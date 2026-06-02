# Phase 2 Handoff: Depth Mismatch Analysis

**Task**: 155 (reynolds_pipeline_activation)
**Phase**: 2 (EF Game Bridge -- plan v61)
**Session**: sess_1780425483_f420ac
**Date**: 2026-06-02
**Status**: BLOCKED -- depth mismatch in Bridge A prevents the approach described in plan v61

## Summary

Extensive analysis of the EF Game Bridge approach (plan v61 Phase 2) reveals a fundamental depth mismatch that blocks the proposed proof strategy. The plan proposes bridging from depth-k NFs on M.carrier to rank_type (depth-k StaviFormula agreement) on ExtendedCarrier. This bridge is not possible because StaviFormulas of depth k have FO depth up to 2k, while depth-k NFs only capture FO depth up to k.

## The Three Root Sorries

1. **Line 2347** in `nf_2var_existential_transfer` (forward direction): needs 4-var existential transfer at depth j'
2. **Line 2429** in `nf_2var_existential_transfer` (backward direction): symmetric 
3. **Line 2787** in `nf_exist_sf_guarded_backward`: depends on sorry-free `nf_2var_from_interval_data`

All three trace to the sub-interval splitting problem: zone matching finds a witness with matching 1-var NF and orderings, but cannot guarantee matching sub-interval types.

## Depth Mismatch Details

### What plan v61 proposes (Bridge A)
```
nf_characteristic M k 1 (fun _ => x) = nf_characteristic M' k 1 (fun _ => x')
  =>  rank_type M atomMap k (extendPoint x) = rank_type M' atomMap k (extendPoint x')
```

### Why it fails
- `rank_type M atomMap k (extendPoint x)` = { A : StaviFormula | stavi_depth A <= k AND stavi_temporal_truth_mu M atomMap k (extendPoint x) A }
- By `stavi_truth_mu_at_point`, for actual points: stavi_temporal_truth_mu = stavi_temporal_truth on M
- A StaviFormula A of stavi_depth k has `stavi_fo_depth A <= 2*k` (proved: `stavi_fo_depth_le_twice_depth`)
- The depth-k 1-var NF captures FO formulas of depth <= k, NOT depth <= 2k
- Therefore depth-k NF agreement does NOT determine rank_type at depth k

### Why char_k doesn't help
- `char_k_correct` gives: agreement on `char_k nf_k` formulas iff NF agreement
- But char_k formulas are SPECIFIC StaviFormulas; they don't cover ALL depth-k StaviFormulas
- rank_type requires agreement on ALL StaviFormulas of depth <= k
- Getting all depth-k StaviFormulas from char_k IS expressive completeness (which is sorry'd)

### Why nf_profile doesn't help cross-structure
- `nf_profile(t) = nf_characteristic (extendedStructureWithMu M atomMap k) (2*k) 1 (fun _ => t)`
- Within a single structure, `nf_profile_determines_rank_type` works
- Cross-structure: depth-k NF on M does NOT determine depth-(2k) NF on muSig structure
- Gap structures in M's and M's ExtendedCarrier are independent

## Private Definition Constraint

All key definitions are `private` to StaviCompleteness.lean:
- `interval_nf_types`, `zone_match_witness`, `nf_fraisse_compression`
- `nf_2var_existential_transfer`, `nf_2var_from_interval_data`
- `nf_exist_sf_guarded_backward`

Any implementation must work WITHIN StaviCompleteness.lean.

## Viable Approaches

### Approach A: Depth-bounded char_k (recommended)
Modify `nf_characterizable_by_stavi` to prove `stavi_depth (char_k nf_k) <= f(k)` for a computable f. At depth 0, char_k is a conjunction of atom literals (depth 0). At depth k+1, the formula includes exist_sf sub_nf which uses Until/Since (+2 depth) and char_k. So f(k+1) = f(k) + 2, giving f(k) = 2k. Then the game at rank 2k gives char_k agreement. This requires:
1. Track depth bounds through the inductive construction
2. Possibly restructure the characterization formula to minimize depth
3. Run the game at rank 2k instead of k

### Approach B: Custom NF-game (alternative)
Define a game that uses NF types directly instead of StaviFormulas. Prove composition for this NF-game on M.carrier. Avoids the depth mismatch entirely. Requires ~200-300 lines of new infrastructure.

### Approach C: Direct Doets lemma approach
Prove the existential transfer using `doets_lemma_1_1` on M at the right depth, combined with a strengthened induction that carries interval data for all sub-intervals.

## Immediate Next Action

Research whether a depth bound `stavi_depth (char_k nf_k) <= 2k` can be proved, and whether running the game at rank 2k is feasible given the existing infrastructure.
