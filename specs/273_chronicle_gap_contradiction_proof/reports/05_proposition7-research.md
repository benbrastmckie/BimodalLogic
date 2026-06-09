# Research Report: GHR93 Proposition 7 Formalization for Task 273

**Task**: 273 (Chronicle Gap Contradiction Proof)
**Focus**: Determine exactly what is needed to formalize GHR93 Proposition 7 + Theorem 6 in Lean 4
**Date**: 2026-06-08

---

## 1. GHR93 Proposition 7: Formal Statement and Proof Structure

### 1.1 What Proposition 7 States

GHR93 Proposition 7 (page 114, Section 8) states:

> **Proposition 7.** For all n < omega the following holds. Let M, N be linear temporal structures and let x_1 < ... < x_m, y_1 < ... < y_m be increasing m-tuples of elements of M, N respectively, for arbitrary m < omega. Define x_0 = -infinity and x_{m+1} = +infinity in M; define y_0, y_{m+1} similarly.
>
> Suppose that Duplicator has winning strategies for G_{f(n);g(n)+4f(n)}(M, x_i x_{i+1}; N, y_i y_{i+1}) and G_{f(n);g(n)+4f(n)}(N, y_i y_{i+1}; M, x_i x_{i+1}) for all 0 <= i <= m.
>
> Then Duplicator has a winning strategy for the Ehrenfeucht-Fraisse game G_n((M, x), (N, y)).

Where f, g are functions satisfying:
- f(0) = g(0) = 0
- f(n+1) > (1 + 3*f(n)) * (2*k_n) + 1
- g(n+1) > g(n) + 4*f(n)
- k_n is the number of inequivalent (1+3*f(n));(g(n)+4*f(n))-decomposition formulas.

### 1.2 What This Means for Task 273

For the sorry sites, we need a simpler form: given that Duplicator wins G_{0;r} on all sub-intervals of a 2-point configuration (x,t)/(x',t'), she wins G_{n;r'} for arbitrary n on the full interval. The key insight is:

- **n=0 case** (base): `discrete_nf_to_decomposition_agreement` already proves this (Bridge A). From the NF bridge hypotheses (1-var NF agreement, orderings, interval types), we get `decomposition_agreement` at n=0 and r=k/2. Via `ghr93_decomposition_implies_game`, Duplicator wins G_{0;k/2}(M, x t; N, x' t').

- **n -> n+1 step**: This is the content of Proposition 7. Given winning sub-interval strategies at n, Duplicator wins the (n+1)-round game on the full interval.

- **Application**: The sorry sites need existential transfer at depth j < k for 3-var extensions. This requires matching an arbitrary number of challenge points (one per depth level), which is exactly what the n-round game provides. With n large enough (n >= k), the game gives enough rounds to handle all depth levels.

### 1.3 Induction Structure of Proposition 7

The proof is by induction on n:

**Base (n=0)**: Trivial. When no first-round elements are selected, Duplicator only needs to respond to a single point challenge (Round 2). She uses the sub-interval strategy directly.

**Inductive step (n -> n+1)**: Suppose Duplicator has winning strategies for G_{f(n+1);r}(M, x_i x_{i+1}; N, y_i y_{i+1}) for all sub-intervals. Given Spoiler's choice of alpha in the (n+1)-round EF game:

1. Determine which sub-interval (x_i, x_{i+1}) contains alpha.
2. List the (1+3*f(n));r-decomposition formulas satisfied by (x_i, alpha) and (alpha, x_{i+1}).
3. Apply the sub-interval strategy to choose Duplicator's response e corresponding to alpha, picking enough witnesses to cover the decomposition formulas. This uses at most (1 + 3*f(n))*(j + k) + 1 elements.
4. By Lemma 11, the response e satisfies the same decomposition formulas as alpha.
5. **Crucially, by Theorem 6**: the decomposition formula agreement gives Duplicator winning strategies for "backward" games on the new sub-intervals (x_i, alpha)/(y_i, e) and (alpha, x_{i+1})/(e, y_{i+1}).
6. By the induction hypothesis (n), Duplicator wins the remaining n rounds.

### 1.4 Theorem 6: The Backward Game Transfer

Theorem 6 (page 113) is the other critical piece:

> **Theorem 6.** Suppose M, N are linear temporal structures. Then (*)_n holds for all n < omega:
>
> (*)_n: For all r, if Duplicator has a winning strategy for G_{1+3n;r+4n}(M, xy; N, x'y'), then she has a winning strategy for G_{n;r}(N, x'y'; M, xy).

This says: if Duplicator wins "enough" forward games (M->N), she wins backward games (N->M). The proof is by induction on n with four cases depending on whether alpha_n is a point, a left-definable gap, a right-definable gap, or a non-left-definable gap.

**For discrete orders**: Theorem 6 simplifies dramatically because there are no gaps. Only Case I and Case II apply (the point cases). Cases III and IV (gap cases) are vacuously true.

### 1.5 Role of Decomposition Formulas

Decomposition formulas (Definition 8.8, page 112) encode:
- The rank-r types at each selected element y_i
- The types realized in each sub-interval (y_i, y_{i+1})
- Whether each y_i is a point or gap

Lemma 11 proves: G_{n;r} game agreement <=> agreement on all (n;r)-decomposition formulas. This is already formalized as:
- `ghr93_game_implies_decomposition` (Decomposition.lean:117)
- `ghr93_decomposition_implies_game` (Decomposition.lean:272)

---

## 2. Complete Inventory of Existing Infrastructure

### 2.1 Defs.lean (559 lines)

| Lemma/Def | Line | Type | Purpose |
|-----------|------|------|---------|
| `stavi_depth` | 164 | def | Depth of StaviFormula |
| `stavi_n_equiv` | 180 | def | n-equivalence on pointed structures |
| `game_depth` | 88 | def | Depth function f(n) for EF games |
| `Gap` | 236 | structure | Dedekind cut with no supremum |
| `ExtendedCarrier` | 336 | def | M.carrier + r-definable gaps |
| `IsPoint`, `IsGap` | 431, 439 | def | Point/gap classification |
| `extendPoint` | 451 | def | Embed point into ExtendedCarrier |
| `discrete_no_gaps` | 532 | theorem | Succ-archimedean orders have no gaps |
| `gap_definable_on_left/right` | 287, 301 | def | Gap definability |

### 2.2 CustomGame.lean (1703 lines)

| Lemma/Def | Line | Type | Purpose |
|-----------|------|------|---------|
| `inClosedInterval` | 39 | def | Element in [x,y] |
| `game_tuple` | 106 | def | (n+3)-tuple: x, a_1..a_n, b, y |
| `game_tuple_sel_eq` | 121 | theorem | Simplify game_tuple at selection index |
| `game_tuple_zero_eq` | 147 | theorem | game_tuple at 0 = x |
| `game_tuple_b_eq` | 154 | theorem | game_tuple at n+1 = b |
| `game_tuple_y_eq` | 162 | theorem | game_tuple at n+2 = y |
| `same_order_type` | 228 | def | Order agreement on tuples |
| `formula_agreement` | 239 | def | Rank-r formula agreement |
| `gap_point_agreement` | 250 | def | Gap/point status agreement |
| `ghr93_winning_condition` | 262 | def | Combined winning condition |
| `ghr93_duplicator_wins` | 285 | def | Duplicator has winning strategy for G_{n;r} |
| `ghr93_duplicator_wins_degenerate_gap` | 314 | theorem | Degenerate gap interval |
| `ghr93_duplicator_wins_round_mono` | ~441 | theorem | n' <= n -> game at n implies n' |
| `ghr93_strategy_restrict_left` | 1241 | theorem | Restrict (n+1)-game to left sub-interval |
| `ghr93_strategy_restrict_right` | 1470 | theorem | Restrict (n+1)-game to right sub-interval |

### 2.3 Composition.lean (626 lines)

| Lemma/Def | Line | Type | Purpose |
|-----------|------|------|---------|
| `ghr93_strategy_compose` | 40 | theorem | **KEY**: Left + Right strategies -> Full strategy at same n,r |

**Signature**:
```lean
theorem ghr93_strategy_compose
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
    (hxc : x <= c) (hcy : c <= y) (hx'd : x' <= d) (hdy' : d <= y')
    (hcd_type : forall A, stavi_depth A <= r -> (stavi_temporal_truth_mu M ... c A <-> stavi_temporal_truth_mu N ... d A))
    (hcd_gp : (IsPoint c <-> IsPoint d) /\ (IsGap c <-> IsGap d))
    (h_compat_R : ...) (h_compat_L : ...)
    (h_left : ghr93_duplicator_wins M N atomMap n r x c x' d)
    (h_right : ghr93_duplicator_wins M N atomMap n r c y d y') :
    ghr93_duplicator_wins M N atomMap n r x y x' y'
```

**Critical observation**: This composes at the SAME n and r. It takes two sub-interval strategies at (n, r) and produces a full-interval strategy at (n, r). This is the building block for Proposition 7.

### 2.4 Decomposition.lean (315 lines)

| Lemma/Def | Line | Type | Purpose |
|-----------|------|------|---------|
| `decomposition_agreement` | 62 | def | Semantic (n;r)-decomposition agreement |
| `ghr93_game_implies_decomposition` | 117 | theorem | Game win -> decomp agreement |
| `ghr93_decomposition_implies_game` | 272 | theorem | Decomp agreement -> game win |
| `ghr93_game_iff_decomposition` | 302 | theorem | Iff version |

### 2.5 NFGameBridge.lean (1237 lines)

| Lemma/Def | Line | Type | Purpose |
|-----------|------|------|---------|
| `nf_agreement_from_nf_char_eq` | 58 | theorem | 1-var NF char eq -> NF eval iff |
| `nf_char_depth_le` | 104 | theorem | depth-k NF agree -> depth-j agree (j <= k) |
| `nvar_nf_eq_depth_zero` | 127 | theorem | depth-0 n-var NF from atom agreement |
| `atom_agree_from_pointwise_nf` | 140 | theorem | n-var atom agree from pointwise 1-var NF + orderings |
| `discrete_muSig_nf_agree` | 332 | theorem | sig NF agree -> muSig NF agree (discrete, any n) |
| `discrete_nf_profile_agree` | 503 | theorem | depth-k NF agree -> nf_profile agree |
| `discrete_rank_type_agree` | 531 | theorem | depth-k NF agree -> rank_type agree at k/2 |
| `discrete_formula_agree_from_nf` | 749 | theorem | depth-k NF agree -> StaviFormula agree at k/2 |
| `discrete_winning_condition_0` | 815 | theorem | 3-element winning condition from pairwise NF + orderings |
| `discrete_nf_to_decomposition_agreement` | 997 | theorem | **Bridge A**: NF hypotheses -> decomp agreement at n=0, r=k/2 |
| `existential_transfer_from_nf` | 719 | theorem | n-var NF agree at d+1 -> (n+1)-var existential transfer at d |
| `game_win_to_formula_agree` | 1222 | theorem | Extract formula agreement from winning condition |

### 2.6 StaviCompleteness.lean (3270 lines) -- Sorry Sites

| Lemma/Def | Line | Type | Purpose |
|-----------|------|------|---------|
| `zone_match_witness` | 2044 | theorem | Find u' matching u with same NF and orderings |
| `nf_2var_existential_transfer` | 2214 | theorem | **SORRY at 2353, 2435**: 3-var existential transfer |
| `nf_2var_from_interval_data` | 2448 | theorem | 2-var NF from 1-var NFs + interval data (calls above) |
| `nf_exist_sf_guarded_backward` | 2778 | theorem | **SORRY at 2805**: backward bridge lemma |
| `nf_2var_exist_sf_classical` | 2810 | theorem | Classical StaviFormula characterization (calls above) |

---

## 3. The Three Sorry Sites -- Exact Type Signatures

### Sorry 1 (line 2353): Forward 4-var transfer
```
-- Context: inside nf_2var_existential_transfer, forward case, j = j'+1
-- Have: u zone-matched to u', with 1-var NF agreement at depth k
-- Have: hu_quant sub_nf : nf_eval quantifier data
-- Need:
(exists w, nf_eval_nf M j' 4 (w :: u :: x :: t) sub_nf) <->
(exists w', nf_eval_nf M' j' 4 (w' :: u' :: x' :: t') sub_nf)
```

### Sorry 2 (line 2435): Backward 4-var transfer (symmetric)
Same as Sorry 1 but in the backward direction (M' -> M).

### Sorry 3 (line 2805): `nf_exist_sf_guarded_backward`
```
-- Context: Given temporal formula truth, extract NF witness
-- Have: stavi_temporal_truth M atomMap t (nf_exist_sf_guarded ...)
-- Need: exists x, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
```
This sorry depends on `nf_2var_from_interval_data`, which depends on `nf_2var_existential_transfer`. Fixing sorries 1 and 2 would automatically fix sorry 3.

---

## 4. Gap Analysis: What is Missing

### 4.1 The Core Missing Piece

The sorry sites need: **given Duplicator's winning strategy for G_{0;r} on the full interval (x,t)/(x',t'), produce a winning strategy for G_{n;r'} for arbitrary n** (or equivalently, produce existential NF transfer at arbitrary depth).

The existing code proves:
1. NF hypotheses -> decomposition_agreement at n=0 (Bridge A, `discrete_nf_to_decomposition_agreement`)
2. decomposition_agreement -> game win (Lemma 11, `ghr93_decomposition_implies_game`)
3. Game at (n, r) on left + right sub-intervals -> game at (n, r) on full interval (`ghr93_strategy_compose`)

What is missing:
- **Proposition 7 step**: Game at (f(n), g(n)+4f(n)) on all sub-intervals -> EF game G_n on full configuration
- **Theorem 6 step**: Forward game G_{1+3n;r+4n} -> backward game G_{n;r}
- **Bridge B**: Game win at sufficient rounds -> NF existential transfer at depth j

### 4.2 Why the Existing Infrastructure is Insufficient

`ghr93_strategy_compose` composes strategies at the SAME n. To build a game at n=1 from games at n=0 on sub-intervals, we need a theorem that:
1. Takes a G_{0;r} game on the full interval
2. When Spoiler places one element alpha, splitting the interval
3. Uses the G_{0;r} game to match alpha with e preserving decomposition formulas
4. Then uses G_{0;r'} games on the sub-intervals (x,alpha)/(x',e) and (alpha,t)/(e,t')
5. Composes via `ghr93_strategy_compose`

The key gap: step 4 needs G_{0;r'} on sub-intervals. For the NEW sub-intervals created by Spoiler's choice, we need to derive sub-interval strategies from the full-interval strategy. This is exactly what `ghr93_strategy_restrict_left` and `ghr93_strategy_restrict_right` do -- but they require a game at n+1 to derive a game at n on sub-intervals, not a game at n=0.

### 4.3 Simplified Architecture for Discrete Orders

For discrete orders (the target of `completeness_discrete`), the architecture simplifies significantly:

1. **No gaps**: `discrete_no_gaps` proves ExtendedCarrier = M.carrier. This eliminates Cases III and IV of Theorem 6.

2. **Direct formula-NF bridge**: `discrete_formula_agree_from_nf` converts depth-k NF agreement to StaviFormula agreement at rank k/2, and `discrete_rank_type_agree` gives rank_type agreement. These bridges work FOR DISCRETE ORDERS ONLY.

3. **The game win gives everything**: When Duplicator wins G_{n;r} and matches a point b to b', she gets formula_agreement at rank r. For discrete orders, this means StaviFormula agreement, which via `discrete_muSig_nf_agree` gives NF agreement. Since the game handles the compositional structure automatically, no sub-interval type data is needed explicitly.

---

## 5. Concrete Implementation Plan

### 5.1 Strategy Overview

The plan implements a **discrete-only inductive argument** that avoids the full generality of Proposition 7 + Theorem 6. For discrete orders:

- Theorem 6 simplifies to only point cases (no gap cases)
- The depth/rank relationship is controlled: NF depth k <-> StaviFormula rank k/2
- `ghr93_strategy_compose` provides the compositional spine

The key new theorem: **for discrete orders, given Bridge A (game at n=0, r=k/2 on the full interval), Duplicator wins G_{0;r'} for any r' <= k/2 on ALL sub-intervals created by matching any finite number of points.**

### 5.2 Lemma Sequence

#### Phase A: Discrete Theorem 6 (backward game transfer)

**Lemma A1**: `discrete_theorem6_base` (n=0 case)
- **File**: NFGameBridge.lean
- **Signature**:
  ```lean
  theorem discrete_theorem6_base {sig : MonadicSignature}
      {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {r : Nat}
      [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
      [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
      [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
      [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
      {x y : ExtendedCarrier M atomMap (r + 4)} {x' y' : ExtendedCarrier N atomMap (r + 4)}
      (h_fwd : ghr93_duplicator_wins M N atomMap 1 (r + 4) x y x' y') :
      ghr93_duplicator_wins N M atomMap 0 r x' y' x y
  ```
- **Uses**: `ghr93_duplicator_wins_round_mono`, Case I/II of Theorem 6 proof
- **Estimated**: 80-120 lines
- **Proof sketch**: Given G_{1;r+4}(M,xy;N,x'y'), when Spoiler picks b in [x,y] for the backward game G_{0;r}(N,x'y';M,xy), Duplicator applies the forward strategy with 1 element (b itself), gets b' with formula agreement at rank r+4 >= r. Since discrete, this is sufficient.

**Lemma A2**: `discrete_theorem6_step` (inductive case)
- **File**: NFGameBridge.lean
- **Signature**:
  ```lean
  theorem discrete_theorem6_step {sig : MonadicSignature}
      {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {n r : Nat}
      [... discrete instances ...]
      (h_fwd : ghr93_duplicator_wins M N atomMap (1 + 3*(n+1)) (r + 4*(n+1)) x y x' y') :
      ghr93_duplicator_wins N M atomMap (n+1) r x' y' x y
  ```
- **Uses**: `ghr93_strategy_compose`, `ghr93_strategy_restrict_left/right`, Lemma A1, induction
- **Estimated**: 150-250 lines
- **Proof sketch**: Following Theorem 6 Cases I and II only (no gaps). Spoiler picks n+1 points alpha_0..alpha_n. Define c = inf{t : C holds on (t,y)} per the GHR93 proof. For discrete orders, c is always a point (no gaps). By Claim 2 of Theorem 6, restrict the forward strategy to sub-intervals to get backward strategies. Apply induction hypothesis on sub-intervals, then compose.

#### Phase B: Discrete Proposition 7

**Lemma B1**: `discrete_prop7_base` (n=0 case)
- **File**: NFGameBridge.lean (or new file Proposition7.lean)
- **Signature**:
  ```lean
  theorem discrete_prop7_base {sig : MonadicSignature}
      {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {r : Nat} {m : Nat}
      [... discrete instances ...]
      (xs : Fin m → M.carrier) (ys : Fin m → N.carrier)
      (h_sorted_x : StrictMono xs) (h_sorted_y : StrictMono ys)
      (h_sub_fwd : ∀ i : Fin (m + 1),
        ghr93_duplicator_wins M N atomMap f0 r
          (left_bound xs i) (right_bound xs i)
          (left_bound ys i) (right_bound ys i))
      (h_sub_bwd : ∀ i : Fin (m + 1),
        ghr93_duplicator_wins N M atomMap f0 r
          (left_bound ys i) (right_bound ys i)
          (left_bound xs i) (right_bound xs i)) :
      -- G_0 on the full EF game
      ∀ φ : monadic_formula, quantifier_depth φ = 0 →
        eval M xs φ ↔ eval N ys φ
  ```
- **Estimated**: 40-60 lines (trivial, no quantifiers at depth 0)

**Lemma B2**: `discrete_prop7_step` (n -> n+1)
- **File**: NFGameBridge.lean or Proposition7.lean
- **Signature**:
  ```lean
  theorem discrete_prop7_step {sig : MonadicSignature}
      {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {n r : Nat} {m : Nat}
      [... discrete instances ...]
      (xs : Fin m → M.carrier) (ys : Fin m → N.carrier)
      (h_sub_strategies : ∀ i : Fin (m + 1),
        ghr93_duplicator_wins M N atomMap (f (n+1)) (g (n+1))
          (left_bound xs i) (right_bound xs i)
          (left_bound ys i) (right_bound ys i) ∧
        ghr93_duplicator_wins N M atomMap (f (n+1)) (g (n+1))
          (left_bound ys i) (right_bound ys i)
          (left_bound xs i) (right_bound xs i))
      -- Induction hypothesis at n
      (IH : ∀ (m' : Nat) (xs' : Fin m' → M.carrier) (ys' : Fin m' → N.carrier) ...,
        ... sub-interval strategies at f(n), g(n)+4f(n) → G_n agreement) :
      -- G_{n+1} agreement
      ∀ α ∈ M, ∃ e ∈ N, -- Duplicator's response
        IH applies to extended configuration (xs ++ [α], ys ++ [e])
  ```
- **Estimated**: 200-350 lines (the main complexity)
- **Uses**: `ghr93_strategy_compose`, `ghr93_strategy_restrict_left/right`, Theorem 6 (Lemma A2), Lemma 11 equivalence
- **Proof sketch**: When Spoiler picks alpha in (x_i, x_{i+1}), list decomposition formulas and use the sub-interval strategy to find e. By Lemma 11, e matches alpha on decomposition formulas. By Theorem 6, derive backward strategies on the new sub-intervals. Apply IH.

#### Phase C: Bridge B -- Game Win to NF Transfer (Discrete)

**Lemma C1**: `discrete_game_to_nf_transfer`
- **File**: NFGameBridge.lean
- **Signature**:
  ```lean
  theorem discrete_game_to_nf_transfer {sig : MonadicSignature}
      {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {k : Nat}
      [... discrete instances ...]
      (x t : M.carrier) (x' t' : M'.carrier)
      (h_game : ghr93_duplicator_wins M M' atomMap n (k/2) 
        (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t'))
      (h_game_bwd : ghr93_duplicator_wins M' M atomMap n (k/2)
        (extendPoint x') (extendPoint t') (extendPoint x) (extendPoint t))
      (h_n_ge : n >= k) :
      ∀ j, j < k →
        ∀ chi : NormalForm sig j (2 + 1),
          (∃ u, nf_eval_nf M j (2 + 1) (Fin.cons u (Fin.cons x (fun _ => t))) chi) ↔
          (∃ u', nf_eval_nf M' j (2 + 1) (Fin.cons u' (Fin.cons x' (fun _ => t'))) chi)
  ```
- **Uses**: `game_win_to_formula_agree`, `discrete_formula_agree_from_nf`, induction on j
- **Estimated**: 150-250 lines
- **Proof sketch**: Induction on j. At j=0, atoms only (existing `nvar_nf_eq_depth_zero`). At j+1, use the game to match each challenge point, extracting formula agreement which (for discrete) gives NF agreement. The game has enough rounds (n >= k > j) to provide matching at every depth level.

**Lemma C2**: `discrete_nf_2var_existential_transfer` (replaces sorry)
- **File**: StaviCompleteness.lean (or NFGameBridge.lean)
- **Signature**: Same as `nf_2var_existential_transfer` but with discrete instances
- **Uses**: Bridge A + Lemma C1
- **Estimated**: 40-80 lines (wiring)
- **Proof sketch**: Apply Bridge A to get decomposition agreement at n=0. Convert to game win. Use Proposition 7 to build game at n=k. Apply Lemma C1.

#### Phase D: Sorry Elimination

**Step D1**: Replace sorry at line 2353 with `discrete_nf_2var_existential_transfer`
**Step D2**: Replace sorry at line 2435 with symmetric version
**Step D3**: Sorry at line 2805 auto-resolves since it depends on `nf_2var_from_interval_data` which calls `nf_2var_existential_transfer`

### 5.3 Alternative Simplified Path (Recommended)

After careful analysis, there is a simpler path that avoids the full Proposition 7 machinery. The key observation:

**For discrete orders, the game at n=0 already gives existential transfer by iterated application.**

The sorry needs 4-var existential transfer at depth j'. The game G_{0;k/2} provides a point-matching oracle: given any b' in M', find b in M with formula agreement at rank k/2. For discrete orders, formula agreement at rank k/2 implies NF agreement at depth 2*(k/2) >= k-1.

The iteration works as follows:
1. To prove existential transfer at depth j' for the 3-point config (u,x,t)/(u',x',t'):
2. Match w to w' using the game oracle on the sub-interval containing w
3. This gives 1-var NF agreement at w/w' at depth >= k-1 >= j'
4. With 1-var NF agreement at all 4 points + orderings, get atom agreement at 4 vars
5. For depth 0: done via atoms
6. For depth d+1: the 5-var existential transfer at depth d uses the same game oracle
7. Depth strictly decreases, terminating at 0

**The critical missing piece**: sub-interval game strategies. When w is in (x,u), we need a game on (x,u)/(x',u'). We get this by RESTRICTING the full-interval game.

**New key theorem**: `discrete_game_restrict_to_subinterval` -- for discrete orders, a game at G_{0;r} on (x,t)/(x',t') where Duplicator matches u to u' gives a game at G_{0;r} on sub-intervals (x,u)/(x',u') and (u,t)/(u',t').

This is simpler than full Proposition 7 because:
- We only need n=0 (no first-round selections)
- We only need it for discrete orders (no gaps)
- The restrict_left/right theorems already exist (but require n+1 games)

### 5.4 Final Recommended Sequence

1. **`discrete_game_subinterval_restrict`** (NEW, ~100-150 lines): Given G_{0;r} on (x,t) and a matched pair (u,u') within the interval, derive G_{0;r} on (x,u)/(x',u') and (u,t)/(u',t'). This uses the existing `ghr93_strategy_restrict_left/right` by promoting the 0-game to a 1-game with u as the fixed element.

2. **`discrete_iterated_game_transfer`** (NEW, ~150-200 lines): By induction on depth j, prove: if G_{0;r} on (x,t) with r >= k/2 and k > j, then existential transfer at depth j for arbitrary n-var extensions. The game oracle matches each new point, the sub-interval restriction provides game strategies on sub-intervals, and the induction decreases depth.

3. **Wire into sorry sites** (~50-100 lines): Apply `discrete_nf_to_decomposition_agreement` (Bridge A) + `ghr93_decomposition_implies_game` to get the game, then apply `discrete_iterated_game_transfer` to close the sorry.

**Total estimated new code**: 300-450 lines.

---

## 6. Dependency Diagram

```
  [NF hypotheses: 1-var NF agree, orderings, interval types]
                    |
                    v
  [discrete_nf_to_decomposition_agreement]  -- Bridge A (DONE, sorry-free)
                    |
                    v
  [decomposition_agreement at n=0, r=k/2]
                    |
                    v
  [ghr93_decomposition_implies_game]  -- Lemma 11 backward (DONE)
                    |
                    v
  [ghr93_duplicator_wins at n=0, r=k/2]
                    |
         +---------+---------+
         |                   |
         v                   v
  [discrete_game_         [game_win_to_
   subinterval_restrict]    formula_agree]  -- (DONE)
   (NEW: ~100 lines)              |
         |                        v
         v               [discrete_formula_
  [sub-interval games]     agree_from_nf]  -- (DONE)
         |                        |
         +--------+-------+------+
                  |
                  v
  [discrete_iterated_game_transfer]  (NEW: ~150-200 lines)
                  |
                  v
  [nf_2var_existential_transfer]  -- SORRY ELIMINATED
                  |
                  v
  [nf_2var_from_interval_data]  -- auto-resolves
                  |
                  v
  [nf_exist_sf_guarded_backward]  -- SORRY ELIMINATED
                  |
                  v
  [stavi_expressive_completeness]  -- complete chain
```

---

## 7. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Sub-interval game restriction requires n+1 game (existing restrict needs n+1 to get n) | Medium | High | Prove a new variant that restricts n=0 game by using the matched point as a fixed "padding" element in the n=1 version |
| Odd-k parity issue: k/2 gives NF at depth 2*(k/2) which is k-1 for odd k, losing one depth level | Medium | Medium | Use ceiling division or adjust the rank parameter (pass r = (k+1)/2 instead of k/2) |
| Iterated game transfer has variable-count blowup: depth j needs 2+j variables | Low | Medium | NF infrastructure is parametric in variable count; `existential_transfer_from_nf` handles arbitrary n |
| Discrete instances propagate awkwardly through game infrastructure (ExtendedCarrier has its own linear order) | Low | Low | `discrete_no_gaps` ensures ExtendedCarrier = M.carrier; existing bridge lemmas handle this |
| Formula agreement at rank r = NF agreement at depth 2r is not tight enough | Medium | High | Verify the exact relationship; may need r = k instead of r = k/2 if the factor-of-2 conversion loses precision |

### Critical Risk: The Rank-Depth Conversion

The most critical risk is the rank-depth conversion. The existing code uses r = k/2 in Bridge A. The conversion chain is:
- Game at rank r gives `formula_agreement` at rank r (StaviFormula agreement)
- `discrete_formula_agree_from_nf` converts: depth-k NF agreement -> StaviFormula agreement at rank k/2
- The REVERSE direction needs: StaviFormula agreement at rank r -> NF agreement at depth 2r

The reverse direction requires `stavi_temporal_truth` to determine `nf_eval_nf`. This is exactly what the completeness theorem proves! So there is a potential circularity.

**Resolution**: The iterated game transfer does NOT need the full reverse direction. It only needs:
1. Formula agreement at rank r for MATCHED POINTS (given by game)
2. 1-var NF agreement at matched points (given by zone_match within the game)
3. Atom agreement at the multi-var environment (derived from 1 + 2 above)
4. Recursive transfer at lower depth (induction hypothesis)

The game provides the witness matching WITHOUT needing to convert formula agreement back to NF agreement. The NF agreement comes from the zone_match oracle, not from the formula agreement.

---

## 8. Summary

The sorry sites at StaviCompleteness.lean:2353,2435,2805 require 4-variable existential transfer that cannot be proved by zone-matching alone due to the sub-interval type problem. The resolution is to use the EF game pipeline:

1. Bridge A (already done) converts NF hypotheses to a game win at n=0, r=k/2
2. The new `discrete_game_subinterval_restrict` derives sub-interval game strategies
3. The new `discrete_iterated_game_transfer` proves existential transfer by induction on depth, using the game oracle for witness matching and the sub-interval restriction for recursive sub-problems
4. The sorry sites are closed by composing Bridge A + new lemmas

Estimated new code: 300-450 lines across NFGameBridge.lean and StaviCompleteness.lean.

This approach is specific to discrete orders (sufficient for `completeness_discrete`) and avoids the full generality of GHR93 Proposition 7 + Theorem 6.
