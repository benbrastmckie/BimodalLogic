# ARCHIVE_INDEX.md - DEPRECATED

**This file has been replaced by `archive/state.json`**

**New Location**: `.opencode/specs/archive/state.json`

**Deprecation Date**: 2025-12-19  
**Migration**: Phase 3 - Data Migration (Maintenance Artifact Redesign)

---

## Why the change?

The archive tracking system has been migrated to a machine-readable JSON format for improved automation and consistency:

- **Machine-readable state** enables automation and programmatic queries
- **Consistent with project state management** approach (state.json pattern)
- **Eliminates redundancy** with state.json tracking
- **Enables efficient querying** with jq and other JSON tools
- **Structured schema** with comprehensive metadata tracking
- **Better integration** with maintenance workflows

---

## How to query archives

### List all archived projects

```bash
jq -r '.archived_projects[] | "\(.project_number) - \(.project_name)"' \
  .opencode/specs/archive/state.json
```

### Find projects by type

```bash
# Documentation projects
jq '.archived_projects[] | select(.project_type == "documentation")' \
  .opencode/specs/archive/state.json

# Bugfix projects
jq '.archived_projects[] | select(.project_type == "bugfix")' \
  .opencode/specs/archive/state.json
```

### Find projects by date

```bash
# Projects completed on specific date
jq '.archived_projects[] | select(.timeline.completed | startswith("2025-12-18"))' \
  .opencode/specs/archive/state.json

# Projects archived in December 2025
jq '.archived_projects[] | select(.timeline.archived | startswith("2025-12"))' \
  .opencode/specs/archive/state.json
```

### Get statistics

```bash
# Overall statistics
jq '.statistics' .opencode/specs/archive/state.json

# Projects by type
jq '.statistics.by_type' .opencode/specs/archive/state.json

# Projects by priority
jq '.statistics.by_priority' .opencode/specs/archive/state.json
```

### Search by module

```bash
# Find projects affecting specific module
jq '.search_index.by_module."Logos.Core.Automation"' \
  .opencode/specs/archive/state.json
```

### Get project details

```bash
# Get full details for project 062
jq '.archived_projects[] | select(.project_number == 62)' \
  .opencode/specs/archive/state.json

# Get summary for all projects
jq '.archived_projects[] | {number: .project_number, name: .project_name, type: .project_type, completed: .timeline.completed}' \
  .opencode/specs/archive/state.json
```

---

## Documentation

For complete documentation on the new archive state system, see:

- **Schema Guide**: `.opencode/specs/STATE_SCHEMA_GUIDE.md`
- **Migration Guide**: `.opencode/specs/maintenance/MIGRATION.md`
- **Quick Reference**: `.opencode/specs/maintenance/QUICK_REFERENCE.md`

---

## Current Archive Contents

As of 2025-12-19, the archive contains **6 completed projects**:

1. **052_fix_aesop_duplicate** (2025-12-15) - Bugfix
2. **056_bridge_helper_lemmas** (2025-12-16) - Verification
3. **059_implementation_status_update** (2025-12-16) - Documentation
4. **060_remove_backup_artifacts** (2025-12-16) - Maintenance
5. **061_add_missing_directory_readmes** (2025-12-18) - Documentation
6. **062_docstring_coverage** (2025-12-18) - Documentation

All project artifacts are preserved in `.opencode/specs/archive/{project_number}_{project_name}/`

---

## Backward Compatibility

This file is kept in place for backward compatibility and to provide a migration notice. It will not be updated with new archive entries. All future archive tracking will be done through `archive/state.json`.

**For the latest archive information, always consult**: `.opencode/specs/archive/state.json`

---

**Deprecated**: 2025-12-19  
**Replacement**: `.opencode/specs/archive/state.json`  
**Documentation**: `.opencode/specs/STATE_SCHEMA_GUIDE.md`
