# Implementation Plan: Fix Systematic Postflight Failures in Workflow Commands

**Task**: 320 - Fix workflow command postflight failures causing missing artifact links and status updates  
**Status**: [PLANNED]  
**Estimated Effort**: 6 hours  
**Complexity**: Medium  
**Language**: meta  
**Priority**: High  
**Created**: 2026-01-05  
**Plan Version**: 1

---

## Metadata

- **Task Number**: 320
- **Dependencies**: None
- **Blocking**: None
- **Related Tasks**: 
  - Task 321 (preflight failures) - complementary fix
  - Task 291 (lean-research-agent) - separate issue
- **Research Integrated**: Yes
- **Reports Integrated**:
  - `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-001.md` (integrated 2026-01-05)

---

## Overview

### Problem Statement

Workflow commands (/research, /plan, /revise, /implement) exhibit systematic postflight failures where artifacts are created successfully but git commits are missing. Research reveals the root cause is **silent git commit failures**, NOT missing postflight steps. Subagents DO execute postflight steps and invoke status-sync-manager (which succeeds) and git-workflow-manager (which fails silently). Because git failures are treated as non-critical, subagents return status="completed" even when git commits fail, and commands have no mechanism to detect or surface these failures to users.

### Research Integration

This plan integrates findings from research-001.md:

**Key Research Findings**:
1. **Root Cause Identified**: Silent git-workflow-manager failures, not missing postflight steps
2. **Evidence**: Task 314 shows artifact created, status updated, artifact linked, but NO git commit
3. **Postflight Steps DO Exist**: researcher.md (step_4_postflight) and planner.md (step_7) properly delegate to status-sync-manager and git-workflow-manager
4. **Non-Critical Git Handling**: Subagents treat git failures as non-critical and return "completed" anyway
5. **Validation Gap**: Commands validate return format but do NOT check if git commits were created

**Research Recommendations**:
- Add git commit validation to workflow commands (stage 3)
- Surface git failures to users with manual recovery steps
- Check errors array in subagent returns
- Maintain non-critical git failure handling (preserve user work)

### Scope

**In Scope**:
1. Add single surgical verification checkpoint in subagent postflight (after status-sync-manager, before git-workflow-manager)
2. Implement two-level error logging in errors.json:
   - CRITICAL: Status/artifact linking failures (fail command)
   - NON-CRITICAL: Git commit failures (log but continue)
3. Add command-level validation to surface git failures to users
4. Provide manual recovery steps for git failures
5. Integration strategy with task 321 (preflight verification)

**Out of Scope**:
- Making git commits critical (would lose user work on git failure)
- Adding multiple verification checkpoints (avoid workflow bloat)
- Fixing lean-research-agent direct file manipulation (task 291)
- Fixing preflight status update failures (task 321)

### Constraints

1. **Minimal Verification**: Single checkpoint after status-sync-manager, not scattered throughout workflow
2. **Two-Level Error Logging**: CRITICAL vs NON-CRITICAL distinction in errors.json
3. **Preserve User Work**: Git failures should NOT fail research/planning (artifact already created)
4. **No Workflow Bloat**: Avoid adding too many verification steps
5. **Integration with Task 321**: Design should complement preflight verification approach

### Definition of Done

- [ ] Single verification checkpoint added to subagent postflight (after status-sync-manager)
- [ ] Two-level error logging implemented (CRITICAL vs NON-CRITICAL)
- [ ] Command-level validation surfaces git failures to users
- [ ] Manual recovery steps provided for git failures
- [ ] All 4 workflow commands updated (/research, /plan, /revise, /implement)
- [ ] All 3 subagents updated (researcher, planner, implementer)
- [ ] Integration strategy documented for task 321
- [ ] Git commit created for changes
- [ ] No regression in existing functionality

---

## Goals and Non-Goals

### Goals

1. **Surface Silent Git Failures**: Make git-workflow-manager failures visible to users
2. **Provide Recovery Steps**: Give users clear manual recovery instructions
3. **Preserve User Work**: Maintain non-critical git failure handling
4. **Minimal Verification**: Single checkpoint, not multiple scattered checks
5. **Two-Level Error Logging**: Distinguish CRITICAL from NON-CRITICAL failures
6. **Robust Functionality**: Fix root cause, not just report failures

### Non-Goals

1. **Make Git Commits Critical**: Would lose user work on git failure
2. **Add Multiple Checkpoints**: Would clutter workflow
3. **Fix Lean-Research-Agent**: Separate issue (task 291)
4. **Fix Preflight Failures**: Separate issue (task 321)
5. **Implement Rollback**: Out of scope for this fix

---

## Risks and Mitigations

### Risk 1: Git-Workflow-Manager May Have Underlying Bugs

**Risk**: If git-workflow-manager is failing systematically due to bugs, validation won't solve the root issue.

**Likelihood**: Medium  
**Impact**: High

**Mitigation**:
1. Test git-workflow-manager in isolation before implementing validation
2. Check git-workflow-manager logs for systematic errors
3. Verify git-workflow-manager return format compliance
4. Fix git-workflow-manager bugs if found (separate task if needed)

### Risk 2: Validation May Increase Context Window Usage

**Risk**: Adding validation steps to commands increases context window usage.

**Likelihood**: Low  
**Impact**: Low

**Mitigation**:
1. Keep validation concise (single checkpoint)
2. Use brief error messages
3. Delegate detailed validation to subagents
4. Follow context window protection guidelines

### Risk 3: Integration with Task 321 May Require Coordination

**Risk**: Task 321 (preflight failures) may use different error logging approach.

**Likelihood**: Medium  
**Impact**: Medium

**Mitigation**:
1. Document two-level error logging standard for both tasks
2. Use consistent error format (type, message, code, recoverable, recommendation)
3. Coordinate with task 321 implementation if needed

---

## Implementation Phases

### Phase 1: Add Verification Checkpoint to Subagent Postflight [NOT STARTED]

**Estimated Effort**: 1.5 hours

**Objective**: Add single surgical verification checkpoint in subagent postflight after status-sync-manager succeeds.

**Tasks**:
1. Update researcher.md step_4_postflight:
   - After status-sync-manager validation (step 2f)
   - Add checkpoint: Verify status updated in state.json AND TODO.md AND artifact linked
   - Use jq to check state.json status field
   - Use grep to check TODO.md status marker and artifact link
   - If verification fails: Log CRITICAL error, return status="failed"
   - If verification succeeds: Continue to git-workflow-manager

2. Update planner.md step_7:
   - After status-sync-manager validation (step 7.1)
   - Add same verification checkpoint
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
- [ ] CRITICAL error logged if verification fails
- [ ] Subagent returns status="failed" if verification fails

**Validation**:
- Read updated subagent files
- Verify checkpoint uses jq and grep (not bash file manipulation)
- Verify checkpoint is AFTER status-sync-manager, BEFORE git-workflow-manager
- Verify error logging follows two-level format

---

### Phase 2: Implement Two-Level Error Logging [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Implement two-level error logging in errors.json with CRITICAL vs NON-CRITICAL distinction.

**Tasks**:
1. Define error logging standard:
   - CRITICAL errors: Status/artifact linking failures
     * type: "status_sync_failed", "artifact_link_failed", "verification_failed"
     * recoverable: false
     * recommendation: Manual recovery steps
   - NON-CRITICAL errors: Git commit failures
     * type: "git_commit_failed"
     * recoverable: true
     * recommendation: Manual git commit steps

2. Update subagent error logging:
   - researcher.md: Log CRITICAL error if verification fails
   - researcher.md: Log NON-CRITICAL error if git-workflow-manager fails
   - planner.md: Same pattern
   - implementer.md: Same pattern

3. Document error format in errors.json:
   ```json
   {
     "type": "status_sync_failed",
     "message": "Status update verification failed: status not updated in state.json",
     "code": "VERIFICATION_FAILED",
     "severity": "CRITICAL",
     "recoverable": false,
     "recommendation": "Manually update state.json and TODO.md, or retry command"
   }
   ```

**Acceptance Criteria**:
- [ ] Error logging standard documented
- [ ] CRITICAL errors have severity="CRITICAL", recoverable=false
- [ ] NON-CRITICAL errors have severity="NON-CRITICAL", recoverable=true
- [ ] All subagents use consistent error format
- [ ] Error recommendations provide manual recovery steps

**Validation**:
- Review error logging code in subagents
- Verify error format matches standard
- Verify severity field present and correct

---

### Phase 3: Add Command-Level Validation for Git Failures [NOT STARTED]

**Estimated Effort**: 2 hours

**Objective**: Add validation to workflow commands (stage 3) to surface git failures and provide manual recovery steps.

**Tasks**:
1. Update /research command stage 3 (ValidateReturn):
   - Add VALIDATION STEP 4: Check Git Commit Created
   - Extract metadata.git_commit from subagent return
   - If git_commit is null/empty:
     * Check errors array for git-related errors
     * If git error found:
       - Display warning: "Git commit failed: {error_message}"
       - Display manual recovery steps:
         1. Review changes: `git status`
         2. Create commit: `git add . && git commit -m "task {number}: research completed"`
         3. Verify commit: `git log -1`
     * If no git error but no commit:
       - Log error: "Postflight incomplete: git commit missing"

2. Update /plan command stage 3:
   - Add same validation step
   - Adjust commit message template: "task {number}: plan created"

3. Update /revise command stage 3:
   - Add same validation step
   - Adjust commit message template: "task {number}: plan revised"

4. Update /implement command stage 3:
   - Add same validation step
   - Adjust commit message template: "task {number}: implementation completed"

5. Add VALIDATION STEP 5: Check Errors Array
   - Extract errors from subagent return
   - If errors array non-empty:
     * For each error:
       - Log error type and message
       - If error.severity == "CRITICAL":
         * Fail command with error details
       - If error.severity == "NON-CRITICAL":
         * Display warning with recovery steps

**Acceptance Criteria**:
- [ ] All 4 commands have git commit validation
- [ ] All 4 commands check errors array
- [ ] CRITICAL errors fail command
- [ ] NON-CRITICAL errors display warnings with recovery steps
- [ ] Manual recovery steps are clear and actionable

**Validation**:
- Read updated command files
- Verify validation steps added to stage 3
- Verify error handling logic correct
- Verify manual recovery steps present

---

### Phase 4: Document Integration Strategy with Task 321 [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Document integration strategy with task 321 (preflight verification) to ensure consistent approach.

**Tasks**:
1. Create integration document:
   - File: `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/integration-with-321.md`
   - Document two-level error logging standard
   - Document verification checkpoint pattern
   - Document error format for both preflight and postflight

2. Coordinate with task 321:
   - Preflight verification: Check status updated to [RESEARCHING]/[PLANNING]/etc.
   - Postflight verification: Check status updated to [RESEARCHED]/[PLANNED]/etc. AND artifact linked
   - Both use same error logging format
   - Both use single checkpoint (not multiple)

3. Document error logging standard:
   - CRITICAL errors: Status update failures (preflight or postflight)
   - NON-CRITICAL errors: Git commit failures (postflight only)
   - Error format: {type, message, code, severity, recoverable, recommendation}

**Acceptance Criteria**:
- [ ] Integration document created
- [ ] Two-level error logging standard documented
- [ ] Verification checkpoint pattern documented
- [ ] Coordination with task 321 clear

**Validation**:
- Read integration document
- Verify standard is consistent with task 321 approach
- Verify error format matches both tasks

---

### Phase 5: Testing and Validation [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Test all changes and validate no regressions.

**Tasks**:
1. Test verification checkpoint:
   - Manually break status-sync-manager (simulate failure)
   - Verify subagent logs CRITICAL error
   - Verify subagent returns status="failed"
   - Verify command fails with error details

2. Test git failure handling:
   - Manually break git-workflow-manager (simulate failure)
   - Verify subagent logs NON-CRITICAL error
   - Verify subagent returns status="completed" with warning
   - Verify command displays manual recovery steps

3. Test command-level validation:
   - Run /research with git failure
   - Verify command displays git failure warning
   - Verify manual recovery steps shown
   - Verify research artifact still created

4. Test normal workflow:
   - Run /research on test task
   - Verify artifact created
   - Verify status updated
   - Verify artifact linked
   - Verify git commit created
   - Verify no errors logged

5. Regression testing:
   - Run /plan on test task
   - Run /revise on test task
   - Run /implement on test task
   - Verify all workflows still work

**Acceptance Criteria**:
- [ ] Verification checkpoint catches status-sync-manager failures
- [ ] Git failures logged as NON-CRITICAL
- [ ] Commands surface git failures with recovery steps
- [ ] Normal workflow still works
- [ ] No regressions in existing functionality

**Validation**:
- Review test results
- Verify all test cases pass
- Verify error logging correct
- Verify manual recovery steps work

---

## Testing and Validation

### Unit Testing

**Test 1: Verification Checkpoint Catches Status-Sync-Manager Failure**
- Simulate status-sync-manager failure
- Verify subagent logs CRITICAL error
- Verify subagent returns status="failed"
- Expected: Command fails with error details

**Test 2: Git Failure Logged as NON-CRITICAL**
- Simulate git-workflow-manager failure
- Verify subagent logs NON-CRITICAL error
- Verify subagent returns status="completed"
- Expected: Command displays warning with recovery steps

**Test 3: Command-Level Validation Surfaces Git Failures**
- Run /research with git failure
- Verify command checks metadata.git_commit
- Verify command displays manual recovery steps
- Expected: User sees warning and recovery instructions

### Integration Testing

**Test 4: Normal Workflow Still Works**
- Run /research on test task
- Verify artifact created, status updated, artifact linked, git commit created
- Expected: No errors, all postflight steps succeed

**Test 5: All Commands Updated**
- Run /plan, /revise, /implement on test tasks
- Verify all commands have git failure validation
- Expected: Consistent behavior across all commands

### Regression Testing

**Test 6: No Regressions in Existing Functionality**
- Run full workflow: /research → /plan → /implement
- Verify all artifacts created
- Verify all status updates correct
- Verify all git commits created
- Expected: No regressions

---

## Artifacts and Outputs

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
   - Add git commit validation in stage 3
   - Add errors array validation

5. `.opencode/command/plan.md`
   - Add git commit validation in stage 3
   - Add errors array validation

6. `.opencode/command/revise.md`
   - Add git commit validation in stage 3
   - Add errors array validation

7. `.opencode/command/implement.md`
   - Add git commit validation in stage 3
   - Add errors array validation

### New Files

1. `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/integration-with-321.md`
   - Integration strategy with task 321
   - Two-level error logging standard
   - Verification checkpoint pattern

### Documentation Updates

1. Error logging standard documented
2. Verification checkpoint pattern documented
3. Manual recovery steps documented

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

1. **Git Commit Success Rate**: 100% (up from ~0% for failing cases)
2. **Error Surfacing Rate**: 100% (git failures visible to users)
3. **False Positive Rate**: <5% (verification checkpoint accuracy)
4. **Regression Rate**: 0% (no existing functionality broken)

### Qualitative Metrics

1. **User Awareness**: Users see git failures and recovery steps
2. **Manual Recovery Success**: Users can recover from git failures
3. **Workflow Robustness**: Commands handle failures gracefully
4. **Error Clarity**: Error messages are clear and actionable

### Acceptance Criteria

- [ ] All git failures surfaced to users
- [ ] Manual recovery steps provided
- [ ] No regressions in existing functionality
- [ ] Two-level error logging implemented
- [ ] Single verification checkpoint added
- [ ] Integration with task 321 documented

---

## Phase Status Summary

| Phase | Status | Estimated Effort | Actual Effort |
|-------|--------|------------------|---------------|
| Phase 1: Add Verification Checkpoint | [NOT STARTED] | 1.5 hours | - |
| Phase 2: Two-Level Error Logging | [NOT STARTED] | 1 hour | - |
| Phase 3: Command-Level Validation | [NOT STARTED] | 2 hours | - |
| Phase 4: Integration Strategy | [NOT STARTED] | 0.5 hours | - |
| Phase 5: Testing and Validation | [NOT STARTED] | 1 hour | - |
| **Total** | **[NOT STARTED]** | **6 hours** | **-** |

---

## Notes

### Research Findings Summary

Research-001.md identified the root cause as silent git-workflow-manager failures, not missing postflight steps. Key evidence:
- Task 314 shows artifact created, status updated, artifact linked, but NO git commit
- Postflight steps DO exist and DO execute
- Git failures treated as non-critical, so subagents return "completed" anyway
- Commands have no validation to detect git failures

### User Requirements Alignment

This plan aligns with all user requirements:
1. ✓ Postflight failures are CONSISTENT (systematic git failures)
2. ✓ Minimal verification checkpoints (single checkpoint after status-sync-manager)
3. ✓ Critical checkpoint verifies status in state.json AND TODO.md AND artifact linked
4. ✓ Two-level error logging (CRITICAL vs NON-CRITICAL)
5. ✓ Focus on robust functionality (fix root cause, not just report)
6. ✓ Integration with task 321 (documented in phase 4)

### Implementation Strategy

1. **Surgical Fix**: Single verification checkpoint, not scattered checks
2. **Preserve User Work**: Git failures remain non-critical
3. **Surface Failures**: Command-level validation makes failures visible
4. **Manual Recovery**: Clear recovery steps for users
5. **Consistent Pattern**: Same approach across all commands/subagents

---

**Plan Created**: 2026-01-05  
**Plan Version**: 1  
**Estimated Total Effort**: 6 hours  
**Complexity**: Medium  
**Research Integrated**: Yes
