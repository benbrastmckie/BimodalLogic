# Handoff: Density Gap in DovetailedTimelineQuot

**Session**: sess_1773848716_f870d9
**Date**: 2026-03-18
**Phase**: 1 (blocked) / 4 (not started)

## Summary

Implementation of Phases 1-3 completed with one critical sorry in `dovetailedTimeline_has_intermediate`. Analysis revealed this is a genuine gap in the plan, not a simple proof oversight.

## Files Created

1. `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
   - DovetailedTimelineElem, DovetailedTimelineQuot definitions
   - Cantor prerequisites (NoMaxOrder, NoMinOrder - both complete)
   - DenselyOrdered (depends on sorry)
   - Cantor isomorphism
   - AddCommGroup, IsOrderedAddMonoid via DurationTransfer
   - MCS extraction

2. `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedFMCS.lean`
   - Core linking lemma: `dovetailedTimelineQuot_lt_implies_canonicalR`
   - Forward G, Backward H coherence
   - FMCS construction over DovetailedTimelineQuot
   - Root MCS existence

## The Density Gap

### Problem Statement

The theorem `dovetailedTimeline_has_intermediate` requires:
```lean
∀ p q, p < q → ∃ c, p < c < q
```
where `<` is induced by CanonicalR.

### Why Dovetailed Construction Doesn't Provide This

The dovetailed construction adds three types of witnesses:
1. **Forward witnesses** for F-formulas (via processForwardObligationDovetailed)
2. **Backward witnesses** for P-formulas (via processBackwardObligationDovetailed)
3. **Density witnesses** for F-formulas (via processDensityDovetailed)

The density witnesses are between a point p and its IMMEDIATE forward witness, not between arbitrary p < q pairs.

### How DenseTimeline Handles This

DenseTimeline.lean uses `densityWitnessesForSet` which explicitly:
```lean
def densityWitnessesForSet (baseSet : Finset StagedPoint) (stage : Stage) : Finset StagedPoint :=
  baseSet.biUnion fun a =>
    baseSet.biUnion fun b =>
      if h : CanonicalR a.mcs b.mcs ∧ ¬CanonicalR b.mcs a.mcs then
        {densityIntermediatePoint a b h.1 h.2 stage}
      else
        ∅
```

This adds density intermediates for ALL pairs (a, b) with a < b, guaranteeing DenselyOrdered.

### Resolution Options

1. **Modify DovetailedBuild to add pair-wise density** - Add a `processPairwiseDensityDovetailed` step similar to `densityWitnessesForSet`. This would require significant changes.

2. **Prove existing witnesses suffice** - Show that the existing density witnesses chain together to provide intermediates for arbitrary pairs. This seems unlikely to work without additional structure.

3. **Use DenseTimeline for density, Dovetailed for coverage** - Combine both constructions. DenseTimeline provides DenselyOrdered, DovetailedCoverage provides forward_F/backward_P.

4. **Fall back to TimelineQuot** - The existing DovetailedCompleteness.lean already uses TimelineQuot and has a sorry in `timelineQuot_not_valid_of_neg_consistent`. The dovetailed coverage lemmas could potentially fill that sorry.

## Recommendation

Option 4 seems most aligned with the existing codebase:
1. The DenseTimeline construction already provides DenselyOrdered
2. The DovetailedCoverage provides sorry-free has_future/has_past
3. TimelineQuot combines these via the bridge in TimelineQuotCanonical.lean

The plan's assumption that DovetailedBuild alone provides density was incorrect. The construction focuses on coverage (forward_F/backward_P), not pair-wise density.

## Current State

- **Phase 1**: PARTIAL (1 sorry: dovetailedTimeline_has_intermediate)
- **Phase 2**: COMPLETED
- **Phase 3**: COMPLETED
- **Phase 4**: NOT STARTED (blocked by Phase 1 sorry)
- **Phase 5**: NOT STARTED

## Build Status

```
lake build Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot  # 1 sorry warning
lake build Bimodal.Metalogic.StagedConstruction.DovetailedFMCS          # clean
```

## Next Steps

1. Decide on resolution approach (recommend Option 4)
2. If proceeding with Option 4, modify DovetailedCompleteness.lean to use DovetailedCoverage for the forward_F/backward_P gap
3. If new plan is created, update plan version to v9
