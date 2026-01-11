# Implementation Plan: Task #392

**Task**: Enhance /todo command orphan tracking
**Version**: 001
**Created**: 2026-01-11
**Language**: meta

## Overview

Enhance the `/todo` command to properly track orphaned directories in `archive/state.json`. The current implementation moves orphaned directories to archive but does NOT add entries to `archive/state.json`. Additionally, the jq queries need to be fixed to handle nested arrays in `archive/state.json`. This plan addresses both issues comprehensively.

## Phases

### Phase 1: Fix jq Query for Nested Arrays

**Status**: [NOT STARTED]

**Objectives**:
1. Update Step 2.5 jq query to handle nested arrays in `archive/state.json`
2. Use `| flatten | .[]` pattern for robust querying

**Files to modify**:
- `.claude/commands/todo.md` - Update jq query in Step 2.5

**Steps**:
1. Locate the jq query in Step 2.5 (lines 53-55)
2. Change from:
   ```bash
   jq -r --arg n "$project_num" \
     '.completed_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
     .claude/specs/archive/state.json 2>/dev/null
   ```
   To:
   ```bash
   jq -r --arg n "$project_num" \
     '.completed_projects | flatten | .[] | select(.project_number == ($n | tonumber)) | .project_number' \
     .claude/specs/archive/state.json 2>/dev/null
   ```

**Verification**:
- Test query against current `archive/state.json` with nested arrays
- Verify both flat entries and nested array entries are found

---

### Phase 2: Fix archive/state.json Schema

**Status**: [NOT STARTED]

**Objectives**:
1. Flatten the existing nested arrays in `archive/state.json`
2. Ensure consistent schema for future entries

**Files to modify**:
- `.claude/specs/archive/state.json` - Flatten nested arrays

**Steps**:
1. Read current `archive/state.json`
2. Apply jq transformation to flatten nested arrays:
   ```bash
   jq '.completed_projects = (.completed_projects | flatten)' archive/state.json
   ```
3. Write back the fixed file
4. Verify no data loss (same count of entries)

**Verification**:
- Count entries before and after (should be equal)
- All project numbers still present
- Standard jq queries work without flatten

---

### Phase 3: Enhance Step 2.5 Detection

**Status**: [NOT STARTED]

**Objectives**:
1. Scan both `specs/` and `specs/archive/` for orphaned directories
2. Distinguish between "stranded" (tracked but wrong location) and "true orphans" (untracked)

**Files to modify**:
- `.claude/commands/todo.md` - Enhance Step 2.5 detection logic

**Steps**:
1. Update detection to scan both directories:
   ```bash
   # Scan specs/ for orphans
   for dir in .claude/specs/[0-9]*_*/; do
     ...
   done

   # Scan specs/archive/ for orphans
   for dir in .claude/specs/archive/[0-9]*_*/; do
     ...
   done
   ```
2. Create separate lists:
   - `orphaned_in_specs[]` - Directories in specs/ not tracked anywhere
   - `orphaned_in_archive[]` - Directories in archive/ not tracked in archive/state.json
3. Update dry-run output to show both categories

**Verification**:
- Detection finds directories in both locations
- Correctly identifies tracked vs untracked directories

---

### Phase 4: Add Orphan State Entries (Step 5.E Enhancement)

**Status**: [NOT STARTED]

**Objectives**:
1. When archiving orphans, create entries in `archive/state.json`
2. Extract minimal metadata from directory name
3. Optionally scan for existing artifacts

**Files to modify**:
- `.claude/commands/todo.md` - Enhance Step 5.E

**Steps**:
1. Update Step 5.E description to:
   ```markdown
   **E. Move Orphaned Directories and Track in State (if approved in Step 4.5)**

   If user selected "Archive all orphans" (archive_orphans = true):
   ```
2. For each orphan, create a minimal state entry:
   ```bash
   # Extract metadata from directory name
   dir_name=$(basename "$orphan_dir")
   project_num=$(echo "$dir_name" | cut -d_ -f1)
   project_name=$(echo "$dir_name" | cut -d_ -f2-)

   # Scan for artifacts
   artifacts=()
   [ -d "$orphan_dir/reports" ] && artifacts+=("reports/")
   [ -d "$orphan_dir/plans" ] && artifacts+=("plans/")
   [ -d "$orphan_dir/summaries" ] && artifacts+=("summaries/")
   ```
3. Add jq command to append orphan entry to `archive/state.json`:
   ```bash
   jq --arg num "$project_num" \
      --arg name "$project_name" \
      --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      '.completed_projects += [{
        project_number: ($num | tonumber),
        project_name: $name,
        status: "orphan_archived",
        archived: $date,
        source: "orphan_recovery"
      }]' archive/state.json
   ```
4. Remove the note that says orphans are not added to state files
5. Update output section to reflect new behavior

**Verification**:
- Orphan entries appear in archive/state.json
- Entries have correct project_number and project_name
- Status is "orphan_archived"

---

### Phase 5: Update Documentation and Notes

**Status**: [NOT STARTED]

**Objectives**:
1. Update command notes to reflect new orphan tracking behavior
2. Document the orphan_archived status

**Files to modify**:
- `.claude/commands/todo.md` - Update Notes section

**Steps**:
1. Update the Notes section at the end of the command file:
   - Remove note about orphans not being tracked
   - Add note about orphan_archived status
   - Document recovery procedure for orphaned directories
2. Add explanation of orphan categories:
   - True orphans (not tracked anywhere)
   - Stranded directories (tracked but in wrong location)

**Verification**:
- Notes section accurately describes new behavior
- Recovery procedures are documented

---

## Dependencies

- None (this is a standalone enhancement to the /todo command)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Data loss during schema fix | High | Low | Backup archive/state.json before flattening |
| jq query performance on large archives | Low | Low | Flatten operation is O(n) and only runs once |
| Duplicate project numbers | Medium | Medium | Log warning for duplicates, don't fail |

## Success Criteria

- [ ] jq queries in Step 2.5 handle nested arrays via `| flatten | .[]`
- [ ] archive/state.json has flat `completed_projects` array (no nested arrays)
- [ ] Detection scans both specs/ and specs/archive/ directories
- [ ] Orphaned directories get entries in archive/state.json with status "orphan_archived"
- [ ] Notes section documents new orphan tracking behavior
- [ ] Existing /todo functionality unchanged for tracked tasks

## Rollback Plan

1. Restore archive/state.json from git if schema fix causes issues
2. Revert todo.md changes via git checkout
3. Manual cleanup of any orphan entries added during testing
