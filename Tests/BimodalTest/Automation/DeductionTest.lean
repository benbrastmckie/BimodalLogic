/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.Deduction

/-!
# Tests for Deduction Theorem Tactics

Tests for the `deduction`, `deduction n`, and `undischarge` tactics defined in
`FormalSystem/Automation/Tactics/Deduction.lean`, plus the term-level
`deduction_converse` and Prop-level `Derivable.deduction` from
`FormalSystem/Metalogic/Core/DeductionTheorem.lean`.

## Test Coverage

- Basic single/iterated discharge (`deduction`, `deduction 2`)
- Context ordering after iterated discharge (innermost antecedent at head)
- **Negation defeq (load-bearing)**: goals stated as `Γ ⊢ ψ.neg` unify through
  `Formula.neg` with no call-site normalization
- Frame-class polymorphism (non-`Base` frame classes)
- `undischarge` (hypothesis direction)
- `deduction_converse` (computable, plain `example`) and round-trip
- `Derivable.deduction` (Prop-level, dot notation)
- Failure modes via `#guard_msgs`

## Notes

This file is separate from `TacticsTest.lean` (which predates the frame-class
generalization and does not currently compile); examples requiring
`deduction_theorem` are `noncomputable`, following the established precedent.
-/

namespace BimodalTest.Automation.DeductionTest

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Metalogic.Core

/-! ## Basic discharge -/

/-- Test 1: single `deduction` transforms `⊢ p → (q → p)` into `[p] ⊢ q → p`. -/
noncomputable example (p q : Formula) : ⊢ p.imp (q.imp p) := by
  deduction
  -- Goal: [p] ⊢ q.imp p
  deduction
  -- Goal: [q, p] ⊢ p
  exact DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))

/-- Test 2: discharge into a non-empty starting context. -/
noncomputable example (p q : Formula) : [q] ⊢ p.imp p := by
  deduction
  -- Goal: [p, q] ⊢ p
  exact DerivationTree.assumption _ _ (List.Mem.head _)

/-! ## Iterated discharge (`deduction n`) -/

/-- Test 3: `deduction 2` — context ordering is `q :: p :: []`
(innermost antecedent at the head). -/
noncomputable example (p q : Formula) : ⊢ p.imp (q.imp p) := by
  deduction 2
  -- Goal: [q, p] ⊢ p — closing with the SECOND context element proves the ordering
  exact DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))

/-- Test 4: `deduction 3` on a triple implication; innermost antecedent `r` at head. -/
noncomputable example (p q r : Formula) : ⊢ p.imp (q.imp (r.imp r)) := by
  deduction 3
  -- Goal: [r, q, p] ⊢ r
  exact DerivationTree.assumption _ _ (List.Mem.head _)

/-! ## Negation defeq (load-bearing)

`Formula.neg p` is a plain `def` for `p.imp Formula.bot`. `deduction` must
unify through it with no `unfold`/`show` at the call site.
-/

/-- Test 5: goal stated as `⊢ p.neg` — `apply` unifies via defeq. -/
noncomputable example (p : Formula) (h : [p] ⊢ Formula.bot) : ⊢ p.neg := by
  deduction
  -- Goal: [p] ⊢ Formula.bot
  exact h

/-- Test 6: negation goal in a non-empty context. -/
noncomputable example (p q : Formula) (h : [p, q] ⊢ Formula.bot) : [q] ⊢ p.neg := by
  deduction
  exact h

/-! ## Frame-class polymorphism -/

/-- Test 7: `deduction` at the non-Base frame class `Dense`. -/
noncomputable example (p q : Formula) : ⊢[FrameClass.Dense] p.imp (q.imp p) := by
  deduction 2
  exact DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))

/-- Test 8: negation defeq at the non-Base frame class `Discrete`. -/
noncomputable example (p : Formula) (h : [p] ⊢[FrameClass.Discrete] Formula.bot) :
    ⊢[FrameClass.Discrete] p.neg := by
  deduction
  exact h

/-! ## `undischarge` (hypothesis direction) -/

/-- Test 9: `undischarge h` closes `⊢ p → q` from `h : [p] ⊢ q`. -/
noncomputable example (p q : Formula) (h : [p] ⊢ q) : ⊢ p.imp q := by
  undischarge h

/-- Test 10: `undischarge` with a `.neg`-stated goal. -/
noncomputable example (p : Formula) (h : [p] ⊢ Formula.bot) : ⊢ p.neg := by
  undischarge h

/-! ## `deduction_converse` (computable) -/

/-- Test 11: converse direction — plain `example`, NO `noncomputable` marker.
This compiles only because `deduction_converse` is computable. -/
example (p q : Formula) (h : ⊢ p.imp q) : [p] ⊢ q :=
  deduction_converse [] p q h

/-- Test 12: converse at a non-Base frame class, non-empty context. -/
example (p q r : Formula) (h : [r] ⊢[FrameClass.Dense] p.imp q) :
    [p, r] ⊢[FrameClass.Dense] q :=
  deduction_converse [r] p q h

/-- Test 13: round-trip `deduction_converse ∘ deduction_theorem` (noncomputable
because `deduction_theorem` is). -/
noncomputable example (p q : Formula) (h : [p] ⊢ q) : [p] ⊢ q :=
  deduction_converse [] p q (deduction_theorem [] p q h)

/-! ## `Derivable.deduction` (Prop-level) -/

/-- Test 14: Prop-level deduction via dot notation — no `noncomputable` marker
needed because `Derivable` is a `Prop`. -/
example (p q : Formula) (h : Derivable FrameClass.Base [p] q) :
    Derivable FrameClass.Base [] (p.imp q) :=
  h.deduction

/-- Test 15: Prop-level deduction with a `.neg`-stated target at frame class `Dense`. -/
example (p : Formula) (h : Derivable FrameClass.Dense [p] Formula.bot) :
    Derivable FrameClass.Dense [] p.neg :=
  h.deduction

/-! ## Failure modes -/

-- Test 16: `deduction` on a non-derivability goal reports a domain-specific error.
/--
error: deduction: goal must be a derivability goal `Γ ⊢[fc] A → B`, got 1 + 1 = 2
-/
#guard_msgs in
example : 1 + 1 = 2 := by deduction

-- Test 17: `deduction` on a derivability goal whose formula is not an
-- implication (and not defeq to one) reports a unification error.
/--
error: deduction: goal formula is not an implication (expected `Γ ⊢[fc] A → B`, got ⊢ p)
-/
#guard_msgs in
noncomputable example (p : Formula) : ⊢ p := by deduction

end BimodalTest.Automation.DeductionTest
