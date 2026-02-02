# Implementation Plan: Task #808 (Revised)

- **Task**: 808 - audit_coherentconstruction_taskrelation_sorries
- **Version**: 002
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/808_audit_coherentconstruction_taskrelation_sorries/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: false

## Overview

Archive CoherentConstruction.lean and TaskRelation.lean to Bimodal/Boneyard/. No sorries are acceptable in the publishable codebase - all 15 sorries in these files must be removed from active code by moving the files to the Boneyard.

### Revision Notes (v002)

**Changed from v001**:
- Removed "acceptable sorries" language - no sorries are acceptable
- Simplified to direct archival without documentation phases
- Target is Theories/Bimodal/Boneyard/ (not Boneyard/Metalogic/)
- Reduced phases from 4 to 2

### Research Integration

Research confirmed:
- 10 sorries in CoherentConstruction.lean
- 5 sorries in TaskRelation.lean
- None block completeness theorem (not on critical path)
- Files can be safely archived

## Goals & Non-Goals

**Goals**:
- Move CoherentConstruction.lean to Theories/Bimodal/Boneyard/
- Move TaskRelation.lean to Theories/Bimodal/Boneyard/
- Verify no dependencies break
- Ensure build passes after archival

**Non-Goals**:
- Complete any sorries (archived instead)
- Document why sorries are "acceptable" (they're not - hence archival)
- Modify other files beyond import updates

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Files have unexpected dependencies | H | L | Phase 1 checks imports before moving |
| Build breaks after archival | M | L | Phase 2 verifies build |

## Implementation Phases

### Phase 1: Dependency Check and Archive [NOT STARTED]

**Goal**: Verify no active files depend on these, then archive to Boneyard

**Tasks**:
- [ ] Grep for imports of CoherentConstruction in Theories/Bimodal/
- [ ] Grep for imports of TaskRelation in Theories/Bimodal/
- [ ] If dependencies found: update imports or abort with findings
- [ ] Move CoherentConstruction.lean to Theories/Bimodal/Boneyard/Representation/
- [ ] Move TaskRelation.lean to Theories/Bimodal/Boneyard/Representation/

**Timing**: 30 minutes

**Files to move**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` -> `Theories/Bimodal/Boneyard/Representation/CoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean` -> `Theories/Bimodal/Boneyard/Representation/TaskRelation.lean`

**Verification**:
- No unexpected import errors
- Files successfully moved

---

### Phase 2: Build Verification [NOT STARTED]

**Goal**: Verify build passes and create summary

**Tasks**:
- [ ] Run lake build
- [ ] Verify no errors from moved files
- [ ] Create implementation summary

**Timing**: 30 minutes

**Verification**:
- Build passes without errors
- No references to archived files in error output

## Testing & Validation

- [ ] lake build passes
- [ ] No import errors referencing CoherentConstruction or TaskRelation
- [ ] Files exist in Theories/Bimodal/Boneyard/Representation/

## Artifacts & Outputs

- plans/implementation-002.md (this file)
- summaries/implementation-summary-{DATE}.md
- Archived files in Theories/Bimodal/Boneyard/Representation/

## Rollback/Contingency

If archival causes issues:
1. Move files back from Boneyard/ to original locations
2. Verify build passes
3. Document blockers for future resolution
