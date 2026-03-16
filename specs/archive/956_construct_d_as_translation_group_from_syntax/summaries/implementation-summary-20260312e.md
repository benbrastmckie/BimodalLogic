# Implementation Summary: Task #956 - Session E (Iteration 3)

**Task**: 956 - Construct D as translation group from syntax
**Session**: sess_1773337195_0a1a7c (Iteration 3)
**Date**: 2026-03-12
**Status**: Analysis phase complete, implementation path confirmed

## Objectives

- [x] Analyze remaining 13 sorries in Phase 6
- [x] Attempt direct proofs for simpler cases
- [x] Confirm implementation approach for reflexive MCS cases
- [x] Write handoff with clear next steps

## Summary

This iteration focused on deep analysis of the remaining sorries in `DensityFrameCondition.lean` (10) and `CantorApplication.lean` (3). The analysis confirmed that:

1. **All sorries are reflexive MCS cases**: When the constructed witness V ends up equivalent to an endpoint (V ~ M' or W ~ M in the quotient), direct proofs cannot establish strictness.

2. **Direct proofs are insufficient**: Attempted multiple approaches:
   - Formula membership analysis
   - Contradiction via consistency
   - Using existing helper lemmas

   None work because the reflexive equivalence fundamentally allows V ~ M'.

3. **Well-founded iteration is required**: The mathematical solution (Pattern B from research-041) uses `Finset.strongInductionOn` on the set of candidate distinguishing formulas. Each iteration either succeeds or shrinks the candidate set.

## Files Modified

None - this was an analysis iteration.

## Files Analyzed

| File | Sorries | Root Cause |
|------|---------|------------|
| DensityFrameCondition.lean | 10 | Reflexive M' cases (lines 504, 585, 611, 639, 655, 662, 770, 1181, 1285, 1363) |
| CantorApplication.lean | 3 | Depends on strict density (lines 210, 269, 316) |

## Key Findings

### Finding 1: Sorry Structure
All 10 DensityFrameCondition sorries follow this pattern:
- Constructed witness V from `{formula} ∪ GContent(M)`
- Need to show V is STRICTLY between M and M'
- When M' is reflexive, V might be equivalent to M' in quotient

### Finding 2: CantorApplication Dependencies
The 3 CantorApplication sorries at lines 210, 269, 316 all depend on having a `density_frame_condition_strict` that actually returns strict witnesses. Once DensityFrameCondition is complete, these should resolve.

### Finding 3: Implementation Path
Pattern B from research-041 provides the solution:
```lean
def candidateFormulas (M M' : Set Formula) (anchor : Formula) : Finset Formula :=
  (anchor.subformulas.toFinset).filter (fun phi => G(phi) ∈ M' ∧ phi ∉ M)

-- Iteration:
-- Each step either returns strict witness OR reduces candidateFormulas
-- By Finset.strongInductionOn, terminates
```

## Artifacts Created

| Path | Type | Description |
|------|------|-------------|
| `handoffs/phase-6-handoff-20260312e.md` | Handoff | Next iteration instructions with implementation approach |
| `summaries/implementation-summary-20260312e.md` | Summary | This file |

## Next Steps

1. **Implement `candidateFormulas` as Finset**: Convert existing `candidateDistinguishing` (Set Formula) to Finset using anchor subformulas
2. **Create iteration helper**: Use `Finset.strongInductionOn` for termination
3. **Prove iteration measure decreases**: Each non-strict result consumes a candidate
4. **Update `density_frame_condition_strict`**: Use iteration helper

## Blockers

None - the path is clear. Implementation requires well-founded recursion boilerplate.

## Technical Notes

- The `toAntisymmetrization_lt_toAntisymmetrization_iff` lemma simplifies quotient reasoning to preorder reasoning
- `Finset.strongInductionOn` is the key Mathlib tool for termination
- Existing `candidateDistinguishing` definition at line 1426 can be adapted to Finset
