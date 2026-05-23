# Claim 1 Interior Cases Handoff

**Session**: sess_1779494931_55482d
**Date**: 2026-05-23
**Status**: 1 sorry closed (Direction 2 x=c_inf gap), 2 sorries remain

## What Was Done

### Direction 2 x=c_inf Gap Case (sorry at old line 2697) -- CLOSED

When c_inf = x (left boundary) and r2_resp is a gap with r2_resp < rank_embed(d):
- r2_resp = rank_embed(x') (from order agreement hord_01 + hx_eq_c)
- rank_embed(x') < rank_embed(d) gives x' < d
- h_cofinal_failure_below_d(x', ...) gives mu-point u with x' < u < y', not cont_holds
- Since rank_embed(x') = r2_resp < rank_embed(u) (because x' < u), h_cont_transfer
  gives cont_holds at u. Contradiction.

The key insight: when r2_resp = rank_embed(x'), ANY carrier point above x' has
rank_embed strictly above r2_resp, so h_cont_transfer always applies.

### Analysis of Remaining Sorries

Two sorries remain (formerly lines 2577 and 2699, now at approximately 2577 and 2732):

**Sorry 2577 (Direction 1 interior)**: rank_embed(d) < r2_resp, x < c_inf.
**Sorry 2732 (Direction 2 interior gap)**: r2_resp < rank_embed(d), x < c_inf, r2_resp is gap.

Both sorries share the same fundamental blocker: when r2_resp is strictly between
rank_embed(x') and rank_embed(d) (not equal to either endpoint), there may be NO
carrier point between r2_resp and the other bound at rank r+2. The h_cont_transfer
argument only works when a failure point's rank_embed is above r2_resp.

## What Remains: The Gap Position Edge Case

### The Precise Blocker

At rank r+2, carrier points are `extendPoint q = rank_embed(extendPoint q at rank r)`.
Gaps at rank r+2 include both `rank_embed(rank-r gaps)` and new r+2-definable gaps.
The element r2_resp (Duplicator's response) can be a gap at rank r+2 that sits
between carrier points rank_embed(q_prev) and rank_embed(q_next) where
q_prev < d < q_next (or q_prev < d and d is a gap).

In this configuration:
- All carrier points u from h_cofinal_failure have rank_embed(u) on one side of r2_resp
- h_cont_transfer cannot be applied because r2_resp is NOT below any of these u's

### Three Resolution Paths (in order of increasing complexity)

#### Path 1: Gap Equivalence Lemma (~50-80 lines)

**Key claim**: If a, b in ExtendedCarrier at rank r satisfy:
1. a < b
2. No mu-point (carrier point) exists strictly between a and b
3. They have the same IsPoint/IsGap status

Then for all StaviFormula A with stavi_depth A <= r:
`stavi_temporal_truth_mu M atomMap r a A <-> stavi_temporal_truth_mu M atomMap r b A`

**Why it works**: If r2_resp and rank_embed(d) have no carrier point between them
at rank r+2, and they have the same gap/point status (both gaps), then they agree
on all depth <= r+2 formulas. Combined with formula agreement at index 1 (c_inf vs
r2_resp), this gives formula agreement between c_inf and d, which is exactly what
the suffices needs.

**Proof approach**: Structural induction on StaviFormula. The key cases:
- base: atoms at gaps are FALSE (both a and b give FALSE)
- neg, conj: immediate from IH
- std_untl/std_snce: the temporal quantifiers range over mu-points. With no mu-points
  between a and b, any witness/universal statement about (a, ...) is equivalent to
  one about (b, ...) -- the mu-points above a and above b are the same.
- stavi_untl/stavi_snce: similar but more complex due to the GHR93 FO table structure.

**Risk**: The stavi_untl/stavi_snce cases involve existential/universal quantifiers
over non-mu-points (the bound s in "exists s > t"), which makes the induction
non-trivial. The bound s could be between a and b even though no mu-point is.

#### Path 2: Direct Pigeonhole Application (~100-150 lines)

Adapt `pigeonhole_definable_formula_cross` preconditions to work with the available
hypotheses. Key steps:
1. Convert h_cofinal_failure_below_c_inf to inf_carrier_cut format
2. Handle the edge case where c_inf is a carrier point (may have cont_holds_cross)
3. Extract D from pigeonhole
4. Build K = neg(std_snce(neg(base(bot)), D)) with depth r+2
5. Show K(c_inf) = TRUE via cofinal failure of D below c_inf
6. Transfer K via formula agreement to r2_resp
7. Show K(r2_resp) = FALSE via Since witness (needs gap equivalence or carrier point)

**Risk**: Step 7 still requires resolving the gap position issue, so this path
alone may not suffice without Path 1.

#### Path 3: Formula Materialization (GHR93 Definition 8.8) (~150-200 lines)

Build `interval_type_formula : ExtendedCarrier -> ExtendedCarrier -> StaviFormula`
following GHR93 exactly:
1. For each NormalForm type realized in (a_n, y'), build a characteristic formula
2. Take the disjunction (encoded via De Morgan: neg(conj(neg A, neg B)))
3. Prove correctness theorem

**Risk**: Requires building NormalForm-to-StaviFormula characteristic formulas,
which is substantial infrastructure not currently in the codebase.

## Recommended Next Step

**Path 1 (Gap Equivalence)** is the most promising because:
- It directly resolves the blocker for BOTH remaining sorries
- It has clear mathematical content (adjacent non-mu elements are indistinguishable)
- It doesn't require formula materialization infrastructure
- The proof is a structural induction with known-pattern cases

The main technical challenge is the stavi_untl/stavi_snce induction cases, which
involve non-mu-point bounds. These require showing that the bound can be adjusted
from one side of the gap to the other without changing truth.

## File State

- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
- Net sorry change: -1 (from 11 to 10)
- Sorries closed: Direction 2 gap case (x=c_inf subcase)
- Sorries remaining: 2577 (Direction 1 interior), ~2732 (Direction 2 interior gap)
- Build: Passes
