# State Schema Reference

## Overview

State tracking system using distributed JSON files for project management, archival, and
maintenance operations.

## File Locations

```
.opencode/specs/
├── state.json                      # Main state (cross-references, health summary)
├── TODO.md                         # User-facing task list
├── archive/
│   └── state.json                  # Archived project tracking
├── maintenance/
│   └── state.json                  # Maintenance operations and health trends
└── NNN_project_name/
    ├── reports/                    # Research and analysis reports
    ├── plans/                      # Implementation plans (versioned)
    ├── summaries/                  # Brief summaries
    └── state.json                  # Project-specific state
```

## Main State File

**Location**: `.opencode/specs/state.json`

### Purpose
- Central tracking of active and completed projects
- Repository health summary
- Cross-references to specialized state files

### Key Sections

```json
{
  "_schema_version": "1.0.0",
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
      "completed": "2025-12-18T00:00:00Z",
      "summary": "Verified 100% docstring coverage",
      "archived": "2025-12-18T00:00:00Z"
    }
  ],
  "repository_health": {
    "last_assessed": "2025-12-19T00:00:00Z",
    "overall_score": 94,
    "layer_0_completion": "98%",
    "production_readiness": "excellent",
    "active_tasks": 30,
    "technical_debt": {
      "sorry_count": 5,
      "axiom_count": 24,
      "status": "well-documented"
    }
  }
}
```

## Archive State File

**Location**: `.opencode/specs/archive/state.json`

### Purpose
- Comprehensive tracking of archived projects
- Detailed metadata, artifacts, and impact analysis
- Search indices for quick lookups

### Key Sections

```json
{
  "_schema_version": "1.0.0",
  "archive_metadata": {
    "total_archived_projects": 6,
    "last_updated": "2025-12-19T00:00:00Z",
    "retention_policy": "indefinite"
  },
  "archived_projects": [
    {
      "project_number": 61,
      "project_name": "add_missing_directory_readmes",
      "project_type": "documentation",
      "timeline": {
        "created": "2025-12-18T00:00:00Z",
        "completed": "2025-12-18T10:30:00Z",
        "archived": "2025-12-19T00:00:00Z",
        "duration_hours": 2.5
      },
      "summary": {
        "title": "Add Missing Directory READMEs",
        "description": "Created Perpetuity/README.md and Automation/README.md",
        "completion_criteria": "All directories have README.md files"
      },
      "artifacts": {
        "base_path": ".opencode/specs/archive/061_add_missing_directory_readmes/",
        "plans": ["plans/implementation-001.md"],
        "summaries": ["summaries/completion-summary.md"]
      },
      "impact": {
        "repository_organization_score": {
          "before": 98,
          "after": 100,
          "improvement": "+2"
        }
      }
    }
  ],
  "statistics": {
    "by_type": {
      "documentation": 3,
      "bugfix": 1,
      "verification": 1,
      "maintenance": 1
    },
    "average_duration_hours": 2.0
  },
  "search_index": {
    "by_date": {
      "2025-12-18": [61, 62]
    },
    "by_module": {
      "Logos.Core.Automation": [52, 61]
    }
  }
}
```

### Required vs Optional Fields

**Required**:
- project_number, project_name, project_type, status
- timeline.completed, timeline.archived
- summary.title
- artifacts.base_path

**Optional** (but recommended):
- priority, complexity
- deliverables, impact
- verification, references
- tags, lessons_learned

## Maintenance State File

**Location**: `.opencode/specs/maintenance/state.json`

### Purpose
- Track maintenance operations history
- Monitor repository health trends
- Schedule recurring maintenance
- Track technical debt

### Key Sections

```json
{
  "_schema_version": "1.0.0",
  "maintenance_metadata": {
    "system_initialized": "2025-12-18T00:00:00Z",
    "last_maintenance": "2025-12-19T00:00:00Z",
    "next_scheduled": "2026-01-19T00:00:00Z",
    "maintenance_frequency": "monthly"
  },
  "maintenance_operations": [
    {
      "operation_id": "maint_20251219_001",
      "operation_type": "todo_maintenance",
      "operation_date": "2025-12-19T00:00:00Z",
      "execution": {
        "duration_hours": 3.5,
        "status": "completed"
      },
      "activities": {
        "tasks_removed_from_todo": 12,
        "projects_archived": 6,
        "discrepancies_resolved": 4
      },
      "metrics": {
        "before": {
          "active_tasks": 41,
          "documentation_accuracy": "87%"
        },
        "after": {
          "active_tasks": 30,
          "documentation_accuracy": "90%"
        }
      }
    }
  ],
  "health_trends": {
    "snapshots": [
      {
        "date": "2025-12-19T00:00:00Z",
        "health_score": 94,
        "sorry_count": 5,
        "axiom_count": 24,
        "active_tasks": 30
      }
    ],
    "trends": {
      "health_direction": "stable_excellent",
      "sorry_trend": "decreasing"
    }
  },
  "technical_debt_tracking": {
    "sorry_statements": {
      "total": 5,
      "by_module": {
        "Truth.lean": 3,
        "Completeness.lean": 1,
        "ModalS5.lean": 1
      }
    },
    "axiom_declarations": {
      "total": 24,
      "by_module": {
        "Perpetuity.lean": 5,
        "Completeness.lean": 11,
        "ProofSearch.lean": 8
      }
    }
  }
}
```

## Project State File

**Location**: `.opencode/specs/NNN_project_name/state.json`

### Purpose
- Track individual project progress
- Reference project artifacts
- Maintain project metadata

### Schema

```json
{
  "project_name": "bimodal_proof_system",
  "project_number": 1,
  "type": "implementation",
  "phase": "planning",
  "reports": [
    "reports/research-001.md",
    "reports/research-002.md"
  ],
  "plans": [
    "plans/implementation-001.md",
    "plans/implementation-002.md"
  ],
  "summaries": [
    "summaries/project-summary.md"
  ],
  "status": "active",
  "created": "2025-01-15T10:00:00Z",
  "last_updated": "2025-01-16T14:30:00Z"
}
```

## Timestamp Format

All timestamps use ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`

Examples:
- `"2025-12-19T00:00:00Z"` - Midnight UTC
- `"2025-12-19T14:30:00Z"` - 2:30 PM UTC

Always use UTC timezone (Z suffix) for consistency.

## Schema Versioning

All state files include:
```json
"_schema_version": "1.0.0"
```

### Version History
- **1.0.0** (2025-12-19): Initial schema release with distributed state tracking

### Backward Compatibility
- All new fields are additive and optional
- Existing tools continue to work with new schema
- Schema version field allows detection of incompatibilities

## Comment Fields

JSON doesn't support comments, so use `_comment` fields for inline documentation:

```json
{
  "_comment_purpose": "Schema for tracking archived completed projects",
  "archive_metadata": {
    "_comment": "High-level metadata about the archive system"
  }
}
```

These fields can be ignored by automated tools but provide documentation for humans.

## Usage Examples

### Reading State

```bash
# Quick health check
jq '.repository_health' .opencode/specs/state.json

# List archived projects
jq '.archived_projects[].project_name' .opencode/specs/archive/state.json

# Check last maintenance
jq '.maintenance_metadata.last_maintenance' .opencode/specs/maintenance/state.json
```

### Updating State

1. Never manually edit during active operations
2. Use automation tools or scripts for updates
3. Validate JSON syntax before committing
4. Update `_last_updated` timestamp

### Adding New Projects to Archive

1. Create project directory in `.opencode/specs/archive/`
2. Add entry to `archive/state.json` archived_projects array
3. Update statistics and search index
4. Update `archive_metadata.last_updated`

## Validation

### JSON Syntax Validation

```bash
# Validate JSON syntax
jq empty .opencode/specs/state.json
jq empty .opencode/specs/archive/state.json
jq empty .opencode/specs/maintenance/state.json
```

### Schema Compliance

All state files should include:
- `_schema_version` field
- Required fields per schema definition
- Valid ISO 8601 timestamps
- Consistent field naming (snake_case)

## Best Practices

1. **Keep Files Focused**
   - Main state: Lightweight, cross-references only
   - Archive state: Comprehensive project history
   - Maintenance state: Operations and health trends

2. **Use Search Indices**
   - Add entries to search indices when archiving projects
   - Keep indices sorted by date for efficiency

3. **Track Trends**
   - Add snapshots to health_trends after each maintenance operation
   - Include contextual notes explaining changes

4. **Document Everything**
   - Use `_comment` fields liberally
   - Include completion_criteria in summaries
   - Add lessons_learned when applicable

5. **Maintain Consistency**
   - Use ISO 8601 timestamps everywhere
   - Follow snake_case naming convention
   - Include both before/after metrics for impact analysis
