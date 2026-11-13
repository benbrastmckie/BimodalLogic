# Implementation Summary: Task #787

- **Task**: 787 - Audit the remaining lake-invoking scripts for the unguarded .lake read hazard
- **Status**: [COMPLETED]
- **Started**: 2026-11-13T19:27:02Z
- **Completed**: 2026-11-13T19:42:00Z
- **Effort**: 0.25 hours
- **Dependencies**: 743 (declared, completed)
- **Artifacts**: plans/01_lake-reader-lock-audit.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Every surveyed lake-invoking script now has a recorded determination. Two scripts gained the
shared `.lake/build-guard.lock` in the precedent hold-to-exit shape, two long-running dataset
runners gained a subshell-scoped locked prebuild, two delegating/source-only scripts carry an
in-header ruling-out, and `scripts/README.md` holds the convention, the full per-script table
(in-repository and deployed), and a list of the readers that remain unguarded. No probe file,
manifest array, Lean source, generated typst file, or `.claude/**` path was touched.

## What Changed

- `scripts/typst-status-counts.sh` — shared lock before the one `lake env lean` call (after the
  `--json` exit); lock-timeout branch (environment class, exit 1, nothing written); failed-read
  message split into environment failure vs the existing "run lake build" text; header note.
- `scripts/typst-machine-appendix.sh` — one hold of the shared lock at the head of default mode
  covering `lake build BimodalTools.MachineAppendixMain` and `lake env lean --run`; header notes
  that `--json` and `--render-only` take no lock.
- `scripts/export-training-data.sh` — `locked_prebuild` (subshell-scoped lock around
  `lake build <targets>`), called after `check_prereqs`; targets follow `--skip-dataset` /
  `--skip-proofs`; one `[dry-run]` line under `--dry-run`; header note.
- `scripts/run_dataset_generation.sh` — same `locked_prebuild` for `dataset_generator`; header note.
- `scripts/typst-sync-check.sh` — header ruling-out (leaf-only: must not lock); `--fix` failure
  hint names a concurrent build holding the lock as a second cause.
- `scripts/typst-module-map.sh` — header ruling-out (reads source text only).
- `scripts/README.md` — new "Shared `.lake` build lock" section: convention, leaf-only rule,
  subshell-scoped variant, what the lock does not cover, per-script determination tables, and
  "Known unguarded readers".

## Decisions

- The failed-read classifier in `typst-status-counts.sh` reuses both halves of
  `check-evidence-probes.sh`'s `probe_env_failure` predicate. Its environment message also names
  `lake build`, because a never-built library produces the same missing-object-file shape.
- `locked_prebuild` signals a lock timeout out of its subshell with exit 75 so the caller can name
  timeout vs build failure; the script's own exit status is 1 in both cases.
- The README section was placed before "`lib/` helper modules" (it spans gates, dataset and typst
  scripts, so it does not belong under any one category table).
- The independent sweep (non-comment `lake` / `.lake` mentions over tracked `scripts/` and
  `.githooks/`) found four names absent from the plan's table: `warning-budget.py` (already
  planned for the unguarded list), `.githooks/pre-commit`, `CheckInitImportsMain.lean`, and
  `nolints-style.txt`. Each has a row.

## Premise Re-Validation

- "check-evidence-probes.sh now takes an flock on `.lake/build-guard.lock` and distinguishes an
  environment failure": CONFIRMED against the live file (its `SHARED .lake LOCK` block and
  `probe_env_failure`).
- The four-probe race and its cost: CARRIED-UNVERIFIED (source: that script's in-file account);
  nothing here depends on re-measuring it.
- "Any candidate under `.claude/scripts/` is a deploy artifact; edit the source store": CONFIRMED
  as a rule; no `.claude/**` or source-store path was edited (the source store is a different
  repository), and the one deployed script that carries the hazard is listed as a follow-up.
- "A reasoned no-lock finding is a complete outcome": applied to every ruled-out row.
- Description's lead candidates: `typst-module-map.sh` invoking bare `lake env lean` is FALSE;
  `export-training-data.sh` running `lake build ...` is FALSE (echoed hint; runtime calls are
  `lake exe`). Both re-confirmed against live files, matching the plan.

## Plan Deviations

- **Task 3.3** altered: in `run_dataset_generation.sh` the prebuild is additionally gated on the
  command being a generation tier (`smoke`, `c4`..`c12`, `all`), so `help` and an unknown command
  do not trigger a build.
- **Task 5.6** altered: per the dispatch's Batch Gate Deferral, the complete `verify-deploy.sh`
  gate set was deferred to the once-per-invocation batch stage. This dispatch ran the scoped tier
  (`verify-deploy.sh --only-gate 4`) and, as the unmappable repository-specific criterion,
  `scripts/check-module-invariants.sh --no-build` directly.

## Verification

All lock paths were exercised with a stub `lake` on `PATH` and a bounded (30 s or less) `flock`
holder; no real build was started and no generated file was written.

| Script / mode | Exit before | Exit after | Notes |
|---|---|---|---|
| `typst-status-counts.sh --json` | 0 | 0 | stdout byte-identical; completes under a held lock with empty stderr |
| `typst-status-counts.sh` (write), lock held, wait 2 s | n/a | 1 | waiting line + environment message; stub never invoked |
| `typst-status-counts.sh` (write), stub fails with missing-object-file | 1 | 1 | environment message |
| `typst-status-counts.sh` (write), stub fails with other text | 1 | 1 | original "Run 'lake build' first" text |
| `typst-machine-appendix.sh --json` / `--render-only` | 0 / 0 | 0 / 0 | byte-identical; no wait under a held lock |
| `typst-machine-appendix.sh` default, lock held, wait 2 s | n/a | 1 | environment message; stub never invoked |
| `typst-machine-appendix.sh` default, stub fails | non-zero | 1 | stub log: exactly `build BimodalTools.MachineAppendixMain` |
| `export-training-data.sh --dry-run c5` | 0 | 0 | one added `[dry-run]` prebuild line (plus timestamp/commit stamps) |
| `run_dataset_generation.sh --dry-run c5` | 0 | 0 | one added `[dry-run]` prebuild line (plus timestamp) |
| both runners, lock held, wait 2 s (`c5`; `smoke`) | n/a | 1 | timeout message; stub never invoked |
| both runners, stub fails (incl. `--skip-proofs`, `--skip-dataset`) | n/a | 1 | stub log shows only the expected `build <targets>`; no `exe`; lock free afterwards |
| `run_dataset_generation.sh help` / unknown command | 0 / 1 | 0 / 1 | no prebuild |
| `typst-sync-check.sh --counts-only` | 0 | 0 | stderr identical; completes under a held lock |
| `typst-sync-check.sh` | 0 | 0 | stderr identical; completes under a held lock |
| `typst-module-map.sh --json` | 0 | 0 | stdout byte-identical |

- Build: N/A (no Lean source changed; no real build run by design)
- `bash -n` on all six edited shell scripts: exit 0
- `bash .claude/scripts/verify-deploy.sh --only-gate 4`: exit 0 after each phase
- `bash scripts/check-module-invariants.sh --no-build`: exit 0 (46 PASS, 0 FAIL), lock free at the time
- Full `verify-deploy.sh` gate set: DEFERRED to the batch stage (not run in this dispatch)
- `command grep -ln 'build-guard.lock' scripts/*.sh scripts/*.py`: the two precedents, the four
  newly locked/prebuilding scripts, and `typst-sync-check.sh` (header comment and one hint string
  only; it never opens the lock)
- Wording check on all added lines: no task numbers, no draft-history phrasing
- Files verified: Yes; nothing changed under `typst/generated/`, `.claude/`, or `data/`

## Impacts

- The typst generators' write paths and the dataset runners now wait (announced, bounded at
  600 s) on a concurrent guarded build, and a guarded build waits on them.
- A lock timeout or a raced read in these scripts is reported as an environment failure, so it
  should not be read as a defect in counts, artifacts, or the library.
- The dataset runners now run an explicit `lake build` of their binaries before generating.

## Follow-ups

- Recommended new task, sited in the agent-system source-store repository: add the shared lock to
  `lean-challenge-snapshot.sh` (bare `lake env lean`, failure maps to a fatal exit), and add a
  context note on flock re-entrancy (a child re-opening the lock file is excluded by its parent).
- Recommended new task: guard `scripts/warning-budget.py` under `--no-build` / standalone use.
- Recommended new task: close the `C1` lock-timeout residual in
  `scripts/check-module-invariants.sh` (later build-requiring checks run unlocked after a timeout).
- Observed, not changed: `scripts/README.md`'s `generate-decidability-inventory.sh` row contains
  the phrase "this task's one hard-failure condition", which predates this work.

## References

- specs/787_lake_unguarded_reader_lock_audit/plans/01_lake-reader-lock-audit.md
- specs/787_lake_unguarded_reader_lock_audit/reports/01_lake-reader-lock-audit.md
- scripts/check-evidence-probes.sh (`SHARED .lake LOCK` block), scripts/check-module-invariants.sh (`C1: build` block)
