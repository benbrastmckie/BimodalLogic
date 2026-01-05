# Implementation Plan: Fix Git Staging Race Condition with Scoped Staging

**Task**: 312  
**Status**: [NOT STARTED]  
**Created**: 2026-01-05  
**Revised**: 2026-01-05  
**Estimated Effort**: 4-5 hours  
**Language**: meta  
**Type**: bugfix  
**Priority**: high  

---

## Metadata

- **Task Number**: 312
- **Plan Version**: 2
- **Complexity**: low-medium
- **Total Phases**: 4
- **Research Integrated**: Yes
- **Dependencies**: None
- **Blocking**: None
- **Revision Reason**: User feedback - avoid git commit locking (slows down work), prefer simpler and more robust solution

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

**Revision Context**: Plan v1 recommended git commit locking. User feedback: "I don't want to implement git commit locking in git-workflow-manager to prevent concurrent staging since that will slow down work. Instead, I'd like to make git commits stage only the changes made if this isn't too tricky, or to create another way to monitor postflight success to avoid this issue altogether."

### Alternative Approaches Evaluated

**Option 1: Git Commit Locking** (Plan v1 approach)
- **Pros**: Prevents all race conditions, simple to implement
- **Cons**: Serializes all git commits, slows down concurrent workflows, risk of deadlock
- **User Feedback**: Rejected - will slow down work

**Option 2: Scoped Staging with `git add -p` or `--patch`**
- **Pros**: Interactive, precise control over staging
- **Cons**: Requires interactive input (not suitable for automation), too complex
- **Verdict**: Not suitable for automated workflows

**Option 3: Git Stash Isolation**
- **Pros**: Isolates changes before staging
- **Cons**: Complex workflow (stash, stage, commit, pop), error-prone, doesn't prevent race condition
- **Verdict**: Too complex, doesn't solve root cause

**Option 4: Separate Git Worktrees**
- **Pros**: True isolation, no race conditions
- **Cons**: Very complex, requires worktree management, cleanup overhead, overkill for this issue
- **Verdict**: Too complex for the benefit

**Option 5: Post-Commit Validation and Automatic Correction**
- **Pros**: Detects race conditions, can auto-fix missing links
- **Cons**: Doesn't prevent race condition, adds complexity, requires retry logic
- **Verdict**: Detection is useful, but correction is complex

**Option 6: Accept Race Condition, Improve Detection/Recovery**
- **Pros**: Simple, no workflow changes, focuses on user experience
- **Cons**: Doesn't fix root cause, race conditions still occur
- **Verdict**: Not a real fix, only a workaround

**Option 7: Git Index Manipulation (Scoped Staging)** ⭐ **SELECTED**
- **Pros**: Stages only specific file changes, no locking needed, simple implementation, robust
- **Cons**: Requires careful git plumbing commands
- **Verdict**: **Best option** - simple, robust, no performance impact

**Option 8: Per-File Locking**
- **Pros**: Less contention than global locking
- **Cons**: Still requires locking, complex lock management, doesn't prevent TODO.md race
- **Verdict**: Doesn't solve the core issue (TODO.md is shared)

**Option 9: Retry Logic on Validation Failure**
- **Pros**: Handles transient failures
- **Cons**: Doesn't prevent race condition, adds latency, complex retry logic
- **Verdict**: Useful as fallback, not a primary solution

### Selected Approach: Scoped Staging with Git Plumbing

**Core Insight**: Instead of staging entire files with `git add {file}`, we can stage ONLY the changes made by the current workflow command using git plumbing commands.

**Implementation Strategy**:
1. Before staging: Capture current state of shared files (TODO.md, state.json)
2. After status-sync-manager: Capture new state of shared files
3. Generate diff between old and new state
4. Stage ONLY the diff (not the entire file)
5. Commit staged changes

**Git Commands**:
```bash
# Step 1: Capture current state (before status-sync-manager)
git show HEAD:.opencode/specs/TODO.md > /tmp/TODO.md.before
git show HEAD:.opencode/specs/state.json > /tmp/state.json.before

# Step 2: status-sync-manager updates files

# Step 3: Generate diff for only our changes
git diff --no-index /tmp/TODO.md.before .opencode/specs/TODO.md > /tmp/TODO.md.patch
git diff --no-index /tmp/state.json.before .opencode/specs/state.json > /tmp/state.json.patch

# Step 4: Apply patch to index (stage only our changes)
git apply --cached /tmp/TODO.md.patch
git apply --cached /tmp/state.json.patch

# Step 5: Stage task-specific artifacts (no race condition)
git add {task_artifact_path}

# Step 6: Commit
git commit -m "..."
```

**Why This Works**:
- Captures the EXACT changes made by status-sync-manager
- Stages only those changes, not the entire file
- If another task modifies TODO.md concurrently, their changes are NOT staged
- No locking needed - each task stages only its own changes
- Robust - works even with concurrent modifications

**Fallback**: If patch application fails (e.g., concurrent modification conflict), fall back to full file staging with validation warning.

### Scope

**In Scope**:
- Implement scoped staging in git-workflow-manager
- Add pre-staging state capture (step_0_capture_state)
- Add scoped staging logic (step_3_stage_scoped_changes)
- Add fallback to full staging on patch failure
- Add post-commit validation to detect race conditions
- Add concurrent execution tests
- Update git-workflow-manager documentation

**Out of Scope**:
- Git commit locking (user rejected)
- Git worktree-based isolation (too complex)
- Orchestrator-level command queuing (reduces parallelism)
- Changes to postflight implementations (already correct)
- Changes to status-sync-manager (already atomic)

### Constraints

- Must not require locking (user requirement)
- Must not slow down concurrent workflows
- Must handle concurrent modifications gracefully
- Must fall back to full staging if scoped staging fails
- Git commit failure must remain non-critical (don't fail task)
- Solution must be simple and robust

### Definition of Done

- [ ] Scoped staging implemented in git-workflow-manager
- [ ] Pre-staging state capture working
- [ ] Patch-based staging working for shared files
- [ ] Fallback to full staging on patch failure
- [ ] Post-commit validation detects missing files
- [ ] Concurrent execution test passes
- [ ] Documentation updated
- [ ] No race conditions when running concurrent workflow commands
- [ ] Each task's commit includes only its own TODO.md changes
- [ ] No performance degradation for concurrent workflows

---

## Goals and Non-Goals

### Goals

1. **Prevent git staging race conditions** - Ensure each workflow command's git commit includes only its own changes
2. **Maintain performance** - No locking, no serialization, concurrent workflows run at full speed
3. **Maintain atomic updates** - Preserve status-sync-manager's atomic TODO.md + state.json updates
4. **Graceful error handling** - Handle patch failures and concurrent modifications without failing tasks
5. **Validation and detection** - Detect race conditions if they occur despite scoped staging
6. **Testing coverage** - Verify concurrent execution works correctly

### Non-Goals

1. **Implement git commit locking** - User rejected due to performance concerns
2. **Rewrite postflight implementations** - Current implementations are correct
3. **Change status-sync-manager** - Already provides atomic updates
4. **Implement git worktrees** - Too complex for this fix
5. **Queue all commands** - Would reduce parallelism unnecessarily
6. **Prevent all concurrent execution** - Only prevent cross-contamination of commits

---

## Risks and Mitigations

### Risk 1: Patch Application Failure

- **Description**: `git apply --cached` fails due to concurrent modifications or merge conflicts
- **Likelihood**: Low-Medium
- **Impact**: Medium (falls back to full staging, potential race condition)
- **Mitigation**: 
  - Implement robust fallback to full file staging
  - Log patch failure with details for debugging
  - Add validation to detect if fallback caused race condition
  - Consider retry with exponential backoff if patch fails

### Risk 2: State Capture Timing

- **Description**: File state changes between capture and status-sync-manager execution
- **Likelihood**: Very Low
- **Impact**: Low (patch will include extra changes)
- **Mitigation**:
  - Capture state immediately before status-sync-manager invocation
  - Minimize time between capture and status-sync-manager
  - Validate captured state matches expected state

### Risk 3: Git Plumbing Command Complexity

- **Description**: Git plumbing commands are more complex and error-prone than porcelain commands
- **Likelihood**: Low
- **Impact**: Medium (implementation bugs)
- **Mitigation**:
  - Thorough testing of patch generation and application
  - Add extensive error handling and logging
  - Document git plumbing commands clearly
  - Test with various concurrent scenarios

### Risk 4: False Positive Validation

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

### Phase 1: Add Pre-Staging State Capture [NOT STARTED]
**Estimated Effort**: 1 hour

**Objective**: Capture current state of shared files before status-sync-manager modifies them

**Tasks**:
1. Add step_0_capture_state to git-workflow-manager.md process_flow
2. Implement state capture logic:
   - Identify shared files: TODO.md, state.json
   - Capture current HEAD state: `git show HEAD:{file} > /tmp/{file}.before`
   - Handle case where file doesn't exist in HEAD (new file)
   - Store captured state in temporary directory
3. Add error handling for capture failures
4. Update process_flow numbering (existing steps shift by 1)

**Acceptance Criteria**:
- [ ] step_0_capture_state added before step_1
- [ ] TODO.md and state.json captured from HEAD
- [ ] Captured state stored in /tmp with unique session ID
- [ ] New files handled gracefully (empty before state)
- [ ] Capture errors logged but don't fail workflow
- [ ] Temporary files cleaned up after commit

**Validation**:
- Test state capture succeeds for existing files
- Test state capture handles new files (not in HEAD)
- Test state capture handles deleted files
- Test temporary files are created correctly
- Test temporary files are cleaned up

---

### Phase 2: Implement Scoped Staging with Patch Application [NOT STARTED]
**Estimated Effort**: 2 hours

**Objective**: Stage only the changes made by current workflow command using git patches

**Tasks**:
1. Update step_3 (stage files) to use scoped staging
2. Implement scoped staging logic:
   - For shared files (TODO.md, state.json):
     a. Generate diff: `git diff --no-index /tmp/{file}.before {file} > /tmp/{file}.patch`
     b. Apply to index: `git apply --cached /tmp/{file}.patch`
     c. Handle patch application errors
     d. Fall back to full staging if patch fails
   - For task-specific files (artifacts):
     a. Use normal staging: `git add {artifact_path}`
3. Add patch validation before application
4. Add detailed error logging for patch failures
5. Implement fallback to full staging with warning

**Acceptance Criteria**:
- [ ] Scoped staging implemented for TODO.md and state.json
- [ ] Patch generated from before/after state
- [ ] Patch applied to git index (staged)
- [ ] Task-specific artifacts staged normally
- [ ] Patch application errors handled gracefully
- [ ] Fallback to full staging on patch failure
- [ ] Warnings logged for fallback cases

**Validation**:
- Test scoped staging succeeds for normal case
- Test scoped staging handles concurrent modifications
- Test patch application with various diff sizes
- Test fallback to full staging on patch failure
- Test task-specific artifacts staged correctly

---

### Phase 3: Add Post-Commit Validation and Concurrent Tests [NOT STARTED]
**Estimated Effort**: 1.5 hours

**Objective**: Detect race conditions if they occur and verify concurrent execution works

**Tasks**:
1. Add post-commit validation to step_4 (after commit creation)
2. Implement validation logic:
   - Get commit hash from git commit output
   - Run `git show --name-only --format="" {hash}`
   - Compare committed files with scope_files
   - Detect missing files
   - Log validation warnings (non-blocking)
3. Create test script: `.opencode/tests/test-concurrent-workflows.sh`
4. Implement concurrent test:
   - Create two test tasks
   - Run /research commands concurrently
   - Verify both commits include TODO.md
   - Verify no cross-contamination
   - Verify scoped staging worked correctly
5. Add test cleanup

**Acceptance Criteria**:
- [ ] Post-commit validation runs after git commit
- [ ] Validation compares committed files with scope_files
- [ ] Missing files detected and logged
- [ ] Validation warnings are non-blocking
- [ ] Test script creates two test tasks
- [ ] Test runs concurrent /research commands
- [ ] Test verifies TODO.md in both commits
- [ ] Test verifies no cross-contamination
- [ ] Test cleanup removes test tasks

**Validation**:
- Test validation passes when all files committed
- Test validation detects missing files
- Test validation warnings are non-blocking
- Run concurrent test with scoped staging (should pass)
- Run concurrent test with full staging (should fail)
- Verify test cleanup works

---

### Phase 4: Update Documentation and Finalize [NOT STARTED]
**Estimated Effort**: 0.5 hours

**Objective**: Document scoped staging mechanism and update standards

**Tasks**:
1. Update git-workflow-manager.md:
   - Document step_0_capture_state
   - Document scoped staging in step_3
   - Document fallback logic
   - Document post-commit validation
   - Update constraints section
2. Create `.opencode/context/core/system/git-race-conditions.md`:
   - Document race condition pattern
   - Explain scoped staging solution
   - Provide troubleshooting steps
   - Document fallback scenarios
3. Update `.opencode/context/core/system/git-commits.md`:
   - Add section on concurrent commit safety
   - Reference git-race-conditions.md
   - Document scoped staging approach
4. Update task 312 description in TODO.md:
   - Correct root cause (git race condition, not postflight failure)
   - Reference research findings
   - Document scoped staging solution

**Acceptance Criteria**:
- [ ] git-workflow-manager.md updated with scoped staging steps
- [ ] git-race-conditions.md created
- [ ] git-commits.md updated with concurrent safety section
- [ ] Task 312 description corrected
- [ ] All documentation follows standards
- [ ] Troubleshooting guide includes scoped staging

**Validation**:
- Review documentation for clarity
- Verify all scoped staging steps documented
- Verify troubleshooting steps are actionable
- Verify task description is accurate

---

## Testing and Validation

### Unit Tests
- State capture for existing files
- State capture for new files
- Patch generation from before/after state
- Patch application to git index
- Fallback to full staging on patch failure
- Post-commit validation
- Error handling

### Integration Tests
- Concurrent workflow execution (test-concurrent-workflows.sh)
- Scoped staging with concurrent modifications
- Patch application with various diff sizes
- Fallback scenarios
- Validation warnings

### Manual Testing
- Run two /research commands concurrently
- Verify both commits include TODO.md
- Verify no cross-contamination
- Test patch failure scenarios
- Test fallback to full staging
- Verify no performance degradation

### Validation Criteria
- All unit tests pass
- Concurrent execution test passes
- No race conditions in manual testing
- Scoped staging works correctly
- Fallback works when needed
- No performance degradation

---

## Artifacts and Outputs

### Primary Artifacts
1. **git-workflow-manager.md** (updated)
   - step_0_capture_state implementation
   - Scoped staging in step_3
   - Fallback logic
   - Post-commit validation

2. **test-concurrent-workflows.sh** (new)
   - Concurrent execution test
   - Race condition detection
   - Test cleanup

3. **git-race-conditions.md** (new)
   - Race condition documentation
   - Scoped staging explanation
   - Troubleshooting guide

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
If scoped staging causes issues:
1. Revert git-workflow-manager.md to previous version
2. Remove state capture and scoped staging steps
3. Revert to full file staging
4. Keep post-commit validation (useful for detection)
5. Document known race condition issue

### Contingency Options
1. **Option A**: Increase fallback usage
   - If scoped staging fails frequently, rely more on fallback
   - Monitor fallback rate and investigate root causes
   - Improve patch generation logic

2. **Option B**: Implement selective locking
   - If scoped staging doesn't fully solve race condition
   - Add lightweight locking only for TODO.md staging
   - Keep task-specific artifacts unlocked

3. **Option C**: Accept race condition and improve detection
   - Keep post-commit validation
   - Add automatic retry on validation failure
   - Document as known limitation

---

## Success Metrics

### Functional Metrics
- [ ] Zero race conditions in concurrent execution tests
- [ ] 100% of commits include expected files
- [ ] Scoped staging success rate >95%
- [ ] Fallback rate <5%

### Performance Metrics
- [ ] No increase in workflow command latency (single execution)
- [ ] No increase in latency for concurrent execution
- [ ] State capture time <100ms (average)
- [ ] Patch generation time <100ms (average)
- [ ] Patch application time <100ms (average)

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
- Write access to .opencode/specs/
- Understanding of git staging and commit process
- Git version 2.0+ (for `git apply --cached`)

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

1. **State Capture Timing**:
   - Capture state immediately before status-sync-manager
   - Minimize time between capture and modification
   - Use session ID for unique temporary file names

2. **Patch Generation**:
   - Use `git diff --no-index` for before/after comparison
   - Handle binary files gracefully (fall back to full staging)
   - Validate patch before application

3. **Patch Application**:
   - Use `git apply --cached` to stage without modifying working tree
   - Handle whitespace differences gracefully
   - Detect and handle patch conflicts

4. **Fallback Strategy**:
   - Fall back to full staging if patch fails
   - Log fallback with reason for debugging
   - Add validation to detect if fallback caused race condition

5. **Temporary File Management**:
   - Use /tmp with session ID for uniqueness
   - Clean up temporary files after commit
   - Handle cleanup on error (trap EXIT)

### Advantages Over Plan v1 (Git Locking)

1. **No Performance Impact**: Concurrent workflows run at full speed, no serialization
2. **No Deadlock Risk**: No locks to manage, no stale lock cleanup needed
3. **Simpler**: No lock acquisition/release logic, no timeout handling
4. **More Robust**: Works even with concurrent modifications, graceful fallback
5. **User Requirement**: Meets user's requirement to avoid locking

### Potential Challenges

1. **Patch Complexity**: Git plumbing commands are more complex than porcelain
2. **Edge Cases**: Need to handle various diff scenarios (new files, deletions, binary files)
3. **Testing**: Need thorough testing of concurrent scenarios
4. **Debugging**: Patch failures may be harder to debug than locking issues

### Future Enhancements
1. Optimize patch generation for large files
2. Add metrics for scoped staging success rate
3. Improve fallback detection and recovery
4. Add automatic retry on patch failure
5. Cross-platform testing (macOS, Windows)

---

## Phase Status Summary

| Phase | Status | Effort | Dependencies |
|-------|--------|--------|--------------|
| 1. Pre-Staging State Capture | [NOT STARTED] | 1h | None |
| 2. Scoped Staging with Patches | [NOT STARTED] | 2h | Phase 1 |
| 3. Validation and Tests | [NOT STARTED] | 1.5h | Phase 1, 2 |
| 4. Documentation | [NOT STARTED] | 0.5h | Phase 1, 2, 3 |

**Total Estimated Effort**: 5 hours

---

## Comparison with Plan v1

| Aspect | Plan v1 (Locking) | Plan v2 (Scoped Staging) |
|--------|-------------------|--------------------------|
| **Approach** | Global git commit lock | Patch-based scoped staging |
| **Performance** | Serializes commits | No performance impact |
| **Complexity** | Medium (lock management) | Medium (git plumbing) |
| **Robustness** | High (prevents all races) | High (graceful fallback) |
| **Risk** | Deadlock, contention | Patch failure |
| **User Requirement** | ❌ Rejected | ✅ Accepted |
| **Effort** | 8 hours | 5 hours |
| **Phases** | 5 | 4 |

**Recommendation**: Plan v2 is simpler, faster, and meets user requirements while solving the same problem.
