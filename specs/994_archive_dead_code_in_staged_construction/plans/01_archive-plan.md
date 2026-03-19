# Implementation Plan: Task #994

- **Task**: 994 - Archive dead code in StagedConstruction
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/994_archive_dead_code_in_staged_construction/reports/01_dead-code-analysis.md
- **Artifacts**: plans/01_archive-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Archive two orphaned Lean files (`DovetailedTimelineQuot.lean` and `DovetailedFMCS.lean`) from the StagedConstruction module to the Boneyard. Research confirmed both files are completely orphaned from the active completeness proof chain - `Completeness.lean` uses the `TimelineQuot` path instead. The dovetailed approach was an alternative construction path using interleaved forward/backward witness enumeration that ultimately had unsolvable sorry gaps around proving density witnesses exist in the dovetailed timeline union.

### Research Integration

Key findings from the dead code analysis:
- Both files are entirely orphaned (not imported by `Completeness.lean` or its dependency chain)
- All sorries trace to same root: proving density witnesses are in the dovetailed timeline union
- Code duplication exists between the two files (incomplete refactoring)
- Mathematical patterns worth preserving: strong induction on iterated modalities, density-via-encoding-overflow technique

## Goals & Non-Goals

**Goals**:
- Move `DovetailedTimelineQuot.lean` and `DovetailedFMCS.lean` to Boneyard
- Create README documenting original purpose, why archived, and patterns preserved
- Update Boneyard top-level README
- Verify build passes after archival

**Non-Goals**:
- Surgical removal of individual declarations (research recommends whole-file archival)
- Fixing the sorries (the approach has fundamental limitations)
- Updating the orphaned files to work with current Mathlib

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden import dependency | High | Low | Run `lake build` after removal to confirm no breakage |
| Loss of valuable patterns | Medium | Low | Document patterns thoroughly in README |
| User confusion about missing files | Low | Low | Clear README explaining why archived |

## Implementation Phases

### Phase 1: Prepare Boneyard Directory [NOT STARTED]

**Goal**: Create archive directory structure following Boneyard conventions.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Task994_DovetailedQuot/` directory
- [ ] Verify directory naming follows `Task{N}_{Description}` pattern from existing Boneyard entries

**Timing**: 5 minutes

**Files to modify**:
- Create: `Theories/Bimodal/Boneyard/Task994_DovetailedQuot/` (directory)

**Verification**:
- Directory exists and follows naming conventions

---

### Phase 2: Move Source Files [NOT STARTED]

**Goal**: Move orphaned Lean files to Boneyard while preserving git history.

**Tasks**:
- [ ] Move `DovetailedTimelineQuot.lean` to Boneyard directory
- [ ] Move `DovetailedFMCS.lean` to Boneyard directory
- [ ] Verify files are in new location

**Timing**: 10 minutes

**Files to modify**:
- Move: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean` -> `Theories/Bimodal/Boneyard/Task994_DovetailedQuot/`
- Move: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedFMCS.lean` -> `Theories/Bimodal/Boneyard/Task994_DovetailedQuot/`

**Verification**:
- Source files no longer exist in StagedConstruction/
- Files exist in Boneyard/Task994_DovetailedQuot/

---

### Phase 3: Create Documentation [NOT STARTED]

**Goal**: Document the archived files with context for future reference.

**Tasks**:
- [ ] Create README.md in Task994_DovetailedQuot/ with:
  - Original purpose of the dovetailed approach
  - Why archived (orphaned from completeness chain, unsolvable sorries)
  - Mathematical patterns preserved (strong induction, density overflow)
  - Restoration notes
- [ ] Update top-level Boneyard README.md with Task994 entry

**Timing**: 20 minutes

**Files to modify**:
- Create: `Theories/Bimodal/Boneyard/Task994_DovetailedQuot/README.md`
- Edit: `Theories/Bimodal/Boneyard/README.md`

**Verification**:
- README documents purpose, sorries, and patterns
- Top-level Boneyard README lists Task994 entry

---

### Phase 4: Build Verification [NOT STARTED]

**Goal**: Confirm the build passes after file removal.

**Tasks**:
- [ ] Run `lake build` to verify no import errors
- [ ] Check that `Completeness.lean` still builds (already uses TimelineQuot path)
- [ ] Document any unexpected issues

**Timing**: 15 minutes (build time)

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds with no errors related to removed files
- Build output confirms completeness chain is unaffected

---

## Testing & Validation

- [ ] `lake build` succeeds after archival
- [ ] No files import DovetailedTimelineQuot or DovetailedFMCS
- [ ] Boneyard README documents Task994 entry
- [ ] Archive README documents patterns for future reference

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/Task994_DovetailedQuot/DovetailedTimelineQuot.lean` (archived)
- `Theories/Bimodal/Boneyard/Task994_DovetailedQuot/DovetailedFMCS.lean` (archived)
- `Theories/Bimodal/Boneyard/Task994_DovetailedQuot/README.md` (documentation)
- `Theories/Bimodal/Boneyard/README.md` (updated)
- `specs/994_archive_dead_code_in_staged_construction/summaries/01_archive-summary.md` (implementation summary)

## Rollback/Contingency

If archival causes unexpected build failures:
1. Move files back: `git checkout HEAD~1 -- Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
2. Investigate which file has hidden dependency
3. Archive only the fully orphaned file(s)
4. Create task for addressing the non-orphaned file separately
