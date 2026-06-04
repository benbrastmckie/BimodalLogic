# Phase 1 Handoff: NF-Game Bridge Analysis

**Task**: 155 (reynolds_pipeline_activation)
**Session**: sess_1780587236_cd56e1
**Date**: 2026-06-04
**Status**: BLOCKED - deep analysis complete, implementation path identified but not executed

## What Was Analyzed

Extensive analysis (90+ minutes) of the sorry sites in `nf_2var_existential_transfer` (StaviCompleteness.lean lines 2347, 2429) and the downstream sorry at line 2787.

## The Core Problem

The sorry sites need **4-variable existential transfer at depth j'** for a 3-point base (u,x,t)/(u',x',t'):

```
(exists w, nf_eval_nf M j' 4 (w :: u :: x :: t) sub_nf) <->
(exists w', nf_eval_nf M' j' 4 (w' :: u' :: x' :: t') sub_nf)
```

where j' + 1 <= j < k, and u/u' were obtained by zone matching from the 2-point base (x,t)/(x',t').

## Why Every Direct Approach Fails

### 1. Strong induction on j (for the same base)
The IH gives transfer for the 2-point base (x,t), not the 3-point base (u,x,t). Different bases, wrong arity.

### 2. Strong induction on j (generalized to n-point bases)
Requires showing that zone matching extends to wider bases. At depth 0, need atom agreement at ALL pairs including (w', u'). Zone matching w against (x,t) gives w' with orderings relative to (x',t') but NOT relative to u'. When w and u are in the SAME zone of (x,t), their relative ordering in M' is NOT determined. This is the **sub-interval problem**.

### 3. Strong induction on k (outer parameter)
Same sub-interval problem at each level: sub-interval types for (x,u)/(x',u') are not derivable from interval types for (x,t)/(x',t').

### 4. Splitting zone match (direct combinatorial)
PROVED FALSE: matching interval types at depth k does NOT guarantee a splitting witness. Counterexample: types {A, B, tau, C} arranged differently in M vs M' (e.g., x--A--B--u(tau)--C--t vs x'--A--C--u'(tau)--B--t'). Same type set, different sub-interval types.

### 5. Using nf_fraisse_compression for the 3-point base
Requires existential transfer at ALL depths < j' for 4-var extensions of (u,x,t), which is the SAME problem one level down. Circular.

## Why the EF Game IS Necessary

The EF game (ghr93_duplicator_wins) handles sub-interval splitting through its **compositional strategy** (ghr93_strategy_compose, Proposition 7). Duplicator chooses the split point to maintain sub-interval invariants at EVERY sub-interval simultaneously. This is what purely pointwise zone matching cannot achieve.

## The Viable Implementation Path

### Prerequisite: Add char_k as a parameter

The key breakthrough: `char_k` (the StaviFormula characterizing each depth-k NF) provides a bidirectional bridge between NF evaluation on M.carrier and StaviFormula truth on ExtendedCarrier. char_k is available in the calling context:

- `nf_exist_sf_guarded_backward` (sorry at line 2787) already takes `char_k` and `char_k_correct` as parameters
- `nf_2var_existence_characterizable` (which calls the sorry chain) also has them
- `nf_characterizable_by_stavi` at depth k+1 provides char_k from the IH at depth k

**Action**: Add `atomMap`, `char_k`, `char_k_correct` as parameters to:
- `nf_2var_existential_transfer` (signature change)
- `nf_2var_from_interval_data` (signature change)
- Update all callers (nf_2var_transfer, nf_exist_sf_guarded_backward)

### Bridge A: NF hypotheses -> ghr93_duplicator_wins

With char_k available:

1. Convert NF agreement to StaviFormula agreement using char_k_correct:
   - nf_characteristic M k 1 x = nf_characteristic M' k 1 x' implies
     forall A : StaviFormula with depth <= k, stavi_temporal_truth M atomMap x A <-> stavi_temporal_truth M' atomMap x' A
   - This works via nf_char_eq_implies_stavi_char_agree (already in NFGameBridge.lean)
   - For general StaviFormulas (not just char_k images), need a separate argument using the fact that char_k formulas span all depth-k types

2. Convert interval_nf_types to interval_types on ExtendedCarrier:
   - interval_nf_types M k x t = set of depth-k 1-var NFs realized between x and t
   - interval_types M atomMap k (extendPoint x) (extendPoint t) = set of rank_types realized between extendPoint x and extendPoint t
   - The connection: rank_type at extendPoint(u) is determined by the StaviFormulas true at u, which via char_k is determined by the 1-var NF
   - Need: rank_type M atomMap k (extendPoint u) is a function of nf_characteristic M k 1 u (when char_k is available)

3. Construct decomposition_agreement from the above
4. Apply ghr93_decomposition_implies_game to get ghr93_duplicator_wins

### Bridge B: ghr93_duplicator_wins -> NF existential transfer

1. Use the game with n >= 1 rounds
2. Select u as Round 1 element; Duplicator responds with u'_game
3. For point challenge w (or w'), get matching w' (or w) with winning condition
4. Winning condition gives formula_agreement at all game_tuple positions
5. At actual points, formula_agreement gives stavi_temporal_truth agreement
6. Via char_k_correct, convert to nf_eval_nf agreement at depth k
7. nf_agreement_monotone gives agreement at depth j < k
8. This gives the 4-var existential transfer

### Estimated Effort

- Signature changes: ~30 minutes (propagating char_k through the call chain)
- Bridge A (NF -> game): ~3 hours (the hardest part; connecting interval_nf_types to interval_types, building decomposition_agreement)
- Bridge B (game -> NF): ~2 hours (extracting formula agreement, converting to NF)
- Sorry replacement: ~30 minutes (plugging Bridge A + B into the sorry sites)
- Verification: ~30 minutes

Total: ~6-7 hours remaining

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` - sorry sites at lines 2347, 2429, 2787
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` - bridge lemmas (to be extended)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Decomposition.lean` - decomposition_agreement, ghr93_decomposition_implies_game
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean` - ghr93_strategy_compose (Proposition 7)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CustomGame.lean` - ghr93_duplicator_wins, winning conditions
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapDetection.lean` - stavi_truth_mu_at_point
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/TypeFormulas.lean` - rank_type, interval_types

## Key Theorems Available (sorry-free)

- `ghr93_strategy_compose` - Composes sub-interval strategies
- `ghr93_decomposition_implies_game` - decomposition_agreement -> ghr93_duplicator_wins
- `ghr93_game_implies_decomposition` - ghr93_duplicator_wins -> decomposition_agreement
- `stavi_truth_mu_at_point` - mu-relativized truth at actual points = standard truth
- `nf_agreement_from_nf_char_eq` - NF char equality -> pointwise NF agreement
- `nf_char_eq_implies_stavi_char_agree` - NF char equality + char_k -> StaviFormula agreement
- `nf_fraisse_compression` - atoms + existential transfer -> NF equality

## Immediate Next Action

1. Add `atomMap`, `char_k`, `char_k_correct` to `nf_2var_existential_transfer` signature
2. Propagate the new parameters through the call chain
3. Verify the build still succeeds with sorries
4. Then implement Bridge A (hardest part)
