# Implementation Plan: Fix Parameter Mapping Between Workflow Commands and status-sync-manager

- **Task**: 518 - Fix parameter mapping errors between workflow commands and status-sync-manager
- **Status**: [COMPLETED]
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

### Phase 1: Analyze Parameter Interface Mismatches [COMPLETED]
- **Goal**: Document all parameter mismatches between workflow commands and status-sync-manager
- **Tasks**:
  - [x] Extract required parameters from status-sync-manager inputs_required section
  - [x] Compare with parameters passed by workflow-designer (Stage 7 delegation)
  - [x] Compare with parameters passed by domain-analyzer, agent-generator, etc.
  - [x] Document specific mismatches:
    * "validated_artifacts" vs "artifact_links" (both now supported)
    * Missing "operation" parameter in all workflow commands (FIXED)
    * Missing error handling for status-sync-manager failures (FIXED)
- **Timing**: 45 minutes (actual: 30 minutes)
- **Findings**: 
  - All workflow commands missing `"operation": "update_status"` parameter
  - status-sync-manager already defaults to update_status but should be explicit
  - Both artifact_links and validated_artifacts should be supported for backward compatibility

### Phase 2: Update status-sync-manager Parameter Specification [COMPLETED]
- **Goal**: Make status-sync-manager more forgiving and backward compatible
- **Tasks**:
  - [x] Add parameter alias support (e.g., accept both "artifact_links" and "validated_artifacts")
  - [x] Add default values for optional but commonly missing parameters
  - [x] Improve error messages to be more specific about what's missing
  - [x] Add parameter validation before processing (with clear error messages)
  - [x] Update documentation to clarify the preferred parameter names
- **Timing**: 1 hour (actual: 45 minutes)
- **Changes Made**:
  - Added `parameter_normalization` process to handle alias conversion
  - Added `step_0_normalize_parameters` as first step in process_flow
  - Updated parameter documentation to note backward compatibility
  - Added automatic inference of operation parameter when missing

### Phase 3: Fix workflow-designer Parameter Mapping [COMPLETED]
- **Goal**: Update workflow-designer Stage 7 delegation to use correct parameters
- **Tasks**:
  - [x] Update Stage 7.2 delegation context to use "validated_artifacts" not "artifact_links"
  - [x] Ensure "delegation_path" includes current agent + "status-sync-manager"
  - [x] Ensure "delegation_depth" is incremented by 1
  - [x] Add all required fields: task_number, new_status, timestamp, session_id
  - [x] Add missing "operation": "update_status" parameter
  - [x] Add enhanced error handling for status-sync-manager failures
- **Timing**: 30 minutes (actual: 20 minutes)
- **Changes Made**:
  - Added `"operation": "update_status"` to delegation context
  - Enhanced error handling to track status_sync_success
  - Improved return validation to extract error details

### Phase 4: Fix Other Workflow Commands [COMPLETED]
- **Goal**: Update domain-analyzer, agent-generator, command-creator, context-organizer
- **Tasks**:
  - [x] Update domain-analyzer Stage 7 delegation parameters
  - [x] Update agent-generator Stage 7 delegation parameters  
  - [x] Update command-creator Stage 7 delegation parameters
  - [x] Update context-organizer Stage 7 delegation parameters
  - [x] Add enhanced error handling for status-sync-manager failures
  - [x] Update return formats to include status_sync_success field
- **Timing**: 1 hour (actual: 45 minutes)
- **Changes Made**:
  - Added `"operation": "update_status"` to all workflow commands
  - Enhanced error handling with detailed error extraction
  - Added status_sync_success to all return formats
  - Improved timeout handling for status-sync-manager calls

### Phase 5: Add Error Handling for Silent Failures [COMPLETED]
- **Goal**: Ensure status-sync-manager failures are properly reported
- **Tasks**:
  - [x] In each workflow command, check return status from status-sync-manager
  - [x] If status != "completed", log error and include in command return
  - [x] Add timeout handling for status-sync-manager calls
  - [x] Update return format to include status_sync_success field
  - [x] Add detailed error extraction from status-sync-manager responses
- **Timing**: 30 minutes (actual: 25 minutes)
- **Changes Made**:
  - Enhanced error handling in all 5 workflow commands
  - Added status_sync_success tracking for success/failure reporting
  - Added timeout handling with proper error logging
  - Updated all return formats to include status_sync_success metadata

## Testing & Validation

- [x] status-sync-manager accepts both old and new parameter names
- [x] All workflow commands pass correct parameters to status-sync-manager
- [x] status-sync-manager failures are properly reported by workflow commands
- [x] No silent failures - all errors logged and returned
- [x] Task status updates work correctly after fixes
- [x] Artifact linking works correctly after fixes

### Test Scenarios

1. **Parameter Alias Test**:
   - Send delegation with "validated_artifacts" → should work
   - Send delegation with "artifact_links" → should work
   - Send delegation with both → should prefer "validated_artifacts"

2. **Missing Operation Test**:
   - Send delegation without "operation" parameter → should default to "update_status"

3. **Error Handling Test**:
   - Simulate status-sync-manager failure → workflow command should report it
   - Simulate timeout → workflow command should handle gracefully

4. **Required Parameters Test**:
   - Send delegation with missing required parameters → should get structured error

## Artifacts & Outputs

- Updated status-sync-manager.md with backward compatibility and parameter normalization
- Updated workflow-designer.md with correct parameter mapping and enhanced error handling
- Updated domain-analyzer.md with correct parameter mapping and enhanced error handling
- Updated agent-generator.md with correct parameter mapping and enhanced error handling
- Updated command-creator.md with correct parameter mapping and enhanced error handling
- Updated context-organizer.md with correct parameter mapping and enhanced error handling
- Enhanced all return formats to include status_sync_success field
- Added comprehensive parameter alias support in status-sync-manager

## Rollback/Contingency

If parameter mapping fixes break existing functionality:
- Revert to original parameter names
- Update status-sync-manager to handle both old and new
- Gradually migrate commands one by one with testing
- Document migration path for future changes