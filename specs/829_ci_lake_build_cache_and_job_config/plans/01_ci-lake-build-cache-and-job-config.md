# Implementation Plan: Task #829

- **Task**: 829 - Ci lake build cache and job config
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/829_ci_lake_build_cache_and_job_config/reports/01_ci-lake-build-cache-and-job-config.md
- **Artifacts**: plans/01_ci-lake-build-cache-and-job-config.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The task was filed with two ordered deliverables: (a) add an `actions/cache` step for
`.lake/build`, and (b) give `ci.yml`'s `build` job a `timeout-minutes` for parity with `docs.yml`.
Research refuted (a) on live evidence: `leanprover/lean-action@v1` — which all three workflows
invoke — ships its own `actions/cache/restore` + `actions/cache/save` pair around the entire
`.lake` directory with `use-github-cache` defaulting to `true`, none of the three workflows
overrides it, and this repository's Actions cache store currently holds live `lake-Linux-X64-…`
entries that a completed `ci.yml` run log shows being restored. Adding a second, separately-keyed
cache step on the same path would duplicate compression/upload cost and cache-quota consumption
for no coverage gain.

What therefore remains is small and entirely additive: deliverable (b) as filed, plus durable
documentation of the caching mechanism's one real limitation (the save snapshot is taken inside
the single `lean-action` step, so `ci.yml`'s four later `lake build` invocations are not covered),
so the next reader grepping `.github/workflows/` for `actions/cache` does not re-derive the same
wrong conclusion. One stale count in `lakefile.toml`'s own comments is corrected while that
in-scope file is open. No build-performance configuration is added to `lakefile.toml` and no
matrix split is attempted — both are MEASURED EXPERIMENTS under the task's own GUARDRAIL and
neither has a before/after timing.

### Carried-Figure Re-Validation

The dispatch flagged two description lines for premise re-validation. Both were checked live at
plan time; results stated explicitly even where they only confirm or only drift:

| Figure as filed (2026-11-02) | Live at plan time (2026-11-18) | Disposition |
|------------------------------|--------------------------------|-------------|
| 716 `FormalSystem` modules | 772 | Drifted upward (library growth) |
| 371,441 lines | 416,312 | Drifted upward |
| `.lake/build` 6.3 GB | 6.4 GB | Drifted slightly upward |
| `Metalogic/Decidability/` 179 files / 106,266 lines | 186 / 127,509 | Drifted upward |
| `Metalogic/Expressiveness/` 143 files / 104,211 lines | 157 / 111,856 | Drifted upward |
| No `actions/cache`/`restore-keys`/`use-github-cache` literal under `.github/workflows/` | Still absent | Confirmed unchanged |
| `timeout-minutes` set only at `docs.yml:57` (value 300) | Confirmed; `ci.yml`'s `build` job keys are exactly `name`, `runs-on`, `steps` | Confirmed unchanged |
| `lakefile.toml` carries zero build-performance configuration | Confirmed: no `moreLeanArgs`, `precompileModules`, `extraDepTargets`, parallelism or memory key anywhere in the file | Confirmed unchanged |
| 15-target `lean_exe` root loop | Confirmed: `python3 scripts/lake_targets.py exe-roots` yields 15; `grep -c '^\[\[lean_exe\]\]' lakefile.toml` yields 15 | Confirmed unchanged |

Every drift is in the direction that strengthens the task's motivation rather than weakening it,
so no plan decision turns on it. The figures above are restated from a live measurement, not
copied forward; a further re-measurement at implementation time is expected to differ again and
that is not a defect.

### Research Integration

Three findings drive this plan directly:

1. **Deliverable (a) is already satisfied by default.** `lean-action@v1`'s composite steps
   restore and save `${lake-package-directory}/.lake` keyed
   `lake-${runner.os}-${runner.arch}-${hashFiles(lean-toolchain)}-${hashFiles(lake-manifest.json)}-${github.sha}`
   with a sha-less `restore-keys` fallback. The dispatch's own ACCEPTANCE criterion ("a second CI
   run on an unchanged tree restores from cache rather than re-elaborating, visible in the run
   log") is therefore met today, confirmed in a completed run's log. This plan does NOT add a
   redundant cache step.
2. **A narrower, real gap survives**: the `actions/cache/save` runs inside the `lean-action` step,
   before `ci.yml`'s `Compile lean_exe roots` loop, `lake build BimodalTools --wfail`, and
   `lake build BimodalToolsTest --wfail`. Their `.lake/build` output is written after the snapshot
   and is never persisted. Closing this requires setting `use-github-cache: false` and
   hand-rolling a job-wide restore/save pair — a cache-lifecycle architecture change with no
   measurement behind it, which the GUARDRAIL puts out of scope here. It is recorded, not landed.
3. **Deliverable (b) is unaffected** by either of the above and lands as filed.

One research claim was itself corrected at plan time. The report's Context Extension
Recommendation states `docs/development/CI_CD_PROCESS.md` "does not currently document" the
default-on cache. It partially does: a `### GitHub Actions Cache` section exists at line 366 and
already gives the primary/fallback key shape and the `use-github-cache: false` disable switch.
What it omits is the per-job save boundary from finding 2 and any pointer for re-verifying the
live cache. Phase 2 therefore **amends that existing section** rather than adding a second one.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch, and `roadmap_flag` is not set; ROADMAP.md was
not consulted and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- `ci.yml`'s `build` job declares `timeout-minutes: 300`, matching `docs.yml:57`.
- `docs/development/CI_CD_PROCESS.md`'s existing `### GitHub Actions Cache` section records (i)
  that `lean-action`'s `use-github-cache` defaults to `true` and caches the whole `.lake`
  directory, (ii) that the save snapshot is taken inside that single step so any later
  `lake build` in the same job is uncovered, and (iii) how to re-verify the live cache entries.
- `lakefile.toml`'s tooling-library comment states the correct `lean_exe` target count.
- No change to what any CI check step verifies.

**Non-Goals**:
- Adding any `actions/cache`, `actions/cache/restore`, or `actions/cache/save` step to any
  workflow. Deliverable (a) as literally filed is superseded by research; implementing it would
  duplicate an existing cache on the same path.
- Setting `use-github-cache: false` anywhere, or re-implementing a job-wide cache lifecycle by
  hand. That is the residual-gap fix, deferred as a measured experiment.
- Adding `moreLeanArgs`, `precompileModules`, `extraDepTargets`, or any parallelism/memory
  setting to `lakefile.toml`. GUARDRAIL: no before/after timing exists.
- Adding `strategy:`/`matrix:` to `ci.yml`, or splitting the build along the
  `Metalogic/Decidability/` ÷ `Metalogic/Expressiveness/` seams. Same GUARDRAIL.
- `timeout-minutes` on `release.yml`'s `release` job (also absent) — outside this task's FILE
  SCOPE, noted by research as ancillary only.
- Touching `.claude/context/project/lean4/operations/long-builds.md`,
  `multi-instance-optimization.md`, or `lake-build-guard.sh`. Explicitly NOT IN SCOPE per the
  dispatch, and they live in the source store, not this repository.
- Editing the quoted historical gate output `FAIL C25  1 of 13 lean_exe root module(s)…` in
  `scripts/check-module-invariants.sh:4947` or `docs/development/MODULE_INVARIANTS.md:309`. Those
  are verbatim records of an observation, not live count claims, and must stay as observed.

## Scope Note: One File Beyond the Declared FILE SCOPE

The dispatch declares FILE SCOPE as `.github/workflows/ci.yml` and `lakefile.toml`. This plan adds
one file: `docs/development/CI_CD_PROCESS.md`. The justification is that research's central
finding is a *documentation* failure — a contributor grepping `.github/workflows/` reaches a
confidently wrong conclusion about caching, which is exactly how this task came to be filed with a
refuted deliverable (a) — and that file is where this repository already documents its caching
strategy. The addition changes no executable surface and no check behavior. An implementer who
judges the expansion unwarranted may drop Phase 2's documentation task and close the task on Phase
1 alone; Phase 3 then records the omission rather than treating it as a gap.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer follows the filed description rather than this plan and adds the redundant `actions/cache` step | M | M | The Non-Goals block above names the prohibition first and explicitly; Phase 3's verification asserts the absence of any `actions/cache` literal under `.github/workflows/` after the task's edits, so a stray addition fails the final phase |
| Concurrent sibling task 938 (`plan` phase, `file_scope` undeclared, so it may touch any file) edits one of these three files on this shared working tree | M | M | Re-read each file immediately before editing it; stage only this task's own explicit file list, never a directory or glob; treat a foreign commit or foreign uncommitted modification as a STOP-and-report condition after checking `git log` to confirm it is not this task's own work; never run `git-snapshot.sh` in its reverting default mode |
| `timeout-minutes: 300` turns out to be tighter than a genuinely slow cold-cache run needs, converting a 360-minute inheritance into a failure | L | L | 300 is `docs.yml`'s own measured-in-production value on the same runner class for a superset of work (build plus docgen), and typical `ci.yml` runtime is 7-10 minutes per `CI_CD_PROCESS.md`; the margin is roughly 30x. Phase 3 records the value and its source so a future adjustment has a stated baseline |
| Documentation amendment introduces a broken relative reference | L | L | `scripts/readme-lint.sh` Check 3 (broken relative refs) is the relevant check; CI runs it only over `FormalSystem BimodalTools`, so Phase 2 runs `bash scripts/readme-lint.sh docs` itself as a baseline-delta check rather than relying on CI |
| The residual gap (uncovered `BimodalTools`/`BimodalToolsTest`/`lean_exe` artifacts) is forgotten once this task closes | M | M | Phase 2 writes the mechanism into `CI_CD_PROCESS.md`, where it is durable and discoverable independent of task records; Phase 3 additionally records it in the summary as a named follow-up candidate |
| `lean-action`'s cache semantics change under the moving `v1` tag, invalidating the documentation added in Phase 2 | L | L | Phase 2's wording states the behavior as `lean-action@v1`'s at the time of writing and includes the `gh api repos/<owner>/<repo>/actions/caches` re-verification pointer, so a future reader can check rather than trust |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint files and
have no ordering constraint between them.

### Phase 1: `timeout-minutes` Parity on `ci.yml`'s Build Job [COMPLETED]

**Goal**: `ci.yml`'s `build` job declares `timeout-minutes: 300`, matching `docs.yml:57`, so it no
longer inherits GitHub's 360-minute default. This is the task's deliverable (b) and the only
functional change in the plan.

**Tasks**:
- [x] Re-read `.github/workflows/ci.yml` immediately before editing (sibling task 938 may have
      touched it), and re-confirm the `build` job still lacks `timeout-minutes`:
      `python3 -c "import yaml; print(sorted(yaml.safe_load(open('.github/workflows/ci.yml'))['jobs']['build'].keys()))"`
      — expected before the edit: `['name', 'runs-on', 'steps']`. *(completed: confirmed, no sibling drift)*
- [x] Add `timeout-minutes: 300` to the `build` job, as a sibling key of `runs-on` (currently
      `.github/workflows/ci.yml:19`), placed between `runs-on` and the blank line preceding
      `steps:` so the job header reads `name` / `runs-on` / `timeout-minutes`. *(completed)*
- [x] Add a one-line comment above it recording where the value comes from: parity with
      `docs.yml`'s `docs` job, which sets the same 300 on the same runner class for a superset of
      work. Cite `docs.yml` by filename and job name, not by line number. *(completed)*
- [x] Confirm the file still parses and the key is now present with the intended value:
      `python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/ci.yml'))['jobs']['build']; print(sorted(d.keys()), d['timeout-minutes'])"`
      — expected `['name', 'runs-on', 'steps', 'timeout-minutes'] 300`. *(completed: matches)*
- [x] Confirm no other job key changed and no step was disturbed:
      `git diff -- .github/workflows/ci.yml` shows exactly the added `timeout-minutes` line plus
      its comment line, and nothing else. *(completed: diff is exactly 3 added lines — timeout-minutes plus a 2-line comment)*
- [x] Commit this phase's single file with the scoped-staging flow
      (`git status --short`, `git diff --staged` review, explicit single-path `git add --`). *(completed)*

**Timing**: 0.3 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts it touches exactly one file
(`.github/workflows/ci.yml`) and that its `build` job currently has exactly three keys
(`name`, `runs-on`, `steps`), measured live at plan time with the `yaml.safe_load` command above.
Confirm at implementation time by re-running that same command before editing; if the key set has
changed (a sibling's edit, or a `timeout-minutes` already added), stop and report rather than
layering a second declaration.

**Tier Justification**: The edit adds one job-level key to one file with no effect on any step,
and the covering check is `bash .claude/scripts/verify-touched.sh .github/workflows/ci.yml`,
measured at plan time to resolve that path to the single suite
`test-lint-roadmap-batch-proposals.sh` (not the `__FULL_SWEEP__` sentinel), run alongside the
`local` tier's own single-file lint, here the `yaml.safe_load` parse of the edited file.

**Files to modify**:
- `.github/workflows/ci.yml` - add `timeout-minutes: 300` to the `build` job, with a one-line comment recording the `docs.yml` parity source

**Verification**:
- `python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/ci.yml'))['jobs']['build']; print(sorted(d.keys()), d['timeout-minutes'])"`
  prints `['name', 'runs-on', 'steps', 'timeout-minutes'] 300`.
- `grep -n "timeout-minutes" .github/workflows/*.yml` lists both `ci.yml` and `docs.yml:57`, each
  at 300.
- `git diff -- .github/workflows/ci.yml` contains only the two added lines; every existing step,
  input, and comment is byte-identical.
- `bash .claude/scripts/verify-touched.sh .github/workflows/ci.yml` exits 0, with its printed
  verdict recorded. Per the repo-wide-lint rule this is read as a baseline delta: a pre-existing
  finding naming no file this phase touched is a recorded PASS, enumerated rather than fixed, and
  only a finding naming `.github/workflows/ci.yml` blocks the phase.

---

### Phase 2: Document the Real Cache Mechanism and Its Per-Job Boundary [COMPLETED]

**Goal**: A future reader who greps `.github/workflows/` for `actions/cache`, finds nothing, and
concludes "`.lake/build` is never cached" is corrected by the repository's own CI documentation
rather than by re-running this task's research. Also correct one stale count in `lakefile.toml`'s
comments while that in-scope file is open.

**Tasks**:
- [x] Re-read `docs/development/CI_CD_PROCESS.md`'s `## Caching Strategy` section (currently
      beginning at line 356, with `### Mathlib Cache` at 358 and `### GitHub Actions Cache` at
      366) immediately before editing. The `### GitHub Actions Cache` subsection ALREADY EXISTS
      and already states the primary/fallback key shape and the `use-github-cache: false` disable
      switch — this task AMENDS it; it does not add a new section. If that subsection is absent
      when read (a sibling's edit, or a restructure), stop and report rather than creating a
      parallel section. *(completed: confirmed present, amended in place)*
- [x] Amend that subsection to add three facts it currently omits:
      (i) the cache is provided by `leanprover/lean-action@v1` itself, whose `use-github-cache`
      input defaults to `true`, and it covers the whole `.lake` directory — there is deliberately
      no `actions/cache` step in this repository's own workflow files, and its absence is not
      evidence that caching is off;
      (ii) the `actions/cache/save` runs inside that single composite step, so every `lake build`
      placed after it in the same job — the `Compile lean_exe roots` loop,
      `lake build BimodalTools --wfail`, and `lake build BimodalToolsTest --wfail` — writes into
      `.lake/build` after the snapshot is taken and is therefore re-elaborated on every run;
      (iii) how to re-verify the live cache for this repository:
      `gh api repos/<owner>/<repo>/actions/caches`, and the `Cache restored from key:` /
      `Cache Size:` lines inside the "Build, test, and lint with Lean" step of a completed run's
      `gh run view <id> --log`. *(completed: all three facts added)*
- [x] State fact (ii) as a known boundary of the current design, not as a defect to be fixed in
      this task, and note that closing it would mean setting `use-github-cache: false` and adding
      an explicit job-wide `actions/cache/restore` after checkout plus `actions/cache/save` as the
      job's last step — a change that must carry a before/after timing. Do not present it as
      planned work. *(completed)*
- [x] Keep every reference in the added prose pointing at a path that exists; introduce no new
      relative link whose target is not already in the tree. *(completed: readme-lint.sh Check 3 confirms 0 broken references)*
- [x] Re-read `lakefile.toml`, then correct the tooling-library comment (currently line 63) that
      reads "the roots of the 13 `lean_exe` targets below" — the file declares 15. Confirm the
      live count first: `grep -c '^\[\[lean_exe\]\]' lakefile.toml` and
      `python3 scripts/lake_targets.py exe-roots | tr ' ' '\n' | grep -c .` must agree; write
      whatever they agree on, not the number in this plan. *(completed: both commands agree at 15)*
- [x] Leave the quoted historical gate output in `scripts/check-module-invariants.sh:4947` and
      `docs/development/MODULE_INVARIANTS.md:309` ("`FAIL C25  1 of 13 lean_exe root module(s)
      do not compile`") untouched. Those are verbatim records of what was observed, not live
      counts, and are outside this task's file scope besides. *(completed: neither file touched)*
- [x] Commit this phase's files with the scoped-staging flow (explicit two-path `git add --`). *(completed)*

**Timing**: 0.7 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts (a) that `docs/development/CI_CD_PROCESS.md` already
contains a `### GitHub Actions Cache` subsection, so the work is an amendment and not an
addition; and (b) that `lakefile.toml` declares 15 `lean_exe` targets against a comment claiming
13. Both were measured live at plan time (`grep -n "^### GitHub Actions Cache"` returns line 366;
both count commands return 15). Confirm by re-running those three commands before editing; if (a)
fails, stop and report, and if (b) now agrees, drop that task rather than editing the comment to
match this plan's number.

**Tier Justification**: Every hunk lies inside a markdown prose body or a TOML `#` comment with
zero elaboration or parse surface, and the covering check is
`bash .claude/scripts/verify-touched.sh docs/development/CI_CD_PROCESS.md lakefile.toml`,
measured at plan time to return the `__FULL_SWEEP__` sentinel over this phase's full
`Files to modify` set, run alongside the `prose` tier's diff read-through confirming each hunk
stays inside a comment or prose region.

**Files to modify**:
- `docs/development/CI_CD_PROCESS.md` - amend the existing `### GitHub Actions Cache` subsection with the lean-action provenance, the per-job save boundary, and the live re-verification pointer
- `lakefile.toml` - correct the stale `lean_exe` target count in the `BimodalTools` library comment

**Verification**:
- Diff read-through: every hunk in `git diff -- docs/development/CI_CD_PROCESS.md lakefile.toml`
  lies inside markdown prose or a TOML `#` comment. No TOML key, value, table header, or
  `leanOptions` entry is touched; `git diff -- lakefile.toml` shows comment lines only.
- `python3 -c "import tomllib; d=tomllib.load(open('lakefile.toml','rb')); print(d['name'], len(d['lean_exe']), len(d['lean_lib']), d['defaultTargets'])"`
  returns the same values before and after the edit, proving the comment change moved no declared
  target.
- `grep -n "use-github-cache\|lean-action\|actions/caches" docs/development/CI_CD_PROCESS.md`
  shows the three added facts present in the `### GitHub Actions Cache` subsection, and
  `grep -c "^### GitHub Actions Cache" docs/development/CI_CD_PROCESS.md` is still exactly 1 (an
  amendment, not a duplicated section).
- `bash scripts/readme-lint.sh docs` reports no broken relative reference (Check 3) attributable
  to this phase's edits. Baseline delta, not absolute zero: CI does not run this script over
  `docs`, so pre-existing findings there are enumerated and recorded, and only a NEW finding
  naming `docs/development/CI_CD_PROCESS.md` is a failure. Check 4 (`Last verified` date) is
  reported-only by that script's own design and is not a gate here.
- `bash .claude/scripts/verify-touched.sh docs/development/CI_CD_PROCESS.md lakefile.toml` exits
  0, with its printed verdict recorded. Baseline delta as above: a finding naming no file this
  phase touched is a recorded PASS, enumerated, and only a finding naming one of these two files
  blocks the phase.
- The pre-commit hook (`.githooks/pre-commit`) is a confirmed no-op for this phase: it fires only
  when the staged set touches a `.lean` path, and neither file is one. No
  `typst/generated/status.typ` regeneration is owed. Independently, `scripts/typst-status-counts.sh`
  reads `lakefile.toml` only for the Mathlib `rev`, which this phase does not touch, so no
  coupled generated surface moves.

---

### Phase 3: Verify Acceptance, Record the Reversal and the Residual Gap [NOT STARTED]

**Goal**: Confirm the task's ACCEPTANCE criteria hold, establish on the record that deliverable
(a) was deliberately not implemented and why, and hand the residual cache-boundary gap forward as
a named follow-up candidate rather than losing it.

**Tasks**:
- [ ] Re-verify the acceptance criterion "a second CI run on an unchanged tree restores from cache
      rather than re-elaborating (visible in the run log)" against live state, which research
      found already satisfied by `lean-action`'s default caching. Use the most recent COMPLETED
      `ci.yml` run: `gh run list --workflow=ci.yml --limit 5 --json databaseId,status,conclusion,createdAt,headSha`,
      then `gh run view <id> --log | grep -i cache` and look for a `Cache restored from key:` or
      `Cache hit for restore-key:` line inside the "Build, test, and lint with Lean" step. Record
      the run id, the matched key, and the cache size verbatim.
- [ ] Re-verify the live cache store: `gh api repos/<owner>/<repo>/actions/caches`. Record the
      entry count, the key family, and the sizes observed. If the store is empty or the key family
      differs from `lake-Linux-X64-…`, record that as a changed premise rather than forcing the
      criterion green — the acceptance claim then rests on the run log alone.
- [ ] Re-verify acceptance criterion "`ci.yml` declares a `timeout-minutes`" (Phase 1's own
      verification, re-run here so the final phase observes it rather than trusting it).
- [ ] Re-verify acceptance criterion "no change to what any check step verifies": every `run:`
      body, every `continue-on-error`, every step `id`, every `report` line, and the `expected`
      count in the "Report results" step are byte-identical to their pre-task state. Confirm with
      `git diff <pre-task-sha> -- .github/workflows/ci.yml`, whose only hunk is Phase 1's
      `timeout-minutes` line plus its comment.
- [ ] Assert the Non-Goals held: `grep -rn "actions/cache\|restore-keys\|use-github-cache" .github/workflows/`
      still returns nothing, and `grep -n "moreLeanArgs\|precompileModules\|extraDepTargets\|strategy:\|matrix:" lakefile.toml .github/workflows/ci.yml`
      still returns nothing.
- [ ] Run the complete gate set and record the result:
      `bash .claude/scripts/verify-deploy.sh`. Per the repo-wide-lint rule this is read as a
      baseline delta — enumerate any pre-existing finding that names no file this task touched,
      and show that each touched file passes individually; do not edit an out-of-scope file to
      force an absolute zero.
- [ ] Write the task summary at
      `specs/829_ci_lake_build_cache_and_job_config/summaries/01_ci-lake-build-cache-and-job-config-summary.md`,
      recording: the live-evidence reversal of deliverable (a) with the run id and cache entries
      that establish it; the one functional change actually made; the documentation amendment; the
      re-validated carried figures; and the residual gap as an explicit follow-up candidate
      (`lean-action`'s cache save boundary leaves the 15 `lean_exe` roots, `BimodalTools`, and
      `BimodalToolsTest` artifacts uncovered; closing it means `use-github-cache: false` plus a
      hand-rolled job-wide restore/save, gated on a recorded before/after timing).
- [ ] Record the residual gap and the reversal in the task's own issue log via
      `bash .claude/scripts/issue-record.sh` as they are confirmed, not reconstructed afterwards.
- [ ] Commit the summary with the scoped-staging flow.

**Timing**: 0.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts that `.github/workflows/ci.yml`'s whole-task diff is
exactly one `timeout-minutes` line plus one comment line, and that the live cache store holds
entries under the `lake-Linux-X64-…` key family. Confirm both at implementation time with the
`git diff <pre-task-sha>` and `gh api …/actions/caches` commands named in the task list; a
divergence in either is recorded as a changed premise in the summary, not reconciled by editing
anything.

**Files to modify**:
- `specs/829_ci_lake_build_cache_and_job_config/summaries/01_ci-lake-build-cache-and-job-config-summary.md` - the task summary, recording the deliverable-(a) reversal, the one functional change, and the residual gap as a follow-up candidate

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` has been run in this dispatch and observed, with its
  result recorded as a baseline delta: every finding either names no file this task touched (a
  recorded pre-existing finding, enumerated) or is absent. No gate is skipped and `--skip-slow` is
  not used — a `--skip-slow` or `--only-gate` pass is not evidence for this phase's `full` tier.
- `python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/ci.yml'))['jobs']['build']; print(d['timeout-minutes'])"`
  prints `300`.
- `git diff <pre-task-sha> -- .github/workflows/ci.yml` shows exactly two added lines and no
  other change; `git diff <pre-task-sha> -- lakefile.toml` shows comment lines only.
- `grep -rn "actions/cache\|restore-keys\|use-github-cache" .github/workflows/` returns nothing.
- A `Cache restored from key:` or `Cache hit for restore-key:` line from a completed `ci.yml` run
  log is quoted verbatim in the summary, with its run id, alongside the `gh api
  .../actions/caches` entry count — or, if either is unavailable, the summary records that
  explicitly instead of asserting the criterion.
- The summary file exists, is non-empty, and names the residual gap as a follow-up candidate.

---

## Testing & Validation

- [ ] `ci.yml` parses as YAML and its `build` job declares `timeout-minutes: 300`.
- [ ] `lakefile.toml` parses as TOML and its declared target set (`lean_exe`, `lean_lib`,
      `defaultTargets`) is unchanged by this task.
- [ ] No `actions/cache`, `restore-keys`, or `use-github-cache` literal exists anywhere under
      `.github/workflows/`.
- [ ] No build-performance key (`moreLeanArgs`, `precompileModules`, `extraDepTargets`) and no
      `strategy:`/`matrix:` was added.
- [ ] Every `run:` body, step `id`, `continue-on-error` flag, `report` line, and the `expected`
      count in `ci.yml` are byte-identical to their pre-task state.
- [ ] `bash .claude/scripts/verify-deploy.sh` recorded as a baseline delta with every touched
      file passing individually.
- [ ] `bash scripts/readme-lint.sh docs` introduces no new broken-reference finding naming
      `docs/development/CI_CD_PROCESS.md`.
- [ ] Cross-run cache restore evidenced from a completed `ci.yml` run log, quoted in the summary.

## Artifacts & Outputs

- `.github/workflows/ci.yml` — `timeout-minutes: 300` on the `build` job (deliverable (b)).
- `docs/development/CI_CD_PROCESS.md` — amended `### GitHub Actions Cache` subsection.
- `lakefile.toml` — corrected `lean_exe` count in one comment; no configuration change.
- `specs/829_ci_lake_build_cache_and_job_config/summaries/01_ci-lake-build-cache-and-job-config-summary.md`
  — summary recording the deliverable-(a) reversal, the acceptance evidence, and the residual gap.
- `specs/829_ci_lake_build_cache_and_job_config/issues.jsonl` — issue/win entries recorded as they
  arise.
- Deliberately NOT produced: any `actions/cache` step, any `lakefile.toml` build-performance
  configuration, any matrix split.

## Rollback/Contingency

Every change is additive, comment-level, or prose-level, and each phase commits exactly one
scoped file set, so rollback is per-phase `git revert` of that phase's commit — no regeneration,
migration, or rebuild is owed by a revert.

- **Phase 1 reverted**: `ci.yml`'s `build` job returns to inheriting GitHub's 360-minute default.
  No check behavior changes either way.
- **Phase 2 reverted**: documentation returns to its current partial account of the cache; the
  `lakefile.toml` comment returns to its stale count. No executable surface is involved.
- **Phase 3 cannot require a rollback** — it writes only a summary artifact under `specs/**`.
- **If `timeout-minutes: 300` ever proves too tight** (a real run approaching 300 minutes), raise
  it rather than removing it, and record the measured runtime that motivated the new value.
- **Concurrency contingency**: if a foreign commit or foreign uncommitted modification to any of
  the three files is observed, STOP and report after checking `git log` to confirm the work is not
  this task's own. Do not run `git-snapshot.sh` in its reverting default mode on this shared
  working tree; use `--no-revert` for a defensive checkpoint.
