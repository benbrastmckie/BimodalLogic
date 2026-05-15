# Research Report: Task #150

**Task**: 150 - Task Order auto-pruning and auto-insertion
**Started**: 2026-05-15T19:00:00Z
**Completed**: 2026-05-15T19:45:00Z
**Effort**: 45 minutes
**Dependencies**: Task #149 (completed) — redesigned Task Order format and created `generate-task-order.sh`
**Sources/Inputs**:
- Codebase exploration
  - `.claude/scripts/update-task-status.sh`
  - `.claude/scripts/generate-task-order.sh`
  - `.claude/scripts/update-recommended-order.sh`
  - `.claude/commands/task.md`
  - `.claude/skills/skill-implementer/SKILL.md`
  - `.claude/skills/skill-lean-implementation/SKILL.md`
  - `.claude/skills/skill-lean-research/SKILL.md`
  - `.claude/context/formats/task-order-format.md`
  - `.claude/rules/state-management.md`
  - `specs/TODO.md` (live state inspection)
  - `specs/state.json` (live state inspection)
  - `specs/149_redesign_task_order_format/plans/01_task-order-redesign.md`
  - `specs/149_redesign_task_order_format/summaries/01_task-order-redesign-summary.md`
  - Git history (task 147 and 149 completion commits)
**Artifacts**:
- `specs/150_task_order_auto_sync/reports/01_task-order-auto-sync.md`
**Standards**: report-format.md, artifact-formats.md

---

## Executive Summary

- The `update-task-status.sh` script already implements auto-pruning for terminal transitions (COMPLETED, ABANDONED, EXPANDED) via Mode B full regeneration using `generate-task-order.sh`. However, this only fires when `update-task-status.sh` is called — and lean4-specific skills bypass it with direct jq/Edit operations, causing drift for lean4 tasks.
- The `/task` command (task.md) Part C still calls `add_to_recommended_order` from the old `update-recommended-order.sh` script, which targets the defunct `## Recommended Order` section. Since TODO.md now uses `## Task Order`, this call silently fails or creates an unwanted section. New tasks are NOT auto-inserted into the Task Order.
- Live drift exists in the current TODO.md: task 147 (status: `completed` in state.json) remains in the Task Order tree as `[COMPLETED]` rather than being pruned, because `skill-lean-implementation` bypasses `update-task-status.sh` and directly edits TODO.md without touching the Task Order section.
- No drift-detection or auto-correction logic currently exists. The `--sync` mode in task.md compares task entries between state.json and TODO.md Tasks section, but does not validate the Task Order section at all.
- The fix for all three issues requires targeted changes to: (1) `task.md` Part C (replace old order call with `generate-task-order.sh`), (2) `skill-lean-implementation` and `skill-lean-research` postflight stages (add Task Order regeneration call after status update), and optionally (3) `task.md --sync` mode (add Task Order drift validation).

---

## Context & Scope

Task 150 builds on task 149, which redesigned the Task Order format from flat category lists to a dependency wave table + indented tree, created `generate-task-order.sh`, and updated `update-task-status.sh` Phase 3 to use two-mode strategy. Task 150 wires auto-sync into the remaining touchpoints: task creation and drift detection.

The scope covers three specific deliverables per the task description:
1. Auto-pruning of completed tasks from Task Order on status completion (partially done; gap is lean4 skill bypass).
2. Auto-insertion of new tasks into Task Order when `/task` creates them.
3. Drift detection and auto-correction between Task Order status markers and state.json.

---

## Findings

### Codebase Patterns

#### `update-task-status.sh` — Current State

The script (`update-task-status.sh`) has four phases:
- **Phase 1**: Update `state.json` status (always runs first)
- **Phase 2**: Update TODO.md task entry `- **Status**: [STATUS]`
- **Phase 3**: Update TODO.md Task Order section — two modes:
  - **Mode A** (non-terminal): In-place `sed` replaces `[OLD_STATUS]` with `[NEW_STATUS]` at the matched tree line (`^\s*(└─ )?{N} \[` pattern)
  - **Mode B** (terminal: COMPLETED, ABANDONED, EXPANDED): Calls `generate-task-order.sh --update-todo` for full section regeneration (auto-prunes the completed task)
- **Phase 4**: Optional plan file update (implement operations only)

Mode B is correctly implemented for auto-pruning. The gap is that not all skills invoke this script.

**Callers of `update-task-status.sh`**:
- `commands/research.md` — postflight: `update-task-status.sh postflight "$task_number" research "$session_id"`
- `commands/plan.md` — postflight: `update-task-status.sh postflight "$task_number" plan "$session_id"`
- `commands/revise.md` — postflight: `update-task-status.sh postflight "$task_number" plan "$session_id"`
- `skills/skill-implementer/SKILL.md` — preflight + postflight: `update-task-status.sh {preflight|postflight} "$task_number" implement "$session_id"`
- `skills/skill-researcher/SKILL.md` — preflight + postflight: `update-task-status.sh {preflight|postflight} "$task_number" research "$session_id"`

**Skills that bypass `update-task-status.sh`** (direct jq + Edit instead):
- `skills/skill-lean-implementation/SKILL.md` — Stage 6 uses direct jq to update state.json and Edit tool to change TODO.md task entry status marker. No Task Order update.
- `skills/skill-lean-research/SKILL.md` — Stage 6 uses direct jq and Edit tool. No Task Order update.

This means lean4 task completions do NOT trigger Task Order regeneration, causing drift.

#### Task Order Tree — Live Drift Detected

Inspecting the current `specs/TODO.md` Task Order tree against `specs/state.json`:

| Task | state.json status | Task Order tree status | Drift? |
|------|------------------|----------------------|--------|
| 147 | `completed` | `[COMPLETED]` (still in tree) | YES — should be pruned |
| 145 | `implementing` | `[IMPLEMENTING]` | No |
| 143 | `partial` | `[PARTIAL]` | No |
| 148 | `researched` | `[RESEARCHED]` | No |
| 150 | `researching` | `[RESEARCHING]` | No |
| 149 | `completed` | Not in tree | No (correctly pruned) |

Task 149 was pruned correctly because it completed via a meta/general skill path (used `update-task-status.sh`). Task 147 (lean4) was not pruned because `skill-lean-implementation` bypasses `update-task-status.sh`.

**Root cause**: Task 147's completion commit (`551113aba`) shows Mode A behavior (in-place `[IMPLEMENTING]` → `[COMPLETED]`) applied to the tree entries, but Mode B (full regeneration removing the completed task) did NOT run because `skill-lean-implementation` uses direct Edit operations, not `update-task-status.sh`.

#### `/task` Command — Part C Auto-Insertion Gap

`task.md` Step 7 Part C attempts to auto-insert the new task into an order section:
```bash
if source "$PROJECT_ROOT/.claude/scripts/update-recommended-order.sh" 2>/dev/null; then
    add_to_recommended_order "$next_num" || echo "Note: Failed to update Recommended Order"
fi
```

The `update-recommended-order.sh` script targets `## Recommended Order`. This section was removed from TODO.md by task 149 (the task-order redesign). The live TODO.md now uses `## Task Order` exclusively. Therefore:
- Part C either silently fails (the `source` or `add_to_recommended_order` call fails with a 2>/dev/null swallowing the error)
- Or it could create a new `## Recommended Order` section (unwanted)

New tasks created after task 149 are NOT appearing in the Task Order tree. This is the auto-insertion gap.

**Evidence**: Tasks 150 and 151 were manually placed in the Task Order tree during task 149's Phase 3 regeneration (the `generate-task-order.sh --update-todo` run at the end of task 149). They would not have been auto-inserted by Part C.

#### `generate-task-order.sh` — Complete Auto-Generation Script

The script (547 lines) implements:
1. **Data extraction**: Reads non-terminal tasks from state.json, preloads descriptions
2. **Graph building**: Associative arrays for task_status, task_deps (active only), task_desc
3. **Kahn's algorithm**: Wave computation (dependency waves)
4. **Wave table generation**: Markdown table with Wave/Tasks/Blocked-by columns
5. **DFS tree generation**: Indented tree with `└─` connectors, visited-set for diamond deps
6. **Section replacement**: Replaces `## Task Order` ... next `##` section in TODO.md

Usage: `generate-task-order.sh --update-todo TODO_FILE STATE_FILE [--goal "text"]`

The script correctly handles the auto-insertion scenario: if called after a new task is added to state.json, it will include the new task in both the wave table and dependency tree with proper dependency positioning.

#### Drift Detection — Not Yet Implemented

No existing drift-detection logic compares Task Order tree statuses against state.json. The `--sync` mode in `task.md` only compares:
- Task numbers in state.json vs `### N.` headings in TODO.md Tasks section
- `next_project_number` values in both files

It does NOT inspect the Task Order section.

---

### Recommendations

#### Change 1: Update `task.md` Part C (auto-insertion)

Replace the old `add_to_recommended_order` call with a `generate-task-order.sh --update-todo` call:

```bash
# Part C - Update Task Order section (non-blocking)
gen_script="$PROJECT_ROOT/.claude/scripts/generate-task-order.sh"
if [[ -x "$gen_script" ]]; then
    "$gen_script" --update-todo "$TODO_FILE" "$STATE_FILE" 2>/dev/null || \
        echo "Note: Failed to regenerate Task Order section (non-fatal)"
fi
```

This is the cleanest approach because:
- Full regeneration is idempotent and always produces a correct result
- The script already handles dependency positioning (Kahn's algorithm)
- Goal line is preserved automatically
- Performance is acceptable (~30ms for 30 tasks)
- No incremental insertion logic needed (avoids edge cases)

**File**: `.claude/commands/task.md` — Step 7 Part C (lines 177-181)

#### Change 2: Add Task Order Regeneration to Lean4 Skill Postflight Stages

After `skill-lean-implementation` and `skill-lean-research` update state.json and TODO.md task entry status, add a call to `generate-task-order.sh --update-todo` (non-blocking, non-fatal):

```bash
# After updating state.json and TODO.md task entry status:
gen_script=".claude/scripts/generate-task-order.sh"
if [[ -x "$gen_script" ]]; then
    "$gen_script" --update-todo specs/TODO.md specs/state.json 2>/dev/null || true
fi
```

This should be added to:
- `skill-lean-implementation` Stage 6 (postflight status update), after the jq and Edit operations
- `skill-lean-research` Stage 6 (postflight status update), after the jq and Edit operations

For completed tasks, `generate-task-order.sh` will exclude them (auto-prune). For non-terminal transitions, it will update the status in the tree. This is more robust than trying to replicate Mode A/Mode B logic in each skill.

**Files**: `.claude/skills/skill-lean-implementation/SKILL.md`, `.claude/skills/skill-lean-research/SKILL.md`

#### Change 3: Drift Detection in `--sync` Mode

Add Task Order drift detection to `task.md --sync` mode as an additional step after the existing state.json/TODO.md Tasks section comparison:

```bash
# After existing task entry sync:
# Step 6: Validate Task Order section
echo "Checking Task Order drift..."

# Get active task IDs from state.json
active_tasks=$(jq -r '[.active_projects[] | select(.status == "completed" | not) | select(.status == "abandoned" | not) | select(.status == "expanded" | not) | .project_number] | sort | .[]' specs/state.json)

# Get task IDs in Task Order tree from TODO.md
tree_tasks=$(grep -E "^\s*(└─ )?[0-9]+ \[" specs/TODO.md | grep -oE "^[\s└─ ]*([0-9]+)" | grep -oE "[0-9]+$" | sort -u)

# Tasks in tree but completed in state.json = drift
# If any drift detected, regenerate Task Order
if drift_detected; then
    .claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json
    echo "Task Order regenerated to fix drift"
fi
```

The simplest implementation: always regenerate Task Order as part of `--sync`. Since `generate-task-order.sh` is idempotent and preserves the Goal line, this is safe.

**Alternative approach**: Add a standalone `validate-task-order.sh` script that:
1. Extracts task IDs from the tree
2. Compares against state.json non-terminal tasks
3. Reports drift (task in tree but completed, status mismatch, task missing from tree)
4. Optionally auto-corrects via `generate-task-order.sh --update-todo`

#### Change 4 (Optional): Add Mode A Fallback in `update-task-status.sh`

When Mode A cannot find the task in the tree (line 267: "Warning: task N not found in TODO.md Task Order tree"), instead of silently returning, fall back to Mode B full regeneration:

```bash
if [[ -z "$order_line" ]]; then
    # Task not in tree — fall back to full regeneration
    local gen_script="$SCRIPT_DIR/generate-task-order.sh"
    if [[ -x "$gen_script" ]]; then
        "$gen_script" --update-todo "$TODO_FILE" "$STATE_FILE" || \
            echo "Warning: generate-task-order.sh failed (non-fatal)" >&2
    else
        echo "Warning: task $task_number not found in Task Order tree (generate-task-order.sh unavailable)" >&2
    fi
    return 0
fi
```

This auto-corrects drift for newly added tasks that haven't appeared in the tree yet.

---

## Decisions

- **Full regeneration over incremental insertion for Part C**: `generate-task-order.sh --update-todo` is the correct approach for Part C. The incremental `add_to_recommended_order` logic from `update-recommended-order.sh` is brittle and targets the wrong section. Full regeneration is already fast enough (~30ms for current task count).
- **Add lean4 skill Task Order update**: The lean4-specific skills should call `generate-task-order.sh` after their status updates, not `update-task-status.sh`. The central script is designed for general skills; the lean skills have their own postflight architecture.
- **Drift detection via regeneration**: The simplest and most reliable drift correction is always calling `generate-task-order.sh --update-todo` in the `--sync` operation. Sophisticated drift diffing adds complexity without practical benefit.
- **update-task-status.sh Mode B is correct as-is**: The terminal transition regeneration logic in Phase 3 is properly implemented. The issue is not in this script but in which skills call it.

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `generate-task-order.sh` called while state.json write incomplete | M | L | State.json is written atomically (mv from tmp); call is always after state.json update |
| Full regeneration in Part C too slow for large task counts | L | L | Script tested at ~30ms for 30 tasks; non-blocking call pattern |
| Goal line overwritten during Part C regeneration | M | L | Script reads and preserves existing Goal line automatically |
| Lean4 skill Task Order call fails (script not found/not executable) | L | L | Use `|| true` or non-fatal warning pattern; Task Order is best-effort |
| Circular dependency warning in `generate-task-order.sh` triggers noise in lean skill postflight | L | L | `2>/dev/null` suppresses stderr; or capture and check return code |

---

## Context Extension Recommendations

- **Topic**: Task Order integration patterns across skills
- **Gap**: `task-order-format.md` documents the format and `update-task-status.sh` integration, but does not document which skills call `generate-task-order.sh` directly vs. through `update-task-status.sh`. This causes maintenance drift when new skills are added.
- **Recommendation**: Add a "Skill Integration" section to `task-order-format.md` (or a new `task-order-integration.md`) documenting which skills are responsible for Task Order updates and the expected call pattern.

---

## Appendix

### Files to Modify

| File | Change | Priority |
|------|--------|----------|
| `.claude/commands/task.md` | Replace Part C `add_to_recommended_order` with `generate-task-order.sh --update-todo` call | High |
| `.claude/skills/skill-lean-implementation/SKILL.md` | Add `generate-task-order.sh --update-todo` call in Stage 6 postflight | High |
| `.claude/skills/skill-lean-research/SKILL.md` | Add `generate-task-order.sh --update-todo` call in Stage 6 postflight | High |
| `.claude/commands/task.md` | Add Task Order drift validation to `--sync` mode | Medium |
| `.claude/scripts/update-task-status.sh` | Add fallback to Mode B when task not found in tree (Mode A miss) | Low |

### Current Drift (Live)

Task 147 (`completed` in state.json) remains in the Task Order tree as `[COMPLETED]` — should be pruned. This will be corrected by the implementation of this task (running `generate-task-order.sh --update-todo` as part of the fix).

### Key Script Signatures

```bash
# Auto-insertion (Part C replacement):
.claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json

# Drift detection/correction (--sync addition):
.claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json

# Validate drift (read-only, for reporting):
.claude/scripts/generate-task-order.sh --print  # compare output vs TODO.md
```

### References

- `.claude/scripts/update-task-status.sh` — Phase 3 two-mode Task Order update
- `.claude/scripts/generate-task-order.sh` — Full Task Order regeneration script
- `.claude/scripts/update-recommended-order.sh` — Old Recommended Order script (superseded)
- `.claude/commands/task.md` — `/task` command with Part C gap
- `.claude/context/formats/task-order-format.md` — Format spec and integration documentation
- `specs/149_redesign_task_order_format/plans/01_task-order-redesign.md` — Task 149 plan (context)
- `specs/149_redesign_task_order_format/summaries/01_task-order-redesign-summary.md` — Task 149 summary (context)
