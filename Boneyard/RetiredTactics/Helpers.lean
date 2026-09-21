/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.UserTactics

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.
Do not import from live code.
-/

#exit

/-!
# Retired: the operator-K and modal-axiom tactics

`mkOperatorKTactic` and the four tactics built on or beside it -- `modal_k_tactic`,
`temporal_k_tactic`, `modal_4_tactic`, `modal_b_tactic` -- lifted out of
`FormalSystem/Automation/Tactics/Helpers.lean`. Every one had exactly one occurrence in live
scope: its own docstring's example block. See [`README.md`](README.md) for the measurement.

This is an EXCERPT, not a module that was archived whole. The formula predicates and extractors
these tactics used (`isBoxFormula`, `isFutureFormula`, `extractFromBox`, `extractFromFuture`)
stayed live, because they carry real test coverage of their own, and so did the search engine
below them. `Helpers.lean` itself no longer exists: it was split into
`Tactics/{UserTactics,Meta,Search}.lean` immediately after this retirement, and the predicates
are now in `UserTactics.lean`, which is what this file imports. To resurrect a tactic, paste it
back into `UserTactics.lean` -- do not restore this file as a module.

Nothing under `Boneyard/` is compiled, and this file is not reachable from `lakefile.lean`'s
`FormalSystem` root.

## Tags

retired · tactics · modal-k · temporal-k · aesop
-/

namespace FormalSystem.Automation

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open Lean Elab Tactic Meta

/-!
## Tactic Factory Functions

Factory functions for creating operator-specific tactics with reduced code duplication.
-/

/--
Factory function for operator K inference rule tactics.

Creates tactics that apply modal K or temporal K rules to goals of form `Γ ⊢ ◯φ`.

**Parameters**:
- `tacticName`: Name of tactic (for error messages)
- `operatorConst`: Formula operator constructor (e.g., ``Formula.box``)
- `ruleConst`: Derivable inference rule (e.g., ``Theorems.generalizedModalK``)
- `operatorSymbol`: Unicode symbol for error messages (e.g., "□")

**Returns**: TacticM action that applies the K rule for the specified operator.

**Example Usage**:
```lean
elab "modal_k_tactic" : tactic =>
  mkOperatorKTactic "modal_k_tactic" ``Formula.box ``Theorems.generalizedModalK "□"
```
-/
def mkOperatorKTactic (tacticName : String) (operatorConst : Name)
    (ruleConst : Name) (operatorSymbol : String) : TacticM Unit := do
  let goal ← getMainGoal
  let goalType ← goal.getType

  match goalType with
  | .app (.app (.app (.const ``DerivationTree _) _fc) _context) formula =>
    match formula with
    | .app (.const opConst _) _innerFormula =>
      if opConst == operatorConst then
        let ruleConstExpr := mkConst ruleConst
        let newGoals ← goal.apply ruleConstExpr
        replaceMainGoal newGoals
      else
        throwError "{tacticName}: expected goal formula to be {operatorSymbol}φ, got {formula}"
    | _ =>
      throwError "{tacticName}: expected goal formula to be {operatorSymbol}φ, got {formula}"
  | _ =>
    throwError "{tacticName}: goal must be derivability relation Γ ⊢ φ, got {goalType}"

/-!
## Phase 1: Inference Rule Tactics (modal_k_tactic, temporal_k_tactic)

Tactics for applying modal K and temporal K inference rules with context transformation.

**Implementation Note**: These tactics now use the `mkOperatorKTactic` factory function
to eliminate code duplication. The factory pattern reduces 52 lines to ~30 lines while
preserving all functionality.
-/

/--
`modal_k_tactic` applies the modal K inference rule.

Given a goal `Derivable (□Γ) (□φ)`, creates subgoal `Derivable Γ φ`
and applies `Theorems.generalizedModalK`.

**Example**:
```lean
example (p : Formula) : [p.box] ⊢ (p.box) := by
  -- Goal: [□p] ⊢ □p
  -- After modal_k_tactic: subgoal [p] ⊢ p
  modal_k_tactic
  assumption
```

**Implementation**: Uses `mkOperatorKTactic` factory for modal operator.
-/
elab "modal_k_tactic" : tactic =>
  mkOperatorKTactic "modal_k_tactic" ``Formula.box ``Theorems.generalizedModalK "□"

/--
`temporal_k_tactic` applies the temporal K inference rule.

Given a goal `Derivable (FΓ) (Fφ)`, creates subgoal `Derivable Γ φ`
and applies `Derivable.temporal_k`.

**Example**:
```lean
example (p : Formula) : [p.allFuture] ⊢ (p.allFuture) := by
  -- Goal: [Fp] ⊢ Fp
  -- After temporal_k_tactic: subgoal [p] ⊢ p
  temporal_k_tactic
  assumption
```

**Implementation**: Uses `mkOperatorKTactic` factory for temporal operator.
-/
elab "temporal_k_tactic" : tactic =>
  mkOperatorKTactic "temporal_k_tactic" ``Formula.allFuture ``Theorems.generalizedTemporalK "F"

/-!
## Phase 2: Modal Axiom Tactics (modal_4_tactic, modal_b_tactic)

Tactics for applying modal 4 and modal B axioms with formula pattern matching.
-/

/--
`modal_4_tactic` applies the modal 4 axiom `□φ → □□φ`.

Automatically applies the axiom when the goal matches the pattern.

**Example**:
```lean
example (p : Formula) : ⊢ ((p.box).imp (p.box.box)) := by
  modal_4_tactic
```

**Implementation**: Uses `elab` following modal_t template.
-/
elab "modal_4_tactic" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType

  match goalType with
  | .app (.app (.app (.const ``DerivationTree _) _fc) _context) formula =>

    match formula with
    | .app (.app (.const ``Formula.imp _) lhs) rhs =>

      match lhs with
      | .app (.const ``Formula.box _) innerFormula =>

        match rhs with
        | .app (.const ``Formula.box _) (.app (.const ``Formula.box _) innerFormula2) =>

          if ← isDefEq innerFormula innerFormula2 then
            let axiomProof ← mkAppM ``Axiom.modal_4 #[innerFormula]
            -- modal_4 is a base axiom so h_fc = trivial
            let hfc ← mkAppM ``trivial #[]
            let proof ← mkAppM ``DerivationTree.axiom #[axiomProof, hfc]
            goal.assign proof
          else
            throwError (
              "modal_4_tactic: expected □φ → □□φ pattern with same φ, " ++
              "got □{innerFormula} → □□{innerFormula2}")

        | _ =>
          throwError "modal_4_tactic: expected □□φ on right side, got {rhs}"

      | _ =>
        throwError "modal_4_tactic: expected □φ on left side, got {lhs}"

    | _ =>
      throwError "modal_4_tactic: expected implication, got {formula}"

  | _ =>
    throwError "modal_4_tactic: goal must be derivability relation, got {goalType}"

/--
`modal_b_tactic` applies the modal B axiom `φ → □◇φ`.

Automatically applies the axiom when the goal matches the pattern.

**Example**:
```lean
example (p : Formula) : ⊢ (p.imp (p.diamond.box)) := by
  modal_b_tactic
```

**Implementation**: Uses `elab` with derived operator handling for `diamond`.
-/
elab "modal_b_tactic" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType

  match goalType with
  | .app (.app (.app (.const ``DerivationTree _) _fc) _context) formula =>

    match formula with
    | .app (.app (.const ``Formula.imp _) lhs) rhs =>

      match rhs with
      | .app (.const ``Formula.box _) diamondPart =>

        -- diamond is a derived operator, check if it matches Formula.diamond pattern
        -- diamond φ = imp (box (imp φ bot)) bot
        let lhsMatches ← isDefEq lhs diamondPart
        if !lhsMatches then
          -- Try alternate: check structure of diamondPart
          let axiomProof ← mkAppM ``Axiom.modal_b #[lhs]
          -- modal_b is a base axiom so h_fc = trivial
          let hfc ← mkAppM ``trivial #[]
          let proof ← mkAppM ``DerivationTree.axiom #[axiomProof, hfc]
          goal.assign proof
        else
          throwError "modal_b_tactic: pattern mismatch in □◇φ structure"

      | _ =>
        throwError "modal_b_tactic: expected □(...) on right side, got {rhs}"

    | _ =>
      throwError "modal_b_tactic: expected implication, got {formula}"

  | _ =>
    throwError "modal_b_tactic: goal must be derivability relation, got {goalType}"

end FormalSystem.Automation
