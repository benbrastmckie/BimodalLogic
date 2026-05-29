# Implementation Summary: Reynolds k-Equivalence Bypass

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: PARTIAL (Phases 1-2 blocked, Phases 3-4 partially complete, Phase 5 pending)
- **Session**: sess_1780033927_3wcw

## What Was Accomplished

### Analysis and Architecture

Traced the complete sorry chain from `completeness_discrete` to its root cause:
- `completeness_discrete` -> `countermodel_discrete_enriched` -> `cantor_bfmcs_discrete_restricted_tc`/`cantor_bfmcs_discrete_restricted_fuc` -> `succ_embed_surjective` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` (SORRY at ChronicleToCountermodel.lean:1885)

Confirmed that the sorry is NOT in the Reynolds pipeline code (Transfer.lean) but in the parametric canonical model pipeline used by `countermodel_discrete_enriched`.

### Phase 3: chronicle_is_good_direct (COMPLETED)

Added to `ShiftAndGlue.lean`:
1. **`one_class_implies_very_good`** (sorry-free): if all points are contemp_equiv, then the structure is very_good. Uses `good_of_very_good_subinterval`.
2. **`chronicle_is_good_direct`** (sorry via no_gaps_discrete): alternative proof of chronicle goodness via one_class -> very_good -> very_good_implies_good. Does NOT use IsSuccArchimedean or orderIsoIntOfLinearSuccPredArch.

### Phase 4: Reynolds Pipeline Architecture (PARTIAL)

Added to `Transfer.lean`:
1. **`countermodel_discrete_reynolds`** (sorry via no_gaps_discrete + h_truth_corr): demonstrates the full Reynolds pipeline: chronicle extraction -> chronicle_is_good_direct -> truth_transfer -> z_interval_countermodel. Has sorry for TaskFrame packaging (h_truth_corr discharge).

### fc Generalization Refactoring

Generalized multiple functions from `ChronicleAsPriorModel FrameClass.Base` to `ChronicleAsPriorModel fc`:
- `chronicleAsMonadicStructure` and 7 instances in NEquivalence.lean
- `chronicle_is_good`, `chronicle_is_good_direct` in ShiftAndGlue.lean
- `chronicle_temporal_truth` in Transfer.lean
- `imp_iff_mcs` in TruthLemma.lean (generalized from FrameClass.Base to any fc)

### Build Verification

- `lake build` passes with zero errors
- No new sorries on existing critical paths
- All new sorries are in new code demonstrating the Reynolds pipeline

## Remaining Blockers

### Phase 1: US Expressive Completeness Over Prior Structures (BLOCKED)

The existing `US_expressively_complete_over_Z` (Theorem.lean:357-363) is Z-specific. Extending to Prior structures (discrete linear orders satisfying Prior-UZ/SZ) requires:
1. Showing U'(A,B) and S'(A,B) are equivalent to bot in Prior structures
2. Adapting `separation_implies_expressiveness` from `int_truth` on `IntStructureFromSig` to `temporal_truth` on `OrderedMonadicStructure`

Estimated: 8-12 hours of mathematical formalization.

### Phase 2: no_gaps_discrete (BLOCKED, depends on Phase 1)

The sorry at GoodStructures.lean:842. Once Phase 1 provides US expressive completeness, the proof follows Reynolds 1994 Section 8: get temporal formula distinguishing classes, locate boundary at successor pair via IVT.

### Phase 4 Completion: h_truth_corr Discharge

The `z_interval_countermodel` hypothesis `h_truth_corr` requires building a TaskModel with position-dependent atom valuation. The current `zIntervalTaskFrame` uses `WorldState = Unit` (constant state), which cannot capture position-dependent predicates. Options:
1. Build a richer TaskFrame with WorldState carrying atom valuation
2. Restructure the countermodel to use the parametric canonical model pipeline on the Z-interval directly

## Plan Deviations

- Phase 1: **[BLOCKED]** - skipped implementation, documented blocker. US expressive completeness over Prior structures is a substantial mathematical formalization not achievable in current session.
- Phase 2: **[BLOCKED]** - depends on Phase 1.
- Phase 3: **[COMPLETED]** with deviation: added 2 sorry placeholders for semantic Prior-UZ/SZ discharge (secondary to no_gaps_discrete).
- Phase 4: **[PARTIAL]** - pipeline architecture demonstrated but sorry for TaskFrame packaging (h_truth_corr).
- Phase 5: **[NOT STARTED]** - depends on Phases 1-4.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` - Added `one_class_implies_very_good`, `chronicle_is_good_direct`; generalized `chronicle_is_good` to generic fc
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Added `countermodel_discrete_reynolds`; generalized `chronicle_temporal_truth` to generic fc; added ShiftAndGlue import
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Generalized `chronicleAsMonadicStructure` and 7 instances from FrameClass.Base to generic fc
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` - Generalized `imp_iff_mcs` from FrameClass.Base to generic fc
