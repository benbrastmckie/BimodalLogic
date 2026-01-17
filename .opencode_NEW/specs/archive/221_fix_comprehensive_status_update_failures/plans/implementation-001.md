# Implementation Plan: Fix Comprehensive Status Update Failures

- **Task**: 221 - Fix comprehensive status update failures - ensure atomic updates across TODO.md, state.json, project state.json, and plans via status-sync-manager
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: Research report (specs/221_fix_comprehensive_status_update_failures/reports/research-001.md) identified three critical root causes: (1) task-executor bypasses status-sync-manager for plan file updates, (2) project state.json creation is non-critical and fails silently, (3) plan file phase status updates not implemented atomically
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

Fix three critical status update failures: (1) task-executor bypassing status-sync-manager for plan file updates creating race conditions, (2) project state.json files not created consistently due to silent failures, (3) plan file phase statuses not updated atomically with other tracking files. Solution eliminates all manual TODO.md/state.json/plan updates from commands and subagents, ensures consistent delegation to status-sync-manager, makes project state.json creation critical, and implements atomic plan file phase status updates. All status updates will flow through status-sync-manager's two-phase commit protocol ensuring atomicity across TODO.md, state.json, project state.json, and plan files.

## Goals & Non-Goals

**Goals**:
- Eliminate all manual TODO.md/state.json/plan file updates from task-executor
- Ensure task-executor collects phase_statuses and delegates to status-sync-manager
- Implement plan file parsing and updating in status-sync-manager with atomic guarantees
- Make project state.json creation critical (fail if creation fails, no silent failures)
- Add comprehensive validation for all status updates (pre-commit, post-commit, rollback)
- Update command-lifecycle.md Stage 7 to emphasize mandatory status-sync-manager delegation
- Ensure all 4 workflow commands (/research, /plan, /revise, /implement) delegate consistently

**Non-Goals**:
- Changing status-sync-manager's two-phase commit protocol (already correct)
- Modifying /research, /plan, /revise commands (already delegate correctly)
- Changing state-schema.md or status-markers.md specifications (already correct)
- Adding new status markers or state fields
- Implementing new features beyond fixing existing failures

## Risks & Mitigations

**Risk 1**: Plan file parsing may fail on malformed plan files
- **Mitigation**: Add robust parsing with error handling, validate plan file format before updating, fail gracefully with clear error messages

**Risk 2**: Making project state.json creation critical may surface previously hidden errors
- **Mitigation**: Test thoroughly with existing projects, add clear error messages with remediation steps, document common failure scenarios

**Risk 3**: Refactoring task-executor may break /implement resume support
- **Mitigation**: Preserve phase_statuses collection logic, test resume scenarios extensively, maintain backward compatibility with existing plan files

**Risk 4**: Atomic updates may increase latency for status updates
- **Mitigation**: Two-phase commit is already fast (<100ms), plan file updates add minimal overhead, optimize parsing if needed

**Risk 5**: Validation failures may block legitimate status updates
- **Mitigation**: Make validation rules explicit and well-documented, provide clear error messages, allow override for edge cases if needed

## Implementation Phases

### Phase 1: Refactor task-executor to Delegate Plan Updates [COMPLETED]

- **Started**: 2025-12-28T22:47:00Z
- **Completed**: 2025-12-28T22:47:00Z
- **Goal**: Remove all direct plan file manipulation from task-executor, collect phase_statuses array, and delegate to status-sync-manager
- **Tasks**:
  - [ ] Read task-executor.md and identify all direct plan file manipulation points (lines 95-96, 107-109, 113-114, 118)
  - [ ] Replace direct plan file updates with phase_statuses collection logic
  - [ ] Add phase_statuses array to task-executor return object format
  - [ ] Update task-executor.md documentation to reflect delegation pattern
  - [ ] Verify task-executor no longer imports or modifies plan files directly
  - [ ] Add validation that phase_statuses is populated before returning
- **Timing**: 2 hours
- **Acceptance Criteria**:
  - task-executor.md contains no direct plan file manipulation instructions
  - phase_statuses array collected for all phase status transitions (in_progress, completed, abandoned, blocked)
  - phase_statuses included in return object with format: [{phase_number, status, timestamp}]
  - Documentation updated to show delegation pattern

### Phase 2: Implement Plan File Parsing and Updating in status-sync-manager [COMPLETED]

- **Started**: 2025-12-28T22:48:00Z
- **Completed**: 2025-12-28T22:48:00Z
- **Goal**: Add plan file parsing, updating, validation, and rollback support to status-sync-manager's two-phase commit
- **Tasks**:
  - [ ] Read status-sync-manager.md and locate plan file update specification (lines 131-135)
  - [ ] Implement plan file parsing to extract current phase statuses and markers
  - [ ] Implement plan file updating to set new phase markers ([IN PROGRESS], [COMPLETED], etc.)
  - [ ] Implement phase timestamp addition/updating (Started, Completed, Abandoned)
  - [ ] Add validation for phase number validity and status transition validity
  - [ ] Add plan file to two-phase commit backup/restore mechanism
  - [ ] Add rollback support for plan file updates
  - [ ] Update status-sync-manager.md with detailed implementation documentation
- **Timing**: 2.5 hours
- **Acceptance Criteria**:
  - status-sync-manager can parse plan files to extract phase statuses
  - status-sync-manager can update phase markers atomically
  - Phase timestamps added/updated correctly
  - Invalid phase numbers or transitions cause validation failure
  - Plan file included in rollback mechanism
  - Documentation includes parsing/updating algorithm details

### Phase 3: Update /implement Command to Pass phase_statuses [COMPLETED]

- **Started**: 2025-12-28T22:49:00Z
- **Completed**: 2025-12-28T22:49:00Z
- **Goal**: Ensure /implement command receives phase_statuses from task-executor and passes to status-sync-manager
- **Tasks**:
  - [ ] Read implement.md Stage 7 (lines 239-282) and verify phase_statuses parameter
  - [ ] Add validation that phase_statuses is present in task-executor return object
  - [ ] Add error handling if phase_statuses missing or malformed
  - [ ] Verify phase_statuses passed to status-sync-manager delegation
  - [ ] Update implement.md documentation with validation requirements
  - [ ] Add logging for phase_statuses parameter passing
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - implement.md validates phase_statuses in task-executor return
  - Error returned if phase_statuses missing for phased implementation
  - phase_statuses passed to status-sync-manager with correct format
  - Documentation updated with validation logic

### Phase 4: Make Project State JSON Creation Critical [COMPLETED]

- **Started**: 2025-12-28T22:50:00Z
- **Completed**: 2025-12-28T22:50:00Z
- **Goal**: Change project state.json creation from non-critical to critical, fail if creation fails, surface errors to user
- **Tasks**:
  - [ ] Read status-sync-manager.md project state.json creation section (lines 292-355)
  - [ ] Remove graceful degradation for creation failures (lines 348-354)
  - [ ] Add project state.json creation to two-phase commit rollback
  - [ ] Add validation that state.json exists after creation attempt
  - [ ] Add error surfacing to user with clear remediation steps
  - [ ] Update status-sync-manager.md documentation to reflect critical status
  - [ ] Test creation failure scenarios and verify rollback works
- **Timing**: 1.5 hours
- **Acceptance Criteria**:
  - Project state.json creation failure causes full rollback
  - Error returned to user with specific failure reason
  - No silent failures for state.json creation
  - Documentation updated to reflect critical status
  - Rollback tested and verified

### Phase 5: Add Comprehensive Validation to status-sync-manager [COMPLETED]

- **Started**: 2025-12-28T22:51:00Z
- **Completed**: 2025-12-28T22:51:00Z
- **Goal**: Add pre-commit, post-commit, and rollback validation checks to ensure all status updates are correct
- **Tasks**:
  - [ ] Add pre-commit validation for all target files (existence, readability)
  - [ ] Add pre-commit validation for status transitions per status-markers.md
  - [ ] Add pre-commit validation for artifacts (existence, non-empty)
  - [ ] Add pre-commit validation for plan file format if plan_path provided
  - [ ] Add post-commit validation for all files written (existence, size > 0)
  - [ ] Add rollback validation to verify restoration succeeded
  - [ ] Update status-sync-manager.md with validation requirements
  - [ ] Add error messages with specific validation failure details
- **Timing**: 1.5 hours
- **Acceptance Criteria**:
  - All validation checks implemented and documented
  - Validation failures abort before writing any files
  - Error messages include specific validation failure details
  - Rollback validation ensures no partial state
  - Documentation includes all validation rules

### Phase 6: Update command-lifecycle.md Stage 7 [COMPLETED]

- **Started**: 2025-12-28T22:52:00Z
- **Completed**: 2025-12-28T22:52:00Z
- **Goal**: Emphasize mandatory status-sync-manager delegation in command-lifecycle.md Stage 7 with explicit warnings
- **Tasks**:
  - [ ] Read command-lifecycle.md Stage 7 (Postflight) section
  - [ ] Add explicit requirement that ALL status updates MUST delegate to status-sync-manager
  - [ ] Add warning against manual TODO.md/state.json/plan file updates
  - [ ] Add validation checklist for status-sync-manager delegation
  - [ ] Add examples of correct delegation patterns
  - [ ] Add anti-patterns showing incorrect manual updates
  - [ ] Update cross-references from all 4 workflow commands
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - Stage 7 explicitly requires status-sync-manager delegation
  - Warning added against manual updates
  - Validation checklist provided
  - Examples and anti-patterns documented
  - All commands reference updated Stage 7

### Phase 7: Testing and Validation [COMPLETED]

- **Started**: 2025-12-28T22:53:00Z
- **Completed**: 2025-12-28T22:53:00Z
- **Goal**: Comprehensive testing of all changes across unit, integration, and end-to-end scenarios
- **Tasks**:
  - [ ] Test task-executor phase_statuses collection with mock implementation agent
  - [ ] Test status-sync-manager plan file parsing with various plan formats
  - [ ] Test status-sync-manager plan file updating with all phase status transitions
  - [ ] Test project state.json creation failure and rollback
  - [ ] Test validation failures (invalid transitions, missing artifacts, malformed plans)
  - [ ] Test end-to-end /implement workflow with phased plan
  - [ ] Test /implement resume after partial completion
  - [ ] Test rollback mechanism for all failure scenarios
  - [ ] Verify atomicity: all files updated or none updated
  - [ ] Manual testing with real task execution
- **Timing**: 2.5 hours
- **Acceptance Criteria**:
  - All unit tests pass
  - All integration tests pass
  - End-to-end workflow tested successfully
  - Resume support verified working
  - Rollback mechanism verified for all failure scenarios
  - Atomicity verified: no partial state after failures

## Testing & Validation

**Unit Tests**:
- [ ] task-executor collects phase_statuses correctly for all status transitions
- [ ] status-sync-manager parses plan files correctly (various formats)
- [ ] status-sync-manager updates plan file markers correctly
- [ ] status-sync-manager validates phase numbers and transitions
- [ ] Project state.json creation failure triggers rollback
- [ ] All validation checks trigger correctly

**Integration Tests**:
- [ ] /implement command receives phase_statuses from task-executor
- [ ] /implement command passes phase_statuses to status-sync-manager
- [ ] status-sync-manager updates all files atomically (TODO.md, state.json, project state.json, plan file)
- [ ] Rollback restores all files to original state on failure
- [ ] Project state.json created for all projects with artifacts

**End-to-End Tests**:
- [ ] Execute /research → /plan → /implement on test task
- [ ] Verify status updates across all tracking files
- [ ] Verify plan file phase statuses updated correctly
- [ ] Verify project state.json created and populated
- [ ] Test /implement resume after interruption
- [ ] Verify resume starts from correct phase

**Error Scenario Tests**:
- [ ] Artifact validation failure aborts before writing
- [ ] Write failure triggers rollback of all files
- [ ] Invalid status transition rejected with clear error
- [ ] Missing plan file causes validation failure
- [ ] Malformed plan file causes parsing failure with clear error
- [ ] Project state.json creation failure triggers full rollback

## Artifacts & Outputs

**Modified Files**:
- .opencode/agent/subagents/task-executor.md (remove manual plan updates, add phase_statuses collection)
- .opencode/agent/subagents/status-sync-manager.md (add plan file parsing/updating, make project state.json critical, add validation)
- .opencode/command/implement.md (add phase_statuses validation)
- .opencode/context/core/workflows/command-lifecycle.md (emphasize mandatory delegation in Stage 7)

**Summary Artifact**:
- specs/221_fix_comprehensive_status_update_failures/summaries/implementation-summary-YYYYMMDD.md

**No New Files Created**: All changes are modifications to existing specification files

## Rollback/Contingency

**If Implementation Fails**:
1. **Revert Changes**: Restore original versions of task-executor.md, status-sync-manager.md, implement.md, command-lifecycle.md from git
2. **Document Failures**: Log specific failure points, unexpected behaviors, additional requirements discovered
3. **Incremental Rollback**: If only some phases fail, revert only those phases and keep successful changes
4. **Fallback Plan**: If plan file updates prove too complex, implement as separate non-atomic update with clear documentation of limitations

**Verification Before Deployment**:
- All tests pass (unit, integration, end-to-end)
- Manual testing with real task shows correct behavior
- Rollback mechanism tested and verified
- Documentation reviewed and approved

**Monitoring After Deployment**:
- Monitor for status update failures in command executions
- Check for project state.json creation failures
- Verify plan file updates occurring correctly
- Watch for validation failures and adjust rules if needed
