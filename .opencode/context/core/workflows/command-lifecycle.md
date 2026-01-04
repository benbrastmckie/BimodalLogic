# Command Lifecycle and Two-Phase Status Update Pattern

## Overview

This document describes the lifecycle of workflow commands (`/research`, `/plan`, `/revise`, `/implement`) and the two-phase status update pattern that all workflow subagents follow.

## Command Lifecycle Stages

All workflow commands follow a standardized 8-stage lifecycle:

### Orchestrator Stages (1-5, 8)

**Stage 1 (PreflightValidation):**
- Parse task number from $ARGUMENTS
- Validate task exists in TODO.md
- Extract task metadata

**Stage 2 (DetermineRouting):**
- Extract language from task entry (state.json or TODO.md)
- Map language to appropriate subagent using routing table
- Validate routing decision

**Stage 3 (RegisterAndDelegate):**
- Register session in session registry
- Prepare delegation context
- Invoke target subagent

**Stage 4 (ValidateReturn):**
- Validate return format per subagent-return-format.md
- Verify artifacts exist and are non-empty
- Extract metadata from return

**Stage 5 (PostflightCleanup):**
- Update session registry
- Relay result to user

**Stage 8 (Return):**
- Subagent returns standardized result to orchestrator

### Subagent Stages (6-7)

**Stage 6 (Execution):**
- Subagent executes main workflow
- Creates artifacts (research reports, plans, implementation files)
- Validates artifacts

**Stage 7 (Postflight):**
- Update status to completion marker
- Create git commit
- Return standardized result

## Two-Phase Status Update Pattern

All workflow subagents (researcher, planner, implementer) follow a **two-phase status update pattern** to provide visibility into work progress and ensure atomic state transitions.

### Phase 1: Preflight Status Update

**When:** Before executing main workflow (Stage 0 or Step 0 in subagent)  
**Purpose:** Signal that work has started  
**Status Markers:**
- `/research`: [RESEARCHING]
- `/plan`: [PLANNING]
- `/revise`: [REVISING]
- `/implement`: [IMPLEMENTING]

**Process:**
1. Validate task exists and is valid for operation
2. Verify task not [COMPLETED] or [ABANDONED]
3. Verify task is in valid starting status
4. Generate timestamp (ISO 8601 date: YYYY-MM-DD)
5. Invoke status-sync-manager with:
   - task_number
   - new_status: "researching" | "planning" | "revising" | "implementing"
   - timestamp
   - session_id
   - delegation_depth
   - delegation_path
6. Validate status update succeeded
7. **Abort if status update fails** (critical error)

**Error Handling:**
- If status update fails: Return status "failed" with error
- Error type: "status_update_failed"
- Recommendation: "Check status-sync-manager logs and retry"
- Work is NOT performed if preflight fails

### Phase 2: Postflight Status Update

**When:** After completing main workflow (Stage 7 or Step 7 in subagent)  
**Purpose:** Signal that work has completed  
**Status Markers:**
- `/research`: [RESEARCHED]
- `/plan`: [PLANNED]
- `/revise`: [REVISED]
- `/implement`: [COMPLETED]

**Process:**
1. Validate artifacts created successfully
2. Generate timestamp (ISO 8601 date: YYYY-MM-DD)
3. Invoke status-sync-manager with:
   - task_number
   - new_status: "researched" | "planned" | "revised" | "completed"
   - timestamp
   - session_id
   - validated_artifacts
   - delegation_depth
   - delegation_path
4. Validate status update succeeded
5. **Log warning if status update fails** (non-critical - work already done)
6. Invoke git-workflow-manager to create commit
7. Return standardized result

**Error Handling:**
- If status update fails: Log error (non-critical)
- Work artifacts already created
- Manual recovery: Update TODO.md and state.json manually

## Status Transitions

### Research Command

```
[NOT STARTED] → [RESEARCHING] → [RESEARCHED]
     ↑              ↑                ↑
     |         Preflight         Postflight
  Initial      (Step 0)          (Step 5)
```

### Plan Command

```
[RESEARCHED] → [PLANNING] → [PLANNED]
     ↑            ↑             ↑
     |       Preflight      Postflight
  Starting    (Step 0)      (Step 7)
```

### Revise Command

```
[PLANNED] → [REVISING] → [REVISED]
    ↑          ↑            ↑
    |     Preflight     Postflight
 Starting   (Step 0)    (Step 7)
```

### Implement Command

```
[PLANNED] → [IMPLEMENTING] → [COMPLETED]
    ↑           ↑                ↑
    |      Preflight         Postflight
 Starting    (Step 0)        (Step 7)
```

## Benefits of Two-Phase Pattern

### User Visibility
- Users can see when work starts (in-progress markers)
- Users can see when work completes (completion markers)
- Clear progress tracking in TODO.md and state.json

### Atomic Updates
- status-sync-manager ensures atomic updates across TODO.md and state.json
- Both files updated together or neither updated
- No partial state updates

### Error Recovery
- Preflight failure aborts work (prevents wasted effort)
- Postflight failure logs warning (work already done, manual recovery possible)
- Clear error messages guide users to recovery steps

### Consistency
- All workflow subagents follow the same pattern
- Predictable behavior across all commands
- Easier to understand and maintain

## Implementation Details

### Preflight Status Update (Step 0)

All workflow subagents implement a `<step_0_preflight>` or `<stage_1_preflight>` section:

```xml
<step_0_preflight>
  <action>Preflight: Validate task and update status to [COMMAND-ING]</action>
  <process>
    1. Parse task_number from delegation context or prompt string
    2. Validate task exists in .opencode/specs/TODO.md
    3. Extract task description and current status
    4. Verify task not [COMPLETED] or [ABANDONED]
    5. Verify task is in valid starting status
    6. Generate timestamp: $(date -I)
    7. Invoke status-sync-manager to mark [COMMAND-ING]:
       a. Prepare delegation context
       b. Invoke status-sync-manager with timeout (60s)
       c. Validate return status == "completed"
       d. Verify files_updated includes ["TODO.md", "state.json"]
       e. If status update fails: Abort with error
    8. Log preflight completion
  </process>
  <validation>
    - Task exists and is valid for operation
    - Status updated to [COMMAND-ING] atomically
    - Timestamp added to TODO.md and state.json
  </validation>
  <error_handling>
    If status update fails:
      Return status "failed" with error:
      - type: "status_update_failed"
      - message: "Failed to update status to [COMMAND-ING]"
      - recommendation: "Check status-sync-manager logs and retry"
  </error_handling>
  <output>Task validated, status updated to [COMMAND-ING]</output>
</step_0_preflight>
```

### Postflight Status Update (Step 7)

All workflow subagents implement a `<step_7>` section for postflight:

```xml
<step_7>
  <action>Execute Stage 7 (Postflight) - Update status and create git commit</action>
  <process>
    STAGE 7: POSTFLIGHT (Subagent owns this stage)
    
    STEP 7.1: INVOKE status-sync-manager
      PREPARE delegation context:
      - task_number
      - new_status: "researched" | "planned" | "revised" | "completed"
      - timestamp
      - session_id
      - validated_artifacts
      - delegation_depth
      - delegation_path
      
      INVOKE status-sync-manager with timeout (60s)
      VALIDATE return status == "completed"
      VERIFY files_updated includes ["TODO.md", "state.json"]
    
    STEP 7.2: INVOKE git-workflow-manager
      PREPARE delegation context with scope_files
      INVOKE git-workflow-manager with timeout (120s)
      VALIDATE return and extract commit_hash
  </process>
  <output>Status updated to [COMMAND-ED], git commit created</output>
</step_7>
```

## References

- **State Management:** `.opencode/context/core/system/state-management.md`
- **Status Sync Manager:** `.opencode/agent/subagents/status-sync-manager.md`
- **Researcher (Reference Implementation):** `.opencode/agent/subagents/researcher.md`
- **Planner:** `.opencode/agent/subagents/planner.md`
- **Implementer:** `.opencode/agent/subagents/implementer.md`
- **Command Files:** `.opencode/command/{research,plan,revise,implement}.md`

## Validation

### Pre-execution Validation
- Verify task_number is positive integer
- Verify task exists in TODO.md
- Verify task not [COMPLETED] or [ABANDONED]
- Verify task in valid starting status

### Post-execution Validation
- Verify preflight status update occurred
- Verify artifacts created successfully
- Verify postflight status update occurred
- Verify git commit created (or logged if failed)

## Testing Recommendations

When testing workflow commands, verify:

1. **Preflight Status Update:**
   - Status changes from starting status to in-progress marker
   - Timestamp added to TODO.md and state.json
   - Both files updated atomically

2. **Postflight Status Update:**
   - Status changes from in-progress marker to completion marker
   - Timestamp updated in TODO.md and state.json
   - Both files updated atomically

3. **Error Cases:**
   - Preflight failure aborts work
   - Postflight failure logs warning but doesn't fail command
   - Clear error messages with recovery instructions

4. **Atomic Updates:**
   - Both TODO.md and state.json updated together
   - No partial updates (both files or neither)
   - Rollback on failure

## Maintenance Notes

- All workflow subagents MUST implement two-phase status updates
- Preflight is CRITICAL (abort on failure)
- Postflight is NON-CRITICAL (log warning on failure)
- Follow researcher.md as reference implementation
- Keep pattern consistent across all subagents
