# Phase 1 BLOCKED: Circularity in Game-Theoretic Bridge

**Task**: 155 (reynolds_pipeline_activation)
**Session**: sess_1780587236_cd56e1
**Date**: 2026-06-04
**Status**: BLOCKED -- fundamental circularity prevents game-theoretic bridge

## Executive Summary

Phase 0 (signature refactoring) completed successfully. Phase 1 (Bridge A: NF hypotheses to decomposition_agreement) is blocked by a fundamental circularity: the EF game machinery requires `formula_agreement` (agreement on ALL StaviFormulas of depth <= k), but proving this requires `stavi_expressive_completeness`, which is the very theorem whose proof contains the sorry sites.

## The Circularity

### What the game needs (formula_agreement)

`ghr93_winning_condition` includes `formula_agreement`:
```
∀ i A, stavi_depth A ≤ r → 
  stavi_temporal_truth_mu M atomMap r (tM i) A ↔ 
  stavi_temporal_truth_mu N atomMap r (tN i) A
```

This requires agreement on ALL StaviFormulas of bounded depth.

### What we can prove (char_k agreement only)

From `nf_characteristic M k 1 (fun _ => u) = nf_characteristic M' k 1 (fun _ => u')` and `char_k_correct`, we can show:
```
∀ nf_k, stavi_temporal_truth M atomMap u (char_k nf_k) ↔ 
        stavi_temporal_truth M' atomMap u' (char_k nf_k)
```

This is agreement on char_k IMAGES only, not all StaviFormulas.

### Why the gap is unclosable within the current architecture

Converting char_k-image agreement to full StaviFormula agreement requires knowing that every StaviFormula of depth ≤ k is equivalent to some char_k image. This is `stavi_expressive_completeness` -- the theorem we're inside the proof of. Circular.

## Approaches Attempted and Why Each Fails

### 1. Building decomposition_agreement from NF data
**Failed**: decomposition_agreement requires rank_type equality, which is defined as agreement on ALL StaviFormulas. Even the point challenge condition requires `ghr93_winning_condition` with formula_agreement.

### 2. Building ghr93_duplicator_wins directly
**Failed**: Same circularity. The winning condition demands formula_agreement.

### 3. Game at rank 0
**Tried**: At rank 0, formula_agreement = atom agreement (depth-0 formulas only). This CAN be built from NF data. But rank-0 game gives only atom transfer, not depth-k transfer.

### 4. Direct induction on j (depth)
**Tried**: Recursion on j: at depth 0, atoms suffice. At depth j'+1, need quantifier transfer at depth j' for one more variable. The IH gives this, BUT each step requires zone matching, which hits the sub-interval splitting problem: zone_match_witness gives w' with correct orderings relative to (x',t') but NOT relative to u'.

### 5. Well-founded recursion on (k-j)
**Tried**: Same as (4). The recursion terminates (depth decreases to 0), but zone matching at each step doesn't provide sub-interval orderings.

### 6. Sub-interval splitting lemma
**Analyzed**: Proposed lemma: given matching interval_nf_types for (x,t)/(x',t') and a split point u, find u'' in M' that splits interval types identically. **Proved FALSE** by counterexample (same as original handoff): types {A,B,τ,C} arranged differently in M vs M' can make identical splitting impossible.

## Potential Resolution Paths

### Path A: NF Type Game (most promising)
Define a simplified game that operates on NormalForm types rather than StaviFormula types. The "winning condition" would be matching NF types + orderings (not formula_agreement). This avoids the circularity because NF agreement IS provable from `char_k_correct`.

**Challenge**: The composition theorem (`ghr93_strategy_compose`) is proven for the full game. A new composition theorem would need to be proven for the NF type game. This is significant work (~200-300 lines) but avoids the circularity.

**Sketch**: 
- Define `nf_type_game_wins M M' k n x t x' t'` analogously to `ghr93_duplicator_wins` but with NF-type matching instead of formula_agreement
- Prove composition for the NF type game
- Prove that the NF hypotheses (matching NFs, orderings, interval_nf_types) imply the NF type game result
- Prove that the NF type game result implies existential transfer

### Path B: Mutual induction restructuring
Restructure the proof of `nf_characterizable_by_stavi` so that at depth k+1:
1. First prove expressive completeness at depth k (not just char_k existence)
2. Then use depth-k expressive completeness to build the full game at rank k
3. Use the game to prove existential transfer
4. Complete the proof at depth k+1

**Challenge**: This requires a major refactoring of StaviCompleteness.lean (~1000+ lines affected).

### Path C: Direct sub-interval composition (avoids game entirely)
Prove: given matching interval_nf_types for (x,t)/(x',t') and a point u with zone-matched u', the EXISTENTIAL transfer at depth j < k holds for (u,x,t)/(u',x',t') even without sub-interval type matching.

**Idea**: Instead of showing the 3-var depth-j NFs match, show directly that witnesses can be transferred. For the forward direction: given w in M with depth-j' 4-var NF chi, find w' in M' satisfying chi. Zone-match w on (x,t) to get w' with matching NF and ordering relative to (x',t'). The depth-j' 4-var NF agreement requires atoms (free from NF data) + existential transfer at depth j'-1 for 5-var extensions. By induction on j', this terminates at depth 0.

**Critical gap**: At each recursive step, the new witness is zone-matched on (x,t), not on the narrower sub-interval. So orderings relative to INTERMEDIATE points (u, previous witnesses) are NOT guaranteed. The depth-0 atom agreement requires ALL pairwise orderings to match, including those between w and u.

### Path D: Specialization to discrete orders
For discrete orders (used by `completeness_discrete`), there are no gaps (`discrete_no_gaps`). The sub-interval splitting problem might be avoidable because discrete orders have successor functions.

**Challenge**: `nf_2var_existential_transfer` is stated for general linear orders. Specializing to discrete orders would require either:
- Proving it only for discrete orders (losing generality)
- Adding `IsSuccArchimedean` as a hypothesis (changing the theorem's signature)

## Recommended Next Step

Path A (NF Type Game) is the most promising. It avoids the circularity entirely and reuses the existing game architecture conceptually. The implementation would:

1. Define `nf_type_duplicator_wins` with NF-matching winning condition
2. Prove composition for the NF type game
3. Build the NF type game from the NF hypotheses (zone_match_witness provides the strategy)
4. Extract existential transfer from the NF type game result

Estimated effort: 3-4 hours, 250-350 lines in NFGameBridge.lean.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- Phase 0 signature changes (committed)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` -- No changes yet (Phase 1 blocked before implementation)

## Key Theorems Available (sorry-free)

- `zone_match_witness` -- finds u' with matching NF + orderings relative to (x',t')
- `nf_fraisse_compression` -- atoms + existential transfer => NF equality
- `nf_agreement_from_nf_char_eq` -- NF char equality => pointwise NF agreement
- `atom_agree_from_pointwise_nf` -- pointwise NF + orderings => atom agreement
- `nvar_nf_eq_depth_zero_from_pointwise` -- depth-0 NF equality from pointwise data
- `stavi_truth_mu_at_point` -- mu-truth at actual point = standard truth
- `nf_char_eq_implies_stavi_char_agree` -- NF char + char_k => char_k-image agreement
