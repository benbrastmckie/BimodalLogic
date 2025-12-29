# Subagent Return Format Standard

**Version**: 1.0
**Status**: Active
**Created**: 2025-12-26
**Purpose**: Define unified return format for all subagent invocations to prevent delegation hangs and ensure consistent parsing

---

## Overview

All subagents MUST return a standardized JSON object when invoked by commands or other agents. This standard prevents the delegation hang issues identified in Task 191 by ensuring:

- Predictable return format that commands can parse reliably
- Clear status indication (completed, failed, partial, blocked)
- Artifact tracking for all created/modified files
- Error information for debugging
- Session tracking to prevent delegation loops

**Root Cause Addressed**: Task 191 Root Cause #6 (Return Format Ambiguity)

---

## Standard Return Format

```json
{
  "status": "completed|failed|partial|blocked",
  "summary": "Brief 2-5 sentence summary (max 100 tokens)",
  "artifacts": [
    {
      "type": "research|plan|implementation|summary|documentation",
      "path": "relative/path/from/project/root",
      "summary": "Optional one-sentence description"
    }
  ],
  "metadata": {
    "session_id": "unique_session_identifier",
    "duration_seconds": 123,
    "agent_type": "agent_name",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "command", "agent"]
  },
  "errors": [
    {
      "type": "timeout|validation|execution|tool_unavailable",
      "message": "Human-readable error description",
      "code": "ERROR_CODE",
      "recoverable": true,
      "recommendation": "Suggested fix or next step"
    }
  ],
  "next_steps": "Optional recommended next actions"
}
```

---

## Field Specifications

### status (required)

**Type**: String enum
**Values**: `completed` | `failed` | `partial` | `blocked`

- `completed`: All work finished successfully
- `failed`: Work failed, no usable results
- `partial`: Some work completed, partial results available (e.g., timeout)
- `blocked`: Cannot proceed, requires external resolution

**Validation**: Must be exactly one of the four values (case-sensitive)

### summary (required)

**Type**: String
**Length**: 2-5 sentences, max 100 tokens (approximately 400 characters)

**Guidelines**:
- Focus on outcomes, not process
- Be specific about what was created or changed
- Mention key decisions or blockers
- No emojis or formatting markup

**Example**: "Created implementation plan for task 191 with 3 phases. Plan addresses 6 root causes of delegation hangs through explicit return handling, cycle detection, and timeout mechanisms. Estimated 14 hours total effort."

### artifacts (required, can be empty array)

**Type**: Array of artifact objects

**Artifact Object**:
```json
{
  "type": "research|plan|implementation|summary|documentation",
  "path": "relative/path/from/root",
  "summary": "Optional one-sentence description"
}
```

**Validation**:
- Paths must be relative from project root
- All paths must exist or be created during execution
- Type must match artifact purpose

### metadata (required)

**Type**: Object with required fields

**Required Fields**:
- `session_id`: Unique identifier for this delegation (format: `sess_{timestamp}_{random}`)
- `duration_seconds`: Execution time in seconds
- `agent_type`: Name of the agent returning results
- `delegation_depth`: Current depth in delegation chain (prevents cycles)
- `delegation_path`: Array of agent names in delegation chain

**Purpose**: Enables cycle detection and delegation tracking

### errors (optional, empty array if no errors)

**Type**: Array of error objects

**Error Object**:
```json
{
  "type": "timeout|validation|execution|tool_unavailable",
  "message": "Human-readable description",
  "code": "ERROR_CODE",
  "recoverable": true,
  "recommendation": "Suggested fix"
}
```

**When to Include**:
- Status is `failed` or `partial`: MUST include errors
- Status is `blocked`: MUST include error explaining blocker
- Status is `completed`: errors array should be empty

### next_steps (optional)

**Type**: String (1-2 sentences)

**When to Include**:
- Recommend follow-up actions
- Suggest alternative approaches after failure
- Indicate dependencies or prerequisites

---

## Validation Requirements

All subagents MUST validate their return before sending:

1. **Required fields present**: status, summary, artifacts, metadata
2. **Status is valid enum**: One of the four allowed values
3. **Summary within limits**: 2-5 sentences, max 100 tokens
4. **Artifacts valid**: All paths exist, types match
5. **Metadata complete**: session_id, duration, agent_type, delegation info
6. **Errors match status**: If failed/partial/blocked, errors present

**Validation Failure**: If validation fails, return a `failed` status with error explaining validation failure.

---

## Usage in Commands

Commands that invoke subagents MUST:

1. **Generate session_id** before invoking subagent
2. **Pass delegation context** (depth, path) to prevent cycles
3. **Set timeout** (default 3600s) for subagent invocation
4. **Validate return format** against this schema
5. **Extract artifacts** from validated return
6. **Handle errors** based on status and error array
7. **Update state** based on return status

**Example Command Pattern**:
```xml
<stage id="3" name="InvokeSubagent">
  <action>Invoke subagent with session tracking</action>
  <process>
    1. Generate session_id: sess_{timestamp}_{random}
    2. Prepare delegation context (depth, path)
    3. Invoke subagent with timeout 3600s
    4. Store session_id for tracking
  </process>
</stage>

<stage id="4" name="ReceiveResults">
  <action>Receive and validate subagent return</action>
  <process>
    1. Wait for subagent completion (max 3600s)
    2. Receive return object
    3. Validate against subagent-return-format.md
    4. Check session_id matches
    5. Handle timeout if no return
  </process>
  <timeout_handling>
    If timeout (3600s exceeded):
      - Log timeout with session_id
      - Check for partial artifacts
      - Mark task as IN PROGRESS (not failed)
      - Return actionable message to user
  </timeout_handling>
</stage>

<stage id="5" name="ProcessResults">
  <action>Process validated return</action>
  <process>
    1. Extract status from return
    2. Extract artifacts and link in .opencode/specs/TODO.md
    3. Extract summary for user
    4. Handle errors if status != completed
    5. Proceed to postflight
  </process>
</stage>
```

---

## Error Codes

Standardized error codes for consistent error handling:

- `TIMEOUT`: Operation exceeded time limit
- `VALIDATION_FAILED`: Input validation failed
- `TOOL_UNAVAILABLE`: Required tool (lean-lsp-mcp, etc.) not available
- `BUILD_ERROR`: Compilation or build failed
- `FILE_NOT_FOUND`: Required file missing
- `CYCLE_DETECTED`: Delegation would create cycle
- `MAX_DEPTH_EXCEEDED`: Delegation depth limit (3) exceeded
- `STATUS_SYNC_FAILED`: Failed to update .opencode/specs/TODO.md/state.json
- `GIT_COMMIT_FAILED`: Failed to create git commit
- `UNKNOWN_ERROR`: Unexpected error occurred

---

## Examples

### Successful Research Completion

```json
{
  "status": "completed",
  "summary": "Research completed on LeanExplore, Loogle, and LeanSearch integration. Found official APIs for all three tools. LeanExplore uses HTTP API, Loogle has CLI interface, LeanSearch provides REST endpoints. Recommend REST API integration for LeanSearch first.",
  "artifacts": [
    {
      "type": "research",
      "path": ".opencode/specs/195_lean_tools_research/reports/research-001.md",
      "summary": "Detailed API specifications for all three Lean tools"
    },
    {
      "type": "summary",
      "path": ".opencode/specs/195_lean_tools_research/summaries/research-summary.md",
      "summary": "Key findings and integration recommendations"
    }
  ],
  "metadata": {
    "session_id": "sess_20251226_abc123",
    "duration_seconds": 1250,
    "agent_type": "researcher",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research-command", "researcher"]
  },
  "errors": [],
  "next_steps": "Create implementation plan for LeanSearch REST API integration"
}
```

### Partial Completion (Timeout)

```json
{
  "status": "partial",
  "summary": "Implementation of task 191 phase 1 started but timed out after 1 hour. Successfully completed return format standardization and updated /implement command. Remaining work: update /research and /plan commands with return handling.",
  "artifacts": [
    {
      "type": "implementation",
      "path": ".opencode/context/common/standards/subagent-return-format.md",
      "summary": "Standardized return format specification"
    },
    {
      "type": "implementation",
      "path": ".opencode/command/implement.md",
      "summary": "Updated with ReceiveResults and ProcessResults stages"
    }
  ],
  "metadata": {
    "session_id": "sess_20251226_def456",
    "duration_seconds": 3600,
    "agent_type": "implementer",
    "delegation_depth": 2,
    "delegation_path": ["orchestrator", "implement-command", "task-executor", "implementer"]
  },
  "errors": [
    {
      "type": "timeout",
      "message": "Implementation exceeded 3600s timeout",
      "code": "TIMEOUT",
      "recoverable": true,
      "recommendation": "Run /implement 191 again to resume from phase 2"
    }
  ],
  "next_steps": "Resume implementation by running /implement 191"
}
```

### Failed Execution

```json
{
  "status": "failed",
  "summary": "Failed to implement Lean proof due to lean-lsp-mcp unavailability. Checked .mcp.json configuration and attempted fallback to direct Lean compilation. Both approaches failed.",
  "artifacts": [],
  "metadata": {
    "session_id": "sess_20251226_ghi789",
    "duration_seconds": 45,
    "agent_type": "lean-implementation-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement-command", "lean-implementation-agent"]
  },
  "errors": [
    {
      "type": "tool_unavailable",
      "message": "lean-lsp-mcp not available in .mcp.json",
      "code": "TOOL_UNAVAILABLE",
      "recoverable": true,
      "recommendation": "Install lean-lsp-mcp: uvx lean-lsp-mcp"
    }
  ],
  "next_steps": "Install lean-lsp-mcp and retry implementation"
}
```

---

## Migration from Old System

Old subagents using inconsistent return formats should be updated:

1. **Identify return pattern** in old agent
2. **Map to standard format** using conversion rules:
   - Old: "summary" → New: "summary"
   - Old: "artifacts" → New: "artifacts" (validate structure)
   - Old: "key_findings" → New: Include in "summary"
   - Old: "project_number" → New: Extract from first artifact path
3. **Add missing fields** (metadata, errors)
4. **Validate** before deploying updated agent

---

## Related Documentation

- Task 191 Research: `.opencode/specs/191_fix_subagent_delegation_hang/reports/research-001.md`
- Task 191 Plan: `.opencode/specs/191_fix_subagent_delegation_hang/plans/implementation-001.md`
- Delegation Workflow: `.opencode/context/common/workflows/delegation.md`
- Status Markers: `.opencode/context/common/system/status-markers.md`
