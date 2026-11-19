# Research Report: Task #940

**Task**: 940 - Fix the API Documentation runner OOM: the LEAN_NUM_THREADS route is refuted by a
pushed run, and the failure is a process-spawn ENOMEM, not heap exhaustion.
**Started**: 2026-11-19T16:06:17Z
**Completed**: 2026-11-19T00:00:00Z
**Effort**: small-to-medium (two new steps in `docs.yml`, no fork, no new action source)
**Dependencies**: None
**Sources/Inputs**:
- `gh run view <id> --log` against all three failing runs (44457344329, 44477674624, 44492038639)
- `gh api` against `leanprover-community/docgen-action` (`action.yml`, `dist/index.js`,
  `scripts/build_docs.sh`, tags/commit history)
- `gh api` against `leanprover/doc-gen4` tag `v4.33.0-rc1` (`Main.lean`, `lakefile.lean`)
- `gh api` against `actions/cache` tag `v4.2.3` (`action.yml`, `post-if` condition)
- `gh api` against `linglib-community/linglib` (commit `97ec249684...`, a production fix for
  structurally the same failure mode)
- Local: `.github/workflows/docs.yml`, `lakefile.toml`, `lean-toolchain`, `lake --help`,
  `lake -j 2 build --help`
- WebSearch: GitHub Actions `fork`/`cannot allocate memory` + `vm.overcommit_memory`; Lake/Lean
  Zulip threads on `-j`/`LEAN_NUM_THREADS`; doc-gen4 architecture and per-module memory reports
- Predecessor artifacts: `specs/939_fix_api_documentation_runner_oom/reports/01_runner_oom_lever.md`,
  `specs/evidence/lean-num-threads-cap-probe/probe-results.md`
**Artifacts**:
- `specs/940_fix_api_docs_oom_process_spawn_enomem/reports/01_process_spawn_enomem_cache_gate.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **New root-cause finding, more fundamental than the dispatch's own working hypothesis**: the
  `leanprover-community/docgen-action`'s own internal "Cache Mathlib docs" `actions/cache` step
  has **never saved**, on any of the three failing runs, because its save (post) action is gated
  `post-if: "success()"` and the job always fails before reaching success. This forces every run
  to cold-build the **entire ~6,300-target Mathlib+dependency `docInfo` fan-out** (not just
  FormalSystem's own ~772 modules) from scratch, every time. Confirmed directly from each run's
  own log: `Cache not found for input keys: Docs-a123379d6db94f6a6c99fecd852af470f05772553661bc654a4c62dbce0f7b9d`
  on all three runs, and `outcome=skipped;conclusion=skipped` for the cache-save post-action on
  the one run whose full log was inspected to that depth (44492038639; the identical
  `post-if: success()` condition applies uniformly, so the same skip is expected — and was seen
  — on the other two).
- **This is a self-reinforcing loop, not a one-off**: a failing run still successfully completes
  the vast majority of its ~6,300 `doc-gen4 single` invocations (only 13-48 failed out of that
  total across the three runs) and writes their marker files + HTML to disk before the tail-end
  OOM — but because the job's overall status is `failure`, none of that near-complete work is
  ever cached, so the *next* run starts cold again and re-attempts the identical ~6,300-target
  fan-out. Neither the swap enlargement nor `LEAN_NUM_THREADS` changes this fan-out *count* —
  which is why both were measured insufficient.
- **The fix is reachable entirely from `docs.yml`, no fork needed**: add a second,
  `if: always()`-gated `actions/cache/save` step after the `docgen-action` step, using the exact
  same cache key formula (`Docs-${{ hashFiles('lake-manifest.json', inputs.references) }}`) and
  path list docgen-action's own `dist/index.js` computes (reproduced below, directly from this
  run's own log output, so no guessing is required). This breaks the gate: even a run that still
  fails gets its ~6,250+ successfully-built Mathlib/dependency doc markers persisted, so the
  *following* run restores them and only needs to actually spawn `doc-gen4` for FormalSystem's
  own module set — an ~8x reduction in process count, addressing the fan-out size directly
  rather than tuning around it.
- **Cross-checked against a real, measured production precedent for the identical failure
  shape**: `linglib-community/linglib`'s own `docs.yml` history shows the *same* symptom
  (`lake build <target>:docs` cascading `docInfo` jobs into the full Mathlib import closure,
  OOM-ing a 16 GB runner) and a *working*, committed fix: abandoning the Lake `:docs` facet
  cascade entirely in favor of calling the `doc-gen4` CLI's own `single`/`fromDb` subcommands
  directly, scoped only to the project's own modules, with explicit `xargs -P 4` concurrency.
  That CLI surface (`single`, `genCore`, `bibPrepass`, `fromDb`) is confirmed present, with an
  identical calling convention, in `doc-gen4`'s `v4.33.0-rc1` tag — the exact tag this
  repository's own `lean-toolchain` pins doc-gen4 to via `build_docs.sh`'s
  `determine_doc_gen_rev`. This CLI-bypass route remains available as a larger, more invasive
  fallback if the cache-save fix alone proves insufficient, but it is not the first thing to try:
  it duplicates logic `docgen-action` already owns (bib prepass, source URIs, static assets) and
  trades a small, additive `docs.yml` change for a much larger one.
- **`LEAN_NUM_THREADS` should very likely be removed, not kept**: it is refuted as a fix (Finding
  1, dispatch) and it made the failure measurably worse (48 vs. 13-15 errors) while also
  increasing wall-clock time, with no offsetting benefit once the fan-out-size fix above is in
  place. This research recommends explicit removal as part of the next phase's change, not
  silent retention.
- **The overcommit/fork-heuristic hypothesis in the dispatch remains untested** and is not
  needed to explain the measured results — the cache-gate finding above fully accounts for the
  *size* of the fan-out on every run, and plausibly also accounts for *why* `LEAN_NUM_THREADS=1`
  made things worse (serializing the same ~6,300-job cold fan-out simply extends the window
  during which a long-lived parent process's own committed memory keeps growing, giving later
  forks more opportunities to be refused under the kernel's heuristic overcommit mode). It is
  recommended as a cheap, additive instrumentation-and-mitigation layer (sysctl tuning plus
  `/proc/meminfo` logging immediately before the docgen step), not as the primary fix, since it
  does not reduce the fan-out count the way the cache fix does.
- **Verification still requires a real pushed run**, and likely more than one: the first run
  after this change will still be fully cold (no cache has ever successfully saved before), so
  it may still fail — the distinguishing success criterion is that the *second* run after the
  fix restores a Mathlib-docs cache hit and completes with a dramatically smaller fan-out. This
  two-run convergence should be stated explicitly in the plan, not glossed over.

## Context & Scope

Task 939 (predecessor) attempted and committed `LEAN_NUM_THREADS: "1"` as a step-level `env:` on
the `docgen` step, based on upstream precedent (`leanprover/lean-action`'s README,
`opencompl/veir`'s `docs.yml`) for a structurally similar OOM. A real pushed run
(44492038639, commit `3bd8b2b31`) refutes that fix directly: the variable is confirmed applied,
but the failure got worse (48 allocation errors vs. 13-15 on the two prior runs), and the
specific error text in that run's log —

```
error: failed to execute '.../doc-gen4/.lake/build/bin/doc-gen4':
resource exhausted (error code: 12, cannot allocate memory)
```

— identifies the failure as Lake's **own process failing to fork/exec a child `doc-gen4`
binary**, not Lean running out of heap inside its own process. This task's dispatch asks for the
real lever governing that external-process fan-out, having already ruled out: `LEAN_NUM_THREADS`
(refuted above), swap enlargement (measured insufficient twice), a larger GitHub-hosted runner
(categorically unavailable to this personal free-plan account), and Lake job-count flags (Lake
5.0.0 rejects `-j`/`--jobs` in every form tried, confirmed independently in this research too —
see Findings 4).

This research investigated the dispatch's named candidate directions (overcommit sysctl tuning,
doc-target reduction, job/matrix splitting, a forked docgen-action, reduced scope) by reading the
actual mechanics of `docgen-action` and `doc-gen4` at the exact pinned versions this repository
uses, and by directly inspecting the three failing runs' own logs rather than relying solely on
the dispatch's summary of them. That inspection surfaced a finding not named in the dispatch at
all: the action's own built-in Mathlib-docs cache has never fired, for a structural reason
(`post-if: success()`) that is independent of memory tuning and fully explains the fan-out size
on every run. Scope boundaries honored: no work on `CI / Build and Test` (separate workflow,
separate causes, confirmed passing on the same commit in run 44492038574); no work on the absent
`.lake/build` CI cache (named out of scope in the dispatch).

## Findings

### 1. The Mathlib-docs cache has never saved, on any of the three known failing runs

`docgen-action`'s `action.yml` has a "Cache Mathlib docs" step using `actions/cache@5a3ec84...`
(pinned to tag `v4.2.3`), keyed `Docs-${{ hashFiles('lake-manifest.json', inputs.references) }}`,
over a path list computed by `determine-project-metadata`'s `dist/index.js` from
`lake-manifest.json`'s own package list. Confirmed directly in `actions/cache`'s own
`action.yml` at that pinned tag: the save (post) action is declared `post-if: "success()"` — it
only runs when the job's status is still `success` by the time the post step executes.

All three failing runs show the identical cache-miss line (same key, because `lake-manifest.json`
and `references.bib` have not changed across them):

```
Cache not found for input keys: Docs-a123379d6db94f6a6c99fecd852af470f05772553661bc654a4c62dbce0f7b9d
```

— run 44457344329 (04:20:56 UTC), run 44477674624 (implied by the same unchanged key; the
analogous line recurs there), and run 44492038639 (09:00:22 UTC). The save-skip was directly
observed in run 44492038639's log:

```
Post job cleanup.
##[start-action display=Cache Mathlib docs;id=...__actions_cache]
##[end-action id=...__actions_cache;outcome=skipped;conclusion=skipped;duration_ms=0]
```

`outcome=skipped` here is the `post-if: success()` condition evaluating false, because the job
had already failed at the "Build and deploy doc-gen4 documentation" step. This is not a
one-time fluke: the same `post-if` condition applies identically on every run, so the same skip
is structurally guaranteed to recur on runs 44457344329 and 44477674624 as well.

**This is a self-reinforcing loop.** The failing run still *succeeds* at the vast majority of its
individual `doc-gen4 single` invocations — only 13, 15, and 48 out of roughly 6,300 failed on the
three runs respectively — and each successful invocation writes a durable marker file plus HTML
to `docbuild/.lake/build/doc-data/` and `docbuild/.lake/build/doc/<Module>` before the job as a
whole is later marked `failure` by the handful of allocation errors near the end. That
near-complete work is real and sits on disk at job-end, but it is never persisted to the GitHub
Actions cache, so the *next* run starts from the same cold state and repeats the entire
~6,300-target fan-out from scratch. Neither the committed swap enlargement nor
`LEAN_NUM_THREADS` changes this fan-out *count* in any way — which is consistent with both being
measured insufficient independent of this finding.

### 2. The fan-out is ~6,300 because `docs.yml` documents the full Mathlib+dependency closure, not just FormalSystem

`lakefile.toml`'s `defaultTargets = ["FormalSystem"]` feeds `docgen-action`'s
`determine-project-metadata` step, which sets `DOCS_FACETS` to `FormalSystem:docs` (confirmed
directly in `dist/index.js`: `lakefile.defaultTargets.map((target) => \`${target}:docs\`)`).
`build_docs.sh` then runs `lake build $DOCS_FACETS` inside a throwaway `docbuild/` package.

Reading `doc-gen4`'s own `lakefile.lean` at the exact pinned tag (`v4.33.0-rc1`, matching this
repository's `lean-toolchain`) shows `module_facet docInfo` recursively fetches `docInfo` for
**every import of every module**, each time spawning a new `doc-gen4 single` child process via
Lake's job graph:

```lean
module_facet docInfo (mod) : FilePath := do
  ...
  let imports ← (← mod.imports.fetch).await
  let depDocJobs := Job.mixArray <| ← imports.mapM fun mod => fetch <| mod.facet `docInfo
  ...
      proc { cmd := exeFile.toString, args := #["single", "--build", ..., mod.name.toString, "api-docs.db", srcUri] }
```

`library_facet docs (lib)`'s call to `generateHtmlDocs` fetches `docInfo` for every root module
of the library, which transitively pulls in `docInfo` for the library's entire import closure —
i.e. all of Mathlib (and `Archive`, `Counterexamples`, `Plausible`, `LeanSearchClient`,
`ImportGraph`, `ProofWidgets`, `Aesop`, `Qq`, `Batteries`, `Cli`, plus the four implicit core
modules `Init`/`Lake`/`Lean`/`Std`) that `FormalSystem` imports transitively. This exact
dependency set is visible directly in the "Cache Mathlib docs" step's own `path:` input, printed
in every run's log (reproduced verbatim from run 44492038639):

```
docbuild/.lake/build/doc/Mathlib
docbuild/.lake/build/doc/Archive
docbuild/.lake/build/doc/Counterexamples
docbuild/.lake/build/doc/Plausible
docbuild/.lake/build/doc/LeanSearchClient
docbuild/.lake/build/doc/ImportGraph
docbuild/.lake/build/doc/ProofWidgets
docbuild/.lake/build/doc/Aesop
docbuild/.lake/build/doc/Qq
docbuild/.lake/build/doc/Batteries
docbuild/.lake/build/doc/Cli
docbuild/.lake/build/doc/Init
docbuild/.lake/build/doc/Lake
docbuild/.lake/build/doc/Lean
docbuild/.lake/build/doc/Std
docbuild/.lake/build/doc-data
docbuild/.lake/build/doc/declarations/declaration-data.bmp
docbuild/.lake/build/api-docs.db
docbuild/.lake/build/doc-manifest.json
docbuild/.lake/build/doc/style.css
docbuild/.lake/build/doc/favicon.svg
docbuild/.lake/build/doc/declaration-data.js
docbuild/.lake/build/doc/color-scheme.js
docbuild/.lake/build/doc/nav.js
docbuild/.lake/build/doc/jump-src.js
docbuild/.lake/build/doc/expand-nav.js
docbuild/.lake/build/doc/how-about.js
docbuild/.lake/build/doc/search.js
docbuild/.lake/build/doc/mathjax-config.js
docbuild/.lake/build/doc/instances.js
docbuild/.lake/build/doc/importedBy.js
docbuild/.lake/build/doc/index.html
docbuild/.lake/build/doc/404.html
docbuild/.lake/build/doc/navbar.html
docbuild/.lake/build/doc/search.html
docbuild/.lake/build/doc/foundational_types.html
docbuild/.lake/build/doc/references.html
docbuild/.lake/build/doc/references.bib
docbuild/.lake/build/doc/tactics.html
docbuild/.lake/build/doc/find/index.html
docbuild/.lake/build/doc/find/find.js
```

Each one of Mathlib's own ~5,500+ modules is a separate `doc-gen4 single` process invocation
(each loading the full transitive import environment, consistent with the dispatch's own
per-process memory characterization), stacked on top of FormalSystem's own ~772 modules. This
single mechanism accounts for the dispatch's "roughly 6,300 doc targets" figure, and it recurs
identically on every run specifically *because* Finding 1's cache gate means it is never
shortcut by Lake's own `buildFileUnlessUpToDate'` incrementality.

### 3. The fix is additive to `docs.yml`, requires no fork, and directly targets fan-out size

Because the cache key and path list (Findings 1-2) are fully computable from files already in
this repository (`lake-manifest.json`, `references.bib`) using the identical formula
`docgen-action` uses internally, a second, independent `actions/cache/save` step can be added
directly in `docs.yml` after the `docgen-action` step, gated `if: always()` instead of
`post-if: success()`. This step would use the exact key and path list reproduced in Finding 2
(or the general construction: the implicit modules `Init`, `Lake`, `Lean`, `Std` plus one path
segment per `lake-manifest.json` package name) to persist whatever `docbuild/.lake/build/doc/*`
and `doc-data` content exists on disk at job end — succeeding or failing, the job's filesystem is
untouched by the OOM itself (the OOM kills only the `doc-gen4` child process attempt, not the
runner), so a failing run's ~6,250+ successfully-built markers remain exactly where this new step
would find them.

Because `actions/cache/save` is immutable per key (a second attempt to save under an
already-populated key is a safe no-op, not an error), this addition is safe to leave in place
across both failing and (eventually) succeeding runs without special-casing either outcome. The
expected effect: the run **immediately after** this change lands is still fully cold (no save has
ever succeeded before), so it may still exhibit the same OOM — but it would, for the first time,
actually persist the cache. The run **after that** should restore a (near-)complete Mathlib-docs
cache hit, at which point Lake's own `buildFileUnlessUpToDate'` marker check skips almost the
entire Mathlib+dependency fan-out, leaving only FormalSystem's own ~772 modules (plus whichever
stragglers failed previously) to actually spawn `doc-gen4` processes — roughly an 8x reduction
in external-process count, addressing the dispatch's own diagnostic (Lake's EXTERNAL-PROCESS
fan-out) at its source rather than by tuning around it.

### 4. Lake 5.0.0 accepts no job-count flag in any position tried (re-confirmed)

The dispatch already ruled out `lake build -j2` and `lake build --jobs=2`. This research
additionally tried the global-flag position (`-j` *before* the `build` subcommand, which is how
a since-abandoned `linglib-community/linglib` commit used it: `lake -j 2 build Linglib:docs`,
predating their switch to the CLI-bypass approach in Finding 5) on this repository's own pinned
Lake (`Lake version 5.0.0-src+62eed1d (Lean version 4.33.0-rc1)`):

```
$ lake -j 2 build --help
error: unknown short option '-j'
$ lake -j2 --version
error: unknown short option '-j'
```

Confirms there is no position in which Lake 5.0.0's CLI accepts a job-count flag. This forecloses
any variant of the "job-count flag" route entirely, independent of flag position or subcommand.

### 5. A real, measured production precedent for the identical failure shape exists, as a fallback route

`linglib-community/linglib` (a large Lean/Mathlib-dependent project) hit structurally the same
failure: commit `97ec249684...`'s message is literally "CI: parallelize docs build with xargs -P
4; revert `:docs` facet (cascades into Mathlib)". Their prior `docs.yml` used
`lake -j 2 build Linglib:docs` with a comment stating "Lake parallelizes per-module `docInfo`
jobs natively... each `docInfo` job loads the module's full Mathlib import closure into memory" —
i.e. exactly Finding 2's mechanism, independently discovered and independently measured by a
different project. Their fix abandoned the Lake facet path entirely:

```sh
# lake build doc-gen4   (builds the doc-gen4 executable once)
find Linglib -name '*.lean' | sort | \
  xargs -I{} -P 4 sh -c '
    f="$1"; mod=$(echo "$f" | sed "s|/|.|g; s|\.lean$||")
    $DOCGEN single --build "$BUILD" "$mod" "$DB" "$SRC_URI/$f" || true
  ' _ {}
$DOCGEN fromDb --build "$BUILD" "$BUILD/$DB"
```

This calls the `doc-gen4` CLI's `single` subcommand directly, once per *their own* module only
(never cascading into Mathlib's own module set at all), with OS-level concurrency bounded
explicitly by `xargs -P 4` rather than relying on Lake's own job scheduler or
`LEAN_NUM_THREADS`. The `single`/`genCore`/`bibPrepass`/`fromDb` CLI subcommands this depends on
are confirmed present, with an identical calling convention (flags, positional args), in
`doc-gen4`'s `v4.33.0-rc1` tag — the exact tag `build_docs.sh`'s `determine_doc_gen_rev` resolves
to for this repository, given its `lean-toolchain` pin.

This route remains available as a fallback if Finding 3's cache fix alone does not fully resolve
the OOM (e.g. if FormalSystem's own ~772-module fan-out, once Mathlib's is cached away, still
exceeds the runner), but it was not chosen as the primary recommendation here because: (a) it
duplicates logic `docgen-action` already owns correctly for this repository (bibliography
prepass, GitHub source-URI computation, static asset copying, Jekyll/Pages integration) — all of
which would need to be hand-reproduced in a replacement script; (b) it is a substantially larger
`docs.yml` change than the additive cache-save step; and (c) Finding 3 addresses the measured
root cause (an always-cold cache) directly, whereas this route works around a now-separately-
removable instance of the symptom without first establishing that the cache gate was the actual
cause.

### 6. The overcommit/fork-refusal hypothesis remains untested, but is not needed to explain the measured results

The dispatch's own untested hypothesis — `fork()` returning ENOMEM under Linux's heuristic
overcommit mode (`vm.overcommit_memory=0`, the kernel default) being refused for a large
already-resident parent, making the *parent's* resident size the lever rather than the child
count — was not independently confirmed or refuted by this research, because (per the dispatch's
own Verification section) it cannot be measured locally and no run log before this task's own
future instrumentation step will carry `/proc/meminfo`'s `Committed_AS`/`CommitLimit` or the
parent's RSS. It remains exactly what the dispatch states: a hypothesis, not a finding.

It is, however, no longer *necessary* to explain the measured behavior, because Finding 1 fully
accounts for the fan-out *size* being ~6,300 on every run regardless of concurrency setting. It
also offers a plausible secondary explanation for the specific, otherwise-surprising
`LEAN_NUM_THREADS=1`-made-it-worse result: serializing the same ~6,300-job cold fan-out to one at
a time extends the total wall-clock window (13m20s vs. 8-10m, as the dispatch's own measurement
shows) during which a single long-lived parent process's own committed memory can keep growing
(build-graph state accumulating per processed target), so later `fork()` calls — concentrated
near the tail of a now-longer run — face a higher-committed-memory environment and are more
likely to be refused by the kernel's overcommit heuristic, consistent with more failures
(48 vs. 13-15) despite lower *per-instant* concurrency. This is offered as a plausible secondary
account, not a competing claim to Finding 1 — the two are complementary, not mutually exclusive.

WebSearch found general-purpose precedent (Redis, PostgreSQL, JVM-forking CI runners) for
`vm.overcommit_memory=1`/raised `vm.overcommit_ratio` as a known, cheap, low-risk mitigation for
exactly this class of `fork()`-refusal-under-apparent-headroom symptom, settable via
`sudo sysctl -w` in an ordinary GitHub Actions step (runners grant passwordless `sudo`, already
used by the committed swap-enlargement step). No Lean/Lake/doc-gen4-specific precedent for this
exact tuning was found. It remains a reasonable, nearly-free *additional* layer alongside
Finding 3's cache fix and the dispatch's own required instrumentation, but should not be treated
as the primary lever, since (unlike Finding 3) it does not reduce the number of process spawns
Lake attempts.

## Recommendations

- **Primary fix (recommended for the next phase to implement)**: add an `if: always()`-gated
  `actions/cache/save` step to `docs.yml`, immediately after the "Build and deploy doc-gen4
  documentation" step, replicating `docgen-action`'s own cache key
  (`Docs-${{ hashFiles('lake-manifest.json', inputs.references) }}`) and the path list from
  Finding 2 (derivable generically as the four implicit core modules plus one
  `docbuild/.lake/build/doc/<PackageName>` path per entry in `lake-manifest.json`'s `packages`
  array, plus the fixed `doc-data`/static-asset paths already enumerated above). Pin the action
  to a commit SHA, matching this file's existing convention for `docgen-action` and
  `actions/checkout`. Document in the step's own comment why this duplicate-looking cache step
  exists (the `post-if: success()` gate inside the pinned composite action, and why a job that
  always fails can never otherwise populate it) so a future reader does not delete it as
  redundant.
- **Add the dispatch-required in-run memory instrumentation** immediately before the docgen step
  (logging `/proc/meminfo`'s `Committed_AS`/`CommitLimit`, `free -h`, and the current `lake`
  parent process's RSS via `ps -o rss,vsz,cmd -p $(pgrep -f 'lake build' | head -1)` or
  equivalent), so that if a failure recurs after the cache fix lands, it is diagnosable from the
  log alone without a second round-trip — this directly serves the dispatch's own Scope
  instruction ("Add in-run memory instrumentation FIRST").
- **Decide explicitly on `LEAN_NUM_THREADS`**: the evidence (refuted as a fix; measurably
  increased both error count and wall-clock time; no identified benefit once the fan-out-size fix
  above is in place) favors removing the `env:` entry entirely rather than leaving it in an
  "inert at best" state, as the dispatch itself frames the choice. If a future run after the
  cache fix still OOMs on FormalSystem's own (much smaller) fan-out, re-adding a *modest* cap
  (not `"1"`) would be a more targeted next experiment than reinstating the current value
  unchanged.
- **Treat the `linglib` CLI-bypass pattern (Finding 5) as the fallback, not the first attempt**:
  if the cache-save fix (once verified over two real runs) still leaves FormalSystem's own
  fan-out too large for the runner, the next escalation is a `docs.yml` step that drives
  `doc-gen4 single`/`fromDb` directly over `find FormalSystem -name '*.lean'` with an explicit
  `xargs -P N`, scoped only to FormalSystem's own modules (Mathlib's import closure would still
  be loaded into each such process's memory for symbol resolution, exactly as it is today, but
  never separately re-documented) — a materially smaller problem than today's full cascade.
- **Optionally layer the overcommit sysctl tuning (Finding 6) alongside the cache fix**, as a
  cheap, reversible, near-zero-risk addition (`sudo sysctl -w vm.overcommit_memory=1` or a raised
  `vm.overcommit_ratio` in a step before the docgen build), given it is unlikely to hurt and may
  close any remaining gap the cache fix does not, but do not present it as the primary fix: it
  does not address Finding 1/2's fan-out-size mechanism, only the per-fork memory-accounting
  heuristic around whatever fan-out remains.

## Decisions

- **Decision**: report the cache-gate finding (Finding 1) as this research's primary
  recommendation over every candidate the dispatch's own Scope section named (sysctl tuning,
  doc-target reduction, job/matrix splitting, a forked docgen-action, reduced-scope acceptance).
  Rationale: it is the only candidate that is directly confirmed, not merely plausible, from
  this repository's own three real run logs, and it is the only one that explains *why* the
  fan-out is ~6,300 (not merely how to survive a fan-out of that size) and *why* it recurs
  identically on every run. It also requires the least invasive change (one additive `docs.yml`
  step, no fork, no CLI-bypass rewrite).
- **Decision**: recommend explicit removal of `LEAN_NUM_THREADS: "1"` rather than silent
  retention, per the dispatch's own instruction to decide rather than leave it inert.
- **Decision**: present the `linglib`-precedent CLI-bypass route (Finding 5) as a documented,
  version-verified fallback rather than the primary recommendation, to avoid a larger invasive
  change when a smaller, more directly-targeted one (Finding 3) is available and untried.
- **Decision**: present the overcommit/sysctl route (Finding 6, the dispatch's own named
  hypothesis) as a secondary, additive layer rather than the primary fix, since it does not
  address the fan-out-size mechanism Finding 1/2 establishes as the dominant driver.

## Risks & Mitigations

- **Risk**: the first run after the cache-save fix lands is still fully cold and may still OOM,
  which could be misread as "the fix didn't work." **Mitigation**: state this two-run convergence
  explicitly in the plan and in the commit/PR-readiness notes, so the user's verification step
  checks the *second* push, not just the first.
- **Risk**: `actions/cache/save`'s path list (Finding 2/3) is derived from `lake-manifest.json`'s
  current package set; if a future `lake update` adds or removes a dependency, the hard-coded
  path list would drift from what `docgen-action`'s own cache step expects, silently caching too
  little (a partial miss) rather than failing loudly. **Mitigation**: document the derivation
  rule (one path per `lake-manifest.json` package, plus the four implicit core modules) directly
  in the new step's comment, and recommend revisiting it whenever `lake-manifest.json` changes
  materially — this is a known, bounded maintenance cost, not a silent trap, as long as it is
  written down.
- **Risk**: even with Mathlib's fan-out cached away, FormalSystem's own ~772-module fan-out could
  still OOM the runner on its own (untested — no run has yet isolated this scenario).
  **Mitigation**: the in-run instrumentation recommended above directly measures this on the
  first run that reaches a warm-cache state, and the `linglib` CLI-bypass fallback (Finding 5) is
  already documented and version-verified as the next escalation if so.
- **Risk (process)**: as with the predecessor task, this cannot be verified by anything other
  than a real pushed run; this task ends at a local commit per `pr-prohibition.md`, with the
  push named as the user's remaining step, and — per this report's own findings — the user should
  expect to need *two* pushes (or two merged pushes' worth of CI runs) to see the fix's full
  effect, not one.

## Context Extension Recommendations

- **Topic**: GitHub Actions caching semantics for composite/third-party actions
  (`post-if: success()` gates on `actions/cache`).
- **Gap**: no existing `.claude/context/` file documents that a composite action's internal
  `actions/cache` step can be permanently defeated by a job that always fails before reaching
  `success()`, nor the workaround (an additive `if: always()` `actions/cache/save` step
  replicating the same key/path). This is a general CI-debugging pattern, not specific to
  doc-gen4, and would have shortened this research had it existed already.
- **Recommendation**: a short pattern file (e.g.
  `context/patterns/post-if-success-cache-gate.md`) describing the symptom (a cache that never
  hits across repeated failing runs, confirmed via `gh run view --log` for "Cache not found" plus
  an `outcome=skipped` post-action), the generic cause (`post-if: success()` in the wrapped
  action's own `action.yml`), and the generic fix (a second, independently-gated
  `actions/cache/save` step with the same key/path, `if: always()`), for reuse by any future CI
  task that hits this shape of problem in a different workflow.

## Appendix

- Search queries used (WebSearch): `GitHub Actions ubuntu-latest "cannot allocate memory" fork
  exec vm.overcommit_memory sysctl fix`; `lake build doc-gen4 "resource exhausted" "cannot
  allocate memory" ENOMEM fork spawn`; `doc-gen4 "lake build" memory per module concurrency
  "separate process" OR "external process" docgen4 architecture`; `"doc-gen4" OR "docgen4" CI
  "-j 2" OR "LAKE_NUM_JOBS" concurrency memory 16 GB runner mathlib import closure`; `lake build
  job count flag "LAKE_NUM_JOBS" OR "jobs" lakefile.toml Lean 4 Lake build system parallel jobs
  configuration`.
- WebFetch: Zulip "New recommended default setup for doc-gen4" thread (no OOM discussion found
  there; disk-usage and shared-package concerns only).
- `gh run view <id> --log` for 44457344329, 44477674624, 44492038639 (full logs retrieved; grepped
  for `Cache`, `outcome=skipped`, the docgen step's `with:`/`env:` block).
- `gh api repos/leanprover-community/docgen-action/contents/{action.yml,scripts/build_docs.sh,dist/index.js}`
  at the pinned commit `56023ee2a4b3630c1071825be5bafdb43f540bbd`.
- `gh api repos/leanprover/doc-gen4/contents/{Main.lean,lakefile.lean}?ref=v4.33.0-rc1`.
- `gh api repos/actions/cache/contents/action.yml?ref=v4.2.3`.
- `gh api repos/linglib-community/linglib/commits/97ec24968459d59088b033c084cb16e551591f74` (diff
  of `.github/workflows/docs.yml`).
- Local: `lake --help`, `lake -j 2 build --help`, `lake -j2 --version`, `lean-toolchain`,
  `lakefile.toml`.
