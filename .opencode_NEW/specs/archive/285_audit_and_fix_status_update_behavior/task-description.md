# Task 285: Audit and fix status update behavior in /research, /plan, /revise, and /implement commands

**Created**: 2026-01-04T06:15:00Z  
**Priority**: High  
**Effort**: 8-12 hours  
**Language**: markdown  
**Status**: [NOT STARTED]

## Problem Statement

When running `/research 259`, the lean-research-agent was correctly invoked, but the task status was NOT updated to `[RESEARCHING]` before work began. This violates the two-phase status update pattern defined in `.opencode/context/core/system/state-management.md`.

## Evidence

- `/research 259` invoked lean-research-agent successfully
- Task 259 status remained `[NOT STARTED]` during research execution
- **Expected**: Status should change to `[RESEARCHING]` at start, `[RESEARCHED]` at completion
- **Actual**: Status never updated during or after execution

## State Management Standard Requirements

From `state-management.md` (lines 390-402):

### Preflight Status Updates (Command Start)
- `/research` → Update status to `[RESEARCHING]`
- `/plan` → Update status to `[PLANNING]`
- `/implement` → Update status to `[IMPLEMENTING]`
- `/revise` → Update status to `[REVISING]`

### Postflight Status Updates (Command Completion)
- `/research` → Update status to `[RESEARCHED]`
- `/plan` → Update status to `[PLANNED]`
- `/implement` → Update status to `[COMPLETED]`
- `/revise` → Update status to `[REVISED]`

### Expected Pattern

```markdown
**`/research` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp)`
- Postflight: `status-sync-manager.mark_researched(task_number, timestamp)`

**`/plan` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp)`
- Postflight: `status-sync-manager.mark_planned(task_number, timestamp, plan_path)`

**`/implement` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp, plan_path)`
- Postflight: `status-sync-manager.mark_completed(task_number, timestamp, plan_path)`
```

## Root Cause Analysis

The actual command implementations may not be following the two-phase status update pattern. Need to audit all four commands to verify:

1. **Preflight status updates**: Are commands updating status at START?
2. **Postflight status updates**: Are commands updating status at END?
3. **Status-sync-manager invocation**: Are commands using status-sync-manager correctly?
4. **Atomic updates**: Are updates atomic (all files or none)?

## Audit Scope

### Commands to Audit (4 files)
- `.opencode/command/research.md` - Check preflight/postflight status updates
- `.opencode/command/plan.md` - Check preflight/postflight status updates
- `.opencode/command/implement.md` - Check preflight/postflight status updates
- `.opencode/command/revise.md` - Check preflight/postflight status updates

### Subagents to Audit (4 files)
- `.opencode/agent/subagents/researcher.md` - Verify status update responsibility
- `.opencode/agent/subagents/planner.md` - Verify status update responsibility
- `.opencode/agent/subagents/implementer.md` - Verify status update responsibility
- `.opencode/agent/subagents/reviser.md` - Verify status update responsibility (if exists)

### Orchestrator to Audit (1 file)
- `.opencode/agent/orchestrator.md` - Check if orchestrator handles status updates in Stage 1 (preflight) and Stage 5 (postflight)

### Status-Sync-Manager to Audit (1 file)
- `.opencode/agent/subagents/status-sync-manager.md` - Verify it supports all required operations

## Implementation Strategy

### Phase 1: Comprehensive Audit (3 hours)
1. Read all 4 command files and document current status update behavior
2. Read all 4 subagent files and document status update responsibility
3. Read orchestrator.md and document Stage 1/Stage 5 status handling
4. Read status-sync-manager.md and document available operations
5. Create audit report comparing actual vs. expected behavior
6. Identify gaps: Which commands/stages are missing status updates?

### Phase 2: Fix Orchestrator (if needed) (2 hours)
1. If orchestrator Stage 1 (PreflightValidation) is missing status updates:
   - Add status-sync-manager invocation to update status to in-progress state
   - Map command to status marker: /research → [RESEARCHING], /plan → [PLANNING], etc.
2. If orchestrator Stage 5 (PostflightCleanup) is missing status updates:
   - Add status-sync-manager invocation to update status to completion state
   - Map subagent return to status marker: researcher → [RESEARCHED], planner → [PLANNED], etc.
3. Test orchestrator changes with all workflow commands

### Phase 3: Fix Commands (if needed) (2 hours)
1. For each command missing preflight status updates:
   - Add status-sync-manager invocation at command start
   - Document the status update in command workflow
2. For each command missing postflight status updates:
   - Add status-sync-manager invocation at command end
   - Document the status update in command workflow
3. Test command changes with real tasks

### Phase 4: Fix Subagents (if needed) (2 hours)
1. If subagents are responsible for status updates (not orchestrator):
   - Add preflight status update to subagent Stage 1
   - Add postflight status update to subagent final stage
2. If subagents should NOT handle status (orchestrator handles it):
   - Remove any status update logic from subagents
   - Document that orchestrator owns status updates
3. Test subagent changes

### Phase 5: Update Documentation (1 hour)
1. Update state-management.md with actual implementation pattern
2. Update command-lifecycle.md with status update workflow
3. Create examples showing correct status update pattern
4. Document which component (orchestrator vs. command vs. subagent) owns status updates

### Phase 6: Validation Testing (2 hours)
1. Test `/research` command:
   - Verify status changes to [RESEARCHING] at start
   - Verify status changes to [RESEARCHED] at completion
   - Verify both TODO.md and state.json updated atomically
2. Test `/plan` command:
   - Verify status changes to [PLANNING] at start
   - Verify status changes to [PLANNED] at completion
3. Test `/implement` command:
   - Verify status changes to [IMPLEMENTING] at start
   - Verify status changes to [COMPLETED] at completion
4. Test `/revise` command:
   - Verify status changes to [REVISING] at start
   - Verify status changes to [REVISED] at completion
5. Verify all updates are atomic (all files updated or none)
6. Verify no regression in existing functionality

## Files to Modify (estimated 10-15 files)

### Commands (4 files)
- `.opencode/command/research.md`
- `.opencode/command/plan.md`
- `.opencode/command/implement.md`
- `.opencode/command/revise.md`

### Subagents (4-5 files)
- `.opencode/agent/subagents/researcher.md`
- `.opencode/agent/subagents/planner.md`
- `.opencode/agent/subagents/implementer.md`
- `.opencode/agent/subagents/reviser.md` (if exists)
- `.opencode/agent/subagents/status-sync-manager.md` (if new operations needed)

### Orchestrator (1 file)
- `.opencode/agent/orchestrator.md`

### Documentation (2-3 files)
- `.opencode/context/core/system/state-management.md`
- `.opencode/context/core/workflows/command-lifecycle.md`
- `.opencode/context/core/standards/status-transitions.md` (if exists)

## Acceptance Criteria

- [ ] Audit report created documenting current vs. expected status update behavior
- [ ] All gaps identified (which commands/stages missing status updates)
- [ ] `/research` updates status to [RESEARCHING] at start, [RESEARCHED] at end
- [ ] `/plan` updates status to [PLANNING] at start, [PLANNED] at end
- [ ] `/implement` updates status to [IMPLEMENTING] at start, [COMPLETED] at end
- [ ] `/revise` updates status to [REVISING] at start, [REVISED] at end
- [ ] All status updates are atomic (TODO.md and state.json updated together)
- [ ] Status updates use status-sync-manager for atomic multi-file updates
- [ ] Documentation updated to reflect actual implementation pattern
- [ ] All workflow commands tested and verified
- [ ] No regression in existing functionality
- [ ] Clear ownership documented (orchestrator vs. command vs. subagent)

## Impact

Ensures all workflow commands follow the two-phase status update pattern defined in state-management.md. Provides visibility into task progress (users can see when research/planning/implementation is actively underway). Enables accurate task tracking and prevents confusion about task state. Fixes the issue observed in `/research 259` where status was not updated during execution.

## Related Tasks

- Task 283: Fix systematic status synchronization failure (broader scope - includes state.json project entries)
- Task 275: Fix workflow status updates (claimed to fix this but didn't work - need to verify what was actually done)
- Task 280: Fix orchestrator Stage 4 validation (should validate status updates occurred)
