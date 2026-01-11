# Implementation Plan: Fix Systematic Status Synchronization Failure Across All Workflow Commands

## Metadata

- **Task**: 283 - Fix systematic status synchronization failure across all workflow commands
- **Status**: [NOT STARTED]
- **Estimated Effort**: 6-8 hours
- **Actual Effort**: TBD
- **Started**: TBD
- **Completed**: TBD
- **Language**: markdown
- **Priority**: High
- **Complexity**: Medium-High
- **Dependencies**: None
- **Blocking**: None
- **Research Integrated**: Yes - Research Report 001 findings incorporated
- **Plan Version**: 001
- **Created**: 2026-01-04

## Overview

### Problem Statement

Multiple tasks (269, 284) have exposed a systematic status synchronization failure affecting ALL workflow commands (/research, /plan, /implement, /revise). When commands complete successfully, status is NOT consistently updated in TODO.md or state.json during workflow execution, breaking task tracking.

The research (research-001.md) confirmed that the root cause is NOT broken specifications or status-sync-manager implementation. The specifications are correct and comprehensive (thanks to Task 275). The problem is architectural: **there is no enforcement mechanism to ensure subagents follow their multi-stage workflow specifications**. The system relies on Claude voluntarily following markdown documentation without validation.

### Scope

**In Scope**:
1. Extend orchestrator Stage 4 validation to verify status updates occurred
2. Add automatic recovery mechanism when status updates are skipped
3. Add stage execution logging to subagent return format
4. Update orchestrator to validate stage execution logs
5. Create status update compliance test
6. Update all affected specifications (orchestrator.md, subagent-return-format.md)

**Out of Scope**:
1. Orchestrator-level status updates (alternative approach - deferred pending Task 240)
2. Rewriting subagent specifications (already correct from Task 275)
3. Changes to status-sync-manager (already correct)
4. Changes to command specifications (thin routers, no changes needed)

### Constraints

1. **Backward Compatibility**: Changes must not break existing subagents
2. **Performance**: Validation overhead must be minimal (<5 seconds)
3. **Non-Blocking**: Validation failures should warn, not block workflow
4. **Task 240 Alignment**: Must align with OpenAgents migration approach
5. **Standards Compliance**: Must follow subagent-return-format.md and state-management.md

### Definition of Done

- [ ] Orchestrator Stage 4 validates status updates occurred
- [ ] Orchestrator Stage 4 includes automatic recovery for missing status updates
- [ ] Subagent return format includes stage_log field (optional for backward compatibility)
- [ ] Orchestrator validates stage_log when present
- [ ] Status update compliance test created and passing
- [ ] All specifications updated (orchestrator.md, subagent-return-format.md)
- [ ] Documentation updated with new validation behavior
- [ ] Manual testing confirms status updates work correctly
- [ ] Git commit created with all changes

## Goals and Non-Goals

### Goals

1. **Detect Status Update Failures**: Orchestrator must detect when status updates are skipped
2. **Automatic Recovery**: Orchestrator must automatically fix missing status updates
3. **Audit Trail**: System must log all status update attempts and results
4. **Backward Compatible**: Changes must not break existing subagents
5. **Minimal Overhead**: Validation must add <5 seconds to workflow execution

### Non-Goals

1. **Rewrite Subagent Specs**: Specifications are already correct (Task 275)
2. **Change Architecture**: Not moving to orchestrator-level status updates (yet)
3. **Fix Task 240 Issues**: Separate task, different scope
4. **Modify status-sync-manager**: Already correct, no changes needed

## Risks and Mitigations

### Risk 1: Validation Overhead
- **Likelihood**: Medium
- **Impact**: Low
- **Mitigation**: Keep validation lightweight (simple file reads), add 5-second timeout, make warnings not errors

### Risk 2: Backward Compatibility
- **Likelihood**: Medium
- **Impact**: Medium
- **Mitigation**: Make stage_log optional, maintain compatibility with old return format, incremental rollout

### Risk 3: Conflict with Task 240
- **Likelihood**: Medium
- **Impact**: High
- **Mitigation**: Review Task 240 research, align with OpenAgents approach, focus on validation (compatible with any architecture)

### Risk 4: Claude Non-Compliance Persists
- **Likelihood**: Low
- **Impact**: High
- **Mitigation**: Automatic recovery mechanism will fix missing updates, detailed error messages, debugging guide

## Implementation Phases

### Phase 1: Extend Subagent Return Format [NOT STARTED]
**Estimated Effort**: 1.5 hours

**Objective**: Add stage_log field to subagent return format to enable workflow execution validation.

**Tasks**:
1. Read current subagent-return-format.md specification
2. Add stage_log field definition:
   ```json
   {
     "stage_log": [
       {"stage": 1, "name": "Preflight", "executed": true, "duration_seconds": 15},
       {"stage": 2, "name": "Core Work", "executed": true, "duration_seconds": 120},
       {"stage": 3, "name": "Artifact Creation", "executed": true, "duration_seconds": 30},
       {"stage": 4, "name": "Validation", "executed": true, "duration_seconds": 5},
       {"stage": 5, "name": "Postflight", "executed": true, "duration_seconds": 20},
       {"stage": 6, "name": "Return", "executed": true, "duration_seconds": 2}
     ]
   }
   ```
3. Mark stage_log as OPTIONAL (for backward compatibility)
4. Document expected stage names for each subagent type
5. Add examples showing stage_log usage
6. Update schema validation rules

**Acceptance Criteria**:
- [ ] subagent-return-format.md includes stage_log field definition
- [ ] stage_log marked as optional
- [ ] Examples provided for researcher, planner, implementer
- [ ] Schema validation rules updated

**Validation**:
- Read updated subagent-return-format.md
- Verify stage_log field documented
- Verify backward compatibility maintained

### Phase 2: Extend Orchestrator Stage 4 Validation [NOT STARTED]
**Estimated Effort**: 2 hours

**Objective**: Add status update verification to orchestrator Stage 4 (ValidateReturn).

**Tasks**:
1. Read current orchestrator.md Stage 4 specification
2. Add status verification step after artifact validation:
   - Read TODO.md and extract current status for task_number
   - Read state.json and extract current status for task_number
   - Map subagent return status to expected TODO.md marker
   - Compare actual vs expected status
   - Log warning if mismatch detected
3. Add stage_log validation (if present):
   - Verify all required stages executed
   - Check for skipped stages
   - Log warnings for missing stages
4. Add 5-second timeout for validation
5. Document validation behavior in orchestrator.md

**Acceptance Criteria**:
- [ ] Orchestrator Stage 4 includes status verification
- [ ] Status verification reads TODO.md and state.json
- [ ] Status verification compares actual vs expected
- [ ] Stage_log validation implemented (when present)
- [ ] 5-second timeout enforced
- [ ] Warnings logged, workflow not blocked

**Validation**:
- Read updated orchestrator.md
- Verify Stage 4 includes new validation steps
- Verify timeout documented
- Verify non-blocking behavior documented

### Phase 3: Add Automatic Recovery Mechanism [NOT STARTED]
**Estimated Effort**: 1.5 hours

**Objective**: Orchestrator automatically fixes missing status updates when detected.

**Tasks**:
1. Add recovery step to orchestrator Stage 4:
   - If status mismatch detected, invoke status-sync-manager
   - Pass subagent return data to status-sync-manager
   - Extract task_number, new_status, timestamp from subagent return
   - Invoke status-sync-manager with delegation context
   - Validate status-sync-manager return
   - Log recovery action for debugging
2. Add recovery logging:
   - Log to .opencode/logs/status-recovery.log
   - Include task_number, expected_status, actual_status, recovery_result
   - Timestamp all recovery actions
3. Document recovery mechanism in orchestrator.md
4. Add error handling for recovery failures

**Acceptance Criteria**:
- [ ] Orchestrator Stage 4 includes recovery mechanism
- [ ] Recovery invokes status-sync-manager when mismatch detected
- [ ] Recovery actions logged to status-recovery.log
- [ ] Recovery failures handled gracefully
- [ ] Recovery mechanism documented

**Validation**:
- Read updated orchestrator.md
- Verify recovery mechanism documented
- Verify logging behavior specified
- Verify error handling included

### Phase 4: Update Subagent Specifications [NOT STARTED]
**Estimated Effort**: 1 hour

**Objective**: Update researcher, planner, implementer specifications to document stage_log requirement.

**Tasks**:
1. Update researcher.md:
   - Add stage_log to Stage 6 (Return) specification
   - Document expected stage names (Preflight, Research, Artifact Creation, Validation, Postflight, Return)
   - Add example return with stage_log
2. Update planner.md:
   - Add stage_log to Stage 8 (Return) specification
   - Document expected stage names (Preflight, Analysis, Planning, Artifact Creation, Validation, Postflight, Return)
   - Add example return with stage_log
3. Update implementer.md:
   - Add stage_log to Stage 6 (Return) specification
   - Document expected stage names (Preflight, Implementation, Testing, Artifact Creation, Validation, Postflight, Return)
   - Add example return with stage_log
4. Mark stage_log as RECOMMENDED (not required for backward compatibility)

**Acceptance Criteria**:
- [ ] researcher.md includes stage_log in return specification
- [ ] planner.md includes stage_log in return specification
- [ ] implementer.md includes stage_log in return specification
- [ ] Expected stage names documented for each subagent
- [ ] Examples provided
- [ ] Marked as recommended, not required

**Validation**:
- Read updated subagent specifications
- Verify stage_log documented in all three
- Verify examples provided
- Verify backward compatibility maintained

### Phase 5: Create Status Update Compliance Test [NOT STARTED]
**Estimated Effort**: 1.5 hours

**Objective**: Create automated test to verify status updates work correctly.

**Tasks**:
1. Create test script: `.opencode/scripts/test-status-updates.sh`
2. Implement test workflow:
   - Create test task in TODO.md (task 999)
   - Record initial status
   - Simulate /research 999 workflow
   - Verify status changes: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]
   - Verify state.json updates
   - Verify artifacts linked
   - Clean up test task
3. Add test assertions:
   - Assert TODO.md status updated at each stage
   - Assert state.json status updated at each stage
   - Assert artifacts linked in TODO.md
   - Assert no orphaned files
4. Document test usage in README
5. Add test to manual validation checklist

**Acceptance Criteria**:
- [ ] test-status-updates.sh created
- [ ] Test creates and cleans up test task
- [ ] Test verifies status transitions
- [ ] Test verifies state.json updates
- [ ] Test verifies artifact linking
- [ ] Test documented in README
- [ ] Test added to validation checklist

**Validation**:
- Run test-status-updates.sh
- Verify test passes
- Verify test cleans up after itself
- Verify test output is clear and actionable

### Phase 6: Documentation and Manual Testing [NOT STARTED]
**Estimated Effort**: 1 hour

**Objective**: Update documentation and perform manual testing to verify fix works.

**Tasks**:
1. Update docs/Development/MAINTENANCE.md:
   - Document new validation behavior
   - Document automatic recovery mechanism
   - Document stage_log field
   - Add troubleshooting guide for status update failures
2. Create debugging guide:
   - How to check if status updates occurred
   - How to manually recover from status update failures
   - How to read status-recovery.log
   - Common failure patterns and solutions
3. Manual testing:
   - Create test task 998
   - Run /research 998
   - Verify status updates occur
   - Verify recovery mechanism works (simulate failure)
   - Run /plan 998
   - Verify status updates occur
   - Clean up test task
4. Update IMPLEMENTATION_STATUS.md with completion

**Acceptance Criteria**:
- [ ] MAINTENANCE.md updated with new validation behavior
- [ ] Debugging guide created
- [ ] Manual testing completed successfully
- [ ] Test task cleaned up
- [ ] IMPLEMENTATION_STATUS.md updated

**Validation**:
- Read updated documentation
- Verify debugging guide is clear and actionable
- Verify manual testing results documented
- Verify test task removed

## Testing and Validation

### Unit Testing
- **Not applicable**: Changes are to markdown specifications, not code

### Integration Testing
1. **Status Update Compliance Test**: Automated test verifies status updates work correctly
2. **Manual Workflow Test**: Test /research, /plan, /implement commands with test tasks
3. **Recovery Mechanism Test**: Simulate status update failure and verify automatic recovery

### Validation Checklist
- [ ] Orchestrator Stage 4 validation extended
- [ ] Automatic recovery mechanism implemented
- [ ] Subagent return format updated
- [ ] Subagent specifications updated
- [ ] Status update compliance test created and passing
- [ ] Documentation updated
- [ ] Manual testing completed
- [ ] No regression in existing workflows

## Artifacts and Outputs

### Primary Artifacts
1. **Updated Specifications**:
   - `.opencode/agent/orchestrator.md` (Stage 4 validation extended)
   - `.opencode/context/core/standards/subagent-return-format.md` (stage_log field added)
   - `.opencode/agent/subagents/researcher.md` (stage_log documented)
   - `.opencode/agent/subagents/planner.md` (stage_log documented)
   - `.opencode/agent/subagents/implementer.md` (stage_log documented)

2. **Test Script**:
   - `.opencode/scripts/test-status-updates.sh`

3. **Documentation**:
   - `docs/Development/MAINTENANCE.md` (updated)
   - `.opencode/docs/debugging-status-updates.md` (new)

4. **Implementation Summary**:
   - `.opencode/specs/283_fix_systematic_status_synchronization_failure/summaries/implementation-summary-20260104.md`

### Validation Artifacts
- Test results from test-status-updates.sh
- Manual testing results
- Status-recovery.log entries (if recovery triggered)

## Rollback/Contingency

### Rollback Plan
If the fix causes issues:
1. Revert orchestrator.md Stage 4 changes (remove validation and recovery)
2. Revert subagent-return-format.md changes (remove stage_log)
3. Revert subagent specification changes (remove stage_log documentation)
4. Keep test script (useful for future attempts)
5. Document rollback reason in task notes

### Contingency Plan
If validation overhead is too high:
1. Add feature flag to enable/disable validation
2. Make validation opt-in via environment variable
3. Reduce validation scope (only check TODO.md, skip state.json)
4. Increase timeout from 5s to 10s

If recovery mechanism causes issues:
1. Disable automatic recovery
2. Log warnings only (no automatic fixes)
3. Create manual recovery script
4. Document manual recovery process

## Success Metrics

### Quantitative Metrics
1. **Status Update Success Rate**: 100% of workflow commands update status correctly
2. **Recovery Success Rate**: 100% of detected failures recovered automatically
3. **Validation Overhead**: <5 seconds added to workflow execution
4. **Test Pass Rate**: 100% of status update compliance tests pass

### Qualitative Metrics
1. **User Confidence**: Users trust that task status is accurate
2. **Debugging Ease**: Status update failures are easy to diagnose and fix
3. **Maintainability**: Validation logic is clear and easy to update
4. **Backward Compatibility**: Existing subagents continue to work

### Acceptance Criteria
- [ ] All phases completed successfully
- [ ] All validation checklist items checked
- [ ] Manual testing confirms fix works
- [ ] No regression in existing workflows
- [ ] Documentation complete and accurate
- [ ] Git commit created with all changes

## Notes

### Research Integration
This plan incorporates findings from research-001.md:
- Root cause: No enforcement mechanism for workflow specifications
- Task 275 fix was correct but insufficient (documentation without validation)
- Solution: Add validation layer to orchestrator Stage 4
- Automatic recovery ensures status updates occur even if subagents skip them

### Alignment with Task 240
This fix is compatible with Task 240 OpenAgents migration:
- Validation and recovery are orchestrator-level concerns (not subagent-level)
- Stage_log field enables better workflow visibility (useful for any architecture)
- Automatic recovery reduces dependency on subagent compliance
- Can be enhanced further when Task 240 is implemented

### Future Enhancements
After this fix is validated:
1. Consider moving status updates to orchestrator (Recommendation 3 from research)
2. Add more detailed stage execution logging
3. Create dashboard for status update health monitoring
4. Integrate with Task 240 OpenAgents migration

---

**Plan Status**: [NOT STARTED]  
**Next Step**: Review plan and execute with /implement 283
