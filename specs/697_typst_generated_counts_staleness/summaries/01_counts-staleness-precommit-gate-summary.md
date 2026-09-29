# Implementation Summary: Task #697

- **Task**: 697 - Typst generated counts staleness
- **Status**: [COMPLETED]
- **Started**: 2026-09-29T05:05:35Z
- **Completed**: 2026-09-29T05:33:20Z
- **Effort**: ~5.5 hours (matches plan estimate)
- **Dependencies**: None
- **Artifacts**: plans/01_counts-staleness-precommit-gate.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Closed the recurring gap where `typst/generated/status.typ`'s counts silently drift out of sync
with the live Lean tree because nothing in the repository regenerates them. Implemented the
research-chosen mechanism (Option (a), build-free and blocking): a versioned
`.githooks/pre-commit` gate that fires only when a commit stages a `.lean` path, delegating to a
new `--counts-only` mode on `scripts/typst-sync-check.sh` (build-free, reuses the existing Check
2 comparison rather than duplicating it), plus a new `--fix` mode that regenerates
`status.typ` via `scripts/typst-status-counts.sh` on a real mismatch and reports (read-only) any
Check 2b/Check 3 drift it cannot repair. An idempotent `scripts/install-git-hooks.sh` wires
`core.hooksPath` and was run live against this working tree. All six plan phases are
`[COMPLETED]`.

## What Changed

- `scripts/typst-sync-check.sh` — added `--counts-only`, `--fix`, and `--help` modes via an
  argument-parsing block; the bare (no-argument) invocation CI uses is byte-for-byte unchanged
  in behaviour. Check 2, Check 2b, and Check 3's comparisons were each factored into a bash
  function (`run_check2_status`, `run_check2_modulemap`, `run_check3_counts`,
  `run_check3_render`) so `--counts-only`/`--fix` reuse the exact full-mode comparison rather than
  a second implementation.
- `.githooks/pre-commit` (new) — the repository's first versioned git hook. Exits 0 immediately
  unless the staged set (via `git diff --cached --name-only --diff-filter=ACMRD`) contains a
  `.lean` path; on trigger, calls `typst-sync-check.sh --counts-only` and blocks with a message
  naming the drifted fields, the exact remedy command, and the `git commit --no-verify` bypass
  (with the legitimate case for it) if it fails. Resolves the repo root via
  `git rev-parse --show-toplevel` and degrades to a loud warning (never a silent skip) if the
  checker script is missing.
- `scripts/install-git-hooks.sh` (new) — idempotent installer setting local `core.hooksPath =
  .githooks`, printing the prior value before overwriting (this clone's was an explicit absolute
  `.git/hooks`), warning on any stray non-sample file in `.git/hooks/`, and a read-only
  `--check`/`--print` mode. Run live against this working tree.
- `CONTRIBUTING.md` — "Development Setup" gained the one-line installer step; "Verifying Setup"
  gained the `--check` confirmation line.
- `docs/development/CI_CD_PROCESS.md` — new "Typst Sync Check — Local Pre-Commit Counterpart"
  subsection (placed after "Check README Health Step", the last of the existing per-check
  subsections) stating CI's Check 2 remains the unchanged, authoritative backstop; the "Running
  CI Locally" block gained the previously-missing bare `typst-sync-check.sh` invocation plus the
  `--fix` remedy.
- `scripts/README.md` — new row documenting `install-git-hooks.sh` and an expanded description
  for `typst-sync-check.sh`'s new modes.
- `typst/generated/status.typ` — regenerated three times over the course of the task to track a
  shared, concurrently-edited tree (see Deviations); the file committed at task close is
  byte-current with live source.

## Decisions

- **Option (a) implemented as designed** (versioned hook + installer), with Option (b) (`--fix`)
  as the complementary remedy the hook's failure message points at, exactly as the research
  report and plan specified. Options (c) and (d) were not pursued, per the plan's Research
  Integration section.
- **Reused, not duplicated, the Check 2/2b/3 comparisons.** Each was factored into its own bash
  function so `--counts-only` and `--fix` call the identical comparison the full run uses,
  closing off the risk (flagged in the plan's Risks table) of three independent copies of the
  field set drifting apart.
- **`--fix`'s scope is honest**: it repairs `status.typ` only, and separately reports (without
  attempting to fix) any Check 2b/Check 3 drift, naming the correct generator command for each.
- **Committed two stamp/count-only resyncs of `status.typ` as their own labelled commits**
  (`f8333742d` before the Phase 4 demonstration, `d888b9577` after its teardown) rather than
  attempting a `git checkout --`/`git restore` discard, which is forbidden on a dirty shared tree
  by `rules/git-workflow.md`. This matches the plan's explicitly pre-authorized stamp-residue
  handling.

## Plan Deviations

- No structural deviations from the plan's phase/task sequence. Two documented, plan-anticipated
  adaptations to the concurrent shared tree:
  - **Phase 1**: the literal byte-identical-behaviour baseline comparison was re-derived via an
    A/B run of the old and new script at the same instant (rather than a straight before/after
    diff), because a sibling task landed real `.lean` drift between the initial baseline capture
    and the edit. Both scripts produced identical stdout/stderr/exit code.
  - **Phase 6**: the plan's Verification bullet `bash scripts/typst-sync-check.sh` reports `PASS
    (all 3 checks green)` was not literally satisfied at phase close — Check 1 (name resolution,
    entirely outside this task's scope and Non-Goals) failed on `typst/template.typ`, landed by
    an already-committed sibling task (702) after Phase 5 closed. Check 2, this task's actual
    deliverable, passed with `MISMATCH_COUNT=0` in that same run. Similarly,
    `check-module-invariants.sh --no-build` failed on C5/INV findings in files outside this
    task's `file_scope` (also attributed to already-landed sibling commits via `git log`/`git
    status`). See the plan's Phase 6 Tasks/Verification annotations for the full evidence trail.
- One size-estimate miss, noted inline in the plan (not a scope deviation): `.githooks/pre-commit`
  came out at 85 lines against a 40-60-line estimate, due to the fuller header comment and
  multi-line blocking message the Phase 2 Tasks explicitly called for.

## Verification

- Build: Success (`lake build --wfail` clean; `lake exe mk_all --lib FormalSystem --check`
  reports "No update necessary")
- Tests: Passed (`lake test`, `lake lint`)
- Files verified: Yes — `git diff --stat` against the commit preceding this task's first commit
  lists exactly `scripts/typst-sync-check.sh`, `.githooks/pre-commit`,
  `scripts/install-git-hooks.sh`, `CONTRIBUTING.md`, `docs/development/CI_CD_PROCESS.md`,
  `scripts/README.md`, and `typst/generated/status.typ`; no change to
  `.github/workflows/ci.yml` or `scripts/typst-status-counts.sh`.
- Full CI-equivalent sweep (Phase 6): 9 of 11 gates fully green (`lake build --wfail`,
  `warning-budget.py`, `lake test`, `lake lint`, `check-copyright-headers.sh --strict`,
  `readme-lint.sh`, `lake exe lint-style`, `lake exe mk_all --check`,
  `check-paper-definitions.sh`); the remaining 2 (`check-module-invariants.sh --no-build`, bare
  `typst-sync-check.sh`) show failures fully attributed to already-landed sibling commits outside
  this task's scope, with this task's own concern (Check 2) green in the same run.

### Demonstration Transcript (Phase 4) — the "demonstrably prevented" evidence

**1. Block**: staged `Tests/BimodalTest/SyntheticCountProbe.lean` and attempted a real commit:

```
pre-commit: BLOCKED -- staged .lean file(s) may have moved counts that
typst/generated/status.typ no longer reflects (scripts/typst-sync-check.sh
Check 2). Drifted fields:

  == Check 2 (--counts-only): generated/status.typ vs live regeneration ==
  VIOLATION: tests-file-count: committed=75 live=76
  VIOLATION: tests-line-count: committed=22445 live=22449
  MISMATCH_COUNT=2
  typst-sync-check.sh --counts-only: FAIL

Remedy:
  lake build && bash scripts/typst-sync-check.sh --fix && git add typst/generated/status.typ

Bypass: 'git commit --no-verify' skips this gate. The legitimate case for
this is drift attributable to another writer's uncommitted .lean file(s) on
a shared working tree, which this commit did not cause and cannot fix.
CI's typst-sync-check.sh Check 2 remains the authoritative backstop and
will still catch an unfixed bypass.
exit=1
```

`git log -1` confirmed HEAD was unchanged (the commit did not happen); the synthetic file
remained staged.

**2. Fix**: `lake build && bash scripts/typst-sync-check.sh --fix` regenerated `status.typ`
(`tests-file-count`/`tests-line-count` updated), reported "Fixed: generated/status.typ now
matches a live regeneration", and a direct `bash .githooks/pre-commit` invocation then exited 0
silently — confirming a retried commit would pass.

**3. Teardown**: unstaged and deleted the synthetic file, regenerated `status.typ` again from the
now-synthetic-free tree (`tests-file-count`/`tests-line-count` back to 75/22445), confirmed
`git status --porcelain` carries no trace of the synthetic path, and confirmed
`typst-sync-check.sh --counts-only` exits 0.

## Impacts

- A future task that adds or removes a `.lean` file, and has run `scripts/install-git-hooks.sh`
  once, will have its commit blocked locally before the stale-count class can reach CI, with a
  one-command remedy and a documented, CI-backstopped bypass for the legitimate concurrent-writer
  case.
- CI's own `typst-sync-check.sh` step is untouched and remains the authoritative, unbypassable
  backstop; no contributor who skips the one-time installer step loses any existing protection.

## Follow-ups

- The installer must still be run once per existing clone (it is not retroactive); this is now
  documented in `CONTRIBUTING.md`.
- Extending the pre-commit gate to cover Check 2b (module map) or Check 3 (machine appendix) was
  explicitly out of scope (plan Non-Goals) and remains a natural, undone follow-on.
- Two pre-existing, out-of-scope gate failures were observed on `main` during the Phase 6 sweep
  (Check 1's `typst/template.typ` gap from task 702's style-conformance series; a stale INV block
  in three README files from tasks 695/685/690) — neither is this task's to fix, but both are
  flagged here for whichever task owns those files next.

## References

- `specs/697_typst_generated_counts_staleness/reports/01_generated_counts_staleness.md`
- `specs/697_typst_generated_counts_staleness/plans/01_counts-staleness-precommit-gate.md`
- `specs/697_typst_generated_counts_staleness/progress/phase-{1..6}-progress.json`
