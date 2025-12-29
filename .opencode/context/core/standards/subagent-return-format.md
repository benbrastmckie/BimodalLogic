# Subagent Return Format Standard

## Schema

All subagents MUST return this JSON structure:

```json
{
  "status": "completed|partial|failed|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "plan|report|summary|implementation|documentation",
      "path": "relative/path/to/artifact.md",
      "summary": "Brief description of artifact"
    }
  ],
  "metadata": {
    "session_id": "sess_1735460684_a1b2c3",
    "duration_seconds": 123,
    "agent_type": "planner|researcher|implementer|...",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "plan", "planner"]
  },
  "errors": [
    {
      "type": "validation|execution|timeout|...",
      "message": "Clear error description",
      "recoverable": true|false,
      "recommendation": "How to fix or retry"
    }
  ],
  "next_steps": "What user should do next (if applicable)"
}
```

## Field Specifications

### status (required)
**Type**: enum  
**Values**: `completed`, `partial`, `failed`, `blocked`  
**Description**:
- `completed`: Task fully completed, all artifacts created
- `partial`: Task partially completed, some artifacts created, can resume
- `failed`: Task failed, no usable artifacts, cannot resume
- `blocked`: Task blocked by external dependency, can retry later

### summary (required)
**Type**: string  
**Constraints**: <100 tokens (~400 characters)  
**Description**: Brief 2-5 sentence summary of what was done  
**Purpose**: Protects orchestrator context window from bloat

### artifacts (required)
**Type**: array of objects  
**Can be empty**: Yes (if status=failed or blocked)  
**Description**: List of files created by agent

**Artifact object**:
```json
{
  "type": "plan|report|summary|implementation|documentation",
  "path": "relative/path/from/project/root",
  "summary": "Brief description"
}
```

### metadata (required)
**Type**: object  
**Required fields**:
- `session_id`: Must match expected session_id from delegation
- `agent_type`: Name of agent (planner, researcher, etc.)
- `delegation_depth`: Current depth in delegation chain
- `delegation_path`: Full path from orchestrator to this agent

**Optional fields**:
- `duration_seconds`: How long agent took
- `phase_count`: Number of phases (for plans)
- `estimated_hours`: Effort estimate (for plans)
- `findings_count`: Number of findings (for research)

### errors (optional)
**Type**: array of objects  
**Required if**: status != completed  
**Description**: List of errors encountered

**Error object**:
```json
{
  "type": "validation|execution|timeout|permission|...",
  "message": "Clear, actionable error message",
  "recoverable": true|false,
  "recommendation": "How to fix or what to do next"
}
```

### next_steps (optional)
**Type**: string  
**Description**: What user should do next (e.g., "Run /implement 244")

## Validation Rules

### Orchestrator Validation (Stage 6)

1. **JSON Validity**: Return must be valid JSON
2. **Required Fields**: status, summary, artifacts, metadata must be present
3. **Status Enum**: status must be one of: completed, partial, failed, blocked
4. **Session ID Match**: metadata.session_id must match expected session_id
5. **Summary Length**: summary must be <100 tokens
6. **Artifacts Exist**: If status=completed, all artifact paths must exist on disk

### Validation Failures

If validation fails:
1. Log error to errors.json
2. Return failed status to user
3. Include validation errors in response
4. Recommendation: "Fix {agent} subagent return format"

## Examples

### Completed Plan
```json
{
  "status": "completed",
  "summary": "Created implementation plan for task 244 with 3 phases. Plan focuses on context reorganization, orchestrator streamlining, and command simplification. Estimated effort: 8 hours.",
  "artifacts": [
    {
      "type": "plan",
      "path": ".opencode/specs/244_context_refactor/plans/implementation-001.md",
      "summary": "3-phase implementation plan"
    }
  ],
  "metadata": {
    "session_id": "sess_1735460684_a1b2c3",
    "duration_seconds": 245,
    "agent_type": "planner",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "plan", "planner"],
    "phase_count": 3,
    "estimated_hours": 8
  },
  "next_steps": "Run /implement 244 to execute the plan"
}
```

### Failed Research
```json
{
  "status": "failed",
  "summary": "Research failed due to network timeout when accessing LeanSearch API. No research artifacts created.",
  "artifacts": [],
  "metadata": {
    "session_id": "sess_1735460684_xyz789",
    "duration_seconds": 30,
    "agent_type": "lean-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "lean-research-agent"]
  },
  "errors": [
    {
      "type": "timeout",
      "message": "LeanSearch API request timed out after 30s",
      "recoverable": true,
      "recommendation": "Check network connection and retry with /research 245"
    }
  ],
  "next_steps": "Retry after checking network connection"
}
```

### Partial Implementation
```json
{
  "status": "partial",
  "summary": "Completed phases 1-2 of 3. Phase 3 interrupted due to timeout. Implementation files created for phases 1-2.",
  "artifacts": [
    {
      "type": "implementation",
      "path": "src/module_a.lean",
      "summary": "Phase 1 implementation"
    },
    {
      "type": "implementation",
      "path": "src/module_b.lean",
      "summary": "Phase 2 implementation"
    },
    {
      "type": "summary",
      "path": ".opencode/specs/246_feature/summaries/implementation-summary.md",
      "summary": "Partial implementation summary"
    }
  ],
  "metadata": {
    "session_id": "sess_1735460684_abc123",
    "duration_seconds": 7200,
    "agent_type": "lean-implementation-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "lean-implementation-agent"]
  },
  "errors": [
    {
      "type": "timeout",
      "message": "Implementation timed out after 7200s during phase 3",
      "recoverable": true,
      "recommendation": "Resume with /implement 246 to continue from phase 3"
    }
  ],
  "next_steps": "Run /implement 246 to resume from phase 3"
}
```
