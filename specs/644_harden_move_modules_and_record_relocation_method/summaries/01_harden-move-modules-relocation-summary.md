# Implementation Summary: Task #644

- **Task**: 644 - Harden move-modules and record relocation method
- **Status**: [COMPLETED]
- **Started**: 2026-09-21T16:01:11Z
- **Completed**: 2026-09-21T16:30:00Z
- **Effort**: ~0.5 hours wall-clock (plan estimate 10.5 hours)
- **Dependencies**: None
- **Artifacts**: plans/01_harden-move-modules-relocation.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`scripts/move-modules.py` gained the five hardening changes the task enumerates, each behind a
fixture test observed red against the unmodified tool and green after; a stdlib-only fixture
harness (`scripts/test-move-modules.py`, 28 tests) now exists; and
`docs/development/MODULE_RELOCATION.md` records the relocation method. A dry-run replay of the
Expressiveness extraction against an export of its pre-move commit reports exactly that move's 17
provenance READMEs (plus two ADRs and `typst/SYNC-MAP.md`) as skipped. The tool was never run in
apply mode against this repository.

**One acceptance item is not literally green in the shared tree**: `check-module-invariants.sh
--no-build` fails on INV only, because a concurrent sibling has uncommitted edits to 21
`FormalSystem/**/*.lean` files that make four generated inventory blocks stale. See Verification.

## What Changed

- `scripts/move-modules.py` — (1) `--no-rewrite PATH_OR_GLOB` (repeatable, ADDS to the defaults
  `Boneyard/**/README.md`, `typst/SYNC-MAP.md`, `docs/architecture/ADR-*.md`): matching files are
  walked and reported with their would-be occurrence count, never written by any class including
  class 7, excluded from class counts and from the bare-form audit; a "skipped AND moved" sub-list
  appears when non-empty. (2) Identical-sides detector (`side_pairs`, `rewrite_fragment`,
  `identical_sides`) run from `run()` over files headed for a write; `--strict` promotes warnings
  to a non-zero exit. (3) `AmbiguousStem`: `resolve_move` refuses a stem that is both a directory
  and a `.lean` file, naming both and the two-invocation remedy; checked up front before anything
  is read, and again per mapping in `move_trees`. (4) `in_move_set` (handles file-granular rows),
  a `namespace`-declaration collector at the class-4 step, a refusal before the write loop naming
  every offending file and line, and `--namespace-paths` scoping class 4 in both rewrite passes
  (class 5 never scoped). (5) A `files moved N in P path(s), against K citation(s) rewritten` line
  and a non-zero exit when nothing moved, dry run included. Plus `glob_to_regex`, `SELF_PATHS`,
  and docstring `Inputs` / "Refusals and exits" text.
- `scripts/test-move-modules.py` — Created. `fixture_repo`, `run_tool`, `write_map`, `snapshot`;
  28 tests in 7 classes, including the history-gated `ReplayTest`.
- `scripts/README.md` — One row for the test file.
- `docs/development/MODULE_RELOCATION.md` — Created. The nine method items each under their own
  heading, the aggregator-layout remedy, a Tooling table, and a ten-step pre-move checklist.
- `docs/development/README.md` — One row in the "Project Organization" table.

## Decisions

- The path default is `docs/architecture/ADR-*.md`, not the task description's `docs/adr/**`,
  which does not exist (research finding, adopted by the plan).
- The namespace refusal is keyed on what class 4 would actually rewrite (plan D6): a declaration
  already renamed by class 2, because namespace and module prefix coincide, is not refused.
- The moved-versus-rewritten line counts actual files (a directory row's whole subtree), since a
  count of rows says little about what moved.
- The fixture test file is excluded from the tool's rewrite scope together with the tool: its map
  rows name made-up modules under real roots and would be rewritten into `new -> new`.

## Plan Deviations

- **Task 4.x** altered: added `SELF_PATHS` and its test (not in the plan), for the reason above.
- **Task 7.5** altered: the permanent replay test runs the loaded tool's `run()` in process from
  inside the export rather than copying the tool file in; identical code under test.
- **Task 7.9** altered: the harness is RED on INV in the shared tree (foreign uncommitted
  `FormalSystem/**/*.lean` edits); INV green was shown on an isolated export instead.

## Verification

- Build: N/A (no Lean source touched)
- Tests: Passed — `python3 scripts/test-move-modules.py`: Ran 28 tests, OK, replay test executed.
  Red-before outputs for deliverables (1)-(5) are recorded per phase in `progress/`.
- Replay at `3419bdb8d` (dry run, that move's own maps): baseline with the export's unmodified
  tool reproduced the plan's Scope Hypothesis exactly (369/638/149/0/2, 13 paths, bare-form
  232/232, 282 files changed). Hardened: rc 0, 13 paths (149 files), 66 files matched the
  defaults, 20 with would-be rewrites = 17 + 2 + 1, `files changed` 262, class 2+3 lower by
  exactly the 143 would-be occurrences, bare-form 174/174, class 4 zero, refusal did not fire.
  The 17 were derived independently by `git grep` over all 13 old prefixes; the two lists are
  equal path by path.
- Harness, shared tree: rc 1, a single failure, `FAIL INV 4 file(s) carry a stale generated
  inventory block` — all four are `dir=FormalSystem` blocks made stale by a sibling's uncommitted
  `.lean` edits. Phase 1's baseline was all green at the same harness commit (`18799fcd9`). C9,
  C9D, C12 (64 files, was 63) and C13 (61, was 60) pass with this task's files in scope.
- Harness, isolated export of HEAD plus this task's files: `PASS INV`; the only failure is C28,
  which needs `.lake` build traces the export lacks and passes in the shared tree.
- Files verified: Yes. No task numbers in any file outside `specs/` (C9 and C9D pass; grep clean).

## Impacts

- A map row naming a directory that has a same-named aggregator `.lean` file (41 such pairs in
  this repository) is now refused instead of silently orphaning the file; the remedy is in the
  error text and the playbook.
- A run that moves nothing now exits non-zero, including a dry run and a re-run of an
  already-applied map. There is no override, by design.
- Files on the `--no-rewrite` defaults are never rewritten, so present-tense citations inside
  them must be updated by hand; the report lists them.
- On the Expressiveness-extraction replay the identical-sides warning fires zero times, with the
  skip list enabled or disabled: every falsification in that move was single-sided. The skip list
  protects those; the warning protects two-sided "from X to Y" sentences. Recorded in the playbook.

## Follow-ups

- Re-run `bash scripts/check-module-invariants.sh --no-build` once the sibling's
  `FormalSystem/**/*.lean` edits are committed and their inventory blocks regenerated; this task
  deliberately did not run `--emit-inventory`, which would have baked uncommitted foreign line
  counts into READMEs it does not own.
- The inverse error (stale present-tense citations the rules never match) remains undetected by
  any flag — an explicit non-goal, stated in the playbook.

## References

- specs/644_harden_move_modules_and_record_relocation_method/plans/01_harden-move-modules-relocation.md
- specs/644_harden_move_modules_and_record_relocation_method/reports/01_harden-move-modules-relocation.md
- specs/644_harden_move_modules_and_record_relocation_method/progress/phase-{1..7}-progress.json
- specs/644_harden_move_modules_and_record_relocation_method/handoffs/ (phase-7 checkpoint, with the territory rule 5 observation report)
