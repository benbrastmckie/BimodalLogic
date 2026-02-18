# Phase 2 Handoff: processWorkItem_preserves_closure (Iteration 4)

**Session**: sess_1771447870_20a856
**Date**: 2026-02-18
**Plan**: specs/864_recursive_seed_henkin_model/plans/implementation-006.md

## Immediate Next Action

**Fix the 3 sorries in futureNegative case** at lines ~9305, ~9358, ~9409.

The issue: `createNewTime_preserves_mem_getFormulas` requires precondition `f' != famIdxTarget OR t != newTime`, but in the `inl h_pos_orig` case we need to establish this.

**Key insight**: In the `inl h_pos_orig` case, position existed in the ORIGINAL seed before ANY modifications. The fresh time is `freshFutureTime > item.timeIdx`. If position at (f', t) existed in original seed and we're applying `createNewTime_preserves_mem_getFormulas` for that position, we need to show f' != item.famIdx OR t != freshFutureTime.

**Solution approach**:
1. The `freshFutureTime` is defined to be greater than all existing times for the given family
2. Therefore if position (f', t) existed in seed1, either:
   - f' != item.famIdx (different family), or
   - t < freshFutureTime (existing time is less than fresh time)
3. In either case, t != freshFutureTime (unless f' = item.famIdx and position was at exactly freshFutureTime, which is impossible since freshFutureTime is strictly greater than all existing times)

May need helper lemma: `hasPosition_time_lt_freshFutureTime` or similar.

## Current State

**File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
**Location**: `processWorkItem_preserves_closure` theorem, line ~8400

### Cases Completed (0 sorries in main proof structure):
1. atomic - DONE
2. bottom - DONE
3. implication - DONE
4. negation - DONE
5. boxPositive - DONE (complex case using foldl_addFormula_fam_puts_phi_in_all)
6. boxNegative - DONE (using backward reasoning lemmas)

### Cases Partially Complete:
7. futureNegative - Structure done, 3 internal sorries (need hasPosition vs freshFutureTime reasoning)

### Cases Not Started:
8. futurePositive - Similar to boxPositive but for times (complex foldl over times)
9. pastPositive - Similar to futurePositive
10. pastNegative - Similar to futureNegative

## Key Decisions Made

1. **Backward reasoning lemmas added**:
   - `mem_getFormulas_after_foldl_fam` (line ~8115)
   - `mem_getFormulas_after_foldl_times` (line ~8145)
   - `mem_getFormulas_after_createNewFamily` (line ~5200)
   - `mem_getFormulas_after_createNewTime` (line ~5250)
   - `foldl_addFormula_fam_preserves_hasPosition_not_in` (line ~8170)

2. **Pattern for negative cases (boxNegative, futureNegative, pastNegative)**:
   - Use backward reasoning to trace Box/G/H formulas to original seed
   - Neither neg(X psi) nor neg psi is a Box/G/H formula
   - Preserve membership through forward direction

3. **Pattern for positive cases (boxPositive, futurePositive, pastPositive)**:
   - For formulas from old seed: preserve through foldl
   - For newly added formulas: use foldl_puts_phi_in_all lemmas

## What NOT to Try

- Direct application of `createNewTime_preserves_mem_getFormulas` without establishing the disjunction precondition
- Assuming f' = famIdxTarget in the `inl h_pos_orig` case (it's usually not)

## Critical Context

1. **WorklistClosureInvariant** definition (line ~7800): Three-part conjunction for Box, G, H closure
2. **processWorkItem** definition (line ~6699): 10 cases, returns (newWork, state')
3. **freshFutureTime** is strictly greater than current time AND all existing times for the family
4. **freshPastTime** is strictly less than current time AND all existing times for the family

## Helper Lemmas Available

- `createNewFamily_preserves_hasPosition` (line ~6287)
- `createNewTime_preserves_hasPosition` (line ~6359)
- `addFormula_hasPosition_backward` (line ~6128)
- `hasPosition_implies_in_familyIndices` (line ~8172)
- `ModelSeed.freshFutureTime_gt` (shows freshFutureTime > current time)

## References

- Plan: `specs/864_recursive_seed_henkin_model/plans/implementation-006.md`
- Research: `specs/864_recursive_seed_henkin_model/reports/research-007.md`

## Sorry Count Progress

Starting this session: ~29 (from delegation context estimate)
After this session: 26

Changes:
- atomic, bottom, implication, negation: confirmed working (no sorries added)
- boxPositive: complete (removed 1 sorry from previous)
- boxNegative: complete (no sorries)
- futureNegative: added structure (3 sorries remain for hasPosition reasoning)
