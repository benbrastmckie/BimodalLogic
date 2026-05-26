# Phase 3 Handoff: Implementation v2

**Task**: 155 - Reynolds Pipeline Activation
**Session**: sess_1779640471_03278b
**Date**: 2026-05-26
**Status**: BLOCKED

## What Was Attempted

Continued Phase 3 sorry closures from previous cycle. Analyzed all 3 remaining sorry sites:

1. **CaseAnalysis.lean:1569** (Case A same_order_type grid) - 3 goals remaining:
   - Goal 1 (y' vs sel): CLOSABLE with existing `tau_sel_y` pattern + impossibility for `<` direction. The pattern at lines 1560-1568 closes this.
   - Goal 2 (sel(i) vs p_n): BLOCKED by sel-vs-p_n ordering gap
   - Goal 3 (p_n vs sel(j)): BLOCKED by sel-vs-p_n ordering gap

2. **CaseAnalysis.lean:1657** (Case B same_order_type) - Full sorry, BLOCKED
3. **CaseAnalysis.lean:1710** - Dead code inside block comment. No goals. Not a live sorry.

## The Sel-vs-P_n Ordering Gap

### The Missing Ordering

The combined (n+1)-round game needs `same_order_type` which requires all pairwise orderings. The ordering between selection positions (a_init k for k < n on N-side, resp_tau k on M-side) and the p_n position (extendPoint p_n on N-side, e_n on M-side) cannot be derived from available hypotheses.

Needed: `(a_init k < extendPoint p_n <-> resp_tau k < e_n)` for all k < n.

### Why It's Missing

The tau game (on [d,y'] x [c,y]) provides orderings among:
- d vs a_init k, a_init k vs y', a_init k vs a_init k'
- But NOT a_init k vs extendPoint p_n (p_n is not a tau game position)

The big game (d-compatible, on [x,y] x [x',y']) provides orderings among:
- resp_tau k vs e_n (via a_pad_big positions)  
- But the N-side correspondents are a'_big elements, NOT a_init elements

The cross-boundary ordering hord_cd_en_pn gives c vs e_n <-> d vs p_n, but this is between the PIVOTS, not between sel and p_n.

### Approaches Tried

1. **pivot_chain_order through d/c**: Requires chain d <= a_init k <= p_n or d <= p_n <= a_init k. Neither is known. Fork geometry (both above d) is not handled by pivot_chain.

2. **Extract from hord_big**: Gives `resp_tau k < e_n <-> a'_big k < p_n`, but a'_big k != a_init k.

3. **Instantiate tau with e_n_pt**: Gives `a_init k < extendPoint b_en <-> resp_tau k < e_n`, but b_en != p_n in general.

4. **Prove b_en = p_n from ordering equivalences**: Established `d < b_en <-> d < p_n` and `b_en < y' <-> p_n < y'`, but this doesn't determine equality when both are strictly between d and y'.

5. **Fork ordering from common bounds**: Proved mathematically impossible on general linear orders.

## Proposed Fix

The cleanest fix is option (1) from the BLOCKER: add a `sel_pn_ord` hypothesis that provides the missing ordering directly. This requires modifications to the proof structure BEFORE the same_order_type_grid dispatch:

```lean
-- Before the grid dispatch, derive sel-vs-p_n orderings
-- This needs a new game construction or a modification to
-- SplitPointProps/obtain_split_point_props
have sel_pn_ord : forall (k : Fin n),
    (a_init k < extendPoint p_n <-> resp_tau k < e_n) /\
    (a_init k = extendPoint p_n <-> resp_tau k = e_n) := by
  -- Source: needs to be derived from a game that includes
  -- both a_init positions and extendPoint p_n/e_n
  sorry
```

The ordering should be derivable by modifying `h_d_compat_left` or adding a new SplitPointProps field that provides an (n+1)-round game on [d,y'] x [c,y] with the n-th inner position being p_n/e_n. This game would include all tau positions plus the cross-boundary element.

## Current State

- Build passes (all existing sorries are in non-critical paths)
- No code changes were made (analysis only)
- Phase 3 marked [BLOCKED] in plan file
- Sorry count unchanged: 3 live in CaseAnalysis.lean (lines 1569, 1657), 1 dead (line 1710), plus S11 at line 2628

## Next Actions

1. Research phase needed to design the sel_pn_ord infrastructure
2. Option: modify `hwin_tau` to return an (n+1)-round game that includes p_n/e_n as a position
3. Option: add `sel_pn_ord` as a new field to `SplitPointProps` populated during `obtain_split_point_props`
4. After sel_pn_ord is available, add it as a branch in the `first | ... | sorry` grid dispatch
5. Case B (sorry #2) additionally needs sigma instantiation for `x' < d <-> x < c`
