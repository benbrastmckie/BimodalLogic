# Implementation Plan: Task #782

- **Task**: 782 - Revert Bimodal theory to before archival refactor
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/782_revert_bimodal_metalogic_archival_refactor/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Revert the `Theories/Bimodal/` directory to the pre-archival state at commit `08754f0b` using selective path reversion (`git checkout <commit> -- <paths>`). This removes the Boneyard directory, restores the original Metalogic structure, and reverts documentation to match. The approach preserves unrelated changes to `.claude/` and `specs/` directories.

### Research Integration

The research report identified:
- Reversion target: commit `08754f0b` (last commit before Boneyard creation)
- Key archival commits: `e52e0fc4` (task 487, Boneyard creation), `2e46e80f` (task 654, Metalogic_v2 move)
- Strategy: Full path reversion (Option A) recommended for clean result
- Files requiring post-reversion attention: `Bimodal.lean`, `Demo.lean`, theorem imports

## Goals & Non-Goals

**Goals**:
- Restore `Theories/Bimodal/` to pre-archival state at commit `08754f0b`
- Remove `Theories/Bimodal/Boneyard/` directory completely
- Restore original `Theories/Bimodal/Metalogic/` structure
- Revert `Theories/Bimodal/docs/` to match code state
- Ensure `lake build` succeeds after reversion
- Document changes worth potential re-application

**Non-Goals**:
- Revert `.claude/` directory changes
- Revert `specs/` directory changes
- Revert `Theories/PropositionalLogic/` or other unrelated theories
- Re-implement any features lost during reversion (future task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build failures after reversion | High | Medium | Run `lake build` immediately, fix imports |
| Lost valid improvements | Medium | High | Document improvements for future re-application |
| Import path breakage | Medium | Medium | Update main module file and verify |
| Documentation inconsistency | Low | Low | Revert docs together with code |

## Implementation Phases

### Phase 1: Preparation and Backup [NOT STARTED]

**Goal**: Create safety backup and verify reversion target

**Tasks**:
- [ ] Create backup branch `backup/pre-revert-782`
- [ ] Verify commit `08754f0b` exists and is accessible
- [ ] Record current state of `Theories/Bimodal/` for comparison
- [ ] List files that will be affected by reversion

**Timing**: 15 minutes

**Files to modify**:
- None (git operations only)

**Verification**:
- Backup branch created and pushed
- Commit `08754f0b` exists: `git cat-file -t 08754f0b` returns "commit"
- `git show 08754f0b --stat` shows expected files

---

### Phase 2: Execute Path Reversion [NOT STARTED]

**Goal**: Revert `Theories/Bimodal/` to pre-archival state

**Tasks**:
- [ ] Run `git checkout 08754f0b -- Theories/Bimodal/`
- [ ] Verify Boneyard directory removed
- [ ] Verify original Metalogic structure restored
- [ ] Check file count matches expected pre-archival state

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/` (entire directory reverted)
- `Theories/Bimodal/Boneyard/` (removed)
- `Theories/Bimodal/Metalogic/` (restored to original structure)
- `Theories/Bimodal/docs/` (reverted to match)

**Verification**:
- `Theories/Bimodal/Boneyard/` does not exist
- `Theories/Bimodal/Metalogic/` contains original structure (Completeness/, Decidability/, etc.)
- `Theories/Bimodal/docs/` contains pre-archival documentation
- `git status` shows expected changes

---

### Phase 3: Fix Imports and Build [NOT STARTED]

**Goal**: Ensure project builds successfully after reversion

**Tasks**:
- [ ] Run `lake build` to identify any import errors
- [ ] Fix any broken imports in `Theories/Bimodal/Bimodal.lean`
- [ ] Update any cross-references if needed
- [ ] Run `lake build` again to verify clean build

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Bimodal.lean` - May need import updates
- Any files with broken references (identified by build)

**Verification**:
- `lake build` completes with no errors
- All imports resolve correctly
- No new `sorry` placeholders introduced

---

### Phase 4: Verification and Documentation [NOT STARTED]

**Goal**: Verify reversion is complete and document for future reference

**Tasks**:
- [ ] Compare current state with expected pre-archival structure
- [ ] Verify no orphaned files remain
- [ ] Update sorry count if applicable
- [ ] Document reversion in implementation summary

**Timing**: 15 minutes

**Files to modify**:
- Implementation summary (created)

**Verification**:
- Directory structure matches research report's "Pre-Archival State"
- No Boneyard artifacts remain
- Build is clean

---

### Phase 5: Commit Changes [NOT STARTED]

**Goal**: Commit reversion with clear history

**Tasks**:
- [ ] Stage all changed files
- [ ] Create commit with descriptive message
- [ ] Verify commit history is clear

**Timing**: 10 minutes

**Files to modify**:
- All reverted files (staged for commit)

**Verification**:
- Commit created with message explaining reversion
- `git log` shows clean history

## Testing & Validation

- [ ] `lake build` succeeds without errors
- [ ] `Theories/Bimodal/Boneyard/` directory does not exist
- [ ] `Theories/Bimodal/Metalogic/` has original structure (Completeness.lean, Soundness.lean, etc. at top level)
- [ ] No regression in existing tests or proofs
- [ ] Backup branch exists at `backup/pre-revert-782`

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (on completion)
- Backup branch: `backup/pre-revert-782`

## Rollback/Contingency

If the reversion causes unforeseen issues:

1. **Quick rollback**: `git checkout backup/pre-revert-782 -- Theories/Bimodal/`
2. **Full abort**: `git reset --hard HEAD~1` if committed
3. **Selective restore**: Cherry-pick specific files from backup branch

The backup branch at `backup/pre-revert-782` preserves the exact state before reversion.

---

## Appendix: Positive Changes Worth Re-Applying

After reviewing the archival period commits, the following improvements may be worth re-applying in the future (as separate tasks):

### 1. Infrastructure Improvements

- **Automation scripts**: Some Boneyard organization may have included useful automation
- **Documentation structure**: Some documentation reorganization may be worth keeping

### 2. Code Quality Improvements

- **Error handling patterns**: Any improved error handling in Metalogic code
- **Type signature refinements**: If any type signatures were improved for clarity
- **Code organization**: Subdirectory organization (Algebraic/, FMP/, etc.) may be useful once the correct approach is established

### 3. Proof Techniques

- **semantic_weak_completeness**: While the emphasis was wrong, the technique itself may be useful as a secondary approach
- **Representation lemmas**: Any representation theory work in the new Metalogic/Representation/

### 4. Testing Infrastructure

- **Examples/Demo.lean updates**: If any demonstration examples were improved

**Recommendation**: After reversion is stable, create a follow-up task to:
1. Review commits from `08754f0b..HEAD` for `Theories/Bimodal/`
2. Cherry-pick or manually re-apply valuable improvements
3. Focus on the correct `weak_completeness` approach this time
