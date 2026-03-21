# Research Report: Task #397

**Task**: Enhance /revise to update description when no plan exists
**Date**: 2026-01-11
**Focus**: General research

## Summary

The /revise command currently errors when invoked on tasks without plans (status `not_started` or `researched`). This research identifies the specific location where the change is needed and documents the state management patterns required to update task descriptions atomically in both state.json and TODO.md.

## Findings

### Current /revise Behavior

The `/revise` command is defined in `.claude/commands/revise.md` (lines 44-50). It currently validates status as follows:

```
### 2. Validate Status

Allowed: planned, implementing, partial, blocked
- If not_started: Error "No plan to revise, use /plan first"
- If completed: Error "Task completed, no revision needed"
- If researched: Note "Consider /plan instead for initial plan"
```

This validation rejects tasks without plans (not_started, researched) entirely, providing no alternative action.

### Real User Example

From `.claude/output/revise.md`, a user attempted:
```
/revise 175 "Many changes have taken place since this task was created. Research and revise the task accordingly."
```

The command errored with:
```
Error: No plan to revise for Task #175
Task 175 has status [NOT STARTED] and no existing implementation plan.
```

The user's intent was clear: update the task description to reflect changed circumstances. This is a valid use case that the current command doesn't support.

### Description Storage Locations

Task descriptions are stored in two places that must stay synchronized:

1. **state.json** (`specs/state.json`):
   ```json
   {
     "project_number": 397,
     "description": "Modify the /revise command..."
   }
   ```

2. **TODO.md** (`specs/TODO.md`):
   ```markdown
   **Description**: Modify the /revise command...
   ```

### State Management Patterns (from skill-status-sync)

The skill-status-sync SKILL.md provides the patterns needed:

**Reading task data:**
```bash
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  specs/state.json)
```

**Updating state.json fields:**
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg desc "$new_description" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    description: $desc,
    last_updated: $ts
  }' specs/state.json > /tmp/state.json && \
  mv /tmp/state.json specs/state.json
```

**Locating task in TODO.md:**
```bash
task_line=$(grep -n "^### ${task_number}\." specs/TODO.md | cut -d: -f1)
```

**Two-Phase Commit Pattern:**
1. Write state.json first (machine state)
2. Write TODO.md second (user-facing)
3. Verify both succeeded

### Description Update in TODO.md

The description in TODO.md follows this format:
```markdown
**Description**: {description text}
```

To update, use Edit tool to replace the existing description line.

### Git Commit Convention

From git-workflow.md, the commit message for description updates could follow:
```
task {N}: update description
```

Or to be consistent with revise:
```
task {N}: revise description
```

## Recommendations

### 1. Add Description Update Branch to /revise

Add a new code path in `/revise` for tasks without plans:

**When status is `not_started` or `researched`:**
- Instead of erroring, update the task description
- Use the revision reason as the new description (or append to existing)
- Follow two-phase commit pattern for atomic updates
- Commit with `task {N}: revise description`

### 2. Behavior Matrix

| Status | Current Behavior | New Behavior |
|--------|------------------|--------------|
| not_started | Error: No plan to revise | Update description |
| researched | Suggest /plan | Update description |
| planned | Create revised plan | Create revised plan (unchanged) |
| implementing | Create revised plan | Create revised plan (unchanged) |
| partial | Create revised plan | Create revised plan (unchanged) |
| blocked | Create revised plan | Create revised plan (unchanged) |
| completed | Error | Error (unchanged) |
| abandoned | Error | Error (unchanged) |

### 3. User Interface

When updating description (no plan exists):
```
Description updated for Task #{N}

Previous: {old_description}
New: {new_description}

Status: [NOT STARTED]
```

### 4. Implementation Approach

Modify `.claude/commands/revise.md` section 2 "Validate Status":

```
### 2. Validate Status and Route

If status in [planned, implementing, partial, blocked]:
  → Continue with plan revision (existing logic)

If status in [not_started, researched]:
  → Branch to description update (new logic)

If status is completed:
  → Error "Task completed, no revision needed"

If status is abandoned:
  → Error "Task abandoned, use /task --recover first"
```

Add new section "2a. Description Update (for tasks without plans)":
- Read current description from state.json
- Construct new description from revision_reason
- Update state.json with jq
- Update TODO.md with Edit
- Git commit

## References

- `.claude/commands/revise.md` - Current command definition
- `.claude/skills/skill-status-sync/SKILL.md` - State management patterns
- `.claude/commands/task.md` - Task creation patterns (description handling)
- `.claude/output/revise.md` - Real error case that inspired this task

## Next Steps

1. Create implementation plan with two phases:
   - Phase 1: Add description update logic to /revise command
   - Phase 2: Test with real tasks and edge cases
