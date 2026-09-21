/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem

/-!
# Reusable `MetaM` plumbing for derivability goals

The small, general operations on a `DerivationTree` goal that more than one tactic needs:
recognising such a goal, reading the head symbol of a formula or of a lemma's conclusion,
recognising the empty context, and rebuilding a context expression from a list of formulas.

This is the reused third of the old 1,210-line `Automation/Tactics/Helpers.lean`, and the only
third that was genuinely shared: `Metalogic/Decidability/Propositional/Tactic.lean` uses
`extractDerivationGoal` and `isNilContext`, and `Automation/Tactics/Commands.lean` uses
`extractDerivationGoal` alongside the search engine. The other two thirds are
[`UserTactics.lean`](../Automation/Tactics/UserTactics.lean) and
[`Search.lean`](../Automation/Tactics/Search.lean).

This file imports neither of them; `Search.lean` imports this one.

**Why this lives at layer 0 rather than in `Automation/Tactics/`.** Its consumers are spread
across `Automation/` and `Metalogic/`, so leaving it under `Automation/` made the propositional
tactic's relocation into `Metalogic/Decidability/Propositional/` trade one `Metalogic ->
Automation` import line for another. It is ordinary metaprogramming, not an attribute
declaration: unlike its sibling [`Attr.lean`](Attr.lean) it imports `FormalSystem.ProofSystem`,
reaches `FormalSystem.Init` in the usual way, and carries none of that file's attributes-only
constraint.

## Recorded namespace exception

This module is `FormalSystem.Tactic.Meta` but declares `namespace FormalSystem.Automation`, so
`scripts/measure-refactor-partitions.py namespace-audit` reports it in the `unrelated` bucket.
The namespace deliberately did not move with the file, for the same reason
`Theorems/DeductionTheorem.lean` kept `FormalSystem.Metalogic.Core`: the declarations are reached
through `open FormalSystem.Automation` at every consumer, and renaming is churn out of proportion
to the gain. A later FQN pass may rename it; until then this is the record, so the audit row reads
as a decision rather than an oversight.

## Main declarations

- `extractDerivationGoal` — is this goal `DerivationTree fc Γ φ`, and if so, what are the three?
- `formulaHead`, `lemmaConclusionHead` — head-symbol readers, for cheap pre-filtering
- `isNilContext` — recognise the empty context
- `buildContextExpr` — rebuild a `Context` expression from a list of `Formula` expressions

## Tags

meta · elaboration · derivation-goals
-/

open FormalSystem.Syntax FormalSystem.ProofSystem
open Lean Elab Tactic Meta

namespace FormalSystem.Automation

/-!
### Helper: Extract DerivationTree goal components
-/

/--
Extract context and formula from a `DerivationTree Γ φ` goal type.

Returns `some (Γ, φ)` if the goal is a derivability goal, `none` otherwise.
-/
def extractDerivationGoal (goalType : Expr) : MetaM (Option (Expr × Expr × Expr)) := do
  match goalType with
  | .app (.app (.app (.const ``DerivationTree _) fc) ctx) formula =>
    return some (fc, ctx, formula)
  | _ => return none

/--
Head constant of a `Formula` expression (e.g. `Formula.imp` for `A → B`).
Returns `none` when the head is not a constant (a bound/free variable
conclusion), which the pre-filter treats as a wildcard.
-/
def formulaHead (formula : Expr) : Option Name :=
  match formula.getAppFn with
  | .const n _ => some n
  | _ => none

/--
Head constant of a labelled lemma's conclusion `Formula`, obtained by
telescoping the lemma type's binders and reading the `DerivationTree` goal.
Returns `none` for non-derivability conclusions or variable heads (wildcard).
-/
def lemmaConclusionHead (lemmaName : Name) : MetaM (Option Name) := do
  let info ← getConstInfo lemmaName
  forallTelescope info.type fun _ concl => do
    match ← extractDerivationGoal concl with
    | some (_, _, formula) => return formulaHead formula
    | none => return none

/--
Is `ctx` the literal empty context `([] : Context)`? Used to avoid a
non-terminating weakening fallback (weakening `[] ⊆ []` would recurse on the
same goal). A `cons` or variable context is treated as potentially non-empty.
-/
def isNilContext (ctx : Expr) : Bool :=
  match ctx with
  | .app (.const ``List.nil _) _ => true
  | .const ``List.nil _ => true
  | _ => false

/--
Build a List expression from a list of formula expressions.
-/
def buildContextExpr (formulas : List Expr) : MetaM Expr := do
  let formulaType := mkConst ``Formula
  let mut result ← mkAppM ``List.nil #[formulaType]
  for f in formulas.reverse do
    result ← mkAppM ``List.cons #[f, result]
  return result

end FormalSystem.Automation
