# Implementation Summary: Task #621

- **Task**: 621 - Adopt uniform reflect naming for time reversal
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T17:47:00Z
- **Completed**: 2026-09-18T19:10:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_uniform-reflect-naming.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Absorbed the paper's rename `lem:temporal-duality` → `lem:time-reflection` and applied one naming
principle across the tree: `reflect` names every time-order reversal (formula, frame, history,
truth lemma), and `swap` survives only for exchanges. Pure renames and prose; no statement changed,
no proof added.

## What Changed

- `docs/reference/paper-definitions-of-record.md` — carve-out withdrawn; new dated section
  "Label rename absorption (2026-09-18)" with the full old→new map and keep-list; `swapUS`/`truth_swap`
  bullets flipped to renamed; `lem:time-reflection|LIVE-UNPINNED` KNOWN-ANCHORS row; no re-pin (case b).
- Identifier renames (22 files): `MinusFrame.swap`→`MinusFrame.reflect`, `truth_swap`→`truth_reflectTime`,
  `swapUS`(`_involutive`)→`reflectTimeBoxOpaque`(`_involutive`), `swap_norm`→`reflect_time_norm`,
  `Encoding.swap`→`Encoding.reflectTime`, `plusValidIn_swap_of_tm*`→`plusValidIn_reflect_time_of_tm*`,
  the four `cValid` swap lemmas → `*reflect_time*`, 10 `starValid_*_swap`→`starValid_*_reflect_time`,
  `swap_next_all_future_eq`→`reflect_time_next_all_future_eq`.
- Lean prose (34 files): "swap-validity"→"reflection-validity", "temporal duality soundness"→
  "time-reflection soundness", `swap(φ)`→`reflectTime(φ)` in comments; `MinusFrame.lean` truth-lemma
  docstrings now cite `lem:time-reflection`; the "`swap` in its name" justifications deleted.
- READMEs, docs, typst, test docs (20 files), including a new "Time-reversal naming" rule in
  `docs/development/LEAN_STYLE_GUIDE.md` and the fixed stale `φ.swap` example.

## Decisions

- Exchange-sense uses kept (Kamp/EF transpositions, `contraSwap`, `monoInv_swap`, `trySwap*`,
  argument-order swap prose, operator-duality ▽/△ names). Wire tags byte-stable.
- typst `#definition("Temporal Swap")` retitled "Time Reflection"; the `#let swap` macro name kept.

## Plan Deviations

- **Phase 2** altered: identifier renames in `Automation/README.md` and `MinusLanguage/README.md`
  were applied with the Phase 2 batch (same sed) rather than in Phase 4.
- **Phase 3** altered: fixed a C20 line-number citation (`TruthTransfer.lean` → `Dual.lean:444`)
  shifted by the longer `reflectTimeBoxOpaque` docstring; now cites the file by declaration name.
- **Phase 4** altered: additionally reworded `FormalSystem/README.md`, `Plus/README.md`,
  `Star/README.md`, `Tests/.../Property/README.md`, `docs/reference/API_REFERENCE.md`,
  `typst/chapters/01-syntax.typ` (found by the confirming grep).

## Verification

- Build: Success (full `lake build`, 2661 jobs; `lake build BimodalTest` also green)
- Sorry count: 0 (in live tree; Boneyard pre-existing, not built)
- Vacuous count: 0
- Axiom count: unchanged (no axiom added)
- Tests: Passed (BimodalTest build incl. conformance tests)
- Files verified: Yes — check-paper-definitions (case b), check-module-invariants (all pass after
  `--emit-inventory`), readme-lint, typst-sync-check, typst compile, regression grep empty,
  no string-literal change.

## Impacts

- Downstream code must use the new names; no deprecated aliases were added.

## Follow-ups

- Possible follow-up: `clockMirrorIso`/`truthAt_mirror`, `TruthAntiIso`, `DenseModelSurgery.dual`
  (other words for time reversal; recorded as deferred in the record).

## References

- specs/621_adopt_uniform_reflect_naming_for_time_reversal/plans/01_uniform-reflect-naming.md
- specs/621_adopt_uniform_reflect_naming_for_time_reversal/reports/01_uniform-reflect-naming.md
