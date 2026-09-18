# Implementation Summary: Task #605

- **Task**: 605 - Reconcile Burgess A7a provenance and add axiom-source footnote
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T07:51:19Z
- **Completed**: 2026-09-18T08:40:00Z
- **Effort**: ~1 hour
- **Dependencies**: None
- **Artifacts**: plans/01_burgess-a7a-provenance.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Only documentation changed. CN (`linear_until`) is confirmed as Burgess 1982 A7a (Xu 1988 (10)),
and it is sound under the tree's strict/open-guard semantics. The old NOTE blamed A7a for the
unsoundness of a removed constructor that had been transcribed incorrectly. That NOTE is
corrected, the provenance is recorded in the docstrings and reference docs, and the paper
footnote's errata are recorded. All four phases are done, and the full gate passed.

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
- **Phase 4** altered: `.claude/scripts/check-task-references.sh` scans only the agent-system trees, which contain none of the six changed files. The same shared pattern library (`TASK_PATTERN`/`PHASE_PATTERN`) was run directly on the six files and found nothing, and invariants C9/C9D also pass. The first Phase 4 run was stopped for low memory; this resume re-ran the whole gate.

## Verification

- Build: Success. Full `lake build` passed (2660 jobs, run through the build guard with a memory bound). Invariant C28 finds no warnings above baseline.
- Sorry count: 0 (invariant C3: the structural sorry inventory is zero across FormalSystem/)
- Vacuous count: 0 introduced. The one grep hit, `int_domain_universal` in `Examples/TemporalStructures.lean`, is older than this task and proves a predicate that really is `True`.
- Axiom count: unchanged. There are no `axiom` declarations; the grep hits are comment lines that start with the word "axiom". Invariants C2/C14 match the axiom baselines.
- Tests: N/A
- `scripts/check-paper-definitions.sh`: pass (all 42 recorded definitions unchanged)
- Task-reference lint: clean on the six files. `scripts/check-module-invariants.sh`: ALL CHECKS PASSED.
- Diff audit: with comments stripped, the code in all four touched Lean files is identical before and after.
- `grep "closed-guard semantics" Axioms.lean`: no matches
- Files verified: Yes (the diff touches comments and docstrings only)

## Impacts

- The Burgess 1982/1984 A7a confusion is resolved everywhere in the built tree. Boneyard is left untouched, per the standing policy.

## Follow-ups

- The paper-side errata (UE, TL/`𝖵₃`) are for the paper's author. The paper is not edited from this repository.

## References

- specs/605_reconcile_burgess_a7a_provenance_and_add_axiom_source_footnote/plans/01_burgess-a7a-provenance.md
- specs/605_reconcile_burgess_a7a_provenance_and_add_axiom_source_footnote/reports/01_burgess-a7a-provenance.md
