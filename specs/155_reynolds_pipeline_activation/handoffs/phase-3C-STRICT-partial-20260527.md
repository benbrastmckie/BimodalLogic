# Phase 3C-STRICT Handoff: 6 of 8 Sorries Closed

**Date**: 2026-05-27
**Session**: sess_1779937857_21f022
**Phase**: 3C-STRICT [IN PROGRESS]
**Status**: 6 of 8 Phase 3C-STRICT sorries closed. Build passes.

## What Was Done

### Key Innovation: Sub-Interval Backward Games

The depth-agreement gap (report 38) prevents proving `same_side` directly. Instead,
we construct sub-interval backward games using the rank-r IH (`ih`) and compose
them at the pivot e_n/p_n. This gives `sel_pn_ord` for free.

### Infrastructure Added

1. **Threaded `ih` parameter** (rank-r forward-to-backward IH) through:
   - `ghr93_cases_II_III_IV` (new parameter)
   - `ghr93_case_II` (new parameter)
   - `ghr93_inductive_step` (passes `ih` to the above)

2. **Added import**: `Bimodal.Metalogic.WeakCanonical.EFGames.Composition`

3. **Constructed sub-interval games** (in `ghr93_case_II`, after `hc_le_en`):
   - `tau_left : ghr93_duplicator_wins N M atomMap n r d (extendPoint p_n) c e_n`
     Via: `h_r1_univ r` -> `rank_down` -> `round_mono` -> `ih`
   - `tau_right : ghr93_duplicator_wins N M atomMap n r (extendPoint p_n) y' e_n y`
     Same chain.
   - `tau_composed : ghr93_duplicator_wins N M atomMap n r d y' c y`
     Via: `ghr93_strategy_compose` composing tau_left and tau_right at pivot p_n/e_n.

4. **Played tau_left with a_init** to extract sub-interval ordering:
   - `resp_left : Fin n -> ExtendedCarrier M atomMap r` with `hresp_left_in : ∀ k, inClosedInterval c e_n (resp_left k)`
   - `hord_left_sel_pn : ∀ k, (a_init k < p_n ↔ resp_left k < e_n) ∧ (a_init k = p_n ↔ resp_left k = e_n)`

5. **Changed resp_mod** to use resp_left in strict case:
   - `resp_mod k = if a_init k = p_n then e_n else resp_left k`
   - Previously used `resp_tau k` in strict case.

### Sorries Closed (6 of 8)

| Old Line | Description | How Closed |
|----------|-------------|------------|
| 1627 | Case A tau_sel_sel mixed (k=p_n, k'!=p_n) | `hord_left_sel_pn` + `not_lt_of_gt` |
| 1630 | Case A tau_sel_sel mixed (k!=p_n, k'=p_n) | Symmetric |
| 1653 | Case A sel_pn_ord strict same_side | Direct from `hord_left_sel_pn` |
| 2095 | Case B tau_sel_sel mixed (k=p_n, k'!=p_n) | Same approach |
| 2097 | Case B tau_sel_sel mixed (k!=p_n, k'=p_n) | Same approach |
| 2122 | Case B sel_pn_ord strict same_side | Direct from `hord_left_sel_pn` |

### Sorries Remaining (4, all Case B)

| Line | Description | Why Still Open |
|------|-------------|----------------|
| 2146 | tau_sel_b equality (a_init(k)=p_n) | Need p_n < b_resp ↔ e_n < b_sp |
| 2148 | tau_sel_b strict (a_init(k)!=p_n) | Need a_init(k) < b_resp ↔ resp_left(k) < b_sp |
| 2200 | tau_b_sel equality (a_init(k)=p_n) | Symmetric of 2146 |
| 2201 | tau_b_sel strict (a_init(k)!=p_n) | Symmetric of 2148 |

All 4 relate to ordering between resp_mod(k) and b_sp (the Round 2 M-side point).
tau_left was instantiated with p_ce = e_n_pt (not b_sp), so it doesn't give resp_left vs b_sp ordering.

## Next Action: Closing Remaining 4 Sorries

### Approach A: Use tau_composed (hwin_comp) for Case B Round 2

Instead of using tau_left for Case B, instantiate `hwin_comp b_sp hb_sp'` to get:
```
∃ b_resp_comp, inClosedInterval d y' (extendPoint b_resp_comp) ∧
    ghr93_winning_condition n (game_tuple d y' a_init b_resp_comp) (game_tuple c y resp_comp b_sp)
```

Then extract ordering between resp_comp(k) and b_sp from the winning condition.
Define resp_mod using resp_comp (not resp_left) to maintain consistency.

**Problem**: resp_comp may differ from resp_left (different game instantiations).
Need to either:
1. Replace resp_mod to use resp_comp uniformly (requires redoing all ordering extractions)
2. Show resp_comp has same ordering as resp_left (not provable in general)

### Approach B: Use hwin_comp only for b-related ordering

Keep resp_left for all non-b ordering (d, y, sel_pn, sel_sel).
For tau_sel_b and tau_b_sel, use a SEPARATE instantiation of hwin_comp to get
b-related ordering. This requires showing resp_comp(k) and resp_left(k) have
consistent b-ordering, which depends on the specific game strategy.

### Approach C: Restructure Case B to use composed game throughout

Replace the entire Case B winning condition assembly to use hwin_comp.
The composed game handles b_sp correctly (routing to left or right sub-game).
This is the cleanest approach but requires ~100 lines of Case B restructuring.

### Recommended Approach: C

Restructure Case B to use `hwin_comp` for all ordering/formula/gap data.
This means:
1. In Case B, instantiate `hwin_comp b_sp hb_sp'` (not hwin_tau)
2. Use resp_comp and its winning condition for all ordering extractions
3. sel_pn_ord follows from the same hord_left_sel_pn (used separately)
4. tau_sel_b, tau_b_sel, tau_d_sel, tau_sel_y, tau_sel_sel all come from resp_comp
5. The problem is that resp_mod uses resp_left, not resp_comp

**Key insight**: resp_comp = resp_left when played with the same a_init and
instantiated with the same Round 2 point (p_ce). But in Case B, the Round 2
point is b_sp (different). So resp_comp may differ.

**Real solution**: Change resp_mod to use resp_comp from tau_composed.
Play tau_composed with a_init to get resp_comp (as currently done).
Then resp_mod(k) = if a_init(k) = p_n then e_n else resp_comp(k).
sel_pn_ord: play tau_left SEPARATELY just for the ordering fact.
Show resp_comp(k) has same pn-ordering as resp_left(k) because both
go through the left sub-game. This requires a new lemma about
composition output when all selections are on one side.

## Build State

`lake build` passes. No new errors or warnings beyond pre-existing ones.

## Key Decisions

1. **resp_mod uses resp_left**: Changed from resp_tau to resp_left.
   This gives sel_pn_ord for free but creates the b_sp ordering problem.
2. **tau_left constructed via ih + h_r1_univ + rank_down**: This bypasses
   the depth-agreement gap entirely.
3. **ghr93_strategy_compose used for tau_composed**: The composed game
   handles degenerate cases correctly (both sub-intervals have points).
