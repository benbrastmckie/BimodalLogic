---
name: abandon
agent: orchestrator
description: "Mark tasks as [ABANDONED]"
timeout: 60
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/abandon 298`)

<context>
  <system_context>Abandon command with atomic status updates</system_context>
  <task_context>Parse task number, validate, update status to [ABANDONED] in TODO.md and state.json</task_context>
</context>

<role>Abandon command - Mark tasks as [ABANDONED]</role>

<task>
  Parse task number from $ARGUMENTS, validate task exists, delegate to status-sync-manager to update status to [ABANDONED]
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and validate task exists</action>
    <process>
      1. Parse task number from $ARGUMENTS
         - $ARGUMENTS contains: "298"
         - Extract first token as task_number
         - Validate is positive integer
         - If invalid: Return error "Task number must be a positive integer"
      
      2. Validate state.json exists and is valid
         - Check .opencode/specs/state.json exists
         - If missing: Return error "Run /meta to regenerate state.json"
      
      3. Lookup task in state.json
         - Find task by project_number
         - If not found: Return error "Task {number} not found"
      
      4. Extract current status
         - Get status field from task
         - Get project_name and description for display
      
      5. Validate status allows abandonment
         - If status is "completed": Return error "Cannot abandon completed tasks"
         - If status is "abandoned": Return error "Task already abandoned"
         - Valid statuses: not_started, in_progress, researched, planned, blocked
    </process>
    <checkpoint>Task validated, status allows abandonment</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to status-sync-manager for atomic updates</action>
    <process>
      1. Invoke status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="Update task {task_number} status to [ABANDONED]",
           description="Mark task {task_number} as abandoned"
         )
      
      2. Wait for status-sync-manager to complete
      
      3. Relay result to user:
         - Success: "Task {number} marked as [ABANDONED]"
         - Success: "Files updated: TODO.md, state.json"
    </process>
    <checkpoint>Delegated to status-sync-manager, result relayed</checkpoint>
  </stage>
</workflow_execution>

## Usage

```bash
/abandon TASK_NUMBER
/abandon 298
```

## What This Does

1. Parses task number from $ARGUMENTS
2. Validates task exists in state.json
3. Validates status allows abandonment (not completed, not already abandoned)
4. Delegates to status-sync-manager for atomic updates
5. Updates task status to [ABANDONED] in both TODO.md and state.json
6. Returns success or error message

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
# Abandon task
/abandon 298
# → Task 298 marked as [ABANDONED]
# → Files updated: TODO.md, state.json

# Error: Task not found
/abandon 9999
# → Error: Task 9999 not found

# Error: Task already completed
/abandon 221
# → Error: Cannot abandon completed tasks
```

## Error Handling

**Invalid Task Number:**
```
Error: Task number must be a positive integer
Usage: /abandon TASK_NUMBER
```

**Task Not Found:**
```
Error: Task {number} not found
Recommendation: Verify task number exists in TODO.md
```

**Task Already Completed:**
```
Error: Cannot abandon completed tasks
Recommendation: Completed tasks are terminal and cannot be abandoned
```

**Task Already Abandoned:**
```
Error: Task already abandoned
Recommendation: Task has already been abandoned
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

**status-sync-manager Responsibilities:**
- Update TODO.md status marker to [ABANDONED]
- Update state.json status field to "abandoned"
- Perform atomic updates (both files or neither)
- Rollback on failure

## Notes

- **Atomic Updates**: Delegates to status-sync-manager for consistency across TODO.md and state.json
- **No Reason Required**: Simplified version does not require abandonment reason
- **Fast Lookup**: Uses state.json for task lookup
- **Consistent Pattern**: Follows same two-stage pattern as /task and /research commands
- **Simplified**: Removed interactive prompting, reason validation, and complex error handling

## See Also

- `.opencode/agent/subagents/status-sync-manager.md` - Atomic status update implementation
- `.opencode/command/task.md` - Similar command pattern
- `.opencode/command/research.md` - Similar command pattern
