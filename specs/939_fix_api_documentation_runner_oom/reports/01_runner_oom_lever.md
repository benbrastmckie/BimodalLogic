# Research Report: Task #939

**Task**: 939 - Fix the API Documentation workflow's runner OOM
**Started**: 2026-11-18T00:00:00Z
**Completed**: 2026-11-19T00:00:00Z
**Effort**: small (single env-var change to `docs.yml`, no fork required)
**Dependencies**: None
**Sources/Inputs**:
- `gh api` against `benbrastmckie/BimodalLogic` (billing plan, Actions permissions)
- `gh api` against `leanprover-community/docgen-action` (commit history, no OOM/concurrency issue)
- Clone of `leanprover-community/docgen-action` source (`action.yml`, `scripts/build_docs.sh`)
- `gh api repos/leanprover/lean-action/contents/README.md` and `action.yml`
- `gh api repos/opencompl/veir/contents/.github/workflows/docs.yml` (live production precedent)
- `gh api search/code` across public GitHub for `LEAN_NUM_THREADS`
- WebSearch: GitHub larger-runner plan eligibility; Lake/Lean thread-pool Zulip discussions; `ubuntu-latest` hardware spec
- Zulip archive pages (leanprover-community) via WebFetch: "lake build -j?", "number of threads for lake build", "Lake parallel builds", "lake build limit cores"
- Local: `.github/workflows/docs.yml`, `nproc`, `lake env lean --version`
**Artifacts**:
- `specs/939_fix_api_documentation_runner_oom/reports/01_runner_oom_lever.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Larger GitHub-hosted runner: confirmed unavailable.** `benbrastmckie/BimodalLogic` is owned by a personal (user) account on the `free` billing plan. GitHub's larger-runner feature is documented as limited to organizations and enterprises on Team/Enterprise Cloud plans; personal accounts cannot use it at any plan tier, and repo visibility (public vs. private) does not change this. This route is closed, not merely unattractive.
- **Forking/patching `docgen-action`: unnecessary, and upstream offers nothing to fork for.** The action is 3 commits behind its current pinned SHA (none of the newer commits touch concurrency/memory), and its `scripts/build_docs.sh` hardcodes `~/.elan/bin/lake build $DOCS_FACETS` with no job-count input anywhere in `action.yml`. There is no concurrency-capping surface to patch in, and no upstream issue requesting one.
- **The real lever is `LEAN_NUM_THREADS`, an environment variable, not a Lake flag — already ruled out was a different thing.** The dispatch's "ruled out" finding is specifically that Lake 5.0 has no `-j`/`--jobs` CLI flag. That is correct but incomplete: Lake has no such flag precisely because Lean's own runtime gives host programs no API to cap its `Task` thread pool at the call site — but the pool size *is* configurable at process-start via the `LEAN_NUM_THREADS` environment variable, which Lean reads once at startup. Lake's own build-job scheduler runs on this same thread pool, so this variable directly caps how many `doc-gen4` jobs (each holding a full environment) run concurrently.
- **This is not a hunch — it is a documented, maintainer-endorsed, production-proven fix for this exact failure mode.** `leanprover/lean-action`'s own README has a dedicated section, "Run leanchecker on a project with a Mathlib dependency," describing byte-for-byte the same mechanism ("each parallel check loads the module's full import environment... can exhaust the memory of a GitHub-hosted runner") and prescribing `LEAN_NUM_THREADS: "1"` as the fix. Independently, `opencompl/veir`'s `docs.yml` sets `LEAN_NUM_THREADS: 4` on its own doc-gen4 build with the comment "`doc-gen4` needs several GB per module and Lake runs one job per core... [the runner's cores] would start [that many] and run out of memory" — the identical root cause named in this task's dispatch.
- **Recommended implementation**: set `LEAN_NUM_THREADS` to a low value (`"1"`, with `"2"` as a documented fallback) as a step-level (or job-level) `env:` entry on the `docgen-action` step in `docs.yml`. No action fork, no runner change, touches only `docs.yml` as the dispatch's Scope requires. The already-committed swap enlargement is retained as headroom/instrumentation, unchanged.
- **This still requires a real pushed CI run to verify** (per the dispatch's Verification section) — it cannot be reproduced locally, since the failure is a property of the GitHub-hosted runner's memory, not of this machine's.

## Context & Scope

Task 939 asks to identify and implement the actual fix for `.github/workflows/docs.yml`'s doc-gen4
build step, which fails with repeated `error: resource exhausted (error code: 12, cannot allocate
memory)` on the GitHub-hosted runner, despite an already-committed swap enlargement (3 GiB -> 15
GiB) that this task's own dispatch confirms is insufficient. The dispatch's Scope names three
candidate routes to investigate — a larger runner, a forked/patched/newer `docgen-action`, or a
reduction in the doc-target set — and asks that facts about runner-plan eligibility and the
action's upstream state settle the choice rather than preference.

This research established that none of those three literal routes is the best available fix: the
larger-runner route is categorically closed (not a preference issue), and the fork route turns out
to be unnecessary because the actual control knob is not inside the action at all — it is a
runtime environment variable reachable directly from `docs.yml`, with no change to the action
needed. This is reported as a finding, not assumed; see Findings below for the evidence chain and
Decisions for why it satisfies the dispatch's constraints (touches only `docs.yml`, implements
"one" lever) even though it is not literally one of the three bulleted options.

Scope boundaries honored: no work on `CI / Build and Test` (separate workflow, separate causes); no
work on the absent `.lake/build` CI cache (named out-of-scope in the dispatch).

## Findings

### 1. Larger GitHub-hosted runners are not available to this account, at any plan tier

- `gh api repos/benbrastmckie/BimodalLogic` confirms the repo is owned by the user account
  `benbrastmckie` (not an organization), and is public (`"private": false`).
- `gh api user` confirms `plan.name: "free"`.
- GitHub's own documentation (confirmed via WebSearch against `docs.github.com`'s
  "Supported runners and hardware resources" and billing pages) states larger runners are
  available only to organizations and enterprises on the **Team** or **Enterprise Cloud** plans —
  there is no path for a personal/user-owned repository to get a larger GitHub-hosted runner by
  upgrading plan or by being public. Public-repo-free-minutes applies only to the *standard*
  runner tier.
- Standard `ubuntu-latest` for a public repo is 4 vCPU / 16 GB RAM / 14 GB SSD (per GitHub's
  hardware-resources table) — consistent with this task's dispatch, which reports `free -h`
  showing roughly 15 GiB RAM on the failing runs.
- **Conclusion**: this route is closed by account structure, not by configuration. It cannot be
  unlocked without moving the repository under an organization and paying for a Team/Enterprise
  plan, which is out of scope for a `docs.yml` fix.

### 2. `docgen-action` upstream has no concurrency-capping surface, and is already nearly current

- `gh api repos/leanprover-community/docgen-action/commits` shows the pinned SHA
  (`56023ee2a4`, "feat: validate the Jekyll build on pull requests (#35)", 2026-08-21) is 3
  commits behind HEAD as of this research. The 3 newer commits are: `#34` ruby-version input,
  `#32` a docbuild lakefile.toml ordering fix, `#41` an `upload-pages-artifact` version bump, and
  `#38` a cache-hit HTML regeneration fix. **None address job concurrency or memory.**
- A direct clone of the action's source confirms `action.yml` exposes no job-count/concurrency
  input anywhere, and `scripts/build_docs.sh` line 99 hardcodes
  `~/.elan/bin/lake build $DOCS_FACETS` — exactly as the dispatch's "ruled out" section already
  established for why `build-args` cannot reach it.
- A GitHub code/issue search found no open or closed `docgen-action` issue mentioning memory,
  OOM, or concurrency.
- **Conclusion**: there is nothing to fork or patch for a concurrency cap — the action's own code
  surface does not own this knob at all (see Finding 3).

### 3. The actual knob is `LEAN_NUM_THREADS`, a Lean-runtime environment variable, not a Lake flag

This is the central finding, and it is distinct from the Lake `-j`/`--jobs` flag the dispatch
already ruled out:

- Lake's build-job scheduler has no flag to cap its own parallelism because, per Lake maintainer
  Mac Malone on the leanprover-community Zulip (`lake build -j?` and `Lake parallel builds`
  threads, 2023–2024): "There isn't a way to do this from Lake, because Lean does not provide a
  [...] API-based thread control mechanism" for a host program (like Lake) to cap Lean's own
  `Task` thread pool at the call site. Lake's parallel build jobs run as Lean `Task`s on this
  shared pool, so the pool's size *is* Lake's effective concurrency.
- The pool size, however, is configurable — just not via a Lake-level flag. It is read once from
  the `LEAN_NUM_THREADS` environment variable at Lean-runtime startup (confirmed by Henrik Böving
  and Mac Malone in the same Zulip threads: "a program-wide limit is available through
  `LEAN_NUM_THREADS`"). Unset, the pool defaults to the machine's hardware concurrency — i.e. 4 on
  the standard public-repo `ubuntu-latest` runner, matching the default-vCPU count this job
  already runs with.
- This is independently and authoritatively documented in `leanprover/lean-action`'s own README
  (`### Run leanchecker on a project with a Mathlib dependency`), describing the *identical*
  mechanism for a different Mathlib-dependent CI step: "`leanchecker` checks modules in parallel,
  and each parallel check loads the module's full import environment. For Mathlib-dependent
  projects this can exhaust the memory of a GitHub-hosted runner... Cap the parallelism by setting
  `LEAN_NUM_THREADS` on the `lean-action` step... Higher values trade memory for speed." The
  recommended value in that doc is `"1"`.
- It is further confirmed as a **working production fix for this exact doc-gen4 scenario**, not
  just the structurally-similar leanchecker case: `opencompl/veir`'s `.github/workflows/docs.yml`
  sets `env: LEAN_NUM_THREADS: 4` on its `docs` job, with the comment: "`doc-gen4` needs several GB
  per module and Lake runs one job per core, so the profile's 32 cores would start 32 of them and
  run out of memory." That is this task's root cause, named by a different project, fixed with
  this exact lever.
- This variable is a plain process environment variable, not an action input — it reaches
  `build_docs.sh`'s `lake build $DOCS_FACETS` subprocess by ordinary environment inheritance from
  whatever GitHub Actions `env:` scope (workflow, job, or step) sets it. No change to
  `docgen-action` itself, and no fork, is required.
- One important asymmetry versus `opencompl/veir`'s case: that project's default (unset) thread
  count was 32 (a 32-core custom runner profile) and they capped it to 4. This project's default
  is already only 4 (the standard runner's vCPU count) and it *still* OOMs at that concurrency even
  with the swap enlargement in place — so the correct value here is lower than veir's, most likely
  `1` (matching the `lean-action` README's own recommended starting point for this failure mode),
  with `2` as the first fallback to try if `1` turns out to be unnecessarily conservative on build
  time (the job already carries a 300-minute timeout, so trading time for memory headroom is cheap
  here).

### 4. Reducing the doc-target set remains a real but less-targeted fallback

Not pursued in depth, since Finding 3 directly addresses the measured cause (concurrent
full-environment-holding processes) without any of the downsides of shrinking the published API
surface. It remains available as a documented fallback if `LEAN_NUM_THREADS` alone proves
insufficient on a real run — e.g. restricting `doc-gen4`'s target scope to exclude a few of the
heaviest or least-visited modules — but it was not researched further because Finding 3 is a
same-effort, lower-downside, zero-scope-reduction fix.

## Decisions

- **Decision**: recommend implementing `LEAN_NUM_THREADS` as a step-level `env:` entry on the
  `docgen-action` step in `docs.yml`, in place of the three literally-bulleted Scope options.
  Rationale: the larger-runner route is categorically unavailable to this account (Finding 1); the
  fork route has no upstream surface to fork into and is unnecessary, since the real knob is a
  runtime env var reachable directly from `docs.yml` (Findings 2–3); and this choice still honors
  the dispatch's touch-boundary (`docs.yml` only, no new action source) and its "pick and implement
  one" instruction, just with a fourth, better-supported lever surfaced by this research rather
  than one of the three originally named.
- **Decision**: start at `LEAN_NUM_THREADS: "1"`, matching `lean-action`'s own README
  recommendation for this exact OOM failure mode, rather than veir's `4` (which was tuned down from
  a 32-core default that is already far above this runner's 4-vCPU default). `"2"` is the
  documented next value to try if `"1"` is confirmed to pass but costs more build time than
  desired; this is a tuning decision for the implementation phase informed by the real CI run's
  outcome, not something resolvable without that run.
- **Decision**: retain the existing swap-enlargement step and its `docs.yml` header documentation
  unchanged — it remains correct, cheap headroom/instrumentation, not the fix, exactly as already
  recorded.

## Recommendations

1. **Implement**: add `LEAN_NUM_THREADS: "1"` under `env:` on the `Build and deploy doc-gen4
   documentation` step in `.github/workflows/docs.yml` (the step invoking
   `leanprover-community/docgen-action`). This is the single change needed; no other file or
   action source is touched, satisfying the dispatch's Scope.
2. **Document it as the fix, not the swap step.** Extend `docs.yml`'s existing header comment
   block (which already documents the swap-enlargement measurement) with the `LEAN_NUM_THREADS`
   rationale and its `lean-action` README / `opencompl/veir` precedents, so a future reader who
   sees a different OOM signature does not re-litigate the already-settled "no `-j` flag" question
   and instead understands why an env var, not a Lake flag, is the lever.
3. **If a real pushed run still OOMs at `"1"`**: this would indicate the per-task memory footprint
   alone (not concurrency) exceeds available RAM+swap even for a single doc-gen4 task, which is a
   different failure mode than what Findings 1-3 diagnose; the fallback at that point is Finding
   4's doc-target reduction, not a larger `LEAN_NUM_THREADS` value.
4. **If a real pushed run succeeds at `"1"` well within the time budget**: optionally try `"2"` on
   a follow-up run to recover some build-time headroom, per the `lean-action` README's own
   "higher values trade memory for speed" framing. This is an optimization, not a correctness
   requirement, and should not block marking the task's primary fix verified.
5. **Owner/next step**: implementation phase makes the one-line `docs.yml` change and commits
   locally; the user remains the one to push and observe the real run, per the dispatch's
   Verification section and `pr-prohibition.md`.

## Risks & Mitigations

- **Risk**: `LEAN_NUM_THREADS=1` could push the build past a time budget. **Mitigation**: the job
  already carries `timeout-minutes: 300`; a serialized doc-gen4 pass over ~6,300 targets is
  expected to take meaningfully longer than the current parallel-but-OOMing attempt, but has a
  large stated ceiling to work within, and `"2"` is available as a documented fallback if `"1"`
  turns out unnecessarily slow on a successful run.
- **Risk**: this cannot be verified without a real push, per the dispatch's own Verification
  section — the failure is a property of the hosted runner's memory and is not reproducible
  locally. **Mitigation**: none available within this task; the implementation phase should end at
  a local commit and name the push as the user's remaining step, exactly as the dispatch specifies.
- **Risk**: `LEAN_NUM_THREADS` is confirmed to exist and to be read at Lean-runtime startup by
  multiple independent primary sources (Lake/Lean maintainers, `lean-action`'s own README, a live
  production `docs.yml`), but no source consulted here measured its before/after memory delta on a
  build of this project's exact size. **Mitigation**: this is inherent to the "cannot be reproduced
  locally" constraint above; the recommendation is strong precedent, not a local measurement, and
  the real CI run is the only way to confirm the specific value needed.

## Context Extension Recommendations

- **Topic**: Lean/Lake CI memory-exhaustion remediation.
- **Gap**: `.claude/context/project/lean4/` has no documented pointer to `LEAN_NUM_THREADS` as the
  answer to "Lake build OOMs on a GitHub-hosted runner" — a reasonably common failure mode for any
  Mathlib-dependent project's CI (doc builds, `leanchecker`/`lean4checker` steps, or a large direct
  `lake build`), and one this task had to re-derive from upstream Zulip archives and another
  project's CI rather than from in-repo context.
- **Recommendation**: add a short note to
  `.claude/context/project/lean4/patterns/` (or `tools/mcp-fallback-table.md`'s neighborhood)
  naming `LEAN_NUM_THREADS` as the env-var-not-a-Lake-flag lever for capping Lake's build
  concurrency on memory-constrained CI runners, with a pointer to `lean-action`'s README section
  and this task's artifacts as a worked example.

## Appendix

### Search queries / sources used

- `gh api repos/benbrastmckie/BimodalLogic`, `gh api user`, `gh api repos/.../actions/permissions`
- `gh api repos/leanprover-community/docgen-action/commits`
- Git clone of `leanprover-community/docgen-action` (`action.yml`, `scripts/build_docs.sh`)
- `gh api search/issues` against `leanprover-community/docgen-action` and `leanprover/lake`
- WebSearch: "GitHub larger runners available for personal user account free plan public repo"
- WebSearch: "Lake build environment variable limit parallel jobs memory LEAN_NUM_THREADS lake 5.0"
- WebSearch: "Lake 5.0 removed -j flag job count parallelism changelog LEAN_NUM_THREADS environment variable github actions"
- WebSearch: "GitHub Actions ubuntu-latest standard runner specs vCPU RAM 2026"
- WebFetch of leanprover-community Zulip archive pages: "lake build -j?", "number of threads for
  lake build", "Lake parallel builds", "lake build limit cores"
- `gh api search/code` for `LEAN_NUM_THREADS` across public GitHub, surfacing
  `leanprover/lean-action`'s `action.yml`/`README.md` and `opencompl/veir`'s `docs.yml`
- `gh api repos/leanprover/lean-action/contents/README.md` and `action.yml`
- `gh api repos/opencompl/veir/contents/.github/workflows/docs.yml`
- Local: `cat .github/workflows/docs.yml`, `nproc`, `lake env lean --version`
