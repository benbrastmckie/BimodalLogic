# Depth Arithmetic Blocker Resolution

## 1. Root Cause Analysis

### 1.1 The 2x Depth Penalty Is Real (Report 66 Table Was Wrong)

Report 66 section 4.5 claims "Max r from depth-k NFs = k (no gaps, mu trivial)" for discrete orders. This is **incorrect**. Section 3.6 of the same report correctly states r ≤ k/2. The confusion arises from conflating "mu is trivially true" with "the extra predicate has no cost in the NF hierarchy."

**The real chain**: For discrete orders, depth-k NF agreement on `sig` gives depth-k NF agreement on `muSig sig` (since mu adds a trivially-true predicate that doesn't distinguish positions). But `nf_profile` is defined as:

```lean
nf_characteristic (extendedStructureWithMu M atomMap r) (2 * r) 1 (fun _ => t)
```

This requires depth `2*r` NF agreement on `muSig sig`. From depth-k on `muSig sig`, we get `nf_profile` agreement only when `2*r ≤ k`, i.e., `r ≤ floor(k/2)`.

### 1.2 But r = floor(k/2) IS Sufficient

The plan assumes r = k is needed, but the game bypass actually works at r = floor(k/2). The key insight: **Bridge B recovers the full depth-k NF agreement from formula_agreement at rank floor(k/2)**.

Here is the complete chain:

**Bridge A** (NF hypotheses → decomposition_agreement at rank r = floor(k/2)):
1. depth-k NF agreement on `sig` between x,x' and t,t'
2. → depth-k NF agreement on `muSig sig` (discrete: mu trivially true, same carrier)
3. → `nf_profile` agreement at depth 2*r = 2*floor(k/2) ≤ k ✓
4. → `rank_type` agreement at rank r (via `nf_profile_determines_rank_type`)
5. → `decomposition_agreement` at rank r (via existing infrastructure)

**Game** (decomposition_agreement → ghr93_duplicator_wins at rank r):
- Already sorry-free. Works at any rank.

**Bridge B** (game → NF agreement at depth j < k):
1. `ghr93_duplicator_wins` gives `formula_agreement` at rank r on ExtendedCarrier
2. For discrete: `stavi_temporal_truth_mu` = `stavi_temporal_truth` on M.carrier
3. → agreement on all StaviFormulas with `stavi_depth ≤ r` 
4. → via `stavi_table_mu_correct`: agreement on `stavi_table_mu A` for such A
5. → agreement on MonadicFormulas of quantifier_depth ≤ 2*r on `muSig sig`
6. → restricting from `muSig sig` to `sig`: agreement at depth 2*r = k on `sig`
7. → NF agreement at depth k on `sig` (via `doets_lemma_1_1`)
8. → NF agreement at depth j for all j < k (monotonicity)

**Edge cases**: k=0 (vacuous), k=1 (r=0, Bridge B gives depth-0 = atom agreement, but depth-0 NF transfer for j=0 is trivially from the NF hypotheses directly).

### 1.3 Why the Plan's r=k Claim Is Wrong

The plan (v67) and report 66 section 4.5 claim that for discrete orders, "the 2x depth penalty vanishes." This is wrong in a specific sense: the depth penalty for `nf_profile` (which needs depth 2*r) does NOT vanish. What vanishes is the need for r=k. The game at r=floor(k/2) is sufficient because:
- Bridge B converts rank-r formula_agreement back to depth-2r = k NF agreement
- The game handles the sub-interval splitting compositionally at any rank

## 2. Assessment of Resolution Paths

### Path 1: Prove stavi_depth of characterizing formula ≤ k

**Verdict: INFEASIBLE (stavi_depth ≤ 2k, not k)**

The `nf_characterizable_by_stavi` construction uses `std_untl`/`std_snce` (not stavi variants), so `stavi_fo_depth = stavi_depth` for the constructed formulas. By induction:
- D(0) = 0
- D(k+1) = D(k) + 2 (from the `std_untl` wrapper in `nf_exist_sf_guarded`)
- D(k) = 2k

So `stavi_depth(char_k nf_k) ≤ 2k`, not ≤ k. This can't be improved — each level of induction wraps in a Until/Since connective adding +2. Even the tighter `stavi_fo_depth` bound equals `stavi_depth` for these formulas.

### Path 2: Prove nf_profile at depth 2*k determined by sig NF at depth k (discrete)

**Verdict: INFEASIBLE DIRECTLY (need depth 2k on muSig, only have k)**

This is exactly the root cause. For discrete orders:
- depth-k NF on `sig` → depth-k NF on `muSig sig` ✓
- nf_profile needs depth 2*k on `muSig sig`
- depth-k on `muSig sig` ≠ depth-2*k on `muSig sig` for k ≥ 1

Even though mu is trivially true, the NF hierarchy doesn't collapse across depth levels.

### Path 3: Use game at rank floor(k/2)

**Verdict: FEASIBLE — the correct approach**

As shown in section 1.2, r = floor(k/2) works:
- Bridge A achieves decomposition_agreement at rank floor(k/2) from depth-k NFs
- The game runs at rank floor(k/2) (sorry-free infrastructure)
- Bridge B recovers depth-k NF agreement from formula_agreement at rank floor(k/2)

This is the mathematically correct resolution.

### Path 4 (NEW): Bypass nf_profile, use reduced-depth agreement directly

**Verdict: FEASIBLE but equivalent to Path 3**

Instead of going through nf_profile → rank_type, go directly:
1. depth-k NF on sig → depth-k NF on muSig
2. depth-k NF on muSig → agreement on all MonadicFormulas of depth ≤ k on muSig
3. → agreement on stavi_table_mu A for A with stavi_fo_depth ≤ k
4. stavi_fo_depth ≤ k means stavi_depth ≤ k (when using only std_untl/snce)
5. → formula_agreement at rank floor(k/2) (covers stavi_depth ≤ floor(k/2))

This is essentially the same as Path 3 but avoids defining new nf_profile variants. It still requires the game at reduced rank.

## 3. Recommended Approach: Path 3 (rank floor(k/2))

### 3.1 Proof Strategy

Implement `discrete_nf_2var_existential_transfer` using the game bypass at rank `r = floor(k/2)`:

**Bridge A** (new lemma, ~150-200 lines):
```lean
theorem discrete_nf_to_decomposition_agreement
    {M M' : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {k : Nat}
    (h_discrete_M : IsSuccArchimedean M.carrier)
    (h_discrete_M' : IsSuccArchimedean M'.carrier)
    (h_nf_x : nf_characteristic M k 1 (fun _ => x) = ...)
    (h_nf_t : nf_characteristic M k 1 (fun _ => t) = ...)
    (h_order : ...)
    (h_intervals : ...) :
    decomposition_agreement M M' atomMap 0 (k/2) (extendPoint x) (extendPoint t) ... := by
```

Key sub-lemmas:
1. `nf_agree_muSig_of_nf_agree_sig`: depth-k NF agreement on sig → depth-k on muSig (for discrete orders). ~60-80 lines. Induction on k and n (variables). Uses: mu is trivially true, carrier is the same, predicates restrict cleanly.
2. `discrete_nf_profile_at_half_rank`: from depth-k NF on muSig, derive nf_profile agreement at depth 2*(k/2). ~30 lines. Direct: 2*(k/2) ≤ k, use nf_agreement_monotone.
3. `discrete_formula_agreement`: from nf_profile at rank k/2, derive formula_agreement at rank k/2. ~20 lines. Reuse `nf_profile_determines_stavi_truth` with r = k/2.
4. `discrete_interval_types`: convert interval_nf_types to interval_types. ~40 lines.

**Bridge B** (new lemma, ~100-150 lines):
```lean
theorem discrete_game_to_nf_transfer
    {M M' : OrderedMonadicStructure sig}
    (h_discrete_M : IsSuccArchimedean M.carrier)
    (h_game : ghr93_duplicator_wins M M' atomMap n (k/2) ...) :
    ∀ j, j < k → ∀ chi : NormalForm sig j (2+1), ... := by
```

Key sub-lemmas:
1. `game_to_muSig_fo_agree`: from formula_agreement at rank r, derive FO agreement at depth 2*r on muSig. ~40 lines. Uses stavi_table_mu_correct.
2. `muSig_fo_to_sig_nf`: from depth-d FO agreement on muSig, derive depth-d NF agreement on sig. ~30 lines. MonadicFormulas of sig embed into those of muSig.
3. `nf_transfer_from_game`: combine the above to get NF existential transfer. ~50 lines. For each u, use game to find u' with formula_agreement; recover NF via muSig_fo_to_sig_nf.

### 3.2 Complexity Estimate

| Component | Lines | Difficulty |
|-----------|-------|------------|
| `nf_agree_muSig_of_nf_agree_sig` | 60-80 | Medium (induction on k, n) |
| `discrete_nf_profile_at_half_rank` | 30 | Easy |
| `discrete_formula_agreement` | 20 | Easy (reuse existing) |
| `discrete_interval_types` | 40 | Medium |
| Bridge A master theorem | 50 | Medium (assembly) |
| `game_to_muSig_fo_agree` | 40 | Medium |
| `muSig_fo_to_sig_nf` | 30 | Easy-Medium |
| Bridge B master theorem | 50 | Medium |
| `discrete_nf_2var_existential_transfer` | 30 | Easy (wire bridges) |
| Threading IsSuccArchimedean | 30 | Easy |
| **Total** | **380-430** | **Medium** |

### 3.3 Key Lean Definitions/Lemmas Needed

**New definitions** (none — all types already exist)

**New lemmas in NFGameBridge.lean**:

```lean
-- Bridge A: sig NF → muSig NF (discrete only)
theorem nf_agree_muSig_of_nf_agree_sig
    [IsSuccArchimedean M.carrier] [IsSuccArchimedean M'.carrier]
    (h : nf_characteristic M d n env = nf_characteristic M' d n env') :
    nf_characteristic (extendedStructureWithMu M atomMap r) d n 
      (fun i => extendPoint (env i)) =
    nf_characteristic (extendedStructureWithMu M' atomMap r) d n 
      (fun i => extendPoint (env' i))

-- Bridge A: nf_profile at half rank
theorem discrete_nf_profile_at_half_rank
    [IsSuccArchimedean M.carrier] [IsSuccArchimedean M'.carrier]
    (h : nf_characteristic M k 1 (fun _ => x) = 
         nf_characteristic M' k 1 (fun _ => x')) :
    nf_profile (r := k/2) (extendPoint x) = 
    nf_profile (r := k/2) (extendPoint x')

-- Bridge B: formula_agreement to NF (via FO on muSig → FO on sig)
theorem discrete_formula_agree_to_nf
    [IsSuccArchimedean M.carrier]
    (h_fa : formula_agreement n tM tN)
    (r_eq : r = k/2) :
    nf_characteristic M k 1 (fun _ => tM 0) = ...

-- Master: discrete existential transfer at rank k/2
theorem discrete_nf_2var_existential_transfer
    [IsSuccArchimedean M.carrier] [IsSuccArchimedean M'.carrier]
    (atomMap : Formula → sig.preds) (k : Nat)
    (x t : M.carrier) (x' t' : M'.carrier)
    (char_k : NormalForm sig k 1 → StaviFormula) ...
    ∀ j, j < k → ∀ chi : NormalForm sig j (2+1), ... 
```

**Modified lemmas**: `nf_2var_existential_transfer` gets a discrete variant that takes IsSuccArchimedean. The sorry sites (lines 2353, 2435) are resolved by delegating to `discrete_nf_2var_existential_transfer` when discrete hypotheses are available. `nf_exist_sf_guarded_backward` (line 2805) similarly delegates.

### 3.4 Critical Verification Points

1. **2*(k/2) ≤ k**: This holds by integer arithmetic (Nat.div_mul_le_self). This is the key inequality making Bridge A work.

2. **formula_agreement at rank k/2 → depth-k NF on sig**: The chain is:
   - formula_agreement at rank k/2 gives stavi_truth agreement for stavi_depth ≤ k/2
   - stavi_table_mu has quantifier_depth ≤ stavi_fo_depth ≤ 2*stavi_depth ≤ 2*(k/2) ≤ k  
   - So agreement on MonadicFormula (muSig sig) of depth ≤ k
   - Restricting from muSig to sig: agreement on MonadicFormula sig of depth ≤ k
   - By doets_lemma_1_1: same NF at depth k on sig

3. **n (game rounds) sufficiency**: The game `ghr93_decomposition_implies_game` takes n and r. For the game to provide full point matching in [x,t], n needs to be at least the number of distinct rank_types. At rank k/2, this is bounded by `|NormalForm (muSig sig) (2*(k/2)) 1| = |NormalForm (muSig sig) k 1|`. So n can be set to this cardinality.

4. **interval_types conversion**: The game's decomposition_agreement uses `interval_types` (rank_type-based), while the hypotheses provide `interval_nf_types` (NF-based). For discrete orders at rank k/2, these are connected via nf_profile_determines_rank_type at rank k/2.

## 4. Plan Revision Recommendations

The plan (v67) should be revised to:
1. **Replace r=k with r=floor(k/2)** throughout Phase 1 and Phase 2
2. **Add `nf_agree_muSig_of_nf_agree_sig`** as a critical sub-lemma (the most technically demanding new piece)
3. **Restructure Bridge A** to go through nf_profile at depth 2*(k/2) instead of 2*k
4. **Add Bridge B recovery chain** (formula_agreement → FO on muSig → NF on sig)
5. **Phase 1 estimate**: increase from 2.5h to 3.5h (the muSig NF correspondence is non-trivial)
6. **Total estimate**: increase from 8h to 10h
