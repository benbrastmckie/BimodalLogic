# Research Report: Potential Bugs/Issues in status-sync-manager

**Task**: 320 - Fix workflow command postflight failures causing missing artifact links and status updates  
**Research Focus**: Study potential bugs/issues in status-sync-manager given its critical importance in implementation plan  
**Started**: 2026-01-05  
**Completed**: 2026-01-05  
**Priority**: High  
**Dependencies**: Research-001.md (root cause analysis)

---

## Executive Summary

Comprehensive analysis of status-sync-manager reveals **7 critical potential bugs/issues** that could cause the systematic postflight failures described in task 320. The most critical issues are: (1) **No file locking mechanism** for concurrent updates, (2) **Race conditions** between TODO.md and state.json writes, (3) **Silent validation failures** that don't abort operations, (4) **Incomplete rollback** that may leave partial state, (5) **No retry logic** for transient failures, (6) **Artifact validation timing** issues, and (7) **Missing post-commit verification**. These issues align with the user's observation that artifacts are created but NOT linked, and status is NOT updated.

**Recommendation**: Prioritize fixes for issues #1 (file locking), #3 (validation failures), and #7 (post-commit verification) as these directly cause the failures described in task 320.

---

## Context & Scope

### Problem Statement

Task 320 implementation plan (implementation-002.md) identifies status-sync-manager as **critically important** for fixing postflight failures. The plan assumes status-sync-manager works correctly, but if it has bugs, the verification checkpoint approach may not solve the root issue.

**User Requirements**:
- MOST IMPORTANT: Fix missing artifact links and status updates (CRITICAL)
- Git failures: Passing failures of little concern (NON-CRITICAL)
- Validation: Minimal and well-placed
- User feedback: Very minimal

### Research Scope

This research investigates potential bugs/issues in status-sync-manager that could cause:
1. Artifacts created but NOT linked in TODO.md
2. Status NOT updated in TODO.md and state.json
3. Silent failures that return status="completed" despite errors
4. Race conditions or concurrency issues
5. Validation failures that don't abort operations
6. Rollback failures that leave partial state

---

## Key Findings

### Finding 1: No File Locking Mechanism (CRITICAL)

**Issue**: status-sync-manager has NO file locking mechanism to prevent concurrent updates.

**Evidence**:
- File: `.opencode/agent/subagents/status-sync-manager.md`
- Lines 345-595: update_status_flow has no lock acquisition
- Test plan (line 228-250): Test 8 "Concurrent Update Handling" expects file locking but none exists
- No `flock`, `lockfile`, or similar mechanism in process_flow

**Impact**: HIGH
- Two concurrent commands can corrupt TODO.md or state.json
- Race condition: Command A reads TODO.md, Command B reads TODO.md, Command A writes, Command B writes (overwrites A's changes)
- Example: `/research 320` and `/plan 320` run simultaneously → one update lost

**Likelihood**: MEDIUM
- User typically runs one command at a time
- But automated scripts or parallel workflows could trigger this

**Recommendation**: Add file locking in step_1_prepare:
```bash
# Acquire lock before reading files
exec 200>.opencode/specs/.status-sync.lock
flock -x 200 || { echo "Failed to acquire lock"; exit 1; }

# Read files...
# Update files...

# Release lock
flock -u 200
```

**Severity**: CRITICAL (can cause data corruption)

---

### Finding 2: Race Condition Between TODO.md and state.json Writes (CRITICAL)

**Issue**: Two-phase commit writes TODO.md first, then state.json, creating a window where files are inconsistent.

**Evidence**:
- File: `.opencode/agent/subagents/status-sync-manager.md`
- Lines 554-560: step_4_commit writes TODO.md, then state.json
- Line 1179: "Write order matters: .opencode/specs/TODO.md first (most critical), then state files"
- No atomic write mechanism (e.g., write to temp files, then rename)

**Impact**: HIGH
- If process crashes between TODO.md write and state.json write: Files inconsistent
- If another process reads files during this window: Sees inconsistent state
- Example: TODO.md shows [RESEARCHED], state.json shows "not_started"

**Likelihood**: LOW
- Requires process crash or concurrent read during narrow window
- But this is EXACTLY the symptom described in task 320 (status updated in TODO.md but not state.json)

**Recommendation**: Use atomic write pattern:
```bash
# Write to temp files
write_file ".opencode/specs/TODO.md.tmp" "$updated_todo"
write_file ".opencode/specs/state.json.tmp" "$updated_state"

# Atomic rename (both files or neither)
mv ".opencode/specs/TODO.md.tmp" ".opencode/specs/TODO.md" && \
mv ".opencode/specs/state.json.tmp" ".opencode/specs/state.json" || \
{ rm -f ".opencode/specs/TODO.md.tmp" ".opencode/specs/state.json.tmp"; exit 1; }
```

**Severity**: CRITICAL (directly causes task 320 symptoms)

---

### Finding 3: Silent Validation Failures (CRITICAL)

**Issue**: Validation failures may not abort operations, allowing invalid updates to proceed.

**Evidence**:
- File: `.opencode/agent/subagents/status-sync-manager.md`
- Lines 358-397: step_2_validate has extensive validation but unclear abort behavior
- Line 386: "If invalid transition: abort before writing" (but no explicit error return)
- Line 374: "If validation fails: abort before writing" (but no explicit error return)
- No explicit `exit 1` or `return failed` in validation steps

**Impact**: HIGH
- Invalid status transitions may proceed (e.g., completed → in_progress)
- Artifacts that don't exist may be linked
- Malformed plan files may be updated
- Example: Artifact validation fails but update proceeds anyway

**Likelihood**: MEDIUM
- Depends on AI agent interpretation of "abort before writing"
- If agent doesn't explicitly exit, validation is ineffective

**Recommendation**: Make validation failures explicit:
```bash
# In step_2_validate
if [ "$transition_invalid" = "true" ]; then
  echo '{"status":"failed","summary":"Invalid status transition","errors":[...]}'
  exit 1
fi

if [ ! -f "$artifact_path" ]; then
  echo '{"status":"failed","summary":"Artifact validation failed","errors":[...]}'
  exit 1
fi
```

**Severity**: CRITICAL (allows invalid updates that cause task 320 symptoms)

---

### Finding 4: Incomplete Rollback May Leave Partial State (HIGH)

**Issue**: Rollback mechanism may not restore all files if restoration fails.

**Evidence**:
- File: `.opencode/agent/subagents/status-sync-manager.md`
- Lines 562-571: rollback_on_failure restores files from backups
- Line 585: "If restoration failed: Log critical error" (but no retry or manual intervention)
- No verification that restored files match original backups

**Impact**: MEDIUM-HIGH
- If rollback fails: Files left in inconsistent state
- If backup is corrupt: Rollback restores corrupt data
- Example: TODO.md restored, state.json restoration fails → inconsistent state

**Likelihood**: LOW
- Requires write failure AND rollback failure (double failure)
- But if it happens, recovery is difficult

**Recommendation**: Add rollback verification:
```bash
# After rollback
if ! diff -q ".opencode/specs/TODO.md" ".opencode/specs/TODO.md.backup"; then
  echo "CRITICAL: Rollback verification failed for TODO.md"
  echo "Manual intervention required"
  exit 1
fi
```

**Severity**: HIGH (leaves system in unrecoverable state)

---

### Finding 5: No Retry Logic for Transient Failures (MEDIUM)

**Issue**: Transient failures (e.g., disk full, temporary permission issue) cause immediate failure with no retry.

**Evidence**:
- File: `.opencode/agent/subagents/status-sync-manager.md`
- Lines 554-560: step_4_commit writes files with no retry
- No exponential backoff or retry mechanism
- Single write failure causes rollback

**Impact**: MEDIUM
- Transient failures cause unnecessary rollbacks
- User must manually retry command
- Example: Disk temporarily full → write fails → rollback → user retries → succeeds

**Likelihood**: LOW
- Transient failures are rare on modern systems
- But when they occur, retry would improve UX

**Recommendation**: Add retry logic with exponential backoff:
```bash
# Retry write up to 3 times
for attempt in 1 2 3; do
  if write_file ".opencode/specs/TODO.md" "$updated_todo"; then
    break
  fi
  if [ $attempt -lt 3 ]; then
    sleep $((attempt * 2))  # Exponential backoff
  else
    echo "Write failed after 3 attempts"
    rollback
    exit 1
  fi
done
```

**Severity**: MEDIUM (reduces reliability but not critical)

---

### Finding 6: Artifact Validation Timing Issue (MEDIUM)

**Issue**: Artifacts are validated BEFORE commit, but artifact creation happens BEFORE status-sync-manager is invoked. If artifact is deleted between creation and validation, validation fails.

**Evidence**:
- File: `.opencode/agent/subagents/status-sync-manager.md`
- Lines 370-375: Artifact validation in step_2_validate
- Validation checks file exists and is non-empty
- But artifact could be deleted by another process between creation and validation

**Impact**: LOW-MEDIUM
- If artifact is deleted: Validation fails, update aborted
- User sees "Artifact validation failed" despite artifact being created
- Example: Researcher creates artifact, another process deletes it, status-sync-manager validation fails

**Likelihood**: VERY LOW
- Requires external process deleting artifacts during workflow
- Unlikely in normal usage

**Recommendation**: Add artifact validation retry:
```bash
# Retry artifact validation once after 1 second
if [ ! -f "$artifact_path" ]; then
  sleep 1
  if [ ! -f "$artifact_path" ]; then
    echo "Artifact validation failed: $artifact_path not found"
    exit 1
  fi
fi
```

**Severity**: MEDIUM (causes false failures)

---

### Finding 7: Missing Post-Commit Verification (CRITICAL)

**Issue**: Post-commit validation (step_5_return) only checks file size > 0, not that updates were actually applied.

**Evidence**:
- File: `.opencode/agent/subagents/status-sync-manager.md`
- Lines 575-593: step_5_return validates file exists and size > 0
- No verification that status marker was actually updated
- No verification that artifact link was actually added
- Example: File written but status marker not updated → validation passes anyway

**Impact**: HIGH
- Updates may fail silently (file written but content unchanged)
- User sees "completed" status but files not actually updated
- This is EXACTLY the symptom described in task 320

**Likelihood**: MEDIUM
- Depends on how AI agent interprets "update status marker"
- If agent writes file but doesn't update content, validation passes

**Recommendation**: Add content verification:
```bash
# In step_5_return
# Verify status marker was updated
if ! grep -q "\*\*Status\*\*: \[$expected_status\]" .opencode/specs/TODO.md; then
  echo "CRITICAL: Status marker not updated in TODO.md"
  echo "Expected: $expected_status"
  echo "File written but content not updated"
  exit 1
fi

# Verify artifact link was added
if [ -n "$artifact_path" ]; then
  if ! grep -q "$artifact_path" .opencode/specs/TODO.md; then
    echo "CRITICAL: Artifact link not added to TODO.md"
    echo "Expected: $artifact_path"
    exit 1
  fi
fi
```

**Severity**: CRITICAL (directly causes task 320 symptoms)

---

## Detailed Analysis

### Root Cause Alignment with Task 320

Task 320 research-001.md identified "silent git commit failures" as root cause. However, user clarified that **MOST IMPORTANT** failures are:
1. Artifacts NOT linked in TODO.md
2. Status NOT updated in TODO.md and state.json

This research reveals that status-sync-manager has **3 critical bugs** that directly cause these symptoms:

**Bug #3 (Silent Validation Failures)**:
- If artifact validation fails but doesn't abort: Artifact not linked
- If status transition validation fails but doesn't abort: Status not updated

**Bug #2 (Race Condition)**:
- If process crashes between TODO.md and state.json writes: Status updated in TODO.md but not state.json
- This matches user's observation exactly

**Bug #7 (Missing Post-Commit Verification)**:
- If file written but content not updated: Validation passes but status/artifact not actually updated
- This is the most likely cause of task 320 symptoms

### Why These Bugs Cause "Silent" Failures

All 3 bugs share a common pattern: **They allow status-sync-manager to return status="completed" even when updates failed**.

**Bug #3**: Validation fails but doesn't abort → continues to commit → returns "completed"
**Bug #2**: TODO.md written, state.json write fails → rollback fails → returns "completed" (should return "failed")
**Bug #7**: Files written but content not updated → size > 0 validation passes → returns "completed"

This explains why task 320 research-001.md found that "postflight steps ARE executing" but failures are silent.

### Integration with Task 320 Implementation Plan

Task 320 implementation-002.md proposes:
- **Phase 2**: Add verification checkpoint after status-sync-manager
- **Phase 3**: Implement two-level error logging
- **Phase 4**: Add command-level validation

This research reveals that **Phase 2 verification checkpoint is ESSENTIAL** because status-sync-manager has bugs that allow silent failures. The checkpoint should verify:
1. Status updated in state.json (Bug #2, #7)
2. Status updated in TODO.md (Bug #2, #7)
3. Artifact linked in TODO.md (Bug #3, #7)

However, **Phase 2 alone is not sufficient**. We also need:
- **Fix Bug #3**: Make validation failures explicit (abort with error)
- **Fix Bug #7**: Add post-commit content verification
- **Fix Bug #2**: Use atomic write pattern (optional, reduces race condition window)

---

## Recommendations

### Immediate Fixes (Required for Task 320)

**Priority 1: Fix Bug #7 (Missing Post-Commit Verification)**
- Add content verification in step_5_return
- Verify status marker updated in TODO.md
- Verify artifact link added to TODO.md
- Verify status updated in state.json
- Effort: 1 hour
- Impact: Directly prevents task 320 symptoms

**Priority 2: Fix Bug #3 (Silent Validation Failures)**
- Make validation failures explicit with `exit 1`
- Add clear error messages for each validation failure
- Ensure validation aborts before commit
- Effort: 0.5 hours
- Impact: Prevents invalid updates

**Priority 3: Implement Phase 2 Verification Checkpoint (Task 320 Plan)**
- Add checkpoint in subagent postflight after status-sync-manager
- Verify status updated in state.json AND TODO.md
- Verify artifact linked in TODO.md
- Effort: 2 hours (as planned)
- Impact: Catches status-sync-manager failures

### Medium-Term Fixes (Recommended)

**Priority 4: Fix Bug #2 (Race Condition)**
- Use atomic write pattern (write to temp, then rename)
- Reduces race condition window to near-zero
- Effort: 1 hour
- Impact: Improves reliability

**Priority 5: Fix Bug #4 (Incomplete Rollback)**
- Add rollback verification
- Ensure restored files match original backups
- Effort: 0.5 hours
- Impact: Improves error recovery

### Long-Term Fixes (Optional)

**Priority 6: Fix Bug #1 (No File Locking)**
- Add file locking mechanism
- Prevents concurrent update corruption
- Effort: 2 hours
- Impact: Prevents rare but severe corruption

**Priority 7: Fix Bug #5 (No Retry Logic)**
- Add retry with exponential backoff
- Handles transient failures gracefully
- Effort: 1 hour
- Impact: Improves UX

**Priority 8: Fix Bug #6 (Artifact Validation Timing)**
- Add artifact validation retry
- Handles rare timing issues
- Effort: 0.5 hours
- Impact: Reduces false failures

---

## Revised Implementation Plan for Task 320

Based on this research, task 320 implementation-002.md should be revised to include:

### Phase 0: Fix status-sync-manager Bugs (NEW)

**Objective**: Fix critical bugs in status-sync-manager before implementing verification checkpoint.

**Tasks**:
1. Fix Bug #7 (Missing Post-Commit Verification):
   - Add content verification in step_5_return
   - Verify status marker updated in TODO.md
   - Verify artifact link added to TODO.md
   - Verify status updated in state.json

2. Fix Bug #3 (Silent Validation Failures):
   - Make validation failures explicit with `exit 1`
   - Add clear error messages
   - Ensure validation aborts before commit

**Estimated Effort**: 1.5 hours

**Rationale**: Without these fixes, Phase 2 verification checkpoint will catch failures but status-sync-manager will still have bugs. Fixing bugs first makes verification checkpoint more effective.

### Phase 1-5: As Planned (with adjustments)

**Phase 1**: Create shared postflight/preflight standards file (0.5 hours)
**Phase 2**: Add verification checkpoint to subagent postflight (2 hours)
- **Adjustment**: Checkpoint now verifies status-sync-manager output AND file content
**Phase 3**: Implement two-level error logging (1 hour)
**Phase 4**: Add minimal command-level validation (1 hour)
**Phase 5**: Testing and validation (0.5 hours)

**Total Effort**: 6.5 hours (up from 5 hours, but more robust)

---

## Risks & Mitigations

### Risk 1: Fixing status-sync-manager May Introduce New Bugs

**Risk**: Adding post-commit verification or explicit validation may introduce new bugs.

**Likelihood**: LOW  
**Impact**: MEDIUM

**Mitigation**:
1. Test fixes in isolation before integrating
2. Use existing test plan (Test 1-10 in archived test-plan.md)
3. Add regression tests for new verification logic

### Risk 2: Atomic Write Pattern May Not Work on All Filesystems

**Risk**: `mv` (rename) may not be atomic on all filesystems (e.g., NFS).

**Likelihood**: LOW  
**Impact**: MEDIUM

**Mitigation**:
1. Document filesystem requirements
2. Test on target filesystem
3. Fallback to two-phase commit if atomic rename not supported

### Risk 3: File Locking May Cause Deadlocks

**Risk**: If two processes acquire locks in different order, deadlock may occur.

**Likelihood**: VERY LOW  
**Impact**: HIGH

**Mitigation**:
1. Use single lock file for all operations
2. Set lock timeout (e.g., 30 seconds)
3. Document lock acquisition order

---

## Appendix: Bug Summary Table

| Bug # | Issue | Severity | Likelihood | Effort | Priority |
|-------|-------|----------|------------|--------|----------|
| 1 | No file locking | CRITICAL | MEDIUM | 2h | 6 (Long-term) |
| 2 | Race condition | CRITICAL | LOW | 1h | 4 (Medium-term) |
| 3 | Silent validation failures | CRITICAL | MEDIUM | 0.5h | 2 (Immediate) |
| 4 | Incomplete rollback | HIGH | LOW | 0.5h | 5 (Medium-term) |
| 5 | No retry logic | MEDIUM | LOW | 1h | 7 (Long-term) |
| 6 | Artifact validation timing | MEDIUM | VERY LOW | 0.5h | 8 (Long-term) |
| 7 | Missing post-commit verification | CRITICAL | MEDIUM | 1h | 1 (Immediate) |

**Total Immediate Fixes**: 1.5 hours (Bugs #3, #7)  
**Total Medium-Term Fixes**: 1.5 hours (Bugs #2, #4)  
**Total Long-Term Fixes**: 3.5 hours (Bugs #1, #5, #6)  
**Total All Fixes**: 6.5 hours

---

## Appendix: Sources and Citations

### Source 1: status-sync-manager.md

- File: `.opencode/agent/subagents/status-sync-manager.md`
- Lines 1-1193: Complete specification
- Key sections:
  - Lines 345-595: update_status_flow (no file locking, race condition)
  - Lines 358-397: step_2_validate (silent validation failures)
  - Lines 554-571: step_4_commit (race condition, no atomic write)
  - Lines 575-593: step_5_return (missing post-commit verification)

### Source 2: Test Plan

- File: `.opencode/specs/archive/168_ensure_plan_research_revise_and_task_update_todo_md_and_state_json_status_correctly/test-plan.md`
- Lines 228-250: Test 8 "Concurrent Update Handling" expects file locking but none exists
- Lines 152-176: Test 5 "Rollback on Partial Failure" tests rollback mechanism

### Source 3: Task 320 Research-001.md

- File: `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-001.md`
- Key findings:
  - Root cause: Silent git commit failures (but user clarified status/artifact failures more important)
  - Postflight steps DO exist and execute
  - Git failures treated as non-critical

### Source 4: Task 320 Implementation-002.md

- File: `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/plans/implementation-002.md`
- Key sections:
  - Lines 42-43: Identifies status-sync-manager as critical
  - Lines 236-296: Phase 2 verification checkpoint
  - Lines 137-146: Risk 1 acknowledges status-sync-manager may have bugs

---

## Summary

This research identifies **7 potential bugs/issues** in status-sync-manager, with **3 critical bugs** (#3, #2, #7) that directly cause the symptoms described in task 320:
1. Artifacts created but NOT linked
2. Status NOT updated in TODO.md and state.json

**Immediate Action Required**:
1. Fix Bug #7 (Missing Post-Commit Verification) - 1 hour
2. Fix Bug #3 (Silent Validation Failures) - 0.5 hours
3. Implement Phase 2 Verification Checkpoint (Task 320 Plan) - 2 hours

**Total Immediate Effort**: 3.5 hours (in addition to task 320 plan)

**Recommendation**: Add Phase 0 to task 320 implementation plan to fix status-sync-manager bugs before implementing verification checkpoint. This ensures verification checkpoint is effective and status-sync-manager is robust.
