# Team Metadata Extension

Schema extension for `.return-meta.json` when using team mode execution.

## Extended Schema

When a skill executes in team mode, the metadata file includes additional fields:

```json
{
  "status": "researched|planned|implemented|partial|failed",
  "summary": "Brief 2-5 sentence summary",
  "artifacts": [
    {
      "type": "research|plan|implementation",
      "path": "specs/{N}_{SLUG}/...",
      "summary": "Artifact description"
    }
  ],
  "team_execution": {
    "enabled": true,
    "wave_count": 2,
    "teammates_spawned": 4,
    "teammates_completed": 4,
    "teammates_failed": 0,
    "token_usage_multiplier": 5.2,
    "degraded_to_single": false
  },
  "teammate_results": [
    {
      "name": "ResearcherA",
      "angle": "Primary implementation approach",
      "status": "completed",
      "artifact_path": "specs/{N}_{SLUG}/reports/research-{RRR}-teammate-a-findings.md",
      "confidence": "high",
      "conflicts_with": []
    },
    {
      "name": "ResearcherB",
      "angle": "Alternative patterns",
      "status": "completed",
      "artifact_path": "specs/{N}_{SLUG}/reports/research-{RRR}-teammate-b-findings.md",
      "confidence": "medium",
      "conflicts_with": ["ResearcherA finding 2"]
    }
  ],
  "synthesis": {
    "conflicts_found": 1,
    "conflicts_resolved": 1,
    "gaps_identified": 0,
    "wave_2_triggered": false,
    "resolution_notes": "ResearcherA approach preferred due to stronger evidence"
  },
  "metadata": {
    "session_id": "sess_...",
    "duration_seconds": 450,
    "agent_type": "skill-team-research",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "skill-team-research"]
  },
  "completion_data": {
    "completion_summary": "...",
    "roadmap_items": []
  }
}
```

## Field Definitions

### team_execution Object

| Field | Type | Description |
|-------|------|-------------|
| `enabled` | boolean | Whether team mode was used |
| `wave_count` | number | Number of waves executed |
| `teammates_spawned` | number | Total teammates spawned across all waves |
| `teammates_completed` | number | Teammates that completed successfully |
| `teammates_failed` | number | Teammates that failed or timed out |
| `token_usage_multiplier` | number | Estimated token multiplier vs single agent |
| `degraded_to_single` | boolean | True if team mode failed and fell back to single agent |

### teammate_results Array

Each entry represents one teammate's contribution:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Teammate identifier (e.g., "ResearcherA") |
| `angle` | string | What aspect this teammate investigated |
| `status` | string | "completed", "partial", "failed", "timeout" |
| `artifact_path` | string | Path to teammate's output file (if any) |
| `confidence` | string | "high", "medium", "low" - self-assessed |
| `conflicts_with` | array | List of conflicting findings from other teammates |

### synthesis Object

Summary of how results were combined:

| Field | Type | Description |
|-------|------|-------------|
| `conflicts_found` | number | Total conflicts between teammate findings |
| `conflicts_resolved` | number | Conflicts resolved by lead synthesis |
| `gaps_identified` | number | Coverage gaps found during synthesis |
| `wave_2_triggered` | boolean | Whether a second wave was spawned |
| `resolution_notes` | string | How conflicts were resolved |

## Single Agent Comparison

When team mode is disabled or degrades, minimal fields:

```json
{
  "status": "researched",
  "summary": "...",
  "artifacts": [...],
  "team_execution": {
    "enabled": false,
    "degraded_to_single": false
  },
  "metadata": {...}
}
```

## Degraded Mode

When team mode was requested but failed:

```json
{
  "status": "researched",
  "summary": "...",
  "artifacts": [...],
  "team_execution": {
    "enabled": true,
    "degraded_to_single": true,
    "degradation_reason": "Teammate spawning failed: Teams feature unavailable"
  },
  "metadata": {...}
}
```

## Usage in Skills

Skills should check `team_execution.enabled` to determine if team-specific processing is needed:

```bash
enabled=$(jq -r '.team_execution.enabled // false' "$metadata_file")
if [ "$enabled" = "true" ]; then
    # Process teammate results
    teammate_count=$(jq -r '.teammate_results | length' "$metadata_file")
    # ...
fi
```

## Related Files

- `.claude/context/core/formats/return-metadata-file.md` - Base metadata schema
- `.claude/context/core/patterns/team-orchestration.md` - Wave coordination patterns
