# Research Report: Task #388

**Task**: Fix /todo command directory archiving
**Date**: 2026-01-12
**Focus**: In addition to moving recently completed or abandoned projects, also move orphaned project directories (with user approval)

## Summary

The `/todo` command correctly updates `state.json` and `archive/state.json` when archiving tasks, but fails to execute Step 5D which moves project directories to the archive. Additionally, there are 40 orphaned project directories that exist in `.claude/specs/` but are not tracked in either `state.json` or `archive/state.json`. The user wants these orphans to be archivable with explicit approval via `AskUserQuestion`.

## Findings

### Current State Analysis

**Directory counts:**
- Project directories in `.claude/specs/`: 106
- Project directories in `.claude/specs/archive/`: 0
- Active projects in `state.json`: 37
- Archived projects in `archive/state.json`: 50
- Orphaned directories: 40 (including some duplicate-numbered directories)

**Orphaned directories** are those with project directories that don't match any entry in either `state.json` (active_projects) or `archive/state.json` (completed_projects). Examples include:
- `170_improve_maintenance_report_system_and_documentation/`
- `170_maintenance_report_improvements/` (duplicate number, different slug)
- `190_improve_maintenance_md_documentation/`
- `190_meta_system_optimization/` (duplicate number, different slug)
- Many others in the 170-225+ range

### Root Cause

The `/todo` command document correctly describes the expected behavior in Step 5D:
```bash
mv .claude/specs/{N}_{SLUG}/ .claude/specs/archive/{N}_{SLUG}/
```

However, the command is a "prompt document" that Claude Code interprets at runtime. The directory move step is either:
1. Being skipped due to execution flow
2. Not being explicitly executed because earlier steps complete and the command returns
3. Failing silently without error handling

### Related Command Patterns

The `/task --recover` command demonstrates the inverse operation:
```bash
if [ -d ".claude/specs/archive/${task_number}_${slug}" ]; then
  mv ".claude/specs/archive/${task_number}_${slug}" ".claude/specs/${task_number}_${slug}"
fi
```

This pattern should be mirrored in `/todo` for the forward direction.

### AskUserQuestion Pattern

The `/meta` command demonstrates the correct pattern for user confirmation:
```
AskUserQuestion:
  question: "Proceed with creating these tasks?"
  header: "Confirm"
  options:
    - label: "Yes, create tasks"
      description: "Create {N} tasks in TODO.md and state.json"
    - label: "Revise"
      description: "Go back and adjust"
    - label: "Cancel"
      description: "Exit without changes"
```

## Recommendations

### 1. Add Explicit Directory Move Step

Update Step 5D with explicit bash commands and conditional checks:
```bash
for each archived_task (project_number, project_name):
  src=".claude/specs/${project_number}_${project_name}"
  dst=".claude/specs/archive/${project_number}_${project_name}"
  if [ -d "$src" ]; then
    mv "$src" "$dst"
    echo "Moved: $src -> archive/"
  fi
```

### 2. Add Orphan Detection Step (New Step 2.5)

Before the dry run output, scan for orphaned directories:
```bash
# Get all {N}_{SLUG} directories
# Compare against active_projects and completed_projects
# Collect orphans for separate handling
```

### 3. Add User Confirmation for Orphans (New Step 4.5)

Use `AskUserQuestion` to present orphaned directories:
```
AskUserQuestion:
  question: "Found {N} orphaned project directories not tracked in any state file. Archive them?"
  header: "Orphans"
  options:
    - label: "Archive all orphans"
      description: "Move all {N} orphaned directories to archive/"
    - label: "Skip orphans"
      description: "Only archive tracked completed/abandoned tasks"
    - label: "Review list"
      description: "Show me the orphaned directories first"
  multiSelect: false
```

### 4. Update allowed-tools

Add `AskUserQuestion` to the command's allowed-tools:
```yaml
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(mv:*), Bash(mkdir:*), Bash(ls:*), TodoWrite, AskUserQuestion
```

### 5. Update Output Section

Add reporting for orphan handling:
```
Orphaned directories archived: {N}
- .claude/specs/170_maintenance_report_improvements/ -> archive/
```

## Technical Details

### Orphan Detection Algorithm

```bash
# All directories in specs/ matching {N}_{SLUG} pattern
find .claude/specs/ -maxdepth 1 -type d -name '[0-9]*_*' | while read dir; do
  num=$(basename "$dir" | cut -d_ -f1)
  # Check if in active_projects
  in_active=$(jq -r --arg n "$num" '.active_projects[] | select(.project_number == ($n | tonumber)) | .project_number' .claude/specs/state.json)
  # Check if in completed_projects
  in_archive=$(jq -r --arg n "$num" '.completed_projects[] | select(.project_number == ($n | tonumber)) | .project_number' .claude/specs/archive/state.json)

  if [ -z "$in_active" ] && [ -z "$in_archive" ]; then
    echo "$dir"  # Orphan
  fi
done
```

### Edge Cases to Handle

1. **Duplicate numbers with different slugs**: Projects 170 and 190 each have two directories with different slugs. The orphan handling should move both.

2. **No directory exists**: Some tasks may never have had artifacts created (never researched/planned). Skip the move step gracefully.

3. **Archive directory doesn't exist**: Ensure `mkdir -p .claude/specs/archive/` runs before any moves.

4. **Partial state**: If directory exists but task isn't tracked anywhere, archive the directory but don't create a state.json entry for it.

## References

- `.claude/commands/todo.md` - Current command implementation (lines 86-96 for Step 5D)
- `.claude/commands/task.md` - `/task --recover` pattern (lines 155-159)
- `.claude/commands/meta.md` - AskUserQuestion patterns (lines 278-286)

## Next Steps

1. Create implementation plan with 3-4 phases:
   - Phase 1: Add AskUserQuestion to allowed-tools and add orphan detection
   - Phase 2: Add user confirmation flow for orphans
   - Phase 3: Fix directory move execution for archived tasks
   - Phase 4: Add comprehensive output reporting
2. Test with `--dry-run` first
3. Run full archive cycle to verify directories move correctly
