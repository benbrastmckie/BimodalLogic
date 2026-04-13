# Implementation Plan: Archive Strict-Semantics Legacy Code

- **Task**: 94 - archive_strict_semantics_legacy
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: Task 91 (completed)
- **Research Inputs**: reports/01_archive-strict-legacy.md
- **Artifacts**: plans/01_archive-strict-legacy.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Archive 6 legacy strict-semantics completeness files (4 primary targets + 2 dependent files) to `Boneyard/StrictSemanticsLegacy/`, removing 103 sorries from the active codebase. Also archive BaseCompleteness, DiscreteCompleteness, and DenseCompleteness which depend on the archived CanonicalConstruction (an additional 4 sorries). Update all importers (Metalogic.lean, FrameConditions.lean) to drop references. Write a README documenting the archival rationale. The task is done when `lake build` succeeds with no new errors and the non-Boneyard sorry count drops by approximately 107.

### Research Integration

Research report `reports/01_archive-strict-legacy.md` was integrated. Key findings:

- Actual sorry counts are lower than task description estimates (99 total in 4 primary files, not ~210).
- SuccChainFMCS is imported by CanonicalConstruction.lean and RestrictedTruthLemma.lean (not in original task scope), which must also be archived (Option B from research).
- BaseCompleteness (0 sorries), DiscreteCompleteness (3), and DenseCompleteness (1) all import CanonicalConstruction and will break if it is archived; they should be co-archived since the active completeness path goes through BXCanonical.
- Metalogic.lean currently imports CanonicalConstruction (not BXCanonical as the task description claimed).
- state.json has no `technical_debt` field; sorry tracking goes in `repository_health`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan advances these ROAD_MAP.md items:
- "Legacy strict-semantics files (~20 sorries) pending archival by task 94" -- directly addresses this line item
- Clearing legacy code supports the publication-readiness goal by reducing non-Boneyard sorry count from ~273 to ~166

## Goals & Non-Goals

**Goals**:
- Archive all files in the legacy SuccChain/UltrafilterChain completeness path to Boneyard
- Write a README explaining the strict-vs-reflexive semantics history
- Update all non-Boneyard importers so `lake build` succeeds
- Update state.json repository_health with sorry count delta

**Non-Goals**:
- Refactoring Base/Discrete/DenseCompleteness to use BXCanonical (those are wiring files for the old path; a future task can re-create them if needed)
- Fixing Boneyard files that import the moved files (Boneyard is not on the build path)
- Updating the ROAD_MAP.md (that is task 103's scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden non-Boneyard importers of archived files | H | L | Research identified all importers; verify with `grep` before moving |
| `lake build` failure after import removal | H | M | Run `lake build` after each phase; revert if needed |
| Base/Discrete/DenseCompleteness have non-CanonicalConstruction content worth preserving | M | L | Research shows they are thin wiring files; archive preserves them |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Create Boneyard Directory and Move Files [COMPLETED]

**Goal**: Move all 9 legacy files to `Boneyard/StrictSemanticsLegacy/` and write the archival README.

**Tasks**:
- [ ] Create directory structure: `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/{Algebraic,Bundle,FrameConditions}/`
- [ ] Move primary targets (4 files):
  - `Metalogic/Algebraic/UltrafilterChain.lean` (18 sorries)
  - `Metalogic/Algebraic/DovetailedChain.lean` (9 sorries)
  - `Metalogic/Bundle/SuccChainFMCS.lean` (18 sorries)
  - `FrameConditions/Completeness.lean` (54 sorries)
- [ ] Move dependent files (2 files):
  - `Metalogic/Algebraic/RestrictedTruthLemma.lean` (1 sorry)
  - `Metalogic/Bundle/CanonicalConstruction.lean` (3 sorries)
- [ ] Move downstream wiring files (3 files):
  - `Metalogic/BaseCompleteness.lean` (0 sorries)
  - `Metalogic/DiscreteCompleteness.lean` (3 sorries)
  - `Metalogic/DenseCompleteness.lean` (1 sorry)
- [ ] Write `Boneyard/StrictSemanticsLegacy/README.md` documenting:
  1. Files were written under strict temporal semantics (G/H with strict `<`)
  2. Codebase reverted to reflexive BX semantics (G/H with `<=`)
  3. Active completeness path is `BXCanonical/`
  4. Sorry counts reflect architectural incompatibility, not mathematical gaps
  5. Reference to ROAD_MAP.md for current trajectory
  6. Relationship to existing `Boneyard/ChainCompleteness/` directory

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/README.md` - create
- 9 `.lean` files - move (git mv)

**Verification**:
- All 9 source files no longer exist at original paths
- All 9 files exist under `Boneyard/StrictSemanticsLegacy/`
- README.md contains all required documentation points

---

### Phase 2: Update Import Paths in Non-Boneyard Files [NOT STARTED]

**Goal**: Remove all imports of archived files from non-Boneyard Lean files so the codebase compiles.

**Tasks**:
- [ ] Update `Theories/Bimodal/Metalogic.lean`: remove `import Bimodal.Metalogic.Bundle.CanonicalConstruction`
- [ ] Update `Theories/Bimodal/FrameConditions.lean`: remove `import Bimodal.FrameConditions.Completeness`
- [ ] Verify no other non-Boneyard files import any of the 9 archived files (grep check)
- [ ] Remove any root-module re-exports for BaseCompleteness, DiscreteCompleteness, DenseCompleteness if they exist in Metalogic.lean

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean` - remove CanonicalConstruction import (and Base/Discrete/DenseCompleteness if present)
- `Theories/Bimodal/FrameConditions.lean` - remove Completeness import

**Verification**:
- `grep -r "CanonicalConstruction\|RestrictedTruthLemma\|UltrafilterChain\|DovetailedChain\|SuccChainFMCS\|BaseCompleteness\|DiscreteCompleteness\|DenseCompleteness" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard` returns no results (except possibly comments)

---

### Phase 3: Build Verification and Sorry Count Update [NOT STARTED]

**Goal**: Verify `lake build` succeeds and update state.json with updated sorry counts.

**Tasks**:
- [ ] Run `lake build` and confirm success (no errors)
- [ ] Count non-Boneyard sorries after archival
- [ ] Count Boneyard sorries after archival
- [ ] Update `state.json` `repository_health` with updated sorry counts and assessment timestamp

**Timing**: 1 hour (build time dominates)

**Depends on**: 2

**Files to modify**:
- `specs/state.json` - update `repository_health` with sorry count tracking

**Verification**:
- `lake build` exits 0
- Non-Boneyard sorry count decreased by ~107
- state.json `repository_health` reflects current counts

---

### Phase 4: Update Boneyard Imports (Best-Effort) [NOT STARTED]

**Goal**: Update existing Boneyard files that imported the moved files to use new paths, preventing future confusion.

**Tasks**:
- [ ] Update import paths in `Boneyard/ChainCompleteness/` files that reference the moved files (update `Bimodal.Metalogic.Algebraic.UltrafilterChain` to `Bimodal.Boneyard.StrictSemanticsLegacy.Algebraic.UltrafilterChain`, etc.)
- [ ] This is best-effort: Boneyard files are not on the build path, so broken imports are acceptable

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- Various `Boneyard/ChainCompleteness/` files - update import paths

**Verification**:
- Import paths in Boneyard files point to new locations (grep check)

## Testing & Validation

- [ ] `lake build` succeeds with no new errors after all phases
- [ ] Non-Boneyard sorry count is approximately 166 (down from 273)
- [ ] No non-Boneyard file imports any of the 9 archived files
- [ ] `Boneyard/StrictSemanticsLegacy/README.md` exists and documents the rationale
- [ ] state.json `repository_health` updated

## Artifacts & Outputs

- `specs/094_archive_strict_semantics_legacy/plans/01_archive-strict-legacy.md` (this plan)
- `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/README.md` (archival documentation)
- 9 moved `.lean` files under `Boneyard/StrictSemanticsLegacy/`
- Updated `Metalogic.lean` and `FrameConditions.lean` (import removal)
- Updated `specs/state.json` (sorry count tracking)

## Rollback/Contingency

All file moves use `git mv`, so reverting is straightforward:
1. `git checkout HEAD -- Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (and all other moved files)
2. `git checkout HEAD -- Theories/Bimodal/Metalogic.lean Theories/Bimodal/FrameConditions.lean`
3. Remove `Boneyard/StrictSemanticsLegacy/` directory

If `lake build` fails after import removal, the most likely cause is an unidentified importer. Fix by restoring that file's import or also archiving the importer.
