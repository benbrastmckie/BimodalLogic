# Implementation Summary: Task #825

**Completed**: 2026-02-03 (Partial - Phases 1-4)
**Duration**: ~4 hours total
**Session ID**: sess_1770088279_3fe7d5
**Status**: [PARTIAL] - Phases 1-4 completed (infrastructure and fixed-point), Phases 5-7 remaining

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

### Phase 4: Modal Saturation Property - PARTIAL (this session)

| Definition/Theorem | Status |
|--------------------|--------|
| `is_modally_saturated` | DEFINED |
| `fixed_point_is_saturated` | sorry (contrapositive argument) |
| `saturated_histories_saturated` | sorry (depends on above) |

## Files Modified

- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`
  - Added import for `Bimodal.Metalogic.Bundle.Construction` (for `lindenbaumMCS_set`)
  - Phase 2: Lines 390-530 (~140 lines of saturation infrastructure)
  - Phase 3: Lines 600-730 (~130 lines of fixed-point construction)
  - Phase 4: Lines 750-790 (~40 lines of modal saturation definitions)
  - Updated summary section

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

### Phase 5: Complete modal_backward_from_saturation
- Requires connecting truth lemma to MCS membership
- Uses contrapositive: if Box psi not in MCS, then Diamond(neg psi) holds, so witness exists
- Blocked on TruthLemma.lean sorries

### Phase 6: Update Completeness.lean
- Replace `fdsm_from_closure_mcs` with multi-history construction
- Use `saturated_histories_from` to build proper FDSM
- Define `fdsm_from_saturated_histories` with proper modal_saturated field

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

2. **Simpler Modal Saturation**: For Phase 4 sorries, a simpler approach might be to prove them using specific properties of the saturation_step definition rather than general fixed-point theory.

3. **Testing**: Before Phase 6, create test cases to verify the multi-history construction produces correct models.
