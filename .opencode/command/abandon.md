---
name: abandon
agent: orchestrator
description: "Mark tasks as [ABANDONED] with reason"
context_level: 2
language: markdown
routing:
  language_based: false
  target_agent: status-sync-manager
timeout: 300
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
    - "core/standards/command-argument-handling.md"
  max_context_size: 50000
---

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Abandon command with direct routing to status-sync-manager</system_context>
  <task_context>Parse task number and reason, validate, delegate to status-sync-manager</task_context>
</context>

<role>Abandon command agent - Parse arguments and mark tasks as [ABANDONED]</role>

<task>
  Parse task number and optional reason from $ARGUMENTS, validate task exists and status allows abandonment, prompt for reason if needed, delegate to status-sync-manager for atomic updates
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and reason, validate task and status</action>
    <process>
      1. Parse task number from $ARGUMENTS
         - $ARGUMENTS contains: "298" or "298 No longer needed"
         - Extract first token as task_number
         - Validate is positive integer
      
      2. Parse reason from $ARGUMENTS
         - Extract remaining tokens after task_number as reason
         - If reason is empty: Prompt user for reason
         - Handle non-interactive mode (require inline reason)
      
      3. Prompt for reason if not provided inline
         - Check if stdin is interactive: [ -t 0 ]
         - If non-interactive and no reason: Error "Reason required in non-interactive mode"
         - If interactive and no reason: Prompt with read -r -t 30
         - If timeout: Error "Reason prompt timed out after 30 seconds"
      
      4. Validate reason
         - Strip leading/trailing whitespace
         - Strip newlines and control characters
         - Validate length: 10-500 characters
         - Validate contains only printable ASCII
      
      5. Validate state.json exists and is valid
         - Check .opencode/specs/state.json exists
         - Validate is valid JSON with jq
         - If missing/corrupt: Return error "Run /meta to regenerate state.json"
      
      6. Lookup task in state.json
         - Use jq to find task by project_number:
           task_data=$(jq -r --arg num "$task_number" \
             '.active_projects[] | select(.project_number == ($num | tonumber))' \
             .opencode/specs/state.json)
         - If task_data is empty: Return error "Task $task_number not found"
      
      7. Extract current status from task_data
         - status=$(echo "$task_data" | jq -r '.status')
         - project_name=$(echo "$task_data" | jq -r '.project_name')
         - description=$(echo "$task_data" | jq -r '.description // ""')
      
      8. Validate status allows abandonment
         - If status is "completed": Error "Cannot abandon completed tasks"
         - If status is "abandoned": Error "Task already abandoned"
         - If status is "not_started": Error "Cannot abandon work that hasn't started. Use /todo to remove task instead."
         - Valid statuses: in_progress, researched, planned, blocked
      
      9. Generate timestamp
         - timestamp=$(date -I)
    </process>
    <checkpoint>Task validated, reason captured, status transition validated</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to status-sync-manager for atomic updates</action>
    <process>
      1. Generate session_id
         - session_id=sess_$(date +%Y%m%d)_$(openssl rand -hex 3)
      
      2. Prepare delegation context
         - operation: "update_status"
         - task_number: {number}
         - new_status: "abandoned"
         - timestamp: {iso_timestamp}
         - abandonment_reason: {reason}
         - session_id: {session_id}
         - delegation_depth: 1
         - delegation_path: ["orchestrator", "abandon", "status-sync-manager"]
      
      3. Invoke status-sync-manager via task tool
         task(
           subagent_type="status-sync-manager",
           prompt="Update task ${task_number} status to [ABANDONED]. Reason: ${reason}",
           description="Mark task ${task_number} as abandoned"
         )
      
      4. Wait for status-sync-manager to complete
      
      5. Validate return format
         - Check return is valid JSON
         - Extract status field
      
      6. Handle result
         - If status == "completed": Display success message
         - If status == "failed": Display error message and exit 1
      
      7. Relay result to user
         - Success: "Task {number} marked as [ABANDONED]"
         - Success: "Reason: {reason}"
         - Success: "Files updated: TODO.md, state.json"
    </process>
    <checkpoint>Delegated to status-sync-manager, result relayed</checkpoint>
  </stage>
</workflow_execution>

## Usage

```bash
/abandon TASK_NUMBER [REASON]
/abandon 298
/abandon 298 "No longer needed due to architectural changes"
```

## What This Does

1. Parses task number and optional reason from arguments
2. Validates task exists in state.json (8x faster than TODO.md parsing)
3. Validates status allows abandonment (not completed, not already abandoned, not not_started)
4. Prompts for reason if not provided inline (interactive mode only)
5. Validates reason length (10-500 characters)
6. Delegates to status-sync-manager for atomic updates
7. Updates task status to [ABANDONED] in both TODO.md and state.json
8. Stores abandonment reason in both files
9. Returns success or error message

## Status Transition Rules

**Valid Transitions to [ABANDONED]:**
- [IN PROGRESS] → [ABANDONED] (work started but abandoned)
- [RESEARCHED] → [ABANDONED] (research done but abandoned)
- [PLANNED] → [ABANDONED] (plan created but abandoned)
- [BLOCKED] → [ABANDONED] (blocked work abandoned)

**Invalid Transitions:**
- [COMPLETED] → [ABANDONED] (cannot abandon completed work)
- [ABANDONED] → [ABANDONED] (already abandoned)
- [NOT STARTED] → [ABANDONED] (cannot abandon work never started - use /todo to remove)

## Arguments

- `TASK_NUMBER` (required): Task number from TODO.md
- `REASON` (optional): Abandonment reason (10-500 characters)
  - If not provided inline, user will be prompted (interactive mode only)
  - In non-interactive mode (scripts/pipelines), reason must be provided inline

## Examples

```bash
# Abandon with inline reason
/abandon 298 "No longer needed due to architectural changes"

# Abandon with prompted reason (interactive mode)
/abandon 298
> No longer needed due to architectural changes

# Error: Task not found
/abandon 9999
# Error: Task 9999 not found in state.json

# Error: Task already completed
/abandon 221
# Error: Task 221 is [COMPLETED]. Cannot abandon completed tasks.

# Error: Task not started
/abandon 260
# Error: Task 260 is [NOT STARTED]. Cannot abandon work that hasn't started. Use /todo to remove task instead.

# Error: Reason too short
/abandon 298 "short"
# Error: Abandonment reason too short (minimum 10 characters)
```

## Error Handling

**Invalid Task Number:**
```
Error: Task number must be a positive integer. Got: {input}
Usage: /abandon TASK_NUMBER [REASON]
```

**Task Not Found:**
```
Error: Task {number} not found in state.json
Recommendation: Verify task number exists in TODO.md or run /meta to regenerate state.json
```

**Task Already Completed:**
```
Error: Task {number} is [COMPLETED]. Cannot abandon completed tasks.
Recommendation: Completed tasks are terminal and cannot be abandoned.
```

**Task Already Abandoned:**
```
Error: Task {number} is already [ABANDONED]
Recommendation: Task has already been abandoned. No action needed.
```

**Task Not Started:**
```
Error: Task {number} is [NOT STARTED]. Cannot abandon work that hasn't started.
Recommendation: Use /todo to remove tasks that haven't been started.
```

**Missing Reason (Non-Interactive):**
```
Error: Abandonment reason required in non-interactive mode
Usage: /abandon TASK_NUMBER REASON
```

**Reason Prompt Timeout:**
```
Error: Reason prompt timed out after 30 seconds
Recommendation: Provide reason inline: /abandon {number} "reason"
```

**Reason Too Short:**
```
Error: Abandonment reason too short (minimum 10 characters)
Current length: {length} characters
Recommendation: Provide a meaningful reason for abandonment
```

**Reason Too Long:**
```
Error: Abandonment reason too long (maximum 500 characters)
Current length: {length} characters
Recommendation: Shorten reason to 500 characters or less
```

**State File Missing/Corrupt:**
```
Error: state.json missing or corrupt
Recommendation: Run /meta to regenerate state.json
```

**Status Sync Failed:**
```
Error: Failed to update task status
Details: {error_message}
Recommendation: Check file permissions and retry
```

## Delegation

**Target Agent:** `status-sync-manager` (`.opencode/agent/subagents/status-sync-manager.md`)  
**Timeout:** 300s (5 minutes)  
**Direct Routing:** Yes (no intermediate agent)

**status-sync-manager Responsibilities:**
- Validate status transition (defense in depth)
- Update TODO.md status marker to [ABANDONED]
- Add abandonment reason to TODO.md
- Add abandoned timestamp to TODO.md
- Update state.json status field to "abandoned"
- Add abandonment_reason field to state.json
- Add abandoned timestamp to state.json
- Perform atomic updates (both files or neither)
- Rollback on failure

## Quality Standards

**Atomic Updates:**
- TODO.md and state.json updated atomically via status-sync-manager
- Both files updated or neither (rollback on failure)
- Consistent status across all tracking files

**Reason Quality:**
- Minimum 10 characters (ensure meaningful reason)
- Maximum 500 characters (keep concise)
- Printable ASCII only (avoid formatting issues)
- No newlines or control characters (clean storage)

**Error Messages:**
- Clear and actionable for all failure cases
- Include recommendations for resolution
- Follow same format as other commands

**User Experience:**
- Support both inline and prompted reason entry
- Fast task lookup using state.json (8x faster than TODO.md)
- Non-interactive mode detection and handling
- Timeout protection for prompts (30 seconds)

## Notes

- **Atomic Updates**: Delegates to status-sync-manager for consistency across TODO.md and state.json
- **No Git Commit**: status-sync-manager handles git workflow (no separate commit needed)
- **Reason Required**: Abandonment reason is mandatory and stored in both files for audit trail
- **Status Validation**: Command validates status transition before delegation (fail fast)
- **Defense in Depth**: status-sync-manager also validates status transition (redundant check)
- **Non-Interactive Mode**: Detects non-interactive mode and requires inline reason
- **Prompt Timeout**: 30-second timeout prevents hanging in edge cases
- **Special Characters**: Strips newlines and control characters, validates printable ASCII
- **Fast Lookup**: Uses state.json for task lookup (8x faster than TODO.md parsing)
- **Consistent Patterns**: Follows same two-stage pattern as /plan, /implement, /research commands

## See Also

- `.opencode/agent/subagents/status-sync-manager.md` - Atomic status update implementation
- `.opencode/command/implement.md` - Similar command pattern
- `.opencode/command/plan.md` - Similar command pattern
- `.opencode/command/research.md` - Similar command pattern
- `.opencode/context/core/system/state-management.md` - State management documentation
