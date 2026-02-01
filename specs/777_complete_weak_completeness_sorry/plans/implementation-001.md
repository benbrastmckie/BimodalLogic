# Implementation Plan: Task #777

- **Task**: 777 - complete_weak_completeness_sorry
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: Task 794 (completed - sorry-free completeness theorems)
- **Research Inputs**: specs/777_complete_weak_completeness_sorry/reports/research-008.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses the archival of deprecated metalogic files identified in research-008.md. The primary target is FiniteCanonicalModel.lean (71 sorries), which contains a deprecated "syntactic approach" that has been superseded by the sorry-free semantic approach via semantic_weak_completeness. The Representation/ directory (35 sorries) must be retained as it is actively used by InfinitaryStrongCompleteness.lean.

### Research Integration

Key findings from research-008.md:
- FiniteCanonicalModel.lean is marked DEPRECATED and has no active imports
- Representation/ is NOT archivable - InfinitaryStrongCompleteness depends on it
- All main completeness theorems are now sorry-free after task 794
- Sorries in Representation/ are in backward directions, not on the critical path

## Goals & Non-Goals

**Goals**:
- Archive FiniteCanonicalModel.lean to Boneyard/Metalogic_v4/Completeness/
- Verify no active imports depend on FiniteCanonicalModel.lean
- Ensure the build passes after archival
- Document the archival rationale for future reference

**Non-Goals**:
- Archiving Representation/ (confirmed dependency from InfinitaryStrongCompleteness)
- Refactoring Completeness.lean (medium priority, separate task)
- Completing Decidability proofs (6 sorries - lower priority)
- Fixing FMP/SemanticCanonicalModel sorries (5 sorries - lower priority)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden import dependency on FiniteCanonicalModel | High | Low | Grep all .lean files for imports before archival |
| Build failure after archival | High | Low | Full lake build verification |
| Loss of salvageable lemmas | Medium | Low | Review file for any reusable content before archival |

## Implementation Phases

### Phase 1: Verify No Active Dependencies [NOT STARTED]

**Goal**: Confirm FiniteCanonicalModel.lean has no active imports in the codebase.

**Tasks**:
- [ ] Grep all .lean files for imports of FiniteCanonicalModel
- [ ] Grep for any direct references to types/theorems from the file
- [ ] Document findings

**Timing**: 15 minutes

**Files to examine**:
- All files in `Theories/` (grep for imports)
- All files in `Theories/Bimodal/Metalogic/` (potential local references)

**Verification**:
- No imports found, or identified imports are in already-archived files

---

### Phase 2: Review File for Salvageable Content [NOT STARTED]

**Goal**: Identify any lemmas or definitions worth extracting before archival.

**Tasks**:
- [ ] Read FiniteCanonicalModel.lean and identify key definitions
- [ ] Check if any definitions are unique and not duplicated elsewhere
- [ ] Document any content worth preserving separately

**Timing**: 20 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- Explicit decision recorded: extract vs. archive-as-is

---

### Phase 3: Create Boneyard Directory Structure [NOT STARTED]

**Goal**: Prepare the Boneyard destination for archived files.

**Tasks**:
- [ ] Create `Boneyard/Metalogic_v4/Completeness/` directory if not exists
- [ ] Add README or header comment explaining archival rationale

**Timing**: 10 minutes

**Files to modify**:
- Create `Boneyard/Metalogic_v4/Completeness/` directory

**Verification**:
- Directory exists and is ready to receive archived file

---

### Phase 4: Archive FiniteCanonicalModel.lean [NOT STARTED]

**Goal**: Move the deprecated file to Boneyard with proper documentation.

**Tasks**:
- [ ] Move `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` to `Boneyard/Metalogic_v4/Completeness/`
- [ ] Update the file header with archival metadata (date, reason, superseded by)
- [ ] Update any import statements in the moved file to reflect new location (if needed for historical builds)

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` -> `Boneyard/Metalogic_v4/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- File moved successfully
- Original location no longer contains the file

---

### Phase 5: Verify Build Passes [NOT STARTED]

**Goal**: Confirm the repository builds cleanly after archival.

**Tasks**:
- [ ] Run `lake build` on the full project
- [ ] Verify no new errors introduced
- [ ] Check that sorry count decreased by 71 in Metalogic/

**Timing**: 30 minutes (including build time)

**Files to examine**:
- Build output

**Verification**:
- Build succeeds with no new errors
- Metalogic/ sorry count decreased

---

### Phase 6: Document Changes and Update State [NOT STARTED]

**Goal**: Record the archival in project documentation.

**Tasks**:
- [ ] Update state.json with completion status
- [ ] Update TODO.md with completion status
- [ ] Create implementation summary

**Timing**: 15 minutes

**Files to modify**:
- `specs/state.json`
- `specs/TODO.md`
- `specs/777_complete_weak_completeness_sorry/summaries/implementation-summary-20260201.md`

**Verification**:
- State files synchronized
- Summary document created

## Testing & Validation

- [ ] Grep confirms no active imports of FiniteCanonicalModel.lean
- [ ] `lake build` passes after archival
- [ ] Sorry count in active Metalogic/ reduced by approximately 71
- [ ] Archived file has proper header documentation
- [ ] All main completeness theorems remain sorry-free

## Artifacts & Outputs

- `Boneyard/Metalogic_v4/Completeness/FiniteCanonicalModel.lean` - Archived file
- `specs/777_complete_weak_completeness_sorry/plans/implementation-001.md` - This plan
- `specs/777_complete_weak_completeness_sorry/summaries/implementation-summary-20260201.md` - Completion summary

## Rollback/Contingency

If the archival causes unexpected build failures:
1. Restore FiniteCanonicalModel.lean from git history: `git checkout HEAD -- Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
2. Investigate which files depend on it
3. Either fix the dependencies or abandon the archival task

If hidden dependencies are found:
1. Document the dependencies
2. Evaluate whether to fix them first or abandon archival
3. Create follow-up tasks if needed
