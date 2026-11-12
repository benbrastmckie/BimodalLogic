# Implementation Summary: Task #818

- **Task**: 818 - Wrap the four directory-rollup inventory tables that need the cols=files-lines column set
- **Status**: [COMPLETED]
- **Started**: 2026-11-12
- **Completed**: 2026-11-12
- **Effort**: 3 hours
- **Dependencies**: None
- **Artifacts**: plans/01_wrap-directory-rollup-tables.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Two of the four scoped `## Modules` tables — `FormalSystem/Metalogic/Expressiveness/README.md`
and `FormalSystem/Metalogic/WeakCanonical/README.md` — are now generator-owned `cols=files-lines`
inventory blocks, converting their hand-maintained 3-column `File | Lines | Description` tables
into 4-column `Module | Files | Lines | Description` blocks owned by
`scripts/check-module-invariants.sh --emit-inventory`. The remaining two scoped files
(`Expressiveness/Kamp/README.md` and `Expressiveness/Kamp/NfMultiAnchorBridge/README.md`) were
deliberately left unwrapped, per a blocking finding confirmed during planning and re-confirmed
during implementation.

## What Changed

- `FormalSystem/Metalogic/Expressiveness/README.md` — `## Modules` table wrapped in
  `<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Expressiveness cols=files-lines -->`
  / `<!-- END GENERATED -->`; header rewritten to `| Module | Files | Lines | Description |`;
  all 15 rows regenerated with real numbers (5 subdirectory rows — `EFGames/`, `GameTransfer/`,
  `Kamp/`, `Separation/`, `SeparationZ/` — now carry a live file count alongside the live line
  total); the `(N files)` parenthetical stripped from all 5 subdirectory descriptions;
  `*Last verified*` updated to 2026-11-12.
- `FormalSystem/Metalogic/WeakCanonical/README.md` — same treatment for its 16-row table
  (`DenseModelSurgery/`, `GroupModel/`, `IntegerModel/`, `KTypeSummary/`, `RealModel/` as the 5
  subdirectory rows). `KTypeSummary/` moved from the stale hand-written `1 file / 122 lines` to
  the live `6 files / 958 lines` — the largest single regeneration delta in either file, and a
  correction rather than a loss, exactly as the plan's Scope Hypothesis predicted.

## Decisions

- Used the identical 4-column header and separator (`| Module | Files | Lines | Description |`)
  for both wrapped tables, matching each other rather than inventing a per-file variant.
- Padded every data row — loose and subdirectory alike — to 4 cells before the first
  `--emit-inventory` run, per the plan's correction to the research's recommended procedure:
  `render_block()` only carries a description forward when the existing row already has
  `ncols` cells, so an unpadded subdirectory row would have had its description silently
  replaced by `<!-- TODO: add description -->`.

## Kamp Exclusion (Reasoned, Not an Oversight)

`FormalSystem/Metalogic/Expressiveness/Kamp/README.md` and
`FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/README.md` were **not** wrapped.
Both carry a `| | Files | Lines |` rollup whose data rows are not the two existing shapes
`check-module-invariants.sh` can emit:

- `rows=subdirs` silently **drops** the tables' `loose modules` aggregate row — there is no
  per-row concept for "every loose file taken together" in that mode, so the row would simply
  vanish from the regenerated output with no error.
- `rows=both` **explodes** that one aggregate row into one row per loose file: 49 rows for
  `Kamp/README.md` and 33 rows for `NfMultiAnchorBridge/README.md`, destroying the rollup shape
  the hand-maintained table deliberately uses.

Neither option reproduces the `loose modules` aggregate-row shape, and this task's NON-GOALS
explicitly forbid extending the generator to add one. Registering either table as
`<!-- INVENTORY: hand-maintained (dir=...) -->` was also considered and rejected: that mode's
`audit_hand_maintained()` requires a registered table to have a row for every live file and
subdirectory and no row for anything else, and both Kamp tables violate that today —
`Kamp/README.md` is additionally missing a row for the live `EANegationFixFaithful/`
subdirectory, so registering it would turn the `INV` gate red rather than leaving it at its
current (ungated, hand-maintained-but-unregistered) status.

Both files were confirmed unmodified by this task: `git diff` against the task's base commit
(`9e617b50c`) shows nothing for either path.

**Follow-up candidates** (out of scope for this task):
- A generator option that sums loose files into one aggregate row, to let `Kamp/README.md` and
  `NfMultiAnchorBridge/README.md` be wrapped without an explosion or a silent drop.
- `Kamp/README.md`'s own Structure table is independently stale and missing a row for the live
  `EANegationFixFaithful/` subdirectory — unrelated to the column-set question this task
  answers, and explicitly out of this task's scope (no hand-correction of counts in a table this
  task does not wrap).

## Plan Deviations

- None (implementation followed plan).

## Verification

- Build: N/A (markdown-only task; no Lean source changed).
- Tests: `bash scripts/check-module-invariants.sh --emit-inventory --check` → `PASS INV` after
  both phases, including a dedicated corrupt/restore demonstration per wrapped file:
  corrupting one numeric cell in each file's regenerated block independently produced
  `FAIL INV` naming exactly that file (and, in Phase 2's case, confirmed *not* naming Phase 1's
  file — evidence the two blocks are independently covered); restoring via
  `--emit-inventory` (never a pathspec checkout) in each case produced an empty diff against the
  pre-corruption state.
- `bash scripts/readme-lint.sh FormalSystem` → overall `RESULT: PASS` (0 broken file references,
  0 missing READMEs); neither wrapped file appears in the STALE DATE / MISSING DATE findings
  (both carry an up-to-date `*Last verified: 2026-11-12*` line). The pre-existing STALE DATE
  findings elsewhere in the tree predate this task and are not attributable to it.
- Files verified: Yes — key-sorted before/after description diffs for both files show an
  identical key set (15 keys for `Expressiveness/README.md`, 16 for `WeakCanonical/README.md`)
  with every description byte-identical except the 10 total `(N files)` strips (5 per file);
  zero `<!-- TODO: add description -->` occurrences in either file; zero em-dash placeholder
  rows in either generated block.
- **Batch Gate Deferral**: this phase's plan declares `**Verification Tier**: full`, naming
  `bash .claude/scripts/verify-deploy.sh` as part of its verification. Per this dispatch's Batch
  Gate Deferral directive, that full deploy-tree gate was **not** run independently here — it
  runs once for the whole `/orchestrate` batch at the end of the invocation, and its result is
  attributed back to this task via `modified_files`. Neither `run-all.sh --only SUITE` nor
  `verify-deploy.sh --only-gate N` expresses the two checks that actually cover this edit class
  (`check-module-invariants.sh --emit-inventory --check` and `readme-lint.sh`), since neither is
  a discovered shell test suite or a numbered deploy-tree gate; both were therefore run directly
  as the UNMAPPABLE CRITERION path specifies, and both are recorded above as green.

## Impacts

- Two previously hand-maintained, drift-prone inventory tables are now machine-owned: future
  file additions, removals, or line-count changes under `Expressiveness/` and `WeakCanonical/`
  are caught by `--emit-inventory --check` rather than silently going stale, the same guarantee
  the prior 23-README sweep established elsewhere in `FormalSystem/`.
- The two Kamp rollup tables remain hand-maintained and ungated, carrying the same drift risk
  they always have; this task deliberately leaves that risk in place rather than papering over
  it with an incorrect generator option or an invalid hand-maintained registration.

## Follow-ups

- Consider a `check-module-invariants.sh` generator option that aggregates loose files into one
  summed row (files count + line total), which would let `Kamp/README.md` and
  `NfMultiAnchorBridge/README.md` be wrapped without exploding into 49/33 rows or silently
  dropping the aggregate.
- `Kamp/README.md`'s own Structure table is stale and missing the live `EANegationFixFaithful/`
  subdirectory — a separate, pre-existing issue unrelated to this task's column-set question.

## References

- Plan: `specs/818_wrap_directory_rollup_tables_files_lines_cols/plans/01_wrap-directory-rollup-tables.md`
- Research report: `specs/818_wrap_directory_rollup_tables_files_lines_cols/reports/01_wrap-directory-rollup-tables.md`
