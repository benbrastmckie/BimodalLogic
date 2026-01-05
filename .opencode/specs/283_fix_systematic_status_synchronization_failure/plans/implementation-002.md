# Implementation Plan: Fix Systematic Status Synchronization Failure Across All Workflow Commands (REVISED)

## Metadata

- **Task**: 283 - Fix systematic status synchronization failure across all workflow commands
- **Status**: [NOT STARTED]
- **Estimated Effort**: 3-4 hours (revised from 6-8 hours based on root cause discovery)
- **Actual Effort**: TBD
- **Started**: TBD
- **Completed**: TBD
- **Language**: markdown
- **Priority**: High
- **Complexity**: Low-Medium (revised from Medium-High)
- **Dependencies**: None
- **Blocking**: None
- **Research Integrated**: Yes - Research Report 001 findings incorporated
- **Plan Version**: 002 (REVISED)
- **Created**: 2026-01-04
- **Revision Reason**: Root cause discovered - inconsistent stage naming between planner (step_0_preflight) and researcher (stage_1_preflight) causes Claude to skip preflight in researcher

## Overview

### Problem Statement

Multiple tasks (269, 284) have exposed a systematic status synchronization failure affecting /research command specifically. When /research completes successfully, status is NOT updated in TODO.md or state.json during workflow execution. However, /plan command DOES successfully update status.

**ROOT CAUSE DISCOVERED**: The planner uses `<step_0_preflight>` (numbered 0, before main workflow) while the researcher uses `<stage_1_preflight>` (numbered 1, as part of main workflow). This inconsistency causes Claude to treat preflight differently:
- **Planner**: `step_0_preflight` signals "execute this BEFORE the main workflow begins" → Claude executes it
- **Researcher**: `stage_1_preflight` signals "this is part of the main workflow" → Claude may skip or defer it

The planner has 8 steps (0-8) with step 0 being preflight, while the researcher has 6 stages (1-6) with stage 1 being preflight. The explicit "step 0" numbering in the planner makes it clear that preflight must execute first, while "stage 1" in the researcher is ambiguous.

### Scope

**In Scope**:
1. Standardize researcher.md to use `<step_0_preflight>` naming (matching planner.md)
2. Renumber researcher stages: `step_0_preflight`, `step_1`, `step_2`, ..., `step_6`
3. Verify implementer.md and other subagents use consistent naming
4. Update subagent-structure.md to document the `step_0_preflight` standard
5. Test /research command to verify status updates work

**Out of Scope**:
1. Orchestrator validation changes (not needed - specifications are correct)
2. Stage execution logging (not needed - naming fix is sufficient)
3. Automatic recovery mechanism (not needed - preflight will execute correctly)
4. Changes to status-sync-manager (already correct)
5. Changes to command specifications (thin routers, no changes needed)

### Constraints

1. **Backward Compatibility**: Changes must not break existing subagents
2. **Minimal Changes**: Only rename stage tags, don't change logic
3. **Standards Compliance**: Must follow subagent-structure.md standard
4. **Consistency**: All subagents must use same naming convention

### Definition of Done

- [ ] researcher.md uses `<step_0_preflight>` naming (matching planner.md)
- [ ] researcher.md stages renumbered: step_0, step_1, ..., step_6
- [ ] implementer.md verified to use consistent naming
- [ ] subagent-structure.md updated with `step_0_preflight` standard
- [ ] /research command tested and status updates work correctly
- [ ] Git commit created with all changes
- [ ] No regression in existing workflows

## Goals and Non-Goals

### Goals

1. **Fix Naming Inconsistency**: Standardize all subagents to use `step_0_preflight` naming
2. **Enable Preflight Execution**: Make it clear to Claude that step 0 must execute first
3. **Maintain Consistency**: All subagents follow same naming convention
4. **Minimal Changes**: Only rename tags, don't change logic or behavior

### Non-Goals

1. **Rewrite Workflow Logic**: Specifications are already correct (Task 275)
2. **Add Validation**: Not needed if preflight executes correctly
3. **Change Architecture**: Not moving to orchestrator-level status updates
4. **Fix Task 240 Issues**: Separate task, different scope

## Risks and Mitigations

### Risk 1: Naming Change Breaks Existing Behavior
- **Likelihood**: Low
- **Impact**: Medium
- **Mitigation**: Test thoroughly, only change tag names (not logic), maintain backward compatibility

### Risk 2: Other Subagents Have Same Issue
- **Likelihood**: Medium
- **Impact**: Medium
- **Mitigation**: Audit all subagents (implementer, reviser, etc.) and fix consistently

### Risk 3: Claude Still Skips Preflight
- **Likelihood**: Low
- **Impact**: High
- **Mitigation**: If naming fix insufficient, fall back to original plan (orchestrator validation)

## Implementation Phases

### Phase 1: Audit All Subagents for Naming Consistency [NOT STARTED]
**Estimated Effort**: 0.5 hours

**Objective**: Identify all subagents with inconsistent stage naming.

**Tasks**:
1. Check researcher.md stage naming (already confirmed: stage_1_preflight)
2. Check planner.md stage naming (already confirmed: step_0_preflight)
3. Check implementer.md stage naming:
   ```bash
   grep -n "step_0_preflight\|stage_1_preflight" .opencode/agent/subagents/implementer.md
   ```
4. Check reviser.md stage naming (if exists):
   ```bash
   grep -n "step_0_preflight\|stage_1_preflight" .opencode/agent/subagents/reviser.md
   ```
5. Check lean-research-agent.md stage naming
6. Check lean-implementation-agent.md stage naming
7. Document all inconsistencies found

**Acceptance Criteria**:
- [ ] All subagents audited for stage naming
- [ ] Inconsistencies documented
- [ ] List of files to update created

**Validation**:
- Verify audit covers all subagents in .opencode/agent/subagents/
- Verify inconsistencies clearly documented

### Phase 2: Standardize Researcher Stage Naming [NOT STARTED]
**Estimated Effort**: 1 hour

**Objective**: Update researcher.md to use `step_0_preflight` naming matching planner.md.

**Tasks**:
1. Read current researcher.md
2. Replace `<stage_1_preflight>` with `<step_0_preflight>`
3. Replace `</stage_1_preflight>` with `</step_0_preflight>`
4. Renumber remaining stages:
   - `<stage_2_research_execution>` → `<step_1_research_execution>`
   - `<stage_3_artifact_creation>` → `<step_2_artifact_creation>`
   - `<stage_4_validation>` → `<step_3_validation>`
   - `<stage_5_postflight>` → `<step_4_postflight>`
   - `<stage_6_return>` → `<step_5_return>`
5. Update all internal references to stages (if any)
6. Verify no logic changes, only tag renaming
7. Verify file still follows subagent-structure.md standard

**Acceptance Criteria**:
- [ ] researcher.md uses `<step_0_preflight>` naming
- [ ] All stages renumbered consistently (0-5)
- [ ] No logic changes, only tag renaming
- [ ] File still valid markdown
- [ ] Internal references updated

**Validation**:
- Read updated researcher.md
- Verify step_0_preflight exists
- Verify all steps numbered 0-5
- Verify no broken references

### Phase 3: Standardize Other Subagents (If Needed) [NOT STARTED]
**Estimated Effort**: 1 hour

**Objective**: Update any other subagents with inconsistent naming.

**Tasks**:
1. For each subagent identified in Phase 1 with inconsistent naming:
   - Read current file
   - Replace `<stage_1_preflight>` with `<step_0_preflight>`
   - Renumber remaining stages to steps (1, 2, 3, ...)
   - Update internal references
   - Verify no logic changes
2. Special attention to:
   - implementer.md (critical for /implement command)
   - lean-research-agent.md (Lean-specific research)
   - lean-implementation-agent.md (Lean-specific implementation)
3. Document all changes made

**Acceptance Criteria**:
- [ ] All subagents use `<step_0_preflight>` naming
- [ ] All subagents use consistent step numbering (0, 1, 2, ...)
- [ ] No logic changes, only tag renaming
- [ ] All files still valid markdown

**Validation**:
- Verify all subagents use step_0_preflight
- Verify consistent numbering across all subagents
- Verify no broken references

### Phase 4: Update Documentation Standards [NOT STARTED]
**Estimated Effort**: 0.5 hours

**Objective**: Document the `step_0_preflight` standard in subagent-structure.md.

**Tasks**:
1. Read current subagent-structure.md
2. Add section documenting stage naming standard:
   ```markdown
   ## Stage Naming Standard
   
   All subagents MUST use the following stage naming convention:
   
   - `<step_0_preflight>`: Preflight validation and status updates (MUST execute first)
   - `<step_1>`: First main workflow step
   - `<step_2>`: Second main workflow step
   - ...
   - `<step_N_postflight>`: Postflight status updates and git commits (MUST execute last)
   - `<step_N+1_return>`: Return standardized result
   
   **Rationale**: The explicit "step_0" numbering signals to Claude that preflight
   MUST execute BEFORE the main workflow begins. Using "stage_1" is ambiguous and
   may cause Claude to skip or defer preflight execution.
   
   **Example**: See planner.md for reference implementation.
   ```
3. Add examples from planner.md and researcher.md
4. Document the rationale (discovered in Task 283)

**Acceptance Criteria**:
- [ ] subagent-structure.md documents `step_0_preflight` standard
- [ ] Rationale explained (Task 283 findings)
- [ ] Examples provided
- [ ] Standard is clear and actionable

**Validation**:
- Read updated subagent-structure.md
- Verify standard is clearly documented
- Verify examples are correct

### Phase 5: Testing and Validation [NOT STARTED]
**Estimated Effort**: 1 hour

**Objective**: Verify /research command now updates status correctly.

**Tasks**:
1. Create test task in TODO.md (task 997):
   ```markdown
   ### 997. Test status synchronization fix
   - **Effort**: 0.5 hours
   - **Status**: [NOT STARTED]
   - **Priority**: High
   - **Language**: markdown
   
   **Description**: Test task for verifying Task 283 fix works correctly.
   ```
2. Add task to state.json active_projects
3. Run /research 997 and monitor status updates:
   - Verify status changes to [RESEARCHING] at start
   - Verify research report created
   - Verify status changes to [RESEARCHED] at end
   - Verify state.json updated
4. Run /plan 997 and verify status updates:
   - Verify status changes to [PLANNING] at start
   - Verify plan created
   - Verify status changes to [PLANNED] at end
5. Clean up test task (remove from TODO.md and state.json)
6. Document test results

**Acceptance Criteria**:
- [ ] Test task created successfully
- [ ] /research 997 updates status correctly
- [ ] /plan 997 updates status correctly (regression test)
- [ ] Test task cleaned up
- [ ] Test results documented

**Validation**:
- Verify status transitions occurred
- Verify artifacts created
- Verify state.json updated
- Verify test task removed

## Testing and Validation

### Unit Testing
- **Not applicable**: Changes are to markdown specifications, not code

### Integration Testing
1. **Status Update Test**: Test /research command with test task 997
2. **Regression Test**: Test /plan command to ensure no regression
3. **Consistency Test**: Verify all subagents use consistent naming

### Validation Checklist
- [ ] researcher.md uses step_0_preflight naming
- [ ] All subagents use consistent naming
- [ ] subagent-structure.md documents standard
- [ ] /research command updates status correctly
- [ ] /plan command still works (no regression)
- [ ] Test task cleaned up
- [ ] Git commit created

## Artifacts and Outputs

### Primary Artifacts
1. **Updated Subagent Specifications**:
   - `.opencode/agent/subagents/researcher.md` (step_0_preflight naming)
   - `.opencode/agent/subagents/implementer.md` (if needed)
   - `.opencode/agent/subagents/lean-research-agent.md` (if needed)
   - `.opencode/agent/subagents/lean-implementation-agent.md` (if needed)

2. **Updated Documentation**:
   - `.opencode/context/core/standards/subagent-structure.md` (step_0_preflight standard)

3. **Implementation Summary**:
   - `.opencode/specs/283_fix_systematic_status_synchronization_failure/summaries/implementation-summary-20260104.md`

### Validation Artifacts
- Test results from /research 997
- Test results from /plan 997 (regression test)
- Audit results from Phase 1

## Rollback/Contingency

### Rollback Plan
If the naming fix doesn't work:
1. Revert researcher.md to original stage naming
2. Revert other subagents to original naming
3. Revert subagent-structure.md changes
4. Fall back to original plan (orchestrator validation and recovery)
5. Document rollback reason in task notes

### Contingency Plan
If naming fix is insufficient:
1. Implement original plan Phase 2 (orchestrator validation)
2. Implement original plan Phase 3 (automatic recovery)
3. Keep naming standardization (still valuable for consistency)
4. Document that naming alone was insufficient

## Success Metrics

### Quantitative Metrics
1. **Status Update Success Rate**: 100% of /research commands update status correctly
2. **Naming Consistency**: 100% of subagents use step_0_preflight naming
3. **Test Pass Rate**: 100% of status update tests pass
4. **Regression Rate**: 0% regression in existing workflows

### Qualitative Metrics
1. **User Confidence**: Users trust that task status is accurate
2. **Code Clarity**: Subagent specifications are clear and consistent
3. **Maintainability**: Standard is documented and easy to follow
4. **Simplicity**: Fix is simple and minimal (only tag renaming)

### Acceptance Criteria
- [ ] All phases completed successfully
- [ ] All validation checklist items checked
- [ ] Testing confirms fix works
- [ ] No regression in existing workflows
- [ ] Documentation complete and accurate
- [ ] Git commit created with all changes

## Notes

### Root Cause Discovery

This revised plan is based on the discovery that:
1. **Planner** uses `<step_0_preflight>` (numbered 0, before main workflow)
2. **Researcher** uses `<stage_1_preflight>` (numbered 1, as part of main workflow)

The explicit "step 0" numbering in the planner signals to Claude that preflight MUST execute BEFORE the main workflow begins. The "stage 1" numbering in the researcher is ambiguous - it could be interpreted as "the first stage of the main workflow" rather than "a prerequisite that must execute first".

This explains why /plan successfully updates status (planner executes step_0_preflight) while /research does not (researcher may skip stage_1_preflight).

### Comparison with Original Plan

**Original Plan** (implementation-001.md):
- 6 phases, 6-8 hours
- Added orchestrator validation, automatic recovery, stage logging
- Complex solution with new validation layer

**Revised Plan** (implementation-002.md):
- 5 phases, 3-4 hours
- Simple tag renaming to fix root cause
- Minimal changes, no new validation needed

**Rationale for Revision**: The root cause is simpler than originally thought. The specifications are correct (Task 275 was right), but the naming inconsistency causes Claude to treat preflight differently. Fixing the naming is simpler, faster, and less risky than adding validation layers.

### Alignment with Task 240

This fix is still compatible with Task 240 OpenAgents migration:
- Naming standardization improves clarity regardless of architecture
- Simpler fix reduces technical debt
- Can still add validation later if needed

### Future Enhancements

After this fix is validated:
1. If naming fix is insufficient, implement original plan (validation and recovery)
2. Consider adding explicit "MUST EXECUTE FIRST" comments to step_0_preflight
3. Add automated tests to verify preflight execution
4. Integrate with Task 240 OpenAgents migration

---

**Plan Status**: [NOT STARTED]  
**Next Step**: Review plan and execute with /implement 283
