# Phase 1 Implementation Summary: Cleanup + Same Order Type

**Task**: 155 - reynolds_pipeline_activation
**Phase**: 1
**Status**: BLOCKED
**Session**: sess_1779565373_9bf0c5

## What Was Done

Detailed analysis of all Phase 1 tasks to determine feasibility. No code changes were made because all substantive tasks (1A, 1C, 1D, 1E) are blocked on the same root cause.

### Task 1B (only completable task)
Decision: KEEP `pigeonhole_definable_formula_cross_strict`. It is actively used at line 2792 in Case B carrier-point sub-case. No code change needed.

## What Was Found

### Root Cause: h_d_unique is NOT orphaned
The plan claimed h_d_unique (lines 2227-2331) is "orphaned" because "d_consistency now uses inline Claim 1." This is incorrect:
- `d_consistency_left` takes h_d_unique as parameter (line 1503) and uses it (line 1602)
- `d_consistency_right` takes h_d_unique as parameter (line 1636) and uses it (line 1724)
- Both are called with h_d_unique at lines 2332-2337

### All tasks share the Claim 1 dependency
- **1A**: Cannot delete h_d_unique without breaking d_consistency_left/right
- **1C**: Boundary case (q_r2 = y') is genuinely non-trivial, not unreachable from bounds
- **1D**: 6 remaining goals after same_order_type_grid need `(d < p_n ↔ c < e_n)` from Claim 1
- **1E**: Dead code uses pivot_chain_order needing `(x' < d ↔ x < c)` from sigma instantiation

## Plan Deviations

- **1A**: Skipped -- h_d_unique is NOT orphaned; still used by d_consistency_left/right
- **1B**: Altered -- decision is KEEP (used at line 2792), not delete/archive
- **1C**: Skipped -- boundary case is NOT unreachable from bounds; requires K⁻ argument
- **1D**: Skipped -- no block-commented proof exists; all remaining goals need Claim 1
- **1E**: Skipped -- blocked on sigma instantiation for (x' < d ↔ x < c)
- **1F**: Skipped -- no changes to verify

## Recommendations

1. The plan's Phase 1 scope should be revised to acknowledge the Claim 1 dependency
2. Phase 1 and Phase 3 share the K⁻(¬D) formula construction requirement
3. Consider merging Phase 1 sorries (1D, 1E, and the h_d_unique sorries) with Phase 3 gap work
4. The sorry count remains 14 in ExpressivenessGeneral.lean (unchanged)

## Artifacts

- Plan: `specs/155_reynolds_pipeline_activation/plans/27_reynolds-pipeline-plan.md` (updated with deviations)
- Handoff: `specs/155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260523T195606.md`
