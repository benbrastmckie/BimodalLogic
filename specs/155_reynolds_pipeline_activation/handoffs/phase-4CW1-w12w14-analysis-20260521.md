# Phase 4C-W1 Tasks W1.2 + W1.4 Analysis Handoff

**Session**: sess_1779383375_6c61c3
**Date**: 2026-05-21
**Status**: BLOCKED -- W1.2 and W1.4 are coupled; both require the d-consistency fix

## Summary

Attempted to close W1.4 (M-side degenerate sorries at lines 430, 447) by making `SplitPointProps.h_pt_xc`/`h_pt_cy` conditional on non-degeneracy. The approach FAILS because Case I genuinely reaches degenerate scenarios and uses the witnesses unconditionally.

W1.2 (d-consistency) was analyzed in depth. All simple approaches fail. The full GHR93 Claim 1 argument (infimum + formula C) is required.

## W1.4 Analysis: Why Conditional h_pt_xc/h_pt_cy Fails

### The Approach
Changed `SplitPointProps` fields from:
```lean
h_pt_xc : Exists (p : M.carrier), inClosedInterval x c (extendPoint p)
h_pt_cy : Exists (p : M.carrier), inClosedInterval c y (extendPoint p)
```
to conditional:
```lean
h_pt_xc : not(x = c and IsGap c) -> Exists ...
h_pt_cy : not(c = y and IsGap c) -> Exists ...
```

Also added `hcd_gp` and `hcd_boundary` as fields of `SplitPointProps` to enable downstream non-degeneracy proofs.

### Why It Fails (Case I)

Case I (`ghr93_case_I`, line 675) has:
- `h_split : Exists i, a_bwd i < d` (some selections strictly below d)
- Uses `props.h_pt_cy` at line 811 (left branch) and `props.h_pt_xc` at line 1248 (right branch)

The non-degeneracy condition `not(c = y and IsGap c)` is NOT derivable in Case I:
- If `c = y` and `IsGap c`, then `d = y'` (boundary correspondence), `IsGap d`.
- All `a_bwd i in [x', y']` gives `a_bwd i <= y' = d`.
- `hi_split : a_bwd i_split < d` gives `a_bwd i_split < d <= a_bwd i_split` ... but wait, `a_bwd i_split <= d` and `a_bwd i_split < d` are BOTH TRUE (not contradictory).
- So `c = y` and `IsGap c` is genuinely possible in Case I.

When Case I reaches `h_pt_cy` with `c = y` (gap), it needs a point in `[c, y] = {gap}` to play tau's Round 2. This is vacuously satisfiable (no challenges exist), but the CODE calls `hwin_R p_cy hp_cy` which requires a witness `p_cy`. No witness exists.

### Why Case II Works

Case II has `h_point : IsPoint (a_bwd n)`, so `IsPoint d` (since `d = a_bwd n`). By `hcd_gp`, `IsPoint c`. Therefore `not(IsGap c)`, making both non-degeneracy conditions trivially satisfied.

### The Coupling

W1.4 is blocked because:
1. The conditional approach fails for Case I
2. The unconditional approach fails because the goals are genuinely unprovable
3. The only fix is to ensure `c` never equals a boundary endpoint as a gap

This requires redefining `d` (Task W1.2). With the correct infimum-based `d`, the split point `c` should avoid boundary gaps, resolving both W1.2 and W1.4 simultaneously.

## W1.2 Analysis: Why Simple Approaches Fail

### Approach: Formula Agreement -> d-consistency (FAILS)

Idea: Two plays with `c` at boundary give responses d1, d2. Formula agreement gives `stavi_temporal_truth_mu N d1 A <-> stavi_temporal_truth_mu N d2 A` for all A. If rank_type is injective, d1 = d2.

**Problem**: rank_type is NOT injective on ExtendedCarrier. Two distinct actual points `p1 != p2` can have the same rank_type (they're in the same equivalence class). Two distinct gaps can have different cuts but the same defining formula. The ExtendedCarrier order is based on cuts, not rank types.

### Approach: Canonical Response via Classical.choice (REQUIRES CASE II REWRITE)

Idea: Play forward game once with `(c, c, ..., c)` at all positions. Define d as the response at position n. d-consistency for this specific play is `rfl`. For other plays...

**Problem**: Different paddings at positions 0..n-1 can give different responses at position n. The strategy is non-deterministic. So d-consistency requires showing ALL responses at position n are equal, which is exactly the Claim 1 argument.

### Approach: Inequality `d <= a_bwd(n)` (REQUIRES CASE II REWRITE)

Idea: Change `hd_eq_an` to `hd_le_an : d <= a_bwd(n)`. Case II uses `hd_eq_an` at ~28 sites.

**Problem**: Case II cannot derive `IsPoint d` from `IsPoint (a_bwd n)` without equality. `hd_le_an` gives `d <= a_bwd(n)`, but `d` could be a different element below `a_bwd(n)`. The ~28 rewrite sites in Case II (~700 lines of sorry-free code) would all need updating. HIGH RISK of breaking the sorry-free proof.

### Correct Approach: Full Claim 1 (GHR93 p.28)

The GHR93 paper proves d-consistency via Claim 1:

1. **Define formula C**: For the backward game's selections a_0,...,a_{n-1} in [x',y'], define a continuation formula C based on the "type" of the split. C(t) holds iff the portion of [x',y'] above t has the same qualitative structure as the portion above the boundary element.

2. **Define d as infimum**: `d = inf{t in [x',y'] : C holds on (t, y')}`. This exists because:
   - The set is nonempty (y' is in it, since C on (y', y') is vacuously true)
   - [x', y'] is bounded below by x'
   - The infimum exists in ExtendedCarrier (which has the completeness property for formula-definable sets)

3. **Prove d = a_bwd(n)**: The backward selection a_bwd(n) satisfies the infimum condition because:
   - C holds on (a_bwd(n), y') by the forward strategy's winning condition
   - No element below a_bwd(n) satisfies C (by Spoiler's ability to challenge between them)
   This gives d <= a_bwd(n) AND a_bwd(n) <= d, hence d = a_bwd(n).

4. **Prove d-consistency**: For any winning play with c at boundary:
   - The response t at boundary satisfies C on (t, y') (from the winning condition)
   - Therefore t >= d (since d is the infimum)
   - If t > d, Spoiler can find a point between d and t where C fails, contradicting the winning condition
   - Therefore t = d

**Effort estimate**: 150-250 lines of new infrastructure, 0 changes to Cases I or II.

**Key challenge**: Defining the "continuation formula C" in Lean. C is a formula of rank <= r that captures the qualitative structure. In ExtendedCarrier, elements are characterized by their rank_type (set of formulas they satisfy). C needs to encode "same rank_type as d at the boundary."

**Alternative challenge**: The infimum existence proof. ExtendedCarrier may not have conditional completeness in general. However, the infimum of a formula-definable set should exist because formula-definable sets have a specific structure (they are cut-defined).

## Files Analyzed (No Changes)

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- analyzed but reverted all changes
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- read-only analysis of strategy_restrict_left/right

## Sorry Count

Unchanged: 7 in ExpressivenessGeneral.lean, 4 in EFGames.lean (11 total on critical path).

## Recommended Next Steps

1. **Implement Claim 1 (Full GHR93 p.28)**: This is the highest-priority task. It unblocks W1.2 (d-consistency), W1.4 (M-side degenerate), and potentially simplifies the c-gap-case (line 551, Phase 4C-W3). Estimated 150-250 lines.

2. **If Claim 1 is too complex**: Consider the "canonical response + Case II rewrite" approach (Option A from earlier handoffs), accepting the ~300 lines of Case II changes. This is lower risk than it sounds because the changes are mechanical (`rw [<- hd_eq_an]` -> `rw [<- hd_le_an]; exact ...`).

3. **Do NOT attempt W1.4 independently**: It is provably blocked by W1.2. Any approach that avoids d-consistency still requires ensuring c never equals a boundary endpoint as a gap, which requires the same Claim 1 infrastructure.

## Key Technical Details for Next Agent

### ExtendedCarrier Order
- `Sum.inl x <= Sum.inr g` iff `x in g.val.cut` (point below gap)
- `Sum.inr g <= Sum.inl x` iff `x notin g.val.cut` (gap below point)
- `Sum.inl x <= Sum.inl y` iff `x <= y` (point order)
- `Sum.inr g1 <= Sum.inr g2` iff `g1.val.cut subset g2.val.cut` (gap order by cut inclusion)

### D-Consistency Statement
```lean
h_d_consistent_left : forall (a_pad : Fin (1 + 3 * n + 1) -> ExtendedCarrier M atomMap r),
    (forall i, inClosedInterval x y (a_pad i)) ->
    a_pad (1 + 3 * n) = c ->
    forall (a'_full : Fin (1 + 3 * n + 1) -> ExtendedCarrier N atomMap r),
      (forall i, inClosedInterval x' y' (a'_full i)) ->
      (forall (b' : N.carrier), inClosedInterval x' y' (extendPoint b') ->
        exists (b : M.carrier), inClosedInterval x y (extendPoint b) and
          ghr93_winning_condition (1 + 3 * n + 1)
            (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ->
      a'_full (1 + 3 * n) = d
```

### ghr93_strategy_restrict_left Signature
Uses d-consistency at exactly ONE point (line 2953 of EFGames.lean) to establish `a'_full(n) = d`, which is then used for response containment and Round 2 containment.

### SplitPointProps h_pt_xc/h_pt_cy Usage
5 downstream call sites, all in Cases I and II:
- Line 811 (Case I left): `props.h_pt_cy` -- FAILS when c=y gap
- Line 1248 (Case I right): `props.h_pt_xc` -- FAILS when x=c gap
- Line 1735 (Case II): `props.h_pt_cy` -- OK (d is point, so c is point)
- Line 1754 (Case II): `props.h_pt_xc` -- OK (same reason)
- Line 2106 (Case II right): `props.h_pt_xc` -- OK (same reason)
