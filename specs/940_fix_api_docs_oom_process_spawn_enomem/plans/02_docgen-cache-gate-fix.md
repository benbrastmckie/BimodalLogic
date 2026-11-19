# Implementation Plan: Task #940

- **Task**: 940 - Fix the API Documentation runner OOM: the LEAN_NUM_THREADS route is refuted by a pushed run, and the failure is a process-spawn ENOMEM, not heap exhaustion.
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/940_fix_api_docs_oom_process_spawn_enomem/reports/01_process_spawn_enomem_cache_gate.md
- **Artifacts**: plans/02_docgen-cache-gate-fix.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Every change lands in one file, `.github/workflows/docs.yml`. The research established that the
dominant driver of the process-spawn ENOMEM is not a tunable memory knob at all but the *size*
of Lake's external-process fan-out, and that the fan-out is ~6,300 on every run because
`docgen-action`'s own internal "Cache Mathlib docs" step has never saved -- its save action is
gated `post-if: "success()"` and this job always fails first. The plan therefore does four
things in order: adds in-run memory instrumentation first (so the next failure is diagnosable
from its own log without a second round-trip, exactly as the dispatch's Scope section requires),
removes the refuted `LEAN_NUM_THREADS` entry, adds an independently-gated
`actions/cache/save` step that breaks the cache gate, and rewrites the file's header comment so
it states measured reality rather than the refuted account now in it.

Verification is asymmetric and must be stated plainly: nothing here can be proven by a local
run, because the failure is a property of the hosted runner. What *can* be proven locally is
proven locally (see the cache-key reproduction in Phase 3, which is exact), and the rest ends at
a local commit with the push named as the user's remaining step, per
`.claude/rules/pr-prohibition.md`.

### Premise Re-Validation (dispatch-required)

The dispatch flagged two lines for re-validation. Both were checked in this dispatch; neither
changed.

- `resource exhausted (error code: 12, cannot allocate memory)` -- **confirmed, unchanged**. The
  research report quotes this verbatim from run 44492038639's own log, having re-read all three
  failing runs' logs directly rather than relying on the dispatch's summary. The spawn-vs-heap
  reading (`failed to execute '.../doc-gen4'` prefixing the message) is what distinguishes it
  from the earlier runs' bare `error: resource exhausted`, and it is what the plan acts on.
- The `pr-prohibition.md` / push-is-the-user's-step claim -- **confirmed, unchanged**, verified
  live against `.claude/rules/pr-prohibition.md` in this dispatch: `git push` in all forms is
  barred for agents, with only a user-invoked `/please` grant as an exception. The final phase
  ends at a local commit accordingly.

One additional live check, not requested but cheap: `gh run list --workflow=docs.yml` confirms
run 44492038639 (commit `3bd8b2b31`) is still the newest `API Documentation` run and still
`failure`, with no newer run since the dispatch was composed. The premise is live, not stale.
That listing also shows five consecutive failures, not three -- runs 44420617987 and
44411191790 precede the three the research examined. This does not change any finding (both
predate the swap step and neither was examined), but it is recorded so a later reader does not
mistake "three failing runs" for the complete history.

### Research Integration

Four research findings drive the phase structure directly:

- **Finding 1** (cache gate, `post-if: "success()"`) is the root cause and becomes Phase 3.
- **Finding 2** (the fan-out is ~6,300 because the `docs` library facet cascades `docInfo` into
  Mathlib's entire import closure) supplies the verbatim cache path list Phase 3 must use.
- **Finding 6** (the overcommit/fork-refusal hypothesis is untested and not needed to explain the
  measured results) is handled by *measuring* it in Phase 1 rather than acting on it -- see
  Decisions below.
- **Finding 5** (the `linglib-community/linglib` CLI-bypass precedent) is documented in Phase 4's
  escalation ladder as the next step if the cache fix proves insufficient, not implemented now.

One research claim is corrected here rather than carried forward. The report offers a generic
derivation rule for the cache path list -- "one `docbuild/.lake/build/doc/<PackageName>` path per
entry in `lake-manifest.json`'s `packages` array, plus the four implicit core modules". That rule
does **not** reproduce the list actually printed in the run log: the log carries `Archive` and
`Counterexamples`, which are not `lake-manifest.json` packages at all, and it capitalizes module
directory names (`Mathlib`, `ImportGraph`, `ProofWidgets`, `Aesop`, `Batteries`, `Plausible`)
where the manifest spells them `mathlib`, `importGraph`, `proofwidgets`, `aesop`, `batteries`,
`plausible`. Verified in this dispatch: `jq -r '.packages[].name' lake-manifest.json` returns
nine names, against eleven non-core module directories in the log. Phase 3 therefore copies the
log's verbatim list and records the derivation rule only as a maintenance *hint* in the comment,
explicitly marked approximate.

### Prior Plan Reference

No `prior_plan_path` was provided for this round. The predecessor effort's approach
(`LEAN_NUM_THREADS: "1"`, committed and pushed) reached this plan through the research report
rather than through a prior-plan load, and it enters this plan only as a refuted hypothesis to
be removed in Phase 2. Its one transferable lesson is calibration, and it is taken seriously
here: that effort reported success on the strength of upstream precedent without a green run,
and the real run contradicted it. This plan's final phase accordingly forbids any
objective-met claim before a green `API Documentation` run exists.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and `roadmap_flag` is not set, so no
roadmap phases are added and no roadmap consultation was performed.

## Goals & Non-Goals

**Goals**:
- Make the next failing run self-diagnosing: its own log must carry `Committed_AS`,
  `CommitLimit`, `MemAvailable`, `SwapFree` and the build parent's RSS sampled across the docgen
  step, so the overcommit hypothesis is decided from the log rather than guessed at again.
- Break the `post-if: "success()"` cache gate so a failing run still persists the ~6,250+
  Mathlib/dependency doc markers it successfully built, letting the following run restore them
  and spawn `doc-gen4` only for `FormalSystem`'s own modules.
- Remove `LEAN_NUM_THREADS: "1"` rather than leave it inert, per the dispatch's explicit
  instruction to decide.
- Leave `.github/workflows/docs.yml`'s header comment stating what is measured, with durable
  anchors (run IDs, commit SHAs, upstream file paths), so the next reader does not re-try a
  closed route.
- End at a local commit that names the user's push as the remaining step and states the two-run
  convergence expectation explicitly.

**Non-Goals**:
- `CI / Build and Test` (run 44492038574 passed on this same commit; separate causes) -- out of
  scope per dispatch.
- The absent `.lake/build` CI cache -- out of scope per dispatch.
- Forking or patching `docgen-action`, or replacing it with a direct `doc-gen4` CLI driver. The
  `linglib` precedent is documented as the escalation, not implemented.
- Changing `vm.overcommit_memory` / `vm.overcommit_ratio` in this round -- see Decisions.
- Any `git push`, PR, or `/merge`. Barred by `.claude/rules/pr-prohibition.md`.
- Re-trying `LEAN_NUM_THREADS` at any value, swap enlargement, a larger hosted runner, or any
  `lake -j`/`--jobs` form. All four are measured-closed.

## Decisions

- **Measure the overcommit hypothesis in this round; do not act on it.** The research offers
  `sudo sysctl -w vm.overcommit_memory=1` as a cheap additive layer. It is deliberately excluded.
  Phase 1's instrumentation exists precisely to decide whether heuristic overcommit is refusing
  forks under apparent headroom; mutating that variable in the same push destroys the measurement
  the instrumentation was added to make, and would leave a *third* unfalsified "fix" in the file
  if the run came back green for an unrelated reason. Phase 1 logs the current
  `vm.overcommit_memory` / `vm.overcommit_ratio` values read-only, and Phase 4 records the sysctl
  change as the first rung of the escalation ladder, to be taken if and only if the trace shows
  `Committed_AS` approaching `CommitLimit` at the moment of failure.
- **Cache-save rather than fan-out reduction as the first move.** Both reduce external-process
  count; the cache route is additive, reversible, keeps every piece of logic `docgen-action`
  already owns correctly (bibliography prepass, source URIs, static assets, Pages integration),
  and is the only candidate directly confirmed from this repository's own run logs. The
  CLI-bypass route is a much larger change that works around the symptom without first
  establishing that the cache gate was the cause.
- **Remove `LEAN_NUM_THREADS` rather than lower it to a modest value now.** Keeping any value
  confounds the next run's reading the same way a sysctl change would. If a warm-cache run still
  OOMs on `FormalSystem`'s own fan-out, a modest cap becomes a targeted follow-up experiment
  with a clean baseline to compare against.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The first run after this change is still fully cold and still fails, and is misread as "the fix did not work" | H | H | Phase 4's comment and Phase 5's commit body both state the two-run convergence explicitly: run #1 proves the *save* fired, run #2 proves the *restore* shrinks the fan-out. Phase 5's verification criteria name the run-#1 success signal (a non-skipped cache-save post step) separately from the run-#2 one. |
| The cache-save step writes under a key `docgen-action`'s own restore step never looks up, making the whole fix silently inert | H | L | Reduced to a local check: GitHub's `hashFiles` is reproducible offline (sha256 over the sorted matched files' sha256 digests). Already run in this dispatch -- it yields `a123379d6db94f6a6c99fecd852af470f05772553661bc654a4c62dbce0f7b9d`, byte-for-byte the key in run 44492038639's `Cache not found for input keys` line. Phase 3 re-runs it as a gating step. |
| The path list drifts from what `docgen-action` computes after a future `lake update` adds or removes a dependency, silently caching too little | M | M | Phase 4's comment records the maintenance rule and marks the generic derivation explicitly approximate (it does not reproduce `Archive`/`Counterexamples` or the capitalization). A partial miss degrades to today's behavior rather than breaking anything. |
| The background memory sampler does not survive past its own step, or holds the step open | M | M | Phase 1 redirects all three file descriptors, detaches, and verifies the extracted shell body with `bash -n`; the reporting step is `if: always()` so an absent log prints a clear notice instead of failing. |
| `actions/cache/save` fails (key already reserved by a concurrent run) and adds a second, confusing failure to the job | L | M | `continue-on-error: true` on that step, so a save failure never alters the job's real outcome. |
| Even with Mathlib's fan-out cached away, `FormalSystem`'s own ~772-module fan-out still OOMs | M | M | Untestable before a warm-cache run exists. Phase 1's instrumentation measures it on the first run that reaches a warm-cache state; Phase 4 documents the `linglib` CLI-bypass escalation, version-verified against `doc-gen4` `v4.33.0-rc1`. |
| The rewritten header comment violates `no-task-references-in-deliverables.md` or `no-record-versioning-in-deliverables.md` (this file is outside `specs/**`) | M | M | Phase 4 states both constraints as explicit task items: durable anchors only (run IDs, commit SHAs, upstream paths), never "task N"; and no narration of the comment's own earlier wording ("previously", "no longer", "formerly"). Phase 5's gate 4 run checks the first mechanically. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

The chain is strictly linear, and that is a deliberate declaration rather than a logical
necessity: Phases 1-4 all edit the same single file, `.github/workflows/docs.yml`, so running any
two concurrently would collide on it. No phase may be parallelized with another.

---

### Phase 1: Add in-run memory instrumentation around the docgen step [COMPLETED]

**Goal**: Make the next failing run diagnosable from its own log alone -- in particular, decide
the overcommit/fork-refusal hypothesis without a further round-trip.

**Tasks**:
- [x] Add a step named "Record pre-docgen memory and overcommit state", placed after "Enlarge swap for the doc build" and before "Build and deploy doc-gen4 documentation". It runs `set -euo pipefail` then prints, each labelled: `free -h`; `grep -E '^(MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree|Committed_AS|CommitLimit)' /proc/meminfo`; `sysctl vm.overcommit_memory vm.overcommit_ratio vm.max_map_count`; `nproc`; `ulimit -a`. *(completed)*
- [x] In that same step, launch a detached background sampler writing one timestamped record every 15 seconds to `"$RUNNER_TEMP/docgen-mem.log"`: the `Committed_AS`, `CommitLimit`, `MemAvailable` and `SwapFree` lines from `/proc/meminfo`, plus `ps -eo rss,comm --sort=-rss | head -6`. Detach it correctly -- redirect stdin from `/dev/null` and both stdout and stderr into the log, background it, and `disown` -- so it survives the step's shell exiting and never holds the step open. Record its PID to `"$RUNNER_TEMP/docgen-mem.pid"`. *(completed)*
- [x] Add a step named "Report docgen memory trace", placed immediately after the docgen step, gated `if: always()`. It stops the sampler (`kill "$(cat "$RUNNER_TEMP/docgen-mem.pid")" 2>/dev/null || true`), then prints: the peak `Committed_AS` and the `CommitLimit` observed across the log; the peak RSS recorded for any `lake` or `doc-gen4` process; and the final 60 samples. If the log is absent, it prints an explicit notice saying so and exits 0 rather than failing. *(completed)*
- [x] Add a short comment on the pre-docgen step stating what question the trace answers: whether `fork()` is being refused under heuristic overcommit while apparent headroom remains, which is the one hypothesis the three failing runs' logs cannot settle. *(completed)*
- [x] Verify locally: `python3 -I -c "import yaml; yaml.safe_load(open('.github/workflows/docs.yml'))"` parses, and each new `run:` body, extracted to a temp file, passes `bash -n`. *(completed: step count 6->8, diff insertions-only confirmed)*

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `suite_selection_select ".github/workflows/docs.yml"` returns
`__FULL_SWEEP__` (run in the planning dispatch), so no repository suite covers this path and the
honest covering check is this one file's own syntax check -- `python3 -I -c "import yaml;
yaml.safe_load(open('.github/workflows/docs.yml'))"` plus `bash -n` on each extracted `run:`
body.

**Scope Hypothesis**: this phase is hypothesized to add exactly two steps to the single job in
`.github/workflows/docs.yml` and modify no existing step. Confirm by diffing: `git diff --
.github/workflows/docs.yml` must show only insertions, and the parsed step count must rise from
6 to 8 (`python3 -I -c "import yaml; print(len(yaml.safe_load(open('.github/workflows/docs.yml'))['jobs']['docs']['steps']))"`, which returns 6 before this phase).

**Files to modify**:
- `.github/workflows/docs.yml` - add a pre-docgen memory/overcommit snapshot step that also launches a detached background sampler, and an `if: always()` post-docgen step that stops the sampler and reports peaks plus the trace tail

**Verification**:
- `python3 -I -c "import yaml; yaml.safe_load(open('.github/workflows/docs.yml'))"` exits 0
- Each new `run:` body passes `bash -n`
- The parsed step count is 8
- `git diff` on the file shows insertions only

---

### Phase 2: Remove the refuted LEAN_NUM_THREADS env entry [NOT STARTED]

**Goal**: Act on the dispatch's explicit instruction to decide rather than leave the variable
inert, by removing it.

**Tasks**:
- [ ] Delete the `env:` block on the "Build and deploy doc-gen4 documentation" step, including the `LEAN_NUM_THREADS: "1"` entry and the five comment lines above it that describe the cap as the remedy.
- [ ] Leave no orphaned `env:` key and no trailing blank mapping; the step must go directly from `uses:` to `with:`.
- [ ] Do not write the refutation narrative here -- it belongs in the header comment, rewritten in Phase 4, so the account lives in one place rather than two.
- [ ] Verify locally: the file still parses, and `grep -c LEAN_NUM_THREADS .github/workflows/docs.yml` returns 0 (the header comment's own references to it are removed in Phase 4, so a non-zero count at the end of this phase means only the header, which Phase 4 then clears -- confirm by eye that every remaining hit is inside the leading comment block).

**Timing**: 15 minutes

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this path, so the
covering check is the same single-file one -- `python3 -I -c "import yaml;
yaml.safe_load(open('.github/workflows/docs.yml'))"` plus a `grep` confirming the `env:` key is
gone from the docgen step's mapping.

**Scope Hypothesis**: this phase is hypothesized to be a pure deletion touching only the docgen
step. Confirm by `git diff -- .github/workflows/docs.yml` showing deletions only, and by
`python3 -I -c "import yaml; d=yaml.safe_load(open('.github/workflows/docs.yml')); s=[x for x in d['jobs']['docs']['steps'] if x.get('id')=='docgen'][0]; print('env' in s)"` printing `False`.

**Files to modify**:
- `.github/workflows/docs.yml` - delete the `env:` block (and its explanatory comment) on the docgen step

**Verification**:
- The file parses under `yaml.safe_load`
- The docgen step mapping has no `env` key
- `git diff` on the file shows deletions only

---

### Phase 3: Add an `if: always()` actions/cache/save step that breaks the post-if gate [NOT STARTED]

**Goal**: Persist the Mathlib/dependency doc markers a failing run already built, so the
following run restores them and spawns `doc-gen4` only for `FormalSystem`'s own modules.

**Tasks**:
- [ ] Resolve the commit SHA for `actions/cache` tag `v4.2.3` (`gh api repos/actions/cache/git/ref/tags/v4.2.3 --jq .object.sha`, dereferencing an annotated tag if the object type is `tag`). Confirm it begins `5a3ec84`, matching the pin `docgen-action`'s own `action.yml` carries. If it does not, stop and report rather than pinning a SHA that differs from the one the action itself restores with.
- [ ] Re-run the cache-key reproduction before writing the step, and treat a mismatch as a stop condition. Using `python3 -I`, compute sha256 over the sorted-path concatenation of the sha256 *digests* of `lake-manifest.json` and `references.bib`; it must equal `a123379d6db94f6a6c99fecd852af470f05772553661bc654a4c62dbce0f7b9d`, the key in run 44492038639's `Cache not found for input keys` line. This confirms `hashFiles('lake-manifest.json', 'references.bib')` reproduces what `docgen-action` computes internally as `hashFiles('lake-manifest.json', inputs.references)` for this workflow's `references: references.bib` input.
- [ ] Recover the authoritative `path:` list verbatim from the run's own log rather than from a transcription: `gh run view 44492038639 --log` and read the `path:` input echoed by the "Cache Mathlib docs" step. Do not derive the list from `lake-manifest.json` -- the derivation is known not to reproduce it (`Archive` and `Counterexamples` are absent from the manifest, and the manifest's casing differs from the directory names).
- [ ] Add a step named "Persist the Mathlib docs cache even when the doc build fails", placed immediately after the docgen step, with `if: always()`, `continue-on-error: true`, `uses: actions/cache/save@<resolved sha>  # v4.2.3`, `key: Docs-${{ hashFiles('lake-manifest.json', 'references.bib') }}`, and the verbatim `path:` block.
- [ ] Order this step relative to Phase 1's "Report docgen memory trace" step deliberately and state the choice in a comment: place the cache save first, so the save is attempted before anything else runs in the failure path.
- [ ] Write the step's own comment explaining why a step that looks redundant with the action's internal cache is not: `actions/cache`'s save (post) action is declared `post-if: "success()"`, and this job has never reached `success`, so the internal save has been skipped on every run -- directly observed as `outcome=skipped;conclusion=skipped` on the "Cache Mathlib docs" post-action in run 44492038639. Note in the same comment that `actions/cache/save` under an already-populated key is a safe no-op.
- [ ] Verify locally: the file parses; the new step's `key:` string matches the expression above character-for-character; the `path:` block's entry count equals the log's.

**Timing**: 60 minutes

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this path, so no
suite covers it; the covering checks are the single-file `yaml.safe_load` parse plus the exact
cache-key reproduction, which settles the one property (key equality with what `docgen-action`
restores) that would otherwise require a pushed run.

**Scope Hypothesis**: the `path:` list is hypothesized to be the 41 entries printed by run
44492038639's "Cache Mathlib docs" step -- 11 dependency module directories (`Mathlib`,
`Archive`, `Counterexamples`, `Plausible`, `LeanSearchClient`, `ImportGraph`, `ProofWidgets`,
`Aesop`, `Qq`, `Batteries`, `Cli`), 4 implicit core module directories (`Init`, `Lake`, `Lean`,
`Std`), and the remaining `doc-data`, database, manifest and static-asset paths. Confirm by
counting the entries in that step's own echoed `path:` input from `gh run view 44492038639
--log`, not by trusting this count or the research report's transcription; if the live count
differs, the log wins and this hypothesis is recorded as corrected.

**Files to modify**:
- `.github/workflows/docs.yml` - add an actions/cache/save step after the docgen step gated with if-always plus continue-on-error, SHA-pinned to actions/cache v4.2.3, carrying the action's own cache key expression and the verbatim path list

**Verification**:
- The locally computed `hashFiles` value equals `a123379d6db94f6a6c99fecd852af470f05772553661bc654a4c62dbce0f7b9d`
- The pinned SHA resolves to `actions/cache` tag `v4.2.3` and matches `docgen-action`'s own `5a3ec84` prefix
- The `path:` entry count equals the count in run 44492038639's own log
- `python3 -I -c "import yaml; yaml.safe_load(open('.github/workflows/docs.yml'))"` exits 0
- The new step carries both `if: always()` and `continue-on-error: true`

---

### Phase 4: Rewrite the header comment to state measured reality [NOT STARTED]

**Goal**: Leave the file's leading comment block describing what is measured and what is closed,
so the next reader neither re-tries a refuted route nor deletes the new cache step as redundant.

**Tasks**:
- [ ] Replace the memory paragraphs of the leading comment block (currently lines ~18-53) with an account built from measured facts: the failure is Lake failing to *spawn* a `doc-gen4` child (`failed to execute '.../doc-gen4': resource exhausted (error code: 12, cannot allocate memory)`), not Lean exhausting its own heap; the governing quantity is therefore external-process fan-out, not in-process thread count.
- [ ] State the root cause: the `docs` library facet cascades `docInfo` into the entire Mathlib import closure (~6,300 targets), and that fan-out recurs in full on every run because `actions/cache`'s save action is `post-if: "success()"` and this job fails first -- so the action's internal Mathlib-docs cache has never been populated.
- [ ] Record the closed routes with their evidence, each anchored to a run ID or a verifiable command, so none is re-tried: `LEAN_NUM_THREADS: "1"` (run 44492038639, commit `3bd8b2b31`: applied correctly, 48 allocation errors against 13 and 15 on runs 44457344329 and 44477674624, and docgen wall-clock up to 13m20s from 8-10m); swap enlargement (15 GiB RAM plus 15 GiB swap confirmed active by the swap step's own `free -h`, still insufficient); a larger GitHub-hosted runner (organization/enterprise-only, unavailable to a personal free-plan account); and Lake job-count flags (Lake 5.0.0 rejects `-j2`, `--jobs=2`, and `-j` in the global position before the subcommand).
- [ ] State the two-run convergence expectation in the comment: the first run after this change is still cold and may still fail, but will for the first time populate the cache; the second run should restore it and reduce the fan-out to `FormalSystem`'s own modules.
- [ ] Record the escalation ladder in order: first, read the memory trace and, only if `Committed_AS` approaches `CommitLimit` at failure, set `vm.overcommit_memory=1` (or raise `vm.overcommit_ratio`) via `sudo sysctl -w` in a step before the doc build; second, if a warm-cache run still OOMs on `FormalSystem`'s own fan-out, drive `doc-gen4`'s own `single`/`fromDb` subcommands directly over `find FormalSystem -name '*.lean'` with an explicit `xargs -P N`, as `linglib-community/linglib` does in production (its commit `97ec249684` -- CLI surface confirmed present at `doc-gen4` tag `v4.33.0-rc1`, the tag `build_docs.sh`'s `determine_doc_gen_rev` resolves to for this `lean-toolchain`).
- [ ] Record the path-list maintenance rule next to the cache step or in the header: the list is copied verbatim from the action's own echoed `path:` input, and the "one directory per `lake-manifest.json` package plus the four implicit core modules" rule is an approximate hint only -- it omits `Archive` and `Counterexamples` and differs in capitalization. Revisit after any `lake update` that changes the dependency set.
- [ ] Remove every remaining `LEAN_NUM_THREADS` mention and the "raise the value to 2" fallback ladder from the comment, so `grep -c LEAN_NUM_THREADS .github/workflows/docs.yml` returns 0 except where the comment names it as a measured-closed route.
- [ ] Observe two repository rules while writing: cite durable anchors only -- run IDs, commit SHAs, upstream file paths -- and never a task number, since this file sits outside `specs/**` (`.claude/rules/no-task-references-in-deliverables.md`); and describe the current design without narrating the comment's own earlier wording -- no "previously", "no longer", "formerly", "used to" (`.claude/rules/no-record-versioning-in-deliverables.md`). Stating a measured fact about a past CI run is not record-versioning and is required here.
- [ ] Leave the non-memory prerequisite paragraphs (lakefile.toml, lean-action ordering, Pages source, push event, `homepage`/`build-page`, the SHA-pinning rationale) intact -- they remain accurate.

**Timing**: 40 minutes

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this path, so no
suite covers it; this phase changes comment text only, and the covering checks are the
single-file `yaml.safe_load` parse plus `bash .claude/scripts/verify-deploy.sh --only-gate 4`,
the task-reference lint, which is a real non-skipping gate in this deploy-consumer repository.

**Scope Hypothesis**: this phase is hypothesized to change comment lines only, with no change to
any executable key. Confirm by re-parsing the file before and after and diffing the parsed
structures (`python3 -I -c` loading both the committed and working copies and comparing) -- the
two must be identical.

**Files to modify**:
- `.github/workflows/docs.yml` - rewrite the leading comment block's memory paragraphs; add the path-list maintenance note

**Verification**:
- The parsed YAML structure is byte-identical before and after (comment-only change)
- `bash .claude/scripts/verify-deploy.sh --only-gate 4` passes
- `grep -niE '\b(previously|no longer|formerly|used to)\b' .github/workflows/docs.yml` returns nothing
- `grep -niE 'task [0-9]+' .github/workflows/docs.yml` returns nothing
- The comment names runs 44492038639, 44477674624 and 44457344329 and commit `3bd8b2b31` as its anchors

---

### Phase 5: Full-gate validation, local commit, and push handoff [NOT STARTED]

**Goal**: Close the task at a verified local commit that states honestly what has and has not
been proven, and names the user's push as the remaining step.

**Tasks**:
- [ ] Re-read the whole of `.github/workflows/docs.yml` top to bottom and confirm step order: Pages check, checkout, lean-action build, redirect, swap, pre-docgen memory snapshot, docgen, cache save, memory trace report.
- [ ] Confirm the full step inventory parses and that `if: always()` is present on both the cache-save and the memory-trace steps, so neither is skipped on the failure path the workflow currently always takes.
- [ ] Optionally lint with `actionlint` if it can be obtained without network cost (`nix run nixpkgs#actionlint -- .github/workflows/docs.yml`); record the result either way, and treat an unavailable linter as an absence of evidence rather than a pass.
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. Observe it green in this dispatch; do not trust it on sight.
- [ ] Commit with `bash .claude/scripts/git-commit-scoped.sh`, staging `.github/workflows/docs.yml` and the task directory explicitly. Never `git add -A`, `git add .`, or a directory/glob pathspec.
- [ ] Write the commit body so the verification state is unambiguous: what is proven locally (the cache key reproduces exactly; the workflow parses; the pinned SHA resolves to `actions/cache` v4.2.3), what is not proven (that the OOM is fixed), and the two-run convergence -- the first push proves the cache *saves*, the second proves the restore shrinks the fan-out.
- [ ] Do not push, do not open a PR, do not invoke `/merge`. Report the push as the user's remaining step, per `.claude/rules/pr-prohibition.md`.
- [ ] State in the summary and handoff that the objective is NOT met and cannot be claimed met until a green `API Documentation` run exists -- naming the success signals to check on the user's first push (the cache-save step reports a completed save rather than `outcome=skipped`, and the memory trace prints) and on the second (a `Cache restored from key: Docs-a123379d...` line, and a materially shorter docgen step).

**Timing**: 30 minutes

**Depends on**: 4

**Verification Tier**: full

**Files to modify**:
- `.github/workflows/docs.yml` - final read-through only; no further edits expected

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` runs green in this dispatch (the complete gate set, run and observed, not assumed)
- `python3 -I -c "import yaml; yaml.safe_load(open('.github/workflows/docs.yml'))"` exits 0 and the step order matches the list above
- `git log -1 --stat` shows exactly the intended files staged, and `git status --short` shows no unintended residue
- No `git push`, `gh pr create`, or `/merge` was invoked
- The summary and handoff state the objective as unmet pending a green pushed run, with the per-run success signals named

---

## Testing & Validation

- [ ] `.github/workflows/docs.yml` parses under `yaml.safe_load` after every phase
- [ ] Every new `run:` body passes `bash -n`
- [ ] The locally reproduced `hashFiles` value equals the key observed in run 44492038639's log
- [ ] The `actions/cache/save` pin resolves to tag `v4.2.3` and shares `docgen-action`'s `5a3ec84` prefix
- [ ] The `path:` entry count matches the live log, not a transcription
- [ ] `bash .claude/scripts/verify-deploy.sh` green before the final commit
- [ ] No task-number reference and no record-versioning phrasing in the workflow file
- [ ] No push, PR, or `/merge` performed

## Artifacts & Outputs

- `.github/workflows/docs.yml` -- instrumented, with the refuted env entry removed, an
  `if: always()` cache-save step added, and a header comment stating measured reality
- A local commit on `main` carrying that change, with a body stating the two-run convergence
- `specs/940_fix_api_docs_oom_process_spawn_enomem/summaries/02_*-summary.md`
- An explicit user-facing note that the push is the user's remaining step and that two pushed
  runs, not one, are needed before the fix's effect is visible

## Rollback/Contingency

Every change is confined to one file and is additive or deletive in isolation, so
`git revert <sha>` of the single commit restores the prior workflow exactly. Partial rollback is
equally cheap: the cache-save step, the two instrumentation steps, and the comment rewrite are
independent of one another and any one can be removed without disturbing the rest. If a phase
fails mid-way, the file is restored with `git checkout HEAD -- .github/workflows/docs.yml` after
taking a snapshot (`bash .claude/scripts/git-snapshot.sh 940 --no-revert`) if uncommitted work
elsewhere exists. Nothing here touches build outputs, Lean sources, or the deployed `.claude/`
tree, so no regeneration or rebuild is implied by a rollback.
