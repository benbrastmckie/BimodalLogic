# Return Metadata File Schema

## Overview

Agents write structured metadata to files instead of returning JSON to the console. This enables reliable data exchange without console pollution and avoids the limitation where Claude treats JSON output as conversational text.

## File Location

```
specs/{N}_{SLUG}/.return-meta.json
```

Where:
- `{N}` = Task number (unpadded)
- `{SLUG}` = Task slug in snake_case

Example: `specs/259_prove_completeness/.return-meta.json`

## Schema

```json
{
  "status": "researched|planned|implemented|partial|failed|blocked",
  "artifacts": [
    {
      "type": "report|plan|summary|implementation",
      "path": "specs/259_prove_completeness/reports/research-001.md",
      "summary": "Brief 1-sentence description of artifact"
    }
  ],
  "next_steps": "Run /plan 259 to create implementation plan",
  "metadata": {
    "session_id": "sess_1736700000_abc123",
    "agent_type": "lean-research-agent",
    "duration_seconds": 180,
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "lean-research-agent"]
  },
  "errors": [
    {
      "type": "validation|execution|timeout",
      "message": "Error description",
      "recoverable": true,
      "recommendation": "How to fix"
    }
  ]
}
```

## Field Specifications

### status (required)

**Type**: enum
**Values**: Contextual success values or error states

| Value | Description |
|-------|-------------|
| `researched` | Research completed successfully |
| `planned` | Plan created successfully |
| `implemented` | Implementation completed successfully |
| `partial` | Partially completed, can resume |
| `failed` | Failed, cannot resume without fix |
| `blocked` | Blocked by external dependency |

**Note**: Never use `"completed"` - it triggers Claude stop behavior.

### artifacts (required)

**Type**: array of objects

Each artifact object:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | `report`, `plan`, `summary`, `implementation` |
| `path` | string | Yes | Relative path from project root |
| `summary` | string | Yes | Brief 1-sentence description |

### next_steps (optional)

**Type**: string
**Description**: What the user/orchestrator should do next

### metadata (required)

**Type**: object

| Field | Required | Description |
|-------|----------|-------------|
| `session_id` | Yes | Session ID from delegation context |
| `agent_type` | Yes | Name of agent (e.g., `lean-research-agent`) |
| `duration_seconds` | No | Execution time |
| `delegation_depth` | Yes | Nesting depth in delegation chain |
| `delegation_path` | Yes | Array of delegation steps |

Additional optional fields for specific agent types:
- `findings_count` - Number of research findings
- `phases_completed` - Implementation phases completed
- `phases_total` - Total implementation phases

### errors (optional)

**Type**: array of objects
**Include if**: status is `partial`, `failed`, or `blocked`

Each error object:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | Error category |
| `message` | string | Yes | Human-readable error message |
| `recoverable` | boolean | Yes | Whether retry may succeed |
| `recommendation` | string | Yes | How to fix or proceed |

## Agent Instructions

### Writing Metadata

At the end of execution, agents MUST:

1. Create the metadata file:
```bash
mkdir -p "specs/${task_number}_${task_slug}"
```

2. Write the JSON:
```json
// Write to specs/{N}_{SLUG}/.return-meta.json
{
  "status": "researched",
  "artifacts": [...],
  "metadata": {...}
}
```

3. Return a brief summary (NOT JSON) to the console:
```
Research completed for task 259:
- Found 5 relevant Mathlib theorems
- Identified proof strategy using structural induction
- Created report at specs/259_prove_completeness/reports/research-001.md
```

### Reading Metadata (Skill Postflight)

Skills read the metadata file during postflight:

```bash
# Read metadata file
metadata_file="specs/${task_number}_${task_slug}/.return-meta.json"
if [ -f "$metadata_file" ]; then
    status=$(jq -r '.status' "$metadata_file")
    artifact_path=$(jq -r '.artifacts[0].path' "$metadata_file")
    artifact_summary=$(jq -r '.artifacts[0].summary' "$metadata_file")
fi
```

### Cleanup

After postflight, delete the metadata file:

```bash
rm -f "specs/${task_number}_${task_slug}/.return-meta.json"
```

## Examples

### Research Success

```json
{
  "status": "researched",
  "artifacts": [
    {
      "type": "report",
      "path": "specs/259_prove_completeness/reports/research-001.md",
      "summary": "Research report with 5 Mathlib theorem findings and proof strategy"
    }
  ],
  "next_steps": "Run /plan 259 to create implementation plan",
  "metadata": {
    "session_id": "sess_1736700000_abc123",
    "agent_type": "lean-research-agent",
    "duration_seconds": 180,
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "lean-research-agent"],
    "findings_count": 5
  }
}
```

### Implementation Partial

```json
{
  "status": "partial",
  "artifacts": [
    {
      "type": "implementation",
      "path": "Logos/Layer1/Modal/Completeness.lean",
      "summary": "Partial completeness theorem (phases 1-2 of 4)"
    },
    {
      "type": "summary",
      "path": "specs/259_prove_completeness/summaries/implementation-summary-20260118.md",
      "summary": "Implementation summary with partial progress"
    }
  ],
  "next_steps": "Run /implement 259 to resume from phase 3",
  "metadata": {
    "session_id": "sess_1736700000_def456",
    "agent_type": "lean-implementation-agent",
    "duration_seconds": 3600,
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "lean-implementation-agent"],
    "phases_completed": 2,
    "phases_total": 4
  },
  "errors": [
    {
      "type": "timeout",
      "message": "Implementation timed out after 1 hour",
      "recoverable": true,
      "recommendation": "Resume with /implement 259"
    }
  ]
}
```

### Planning Success

```json
{
  "status": "planned",
  "artifacts": [
    {
      "type": "plan",
      "path": "specs/259_prove_completeness/plans/implementation-001.md",
      "summary": "4-phase implementation plan for completeness theorem"
    }
  ],
  "next_steps": "Run /implement 259 to execute the plan",
  "metadata": {
    "session_id": "sess_1736700000_ghi789",
    "agent_type": "planner-agent",
    "duration_seconds": 300,
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "plan", "planner-agent"],
    "phase_count": 4,
    "estimated_hours": 8
  }
}
```

## Relationship to subagent-return.md

This file-based format complements `subagent-return.md`:

| Aspect | subagent-return.md | return-metadata-file.md |
|--------|-------------------|------------------------|
| Purpose | Console JSON return | File-based metadata |
| Location | Agent's stdout | `specs/{N}_{SLUG}/.return-meta.json` |
| Consumer | Skill validation logic | Skill postflight operations |
| When | Before file-based pattern | With file-based pattern |
| Cleanup | N/A | Deleted after postflight |

**Migration path**: Skills migrate from validating console JSON to reading file metadata. The schema is nearly identical for compatibility.

## Related Documentation

- `.claude/context/core/formats/subagent-return.md` - Original console-based format
- `.claude/context/core/patterns/postflight-control.md` - Marker file protocol
- `.claude/context/core/patterns/file-metadata-exchange.md` - File I/O patterns
- `.claude/rules/state-management.md` - State update patterns
