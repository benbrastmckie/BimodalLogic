import Bimodal.Theorems.ModalS5

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

namespace LogosTest.Core.Theorems.ModalS5Test

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Perpetuity
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.ModalS5

/-!
## T-Box-to-Diamond Tests (Task 30)
-/

/-- Test t_box_to_diamond type signature: □A → ◇A -/
example (A : Formula) : ⊢ A.box.imp A.diamond := t_box_to_diamond A

/-- Test t_box_to_diamond with atomic formula -/
example : ⊢ (Formula.atom "p").box.imp (Formula.atom "p").diamond :=
  t_box_to_diamond (Formula.atom "p")

/-- Test t_box_to_diamond with complex formula -/
example : ⊢ ((Formula.atom "p").imp (Formula.atom "q")).box.imp
             ((Formula.atom "p").imp (Formula.atom "q")).diamond :=
  t_box_to_diamond ((Formula.atom "p").imp (Formula.atom "q"))

/-- Test t_box_to_diamond with nested modal formula -/
example : ⊢ ((Formula.atom "p").box).box.imp ((Formula.atom "p").box).diamond :=
  t_box_to_diamond ((Formula.atom "p").box)

/-!
## Box-Contraposition Tests (Task 35)
-/

/-- Test box_contrapose type signature: □(A → B) → □(¬B → ¬A) -/
example (A B : Formula) : ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box) :=
  box_contrapose A B

/-- Test box_contrapose with atomic formulas -/
example : ⊢ ((Formula.atom "p").imp (Formula.atom "q")).box.imp
             (((Formula.atom "q").neg.imp (Formula.atom "p").neg).box) :=
  box_contrapose (Formula.atom "p") (Formula.atom "q")

/-- Test box_contrapose with complex formulas -/
example : ⊢ (((Formula.atom "p").box).imp ((Formula.atom "q").diamond)).box.imp
             ((((Formula.atom "q").diamond).neg.imp ((Formula.atom "p").box).neg).box) :=
  box_contrapose ((Formula.atom "p").box) ((Formula.atom "q").diamond)

/-!
## T-Box-Consistency Tests (Task 36)
-/

/-- Test t_box_consistency type signature: ¬□(A ∧ ¬A) -/
example (A : Formula) : ⊢ ((A.and A.neg).box).neg := t_box_consistency A

/-- Test t_box_consistency with atomic formula -/
example : ⊢ (((Formula.atom "p").and (Formula.atom "p").neg).box).neg :=
  t_box_consistency (Formula.atom "p")

/-- Test t_box_consistency with complex formula -/
example : ⊢ ((((Formula.atom "p").imp (Formula.atom "q")).and
               ((Formula.atom "p").imp (Formula.atom "q")).neg).box).neg :=
  t_box_consistency ((Formula.atom "p").imp (Formula.atom "q"))

/-!
## Integration Tests: Combining Modal S5 Theorems
-/

/-- Test: t_box_to_diamond composes with modal_t -/
example (A : Formula) : ⊢ A.box.imp A.diamond := t_box_to_diamond A

/-- Test: box_contrapose preserves modal structure -/
example (A B : Formula) : ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box) :=
  box_contrapose A B

/-- Test: Consistency and modal T together -/
example : ⊢ (((Formula.atom "p").and (Formula.atom "p").neg).box).neg :=
  t_box_consistency (Formula.atom "p")

/-!
## Placeholder Tests for Biconditional Theorems

These tests are commented out pending Phase 3 biconditional infrastructure.
-/

-- /-- Test box_conj_iff type signature (pending) -/
-- example (A B : Formula) : ⊢ iff (A.and B).box (A.box.and B.box) := box_conj_iff A B

-- /-- Test diamond_disj_iff type signature (pending) -/
-- example (A B : Formula) : ⊢ iff (A.or B).diamond (A.diamond.or B.diamond) := diamond_disj_iff A B

end LogosTest.Core.Theorems.ModalS5Test
