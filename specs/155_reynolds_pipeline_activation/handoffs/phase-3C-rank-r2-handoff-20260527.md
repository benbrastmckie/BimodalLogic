# Phase 3C Handoff: Rank-(r+2) IH Infrastructure

**Date**: 2026-05-27
**Session**: sess_1748390400_orch155
**Phase**: 3C (U(B,A) Transfer)
**Status**: IN PROGRESS -- rank-r+2 IH parameter added, sel_pn_ord still sorry'd

## What Was Done (Cycle 2)

1. **Reverted `r` in induction** (Theorem6.lean): Changed `revert h_enough x y x' y' ...` to `revert r h_enough x y x' y' ...` in `ghr93_forward_to_backward_core`. This makes `ih_gen` rank-polymorphic, allowing instantiation at r+2.

2. **Constructed `h_ih_r2`** (Theorem6.lean, line ~127): Within the `succ n` case, `ih_gen (r+2) ...` gives the forward-to-backward conversion at rank r+2. This is passed as a new parameter to `ghr93_inductive_step`.

3. **Threaded `h_ih_r2` through the call chain** (CaseAnalysis.lean):
   - Added to `ghr93_inductive_step` (line ~4189)
   - Added to `ghr93_cases_II_III_IV` (line ~4148)
   - Added to `ghr93_case_II` (line ~1214)
   
4. **Full `lake build` passes** with no regressions. Sorry count unchanged.

## What h_ih_r2 Provides

```lean
h_ih_r2 : ∀ {x₀ y₀ : ExtendedCarrier M atomMap (r + 2)}
             {x₀' y₀' : ExtendedCarrier N atomMap (r + 2)},
           x₀ ≤ y₀ → x₀' ≤ y₀' →
           (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
           ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 2) x₀ y₀ x₀' y₀' →
           ghr93_duplicator_wins N M atomMap n (r + 2) x₀' y₀' x₀ y₀
```

This converts (1+3n)-round forward games at rank r+2 into n-round backward games at rank r+2, for any sub-interval. Combined with `h_r1_univ r` (which gives (4+3n)-round forward at rank r+2), this enables constructing n-round backward games at rank r+2 on sub-intervals like [d,y']/[c,y].

## Immediate Next Action

Use `h_ih_r2` to prove sel_pn_ord. The approach requires REPLACING the e_n construction (not just proving the ordering for the existing e_n).

## Why the Existing sel_pn_ord Cannot Be Proved

**Core obstacle**: sel_pn_ord asks `a_init(k) < p_n ↔ resp_tau(k) < e_n`. These involve positions from TWO DIFFERENT games:
- a_init(k) and p_n are N-side selections (input to the backward game)
- resp_tau(k) comes from props.tau (rank-r backward game on [d,y']/[c,y])
- e_n comes from the d-compatible forward game on [x,y]/[x',y']

No single game has all four positions. The forward game gives `resp_tau(k) < e_n ↔ a'_big(k) < p_n` where a'_big(k) is a FRESH N-response, NOT a_init(k). And a'_big(k) having the same rank-r type as a_init(k) does NOT imply they're on the same side of p_n (counterexample in dense orders).

## Implementation Plan for Next Cycle

**Goal**: Replace Steps 2-3d (lines ~1227-1310 approximately) with a rank-r+2 based construction.

### Step A: Construct rank-r+2 backward game on [d,y']/[c,y]

```lean
-- Get forward game at rank r+2 on [c,y]/[d,y']
have h_fwd_cy_r2 := h_r1_univ r props.hcy.le props.hdy'.le  -- wrong signature
-- Actually: h_r1_univ r with x₁=c, y₁=y, x₁'=d, y₁'=y' needs c ≤ y and d ≤ y'
-- Result: (4+3n)-round forward at rank r+2 on rank_embed'd [c,y]/[d,y']

-- Apply round_mono to get (1+3n) rounds
have h_fwd_cy_1p3n := ghr93_duplicator_wins_round_mono (show 1+3*n ≤ 4+3*n by omega) ... h_fwd_cy_r2

-- Need point existence in N's [rank_embed d, rank_embed y'] for h_ih_r2:
-- p_n is a carrier point in [d,y'], so extendPoint p_n ∈ [rank_embed d, rank_embed y']
have h_pt_dy'_r2 : ∃ p, inClosedInterval (rank_embed ... d) (rank_embed ... y') (extendPoint p) := ...

-- Apply h_ih_r2 to get n-round backward at rank r+2
have tau_r2 := h_ih_r2 (rank_embed_le ... d y').mpr props.hdy') 
                       (rank_embed_le ... c y).mpr props.hcy')
                       h_pt_dy'_r2 h_fwd_cy_1p3n
-- tau_r2 : ghr93_duplicator_wins N M atomMap n (r+2) 
--           (rank_embed d) (rank_embed y') (rank_embed c) (rank_embed y)
```

### Step B: Play tau_r2 with rank_embed(a_init) and challenge with some M-point

tau_r2 gives n-round backward at rank r+2. Play with:
- N-side selections: `fun k => rank_embed (a_init k)` (all in [rank_embed d, rank_embed y'])
- Get M-side responses: `resp_r2 : Fin n → ExtendedCarrier M atomMap (r+2)` in [rank_embed c, rank_embed y]
- M-side challenge: some carrier point in [c,y]... 

**Problem**: The challenge point determines what ordering information we get. If we challenge with e_n_pt (from the forward game), we get ordering between a_init(k) and the N-response b (unknown) vs resp_r2(k) and e_n. But b ≠ p_n.

### Step C: The resolution — redefine e_n

Instead of getting e_n from the forward game, DEFINE e_n from the rank-r+2 backward game itself:
1. Play tau_r2 with rank_embed(a_init(0)),...,rank_embed(a_init(n-1))
2. For the Round 2 challenge, we CANNOT choose p_n (it's on the N-side, not M-side)
3. The game structure means the M-side challenge goes AFTER the selections

**Alternative**: Instead of a rank-r+2 backward game, build a (rank-r+2, n+1-round) game that includes p_n. But n+1-round backward requires more rounds than available.

### The actual GHR93 approach (simplified for formalization):

GHR93 has tau preserving formulas at rank r+4. At rank r+4, `U(B, sf_top)` (rank r+1) is within the formula preservation range. The proof goes:

1. N |= U(B, sf_top) at a_init(n-1) (witnessed by p_n: p_n > a_init(n-1), p_n satisfies B)
2. tau_r4 preserves U(B, sf_top) from a_init(n-1) to resp_tau_r4(n-1) in M
3. M |= U(B, sf_top) at resp_tau_r4(n-1), so ∃ z > resp_tau_r4(n-1) in M with M |= B(z)
4. Define e_n = z

This gives e_n > resp_tau_r4(k) for all k < n (since resp_tau_r4(n-1) ≥ resp_tau_r4(k) by tau ordering and the fact that a_init is sorted: a_init(n-1) ≥ a_init(k) → resp_tau_r4(n-1) ≥ resp_tau_r4(k)).

**Key requirement**: We need formulas materialized as StaviFormula. B = X_{a_n} = conjunction of all rank-r formulas true at a_n. This requires the formula materialization infrastructure from TypeFormulas.lean.

### Remaining obstacles:

1. **Formula materialization**: Need to build B as a concrete StaviFormula of depth r from TypeFormulas.lean's `rank_type` infrastructure.

2. **U(B, sf_top) truth evaluation**: Need `stavi_temporal_truth_mu N atomMap (r+2) (rank_embed(a_init(n-1))) (std_untl B sf_top)` to hold, witnessed by rank_embed(p_n).

3. **Transfer through tau_r2**: tau_r2 preserves formulas at rank r+2. U(B, sf_top) has depth max(depth B, depth sf_top) + 2 = r + 2 (since depth B = r). So the formula is EXACTLY at the preservation boundary.

4. **Extracting witness**: From M |= U(B, sf_top) at resp_r2(n-1), extract z : M.carrier with z > resp_r2(n-1) and M |= B at z.

5. **Projecting from rank r+2 to rank r**: z is a carrier point (from U semantics — the witness is an actual point, not a gap). So `extendPoint z` works at both rank r and rank r+2.

6. **Sorting assumption**: Need a_init(0) ≤ ... ≤ a_init(n-1) (can use ghr93_winning_condition_perm for WLOG).

7. **Replacing resp_tau with resp_r2**: The downstream code uses resp_tau heavily. If we replace it with resp_r2 (projected to rank r), we need to show resp_r2 projected values work at rank r.

## Estimated Remaining Work

The remaining implementation requires:
- Building B from TypeFormulas.lean (rank_type materialization) -- ~50-80 lines
- Constructing std_untl B sf_top and proving truth at a_init(n-1) -- ~30-50 lines
- Transferring through tau_r2 -- ~20-30 lines
- Extracting witness and defining e_n -- ~20-30 lines
- Proving sel_pn_ord from the construction -- ~10-20 lines
- Replacing resp_tau references with resp_r2 projected values -- ~100-200 lines (large because downstream code uses tau ordering extensively)

Total: ~250-400 lines of changes, plus understanding TypeFormulas.lean API.

## Files Modified This Cycle

- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean`: revert r, construct h_ih_r2
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`: add h_ih_r2 param to 3 theorems
- `specs/155_reynolds_pipeline_activation/plans/36_ghr93-classical-plan.md`: Phase 3C marked BLOCKED (will need update)

## Key Files to Read Next Cycle

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/TypeFormulas.lean` -- rank_type, formula materialization
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Defs.lean` -- stavi_temporal_truth_mu, std_untl
- Lines 1227-1340 of CaseAnalysis.lean -- the section to replace
