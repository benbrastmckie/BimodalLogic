---
name: abandon
agent: orchestrator
description: "Mark tasks as [ABANDONED]"
timeout: 60
---

**Task Input (required):** $ARGUMENTS (task number, range, or list; e.g., `/abandon 298`, `/abandon 293-295`, `/abandon 302, 303`, `/abandon 293-295, 302, 303`)

<context>
  <system_context>Abandon command with atomic status updates and bulk operation support</system_context>
  <task_context>Parse task numbers (single, range, or list), validate all tasks, update status to [ABANDONED] in TODO.md and state.json with rollback on failure</task_context>
</context>

<role>Abandon command - Mark tasks as [ABANDONED] with support for bulk operations</role>

<task>
  Parse task numbers from $ARGUMENTS (supporting ranges and lists), validate all tasks exist and have valid status, delegate to status-sync-manager for each task to update status to [ABANDONED], with rollback on failure
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task numbers and validate all tasks exist with valid status</action>
    <process>
      1. Parse task numbers from $ARGUMENTS using parse_task_numbers()
         - Split by comma: IFS=',' read -ra PARTS <<< "$ARGUMENTS"
         - For each part (trimmed):
           * If matches range pattern ^([0-9]+)-([0-9]+)$:
             - Extract start and end
             - Validate start <= end (error if start > end)
             - Expand with seq: seq $start $end
           * If matches single number pattern ^[0-9]+$:
             - Add to task list
           * Else:
             - Return error "Invalid task number format: '{part}'"
         - Deduplicate and sort: printf '%s\n' "${task_numbers[@]}" | sort -nu
         - Convert to array for validation
         - Examples:
           * "298" → [298]
           * "293-295" → [293, 294, 295]
           * "302, 303" → [302, 303]
           * "293-295, 302, 303" → [293, 294, 295, 302, 303]
           * "293, 293-295" → [293, 294, 295] (deduplicated)
      
      2. Validate state.json exists and is valid
         - Check .opencode/specs/state.json exists
         - If missing: Return error "Run /meta to regenerate state.json"
      
      3. Validate all tasks using validate_tasks()
         - For each task number:
           * Lookup task in state.json by project_number
           * If not found: Return error "Task {number} not found"
           * Extract current status and project_name
           * Store original status in associative array for rollback
           * Validate status allows abandonment:
             - Error if status == "completed" (cannot abandon completed tasks)
             - Error if status == "abandoned" (already abandoned)
             - Allow if status in ["not_started", "in_progress", "researched", "planned", "blocked"]
         - Fail fast on first validation error
         - Log validated tasks with original status
      
      4. Display summary of tasks to abandon
         - Count: {N} tasks
         - Task numbers: {list}
    </process>
    <checkpoint>All tasks validated, status allows abandonment, original status stored for rollback</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to status-sync-manager for each task with rollback on failure</action>
    <process>
      1. Abandon tasks using abandon_tasks() with loop delegation
         - Initialize abandoned_tasks array to track progress
         - For each task number:
           * Delegate to status-sync-manager via task tool:
             task(
               subagent_type="status-sync-manager",
               prompt="Update task {task_number} status to [ABANDONED]",
               description="Mark task {task_number} as abandoned"
             )
           * Wait for status-sync-manager to complete
           * Check delegation result status
           * If success: Add task to abandoned_tasks array
           * If failure: Trigger rollback
         - Log progress during abandonment
      
      2. Implement rollback on failure
         - If any delegation fails:
           * Reverse loop through abandoned_tasks array
           * For each task: Delegate to status-sync-manager with original status
           * Log rollback attempts
           * Return error with rollback details
         - Rollback ensures atomicity: all tasks abandoned or none
      
      3. Relay result to user
         - Success: "Abandoned {N} tasks: {task_numbers}"
         - Success: "Files updated: TODO.md, state.json"
         - Failure: "Failed to abandon task {number}, rolled back {count} tasks"
    </process>
    <checkpoint>All tasks delegated to status-sync-manager, rollback performed on failure, result relayed</checkpoint>
  </stage>
</workflow_execution>

## Usage

```bash
# Single task (backward compatible)
/abandon TASK_NUMBER
/abandon 298

# Range of tasks
/abandon START-END
/abandon 293-295

# List of tasks
/abandon TASK1, TASK2, TASK3
/abandon 302, 303

# Mixed syntax (range + list)
/abandon START-END, TASK1, TASK2
/abandon 293-295, 302, 303
```

## What This Does

1. Parses task numbers from $ARGUMENTS (single, range, or list)
2. Validates all tasks exist in state.json
3. Validates all tasks have status that allows abandonment (not completed, not already abandoned)
4. Delegates to status-sync-manager for each task to update status to [ABANDONED]
5. Updates task status to [ABANDONED] in both TODO.md and state.json
6. Performs rollback on failure (restores original status for all abandoned tasks)
7. Returns success with count and task list, or error with rollback details

## Status Transition Rules

**Valid Transitions to [ABANDONED]:**
- [NOT STARTED] → [ABANDONED]
- [IN PROGRESS] → [ABANDONED]
- [RESEARCHED] → [ABANDONED]
- [PLANNED] → [ABANDONED]
- [BLOCKED] → [ABANDONED]

**Invalid Transitions:**
- [COMPLETED] → [ABANDONED] (cannot abandon completed work)
- [ABANDONED] → [ABANDONED] (already abandoned)

## Examples

```bash
# Abandon single task
/abandon 298
# → Task 298 marked as [ABANDONED]
# → Files updated: TODO.md, state.json

# Abandon range of tasks
/abandon 293-295
# → Abandoned 3 tasks: 293, 294, 295
# → Files updated: TODO.md, state.json

# Abandon list of tasks
/abandon 302, 303
# → Abandoned 2 tasks: 302, 303
# → Files updated: TODO.md, state.json

# Abandon mixed (range + list)
/abandon 293-295, 302, 303
# → Abandoned 5 tasks: 293, 294, 295, 302, 303
# → Files updated: TODO.md, state.json

# Error: Invalid range (start > end)
/abandon 295-293
# → Error: Invalid range 295-293 (start > end)

# Error: Task not found
/abandon 9999
# → Error: Task 9999 not found

# Error: Task already completed
/abandon 221
# → Error: Cannot abandon completed task 221 (project_name). Completed tasks are terminal.

# Error: Delegation failure with rollback
/abandon 293-295
# → Error: Failed to abandon task 294, rolled back 1 tasks
# → Task 293 restored to original status
```

## Error Handling

**Empty Input:**
```
Error: Task number required
Usage: /abandon TASK_NUMBER|RANGE|LIST
Examples:
  /abandon 298                    # Single task
  /abandon 293-295                # Range
  /abandon 302, 303               # List
  /abandon 293-295, 302, 303      # Mixed
```

**Invalid Format:**
```
Error: Invalid task number format: 'abc'
Expected: number (e.g., 298) or range (e.g., 293-295)
Usage: /abandon TASK_NUMBER|RANGE|LIST
Examples:
  /abandon 298                    # Single task
  /abandon 293-295                # Range
  /abandon 302, 303               # List
  /abandon 293-295, 302, 303      # Mixed
```

**Invalid Range:**
```
Error: Invalid range 295-293 (start > end)
Usage: /abandon TASK_NUMBER|RANGE|LIST
```

**Task Not Found:**
```
Error: Task {number} not found in state.json
Recommendation: Verify task number exists in TODO.md
Available tasks: {first 10 task numbers}
```

**Task Already Completed:**
```
Error: Cannot abandon completed task {number} ({project_name})
Recommendation: Completed tasks are terminal and cannot be abandoned
```

**Task Already Abandoned:**
```
Error: Task {number} already abandoned ({project_name})
Recommendation: Task has already been abandoned
```

**Delegation Failure with Rollback:**
```
Error: Failed to abandon task {number}
Rolled back {count} tasks to original status
Details: {error_message}
Recommendation: Check error details and retry
```

**Status Sync Failed:**
```
Error: Failed to update task status
Details: {error_message}
Recommendation: Check file permissions and retry
```

## Delegation

**Target Agent:** `status-sync-manager` (`.opencode/agent/subagents/status-sync-manager.md`)  
**Timeout:** 60s  
**Direct Routing:** Yes  
**Delegation Pattern:** Loop delegation (one call per task)

**status-sync-manager Responsibilities:**
- Update TODO.md status marker to [ABANDONED]
- Update state.json status field to "abandoned"
- Perform atomic updates (both files or neither)
- Rollback on failure

**Rollback Mechanism:**
- Track original status for each task before abandonment
- On delegation failure: Reverse loop through abandoned tasks
- Restore original status for each abandoned task
- Log rollback attempts and results
- Return error with rollback details

## Notes

- **Bulk Operations**: Supports ranges (e.g., `293-295`), lists (e.g., `302, 303`), and mixed syntax (e.g., `293-295, 302, 303`)
- **Backward Compatible**: Single-task syntax still works (e.g., `/abandon 298`)
- **Atomic Updates**: Delegates to status-sync-manager for consistency across TODO.md and state.json
- **Rollback on Failure**: Restores original status for all abandoned tasks if any delegation fails
- **Fail-Fast Validation**: Validates all tasks before abandoning any to prevent partial abandonment
- **Deduplication**: Automatically deduplicates task numbers (e.g., `293, 293-295` → `[293, 294, 295]`)
- **No Reason Required**: Simplified version does not require abandonment reason
- **Fast Lookup**: Uses state.json for task lookup
- **Consistent Pattern**: Follows same two-stage pattern as /task and /research commands
- **Loop Delegation**: Uses loop delegation approach (reuses existing atomic update logic, lower effort)

## Performance

- **Single task**: < 100ms (same as before)
- **5 tasks**: < 500ms (acceptable)
- **10 tasks**: < 1000ms (acceptable)
- **Timeout**: 60s (generous for bulk operations)

## See Also

- `.opencode/agent/subagents/status-sync-manager.md` - Atomic status update implementation
- `.opencode/command/task.md` - Similar command pattern
- `.opencode/command/research.md` - Similar command pattern
