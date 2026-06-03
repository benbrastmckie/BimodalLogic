# Teammate A Findings: Blocker 1 -- nf_2var_existential_transfer (Interval Splitting)

**Task**: 155 (reynolds_pipeline_activation)
**Role**: Teammate A -- Primary Angle
**Focus**: Blocker 1 -- `nf_2var_existential_transfer` and the interval splitting problem
**Date**: 2026-06-02

---

## Key Findings

### Finding 1: The Exact GHR93 Literature Structure for Proposition 7

GHR93 Proposition 7 (paper p.114-115) is an induction on n (the number of EF game rounds):

**Base case (n=0)**: Trivial. The first round is empty; Duplicator just responds to Spoiler's single challenge in round 2 using the winning G_{1;r} strategy directly.

**Inductive step (n+1)**: Given winning strategies for all G_{f(n+1);r}(M, x_i x_{i+1}; N, y_i y_{i+1}) (both directions, all intervals), prove Duplicator wins G_{n+1;r}((M,x), (N,y)).

The key mechanism is:
1. Spoiler picks alpha in some interval (x_i, x_{i+1}) in M.
2. Duplicator lists all (1+3f(n));r-decomposition formulas phi satisfied by (x_i, alpha) and all (1+3f(n));r-decomposition formulas psi satisfied by (alpha, x_{i+1}).
3. She applies her winning strategy for G_{f(n+1);r}(M, x_i x_{i+1}; N, y_i y_{i+1}) with the phi/psi witnesses to find e in (y_i, y_{i+1}) such that all the same decomposition formulas hold for (y_i, e) and (e, y_{i+1}).
4. By Lemma 11 (game ↔ decomposition), she has winning strategies for G_{1+3f(n);r}(M, x_i alpha; N, y_i e) and G_{1+3f(n);r}(M, alpha x_{i+1}; N, e y_{i+1}).
5. By Theorem 6, she converts those forward strategies to backward strategies G_{n;r+4}(N, y_i e; M, x_i alpha) and G_{n;r+4}(N, e y_{i+1}; M, alpha x_{i+1}).
6. By the induction hypothesis (at depth n), she has a winning strategy for G_n((M, x_1..alpha), (N, y_1..e)), and she follows it for the rest of the game.

**What makes this work**: The decomposition formula in Definition 8.8.2b explicitly encodes that for every adjacent pair (a_i, a_{i+1}) of selected points, **all types realized in the sub-interval between them** match. When Duplicator finds e such that the same decomposition formulas hold for (y_i, e)/(x_i, alpha) and (e, y_{i+1})/(alpha, x_{i+1}), she has automatically ensured that:
- interval_types(x_i, alpha) = interval_types(y_i, e)
- interval_types(alpha, x_{i+1}) = interval_types(e, y_{i+1})

This is the sub-interval splitting that the direct NF approach cannot achieve.

### Finding 2: How the 3-Point (u,x,t) Configuration Maps to Proposition 7

The sorry sites are inside `nf_2var_existential_transfer` (StaviCompleteness.lean:2214-2429):
- Line 2347: forward direction at depth j'+1
- Line 2429: backward direction at depth j'+1

The theorem takes as hypotheses:
- depth-k 1-var NF equality for x/x' and t/t'
- ordering agreement: (x<t ↔ x'<t') and (t<x ↔ t'<x')
- interval_nf_types agreement for the interval between x and t
- above_max and below_min type existence agreement

It must prove: for all j < k and all depth-j 3-var NFs chi,
  (∃ u, nf_eval M j 3 (u::x::t) chi) ↔ (∃ u', nf_eval M' j 3 (u'::x'::t') chi)

**Zone matching works for j=0**: finds u' with matching 1-var NF and all correct orderings from the hypothesis data.

**For j=j'+1**: after zone matching to find u' with matching 1-var NF, the depth-(j'+1) 3-var NF of (u,x,t) decomposes into atoms + quantifiers over a 4th variable w at depth j'. The atoms transfer (handled correctly in the existing code). But the quantifiers require showing:
  (∃ w, nf_eval M j' 4 (w::u::x::t) sub_nf) ↔ (∃ w', nf_eval M' j' 4 (w'::u'::x'::t') sub_nf)

This 4-var problem requires sub-interval types for (x,u), (u,t) in M and (x',u') and (u',t') in M'. These are NOT available -- the hypotheses only give interval_nf_types for the interval between x and t (the outermost pair).

### Finding 3: The Correct Route -- Through the EF Game

The analysis in `reports/61_depth-mismatch-literature.md` and `reports/60_blocker-resolution.md` is correct:
- The **direct NF approach fundamentally cannot solve the sub-interval splitting problem**
- The fix is the **EF Game Bridge** (Approach A in both reports)

The infrastructure needed is:

**Bridge A** (NF hypotheses → decomposition_agreement → ghr93_duplicator_wins):
1. `nf_char_eq_implies_rank_type_eq`: depth-k 1-var NF equality on M.carrier → rank_type equality on ExtendedCarrier at depth r = k
2. `interval_nf_types_implies_interval_types`: interval_nf_types at depth k → interval_types at depth k
3. `nf_hypotheses_imply_duplicator_wins`: all the bridge theorem hypotheses → ghr93_duplicator_wins at rank k

**Bridge B** (ghr93_duplicator_wins → NF agreement):
4. `duplicator_wins_implies_nf_agreement`: G_n winning at rank k → depth-k 2-var NF equality

**Then replace** `nf_2var_from_interval_data`'s use of `nf_2var_existential_transfer` with: Bridge A → ghr93_strategy_compose (Composition.lean, sorry-free) → Bridge B.

### Finding 4: The Depth Parameter Relationship

Key insight from `reports/61_depth-mismatch-literature.md`:
- `nf_characteristic M k 1 (fun _ => x)` uses **FO depth k** on the original structure M
- `rank_type M atomMap r (extendPoint x)` captures all StaviFormulas of **stavi_depth ≤ r**, which correspond to FO formulas of **quantifier depth ≤ 2r** on the mu-extended structure

Therefore: depth-k NF → rank_type at depth r where r = ⌊k/2⌋ (or k/2, since stavi_fo_depth ≤ 2 × stavi_depth).

For the bridge to work, we should set the game rank r = k. This means rank_type at depth k captures StaviFormulas of depth ≤ k, which correspond to FO formulas of depth ≤ 2k. This is STRONGER than what the original depth-k NF provides. So actually, from depth-k NF agreement, we can derive rank_type agreement at depth ⌊k/2⌋.

However, for the bridge at depth k going into ghr93_strategy_compose (which is sorry-free and operates at arbitrary n and r), we just need:
- rank_type agreement at SOME depth r for the boundary points
- interval_types agreement at depth r for the interval between x and t

The weaker direction works: from depth-k NF equality, we CAN derive rank_type equality at depth k (since rank_type at depth k captures exactly StaviFormulas of stavi_depth ≤ k, and stavi_table_mu_correct + doets_lemma_1_1 connect stavi_depth with NF depth at 2k). But this only works if nf_characteristic and the extendedStructureWithMu are compatible at depth k vs 2k.

The key lemma `nf_profile_determines_stavi_truth` (CharacteristicFormula.lean:219) already shows: same nf_profile (= nf_characteristic at depth 2r on muSig) → same stavi_temporal_truth_mu at depth ≤ r. So if depth-k NF equality on M → nf_profile equality on extendedStructureWithMu at depth 2k, the rest follows.

### Finding 5: The Circularity is Breakable

`reports/61_depth-mismatch-literature.md` identified a potential circularity:
- `nf_2var_from_interval_data` is used inside `nf_characterizable_by_stavi`
- The game bridge needs char_k completeness to connect NFs to rank_types
- char_k completeness IS `nf_characterizable_by_stavi`

But this circularity is breakable because `nf_characterizable_by_stavi` proceeds by induction on k:
- At step k, we need char_k to connect NFs to rank_types for `nf_2var_from_interval_data`
- char_k at depth k is already constructed (it's the characteristic formula for depth k)
- The connection nf_profile → rank_type at depth r (CharacteristicFormula.lean:250) is already sorry-free and does NOT depend on `nf_2var_from_interval_data`
- Therefore: depth-k NF equality → rank_type equality (via char_k being an injective map on NF profiles)

**The correct bridge direction is**: nf_characteristic equality → nf_profile equality → rank_type equality, where nf_profile is defined as nf_characteristic at depth 2k on muSig (CharacteristicFormula.lean:207-211).

---

## Recommended Approach

### Step-by-Step EF Game Bridge Implementation

This is the correct approach per the literature and is Approach A from `reports/60_blocker-resolution.md`.

**Step 1: Prove `nf_char_eq_implies_rank_type_eq`** (new lemma in NFGameBridge.lean)

```lean
theorem nf_char_eq_implies_rank_type_eq {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat} {x : M.carrier} {x' : M'.carrier}
    (h_nf : nf_characteristic M k 1 (fun _ => x) =
            nf_characteristic M' k 1 (fun _ => x')) :
    rank_type M atomMap k (extendPoint x) =
    rank_type N atomMap k (extendPoint x')
```

Proof strategy: Use `nf_profile_determines_rank_type` (CharacteristicFormula.lean:250). Need to show nf_profile equality from nf_characteristic equality. nf_profile is defined as nf_characteristic of extendedStructureWithMu at depth 2k. The connection is:
- depth-k NF on M → depth-k Stavi truth on M (via char_k_correct and nf_characterizable_by_stavi at depth k)
- depth-k Stavi truth on M ↔ depth-2k FO truth on extendedStructureWithMu (via stavi_table_mu_correct)
- depth-2k FO truth on extendedStructureWithMu → depth-2k NF on extendedStructureWithMu (via nf_characteristic)
- This is nf_profile

Estimated difficulty: Hard (depth doubling, but existing lemmas do most of the work). ~80-120 lines.

**Step 2: Prove `interval_nf_types_implies_interval_types`** (new lemma in NFGameBridge.lean)

```lean
theorem interval_nf_types_implies_interval_types {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat} {lo hi : M.carrier} {lo' hi' : M'.carrier}
    (h_int : interval_nf_types M k lo hi = interval_nf_types M' k lo' hi') :
    interval_types M atomMap k (extendPoint lo) (extendPoint hi) =
    interval_types M' atomMap k (extendPoint lo') (extendPoint hi')
```

Estimated difficulty: Medium. Uses Step 1 for each member of the interval. ~50-80 lines.

**Step 3: Prove `nf_hypotheses_imply_duplicator_wins`** (new lemma in NFGameBridge.lean)

This translates all six hypotheses of `nf_2var_existential_transfer` into a `ghr93_duplicator_wins` conclusion:

```lean
theorem nf_hypotheses_imply_duplicator_wins {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
    (h_nf_x : ...) (h_nf_t : ...) (h_order : ...)
    (h_interval_above : ...) (h_interval_below : ...)
    (h_above_max : ...) (h_below_min : ...) (n : Nat) :
    ghr93_duplicator_wins M M' atomMap n k
      (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')
```

Uses Steps 1 and 2 to convert NF data to game data, then applies `ghr93_strategy_compose` iteratively. Estimated: ~80-120 lines.

**Step 4: Prove `duplicator_wins_implies_nf_agreement`** (new lemma in NFGameBridge.lean)

```lean
theorem duplicator_wins_implies_nf_agreement {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
    (hwin : ∀ n, ghr93_duplicator_wins M M' atomMap n k
      (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')) :
    nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
    nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))
```

Uses nf_fraisse_compression (already sorry-free, line ~2006) to convert per-depth-j formula transfer to k-NF equality. Estimated: ~50-80 lines.

**Step 5: Refactor `nf_2var_from_interval_data`**

Replace the current call structure:
```
nf_fraisse_compression ... h_atom_agree (nf_2var_existential_transfer ...)
```
with:
```
duplicator_wins_implies_nf_agreement (nf_hypotheses_imply_duplicator_wins ...)
```

Remove `nf_2var_existential_transfer` (the sorry'd lemma) entirely. Estimated: ~20-30 lines.

**Total estimated effort**: 300-430 lines of new proof code across NFGameBridge.lean.

### Why This Approach Is Correct

1. **Literature-faithful**: Directly implements GHR93 Proposition 7 via the EF game infrastructure that is already sorry-free in Composition.lean.

2. **No sorry deferral**: Each step is mathematically self-contained and provable with the existing sorry-free infrastructure.

3. **The key insight**: The game's `decomposition_agreement` (Decomposition.lean:62) encodes sub-interval type matching DIRECTLY in its definition. Step (b) of the `decomposition_agreement` (line 79-86) is:
   > for any actual point challenge b' in [x',y'], there exists b in [x,y] with full ghr93_winning_condition.

   This condition, when instantiated for each of the n+3 slots in game_tuple, enforces that all sub-intervals between adjacent selected points have matching types. This is precisely what the direct NF approach lacks.

4. **Existing infrastructure is sufficient**: Composition.lean's `ghr93_strategy_compose` is 626 lines and sorry-free. Decomposition.lean's `ghr93_game_iff_decomposition` is sorry-free. The main new work is the NF ↔ game translation layer.

---

## Evidence and Literature Citations

### GHR93 Proposition 7 (paper p.113-115)

Directly relevant. The strategy composition works by:
1. The pivot point c in M (and d in N) is determined by the formula C = inf{t ∈ [x,y] : M |= C(u) for all u ∈ (t,y)} -- the formula C isolates the "last zone before the game is over" landmark.
2. By Claim 1: any play of G_{4+3n;r+4(n+1)} that picks c among its elements will respond with d.
3. By Claim 2: 3 has winning strategies for the LEFT sub-interval (G_{1+3n;r+4(n+1)}(M,xc;N,x'd)) and RIGHT sub-interval (G_{1+3n;r+4(n+1)}(M,cy;N,dy')).
4. The left and right sub-strategies are combined via the induction hypothesis to win G_{n+1;r}.

In Lean, `ghr93_strategy_compose` implements exactly this mechanism with a pivot point (c, d) that has:
- matching rank_type: hcd_type
- matching gap/point: hcd_gp
- compatibility conditions: h_compat_R, h_compat_L
- left and right winning strategies: h_left, h_right

**Lean mapping**: GHR93 C formula → pivot c. GHR93 Claim 2 → the two h_left/h_right hypotheses. GHR93 induction hypothesis → the result of applying `ghr93_strategy_compose` recursively.

### GHR93 Lemma 11 (paper p.113)

Already implemented as `ghr93_game_iff_decomposition` (Decomposition.lean:302). The key: G_{n;r} winning strategy ↔ all n;r-decomposition formulas agree. The decomposition formula clause (b) (Definition 8.8.2b) is where sub-interval types are encoded.

### GHR93 Definition 8.8 / 8.7 (paper p.112-113)

Already implemented as `decomposition_agreement` (Decomposition.lean:62) and the game types in Defs.lean. The winning condition `ghr93_winning_condition` at each play gives: same order type, same gap/point status, same formula truth at all positions.

### Lean Infrastructure Summary

| Source | Lines | Status | Role in Bridge |
|--------|-------|--------|----------------|
| Composition.lean:40 | 626 | Sorry-free | Provides interval splitting via pivot |
| Decomposition.lean:62 | 315 | Sorry-free | Links game to decomposition formulas |
| CharacteristicFormula.lean:207 | 666 | Sorry-free | nf_profile → rank_type (key bridge) |
| CharacteristicFormula.lean:250 | ~12 | Sorry-free | Same nf_profile → same rank_type |
| CharacteristicFormula.lean:219 | ~30 | Sorry-free | Same nf_profile → same Stavi truth |
| StaviCompleteness.lean:2006 | ~33 | Sorry-free | nf_fraisse_compression |
| NFGameBridge.lean | 174 | Sorry-free | Partial bridge (depth-0 case) |

---

## Confidence Level

**Confidence: HIGH**

The analysis is based on:
1. Direct reading of GHR93 Proposition 7 (paper p.113-115)
2. Direct reading of all relevant Lean code (sorry sites at lines 2347, 2429; zone_match_witness; nf_fraisse_compression)
3. Five prior failed attempts documented in NFGameBridge.lean (lines 30-44)
4. Consistency with the analysis in reports 60 and 61

The approach is correct because:
- The EF Game Bridge is exactly what GHR93 uses to solve the sub-interval splitting problem
- The sorry-free game infrastructure (Composition.lean) already handles the hard combinatorics
- The remaining work is purely a translation layer between two different representations of the same mathematical content (NF types vs rank_type via stavi_temporal_truth_mu)

The main technical risk is the **depth parameter mismatch**: `nf_characteristic M k 1` vs `rank_type M atomMap k (extendPoint x)`. This is the hardest part (~80-120 lines). But the connecting lemmas `nf_profile_determines_rank_type` and `nf_profile_determines_stavi_truth` already exist in CharacteristicFormula.lean and are sorry-free.

**Secondary confidence note**: The `private` keyword issue identified in `reports/61_depth-mismatch-literature.md` is already resolved -- plan v63 Phase 2 (marked COMPLETED) removed the `private` keywords from `interval_nf_types` and related definitions.
