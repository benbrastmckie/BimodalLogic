# Implementation Plan: Task #401

**Task**: Add [EXPANDED] status for parent tasks
**Version**: 001
**Created**: 2026-01-11
**Language**: meta

## Overview

Add the `[EXPANDED]` status marker for parent tasks that have been divided into subtasks. This is a terminal-like status indicating the parent task's work is now represented by its subtasks. Implementation follows a layered approach: update primary status definition, then propagate to secondary references, then update command behavior.

## Phases

### Phase 1: Update Primary Status Definition

**Estimated effort**: 20 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add [EXPANDED] status marker definition to status-markers.md
2. Update the TODO.md vs state.json mapping table
3. Update the valid transitions diagram

**Files to modify**:
- `.claude/context/core/standards/status-markers.md`
  - Add new section after [ABANDONED] defining [EXPANDED]
  - Add row to mapping table at line ~188
  - Update transition diagram

**Steps**:
1. Read status-markers.md to find exact insertion points
2. Add [EXPANDED] definition section after [ABANDONED] section (~line 170):
   ```markdown
   #### `[EXPANDED]`
   **TODO.md Format**: `- **Status**: [EXPANDED]`
   **state.json Value**: `"status": "expanded"`
   **Meaning**: Parent task has been expanded into subtasks; work continues in subtasks.

   **Valid Transitions**:
   - `[NOT STARTED]` → `[EXPANDED]` (when task is divided into subtasks)
   - `[RESEARCHED]` → `[EXPANDED]` (when researched task is divided)
   - `[PLANNED]` → `[EXPANDED]` (when planned task is divided)
   - Any non-terminal status → `[EXPANDED]` (when divided)

   **Note**: `[EXPANDED]` is terminal-like. The parent delegates work to subtasks.

   **Required Information**:
   - `- **Subtasks**: {list}` in TODO.md
   - `"subtasks": [...]` array in state.json
   ```
3. Add row to mapping table: `| [EXPANDED] | expanded | Task expanded into subtasks |`
4. Update transition diagram to show [EXPANDED] as a terminal-like state

**Verification**:
- [EXPANDED] section exists with proper format
- Mapping table includes expanded row
- Transition diagram shows [EXPANDED]

---

### Phase 2: Update Rules and Workflow Files

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Update state-management.md with [EXPANDED] status
2. Update status-transitions.md quick reference

**Files to modify**:
- `.claude/rules/state-management.md`
  - Add to Valid Transitions section (line ~32)
  - Add row to Status Values Mapping table (line ~105)
- `.claude/context/core/workflows/status-transitions.md`
  - Add row to Status Markers table (line ~20)
  - Update Valid Transitions section

**Steps**:
1. Edit state-management.md:
   - Add `Any state → [EXPANDED] (when divided into subtasks)` to Valid Transitions
   - Add `| [EXPANDED] | expanded |` to Status Values Mapping table
2. Edit status-transitions.md:
   - Add `| Expanded | [EXPANDED] | Task expanded into subtasks |` to table
   - Add note about [EXPANDED] being terminal-like in Valid Transitions

**Verification**:
- Both files include [EXPANDED] in their tables
- Transitions properly documented

---

### Phase 3: Update Reference Files

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update CLAUDE.md quick reference
2. Update skill-status-sync Status Mapping table

**Files to modify**:
- `.claude/CLAUDE.md`
  - Line ~38: Add [EXPANDED] to terminal/exception states
- `.claude/skills/skill-status-sync/SKILL.md`
  - Line ~448: Add expand operation to Status Mapping table

**Steps**:
1. Edit CLAUDE.md Status Markers section:
   - Change `[BLOCKED], [ABANDONED], [PARTIAL]` to `[BLOCKED], [ABANDONED], [PARTIAL], [EXPANDED]`
2. Edit skill-status-sync/SKILL.md Status Mapping table:
   - Add row: `| Expand task | any (non-terminal) | expanded | status, subtasks |`

**Verification**:
- CLAUDE.md lists [EXPANDED] in terminal states
- skill-status-sync includes expand operation

---

### Phase 4: Update Command and Apply Status

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update task.md Divide Mode to set expanded status
2. Apply [EXPANDED] status to task 394 as validation

**Files to modify**:
- `.claude/commands/task.md`
  - Line ~190: Modify jq command to also set status to expanded
- `.claude/specs/state.json`
  - Update task 394 status to "expanded"
- `.claude/specs/TODO.md`
  - Update task 394 status to [EXPANDED]

**Steps**:
1. Edit task.md Divide Mode step 4 jq command:
   ```bash
   jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
       status: "expanded",
       subtasks: [list_of_subtask_numbers],
       last_updated: $ts
     }' .claude/specs/state.json > /tmp/state.json && \
     mv /tmp/state.json .claude/specs/state.json
   ```
2. Update task 394 in state.json:
   - Change `"status": "researched"` to `"status": "expanded"`
3. Update task 394 in TODO.md:
   - Change `[RESEARCHED]` to `[EXPANDED]`

**Verification**:
- task.md Divide Mode includes status: "expanded"
- Task 394 shows [EXPANDED] in TODO.md
- Task 394 shows "expanded" in state.json

---

## Dependencies

- None - this is a self-contained documentation/configuration change

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inconsistent status across files | Medium | Low | Follow phase order, verify each phase |
| Breaking existing status checks | Low | Low | [EXPANDED] is additive, not replacing |
| Task 394 state corruption | Low | Low | Use atomic jq updates |

## Success Criteria

- [ ] [EXPANDED] defined in status-markers.md
- [ ] [EXPANDED] in state-management.md mapping table
- [ ] [EXPANDED] in status-transitions.md table
- [ ] [EXPANDED] in CLAUDE.md terminal states
- [ ] [EXPANDED] in skill-status-sync mapping
- [ ] task.md Divide Mode sets expanded status
- [ ] Task 394 status is [EXPANDED]

## Rollback Plan

If issues arise:
1. Revert all file changes via git
2. Task 394 can remain at [RESEARCHED] temporarily
3. The [EXPANDED] status is purely additive - no existing functionality breaks
