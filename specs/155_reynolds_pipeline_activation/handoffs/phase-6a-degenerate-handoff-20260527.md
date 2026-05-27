# Phase 6A Degenerate Case Handoff

**Task**: 155 (Reynolds Pipeline Activation)
**Phase**: 6A (continued)
**Date**: 2026-05-27
**Session**: sess_1748393400_orch155
**Status**: PARTIAL -- compose_wc/compose_wc_right closed, 2 degenerate sorries remain

## What Was Completed

1. **compose_wc** (line 136): Winning condition transfer when b comes from LEFT strategy.
   - Per-index ownership classification via `idx_data` helper
   - Same-side pairs: rewrite to sub-game values, apply hord_L/hord_R
   - Cross-side pairs: pivot_chain_order through c/d
   - Gap_point_agreement and formula_agreement: per-index dispatch

2. **compose_wc_right** (line 348): Symmetric case when b comes from RIGHT strategy.
   - Same structure as compose_wc but n+1 is RIGHT-owned
   - Uses c <= tM classification (may overlap at boundary)
   - RIGHT i, LEFT j case uses reversed pivot with trichotomy argument

## What Remains: 2 Degenerate Case Sorries

### Sorry at line 98: No point in [d, y']
- Context: b' <= d (left case), left strategy gives b and hcond_L, no point in [d, y']
- Goal: exists b, inClosedInterval x y (extendPoint b) /\ ghr93_winning_condition ...

### Sorry at line 112: No point in [x', d]  
- Context: d < b' (right case), right strategy gives b and hcond_R, no point in [x', d]
- Goal: exists b, inClosedInterval x y (extendPoint b) /\ ghr93_winning_condition ...

## Analysis of the Degenerate Case

### The Core Problem

When d = y' (no point in [d, y']):
- All a'_R i = d (forced by [d, d] interval)
- Merged N at RIGHT sel k: a'_R k = d
- Merged N at n+2: y' = d
- Merged M at RIGHT sel k: a k > c (varies)
- same_order_type at (RIGHT i, RIGHT j) requires: a_i < a_j <-> d < d = False
- This forces a_i = a_j for ALL RIGHT pairs, which Spoiler can violate

### Key Insight (Not Yet Implemented)

From hcond_L (left game winning condition) at indices (1+k, n+2) where a_L k = c:
- hcond_L gives (c < c <-> a'_L k < d) and (c = c <-> a'_L k = d)
- The second gives True <-> (a'_L k = d), so **a'_L k = d for all RIGHT k**

Therefore: a' k = if (a k <= c) then a'_L k else a'_R k
- LEFT k: a'_L k
- RIGHT k: a'_R k = d = a'_L k

So **a' k = a'_L k for ALL k**, and the merged N-tuple equals the left game N-tuple:
game_tuple x' y' a' b' = game_tuple x' d a'_L b' (since y' = d)

### Proposed Approach

The merged game has:
- M-side: game_tuple x y a b
- N-side: game_tuple x' d a'_L b' (= left game N-tuple)

The left game has:
- M-side: game_tuple x c a_L b  
- N-side: game_tuple x' d a'_L b'

At LEFT indices: merged M = left M (a k = a_L k).
At RIGHT sel k: merged M = a k > c, left M = a_L k = c.
At n+2: merged M = y, left M = c.

For same_order_type:
- LEFT-LEFT: use hord_L directly (M and N match)
- LEFT-RIGHT: pivot through c/d using hord_L at (i, n+2)
  - Need: merged M at RIGHT j >= c (true) and merged N at RIGHT j = d
  - From hord_L: left M at 1+k = c and left N at 1+k = a'_L k = d
  - So pivot data: (c < c <-> d < d) [trivially true], (c = c <-> d = d) [True]
  - For merged: (left_val < a_k <-> left_N_val < d)
  - Since left_N_val = a'_L i <= d: use hord_L at (i, n+2) for (left_val < c <-> left_N < d)
  - And (c < a_k iff true, d < d iff false) -- this doesn't work cleanly
- RIGHT-RIGHT: merged M values are a_i, a_j > c. N values are both d.
  - Need a_i < a_j <-> False and a_i = a_j <-> True
  - NOT satisfiable in general!

### Alternative Approach: Change Response in Degenerate Case

Instead of using the merged a' = if ... then a'_L else a'_R, use a'_L for ALL indices.
Since a'_L k = d for RIGHT k, this gives the same a' values.
BUT the current code already commits to a' at line 72.

The fix: in the degenerate case branch, DO NOT use compose_wc. Instead:
1. Prove d = y'
2. Prove a'_L k = d for RIGHT k
3. Show game_tuple x' y' a' b' = game_tuple x' d a'_L b'
4. Show that the merged M-tuple at RIGHT indices maps to the left game's boundary c
   via: a_k > c and left game has a_L k = c at those indices
5. For same_order_type: at RIGHT-RIGHT pairs, both merged N = d and from the left game
   hord_L at (1+i, 1+j) with both M = c: (c < c <-> d < d) /\ (c = c <-> d = d).
   The merged M values differ from the left game (a_k vs c), but the ordering in the merged
   game at (RIGHT i, RIGHT j) should follow from:
   - a_i < a_j implies c < a_j (since a_i > c) but we need a_i < a_j <-> d < d = False
   - This STILL requires a_i = a_j.

### Conclusion

The degenerate case has a genuine mathematical subtlety. The GHR93 paper may handle it
by choosing a different response in the degenerate case, or by showing that the degenerate
case doesn't arise when Spoiler picks distinct RIGHT selections. This needs further
mathematical analysis before a Lean proof can be completed.

One possible resolution: the degenerate case only arises when d and y' are the same GAP.
In this case, the right sub-interval [c, y] vs [d, d] has all N-responses equal to d.
The right strategy's Round 1 response a'_R satisfies: game_tuple c y a_R ? at any index
compared to game_tuple d y' a'_R ? has all N-values = d. So the right strategy's
same_order_type implies all M-side values in the right game are equal to c (since the N-side
is constant). This means a_R k = c for all k, which means a k <= c for all k. 
Then there are NO RIGHT selections! And the degenerate case is trivially handled because
the only RIGHT index is n+2.

**This is the correct argument**: when d = y', the right strategy's existence forces all
right-side Round 1 M-responses to be the boundary c. Since a_R k = a k for a k > c,
this means a k <= c for all k. So there are no RIGHT selections.
