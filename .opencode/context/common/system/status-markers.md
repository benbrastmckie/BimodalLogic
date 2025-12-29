# Status Markers Specification

**Version**: 1.0  
**Last Updated**: 2025-12-23  
**Scope**: .opencode/specs/TODO.md tasks, implementation plans, and state tracking

## Overview

This document defines the standardized status markers used across the ProofChecker project for tracking task and phase progress. These markers ensure consistency across .opencode/specs/TODO.md, implementation plans, and all automation tools.

## Standard Status Markers

### `[NOT STARTED]`

**Meaning**: Task or phase has not yet begun.

**Usage**:
- Initial state for new tasks in .opencode/specs/TODO.md
- Initial state for phases in implementation plans
- Indicates no work has been performed

**Valid Transitions**:
- `[NOT STARTED]` → `[IN PROGRESS]` (work begins)
- `[NOT STARTED]` → `[BLOCKED]` (blocked before starting)

**Examples**:
```markdown
**Status**: [NOT STARTED]

## Phase 1: Setup Infrastructure [NOT STARTED]
```

---

### `[IN PROGRESS]`

**Meaning**: Task or phase is currently being worked on.

**Usage**:
- Task has been started but not completed
- Phase is currently executing
- Active work is ongoing

**Valid Transitions**:
- `[IN PROGRESS]` → `[COMPLETED]` (work finishes successfully)
- `[IN PROGRESS]` → `[BLOCKED]` (work encounters blocker)
- `[IN PROGRESS]` → `[ABANDONED]` (work is abandoned)

**Timestamps**:
- Always include `**Started**: YYYY-MM-DD` when transitioning to `[IN PROGRESS]`

**Examples**:
```markdown
**Status**: [IN PROGRESS]
**Started**: 2025-12-20

## Phase 2: Implement Core Logic [IN PROGRESS]
(Started: 2025-12-20T10:15:30Z)
```

---

### `[BLOCKED]`

**Meaning**: Task or phase is blocked by dependencies or issues.

**Usage**:
- Task cannot proceed due to unmet dependencies
- Phase is blocked by failed prerequisite phase
- External blocker prevents progress

**Valid Transitions**:
- `[BLOCKED]` → `[IN PROGRESS]` (blocker resolved, work resumes)
- `[BLOCKED]` → `[ABANDONED]` (blocker cannot be resolved)

**Required Information**:
- Always include `**Blocked**: YYYY-MM-DD` timestamp
- Always include `**Blocking Reason**: {reason}` or `**Blocked by**: {dependency}`

**Examples**:
```markdown
**Status**: [BLOCKED]
**Blocked**: 2025-12-20
**Blocking Reason**: Blocked by failed task 64

## Phase 3: Integration Tests [BLOCKED]
(Blocked by: Failed Phase 2, Reason: Build errors)
```

---

### `[ABANDONED]`

**Meaning**: Task or phase was started but abandoned without completion.

**Usage**:
- Work was started but discontinued
- Approach was attempted but proved infeasible
- Task is no longer relevant or needed

**Valid Transitions**:
- `[ABANDONED]` → `[NOT STARTED]` (restart from scratch)
- `[ABANDONED]` is typically terminal (no further transitions)

**Required Information**:
- Always include `**Abandoned**: YYYY-MM-DD` timestamp
- Always include `**Abandonment Reason**: {reason}`

**Examples**:
```markdown
**Status**: [ABANDONED]
**Started**: 2025-12-15
**Abandoned**: 2025-12-20
**Abandonment Reason**: Approach proved infeasible; alternative solution implemented in Task 72

## Phase 4: Legacy Integration [ABANDONED]
(Started: 2025-12-15T09:00:00Z)
(Abandoned: 2025-12-20T14:30:00Z, Reason: Legacy system deprecated)
```

---

### `[COMPLETED]`

**Meaning**: Task or phase is finished successfully.

**Usage**:
- All work is complete
- Success criteria met
- No further action needed

**Valid Transitions**:
- `[COMPLETED]` is terminal (no further transitions)
- Completed tasks/phases should not be modified

**Required Information**:
- Always include `**Completed**: YYYY-MM-DD` timestamp
- Do not add emojis; rely on the status marker and text alone.

**Examples**:
```markdown
**Status**: [COMPLETED]
**Started**: 2025-12-19
**Completed**: 2025-12-20

### 63. Add Missing Directory READMEs
**Status**: [COMPLETED]
**Started**: 2025-12-19
**Completed**: 2025-12-20

## Phase 1: Setup Infrastructure [COMPLETED]
(Started: 2025-12-19T10:00:00Z)
(Completed: 2025-12-19T10:30:00Z)
```

---

### Command-Specific Status Markers

Command-specific status markers track the progress of specific command workflows. These markers provide fine-grained visibility into which stage a task is in.

**In-Progress Markers**:
- `[RESEARCHING]`: Task research is actively underway (used by `/research`)
- `[PLANNING]`: Implementation plan is being created (used by `/plan`)
- `[REVISING]`: Plan revision is in progress (used by `/revise`)
- `[IMPLEMENTING]`: Implementation work is actively underway (used by `/implement`)

**Completion Markers**:
- `[RESEARCHED]`: Research completed, deliverables created
- `[PLANNED]`: Implementation plan completed, ready for implementation
- `[REVISED]`: Plan revision completed, new plan version created
- `[COMPLETED]`: Implementation finished successfully (terminal state)
- `[PARTIAL]`: Implementation partially completed (can resume)
- `[BLOCKED]`: Work blocked by dependencies or issues

**Workflow Examples**:

`/research` flow:
```markdown
[NOT STARTED] → [RESEARCHING] → [RESEARCHED]
                       ↓
                  [BLOCKED] (if issues occur)
```

`/plan` flow:
```markdown
[NOT STARTED] → [PLANNING] → [PLANNED]
      ↓               ↓
[RESEARCHED] →   [BLOCKED] (if issues occur)
```

`/revise` flow:
```markdown
[PLANNED] → [REVISING] → [REVISED]
                ↓
           [BLOCKED] (if issues occur)
```

`/implement` flow:
```markdown
[PLANNED] → [IMPLEMENTING] → [COMPLETED]
    ↓             ↓              ↓
[NOT STARTED] → [PARTIAL] ← timeout/incomplete
                  ↓
              [BLOCKED] (if issues occur)
```

**Usage Guidelines**:
- `/research`: `[RESEARCHING]` at start → `[RESEARCHED]` on completion
- `/plan`: `[PLANNING]` at start → `[PLANNED]` on completion
- `/revise`: `[REVISING]` at start → `[REVISED]` on completion
- `/implement`: `[IMPLEMENTING]` at start → `[COMPLETED]`/`[PARTIAL]`/`[BLOCKED]` on completion
- State file values mirror these markers using lowercase (`researching`, `planned`, `implementing`, etc.)

**Required Information**:
- Always include `**Started**: YYYY-MM-DD` when transitioning to in-progress state
- Always include `**Completed**: YYYY-MM-DD` when transitioning to completion state
- Preserve `**Started**` timestamp through all transitions
- Keep lazy creation: project roots/subdirs are created only when writing artifacts

**Examples**:
```markdown
**Status**: [RESEARCHING]
**Started**: 2025-12-27

**Status**: [RESEARCHED]
**Started**: 2025-12-27
**Completed**: 2025-12-27
- Research: .opencode/specs/154.../reports/research-001.md

**Status**: [PLANNING]
**Started**: 2025-12-27

**Status**: [PLANNED]
**Started**: 2025-12-27
**Completed**: 2025-12-27
- Plan: .opencode/specs/128.../plans/implementation-001.md

**Status**: [IMPLEMENTING]
**Started**: 2025-12-27

**Status**: [COMPLETED]
**Started**: 2025-12-27
**Completed**: 2025-12-27
```

---

## Status Transition Diagram

```
[NOT STARTED] ─────────────────────────────────────────────────┐
    │                                                           │
    │ (/research)         (/plan)          (/implement)        │ (blocked before start)
    ▼                     ▼                 ▼                  ▼
[RESEARCHING]    [PLANNING]        [IMPLEMENTING]         [BLOCKED]
    │                │                     │                   │
    │                │                     │                   │ (blocker resolved)
    ▼                ▼                     ▼                   │
[RESEARCHED] ──→ [PLANNED] ──(/revise)──→ [REVISING]          │
                    │            │             │               │
                    │            │             ▼               │
                    │            │        [REVISED]            │
                    │            │             │               │
                    │            └─────────────┘               │
                    │ (/implement)                             │
                    ▼                                          │
             [IMPLEMENTING] ─────────────────────────────────> │
                    │                                          │
                    │                                          │
                    ├────> [COMPLETED] (all phases done)       │
                    ├────> [PARTIAL] (some phases done)        │
                    └────> [BLOCKED] (cannot proceed) ─────────┘
                                     
    ┌──────────────────────────────────────────────────────────┘
    │ (work abandoned)
    ▼
[ABANDONED]
```

### Valid Transitions

| From | To | Condition |
|------|-----|-----------|
| `[NOT STARTED]` | `[RESEARCHING]` | `/research` command starts |
| `[NOT STARTED]` | `[PLANNING]` | `/plan` command starts |
| `[NOT STARTED]` | `[IMPLEMENTING]` | `/implement` command starts (no plan) |
| `[NOT STARTED]` | `[BLOCKED]` | Blocked before starting |
| `[RESEARCHING]` | `[RESEARCHED]` | Research completes successfully |
| `[RESEARCHING]` | `[BLOCKED]` | Research encounters blocker |
| `[RESEARCHING]` | `[ABANDONED]` | Research discontinued |
| `[RESEARCHED]` | `[PLANNING]` | `/plan` command starts |
| `[PLANNING]` | `[PLANNED]` | Planning completes successfully |
| `[PLANNING]` | `[BLOCKED]` | Planning encounters blocker |
| `[PLANNING]` | `[ABANDONED]` | Planning discontinued |
| `[PLANNED]` | `[REVISING]` | `/revise` command starts |
| `[PLANNED]` | `[IMPLEMENTING]` | `/implement` command starts |
| `[REVISING]` | `[REVISED]` | Revision completes successfully |
| `[REVISING]` | `[BLOCKED]` | Revision encounters blocker |
| `[REVISED]` | `[IMPLEMENTING]` | `/implement` command starts |
| `[IMPLEMENTING]` | `[COMPLETED]` | Implementation finishes successfully |
| `[IMPLEMENTING]` | `[PARTIAL]` | Implementation partially complete (timeout) |
| `[IMPLEMENTING]` | `[BLOCKED]` | Implementation encounters blocker |
| `[IMPLEMENTING]` | `[ABANDONED]` | Implementation discontinued |
| `[PARTIAL]` | `[IMPLEMENTING]` | Resume implementation |
| `[PARTIAL]` | `[ABANDONED]` | Abandon incomplete work |
| `[BLOCKED]` | `[RESEARCHING]` | Blocker resolved, resume research |
| `[BLOCKED]` | `[PLANNING]` | Blocker resolved, resume planning |
| `[BLOCKED]` | `[IMPLEMENTING]` | Blocker resolved, resume implementation |
| `[BLOCKED]` | `[ABANDONED]` | Blocker cannot be resolved |
| `[ABANDONED]` | `[NOT STARTED]` | Restart from scratch (rare) |

### Invalid Transitions

| From | To | Why Invalid |
|------|-----|-------------|
| `[COMPLETED]` | Any | Completed work should not change |
| `[NOT STARTED]` | `[COMPLETED]` | Must go through command-specific workflow |
| `[NOT STARTED]` | `[RESEARCHED]` | Must go through `[RESEARCHING]` |
| `[NOT STARTED]` | `[PLANNED]` | Must go through `[PLANNING]` |
| `[NOT STARTED]` | `[ABANDONED]` | Cannot abandon work that never started |
| `[RESEARCHING]` | `[PLANNED]` | Must complete research first |
| `[PLANNING]` | `[COMPLETED]` | Planning creates plan, not completion |
| `[IMPLEMENTING]` | `[RESEARCHED]` | Cannot go backwards in workflow |
| `[IMPLEMENTING]` | `[PLANNED]` | Cannot go backwards in workflow |
| `[ABANDONED]` | `[COMPLETED]` | Abandoned work is not complete |

---

## Context-Specific Usage

### .opencode/specs/TODO.md Tasks

**Format**:
```markdown
### 63. Add Missing Directory READMEs
**Effort**: 1 hour
**Status**: [NOT STARTED]
**Priority**: Medium
```

**Lifecycle**:
1. Created: `[NOT STARTED]`
2. Work begins: `[IN PROGRESS]` + `**Started**: YYYY-MM-DD`
3. Work completes: `[COMPLETED]` + `**Completed**: YYYY-MM-DD` + ✅ to title
4. Or blocked: `[BLOCKED]` + `**Blocked**: YYYY-MM-DD` + `**Blocking Reason**: {reason}`
5. Or abandoned: `[ABANDONED]` + `**Abandoned**: YYYY-MM-DD` + `**Abandonment Reason**: {reason}`

**Status Update Tools**:
- `/implement` command: Marks `[IN PROGRESS]` at start, `[COMPLETED]` at end (simple tasks)
- `/plan` command: Marks `[IN PROGRESS]` at start, `[PLANNED]` at completion
- `/research` command: Marks `[IN PROGRESS]` at start, `[RESEARCHED]` at completion
- `/revise` command: Preserves current status, creates new plan version
- `/todo` command: Removes `[COMPLETED]` **and** `[ABANDONED]` tasks from TODO/state (with confirmation thresholds) while preserving numbering and lazy creation guardrails
- `status-sync-manager`: Atomic multi-file updates (.opencode/specs/TODO.md + state.json + plan files)
- `batch-status-manager`: Atomic batch updates for .opencode/specs/TODO.md only
- `todo-manager`: Manual status updates

---

### Implementation Plans

**Format**:
```markdown
## Phase 1: Setup Infrastructure [NOT STARTED]

## Phase 2: Implement Core Logic [IN PROGRESS]
(Started: 2025-12-20T10:15:30Z)

## Phase 3: Testing [COMPLETED] ✅
(Started: 2025-12-20T11:00:00Z)
(Completed: 2025-12-20T11:45:00Z)
```

**Lifecycle**:
1. Created: `[NOT STARTED]`
2. Phase begins: `[IN PROGRESS]` + `(Started: ISO8601_timestamp)`
3. Phase completes: `[COMPLETED]` + `(Completed: ISO8601_timestamp)` + ✅
4. Or blocked: `[BLOCKED]` + `(Blocked by: {dependency}, Reason: {reason})`
5. Or abandoned: `[ABANDONED]` + `(Abandoned: ISO8601_timestamp, Reason: {reason})`

**Status Update Tools**:
- `implementation-orchestrator`: Updates plan file with phase status
- `/implement` command: Orchestrates phase execution and status tracking

---

### State Files (state.json)

**Format**:
```json
{
  "tasks": {
    "63": {
      "status": "completed",
      "started": "2025-12-19",
      "completed": "2025-12-20"
    },
    "64": {
      "status": "in_progress",
      "started": "2025-12-20"
    },
    "65": {
      "status": "blocked",
      "blocked": "2025-12-20",
      "blocking_reason": "Blocked by failed task 64"
    }
  }
}
```

**Status Values** (lowercase, underscore-separated):
- `not_started`
- `researching` (task research underway)
- `researched` (research completed)
- `planning` (plan creation underway)
- `planned` (plan completed)
- `revising` (plan revision underway)
- `revised` (plan revision completed)
- `implementing` (implementation underway)
- `partial` (implementation partially completed)
- `completed` (implementation fully completed)
- `blocked` (work blocked)
- `abandoned` (work discontinued)

---

## Timestamp Formats

### .opencode/specs/TODO.md Format

**Date Only** (YYYY-MM-DD):
```markdown
**Started**: 2025-12-20
**Completed**: 2025-12-20
**Blocked**: 2025-12-20
**Abandoned**: 2025-12-20
```

### Implementation Plan Format

**ISO 8601 with Timezone** (YYYY-MM-DDTHH:MM:SSZ):
```markdown
(Started: 2025-12-20T10:15:30Z)
(Completed: 2025-12-20T11:45:15Z)
(Blocked by: Phase 2, Reason: Build errors)
(Abandoned: 2025-12-20T14:30:00Z, Reason: Approach infeasible)
```

### State File Format

**ISO 8601 Date** (YYYY-MM-DD):
```json
{
  "started": "2025-12-20",
  "completed": "2025-12-20"
}
```

---

## Backward Compatibility

### Legacy Status Values

For backward compatibility, tools should recognize and convert legacy status values:

| Legacy Value | Standard Value | Conversion |
|--------------|----------------|------------|
| `Not Started` | `[NOT STARTED]` | Add brackets |
| `In Progress` | `[IN PROGRESS]` | Add brackets |
| `Complete` | `[COMPLETED]` | Add brackets, change to past tense |
| `COMPLETE` | `[COMPLETED]` | Add brackets, change to past tense |
| `[COMPLETE]` | `[COMPLETED]` | Change to past tense |
| `Failed` | `[ABANDONED]` or `[BLOCKED]` | Context-dependent |
| `[FAILED]` | `[ABANDONED]` or `[BLOCKED]` | Context-dependent |

**Conversion Rules**:
- `Failed` → `[BLOCKED]` if task can be retried after fixing blocker
- `Failed` → `[ABANDONED]` if task approach was fundamentally flawed

---

## Tool Integration

### Commands

| Command | Status Updates |
|---------|----------------|
| `/research` | `[NOT STARTED]` → `[RESEARCHING]` (start) → `[RESEARCHED]` (completion) with timestamps |
| `/plan` | `[NOT STARTED]`/`[RESEARCHED]` → `[PLANNING]` (start) → `[PLANNED]` (completion) with timestamps |
| `/revise` | `[PLANNED]` → `[REVISING]` (start) → `[REVISED]` (completion), creates new plan version |
| `/implement` | `[NOT STARTED]`/`[PLANNED]` → `[IMPLEMENTING]` (start) → `[COMPLETED]`/`[PARTIAL]`/`[BLOCKED]` (completion) |
| `/todo` | Reviews and cleans up `[COMPLETED]` **and** `[ABANDONED]` tasks |

### Subagents

| Subagent | Status Updates |
|----------|----------------|
| `task-executor` | Marks tasks `[IN PROGRESS]` at start |
| `batch-task-orchestrator` | Manages batch task status transitions |
| `batch-status-manager` | Atomic .opencode/specs/TODO.md updates for multiple tasks |
| `implementation-orchestrator` | Updates plan file phase status |
| `todo-manager` | Manual .opencode/specs/TODO.md status updates |

---

## Best Practices

### 1. Always Include Timestamps

**Good**:
```markdown
**Status**: [IN PROGRESS]
**Started**: 2025-12-20
```

**Bad**:
```markdown
**Status**: [IN PROGRESS]
```

### 2. Always Include Blocking/Abandonment Reasons

**Good**:
```markdown
**Status**: [BLOCKED]
**Blocked**: 2025-12-20
**Blocking Reason**: Blocked by failed task 64
```

**Bad**:
```markdown
**Status**: [BLOCKED]
```

### 3. Use Consistent Formatting

**Good**:
```markdown
**Status**: [COMPLETED]
**Started**: 2025-12-19
**Completed**: 2025-12-20
```

**Bad**:
```markdown
Status: COMPLETED
started: 12/19/2025
completed: 12/20/2025
```

### 4. Preserve Status History

When updating status, preserve previous timestamps:

**Good**:
```markdown
**Status**: [COMPLETED]
**Started**: 2025-12-19
**Completed**: 2025-12-20
```

**Bad** (overwrites history):
```markdown
**Status**: [COMPLETED]
**Completed**: 2025-12-20
```

### 5. Use Atomic Updates

For batch operations, use `batch-status-manager` to ensure atomic updates:

**Good**:
```python
batch_status_manager.mark_complete(
    tasks=[
        {"task_num": 63, "timestamp": "2025-12-20"},
        {"task_num": 64, "timestamp": "2025-12-20"}
    ]
)
```

**Bad** (non-atomic):
```python
update_task(63, "COMPLETED")
update_task(64, "COMPLETED")  # May fail, leaving inconsistent state
```

---

## Examples

### .opencode/specs/TODO.md Task Lifecycle

**Initial State**:
```markdown
### 63. Add Missing Directory READMEs
**Effort**: 1 hour
**Status**: [NOT STARTED]
**Priority**: Medium
```

**After `/implement 63` starts**:
```markdown
### 63. Add Missing Directory READMEs
**Effort**: 1 hour
**Status**: [IN PROGRESS]
**Started**: 2025-12-20
**Priority**: Medium
```

**After task completes**:
```markdown
### 63. Add Missing Directory READMEs ✅
**Effort**: 1 hour
**Status**: [COMPLETED]
**Started**: 2025-12-20
**Completed**: 2025-12-20
**Priority**: Medium
```

**If task gets blocked**:
```markdown
### 63. Add Missing Directory READMEs
**Effort**: 1 hour
**Status**: [BLOCKED]
**Started**: 2025-12-20
**Blocked**: 2025-12-20
**Blocking Reason**: Missing template file; waiting for Task 62 completion
**Priority**: Medium
```

---

### Implementation Plan Phase Lifecycle

**Initial State**:
```markdown
## Phase 1: Setup Infrastructure [NOT STARTED]

Create project directory structure and initialize configuration files.
```

**After phase starts**:
```markdown
## Phase 1: Setup Infrastructure [IN PROGRESS]
(Started: 2025-12-20T10:00:00Z)

Create project directory structure and initialize configuration files.
```

**After phase completes**:
```markdown
## Phase 1: Setup Infrastructure [COMPLETED] ✅
(Started: 2025-12-20T10:00:00Z)
(Completed: 2025-12-20T10:30:00Z)

Create project directory structure and initialize configuration files.
```

**If phase gets blocked**:
```markdown
## Phase 2: Implement Core Logic [BLOCKED]
(Started: 2025-12-20T10:35:00Z)
(Blocked by: Failed Phase 1, Reason: Directory creation permission denied)

Implement the core business logic for the feature.
```

---

## Validation Rules

### Status Marker Validation

1. **Format**: Status markers must be in brackets: `[STATUS]`
2. **Case**: Status markers must be uppercase: `[COMPLETED]` not `[completed]`
3. **Spelling**: Must match exactly: `[COMPLETED]` not `[COMPLETE]`
4. **Whitespace**: No extra whitespace: `[IN PROGRESS]` not `[ IN PROGRESS ]`

### Timestamp Validation

1. **.opencode/specs/TODO.md**: Must be YYYY-MM-DD format
2. **Plans**: Must be ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ)
3. **State files**: Must be YYYY-MM-DD format
4. **Required**: Timestamps required for all status transitions

### Transition Validation

1. **Valid transitions**: Must follow transition diagram
2. **Required fields**: Blocking/abandonment reasons required
3. **Timestamp order**: Started < Completed/Blocked/Abandoned
4. **Immutability**: `[COMPLETED]` tasks should not change

---

## Migration Guide

### Updating Existing Files

**Step 1**: Identify legacy status values
```bash
grep -r "Status: Not Started" .opencode/specs/TODO.md
grep -r "Status: Complete" .opencode/specs/TODO.md
```

**Step 2**: Convert to standard format
```markdown
# Before
**Status**: Not Started

# After
**Status**: [NOT STARTED]
```

**Step 3**: Add missing timestamps
```markdown
# Before
**Status**: [IN PROGRESS]

# After
**Status**: [IN PROGRESS]
**Started**: 2025-12-20
```

**Step 4**: Convert FAILED to BLOCKED or ABANDONED
```markdown
# Before
**Status**: [FAILED]

# After (if retriable)
**Status**: [BLOCKED]
**Blocked**: 2025-12-20
**Blocking Reason**: {specific reason}

# After (if not retriable)
**Status**: [ABANDONED]
**Abandoned**: 2025-12-20
**Abandonment Reason**: {specific reason}
```

---

## Multi-File Status Synchronization

### Overview

Commands that create or update plans (`/plan`, `/research`, `/revise`, `/implement`) must keep status markers synchronized across multiple files:
- .opencode/specs/TODO.md (user-facing task list)
- state.json (global project state)
- Project state.json (project-specific state)
- Plan files (implementation plans)

### Atomic Update Requirement

All status updates across these files must be **atomic** - either all files are updated successfully, or none are updated. This prevents inconsistent states where .opencode/specs/TODO.md shows one status but state.json shows another.

### status-sync-manager Specialist

The `status-sync-manager` specialist provides atomic multi-file updates using a two-phase commit protocol:

**Phase 1 (Prepare)**:
1. Read all target files into memory
2. Validate current status allows requested transition
3. Prepare all updates in memory
4. Validate all updates are well-formed
5. If any validation fails, abort (no files written)

**Phase 2 (Commit)**:
1. Write files in dependency order: .opencode/specs/TODO.md → state.json → project state → plan
2. Verify each write before proceeding
3. On any write failure, rollback all previous writes
4. All files updated or none updated (atomic guarantee)

### Usage in Commands

**`/plan` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp)`
- Postflight: `status-sync-manager.mark_planned(task_number, timestamp, plan_path)`

**`/research` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp)`
- Postflight: `status-sync-manager.mark_researched(task_number, timestamp)`

**`/revise` command**:
- Preflight: Preserve current status (no status change)
- Postflight: Update plan links, preserve status

**`/implement` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp, plan_path)`
- Postflight: `status-sync-manager.mark_completed(task_number, timestamp, plan_path)`

### Rollback Mechanism

If any file write fails during the commit phase:
1. Immediately stop further writes
2. Restore all previously written files from backup
3. Return error with details of which file failed
4. System remains in consistent state (all files match original)

### Error Handling

**File Not Found**: Abort before writing, return error
**Invalid Transition**: Abort before writing, return error
**Write Failure**: Rollback all writes, return error with file details
**Rollback Failure**: Log critical error, manual intervention required

### Backward Compatibility

- `batch-status-manager` remains for .opencode/specs/TODO.md-only updates
- `status-sync-manager` used for multi-file updates
- Commands choose appropriate specialist based on needs
- No breaking changes to existing workflows

---

## Reference Implementation

See these files for reference implementations:

- **.opencode/specs/TODO.md status tracking**: `.opencode/agent/subagents/task-executor.md`
- **Batch status updates**: `.opencode/agent/subagents/specialists/batch-status-manager.md`
- **Plan phase tracking**: `.opencode/agent/subagents/implementation-orchestrator.md`
- **Status transitions**: `.opencode/command/implement.md`

---

## Testing Guidelines

### Unit Tests

Test coverage for status marker functionality:

1. **Status Marker Parsing**
   - Test recognition of all 5 status markers
   - Test backward compatibility with legacy formats
   - Test case sensitivity and whitespace handling

2. **Status Transitions**
   - Test all valid transitions
   - Test rejection of invalid transitions
   - Test timestamp generation

3. **Batch Operations**
   - Test atomic updates with multiple tasks
   - Test partial success scenarios
   - Test error handling

### Integration Tests

End-to-end testing scenarios:

1. **Task Execution Flow**
   - Create task with `[NOT STARTED]`
   - Execute task (marks `[IN PROGRESS]`)
   - Complete task (marks `[COMPLETED]`)

2. **Batch Task Execution**
   - Execute multiple tasks in batch
   - Verify wave-based execution
   - Verify status updates for completed/abandoned/blocked tasks

3. **Plan Implementation**
   - Create plan with phases `[NOT STARTED]`
   - Execute phases (marks `[IN PROGRESS]` → `[COMPLETED]`)
   - Handle phase failures (marks `[ABANDONED]`)
   - Handle blocked phases (marks `[BLOCKED]`)

### Manual Testing

User-facing validation:

1. **.opencode/specs/TODO.md Updates**
   - Run `/implement {number}` and verify status changes
   - Run `/implement {list}` and verify batch status changes
   - Check timestamp formatting

3. **Error Scenarios**
   - Test task failure → `[ABANDONED]`
   - Test dependency blocking → `[BLOCKED]`
   - Test status update failures (graceful degradation)

---

## Version History

- **1.0** (2025-12-20): Initial specification with 5 standard status markers
