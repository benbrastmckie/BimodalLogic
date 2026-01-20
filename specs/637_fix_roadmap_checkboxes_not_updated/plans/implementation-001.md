# Implementation Plan: Task #637

- **Task**: 637 - fix_roadmap_checkboxes_not_updated
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/637_fix_roadmap_checkboxes_not_updated/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Update roadmap checkboxes in `specs/ROAD_MAP.md` to reflect actual project state. Research identified 12-15 items that are demonstrably complete based on codebase evidence, with an additional 12-14 items showing significant partial progress. The file currently shows 71 unchecked items and 0 checked items, despite substantial implementation work completed in Metalogic_v2.

### Research Integration

Research report (research-001.md) provides:
- Comprehensive checkbox analysis by phase
- Evidence mapping for completed items (file paths, code artifacts)
- Recommended checkbox updates with specific line references
- Risk mitigation strategies for avoiding over-marking

## Goals & Non-Goals

**Goals**:
- Update checkboxes to `[x]` for items with file-level evidence of completion
- Add brief evidence annotations to completed items for traceability
- Update "Last Updated" date to reflect current state
- Preserve all unchecked items for future work tracking

**Non-Goals**:
- Restructuring the roadmap document
- Adding new roadmap items
- Changing the overall roadmap organization or priorities
- Marking items as partial (keep checkboxes binary: done or not done)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Over-marking items as complete | Medium | Medium | Require file-level evidence for each checkbox; verify existence before marking |
| Missing completed items | Low | Low | Cross-reference with Metalogic_v2 README and docs/ |
| Stale roadmap after update | Low | Low | Update "Last Updated" date and establish update discipline |
| Incorrect line references from research | Low | Medium | Verify line numbers before editing; use content matching |

## Implementation Phases

### Phase 1: Update Phase 4.1 Checkboxes (Architecture/Layering) [NOT STARTED]

**Goal**: Mark Phase 4.1 items as complete - the Metalogic_v2 architecture fully implements the optimal layering design

**Tasks**:
- [ ] Mark "Enforce layer discipline" as complete (evidence: Metalogic_v2 directory structure implements strict Core < Soundness < Representation < Completeness < Applications layering)
- [ ] Mark architecture restructure items complete where applicable
- [ ] Add evidence annotations referencing Metalogic_v2/README.md

**Timing**: 20 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Phase 4.1 section (approximately lines 439-490)

**Verification**:
- All Phase 4.1 checkboxes reviewed
- Evidence annotations present for marked items

---

### Phase 2: Update Phase 6 Checkboxes (Testing/Documentation) [NOT STARTED]

**Goal**: Mark completed documentation and testing items

**Tasks**:
- [ ] Mark "Create API documentation" as complete (evidence: docs/reference/API_REFERENCE.md exists, 720 lines)
- [ ] Mark "Add usage examples" as complete (evidence: API_REFERENCE.md contains examples)
- [ ] Mark "Create test suite for each major theorem" as complete (evidence: Tests/BimodalTest/Metalogic_v2/ with 10 test files)
- [ ] Add evidence annotations with file paths

**Timing**: 20 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Phase 6 section (approximately lines 612-640)

**Verification**:
- Documentation items in Phase 6.1 reviewed
- Testing items in Phase 6.3 reviewed
- Evidence annotations present for marked items

---

### Phase 3: Update Phase 1.2 and 1.3 Checkboxes (Proof Flow/Documentation) [NOT STARTED]

**Goal**: Mark completed proof flow and module documentation items

**Tasks**:
- [ ] Review Phase 1.2 items against Metalogic_v2 README import structure
- [ ] Mark "Add module overviews" partial evidence - Metalogic_v2/README.md has comprehensive overview (consider marking if sufficient)
- [ ] Review Phase 1.3 documentation items
- [ ] Mark items with clear file-level evidence

**Timing**: 20 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Phase 1.2 section (approximately lines 133-165)
- `specs/ROAD_MAP.md` - Phase 1.3 section (approximately lines 166-184)

**Verification**:
- Import cycle status verified (README confirms no cycles)
- Module overview status assessed

---

### Phase 4: Update Phase 4.2 Checkboxes (Minimal Kernel) [NOT STARTED]

**Goal**: Mark items related to representation theorem centrality

**Tasks**:
- [ ] Review "Refactor to make representation_theorem the primary export" - Metalogic_v2 implements this
- [ ] Mark applicable items in Phase 4.2 as complete
- [ ] Add evidence annotations

**Timing**: 15 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Phase 4.2 section (approximately lines 492-538)

**Verification**:
- Representation theorem centrality verified against README
- Evidence annotations present

---

### Phase 5: Update Header and Final Review [NOT STARTED]

**Goal**: Update document metadata and perform final consistency check

**Tasks**:
- [ ] Update "Last Updated" date at top of file to current date (2026-01-19)
- [ ] Review all changes for consistency
- [ ] Verify no unchecked items were accidentally modified
- [ ] Count final checkbox state (expected: ~12-15 checked, ~56-59 unchecked)

**Timing**: 15 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Header section (lines 1-5)

**Verification**:
- Last Updated date is current
- Total checked count matches evidence (~12-15)
- Document renders correctly

## Testing & Validation

- [ ] Verify all marked items have corresponding file evidence
- [ ] Verify unchecked items were not modified
- [ ] Verify checkbox syntax is correct (`- [x]` not `- [X]` or other variants)
- [ ] Count checkboxes: expect 12-15 checked, 56-59 unchecked
- [ ] Document renders correctly in markdown preview

## Artifacts & Outputs

- `specs/ROAD_MAP.md` - Updated roadmap with accurate checkbox states
- `specs/637_fix_roadmap_checkboxes_not_updated/summaries/implementation-summary-20260119.md` - Completion summary

## Rollback/Contingency

If changes introduce errors or are incorrect:
1. Use `git checkout specs/ROAD_MAP.md` to restore original
2. Re-run research to verify evidence before retrying
3. Mark fewer items as complete if evidence is ambiguous
