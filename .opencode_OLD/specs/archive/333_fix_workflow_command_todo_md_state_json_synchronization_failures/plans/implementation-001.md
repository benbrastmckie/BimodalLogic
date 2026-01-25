# Implementation Plan: Fix Workflow Command TODO.md/state.json Synchronization Failures

**Task**: 333 - Fix workflow command TODO.md/state.json synchronization failures  
**Status**: [PLANNED]  
**Created**: 2026-01-06  
**Estimated Effort**: 6-8 hours  
**Complexity**: Medium  
**Priority**: High  
**Language**: meta

---

## Metadata

- **Task Number**: 333
- **Plan Version**: 1
- **Research Integrated**: Yes
- **Research Reports**:
  - `.opencode/specs/333_fix_workflow_command_todo_md_state_json_synchronization_failures/reports/research-001.md`
- **Dependencies**: None
- **Blocking**: None
- **Related Tasks**: 329 (duplicate), 312 (abandoned predecessor)

---

## Overview

### Problem Statement

Workflow commands (`/research`, `/plan`, `/revise`, `/implement`) systematically fail to update TODO.md with status changes and artifact links, while successfully updating state.json. This creates persistent inconsistency between the two files, violating the architectural requirement that both files must be kept in sync via status-sync-manager's two-phase commit protocol.

**Failure Rate**: 100% of workflow command executions result in sync failures  
**User Impact**: Users see `[NOT STARTED]` in TODO.md when task is actually `[RESEARCHED]`, lose trust in system

### Root Cause

Commands use manual file manipulation (sed/awk) to update TODO.md instead of delegating to status-sync-manager. Manual sed/awk commands:
1. Fail silently when patterns don't match (exit code 0)
2. Provide no validation that changes occurred
3. Update TODO.md and state.json separately (not atomic)
4. Have no rollback mechanism on failure
5. Use complex regex patterns prone to errors

### Solution Approach

Systematically replace all manual file manipulation with status-sync-manager delegation in workflow command postflight stages. status-sync-manager provides:
- Atomic updates via two-phase commit (both files or neither)
- Pre-commit artifact validation
- Post-commit content verification
- Automatic rollback on failure
- Clear error messages with recovery recommendations

### Research Integration

This plan integrates findings from research-001.md:

**Key Findings**:
- Root cause confirmed: Manual sed/awk fails silently (100% failure rate)
- Elegant solution exists: status-sync-manager's two-phase commit protocol
- Integration pattern identified: Postflight delegation with validated_artifacts array
- Validation strategy: Multi-layer validation prevents phantom updates
- Git integration: Delegate to git-workflow-manager (non-critical failures)

**Critical Discovery**: researcher.md specification already implements the correct pattern with status-sync-manager delegation in both preflight and postflight stages. The issue is likely that agents are not following their specifications during execution, or command files are not invoking agents correctly.

### Scope

**In Scope**:
- Fix `/research` command (verify researcher.md delegation is followed)
- Fix `/plan` command (add status-sync-manager delegation to planner.md)
- Fix `/revise` command (add status-sync-manager delegation to task-reviser.md)
- Fix `/implement` command (add status-sync-manager delegation to implementer.md)
- Add validation before git commits (all commands)
- Add defense-in-depth verification (all commands)
- Integration testing for sync verification

**Out of Scope**:
- Prevention strategy (linting, documentation) - separate task
- Audit of other commands - separate task
- Performance optimization - not needed (status-sync-manager is fast)

### Constraints

- Must maintain backward compatibility (same command-line interface)
- Must not break existing user workflows
- Must preserve git-only rollback strategy (no backup files)
- Must handle git failures gracefully (non-critical)
- Must complete within 6-8 hours

### Definition of Done

- [ ] All 4 workflow commands delegate to status-sync-manager for status updates
- [ ] TODO.md and state.json updated atomically (both or neither)
- [ ] Artifact links added correctly to both files
- [ ] Status transitions work correctly (NOT STARTED → RESEARCHED → PLANNED → IMPLEMENTED)
- [ ] No manual sed/awk usage in any workflow command
- [ ] Validation added before git commits (all commands)
- [ ] Defense-in-depth verification added (all commands)
- [ ] Integration tests pass (sync verification)
- [ ] Git commits created only after successful status updates
- [ ] Documentation updated with changes

---

## Goals and Non-Goals

### Goals

1. **Eliminate Sync Failures**: Achieve 0% sync failure rate (down from 100%)
2. **Atomic Updates**: Ensure TODO.md and state.json always stay in sync
3. **Validation**: Prevent phantom updates (status change without artifact creation)
4. **Clear Errors**: Provide actionable error messages when failures occur
5. **Graceful Degradation**: Handle git failures without blocking workflow completion

### Non-Goals

1. **Prevention Strategy**: Linting and documentation updates (separate task)
2. **Audit Other Commands**: Review all commands for manual file manipulation (separate task)
3. **Performance Optimization**: status-sync-manager is already fast (~1-2 seconds)
4. **Backward Incompatibility**: No changes to command-line interface
5. **Backup Files**: Continue using git-only rollback strategy

---

## Risks and Mitigations

### Risk 1: Researcher Specification Not Being Followed

**Risk**: researcher.md already includes status-sync-manager delegation, but agents may not follow specification during execution.

**Likelihood**: High (explains persistent failures despite correct specification)  
**Impact**: High (fix won't work if agents don't follow specification)

**Mitigation**:
- Phase 1: Verify researcher agent execution follows specification
- Add execution logging to confirm delegation occurs
- Test with real research tasks before proceeding to other commands
- Add orchestrator validation to verify delegation occurred

### Risk 2: Breaking Changes to Existing Workflows

**Risk**: Changing workflow commands may break existing user workflows or scripts.

**Likelihood**: Low (changes are internal, user-facing API unchanged)  
**Impact**: Medium (users may need to update scripts)

**Mitigation**:
- Maintain same command-line interface
- Test with existing tasks before deployment
- Document any changes in release notes
- Keep rollback plan ready (git revert)

### Risk 3: Git Commit Failures

**Risk**: git-workflow-manager failures may cause user confusion.

**Likelihood**: Medium (git failures are common: nothing to commit, conflicts, etc.)  
**Impact**: Low (git failures are non-critical, user can commit manually)

**Mitigation**:
- Implement graceful git failure handling
- Provide clear instructions for manual commit
- Log git failures to errors.json for review
- Don't fail research/plan/implement on git failure

---

## Implementation Phases

### Phase 1: Fix /research Command (1.5-2 hours)

**Objective**: Verify researcher.md delegation is followed during execution

**Tasks**:
1. Review researcher.md specification (preflight and postflight stages)
2. Test researcher agent execution with logging enabled
3. Verify status-sync-manager delegation occurs in preflight (status → "researching")
4. Verify status-sync-manager delegation occurs in postflight (status → "researched")
5. Verify validated_artifacts array passed to status-sync-manager
6. Add validation: verify status-sync-manager return before git commit
7. Add defense-in-depth verification: confirm status actually updated
8. Test with existing research tasks (create test task, run /research, verify sync)
9. Update documentation if needed

**Acceptance Criteria**:
- [ ] researcher.md specification reviewed and confirmed correct
- [ ] Researcher agent execution follows specification (delegation occurs)
- [ ] Preflight updates status to "researching" atomically
- [ ] Postflight updates status to "researched" atomically
- [ ] Artifact links added to both TODO.md and state.json
- [ ] Validation prevents git commit if status update fails
- [ ] Defense-in-depth verification catches edge cases
- [ ] Test task syncs correctly (TODO.md and state.json match)

**Deliverables**:
- Verified researcher.md specification
- Execution logs confirming delegation
- Test results showing sync success
- Updated documentation (if needed)

**Status**: [NOT STARTED]

---

### Phase 2: Fix /plan Command (1.5-2 hours)

**Objective**: Add status-sync-manager delegation to planner.md

**Tasks**:
1. Review planner.md specification (current implementation)
2. Identify manual sed/awk usage in postflight stage
3. Remove manual file manipulation code
4. Add preflight delegation to status-sync-manager (status → "planning")
5. Add postflight delegation to status-sync-manager (status → "planned")
6. Pass plan_path and plan_metadata to status-sync-manager
7. Add validation: verify status-sync-manager return before git commit
8. Add defense-in-depth verification: confirm status actually updated
9. Test with existing planning tasks (create test task, run /plan, verify sync)
10. Update documentation

**Acceptance Criteria**:
- [ ] Manual sed/awk usage removed from planner.md
- [ ] Preflight updates status to "planning" atomically
- [ ] Postflight updates status to "planned" atomically
- [ ] Plan artifact linked in both TODO.md and state.json
- [ ] plan_path and plan_metadata stored correctly
- [ ] Validation prevents git commit if status update fails
- [ ] Defense-in-depth verification catches edge cases
- [ ] Test task syncs correctly (TODO.md and state.json match)

**Deliverables**:
- Updated planner.md specification
- Test results showing sync success
- Updated documentation

**Status**: [NOT STARTED]

---

### Phase 3: Fix /revise Command (1.5-2 hours)

**Objective**: Add status-sync-manager delegation to task-reviser.md and planner.md (revision mode)

**Tasks**:
1. Review task-reviser.md specification (task-only revision mode)
2. Review planner.md specification (plan revision mode)
3. Identify manual sed/awk usage in both files
4. Remove manual file manipulation code
5. Add preflight delegation to status-sync-manager (status → "revising")
6. Add postflight delegation to status-sync-manager (status → "revised")
7. Pass revised plan_path and plan_version to status-sync-manager (if plan revision)
8. Add validation: verify status-sync-manager return before git commit
9. Add defense-in-depth verification: confirm status actually updated
10. Test both revision modes (task-only and plan revision)
11. Update documentation

**Acceptance Criteria**:
- [ ] Manual sed/awk usage removed from task-reviser.md and planner.md
- [ ] Preflight updates status to "revising" atomically
- [ ] Postflight updates status to "revised" atomically
- [ ] Task-only revision updates description/priority/effort correctly
- [ ] Plan revision creates new plan version and links correctly
- [ ] plan_version incremented correctly
- [ ] Validation prevents git commit if status update fails
- [ ] Defense-in-depth verification catches edge cases
- [ ] Test tasks sync correctly (both modes)

**Deliverables**:
- Updated task-reviser.md specification
- Updated planner.md specification (revision mode)
- Test results showing sync success (both modes)
- Updated documentation

**Status**: [NOT STARTED]

---

### Phase 4: Fix /implement Command (1.5-2 hours)

**Objective**: Add status-sync-manager delegation to implementer.md

**Tasks**:
1. Review implementer.md specification (current implementation)
2. Identify manual sed/awk usage in postflight stage
3. Remove manual file manipulation code
4. Add preflight delegation to status-sync-manager (status → "implementing")
5. Add postflight delegation to status-sync-manager (status → "completed")
6. Pass implementation artifacts to status-sync-manager
7. Add validation: verify status-sync-manager return before git commit
8. Add defense-in-depth verification: confirm status actually updated
9. Test with existing implementation tasks (create test task, run /implement, verify sync)
10. Update documentation

**Acceptance Criteria**:
- [ ] Manual sed/awk usage removed from implementer.md
- [ ] Preflight updates status to "implementing" atomically
- [ ] Postflight updates status to "completed" atomically
- [ ] Implementation artifacts linked in both TODO.md and state.json
- [ ] Validation prevents git commit if status update fails
- [ ] Defense-in-depth verification catches edge cases
- [ ] Test task syncs correctly (TODO.md and state.json match)

**Deliverables**:
- Updated implementer.md specification
- Test results showing sync success
- Updated documentation

**Status**: [NOT STARTED]

---

### Phase 5: Integration Testing and Validation (1-2 hours)

**Objective**: Verify all workflow commands work together and sync correctly

**Tasks**:
1. Create integration test suite (`.opencode/specs/333_*/tests/sync-test.sh`)
2. Test 1: /research command sync (create task, research, verify sync)
3. Test 2: /plan command sync (create task, plan, verify sync)
4. Test 3: /revise command sync (create task, revise, verify sync - both modes)
5. Test 4: /implement command sync (create task, implement, verify sync)
6. Test 5: Full workflow sequence (research → plan → implement, verify sync throughout)
7. Test 6: Verify no manual file manipulation (grep for sed/awk usage)
8. Test 7: Verify status-sync-manager delegation (grep for delegation calls)
9. Run all tests and verify 100% pass rate
10. Document test results

**Acceptance Criteria**:
- [ ] Integration test suite created
- [ ] All individual command tests pass (Tests 1-4)
- [ ] Full workflow sequence test passes (Test 5)
- [ ] No manual file manipulation detected (Test 6)
- [ ] All commands delegate to status-sync-manager (Test 7)
- [ ] 100% test pass rate
- [ ] Test results documented

**Deliverables**:
- Integration test suite (`.opencode/specs/333_*/tests/sync-test.sh`)
- Test execution report
- Documentation of test results

**Status**: [NOT STARTED]

---

## Testing and Validation

### Unit Testing

**Test Level**: Individual command testing

**Test Cases**:

1. **Test /research Sync**:
   - Given: Task 999 exists with status "not_started"
   - When: Run /research 999
   - Then: Research report created
   - And: TODO.md status updated to [RESEARCHED]
   - And: TODO.md has artifact link to research report
   - And: state.json status updated to "researched"
   - And: state.json has artifact path
   - And: Git commit created

2. **Test /plan Sync**:
   - Given: Task 999 exists with status "researched"
   - When: Run /plan 999
   - Then: Implementation plan created
   - And: TODO.md status updated to [PLANNED]
   - And: TODO.md has artifact link to plan
   - And: state.json status updated to "planned"
   - And: state.json has plan_path and plan_metadata
   - And: Git commit created

3. **Test /revise Sync (Task-Only)**:
   - Given: Task 999 exists with status "not_started" (no plan)
   - When: Run /revise 999 "Update description"
   - Then: TODO.md description updated
   - And: TODO.md status updated to [REVISED]
   - And: state.json description updated
   - And: state.json status updated to "revised"
   - And: Git commit created

4. **Test /revise Sync (Plan Revision)**:
   - Given: Task 999 exists with status "planned" (plan exists)
   - When: Run /revise 999 "Update plan"
   - Then: New plan version created (implementation-002.md)
   - And: TODO.md plan link updated to new version
   - And: TODO.md status updated to [REVISED]
   - And: state.json plan_path updated to new version
   - And: state.json plan_version incremented
   - And: state.json status updated to "revised"
   - And: Git commit created

5. **Test /implement Sync**:
   - Given: Task 999 exists with status "planned"
   - When: Run /implement 999
   - Then: Implementation artifacts created
   - And: TODO.md status updated to [COMPLETED]
   - And: TODO.md has artifact links
   - And: state.json status updated to "completed"
   - And: state.json has artifact paths
   - And: Git commit created

### Integration Testing

**Test Level**: Multi-command workflow testing

**Test Cases**:

1. **Test Full Workflow Sequence**:
   - Given: Task 999 exists with status "not_started"
   - When: Run /research 999, then /plan 999, then /implement 999
   - Then: All artifacts created
   - And: TODO.md status progresses: [NOT STARTED] → [RESEARCHED] → [PLANNED] → [COMPLETED]
   - And: TODO.md has all artifact links
   - And: state.json status progresses correctly
   - And: state.json has all artifacts
   - And: Files stay in sync throughout

2. **Test Rollback on Failure**:
   - Given: Task 999 exists
   - When: Run /research 999 with invalid data (trigger failure)
   - Then: status-sync-manager returns status="failed"
   - And: TODO.md unchanged
   - And: state.json unchanged
   - And: No git commit created

3. **Test Git Failure Handling**:
   - Given: Task 999 exists
   - When: Run /research 999 with git in broken state
   - Then: Research report created
   - And: TODO.md and state.json updated
   - And: Git commit fails (non-critical)
   - And: Warning logged to errors.json
   - And: Command returns status="completed" with warning

### Regression Testing

**Test Level**: Prevent future regressions

**Test Cases**:

1. **Test No Manual File Manipulation**:
   - Given: All workflow command files
   - When: Grep for sed/awk usage on TODO.md
   - Then: No matches found (except in comments/documentation)

2. **Test status-sync-manager Delegation**:
   - Given: All workflow command files
   - When: Check for status-sync-manager delegation in postflight
   - Then: All commands delegate to status-sync-manager
   - And: All commands validate return before git commit

### Validation Checklist

**Pre-Deployment**:
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] All regression tests pass
- [ ] No manual file manipulation in workflow commands
- [ ] All commands delegate to status-sync-manager
- [ ] Validation added before git commits
- [ ] Defense-in-depth verification added
- [ ] Documentation updated

**Post-Deployment**:
- [ ] Monitor sync failure rate (should be 0%)
- [ ] Monitor git commit failure rate
- [ ] Monitor command execution time
- [ ] Collect user feedback
- [ ] Address any issues

---

## Artifacts and Outputs

### Primary Artifacts

1. **Updated Subagent Specifications**:
   - `.opencode/agent/subagents/researcher.md` (verified, may need minor updates)
   - `.opencode/agent/subagents/planner.md` (updated with delegation)
   - `.opencode/agent/subagents/task-reviser.md` (updated with delegation)
   - `.opencode/agent/subagents/implementer.md` (updated with delegation)

2. **Integration Test Suite**:
   - `.opencode/specs/333_*/tests/sync-test.sh` (new)

3. **Test Execution Report**:
   - `.opencode/specs/333_*/tests/test-results.md` (new)

4. **Implementation Summary**:
   - `.opencode/specs/333_*/summaries/implementation-summary-20260106.md` (new)

### Documentation Updates

1. **Command Documentation**:
   - `.opencode/command/research.md` (verify delegation documented)
   - `.opencode/command/plan.md` (update with delegation)
   - `.opencode/command/revise.md` (update with delegation)
   - `.opencode/command/implement.md` (update with delegation)

2. **Release Notes**:
   - Document sync failure fix
   - Document validation improvements
   - Document any breaking changes (none expected)

### Git Commits

1. **Phase 1**: "task 333: fix /research command sync (verify delegation)"
2. **Phase 2**: "task 333: fix /plan command sync (add delegation)"
3. **Phase 3**: "task 333: fix /revise command sync (add delegation)"
4. **Phase 4**: "task 333: fix /implement command sync (add delegation)"
5. **Phase 5**: "task 333: add integration tests for sync verification"

---

## Rollback/Contingency

### Rollback Plan

**If Fix Fails**:

1. **Immediate Rollback** (git revert):
   ```bash
   # Revert all commits from this task
   git revert <commit-hash-phase-5>
   git revert <commit-hash-phase-4>
   git revert <commit-hash-phase-3>
   git revert <commit-hash-phase-2>
   git revert <commit-hash-phase-1>
   ```

2. **Restore Previous Behavior**:
   - Manual file manipulation restored (broken but familiar)
   - Users continue manual TODO.md fixes
   - Document rollback reason in errors.json

3. **Root Cause Analysis**:
   - Investigate why fix failed
   - Document findings
   - Create new task for alternative approach

### Contingency Plans

**Contingency 1: Researcher Delegation Not Working**

**Trigger**: Phase 1 testing reveals researcher agent doesn't follow specification

**Action**:
1. Investigate why agent bypasses delegation
2. Check context loading (verify researcher.md loaded)
3. Check orchestrator routing (verify researcher invoked correctly)
4. Add explicit delegation enforcement in command file
5. If unfixable: Escalate to architectural review

**Contingency 2: Performance Degradation**

**Trigger**: Command execution time increases significantly (>5 seconds)

**Action**:
1. Profile status-sync-manager execution
2. Optimize slow operations (file I/O, validation)
3. Consider async status updates if needed
4. If unfixable: Document performance trade-off, proceed if acceptable

**Contingency 3: Git Failures Increase**

**Trigger**: Git commit failure rate >50%

**Action**:
1. Investigate git failure causes
2. Improve git-workflow-manager error handling
3. Add pre-commit validation (check git status)
4. Document manual commit procedure
5. If unfixable: Accept non-critical failures, improve error messages

### Recovery Procedures

**If Sync Failures Persist**:

1. **Manual Sync Script**:
   ```bash
   # Sync TODO.md and state.json for task
   ./sync-task.sh <task_number>
   ```

2. **Audit Script**:
   ```bash
   # Find tasks with sync issues
   ./audit-sync.sh
   ```

3. **Bulk Fix Script**:
   ```bash
   # Fix all sync issues
   ./fix-all-sync.sh
   ```

---

## Success Metrics

### Quantitative Metrics

**Before Fix** (Current State):
- Sync Failures: ~100% of workflow command executions
- Manual Fixes Required: ~100% of workflow command executions
- False Commit Messages: ~50% of workflow commits
- Time Wasted: ~5-10 minutes per task (manual TODO.md fixes)

**After Fix** (Target State):
- Sync Failures: 0% (atomic updates via status-sync-manager)
- Manual Fixes Required: 0% (automatic synchronization)
- False Commit Messages: 0% (validation before commit)
- Time Saved: ~5-10 minutes per task

**Success Criteria**:
- Sync failure rate: 0% (down from 100%)
- Test pass rate: 100%
- Command execution time: <5 seconds (acceptable overhead)
- Git commit failure rate: <20% (non-critical)

### Qualitative Metrics

**User Experience**:
- TODO.md and state.json always in sync
- No manual fixes required
- Clear error messages when failures occur
- Trust in system restored

**Code Quality**:
- No manual file manipulation (sed/awk)
- Consistent delegation pattern across all commands
- Comprehensive validation and error handling
- Well-tested and documented

**Maintainability**:
- Easy to add new workflow commands
- Clear best practices documented
- Regression tests prevent future issues
- Monitoring in place for early detection

---

## Dependencies and Prerequisites

### Technical Dependencies

1. **status-sync-manager** (`.opencode/agent/subagents/status-sync-manager.md`):
   - Must support `update_status` operation
   - Must support `validated_artifacts` array
   - Must implement two-phase commit protocol
   - Status: ✅ Available and working

2. **git-workflow-manager** (`.opencode/agent/subagents/git-workflow-manager.md`):
   - Must support scoped commits
   - Must handle failures gracefully
   - Status: ✅ Available and working

3. **Workflow Commands**:
   - `/research` command (`.opencode/command/research.md`)
   - `/plan` command (`.opencode/command/plan.md`)
   - `/revise` command (`.opencode/command/revise.md`)
   - `/implement` command (`.opencode/command/implement.md`)
   - Status: ✅ Available (need updates)

4. **Subagent Specifications**:
   - `researcher.md` (`.opencode/agent/subagents/researcher.md`)
   - `planner.md` (`.opencode/agent/subagents/planner.md`)
   - `task-reviser.md` (`.opencode/agent/subagents/task-reviser.md`)
   - `implementer.md` (`.opencode/agent/subagents/implementer.md`)
   - Status: ✅ Available (need updates)

### Knowledge Prerequisites

1. **Two-Phase Commit Protocol**: Understanding of atomic update mechanism
2. **status-sync-manager API**: Knowledge of delegation context format
3. **Artifact Validation**: Understanding of validation protocol
4. **Git Workflow**: Knowledge of git-workflow-manager integration
5. **Testing Strategy**: Understanding of integration testing approach

### Resource Prerequisites

1. **Development Environment**: Access to .opencode system
2. **Test Environment**: Ability to create test tasks
3. **Git Repository**: Clean working directory for testing
4. **Time**: 6-8 hours for implementation and testing

---

## Notes and Considerations

### Critical Discovery from Research

The researcher.md specification **already implements the correct pattern** with status-sync-manager delegation in both preflight and postflight stages. This suggests the issue is not in the specification but in execution:

1. **Possible Causes**:
   - Agents not reading their specifications correctly
   - Context loading issues (specification not loaded)
   - Orchestrator routing issues (wrong agent invoked)
   - Specification being overridden by command file

2. **Investigation Required**:
   - Phase 1 must verify researcher agent execution follows specification
   - Add logging to confirm delegation actually occurs
   - Test with real research tasks before proceeding

3. **Implications**:
   - Fix may be simpler than expected (verify execution, not rewrite spec)
   - Or more complex (architectural issue with agent execution)
   - Phase 1 results will determine approach for other phases

### Validation Strategy

Multi-layer validation prevents phantom updates:

1. **Layer 1: Pre-Commit Artifact Validation** (status-sync-manager):
   - Verify artifacts exist on disk
   - Verify artifacts are non-empty (size > 0)
   - Abort if validation fails

2. **Layer 2: Post-Commit Content Verification** (status-sync-manager):
   - Verify status marker updated in TODO.md
   - Verify status updated in state.json
   - Verify artifact links added

3. **Layer 3: Defense in Depth** (subagent):
   - Read state.json to verify status
   - Read TODO.md to verify artifact link
   - Abort git commit if verification fails

### Git Integration

Git failures are **non-critical** and should not block workflow completion:

1. **Graceful Failure Handling**:
   - Log git failures to errors.json
   - Include warning in return
   - Return status="completed" (not "failed")
   - Provide manual commit instructions

2. **Common Git Failures**:
   - Nothing to commit (already committed)
   - Merge conflicts (concurrent changes)
   - Detached HEAD (git state issue)
   - Permission errors (file system issue)

3. **Recovery**:
   - User can commit manually
   - Git history preserved
   - No data loss

### Performance Considerations

status-sync-manager delegation adds ~1-2 seconds overhead:

1. **Acceptable Trade-Off**:
   - Atomic updates worth the overhead
   - 1-2 seconds negligible for workflow commands
   - Users already wait for research/plan/implement work

2. **Optimization Not Needed**:
   - status-sync-manager is already fast
   - File I/O is minimal (2 files)
   - Validation is lightweight

3. **Monitoring**:
   - Track command execution time
   - Alert if >5 seconds (investigate)

---

## Approval and Sign-Off

**Plan Author**: Claude (AI Assistant)  
**Plan Date**: 2026-01-06  
**Plan Version**: 1.0  
**Plan Status**: [PLANNED]

**Reviewed By**: (To be filled)  
**Approved By**: (To be filled)  
**Approval Date**: (To be filled)

---

**End of Implementation Plan**
