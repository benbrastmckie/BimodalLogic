/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.Helpers

/-!
# Deduction Theorem Tactics

This module provides tactics that apply the frame-class-polymorphic deduction
theorem (`FormalSystem.Metalogic.Core.deduction_theorem`) to derivability goals.

## Main Tactics

- `deduction`: transform a goal `Γ ⊢[fc] A → B` into `(A :: Γ) ⊢[fc] B`
- `deduction n`: apply `deduction` exactly `n` times (iterated discharge)
- `undischarge h`: close a goal `Γ ⊢[fc] A → B` from `h : (A :: Γ) ⊢[fc] B`

## Design Notes

The core tactic is built on `MVarId.apply` — **never** a syntactic match on the
`Formula.imp` constructor. `apply` unifies at default transparency, which sees
through plain `def`s such as `Formula.neg` (defined as `φ.imp Formula.bot`).
This makes goals stated as `Γ ⊢[fc] ψ.neg` work for free: `deduction`
transforms them into `(ψ :: Γ) ⊢[fc] Formula.bot` without any call-site
normalization (`unfold`/`show`). The 3-app match on the goal head is a guard
used only to produce a good error message on non-derivability goals.

## Noncomputability

`deduction_theorem` is `noncomputable` (it uses classical case analysis in its
well-founded recursion). Consequently, any `def`/`example` whose proof term is
produced by `deduction` or `undischarge` must be marked `noncomputable`. This
matches established codebase practice for `modal_k_tactic` and friends. For
`Prop`-valued derivability statements, use `Derivable.deduction`
(`FormalSystem.Metalogic.Core`) instead — `Prop` proofs never need the marker.

The converse direction (`deduction_converse`) is computable; it is a term-level
lemma, not a tactic, and can be used directly.

## References

* [DeductionTheorem.lean](../../Metalogic/Core/DeductionTheorem.lean) — the theorem applied
* [Helpers.lean](./Helpers.lean) — the `mkOperatorKTactic` template this follows
-/

namespace FormalSystem.Automation

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open Lean Elab Tactic Meta

/--
Core implementation of the `deduction` tactic.

Matches the goal against the 3-app pattern
`DerivationTree fc Γ φ` (guard for error messages only), then applies
`FormalSystem.Metalogic.Core.deduction_theorem` via `MVarId.apply`, which unifies
`φ =?= ?A.imp ?B` at default transparency (so `ψ.neg` goals unify via defeq).
-/
def runDeductionTactic : TacticM Unit := do
  let goal ← getMainGoal
  let goalType ← goal.getType

  match goalType with
  | .app (.app (.app (.const ``DerivationTree _) _fc) _context) _formula =>
    let newGoals ←
      try
        goal.apply (mkConst ``FormalSystem.Metalogic.Core.deduction_theorem)
      catch _ =>
        throwError "deduction: goal formula is not an implication (expected `Γ ⊢[fc] A → B`, got {goalType})"
    replaceMainGoal newGoals
  | _ =>
    throwError "deduction: goal must be a derivability goal `Γ ⊢[fc] A → B`, got {goalType}"

/--
`deduction` applies the deduction theorem to a derivability goal.

Given a goal `Γ ⊢[fc] A → B`, produces the subgoal `(A :: Γ) ⊢[fc] B`
(the antecedent is discharged into the head of the context).

`deduction n` applies the transformation exactly `n` times. Ordering: for
`Γ ⊢[fc] A → B → C`, `deduction 2` yields `(B :: A :: Γ) ⊢[fc] C` — the
innermost antecedent ends up at the context head.

Goals stated with `Formula.neg` work via definitional unfolding: for
`Γ ⊢[fc] ψ.neg` (i.e. `ψ.imp Formula.bot`), `deduction` yields
`(ψ :: Γ) ⊢[fc] Formula.bot`.

**Noncomputability**: `def`s/`example`s closed via this tactic must be marked
`noncomputable` because `deduction_theorem` is noncomputable. Prop-level
statements (`Derivable`) are unaffected; see `Derivable.deduction`.

**Example**:
```lean
noncomputable example (p q : Formula) : ⊢ p.imp (q.imp p) := by
  deduction 2
  -- Goal: [q, p] ⊢ p
  exact DerivationTree.assumption _ _ (by simp)
```
-/
syntax "deduction" (num)? : tactic

elab_rules : tactic
  | `(tactic| deduction $[$n]?) => do
    let count := n.map (·.getNat) |>.getD 1
    for _ in [0:count] do
      runDeductionTactic

/--
`undischarge h` closes a goal `Γ ⊢[fc] A → B` given `h : (A :: Γ) ⊢[fc] B`.

This is the hypothesis-direction counterpart of `deduction`: instead of
transforming the goal, it consumes an already-available derivation in the
extended context. Expands to `exact deduction_theorem _ _ _ h`.

**Noncomputability**: same caveat as `deduction` — enclosing `def`s/`example`s
must be `noncomputable`.

**Example**:
```lean
noncomputable example (p : Formula) (h : [p] ⊢ Formula.bot) : ⊢ p.neg := by
  undischarge h
```
-/
macro "undischarge" h:term : tactic =>
  `(tactic| exact FormalSystem.Metalogic.Core.deduction_theorem _ _ _ $h)

/-! ## Smoke Tests

Minimal in-file sanity checks (the full test section lives in
`Tests/BimodalTest/Automation/DeductionTest.lean`).
-/

-- Basic: single discharge, then close by assumption at the head.
noncomputable example (p q : Formula) : ⊢ p.imp (q.imp p) := by
  deduction
  deduction
  exact DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))

-- Negation goal unifies via defeq (no `unfold`/`show` at the call site).
noncomputable example (p : Formula) (h : [p] ⊢ Formula.bot) : ⊢ p.neg := by
  deduction
  exact h

end FormalSystem.Automation
