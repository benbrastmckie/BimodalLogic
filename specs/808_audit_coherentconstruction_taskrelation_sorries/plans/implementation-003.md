# Implementation Plan: Task #808 (Revised v3)

- **Task**: 808 - audit_coherentconstruction_taskrelation_sorries
- **Version**: 003
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/808_audit_coherentconstruction_taskrelation_sorries/reports/research-001.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: false

## Overview

Archive CoherentConstruction.lean and TaskRelation.lean to Bimodal/Boneyard/ while ensuring the completeness proof remains intact. No sorries are acceptable in the publishable codebase. This revision emphasizes proof integrity verification and refactoring opportunities to improve overall metalogic quality.

### Revision Notes (v003)

**Changed from v002**:
- Added explicit proof integrity verification phase
- Added refactoring opportunities analysis
- Expanded verification to cover completeness theorem chain
- Increased effort estimate to account for quality improvements

### Research Integration

Research confirmed:
- 10 sorries in CoherentConstruction.lean
- 5 sorries in TaskRelation.lean
- None block completeness theorem (not on critical path)
- Files can be safely archived

## Goals & Non-Goals

**Goals**:
- Archive CoherentConstruction.lean and TaskRelation.lean to Boneyard
- **Verify completeness proof chain remains intact**
- **Identify and apply refactoring opportunities** to improve metalogic quality
- Ensure build passes with no regressions
- Clean up any dead imports or references

**Non-Goals**:
- Complete any sorries (archived instead)
- Major restructuring beyond necessary cleanup
- Changes to the completeness proof logic itself

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Files have unexpected dependencies | H | L | Phase 1 comprehensive dependency scan |
| Build breaks after archival | M | L | Phase 3 full build verification |
| Completeness proof broken | H | VL | Phase 2 explicit proof chain verification |
| Missed refactoring opportunities | L | M | Phase 2 systematic review |

## Implementation Phases

### Phase 1: Dependency Analysis and Archival [NOT STARTED]

**Goal**: Map all dependencies, then safely archive files to Boneyard

**Tasks**:
- [ ] Grep for imports of CoherentConstruction in Theories/Bimodal/
- [ ] Grep for imports of TaskRelation in Theories/Bimodal/
- [ ] Map the dependency chain: which files import these, and what do they use?
- [ ] If active dependencies found: document them and assess impact
- [ ] Create Theories/Bimodal/Boneyard/Representation/ directory if needed
- [ ] Move CoherentConstruction.lean to Theories/Bimodal/Boneyard/Representation/
- [ ] Move TaskRelation.lean to Theories/Bimodal/Boneyard/Representation/
- [ ] Remove or update any imports in remaining active files

**Timing**: 30 minutes

**Files to move**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` -> `Theories/Bimodal/Boneyard/Representation/CoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean` -> `Theories/Bimodal/Boneyard/Representation/TaskRelation.lean`

**Verification**:
- Dependency map documented
- Files successfully moved
- No dangling imports in active code

---

### Phase 2: Proof Integrity and Refactoring Review [NOT STARTED]

**Goal**: Verify completeness proof remains intact and identify quality improvements

**Tasks**:
- [ ] Verify InfinitaryStrongCompleteness.lean compiles without these files
- [ ] Check UniversalCanonicalModel.lean has no broken references
- [ ] Trace the completeness proof dependency chain:
  - `infinitary_strong_completeness` theorem
  - Required lemmas and supporting theorems
  - Confirm no sorried dependencies remain in the chain
- [ ] Identify refactoring opportunities in remaining Representation/ files:
  - Dead code removal
  - Unused imports cleanup
  - Documentation improvements
- [ ] Apply minimal refactoring for code quality (if any identified)

**Timing**: 45 minutes

**Files to review**:
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean`
- `Theories/Bimodal/Metalogic/Canonicity/UniversalCanonicalModel.lean`
- `Theories/Bimodal/Metalogic/Representation/*.lean` (remaining files)

**Verification**:
- Completeness theorem proof chain verified intact
- No sorry-dependent code in critical path
- Refactoring changes (if any) documented

---

### Phase 3: Build Verification and Summary [NOT STARTED]

**Goal**: Full build verification and implementation summary

**Tasks**:
- [ ] Run lake build on full project
- [ ] Verify no errors or warnings related to moved files
- [ ] Verify completeness theorem accessible and compiles
- [ ] Create implementation summary documenting:
  - Files archived
  - Dependencies handled
  - Proof integrity confirmed
  - Refactoring applied (if any)
  - Sorry count reduction

**Timing**: 15 minutes

**Verification**:
- `lake build` passes without errors
- Completeness theorem compiles successfully
- Summary accurately reflects all changes

## Testing & Validation

- [ ] `lake build` passes
- [ ] No import errors referencing CoherentConstruction or TaskRelation in active code
- [ ] Files exist in Theories/Bimodal/Boneyard/Representation/
- [ ] `infinitary_strong_completeness` theorem compiles
- [ ] No new sorries introduced
- [ ] Repository sorry count reduced by 15

## Artifacts & Outputs

- plans/implementation-003.md (this file)
- summaries/implementation-summary-{DATE}.md
- Archived files in Theories/Bimodal/Boneyard/Representation/

## Rollback/Contingency

If archival causes issues:
1. `git restore` to revert file moves
2. Verify build passes
3. Document specific blockers
4. Create follow-up task if refactoring needed before archival

**Critical invariant**: The completeness proof must remain functional at all times. If any change threatens this, abort and document the issue.
