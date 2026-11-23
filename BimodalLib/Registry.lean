/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Lean.Elab.Command
import Lean.Meta.Reduce
import FormalSystem.ProofSystem.Derivation
import BimodalLib.Fragment

/-!
# The theorem registry

A theorem is registered by reference: one line, `register_theorem X`, names a closed derivation
`X` declared elsewhere and adds a row for it. The row is a definition of type
`BimodalLib.TheoremEntry`, built from the type of `X` and checked by the kernel. The registry
is the set of constants of that type; nothing is stored in an environment extension.

## Main definitions

* `BimodalLib.TheoremEntry`: a row. Its `proof` field cites the registered declaration at the
  row's statement, so the statement is read from the declaration and cannot be retyped; its
  `profile_eq` field is closed by `rfl`, so the fragment and the modal operator set are
  computed and not asserted.
* `register_theorem X` and `register_theorem X (dual := Y)`: the registration command. The row
  of `X` is the constant `BimodalLib.Registry.X`, with the full name of `X` after the prefix.

## Frame class

The frame class of a row is read from the binders of the declaration: a derivation stated at
every class is filed at `Base`; one with a hypothesis `C ≤ fc` at `C`; one stated at a fixed
class at that class. Above `Base` this is the class the derivation is stated at. The row proves
derivability there and does not prove failure at a weaker class.
-/

namespace BimodalLib

open Lean Meta Elab Command
open FormalSystem.Syntax FormalSystem.ProofSystem

/-- The canonical schema variables: distinct atoms, at which a schematic statement is
instantiated to compute its profile. An instance at distinct atoms contains exactly the
operators of the schema. -/
def schemaVar (i : Nat) : Formula := .atom (Atom.mkFresh "p" i)

/-- A registered theorem. Every field but `dual` is fixed by the registered declaration; the
`proof` and `profile_eq` fields are what the kernel checks. -/
structure TheoremEntry where
  /-- The number of schema variables of the statement. -/
  arity : Nat
  /-- The frame class the derivation is stated at. -/
  frameClass : FrameClass
  /-- The statement, as a function of an assignment to its schema variables. -/
  stmt : (Nat → Formula) → Formula
  /-- The registered derivation, at every frame class above `frameClass` and every assignment.
  Because it holds at every assignment, the statement is schematic in all its variables. -/
  proof : ∀ fc, frameClass ≤ fc → ∀ v, DerivationTree fc [] (stmt v)
  /-- The primitive operators of the statement. -/
  profile : Profile
  /-- The profile is the computed one. -/
  profile_eq : profileF (stmt schemaVar) = profile
  /-- The substitution class of the statement. -/
  substClass : SubstClass := .schematic
  /-- The declaration registered as the dual law in the other polarity, if one is declared. -/
  dual : Option Name := none

/-- The fragment a row is filed in. -/
def TheoremEntry.fragment (e : TheoremEntry) : Fragment := e.profile.fragment

/-- The namespace that holds the rows: the row of `X` is `BimodalLib.Registry.X`. -/
def registryPrefix : Name := `BimodalLib.Registry

/-- The name of the row of a declaration. -/
def rowName (n : Name) : Name := registryPrefix ++ n

/-- A name as an expression built from `Name.anonymous`, `Name.mkStr` and `Name.mkNum` only,
so that `nameOfExpr?` reads it back. -/
def nameToExpr : Name → Expr
  | .anonymous => mkConst ``Name.anonymous
  | .str p s => mkApp2 (mkConst ``Name.mkStr) (nameToExpr p) (mkStrLit s)
  | .num p k => mkApp2 (mkConst ``Name.mkNum) (nameToExpr p) (mkNatLit k)

/-- Reads back a name written by `nameToExpr`. -/
partial def nameOfExpr? (e : Expr) : Option Name :=
  match e.getAppFn.constName?, e.getAppArgs with
  | some ``Name.anonymous, #[] => some .anonymous
  | some ``Name.mkStr, #[p, .lit (.strVal s)] => (nameOfExpr? p).map (.str · s)
  | some ``Name.mkNum, #[p, .lit (.natVal k)] => (nameOfExpr? p).map (.num · k)
  | _, _ => none

/-- The frame class a closed derivation is stated at, and whether that class is fixed in the
conclusion (in which case the row lifts the derivation along `C ≤ fc`). Fails if the type is
not that of a derivation. -/
def frameClassOf (n : Name) (type : Expr) : MetaM (Expr × Bool) :=
  forallTelescope type fun xs body => do
    let mut cls : Option Expr := none
    for x in xs do
      let t ← whnfR (← inferType x)
      if t.isAppOfArity ``LE.le 4 then cls := some t.appFn!.appArg!
    let body ← whnfR body
    unless body.isAppOfArity ``DerivationTree 3 do
      throwError "register_theorem: {.ofConstName n} is not a derivation: its type ends in\
        {indentExpr body}"
    let fcE := body.getAppArgs[0]!
    if fcE.isFVar then return (cls.getD (mkConst ``FrameClass.Base), false)
    else return (fcE, true)

/-- Builds the row of the closed derivation `n` from its type. -/
def mkTheoremEntry (n : Name) (dual : Option Name) : MetaM Expr := do
  let ci ← getConstInfo n
  unless ci.levelParams.isEmpty do
    throwError "register_theorem: {.ofConstName n} is universe-polymorphic"
  let (cls, fixed) ← frameClassOf n ci.type
  let entry ← withLocalDeclD `fc (mkConst ``FrameClass) fun fc => do
    withLocalDeclD `h (← mkAppM ``LE.le #[cls, fc]) fun h => do
    withLocalDeclD `v (← mkArrow (mkConst ``Nat) (mkConst ``Formula)) fun v => do
      let mut ty := ci.type
      let mut args : Array Expr := #[]
      let mut k := 0
      repeat
        let .forallE _ d b _ := ty | break
        let d' ← whnfR d
        let a ←
          if d'.isConstOf ``FrameClass then pure fc
          else if d'.isConstOf ``Formula then do
            let a := mkApp v (mkNatLit k)
            k := k + 1
            pure a
          else if d'.isAppOfArity ``LE.le 4 then pure h
          else throwError "register_theorem: {.ofConstName n} is not a closed derivation: it \
            takes a premise of type{indentExpr d}"
        args := args.push a
        ty := b.instantiate1 a
      let concl ← whnfR ty
      let φ := concl.getAppArgs[2]!
      let ctx ← whnf concl.getAppArgs[1]!
      unless ctx.isAppOf ``List.nil do
        throwError "register_theorem: {.ofConstName n} is not a closed derivation: its context \
          is{indentExpr ctx}"
      if φ.containsFVar fc.fvarId! then
        throwError "register_theorem: the statement of {.ofConstName n} depends on the frame \
          class"
      let stmt ← mkLambdaFVars #[v] φ
      let d := mkAppN (mkConst n) args
      let d ← if fixed then mkAppOptM ``DerivationTree.lift #[cls, fc, h, none, none, d]
        else pure d
      let proof ← mkLambdaFVars #[fc, h, v] d
      let atSchema := mkApp stmt (mkConst ``schemaVar)
      let prof ← reduce (← mkAppM ``profileF #[atSchema.headBeta])
      let profEq ← mkExpectedTypeHint (← mkEqRefl prof)
        (← mkEq (← mkAppM ``profileF #[atSchema]) prof)
      let dualE ← match dual with
        | none => mkAppOptM ``Option.none #[mkConst ``Name]
        | some y => mkAppM ``Option.some #[nameToExpr y]
      mkAppM ``TheoremEntry.mk
        #[mkNatLit k, cls, stmt, proof, prof, profEq, mkConst ``SubstClass.schematic, dualE]
  instantiateMVars entry

/-- Adds the row of `n` to the environment, checked by the kernel and compiled, with a
generated docstring. -/
def addTheoremEntry (n : Name) (dual : Option Name) : MetaM Unit := do
  let entry ← mkTheoremEntry n dual
  let declName := rowName n
  if (← getEnv).contains declName then
    throwError "register_theorem: {.ofConstName n} is already registered"
  addAndCompile <| .defnDecl <| mkDefinitionValEx declName [] (mkConst ``TheoremEntry) entry
    .abbrev .safe [declName]
  addDocStringCore declName
    s!"The registry row of `{n}`: its statement, frame class and operator profile, read from \
      the type of the declaration."

/-- `register_theorem X` adds the registry row of the closed derivation `X`, as the constant
`BimodalLib.Registry.X` of type `BimodalLib.TheoremEntry`. The row is built from the type of
`X`: nothing is retyped. `register_theorem X (dual := Y)` also records `Y` as the law in the
other polarity. The command fails if `X` is not a closed derivation: a derivation from the
empty context whose only premises are formulas, a frame class, and at most a hypothesis
`C ≤ fc`. -/
syntax (name := registerTheorem)
  "register_theorem " ident (" (" &"dual" " := " ident ")")? : command

/-- Elaborates `register_theorem`. -/
@[command_elab registerTheorem] def elabRegisterTheorem : CommandElab := fun stx => do
  match stx with
  | `(register_theorem $x:ident $[(dual := $y?:ident)]?) => liftTermElabM do
    let n ← realizeGlobalConstNoOverloadWithInfo x
    let dual ← y?.mapM fun y => realizeGlobalConstNoOverloadWithInfo y
    addTheoremEntry n dual
  | _ => throwUnsupportedSyntax

end BimodalLib
