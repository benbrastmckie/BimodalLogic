import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic
import LogosTest.Core.Integration.Helpers

/-!
# Bimodal Integration Tests

Tests for modal-temporal interaction and MF/TF axiom integration.

## Test Coverage

This test suite covers:
1. Modal-Future axiom integration (□p → □Fp)
2. Temporal-Future axiom integration (□p → F□p)
3. Modal-temporal operator combinations
4. Time-shift preservation properties
5. Bimodal derivation workflows
6. Cross-operator soundness verification

## Organization

Tests are organized by bimodal axiom:
- Modal-Future (MF) axiom tests
- Temporal-Future (TF) axiom tests
- Combined bimodal workflows
- Time-shift invariance tests

## References

* [Axioms.lean](../../../Logos/Core/ProofSystem/Axioms.lean) - Bimodal axioms
* [Soundness.lean](../../../Logos/Core/Metalogic/Soundness.lean) - Soundness theorem
* [Truth.lean](../../../Logos/Core/Semantics/Truth.lean) - Bimodal semantics
-/

namespace LogosTest.Core.Integration

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic
open LogosTest.Core.Integration.Helpers

-- ============================================================
-- Modal-Future Axiom Integration
-- ============================================================

section ModalFutureIntegration

/--
Test 1: Modal-Future axiom derivation and soundness.

Verifies □p → □Fp is derivable and sound.
-/
example : True := by
  let p := Formula.atom "p"
  let φ := p.box.imp (p.all_future.box)
  
  -- Derive using Modal-Future axiom
  let d : ⊢ φ := DerivationTree.axiom [] φ (Axiom.modal_future p)
  
  -- Verify soundness
  have v : [] ⊨ φ := soundness [] φ d
  
  -- Verify semantic validity directly
  have v_direct : [] ⊨ φ := modal_future_valid p
  
  trivial

/--
Test 2: Modal-Future with modus ponens.

From [□p], derive □Fp.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box]
  
  -- □p → □Fp
  let ax : Γ ⊢ (p.box.imp (p.all_future.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p)
  
  -- □p (assumption)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  
  -- □Fp (by modus ponens)
  let d : Γ ⊢ (p.all_future.box) :=
    DerivationTree.modus_ponens Γ p.box (p.all_future.box) ax ass
  
  -- Verify soundness
  have v : Γ ⊨ (p.all_future.box) :=
    soundness Γ (p.all_future.box) d
  
  trivial

/--
Test 3: Chained Modal-Future applications.

From [□p], derive □FFp through repeated application.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box]
  
  -- Step 1: □p → □Fp, □p ⊢ □Fp
  let ax1 : Γ ⊢ (p.box.imp (p.all_future.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ (p.all_future.box) :=
    DerivationTree.modus_ponens Γ p.box (p.all_future.box) ax1 ass
  
  -- Step 2: □Fp → □FFp, □Fp ⊢ □FFp
  let ax2 : Γ ⊢ ((p.all_future.box).imp ((p.all_future.all_future).box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p.all_future)
  let d2 : Γ ⊢ ((p.all_future.all_future).box) :=
    DerivationTree.modus_ponens Γ (p.all_future.box)
      ((p.all_future.all_future).box) ax2 d1
  
  -- Verify soundness at each step
  have v1 : Γ ⊨ (p.all_future.box) :=
    soundness Γ (p.all_future.box) d1
  have v2 : Γ ⊨ ((p.all_future.all_future).box) :=
    soundness Γ ((p.all_future.all_future).box) d2
  
  trivial

/--
Test 4: Modal-Future with nested boxes.

From [□□p], derive □□Fp.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box.box]
  
  -- Step 1: □□p → □p using Modal T
  let ax1 : Γ ⊢ (p.box.box.imp p.box) :=
    DerivationTree.axiom Γ _ (Axiom.modal_t p.box)
  let ass : Γ ⊢ p.box.box :=
    DerivationTree.assumption Γ p.box.box (List.Mem.head _)
  let d1 : Γ ⊢ p.box :=
    DerivationTree.modus_ponens Γ p.box.box p.box ax1 ass
  
  -- Step 2: □p → □Fp using Modal-Future
  let ax2 : Γ ⊢ (p.box.imp (p.all_future.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p)
  let d2 : Γ ⊢ (p.all_future.box) :=
    DerivationTree.modus_ponens Γ p.box (p.all_future.box) ax2 d1
  
  -- Step 3: □Fp → □□Fp using Modal 4
  let ax3 : Γ ⊢ ((p.all_future.box).imp ((p.all_future.box).box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_4 p.all_future)
  let d3 : Γ ⊢ ((p.all_future.box).box) :=
    DerivationTree.modus_ponens Γ (p.all_future.box)
      ((p.all_future.box).box) ax3 d2
  
  -- Verify soundness
  have v : Γ ⊨ ((p.all_future.box).box) :=
    soundness Γ ((p.all_future.box).box) d3
  
  trivial

end ModalFutureIntegration

-- ============================================================
-- Temporal-Future Axiom Integration
-- ============================================================

section TemporalFutureIntegration

/--
Test 5: Temporal-Future axiom derivation and soundness.

Verifies □p → F□p is derivable and sound.
-/
example : True := by
  let p := Formula.atom "p"
  let φ := p.box.imp (p.box.all_future)
  
  -- Derive using Temporal-Future axiom
  let d : ⊢ φ := DerivationTree.axiom [] φ (Axiom.temp_future p)
  
  -- Verify soundness
  have v : [] ⊨ φ := soundness [] φ d
  
  -- Verify semantic validity directly
  have v_direct : [] ⊨ φ := temp_future_valid p
  
  trivial

/--
Test 6: Temporal-Future with modus ponens.

From [□p], derive F□p.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box]
  
  -- □p → F□p
  let ax : Γ ⊢ (p.box.imp (p.box.all_future)) :=
    DerivationTree.axiom Γ _ (Axiom.temp_future p)
  
  -- □p (assumption)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  
  -- F□p (by modus ponens)
  let d : Γ ⊢ (p.box.all_future) :=
    DerivationTree.modus_ponens Γ p.box (p.box.all_future) ax ass
  
  -- Verify soundness
  have v : Γ ⊨ (p.box.all_future) :=
    soundness Γ (p.box.all_future) d
  
  trivial

/--
Test 7: Chained Temporal-Future applications.

From [□p], derive FF□p through repeated application.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box]
  
  -- Step 1: □p → F□p, □p ⊢ F□p
  let ax1 : Γ ⊢ (p.box.imp (p.box.all_future)) :=
    DerivationTree.axiom Γ _ (Axiom.temp_future p)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ (p.box.all_future) :=
    DerivationTree.modus_ponens Γ p.box (p.box.all_future) ax1 ass
  
  -- Step 2: F□p → FF□p using Temporal 4
  let ax2 : Γ ⊢ ((p.box.all_future).imp ((p.box.all_future).all_future)) :=
    DerivationTree.axiom Γ _ (Axiom.temp_4 p.box)
  let d2 : Γ ⊢ ((p.box.all_future).all_future) :=
    DerivationTree.modus_ponens Γ (p.box.all_future)
      ((p.box.all_future).all_future) ax2 d1
  
  -- Verify soundness at each step
  have v1 : Γ ⊨ (p.box.all_future) :=
    soundness Γ (p.box.all_future) d1
  have v2 : Γ ⊨ ((p.box.all_future).all_future) :=
    soundness Γ ((p.box.all_future).all_future) d2
  
  trivial

end TemporalFutureIntegration

-- ============================================================
-- Combined Bimodal Workflows
-- ============================================================

section CombinedBimodalWorkflows

/--
Test 8: Combining MF and TF axioms.

From [□p], derive both □Fp and F□p.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box]
  
  -- Path 1: □p → □Fp (Modal-Future)
  let ax1 : Γ ⊢ (p.box.imp (p.all_future.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ (p.all_future.box) :=
    DerivationTree.modus_ponens Γ p.box (p.all_future.box) ax1 ass
  
  -- Path 2: □p → F□p (Temporal-Future)
  let ax2 : Γ ⊢ (p.box.imp (p.box.all_future)) :=
    DerivationTree.axiom Γ _ (Axiom.temp_future p)
  let d2 : Γ ⊢ (p.box.all_future) :=
    DerivationTree.modus_ponens Γ p.box (p.box.all_future) ax2 ass
  
  -- Verify both paths are sound
  have v1 : Γ ⊨ (p.all_future.box) :=
    soundness Γ (p.all_future.box) d1
  have v2 : Γ ⊨ (p.box.all_future) :=
    soundness Γ (p.box.all_future) d2
  
  trivial

/--
Test 9: Complex bimodal derivation chain.

Multi-step proof combining modal and temporal axioms.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box]
  
  -- Step 1: □p → □Fp (Modal-Future)
  let ax1 : Γ ⊢ (p.box.imp (p.all_future.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ (p.all_future.box) :=
    DerivationTree.modus_ponens Γ p.box (p.all_future.box) ax1 ass
  
  -- Step 2: □Fp → F□Fp (Temporal-Future)
  let ax2 : Γ ⊢ ((p.all_future.box).imp ((p.all_future.box).all_future)) :=
    DerivationTree.axiom Γ _ (Axiom.temp_future p.all_future)
  let d2 : Γ ⊢ ((p.all_future.box).all_future) :=
    DerivationTree.modus_ponens Γ (p.all_future.box)
      ((p.all_future.box).all_future) ax2 d1
  
  -- Step 3: F□Fp → FF□Fp (Temporal 4)
  let ax3 : Γ ⊢ (((p.all_future.box).all_future).imp
                  (((p.all_future.box).all_future).all_future)) :=
    DerivationTree.axiom Γ _ (Axiom.temp_4 (p.all_future.box))
  let d3 : Γ ⊢ (((p.all_future.box).all_future).all_future) :=
    DerivationTree.modus_ponens Γ ((p.all_future.box).all_future)
      (((p.all_future.box).all_future).all_future) ax3 d2
  
  -- Verify soundness at each step
  have v1 : Γ ⊨ (p.all_future.box) :=
    soundness Γ (p.all_future.box) d1
  have v2 : Γ ⊨ ((p.all_future.box).all_future) :=
    soundness Γ ((p.all_future.box).all_future) d2
  have v3 : Γ ⊨ (((p.all_future.box).all_future).all_future) :=
    soundness Γ (((p.all_future.box).all_future).all_future) d3
  
  trivial

/--
Test 10: Bimodal workflow with necessitation.

Combine modal and temporal necessitation.
-/
example : True := by
  let p := Formula.atom "p"
  
  -- Start with Modal T axiom
  let d1 : ⊢ (p.box.imp p) :=
    DerivationTree.axiom [] (p.box.imp p) (Axiom.modal_t p)
  
  -- Apply modal necessitation
  let d2 : ⊢ ((p.box.imp p).box) :=
    DerivationTree.necessitation (p.box.imp p) d1
  
  -- Apply temporal necessitation
  let d3 : ⊢ (((p.box.imp p).box).all_future) :=
    DerivationTree.temporal_necessitation ((p.box.imp p).box) d2
  
  -- Verify soundness at each step
  have v1 : [] ⊨ (p.box.imp p) := soundness [] (p.box.imp p) d1
  have v2 : [] ⊨ ((p.box.imp p).box) := soundness [] ((p.box.imp p).box) d2
  have v3 : [] ⊨ (((p.box.imp p).box).all_future) :=
    soundness [] (((p.box.imp p).box).all_future) d3
  
  trivial

end CombinedBimodalWorkflows

-- ============================================================
-- Modal-Temporal Operator Combinations
-- ============================================================

section ModalTemporalCombinations

/--
Test 11: Box-Future combination properties.

Test derivations involving □Fp formulas.
-/
example : True := by
  let p := Formula.atom "p"
  let q := Formula.atom "q"
  
  -- Derive Modal K for Fp: □(Fp → Fq) → (□Fp → □Fq)
  let φ := (p.all_future.imp q.all_future).box.imp
           (p.all_future.box.imp q.all_future.box)
  let d : ⊢ φ :=
    DerivationTree.axiom [] φ (Axiom.modal_k_dist p.all_future q.all_future)
  
  -- Verify soundness
  have v : [] ⊨ φ := soundness [] φ d
  
  trivial

/--
Test 12: Future-Box combination properties.

Test derivations involving F□p formulas.
-/
example : True := by
  let p := Formula.atom "p"
  let q := Formula.atom "q"
  
  -- Derive Temporal K for □p: F(□p → □q) → (F□p → F□q)
  let φ := (p.box.imp q.box).all_future.imp
           (p.box.all_future.imp q.box.all_future)
  let d : ⊢ φ :=
    DerivationTree.axiom [] φ (Axiom.temp_k_dist p.box q.box)
  
  -- Verify soundness
  have v : [] ⊨ φ := soundness [] φ d
  
  trivial

/--
Test 13: Nested bimodal operators.

Test deeply nested □F combinations.
-/
example : True := by
  let p := Formula.atom "p"
  let Γ := [p.box]
  
  -- Build □F□Fp from □p
  -- Step 1: □p → □Fp
  let ax1 : Γ ⊢ (p.box.imp (p.all_future.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ (p.all_future.box) :=
    DerivationTree.modus_ponens Γ p.box (p.all_future.box) ax1 ass
  
  -- Step 2: □Fp → □□Fp
  let ax2 : Γ ⊢ ((p.all_future.box).imp ((p.all_future.box).box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_4 p.all_future)
  let d2 : Γ ⊢ ((p.all_future.box).box) :=
    DerivationTree.modus_ponens Γ (p.all_future.box)
      ((p.all_future.box).box) ax2 d1
  
  -- Step 3: □□Fp → □F□Fp
  let ax3 : Γ ⊢ (((p.all_future.box).box).imp
                  (((p.all_future.box).all_future).box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future (p.all_future.box))
  let d3 : Γ ⊢ (((p.all_future.box).all_future).box) :=
    DerivationTree.modus_ponens Γ ((p.all_future.box).box)
      (((p.all_future.box).all_future).box) ax3 d2
  
  -- Verify soundness
  have v : Γ ⊨ (((p.all_future.box).all_future).box) :=
    soundness Γ (((p.all_future.box).all_future).box) d3
  
  trivial

end ModalTemporalCombinations

-- ============================================================
-- Time-Shift Preservation Tests
-- ============================================================

section TimeShiftPreservation

/--
Test 14: Time-shift with Modal-Future axiom.

Verify that Modal-Future axiom respects time-shift invariance.
-/
example : True := by
  let p := Formula.atom "p"
  
  -- Modal-Future axiom is valid (time-shift invariant)
  let d : ⊢ (p.box.imp (p.all_future.box)) :=
    DerivationTree.axiom [] _ (Axiom.modal_future p)
  
  have v : [] ⊨ (p.box.imp (p.all_future.box)) :=
    soundness [] _ d
  
  -- Validity implies truth at all time-shifted models
  have : ∀ F M τ t ht, truth_at M τ t ht (p.box.imp (p.all_future.box)) := v
  
  trivial

/--
Test 15: Time-shift with Temporal-Future axiom.

Verify that Temporal-Future axiom respects time-shift invariance.
-/
example : True := by
  let p := Formula.atom "p"
  
  -- Temporal-Future axiom is valid (time-shift invariant)
  let d : ⊢ (p.box.imp (p.box.all_future)) :=
    DerivationTree.axiom [] _ (Axiom.temp_future p)
  
  have v : [] ⊨ (p.box.imp (p.box.all_future)) :=
    soundness [] _ d
  
  -- Validity implies truth at all time-shifted models
  have : ∀ F M τ t ht, truth_at M τ t ht (p.box.imp (p.box.all_future)) := v
  
  trivial

end TimeShiftPreservation

end LogosTest.Core.Integration
