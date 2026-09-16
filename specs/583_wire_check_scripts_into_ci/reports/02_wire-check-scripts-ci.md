# Research Report: Task #583

**Task**: 583 - Wire the check scripts that are green today into `.github/workflows/ci.yml`, and establish the per-script wiring pattern every later check follows
**Started**: 2026-09-16T00:00:00Z
**Completed**: 2026-09-16T00:00:00Z
**Effort**: Medium — mechanically small (three `run:` steps), the judgment is in the exact invocation form and the wiring-pattern writeup
**Dependencies**: None (rescoped 2026-09-16; no longer waits on 581/582/586/590 — see prior round's report and `state.json`)
**Sources/Inputs**:
- `.github/workflows/ci.yml` (65 lines, current)
- `scripts/check-module-invariants.sh`, `scripts/check-copyright-headers.sh`, `scripts/readme-lint.sh` (read in full / in relevant part, and executed locally)
- `docs/development/MODULE_INVARIANTS.md`, `docs/development/CI_CD_PROCESS.md`
- Prior artifact: `specs/583_wire_check_scripts_into_ci/reports/01_uncalled-check-scripts.md` (round 1, pre-rescope sweep evidence)
- `specs/593_revise_task_organization_codebase_cleanup/reports/01_cleanup-topic-reorganization.md`, Recommendation 3 (the rescoping rationale)
- `specs/reviews/review-2026-09-16.md`, Finding H3
- `specs/state.json` task 583 entry (current scope, `dependencies: []`, `file_scope`)
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The three in-scope scripts are confirmed green today, freshly re-run: `check-module-invariants.sh --no-build` (exit 0, 20.9s), `check-module-invariants.sh` full (exit 0, ~2m6s-2m11s warm), `check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem` (exit 0, 11.5s, 520/520 conforming), `readme-lint.sh` (exit 0, 7.1s, `RESULT: PASS`).
- **Recommended invocation for `check-module-invariants.sh` is `--no-build`**, not the full run. The task's own WHY paragraph budgets "the structural pass (20s) ... total under a minute" together with the other two scripts — that framing only holds under `--no-build`. The full run costs ~2 minutes extra even with the Lake cache and the `lean_exe` roots already warm (verified by re-timing after pre-building all 13 `lean_exe` roots: still 2m11s), and most of that delta is `check-module-invariants.sh`'s own re-run of the Batteries `env_linter` across all 14 lakefile roots (C16) plus the four-theorem axiom-baseline check (C2) — the FormalSystem-scoped half of C16 substantially duplicates what `lean-action`'s `lint: true` already gates, and C25 (lean_exe compile) duplicates the workflow's own "Compile lean_exe roots" step. The genuinely new, not-otherwise-covered checks the full run adds over `--no-build` are C2 (axiom-baseline drift), C6 (unreachable-module rot), and C24 (`Init` transitive-import). This is a real coverage-vs-runtime tradeoff, not a strict win for either side — see Decisions and Risks below.
- The existing "Compile `lean_exe` roots" step in `ci.yml` is the template to copy: named step, `::group::`/`::endgroup::` wrapping, `set -euo pipefail`, placed after `lean-action` so the Lake/Mathlib cache is warm.
- The per-script wiring pattern to record (per the dispatch's ALSO DELIVER) has four parts, detailed in Findings: step naming, the skip-and-report-neutral convention (needed by 584's `check-paper-definitions.sh`, not implemented here but the convention should be written down now since this task owns the pattern), cache-warm placement, and the measured runtime budget.
- No blockers, no ambiguity requiring user judgment — proceeding straight to a plan is appropriate.

## Context & Scope

Researched what `ci.yml` currently runs, verified the exact green/red status of every script named in the task description by re-running each one locally with a warm Lake cache, and measured wall-clock cost precisely enough to settle the `--no-build`-vs-full question the task description explicitly leaves open. Did not touch the four out-of-scope scripts (`check-evidence-probes.sh`, `check-metalogic-cycles.sh`, `check-paper-definitions.sh`, `typst-sync-check.sh`) beyond confirming via `state.json`'s own task descriptions (581/582/584/586) that each is still red today, which matches this task's OUT OF SCOPE list and requires no independent re-verification here.

## Findings

### Codebase Patterns

- **Current `ci.yml` structure** (65 lines): `actions/checkout@v4` -> `leanprover/lean-action@v1` (`build: true`, `test: true`, `lint: true`, `use-mathlib-cache: true`) -> "Compile `lean_exe` roots" (scrapes `root :=` from `lakefile.lean`, loops `lake build "$root"`, each iteration wrapped in `::group::`/`::endgroup::`) -> "Report results" (`if: always()`, echoes the three `lean-action` output statuses).
- Line 48's comment currently *describes* `check-module-invariants.sh` in prose ("The local counterpart is invariant C25 ... which scrapes the same root list at run time") without the workflow ever running it. Per the task's own framing, once the script is wired this comment should point at the new step rather than only describing the script from the outside.
- `check-module-invariants.sh` already has a documented `--no-build` flag (`docs/development/MODULE_INVARIANTS.md:8-9`: "`--no-build` # structural checks only (seconds)"; the file's own usage line documents the full run as "~1-2 min warm" — consistent with what was measured here).
- `check-copyright-headers.sh`'s bare invocation is a trap: its own header comment (lines 20-25) states the bare form "could otherwise never exit 0" against the archive, and the strict live-set form is explicitly `--strict --exclude '*/Boneyard/*' FormalSystem`. The task description already names this exact form; confirmed it is what must be wired, not the bare form.
- `readme-lint.sh` gates only Checks 1 and 3 (missing README, broken relative link); Checks 2 (NOT LISTED) and 4 (stale/missing "Last verified" date) are informational only and do not affect its exit code — the current run reports 91 NOT-LISTED and 3 missing/stale dates alongside `RESULT: PASS`. No action needed; this is by design per the script's own header.

### Measured Runtimes (local, warm Lake cache, `lean_exe` roots pre-built)

| Script | Exit | Runtime |
|---|---|---|
| `check-module-invariants.sh --no-build` | 0 | 20.9s |
| `check-module-invariants.sh` (full, roots already warm) | 0 | 2m11.9s |
| `check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem` | 0 | 11.5s |
| `readme-lint.sh` | 0 | 7.1s |
| `lake build` (baseline, warm) | 0 | 24.8s |
| Pre-building all 13 `lean_exe` roots (the workflow's existing step) | 0 | 12.1s |

Total added wall-clock if wiring `--no-build` + copyright + readme-lint: **~40s**. Total added wall-clock if wiring the full invariants run instead: **~2m30s**. `docs/development/CI_CD_PROCESS.md` documents "typical CI runtime" today as 7-10 minutes with the Mathlib cache, so either choice is a modest percentage increase, but the two options differ from each other by roughly 4-6x.

### External Resources

- GitHub Actions convention already in this file for a multi-item shell loop: `set -euo pipefail`, `echo "::group::..."` / `echo "::endgroup::"` per logical unit, so a failure's log output is scoped to the specific script/root that failed. The same convention should wrap each new check step, even though each is a single command (no loop) — a `::group::` still helps collapse verbose PASS/INFO output in the Actions UI.
- No GitHub Actions-specific research beyond the existing `lean-action` action's documented outputs (`build-status`, `test-status`, `lint-status`) was needed; the new steps are plain `run:` blocks, not action calls.

### Recommendations

1. **Step order**: `checkout` -> `lean-action` -> "Compile `lean_exe` roots" (existing) -> three new steps, one per script -> "Report results" (existing, `if: always()`). Placing the new steps after the `lean_exe` compile step keeps the workflow narrative "build everything, then check everything" and lets a future full-mode `check-module-invariants.sh` (if ever chosen) see the roots already warm.
2. **Step naming**: each new step's `name:` must name the script verbatim (e.g. `name: Check module invariants`, `name: Check copyright headers`, `name: Check README health`) so a failing step is self-explanatory in the Actions UI without opening logs — this directly satisfies the task's own Verify criterion ("the failing step names the script").
3. **Exact commands**:
   - `bash scripts/check-module-invariants.sh --no-build`
   - `bash scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem`
   - `bash scripts/readme-lint.sh`
4. **Wiring-pattern convention to record** (ALSO DELIVER), four parts:
   - *Step naming*: name is the script's purpose in plain words; the script's basename appears in the `run:` line so both log and step title identify it.
   - *Skip-and-report-neutral convention* (not implemented by this task, but the pattern this task is asked to record for 584 and any future check whose input CI cannot see): a check step should detect the missing-input case explicitly (e.g. `test -f "$PAPER_TEX"` or the record's own path sentinel) and exit 0 with a clearly-labeled neutral message rather than fail — `check-paper-definitions.sh` today exits 2 with a plain `error:` when the path cannot be resolved (verified at `scripts/check-paper-definitions.sh:96-100`), which is fail-shaped, not skip-shaped; 584's final phase must change this before wiring it in, following whatever textual convention this task records.
   - *Cache-warm placement*: any check that runs `lake build`/`lake env lean` internally (all three in scope do, at least partially) must be placed after `lean-action`'s build step, never before, so it reuses the populated Lake/Mathlib cache instead of re-resolving dependencies cold.
   - *Runtime budget*: record the measured delta (this report's table) at the point the steps are added, and update it if a later task changes which scripts are wired or how (e.g. if 585's compiler-warning gate or 590's `ENFORCE_C9_DOCS=1` flip land in the same workflow).
5. **Documentation targets for the convention** (the task allows "the workflow header comment and/or `docs/development/`"): `docs/development/CI_CD_PROCESS.md` already has a "CI Steps Explained" section structured per-step — extending it with one subsection per newly-wired check is the natural fit and keeps the convention next to the runtime-budget prose already there ("Typical CI runtime: 7-10 minutes"). `.github/workflows/ci.yml`'s own comment at line 48 should be updated from describing the script in prose to referencing the new step by name (once it exists), per the task's Verify intent that the workflow and its own comments agree about what runs where.

## Decisions

- **`--no-build` is the recommended invocation for `check-module-invariants.sh`** in this wiring pass, on the measured runtime-budget evidence above. This is presented as a recommendation, not a foreclosed choice — the task description explicitly leaves both forms open ("full, or `--no-build`"), and the planner may reasonably choose full coverage (C2/C6/C24) at the ~2-minute cost if that tradeoff is preferred. Either choice satisfies the task's literal SCOPE bullet.
- Confirmed the strict-live-set copyright invocation (`--strict --exclude '*/Boneyard/*' FormalSystem`) is the one to wire; the bare form is explicitly documented as unconditionally exiting 0 and must not be substituted.
- `readme-lint.sh` needs no flags; its default root (`FormalSystem`) and default gated checks (1, 3) are exactly what should run in CI.

## Risks & Mitigations

- **Redundant coverage if full `check-module-invariants.sh` is chosen instead of `--no-build`**: the full run's C1, the bulk of C16, and C25 substantially overlap with `lean-action`'s own `build`/`lint` steps and the existing "Compile `lean_exe` roots" step. Mitigation: if the planner chooses the full form anyway (to gate C2/C6/C24), document explicitly in the wiring-pattern writeup that the overlap is accepted for those three checks' sake, so a future reader does not mistake it for an oversight.
- **`readme-lint.sh`'s informational findings (91 NOT-LISTED, 3 stale/missing dates) could be mistaken for new failures** once this step is visible in CI logs for the first time. Mitigation: the wiring-pattern doc should note explicitly that Checks 2 and 4 are reported, not gated, matching the script's own header — no code change needed, just call this out so a reviewer does not chase a false alarm.
- **A later task (585, 590) editing the same workflow file concurrently** could produce a merge conflict or duplicate step. Mitigation already exists at the task-graph level: per `state.json`, 585 and 590 are both written to "extend 583's workflow rather than editing CI independently" / "wire it into CI following 583's recorded pattern" — this task landing first with a clear, documented pattern is exactly what de-risks that sequencing.
- **Verify criterion requires a deliberate-violation branch for each wired check to fail CI with a step that names the script.** This is a plan/implementation-phase activity (create a throwaway branch or a scratch violation, observe the named step fail, then revert) rather than something resolved in research; noting it here so the plan allocates a phase for it rather than treating "wire the steps" as sufficient on its own.

## Context Extension Recommendations

- **Topic**: CI wiring pattern for repository-specific check scripts.
- **Gap**: `docs/development/CI_CD_PROCESS.md`'s "CI Steps Explained" section currently documents only the `lean-action`-provided build/test/lint steps; it has no section for repository-specific script steps (the existing `lean_exe` compile step is also undocumented there).
- **Recommendation**: add a subsection to `CI_CD_PROCESS.md` (or a new short doc under `docs/development/`) recording the four-part wiring pattern from Findings above, so each of 581/582/584/586/590's final CI-wiring phases has one place to follow rather than reverse-engineering the pattern from `ci.yml`'s comments each time. This is itself part of this task's ALSO DELIVER, so the plan should treat writing it as a phase, not an afterthought.

## Appendix

- Commands run: `lake build`; `bash scripts/check-module-invariants.sh --no-build`; `bash scripts/check-module-invariants.sh` (twice, once cold on `lean_exe` roots and once after pre-building them, to isolate whether C25's cost was double-counted — it was not the dominant cost either way); `bash scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem`; `bash scripts/readme-lint.sh`; the `lean_exe`-roots loop copied verbatim from `ci.yml`'s existing step, run standalone to pre-warm and to time it in isolation.
- Files read: `.github/workflows/ci.yml`, `scripts/check-module-invariants.sh` (header/usage/flag sections), `scripts/check-copyright-headers.sh` (header + arg parsing), `scripts/readme-lint.sh` (header), `docs/development/MODULE_INVARIANTS.md`, `docs/development/CI_CD_PROCESS.md`, `scripts/check-paper-definitions.sh` (path-resolution section, to confirm today's fail-shaped behavior for the skip-neutral convention note), `specs/583_wire_check_scripts_into_ci/reports/01_uncalled-check-scripts.md`, `specs/593_revise_task_organization_codebase_cleanup/reports/01_cleanup-topic-reorganization.md` (Recommendation 3 + rescope section), `specs/state.json` (task 583 entry and the four out-of-scope tasks' descriptions).
