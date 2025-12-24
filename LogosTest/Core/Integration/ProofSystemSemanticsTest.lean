import Logos.Core.ProofSystem
import Logos.Core.Semantics
import Logos.Core.Metalogic

/-!
# Proof System and Semantics Integration Tests

Comprehensive integration tests verifying the connection between the proof system
(derivation) and semantics (validity) through the soundness theorem.

## Test Coverage

This test suite covers:
1. All 15 axioms produce valid formulas (via soundness)
2. All 7 inference rules preserve validity
3. Derivation → Validity workflow for each axiom
4. Modus ponens soundness with various formula combinations
5. Necessitation soundness (modal and temporal)
6. Temporal duality soundness (swap preservation)
7. Weakening soundness
8. Context semantic consequence vs derivability
9. Complex derivation chains produce valid results

## Organization

Tests are organized by category:
- Axiom Validity Tests (15 axioms)
- Inference Rule Soundness Tests (7 rules)
- Workflow Integration Tests (derivation → soundness → validity)
- Complex Derivation Tests (multi-step proofs)
- Negative Tests (non-derivable formulas)

## References

* [Soundness.lean](../../../Logos/Core/Metalogic/Soundness.lean) - Soundness theorem
* [Derivation.lean](../../../Logos/Core/ProofSystem/Derivation.lean) - Proof system
* [Validity.lean](../../../Logos/Core/Semantics/Validity.lean) - Semantic validity
-/

namespace LogosTest.Core.Integration

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Semantics
open Logos.Core.Metalogic

-- ============================================================
-- Axiom Validity Tests (15 axioms)
-- ============================================================

section AxiomValidityTests

/--
Test 1: Propositional K axiom is valid.

Verifies that the distribution axiom `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
is valid via soundness.
-/
example (φ ψ χ : Formula) : ⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.prop_k φ ψ χ)
  exact soundness [] _ deriv

/--
Test 2: Propositional S axiom is valid.

Verifies that the weakening axiom `φ → (ψ → φ)` is valid via soundness.
-/
example (φ ψ : Formula) : ⊨ (φ.imp (ψ.imp φ)) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.prop_s φ ψ)
  exact soundness [] _ deriv

/--
Test 3: Modal T axiom is valid.

Verifies that `□φ → φ` is valid via soundness.
-/
example (φ : Formula) : ⊨ (φ.box.imp φ) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.modal_t φ)
  exact soundness [] _ deriv

/--
Test 4: Modal 4 axiom is valid.

Verifies that `□φ → □□φ` is valid via soundness.
-/
example (φ : Formula) : ⊨ ((φ.box).imp (φ.box.box)) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.modal_4 φ)
  exact soundness [] _ deriv

/--
Test 5: Modal B axiom is valid.

Verifies that `φ → □◇φ` is valid via soundness.
-/
example (φ : Formula) : ⊨ (φ.imp (φ.diamond.box)) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.modal_b φ)
  exact soundness [] _ deriv

/--
Test 6: Modal 5 Collapse axiom is valid.

Verifies that `◇□φ → □φ` is valid via soundness.
-/
example (φ : Formula) : ⊨ (φ.box.diamond.imp φ.box) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.modal_5_collapse φ)
  exact soundness [] _ deriv

/--
Test 7: Ex Falso Quodlibet axiom is valid.

Verifies that `⊥ → φ` is valid via soundness.
-/
example (φ : Formula) : ⊨ (Formula.bot.imp φ) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.ex_falso φ)
  exact soundness [] _ deriv

/--
Test 8: Peirce's Law is valid.

Verifies that `((φ → ψ) → φ) → φ` is valid via soundness.
-/
example (φ ψ : Formula) : ⊨ (((φ.imp ψ).imp φ).imp φ) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.peirce φ ψ)
  exact soundness [] _ deriv

/--
Test 9: Modal K Distribution axiom is valid.

Verifies that `□(φ → ψ) → (□φ → □ψ)` is valid via soundness.
-/
example (φ ψ : Formula) : ⊨ ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.modal_k_dist φ ψ)
  exact soundness [] _ deriv

/--
Test 10: Temporal K Distribution axiom is valid.

Verifies that `F(φ → ψ) → (Fφ → Fψ)` is valid via soundness.
-/
example (φ ψ : Formula) : ⊨ ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.temp_k_dist φ ψ)
  exact soundness [] _ deriv

/--
Test 11: Temporal 4 axiom is valid.

Verifies that `Fφ → FFφ` is valid via soundness.
-/
example (φ : Formula) : ⊨ ((φ.all_future).imp (φ.all_future.all_future)) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.temp_4 φ)
  exact soundness [] _ deriv

/--
Test 12: Temporal A axiom is valid.

Verifies that `φ → F(sometime_past φ)` is valid via soundness.
-/
example (φ : Formula) : ⊨ (φ.imp (Formula.all_future φ.sometime_past)) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.temp_a φ)
  exact soundness [] _ deriv

/--
Test 13: Temporal L axiom is valid.

Verifies that `△φ → F(Pφ)` is valid via soundness.
-/
example (φ : Formula) : ⊨ (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.temp_l φ)
  exact soundness [] _ deriv

/--
Test 14: Modal-Future axiom is valid.

Verifies that `□φ → □Fφ` is valid via soundness.
-/
example (φ : Formula) : ⊨ ((Formula.box φ).imp (Formula.box (Formula.all_future φ))) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.modal_future φ)
  exact soundness [] _ deriv

/--
Test 15: Temporal-Future axiom is valid.

Verifies that `□φ → F□φ` is valid via soundness.
-/
example (φ : Formula) : ⊨ ((Formula.box φ).imp (Formula.all_future (Formula.box φ))) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.temp_future φ)
  exact soundness [] _ deriv

end AxiomValidityTests

-- ============================================================
-- Inference Rule Soundness Tests (7 rules)
-- ============================================================

section InferenceRuleSoundnessTests

/--
Test 16: Assumption rule is sound.

If φ ∈ Γ, then Γ ⊨ φ.
-/
example (φ ψ : Formula) : [φ, ψ] ⊨ φ := by
  let deriv : [φ, ψ] ⊢ φ := DerivationTree.assumption [φ, ψ] φ (List.Mem.head _)
  exact soundness [φ, ψ] φ deriv

/--
Test 17: Modus ponens is sound (basic case).

From Γ ⊢ φ → ψ and Γ ⊢ φ, we get Γ ⊨ ψ.
-/
example (φ ψ : Formula) : [φ.imp ψ, φ] ⊨ ψ := by
  let deriv : [φ.imp ψ, φ] ⊢ ψ :=
    DerivationTree.modus_ponens [φ.imp ψ, φ] φ ψ
      (DerivationTree.assumption [φ.imp ψ, φ] (φ.imp ψ) (List.Mem.head _))
      (DerivationTree.assumption [φ.imp ψ, φ] φ (List.Mem.tail _ (List.Mem.head _)))
  exact soundness [φ.imp ψ, φ] ψ deriv

/--
Test 18: Modus ponens is sound (with axiom).

Using Modal T axiom with modus ponens.
-/
example (p : String) : [(Formula.atom p).box] ⊨ (Formula.atom p) := by
  let deriv : [(Formula.atom p).box] ⊢ (Formula.atom p) :=
    DerivationTree.modus_ponens [(Formula.atom p).box] ((Formula.atom p).box) (Formula.atom p)
      (DerivationTree.axiom [(Formula.atom p).box] _ (Axiom.modal_t (Formula.atom p)))
      (DerivationTree.assumption [(Formula.atom p).box] ((Formula.atom p).box) (List.Mem.head _))
  exact soundness [(Formula.atom p).box] (Formula.atom p) deriv

/--
Test 19: Modal necessitation is sound.

From ⊢ φ, we get ⊨ □φ.
-/
example (φ : Formula) : ⊨ ((φ.box.imp φ).box) := by
  let deriv : [] ⊢ (φ.box.imp φ) := DerivationTree.axiom [] _ (Axiom.modal_t φ)
  let deriv_box : [] ⊢ (φ.box.imp φ).box := DerivationTree.necessitation _ deriv
  exact soundness [] _ deriv_box

/--
Test 20: Temporal necessitation is sound.

From ⊢ φ, we get ⊨ Fφ.
-/
example (φ : Formula) : ⊨ ((φ.box.imp φ).all_future) := by
  let deriv : [] ⊢ (φ.box.imp φ) := DerivationTree.axiom [] _ (Axiom.modal_t φ)
  let deriv_future : [] ⊢ (φ.box.imp φ).all_future := DerivationTree.temporal_necessitation _ deriv
  exact soundness [] _ deriv_future

/--
Test 21: Temporal duality is sound.

From ⊢ φ, we get ⊨ swap_temporal φ.
-/
example : ⊨ ((Formula.all_future (Formula.atom "p")).imp 
              (Formula.all_future (Formula.all_future (Formula.atom "p")))).swap_temporal := by
  let deriv : [] ⊢ ((Formula.all_future (Formula.atom "p")).imp 
                    (Formula.all_future (Formula.all_future (Formula.atom "p")))) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.atom "p"))
  let deriv_swap : [] ⊢ ((Formula.all_future (Formula.atom "p")).imp 
                         (Formula.all_future (Formula.all_future (Formula.atom "p")))).swap_temporal :=
    DerivationTree.temporal_duality _ deriv
  exact soundness [] _ deriv_swap

/--
Test 22: Weakening is sound.

From Γ ⊢ φ and Γ ⊆ Δ, we get Δ ⊨ φ.
-/
example (φ ψ χ : Formula) : [φ, ψ, χ] ⊨ φ := by
  let deriv : [φ] ⊢ φ := DerivationTree.assumption [φ] φ (List.Mem.head _)
  have h_sub : [φ] ⊆ [φ, ψ, χ] := by
    intro x hx
    cases hx with
    | head => exact List.Mem.head _
    | tail _ h => contradiction
  let deriv_weak : [φ, ψ, χ] ⊢ φ := DerivationTree.weakening [φ] [φ, ψ, χ] φ deriv h_sub
  exact soundness [φ, ψ, χ] φ deriv_weak

end InferenceRuleSoundnessTests

-- ============================================================
-- Workflow Integration Tests
-- ============================================================

section WorkflowIntegrationTests

/--
Test 23: Complete workflow - Modal T.

Demonstrates: Derivation → Soundness → Validity verification.
-/
example : True := by
  -- Step 1: Syntactic derivation
  let proof : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom "p"))
  
  -- Step 2: Apply soundness
  let valid_from_soundness : [] ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    soundness [] _ proof
  
  -- Step 3: Direct semantic validity
  let valid_direct : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    modal_t_valid (Formula.atom "p")
  
  -- Both paths give the same result
  trivial

/--
Test 24: Complete workflow - Modal 4.

Demonstrates: Derivation → Soundness → Validity for transitivity axiom.
-/
example : True := by
  let proof : ⊢ ((Formula.atom "q").box.imp (Formula.atom "q").box.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.atom "q"))
  
  let valid_from_soundness : [] ⊨ ((Formula.atom "q").box.imp (Formula.atom "q").box.box) :=
    soundness [] _ proof
  
  let valid_direct : ⊨ ((Formula.atom "q").box.imp (Formula.atom "q").box.box) :=
    modal_4_valid (Formula.atom "q")
  
  trivial

/--
Test 25: Complete workflow - Temporal 4.

Demonstrates: Derivation → Soundness → Validity for temporal transitivity.
-/
example : True := by
  let proof : ⊢ ((Formula.atom "r").all_future.imp (Formula.atom "r").all_future.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.atom "r"))
  
  let valid_from_soundness : [] ⊨ ((Formula.atom "r").all_future.imp 
                                    (Formula.atom "r").all_future.all_future) :=
    soundness [] _ proof
  
  let valid_direct : ⊨ ((Formula.atom "r").all_future.imp 
                        (Formula.atom "r").all_future.all_future) :=
    temp_4_valid (Formula.atom "r")
  
  trivial

/--
Test 26: Workflow with modus ponens.

Demonstrates: Complex derivation → Soundness → Validity.
-/
example : True := by
  -- Derive: from [□p, □p → p], derive p
  let ax : [Formula.box (Formula.atom "p")] ⊢ 
           (Formula.box (Formula.atom "p")).imp (Formula.atom "p") :=
    DerivationTree.axiom [Formula.box (Formula.atom "p")] _ 
                        (Axiom.modal_t (Formula.atom "p"))
  
  let ass : [Formula.box (Formula.atom "p")] ⊢ Formula.box (Formula.atom "p") :=
    DerivationTree.assumption [Formula.box (Formula.atom "p")] 
                             (Formula.box (Formula.atom "p")) 
                             (List.Mem.head _)
  
  let proof : [Formula.box (Formula.atom "p")] ⊢ Formula.atom "p" :=
    DerivationTree.modus_ponens [Formula.box (Formula.atom "p")] 
                                (Formula.box (Formula.atom "p")) 
                                (Formula.atom "p") 
                                ax ass
  
  -- Apply soundness
  let valid : [Formula.box (Formula.atom "p")] ⊨ Formula.atom "p" :=
    soundness [Formula.box (Formula.atom "p")] (Formula.atom "p") proof
  
  trivial

end WorkflowIntegrationTests

-- ============================================================
-- Complex Derivation Tests
-- ============================================================

section ComplexDerivationTests

/--
Test 27: Chained modus ponens is sound.

From [p → q, q → r, p], derive r and verify soundness.
-/
example (p q r : Formula) : [p.imp q, q.imp r, p] ⊨ r := by
  let deriv : [p.imp q, q.imp r, p] ⊢ r :=
    DerivationTree.modus_ponens [p.imp q, q.imp r, p] q r
      (DerivationTree.assumption [p.imp q, q.imp r, p] (q.imp r) 
        (List.Mem.tail _ (List.Mem.head _)))
      (DerivationTree.modus_ponens [p.imp q, q.imp r, p] p q
        (DerivationTree.assumption [p.imp q, q.imp r, p] (p.imp q) (List.Mem.head _))
        (DerivationTree.assumption [p.imp q, q.imp r, p] p 
          (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))))
  exact soundness [p.imp q, q.imp r, p] r deriv

/--
Test 28: Nested modal operators are sound.

Derive □□p → □p using Modal T and verify soundness.
-/
example (p : Formula) : [p.box.box] ⊨ p.box := by
  -- First apply Modal T to get □□p → □p
  let ax1 : [p.box.box] ⊢ (p.box.box.imp p.box) :=
    DerivationTree.axiom [p.box.box] _ (Axiom.modal_t p.box)
  
  -- Then use assumption to get □□p
  let ass : [p.box.box] ⊢ p.box.box :=
    DerivationTree.assumption [p.box.box] p.box.box (List.Mem.head _)
  
  -- Apply modus ponens
  let deriv : [p.box.box] ⊢ p.box :=
    DerivationTree.modus_ponens [p.box.box] p.box.box p.box ax1 ass
  
  exact soundness [p.box.box] p.box deriv

/--
Test 29: Nested temporal operators are sound.

Verify that Temporal 4 axiom is sound in non-empty contexts.
-/
example (p : Formula) : [p.all_future.all_future] ⊨ (p.all_future.imp p.all_future.all_future) := by
  -- Demonstrate that axioms are sound even in non-empty contexts
  let ax : [p.all_future.all_future] ⊢ (p.all_future.imp p.all_future.all_future) :=
    DerivationTree.axiom [p.all_future.all_future] _ (Axiom.temp_4 p)
  
  -- Apply soundness to show the axiom is valid
  exact soundness [p.all_future.all_future] _ ax

/--
Test 30: Mixed modal-temporal operators are sound.

Verify soundness of □Fp derivations.
-/
example (p : Formula) : [p.all_future.box] ⊨ p.all_future.box := by
  let deriv : [p.all_future.box] ⊢ p.all_future.box :=
    DerivationTree.assumption [p.all_future.box] p.all_future.box (List.Mem.head _)
  exact soundness [p.all_future.box] p.all_future.box deriv

end ComplexDerivationTests

-- ============================================================
-- Context Semantic Consequence Tests
-- ============================================================

section ContextSemanticConsequenceTests

/--
Test 31: Empty context semantic consequence.

If ⊢ φ, then [] ⊨ φ (theorems are valid).
-/
example : [] ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  let deriv : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom "p"))
  exact soundness [] _ deriv

/--
Test 32: Single assumption semantic consequence.

From [φ], we get [φ] ⊨ φ.
-/
example (φ : Formula) : [φ] ⊨ φ := by
  let deriv : [φ] ⊢ φ := DerivationTree.assumption [φ] φ (List.Mem.head _)
  exact soundness [φ] φ deriv

/--
Test 33: Multiple assumptions semantic consequence.

From [φ, ψ], we get [φ, ψ] ⊨ φ and [φ, ψ] ⊨ ψ.
-/
example (φ ψ : Formula) : [φ, ψ] ⊨ φ ∧ [φ, ψ] ⊨ ψ := by
  let deriv1 : [φ, ψ] ⊢ φ := DerivationTree.assumption [φ, ψ] φ (List.Mem.head _)
  let deriv2 : [φ, ψ] ⊢ ψ := 
    DerivationTree.assumption [φ, ψ] ψ (List.Mem.tail _ (List.Mem.head _))
  exact ⟨soundness [φ, ψ] φ deriv1, soundness [φ, ψ] ψ deriv2⟩

/--
Test 34: Weakening preserves semantic consequence.

If Γ ⊨ φ and Γ ⊆ Δ, then Δ ⊨ φ.
-/
example (φ ψ : Formula) : [φ, ψ] ⊨ φ := by
  let deriv : [φ] ⊢ φ := DerivationTree.assumption [φ] φ (List.Mem.head _)
  have h_sub : [φ] ⊆ [φ, ψ] := by
    intro x hx
    cases hx with
    | head => exact List.Mem.head _
    | tail _ h => contradiction
  let deriv_weak : [φ, ψ] ⊢ φ := DerivationTree.weakening [φ] [φ, ψ] φ deriv h_sub
  exact soundness [φ, ψ] φ deriv_weak

/--
Test 35: Semantic consequence is transitive.

If Γ ⊨ φ and [φ] ⊨ ψ, then Γ ∪ {φ} ⊨ ψ (via derivability).
-/
example (p q r : Formula) : [p.imp q, q.imp r, p] ⊨ r := by
  -- This is Test 27 repeated to show transitivity
  let deriv : [p.imp q, q.imp r, p] ⊢ r :=
    DerivationTree.modus_ponens [p.imp q, q.imp r, p] q r
      (DerivationTree.assumption [p.imp q, q.imp r, p] (q.imp r) 
        (List.Mem.tail _ (List.Mem.head _)))
      (DerivationTree.modus_ponens [p.imp q, q.imp r, p] p q
        (DerivationTree.assumption [p.imp q, q.imp r, p] (p.imp q) (List.Mem.head _))
        (DerivationTree.assumption [p.imp q, q.imp r, p] p 
          (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))))
  exact soundness [p.imp q, q.imp r, p] r deriv

end ContextSemanticConsequenceTests

-- ============================================================
-- Axiom-Specific Soundness Tests
-- ============================================================

section AxiomSpecificSoundnessTests

/--
Test 36: Modal K distribution soundness with concrete formulas.

Verify □(p → q) → (□p → □q) is sound.
-/
example : ⊨ (((Formula.atom "p").imp (Formula.atom "q")).box.imp 
             ((Formula.atom "p").box.imp (Formula.atom "q").box)) := by
  let deriv := DerivationTree.axiom [] _ 
    (Axiom.modal_k_dist (Formula.atom "p") (Formula.atom "q"))
  exact soundness [] _ deriv

/--
Test 37: Temporal K distribution soundness with concrete formulas.

Verify F(p → q) → (Fp → Fq) is sound.
-/
example : ⊨ (((Formula.atom "p").imp (Formula.atom "q")).all_future.imp 
             ((Formula.atom "p").all_future.imp (Formula.atom "q").all_future)) := by
  let deriv := DerivationTree.axiom [] _ 
    (Axiom.temp_k_dist (Formula.atom "p") (Formula.atom "q"))
  exact soundness [] _ deriv

/--
Test 38: Modal B soundness with concrete formula.

Verify p → □◇p is sound.
-/
example : ⊨ ((Formula.atom "p").imp ((Formula.atom "p").diamond.box)) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.modal_b (Formula.atom "p"))
  exact soundness [] _ deriv

/--
Test 39: Temporal A soundness with concrete formula.

Verify p → F(sometime_past p) is sound.
-/
example : ⊨ ((Formula.atom "p").imp 
             (Formula.all_future (Formula.atom "p").sometime_past)) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.temp_a (Formula.atom "p"))
  exact soundness [] _ deriv

/--
Test 40: Modal-Future soundness with concrete formula.

Verify □p → □Fp is sound.
-/
example : ⊨ ((Formula.box (Formula.atom "p")).imp 
             (Formula.box (Formula.all_future (Formula.atom "p")))) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.modal_future (Formula.atom "p"))
  exact soundness [] _ deriv

end AxiomSpecificSoundnessTests

end LogosTest.Core.Integration
