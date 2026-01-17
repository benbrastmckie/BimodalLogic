# Implementation Plan: Fix Workflow Commands to Update Status at Beginning and End

**Task**: 275 - Fix workflow commands to update status at beginning and end in both TODO.md and state.json  
**Plan Version**: 001  
**Created**: 2026-01-03  
**Status**: [NOT STARTED]  
**Estimated Effort**: 8 hours  
**Complexity**: Medium  
**Language**: markdown  
**Research Integrated**: Yes (research-001.md)

---

## Metadata

**Task Number**: 275  
**Task Title**: Fix workflow commands to update status at beginning and end in both TODO.md and state.json  
**Priority**: High  
**Dependencies**: None  
**Blocking**: None  
**Research Artifacts**:
- `specs/275_fix_workflow_status_updates/reports/research-001.md`

**Key Research Findings**:
1. Researcher subagent ALREADY implements two-phase status updates correctly
2. Planner and implementer subagents need verification for preflight status updates
3. Status-sync-manager fully supports all required status transitions
4. Command documentation is ambiguous about status update ownership
5. Two-phase pattern not documented in command lifecycle documentation

---

## Overview

### Problem

The task description states that workflow commands only update status at the end, not at the beginning. However, research reveals that the researcher subagent already implements the correct two-phase pattern:
- **Preflight**: Update to [RESEARCHING] before starting work
- **Postflight**: Update to [RESEARCHED] after completing work

The planner and implementer subagents show postflight updates in documentation but preflight updates were not found in the initial excerpts (lines 1-250). This plan focuses on:
1. Verifying whether preflight updates exist in planner and implementer
2. Adding preflight updates if missing
3. Updating documentation to clarify the two-phase pattern

### Scope

**In Scope**:
- Verify planner.md and implementer.md for preflight status updates
- Add preflight status updates if missing (following researcher pattern)
- Update command documentation to clarify status update ownership
- Document two-phase pattern in command lifecycle documentation
- Test status updates with sample tasks

**Out of Scope**:
- Modifying status-sync-manager (already correct)
- Changing orchestrator routing logic
- Implementing new status markers (all markers already defined)

### Constraints

- Must maintain atomic updates across TODO.md and state.json
- Must follow state-management.md status transition rules
- Must preserve existing two-phase commit protocol in status-sync-manager
- Must not break existing workflows
- Must follow researcher.md pattern exactly for consistency

### Definition of Done

- [ ] Planner and implementer preflight status updates verified or added
- [ ] All workflow subagents implement two-phase status update pattern
- [ ] Command documentation clarifies status update ownership
- [ ] Two-phase pattern documented in command lifecycle documentation
- [ ] Status updates tested with sample tasks
- [ ] All acceptance criteria met
- [ ] Git commit created with changes

---

## Goals and Non-Goals

### Goals

1. **Ensure Consistency**: All workflow subagents (researcher, planner, implementer) follow the same two-phase status update pattern
2. **Improve Documentation**: Clearly document status update ownership and the two-phase pattern
3. **Maintain Atomicity**: Preserve atomic updates across TODO.md and state.json via status-sync-manager
4. **Follow Standards**: Adhere to state-management.md status transition rules

### Non-Goals

1. **Not changing status-sync-manager**: Already implements two-phase commit correctly
2. **Not adding new status markers**: All markers already defined in state-management.md
3. **Not modifying orchestrator**: Orchestrator delegates to subagents correctly
4. **Not implementing validation**: Orchestrator validation is out of scope (low priority)

---

## Risks and Mitigations

### Risk 1: Preflight Updates May Already Exist

**Risk**: Planner and implementer may already have preflight status updates beyond line 250.  
**Impact**: Medium - Implementing duplicate logic would be wasteful.  
**Mitigation**: Thoroughly verify current implementation in Phase 1 before making changes.  
**Likelihood**: Medium

### Risk 2: Breaking Existing Workflows

**Risk**: Adding preflight status updates could break existing workflows.  
**Impact**: High - Could cause workflow failures.  
**Mitigation**: Test changes with sample tasks before committing. Verify status-sync-manager handles transitions.  
**Likelihood**: Low (status-sync-manager already supports all transitions)

### Risk 3: Status Update Failures Could Block Work

**Risk**: If preflight status update fails, work is aborted.  
**Impact**: Medium - Users cannot proceed with work.  
**Mitigation**: Ensure status-sync-manager is robust. Provide clear error messages with recovery instructions.  
**Likelihood**: Low (status-sync-manager uses two-phase commit with rollback)

### Risk 4: Documentation Drift

**Risk**: Documentation updates may not stay synchronized with code changes.  
**Impact**: Low - Confusion for developers and users.  
**Mitigation**: Update documentation in same commit as code changes. Include documentation in acceptance criteria.  
**Likelihood**: Medium

---

## Implementation Phases

### Phase 1: Verify Planner and Implementer Preflight Status Updates [NOT STARTED]

**Goal**: Determine if planner.md and implementer.md already have preflight status updates.

**Tasks**:
1. Read full planner.md file (all lines, not just 1-250)
2. Search for "planning" or "PLANNING" status update before Step 7
3. Read full implementer.md file (all lines, not just 1-250)
4. Search for "implementing" or "IMPLEMENTING" status update before Step 7
5. Document findings:
   - If preflight updates exist: Note location and skip Phase 2
   - If preflight updates missing: Proceed to Phase 2
6. Create verification report documenting findings

**Acceptance Criteria**:
- [ ] Full planner.md file read and analyzed
- [ ] Full implementer.md file read and analyzed
- [ ] Preflight status update presence/absence documented
- [ ] Verification report created

**Estimated Effort**: 1 hour

**Files to Read**:
- `.opencode/agent/subagents/planner.md` (full file)
- `.opencode/agent/subagents/implementer.md` (full file)

**Output**: Verification report documenting whether preflight updates exist

---

### Phase 2: Add Preflight Status Updates to Planner and Implementer [NOT STARTED]

**Goal**: Add preflight status updates to planner and implementer if missing (conditional on Phase 1 findings).

**Tasks**:
1. If planner.md missing preflight update:
   a. Add `<step_0_preflight>` section to planner.md
   b. Follow researcher.md pattern exactly
   c. Update status to [PLANNING] before Step 1
   d. Invoke status-sync-manager with new_status: "planning"
   e. Validate status update succeeded
   f. Abort if status update fails
2. If implementer.md missing preflight update:
   a. Add `<step_0_preflight>` section to implementer.md
   b. Follow researcher.md pattern exactly
   c. Update status to [IMPLEMENTING] before Step 1
   d. Invoke status-sync-manager with new_status: "implementing"
   e. Validate status update succeeded
   f. Abort if status update fails
3. Ensure consistency with researcher.md pattern
4. Validate XML structure and formatting

**Acceptance Criteria**:
- [ ] Planner.md has preflight status update to [PLANNING] (if missing)
- [ ] Implementer.md has preflight status update to [IMPLEMENTING] (if missing)
- [ ] Preflight updates follow researcher.md pattern exactly
- [ ] Status-sync-manager invoked with correct parameters
- [ ] XML structure and formatting validated

**Estimated Effort**: 2 hours

**Files to Modify** (conditional):
- `.opencode/agent/subagents/planner.md`
- `.opencode/agent/subagents/implementer.md`

**Pattern to Follow**:
```markdown
<step_0_preflight>
  <action>Preflight: Validate task and update status to [PLANNING/IMPLEMENTING]</action>
  <process>
    1. Parse task_number from delegation context or prompt string
    2. Validate task exists in TODO.md
    3. Verify task is in valid starting status
    4. Generate timestamp: $(date -I)
    5. Invoke status-sync-manager to mark [PLANNING/IMPLEMENTING]:
       a. Prepare delegation context:
          - task_number: {number}
          - new_status: "planning" | "implementing"
          - timestamp: {date}
          - session_id: {session_id}
          - delegation_depth: {depth + 1}
          - delegation_path: [...delegation_path, "status-sync-manager"]
       b. Invoke status-sync-manager with timeout (60s)
       c. Validate return status == "completed"
       d. Verify files_updated includes ["TODO.md", "state.json"]
       e. If status update fails: Abort with error and recommendation
    6. Log preflight completion
  </process>
  <validation>
    - Task exists and is valid for planning/implementation
    - Status updated to [PLANNING/IMPLEMENTING] atomically
    - Timestamp added to TODO.md and state.json
  </validation>
  <error_handling>
    If status update fails:
      Return status "failed" with error:
      - type: "status_update_failed"
      - message: "Failed to update status to [PLANNING/IMPLEMENTING]"
      - recommendation: "Check status-sync-manager logs and retry"
  </error_handling>
  <output>Status updated to [PLANNING/IMPLEMENTING]</output>
</step_0_preflight>
```

---

### Phase 3: Update Command Documentation [NOT STARTED]

**Goal**: Update command files to clarify that subagents handle BOTH beginning and end status updates.

**Tasks**:
1. Update `.opencode/command/research.md`:
   a. Update "Researcher subagent handles" section
   b. Add explicit bullet: "Update status to [RESEARCHING] at beginning (preflight)"
   c. Add explicit bullet: "Update status to [RESEARCHED] at end (postflight)"
2. Update `.opencode/command/plan.md`:
   a. Update "Planner Responsibilities" section
   b. Add explicit bullet: "Update status to [PLANNING] at beginning (preflight)"
   c. Add explicit bullet: "Update status to [PLANNED] at end (postflight)"
3. Update `.opencode/command/implement.md`:
   a. Update "Implementer Responsibilities" section
   b. Add explicit bullet: "Update status to [IMPLEMENTING] at beginning (preflight)"
   c. Add explicit bullet: "Update status to [COMPLETED] at end (postflight)"
4. Update `.opencode/command/revise.md`:
   a. Update "Planner Responsibilities" section (revise uses planner)
   b. Add explicit bullet: "Update status to [REVISING] at beginning (preflight)"
   c. Add explicit bullet: "Update status to [REVISED] at end (postflight)"
5. Ensure consistency across all command files

**Acceptance Criteria**:
- [ ] research.md clarifies two-phase status updates
- [ ] plan.md clarifies two-phase status updates
- [ ] implement.md clarifies two-phase status updates
- [ ] revise.md clarifies two-phase status updates
- [ ] All command files use consistent language
- [ ] Documentation is clear and unambiguous

**Estimated Effort**: 1.5 hours

**Files to Modify**:
- `.opencode/command/research.md`
- `.opencode/command/plan.md`
- `.opencode/command/implement.md`
- `.opencode/command/revise.md`

**Example Update** (for plan.md):
```markdown
**Planner Responsibilities:**
- Update status to [PLANNING] at beginning (preflight)
- Harvest research artifacts from TODO.md links
- Create phased implementation plan
- Follow plan.md template standard
- Update status to [PLANNED] at end (postflight)
- Create git commit via git-workflow-manager
```

---

### Phase 4: Document Two-Phase Status Update Pattern [NOT STARTED]

**Goal**: Document the two-phase status update pattern in command lifecycle documentation.

**Tasks**:
1. Check if `.opencode/context/core/workflows/command-lifecycle.md` exists
2. If exists: Update with two-phase pattern section
3. If not exists: Create command-lifecycle.md with two-phase pattern documentation
4. Add section: "Two-Phase Status Update Pattern"
5. Document pattern with examples from researcher.md
6. Include benefits and rationale
7. Reference from all command files
8. Add cross-references to state-management.md

**Acceptance Criteria**:
- [ ] command-lifecycle.md exists with two-phase pattern documentation
- [ ] Pattern documented with clear examples
- [ ] Benefits and rationale explained
- [ ] Cross-references to state-management.md added
- [ ] Command files reference command-lifecycle.md

**Estimated Effort**: 1.5 hours

**Files to Create/Modify**:
- `.opencode/context/core/workflows/command-lifecycle.md` (create or update)

**Content Structure**:
```markdown
## Two-Phase Status Update Pattern

All workflow subagents (researcher, planner, implementer) follow a two-phase status update pattern:

### Phase 1: Preflight Status Update
- When: Before executing main workflow
- Purpose: Signal that work has started
- Status Markers: [RESEARCHING], [PLANNING], [REVISING], [IMPLEMENTING]
- Process: Invoke status-sync-manager, validate, abort if fails

### Phase 2: Postflight Status Update
- When: After completing main workflow
- Purpose: Signal that work has completed
- Status Markers: [RESEARCHED], [PLANNED], [REVISED], [COMPLETED]
- Process: Invoke status-sync-manager, validate, log warning if fails

### Benefits
- User visibility into work progress
- Atomic updates across TODO.md and state.json
- Error recovery via preflight validation
- Consistent pattern across all workflow commands
```

---

### Phase 5: Test Status Updates with Sample Tasks [NOT STARTED]

**Goal**: Verify that status updates work correctly with sample tasks.

**Tasks**:
1. Create test task in TODO.md (or use existing task)
2. Test `/research` command:
   a. Verify status changes: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]
   b. Verify timestamps added to TODO.md and state.json
   c. Verify atomic updates (both files updated or neither)
3. Test `/plan` command:
   a. Verify status changes: [RESEARCHED] → [PLANNING] → [PLANNED]
   b. Verify timestamps added to TODO.md and state.json
   c. Verify atomic updates
4. Test `/implement` command:
   a. Verify status changes: [PLANNED] → [IMPLEMENTING] → [COMPLETED]
   b. Verify timestamps added to TODO.md and state.json
   c. Verify atomic updates
5. Test error cases:
   a. Verify preflight abort if status update fails
   b. Verify rollback if postflight fails
6. Document test results

**Acceptance Criteria**:
- [ ] `/research` status updates tested and verified
- [ ] `/plan` status updates tested and verified
- [ ] `/implement` status updates tested and verified
- [ ] Error cases tested and verified
- [ ] All status transitions follow state-management.md rules
- [ ] Atomic updates verified (both files or neither)
- [ ] Test results documented

**Estimated Effort**: 1.5 hours

**Test Cases**:
1. Normal flow: [NOT STARTED] → [RESEARCHING] → [RESEARCHED] → [PLANNING] → [PLANNED] → [IMPLEMENTING] → [COMPLETED]
2. Error case: Preflight status update fails → Work aborted
3. Error case: Postflight status update fails → Warning logged
4. Atomic update: Both TODO.md and state.json updated together

**Output**: Test results document

---

### Phase 6: Create Git Commit and Update Task Status [NOT STARTED]

**Goal**: Create git commit with all changes and update task status to [COMPLETED].

**Tasks**:
1. Review all changes made in previous phases
2. Verify all acceptance criteria met
3. Stage all modified files:
   - `.opencode/agent/subagents/planner.md` (if modified)
   - `.opencode/agent/subagents/implementer.md` (if modified)
   - `.opencode/command/research.md`
   - `.opencode/command/plan.md`
   - `.opencode/command/implement.md`
   - `.opencode/command/revise.md`
   - `.opencode/context/core/workflows/command-lifecycle.md`
   - `specs/TODO.md`
   - `specs/state.json`
4. Create git commit with descriptive message
5. Update task 275 status to [COMPLETED] in TODO.md and state.json
6. Add completion timestamp
7. Link implementation summary in TODO.md

**Acceptance Criteria**:
- [ ] All modified files staged
- [ ] Git commit created with descriptive message
- [ ] Task 275 status updated to [COMPLETED]
- [ ] Completion timestamp added
- [ ] Implementation summary linked in TODO.md

**Estimated Effort**: 0.5 hours

**Git Commit Message Template**:
```
task 275: fix workflow commands to update status at beginning and end

- Added preflight status updates to planner and implementer (if missing)
- Updated command documentation to clarify two-phase status updates
- Documented two-phase pattern in command-lifecycle.md
- Tested status updates with sample tasks
- All workflow subagents now follow consistent two-phase pattern
```

---

## Testing and Validation

### Unit Testing

**Not applicable** - This task involves documentation and configuration changes, not code logic.

### Integration Testing

**Test Cases**:
1. **Test Case 1: Research Command Status Updates**
   - Input: `/research {task_number}`
   - Expected: Status changes [NOT STARTED] → [RESEARCHING] → [RESEARCHED]
   - Validation: Check TODO.md and state.json for status and timestamps

2. **Test Case 2: Plan Command Status Updates**
   - Input: `/plan {task_number}`
   - Expected: Status changes [RESEARCHED] → [PLANNING] → [PLANNED]
   - Validation: Check TODO.md and state.json for status and timestamps

3. **Test Case 3: Implement Command Status Updates**
   - Input: `/implement {task_number}`
   - Expected: Status changes [PLANNED] → [IMPLEMENTING] → [COMPLETED]
   - Validation: Check TODO.md and state.json for status and timestamps

4. **Test Case 4: Atomic Updates**
   - Input: Any workflow command
   - Expected: Both TODO.md and state.json updated together
   - Validation: Verify no partial updates (both files or neither)

5. **Test Case 5: Preflight Failure**
   - Input: Workflow command with invalid task
   - Expected: Preflight status update fails, work aborted
   - Validation: Verify error message and no work performed

### Validation Criteria

- [ ] All status transitions follow state-management.md rules
- [ ] Atomic updates verified across TODO.md and state.json
- [ ] Preflight and postflight status updates occur for all workflow commands
- [ ] Error handling works correctly (abort on preflight failure)
- [ ] Documentation is clear and accurate

---

## Artifacts and Outputs

### Primary Artifacts

1. **Modified Subagent Files** (conditional on Phase 1 findings):
   - `.opencode/agent/subagents/planner.md` (if preflight update missing)
   - `.opencode/agent/subagents/implementer.md` (if preflight update missing)

2. **Modified Command Files**:
   - `.opencode/command/research.md`
   - `.opencode/command/plan.md`
   - `.opencode/command/implement.md`
   - `.opencode/command/revise.md`

3. **New/Modified Context Files**:
   - `.opencode/context/core/workflows/command-lifecycle.md`

4. **Updated Tracking Files**:
   - `specs/TODO.md` (task 275 status updated to [COMPLETED])
   - `specs/state.json` (task 275 status updated to completed)

### Supporting Artifacts

1. **Verification Report** (Phase 1):
   - Documents whether preflight updates exist in planner and implementer
   - Location: `specs/275_fix_workflow_status_updates/reports/verification-001.md`

2. **Test Results Document** (Phase 5):
   - Documents test results for status updates
   - Location: `specs/275_fix_workflow_status_updates/reports/test-results-001.md`

3. **Implementation Summary**:
   - Brief summary of changes made (<100 tokens)
   - Location: `specs/275_fix_workflow_status_updates/summaries/implementation-summary-20260103.md`

---

## Rollback/Contingency

### Rollback Plan

If implementation causes issues:

1. **Identify Issue**: Determine which phase caused the problem
2. **Revert Git Commit**: Use `git revert` to undo changes
3. **Restore Files**: Restore modified files from git history
4. **Update Status**: Update task 275 status to [BLOCKED] with blocking reason
5. **Document Issue**: Document the issue and root cause
6. **Create Follow-up Task**: Create new task to address the issue

### Contingency Actions

**If Preflight Updates Already Exist** (Phase 1):
- Skip Phase 2 (no code changes needed)
- Proceed directly to Phase 3 (documentation updates)
- Adjust effort estimate (reduce by 2 hours)

**If Status Update Failures Occur** (Phase 5):
- Investigate status-sync-manager logs
- Verify status transition rules in state-management.md
- Check for file permission issues
- Verify atomic update mechanism

**If Documentation Drift Occurs**:
- Create validation script to check documentation consistency
- Add documentation validation to CI/CD pipeline (future task)

---

## Success Metrics

### Quantitative Metrics

1. **Status Update Coverage**: 100% of workflow commands implement two-phase status updates
2. **Documentation Coverage**: 100% of command files document two-phase pattern
3. **Test Pass Rate**: 100% of test cases pass
4. **Atomic Update Rate**: 100% of status updates are atomic (both files or neither)

### Qualitative Metrics

1. **User Visibility**: Users can see when work starts and ends via status markers
2. **Documentation Clarity**: Documentation clearly explains status update ownership
3. **Pattern Consistency**: All workflow subagents follow the same pattern
4. **Error Handling**: Clear error messages guide users when status updates fail

### Acceptance Criteria Summary

- [ ] All workflow subagents implement two-phase status update pattern
- [ ] Command documentation clarifies status update ownership
- [ ] Two-phase pattern documented in command lifecycle documentation
- [ ] Status updates tested and verified with sample tasks
- [ ] All acceptance criteria from all phases met
- [ ] Git commit created with changes
- [ ] Task 275 status updated to [COMPLETED]

---

## Dependencies and Prerequisites

### Prerequisites

- [x] Research completed (task 275 research-001.md)
- [x] Status-sync-manager supports all required status transitions
- [x] State-management.md defines command-specific status markers
- [x] Researcher subagent implements correct two-phase pattern (reference implementation)

### Dependencies

**None** - This task has no external dependencies.

### Blocking Issues

**None** - No blocking issues identified.

---

## Notes and Considerations

### Key Considerations

1. **Verification First**: Phase 1 is critical - must verify before implementing to avoid duplicate work
2. **Follow Researcher Pattern**: Use researcher.md as the reference implementation for consistency
3. **Atomic Updates**: Preserve atomic update mechanism via status-sync-manager
4. **Error Handling**: Ensure clear error messages for status update failures
5. **Documentation Consistency**: Keep documentation synchronized with code changes

### Alternative Approaches Considered

**Approach 1: Orchestrator Handles Preflight Updates**
- Pros: Centralized status update logic
- Cons: Violates agent-owned workflow pattern, increases orchestrator complexity
- Decision: Rejected - Subagents should own their complete workflow

**Approach 2: Make Preflight Updates Optional**
- Pros: More flexible, less risk of blocking work
- Cons: Inconsistent status visibility, harder to track progress
- Decision: Rejected - Two-phase pattern provides better user visibility

**Approach 3: Add Validation to Orchestrator**
- Pros: Additional safety check
- Cons: Adds complexity, low priority
- Decision: Deferred - Can be added in future task if needed

### Future Enhancements

1. **Orchestrator Validation**: Add validation in orchestrator Stage 4 to verify status transitions
2. **Status Update Logging**: Add detailed logging for status updates
3. **Status Update Metrics**: Track status update success/failure rates
4. **Documentation Validation**: Create script to validate documentation consistency

---

## Estimated Effort Summary

| Phase | Description | Estimated Effort |
|-------|-------------|------------------|
| 1 | Verify Planner and Implementer Preflight Status Updates | 1 hour |
| 2 | Add Preflight Status Updates (if missing) | 2 hours |
| 3 | Update Command Documentation | 1.5 hours |
| 4 | Document Two-Phase Status Update Pattern | 1.5 hours |
| 5 | Test Status Updates with Sample Tasks | 1.5 hours |
| 6 | Create Git Commit and Update Task Status | 0.5 hours |
| **Total** | | **8 hours** |

**Complexity**: Medium  
**Risk Level**: Low  
**Research Integrated**: Yes

---

## Conclusion

This implementation plan provides a systematic approach to ensuring all workflow commands implement consistent two-phase status updates. The plan prioritizes verification (Phase 1) to avoid unnecessary work, follows the researcher.md pattern for consistency, and includes comprehensive documentation updates to prevent future confusion.

The estimated effort of 8 hours aligns with the task estimate of 8-12 hours and accounts for verification, implementation (if needed), documentation, and testing.
