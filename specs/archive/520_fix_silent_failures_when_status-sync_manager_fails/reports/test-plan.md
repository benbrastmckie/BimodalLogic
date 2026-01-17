# Test Error Propagation

## Phase 6: Test Error Propagation

### Test Scenarios

#### Test 1: Valid status-sync-manager Success
**Objective**: Verify normal operation returns "completed" status

**Test Setup:**
- Mock status-sync-manager to return `{"status": "completed", ...}`
- Run workflow-designer with valid inputs
- Verify return format

**Expected Results:**
```json
{
  "status": "completed",
  "metadata": {
    "status_sync_result": {
      "status": "success",
      "operation": "update_status",
      "details": "Task 515 status updated to 'completed'"
    }
  },
  "errors": []
}
```

**Validation:**
- [ ] Return status is "completed"
- [ ] status_sync_result shows success
- [ ] errors array is empty
- [ ] next_steps suggests normal progression

#### Test 2: Important Failure (FILE_WRITE_FAILED)
**Objective**: Verify important failures return "partial" status with recovery instructions

**Test Setup:**
- Mock status-sync-manager to return:
```json
{
  "status": "failed",
  "errors": [
    {
      "code": "FILE_WRITE_FAILED",
      "message": "Failed to update TODO.md: Permission denied"
    }
  ]
}
```
- Run workflow-designer with valid inputs

**Expected Results:**
```json
{
  "status": "partial",
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
  "next_steps": "Review workflows. Manually update task status: /task --update 515 --status completed"
}
```

**Validation:**
- [ ] Return status is "partial"
- [ ] status_sync_result includes error details
- [ ] errors array includes status_sync_failed entry
- [ ] severity is "important"
- [ ] next_steps includes manual recovery instructions

#### Test 3: Critical Failure (PARAM_MISSING_REQUIRED)
**Objective**: Verify critical failures return "failed" status and halt workflow

**Test Setup:**
- Mock status-sync-manager to return:
```json
{
  "status": "failed",
  "errors": [
    {
      "code": "PARAM_MISSING_REQUIRED",
      "message": "Parameter 'task_number' is required"
    }
  ]
}
```
- Run workflow-designer with missing task_number

**Expected Results:**
```json
{
  "status": "failed",
  "metadata": {
    "status_sync_result": {
      "status": "failed",
      "operation": "create_task",
      "error": {
        "code": "PARAM_MISSING_REQUIRED",
        "message": "Parameter 'task_number' is required"
      }
    }
  },
  "errors": [
    {
      "type": "status_sync_failed",
      "code": "PARAM_MISSING_REQUIRED",
      "message": "Parameter 'task_number' is required",
      "severity": "critical"
    }
  ],
  "next_steps": "Retry with correct parameters or fix underlying issue"
}
```

**Validation:**
- [ ] Return status is "failed"
- [ ] status_sync_result shows critical error
- [ ] errors array includes critical status_sync_failed entry
- [ ] severity is "critical"
- [ ] next_steps suggests retry with fix

#### Test 4: Timeout Failure
**Objective**: Verify timeout handling returns "partial" status

**Test Setup:**
- Mock status-sync-manager to timeout (no response within 60s)
- Run workflow-designer with valid inputs

**Expected Results:**
```json
{
  "status": "partial",
  "metadata": {
    "status_sync_result": {
      "status": "failed",
      "operation": "update_status",
      "error": {
        "code": "TIMEOUT",
        "message": "status-sync-manager timeout after 60s"
      }
    }
  },
  "errors": [
    {
      "type": "status_sync_failed",
      "code": "TIMEOUT",
      "message": "status-sync-manager timeout after 60s",
      "severity": "important"
    }
  ]
}
```

**Validation:**
- [ ] Return status is "partial" (timeout is treated as important)
- [ ] status_sync_result shows TIMEOUT error
- [ ] errors array includes timeout error
- [ ] severity is "important"

#### Test 5: Cosmetic Failure
**Objective**: Verify cosmetic failures return "completed" status with warning

**Test Setup:**
- Mock status-sync-manager to return:
```json
{
  "status": "failed",
  "errors": [
    {
      "code": "METADATA_UPDATE_FAILED",
      "message": "Failed to update task metadata"
    }
  ]
}
```
- Update severity mapping to treat METADATA_UPDATE_FAILED as "cosmetic"

**Expected Results:**
```json
{
  "status": "completed",
  "metadata": {
    "status_sync_result": {
      "status": "failed",
      "operation": "update_status",
      "error": {
        "code": "METADATA_UPDATE_FAILED",
        "message": "Failed to update task metadata"
      }
    }
  },
  "errors": [
    {
      "type": "status_sync_failed",
      "code": "METADATA_UPDATE_FAILED",
      "message": "Failed to update task metadata",
      "severity": "cosmetic"
    }
  ]
}
```

**Validation:**
- [ ] Return status is "completed"
- [ ] status_sync_result shows cosmetic error
- [ ] errors array includes cosmetic status_sync_failed entry
- [ ] severity is "cosmetic"

### Cross-Command Testing

Apply same test scenarios to all 5 workflow commands:
1. workflow-designer.md ✓
2. domain-analyzer.md ✓
3. agent-generator.md ✓
4. command-creator.md ✓
5. context-organizer.md ✓

**Consistency Validation:**
- [ ] All commands use same error format
- [ ] All commands determine severity consistently
- [ ] All commands include status_sync_result in metadata
- [ ] All commands provide appropriate next_steps

### Error Message Clarity Testing

**Test Message Comprehension:**
- [ ] Error messages are specific and actionable
- [ ] Recovery instructions are clear
- [ ] Error codes are descriptive
- [ ] Severity levels are appropriate

**Test User Understanding:**
- Present error messages to test users
- Verify they can:
  - Understand what went wrong
  - Know how to recover
  - Distinguish between critical, important, and cosmetic issues

### Integration Testing

**Test with Real status-sync-manager:**
- [ ] Test with actual permission denied error
- [ ] Test with invalid task number
- [ ] Test with network connectivity issues
- [ ] Test with corrupted state.json

**Test Git Commit Behavior:**
- [ ] Verify git commit still happens for "partial" status
- [ ] Verify git commit is skipped for "failed" status
- [ ] Verify commit messages include appropriate context

### Performance Testing

**Test Timeout Handling:**
- [ ] Verify 60s timeout works correctly
- [ ] Verify graceful handling of very slow status-sync-manager
- [ ] Verify workflow doesn't hang indefinitely

**Test Error Propagation Speed:**
- [ ] Verify errors are propagated quickly
- [ ] Verify no unnecessary delays in error reporting
- [ ] Verify multiple errors are handled efficiently

### Success Criteria

All tests must pass:
- [ ] status-sync-manager failures are no longer silent
- [ ] Workflow commands return appropriate status based on failure severity
- [ ] Error messages include specific details about what failed
- [ ] Recovery instructions help users fix status sync issues
- [ ] Artifacts are still committed even when status sync fails (for partial)
- [ ] Return format includes status_sync_result field
- [ ] All 5 workflow commands behave consistently