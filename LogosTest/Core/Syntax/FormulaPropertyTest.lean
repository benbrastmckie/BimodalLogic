import Bimodal.Syntax.Formula
import LogosTest.Core.Property.Generators
import Plausible

/-!
# Formula Property Tests

Property-based tests for Formula transformations and invariants.

## Properties Tested

- Complexity is always positive
- Double negation equivalence (structural)
- Temporal swap involution
- Temporal swap distributes over diamond
- Temporal swap distributes over negation

## Implementation Notes

Uses Plausible framework with 100+ test cases per property.
Generators defined in LogosTest.Property.Generators.

## References

* [Formula.lean](../../../Logos/Core/Syntax/Formula.lean)
* [Generators.lean](../Property/Generators.lean)
-/


namespace LogosTest.Syntax.FormulaPropertyTest

open Bimodal.Syntax
open LogosTest.Property.Generators
open Plausible

/-! ## Complexity Properties -/

/--
Property: Formula complexity is always positive.

Every formula has at least complexity 1 (atoms and bot have complexity 1,
compound formulas have higher complexity).
-/
example : Testable (∀ φ : Formula, φ.complexity ≥ 1) := by
  infer_instance

/--
Test: Complexity is always positive (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.complexity ≥ 1) {
  numInst := 100,
  maxSize := 50
}

/-! ## Temporal Swap Properties -/

/--
Property: Temporal swap is an involution.

Swapping temporal operators twice gives the original formula.
This is proven as a theorem in Formula.lean, here we test it.
-/
example : Testable (∀ φ : Formula, φ.swap_temporal.swap_temporal = φ) := by
  infer_instance

/--
Test: Temporal swap involution (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.swap_temporal.swap_temporal = φ) {
  numInst := 100,
  maxSize := 50
}

/--
Property: Temporal swap distributes over diamond.

swap(◇φ) = ◇(swap φ)
-/
example : Testable (∀ φ : Formula, φ.diamond.swap_temporal = φ.swap_temporal.diamond) := by
  infer_instance

/--
Test: Temporal swap distributes over diamond (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.diamond.swap_temporal = φ.swap_temporal.diamond) {
  numInst := 100,
  maxSize := 50
}

/--
Property: Temporal swap distributes over negation.

swap(¬φ) = ¬(swap φ)
-/
example : Testable (∀ φ : Formula, φ.neg.swap_temporal = φ.swap_temporal.neg) := by
  infer_instance

/--
Test: Temporal swap distributes over negation (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.neg.swap_temporal = φ.swap_temporal.neg) {
  numInst := 100,
  maxSize := 50
}

/-! ## Derived Operator Properties -/

/--
Property: Diamond is dual to box (structural).

◇φ = ¬□¬φ (by definition)
-/
example : Testable (∀ φ : Formula, φ.diamond = φ.neg.box.neg) := by
  infer_instance

/--
Test: Diamond-box duality (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.diamond = φ.neg.box.neg) {
  numInst := 100,
  maxSize := 50
}

/--
Property: Negation is derived from implication.

¬φ = φ → ⊥ (by definition)
-/
example : Testable (∀ φ : Formula, φ.neg = φ.imp Formula.bot) := by
  infer_instance

/--
Test: Negation definition (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.neg = φ.imp Formula.bot) {
  numInst := 100,
  maxSize := 50
}

/-! ## Complexity Ordering Properties -/

/--
Property: Subformulas have smaller complexity.

For implication: complexity of subformulas < complexity of compound.
-/
example : Testable (∀ φ ψ : Formula, φ.complexity < (φ.imp ψ).complexity) := by
  infer_instance

/--
Test: Implication left subformula complexity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.complexity < (φ.imp ψ).complexity) {
  numInst := 100,
  maxSize := 30
}

/--
Property: Box increases complexity.

complexity(□φ) > complexity(φ)
-/
example : Testable (∀ φ : Formula, φ.complexity < φ.box.complexity) := by
  infer_instance

/--
Test: Box increases complexity (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.complexity < φ.box.complexity) {
  numInst := 100,
  maxSize := 50
}

/-! ## Structural Properties -/

/--
Property: Temporal operators preserve structure.

all_past and all_future are injective on structure.
-/
example : Testable (∀ φ ψ : Formula, φ.all_past = ψ.all_past → φ = ψ) := by
  infer_instance

/--
Test: all_past injectivity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.all_past = ψ.all_past → φ = ψ) {
  numInst := 100,
  maxSize := 50
}

/--
Property: all_future injectivity.
-/
example : Testable (∀ φ ψ : Formula, φ.all_future = ψ.all_future → φ = ψ) := by
  infer_instance

/--
Test: all_future injectivity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.all_future = ψ.all_future → φ = ψ) {
  numInst := 100,
  maxSize := 50
}

/-! ## Operator Injectivity Properties -/

/--
Property: Box operator is injective.

If □φ = □ψ, then φ = ψ.
-/
example : Testable (∀ φ ψ : Formula, φ.box = ψ.box → φ = ψ) := by
  infer_instance

/--
Test: Box injectivity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.box = ψ.box → φ = ψ) {
  numInst := 100,
  maxSize := 50
}

/--
Property: Implication is injective in both arguments.

If φ₁ → ψ₁ = φ₂ → ψ₂, then φ₁ = φ₂ and ψ₁ = ψ₂.
-/
example : Testable (∀ φ₁ φ₂ ψ₁ ψ₂ : Formula,
    φ₁.imp ψ₁ = φ₂.imp ψ₂ → φ₁ = φ₂ ∧ ψ₁ = ψ₂) := by
  infer_instance

/--
Test: Implication injectivity (100 test cases).
-/
#eval Testable.check (∀ φ₁ φ₂ ψ₁ ψ₂ : Formula,
    φ₁.imp ψ₁ = φ₂.imp ψ₂ → φ₁ = φ₂ ∧ ψ₁ = ψ₂) {
  numInst := 100,
  maxSize := 30
}

/-! ## Derived Operator Expansion Properties -/

/--
Property: Conjunction expansion via implication.

φ ∧ ψ = ¬(φ → ¬ψ)
-/
example : Testable (∀ φ ψ : Formula, φ.and ψ = (φ.imp ψ.neg).neg) := by
  infer_instance

/--
Test: Conjunction expansion (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.and ψ = (φ.imp ψ.neg).neg) {
  numInst := 100,
  maxSize := 40
}

/--
Property: Disjunction expansion via implication.

φ ∨ ψ = ¬φ → ψ
-/
example : Testable (∀ φ ψ : Formula, φ.or ψ = φ.neg.imp ψ) := by
  infer_instance

/--
Test: Disjunction expansion (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.or ψ = φ.neg.imp ψ) {
  numInst := 100,
  maxSize := 40
}

/--
Property: Biconditional expansion via conjunction of implications.

φ ↔ ψ = (φ → ψ) ∧ (ψ → φ)
-/
example : Testable (∀ φ ψ : Formula, φ.iff ψ = (φ.imp ψ).and (ψ.imp φ)) := by
  infer_instance

/--
Test: Biconditional expansion (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.iff ψ = (φ.imp ψ).and (ψ.imp φ)) {
  numInst := 100,
  maxSize := 40
}

/-! ## Temporal Operator Properties -/

/--
Property: Sometime-past is dual to all-past.

sometime_past φ = ¬(all_past ¬φ)
-/
example : Testable (∀ φ : Formula, φ.sometime_past = φ.neg.all_past.neg) := by
  infer_instance

/--
Test: Sometime-past duality (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.sometime_past = φ.neg.all_past.neg) {
  numInst := 100,
  maxSize := 50
}

/--
Property: Sometime-future is dual to all-future.

sometime_future φ = ¬(all_future ¬φ)
-/
example : Testable (∀ φ : Formula, φ.sometime_future = φ.neg.all_future.neg) := by
  infer_instance

/--
Test: Sometime-future duality (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.sometime_future = φ.neg.all_future.neg) {
  numInst := 100,
  maxSize := 50
}

/--
Property: Always operator expansion.

always φ = (all_past φ) ∧ φ ∧ (all_future φ)
-/
example : Testable (∀ φ : Formula,
    φ.always = (Formula.all_past φ).and φ |>.and (Formula.all_future φ)) := by
  infer_instance

/--
Test: Always expansion (100 test cases).
-/
#eval Testable.check (∀ φ : Formula,
    φ.always = (Formula.all_past φ).and φ |>.and (Formula.all_future φ)) {
  numInst := 100,
  maxSize := 50
}

/-! ## Complexity Computation Properties -/

/--
Property: Implication complexity is sum plus one.

complexity(φ → ψ) = 1 + complexity(φ) + complexity(ψ)
-/
example : Testable (∀ φ ψ : Formula,
    (φ.imp ψ).complexity = 1 + φ.complexity + ψ.complexity) := by
  infer_instance

/--
Test: Implication complexity formula (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula,
    (φ.imp ψ).complexity = 1 + φ.complexity + ψ.complexity) {
  numInst := 100,
  maxSize := 30
}

/--
Property: Box complexity is subformula plus one.

complexity(□φ) = 1 + complexity(φ)
-/
example : Testable (∀ φ : Formula, φ.box.complexity = 1 + φ.complexity) := by
  infer_instance

/--
Test: Box complexity formula (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.box.complexity = 1 + φ.complexity) {
  numInst := 100,
  maxSize := 50
}

/--
Property: Temporal operators add one to complexity.
-/
example : Testable (∀ φ : Formula, φ.all_past.complexity = 1 + φ.complexity) := by
  infer_instance

/--
Test: All-past complexity formula (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.all_past.complexity = 1 + φ.complexity) {
  numInst := 100,
  maxSize := 50
}

end LogosTest.Syntax.FormulaPropertyTest
