---
paths: specs/**/*
---

# State Management Rules

## File Synchronization

TODO.md and state.json MUST stay synchronized. Any update to one requires updating the other.

### Canonical Sources
- **state.json**: Machine-readable source of truth
  - next_project_number
  - active_projects array with status, task_type, topic (optional per-task field)
  - active_topics top-level string array: canonical topic taxonomy for task grouping in Task Order
  - Faster to query (12ms vs 100ms for TODO.md parsing)

- **TODO.md**: User-facing source of truth
  - Human-readable task list with descriptions
  - Status markers in brackets: [STATUS]
  - Single `## Tasks` section (new tasks prepended at top)

## Status Transitions

### Permissive Model

Any command can run from any non-terminal status. Only terminal states block transitions:

```
Terminal states: [COMPLETED], [ABANDONED], [EXPANDED]

Any non-terminal status -> any command (research, plan, implement, revise)
Any status -> [BLOCKED] (with reason)
Any status -> [ABANDONED] (moves to archive)
Any non-terminal -> [EXPANDED] (when divided into subtasks)
[IMPLEMENTING] -> [PARTIAL] (on timeout/error)
```

### Restrictions
- Cannot transition from terminal states (completed, abandoned, expanded)
- Cannot mark COMPLETED without all phases done

## Two-Phase Update Pattern

When updating task status:

### Phase 1: Prepare
```
1. Read current state.json
2. Read current TODO.md
3. Validate task exists in both
4. Prepare updated content in memory
5. Validate updates are consistent
```

### Phase 2: Commit
```
1. Write state.json (machine state first)
2. Write TODO.md (user-facing second)
3. Verify both writes succeeded
4. If either fails: log error, preserve original state
```

## Task Order Synchronization

The Task Order section in `specs/TODO.md` is a **derived artifact** generated from `specs/state.json`. It is not a canonical source of truth.

### Derivation Relationship

| Property | Value |
|----------|-------|
| Canonical source | `specs/state.json` (task statuses, dependencies) |
| Derived artifact | `specs/TODO.md` Task Order section (wave+tree display) |
| Divergence tolerance | Acceptable between regeneration events |
| Sync direction | Always state.json → Task Order (never reverse) |

The Task Order may temporarily diverge from `state.json` between regeneration events. This is expected and tolerated. Agents should not hand-edit the Task Order section; regeneration via `generate-task-order.sh` is the only write path.

### Regeneration Triggers

Events that trigger Task Order regeneration:

| Event | Command | Script Call |
|-------|---------|-------------|
| Task archival | `/todo` | `generate-task-order.sh --update-todo` (Step 5.8) |
| Post-vault renumbering | `/todo` | `generate-task-order.sh --update-todo` (Step 5.8.8a) |
| Codebase review | `/review` | `generate-task-order.sh --update-todo` (Section 6.5) |
| Terminal status transition | Automated | `generate-task-order.sh --update-todo` (optional, via hooks) |

All regeneration calls use the `--update-todo` flag, which writes the wave+tree format to the Task Order section in `specs/TODO.md`.

### Responsible Scripts

| Script | Role | When Used |
|--------|------|-----------|
| `generate-task-order.sh --update-todo` | Full regeneration from state.json | `/todo`, `/review`, terminal transitions |
| `update-task-status.sh` (Phase 3) | In-place status-only updates within existing entries | Single-task status changes without full regeneration |

Use `generate-task-order.sh` for all cases where the task set changes (archival, new tasks, renumbering). Use `update-task-status.sh` only for status-only updates to existing Task Order entries.

### Non-Regeneration Events

These events do NOT trigger Task Order regeneration:

- Task creation (before the task enters a terminal or near-terminal state)
- Status transitions to `researching`, `researched`, `planning`, `planned`, `implementing`, `partial`, `blocked`
- Roadmap annotation updates
- Git commits and state.json writes not involving task number changes
- Memory harvest operations

The Task Order is a planning view -- it need not reflect every transient status. Regenerate at archival and review boundaries.

## Error Handling

### On Write Failure
1. Do not update either file partially
2. Log error with context
3. Preserve original state
4. Return error to caller

### On Inconsistency Detection
1. Log the inconsistency
2. Use git blame to determine latest
3. Sync to latest version
4. Use git for recovery of overwritten versions

## Schema Reference

For complete field schemas, status values mapping, artifact linking formats, and directory creation patterns, see:
- [State Management Schema](.claude/context/reference/state-management-schema.md)
