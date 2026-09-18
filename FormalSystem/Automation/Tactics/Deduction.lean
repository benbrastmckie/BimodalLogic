/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem
import FormalSystem.Metalogic.Core.DeductionTheorem
import Lean

/-!
# Deduction Theorem Tactics

This module provides tactics that apply the frame-class-polymorphic deduction
theorem (`FormalSystem.Metalogic.Core.deductionTheorem`) to derivability goals.

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

`deductionTheorem` is `noncomputable` (it uses classical case analysis in its
well-founded recursion). Consequently, any `def`/`example` whose proof term is
produced by `deduction` or `undischarge` must be marked `noncomputable`. This
matches the established codebase practice for tactic elaborators. For
`Prop`-valued derivability statements, use `Derivable.deduction`
(`FormalSystem.Metalogic.Core`) instead — `Prop` proofs never need the marker.

The converse direction (`deductionConverse`) is computable; it is a term-level
lemma, not a tactic, and can be used directly.

## Adoption verdict: DECLINED for `Metalogic/Core/DeductionTheorem.lean`

These two tactics have **zero** invocations in the library and 16 in the test suite
(`Tests/BimodalTest/Automation/DeductionTest.lean`: 14 `deduction`, 2 `undischarge`). A
time-boxed trial asked whether they should be adopted in
`Metalogic/Core/DeductionTheorem.lean`, the obvious candidate, since that file is where
`Γ ⊢[fc] A.imp B` goals are densest. The answer is no, and the reason is stronger than the
`noncomputable` cost recorded above.

**The blocker is circularity, not noncomputability.** Every `Γ ⊢[fc] A.imp B` goal in that
file belongs to one of the four case lemmas — `deductionAxiom`, `deductionAssumptionSame`,
`deductionAssumptionOther`, `deductionMp` — and all four sit *above* `deductionTheorem` in the
file, because they are the cases `deductionTheorem`'s own well-founded recursion dispatches to.
`deduction` is a wrapper around `deductionTheorem`. Using it in any of them would ask the
theorem to prove its own cases. The only two declarations below `deductionTheorem` are
`deductionConverse`, which runs the other direction and is already a three-line term, and
`Derivable.deduction`, which is `Prop`-valued and has no goal of this shape.

So there is no site in that file where the tactic form could apply, at any cost. The
`noncomputable` infection is real and is documented above, but it never gets to be the
deciding factor here.

**What to use instead, so this is not re-litigated.** `Derivable.deduction` (11 uses) is the
route for `Prop`-valued derivability, and carries no `noncomputable` marker. The
`deductionTheorem` term form (186 uses) is the route when the derivation tree itself is wanted.
Between them they cover every case in the tree. These tactics are kept as a convenience for
interactive `Type`-valued work and as the subject of their own test file; they are not
library infrastructure, and a future census finding them unused in the library should read
this note rather than repeat the trial.

## References

* [DeductionTheorem.lean](../../Metalogic/Core/DeductionTheorem.lean) — the theorem applied
* [UserTactics.lean](./UserTactics.lean) — the tactic-elaborator infrastructure this follows
-/

namespace FormalSystem.Automation

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open Lean Elab Tactic Meta

/--
Core implementation of the `deduction` tactic.

Matches the goal against the 3-app pattern
`DerivationTree fc Γ φ` (guard for error messages only), then applies
`FormalSystem.Metalogic.Core.deductionTheorem` via `MVarId.apply`, which unifies
`φ =?= ?A.imp ?B` at default transparency (so `ψ.neg` goals unify via defeq).
-/
def runDeductionTactic : TacticM Unit := do
  let goal ← getMainGoal
  let goalType ← goal.getType
  match goalType with
  | .app (.app (.app (.const ``DerivationTree _) _fc) _context) _formula =>
    let newGoals ←
      try
        goal.apply (mkConst ``FormalSystem.Metalogic.Core.deductionTheorem)
      catch _ =>
        throwError
            "deduction: goal formula is not an implication (expected `Γ ⊢[fc] A → B`, got \
                {goalType})"
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
`noncomputable` because `deductionTheorem` is noncomputable. Prop-level
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
extended context. Expands to `exact deductionTheorem _ _ _ h`.

**Noncomputability**: same caveat as `deduction` — enclosing `def`s/`example`s
must be `noncomputable`.

**Example**:
```lean
noncomputable example (p : Formula) (h : [p] ⊢ Formula.bot) : ⊢ p.neg := by
  undischarge h
```
-/
macro "undischarge" h:term : tactic =>
  `(tactic| exact FormalSystem.Metalogic.Core.deductionTheorem _ _ _ $h)

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
