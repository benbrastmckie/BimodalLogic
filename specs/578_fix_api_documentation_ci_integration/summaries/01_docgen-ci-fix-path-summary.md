# Implementation Summary: Task #578

- **Task**: 578 - Fix API documentation CI integration
- **Status**: [IN PROGRESS]
- **Started**: 2026-09-17T08:10:00Z
- **Completed**: N/A (Phase 5 awaiting user push and Pages enablement)
- **Effort**: ~2.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_docgen-ci-fix-path.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The Lake configuration is now `lakefile.toml` instead of `lakefile.lean`, and the package is renamed `Logos` -> `BimodalLogic`. Every lakefile scraper now goes through one TOML reader. The API docs workflow is rewritten and re-enabled. Phases 1-4 are committed locally. Phase 5 (enable Pages, push, watch a green run) is stopped at its authorization gate, because an agent may not push.

## What Changed

- `lakefile.toml`: new sole Lake config (`name = "BimodalLogic"`). It matches `lake translate-config toml` output exactly (checked with tomllib), and the per-exe docstrings are kept as comments.
- `lakefile.lean`: deleted.
- `lake-manifest.json`: root package name changed to `BimodalLogic`.
- `scripts/lake_targets.py`: new tomllib reader with `exe-roots`, `lib-roots` and `exes` modes. It applies Lake defaults and exits 2 when the file is missing, unparseable or has no targets.
- `scripts/check-module-invariants.sh`: C6 reachability, the shared LAKE_EXE_ROOTS/LAKE_LIB_ROOTS lists (C16/C25) and C25N now use the helper. The silent `SystemExit(0)`/`pass` fallbacks are replaced by FAIL (`FAIL LAKE`, `FAIL C6`, `FAIL C25N`). The C9 scan now covers `lakefile.toml` (`*.toml` included), and messages were updated.
- `.github/workflows/ci.yml`: the exe-roots step uses `python3 scripts/lake_targets.py exe-roots`.
- `.github/workflows/docs.yml`: renamed from `.disabled` and rewritten. Steps: checkout (fetch-depth 0), then lean-action (build only, Mathlib cache), then a root `api-site/index.html` redirect, then docgen-action pinned to `56023ee2a4b3630c1071825be5bafdb43f540bbd` with `homepage: api-site` and `build-page: false`. Job `timeout-minutes: 300`.
- Prose: CLAUDE.md, README.md, docs/README.md, docs/development/{CI_CD_PROCESS,MODULE_INVARIANTS,MODULE_ORGANIZATION}.md, docs/architecture/ADR-009, docs/training/PIPELINE.md, FormalSystem/README.md, FormalSystem/Metalogic/README.md, Tests/README.md, scripts/typst-machine-appendix.sh, typst/sync-check-whitelist.txt and typst/chapters/p4-dataset-pipeline.typ.

## Decisions

- **Fix path**: migrate to lakefile.toml. docgen-action reads only that file.
- **Package name**: `BimodalLogic`, matching the repository. It has no effect on doc URLs: `https://benbrastmckie.github.io/BimodalLogic/docs/FormalSystem/...`.
- **Site layout**: `homepage: api-site`, a folder created only inside the job, so the hand-written `docs/` tree is not published. A root redirect was added so the bare Pages URL is not a 404.
- **Phase 5 not executed by the agent**: `.claude/rules/pr-prohibition.md` forbids agent pushes even when asked. The authorization on record came only through the orchestrator, which an agent cannot verify as the user's consent. Local `main` (168 ahead) also carries other tasks' in-flight commits.

## Plan Deviations

- **Phase 2** altered: the full-mode invariant run was replaced by running its build components directly (`lake build`/`test`/`lint`, all 13 exe-root builds, all green). `--no-build` was compared against the baseline in a HEAD worktree with only this change's files: no new FAIL. The shared working tree shows `FAIL INV` (stale inventory in FormalSystem/Automation/README.md and README.md), caused by concurrent tasks' uncommitted edits. HEAD plus this change passes INV.
- **Phase 2** altered: the C9 scan was widened to include `*.toml`, and a structural `FAIL LAKE` was added for `--no-build`.
- **Phase 2/3**: the scoped-commit helper dropped staged deletions (`lakefile.lean`, `docs.yml.disabled`), so each went in a small follow-up commit.
- **Phase 3** altered: added the root redirect step and `timeout-minutes: 300`. actionlint is not installed, so YAML was checked with PyYAML.
- **Phase 4** altered: four current-state mentions were deferred because their files carry uncommitted concurrent edits: docs/user-guide/architecture.md:1131, docs/development/LEAN_STYLE_GUIDE.md:790, docs/user-guide/troubleshooting.md:55, docs/development/NAMING_CONVENTION_DEVIATION.md:333.
- **Phase 5** blocked: waiting for the user to push and enable Pages.

## Verification

- Build: Success (`lake build` via build guard, 2659 jobs). `lake test` and `lake lint` exit 0. All 13 `lean_exe` root module builds succeed.
- Root sets: 13 exe roots (identical to baseline) and 2 lib roots.
- Negative checks: with no lakefile.toml, the helper exits 2, the CI step fails under `set -e`, the LAKE block prints FAIL and C25N prints FAIL.
- Sorry count: 0 introduced (no Lean source edited). Vacuous count: 0. Axiom count: unchanged.
- Remote: not verified. The docs.yml green run is still pending (Phase 5).
- Files verified: Yes

## Impacts

- Tools that expected `lakefile.lean` (the old regex scrapers) must use `scripts/lake_targets.py`.
- The first build after the migration is a full local rebuild (config hash changed).

## Follow-ups

- The user enables Pages (source = GitHub Actions) and pushes `main`. Then resume Phase 5 to watch the `API Documentation` and `CI` runs and fetch the Pages URL.
- Update the four deferred prose mentions once the concurrent edits land.

## References

- specs/578_fix_api_documentation_ci_integration/plans/01_docgen-ci-fix-path.md
- specs/578_fix_api_documentation_ci_integration/reports/01_docgen-ci-fix-path.md
