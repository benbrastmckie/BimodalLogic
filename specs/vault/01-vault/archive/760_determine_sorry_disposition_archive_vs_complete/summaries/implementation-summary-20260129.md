# Implementation Summary: Task #760

**Completed**: 2026-01-29
**Duration**: ~90 minutes

## Overview

Archived sorried code to Boneyard to reduce the sorry count in the main Bimodal codebase. This complements Task 750 which archived failed truth lemma approaches.

## Changes Made

### Phase 1: Dependency Analysis
- Verified import dependencies for all target files
- Identified 12 exercise sorries in Examples/ (imported by Logos/Examples.lean)
- Confirmed 4 dead code sorries in IndexedMCSFamily.lean (unused)
- Documented 8 cross-origin sorries in CoherentConstruction.lean (already has Boneyard reference)
- Documented 5 compositionality sorries in TaskRelation.lean (architectural limitation)

### Phase 2: Archive Examples/ (12 sorries)
- Created `Boneyard/Examples/` directory
- Moved 3 files to Boneyard with archive headers:
  - `ModalProofs.lean` (5 sorries)
  - `ModalProofStrategies.lean` (5 sorries)
  - `TemporalProofs.lean` (2 sorries)
- Updated namespace from `Bimodal.Examples.*` to `Bimodal.Boneyard.Examples.*`
- Updated `Bimodal/Examples.lean` to remove imports
- Updated `Logos/Examples.lean` to reflect changes

### Phase 3: Archive IndexedMCSFamily Dead Code (4 sorries)
- Created `Boneyard/Metalogic_v3/IndexedMCSFamily/` directory
- Created `ConstructIndexedFamily.lean` documenting the removed function
- Removed `construct_indexed_family` and helper lemmas from main file
- Left reference comment pointing to CoherentConstruction as alternative

### Phase 4: Document CoherentConstruction Sorries (8 sorries)
- Verified `Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean` already exists
- Sorries already have "NOT REQUIRED FOR COMPLETENESS" comments
- No extraction needed - documentation is complete

### Phase 5: Document TaskRelation Sorries (5 sorries)
- Created `Boneyard/Metalogic_v3/TaskRelation/Compositionality.lean`
- Added Boneyard references to all 5 sorries in main file
- Updated file header to reference Boneyard documentation

### Phase 6: Boneyard Documentation
- Updated `Boneyard/README.md` with Task 760 sections
- Updated `Boneyard/Metalogic_v3/README.md` with new directories
- Verified no new Boneyard imports in main code

### Phase 7: Final Verification
- `lake build` succeeds (986 jobs)
- Sorry count in main Bimodal (excluding Boneyard): 19
  - TaskRelation.lean: 5 (documented, architectural)
  - CoherentConstruction.lean: 8 (documented, architectural)
  - TruthLemma.lean: 4 (backward direction, not needed for completeness)
  - Others: 2-3 (FMP, ProofSearch placeholders)

## Files Modified

### Removed/Moved
- `Bimodal/Examples/ModalProofs.lean` -> `Boneyard/Examples/`
- `Bimodal/Examples/ModalProofStrategies.lean` -> `Boneyard/Examples/`
- `Bimodal/Examples/TemporalProofs.lean` -> `Boneyard/Examples/`

### Modified
- `Bimodal/Examples.lean` - Removed imports, updated docs
- `Logos/Examples.lean` - Updated docs
- `Metalogic/Representation/IndexedMCSFamily.lean` - Removed dead code
- `Metalogic/Representation/TaskRelation.lean` - Added Boneyard references

### Created
- `Boneyard/Examples/ModalProofs.lean`
- `Boneyard/Examples/ModalProofStrategies.lean`
- `Boneyard/Examples/TemporalProofs.lean`
- `Boneyard/Metalogic_v3/IndexedMCSFamily/ConstructIndexedFamily.lean`
- `Boneyard/Metalogic_v3/TaskRelation/Compositionality.lean`

### Updated Documentation
- `Boneyard/README.md`
- `Boneyard/Metalogic_v3/README.md`

## Sorry Count Impact

| Category | Before | After | Change |
|----------|--------|-------|--------|
| Examples/ | 12 | 0 | -12 (moved to Boneyard) |
| IndexedMCSFamily | 4 | 0 | -4 (removed dead code) |
| CoherentConstruction | 8 | 8 | 0 (documented in place) |
| TaskRelation | 5 | 5 | 0 (documented in place) |

**Net reduction in main codebase**: 16 sorries moved/removed

## Verification

- [x] `lake build` succeeds
- [x] No new Boneyard imports in main theory
- [x] `semantic_weak_completeness` still compiles
- [x] Boneyard README documents all archived code

## Notes

- The CoherentConstruction and TaskRelation sorries were NOT extracted because they represent architectural limitations, not incomplete work. They already have thorough documentation in the file headers and now reference Boneyard documentation files.
- The Examples sorries are intentional exercise placeholders that are straightforward to complete if needed.
- The IndexedMCSFamily `construct_indexed_family` was dead code - the approach fundamentally cannot work, and `CoherentConstruction.construct_coherent_family` is the correct replacement.
