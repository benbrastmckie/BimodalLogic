# Implementation Summary: Task 48 Plan v5 (Partial)

## Status: PARTIAL

## Summary

Attempted to implement the fuel-based recursion approach for removing the sorry in `restricted_forward_chain_iter_F_witness`. The implementation is PARTIAL due to a fundamental issue with the fuel bound invariant.

## What Was Done

1. **Added `restricted_forward_chain_iter_F_witness_persistence`**: A new fuel-based helper theorem that uses well-founded recursion on `(d + fuel)` as the termination measure.

2. **Restructured proof approach**:
   - Base case (d >= closure_F_bound phi): Derives contradiction since iter_F d psi would have F-nesting depth exceeding the max in deferralClosure
   - Inl case (depth decrease): Recursive call with d-1, same fuel - measure decreases
   - Inr case (persistence): Recursive call with same d, fuel-1 - measure decreases

3. **Updated wrapper theorem**: `restricted_forward_chain_iter_F_witness` now calls the fuel-based helper with `fuel = closure_F_bound phi`

## Blocker Discovered

The fuel-based approach as designed in the research has a fundamental issue:

**Problem**: In the inr case (persistence), when `fuel = fuel' + 1`:
- We have `fuel >= closure_F_bound phi`
- After decreasing fuel to `fuel'`, we need `fuel' >= closure_F_bound phi` for the recursive call
- But `fuel' = fuel - 1 >= closure_F_bound phi - 1`, which is NOT `>= closure_F_bound phi`

The fuel bound invariant weakens by 1 each time we take an inr step. After at most `closure_F_bound phi` inr steps, we'd have fuel = 0 and couldn't make progress.

**Key insight missed by research**: The fuel bound (`d + fuel >= closure_F_bound phi` or `fuel >= closure_F_bound phi`) cannot be maintained through multiple inr steps. The research assumed the bound would help derive a contradiction at fuel = 0, but:
- In the inl case, d decreases toward d=1 (success)
- In the inr case, d stays same, fuel decreases
- If we keep hitting inr, fuel reaches 0 while d is still < closure_F_bound phi
- At this point, we can neither derive contradiction (d < bound) nor recurse (fuel = 0)

## What Works

- The base case (d >= bound) correctly derives contradiction via `iter_F_not_mem_deferralClosure`
- The inl case (depth decrease) correctly handles the d=1 success case and recursive case
- The termination measure `d + fuel` correctly decreases in both cases
- Build succeeds with `lake build`

## What Doesn't Work

- The inr case with `fuel = succ fuel'` cannot satisfy the fuel bound invariant for the recursive call
- A sorry remains in this case

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`: Added `restricted_forward_chain_iter_F_witness_persistence` with sorry in inr.succ case

## Sorry Count

- Before: 3 sorries in SuccChainFMCS.lean (2 deprecated, 1 in iter_F_witness)
- After: 3 sorries in SuccChainFMCS.lean (2 deprecated, 1 in persistence helper)
- Net change: 0 (sorry moved but not removed)

## Recommendations for Resolution

1. **Lexicographic recursion**: Use `WellFounded.prod_lex` on `(closure_F_bound phi - d, fuel)` where:
   - Inl decreases first component (more significant)
   - Inr decreases second component
   - This avoids the bound invariant issue

2. **Different formulation**: Track "F-level" explicitly - how many F-layers wrap the innermost formula. Persistence at the same level can only happen finitely often due to deferralClosure being finite.

3. **Pigeonhole argument**: After `|deferralClosure phi|` persistence steps at the same d, some formula must repeat, giving a cycle that can be exploited for contradiction.

## Verification Results

```
Build: PASSED (lake build succeeds)
Sorry count: UNCHANGED (3 sorries)
New axioms: NONE
```
