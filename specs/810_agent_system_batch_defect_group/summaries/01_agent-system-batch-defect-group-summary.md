# Implementation Summary: Task #810

- **Task**: 810 - agent_system_batch_defect_group
- **Status**: [COMPLETED]
- **Started**: 2026-11-05T03:44:33Z
- **Completed**: 2026-11-05T04:55:54Z
- **Effort**: ~4.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_agent-system-batch-defect-group.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Fixed five independent agent-system defects (batch gate deferral paths, Goals-header anchor,
plan-compliance polarity inversion, literature `--read` path resolution, and Gate 16's
batch-blocking WARN finding) across three extensions (`core`, `lean`, `literature`) in the
resolved source store at `/home/benjamin/.config/nvim` (containing `agent-system/`), never under
this repository's disposable `.claude/` deploy tree. Each defect's fix carries the evidence its
own defect admits — an extended or new test suite for Defects 1, 2, 3, and 5; a measured `--read`
for Defect 4 — and this repository's `.claude/` tree was redeployed and re-verified clean.

## What Changed

- `agent-system/extensions/literature/scripts/literature-search.sh` — added a third chunk-file
  resolution candidate (`sources/<doc_id>/<basename>`) to `do_read()`, mirroring
  `load_fidelity_map()`'s own precedent.
- `agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh` — widened `extract_goal_names()`'s
  `START_RE` to drop the trailing-colon requirement (colon-optional Goals header); tidied
  `extract_r2()`'s names write; added cross-reference comments for the `LEAN_KEYWORDS` denylist
  and the colon-optional widening, both shared (independently) with `lean-plan-compliance-check.sh`.
- `agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` — four new cases
  (R18-R21: single-line and multi-line parenthetical headers, a `**Non-Goals**` negative case, and
  the empty-Goals-guard regression) plus four new fixture files.
- `agent-system/extensions/core/scripts/orchestrate-build-dispatch.sh` — the `## Batch Gate
  Deferral` directive now resolves its two narrowing-invocation paths (`run-all.sh`,
  `verify-deploy.sh`) across the deploy/source-store boundary via a two-candidate,
  existence-checked array, with a degradation to "state the full gate set as such" when neither
  candidate exists.
- `agent-system/extensions/core/context/formats/plan-format.md` — the "Batch-aware deferral"
  example given the dual source-store/deployed form; new "Goal Polarity" section documenting the
  optional plan-level field.
- `agent-system/extensions/core/context/contracts/batch-gate-stage.md` — documents the resolved
  narrowing-invocation paths and the `FINDING `/`WARN-FINDING ` severity channel distinction.
- `agent-system/extensions/core/scripts/tests/test-orchestrate-build-dispatch.sh` — strengthened
  Group 19 with a no-resolvable-candidate case and a deployed-candidates-present case, replacing
  two assertions too weak to detect the fix either way.
- `agent-system/extensions/core/scripts/verify-deploy.sh` — new `warn_advisory()` function
  (findings-mode `WARN-FINDING ` prefix, invisible to the `grep '^FINDING '` consumer filter);
  gate16's call site switched to it; `warn()` itself unchanged (still used by gate20's per-file
  budget-ceiling check, which stays batch-attributable).
- `agent-system/extensions/core/scripts/tests/test-verify-deploy-gate-selection.sh` — new Case
  (r): four sub-assertions confirming gate16's notice no longer escalates while a real `fail()`
  finding from another gate still does.
- `agent-system/extensions/lean/agents/lean-implementation-agent.md` — Final Verification Stage
  step 5 now invokes the extracted script instead of inlining the spot-check bash.
- `agent-system/extensions/lean/scripts/lean-plan-compliance-check.sh` — new; the extracted,
  behaviour-preserving plan-compliance spot-check, extended with an opt-in `Goal Polarity`
  declaration (default/`refutation`/explicit-non-refutation-skips) and a reserved-keyword
  denylist.
- `agent-system/extensions/lean/scripts/tests/test-lean-plan-compliance-check.sh` — new; 13
  characterization and regression cases (C1-C13), including the archived refutation plan's own
  Goals content reproducing the original symptom.
- This repository's `.claude/` tree — redeployed via `deploy-headless.sh` (`__WHOLE_TREE__`).

## Decisions

- **D1 (Defect 5)**: fixed at the findings-interface layer with a severity-distinguishing
  `WARN-FINDING ` prefix, implemented as a separate `warn_advisory()` function rather than a
  parameter on `warn()` — a second `warn()` caller (gate20) was discovered mid-implementation
  that needed to keep today's blocking-channel attributability; see Plan Deviations.
- **D2 (Defect 3)**: fixed by extracting the spot-check to a script (Phase 5), then giving it an
  explicit, opt-in polarity declaration (Phase 6) — neither `SKILL.md` consumer needed editing,
  since both already read the unchanged `passed`/`failed`/`skipped` vocabulary.
- **D3 (task 780 reconciliation)**: the inline block task 780 was filed against no longer exists;
  its fix must now be written as a diff against `lean-plan-compliance-check.sh`. Surfaced as a
  follow-up below rather than attempted here.
- **D4 (Defect 2 guard)**: the `[ ! -s "$GOALS_FILE" ]` guard was left unchanged — measured to
  already fire unconditionally on both the R1 and R2 routes ahead of cross-validation, so there
  was nothing to fix; a comment was added recording this.

## Plan Deviations

- **Phase 4**: the plan's Scope Hypothesis asserted `warn()` has a single caller (gate16). A
  second caller was found at gate20 (per-file budget-ceiling check, default
  `ORCHESTRATOR_BUDGET_GATE_MODE=warn`), with an existing test
  (`test-verify-deploy-context-budget.sh`) relying on its plain `FINDING` channel for
  batch-attributability. Resolved by introducing `warn_advisory()` as a separate function used
  only by gate16, leaving `warn()` and gate20 unaffected — avoided a silent regression the plan's
  own Scope Hypothesis would not have caught.
- **Phase 6**: Characterization cases C5 and C6 (pinned in Phase 5 against the pre-existing
  no-denylist and colon-anchored quirks) are now explicitly superseded by this phase's denylist
  and colon-optional widening, annotated as such in both the test file and the plan checklist —
  not silently re-baselined.
- **Phase 6 (minor scope note)**: `lean-challenge-snapshot.sh` received two
  comment-only cross-reference additions (shared-fragility notes) beyond Phase 6's literally
  declared Files-to-modify list; the file was already in this task's declared `file_scope` from
  Phase 2.

## Verification

- **Defect 1**: `test-orchestrate-build-dispatch.sh`'s strengthened Group 19 assertions were
  measured to fail against the pre-fix composer (5 failures) and pass against the fixed one (183
  passed, 0 failed).
- **Defect 2**: `test-lean-challenge-snapshot.sh`'s new cases R18/R19 were measured to exit 71
  against the pre-fix script and exit 0 (theorem_names=comm) against the fixed one; full suite 33
  passed, 0 failed.
- **Defect 3**: `test-lean-plan-compliance-check.sh` — 13 passed, 0 failed, including the
  archived refutation plan's actual Goals content (re-derived, not hand-typed) producing `failed`
  without the polarity declaration and `passed` with it.
- **Defect 4**: measured `--read` of chunk `fd8fba3d5eb37a3f` (caleiro_2013) returned
  `[Chunk file not found: ...]` pre-fix and real paper content post-fix, against both the source
  store and (after redeploy) this repository's own deployed copy.
- **Defect 5**: measured against a real-copy fixture whose lean manifest genuinely declares
  `routing_agents_hard`: `WARN-FINDING gate16 ...` appears (not `FINDING gate16`), the `[WARN]`
  stderr line is still emitted, and the exit code is unchanged (0). Re-confirmed in this
  repository after redeploy: `verify-deploy.sh --only-gate 16 --findings --quiet .` contains no
  `^FINDING gate16` line.
- **Build**: N/A (shell/markdown task; `bash -n` run on every edited/new shell script).
- **Gate set**: scoped per this phase's own `## Batch Gate Deferral` directive — see "Batch Gate
  Deferral Discharge" below.
- Files verified: Yes (every new/modified file read back and exercised).

## Batch Gate Deferral Discharge

This dispatch's own `.dispatch/6.md` carried a `## Batch Gate Deferral` section for this (final)
phase, which declares `**Verification Tier**: full` in the plan. Per that directive, the complete
unnarrowed gate set (`verify-deploy.sh` with no `--only-gate`/`--skip-slow`, and `run-all.sh` with
no `--only`) was **not** independently run in this dispatch; it is deferred to the once-per-
invocation batch-level stage and attributed back to this task via its own `modified_files`.

Instead, this phase discharged a scoped tier: a single consolidated run of every suite touched
across Phases 1-6 —

```
bash agent-system/extensions/core/scripts/tests/run-all.sh --only \
  test-lit-pipeline.sh,test-lean-challenge-snapshot.sh,test-orchestrate-build-dispatch.sh,\
  test-plan-file-scope-harvest.sh,test-phase-heading-patterns.sh,test-deploy-baseline-lib.sh,\
  test-orchestrate-batch-gate.sh,test-verify-deploy-gate-selection.sh,test-gate-cache-equivalence.sh,\
  test-lean-plan-compliance-check.sh,test-lint-agent-contracts.sh,test-lint-agent-contracts-heartbeat.sh,\
  test-lint-agent-contracts-await-notification.sh
```

Result: **11 passed, 2 failed (1 expected, 1 NEW)** of 13 total.

- `test-gate-cache-equivalence.sh` (EXPECTED): a pre-existing, documented load-sensitive 600s
  internal timeout (`known-failures.txt` line 33), unrelated to this task.
- `test-verify-deploy-gate-selection.sh` (flagged NEW by `run-all.sh`'s own classifier, but
  **confirmed pre-existing and unrelated to this task**): case(c)'s `invalid_cases` array treats
  gate id `24` as presumed-invalid, but gate 24 (`lint-dead-command-recommendations.sh`) has been
  a real, registered gate since task 434 (an ancestor of this task's own starting commit,
  confirmed via `git merge-base --is-ancestor` and a direct read of `gate-registry.data` at that
  commit). This task's own four new assertions in the same suite (Case r-a through r-d) all
  passed cleanly. Recorded as a found issue (not yet in `known-failures.txt`) in this task's own
  issue log; not fixed here, as it is unrelated to any of the five defects.

This repository's own deploy and gate16 discharge were additionally verified directly (not
deferred, since these are per-defect acceptance evidence, not the batch-level full-gate
obligation):
- `timeout 540 bash .claude/scripts/deploy-headless.sh` — `RESULT=landed_verify_clean`,
  `verify-deploy.sh PASS -- 15 check(s), 0 failure(s)`.
- `bash .claude/scripts/verify-deploy.sh --skip-slow --only-gate 16 --findings --quiet .` — no
  `^FINDING gate16` line; `[WARN]` stderr line present; exit 0.

## Acceptance Walk

1. **All five fixed under the resolved source store**: yes — every fix landed under
   `/home/benjamin/.config/nvim/agent-system/extensions/...`, verified by `ls`/`bash -n` on each
   edited file and the commits below.
2. **Defects 1, 2, 3, 5 each carry an extended or new test suite**: yes — see Verification above;
   none asserted by inspection alone.
3. **Defect 4 carries a measured `--read` returning content**: yes — see Verification above,
   measured against both the source store and this repository's post-redeploy deployed copy.
4. **Gate 16 no longer blocks the batch, and `extensions/lean/manifest.json` still declares
   `routing_agents_hard`**: yes — `jq -r 'has("routing_agents_hard")'` returns `true`; no
   deletion was made.
5. **No `.claude/**` file hand-authored**: yes, proven mechanically — every one of this task's 12
   phase commits (6 in each of the two repositories) was inspected via
   `git show --name-only --format="" <sha> | grep '^\.claude/'`, and all 12 are clean.
6. **Staging narrow and explicit throughout**: yes — every commit in both repositories used an
   explicit file-list pathspec; `git-commit-scoped.sh`'s own warnings confirm it dropped any
   cross-repo path mismatch rather than silently widening the stage.

## Impacts

- A refutation-shaped lean plan can now declare `- **Goal Polarity**: refutation` and reach a
  correct spot-check verdict instead of being failed for achieving its goal.
- A `--batch-gate-deferral` dispatch's directive is now followable as written in a deploy-target
  repository instead of requiring each implementing agent to improvise a substitute.
- `literature-search.sh --read` now resolves chunks whose source lives under `sources/<doc_id>/`.
- Gate 16's migration nudge no longer perpetually blocks a batch; the manifest declaration and
  the gate's own behaviour are otherwise unchanged.

## Follow-ups

- **The full `routing_agents_hard` → `hard_contracts` migration** across `core`, `lean`, `cslib`,
  and `books`. Re-measured at implementation time: `grep -rl routing_agents_hard agent-system/`
  returns **22 files** across those same four extensions (the Non-Goals' cited research figure
  was 19; two of this task's own Phase 4 edits — `batch-gate-stage.md` and
  `test-verify-deploy-gate-selection.sh` — each added one new mention, accounting for part of the
  delta). `verify-deploy.sh`'s own gate16 comment names this migration as the real target; it
  remains out of scope for this task and is not yet ready to land per that same comment.
- **Task 780** (`plan_compliance_spotcheck_probe_scope`) must now be written as a diff against
  `lean-plan-compliance-check.sh`, because the inline block it was filed against no longer
  exists, and the sanctioned `update-task-status.sh --depends-on-add` edge is not addable to a
  `not_started` task (confirmed: task 780 is still `not_started` with no `file_scope`).
- A found, pre-existing issue in `test-verify-deploy-gate-selection.sh` (stale `invalid_cases`
  entry for gate 24, now a valid gate) was recorded in this task's issue log; unrelated to any of
  the five defects and not fixed here.
- A found, pre-existing hook false-positive in `guard-destructive-git.sh`'s `git commit -a/-am`
  detector (it matches ordinary hyphenated prose in a commit message body, not just an actual
  flag) was recorded in this task's issue log; worked around by rewording commit messages.

## References

- Plan: `specs/810_agent_system_batch_defect_group/plans/01_agent-system-batch-defect-group.md`
- Report: `specs/810_agent_system_batch_defect_group/reports/01_agent-system-batch-defect-group.md`
- Per-phase progress/handoffs: `specs/810_agent_system_batch_defect_group/{progress,handoffs}/`
