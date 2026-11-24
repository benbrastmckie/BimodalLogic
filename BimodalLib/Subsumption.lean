/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Registry.Complete
import FormalSystem.ProofSystem.Substitution

/-!
# Subsumption: when one statement is a substitution instance of another

A registry row is schematic: its statement is `stmt schemaVar`, a formula whose atoms are the
schema variables. Two rows can therefore say the same thing at different generality — `□A → A`
subsumes `□⊥ → ⊥`, and registering both adds a row that carries no information the first does
not already give.

This module decides that relation. `matchSubst? schema target` returns the witness assignment
`σ` with `substF σ schema = target` when one exists, and `none` otherwise; `isSubstInstance` is
its `Bool` face. `assert_no_subsumed_entries` turns non-redundancy of the registry into a build
invariant: it fails when one registered row's statement is a substitution instance of another's.

## The matcher is computable, not kernel-verified

`matchSubst?` carries no proof that its witness substitutes correctly. That is deliberate and
safe in the only direction that matters: a wrong answer can drop a row that should have been
admitted, or admit a row that was already subsumed, but it can never admit an **unproved**
entry, because admission still requires a `DerivationTree` of its own. The failure mode is a
redundant or missing library row, not an unsound one.

What the matcher must not do is say "instance" when there is none, which is why the agreement
check on a recurring variable **fails on disagreement** rather than overwriting the earlier
binding: `A → A` matches `⊥ → ⊥` and must not match `⊥ → p`.

## Main Definitions

- `BimodalLib.matchSubst?` — the witness assignment, or `none`
- `BimodalLib.isSubstInstance` — the `Bool` face
- `BimodalLib.matchSubstP?` — the same over `PlusFormula`, with the `⊡` case
- `BimodalLib.isSubstInstanceP` — its `Bool` face
- `BimodalLib.assert_no_subsumed_entries` — the build-time non-redundancy check

## References

* `FormalSystem/ProofSystem/Substitution.lean` — `substF`, the substitution the witness feeds
* `BimodalLib/Registry.lean` — `TheoremEntry`, `schemaVar`, `rowName`
* `BimodalLib/Registry/Complete.lean` — `registryRows`, the environment walk reused here

## Tags

subsumption · substitution · registry · theorem-library
-/

namespace BimodalLib

open Lean Meta Elab Command
open FormalSystem.Syntax FormalSystem.ProofSystem
-- Only the type name is opened, not the whole namespace: the extended language's defined
-- operators share spellings with the base language's and would shadow them here.
open FormalSystem.PlusLanguage (PlusFormula)

/-! ## The matcher -/

/-- Extend an assignment with `p ↦ φ`, failing when `p` is already bound to something else.
This is the agreement check that makes a recurring schema variable behave as one variable. -/
def bindAtom (acc : List (Atom × Formula)) (p : Atom) (φ : Formula) :
    Option (List (Atom × Formula)) :=
  match acc.find? (fun kv => kv.1 = p) with
  | some kv => if kv.2 = φ then some acc else none
  | none => some ((p, φ) :: acc)

/-- The matcher's worker: match `schema` against `target`, threading the assignment built so
far. An atom of `schema` matches anything, subject to agreement; every other constructor must
match head to head. -/
def matchSubstAux : Formula → Formula → List (Atom × Formula) → Option (List (Atom × Formula))
  | .atom p, target, acc => bindAtom acc p target
  | .bot, .bot, acc => some acc
  | .imp φ₁ ψ₁, .imp φ₂ ψ₂, acc => matchSubstAux φ₁ φ₂ acc >>= matchSubstAux ψ₁ ψ₂
  | .box φ₁, .box φ₂, acc => matchSubstAux φ₁ φ₂ acc
  | .untl φ₁ ψ₁, .untl φ₂ ψ₂, acc => matchSubstAux φ₁ φ₂ acc >>= matchSubstAux ψ₁ ψ₂
  | .snce φ₁ ψ₁, .snce φ₂ ψ₂, acc => matchSubstAux φ₁ φ₂ acc >>= matchSubstAux ψ₁ ψ₂
  | _, _, _ => none

/--
The witness assignment making `target` a substitution instance of `schema`, or `none`.

One structural pass. An atom of `schema` binds to the subterm of `target` facing it; a recurring
atom must meet the same subterm again, or the match fails. The returned list binds each atom of
`schema` that actually occurs, so `substF (fun p => (result.find? …).getD (.atom p)) schema`
is `target`.
-/
def matchSubst? (schema target : Formula) : Option (List (Atom × Formula)) :=
  matchSubstAux schema target []

/-- Whether `target` is a substitution instance of `schema`. -/
def isSubstInstance (schema target : Formula) : Bool := (matchSubst? schema target).isSome

/-! ## The matcher over the extended language

The matcher above is `Formula`-only by type. A countermodel row may be stated in L⁺ (every row
that mentions `⊡` is), and the proof mode's unclosed-leaf lookup must reach those rows too, so
the four functions are mirrored here with one extra constructor case.

The mirror is structural and deliberate rather than abstracted over a class: a shared matcher
would need the language's constructor set as data, which is exactly what the two inductives do
not share. The agreement check on a recurring variable behaves as it does above — it **fails on
disagreement** rather than overwriting the earlier binding, so `⊡A → A` matches `⊡⊥ → ⊥` and
must not match `⊡⊥ → p`.
-/

/-- Extend an assignment over the extended language with `p ↦ φ`, failing when `p` is already
bound to something else. -/
def bindAtomP (acc : List (Atom × PlusFormula)) (p : Atom) (φ : PlusFormula) :
    Option (List (Atom × PlusFormula)) :=
  match acc.find? (fun kv => kv.1 = p) with
  | some kv => if kv.2 = φ then some acc else none
  | none => some ((p, φ) :: acc)

/-- The extended matcher's worker: match `schema` against `target`, threading the assignment
built so far. An atom of `schema` matches anything, subject to agreement; every other
constructor must match head to head, `⊡` included. -/
def matchSubstPAux : PlusFormula → PlusFormula → List (Atom × PlusFormula) →
    Option (List (Atom × PlusFormula))
  | .atom p, target, acc => bindAtomP acc p target
  | .bot, .bot, acc => some acc
  | .imp φ₁ ψ₁, .imp φ₂ ψ₂, acc => matchSubstPAux φ₁ φ₂ acc >>= matchSubstPAux ψ₁ ψ₂
  | .box φ₁, .box φ₂, acc => matchSubstPAux φ₁ φ₂ acc
  | .stab φ₁, .stab φ₂, acc => matchSubstPAux φ₁ φ₂ acc
  | .untl φ₁ ψ₁, .untl φ₂ ψ₂, acc => matchSubstPAux φ₁ φ₂ acc >>= matchSubstPAux ψ₁ ψ₂
  | .snce φ₁ ψ₁, .snce φ₂ ψ₂, acc => matchSubstPAux φ₁ φ₂ acc >>= matchSubstPAux ψ₁ ψ₂
  | _, _, _ => none

/-- The witness assignment making the extended-language `target` a substitution instance of
`schema`, or `none`. One structural pass, as in the base-language case. -/
def matchSubstP? (schema target : PlusFormula) : Option (List (Atom × PlusFormula)) :=
  matchSubstPAux schema target []

/-- Whether the extended-language `target` is a substitution instance of `schema`. -/
def isSubstInstanceP (schema target : PlusFormula) : Bool := (matchSubstP? schema target).isSome

/-- The assignment as a function, defaulting to the atom itself off the bound set. -/
def assignmentOf (acc : List (Atom × Formula)) : Atom → Formula :=
  fun p => match acc.find? (fun kv => kv.1 = p) with
    | some kv => kv.2
    | none => .atom p

/-! ## The registry scan -/

/-- The statement of a registry row at the schema variables, evaluated to a `Formula`. Returns
`none` when the row's `stmt` field does not reduce to a closed formula. -/
def rowStatement? (ci : ConstantInfo) : MetaM (Option Formula) := do
  let stmt := mkApp (mkApp (mkConst ``TheoremEntry.stmt) (mkConst ci.name)) (mkConst ``schemaVar)
  try
    let f ← unsafe evalExpr Formula (mkConst ``Formula) (← instantiateMVars stmt)
    return some f
  catch _ => return none

/--
The first registered row, other than `self`, whose statement `stmt` is a substitution instance
of. Returns the subsuming row's registered declaration name.

The scan walks the same `registryRows` the registration check uses, so the two commands range
over exactly the same set of rows.
-/
def subsumedBy? (self : Name) (stmt : Formula) : MetaM (Option Name) := do
  for (target, ci) in ← registryRows do
    if target == self then continue
    let some schema ← rowStatement? ci | continue
    if isSubstInstance schema stmt then return some target
  return none

/--
`assert_no_subsumed_entries` fails when one registered row's statement is a substitution
instance of another's, naming both. It logs the number of rows it compared. Only imported
modules are scanned, exactly as `assert_registry_complete` is.

`assert_no_subsumed_entries P` restricts the **candidate** side to rows whose registered
declaration has prefix `P`, while still comparing against every row in scope as a possible
subsumer. That is the form the enumerated pipeline uses: it must not admit an entry subsumed by
anything already in the library, but it has no business indicting a hand-curated row.

**The unscoped form does not pass over the live registry, and that is a fact about the library,
not a defect here.** 26 of the 190 registered rows are substitution instances of another row,
because the library deliberately names laws that are instances of more general schemata —
`Combinators.topThm : ⊤` is `Combinators.identity` at `⊥`, and its own proof term is literally
`identity Formula.bot`; `Propositional.em : A ∨ ¬A` unfolds to `(A → ⊥) → (A → ⊥)`, an instance
of `A → A`. Making the unscoped form a build invariant would turn the build red on those rows.
Whether the registry should be globally non-redundant, or whether non-redundancy is a property
only of machine-generated entries, is a design question this module does not decide; it supplies
both forms and leaves the choice to the caller.
-/
syntax (name := assertNoSubsumedEntries)
  "assert_no_subsumed_entries" (ppSpace ident)? : command

/-- Elaborates `assert_no_subsumed_entries`. -/
@[command_elab assertNoSubsumedEntries] def elabAssertNoSubsumedEntries : CommandElab := fun stx =>
  match stx with
  | `(assert_no_subsumed_entries $[$p?:ident]?) => liftTermElabM do
    let pfx? := p?.map (·.getId)
    let rows ← registryRows
    let mut statements : Array (Name × Formula) := #[]
    for (target, ci) in rows do
      if let some f ← rowStatement? ci then statements := statements.push (target, f)
    let mut offenders : Array MessageData := #[]
    let candidates := match pfx? with
      | none => statements
      | some pfx => statements.filter (fun (n, _) => pfx.isPrefixOf n)
    for (target, stmt) in candidates do
      for (other, schema) in statements do
        if other == target then continue
        -- A row subsumes another only if it is strictly more general: both directions matching
        -- means the two statements are renamings of each other, which `register_theorem`
        -- already refuses by name, so only the strict direction is an offence.
        if isSubstInstance schema stmt && !isSubstInstance stmt schema then
          offenders := offenders.push m!"{target} is a substitution instance of {other}"
          break
    logInfo m!"compared {candidates.size} candidate row(s) against {statements.size} row(s) \
      of {rows.size} for subsumption"
    unless offenders.isEmpty do
      throwError "{offenders.size} registered row(s) are subsumed by another row; drop the \
        subsumed row or state it as the general schema:{indentD (MessageData.joinSep
          offenders.toList Format.line)}"
  | _ => throwUnsupportedSyntax

end BimodalLib
