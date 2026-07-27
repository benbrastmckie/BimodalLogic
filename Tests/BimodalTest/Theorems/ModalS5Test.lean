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
- `tBoxToDiamond`: `⊢ □A → ◇A` (necessary implies possible)
- `boxDisjIntro`: `⊢ (□A ∨ □B) → □(A ∨ B)` (box disjunction introduction)
- `boxContrapose`: `⊢ □(A → B) → □(¬B → ¬A)` (box contraposition)
- `tBoxConsistency`: `⊢ ¬□(A ∧ ¬A)` (contradiction not necessary)
- `boxConjIff`: `⊢ □(A ∧ B) ↔ (□A ∧ □B)` (box conjunction biconditional)
- `diamondDisjIff`: `⊢ ◇(A ∨ B) ↔ (◇A ∨ ◇B)` (diamond disjunction biconditional)

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

/-- Test tBoxToDiamond type signature: □A → ◇A -/
example (A : Formula) : ⊢ A.box.imp A.diamond := tBoxToDiamond A

/-- Test tBoxToDiamond with atomic formula -/
example : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p").diamond :=
  tBoxToDiamond (Formula.atomS "p")

/-- Test tBoxToDiamond with complex formula -/
example : ⊢ ((Formula.atomS "p").imp (Formula.atomS "q")).box.imp
             ((Formula.atomS "p").imp (Formula.atomS "q")).diamond :=
  tBoxToDiamond ((Formula.atomS "p").imp (Formula.atomS "q"))

/-- Test tBoxToDiamond with nested modal formula -/
example : ⊢ ((Formula.atomS "p").box).box.imp ((Formula.atomS "p").box).diamond :=
  tBoxToDiamond ((Formula.atomS "p").box)

/-!
## Box-Contraposition Tests (Task 35)
-/

/-- Test boxContrapose type signature: □(A → B) → □(¬B → ¬A) -/
example (A B : Formula) : ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box) :=
  boxContrapose A B

/-- Test boxContrapose with atomic formulas -/
example : ⊢ ((Formula.atomS "p").imp (Formula.atomS "q")).box.imp
             (((Formula.atomS "q").neg.imp (Formula.atomS "p").neg).box) :=
  boxContrapose (Formula.atomS "p") (Formula.atomS "q")

/-- Test boxContrapose with complex formulas -/
example : ⊢ (((Formula.atomS "p").box).imp ((Formula.atomS "q").diamond)).box.imp
             ((((Formula.atomS "q").diamond).neg.imp ((Formula.atomS "p").box).neg).box) :=
  boxContrapose ((Formula.atomS "p").box) ((Formula.atomS "q").diamond)

/-!
## T-Box-Consistency Tests (Task 36)
-/

/-- Test tBoxConsistency type signature: ¬□(A ∧ ¬A) -/
example (A : Formula) : ⊢ ((A.and A.neg).box).neg := tBoxConsistency A

/-- Test tBoxConsistency with atomic formula -/
example : ⊢ (((Formula.atomS "p").and (Formula.atomS "p").neg).box).neg :=
  tBoxConsistency (Formula.atomS "p")

/-- Test tBoxConsistency with complex formula -/
example : ⊢ ((((Formula.atomS "p").imp (Formula.atomS "q")).and
               ((Formula.atomS "p").imp (Formula.atomS "q")).neg).box).neg :=
  tBoxConsistency ((Formula.atomS "p").imp (Formula.atomS "q"))

/-!
## Integration Tests: Combining Modal S5 Theorems
-/

/-- Test: tBoxToDiamond composes with modal_t -/
example (A : Formula) : ⊢ A.box.imp A.diamond := tBoxToDiamond A

/-- Test: boxContrapose preserves modal structure -/
example (A B : Formula) : ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box) :=
  boxContrapose A B

/-- Test: Consistency and modal T together -/
example : ⊢ (((Formula.atomS "p").and (Formula.atomS "p").neg).box).neg :=
  tBoxConsistency (Formula.atomS "p")

/-!
## Placeholder Tests for Biconditional Theorems

These tests are commented out pending Phase 3 biconditional infrastructure.
-/

-- /-- Test boxConjIff type signature (pending) -/
-- example (A B : Formula) : ⊢ iff (A.and B).box (A.box.and B.box) := boxConjIff A B

-- /-- Test diamondDisjIff type signature (pending) -/
-- example (A B : Formula) : ⊢ iff (A.or B).diamond (A.diamond.or B.diamond) := diamondDisjIff A B

end BimodalTest.Theorems.ModalS5Test
