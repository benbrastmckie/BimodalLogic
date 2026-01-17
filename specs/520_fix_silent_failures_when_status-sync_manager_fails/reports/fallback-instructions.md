# Fallback Status Update Instructions

## Phase 5: Provide Manual Fallback When status-sync-manager Fails

### Manual Status Update Instructions

When status-sync-manager fails and workflow command returns "partial" status, users need to manually update task status. Provide these instructions in error messages:

#### Primary Method: Use /task Command
```
Manually update task status using: /task --update {task_number} --status {target_status}

Examples:
- /task --update 515 --status completed
- /task --update 516 --status in_progress  
- /task --update 517 --status failed
```

#### Alternative Method: Direct File Edit
```
Alternatively, edit TODO.md and state.json directly:

1. Open TODO.md and update task {task_number} status:
   - Find the task entry under the appropriate priority section
   - Update the status: [IN_PROGRESS] → [COMPLETED]
   - Add any completion notes if needed

2. Open .opencode/specs/state.json and update the corresponding task:
   - Find the task with matching number
   - Update "status" field to the target status
   - Update "completed_at" timestamp if completed

3. Run git commit:
   git commit TODO.md .opencode/specs/state.json -m 'Manual status update for task {task_number}'
```

### Helper Command Template

Create a helper command for manual status updates:
```bash
#!/bin/bash
# helper-manual-status-update.sh

TASK_NUMBER=$1
TARGET_STATUS=$2

if [ -z "$TASK_NUMBER" ] || [ -z "$TARGET_STATUS" ]; then
    echo "Usage: $0 <task_number> <target_status>"
    echo "Example: $0 515 completed"
    exit 1
fi

echo "Manually updating task $TASK_NUMBER to status: $TARGET_STATUS"
echo ""
echo "Method 1: Use /task command"
echo "/task --update $TASK_NUMBER --status $TARGET_STATUS"
echo ""
echo "Method 2: Manual file edit"
echo "1. Edit TODO.md - update task $TASK_NUMBER status to [$TARGET_STATUS]"
echo "2. Edit .opencode/specs/state.json - update task $TASK_NUMBER status field"
echo "3. git commit TODO.md .opencode/specs/state.json -m 'Manual status update for task $TASK_NUMBER'"
```

### When to Use Fallback vs Retry

#### Use Fallback (Manual Update) When:
- status-sync-manager returns FILE_WRITE_FAILED
- status-sync-manager returns PARSE_ERROR
- status-sync-manager returns VALIDATION_FAILED
- status-sync-manager times out (after 60s)
- Multiple retry attempts have failed

#### Use Retry When:
- status-sync-manager returns NETWORK_ERROR
- status-sync-manager returns TEMPORARY_FAILURE
- status-sync-manager returns SERVICE_UNAVAILABLE
- Error message suggests retry is appropriate

#### Retry Pattern:
```
1. First attempt: Original command
2. If fails with retryable error: Wait 5 seconds and retry
3. If fails again: Wait 30 seconds and retry
4. If fails third time: Use fallback manual update
```

### Recovery Instructions Template

For inclusion in workflow command error messages:

#### For IMPORTANT Failures:
```
Status update failed but artifacts were created successfully.

RECOVERY REQUIRED:
Manually update task status using: /task --update {task_number} --status {target_status}

Alternative: Edit TODO.md and .opencode/specs/state.json directly, then commit.
```

#### For CRITICAL Failures:
```
Critical status sync failure - workflow could not complete.

ERROR: {specific_error_details}

RECOVERY:
1. Fix the underlying issue: {fix_instructions}
2. Retry the original command: {original_command}
3. If retry fails, contact support with error details
```

### Integration with Workflow Commands

All updated workflow commands now include these instructions in their `next_steps` field when returning "partial" status:

```json
{
  "status": "partial",
  "summary": "Workflow completed but status update failed",
  "errors": [
    {
      "type": "status_sync_failed", 
      "code": "FILE_WRITE_FAILED",
      "message": "Failed to update TODO.md: Permission denied",
      "severity": "important"
    }
  ],
  "next_steps": "Review artifacts. Manually update task status: /task --update {task_number} --status completed"
}
```

### Testing Fallback Instructions

Test scenarios to verify fallback instructions are clear and actionable:

1. **Permission Denied Error**
   - Verify instructions mention checking file permissions
   - Verify sudo/chmod suggestions if appropriate

2. **File Parse Error**  
   - Verify instructions mention validating JSON/YAML syntax
   - Verify instructions suggest using validation tools

3. **Network Timeout**
   - Verify instructions suggest retry after network check
   - Verify fallback to manual update after multiple retries

4. **Missing Task Number**
   - Verify instructions explain how to find correct task number
   - Verify instructions suggest checking TODO.md for task list