# Implementation Summary: Task #962

**Task**: 962 - dense_timeline_strict_intermediate_reflexive_source
**Completed**: 2026-03-13
**Session**: sess_1773630312_d8e4f3
**Plan Version**: implementation-001.md

## Overview

Modified `densityIntermediateMCS` in `DenseTimeline.lean` to use the strict density variant (`density_frame_condition_reflexive_source`) when the source MCS is reflexive. This guarantees the intermediate is strictly ordered from the target (never equivalent to target in the quotient), providing infrastructure to unblock task 961.

## Changes Made

### Phase 1: Moved Strict Density Lemmas
- **From**: `CantorApplication.lean`
- **To**: `DensityFrameCondition.lean`
- **Lemmas moved**:
  - `G_F_neg_inconsistent` (private helper)
  - `density_frame_condition_caseA_strict`
  - `density_frame_condition_reflexive_source`

### Phase 2-3: Modified densityIntermediateMCS
- Updated definition to use conditional dispatch:
  ```lean
  if h_refl : CanonicalR a.mcs a.mcs then
    density_frame_condition_reflexive_source...
  else
    density_frame_condition...
  ```
- Updated `densityIntermediateMCS_spec` proof to handle both branches

### Phase 4: Added Strictness Lemmas
- `densityIntermediateMCS_strict_from_target`: Provides `negCanonicalR b.mcs (densityIntermediateMCS a b h_R h_not_R)` when source `a` is reflexive
- `densityIntermediatePoint_strict_from_target`: Same property lifted to StagedPoint level

### Phase 5-6: Verification
- All downstream code compiles (`lake build` passes)
- No new sorries introduced in modified files
- No new axioms introduced
- Pre-existing sorries in `CantorApplication.lean` (task 961 work) unchanged

## Files Modified

| File | Action |
|------|--------|
| `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` | Added 3 lemmas (G_F_neg_inconsistent, density_frame_condition_caseA_strict, density_frame_condition_reflexive_source) |
| `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` | Modified densityIntermediateMCS definition and spec; added 2 strictness lemmas |
| `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` | Removed moved lemmas (now imported from DensityFrameCondition) |

## New API

```lean
-- When source is reflexive, intermediate is strict from target
theorem densityIntermediateMCS_strict_from_target
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : negCanonicalR b.mcs a.mcs)
    (h_refl : CanonicalR a.mcs a.mcs) :
    negCanonicalR b.mcs (densityIntermediateMCS a b h_R h_not_R)

-- Same at StagedPoint level
theorem densityIntermediatePoint_strict_from_target
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : negCanonicalR b.mcs a.mcs)
    (stage : Stage)
    (h_refl : CanonicalR a.mcs a.mcs) :
    negCanonicalR b.mcs (densityIntermediatePoint a b h_R h_not_R stage).mcs
```

## Impact on Task 961

This task provides the infrastructure needed by task 961:
- The `strict_intermediate_exists` theorem in CantorApplication.lean can now use `densityIntermediateMCS_strict_from_target` when the source is reflexive
- This handles Case 2 (c ~ p implies p reflexive) of the strict intermediate proof
- The sorry at line 214+ of CantorApplication.lean becomes provable using the new lemmas

## Verification Checklist

- [x] `lake build` passes with no errors
- [x] No sorries in DenseTimeline.lean
- [x] No sorries in DensityFrameCondition.lean
- [x] No new axioms introduced
- [x] `densityIntermediateMCS_spec` signature unchanged
- [x] `densityIntermediatePoint_canonicalR_left/right` still work unchanged
- [x] CantorApplication.lean compiles and imports strict lemmas
- [x] Pre-existing sorry count unchanged (task 961 work)

## Session Progress

**Session: 2026-03-13, sess_1773630312_d8e4f3**
- Added: `G_F_neg_inconsistent` helper to DensityFrameCondition.lean
- Added: `density_frame_condition_caseA_strict` theorem to DensityFrameCondition.lean
- Added: `density_frame_condition_reflexive_source` theorem to DensityFrameCondition.lean
- Added: `densityIntermediateMCS_strict_from_target` theorem to DenseTimeline.lean
- Added: `densityIntermediatePoint_strict_from_target` theorem to DenseTimeline.lean
- Refactored: `densityIntermediateMCS` definition to use conditional dispatch
- Refactored: `densityIntermediateMCS_spec` proof to handle both branches
