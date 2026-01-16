# Implementation Plan: Fix Silent Failures When status-sync-manager Fails

- **Task**: 520 - Fix silent failures when status-sync-manager fails
- **Status**: [NOT STARTED]
- **Effort**: 1-2 hours
- **Priority**: High
- **Dependencies**: []
- **Research Inputs**: Analysis of workflow commands showing status-sync-manager failures are logged but not propagated
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - .opencode/agent/subagents/meta/workflow-designer.md (updated)
  - .opencode/agent/subagents/meta/domain-analyzer.md (updated)
  - .opencode/agent/subagents/meta/agent-generator.md (updated)
  - .opencode/agent/subagents/meta/command-creator.md (updated)
  - .opencode/agent/subagents/meta/context-organizer.md (updated)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/error-handling.md
  - .opencode/context/core/workflows/command-lifecycle.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Fix silent failures when status-sync-manager delegation fails. Research revealed that workflow commands log status-sync-manager failures as "non-critical" and continue, returning success status even when status updates fail. This leads to inconsistent state where artifacts are created but task status isn't updated.

## Goals & Non-Goals

**Goals**:
- Ensure status-sync-manager failures are properly reported by workflow commands
- Add error propagation from status-sync-manager to workflow command return status
- Implement fallback handling when status-sync-manager fails
- Provide clear error messages to users when status updates fail
- Maintain data consistency between artifacts and task status

**Non-Goals**:
- Rewriting status-sync-manager itself (only handling failures in callers)
- Automatically retrying failed status updates (user intervention preferred)
- Blocking workflow completion on non-critical status failures

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Too strict - failing entire workflow for minor status issues | Use partial success status for non-critical failures |
| Error propagation creates complex failure modes | Keep it simple: pass through status-sync-manager error details |
| Users don't know how to recover from status sync failures | Provide clear manual recovery instructions |

## Implementation Phases

### Phase 1: Analyze Current Error Handling Patterns [NOT STARTED]
- **Goal**: Document how each workflow command currently handles status-sync-manager failures
- **Tasks**:
  - [ ] Extract Stage 7.2 (status-sync-manager delegation) from all workflow commands
  - [ ] Document current error handling:
    * workflow-designer: "LOG error (non-critical), continue"
    * domain-analyzer: Similar pattern
    * Others: Likely similar
  - [ ] Identify which failures should be critical vs non-critical
  - [ ] Document what information is lost when status sync fails silently
- **Timing**: 30 minutes

### Phase 2: Define Error Handling Standards [NOT STARTED]
- **Goal**: Create consistent error handling standards for status-sync-manager failures
- **Tasks**:
  - [ ] Define failure severity levels:
    * CRITICAL: Status update must succeed for workflow to be considered complete
    * IMPORTANT: Status update should succeed but workflow can continue with warning
    * COSMETIC: Status update failure doesn't affect workflow outcome
  - [ ] Define return status patterns:
    * "completed" - Full success including status sync
    * "partial" - Artifacts created but status sync failed
    * "failed" - Critical failure (artifacts not created or status sync critical)
  - [ ] Document standard error message format
  - [ ] Create recovery instructions template for users
- **Timing**: 30 minutes

### Phase 3: Fix workflow-designer Error Handling [NOT STARTED]
- **Goal**: Update workflow-designer to properly handle and report status-sync-manager failures
- **Tasks**:
  - [ ] Modify Stage 7.2 to check status-sync-manager return status
  - [ ] If status == "completed":
    * Log success
    * Continue to git commit
  - [ ] If status == "failed":
    * Extract error details from return object
    * Log error with full details
    * Set workflow return status to "partial" 
    * Include error in errors array
    * Add recovery instructions to next_steps
    * Continue to git commit (artifacts should still be committed)
  - [ ] Update return object to include status_sync_result field
- **Timing**: 15 minutes

### Phase 4: Fix Other Workflow Commands Error Handling [NOT STARTED]
- **Goal**: Update domain-analyzer, agent-generator, command-creator, context-organizer
- **Tasks**:
  - [ ] Apply same error handling pattern to domain-analyzer Stage 7.2
  - [ ] Apply same error handling pattern to agent-generator Stage 7.2
  - [ ] Apply same error handling pattern to command-creator Stage 7.2
  - [ ] Apply same error handling pattern to context-organizer Stage 7.2
  - [ ] Ensure all commands include status_sync_result in return
  - [ ] Ensure all commands provide recovery instructions
- **Timing**: 30 minutes

### Phase 5: Add Fallback Status Update [NOT STARTED]
- **Goal**: Provide manual fallback when status-sync-manager fails
- **Tasks**:
  - [ ] Create manual status update instructions:
    * "Run: /task --update {task_number} --status {target_status}"
    * "Or: Manually edit TODO.md and state.json"
  - [ ] Add these instructions to error messages
  - [ ] Create helper command template for manual status updates
  - [ ] Document when to use fallback vs retry
- **Timing**: 15 minutes

### Phase 6: Test Error Propagation [NOT STARTED]
- **Goal**: Verify errors are properly propagated and reported
- **Tasks**:
  - [ ] Test with valid status-sync-manager (should return "completed")
  - [ ] Mock status-sync-manager failure:
    * Verify workflow returns "partial" status
    * Verify error details included in return
    * Verify recovery instructions provided
  - [ ] Test with different failure types:
    * Artifact validation failed
    * File write failed
    * Invalid parameters
  - [ ] Verify error messages are clear and actionable
- **Timing**: 30 minutes

## Testing & Validation

- [ ] status-sync-manager failures are no longer silent
- [ ] Workflow commands return appropriate status based on failure severity
- [ ] Error messages include specific details about what failed
- [ ] Recovery instructions help users fix status sync issues
- [ ] Artifacts are still committed even when status sync fails
- [ ] Return format includes status_sync_result field

## Artifacts & Outputs

- Updated workflow-designer.md with proper error handling
- Updated domain-analyzer.md with proper error handling
- Updated agent-generator.md with proper error handling
- Updated command-creator.md with proper error handling
- Updated context-organizer.md with proper error handling
- error-handling.md with status-sync-manager failure standards

## Rollback/Contingency

If error handling becomes too strict:
- Revert to logging failures as warnings
- Make status_sync_result informational only
- Provide opt-in flag for strict error handling
- Document which failures are safe to ignore