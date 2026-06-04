# Depth Arithmetic Verification for Path 1 (Mutual Induction at Rank k-1)

## 1. Exact Definitions (Lean Type Signatures)

### 1.1 stavi_depth (Defs.lean lines 164-171)

```lean
def stavi_depth : StaviFormula → Nat
  | .base φ => operator_depth φ
  | .stavi_untl A B => max (stavi_depth A) (stavi_depth B) + 2
  | .stavi_snce A B => max (stavi_depth A) (stavi_depth B) + 2
  | .neg φ => stavi_depth φ
  | .conj φ ψ => max (stavi_depth φ) (stavi_depth ψ)
  | .std_untl A B => max (stavi_depth A) (stavi_depth B) + 2
  | .std_snce A B => max (stavi_depth A) (stavi_depth B) + 2
```

This counts temporal connective nesting. Each U, S, U', S' adds 2.

### 1.2 stavi_fo_depth (StaviCompleteness.lean lines 464-471)

```lean
def stavi_fo_depth : StaviFormula → Nat
  | .base φ => operator_depth φ
  | .neg A => stavi_fo_depth A
  | .conj A B => max (stavi_fo_depth A) (stavi_fo_depth B)
  | .std_untl A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 2
  | .std_snce A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 2
  | .stavi_untl A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 4
  | .stavi_snce A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 4
```

This is the FO quantifier depth of `stavi_table_mu A`. Note: stavi_untl/snce add +4 (not +2).

### 1.3 stavi_fo_depth_le_twice_depth (StaviCompleteness.lean lines 488-497)

```lean
theorem stavi_fo_depth_le_twice_depth (A : StaviFormula) :
    stavi_fo_depth A ≤ 2 * stavi_depth A
```

**PROVEN**. The bound is: `stavi_fo_depth(A) <= 2 * stavi_depth(A)`.

### 1.4 stavi_table_mu_depth (StaviCompleteness.lean lines 500-540)

```lean
theorem stavi_table_mu_depth {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} (A : StaviFormula) :
    (stavi_table_mu atomMap A).quantifier_depth ≤ stavi_fo_depth A
```

**PROVEN**. Combined with 1.3: `(stavi_table_mu A).quantifier_depth <= 2 * stavi_depth(A)`.

### 1.5 nf_profile (CharacteristicFormula.lean lines 207-211)

```lean
noncomputable abbrev nf_profile {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (t : ExtendedCarrier M atomMap r) :
    NormalForm (muSig sig) (2 * r) 1 :=
  nf_characteristic (extendedStructureWithMu M atomMap r) (2 * r) 1 (fun _ => t)
```

**CRITICAL**: nf_profile uses `NormalForm (muSig sig) (2 * r) 1`. The depth is `2 * r`.

### 1.6 nf_profile_determines_stavi_truth (CharacteristicFormula.lean lines 219-247)

```lean
theorem nf_profile_determines_stavi_truth ...
    (h_same : nf_profile t = nf_profile u)
    (A : StaviFormula) (hA : stavi_depth A ≤ r) :
    stavi_temporal_truth_mu M atomMap r t A ↔
    stavi_temporal_truth_mu M atomMap r u A
```

**The chain inside this proof** (lines 237-247):
```
hA_fo : (stavi_table_mu atomMap A).quantifier_depth ≤ 2 * r :=
  le_trans (stavi_table_mu_depth A)
    (le_trans (stavi_fo_depth_le_twice_depth A) (Nat.mul_le_mul_left 2 hA))
```

Spelled out: `quantifier_depth(stavi_table_mu A) <= stavi_fo_depth(A) <= 2 * stavi_depth(A) <= 2 * r`.

### 1.7 rank_type (TypeFormulas.lean lines 381-384)

```lean
def rank_type {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (r : Nat)
    (t : ExtendedCarrier M atomMap r) : Set StaviFormula :=
  { A | stavi_depth A ≤ r ∧ stavi_temporal_truth_mu M atomMap r t A }
```

rank_type at rank r is the set of StaviFormulas with `stavi_depth A <= r` that are mu-true at t.

### 1.8 formula_agreement (CustomGame.lean lines 239-246)

```lean
def formula_agreement {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (n : Nat)
    (tM : Fin (n + 3) → ExtendedCarrier M atomMap r)
    (tN : Fin (n + 3) → ExtendedCarrier N atomMap r) : Prop :=
  ∀ (i : Fin (n + 3)) (A : StaviFormula), stavi_depth A ≤ r →
    (stavi_temporal_truth_mu M atomMap r (tM i) A ↔
     stavi_temporal_truth_mu N atomMap r (tN i) A)
```

formula_agreement at rank r: agreement on ALL StaviFormulas with stavi_depth <= r.

### 1.9 decomposition_agreement (Decomposition.lean lines 62-101)

```lean
def decomposition_agreement {sig : MonadicSignature}
    (M N : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (n r : Nat)
    (x y : ExtendedCarrier M atomMap r) (x' y' : ExtendedCarrier N atomMap r) : Prop
```

Parameterized by `n` (selection size) and `r` (rank). Uses `rank_type M atomMap r` and `ExtendedCarrier M atomMap r`.

### 1.10 ghr93_duplicator_wins (CustomGame.lean lines 285-303)

```lean
def ghr93_duplicator_wins {sig : MonadicSignature}
    (M N : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (n r : Nat)
    (x y : ExtendedCarrier M atomMap r) (x' y' : ExtendedCarrier N atomMap r) : Prop
```

The game G_{n;r} is parameterized by `n` (rounds) and `r` (rank). Winning condition includes `formula_agreement n tM tN` where formula_agreement checks `stavi_depth A <= r`.

### 1.11 stavi_n_equiv (Defs.lean lines 180-184)

```lean
def stavi_n_equiv ... (n : Nat) ... : Prop :=
  ∀ (A : StaviFormula), stavi_depth A ≤ game_depth sig n →
    (stavi_temporal_truth M atomMap t A ↔ stavi_temporal_truth N atomMap s A)
```

n-equivalence checks stavi_depth against `game_depth sig n`, NOT directly against n.

### 1.12 nf_characterizable_by_stavi (StaviCompleteness.lean lines 3078-3084)

```lean
theorem nf_characterizable_by_stavi
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) (nf : NormalForm sig k 1) :
    ∃ A : StaviFormula, ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
      stavi_temporal_truth M atomMap t A ↔
      nf_eval_nf M k 1 (fun _ => t) nf
```

This gives a StaviFormula characterizing depth-k NFs. The **stavi_depth of the resulting formula is NOT bounded by k** -- the theorem says nothing about the depth of A. It only guarantees A exists with the right semantics.

### 1.13 nf_2var_existential_transfer (StaviCompleteness.lean lines 2214-2435)

```lean
theorem nf_2var_existential_transfer {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    (atomMap : Formula → sig.preds)
    (k : Nat) (x t : M.carrier) (x' t' : M'.carrier)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (N : OrderedMonadicStructure sig) (t : N.carrier),
        stavi_temporal_truth N atomMap t (char_k nf_k) ↔
        nf_eval_nf N k 1 (fun _ => t) nf_k)
    ...
    ∀ j, j < k →
      ∀ chi : NormalForm sig j (2 + 1),
        (∃ u, nf_eval_nf M j (2 + 1) ...) ↔ (∃ u', nf_eval_nf M' j (2 + 1) ...)
```

**The key parameter**: `char_k` provides characteristic formulas for depth-k 1-var NFs. The theorem needs `char_k_correct` for ALL structures N. The sorry is at the 4-var quantifier transfer (depth j' for the inner case j = j'+1).

## 2. The Depth Chain: Precise Analysis

### 2.1 What does "depth-k NF agreement" give us?

If `nf_characteristic M k 1 (fun _ => x) = nf_characteristic M' k 1 (fun _ => x')`, this means x and x' agree on all `NormalForm sig k 1` evaluations. By `doets_lemma_1_1`, they agree on all `MonadicFormula sig 1` of quantifier_depth <= k.

### 2.2 What does "depth-k NF agreement" give us about Stavi formulas on the ORIGINAL structures?

Via `nf_characterizable_by_stavi`, each depth-k NF has a characterizing StaviFormula. But the stavi_depth of this formula is NOT bounded. The `nf_characterizable_by_stavi` proof builds formulas using Until/Since wrappings at each induction step, so the stavi_depth grows with k but is not claimed to equal k.

**However**, for the purposes of the proof, the relevant pathway is different. The question is about `formula_agreement` on ExtendedCarrier, not about StaviFormula agreement on the original carrier.

### 2.3 The nf_profile -> rank_type pathway (CharacteristicFormula.lean)

This is the pathway from NF agreement to formula_agreement:

1. `nf_profile t = nf_profile u` (same NormalForm (muSig sig) (2*r) 1 on ExtendedStructureWithMu)
2. => `rank_type M atomMap r t = rank_type M atomMap r u` (via `nf_profile_determines_rank_type`)
3. => agreement on all StaviFormulas with `stavi_depth A <= r` (via `rank_type_eq_iff`)

The critical step is (1->2). The proof chain is:
- `nf_profile` at depth `2*r` determines agreement on all `MonadicFormula (muSig sig) 1` of quantifier_depth <= `2*r`
- For A with stavi_depth(A) <= r: `quantifier_depth(stavi_table_mu A) <= stavi_fo_depth(A) <= 2*stavi_depth(A) <= 2*r`
- So `stavi_table_mu A` has quantifier_depth <= 2*r, hence its evaluation is determined
- By `stavi_table_mu_correct`, this means `stavi_temporal_truth_mu` of A is determined

**Result**: Same nf_profile at depth 2*r => same rank_type at rank r => formula_agreement at rank r.

### 2.4 The x_t_formula construction (CharacteristicFormula.lean)

```lean
noncomputable def x_t_formula ... (r : Nat) (t : ExtendedCarrier M atomMap r) : StaviFormula
theorem x_t_depth : stavi_depth (x_t_formula M atomMap r t) ≤ r
```

The characteristic formula X_t has `stavi_depth <= r`. This is proven. So X_t fits within a rank-r formula_agreement budget.

## 3. The Critical Question: Does Path 1 Work?

### 3.1 What Path 1 Claims

Path 1 (Mutual Induction at Rank k-1): The outer induction hypothesis at depth k gives `nf_characterizable_by_stavi` at depth k-1, yielding `stavi_expressive_completeness` at depth k-1. With depth-(k-1) expressive completeness, `formula_agreement` at some rank r can be built from NF hypotheses, breaking the circularity.

### 3.2 What nf_2var_existential_transfer Actually Needs

Looking at the signature:
```lean
(char_k : NormalForm sig k 1 → StaviFormula)
(char_k_correct : ∀ (nf_k : NormalForm sig k 1)
    (N : OrderedMonadicStructure sig) (t : N.carrier),
    stavi_temporal_truth N atomMap t (char_k nf_k) ↔
    nf_eval_nf N k 1 (fun _ => t) nf_k)
```

It needs `char_k` that characterizes depth-**k** NFs (not k-1). The induction in `nf_characterizable_by_stavi` at depth k+1 uses `char_k` at depth k via the IH. This is exactly the structure -- the IH provides `char_k` for depth k, and the theorem proves the result for depth k+1.

**The sorry at line 2353** is inside `nf_2var_existential_transfer` at depth j'+1 (where j = j'+1 < k). It needs 4-variable existential transfer:
```
(∃ w, nf_eval M j' 4 (w::u::x::t) sub_nf) ↔ (∃ w', nf_eval M' j' 4 (w'::u'::x'::t') sub_nf)
```

This is NOT about formula_agreement or rank_type. It is about n-variable NF transfer for n=4, at a LOWER depth j'. The problem is that zone matching gives u' with correct 1-var NF and orderings, but the 4-var NF requires sub-interval type data for ALL pairs in the 3-point configuration (u,x,t).

### 3.3 The Game-Based Bypass (NFGameBridge.lean approach)

The NFGameBridge.lean documentation (lines 18-39) explains why the direct NF induction approach fails and why the game-based approach works:

```
The correct path (GHR93) goes THROUGH the EF game:
1. NF hypotheses → decomposition_agreement (Bridge A)
2. decomposition_agreement → ghr93_duplicator_wins (already sorry-free!)
3. ghr93_duplicator_wins → NF agreement (Bridge B)
```

The game handles the sub-interval splitting problem compositionally.

### 3.4 Teammate C's Claim: formula_agreement from NF hypotheses

Teammate C claims: depth-k NF agreement + depth-(k-1) expressive completeness gives formula_agreement at some rank r.

Let me trace this precisely.

**Given**: Two points x in M, x' in M' with `nf_characteristic M k 1 (fun _ => x) = nf_characteristic M' k 1 (fun _ => x')`.

**Question**: Can we derive `formula_agreement` at some rank r on ExtendedCarrier?

**The issue**: `formula_agreement` lives on `ExtendedCarrier M atomMap r`, not on the original carriers M.carrier and M'.carrier. The game infrastructure operates on extended carriers. The NF infrastructure operates on original carriers.

**To bridge**: We would need to show that NF agreement on the original carrier translates to formula_agreement on the extended carrier. This is exactly what nf_profile_determines_rank_type does, but it operates at a SINGLE position, not across two different structures.

For two different structures M and M', we would need:
- `nf_profile` of `extendPoint x` in `extendedStructureWithMu M atomMap r` equals
- `nf_profile` of `extendPoint x'` in `extendedStructureWithMu M' atomMap r`

This requires showing that the NF characteristic of the mu-extended structure at the embedding of x matches across structures. This is plausible but requires new lemmas connecting NF agreement on the original carrier to NF agreement on the extended carrier.

### 3.5 Teammate A's Concern: The 2x Depth Penalty

Teammate A's concern: `stavi_fo_depth_le_twice_depth` means stavi_depth d has FO depth up to 2d. So depth-k NFs (FO depth <= k) only give formula_agreement at rank floor(k/2).

**THIS CONCERN IS MISPLACED.** Here is why:

The `stavi_fo_depth_le_twice_depth` bound goes in the wrong direction for Teammate A's argument. The bound says: if `stavi_depth(A) <= r`, then `stavi_fo_depth(A) <= 2*r`, and hence `quantifier_depth(stavi_table_mu A) <= 2*r`.

The nf_profile uses depth `2*r` precisely to compensate for this: `nf_profile` at depth `2*r` determines truth of all StaviFormulas with stavi_depth <= r. This is already accounted for in the existing infrastructure.

**The real question** is: given depth-k NF agreement on original carriers, what rank r of formula_agreement can we achieve on the extended carriers?

### 3.6 The Actual Achievable Rank

The nf_profile lives on the extended carrier at depth `2*r`. If we want formula_agreement at rank r on ExtendedCarrier, we need nf_profile agreement at depth 2*r.

For a point x in M embedded as `extendPoint x` in `ExtendedCarrier M atomMap r`:
- The nf_profile is `nf_characteristic (extendedStructureWithMu M atomMap r) (2*r) 1 (fun _ => extendPoint x)`
- This involves evaluating MonadicFormulas of depth <= 2*r on the extended structure with mu
- The mu-extended structure has predicates from sig PLUS the mu predicate
- The quantifier domain is ALL of ExtendedCarrier (points AND gaps)

Given depth-k NF agreement on original carriers, we can derive agreement on `MonadicFormula sig 1` of depth <= k. But the extended structure uses `muSig sig` (with mu predicate) and has a larger carrier. The connection from depth-k original agreement to depth-2*r extended agreement is NOT trivial.

**However**, for the specific case of `extendPoint x` on a DISCRETE order (no gaps), `ExtendedCarrier M atomMap r = M.carrier` (via `discrete_no_gaps`). In this case:
- `extendedStructureWithMu` at a point has mu = true
- All quantifiers range over M.carrier (no gaps)
- The nf_profile reduces to the NF characteristic on the original structure with an extra mu predicate that is always true

For discrete orders, depth-k NF agreement on the original carrier gives depth-k NF agreement on the mu-extended structure (since mu is trivially true everywhere). This means:
- We can achieve nf_profile agreement at depth 2*r when 2*r <= k, i.e., r <= k/2
- With nf_profile agreement at depth 2*r, we get formula_agreement at rank r
- So we get formula_agreement at rank r = floor(k/2)

### 3.7 Is r = floor(k/2) Sufficient?

`nf_2var_existential_transfer` needs:
```
∀ j, j < k → ∀ chi : NormalForm sig j (2+1), (∃ u, ...) ↔ (∃ u', ...)
```

The game at rank r would give existential transfer at depths j where the game's formula budget covers it. But the game's formula_agreement is at stavi_depth <= r. The connection from formula_agreement at rank r to NF existential transfer at depth j is NOT direct -- the game handles this through its compositional structure (Composition.lean), not through a simple depth bound.

**For the direct NF induction approach** (the sorry at line 2353), the game is NOT used. The sorry needs 4-var NF transfer at depth j', which is a purely NF-theoretic statement. The game bypass in NFGameBridge.lean replaces this entire approach.

## 4. Conclusion: Path 1 Assessment

### 4.1 Path 1 Does NOT Directly Fix the Sorry

The sorry at line 2353 in `nf_2var_existential_transfer` is a 4-variable NF transfer problem. Path 1's mutual induction would provide `char_k` at depth k (which is already available via the IH in the existing induction). The sorry is not about lacking `char_k` -- it has `char_k`. The sorry is about the sub-interval splitting problem: zone matching gives the right point u' but cannot prove the 4-var NF agrees because sub-interval types for pairs in the 3-point configuration are not determined.

### 4.2 The Game Bypass IS the Right Path

As NFGameBridge.lean documents (lines 18-39), the correct resolution goes through the EF game:
1. NF hypotheses on original carriers => decomposition_agreement on extended carriers (Bridge A)
2. decomposition_agreement => ghr93_duplicator_wins (already proven, Decomposition.lean)
3. ghr93_duplicator_wins => NF agreement (Bridge B)

The game's compositional structure (Composition.lean, CustomGame.lean) handles the sub-interval splitting problem that the direct NF induction cannot.

### 4.3 Depth Arithmetic for the Game Bypass

For the game bypass, the relevant depth arithmetic is:

**Bridge A** (NF hypotheses => decomposition_agreement):
- Given: depth-k NF agreement on original carriers, char_k at depth k
- Need: decomposition_agreement at some (n, r) on extended carriers
- The x_t_formula construction gives depth-r StaviFormulas on ExtendedCarrier at rank r
- For discrete orders: r can be up to k (since ExtendedCarrier = M.carrier, no 2x penalty)
- For general orders: r can be up to floor(k/2) (due to the nf_profile depth-2*r requirement)

**Bridge B** (ghr93_duplicator_wins => NF agreement):
- Given: Duplicator wins G_{n;r}
- Get: formula_agreement at rank r on ExtendedCarrier
- This gives: same rank_type at rank r
- For NF agreement at depth k on original carrier: need to transfer back from extended

**For DISCRETE orders** (the immediate target):
- No gaps => ExtendedCarrier = M.carrier
- The 2x factor is absorbed: formula_agreement at rank r transfers directly
- r = k works (no penalty)
- This should be sufficient to prove the sorry

**For GENERAL orders**:
- The 2x factor matters: nf_profile at depth 2*r determines rank r
- Need r >= k-1 for the induction step? This would require 2*r >= k-1, so r >= ceil((k-1)/2)
- But the game also needs sufficient rounds n
- The full analysis requires understanding how game_depth(n) relates to the NF depth

### 4.4 The Discrete Case is Achievable

For discrete orders:
1. `discrete_no_gaps` (Defs.lean line 532) proves there are no gaps in succ-archimedean orders
2. `ExtendedCarrier M atomMap r` is isomorphic to `M.carrier` (all elements are points)
3. The mu predicate is trivially true everywhere
4. formula_agreement at rank k on the (trivially) extended carrier IS formula_agreement at stavi_depth <= k on the original carrier
5. This eliminates the 2x depth penalty concern entirely
6. The game at rank k with appropriate n gives the sub-interval splitting that resolves the sorry

### 4.5 Summary of Depth Arithmetic

| Parameter | Discrete Order | General Order |
|-----------|---------------|---------------|
| NF depth on carrier | k | k |
| nf_profile depth needed | 2*r | 2*r |
| Max r from depth-k NFs | k (no gaps, mu trivial) | floor(k/2) |
| formula_agreement rank | k | floor(k/2) |
| Sufficient for j < k? | YES (r = k > k-1) | UNCLEAR (r = floor(k/2) < k-1 for k >= 3) |

## 5. Implementation Recommendations

### 5.1 Discrete Case (Recommended First Target)

For discrete orders, the game bypass works cleanly:

1. Use `discrete_no_gaps` to show `ExtendedCarrier = M.carrier`
2. Build decomposition_agreement from NF hypotheses (Bridge A) at rank k
3. Use `ghr93_decomposition_implies_game` (already proven) to get game
4. Extract NF agreement from the game (Bridge B)

The depth arithmetic is clean: no 2x penalty, r = k suffices.

### 5.2 General Case (Requires Deeper Analysis)

For general orders with gaps, the 2x depth factor IS a real concern:
- r = floor(k/2) may be insufficient for transfer at all j < k
- The GHR93 proof handles this through the game_depth function (which grows much faster than k)
- The relationship between game_depth(n) and the NF depth k is: game_depth(n+1) = (1 + 3*game_depth(n)) * (2*K_n) + 2
- The game is played for a number of rounds n where game_depth(n) >= k
- This means the rank r in the game is game_depth(n), which is MUCH larger than k
- At this rank, formula_agreement covers stavi_depth <= game_depth(n) >> k, which more than compensates for the 2x factor

### 5.3 The Two Sorries

The two sorries at lines 2353 and 2435 of StaviCompleteness.lean are both in `nf_2var_existential_transfer`. They require 4-var existential transfer at depth j' for the 3-point configuration. The game bypass documented in NFGameBridge.lean is the correct resolution path. The depth arithmetic works for discrete orders without any concerns. For general orders, the game_depth function provides sufficient rank.

## 6. Direct Answer to the Four Questions

### Q1: The exact depth relationships

- `stavi_fo_depth(A) <= 2 * stavi_depth(A)` (proven)
- `nf_profile` uses depth `2*r` to determine rank `r` (by construction)
- `formula_agreement` at rank r checks `stavi_depth A <= r`
- `x_t_formula` has `stavi_depth <= r` (proven)
- `decomposition_agreement` at (n,r) lives on `ExtendedCarrier` at rank r

### Q2: The chain from NF agreement to formula_agreement

Given depth-k NF agreement at points:
- **Discrete**: Directly yields formula_agreement at rank k (no 2x penalty)
- **General**: Yields nf_profile agreement at depth min(2*r, k), so formula_agreement at rank floor(k/2)

### Q3: What rank does nf_2var_existential_transfer need?

It needs transfer at ALL j < k. The sorry is about 4-var NF transfer, not about formula_agreement rank. The game bypass replaces this entire approach.

### Q4: The critical test

- **Discrete**: YES, Path 1 works. r = k is achievable, which exceeds k-1.
- **General**: The game_depth function makes it work, but the analysis is more complex. The EF game at sufficient rounds provides rank >> k.
