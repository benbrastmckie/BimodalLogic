# Phase 6 Handoff: Strict Density Iteration (Iteration 4)

**Date**: 2026-03-12
**Session**: sess_1773376107_8hwl1r
**Status**: Phase 6b PARTIAL

## Immediate Next Action

Implement `fuel_suffices` theorem using `Nat.strongRecOn` on `subformulaClosure.card` to provide the termination measure for strict density iteration.

## Current State

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`
**Lines modified**: 862-924 (replaced line 865 sorry with iteration pattern)
**New sorries**: Lines 894, 921 (iteration cases where U ~ M or U1 ~ M)

**Sorry Count**:
- DensityFrameCondition.lean: 14 sorries
- CantorApplication.lean: 3 sorries
- Total: 17 (+1 from before)

## Key Decisions Made

1. **Iteration pattern demonstrated**: Line 865 sorry replaced with structured proof that extracts new distinguishing formula from `h_M'_V` and applies Case A
2. **Case splits work correctly**: When G(psi) in M, contradiction via psi in GContent(M) subset V. When G(psi) not in M, apply Case A.
3. **New iteration cases exposed**: Lines 894, 921 are structurally identical to original problem but with different formula (psi instead of delta)

## What NOT to Try

1. **Manual case-by-case resolution**: Each sorry resolves to another iteration case, leading to infinite regress
2. **Proving termination via direct Lean recursion**: Termination checker fails without explicit measure
3. **Using V reflexivity argument**: V ~ M and M reflexive does NOT imply phi in M => phi in V

## Critical Context

### Iteration Pattern (Proven Structure)

At each iteration with M < M' strictly and witness W ~ M:
1. Extract psi from `h_M'_W : ¬CanonicalR M' W` with G(psi) ∈ M' and psi ∉ W
2. If G(psi) ∈ M: psi ∈ GContent(M) ⊆ W (by h_R_MW), contradiction with psi ∉ W
3. If G(psi) ∉ M: Apply Case A with psi to get new witness U with neg(psi) ∈ U
4. Check U's strictness; if U ~ M, iterate with psi as new anchor formula

### Termination Argument

Each iteration:
- Uses a formula from GContent(M') that is NOT in M (specifically G(psi) ∉ M)
- This psi must be a subformula of any formula in the original GContent(M')
- Since `subformulaClosure(anchor)` is finite, at most `card` iterations before success

### Goal State at New Sorries

**Line 894** (U ~ M case):
```lean
h_UM : CanonicalR U M     -- U sees M back (U ~ M)
h_not_M'U : ¬CanonicalR M' U  -- M' doesn't see U (strict from M' side)
h_neg_psi_U : psi.neg ∈ U  -- U has neg(psi)
```

**Line 921** (U1 ~ M case):
```lean
h_U₁M : CanonicalR U₁ M    -- U1 sees M back (U1 ~ M)
h_not_M'U₁ : ¬CanonicalR M' U₁  -- M' doesn't see U1 (strict from M' side)
h_F_neg_U₁ : psi.neg.some_future ∈ U₁  -- U1 has F(neg(psi))
```

Both cases need: extract NEW formula from ¬CanonicalR M' U (or U1) and iterate.

## Recommended Implementation

```lean
/-- Iteration termination measure: cardinality of candidate formulas. -/
def iterMeasure (M' : Set Formula) (anchor : Formula) : Nat :=
  (subformulaClosure anchor ∩ GContent M').toFinset.card

/-- Sufficient fuel exists for strict density iteration. -/
theorem fuel_suffices (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : ¬CanonicalR M' M)
    (anchor : Formula)
    (h_anchor : GContent M' ⊆ subformulaClosure anchor) :
    ∃ fuel, (strictDensityIterWithFuel M M' h_mcs h_mcs' h_R h_not_R' fuel).isSome := by
  apply Nat.strongRecOn (iterMeasure M' anchor)
  intro n ih
  -- Case analysis: either witness is strict, or we iterate with decreased measure
  sorry
```

## References

- **Plan**: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-023.md`
- **Research**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-045.md`
- **Summary**: `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-20260312-iter4.md`
- **SubformulaClosure**: `Theories/Bimodal/Syntax/SubformulaClosure.lean`

## Build Status

```bash
lake build  # Passes with 17 sorry warnings
```
