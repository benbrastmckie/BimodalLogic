# Phase 6 Handoff v4: Cases III/IV -- 1 Sorry Remaining (Non-Degenerate Case)

**Date**: 2026-05-28
**Session**: sess_1780001766_2e723d
**Status**: PARTIAL (1 sorry remains in non-degenerate case)
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`
**Sorry location**: Line 3359 (non-degenerate case of `case pos` in ghr93_cases_III_IV)

## What Was Attempted This Session

Deep analysis of the non-degenerate case sorry at line 3359. The proof was decomposed into clear sub-problems but a critical ordering lemma (`c <= Sum.inr gamma_M`) is needed and requires infrastructure that does not yet exist in the codebase.

## Goal State at Line 3359

```
exists b_resp,
    inClosedInterval x' y' (extendPoint b_resp) /\
      ghr93_winning_condition (n + 1)
        (game_tuple x' y' a_bwd b_resp)
        (game_tuple x y a'_resp b_sp)
```

where:
- `a'_resp(k) = resp_sub(k)` for k < n, `a'_resp(n) = Sum.inr gamma_M`
- `a_bwd(k) = a_init(k)` for k < n, `a_bwd(n) = Sum.inr gamma_N`
- `resp_sub(k) in [x, gamma_M]` from sub-game
- `b_sp : M.carrier` with `b_sp in [x, y]`

## Proof Strategy (Validated)

### Step 1: Establish `c <= Sum.inr gamma_M` [BLOCKED]

This is the critical missing piece. The proof requires:

1. Use `h_d_compat_left` to play the forward game with selections `[gamma_M, c, c, ..., c]` (gamma_M at position 0, c at all others including the last position).
2. The forward game gives N-responses `a'_full` with `a'_full(last) = d`.
3. The ordering biconditional gives: `gamma_M < c <-> a'_full(0) < d`.
4. To show `c <= gamma_M`, it suffices to show `a'_full(0) >= d` (i.e., `not (a'_full(0) < d)`).
5. To show `a'_full(0) >= d`: since `a'_full(0)` has the same rank-r formulas as `gamma_M` (from the forward game's formula_agreement), and `gamma_M` has the same rank-r formulas as `gamma_N` (from `h_gamma_M_form`), `a'_full(0)` has the same rank-r formulas as `gamma_N`.
6. Since `gamma_N = a_bwd(n)` is in `continuation_set` (by `a_n_in_continuation_set`), and `cont_holds` is determined by rank-r formula satisfaction, `a'_full(0)` should also be in `continuation_set` (at least the same-or-higher continuation holds).
7. Since `d = inf(continuation_set)` and `a'_full(0) in continuation_set`, we get `d <= a'_full(0)`.

**Blocker**: Step 6 requires a lemma that `continuation_set` membership is closed under rank-r formula equivalence. Specifically:
```
-- If t, s in [x', y'] with stavi_temporal_truth_mu ... t A <-> stavi_temporal_truth_mu ... s A
-- for all A with stavi_depth A <= r, and s in continuation_set, then t in continuation_set.
-- (Requires: t >= x' and t <= y', which we have from a'_full_in.)
```

This lemma does NOT exist in the codebase. The continuation_set (`Claim1.lean` line 164) is defined as:
```
{ t | inClosedInterval x' y' t /\
  forall u, t < u -> u < y' -> mu_holds u -> cont_holds a_n y' u }
```

The inner condition `cont_holds a_n y' u` is:
```
forall A, stavi_depth A <= r ->
  (forall v, a_n < v -> v < y' -> mu_holds v -> stavi_temporal_truth_mu ... v A) ->
  stavi_temporal_truth_mu ... u A
```

This is about u's truth, NOT t's truth. So continuation_set membership depends on what happens at mu-points ABOVE t (in the tail (t, y')), not on t's own formula satisfaction. Two points t, s can have the same rank-r formulas but different continuation_set membership if the mu-points in their tails differ.

**HOWEVER**: if `a'_full(0) < gamma_N` (which is what `a'_full(0) < d <= gamma_N` implies), then `(a'_full(0), y') SUPERSET (gamma_N, y')`. Since `gamma_N in continuation_set`, `cont_holds` holds at all mu-points in `(gamma_N, y')`. But `(a'_full(0), y')` is LARGER, and includes mu-points in `(a'_full(0), gamma_N]`. For these additional mu-points, we need to verify `cont_holds`, which is NOT guaranteed by gamma_N's membership.

**Conclusion**: The naive continuation_set argument does NOT work for proving `c <= gamma_M`. A different approach is needed.

### Alternative Approach: Avoid `c <= gamma_M` Entirely

Instead of proving `c <= gamma_M`, restructure the Round 2 case split:

1. Case split on `extendPoint b_sp <= c`:
   - **b_sp <= c**: Use sigma game (0-round version for Round 2 challenge). But sigma only gives 0-round orderings (x/x', b/b', c/d), not the full (n+1)-round orderings needed.
   - **b_sp > c**: Use tau game directly.

This doesn't work because sigma with 0 rounds gives insufficient orderings.

2. Alternative: Use `h_d_compat_left` directly for the ENTIRE winning condition (not just for `c <= gamma_M`). Play the forward game with selections that include all of `a'_resp` (resp_sub(0), ..., resp_sub(n-1), gamma_M) and c. Extract orderings from the forward game response. This gives orderings between ALL pairs, bypassing the need for `c <= gamma_M`.

**This is the recommended approach for the next session.**

### Step 2: Case Split on `b_sp <= gamma_M` [READY once Step 1 resolved]

- **Case A (b_sp <= gamma_M)**: Use sub-game `hwin_sub` to get `b_resp in [x', gamma_N]`.
- **Case B (b_sp > gamma_M)**: Use tau `hwin_tau` to get `b_resp in [d, y']`. Requires `c <= b_sp`, which follows from `c <= gamma_M < b_sp`.

### Step 3: Assemble Winning Condition [READY once Step 2 provides b_resp]

For each case, construct the 3 components:
1. **same_order_type_of_cases**: 7 ordering arguments using sub-game/tau orderings + pivot_chain_order for y/y' orderings.
2. **gap_point_agreement_of_cases**: 4 arguments. At x/x': from sub-game or interval. At b: points (carrier). At y/y': from tau. At selections k<n: from sub-game. At selection n (gap): from gamma_gp.
3. **formula_agreement_of_cases**: 4 arguments. At x/x': from sub-game. At b: from sub-game/tau. At y/y': from tau. At selections: from sub-game + gamma_M_form.

## RECOMMENDED APPROACH: Fresh Upper Sub-Game (Avoids c <= gamma_M Entirely)

**Key insight**: Instead of proving `c <= gamma_M` to use tau for Case B, construct a FRESH backward sub-game on `[gamma_N, y'] x [gamma_M, y]` using the IH + `h_r1_univ`. This sub-game handles `b_sp > gamma_M` directly without needing the c/d split point.

### Construction

1. Get forward game on `[gamma_M, y] x [gamma_N, y']`:
   ```
   h_fwd_upper := ghr93_duplicator_wins_round_mono (1+3*n <= 4+3*n) gamma_M_le_y gamma_N_le_y'
     (ghr93_duplicator_wins_rank_down (r <= r+2) (r+2 <= r+2) gamma_M_le_y gamma_N_le_y'
       (h_r1_univ r gamma_M_le_y gamma_N_le_y'))
   ```
   This gives a `(1+3*n)`-round forward game at rank r.

2. Apply IH to get backward game:
   ```
   tau_upper := ih gamma_M_le_y gamma_N_le_y' h_pt_upper h_fwd_upper
   ```
   This gives an n-round backward game on `[gamma_N, y'] x [gamma_M, y]`.

3. **Carrier point in [gamma_N, y']**: Case split on `gamma_N = y'` vs `gamma_N < y'`.
   - If `gamma_N = y'`: all a_bwd(k) = gamma_N = y', gamma_M = y (from gamma correspondence). All selections are at endpoints. Use a degenerate argument (similar to existing degenerate case).
   - If `gamma_N < y'`: find carrier point in `(gamma_N, y']` using `isPoint_or_isGap y'` and gap cut structure.

### Round 2 Dispatch

- **Case A (b_sp <= gamma_M)**: Use `hwin_sub` (sub-game on `[x', gamma_N] x [x, gamma_M]`).
- **Case B (b_sp > gamma_M)**: Use `tau_upper` (fresh sub-game on `[gamma_N, y'] x [gamma_M, y]`). `b_sp in (gamma_M, y]` gives `b_sp in [gamma_M, y]`. Get `b_resp in [gamma_N, y']`.

### Ordering Assembly

For same_order_type_of_cases, the 7 arguments are:
1. (x', b_resp): From sub-game (Case A) or compose sub_game x<->gamma + upper gamma<->b (Case B).
2. (x', y'): pivot_chain_order through gamma_N/gamma_M using sub-game + upper sub-game.
3. (b_resp, y'): From upper sub-game (Case B has b_resp in [gamma_N, y']) or sub-game (Case A has b_resp in [x', gamma_N]).
4. (x', a_bwd(k)): For k<n from sub-game; for k=n from gamma correspondence.
5. (b_resp, a_bwd(k)): For k<n from sub-game/upper; for k=n from gap orderings.
6. (y', a_bwd(k)): Both False since a_bwd(k) <= gamma_N <= y' (always <= not >).
7. (a_bwd(k), a_bwd(k')): From sub-game (k,k'<n); from gamma ordering (k or k'=n).

### Advantage

This approach completely avoids the `c <= gamma_M` problem. The two sub-games partition the interval at gamma_M/gamma_N (a natural split), not at c/d (an artificial split that may not align with gamma).

## Key Available Data (Quick Reference)

| Hypothesis | Type | Source |
|-----------|------|--------|
| `hwin_sub` | Sub-game Round 2: M-challenge in [x, gamma_M] -> N-response in [x', gamma_N] | IH + h_fwd_sub |
| `hwin_tau` | Tau Round 2: M-challenge in [c, y] -> N-response in [d, y'] | rank_down of props.tau |
| `resp_sub(k)` | M-responses in [x, gamma_M] | Sub-game Round 1 |
| `resp_tau(k)` | M-responses in [c, y] | Tau Round 1 |
| `h_gamma_M_form` | Formula agreement: gamma_M <-> gamma_N at rank r | Gap detection transfer |
| `h_gamma_gp` | Gap/point agreement: gamma_M <-> gamma_N | Gap detection |
| `props.hcd_form` | Formula agreement: c <-> d at rank r | SplitPointProps |
| `props.hcd_gp` | Gap/point agreement: c <-> d | SplitPointProps |
| `h_d_compat_left` | Forward game with d at last N-position | SplitPointProps |
| `props.h_fwd_n1` | (n+1)-round forward game on [x,y] x [x',y'] | SplitPointProps |

## Files NOT to Modify

- `ChronicleToCountermodel.lean` (another agent working on succ_cofinal)
- `Transfer.lean`
- `SplitPoint.lean` (unless adding infrastructure lemmas)

## Degenerate Case Template

The degenerate case proof (lines 3399-3740) serves as a template for the assembly pattern. Key patterns:
- Use `@same_order_type_of_cases sig N M` for backward direction (N first, M second)
- Use `show` to force `a'_resp k` reduction
- Use `rw [ha_bwd_all_γN k]` to simplify N-side selections
- Use `hx'_eq_γN` and `hxc_eq` to rewrite endpoints

## What NOT to Try

1. Do NOT attempt to prove `c <= gamma_M` via continuation_set membership closure -- the inner condition depends on the TAIL of t, not t's own formulas.
2. Do NOT use sigma for Case B when b_sp > gamma_M -- sigma requires selections from [x', d] but a_init is in [d, y'].
3. Do NOT use a 0-round version of sigma for full winning condition -- it only gives 3-position orderings, not n+1 positions.
