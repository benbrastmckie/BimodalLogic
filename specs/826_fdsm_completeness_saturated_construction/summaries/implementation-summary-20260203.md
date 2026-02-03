# Implementation Summary: Task #826

**Task**: FDSM Completeness Saturated Construction
**Completed**: 2026-02-03
**Status**: Partial

## Overview

This task aimed to complete sorries in the FDSM completeness module to enable a sorry-free path through the metalogic. Progress was made on key proofs, but several sorries remain due to architectural limitations and complexity.

## Changes Made

### Phase 1: Core.lean (COMPLETED)

**File**: `Theories/Bimodal/Metalogic/FDSM/Core.lean`

**Change**: Modified the `modal_saturated` field in `FiniteDynamicalSystemModel` to use direct `toSet` membership instead of `.models` which required a closure membership proof.

**Before**:
```lean
modal_saturated : ∀ h ∈ histories, ∀ t : FDSMTime phi, ∀ psi : Formula,
    ∀ h_psi_clos : psi ∈ closure phi,
    (h.states t).models (Formula.neg (Formula.box (Formula.neg psi))) (by sorry) →
    ∃ h' ∈ histories, (h'.states t).models psi h_psi_clos
```

**After**:
```lean
modal_saturated : ∀ h ∈ histories, ∀ t : FDSMTime phi, ∀ psi : Formula,
    ∀ h_psi_clos : psi ∈ closure phi,
    Formula.neg (Formula.box (Formula.neg psi)) ∈ (h.states t).toSet →
    ∃ h' ∈ histories, (h'.states t).models psi h_psi_clos
```

**Impact**: Eliminates the need for Diamond formulas to be in closure phi, which is not generally true.

### Phase 3: ModalSaturation.lean (PARTIAL)

**File**: `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`

#### Completed: neg_box_iff_diamond_neg (lines 286-354)

Proved the classical equivalence theorem showing that `(Box psi).neg ∈ S` implies `(Box psi.neg.neg).neg ∈ S` for any MCS S.

**Proof technique**:
1. Used double negation elimination (DNE) theorem
2. Applied necessitation to DNE inside Box
3. Used modal_k_dist distribution axiom
4. Derived contrapositive using b_combinator and prop_k
5. Applied MCS closure under derivation

#### Simplified: saturation_terminates (lines 756-792)

Restructured the termination proof to use a cleaner argument structure. The proof now has 2 inner sorries for:
1. Classical well-founded recursion argument
2. Bound verification that n ≤ maxHistories phi

### Phase 2: Closure.lean (BLOCKED)

**File**: `Theories/Bimodal/Metalogic/FMP/Closure.lean`

The lemma `diamond_in_closureWithNeg_of_box` at line 728 is **architecturally blocked**. The claim that `Box psi ∈ closure phi` implies `Diamond(psi.neg) ∈ closureWithNeg phi` is false because `Box(psi.neg.neg)` is not necessarily a subformula of phi.

## Files Modified

1. `Theories/Bimodal/Metalogic/FDSM/Core.lean`
   - Changed modal_saturated field signature (removed sorry)

2. `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`
   - Completed neg_box_iff_diamond_neg proof
   - Simplified saturation_terminates structure

3. `specs/826_fdsm_completeness_saturated_construction/plans/implementation-001.md`
   - Updated phase statuses

## Remaining Sorries

### ModalSaturation.lean (9 sorries)
- `modal_backward_from_saturation` - Requires truth lemma
- `saturation_terminates` - 2 inner sorries for well-founded recursion
- `fixed_point_is_saturated` - Contrapositive argument
- `saturated_histories_saturated` - Depends on saturation_terminates
- `mcsTrackedHistory_finite` - Proof irrelevance
- `tracked_saturated_histories_saturated` - Tracked version
- `projectTrackedHistories_modal_saturated` - Projection lemma
- `fdsm_from_tracked_saturation` modal_saturated case

### TruthLemma.lean (13 sorries)
- Closure membership tracking throughout induction
- Modal and temporal case handling

### Completeness.lean (2 sorries)
- `fdsm_from_closure_mcs` modal_saturated case
- `fdsm_mcs_implies_truth` and `fdsm_mcs_neg_implies_false`

### Closure.lean (1 sorry)
- `diamond_in_closureWithNeg_of_box` - BLOCKED (architecturally unprovable)

### FiniteStrongCompleteness.lean (1 sorry)
- `weak_completeness` validity bridge - Known architectural limitation

## Verification

- `lake build` succeeds with no errors
- All modified files compile successfully
- Build job count: 707

## Recommendations

1. **Closure.lean sorry**: Mark as Boneyard candidate for task 818. The lemma should be removed or its signature corrected.

2. **TruthLemma.lean**: Focus on simplifying the induction structure. Consider whether all cases need full closure tracking or if toSet membership suffices.

3. **Saturation termination**: Complete the well-founded recursion using Mathlib's `WellFounded.recursion` or `Nat.lt_wfRel`.

4. **Modal backward**: This requires the full truth lemma infrastructure. Defer until TruthLemma.lean sorries are resolved.

## Notes

The architectural change to Core.lean (using toSet instead of models) propagates correctly through the codebase. This pattern may be applicable to other sorries that require Diamond formulas to be in closure.
