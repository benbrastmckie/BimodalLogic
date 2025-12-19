# State Schema Guide

**Version**: 1.0.0  
**Last Updated**: 2025-12-19  
**Purpose**: Documentation for state.json schema files used throughout the ProofChecker project

---

## Overview

The ProofChecker project uses a distributed state tracking system with three main state files:

1. **Main State** (`.opencode/specs/state.json`) - Central project state and cross-references
2. **Archive State** (`.opencode/specs/archive/state.json`) - Detailed archived project tracking
3. **Maintenance State** (`.opencode/specs/maintenance/state.json`) - Maintenance operations and health metrics

This distributed approach keeps files focused and manageable while providing comprehensive tracking.

---

## File Locations

```
.opencode/specs/
├── state.json                      # Main state file (lightweight, cross-references)
├── archive/
│   └── state.json                  # Archive state (comprehensive project history)
├── maintenance/
│   └── state.json                  # Maintenance state (operations & health trends)
└── STATE_SCHEMA_GUIDE.md          # This file
```

---

## 1. Main State File

**Location**: `.opencode/specs/state.json`

### Purpose
- Central tracking of active and completed projects
- Quick reference for repository health
- Cross-references to specialized state files
- Maintains backward compatibility with existing tools

### Key Sections

#### State References
```json
"state_references": {
  "archive_state_path": ".opencode/specs/archive/state.json",
  "maintenance_state_path": ".opencode/specs/maintenance/state.json"
}
```
Links to specialized state files for detailed information.

#### Active Projects
```json
"active_projects": []
```
Currently running projects (usually empty - completed projects are archived).

#### Completed Projects
```json
"completed_projects": [
  {
    "project_number": 62,
    "project_name": "docstring_coverage",
    "type": "documentation",
    "completed": "2025-12-18T00:00:00Z",
    "summary": "Verified 100% docstring coverage across all Logos modules",
    "archived": "2025-12-18T00:00:00Z"
  }
]
```
Historical record of all completed projects with timestamps and summaries.

#### Repository Health Summary
```json
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
```
Quick snapshot of current repository health (detailed metrics in maintenance/state.json).

### Schema Version
- **Version**: 1.0.0
- **Backward Compatible**: Yes (new fields are additive and optional)
- **Extensible**: Yes

---

## 2. Archive State File

**Location**: `.opencode/specs/archive/state.json`

### Purpose
- Comprehensive tracking of archived projects
- Detailed metadata, artifacts, and impact analysis
- Search indices for quick lookups
- Statistical summaries by type, priority, complexity

### Key Sections

#### Archive Metadata
```json
"archive_metadata": {
  "total_archived_projects": 6,
  "archive_created": "2025-12-18T00:00:00Z",
  "last_updated": "2025-12-19T00:00:00Z",
  "retention_policy": "indefinite",
  "archive_location": ".opencode/specs/archive/"
}
```

#### Archived Projects (Detailed)
Each archived project includes:

- **Basic Info**: project_number, project_name, project_type, status, priority, complexity
- **Timeline**: created, started, completed, archived, duration_hours
- **Summary**: title, description, motivation, completion_criteria
- **Artifacts**: plans, summaries, reports, state_file (with base_path)
- **Deliverables**: files created/modified/deleted, lines changed, templates used
- **Impact**: metrics before/after, affected modules, breaking changes
- **Verification**: build status, tests, linter, peer review, compliance
- **References**: related_tasks, parent_project, child_tasks, documentation_links
- **Tags**: Searchable keywords
- **Lessons Learned**: Optional insights from project

Example:
```json
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
    "motivation": "Improve repository organization",
    "completion_criteria": "All directories have README.md files"
  },
  "impact": {
    "repository_organization_score": {
      "before": 98,
      "after": 100,
      "improvement": "+2"
    }
  }
}
```

#### Statistics
```json
"statistics": {
  "by_type": {
    "documentation": 3,
    "bugfix": 1,
    "verification": 1,
    "maintenance": 1,
    "total": 6
  },
  "by_priority": { "high": 1, "medium": 5, "low": 0 },
  "by_complexity": { "simple": 6, "moderate": 0, "complex": 0 },
  "average_duration_hours": 2.0
}
```

#### Search Index
```json
"search_index": {
  "by_date": {
    "2025-12-18": [61, 62]
  },
  "by_impact": {
    "critical": [52],
    "high": [61, 62]
  },
  "by_module": {
    "Logos.Core.Automation": [52, 61]
  }
}
```
Quick lookups by date, impact, or affected module.

### Required vs Optional Fields

**Required**:
- project_number
- project_name
- project_type
- status
- timeline.completed
- timeline.archived
- summary.title
- artifacts.base_path

**Optional** (but recommended):
- priority, complexity
- deliverables, impact
- verification, references
- tags, lessons_learned
- technical_details

---

## 3. Maintenance State File

**Location**: `.opencode/specs/maintenance/state.json`

### Purpose
- Track maintenance operations history
- Monitor repository health trends over time
- Schedule recurring maintenance
- Track technical debt (sorry statements, axioms)
- Quality gate verification

### Key Sections

#### Maintenance Metadata
```json
"maintenance_metadata": {
  "system_initialized": "2025-12-18T00:00:00Z",
  "last_maintenance": "2025-12-19T00:00:00Z",
  "next_scheduled": "2026-01-19T00:00:00Z",
  "maintenance_frequency": "monthly",
  "maintenance_coordinator": "repository-reviewer-agent"
}
```

#### Maintenance Operations (Detailed)
Each operation includes:

- **Identification**: operation_id, operation_type, operation_date, coordinator, subagents
- **Scope**: targets, affected_files
- **Execution**: started, completed, duration, status, phases
- **Activities**: tasks removed, projects archived, docs updated, discrepancies found/resolved
- **Metrics**: before/after snapshots with changes
- **Findings**: critical issues, warnings, info notes (with resolutions)
- **Artifacts**: reports, updated_files, backups
- **Health Snapshot**: current state after operation
- **Recommendations**: high/medium/low priority actions

Example:
```json
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
    "discrepancies_found": 4,
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
```

#### Scheduled Maintenance
```json
"scheduled_maintenance": {
  "next_operation": {
    "scheduled_date": "2026-01-19T00:00:00Z",
    "operation_type": "monthly_review",
    "estimated_duration_hours": 3.0
  },
  "recurring_schedule": {
    "frequency": "monthly",
    "day_of_month": 19
  },
  "triggers": {
    "automatic": [
      "Major milestone completion",
      "Monthly schedule",
      "After 10+ task completions"
    ]
  }
}
```

#### Health Trends
```json
"health_trends": {
  "snapshots": [
    {
      "date": "2025-12-19T00:00:00Z",
      "health_score": 94,
      "sorry_count": 5,
      "axiom_count": 24,
      "active_tasks": 30,
      "documentation_coverage": "100%"
    }
  ],
  "trends": {
    "health_direction": "stable_excellent",
    "sorry_trend": "decreasing",
    "documentation_trend": "improving"
  }
}
```

#### Technical Debt Tracking
```json
"technical_debt_tracking": {
  "sorry_statements": {
    "total": 5,
    "production": 5,
    "by_priority": { "critical": 0, "high": 0, "medium": 1, "low": 4 },
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
    },
    "estimated_effort_hours": { "total": 120 }
  }
}
```

#### Quality Gates
```json
"quality_gates": {
  "build_verification": {
    "enabled": true,
    "command": "lake build Logos.Core",
    "last_result": "passing"
  },
  "documentation_coverage": {
    "enabled": true,
    "target": "100%",
    "current": "100%"
  }
}
```

---

## Timestamp Format

All timestamps use **ISO 8601 format**: `YYYY-MM-DDTHH:MM:SSZ`

Examples:
- `"2025-12-19T00:00:00Z"` - Midnight UTC on Dec 19, 2025
- `"2025-12-19T14:30:00Z"` - 2:30 PM UTC on Dec 19, 2025

**Note**: Always use UTC timezone (Z suffix) for consistency.

---

## Schema Versioning

All state files include schema version information:

```json
"_schema_version": "1.0.0"
```

### Version History
- **1.0.0** (2025-12-19): Initial schema release
  - Main state with cross-references
  - Archive state with comprehensive tracking
  - Maintenance state with health trends

### Backward Compatibility
- All new fields are **additive and optional**
- Existing tools continue to work with new schema
- Schema version field allows detection of incompatibilities

### Future Extensions
The schema is designed to be extensible:
- Add new optional fields without breaking changes
- Use `_comment` fields for documentation
- Increment schema version for breaking changes

---

## Usage Guidelines

### For Developers

#### Reading State
```bash
# Quick health check
jq '.repository_health' .opencode/specs/state.json

# List archived projects
jq '.archived_projects[].project_name' .opencode/specs/archive/state.json

# Check last maintenance
jq '.maintenance_metadata.last_maintenance' .opencode/specs/maintenance/state.json
```

#### Updating State
1. **Never manually edit** during active operations
2. Use automation tools or scripts for updates
3. Validate JSON syntax before committing
4. Update `_last_updated` timestamp

#### Adding New Projects to Archive
1. Create project directory in `.opencode/specs/archive/`
2. Add entry to `archive/state.json` archived_projects array
3. Update statistics and search index
4. Update `archive_metadata.last_updated`

### For Automation Tools

#### State File Discovery
```javascript
// Read main state
const mainState = JSON.parse(fs.readFileSync('.opencode/specs/state.json'));

// Follow references to specialized states
const archivePath = mainState.state_references.archive_state_path;
const maintenancePath = mainState.state_references.maintenance_state_path;

const archiveState = JSON.parse(fs.readFileSync(archivePath));
const maintenanceState = JSON.parse(fs.readFileSync(maintenancePath));
```

#### Schema Version Check
```javascript
const expectedVersion = "1.0.0";
if (state._schema_version !== expectedVersion) {
  console.warn(`Schema version mismatch: expected ${expectedVersion}, got ${state._schema_version}`);
}
```

---

## Comment Fields

All state files use `_comment` fields for inline documentation (since JSON doesn't support comments):

- `_comment`: General comment for the field
- `_comment_purpose`: Explains the purpose of a section
- `_comment_usage`: Describes how to use the data
- `_comment_<field>`: Specific comment about a particular field

**Example**:
```json
{
  "_comment_purpose": "Schema for tracking archived completed projects",
  "archive_metadata": {
    "_comment": "High-level metadata about the archive system"
  }
}
```

These fields can be ignored by automated tools but provide valuable documentation for human readers.

---

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

---

## Best Practices

### 1. Keep Files Focused
- Main state: Lightweight, cross-references only
- Archive state: Comprehensive project history
- Maintenance state: Operations and health trends

### 2. Use Search Indices
- Add entries to search indices when archiving projects
- Keep indices sorted by date for efficiency
- Include multiple index types (by_date, by_impact, by_module)

### 3. Track Trends
- Add snapshots to health_trends after each maintenance operation
- Include contextual notes explaining changes
- Monitor trends direction (improving/stable/declining)

### 4. Document Everything
- Use `_comment` fields liberally
- Include completion_criteria in summaries
- Add lessons_learned when applicable
- Link related tasks and documentation

### 5. Maintain Consistency
- Use ISO 8601 timestamps everywhere
- Follow snake_case naming convention
- Include both before/after metrics for impact analysis
- Update statistics and indices when adding data

---

## Examples

### Example 1: Find All Documentation Projects
```bash
jq '.archived_projects[] | select(.project_type == "documentation") | .project_name' \
  .opencode/specs/archive/state.json
```

### Example 2: Get Latest Health Score
```bash
jq '.health_trends.snapshots[-1].health_score' \
  .opencode/specs/maintenance/state.json
```

### Example 3: List High Priority Tasks from Last Maintenance
```bash
jq '.maintenance_operations[-1].recommendations.high_priority' \
  .opencode/specs/maintenance/state.json
```

### Example 4: Count Projects by Type
```bash
jq '.statistics.by_type' .opencode/specs/archive/state.json
```

---

## Migration Guide

### From Legacy State Format

If migrating from an older state.json format:

1. **Backup existing state**:
   ```bash
   cp .opencode/specs/state.json .opencode/specs/state.json.backup
   ```

2. **Add schema version and references**:
   - Add `_schema_version: "1.0.0"`
   - Add `state_references` section
   - Add `repository_health` summary
   - Add `maintenance_summary` summary
   - Add `archive_summary` summary

3. **Create specialized state files**:
   - Extract archived projects to `archive/state.json`
   - Create `maintenance/state.json` with initial snapshot

4. **Validate migration**:
   ```bash
   jq empty .opencode/specs/state.json
   jq empty .opencode/specs/archive/state.json
   jq empty .opencode/specs/maintenance/state.json
   ```

5. **Test backward compatibility**:
   - Verify existing tools still work
   - Check that all data is accessible
   - Ensure no information loss

---

## Support

For questions or issues with state schemas:

1. Check this guide for schema definitions and examples
2. Review example entries in each state file
3. Validate JSON syntax with `jq`
4. Check `.opencode/specs/ARCHIVE_INDEX.md` for archive reference
5. Review maintenance reports in `.opencode/specs/maintenance/reports/`

---

## Changelog

### Version 1.0.0 (2025-12-19)
- Initial schema release
- Created distributed state tracking system
- Added comprehensive archive state schema
- Added maintenance operations tracking schema
- Updated main state with cross-references
- Added backward compatibility support
- Documented all schemas and examples

---

**Last Updated**: 2025-12-19  
**Schema Version**: 1.0.0  
**Maintained By**: OpenCode System
