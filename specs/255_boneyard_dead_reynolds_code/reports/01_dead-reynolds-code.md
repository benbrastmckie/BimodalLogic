# Research Report: Archive Dead Reynolds Code to Boneyard

**Task**: 255
**Session**: sess_1749054756_a3b2c1
**Date**: 2026-06-04

## Summary

Three code targets were identified for archival after task 202 completed the Reynolds model surgery pipeline. All are deprecated BX pipeline dead code. Analysis reveals a mixed picture: one file is already archived, one cannot be fully moved, and one section can be safely removed.

## File-by-File Analysis

### 1. ReynoldsModelSurgery.lean -- ALREADY IN BONEYARD

**Current location**: `Theories/Bimodal/Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean`
**Status**: Already archived (407 lines)
**Action required**: None. The file was already moved to Boneyard during a prior archival pass (visible in the BXPipelineDeadCode subdirectory). No active code imports it.

### 2. ReynoldsNoGaps.lean -- PARTIAL: Live definitions prevent full archival

**Current location**: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean`
**Size**: 331 lines
**Sorry count**: 1 (`no_gaps_prior` at line 287 -- marked mathematically false)

**Dead definitions** (zero references outside this file):
- `no_gaps_prior` (line 276) -- mathematically false as stated, sorry'd, deprecated
- `prior_implies_succ_archimedean` (line 299) -- depends on `no_gaps_prior`
- `one_class_implies_succ_archimedean` (line 321) -- wrapper around `prior_implies_succ_archimedean`
- `no_gaps_discrete_archimedean` (line 111) -- vacuous specialization, zero references
- `orbit_le_succ_closed` (line 133, private) -- helper for `gap_of_not_succ_archimedean`

**Live definitions** (referenced by GoodStructuresModelSurgery.lean):
- `gap_of_not_succ_archimedean` (line 158) -- used at GoodStructuresModelSurgery.lean:336
- `one_class_archimedean` (line 82) -- used at GoodStructuresModelSurgery.lean:338, 514
- `very_good_of_archimedean` (line 61) -- not directly referenced but supports `one_class_archimedean`

**Import sites**:
- `GoodStructuresModelSurgery.lean` (line 3) -- USES live definitions
- `ShiftAndGlue.lean` (line 2) -- DOES NOT USE any definitions (redundant import)

**Recommendation**: Cannot move the entire file to Boneyard. Instead:
1. Remove the 4 deprecated definitions (`no_gaps_prior`, `prior_implies_succ_archimedean`, `one_class_implies_succ_archimedean`, `no_gaps_discrete_archimedean`) from ReynoldsNoGaps.lean
2. Move those definitions to Boneyard (with `#exit` since they depend on deleted code)
3. Remove the redundant import from ShiftAndGlue.lean (it already gets ReynoldsNoGaps transitively via GoodStructuresModelSurgery)
4. Keep the live definitions (`gap_of_not_succ_archimedean`, `one_class_archimedean`, `very_good_of_archimedean`) in place

### 3. Transfer.lean `countermodel_discrete` (lines 1249-1298) -- LIVE REFERENCE BLOCKS REMOVAL

**Current location**: `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` lines 1249-1298
**Size**: ~50 lines (within 1300-line file)
**Sorry count**: 1 (line 1298, the `sorry` argument to `dd_countermodel_chronicle_discrete`)

**Reference**: `countermodel_discrete` is called at `Completeness.lean:165` in the general `completeness` theorem (not `completeness_discrete`). This is for the `FrameClass.Base` case where the discrete box-class MCS uses the BX pipeline path.

**The call chain**:
```
Completeness.lean:165 -> WeakCanonical.countermodel_discrete
  -> dd_countermodel_chronicle_discrete FrameClass.Base A h_mcs sorry ...
```

The general `completeness` theorem (Base frame class) still needs this path. The sorry here is structural: `FrameClass.Discrete <= FrameClass.Base` is unprovable, and this path was always sorry'd.

**Recommendation**: Can be moved to Boneyard, but requires creating a sorry stub in Transfer.lean to keep `Completeness.lean` compiling. Two options:

**Option A (preferred)**: Move `countermodel_discrete` to Boneyard, replace with a sorry stub in Transfer.lean:
```lean
theorem countermodel_discrete ... := by sorry
```
This is honest: the theorem was already sorry'd via `dd_countermodel_chronicle_discrete ... sorry`. Making the sorry explicit at the top level is cleaner.

**Option B**: Leave `countermodel_discrete` in Transfer.lean with its current body (already essentially a sorry). Add more prominent deprecation documentation. This is the minimal-risk approach.

## Import Cleanup Analysis

### ShiftAndGlue.lean
- **Line 2**: `import Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps`
- **Uses from ReynoldsNoGaps**: Zero definitions
- **Action**: Remove this import. ShiftAndGlue already imports GoodStructuresModelSurgery (line 3), which imports ReynoldsNoGaps, so any transitive dependency is satisfied.

### GoodStructuresModelSurgery.lean
- **Line 3**: `import Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps`
- **Uses from ReynoldsNoGaps**: `gap_of_not_succ_archimedean` (line 336), `one_class_archimedean` (lines 338, 514)
- **Action**: Keep this import. It uses live definitions.

### ChronicleToCountermodel.lean
- **Does NOT import** ReynoldsNoGaps or ReynoldsModelSurgery
- **Action**: No change needed.

## Boneyard Convention

The Boneyard is at `Theories/Bimodal/Boneyard/` with well-established conventions:
- Each archived group gets a subdirectory with README.md
- Files use `#exit` if they cannot compile with current API
- The `BoneyardArchive` lake target covers all `Bimodal.Boneyard.*` modules
- The Boneyard README contains a directory inventory table (must be updated)

The `BXPipelineDeadCode/` subdirectory already exists and contains `ReynoldsModelSurgery.lean`. The deprecated ReynoldsNoGaps definitions should go into this same subdirectory or a new sibling.

## Recommended Archival Plan

### Phase 1: Remove redundant import from ShiftAndGlue.lean
- Delete line 2 (`import Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps`) from ShiftAndGlue.lean
- Verify with `lake build`

### Phase 2: Extract deprecated definitions from ReynoldsNoGaps.lean
- Remove from ReynoldsNoGaps.lean:
  - `no_gaps_discrete_archimedean` (lines 111-120)
  - `no_gaps_prior` (lines 276-287)
  - `prior_implies_succ_archimedean` (lines 299-311)
  - `one_class_implies_succ_archimedean` (lines 321-329)
- Create `Boneyard/BXPipelineDeadCode/ReynoldsNoGapsDeprecated.lean` with these definitions (using `#exit` after imports)
- Net sorry reduction: 1 (`no_gaps_prior`)

### Phase 3: Handle countermodel_discrete in Transfer.lean
- Option A: Replace `countermodel_discrete` body (lines 1283-1298) with a top-level `sorry` (making the existing sorry explicit and removing the dependency on `dd_countermodel_chronicle_discrete` with the unprovable `FrameClass.Discrete <= FrameClass.Base` argument)
- Move the old body to `Boneyard/BXPipelineDeadCode/TransferDeadCode.lean` with documentation

### Phase 4: Update Boneyard README
- Add new entries to the directory inventory table
- Update total file/line counts
- Add task 255 to the cross-reference table

### Verification
- `lake build` after each phase
- Confirm no imports break
- Confirm sorry count does not increase (should decrease by 0 net: the `no_gaps_prior` sorry is removed but was already tainted)

## Risk Assessment

**Low risk**:
- Removing ShiftAndGlue redundant import (zero definitions used)
- Extracting deprecated definitions from ReynoldsNoGaps (zero references elsewhere)
- Updating Boneyard README

**Medium risk**:
- Replacing `countermodel_discrete` body with direct sorry (functionally equivalent but changes the proof tree structure; `lake build` needed to verify)

**No risk**:
- ReynoldsModelSurgery.lean -- already in Boneyard, no action needed

## Definition Reference Summary

| Definition | File | Dead? | References |
|-----------|------|-------|------------|
| `no_gaps_faithful` | Boneyard/...ReynoldsModelSurgery | Dead | 0 (already archived) |
| `prior_model_is_succ_archimedean` | Boneyard/...ReynoldsModelSurgery | Dead | 0 (already archived) |
| `no_gaps_prior` | ReynoldsNoGaps.lean | Dead | 0 (FALSE, sorry'd) |
| `prior_implies_succ_archimedean` | ReynoldsNoGaps.lean | Dead | 0 |
| `one_class_implies_succ_archimedean` | ReynoldsNoGaps.lean | Dead | 0 |
| `no_gaps_discrete_archimedean` | ReynoldsNoGaps.lean | Dead | 0 |
| `gap_of_not_succ_archimedean` | ReynoldsNoGaps.lean | **Live** | GoodStructuresModelSurgery:336 |
| `one_class_archimedean` | ReynoldsNoGaps.lean | **Live** | GoodStructuresModelSurgery:338,514 |
| `very_good_of_archimedean` | ReynoldsNoGaps.lean | **Live** | Supports one_class_archimedean |
| `countermodel_discrete` | Transfer.lean | Dead code, live reference | Completeness.lean:165 |
