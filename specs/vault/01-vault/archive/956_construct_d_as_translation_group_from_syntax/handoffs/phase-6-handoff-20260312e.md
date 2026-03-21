# Handoff: Phase 6 Strict Density - Iteration 3 Analysis

**Task**: 956
**Session**: sess_1773337195_0a1a7c (Iteration 3)
**Phase**: 6 (Cantor Isomorphism Application)
**Status**: Analysis complete, implementation path identified

## Immediate Next Action

Implement a well-founded iteration helper using `Finset.strongInductionOn` for `density_frame_condition_strict`. The helper should:

1. Define `candidateFormulas M M' anchor : Finset Formula` as formulas phi where G(phi) in M' and phi not in M
2. Iterate: each step either returns strict witness OR reduces candidate set
3. Use `Finset.strongInductionOn` for termination

## Current State

**Files**:
- `DensityFrameCondition.lean`: 10 sorries (lines 504, 585, 611, 639, 655, 662, 770, 1181, 1285, 1363)
- `CantorApplication.lean`: 3 sorries (lines 210, 269, 316)

**Build**: `lake build` passes with warnings

## Key Decisions Made

1. **All sorries are reflexive M/M' cases**: When the constructed witness V ends up equivalent to an endpoint (V ~ M' or W ~ M), the proof can't show strictness directly.

2. **Mathematical solution confirmed**: Well-founded iteration on `candidateFormulas` shrinks the set each step. Research-041 established Pattern B (Finset.strongInduction) as the strongest approach.

3. **Direct proofs insufficient**: Attempted to prove individual sorries directly but the reflexive cases fundamentally require iteration to find a witness outside the equivalence class.

## What NOT to Try

1. **Direct proof of reflexive cases**: Spent significant time trying to prove `not CanonicalR M' V` when M' is reflexive. The issue is that V might legitimately be equivalent to M' when built from GContent(M).

2. **Simple seriality escape**: Using seriality to get a future doesn't help if the future is also in the same equivalence class.

3. **Formula-by-formula case analysis**: Too many sub-cases; the iteration approach is cleaner.

## Critical Context

**Key Mathlib tools**:
- `Finset.strongInductionOn`: Strong induction on finite set cardinality
- `toAntisymmetrization_lt_toAntisymmetrization_iff`: Quotient strict order = preorder strict order

**Existing helpers**:
- `irreflexive_mcs_has_strict_future` (line 1397): Works when M is NOT reflexive
- `candidateDistinguishing` (line 1426): Candidate formula set definition exists but not as Finset

**Pattern from research-041**:
```lean
-- Each iteration either:
--   (a) Returns strict witness (success)
--   (b) Consumes a candidate formula (measure decreases)
-- By Finset.strongInductionOn, terminates
```

## References

- Plan: `specs/956.../plans/implementation-017.md` (Phase 6)
- Research: `specs/956.../reports/research-041.md` (Pattern comparison)
- Context index query: `.claude/context/project/lean4/patterns/tactic-patterns.md`

## Technical Notes

The iteration works because:
1. `candidateFormulas M M'` is finite (bounded by subformula count)
2. Each non-strict witness "uses up" at least one candidate formula
3. When candidate set is empty, CanonicalR(M', M) holds, contradicting hypothesis
