# Implementation Summary: Task #956 - D Construction (Session C)

**Date**: 2026-03-12
**Session**: sess_1773337195_0a1a7c
**Status**: PARTIAL
**Phase**: 6 (Well-Founded Strict Density)

## Summary

Continued Phase 6 implementation. Made progress on proving unreachable cases and added helper lemmas for strict futures. The core challenge of proving strict density for all cases remains, requiring well-founded iteration.

## Progress Made

### New Lemma: `irreflexive_mcs_has_strict_future`

Added helper lemma that proves: if M is not reflexive (NOT CanonicalR M M), then the seriality future W satisfies NOT CanonicalR W M (strict).

**Key insight**: For non-reflexive M, there exists phi with G(phi) in M but phi not in M. By Temporal 4, G(G(phi)) in M, so G(phi) in GContent(M) subset W. Thus phi in GContent(W) but phi not in M, so GContent(W) is NOT subset of M.

### CantorApplication.lean Improvements

1. **NoMaxOrder**: Expanded proof structure with explicit case analysis:
   - Case: q is strict future - PROVEN
   - Case: q equivalent to p, iterate to q':
     - Subcase: q' is strict - PROVEN
     - Subcase: q' equivalent, p reflexive - SORRY (needs well-founded iteration)
     - Subcase: q' equivalent, p NOT reflexive - PROVEN UNREACHABLE (mutual accessibility implies reflexivity)

2. **NoMinOrder**: Similar structure to NoMaxOrder using past direction
   - Strict past case - PROVEN
   - Non-strict case - SORRY

3. **DenselyOrdered**: Set up proof using `density_frame_condition_strict`
   - Extract strict ordering from quotient `<`
   - Apply density to get intermediate
   - Need to show intermediate is STRICT - SORRY

### Key Unreachability Proof

Proved that if p.mcs is NOT reflexive but both q and q' are equivalent to p (mutual CanonicalR), then we get a contradiction:
- From mutual accessibility via Temporal 4 closure
- G(phi) in p.mcs implies G(G(phi)) in p.mcs (Temporal 4)
- G(phi) in GContent(p.mcs) subset q.mcs
- phi in GContent(q.mcs) subset p.mcs
- Hence GContent(p.mcs) subset p.mcs, contradicting non-reflexivity

### Sorry Count

| File | Previous | Current | Change |
|------|----------|---------|--------|
| DensityFrameCondition.lean | 16 | 16 | 0 |
| CantorApplication.lean | 3 | 3 | 0 |

Note: The structure improved significantly even though sorry count didn't decrease. Several cases that previously needed sorries are now proven unreachable or trivially true.

## Remaining Blockers

### Reflexive MCS Case (NoMaxOrder line 210)

When p.mcs IS reflexive (CanonicalR p.mcs p.mcs holds), seriality futures q may also be reflexive and equivalent to p. The iteration p -> q -> q' -> ... may stay in the same equivalence class.

**Solution needed**: Well-founded iteration on candidate formula set. Each iteration either:
1. Finds a strict future (done), OR
2. Consumes a distinguishing formula, reducing the measure

### Strict Intermediate in Timeline (DenselyOrdered)

`density_frame_condition_strict` gives a strict intermediate W, but W might not be represented in `denseTimelineUnion`. Need to either:
1. Show W is in the timeline, OR
2. Show an equivalent point that IS in the timeline

## Files Modified

- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`
  - Added import for Subformulas and Finset.Card
  - Added `irreflexive_mcs_has_strict_future` lemma

- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
  - Expanded NoMaxOrder proof with case analysis
  - Proved unreachable case via Temporal 4 closure
  - Expanded NoMinOrder with similar structure
  - Set up DenselyOrdered proof framework

## Build Status

`lake build` passes with sorry warnings. No errors.

## Next Steps

1. **Implement well-founded iteration** using Finset.strongInductionOn:
   - Define `candidateFormulas (M M' : Set Formula) (anchor : Formula) : Finset Formula`
   - Prove measure decreases on each non-strict iteration
   - Complete `density_frame_condition_strict_wf`

2. **Integrate strict density with timeline**:
   - Show density_frame_condition_strict witness is equivalent to a timeline point
   - OR modify timeline construction to include strict intermediates

3. **Complete Phase 7 and 8** after Phase 6 is done
