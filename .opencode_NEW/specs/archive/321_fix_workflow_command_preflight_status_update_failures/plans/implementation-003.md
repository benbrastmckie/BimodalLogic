# Implementation Plan: Fix Systematic Preflight Failures in Workflow Commands (Revised v3)

## Metadata

- **Task**: 321 - Fix workflow command preflight status update failures
- **Status**: [NOT STARTED]
- **Estimated Effort**: 4.5 hours
- **Language**: meta
- **Priority**: High
- **Created**: 2026-01-05
- **Plan Version**: 3
- **Previous Version**: implementation-002.md
- **Complexity**: Medium
- **Dependencies**: None
- **Blocking**: None

## Revision Summary

**Changes from Version 2**:
1. **Integrated status-sync-manager Bug Analysis**: Research-002.md from task 320 reveals 7 critical bugs in status-sync-manager that directly cause preflight/postflight failures
2. **Eliminated File Locking**: Per user requirement, removed file locking approach to allow concurrent agent execution
3. **Git-Only Rollback**: Removed backup file rollback mechanism, rely exclusively on git for recovery
4. **Timing-Focused Architecture**: Complete rethink of preflight/postflight timing to ensure deterministic execution order
5. **Reduced Complexity**: Streamlined from 6 phases to 4 phases by focusing on critical bugs only
6. **Priority Reordering**: Fix status-sync-manager bugs FIRST (Phase 1), then add verification (Phase 2)

**Key Insights from Research-002.md**:
- **Bug #7 (Missing Post-Commit Verification)**: status-sync-manager validates file size > 0 but NOT that status marker was actually updated - CRITICAL
- **Bug #3 (Silent Validation Failures)**: Validation failures don't abort operations, allowing invalid updates to proceed - CRITICAL
- **Bug #2 (Race Condition)**: Two-phase commit creates inconsistency window between TODO.md and state.json writes - CRITICAL
- **Timing Issue**: Preflight must complete BEFORE subagent work begins, postflight must complete BEFORE command returns

**User Requirements Incorporated**:
- NO file locking (allow concurrent agents)
- NO backup files for rollback (git-only recovery)
- Careful timing analysis to prevent race conditions
- Focus on making delegation instructions actually execute

## Overview

### Problem Statement

Workflow commands (/research, /plan, /revise, /implement) experience **consistent preflight AND postflight failures** where status-sync-manager delegation instructions in subagent markdown files are **not being executed** by AI agents. Research-002.md reveals this is compounded by **7 critical bugs in status-sync-manager** that allow silent failures even when delegation DOES occur.

**Root Causes** (Dual Problem):
1. **Documentation-vs-Execution Gap**: Subagent markdown instructions to delegate to status-sync-manager are not consistently executed by AI agents
2. **status-sync-manager Silent Failures**: Even when delegation occurs, bugs #3, #7, and #2 allow failures to return status="completed" despite not actually updating files

**Critical Timing Requirements**:
- **Preflight**: MUST complete status update to [RESEARCHING]/[PLANNING]/etc. BEFORE subagent begins work
- **Postflight**: MUST complete status update and artifact linking BEFORE subagent returns to command
- **Verification**: MUST occur AFTER delegation completes but BEFORE proceeding to next step
- **No File Locking**: Multiple agents may run concurrently, so timing must be deterministic without locks

**Evidence of Failures**:
- Task 314: Artifact created, TODO.md updated to [RESEARCHED], but state.json still shows "not_started" (Bug #2 race condition)
- Task 315: /research 315 does not update status to [RESEARCHING] at start (preflight not executed)
- Research-002.md: status-sync-manager has no post-commit content verification (Bug #7)

### Scope

**In Scope**:
- Fix Bug #7 (Missing Post-Commit Verification) in status-sync-manager
- Fix Bug #3 (Silent Validation Failures) in status-sync-manager
- Fix Bug #2 (Race Condition) using atomic write pattern (NO file locking)
- Add explicit preflight/postflight verification in subagents
- Add timing-aware delegation instructions with concrete examples
- Create `.opencode/context/system/status-markers.md` for consistency

**Out of Scope**:
- File locking mechanisms (user requirement: allow concurrent agents)
- Backup file rollback (user requirement: git-only recovery)
- Timeout protection for stale statuses (future work)
- Extensive validation checks (keep surgical only)
- Bugs #1, #4, #5, #6 from research-002.md (lower priority, future work)

### Constraints

**User-Specified Constraints**:
1. NO file locking - must allow concurrent agent execution
2. NO backup files for rollback - rely on git exclusively
3. Timing must be deterministic and carefully analyzed
4. Focus on making delegation actually execute
5. Keep complexity minimal - surgical fixes only
6. Create status-markers.md for single source of truth

**Technical Constraints**:
- Atomic writes must work without file locking (use atomic rename)
- Verification must not introduce race conditions
- Git is the only rollback mechanism
- Multiple agents may update TODO.md/state.json concurrently

### Definition of Done

- [ ] Bug #7 fixed: status-sync-manager verifies status marker actually updated in TODO.md
- [ ] Bug #3 fixed: status-sync-manager validation failures abort with explicit errors
- [ ] Bug #2 fixed: Atomic write pattern eliminates race condition window (no file locking)
- [ ] Preflight delegation instructions enhanced with concrete examples and timing requirements
- [ ] Postflight delegation instructions enhanced with concrete examples and timing requirements
- [ ] Verification checkpoints added to subagents AFTER delegation completes
- [ ] Status marker convention file created at `.opencode/context/system/status-markers.md`
- [ ] All changes tested with at least one workflow command
- [ ] Timing analysis documented showing deterministic execution order
- [ ] No file locking or backup files introduced

### Research Integration

This plan integrates findings from 3 research reports:

**New Reports** (integrated in plan v3):
- **320/research-002.md** (2026-01-05): Analysis of status-sync-manager bugs
  - Key Finding: Bug #7 (Missing Post-Commit Verification) - status-sync-manager only checks file size > 0, not that content was actually updated
  - Key Finding: Bug #3 (Silent Validation Failures) - validation failures don't abort, allowing invalid updates to proceed
  - Key Finding: Bug #2 (Race Condition) - two-phase commit creates inconsistency window between TODO.md and state.json writes
  - Recommendation: Fix bugs #7, #3, #2 immediately (1.5 hours total) before adding verification checkpoints

**Previously Integrated** (from plan v2):
- **321/research-001.md** (2026-01-05): Preflight status update failure analysis
  - Root cause: Documentation-vs-execution gap in subagent markdown instructions
  - Recommendation: Add concrete delegation examples and validation checkpoints
- **320/research-001.md** (2026-01-05): Postflight failure analysis
  - Root cause: Same documentation-vs-execution gap as preflight
  - Recommendation: Unified fix for both preflight and postflight

## Goals and Non-Goals

### Goals

1. **Fix status-sync-manager critical bugs** (#7, #3, #2) that cause silent failures
2. **Eliminate race conditions** using atomic write pattern (NO file locking)
3. **Make delegation instructions executable** with concrete examples and timing requirements
4. **Add verification checkpoints** to catch failures immediately
5. **Ensure deterministic timing** for preflight/postflight execution
6. **Standardize status markers** via `.opencode/context/system/status-markers.md`
7. **Maintain concurrency** - multiple agents can run simultaneously

### Non-Goals

1. Add file locking mechanisms (user requirement: allow concurrency)
2. Implement backup file rollback (user requirement: git-only recovery)
3. Fix all 7 status-sync-manager bugs (focus on critical #7, #3, #2 only)
4. Add timeout protection for stale statuses (future work)
5. Extensive validation throughout workflow (keep surgical only)
6. Redesign entire workflow architecture

## Risks and Mitigations

### Risk 1: Atomic Writes Without Locking May Cause Lost Updates

**Risk**: Two concurrent agents writing TODO.md/state.json simultaneously may cause lost updates

**Likelihood**: Medium (user may run multiple commands in parallel)  
**Impact**: High (state corruption)  
**Mitigation**: 
- Use atomic rename (mv) which is atomic on most filesystems
- Write to temp files with unique names (include PID/session_id)
- Rename atomically: last writer wins (acceptable per user requirement)
- Document that concurrent updates may overwrite each other
- Rely on git for recovery if corruption occurs
- Consider adding optimistic locking in future (compare-and-swap pattern)

### Risk 2: Git-Only Rollback May Not Recover from Partial Failures

**Risk**: If status-sync-manager fails mid-update, git may not have a clean state to revert to

**Likelihood**: Low (atomic writes reduce failure window)  
**Impact**: Medium (manual recovery required)  
**Mitigation**:
- Atomic write pattern minimizes partial failure window
- Document manual recovery procedure (git reset, manual TODO.md/state.json edit)
- Add post-commit verification to detect failures immediately
- Fail fast with clear error messages
- Log all failures for debugging

### Risk 3: Verification Checkpoints May Introduce Timing Issues

**Risk**: Verification after delegation may read stale state if writes haven't flushed

**Likelihood**: Low (filesystem writes are typically synchronous)  
**Impact**: Medium (false failures)  
**Mitigation**:
- Add small delay (100ms) before verification if needed
- Retry verification once on failure
- Document timing assumptions
- Test on target filesystem

### Risk 4: Delegation Instructions Still Not Executed

**Risk**: Even with concrete examples, AI agents may not execute preflight/postflight

**Likelihood**: Medium (current consistent failures suggest systemic issue)  
**Impact**: High (status updates don't occur)  
**Mitigation**:
- Verification checkpoints catch failures immediately (defense in depth)
- Fail fast with clear error messages
- Document manual workaround (run /sync to fix state)
- Consider architectural change in future (move delegation to command layer)

## Implementation Phases

### Phase 1: Fix Critical status-sync-manager Bugs [NOT STARTED]

**Objective**: Fix bugs #7, #3, and #2 in status-sync-manager to eliminate silent failures and race conditions

**Tasks**:

1. **Fix Bug #7 (Missing Post-Commit Verification)**:
   - Location: `.opencode/agent/subagents/status-sync-manager.md` step_5_return
   - Current: Only validates file size > 0
   - Fix: Add content verification after commit
   
   ```bash
   # In step_5_return, after file existence check
   
   # Verify status marker was actually updated in TODO.md
   if ! grep -q "**Status**: \[$expected_status\]" specs/TODO.md; then
     echo '{"status":"failed","summary":"Status marker not updated in TODO.md","errors":[{"type":"verification_failed","message":"File written but status marker not updated","code":"CONTENT_VERIFICATION_FAILED"}]}'
     exit 1
   fi
   
   # Verify status was actually updated in state.json
   actual_status=$(jq -r --arg num "$task_number" \
     '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
     specs/state.json)
   
   if [ "$actual_status" != "$expected_status" ]; then
     echo '{"status":"failed","summary":"Status not updated in state.json","errors":[{"type":"verification_failed","message":"Expected: $expected_status, Actual: $actual_status","code":"STATE_VERIFICATION_FAILED"}]}'
     exit 1
   fi
   
   # Verify artifact link was added (if validated_artifacts provided)
   if [ -n "$artifact_path" ]; then
     if ! grep -q "$artifact_path" specs/TODO.md; then
       echo '{"status":"failed","summary":"Artifact link not added to TODO.md","errors":[{"type":"verification_failed","message":"Artifact: $artifact_path","code":"ARTIFACT_LINK_FAILED"}]}'
       exit 1
     fi
   fi
   ```
   
   **Estimated Effort**: 1 hour

2. **Fix Bug #3 (Silent Validation Failures)**:
   - Location: `.opencode/agent/subagents/status-sync-manager.md` step_2_validate
   - Current: Validation failures may not abort operations
   - Fix: Make all validation failures explicit with exit 1
   
   ```bash
   # In step_2_validate
   
   # Validate status transition
   if [ "$transition_invalid" = "true" ]; then
     echo '{"status":"failed","summary":"Invalid status transition","errors":[{"type":"validation_failed","message":"Cannot transition from $current_status to $new_status","code":"INVALID_TRANSITION"}]}'
     exit 1
   fi
   
   # Validate artifact exists (if provided)
   if [ -n "$artifact_path" ] && [ ! -f "$artifact_path" ]; then
     echo '{"status":"failed","summary":"Artifact validation failed","errors":[{"type":"validation_failed","message":"Artifact not found: $artifact_path","code":"ARTIFACT_NOT_FOUND"}]}'
     exit 1
   fi
   
   # Validate artifact is non-empty (if provided)
   if [ -n "$artifact_path" ] && [ ! -s "$artifact_path" ]; then
     echo '{"status":"failed","summary":"Artifact validation failed","errors":[{"type":"validation_failed","message":"Artifact is empty: $artifact_path","code":"ARTIFACT_EMPTY"}]}'
     exit 1
   fi
   ```
   
   **Estimated Effort**: 0.5 hours

3. **Fix Bug #2 (Race Condition) with Atomic Write Pattern**:
   - Location: `.opencode/agent/subagents/status-sync-manager.md` step_4_commit
   - Current: Two-phase commit (write TODO.md, then state.json) creates inconsistency window
   - Fix: Use atomic write pattern (write to temp, rename atomically)
   - **NO FILE LOCKING** per user requirement
   
   ```bash
   # In step_4_commit
   
   # Generate unique temp file names (include session_id for uniqueness)
   todo_tmp="specs/TODO.md.tmp.${session_id}"
   state_tmp="specs/state.json.tmp.${session_id}"
   
   # Write to temp files
   echo "$updated_todo" > "$todo_tmp"
   echo "$updated_state" > "$state_tmp"
   
   # Verify temp files written successfully
   if [ ! -s "$todo_tmp" ] || [ ! -s "$state_tmp" ]; then
     rm -f "$todo_tmp" "$state_tmp"
     echo '{"status":"failed","summary":"Failed to write temp files","errors":[...]}'
     exit 1
   fi
   
   # Atomic rename (both files or neither)
   # Note: Last writer wins if concurrent updates occur (acceptable per user requirement)
   if mv "$todo_tmp" specs/TODO.md && \
      mv "$state_tmp" specs/state.json; then
     # Success - both files updated atomically
     echo "Files updated successfully"
   else
     # Failure - clean up temp files
     rm -f "$todo_tmp" "$state_tmp"
     echo '{"status":"failed","summary":"Atomic rename failed","errors":[...]}'
     exit 1
   fi
   
   # Note: No rollback to backup files - rely on git for recovery
   ```
   
   **Estimated Effort**: 1 hour

4. **Remove Backup File Rollback Mechanism**:
   - Location: `.opencode/agent/subagents/status-sync-manager.md` step_4_commit
   - Current: Creates .backup files and restores on failure
   - Fix: Remove backup creation and rollback logic
   - Rationale: User requirement to rely on git exclusively for recovery
   
   ```bash
   # REMOVE these lines from step_4_commit:
   # cp specs/TODO.md specs/TODO.md.backup
   # cp specs/state.json specs/state.json.backup
   
   # REMOVE rollback_on_failure function
   
   # On failure: Just exit with error, rely on git for recovery
   ```
   
   **Estimated Effort**: 0.5 hours

**Acceptance Criteria**:
- Bug #7 fixed: Post-commit verification checks status marker in TODO.md, status in state.json, artifact links
- Bug #3 fixed: All validation failures abort with explicit exit 1 and error JSON
- Bug #2 fixed: Atomic write pattern using temp files and atomic rename
- No file locking introduced
- No backup files created
- All changes tested with status-sync-manager invocation
- Verification catches failures that previously returned "completed"

**Estimated Effort**: 3 hours

**Validation**:
- Test status-sync-manager with valid inputs: Returns "completed", files updated correctly
- Test with invalid transition: Returns "failed" with clear error (Bug #3 fix)
- Test with missing artifact: Returns "failed" with clear error (Bug #3 fix)
- Test with file write that doesn't update content: Returns "failed" with clear error (Bug #7 fix)
- Verify atomic write pattern: Both files updated or neither (Bug #2 fix)
- Verify no .backup files created
- Verify no file locking used

---

### Phase 2: Enhance Subagent Delegation Instructions with Timing Requirements [NOT STARTED]

**Objective**: Update preflight/postflight instructions in all 6 subagents to ensure delegation executes with proper timing

**Tasks**:

1. **Create Status Marker Convention File**:
   - Create `.opencode/context/system/status-markers.md`
   - Extract all status marker definitions from state-management.md
   - Document valid transitions
   - Document TODO.md marker format vs state.json value mapping
   - This becomes the single source of truth
   
   **Estimated Effort**: 0.5 hours

2. **Design Timing-Aware Delegation Template**:
   - Create concrete delegation example with timing requirements
   - Specify execution order: delegate → wait → verify → proceed
   - Add explicit timing checkpoints
   
   Template:
   ```xml
   <step_0_preflight>
     <action>Preflight: Update status to [RESEARCHING] BEFORE beginning research</action>
     <process>
       CRITICAL TIMING REQUIREMENT: This step MUST complete BEFORE step_1 begins.
       
       1. Extract task inputs from delegation context
       
       2. Delegate to status-sync-manager (REQUIRED - DO NOT SKIP):
          
          INVOKE status-sync-manager:
            task(
              subagent_type="status-sync-manager",
              prompt="Update task {task_number} status to researching",
              description="Update status to [RESEARCHING]",
              context={
                "operation": "update_status",
                "task_number": {task_number},
                "new_status": "researching",
                "timestamp": "{current_date}",
                "session_id": "{session_id}",
                "delegation_depth": {depth + 1},
                "delegation_path": [...delegation_path, "status-sync-manager"]
              }
            )
          
          WAIT for status-sync-manager to return (timeout: 60s)
          
          VERIFY return:
            - status == "completed" (if "failed", abort with error)
            - files_updated includes ["TODO.md", "state.json"]
          
          IF status != "completed":
            - Log error: "Preflight status update failed: {error_message}"
            - Return status: "failed"
            - DO NOT proceed to step_1
       
       3. Verify status was actually updated (defense in depth):
          
          Read state.json:
            actual_status=$(jq -r --arg num "$task_number" \
              '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
              specs/state.json)
          
          IF actual_status != "researching":
            - Log error: "Preflight verification failed - status not updated"
            - Log: "Expected: researching, Actual: $actual_status"
            - Return status: "failed"
            - DO NOT proceed to step_1
       
       4. Proceed to step_1 (research execution)
     </process>
     <checkpoint>Status updated to [RESEARCHING], verified in state.json, ready to begin research</checkpoint>
   </step_0_preflight>
   ```
   
   **Estimated Effort**: 0.5 hours

3. **Update Preflight in All 6 Subagents**:
   - Apply timing-aware delegation template to:
     - researcher.md (step_0_preflight)
     - planner.md (step_0_preflight)
     - implementer.md (step_0_preflight)
     - lean-research-agent.md (step_0_preflight)
     - lean-planner.md (step_0_preflight)
     - lean-implementation-agent.md (step_0_preflight)
   - Adjust status markers for each subagent type
   - Keep timing requirements consistent
   
   **Estimated Effort**: 1 hour (10 minutes per subagent)

4. **Update Postflight in All 6 Subagents**:
   - Apply same timing-aware pattern to postflight steps
   - Add verification checkpoint after delegation
   - Ensure postflight completes BEFORE step_8_return
   
   **Estimated Effort**: 1 hour (10 minutes per subagent)

**Acceptance Criteria**:
- Status marker convention file created and complete
- Delegation template includes explicit timing requirements
- All 6 subagents updated with timing-aware preflight
- All 6 subagents updated with timing-aware postflight
- Verification checkpoints added after delegation
- Instructions are concrete and executable
- Timing order is explicit: delegate → wait → verify → proceed

**Estimated Effort**: 3 hours

**Validation**:
- Review all 12 instruction blocks (6 preflight + 6 postflight)
- Verify timing requirements are explicit
- Verify verification checkpoints present
- Verify delegation syntax is concrete
- Verify failure handling is clear

---

### Phase 3: Testing and Timing Analysis [NOT STARTED]

**Objective**: Test all fixes with real workflow commands and document timing behavior

**Tasks**:

1. **Test status-sync-manager Bug Fixes**:
   - Test Bug #7 fix: Verify post-commit verification catches content failures
   - Test Bug #3 fix: Verify validation failures abort with errors
   - Test Bug #2 fix: Verify atomic writes work correctly
   - Test concurrent updates: Run two status-sync-manager invocations simultaneously
   - Document results
   
   **Estimated Effort**: 0.5 hours

2. **Test Preflight Execution**:
   - Create test task (e.g., task 322)
   - Run /research on test task
   - Verify status updates to [RESEARCHING] immediately (check state.json)
   - Verify preflight verification checkpoint passes
   - Verify research proceeds after preflight completes
   - Check for timing issues
   
   **Estimated Effort**: 0.5 hours

3. **Test Postflight Execution**:
   - Continue with same test task
   - Verify status updates to [RESEARCHED] on completion
   - Verify artifact linked in TODO.md
   - Verify postflight verification checkpoint passes
   - Verify state.json synchronized with TODO.md
   - Check for timing issues
   
   **Estimated Effort**: 0.5 hours

4. **Test Concurrent Execution**:
   - Run /research on task A and /plan on task B simultaneously
   - Verify both complete successfully
   - Verify no state corruption
   - Verify last writer wins (acceptable)
   - Document behavior
   
   **Estimated Effort**: 0.5 hours

5. **Document Timing Analysis**:
   - Create timing diagram showing execution order
   - Document critical timing requirements
   - Document verification checkpoint timing
   - Document atomic write timing
   - Identify any remaining timing issues
   
   **Estimated Effort**: 0.5 hours

**Acceptance Criteria**:
- All bug fixes tested and working
- Preflight execution confirmed
- Postflight execution confirmed
- Concurrent execution tested
- Timing analysis documented
- No regressions detected
- No timing-related failures observed

**Estimated Effort**: 2.5 hours

**Validation**:
- Test results documented
- Timing diagram created
- All tests pass
- No state corruption observed
- Concurrent execution works as expected

---

### Phase 4: Documentation and Cleanup [NOT STARTED]

**Objective**: Update documentation and prepare for commit

**Tasks**:

1. **Document Bug Fixes**:
   - Create `specs/321_fix_workflow_command_preflight_status_update_failures/bug-fixes.md`
   - Document bugs #7, #3, #2 and how they were fixed
   - Document why file locking was not used
   - Document why backup files were removed
   - Document timing requirements
   
   **Estimated Effort**: 0.5 hours

2. **Update Affected Documentation**:
   - Update state-management.md to reference status-markers.md
   - Update status-transitions.md to reference status-markers.md
   - Document atomic write pattern in status-sync-manager.md
   - Document timing requirements in subagent files
   
   **Estimated Effort**: 0.5 hours

3. **Clean Up Test Artifacts**:
   - Remove test task from TODO.md (if created)
   - Clean up any temporary test files
   - Verify no .tmp files left behind
   
   **Estimated Effort**: 0.25 hours

4. **Prepare Summary**:
   - Summarize all changes made
   - List all files modified
   - Document effort spent per phase
   - Prepare commit message
   
   **Estimated Effort**: 0.25 hours

**Acceptance Criteria**:
- Bug fixes documented
- All documentation updated
- No temporary files left behind
- Changes are consistent and well-documented
- Ready for git commit

**Estimated Effort**: 1.5 hours

**Validation**:
- Documentation complete and accurate
- No temporary files remain
- All references updated
- Changes ready for commit

---

## Testing and Validation

### Unit Testing

**status-sync-manager Bug Fixes**:
1. Test Bug #7 fix (post-commit verification):
   - Mock file write that doesn't update content
   - Verify status-sync-manager returns "failed"
   - Verify error message is clear

2. Test Bug #3 fix (validation failures):
   - Test invalid status transition
   - Test missing artifact
   - Test empty artifact
   - Verify all return "failed" with explicit errors

3. Test Bug #2 fix (atomic writes):
   - Test successful atomic write
   - Test failed atomic write (cleanup temp files)
   - Verify no .backup files created

### Integration Testing

1. **Preflight Execution Test**:
   - Run /research on test task
   - Verify status updates to [RESEARCHING] immediately
   - Verify state.json synchronized
   - Verify preflight verification passes

2. **Postflight Execution Test**:
   - Complete research on test task
   - Verify status updates to [RESEARCHED]
   - Verify artifact linked in TODO.md
   - Verify state.json synchronized
   - Verify postflight verification passes

3. **Concurrent Execution Test**:
   - Run /research and /plan simultaneously
   - Verify both complete successfully
   - Verify no state corruption
   - Verify last writer wins

4. **Timing Test**:
   - Verify preflight completes before work begins
   - Verify postflight completes before return
   - Verify verification occurs after delegation
   - Verify no race conditions

### Acceptance Testing

1. **User Workflow Test**:
   - Complete full workflow: /research → /plan → /implement
   - Verify status updates at each stage
   - Verify state synchronization throughout
   - Verify no silent failures

2. **Concurrent Agent Test**:
   - Run multiple commands in parallel
   - Verify all complete successfully
   - Verify state remains consistent
   - Verify no file locking issues

## Artifacts and Outputs

### Primary Artifacts

1. **Updated status-sync-manager.md**:
   - Bug #7 fix: Post-commit content verification
   - Bug #3 fix: Explicit validation failures
   - Bug #2 fix: Atomic write pattern
   - Removed backup file rollback

2. **Updated Subagent Files** (6 files):
   - researcher.md (timing-aware preflight + postflight)
   - planner.md (timing-aware preflight + postflight)
   - implementer.md (timing-aware preflight + postflight)
   - lean-research-agent.md (timing-aware preflight + postflight)
   - lean-planner.md (timing-aware preflight + postflight)
   - lean-implementation-agent.md (timing-aware preflight + postflight)

3. **.opencode/context/system/status-markers.md**:
   - Single source of truth for status markers
   - Complete list of all markers and transitions
   - TODO.md format vs state.json value mapping

### Documentation Artifacts

1. **Bug Fixes Documentation**:
   - `specs/321_fix_workflow_command_preflight_status_update_failures/bug-fixes.md`
   - Details of bugs #7, #3, #2 and fixes
   - Rationale for no file locking
   - Rationale for no backup files
   - Timing requirements

2. **Updated References**:
   - state-management.md (cross-reference to status-markers.md)
   - status-transitions.md (cross-reference to status-markers.md)
   - status-sync-manager.md (atomic write pattern documentation)

### Test Artifacts

1. **Test Results**:
   - status-sync-manager bug fix tests
   - Preflight execution tests
   - Postflight execution tests
   - Concurrent execution tests
   - Timing analysis

2. **Timing Diagram**:
   - Visual representation of execution order
   - Critical timing checkpoints
   - Verification timing

## Rollback/Contingency

### Rollback Plan

**Git-Only Rollback** (per user requirement):

1. **Immediate Rollback**:
   - `git revert <commit-hash>` to undo all changes
   - Restore original status-sync-manager.md
   - Restore original subagent files
   - No backup files to restore (none created)

2. **Partial Rollback**:
   - Keep status-markers.md (no harm)
   - Revert status-sync-manager changes if causing issues
   - Revert subagent changes if causing issues
   - Use git to selectively revert files

### Contingency Plan

If fixes cause issues:

1. **status-sync-manager Failures**:
   - Revert to previous version via git
   - Document failure mode
   - Investigate root cause
   - Propose alternative fix

2. **Concurrent Update Corruption**:
   - Document corruption pattern
   - Consider adding optimistic locking (compare-and-swap)
   - Document manual recovery procedure
   - Rely on git for state recovery

3. **Timing Issues**:
   - Add delays if verification reads stale state
   - Add retry logic for verification
   - Document timing assumptions
   - Test on different filesystems

## Success Metrics

### Primary Metrics

1. **Preflight Execution Rate**:
   - Target: 100% of workflow commands execute preflight
   - Measurement: Test with multiple commands, verify status updates
   - Baseline: Currently inconsistent (user reports consistent failures)

2. **Postflight Execution Rate**:
   - Target: 100% of workflow commands execute postflight
   - Measurement: Test with multiple commands, verify artifact linking
   - Baseline: Currently inconsistent

3. **State Synchronization**:
   - Target: 100% synchronization between TODO.md and state.json
   - Measurement: Compare status markers after workflow execution
   - Baseline: Currently desynchronized (Task 314 evidence)

4. **Silent Failure Rate**:
   - Target: 0% silent failures (all failures caught and reported)
   - Measurement: Test with simulated failures
   - Baseline: Currently 100% silent (bugs #7, #3 allow silent failures)

### Secondary Metrics

1. **Concurrent Execution**:
   - Target: Multiple agents can run simultaneously without corruption
   - Measurement: Run concurrent commands, verify state consistency
   - Baseline: Unknown (not tested)

2. **Timing Determinism**:
   - Target: Preflight/postflight timing is deterministic
   - Measurement: Timing analysis, no race conditions observed
   - Baseline: Unknown (timing not analyzed)

3. **Code Complexity**:
   - Target: Minimal increase (<150 lines total)
   - Measurement: Line count diff
   - Baseline: Current line count

## Notes

### Key Insights from Research-002.md

1. **Bug #7 is Critical**: status-sync-manager validates file size > 0 but NOT that status marker was actually updated. This allows silent failures where files are written but content is unchanged.

2. **Bug #3 Enables Silent Failures**: Validation failures don't abort operations, allowing invalid updates to proceed and return status="completed".

3. **Bug #2 Causes State Desync**: Two-phase commit creates a window where TODO.md is updated but state.json is not, causing the exact symptom seen in Task 314.

4. **No File Locking Required**: User requirement to allow concurrent agents means we cannot use file locking. Atomic writes with last-writer-wins is acceptable.

5. **Git-Only Rollback**: User requirement to rely on git exclusively means we remove backup file mechanism from status-sync-manager.

6. **Timing is Critical**: Preflight must complete BEFORE work begins, postflight must complete BEFORE return. Verification must occur AFTER delegation completes.

### Implementation Strategy

1. **Fix Root Causes First**: Phase 1 fixes status-sync-manager bugs that cause silent failures
2. **Then Add Verification**: Phase 2 enhances delegation instructions with verification checkpoints
3. **Test Thoroughly**: Phase 3 validates fixes work in practice and analyzes timing
4. **Document**: Phase 4 captures learnings and prepares for commit

### Alignment with User Requirements

- ✅ NO file locking (atomic writes only)
- ✅ NO backup files (git-only rollback)
- ✅ Careful timing analysis (Phase 3)
- ✅ Focus on making delegation execute (Phase 2)
- ✅ Minimal complexity (4 phases, surgical fixes only)
- ✅ status-markers.md created (Phase 2)
- ✅ Integrated research-002.md findings (Phase 1)

### Changes from Version 2

1. **Integrated research-002.md**: Added Phase 1 to fix status-sync-manager bugs
2. **Eliminated file locking**: Use atomic writes only
3. **Removed backup files**: Git-only rollback per user requirement
4. **Timing-focused**: Complete rethink of preflight/postflight timing
5. **Reduced complexity**: 6 phases → 4 phases
6. **Reordered priorities**: Fix bugs first, then add verification
7. **Reduced effort**: 5 hours → 4.5 hours (more focused scope)

---

**Plan Status**: Ready for implementation  
**Next Step**: Begin Phase 1 - Fix Critical status-sync-manager Bugs
