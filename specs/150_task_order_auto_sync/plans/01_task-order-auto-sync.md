# Implementation Plan: Task Order Auto-Sync

- **Task**: 150 - Add automatic Task Order synchronization
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: Task 149 (completed -- created `generate-task-order.sh`)
- **Research Inputs**: specs/150_task_order_auto_sync/reports/01_task-order-auto-sync.md
- **Artifacts**: plans/01_task-order-auto-sync.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Three gaps prevent the Task Order section in TODO.md from staying synchronized with state.json: (1) the `/task` command's Part C still calls `add_to_recommended_order` from the defunct `update-recommended-order.sh` script targeting the removed `## Recommended Order` section, (2) lean4-specific skills bypass `update-task-status.sh` and perform direct jq/Edit operations without regenerating the Task Order, and (3) the `--sync` mode does not validate or correct the Task Order section. This plan addresses all three gaps by wiring `generate-task-order.sh --update-todo` into each touchpoint and adding drift correction to `--sync`. Definition of done: newly created tasks appear in the Task Order, lean4 task completions prune the Task Order, and `--sync` detects and corrects Task Order drift.

### Research Integration

The research report (01_task-order-auto-sync.md) identified the three gaps, confirmed live drift (task 147 remains in Task Order despite being completed), mapped all callers and non-callers of `update-task-status.sh`, and recommended full regeneration via `generate-task-order.sh` as the idempotent fix for all touchpoints. The recommendations are adopted directly into this plan.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items are directly advanced by this task. This is a meta/infrastructure improvement to the agent orchestration system.

## Goals & Non-Goals

**Goals**:
- Replace defunct `add_to_recommended_order` call in `/task` Part C with `generate-task-order.sh --update-todo`
- Add Task Order regeneration to lean4 skill postflight stages (both implementation and research)
- Add Task Order drift detection and auto-correction to `--sync` mode
- Add Mode A fallback to Mode B in `update-task-status.sh` when task not found in tree
- Correct the existing drift (task 147 still in Task Order tree)

**Non-Goals**:
- Creating a standalone `validate-task-order.sh` script (full regeneration is sufficient for drift correction)
- Modifying `generate-task-order.sh` itself (it works correctly as-is)
- Adding Task Order regeneration to every skill (only lean4 skills bypass `update-task-status.sh`)
- Removing `update-recommended-order.sh` (can be cleaned up in a future task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `generate-task-order.sh` called while state.json write incomplete | M | L | State.json writes use atomic mv-from-tmp pattern; regeneration call always follows the write |
| Goal line overwritten during Part C regeneration | M | L | `generate-task-order.sh` reads and preserves the existing Goal line automatically |
| Lean4 skill postflight call fails (script not found) | L | L | Non-fatal pattern with `\|\| true`; Task Order is best-effort |
| `--sync` regeneration masks deeper consistency issues | L | L | Regeneration is idempotent and always produces correct output from state.json truth |
| Mode A fallback to Mode B adds unexpected latency | L | L | `generate-task-order.sh` runs in ~30ms for current task count |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Fix `/task` Part C auto-insertion [NOT STARTED]

**Goal**: Replace the defunct `add_to_recommended_order` call with `generate-task-order.sh --update-todo` so newly created tasks appear in the Task Order.

**Tasks**:
- [ ] Edit `.claude/commands/task.md` Step 7 Part C (lines 177-183) to replace the old code block
- [ ] Replace `source "$PROJECT_ROOT/.claude/scripts/update-recommended-order.sh"` and `add_to_recommended_order` with a direct call to `generate-task-order.sh --update-todo`
- [ ] Update the comment from "Update Recommended Order section" to "Update Task Order section"
- [ ] Use non-blocking pattern: `"$gen_script" --update-todo "$TODO_FILE" "$STATE_FILE" 2>/dev/null || echo "Note: Failed to regenerate Task Order section (non-fatal)"`
- [ ] Verify the variable names (`$TODO_FILE`, `$STATE_FILE`) match the surrounding context in task.md (they use `specs/TODO.md` and `specs/state.json` directly)

**Timing**: 20 minutes

**Depends on**: none

**Files to modify**:
- `.claude/commands/task.md` -- Replace Part C code block (lines 177-183)

**Verification**:
- Part C references `generate-task-order.sh` instead of `update-recommended-order.sh`
- The call pattern is non-blocking (failure does not abort task creation)

---

### Phase 2: Add Task Order regeneration to lean4 skill postflight [NOT STARTED]

**Goal**: Ensure lean4 task status transitions (both implementation and research) trigger Task Order regeneration, closing the drift gap for lean4 tasks.

**Tasks**:
- [ ] Edit `.claude/skills/skill-lean-implementation/SKILL.md` Stage 6 to add a Task Order regeneration call after the state.json and TODO.md status updates
- [ ] Add the call between Stage 6 (status update) and Stage 7 (artifact linking), using pattern: `.claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json 2>/dev/null || true`
- [ ] Edit `.claude/skills/skill-lean-research/SKILL.md` Stage 6 to add the same Task Order regeneration call after the state.json and TODO.md status updates
- [ ] Add the call between Stage 6 (status update) and Stage 7 (artifact linking), using the same pattern
- [ ] Also add the regeneration call to the preflight stages (Stage 2) of both skills, since preflight transitions (e.g., `[PLANNED]` to `[IMPLEMENTING]`) also need Task Order updates

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` -- Add regeneration call in Stage 2 (preflight) and Stage 6 (postflight)
- `.claude/skills/skill-lean-research/SKILL.md` -- Add regeneration call in Stage 2 (preflight) and Stage 6 (postflight)

**Verification**:
- Both skill files contain `generate-task-order.sh --update-todo` calls in their postflight stages
- Both skill files contain `generate-task-order.sh --update-todo` calls in their preflight stages
- Calls use non-fatal pattern (`|| true` or `2>/dev/null || true`)

---

### Phase 3: Add Task Order drift correction to `--sync` and Mode A fallback [NOT STARTED]

**Goal**: Add Task Order regeneration to `--sync` mode for drift correction, and add a Mode A fallback to Mode B in `update-task-status.sh` when a task is not found in the tree.

**Tasks**:
- [ ] Edit `.claude/commands/task.md` Sync Mode section to add a new step after step 5 (sync discrepancies): "Step 6: Regenerate Task Order section"
- [ ] Add `generate-task-order.sh --update-todo specs/TODO.md specs/state.json` call with non-fatal error handling
- [ ] Add a comment explaining this corrects drift between Task Order tree statuses and state.json
- [ ] Edit `.claude/scripts/update-task-status.sh` Mode A section (around line 266-268) to add fallback: when `order_line` is empty, call `generate-task-order.sh --update-todo` instead of just printing a warning
- [ ] Ensure the fallback is non-fatal and returns 0

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/commands/task.md` -- Add Task Order regeneration step to Sync Mode
- `.claude/scripts/update-task-status.sh` -- Add Mode B fallback when Mode A cannot find task in tree (around line 266)

**Verification**:
- `--sync` mode description includes Task Order regeneration step
- `update-task-status.sh` Mode A has a fallback to `generate-task-order.sh` when task not in tree
- Both use non-fatal error handling

---

### Phase 4: Validate and correct existing drift [NOT STARTED]

**Goal**: Run `generate-task-order.sh --update-todo` to correct the current drift (task 147 in Task Order despite being completed) and verify all changes work together.

**Tasks**:
- [ ] Run `generate-task-order.sh --update-todo specs/TODO.md specs/state.json` to fix the live drift
- [ ] Verify task 147 is no longer in the Task Order tree
- [ ] Verify all non-terminal tasks appear in the Task Order tree with correct status markers
- [ ] Review the modified files (task.md, both lean skill files, update-task-status.sh) for consistency
- [ ] Verify no references to `update-recommended-order.sh` remain in the modified files (the old script itself can stay for now)

**Timing**: 20 minutes

**Depends on**: 1, 2, 3

**Files to modify**:
- `specs/TODO.md` -- Task Order section regenerated (automated by script)

**Verification**:
- Task 147 (completed) is not in the Task Order tree
- All active tasks appear with correct status markers
- No references to `add_to_recommended_order` or `update-recommended-order.sh` in modified files
- `grep -r "add_to_recommended_order\|update-recommended-order" .claude/commands/task.md .claude/skills/skill-lean-implementation/SKILL.md .claude/skills/skill-lean-research/SKILL.md` returns no matches

## Testing & Validation

- [ ] `grep -q "generate-task-order.sh" .claude/commands/task.md` confirms Part C uses new script
- [ ] `grep -q "generate-task-order.sh" .claude/skills/skill-lean-implementation/SKILL.md` confirms lean implementation skill has regeneration call
- [ ] `grep -q "generate-task-order.sh" .claude/skills/skill-lean-research/SKILL.md` confirms lean research skill has regeneration call
- [ ] `grep -c "generate-task-order.sh" .claude/scripts/update-task-status.sh` returns at least 2 (existing Mode B + new fallback)
- [ ] `.claude/scripts/generate-task-order.sh --update-todo specs/TODO.md specs/state.json` runs without error
- [ ] Task 147 does not appear in the Task Order tree after regeneration
- [ ] All non-terminal active tasks appear in the Task Order tree

## Artifacts & Outputs

- `specs/150_task_order_auto_sync/plans/01_task-order-auto-sync.md` (this plan)
- `specs/150_task_order_auto_sync/summaries/01_task-order-auto-sync-summary.md` (implementation summary)
- Modified files:
  - `.claude/commands/task.md` (Part C replacement + sync mode addition)
  - `.claude/skills/skill-lean-implementation/SKILL.md` (postflight Task Order regeneration)
  - `.claude/skills/skill-lean-research/SKILL.md` (postflight Task Order regeneration)
  - `.claude/scripts/update-task-status.sh` (Mode A fallback to Mode B)
  - `specs/TODO.md` (Task Order drift corrected)

## Rollback/Contingency

All changes are to `.claude/` configuration files and `specs/TODO.md`. If the changes cause issues:
1. Revert the task.md Part C change to restore the old (non-functional) `add_to_recommended_order` call -- functionally equivalent since it was already silently failing
2. Remove `generate-task-order.sh` calls from lean4 skill files -- reverts to the previous (drifting) behavior
3. Remove the sync mode Task Order step -- reverts to sync without Task Order validation
4. Remove the Mode A fallback in `update-task-status.sh` -- reverts to warning-only behavior
5. Git revert of the implementation commit restores all files atomically
