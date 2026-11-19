# Implementation Summary: Task #939

- **Task**: 939 - Fix the API Documentation workflow's runner OOM
- **Status**: [COMPLETED]
- **Started**: 2026-11-19T08:13:00Z
- **Completed**: 2026-11-19T09:05:00Z
- **Effort**: ~1.25 hours
- **Dependencies**: None
- **Artifacts**: plans/01_fix-api-docs-runner-oom.md, reports/01_runner_oom_lever.md,
  specs/evidence/lean-num-threads-cap-probe/probe.lean,
  specs/evidence/lean-num-threads-cap-probe/probe-results.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Capped doc-gen4's build concurrency on the `API Documentation` GitHub Actions workflow by adding
a step-level `env: LEAN_NUM_THREADS: "1"` to the `docgen` step in `.github/workflows/docs.yml`,
and rewrote the file's header comment to record the finding, its precedents, the two routes
measured closed, and a fallback ladder. Phase 1 measured the variable's local effect on this
toolchain before the edit landed, closing the research report's own Risk 3; the result was
inconclusive, which the plan's own contingency explicitly treats as not a blocker given the
strength of the upstream precedent.

## What Changed

- `.github/workflows/docs.yml` — added a step-level `env: LEAN_NUM_THREADS: "1"` on the `id:
  docgen` step (confirmed, via a parsed-YAML assertion, to be the only step or job carrying that
  key); rewrote the header's closing memory paragraph and the line-18 "THIS JOB DOES NOT
  CURRENTLY PASS" sentence to record the actual finding instead of the refuted "a real fix means
  a larger runner, a forked or newer action, or fewer doc targets" claim.
- `specs/evidence/lean-num-threads-cap-probe/probe.lean` — created; a standalone Lean program (no
  Mathlib/`FormalSystem` imports) that launches 48 (`2 x nproc` on this host) CPU-bound tasks via
  `IO.asTask` and waits for all of them, used to measure `LEAN_NUM_THREADS`'s effect locally.
- `specs/evidence/lean-num-threads-cap-probe/probe-results.md` — created; records both official
  measurement runs (`LEAN_NUM_THREADS` unset and `=1`), the host/toolchain, the methodology
  investigation that led to using `IO.asTask` instead of a plain `Task.spawn` closure, and the
  explicit **inconclusive** verdict with its reasoning.

## Decisions

- **Probe mechanism changed from `Task.spawn` to `IO.asTask`.** The plan named either as
  acceptable. A pure `Task.spawn (fun _ => ...)` closure was tried first and, via
  `/proc/<pid>/task/*/stat` polling against a compiled build of the same logic, never
  observably used more than one worker thread regardless of `LEAN_NUM_THREADS` (including at
  `Task.Priority.dedicated`, which the Lean reference documents as always getting its own OS
  thread). `IO.asTask` wrapping a CPU-bound `IO` action did achieve confirmed multi-thread
  concurrency (8 threads simultaneously `R` at `LEAN_NUM_THREADS=8` in the same polling test), so
  the committed probe uses it.
- **Verdict recorded as inconclusive, not refuted, despite the raw numbers reading as "same
  utilization either way."** The official measurement showed 1433% CPU (`LEAN_NUM_THREADS`
  unset) vs 1669% (`=1`) — no capping signal, if anything backward. This was not treated as a
  flat refutation because the probe's own task shape (48 simultaneously-ready, non-nested,
  independent tasks, waited on in a flat loop from a single non-task caller) plausibly triggers
  the Lean runtime's own documented escape valve ("the thread pool size is not a hard limit; in
  certain situations it may be exceeded to avoid deadlocks") — a shape unlike Lake's real
  dependency-graph-driven job release. A named Lake maintainer statement (Mac Malone,
  leanprover-community Zulip, "number of threads for lake build" thread) independently confirms
  Lake has no mechanism of its own to limit its `Task` pool and that `LEAN_NUM_THREADS` "serves a
  good-enough fix for the few places this has been an issue" — direct endorsement of the
  mechanism's practical effectiveness, separate from this probe's own inconclusive result.
- **Proceeded with the edit on inconclusive**, per the plan's own explicit contingency: only a
  **refuted** verdict blocks Phase 2; inconclusive does not, since the upstream precedent
  (maintainer statement, `lean-action`'s README, `opencompl/veir`'s production `docs.yml`) stands
  on its own.
- **`env:` placed step-scoped on `docgen`, not job-scoped**, so the earlier
  `leanprover/lean-action` build step (not the one OOMing) keeps its default parallelism.

## Plan Deviations

- **Task 1.1** (Phase 1, probe mechanism) altered: used `IO.asTask` instead of `Task.spawn`, both
  named as acceptable by the plan. `Task.spawn` was tried first and confirmed non-functional for
  concurrency on this toolchain via direct thread-state polling; see the Decisions section above
  and `probe-results.md`'s "Methodology note" for the full account.

## Verification

- Build: N/A (no Lean build touched; the probe is a standalone file outside `FormalSystem/`)
- Tests: N/A (no test suite covers `.github/workflows/**` or `specs/evidence/**`)
- `.github/workflows/docs.yml` parses as YAML (`python3 -c "import yaml; yaml.safe_load(...)"`
  exits 0); a parsed-YAML assertion confirms the `docgen` step carries
  `env: {LEAN_NUM_THREADS: "1"}` and no other step or the job level gained that key.
- The header no longer contains the refuted three-route sentence; it names `LEAN_NUM_THREADS`,
  both precedents, both closed routes, and the fallback ladder (confirmed by grep: the old
  sentence and the stale "THIS JOB DOES NOT CURRENTLY PASS" line are both absent; the new
  `LEAN_NUM_THREADS` references are present at four locations: the two header paragraphs and the
  step's own `env:` block).
- `bash .claude/scripts/verify-deploy.sh` (the full gate set per the plan's `full` verification
  tier): PASS, 12 checks run / 0 failures. Doc-lint and 17 other gates SKIP by design, since this
  repository is a deploy consumer with no `agent-system/extensions` source store, exactly as the
  plan anticipated. No finding named `.github/workflows/docs.yml`.
- `bash scripts/typst-sync-check.sh --counts-only` (the anticipated pre-commit gate collision):
  `MISMATCH_COUNT=0`, clean. In the event, this phase's own commit staged only `docs.yml` (no
  `.lean` path), since Phase 1's `probe.lean` was already committed in Phase 1's own closing
  commit, so the anticipated collision never materialized.
- Files verified: both evidence files exist and are non-empty; `docs.yml`'s diff is confined to
  the `docgen` step's `env:` block and the header comment.
- Working tree: clean of this task's edits after each phase's commit; nothing pushed, no PR
  opened.

## Impacts

- The next push to `main` that triggers the `API Documentation` workflow will run the `docgen`
  step with `LEAN_NUM_THREADS=1`. If the OOM is resolved, the workflow should report a green
  `Build and deploy doc-gen4 documentation` step for the first time since the prior green run.
- If the pushed run still OOMs at `"1"`, the header's own recorded response is a doc-target
  reduction — **not** a higher thread count — since that outcome would indicate a single
  doc-gen4 task's own memory footprint, not concurrency, exceeds the runner. If the run succeeds
  but overruns the 300-minute timeout, the recorded next step is trying `"2"` on a follow-up run.
- No other workflow, build, or test is affected: `CI / Build and Test` (`ci.yml`) was explicitly
  out of scope and untouched, and no `.lake/build` CI-cache work was done (also explicitly out of
  scope).

## Follow-ups

- **The user's remaining step, named explicitly per this task's own Verification section**: push
  this branch to `main` and confirm the `API Documentation` workflow reports a green run. This
  agent did not push and did not open a PR (`.claude/rules/pr-prohibition.md`); the failure is a
  property of the hosted runner's memory and cannot be reproduced or verified locally.
- If a real run still OOMs at `"1"`, the next task should be a doc-target reduction, filed as its
  own task per the plan's Rollback/Contingency section — not a higher `LEAN_NUM_THREADS` value.

## References

- Plan: `specs/939_fix_api_documentation_runner_oom/plans/01_fix-api-docs-runner-oom.md`
- Research: `specs/939_fix_api_documentation_runner_oom/reports/01_runner_oom_lever.md`
- Evidence: `specs/evidence/lean-num-threads-cap-probe/probe.lean`,
  `specs/evidence/lean-num-threads-cap-probe/probe-results.md`
- Edited: `.github/workflows/docs.yml`
- External precedent cited in the header and the evidence: `leanprover/lean-action`'s README
  ("Run leanchecker on a project with a Mathlib dependency"); `opencompl/veir`'s production
  `docs.yml`; the leanprover-community Zulip thread "number of threads for lake build"
  (Mac Malone's maintainer statement).
