# Implementation Plan: Fix Parameter Mapping Between Workflow Commands and status-sync-manager

- **Task**: 518 - Fix parameter mapping errors between workflow commands and status-sync-manager
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Priority**: High
- **Dependencies**: []
- **Research Inputs**: Analysis of workflow-designer.md and status-sync-manager.md parameter interfaces
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - .opencode/agent/subagents/meta/workflow-designer.md (updated)
  - .opencode/agent/subagents/status-sync-manager.md (updated)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/orchestration/state-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Fix critical parameter mapping errors between workflow commands (workflow-designer, domain-analyzer, etc.) and status-sync-manager. Research revealed mismatched parameter names, missing required fields, and incompatible data formats causing silent failures and inconsistent state updates.

## Goals & Non-Goals

**Goals**:
- Standardize parameter interface between all workflow commands and status-sync-manager
- Fix parameter name mismatches (e.g., "artifact_links" vs "validated_artifacts")
- Ensure all required parameters are passed correctly
- Add parameter validation in workflow commands before delegation
- Fix silent failures when status-sync-manager returns errors

**Non-Goals**:
- Rewriting the entire delegation system (only fixing parameter mapping)
- Changing the core status-sync-manager functionality (only ensuring compatibility)
- Modifying other command types not affected by this issue

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Breaking existing working commands | Test each fixed command individually |
| Parameter validation too strict | Use warnings for non-critical mismatches |
| Circular dependency between fixes | Fix status-sync-manager first, then workflow commands |

## Implementation Phases

### Phase 1: Analyze Parameter Interface Mismatches [NOT STARTED]
- **Goal**: Document all parameter mismatches between workflow commands and status-sync-manager
- **Tasks**:
  - [ ] Extract required parameters from status-sync-manager inputs_required section
  - [ ] Compare with parameters passed by workflow-designer (Stage 7 delegation)
  - [ ] Compare with parameters passed by domain-analyzer, agent-generator, etc.
  - [ ] Document specific mismatches:
    * "validated_artifacts" vs "artifact_links" 
    * Missing "delegation_path" in some calls
    * Missing "delegation_depth" increment
    * Incorrect "operation" parameter values
- **Timing**: 45 minutes

### Phase 2: Update status-sync-manager Parameter Specification [NOT STARTED]
- **Goal**: Make status-sync-manager more forgiving and backward compatible
- **Tasks**:
  - [ ] Add parameter alias support (e.g., accept both "artifact_links" and "validated_artifacts")
  - [ ] Add default values for optional but commonly missing parameters
  - [ ] Improve error messages to be more specific about what's missing
  - [ ] Add parameter validation before processing (with clear error messages)
  - [ ] Update documentation to clarify the preferred parameter names
- **Timing**: 1 hour

### Phase 3: Fix workflow-designer Parameter Mapping [NOT STARTED]
- **Goal**: Update workflow-designer Stage 7 delegation to use correct parameters
- **Tasks**:
  - [ ] Update Stage 7.2 delegation context to use "validated_artifacts" not "artifact_links"
  - [ ] Ensure "delegation_path" includes current agent + "status-sync-manager"
  - [ ] Ensure "delegation_depth" is incremented by 1
  - [ ] Add all required fields: task_number, new_status, timestamp, session_id
  - [ ] Add validation before delegation to check all required parameters present
- **Timing**: 30 minutes

### Phase 4: Fix Other Workflow Commands [NOT STARTED]
- **Goal**: Update domain-analyzer, agent-generator, command-creator, context-organizer
- **Tasks**:
  - [ ] Update domain-analyzer Stage 7 delegation parameters
  - [ ] Update agent-generator Stage 7 delegation parameters  
  - [ ] Update command-creator Stage 7 delegation parameters
  - [ ] Update context-organizer Stage 7 delegation parameters
  - [ ] Add parameter validation template to all workflow commands
  - [ ] Test each command with a sample delegation
- **Timing**: 1 hour

### Phase 5: Add Error Handling for Silent Failures [NOT STARTED]
- **Goal**: Ensure status-sync-manager failures are properly reported
- **Tasks**:
  - [ ] In each workflow command, check return status from status-sync-manager
  - [ ] If status != "completed", log error and include in command return
  - [ ] Add retry logic for transient failures (timeout, network issues)
  - [ ] Add fallback to manual status update instructions if delegation fails
  - [ ] Update return format to include status_sync_success field
- **Timing**: 30 minutes

## Testing & Validation

- [ ] status-sync-manager accepts both old and new parameter names
- [ ] All workflow commands pass correct parameters to status-sync-manager
- [ ] status-sync-manager failures are properly reported by workflow commands
- [ ] No silent failures - all errors logged and returned
- [ ] Task status updates work correctly after fixes
- [ ] Artifact linking works correctly after fixes

## Artifacts & Outputs

- Updated status-sync-manager.md with backward compatibility
- Updated workflow-designer.md with correct parameter mapping
- Updated other workflow commands with correct parameter mapping
- Test report showing all commands work with status-sync-manager

## Rollback/Contingency

If parameter mapping fixes break existing functionality:
- Revert to original parameter names
- Update status-sync-manager to handle both old and new
- Gradually migrate commands one by one with testing
- Document migration path for future changes