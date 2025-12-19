# Migration Guide: ARCHIVE_INDEX.md to state.json

**Version**: 1.0.0  
**Date**: 2025-12-19  
**Purpose**: Guide for migrating from ARCHIVE_INDEX.md to archive/state.json

---

## Overview

This guide documents the migration from the legacy `ARCHIVE_INDEX.md` markdown-based archive tracking to the new `archive/state.json` machine-readable state management system.

### Migration Goals

1. **Eliminate Redundancy**: Replace duplicate tracking in ARCHIVE_INDEX.md and state.json
2. **Standardize State**: Use JSON for machine-readable state, markdown for human-readable reports
3. **Improve Traceability**: Track all project metadata in structured format
4. **Enable Automation**: Allow automated queries and updates of archive state
5. **Maintain History**: Preserve all historical information during migration

---

## Current State Analysis

### ARCHIVE_INDEX.md (Legacy)

**Location**: `.opencode/specs/ARCHIVE_INDEX.md`  
**Format**: Markdown  
**Purpose**: Track archived completed projects  
**Strengths**:
- Human-readable
- Easy to edit manually
- Good documentation of archive structure

**Weaknesses**:
- Not machine-readable
- Duplicate information with state.json
- Difficult to query programmatically
- Manual updates required
- No schema validation

**Content**:
- Archive structure documentation
- List of archived projects with metadata
- Manual archiving instructions
- Archive access documentation
- Statistics

### archive/state.json (New)

**Location**: `.opencode/specs/archive/state.json`  
**Format**: JSON  
**Purpose**: Machine-readable archive state tracking  
**Strengths**:
- Machine-readable and queryable
- Schema-validated structure
- Atomic updates possible
- Automated processing
- Extensible design

**Weaknesses**:
- Less human-readable
- Requires tools for editing
- More verbose than markdown

**Content**:
- Archive metadata
- Detailed project entries
- Statistics by type/priority/complexity
- Search indices
- Schema definition

---

## Migration Strategy

### Phase 1: Data Extraction (Completed)

**Status**: ✅ Complete

**Actions**:
1. ✅ Created archive/state.json with schema
2. ✅ Populated with 3 example projects (052, 056, 061)
3. ✅ Documented schema in STATE_SCHEMA_GUIDE.md

**Remaining Projects to Migrate**:
- 059_implementation_status_update
- 060_remove_backup_artifacts
- 062_docstring_coverage

### Phase 2: Complete Migration (Next)

**Status**: ⏳ Pending

**Actions**:
1. Extract remaining project data from ARCHIVE_INDEX.md
2. Add to archive/state.json following schema
3. Verify all projects migrated
4. Update statistics in archive/state.json

**Script** (manual execution):
```bash
# Verify all archived projects are in state.json
cd .opencode/specs/archive
for dir in */; do
  project_num=$(basename "$dir" | cut -d'_' -f1)
  if ! grep -q "\"project_number\": \"$project_num\"" state.json; then
    echo "Missing: $dir"
  fi
done
```

### Phase 3: Deprecate ARCHIVE_INDEX.md (Next)

**Status**: ⏳ Pending

**Actions**:
1. Add deprecation notice to ARCHIVE_INDEX.md
2. Point to archive/state.json as authoritative source
3. Keep ARCHIVE_INDEX.md for reference (read-only)
4. Update all documentation references

**Deprecation Notice** (to add to ARCHIVE_INDEX.md):
```markdown
# Archive Index - DEPRECATED

**⚠️ DEPRECATION NOTICE**: This file is deprecated as of 2025-12-19.

**New Location**: `.opencode/specs/archive/state.json`

This file is kept for historical reference only. All new archive tracking is done in `archive/state.json`. See `STATE_SCHEMA_GUIDE.md` for schema documentation.

For querying archived projects, use:
```bash
# List all archived projects
jq '.archived_projects[] | {number: .project_number, name: .project_name, date: .archived_date}' .opencode/specs/archive/state.json

# Search by type
jq '.archived_projects[] | select(.type == "documentation")' .opencode/specs/archive/state.json
```

---

[Original content preserved below for reference]
```

### Phase 4: Update Agents (Next)

**Status**: ⏳ Pending

**Agents to Update**:
1. `reviewer.md` - Update archiving workflow
2. `todo.md` command - Update archive references
3. `todo-manager.md` - Update archive state management

**Changes Required**:
- Read from archive/state.json instead of ARCHIVE_INDEX.md
- Write to archive/state.json when archiving
- Update documentation references
- Use jq or similar for JSON queries

### Phase 5: Update Commands (Next)

**Status**: ⏳ Pending

**Commands to Update**:
1. `/todo` - Update to use archive/state.json
2. `/review` - Update to use archive/state.json

**Changes Required**:
- Update context loading to include archive/state.json
- Update archiving instructions
- Update verification commands

---

## Migration Procedure

### Step 1: Extract Project Data

For each project in ARCHIVE_INDEX.md, extract:

**From ARCHIVE_INDEX.md**:
```markdown
### 061_add_missing_directory_readmes (Archived: 2025-12-19)
- **Completed**: 2025-12-18
- **Type**: Documentation
- **Summary**: Created Perpetuity/README.md and Automation/README.md
- **Impact**: Repository organization score 100/100
- **Artifacts**:
  - Implementation plan: `plans/implementation-001.md`
  - Task summary: `summaries/task-summary.md`
  - State: `state.json`
```

**To archive/state.json**:
```json
{
  "project_number": "061",
  "project_name": "add_missing_directory_readmes",
  "type": "documentation",
  "archived_date": "2025-12-19T00:00:00Z",
  "timeline": {
    "created": "2025-12-18T00:00:00Z",
    "started": "2025-12-18T00:00:00Z",
    "completed": "2025-12-18T00:00:00Z",
    "archived": "2025-12-19T00:00:00Z",
    "duration_hours": 1.0
  },
  "summary": {
    "title": "Add Missing Directory READMEs",
    "description": "Created Perpetuity/README.md and Automation/README.md",
    "motivation": "Improve repository organization and documentation",
    "completion_criteria": "All major directories have README files"
  },
  "artifacts": {
    "base_path": ".opencode/specs/archive/061_add_missing_directory_readmes",
    "plans": ["plans/implementation-001.md"],
    "summaries": ["summaries/task-summary.md"],
    "reports": [],
    "state_file": "state.json"
  },
  "deliverables": {
    "files_created": [
      "Logos/Core/Theorems/Perpetuity/README.md",
      "Logos/Core/Automation/README.md"
    ],
    "files_modified": [],
    "files_deleted": [],
    "lines_added": 150,
    "lines_removed": 0
  },
  "impact": {
    "before": {
      "repository_organization_score": 95
    },
    "after": {
      "repository_organization_score": 100
    },
    "affected_modules": ["Theorems/Perpetuity", "Automation"],
    "breaking_changes": false
  },
  "verification": {
    "build_status": "passed",
    "tests_passed": true,
    "linter_passed": true,
    "peer_reviewed": false
  },
  "references": {
    "related_tasks": [61],
    "parent_project": null,
    "documentation_links": []
  },
  "tags": ["documentation", "repository-organization", "readme"],
  "lessons_learned": []
}
```

### Step 2: Verify Migration

**Verification Checklist**:
- [ ] All projects from ARCHIVE_INDEX.md are in archive/state.json
- [ ] All metadata is preserved
- [ ] All timestamps are in ISO 8601 format
- [ ] All file paths are correct
- [ ] Statistics are updated
- [ ] Search indices are populated

**Verification Commands**:
```bash
# Count projects in ARCHIVE_INDEX.md
grep -c "^### [0-9]" .opencode/specs/ARCHIVE_INDEX.md

# Count projects in archive/state.json
jq '.archived_projects | length' .opencode/specs/archive/state.json

# Should match!

# List all project numbers in archive/state.json
jq -r '.archived_projects[].project_number' .opencode/specs/archive/state.json | sort -n

# Compare with ARCHIVE_INDEX.md project numbers
grep "^### [0-9]" .opencode/specs/ARCHIVE_INDEX.md | sed 's/### \([0-9]*\).*/\1/' | sort -n

# Should match!
```

### Step 3: Update Statistics

After migrating all projects, update statistics in archive/state.json:

```json
{
  "statistics": {
    "by_type": {
      "documentation": 3,
      "bugfix": 1,
      "verification": 1,
      "maintenance": 1
    },
    "by_priority": {
      "high": 1,
      "medium": 4,
      "low": 1
    },
    "by_complexity": {
      "simple": 4,
      "moderate": 2,
      "complex": 0
    },
    "total_duration_hours": 15.5,
    "average_duration_hours": 2.58
  }
}
```

### Step 4: Update Search Indices

Populate search indices for efficient querying:

```json
{
  "search_indices": {
    "by_date": {
      "2025-12-19": ["061"],
      "2025-12-18": ["060", "062"],
      "2025-12-16": ["056", "059"],
      "2025-12-15": ["052"]
    },
    "by_impact": {
      "high": ["052", "061"],
      "medium": ["056", "059", "060", "062"],
      "low": []
    },
    "by_module": {
      "Core/Automation": ["052", "061"],
      "Core/Theorems": ["056", "061"],
      "Documentation": ["059", "060", "062"]
    }
  }
}
```

---

## Data Mapping

### Project Metadata Mapping

| ARCHIVE_INDEX.md Field | archive/state.json Field | Notes |
|------------------------|--------------------------|-------|
| Project number (### NNN_...) | `project_number` | Extract from heading |
| Project name (### ..._name) | `project_name` | Extract from heading |
| Archived date | `archived_date` | Convert to ISO 8601 |
| Completed date | `timeline.completed` | Convert to ISO 8601 |
| Type | `type` | Lowercase, standardize |
| Summary | `summary.description` | Direct copy |
| Impact | `impact.after` | Parse metrics |
| Artifacts | `artifacts.*` | Parse list |

### Type Standardization

| ARCHIVE_INDEX.md | archive/state.json |
|------------------|-------------------|
| Documentation | documentation |
| Bugfix | bugfix |
| Verification | verification |
| Maintenance | maintenance |
| Feature | feature |
| Research | research |

### Date Format Conversion

**From**: `2025-12-19`  
**To**: `2025-12-19T00:00:00Z`

**Script**:
```bash
# Convert date to ISO 8601
date -d "2025-12-19" -Iseconds -u
# Output: 2025-12-19T00:00:00+00:00

# For JSON (use Z suffix)
echo "2025-12-19T00:00:00Z"
```

---

## Backward Compatibility

### During Migration

**Keep Both Files**:
- ARCHIVE_INDEX.md (read-only, deprecated)
- archive/state.json (read-write, authoritative)

**Update Strategy**:
- New archives: Add to archive/state.json only
- Queries: Use archive/state.json
- Human reference: ARCHIVE_INDEX.md still available

### After Migration

**ARCHIVE_INDEX.md**:
- Mark as deprecated
- Add pointer to archive/state.json
- Keep for historical reference
- No longer updated

**archive/state.json**:
- Authoritative source
- All queries use this file
- All updates go here
- Maintained by agents

---

## Agent Updates

### reviewer.md Changes

**Before**:
```markdown
3. **Archive Project Directories**
   - Update ARCHIVE_INDEX.md with project metadata
   - Optionally move directories to archive/
```

**After**:
```markdown
3. **Archive Project Directories**
   - Update archive/state.json with project metadata
   - Optionally move directories to archive/
   - ARCHIVE_INDEX.md is deprecated (read-only reference)
```

### todo.md Command Changes

**Before**:
```markdown
**File Structure:**
- Archive: .opencode/specs/archive/{project-name}/
- Archive Index: .opencode/specs/ARCHIVE_INDEX.md
```

**After**:
```markdown
**File Structure:**
- Archive: .opencode/specs/archive/{project-name}/
- Archive State: .opencode/specs/archive/state.json
- Archive Index (deprecated): .opencode/specs/ARCHIVE_INDEX.md
```

### todo-manager.md Changes

**Before**:
```markdown
4. **Synchronize State**
   - Update ARCHIVE_INDEX.md with archived projects
   - Update state.json with archived project references
```

**After**:
```markdown
4. **Synchronize State**
   - Update archive/state.json with archived projects
   - Update state.json with maintenance summary
   - ARCHIVE_INDEX.md is deprecated (no updates)
```

---

## Query Examples

### Using jq with archive/state.json

**List all archived projects**:
```bash
jq -r '.archived_projects[] | "\(.project_number) - \(.project_name) (\(.archived_date))"' \
  .opencode/specs/archive/state.json
```

**Find projects by type**:
```bash
jq '.archived_projects[] | select(.type == "documentation")' \
  .opencode/specs/archive/state.json
```

**Get project statistics**:
```bash
jq '.statistics' .opencode/specs/archive/state.json
```

**Find projects archived in December 2025**:
```bash
jq '.archived_projects[] | select(.archived_date | startswith("2025-12"))' \
  .opencode/specs/archive/state.json
```

**Get total archived projects**:
```bash
jq '.archive_metadata.total_projects' .opencode/specs/archive/state.json
```

**Find high-impact projects**:
```bash
jq '.search_indices.by_impact.high[]' .opencode/specs/archive/state.json
```

---

## Rollback Plan

If migration fails or issues arise:

### Step 1: Verify ARCHIVE_INDEX.md Intact
```bash
# Check ARCHIVE_INDEX.md is unchanged
git diff .opencode/specs/ARCHIVE_INDEX.md
```

### Step 2: Restore Previous State
```bash
# If archive/state.json is corrupted
git checkout HEAD -- .opencode/specs/archive/state.json

# Or restore from backup
cp .opencode/specs/archive/state.json.backup .opencode/specs/archive/state.json
```

### Step 3: Continue Using ARCHIVE_INDEX.md
- Revert agent changes
- Continue using ARCHIVE_INDEX.md
- Investigate migration issues
- Retry migration when ready

---

## Testing Plan

### Test 1: Data Integrity
**Objective**: Verify all data migrated correctly

**Steps**:
1. Count projects in both files
2. Compare project numbers
3. Verify all metadata present
4. Check timestamps are valid ISO 8601

**Expected**: All projects migrated, no data loss

### Test 2: Query Performance
**Objective**: Verify JSON queries work correctly

**Steps**:
1. Run all query examples
2. Verify results match expectations
3. Test search indices
4. Test statistics calculations

**Expected**: All queries return correct results

### Test 3: Agent Integration
**Objective**: Verify agents can read/write archive/state.json

**Steps**:
1. Run /todo command
2. Archive a test project
3. Verify archive/state.json updated
4. Verify ARCHIVE_INDEX.md not updated

**Expected**: Agents use archive/state.json correctly

### Test 4: Backward Compatibility
**Objective**: Verify ARCHIVE_INDEX.md still readable

**Steps**:
1. Read ARCHIVE_INDEX.md manually
2. Verify deprecation notice present
3. Verify historical data intact
4. Verify links to archive/state.json work

**Expected**: ARCHIVE_INDEX.md usable as reference

---

## Timeline

### Week 1 (Current)
- [x] Create archive/state.json schema
- [x] Populate with 3 example projects
- [x] Document schema in STATE_SCHEMA_GUIDE.md
- [x] Create migration guide (this document)

### Week 2 (Next)
- [ ] Migrate remaining 3 projects to archive/state.json
- [ ] Update statistics and search indices
- [ ] Add deprecation notice to ARCHIVE_INDEX.md
- [ ] Verify all data migrated correctly

### Week 3
- [ ] Update reviewer.md agent
- [ ] Update todo.md command
- [ ] Update todo-manager.md agent
- [ ] Test agent integration

### Week 4
- [ ] Run full test suite
- [ ] Verify backward compatibility
- [ ] Update all documentation
- [ ] Mark migration complete

---

## Success Criteria

- ✅ All projects from ARCHIVE_INDEX.md migrated to archive/state.json
- ✅ All metadata preserved and validated
- ✅ Statistics and search indices populated
- ✅ ARCHIVE_INDEX.md marked as deprecated
- ✅ All agents updated to use archive/state.json
- ✅ All queries work correctly
- ✅ Backward compatibility maintained
- ✅ Documentation updated
- ✅ Tests passing

---

## Support

### Questions?
- See `STATE_SCHEMA_GUIDE.md` for schema documentation
- See `maintenance-workflow.md` for workflow details
- See archive/state.json for examples

### Issues?
- Check rollback plan above
- Verify ARCHIVE_INDEX.md intact
- Report issues with specific project numbers
- Include error messages and context

---

**Migration Status**: In Progress  
**Last Updated**: 2025-12-19  
**Next Review**: After Week 2 completion
