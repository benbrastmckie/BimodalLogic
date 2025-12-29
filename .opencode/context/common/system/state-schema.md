# State Schema Reference

## Overview

State tracking system using distributed JSON files for project management, archival, and
maintenance operations.

## File Locations

```
.opencode/specs/
├── state.json                      # Main state (cross-references, health summary)
├── .opencode/specs/TODO.md                         # User-facing task list
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

The fields are organized in logical order:
1. Schema metadata (_schema_version, optional _comment, _last_updated)
2. Project numbering configuration (next_project_number, project_numbering)
3. State references (paths to archive and maintenance state files)
4. Active and completed projects
5. Repository health and summaries

```json
{
  "_schema_version": "1.0.0",
  "_last_updated": "2025-12-22T15:50:00Z",
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
    },
    "review_artifacts": [
      {
        "timestamp": "2025-12-28T20:00:00Z",
        "path": ".opencode/specs/207_codebase_review/summaries/review-summary.md",
        "scope": "full"
      }
    ]
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
    "summaries/project-summary.md",
    "summaries/implementation-summary-20251228.md"
  ],
  "plan_metadata": {
    "phase_count": 4,
    "estimated_hours": 12,
    "complexity": "medium",
    "extracted_from": "plans/implementation-001.md",
    "extracted_at": "2025-12-28T10:00:00Z"
  },
  "plan_versions": [
    {
      "version": 1,
      "path": "plans/implementation-001.md",
      "created": "2025-12-28T10:00:00Z",
      "reason": "Initial implementation plan"
    }
  ],
  "status": "active",
  "created": "2025-01-15T10:00:00Z",
  "last_updated": "2025-01-16T14:30:00Z"
}
```

### Field Descriptions

**plan_metadata** (object, optional):
- Metadata extracted from implementation plan
- Enables querying without parsing plan files
- Fields:
  - `phase_count` (integer): Number of implementation phases
  - `estimated_hours` (number): Total estimated effort in hours
  - `complexity` (string): Complexity level (simple, medium, complex)
  - `extracted_from` (string): Plan file path metadata was extracted from
  - `extracted_at` (string): ISO8601 timestamp of extraction

**plan_versions** (array, optional):
- Version history of implementation plans
- Preserves plan evolution across revisions
- Each entry contains:
  - `version` (integer): Plan version number (1, 2, 3, ...)
  - `path` (string): Relative path to plan file
  - `created` (string): ISO8601 timestamp of plan creation
  - `reason` (string): Reason for plan creation or revision

### Lazy Creation

Project state.json is created lazily on first artifact write:
- Created when first research report, plan, or implementation is added
- Uses template above with initial values
- Populated with project metadata from task description
- Added to status-sync-manager two-phase commit transaction

## Timestamp Format

All timestamps use ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ` for creation timestamps, and `YYYY-MM-DD` for status change timestamps.

Examples:
- `"created": "2025-12-19T00:00:00Z"` - Full ISO8601 with time
- `"started": "2025-12-19"` - Date only for status changes
- `"completed": "2025-12-19"` - Date only for status changes

Always use UTC timezone (Z suffix) for full timestamps.

### Field Naming Convention

**Status change timestamp fields use simple names WITHOUT `_at` suffix:**
- `started` (NOT `started_at`)
- `completed` (NOT `completed_at`)
- `researched` (NOT `researched_at`)
- `planned` (NOT `planned_at`)
- `blocked` (NOT `blocked_at`)
- `abandoned` (NOT `abandoned_at`)

**Creation/update timestamps use full ISO8601:**
- `created` - Full ISO8601 timestamp
- `last_updated` - Date only (YYYY-MM-DD)

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

## Self-Healing Infrastructure

### Auto-Creation of Missing State Files

Commands and agents should implement self-healing logic to auto-create missing infrastructure files:

**Template Location**: `.opencode/context/common/templates/state-template.json`

**Auto-Creation Logic**:
```python
def ensure_state_json_exists():
    state_path = ".opencode/specs/state.json"
    
    if not file_exists(state_path):
        # Load template
        template = read_json(".opencode/context/common/templates/state-template.json")
        
        # Populate from .opencode/specs/TODO.md
        todo_data = parse_todo_md()
        
        # Replace placeholders
        state = {
            "_schema_version": "1.0.0",
            "_comment": "Auto-created from template with self-healing",
            "_last_updated": current_timestamp(),
            "next_project_number": todo_data["highest_task_number"] + 1,
            "project_numbering": template["project_numbering"],
            "state_references": template["state_references"],
            "active_projects": extract_active_projects(todo_data),
            "completed_projects": extract_completed_projects(todo_data),
            "repository_health": calculate_health_metrics(todo_data),
            "recent_activities": [
                {
                    "timestamp": current_timestamp(),
                    "activity": f"Auto-created state.json - initialized from .opencode/specs/TODO.md ({len(todo_data['tasks'])} tasks)"
                }
            ],
            "pending_tasks": extract_pending_tasks(todo_data),
            "maintenance_summary": template["maintenance_summary"],
            "archive_summary": template["archive_summary"],
            "schema_info": template["schema_info"]
        }
        
        # Write atomically
        write_json_atomic(state_path, state)
        log_info(f"Self-healing: Created {state_path} from template")
        
    return state_path
```

**When to Trigger Self-Healing**:
- On first command execution if state.json missing
- Before any state.json read operation
- During .opencode/specs/TODO.md sync operations
- On explicit validation requests

**Graceful Degradation**:
- If template missing: Use minimal hardcoded defaults
- If .opencode/specs/TODO.md unreadable: Create empty state with warnings
- Log all self-healing actions to recent_activities

### Missing File Detection

**Context Loading Semantics**:
- `@.opencode/specs/state.json` - **Auto-create from template if missing**
- `@.opencode/specs/TODO.md` - **Required, fail with clear error if missing**
- `@.opencode/specs/archive/state.json` - **Auto-create from template if missing**
- `@.opencode/specs/maintenance/state.json` - **Auto-create from template if missing**

**Error Messages**:
```
Missing required file: .opencode/specs/TODO.md
This file is required for task tracking.

To fix:
1. Restore from backup if available
2. Create new .opencode/specs/TODO.md with standard format
3. Run task system initialization
```

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

4. **Tasks without plans**
   - `/task` may execute without a linked plan; still sync status/numbering in state/TODO and avoid creating project roots/subdirs unless an artifact is written.
   - When a plan exists, continue to reuse and update it in place.

5. **Document Everything**
   - Use `_comment` fields liberally
   - Include completion_criteria in summaries
   - Add lessons_learned when applicable

6. **Maintain Consistency**
   - Use ISO 8601 timestamps everywhere
   - Follow snake_case naming convention
   - Include both before/after metrics for impact analysis

7. **Enable Self-Healing**
   - Check for missing infrastructure files before operations
   - Auto-create from templates when safe
   - Log all self-healing actions
   - Provide clear recovery instructions for critical failures

---

## Schema Evolution and Versioning

### Version Management

The `_schema_version` field in state.json tracks schema changes:

**Format**: `"MAJOR.MINOR.PATCH"` (Semantic Versioning)
- **MAJOR**: Breaking changes requiring migration
- **MINOR**: New optional fields (backward compatible)
- **PATCH**: Documentation or clarification only

**Current Version**: `"1.0.0"`

### When to Update Schema

**MAJOR version bump** (1.0.0 → 2.0.0):
- Change required field structure
- Remove or rename existing fields
- Change field value formats (e.g., ISO 8601 → Unix timestamp)
- Requires migration script for existing state files

**MINOR version bump** (1.0.0 → 1.1.0):
- Add new optional fields
- Expand enum values
- Add new sections
- Old files still valid, new files have more data

**PATCH version bump** (1.0.0 → 1.0.1):
- Clarify documentation
- Fix typos in comments
- No functional changes

### Schema Update Process

When evolving the schema:

1. **Update Template** (`.opencode/context/common/templates/state-template.json`)
   - Add new fields with default values
   - Update `_schema_version`
   - Add `_comment` explaining changes

2. **Update Schema Documentation** (this file)
   - Document new fields in appropriate sections
   - Update examples
   - Add migration notes if breaking

3. **Update Self-Healing Logic** (`self-healing-implementation-details.md`)
   - Adjust extraction functions for new fields
   - Ensure template population handles new fields
   - Test auto-creation with new schema

4. **Test Backward Compatibility**
   - Verify old state.json files still load
   - Ensure new fields have sensible defaults
   - Test self-healing creates valid new-schema files

5. **Version Bump**
   - Increment `_schema_version` appropriately
   - Document in CHANGELOG or version notes
   - Update this section with version history

### Backward Compatibility Strategy

**Reading Old Files**:
- Commands should tolerate missing optional fields
- Use defaults for missing fields
- Log warnings if unexpected schema version found

**Writing New Files**:
- Always write latest schema version
- Include all new fields with defaults
- Preserve unknown fields from old schema (don't delete)

**Migration Path**:
```python
def migrate_state_schema(old_state):
    """Migrate old schema to current version"""
    
    version = old_state.get("_schema_version", "0.0.0")
    
    # No migration needed
    if version == "1.0.0":
        return old_state
    
    # Migrate from 0.9.x to 1.0.0
    if version.startswith("0.9"):
        new_state = {
            **old_state,
            "_schema_version": "1.0.0",
            "state_references": {
                "archive_state_path": ".opencode/specs/archive/state.json",
                "maintenance_state_path": ".opencode/specs/maintenance/state.json"
            }
        }
        return new_state
    
    # Unknown version
    log_warning(f"Unknown schema version: {version}")
    return old_state  # Best effort
```

### Schema Version History

**1.0.0** (2025-12-27):
- Initial standardized schema
- Includes: project numbering, active/completed projects, health metrics
- Self-healing enabled
- Backward compatible with legacy formats

**1.1.0** (2025-12-28):
- Added `review_artifacts` array to `repository_health` section
- Tracks review summary artifacts created by /review command
- Optional field (backward compatible)
- Schema: Array of objects with `timestamp`, `path`, `scope` fields
- Example:
  ```json
  "review_artifacts": [
    {
      "timestamp": "2025-12-28T20:00:00Z",
      "path": ".opencode/specs/207_codebase_review/summaries/review-summary.md",
      "scope": "full"
    }
  ]
  ```

---

## Related Documentation

- **Self-Healing Guide**: `.opencode/context/common/system/self-healing-guide.md`
- **Implementation Details**: `.opencode/context/project/repo/self-healing-implementation-details.md`
- **State Template**: `.opencode/context/common/templates/state-template.json`
