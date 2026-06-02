# Phase 2 Blocker Resolution: Interval-Splitting Problem

**Task**: 155 (reynolds_pipeline_activation)
**Status**: BLOCKER ANALYSIS
**Date**: 2026-06-02

## Root Cause

The sorries at StaviCompleteness.lean lines 2347 and 2429 are in `nf_2var_existential_transfer`, which tries to prove existential transfer at depth j for 3-var NFs (u,x,t)/(u',x',t') from the bridge lemma hypotheses. At depth j'+1, the proof needs 4-var existential transfer at depth j' — which in turn needs 5-var at depth j'-1, etc. This recursive descent over variable count is exactly the iterated game argument from GHR93.

**Why direct NF induction fails**: Zone matching finds u' with matching 1-var NF and correct orderings relative to (x',t'), but the **sub-interval types** of (x',u') are NOT determined by the interval types of (x',t'). A type realized in (x,t) might appear in (u,t) but not in (x,u), so the zone-match witness u' has undetermined internal structure.

## Available Infrastructure

| Component | File | Lines | Sorry-free | What it provides |
|-----------|------|-------|------------|------------------|
| `nf_fraisse_compression` | StaviCompleteness.lean:2006 | ~33 | Yes | atoms + ∀j<k transfer → depth-k NF equality |
| `zone_match_witness` | StaviCompleteness.lean:2044 | ~140 | Yes | Given hypotheses, finds u' with matching 1-var NF and orderings |
| `nf_agreement_from_nf_char_eq` | NFGameBridge.lean:57 | ~12 | Yes | 1-var NF equality → 1-var NF eval agreement |
| `nvar_nf_eq_depth_zero_from_pointwise` | NFGameBridge.lean:159 | ~10 | Yes | Depth-0 n-var NF from pointwise data |
| `atom_agree_from_pointwise_nf` | NFGameBridge.lean:139 | ~18 | Yes | n-var atom agreement from pointwise 1-var NF + orderings |
| `ghr93_strategy_compose` | Composition.lean:40 | ~190 | Yes | Strategy composition at pivot point |
| `ghr93_game_iff_decomposition` | Decomposition.lean:302 | ~12 | Yes | Game ↔ decomposition agreement |
| `nf_profile_determines_rank_type` | CharacteristicFormula.lean:250 | ~12 | Yes | Same NF profile → same rank_type |
| `stavi_temporal_truth_mu` | TypeFormulas.lean:304 | — | Yes | Mu-relativized Stavi truth on ExtendedCarrier |

## Approach Analysis

### Approach A: EF Game Bridge (recommended)

Build two bridge lemmas connecting the NF world (M.carrier, depth-k NFs) to the game world (ExtendedCarrier, rank-r types):

**Bridge A** (~150-200 lines): From NF hypotheses → `ghr93_duplicator_wins`
- Key challenge: NF hypotheses talk about `nf_characteristic M k 1` on `M.carrier`, but the game operates on `ExtendedCarrier M atomMap r` with `stavi_temporal_truth_mu` at depth r.
- Need: relationship between `nf_characteristic M k 1 (fun _ => x)` and `rank_type M atomMap r (extendPoint x)`.
- The connection exists via `nf_profile_determines_rank_type` + `nf_profile_determines_stavi_truth` (CharacteristicFormula.lean), but the depth parameters differ: NF uses depth k, game uses rank r (where the Stavi depth r corresponds to quantifier depth 2r on the mu-extended structure).
- Requires establishing: `nf_characteristic M k 1 (fun _ => x) = nf_characteristic M' k 1 (fun _ => x')` implies `rank_type M atomMap k (extendPoint x) = rank_type M' atomMap k (extendPoint x')` when `r = k`.
- Also need: `interval_nf_types M k x t = interval_nf_types M' k x' t'` implies `interval_types M atomMap k (extendPoint x) (extendPoint t) = interval_types M' atomMap k (extendPoint x') (extendPoint t')`.

**Bridge B** (~100-150 lines): From `ghr93_duplicator_wins` → NF agreement
- Need: the game winning condition (formula_agreement at depth r) implies `nf_characteristic M k n env_M = nf_characteristic M' k n env_M'`.
- The winning condition gives `stavi_temporal_truth_mu M atomMap r (tM i) A ↔ stavi_temporal_truth_mu N atomMap r (tN i) A` for all StaviFormulas A of depth ≤ r.
- Need to convert this to `nf_eval_nf` agreement. This requires the characteristic formula `char_k` machinery and the Stavi completeness theorem at lower depths.
- Actually, for the specific use in `nf_2var_from_interval_data`, we only need 2-var NF agreement, and we could potentially get this more directly.

**Estimated effort**: 300-400 lines total. Uses existing sorry-free infrastructure (Composition.lean, Decomposition.lean, CharacteristicFormula.lean).

**Risk**: The depth parameter mismatch between the NF world (depth k) and the game world (rank r, which uses depth 2r on muSig) is a significant complexity factor. The connection requires careful handling of the mu-relativization.

### Approach B: Interval-Splitting Zone Match (NOT recommended)

Prove directly that zone matching can be strengthened to preserve sub-interval types. This would require proving:
```
interval_nf_types M k x u = interval_nf_types M' k x' u'
interval_nf_types M k u t = interval_nf_types M' k u' t'
```
from the hypotheses that include `interval_nf_types M k x t = interval_nf_types M' k x' t'`.

**Why this fails**: Zone matching places u' in the correct zone (e.g., x' < u' < t'), but the types realized in (x',u') vs (u',t') are NOT determined by the types in (x',t'). The partition of interval types into sub-intervals depends on the specific model, not just the type set. This is precisely the gap that the game argument fills via its compositional structure.

### Approach C: Restructure to Avoid `nf_2var_existential_transfer` (NOT recommended)

The only known alternative is to replace `nf_fraisse_compression` with a different proof strategy for `nf_2var_from_interval_data`. Possible routes:
- Use `interval_2var_nf_types` (line 1847) which encodes richer spatial data (2-var NFs rather than 1-var). But this shifts the problem to proving interval_2var_nf_types agreement, which is equally hard.
- Temporal formula decomposition: express the 2-var NF as a Boolean combination of temporal formulas, then use the existing StaviFormula machinery. But this essentially re-derives the game argument through a different encoding.

**Why this fails**: Any approach that avoids the game composition ultimately needs to solve the same sub-interval splitting problem.

### Approach D: Direct Double Induction on (k, n) (NOT recommended)

Prove a general `nvar_nf_from_pointwise_data` theorem by joint induction on depth k and variable count n. At depth k+1 with n variables, existential transfer needs (n+1)-var agreement at depth k, which would come from the induction hypothesis.

**Why this might work**: The descent is bounded — after at most k steps, depth reaches 0 and the n-var NF is pure atom agreement (already proved in NFGameBridge.lean).

**Why this is harder than it looks**: Each induction step needs zone-matching at the appropriate depth, and the zone-matching hypotheses (interval types, above/below) need to be maintained through the induction. The hypotheses for the inner step are NOT the same as the outer hypotheses — they involve sub-intervals of the original interval, and these sub-interval types are exactly what we don't have.

This is mathematically equivalent to the game argument but without the compositional structure that makes it manageable.

## Recommendation: Approach A (EF Game Bridge)

**Approach A** is the correct path because:

1. **Mathematical correctness**: This IS the GHR93 proof. The game composition in Composition.lean already handles the sub-interval splitting correctly.

2. **Infrastructure exists**: The sorry-free game infrastructure (Composition.lean, Decomposition.lean, CharacteristicFormula.lean) provides all the game-theoretic components.

3. **Modular**: Bridge A and Bridge B are independent lemmas that can be developed and tested separately.

4. **Precedent in codebase**: NFGameBridge.lean already has partial bridge lemmas (depth-0 NF transfer, atom helpers). The full bridge extends this existing work.

### Concrete Implementation Spec

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (extend existing file)

**New theorems needed**:

```lean
-- Bridge A: NF hypotheses → Duplicator wins
-- Key helper: 1-var NF agreement on M.carrier → rank_type agreement on ExtendedCarrier
theorem nf_char_eq_implies_rank_type_eq {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat} {x : M.carrier} {x' : M'.carrier}
    (h_nf : nf_characteristic M k 1 (fun _ => x) =
            nf_characteristic M' k 1 (fun _ => x')) :
    rank_type M atomMap k (extendPoint x) = 
    rank_type M' atomMap k (extendPoint x')

-- Key helper: interval_nf_types → interval_types
theorem interval_nf_types_eq_implies_interval_types_eq {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
    (h_int : interval_nf_types M k x t = interval_nf_types M' k x' t') :
    interval_types M atomMap k (extendPoint x) (extendPoint t) =
    interval_types M' atomMap k (extendPoint x') (extendPoint t')

-- Main Bridge A theorem
theorem nf_hypotheses_imply_duplicator_wins {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
    (h_nf_x : nf_characteristic M k 1 (fun _ => x) = ...)
    (h_nf_t : ...) (h_order : ...) (h_interval : ...) (h_above : ...) (h_below : ...) :
    ghr93_duplicator_wins M M' atomMap n k 
      (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')

-- Bridge B: Duplicator wins → NF agreement
-- The winning condition gives formula_agreement, which gives
-- stavi_temporal_truth agreement at all depths ≤ k.
-- Combined with char_k_correct, this gives nf_eval agreement.
theorem duplicator_wins_implies_nf_agreement {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
    (hwin : ∀ n, ghr93_duplicator_wins M M' atomMap n k 
      (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')) :
    nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
    nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))
```

**Then refactor `nf_2var_from_interval_data`**: Replace the call to `nf_fraisse_compression` + `nf_2var_existential_transfer` with a direct application of Bridge A → existing game composition → Bridge B.

### Critical Dependency

The bridge from `nf_characteristic M k 1 (fun _ => x)` to `rank_type M atomMap k (extendPoint x)` requires the relationship between:
- `nf_characteristic M k 1` (depth-k NF on the original structure)
- `nf_profile (extendPoint x)` = `nf_characteristic (extendedStructureWithMu M atomMap k) (2*k) 1 (fun _ => extendPoint x)` (NF profile on the mu-extended structure)

This relationship passes through `stavi_table_mu_correct` and `doets_lemma_1_1`. The depth doubling (k → 2k) is because Stavi formulas of depth r correspond to FO formulas of quantifier depth 2r on the mu-extended structure.

**Key question**: Is `nf_characteristic M k 1 (fun _ => x) = nf_characteristic M' k 1 (fun _ => x')` sufficient to conclude `nf_profile (extendPoint x) = nf_profile (extendPoint x')`? This depends on whether the mu-extension preserves enough structure. The mu predicate is defined structurally (it marks actual points vs gaps in ExtendedCarrier), so its truth at `extendPoint x` is always True (extendPoint is an actual point). The key is whether depth-k NF agreement on M implies depth-(2k) NF agreement on extendedStructureWithMu at the extended point.

This is non-trivial and constitutes the main complexity of Bridge A. Estimated ~100-150 lines for this lemma alone.

### Estimated Total

| Component | Lines | Difficulty |
|-----------|-------|------------|
| `nf_char_eq_implies_rank_type_eq` | 100-150 | Hard (depth parameter mismatch) |
| `interval_nf_types_eq_implies_interval_types_eq` | 50-80 | Medium |
| `nf_hypotheses_imply_duplicator_wins` | 80-120 | Medium (uses existing composition) |
| `duplicator_wins_implies_nf_agreement` | 50-80 | Medium |
| Refactoring `nf_2var_from_interval_data` | 20-30 | Easy |
| **Total** | **300-460** | |
