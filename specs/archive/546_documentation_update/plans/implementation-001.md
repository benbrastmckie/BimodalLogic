# Implementation Plan: Task #546

- **Task**: 546 - documentation_update
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Priority**: Medium
- **Dependencies**: 542, 543, 544, 545 (all completed)
- **Research Inputs**: specs/546_documentation_update/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Update the Metalogic/README.md to accurately reflect the current state of the codebase after Tasks 542-545 completed the refactoring work. The primary changes involve fixing incorrect Boneyard path references, updating the module status table to show that previously broken modules now compile, and refreshing the architecture diagram to reflect the unified structure.

### Research Integration

Research report `research-001.md` identified:
- Metalogic/Boneyard/ path references are incorrect (should be Bimodal/Boneyard/)
- Module status table shows BROKEN for modules that now compile
- Architecture diagram is outdated and shows Representation/ as separate/broken
- Known Issues section describes issues that have been resolved

## Goals & Non-Goals

**Goals**:
- Fix all Boneyard path references from Metalogic/Boneyard/ to Bimodal/Boneyard/
- Update module status table to reflect current compilation state
- Refresh architecture diagram to show unified structure
- Update Known Issues section to remove resolved issues
- Add Last Updated timestamp for documentation freshness tracking

**Non-Goals**:
- Adding extensive new documentation content
- Modifying any Lean source files
- Creating new README files for subdirectories

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| README drift after future changes | Medium | Medium | Add prominent Last Updated date to track freshness |
| Overstating completion (sorries remain) | Low | Low | Clearly indicate which modules have sorries vs clean compilation |

## Implementation Phases

### Phase 1: Fix Path References and Module Status [COMPLETED]

**Goal**: Correct all incorrect path references and update status table to reflect reality

**Tasks**:
- [ ] Change all Metalogic/Boneyard/ references to Bimodal/Boneyard/ (or full path Theories/Bimodal/Boneyard/)
- [ ] Update module status table:
  - Representation/ modules: Change from BROKEN to PARTIAL (compiles with sorries)
  - CompletenessTheorem.lean: Change from BROKEN to WORKING
  - Compactness.lean: Change from BROKEN to WORKING
- [ ] Update Known Issues section to mark resolved issues and add current sorry counts

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` - Fix Boneyard paths (lines 209-215), update status table (lines 113-124), update Known Issues (lines 293-304)

**Verification**:
- Grep for "Metalogic/Boneyard" returns zero results
- Status table accurately reflects current compilation state

---

### Phase 2: Update Architecture Diagram and Add Timestamp [COMPLETED]

**Goal**: Refresh architecture visualization and add documentation freshness tracking

**Tasks**:
- [ ] Update "Working Structure" diagram (lines 15-58) to show:
  - Representation/ modules as integrated (not separate/broken)
  - Current import chain: CompletenessTheorem.lean imports from Completeness.lean
  - Compactness.lean imports from both CompletenessTheorem and RepresentationTheorem
- [ ] Update "Current Structure" section (lines 168-214):
  - Remove non-existent Metalogic/Boneyard/ entry
  - Fix status markers for CompletenessTheorem.lean and Compactness.lean
- [ ] Update "Two parallel structures" description (lines 8-12) to reflect unified architecture
- [ ] Add prominent Last Updated timestamp (update line 362 or add new metadata section)

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` - Architecture diagram, directory structure, Last Updated

**Verification**:
- Architecture diagram matches actual import chain
- Last Updated date is current
- Directory structure section matches actual filesystem

## Testing & Validation

- [ ] Verify no references to non-existent Metalogic/Boneyard/ remain
- [ ] Verify module status table matches lean diagnostic output
- [ ] Verify architecture diagram matches actual import relationships
- [ ] Verify Last Updated timestamp is present and current

## Artifacts & Outputs

- Updated `Theories/Bimodal/Metalogic/README.md` with accurate documentation
- `specs/546_documentation_update/summaries/implementation-summary-YYYYMMDD.md` (completion summary)

## Rollback/Contingency

If documentation updates cause confusion or are inaccurate:
1. Revert README.md using `git checkout HEAD~1 -- Theories/Bimodal/Metalogic/README.md`
2. Re-verify codebase state against diagnostic tools
3. Make incremental corrections
