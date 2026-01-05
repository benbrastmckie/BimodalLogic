---
name: abandon
agent: orchestrator
description: "Mark task as [ABANDONED] with reason"
timeout: 300
---

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Task abandonment command with status synchronization</system_context>
  <task_context>Parse task number, validate, mark as [ABANDONED] in TODO.md and state.json</task_context>
</context>

<role>Task abandonment command - Parse task number and delegate to status-sync-manager</role>

<task>
  Parse task number from $ARGUMENTS, validate task exists and is not already abandoned/completed, prompt for abandonment reason, delegate to status-sync-manager to update status to [ABANDONED]
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and validate task state</action>
    <process>
      1. Parse task number from $ARGUMENTS
         - $ARGUMENTS contains: "271" or "271 reason text"
         - Extract first token as task_number
         - Validate is integer (not range - abandon does not support batch operations)
         - If not integer: Return error "Task number must be a single integer"
      
      2. Validate state.json exists and is valid
         - Check .opencode/specs/state.json exists
         - Validate is valid JSON with jq
         - If missing/corrupt: Return error "Run /meta to regenerate state.json"
      
      3. Lookup task in state.json
         - Use jq to find task by project_number:
           task_data=$(jq -r --arg num "$task_number" \
             '.active_projects[] | select(.project_number == ($num | tonumber))' \
             .opencode/specs/state.json)
         - If task_data is empty: Return error "Task $task_number not found"
      
      4. Extract task metadata
         - status=$(echo "$task_data" | jq -r '.status')
         - project_name=$(echo "$task_data" | jq -r '.project_name')
         - description=$(echo "$task_data" | jq -r '.description // ""')
      
      5. Validate task status allows abandonment
         - If status is "completed": Return error "Task $task_number already completed. Cannot abandon completed tasks."
         - If status is "abandoned": Return error "Task $task_number already abandoned."
      
      6. Extract abandonment reason from $ARGUMENTS if present
         - If $ARGUMENTS has multiple tokens: abandonment_reason = remaining tokens after task_number
         - Else: abandonment_reason = ""
         - If abandonment_reason is empty: Prompt user for reason
           "Please provide a reason for abandoning task $task_number:"
           Read user input as abandonment_reason
         - Validate abandonment_reason is non-empty
         - If still empty: Return error "Abandonment reason is required"
    </process>
    <checkpoint>Task validated, abandonment reason obtained</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to status-sync-manager to update status</action>
    <process>
      1. Get current timestamp
         - timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
      
      2. Invoke status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="Update task ${task_number} status to abandoned. Abandonment reason: ${abandonment_reason}. Timestamp: ${timestamp}.",
           description="Mark task ${task_number} as abandoned"
         )
      
      3. Wait for status-sync-manager to complete
         Expected return: Confirmation that TODO.md and state.json updated
      
      4. Return result to user:
         "Task ${task_number} marked as [ABANDONED]"
         "Reason: ${abandonment_reason}"
         ""
         "Updated files:"
         "  - .opencode/specs/TODO.md"
         "  - .opencode/specs/state.json"
    </process>
    <checkpoint>Status updated, result returned to user</checkpoint>
  </stage>
</workflow_execution>

## Usage

```bash
/abandon TASK_NUMBER [REASON]
/abandon 271
/abandon 271 "Superseded by task 280"
/abandon 295 "Duplicate of task 296"
```

## What This Does

1. Parses task number from arguments
2. Validates task exists in state.json
3. Validates task is not already completed or abandoned
4. Prompts for abandonment reason if not provided
5. Delegates to status-sync-manager to update status to [ABANDONED]
6. Updates both TODO.md and state.json atomically

## Validation

- Task number must be a single integer (no ranges)
- Task must exist in state.json
- Task must not be already completed
- Task must not be already abandoned
- Abandonment reason is required

## Status Transitions

Valid transitions to [ABANDONED]:
- [NOT STARTED] → [ABANDONED]
- [IN PROGRESS] → [ABANDONED]
- [RESEARCHING] → [ABANDONED]
- [RESEARCHED] → [ABANDONED]
- [PLANNING] → [ABANDONED]
- [PLANNED] → [ABANDONED]
- [BLOCKED] → [ABANDONED]

Invalid transitions:
- [COMPLETED] → [ABANDONED] (cannot abandon completed work)
- [ABANDONED] → [ABANDONED] (already abandoned)

## Examples

```bash
# Abandon task with inline reason
/abandon 271 "Superseded by task 280"

# Abandon task with prompted reason
/abandon 271
# System prompts: "Please provide a reason for abandoning task 271:"
# User enters: "Duplicate of task 296"

# Error: Task already completed
/abandon 258
# Error: Task 258 already completed. Cannot abandon completed tasks.

# Error: Task already abandoned
/abandon 229
# Error: Task 229 already abandoned.

# Error: Task not found
/abandon 999
# Error: Task 999 not found
```

## Important Notes

1. Abandonment is permanent - there is no /unabandone command
2. Abandonment reason is required and will be recorded in both TODO.md and state.json
3. Abandoned tasks remain in TODO.md until archived by /todo command
4. Use /abandon for tasks that are no longer needed, superseded, or duplicates
5. For tasks that are temporarily blocked, use status update to [BLOCKED] instead
6. Batch abandonment is not supported - abandon tasks one at a time

## Version History

- **v1.0.0** (2026-01-05): Initial implementation
