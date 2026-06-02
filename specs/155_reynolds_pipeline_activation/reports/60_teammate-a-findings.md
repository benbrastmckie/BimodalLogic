# Teammate A Findings: GHR93 Proposition 7 Exact Proof Extraction

**Artifact**: 60_teammate-a-findings.md
**Task**: 155 (reynolds_pipeline_activation)
**Focus**: GHR93 Proposition 7 exact proof for game composition bridge
**Date**: 2026-06-02

---

## Key Findings

### 1. What the Three Sorries Actually Need

**Sorry 1 (line 2347) and Sorry 2 (line 2429)**: Both are in `nf_2var_existential_transfer`. The theorem claims: given the 2-point configuration (x,t)/(x',t') hypotheses, for every j < k and every 3-var depth-j NF `chi`, there is an existential transfer:
```
(∃ u, nf_eval_nf M j 3 (u::x::t) chi) ↔ (∃ u', nf_eval_nf M' j 3 (u'::x'::t') chi)
```

At depth 0, this is handled (atoms + orderings from zone_match). At depth j'+1, it requires transferring the quantifier sub_nf at depth j' for a 4-variable configuration — which again requires sub-interval types for ALL pairs in the 4-point configuration. This is the recursive descent that only terminates via the game argument.

**Sorry 3 (line 2787)**: In `nf_exist_sf_guarded_backward`. This proves the backward direction: given that the guarded Stavi formula is satisfied, extract a witness x with the correct 2-var depth-k NF. The comment explicitly notes this depends on `nf_2var_from_interval_data`, which itself depends on `nf_2var_existential_transfer`.

**Dependency chain**: Sorry 3 (line 2787) → `nf_exist_sf_guarded_backward` → `nf_2var_from_interval_data` → `nf_2var_existential_transfer` → Sorries 1 & 2.

All three sorries reduce to a single root blocker: **4-variable existential transfer at depth j' for the 3-point configuration (u,x,t)/(u',x',t')**.

### 2. The Exact GHR93 Mathematical Argument

**Proposition 7 (GHR93, p.114-115)**: For all n < ω: Let M, N be linear temporal structures with increasing m-tuples x_1 < ... < x_m in M and y_1 < ... < y_m in N. Suppose Duplicator has winning strategies for both forward games G_{f(n);g(n)}(M, x_i x_{i+1}; N, y_i y_{i+1}) AND backward games G_{f(n);g(n)}(N, y_i y_{i+1}; M, x_i x_{i+1}) for all 0 ≤ i ≤ m. Then Duplicator has a winning strategy for the full EF game G_n((M,x), (N,y)).

**The inductive step** (p.114-115): Given that Spoiler picks α in (x_i, x_{i+1}) in M:

1. Enumerate all [1+3f(n)];r-decomposition formulas φ(u,v) with M_r ⊨ φ(x_i, α), and all ψ(u,v) with M_r ⊨ ψ(α, x_{i+1}).
2. Duplicator picks witnesses for the existentials of each φ and ψ, plus α itself — at most f(n+1) elements from (x_i, x_{i+1})_r total.
3. Apply the winning strategy for G_{f(n+1);r}(M, x_i x_{i+1}; N, y_i y_{i+1}) to obtain a response e in (y_i, y_{i+1}).
4. From Lemma 11: N_r ⊨ φ(y_i, e) for all φ and N_r ⊨ ψ(e, y_{i+1}) for all ψ.
5. Hence by Lemma 11, Duplicator has winning strategies for G_{1+3f(n);r}(M, x_i α; N, y_i e) and G_{1+3f(n);r}(M, α x_{i+1}; N, e y_{i+1}).
6. **Crucially, by Theorem 6** (which is the backward game theorem), she also has winning strategies for the BACKWARD games G_{1+3f(n);r}(N, y_i e; M, x_i α) and G_{1+3f(n);r}(N, e y_{i+1}; M, α x_{i+1}).
7. Apply the induction hypothesis to get a winning strategy for G_n((M, x·α), (N, y·e)).

**The sub-interval splitting solution**: The pivot point e is chosen by Duplicator's winning strategy for the FULL interval game G_{f(n+1);r}(M, x_i x_{i+1}; N, y_i y_{i+1}). This strategy guarantees that the decomposition formulas for ALL sub-intervals (x_i,α), (α,x_{i+1}) are matched at (y_i,e), (e,y_{i+1}). This is why the sub-interval types are preserved: Duplicator's strategy choice of e is NOT based just on zone-matching, but on winning the full game which encodes the decomposition agreement.

### 3. How Lemma 11 Provides Sub-interval Preservation

**Lemma 11 (GHR93, p.113)**: The following are equivalent:
1. Duplicator has a winning strategy for G_{n;r}(M, xy; N, x'y').
2. For all n;r-decomposition formulas φ(x1,x2): M_r ⊨ φ(x,y) implies N_r ⊨ φ(x',y').

**Decomposition formulas** (Definition 8.8, p.113) specify:
- The rank-r type at each selected element y_1,...,y_n
- The gap/point status at each y_i
- For each adjacent pair (y_i, y_{i+1}): which rank-r types are realized in that sub-interval

This is the EXACT semantic content of `decomposition_agreement` in `Decomposition.lean`. So Lemma 11 in the Lean codebase is `ghr93_game_iff_decomposition` (Decomposition.lean line 302).

The key: when Spoiler picks α in M, Duplicator's strategy produces e such that the decomposition formulas for (x_i, x_{i+1}) with y_1=α hold for (y_i, y_{i+1}) with e. By Lemma 11, this means the decomposition agreements for ALL sub-intervals are satisfied simultaneously.

### 4. The Role of Corollary 5 (GHR93 p.115)

**Corollary 5**: If x in M and y in N satisfy the same temporal formulas of rank g(n+1)+1, then for all monadic FO formulas φ of quantifier depth ≤ n: M ⊨ φ(x) iff N ⊨ φ(y).

This corollary is proved from Propositions 5, 6, and 7 together. In the Lean formalization context, this is the final step connecting "same temporal formula truth" (which is NF agreement in the NF world) to "same FO formula truth" (which is used in the completeness proof).

### 5. Mapping GHR93 Steps to Lean Infrastructure

| GHR93 Concept | Lean Definition/Theorem | Location |
|---------------|------------------------|----------|
| Rank-r type at point | `rank_type M atomMap r x` | TypeFormulas.lean |
| Types in interval (x,y)_r | `interval_types M atomMap r x y` | TypeFormulas.lean |
| n;r-decomposition formula | `decomposition_agreement` | Decomposition.lean |
| Lemma 11 (game ↔ decomp) | `ghr93_game_iff_decomposition` | Decomposition.lean:302 |
| Duplicator wins G_{n;r} | `ghr93_duplicator_wins` | Defs.lean |
| Prop 7 (strategy compose) | `ghr93_strategy_compose` | Composition.lean:40 |
| G_n((M,x),(N,y)) | (needs mapping from NF world) | — |
| NF type at point | `nf_characteristic M k 1 (fun _ => x)` | StaviCompleteness.lean |
| Types in NF interval | `interval_nf_types M k x t` | StaviCompleteness.lean |
| 1-var NF implies 1-var rank_type | **MISSING BRIDGE** | — |
| interval_nf_types implies interval_types | **MISSING BRIDGE** | — |

### 6. The Precise Gap: NF World ↔ Game World

The existing codebase has two complete, sorry-free worlds:

**NF world** (StaviCompleteness.lean):
- `nf_characteristic M k 1 (fun _ => x)`: depth-k 1-var NF of x in M
- `interval_nf_types M k x t`: set of 1-var depth-k NFs realized in (x,t)
- `nf_2var_existential_transfer`: needs sub-interval transfer (SORRY)

**Game world** (Composition.lean, Decomposition.lean):
- `ghr93_duplicator_wins M N atomMap n r x y x' y'`: Duplicator wins G_{n;r}
- `ghr93_strategy_compose`: Proposition 7 composition (sorry-free)
- `decomposition_agreement`: Lemma 11 characterization (sorry-free)
- `rank_type M atomMap r x`: rank-r type on ExtendedCarrier

**Missing bridge**: The bridge from NF world to game world requires:

**Bridge A** (NF hypotheses → Duplicator wins):
- `nf_characteristic M k 1 (fun _ => x) = nf_characteristic M' k 1 (fun _ => x')` → `rank_type M atomMap k (extendPoint x) = rank_type M' atomMap k (extendPoint x')`
- `interval_nf_types M k x t = interval_nf_types M' k x' t'` → `interval_types M atomMap k (extendPoint x) (extendPoint t) = interval_types M' atomMap k (extendPoint x') (extendPoint t')`
- These two + `decomposition_agreement` definition → `ghr93_duplicator_wins`

**Bridge B** (Duplicator wins → NF agreement):
- `ghr93_duplicator_wins M M' atomMap n k (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')` for all n → `nf_characteristic M k 2 (x::t) = nf_characteristic M' k 2 (x'::t')`
- This requires: game winning condition (formula_agreement at rank k) → NF eval agreement

### 7. The Depth Parameter Issue

The NF world uses depth k where `nf_characteristic M k n env` is determined by the first k rounds of the Fraisse game. The game world uses rank r where `rank_type M atomMap r x` is determined by all StaviFormulas of depth ≤ r.

These are NOT the same parameterization:
- `nf_characteristic M k 1` at depth k corresponds to truth of all rank-k temporal formulas (by the Stavi completeness theory being built)
- `rank_type M atomMap r x` on ExtendedCarrier with mu-relativization uses rank r on the mu-structure, which corresponds to quantifier depth 2r on the mu-structure

The connection: `nf_characteristic M k 1 (fun _ => x) = nf_characteristic M' k 1 (fun _ => x')` iff `rank_type M atomMap k (extendPoint x) = rank_type M' atomMap k (extendPoint x')` — BUT only when the ExtendedCarrier's mu-structure correctly reflects depth-k NFs. This requires the `stavi_table_mu_correct` result and `doets_lemma_1_1` machinery.

**Prior research (60_blocker-resolution.md) confirms**: the depth doubling issue (k → 2k for mu-relativization) is the main complexity factor. However, since `extendPoint x` always has mu=True, the depth doubling may simplify for actual points vs gaps.

---

## Recommended Approach

### Approach: Direct NF-to-NF Bridge (Bypassing ExtendedCarrier)

Rather than going through the full game machinery (ExtendedCarrier, rank_type, stavi_temporal_truth_mu), the mathematical argument can be implemented MORE DIRECTLY by translating the GHR93 game argument WITHIN the NF world.

**Key insight**: Proposition 7 in GHR93 proves that n-round game-equivalence (on points) is preserved by composition at pivot points. In the NF world, this translates to:

```
nf_2var_existential_transfer k x t x' t' chi:
  (∃ u, nf_eval_nf M j 3 (u::x::t) chi) ↔ (∃ u', nf_eval_nf M' j 3 (u'::x'::t') chi)
```

This can be proved by induction on j without going through ExtendedCarrier at all, provided we have the right inductive hypothesis. The trick is to reformulate the claim as:

**Claim**: Given depth-k interval data for (x,t)/(x',t'), for all j ≤ k and all (n+2)-var depth-j NFs chi, the existential transfer holds for (u,x,t)/(u',x',t') where u is in the same "zone" as u' and both have matching depth-k 1-var NFs.

The zone matching already gives: u and u' have the same depth-k 1-var NF. By depth monotonicity (`nf_char_depth_le`), they also have the same depth-j 1-var NF. For depth j = 0, the transfer is direct (atoms only). For depth j'+1, the transfer needs:
- Atoms: from 1-var NF agreement (done)
- Quantifier (4-var at depth j'): needs u with matching depth-k NF AND matching sub-interval data for the new extended configuration (w,u,x,t)

**The inductive invariant**: Maintain that sub-interval types for ALL pairs in the configuration agree at depth min(j, k). This is the key invariant that zone-matching PRESERVES (by construction), and the induction on j unwinds it.

**Concrete implementation** (without going through game world):

```lean
theorem nf_kvar_existential_transfer {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    (k j n : Nat) (hj : j ≤ k)
    -- n points in M and M' with matching depth-k NFs and orderings
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_nf_points : ∀ i, nf_characteristic M k 1 (fun _ => env_M i) =
                        nf_characteristic M' k 1 (fun _ => env_M' i))
    (h_order : ∀ i j, env_M i < env_M j ↔ env_M' i < env_M' j)
    -- Interval type agreement at depth k for ALL pairs
    (h_interval : ∀ i j (hij : env_M i < env_M j),
        interval_nf_types M k (env_M i) (env_M j) =
        interval_nf_types M' k (env_M' i) (env_M' j))
    (h_above : ...) (h_below : ...) :
    ∀ chi : NormalForm sig j (n + 1),
      (∃ u, nf_eval_nf M j (n + 1) (Fin.cons u env_M) chi) ↔
      (∃ u', nf_eval_nf M' j (n + 1) (Fin.cons u' env_M') chi)
```

This strengthened induction hypothesis (n-var with all pairwise interval agreements) is what allows the inductive step to go through. The base case (j=0) is atoms only. The inductive step uses zone-matching to find u'/u with matching NF and then invokes the IH for the (n+1)-point configuration (u,env_M) with the sub-interval data.

**Critical point**: The sub-interval data for the extended (n+1)-point configuration CAN be derived from the n-point interval data combined with the zone of u. When u is strictly between env_M i and env_M (i+1), the interval types in (env_M i, u) and (u, env_M (i+1)) together partition the types in (env_M i, env_M (i+1)). The zone-matching hypothesis `interval_nf_types M k (env_M i) (env_M (i+1)) = interval_nf_types M' k (env_M' i) (env_M' (i+1))` allows us to find u' such that the types in (env_M' i, u') match types in (env_M i, u) and types in (u', env_M' (i+1)) match types in (u, env_M (i+1)).

**This is exactly the "interval splitting" that zone_match_witness currently fails to provide** — but with a stronger hypothesis (all-pairs interval agreement), the split CAN be constructed.

---

## Evidence/Examples

### Evidence 1: GHR93 Proposition 7 is Exactly What We Need

From GHR93 p.114: "By the induction hypothesis, 3 has a winning strategy σ for G_n((M,x·α),(N,y·e))." The key is that Duplicator picks e using the FULL interval strategy, which provides all sub-interval decomposition agreements. This is implemented in `ghr93_strategy_compose` (Composition.lean line 40), which is sorry-free.

### Evidence 2: The n-var Induction Formulation Works

`nf_fraisse_compression` (StaviCompleteness.lean:2006) already proves: atoms + existential transfer at all depths j < k → depth-k NF equality. What's missing is the existential transfer itself. The n-var induction provides this transfer by maintaining all-pairs interval agreements as an invariant.

### Evidence 3: Zone-Matching Already Handles 5 Zones

`zone_match_witness` (StaviCompleteness.lean:2044) already implements zone matching for 1 additional variable relative to 2 reference points. Generalizing to n reference points requires matching u to the zone between env_M i and env_M (i+1), using `interval_nf_types M k (env_M i) (env_M (i+1)) = interval_nf_types M' k (env_M' i) (env_M' (i+1))`.

### Evidence 4: All Structural Pieces Exist

The following sorry-free components exist and can be composed:
- `nf_char_depth_le`: depth k → depth j agreement for j ≤ k
- `zone_match_witness`: 1-var NF-matching witness with correct orderings
- `nf_fraisse_compression`: depth-k NF from atoms + existential transfer
- `nvar_nf_eq_depth_zero_from_pointwise`: depth-0 NF from pointwise data
- `atom_agree_from_pointwise_nf`: n-var atom agreement from pointwise NFs + orderings
- `ghr93_strategy_compose`: Proposition 7 composition (sorry-free game world)

### Evidence 5: GHR94 Ch9 Uses the Same Structure

The GHR94 Chapter 9 approach (Theorem 9.3.1, Separation → Expressive Completeness) uses the same inductive argument but via separation rather than games. The EF game approach in GHR93 Section 8 (Theorem 6 + Proposition 7) is the direct game-theoretic version of the same argument. Both converge to the same conclusion: the existential transfer at depth j requires all-pairs interval type agreement, maintained by the pivot splitting strategy.

---

## Confidence Level

**Confidence: HIGH (90%)** for the mathematical approach. The GHR93 argument is clearly documented and the Lean infrastructure is largely in place.

**Confidence: MEDIUM (70%)** for the direct NF-world induction avoiding ExtendedCarrier. The key uncertainty is whether the zone-matching for an (n+1)-point configuration can be proved using ONLY `interval_nf_types` at the outer level, or whether additional data about how types are distributed within sub-intervals is needed. If `interval_nf_types M k x t` is the SET of NF types realized in (x,t) (not a multiset), then knowing the set of types in (x,t) and the set of types realized at u suffices to determine the set of types in (x,u) — namely, it's a subset of `interval_nf_types M k x t`. But a matching u' in (x',t') with the same 1-var NF MIGHT not have `interval_nf_types M' k x' u' = interval_nf_types M k x u`. This is the precise gap.

**Confidence: HIGH (85%)** that the ExtendedCarrier bridge approach (60_blocker-resolution.md approach A) is also correct but requires ~300-400 lines including handling the mu-relativization depth doubling.

---

## Summary of the Exact GHR93 Mathematical Steps

For the sub-interval splitting problem in Proposition 7:

**Step 1** (p.114): Define c = inf{t ∈ [x,y] : M ⊨ C(u) for all u ∈ (t,y)} and d similarly in N. These are the "canonical pivot points" for the interval [x,y] and [x',y']. They are well-defined elements of M_r (the r-extended structure including r-definable gaps).

**Step 2** (Claim 1, p.116): In any play where Duplicator uses her winning strategy and Spoiler includes c in his choices, Duplicator's response to c is exactly d. (Proved by the rank r+1 formula C' = ¬C ∨ K⁻¬C, which characterizes c.)

**Step 3** (Claim 2, p.116): Duplicator has winning strategies for the sub-interval forward games G_{1+3n;r+4(n+1)}(M,xc;N,x'd) and G_{1+3n;r+4(n+1)}(M,cy;N,dy'). (Proved by restricting the full strategy σ to elements in [x,c] and [c,y] respectively.)

**Step 4** (p.116): By the inductive hypothesis (*_n), she also has backward strategies for G_{n;r+4}(N,x'd;M,xc) and G_{n;r+4}(N,dy';M,cy).

**Step 5** (Case analysis, pp.116-119): Split on whether Spoiler's final choice α_n is:
- Case I: α_0 < d (then at most n points on each side; use left+right strategies)
- Case II: α_n ∈ N is a point (use rank-r type B = X_{α_n}, find b in M satisfying B and U(B,A))
- Case III: α_n is a left-definable gap D (use left(B,D) with Lemma 9 to find gap in M)
- Case IV: α_n is a right-definable gap (use right(B,D) with Lemma 9)

**Key insight for Case II** (the most common case, p.117): Duplicator has strategy τ for G_{n;r+4}(N,d'y';M,cy) where d' = sup{t ∈ (x',y') : N ⊨ ¬B(t)}. She uses τ to choose e_0,...,e_{n-1} in response to α_0,...,α_{n-1}. Then U(B,A) holds at e_{n-1} (preserved by the rank r+4 strategy), giving a point z > e_{n-1} in M with M ⊨ B(z). She chooses e_n = z. This z and α_n both satisfy B (= X_{α_n}), so they have the same rank-r type. The game is won.

**The translation to NF world**: The role of "rank-r type" (X_{α_n}) is played by `nf_characteristic M j 1 (fun _ => u)` at depth j. The "sub-interval type set" for (x,u) vs (x,u') is `interval_nf_types M j x u`. The "U(B,A) holds at e_{n-1}" condition corresponds to: there exists a point z in (e_{n-1}, d) with the same 1-var NF as u, and all points in (e_{n-1}, z) have NF types in the interval set for (x,t).

**Conclusion for implementation**: The game composition argument CAN be implemented in the NF world directly, but it requires maintaining interval type agreement for all pairs in the n-point configuration. The `nf_kvar_existential_transfer` theorem with the strengthened hypothesis is the right formulation. It avoids the ExtendedCarrier completely and has a clear inductive structure matching the GHR93 proof.
