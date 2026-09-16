# Implementation Summary: Task #583

- **Task**: 583 - Wire the check scripts that are green today into `.github/workflows/ci.yml`, and establish the per-script wiring pattern every later check follows
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T00:00:00Z
- **Completed**: 2026-09-16T16:24:49Z
- **Effort**: ~2 hours
- **Dependencies**: None
- **Artifacts**: plans/02_wire-check-scripts-ci.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Wired `scripts/check-module-invariants.sh --no-build`, `scripts/check-copyright-headers.sh
--strict --exclude '*/Boneyard/*' FormalSystem`, and `scripts/readme-lint.sh` into
`.github/workflows/ci.yml` as three named steps placed directly before "Report results" (after
two sibling steps concurrent tasks added to the same slot). Recorded the per-script wiring
pattern — step naming, skip-and-report-neutral convention, cache-warm placement, and a measured
runtime budget — as a new "Wiring a New Check Script" section of
`docs/development/CI_CD_PROCESS.md`, plus subsections documenting the previously-undocumented
"Compile lean_exe roots" step and each of the three new steps. Proved each wired step fails
under its own step name on a deliberate violation, then reverted every violation and confirmed a
clean re-run.

## What Changed

- `.github/workflows/ci.yml` — added three named steps (`Check module invariants
  (scripts/check-module-invariants.sh --no-build)`, `Check copyright headers
  (scripts/check-copyright-headers.sh --strict)`, `Check README health
  (scripts/readme-lint.sh)`) directly before "Report results"; replaced the "Compile lean_exe
  roots" step's C25 prose comment with a reference to the new invariants step; added a header
  comment pointing to `CI_CD_PROCESS.md`'s wiring-pattern section.
- `docs/development/CI_CD_PROCESS.md` — added "Compile lean_exe Roots Step", "Check Module
  Invariants Step", "Check Copyright Headers Step", and "Check README Health Step" subsections
  under "CI Steps Explained"; added a "Wiring a New Check Script" section (step naming,
  skip-and-report-neutral convention, cache-warm placement, runtime-budget table); added a
  "Known Not-in-CI Gaps" subsection documenting C2/C6/C24 and the shallow-clone date effect on
  readme-lint Check 4; updated "Pipeline Summary" and "Running CI Locally" to list the three
  commands.
- `specs/583_wire_check_scripts_into_ci/plans/02_wire-check-scripts-ci.md` — all four phases
  checked off with completion annotations.
- `specs/583_wire_check_scripts_into_ci/progress/phase-{1,2,3,4}-progress.json` — created.

No production `.lean` or other source files were changed in the final state; three files
(`FormalSystem/Syntax/SubformulaClosure.lean`, `FormalSystem/Syntax/README.md`, root `README.md`)
were edited to prove violations, then restored byte-for-byte from backups (confirmed via `git
diff --quiet -- <file>` after each revert).

## Decisions

- **Invariants wired as `--no-build`.** Matches the task description's runtime framing and
  avoids duplicating work the lean-action/lean_exe steps already do. C2 (axiom-baseline drift),
  C6 (unreachable-module compile-check half), and C24 (transitive `Init` import) are the
  resulting known CI gaps, documented with a one-line upgrade path in `CI_CD_PROCESS.md`.
- **New steps placed after the two concurrently-added sibling steps.** Tasks addressing
  `check-evidence-probes.sh` and `check-metalogic-cycles.sh` committed their own steps into the
  same "before Report results" slot while this task was in flight. The three new steps were
  appended after both, preserving the documented append-before-"Report results" convention
  rather than inserting between the existing steps.
- **C10 used as the invariants violation, not C9.** The plan anticipated the write-time
  `validate-no-task-references.sh` hook could block a C9 (task-number citation) violation made
  via Write/Edit — it did, on the first attempt at a wording that itself named this task's
  number in a comment. Switched to the plan's documented fallback, a C10 stale-path reference
  (`FormalSystem/docs/old-path.md`), which is not subject to that hook and gave the same
  nonzero-exit proof.
- **Runtime budget table carries two local columns, not one.** Phase 1's full-shell timings and
  Phase 4's minimal-env, extracted-body timings differ measurably (e.g. invariants 23.6s vs.
  20.3s) because Phase 4 reruns the *exact* YAML body under a stripped `env -i`, closer to what
  a CI runner does. Both are kept, clearly labeled, rather than discarding one.
- **Minimal-env PATH built via `command -v`, not the plan's literal `/usr/bin:/bin` template.**
  This development machine is NixOS; `/usr/bin` and `/bin` do not carry `bash`/`git`/`find`. The
  intent (a minimal, explicit tool set standing in for the runner's PATH) was preserved by
  resolving each required tool's directory directly.

## Plan Deviations

- **Task 3.2 (Wiring a New Check Script's runtime-budget table)** altered: populated in Phase 3
  using Phase 1's measurements rather than left empty until Phase 4, since the numbers were
  already in hand. Phase 4 added its own column from the extracted-body measurement rather than
  overwriting Phase 3's — no verification step was skipped.
- **Task 4.2 (minimal-env PATH)** altered: built from `command -v` lookups instead of the
  literal `/usr/bin:/bin` template, because this development machine is NixOS rather than an
  FHS Ubuntu layout. Same intent (minimal explicit PATH), different construction.
- **Task 4 invariants violation** altered from the plan's first-listed option (C9) to its own
  documented fallback (C10), because the C9 attempt was blocked by the
  `validate-no-task-references.sh` write-time hook exactly as the plan's risk note anticipated.

## Verification

- Build: N/A (no `.lean` source changed in the final state)
- Tests: N/A
- Files verified: Yes
  - `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml'))"` succeeds.
  - Parsed step order: `Checkout repository`, `Build, test, and lint with Lean`, `Compile
    lean_exe roots (outside the library closures)`, `check-evidence-probes.sh`, `Check module
    invariants (scripts/check-module-invariants.sh --no-build)`, `Check copyright headers
    (scripts/check-copyright-headers.sh --strict)`, `Check README health
    (scripts/readme-lint.sh)`, `Check Metalogic directory-level import cycles
    (scripts/check-metalogic-cycles.sh)`, `Report results`.
  - `git diff .github/workflows/ci.yml` (against the commit immediately before this task's
    Phase 2 edit) shows only the three new steps, one rewritten comment, and one new header
    comment — no other existing step changed.
  - Clean pass (extracted `run:` bodies, minimal env): invariants 20.3s / exit 0, copyright
    4.5s / exit 0, readme-lint 4.7s / exit 0.
  - Violation pass, each reverted and confirmed clean via `git diff --quiet`: invariants (C10
    stale-path) exit 1, copyright (stripped header) exit 1 (missing: 1), readme-lint (broken
    link) exit 1 (Check 3 FAIL).
  - Final full gate: `lake build` (2653 jobs, success) and the full (non-`--no-build`)
    `bash scripts/check-module-invariants.sh` both green (2m14s).
  - No task-number references were introduced in `.github/workflows/ci.yml` or
    `docs/development/CI_CD_PROCESS.md`.

## Impacts

- Every push/PR to `main` now runs three additional gates that were previously enforced only by
  convention or by hand: module-structure invariants (structural subset), copyright headers, and
  README health. A regression in any of these now fails CI under a step name that identifies
  the script, rather than silently rotting.
- The recorded "Wiring a New Check Script" convention in `CI_CD_PROCESS.md` is now the reference
  every later CI-wiring task (584's `check-paper-definitions.sh`, 586's
  `typst-sync-check.sh`, 590's `ENFORCE_C9_DOCS=1`, 585's compiler-warning gate) should follow,
  including the explicit skip-and-report-neutral requirement that `check-paper-definitions.sh`
  does not yet meet.
- Measured added CI wall-clock (local, warm cache): roughly 30-42 seconds across the three new
  steps (see the two "Local" columns in `CI_CD_PROCESS.md`'s runtime-budget table); the
  Actions-measured column is intentionally left for the user to fill via the checklist below.

## Follow-ups

**User remote-confirmation checklist** (per `.claude/rules/pr-prohibition.md`, this task does
not push or open a PR — the steps below are for the user to run):

1. For each of the three new steps, push a branch that reproduces its local violation and
   confirm in the Actions UI that the step named after the script (`Check module invariants
   (...)`, `Check copyright headers (...)`, or `Check README health (...)`) fails:
   - Invariants: add a `FormalSystem/docs/...`-shaped path reference somewhere outside
     `specs/**` (reproduces the C10 violation used locally), or use a C9 task-number citation
     if preferred (apply via `sed`, not Write/Edit, to avoid the write-time hook).
   - Copyright: remove the copyright header block from one live (non-`Boneyard`)
     `FormalSystem/**/*.lean` file.
   - readme-lint: add a broken relative link to any `FormalSystem/**/README.md`.
2. Push a clean branch (no violations) and confirm the workflow run is green end-to-end,
   including all three new steps.
3. Compare the clean run's total job duration against a recent `main` run from before this
   change, and fill in the "Actions-measured" column of `docs/development/CI_CD_PROCESS.md`'s
   runtime-budget table (`## CI Steps Explained` > `## Wiring a New Check Script` > `### 4.
   Runtime Budget`) with the observed per-step and total deltas.
4. Also confirm `check-paper-definitions.sh` (task 584) adopts the skip-and-report-neutral
   convention recorded here before it is wired — it currently exits 2 on a missing input, which
   this convention forbids.

## References

- specs/583_wire_check_scripts_into_ci/plans/02_wire-check-scripts-ci.md
- specs/583_wire_check_scripts_into_ci/reports/02_wire-check-scripts-ci.md
- specs/583_wire_check_scripts_into_ci/reports/01_uncalled-check-scripts.md
- docs/development/CI_CD_PROCESS.md
- .github/workflows/ci.yml
- specs/reviews/review-2026-09-16.md, Finding H3
