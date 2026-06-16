# Implementation Summary: Task #302

- **Task**: 302 - Comprehensive dead code archival to Boneyard/ with comment cleanup
- **Status**: Implemented
- **Session**: sess_1781633453_61dbf4
- **Phases**: 5/5 completed

## What Was Done

### Phase 1: Archive standalone dead Kamp files
Moved 8 files (4,514 lines) from `Metalogic/WeakCanonical/Kamp/` to two new Boneyard directories:
- `Boneyard/KampNegationClosure/`: NegationClosure.lean, NegationClosure5.lean, NegationClosureProp42.lean, FoToVecEA.lean
- `Boneyard/RabinovichPath/`: RabinovichNegation.lean, RabinovichGeneralized.lean, RabinovichWiring.lean, RabinovichProp42.lean

### Phase 2: Archive dead EFGames, EnrichedClosure, relocate root Boneyard
- Moved 3 EFGames files (3,206 lines) to `Boneyard/StaviDiscretePath/`
- Moved EnrichedClosure.lean (158 lines) to `Boneyard/BXCanonicalQuasimodel/`
- Relocated root `/Boneyard/DeadConvergenceProof/` to `Theories/Bimodal/Boneyard/DeadConvergenceProof/`
- Eliminated root-level Boneyard directory
- Updated StaviCompleteness.lean docstring to note archival

### Phase 3: Extract z1 dead block from ChronicleToCountermodel
- Extracted z1_formula, z1_derivation, z1_in_mcs (13 lines) to `Boneyard/DeadChronicleGapElimination/GapElimination.lean`
- The large dead block (succ_reaches_dom_N through limitDomSubtype_isSuccArchimedean, ~700 lines) was NOT removed — investigation revealed limitDomSubtype_isSuccArchimedean is still used by succ_embed_surjective (line 1721), which is on the live call path

### Phase 4: Extract dead blocks from ChronicleExtraction, ShiftAndGlue, Completeness
- Removed extract_chronicle_as_prior from ChronicleExtraction.lean (44 lines)
- Removed chronicle_is_good and chronicle_is_good_direct from ShiftAndGlue.lean (88 lines)
- Removed countermodel_discrete_enriched from Completeness.lean (36 lines)
- Created `Boneyard/DeadChronicleGapElimination/TransferDead.lean` with all extracted code
- Transfer.lean's countermodel_discrete and countermodel_discrete_reynolds were NOT removed — both are called by live code (Completeness.lean)

### Phase 5: Comment cleanup and Boneyard hygiene
- Fixed SuccRelation.lean section heading (was claiming theorems were "derivable", they're sorry'd tombstones)
- Fixed Axioms.lean comment (BX1 is seriality, not reflexive G)
- Consolidated deprecated section header in Transfer.lean
- Expanded terse sorry comment in InteriorOperators.lean
- Removed stale TODO in 06-notes.typ
- Removed orphaned Research-016 references in DenseSoundness.lean and DiscreteSoundness.lean
- Added #exit guard to ReynoldsModelSurgery.lean
- Updated Boneyard README.md with 5 new subdirectories

## Plan Deviations

- **Phase 3, Task 3.1**: Skipped — the large ChronicleToCountermodel dead block (succ_reaches_dom_N through limitDomSubtype_isSuccArchimedean) is NOT dead; it is still used by succ_embed_surjective at line 1721
- **Phase 4, Task 4.1**: Skipped — countermodel_discrete is called by BXCanonical/Completeness.lean:166
- **Phase 4, Task 4.2**: Skipped — there is no v1/v2 distinction for countermodel_discrete_reynolds; the sole definition is live
- **Phase 5, Task 5.3**: Altered — consolidated the deprecated section header rather than editing individual task refs
- **Phase 5, Task 5.8**: Skipped — "NOTE: constructor removed" comments already removed by a prior task

## Metrics

| Metric | Value |
|--------|-------|
| Files moved to Boneyard | 14 (8 Kamp + 3 EFGames + 1 EnrichedClosure + 2 DeadConvergenceProof) |
| Files created in Boneyard | 1 (TransferDead.lean) |
| Lines archived (standalone files) | ~7,878 |
| Lines extracted (in-file dead blocks) | ~181 |
| New Boneyard subdirectories | 5 |
| Comment fixes | 7 |
| Root Boneyard eliminated | Yes |
| Build status | Passes (pre-existing CanonicalTaskRelation timeout unrelated to changes) |

## Artifacts

- `specs/302_boneyard_dead_code_archival/plans/02_implementation-plan.md` — Implementation plan (all 5 phases marked [COMPLETED])
- `specs/302_boneyard_dead_code_archival/summaries/03_implementation-summary.md` — This file
- `Theories/Bimodal/Boneyard/KampNegationClosure/` — 4 archived files
- `Theories/Bimodal/Boneyard/RabinovichPath/` — 4 archived files
- `Theories/Bimodal/Boneyard/StaviDiscretePath/` — 3 archived files
- `Theories/Bimodal/Boneyard/BXCanonicalQuasimodel/` — 1 archived file
- `Theories/Bimodal/Boneyard/DeadConvergenceProof/` — 2 relocated files
- `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/TransferDead.lean` — extracted dead blocks
