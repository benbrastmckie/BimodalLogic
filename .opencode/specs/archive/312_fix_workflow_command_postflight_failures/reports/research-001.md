# Research Report: Fix Systematic Postflight Failures in Workflow Commands

**Task**: 312  
**Started**: 2026-01-05  
**Completed**: 2026-01-05  
**Effort**: 6-8 hours  
**Priority**: High  
**Dependencies**: None  
**Sources/Inputs**:
- .opencode/specs/TODO.md (task 307, 312 entries)
- .opencode/specs/state.json (task status tracking)
- .opencode/agent/subagents/researcher.md (step_4_postflight)
- .opencode/agent/subagents/planner.md (step_7)
- .opencode/agent/subagents/lean-research-agent.md (step_7)
- .opencode/agent/subagents/status-sync-manager.md (atomic updates)
- .opencode/agent/subagents/git-workflow-manager.md (commit creation)
- Git history analysis (commits 4b9ad5c, 58f081c, e5cde92)

**Artifacts**:
- reports/research-001.md (this file)

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

**ROOT CAUSE IDENTIFIED: Git Race Condition, NOT Postflight Failure**

The systematic "postflight failures" are NOT actually postflight failures. The postflight steps ARE executing correctly and updating both TODO.md and state.json atomically via status-sync-manager. However, a **git race condition** causes TODO.md updates to be committed in a different task's commit when multiple workflow commands execute in rapid succession.

**Evidence**:
- Task 307 status WAS updated to [RESEARCHED] in TODO.md and state.json
- Task 307 research artifact WAS linked in TODO.md
- Task 307 postflight DID execute successfully
- BUT: Task 307's TODO.md changes were committed in task 306's commit (e5cde92) instead of task 307's commit (4b9ad5c)
- Timing: Task 306 commit at 05:32:42, Task 307 commit at 05:33:09 (27 seconds apart)

**Impact**: This is a git staging/commit timing issue, NOT a workflow execution issue. The system is working correctly from a functional perspective (status updates and artifact links are present), but the git commits are not properly scoped.

**Recommendation**: Implement git commit locking or staging isolation to prevent concurrent workflow commands from interfering with each other's commits.

---

## Context & Scope

### Research Question

Why do workflow commands (/research, /plan, /revise, /implement) create artifacts successfully but fail to link them in TODO.md and update status? Specifically:

1. Compare researcher.md and planner.md postflight implementations
2. Identify why postflight steps fail silently or don't execute
3. Examine status-sync-manager invocation patterns
4. Review artifact validation and linking mechanisms
5. Analyze the difference between working (/plan) and failing (/research) workflows
6. Determine if this is a delegation issue, execution flow issue, or error handling issue

### Background

Task 312 was created to investigate systematic postflight failures observed in task 307:
- `/research 307` created research-001.md successfully
- Task status allegedly remained [NOT STARTED] with no research link
- This suggested postflight steps (step_4_postflight in researcher, step_7 in planner) were not executing

However, investigation reveals a different root cause.

---

## Key Findings

### Finding 1: Postflight Steps ARE Executing Correctly

**Evidence from Code Analysis**:

All workflow subagents have proper postflight implementations:

1. **researcher.md** (lines 287-340):
   - step_4_postflight: Invokes status-sync-manager with validated_artifacts
   - Invokes git-workflow-manager with scope_files including TODO.md, state.json
   - Proper error handling and validation
   - Status transition: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]

2. **planner.md** (lines 240-349):
   - step_7: Invokes status-sync-manager with plan_metadata
   - Invokes git-workflow-manager with scope_files including TODO.md, state.json
   - Proper error handling and validation
   - Status transition: [NOT STARTED] → [PLANNING] → [PLANNED]

3. **lean-research-agent.md** (lines 631-679):
   - step_7: Invokes status-sync-manager with validated_artifacts
   - Invokes git-workflow-manager with scope_files including TODO.md, state.json
   - Proper error handling and validation
   - Status transition: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]

**Conclusion**: All postflight implementations follow the correct pattern and delegate to status-sync-manager and git-workflow-manager as specified.

---

### Finding 2: Task 307 Status WAS Updated Successfully

**Evidence from File Analysis**:

Current state of task 307 in TODO.md (lines 91-102):
```markdown
### 307. Verify or revert core logic changes in high-risk files (4/5)
- **Effort**: 1 hour
- **Status**: [RESEARCHED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Research Report](.opencode/specs/307_verify_or_revert_core_logic_changes_in_high_risk_files_4_5/reports/research-001.md)
- **Researched**: 2026-01-05
```

Current state of task 307 in state.json:
```json
{
  "project_number": 307,
  "status": "researched",
  "artifacts": [
    ".opencode/specs/307_verify_or_revert_core_logic_changes_in_high_risk_files_4_5/reports/research-001.md"
  ]
}
```

**Conclusion**: Task 307 status IS [RESEARCHED], artifact IS linked, postflight DID execute successfully. The claim that "task status remains [NOT STARTED] with no research link" is FALSE.

---

### Finding 3: Git Race Condition Caused Commit Mismatch

**Evidence from Git History**:

Commit timeline:
1. **Commit e5cde92** (2026-01-05 05:32:42): "task 306: plan revised (v3)"
   - Files: implementation-003.md, TODO.md, state.json
   - TODO.md changes include: Task 306 plan revision AND task 307 status update to [RESEARCHED]

2. **Commit 4b9ad5c** (2026-01-05 05:33:09): "Research task 307: Verify or revert core logic changes"
   - Files: research-001.md, state.json
   - TODO.md NOT included (no changes to commit)

**Git diff analysis**:
```bash
git diff e5cde92^..e5cde92 -- .opencode/specs/TODO.md
```

Shows task 307 changes in commit e5cde92:
```diff
 ### 307. Verify or revert core logic changes in high-risk files (4/5)
 - **Effort**: 1 hour
-- **Status**: [NOT STARTED]
+- **Status**: [RESEARCHED]
 - **Priority**: High
 - **Language**: markdown
 - **Blocking**: None
 - **Dependencies**: None
+- **Research**: [Research Report](.opencode/specs/307_verify_or_revert_core_logic_changes_in_high_risk_files_4_5/reports/research-001.md)
+- **Researched**: 2026-01-05
```

**Timeline reconstruction**:
1. Task 307 research completes at ~05:32:30
2. status-sync-manager updates TODO.md and state.json atomically
3. git-workflow-manager stages TODO.md, state.json, research-001.md
4. Task 306 plan revision starts at ~05:32:35
5. Task 306 status-sync-manager updates TODO.md and state.json
6. Task 306 git-workflow-manager stages TODO.md, state.json, implementation-003.md
7. Task 306 git commit executes at 05:32:42 - **includes task 307's TODO.md changes**
8. Task 307 git commit executes at 05:33:09 - TODO.md has no new changes to commit

**Conclusion**: This is a **git staging race condition**. When multiple workflow commands execute concurrently or in rapid succession, their TODO.md changes can be staged simultaneously, causing one task's commit to include another task's changes.

---

### Finding 4: No Error Logging Indicates Silent Success

**Evidence from Error Logs**:

Checked .opencode/specs/errors.json:
```json
{
  "_schema_version": "1.0.0",
  "_last_updated": "2025-12-26T00:00:00Z",
  "errors": []
}
```

**Conclusion**: No errors logged for task 307 or any recent workflow commands. This confirms postflight steps are executing successfully without errors. If postflight were failing, git-workflow-manager would log errors to errors.json per its error_logging specification (git-workflow-manager.md lines 158-171).

---

### Finding 5: Working vs Failing Workflows - No Difference

**Comparison Analysis**:

Task 306 (working):
- Commit 58f081c includes: research-001.md, TODO.md, state.json
- Status updated correctly
- Artifact linked correctly
- No concurrent tasks

Task 307 (allegedly failing):
- Commit 4b9ad5c includes: research-001.md, state.json (TODO.md missing)
- Status updated correctly (but in previous commit)
- Artifact linked correctly (but in previous commit)
- Concurrent with task 306 plan revision

**Conclusion**: There is NO difference in postflight implementation between working and failing workflows. The only difference is timing - task 307 executed concurrently with task 306, causing the git race condition.

---

## Detailed Analysis

### Root Cause: Git Staging is Not Isolated

**Problem**: git-workflow-manager stages files using `git add {file_path}` without any locking or isolation mechanism. When multiple workflow commands execute concurrently:

1. Task A stages TODO.md with its changes
2. Task B stages TODO.md with its changes (overwrites Task A's staging)
3. Task B commits - includes both Task A and Task B changes
4. Task A commits - TODO.md has no new changes (already committed by Task B)

**Git staging behavior**:
- `git add` stages the CURRENT state of a file
- Multiple `git add` calls on the same file overwrite previous staging
- `git commit` commits ALL staged changes, regardless of which task staged them

**Evidence from git-workflow-manager.md**:

Lines 117-129 (step_3):
```markdown
<step_3>
  <action>Stage files</action>
  <process>
    1. For each file in scope:
       a. Run: git add {file_path}
       b. Check for errors
       c. Log if file not found or not in repo
    2. Verify files staged successfully
    3. Check git status to confirm
  </process>
  <validation>All scoped files staged successfully</validation>
  <output>Staged files ready for commit</output>
</step_3>
```

**No locking mechanism**: git-workflow-manager does not implement any locking to prevent concurrent staging.

---

### Why This Appears as "Postflight Failure"

From a user perspective, when checking task 307's git commit:
1. User sees commit 4b9ad5c: "Research task 307"
2. User checks files in commit: research-001.md, state.json
3. User notices TODO.md is MISSING
4. User concludes: "Postflight failed to update TODO.md"

However, the actual state:
1. TODO.md WAS updated by task 307's postflight
2. TODO.md changes WERE committed (in task 306's commit)
3. Postflight DID execute successfully
4. Git commit scoping is incorrect due to race condition

---

### Affected Workflows

All workflow commands are potentially affected:
1. **/research** - researcher.md, lean-research-agent.md
2. **/plan** - planner.md, lean-planner.md
3. **/revise** - planner.md (revision mode)
4. **/implement** - implementer.md, lean-implementation-agent.md

**Frequency**: Race condition occurs when:
- Multiple workflow commands execute within ~30 seconds
- Commands update the same shared files (TODO.md, state.json)
- No locking mechanism prevents concurrent staging

---

## Decisions

### Decision 1: Postflight Implementation is Correct

**Rationale**: All postflight implementations follow the correct pattern:
1. Delegate to status-sync-manager for atomic TODO.md + state.json updates
2. Delegate to git-workflow-manager for scoped commits
3. Proper error handling and validation
4. Correct status transitions

**Action**: No changes needed to postflight implementations.

---

### Decision 2: Git Staging Requires Isolation

**Rationale**: The root cause is git staging race condition, not postflight execution failure.

**Action**: Implement one of the following solutions:

**Option A: Git Commit Locking** (Recommended)
- Add file-based locking to git-workflow-manager
- Lock file: .opencode/specs/.git-commit.lock
- Acquire lock before staging, release after commit
- Timeout: 60s (fail if lock held longer)
- Prevents concurrent git operations

**Option B: Staging Isolation**
- Use git worktrees for isolated staging
- Each workflow command gets its own worktree
- Commit from worktree, then merge to main
- More complex but provides true isolation

**Option C: Sequential Execution**
- Queue workflow commands at orchestrator level
- Execute one workflow command at a time
- Simple but reduces parallelism

**Recommendation**: Option A (Git Commit Locking) provides the best balance of simplicity, safety, and performance.

---

### Decision 3: Update Task 312 Description

**Rationale**: Task 312 description incorrectly states "postflight steps are not executing or failing silently". Research shows postflight steps ARE executing successfully.

**Action**: Update task 312 description to reflect actual root cause:
- Root cause: Git staging race condition
- Postflight steps execute correctly
- TODO.md and state.json are updated atomically
- Git commits are not properly scoped due to concurrent staging

---

## Recommendations

### Recommendation 1: Implement Git Commit Locking

**Priority**: High  
**Effort**: 2-3 hours  
**Impact**: Prevents all git race conditions

**Implementation**:

1. **Add locking to git-workflow-manager.md** (step_0_acquire_lock):
   ```bash
   # Acquire lock
   lock_file=".opencode/specs/.git-commit.lock"
   lock_timeout=60
   lock_acquired=false
   
   for i in {1..60}; do
     if mkdir "$lock_file" 2>/dev/null; then
       lock_acquired=true
       echo $$ > "$lock_file/pid"
       echo $(date -I) > "$lock_file/timestamp"
       break
     fi
     sleep 1
   done
   
   if [ "$lock_acquired" = false ]; then
     echo "ERROR: Failed to acquire git commit lock after ${lock_timeout}s"
     exit 1
   fi
   ```

2. **Add lock release** (step_5_release_lock):
   ```bash
   # Release lock
   rm -rf "$lock_file"
   ```

3. **Add lock cleanup on error**:
   - Trap EXIT signal to ensure lock is released
   - Check lock age and force-remove stale locks (>5 minutes old)

4. **Update git-workflow-manager constraints**:
   - Must acquire lock before staging
   - Must release lock after commit (success or failure)
   - Must handle lock timeout gracefully

**Testing**:
1. Run two workflow commands concurrently
2. Verify both commits include only their own TODO.md changes
3. Verify no race condition occurs
4. Verify lock is released on success and failure

---

### Recommendation 2: Add Git Commit Validation

**Priority**: Medium  
**Effort**: 1-2 hours  
**Impact**: Detects race conditions if they occur

**Implementation**:

1. **Add post-commit validation to git-workflow-manager**:
   ```bash
   # After commit, verify scoped files are in commit
   commit_hash=$(git rev-parse HEAD)
   committed_files=$(git show --name-only --format="" $commit_hash)
   
   for file in "${scope_files[@]}"; do
     if ! echo "$committed_files" | grep -q "^$file$"; then
       echo "WARNING: Expected file $file not in commit $commit_hash"
       echo "This may indicate a git race condition"
     fi
   done
   ```

2. **Log validation warnings to errors.json**:
   - Type: "git_commit_validation_warning"
   - Severity: "medium"
   - Include: task_number, expected_files, actual_files, commit_hash

3. **Return validation result in metadata**:
   ```json
   "metadata": {
     "commit_validation": {
       "expected_files": ["TODO.md", "state.json", "research-001.md"],
       "committed_files": ["state.json", "research-001.md"],
       "missing_files": ["TODO.md"],
       "status": "warning"
     }
   }
   ```

---

### Recommendation 3: Document Git Race Condition in Standards

**Priority**: Low  
**Effort**: 30 minutes  
**Impact**: Prevents future confusion

**Implementation**:

1. **Create .opencode/context/core/system/git-race-conditions.md**:
   - Document the race condition pattern
   - Explain why TODO.md might be missing from commits
   - Describe the locking solution
   - Provide troubleshooting steps

2. **Update git-commits.md**:
   - Add section on concurrent commit safety
   - Reference git-race-conditions.md
   - Document locking mechanism

3. **Update troubleshooting guides**:
   - Add "TODO.md missing from commit" troubleshooting entry
   - Explain how to verify if race condition occurred
   - Provide recovery steps

---

### Recommendation 4: Add Concurrent Execution Tests

**Priority**: Medium  
**Effort**: 2-3 hours  
**Impact**: Prevents regression

**Implementation**:

1. **Create test script**: `.opencode/tests/test-concurrent-workflows.sh`
   ```bash
   #!/bin/bash
   # Test concurrent workflow execution
   
   # Create two test tasks
   task1=$(create_test_task "Test concurrent research 1")
   task2=$(create_test_task "Test concurrent research 2")
   
   # Run research commands concurrently
   /research $task1 &
   pid1=$!
   /research $task2 &
   pid2=$!
   
   # Wait for both to complete
   wait $pid1
   wait $pid2
   
   # Verify both commits include only their own TODO.md changes
   commit1=$(git log --oneline --grep="task $task1" -1 --format="%H")
   commit2=$(git log --oneline --grep="task $task2" -1 --format="%H")
   
   files1=$(git show --name-only --format="" $commit1)
   files2=$(git show --name-only --format="" $commit2)
   
   # Verify TODO.md in both commits
   if ! echo "$files1" | grep -q "TODO.md"; then
     echo "FAIL: TODO.md missing from task $task1 commit"
     exit 1
   fi
   
   if ! echo "$files2" | grep -q "TODO.md"; then
     echo "FAIL: TODO.md missing from task $task2 commit"
     exit 1
   fi
   
   echo "PASS: Concurrent workflow execution test"
   ```

2. **Add to CI/CD pipeline**:
   - Run concurrent execution test on every PR
   - Fail build if race condition detected

---

## Risks & Mitigations

### Risk 1: Lock Deadlock

**Description**: If a workflow command crashes while holding the lock, subsequent commands will timeout waiting for the lock.

**Likelihood**: Low  
**Impact**: High (blocks all workflow commands)

**Mitigation**:
1. Implement stale lock detection (remove locks >5 minutes old)
2. Store PID in lock file and check if process is still running
3. Add manual lock removal command: `/unlock-git`
4. Log lock acquisition and release for debugging

---

### Risk 2: Lock Contention

**Description**: If many workflow commands execute concurrently, they will queue waiting for the lock, increasing latency.

**Likelihood**: Medium  
**Impact**: Medium (slower workflow execution)

**Mitigation**:
1. Set reasonable lock timeout (60s)
2. Optimize git-workflow-manager to minimize lock hold time
3. Consider per-task locking instead of global locking (more complex)
4. Monitor lock wait times and adjust timeout if needed

---

### Risk 3: False Positive Detection

**Description**: Validation might incorrectly flag missing files as race condition when files were intentionally excluded.

**Likelihood**: Low  
**Impact**: Low (warning noise)

**Mitigation**:
1. Only validate files explicitly listed in scope_files
2. Distinguish between "file not staged" vs "file not in commit"
3. Log validation details for debugging
4. Make validation warnings non-blocking

---

## Appendix: Sources and Citations

### Source 1: Task 307 Git History
- Commit 4b9ad5c: Research task 307 (05:33:09)
- Commit e5cde92: Task 306 plan revision (05:32:42)
- Analysis: Task 307 TODO.md changes in commit e5cde92

### Source 2: Subagent Implementations
- researcher.md lines 287-340: step_4_postflight
- planner.md lines 240-349: step_7
- lean-research-agent.md lines 631-679: step_7
- status-sync-manager.md lines 1-150: atomic updates
- git-workflow-manager.md lines 117-129: staging logic

### Source 3: Current State Files
- TODO.md lines 91-102: Task 307 entry (status [RESEARCHED])
- state.json: Task 307 entry (status "researched", artifacts present)
- errors.json: No errors logged

### Source 4: Git Commands Used
```bash
# Check commit files
git show --name-status 4b9ad5c
git show --name-status 58f081c

# Check TODO.md history
git log --all --oneline -- .opencode/specs/TODO.md

# Check TODO.md at specific commit
git show e5cde92:.opencode/specs/TODO.md

# Check TODO.md changes in commit
git diff e5cde92^..e5cde92 -- .opencode/specs/TODO.md
```

---

## Conclusion

The systematic "postflight failures" reported in task 312 are NOT postflight failures. The postflight steps ARE executing correctly, updating TODO.md and state.json atomically, and creating git commits. However, a **git staging race condition** causes TODO.md updates to be committed in a different task's commit when multiple workflow commands execute concurrently.

**Key Findings**:
1. Postflight implementations are correct and follow best practices
2. status-sync-manager updates TODO.md and state.json atomically
3. git-workflow-manager stages and commits files correctly
4. Race condition occurs when concurrent commands stage the same files
5. Task 307 status WAS updated correctly (visible in TODO.md and state.json)
6. Task 307 TODO.md changes were committed in task 306's commit

**Recommended Solution**: Implement git commit locking in git-workflow-manager to prevent concurrent staging and ensure proper commit scoping.

**Impact**: This fix will ensure each workflow command's git commit includes only its own changes, eliminating the race condition and providing proper commit attribution.
