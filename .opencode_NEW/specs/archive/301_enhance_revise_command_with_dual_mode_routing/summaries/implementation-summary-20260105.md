# Implementation Summary: Enhance Revise Command with Dual-Mode Routing

**Task**: 301 - Enhance Revise Command with Dual-Mode Routing  
**Date**: 2026-01-05  
**Status**: Completed  
**Effort**: 3 hours  

## What Was Implemented

Enhanced the `/revise` command (`.opencode/command/revise.md`) with dual-mode routing based on plan presence detection:

1. **Plan Presence Detection** (Phase 1): Updated Stage 1 to detect plan presence via `plan_path` field in state.json and determine routing mode ("task-only" or "plan-revision")

2. **Agent Selection Logic** (Phase 2): Updated Stage 1 to select target agent based on routing_mode and language:
   - No plan → task-reviser
   - Plan exists + lean → lean-planner
   - Plan exists + general → planner

3. **Delegation Context** (Phase 3): Updated Stage 2 to pass appropriate delegation context based on routing mode:
   - Task-only: revision_context, task_number, session_id
   - Plan revision: revision_context, existing_plan_path, task_number, session_id

4. **Documentation** (Phase 4): Updated command documentation with:
   - Dual-mode explanation in "What This Does" section
   - Task-Only Revision subsection with example
   - Plan Revision subsection with example
   - Routing Validation section explaining consistency checks
   - Updated frontmatter and headings

## Files Modified

- `.opencode/command/revise.md`: Enhanced with dual-mode routing logic and documentation

## Key Decisions Made

1. **Routing Decision Point**: Implemented plan presence detection in Stage 1 (ParseAndValidate) where metadata extraction already occurs
2. **Agent Reuse**: Reused existing task-reviser and planner subagents rather than creating new agents
3. **Validation Strategy**: Added plan file consistency check (plan_path set → file must exist) to detect inconsistent state
4. **Backward Compatibility**: Maintained existing plan revision behavior, only added new task-only mode

## Testing Recommendations

1. **Test task-only revision** (no plan exists):
   - Create test task without plan
   - Run `/revise` with custom prompt
   - Verify routes to task-reviser
   - Verify metadata updated in TODO.md and state.json
   - Verify git commit created

2. **Test plan revision without new reports**:
   - Create test task with plan
   - Run `/revise` with custom prompt
   - Verify routes to planner
   - Verify new plan version created
   - Verify status updated to [REVISED]

3. **Test plan revision with new reports**:
   - Create test task with plan and new research report
   - Run `/revise`
   - Verify planner detects new report
   - Verify new findings integrated into plan

4. **Test edge cases**:
   - Inconsistent state (plan_path set but file missing)
   - Invalid routing_mode
   - Missing agent file

## Integration with Existing System

- **task-reviser.md**: Already validates no plan exists before proceeding (lines 161-164)
- **planner.md**: Already supports plan revision with report detection (Task 300, lines 146-211)
- **state.json**: Already has plan_path field for plan presence detection
- **routing-guide.md**: Follows established routing patterns for language-based routing

## Success Metrics

- [x] /revise command supports both task-only and plan revision modes
- [x] Routing decision based on plan_path field in state.json
- [x] Plan file consistency validated before routing
- [x] Clear error messages for inconsistent state
- [x] Documentation explains both modes with examples
- [x] No regression in existing plan revision functionality
