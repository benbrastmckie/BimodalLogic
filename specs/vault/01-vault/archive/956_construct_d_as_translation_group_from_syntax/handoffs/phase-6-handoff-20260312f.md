# Handoff: Phase 6 Strict Density - Iteration 4 Progress

**Task**: 956
**Session**: sess_1773337195_0a1a7c (Iteration 4)
**Phase**: 6 (Cantor Isomorphism Application)
**Status**: Implementation attempted, new approach needed

## Immediate Next Action

Implement iteration using **Nat.strongRecOn** with subformula count as measure, avoiding Finset decidability issues:

```lean
-- Use Nat measure instead of Finset
def candidateCount (M M' : Set Formula) (anchor : Formula) : Nat :=
  -- Theoretical count of distinguishing formulas bounded by anchor's subformula count
  anchor.subformulaCount

theorem density_frame_condition_strict_iter
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M)
    (fuel : Nat)
    (h_fuel : candidateCount M M' anchor ≤ fuel) :
    ∃ W, SetMaximalConsistent W ∧ ... := by
  induction fuel with
  | zero => -- base case: contradiction (0 candidates but ¬CanonicalR M' M)
  | succ n ih => -- inductive case: try density, if not strict, recurse with n
```

## Current State

**Files**:
- `DensityFrameCondition.lean`: 10 sorries (unchanged)
- `CantorApplication.lean`: 3 sorries (unchanged)

**New additions in iteration 4**:
- Added `import Bimodal.Syntax.SubformulaClosure`
- Added `attribute [local instance] Classical.propDecidable`
- Updated documentation for well-founded approach

**Build**: `lake build` passes with warnings (sorries)

## Key Decisions Made

1. **Finset.filter requires decidability**: Cannot use `Finset.filter (fun phi => G(phi) ∈ M' ∧ phi ∉ M)` directly without decidable membership in arbitrary Set Formula.

2. **M is NOT reflexive in Case B**: The presence of `G(delta) ∈ M` with `delta ∉ M` proves M's non-reflexivity. This is useful but doesn't directly help with M'-V strictness.

3. **Nat recursion alternative**: Use subformula count as Nat bound, avoiding Finset decidability entirely.

## What NOT to Try

1. **Direct Finset.filter on Set membership**: Decidability issues
2. **Direct proof of reflexive cases**: Mathematically impossible without iteration
3. **Simple Classical.em on individual goals**: Doesn't provide new distinguishing formulas

## Critical Context

**Mathematical structure of stuck cases**:
- Goal: `¬CanonicalR M' V` when we have `CanonicalR V M'`
- M' is reflexive, V constructed from GContent(M)
- `delta ∈ V`, so `neg(delta) ∉ V`
- `G(neg(delta)) ∉ M'` (since M' reflexive with `delta ∈ M'`)
- No direct contradiction available

**Iteration escape**:
- If CanonicalR M' V, then V ~ M' in quotient
- From `¬CanonicalR V M`, there exists gamma: `G(gamma) ∈ V`, `gamma ∉ M`
- This gamma has `G(gamma) ∈ M'` (since V ~ M')
- gamma ≠ delta (delta was absorbed)
- Use gamma for next iteration

## References

- Plan: `specs/956.../plans/implementation-017.md` (Phase 6)
- Research: `specs/956.../reports/research-041.md` (Pattern comparison)
- Summary: `specs/956.../summaries/implementation-summary-20260312f.md` (This iteration)

## Implementation Sketch

```lean
-- Alternative: fuel-based with sufficiency proof (Pattern C)
def strictDensityWithFuel (M M' : Set Formula) ... (fuel : Nat) :
    Option (∃ W, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' ∧
           ¬CanonicalR W M ∧ ¬CanonicalR M' W) :=
  match fuel with
  | 0 => none
  | n + 1 =>
    let W := density_frame_condition M M' ...
    if strict W then some ⟨W, ...⟩
    else
      -- V ~ M', find new distinguishing formula gamma from ¬CanonicalR V M
      -- recurse with (M, V, n) or (M, newTarget, n)
      strictDensityWithFuel M newTarget ... n

-- Then prove: ∃ fuel, (strictDensityWithFuel M M' h_mcs h_mcs' h_R h_not_R' fuel).isSome
-- This follows from subformula count bound
```
