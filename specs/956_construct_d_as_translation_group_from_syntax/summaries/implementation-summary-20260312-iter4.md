# Implementation Summary: Task #956 - Iteration 4

**Date**: 2026-03-12
**Session**: sess_1773376107_8hwl1r
**Status**: PARTIAL - Iteration pattern demonstrated, full machinery needed

## Summary

Analyzed and partially resolved the line 865 sorry in DensityFrameCondition.lean by demonstrating the iteration pattern for strict density proofs. The core blocking issue requires well-founded recursion on subformula closure cardinality.

## Changes Made

### DensityFrameCondition.lean (lines 862-924)

Replaced the sorry at line 865 (Case A, V ~ M, M reflexive) with a more structured proof that:

1. **Extracts distinguishing formula from h_M'_V**: When M' doesn't see V, extract psi with G(psi) in M' and psi not in V

2. **Case splits on G(psi) in M**:
   - If G(psi) in M: psi in GContent(M) subset V (by h_R_MV), contradicting psi not in V
   - If G(psi) not in M: Apply Case A construction with psi

3. **Case A with psi**:
   - Get U with neg(psi) in U and CanonicalR M U
   - Check U's relation to M' via linearity
   - Handle subcases for strictness

4. **New sorries introduced** at lines 894 and 921 for iteration cases where U ~ M or U1 ~ M

## Sorry Count Change

| File | Before | After | Change |
|------|--------|-------|--------|
| DensityFrameCondition.lean | 13 | 14 | +1 |
| CantorApplication.lean | 3 | 3 | 0 |
| **Total** | 16 | 17 | +1 |

The +1 is expected: eliminating one sorry revealed additional iteration structure that requires the same machinery.

## Key Finding

The iteration pattern is now explicit:
1. Extract distinguishing formula from non-containment hypothesis
2. Apply Case A construction with new formula
3. Check strictness of result
4. If result is equivalent to M (U ~ M), iterate with the new formula

**Termination argument**: Each iteration uses a formula from `subformulaClosure(anchor)`. Since this set is finite, iteration terminates after at most `card + 1` steps.

## Blocking Issue

Implementing proper termination requires `Nat.strongRecOn` on `subformulaClosure.card` with:
- Proof that each iteration uses a formula from the closure
- Proof that repeated iterations cannot use the same formula
- Proper tracking of the decreasing measure across recursive calls

## Recommendations

1. **Implement `fuel_suffices` theorem**: Use `Nat.strongRecOn` with explicit fuel tracking
2. **Alternative**: Define a well-founded relation on (M, M', distinguishing formula set) triples
3. **Short-term fix**: Axiomatize strict density as a temporary measure (NOT recommended per proof-debt-policy)

## Files Modified

- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`

## Build Status

```
lake build  # Passes with 17 sorry warnings (14 in DensityFrameCondition, 3 in CantorApplication)
```

## Next Steps

1. Implement `fuel_suffices` using `Nat.strongRecOn` (Phase 6b completion)
2. Use result to eliminate all 14 DensityFrameCondition sorries (Phase 6d)
3. Wire up CantorApplication sorries (Phase 6d)
