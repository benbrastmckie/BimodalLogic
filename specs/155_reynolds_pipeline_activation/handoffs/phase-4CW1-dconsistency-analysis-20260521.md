# Phase 4C-W1: D-Consistency Deep Analysis and Implementation Roadmap

**Session**: sess_1779383375_6c61c3
**Date**: 2026-05-21
**Status**: BLOCKED -- all 4 sorries (306, 316, 430, 447) are coupled; resolution requires substantial new infrastructure

## Summary

Conducted an exhaustive analysis of the 4 coupled sorries in `obtain_split_point_props` (ExpressivenessGeneral.lean). The key finding is that **d-consistency (lines 306, 316) is NOT provable from the current code's hypotheses alone** and genuinely requires the GHR93 Claim 1 infrastructure (infimum-based argument with formula C). The M-side degenerate sorries (lines 430, 447) require making `SplitPointProps.h_pt_xc`/`h_pt_cy` conditional and updating Case I, which is a ~50-100 line change to sorry-free code.

## D-Consistency Analysis (Lines 306, 316)

### What the Statement Says

```lean
h_d_consistent_left : forall (a_pad : Fin (1+3*n+1) -> ExtendedCarrier M atomMap r),
    (forall i, inClosedInterval x y (a_pad i)) ->
    a_pad (1+3*n) = c ->
    forall (a'_full : Fin (1+3*n+1) -> ExtendedCarrier N atomMap r),
      (forall i, inClosedInterval x' y' (a'_full i)) ->
      (forall (b' : N.carrier), inClosedInterval x' y' (extendPoint b') ->
        exists (b : M.carrier), inClosedInterval x y (extendPoint b) /\
          ghr93_winning_condition (1+3*n+1)
            (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ->
      a'_full (1+3*n) = d
```

For ANY a_pad with a_pad(n) = c, and ANY a'_full satisfying the winning condition for ALL point challenges b', the response at position n must equal d (= a_bwd(n)).

### Why Simple Approaches Fail

**Approach 1: Formula Agreement alone** -- From winning condition + hcd_form, we get: truth at a'_full(n) matches truth at d for all rank-r formulas. But two DISTINCT ExtendedCarrier elements can satisfy the same rank-r formulas (two distinct points can be rank-r equivalent; two distinct gaps can have different cuts but same formula truth values).

**Approach 2: same_order_type with point challenges** -- From same_order_type at each b' challenge: `c < extendPoint b_response <-> a'_full(n) < extendPoint b'`. This relates a'_full(n)'s position to b' via a DIFFERENT M-side element b_response. Since b_response varies with b', we can't directly compare a'_full(n) to d using this.

**Approach 3: eq_of_forall_le_iff** -- To use Mathlib's `eq_of_forall_le_iff` (if forall c, c <= t <-> c <= d then t = d), we'd need: for ALL ExtendedCarrier elements e, e <= a'_full(n) <-> e <= d. Point challenges only give comparisons with `extendPoint p` (carrier points), not with gaps. For actual points, the comparison IS determined by point challenges. For gaps, the comparison depends on cut inclusion, which is NOT directly determined by point challenges. Moreover, even for points, the same_order_type only gives comparisons MEDIATED through the M-side response, not direct comparisons to d.

**Approach 4: Uniqueness of response** -- Showing that any two a'_full satisfying the winning condition must agree at position n. This requires comparing two plays, but the winning condition is per-play (existential over b response, universal over b' challenge). Cross-play comparison is not available.

### Why GHR93 Claim 1 Is Needed

The GHR93 proof works because it:
1. Defines c as the INFIMUM of a formula-definable set S_C = {t in [x,y] : C holds on (t,y)}
2. Defines c' = inf{t in [x',y'] : C holds on (t,y')} (the N-side analog)
3. Uses the formula C' = not-C or K^-(not-C) (rank r+1)
4. Shows C'(c) by the infimum property
5. Transfers C'(c) to C'(d) by formula agreement (rank r+1 <= r')
6. Derives d <= c' from C'(d)
7. Derives c' <= d by contradiction: if d < c', Spoiler finds d' in (d,c') with not-C(d'), and Duplicator can't respond (C holds on (c,y) by infimum)
8. Concludes d = c'

The contradiction at step 7 is the essential ingredient that cannot be replicated without the formula C and infimum infrastructure.

### Implementation Requirements for Claim 1

To implement Claim 1 in Lean, the following infrastructure is needed:

1. **Formula C predicate** (~10 lines): Define C_holds(t) as a Prop capturing "all rank-r formulas true on (a_n, y') in N are true at t". Use Option A from report 18_alternative-strategies.md (Prop-level, no StaviFormula enumeration).

2. **Infimum construction in ExtendedCarrier** (~80-120 lines): Show that S_C = {t in [x,y] : C_holds on (t,y)} has an infimum in ExtendedCarrier. This requires showing that the infimum is either an actual point (in M.carrier) or a formula-definable gap (in RDefinableGap). The gap case requires constructing a DedekindGap from the cut {p : p is below the infimum} and showing it's r-definable.

3. **Infimum property** (~30 lines): C'(c) holds at the infimum c. This is a case split: either C fails at c (then not-C holds), or C holds at c but not-C is cofinal below c (by the infimum property).

4. **Formula transfer** (~20 lines): C' has rank r+1, and the forward strategy has depth r' = r + 4(n+1) >= r+1. So formula agreement gives C'(c) <-> C'(d), hence C'(d).

5. **d <= c'** (~30 lines): From C'(d): case split on not-C(d) vs K^-(not-C)(d). In both cases, d <= c'.

6. **c' <= d** (~50-80 lines): Contradiction argument. If d < c', find d' in (d,c') with not-C(d'). Challenge with d'. Duplicator responds with b in (c,y) where C holds. But formula agreement gives C(b) <-> C(d'), contradicting not-C(d'). This step requires careful handling of the game structure and the infimum's properties.

7. **Integration** (~20 lines): Prove claim1_d_consistency as a standalone theorem and apply at lines 306, 316.

**Total estimate**: 240-370 lines of new infrastructure, 0 changes to Cases I/II.

### Critical Challenge: Infimum Existence

The hardest part is step 2. ExtendedCarrier does NOT have a ConditionallyCompleteLattice instance. The infimum must be constructed manually:

- If S_C has a minimum (some t in S_C with t <= all elements of S_C): the infimum is t.
- If S_C has no minimum but its infimum among carrier points is itself a carrier point: the infimum is that point.
- If the infimum among carrier points defines a gap (a Dedekind cut with no supremum): need to show this gap is r-definable. The gap is right-definable by C (since C holds at all points above the gap in M.carrier). The r-definability follows from C being a rank-r formula.

The last case requires connecting the Prop-level C to the formal r-definability notion (gap_definable_on_right in EFGames.lean). This is where the Prop-level encoding DIVERGES from the StaviFormula encoding: the Prop-level C captures "all rank-r formulas true on (a_n, y')", but gap_definable_on_right requires a SPECIFIC StaviFormula D. So we'd need to either:
(a) Show that the Prop-level C corresponds to some StaviFormula (requires formula enumeration or finiteness), or
(b) Use a different infimum construction that doesn't go through gap_definable_on_right, or
(c) Define C as a StaviFormula directly (requires the formula enumeration infrastructure that doesn't exist).

This is the deepest blocker in the Claim 1 implementation.

### Fallback: Restructure d's Definition

Instead of proving d-consistency for the current d (= a_bwd(n)), redefine d as the infimum c' directly:

1. Define d_new = inf{t in [x',y'] : C_holds on (t,y')} (the infimum in N)
2. Prove d_new is in [x', y'] and has the right formula/gap properties
3. Prove d_new = a_bwd(n) (this IS the content of Claim 1, just applied to N instead of M)
4. Use d_new as the split point

This approach has the same complexity as Claim 1 but changes the construction flow. It would require updating SplitPointProps.hd_eq_an to hold for d_new instead of a direct definition.

## M-Side Degenerate Analysis (Lines 430, 447)

### What the Goals Assert

- Line 430: `exists p, inClosedInterval x c (extendPoint p)` when x = c and IsGap c
- Line 447: `exists p, inClosedInterval c y (extendPoint p)` when c = y and IsGap c

Both are **genuinely unprovable** -- no carrier point exists in a degenerate gap interval [gap, gap].

### Fix: Conditional h_pt_xc/h_pt_cy

Change SplitPointProps fields:
```lean
h_pt_xc : x /= c \/ IsPoint c -> exists p, inClosedInterval x c (extendPoint p)
h_pt_cy : c /= y \/ IsPoint c -> exists p, inClosedInterval c y (extendPoint p)
```

The construction in obtain_split_point_props closes the sorry branches: when x = c and IsGap c, the condition `x /= c \/ IsPoint c` is False (both disjuncts fail), so the function is trivially total.

### Downstream Impact (5 call sites)

| Line | Case | Field | Fix difficulty |
|------|------|-------|---------------|
| 814 | Case I left | h_pt_cy | HIGH -- 50-100 lines, restructure R-side data extraction |
| 1248 | Case I right | h_pt_xc | HIGH -- symmetric to line 814 |
| 1735 | Case II | h_pt_cy | TRIVIAL -- d is a point, so c is a point, condition holds |
| 1754 | Case II | h_pt_xc | TRIVIAL -- same reason |
| 2106 | Case II right | h_pt_xc | TRIVIAL -- same reason |

### Case I Fix Strategy (lines 814, 1248)

When `h_pt_cy` can't be instantiated (c = y, IsGap c):
- The tau game is degenerate: [c,y] = [c,c] with a gap
- All R-selections (a_bwd j >= d) satisfy a_bwd j = d (since d = y' and a_bwd j <= y')
- resp_R k = c (forced by degenerate interval [c,c])
- R-side gap_point data: from hcd_gp (IsPoint c <-> IsPoint d, etc.)
- R-side formula data: from hcd_form (truth at c <-> truth at d)
- R-side ordering: trivial (all R-values equal d/c)
- Boundary data (hgp_y, hform_y): from hcd_gp + boundary correspondence

This requires adding `hcd_form` and `hcd_gp` as fields of SplitPointProps (or passing them separately) and restructuring ~50-100 lines of Case I to handle the degenerate branch.

### Coupling Between W1.2 and W1.4

The M-side degenerate fix (W1.4) is **technically independent** of d-consistency (W1.2) -- it can be implemented without Claim 1. However:
1. The fix requires modifying Case I (~50-100 lines of sorry-free code)
2. Case II modifications are trivial (d is a point -> c is a point -> condition holds)
3. The user's directive "avoid modifying Cases I/II" creates tension

If the user approves Case I modifications, W1.4 can be done independently in ~3-4 hours.

## Recommended Next Steps

### Option A: Full Claim 1 Implementation (15-25 hours)
1. Implement formula C as a Prop-level predicate
2. Construct infimum in ExtendedCarrier (hardest step -- requires r-definability proof)
3. Prove Claim 1 steps 1-8
4. Close d-consistency sorries (lines 306, 316)
5. Fix degenerate sorries (lines 430, 447) with conditional h_pt_xc/h_pt_cy
6. Update Case I for degenerate branches

### Option B: Restructure d's Definition (10-15 hours)
1. Define d as the strategy response (from h_mono_left with specific a_pad)
2. D-consistency for the defining play is rfl
3. Prove d = a_bwd(n) via Claim 1 (still needed, but the proof direction is clearer)
4. Same downstream changes as Option A

### Option C: Weaken strategy_restrict (8-12 hours)
1. Modify `ghr93_strategy_restrict_left/right` to not need d-consistency
2. Instead, have strategy_restrict OUTPUT the split point d' = a'_full(n)
3. Move the d' = a_bwd(n) proof to SplitPointProps.hd_eq_an
4. This changes 2 sorry-free theorems in EFGames.lean (~200 lines each)
5. Still requires Claim 1 for hd_eq_an, but the proof context is different

### Option D: Fix W1.4 Only (3-4 hours, leaves d-consistency blocked)
1. Make h_pt_xc/h_pt_cy conditional
2. Update Case I with degenerate branch handling
3. Update Case II trivially
4. Leave d-consistency sorries (lines 306, 316) for a future session with Claim 1

**Recommended**: Option D first (quick win, reduces sorry count by 2), then Option A in a dedicated session.

## Technical Details for Next Agent

### ExtendedCarrier Order (for reference)
- `Sum.inl x <= Sum.inl y` iff `x <= y` (carrier order)
- `Sum.inl x <= Sum.inr g` iff `x in g.val.cut` (point below gap)
- `Sum.inr g <= Sum.inl x` iff `x not-in g.val.cut` (gap below point)
- `Sum.inr g1 <= Sum.inr g2` iff `g1.val.cut subset g2.val.cut` (gap order by cut)

### Key Definitions
- `ExtendedCarrier M atomMap r = M.carrier + RDefinableGap M atomMap r` (EFGames.lean:356)
- `RDefinableGap = { g : Gap M.carrier // r_definable_gap M atomMap g r }` (EFGames.lean:342)
- `r_definable_gap` requires a StaviFormula D with depth <= r that is `gap_definable_on_left` or `gap_definable_on_right` (EFGames.lean:334)
- `gap_ext` proves Gap equality from cut equality (EFGames.lean:275)
- `point_between_strict_gaps` gives a point between two strict gaps (EFGames.lean:2478)

### What eq_of_forall_le_iff Would Need
To prove a'_full(n) = d using Mathlib's `eq_of_forall_le_iff`:
- Need: forall e : ExtendedCarrier N atomMap r, e <= a'_full(n) <-> e <= d
- For e = extendPoint p: provable from same_order_type IF we can relate M-side and N-side positions
- For e = Sum.inr g: requires knowing g.val.cut inclusion properties
- Current winning condition does NOT give direct comparison between a'_full(n) and arbitrary ExtendedCarrier elements -- only comparisons mediated through M-side responses to specific point challenges

### Sorry Inventory (unchanged at 11)
ExpressivenessGeneral.lean (7): lines 306, 316, 430, 447, 551, 2455, 2676
EFGames.lean (4): lines 2415, 2434, 3504, 3576
