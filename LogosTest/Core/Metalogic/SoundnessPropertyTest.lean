/-!
# Soundness Property Tests

Property-based tests for soundness properties.

## Properties Tested

- All axiom instances are valid
- Axiom validity for specific axiom schemas
- Structural soundness properties

## Implementation Notes

Full soundness (derivable → valid) is proven as a theorem in Soundness.lean.
Here we test specific instances with property-based testing to gain
confidence in the implementation.

Note: We cannot easily generate random *derivations* (only formulas),
so we focus on testing axiom validity across many formula instances.

## References

* [Soundness.lean](../../../Logos/Core/Metalogic/Soundness.lean)
* [Axioms.lean](../../../Logos/Core/ProofSystem/Axioms.lean)
-/

import Logos.Core.Metalogic.Soundness
import Logos.Core.ProofSystem.Axioms
import LogosTest.Core.Property.Generators
import Plausible

namespace LogosTest.Metalogic.SoundnessPropertyTest

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Metalogic
open Logos.Core.Semantics
open LogosTest.Property.Generators
open Plausible

/-! ## Axiom Validity Properties -/

/--
Property: Propositional K axiom is valid for all formulas.

⊨ (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
-/
example : Testable (∀ φ ψ χ : Formula, ⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))) := by
  infer_instance

/--
Test: Propositional K validity (100 test cases).
-/
#eval Testable.check (∀ φ ψ χ : Formula, ⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))) {
  numInst := 100,
  maxSize := 30
}

/--
Property: Propositional S axiom is valid for all formulas.

⊨ φ → (ψ → φ)
-/
example : Testable (∀ φ ψ : Formula, ⊨ (φ.imp (ψ.imp φ))) := by
  infer_instance

/--
Test: Propositional S validity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, ⊨ (φ.imp (ψ.imp φ))) {
  numInst := 100,
  maxSize := 30
}

/--
Property: Modal T axiom is valid for all formulas.

⊨ □φ → φ
-/
example : Testable (∀ φ : Formula, ⊨ (φ.box.imp φ)) := by
  infer_instance

/--
Test: Modal T validity (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, ⊨ (φ.box.imp φ)) {
  numInst := 100,
  maxSize := 40
}

/--
Property: Modal 4 axiom is valid for all formulas.

⊨ □φ → □□φ
-/
example : Testable (∀ φ : Formula, ⊨ (φ.box.imp φ.box.box)) := by
  infer_instance

/--
Test: Modal 4 validity (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, ⊨ (φ.box.imp φ.box.box)) {
  numInst := 100,
  maxSize := 40
}

/--
Property: Modal B axiom is valid for all formulas.

⊨ φ → □◇φ
-/
example : Testable (∀ φ : Formula, ⊨ (φ.imp φ.diamond.box)) := by
  infer_instance

/--
Test: Modal B validity (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, ⊨ (φ.imp φ.diamond.box)) {
  numInst := 100,
  maxSize := 40
}

/--
Property: Modal K distribution is valid for all formulas.

⊨ □(φ → ψ) → (□φ → □ψ)
-/
example : Testable (∀ φ ψ : Formula, ⊨ ((φ.imp ψ).box.imp (φ.box.imp ψ.box))) := by
  infer_instance

/--
Test: Modal K distribution validity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, ⊨ ((φ.imp ψ).box.imp (φ.box.imp ψ.box))) {
  numInst := 100,
  maxSize := 30
}

/--
Property: Temporal 4 axiom is valid for all formulas.

⊨ Gφ → GGφ
-/
example : Testable (∀ φ : Formula, ⊨ (φ.all_future.imp φ.all_future.all_future)) := by
  infer_instance

/--
Test: Temporal 4 validity (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, ⊨ (φ.all_future.imp φ.all_future.all_future)) {
  numInst := 100,
  maxSize := 40
}

/--
Property: Temporal K distribution is valid for all formulas.

⊨ G(φ → ψ) → (Gφ → Gψ)
-/
example : Testable (∀ φ ψ : Formula, ⊨ ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future))) := by
  infer_instance

/--
Test: Temporal K distribution validity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, ⊨ ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future))) {
  numInst := 100,
  maxSize := 30
}

/--
Property: Ex falso quodlibet is valid.

⊨ ⊥ → φ
-/
example : Testable (∀ φ : Formula, ⊨ (Formula.bot.imp φ)) := by
  infer_instance

/--
Test: Ex falso validity (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, ⊨ (Formula.bot.imp φ)) {
  numInst := 100,
  maxSize := 40
}

/--
Property: Peirce's law is valid.

⊨ ((φ → ψ) → φ) → φ
-/
example : Testable (∀ φ ψ : Formula, ⊨ (((φ.imp ψ).imp φ).imp φ)) := by
  infer_instance

/--
Test: Peirce's law validity (100 test cases).
-/
#eval Testable.check (∀ φ ψ : Formula, ⊨ (((φ.imp ψ).imp φ).imp φ)) {
  numInst := 100,
  maxSize := 30
}

/--
Property: Modal 5 Collapse axiom is valid for all formulas.

⊨ ◇□φ → □φ
-/
example : Testable (∀ φ : Formula, ⊨ (φ.box.diamond.imp φ.box)) := by
  infer_instance

/--
Test: Modal 5 Collapse validity (500 test cases - critical S5 property).
-/
#eval Testable.check (∀ φ : Formula, ⊨ (φ.box.diamond.imp φ.box)) {
  numInst := 500,
  maxSize := 40
}

/--
Property: Temporal A axiom is valid for all formulas.

⊨ φ → F(sometime_past φ)
-/
example : Testable (∀ φ : Formula, ⊨ (φ.imp (Formula.all_future φ.sometime_past))) := by
  infer_instance

/--
Test: Temporal A validity (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, ⊨ (φ.imp (Formula.all_future φ.sometime_past))) {
  numInst := 100,
  maxSize := 40
}

/--
Property: Temporal L axiom is valid for all formulas.

⊨ △φ → F(Pφ)
-/
example : Testable (∀ φ : Formula, ⊨ (φ.always.imp (Formula.all_future (Formula.all_past φ)))) := by
  infer_instance

/--
Test: Temporal L validity (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, ⊨ (φ.always.imp (Formula.all_future (Formula.all_past φ)))) {
  numInst := 100,
  maxSize := 40
}

/--
Property: Modal-Future axiom is valid for all formulas.

⊨ □φ → □Fφ
-/
example : Testable (∀ φ : Formula, ⊨ ((Formula.box φ).imp (Formula.box (Formula.all_future φ)))) := by
  infer_instance

/--
Test: Modal-Future validity (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, ⊨ ((Formula.box φ).imp (Formula.box (Formula.all_future φ)))) {
  numInst := 100,
  maxSize := 40
}

/--
Property: Temporal-Future axiom is valid for all formulas.

⊨ □φ → F□φ
-/
example : Testable (∀ φ : Formula, ⊨ ((Formula.box φ).imp (Formula.all_future (Formula.box φ)))) := by
  infer_instance

/--
Test: Temporal-Future validity (100 test cases).
-/
#eval Testable.check (∀ φ : Formula, ⊨ ((Formula.box φ).imp (Formula.all_future (Formula.box φ)))) {
  numInst := 100,
  maxSize := 40
}

/-! ## Axiom Instance Validity -/

/--
Property: All axiom instances are valid.

For any formula φ that matches an axiom schema, φ is valid.
-/
def axiom_instance_valid (φ : Formula) (h : Axiom φ) : ⊨ φ :=
  axiom_valid h

/--
Test: Modal T instances are valid.
-/
example (φ : Formula) : ⊨ (φ.box.imp φ) :=
  axiom_valid (Axiom.modal_t φ)

/--
Test: Modal 4 instances are valid.
-/
example (φ : Formula) : ⊨ (φ.box.imp φ.box.box) :=
  axiom_valid (Axiom.modal_4 φ)

/--
Test: Temporal 4 instances are valid.
-/
example (φ : Formula) : ⊨ (φ.all_future.imp φ.all_future.all_future) :=
  axiom_valid (Axiom.temp_4 φ)

/-! ## Structural Soundness Properties -/

/--
Property: Validity is preserved under uniform substitution.

This is a meta-property: if ⊨ φ, then ⊨ φ[ψ/p] for any substitution.
We test specific instances.
-/
-- Note: We don't have substitution implemented yet, so this is a placeholder

/-! ## Semantic Consequence Properties -/

/--
Property: Empty context semantically entails all valid formulas.

If ⊨ φ, then [] ⊨ φ.
-/
def valid_implies_consequence (φ : Formula) (h : ⊨ φ) : [] ⊨ φ := by
  intro T _ F M τ t ht _
  exact h T F M τ t ht

end LogosTest.Metalogic.SoundnessPropertyTest
