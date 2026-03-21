# Implementation Summary: Task #402

**Completed**: 2026-01-12
**Duration**: ~30 minutes

## Changes Made

Renamed the `/task --divide` flag to `/task --expand` across the active `.claude/` system for consistency with the new `[EXPANDED]` status marker. The `/research --divide` feature (topic subdivision) was preserved unchanged.

## Files Modified

### Core Command Files
- `.claude/commands/task.md` - Updated argument-hint, mode detection, and section heading
- `.claude/CLAUDE.md` - Updated quick reference example

### Standards Documentation
- `.claude/context/core/standards/task-management.md` - Updated 4 occurrences (inline example, section heading, usage examples)
- `.claude/context/core/standards/git-integration.md` - Updated commit trigger list
- `.claude/context/core/standards/status-markers.md` - Updated transition diagram
- `.claude/context/core/standards/documentation.md` - Updated changelog example

### Orchestration Files
- `.claude/context/core/orchestration/routing.md` - Updated flag table and bash routing logic (preserved `/research --divide`)
- `.claude/context/core/orchestration/validation.md` - Updated flag validation code

### Workflow Files
- `.claude/context/core/workflows/status-transitions.md` - Updated status transition description

### Related Summaries
- `specs/401_add_expanded_status_for_parent_tasks/summaries/implementation-summary-20260112.md` - Updated forward reference to use --expand

## Verification

- All active documentation now uses `--expand` for task expansion
- `/research --divide` preserved (3 occurrences in research-workflow.md)
- Archive files unchanged (historical records)
- Grep verification passed: no task-related --divide references remain outside archives

## Notes

- Total files updated: 10 (9 new changes + 1 related summary update)
- The rename aligns with the `[EXPANDED]` status introduced in task 401
- Internal operation names (divide_task, task-divider) were not changed as they are separate from the flag name
