# Implementation Summary: Task 928 - Refactor metalogic terminology

**Date**: 2026-02-25
**Session**: sess_1740528300_i928
**Plan**: specs/928_refactor_metalogic_terminology_bfmcs_fmcs_mcs_boneyard/plans/implementation-002.md
**Status**: Implemented (all 7 phases completed)

## Overview

Completed full terminology refactoring and Boneyard cleanup:
- Renamed BFMCS (single family) -> FMCS (Family of MCS)
- Renamed BMCS (bundle) -> BFMCS (Bundle of FMCSs)
- Moved CoherentConstruction.lean to Boneyard
- Cleaned up imports and documentation

## Terminology After Refactoring

| Term | Meaning | Was |
|------|---------|-----|
| **MCS** | Maximal Consistent Set | MCS (unchanged) |
| **FMCS** | Family of MCS (single time-indexed family) | BFMCS |
| **BFMCS** | Bundle of FMCSs (set of families with modal coherence) | BMCS |

## Phase Summary

### Phase 1: BFMCS -> FMCS Rename in Core Definitions [COMPLETED]
- Renamed BFMCS.lean -> FMCSDef.lean (structure definition)
- Renamed CanonicalBFMCS.lean -> CanonicalFMCS.lean
- Created FMCS.lean as re-export with backward compat alias
- Updated all import paths (22 files)
- Fixed TemporalCoherentFamily extends clause (toBFMCS -> toFMCS)

### Phase 2: BFMCS -> FMCS in All Usage Sites [COMPLETED]
- Replaced 264 BFMCS occurrences across 20 files
- Removed backward compat alias after all references updated
- Updated docstrings to use new terminology

### Phase 3: BMCS -> BFMCS Rename [COMPLETED]
- Renamed BMCS.lean -> BFMCS.lean
- Renamed BMCSTruth.lean -> BFMCSTruth.lean
- Renamed ChainBundleBMCS.lean -> ChainBundleBFMCS.lean
- Renamed SeedBMCS.lean -> SeedBFMCS.lean (Boneyard)
- Replaced 360+ BMCS/bmcs occurrences across all files
- Fixed compound identifiers (singleFamilyBMCS -> singleFamilyBFMCS, etc.)

### Phase 4: Move CoherentConstruction.lean to Boneyard [COMPLETED]
- Extracted IsConstantFamily to FMCSDef.lean (general property)
- Removed CoherentConstruction import from TemporalCoherentConstruction.lean
- Removed CoherentConstruction import from TruthLemma.lean
- Moved CoherentConstruction.lean to Theories/Bimodal/Boneyard/Bundle/
- Updated Boneyard import paths

### Phase 5: Constant Family Definitions [COMPLETED]
- Audited constantBFMCS, constantWitnessFamily, constructWitnessFamily
- All constant family defs used by active code - kept in place
- Completed compound identifier renaming from Phase 3

### Phase 6: Code Cleanup and Import Hygiene [COMPLETED]
- Removed CanonicalWorldState duplicate from Completeness.lean
- Removed redundant FMCS imports (6 files)
- Cleaned up import chains

### Phase 7: Documentation Update [COMPLETED]
- Updated Metalogic.lean sorry table (7 -> 5 actual sorries)
- Updated module structure diagram
- Fixed IndexedMCSFamily references in READMEs
- Updated terminology references throughout

## Metrics

| Metric | Before | After |
|--------|--------|-------|
| Active sorries | 5 | 5 (unchanged) |
| Active axioms | 2 | 1 (saturated_extension_exists moved to Boneyard) |
| BFMCS occurrences (old family name) | 264 | 0 |
| BMCS occurrences (old bundle name) | 360 | 0 |
| Files renamed | - | 7 (BFMCS.lean -> FMCSDef.lean, CanonicalBFMCS.lean -> CanonicalFMCS.lean, BMCS.lean -> BFMCS.lean, BMCSTruth.lean -> BFMCSTruth.lean, ChainBundleBMCS.lean -> ChainBundleBFMCS.lean, SeedBMCS.lean -> SeedBFMCS.lean, CoherentConstruction.lean moved) |

## Verification

- `lake build` passes with 0 errors (1001 jobs)
- No new sorries introduced
- No new axioms introduced
- All pre-existing proofs still close
