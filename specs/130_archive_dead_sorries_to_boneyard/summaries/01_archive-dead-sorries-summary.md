# Implementation Summary: Archive Dead Sorries to Boneyard

- **Task**: 130 - Archive dead sorries to Boneyard
- **Status**: Implemented
- **Session**: sess_1779293683_4e43b6
- **Date**: 2026-05-20
- **Plan**: plans/01_archive-dead-sorries.md

## Results

**15 sorries removed from active codebase** (10 archived + 5 deleted):
- Phase 1: Deleted 5 trivial stubs (Construction.lean: 2, TruthLemma.lean: 2, ChronicleToCountermodel.lean: 1)
- Phase 2: Archived RootScopedChain.lean (3 sorries) to Boneyard/ScheduleBasedBFMCS/
- Phase 3: Archived SigmaOrdering.lean (3 sorries) to Boneyard/FiltrationOrdering/
- Phase 4: Extracted 4 sorry-bearing definitions from Realization.lean to Boneyard/BX1DependentCode/

**4 convergence sorries annotated** with DEAD APPROACH markers in ChronicleToCountermodel.lean.

**3 new Boneyard subdirectories** created with README.md documentation:
- Boneyard/ScheduleBasedBFMCS/ (RootScopedChain.lean + README)
- Boneyard/FiltrationOrdering/ (SigmaOrdering.lean + README)
- Boneyard/BX1DependentCode/ (RealizationSorries.lean + README)

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` - Removed 2 sorry stubs
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` - Removed 2 sorry stubs
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Removed 1 sorry stub, added 4 DEAD APPROACH annotations
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Removed RootScopedChain import, added tombstone, removed #print axioms dd_countermodel
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` - Replaced SigmaOrdering import with Frame.lean
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` - Removed F_of_mem, P_of_mem, enriched_seed_consistent_until/since (4 sorries)
- `Theories/Bimodal/Boneyard/README.md` - Added 3 new inventory rows

## Files Created

- `Theories/Bimodal/Boneyard/ScheduleBasedBFMCS/RootScopedChain.lean` (moved)
- `Theories/Bimodal/Boneyard/ScheduleBasedBFMCS/README.md`
- `Theories/Bimodal/Boneyard/FiltrationOrdering/SigmaOrdering.lean` (moved)
- `Theories/Bimodal/Boneyard/FiltrationOrdering/README.md`
- `Theories/Bimodal/Boneyard/BX1DependentCode/RealizationSorries.lean`
- `Theories/Bimodal/Boneyard/BX1DependentCode/README.md`

## Verification

- `lake build` succeeds cleanly after each phase (5 builds total)
- No new errors or warnings introduced
- Zero sorries remain in modified active files (Realization.lean, Construction.lean, TruthLemma.lean)
- 4 convergence sorries remain in ChronicleToCountermodel.lean (annotated, not removable without resolving proof gap)
- All downstream imports verified: Completeness.lean, CanonicalChain.lean, LocusControl.lean compile

## Plan Deviations

- Phase 2: Also removed `#print axioms dd_countermodel` since dd_countermodel was defined in archived RootScopedChain.lean
- Phase 4: Removed entire `enriched_seed_consistent_until/since` definitions (not just sorry-bearing branches) since they were unreferenced by any active code
