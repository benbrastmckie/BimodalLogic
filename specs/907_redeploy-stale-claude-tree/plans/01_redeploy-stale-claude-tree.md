# Implementation Plan: Task #907

- **Task**: 907 - Redeploy stale .claude/ tree
- **Status**: [IMPLEMENTING]
- **Effort**: 1 hour
- **Dependencies**: None (recurrence of the condition closed by task 715; no blocking task)
- **Research Inputs**: specs/907_redeploy-stale-claude-tree/reports/01_redeploy-stale-claude-tree.md
- **Artifacts**: plans/01_redeploy-stale-claude-tree.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The deployed `.claude/` tree in this repository was reported stale relative to the source store
for six extensions (core, formal, lean, literature, memory, typst). The research dispatch already
executed the sanctioned operational remedy — `deploy-headless.sh` under the bounded-wait idiom —
and verified all six extensions now report `FRESH` through two independent surfaces. This plan is
therefore a confirm-and-close sequence, not a fresh repair: it re-probes freshness (the condition
can drift again between dispatches if the source store moves), conditionally re-runs the redeploy
only if drift is found, and discharges the complete deploy gate set that the research dispatch
deliberately left out of its narrower scope. Definition of done: all six named extensions report
`FRESH`, `check-deploy-freshness.sh` exits 0 with no WARN, and a full (not `--skip-slow`)
`verify-deploy.sh` run passes.

### Research Integration

Key findings carried into this plan from `reports/01_redeploy-stale-claude-tree.md`:

- The redeploy has already been run twice, both landing `RESULT=landed_verify_clean`; the
  operation is idempotent and repeatable, so a conditional re-run in Phase 2 is cheap and safe.
- Freshness was confirmed through `deploy_freshness_status` (the library primitive, queried per
  extension) *and* `check-deploy-freshness.sh` (the actual advisory consumer). This plan reuses
  both surfaces rather than trusting the deploy script's own bundled verification.
- `verify-deploy.sh` SKIPs gates 3, 5, 6, 7, 9–13, 15, 17–29 in this repository because it is a
  deploy *consumer*, not the source store. That is expected, not incomplete verification — the
  implementer must not read those SKIPs as failures.
- The research dispatch explicitly did **not** run `verify-deploy.sh` without `--skip-slow`,
  calling it out of scope for that phase. Phase 2 of this plan closes that gap.
- `.claude/` and `.claude-extensions.json` are both gitignored, so a redeploy produces no tracked
  git diff. The only committable outputs of this task are its own `specs/**` artifacts.
- No code or configuration change is recommended for this occurrence; the fix is operational.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; no roadmap consultation performed.

## Goals & Non-Goals

**Goals**:

- Confirm, at implementation time rather than on the strength of the research dispatch's
  now-older observation, that all six named extensions (core, formal, lean, literature, memory,
  typst) report `FRESH`.
- Re-run the sanctioned `deploy-headless.sh` regeneration if and only if any extension has drifted
  back to `STALE` since the research dispatch.
- Discharge the complete `verify-deploy.sh` gate set (no `--skip-slow`), which the research phase
  scoped out.
- Confirm the per-dispatch staleness `WARN` emitted from `skill-base.sh` no longer fires.

**Non-Goals**:

- Hand-patching any file under `.claude/**` to silence the staleness warning. This is explicitly
  prohibited by the dispatch: it masks divergence instead of fixing it.
- Any change to the staleness algorithm, the deploy engine, or the inter-cycle redeploy checkpoint
  cadence. The research phase found no defect in the mechanism; the recurrence-cadence question it
  raised is a separate, out-of-scope concern.
- Re-doing any work from the two dispatches that reported the staleness. The dispatch description
  establishes neither relied on a stale deployed command.
- A `--wipe` deploy. The condition is "source store moved ahead of the recorded resync", which
  `manager.resync_all` closes; nothing observed suggests divergence requiring wipe-and-reload.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Freshness drifts back to STALE between this plan and implementation (source store advances) | M | M | Phase 1 re-probes rather than trusting the research report; Phase 2 conditionally redeploys on that probe's result |
| Implementer reads `verify-deploy.sh`'s many consumer-repo `[SKIP]` lines as failures and reports a false problem | M | M | Phase 2's verification criteria state the expected SKIP set explicitly and key the pass/fail judgement on the failure count, not the SKIP count |
| Full (non-`--skip-slow`) `verify-deploy.sh` exceeds a naive tool timeout and is reported as a hang | M | M | Phase 2 runs it under the bounded-wait idiom (`timeout 540`, Bash tool `timeout` 600000) per `context/patterns/external-process-wait.md` Rule 1 |
| Temptation to edit a deployed `.claude/**` file to clear a residual WARN | H | L | Explicit Non-Goal above; the only sanctioned remedy is re-running `deploy-headless.sh` |
| Nothing to commit (deploy outputs are gitignored) read as a failed implementation | L | M | Artifacts & Outputs states that the only tracked outputs are this task's `specs/**` artifacts |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Re-Probe Deploy Freshness [COMPLETED]

**Goal**: Establish, from live probes rather than from the research report's older observation,
whether any of the six named extensions has drifted back to `STALE`. This phase decides whether
Phase 2 must actually redeploy or only verify.

**Tasks**:

- [x] Source the freshness library and query each of the six named extensions individually:
      `source .claude/scripts/lib/deploy-freshness-lib.sh` then
      `deploy_freshness_status "$(pwd)" <ext>` for `core`, `formal`, `lean`, `literature`,
      `memory`, `typst`. Record the three-way result (`FRESH` / `STALE` / `CANNOTVERIFY`) for each.
      *(completed: all six returned FRESH)*
- [x] Run the actual advisory consumer: `bash .claude/scripts/check-deploy-freshness.sh`. Record
      its exit code and any `WARN:` output. *(completed: exit 0, no WARN output)*
- [x] Treat a `CANNOTVERIFY` result as neither pass nor fail: it means the probe could not reach a
      conclusion (missing field, non-git source_dir, missing `jq`/`git`). If any extension returns
      `CANNOTVERIFY`, record which and why, and carry that forward to Phase 2 as an explicitly
      unverified extension rather than reporting it as fresh. *(completed: no extension returned
      CANNOTVERIFY)*
- [x] Record the verdict for Phase 2: `redeploy_needed = true` if any of the six returns `STALE`
      or `check-deploy-freshness.sh` emits any `WARN:`; otherwise `false`. *(completed:
      redeploy_needed = false)*

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: All six extensions are expected to return `FRESH` and
`check-deploy-freshness.sh` to exit 0 silently — this was observed directly at plan-authoring
time, so `redeploy_needed` is hypothesised to be `false`. This is a hypothesis about a
time-varying condition, not a fact: the implementer confirms it by actually running both probes
above and must not skip them on the strength of this note. A `STALE` result here is a normal
outcome, not a contradiction of the plan.

**Tier Justification**: This phase edits no file at all — its only outputs are read-only probe
results recorded in the dispatch narrative — and `bash .claude/scripts/check-deploy-freshness.sh`
is itself the covering check, exercising exactly the surface the phase reads.

**Files to modify**:

- None. This phase is read-only.

**Verification**:

- A recorded three-way status for each of the six named extensions, with no extension left
  unqueried.
- A recorded exit code and WARN output (or explicit absence of WARN output) from
  `check-deploy-freshness.sh`.
- An explicit `redeploy_needed` verdict (`true` or `false`) stated before Phase 2 begins.

---

### Phase 2: Conditionally Redeploy and Discharge the Full Deploy Gate [NOT STARTED]

**Goal**: Bring the deployed tree to a verified-fresh state (redeploying only if Phase 1 found
drift) and discharge the complete `verify-deploy.sh` gate set that the research dispatch
deliberately scoped out, closing the task.

**Tasks**:

- [ ] If and only if Phase 1 recorded `redeploy_needed = true`, run the sanctioned regeneration
      under the bounded-wait idiom: `timeout 540 bash .claude/scripts/deploy-headless.sh` with the
      Bash tool `timeout` parameter set to `600000` (per `context/patterns/external-process-wait.md`
      Rule 1). Use the default, non-destructive mode — not `--wipe`. Confirm the run ends with
      `RESULT=landed_verify_clean`.
- [ ] If Phase 1 recorded `redeploy_needed = false`, skip the redeploy and state in the dispatch
      narrative that it was skipped and why. Do not run it reflexively.
- [ ] Re-run `bash .claude/scripts/check-deploy-freshness.sh` and confirm exit 0 with no `WARN:`
      output, so the `skill-base.sh` per-dispatch staleness warning is confirmed silent through
      its real consumer surface.
- [ ] Run the complete gate set: `timeout 540 bash .claude/scripts/verify-deploy.sh` (no
      `--skip-slow`, no `--only-gate` filter), again with the Bash tool `timeout` parameter at
      `600000`. Record the reported check count and failure count.
- [ ] Interpret the result correctly: in this repository, gates 3, 5, 6, 7, 9–13, 15, and 17–29
      are expected to `[SKIP]` because this is a deploy *consumer*, not the source store. Judge
      pass/fail on the reported failure count being zero, never on the SKIP count. Do not attempt
      to make a SKIPped gate run.
- [ ] Do not hand-edit any file under `.claude/**` at any point. If a residual WARN or gate
      failure persists after a redeploy, record it and surface it as a blocker rather than
      patching the deployed tree.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: The redeploy branch is hypothesised to be skipped (Phase 1 expected to find
no drift), leaving this phase as verification only; the implementer confirms by reading Phase 1's
recorded `redeploy_needed` verdict, not by assuming either branch. Separately, the enumerated SKIP
gate list above is drawn from the research report's observation of a prior run and is a hypothesis
about this run's output — confirm it against the actual `verify-deploy.sh` output rather than
asserting it, and record any divergence.

**Files to modify**:

- `__WHOLE_TREE__` - this phase conditionally invokes `deploy-headless.sh`, which regenerates the
  entire deployed `.claude/` tree from the source store. The reserved sentinel declares that
  whole-tree claim so a concurrently-admitted task that would also regenerate the tree is
  serialized against this one.

**Verification**:

- The complete gate set has been run in this dispatch and observed green: `bash
  .claude/scripts/verify-deploy.sh` (full run, no `--skip-slow` and no gate filter) reports zero
  failures. This is the `full` tier's named gate aggregator, run in its entirety.
- `bash .claude/scripts/check-deploy-freshness.sh` exits 0 with no `WARN:` output.
- Every one of the six named extensions (core, formal, lean, literature, memory, typst) returns
  `FRESH` from `deploy_freshness_status`, with no extension left at `STALE` or `CANNOTVERIFY`.
- If the redeploy branch ran, its final line reported `RESULT=landed_verify_clean`.
- No file under `.claude/**` was edited by hand during this phase.

---

## Testing & Validation

- [ ] All six named extensions report `FRESH` from `deploy_freshness_status`.
- [ ] `bash .claude/scripts/check-deploy-freshness.sh` exits 0 with no `WARN:` output.
- [ ] `bash .claude/scripts/verify-deploy.sh` (full run, no `--skip-slow`) reports zero failures.
- [ ] If a redeploy ran, it reported `RESULT=landed_verify_clean`.
- [ ] `git status --porcelain` shows no tracked change under `.claude/**` (the tree is gitignored);
      any change shown there would indicate a hand-patch and is a failure condition.

## Artifacts & Outputs

- `specs/907_redeploy-stale-claude-tree/plans/01_redeploy-stale-claude-tree.md` (this plan).
- `specs/907_redeploy-stale-claude-tree/summaries/01_redeploy-stale-claude-tree-summary.md`
  (produced at implementation completion).
- A regenerated `.claude/` tree, if the conditional redeploy branch fires. This is **not** a
  tracked output: `.claude/` and `.claude-extensions.json` are gitignored, so the implementation
  produces no tracked diff outside `specs/**`. An empty tracked diff for the deploy itself is the
  expected, correct outcome — not evidence that nothing happened.

## Rollback/Contingency

The deployed `.claude/` tree is a disposable, regenerable artifact: there is nothing to roll back
in git, because nothing this task touches outside `specs/**` is tracked. If a redeploy leaves the
tree in a worse state than it started, the remedy is another regeneration, not a git revert — re-run
`timeout 540 bash .claude/scripts/deploy-headless.sh` (bounded-wait idiom, Bash tool `timeout`
600000). If repeated default-mode redeploys fail to reach `RESULT=landed_verify_clean` or fail to
clear the staleness warning, stop and surface the failure as a blocker with the captured output;
escalating to `--wipe` is a destructive mode change that is out of scope for this plan and must not
be taken unilaterally. Under no circumstance is hand-editing a deployed `.claude/**` file an
acceptable contingency: it would mask the divergence this task exists to resolve.
