# State Management Standard

**Version**: 2.0  
**Status**: Active  
**Created**: 2025-12-29  
**Purpose**: Unified state management standard defining status markers, state schemas, and synchronization

---

## Overview

This standard defines the complete state management system for ProofChecker, including:

- **Status Markers**: Standardized markers for tracking task and phase progress
- **State Schemas**: JSON schemas for distributed state tracking
- **Status Synchronization**: Atomic multi-file update mechanisms
- **Timestamp Formats**: Consistent timestamp formatting across all files

---

## Status Markers

### Standard Status Markers

#### `[NOT STARTED]`
**Meaning**: Task or phase has not yet begun.

**Valid Transitions**:
- `[NOT STARTED]` → `[IN PROGRESS]` (work begins)
- `[NOT STARTED]` → `[BLOCKED]` (blocked before starting)

#### `[IN PROGRESS]`
**Meaning**: Task or phase is currently being worked on.

**Valid Transitions**:
- `[IN PROGRESS]` → `[COMPLETED]` (work finishes successfully)
- `[IN PROGRESS]` → `[BLOCKED]` (work encounters blocker)
- `[IN PROGRESS]` → `[ABANDONED]` (work is abandoned)

**Timestamps**: Always include `**Started**: YYYY-MM-DD`

#### `[BLOCKED]`
**Meaning**: Task or phase is blocked by dependencies or issues.

**Valid Transitions**:
- `[BLOCKED]` → `[IN PROGRESS]` (blocker resolved, work resumes)
- `[BLOCKED]` → `[ABANDONED]` (blocker cannot be resolved)

**Required Information**:
- `**Blocked**: YYYY-MM-DD` timestamp
- `**Blocking Reason**: {reason}` or `**Blocked by**: {dependency}`

#### `[ABANDONED]`
**Meaning**: Task or phase was started but abandoned without completion.

**Valid Transitions**:
- `[ABANDONED]` → `[NOT STARTED]` (restart from scratch, rare)
- `[ABANDONED]` is typically terminal

**Required Information**:
- `**Abandoned**: YYYY-MM-DD` timestamp
- `**Abandonment Reason**: {reason}`

#### `[COMPLETED]`
**Meaning**: Task or phase is finished successfully.

**Valid Transitions**: Terminal state (no further transitions)

**Required Information**:
- `**Completed**: YYYY-MM-DD` timestamp
- Do not add emojis; rely on status marker and text alone

### Command-Specific Status Markers

**In-Progress Markers**:
- `[RESEARCHING]`: Task research actively underway (used by `/research`)
- `[PLANNING]`: Implementation plan being created (used by `/plan`)
- `[REVISING]`: Plan revision in progress (used by `/revise`)
- `[IMPLEMENTING]`: Implementation work actively underway (used by `/implement`)

**Completion Markers**:
- `[RESEARCHED]`: Research completed, deliverables created
- `[PLANNED]`: Implementation plan completed, ready for implementation
- `[REVISED]`: Plan revision completed, new plan version created
- `[COMPLETED]`: Implementation finished successfully (terminal state)
- `[PARTIAL]`: Implementation partially completed (can resume)
- `[BLOCKED]`: Work blocked by dependencies or issues

### Status Transition Diagram

```
[NOT STARTED] ─────────────────────────────────────────────────┐
    │                                                           │
    │ (/research)         (/plan)          (/implement)        │
    ▼                     ▼                 ▼                  ▼
[RESEARCHING]    [PLANNING]        [IMPLEMENTING]         [BLOCKED]
    │                │                     │                   │
    ▼                ▼                     ▼                   │
[RESEARCHED] ──→ [PLANNED] ──(/revise)──→ [REVISING]          │
                    │            │             │               │
                    │            │             ▼               │
                    │            │        [REVISED]            │
                    │            └─────────────┘               │
                    │ (/implement)                             │
                    ▼                                          │
             [IMPLEMENTING] ─────────────────────────────────> │
                    │                                          │
                    ├────> [COMPLETED] (all phases done)       │
                    ├────> [PARTIAL] (some phases done)        │
                    └────> [BLOCKED] (cannot proceed) ─────────┘
                                     
    ┌──────────────────────────────────────────────────────────┘
    │ (work abandoned)
    ▼
[ABANDONED]
```

### Valid Transitions Table

| From | To | Condition |
|------|-----|-----------|
| `[NOT STARTED]` | `[RESEARCHING]` | `/research` command starts |
| `[NOT STARTED]` | `[PLANNING]` | `/plan` command starts |
| `[NOT STARTED]` | `[IMPLEMENTING]` | `/implement` command starts (no plan) |
| `[RESEARCHING]` | `[RESEARCHED]` | Research completes successfully |
| `[RESEARCHED]` | `[PLANNING]` | `/plan` command starts |
| `[PLANNING]` | `[PLANNED]` | Planning completes successfully |
| `[PLANNED]` | `[REVISING]` | `/revise` command starts |
| `[PLANNED]` | `[IMPLEMENTING]` | `/implement` command starts |
| `[IMPLEMENTING]` | `[COMPLETED]` | Implementation finishes successfully |
| `[IMPLEMENTING]` | `[PARTIAL]` | Implementation partially complete (timeout) |
| `[BLOCKED]` | `[IN PROGRESS]` | Blocker resolved, work resumes |

---

## State Schemas

### File Locations

```
.opencode/specs/
├── state.json                      # Main state (cross-references, health)
├── TODO.md                         # User-facing task list
├── archive/
│   └── state.json                  # Archived project tracking
├── maintenance/
│   └── state.json                  # Maintenance operations and health
└── NNN_project_name/
    ├── reports/                    # Research and analysis reports
    ├── plans/                      # Implementation plans (versioned)
    ├── summaries/                  # Brief summaries
    └── state.json                  # Project-specific state
```

### Main State File

**Location**: `.opencode/specs/state.json`

**Purpose**: Central tracking of active/completed projects, repository health, cross-references

**Schema**:
```json
{
  "_schema_version": "1.1.0",
  "_last_updated": "2025-12-29T09:00:00Z",
  "next_project_number": 90,
  "project_numbering": {
    "min": 0,
    "max": 999,
    "policy": "increment_modulo_1000"
  },
  "state_references": {
    "archive_state_path": ".opencode/specs/archive/state.json",
    "maintenance_state_path": ".opencode/specs/maintenance/state.json"
  },
  "active_projects": [],
  "completed_projects": [
    {
      "project_number": 62,
      "project_name": "docstring_coverage",
      "type": "documentation",
      "completed": "2025-12-18",
      "summary": "Verified 100% docstring coverage"
    }
  ],
  "repository_health": {
    "last_assessed": "2025-12-19",
    "overall_score": 94,
    "layer_0_completion": "98%",
    "active_tasks": 30,
    "technical_debt": {
      "sorry_count": 5,
      "axiom_count": 24
    }
  }
}
```

### Archive State File

**Location**: `.opencode/specs/archive/state.json`

**Purpose**: Comprehensive tracking of archived projects with metadata, artifacts, impact

**Key Sections**:
```json
{
  "_schema_version": "1.0.0",
  "archive_metadata": {
    "total_archived_projects": 6,
    "last_updated": "2025-12-19",
    "retention_policy": "indefinite"
  },
  "archived_projects": [
    {
      "project_number": 61,
      "project_name": "add_missing_directory_readmes",
      "project_type": "documentation",
      "timeline": {
        "created": "2025-12-18",
        "completed": "2025-12-18",
        "archived": "2025-12-19",
        "duration_hours": 2.5
      },
      "artifacts": {
        "base_path": ".opencode/specs/archive/061_add_missing_directory_readmes/",
        "plans": ["plans/implementation-001.md"]
      }
    }
  ]
}
```

### Maintenance State File

**Location**: `.opencode/specs/maintenance/state.json`

**Purpose**: Track maintenance operations, health trends, technical debt

**Key Sections**:
```json
{
  "_schema_version": "1.0.0",
  "maintenance_metadata": {
    "last_maintenance": "2025-12-19",
    "next_scheduled": "2026-01-19",
    "maintenance_frequency": "monthly"
  },
  "maintenance_operations": [
    {
      "operation_id": "maint_20251219_001",
      "operation_type": "todo_maintenance",
      "operation_date": "2025-12-19",
      "activities": {
        "tasks_removed_from_todo": 12,
        "projects_archived": 6
      }
    }
  ],
  "health_trends": {
    "snapshots": [
      {
        "date": "2025-12-19",
        "health_score": 94,
        "sorry_count": 5,
        "active_tasks": 30
      }
    ]
  }
}
```

---

## Timestamp Formats

### TODO.md Structure

TODO.md follows standard YAML frontmatter format with metadata header at the beginning:

```markdown
---
last_updated: 2026-01-04T04:45:44Z
next_project_number: 280
repository_health:
  overall_score: 92
  production_readiness: excellent
task_counts:
  active: 4
  completed: 50
  total: 81
priority_distribution:
  high: 15
  medium: 12
  low: 11
technical_debt:
  sorry_count: 6
  axiom_count: 11
  build_errors: 11
---

# TODO

## High Priority

### 272. Task Title
- **Effort**: 14 hours
- **Status**: [PLANNED]
- **Priority**: Medium
- **Language**: markdown
- **Started**: 2025-12-20
- **Completed**: 2025-12-20
- **Blocked**: 2025-12-20
```

**YAML Header**: Auto-generated from state.json, surfaces repository health and task metrics  
**Task Timestamps**: Date only format (YYYY-MM-DD)

### Implementation Plan Format
**ISO 8601 with Timezone** (YYYY-MM-DDTHH:MM:SSZ):
```markdown
(Started: 2025-12-20T10:15:30Z)
(Completed: 2025-12-20T11:45:15Z)
```

### State File Format
**ISO 8601 Date** (YYYY-MM-DD) for status changes:
```json
{
  "started": "2025-12-20",
  "completed": "2025-12-20"
}
```

**Full ISO 8601** (YYYY-MM-DDTHH:MM:SSZ) for creation timestamps:
```json
{
  "created": "2025-12-20T10:00:00Z",
  "last_updated": "2025-12-20"
}
```

### Field Naming Convention

**Status change timestamps use simple names WITHOUT `_at` suffix**:
- `started` (NOT `started_at`)
- `completed` (NOT `completed_at`)
- `researched` (NOT `researched_at`)
- `planned` (NOT `planned_at`)
- `blocked` (NOT `blocked_at`)
- `abandoned` (NOT `abandoned_at`)

**Creation/update timestamps**:
- `created` - Full ISO8601 timestamp
- `last_updated` - Date only (YYYY-MM-DD)

---

## Status Synchronization

### Multi-File Synchronization

Commands that create or update plans must keep status synchronized across:
- `.opencode/specs/TODO.md` (user-facing task list)
- `state.json` (global project state)
- Plan files (implementation plans)

### Atomic Update Requirement

All status updates must be **atomic** - either all files updated successfully, or none updated.

### status-sync-manager

The `status-sync-manager` specialist provides atomic multi-file updates using two-phase commit:

**Phase 1 (Prepare)**:
1. Read all target files into memory
2. Validate current status allows requested transition
3. Prepare all updates in memory
4. Validate all updates are well-formed
5. If any validation fails, abort (no files written)

**Phase 2 (Commit)**:
1. Write files in dependency order: TODO.md → state.json → plan
2. Verify each write before proceeding
3. On any write failure, rollback all previous writes
4. All files updated or none updated (atomic guarantee)

### Usage in Commands

**`/research` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp)`
- Postflight: `status-sync-manager.mark_researched(task_number, timestamp)`

**`/plan` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp)`
- Postflight: `status-sync-manager.mark_planned(task_number, timestamp, plan_path)`

**`/implement` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp, plan_path)`
- Postflight: `status-sync-manager.mark_completed(task_number, timestamp, plan_path)`

### Rollback Mechanism

If any file write fails during commit:
1. Immediately stop further writes
2. Restore all previously written files from backup
3. Return error with details of which file failed
4. System remains in consistent state

---

## Validation

### Status Marker Validation

1. **Format**: Status markers must be in brackets: `[STATUS]`
2. **Case**: Status markers must be uppercase: `[COMPLETED]` not `[completed]`
3. **Spelling**: Must match exactly: `[COMPLETED]` not `[COMPLETE]`
4. **Whitespace**: No extra whitespace: `[IN PROGRESS]` not `[ IN PROGRESS ]`

### Timestamp Validation

1. **TODO.md**: Must be YYYY-MM-DD format
2. **Plans**: Must be ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ)
3. **State files**: Must be YYYY-MM-DD for status changes, full ISO8601 for creation
4. **Required**: Timestamps required for all status transitions

### Transition Validation

1. **Valid transitions**: Must follow transition diagram
2. **Required fields**: Blocking/abandonment reasons required
3. **Timestamp order**: Started < Completed/Blocked/Abandoned
4. **Immutability**: `[COMPLETED]` tasks should not change

### JSON Syntax Validation

```bash
# Validate JSON syntax
jq empty .opencode/specs/state.json
jq empty .opencode/specs/archive/state.json
jq empty .opencode/specs/maintenance/state.json
```

---

## Schema Versioning

All state files include:
```json
"_schema_version": "1.1.0"
```

### Version Format
**Format**: `"MAJOR.MINOR.PATCH"` (Semantic Versioning)
- **MAJOR**: Breaking changes requiring migration
- **MINOR**: New optional fields (backward compatible)
- **PATCH**: Documentation or clarification only

### Version History

**1.0.0** (2025-12-27):
- Initial standardized schema
- Includes: project numbering, active/completed projects, health metrics

**1.1.0** (2025-12-28):
- Added `review_artifacts` array to `repository_health`
- Tracks review summary artifacts created by /review command
- Optional field (backward compatible)

---

## Best Practices

### 1. Always Include Timestamps

**Good**:
```markdown
**Status**: [IN PROGRESS]
**Started**: 2025-12-20
```

**Bad**:
```markdown
**Status**: [IN PROGRESS]
```

### 2. Always Include Blocking/Abandonment Reasons

**Good**:
```markdown
**Status**: [BLOCKED]
**Blocked**: 2025-12-20
**Blocking Reason**: Blocked by failed task 64
```

**Bad**:
```markdown
**Status**: [BLOCKED]
```

### 3. Use Atomic Updates

**Good**:
```python
status_sync_manager.mark_complete(
    task_number=63,
    timestamp="2025-12-20"
)
```

**Bad** (non-atomic):
```python
update_todo(63, "COMPLETED")
update_state(63, "completed")  # May fail, leaving inconsistent state
```

### 4. Preserve Status History

When updating status, preserve previous timestamps:

**Good**:
```markdown
**Status**: [COMPLETED]
**Started**: 2025-12-19
**Completed**: 2025-12-20
```

**Bad** (overwrites history):
```markdown
**Status**: [COMPLETED]
**Completed**: 2025-12-20
```

---

## Related Documentation

- Delegation Standard: `.opencode/context/core/standards/delegation.md`
- Artifact Management: `.opencode/context/core/system/artifact-management.md`
- Git Commits: `.opencode/context/core/system/git-commits.md`
