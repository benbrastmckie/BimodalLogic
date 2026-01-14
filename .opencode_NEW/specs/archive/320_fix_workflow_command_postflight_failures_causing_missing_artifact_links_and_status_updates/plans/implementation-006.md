# Implementation Plan: Fix Workflow Command Postflight Failures (v6 - Corrected After Empirical Testing)

**Task**: 320 - Fix workflow command postflight failures causing missing artifact links and status updates  
**Status**: [PLANNED]  
**Estimated Effort**: TBD (pending task 324 investigation)  
**Complexity**: High  
**Language**: meta  
**Priority**: High  
**Created**: 2026-01-05  
**Plan Version**: 6  
**Revision Reason**: Plan v5 was INCORRECT - claimed task 321 completed all work based on reading implementation summary. Empirical testing (task 323) proves the problem STILL EXISTS. TODO.md is NOT being updated during postflight despite task 321's claimed fixes. This plan acknowledges the error and waits for task 324 investigation before proposing solutions.

---

## Critical Correction to Plan v5

### What Plan v5 Claimed (WRONG)

**Claim**: "Task 321 has COMPLETELY SOLVED the original task 320 problem. There is NO REMAINING WORK."

**Basis**: Reading task 321 implementation summary without empirical verification

**Conclusion**: "Mark task 320 as COMPLETED"

### What Empirical Testing Revealed (CORRECT)

**Test Case**: `/research 323` executed after task 321 implementation

**Results**:
- ✓ Research artifact created successfully (research-001.md, 699 lines)
- ✓ state.json updated correctly (status: "researched", artifacts array populated)
- ✓ Git commit created successfully (14abf52)
- ✗ **TODO.md NOT updated** (still shows "[NOT STARTED]")
- ✗ **TODO.md NOT staged** in git commit
- ✗ **Artifact links NOT added** to TODO.md

**Evidence**: `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/artifacts/task-323-workflow-execution-report.md`

**Conclusion**: **The problem STILL EXISTS** - task 321 did NOT fix it

### Lesson Learned

**Never conclude a task is complete based solely on reading implementation summaries.**

Always require empirical verification:
1. Test the actual behavior
2. Verify the fixes work in practice
3. Check if the original problem is resolved
4. Provide concrete evidence (test cases, before/after comparisons)

---

## Current Understanding (After Task 323 Test)

### Confirmed Problem

**Symptom**: Workflow commands (/research, /plan, /revise, /implement) create artifacts successfully but fail to update TODO.md with:
- Status markers (e.g., [RESEARCHED], [PLANNED], [IMPLEMENTED])
- Artifact links
- Completion timestamps

**Evidence**: Task 323 research
- state.json: status = "researched", artifacts = ["...research-001.md"], research_completed = "2026-01-05" ✓
- TODO.md: Status = "[NOT STARTED]", no artifacts listed, no research completion date ✗
- Git commit 14abf52: Includes state.json ✓, excludes TODO.md ✗

### What Task 321 Actually Fixed

Based on task 321 implementation summary:
1. ✅ Bug #7 (Missing Post-Commit Verification) - Added content verification to status-sync-manager
2. ✅ Bug #3 (Silent Validation Failures) - Made validation failures explicit
3. ✅ Bug #2 (Race Condition) - Implemented atomic write pattern
4. ✅ Enhanced all 6 subagents with preflight/postflight delegation instructions
5. ✅ Created status-markers.md convention file
6. ✅ Implemented atomic writes without file locking
7. ✅ Removed backup files (git-only rollback)

**However**: These fixes did NOT resolve the TODO.md update problem.

### What Task 321 Did NOT Fix

**The core issue**: TODO.md is not being updated during postflight, despite:
- status-sync-manager having post-commit verification (Bug #7 fix)
- Subagents having explicit delegation instructions
- Atomic write pattern implemented (Bug #2 fix)

**Possible explanations**:
1. status-sync-manager is not being invoked for TODO.md updates
2. status-sync-manager is invoked but fails silently
3. status-sync-manager updates state.json but skips TODO.md
4. Delegation instructions are not being executed by AI agents
5. Verification checkpoints are not catching the TODO.md update failure

### Task 324 Investigation

**Purpose**: Investigate and prove the root cause before attempting solutions

**Key Questions**:
1. Is status-sync-manager being invoked during postflight?
2. If yes, does it attempt to update TODO.md?
3. If yes, does the update succeed or fail?
4. If it fails, is the failure logged or silent?
5. If it's not invoked, why are the delegation instructions not being executed?

**Approach**: Study task 323 workflow execution report and trace the actual execution path

---

## Scope (Pending Task 324 Investigation)

### In Scope (After Investigation)

**Will be determined based on task 324 findings**

Possible areas:
1. Fix status-sync-manager invocation (if not being called)
2. Fix status-sync-manager TODO.md update logic (if failing)
3. Fix delegation instruction execution (if being skipped)
4. Fix verification checkpoints (if not catching failures)
5. Add missing postflight steps (if workflow incomplete)

### Out of Scope

1. Bugs #5 and #6 from research-002.md (MEDIUM severity, not critical)
2. Two-level error logging formalization (nice-to-have)
3. Command-level validation (may be redundant)
4. Extensive testing (will be done after fix)

### Constraints

1. **NO File Locking**: Allow concurrent agents (task 321 implemented this)
2. **NO Backup Files**: Use git exclusively for rollback (task 321 implemented this)
3. **Atomic Updates**: Both TODO.md and state.json must update atomically
4. **Minimal Changes**: Surgical fix based on root cause
5. **Empirical Verification**: Test fix with task 323 as validation case

---

## Definition of Done (Pending Investigation)

**Will be updated after task 324 investigation completes**

Minimum requirements:
- [ ] Root cause identified and proven (task 324)
- [ ] Fix implemented based on root cause
- [ ] Task 323 TODO.md updated correctly (validation case)
- [ ] All 4 workflow commands tested (/research, /plan, /revise, /implement)
- [ ] TODO.md and state.json synchronized
- [ ] Artifact links added to TODO.md
- [ ] Status markers updated correctly
- [ ] Git commits include both TODO.md and state.json
- [ ] No regression in existing functionality

---

## Implementation Phases (Placeholder)

**NOTE**: These phases are PLACEHOLDERS pending task 324 investigation results.

### Phase 0: Wait for Task 324 Investigation [IN PROGRESS]

**Objective**: Understand the root cause before proposing solutions

**Tasks**:
1. Task 324 investigates task 323 workflow execution
2. Task 324 traces actual execution path
3. Task 324 identifies specific failure point
4. Task 324 proves root cause with evidence

**Estimated Effort**: TBD (task 324 effort)

**Acceptance Criteria**:
- [ ] Root cause identified
- [ ] Evidence provided (logs, traces, code analysis)
- [ ] Failure mechanism understood
- [ ] Fix approach recommended

---

### Phase 1: Implement Fix Based on Root Cause [NOT STARTED]

**Objective**: TBD (depends on task 324 findings)

**Tasks**: TBD

**Estimated Effort**: TBD

**Acceptance Criteria**: TBD

---

### Phase 2: Test Fix with Task 323 [NOT STARTED]

**Objective**: Validate fix resolves the problem

**Tasks**:
1. Manually update task 323 TODO.md entry to test expected format
2. Run /research on a new test task
3. Verify TODO.md updated correctly
4. Verify state.json synchronized
5. Verify git commit includes both files
6. Compare with task 323 baseline (before fix)

**Estimated Effort**: 0.5 hours

**Acceptance Criteria**:
- [ ] TODO.md updated with correct status marker
- [ ] Artifact links added to TODO.md
- [ ] state.json synchronized with TODO.md
- [ ] Git commit includes both files
- [ ] No discrepancies between TODO.md and state.json

---

### Phase 3: Test All Workflow Commands [NOT STARTED]

**Objective**: Ensure fix works for all commands

**Tasks**:
1. Test /research on new task
2. Test /plan on researched task
3. Test /implement on planned task
4. Test /revise on existing plan
5. Verify all update TODO.md correctly

**Estimated Effort**: 1 hour

**Acceptance Criteria**:
- [ ] /research updates TODO.md to [RESEARCHED]
- [ ] /plan updates TODO.md to [PLANNED]
- [ ] /implement updates TODO.md to [IMPLEMENTED]
- [ ] /revise updates TODO.md correctly
- [ ] All commands link artifacts in TODO.md
- [ ] All commands synchronize state.json and TODO.md

---

### Phase 4: Documentation and Cleanup [NOT STARTED]

**Objective**: Document fix and close task

**Tasks**:
1. Document root cause and fix
2. Update task 320 description with findings
3. Create implementation summary
4. Clean up test artifacts
5. Prepare git commit

**Estimated Effort**: 0.5 hours

**Acceptance Criteria**:
- [ ] Root cause documented
- [ ] Fix documented
- [ ] Test results documented
- [ ] Task 320 description updated
- [ ] Implementation summary created

---

## Risks and Mitigations

### Risk 1: Root Cause May Be Complex

**Risk**: Task 324 investigation may reveal multiple interacting issues

**Likelihood**: MEDIUM  
**Impact**: HIGH

**Mitigation**:
1. Focus on most critical issue first (TODO.md not updating)
2. Implement surgical fix for core problem
3. Address secondary issues in follow-up tasks
4. Document all findings for future reference

### Risk 2: Fix May Break Existing Functionality

**Risk**: Changes to status-sync-manager or subagents may cause regressions

**Likelihood**: MEDIUM  
**Impact**: HIGH

**Mitigation**:
1. Test thoroughly before committing
2. Use task 323 as validation case
3. Test all 4 workflow commands
4. Keep changes minimal and surgical
5. Rely on git for rollback if needed

### Risk 3: Task 321 Fixes May Conflict

**Risk**: Task 321's changes may conflict with task 320 fix

**Likelihood**: LOW  
**Impact**: MEDIUM

**Mitigation**:
1. Review task 321 changes before implementing fix
2. Ensure fix builds on task 321 foundation
3. Avoid duplicating task 321 work
4. Test integration carefully

### Risk 4: Delegation Instructions May Still Not Execute

**Risk**: Even with fixes, AI agents may not execute delegation instructions

**Likelihood**: MEDIUM  
**Impact**: HIGH

**Mitigation**:
1. Add verification checkpoints that catch failures immediately
2. Fail fast with clear error messages
3. Document manual workaround (/sync command)
4. Consider architectural change if problem persists

---

## Success Metrics

### Quantitative Metrics

1. **TODO.md Update Rate**: 100% (all workflow commands update TODO.md)
2. **State Synchronization**: 100% (TODO.md and state.json always match)
3. **Artifact Linking Rate**: 100% (all artifacts linked in TODO.md)
4. **Regression Rate**: 0% (no existing functionality broken)

### Qualitative Metrics

1. **User Visibility**: Users can see task status and artifacts in TODO.md
2. **Workflow Consistency**: TODO.md and state.json always synchronized
3. **Empirical Verification**: Fix validated with concrete test cases
4. **Root Cause Understanding**: Clear explanation of why problem occurred

### Validation

- [ ] Task 323 TODO.md updated correctly (baseline validation)
- [ ] New test tasks update TODO.md correctly
- [ ] All 4 workflow commands tested
- [ ] No discrepancies between TODO.md and state.json
- [ ] No regressions in existing functionality

---

## Comparison: Plan v5 vs Plan v6

| Aspect | Plan v5 (WRONG) | Plan v6 (CORRECTED) |
|--------|-----------------|---------------------|
| **Basis** | Reading task 321 summary | Empirical testing (task 323) |
| **Conclusion** | Task 321 fixed everything | Problem STILL EXISTS |
| **Remaining Work** | 0 hours (none) | TBD (pending investigation) |
| **Recommendation** | Mark task 320 COMPLETED | Wait for task 324 investigation |
| **Evidence** | Implementation summary | Workflow execution report |
| **Verification** | None (assumed) | Concrete test case (task 323) |
| **Lesson** | Don't trust summaries | Always test empirically |

---

## Task 323 Evidence Summary

### What Worked

1. ✅ Research artifact created (research-001.md, 699 lines, 23KB)
2. ✅ state.json updated correctly:
   - status: "not_started" → "researching" → "researched"
   - research_completed: "2026-01-05"
   - artifacts: ["...research-001.md"]
3. ✅ Git commit created (14abf52)
4. ✅ Atomic state.json updates (write to .tmp, then mv)

### What Failed

1. ✗ TODO.md NOT updated (still shows "[NOT STARTED]")
2. ✗ TODO.md NOT staged in git commit
3. ✗ Artifact links NOT added to TODO.md
4. ✗ Research completion date NOT added to TODO.md
5. ✗ No error logged for TODO.md update failure

### Discrepancy

| Field | state.json | TODO.md | Match? |
|-------|------------|---------|--------|
| Status | "researched" | "[NOT STARTED]" | ✗ NO |
| Research Completed | "2026-01-05" | (missing) | ✗ NO |
| Artifacts | ["...research-001.md"] | (missing) | ✗ NO |

### Git Commit Analysis

**Commit 14abf52** included:
- ✅ research-001.md (new file, +705 lines)
- ✅ state.json (modified, +2/-2 lines)
- ✗ TODO.md (NOT MODIFIED)

**Expected** commit should include:
- ✅ research-001.md
- ✅ state.json
- ✅ TODO.md (MISSING)

---

## Next Steps

### Immediate (Now)

1. ✅ Create task 324 for root cause investigation (DONE)
2. ✅ Acknowledge plan v5 was incorrect (DONE - this plan)
3. ✅ Document task 323 evidence (DONE - workflow execution report)
4. ⏳ Wait for task 324 investigation results (IN PROGRESS)

### After Task 324 Investigation

1. Update this plan with specific fix approach
2. Implement fix based on root cause
3. Test fix with task 323 as validation case
4. Test all 4 workflow commands
5. Document fix and close task 320

### Long-Term

1. Add regression tests to prevent recurrence
2. Improve empirical verification process
3. Never conclude tasks complete without testing
4. Document lessons learned

---

## References

### Task 321 Implementation

- **Summary**: `.opencode/specs/archive/321_fix_workflow_command_preflight_status_update_failures/summaries/implementation-summary-20260105.md`
- **Plan**: `.opencode/specs/archive/321_fix_workflow_command_preflight_status_update_failures/plans/implementation-003.md`
- **What it fixed**: Bugs #7, #3, #2 in status-sync-manager, enhanced subagents, created status-markers.md
- **What it didn't fix**: TODO.md update problem (proven by task 323 test)

### Task 323 Test Case

- **Workflow Report**: `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/artifacts/task-323-workflow-execution-report.md`
- **Evidence**: Appendix D (Discrepancy Analysis)
- **Git Commit**: 14abf52
- **Finding**: TODO.md not updated despite state.json being updated correctly

### Task 324 Investigation

- **Task Number**: 324
- **Purpose**: Investigate and prove root cause of persistent postflight failures
- **Status**: [NOT STARTED]
- **Blocking**: Task 320 implementation (this task)

### Research Reports

- **Research-001**: `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-001.md`
- **Research-002**: `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-002.md` (status-sync-manager bugs)
- **Research-003**: `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-003.md` (task 321 analysis)

---

## Summary

**Plan v5 was WRONG**: Claimed task 321 completed all work based on reading implementation summary without empirical verification.

**Plan v6 is CORRECTED**: Acknowledges the problem STILL EXISTS based on empirical testing (task 323).

**Key Lesson**: Never conclude a task is complete without testing. Always require empirical evidence.

**Current Status**: Waiting for task 324 investigation to identify root cause before proposing specific fixes.

**Estimated Effort**: TBD (pending task 324 investigation results)

**Next Step**: Wait for task 324 to complete, then update this plan with specific fix approach.

---

**Plan Created**: 2026-01-05  
**Plan Version**: 6  
**Estimated Total Effort**: TBD (pending task 324 investigation)  
**Complexity**: High  
**Research Integrated**: Yes (research-001.md, research-002.md, research-003.md, task 323 workflow report)  
**Revision Reason**: Plan v5 was INCORRECT - claimed task 321 completed all work based on reading implementation summary. Empirical testing (task 323) proves the problem STILL EXISTS. TODO.md is NOT being updated during postflight despite task 321's claimed fixes. This plan acknowledges the error and waits for task 324 investigation before proposing solutions.
