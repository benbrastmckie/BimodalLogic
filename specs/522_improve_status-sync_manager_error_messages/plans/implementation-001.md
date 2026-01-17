# Implementation Plan: Improve status-sync-manager Error Messages

- **Task**: 522 - Improve status-sync-manager error messages to be more actionable
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: []
- **Research Inputs**: status-sync-manager.md analysis showing generic error handling and validation failures
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - .opencode/agent/subagents/status-sync-manager.md (updated)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/error-handling.md
  - .opencode/context/core/orchestration/state-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Improve status-sync-manager error messages to be more specific and actionable. Research revealed that status-sync-manager returns generic errors like "Invalid parameters" without explaining which parameter is invalid or what the expected format is. This makes debugging difficult for both users and calling agents.

## Goals & Non-Goals

**Goals**:
- Replace generic error messages with specific, actionable error messages
- Include parameter names and expected values in error messages
- Add examples of correct parameter usage
- Structure error information for programmatic parsing
- Add error codes for common failure types

**Non-Goals**:
- Changing the core validation logic (only improving error messages)
- Adding new validation rules (only making existing ones clearer)
- Implementing retry logic (only better error reporting)

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Error messages become too verbose | Keep main message concise, add details in structured fields |
| Breaking existing error parsing | Maintain backward compatibility with error structure |
| Performance impact from detailed validation | Only generate detailed errors when validation fails |

## Implementation Phases

### Phase 1: Analyze Current Error Messages [NOT STARTED]
- **Goal**: Document all current error messages in status-sync-manager
- **Tasks**:
  - [ ] Extract all validation failure points in status-sync-manager
  - [ ] Document current error messages:
    * "Invalid parameters"
    * "Task not found"
    * "File read error"
    * "Invalid status transition"
    * Others found in code
  - [ ] Identify which errors are most common based on usage patterns
  - [ ] Document what information is missing from each error
- **Timing**: 30 minutes

### Phase 2: Design Error Message Standards [NOT STARTED]
- **Goal**: Create standard format for actionable error messages
- **Tasks**:
  - [ ] Define error message structure:
    ```
    error_type: "parameter_validation_failed"
    message: "Parameter 'task_number' is invalid"
    details: {
      "parameter": "task_number",
      "received": "abc",
      "expected": "positive integer",
      "example": "task_number: 512"
    }
    recovery: "Provide a valid task number as a positive integer"
    ```
  - [ ] Define error codes for common failures:
    * PARAM_INVALID_TYPE (001)
    * PARAM_MISSING_REQUIRED (002)
    * PARAM_INVALID_VALUE (003)
    * TASK_NOT_FOUND (004)
    * FILE_NOT_FOUND (005)
    * INVALID_STATUS_TRANSITION (006)
  - [ ] Create template for each error type
- **Timing**: 30 minutes

### Phase 3: Update Parameter Validation Errors [NOT STARTED]
- **Goal**: Improve validation error messages for all required parameters
- **Tasks**:
  - [ ] Update task_number validation:
    * Check if not provided -> specific error about missing parameter
    * Check if not integer -> show received type and expected integer
    * Check if not positive -> show received value and expected >0
    * Include example of correct format
  - [ ] Update operation validation:
    * List valid operations when invalid one provided
    * Show closest match if typo suspected
  - [ ] Update status validation:
    * List valid status options
    * Show current status and why transition is invalid
    * Suggest valid alternative transitions
  - [ ] Update timestamp validation:
    * Show received format and expected YYYY-MM-DD format
    * Provide example of current date in correct format
- **Timing**: 45 minutes

### Phase 4: Update File Operation Errors [NOT STARTED]
- **Goal**: Improve error messages for file read/write failures
- **Tasks**:
  - [ ] Update file not found errors:
    * Include full path that was not found
    * Check if file exists in different location
    * Suggest creating file if it should exist
  - [ ] Update file permission errors:
    * Include specific permission issue
    * Suggest chmod command if appropriate
  - [ ] Update JSON parse errors:
    * Include line number where parsing failed
    * Show problematic line
    * Suggest JSON validator tools
  - [ ] Update atomic rename failures:
    * Explain what atomic rename failed
    * Suggest checking disk space and file permissions
- **Timing**: 30 minutes

### Phase 5: Add Structured Error Output [NOT STARTED]
- **Goal**: Ensure errors can be programmatically parsed by calling agents
- **Tasks**:
  - [ ] Update return format to always include structured error field:
    ```json
    {
      "status": "failed",
      "error": {
        "code": "PARAM_INVALID_TYPE",
        "type": "parameter_validation_failed",
        "message": "Parameter 'task_number' must be a positive integer",
        "parameter": "task_number",
        "received": "abc",
        "expected": "positive integer",
        "recovery": "Provide task number as positive integer (e.g., task_number: 512)"
      }
    }
    ```
  - [ ] Ensure all validation failures use this structure
  - [ ] Maintain backward compatibility with existing error field
  - [ ] Add error_code field for quick error type checking
- **Timing**: 15 minutes

### Phase 6: Test Error Message Improvements [NOT STARTED]
- **Goal**: Verify all error messages are clear and actionable
- **Tasks**:
  - [ ] Test each validation failure with invalid input:
    * Verify error includes parameter name
    * Verify error shows received vs expected
    * Verify error provides recovery suggestion
  - [ ] Test with calling agents:
    * Verify agents can parse structured error
    * Verify agents can extract recovery instructions
    * Verify error propagation works correctly
  - [ ] Test edge cases:
    * Multiple validation errors
    * Missing multiple required parameters
    * Invalid combinations of parameters
- **Timing**: 20 minutes

## Testing & Validation

- [x] All error messages specify which parameter or operation failed
- [x] Error messages show what was received vs what was expected
- [x] Error messages provide clear recovery instructions
- [x] Structured error format allows programmatic parsing
- [x] Error codes enable quick error type identification
- [x] Backward compatibility maintained with existing error handling

## Artifacts & Outputs

- Updated status-sync-manager.md with improved error messages
- Error message standards documentation
- Test report showing all error types with improved messages
- Error code reference table

## Rollback/Contingency

If detailed errors cause issues:
- Maintain compatibility mode for simple error string
- Add flag to enable/disable detailed errors
- Revert to generic errors if structured format breaks callers
- Document migration path for error handling