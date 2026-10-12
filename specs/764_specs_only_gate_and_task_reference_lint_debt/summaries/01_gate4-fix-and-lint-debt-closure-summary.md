# Implementation Summary: Task #764

- **Task**: 764 - Close the specs/**-only phase verification gap and the repo-wide task-reference lint debt
- **Status**: [COMPLETED]
- **Started**: 2026-10-12T04:25:00Z
- **Completed**: 2026-10-12T12:46:00Z
- **Effort**: ~3 hours
- **Dependencies**: Task 771 (completed)
- **Artifacts**: plans/01_gate4-fix-and-lint-debt-closure.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Closed two independent verification findings. Finding (1) — an `--only-gate` selection that
exits 0 having run zero checks — is fixed at two levels in `verify-deploy.sh`: gate 4's SKIP
guard (factually wrong for `check-task-references.sh`, which runs a real scan in any
deploy-consumer repo) is removed, and a new end-of-run branch detects any `--only-gate` selection
whose every named gate skipped or was deferred, reporting it loudly (exit 2, named message, and
a `FINDING gate0` line under `--findings`) instead of silently printing `PASS -- 0 check(s)`,
exit 0. Finding (2) — the repo-wide task-reference lint debt — was already mechanically closed
(0 occurrences, independently re-confirmed); the one open sub-question it left behind (whether to
add a path-level exemption category for archival/tombstone trees) was settled and declined, with
the decision recorded durably.

## What Changed

- `agent-system/extensions/core/scripts/verify-deploy.sh` (source store) — gate 4's SKIP branch
  removed (takes the no-guard shape gates 1/2/14/16 already use); block comment rewritten to
  state the disproved premise directly and flag the remaining source-store-conditioned guards as
  unaudited; new zero-check-under-filter detection branch added before the PASS summary (exit 2,
  named stderr message, `FINDING gate0` under `--findings`); header `Exit codes:` and `Gate
  selection` documentation extended accordingly.
- `agent-system/extensions/core/scripts/tests/test-verify-deploy-gate-selection.sh` (source
  store) — new FIXTURE_CONSUMER fixture (deploy-consumer shape, `.claude` symlinked to a real
  deployed tree) and four new cases (e, f, g, h) pinning the gate 4 de-guard, the all-SKIP
  zero-check result, the `--findings` sentinel, and the deferred-gate (`--skip-slow --only-gate
  8`) decision. Each new case confirmed to discriminate via stash-isolation against the
  unmodified script. Fixture comment corrected for FIXTURE_CHEAP's changed gate-4 behavior.
- `agent-system/extensions/core/context/formats/plan-format.md` (source store) — the
  `__FULL_SWEEP__` bullet in `## Verification Tiers` rewritten into a three-way sub-case
  distinction: (a) a `specs/**`-only phase uses `validate-artifact.sh` or a diff read-through,
  never gate 3/4; (b) a source-store, non-`specs/**` markdown edit requires an explicit `TARGET`
  naming the resolved `source_dir`; (c) a deploy-consumer-tree path uses `--only-gate 4` only,
  not `3,4`. Surrounding honesty-constraint paragraphs left byte-unchanged.
- `agent-system/extensions/core/context/standards/task-reference-exemptions.md` (source store) —
  one pointer line under `## Exemption Taxonomy` to the declined archival-tree exemption
  decision; the 7-category table itself unchanged.
- `specs/decisions/no-task-references-enforcement-history.md` (source-store repo) — new
  "Declined: a path-level exemption category for archival/tombstone trees" section with the
  three reasons (durable-anchor rewriting already demonstrated across 53 files; the write-time
  guard already blocks new citations there regardless; category 1's rationale does not
  transfer to archival trees).
- This repo's `.claude/**` — regenerated via `deploy-headless.sh` (Phase 6); not hand-authored.

## Decisions

- The path-level archival-tree exemption category is declined, not added (Phase 1).
- Gate 4 now runs unconditionally against every deploy-consumer repo; gate 3's own
  source-store-only guard is deliberately left untouched and unaudited reasoning extended to the
  other 17 similarly-guarded gates (Phase 2).
- A deferred-gate-only `--only-gate` selection (e.g. gate 8 under `--skip-slow`) is folded into
  the same zero-check detection branch as an all-SKIP selection, since both leave `CHECKS=0`
  (Phase 3).
- `plan-format.md`'s guidance now routes on WHERE a touched path lives rather than offering one
  blanket recommendation (Phase 5).

## Plan Deviations

- **Phase 2/3 verification**: the combined `--only-gate 3,4` check against the nvim source-store
  repo and `test-verify-deploy-context-budget.sh` initially showed unrelated findings/failures
  caused by heavy, unrelated concurrent editing activity in that shared repo (confirmed
  not-caused-by-this-task via git-stash isolation against the unmodified script in both cases).
  The Phase 2/3 drift resolved itself once Phase 5 redeployed the nvim repo's own self-hosted
  tree a second time; Phase 6's `--only-gate 3,4` re-check came back exactly as the plan
  predicted (`PASS -- 3 check(s)`).
- **Phase 6 verification**: `test-verify-deploy-context-budget.sh` still reports 14 passed, 1
  failed. Root-caused definitively (not merely isolated): that suite's fixture is `git init`'d
  but never `git add`s its rsync-copied content, so gate 22 (shellcheck lint)'s default
  `git ls-files`-based `*.sh` enumeration finds zero tracked files inside the fixture and exits
  2, which `verify-deploy.sh`'s gate 22 branch reports as a FAIL. Confirmed via direct
  reproduction and via stash-isolation against the unmodified `verify-deploy.sh` (identical
  failure both before and after this task's changes). Wholly unrelated to gate 3/4, this task's
  only named scope; left unfixed as out of scope (a NON-GOAL explicitly limits changes to gate
  4's applicability and the zero-check summary). Logged as an issue with a recommended follow-up
  fix for that suite's own fixture construction.

## Verification

- Build: N/A (shell scripts and markdown only; `bash -n` clean on every edited script)
- Tests: `test-verify-deploy-gate-selection.sh`: 9 passed, 0 failed.
  `test-verify-deploy-context-budget.sh`: 14 passed, 1 failed (pre-existing, unrelated — see
  Plan Deviations above).
- Files verified: Yes — every phase's named verification criteria run and observed, with
  discrimination confirmed for Phase 4's new test cases via stash-isolation.
- Final full-gate run (deployed copy, this repo): `PASS -- 15 check(s), 0 failure(s)`, exit 0
  (14 pre-fix baseline + 1 new real gate-4 check). Findings diff pre-/post-redeploy: empty.
- `check-task-references.sh`: `0 occurrence(s)`, PASS, exit 0 (confirmed at Phase 1 and again at
  Phase 6).

## Impacts

- Every deploy-consumer repo's `--only-gate 4` invocation now runs a real task-reference scan
  instead of silently skipping, surfacing real citation debt in other repos on their next
  redeploy if any exists — this is the fix working as intended, not a regression, and is not
  this task's to resolve on other repos' behalf.
- Any `--only-gate` selection whose every named gate skips or defers now fails loudly (exit 2)
  instead of exiting 0 having checked nothing, closing the "exit 0 that verified nothing" gap
  named in the task description.
- Planners following `plan-format.md`'s `__FULL_SWEEP__` guidance now get a check that actually
  runs, for all three path-location sub-cases, rather than one recommendation that was vacuous
  for the most common case (a `specs/**`-only phase).

## Follow-ups

- `test-verify-deploy-context-budget.sh`'s fixture should `git add -A && git commit` its
  rsync-copied content before gate 22 (and potentially other `git ls-files`-dependent gates) run
  against it, so the suite's own "baseline fixture is clean" assertion is not spuriously tripped
  by gate 22's enumeration finding nothing tracked. Recorded as an issue
  (`pre-existing-test-defect`, minor); not fixed here as it is outside this task's scope.
- The remaining 17 source-store-conditioned gate guards (beyond gate 3, confirmed correct, and
  gate 4, now fixed) are explicitly unaudited by this task — a future task could systematically
  re-derive each one's premise the way this task did for gate 4.

## References

- Plan: `specs/764_specs_only_gate_and_task_reference_lint_debt/plans/01_gate4-fix-and-lint-debt-closure.md`
- Research: `specs/764_specs_only_gate_and_task_reference_lint_debt/reports/01_specs-only-gate-and-lint-debt.md`
- Decision record: `specs/decisions/no-task-references-enforcement-history.md` (source-store repo)
