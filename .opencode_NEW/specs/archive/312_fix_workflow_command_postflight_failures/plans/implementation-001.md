# Implementation Plan: Fix Git Staging Race Condition in Workflow Commands

**Task**: 312  
**Status**: [NOT STARTED]  
**Created**: 2026-01-05  
**Estimated Effort**: 6-8 hours  
**Language**: meta  
**Type**: bugfix  
**Priority**: high  

---

## Metadata

- **Task Number**: 312
- **Plan Version**: 1
- **Complexity**: medium
- **Total Phases**: 5
- **Research Integrated**: Yes
- **Dependencies**: None
- **Blocking**: None

---

## Overview

### Problem Statement

Workflow commands (/research, /plan, /revise, /implement) experience git staging race conditions when executed concurrently or in rapid succession. This causes TODO.md and state.json updates from one task to be committed in another task's git commit, making it appear that postflight steps failed when they actually executed successfully.

**Example**: Task 307 research completed successfully, updating TODO.md and state.json to [RESEARCHED] status with artifact links. However, these changes were committed in task 306's commit (e5cde92) instead of task 307's commit (4b9ad5c), making it appear that task 307's postflight failed.

### Research Integration

This plan integrates findings from 1 research report:

**Integrated Reports**:
- **research-001.md** (2026-01-05): Root cause analysis of systematic postflight failures
  - Key Finding: Postflight steps ARE executing correctly - the issue is a git staging race condition
  - Key Finding: When multiple workflow commands execute within ~30 seconds, their TODO.md changes can be staged simultaneously
  - Key Finding: Git commit includes ALL staged changes, regardless of which task staged them
  - Key Finding: Task 307 status WAS updated correctly, but committed in task 306's commit due to race condition
  - Recommendation: Implement git commit locking in git-workflow-manager to prevent concurrent staging

### Scope

**In Scope**:
- Implement file-based locking mechanism in git-workflow-manager
- Add lock acquisition before staging (step_0_acquire_lock)
- Add lock release after commit (step_5_release_lock)
- Add stale lock detection and cleanup
- Add post-commit validation to detect race conditions
- Add concurrent execution tests
- Update git-workflow-manager documentation

**Out of Scope**:
- Git worktree-based isolation (more complex alternative)
- Orchestrator-level command queuing (reduces parallelism)
- Changes to postflight implementations (already correct)
- Changes to status-sync-manager (already atomic)

### Constraints

- Lock timeout must be reasonable (60s recommended)
- Lock must be released on both success and failure
- Stale locks (>5 minutes old) must be auto-removed
- Git commit failure must remain non-critical (don't fail task)
- Solution must not reduce parallelism unnecessarily

### Definition of Done

- [ ] Git commit locking implemented in git-workflow-manager
- [ ] Lock acquired before staging, released after commit
- [ ] Stale lock detection and cleanup working
- [ ] Post-commit validation detects missing files
- [ ] Concurrent execution test passes
- [ ] Documentation updated
- [ ] No race conditions when running concurrent workflow commands
- [ ] Each task's commit includes only its own TODO.md changes

---

## Goals and Non-Goals

### Goals

1. **Prevent git staging race conditions** - Ensure each workflow command's git commit includes only its own changes
2. **Maintain atomic updates** - Preserve status-sync-manager's atomic TODO.md + state.json updates
3. **Graceful error handling** - Handle lock timeouts and stale locks without failing tasks
4. **Validation and detection** - Detect race conditions if they occur despite locking
5. **Testing coverage** - Verify concurrent execution works correctly

### Non-Goals

1. **Rewrite postflight implementations** - Current implementations are correct
2. **Change status-sync-manager** - Already provides atomic updates
3. **Implement git worktrees** - Too complex for this fix
4. **Queue all commands** - Would reduce parallelism unnecessarily
5. **Prevent all concurrent execution** - Only prevent concurrent git commits

---

## Risks and Mitigations

### Risk 1: Lock Deadlock
- **Description**: Workflow command crashes while holding lock, blocking subsequent commands
- **Likelihood**: Low
- **Impact**: High (blocks all workflow commands)
- **Mitigation**: 
  - Implement stale lock detection (remove locks >5 minutes old)
  - Store PID in lock file and check if process is still running
  - Add manual lock removal capability
  - Use trap EXIT to ensure lock release

### Risk 2: Lock Contention
- **Description**: Many concurrent workflow commands queue waiting for lock, increasing latency
- **Likelihood**: Medium
- **Impact**: Medium (slower workflow execution)
- **Mitigation**:
  - Set reasonable lock timeout (60s)
  - Optimize git-workflow-manager to minimize lock hold time
  - Monitor lock wait times in metadata
  - Consider per-task locking if contention becomes severe

### Risk 3: False Positive Validation
- **Description**: Post-commit validation incorrectly flags missing files as race condition
- **Likelihood**: Low
- **Impact**: Low (warning noise)
- **Mitigation**:
  - Only validate files explicitly listed in scope_files
  - Make validation warnings non-blocking
  - Log validation details for debugging
  - Distinguish "file not staged" vs "file not in commit"

---

## Implementation Phases

### Phase 1: Add Lock Acquisition and Release [NOT STARTED]
**Estimated Effort**: 2 hours

**Objective**: Implement file-based locking mechanism in git-workflow-manager

**Tasks**:
1. Add step_0_acquire_lock to git-workflow-manager.md process_flow
2. Implement lock acquisition logic:
   - Lock file: `specs/.git-commit.lock`
   - Lock timeout: 60 seconds
   - Store PID and timestamp in lock file
   - Retry with 1-second sleep intervals
3. Add step_5_release_lock to git-workflow-manager.md process_flow
4. Implement lock release logic:
   - Remove lock directory
   - Log lock release
5. Add trap EXIT to ensure lock release on error
6. Update process_flow numbering (step_5 becomes step_6, etc.)

**Acceptance Criteria**:
- [ ] step_0_acquire_lock added before step_1
- [ ] Lock file created with PID and timestamp
- [ ] Lock acquisition retries up to 60 times (60 seconds)
- [ ] Lock acquisition fails gracefully after timeout
- [ ] step_5_release_lock added after step_4
- [ ] Lock removed on both success and failure
- [ ] trap EXIT ensures lock cleanup

**Validation**:
- Test lock acquisition succeeds when no lock exists
- Test lock acquisition waits when lock exists
- Test lock acquisition fails after timeout
- Test lock release removes lock directory
- Test trap EXIT removes lock on error

---

### Phase 2: Add Stale Lock Detection and Cleanup [NOT STARTED]
**Estimated Effort**: 1.5 hours

**Objective**: Prevent deadlock from crashed processes holding locks

**Tasks**:
1. Add stale lock detection to step_0_acquire_lock
2. Implement stale lock logic:
   - Check lock timestamp (>5 minutes = stale)
   - Check if PID is still running
   - Force-remove stale locks
   - Log stale lock removal
3. Add lock age validation
4. Add PID validation (check /proc/{pid} on Linux)
5. Update error handling for stale locks

**Acceptance Criteria**:
- [ ] Locks older than 5 minutes are detected as stale
- [ ] Stale locks are force-removed before acquisition
- [ ] PID validation checks if process is still running
- [ ] Stale lock removal is logged
- [ ] Lock acquisition succeeds after stale lock removal

**Validation**:
- Test stale lock (>5 minutes) is removed
- Test fresh lock (<5 minutes) is not removed
- Test dead PID lock is removed
- Test live PID lock is not removed
- Test stale lock removal is logged

---

### Phase 3: Add Post-Commit Validation [NOT STARTED]
**Estimated Effort**: 1.5 hours

**Objective**: Detect race conditions if they occur despite locking

**Tasks**:
1. Add post-commit validation to step_4 (after commit creation)
2. Implement validation logic:
   - Get commit hash from git commit output
   - Run `git show --name-only --format="" {hash}`
   - Compare committed files with scope_files
   - Detect missing files
3. Add validation result to return metadata
4. Log validation warnings to errors.json (non-blocking)
5. Include validation details in return object

**Acceptance Criteria**:
- [ ] Post-commit validation runs after git commit
- [ ] Validation compares committed files with scope_files
- [ ] Missing files are detected and logged
- [ ] Validation warnings are non-blocking
- [ ] Validation result included in metadata
- [ ] Warnings logged to errors.json with type "git_commit_validation_warning"

**Validation**:
- Test validation passes when all files committed
- Test validation detects missing files
- Test validation warnings are non-blocking
- Test validation result in metadata
- Test warnings logged to errors.json

---

### Phase 4: Add Concurrent Execution Tests [NOT STARTED]
**Estimated Effort**: 2 hours

**Objective**: Verify locking prevents race conditions in concurrent execution

**Tasks**:
1. Create test script: `.opencode/tests/test-concurrent-workflows.sh`
2. Implement test logic:
   - Create two test tasks
   - Run /research commands concurrently
   - Wait for both to complete
   - Verify both commits include TODO.md
   - Verify no cross-contamination of changes
3. Add test assertions:
   - TODO.md in both commits
   - Each commit includes only its own changes
   - No race condition detected
4. Add test cleanup (remove test tasks)
5. Document test usage

**Acceptance Criteria**:
- [ ] Test script creates two test tasks
- [ ] Test runs two /research commands concurrently
- [ ] Test verifies TODO.md in both commits
- [ ] Test verifies no cross-contamination
- [ ] Test passes with locking enabled
- [ ] Test cleanup removes test tasks
- [ ] Test documented in README

**Validation**:
- Run test with locking enabled (should pass)
- Run test with locking disabled (should fail)
- Verify test detects race conditions
- Verify test cleanup works

---

### Phase 5: Update Documentation and Finalize [NOT STARTED]
**Estimated Effort**: 1 hour

**Objective**: Document locking mechanism and update standards

**Tasks**:
1. Update git-workflow-manager.md:
   - Document step_0_acquire_lock
   - Document step_5_release_lock
   - Document stale lock detection
   - Document post-commit validation
   - Update constraints section
2. Create `.opencode/context/core/system/git-race-conditions.md`:
   - Document race condition pattern
   - Explain locking solution
   - Provide troubleshooting steps
3. Update `.opencode/context/core/system/git-commits.md`:
   - Add section on concurrent commit safety
   - Reference git-race-conditions.md
4. Update task 312 description in TODO.md:
   - Correct root cause (git race condition, not postflight failure)
   - Reference research findings

**Acceptance Criteria**:
- [ ] git-workflow-manager.md updated with locking steps
- [ ] git-race-conditions.md created
- [ ] git-commits.md updated with concurrent safety section
- [ ] Task 312 description corrected
- [ ] All documentation follows standards

**Validation**:
- Review documentation for clarity
- Verify all locking steps documented
- Verify troubleshooting steps are actionable
- Verify task description is accurate

---

## Testing and Validation

### Unit Tests
- Lock acquisition and release
- Stale lock detection
- PID validation
- Post-commit validation
- Error handling

### Integration Tests
- Concurrent workflow execution (test-concurrent-workflows.sh)
- Lock timeout handling
- Stale lock cleanup
- Validation warnings

### Manual Testing
- Run two /research commands concurrently
- Verify both commits include TODO.md
- Verify no cross-contamination
- Test lock timeout (hold lock manually)
- Test stale lock cleanup (create old lock)

### Validation Criteria
- All unit tests pass
- Concurrent execution test passes
- No race conditions in manual testing
- Lock timeout works correctly
- Stale locks are cleaned up

---

## Artifacts and Outputs

### Primary Artifacts
1. **git-workflow-manager.md** (updated)
   - step_0_acquire_lock implementation
   - step_5_release_lock implementation
   - Stale lock detection
   - Post-commit validation

2. **test-concurrent-workflows.sh** (new)
   - Concurrent execution test
   - Race condition detection
   - Test cleanup

3. **git-race-conditions.md** (new)
   - Race condition documentation
   - Troubleshooting guide
   - Locking mechanism explanation

### Supporting Artifacts
1. **git-commits.md** (updated)
   - Concurrent commit safety section
   - Reference to git-race-conditions.md

2. **TODO.md** (updated)
   - Task 312 description corrected
   - Root cause documented

---

## Rollback/Contingency

### Rollback Plan
If locking causes issues:
1. Revert git-workflow-manager.md to previous version
2. Remove lock acquisition and release steps
3. Remove stale lock detection
4. Keep post-commit validation (useful for detection)
5. Document known race condition issue

### Contingency Options
1. **Option A**: Implement per-task locking instead of global locking
   - More complex but reduces contention
   - Allows concurrent commits for different tasks

2. **Option B**: Implement orchestrator-level command queuing
   - Simpler but reduces parallelism
   - Queue workflow commands at orchestrator level

3. **Option C**: Accept race condition and improve detection
   - Keep post-commit validation
   - Add automatic retry on validation failure
   - Document as known limitation

---

## Success Metrics

### Functional Metrics
- [ ] Zero race conditions in concurrent execution tests
- [ ] 100% of commits include expected files
- [ ] Lock acquisition success rate >99%
- [ ] Stale lock cleanup success rate 100%

### Performance Metrics
- [ ] Lock acquisition time <1 second (average)
- [ ] Lock hold time <5 seconds (average)
- [ ] No increase in workflow command latency (single execution)
- [ ] <10% increase in latency for concurrent execution

### Quality Metrics
- [ ] All tests pass
- [ ] Documentation complete and clear
- [ ] No new errors logged
- [ ] Code follows standards

---

## Dependencies and Prerequisites

### Prerequisites
- Git installed and configured
- Bash shell available
- Write access to specs/
- Understanding of git staging and commit process

### External Dependencies
- None (pure bash and git implementation)

### Internal Dependencies
- git-workflow-manager.md (existing)
- status-sync-manager.md (existing, no changes needed)
- Workflow command subagents (existing, no changes needed)

---

## Notes and Considerations

### Key Insights from Research
1. Postflight implementations are correct - no changes needed
2. status-sync-manager provides atomic updates - no changes needed
3. Race condition is purely a git staging issue
4. Task 307 status WAS updated correctly (visible in TODO.md and state.json)
5. Git commits are not properly scoped due to concurrent staging

### Implementation Considerations
1. Lock file location: `specs/.git-commit.lock`
   - Visible in git status but not committed
   - Easy to inspect and remove manually
   - Standard location for lock files

2. Lock timeout: 60 seconds
   - Long enough for normal git operations
   - Short enough to prevent long waits
   - Adjustable if needed

3. Stale lock threshold: 5 minutes
   - Generous buffer for slow operations
   - Prevents false positives
   - Catches truly stale locks

4. PID validation: Check /proc/{pid}
   - Linux-specific but works on most systems
   - Fallback to timestamp-only validation if /proc unavailable
   - Prevents removing locks from live processes

### Future Enhancements
1. Per-task locking for better concurrency
2. Lock metrics and monitoring
3. Automatic retry on lock timeout
4. Lock queue visualization
5. Cross-platform PID validation (macOS, Windows)

---

## Phase Status Summary

| Phase | Status | Effort | Dependencies |
|-------|--------|--------|--------------|
| 1. Lock Acquisition/Release | [NOT STARTED] | 2h | None |
| 2. Stale Lock Detection | [NOT STARTED] | 1.5h | Phase 1 |
| 3. Post-Commit Validation | [NOT STARTED] | 1.5h | Phase 1 |
| 4. Concurrent Execution Tests | [NOT STARTED] | 2h | Phase 1, 2, 3 |
| 5. Documentation | [NOT STARTED] | 1h | Phase 1, 2, 3, 4 |

**Total Estimated Effort**: 8 hours
