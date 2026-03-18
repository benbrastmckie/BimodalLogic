# Implementation Summary: Task #981 - Density Index Induction Attempt

**Date**: 2026-03-18
**Status**: Partial (Phase 1 incomplete)
**Session ID**: sess_1773876363_a46902

## Summary

Attempted to implement the density index induction approach from plan v12 to remove sorries at lines 770 and 839 in DovetailedTimelineQuot.lean. The approach encountered a fundamental mathematical challenge that was not fully resolved in the research phase.

## Work Completed

### Helper Lemmas Added

Added to DovetailedTimelineQuot.lean (lines 618-635):

1. `iteratedFuture_some_future_comm`: Proves `iteratedFuture j (F X) = F (iteratedFuture j X)`
2. `iteratedFuture_add`: Proves `iteratedFuture m (iteratedFuture n psi) = iteratedFuture (m + n) psi`

### Attempted Proof Structures

1. **forward_F_core** (lines 644-806): Attempted direct proof of `F(psi) in p.mcs => exists q, psi in q.mcs` using density + large step. Successfully handles the `j = 0` case but the `j > 0` case requires recursion that doesn't terminate under simple induction.

2. **forward_F_iterate_with_large_step**: Attempted proof using induction on j with explicit large-step conditions. Same termination issue encountered.

## Key Finding: Mathematical Challenge

The research report (26_forward-f-termination-analysis.md) claimed:

> "After ONE application of witness_at_large_step, ALL subsequent steps are guaranteed to be large steps."

This claim is **NOT directly provable** as stated. The issue:

1. **Claim in report**: `w.point_index >= m` where `m = pair(p.point_index, k)`
2. **Actual invariant**: `w.point_index = list_length_before_addition`
3. **Problem**: List length at step m can be much smaller than m (the list grows sparsely, not monotonically with step number)

### The Real Challenge

When using density to find a large encoding:
- We get `iteratedFuture j psi` with encoding >= n + 1
- Large step gives witness with `iteratedFuture j psi in w.mcs`
- If `j > 0`, this is `F(iteratedFuture (j-1) psi) in w.mcs`
- The recursive call may again need density, giving `j' > 0`
- The formula depth can INCREASE: `j' + (j-1)` may be larger than `j`

The number of F's to peel is NOT monotonically decreasing!

### Why Simple Induction Fails

- Strong induction on formula depth `i`: Fails because density can increase depth
- Induction on density index `j`: Fails because next call's `j'` is independent
- Stage-based argument: Stage increases but formula depth can also increase

### What Would Work

The proof requires well-founded recursion on a measure that captures:
1. The stage (which increases monotonically)
2. The "distance to target formula psi" (which eventually decreases)

A lexicographic measure `(remaining_F_count, stage_gap)` or similar could work, but requires proving that the random walk on formula depths eventually reaches 0. This is true because:
- There are only finitely many formulas with small encodings
- At sufficiently high stages, the encoding of our target formula IS large enough for direct large step

## Current State

### Sorries in DovetailedTimelineQuot.lean

| Line | Location | Status |
|------|----------|--------|
| 295 | `dovetailedTimeline_has_intermediate` | Expected (DenselyOrdered case) |
| 806 | `forward_F_core` succ j' case | NEW - same issue as original |
| 959 | `forward_F_chain_witness` succ j' case | Original sorry, unchanged |
| 1028 | `backward_P_chain_witness` succ j' case | Original sorry, symmetric |

### Build Status

```
Build completed successfully (960 jobs)
```

The codebase builds, but with 4 sorries (vs target of 1).

## Recommendations for Next Steps

1. **Option A: Well-founded recursion**: Use `termination_by` with a custom measure. The measure should track that eventually all recursive calls use `j = 0` (direct large step). This requires proving that at sufficiently high stages, the formula encoding is always large enough.

2. **Option B: Accept structured sorry**: The mathematical argument is sound (the construction does produce the required witnesses), but the termination proof is complex. Accept a well-documented sorry that identifies the exact gap.

3. **Option C: Structural redesign**: Reformulate `forward_F_chain_witness` to not use induction on formula depth. Instead, use the dovetailing property directly: show that all (point, formula) pairs are eventually processed.

## Files Modified

- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
  - Added helper lemmas (lines 618-635)
  - Added `forward_F_core` theorem (partial, with sorry at line 806)
  - Unchanged: `forward_F_chain_witness` and `backward_P_chain_witness` still have original sorries

## References

- Plan: specs/981_remove_axiom_technical_debt_from_task_979/plans/12_density-index-induction.md
- Research: specs/981_remove_axiom_technical_debt_from_task_979/reports/26_forward-f-termination-analysis.md
