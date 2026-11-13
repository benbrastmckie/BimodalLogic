# Research Report: Task #787

**Task**: 787 - Audit the remaining lake-invoking scripts for the unguarded .lake read hazard
**Started**: 2026-11-13T09:38:42Z
**Completed**: 2026-11-13T09:43:35Z
**Effort**: ~2 hours implementation (two small lock blocks, one optional scoped prebuild, header notes, one doc section)
**Dependencies**: 743 (declared); none technical
**Sources/Inputs**: - Codebase only (scripts/, .claude/scripts/, source store at ~/.config/nvim/agent-system/extensions/, .github/workflows/, .githooks/); one local flock experiment; no web sources needed
**Artifacts**: - specs/787_lake_unguarded_reader_lock_audit/reports/01_lake-reader-lock-audit.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The task's "strongest candidate" is not a candidate.** `scripts/typst-module-map.sh` never invokes lake; its single grep hit is a header comment stating it needs no built library. Two other description claims also fail on reading the code (`export-training-data.sh` runs `lake exe`, not `lake build`; `lean-sorry-census.sh` is not prose-only and is already guard-routed).
- **Exactly two repository scripts carry the unguarded hazard and should take the lock**: `scripts/typst-status-counts.sh` (write path only: one bare `lake env lean`, the verbatim reader shape) and `scripts/typst-machine-appendix.sh` (default mode only: a scoped `lake build` followed by `lake env lean --run`).
- **One hard design constraint, measured**: a child script that re-opens the lock file blocks against its own lock-holding parent. The lock must be taken at exactly one level of any call chain, so `typst-sync-check.sh` must NOT take it (it delegates to `typst-status-counts.sh`), and each lock must sit *after* the build-free mode exits (`--json`, `--render-only`), which CI and the pre-commit hook depend on.
- **The dataset scripts want a different shape or none**: `lake exe` runs for up to hours; the precedent's hold-to-process-exit lock would starve every guarded build. Recommended: a subshell-scoped locked prebuild, or an explicit recorded ruling-out.
- **Survey gaps found**: `.claude/scripts/lean-challenge-snapshot.sh` (bare `lake env lean`, failure is fatal exit 74) is the one deployed script with the exact hazard, and `scripts/warning-budget.py` reads `.lake` directly without invoking lake at all. Neither is in this task's `file_scope`; the first is a source-store edit that belongs to a task sited in the source-store repository.
- **No doc anywhere names the lock convention** (grep of docs/, README.md, scripts/README.md, typst/README.md for `build-guard|flock`: zero hits). The rulings-out need a durable home; `scripts/README.md` is the natural one.

## Context & Scope

Scope: every script under `scripts/` and `.claude/scripts/` (non-test) that can read or write `.lake` at runtime, judged per script against the precedent in `scripts/check-module-invariants.sh` (C1 block) and `scripts/check-evidence-probes.sh` (SHARED `.lake` LOCK block). Out of scope and untouched: probe files, manifest arrays, the Lean sources. No build was started by this research. A sibling's guarded probe (`lake-build-guard.sh build --timeout 2400 -- env lean .../HbProbe.lean`, holder pid 4047056) was in flight on the lock during the survey; it is not this task's and nothing here depended on `.lake` state.

Evidence tier: code reading plus one mechanical experiment. The underlying race itself (missing-olean error under a concurrent build) was NOT re-measured here; it is carried from the precedent's own in-file account [CARRIED-UNVERIFIED: scripts/check-evidence-probes.sh "THE THIRD DIAGNOSTIC CLASS" comment block / re-measuring needs a deliberately raced full build, which would collide with the sibling task's live build].

## Findings

### Survey method (enumeration completeness)

The candidate table below is presented as complete for `scripts/`, `.githooks/`, `.claude/scripts/` (excluding `tests/`) and `.claude/hooks/`. Two differently-shaped patterns were run, both with `command grep` (the shell's `grep` is a function that honours .gitignore and silently skips `.claude/`):

1. Literal invocation pattern, comment lines filtered: `(^|[^A-Za-z_./-])lake( |$)|\blake"|lean --run` then `grep -vE '^[^:]+:[0-9]+:\s*#'`.
2. Structural process-spawn / artifact pattern: `"lake"|'lake'|\$\{?LAKE[A-Z_]*\}?|\blean +(--run|[^ ]*\.lean)|command -v (lake|lean)|subprocess.*(lake|lean)|\.lake/build`, plus a separate `\.lake/(build|packages)|\.olean|\.ilean|\.trace` pass for direct artifact readers.

Pattern 2 surfaced what pattern 1 could not: `scripts/warning-budget.py` (reads `.lake/build/lib/lean/**/*.trace` with no lake call) and confirmed `lean-src-roots.sh` as a non-invoker. Not covered: lake calls issued by agents or skills directly from prose instructions (`SKILL.md`, the `lean_build` MCP tool, `lake serve` under lean-lsp) — these are not scripts and cannot take a script-level lock.

### Per-script determination

| Script | Runtime lake / .lake use | Shape | Determination |
|---|---|---|---|
| `scripts/check-module-invariants.sh` | 11 lake calls, all inside `RUN_BUILD=1` branches (lines 1040, 1046, 1232, 1519, 3007, 3665, 3705-3706, 4880, 4962, 7419) | precedent | Already locked at C1; every later call inherits. Residual: on a C1 lock *timeout* the later RUN_BUILD checks still run, unlocked. Not in file_scope; note only. |
| `scripts/check-evidence-probes.sh` | `lake env lean` per probe (line 2661) | precedent | Already locked. |
| `scripts/typst-status-counts.sh` | one `lake env lean $AX_SRC` (line 301), write path only; `--json` exits before it | unguarded reader | **ADD LOCK**, after the `--json` branch, before line 301. |
| `scripts/typst-machine-appendix.sh` | `lake build BimodalTools.MachineAppendixMain` (192) then `lake env lean --run` (196), default mode only; `--json` and `--render-only` exit before | scoped builder + reader | **ADD LOCK**, at the "Default mode" section, covering both calls. |
| `scripts/typst-sync-check.sh` | no direct lake call; `--fix` calls `typst-status-counts.sh` (write path); default and `--counts-only` call only build-free child modes | delegator | **RULE OUT, and must not lock**: locking here would deadlock the child for the full timeout (see experiment). Protection arrives via the child. |
| `scripts/typst-module-map.sh` | none (pure glob + `wc` + python regex over source text) | prose-only | **RULE OUT**: never touches `.lake`. |
| `scripts/export-training-data.sh` | `lake exe dataset_generator` (188, 201), `lake exe proof_extractor` (246); the `lake build dataset_generator proof_extractor` string (88) is an echoed hint | implicit scoped builder + long runner | **DIFFERENT SHAPE**: no hold-to-exit lock (runs for up to hours). Recommended: subshell-scoped locked prebuild; acceptable alternative: recorded ruling-out. |
| `scripts/run_dataset_generation.sh` | 9 `lake exe dataset_generator` calls (290-564); tiers documented at up to 2-6h | same as above | Same as above. **Not in declared file_scope** and absent from the task's candidate list. |
| `scripts/warning-budget.py` | no lake call; walks `.lake/build/lib/lean/**/*.trace` | direct artifact reader | Covered when run under a full invariants pass (inherits C1's lock); unguarded under `--no-build`. Its header already documents the quiescence requirement and a measured spurious `FAIL C28`. Outside this task's scope; follow-up candidate. |
| `scripts/generate-decidability-inventory.sh` | no direct lake; runs `check-evidence-probes.sh` as a child | delegator | RULE OUT; child locks itself, parent holds nothing. |
| `scripts/check-copyright-headers.sh`, `scripts/move-modules.py`, `scripts/lake_targets.py`, `scripts/reanchor-lean-citations.py` | none (comment or prune-list mentions; lakefile text parsing) | prose-only | RULE OUT. |
| `.claude/scripts/lake-build-guard.sh` | the guard itself | precedent | Publishes the lock. |
| `.claude/scripts/lean-sorry-census.sh` | `lake build` under `--cross-check` (line 240), routed through `lake-build-guard.sh build -- build`; bare fallback only when the guard is absent | builder, already guarded | RULE OUT: already serialised. The description's "prose-only" classification is wrong. |
| `.claude/scripts/lean-challenge-snapshot.sh` | `cd $PROJECT_ROOT && lake env lean $scratch_file` (line 893); failure maps to fatal exit 74 | unguarded reader | **Carries the hazard verbatim; missed by the task's survey.** Not editable from this task (see Source-store siting). |
| `.claude/scripts/lean-comparator-run.sh` | `lake exe cache get` (353) and `lake env comparator` (548), both with cwd = a private `mktemp -d` git worktree; nested around the guard | private-tree builder | RULE OUT: reads and writes only its own clean-room `.lake`, never the main tree's. |
| `.claude/scripts/lean-comparator-landrun-shim.sh` | `command -v lake` only | prose-only | RULE OUT. |
| `.claude/scripts/plan-file-scope-harvest.sh`, `claude-refresh.sh`, `lean-mcp-preflight-check.sh`, `lean-src-roots.sh` | none (comments, a `.lake` prune entry, `ps -C lake,lean` process matching, lakefile presence tests) | prose-only | RULE OUT. |
| `.claude/scripts/dispatch-worktree.sh` | `cp -al $PROJECT_ROOT/.lake` (line 319) | direct artifact reader | Not a verdict-producing reader: a clone that catches a mid-rewrite tree is repaired by the worktree's own next build. Note only. |

CI is not a concurrency site for any of these: `.github/workflows/ci.yml` runs `check-evidence-probes.sh`, `check-module-invariants.sh --no-build` and `typst-sync-check.sh` (no-argument, build-free) as sequential steps after the build. `.githooks/pre-commit` uses `typst-sync-check.sh --counts-only`, also build-free. So the two ADD LOCK scripts are reached only by a local operator or agent running a generator (or `--fix`) — which is precisely when a sibling build is likely.

### The nested-lock experiment

With util-linux flock 2.42.3, in a scratch directory: a parent took `flock -n` on an fd opened with `exec {P}<>lock`; a child bash that re-opened the same path and ran `flock -n` was **BLOCKED**; a child that ran `flock -n` on the *inherited* fd number **ACQUIRED** (same open file description). Consequence: the precedent block is safe only in a script that is never run by a lock-holding parent. Checked call chains:

- `typst-sync-check.sh --fix` -> `typst-status-counts.sh` (write): parent holds nothing. Safe if only the child locks.
- `typst-sync-check.sh` -> `typst-status-counts.sh --json`, `typst-module-map.sh --json`, `typst-machine-appendix.sh --render-only`: build-free modes; must stay lock-free.
- `generate-decidability-inventory.sh` -> `check-evidence-probes.sh`: parent holds nothing. Safe today.
- `check-module-invariants.sh` (lock holder) -> `warning-budget.py`, `lake_targets.py`: neither locks. Safe today; it does not call either typst generator.

### Source-store siting

All `.claude/scripts/` candidates resolve to `~/.config/nvim/agent-system/extensions/{core,lean}/scripts/` and are byte-identical to their deployed copies (`cmp`), except `dispatch-worktree.sh`, which was not found under any `extensions/*/scripts/` path. That source store is a separate git repository (`~/.config/nvim`, currently with 4 uncommitted paths of its own). The task's declared `file_scope` lists five `scripts/` files and no source-store path. Under the Task Siting rule in `.claude/rules/source-store-deploy-boundary.md`, the one deployed script that warrants a change (`lean-challenge-snapshot.sh`) is a task for the source-store repository, not an edit to make from here — even though the task description's SOURCE-STORE BOUNDARY paragraph tells the implementer to edit the mirrored path.

## Decisions

- Classify by runtime behaviour read from non-comment lines, not by grep hit; the task's candidate list was re-derived rather than trusted, as it instructed.
- The lock is taken at the innermost script that invokes lake (the leaf), never at a delegator.
- "fd held to process exit" is not applied to hours-long runners; where a lock is wanted there, it is scoped to a subshell that exits when the build does. This keeps the precedent's no-`flock -u` property rather than introducing an unlock.
- `.claude/**` scripts are judged and recorded here but not edited by this task.
- No `user_decision` is raised: the siting question is settled by a written rule, and the dataset-script choice is a routine planner call with a stated default.

## Recommendations

1. **`scripts/typst-status-counts.sh`** — insert the precedent block (`flock -n`, announced bounded `flock -w` with a 600 s default, fd never released, audible stderr notice when flock is absent) immediately before the `AX_SRC=$(mktemp ...)` step, i.e. strictly after the `--json` early exit. Lock path `${REPO_ROOT}/.lake/build-guard.lock` (the script has `cd`'d into `FormalSystem/`, so use `REPO_ROOT`, not `pwd`). On timeout: exit 1 with an environment-class message. Also split the existing failure message: it currently says "Run 'lake build' first" for every failure, which misattributes a raced read; reuse the narrow missing-object-file predicate from `check-evidence-probes.sh` to say "environment, re-run" in that case. Exit contract stays 0/1. Mind `set -euo pipefail`: write the acquisition as `if ! flock ...` forms as the precedents do.
2. **`scripts/typst-machine-appendix.sh`** — same block at the top of "Default mode", after both early-exit modes. Exit contract unchanged (lake's status under `set -e`; 1 on lock timeout).
3. **`scripts/typst-sync-check.sh`, `scripts/typst-module-map.sh`** — no lock. Add a short header note to each stating why (delegates to a locking child and must not double-lock; never touches `.lake`). For `typst-sync-check.sh` also extend the `--fix` failure hint to mention a concurrent build.
4. **`scripts/export-training-data.sh`** (and, if the planner widens `file_scope`, `scripts/run_dataset_generation.sh`) — default recommendation: before the first `lake exe`, run `( <precedent lock block>; lake build <the exe targets this invocation needs> )` in a subshell so the lock dies with the subshell; skip it under `--dry-run`; leave the `lake exe` calls as they are (their implicit build is then a no-op unless sources change mid-run). If the planner prefers not to touch a data-export tool, the complete alternative is a header note recording that a hold-to-exit lock was rejected because the run lasts hours. Either is a finished result for these files.
5. **Record the convention once, where readers look**: add a short section to `scripts/README.md` naming the lock path, the leaf-only rule and its reason, and the per-script determinations above (including the deployed scripts by filename, since their own headers cannot be edited from this repository). State current facts only: no task numbers, no draft-history phrasing.
6. **Verification the plan should require**: for each script that gains a lock, (a) hold the lock from another shell and confirm the "waiting" announcement, then the timeout branch with a short override, then normal completion after release; (b) confirm `typst-sync-check.sh` (no-arg and `--counts-only`) still completes *while the lock is held elsewhere* — the proof the build-free modes stayed lock-free; (c) each script's own gate. The first two need no build. Regenerating `typst/generated/status.typ` is in a sibling task's territory this cycle; verify with output diffed or redirected rather than committing that file.
7. **Follow-ups to file, not do here**: (i) in the source-store repository, route `lean-challenge-snapshot.sh`'s compile check through the guard, as `lean-sorry-census.sh` already does — the guard's allowlist includes `env`, and a sibling was observed live running `lake-build-guard.sh build -- env lean <file>`; (ii) `warning-budget.py` / C28 under `--no-build`, where a non-blocking `flock -n` probe could at least announce that a build is in flight; (iii) the C1-timeout residual in `check-module-invariants.sh`.

## Risks & Mitigations

- **Self-deadlock from a future nested caller** (measured mechanism). Mitigation: leaf-only rule written into each new block's comment and into `scripts/README.md`; verification step 6(b).
- **The lock is advisory and bypassable.** Bare `lake build`, `lake serve` under lean-lsp, and the `lean_build` MCP tool never take it, so a locked reader can still be raced. Mitigation: keep the environment-vs-content failure classification next to each lock so a raced read is at least named correctly; do not describe the lock as closing the hazard.
- **A generator now waits up to 600 s behind a long build.** This is the precedent's accepted trade (a slower green over a spurious red); the wait is announced on stderr.
- **Shared tree this cycle**: task 803 holds `typst/generated/status.typ` and is running guarded builds. Mitigation: edit only the five scoped scripts plus `scripts/README.md`; re-read before editing; explicit-file staging.
- **`scripts/README.md` and `run_dataset_generation.sh` are outside the declared file_scope.** The planner should widen scope explicitly or drop those items.

## Context Extension Recommendations

- **Topic**: flock re-entrancy across a script call chain
- **Gap**: nothing in `.claude/context/` states that a child re-opening a lock file blocks against its lock-holding parent, nor the resulting leaf-only rule for `build-guard.lock` consumers.
- **Recommendation**: a short addition to the guard-consumer guidance in `context/patterns/batch-orchestration-guardrails.md` (source-store edit, so a source-store-repository task).

## Appendix

- Patterns: as quoted under "Survey method". Call-graph pass: `command grep -rnE "<name>\.(sh|py)"` per script over the repository excluding `.lake .git specs .claude .opencode`.
- Source-store comparison: `cmp` of each `.claude/scripts/<name>.sh` against `~/.config/nvim/agent-system/extensions/*/scripts/<name>.sh`.
- Precedent text read in full: `scripts/check-module-invariants.sh` lines 998-1059; `scripts/check-evidence-probes.sh` lines 2542-2716; `.claude/scripts/lake-build-guard.sh` header lines 1-120 and allowlist line 280.
- Issue log: three entries recorded this dispatch (two wrong-premise issues, one experiment win).
