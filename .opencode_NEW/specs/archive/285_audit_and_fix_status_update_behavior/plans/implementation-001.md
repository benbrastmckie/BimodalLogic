# Implementation Plan: Audit and Fix Status Update Behavior in Workflow Commands

## Metadata

- **Task**: 285 - Audit and fix status update behavior in /research, /plan, /revise, and /implement commands
- **Status**: [NOT STARTED]
- **Estimated Effort**: 6-8 hours (revised from 8-12 hours based on research findings)
- **Priority**: High
- **Language**: markdown
- **Created**: 2026-01-04
- **Plan Version**: 1
- **Research Integrated**: Yes (research-001.md)

## Overview

### Problem Statement

Research on task 285 revealed that Task 283 successfully fixed status update behavior for general-purpose subagents (researcher, planner, implementer) but did NOT fix Lean-specific subagents (lean-research-agent, lean-planner, lean-implementation-agent). This causes status update failures for all Lean tasks, as evidenced by `/research 259` failing to update status to [RESEARCHING].

**Root Cause**: Lean subagents use `<step_1>` naming instead of `<step_0_preflight>`, causing Claude to skip or defer preflight status updates.

### Scope

**In Scope**:
- Standardize Lean subagent naming to `<step_0_preflight>` pattern
- Replace direct TODO.md updates with status-sync-manager delegation
- Update subagent-structure.md to document naming standard
- Test Lean workflow after fixes

**Out of Scope**:
- Changes to workflow commands (already correct - delegate to orchestrator)
- Changes to general subagents (already fixed by Task 283)
- Changes to orchestrator (already correct - routes based on language)

### Constraints

- Must follow Task 283 pattern exactly (proven to work)
- Must maintain backward compatibility with existing Lean tasks
- Must ensure atomic updates to TODO.md and state.json
- Must not change core Lean-specific logic (only naming and status updates)

### Definition of Done

- All Lean subagents use `<step_0_preflight>` naming consistently
- All Lean subagents delegate to status-sync-manager for status updates
- Lean workflow tested and verified (research, plan, implement)
- Documentation updated with naming standard
- No regression in existing functionality

## Goals and Non-Goals

### Goals

1. **Standardize Lean subagent naming**: Apply Task 283 fix to all three Lean subagents
2. **Atomic status updates**: Replace direct TODO.md updates with status-sync-manager delegation
3. **Documentation**: Update subagent-structure.md to prevent future inconsistencies
4. **Validation**: Test Lean workflow end-to-end

### Non-Goals

1. **Command changes**: Commands are thin routers, no changes needed
2. **Orchestrator changes**: Already handles language-based routing correctly
3. **General subagent changes**: Already fixed by Task 283
4. **New features**: Only fixing existing status update behavior

## Risks and Mitigations

### Risk 1: Lean Subagent Refactoring Breaks Existing Functionality

**Likelihood**: Low  
**Impact**: High  
**Mitigation**: 
- Follow Task 283 pattern exactly (proven to work)
- Only change naming and status update method (don't change core logic)
- Test thoroughly with Lean tasks before completing
- Keep backup of original files

### Risk 2: Status-Sync-Manager Delegation Adds Latency

**Likelihood**: Low  
**Impact**: Low  
**Mitigation**: 
- status-sync-manager is fast (60s timeout, typically completes in <5s)
- Atomic updates are worth the small latency cost
- General subagents already use this pattern successfully

### Risk 3: Incomplete Fix (Missing Edge Cases)

**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**: 
- Audit all six primary subagents (done in research)
- Check for other subagents that might need fixing
- Document standard in subagent-structure.md to prevent future inconsistencies

## Implementation Phases

### Phase 1: Standardize lean-research-agent.md Naming [NOT STARTED]

**Estimated Effort**: 1.5 hours

**Objective**: Apply Task 283 fix to lean-research-agent.md by renaming `<step_1>` to `<step_0_preflight>` and adding status-sync-manager delegation.

**Tasks**:
1. Read lean-research-agent.md to understand current structure
2. Rename `<step_1>` to `<step_0_preflight>` (following researcher.md pattern)
3. Add status-sync-manager invocation for [RESEARCHING] status update
4. Remove direct TODO.md update logic
5. Renumber remaining steps (step_2 → step_1, step_3 → step_2, etc.)
6. Add postflight status-sync-manager invocation for [RESEARCHED] status update
7. Verify all step references updated consistently

**Acceptance Criteria**:
- [ ] lean-research-agent.md uses `<step_0_preflight>` naming
- [ ] Preflight invokes status-sync-manager to mark [RESEARCHING]
- [ ] Postflight invokes status-sync-manager to mark [RESEARCHED]
- [ ] No direct TODO.md updates remain
- [ ] All step numbers renumbered correctly

**Files Modified**:
- `.opencode/agent/subagents/lean-research-agent.md`

### Phase 2: Standardize lean-planner.md Naming [NOT STARTED]

**Estimated Effort**: 1.5 hours

**Objective**: Apply Task 283 fix to lean-planner.md by renaming `<step_1>` to `<step_0_preflight>` and adding status-sync-manager delegation.

**Tasks**:
1. Read lean-planner.md to understand current structure
2. Rename `<step_1>` to `<step_0_preflight>` (following planner.md pattern)
3. Add status-sync-manager invocation for [PLANNING] status update
4. Remove direct TODO.md update logic
5. Renumber remaining steps (step_2 → step_1, step_3 → step_2, etc.)
6. Add postflight status-sync-manager invocation for [PLANNED] status update
7. Verify all step references updated consistently

**Acceptance Criteria**:
- [ ] lean-planner.md uses `<step_0_preflight>` naming
- [ ] Preflight invokes status-sync-manager to mark [PLANNING]
- [ ] Postflight invokes status-sync-manager to mark [PLANNED]
- [ ] No direct TODO.md updates remain
- [ ] All step numbers renumbered correctly

**Files Modified**:
- `.opencode/agent/subagents/lean-planner.md`

### Phase 3: Standardize lean-implementation-agent.md Naming [NOT STARTED]

**Estimated Effort**: 1.5 hours

**Objective**: Apply Task 283 fix to lean-implementation-agent.md by renaming `<step_1>` to `<step_0_preflight>` and adding status-sync-manager delegation.

**Tasks**:
1. Read lean-implementation-agent.md to understand current structure
2. Rename `<step_1>` to `<step_0_preflight>` (following implementer.md pattern)
3. Add status-sync-manager invocation for [IMPLEMENTING] status update
4. Remove direct TODO.md update logic
5. Renumber remaining steps (step_2 → step_1, step_3 → step_2, etc.)
6. Add postflight status-sync-manager invocation for [COMPLETED] status update
7. Verify all step references updated consistently

**Acceptance Criteria**:
- [ ] lean-implementation-agent.md uses `<step_0_preflight>` naming
- [ ] Preflight invokes status-sync-manager to mark [IMPLEMENTING]
- [ ] Postflight invokes status-sync-manager to mark [COMPLETED]
- [ ] No direct TODO.md updates remain
- [ ] All step numbers renumbered correctly

**Files Modified**:
- `.opencode/agent/subagents/lean-implementation-agent.md`

### Phase 4: Update Documentation [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Document the `<step_0_preflight>` naming standard in subagent-structure.md to prevent future inconsistencies.

**Tasks**:
1. Read subagent-structure.md to understand current documentation
2. Add requirement: "All subagents MUST use `<step_0_preflight>` for preflight step"
3. Add rationale: "Explicit step_0 numbering prevents Claude from skipping preflight"
4. Add examples from both general and Lean subagents
5. Reference Task 283 and Task 285 as history
6. Document status-sync-manager delegation pattern

**Acceptance Criteria**:
- [ ] subagent-structure.md documents `<step_0_preflight>` requirement
- [ ] Rationale explains why explicit step_0 numbering is needed
- [ ] Examples show both general and Lean subagent patterns
- [ ] Task 283 and Task 285 referenced as history

**Files Modified**:
- `.opencode/context/core/standards/subagent-structure.md`

### Phase 5: Test Lean Workflow [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Verify that Lean workflow commands correctly update status after fixes.

**Tasks**:
1. Identify a Lean task for testing (e.g., Task 259 or create test task)
2. Test `/research {task}`:
   - Verify status changes to [RESEARCHING] at start
   - Verify status changes to [RESEARCHED] at completion
   - Verify both TODO.md and state.json updated atomically
3. Test `/plan {task}`:
   - Verify status changes to [PLANNING] at start
   - Verify status changes to [PLANNED] at completion
   - Verify both TODO.md and state.json updated atomically
4. Test `/implement {task}`:
   - Verify status changes to [IMPLEMENTING] at start
   - Verify status changes to [COMPLETED] at completion
   - Verify both TODO.md and state.json updated atomically
5. Verify no regression in existing functionality
6. Document test results

**Acceptance Criteria**:
- [ ] Lean research workflow tested and verified
- [ ] Lean planning workflow tested and verified
- [ ] Lean implementation workflow tested and verified
- [ ] All status updates are atomic (TODO.md + state.json)
- [ ] No regression in existing functionality
- [ ] Test results documented

**Files Modified**:
- None (testing only)

### Phase 6: Create Task 289 for Remaining Work [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Create follow-up task to extend this fix to any other subagents with inconsistent naming.

**Tasks**:
1. Audit all subagent files for step naming patterns
2. Identify any other subagents with inconsistent naming (beyond the 6 primary subagents)
3. Create Task 289 to fix remaining subagents if any found
4. Document findings in task description

**Acceptance Criteria**:
- [ ] All subagent files audited for naming patterns
- [ ] Task 289 created if additional subagents need fixing
- [ ] Findings documented

**Files Modified**:
- `.opencode/specs/TODO.md` (if Task 289 created)

## Testing and Validation

### Unit Testing

**Not applicable** - This task modifies subagent specifications (markdown files), not code.

### Integration Testing

**Phase 5 covers integration testing**:
- Test `/research` with Lean task
- Test `/plan` with Lean task
- Test `/implement` with Lean task
- Verify atomic status updates (TODO.md + state.json)

### Validation Criteria

- [ ] All Lean subagents use `<step_0_preflight>` naming
- [ ] All Lean subagents delegate to status-sync-manager
- [ ] Lean workflow tested end-to-end
- [ ] Documentation updated
- [ ] No regression in existing functionality

## Artifacts and Outputs

### Primary Artifacts

1. **Updated Lean Subagents** (3 files):
   - `.opencode/agent/subagents/lean-research-agent.md`
   - `.opencode/agent/subagents/lean-planner.md`
   - `.opencode/agent/subagents/lean-implementation-agent.md`

2. **Updated Documentation** (1 file):
   - `.opencode/context/core/standards/subagent-structure.md`

### Secondary Artifacts

1. **Implementation Summary**: `.opencode/specs/285_audit_and_fix_status_update_behavior/summaries/implementation-summary-{date}.md`
2. **Test Results**: Documented in implementation summary

## Rollback/Contingency

### Rollback Plan

If implementation causes issues:

1. **Immediate Rollback**:
   - Revert all three Lean subagent files to previous versions
   - Revert subagent-structure.md to previous version
   - Create git commit with rollback

2. **Root Cause Analysis**:
   - Identify what went wrong
   - Compare with Task 283 implementation
   - Determine if pattern needs adjustment

3. **Re-implementation**:
   - Fix identified issues
   - Re-test thoroughly
   - Re-deploy with fixes

### Contingency Plan

If Lean workflow testing fails:

1. **Isolate Failure**:
   - Determine which phase failed (research, plan, implement)
   - Check status-sync-manager logs
   - Verify delegation context is correct

2. **Fix and Re-test**:
   - Fix identified issues
   - Re-run tests
   - Verify fix works

3. **Escalate if Needed**:
   - If fix is not straightforward, create follow-up task
   - Document issues and partial progress
   - Mark task as [BLOCKED] with clear blocker description

## Success Metrics

### Quantitative Metrics

- **Naming Consistency**: 100% of subagents use `<step_0_preflight>` naming (6/6 subagents)
- **Status Update Method**: 100% of subagents use status-sync-manager delegation (6/6 subagents)
- **Test Pass Rate**: 100% of Lean workflow tests pass (3/3 commands)
- **Atomic Updates**: 100% of status updates are atomic (TODO.md + state.json)

### Qualitative Metrics

- **Code Quality**: Lean subagents follow same pattern as general subagents
- **Documentation**: Clear standard documented in subagent-structure.md
- **Maintainability**: Future subagents will follow documented standard
- **User Experience**: Lean tasks show correct status during execution

## Dependencies

### Upstream Dependencies

- **Task 283**: Completed (provides pattern to follow)
- **status-sync-manager**: Exists and works correctly

### Downstream Dependencies

- **Task 289**: May be created if additional subagents need fixing
- **Future Lean tasks**: Will benefit from reliable status updates

## Notes

### Research Findings Summary

Research revealed that Task 283 successfully fixed general subagents but did NOT fix Lean subagents:

**Fixed (Task 283)**:
- researcher.md uses `<step_0_preflight>` + status-sync-manager
- planner.md uses `<step_0_preflight>` + status-sync-manager
- implementer.md uses `<step_0_preflight>` + status-sync-manager

**Not Fixed (This Task)**:
- lean-research-agent.md uses `<step_1>` + direct TODO.md updates
- lean-planner.md uses `<step_1>` + direct TODO.md updates
- lean-implementation-agent.md uses `<step_1>` + direct TODO.md updates

### Task 259 Root Cause

Task 259 failure explained:
1. Task 259 language is "lean" (from state.json)
2. `/research 259` routes to lean-research-agent (per routing table)
3. lean-research-agent uses `<step_1>` naming (not `<step_0_preflight>`)
4. Claude treats `<step_1>` as "part of main workflow" instead of "execute first"
5. Preflight status update is skipped or deferred
6. Task 259 status remains [NOT STARTED] during research execution

### Pattern to Follow

Follow Task 283 pattern exactly:
1. Rename `<step_1>` to `<step_0_preflight>`
2. Add status-sync-manager delegation in preflight
3. Add status-sync-manager delegation in postflight
4. Remove direct TODO.md updates
5. Renumber remaining steps
6. Test thoroughly

---

**Plan Created**: 2026-01-04  
**Next Steps**: Execute phases 1-6 sequentially with `/implement 285`
