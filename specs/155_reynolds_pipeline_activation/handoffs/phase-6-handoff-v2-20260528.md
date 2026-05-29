# Phase 6 Handoff v2: Cases III/IV Gap Handling

**Date**: 2026-05-28
**Session**: sess_1780001766_2e723d
**Status**: PARTIAL (2 sorries remain, structure correct)
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`
**Sorry locations**: Lines ~3359 (non-degenerate case), ~3453 (degenerate case)

## Summary of Progress

### What Was Done

1. **Identified the sel_gap_ord blocker**: The previous attempt was blocked on proving `resp_tau(k) < gamma_M <-> a_init(k) < gamma_N` (ordering between tau responses and gap positions). This is fundamentally unprovable from the tau game alone because resp_tau ranges over [c, y] while gamma_M might be anywhere in [x, y].

2. **Implemented IH sub-game approach**: Built a backward game on [x, gamma_M] x [x', gamma_N] using:
   - `h_r1_univ` at r' = r to get forward game at rank r+2
   - `ghr93_duplicator_wins_rank_down` to project to rank r
   - `ghr93_duplicator_wins_round_mono` to reduce rounds to (1+3*n)
   - `ih` to convert forward to backward game

3. **Solved sel_gap_ord**: The sub-game responses `resp_sub` are in [x, gamma_M], so `resp_sub(k) <= gamma_M` by construction. The sub-game winning condition gives all sel-gap orderings because gamma_M/gamma_N ARE the y-endpoints of the sub-game.

4. **Handled degenerate case**: When no carrier point exists in [x', gamma_N], proved x' = gamma_N (degenerate). Then proved all a_bwd(k) = gamma_N and all resp_tau(k) = c (the split point). This uses tau ordering at the c/d endpoint positions.

5. **Build passes**: Both sorry markers are in valid positions with all required hypotheses available.

### What Remains (2 Sorries)

#### Sorry 1: Non-Degenerate Winning Condition Assembly (Line ~3359)

**Available hypotheses at sorry site**:
- `resp_sub : Fin n -> ExtendedCarrier M atomMap r` with `hresp_sub_in : forall k, resp_sub(k) in [x, gamma_M]`
- `hwin_sub` : sub-game winning condition for n-round game on [x, gamma_M] x [x', gamma_N]
- `b_sp : M.carrier` with `hb_sp_in : b_sp in [x, y]`
- `a'_resp(k) = resp_sub(k)` for k < n, `a'_resp(n) = gamma_M`
- `gamma_M_form`, `gamma_gp` for formula/gap-point at gamma position
- `h_r1_univ` for forward games at any sub-interval

**What needs to be proved**: `exists b_resp in [x', y'], ghr93_winning_condition (n+1) (game_tuple x' y' a_bwd b_resp) (game_tuple x y a'_resp b_sp)`

**Strategy for closing**:
1. Case split on `b_sp in gamma_M.cut` (b_sp < gamma_M) vs `b_sp not in gamma_M.cut` (b_sp > gamma_M).
2. For b_sp < gamma_M: challenge sub-game with b_sp to get b_resp in [x', gamma_N]. The sub-game winning condition maps to the outer winning condition with a position remapping.
3. For b_sp > gamma_M: all selections are below gamma_M < b_sp. Need b_resp > gamma_N from a right-side forward game on [gamma_M, y] x [gamma_N, y'].
4. **The key difficulty** for same_order_type: orderings between gamma_M and y (resp. gamma_N and y'). The sub-game gives orderings relative to its endpoints (x and gamma_M), but NOT relative to the outer endpoint y. Need `gamma_M < y <-> gamma_N < y'` and `gamma_M = y <-> gamma_N = y'`. Derivable from a forward game on [gamma_M, y] x [gamma_N, y'] when carrier points exist in [gamma_N, y'].
5. For gap_point_agreement and formula_agreement: mostly from sub-game + gamma_M_form + tau endpoint data.

#### Sorry 2: Degenerate Winning Condition Assembly (Line ~3453)

**Available hypotheses**:
- `hx'_eq_gamma_N : x' = gamma_N` (degenerate)
- `ha_bwd_all_gamma_N : forall i, a_bwd i = gamma_N`
- `hresp_tau_all_c : forall k, resp_tau k = c = Sum.inr g_c`
- `hgc_form` : formula agreement between g_c and gamma_N
- All N-selections collapse to a single gap point

**Strategy for closing**: Since all N-positions (except y') are the same gap gamma_N, and all M-responses (except gamma_M) are the same gap g_c, the winning condition is highly degenerate. All sel-sel orderings are trivially equal (both sides identical). The main work is showing b_resp exists with the right properties.

## Key Mathematical Insight

The `sel_gap_ord` problem (resp_tau(k) < gamma_M) cannot be solved from the tau game because the tau game ranges over [c, y] while gamma_M ranges over [x, y] with no ordering guarantee between c and gamma_M. The IH sub-game approach CREATES a game whose interval ENDS at gamma_M, so all responses are bounded by gamma_M by construction.

The remaining issue (`gamma_M < y <-> gamma_N < y'`) requires either:
1. A forward game on [gamma_M, y] x [gamma_N, y'] (needs carrier point existence)
2. Case analysis on gamma_N = y' (degenerate, which is already handled separately)
3. Modifying h_gap_match to return the strict ordering as additional data

Approach (2) + a right-side forward game for (1) when gamma_N < y' is the recommended path.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`: Replaced lines 3274-3318 (sorry) with ~180 lines of proof structure including:
  - IH sub-game construction (lines ~3274-3340)
  - Non-degenerate case skeleton with sorry (line ~3359)
  - Degenerate case proof (x' = gamma_N, all collapses) with sorry (line ~3453)
- `specs/155_reynolds_pipeline_activation/plans/47_path-c-supremum-plan.md`: Phase 6 marked [IN PROGRESS]

## Prohibited Workarounds

- Do NOT use `sorry` for the orderings and consider the phase done
- Do NOT use vacuous definitions
- Do NOT simplify to discrete-only
