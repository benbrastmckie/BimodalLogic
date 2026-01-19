# Implementation Plan: Task #595

- **Task**: 595 - Remove Maintenance Directory and Fix Review State Management
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/595_remove_maintenance_dir_fix_review_state/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task addresses two related cleanup items: removing the unused `specs/maintenance/` directory and associated documentation, and adding state management to the `/review` command. The maintenance directory contains legacy artifacts from a workflow that was never fully implemented, while the review command currently lacks the state tracking that other commands have. Implementation follows a bottom-up approach: remove dead code first, then add new functionality to the review workflow.

### Research Integration

Key findings from research-001.md:
- 28 files reference `specs/maintenance/` but no active command uses the directory
- The `/review` command creates reports but does not maintain `reviews/state.json`
- Existing `archive/state.json` provides a pattern for the new state file schema
- The review command already has a git commit step (Step 7) but implementation details are incomplete

## Goals & Non-Goals

**Goals**:
- Remove `specs/maintenance/` directory and all documentation references
- Create `specs/reviews/state.json` with review history tracking
- Update `/review` command to maintain state and commit changes
- Clean up related documentation files

**Non-Goals**:
- Modifying review report format or content
- Changing review categorization logic
- Creating a new `/maintenance` command
- Migrating historical maintenance data

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking hidden dependencies on maintenance/ | Medium | Low | Grep search confirmed no active command usage |
| Review state schema incompatibility | Medium | Low | Design based on existing archive/state.json pattern |
| Incomplete documentation cleanup | Low | Medium | Systematic search and checklist approach |
| Git commit step conflicts | Low | Low | Test commit flow after changes |

## Implementation Phases

### Phase 1: Remove Maintenance Directory and Core References [COMPLETED]

**Goal**: Delete the unused maintenance directory and remove its primary documentation references.

**Tasks**:
- [ ] Archive `specs/maintenance/maintenance-report-20251224.md` content for reference (copy to a comment or temporary location if historical value is needed)
- [ ] Delete `specs/maintenance/` directory entirely
- [ ] Delete `.claude/context/project/lean4/processes/maintenance-workflow.md`
- [ ] Delete `.claude/context/project/lean4/templates/maintenance-report-template.md`
- [ ] Update `.claude/context/core/templates/state-template.json` to remove `maintenance_state_path` reference

**Timing**: 30 minutes

**Files to modify**:
- `specs/maintenance/` - DELETE directory
- `.claude/context/project/lean4/processes/maintenance-workflow.md` - DELETE file
- `.claude/context/project/lean4/templates/maintenance-report-template.md` - DELETE file
- `.claude/context/core/templates/state-template.json` - EDIT to remove maintenance reference

**Verification**:
- `specs/maintenance/` no longer exists
- Deleted documentation files no longer present
- state-template.json parses correctly without maintenance reference

---

### Phase 2: Clean Up Secondary Documentation References [COMPLETED]

**Goal**: Remove maintenance references from remaining documentation and context files.

**Tasks**:
- [ ] Update `.claude/context/project/repo/self-healing-implementation-details.md` to remove maintenance references
- [ ] Search for any remaining `maintenance/` references in `.claude/` directory
- [ ] Verify no stale imports or links remain in context/index.md or other index files
- [ ] Check if `.opencode/` and `.opencode_NEW/` directories should be removed (discuss with user or note as separate task)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/repo/self-healing-implementation-details.md` - EDIT to remove maintenance references
- Any other files found with stale references

**Verification**:
- `grep -r "specs/maintenance" .claude/` returns no results
- `grep -r "maintenance-workflow" .claude/` returns no results
- All modified files remain syntactically valid

---

### Phase 3: Create Reviews State Schema and Initial State [IN PROGRESS]

**Goal**: Design and create the `specs/reviews/state.json` file with proper schema.

**Tasks**:
- [ ] Create `specs/reviews/state.json` with schema following existing patterns
- [ ] Populate with entries for existing review reports (3 existing reviews)
- [ ] Add schema version and metadata fields
- [ ] Validate JSON syntax

**Timing**: 45 minutes

**Files to modify**:
- `specs/reviews/state.json` - CREATE new file

**Verification**:
- `specs/reviews/state.json` exists and parses as valid JSON
- Schema includes: `_schema_version`, `_last_updated`, `reviews` array, `statistics` object
- Each existing review has an entry in the reviews array

**Schema**:
```json
{
  "_schema_version": "1.0.0",
  "_comment": "Review state tracking for code review history",
  "_last_updated": "ISO_TIMESTAMP",
  "reviews": [
    {
      "review_id": "review-YYYYMMDD",
      "date": "ISO_DATE",
      "scope": "all|path|file",
      "report_path": "specs/reviews/review-YYYYMMDD.md",
      "summary": {
        "files_reviewed": 0,
        "critical_issues": 0,
        "high_issues": 0,
        "medium_issues": 0,
        "low_issues": 0
      },
      "tasks_created": [],
      "registries_updated": []
    }
  ],
  "statistics": {
    "total_reviews": 0,
    "last_review": "ISO_DATE",
    "total_issues_found": 0,
    "total_tasks_created": 0
  }
}
```

---

### Phase 4: Update Review Command for State Management [NOT STARTED]

**Goal**: Modify the `/review` command to maintain `reviews/state.json` and properly commit changes.

**Tasks**:
- [ ] Add step to read existing `specs/reviews/state.json` at start (or create if missing)
- [ ] Add step to update state.json after creating review report
- [ ] Update state entry with review metadata (scope, date, issue counts, tasks created)
- [ ] Update statistics section with aggregate counts
- [ ] Enhance git commit step to include state.json changes
- [ ] Add state.json to git add command

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/review.md` - EDIT to add state management steps

**Verification**:
- Command documentation includes state management steps
- Git commit step explicitly adds `specs/reviews/state.json`
- State update logic documented between report creation (Step 4) and git commit (Step 7)

---

### Phase 5: Documentation and Final Verification [NOT STARTED]

**Goal**: Update related documentation and verify all changes work together.

**Tasks**:
- [ ] Update `.claude/CLAUDE.md` if it references maintenance workflow
- [ ] Update any context index files that referenced deleted files
- [ ] Run final grep search for orphaned maintenance references
- [ ] Test that specs/reviews/ directory structure is correct
- [ ] Verify state.json schema is consistent with documentation

**Timing**: 30 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - CHECK and potentially EDIT
- `.claude/context/index.md` - CHECK and potentially EDIT

**Verification**:
- `grep -ri "maintenance" .claude/ specs/` returns only this task's files
- `specs/reviews/state.json` is valid and populated
- `/review` command documentation is complete and accurate
- No broken links in context files

## Testing & Validation

- [ ] `grep -r "specs/maintenance" .` returns only this task's references
- [ ] `specs/reviews/state.json` parses as valid JSON
- [ ] `jq '.' specs/reviews/state.json` succeeds
- [ ] All modified markdown files have valid syntax
- [ ] Git status shows expected changes (deletions and modifications)

## Artifacts & Outputs

- `specs/595_remove_maintenance_dir_fix_review_state/plans/implementation-001.md` (this file)
- `specs/595_remove_maintenance_dir_fix_review_state/summaries/implementation-summary-YYYYMMDD.md` (upon completion)
- `specs/reviews/state.json` (new file created)

## Rollback/Contingency

If implementation needs to be reverted:
1. Use `git checkout HEAD~N -- specs/maintenance/` to restore maintenance directory
2. Use `git checkout HEAD~N -- .claude/context/project/lean4/processes/maintenance-workflow.md` to restore deleted docs
3. Delete `specs/reviews/state.json` if created
4. Revert changes to `.claude/commands/review.md`

Git history preserves all deleted content, so full rollback is possible at any point.
