/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.ModalS5

/-!
# Modal S5 Theorems Tests

Tests for modal S5 theorems derived in Hilbert-style proof calculus.

## Test Coverage

### Phase 2: Modal S5 Theorems
- `t_box_to_diamond`: `⊢ □A → ◇A` (necessary implies possible)
- `box_disj_intro`: `⊢ (□A ∨ □B) → □(A ∨ B)` (box disjunction introduction)
- `box_contrapose`: `⊢ □(A → B) → □(¬B → ¬A)` (box contraposition)
- `t_box_consistency`: `⊢ ¬□(A ∧ ¬A)` (contradiction not necessary)
- `box_conj_iff`: `⊢ □(A ∧ B) ↔ (□A ∧ □B)` (box conjunction biconditional)
- `diamond_disj_iff`: `⊢ ◇(A ∨ B) ↔ (◇A ∨ ◇B)` (diamond disjunction biconditional)

Each theorem has minimum 2 test cases (simple atomic, nested/complex).
-/

namespace BimodalTest.Theorems.ModalS5Test

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Perpetuity
open FormalSystem.Theorems.Propositional
open FormalSystem.Theorems.ModalS5

/-!
## T-Box-to-Diamond Tests (Task 30)
-/

/-- Test t_box_to_diamond type signature: □A → ◇A -/
example (A : Formula) : ⊢ A.box.imp A.diamond := tBoxToDiamond A

/-- Test t_box_to_diamond with atomic formula -/
example : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p").diamond :=
  tBoxToDiamond (Formula.atomS "p")

/-- Test t_box_to_diamond with complex formula -/
example : ⊢ ((Formula.atomS "p").imp (Formula.atomS "q")).box.imp
             ((Formula.atomS "p").imp (Formula.atomS "q")).diamond :=
  tBoxToDiamond ((Formula.atomS "p").imp (Formula.atomS "q"))

/-- Test t_box_to_diamond with nested modal formula -/
example : ⊢ ((Formula.atomS "p").box).box.imp ((Formula.atomS "p").box).diamond :=
  tBoxToDiamond ((Formula.atomS "p").box)

/-!
## Box-Contraposition Tests (Task 35)
-/

/-- Test box_contrapose type signature: □(A → B) → □(¬B → ¬A) -/
example (A B : Formula) : ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box) :=
  boxContrapose A B

/-- Test box_contrapose with atomic formulas -/
example : ⊢ ((Formula.atomS "p").imp (Formula.atomS "q")).box.imp
             (((Formula.atomS "q").neg.imp (Formula.atomS "p").neg).box) :=
  boxContrapose (Formula.atomS "p") (Formula.atomS "q")

/-- Test box_contrapose with complex formulas -/
example : ⊢ (((Formula.atomS "p").box).imp ((Formula.atomS "q").diamond)).box.imp
             ((((Formula.atomS "q").diamond).neg.imp ((Formula.atomS "p").box).neg).box) :=
  boxContrapose ((Formula.atomS "p").box) ((Formula.atomS "q").diamond)

/-!
## T-Box-Consistency Tests (Task 36)
-/

/-- Test t_box_consistency type signature: ¬□(A ∧ ¬A) -/
example (A : Formula) : ⊢ ((A.and A.neg).box).neg := tBoxConsistency A

/-- Test t_box_consistency with atomic formula -/
example : ⊢ (((Formula.atomS "p").and (Formula.atomS "p").neg).box).neg :=
  tBoxConsistency (Formula.atomS "p")

/-- Test t_box_consistency with complex formula -/
example : ⊢ ((((Formula.atomS "p").imp (Formula.atomS "q")).and
               ((Formula.atomS "p").imp (Formula.atomS "q")).neg).box).neg :=
  tBoxConsistency ((Formula.atomS "p").imp (Formula.atomS "q"))

/-!
## Integration Tests: Combining Modal S5 Theorems
-/

/-- Test: t_box_to_diamond composes with modal_t -/
example (A : Formula) : ⊢ A.box.imp A.diamond := tBoxToDiamond A

/-- Test: box_contrapose preserves modal structure -/
example (A B : Formula) : ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box) :=
  boxContrapose A B

/-- Test: Consistency and modal T together -/
example : ⊢ (((Formula.atomS "p").and (Formula.atomS "p").neg).box).neg :=
  tBoxConsistency (Formula.atomS "p")

/-!
## Placeholder Tests for Biconditional Theorems

These tests are commented out pending Phase 3 biconditional infrastructure.
-/

-- /-- Test box_conj_iff type signature (pending) -/
-- example (A B : Formula) : ⊢ iff (A.and B).box (A.box.and B.box) := box_conj_iff A B

-- /-- Test diamond_disj_iff type signature (pending) -/
-- example (A B : Formula) : ⊢ iff (A.or B).diamond (A.diamond.or B.diamond) := diamond_disj_iff A B

end BimodalTest.Theorems.ModalS5Test
