# Research Report: Task #578

**Task**: 578 - Fix API documentation CI integration
**Started**: 2026-09-17T00:49:31-07:00
**Completed**: 2026-09-17T01:05:00-07:00
**Effort**: 2-3 hours (migration + scrape-site updates + workflow fix + one push-to-main verification run)
**Dependencies**: None
**Sources/Inputs**: - Codebase (lakefile.lean, lake-manifest.json, .github/workflows/ci.yml, .github/workflows/docs.yml.disabled, scripts/check-module-invariants.sh), cslib precedent (/home/benjamin/Projects/cslib/lakefile.toml, .github/workflows/docs.yml), leanprover-community/docgen-action source (action.yml, src/index.js, scripts/build_docs.sh, README, PR list) via gh api, leanprover/lean-action action.yml, `lake translate-config` (Lake 5.0.0, Lean 4.33.0-rc1), GitHub run logs for the failed runs
**Artifacts**: - specs/578_fix_api_documentation_ci_integration/reports/01_docgen-ci-fix-path.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary
- docgen-action reads exactly two keys from `lakefile.toml`: `name` (used as the `[[require]] name` of a generated `docbuild/lakefile.toml` with `path = "../"`) and `defaultTargets` (turned into `<target>:docs` facets). It has never supported `lakefile.lean`, and no PR (open or closed, #1-#40) proposes it.
- `lake translate-config toml` produces a lossless declarative translation of this project's `lakefile.lean` (verified by round-tripping back to Lean and by loading the TOML in an isolated copy: `lake check-test` and `lake check-lint` both exit 0). Only comments/docstrings are lost; they can be re-added as TOML comments.
- The disabled `docs.yml` has TWO further latent defects that would fail or misbehave even after the lakefile is fixed: (1) no `leanprover/lean-action` step precedes the action, but `build_docs.sh` calls `~/.elan/bin/lake` and needs the Mathlib cache already fetched; (2) with `build-page: false` and the default `homepage: docs`, the upload step publishes the whole `docs/` folder (~100 hand-written markdown files) with the API under `/docs/docs/` -- the header comment's claim that this "publishes the API documentation alone" is wrong.
- **Recommended path: (a) migrate to `lakefile.toml`**, update the five `lakefile.lean` scrape sites (four in `scripts/check-module-invariants.sh`, one in `ci.yml`) to parse TOML via Python `tomllib`, and re-enable `docs.yml` with a lean-action build step and an isolated `homepage` folder.
- **Package name decision: rename `Logos` -> `BimodalLogic`.** It has no effect on doc URLs (see Decisions); the only couplings are `lakefile` `name` and the root `"name"` field of `lake-manifest.json`.

## Context & Scope
Researched why `.github/workflows/docs.yml` failed on every run (runs 34386791604, 34409867819: failure in ~15 s at the "Parse the project metadata" step) and chose among: migrate to TOML, upstream `lakefile.lean` support, or an alternative doc-gen4 integration. Constraint from the existing workflow header: doc-gen4 must NOT become a dependency of the project's own lakefile/manifest. Repo is public (Pages available on the free plan); the Pages site is currently not configured (`gh api repos/benbrastmckie/BimodalLogic/pages` -> 404).

## Findings
### Codebase Patterns
- `lakefile.lean` is fully declarative apart from `abbrev theoryLeanOptions` (inlined by translation). Settings: package `Logos`, `testDriver := "BimodalTest"`, `lintDriver := "batteries/runLinter"`, mathlib by git @ `v4.33.0-rc1`, `@[default_target] lean_lib FormalSystem` (srcDir ".", roots #[`FormalSystem]), `lean_lib BimodalTest` (srcDir "Tests"), both with `pp.unicode.fun = true, autoImplicit = false`, and 13 `lean_exe` targets (12 under `FormalSystem.Automation.*Main` with srcDir ".", `checkInitImports` with srcDir "scripts"), all `supportInterpreter := true`.
- Translation output (verified): `name = "Logos"`, `testDriver`, `lintDriver`, `defaultTargets = ["FormalSystem"]`, `[[require]] name="mathlib" git=... rev="v4.33.0-rc1"`, both `[[lean_lib]]` with inline `leanOptions`, 13 `[[lean_exe]]` with `root`/`supportInterpreter` (and `srcDir = "scripts"` on checkInitImports). Defaults (`srcDir = "."`, `roots = [name]`) are omitted, which matters for scrapers below.
- Consumers that parse `lakefile.lean` text and MUST be updated in the same commit:
  1. `.github/workflows/ci.yml` step "Compile lean_exe roots": `grep -oP 'root\s*:=\s*`\K...' lakefile.lean`.
  2. `scripts/check-module-invariants.sh` ~L866 (reachability roots for C6/C7).
  3. same file ~L2039 `LAKE_EXE_ROOTS` (C16/C25).
  4. same file ~L2049 `LAKE_LIB_ROOTS` (`roots := #[...]` regex -- after migration the roots key is absent/defaulted, so the replacement must fall back to the lib `name`).
  5. same file ~L3088 C25N block parser (target name, root, srcDir).
  Also: C9's path list (~L1131) names `lakefile.lean` as a scanned file; the `note`/`fail` message strings; `docs/development/CI_CD_PROCESS.md` L104; `CLAUDE.md` "Lean Version" section; and ~30 prose mentions in docs/READMEs/typst (non-blocking, but `typst/sync-check-whitelist.txt` and `scripts/typst-machine-appendix.sh` comments should be kept accurate). Python 3.13 locally; ubuntu-latest has >=3.12, so `tomllib` is available in CI.
- `lake-manifest.json` root `"name": "Logos"` (L94) must track any package rename; edit by hand rather than running `lake update` (which could move inherited deps).

### External Resources
- docgen-action `src/index.js`: `fs.readFileSync("lakefile.toml")` then `TOML.parse`; outputs `name`, `default_targets`, `docs_facets = defaultTargets.map(t => t + ":docs")`. No fallback.
- docgen-action `scripts/build_docs.sh`: writes `docbuild/lakefile.toml` with `packagesDir = "../.lake/packages"`, requires `$NAME` at `path = "../"` and `doc-gen4` at rev derived from `lean-toolchain` (`v4.33.0-rc1`; tag verified to exist in leanprover/doc-gen4, sha 498457de). Runs `~/.elan/bin/lake update $NAME` and `lake build $DOCS_FACETS`, then copies `docbuild/.lake/build/doc` to `$HOMEPAGE/docs`. It never installs elan -- the README's example (and cslib) put `leanprover/lean-action` first.
- docgen-action `action.yml`: API build, upload and deploy steps are all gated on `github.event_name == 'push'`; `workflow_dispatch` runs do nothing useful. Upload path is `<homepage>/` when Jekyll is not built.
- cslib precedent: `lakefile.toml` + `docs.yml` = checkout (fetch-depth 0) -> `leanprover/lean-action@v1` -> `docgen-action@main` with `build-page: false`.
- lean-action inputs `build`, `test`, `lint`, `use-mathlib-cache` exist and override auto-config.

### Recommendations
1. Migrate: generate `lakefile.toml` with `lake translate-config toml` (it renames the original to `lakefile.lean.bak`; delete that), set `name = "BimodalLogic"`, restore the per-exe docstrings as `#` comments, update `lake-manifest.json` root name, remove `lakefile.lean`. Lake refuses ambiguity poorly if both files exist (lean wins), so do not keep both.
2. Replace all five scrape sites with one `tomllib`-based parse (e.g. `python3 -c 'import tomllib; ...'` printing exe roots `(name, root, srcDir or ".")` and lib roots `roots or [name]`); keep the existing empty-list-is-a-failure guards. Update C9's file list and message strings to `lakefile.toml`.
3. Verify locally: `lake build` (detached/guarded per long-builds guidance), `lake test`, `lake lint`, `bash scripts/check-module-invariants.sh --no-build` (C6/C25N scrape counts must equal pre-migration: 13 exe roots, 2 libs), and a full run for C25.
4. Re-enable workflow as `.github/workflows/docs.yml`: checkout -> `leanprover/lean-action@v1` with `build: true`, `test: false`, `lint: false`, `use-mathlib-cache: true` -> `docgen-action@main` with `build-page: false`, `blueprint: false`, `references: references.bib`, and `homepage: api-site` (a folder that does not exist in the repo, so only the generated API is uploaded; it lands at `https://benbrastmckie.github.io/BimodalLogic/docs/`). Rewrite the header comment (remove the DISABLED block and the incorrect "publishes the API documentation alone" rationale for `homepage: docs`).
5. One-time manual step (user, GitHub UI): Settings -> Pages -> Source = "GitHub Actions". Without it the deploy step fails. Verification requires a push to `main` (not workflow_dispatch). Consider pinning `docgen-action` to commit `56023ee2` instead of `@main` for reproducibility.
- This is a build-config/CI task; no proofs are involved, so no sorry/axiom considerations apply.

## Decisions
- **Fix path: migrate to `lakefile.toml`** (option a). Rejected (b) upstream `lakefile.lean` support: would require the action to evaluate Lean config (e.g. via `lake`), no issue/PR exists, and timing is outside our control. Rejected (c) a hand-rolled doc-gen4 workflow replicating `build_docs.sh`: avoids the migration but forks the action's cache-path list (which upstream actively changes, PRs #29/#30/#38/#40), and the migration itself is shown lossless and cheap.
- **Package name: rename `Logos` -> `BimodalLogic`.** `Logos` names the broader research project and a retired module namespace (`Logos.*` in old docs), so it misleads; `BimodalLogic` matches the repository, following the cslib convention (package = repo). Not `FormalSystem`, to keep package and library distinct. Effect on doc URLs: none. The Pages URL is repository-derived (`benbrastmckie.github.io/BimodalLogic/docs/`) and doc-gen4 page paths are module-derived (`.../docs/FormalSystem/Syntax/....html`); the package name is only used as the docbuild `require` name. No downstream project `require`s this package, and root-package build outputs under `.lake/build` are not name-keyed.
- No `user_decision` needed; the Pages-source setting is a required manual action to surface in the plan, not a choice.

## Risks & Mitigations
- Scraper drift after migration silently shrinking root lists -> keep existing "empty list = FAIL" guards and add a count assertion check in the verification phase.
- `LAKE_LIB_ROOTS` regex returns nothing on TOML (roots defaulted) -> tomllib parse with `roots or [name]` fallback.
- Lake reconfiguration triggers a full rebuild locally/CI (config hash changes) -> expected; Mathlib cache is unaffected; schedule the local build detached.
- Doc build time: doc-gen4 over all Mathlib dependencies on a cold cache can take a long time; subsequent runs use the action's GitHub cache (push events only).
- `docgen-action@main` moving target -> pin to a commit SHA.
- Pages not enabled -> first push fails at deploy; mitigate by doing the manual Settings step before re-enabling.
- Other agents editing `lakefile.lean` concurrently -> do the migration as a single atomic commit.

## Tactic Survey Results
- Not applicable (no tactic survey performed)

## Context Extension Recommendations
- **Topic**: Lake TOML config consumers
- **Gap**: No context file documents that repo scripts scrape the lakefile, nor the docgen-action lakefile.toml/elan preconditions.
- **Recommendation**: After migration, add a short note to `docs/development/CI_CD_PROCESS.md` describing the single tomllib parse and the docs workflow prerequisites.

## Appendix
- Commands: `gh api repos/leanprover-community/docgen-action/contents/{action.yml,src/index.js,scripts/build_docs.sh,README.md}`; `gh api .../pulls?state=all`; `gh run list --workflow docs.yml`; `lake translate-config toml` and `lake translate-config lean round.lean` in scratch copies; `lake check-test` / `lake check-lint` on the TOML-only copy with `.lake/packages` symlinked (both exit 0); `gh api repos/leanprover/doc-gen4/git/ref/tags/v4.33.0-rc1`.
- No Lean MCP search tools were needed (non-proof task).
