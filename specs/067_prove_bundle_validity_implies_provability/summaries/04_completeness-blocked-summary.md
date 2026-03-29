# Implementation Summary: Task 67 - Plan 04 Bypass Z-chain Approach

**Task**: 67 - prove_bundle_validity_implies_provability
**Plan**: 04_bypass-z-chain-plan.md
**Status**: BLOCKED
**Session**: sess_1774764493_f13c43
**Date**: 2026-03-28

## Summary

Implementation of Plan 04 is blocked due to a fundamental gap discovered during Phase 1. The plan's approach of building a `DeferralRestrictedSerialMCS` from a consistent set containing `neg(phi)` requires `F_top` and `P_top` to be in `deferralClosure(phi)`, which is NOT true for general formulas phi.

## Technical Analysis

### The Plan's Approach
1. Extend `{neg(phi)}` to `DeferralRestrictedMCS` via `deferral_restricted_lindenbaum`
2. Show `F_top` and `P_top` are in this extension (to get `DeferralRestrictedSerialMCS`)
3. Apply `build_restricted_tc_family` to get family-level temporal coherence
4. Use restricted truth lemma at position 0
5. Wire to completeness

### The Blocking Issue

Step 2 fails for general phi. The analysis shows:

1. **Definition of F_top**: `F_top = F(neg bot) = some_future (neg bot)`

2. **Theorem**: `some_future_in_deferralClosure_is_in_closureWithNeg` (SubformulaClosure.lean:919)
   - If `F(chi) ∈ deferralClosure(phi)`, then `F(chi) ∈ closureWithNeg(phi)`

3. **Definition of closureWithNeg**: Contains only subformulas of phi and their negations

4. **Conclusion**: `F_top ∈ deferralClosure(phi)` requires phi to contain `F(neg bot)` as a subformula or `G(bot)` (the negation)

For general formulas like `phi = box p`, the deferralClosure does NOT include `F_top`.

### Why This Matters

- `DeferralRestrictedSerialMCS` structure requires `F_top ∈ world` and `P_top ∈ world`
- The `theorem_in_drm` lemma only guarantees theorems are in DRM IF they are in the closure
- Since `F_top ∉ deferralClosure(phi)` for general phi, we cannot construct `DeferralRestrictedSerialMCS`
- Without `DeferralRestrictedSerialMCS`, we cannot use `build_restricted_tc_family`
- Without `RestrictedTemporallyCoherentFamily`, we cannot prove the restricted truth lemma

## Verification Results

```
Build status: PASSED
Sorry count in Completeness.lean: 2 (unchanged)
  - Line 126: dense_completeness_fc (out of scope)
  - Line 232: bundle_validity_implies_provability (target sorry, blocked)
```

## Potential Resolutions

1. **Extend deferralClosure Definition**
   - Add seriality formulas (F_top, P_top) to deferralClosure by default
   - Requires significant infrastructure changes and re-proving many lemmas

2. **Restrict Completeness Theorem**
   - Prove completeness only for "seriality-compatible" formulas
   - Definition: phi is seriality-compatible iff `F_top ∈ deferralClosure(phi)`
   - This would be a partial result, not full completeness

3. **Alternative Proof Path**
   - Find a way to prove completeness without requiring `DeferralRestrictedSerialMCS`
   - Possibly use bundle-level coherence with a modified truth lemma
   - Would require proving that bundle-level coherence somehow suffices

4. **Henkin-style Fair Scheduling (Major Redesign)**
   - Redesign `omega_chain_forward` to resolve F-obligations fairly
   - Would allow Z_chain_forward_F to be proven
   - Significant effort, may introduce new complications

## Artifacts

- **Plan updated**: `plans/04_bypass-z-chain-plan.md` - Phase 1 marked BLOCKED with detailed analysis
- **Summary**: This file

## Files Examined

| File | Purpose | Finding |
|------|---------|---------|
| `Completeness.lean` | Target sorry | Lines 126, 232 have sorries |
| `RestrictedMCS.lean` | Infrastructure | `theorem_in_drm` requires formula in closure |
| `SubformulaClosure.lean` | Closure definitions | `some_future_in_deferralClosure_is_in_closureWithNeg` is the blocking lemma |
| `SuccChainFMCS.lean` | Chain construction | Requires `DeferralRestrictedSerialMCS` with F_top |

## Conclusion

The Plan 04 approach cannot succeed for general formulas without either extending the closure definition or finding an alternative proof path. The fundamental mathematical requirement (F_top must be in a bounded closure) conflicts with the closure being formula-specific.

This is not an implementation bug but a gap in the theoretical approach that was not identified in the research phase.
