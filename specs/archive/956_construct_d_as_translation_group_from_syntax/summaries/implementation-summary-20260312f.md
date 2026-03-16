# Implementation Summary: Task #956 - Session F (Iteration 4)

**Task**: 956 - Construct D as translation group from syntax
**Session**: sess_1773337195_0a1a7c (Iteration 4)
**Date**: 2026-03-12
**Status**: Implementation attempted, sorries remain

## Objectives

- [x] Attempt well-founded iteration implementation using Finset.strongInductionOn
- [x] Add SubformulaClosure import for Finset operations
- [x] Add Classical decidability attribute
- [ ] Eliminate sorries in density_frame_condition_strict
- [ ] Eliminate sorries in CantorApplication

## Summary

This iteration attempted to implement the well-founded iteration approach described in the handoff. Key activities:

1. **Added SubformulaClosure import**: Enables Finset operations on formula subsets
2. **Added Classical.propDecidable**: Required for set membership decidability
3. **Attempted Finset.filter approach**: Discovered fundamental decidability issues
4. **Analyzed reflexive MCS cases in depth**: Confirmed mathematical approach is sound but implementation requires more sophisticated handling

## Files Modified

| File | Changes |
|------|---------|
| DensityFrameCondition.lean | Added SubformulaClosure import, Classical.propDecidable attribute, well-founded iteration documentation |

## Sorries Remaining

| File | Count | Line Numbers |
|------|-------|--------------|
| DensityFrameCondition.lean | 10 | 505, 586, 612, 640, 656, 663, 771, 1182, 1286, 1364 |
| CantorApplication.lean | 3 | 210, 269, 316 |
| **Total** | 13 | - |

## Key Findings

### Finding 1: Decidability Challenge
Using `Finset.filter` with predicates involving `Set Formula` membership requires decidability. The approach works with `Classical.propDecidable` but the iteration logic itself is complex.

### Finding 2: Reflexive MCS Mathematical Structure
When M' is reflexive and V is constructed from GContent(M):
- `delta ∈ V` (by construction)
- `neg(delta) ∉ V` (by V's consistency)
- If `G(neg(delta)) ∈ M'`, we'd get contradiction, but...
- `G(neg(delta)) ∉ M'` (since M' is reflexive and `delta ∈ M'`)

This confirms no direct proof exists - iteration IS required.

### Finding 3: Iteration Key Insight
When V ~ M' (both CanonicalR directions hold):
- From `¬CanonicalR V M`, there exists gamma with `G(gamma) ∈ V` and `gamma ∉ M`
- Since V ~ M', this gamma also has `G(gamma) ∈ M'`
- So gamma is a NEW distinguishing formula for iteration
- But gamma ≠ delta (delta is "absorbed" by V)

This confirms the measure decreases, but implementing the iteration recursion is non-trivial.

## Technical Discoveries

1. **M is NOT reflexive in Case B**: `G(delta) ∈ M` but `delta ∉ M` proves M is not reflexive. The `irreflexive_mcs_has_strict_future` lemma applies to M but not M'.

2. **Mutual canonicalR implies reflexivity**: When `CanonicalR M V` and `CanonicalR V M`, Temporal 4 closure makes M reflexive. Used in unreachable case proofs.

3. **Build passes with sorries**: Both DensityFrameCondition and CantorApplication compile correctly with the current sorry structure.

## What NOT to Try (Updated)

- **Simple decidability fix**: Classical.propDecidable doesn't make Finset.filter trivial to use
- **Formula-by-formula case split**: The iteration approach is more systematic
- **Direct proof of reflexive cases**: Mathematically impossible without iteration

## Next Steps

1. Implement iteration using Nat recursion instead of Finset.strongInductionOn (avoid decidability issues)
2. Define measure as subformula count bound
3. Use well-founded recursion on natural number measure
4. Or: restructure to use a fuel-based approach with fuel sufficiency proof

## Handoff

Continue from the analysis in this summary. The mathematical solution is confirmed - implementation requires either:
- Nat.strongRecOn with formula count measure
- Fuel-based approach (Pattern C from research-041)

## Build Status

```
lake build: Build completed successfully (758 jobs)
```
