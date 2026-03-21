# Research Report: Task #392

**Task**: Enhance /todo command orphan tracking
**Date**: 2026-01-12
**Focus**: Understand current orphan detection issues and design comprehensive solution

## Summary

The `/todo` command has multiple issues with orphan directory detection and tracking. The core problem is that archived projects' directories are often not moved to `specs/archive/`, and additionally there are directories in both `specs/` and `specs/archive/` that have no corresponding entries in any state file. This research identifies all issues and proposes a comprehensive solution.

## Findings

### Issue 1: jq Query Doesn't Handle Nested Arrays

The current Step 2.5 detection logic uses:
```bash
in_archive=$(jq -r --arg n "$project_num" \
  '.completed_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
  specs/archive/state.json 2>/dev/null)
```

However, `archive/state.json` has a malformed structure where `completed_projects` contains a mix of objects and nested arrays:
```json
"completed_projects": [
  { "project_number": 366, ... },  // Object
  { "project_number": 176, ... },  // Object
  [                                 // Nested array!
    { "project_number": 390, ... },
    { "project_number": 389, ... }
  ]
]
```

**Fix required**: Use `| flatten | .[]` in jq queries to handle nested arrays.

### Issue 2: Directories Not Moved to Archive

**46 directories** exist in `specs/` that ARE tracked in `archive/state.json` but were never physically moved:

| Project | Directory |
|---------|-----------|
| 176 | `176_enhance_proof_search_with_domain_specific_heuristics_and_caching/` |
| 179 | `179_implement_performance_benchmarks_for_proof_search_and_derivation/` |
| 180 | `180_add_test_coverage_metrics_and_reporting/` |
| ... | (46 total) |

These are not "orphans" per se - they're tracked projects whose directories weren't moved when archiving.

### Issue 3: True Orphans in specs/archive/

**38 directories** exist in `specs/archive/` that are NOT tracked in `archive/state.json`:

| Project | Directory |
|---------|-----------|
| 170 | `170_improve_maintenance_report_system_and_documentation/` |
| 170 | `170_maintenance_report_improvements/` (duplicate number!) |
| 173 | `173_integration_tests/` |
| 184 | `184_truth_lean_build_error/` |
| ... | (38 total) |

These are true orphans - directories with no state tracking at all.

### Issue 4: Duplicate Project Numbers

Some project numbers have multiple directories:
- Project 170: 2 directories (different slugs)
- Project 190: 2 directories
- Project 230: 2 directories
- Project 260: 2 directories (one active, one orphan with different slug)
- Project 263: 2 directories (one in specs/, one in archive/)

### Issue 5: Step 5.E Doesn't Create State Entries

The current command at line 217 states:
> **Note**: Orphaned directories are moved but NOT added to archive/state.json since they have no task metadata.

This is the design gap - orphans should be tracked even with minimal metadata extracted from the directory name.

## Current State Summary

| Location | Count | Description |
|----------|-------|-------------|
| `specs/` tracked in active_projects | ~25 | Active tasks |
| `specs/` tracked in archive/state.json | 46 | Archived but not moved |
| `specs/` true orphans | 1-2 | `260_investigate...` etc. |
| `archive/` tracked in archive/state.json | ~63 | Properly archived |
| `archive/` true orphans | 38 | Never tracked |

## Recommendations

### Phase 1: Fix jq Queries

Update Step 2.5 to use flattened queries:
```bash
in_archive=$(jq -r --arg n "$project_num" \
  '.completed_projects | flatten | .[] | select(.project_number == ($n | tonumber)) | .project_number' \
  specs/archive/state.json 2>/dev/null)
```

### Phase 2: Define Orphan Categories

Distinguish between:
1. **Stranded directories**: Tracked in state files but directory in wrong location
2. **True orphans**: Not tracked anywhere

### Phase 3: Update Detection Logic (Step 2.5)

Scan both `specs/` and `specs/archive/` for:
1. Directories not tracked in `state.json` active_projects
2. Directories not tracked in `archive/state.json` completed_projects (flattened)

### Phase 4: Add Orphan State Entries (Step 5.E Enhancement)

When archiving orphans, create minimal entries in `archive/state.json`:
```json
{
  "project_number": 170,
  "project_name": "maintenance_report_improvements",
  "status": "orphan_archived",
  "archived": "2026-01-12T12:00:00Z",
  "source_path": "specs/170_maintenance_report_improvements/",
  "artifacts": ["reports/", "plans/"]  // scan subdirs
}
```

### Phase 5: Fix archive/state.json Schema

Flatten the nested array structure to ensure consistent queries:
```bash
jq '.completed_projects = (.completed_projects | flatten)' archive/state.json
```

## Schema Design for Orphan Entries

**Minimal required fields**:
- `project_number` (from directory name)
- `project_name` (from directory name after first `_`)
- `status`: "orphan_archived"
- `archived`: ISO timestamp

**Optional enrichment** (if subdirectories exist):
- `artifacts`: list detected subdirectories (reports/, plans/, summaries/)
- `description`: null or extracted from any README/plan

## References

- Current /todo command: `.claude/commands/todo.md`
- archive/state.json: `specs/archive/state.json`
- state.json: `specs/state.json`
- artifact-formats.md: `.claude/rules/artifact-formats.md`

## Next Steps

1. Create implementation plan with phases:
   - Phase 1: Fix jq queries to handle nested arrays
   - Phase 2: Enhance detection to scan both directories
   - Phase 3: Add orphan entry creation in Step 5.E
   - Phase 4: Add cleanup for existing orphans (one-time)
   - Phase 5: Fix archive/state.json nested array (one-time)
2. Consider whether to also move stranded directories during archival
3. Document the orphan tracking behavior in command notes
