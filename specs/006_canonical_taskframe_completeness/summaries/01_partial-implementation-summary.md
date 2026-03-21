# Implementation Summary: Task #1006 (Partial)

**Date**: 2026-03-20
**Status**: Partial - 2 sorries remain
**Session**: sess_1774019195_85c381

## Overview

This session attempted to close the 3 remaining sorries in `FlagBFMCSRatBundle.lean`:
1. `convex` (line 364) - WorldHistory domain convexity
2. `respects_task` (line ~370) - Task relation coherence
3. `shifted_truth_lemma` (line 438) - Truth lemma for shifted WorldHistory

## Progress Made

### Closed: `respects_task`

Successfully proved that the task relation holds between shifted world states:
- Added `shifted_flag_retract_lt` lemma: if s < t in the shifted domain, then their chain retracts are ordered
- Added `shifted_flag_retract_le` lemma: monotonicity for the non-strict case
- Proved `respects_task` using:
  - For t - s > 0: Use `CanonicalMCS.canonicalR_of_lt` with the retract ordering
  - For t - s = 0: States are equal by reflexivity

### Blocked: `convex`

The domain `ShiftedFlagTimeDomain F center` is the image of a discrete chain embedded into Rat. This is NOT convex:
- A discrete chain has gaps between consecutive elements
- The embedding maps these to rationals, but points between the images are NOT in the domain
- Example: if chain elements map to 0.1 and 0.3, the value 0.2 is NOT in the domain

**This sorry is mathematically unprovable with the current approach.**

### Blocked: `shifted_truth_lemma`

This depends on having a valid WorldHistory, which requires:
1. Domain predicate
2. Convexity (blocked)
3. State assignment
4. Task relation respect (now proven)

Since convexity cannot be proven, the WorldHistory is ill-formed, and the truth lemma cannot be stated properly.

## Architectural Analysis

### The Fundamental Problem

The `valid` definition requires:
- D : Type with AddCommGroup structure
- WorldHistory with convex domain

The natural domain for a chain is:
- ChainFMCSDomain F (subtype of CanonicalMCS)
- Not an AddCommGroup

Approaches attempted:
1. **Embedding into Rat** (this file): Domain is non-convex
2. **Extending to all of Rat**: Breaks forward_G/backward_H (G is irreflexive)
3. **Using FlagTimeDomain subtype**: Not an AddCommGroup

### Alternative Paths

1. **Weaken WorldHistory.convex**: Major semantic change
2. **Use different validity definition**: Not standard
3. **Bridge satisfies_at to truth_at directly**: The FlagBFMCS_completeness is sorry-free with satisfies_at; find a different bridge

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSRatBundle.lean`
  - Added `shifted_flag_retract_lt` theorem
  - Added `shifted_flag_retract_le` theorem
  - Proved `respects_task` field of `shiftedFlagWorldHistory`

## Remaining Sorries

| Location | Line | Issue | Status |
|----------|------|-------|--------|
| `shiftedFlagWorldHistory.convex` | 364 | Non-convex domain | **Blocked** |
| `shifted_truth_lemma` | 438 | Depends on valid WorldHistory | **Blocked** |

## Recommendations

1. **Do not merge this approach as-is** - The fundamental issue remains
2. **Consider alternative approaches**:
   - Prove a bridge lemma between `satisfies_at` (FlagBFMCS) and `¬valid` directly
   - Modify the `valid` definition to allow non-convex domains
   - Use a different time domain structure
3. **Document the gap** - The mathematical insight is valuable: discrete chain embeddings create non-convex domains

## Verification

- Build passes: Yes
- Sorries in modified file: 2 (down from 3)
- Total sorries in Theories/: 329
- Axioms in Theories/: 11
