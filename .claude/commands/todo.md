---
description: Archive completed and abandoned tasks
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(mv:*), Bash(mkdir:*), TodoWrite
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

### 3. Prepare Archive List

For each archivable task, collect:
- project_number
- project_name
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

Total: {N} tasks

Run without --dry-run to archive.
```

Exit here if dry run.

### 5. Archive Tasks

**A. Update archive/state.json**

Ensure .claude/specs/archive/ exists.

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

For each archived task with a project directory:
```bash
# Move project directory to archive
mv .claude/specs/{N}_{SLUG}/ .claude/specs/archive/{N}_{SLUG}/
```

This preserves artifacts while keeping the active .claude/specs/ directory clean.

Note: If a directory doesn't exist for a task (e.g., tasks that were never researched/planned), skip the move step for that task.

### 6. Git Commit

```bash
git add .claude/specs/
git commit -m "todo: archive {N} completed tasks"
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
- .claude/specs/{N1}_{SLUG1}/ → archive/
- .claude/specs/{N2}_{SLUG2}/ → archive/

Active tasks remaining: {N}
- High priority: {N}
- Medium priority: {N}
- Low priority: {N}

Archives: .claude/specs/archive/
```

## Notes

- Artifacts (plans, reports, summaries) are preserved in archive/{N}_{SLUG}/
- Tasks can be recovered with `/task --recover N`
- Archive is append-only (for audit trail)
- Run periodically to keep TODO.md and .claude/specs/ manageable
