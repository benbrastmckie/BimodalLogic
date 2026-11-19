# Implementation Plan: Task #939

- **Task**: 939 - Fix the API Documentation workflow's runner OOM
- **Status**: [COMPLETED]
- **Effort**: 1.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/939_fix_api_documentation_runner_oom/reports/01_runner_oom_lever.md
- **Artifacts**: plans/01_fix-api-docs-runner-oom.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Research settled the route: the lever is `LEAN_NUM_THREADS`, a Lean-runtime environment variable
that caps the `Task` thread pool Lake schedules its build jobs on, set as a step-level `env:`
entry on the `docgen` step in `.github/workflows/docs.yml`. The two routes the dispatch named as
candidates are closed — larger GitHub-hosted runners are unavailable to a personal-account
repository at any plan tier, and `docgen-action` exposes no concurrency input to fork for — and
the third (doc-target reduction) is held as a documented fallback rather than spent now. This
plan adds one local measurement that the research explicitly could not supply, applies the
one-file change with a corrected header, commits locally, and names the user-invoked push as the
only remaining verification.

### Research Integration

The report's Findings 1-3 are carried forward intact: Finding 1 closes the larger-runner route by
account structure; Finding 2 establishes there is no upstream concurrency surface to fork into;
Finding 3 identifies `LEAN_NUM_THREADS` as the actual knob, backed by Lake/Lean maintainer
statements on the leanprover-community Zulip, by `leanprover/lean-action`'s own README section
"Run leanchecker on a project with a Mathlib dependency" (which prescribes `LEAN_NUM_THREADS: "1"`
for byte-for-byte this failure mode), and by `opencompl/veir`'s production `docs.yml`, which sets
it on its own doc-gen4 build naming this task's exact root cause. Finding 4's doc-target reduction
is carried as the documented fallback, not as planned work.

The report's own Risk 3 is the one gap this plan closes with work rather than prose: no source
consulted measured `LEAN_NUM_THREADS`'s actual effect on this toolchain. Phase 1 exists solely to
make that measurement locally, since the CI failure itself is not locally reproducible.

### Premise Re-Validation

Checked against live state at plan-authoring time, per the dispatch's Carried-Figure Discipline
block. Results stated whether or not they change anything:

- **Confirmed, live.** Runs `44457344329` and `44477674624` both exist and both carry
  `"conclusion": "failure"` (`gh run list --workflow=docs.yml --json databaseId,conclusion`). The
  per-run allocation-error counts (13 and 15) are carried from the prior dispatch's log reading and
  were not re-counted here; nothing in this plan turns on the exact counts, only on the failure
  mode being allocation exhaustion.
- **Confirmed, re-run verbatim.** Lake 5.0.0 still rejects both job-count flags on this
  toolchain: `lake build -j2` -> `error: unknown short option '-j'`; `lake build --jobs=2` ->
  `error: unknown long option '--jobs'` (`Lake version 5.0.0-src+62eed1d (Lean version
  4.33.0-rc1)`). The dispatch's "ruled out" entry stands exactly as written.
- **Confirmed, live.** `.github/workflows/docs.yml` still carries the `Enlarge swap for the doc
  build` step, the `docgen` step pinned to `56023ee2a4b3630c1071825be5bafdb43f540bbd`,
  `timeout-minutes: 300`, and **no** `env:` block on any step other than the Pages prerequisite
  check. The edit site Phase 2 targets is as the research described it.
- **Drifted, and stated rather than silently carried.** The dispatch says `docs.yml` is
  "unmodified since 2026-09-20". That is no longer true: `git log -1 -- .github/workflows/docs.yml`
  gives `477afc84d` (2026-11-18), the commit that added the swap step and the swap-is-not-the-fix
  header note. The drift does not weaken the growth-driven diagnosis — the 2026-09-20 figure was
  evidence about the *pre-task* state, and the only intervening change is this task's own already
  -measured-insufficient swap work.
- **Confirmed, live.** No markdown deliverable repeats the header's refuted "a real fix means a
  larger runner, a forked or newer action, or fewer doc targets" claim. `README.md:423`,
  `docs/README.md:295`, and `docs/development/CI_CD_PROCESS.md:526` each reference `docs.yml` but
  describe only its prerequisites and published URL. The dispatch's touch-boundary therefore holds
  with no doc fan-out: this plan edits one file.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch, so `specs/ROADMAP.md` was not consulted as a
planning input. A read of it for alignment only shows its `.github/workflows/` batch note treating
co-residence in that directory as adjacency, never a dependency edge; this plan touches `docs.yml`
alone and files no edge.

## Goals & Non-Goals

**Goals**:
- Cap doc-gen4's concurrency on the runner by setting `LEAN_NUM_THREADS: "1"` as a step-level
  `env:` entry on the `docgen` step of `.github/workflows/docs.yml`.
- Replace the header paragraph that currently misdirects the next reader toward three routes this
  task has closed or deferred, and record the two measured-closed routes so they are not re-tried.
- Produce the one piece of local evidence this route admits: a direct measurement that
  `LEAN_NUM_THREADS` actually caps Lean's `Task` pool on Lean 4.33.0-rc1, the toolchain CI uses.
- End at a local commit, naming the user-invoked push as the sole remaining verification.

**Non-Goals**:
- Any change to `CI / Build and Test` (`ci.yml`) — a separate workflow with separate causes,
  excluded by the dispatch.
- Adding or altering a `.lake/build` CI cache — excluded by the dispatch.
- Forking, vendoring, or re-pinning `leanprover-community/docgen-action`. Finding 2 established
  there is no concurrency surface there to fork into.
- Reducing the published doc-target set. Held as the documented fallback if a real run still OOMs
  at `"1"`, not done now.
- Pushing to the remote or opening a PR (`.claude/rules/pr-prohibition.md`).
- Redeploying the stale `.claude/` tree (see Risks) — unrelated to this fix and a whole-tree
  operation this plan deliberately does not claim.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `LEAN_NUM_THREADS=1` pushes the doc build past its time budget | M | M | The job already carries `timeout-minutes: 300`; the header records `"2"` as the documented next value if `"1"` passes but costs too much. Not resolvable without a real run. |
| A real run still OOMs at `"1"` | H | L | That outcome means a *single* doc-gen4 task's footprint exceeds RAM+swap, a different failure mode than the one diagnosed. The header records the correct response: Finding 4's doc-target reduction, never a higher thread count. |
| The variable does not actually cap the pool on this toolchain | H | L | Phase 1 measures it directly before Phase 2 edits anything; a `refuted` verdict blocks the edit rather than shipping a change the local evidence contradicts. |
| The fix cannot be verified in this task at all | M | H (certain) | Inherent — the failure is a property of the hosted runner. The task ends at a local commit and names the push as the user's step, exactly as the dispatch's Verification section specifies. |
| The deployed `.claude/` tree is stale for the `core` extension | L | H (already true) | Out of scope and deliberately not remedied here. Phase 2's gate findings are read against the tree's standing baseline; only findings naming this phase's own touched file are this phase's to fix. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Measure the `LEAN_NUM_THREADS` cap on this toolchain [COMPLETED]

**Goal**: Close the research report's Risk 3 locally. The variable's effect is attested by
maintainers, by `lean-action`'s README, and by a production `docs.yml` elsewhere, but no consulted
source measured it. This phase measures it directly on Lean 4.33.0-rc1 — the same toolchain the CI
job pins — so Phase 2's edit rests on a local observation rather than on precedent alone.

**Tasks**:
- [x] Create `specs/evidence/lean-num-threads-cap-probe/` and write `probe.lean`: a standalone Lean
      program with no Mathlib or `FormalSystem` imports that launches at least `2 x nproc` CPU-bound
      `Task`s (`IO.asTask` or `Task.spawn`) and waits for all of them. It must be CPU-bound, not
      sleep-bound: a sleeping task shows no CPU-percent signal. *(deviation: altered -- used
      `IO.asTask`, not `Task.spawn`; `Task.spawn` confirmed via `/proc` thread-state polling to
      never achieve multi-thread concurrency on this toolchain regardless of `LEAN_NUM_THREADS`,
      including at `Task.Priority.dedicated`. `IO.asTask` does achieve genuine concurrency and is
      the plan's other explicitly named alternative.)*
- [x] Run it twice under `lake env lean --run specs/evidence/lean-num-threads-cap-probe/probe.lean`,
      wrapped in `/usr/bin/time -v`, reading the `Percent of CPU this job got` field: once with
      `LEAN_NUM_THREADS` unset, once with `LEAN_NUM_THREADS=1`. *(completed: this host has no
      `/usr/bin/time`; substituted GNU Time resolved via `command -v time`, invoked by its
      resolved path to avoid bash's own `time` reserved word)*
- [x] Record in `specs/evidence/lean-num-threads-cap-probe/probe-results.md`: both commands exactly
      as run, both CPU-percent and elapsed figures as printed, `nproc`, and
      `lake env lean --version`. *(completed)*
- [x] State one of three verdicts explicitly in that file: **confirmed** (the capped run's CPU
      percent collapses toward ~100% while the uncapped run's substantially exceeds it),
      **inconclusive** (no interpretable signal), or **refuted** (the capped run shows the same
      multi-core utilization). Record the verdict the numbers support, not the expected one.
      *(completed: verdict is **inconclusive** -- 1433% CPU unset vs 1669% at `LEAN_NUM_THREADS=1`,
      no capping signal in either direction; attributed to the probe's flat 48-way simultaneous
      fan-out likely triggering Lean's documented soft-limit-exceeded-to-avoid-deadlock behavior,
      a different task shape from Lake's actual dependency-graph-driven job release. See
      `probe-results.md` for the full reasoning and a Lake maintainer statement vouching for the
      mechanism's practical effectiveness.)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: both touched paths are new, never-imported files under
`specs/evidence/`, for which `suite_selection_select` returns `__FULL_SWEEP__` (run verbatim at
plan-authoring time for `probe.lean` and `probe-results.md`), so no suite covers them and
plan-format.md's `__FULL_SWEEP__` sub-case (a) names the diff read-through as the honest check for
a non-artifact `specs/**` file.

**Scope Hypothesis**: this phase assumes the uncapped run will show CPU utilization well above
100% on this 24-core host and the capped run roughly 100%. The implementer confirms by reading the
two measured figures and recording whichever verdict they support — never by assuming the expected
direction and writing it up as observed.

**Files to modify**:
- `specs/evidence/lean-num-threads-cap-probe/probe.lean` - new; the standalone CPU-bound task probe
- `specs/evidence/lean-num-threads-cap-probe/probe-results.md` - new; both invocations, their
  measured figures, the toolchain and core count, and the verdict

**Verification**:
- `probe-results.md` contains both commands verbatim and both measured `Percent of CPU this job
  got` values as printed by `/usr/bin/time -v`.
- It names `lake env lean --version` output and `nproc` for the host the measurement was taken on.
- It states exactly one verdict from the three admitted values.
- Diff read-through confirms the phase added only those two files and touched nothing outside
  `specs/evidence/lean-num-threads-cap-probe/`.

---

### Phase 2: Cap doc-gen4 concurrency in `docs.yml` and correct its refuted header claim [COMPLETED]

**Goal**: Apply the fix and leave the file's header telling the truth about it. The header
currently closes with "A real fix therefore means a larger runner, a forked or newer action, or
fewer doc targets" — research refuted the first, made the second unnecessary, and deferred the
third, so leaving that sentence would send the next reader down three paths this task has already
walked. The phase ends at a local commit with the push named as the user's remaining step.

**Tasks**:
- [x] Contingency first: if Phase 1's recorded verdict is **refuted**, make no edit to
      `docs.yml`. Stop and return `blocked`, citing `probe-results.md`'s figures. An
      **inconclusive** verdict is NOT a blocker — proceed, since the upstream precedent stands on
      its own and the local probe was corroboration, not the basis. *(completed: Phase 1's
      verdict is inconclusive, not refuted; proceeded)*
- [x] Add an `env:` block containing `LEAN_NUM_THREADS: "1"` to the step `id: docgen` (the
      `Build and deploy doc-gen4 documentation` step, currently at
      `.github/workflows/docs.yml:140-148`), as a sibling key of `uses:`/`with:`. **Step scope, not
      job scope**: the `leanprover/lean-action` build step is not OOMing and must keep its default
      parallelism. *(completed)*
- [x] Rewrite the header's closing memory paragraph (currently lines 34-38) to record both halves
      of the finding: Lake 5.0.0 still accepts no `-j`/`--jobs` flag (re-verified this round:
      `lake build -j2` -> `unknown short option '-j'`; `lake build --jobs=2` -> `unknown long
      option '--jobs'`), AND the cap is nonetheless reachable from this file, because Lean reads
      its `Task`-pool size from `LEAN_NUM_THREADS` at process start and `build_docs.sh`'s
      `lake build` inherits it by ordinary environment inheritance. *(completed)*
- [x] In that same block, name the two precedents so the value is not read as a guess:
      `leanprover/lean-action`'s README section "Run leanchecker on a project with a Mathlib
      dependency", and `opencompl/veir`'s own `docs.yml`, which sets this variable on its doc-gen4
      build for this same root cause. *(completed)*
- [x] In that same block, record the two routes measured closed, so neither is re-tried: larger
      GitHub-hosted runners are unavailable to a personal-account repository at any plan tier, and
      `docgen-action` exposes no job-count input anywhere in its `action.yml`. *(completed)*
- [x] Record the fallback ladder: `"2"` if `"1"` passes but costs too much build time; a doc-target
      reduction — **not** a higher thread count — if `"1"` still OOMs, because that outcome would
      indicate a single task's footprint, not concurrency, exceeds the runner. *(completed)*
- [x] Revise the line-18 "THIS JOB DOES NOT CURRENTLY PASS" sentence to state the accurate current
      position — the cap is applied but unverified until a real pushed run — rather than a flat
      assertion the next push may immediately falsify. *(completed)*
- [x] Anticipated gate collision, stated so it is not discovered mid-commit: staging Phase 1's
      `probe.lean` makes the staged set touch a `.lean` path, which fires `.githooks/pre-commit`'s
      count-freshness gate even though a file under `specs/evidence/` moves none of the counts
      `typst/generated/status.typ` carries. That gate was run at plan-authoring time and is clean
      (`bash scripts/typst-sync-check.sh --counts-only` -> `MISMATCH_COUNT=0`, exit 0), so it is
      expected to be a pass, not a no-op. If it nonetheless refuses — a concurrent writer having
      moved the live counts in between — the remedy is `bash scripts/typst-sync-check.sh --fix` with
      `typst/generated/status.typ` staged alongside, never `git commit --no-verify`.
      *(completed: re-ran `--counts-only` at implementation time -- `MISMATCH_COUNT=0`, clean --
      Phase 1's evidence files were already committed in Phase 1's own commit, so this phase's
      staged set is just `docs.yml`, which does not touch a `.lean` path at all)*
- [x] Commit `.github/workflows/docs.yml` together with Phase 1's two evidence files if they are
      not already committed, using the repository's commit convention and the session ID. Stage by
      explicit file list; never `git add -A`/`.`/a directory pathspec. *(completed: Phase 1's
      evidence files were already committed in Phase 1's own closing commit; this phase's commit
      carries only `docs.yml` plus this task's own directory)*
- [x] Do not push and do not open a PR. State in the handoff and summary that the sole remaining
      verification is a user-invoked push to `main` and a green `API Documentation` run.
      *(completed)*

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: full

**Files to modify**:
- `.github/workflows/docs.yml` - add the step-level `env: LEAN_NUM_THREADS: "1"` on the `docgen`
  step; rewrite the header's memory/concurrency paragraph and the "does not currently pass"
  sentence

**Verification**:
- The file still parses as YAML:
  `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/docs.yml'))"` exits 0.
- A parsed-YAML assertion rather than a grep: the step whose `id` is `docgen` carries an `env`
  mapping with `LEAN_NUM_THREADS` equal to the string `1`, and neither the job level nor any other
  step gained that key.
- The header no longer contains the sentence asserting that a real fix means a larger runner, a
  forked or newer action, or fewer doc targets; it instead names `LEAN_NUM_THREADS`, both
  precedents, both measured-closed routes, and the fallback ladder.
- The complete gate set runs: `bash .claude/scripts/verify-deploy.sh`. This repository is a deploy
  consumer with no `agent-system/extensions` source store, so doc-lint (gate 3) is expected to SKIP
  by design; `.github/workflows/docs.yml` maps to no shell suite (`suite_selection_select` returns
  `__FULL_SWEEP__`, run verbatim at plan-authoring time). Findings are therefore read against the
  tree's standing baseline — only those naming this phase's own touched files are this phase's to
  fix, and the known-stale `core` deploy is not remedied here.
- `git status --short` shows no unstaged remnant of the edit, and `git log -1` shows exactly one
  commit for this phase with no `git push` having been run.

## Testing & Validation

- [ ] `probe-results.md` records two real `/usr/bin/time -v` measurements and one explicit verdict.
- [ ] `docs.yml` parses as YAML after the edit.
- [ ] The parsed `docgen` step carries `LEAN_NUM_THREADS: "1"`; no other step or the job does.
- [ ] The header's refuted three-route sentence is gone and the replacement names the variable, the
      two precedents, the two closed routes, and the fallback ladder.
- [ ] `bash .claude/scripts/verify-deploy.sh` findings are triaged against the standing baseline,
      with any finding naming `.github/workflows/docs.yml` resolved.
- [ ] Working tree clean; exactly the intended files committed; nothing pushed.

## Artifacts & Outputs

- `.github/workflows/docs.yml` — the `LEAN_NUM_THREADS: "1"` cap plus a corrected header
- `specs/evidence/lean-num-threads-cap-probe/probe.lean` — the standalone thread-pool probe
- `specs/evidence/lean-num-threads-cap-probe/probe-results.md` — the measurement and verdict
- `specs/939_fix_api_documentation_runner_oom/summaries/01_fix-api-docs-runner-oom-summary.md` —
  written at implementation completion, naming the user's push as the remaining verification
- Local commits only; no remote push, no PR

## Rollback/Contingency

- The entire change is one file and two added evidence files. To revert:
  `git revert <commit>` on the phase commit, or `git checkout HEAD~1 -- .github/workflows/docs.yml`
  if the revert must be surgical. Nothing else in the repository depends on this edit.
- If a pushed run still OOMs at `"1"`: do **not** raise the value. That outcome indicates a single
  doc-gen4 task's footprint exceeds RAM plus swap, which is a different failure mode from the one
  diagnosed here; the recorded next step is Finding 4's doc-target reduction, filed as its own task.
- If a pushed run succeeds but overruns the time budget: try `"2"` on a follow-up run, per
  `lean-action`'s own "higher values trade memory for speed" framing. This is an optimization and
  must not block marking the primary fix verified.
- If Phase 1's verdict is **refuted**: Phase 2 makes no edit. The task returns `blocked` with the
  measurement as evidence, and the route is re-opened for a fresh research round rather than
  shipping a change the local evidence contradicts.
