# Implementation Plan: Fix Systematic Postflight Failures in Workflow Commands (Revised)

**Task**: 320 - Fix workflow command postflight failures causing missing artifact links and status updates  
**Status**: [PLANNED]  
**Estimated Effort**: 5 hours  
**Complexity**: Medium  
**Language**: meta  
**Priority**: High  
**Created**: 2026-01-05  
**Plan Version**: 2  
**Revision Reason**: User clarification - MOST IMPORTANT failures are missing artifact links and status updates, not git commits. Git failures are passing failures of little concern. Focus on minimal validation, brief user feedback, and integration with task 321.

---

## Metadata

- **Task Number**: 320
- **Dependencies**: None
- **Blocking**: None
- **Related Tasks**: 
  - Task 321 (preflight failures) - complementary fix, coordinate on shared context files
  - Task 291 (lean-research-agent) - separate issue
- **Research Integrated**: Yes
- **Reports Integrated**:
  - `specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-001.md` (integrated 2026-01-05)

---

## Overview

### Problem Statement (Revised)

Workflow commands (/research, /plan, /revise, /implement) exhibit systematic postflight failures where:

**MOST IMPORTANT (CRITICAL)**:
1. Artifacts are NOT LINKED in TODO.md and state.json
2. Task status is NOT UPDATED in TODO.md and state.json

**LESS IMPORTANT (NON-CRITICAL)**:
3. Git commits are missing (passing failure, worth logging but not critical)

Research reveals the root cause is **silent status-sync-manager failures**, not git failures. When status-sync-manager fails to update status or link artifacts, subagents may still return status="completed" because they treat these as non-critical errors. Commands have no validation to detect these failures.

### User Requirements (Clarified)

1. **MOST IMPORTANT**: Fix missing artifact links and status updates (CRITICAL failures)
2. **Git failures**: Passing failures of little concern, just log in errors.json
3. **User feedback**: Very minimal - task number, artifact created, single sentence of work done, any failures with "/errors" recommendation
4. **Validation**: Minimal and well-placed, check everything worked at once, avoid bloating complexity
5. **Integration with task 321**: Coordinate on shared context files for preflight/postflight standards

### Research Integration

This plan integrates findings from research-001.md:

**Key Research Findings**:
1. **Root Cause**: Silent git-workflow-manager failures (research focused on git, but user clarifies status/artifact linking is MORE important)
2. **Evidence**: Task 314 shows artifact created, status updated, artifact linked, but NO git commit
3. **Postflight Steps DO Exist**: researcher.md (step_4_postflight) and planner.md (step_7) properly delegate
4. **Non-Critical Error Handling**: Subagents treat failures as non-critical and return "completed" anyway
5. **Validation Gap**: Commands validate return format but do NOT check if status/artifacts were updated

**Revised Interpretation**:
- Research focused on git failures, but user clarifies status/artifact failures are MORE critical
- Need to prioritize validation of status updates and artifact linking
- Git failures should be logged but not fail the command
- Validation should be minimal and strategic (single checkpoint)

### Scope

**In Scope**:
1. Add single verification checkpoint in subagent postflight (after status-sync-manager)
2. Verify status updated in state.json AND TODO.md
3. Verify artifact linked in TODO.md
4. Implement two-level error logging:
   - CRITICAL: Status/artifact linking failures (fail command)
   - NON-CRITICAL: Git commit failures (log but continue)
5. Add minimal command-level validation to surface CRITICAL failures
6. Provide brief user feedback (task number, artifact, work summary, failures)
7. Create shared context file with task 321 for postflight/preflight standards

**Out of Scope**:
- Making git commits critical (user confirmed these are passing failures)
- Adding multiple verification checkpoints (user wants minimal, well-placed validation)
- Verbose user feedback (user wants very minimal output)
- Fixing lean-research-agent direct file manipulation (task 291)
- Fixing preflight status update failures (task 321)

### Constraints

1. **Minimal Validation**: Single checkpoint after status-sync-manager, check everything at once
2. **Two-Level Error Logging**: CRITICAL (status/artifacts) vs NON-CRITICAL (git)
3. **Brief User Feedback**: Task number, artifact, single sentence, failures with /errors recommendation
4. **No Workflow Bloat**: Avoid adding complexity that slows down workflow
5. **Integration with Task 321**: Coordinate on shared context files

### Definition of Done

- [ ] Single verification checkpoint added to subagent postflight (after status-sync-manager)
- [ ] Checkpoint verifies status updated in state.json AND TODO.md
- [ ] Checkpoint verifies artifact linked in TODO.md
- [ ] Two-level error logging implemented (CRITICAL vs NON-CRITICAL)
- [ ] Command-level validation surfaces CRITICAL failures only
- [ ] User feedback is minimal (task number, artifact, work summary, failures)
- [ ] Shared context file created with task 321 for postflight/preflight standards
- [ ] All 4 workflow commands updated (/research, /plan, /revise, /implement)
- [ ] All 3 subagents updated (researcher, planner, implementer)
- [ ] Git commit created for changes
- [ ] No regression in existing functionality

---

## Goals and Non-Goals

### Goals

1. **Fix CRITICAL Failures**: Ensure status updates and artifact linking work reliably
2. **Minimal Validation**: Single checkpoint, check everything at once
3. **Brief User Feedback**: Task number, artifact, work summary, failures
4. **Two-Level Error Logging**: Distinguish CRITICAL from NON-CRITICAL failures
5. **Integration with Task 321**: Coordinate on shared context files

### Non-Goals

1. **Make Git Commits Critical**: User confirmed these are passing failures
2. **Add Multiple Checkpoints**: User wants minimal, well-placed validation
3. **Verbose User Feedback**: User wants very minimal output
4. **Fix Lean-Research-Agent**: Separate issue (task 291)
5. **Fix Preflight Failures**: Separate issue (task 321)

---

## Risks and Mitigations

### Risk 1: Status-Sync-Manager May Have Underlying Bugs

**Risk**: If status-sync-manager is failing systematically due to bugs, validation won't solve the root issue.

**Likelihood**: Medium  
**Impact**: High

**Mitigation**:
1. Test status-sync-manager in isolation before implementing validation
2. Check status-sync-manager logs for systematic errors
3. Verify status-sync-manager return format compliance
4. Fix status-sync-manager bugs if found (separate task if needed)

### Risk 2: Single Checkpoint May Miss Some Failures

**Risk**: Checking everything at once may not catch all failure modes.

**Likelihood**: Low  
**Impact**: Medium

**Mitigation**:
1. Design checkpoint to check all critical conditions (status in state.json, status in TODO.md, artifact link)
2. Use fail-fast approach to surface issues quickly
3. Document known edge cases for future enhancement
4. Monitor for new failure patterns post-fix

### Risk 3: Integration with Task 321 May Require Coordination

**Risk**: Task 321 may use different error logging or validation approach.

**Likelihood**: Low  
**Impact**: Low

**Mitigation**:
1. Create shared context file for both tasks (.opencode/context/core/standards/postflight-preflight.md)
2. Use consistent error format (type, message, code, severity, recoverable, recommendation)
3. Coordinate with task 321 implementation if needed

---

## Implementation Phases

### Phase 1: Create Shared Postflight/Preflight Standards File [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Create shared context file with task 321 for consistent postflight/preflight standards.

**Tasks**:
1. Create `.opencode/context/core/standards/postflight-preflight.md`:
   - Document postflight verification requirements (status updated, artifact linked)
   - Document preflight verification requirements (status updated to in-progress)
   - Document two-level error logging standard (CRITICAL vs NON-CRITICAL)
   - Document error format: {type, message, code, severity, recoverable, recommendation}
   - Document verification checkpoint pattern (single checkpoint, check all conditions)
   - Document user feedback format (minimal: task number, artifact, work summary, failures)

2. Define CRITICAL vs NON-CRITICAL errors:
   - CRITICAL: Status update failures, artifact linking failures
     * type: "status_sync_failed", "artifact_link_failed", "verification_failed"
     * severity: "CRITICAL"
     * recoverable: false
     * recommendation: Manual recovery steps or retry command
   - NON-CRITICAL: Git commit failures
     * type: "git_commit_failed"
     * severity: "NON-CRITICAL"
     * recoverable: true
     * recommendation: Manual git commit steps

3. Document verification checkpoint pattern:
   - Single checkpoint after status-sync-manager
   - Check all conditions at once:
     * Status updated in state.json (use jq)
     * Status updated in TODO.md (use grep)
     * Artifact linked in TODO.md (use grep)
   - If any condition fails: Log CRITICAL error, return status="failed"
   - If all conditions pass: Continue to git-workflow-manager

4. Document user feedback format:
   - Minimal output: "Task {number}: {artifact} created. {work_summary}."
   - If failures: "Failures occurred. Run /errors for details."
   - No verbose output, no detailed error messages in user feedback

**Acceptance Criteria**:
- [ ] Shared context file created at `.opencode/context/core/standards/postflight-preflight.md`
- [ ] Two-level error logging standard documented
- [ ] Verification checkpoint pattern documented
- [ ] User feedback format documented
- [ ] Consistent with task 321 approach

**Validation**:
- Read created file
- Verify all standards documented
- Verify consistent with task 321 plan

---

### Phase 2: Add Verification Checkpoint to Subagent Postflight [NOT STARTED]

**Estimated Effort**: 2 hours

**Objective**: Add single verification checkpoint in subagent postflight after status-sync-manager succeeds.

**Tasks**:
1. Update researcher.md step_4_postflight:
   - After status-sync-manager validation (step 2f)
   - Add single checkpoint: Verify status updated AND artifact linked
   - Check all conditions at once:
     ```bash
     # Check status in state.json
     status_in_state=$(jq -r --arg num "$task_number" \
       '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
       specs/state.json)
     
     # Check status in TODO.md
     status_in_todo=$(grep -A 5 "^### $task_number\." specs/TODO.md | \
       grep -oP '\*\*Status\*\*: \[\K[^\]]+')
     
     # Check artifact link in TODO.md
     artifact_linked=$(grep -A 20 "^### $task_number\." specs/TODO.md | \
       grep -q "$research_report_path" && echo "yes" || echo "no")
     
     # Verify all conditions
     if [ "$status_in_state" != "researched" ] || \
        [ "$status_in_todo" != "RESEARCHED" ] || \
        [ "$artifact_linked" != "yes" ]; then
       # Log CRITICAL error
       echo "CRITICAL: Postflight verification failed"
       echo "  Status in state.json: $status_in_state (expected: researched)"
       echo "  Status in TODO.md: $status_in_todo (expected: RESEARCHED)"
       echo "  Artifact linked: $artifact_linked (expected: yes)"
       # Return status="failed"
       exit 1
     fi
     ```
   - If verification fails: Log CRITICAL error, return status="failed"
   - If verification succeeds: Continue to git-workflow-manager

2. Update planner.md step_7:
   - After status-sync-manager validation (step 7.1)
   - Add same verification checkpoint pattern
   - Check plan_path in state.json
   - Check plan link in TODO.md
   - Same error handling as researcher

3. Update implementer.md postflight:
   - Add same verification checkpoint pattern
   - Check implementation status and artifact links

**Acceptance Criteria**:
- [ ] Single checkpoint added after status-sync-manager in all 3 subagents
- [ ] Checkpoint verifies status in BOTH state.json AND TODO.md
- [ ] Checkpoint verifies artifact linked in TODO.md
- [ ] All conditions checked at once (not scattered)
- [ ] CRITICAL error logged if verification fails
- [ ] Subagent returns status="failed" if verification fails

**Validation**:
- Read updated subagent files
- Verify checkpoint uses jq and grep (not bash file manipulation)
- Verify checkpoint is AFTER status-sync-manager, BEFORE git-workflow-manager
- Verify all conditions checked in single block

---

### Phase 3: Implement Two-Level Error Logging [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Implement two-level error logging in subagents with CRITICAL vs NON-CRITICAL distinction.

**Tasks**:
1. Update subagent error logging to use two-level format:
   - CRITICAL errors (status/artifact failures):
     ```json
     {
       "type": "verification_failed",
       "message": "Postflight verification failed: status not updated in state.json",
       "code": "VERIFICATION_FAILED",
       "severity": "CRITICAL",
       "recoverable": false,
       "recommendation": "Manually update state.json and TODO.md, or retry command"
     }
     ```
   - NON-CRITICAL errors (git failures):
     ```json
     {
       "type": "git_commit_failed",
       "message": "Git commit failed: {error_details}",
       "code": "GIT_COMMIT_FAILED",
       "severity": "NON-CRITICAL",
       "recoverable": true,
       "recommendation": "Manually create git commit: git add . && git commit -m 'task {number}: {description}'"
     }
     ```

2. Update researcher.md error logging:
   - Log CRITICAL error if verification fails
   - Log NON-CRITICAL error if git-workflow-manager fails
   - Return status="failed" for CRITICAL errors
   - Return status="completed" for NON-CRITICAL errors

3. Update planner.md and implementer.md with same pattern

**Acceptance Criteria**:
- [ ] Error logging standard implemented in all 3 subagents
- [ ] CRITICAL errors have severity="CRITICAL", recoverable=false
- [ ] NON-CRITICAL errors have severity="NON-CRITICAL", recoverable=true
- [ ] All errors include recommendation field
- [ ] Consistent error format across all subagents

**Validation**:
- Review error logging code in subagents
- Verify error format matches standard
- Verify severity field present and correct

---

### Phase 4: Add Minimal Command-Level Validation [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Add minimal validation to workflow commands (stage 3) to surface CRITICAL failures only.

**Tasks**:
1. Update /research command stage 3 (ValidateReturn):
   - Add VALIDATION STEP 4: Check for CRITICAL errors
   - Extract errors array from subagent return
   - Check for errors with severity="CRITICAL"
   - If CRITICAL error found:
     * Display brief message: "Task {number}: Postflight failed. Run /errors for details."
     * Exit with error
   - If no CRITICAL errors:
     * Check for NON-CRITICAL errors (git failures)
     * If found: Display brief message: "Task {number}: {artifact} created. Git commit failed."
     * Continue (don't fail command)

2. Update /plan, /revise, /implement commands with same pattern

3. Keep validation minimal:
   - Single check for CRITICAL errors
   - Brief user feedback
   - No verbose error messages
   - Recommend /errors for details

**Acceptance Criteria**:
- [ ] All 4 commands check for CRITICAL errors
- [ ] CRITICAL errors fail command with brief message
- [ ] NON-CRITICAL errors display brief warning
- [ ] User feedback is minimal (task number, artifact, work summary, failures)
- [ ] Recommendation to run /errors for details

**Validation**:
- Read updated command files
- Verify validation is minimal (single check)
- Verify user feedback is brief
- Verify /errors recommendation present

---

### Phase 5: Testing and Validation [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Test all changes and validate no regressions.

**Tasks**:
1. Test verification checkpoint:
   - Manually break status-sync-manager (simulate failure)
   - Verify subagent logs CRITICAL error
   - Verify subagent returns status="failed"
   - Verify command fails with brief message

2. Test git failure handling:
   - Manually break git-workflow-manager (simulate failure)
   - Verify subagent logs NON-CRITICAL error
   - Verify subagent returns status="completed"
   - Verify command displays brief warning

3. Test normal workflow:
   - Run /research on test task
   - Verify artifact created
   - Verify status updated in state.json AND TODO.md
   - Verify artifact linked in TODO.md
   - Verify git commit created (if git works)
   - Verify brief user feedback

4. Regression testing:
   - Run /plan, /revise, /implement on test tasks
   - Verify all workflows still work
   - Verify no verbose output

**Acceptance Criteria**:
- [ ] Verification checkpoint catches status-sync-manager failures
- [ ] Git failures logged as NON-CRITICAL
- [ ] Commands surface CRITICAL failures with brief message
- [ ] Normal workflow still works
- [ ] User feedback is minimal
- [ ] No regressions in existing functionality

**Validation**:
- Review test results
- Verify all test cases pass
- Verify error logging correct
- Verify user feedback minimal

---

## Testing and Validation

### Unit Testing

**Test 1: Verification Checkpoint Catches Status-Sync-Manager Failure**
- Simulate status-sync-manager failure
- Verify subagent logs CRITICAL error
- Verify subagent returns status="failed"
- Expected: Command fails with brief message

**Test 2: Git Failure Logged as NON-CRITICAL**
- Simulate git-workflow-manager failure
- Verify subagent logs NON-CRITICAL error
- Verify subagent returns status="completed"
- Expected: Command displays brief warning

**Test 3: Command-Level Validation Surfaces CRITICAL Failures**
- Run /research with status-sync-manager failure
- Verify command checks errors array
- Verify command displays brief message
- Expected: User sees "Postflight failed. Run /errors for details."

### Integration Testing

**Test 4: Normal Workflow Still Works**
- Run /research on test task
- Verify artifact created, status updated, artifact linked, git commit created
- Expected: Brief user feedback, no errors

**Test 5: All Commands Updated**
- Run /plan, /revise, /implement on test tasks
- Verify all commands have CRITICAL error validation
- Expected: Consistent behavior across all commands

### Regression Testing

**Test 6: No Regressions in Existing Functionality**
- Run full workflow: /research → /plan → /implement
- Verify all artifacts created
- Verify all status updates correct
- Verify all git commits created
- Expected: No regressions, minimal user feedback

---

## Artifacts and Outputs

### New Files

1. `.opencode/context/core/standards/postflight-preflight.md`
   - Shared context file with task 321
   - Two-level error logging standard
   - Verification checkpoint pattern
   - User feedback format

### Modified Files

1. `.opencode/agent/subagents/researcher.md`
   - Add verification checkpoint in step_4_postflight
   - Add two-level error logging

2. `.opencode/agent/subagents/planner.md`
   - Add verification checkpoint in step_7
   - Add two-level error logging

3. `.opencode/agent/subagents/implementer.md`
   - Add verification checkpoint in postflight
   - Add two-level error logging

4. `.opencode/command/research.md`
   - Add CRITICAL error validation in stage 3
   - Add brief user feedback

5. `.opencode/command/plan.md`
   - Add CRITICAL error validation in stage 3
   - Add brief user feedback

6. `.opencode/command/revise.md`
   - Add CRITICAL error validation in stage 3
   - Add brief user feedback

7. `.opencode/command/implement.md`
   - Add CRITICAL error validation in stage 3
   - Add brief user feedback

---

## Rollback/Contingency

### Rollback Plan

If implementation causes regressions:

1. **Identify Regression**:
   - Test all 4 workflow commands
   - Identify which command/subagent has regression

2. **Revert Changes**:
   - Use git to revert specific file changes
   - Test reverted version
   - Verify regression resolved

3. **Isolate Issue**:
   - Review changes that caused regression
   - Fix issue in isolation
   - Re-apply fix with additional testing

### Contingency Plan

If verification checkpoint causes false positives:

1. **Adjust Verification Logic**:
   - Review jq/grep commands
   - Add more specific checks
   - Reduce false positive rate

2. **Add Retry Logic**:
   - If verification fails, retry once after 1 second
   - Handles race conditions in file updates

3. **Fallback to Warning**:
   - If verification fails but status-sync-manager returned "completed"
   - Log warning instead of failing command
   - Preserve user work

---

## Success Metrics

### Quantitative Metrics

1. **Status Update Success Rate**: 100% (up from ~0% for failing cases)
2. **Artifact Linking Success Rate**: 100% (up from ~0% for failing cases)
3. **CRITICAL Error Surfacing Rate**: 100% (all CRITICAL failures visible to users)
4. **False Positive Rate**: <5% (verification checkpoint accuracy)
5. **Regression Rate**: 0% (no existing functionality broken)

### Qualitative Metrics

1. **User Awareness**: Users see CRITICAL failures immediately
2. **User Feedback**: Minimal output (task number, artifact, work summary, failures)
3. **Workflow Robustness**: Commands handle failures gracefully
4. **Error Clarity**: Error messages are brief with /errors recommendation

### Acceptance Criteria

- [ ] All CRITICAL failures surfaced to users
- [ ] User feedback is minimal
- [ ] No regressions in existing functionality
- [ ] Two-level error logging implemented
- [ ] Single verification checkpoint added
- [ ] Integration with task 321 documented

---

## Phase Status Summary

| Phase | Status | Estimated Effort | Actual Effort |
|-------|--------|------------------|---------------|
| Phase 1: Shared Standards File | [NOT STARTED] | 0.5 hours | - |
| Phase 2: Verification Checkpoint | [NOT STARTED] | 2 hours | - |
| Phase 3: Two-Level Error Logging | [NOT STARTED] | 1 hour | - |
| Phase 4: Command-Level Validation | [NOT STARTED] | 1 hour | - |
| Phase 5: Testing and Validation | [NOT STARTED] | 0.5 hours | - |
| **Total** | **[NOT STARTED]** | **5 hours** | **-** |

---

## Notes

### User Requirements Summary

User clarified that:
1. **MOST IMPORTANT**: Fix missing artifact links and status updates (CRITICAL)
2. **Git failures**: Passing failures of little concern, just log in errors.json
3. **User feedback**: Very minimal - task number, artifact, work summary, failures
4. **Validation**: Minimal and well-placed, check everything at once
5. **Integration with task 321**: Coordinate on shared context files

### Research Findings Summary

Research-001.md identified git failures as root cause, but user clarifies status/artifact failures are MORE critical. Key evidence:
- Task 314 shows artifact created, status updated, artifact linked, but NO git commit
- Postflight steps DO exist and DO execute
- Git failures treated as non-critical, so subagents return "completed" anyway
- Commands have no validation to detect failures

### Implementation Strategy

1. **Shared Standards**: Create context file with task 321 for consistency
2. **Single Checkpoint**: Verify status AND artifact linking at once (minimal, well-placed)
3. **Two-Level Errors**: CRITICAL (status/artifacts) vs NON-CRITICAL (git)
4. **Brief Feedback**: Task number, artifact, work summary, failures with /errors recommendation
5. **Minimal Validation**: Single check in commands for CRITICAL errors only

### Integration with Task 321

Task 321 focuses on preflight failures (status not updated to in-progress). This task focuses on postflight failures (status not updated to completion, artifact not linked). Both tasks will:
- Share `.opencode/context/core/standards/postflight-preflight.md` context file
- Use same two-level error logging standard
- Use same verification checkpoint pattern
- Use same user feedback format

---

**Plan Created**: 2026-01-05  
**Plan Version**: 2  
**Estimated Total Effort**: 5 hours  
**Complexity**: Medium  
**Research Integrated**: Yes  
**Revision Reason**: User clarification on priorities and requirements
