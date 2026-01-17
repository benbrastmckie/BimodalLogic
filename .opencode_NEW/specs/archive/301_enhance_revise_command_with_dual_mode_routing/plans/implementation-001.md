# Implementation Plan: Enhance Revise Command with Dual-Mode Routing

- **Task**: 301 - Enhance Revise Command with Dual-Mode Routing
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: Task 299 (task-reviser subagent), Task 300 (planner report detection)
- **Research Inputs**: specs/301_enhance_revise_command_with_dual_mode_routing/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The current `/revise` command routes exclusively to the `planner` subagent, assuming a plan always exists. This enhancement implements dual-mode routing based on plan presence detection: (1) **No Plan Mode** routes to `task-reviser` for task metadata updates, and (2) **Plan Exists Mode** routes to `planner` for plan revision with research integration. Research shows both subagents are fully functional and the architecture already supports this pattern through the `plan_path` field in state.json. Implementation requires minimal changes to Stage 1 (detection) and Stage 2 (routing) of the `/revise` command.

### Research Integration

This plan integrates findings from 1 research report:

**Integrated Reports**:
- **research-001.md** (2026-01-05): Comprehensive analysis of /revise command architecture and dual-mode routing requirements
  - Key Finding: Current /revise validates plan existence (lines 89-91) but always routes to planner
  - Key Finding: task-reviser.md and planner.md subagents already exist and are fully functional
  - Key Finding: Plan presence detectable via plan_path field in state.json
  - Recommendation: Implement plan presence detection in Stage 1 and conditional routing in Stage 2

## Goals & Non-Goals

**Goals**:
- Implement plan presence detection in `/revise` command Stage 1
- Add conditional routing to task-reviser (no plan) or planner (plan exists)
- Validate plan file consistency when plan_path is set
- Update command documentation with dual-mode examples
- Ensure atomic status updates via status-sync-manager delegation

**Non-Goals**:
- Modifications to task-reviser or planner subagents (already functional)
- Changes to state.json schema (plan_path field already exists)
- Adding new flags like --task-only or --plan-only (future enhancement)
- Changing status transition logic (already defined in state-management.md)

## Risks & Mitigations

- **Risk**: Inconsistent state (plan_path set but file missing) causes routing failure
  - **Mitigation**: Add plan file consistency check with clear error message and recovery instructions
- **Risk**: Routing logic complexity increases maintenance burden
  - **Mitigation**: Add comprehensive logging and validation checks, document routing decision logic clearly
- **Risk**: Users confused about when to use task-only vs plan revision
  - **Mitigation**: Update documentation with clear examples, add routing decision logging visible to user
- **Risk**: Breaking changes to existing /revise usage
  - **Mitigation**: Maintain backward compatibility - existing plan revision behavior unchanged, only add new task-only mode

## Implementation Phases

### Phase 1: Update Stage 1 Plan Presence Detection [NOT STARTED]

- **Goal**: Replace plan existence validation with plan presence detection and routing mode determination
- **Tasks**:
  - [ ] Locate current plan validation logic in `.opencode/command/revise.md` (lines 89-91)
  - [ ] Replace validation with plan presence detection:
    - Extract plan_path from state.json (already done in step 4)
    - Determine routing_mode: "task-only" if plan_path empty, "plan-revision" if non-empty
    - Validate plan file exists if plan_path set (detect inconsistent state)
    - Log routing decision with rationale
  - [ ] Add error handling for inconsistent state (plan_path set but file missing)
  - [ ] Set routing_mode variable for Stage 2
- **Timing**: 45 minutes

### Phase 2: Update Stage 1 Agent Selection Logic [NOT STARTED]

- **Goal**: Modify agent selection to consider routing_mode in addition to language
- **Tasks**:
  - [ ] Locate current agent selection logic in `.opencode/command/revise.md` (lines 97-99)
  - [ ] Replace with conditional logic:
    - If routing_mode == "task-only": target_agent = "task-reviser"
    - If routing_mode == "plan-revision" AND language == "lean": target_agent = "lean-planner"
    - If routing_mode == "plan-revision" AND language != "lean": target_agent = "planner"
  - [ ] Add agent existence validation before delegation
  - [ ] Add routing validation logging
- **Timing**: 30 minutes

### Phase 3: Update Stage 2 Delegation Context [NOT STARTED]

- **Goal**: Pass appropriate delegation context based on routing_mode
- **Tasks**:
  - [ ] Locate current delegation logic in `.opencode/command/revise.md` (lines 107-116)
  - [ ] Add conditional delegation context:
    - For task-only mode: Pass revision_context with task_number, session_id, delegation_path
    - For plan-revision mode: Pass revision_context with existing_plan_path, task_number, session_id, delegation_path
  - [ ] Verify delegation_path includes correct agent name
  - [ ] Test delegation context structure matches subagent expectations
- **Timing**: 30 minutes

### Phase 4: Update Command Documentation [NOT STARTED]

- **Goal**: Document dual-mode routing behavior with clear examples
- **Tasks**:
  - [ ] Add dual-mode explanation to "What This Does" section (lines 126-168)
  - [ ] Add "Dual-Mode Routing" section with:
    - Task-Only Revision subsection (no plan exists)
    - Plan Revision subsection (plan exists)
    - Examples for both modes
  - [ ] Add "Routing Validation" section explaining consistency checks
  - [ ] Add edge cases documentation (inconsistent state, multiple plan versions)
- **Timing**: 30 minutes

### Phase 5: Testing and Validation [NOT STARTED]

- **Goal**: Verify dual-mode routing works correctly for all scenarios
- **Tasks**:
  - [ ] Test task-only revision (no plan exists):
    - Create test task without plan
    - Run /revise with custom prompt
    - Verify routes to task-reviser
    - Verify metadata updated in TODO.md and state.json
    - Verify git commit created
  - [ ] Test plan revision without new reports:
    - Create test task with plan
    - Run /revise with custom prompt
    - Verify routes to planner
    - Verify new plan version created
    - Verify status updated to [REVISED]
  - [ ] Test plan revision with new reports:
    - Create test task with plan and new research report
    - Run /revise
    - Verify planner detects new report
    - Verify new findings integrated into plan
  - [ ] Test edge cases:
    - Inconsistent state (plan_path set but file missing)
    - Invalid routing_mode
    - Missing agent file
- **Timing**: 45 minutes

## Testing & Validation

**Pre-Implementation Validation**:
- [ ] Verify task-reviser.md exists and is functional
- [ ] Verify planner.md has report detection (Task 300 completed)
- [ ] Verify state.json has plan_path field for all active projects
- [ ] Verify routing-guide.md documents language-based routing patterns

**Post-Implementation Validation**:
- [ ] /revise routes to task-reviser when no plan exists
- [ ] /revise routes to planner when plan exists (general tasks)
- [ ] /revise routes to lean-planner when plan exists (Lean tasks)
- [ ] Plan file consistency check detects missing files
- [ ] Routing decision logged clearly for debugging
- [ ] Documentation updated with dual-mode examples
- [ ] All edge cases handled gracefully with clear error messages

**Integration Tests**:
- [ ] Test case 1: Task-only revision updates description, priority, effort
- [ ] Test case 2: Plan revision creates new version without new reports
- [ ] Test case 3: Plan revision integrates new reports into phases
- [ ] Test case 4: Inconsistent state error provides recovery instructions

## Artifacts & Outputs

- `.opencode/command/revise.md` (modified - dual-mode routing logic)
- `specs/301_enhance_revise_command_with_dual_mode_routing/plans/implementation-001.md` (this file)
- `specs/301_enhance_revise_command_with_dual_mode_routing/summaries/implementation-summary-20260105.md` (created after completion)

## Rollback/Contingency

If dual-mode routing causes issues:

1. **Immediate Rollback**: Revert `.opencode/command/revise.md` to previous version via git
2. **Partial Rollback**: Keep plan presence detection but force routing to planner (restore original behavior)
3. **Recovery Steps**:
   - Restore plan existence validation (lines 89-91)
   - Restore simple agent selection (lines 97-99)
   - Restore simple delegation context (lines 107-116)
   - Document rollback reason in task notes

**Git Safety**: All changes committed with clear message "task 301: enhance revise command with dual-mode routing"

## Success Metrics

- [ ] /revise command supports both task-only and plan revision modes
- [ ] Routing decision based on plan_path field in state.json
- [ ] Plan file consistency validated before routing
- [ ] Clear error messages for inconsistent state
- [ ] Documentation explains both modes with examples
- [ ] All tests pass (task-only, plan revision, edge cases)
- [ ] No regression in existing plan revision functionality
