# Implementation Summary: Task #56

- **Task**: 56 - clean_up_succchain_fmcs_dead_code
- **Status**: COMPLETED
- **Plan**: plans/01_dead-code-removal.md
- **Date**: 2026-03-24

## Overview

Removed 2258 lines of dead code from two Lean 4 files. The code consisted of mathematically FALSE theorems, deprecated nesting bounds, and failed proof attempts.

## Quantitative Results

| File | Before | After | Removed |
|------|--------|-------|---------|
| SuccChainFMCS.lean | 4542 | 2470 | 2072 |
| RestrictedMCS.lean | 1603 | 1417 | 186 |
| **Total** | 6145 | 3887 | **2258** |

## Phase Execution

### Phase 1: Remove FALSE restricted variants
**Lines removed**: 970
- `restricted_succ_propagates_F_not` (with docstring)
- `restricted_succ_propagates_F_not'` (with docstring and section comment)
- `restricted_single_step_forcing'` (with docstring)

### Phase 2: Remove single_step_forcing and bounded_witness
**Lines removed**: 841
- `restricted_single_step_forcing` (749 lines, 9 sorries)
- `restricted_bounded_witness` (80 lines, depended on FALSE theorems)

### Phase 3: Remove deprecated nesting bounds and dependents
**Lines removed**: 244
- `f_nesting_is_bounded` (mathematically FALSE for arbitrary MCS)
- `f_nesting_boundary` (depended on FALSE theorem)
- `succ_chain_forward_F_neg` (depended on FALSE theorem)
- `succ_chain_forward_F` (depended on FALSE theorem)
- `p_nesting_is_bounded` (mathematically FALSE for arbitrary MCS)
- `p_nesting_boundary` (depended on FALSE theorem)
- `succ_chain_backward_P` (depended on FALSE theorem)
- `SuccChainTemporalCoherent` (depended on FALSE theorems)

### Phase 4: RestrictedMCS cleanup and summary update
**Lines removed**: 186
- `p_step_blocking_for_deferral_restricted` (from RestrictedMCS.lean)
- Updated summary section in SuccChainFMCS.lean

## Verification

- `lake build` passes successfully after all phases
- No grep hits for deleted theorem names
- Code reduction exceeds estimate (2258 vs ~2034 projected)

## Remaining Infrastructure

The mathematically correct restricted versions remain:
- `f_nesting_is_bounded_restricted`
- `f_nesting_boundary_restricted`
- `p_nesting_is_bounded_restricted`
- `p_nesting_boundary_restricted`
- `p_step_blocking_for_deferral_restricted_correct`
- All DeferralRestrictedSerialMCS infrastructure

## Artifacts

- Plan: `specs/056_clean_up_succchain_fmcs_dead_code/plans/01_dead-code-removal.md`
- Summary: `specs/056_clean_up_succchain_fmcs_dead_code/summaries/01_dead-code-removal-summary.md`
