/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem
import FormalSystem.Semantics
import FormalSystem.Metalogic

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

namespace BimodalTest.Integration

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics
open FormalSystem.Metalogic

-- ============================================================
-- Axiom Validity Tests (15 axioms)
-- ============================================================

section AxiomValidityTests

/--
Test 1: Propositional K axiom is valid.

Verifies that the distribution axiom `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
is valid via soundness.
-/
example (φ ψ χ : Formula) : [] ⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.prop_k φ ψ χ) trivial
  exact soundness [] _ deriv

/--
Test 2: Propositional S axiom is valid.

Verifies that the weakening axiom `φ → (ψ → φ)` is valid via soundness.
-/
example (φ ψ : Formula) : [] ⊨ (φ.imp (ψ.imp φ)) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.prop_s φ ψ) trivial
  exact soundness [] _ deriv

/--
Test 3: Modal T axiom is valid.

Verifies that `□φ → φ` is valid via soundness.
-/
example (φ : Formula) : [] ⊨ (φ.box.imp φ) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_t φ) trivial
  exact soundness [] _ deriv

/--
Test 4: Modal 4 axiom is valid.

Verifies that `□φ → □□φ` is valid via soundness.
-/
example (φ : Formula) : [] ⊨ ((φ.box).imp (φ.box.box)) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_4 φ) trivial
  exact soundness [] _ deriv

/--
Test 5: Modal B axiom is valid.

Verifies that `φ → □◇φ` is valid via soundness.
-/
example (φ : Formula) : [] ⊨ (φ.imp (φ.diamond.box)) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_b φ) trivial
  exact soundness [] _ deriv

/--
Test 6: Modal 5 Collapse axiom is valid.

Verifies that `◇□φ → □φ` is valid via soundness.
-/
example (φ : Formula) : [] ⊨ (φ.box.diamond.imp φ.box) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_5_collapse φ) trivial
  exact soundness [] _ deriv

/--
Test 7: Ex Falso Quodlibet axiom is valid.

Verifies that `⊥ → φ` is valid via soundness.
-/
example (φ : Formula) : [] ⊨ (Formula.bot.imp φ) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.ex_falso φ) trivial
  exact soundness [] _ deriv

/--
Test 8: Peirce's Law is valid.

Verifies that `((φ → ψ) → φ) → φ` is valid via soundness.
-/
example (φ ψ : Formula) : [] ⊨ (((φ.imp ψ).imp φ).imp φ) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.peirce φ ψ) trivial
  exact soundness [] _ deriv

/--
Test 9: Modal K Distribution axiom is valid.

Verifies that `□(φ → ψ) → (□φ → □ψ)` is valid via soundness.
-/
example (φ ψ : Formula) : [] ⊨ ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_k_dist φ ψ) trivial
  exact soundness [] _ deriv

/--
Test 10: Temporal K Distribution axiom is valid.

Verifies that `F(φ → ψ) → (Fφ → Fψ)` is valid via soundness.
-/
example (φ ψ : Formula) : [] ⊨ ((φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture)) := by
  let deriv := FormalSystem.Theorems.TemporalDerived.temporalKDistDerived φ ψ
  exact soundness [] _ deriv

/--
Test 11: Temporal 4 axiom is valid.

Verifies that `Fφ → FFφ` is valid via soundness.
-/
example (φ : Formula) : [] ⊨ ((φ.allFuture).imp (φ.allFuture.allFuture)) := by
  let deriv := FormalSystem.Theorems.TemporalDerived.temporal4Derived φ
  exact soundness [] _ deriv

/--
Test 12: Temporal A axiom is valid.

Verifies that `φ → F(some_past φ)` is valid via soundness.
-/
example (φ : Formula) : [] ⊨ (φ.imp (Formula.allFuture φ.somePast)) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.connect_future φ) trivial
  exact soundness [] _ deriv

-- /--
-- Test 13: Temporal L axiom is valid.

-- NOTE (Task 365): quarantined — `Axiom.temp_l` was removed (no axiom/derived replacement;
-- requires a multi-step derivation). Semantic `temp_l_valid` is retained elsewhere. See task summary.
-- Verifies that `△φ → F(Pφ)` is valid via soundness.
-- -/
-- example (φ : Formula) : [] ⊨ (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
--   let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.temp_l φ)
--   exact soundness [] _ deriv

/--
Test 14: Modal-Future axiom is valid.

Verifies that `□φ → □Fφ` is valid via soundness.
-/
example (φ : Formula) : [] ⊨ ((Formula.box φ).imp (Formula.box (Formula.allFuture φ))) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_future φ) trivial
  exact soundness [] _ deriv

/--
Test 15: Temporal-Future (derived) is valid.

Verifies that `□φ → G□φ` is valid via soundness (TF derived from MF + T + Modal 4).
-/
example (φ : Formula) : [] ⊨ ((Formula.box φ).imp (Formula.allFuture (Formula.box φ))) := by
  let deriv : ⊢ ((Formula.box φ).imp (Formula.allFuture (Formula.box φ))) :=
    FormalSystem.Theorems.Combinators.temporalFutureDerived φ
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
example (p : String) : [(Formula.atomS p).box] ⊨ (Formula.atomS p) := by
  let deriv : [(Formula.atomS p).box] ⊢ (Formula.atomS p) :=
    DerivationTree.modus_ponens [(Formula.atomS p).box] ((Formula.atomS p).box) (Formula.atomS p)
      (DerivationTree.axiom [(Formula.atomS p).box] _ (Axiom.modal_t (Formula.atomS p)) trivial)
      (DerivationTree.assumption [(Formula.atomS p).box] ((Formula.atomS p).box) (List.Mem.head _))
  exact soundness [(Formula.atomS p).box] (Formula.atomS p) deriv

/--
Test 19: Modal necessitation is sound.

From ⊢ φ, we get ⊨ □φ.
-/
example (φ : Formula) : [] ⊨ ((φ.box.imp φ).box) := by
  let deriv : [] ⊢ (φ.box.imp φ) := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_t φ) trivial
  let deriv_box : [] ⊢ (φ.box.imp φ).box := DerivationTree.necessitation _ deriv
  exact soundness [] _ deriv_box

/--
Test 20: Temporal necessitation is sound.

From ⊢ φ, we get ⊨ Fφ.
-/
example (φ : Formula) : [] ⊨ ((φ.box.imp φ).allFuture) := by
  let deriv : [] ⊢ (φ.box.imp φ) := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_t φ) trivial
  let deriv_future : [] ⊢ (φ.box.imp φ).allFuture := DerivationTree.temporal_necessitation _ deriv
  exact soundness [] _ deriv_future

/--
Test 21: Temporal duality is sound.

From ⊢ φ, we get ⊨ swap_temporal φ.
-/
example : [] ⊨ ((Formula.allFuture (Formula.atomS "p")).imp 
              (Formula.allFuture (Formula.allFuture (Formula.atomS "p")))).swapTemporal := by
  let deriv : [] ⊢ ((Formula.allFuture (Formula.atomS "p")).imp 
                    (Formula.allFuture (Formula.allFuture (Formula.atomS "p")))) :=
    FormalSystem.Theorems.TemporalDerived.temporal4Derived (Formula.atomS "p")
  let deriv_swap : [] ⊢ ((Formula.allFuture (Formula.atomS "p")).imp 
                         (Formula.allFuture (Formula.allFuture (Formula.atomS "p")))).swapTemporal :=
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
  let proof : ⊢ ((Formula.atomS "p").box.imp (Formula.atomS "p")) :=
    DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_t (Formula.atomS "p")) trivial
  
  -- Step 2: Apply soundness
  let valid_from_soundness : [] ⊨ ((Formula.atomS "p").box.imp (Formula.atomS "p")) :=
    soundness [] _ proof
  
  -- Step 3: Direct semantic validity
  let valid_direct : [] ⊨ ((Formula.atomS "p").box.imp (Formula.atomS "p")) :=
    (Validity.valid_iff_empty_consequence _).mp (modal_t_valid (Formula.atomS "p"))
  
  -- Both paths give the same result
  trivial

/--
Test 24: Complete workflow - Modal 4.

Demonstrates: Derivation → Soundness → Validity for transitivity axiom.
-/
example : True := by
  let proof : ⊢ ((Formula.atomS "q").box.imp (Formula.atomS "q").box.box) :=
    DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_4 (Formula.atomS "q")) trivial
  
  let valid_from_soundness : [] ⊨ ((Formula.atomS "q").box.imp (Formula.atomS "q").box.box) :=
    soundness [] _ proof
  
  let valid_direct : [] ⊨ ((Formula.atomS "q").box.imp (Formula.atomS "q").box.box) :=
    (Validity.valid_iff_empty_consequence _).mp (modal_4_valid (Formula.atomS "q"))
  
  trivial

/--
Test 25: Complete workflow - Temporal 4.

Demonstrates: Derivation → Soundness → Validity for temporal transitivity.
-/
example : True := by
  let proof : ⊢ ((Formula.atomS "r").allFuture.imp (Formula.atomS "r").allFuture.allFuture) :=
    FormalSystem.Theorems.TemporalDerived.temporal4Derived (Formula.atomS "r")
  
  let valid_from_soundness : [] ⊨ ((Formula.atomS "r").allFuture.imp 
                                    (Formula.atomS "r").allFuture.allFuture) :=
    soundness [] _ proof
  
  let valid_direct : [] ⊨ ((Formula.atomS "r").allFuture.imp 
                        (Formula.atomS "r").allFuture.allFuture) :=
    (Validity.valid_iff_empty_consequence _).mp (temp_4_valid (Formula.atomS "r"))
  
  trivial

/--
Test 26: Workflow with modus ponens.

Demonstrates: Complex derivation → Soundness → Validity.
-/
example : True := by
  -- Derive: from [□p, □p → p], derive p
  let ax : [Formula.box (Formula.atomS "p")] ⊢ 
           (Formula.box (Formula.atomS "p")).imp (Formula.atomS "p") :=
    DerivationTree.axiom [Formula.box (Formula.atomS "p")] _
                        (Axiom.modal_t (Formula.atomS "p")) trivial
  
  let ass : [Formula.box (Formula.atomS "p")] ⊢ Formula.box (Formula.atomS "p") :=
    DerivationTree.assumption [Formula.box (Formula.atomS "p")] 
                             (Formula.box (Formula.atomS "p")) 
                             (List.Mem.head _)
  
  let proof : [Formula.box (Formula.atomS "p")] ⊢ Formula.atomS "p" :=
    DerivationTree.modus_ponens [Formula.box (Formula.atomS "p")] 
                                (Formula.box (Formula.atomS "p")) 
                                (Formula.atomS "p") 
                                ax ass
  
  -- Apply soundness
  let valid : [Formula.box (Formula.atomS "p")] ⊨ Formula.atomS "p" :=
    soundness [Formula.box (Formula.atomS "p")] (Formula.atomS "p") proof
  
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
    DerivationTree.axiom [p.box.box] _ (Axiom.modal_t p.box) trivial
  
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
example (p : Formula) : [p.allFuture.allFuture] ⊨ (p.allFuture.imp p.allFuture.allFuture) := by
  -- Demonstrate that axioms are sound even in non-empty contexts
  let ax : [p.allFuture.allFuture] ⊢ (p.allFuture.imp p.allFuture.allFuture) :=
    DerivationTree.weakening [] [p.allFuture.allFuture] _
      (FormalSystem.Theorems.TemporalDerived.temporal4Derived p) (List.nil_subset _)
  
  -- Apply soundness to show the axiom is valid
  exact soundness [p.allFuture.allFuture] _ ax

/--
Test 30: Mixed modal-temporal operators are sound.

Verify soundness of □Fp derivations.
-/
example (p : Formula) : [p.allFuture.box] ⊨ p.allFuture.box := by
  let deriv : [p.allFuture.box] ⊢ p.allFuture.box :=
    DerivationTree.assumption [p.allFuture.box] p.allFuture.box (List.Mem.head _)
  exact soundness [p.allFuture.box] p.allFuture.box deriv

end ComplexDerivationTests

-- ============================================================
-- Context Semantic Consequence Tests
-- ============================================================

section ContextSemanticConsequenceTests

/--
Test 31: Empty context semantic consequence.

If ⊢ φ, then [] ⊨ φ (theorems are valid).
-/
example : [] ⊨ ((Formula.atomS "p").box.imp (Formula.atomS "p")) := by
  let deriv : ⊢ ((Formula.atomS "p").box.imp (Formula.atomS "p")) :=
    DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_t (Formula.atomS "p")) trivial
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
example : [] ⊨ (((Formula.atomS "p").imp (Formula.atomS "q")).box.imp 
             ((Formula.atomS "p").box.imp (Formula.atomS "q").box)) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _
    (Axiom.modal_k_dist (Formula.atomS "p") (Formula.atomS "q")) trivial
  exact soundness [] _ deriv

/--
Test 37: Temporal K distribution soundness with concrete formulas.

Verify F(p → q) → (Fp → Fq) is sound.
-/
example : [] ⊨ (((Formula.atomS "p").imp (Formula.atomS "q")).allFuture.imp 
             ((Formula.atomS "p").allFuture.imp (Formula.atomS "q").allFuture)) := by
  let deriv := FormalSystem.Theorems.TemporalDerived.temporalKDistDerived
    (Formula.atomS "p") (Formula.atomS "q")
  exact soundness [] _ deriv

/--
Test 38: Modal B soundness with concrete formula.

Verify p → □◇p is sound.
-/
example : [] ⊨ ((Formula.atomS "p").imp ((Formula.atomS "p").diamond.box)) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_b (Formula.atomS "p")) trivial
  exact soundness [] _ deriv

/--
Test 39: Temporal A soundness with concrete formula.

Verify p → F(some_past p) is sound.
-/
example : [] ⊨ ((Formula.atomS "p").imp 
             (Formula.allFuture (Formula.atomS "p").somePast)) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.connect_future (Formula.atomS "p")) trivial
  exact soundness [] _ deriv

/--
Test 40: Modal-Future soundness with concrete formula.

Verify □p → □Fp is sound.
-/
example : [] ⊨ ((Formula.box (Formula.atomS "p")).imp 
             (Formula.box (Formula.allFuture (Formula.atomS "p")))) := by
  let deriv := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_future (Formula.atomS "p")) trivial
  exact soundness [] _ deriv

end AxiomSpecificSoundnessTests

end BimodalTest.Integration
