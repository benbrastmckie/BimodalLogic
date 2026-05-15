# Implementation Plan: Redesign Task Order Format

- **Task**: 149 - Redesign Task Order format and generation script
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/149_redesign_task_order_format/reports/01_format-redesign-research.md
- **Artifacts**: plans/01_task-order-redesign.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Replace the flat category-based Task Order section in TODO.md with a dependency-driven format consisting of a wave table (parallel execution groups from Kahn's algorithm) and an indented dependency tree (per-task relationship display). Create `generate-task-order.sh` to auto-generate the Task Order section from state.json, fix the broken Phase 3 of `update-task-status.sh` to match the new format, and regenerate the live TODO.md section.

### Research Integration

The research report (01_format-redesign-research.md) established:
- Phase 3 of `update-task-status.sh` is silently broken: its grep pattern `^- \*\*{N}\*\* \[` targets unordered bullets but the live TODO.md uses numbered list entries, making every status update a no-op.
- `update-recommended-order.sh` contains a complete Kahn's algorithm implementation (~709 lines) with `topological_sort()`, `get_dependents()`, and section-replacement machinery that can be adapted.
- The new format uses two complementary views: a wave table (matching plan-format.md Dependency Analysis pattern) and an indented dependency tree where deeper indentation means "must complete first."
- A two-mode Phase 3 strategy: in-place sed for non-terminal status changes (fast), full regeneration for completed/abandoned transitions (auto-prunes).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task is a meta/infrastructure task that does not directly advance ROADMAP.md items. It improves the tooling that tracks task execution order.

## Goals & Non-Goals

**Goals**:
- Define the new wave+tree Task Order format in `task-order-format.md`
- Create `generate-task-order.sh` that auto-generates the Task Order section from state.json
- Fix `update-task-status.sh` Phase 3 to correctly update statuses in the new format
- Regenerate the live `specs/TODO.md` Task Order section with the new format

**Non-Goals**:
- Wiring `generate-task-order.sh` into `/task` creation (that is task 150 scope)
- Wiring into `/todo` postflight or `/review` (that is task 151 scope)
- Removing or modifying `update-recommended-order.sh` (it may still be used elsewhere)
- Implementing a backlog filtering/collapsing feature (can be added later)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Diamond dependencies (multi-parent tasks) duplicate in tree | M | M | Add `(also blocks N)` annotation or deduplicate with visited-set |
| Circular dependencies in state.json cause infinite loop | H | L | Kahn's algorithm naturally detects cycles; emit warning and skip |
| Tree too long with 30+ tasks | M | H | Show all tasks initially; backlog collapsing is a future enhancement |
| Goal line gets overwritten on regeneration | M | M | Script reads and preserves existing Goal line from TODO.md |
| New format breaks other scripts that parse Task Order | M | L | Section header `## Task Order` is preserved; only internal format changes |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Write New Format Spec and Create Generation Script [NOT STARTED]

**Goal**: Define the new wave+tree format in `task-order-format.md` and create the `generate-task-order.sh` script that generates the Task Order section from state.json.

**Tasks**:
- [ ] Rewrite `.claude/context/formats/task-order-format.md` with the new wave table + dependency tree format spec, preserving the section header sentinel (`## Task Order`) and timestamp/goal patterns
- [ ] Include parsing patterns table for the new format elements (wave table rows, tree entries with indent levels, tree connector `└─`)
- [ ] Include generation template showing the complete section structure
- [ ] Create `.claude/scripts/generate-task-order.sh` implementing: (a) extract non-terminal tasks from state.json, (b) clean dependencies (remove terminal deps), (c) Kahn's algorithm to compute waves, (d) build wave table, (e) build indented dependency tree via DFS from roots, (f) section replacement in TODO.md
- [ ] Support CLI flags: `--print` (stdout only), `--update-todo FILE STATE` (replace section in file), `--goal "text"` (override goal line)
- [ ] Adapt `topological_sort()` logic from `update-recommended-order.sh` for wave computation (assign wave numbers instead of just ordering)
- [ ] Handle diamond dependencies in tree: use a visited set and add `(also blocks N)` annotation on revisited nodes
- [ ] Handle the Goal line preservation: read existing Goal from TODO.md on `--update-todo`; only override if `--goal` flag is passed
- [ ] Make script executable with proper shebang and error handling

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/context/formats/task-order-format.md` -- full rewrite with new wave+tree format spec
- `.claude/scripts/generate-task-order.sh` -- new file, ~250-300 lines bash

**Verification**:
- `generate-task-order.sh --print` produces valid wave table + dependency tree output from current state.json
- The format spec document includes all parsing patterns for the new elements
- Script handles edge cases: tasks with no dependencies (roots), tasks with all deps completed, circular dependency warning

---

### Phase 2: Fix update-task-status.sh Phase 3 [NOT STARTED]

**Goal**: Update the `update_todo_task_order()` function to correctly match and update status markers in the new tree format, and add full regeneration mode for terminal status transitions.

**Tasks**:
- [ ] Change the grep pattern from `^- \*\*${task_number}\*\* \[` to `^\s*(└─ )?${task_number} \[` to match the new tree format lines
- [ ] Add two-mode logic: in-place sed for non-terminal transitions (RESEARCHING, RESEARCHED, PLANNING, PLANNED, IMPLEMENTING), full regeneration via `generate-task-order.sh --update-todo` for terminal transitions (COMPLETED, ABANDONED)
- [ ] Test in-place mode with `--dry-run` on a sample tree line like `148 [RESEARCHED] — description`
- [ ] Test in-place mode on indented tree lines like `  └─ 147 [RESEARCHED] — description`
- [ ] Test regeneration mode triggers correctly when status is COMPLETED or ABANDONED

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `.claude/scripts/update-task-status.sh` -- rewrite `update_todo_task_order()` function (lines 232-265)

**Verification**:
- `update-task-status.sh postflight 147 research sess_test --dry-run` correctly identifies the tree line and reports the status change
- `update-task-status.sh postflight 147 implement sess_test --dry-run` reports regeneration mode would be triggered
- The grep pattern matches both root-level and indented tree entries

---

### Phase 3: Regenerate Live TODO.md and Verify [NOT STARTED]

**Goal**: Run `generate-task-order.sh` against the live state.json to replace the current Task Order section in TODO.md with the new wave+tree format, then verify correctness.

**Tasks**:
- [ ] Run `generate-task-order.sh --print` and review the output against manually computed waves from the research report
- [ ] Preserve the existing Goal line from the current Task Order section
- [ ] Run `generate-task-order.sh --update-todo specs/TODO.md specs/state.json` to replace the Task Order section
- [ ] Verify the output: all non-terminal tasks from state.json appear in the wave table, dependency tree shows correct parent-child relationships, status markers match state.json values
- [ ] Verify `update-task-status.sh postflight 148 research sess_test --dry-run` correctly matches a tree line in the new format
- [ ] Remove or clean up the duplicate `## Recommended Order` headers at the bottom of TODO.md (lines ~522-527) if they still exist
- [ ] Run a final `--dry-run` status update to confirm Phase 3 of update-task-status.sh works end-to-end with the new format

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Files to modify**:
- `specs/TODO.md` -- Task Order section replaced (lines ~28-91) with new wave+tree format

**Verification**:
- The `## Task Order` section in TODO.md contains a wave table and dependency tree
- All active (non-terminal) tasks from state.json appear in both the wave table and the dependency tree
- Task statuses in the tree match the statuses in state.json
- `update-task-status.sh --dry-run` reports correct matches on the new format
- No duplicate `## Recommended Order` sections remain

## Testing & Validation

- [ ] `generate-task-order.sh --print` produces well-formed markdown output (wave table + tree)
- [ ] Wave assignments are correct: all wave-1 tasks have no active dependencies, wave-2 tasks depend only on wave-1 tasks, etc.
- [ ] Dependency tree roots have no active dependencies (all deps are terminal or absent)
- [ ] Tree indentation is consistent: each level adds 2 spaces + `└─` prefix
- [ ] Diamond dependencies are handled without infinite recursion
- [ ] `update-task-status.sh --dry-run` correctly matches tree lines for both root and indented entries
- [ ] Terminal status transitions (COMPLETED, ABANDONED) trigger full regeneration
- [ ] The `## Task Order` sentinel header is preserved for downstream parsers
- [ ] Goal line is preserved across regenerations

## Artifacts & Outputs

- `.claude/context/formats/task-order-format.md` -- rewritten format spec
- `.claude/scripts/generate-task-order.sh` -- new generation script
- `.claude/scripts/update-task-status.sh` -- fixed Phase 3 function
- `specs/TODO.md` -- Task Order section regenerated in new format
- `specs/149_redesign_task_order_format/plans/01_task-order-redesign.md` -- this plan

## Rollback/Contingency

If the new format causes issues with downstream tooling:
1. Revert `task-order-format.md` to the previous version from git history
2. Revert `update-task-status.sh` Phase 3 changes
3. Manually restore the TODO.md Task Order section from git history
4. The `generate-task-order.sh` script is new and can simply be deleted

All changes are to files tracked in git, so `git checkout -- <file>` can restore any individual file.
