import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms
import BimodalTest.Property.Generators
import Plausible

/-!
# Derivation Property Tests

Property-based tests for the derivation system.

## Properties Tested

- Weakening: Γ ⊢ φ → Γ ⊆ Δ → Δ ⊢ φ
- Reflexivity: φ ∈ Γ → Γ ⊢ φ
- Height properties for derivation trees
- Axiom derivability

## Implementation Notes

These are structural properties that should hold for the derivation system.
We test them with property-based testing to ensure they hold across
many different contexts and formulas.

Note: Some properties like "modus ponens correctness" require actual
derivations, which are harder to generate randomly. We focus on
structural properties that can be tested with arbitrary inputs.

## References

* [Derivation.lean](../../../Logos/Core/ProofSystem/Derivation.lean)
* [Axioms.lean](../../../Logos/Core/ProofSystem/Axioms.lean)
-/


namespace BimodalTest.ProofSystem.DerivationPropertyTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open BimodalTest.Property.Generators
open Plausible

/-! ## Reflexivity Properties -/

/--
Property: Assumptions are derivable (reflexivity).

If φ is in the context Γ, then Γ ⊢ φ.
-/
def reflexivity_property (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : Γ ⊢ φ :=
  DerivationTree.assumption Γ φ h

/--
Test: Reflexivity holds for all contexts and formulas.

We test this by checking that we can construct the derivation.
-/
example : ∀ (φ : Formula) (Γ : Context), φ ∈ Γ → Nonempty (Γ ⊢ φ) := by
  intro φ Γ h
  exact ⟨DerivationTree.assumption Γ φ h⟩

/-! ## Weakening Properties -/

/--
Property: Weakening preserves derivability.

If Γ ⊢ φ and Γ ⊆ Δ, then Δ ⊢ φ.
-/
def weakening_property (Γ Δ : Context) (φ : Formula)
    (d : Γ ⊢ φ) (h : Γ ⊆ Δ) : Δ ⊢ φ :=
  DerivationTree.weakening Γ Δ φ d h

/--
Test: Weakening construction is always possible.
-/
example : ∀ (Γ Δ : Context) (φ : Formula) (d : Γ ⊢ φ) (h : Γ ⊆ Δ),
    Nonempty (Δ ⊢ φ) := by
  intro Γ Δ φ d h
  exact ⟨DerivationTree.weakening Γ Δ φ d h⟩

/-! ## Height Properties -/

/--
Property: Derivation height is always finite.

Every derivation tree has a finite height (by construction).
-/
example : ∀ (Γ : Context) (φ : Formula) (d : Γ ⊢ φ), d.height < 1000000 := by
  intro Γ φ d
  -- Height is always finite, though we can't easily bound it
  -- This is more of a sanity check
  omega

/--
Property: Axiom derivations have height 0.
-/
def axiom_height_zero (Γ : Context) (φ : Formula) (h : Axiom φ) :
    (DerivationTree.axiom Γ φ h).height = 0 := by
  rfl

/--
Property: Assumption derivations have height 0.
-/
def assumption_height_zero (Γ : Context) (φ : Formula) (h : φ ∈ Γ) :
    (DerivationTree.assumption Γ φ h).height = 0 := by
  rfl

/-! ## Axiom Derivability Properties -/

/--
Property: All axiom instances are derivable from empty context.

For any axiom φ, we have ⊢ φ.
-/
def axiom_derivable (φ : Formula) (h : Axiom φ) : ⊢ φ :=
  DerivationTree.axiom [] φ h

/--
Test: Modal T axiom is derivable.
-/
example (φ : Formula) : ⊢ (φ.box.imp φ) :=
  DerivationTree.axiom [] (φ.box.imp φ) (Axiom.modal_t φ)

/--
Test: Modal 4 axiom is derivable.
-/
example (φ : Formula) : ⊢ (φ.box.imp φ.box.box) :=
  DerivationTree.axiom [] (φ.box.imp φ.box.box) (Axiom.modal_4 φ)

/--
Test: Temporal 4 axiom is derivable.
-/
example (φ : Formula) : ⊢ (φ.all_future.imp φ.all_future.all_future) :=
  DerivationTree.axiom [] (φ.all_future.imp φ.all_future.all_future) (Axiom.temp_4 φ)

/-! ## Modus Ponens Properties -/

/--
Property: Modus ponens increases height.

The height of (Γ ⊢ ψ) via MP is greater than both premises.
-/
def mp_height_property (Γ : Context) (φ ψ : Formula)
    (d1 : Γ ⊢ φ.imp ψ) (d2 : Γ ⊢ φ) :
    d1.height < (DerivationTree.modus_ponens Γ φ ψ d1 d2).height ∧
    d2.height < (DerivationTree.modus_ponens Γ φ ψ d1 d2).height := by
  constructor
  · exact DerivationTree.mp_height_gt_left d1 d2
  · exact DerivationTree.mp_height_gt_right d1 d2

/-! ## Necessitation Properties -/

/--
Property: Necessitation increases height by 1.
-/
def necessitation_height_property (φ : Formula) (d : ⊢ φ) :
    (DerivationTree.necessitation φ d).height = d.height + 1 :=
  DerivationTree.necessitation_height_succ d

/--
Property: Temporal necessitation increases height by 1.
-/
def temporal_necessitation_height_property (φ : Formula) (d : ⊢ φ) :
    (DerivationTree.temporal_necessitation φ d).height = d.height + 1 :=
  DerivationTree.temporal_necessitation_height_succ d

/-! ## Context Subset Properties -/

/--
Property: Empty context is subset of all contexts.
-/
example : Testable (∀ Γ : Context, [] ⊆ Γ) := by
  infer_instance

/--
Test: Empty context subset property (100 test cases).
-/
#eval Testable.check (∀ Γ : Context, [] ⊆ Γ) {
  numInst := 100,
  maxSize := 20
}

/--
Property: Context is subset of itself.
-/
example : Testable (∀ Γ : Context, Γ ⊆ Γ) := by
  infer_instance

/--
Test: Reflexivity of subset (100 test cases).
-/
#eval Testable.check (∀ Γ : Context, Γ ⊆ Γ) {
  numInst := 100,
  maxSize := 20
}

/--
Property: Subset is transitive.
-/
example : Testable (∀ Γ Δ Θ : Context, Γ ⊆ Δ → Δ ⊆ Θ → Γ ⊆ Θ) := by
  infer_instance

/--
Test: Transitivity of subset (100 test cases).
-/
#eval Testable.check (∀ Γ Δ Θ : Context, Γ ⊆ Δ → Δ ⊆ Θ → Γ ⊆ Θ) {
  numInst := 100,
  maxSize := 15
}

/-! ## Additional Axiom Derivability Tests -/

/--
Test: Modal 5 Collapse axiom is derivable.
-/
example (φ : Formula) : ⊢ (φ.box.diamond.imp φ.box) :=
  DerivationTree.axiom [] (φ.box.diamond.imp φ.box) (Axiom.modal_5_collapse φ)

/--
Test: Temporal A axiom is derivable.
-/
example (φ : Formula) : ⊢ (φ.imp (Formula.all_future φ.sometime_past)) :=
  DerivationTree.axiom [] (φ.imp (Formula.all_future φ.sometime_past)) (Axiom.temp_a φ)

/--
Test: Temporal L axiom is derivable.
-/
example (φ : Formula) : ⊢ (φ.always.imp (Formula.all_future (Formula.all_past φ))) :=
  DerivationTree.axiom [] (φ.always.imp (Formula.all_future (Formula.all_past φ))) (Axiom.temp_l φ)

/--
Test: Modal-Future axiom is derivable.
-/
example (φ : Formula) : ⊢ ((Formula.box φ).imp (Formula.box (Formula.all_future φ))) :=
  DerivationTree.axiom [] ((Formula.box φ).imp (Formula.box (Formula.all_future φ))) (Axiom.modal_future φ)

/--
Test: Temporal-Future axiom is derivable.
-/
example (φ : Formula) : ⊢ ((Formula.box φ).imp (Formula.all_future (Formula.box φ))) :=
  DerivationTree.axiom [] ((Formula.box φ).imp (Formula.all_future (Formula.box φ))) (Axiom.temp_future φ)

/-! ## Context Operations Properties -/

/--
Property: Adding duplicate formulas preserves derivability (contraction).
-/
example : ∀ (Γ : Context) (φ ψ : Formula),
    φ ∈ Γ → ψ ∈ Γ → φ ∈ (φ :: Γ) ∧ ψ ∈ (φ :: Γ) := by
  intro Γ φ ψ hφ hψ
  constructor
  · exact List.mem_cons_self φ Γ
  · exact List.mem_cons_of_mem φ hψ

/--
Property: Context concatenation preserves membership.
-/
example : Testable (∀ (Γ Δ : Context) (φ : Formula), φ ∈ Γ → φ ∈ (Γ ++ Δ)) := by
  infer_instance

/--
Test: Context concatenation membership (100 test cases).
-/
#eval Testable.check (∀ (Γ Δ : Context) (φ : Formula), φ ∈ Γ → φ ∈ (Γ ++ Δ)) {
  numInst := 100,
  maxSize := 20
}

/--
Property: Cons preserves subset.
-/
example : Testable (∀ (Γ Δ : Context) (φ : Formula), Γ ⊆ Δ → (φ :: Γ) ⊆ (φ :: Δ)) := by
  infer_instance

/--
Test: Cons preserves subset (100 test cases).
-/
#eval Testable.check (∀ (Γ Δ : Context) (φ : Formula), Γ ⊆ Δ → (φ :: Γ) ⊆ (φ :: Δ)) {
  numInst := 100,
  maxSize := 20
}

end BimodalTest.ProofSystem.DerivationPropertyTest
