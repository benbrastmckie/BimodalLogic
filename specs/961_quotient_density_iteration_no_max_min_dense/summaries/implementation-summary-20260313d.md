# Implementation Summary: Task #961 (Iteration 2)

**Task**: 961 - quotient_density_iteration_no_max_min_dense
**Date**: 2026-03-13
**Status**: BLOCKED (requires user decision)
**Session**: sess_1773629422_a8c4d1
**Plan**: implementation-005.md (v005)

## Summary

Continued analysis from iteration 1. Attempted Option B (non-constructive existence proof) and Option C (quotient-level reasoning). Both approaches reduce to the same fundamental issue: proving existence of strict intermediates when the source is reflexive.

## Analysis Performed

### Option B (Non-constructive existence)

Attempted to prove `strict_intermediate_exists` using `Classical.byContradiction`:
1. Assume no strict intermediate exists
2. Then all density intermediates are equivalent to one endpoint
3. But `density_frame_condition_reflexive_source` says there EXISTS W with strictness from target
4. **Blocker**: W from `density_frame_condition_reflexive_source` provides `¬CanonicalR q W` (strict from target) but NOT `¬CanonicalR W p` (strict from source)
5. If `CanonicalR W p` holds, then `[W] = [p]`, so W doesn't give a strict intermediate

### Option C (Quotient-level reasoning)

Attempted to prove `¬CovBy` using `denselyOrdered_iff_forall_not_covBy`:
- This reduces to proving existence of strict intermediate between any [p] < [q]
- Same fundamental blocker as Option B

### Traced Case A Construction

Detailed analysis of the density_frame_condition Case A construction:
- V constructed via double-density contains `neg(delta)` where delta is the distinguishing formula
- For `¬CanonicalR V p`, we need `GContent(V) ⊄ p`, i.e., some `psi ∈ GContent(V)` with `psi ∉ p`
- delta ∉ p (given), so if `G(delta) ∈ V`, then `delta ∈ GContent(V)` and we'd have strictness
- **Finding**: `G(delta)` might or might not be in V; the MCS completion doesn't guarantee it
- **Conclusion**: Case A does NOT guarantee strictness from source side

## Root Cause (Confirmed)

The fundamental mismatch identified in iteration 1 is confirmed:

1. **`density_frame_condition`** (used by timeline construction):
   - Case B1 can return W = M' (endpoint) when M' is reflexive
   - Even Case A/B2 may return W ~ M (equivalent to source)

2. **`density_frame_condition_reflexive_source`** (provides target strictness):
   - Guarantees `¬CanonicalR M' W` (strict from target)
   - Does NOT guarantee `¬CanonicalR W M` (strict from source)

3. **Missing**: A lemma `density_frame_condition_double_strict` that gives:
   - `CanonicalR M W`
   - `CanonicalR W M'`
   - `¬CanonicalR M' W` (strict from target)
   - `¬CanonicalR W M` (strict from source)

Such a lemma appears to be **FALSE** in general: the Case A construction can produce W ~ M.

## Options to Complete (Updated)

### Option A: Modify DenseTimeline.lean (RECOMMENDED)

Modify `densityIntermediateMCS` to use a strict construction when the source is reflexive:
```lean
noncomputable def densityIntermediateMCS
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : ¬CanonicalR b.mcs a.mcs) : Set Formula :=
  -- Check if source is reflexive
  if h_refl : CanonicalR a.mcs a.mcs then
    -- Use strict construction that avoids returning b
    (density_frame_condition_reflexive_source a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R h_refl).choose
  else
    -- Use standard density
    (density_frame_condition a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R).choose
```

**Pros**:
- Direct fix at the source of the problem
- Timeline construction will add strict intermediates when source is reflexive
- Existing proofs using `density_frame_condition_reflexive_source` become directly applicable

**Cons**:
- Modifies core infrastructure (DenseTimeline.lean)
- Need to update specs for `densityIntermediateMCS` and related lemmas

### Option B: Well-founded iteration proof

Prove termination of the iteration using a well-founded measure (e.g., stage number, formula complexity).

**Blocker**: Each iteration produces W with strictness from target only. Even with well-founded recursion, we can't prove the iteration eventually gives strictness from source.

### Option C: Alternative mathematical approach

Find a completely different proof strategy that doesn't require strict intermediate construction.

**Status**: No viable alternative found. DenselyOrdered, NoMaxOrder, NoMinOrder all require showing existence of strict witnesses.

## Recommendation

**Option A is the only viable path forward.**

The other options are blocked by the fundamental property: `density_frame_condition_reflexive_source` (and Case A construction generally) provides strictness from the TARGET but not from the SOURCE. This is a property of the mathematical construction, not a proof bug.

## Sorries Remaining (5)

| Line | Description | Root Cause |
|------|-------------|------------|
| 367 | strict_intermediate_exists: c ~ p case | Need strictness from source, but only have strictness from target |
| 386 | strict_intermediate_exists: d ~ p nested case | Same |
| 398 | strict_intermediate_exists: d ~ q nested case | Same |
| 537 | NoMaxOrder: reflexive case | Depends on strict_intermediate_exists |
| 596 | NoMinOrder: reflexive case | Depends on strict_intermediate_exists |

## Files Analyzed

- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean`

## Next Steps (If Option A Approved)

1. Create follow-up task to modify DenseTimeline.lean
2. Update `densityIntermediateMCS` to use reflexive-source variant
3. Add corresponding spec lemmas for the strict variant
4. Resume task 961 implementation after DenseTimeline update

## Artifacts

- Plan: `specs/961_quotient_density_iteration_no_max_min_dense/plans/implementation-005.md`
- Previous Summary: `specs/961_quotient_density_iteration_no_max_min_dense/summaries/implementation-summary-20260313c.md`
- This Summary: `specs/961_quotient_density_iteration_no_max_min_dense/summaries/implementation-summary-20260313d.md`
