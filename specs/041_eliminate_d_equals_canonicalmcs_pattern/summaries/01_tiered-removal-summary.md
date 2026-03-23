# Implementation Summary: Task #41 - Tiered Removal of D=CanonicalMCS Pattern

**Task**: 41 - eliminate_d_equals_canonicalmcs_pattern
**Completed**: 2026-03-23
**Session**: sess_1774293770_9891ef

## Overview

Executed the 6-phase tiered removal plan to eliminate the confused D=CanonicalMCS pattern from the codebase. The pattern conflated the duration domain (D) with the space of maximal consistent sets (CanonicalMCS), creating infrastructure that trivialized F/P witness obligations rather than proving them.

## Execution Summary

### Phase 1: DELETE Confused Files [COMPLETED]

Removed 3 files that embodied the D=CanonicalMCS confusion:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` (git rm)
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` (git rm)
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalQuot.lean` (git rm)

### Phase 2: BONEYARD Valuable Infrastructure [COMPLETED]

Archived 11 files to `Boneyard/CanonicalMCS_Infrastructure/` with archival headers:

**Original Plan (7 files):**
1. `Bundle/ChainFMCS.lean`
2. `Bundle/ClosedFlagBundle.lean`
3. `Bundle/ClosedFlagIntBFMCS.lean`
4. `Bundle/WitnessFamilyBundle.lean`
5. `Bundle/SaturatedBFMCSConstruction.lean`
6. `Bundle/ModalWitnessData.lean`
7. `Algebraic/MultiFamilyBFMCS.lean`

**Additional Files (Phase 6 decision + transitive dependencies):**
8. `Bundle/ModallyCoherentBFMCS.lean`
9. `Bundle/DirectMultiFamilyBFMCS.lean`
10. `Algebraic/AlgebraicBaseCompleteness.lean`
11. `Algebraic/DiscreteInstantiation.lean`

### Phase 3: Clean Active File Imports [COMPLETED]

Removed dead imports and references from:
- `BaseCompleteness.lean` - removed CanonicalFMCS import
- `DenseCompleteness.lean` - removed CanonicalFMCS import
- `DiscreteCompleteness.lean` - removed CanonicalFMCS import
- `LogicVariants.lean` - removed import, removed broken `dense_components_export` function
- `Algebraic/Algebraic.lean` - removed DiscreteInstantiation and AlgebraicBaseCompleteness imports/opens
- `Bundle/README.md` - updated import example

### Phase 4: Update ROAD_MAP.md Dead Ends [COMPLETED]

Added "Dead End: D = CanonicalMCS Pattern" entry to specs/ROAD_MAP.md documenting:
- Why the pattern was confused (conflates D with W)
- What we tried (temporal_coherent_family_exists_CanonicalMCS was "sorry-free but useless")
- Key lesson (D indexes time, W indexes worlds - never conflate)
- Reference to 03_removal-analysis.md

### Phase 5: Clean FMCSDef.lean Documentation [COMPLETED]

Updated `Bundle/FMCSDef.lean` to:
- Remove D=CanonicalMCS special case documentation
- Point to SuccChainFMCS as the canonical D=Int implementation
- Add warning against W/D conflation

### Phase 6: Algebraic Path Decision [COMPLETED]

Decision: Archive to Boneyard (Option A - recommended)

Moved `DirectMultiFamilyBFMCS.lean` and `ModallyCoherentBFMCS.lean` to Boneyard since they:
- Have 4 blocking sorries from W=D conflation
- Explicitly recommend SuccChain in their own documentation
- Are not used by any active code path

## Verification Results

| Metric | Before | After | Delta |
|--------|--------|-------|-------|
| Sorries | 398 | 385 | -13 |
| Axioms | 5 | 5 | 0 |
| Build | Pass | Pass | - |
| Jobs | 929 | 928 | -1 |

## Artifacts

### Deleted (git rm)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalQuot.lean`

### Archived (Boneyard/CanonicalMCS_Infrastructure/)
- 11 files with archival headers explaining why archived
- Headers point to SuccChainFMCS as the correct approach

### Modified
- `specs/ROAD_MAP.md` - new Dead End entry
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` - updated documentation
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - removed dead imports
- `Theories/Bimodal/LogicVariants.lean` - removed broken function
- `Theories/Bimodal/Metalogic/BaseCompleteness.lean` - removed import
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - removed import
- `Theories/Bimodal/Metalogic/DiscreteCompleteness.lean` - removed import
- `Theories/Bimodal/Metalogic/Bundle/README.md` - updated example

## Impact

The removal of 13 sorries (398 -> 385) is a direct consequence of moving blocked code to Boneyard. The sorries in the archived files were blocking and marked as architecturally unprovable due to the W=D conflation.

The active completeness path (SuccChainFMCS with D=Int) is unaffected - it never imported CanonicalFMCS.

## Key Lesson Documented

> D and W must be distinct: D indexes temporal positions; W indexes possible worlds (MCSs). Collapsing them creates elegant proofs of nothing.
