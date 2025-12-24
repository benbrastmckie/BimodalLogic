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

import Logos.Core.Syntax.Formula
import LogosTest.Core.Property.Generators
import Plausible

namespace LogosTest.Syntax.FormulaPropertyTest

open Logos.Core.Syntax
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

end LogosTest.Syntax.FormulaPropertyTest
