# State JSON Schema

Complete schema reference for state.json. For quick overview, see CLAUDE.md.

## Full Structure

```json
{
  "next_project_number": 346,
  "active_projects": [
    {
      "project_number": 334,
      "project_name": "task_slug_here",
      "status": "planned",
      "language": "lean",
      "effort": "4 hours",
      "created": "2026-01-08T10:00:00Z",
      "last_updated": "2026-01-08T14:30:00Z",
      "artifacts": [
        {
          "type": "research",
          "path": "specs/334_task_slug_here/reports/research-001.md",
          "summary": "Brief 1-sentence description of artifact"
        }
      ],
      "completion_summary": "1-3 sentence description of what was accomplished",
      "roadmap_items": ["Optional explicit roadmap item text to match"],
      "claudemd_suggestions": "Description of .claude/ changes (meta tasks only)"
    }
  ],
  "repository_health": {
    "last_assessed": "2026-01-29T18:38:22Z",
    "sorry_count": 295,
    "axiom_count": 10,
    "build_errors": 0,
    "status": "manageable"
  }
}
```

## Field Reference

### Project Entry Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `project_number` | number | Yes | Unique task identifier |
| `project_name` | string | Yes | Snake_case slug from title |
| `status` | string | Yes | Current status (see Status Values) |
| `language` | string | Yes | Task language (lean, latex, typst, general, meta, markdown) |
| `effort` | string | No | Estimated effort |
| `created` | string | Yes | ISO8601 creation timestamp |
| `last_updated` | string | Yes | ISO8601 last update timestamp |
| `artifacts` | array | No | Array of artifact objects |

### Artifact Object Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | Artifact type: `research`, `plan`, `summary`, `implementation` |
| `path` | string | Yes | Relative path from project root |
| `summary` | string | Yes | Brief 1-sentence description |

### Completion Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `completion_summary` | string | Yes (when completed) | 1-3 sentence summary of accomplishment |
| `roadmap_items` | array | No | Explicit ROAD_MAP.md item texts (non-meta only) |
| `claudemd_suggestions` | string | Yes (meta only) | .claude/ changes made, or "none" |

### Repository Health Fields

| Field | Type | Description |
|-------|------|-------------|
| `last_assessed` | string | ISO8601 timestamp of last metrics update |
| `sorry_count` | number | Total `sorry` occurrences in Theories/ |
| `axiom_count` | number | Total `axiom` declarations in Theories/ |
| `build_errors` | number | Current build error count |
| `status` | string | `manageable`, `concerning`, or `critical` |

## Status Values

| TODO.md Marker | state.json status |
|----------------|-------------------|
| [NOT STARTED] | not_started |
| [RESEARCHING] | researching |
| [RESEARCHED] | researched |
| [PLANNING] | planning |
| [PLANNED] | planned |
| [IMPLEMENTING] | implementing |
| [COMPLETED] | completed |
| [BLOCKED] | blocked |
| [ABANDONED] | abandoned |
| [PARTIAL] | partial |
| [EXPANDED] | expanded |

## Examples

### New Task Entry
```json
{
  "project_number": 500,
  "project_name": "implement_new_feature",
  "status": "not_started",
  "language": "lean",
  "created": "2026-02-25T10:00:00Z",
  "last_updated": "2026-02-25T10:00:00Z",
  "artifacts": []
}
```

### Completed Task Entry
```json
{
  "project_number": 500,
  "project_name": "implement_new_feature",
  "status": "completed",
  "language": "lean",
  "created": "2026-02-25T10:00:00Z",
  "last_updated": "2026-02-25T16:00:00Z",
  "artifacts": [
    {
      "type": "research",
      "path": "specs/500_implement_new_feature/reports/research-001.md",
      "summary": "Research on feature implementation approaches"
    },
    {
      "type": "plan",
      "path": "specs/500_implement_new_feature/plans/implementation-001.md",
      "summary": "4-phase implementation plan"
    },
    {
      "type": "summary",
      "path": "specs/500_implement_new_feature/summaries/implementation-summary-20260225.md",
      "summary": "Implementation summary with verification results"
    }
  ],
  "completion_summary": "Implemented new feature with 4 supporting lemmas."
}
```
