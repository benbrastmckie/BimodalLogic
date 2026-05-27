# Phase 5 S11 Interval Bound: Proof Strategy Handoff

## Status: ACTIONABLE (proof strategy fully determined)

## Session
Session: sess_1779860853_aa14bdbdcf56

## Problem

Two sorry sites in `ghr93_cases_III_IV` (CaseAnalysis.lean):
1. **Sorry #1 (line ~3328)**: Need `Sum.inr gamma_M <= y` in the LEFT case
2. **Sorry #2 (line ~3639)**: Need `x <= Sum.inr gamma_M` in the RIGHT case (symmetric)

Both arise because `left_formula_gap_detection` / `right_formula_gap_detection` find D-definable gaps GLOBALLY, but we need the detected gap within the interval [x, y].

## Proven Correct Strategy: Sub-Interval Forward Game + D-Contradiction

### Key Insight
Use `h_r1_univ` to play a forward game on the sub-interval `[m_M, y]` vs `[m_N, y']` (for sorry #1) or `[x, m_M]` vs `[x', m_N]` (for sorry #2). The endpoints of the sub-interval are `m_M` and `m_N`, so **order agreement between position 0 (= m_M/m_N endpoints) and position 2 (= p_M/p_N responses)** gives `m_M < p_M` from `m_N < p_N`. This is the critical step that a global forward game cannot provide.

### Sorry #1 Proof (LEFT case: `Sum.inr gamma_M <= y`)

**Proof by contradiction**: Assume `y < Sum.inr gamma_M`.

**Case A: `y' = Sum.inr gamma_N` (degenerate)**
1. Gap/point agreement at y vs y' (position 3 of the 1-round game `_hgp_1`) gives y is a gap `g_y`.
2. Formula agreement at y vs y' (hform_1 at position 3) transfers `gap_char_formula D` (depth <= r+2 <= r+4), so `g_y` is D-definable.
3. Transfer the left disjunct of `gap_char_formula` specifically: `std_snce(sf_verum, D) /\ ~std_untl(sf_verum, D)` holds at `gamma_N` (since gamma_N is D-def-left), so it holds at `g_y` too. By `gap_char_formula_implies_definable` with specific disjunct, `g_y` is D-def-left.
4. `m_M in g_y.cut` (since `extendPoint m_M <= y = Sum.inr g_y`).
5. `m_M in gamma_M.cut` (since `extendPoint m_M < Sum.inr gamma_M`).
6. D-between from `m_M` for `g_y`: use `h_D_bet_gamma_M` since `g_y.cut subset gamma_M.cut` (from `Sum.inr g_y <= Sum.inr gamma_M`), so any u in `g_y.cut` with `u > m_M` is also in `gamma_M.cut` and has D by `h_D_bet_gamma_M`.
7. `gap_detection_unique` gives `g_y.val = gamma_M.val`.
8. Then `y = Sum.inr g_y = Sum.inr gamma_M`, contradicting `y < Sum.inr gamma_M`.

**Case B: `Sum.inr gamma_N < y'` (non-degenerate)**
1. Find complement element `t0` of `gamma_N` with `extendPoint t0 <= y'`:
   - If y' is carrier point p_y': use p_y' (since `Sum.inr gamma_N < extendPoint p_y'` gives `p_y' not in gamma_N.cut`).
   - If y' is gap g_y': find `m0 in g_y'.cut \ gamma_N.cut` (exists since `gamma_N.cut` is proper subset of `g_y'.cut`).
2. From `_h_no_init` (pushed neg): `forall t not in gamma_N.cut, exists u not in gamma_N.cut, u <= t /\ ~D(u)`. Apply to `t0` to get `p_N` with `p_N not in gamma_N.cut`, `p_N <= t0`, `~D(p_N)`.
3. `p_N in [x', y']`: `extendPoint p_N > Sum.inr gamma_N >= x'` and `extendPoint p_N <= extendPoint t0 <= y'`.
4. `m_N < p_N`: Since `m_N in gamma_N.cut`, `p_N not in gamma_N.cut`, and carrier is linearly ordered, `p_N <= m_N` would give `p_N in cut` by downward closure. Contradiction.
5. **Sub-interval forward game** via `h_r1_univ` at `r' = r+2`:
   - Intervals: `[extendPoint m_M, rank_embed y]` at rank r+2 in M, `[extendPoint m_N, rank_embed y']` at rank r+2 in N.
   - After `rank_embed` to rank r+4: `[extendPoint m_M, rank_embed y]` and `[extendPoint m_N, rank_embed y']` at rank r+4.
   - Reduce to 1 round via `ghr93_duplicator_wins_round_mono`.
   - Pick `a(0) = extendPoint m_M` (the left endpoint).
   - Challenge with `p_N`. Get `p_M`.
   - Game tuple: `extendPoint m_M, extendPoint m_M, extendPoint p_M, rank_embed y` (M-side) and `extendPoint m_N, a'(0), extendPoint p_N, rank_embed y'` (N-side).
6. **Order agreement at positions 0 and 2**: `extendPoint m_M < extendPoint p_M <-> extendPoint m_N < extendPoint p_N`. Since `m_N < p_N` (step 4), the N-side is TRUE, so `m_M < p_M`.
7. **Formula agreement at position 2**: D at `p_M` iff D at `p_N` (at rank r+4, which equals rank-r truth by `stavi_truth_mu_at_point`). Since `~D(p_N)`, `~D(p_M)`.
8. **D at p_M from h_D_bet_gamma_M**: `m_M < p_M` (step 6), `p_M in gamma_M.cut` (since `extendPoint p_M <= y < Sum.inr gamma_M`). So `D(p_M)`.
9. **Contradiction**: `D(p_M)` vs `~D(p_M)`.

### Sorry #2 Proof (RIGHT case: `x <= Sum.inr gamma_M`)

Symmetric to Sorry #1, swapping:
- `left` <-> `right` for gap definability
- `m < u` <-> `u < m` for D-between
- `x` <-> `y` for interval bounds
- Sub-interval: `[x, m_M]` vs `[x', m_N]`

## Rank Embedding Mechanics

The most tedious part is the rank embedding for the sub-interval game. Key lemmas:
- `rank_embed_point h m` : `rank_embed h (extendPoint m) = extendPoint m`
- `rank_embed_le h a b` : `rank_embed h a <= rank_embed h b <-> a <= b`
- Local `rank_embed_comp` (lines 3020-3025): `rank_embed (r+2<=r+4) (rank_embed (r<=r+2) e) = rank_embed (r<=r+4) e`
- `rank_embed_comp_N` (lines 3026-3031): same for N

For the sub-interval game:
1. `h_r1_univ (r+2)` gives game at rank (r+2)+2 = r+4 on `[rank_embed(extendPoint m_M), rank_embed(rank_embed y)]` at rank r+4.
2. Simplify: `rank_embed(extendPoint m_M) = extendPoint m_M` by `rank_embed_point`.
3. Simplify: `rank_embed(rank_embed y) = rank_embed y` by `rank_embed_comp`.
4. Challenge with `p_N` as carrier point: `extendPoint p_N` at rank r+4. Need `extendPoint p_N in [extendPoint m_N, rank_embed y']` at rank r+4.
5. Response `p_M`: `extendPoint p_M in [extendPoint m_M, rank_embed y]` at rank r+4.

## Implementation Notes

- The `game_tuple_b_eq` simp lemma gives `game_tuple x y a b <n+2, _> = y`.
- Order agreement is `same_order_type`, formula agreement is `formula_agreement`.
- Position indices: for n=1 game, positions 0=x, 1=a(0), 2=b, 3=y. So position 0 is the endpoint m_M/m_N and position 2 is the response p_M/p_N.
- The `ghr93_winning_condition` unfolds into `same_order_type /\ gap_point_agreement /\ formula_agreement`.
- For formula agreement at carrier points across ranks: `stavi_truth_mu_at_point m A` gives `stavi_temporal_truth_mu M atomMap r (extendPoint m) A <-> stavi_temporal_truth M atomMap m A` (rank-independent).

## Files
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`: Lines 3328, 3639
- Build passes with sorries.

## Immediate Next Action
Implement the sub-interval forward game proof for Sorry #1 (line 3328), handling the rank embedding mechanics. Then apply the symmetric argument for Sorry #2 (line 3639). Then attempt Sorry #3 (line 3753, winning condition assembly).
