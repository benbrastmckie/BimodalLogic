# Preflight/Postflight Workflow Standards

**Version**: 1.0  
**Created**: 2026-01-05  
**Purpose**: Document workflow timing requirements and patterns  
**Source**: Tasks 320 and 321 (workflow bug fixes and standards)  
**Audience**: Command developers, subagent developers, workflow designers

---

## Overview

Preflight and postflight patterns ensure **correct timing** of status updates, artifact linking, and verification checkpoints in ProofChecker workflows. These patterns prevent common bugs where status updates occur at the wrong time or artifacts are not properly linked to tasks.

### Core Principles

1. **Preflight Timing**: Status updates MUST occur BEFORE work begins
2. **Postflight Timing**: Status and artifact updates MUST occur BEFORE returning to caller
3. **Verification Checkpoints**: Delegate → Wait → Verify → Proceed
4. **Atomic Writes**: All state updates use atomic write pattern
5. **Two-Level Error Logging**: CRITICAL vs NON-CRITICAL errors

---

## Preflight Pattern

### Purpose

Preflight updates task status to "in_progress" BEFORE work begins, ensuring accurate status tracking and preventing race conditions.

### Timing Requirement

**CRITICAL**: Preflight MUST complete BEFORE work execution begins.

```
✅ CORRECT:
  Preflight (update status to "in_progress")
    ↓
  Work (execute implementation)
    ↓
  Postflight (update status to "completed")

❌ WRONG:
  Work (execute implementation)
    ↓
  Preflight (update status to "in_progress") ← TOO LATE
    ↓
  Postflight (update status to "completed")
```

### Pattern

```markdown
<preflight>
  <step_1>
    <action>Update task status to "in_progress"</action>
    <delegation>
      Delegate to status-sync-manager with:
        - task_number: {task_number}
        - new_status: "in_progress"
        - session_id: {session_id}
        - delegation_depth: {current_depth + 1}
    </delegation>
    <timing>BEFORE work begins</timing>
  </step_1>
  
  <step_2>
    <action>Log start time</action>
    <log>
      Task {task_number} started at {timestamp}
      Session: {session_id}
    </log>
  </step_2>
  
  <step_3>
    <action>Validate preconditions</action>
    <validation>
      - Task exists in state.json
      - Task status allows transition to "in_progress"
      - All required artifacts present
    </validation>
    <on_failure>
      Return error immediately
      Do NOT proceed to work execution
    </on_failure>
  </step_3>
</preflight>
```

### Example

```markdown
## Workflow Execution

<workflow_execution>
  <!-- PREFLIGHT: Update status BEFORE work -->
  <preflight>
    Delegate to status-sync-manager:
      - task_number: 259
      - new_status: "in_progress"
      - session_id: sess_20260105_abc123
      - delegation_depth: 2
    
    Wait for confirmation
    Validate status updated successfully
  </preflight>
  
  <!-- WORK: Execute implementation -->
  <work>
    Delegate to implementer:
      - task_number: 259
      - session_id: sess_20260105_abc123
      - delegation_depth: 2
    
    Wait for return
    Validate implementation completed
  </work>
  
  <!-- POSTFLIGHT: Update status AFTER work -->
  <postflight>
    Delegate to status-sync-manager:
      - task_number: 259
      - new_status: "completed"
      - artifact_path: {implementation_path}
      - session_id: sess_20260105_abc123
      - delegation_depth: 2
    
    Wait for confirmation
  </postflight>
  
  <return>
    Return result to caller
  </return>
</workflow_execution>
```

---

## Postflight Pattern

### Purpose

Postflight updates task status to "completed" and links artifacts BEFORE returning to caller, ensuring state consistency and artifact tracking.

### Timing Requirement

**CRITICAL**: Postflight MUST complete BEFORE returning to caller.

```
✅ CORRECT:
  Work (execute implementation)
    ↓
  Postflight (update status, link artifacts)
    ↓
  Return to caller

❌ WRONG:
  Work (execute implementation)
    ↓
  Return to caller ← TOO EARLY
    ↓
  Postflight (update status, link artifacts) ← NEVER EXECUTED
```

### Pattern

```markdown
<postflight>
  <step_1>
    <action>Update task status to "completed"</action>
    <delegation>
      Delegate to status-sync-manager with:
        - task_number: {task_number}
        - new_status: "completed"
        - session_id: {session_id}
        - delegation_depth: {current_depth + 1}
    </delegation>
    <timing>AFTER work completes, BEFORE return</timing>
  </step_1>
  
  <step_2>
    <action>Link artifacts to task</action>
    <delegation>
      Delegate to status-sync-manager with:
        - task_number: {task_number}
        - artifact_path: {artifact_path}
        - artifact_type: "implementation|plan|research|review"
        - session_id: {session_id}
        - delegation_depth: {current_depth + 1}
    </delegation>
    <timing>AFTER work completes, BEFORE return</timing>
  </step_2>
  
  <step_3>
    <action>Log completion time</action>
    <log>
      Task {task_number} completed at {timestamp}
      Duration: {duration_seconds}s
      Session: {session_id}
    </log>
  </step_3>
  
  <step_4>
    <action>Validate postflight completed</action>
    <validation>
      - Status updated to "completed"
      - Artifacts linked to task
      - All state changes persisted
    </validation>
    <on_failure>
      Log CRITICAL error
      Return error to caller
    </on_failure>
  </step_4>
</postflight>
```

### Example

```markdown
## Workflow Execution

<workflow_execution>
  <!-- WORK: Execute implementation -->
  <work>
    Delegate to implementer:
      - task_number: 259
      - session_id: sess_20260105_abc123
      - delegation_depth: 2
    
    Wait for return
    Validate implementation completed
    Extract artifact_path from return
  </work>
  
  <!-- POSTFLIGHT: Update status and link artifacts BEFORE return -->
  <postflight>
    <status_update>
      Delegate to status-sync-manager:
        - task_number: 259
        - new_status: "completed"
        - session_id: sess_20260105_abc123
        - delegation_depth: 2
      
      Wait for confirmation
      Validate status updated
    </status_update>
    
    <artifact_linking>
      Delegate to status-sync-manager:
        - task_number: 259
        - artifact_path: {artifact_path}
        - artifact_type: "implementation"
        - session_id: sess_20260105_abc123
        - delegation_depth: 2
      
      Wait for confirmation
      Validate artifact linked
    </artifact_linking>
    
    <validation>
      Verify postflight completed successfully
      If failed: Log CRITICAL error, return error
    </validation>
  </postflight>
  
  <!-- RETURN: Only after postflight completes -->
  <return>
    Return result to caller with:
      - status: "completed"
      - artifacts: [{artifact_path}]
      - summary: "Implementation completed"
  </return>
</workflow_execution>
```

---

## Verification Checkpoint Pattern

### Purpose

Verification checkpoints ensure delegated work completes successfully before proceeding to next step.

### Pattern

```
Delegate → Wait → Verify → Proceed
```

**NOT**:
```
Delegate → Proceed (without waiting or verifying) ← WRONG
```

### Implementation

```markdown
<verification_checkpoint>
  <step_1>
    <action>Delegate to subagent</action>
    <delegation>
      Delegate to {subagent} with {context}
    </delegation>
  </step_1>
  
  <step_2>
    <action>Wait for return</action>
    <timeout>{timeout_seconds}s</timeout>
    <on_timeout>
      Log error: "Subagent timeout"
      Return error to caller
    </on_timeout>
  </step_2>
  
  <step_3>
    <action>Verify return</action>
    <validation>
      - status is "completed", "partial", or "failed"
      - artifacts array is present (if expected)
      - metadata is complete
      - All artifact paths exist on disk
    </validation>
    <on_failure>
      Log error: "Verification failed"
      Return error to caller
      Do NOT proceed to next step
    </on_failure>
  </step_3>
  
  <step_4>
    <action>Proceed to next step</action>
    <condition>Only if verification passed</condition>
  </step_4>
</verification_checkpoint>
```

### Example

```markdown
<workflow_execution>
  <!-- Checkpoint 1: Delegate to planner -->
  <checkpoint_1>
    <delegate>
      Delegate to planner with task_number: 196
    </delegate>
    
    <wait>
      Wait for planner return (timeout: 3600s)
    </wait>
    
    <verify>
      Validate return:
        - status == "completed"
        - artifacts contains plan
        - plan file exists on disk
      
      If validation fails:
        Return error to caller
        Do NOT proceed to checkpoint 2
    </verify>
  </checkpoint_1>
  
  <!-- Checkpoint 2: Delegate to status-sync-manager -->
  <checkpoint_2>
    <delegate>
      Delegate to status-sync-manager with:
        - task_number: 196
        - new_status: "planned"
        - artifact_path: {plan_path}
    </delegate>
    
    <wait>
      Wait for status-sync-manager return (timeout: 30s)
    </wait>
    
    <verify>
      Validate return:
        - status == "completed"
        - state.json updated
      
      If validation fails:
        Log warning (non-critical)
        Continue (status update failure non-blocking)
    </verify>
  </checkpoint_2>
  
  <return>
    Return aggregated result to caller
  </return>
</workflow_execution>
```

---

## Two-Level Error Logging

### Purpose

Distinguish between errors that prevent task completion (CRITICAL) and warnings or recoverable errors (NON-CRITICAL).

### CRITICAL Errors

**Definition**: Errors that prevent task completion and require user intervention.

**Examples**:
- Argument parsing failure
- Subagent execution failure
- Required artifact creation failure
- State update failure (if blocking)
- Validation failure

**Handling**:
```markdown
<critical_error_handling>
  <on_critical_error>
    Log to errors.json:
      {
        "type": "execution",
        "message": "{error_message}",
        "code": "{ERROR_CODE}",
        "recoverable": true|false,
        "recommendation": "{recovery_recommendation}"
      }
    
    Return error to caller:
      {
        "status": "failed",
        "errors": [{...}],
        "next_steps": "{recovery_recommendation}"
      }
    
    Do NOT proceed to next step
  </on_critical_error>
</critical_error_handling>
```

### NON-CRITICAL Errors

**Definition**: Warnings or recoverable errors that don't prevent task completion.

**Examples**:
- Git commit failure (if non-blocking)
- Optional artifact creation failure
- Performance warnings
- Status update failure (if non-blocking)

**Handling**:
```markdown
<non_critical_error_handling>
  <on_non_critical_error>
    Log warning:
      {
        "type": "warning",
        "message": "{warning_message}",
        "code": "{WARNING_CODE}",
        "impact": "low|medium"
      }
    
    Continue execution
    Include warning in return metadata
  </on_non_critical_error>
</non_critical_error_handling>
```

### Example

```markdown
<error_handling>
  <critical_errors>
    <!-- Planner failure prevents task completion -->
    If planner returns {status: "failed"}:
      Log CRITICAL error to errors.json
      Return error to caller
      Do NOT proceed to status update
  </critical_errors>
  
  <non_critical_errors>
    <!-- Git commit failure doesn't prevent task completion -->
    If git-workflow-manager returns {status: "failed"}:
      Log NON-CRITICAL warning
      Continue execution
      Include warning in return metadata
  </non_critical_errors>
</error_handling>
```

**See Also**: `standards/error-handling.md` for complete error handling patterns

---

## Atomic Write Pattern

### Purpose

Ensure state updates are atomic (all-or-nothing) to prevent partial state corruption.

### Pattern

```
Write to temp file → Validate → Rename atomically
```

**NOT**:
```
Write directly to state.json ← WRONG (not atomic)
```

### Implementation

```markdown
<atomic_write>
  <step_1>
    <action>Write to temporary file</action>
    <file>state.json.tmp.{session_id}</file>
    <content>{updated_state}</content>
  </step_1>
  
  <step_2>
    <action>Validate temporary file</action>
    <validation>
      - File is valid JSON
      - All required fields present
      - No data loss from original
    </validation>
    <on_failure>
      Delete temporary file
      Return error
      Do NOT rename
    </on_failure>
  </step_2>
  
  <step_3>
    <action>Rename atomically</action>
    <command>mv state.json.tmp.{session_id} state.json</command>
    <atomic>true (mv is atomic on same filesystem)</atomic>
  </step_3>
  
  <step_4>
    <action>Verify write succeeded</action>
    <validation>
      - state.json exists
      - state.json contains expected updates
    </validation>
    <on_failure>
      Log CRITICAL error
      Attempt rollback from backup
    </on_failure>
  </step_4>
</atomic_write>
```

### Example (status-sync-manager)

```markdown
<state_update>
  <atomic_write>
    # Write to temp file
    jq ".tasks[] | select(.number == $task_number) | .status = \"$new_status\"" \
      .opencode/state.json > .opencode/state.json.tmp.$session_id
    
    # Validate temp file
    if ! jq empty .opencode/state.json.tmp.$session_id 2>/dev/null; then
      rm .opencode/state.json.tmp.$session_id
      return error "Invalid JSON in temp file"
    fi
    
    # Rename atomically
    mv .opencode/state.json.tmp.$session_id .opencode/state.json
    
    # Verify write succeeded
    updated_status=$(jq -r ".tasks[] | select(.number == $task_number) | .status" .opencode/state.json)
    if [ "$updated_status" != "$new_status" ]; then
      return error "State update verification failed"
    fi
  </atomic_write>
</state_update>
```

**See Also**: `orchestration/state-management.md` for state management patterns

---

## Git-Only Rollback Strategy

### Purpose

Use git as the single source of truth for rollback, avoiding complex backup/restore logic.

### Pattern

```
Git commit → Work → If failure: git reset --hard
```

**NOT**:
```
Manual backup → Work → If failure: restore from backup ← COMPLEX
```

### Implementation

```markdown
<git_rollback>
  <step_1>
    <action>Create git commit before work</action>
    <command>git add . && git commit -m "Pre-work checkpoint"</command>
    <purpose>Establish rollback point</purpose>
  </step_1>
  
  <step_2>
    <action>Execute work</action>
    <work>{work_execution}</work>
  </step_2>
  
  <step_3>
    <action>If work fails: rollback via git</action>
    <on_failure>
      git reset --hard HEAD
      git clean -fd
      Log: "Rolled back to pre-work checkpoint"
    </on_failure>
  </step_3>
  
  <step_4>
    <action>If work succeeds: create success commit</action>
    <on_success>
      git add .
      git commit -m "Work completed successfully"
    </on_success>
  </step_4>
</git_rollback>
```

### Example

```markdown
<workflow_execution>
  <!-- Create rollback point -->
  <checkpoint>
    Delegate to git-workflow-manager:
      - action: "commit"
      - message: "Pre-implementation checkpoint for task 259"
    
    Wait for confirmation
  </checkpoint>
  
  <!-- Execute work -->
  <work>
    Delegate to implementer:
      - task_number: 259
    
    Wait for return
  </work>
  
  <!-- Handle success or failure -->
  <result_handling>
    If implementer returns {status: "failed"}:
      Delegate to git-workflow-manager:
        - action: "rollback"
        - target: "HEAD"
      
      Return error to caller
    
    Else if implementer returns {status: "completed"}:
      Delegate to git-workflow-manager:
        - action: "commit"
        - message: "task 259: implementation completed"
      
      Return success to caller
  </result_handling>
</workflow_execution>
```

**See Also**: `standards/git-safety.md` for git safety patterns

---

## Timing-Aware Delegation Instructions

### Purpose

Provide clear timing requirements when delegating to subagents.

### Pattern

```markdown
<delegation>
  <subagent>{subagent_name}</subagent>
  <context>{delegation_context}</context>
  <timing>
    <preflight>Update status BEFORE work begins</preflight>
    <work>Execute work</work>
    <postflight>Update status and link artifacts BEFORE return</postflight>
  </timing>
  <timeout>{timeout_seconds}s</timeout>
  <expected_return>{expected_return_format}</expected_return>
</delegation>
```

### Example

```markdown
<delegation>
  <subagent>task-executor</subagent>
  <context>
    - task_number: 259
    - plan_path: .opencode/specs/259_.../plan.md
    - session_id: sess_20260105_abc123
    - delegation_depth: 2
  </context>
  <timing>
    <preflight>
      BEFORE executing any phase:
        - Update task status to "in_progress"
        - Log start time
        - Validate preconditions
    </preflight>
    <work>
      Execute all phases sequentially:
        - Phase 1: Setup
        - Phase 2: Implementation
        - Phase 3: Testing
    </work>
    <postflight>
      AFTER all phases complete, BEFORE return:
        - Update task status to "completed"
        - Link all artifacts to task
        - Log completion time
        - Create git commit
    </postflight>
  </timing>
  <timeout>7200s (2 hours)</timeout>
  <expected_return>
    {
      "status": "completed",
      "artifacts": [{...}],
      "summary": "All phases completed"
    }
  </expected_return>
</delegation>
```

---

## Status Marker Conventions

### Purpose

Use consistent status markers for task state tracking.

### Standard Status Markers

**Task Status**:
- `not_started` - Task created but not started
- `in_progress` - Task currently being worked on
- `completed` - Task finished successfully
- `abandoned` - Task abandoned (not completed)
- `blocked` - Task blocked by dependency

**Phase Status** (in plans):
- `[NOT STARTED]` - Phase not yet begun
- `[IN PROGRESS]` - Phase currently executing
- `[COMPLETED]` - Phase finished successfully
- `[ABANDONED]` - Phase abandoned (not completed)
- `[BLOCKED]` - Phase blocked by dependency

**Validation Status** (in tests):
- `[PASS]` - Validation passed
- `[FAIL]` - Validation failed
- `[WARN]` - Validation warning (non-critical)

### Usage

```markdown
<status_transitions>
  <task_lifecycle>
    not_started → in_progress → completed
    not_started → abandoned
    in_progress → blocked → in_progress → completed
  </task_lifecycle>
  
  <phase_lifecycle>
    [NOT STARTED] → [IN PROGRESS] → [COMPLETED]
    [NOT STARTED] → [ABANDONED]
    [IN PROGRESS] → [BLOCKED] → [IN PROGRESS] → [COMPLETED]
  </phase_lifecycle>
</status_transitions>
```

**See Also**: `workflows/status-transitions.md` for status transition rules

---

## Cross-References

### Related Documentation

**State Management**:
- `orchestration/state-management.md` - State management patterns and atomic writes
- `orchestration/state-lookup.md` - Query patterns for state.json

**Status Transitions**:
- `workflows/status-transitions.md` - Status transition rules and validation

**Error Handling**:
- `standards/error-handling.md` - Error handling patterns and two-level logging

**Git Safety**:
- `standards/git-safety.md` - Git safety patterns and rollback strategies

**Architecture**:
- `orchestration/architecture.md` - Three-layer delegation pattern
- `formats/command-structure.md` - Command file anatomy and workflows

---

## Summary

**Key Principles**:

1. ✅ **Preflight BEFORE work**: Update status to "in_progress" BEFORE work begins
2. ✅ **Postflight BEFORE return**: Update status and link artifacts BEFORE returning
3. ✅ **Verification checkpoints**: Delegate → Wait → Verify → Proceed
4. ✅ **Atomic writes**: Write to temp, validate, rename atomically
5. ✅ **Two-level errors**: CRITICAL (blocking) vs NON-CRITICAL (warnings)
6. ✅ **Git-only rollback**: Use git for rollback, not manual backups
7. ✅ **Timing-aware delegation**: Provide clear timing requirements to subagents

**Common Patterns**:
- Preflight pattern (status update before work)
- Postflight pattern (status update and artifact linking after work)
- Verification checkpoint pattern (delegate → wait → verify → proceed)
- Atomic write pattern (temp file → validate → rename)
- Git rollback pattern (commit → work → rollback if failed)

**Avoid**:
- ❌ Updating status after work begins (preflight too late)
- ❌ Returning before status update (postflight too early)
- ❌ Proceeding without verification (skipping checkpoints)
- ❌ Direct writes to state.json (not atomic)
- ❌ Manual backup/restore (use git instead)

**Remember**: Correct timing of status updates and verification checkpoints prevents common workflow bugs and ensures state consistency.

---

**Version History**:
- v1.0 (2026-01-05): Initial version based on tasks 320 and 321 workflow standards
