# TODO.md - MOVED

**This file has been migrated to the opencode system.**

All active tasks are now tracked in:

```
.opencode/specs/TODO.md
```

## Why the Move?

The opencode system utilities (`/review`, `/plan`, `/implement`, etc.) are designed to work with `.opencode/specs/TODO.md`. This migration ensures:

1. ✅ Automatic TODO updates from `/review` command
2. ✅ Integration with project planning and implementation workflows
3. ✅ Synchronization with verification reports and analysis
4. ✅ Consistent task tracking across the opencode system

## How to Use

```bash
# View current tasks
cat .opencode/specs/TODO.md

# Update TODO after repository review
/review

# Create implementation plan for a task
/plan "Task description"

# Implement a planned task
/implement <project_number>
```

## Migration Details

- **Migration Date**: 2025-12-16
- **Tasks Migrated**: 16 active tasks (all preserved with full context)
- **History Preserved**: Git history maintains all completion records
- **Old Location**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md`
- **New Location**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/specs/TODO.md`

## Archive

This file is kept for reference. All future updates should be made to `.opencode/specs/TODO.md`.

For historical task completion records, use:
```bash
git log --all --grep="Task" --oneline
```
