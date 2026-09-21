# Implementation Summary: Task #642

- **Task**: 642 - Restore layer measurement for the language directories
- **Status**: [COMPLETED]
- **Started**: 2026-09-21T00:00:00Z
- **Completed**: 2026-09-21T03:00:00Z
- **Effort**: about 3 hours (plan estimate 5.5)
- **Dependencies**: None
- **Artifacts**: plans/01_restore-layer-measurement-language.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`FormalSystem/{Minus,Plus,Star}Language/` had no row in `LAYERS`, so `layer_of` returned `None`
for their 33 modules and the equality-asserted upward allowlist passed vacuously on an empty set.
The three directories are now layered per file, keyed on each file's directory before the
language-extension merge (commit `e2b646c84`); `layer_of` raises for any module under
`FormalSystem/` with no row; the allowlist is restored to the 7 measured lines; a third named
assertion enforces syntax-before-semantics inside the language directories; every failure
direction was negative-tested by hand on the real tree; and eight documents plus three aggregator
docstrings now state the measured order. **The measured upward set is exactly the expected 7
lines; no other line surfaced, so there is no finding to escalate.**

## What Changed

- `scripts/measure-refactor-partitions.py` — `LAYERS` rows `Version: 0`, `MainResults: 4`; new
  30-row per-file table `LANGUAGE_FILE_LAYERS` (13 at layer 0, 16 at layer 1, `Soundness` at 3)
  with the decision record in the comment above it; `LANGUAGE_AGGREGATOR_LAYER = 1`; new
  `UnlayeredModuleError`; `layer_of` rewritten to raise (names the module and the table lacking
  the row, at both levels, and for nested modules); `stale_language_rows`, surfaced in
  `measure_upward_edges` and `print_upward_edges`; `main` catches the error and exits 1 on stderr;
  docstring `upward-edges` block regenerated, CAVEAT paragraph deleted.
- `scripts/check-metalogic-cycles.sh` — `ALLOWLIST` restored to 7 lines under
  `FormalSystem.MinusLanguage.AxiomDischarge`; assertion B prints an unlayered module as a `FAIL`
  line (no traceback) and fails on `STALE ROW`; new assertion C in its own heredoc with
  `SYNTAX_STATUS`, a non-vacuity guard, `SYNTAX->SEMANTICS` lines and remediation text; header,
  exit-code paragraph and shortfall hint rewritten.
- `ORGANISATION.md` — layer table gains `MainResults.lean`, `Version.lean` and a per-file row for
  the three directories; "upward set is now empty" replaced by the 7 measured lines; the
  "sit outside this table" subsection replaced by "layered per file" (L=0/1/2/3 figures, origin
  rule, merge commit, per-file table, the three mechanisms); blind-spot sentence removed.
- `docs/ARCHITECTURE.md` — diagram box redrawn (layers 0/1/3, 7 upward lines from
  `AxiomDischarge`), `MainResults.lean` and `Version.lean` added to the diagram and the layer-0
  table; upward-set section rewritten; new per-file section; `Syntax/` row corrected.
- `docs/development/MODULE_INVARIANTS.md` — two assertions become three; fail-loud lookup,
  stale-row failure, assertion C and the hand negative tests described.
- `docs/development/PUBLICATION_REFACTOR.md` — measurement row corrected from 0 to 7; Phase 4
  status paragraph corrected; Phase 5's "become ordinary downward edges" bullet struck as refuted
  by measurement (that document's own strike-through convention); allowlist sentence corrected.
- `docs/development/MODULE_RELOCATION.md` — "No harness check catches a regression there"
  replaced: the lookup now raises (seventh file, found by the Phase 4 scope grep).
- `scripts/README.md`, `README.md` — script row now three assertions; Architecture link text no
  longer embeds a wrong count.
- `FormalSystem/{Minus,Plus,Star}Language/README.md` — "No mechanical check enforces it" replaced
  by the check that does, with the new-file-needs-a-row note; Minus README files `Soundness.lean`
  as a metalogic module (layer 3) instead of a semantic one.
- `FormalSystem/{Minus,Plus,Star}Language.lean` — one docstring sentence each; no import,
  declaration or namespace change.
- `README.md`, `FormalSystem/README.md` — generated inventory blocks regenerated
  (`--emit-inventory`): the docstring edits added 6 comment lines.

## Decisions

- **Per-file sub-layer, not a per-directory layer.** Re-measured during implementation, with
  aggregator sources excluded as assertion B does: one layer L for all three directories leaves
  23 upward lines at L=0, 9 at L=1, 5 at L=2, 3 at L=3. Every choice yields a set that tracks
  the number rather than the tree.
- **Classification rule: pre-merge origin directory**, re-derived from
  `git show -M --name-status e2b646c84` (30 renames, matching the 30 live files), not from the
  research report's table. A content judgement could put `AxiomDischarge` at layer 2 and empty
  the allowlist by assertion.
- **Explicit table over a filename-prefix heuristic**: the heuristic misfiles `Soundness` and
  would classify the next new file silently.
- **Assertion C kept although B subsumes it today**, so the failure names the invariant and
  survives a future allowlist entry. Its sets are intersected with the import graph so a moved
  directory empties them and trips the guard.
- **`layer_of(src)` stays evaluated before the aggregator exclusion** in assertion B, so an
  aggregator with no row still raises.
- The stale-row report does not change the measurement script's own exit code; the failure is
  assertion B's (`upward-edges` prints the stale rows, `check-metalogic-cycles.sh` exits 1).

## Plan Deviations

- **Task 4.7** altered: the scope grep found a seventh repository-level file,
  `docs/development/MODULE_RELOCATION.md`, stating that no harness check catches an unlayered
  directory; corrected in Phase 4, as the phase's scope hypothesis directs.
- **Task 5.2** altered: `Soundness.lean` was moved out of the hand-written semantic-modules table
  only. Its other occurrence is the generated per-file inventory (between
  `BEGIN/END GENERATED` markers), which lists files alphabetically without classifying them and
  is not hand-edited.
- **Task 5.1** note: the three `Last verified` stamps already read 2026-09-21 (the commit date);
  no bump was needed.
- **Task 6.2** altered: "no files expected" did not hold — the harness's INV check went red
  because the aggregator docstring edits changed line counts recorded in two generated inventory
  blocks; regenerated with the harness's own `--emit-inventory`, after which all checks passed.
- Beyond the plan, `docs/ARCHITECTURE.md`'s diagram and layer-0 table gained `MainResults.lean`
  and `Version.lean`, since both now carry a layer row; and one script comment was corrected
  (`Version.lean` imports `Init`, not nothing).

## Verification

- Build: Success — `lake build` exit 0 (2663 jobs); three-aggregator build exit 0 (1384 jobs)
- Tests: Passed — `check-module-invariants.sh` ALL CHECKS PASSED (includes `lake build
  BimodalTest`, C1, C5, C9, C9D, C12, INV, warning budget); `readme-lint.sh` RESULT: PASS;
  `check-task-references.sh` PASS
- Files verified: Yes

**Acceptance criteria, each by command and observed line**

| Criterion | Command | Observed |
|---|---|---|
| Non-empty measured set for the three directories | `python3 scripts/measure-refactor-partitions.py upward-edges` | `Total upward import lines: 7`; `### MinusLanguage -> Theorems (7 lines)`; `Stale per-file rows ...: 0` |
| No `None` path under `FormalSystem/` | loop of `layer_of` over every `FormalSystem.*` module in `ImportGraph()` | `504 library modules, 0 with None layer, 0 raised`; `None` for root `FormalSystem`, `Mathlib.*`, `BimodalTest.*` |
| Cycle script green, non-vacuous allowlist, exactly 1 cycle | `bash scripts/check-metalogic-cycles.sh` | `PASS  exactly 1 directory-level import cycle`; `PASS  upward import set is exactly the recorded 7 line(s)`; `PASS  no language-directory syntax module imports a semantics module (13 syntax modules, 16 language-directory semantics modules ...)`; exit 0 |
| Negative tests observed to fail | see below | six failure directions, each exit 1 |

**Negative tests** (real file edits through the real scripts; each file saved with `cp -p`,
restored unconditionally, confirmed with `git diff --quiet`; no concurrent `lake build`):

| # | Edit | Observed lines | Exit |
|---|---|---|---|
| 1 | `import FormalSystem.PlusLanguage.PlusTruth` added to `PlusLanguage/Formula.lean` | `SURPLUS    FormalSystem.PlusLanguage.Formula -> FormalSystem.PlusLanguage.PlusTruth`; `FAIL  upward import set is not the recorded allowlist (1 surplus, 0 shortfall)`; `SYNTAX->SEMANTICS  ...Formula -> ...PlusTruth`; `FAIL  syntax before semantics: 1 import line(s) ...` | 1 |
| 2 | `import FormalSystem.Theorems.TemporalDerived` deleted from `MinusLanguage/AxiomDischarge.lean` | `SHORTFALL  ...AxiomDischarge -> FormalSystem.Theorems.TemporalDerived`; `FAIL ... (0 surplus, 1 shortfall)`; assertion C still `PASS` | 1 |
| 3 | empty `FormalSystem/PlusLanguage/Scratch.lean` | cycles: ``FAIL  unlayered module `FormalSystem.PlusLanguage.Scratch`: the per-file table LANGUAGE_FILE_LAYERS["PlusLanguage"] has no row `Scratch` ``; measure script: same message on stderr, no stdout | 1 / 1 |
| 4 | `FormalSystem/ScratchDir/Thing.lean` | cycles: ``FAIL  unlayered module `FormalSystem.ScratchDir.Thing`: the top-level table LAYERS has no row `ScratchDir` ``; measure script: same on stderr | 1 / 1 |
| 5 | bogus `"Bogus": 0` row in the `PlusLanguage` per-file table | `STALE ROW  FormalSystem.PlusLanguage.Bogus`; `FAIL  1 per-file layer row(s) name a module that does not exist`; `upward-edges` reports 1 stale row | 1 |
| — | restored tree | three `PASS` lines | 0 |

No test failed to fail; no script fix was needed after Phase 2.

## Impacts

- `check-metalogic-cycles.sh` (run in CI) now turns red on: a new top-level directory under
  `FormalSystem/` with no `LAYERS` row; a new file in a language directory with no
  `LANGUAGE_FILE_LAYERS` row; a renamed/removed language-directory file whose row stayed; any
  syntax-to-semantics import inside the language directories. Anyone adding such a file must add
  a row in `scripts/measure-refactor-partitions.py` and `ORGANISATION.md` together.
- `measure-refactor-partitions.py --json` output gains `upward-edges.stale_language_rows`; the
  other three measurements are byte-identical to the pre-change script's output on this tree.
- The three aggregator docstring edits rebuilt about 30 dependents; no declaration changed.

## Follow-ups

- The 7 `MinusLanguage/AxiomDischarge.lean -> Theorems/*` lines are recorded, not removed.
  Turning them downward means relocating the file (non-goal here).
- Pre-existing drift, not introduced by this task and outside its scope: the
  `weakcanonical-partition` and `automation-partition` figures typed into the measurement
  script's docstring (141 files / 104,087 lines; 9 library-needed, 25 tooling) no longer match
  what the script prints on the current tree (139 files / 104,108 lines; residual 38 / 28,536;
  4 library-needed, 0 tooling). `PUBLICATION_REFACTOR.md`'s table carries the same older figures,
  pinned there to commit `220e94ea4`. Worth a small regeneration task.
- The Phase 1 commit (`d9532155a`) was made before the attribution trailer was added to commit
  messages; Phases 2-6 carry it.

## References

- `specs/642_restore_layer_measurement_for_language_directories/plans/01_restore-layer-measurement-language.md`
- `specs/642_restore_layer_measurement_for_language_directories/reports/01_restore-layer-measurement-language.md`
- `specs/642_restore_layer_measurement_for_language_directories/progress/phase-{1..6}-progress.json`
- `scripts/measure-refactor-partitions.py`, `scripts/check-metalogic-cycles.sh`
- `ORGANISATION.md` (section "The extension-language directories are layered per file")
- Commits: `d9532155a` (phase 1), `1c35e164f` (phase 2), phases 3-6 following on `main`
