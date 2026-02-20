# Implementation Plan: Task #913

- **Task**: 913 - todo_expanded_autocompletion
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/913_todo_expanded_autocompletion/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task adds automatic completion of expanded tasks to the /todo command. When all subtasks of an expanded parent task reach terminal status (completed or abandoned), the parent task should automatically transition to completed status and become eligible for archival. The implementation involves adding Step 2.7 between existing Steps 2.6 and 3, plus updates to Steps 4 (dry-run) and 7 (final output) for reporting.

### Research Integration

Integrated findings from research-001.md:
- Insertion point identified: after Step 2.6 (Detect Misplaced Directories), before Step 3 (Prepare Archive List)
- Expanded task schema documented: `status: "expanded"` with `subtasks: [N1, N2, ...]` array
- Terminal subtask statuses: `completed` and `abandoned`
- Safe jq patterns required (Issue #1132): avoid `!=` operator, use `has()` or `| not` patterns
- Live example: Task 906 expanded into 907-911

## Goals & Non-Goals

**Goals**:
- Auto-complete expanded tasks when ALL subtasks reach terminal status (completed or abandoned)
- Update both state.json and TODO.md consistently for auto-completed tasks
- Add auto-completed expanded tasks to the archivable tasks list
- Report auto-completed tasks in dry-run output (Step 4)
- Report auto-completed tasks in final output (Step 7)

**Non-Goals**:
- Recursive expansion handling (if a subtask is itself expanded, that is a future enhancement)
- Manual override to prevent auto-completion
- Notification or warning before auto-completion

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| jq Issue #1132 with `!=` operator | Medium | High | Use `has()` and `| not` patterns per jq-escaping-workarounds.md |
| Missing subtask in state.json | Low | Low | Treat missing subtasks as "completed" (they may have been manually deleted or archived) |
| Race condition with concurrent archival | Low | Low | /todo requires exclusive access per command header |
| TODO.md edit fails | Medium | Low | Use specific old_string patterns for reliable edit matching |

## Implementation Phases

### Phase 1: Add Step 2.7 - Auto-Complete Expanded Tasks [COMPLETED]

- **Dependencies:** None
- **Goal:** Add the core Step 2.7 logic to detect and auto-complete expanded tasks

**Tasks**:
- [ ] Read `.claude/commands/todo.md` to identify exact insertion point
- [ ] Insert new Step 2.7 section after Step 2.6 with:
  - [ ] Scan state.json for tasks with `status == "expanded"`
  - [ ] For each expanded task, retrieve its `subtasks` array
  - [ ] Check each subtask status (handle missing subtasks as completed)
  - [ ] If all subtasks are terminal (completed/abandoned), mark parent as completed
  - [ ] Update state.json with status change and completion_summary
  - [ ] Update TODO.md: change `[EXPANDED]` to `[COMPLETED]`, add Completed date
  - [ ] Track auto-completed tasks in `auto_completed_expanded[]` array
  - [ ] Count completed vs abandoned subtasks for summary generation

**Timing:** 1 hour

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 2.7 section (approximately 60-80 lines)

**Verification**:
- Step 2.7 exists between Step 2.6 and Step 3
- jq patterns use safe Issue #1132 workarounds
- Auto-completed tasks added to archivable list

---

### Phase 2: Update Step 4 - Dry Run Output [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Add auto-completed expanded tasks section to dry-run output

**Tasks**:
- [ ] Locate Step 4 (Dry Run Output) in todo.md
- [ ] Add new section after orphans/misplaced reporting:
  ```
  Auto-completed expanded tasks: {N}
  - #{N1}: {title} (all {X} subtasks finished: {Y} completed, {Z} abandoned)
  ```
- [ ] Condition section on `auto_completed_expanded[]` being non-empty
- [ ] Include subtask breakdown in output

**Timing:** 20 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Update Step 4 section

**Verification**:
- Dry-run output includes auto-completed expanded tasks section
- Section omitted when no tasks auto-completed

---

### Phase 3: Update Step 7 - Final Output [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Add auto-completed expanded tasks section to final output

**Tasks**:
- [ ] Locate Step 7 (Output) in todo.md
- [ ] Add new section after orphans/misplaced reporting:
  ```
  Auto-completed expanded tasks: {N}
  - #{N1}: {title} ({Y} completed, {Z} abandoned)
  ```
- [ ] Condition section on `auto_completed_expanded[]` being non-empty
- [ ] Update Notes section if needed to document the feature

**Timing:** 20 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Update Step 7 section

**Verification**:
- Final output includes auto-completed expanded tasks section
- Section omitted when no tasks auto-completed

---

### Phase 4: Add Notes Section Documentation [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Document the auto-completion feature in the Notes section

**Tasks**:
- [ ] Add "### Auto-Completion of Expanded Tasks" subsection to Notes
- [ ] Document:
  - When auto-completion triggers (all subtasks terminal)
  - Terminal statuses: completed, abandoned
  - Handling of missing subtasks (treated as completed)
  - Auto-generated completion_summary format
  - Integration with archival workflow

**Timing:** 20 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Add Notes subsection

**Verification**:
- Notes section documents auto-completion behavior
- Edge cases documented

## Testing & Validation

- [ ] Step 2.7 correctly detects expanded tasks with all terminal subtasks
- [ ] state.json updated with `status: "completed"` and `completion_summary`
- [ ] TODO.md updated with `[COMPLETED]` marker and Completed date
- [ ] Dry-run output shows auto-completed tasks when applicable
- [ ] Final output shows auto-completed tasks when applicable
- [ ] Safe jq patterns used throughout (no `!=` operator)
- [ ] Notes section documents the feature

## Artifacts & Outputs

- `.claude/commands/todo.md` - Updated with Steps 2.7, 4 modifications, 7 modifications, and Notes

## Rollback/Contingency

If implementation causes issues:
1. Revert changes to `.claude/commands/todo.md` using git
2. Expanded tasks will remain in `[EXPANDED]` status until manually updated
3. No data loss since auto-completion only changes status, not artifacts
