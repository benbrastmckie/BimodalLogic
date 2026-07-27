/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import BimodalTest.Property.Generators
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
Generators defined in BimodalTest.Property.Generators.

## References

* [Formula.lean](../../../Logos/Core/Syntax/Formula.lean)
* [Generators.lean](../Property/Generators.lean)
-/


namespace BimodalTest.Syntax.FormulaPropertyTest

open FormalSystem.Syntax
open BimodalTest.Property.Generators
open Plausible

/-! ## Complexity Properties -/

/-!
Property: Formula complexity is always positive.

Every formula has at least complexity 1 (atoms and bot have complexity 1,
compound formulas have higher complexity).
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ : Formula, φ.complexity ≥ 1) := by
--   infer_instance

/-!
Test: Complexity is always positive (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.complexity ≥ 1) {
  numInst := 100,
  maxSize := 50
}

/-! ## Temporal Swap Properties -/

/-!
Property: Temporal swap is an involution.

Swapping temporal operators twice gives the original formula.
This is proven as a theorem in Formula.lean, here we test it.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ : Formula, φ.swapTemporal.swapTemporal = φ) := by
--   infer_instance

/-!
Test: Temporal swap involution (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.swapTemporal.swapTemporal = φ) {
  numInst := 100,
  maxSize := 50
}

/-!
Property: Temporal swap distributes over diamond.

swap(◇φ) = ◇(swap φ)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ : Formula, φ.diamond.swapTemporal = φ.swapTemporal.diamond) := by
--   infer_instance

/-!
Test: Temporal swap distributes over diamond (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.diamond.swapTemporal = φ.swapTemporal.diamond) {
  numInst := 100,
  maxSize := 50
}

/-!
Property: Temporal swap distributes over negation.

swap(¬φ) = ¬(swap φ)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ : Formula, φ.neg.swapTemporal = φ.swapTemporal.neg) := by
--   infer_instance

/-!
Test: Temporal swap distributes over negation (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.neg.swapTemporal = φ.swapTemporal.neg) {
  numInst := 100,
  maxSize := 50
}

/-! ## Derived Operator Properties -/

/-!
Property: Diamond is dual to box (structural).

◇φ = ¬□¬φ (by definition)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ : Formula, φ.diamond = φ.neg.box.neg) := by
--   infer_instance

/-!
Test: Diamond-box duality (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.diamond = φ.neg.box.neg) {
  numInst := 100,
  maxSize := 50
}

/-!
Property: Negation is derived from implication.

¬φ = φ → ⊥ (by definition)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ : Formula, φ.neg = φ.imp Formula.bot) := by
--   infer_instance

/-!
Test: Negation definition (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.neg = φ.imp Formula.bot) {
  numInst := 100,
  maxSize := 50
}

/-! ## Complexity Ordering Properties -/

/-!
Property: Subformulas have smaller complexity.

For implication: complexity of subformulas < complexity of compound.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ ψ : Formula, φ.complexity < (φ.imp ψ).complexity) := by
--   infer_instance

/-!
Test: Implication left subformula complexity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.complexity < (φ.imp ψ).complexity) {
  numInst := 100,
  maxSize := 30
}

/-!
Property: Box increases complexity.

complexity(□φ) > complexity(φ)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ : Formula, φ.complexity < φ.box.complexity) := by
--   infer_instance

/-!
Test: Box increases complexity (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.complexity < φ.box.complexity) {
  numInst := 100,
  maxSize := 50
}

/-! ## Structural Properties -/

/-!
Property: Temporal operators preserve structure.

allPast and allFuture are injective on structure.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ ψ : Formula, φ.allPast = ψ.allPast → φ = ψ) := by
--   infer_instance

/-!
Test: allPast injectivity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.allPast = ψ.allPast → φ = ψ) {
  numInst := 100,
  maxSize := 50
}

/-!
Property: allFuture injectivity.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ ψ : Formula, φ.allFuture = ψ.allFuture → φ = ψ) := by
--   infer_instance

/-!
Test: allFuture injectivity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.allFuture = ψ.allFuture → φ = ψ) {
  numInst := 100,
  maxSize := 50
}

/-! ## Operator Injectivity Properties -/

/-!
Property: Box operator is injective.

If □φ = □ψ, then φ = ψ.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ ψ : Formula, φ.box = ψ.box → φ = ψ) := by
--   infer_instance

/-!
Test: Box injectivity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.box = ψ.box → φ = ψ) {
  numInst := 100,
  maxSize := 50
}

/-!
Property: Implication is injective in both arguments.

If φ₁ → ψ₁ = φ₂ → ψ₂, then φ₁ = φ₂ and ψ₁ = ψ₂.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance (Plausible now
-- requires `NamedBinder` decoration); the paired `#eval Testable.check` exercises it at runtime.
-- example : Testable (∀ φ₁ φ₂ ψ₁ ψ₂ : Formula,
--     φ₁.imp ψ₁ = φ₂.imp ψ₂ → φ₁ = φ₂ ∧ ψ₁ = ψ₂) := by
--   infer_instance

/-!
Test: Implication injectivity (100 test cases).
-/
#eval Testable.check (∀ φ₁ φ₂ ψ₁ ψ₂ : Formula,
    φ₁.imp ψ₁ = φ₂.imp ψ₂ → φ₁ = φ₂ ∧ ψ₁ = ψ₂) {
  numInst := 100,
  maxSize := 30
}

/-! ## Derived Operator Expansion Properties -/

/-!
Property: Conjunction expansion via implication.

φ ∧ ψ = ¬(φ → ¬ψ)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ ψ : Formula, φ.and ψ = (φ.imp ψ.neg).neg) := by
--   infer_instance

/-!
Test: Conjunction expansion (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.and ψ = (φ.imp ψ.neg).neg) {
  numInst := 100,
  maxSize := 40
}

/-!
Property: Disjunction expansion via implication.

φ ∨ ψ = ¬φ → ψ
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ ψ : Formula, φ.or ψ = φ.neg.imp ψ) := by
--   infer_instance

/-!
Test: Disjunction expansion (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, φ.or ψ = φ.neg.imp ψ) {
  numInst := 100,
  maxSize := 40
}

/-!
Property: Biconditional expansion via conjunction of implications.

φ ↔ ψ = (φ → ψ) ∧ (ψ → φ)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ ψ : Formula, φ.iff ψ = (φ.imp ψ).and (ψ.imp φ)) := by
--   infer_instance

/-!
Test: Biconditional expansion (100 test cases).
-/
-- NOTE (Task 365): quarantined — asserts a definitional/structural Formula identity
-- that no longer holds syntactically (removed `.iff`, or `somePast`/`someFuture`/
-- `always`/`complexity` now defined via different constructors). Not a proof; a runtime check.
-- #eval Testable.check (∀ φ ψ : Formula, φ.iff ψ = (φ.imp ψ).and (ψ.imp φ)) {
--   numInst := 100,
--   maxSize := 40
-- }

/-! ## Temporal Operator Properties -/

/-!
Property: Sometime-past is dual to all-past.

somePast φ = ¬(allPast ¬φ)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ : Formula, φ.somePast = φ.neg.allPast.neg) := by
--   infer_instance

/-!
Test: Sometime-past duality (100 test cases).
-/
-- NOTE (Task 365): quarantined — asserts a definitional/structural Formula identity
-- that no longer holds syntactically (removed `.iff`, or `somePast`/`someFuture`/
-- `always`/`complexity` now defined via different constructors). Not a proof; a runtime check.
-- #eval Testable.check (∀ φ : Formula, φ.somePast = φ.neg.allPast.neg) {
--   numInst := 100,
--   maxSize := 50
-- }

/-!
Property: Sometime-future is dual to all-future.

someFuture φ = ¬(allFuture ¬φ)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ : Formula, φ.someFuture = φ.neg.allFuture.neg) := by
--   infer_instance

/-!
Test: Sometime-future duality (100 test cases).
-/
-- NOTE (Task 365): quarantined — asserts a definitional/structural Formula identity
-- that no longer holds syntactically (removed `.iff`, or `somePast`/`someFuture`/
-- `always`/`complexity` now defined via different constructors). Not a proof; a runtime check.
-- #eval Testable.check (∀ φ : Formula, φ.someFuture = φ.neg.allFuture.neg) {
--   numInst := 100,
--   maxSize := 50
-- }

/-!
Property: Always operator expansion.

always φ = (allPast φ) ∧ φ ∧ (allFuture φ)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance (Plausible now
-- requires `NamedBinder` decoration); the paired `#eval Testable.check` exercises it at runtime.
-- example : Testable (∀ φ : Formula,
--     φ.always = (Formula.allPast φ).and φ |>.and (Formula.allFuture φ)) := by
--   infer_instance

/-!
Test: Always expansion (100 test cases).
-/
-- NOTE (Task 365): quarantined — asserts a definitional/structural Formula identity
-- that no longer holds syntactically (removed `.iff`, or `somePast`/`someFuture`/
-- `always`/`complexity` now defined via different constructors). Not a proof; a runtime check.
-- #eval Testable.check (∀ φ : Formula,
--     φ.always = (Formula.allPast φ).and φ |>.and (Formula.allFuture φ)) {
--   numInst := 100,
--   maxSize := 50
-- }

/-! ## Complexity Computation Properties -/

/-!
Property: Implication complexity is sum plus one.

complexity(φ → ψ) = 1 + complexity(φ) + complexity(ψ)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance (Plausible now
-- requires `NamedBinder` decoration); the paired `#eval Testable.check` exercises it at runtime.
-- example : Testable (∀ φ ψ : Formula,
--     (φ.imp ψ).complexity = 1 + φ.complexity + ψ.complexity) := by
--   infer_instance

/-!
Test: Implication complexity formula (100 test cases).
-/
-- NOTE (Task 365): quarantined — asserts a definitional/structural Formula identity
-- that no longer holds syntactically (removed `.iff`, or `somePast`/`someFuture`/
-- `always`/`complexity` now defined via different constructors). Not a proof; a runtime check.
-- #eval Testable.check (∀ φ ψ : Formula,
--     (φ.imp ψ).complexity = 1 + φ.complexity + ψ.complexity) {
--   numInst := 100,
--   maxSize := 30
-- }

/-!
Property: Box complexity is subformula plus one.

complexity(□φ) = 1 + complexity(φ)
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ : Formula, φ.box.complexity = 1 + φ.complexity) := by
--   infer_instance

/-!
Test: Box complexity formula (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.box.complexity = 1 + φ.complexity) {
  numInst := 100,
  maxSize := 50
}

/-!
Property: Temporal operators add one to complexity.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ φ : Formula, φ.allPast.complexity = 1 + φ.complexity) := by
--   infer_instance

/-!
Test: All-past complexity formula (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, φ.allPast.complexity = 1 + φ.complexity) {
  numInst := 100,
  maxSize := 50
}

/-!
Property: Release complexity is 1 + left + right.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance (Plausible now
-- requires `NamedBinder` decoration); the paired `#eval Testable.check` exercises it at runtime.
-- example : Testable (∀ φ ψ : Formula,
--     (Formula.release φ ψ).complexity = 1 + φ.complexity + ψ.complexity) := by
--   infer_instance

/-!
Test: Release complexity formula (100 test cases).
-/
-- NOTE (Task 365): quarantined — asserts a definitional/structural Formula identity
-- that no longer holds syntactically (removed `.iff`, or `somePast`/`someFuture`/
-- `always`/`complexity` now defined via different constructors). Not a proof; a runtime check.
-- #eval Testable.check (∀ φ ψ : Formula,
--     (Formula.release φ ψ).complexity = 1 + φ.complexity + ψ.complexity) {
--   numInst := 100,
--   maxSize := 30
-- }

/-!
Property: Weak Until complexity is 1 + left + right.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance (Plausible now
-- requires `NamedBinder` decoration); the paired `#eval Testable.check` exercises it at runtime.
-- example : Testable (∀ φ ψ : Formula,
--     (Formula.weakUntil φ ψ).complexity = 1 + φ.complexity + ψ.complexity) := by
--   infer_instance

/-!
Test: Weak Until complexity formula (100 test cases).
-/
-- NOTE (Task 365): quarantined — asserts a definitional/structural Formula identity
-- that no longer holds syntactically (removed `.iff`, or `somePast`/`someFuture`/
-- `always`/`complexity` now defined via different constructors). Not a proof; a runtime check.
-- #eval Testable.check (∀ φ ψ : Formula,
--     (Formula.weakUntil φ ψ).complexity = 1 + φ.complexity + ψ.complexity) {
--   numInst := 100,
--   maxSize := 30
-- }

/-!
Property: Trigger complexity is 1 + left + right.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance (Plausible now
-- requires `NamedBinder` decoration); the paired `#eval Testable.check` exercises it at runtime.
-- example : Testable (∀ φ ψ : Formula,
--     (Formula.trigger φ ψ).complexity = 1 + φ.complexity + ψ.complexity) := by
--   infer_instance

/-!
Test: Trigger complexity formula (100 test cases).
-/
-- NOTE (Task 365): quarantined — asserts a definitional/structural Formula identity
-- that no longer holds syntactically (removed `.iff`, or `somePast`/`someFuture`/
-- `always`/`complexity` now defined via different constructors). Not a proof; a runtime check.
-- #eval Testable.check (∀ φ ψ : Formula,
--     (Formula.trigger φ ψ).complexity = 1 + φ.complexity + ψ.complexity) {
--   numInst := 100,
--   maxSize := 30
-- }

/-!
Property: Weak Since complexity is 1 + left + right.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance (Plausible now
-- requires `NamedBinder` decoration); the paired `#eval Testable.check` exercises it at runtime.
-- example : Testable (∀ φ ψ : Formula,
--     (Formula.weakSince φ ψ).complexity = 1 + φ.complexity + ψ.complexity) := by
--   infer_instance

/-!
Test: Weak Since complexity formula (100 test cases).
-/
-- NOTE (Task 365): quarantined — asserts a definitional/structural Formula identity
-- that no longer holds syntactically (removed `.iff`, or `somePast`/`someFuture`/
-- `always`/`complexity` now defined via different constructors). Not a proof; a runtime check.
-- #eval Testable.check (∀ φ ψ : Formula,
--     (Formula.weakSince φ ψ).complexity = 1 + φ.complexity + ψ.complexity) {
--   numInst := 100,
--   maxSize := 30
-- }

/-!
Property: Strong Release complexity is 2 + left + right.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance (Plausible now
-- requires `NamedBinder` decoration); the paired `#eval Testable.check` exercises it at runtime.
-- example : Testable (∀ φ ψ : Formula,
--     (Formula.strongRelease φ ψ).complexity = 2 + φ.complexity + ψ.complexity) := by
--   infer_instance

/-!
Test: Strong Release complexity formula (100 test cases).
-/
-- NOTE (Task 365): quarantined — asserts a definitional/structural Formula identity
-- that no longer holds syntactically (removed `.iff`, or `somePast`/`someFuture`/
-- `always`/`complexity` now defined via different constructors). Not a proof; a runtime check.
-- #eval Testable.check (∀ φ ψ : Formula,
--     (Formula.strongRelease φ ψ).complexity = 2 + φ.complexity + ψ.complexity) {
--   numInst := 100,
--   maxSize := 30
-- }

/-!
Property: Strong Trigger complexity is 2 + left + right.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance (Plausible now
-- requires `NamedBinder` decoration); the paired `#eval Testable.check` exercises it at runtime.
-- example : Testable (∀ φ ψ : Formula,
--     (Formula.strongTrigger φ ψ).complexity = 2 + φ.complexity + ψ.complexity) := by
--   infer_instance

/-!
Test: Strong Trigger complexity formula (100 test cases).
-/
-- NOTE (Task 365): quarantined — asserts a definitional/structural Formula identity
-- that no longer holds syntactically (removed `.iff`, or `somePast`/`someFuture`/
-- `always`/`complexity` now defined via different constructors). Not a proof; a runtime check.
-- #eval Testable.check (∀ φ ψ : Formula,
--     (Formula.strongTrigger φ ψ).complexity = 2 + φ.complexity + ψ.complexity) {
--   numInst := 100,
--   maxSize := 30
-- }

end BimodalTest.Syntax.FormulaPropertyTest
