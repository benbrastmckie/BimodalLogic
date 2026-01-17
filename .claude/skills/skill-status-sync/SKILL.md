---
name: skill-status-sync
description: Atomically update task status across TODO.md and state.json. Invoke when task status changes.
allowed-tools: Task
context: fork
agent: status-sync-agent
---

# Status Sync Skill

Thin wrapper that delegates status synchronization to `status-sync-agent` subagent.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/core/validation.md`
- Purpose: Return validation at GATE OUT checkpoint
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:
- Task status needs to change (preflight/postflight updates)
- Artifacts are added to a task
- Status synchronization is needed between TODO.md and state.json

## API Operations

This skill exposes three primary operations:

| Operation | Purpose | When to Use |
|-----------|---------|-------------|
| `preflight_update` | Set in-progress status | GATE IN checkpoint |
| `postflight_update` | Set completed status + link artifacts | GATE OUT checkpoint |
| `artifact_link` | Add single artifact link (idempotent) | Post-artifact creation |

---

## Execution

### 1. Input Validation

Validate required inputs based on operation type:

**For preflight_update**:
- `task_number` - Must be provided and exist in state.json
- `target_status` - Must be an in-progress variant (researching, planning, implementing)
- `session_id` - Must be provided for traceability

**For postflight_update**:
- `task_number` - Must be provided and exist
- `target_status` - Must be a completed variant (researched, planned, completed, partial)
- `artifacts` - Array of {path, type} to link
- `session_id` - Must be provided

**For artifact_link**:
- `task_number` - Must be provided and exist
- `artifact_path` - Relative path to artifact
- `artifact_type` - One of: research, plan, summary

### 2. Context Preparation

Prepare delegation context:

```json
{
  "operation": "preflight_update|postflight_update|artifact_link",
  "task_number": N,
  "target_status": "{status}",
  "artifacts": [{"path": "...", "type": "..."}],
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "{command}", "skill-status-sync"]
}
```

### 3. Invoke Subagent

**CRITICAL**: You MUST use the **Task** tool to spawn the subagent.

The `agent` field in this skill's frontmatter specifies the target: `status-sync-agent`

**Required Tool Invocation**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "status-sync-agent"
  - prompt: [Include operation, task_number, target_status, artifacts, session_id]
  - description: "Execute status sync for task {N}"
```

**DO NOT** use `Skill(status-sync-agent)` - this will FAIL.
Agents live in `.claude/agents/`, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.

The subagent will:
- Load state files (state.json, TODO.md)
- Validate task exists and status transition is valid
- Execute the requested operation
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: synced, linked, skipped, failed, or target status value
- Summary is non-empty and <100 tokens
- Metadata contains session_id, agent_type, delegation info

### 5. Return Propagation

Return validated result to caller without modification.

---

## Return Format

See `.claude/context/core/formats/subagent-return.md` for full specification.

### preflight_update returns:
```json
{
  "status": "synced",
  "summary": "Updated task #N to [STATUS]",
  "artifacts": [],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "status-sync-agent",
    "delegation_depth": 1,
    "delegation_path": ["...", "status-sync-agent"]
  },
  "previous_status": "not_started",
  "new_status": "researching"
}
```

### postflight_update returns:
```json
{
  "status": "{target_status}",
  "summary": "Updated task #N to [STATUS] with N artifacts",
  "artifacts": [],
  "metadata": {...},
  "artifacts_linked": ["path1", "path2"],
  "previous_status": "researching",
  "new_status": "researched"
}
```

### artifact_link returns:
```json
{
  "status": "linked|skipped",
  "summary": "Linked artifact to task #N" | "Link already exists",
  "artifacts": [],
  "metadata": {...},
  "artifact_path": "path/to/artifact.md",
  "artifact_type": "research"
}
```

---

## Error Handling

### Input Validation Errors
Return immediately with failed status if operation type is unknown or required fields are missing.

### Subagent Errors
Pass through the subagent's error return verbatim.

### Timeout
Return failed status if subagent times out (default 60s for status operations).

---

## Integration Notes

Command files should use this skill for ALL status updates:

```
# In command file:
### Preflight (GATE IN)
Invoke skill-status-sync with:
- operation: preflight_update
- task_number: {N}
- target_status: researching|planning|implementing
- session_id: {session_id}

### Postflight (GATE OUT)
Invoke skill-status-sync with:
- operation: postflight_update
- task_number: {N}
- target_status: researched|planned|completed|partial
- artifacts: [{path, type}, ...]
- session_id: {session_id}
```

This ensures:
- Atomic updates across both files
- Consistent jq/grep patterns
- Proper error handling
- No workflow interruptions (forked pattern)
