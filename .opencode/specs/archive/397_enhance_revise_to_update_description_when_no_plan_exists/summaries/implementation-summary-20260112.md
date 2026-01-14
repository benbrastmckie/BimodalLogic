# Implementation Summary: Task #397

**Completed**: 2026-01-12
**Duration**: ~20 minutes

## Changes Made

Enhanced the `/revise` command to handle tasks without plans by updating the task description instead of erroring. Previously, `/revise` would error on `not_started` or `researched` tasks. Now it routes to a description update flow for these statuses.

## Files Modified

- `.claude/commands/revise.md` - Main command definition
  - Updated frontmatter description to reflect dual functionality
  - Replaced section 2 "Validate Status" with "Validate Status and Route"
  - Added section 2a "Description Update (for tasks without plans)"
  - Updated section 8 heading to clarify it applies to plan revisions

## Implementation Details

### Status Routing Logic

| Status | Behavior |
|--------|----------|
| planned, implementing, partial, blocked | Plan revision (existing) |
| not_started, researched | Description update (new) |
| completed | Error: "Task completed, no revision needed" |
| abandoned | Error: "Task abandoned, use /task --recover first" |

### Description Update Flow

1. Read current description from task data
2. Validate revision reason is provided
3. Update state.json with new description
4. Update TODO.md description line
5. Git commit with message "task {N}: revise description"
6. Output showing previous and new description

## Verification

- All status cases are handled with appropriate routing
- Description update flow includes atomic updates to both state.json and TODO.md
- Git commit follows project conventions with Co-Authored-By
- Original plan revision behavior unchanged for tasks with plans

## Notes

- For multi-line descriptions, the Edit tool should include enough context to uniquely identify the description block
- The command now has dual functionality reflected in its description
