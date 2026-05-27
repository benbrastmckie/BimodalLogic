# Phase 5 S11: Gap Detection Assembly Progress

## Status: PARTIAL (2 sorry sub-goals from 1 original sorry)

## Summary

Decomposed the single sorry in `ghr93_cases_III_IV` (CaseAnalysis.lean) into a
structured proof with well-typed sorry sub-goals. The original monolithic sorry
has been replaced with:

1. **Response construction** (PROVED): `a'_resp` defined with `resp_tau(k)` for
   k < n and `Sum.inr gamma_M` for k = n.
2. **Interval membership** (PROVED): All responses in `[x, y]`.
3. **Gap/point agreement** (PROVED): S11.2 — trivially both are gaps.
4. **Gap matching** (SORRY): S11.1 — find gamma_M with formula agreement.
5. **Winning condition assembly** (SORRY): S11.3 — point challenge + order/gp/formula.

## What Was Done

### Structural Decomposition

The single sorry at line ~3042 has been replaced with a structured proof that:

1. Extracts the defining formula D from gamma_N's r-definability
2. Sorry's the gap matching (S11.1): finding gamma_M in M with:
   - `inClosedInterval x y (Sum.inr gamma_M)`
   - `forall A, stavi_depth A <= r -> (A^mu(gamma_M) <-> A^mu(gamma_N))`
3. Proves gap/point agreement (S11.2): both Sum.inr are gaps, so IsPoint <-> IsPoint
   and IsGap <-> IsGap are trivially true
4. Constructs `a'_resp`:
   - `a'_resp(k) = resp_tau(k)` for k < n
   - `a'_resp(n) = Sum.inr gamma_M`
5. Proves all responses in `[x, y]`:
   - For k < n: resp_tau in [c, y] subset [x, y] via props.hxc
   - For k = n: from gamma_M's interval membership
6. Sorry's the point challenge + winning condition (S11.3): finding b_resp and
   verifying ghr93_winning_condition (n+1)

### Simp Warning Fix

Fixed unused `extendPoint` argument in rank_embed_comp and rank_embed_comp_N
simp calls (pre-existing warnings from the rank mismatch fix).

## Sorry Goals (Exact Types)

### S11.1 (line ~3063): Gap Matching

```
exists gamma_M : RDefinableGap M atomMap r,
  inClosedInterval x y (Sum.inr gamma_M) /\
  forall A : StaviFormula, stavi_depth A <= r ->
    (stavi_temporal_truth_mu M atomMap r (Sum.inr gamma_M) A <->
     stavi_temporal_truth_mu N atomMap r (Sum.inr gamma_N) A)
```

**Available in context**: D (defining formula), hD_depth (stavi_depth D <= r),
hD_def (gap_definable_on_left or right), h_fwd_r3 (rank r+4 forward game),
h_fwd_r1 (rank r+2 forward game), h_r1_univ (rank-universal forward games).

**Proof strategy** (documented in comments):
1. S11.1a: Get reference point m_N in gamma_N.cut and [d, y']
2. S11.1b: 1-round game from h_fwd_r3, challenge with m_N to get m_M
3. S11.1c: Gap detection transfer chain:
   - backward: A^mu(gamma_N) -> left_formula(A,D)(m_N) via left_formula_gap_detection
   - transfer: left_formula(A,D)(m_N) <-> left_formula(A,D)(m_M) via
     rank_embed_stavi_truth_mu + forward game (depth left_formula A D <= r+4)
   - forward: left_formula(A,D)(m_M) -> exists gamma_M, A^mu(gamma_M)
4. S11.1d: gap_detection_unique shows gamma_M independent of A
5. S11.1e: Interval from forward game bounds

**Key lemmas needed**:
- `left_formula_gap_detection` / `right_formula_gap_detection` (proved in GapDetection.lean)
- `stavi_depth_left_formula` / `stavi_depth_right_formula` (proved, bound: r+4)
- `rank_embed_stavi_truth_mu` (proved in TypeFormulas.lean)
- `gap_detection_unique` (proved in GapDetection.lean)
- `ghr93_duplicator_wins_round_mono` (proved in CustomGame.lean)

**Reference point subtlety**: Need m_N in gamma_N.cut AND in [x', y']. When
d is a point, use d directly (since d <= Sum.inr gamma_N implies d's point is
in gamma_N.cut, and d in [x', y']). When d is a gap, need care — may need
a cut member above d (exists since gamma_N.cut has no supremum).

### S11.3 (line ~3117): Point Challenge + Winning Condition

```
exists b_resp : N.carrier,
  inClosedInterval x' y' (extendPoint b_resp) /\
  ghr93_winning_condition (n+1)
    (game_tuple x' y' a_bwd b_resp)
    (game_tuple x y a'_resp b_sp)
```

**Available in context**: gamma_M, hgamma_M_in, hgamma_M_form, hgamma_gp,
a'_resp, ha'_resp_in, b_sp, hb_sp_in, plus all tau/forward game infrastructure.

**Proof strategy** (documented in comments):
Mirrors Case II assembly (~200 lines). Key steps:
1. Use d-compatible forward game (h_d_compat_left) with padded selections
   to get b_resp and cross-boundary orderings
2. Assemble same_order_type: 
   - tau positions from hwin_tau
   - gap position from gamma_M interval membership + d-compat orderings
   - endpoint positions from props
3. Assemble gap_point_agreement:
   - tau positions from hwin_tau
   - gap position from S11.2 (hgamma_gp)
   - b_sp/b_resp are always points
4. Assemble formula_agreement:
   - tau positions from hwin_tau
   - gap position from S11.1 (hgamma_M_form)
   - b_sp/b_resp from d-compat forward game
   - endpoints from props

**Estimated effort**: ~200 lines (mechanical, following Case II pattern)

## Verification

- `lake build` passes (1667 jobs)
- Theorem6.lean: still sorry-free
- CaseAnalysis.lean: 3 sorries total (1 pre-existing Phase 3, 2 new S11)
- No regressions

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`
  - Lines 3032-3117: Decomposed sorry into structured proof with 2 sub-goals

## Next Actions

1. **S11.1 (gap matching)**: Implement the gap detection transfer chain.
   This is the mathematically core part of Cases III/IV. Requires careful
   handling of the reference point (d being a point vs gap) and the
   left/right case split on D-definability.

2. **S11.3 (winning condition)**: Implement the point challenge + 3-part
   winning condition assembly. This is mechanical (follows Case II pattern)
   but lengthy (~200 lines).

Either sorry can be attacked independently.
