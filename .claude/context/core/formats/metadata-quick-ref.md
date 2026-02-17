# Metadata Quick Reference

**Full Schema**: @.claude/context/core/formats/return-metadata-file.md (for edge cases)

## File Location

```
specs/{N}_{SLUG}/.return-meta.json
```

## Essential Fields

### status (required)

| Value | When to Use |
|-------|-------------|
| `in_progress` | Early metadata (Stage 0) |
| `researched` | Research complete |
| `planned` | Plan created |
| `implemented` | Implementation complete |
| `partial` | Partially done, can resume |
| `failed` | Cannot proceed without fix |
| `blocked` | External dependency needed |

**Never use "completed"** - triggers stop behavior.

### artifacts (required)

```json
"artifacts": [
  {
    "type": "summary",
    "path": "specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md",
    "summary": "Brief 1-sentence description"
  }
]
```

**Types**: `report`, `plan`, `summary`, `implementation`

### metadata (required)

```json
"metadata": {
  "session_id": "sess_...",
  "agent_type": "lean-implementation-agent",
  "delegation_depth": 1,
  "phases_completed": 2,
  "phases_total": 4
}
```

### completion_data (for implemented status)

```json
"completion_data": {
  "completion_summary": "1-3 sentence description",
  "claudemd_suggestions": "Description or 'none' (meta only)"
}
```

### partial_progress (for in_progress/partial)

```json
"partial_progress": {
  "stage": "phase_2_completed",
  "details": "Completed phases 1-2 of 4",
  "phases_completed": 2,
  "phases_total": 4
}
```

## Common Patterns

### Early Metadata (Stage 0)

```json
{
  "status": "in_progress",
  "started_at": "2026-02-16T10:00:00Z",
  "artifacts": [],
  "partial_progress": {
    "stage": "initializing",
    "details": "Agent started"
  },
  "metadata": {
    "session_id": "...",
    "agent_type": "..."
  }
}
```

### Implemented (All Phases Complete)

```json
{
  "status": "implemented",
  "artifacts": [
    {"type": "summary", "path": "...", "summary": "..."}
  ],
  "completion_data": {
    "completion_summary": "..."
  },
  "metadata": {...}
}
```

### Partial (Some Phases Complete)

```json
{
  "status": "partial",
  "artifacts": [
    {"type": "summary", "path": "...", "summary": "..."}
  ],
  "partial_progress": {
    "stage": "phase_3_blocked",
    "phases_completed": 2,
    "phases_total": 4
  },
  "metadata": {...}
}
```

## Key Rules

1. **Write early metadata** at Stage 0 before substantive work
2. **Include summary artifact** for both `implemented` and `partial` status
3. **Return text summary** to console, NOT JSON
4. **Never use "completed"** as status value
