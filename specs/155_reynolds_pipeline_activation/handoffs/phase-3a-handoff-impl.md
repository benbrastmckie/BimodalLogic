# Phase 3A Handoff: Unified Game Restructure -- BLOCKED

## Status: BLOCKED

## Immediate Next Action

The sel-vs-p_n ordering gap requires one of three resolution paths before Phase 3B can proceed:
1. **Lemma 10 (strategy restriction)**: Implement GHR93 Lemma 10 to assume Spoiler's selections are distinct and strictly ordered. Then both sides of the biconditional are True.
2. **(n+1)-round backward game on [d,y']/[c,y]**: Currently only n-round tau exists. Need to derive an (n+1)-round backward game that covers all n+1 positions.
3. **Constrained d-compatible game**: Modify `h_d_compat_left` so that `a'_big(k) = a_init(k)` by construction (requires changing how the game's Duplicator strategy works).

## Current Proof State

### Sorry Sites (unchanged from entry)
- **Line 1594 (Case A)**: 3 goals remain from `same_order_type_grid <;> first | ... | sorry`
  - Goal 1: y' vs sel (Fin mismatch) -- CLOSABLE with convert/congr/Fin.ext
  - Goal 2: sel(i) vs p_n -- BLOCKED (structural gap)
  - Goal 3: p_n vs sel(j) -- BLOCKED (structural gap, reverse of Goal 2)
- **Line 1866 (Case B)**: ~8 goals remain, same pattern plus additional cross-boundary cases
- **Line ~2837 (Cases III-IV)**: Entire theorem body sorry -- Phase 5, independent

### Key Hypotheses Available at Sorry Site
```
tau_d_sel : (d < a_init(k) <-> c < resp_tau(k))
hord_cd_en_pn : (c < e_n <-> d < extendPoint p_n)
tau_sel_sel : (a_init(k) < a_init(k') <-> resp_tau(k) < resp_tau(k'))
tau_sel_y : (a_init(k) < y' <-> resp_tau(k) < y)
hd_le_sel : d <= a_init(k), hd_le_pn : d <= extendPoint p_n
hc_le_rtau : c <= resp_tau(k), hc_le_en : c <= e_n
```

### What Is Missing
```
sel_pn_ord : (a_init(k) < extendPoint p_n <-> resp_tau(k) < e_n)
```
This cannot be derived from the above because a_init(k) and extendPoint p_n are in a FAN configuration relative to d (both >= d, no chain).

## Key Decisions

1. **Approach E (unified game) is infeasible as stated**: Any game play produces NEW N-side responses that are NOT a_init(k). The order-isomorphism between a_init and a'_game relative to d and y' does NOT extend to ordering relative to p_n.

2. **Trichotomy argument partially works**: When d = a_init(k) or d = p_n, the ordering IS derivable. Only the case (d < a_init(k) AND d < p_n) is stuck.

3. **Goal 1 (y' vs sel) IS closable**: The Fin mismatch is solvable with `convert ... using 3 <;> (congr 1; exact Fin.ext (by omega))`.

## Approaches Attempted and Failed

| # | Approach | Result |
|---|----------|--------|
| 1 | h_fwd_n1 with resp_tau + e_n | a'_fwd(k) != a_init(k) |
| 2 | hord_big at (1+k, b-pos) | a'_big(k) != a_init(k) |
| 3 | Tau with e_n_pt challenge | b_tau != p_n (fan with d) |
| 4 | Trichotomy d/a_init/p_n | Only d=a_init or d=p_n cases work |
| 5 | Order-iso extension | FALSE: counterexample d=0, a_init=1, a'=2, p_n=1.5 |
| 6 | Pivot through y', x', a_init(k') | No chain exists |

## Build Status

Build passes cleanly with sorry fallbacks in place (no regressions).

## Files Modified

None (analysis only, no code changes).

## Recommended Research Direction

The most promising resolution path is **Lemma 10 (strategy restriction)**:
- GHR93 explicitly uses "we may assume [selections] are all distinct" (p. 116)
- Lemma 10 states: if Duplicator wins G_{n;r}, she also wins when Spoiler's selections are restricted to be distinct
- With distinct selections, a_init(0) < ... < a_init(n-1) < p_n, making (a_init(k) < p_n) trivially True
- And resp_tau(0) < ... < resp_tau(n-1) < e_n from the ordering preservation, making (resp_tau(k) < e_n) trivially True
- The biconditional becomes True <-> True

This requires implementing `ghr93_duplicator_wins_strategy_restrict` or equivalent.

## Session

Session: sess_1779830567_4cbdda
