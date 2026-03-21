# Research Report: Task #601 (Follow-up)

- **Task**: 601 - Design Task Review Logic and Validation Rules
- **Started**: 2026-01-19T06:53:37Z
- **Completed**: 2026-01-19T07:15:00Z
- **Effort**: 30 minutes
- **Priority**: High
- **Dependencies**: None
- **Sources/Inputs**:
  - `.claude/commands/task.md` - Current /task command implementation
  - `.claude/skills/skill-status-sync/SKILL.md` - Atomic status synchronization
  - `.claude/context/core/orchestration/validation.md` - Validation patterns
  - `.claude/context/core/standards/task-management.md` - Task standards including --sync
  - `.claude/rules/state-management.md` - Two-phase update patterns
  - `specs/601_design_task_review_logic_validation/reports/research-001.md` - Initial validation rules design
- **Artifacts**: specs/601_design_task_review_logic_validation/reports/research-002.md
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- Current `--sync` implementation in task.md (lines 197-223) provides basic bidirectional sync using grep parsing and git blame conflict resolution
- `--sync` supports optional task ranges but defaults to syncing ALL tasks when no ranges provided
- Design recommendation: `--review` should be a **superset** that includes all `--sync` functionality plus comprehensive validation
- Migration path: `--sync` becomes an alias for `--review --sync-only` (sync without validation), eventually deprecated
- Key architectural insight: `--sync` focuses on **reconciliation**, while `--review` adds **verification** and **reporting**

## Context & Scope

This follow-up research specifically addresses:
1. What does the current `--sync` implementation do?
2. What functionality must `--review` preserve from `--sync`?
3. How should `--review` be designed as a superset of `--sync`?
4. What is the deprecation/migration path for `--sync`?

## Findings

### 1. Current --sync Implementation Analysis

**Location**: `.claude/commands/task.md` lines 197-223

**Current Behavior**:

```markdown
## Sync Mode (--sync)

1. **Read state.json task list via jq**:
   state_tasks=$(jq -r '.active_projects[].project_number' specs/state.json | sort -n)
   state_next=$(jq -r '.next_project_number' specs/state.json)

2. **Read TODO.md task list via grep**:
   todo_tasks=$(grep -o "^### [0-9]\+\." specs/TODO.md | sed 's/[^0-9]//g' | sort -n)
   todo_next=$(grep "^next_project_number:" specs/TODO.md | awk '{print $2}')

3. **Compare entries for consistency**:
   - Tasks in state.json but not TODO.md → Add to TODO.md
   - Tasks in TODO.md but not state.json → Add to state.json or mark as orphaned
   - next_project_number mismatch → Use higher value

4. **Use git blame to determine "latest wins"** for conflicting data

5. **Sync discrepancies**:
   - Use jq to update state.json
   - Use Edit to update TODO.md
   - Ensure next_project_number matches in both files

6. Git commit: "sync: reconcile TODO.md and state.json"
```

**Functionality Summary**:

| Feature | Current --sync |
|---------|----------------|
| Task existence check | Yes (bidirectional) |
| next_project_number sync | Yes |
| Status field sync | Yes (via git blame) |
| Git blame conflict resolution | Yes |
| Range support | Yes (default: all tasks) |
| Git commit | Yes |
| Validation/verification | **No** |
| Artifact validation | **No** |
| Completion verification | **No** |
| User confirmation | **No** (automatic) |
| Dry-run mode | **No** |

### 2. Standards from task-management.md

**Location**: `.claude/context/core/standards/task-management.md` lines 171-196

The task management standard documents `--sync` behavior:

```markdown
### Task Synchronization (--sync)

**Standards**:
- Default behavior: sync ALL tasks when no ranges specified
- Supports range/list syntax for selective sync
- Git blame conflict resolution: latest commit wins
- For each field that differs:
  1. Run git blame on TODO.md and state.json
  2. Extract commit timestamps
  3. Use value from file with latest commit
  4. Log conflict resolution details
- Atomic operation: both files updated or neither
- Updates TODO.md and state.json only

**Git Blame Conflict Resolution**:
- Compare timestamps for each differing field
- Latest commit wins (most recent change)
- Tie-breaker: state.json wins (source of truth)
- Log format: "Task 343: status from state.json (2026-01-07) > TODO.md (2026-01-06)"
```

### 3. Key Differences: --sync vs --review

| Aspect | --sync (Current) | --review (Proposed) |
|--------|------------------|---------------------|
| **Primary Purpose** | Reconcile discrepancies | Validate + reconcile + verify |
| **Sync Functionality** | Full | Full (inherited) |
| **Existence Checks** | Task presence | Task presence + artifact existence |
| **Field Validation** | Basic (git blame) | Comprehensive (all field types) |
| **Artifact Validation** | None | File existence, non-empty, format |
| **Completion Verification** | None | Plan phase status, summary checks |
| **Output Mode** | Automatic fixes | Report issues, prompt for fixes |
| **Dry-run Support** | No | Yes (--dry-run flag) |
| **Fix Modes** | Automatic | Interactive / --fix / --dry-run |
| **Follow-up Tasks** | No | Yes (for incomplete work) |
| **Severity Levels** | None | ERROR/WARN/INFO |
| **Git Commit** | Yes (always) | Yes (only if changes made) |

### 4. --review as Superset Design

**Architecture**:

```
/task --review [RANGES] [--fix | --dry-run | --sync-only]

Execution Flow:
┌─────────────────────────────────────────────────────────────┐
│  STAGE 1: Parse & Load                                      │
│  - Parse ranges (default: all tasks)                        │
│  - Load state.json and TODO.md into memory                  │
│  - Build task maps for both sources                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 2: Sync Validation (inherited from --sync)           │
│  - Task existence check (bidirectional)                     │
│  - next_project_number consistency                          │
│  - Field value comparison with git blame                    │
│  - Status mapping validation                                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 3: Artifact Validation (NEW in --review)             │
│  - Verify artifact paths exist                              │
│  - Verify artifacts are non-empty                           │
│  - Cross-reference TODO.md links with state.json            │
│  - Validate artifact naming conventions                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 4: Completion Verification (NEW in --review)         │
│  - For COMPLETED tasks: verify all plan phases complete     │
│  - Verify summary artifact exists and has required sections │
│  - Detect phantom completions                               │
│  - Generate incomplete work reports                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 5: Issue Reporting                                   │
│  - Aggregate issues by severity (ERROR/WARN/INFO)           │
│  - Group issues by task                                     │
│  - Display report to user                                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 6: Fix Application (based on mode flag)              │
│  - --dry-run: Report only, no changes                       │
│  - --fix: Auto-fix all, prompt for ambiguous                │
│  - (default): Interactive mode, prompt for each             │
│  - --sync-only: Apply sync fixes only, skip validation      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 7: Git Commit (if changes made)                      │
│  - "task: review and fix {N} issues"                        │
│  - Include session_id                                       │
└─────────────────────────────────────────────────────────────┘
```

**Mode Flags**:

| Flag | Behavior | Use Case |
|------|----------|----------|
| (none) | Interactive: report all, prompt for each fix | Normal review |
| `--fix` | Auto-fix obvious issues, prompt for ambiguous | Quick cleanup |
| `--dry-run` | Report only, no changes | Audit/preview |
| `--sync-only` | Sync only, skip validation (= old --sync) | Backwards compat |

### 5. Migration Path for --sync

**Recommended Approach**: Alias then Deprecate

**Phase 1: Alias (Immediate)**
- `--sync` becomes alias for `--review --sync-only`
- Emit deprecation warning: "Warning: --sync is deprecated. Use --review or --review --sync-only"
- Full functionality preserved

**Phase 2: Deprecation Warning (1 month)**
- Warning becomes more prominent
- Documentation updated to recommend --review
- --sync still functional

**Phase 3: Removal (3 months)**
- Remove --sync flag
- Error message: "--sync has been removed. Use --review instead."

**Implementation in task.md**:

```markdown
## Mode Detection (Updated)

Check $ARGUMENTS for flags:
- `--recover RANGES` → Recover tasks from archive
- `--expand N [prompt]` → Expand task into subtasks
- `--review [RANGES] [--fix|--dry-run|--sync-only]` → Review and validate tasks
- `--sync` → **DEPRECATED**: Alias for `--review --sync-only` (emit warning)
- `--abandon RANGES` → Archive tasks
- No flag → Create new task with description
```

### 6. Backwards Compatibility

**What --sync Users Expect**:
1. Automatic bidirectional sync
2. Git blame conflict resolution
3. No prompts (automatic fixing)
4. Git commit on completion

**How --review --sync-only Preserves This**:
1. Stage 2 (Sync Validation) runs exactly as before
2. Git blame resolution unchanged
3. `--sync-only` flag skips interactive prompts
4. Git commit pattern unchanged

**What Changes for --sync Users**:
- Deprecation warning (non-blocking)
- Flag name change (eventual)

### 7. Integration with skill-status-sync

`skill-status-sync` provides atomic status updates but is designed for **standalone use only** (not workflow commands).

**Recommendation**: `--review` should NOT use skill-status-sync because:
1. --review is a direct command mode, not a skill invocation
2. --review needs to batch multiple updates atomically
3. --review uses two-phase update pattern directly

**--review uses same patterns as skill-status-sync**:
- jq for state.json updates
- Edit tool for TODO.md updates
- Two-phase commit (prepare then write)
- Atomic operation guarantees

## Decisions

1. **--review is superset of --sync**: All sync functionality included plus validation/verification
2. **--sync becomes alias**: `--sync` = `--review --sync-only` with deprecation warning
3. **Four fix modes**: Interactive (default), --fix (auto), --dry-run (report only), --sync-only (sync only)
4. **Stages are sequential**: Must complete sync before validation, validation before verification
5. **Direct implementation**: --review is implemented in task.md, not via skill delegation

## Recommendations

1. **Implement --review with --sync-only first**: Ensures backwards compatibility from day one

2. **Add deprecation warning to --sync immediately**: Gives users time to transition

3. **Preserve git blame resolution**: The conflict resolution logic from --sync is valuable and should be retained

4. **Make --dry-run the default for first release**: Safer rollout, users can opt into fixes with --fix

5. **Follow validation severity from research-001.md**: ERROR blocks completion, WARN should fix, INFO awareness only

6. **Create separate tasks for each stage**:
   - Task 602: Implement --review mode with --sync-only (preserve --sync behavior)
   - Task 603: Add artifact and completion validation stages
   - Future: Add follow-up task generation

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking --sync users | High | Use alias + deprecation warning |
| Performance on large task sets | Medium | Add progress indicator, batch operations |
| Git blame slow on large repos | Medium | Cache blame results per session |
| Interactive mode confusing | Low | Clear prompts, --fix for automation |

## Appendix

### Search Queries Used
- `Grep "--sync"` in .claude/ directory
- `Grep "sync"` in .claude/ directory for context
- `Read` task.md, skill-status-sync, validation.md, task-management.md

### References
- `.claude/commands/task.md` lines 197-223 (--sync implementation)
- `.claude/context/core/standards/task-management.md` lines 171-196 (--sync standards)
- `.claude/skills/skill-status-sync/SKILL.md` (atomic update patterns)
- `.claude/context/core/orchestration/validation.md` (validation philosophy)
- `specs/601_design_task_review_logic_validation/reports/research-001.md` (validation rules design)

### Next Steps

1. Update task 602 description to include --sync-only preservation
2. Run `/plan 601` to create implementation plan incorporating both research reports
3. Consider adding a task for deprecation timeline documentation
