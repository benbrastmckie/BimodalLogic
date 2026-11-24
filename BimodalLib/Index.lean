/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Conjecture
import BimodalLib.Conservativity.Table
import BimodalLib.Pairing
import BimodalLib.Registry.Complete

/-!
# The library index

`library_index` renders, in Markdown, every theorem row, pairing row, conservativity edge and
conjecture in the environment: theorems by fragment and frame class, second proofs by statement,
conservativity edges with their verdict, conjectures with their status and note, and, for each
pair of dual operators, the rows that state a law for the universal operator and declare no
dual.

The index is a report. It reads the kernel-checked rows and adds nothing to them: the fragment
and frame class it prints are those of the rows, and the statement it prints is the type of
the registered declaration.

## The polarity census

`BimodalLib.polarityF` records which operators of each dual pair occur in a formula, by
pattern over the primitives: `◇` is recognized as `¬□¬`, `G` as `¬F¬`, and so on, with the
most specific pattern taken first, so that the `G` and `H` inside an `always` are not counted
again. No mechanical test decides whether one law is the dual of another, so the listing of
laws with no dual rests on declared links: a row is listed when its statement has the
universal operator of a pair and its `dual` field is empty.
-/

namespace BimodalLib

open Lean Meta Elab Command
open FormalSystem.Syntax FormalSystem.ProofSystem

/-- Which operators of each dual pair occur in a formula. -/
structure Polarity where
  /-- `□` occurs outside a `◇`. -/
  box : Bool := false
  /-- `◇` occurs. -/
  diamond : Bool := false
  /-- `G` occurs outside an `F`, an `always` and a `sometimes`. -/
  allFuture : Bool := false
  /-- `F` occurs. -/
  someFuture : Bool := false
  /-- `H` occurs outside a `P`, an `always` and a `sometimes`. -/
  allPast : Bool := false
  /-- `P` occurs. -/
  somePast : Bool := false
  /-- `always` occurs outside a `sometimes`. -/
  always : Bool := false
  /-- `sometimes` occurs. -/
  sometimes : Bool := false
  deriving DecidableEq, Repr, Inhabited

/-- The census of a formula built from two parts. -/
def Polarity.join (a b : Polarity) : Polarity :=
  ⟨a.box || b.box, a.diamond || b.diamond, a.allFuture || b.allFuture,
    a.someFuture || b.someFuture, a.allPast || b.allPast, a.somePast || b.somePast,
    a.always || b.always, a.sometimes || b.sometimes⟩

/-- Reads `¬φ`. -/
def asNeg? : Formula → Option Formula
  | .imp φ .bot => some φ
  | _ => none

/-- Reads `φ ∧ ψ`, which is `¬(φ → ¬ψ)`. -/
def asAnd? (χ : Formula) : Option (Formula × Formula) := do
  let .imp φ nψ ← asNeg? χ | none
  let ψ ← asNeg? nψ
  pure (φ, ψ)

/-- Reads `◇φ`, which is `¬□¬φ`. -/
def asDiamond? (χ : Formula) : Option Formula := do
  let .box nφ ← asNeg? χ | none
  asNeg? nφ

/-- Reads `Gφ`, which is `¬F¬φ`. -/
def asAllFuture? (χ : Formula) : Option Formula := do
  let .untl (.imp .bot .bot) nφ ← asNeg? χ | none
  asNeg? nφ

/-- Reads `Hφ`, which is `¬P¬φ`. -/
def asAllPast? (χ : Formula) : Option Formula := do
  let .snce (.imp .bot .bot) nφ ← asNeg? χ | none
  asNeg? nφ

/-- Reads `always φ`, which is `Hφ ∧ (φ ∧ Gφ)`. -/
def asAlways? (χ : Formula) : Option Formula := do
  let (h, rest) ← asAnd? χ
  let (φ, g) ← asAnd? rest
  let φh ← asAllPast? h
  let φg ← asAllFuture? g
  if φh = φ ∧ φg = φ then some φ else none

/-- Reads `sometimes φ`, which is `¬ always ¬φ`. -/
def asSometimes? (χ : Formula) : Option Formula := do
  let nφ ← asAlways? (← asNeg? χ)
  asNeg? nφ

/-- The polarity census of a formula, by pattern over the primitives, most specific pattern
first. -/
partial def polarityF (χ : Formula) : Polarity :=
  if let some φ := asSometimes? χ then { polarityF φ with sometimes := true }
  else if let some φ := asAlways? χ then { polarityF φ with always := true }
  else if let some φ := asAllFuture? χ then { polarityF φ with allFuture := true }
  else if let some φ := asAllPast? χ then { polarityF φ with allPast := true }
  else if let some φ := asDiamond? χ then { polarityF φ with diamond := true }
  else match χ with
    | .untl (.imp .bot .bot) φ => { polarityF φ with someFuture := true }
    | .snce (.imp .bot .bot) φ => { polarityF φ with somePast := true }
    | .box φ => { polarityF φ with box := true }
    | .untl φ ψ => (polarityF φ).join (polarityF ψ)
    | .snce φ ψ => (polarityF φ).join (polarityF ψ)
    | .imp φ ψ => (polarityF φ).join (polarityF ψ)
    | .atom _ => {}
    | .bot => {}

/-- A pair of dual operators: a name for each and how to read each off a census. -/
structure DualPair where
  /-- The universal operator, as printed. -/
  universal : String
  /-- The existential operator, as printed. -/
  existential : String
  /-- Whether the universal operator occurs. -/
  hasUniversal : Polarity → Bool
  /-- Whether the existential operator occurs. -/
  hasExistential : Polarity → Bool

/-- The dual pairs of the base language. The pair of `⊡` and `⟐` belongs to the extended
language, which has no theorem rows; the index says so in its place. -/
def dualPairs : List DualPair :=
  [⟨"□", "◇", (·.box), (·.diamond)⟩,
   ⟨"G", "F", (·.allFuture), (·.someFuture)⟩,
   ⟨"H", "P", (·.allPast), (·.somePast)⟩,
   ⟨"always", "sometimes", (·.always), (·.sometimes)⟩]

/-- A formula from an expression in constructor normal form, whose schema variables are
applications of `v` to a numeral. -/
partial def reifyFormula? (v : Expr) (e : Expr) : Option Formula :=
  match e.getAppFn.constName?, e.getAppArgs with
  | some ``Formula.bot, #[] => some .bot
  | some ``Formula.atom, #[_] => some (.atom (Atom.mkFresh "a" 0))
  | some ``Formula.imp, #[a, b] => .imp <$> reifyFormula? v a <*> reifyFormula? v b
  | some ``Formula.box, #[a] => .box <$> reifyFormula? v a
  | some ``Formula.untl, #[a, b] => .untl <$> reifyFormula? v a <*> reifyFormula? v b
  | some ``Formula.snce, #[a, b] => .snce <$> reifyFormula? v a <*> reifyFormula? v b
  | _, _ =>
    match e with
    | .app f (.lit (.natVal k)) => if f == v then some (.atom (Atom.mkFresh "p" k)) else none
    | _ => none

/-- What the index prints for one theorem row. -/
structure IndexRow where
  /-- The registered declaration. -/
  decl : Name
  /-- The statement, as the declaration states it. -/
  statement : String
  /-- The fragment of the row. -/
  fragment : Fragment
  /-- The frame class of the row. -/
  frameClass : String
  /-- The profile of the row. -/
  profile : Profile
  /-- The polarity census of the statement. -/
  polarity : Polarity
  /-- The declared dual. -/
  dual : Option Name

/-- Reads a Boolean literal. -/
def boolOfExpr? (e : Expr) : Option Bool :=
  if e.isConstOf ``Bool.true then some true
  else if e.isConstOf ``Bool.false then some false
  else none

/-- Reads a profile in constructor normal form. -/
def profileOfExpr? (e : Expr) : Option Profile := do
  guard (e.isAppOfArity ``Profile.mk 3)
  let a := e.getAppArgs
  pure ⟨← boolOfExpr? a[0]!, ← boolOfExpr? a[1]!, ← boolOfExpr? a[2]!⟩

/-- Reads a fragment constant. -/
def fragmentOfExpr? (e : Expr) : Option Fragment :=
  match e.constName? with
  | some ``Fragment.Boolean => some .Boolean
  | some ``Fragment.ModalBoolean => some .ModalBoolean
  | some ``Fragment.TemporalBoolean => some .TemporalBoolean
  | some ``Fragment.ModalTemporalBoolean => some .ModalTemporalBoolean
  | _ => none

/-- Pretty-prints an expression on one line, with the namespaces of the two languages open. -/
def ppOneLine (e : Expr) : MetaM String :=
  let opened : List OpenDecl := [`FormalSystem.Syntax, `FormalSystem.ProofSystem,
    `FormalSystem.PlusLanguage, `FormalSystem.Theorems.ModalS5, `BimodalLib].map (.simple · [])
  withTheReader Core.Context (fun c => { c with openDecls := opened ++ c.openDecls }) do
    return (← ppExpr e).pretty (width := 100000)

/-- The statement of a closed derivation, as its declaration states it. -/
def statementString (n : Name) : MetaM String := do
  forallTelescope (← getConstInfo n).type fun _ body => do
    ppOneLine (← whnfR body).getAppArgs[2]!

/-- The index row of a theorem row. -/
def indexRow (n : Name) (ci : ConstantInfo) : MetaM IndexRow := do
  let bad {α} : MetaM α := throwError "the registry row of {n} is not in the expected form"
  let some val := ci.value? | bad
  unless val.isAppOfArity ``TheoremEntry.mk 8 do bad
  let args := val.getAppArgs
  let some profile := profileOfExpr? (← reduce args[4]!) | bad
  let some fc := (← whnf args[1]!).constName? | bad
  let census ← withLocalDeclD `v (← mkArrow (mkConst ``Nat) (mkConst ``Formula)) fun v => do
    let some φ := reifyFormula? v (← reduce (mkApp args[2]! v).headBeta) | bad
    pure (polarityF φ)
  return {
    decl := n, statement := ← statementString n, fragment := profile.fragment,
    frameClass := fc.getString!, profile, polarity := census, dual := rowDual? ci }

/-- A name in backticks. -/
def code (s : String) : String := "`" ++ s ++ "`"

/-- The frame classes, in the order the index lists them. -/
def frameClassOrder : List String := ["Base", "Dense", "ZTime", "RTime"]

/-- The fragments, in the order the index lists them. -/
def fragmentOrder : List Fragment :=
  [.Boolean, .ModalBoolean, .TemporalBoolean, .ModalTemporalBoolean]

/-- The theorem sections of the index. -/
def renderTheorems (rows : Array IndexRow) : String := Id.run do
  let mut out := s!"## Theorems\n\n{rows.size} registered theorems. A frame class other than \
    `Base` is the class the registered derivation is stated at; the row proves derivability \
    there and at every stronger class, and does not prove failure at a weaker one.\n\n"
  out := out ++ "| Fragment | " ++ " | ".intercalate frameClassOrder ++ " | Total |\n"
  out := out ++ "|---|" ++ String.join (frameClassOrder.map fun _ => "---|") ++ "---|\n"
  for fr in fragmentOrder do
    let inFr := rows.filter (·.fragment == fr)
    let cells := frameClassOrder.map fun fc => toString (inFr.filter (·.frameClass == fc)).size
    out := out ++ s!"| {code fr.name} | " ++ " | ".intercalate cells ++ s!" | {inFr.size} |\n"
  for fr in fragmentOrder do
    out := out ++ s!"\n### {fr.name}\n"
    for fc in frameClassOrder do
      let cell := rows.filter fun r => r.fragment == fr && r.frameClass == fc
      if cell.isEmpty then continue
      let label := if fc == "Base" then "Base" else s!"stated at {fc}"
      out := out ++ s!"\n#### {fr.name}, {label} ({cell.size})\n\n"
      out := out ++ "| Declaration | Statement | Modal operators | Declared dual |\n"
      out := out ++ "|---|---|---|---|\n"
      for r in cell do
        let dual := match r.dual with
          | some d => code (toString d)
          | none => ""
        out := out ++ s!"| {code (toString r.decl)} | {code r.statement} | \
          {r.profile.opsName} | {dual} |\n"
  return out

/-- The dual-pair section of the index. -/
def renderDuals (rows : Array IndexRow) : String := Id.run do
  let mut out := "## Laws with no declared dual\n\nEach operator is entered in both \
    polarities. For each pair, the rows below state a law for the universal operator and \
    declare no dual with `register_theorem X (dual := Y)`. The operators of a statement are \
    recognized by pattern over the primitives; whether one law is the dual of another is \
    declared, not computed.\n"
  for p in dualPairs do
    let u := rows.filter fun r => p.hasUniversal r.polarity
    let e := rows.filter fun r => p.hasExistential r.polarity
    let both := u.filter fun r => p.hasExistential r.polarity
    let undeclared := u.filter (·.dual.isNone)
    out := out ++ s!"\n### {p.universal} and {p.existential}\n\n"
    out := out ++ s!"{u.size - both.size} rows have {p.universal} only, \
      {e.size - both.size} have {p.existential} only, {both.size} have both. \
      {undeclared.size} of the {u.size} rows with {p.universal} declare no dual.\n\n"
    for r in undeclared do
      out := out ++ s!"- {code (toString r.decl)}: {code r.statement}\n"
  out := out ++ "\n### ⊡ and ⟐\n\nNo theorem row is stated in the extended language, so no \
    row has either operator.\n"
  return out

/-- The pairing section of the index. -/
def renderReproofs : MetaM String := do
  let env ← getEnv
  let mut pairs : Array (String × String) := #[]
  for (n, ci) in env.constants.map₁.toList ++ env.constants.map₂.toList do
    unless ci.type.isConstOf ``ReproofEntry && reproofPrefix.isPrefixOf n do continue
    let some val := ci.value? | continue
    unless val.isAppOfArity ``ReproofEntry.mk 2 do continue
    let some row := val.getAppArgs[0]!.constName? | continue
    pairs := pairs.push (toString (row.replacePrefix registryPrefix .anonymous),
      toString (n.replacePrefix reproofPrefix .anonymous))
  let sorted := pairs.qsort fun a b => a.1 < b.1 || (a.1 == b.1 && a.2 < b.2)
  let mut out := s!"## Second proofs\n\n{sorted.size} second proofs paired with a registered \
    statement by `reprove X as Y := t`.\n"
  unless sorted.isEmpty do
    out := out ++ "\n| Registered statement | Second proof |\n|---|---|\n"
    for (x, y) in sorted do
      out := out ++ s!"| {code x} | {code y} |\n"
  return out

/-- The conservativity-edge section of the index. The status of a row is the constructor of its
verdict, so it reads "proved" or "refuted" only when the row holds a kernel-checked proof of its
statement or of the negation. -/
def renderEdges : MetaM String := do
  let env ← getEnv
  let mut items : Array (Nat × String × Option (String × String)) := #[]
  for (n, ci) in env.constants.map₁.toList ++ env.constants.map₂.toList do
    unless ci.type.isConstOf ``ConservativityEdge do continue
    let c := mkConst n
    let bad {α} (what : String) : MetaM α :=
      throwError "the conservativity edge {n} has no computable {what}"
    let orderE ← whnf (← mkAppM ``ConservativityEdge.order #[c])
    let some order := orderE.rawNatLit? <|> orderE.nat? | bad "order"
    let .lit (.strVal smaller) ← whnf (← mkAppM ``ConservativityEdge.smaller #[c])
      | bad "cell"
    let .lit (.strVal larger) ← whnf (← mkAppM ``ConservativityEdge.larger #[c])
      | bad "cell"
    let .lit (.strVal reference) ← whnf (← mkAppM ``ConservativityEdge.reference #[c])
      | bad "reference"
    let fcE ← whnf (← mkAppM ``ConservativityEdge.frameClass #[c])
    let fc ← if fcE.isAppOfArity ``Option.some 2 then
        pure ((← whnf fcE.appArg!).constName?.map (·.getString!) |>.getD "?")
      else pure "every class"
    let verdict ← whnf (← mkAppM ``ConservativityEdge.verdict #[c])
    let (status, obstruction) ← match verdict.getAppFn.constName? with
      | some ``EdgeVerdict.proved => pure ("proved", none)
      | some ``EdgeVerdict.refuted => pure ("refuted", none)
      | some ``EdgeVerdict.open =>
        let .lit (.strVal text) ← whnf verdict.appArg! | bad "obstruction"
        pure ("open", some (reference, text))
      | _ => bad "verdict"
    items := items.push (order,
      s!"| {smaller} | {larger} | {fc} | {status} | {code reference} |\n", obstruction)
  let sorted := items.qsort (·.1 < ·.1)
  let mut out := s!"## Conservativity edges\n\n{sorted.size} registered edges. An edge claims \
    that the larger cell or system derives nothing new about the formulas of the smaller cell. \
    A row reads proved when it holds a proof of its statement, refuted when it holds a proof of \
    the negation, and open otherwise; the last column names the theorem, or for an open edge \
    the conjecture that states it.\n\n"
  out := out ++ "| Smaller cell | Larger cell or system | Frame class | Status | Reference |\n"
  out := out ++ "|---|---|---|---|---|\n"
  for (_, row, _) in sorted do
    out := out ++ row
  let opens := sorted.filterMap (·.2.2)
  unless opens.isEmpty do
    out := out ++ "\n### Open edges\n\nWhat stands in the way of each open edge.\n\n"
    for (reference, text) in opens do
      out := out ++ s!"- {code reference}: {text}\n"
  return out

/-- The conjecture section of the index. -/
def renderConjectures : MetaM String := do
  let env ← getEnv
  let mut items : Array (String × String) := #[]
  for (n, ci) in env.constants.map₁.toList ++ env.constants.map₂.toList do
    unless ci.type.isConstOf ``Conjecture do continue
    let c := mkConst n
    let some fr := fragmentOfExpr? (← reduce (← mkAppM ``Conjecture.fragment #[c]))
      | throwError "the conjecture {n} has no computable fragment"
    let some ops := profileOfExpr? (← reduce (← mkAppM ``Conjecture.ops #[c]))
      | throwError "the conjecture {n} has no computable operator set"
    let fcE ← whnf (← mkAppM ``Conjecture.frameClass #[c])
    let fc ← if fcE.isAppOfArity ``Option.some 2 then
        pure ((← whnf fcE.appArg!).constName?.map (·.getString!) |>.getD "?")
      else pure "every class"
    let some status := (← whnf (← mkAppM ``Conjecture.status #[c])).constName?
      | throwError "the conjecture {n} has no computable status"
    let .lit (.strVal note) ← whnf (← mkAppM ``Conjecture.note #[c])
      | throwError "the note of the conjecture {n} is not a string literal"
    let stmt ← ppOneLine (← whnfCore (← whnfR (← mkAppM ``Conjecture.statement #[c])))
    let statusName := match status with
      | ``ConjectureStatus.unsettled => ConjectureStatus.unsettled.name
      | ``ConjectureStatus.heuristicallyRefuted => ConjectureStatus.heuristicallyRefuted.name
      | ``ConjectureStatus.undetermined => ConjectureStatus.undetermined.name
      | ``ConjectureStatus.derived => ConjectureStatus.derived.name
      | _ => ConjectureStatus.refuted.name
    items := items.push (toString n,
      s!"### {code (toString n)}\n\n- Fragment: {code fr.name}; modal operators: \
        {ops.opsName}; frame class: {fc}\n- Status: {statusName}\n- Statement: \
        {code stmt}\n- Note: {note}\n")
  let sorted := items.qsort (·.1 < ·.1)
  let mut out := s!"## Conjectures\n\n{sorted.size} registered conjectures. A conjecture is a \
    statement with no proof; none is a result.\n"
  for (_, s) in sorted do
    out := out ++ "\n" ++ s
  return out

/-- The whole index, as Markdown. -/
def renderIndex : MetaM String := do
  let rows ← (← registryRows).mapM fun (n, ci) => indexRow n ci
  return "# BimodalLib index\n\nGenerated by `scripts/library-index.sh` from the rows of the \
    library; do not edit. Regenerate it with that script after registering a theorem, a \
    second proof, a conservativity edge or a conjecture.\n\n" ++ renderTheorems rows ++ "\n"
    ++ (← renderReproofs)
    ++ "\n" ++ (← renderEdges) ++ "\n" ++ (← renderConjectures) ++ "\n" ++ renderDuals rows

/-- `library_index` prints the index of the library, in Markdown, to standard output.
`library_index to "path"` writes it to a file instead. The index covers the theorem rows,
pairing rows, conservativity edges and conjectures of the modules imported where the command
runs. -/
syntax (name := libraryIndex) "library_index" (" to " str)? : command

/-- Elaborates `library_index`. -/
@[command_elab libraryIndex] def elabLibraryIndex : CommandElab := fun stx =>
  match stx with
  | `(library_index $[to $path?:str]?) => do
    let text ← liftTermElabM renderIndex
    match path? with
    | some path => IO.FS.writeFile path.getString text
    | none => IO.println text
  | _ => throwUnsupportedSyntax

end BimodalLib
