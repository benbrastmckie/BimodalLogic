# Phase 2 Handoff: right_gap_class infrastructure added

**Session**: sess_1780157486_orch202r4
**Timestamp**: 2026-05-30T16:48:56Z
**Phase**: 2 (Reynolds Model Surgery Core)
**Status**: IN PROGRESS

## What Was Done

Added sorry-free infrastructure for the Reynolds model surgery argument in
`GoodStructuresModelSurgery.lean`:

1. **`right_gap_class_prop`** (def, sorry-free): Predicate encoding "t's contemp_equiv
   class is bounded above and succ-closed (boundary is a gap, not a successor pair)."

2. **`right_gap_class_invariant`** (theorem, sorry-free): If `t ~M s` and
   `right_gap_class(t)`, then `right_gap_class(s)`. Proof uses convexity of classes
   and transitivity of contemp_equiv.

3. **`right_gap_class_succ`** (theorem, sorry-free): If `right_gap_class(t)`, then
   `right_gap_class(succ(t))`. Follows from invariance + no_boundary_at_successor.

4. **`right_gap_class_pred`** (theorem, sorry-free): If `right_gap_class(t)`, then
   `right_gap_class(pred(t))`. Follows from invariance + contemp_equiv_pred_closed.

5. Cleaned up documentation and section structure.

## Sorry Count

Still exactly 2 sorry sites (unchanged from before):
- `gap_prior_UZ_contradiction` (line 702)
- `gap_prior_SZ_contradiction` (line 728)

## What Remains

The sorry sites require the full Reynolds model surgery argument (Lemmas 6-13,
~300-600 lines). The mathematical content:

1. Construct MonadicFormula sig 1 for right_gap_class (Reynolds Lemma 6)
2. Apply US_expressively_complete_over_prior to get temporal formula R
3. Construct model surgery domain (remove bad interval, keep one class)
4. Prove temporal truth preservation across surgery (26 subcases for U/S)
5. Derive contradiction (R holds at surgery point in original but not in surgery model)

## Key Insight from Analysis

The right_gap_class_definable approach (temporal formula detecting gap class) is
NECESSARY but NOT SUFFICIENT. Having R such that temporal_truth t R <-> right_gap_class(t)
establishes via prior_UZ_first_transition that R never transitions at successor pairs
(since right_gap_class is class-invariant). This proves R is constant (holds everywhere
or nowhere). But constant R does NOT give a contradiction -- all classes might genuinely
end at gaps. The actual contradiction requires model surgery: constructing a modified
structure where a gap boundary becomes a successor-pair boundary, showing temporal truth
is preserved, and deriving that R should be false at the modified boundary while being
true in the original.

## Immediate Next Action

To close the sorry: implement Reynolds Lemmas 6-13 model surgery construction and
temporal truth preservation. This is ~300-600 lines of Lean code. The infrastructure
(right_gap_class_prop, invariance) is ready to use.

## Build Status

`lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` passes.
