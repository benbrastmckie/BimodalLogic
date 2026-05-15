# Implementation Summary: Task #149

**Completed**: 2026-05-15
**Duration**: ~2 hours

## Overview

Redesigned the Task Order section format in `specs/TODO.md` from flat manual category lists to an auto-generated dependency-driven format. Created the `generate-task-order.sh` script that computes dependency waves (via Kahn's algorithm) and builds an indented dependency tree from `specs/state.json`. Updated `update-task-status.sh` Phase 3 to use the new tree format patterns. Updated `task-order-format.md` to document the new spec.

## What Changed

- `.claude/context/formats/task-order-format.md` — Complete rewrite with new wave table + dependency tree format spec, including parsing patterns, generation template, and historical appendix
- `.claude/scripts/generate-task-order.sh` — New script (~540 lines) implementing Kahn's algorithm wave computation, DFS dependency tree generation, section replacement in TODO.md; supports `--print`, `--update-todo FILE STATE`, and `--goal TEXT` flags
- `.claude/scripts/update-task-status.sh` — Rewrote `update_todo_task_order()` function (Phase 3) with two-mode strategy: in-place sed for non-terminal status changes (matches tree format with `^\s*(└─ )?{N} \[` pattern), full regeneration via `generate-task-order.sh` for terminal transitions (COMPLETED, ABANDONED, EXPANDED)
- `specs/TODO.md` — Task Order section replaced with new wave+tree format; duplicate `## Recommended Order` sections at end of file removed

## Decisions

- Used `(see above)` annotation for diamond dependencies (tasks appearing as blockers under multiple parents) rather than duplicating full subtrees
- Descriptions are preloaded in one jq batch call (not per-task), improving performance
- The `## Recommended Order` duplicate empty sections were removed since the `generate-task-order.sh` script was never wired up for that section, and the new `## Task Order` section supersedes it
- Goal line is always preserved from existing TODO.md content; only overridden when `--goal` flag is explicitly passed

## Plan Deviations

- None (implementation followed plan)

## Verification

- Build: N/A (meta task, no Lean files modified)
- Tests: N/A
- Files verified:
  - `generate-task-order.sh --print` produces well-formed wave table + tree output
  - `--update-todo` replaces section correctly with proper blank-line separation
  - `update-task-status.sh --dry-run postflight 147 research sess_test` matches line 59 in tree format: `[dry-run] TODO.md Task Order (line 59): [IMPLEMENTING] -> [RESEARCHED]`
  - `--dry-run postflight 147 implement sess_test` triggers regeneration mode: `[dry-run] TODO.md Task Order: terminal status COMPLETED -> would run generate-task-order.sh --update-todo`
  - No duplicate `## Recommended Order` sections remain in TODO.md (confirmed via `grep -n "^## " specs/TODO.md`)

## Notes

- The generation script respects task 125's complex multi-parent dependency chain (depends on 116, 122, plus completed tasks 123, 124, 115)
- A follow-up task (149 -> 150) will wire `generate-task-order.sh` into `/task` auto-insertion
- A follow-up task (149 -> 151) will wire it into `/todo` archival and `/review` commands
- The `update-recommended-order.sh` script (709 lines, original Kahn's implementation) was NOT modified as specified in non-goals — the new script is independent
