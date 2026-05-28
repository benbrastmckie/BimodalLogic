# Phase 3C-EQ Handoff: Equality Case Complete

**Date**: 2026-05-28
**Session**: sess_1779937857_21f022
**Phase**: 3C-EQ [COMPLETED]
**Status**: Equality case of sel_pn_ord closed via modified response function.

## What Was Done

### Modified Response Function (`resp_mod`)

Defined `resp_mod : Fin n -> ExtendedCarrier M atomMap r` at line ~1479 of CaseAnalysis.lean:
```
resp_mod(k) = if a_init(k) = extendPoint p_n then e_n else resp_tau(k)
```

This replaces `resp_tau` in the game_tuple response function. When Spoiler duplicates the split point (a_init(k) = p_n), Duplicator responds with e_n (the forward-game witness) instead of resp_tau(k).

### Ordering Facts Lifted to resp_mod

All tau ordering facts were restated in terms of `resp_mod`:
- `tau_d_sel`, `tau_sel_y`: equality case uses `hord_cd_en_pn` / `hord_fwd_en_y`; strict case uses raw tau facts
- `tau_sel_sel`: both-equal case trivial; mixed cases sorry'd (Phase 3C-STRICT); both-strict case uses raw tau
- `sel_pn_ord`: equality case `(False <-> False) /\ (True <-> True)` closed; strict case sorry'd via same_side
- `pn_sel_ord`: derived from sel_pn_ord
- Case B additionally: `tau_sel_b`, `tau_b_sel` -- equality cases sorry'd (Phase 3C-STRICT)

### Winning Condition Updates

- `gap_point_agreement`: equality case -- both a_init(k) = p_n (point) and resp_mod(k) = e_n (point). Proved directly.
- `formula_agreement`: equality case -- uses `hform_en_an` (e_n agrees with p_n on rank-r formulas). Proved directly.
- `ha'_resp_in`: updated to use `hresp_mod_in`.
- Grid dispatch: `hresp_tau_in` references replaced with `hresp_mod_in` where goals involve `resp_mod`.

## Sorry Inventory

| Line | Location | Type | Phase |
|------|----------|------|-------|
| 1627 | Case A tau_sel_sel | mixed k=p_n, k'≠p_n | 3C-STRICT |
| 1630 | Case A tau_sel_sel | mixed k≠p_n, k'=p_n | 3C-STRICT |
| 1653 | Case A sel_pn_ord | strict same_side | 3C-STRICT |
| 2076 | Case B tau_sel_b | equality sel vs b_resp | 3C-STRICT |
| 2095 | Case B tau_sel_sel | mixed case | 3C-STRICT |
| 2097 | Case B tau_sel_sel | mixed case | 3C-STRICT |
| 2105 | Case B tau_b_sel | equality b_resp vs sel | 3C-STRICT |
| 2122 | Case B sel_pn_ord | strict same_side | 3C-STRICT |
| 2337 | Case B grid | b_resp vs p_n | 3C (pre-existing) |
| 2390 | Case B dead code | dead code | pre-existing |
| 4454 | Cases III/IV | Cases III/IV | pre-existing |

All 8 new sorries are Phase 3C-STRICT material. The equality case of sel_pn_ord is fully closed.

## Key Decisions

1. **Response function modification required**: Same_side for the equality case cannot be proved without modifying the response function, because `resp_tau(k) = e_n` when `a_init(k) = p_n` is not derivable from available hypotheses.
2. **Cascading changes**: The response function change cascades through ordering facts, grid dispatch, gap_point_agreement, and formula_agreement. ~200 lines modified.
3. **Hoisted `hd_le_pn` and `hc_le_en`**: These were moved before `resp_mod` definition since `hresp_mod_in` needs `c <= e_n`.

## Next Action

Phase 3C-STRICT or Phase 6E (strategy composition infrastructure). The strict case requires either same_side proof or strategy composition to bypass sel_pn_ord entirely.

## Build State

`lake build` passes. No new warnings beyond pre-existing ones.
