# Implementation Summary: Task #825

**Completed**: 2026-02-03 (Partial - Phases 1-6)
**Duration**: ~6 hours total (across 2 sessions)
**Session IDs**: sess_1770088279_3fe7d5 (Phase 1-4), sess_1770088932_7e850f (Phase 4-6 continuation)
**Status**: [PARTIAL] - MCSTrackedHistory infrastructure added, core saturation theorems remain with sorries

## Overview

This task addresses the modal trivialization bug in the FDSM completeness construction. The current single-history construction makes Box psi = psi, which is semantically incorrect. This implementation provides the multi-history saturation infrastructure.

## Changes Made

### Phase 1: witness_set_consistent - COMPLETED (previous session)

The key theorem `witness_set_consistent` proves that if M is a Set-Maximal Consistent set containing Diamond psi, then the witness set `{psi} U {chi | Box chi in M}` is consistent.

### Phase 2: Saturation Infrastructure - COMPLETED (this session)

Added definitions and proofs for:

| Definition | Purpose |
|------------|---------|
| `hasDiamondWitness` | Check if a diamond formula has a witness in histories |
| `unsatisfiedDiamondFormulas` | Set of diamond formulas needing witnesses |
| `buildWitnessHistory` | Construct witness history via Lindenbaum extension |
| `IsWitnessFor` | Specification of valid witnesses |
| `saturation_step` | One round of adding all missing witnesses |

| Theorem | Status |
|---------|--------|
| `buildWitnessHistory_models_psi` | PROVEN |
| `saturation_step_subset` | PROVEN |
| `saturation_step_nonempty` | PROVEN |

### Phase 3: Fixed-Point Construction - COMPLETED (this session)

Added definitions and proofs for:

| Definition | Purpose |
|------------|---------|
| `saturate_with_fuel` | Fuel-based iteration until fixed point |
| `saturated_histories_from` | Entry point using maxHistories as fuel |

| Theorem | Status |
|---------|--------|
| `saturate_with_fuel_subset` | PROVEN |
| `saturate_with_fuel_nonempty` | PROVEN |
| `fixed_point_stable` | PROVEN |
| `saturation_step_card_increase` | PROVEN |
| `saturation_terminates` | sorry (classical well-founded argument) |

### Phase 4: Modal Saturation Property - PARTIAL (session 2)

| Definition/Theorem | Status |
|--------------------|--------|
| `is_modally_saturated` | DEFINED |
| `MCSTrackedHistory` | DEFINED - Structure to track MCS origin |
| `mcsTrackedHistory_from_mcs` | DEFINED - Constructor from MCS |
| `buildMCSTrackedWitness` | DEFINED - MCS-aware witness construction |
| `buildMCSTrackedWitness_models` | PROVEN - Witness models the formula |
| `fixed_point_is_saturated` | sorry (needs MCS-tracked saturation) |
| `saturated_histories_saturated` | sorry (depends on above) |

**Key Finding**: The abstract `saturation_step` filters from `Finset.univ` but doesn't know how to construct witnesses. The `MCSTrackedHistory` structure bridges this gap by tracking MCS origins, enabling witness construction via `buildMCSTrackedWitness`.

## Files Modified

- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`
  - Added import for `Bimodal.Metalogic.Bundle.Construction` (for `lindenbaumMCS_set`)
  - Phase 2: Lines 390-530 (~140 lines of saturation infrastructure)
  - Phase 3: Lines 600-730 (~130 lines of fixed-point construction)
  - Phase 4: Lines 750-850 (~100 lines of modal saturation definitions and MCSTrackedHistory)
  - Updated summary section

- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean` (session 2)
  - Added import for ModalSaturation.lean
  - Added documentation for multi-history approach
  - Documented blocking issues for full multi-history FDSM construction

## Verification

- Full project build passes: `lake build` succeeds (707 jobs)
- All new definitions compile without errors
- 7 key theorems proven without sorry

## Sorry Audit

Current sorries in ModalSaturation.lean (5 actual code sorries):

| Line | Theorem | Difficulty | Notes |
|------|---------|------------|-------|
| 309 | `neg_box_iff_diamond_neg` | Medium | Classical logic equivalence |
| 345 | `modal_backward_from_saturation` | Hard | Requires truth lemma |
| 728 | `saturation_terminates` | Medium | Well-founded argument |
| 773 | `fixed_point_is_saturated` | Medium | Contrapositive on saturation_step |
| 785 | `saturated_histories_saturated` | Easy | Composition of above |

## Remaining Work

### Phase 4 Completion: MCS-Tracked Saturation
- Add DecidableEq instance for MCSTrackedHistory (using classical decidability)
- Implement saturation iteration on `Finset (MCSTrackedHistory phi)`
- Prove `fixed_point_is_saturated` using MCS-tracked construction
- Prove `saturated_histories_saturated` as composition

### Phase 5: Complete modal_backward_from_saturation
- Requires connecting truth lemma to MCS membership
- Uses contrapositive: if Box psi not in MCS, then Diamond(neg psi) holds, so witness exists
- Blocked on TruthLemma.lean sorries

### Phase 6: Update Completeness.lean (continued)
- Implement full multi-history FDSM construction
- Replace `fdsm_from_closure_mcs` references in completeness proof
- Verify `fdsm_internal_completeness` still holds

### Phase 7: Verification and sorry audit
- Review all sorries in saturation path
- Verify no regressions in dependent files
- Document remaining sorries with justification

## Technical Notes

### Key Design Decisions

1. **Classical Decidability**: Used `Classical.dec` for existential predicates in filter operations, since the domain (FDSMHistory) is finite but predicates involve set membership.

2. **Fuel-Based Iteration**: Instead of well-founded recursion, used explicit fuel bounded by `maxHistories phi = 2^closureSize phi`. This avoids complex termination proofs while ensuring the construction is well-defined.

3. **Witness Construction Path**:
   ```
   witnessSet M psi (consistent by witness_set_consistent)
   → lindenbaumMCS_set (extends to full MCS)
   → mcs_projection (projects to closure MCS)
   → fdsm_history_from_closure_mcs (builds constant history)
   ```

### Dependencies Added

- `Bimodal.Metalogic.Bundle.Construction`: For `lindenbaumMCS_set` and related lemmas

## Recommendations

1. **Phase 5-6 Dependencies**: The remaining sorries mostly depend on connecting the truth lemma to MCS membership. Consider prioritizing TruthLemma.lean completions.

2. **Alternative Approach for Modal Saturation**: Instead of proving abstract fixed point properties, directly construct the saturated set by:
   - Starting with initial MCS-tracked history
   - Explicitly enumerating Diamond formulas in closure
   - Adding witness for each via `buildMCSTrackedWitness`
   - The resulting finite set is trivially saturated by construction

3. **Testing**: Before Phase 6, create test cases to verify the multi-history construction produces correct models.

4. **DecidableEq for MCSTrackedHistory**: This requires comparing two Set Formula values for equality, which is undecidable in general. Use classical decidability or restructure to avoid this requirement.

## Session 2 Key Finding

The fundamental gap identified in this session:
- The abstract `saturation_step` filters from `Finset.univ` for histories satisfying `IsWitnessFor`
- Proving witness existence requires constructing witnesses via `buildWitnessHistory`
- `buildWitnessHistory` needs MCS information that plain `FDSMHistory` values don't carry
- `MCSTrackedHistory` was added to bridge this gap, but requires type class instances (DecidableEq) for full integration
