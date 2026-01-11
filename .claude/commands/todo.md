---
description: Archive completed and abandoned tasks
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(mv:*), Bash(mkdir:*), Bash(ls:*), Bash(find:*), Bash(jq:*), TodoWrite, AskUserQuestion
argument-hint: [--dry-run]
model: claude-opus-4-5-20251101
---

# /todo Command

Archive completed and abandoned tasks to clean up active task list.

## Arguments

- `--dry-run` - Show what would be archived without making changes

## Execution

### 1. Parse Arguments

```
dry_run = "--dry-run" in $ARGUMENTS
```

### 2. Scan for Archivable Tasks

Read .claude/specs/state.json and identify:
- Tasks with status = "completed"
- Tasks with status = "abandoned"

Read .claude/specs/TODO.md and cross-reference:
- Entries marked [COMPLETED]
- Entries marked [ABANDONED]

### 2.5. Detect Orphaned Directories

Scan for project directories not tracked in any state file.

**CRITICAL**: This step MUST be executed to identify orphaned directories.

```bash
# Get orphaned directories in specs/ (not tracked anywhere)
orphaned_in_specs=()
for dir in .claude/specs/[0-9]*_*/; do
  [ -d "$dir" ] || continue
  project_num=$(basename "$dir" | cut -d_ -f1)

  # Check if in state.json active_projects
  in_active=$(jq -r --arg n "$project_num" \
    '.active_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
    .claude/specs/state.json 2>/dev/null)

  # Check if in archive/state.json completed_projects
  in_archive=$(jq -r --arg n "$project_num" \
    '.completed_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
    .claude/specs/archive/state.json 2>/dev/null)

  # If not in either, it's an orphan
  if [ -z "$in_active" ] && [ -z "$in_archive" ]; then
    orphaned_in_specs+=("$dir")
  fi
done

# Get orphaned directories in specs/archive/ (not tracked in archive/state.json)
orphaned_in_archive=()
for dir in .claude/specs/archive/[0-9]*_*/; do
  [ -d "$dir" ] || continue
  project_num=$(basename "$dir" | cut -d_ -f1)

  # Check if in archive/state.json completed_projects
  in_archive=$(jq -r --arg n "$project_num" \
    '.completed_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
    .claude/specs/archive/state.json 2>/dev/null)

  # If not tracked, it's an orphan
  if [ -z "$in_archive" ]; then
    orphaned_in_archive+=("$dir")
  fi
done

# Combined list for archival operations
orphaned_dirs=("${orphaned_in_specs[@]}" "${orphaned_in_archive[@]}")
```

Collect orphaned directories in two categories:
- `orphaned_in_specs[]` - Directories in specs/ not tracked anywhere (will be moved to archive/)
- `orphaned_in_archive[]` - Directories in archive/ not tracked in archive/state.json (already in archive/, need state entries)

Store counts and lists for later use.

### 3. Prepare Archive List

For each archivable task, collect:
- project_number
- project_name (slug)
- status
- completion/abandonment date
- artifact paths

### 4. Dry Run Output (if --dry-run)

```
Tasks to archive:

Completed:
- #{N1}: {title} (completed {date})
- #{N2}: {title} (completed {date})

Abandoned:
- #{N3}: {title} (abandoned {date})

Orphaned directories in specs/ (will be moved to archive/): {N}
- {N4}_{SLUG4}/
- {N5}_{SLUG5}/

Orphaned directories in archive/ (need state tracking): {N}
- {N6}_{SLUG6}/
- {N7}_{SLUG7}/

Total tasks: {N}
Total orphans: {N} (specs: {N}, archive: {N})

Run without --dry-run to archive.
```

Exit here if dry run.

### 4.5. Handle Orphaned Directories (if any found)

If orphaned directories were detected in Step 2.5:

**Use AskUserQuestion**:
```
AskUserQuestion:
  question: "Found {N} orphaned project directories not tracked in state files. What would you like to do?"
  header: "Orphans"
  options:
    - label: "Track all orphans"
      description: "Move specs/ orphans to archive/ and add state entries for all orphans"
    - label: "Skip orphans"
      description: "Only archive tracked completed/abandoned tasks"
    - label: "Review list first"
      description: "Show the full list of orphaned directories"
  multiSelect: false
```

**If "Review list first" selected**:
Display the full list of orphaned directories with their contents summary:
```
Orphaned directories:
- 170_maintenance_report_improvements/ (contains: reports/, plans/)
- 190_meta_system_optimization/ (contains: reports/)
...

```

Then re-ask with only two options:
```
AskUserQuestion:
  question: "Track these {N} orphaned directories in state files?"
  header: "Confirm"
  options:
    - label: "Yes, track all"
      description: "Move specs/ orphans to archive/ and add state entries for all"
    - label: "No, skip orphans"
      description: "Only archive tracked completed/abandoned tasks"
  multiSelect: false
```

**Store the user's decision** (track_orphans = true/false) for use in Step 5.

If no orphaned directories were found, skip this step and proceed.

### 5. Archive Tasks

**A. Update archive/state.json**

Ensure archive directory exists:
```bash
mkdir -p .claude/specs/archive/
```

Read or create .claude/specs/archive/state.json:
```json
{
  "archived_projects": [],
  "completed_projects": []
}
```

Move each task from state.json `active_projects` to archive/state.json `completed_projects` (for completed tasks) or `archived_projects` (for abandoned tasks).

**B. Update state.json**

Remove archived tasks from active_projects array.

**C. Update TODO.md**

Remove archived task entries from main sections.

**D. Move Project Directories to Archive**

**CRITICAL**: This step MUST be executed - do not skip it.

For each archived task (completed or abandoned):
```bash
# Variables from task data
project_number={N}
project_name={SLUG}

src=".claude/specs/${project_number}_${project_name}"
dst=".claude/specs/archive/${project_number}_${project_name}"

if [ -d "$src" ]; then
  mv "$src" "$dst"
  echo "Moved: ${project_number}_${project_name} -> archive/"
  # Track this move for output reporting
else
  echo "Note: No directory for task ${project_number} (skipped)"
  # Track this skip for output reporting
fi
```

Track:
- directories_moved: list of successfully moved directories
- directories_skipped: list of tasks without directories

**E. Track Orphaned Directories (if approved in Step 4.5)**

If user selected "Track all orphans" (track_orphans = true):

**Step E.1: Move orphaned directories from specs/ to archive/**
```bash
for orphan_dir in "${orphaned_in_specs[@]}"; do
  dir_name=$(basename "$orphan_dir")
  mv "$orphan_dir" ".claude/specs/archive/${dir_name}"
  echo "Moved orphan: ${dir_name} -> archive/"
done
```

**Step E.2: Add state entries for ALL orphans (both moved and existing in archive/)**
```bash
for orphan_dir in "${orphaned_dirs[@]}"; do
  dir_name=$(basename "$orphan_dir")
  project_num=$(echo "$dir_name" | cut -d_ -f1)
  project_name=$(echo "$dir_name" | cut -d_ -f2-)

  # Determine archive path (after potential move)
  archive_path=".claude/specs/archive/${dir_name}"

  # Scan for existing artifacts
  artifacts="[]"
  [ -d "$archive_path/reports" ] && artifacts=$(echo "$artifacts" | jq '. + ["reports/"]')
  [ -d "$archive_path/plans" ] && artifacts=$(echo "$artifacts" | jq '. + ["plans/"]')
  [ -d "$archive_path/summaries" ] && artifacts=$(echo "$artifacts" | jq '. + ["summaries/"]')

  # Add entry to archive/state.json
  jq --arg num "$project_num" \
     --arg name "$project_name" \
     --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     --argjson arts "$artifacts" \
     '.completed_projects += [{
       project_number: ($num | tonumber),
       project_name: $name,
       status: "orphan_archived",
       archived: $date,
       source: "orphan_recovery",
       detected_artifacts: $arts
     }]' .claude/specs/archive/state.json > .claude/specs/archive/state.json.tmp \
  && mv .claude/specs/archive/state.json.tmp .claude/specs/archive/state.json

  echo "Added state entry for orphan: ${dir_name}"
done
```

Track orphan operations for output reporting:
- orphans_moved: count of directories moved from specs/ to archive/
- orphans_tracked: count of state entries added to archive/state.json

### 6. Git Commit

```bash
git add .claude/specs/
git commit -m "todo: archive {N} completed tasks"
```

Include orphan count in message if orphans were tracked:
```bash
git commit -m "todo: archive {N} tasks and track {M} orphaned directories"
```

### 7. Output

```
Archived {N} tasks:

Completed ({N}):
- #{N1}: {title}
- #{N2}: {title}

Abandoned ({N}):
- #{N3}: {title}

Directories moved to archive: {N}
- {N1}_{SLUG1}/ -> archive/
- {N2}_{SLUG2}/ -> archive/

Orphaned directories tracked: {N}
- {N4}_{SLUG4}/ (moved to archive/, state entry added)
- {N5}_{SLUG5}/ (already in archive/, state entry added)

Skipped (no directory): {N}
- Task #{N6}

Active tasks remaining: {N}
- High priority: {N}
- Medium priority: {N}
- Low priority: {N}

Archives: .claude/specs/archive/
```

If no orphans were tracked (either none found or user skipped):
- Omit the "Orphaned directories tracked" section

## Notes

### Task Archival
- Artifacts (plans, reports, summaries) are preserved in archive/{N}_{SLUG}/
- Tasks can be recovered with `/task --recover N`
- Archive is append-only (for audit trail)
- Run periodically to keep TODO.md and .claude/specs/ manageable

### Orphan Tracking

**Orphan Categories**:
1. **Orphaned in specs/** - Directories in `.claude/specs/` not tracked in any state file
   - Action: Move to archive/ AND add entry to archive/state.json
2. **Orphaned in archive/** - Directories in `.claude/specs/archive/` not tracked in archive/state.json
   - Action: Add entry to archive/state.json (no move needed)

**orphan_archived Status**:
- Orphaned directories receive status `"orphan_archived"` in archive/state.json
- The `source` field is set to `"orphan_recovery"` to distinguish from normal archival
- The `detected_artifacts` field lists any existing subdirectories (reports/, plans/, summaries/)

**Recovery**:
- Orphaned directories with state entries can be inspected in archive/
- Manual recovery is possible by moving directories and updating state files
- Use `/task --recover N` only for tracked tasks (not orphans)
