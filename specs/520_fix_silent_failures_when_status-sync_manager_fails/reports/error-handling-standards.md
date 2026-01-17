# Error Handling Standards for status-sync-manager Failures

## Phase 2: Define Error Handling Standards

### Failure Severity Levels

#### CRITICAL
Status update must succeed for workflow to be considered complete:
- Task creation failures (create_task operation)
- Plan artifact linking failures (link_artifacts operation)
- Task deletion/cancellation failures

**Behavior**: Return `status: "failed"` and halt workflow

#### IMPORTANT  
Status update should succeed but workflow can continue with warning:
- Status update failures for existing tasks (update_status operation)
- Artifact validation failures in status-sync-manager
- Dependency resolution failures

**Behavior**: Return `status: "partial"` and include recovery instructions

#### COSMETIC
Status update failure doesn't affect workflow outcome:
- Metadata updates (timestamps, session info)
- Non-essential task field updates
- Progress percentage updates

**Behavior**: Return `status: "completed"` with warning message

### Return Status Patterns

#### "completed" - Full Success
```json
{
  "status": "completed",
  "summary": "Domain analysis completed successfully",
  "artifacts": [...],
  "metadata": {
    "status_sync_result": {
      "status": "success",
      "operation": "update_status",
      "details": "Task 515 status updated to 'completed'"
    }
  },
  "errors": [],
  "next_steps": "Proceed with next task"
}
```

#### "partial" - Artifacts Created, Status Sync Failed
```json
{
  "status": "partial", 
  "summary": "Domain analysis completed but status update failed",
  "artifacts": [...],
  "metadata": {
    "status_sync_result": {
      "status": "failed",
      "operation": "update_status",
      "error": {
        "code": "FILE_WRITE_FAILED",
        "message": "Failed to update TODO.md: Permission denied"
      }
    }
  },
  "errors": [
    {
      "type": "status_sync_failed",
      "code": "FILE_WRITE_FAILED", 
      "message": "Failed to update TODO.md: Permission denied",
      "severity": "important"
    }
  ],
  "next_steps": "Manually update task status: /task --update 515 --status completed"
}
```

#### "failed" - Critical Failure
```json
{
  "status": "failed",
  "summary": "Task creation failed - unable to create task entry",
  "artifacts": [],
  "metadata": {
    "status_sync_result": {
      "status": "failed",
      "operation": "create_task", 
      "error": {
        "code": "PARAM_MISSING_REQUIRED",
        "message": "Parameter 'title' is required"
      }
    }
  },
  "errors": [
    {
      "type": "status_sync_failed",
      "code": "PARAM_MISSING_REQUIRED",
      "message": "Parameter 'title' is required for task creation",
      "severity": "critical"
    }
  ],
  "next_steps": "Retry with required parameters: /implement --title 'Task Title' --description 'Task description'"
}
```

### Standard Error Message Format

```json
{
  "type": "status_sync_failed",
  "code": "{ERROR_CODE_FROM_STATUS_SYNC_MANAGER}",
  "message": "{Human-readable message}",
  "severity": "critical|important|cosmetic",
  "recovery": "{Specific recovery instructions}"
}
```

### Recovery Instructions Templates

#### For IMPORTANT failures:
```
"Manually update task status using: /task --update {task_number} --status {target_status}

Alternatively, edit TODO.md and state.json directly:
1. Open TODO.md and update task {task_number} status
2. Open .opencode/specs/state.json and update the corresponding task
3. Run: git commit TODO.md .opencode/specs/state.json -m 'Manual status update'"
```

#### For CRITICAL failures:
``"Task operation failed. Please retry with correct parameters or contact support.

Error: {specific_error}
Retry command: {original_command_with_fixes}
```

### Implementation Requirements

1. **All workflow commands must:**
   - Check status-sync-manager return status
   - Set `status_sync_result` in metadata
   - Return appropriate overall status based on failure severity
   - Include recovery instructions in `next_steps`

2. **Return format must include:**
   - `metadata.status_sync_result` object with operation and status
   - `errors` array with status_sync_failed entry (if applicable)
   - `next_steps` with recovery instructions (if partial/failed)

3. **Error handling updates needed:**
   - Update error_case sections to handle different severities
   - Update Stage 8 return logic to check status_sync_success
   - Add severity determination logic

### Migration Strategy

1. Update workflow-designer.md first (reference implementation)
2. Apply pattern to other 4 workflow commands  
3. Test with mock failures to verify error propagation
4. Update any other commands that delegate to status-sync-manager

### Validation Criteria

- [ ] status-sync-manager failures no longer silent
- [ ] Appropriate return status based on failure severity
- [ ] Clear error messages with recovery instructions
- [ ] Consistent format across all workflow commands
- [ ] Artifacts still committed even when status sync fails (for partial)