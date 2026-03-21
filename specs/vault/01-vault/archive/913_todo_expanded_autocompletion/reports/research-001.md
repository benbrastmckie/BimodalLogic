# Research Report: Task #913

**Task**: 913 - todo_expanded_autocompletion
**Date**: 2026-02-19
**Language**: meta
**Session**: sess_1771544824_dcc135

## Summary

The /todo command needs a new Step 2.7 (between Steps 2.6 and 3) to auto-complete expanded tasks when all their subtasks finish. This involves querying state.json for expanded tasks, checking subtask statuses, and updating both state.json and TODO.md when all subtasks are completed or abandoned.

## Findings

### 1. Current /todo Command Structure

The `/todo` command is defined in `.claude/commands/todo.md` with the following relevant steps:

| Step | Description |
|------|-------------|
| 2 | Scan for Archivable Tasks (completed/abandoned) |
| 2.5 | Detect Orphaned Directories |
| 2.6 | Detect Misplaced Directories |
| 3 | Prepare Archive List |
| 3.5 | Scan Roadmap for Task References |
| 3.6 | Scan Meta Tasks for CLAUDE.md Suggestions |
| 4 | Dry Run Output |
| ... | ... |
| 7 | Final Output |

**Insertion Point**: The new Step 2.7 should be inserted immediately after Step 2.6 (Detect Misplaced Directories) and before Step 3 (Prepare Archive List).

### 2. Expanded Task Data Model

From examining `specs/state.json`, expanded tasks use:

**Parent Task Schema** (status: "expanded"):
```json
{
  "project_number": 906,
  "project_name": "box_admissible_histories_omega_closure",
  "status": "expanded",
  "language": "lean",
  "subtasks": [907, 908, 909, 910, 911]
}
```

**Subtask Schema** (with parent_task reference):
```json
{
  "project_number": 907,
  "project_name": "phase1_truth_omega_parameter",
  "status": "completed",
  "language": "lean",
  "parent_task": 906,
  "completion_summary": "..."
}
```

**Key Fields**:
- `status: "expanded"` - Identifies parent tasks that have been divided into subtasks
- `subtasks: [N1, N2, ...]` - Array of subtask project_numbers
- `parent_task: N` - Reference from subtask to parent (inverse relationship)

### 3. Current Live Example

Task 906 is currently in `status: "expanded"` with subtasks:
- Task 907: `status: "completed"`
- Task 908: `status: "completed"`
- Task 909: `status: "completed"`
- Task 910: `status: "completed"`
- Task 911: `status: "implementing"` (NOT completed yet)

Once Task 911 completes, Task 906 should be eligible for auto-completion.

### 4. jq Patterns for Implementation

**Safe jq patterns** must be used (Issue #1132 workarounds from `.claude/context/core/patterns/jq-escaping-workarounds.md`):

**Pattern 1: Find expanded tasks**
```bash
# Get expanded tasks
expanded_tasks=$(jq -c '.active_projects[] | select(.status == "expanded")' specs/state.json)
```

**Pattern 2: Check subtask statuses**
```bash
# For a given expanded task, check if all subtasks are terminal
# Using "| not" pattern instead of "!=" for safety
subtasks=$(echo "$task_data" | jq -r '.subtasks[]')
all_terminal=true
for subtask_num in $subtasks; do
  subtask_status=$(jq -r --arg num "$subtask_num" \
    '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
    specs/state.json)
  # Safe pattern using "| not"
  if [ "$subtask_status" != "completed" ] && [ "$subtask_status" != "abandoned" ]; then
    all_terminal=false
    break
  fi
done
```

**Pattern 3: Update expanded task to completed**
```bash
# Mark expanded task as completed when all subtasks finish
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg num "$task_number" \
  '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
    status: "completed",
    last_updated: $ts,
    completed: $ts,
    completion_summary: "All subtasks completed/abandoned"
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

### 5. Status Values for Terminal Subtask Check

From `.claude/rules/state-management.md`, the terminal statuses for subtasks are:
- `completed` - Subtask finished successfully
- `abandoned` - Subtask was abandoned

**Non-terminal statuses** that block parent completion:
- `not_started`, `researching`, `researched`, `planning`, `planned`, `implementing`, `partial`, `blocked`

### 6. TODO.md Status Marker Updates

The TODO.md entry for an expanded task shows `[EXPANDED]`. When auto-completing:
- Change `[EXPANDED]` to `[COMPLETED]`
- Add `- **Completed**: {ISO date}` field

Example transformation:
```markdown
# Before
### 906. Box admissible histories omega closure
- **Status**: [EXPANDED]
- **Language**: lean

# After
### 906. Box admissible histories omega closure
- **Status**: [COMPLETED]
- **Completed**: 2026-02-19
- **Language**: lean
```

### 7. Integration with Existing Steps

**Step 3 (Prepare Archive List) Impact**:
Auto-completed expanded tasks should be added to the archivable tasks list, so they get processed in subsequent steps (roadmap updates, directory moves, etc.).

**Step 4 (Dry Run Output) Impact**:
Add new section:
```
Auto-completed expanded tasks:
- #{N1}: {title} (all {X} subtasks finished)
```

**Step 7 (Final Output) Impact**:
Add new section:
```
Auto-completed expanded tasks: {N}
- #{N1}: {title} (4 completed, 1 abandoned)
```

### 8. Edge Cases

1. **Some subtasks abandoned**: Still auto-complete parent if ALL subtasks are terminal
2. **Nested expansion**: A subtask could itself be expanded - recursively check
3. **Missing subtasks**: If a subtask number in the array doesn't exist in active_projects, it may have been manually deleted or already archived - treat as "completed"
4. **Partial subtask archival**: If some subtasks were already archived, they won't be in active_projects - need to check archive/state.json or treat missing as "completed"

### 9. Proposed Step 2.7 Algorithm

```
Step 2.7: Auto-Complete Expanded Tasks

1. Scan state.json for tasks with status = "expanded"
2. For each expanded task:
   a. Get subtasks array
   b. For each subtask number:
      - Look up in active_projects
      - If not found, check archive/state.json completed_projects
      - If not found anywhere, treat as completed (manual deletion)
      - Record status
   c. Check if ALL subtasks have terminal status (completed OR abandoned)
   d. If all terminal:
      - Update expanded task status to "completed" in state.json
      - Set completion_summary with subtask breakdown
      - Update TODO.md to change [EXPANDED] to [COMPLETED]
      - Add to auto_completed_expanded list for reporting
3. Track:
   - auto_completed_expanded[]: Array of auto-completed task data
   - auto_completed_count: Count for reporting
```

## Recommendations

### Implementation Approach

1. **Add Step 2.7** immediately after Step 2.6 in todo.md
2. **Update Step 3** to include auto-completed expanded tasks in archivable list
3. **Update Step 4** (dry run) to show auto-completed expanded tasks section
4. **Update Step 7** (final output) to report auto-completed expanded tasks

### jq Safety

Use these patterns consistently:
- `select(.status == "expanded")` for finding expanded tasks
- Avoid `!=` operator - use shell comparisons or `| not` pattern
- Two-step updates if complex artifact manipulation needed

### Completion Summary Generation

When auto-completing, generate a summary like:
```
"All 5 subtasks finished: 4 completed, 1 abandoned"
```

This provides context for the expanded task's archival without requiring manual input.

## References

- `.claude/commands/todo.md` - Main todo command definition (Steps 2-7)
- `.claude/commands/task.md` - Task expand mode (--expand flag)
- `.claude/context/core/patterns/jq-escaping-workarounds.md` - Safe jq patterns
- `.claude/rules/state-management.md` - Status transitions and state.json schema
- `specs/state.json` - Live example: Task 906 expanded into 907-911

## Next Steps

Run `/plan 913` to create an implementation plan covering:
1. Step 2.7 insertion in todo.md
2. Step 4 dry run output update
3. Step 7 final output update
4. Step 3 archive list integration
