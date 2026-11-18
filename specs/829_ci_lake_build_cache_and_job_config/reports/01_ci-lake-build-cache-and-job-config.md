# Research Report: Task #829

**Task**: 829 - Ci lake build cache and job config
**Started**: 2026-11-18T23:32:00Z
**Completed**: 2026-11-18T23:50:00Z
**Effort**: small
**Dependencies**: None
**Sources/Inputs**: Codebase (`.github/workflows/*.yml`, `lakefile.toml`, `lake-manifest.json`), `gh api`/`gh run view` against this repository's live Actions history, `leanprover/lean-action` upstream `action.yml` (both the `v1` moving tag's current resolution and the pinned `v1` tag's source)
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The task's central premise is refuted by live evidence, not just a stale grep.** Re-grepping
  `.github/workflows/` at research time still finds no literal `actions/cache` step there — that
  part of the "VERIFIED AT FILING" note is textually accurate. But all three workflows invoke
  `leanprover/lean-action@v1`, and that composite action has shipped its own built-in
  `actions/cache/restore` + `actions/cache/save` pair around the ENTIRE `.lake` directory (which
  contains `.lake/build`) since at least `v1.0.0`, defaulting `use-github-cache: true` when a
  caller does not override it — which none of this repo's three workflows do. A live check of
  this repository's GitHub Actions cache store (`gh api .../actions/caches`) found **4 real,
  currently-live cache entries** (~2.6 GB each, keyed `lake-Linux-X64-<toolchain-hash>-<manifest-hash>-<sha>`),
  and a run log from the most recent completed `ci.yml` run shows an explicit
  `Cache restored from key: lake-Linux-X64-...-c8aa0119...` line followed by a ~49-second tar
  restore of a prior commit's `.lake` tree. **`.lake/build` for `FormalSystem`/Mathlib is already
  being cached across CI runs, today, by default.**
- **A real, narrower caching gap does survive**, and it is the one the task's own "subordinate
  configuration finding 3" already names without connecting it to caching: the GH cache
  save happens *inside* the `lean-action` composite step, which runs *before* `ci.yml`'s four
  subsequent sequential `lake build` invocations (the 15-target `lean_exe` root loop,
  `BimodalTools --wfail`, `BimodalToolsTest --wfail`). Those artifacts are written to
  `.lake/build` *after* the cache was already saved, so they are never persisted and are
  re-elaborated from scratch on every run, unlike `FormalSystem`.
- **Recommendation reversal on deliverable (a) as filed**: adding a second, separately-keyed
  `actions/cache` step scoped to `.lake/build` (as literally specified) would not add coverage —
  it would race and duplicate the cache `lean-action` already manages on the same path, doubling
  compression/upload cost and GitHub Actions cache-storage consumption for no net benefit. The
  cheap, safe deliverable that remains is part **(b)**: `timeout-minutes` parity on `ci.yml`'s
  `build` job.
- `lakefile.toml`'s greenfield build-performance posture (finding 2) and the serial-job/no-matrix
  observation (finding 3) are both confirmed as written; no change is recommended for either
  without a before/after timing, per the dispatch's own GUARDRAIL.

## Context & Scope

Researched whether `.github/workflows/ci.yml`, `docs.yml`, and `release.yml` lack a build-artifact
cache for the project's own `.lake/build` output, and whether `ci.yml`'s `build` job needs
`timeout-minutes` parity with `docs.yml`. Scope per the dispatch's FILE SCOPE is
`.github/workflows/ci.yml` and `lakefile.toml`; `docs.yml`/`release.yml` were read only for
comparison (the dispatch names them as corroborating, not as edit targets). The dispatch's
STANDING INSTRUCTION ("re-grep before citing") was followed: every line number below was
re-confirmed against the current tree, and the caching claim was additionally checked against
live CI behavior (not just static grep), because the composite action in use is exactly the kind
of indirection a pure grep of `.github/workflows/` cannot see through.

## Findings

### Codebase Patterns

- `ci.yml`'s `build` job is declared at line 17 (`runs-on: ubuntu-latest` at line 19) with no
  `timeout-minutes` key anywhere in the job — confirmed by a full re-grep of the file
  (`grep -n timeout-minutes .github/workflows/*.yml` returns only `docs.yml:57`). This inherits
  GitHub's 360-minute default. `docs.yml`'s `docs` job sets `timeout-minutes: 300` at line 57.
  `release.yml`'s `release` job also has no `timeout-minutes` (ancillary observation; out of this
  task's FILE SCOPE, not part of either deliverable).
- All three workflows set `use-mathlib-cache: true` on their `leanprover/lean-action@v1` step
  (`ci.yml:55`, `docs.yml:92`, `release.yml:115`) — re-confirmed, unchanged from filing. This
  input controls only `lake exe cache get` (the remote Mathlib-olean fetch); it is unrelated to
  the GitHub Actions cache discussed below.
- A literal `actions/cache` step, `key:`, or `restore-keys:` line is absent from every file under
  `.github/workflows/` — re-confirmed (`grep -rn "actions/cache\|restore-keys\|^\s*key:"
  .github/workflows/` returns no matches). This grep result is accurate but, as the next
  subsection shows, does not establish the conclusion the task draws from it.
- `lakefile.toml` carries zero build-performance configuration: no `moreLeanArgs`,
  `precompileModules`, `extraDepTargets`, parallelism, or memory setting anywhere in the file —
  re-confirmed by reading the full file. Its only `[leanOptions]` are
  `weak.linter.mathlibStandardSet`, `weak.linter.style.longFile = 1500`, and
  `weak.linter.unicodeLinter = false`, all linter-related. This matches the dispatch's framing
  exactly: a greenfield area, not a misconfiguration.
- `ci.yml` is a single job (`build`) with no `strategy:`/`matrix:` key, and after the main
  `lean-action` step it runs four further sequential `lake build` invocations: the `lean_exe`
  root loop (line 71-80, 15 targets per `scripts/lake_targets.py`), `BimodalTools --wfail`
  (line 95-100), `BimodalToolsTest --wfail` (line 105-110), plus the later check-script steps —
  re-confirmed by reading the full file top to bottom (361 lines).
- Local `.lake/build` on this machine measures 6.4 GB (`du -sh .lake/build`), close to the
  6.3 GB figure recorded at filing; minor drift is expected as the library has grown since.

### External Resources — the lean-action composite action's own caching

This is the load-bearing finding this report adds beyond what a `.github/workflows/` grep can
see, because the mechanism lives in a separate repository (`leanprover/lean-action`) that this
project's workflows merely `uses:`.

- Fetched `action.yml` from `leanprover/lean-action` at the `v1` tag (currently resolving to
  commit `ba3fdfe5`, i.e. the `v1.7.1` release content) via `gh api
  repos/leanprover/lean-action/contents/action.yml?ref=v1`. It declares a `use-github-cache`
  input, default `"true"`, described as: *"If use-github-cache input is not provided,
  `lean-action` will use GitHub caching by default."* This input, and the cache steps it gates,
  are present in the `v1` tag the three workflows pin to, not only on an unreleased `main`.
- The composite action's `runs.steps` include, in order: `actions/cache/restore` (path
  `${lake-package-directory}/.lake`, key
  `lake-${runner.os}-${runner.arch}-${hashFiles(lean-toolchain)}-${hashFiles(lake-manifest.json)}-${github.sha}`,
  restore-keys the same prefix *without* `${github.sha}`) → configure → mk_all check (if
  requested) → Mathlib-cache detection → `lake exe cache get` (Mathlib) → `lake build` → `lake
  test` → `lake lint` → `actions/cache/save` (same path, same primary key, gated on `cache-hit !=
  'true'`, i.e. it only re-saves when the exact-sha key missed).
- None of this repository's three workflow invocations of `leanprover/lean-action@v1` set
  `use-github-cache: false` (re-confirmed by grep: `use-github-cache` does not appear anywhere in
  `.github/workflows/`), so all three run with GitHub Actions caching of `.lake` **on by
  default**.
- Confirmed this is not merely theoretically available but actually operating: `gh run view
  44411191783 --log` (the most recently *completed* `ci.yml` run as of this research, commit
  `c78a4ced`) shows, inside the "Build, test, and lint with Lean" step's own sub-log:
  `use-github-cache: true`; `Cache hit for restore-key: lake-Linux-X64-...-c8aa0119...` (a prior
  commit's cache, matched via the sha-less restore-keys fallback, not the exact-sha primary key);
  `Cache Size: ~2604 MB`; `Cache restored successfully` after a ~49-second tar/zstd extraction;
  and, at the end of the same step, an `actions/cache/save` attempt for the current sha (which in
  this particular run raced against a concurrent job's save for the same key and lost — `Failed
  to save: ... another job may be creating this cache` — a benign, expected race under concurrent
  runs, not a caching failure).
- Confirmed via `gh api repos/benbrastmckie/BimodalLogic/actions/caches` that this repository's
  Actions cache store currently holds 4 live entries, all under the `lake-Linux-X64-...` key
  family, sizes 2603-2605 MB, most recently created `2026-11-18T23:28:21Z` (for the current `main`
  HEAD) and ranging back to `2026-11-17T21:35:38Z`. This is the self-same path the task's
  deliverable (a) proposes to add caching for.
- **The real residual gap**: because `actions/cache/save` executes inside the single
  `lean-action` composite step, it runs *before* `ci.yml`'s four later sequential `lake build`
  steps (the `lean_exe` root loop, `BimodalTools --wfail`, `BimodalToolsTest --wfail`). Their
  output is written into `.lake/build` after the snapshot is already taken, so none of it is
  captured by the existing cache and all of it is re-elaborated from scratch on every run — even
  though `FormalSystem` itself is cache-accelerated. This is a real instance of "the project's own
  build artifacts are discarded between runs," just scoped to `BimodalTools`/`BimodalToolsTest`/
  the 15 `lean_exe` roots (per the task's own filing: "14,750 lines" of tooling, per an existing
  `ci.yml` comment) rather than to the whole 371,441-line library as originally framed.

## Recommendations

- **Do not implement deliverable (a) as literally specified.** A new, separately-keyed
  `actions/cache` step scoped only to `.lake/build` would run alongside `lean-action`'s own
  restore/save of the superset path `.lake` on the exact same files. Two independent cache
  systems writing overlapping content under different keys does not add coverage; it doubles the
  tar/zstd compression and upload time on every run, doubles the storage consumed against
  GitHub's per-repository cache quota (which uses LRU eviction once near its cap), and leaves
  restore ordering between the two steps unspecified in terms of which one's content survives on
  disk when both hit. There is no net correctness or performance benefit, and the dispatch's own
  ACCEPTANCE criterion ("a second CI run on an unchanged tree restores from cache rather than
  re-elaborating, visible in the run log") is **already satisfied today** by the mechanism
  documented above — re-running `ci.yml` on an unchanged tree already shows exactly this in the
  log.
- **Implement deliverable (b) as filed**: add `timeout-minutes: 300` (matching `docs.yml`'s
  value) to `ci.yml`'s `build` job. This is unaffected by the caching finding above and remains a
  cheap, uncontroversial parity fix within FILE SCOPE.
- **If the residual gap (BimodalTools/BimodalToolsTest/lean_exe roots not covered by the existing
  cache) is worth closing**, the correct shape is not "add a second cache step" but "move the
  single existing cache lifecycle to cover the whole job": set `use-github-cache: false` on the
  `lean-action` step and add an equivalent, explicitly-keyed `actions/cache/restore` immediately
  after checkout and an `actions/cache/save` as the LAST step of the job (after the `lean_exe`
  root loop and both `BimodalTools`/`BimodalToolsTest` compiles), using a key scheme like
  `lake-recheck-v3-${{ hashFiles('lean-toolchain') }}-${{ hashFiles('lake-manifest.json') }}` (an
  epoch segment such as `lake-recheck-v3-` is a sanctioned durable version axis under
  `rules/no-record-versioning-in-deliverables.md`). This is a genuine architecture change to the
  cache lifecycle (disabling the composite action's own cache and re-implementing an equivalent,
  wider one by hand), not the small addition the task as filed describes, and it has not been
  measured — flagging it as a candidate for a follow-up record rather than folding it into this
  one's deliverable (a), consistent with the GUARDRAIL's "measured experiments only" posture for
  anything beyond the two named deliverables.
- `lakefile.toml`'s greenfield build-performance surface (`moreLeanArgs`, `precompileModules`,
  `extraDepTargets`) and the serial/no-matrix CI shape remain exactly as filed, with the
  dispatch's own GUARDRAIL governing them: neither should land without a recorded before/after
  timing, and a matrix split's natural seams remain `Metalogic/Decidability/` (179 files,
  106,266 lines) and `Metalogic/Expressiveness/` (143 files, 104,211 lines), then
  `WeakCanonical/` (45/29,303) and `BXCanonical/` (28/23,165).

## Decisions

- Treat the task's filed deliverable (a) as superseded by this research's live-evidence finding:
  `.lake/build` for `FormalSystem`/Mathlib already receives GitHub Actions caching through
  `leanprover/lean-action@v1`'s default `use-github-cache: true`, confirmed both in the upstream
  action's source at the pinned `v1` tag and in this repository's own live run logs and cache
  store. The implementation phase should NOT add a redundant `actions/cache` step for this path.
- Keep deliverable (b) (timeout-minutes parity on `ci.yml`'s `build` job) as the sole concrete
  change this task's implementation phase should make within its FILE SCOPE.
- Record the newly-identified, narrower residual gap (BimodalTools/BimodalToolsTest/lean_exe
  roots not covered by the existing per-job cache boundary) as a candidate for a follow-up
  record rather than in-scope work here, since closing it requires disabling and replacing
  `lean-action`'s own cache lifecycle — a measured-experiment-shaped change under this task's own
  GUARDRAIL, not the small addition originally envisioned.

## Risks & Mitigations

- **Risk**: a planner reading only the task's filed description (not this report) could write a
  plan that adds the now-redundant `actions/cache` step. **Mitigation**: this report's Executive
  Summary and Decisions sections state the reversal plainly up front, and a `claim_invalidations`
  entry is recorded in this dispatch's `.return-meta.json` so the finding is machine-discoverable,
  not only prose.
- **Risk**: GitHub's cache eviction (LRU once a repository nears its cache-storage cap) could
  someday evict the `lean-action`-managed cache faster than expected if this repository's cache
  usage grows (e.g. from matrices or other workflows adding entries). **Mitigation**: no action
  needed now — the live check found only 4 entries at ~2.6 GB each, far under typical quota
  pressure; worth re-checking if a future change (e.g. the residual-gap fix above, or a matrix
  split) multiplies the number of distinct cache keys in play.
- **Risk**: the residual gap's suggested fix (disable `use-github-cache`, hand-roll a
  wider-scoped restore/save) could silently break if `lean-action` changes its own cache-save
  semantics in a later `v1.x` release this project tracks via the moving `v1` tag. **Mitigation**:
  out of scope here since the fix itself is deferred to a follow-up record; that record should
  re-verify `lean-action`'s current behavior at implementation time rather than relying on this
  report's snapshot.

## Context Extension Recommendations

- **Topic**: CI caching behavior of `leanprover/lean-action`.
- **Gap**: `docs/development/CI_CD_PROCESS.md` (referenced from `ci.yml`'s own header comment for
  the "Wiring a New Check Script" pattern) does not currently document that `leanprover/lean-action@v1`
  provides its own default-on GitHub Actions cache of `.lake`, scoped per-job, saved before any
  subsequent `lake build` step in the same job. A future contributor re-discovering "there's no
  explicit cache step" by grepping `.github/workflows/` will reach the same wrong conclusion this
  task's filing did, absent this documentation.
- **Recommendation**: add a short subsection to `docs/development/CI_CD_PROCESS.md` (or a new
  `.claude/context/project/lean4/operations/` note, if one exists for CI mechanics) stating: (1)
  `lean-action`'s `use-github-cache` defaults to `true` and caches the whole `.lake` directory,
  keyed on toolchain + `lake-manifest.json` + commit sha with a sha-less restore-keys fallback;
  (2) the cache snapshot is taken once, inside that single step, so any `lake build` invocation
  placed AFTER it in the same job (as `ci.yml` does for its `lean_exe` roots, `BimodalTools`, and
  `BimodalToolsTest`) is not covered and re-elaborates from scratch every run; (3) where to find
  the live cache entries (`gh api repos/<owner>/<repo>/actions/caches`) if this ever needs
  re-verifying.

## Appendix

- Search/verification commands used (all from the repository root):
  - `grep -n "timeout-minutes" .github/workflows/*.yml`
  - `grep -rn "actions/cache\|restore-keys\|^\s*key:" .github/workflows/`
  - `grep -n "use-mathlib-cache" .github/workflows/*.yml`
  - `cat lakefile.toml`, `cat lean-toolchain`, `du -sh .lake/build`
  - `gh api repos/leanprover/lean-action/contents/action.yml --jq '.content' | base64 -d`
  - `gh api repos/leanprover/lean-action/git/refs/tags/v1`
  - `gh api repos/leanprover/lean-action/contents/action.yml?ref=v1 --jq '.content' | base64 -d`
  - `gh run list --workflow=ci.yml --limit 5 --json databaseId,status,conclusion,createdAt,headSha`
  - `gh run view 44411191783 --log | grep -i -n "cache"`
  - `gh api repos/benbrastmckie/BimodalLogic/actions/caches`
- References: `specs/reviews/review-2026-11-02.md` (High Priority Issues, Medium Priority
  Issues), `leanprover/lean-action` upstream repository (`action.yml`, tag `v1` and its current
  resolution `v1.7.1`/`ba3fdfe5`).
