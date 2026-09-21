# Implementation Summary: Task #614

- **Task**: 614 - Refresh stale README date stamps across FormalSystem, repair archive links, re-point typst citations
- **Status**: [COMPLETED]
- **Started**: 2026-09-21T16:01:47Z
- **Completed**: 2026-09-21T18:07:50Z
- **Effort**: ~1.5 hours across two dispatches (13 and 17)
- **Dependencies**: None
- **Artifacts**: plans/01_readme-lint-citation-repair.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Both red documentation lints are green and the advisory stamp drift is cleared. `readme-lint.sh FormalSystem BimodalTools` now exits 0 with 0 broken references (was 21), 0 stale and 0 missing stamps (was 52 + 2); `typst-sync-check.sh` exits 0 with `TOTAL_VIOLATIONS=0` (was 9) in the working tree and in a CI-shaped clean clone. No Lean source, no script and nothing under `Boneyard/` was modified.

## What Changed

- 11 `FormalSystem/**/README.md` files — 21 relative links to the repository-root `Boneyard/` archive gained one `../` each (commit `82beab641`).
- `typst/chapters/p4-dataset-pipeline.typ` — 5 citations re-pointed from `docs/training/PIPELINE.md` to `training/PIPELINE.md` with re-read line ranges paired with their section headings (`:230`, `:389-403`, `:576`, `:578-592`, `:651-676`); 4 orphaned footnotes de-cited into the chapter's own voice (settled option A); the false `README.md:183-184` anchor dropped; the quotation closed at its verbatim sentence; `EnrichedCountermodel.lean` line count corrected 211 -> 223 (commit `b3a095209`).
- `typst/sync-check-whitelist.txt` — two commented blocks: the six surviving `training/PIPELINE.md` spans (`training/` is gitignored) and the deliberate negative reference `lakefile.lean` (same commit).
- 20 non-Metalogic READMEs restamped to 2026-09-21, both lines in the two `Semantics/` double-stamp files (commit `06363865d`).
- 34 `FormalSystem/Metalogic/**` READMEs restamped to 2026-09-21: 32 stale (both lines in the nine double-stamp files) and a new trailing stamp in `Conservativity/Star/README.md` and `Decidability/Verified/Termination/MintBound/README.md`; `Bundle/README.md`'s dated historical record reworded out of stamp shape with its 2026-09-02 date kept (commit `9728e07bb`).

## Decisions

- `FormalSystem/README.md`'s stamp line carries claims (`lake build` clean and sorry-free, invariants all-green, `check-paper-definitions.sh` exit 0, `typst-sync-check.sh` PASS). Each was re-run on the settled tree before the date was bumped; all held.
- Phase 2 before Phase 3, so the root README's "`typst-sync-check.sh` PASS" claim was true on the day it was restamped.
- The de-cited content's canonical home is the chapter itself; `training/PIPELINE.md:10` and `:676` record that consolidation.
- Dispatch 13's blocker (21 foreign uncommitted `.lean` edits turning Check 2b red) had cleared by dispatch 17: the tree carried no Lean modifications, Check 2b was green with no module-map regeneration by this task, and no foreign file was touched.

## Plan Deviations

- **Phase 1, link corrections** altered: one scripted pass with per-link resolve assertions and an exact count of 21, instead of 21 hand edits.
- **Phase 2, clean-export gate** altered: a `git archive HEAD` export prints `TOTAL_VIOLATIONS=0` for Check 1, but the script exits 1 there because Check 2's status-count regeneration calls `git` and an export has no `.git`. The exit-0 evidence is a `git clone --depth 1` of HEAD (no `training/`, no `.lake/`, `.git` present, i.e. what CI checks out): PASS on all checks at `b3a095209` and again at `9728e07bb`.
- **Phase 3, file list** altered: 20 files, not 19. `FormalSystem/Tactic/README.md` went stale from a sibling's 2026-09-21 commit and was restamped here rather than in Phase 5.
- **Phases 3 and 4, stamp edits** altered: a scripted per-file pass asserting the expected number of stamp lines and the stamp shape of each, rewriting only the date token; diffs reviewed (date strings only, plus the two appended stamps and the one `Bundle` rewording).
- **Phase 5, restamp follow-up commit** skipped: not needed, every commit landed on 2026-09-21.
- **Phase 5, sibling-attribution step** skipped: not needed, `check-module-invariants.sh --no-build` passed outright.
- **Phase 5, R8 line numbers** altered: the two baseline rows now sit at `docs/development/REFERENCE_NORMAL_FORM.md:193-194`, not `:159-160`.

## Verification

- Build: Success — guarded, detached full `lake build`, exit 0, 2663 jobs, run twice this dispatch on a tree with no Lean modifications (before the root README restamp and after the last commit)
- Sorry count: 0 (`lean-sorry-census.sh FormalSystem/`)
- Vacuous count: 0 introduced. The single-line grep matches one pre-existing line, `FormalSystem/Examples/TemporalStructures.lean:483` (`intTimeHistory.domain t := trivial`, a genuine proof of a `True`-valued domain), untouched by this task.
- Axiom count: 12 `^axiom ` lines under `FormalSystem/`, identical to the count before this task's first commit; this task's four commits touch no `.lean` file
- Tests: N/A
- Files verified: Yes
- `readme-lint.sh FormalSystem BimodalTools` after the last commit: exit 0, `Broken file references: 0`, 0 `STALE DATE`, `Missing dates (info): 0`, `RESULT: PASS`; in the `git archive` export: `Broken file references: 0`, PASS
- `typst-sync-check.sh`: working tree exit 0, `TOTAL_VIOLATIONS=0`, Checks 2/2b/3 all 0; depth-1 clean clone of `9728e07bb` the same
- `typst compile --root ..` for `BimodalReference.typ` and `FormalFoundations.typ`: both exit 0 (pre-existing font warnings only)
- `check-module-invariants.sh --no-build`: ALL CHECKS PASSED; `--emit-inventory --check`: PASS, exit 0
- `check-paper-definitions.sh`: exit 0
- `git status --porcelain -- Boneyard/`: empty; commit-stat review shows only the declared READMEs, the two typst files and this task's own `specs/614_*` artifacts
- Plan compliance spot-check: skipped (the plan names no Lean identifiers)

## Impacts

- CI's README-health step and typst sync step both move from red to green.
- **Cross-task (R8)**: `docs/development/REFERENCE_NORMAL_FORM.md` §5 "Recorded baselines" (rows at `:193-194`) still records `readme-lint.sh` broken references = 21 and `typst-sync-check.sh` Check 1 = 9 violations, both "unchanged". They are now 0 and 0 (commits `82beab641` and `b3a095209`), and the accurate direction is "must stay 0". That file is outside this task's scope and was not edited.
- **CI Check 4 limitation**: CI checks out at depth 1 (`actions/checkout@v5`, no `fetch-depth`), so there every directory's `git log -1` date is HEAD's date and the first commit on a later day makes every README read as stale. Check 4 is advisory and never affects the exit code; the zero-stale result is measured on the local full clone. Later CI stamp output is not a regression of this sweep.
- The `training/PIPELINE.md:NNN` spans are whitelisted and the file is untracked, so no gate re-verifies their line numbers; each is paired with a section heading to survive drift.

## Follow-ups

- Update the two baseline rows in `docs/development/REFERENCE_NORMAL_FORM.md` §5 to 0 / "must stay 0".
- The 89 ungated `NOT LISTED` Check 2 findings remain (out of scope, pre-existing).
- `typst-sync-check.sh` Check 2 cannot run without a `.git` (traceback in a `git archive` export); harmless on CI, noted for whoever next touches that script.

## References

- specs/614_refresh_stale_readme_date_stamps_across/plans/01_readme-lint-citation-repair.md
- specs/614_refresh_stale_readme_date_stamps_across/reports/01_readme-stamps-lint-repair.md
- specs/614_refresh_stale_readme_date_stamps_across/handoffs/phase-2-handoff-20260921T110800.md
