# Implementation Plan: Merge Root Boneyard into Canonical Location

- **Task**: 132 - Merge root Boneyard into Theories/Bimodal/Boneyard and populate README
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None (independent housekeeping task)
- **Research Inputs**: specs/132_merge_boneyard_directories/reports/01_boneyard-merge-research.md
- **Artifacts**: plans/01_boneyard-merge-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The project has two Boneyard directories: a root-level `Boneyard/` (2 files, 216 lines, outside the build tree) and the canonical `Theories/Bimodal/Boneyard/` (45 files, 14 subdirectories, ~26K lines). This plan merges the root files into the canonical location using thematic subdirectories consistent with the existing organizational pattern, writes comprehensive README documentation for the top-level Boneyard, and removes the root-level directory. The task is complete when all archived code lives under `Theories/Bimodal/Boneyard/`, the top-level README documents the full archive, and `lake build` passes without regression.

### Research Integration

Key findings from the research report (01_boneyard-merge-research.md):
- Root `Boneyard/` contains exactly 2 files: `XuLemma321.lean` (75 lines, blocked proof-by-contradiction for Xu 3.2.1) and `NonBurgessSeed/PointInsertionLegacy.lean` (141 lines, legacy g_content/h_content approach)
- No naming conflicts between root and canonical Boneyard directories
- Neither root Boneyard file is imported by any compiled module; root `Boneyard/` is outside the lake build tree
- The top-level `Theories/Bimodal/Boneyard/README.md` is empty and needs comprehensive documentation
- Six existing subdirectory READMEs provide good templates (BundleTemporalCoherence, QuasimodelOracle, StrictSemanticsLegacy, TAxiomDependentCode, UltrafilterDeadCode, StageInductionGapAnalysis)
- Three informational comments in active code reference Boneyard but require no updating

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task is general housekeeping that does not directly advance any specific ROADMAP completeness item. It consolidates the archive, improving codebase hygiene and making it easier to navigate the Boneyard when consulting archived approaches during future completeness work.

## Goals & Non-Goals

**Goals**:
- Move all files from root `Boneyard/` into thematic subdirectories under `Theories/Bimodal/Boneyard/`
- Create a subdirectory README for the newly moved `XuLemma321Legacy/` directory
- Populate `Theories/Bimodal/Boneyard/README.md` with comprehensive documentation covering purpose, structure, archival reasons, and consultation guidance
- Remove the root-level `Boneyard/` directory
- Verify `lake build` passes after all changes

**Non-Goals**:
- Updating informational comments in active code that reference "Boneyard" (they remain accurate)
- Modifying any existing Boneyard subdirectory READMEs (they are already well-written)
- Changing import paths (none exist for Boneyard files)
- Reorganizing existing canonical Boneyard subdirectories

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build breakage after file move | M | L | Root Boneyard is outside build tree; canonical Boneyard not imported. Run `lake build` to confirm. |
| Git history loss for moved files | L | L | Use `git mv` to preserve history; verify with `git log --follow` after move. |
| README content becomes stale over time | L | M | Include git-based retrieval instructions so README serves as index, not sole source of truth. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1    | 1      | --         |
| 2    | 2      | 1          |
| 3    | 3      | 2          |

Phases within the same wave can execute in parallel.

### Phase 1: Move Root Boneyard Files to Canonical Location [COMPLETED]

**Goal**: Relocate both root Boneyard files into thematic subdirectories under `Theories/Bimodal/Boneyard/`, preserving git history.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/XuLemma321Legacy/` subdirectory
- [ ] `git mv Boneyard/XuLemma321.lean Theories/Bimodal/Boneyard/XuLemma321Legacy/XuLemma321.lean`
- [ ] `git mv Boneyard/NonBurgessSeed/PointInsertionLegacy.lean Theories/Bimodal/Boneyard/NonBurgessSeed/PointInsertionLegacy.lean`
- [ ] Remove the now-empty root `Boneyard/` directory (git rm or manual cleanup)
- [ ] Verify git status shows moves, not deletions + additions

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `Boneyard/XuLemma321.lean` - move to `Theories/Bimodal/Boneyard/XuLemma321Legacy/`
- `Boneyard/NonBurgessSeed/PointInsertionLegacy.lean` - move to `Theories/Bimodal/Boneyard/NonBurgessSeed/`

**Verification**:
- `git status` shows renames (not delete + create)
- Root `Boneyard/` directory no longer exists
- Files exist at their new canonical locations

---

### Phase 2: Write README Documentation [COMPLETED]

**Goal**: Create comprehensive documentation for the Boneyard archive, including a new subdirectory README for XuLemma321Legacy and a full rewrite of the top-level Boneyard README.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/XuLemma321Legacy/README.md` explaining: blocked proof-by-contradiction approach for Xu 3.2.1(i)/(ii), origin from `RRelation.lean`, BX9 unsoundness under open guard semantics, and that task 115 proved Xu 3.2.1 via a different method (`dcs_neg_union_consistent`)
- [ ] Write `Theories/Bimodal/Boneyard/README.md` with the following sections:
  - Purpose of the Boneyard (archived dead code, superseded approaches, mathematically false lemmas)
  - Complete directory inventory table (all 15+ subdirectories with file counts, line counts, archived-from source, and why archived)
  - Archival reason taxonomy (unsound axioms, superseded approaches, architectural incompatibility, dead-end strategies)
  - Task cross-references (which tasks created each archived group)
  - Guidance on when to consult Boneyard code vs when to ignore it
  - Git-based retrieval instructions for browsing history

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Boneyard/XuLemma321Legacy/README.md` - create new
- `Theories/Bimodal/Boneyard/README.md` - full rewrite (currently empty)

**Verification**:
- Both README files exist and contain substantive content
- Top-level README includes all 15+ subdirectories in inventory table
- Cross-references to originating tasks are accurate

---

### Phase 3: Build Verification and Cleanup [COMPLETED]

**Goal**: Confirm the merge causes no build regressions and the codebase is clean.

**Tasks**:
- [ ] Run `lake build` and verify it completes without new errors
- [ ] Verify no dangling import references exist (grep for old root Boneyard paths)
- [ ] Confirm root `Boneyard/` directory is fully removed from working tree
- [ ] Spot-check that existing Boneyard subdirectory READMEs are unmodified

**Timing**: 45 minutes

**Depends on**: 2

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds
- `ls Boneyard/` fails (directory does not exist)
- `grep -r "Boneyard/XuLemma321" Theories/` returns no import hits
- `grep -r "Boneyard/NonBurgessSeed" Theories/` returns no import hits

## Testing & Validation

- [ ] `lake build` passes without new errors or warnings
- [ ] `git log --follow Theories/Bimodal/Boneyard/XuLemma321Legacy/XuLemma321.lean` shows history
- [ ] `git log --follow Theories/Bimodal/Boneyard/NonBurgessSeed/PointInsertionLegacy.lean` shows history
- [ ] Root `Boneyard/` directory no longer exists
- [ ] Top-level Boneyard README covers all subdirectories
- [ ] XuLemma321Legacy README explains archival context

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/XuLemma321Legacy/XuLemma321.lean` - moved file
- `Theories/Bimodal/Boneyard/NonBurgessSeed/PointInsertionLegacy.lean` - moved file
- `Theories/Bimodal/Boneyard/XuLemma321Legacy/README.md` - new subdirectory README
- `Theories/Bimodal/Boneyard/README.md` - comprehensive top-level README
- `specs/132_merge_boneyard_directories/plans/01_boneyard-merge-plan.md` - this plan

## Rollback/Contingency

If the merge causes unexpected build failures:
1. `git checkout -- Boneyard/` to restore root Boneyard files
2. `git checkout -- Theories/Bimodal/Boneyard/` to restore canonical Boneyard state
3. Investigate which file move caused the issue (likely none, given research findings)

Since both Boneyard locations are fully isolated from the active codebase (no imports), rollback should not be necessary. The entire operation can be reverted with `git reset HEAD~1` if committed as a single change.
