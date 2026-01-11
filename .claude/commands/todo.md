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
# Get all project directories matching {N}_{SLUG} pattern
orphaned_dirs=()
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
    orphaned_dirs+=("$dir")
  fi
done
```

Collect orphaned directories:
- Full directory path
- Project number (extracted from directory name)
- Slug (extracted from directory name)

Store count and list for later use.

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

Orphaned directories (not tracked in any state file): {N}
- {N4}_{SLUG4}/
- {N5}_{SLUG5}/

Total tasks: {N}
Total orphans: {N}

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
    - label: "Archive all orphans"
      description: "Move all {N} orphaned directories to archive/"
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
  question: "Archive these {N} orphaned directories?"
  header: "Confirm"
  options:
    - label: "Yes, archive all"
      description: "Move all orphaned directories to archive/"
    - label: "No, skip orphans"
      description: "Only archive tracked completed/abandoned tasks"
  multiSelect: false
```

**Store the user's decision** (archive_orphans = true/false) for use in Step 5.

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

**E. Move Orphaned Directories (if approved in Step 4.5)**

If user selected "Archive all orphans" (archive_orphans = true):
```bash
for orphan_dir in "${orphaned_dirs[@]}"; do
  dir_name=$(basename "$orphan_dir")
  mv "$orphan_dir" ".claude/specs/archive/${dir_name}"
  echo "Moved orphan: ${dir_name} -> archive/"
done
```

Track orphan moves for output reporting.

**Note**: Orphaned directories are moved but NOT added to archive/state.json since they have no task metadata. They can be manually inspected in archive/ if needed.

### 6. Git Commit

```bash
git add .claude/specs/
git commit -m "todo: archive {N} completed tasks"
```

Include orphan count in message if orphans were archived:
```bash
git commit -m "todo: archive {N} tasks and {M} orphaned directories"
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

Orphaned directories archived: {N}
- {N4}_{SLUG4}/ -> archive/ (orphan)
- {N5}_{SLUG5}/ -> archive/ (orphan)

Skipped (no directory): {N}
- Task #{N6}

Active tasks remaining: {N}
- High priority: {N}
- Medium priority: {N}
- Low priority: {N}

Archives: .claude/specs/archive/
```

If no orphans were archived (either none found or user skipped):
- Omit the "Orphaned directories archived" section

## Notes

- Artifacts (plans, reports, summaries) are preserved in archive/{N}_{SLUG}/
- Tasks can be recovered with `/task --recover N`
- **Orphaned directories** can be manually moved back but have no state.json entry to recover
- Archive is append-only (for audit trail)
- Run periodically to keep TODO.md and .claude/specs/ manageable
