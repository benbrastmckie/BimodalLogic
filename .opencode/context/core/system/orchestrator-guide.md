# Orchestrator Guide - Examples and Troubleshooting

**Version**: 1.0  
**Created**: 2025-12-29 (Task 245 Phase 5)  
**Purpose**: Examples, troubleshooting, and detailed guidance for orchestrator usage

---

## Overview

This guide provides detailed examples and troubleshooting information for the orchestrator router pattern. The orchestrator itself is simplified to ~80 lines focusing on routing logic. This guide contains the supporting documentation.

**Related Files**:
- `.opencode/agent/orchestrator.md` - Main orchestrator (routing logic)
- `.opencode/context/system/routing-guide.md` - Command→Agent mapping
- `.opencode/context/core/workflows/subagent-delegation-guide.md` - Delegation safety
- `.opencode/context/core/standards/subagent-return-format.md` - Return validation

---

## Delegation Registry

### Purpose

The delegation registry tracks all active delegations in memory for monitoring, timeout enforcement, and debugging.

### Schema

```javascript
{
  "sess_20251226_abc123": {
    "session_id": "sess_20251226_abc123",
    "command": "implement",
    "subagent": "task-executor",
    "task_number": 191,
    "language": "markdown",
    "start_time": "2025-12-26T10:00:00Z",
    "timeout": 3600,
    "deadline": "2025-12-26T11:00:00Z",
    "status": "running",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "task-executor"],
    
    // Command stage tracking (workflow commands only)
    "is_command": true,
    "command_stages": {
      "current_stage": 4,
      "stages_completed": [1, 2, 3],
      "stage_7_completed": false,
      "stage_7_artifacts": {
        "status_sync_manager_invoked": false,
        "status_sync_manager_completed": false,
        "todo_md_updated": false,
        "state_json_updated": false,
        "git_commit_created": false
      }
    }
  }
}
```

**Note**: `command_stages` tracking is only populated for workflow commands (plan, research, implement, revise). For direct subagent delegations, `is_command = false` and `command_stages` is omitted.

### Operations

| Operation | When | Purpose |
|-----------|------|---------|
| Register | Delegation start | Add entry to registry with session_id |
| Monitor | Periodic (every 60s) | Check for timeouts, update status |
| Update | Status changes | Update delegation status field |
| Complete | Delegation completion | Mark as completed, optionally remove |
| Cleanup | Timeout or error | Remove from registry, log error |

### Example: Register Delegation

```javascript
function register_delegation(session_id, context) {
  registry[session_id] = {
    "session_id": session_id,
    "command": context.command,
    "subagent": context.target_agent,
    "task_number": context.task_number,
    "language": context.language,
    "start_time": new Date().toISOString(),
    "timeout": context.timeout,
    "deadline": new Date(Date.now() + context.timeout * 1000).toISOString(),
    "status": "running",
    "delegation_depth": context.delegation_depth,
    "delegation_path": context.delegation_path,
    "is_command": context.is_command || false
  };
  
  if (context.is_command) {
    registry[session_id].command_stages = {
      "current_stage": 1,
      "stages_completed": [],
      "stage_7_completed": false,
      "stage_7_artifacts": {
        "status_sync_manager_invoked": false,
        "status_sync_manager_completed": false,
        "todo_md_updated": false,
        "state_json_updated": false,
        "git_commit_created": false
      }
    };
  }
}
```

### Example: Monitor Timeouts

```javascript
function monitor_delegations() {
  const now = new Date();
  
  for (const [session_id, delegation] of Object.entries(registry)) {
    if (delegation.status !== "running") continue;
    
    const deadline = new Date(delegation.deadline);
    if (now > deadline) {
      handle_timeout(session_id, delegation);
    }
  }
}

function handle_timeout(session_id, delegation) {
  delegation.status = "timeout";
  
  log_error({
    "type": "timeout",
    "session_id": session_id,
    "command": delegation.command,
    "subagent": delegation.subagent,
    "timeout": delegation.timeout,
    "task_number": delegation.task_number
  });
  
  // Check for partial artifacts
  const partial_artifacts = check_for_artifacts(delegation.task_number);
  
  // Return timeout error to user
  return_timeout_error(session_id, partial_artifacts);
  
  // Remove from registry
  delete registry[session_id];
}
```

---

## Cycle Detection

### Purpose

Prevent infinite delegation loops by tracking delegation paths and enforcing maximum depth.

### Maximum Depth

**Limit**: 3 levels

**Depth Counting**:
- Orchestrator → Command: depth = 0 (not counted)
- Command → Subagent: depth = 1
- Subagent → Specialist: depth = 2
- Specialist → Helper: depth = 3 (max)
- Helper → Another Agent: **BLOCKED** (exceeds limit)

### Detection Logic

```javascript
function check_cycle(delegation_path, target_agent) {
  // Check if target already in path (cycle)
  if (delegation_path.includes(target_agent)) {
    throw new CycleError(
      `Cycle detected: ${delegation_path.join(" → ")} → ${target_agent}`
    );
  }
  
  // Check depth limit
  if (delegation_path.length >= 3) {
    throw new DepthError(
      `Max delegation depth (3) exceeded: ${delegation_path.join(" → ")}`
    );
  }
  
  return false;
}
```

### Example: Valid Delegation Chain

```
Orchestrator → /implement → task-executor → implementer → git-workflow-manager
    (depth 0)      (depth 1)      (depth 2)       (depth 3)
                                                   ↑ MAX DEPTH
```

### Example: Blocked Delegation

```
Orchestrator → /implement → task-executor → implementer → git-workflow-manager → ???
    (depth 0)      (depth 1)      (depth 2)       (depth 3)         (BLOCKED)
```

**Error**: "Max delegation depth (3) exceeded"

---

## Session Tracking

### Purpose

Unique session IDs enable tracking, debugging, and validation of delegation chains.

### Format

`sess_{timestamp}_{random_6char}`

**Example**: `sess_1703606400_a1b2c3`

### Generation

```javascript
function generate_session_id() {
  const timestamp = Math.floor(Date.now() / 1000);
  const random_chars = Array.from({length: 6}, () => 
    '0123456789abcdefghijklmnopqrstuvwxyz'[Math.floor(Math.random() * 36)]
  ).join('');
  
  return `sess_${timestamp}_${random_chars}`;
}
```

### Usage

1. **Generate** before invoking subagent
2. **Pass** to subagent in delegation context
3. **Validate** in subagent return metadata
4. **Track** in delegation registry
5. **Log** for debugging and error tracking

---

## Timeout Enforcement

### Purpose

Prevent indefinite hangs by enforcing timeouts on all delegations with partial result recovery.

### Default Timeouts

| Operation | Timeout | Justification |
|-----------|---------|---------------|
| Research | 3600s (1 hour) | Research can be extensive |
| Planning | 1800s (30 min) | Planning is structured |
| Implementation | 7200s (2 hours) | Most complex, multiple phases |
| Simple operations | 300s (5 min) | Quick operations |

### Timeout Handling

```javascript
try {
  result = invoke_subagent(timeout=3600);
} catch (TimeoutError) {
  // Graceful degradation
  partial_results = check_for_artifacts();
  
  return {
    "status": "partial",
    "summary": "Operation timed out after 3600s",
    "artifacts": partial_results,
    "errors": [{
      "type": "timeout",
      "message": "Subagent exceeded timeout",
      "code": "TIMEOUT",
      "recoverable": true,
      "recommendation": "Resume with same command to continue"
    }]
  };
}
```

### Principles

- Never wait indefinitely
- Return partial results if available
- Mark task as IN PROGRESS (not failed)
- Provide actionable recovery message

---

## Return Validation

### Purpose

Validate all subagent returns against standardized format to ensure consistent parsing.

### Validation Steps

1. Check return is valid JSON/structured format
2. Validate against `subagent-return-format.md` schema
3. Check session_id matches expected
4. Validate all required fields present
5. Check status is valid enum value
6. Validate summary within length limits
7. Validate artifacts have valid paths

### Validation Logic

```javascript
function validate_return(return_obj, expected_session_id) {
  // 1. Check JSON structure
  if (typeof return_obj !== 'object') {
    throw new ValidationError("Return must be JSON object");
  }
  
  // 2. Check required fields
  const required = ["status", "summary", "artifacts", "metadata"];
  for (const field of required) {
    if (!(field in return_obj)) {
      throw new ValidationError(`Missing required field: ${field}`);
    }
  }
  
  // 3. Validate status
  const valid_statuses = ["completed", "failed", "partial", "blocked"];
  if (!valid_statuses.includes(return_obj.status)) {
    throw new ValidationError(`Invalid status: ${return_obj.status}`);
  }
  
  // 4. Check session ID
  const actual_session = return_obj.metadata.session_id;
  if (actual_session !== expected_session_id) {
    throw new ValidationError(
      `Session ID mismatch: ${actual_session} != ${expected_session_id}`
    );
  }
  
  // 5. Validate summary length
  const summary = return_obj.summary;
  if (summary.length === 0) {
    throw new ValidationError("Summary cannot be empty");
  }
  if (summary.length > 500) {
    throw new ValidationError("Summary too long (max 500 chars)");
  }
  
  return true;
}
```

### Validation Failure Handling

If validation fails:
1. Log validation error with details
2. Return failed status
3. Include original return for debugging
4. Recommend subagent fix

---

## Troubleshooting

### Symptom: Delegation Hangs

**Cause**: Missing timeout or return validation

**Fix**:
1. Check timeout is set (default 3600s)
2. Verify subagent returns standardized format
3. Check session_id tracking
4. Enable delegation registry monitoring

### Symptom: Infinite Loop

**Cause**: Cycle in delegation path

**Fix**:
1. Enable cycle detection
2. Check delegation_path before routing
3. Verify depth limit enforced (max 3)
4. Log delegation paths for debugging

### Symptom: Timeout Too Short/Long

**Cause**: Incorrect timeout for operation type

**Fix**:
1. Adjust timeout based on operation:
   - Research: 3600s (1 hour)
   - Planning: 1800s (30 min)
   - Implementation: 7200s (2 hours)
2. Make timeout configurable per command
3. Monitor actual durations and adjust

### Symptom: Return Validation Failures

**Cause**: Subagent not following standard format

**Fix**:
1. Update subagent to follow subagent-return-format.md
2. Add validation before returning
3. Test subagent independently
4. Check session_id matches

### Symptom: Stage 7 Not Executing

**Cause**: Command skips postflight stage

**Fix**:
1. Check command_stages tracking in registry
2. Verify stage_7_completed flag
3. Check status-sync-manager invocation
4. Validate TODO.md and state.json updates

### Symptom: Wrong Agent Routed

**Cause**: Language extraction failed or routing logic incorrect

**Fix**:
1. Verify language extracted from TODO.md
2. Check routing-guide.md for correct mapping
3. Log routing decision for debugging
4. Validate language field in task entry

---

## Examples

### Example 1: Simple Research Delegation

```
User: /research 197

Orchestrator:
1. Load command file: .opencode/command/research.md
2. Extract language from TODO.md: "lean"
3. Route to: lean-research-agent
4. Generate session_id: sess_1703606400_a1b2c3
5. Register delegation in registry
6. Invoke lean-research-agent with context
7. Monitor timeout (3600s)
8. Receive return, validate format
9. Complete delegation, remove from registry
10. Return success to user
```

### Example 2: Phased Implementation with Timeout

```
User: /implement 191

Orchestrator:
1. Load command file: .opencode/command/implement.md
2. Extract language from TODO.md: "markdown"
3. Check for plan: Yes (plan-001.md)
4. Route to: task-executor
5. Generate session_id: sess_1703606401_d4e5f6
6. Register delegation in registry
7. Invoke task-executor with plan_path
8. Monitor timeout (7200s)
9. Timeout after 3600s (phase 2 incomplete)
10. Check for partial artifacts: phase 1 complete
11. Return partial status with resume instructions
12. Keep delegation in registry as "partial"
```

### Example 3: Cycle Detection

```
User: /implement 192 (complex delegation chain)

Orchestrator:
1. Load command file: .opencode/command/implement.md
2. Route to: task-executor
3. task-executor delegates to: implementer
4. implementer delegates to: git-workflow-manager
5. git-workflow-manager attempts to delegate to: task-executor
6. Cycle detected: ["orchestrator", "implement", "task-executor", "implementer", "git-workflow-manager", "task-executor"]
7. Block delegation, return error
8. Error: "Cycle detected: orchestrator → implement → task-executor → implementer → git-workflow-manager → task-executor"
```

---

## Related Documentation

- **Orchestrator**: `.opencode/agent/orchestrator.md`
- **Routing Guide**: `.opencode/context/system/routing-guide.md`
- **Delegation Guide**: `.opencode/context/core/workflows/subagent-delegation-guide.md`
- **Return Format**: `.opencode/context/core/standards/subagent-return-format.md`
- **Command Lifecycle**: `.opencode/context/core/workflows/command-lifecycle.md`
