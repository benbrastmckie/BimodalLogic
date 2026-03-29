# Implementation Summary: Task 67 - Termination-First Restricted Truth Lemma

**Task**: 67 - prove_bundle_validity_implies_provability
**Plan**: 03_termination-first-plan.md
**Status**: PARTIAL (Phase 1 analysis complete, termination measure identified but not proven)
**Date**: 2026-03-28

## Overview

This implementation attempt focused on filling the termination sorries in SuccChainFMCS.lean as the first phase of eliminating the sorry in `bundle_validity_implies_provability`. The termination proofs turned out to be more complex than anticipated.

## Work Completed

### Phase 1: Termination Sorries Analysis

**Status**: PARTIAL

**Key Finding**: The termination argument for `restricted_bounded_witness` and related functions requires a lexicographic measure that the current Lean 4 `decreasing_by` mechanism cannot easily express.

**The Problem**:
- Functions like `restricted_bounded_witness` have recursive calls where the depth parameter `d` can INCREASE (when `d' > 1`)
- The position `k` always increases by 1 with each call
- The depth is bounded by `closure_F_bound phi`, but this bound is not sufficient for a simple `termination_by d` proof

**Termination Measure Attempted**: `(closure_F_bound phi - d, d)` with lexicographic ordering
- This works for the `d' = 1` case where depth decreases
- This works for the `d' > 2` case where the first component decreases
- This FAILS for the `d' = 2` case where `d' + (n - 1) = n + 1 = d`, so neither component strictly decreases

**Correct Termination Argument** (not yet implemented):
The function terminates because:
1. The total "F-work" is bounded by `(closure_F_bound phi)^2`
2. Each call either:
   - Resolves one F (decreasing cumulative depth)
   - Defers F (but advances position and consumes "fuel")
3. After at most `B^2` calls (where `B = closure_F_bound phi`), termination is guaranteed

**What Would Fix It**:
1. Add an explicit `fuel` parameter that decreases on each non-depth-decreasing call
2. Use well-founded recursion with a custom measure on `(total_fuel_used, d)`
3. Prove fuel sufficiency: `B * B` fuel is always enough

### Code Changes Made

Modified `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`:
- Refactored `restricted_bounded_witness` to use `termination_by (closure_F_bound phi - d, d)`
- The proof structure is correct but `decreasing_by` goals remain as `sorry`
- Build completes successfully with sorries

## Remaining Work

### Phase 1 (Incomplete)
- Fill 4 termination `decreasing_by sorry` blocks at lines 2793, 4212, 4361, 4542
- Requires either:
  - Fuel-based approach with sufficiency proof
  - More sophisticated well-founded measure

### Phases 2-5 (Not Started)
- Phase 2: G/H propagation sorries (3 in RestrictedTruthLemma.lean)
- Phase 3: Restricted BFMCS coherence bridge
- Phase 4: Restricted truth lemma adaptation
- Phase 5: Completeness wiring

## Sorry Count Summary

| File | Sorry Count | Notes |
|------|-------------|-------|
| SuccChainFMCS.lean | 18 | 4 termination, others for different issues |
| RestrictedTruthLemma.lean | 3 | G/H propagation |
| Completeness.lean | 18 | Main completeness sorry at line 176 |

## Recommendations

1. **For termination sorries**: Implement fuel-based version with explicit bound proof
2. **Alternative path**: Consider if the restricted approach can avoid these recursive calls entirely
3. **Consider Path B**: The family-level coherence path from the research might have simpler termination

## Build Status

- `lake build` succeeds with warnings about sorries
- No regressions introduced
- All existing theorems still compile
