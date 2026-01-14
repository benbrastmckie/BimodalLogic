# Implementation Plan: Fix Systematic Postflight Failures in Workflow Commands (v3 - Timing-Focused)

**Task**: 320 - Fix workflow command postflight failures causing missing artifact links and status updates  
**Status**: [PLANNED]  
**Estimated Effort**: 7 hours  
**Complexity**: Medium-High  
**Language**: meta  
**Priority**: High  
**Created**: 2026-01-05  
**Plan Version**: 3  
**Revision Reason**: Integrated research-002.md findings on status-sync-manager bugs. User requirements: NO file locking (allow concurrent agents), NO backup files (git-only rollback), FOCUS on timing issues. Rethought preflight/postflight process for timing certainty.

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
  - `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-001.md` (integrated 2026-01-05)
  - `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-002.md` (integrated 2026-01-05)

---

## Overview

### Problem Statement (Revised with Research-002 Findings)

Workflow commands (/research, /plan, /revise, /implement) exhibit systematic postflight failures where:

**MOST IMPORTANT (CRITICAL)**:
1. Artifacts are NOT LINKED in TODO.md and state.json
2. Task status is NOT UPDATED in TODO.md and state.json

**Root Cause (Updated)**:
Research-002.md reveals **3 critical bugs in status-sync-manager** that cause these failures:
- **Bug #7 (Missing Post-Commit Verification)**: Files written but content not verified → status/artifact updates may fail silently
- **Bug #3 (Silent Validation Failures)**: Validation failures don't abort → invalid updates proceed
- **Bug #2 (Race Condition)**: TODO.md and state.json written sequentially → process crash causes inconsistent state

### User Requirements (Clarified)

1. **MOST IMPORTANT**: Fix missing artifact links and status updates (CRITICAL)
2. **Git failures**: Passing failures of little concern (NON-CRITICAL)
3. **User feedback**: Very minimal - task number, artifact, work summary, failures
4. **Validation**: Minimal and well-placed
5. **NO file locking**: Allow many agents to work on tasks concurrently
6. **NO backup files**: Rely on git exclusively for rollback
7. **FOCUS on timing**: Rethink preflight/postflight process for timing certainty

### Research Integration

**Research-001.md** identified silent git failures as root cause, but user clarified status/artifact failures are MORE important.

**Research-002.md** identified 7 bugs in status-sync-manager:
1. Bug #1: No file locking (CRITICAL) - **User accepts this risk, wants concurrent agents**
2. Bug #2: Race condition between writes (CRITICAL) - **Must fix with atomic writes**
3. Bug #3: Silent validation failures (CRITICAL) - **Must fix with explicit aborts**
4. Bug #4: Incomplete rollback (HIGH) - **User wants git-only rollback, remove backup files**
5. Bug #5: No retry logic (MEDIUM) - **Add for transient failures**
6. Bug #6: Artifact validation timing (MEDIUM) - **Add retry for timing issues**
7. Bug #7: Missing post-commit verification (CRITICAL) - **Must fix with content verification**

### Scope

**In Scope**:
1. Fix Bug #7 (Missing Post-Commit Verification) - Add content verification
2. Fix Bug #3 (Silent Validation Failures) - Make validation failures explicit
3. Fix Bug #2 (Race Condition) - Use atomic write pattern (write to temp, rename)
4. Fix Bug #5 (No Retry Logic) - Add retry with exponential backoff
5. Fix Bug #6 (Artifact Validation Timing) - Add artifact validation retry
6. Remove backup file mechanism - Use git-only rollback
7. Add verification checkpoint in subagent postflight
8. Implement two-level error logging (CRITICAL vs NON-CRITICAL)
9. Add minimal command-level validation
10. Create shared context file with task 321

**Out of Scope**:
- Bug #1 (No file locking) - User accepts concurrent agent risk
- Bug #4 (Incomplete rollback) - Replaced with git-only rollback
- Making git commits critical (user confirmed these are passing failures)
- Adding multiple verification checkpoints (user wants minimal validation)
- Verbose user feedback (user wants very minimal output)

### Constraints

1. **NO File Locking**: Allow concurrent agents, accept race condition risk
2. **NO Backup Files**: Use git exclusively for rollback
3. **Timing Certainty**: Rethink preflight/postflight for deterministic timing
4. **Minimal Validation**: Single checkpoint, check everything at once
5. **Two-Level Error Logging**: CRITICAL (status/artifacts) vs NON-CRITICAL (git)
6. **Brief User Feedback**: Task number, artifact, single sentence, failures

### Definition of Done

- [ ] Bug #7 fixed (post-commit content verification added)
- [ ] Bug #3 fixed (validation failures explicit with exit 1)
- [ ] Bug #2 fixed (atomic write pattern implemented)
- [ ] Bug #5 fixed (retry logic with exponential backoff)
- [ ] Bug #6 fixed (artifact validation retry)
- [ ] Backup file mechanism removed (git-only rollback)
- [ ] Verification checkpoint added to subagent postflight
- [ ] Two-level error logging implemented
- [ ] Command-level validation surfaces CRITICAL failures
- [ ] Shared context file created with task 321
- [ ] All 4 workflow commands updated
- [ ] All 3 subagents updated
- [ ] Git commit created for changes
- [ ] No regression in existing functionality

---

## Goals and Non-Goals

### Goals

1. **Fix CRITICAL Bugs**: Ensure status updates and artifact linking work reliably
2. **Timing Certainty**: Eliminate race conditions through atomic writes
3. **Concurrent Agents**: Support many agents working simultaneously (no file locking)
4. **Git-Only Rollback**: Remove backup files, rely on git exclusively
5. **Minimal Validation**: Single checkpoint, check everything at once
6. **Brief User Feedback**: Task number, artifact, work summary, failures

### Non-Goals

1. **File Locking**: User wants concurrent agents, accepts race condition risk
2. **Backup Files**: User wants git-only rollback
3. **Make Git Commits Critical**: User confirmed these are passing failures
4. **Add Multiple Checkpoints**: User wants minimal, well-placed validation
5. **Verbose User Feedback**: User wants very minimal output

---

## Risks and Mitigations

### Risk 1: Concurrent Agents May Cause Race Conditions (ACCEPTED)

**Risk**: Without file locking, two concurrent agents can corrupt TODO.md or state.json.

**Likelihood**: MEDIUM  
**Impact**: HIGH

**Mitigation**:
1. **User accepts this risk** - wants concurrent agents
2. Use atomic write pattern (write to temp, rename) to reduce race window
3. Add post-commit verification to detect corruption
4. Document race condition risk in shared context file
5. Recommend users avoid running concurrent commands on same task

**Note**: This is an **accepted risk** per user requirements.

### Risk 2: Git-Only Rollback May Not Work for All Failures

**Risk**: If git is unavailable or corrupted, rollback impossible.

**Likelihood**: VERY LOW  
**Impact**: HIGH

**Mitigation**:
1. Verify git is available before starting operations
2. Check git status before operations (ensure clean working tree)
3. Document git requirements in shared context file
4. Add git availability check to status-sync-manager

### Risk 3: Atomic Write Pattern May Not Work on All Filesystems

**Risk**: `mv` (rename) may not be atomic on all filesystems (e.g., NFS).

**Likelihood**: LOW  
**Impact**: MEDIUM

**Mitigation**:
1. Document filesystem requirements (local filesystem recommended)
2. Test on target filesystem
3. Add filesystem check to status-sync-manager (optional)

---

## Implementation Phases

### Phase 1: Fix status-sync-manager Critical Bugs [NOT STARTED]

**Estimated Effort**: 3 hours

**Objective**: Fix bugs #2, #3, #5, #6, #7 in status-sync-manager to ensure reliable updates.

**Tasks**:

**1.1: Fix Bug #7 (Missing Post-Commit Verification)**

Add content verification in step_5_return to verify status and artifact updates:

```xml
<step_5_return>
  <action>Post-commit validation and return</action>
  <process>
    1. Post-commit content verification:
       a. Verify status marker updated in TODO.md:
          - Extract expected status from new_status parameter
          - Convert to TODO.md format (e.g., "researched" → "RESEARCHED")
          - Check: grep -q "**Status**: \[$expected_status\]" .opencode/specs/TODO.md
          - If not found: Return CRITICAL error "Status marker not updated in TODO.md"
       
       b. Verify status updated in state.json:
          - Extract task status from state.json using jq
          - Check: status=$(jq -r --arg num "$task_number" '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' .opencode/specs/state.json)
          - If status != new_status: Return CRITICAL error "Status not updated in state.json"
       
       c. Verify artifact links added (if validated_artifacts provided):
          - For each artifact in validated_artifacts:
            * Check: grep -q "$artifact_path" .opencode/specs/TODO.md
            * If not found: Return CRITICAL error "Artifact link not added to TODO.md"
       
       d. If any verification fails:
          - Log CRITICAL error with details
          - Return status="failed" with error array
          - Include recommendation: "Run git diff to see what was written"
    
    2. Post-commit file validation (existing):
       - Verify files exist and size > 0
    
    3. Format return following subagent-return-format.md
  </process>
</step_5_return>
```

**1.2: Fix Bug #3 (Silent Validation Failures)**

Make validation failures explicit with exit 1:

```xml
<step_2_validate>
  <action>Validate status transition and artifacts</action>
  <process>
    1. Pre-commit validation (existing)
    
    2. Make validation failures explicit:
       a. If any file missing or unreadable:
          - echo '{"status":"failed","summary":"Pre-commit validation failed: file not found","errors":[...]}'
          - exit 1
       
       b. If status transition invalid:
          - echo '{"status":"failed","summary":"Invalid status transition","errors":[...]}'
          - exit 1
       
       c. If artifact validation fails:
          - echo '{"status":"failed","summary":"Artifact validation failed","errors":[...]}'
          - exit 1
       
       d. If plan file malformed:
          - echo '{"status":"failed","summary":"Plan file validation failed","errors":[...]}'
          - exit 1
    
    3. All validation failures MUST exit 1 (do not continue to commit)
  </process>
</step_2_validate>
```

**1.3: Fix Bug #2 (Race Condition) - Atomic Write Pattern**

Replace sequential writes with atomic write pattern:

```xml
<step_4_commit>
  <action>Phase 2: Commit all updates atomically</action>
  <process>
    1. Write to temporary files:
       - write_file ".opencode/specs/TODO.md.tmp" "$updated_todo"
       - write_file ".opencode/specs/state.json.tmp" "$updated_state"
       - If plan_path: write_file "$plan_path.tmp" "$updated_plan"
    
    2. Verify temp files written successfully:
       - Check each temp file exists and size > 0
       - If any write failed: Remove all temp files, return failed
    
    3. Atomic rename (all files or none):
       - mv ".opencode/specs/TODO.md.tmp" ".opencode/specs/TODO.md" && \
         mv ".opencode/specs/state.json.tmp" ".opencode/specs/state.json" && \
         ([ -z "$plan_path" ] || mv "$plan_path.tmp" "$plan_path") || \
         { rm -f ".opencode/specs/TODO.md.tmp" ".opencode/specs/state.json.tmp" "$plan_path.tmp"; exit 1; }
    
    4. If rename fails:
       - Remove all temp files
       - Return status="failed" with error details
       - Recommend: "Run git status to check for partial updates"
  </process>
  <rollback_on_failure>
    If atomic rename fails:
    1. Remove all temp files (cleanup)
    2. Original files unchanged (no rollback needed)
    3. Return failed status with error details
    4. Recommend git-based recovery if needed
  </rollback_on_failure>
</step_4_commit>
```

**1.4: Fix Bug #5 (No Retry Logic)**

Add retry with exponential backoff for transient failures:

```xml
<step_4_commit>
  <retry_logic>
    For each file write operation:
    1. Attempt write up to 3 times
    2. If write fails:
       - If attempt < 3: sleep $((attempt * 2)) seconds (exponential backoff)
       - If attempt == 3: Return failed status
    3. If write succeeds: Continue to next file
    
    Example:
    for attempt in 1 2 3; do
      if write_file ".opencode/specs/TODO.md.tmp" "$updated_todo"; then
        break
      fi
      if [ $attempt -lt 3 ]; then
        sleep $((attempt * 2))
      else
        echo "Write failed after 3 attempts"
        return_failed_status
        exit 1
      fi
    done
  </retry_logic>
</step_4_commit>
```

**1.5: Fix Bug #6 (Artifact Validation Timing)**

Add artifact validation retry for timing issues:

```xml
<step_2_validate>
  <artifact_validation_retry>
    For each artifact in validated_artifacts:
    1. Check if file exists: [ -f "$artifact_path" ]
    2. If not found:
       - Sleep 1 second (allow filesystem sync)
       - Check again: [ -f "$artifact_path" ]
       - If still not found: Return validation failed
    3. Check if file non-empty: [ -s "$artifact_path" ]
    4. If validation passes: Continue to next artifact
  </artifact_validation_retry>
</step_2_validate>
```

**1.6: Remove Backup File Mechanism**

Replace backup files with git-only rollback:

```xml
<step_1_prepare>
  <action>Phase 1: Prepare all updates in memory</action>
  <process>
    1. Read files into memory (existing)
    2. REMOVE: Create backups of original content
    3. ADD: Verify git is available and working tree is clean:
       - Check: git status --porcelain
       - If dirty: Log warning "Working tree has uncommitted changes"
       - If git unavailable: Return error "Git required for rollback"
  </process>
</step_1_prepare>

<rollback_on_failure>
  If any write fails:
  1. Remove temp files (cleanup)
  2. Original files unchanged (atomic rename failed)
  3. If files were partially updated:
     - Recommend: git checkout .opencode/specs/TODO.md .opencode/specs/state.json
     - Recommend: git status to verify recovery
  4. Return failed status with git recovery instructions
</rollback_on_failure>
```

**Acceptance Criteria**:
- [ ] Bug #7 fixed: Post-commit content verification added
- [ ] Bug #3 fixed: Validation failures explicit with exit 1
- [ ] Bug #2 fixed: Atomic write pattern implemented
- [ ] Bug #5 fixed: Retry logic with exponential backoff
- [ ] Bug #6 fixed: Artifact validation retry
- [ ] Backup file mechanism removed
- [ ] Git-only rollback documented

**Validation**:
- Read updated status-sync-manager.md
- Verify all bugs fixed
- Verify backup files removed
- Verify git-only rollback

---

### Phase 2: Add Verification Checkpoint to Subagent Postflight [NOT STARTED]

**Estimated Effort**: 2 hours

**Objective**: Add single verification checkpoint in subagent postflight after status-sync-manager succeeds.

**Tasks**:

**2.1: Update researcher.md step_4_postflight**

Add verification checkpoint after status-sync-manager:

```xml
<step_4_postflight>
  <action>Postflight: Update status to [RESEARCHED], link report, create git commit</action>
  <process>
    1. Generate completion timestamp
    2. Invoke status-sync-manager (existing)
    3. Validate status-sync-manager return (existing)
    
    4. VERIFICATION CHECKPOINT (NEW):
       a. Verify status updated in state.json:
          - status=$(jq -r --arg num "$task_number" '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' .opencode/specs/state.json)
          - If status != "researched": Log CRITICAL error, return failed
       
       b. Verify status updated in TODO.md:
          - status=$(grep -A 5 "^### $task_number\." .opencode/specs/TODO.md | grep -oP '\*\*Status\*\*: \[\K[^\]]+')
          - If status != "RESEARCHED": Log CRITICAL error, return failed
       
       c. Verify artifact linked in TODO.md:
          - If ! grep -q "$research_report_path" .opencode/specs/TODO.md; then
              Log CRITICAL error "Artifact not linked in TODO.md"
              return failed
            fi
       
       d. If any verification fails:
          - Log CRITICAL error with details
          - Return status="failed" with error array
          - Include recommendation: "Run /errors for details"
    
    5. Invoke git-workflow-manager (existing)
    6. Log postflight completion
  </process>
</step_4_postflight>
```

**2.2: Update planner.md step_7**

Add same verification checkpoint pattern:

```xml
<step_7>
  <action>Execute Stage 7 (Postflight) - Update status and create git commit</action>
  <process>
    1. Invoke status-sync-manager (existing)
    2. Validate status-sync-manager return (existing)
    
    3. VERIFICATION CHECKPOINT (NEW):
       - Verify status updated in state.json (check for "planned")
       - Verify status updated in TODO.md (check for "PLANNED")
       - Verify plan link added to TODO.md
       - If any verification fails: Return CRITICAL error
    
    4. Invoke git-workflow-manager (existing)
  </process>
</step_7>
```

**2.3: Update implementer.md postflight**

Add same verification checkpoint pattern.

**Acceptance Criteria**:
- [ ] Verification checkpoint added to all 3 subagents
- [ ] Checkpoint verifies status in state.json AND TODO.md
- [ ] Checkpoint verifies artifact linked in TODO.md
- [ ] CRITICAL error logged if verification fails
- [ ] Checkpoint is AFTER status-sync-manager, BEFORE git-workflow-manager

**Validation**:
- Read updated subagent files
- Verify checkpoint uses jq and grep
- Verify checkpoint is single block (not scattered)

---

### Phase 3: Implement Two-Level Error Logging [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Implement two-level error logging with CRITICAL vs NON-CRITICAL distinction.

**Tasks**:

**3.1: Define Error Logging Standard**

Create error format for both levels:

```json
{
  "CRITICAL": {
    "type": "verification_failed" | "status_sync_failed" | "artifact_link_failed",
    "message": "Detailed error message",
    "code": "VERIFICATION_FAILED",
    "severity": "CRITICAL",
    "recoverable": false,
    "recommendation": "Manual recovery steps or retry command"
  },
  "NON-CRITICAL": {
    "type": "git_commit_failed",
    "message": "Git commit failed: {error_details}",
    "code": "GIT_COMMIT_FAILED",
    "severity": "NON-CRITICAL",
    "recoverable": true,
    "recommendation": "Manually create git commit: git add . && git commit -m '...'"
  }
}
```

**3.2: Update Subagent Error Logging**

Update all 3 subagents to use two-level format:
- CRITICAL errors: Verification failures, status-sync-manager failures
- NON-CRITICAL errors: Git commit failures

**Acceptance Criteria**:
- [ ] Error logging standard documented
- [ ] CRITICAL errors have severity="CRITICAL", recoverable=false
- [ ] NON-CRITICAL errors have severity="NON-CRITICAL", recoverable=true
- [ ] All subagents use consistent error format

**Validation**:
- Review error logging code
- Verify error format matches standard

---

### Phase 4: Add Minimal Command-Level Validation [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Add minimal validation to workflow commands to surface CRITICAL failures only.

**Tasks**:

**4.1: Update Command Stage 3 (ValidateReturn)**

Add CRITICAL error check:

```xml
<stage id="3" name="ValidateReturn">
  <action>Validate subagent return format and artifacts</action>
  <process>
    1-6. Existing validation steps
    
    7. VALIDATION STEP 7: Check for CRITICAL errors (NEW)
       - Extract errors array from subagent return
       - Check for errors with severity="CRITICAL"
       - If CRITICAL error found:
         * Display brief message: "Task {number}: Postflight failed. Run /errors for details."
         * Exit with error
       - If no CRITICAL errors:
         * Check for NON-CRITICAL errors (git failures)
         * If found: Display brief message: "Task {number}: {artifact} created. Git commit failed."
         * Continue (don't fail command)
  </process>
</stage>
```

**4.2: Update All 4 Commands**

Apply same validation to /research, /plan, /revise, /implement.

**Acceptance Criteria**:
- [ ] All 4 commands check for CRITICAL errors
- [ ] CRITICAL errors fail command with brief message
- [ ] NON-CRITICAL errors display brief warning
- [ ] User feedback is minimal

**Validation**:
- Read updated command files
- Verify validation is minimal (single check)

---

### Phase 5: Create Shared Postflight/Preflight Standards File [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Create shared context file with task 321 for consistent standards.

**Tasks**:

**5.1: Create Shared Standards File**

File: `.opencode/context/core/standards/postflight-preflight.md`

Content:
- Postflight verification requirements (status updated, artifact linked)
- Preflight verification requirements (status updated to in-progress)
- Two-level error logging standard
- Error format specification
- Verification checkpoint pattern
- User feedback format
- Timing considerations (atomic writes, retry logic)
- Git-only rollback strategy
- Concurrent agent considerations (no file locking)

**Acceptance Criteria**:
- [ ] Shared context file created
- [ ] Two-level error logging standard documented
- [ ] Verification checkpoint pattern documented
- [ ] Timing considerations documented
- [ ] Git-only rollback documented
- [ ] Concurrent agent considerations documented

**Validation**:
- Read created file
- Verify all standards documented

---

### Phase 6: Testing and Validation [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Test all changes and validate no regressions.

**Tasks**:

**6.1: Test Verification Checkpoint**

- Manually break status-sync-manager (simulate failure)
- Verify subagent logs CRITICAL error
- Verify subagent returns status="failed"
- Verify command fails with brief message

**6.2: Test Git Failure Handling**

- Manually break git-workflow-manager (simulate failure)
- Verify subagent logs NON-CRITICAL error
- Verify subagent returns status="completed"
- Verify command displays brief warning

**6.3: Test Normal Workflow**

- Run /research on test task
- Verify artifact created
- Verify status updated in state.json AND TODO.md
- Verify artifact linked in TODO.md
- Verify git commit created (if git works)
- Verify brief user feedback

**6.4: Test Atomic Write Pattern**

- Simulate process crash during write
- Verify original files unchanged (atomic rename failed)
- Verify temp files cleaned up
- Verify git-based recovery works

**6.5: Regression Testing**

- Run /plan, /revise, /implement on test tasks
- Verify all workflows still work
- Verify no verbose output

**Acceptance Criteria**:
- [ ] Verification checkpoint catches status-sync-manager failures
- [ ] Git failures logged as NON-CRITICAL
- [ ] Commands surface CRITICAL failures with brief message
- [ ] Atomic write pattern works correctly
- [ ] Git-only rollback works
- [ ] Normal workflow still works
- [ ] User feedback is minimal
- [ ] No regressions

**Validation**:
- Review test results
- Verify all test cases pass

---

## Testing and Validation

### Unit Testing

**Test 1: Post-Commit Content Verification**
- Simulate status-sync-manager writing files but not updating content
- Verify post-commit verification catches failure
- Expected: CRITICAL error "Status marker not updated in TODO.md"

**Test 2: Silent Validation Failures**
- Simulate artifact validation failure
- Verify validation aborts with exit 1
- Expected: status="failed" with error details

**Test 3: Atomic Write Pattern**
- Simulate process crash during write
- Verify original files unchanged
- Expected: Temp files cleaned up, original files intact

**Test 4: Retry Logic**
- Simulate transient write failure
- Verify retry with exponential backoff
- Expected: Write succeeds on retry

**Test 5: Artifact Validation Retry**
- Simulate artifact not immediately available
- Verify retry after 1 second
- Expected: Validation succeeds on retry

### Integration Testing

**Test 6: Normal Workflow**
- Run /research on test task
- Verify all updates succeed
- Expected: Artifact created, status updated, artifact linked, git commit created

**Test 7: Concurrent Agents (Accepted Risk)**
- Run two commands on different tasks simultaneously
- Verify no corruption (atomic writes protect)
- Expected: Both commands succeed (or one fails gracefully)

**Test 8: Git-Only Rollback**
- Simulate write failure
- Verify git-based recovery instructions
- Expected: User can recover with git checkout

### Regression Testing

**Test 9: All Commands Updated**
- Run /plan, /revise, /implement on test tasks
- Verify consistent behavior
- Expected: All commands work correctly

---

## Artifacts and Outputs

### Modified Files

1. `.opencode/agent/subagents/status-sync-manager.md`
   - Fix bugs #2, #3, #5, #6, #7
   - Remove backup file mechanism
   - Add git-only rollback

2. `.opencode/agent/subagents/researcher.md`
   - Add verification checkpoint in step_4_postflight
   - Add two-level error logging

3. `.opencode/agent/subagents/planner.md`
   - Add verification checkpoint in step_7
   - Add two-level error logging

4. `.opencode/agent/subagents/implementer.md`
   - Add verification checkpoint in postflight
   - Add two-level error logging

5. `.opencode/command/research.md`
   - Add CRITICAL error validation in stage 3

6. `.opencode/command/plan.md`
   - Add CRITICAL error validation in stage 3

7. `.opencode/command/revise.md`
   - Add CRITICAL error validation in stage 3

8. `.opencode/command/implement.md`
   - Add CRITICAL error validation in stage 3

### New Files

1. `.opencode/context/core/standards/postflight-preflight.md`
   - Shared context file with task 321
   - Two-level error logging standard
   - Verification checkpoint pattern
   - Timing considerations
   - Git-only rollback strategy
   - Concurrent agent considerations

---

## Rollback/Contingency

### Rollback Plan

If implementation causes regressions:

1. **Git-Based Rollback**:
   - Use git to revert specific file changes
   - Test reverted version
   - Verify regression resolved

2. **Partial Rollback**:
   - Keep shared context file (no harm)
   - Revert status-sync-manager changes if they cause issues
   - Revert subagent changes if they cause false positives

### Contingency Plan

If atomic write pattern causes issues:

1. **Fallback to Sequential Writes**:
   - Document that atomic writes not supported on filesystem
   - Recommend local filesystem
   - Accept race condition risk

If git-only rollback insufficient:

1. **Add Minimal Backup**:
   - Create single backup file before operations
   - Use for emergency recovery only
   - Document as last resort

---

## Success Metrics

### Quantitative Metrics

1. **Status Update Success Rate**: 100% (up from ~0% for failing cases)
2. **Artifact Linking Success Rate**: 100% (up from ~0% for failing cases)
3. **CRITICAL Error Surfacing Rate**: 100% (all CRITICAL failures visible)
4. **Atomic Write Success Rate**: 100% (no partial updates)
5. **Regression Rate**: 0% (no existing functionality broken)

### Qualitative Metrics

1. **User Awareness**: Users see CRITICAL failures immediately
2. **User Feedback**: Minimal output (task number, artifact, work summary, failures)
3. **Workflow Robustness**: Commands handle failures gracefully
4. **Timing Certainty**: Atomic writes eliminate race conditions
5. **Concurrent Agent Support**: Multiple agents can work simultaneously

### Acceptance Criteria

- [ ] All CRITICAL failures surfaced to users
- [ ] User feedback is minimal
- [ ] No regressions in existing functionality
- [ ] Two-level error logging implemented
- [ ] Verification checkpoint added
- [ ] Atomic write pattern works
- [ ] Git-only rollback works
- [ ] Concurrent agents supported (no file locking)

---

## Phase Status Summary

| Phase | Status | Estimated Effort | Actual Effort |
|-------|--------|------------------|---------------|
| Phase 1: Fix status-sync-manager Bugs | [NOT STARTED] | 3 hours | - |
| Phase 2: Verification Checkpoint | [NOT STARTED] | 2 hours | - |
| Phase 3: Two-Level Error Logging | [NOT STARTED] | 1 hour | - |
| Phase 4: Command-Level Validation | [NOT STARTED] | 0.5 hours | - |
| Phase 5: Shared Standards File | [NOT STARTED] | 0.5 hours | - |
| Phase 6: Testing and Validation | [NOT STARTED] | 0.5 hours | - |
| **Total** | **[NOT STARTED]** | **7.5 hours** | **-** |

---

## Notes

### User Requirements Summary

User clarified:
1. **MOST IMPORTANT**: Fix missing artifact links and status updates (CRITICAL)
2. **Git failures**: Passing failures, just log in errors.json
3. **User feedback**: Very minimal
4. **Validation**: Minimal and well-placed
5. **NO file locking**: Allow concurrent agents
6. **NO backup files**: Git-only rollback
7. **FOCUS on timing**: Rethink preflight/postflight for timing certainty

### Research Findings Summary

**Research-002.md** identified 7 bugs in status-sync-manager:
- **Bug #7 (CRITICAL)**: Missing post-commit verification → status/artifact updates fail silently
- **Bug #3 (CRITICAL)**: Silent validation failures → invalid updates proceed
- **Bug #2 (CRITICAL)**: Race condition → inconsistent state
- **Bug #5 (MEDIUM)**: No retry logic → transient failures cause rollback
- **Bug #6 (MEDIUM)**: Artifact validation timing → false failures
- **Bug #1 (CRITICAL)**: No file locking → **User accepts this risk**
- **Bug #4 (HIGH)**: Incomplete rollback → **Replaced with git-only rollback**

### Implementation Strategy

1. **Fix Root Causes**: Fix status-sync-manager bugs #2, #3, #5, #6, #7
2. **Atomic Writes**: Eliminate race conditions through write-to-temp-then-rename
3. **Git-Only Rollback**: Remove backup files, rely on git exclusively
4. **Verification Checkpoint**: Single checkpoint after status-sync-manager
5. **Two-Level Errors**: CRITICAL (status/artifacts) vs NON-CRITICAL (git)
6. **Minimal Validation**: Single check in commands for CRITICAL errors only
7. **Concurrent Agents**: No file locking, accept race condition risk

### Timing Considerations

**Preflight Timing**:
1. Command validates task status
2. Command delegates to subagent
3. Subagent invokes status-sync-manager (preflight)
4. status-sync-manager writes atomically (temp → rename)
5. Subagent verifies status updated (checkpoint)
6. Subagent proceeds with work

**Postflight Timing**:
1. Subagent creates artifact
2. Subagent invokes status-sync-manager (postflight)
3. status-sync-manager validates artifact exists (with retry)
4. status-sync-manager writes atomically (temp → rename)
5. status-sync-manager verifies content updated (post-commit)
6. Subagent verifies status/artifact updated (checkpoint)
7. Subagent invokes git-workflow-manager
8. Subagent returns to command

**Critical Timing Points**:
- Artifact validation: Retry after 1 second if not found (Bug #6)
- File writes: Atomic rename eliminates race window (Bug #2)
- Post-commit verification: Catches silent failures (Bug #7)
- Verification checkpoint: Catches status-sync-manager failures

### Integration with Task 321

Task 321 focuses on preflight failures. This task focuses on postflight failures. Both tasks will:
- Share `.opencode/context/core/standards/postflight-preflight.md` context file
- Use same two-level error logging standard
- Use same verification checkpoint pattern
- Use same atomic write pattern
- Use same git-only rollback strategy
- Support concurrent agents (no file locking)

---

**Plan Created**: 2026-01-05  
**Plan Version**: 3  
**Estimated Total Effort**: 7.5 hours  
**Complexity**: Medium-High  
**Research Integrated**: Yes (research-001.md, research-002.md)  
**Revision Reason**: Integrated research-002.md findings on status-sync-manager bugs. User requirements: NO file locking, NO backup files, FOCUS on timing issues.
