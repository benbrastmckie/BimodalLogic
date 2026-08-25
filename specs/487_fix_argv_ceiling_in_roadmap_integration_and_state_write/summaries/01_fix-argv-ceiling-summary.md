# Implementation Summary: Task #487

- **Task**: 487 - Fix 128KB argv ceiling in roadmap-integration.sh and state-write.sh
- **Status**: [COMPLETED]
- **Started**: 2026-08-25T00:00:00Z
- **Completed**: 2026-08-25T02:30:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_fix-argv-ceiling.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Fixed the 128KB (Linux `MAX_ARG_STRLEN` = 131,072-byte) argv ceiling that crashed both
`roadmap-integration.sh` (unconditionally, against the live repo) and `state-write.sh` (for any
caller with an oversized `--argjson` payload), made `roadmap-integration.sh`'s `--annotate` mode
atomic (a mid-run failure now leaves `ROADMAP.md` byte-identical), and tightened the
`explicit_task_ref` heuristic so an item referencing a still-non-terminal sibling task is no
longer wrongly auto-completed. Both scripts now exit 0 on the exact invocations that crashed
before this task, regression tests exist above the ceiling for both, and the fixes are committed
in the source store, ready for the orchestrator's next redeploy checkpoint.

## What Changed

- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/state-write.sh` — transparent
  oversized-`--argjson` spill to `jq --slurpfile` above a 100,000-byte threshold, an additive
  `--argjson-file NAME PATH` flag, an `EFFECTIVE_FILTER` `as`-binding prefix applied at all four
  `jq` call sites, and the existing `cleanup`/`trap` extended (and moved before the `--dry-run`
  branch) to also remove spill files.
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/roadmap-integration.sh` —
  three coordinated fixes: (1) the final report-building `jq -n` now binds `ROADMAP_STATE`/
  `ROADMAP_MATCHES` via `--slurpfile` temp files instead of argv; (2) `--annotate` mode now stages
  every write to a private `ANNOTATE_TARGET` copy and commits to the real `ROADMAP_PATH` exactly
  once, after the JSON report is fully built (report → commit → print, in that order); (3)
  `find_match()`'s `explicit_task_ref` check now collects every `(task N)` reference via
  `re.finditer` (not just the first) and rejects the high-confidence verdict when any referenced
  task is still non-terminal, fed by a new `ACTIVE_TASKS` payload plumbed through a third temp-file
  argument to the Python matching step. The existing single `EXIT` trap was extended (never
  duplicated) to cover every new temp file across all three fixes.
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/test-state-write-large-payload.sh`
  (new) — 7-case isolated-temp-root suite; 5 of 7 cases fail against the pre-fix script.
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-roadmap-argv-ceiling.sh`
  (new) — 5-case isolated-temp-root suite; 3 of 5 cases fail against the pre-fix script.
- `specs/ROADMAP.md` — one live annotation applied via the fixed, tested script: the
  "BimodalReference living monograph" item, whose referenced sibling tasks have all since resolved
  to terminal states, is now correctly checked off.
- Source-store commit `67876e6b3` in `/home/benjamin/.config/nvim/` (not pushed).

## Decisions

- Followed the plan's D1/D2 exactly: transparent auto-spill at a 100,000-byte threshold plus an
  additive `--argjson-file` flag, rather than migrating any existing call site.
- `ACTIVE_TASKS` uses an explicit non-terminal-status allowlist (`not_started`, `researching`,
  `researched`, `planning`, `planned`, `implementing`, `partial`, `blocked`, `pr_ready`) rather
  than `.status != "completed"`, so an abandoned/expanded (also-terminal) task reference does not
  wrongly block a match.
- The commit-ordering fix (report → commit → print) relies on the script's existing `set -euo
  pipefail`: a `jq` failure while building the report aborts the script before the commit `mv`
  ever runs, which is what makes atomicity hold without extra explicit error-checking.

## Plan Deviations

- **Phase 1 / Phase 2 (Case A)**: A >131,072-byte value can never reach `state-write.sh`'s own
  `--argjson $3` at all — the shell's own `execve()` of `bash state-write.sh ...` fails with exit
  126 *before* state-write.sh's internal spill logic (or any of its code) ever runs, since the
  same kernel `MAX_ARG_STRLEN` ceiling applies to that outer invocation as to jq's own. This was
  independently confirmed empirically and is already noted in the research report (line 124).
  `--argjson`'s spill path is real and tested, but only reachable for the (100000, ~131072]-byte
  range where state-write.sh's own invocation still succeeds — the only mechanism that actually
  accepts a genuinely oversized (>131,072-byte) payload in a single call is the new
  `--argjson-file NAME PATH` flag (PATH is a short argv token regardless of file size). Test
  Case A was adapted to use `--argjson-file`, with a new Case A0 added to directly demonstrate and
  document the OS-level ceiling.
- **Plan-level finding (flagged, not corrected by this implementer)**: The plan's Non-Goals state
  "No changes to `skill-todo/SKILL.md` or `commands/todo.md`... makes every existing `--argjson`
  call site work unchanged." Per the deviation above, this is not fully accurate for the one
  *known* real caller that hits this ceiling in production — the `/todo` archival batch (recorded
  at 168,180 bytes, exceeding 131,072). That call will still crash at `state-write.sh`'s own
  invocation unless it is migrated to `--argjson-file`. This is a plan-scope question, not
  something an implementer should resolve unilaterally — flagged here for follow-up planning.
- **Phase 5 verification bullet** ("the previously mis-matched item no longer appears as a
  high-confidence match against the live repo"): could not be demonstrated as literally worded,
  because the live repo's data has moved on since the original incident — all six of the
  BimodalReference item's referenced sibling tasks have since resolved to terminal states
  (completed or abandoned), so the item now legitimately re-matches (this is the fix working
  correctly, not a regression). The fix's actual defense against the historical failure mode is
  instead proven via a synthetic fixture recreating the original conditions (Phase 5's ad hoc
  test, and Phase 6's Case D), which the pre-fix script wrongly matches and the post-fix script
  correctly rejects.
- **Phase 7 (Reasoned Exclusions)**: Redeploy (`deploy-headless.sh`) and the `.claude/scripts/`
  `diff -q` parity check were deliberately skipped, per the delegating orchestrator's explicit
  live-machinery-hazard instruction (a concurrent `/orchestrate` loop is running in this repo and
  calls `.claude/scripts/state-write.sh`/`task-lock.sh` between dispatches; overwriting that live
  tree mid-loop is unsafe and was explicitly forbidden). All four acceptance criteria were instead
  demonstrated against a scratch copy of the fixed source-store scripts, using the real live
  `specs/ROADMAP.md` and `specs/state.json` as inputs — exactly as the delegation context directed
  ("verify against a scratch copy instead and say so in your handoff"). The source-store commit is
  in place and ready for the orchestrator's own next redeploy checkpoint; the actual `.claude/`
  parity `diff -q` must be re-run then.
- **Incident, self-corrected**: `bash .claude/scripts/git-snapshot.sh 487` (default mode) was run
  literally per the plan's Phase 7 task text without first checking that default mode reverts the
  working tree (`git stash push -u`). This briefly stashed away concurrent, unrelated orchestrator
  state changes (`specs/state.json`, `specs/TODO.md`, `specs/events.jsonl`, task-298 log files) —
  not this task's own work. Caught immediately via the script's own printed warning and `git stash
  show -p`, corrected with `git stash pop` before any other write occurred (stash dropped cleanly,
  window was seconds, no other write happened during it), then correctly re-run with
  `--no-revert`.

## Verification

- Build: N/A (shell scripts)
- Tests: Passed — `test-state-write-large-payload.sh` 7/7, `tests/test-roadmap-argv-ceiling.sh`
  5/5, full `tests/run-all.sh` regression 56/56 (was 55, +1 for the new roadmap suite)
- Files verified: Yes — both fixed scripts and both new test files exist, are executable, and
  `bash -n` clean
- Both new suites independently confirmed to fail against pre-fix copies of their target scripts
  (5/7 and 3/5 cases respectively), proving they detect the original defects
- Acceptance 1 (parse-only exits 0 against live repo), Acceptance 2 (scratch-copy `--annotate` then
  real `specs/ROADMAP.md`, identical single-line diff), Acceptance 3 (forced mid-run failure
  byte-identical), Acceptance 4 (both new suites green) — all demonstrated against a scratch copy
  per the Phase 7 Reasoned Exclusion above

## Impacts

- `roadmap-integration.sh` (used by `/review` and `/todo`) now works against the live repo instead
  of crashing unconditionally — restores roadmap integration generally, not any single roadmap
  item.
- `state-write.sh` callers can now pass a single `--argjson` payload up to ~131,072 bytes (spilled
  transparently above 100,000 bytes) without a call-site change, and any caller can adopt
  `--argjson-file` for genuinely unbounded payloads.
- One live `specs/ROADMAP.md` annotation applied (see What Changed).

## Follow-ups

- Consider migrating `skill-todo/SKILL.md` Stage 10 and `commands/todo.md`'s archival-batch
  `--argjson tasks` call to the new `--argjson-file` flag — this is the one known real caller
  whose payload (168,180 bytes at last measurement) exceeds the OS-level ceiling that no
  state-write.sh-internal fix can lift for a literal `--argjson` invocation. Currently worked
  around manually by splitting into 4 calls; `--argjson-file` would make it a proper single-call
  fix. Out of this task's stated Non-Goals as written, but the Non-Goals' stated rationale ("makes
  every existing call site work unchanged") does not hold for this specific caller — see Plan
  Deviations above.
- Requirement 4 (per-match payload trimming) remains descoped per the plan's D3/Non-Goals — not a
  correctness issue now that payloads no longer transit argv.
- Redeploy + `.claude/scripts/` `diff -q` parity check (Phase 7's skipped tasks) should be
  completed at the orchestrator's next redeploy checkpoint.

## References

- Plan: `specs/487_fix_argv_ceiling_in_roadmap_integration_and_state_write/plans/01_fix-argv-ceiling.md`
- Report: `specs/487_fix_argv_ceiling_in_roadmap_integration_and_state_write/reports/01_fix-argv-ceiling.md`
- Progress files: `specs/487_fix_argv_ceiling_in_roadmap_integration_and_state_write/progress/phase-{1..7}-progress.json`
- Source-store commit: `67876e6b3` in `/home/benjamin/.config/nvim/`
