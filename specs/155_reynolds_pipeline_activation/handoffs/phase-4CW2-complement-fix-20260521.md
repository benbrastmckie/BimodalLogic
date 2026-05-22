# Phase 4C-W2 Handoff: Complement-Point Truth Fix

**Session**: sess_1779418490_015a53
**Date**: 2026-05-21
**Phase**: 4C-W2 (stavi_untl_gap_detection X^mu(gamma) blocker resolution)

## What Was Done

1. **Identified the fundamental blocker**: `stavi_untl_gap_detection` promised `X^mu(gamma)` for arbitrary X, but atoms evaluate to False at gaps. The theorem as originally stated was mathematically unprovable for X containing atoms.

2. **Changed theorem signature**: Replaced the last conjunct `stavi_temporal_truth_mu M atomMap r (Sum.inr gamma) X` with a bounded complement-point truth formulation:
   ```lean
   (exists s_bound, s_bound not-in cut /\ forall u not-in cut, u < s_bound -> X(u))
   ```

3. **Closed stavi_untl_gap_detection (SORRY-FREE)**:
   - Forward direction: proved X at complement points from FO table right disjunct
   - Backward direction: proved FO table conditions from complement-point truth of X

4. **Updated all callers in left_formula_gap_detection**:
   - neg forward: discards complement-point truth (trivial update)
   - neg backward: provides trivial complement-point truth of `top`
   - stavi_untl forward: CLOSED -- constructs `stavi_untl(A,B)^mu(gamma)` from complement-point truth by using inner FO table at a complement point and extending quantifiers backward to the gap using B at complement points
   - std_untl forward: CLOSED -- simpler construction for standard Until
   - Both backward cases: still sorry'd

5. **Updated std_untl_gap_detection signature** (body still sorry'd -- mirror of stavi_untl)

## Key Technical Insight

The `<` relation on `ExtendedCarrier`: `Sum.inr gamma < extendPoint x` iff `x not-in gamma.val.cut`. And `extendPoint x < Sum.inr gamma` iff `x in gamma.val.cut`. This makes the conversion between cut membership and ordering on ExtendedCarrier straightforward (use `exact <hs_not, hs_not>` for `<` goals).

## Immediate Next Actions

1. **Backward directions of stavi_untl and std_untl cases** (lines 3032, 3083):
   - Need: from `stavi_untl(A,B)^mu(gamma)`, provide complement-point truth of `conj B (stavi_untl A B)` to feed to `stavi_untl_gap_detection.mpr`
   - Strategy: From the FO table of stavi_untl(A,B) at the gap, extract B at complement points (condition 3 gives B initially, extend via body) and stavi_untl(A,B) at complement points (restrict the FO table from gamma to each complement point)
   - Difficulty: Medium -- need to show stavi_untl(A,B)(u) for complement point u from stavi_untl(A,B)^mu(gamma)

2. **std_untl_gap_detection body** (line 2682):
   - Mirror proof of stavi_untl_gap_detection for standard Until
   - Simpler structure (no 3-condition FO table, just exists s, A(s) and B-between)

3. **stavi_snce and std_snce cases**: Dual of the untl cases (past direction)

## Current Sorry Map (EFGames.lean)

| Line | Context | Status |
|------|---------|--------|
| 2682 | std_untl_gap_detection | Sorry'd (signature updated, needs mirror proof) |
| 2759 | base.imp sub-case | Sorry'd (complex but mechanical) |
| 2763 | base.untl sub-case | Sorry'd |
| 2767 | base.snce sub-case | Sorry'd |
| 3032 | stavi_untl backward | Sorry'd (needs complement-point extraction from gap truth) |
| 3036 | stavi_snce case | Sorry'd |
| 3083 | std_untl backward | Sorry'd (same pattern as stavi_untl backward) |
| 3087 | std_snce case | Sorry'd |
| 3109 | stavi_snce_gap_detection | Sorry'd |
| 3124 | std_snce_gap_detection | Sorry'd |
| 3137 | right_formula_gap_detection | Sorry'd |
| 4198 | ghr93_decomposition_implies_game | Sorry'd (W4) |
| 5500 | stavi_expressive_completeness | Sorry'd (W4) |

## Build Status

`lake build` passes with 0 errors.
