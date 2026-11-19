# Implementation Summary: Task #829

- **Task**: 829 - Ci lake build cache and job config
- **Status**: [COMPLETED]
- **Started**: 2026-11-19T00:12:56Z
- **Completed**: 2026-11-19T00:50:00Z
- **Effort**: ~0.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_ci-lake-build-cache-and-job-config.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This task was filed with two ordered deliverables: (a) add an `actions/cache` step scoped to
`.lake/build`, and (b) give `ci.yml`'s `build` job a `timeout-minutes` for parity with
`docs.yml`. Research (round 1) found deliverable (a) already satisfied by default:
`leanprover/lean-action@v1`, which all three workflows invoke, ships its own composite
`actions/cache/restore` + `actions/cache/save` pair around the entire `.lake` directory with
`use-github-cache` defaulting to `true`, and none of the three workflows overrides it. Adding a
second, separately-keyed cache step on the same path would duplicate compression/upload cost and
cache-quota consumption for no coverage gain, so the plan deliberately did not implement
deliverable (a) as literally filed. Implementation landed deliverable (b) as the one functional
change, amended this repository's own CI documentation to close the gap that caused the task to
be filed with a refuted premise in the first place, corrected one stale count comment in
`lakefile.toml`, and re-verified every acceptance criterion against live state (a completed CI
run's log and the live Actions cache store), not only against research-time inspection.

## What Changed

- `.github/workflows/ci.yml` — added `timeout-minutes: 300` to the `build` job (sibling key of
  `runs-on`), with a one-line comment recording the `docs.yml` parity source. This is the task's
  deliverable (b) and the only executable/functional change in this task.
- `docs/development/CI_CD_PROCESS.md` — amended the existing `### GitHub Actions Cache`
  subsection (not duplicated) with three previously-omitted facts: (i) the cache is provided by
  `leanprover/lean-action@v1` itself, default-on, covering the whole `.lake` directory, and the
  repository's own workflows deliberately carry no separate `actions/cache` step; (ii) the
  `actions/cache/save` half runs inside that single composite step, so the `Compile lean_exe
  roots` loop and the `BimodalTools`/`BimodalToolsTest --wfail` builds that follow it in the same
  job write into `.lake/build` after the snapshot is taken and are therefore re-elaborated every
  run — stated as a known design boundary, not a defect being fixed here; (iii) how to
  re-verify the live cache (`gh api repos/<owner>/<repo>/actions/caches`, and the `Cache restored
  from key:` / `Cache Size:` lines inside a completed run's log).
- `lakefile.toml` — corrected the `BimodalTools` tooling-library comment from "the roots of the
  13 `lean_exe` targets below" to 15, matching the live count (`grep -c '^\[\[lean_exe\]\]'` and
  `scripts/lake_targets.py exe-roots` both agree at 15). Comment-only; `tomllib` confirms the
  declared `lean_exe`/`lean_lib`/`defaultTargets` sets are identical before and after.
- `specs/829_ci_lake_build_cache_and_job_config/summaries/01_ci-lake-build-cache-and-job-config-summary.md`
  — this summary.

## Decisions

- **Deliverable (a) was deliberately not implemented.** Live evidence at implementation time
  (not just research time) confirms `lean-action@v1`'s own cache is active: a completed `ci.yml`
  run (databaseId `44420618072`, headSha `81ae7a6c09807630b5000992a8bb5f689e051fa6`) logs `Cache
  hit for restore-key: lake-Linux-X64-84afb9faf81ba594c8fbeacf1c7b9498b7b68d5c977b26004b4d20034536373c-983b2d49856adbb7022668686c620cf48e6051b0f53ff065060737f9c9a23b39-c78a4cedc9c3c4195e206f779de8d8eda85e3f50`
  and `Cache Size: ~2605 MB (2731915539 B)` inside the "Build, test, and lint with Lean" step.
  `gh api repos/<owner>/<repo>/actions/caches` lists 4 live entries, all under the
  `lake-Linux-X64-…` key family, each ~2.6-2.7 GB. Adding a second, independently-keyed
  `actions/cache` step on `.lake/build` would duplicate this coverage for no gain, so the task's
  Non-Goals correctly bar it.
- The documentation amendment lands inside the task's declared FILE SCOPE expansion (one file,
  `docs/development/CI_CD_PROCESS.md`, beyond the dispatch's literal `ci.yml`/`lakefile.toml`
  scope) because the central research finding is a documentation gap, not a code gap: a
  contributor grepping `.github/workflows/` for `actions/cache` and finding nothing is exactly
  how this task came to be filed against a premise that live evidence refutes.
- The residual cache-boundary gap (the per-job save-point limitation) is recorded as a named
  follow-up candidate rather than landed, per the task's own GUARDRAIL: closing it (setting
  `use-github-cache: false` plus a hand-rolled job-wide restore/save) is a measured experiment
  requiring a before/after timing that does not exist yet.
- `moreLeanArgs`, `precompileModules`, `extraDepTargets`, and any `strategy:`/`matrix:` split
  remain unimplemented, per the same GUARDRAIL — confirmed absent by grep at Phase 3.

## Plan Deviations

- **Task 3.5** (Phase 3) altered: the plan's own task list named `bash
  .claude/scripts/verify-deploy.sh` (unscoped, full battery) as Phase 3's gate-set check. This
  dispatch's own Batch Gate Deferral directive — issued because this implementation ran inside a
  multi-task `/orchestrate` batch invocation alongside sibling task 938 — supersedes that
  independent full sweep. Discharged instead via the scoped `verify-touched.sh` narrowing
  invocation (run with no arguments, the directive's stated preference), run once per phase
  across this task (3 times total: after Phase 1, after Phase 2, and again in Phase 3). Each run
  hit the same pre-existing tooling defect — `.claude/scripts/tests/suite-selection-map.data`
  line 37 names `test-verification-scope-lib.sh`, a self-referential new-library suite not yet
  landed, causing a preflight `exit 2` — and that finding names no file in this task's scope
  (`.github/workflows/ci.yml`, `lakefile.toml`, `docs/development/CI_CD_PROCESS.md`, or this
  summary file). Per the dispatch's own baseline-delta rule, each run is a recorded PASS for this
  task rather than a block. The complete gate set runs once for the whole batch at the end of
  this invocation, and its result is attributed back to this task via `modified_files`.

## Verification

- Build: N/A (no Lean code touched; `ci.yml` and `lakefile.toml` parse correctly — confirmed via
  `yaml.safe_load` and `tomllib.load`).
- Tests: N/A (no test surface touched).
- `python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/ci.yml'))['jobs']['build']; print(d['timeout-minutes'])"`
  → `300`.
- `git diff f697f456fa870c9791ec6f40fbb491ac0fca379c -- .github/workflows/ci.yml` → exactly the
  added `timeout-minutes: 300` line plus its two-line comment; every existing step, input, and
  comment byte-identical.
- `git diff 98149bc77fe338ce0701d4832c0988cd3e56a6fc -- lakefile.toml` → exactly the one comment
  line changed (13 → 15); `tomllib` parse of declared targets unchanged before/after.
- `grep -rn "actions/cache\|restore-keys\|use-github-cache" .github/workflows/` → nothing
  (Non-Goal held).
- `grep -n "moreLeanArgs\|precompileModules\|extraDepTargets\|strategy:\|matrix:" lakefile.toml .github/workflows/ci.yml`
  → nothing (Non-Goal held).
- `bash scripts/readme-lint.sh docs` → PASS, 0 broken references, 0 missing READMEs.
- `bash .claude/scripts/verify-touched.sh` (and scoped to this task's touched files) → ran three
  times across this task's phases; each hit the pre-existing, unrelated
  `suite-selection-map.data` preflight defect described under Plan Deviations above, recorded as
  a baseline-delta PASS each time (no finding named any file in this task's scope). Full
  `verify-deploy.sh` sweep deferred to the batch-level stage per this dispatch's Batch Gate
  Deferral directive.
- Live cache-restore evidence: run `44420618072` (completed), `Cache hit for restore-key:
  lake-Linux-X64-...c78a4cedc9c3c4195e206f779de8d8eda85e3f50`, `Cache Size: ~2605 MB`. Live
  cache store: 4 entries under the `lake-Linux-X64-…` key family via `gh api
  repos/<owner>/<repo>/actions/caches`.
- Files verified: Yes (both edited files parse; diffs confirmed minimal and scoped).

## Impacts

- `ci.yml`'s `build` job no longer inherits GitHub's 360-minute default timeout, closing the
  parity gap with `docs.yml` noted in the original filing.
- `docs/development/CI_CD_PROCESS.md` now carries the full, accurate account of how `.lake/build`
  caching actually works in this repository, including its one real limitation, closing the
  documentation gap that produced this task's originally-refuted deliverable (a).
- No change to any CI check step's behavior, `run:` body, `continue-on-error` flag, step `id`,
  `report` line, or the `expected` count in the "Report results" step.

## Follow-ups

- **Residual cache-boundary gap** (not landed, named as a follow-up candidate per the task's
  GUARDRAIL): `lean-action@v1`'s `actions/cache/save` runs inside its single composite step, so
  the `Compile lean_exe roots` loop (15 targets) and the `lake build
  BimodalTools`/`BimodalToolsTest --wfail` steps that follow it in `ci.yml`'s `build` job write
  into `.lake/build` after the snapshot is taken and are re-elaborated every run. Closing this
  means setting `use-github-cache: false` and hand-rolling a job-wide `actions/cache/restore`
  (right after checkout) plus `actions/cache/save` (as the job's last step) — gated on a recorded
  before/after timing, which does not exist yet and was explicitly out of scope here.
- `timeout-minutes: 300` on `release.yml`'s `release` job is also absent (noted by research as
  ancillary only) — outside this task's FILE SCOPE; not actioned here.

## References

- Plan: `specs/829_ci_lake_build_cache_and_job_config/plans/01_ci-lake-build-cache-and-job-config.md`
- Report: `specs/829_ci_lake_build_cache_and_job_config/reports/01_ci-lake-build-cache-and-job-config.md`
- CI run used for acceptance evidence: `44420618072`
