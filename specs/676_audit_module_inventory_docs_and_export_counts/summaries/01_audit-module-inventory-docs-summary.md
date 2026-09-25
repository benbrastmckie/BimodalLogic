# Implementation Summary: Task #676

- **Task**: 676 - Audit module inventory docs and export counts
- **Status**: [COMPLETED]
- **Started**: 2026-09-25T19:52:47Z
- **Completed**: 2026-09-25T20:33:08Z
- **Effort**: ~1.5 hours
- **Dependencies**: None (the `MinusLanguageSoundness.lean` repoint it follows was already landed)
- **Artifacts**: plans/01_audit-module-inventory-docs.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Audited `docs/user-guide/architecture.md`'s source-tree diagram exhaustively against the live
repository layout and rewrote it in full; settled the Conservativity aggregator's three
mutually-inconsistent re-export counts (nine / five / actual-20) on one answer — 20, "every
import" — applied consistently to the module's own docstring, its bullet list, and
`docs/project-info/implementation-status.md`; and resolved the `MinusLanguage/Soundness.lean`
row-placement question in `implementation-status.md` with a recorded rationale. All edits are
documentation/docstring only; no theorem, statement, or definition was touched.

## What Changed

- `docs/user-guide/architecture.md` — section 6.1 source-tree diagram rewritten in full: 7
  missing top-level `FormalSystem/` subsystems added (`ForMathlib/`, `HybridLanguage/`,
  `OpenLanguage/`, `PlusLanguage/`, `QuantLanguage/`, `StarLanguage/`, `Tactic/`), `Boneyard/`
  moved from a (wrong) `FormalSystem/` child to its real repo-root-sibling position,
  `MinusLanguage/` given its 6 missing files, `Semantics/` corrected (2 misplaced files removed,
  21 missing files and 4 missing subdirectory pointers added), `Metalogic/` corrected (the
  nonexistent `MinusLanguageSoundness.lean` entry removed, 2 missing top-level files and 4
  missing subdirectory pointers added), `Theorems/`/`ProofSystem/`/`Syntax/`/`Automation/`
  reconciled against a live baseline, and an audit-provenance paragraph added beneath the
  diagram recording what was checked and the shim-omission convention.
- `FormalSystem/Metalogic/Conservativity.lean` — module docstring only: the "re-exports the nine
  modules" prose replaced with "re-exports 20 modules... every module this file imports", naming
  the counted set explicitly; two missing bullets added (`Conservativity/ChainBundleTruth.lean`,
  `Conservativity/DenseObstructionTransfer.lean`) in import-consistent order. `git diff` confirms
  both edits confined to the `/-! ... -/` docstring region (lines 368-440); no import,
  declaration, or proof line touched.
- `docs/project-info/implementation-status.md` — the aggregator row's "re-exports the five
  modules below" replaced with wording carrying the same count (20) and set as the docstring,
  explicitly flagging the two rows below it as an illustrative sample rather than the full
  enumeration; the `MinusLanguage/Soundness.lean` row left in place with a parenthetical Notes
  addition recording why (narrative-Layer grouping convention, no other `MinusLanguage/` row
  exists to group it with).

## Decisions

- Defect 2 settled on 20 = "every import" (19 files physically in `Metalogic/Conservativity/`
  plus the cross-directory `MinusLanguage/Soundness.lean`), per the research report's rationale;
  verified by set-equality script (import set == bullet set, both directions).
- Defect 1's style question was pinned to full expansion of every top-level subsystem directory
  to non-shim `.lean`-file level, with second-level subdirectories left as bare pointers,
  matching the tree's own pre-existing convention for `Metalogic/Core/`, `Bundle/`, etc.
  `Conservativity.lean` and `SoundnessLemmas.lean` were kept as their own entries (substantive
  content distinct from their sibling directories) alongside new pointers for
  `Conservativity/` and `SoundnessLemmas/`.
- Defect 3 resolved as "leave the row, add a note" — no other `MinusLanguage/` row exists in the
  table to move it to, and its current position already matches the table's narrative-Layer
  grouping convention.
- `docs/development/PUBLICATION_REFACTOR.md`'s optional clarifying note was skipped (recorded as
  a deviation): the file is explicitly out of this task's scope as the historical record of the
  move, and its old paths were confirmed unchanged (`grep -c MinusLanguageSoundness` stable at 4).

## Plan Deviations

- **Phase 4, optional PUBLICATION_REFACTOR.md note** skipped: file is out of scope (historical
  record); its old-path references are correct in context and were confirmed unchanged.

## Verification

- Build: Success — full-tree `lake build` via `.claude/scripts/lake-build-guard.sh`, 2737 jobs,
  exit 0 (confirmed via `lake-build-guard.sh result`: `state=complete exit_status=0`).
- Tests: N/A (documentation/docstring task; no test suite changes)
- Gates: `scripts/check-module-invariants.sh` — ALL CHECKS PASSED (full run, with build).
  `scripts/readme-lint.sh` — RESULT: PASS.
- Files verified: Yes — every `architecture.md` directory entry spot-checked with `ls -d` against
  disk; `grep -n MinusLanguageSoundness docs/user-guide/architecture.md` returns nothing;
  `grep -rln 'Metalogic/Conservativity/MinusLanguageSoundness'` (outside `specs/**`) returns only
  `docs/development/PUBLICATION_REFACTOR.md`; docstring bullet count (20) equals import count
  (20) with full set equality confirmed both directions; `implementation-status.md`'s aggregator
  row states the same count and set as the docstring; `grep -n 'five modules'
  docs/project-info/implementation-status.md` returns nothing.

## Impacts

- Documentation now accurately reflects the real `FormalSystem/` source layout, closing a drift
  gap that had grown well beyond the three originally-confirmed lines (7 missing subsystems,
  `Boneyard/` under the wrong parent, dozens of missing files across `Semantics/` and
  `Metalogic/`).
- The Conservativity aggregator's re-export count is now internally consistent across all three
  places it was previously stated differently, with the counted set named explicitly so the
  ambiguity cannot silently reappear.

## Follow-ups

- `.claude/CLAUDE.md`'s own "Project Structure" section (repo overview) has the same drift shape
  (missing `MinusLanguage/`, `HybridLanguage/`, `OpenLanguage/`, `PlusLanguage/`,
  `QuantLanguage/`, `StarLanguage/`, `Tactic/`) but is out of this task's declared scope and is
  source-store-governed (see `.claude/rules/source-store-deploy-boundary.md`) — a small follow-up
  task should target the source store copy, not the deployed file directly.

## References

- `specs/676_audit_module_inventory_docs_and_export_counts/plans/01_audit-module-inventory-docs.md`
- `specs/676_audit_module_inventory_docs_and_export_counts/reports/01_audit-module-inventory-docs.md`
- `docs/user-guide/architecture.md` (section 6.1)
- `FormalSystem/Metalogic/Conservativity.lean` (docstring, lines 368-440)
- `docs/project-info/implementation-status.md` (Layer 2: Metalogic table)
