# Implementation Plan: Fix Remaining Postflight Issues After Task 321 (v4)

**Task**: 320 - Fix workflow command postflight failures causing missing artifact links and status updates  
**Status**: [PLANNED]  
**Estimated Effort**: 2.5 hours  
**Complexity**: Low-Medium  
**Language**: meta  
**Priority**: High  
**Created**: 2026-01-05  
**Plan Version**: 4  
**Revision Reason**: Task 321 (completed 2026-01-05) already fixed bugs #7, #3, #2, enhanced all 6 subagents with preflight/postflight verification, created status-markers.md, and implemented atomic writes. Plan v4 focuses ONLY on remaining work not covered by task 321.

---

## Metadata

- **Task Number**: 320
- **Dependencies**: Task 321 (completed 2026-01-05)
- **Blocking**: None
- **Related Tasks**: 
  - Task 321 (preflight/postflight fixes) - COMPLETED, provides foundation
  - Task 291 (lean-research-agent) - separate issue
- **Research Integrated**: Yes
- **Reports Integrated**:
  - `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-001.md` (integrated 2026-01-05)
  - `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-002.md` (integrated 2026-01-05)
  - `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-003.md` (integrated 2026-01-05)

---

## Overview

### Problem Statement (Updated After Task 321)

**CONTEXT**: Task 321 (completed 2026-01-05) already fixed the CRITICAL bugs causing postflight failures:
- ✅ Bug #7 (Missing Post-Commit Verification) - FIXED by task 321
- ✅ Bug #3 (Silent Validation Failures) - FIXED by task 321
- ✅ Bug #2 (Race Condition) - FIXED by task 321
- ✅ Enhanced all 6 subagents with preflight/postflight verification checkpoints
- ✅ Created status-markers.md convention file
- ✅ Implemented atomic writes (write to temp, rename)
- ✅ Removed backup files (git-only rollback)

**REMAINING WORK** (from research-003.md):
1. Bug #5 (No Retry Logic) - Add retry with exponential backoff for transient failures
2. Bug #6 (Artifact Validation Timing) - Add artifact validation retry for timing issues
3. Two-Level Error Logging - Formalize CRITICAL vs NON-CRITICAL standard
4. Command-Level Validation - Surface CRITICAL errors to users
5. Testing - Validate integrated solution (preflight + postflight)

### User Requirements (Clarified)

1. **MOST IMPORTANT**: Fix missing artifact links and status updates (CRITICAL) - ✅ DONE by task 321
2. **Git failures**: Passing failures of little concern (NON-CRITICAL)
3. **User feedback**: Very minimal - task number, artifact, work summary, failures
4. **Validation**: Minimal and well-placed
5. **NO file locking**: Allow many agents to work on tasks concurrently - ✅ DONE by task 321
6. **NO backup files**: Rely on git exclusively for rollback - ✅ DONE by task 321
7. **FOCUS on timing**: Rethink preflight/postflight process for timing certainty - ✅ DONE by task 321

### Research Integration

**Research-003.md** (Task 321 Implementation Analysis):
- Task 321 completed 6 of 11 sub-phases from plan v3 (~5.5 hours of 7.5 hours)
- Remaining work: Bugs #5, #6, error logging formalization, command validation, testing
- Estimated remaining effort: 2.5 hours (down from 7.5 hours)

### Scope

**In Scope**:
1. Add Bug #5 fix (retry logic with exponential backoff) to status-sync-manager
2. Add Bug #6 fix (artifact validation retry) to status-sync-manager
3. Formalize two-level error logging standard (CRITICAL vs NON-CRITICAL)
4. Add command-level validation to surface CRITICAL errors to users
5. Test integrated solution (preflight + postflight from task 321)

**Out of Scope** (Already Done by Task 321):
- Bug #7 (Missing Post-Commit Verification) - ✅ FIXED
- Bug #3 (Silent Validation Failures) - ✅ FIXED
- Bug #2 (Race Condition) - ✅ FIXED
- Verification checkpoints in subagents - ✅ ADDED
- Status markers convention file - ✅ CREATED
- Atomic write pattern - ✅ IMPLEMENTED
- Backup file removal - ✅ DONE

### Constraints

1. **NO File Locking**: Allow concurrent agents (task 321 implemented this)
2. **NO Backup Files**: Use git exclusively for rollback (task 321 implemented this)
3. **Timing Certainty**: Atomic writes implemented by task 321
4. **Minimal Validation**: Single checkpoint per workflow stage
5. **Two-Level Error Logging**: CRITICAL (status/artifacts) vs NON-CRITICAL (git)
6. **Brief User Feedback**: Task number, artifact, single sentence, failures

### Definition of Done

- [ ] Bug #5 fixed (retry logic with exponential backoff added to status-sync-manager)
- [ ] Bug #6 fixed (artifact validation retry added to status-sync-manager)
- [ ] Two-level error logging standard formalized and documented
- [ ] Command-level validation added to surface CRITICAL errors
- [ ] Integrated solution tested (preflight + postflight)
- [ ] All 4 workflow commands validated
- [ ] Git commit created for changes
- [ ] No regression in existing functionality

---

## Goals and Non-Goals

### Goals

1. **Complete Remaining Fixes**: Add bugs #5 and #6 fixes to status-sync-manager
2. **Formalize Error Logging**: Document CRITICAL vs NON-CRITICAL error standard
3. **Surface CRITICAL Errors**: Add minimal command-level validation
4. **Validate Integration**: Test that task 321 fixes work for postflight scenarios
5. **Brief User Feedback**: Maintain minimal output

### Non-Goals

1. **Duplicate Task 321 Work**: Don't re-implement bugs #7, #3, #2 fixes
2. **Add File Locking**: User wants concurrent agents
3. **Add Backup Files**: User wants git-only rollback
4. **Add Multiple Checkpoints**: User wants minimal validation
5. **Verbose User Feedback**: User wants very minimal output

---

## Risks and Mitigations

### Risk 1: Task 321 Fixes May Not Work for All Postflight Scenarios

**Risk**: Task 321 focused on preflight failures. Postflight scenarios may have unique issues.

**Likelihood**: LOW  
**Impact**: MEDIUM

**Mitigation**:
1. Test all postflight scenarios thoroughly (Phase 5)
2. Verify artifact linking works correctly
3. Verify git-workflow-manager integration works
4. Document any postflight-specific issues

### Risk 2: Remaining Bugs (#5, #6) May Cause Transient Failures

**Risk**: Without retry logic and artifact validation retry, transient failures may still occur.

**Likelihood**: LOW  
**Impact**: MEDIUM

**Mitigation**:
1. Implement bugs #5 and #6 fixes as planned (Phases 1-2)
2. Test with simulated transient failures
3. Document manual recovery procedures

### Risk 3: Command-Level Validation May Be Redundant

**Risk**: Subagent verification checkpoints (from task 321) may be enough; command-level validation may be redundant.

**Likelihood**: MEDIUM  
**Impact**: LOW

**Mitigation**:
1. Test if subagent verification catches all failures
2. Add command-level validation only if needed
3. Keep validation minimal (single check)

---

## Implementation Phases

### Phase 1: Add Bug #5 Fix (Retry Logic) to status-sync-manager [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Add retry logic with exponential backoff for transient write failures.

**Tasks**:

**1.1: Add Retry Logic to step_4_commit**

Update `.opencode/agent/subagents/status-sync-manager.md` step_4_commit:

```xml
<step_4_commit>
  <action>Phase 2: Commit all updates atomically</action>
  <process>
    1. Write to temporary files WITH RETRY:
       
       For each file (TODO.md, state.json, plan_path if provided):
       a. Attempt write up to 3 times with exponential backoff:
          
          for attempt in 1 2 3; do
            if write_file "$temp_file" "$content"; then
              break
            fi
            if [ $attempt -lt 3 ]; then
              sleep $((attempt * 2))  # 2s, 4s exponential backoff
              echo "Write failed (attempt $attempt/3), retrying..."
            else
              echo "Write failed after 3 attempts"
              rm -f *.tmp  # Cleanup temp files
              return_failed_status "File write failed after 3 retries"
              exit 1
            fi
          done
       
       b. Verify temp file written successfully:
          - Check file exists: [ -f "$temp_file" ]
          - Check file non-empty: [ -s "$temp_file" ]
          - If verification fails: Cleanup and return failed
    
    2. Atomic rename (existing logic from task 321):
       - mv ".opencode/specs/TODO.md.tmp" ".opencode/specs/TODO.md" && \
         mv ".opencode/specs/state.json.tmp" ".opencode/specs/state.json" && \
         ([ -z "$plan_path" ] || mv "$plan_path.tmp" "$plan_path") || \
         { rm -f *.tmp; exit 1; }
    
    3. If rename fails (existing logic from task 321):
       - Remove all temp files
       - Return status="failed" with error details
  </process>
  <retry_logic>
    Retry parameters:
    - Max attempts: 3
    - Backoff: Exponential (2s, 4s)
    - Retry on: Write failures (disk full, temporary permissions)
    - No retry on: Validation failures (invalid content)
  </retry_logic>
</step_4_commit>
```

**Acceptance Criteria**:
- [ ] Retry logic added to file write operations
- [ ] Exponential backoff implemented (2s, 4s)
- [ ] Max 3 attempts per file
- [ ] Cleanup on final failure
- [ ] Error message includes retry count

**Validation**:
- Read updated status-sync-manager.md
- Verify retry logic in step_4_commit
- Verify exponential backoff formula

---

### Phase 2: Add Bug #6 Fix (Artifact Validation Retry) to status-sync-manager [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Add artifact validation retry for timing issues (filesystem sync delays).

**Tasks**:

**2.1: Add Artifact Validation Retry to step_2_validate**

Update `.opencode/agent/subagents/status-sync-manager.md` step_2_validate:

```xml
<step_2_validate>
  <action>Validate status transition and artifacts</action>
  <process>
    1. Pre-commit validation (existing from task 321)
    
    2. Artifact validation WITH RETRY (NEW):
       
       If validated_artifacts array provided:
       a. For each artifact in validated_artifacts:
          
          # First attempt
          if [ -f "$artifact_path" ] && [ -s "$artifact_path" ]; then
            continue  # Artifact valid, check next
          fi
          
          # Retry after 1 second (allow filesystem sync)
          echo "Artifact not found, retrying after 1s..."
          sleep 1
          
          # Second attempt
          if [ -f "$artifact_path" ] && [ -s "$artifact_path" ]; then
            continue  # Artifact valid on retry
          fi
          
          # Validation failed after retry
          echo '{"status":"failed","summary":"Artifact validation failed after retry","errors":[...]}'
          exit 1
       
       b. If all artifacts valid: Continue to commit
    
    3. Make validation failures explicit (existing from task 321):
       - All validation failures exit 1
  </process>
  <artifact_validation_retry>
    Retry parameters:
    - Max attempts: 2 (immediate + 1 retry)
    - Delay: 1 second (allow filesystem sync)
    - Retry on: File not found, file empty
    - No retry on: File malformed (content validation)
  </artifact_validation_retry>
</step_2_validate>
```

**Acceptance Criteria**:
- [ ] Artifact validation retry added
- [ ] 1 second delay before retry
- [ ] Max 2 attempts (immediate + retry)
- [ ] Error message includes retry status
- [ ] Validation checks file exists AND non-empty

**Validation**:
- Read updated status-sync-manager.md
- Verify retry logic in step_2_validate
- Verify 1 second delay

---

### Phase 3: Formalize Two-Level Error Logging Standard [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Document CRITICAL vs NON-CRITICAL error logging standard.

**Tasks**:

**3.1: Update status-markers.md with Error Logging Standard**

Update `.opencode/context/system/status-markers.md` (created by task 321):

Add new section:

```markdown
## Error Logging Standard

### Two-Level Error Severity

**CRITICAL Errors** (Block workflow, require user intervention):
- Status synchronization failures (status not updated in TODO.md or state.json)
- Artifact linking failures (artifact not linked in TODO.md)
- Validation failures (invalid status transition, missing required fields)
- Verification checkpoint failures (post-commit verification failed)
- File write failures after retry (disk full, permissions)

**NON-CRITICAL Errors** (Workflow continues, log for awareness):
- Git commit failures (git-workflow-manager failed)
- Git push failures (remote unavailable)
- Optional metadata update failures (non-essential fields)

### Error Format

**CRITICAL Error Format**:
```json
{
  "type": "verification_failed" | "status_sync_failed" | "artifact_link_failed" | "validation_failed",
  "message": "Detailed error message with context",
  "code": "VERIFICATION_FAILED" | "STATUS_SYNC_FAILED" | "ARTIFACT_LINK_FAILED" | "VALIDATION_FAILED",
  "severity": "CRITICAL",
  "recoverable": false,
  "recommendation": "Manual recovery steps or retry command",
  "context": {
    "task_number": 123,
    "artifact_path": "path/to/artifact.md",
    "expected_status": "researched",
    "actual_status": "not_started"
  }
}
```

**NON-CRITICAL Error Format**:
```json
{
  "type": "git_commit_failed" | "git_push_failed",
  "message": "Git operation failed: {error_details}",
  "code": "GIT_COMMIT_FAILED" | "GIT_PUSH_FAILED",
  "severity": "NON-CRITICAL",
  "recoverable": true,
  "recommendation": "Manually create git commit: git add . && git commit -m '...'",
  "context": {
    "task_number": 123,
    "files_modified": ["TODO.md", "state.json"]
  }
}
```

### Error Handling Protocol

**For CRITICAL Errors**:
1. Subagent logs error to errors.json
2. Subagent returns status="failed" with error array
3. Command validates return and surfaces error to user
4. User sees brief message: "Task {number}: Postflight failed. Run /errors for details."
5. Workflow ABORTS (do not proceed)

**For NON-CRITICAL Errors**:
1. Subagent logs error to errors.json
2. Subagent returns status="completed" with warning in errors array
3. Command validates return and displays brief warning
4. User sees brief message: "Task {number}: {artifact} created. Git commit failed."
5. Workflow CONTINUES (do not abort)

### Integration with Verification Checkpoints

Verification checkpoints (added by task 321) detect CRITICAL errors:
- Post-commit content verification (status-sync-manager step_5)
- Defense-in-depth verification (subagent postflight)

If verification checkpoint fails:
- Log CRITICAL error
- Return status="failed"
- Surface to user via command validation
```

**Acceptance Criteria**:
- [ ] Two-level error severity defined (CRITICAL vs NON-CRITICAL)
- [ ] Error format specified for both levels
- [ ] Error handling protocol documented
- [ ] Integration with verification checkpoints explained
- [ ] Examples provided for both error types

**Validation**:
- Read updated status-markers.md
- Verify error logging standard section added
- Verify format matches examples

---

### Phase 4: Add Command-Level Validation to Surface CRITICAL Errors [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Add minimal validation to workflow commands to surface CRITICAL failures to users.

**Tasks**:

**4.1: Update Command Stage 3 (ValidateReturn)**

Update all 4 workflow commands (research.md, plan.md, revise.md, implement.md):

Add to Stage 3 (ValidateReturn):

```xml
<stage id="3" name="ValidateReturn">
  <action>Validate subagent return format and artifacts</action>
  <process>
    1-6. Existing validation steps (from task 321)
    
    7. VALIDATION STEP 7: Check for CRITICAL errors (NEW)
       
       a. Extract errors array from subagent return:
          errors=$(echo "$subagent_return" | jq -r '.errors // []')
       
       b. Check for CRITICAL errors:
          critical_errors=$(echo "$errors" | jq -r '.[] | select(.severity == "CRITICAL")')
       
       c. If CRITICAL error found:
          - Extract error message: msg=$(echo "$critical_errors" | jq -r '.message' | head -1)
          - Display brief message to user:
            echo "Task {task_number}: Postflight failed - $msg"
            echo "Run /errors for full details."
          - Exit with error code 1
       
       d. If no CRITICAL errors, check for NON-CRITICAL errors:
          non_critical=$(echo "$errors" | jq -r '.[] | select(.severity == "NON-CRITICAL")')
          
          If NON-CRITICAL error found:
          - Extract error type: type=$(echo "$non_critical" | jq -r '.type' | head -1)
          - Display brief warning:
            echo "Task {task_number}: {artifact} created successfully."
            echo "Warning: $type (non-critical, workflow continues)"
          - Continue (do not exit)
       
       e. If no errors:
          - Display brief success message:
            echo "Task {task_number}: {artifact} created successfully."
          - Continue to next stage
  </process>
  <user_feedback>
    Keep feedback minimal:
    - Success: "Task {number}: {artifact} created successfully."
    - CRITICAL failure: "Task {number}: Postflight failed - {brief_message}. Run /errors for details."
    - NON-CRITICAL warning: "Task {number}: {artifact} created. Warning: {type} (non-critical)."
  </user_feedback>
</stage>
```

**4.2: Update All 4 Commands**

Apply same validation to:
1. `.opencode/command/research.md`
2. `.opencode/command/plan.md`
3. `.opencode/command/revise.md`
4. `.opencode/command/implement.md`

**Acceptance Criteria**:
- [ ] All 4 commands check for CRITICAL errors in Stage 3
- [ ] CRITICAL errors fail command with brief message
- [ ] NON-CRITICAL errors display brief warning
- [ ] User feedback is minimal (single line)
- [ ] Error details available via /errors command

**Validation**:
- Read updated command files
- Verify validation step 7 added to Stage 3
- Verify user feedback is minimal

---

### Phase 5: Test Integrated Solution (Preflight + Postflight) [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Validate that task 321 fixes work for postflight scenarios and new fixes work correctly.

**Tasks**:

**5.1: Test Normal Workflow (Task 321 Integration)**

Test that task 321 fixes work for postflight:

1. Run /research on test task:
   - Verify preflight updates status to [RESEARCHING] (task 321)
   - Verify artifact created
   - Verify postflight updates status to [RESEARCHED] (task 321)
   - Verify artifact linked in TODO.md (task 321)
   - Verify state.json synchronized (task 321)
   - Verify git commit created (if git works)
   - Verify brief user feedback

2. Run /plan on test task (same pattern)
3. Run /implement on test task (same pattern)

**5.2: Test Bug #5 Fix (Retry Logic)**

Simulate transient write failure:

1. Temporarily make .opencode/specs directory read-only
2. Run /research on test task
3. Verify retry logic activates (check logs for "retrying...")
4. Restore write permissions
5. Verify write succeeds on retry
6. Verify workflow completes successfully

**5.3: Test Bug #6 Fix (Artifact Validation Retry)**

Simulate artifact timing issue:

1. Modify researcher to delay artifact creation by 2 seconds
2. Run /research on test task
3. Verify artifact validation retry activates (check logs for "retrying after 1s...")
4. Verify validation succeeds on retry
5. Verify workflow completes successfully

**5.4: Test CRITICAL Error Surfacing**

Simulate CRITICAL error:

1. Manually break status-sync-manager (simulate failure)
2. Run /research on test task
3. Verify subagent logs CRITICAL error
4. Verify subagent returns status="failed"
5. Verify command surfaces error with brief message
6. Verify user sees: "Task {number}: Postflight failed - {message}. Run /errors for details."

**5.5: Test NON-CRITICAL Error Handling**

Simulate NON-CRITICAL error:

1. Manually break git-workflow-manager (simulate failure)
2. Run /research on test task
3. Verify subagent logs NON-CRITICAL error
4. Verify subagent returns status="completed"
5. Verify command displays brief warning
6. Verify user sees: "Task {number}: {artifact} created. Warning: git_commit_failed (non-critical)."

**5.6: Regression Testing**

Verify no regressions:

1. Run /plan, /revise, /implement on test tasks
2. Verify all workflows still work
3. Verify no verbose output
4. Verify user feedback is minimal

**Acceptance Criteria**:
- [ ] Task 321 fixes work for postflight scenarios
- [ ] Retry logic works for transient failures
- [ ] Artifact validation retry works for timing issues
- [ ] CRITICAL errors surfaced to users with brief message
- [ ] NON-CRITICAL errors logged but workflow continues
- [ ] No regressions in existing functionality
- [ ] User feedback is minimal

**Validation**:
- Review test results
- Verify all test cases pass
- Document any issues found

---

## Testing and Validation

### Unit Testing

**Test 1: Retry Logic (Bug #5)**
- Simulate transient write failure
- Verify retry with exponential backoff (2s, 4s)
- Expected: Write succeeds on retry

**Test 2: Artifact Validation Retry (Bug #6)**
- Simulate artifact not immediately available
- Verify retry after 1 second
- Expected: Validation succeeds on retry

**Test 3: CRITICAL Error Surfacing**
- Simulate status-sync-manager failure
- Verify command surfaces error to user
- Expected: Brief message with /errors reference

**Test 4: NON-CRITICAL Error Handling**
- Simulate git-workflow-manager failure
- Verify workflow continues
- Expected: Brief warning, workflow completes

### Integration Testing

**Test 5: Normal Workflow (Task 321 Integration)**
- Run /research on test task
- Verify all updates succeed (preflight + postflight)
- Expected: Artifact created, status updated, artifact linked, git commit created

**Test 6: Concurrent Agents (Task 321 Feature)**
- Run two commands on different tasks simultaneously
- Verify no corruption (atomic writes protect)
- Expected: Both commands succeed

**Test 7: Git-Only Rollback (Task 321 Feature)**
- Simulate write failure
- Verify git-based recovery instructions
- Expected: User can recover with git checkout

### Regression Testing

**Test 8: All Commands Updated**
- Run /plan, /revise, /implement on test tasks
- Verify consistent behavior
- Expected: All commands work correctly

---

## Artifacts and Outputs

### Modified Files

1. `.opencode/agent/subagents/status-sync-manager.md`
   - Add Bug #5 fix (retry logic with exponential backoff)
   - Add Bug #6 fix (artifact validation retry)

2. `.opencode/context/system/status-markers.md`
   - Add two-level error logging standard
   - Add error format specification
   - Add error handling protocol

3. `.opencode/command/research.md`
   - Add CRITICAL error validation in Stage 3

4. `.opencode/command/plan.md`
   - Add CRITICAL error validation in Stage 3

5. `.opencode/command/revise.md`
   - Add CRITICAL error validation in Stage 3

6. `.opencode/command/implement.md`
   - Add CRITICAL error validation in Stage 3

### New Files

None (all files already exist from task 321)

---

## Rollback/Contingency

### Rollback Plan

If implementation causes regressions:

1. **Git-Based Rollback**:
   - Use git to revert specific file changes
   - Test reverted version
   - Verify regression resolved

2. **Partial Rollback**:
   - Keep error logging standard (no harm)
   - Revert retry logic if it causes issues
   - Revert command validation if it causes false positives

### Contingency Plan

If retry logic causes issues:

1. **Reduce Retry Count**:
   - Change from 3 attempts to 2 attempts
   - Reduce backoff delay
   - Document retry behavior

If artifact validation retry causes issues:

1. **Increase Retry Delay**:
   - Change from 1 second to 2 seconds
   - Add second retry attempt
   - Document timing requirements

---

## Success Metrics

### Quantitative Metrics

1. **Retry Success Rate**: 90%+ (transient failures recovered)
2. **Artifact Validation Success Rate**: 95%+ (timing issues resolved)
3. **CRITICAL Error Surfacing Rate**: 100% (all CRITICAL failures visible)
4. **Regression Rate**: 0% (no existing functionality broken)

### Qualitative Metrics

1. **User Awareness**: Users see CRITICAL failures immediately
2. **User Feedback**: Minimal output (task number, artifact, brief message)
3. **Workflow Robustness**: Commands handle transient failures gracefully
4. **Integration Quality**: Task 321 fixes work seamlessly for postflight

### Acceptance Criteria

- [ ] Bug #5 fixed (retry logic works)
- [ ] Bug #6 fixed (artifact validation retry works)
- [ ] Two-level error logging formalized
- [ ] CRITICAL errors surfaced to users
- [ ] Task 321 integration validated
- [ ] No regressions in existing functionality

---

## Phase Status Summary

| Phase | Status | Estimated Effort | Actual Effort |
|-------|--------|------------------|---------------|
| Phase 1: Add Bug #5 Fix (Retry Logic) | [NOT STARTED] | 0.5 hours | - |
| Phase 2: Add Bug #6 Fix (Artifact Validation Retry) | [NOT STARTED] | 0.5 hours | - |
| Phase 3: Formalize Two-Level Error Logging | [NOT STARTED] | 0.5 hours | - |
| Phase 4: Add Command-Level Validation | [NOT STARTED] | 0.5 hours | - |
| Phase 5: Test Integrated Solution | [NOT STARTED] | 0.5 hours | - |
| **Total** | **[NOT STARTED]** | **2.5 hours** | **-** |

---

## Notes

### Task 321 Accomplishments (Foundation for This Plan)

Task 321 (completed 2026-01-05) already fixed:
1. ✅ Bug #7 (Missing Post-Commit Verification) - Added content verification
2. ✅ Bug #3 (Silent Validation Failures) - Made validation failures explicit
3. ✅ Bug #2 (Race Condition) - Implemented atomic write pattern
4. ✅ Enhanced all 6 subagents with preflight/postflight verification checkpoints
5. ✅ Created status-markers.md convention file
6. ✅ Implemented atomic writes (write to temp, rename)
7. ✅ Removed backup files (git-only rollback)

**Files Modified by Task 321**:
- `.opencode/agent/subagents/status-sync-manager.md` (bugs #7, #3, #2 fixed)
- `.opencode/agent/subagents/researcher.md` (preflight + postflight enhanced)
- `.opencode/agent/subagents/planner.md` (preflight + verification checkpoint)
- `.opencode/agent/subagents/implementer.md` (preflight + verification checkpoint)
- `.opencode/agent/subagents/lean-research-agent.md` (preflight enhanced)
- `.opencode/agent/subagents/lean-planner.md` (preflight enhanced)
- `.opencode/agent/subagents/lean-implementation-agent.md` (preflight enhanced)
- `.opencode/context/system/status-markers.md` (created new)

### Remaining Work Summary

This plan (v4) focuses ONLY on work NOT covered by task 321:

**Remaining Bugs** (MEDIUM severity):
1. Bug #5 (No Retry Logic) - Transient failures cause immediate rollback
2. Bug #6 (Artifact Validation Timing) - Filesystem sync delays cause false failures

**Remaining Enhancements**:
3. Two-Level Error Logging - Formalize CRITICAL vs NON-CRITICAL standard
4. Command-Level Validation - Surface CRITICAL errors to users
5. Testing - Validate integrated solution (preflight + postflight)

**Total Effort**: 2.5 hours (down from 7.5 hours in plan v3)

### User Requirements Summary

User clarified:
1. **MOST IMPORTANT**: Fix missing artifact links and status updates (CRITICAL) - ✅ DONE by task 321
2. **Git failures**: Passing failures, just log in errors.json
3. **User feedback**: Very minimal
4. **Validation**: Minimal and well-placed
5. **NO file locking**: Allow concurrent agents - ✅ DONE by task 321
6. **NO backup files**: Git-only rollback - ✅ DONE by task 321
7. **FOCUS on timing**: Rethink preflight/postflight for timing certainty - ✅ DONE by task 321

### Integration Strategy

This plan builds on task 321 foundation:
1. **Leverage Task 321 Fixes**: Use atomic writes, verification checkpoints, status-markers.md
2. **Add Missing Pieces**: Retry logic, artifact validation retry, error logging standard
3. **Validate Integration**: Test that task 321 fixes work for postflight scenarios
4. **Minimal Changes**: Only 6 files modified (vs 8 files in task 321)

---

**Plan Created**: 2026-01-05  
**Plan Version**: 4  
**Estimated Total Effort**: 2.5 hours  
**Complexity**: Low-Medium  
**Research Integrated**: Yes (research-001.md, research-002.md, research-003.md)  
**Revision Reason**: Task 321 (completed 2026-01-05) already fixed bugs #7, #3, #2, enhanced all 6 subagents, created status-markers.md, and implemented atomic writes. Plan v4 focuses ONLY on remaining work (bugs #5, #6, error logging, command validation, testing).
