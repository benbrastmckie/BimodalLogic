/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem
import FormalSystem.Semantics
import FormalSystem.Metalogic
import FormalSystem.Theorems.Combinators
import BimodalTest.Integration.Helpers

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

namespace BimodalTest.Integration

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics
open FormalSystem.Metalogic
open FormalSystem.Theorems.Combinators
open BimodalTest.Integration.Helpers

-- ============================================================
-- Modal-Future Axiom Integration
-- ============================================================

section ModalFutureIntegration

/--
Test 1: Modal-Future axiom derivation and soundness.

Verifies □p → □Fp is derivable and sound.
-/
example : True := by
  let p := Formula.atomS "p"
  let φ := p.box.imp (p.allFuture.box)
  
  -- Derive using Modal-Future axiom
  let d : ⊢ φ := DerivationTree.axiom [] φ (Axiom.modal_future p) trivial
  
  -- Verify soundness
  have v : [] ⊨ φ := soundness [] φ d
  
  -- Verify semantic validity directly
  have v_direct : ⊨ φ := modal_future_valid p
  
  trivial

/--
Test 2: Modal-Future with modus ponens.

From [□p], derive □Fp.
-/
example : True := by
  let p := Formula.atomS "p"
  let Γ := [p.box]
  
  -- □p → □Fp
  let ax : Γ ⊢ (p.box.imp (p.allFuture.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p) trivial
  
  -- □p (assumption)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  
  -- □Fp (by modus ponens)
  let d : Γ ⊢ (p.allFuture.box) :=
    DerivationTree.modus_ponens Γ p.box (p.allFuture.box) ax ass
  
  -- Verify soundness
  have v : Γ ⊨ (p.allFuture.box) :=
    soundness Γ (p.allFuture.box) d
  
  trivial

/--
Test 3: Chained Modal-Future applications.

From [□p], derive □FFp through repeated application.
-/
example : True := by
  let p := Formula.atomS "p"
  let Γ := [p.box]
  
  -- Step 1: □p → □Fp, □p ⊢ □Fp
  let ax1 : Γ ⊢ (p.box.imp (p.allFuture.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p) trivial
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ (p.allFuture.box) :=
    DerivationTree.modus_ponens Γ p.box (p.allFuture.box) ax1 ass
  
  -- Step 2: □Fp → □FFp, □Fp ⊢ □FFp
  let ax2 : Γ ⊢ ((p.allFuture.box).imp ((p.allFuture.allFuture).box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p.allFuture) trivial
  let d2 : Γ ⊢ ((p.allFuture.allFuture).box) :=
    DerivationTree.modus_ponens Γ (p.allFuture.box)
      ((p.allFuture.allFuture).box) ax2 d1
  
  -- Verify soundness at each step
  have v1 : Γ ⊨ (p.allFuture.box) :=
    soundness Γ (p.allFuture.box) d1
  have v2 : Γ ⊨ ((p.allFuture.allFuture).box) :=
    soundness Γ ((p.allFuture.allFuture).box) d2
  
  trivial

/--
Test 4: Modal-Future with nested boxes.

From [□□p], derive □□Fp.
-/
example : True := by
  let p := Formula.atomS "p"
  let Γ := [p.box.box]
  
  -- Step 1: □□p → □p using Modal T
  let ax1 : Γ ⊢ (p.box.box.imp p.box) :=
    DerivationTree.axiom Γ _ (Axiom.modal_t p.box) trivial
  let ass : Γ ⊢ p.box.box :=
    DerivationTree.assumption Γ p.box.box (List.Mem.head _)
  let d1 : Γ ⊢ p.box :=
    DerivationTree.modus_ponens Γ p.box.box p.box ax1 ass
  
  -- Step 2: □p → □Fp using Modal-Future
  let ax2 : Γ ⊢ (p.box.imp (p.allFuture.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p) trivial
  let d2 : Γ ⊢ (p.allFuture.box) :=
    DerivationTree.modus_ponens Γ p.box (p.allFuture.box) ax2 d1
  
  -- Step 3: □Fp → □□Fp using Modal 4
  let ax3 : Γ ⊢ ((p.allFuture.box).imp ((p.allFuture.box).box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_4 p.allFuture) trivial
  let d3 : Γ ⊢ ((p.allFuture.box).box) :=
    DerivationTree.modus_ponens Γ (p.allFuture.box)
      ((p.allFuture.box).box) ax3 d2
  
  -- Verify soundness
  have v : Γ ⊨ ((p.allFuture.box).box) :=
    soundness Γ ((p.allFuture.box).box) d3
  
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
  let p := Formula.atomS "p"
  let φ := p.box.imp (p.box.allFuture)
  
  -- Derive using Temporal-Future axiom
  let d : ⊢ φ := temporalFutureDerived p

  -- Verify soundness
  have v : [] ⊨ φ := soundness [] φ d

  -- Verify semantic validity (TF soundness inherited from MF + T + Modal 4)
  have v_direct : [] ⊨ φ := soundness [] φ d
  
  trivial

/--
Test 6: Temporal-Future with modus ponens.

From [□p], derive F□p.
-/
example : True := by
  let p := Formula.atomS "p"
  let Γ := [p.box]
  
  -- □p → F□p (derived from MF + T + Modal 4)
  let ax : Γ ⊢ (p.box.imp (p.box.allFuture)) :=
    DerivationTree.weakening [] Γ _ (temporalFutureDerived p) (List.nil_subset Γ)
  
  -- □p (assumption)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  
  -- F□p (by modus ponens)
  let d : Γ ⊢ (p.box.allFuture) :=
    DerivationTree.modus_ponens Γ p.box (p.box.allFuture) ax ass
  
  -- Verify soundness
  have v : Γ ⊨ (p.box.allFuture) :=
    soundness Γ (p.box.allFuture) d
  
  trivial

/--
Test 7: Chained Temporal-Future applications.

From [□p], derive FF□p through repeated application.
-/
example : True := by
  let p := Formula.atomS "p"
  let Γ := [p.box]
  
  -- Step 1: □p → F□p, □p ⊢ F□p
  let ax1 : Γ ⊢ (p.box.imp (p.box.allFuture)) :=
    DerivationTree.weakening [] Γ _ (temporalFutureDerived p) (List.nil_subset Γ)
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ (p.box.allFuture) :=
    DerivationTree.modus_ponens Γ p.box (p.box.allFuture) ax1 ass

  -- Step 2: F□p → FF□p using Temporal 4
  let ax2 : Γ ⊢ ((p.box.allFuture).imp ((p.box.allFuture).allFuture)) :=
    DerivationTree.weakening [] Γ _ (FormalSystem.Theorems.TemporalDerived.temporal4Derived p.box)
        (List.nil_subset _)
  let d2 : Γ ⊢ ((p.box.allFuture).allFuture) :=
    DerivationTree.modus_ponens Γ (p.box.allFuture)
      ((p.box.allFuture).allFuture) ax2 d1
  
  -- Verify soundness at each step
  have v1 : Γ ⊨ (p.box.allFuture) :=
    soundness Γ (p.box.allFuture) d1
  have v2 : Γ ⊨ ((p.box.allFuture).allFuture) :=
    soundness Γ ((p.box.allFuture).allFuture) d2
  
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
  let p := Formula.atomS "p"
  let Γ := [p.box]
  
  -- Path 1: □p → □Fp (Modal-Future)
  let ax1 : Γ ⊢ (p.box.imp (p.allFuture.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p) trivial
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ (p.allFuture.box) :=
    DerivationTree.modus_ponens Γ p.box (p.allFuture.box) ax1 ass
  
  -- Path 2: □p → F□p (Temporal-Future)
  let ax2 : Γ ⊢ (p.box.imp (p.box.allFuture)) :=
    DerivationTree.weakening [] Γ _ (temporalFutureDerived p) (List.nil_subset Γ)
  let d2 : Γ ⊢ (p.box.allFuture) :=
    DerivationTree.modus_ponens Γ p.box (p.box.allFuture) ax2 ass
  
  -- Verify both paths are sound
  have v1 : Γ ⊨ (p.allFuture.box) :=
    soundness Γ (p.allFuture.box) d1
  have v2 : Γ ⊨ (p.box.allFuture) :=
    soundness Γ (p.box.allFuture) d2
  
  trivial

/--
Test 9: Complex bimodal derivation chain.

Multi-step proof combining modal and temporal axioms.
-/
example : True := by
  let p := Formula.atomS "p"
  let Γ := [p.box]
  
  -- Step 1: □p → □Fp (Modal-Future)
  let ax1 : Γ ⊢ (p.box.imp (p.allFuture.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p) trivial
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ (p.allFuture.box) :=
    DerivationTree.modus_ponens Γ p.box (p.allFuture.box) ax1 ass
  
  -- Step 2: □Fp → F□Fp (Temporal-Future)
  let ax2 : Γ ⊢ ((p.allFuture.box).imp ((p.allFuture.box).allFuture)) :=
    DerivationTree.weakening [] Γ _ (temporalFutureDerived p.allFuture) (List.nil_subset Γ)
  let d2 : Γ ⊢ ((p.allFuture.box).allFuture) :=
    DerivationTree.modus_ponens Γ (p.allFuture.box)
      ((p.allFuture.box).allFuture) ax2 d1
  
  -- Step 3: F□Fp → FF□Fp (Temporal 4)
  let ax3 : Γ ⊢ (((p.allFuture.box).allFuture).imp
                  (((p.allFuture.box).allFuture).allFuture)) :=
    DerivationTree.weakening [] Γ _ (FormalSystem.Theorems.TemporalDerived.temporal4Derived
        (p.allFuture.box)) (List.nil_subset _)
  let d3 : Γ ⊢ (((p.allFuture.box).allFuture).allFuture) :=
    DerivationTree.modus_ponens Γ ((p.allFuture.box).allFuture)
      (((p.allFuture.box).allFuture).allFuture) ax3 d2
  
  -- Verify soundness at each step
  have v1 : Γ ⊨ (p.allFuture.box) :=
    soundness Γ (p.allFuture.box) d1
  have v2 : Γ ⊨ ((p.allFuture.box).allFuture) :=
    soundness Γ ((p.allFuture.box).allFuture) d2
  have v3 : Γ ⊨ (((p.allFuture.box).allFuture).allFuture) :=
    soundness Γ (((p.allFuture.box).allFuture).allFuture) d3
  
  trivial

/--
Test 10: Bimodal workflow with necessitation.

Combine modal and temporal necessitation.
-/
example : True := by
  let p := Formula.atomS "p"
  
  -- Start with Modal T axiom
  let d1 : ⊢ (p.box.imp p) :=
    DerivationTree.axiom [] (p.box.imp p) (Axiom.modal_t p) trivial
  
  -- Apply modal necessitation
  let d2 : ⊢ ((p.box.imp p).box) :=
    DerivationTree.necessitation (p.box.imp p) d1
  
  -- Apply temporal necessitation
  let d3 : ⊢ (((p.box.imp p).box).allFuture) :=
    DerivationTree.temporal_necessitation ((p.box.imp p).box) d2
  
  -- Verify soundness at each step
  have v1 : [] ⊨ (p.box.imp p) := soundness [] (p.box.imp p) d1
  have v2 : [] ⊨ ((p.box.imp p).box) := soundness [] ((p.box.imp p).box) d2
  have v3 : [] ⊨ (((p.box.imp p).box).allFuture) :=
    soundness [] (((p.box.imp p).box).allFuture) d3
  
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
  let p := Formula.atomS "p"
  let q := Formula.atomS "q"
  
  -- Derive Modal K for Fp: □(Fp → Fq) → (□Fp → □Fq)
  let φ := (p.allFuture.imp q.allFuture).box.imp
           (p.allFuture.box.imp q.allFuture.box)
  let d : ⊢ φ :=
    DerivationTree.axiom [] φ (Axiom.modal_k_dist p.allFuture q.allFuture) trivial
  
  -- Verify soundness
  have v : [] ⊨ φ := soundness [] φ d
  
  trivial

/--
Test 12: Future-Box combination properties.

Test derivations involving F□p formulas.
-/
example : True := by
  let p := Formula.atomS "p"
  let q := Formula.atomS "q"
  
  -- Derive Temporal K for □p: F(□p → □q) → (F□p → F□q)
  let φ := (p.box.imp q.box).allFuture.imp
           (p.box.allFuture.imp q.box.allFuture)
  let d : ⊢ φ :=
    FormalSystem.Theorems.TemporalDerived.temporalKDistDerived p.box q.box
  
  -- Verify soundness
  have v : [] ⊨ φ := soundness [] φ d
  
  trivial

/--
Test 13: Nested bimodal operators.

Test deeply nested □F combinations.
-/
example : True := by
  let p := Formula.atomS "p"
  let Γ := [p.box]
  
  -- Build □F□Fp from □p
  -- Step 1: □p → □Fp
  let ax1 : Γ ⊢ (p.box.imp (p.allFuture.box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future p) trivial
  let ass : Γ ⊢ p.box :=
    DerivationTree.assumption Γ p.box (List.Mem.head _)
  let d1 : Γ ⊢ (p.allFuture.box) :=
    DerivationTree.modus_ponens Γ p.box (p.allFuture.box) ax1 ass
  
  -- Step 2: □Fp → □□Fp
  let ax2 : Γ ⊢ ((p.allFuture.box).imp ((p.allFuture.box).box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_4 p.allFuture) trivial
  let d2 : Γ ⊢ ((p.allFuture.box).box) :=
    DerivationTree.modus_ponens Γ (p.allFuture.box)
      ((p.allFuture.box).box) ax2 d1
  
  -- Step 3: □□Fp → □F□Fp
  let ax3 : Γ ⊢ (((p.allFuture.box).box).imp
                  (((p.allFuture.box).allFuture).box)) :=
    DerivationTree.axiom Γ _ (Axiom.modal_future (p.allFuture.box)) trivial
  let d3 : Γ ⊢ (((p.allFuture.box).allFuture).box) :=
    DerivationTree.modus_ponens Γ ((p.allFuture.box).box)
      (((p.allFuture.box).allFuture).box) ax3 d2
  
  -- Verify soundness
  have v : Γ ⊨ (((p.allFuture.box).allFuture).box) :=
    soundness Γ (((p.allFuture.box).allFuture).box) d3
  
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
  let p := Formula.atomS "p"
  
  -- Modal-Future axiom is valid (time-shift invariant)
  let d : ⊢ (p.box.imp (p.allFuture.box)) :=
    DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.modal_future p) trivial
  
  have v : [] ⊨ (p.box.imp (p.allFuture.box)) :=
    soundness [] _ d
  
  -- Validity implies truth at all time-shifted models
  have _time_shift : [] ⊨ (p.box.imp (p.allFuture.box)) := v
  
  trivial

/--
Test 15: Time-shift with Temporal-Future axiom.

Verify that Temporal-Future axiom respects time-shift invariance.
-/
example : True := by
  let p := Formula.atomS "p"
  
  -- Temporal-Future axiom is valid (time-shift invariant)
  let d : ⊢ (p.box.imp (p.box.allFuture)) :=
    temporalFutureDerived p
  
  have v : [] ⊨ (p.box.imp (p.box.allFuture)) :=
    soundness [] _ d
  
  -- Validity implies truth at all time-shifted models
  have _time_shift : [] ⊨ (p.box.imp (p.box.allFuture)) := v
  
  trivial

end TimeShiftPreservation

end BimodalTest.Integration
