# Implementation Summary: Task #605

- **Task**: 605 - Reconcile Burgess A7a provenance and add axiom-source footnote
- **Status**: [IN PROGRESS]
- **Started**: 2026-09-18T07:51:19Z
- **Completed**: 2026-09-18T08:15:28Z
- **Effort**: ~45 minutes
- **Dependencies**: None
- **Artifacts**: plans/01_burgess-a7a-provenance.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Only documentation changed. CN (`linear_until`) is confirmed as Burgess 1982 A7a (Xu 1988 (10)),
and it is sound under the tree's strict/open-guard semantics. The old NOTE blamed A7a for the
unsoundness of a removed constructor that had been transcribed incorrectly. That NOTE is
corrected, the provenance is recorded in the docstrings and reference docs, and the paper
footnote's errata are recorded. Phases 1-3 are done. Phase 4, the full gate, is partial because
its commands were stopped for low memory.

## What Changed

- `FormalSystem/ProofSystem/Axioms.lean`:
  - Replaced the wrong `linear_until` NOTE with a corrected provenance note.
  - Added Burgess/Xu tags to the docstrings of `serial_future`, the `left_mono_*`, `right_mono_*`, `self_accum_*`, `absorb_*` and `linear_*` pairs, `until_F` and `temp_linearity`. Each Burgess formula is quoted verbatim in his `U(event, guard)` order.
  - Added a module-level `## Axiom Sources` table.
  - Corrected the header sentence that said "reflexive semantics".
- The three Chronicle files (`ChronicleGuardAccumulation`, `ChronicleLimitGuardWitness`, `ChronicleRealExtension`) now note that their A7a citation is Burgess 1984's Dedekind-completeness axiom `Fp ∧ FG¬p → F(HFp ∧ G¬p)`, not Burgess 1982's A7a. That formula was checked against the Burgess 1984 PDF.
- `docs/reference/paper-definitions-of-record.md`: the "Open opportunity" paragraph is now a closed record. Added a two-item paper-footnote errata list: UE follows from UG, not UC; Xu has no `𝖵₃`, and TL is Burgess 1984 A2a. The pinned quoted block is unchanged.
- `docs/reference/axiom-reference.md`: added a "Burgess / Xu source" column and an explanatory paragraph.

## Decisions

- Placed `## Axiom Sources` just before `## References`, so it does not split `## Axiom System` from its `### Layers` subsection.
- Split each long line in the table and the Chronicle comments to stay within 100 columns.

## Plan Deviations

- **Phase 1 Axiom Sources placement** altered: it is a top-level section before References instead of a subsection inside Axiom System.
- **Phase 4** partial: the full `lake build`, the task-reference lint and the module-invariants check were stopped by the harness for low system memory, and were not restarted.

## Verification

- Build: scoped build of `FormalSystem.ProofSystem.Axioms` plus the three Chronicle modules succeeded (1755 jobs, no warnings in the touched modules). Full `lake build`: not run (stopped for low memory).
- Sorry count: unchanged (comment-only edits)
- Vacuous count: 0 introduced
- Axiom count: unchanged (no declarations touched)
- Tests: N/A
- `scripts/check-paper-definitions.sh`: pass (all 42 recorded definitions unchanged)
- Task-reference lint, module-invariants: not run (stopped for low memory)
- `grep "closed-guard semantics" Axioms.lean`: no matches
- Files verified: Yes (the diff touches comments and docstrings only)

## Impacts

- The Burgess 1982/1984 A7a confusion is resolved everywhere in the built tree. Boneyard is left untouched, per the standing policy.

## Follow-ups

- Re-run Phase 4 when memory allows: the full guarded `lake build`, `.claude/scripts/check-task-references.sh` on the six files, and `scripts/check-module-invariants.sh`.
- The paper-side errata (UE, TL/`𝖵₃`) are for the paper's author. The paper is not edited from this repository.

## References

- specs/605_reconcile_burgess_a7a_provenance_and_add_axiom_source_footnote/plans/01_burgess-a7a-provenance.md
- specs/605_reconcile_burgess_a7a_provenance_and_add_axiom_source_footnote/reports/01_burgess-a7a-provenance.md
