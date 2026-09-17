# Implementation Plan: Task #578

- **Task**: 578 - Fix API documentation CI integration
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/578_fix_api_documentation_ci_integration/reports/01_docgen-ci-fix-path.md
- **Artifacts**: plans/01_docgen-ci-fix-path.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false (build-config / CI task; no proofs, no sorry/axiom surface)

## Overview

Migrate the Lake configuration from `lakefile.lean` to a declarative `lakefile.toml` (generated
by `lake translate-config toml`, shown lossless by research), renaming the package `Logos` ->
`BimodalLogic` in the same change. Every repo site that scrapes `lakefile.lean` text (one in
`ci.yml`, four Python blocks in `scripts/check-module-invariants.sh`, plus C9's scanned-file list)
is repointed at one shared `tomllib`-based helper, landing in the same atomic commit as the
migration so no intermediate commit has a lakefile its scrapers cannot read. The docs workflow is
then rewritten (lean-action first, isolated `homepage`, pinned action SHA) and re-enabled as
`.github/workflows/docs.yml`; prose references are updated; and a final, user-authorized phase
enables GitHub Pages and verifies a green run on a push to `main`.

### Research Integration

- docgen-action reads only `lakefile.toml` keys `name` and `defaultTargets`; no `lakefile.lean`
  support exists or is proposed upstream -> fix path (a), migration, adopted.
- `lake translate-config toml` round-trips; defaults (`srcDir = "."`, `roots = [name]`) are
  omitted in output, which breaks the current regex scrapers (esp. `LAKE_LIB_ROOTS`).
- The disabled workflow has two latent defects beyond the lakefile: no `leanprover/lean-action`
  step (elan/Mathlib cache absent) and `homepage: docs` uploading the whole hand-written `docs/`
  tree with the API nested at `/docs/docs/`.
- Deploy steps run only on `push` events; Pages is not configured (API returns 404).
- Package rename `Logos` -> `BimodalLogic` has no doc-URL effect (Pages URL is repo-derived,
  page paths module-derived); only couplings are lakefile `name` and `lake-manifest.json` L94.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

Not consulted (no roadmap_path in dispatch).

## Decisions

- **Fix path**: migrate to `lakefile.toml` (research option a). Upstream support (b) and a
  hand-rolled doc-gen4 workflow (c) rejected per report's Decisions section.
- **Package name**: `BimodalLogic` (matches repository, cslib convention package = repo; kept
  distinct from library `FormalSystem`). Doc URL effect: none —
  `https://benbrastmckie.github.io/BimodalLogic/docs/FormalSystem/...html` either way.
- **Scraper consolidation**: introduce one helper `scripts/lake_targets.py` (modes: `exe-roots`,
  `lib-roots`, `exes` printing `target<TAB>root<TAB>srcDir`) rather than five inline `tomllib`
  copies. Rationale: the existing comment at "The lakefile root scrape: ONE site" already argues
  for a single scrape; the helper extends that to `ci.yml` and C6/C25N. Missing/unparseable
  `lakefile.toml` must exit non-zero — the current `except OSError: raise SystemExit(0)` /
  `pass` fallbacks in C6, C25N, and the root scrape would turn the migration into a SILENT pass,
  so they are replaced with loud failures.
- **Action pin**: pin `leanprover-community/docgen-action` to commit `56023ee2` (full SHA to be
  resolved at implementation via `gh api`) instead of `@main`.

## Goals & Non-Goals

**Goals**:
- `lakefile.toml` is the sole Lake config; `lake build`, `lake test`, `lake lint` pass.
- Package named `BimodalLogic`; manifest root name matches.
- All lakefile scrapers read TOML and produce the same root sets as pre-migration (13 exe roots,
  2 lib roots).
- `.github/workflows/docs.yml` re-enabled and green on GitHub Actions, publishing only the API.

**Non-Goals**:
- Adding doc-gen4 as a dependency of the project lakefile/manifest (explicitly forbidden by the
  existing workflow header rationale).
- Running `lake update` or moving any dependency pin.
- Rewriting historical prose under `specs/**`.
- A Jekyll landing page (`build-page: false`).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Scrapers silently return empty/shrunken root lists on TOML | H | H | Shared helper fails loudly on missing file; Phase 1 baseline counts compared in Phase 2; keep empty-list = FAIL guards |
| `lakefile.lean` and `lakefile.toml` coexist (lean wins silently) | H | M | Phase 2 deletes `lakefile.lean` and `lakefile.lean.bak`; verification asserts absence |
| Config hash change triggers full local rebuild | M | H | Expected; run `lake build` detached/guarded per long-builds guidance; Mathlib cache unaffected |
| Concurrent agents editing `lakefile.lean` | M | L | Single atomic commit for Phase 2; re-check `git status` before starting |
| Pages not enabled -> deploy step fails | M | H | Phase 5 enables Pages before pushing |
| Pushing to `main` publishes ~148 unpushed local commits | H | H | Phase 5 requires explicit user authorization; implementer must stop with a blocking `user_decision` if not granted |
| Cold doc-gen4 build over Mathlib is slow (possible timeout) | M | M | Watch run with `gh run watch`; if job timeout hit, raise `timeout-minutes` and re-run; cache helps subsequent runs |
| `docgen-action` upstream changes | L | M | Pin commit SHA |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Capture Pre-Migration Baseline [COMPLETED]

**Goal**: Record the exact root sets and invariant-check results the migration must preserve.

**Tasks**:
- [x] Confirm `git status` shows no uncommitted edits to `lakefile.lean`, `lake-manifest.json`,
      `scripts/check-module-invariants.sh`, `.github/workflows/`.
- [x] Record exe roots: `grep -oP 'root\s*:=\s*`\K[A-Za-z0-9_.]+' lakefile.lean | sort` (expect 13).
- [x] Record lib roots from `roots := #[...]` (expect `BimodalTest`, `FormalSystem`) and the
      C25N `(target, root, srcDir)` triples.
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and save the PASS/FAIL/INFO lines.
- [x] Save all of the above to the scratchpad (not the repo) for comparison in Phase 2.

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: 13 `lean_exe` roots and 2 `lean_lib` roots. Confirm by the grep above
before relying on the numbers; if different, use the observed counts as the baseline.

**Files to modify**:
- None (scratchpad only)

**Verification**:
- Baseline file exists with exe roots, lib roots, C25N triples, and invariant-check summary.

---

### Phase 2: Migrate to lakefile.toml and Repoint Scrapers (atomic) [NOT STARTED]

**Goal**: Replace `lakefile.lean` with an equivalent `lakefile.toml` named `BimodalLogic`, and
update every scraper in the same commit.

**Tasks**:
- [ ] Run `lake translate-config toml`; delete the produced `lakefile.lean.bak` and ensure
      `lakefile.lean` is gone.
- [ ] Set `name = "BimodalLogic"`; restore per-exe and header docstrings as `#` comments (no
      task-number citations — C9 still scans the lakefile).
- [ ] Edit `lake-manifest.json` root `"name": "Logos"` -> `"BimodalLogic"` by hand (no
      `lake update`).
- [ ] Diff the TOML against the old lakefile setting-by-setting: `testDriver`, `lintDriver`,
      `defaultTargets = ["FormalSystem"]`, mathlib `rev = "v4.33.0-rc1"`, both libs' `srcDir` and
      `leanOptions` (`pp.unicode.fun = true`, `autoImplicit = false`), 13 exes with `root`,
      `supportInterpreter = true`, `srcDir = "scripts"` on `checkInitImports`.
- [ ] Create `scripts/lake_targets.py` (Python 3.11+ `tomllib`): `exe-roots` prints each exe
      `root` (default: exe name); `lib-roots` prints `roots or [name]` per lib; `exes` prints
      `name\troot\tsrcDir-or-.`. Exit 2 with a stderr message if `lakefile.toml` is missing or
      unparseable.
- [ ] `scripts/check-module-invariants.sh`: repoint C6 reachability (~L864), `LAKE_EXE_ROOTS` /
      `LAKE_LIB_ROOTS` (~L2035-2056), and C25N parser (~L3085) at the helper; replace the
      silent `SystemExit(0)`/`pass` fallbacks with a failure; update C9's scanned-path list
      (~L1131) and all `lakefile.lean` message/comment strings to `lakefile.toml`.
- [ ] `.github/workflows/ci.yml` "Compile lean_exe roots" step: `roots=$(python3
      scripts/lake_targets.py exe-roots)`, keep `test -n "$roots"`; update the comment block.
- [ ] Build: `lake build` (detached with log, poll to completion), then `lake test`, `lake lint`.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build`, then the full mode (C25, C16
      roots); compare root counts and PASS set with Phase 1 baseline.
- [ ] Negative check in a scratch copy: temporarily move `lakefile.toml` away and confirm the
      helper and the scrape sites fail loudly (not pass); restore.
- [ ] Commit all of the above as one commit.

**Timing**: 2 hours (includes rebuild wait)

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Five scrape sites (ci.yml 1, check-module-invariants.sh 4) plus C9's path
list. Confirm with `grep -rn "lakefile" scripts .github --include=*.sh --include=*.py
--include=*.yml` before and after — no remaining functional `lakefile.lean` reads.

**Files to modify**:
- `lakefile.toml` - new, sole Lake config
- `lakefile.lean` - deleted
- `lake-manifest.json` - root name
- `scripts/lake_targets.py` - new shared TOML target reader
- `scripts/check-module-invariants.sh` - scrapers, C9 path list, messages
- `.github/workflows/ci.yml` - exe-roots step

**Verification**:
- `test ! -e lakefile.lean && test -e lakefile.toml`
- `lake build`, `lake test`, `lake lint` exit 0.
- `python3 scripts/lake_targets.py exe-roots | wc -l` = baseline (13); `lib-roots` = baseline (2).
- `check-module-invariants.sh` full run: no new FAIL vs. baseline; C25 reports 13 roots.

---

### Phase 3: Rewrite and Re-enable docs.yml [NOT STARTED]

**Goal**: A correct docs workflow at `.github/workflows/docs.yml`.

**Tasks**:
- [ ] `git mv .github/workflows/docs.yml.disabled .github/workflows/docs.yml`.
- [ ] Steps: `actions/checkout` (fetch-depth 0) -> `leanprover/lean-action@v1` with
      `build: true`, `test: false`, `lint: false`, `use-mathlib-cache: true` ->
      `leanprover-community/docgen-action@<full SHA of 56023ee2>` with `build-page: false`,
      `blueprint: false`, `homepage: api-site`, and `references: references.bib` only if that
      file exists (otherwise omit the input).
- [ ] Check triggers include `push` to `main` (deploy only runs on push) and keep
      `workflow_dispatch`; confirm required `permissions` (`contents: read`, `pages: write`,
      `id-token: write`) against the pinned action's README.
- [ ] Rewrite header comment: remove DISABLED block and the incorrect "publishes the API
      documentation alone" claim; state lakefile.toml requirement, lean-action precondition,
      `homepage: api-site` rationale, resulting URL, and the no-doc-gen4-in-manifest rule.
- [ ] Lint YAML (`actionlint` if installed, else `python3 -c 'import yaml,sys;
      yaml.safe_load(open(...))'`).
- [ ] Commit.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `.github/workflows/docs.yml` - renamed from `.disabled`, rewritten

**Verification**:
- YAML parses; `homepage` folder `api-site` does not exist in the repo; action pinned to a SHA.

---

### Phase 4: Update Prose References [NOT STARTED]

**Goal**: Documentation accurately names `lakefile.toml` and package `BimodalLogic`.

**Tasks**:
- [ ] `CLAUDE.md` "Lean Version" section: requested Mathlib tag is in `lakefile.toml`.
- [ ] `docs/development/CI_CD_PROCESS.md` (~L104): lakefile name; add a short note on
      `scripts/lake_targets.py` as the single scrape and on docs-workflow prerequisites
      (lakefile.toml, lean-action first, Pages source = GitHub Actions, push-only deploy).
- [ ] Sweep `grep -rn "lakefile.lean\|package Logos" --exclude-dir=specs --exclude-dir=.lake
      --exclude-dir=.claude --exclude-dir=agent-system .` and update current-state prose in
      docs/READMEs/typst; keep `typst/sync-check-whitelist.txt` and
      `scripts/typst-machine-appendix.sh` comments accurate. Leave clearly historical text alone.
- [ ] No task-number citations in any edited deliverable.
- [ ] Commit.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: ~30 prose mentions (research estimate). Confirm with the grep above; the
count may differ.

**Files to modify**:
- `CLAUDE.md`, `docs/development/CI_CD_PROCESS.md`, plus files found by the sweep

**Verification**:
- Grep sweep returns only intentionally historical mentions.
- `bash scripts/check-module-invariants.sh --no-build` (C5/C9) still passes.

---

### Phase 5: Enable Pages, Push, and Verify Green Run [NOT STARTED]

**Goal**: Observe `docs.yml` (and `ci.yml`) green on GitHub Actions with the API published.

**Tasks**:
- [ ] **Authorization gate**: local `main` is ~148 commits ahead of `origin/main`; pushing
      publishes all of them and enabling Pages makes a public site. Proceed only with explicit
      user authorization for both; otherwise stop at a resumable point and return a blocking
      `user_decision` (push + enable Pages now / defer).
- [ ] Enable Pages with source GitHub Actions (UI: Settings -> Pages -> Source = GitHub
      Actions; or `gh api -X POST repos/benbrastmckie/BimodalLogic/pages -f build_type=workflow`
      if permitted). Confirm `gh api repos/benbrastmckie/BimodalLogic/pages` no longer 404s.
- [ ] `git push origin main`.
- [ ] `gh run list --workflow docs.yml` / `gh run watch` until complete; same for `ci.yml`.
- [ ] On failure: read logs (`gh run view --log-failed`), fix in a follow-up commit, push,
      re-watch. Timeouts: add/raise `timeout-minutes`.
- [ ] Fetch `https://benbrastmckie.github.io/BimodalLogic/docs/` and one module page (e.g.
      `docs/FormalSystem.html`) to confirm deployment.

**Timing**: 1.25 hours (dominated by CI wall time)

**Depends on**: 3, 4

**Verification Tier**: full

**Files to modify**:
- None expected (fix-up commits only if the run fails)

**Verification**:
- `gh run list --workflow docs.yml --limit 1 --json conclusion` = `success` on a push event.
- `ci.yml` run on the same push = `success`.
- API index page returns HTTP 200.

## Testing & Validation

- [ ] `lakefile.lean` absent; `lakefile.toml` present with `name = "BimodalLogic"`.
- [ ] `lake build`, `lake test`, `lake lint` pass locally.
- [ ] Scraped root counts equal pre-migration baseline; helper fails loudly without the file.
- [ ] `check-module-invariants.sh` full run introduces no new FAIL.
- [ ] `docs.yml` and `ci.yml` green on a push to `main`; API reachable at the Pages URL.

## Artifacts & Outputs

- `lakefile.toml`, `scripts/lake_targets.py`, updated `lake-manifest.json`,
  `scripts/check-module-invariants.sh`, `.github/workflows/ci.yml`, `.github/workflows/docs.yml`
- Updated prose docs
- Implementation summary under `specs/578_fix_api_documentation_ci_integration/summaries/`

## Rollback/Contingency

- Phase 2 is a single commit: `git revert` it to restore `lakefile.lean`, the `Logos` name, and
  the regex scrapers together.
- If docs workflow cannot be made green within the phase budget, rename back to
  `docs.yml.disabled` with an updated header recording the new failure cause; the lakefile
  migration stands on its own (CI still green).
- Pages can be disabled via Settings if the published site is unwanted.
