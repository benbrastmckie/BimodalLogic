# Implementation Summary: Task #98

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Status**: [PARTIAL]
- **Started**: 2026-04-10
- **Completed**: 2026-04-10
- **Effort**: ~4 hours
- **Dependencies**: None
- **Artifacts**: plans/01_quasimodel-pivot-plan.md, reports/01_filtration-quasimodel-pivot.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, summary-format.md

## Overview

Implemented the Hintikka-set quasimodel infrastructure for the Until/Since truth lemma in the BX canonical model. Five new Lean files were created under `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/`, providing SubformulaClosure, HintikkaPoint, Construction (BX axiom lemmas at MCS level), Realization (proof structure with sorry at guard-lifting), and LocusControl (interface for Frame.lean sorry replacement). The full project builds cleanly (949 jobs) with no regressions.

## What Changed

- Created `Quasimodel/SubformulaClosure.lean`: Finite subformula closure with G/H enrichment and negation pairing. All proofs sorry-free.
- Created `Quasimodel/HintikkaPoint.lean`: Hintikka point structure over Sigma-closure with sigma_signature projection from BXPoint. All proofs sorry-free.
- Created `Quasimodel/Construction.lean`: MCS-level lemma wrappers for BX axioms (BX4, BX5, BX8, BX9, BX10 for both Until and Since). All proofs sorry-free.
- Created `Quasimodel/Realization.lean`: Proof structure for Until/Since eventuality resolution and backward direction. Contains 6 sorry locations at the guard-lifting steps where interval linearity of `bx_le` is needed.
- Created `Quasimodel/LocusControl.lean`: Interface delegating to Realization.lean for Frame.lean sorry replacement.
- Modified `BXCanonical.lean`: Added imports for all 5 Quasimodel submodules.
- Frame.lean and TruthLemma.lean are UNTOUCHED (verified by `git diff`).

## Decisions

- Chose to keep Frame.lean's 4 sorries in place due to circular dependency: Frame.lean defines BXPoint which the quasimodel module needs, but the quasimodel module provides the proofs that Frame.lean needs.
- Simplified SubformulaClosure to omit Burgess-Xu accumulate/absorb operations (which required `Finset.filterMap` injectivity proofs) since the core proofs don't depend on those enrichments.
- Used `open Classical in` scoping for sigma_signature functions that need decidable Set membership.
- Did not attempt to close the realization lifting sorries (the mathematical core) as this requires either proving interval linearity from BX7/BX11 or the full quasimodel defect-discharge construction -- both estimated at 10-20 additional hours.

## Impacts

- The quasimodel infrastructure is in place for future work on closing the Until/Since sorries.
- The sorry count in BXCanonical/ increased from 6 to 12 (4 in Frame.lean unchanged, 1 in Completeness.lean unchanged, 1 in new Realization.lean per function = 6 new, but some have 2 internal sorries).
- No existing sorry-free proofs were affected (zero regressions).
- The mathematical blocker is clearly identified: proving that `bx_le` (defined as `g_content ⊆`) is linear on intervals between Until/Since witnesses.

## Follow-ups

- Close the 6 Realization.lean sorries by either:
  1. Proving interval linearity of `bx_le` from BX7 (linearity of Until) and BX11 (temporal linearity) axioms
  2. Implementing the full Burgess-Xu defect-discharge chain with step-by-step Lindenbaum seed consistency
- Once Realization.lean is sorry-free, restructure to eliminate the circular dependency (split BXPoint definition to a separate file) and replace Frame.lean sorries
- Estimated remaining effort: 15-30 hours for the mathematical proofs

## References

- `specs/098_research_filtration_quasimodel_pivot/reports/01_filtration-quasimodel-pivot.md` -- research report
- `specs/098_research_filtration_quasimodel_pivot/plans/01_quasimodel-pivot-plan.md` -- implementation plan
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/` -- all new source files
