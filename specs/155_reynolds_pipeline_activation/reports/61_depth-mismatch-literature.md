# Depth Mismatch Literature Analysis

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-06-02
**Purpose**: Definitive analysis of the Phase 2 blocker against GHR93/GHR94 prior art

## Executive Summary

The three sorry sites (lines 2347, 2429, 2787 in StaviCompleteness.lean) all trace to `nf_2var_from_interval_data`, which requires **sub-interval type preservation** — a property that CANNOT be derived from enclosing interval data + endpoint NFs. This is not a depth mismatch bug; it is a **structural limitation of the direct NF induction approach**. GHR93 resolves this through EF game composition (Proposition 7), where Duplicator's strategy naturally preserves sub-interval data via decomposition formula matching.

## The Root Problem: Sub-Interval Data Is Not Derivable

### What the proof needs

`nf_2var_existential_transfer` (line 2214) must prove: given a 2-point config (x,t) with matching depth-k 1-var NFs and interval_nf_types, for each depth j < k, 3-var existential transfer holds (adding a third variable u).

At depth j'+1 (line 2347), after zone-matching u to u', we need the 3-var depth-j' NF of (u,x,t) to match (u',x',t'). By `nf_fraisse_compression`, this requires 4-var existential transfer at depth j'-1, creating a 5-var problem at depth j'-2, etc.

The recursion terminates at depth 0 (atoms only). Total variables = 2 + k. But at EACH level, when we add a new variable w via zone matching, we need **interval_nf_types for the new sub-intervals** (x,w), (w,t), (w,u), etc.

### Why sub-interval data is not derivable

Consider: `interval_nf_types M k x u = {nf_characteristic M k 1 (fun _ => v) | x < v < u}`.

If u is between x and t, the types in (x,u) are a SUBSET of those in (x,t). But knowing interval_nf_types(x,t) = interval_nf_types(x',t') and nf(u) = nf(u') does NOT determine interval_nf_types(x,u) = interval_nf_types(x',u'). The points between x and u could be differently distributed even when the enclosing interval types match.

**Concrete counterexample**: M has x < a < b < u < t with types {τ_a, τ_b}. M' has x' < b' < a' < u' < t' with types {τ_a, τ_b}. Both intervals (x,t) and (x',t') have the same type set. But interval (x,u) = {τ_a, τ_b} while interval (x',u') = {τ_b} only.

This is the **fundamental structural limitation** of the direct NF approach.

## How GHR93 Resolves This

### Proposition 7 (GHR93, p.114-115)

GHR93's composition argument works with EF **games**, not NFs directly. The game G_{n;r}(M,xy; N,x'y') has n elements and rank r. The winning condition (Definition 8.7, p.112) requires:
1. Same order type for the tuple
2. Gap/point agreement
3. Rank-r temporal formula agreement (via rank_type)

When V picks α in some interval (x_i, x_{i+1}), Duplicator responds with e using her strategy for G_{f(n+1);r}. By Lemma 11 (p.113), this preserves all n;r-decomposition formulas, which EXPLICITLY encode interval types for ALL sub-intervals. The sub-interval data is preserved because the decomposition formula φ(x_1, x_2) from Definition 8.8.2 includes:

> (b) μ(z) ∧ a < z < b → B^μ(z), where a < b are adjacent elements... and B is a temporal formula of rank ≤ r.

This clause ensures that the types realized BETWEEN any adjacent pair match. When Duplicator maintains decomposition formula agreement, sub-interval data is preserved automatically.

### Theorem 6 (GHR93, p.113)

Provides the forward-backward game transfer: winning G_{1+3n; r+4n} forward → winning G_{n;r} backward. This is crucial because Proposition 7 needs strategies in BOTH directions.

### Depth/Rank relationship in GHR93

- **Rank** (Definition 8.2, p.108): max depth of temporal connective nesting. So rank r means temporal nesting depth r.
- A StaviFormula of stavi_depth r has FO depth ≤ 2r (proved by `stavi_fo_depth_le_twice_depth` in the Lean code).
- rank_type at depth r captures StaviFormulas of depth ≤ r, hence FO formulas of depth ≤ 2r.
- Depth-k 1-var NF captures FO formulas of depth ≤ k.
- Therefore: depth-k NF agreement → rank_type agreement at depth ⌊k/2⌋.

## The Circularity Problem with the Game Bridge

Using the game infrastructure (Composition.lean) to prove `nf_2var_from_interval_data` creates a circularity:

1. `nf_2var_from_interval_data` is used inside `nf_characterizable_by_stavi` (line 3060)
2. The game bridge needs: NF agreement → rank_type agreement (= char_k completeness)
3. char_k completeness IS `nf_characterizable_by_stavi`

However, this circularity is breakable because `nf_characterizable_by_stavi` proceeds by induction on k. At step k+1:
- char_k (depth k) is already complete (by IH)
- char_k has stavi_depth ≈ k
- So depth-k NF agreement → rank_type at depth ⌊k/2⌋ via char_{⌊k/2⌋}
- The game at rank ⌊k/2⌋ gives depth-k 2-var NF agreement

**The depth relationship works**: for the game at rank r = ⌊k/2⌋:
- Hypotheses need rank_type at depth r: available from depth-k NFs (since k ≥ 2r)
- interval_types at depth r: derivable from interval_nf_types at depth k
- Game gives standard EF G_k winning (via Proposition 7)
- G_k gives depth-k FO agreement (via Proposition 5)
- Depth-k FO agreement = depth-k 2-var NF agreement ✓

## The Private Definition Constraint

All key definitions are `private` to StaviCompleteness.lean:
- `interval_nf_types`, `zone_match_witness`, `nf_fraisse_compression`
- `nf_2var_existential_transfer`, `nf_2var_from_interval_data`

Any bridge code must work WITHIN StaviCompleteness.lean, or these must be made non-private.

**Recommendation**: Make `interval_nf_types` and supporting types non-private. The NF-to-game bridge naturally belongs in NFGameBridge.lean (which already exists as a skeleton).

## GHR94 Ch9 Alternative: Separation-Based Approach

GHR94 Ch9 (Theorem 9.1.1, p.8-11) proves expressive completeness WITHOUT games, using **separation**:

1. Induction on quantifier depth m
2. ∃z ψ(t,z) decomposed into ∨_j [α_j(t) ∧ ∃z ψ_j(z, Q, R_=, R_>, R_<)]
3. IH gives temporal formula for each ψ_j (depth ≤ m)
4. Separation eliminates the extra predicates R_=, R_>, R_<

This approach avoids sub-interval data entirely — it works through separation of future/past/present components. However, it requires the **separation property** for the logic, which is a separate theorem (and may itself be substantial to prove).

## Recommended Resolution

### Option A: Game Bridge (Recommended — ~400-600 lines)

1. Make `interval_nf_types` non-private
2. In NFGameBridge.lean, prove:
   - `nf_agreement_implies_rank_type`: depth-k NF → rank_type at depth ⌊k/2⌋ (uses char_k from IH)
   - `interval_nf_types_implies_interval_types`: interval_nf_types at depth k → interval_types at depth ⌊k/2⌋
   - `game_winning_implies_nf_agreement`: G_k standard EF winning → depth-k 2-var NF agreement
3. In StaviCompleteness.lean, replace the sorry'd `nf_2var_from_interval_data` with a call through the bridge:
   - Convert hypotheses to game data (via NFGameBridge)
   - Apply `ghr93_strategy_compose` from Composition.lean
   - Convert game result back to NF agreement

**Key insight**: The bridge uses char_k from the INDUCTION HYPOTHESIS (depth k), not from the theorem being proved (depth k+1). So there's no circularity.

### Option B: Direct Game Embedding (~200-400 lines)

Keep everything inside StaviCompleteness.lean:
1. Define a local game using NF types instead of StaviFormulas
2. Prove composition for this NF-game (mirrors Composition.lean but for NFs)
3. Use the NF-game to prove `nf_2var_from_interval_data`

**Advantage**: No private def changes needed.
**Disadvantage**: Duplicates game composition logic.

### Option C: Separation Approach (~500-800 lines)

Replace the NF-based proof structure with GHR94 Ch9's separation-based approach.

**Advantage**: Avoids sub-interval problem entirely.
**Disadvantage**: Requires proving separation property; major restructuring.

## Literature References

| Source | Section | Content |
|--------|---------|---------|
| GHR93 (p.108) | Definition 8.2 | Rank = temporal nesting depth |
| GHR93 (p.112) | Definition 8.7 | Custom game G_{n;r} definition |
| GHR93 (p.113) | Lemma 11 | G_{n;r} ↔ decomposition formula agreement |
| GHR93 (p.113) | Theorem 6 | Forward-backward game transfer |
| GHR93 (p.114) | Proposition 7 | Strategy composition |
| GHR93 (p.115) | Corollary 5 | rank agreement → FO agreement |
| GHR94 Ch9 (p.8) | Theorem 9.1.1 | Separation-based expressive completeness |
| Lean code | StaviCompleteness.lean:464 | stavi_fo_depth ≤ 2 × stavi_depth |
| Lean code | Composition.lean:40 | ghr93_strategy_compose (sorry-free, 626 lines) |
