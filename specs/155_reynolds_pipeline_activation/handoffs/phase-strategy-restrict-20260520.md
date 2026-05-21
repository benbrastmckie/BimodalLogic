# Phase: Strategy Restriction Sorry Closing - Handoff

## Session
- Session ID: sess_1779304083_f28ee0
- Date: 2026-05-20

## What Was Done

### Closed Sorries (2 of 3 targeted)

1. **EFGames.lean `ghr93_strategy_restrict_left` (was line 1900)**:
   - Sorry was: `a'_res i <= a'_full(n)` -- proving Duplicator's restricted responses are contained in [x',d]
   - Fix: Added `h_pt` hypothesis (existence of N-carrier point in [x',y']), used it to instantiate the winning condition via `hwin_full`, extracted `same_order_type` at game_tuple indices (n+1) and (i+1), and derived ordering from `a_pad(i) <= c = a_pad(n)`
   - Key insight: `same_order_type` at game_tuple selection indices gives `a_pad(n) < a_pad(i) iff a'_full(n) < a'_full(i)`. Since `a_pad(i) <= a_pad(n)`, contrapositive gives `a'_full(i) <= a'_full(n)`.

2. **EFGames.lean `ghr93_strategy_restrict_right` (was line 2100)**:
   - Same pattern, symmetric case. Added `h_pt`, used same approach at game_tuple indices (i+2) and (1).

### Updated Call Sites
- ExpressivenessGeneral.lean lines 307-311: Added `h_pt` argument to both `ghr93_strategy_restrict_left` and `ghr93_strategy_restrict_right` calls.

### Added Hypotheses
- `h_pt_M : exists p : M.carrier, inClosedInterval x y (extendPoint p)` added to:
  - `ghr93_case_I` (for winning condition transfer)
  - `ghr93_inductive_step` (propagation)
  - `ghr93_forward_to_backward` (entry point)
- `h_pt_M` is derived from the forward game when passing through induction: if the forward game can win on [x0,y0] vs [x0',y0'], playing Round 1 with any element and Round 2 with an N-point gives an M-point in [x0,y0].

## Remaining Sorry (1 of 3)

### Case I Winning Condition Transfer (ExpressivenessGeneral.lean lines 579, 592)

**Problem**: Combining sigma's and tau's sub-game winning conditions into the full (n+1)-round winning condition.

**Why it's hard**:
1. **Index mapping**: sigma's game_tuple indices (Fin(L.card+3)) must be mapped to full game indices (Fin(n+4)) via the L-partition embedding. Similarly for tau. The embeddings are non-contiguous.
2. **Density requirement**: To extract tau's ordering data in the left case (b_sp <= c), we need an M.carrier point in [c,y] to instantiate `hwin_R`. We have `h_pt_M` giving a point in [x,y], but it might be in [x,c) only. A density hypothesis (every non-degenerate ExtendedCarrier interval contains an M.carrier point) would resolve this.
3. **Cross-partition ordering**: For (L-index, R-index) pairs, the ordering follows from interval containment + sigma's strict inequality. But the proof requires careful game_tuple simplification.

**What's needed to close**:
1. Add a density hypothesis to the theorem chain, OR derive point existence from the forward game structure
2. ~200 lines of index case analysis for same_order_type, gap_point_agreement, formula_agreement across all index pair types (LL, RR, LR, RL, boundary, challenge point)

## Immediate Next Action

To close the Case I winning condition transfer:
1. Add `h_pt_density : forall a b, a < b -> exists p, inClosedInterval a b (extendPoint p)` to `ghr93_forward_to_backward` and propagate to `ghr93_case_I`
2. Use it to get a point in [c,y] for tau's Round 2 (left case) and [x,c] for sigma's Round 2 (right case)
3. With both sigma and tau winning conditions available, prove each component by index case analysis

## Build Status
- `lake build` passes (1647 jobs)
- No new sorries introduced (net: -2 sorries in EFGames.lean)
- No vacuous definitions, no new axioms
