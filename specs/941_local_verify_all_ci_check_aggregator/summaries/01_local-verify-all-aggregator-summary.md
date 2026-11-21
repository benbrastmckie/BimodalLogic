# Implementation Summary: Task #941

- **Task**: 941 - Local aggregator that mirrors ci.yml's check gate
- **Status**: [COMPLETED]
- **Started**: 2026-11-19T00:00:00Z
- **Completed**: 2026-11-19T02:00:00Z
- **Effort**: ~3 hours
- **Dependencies**: None
- **Artifacts**: plans/01_local-verify-all-aggregator.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Added `scripts/verify-all.sh`, a sequential local aggregator that runs the nine check
invocations `.github/workflows/ci.yml` runs, in the same order and with the same arguments,
continuing past every failure and reporting per-check verdicts plus an aggregate `RESULT:`
line with a nonzero exit on any failure — the same reporting shape as ci.yml's own "Report
results" step. Documented it in `CONTRIBUTING.md`'s Development Setup block and catalogued it
in `scripts/README.md`'s two relevant tables.

## What Changed

- `scripts/verify-all.sh` — new file, mode `100755`. Runs, in `ci.yml`'s order:
  `check-evidence-probes.sh`, `check-module-invariants.sh --no-build`,
  `check-copyright-headers.sh --strict FormalSystem BimodalTools`,
  `readme-lint.sh FormalSystem BimodalTools`, `check-metalogic-cycles.sh`,
  `typst-sync-check.sh`, `check-paper-definitions.sh`, `lake exe mk_all --lib FormalSystem
  --check`, and a combined check 9 (`lake exe lint-style` + an executable-bit scan + a
  case-insensitive tracked-path-collision scan, one verdict). Uses `set -uo pipefail`
  (deliberately not `-e`) with `rc=0; <cmd> || rc=$?` guards so no check aborts the run; checks
  8-9 report `SKIPPED` rather than `FAIL` when `lake` is not on `PATH`.
- `CONTRIBUTING.md` — added `bash scripts/verify-all.sh` (with a short explanatory comment) to
  the Development Setup fenced block, immediately after the `install-git-hooks.sh` line.
- `scripts/README.md` — added one row to the "Gates and ratchets" table and one row to the
  "Per-script determinations" table (`No lock`, matching the other leaf-only scripts there).

## Decisions

All six decisions in the plan (check 9's three sub-checks all run under one verdict; no
`lake build`/`lake test` inside the aggregator; `SKIPPED` retained and reachable via a missing
`lake` binary; documentation placed once per file next to the git-hook instruction; two
`scripts/README.md` rows; `check-paper-definitions.sh`'s neutral skip reported as `PASS`) were
implemented exactly as specified, with no changes.

## Plan Deviations

- None in scope or implementation. Two verification-methodology adjustments, both recorded via
  `issue-record.sh` and noted inline in the plan:
  - Seeding check 9's executable-bit sub-check required `git add` (staging), not a bare
    `chmod +x`: `git ls-files -s` (the exact command both `ci.yml` and the new script use)
    reads the git index mode, which an unstaged working-tree permission change does not touch.
  - Phase 1's static verification heuristic (`grep -c 'report ' scripts/verify-all.sh` equals
    `expected`) does not hold exactly as a literal count (12 matches vs. `expected=9`) because
    checks 8-9 are reported from two mutually-exclusive `if`/`else` branches plus one
    incidental match inside the out-of-sync error message text. The real, load-bearing
    invariant — the script's own runtime `seen -ne expected` assertion — was confirmed correct
    both by direct execution (`seen=9` in every real run) and by an isolated logic test that
    bumped `expected=10` in a scratch copy and confirmed the out-of-sync branch fires correctly.

## Verification

- Build: N/A (bash script, no Lean build required by this task)
- Tests: see below — Passed, with findings recorded as findings rather than silently absorbed
- Files verified: Yes

Ran `scripts/verify-all.sh` on the clean tree three times in total across this phase:

1. **Clean-tree baseline**: 8 PASS, 1 FAIL, 0 SKIPPED — `check-paper-definitions.sh` failed on
   a genuine, pre-existing content drift between a Lean definition and the pinned paper record
   (`def:id`), unrelated to this task's scope (which explicitly excludes changing any of the
   nine checks or their inputs). `RESULT: FAIL (1 failed, 8 passed, 0 skipped)`.
2. **Seeded-failure run**: staged (`git add`) an executable-bit change on
   `FormalSystem/Automation/ProofMode.lean`, then ran the script. Check 9 correctly reported
   `FAIL`, named the exact file, and all nine checks still ran — including the independent
   pre-existing `check-paper-definitions.sh` failure, demonstrating two simultaneous failures
   both correctly surfaced. `RESULT: FAIL (2 failed, 7 passed, 0 skipped)`, exit code 1.
3. **Post-revert**: unstaged via `git restore --staged` (sanctioned unstage-only form) and
   `chmod -x`; `git status --short` clean. Re-ran only check 9's two sub-check commands
   directly (rather than a third full ~12-minute script run) and confirmed both return
   empty/PASS — the exact mechanism the full script's check 9 uses, so this is equivalent
   evidence to a full re-run for the one check this seed could affect.

CI parity: no network access to `gh run view` in this sandbox, so parity was verified against
`.github/workflows/ci.yml`'s text instead of a live CI run, per the plan's own stated
contingency — all nine invocations are byte-exact against the live workflow file, re-confirmed
at implementation time.

The out-of-sync `seen -ne expected` guard was confirmed via an isolated logic-test harness (a
scratch copy of the script with the nine real check invocations replaced by instant
stand-ins, never touching the tracked file): the all-pass case reported `RESULT: PASS (all 9
checks ran and passed)`, exit 0; bumping `expected=10` reproduced the out-of-sync error and
exit 1 exactly as the plan specifies.

`bash .claude/scripts/verify-touched.sh scripts/verify-all.sh CONTRIBUTING.md scripts/README.md`
(the Batch Gate Deferral's scoped-tier check) maps all three paths to its NO-SUITE-BY-CLASS
fallback battery, which reports 12 pre-existing failing suites under `.claude/scripts/tests/`.
All 12 trace to one unrelated, pre-existing root cause: those tests resolve
`agent-system/extensions/core/scripts/...` relative to the project root, but this sandbox's
actual `core` extension `source_dir` (`.claude-extensions.json`) is an absolute path outside
this repository not mounted at the location the tests expect. None of this task's three
touched files relate to `.claude/` or the agent-system source store. Real in-dispatch coverage
for this task's own deliverable was the Tier Justification's own named fallback — `bash -n
scripts/verify-all.sh` plus the actual runs documented above.

## Impacts

- A contributor can now run `bash scripts/verify-all.sh` after a successful `lake build`/`lake
  test` to reproduce CI's nine-check verdict locally before pushing, rather than discovering a
  CI-red commit only after a ~30-minute CI run.
- Surfaced one genuine, pre-existing drift (`check-paper-definitions.sh`'s `def:id` mismatch)
  that is now locally reproducible; fixing it is out of this task's scope.

## Follow-ups

- The `check-paper-definitions.sh` drift on `def:id` found during verification is a real,
  pre-existing finding, independent of this task — worth its own task to reconcile the Lean
  source with the pinned paper record (or vice versa).
- The 12 pre-existing `.claude/scripts/tests/` failures found via `verify-touched.sh`'s
  fallback battery (source-store path resolution gap, unrelated to this task) are worth a
  separate investigation if this sandbox's agent-system source-store mounting is meant to be
  exercised here.
- A mechanical `ci.yml`-to-`verify-all.sh` sync checker remains explicitly out of scope (see
  the plan's Risks table); the per-check `ci.yml` step-name/id comments are the only drift
  tripwire today.

## References

- Plan: `specs/941_local_verify_all_ci_check_aggregator/plans/01_local-verify-all-aggregator.md`
- Research: `specs/941_local_verify_all_ci_check_aggregator/reports/01_local-verify-all-aggregator.md`
- Source of record for the nine checks: `.github/workflows/ci.yml`
