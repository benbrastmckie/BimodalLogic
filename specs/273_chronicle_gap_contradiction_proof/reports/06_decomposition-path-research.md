# Task 273 Research Report: GHR93 Decomposition-Formula Path

## 1. GHR93 Decomposition-Formula Proof Path (Exact Steps)

### 1a. Lemma 11 (Game <-> Decomposition Agreement)

**Reference**: GHR93 p.112, lines 1222-1242 in the OCR.

**Statement**: Let M, N be linear temporal structures, x < y in M_r, x' < y' in N_r, and n, r < omega. The following are equivalent:

1. Duplicator has a winning strategy for G_{n;r}(M, xy; N, x'y').
2. For all (n;r)-decomposition formulas phi(x1,x2), M_r |= phi(x,y) implies N_r |= phi(x',y').

**Decomposition formulas** (Definition 8.8, p.112, lines 1204-1221): An (n;r)-decomposition formula specifies:
- (a) For each element in the sequence x, y1, ..., yn, y2: whether it is a point or gap, and its rank-r type (conjunction of rank-r StaviFormulas satisfied there).
- (b) For each pair of adjacent elements a < b: the set of rank-r types realized by actual points in the interval (a,b).

The **forward direction** (game -> decomposition): trivial -- Duplicator's strategy provides matching selections.

The **backward direction** (decomposition -> game): From the decomposition agreement, construct Duplicator's strategy. Round 1 response uses the forward matching condition. Round 2 point challenge uses the "point challenge" clause in the decomposition formula, which ensures for any actual point b' in [x',y'], there exists an actual point b in [x,y] with matching rank-r type and correct ordering.

### 1b. Proposition 7 (Main Composition)

**Reference**: GHR93 p.115, lines 1293-1340.

**Statement**: For all n < omega: Let M, N be linear temporal structures with increasing m-tuples x1 < ... < xm in M, y1 < ... < ym in N. Define x0 = -inf, x_{m+1} = +inf, and similarly y0, y_{m+1}. Suppose Duplicator has winning strategies for:
- G_{f(n);g(n)}(M, xi xi+1; N, yi yi+1) for all 0 <= i <= m
- G_{f(n);g(n)}(N, yi yi+1; M, xi xi+1) for all 0 <= i <= m

Then Duplicator has a winning strategy for the standard EF game G_n((M,x),(N,y)).

**Proof structure** (by induction on n):
- n=0: trivial.
- n -> n+1: Suppose Spoiler picks alpha in M (WLOG). Let i be such that xi < alpha < xi+1. List all (1+3f(n));r-decomposition formulas satisfied by (xi, alpha) as phi_1,...,phi_j and those satisfied by (alpha, xi+1) as psi_1,...,psi_k. The total number of witnesses needed is at most n' = (1+3f(n))*(j+k) + 1 <= f(n+1) elements.

  Apply the winning strategy for G_{f(n+1);r}(M, xi xi+1; N, yi yi+1). Let e be the point Duplicator chooses corresponding to alpha. **By Lemma 11**, we get:
  - N_r |= phi_s(yi, e) for all s <= j (left sub-interval decomposition agreement)
  - N_r |= psi_s(e, yi+1) for all s <= k (right sub-interval decomposition agreement)

  **By Lemma 11 (backward direction)**, Duplicator has winning strategies for:
  - G_{1+3f(n);r}(M, xi alpha; N, yi e)
  - G_{1+3f(n);r}(M, alpha xi+1; N, e yi+1)

  **By Theorem 6** (forward-to-backward game inversion), she also has:
  - G_{f(n);g(n)}(N, yi e; M, xi alpha)
  - G_{f(n);g(n)}(N, e yi+1; M, alpha xi+1)

  By induction hypothesis, Duplicator wins G_n((M, x concatenated alpha), (N, y concatenated e)).

### 1c. The f, g Rank Functions (Definition 8.9)

**Reference**: GHR93 p.114, lines 1290-1292.

**Definition**: Let f, g be functions on omega satisfying:
- f(0) = g(0) = 0
- f(n+1) > (1 + 3f(n)) * (2*k_n) + 1
- g(n+1) > g(n) + 4*f(n)

where k_n is the number of inequivalent (1+3f(n));(g(n)+4f(n))-decomposition formulas.

**Critical observation**: In the codebase, `game_depth` (Defs.lean:88-93) implements a similar function but not identical. The codebase uses `game_depth sig (n+1) = (1 + 3 * game_depth sig n) * (2 * Fintype.card (NormalForm sig (game_depth sig n) 1)) + 2`.

**For discrete orders**: The rank parameter r in the game is fixed. Bridge A (NFGameBridge.lean:997) produces decomposition_agreement at n=0, r=k/2. The question is whether k/2 suffices or whether we need the growing g(n). Since discrete orders have no gaps and M_r = M, the rank parameter is less critical -- all elements are actual points, and there are no gap-defined elements to worry about.

### 1d. Simplification for Discrete Orders

For discrete orders:
1. **No gaps**: `discrete_no_gaps` (Defs.lean:532) proves `IsEmpty (Gap T)` for succ-archimedean orders. So M_r = M for all r; ExtendedCarrier is just M.carrier (via Sum.inl).
2. **Cases III and IV of Theorem 6 are vacuous**: These handle gap-defined points (alpha_n being a gap). In discrete orders, all points in [x,y]_r are actual points.
3. **Only Cases I and II apply**: Case I is when alpha_0 < d-tilde (the split point is between some of the chosen elements). Case II is when all chosen points lie on one side.
4. **The full Proposition 7 induction on n IS needed** even for discrete orders -- it handles the back-and-forth n-round game. However, the rank parameter can likely stay fixed at k/2 (no gap-related rank inflation needed).

## 2. Complete Codebase Inventory

### 2a. Decomposition.lean (315 lines, sorry-free)

| Lemma | Line | Type Signature Summary | What It Does |
|-------|------|----------------------|-------------|
| `decomposition_agreement` | 62 | `M N atomMap n r x y x' y' : Prop` | Semantic characterization of (n;r)-decomposition formula agreement. Has forward (M->N) and backward (N->M) conditions with point challenges. |
| `ghr93_game_implies_decomposition` | 117 | `h_pt -> h_pt_M -> h_game -> h_bwd -> decomposition_agreement` | **Lemma 11 forward**: game win -> decomposition agreement. Extracts boundary types, selection types, gap/point status, order preservation, and point challenges from game winning conditions. |
| `ghr93_decomposition_implies_game` | 272 | `h_pt -> h_pt_M -> decomposition_agreement -> ghr93_duplicator_wins` | **Lemma 11 backward**: decomposition agreement -> game win. Constructs Duplicator's strategy directly from the matching conditions. |
| `ghr93_game_iff_decomposition` | 302 | `ghr93_duplicator_wins <-> decomposition_agreement` | Lemma 11 iff version (combines forward and backward). |

**Key insight**: `decomposition_agreement` at n=0 is the simplest form -- no inner selections (Fin 0), just boundary type agreement plus the point challenge condition. This is exactly what Bridge A produces.

### 2b. NFGameBridge.lean (1237 lines, sorry-free)

| Lemma | Line | Type Signature Summary | What It Does |
|-------|------|----------------------|-------------|
| `discrete_nf_to_decomposition_agreement` | 997 | NF bridge hypotheses -> `decomposition_agreement M M' atomMap 0 (k/2) (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')` | **Bridge A**: Converts NF-level hypotheses (1-var NF agreement, ordering, interval types) to decomposition_agreement at n=0, r=k/2. Uses `zone_match_witness` for the point challenge. |
| `game_win_to_formula_agree` | 1222 | `ghr93_winning_condition 0 (...) -> formula_agreement at b/b'` | Extracts rank-r formula agreement at a matched point from a winning condition. |

### 2c. Composition.lean (626 lines, sorry-free)

| Lemma | Line | Type Signature Summary | What It Does |
|-------|------|----------------------|-------------|
| `ghr93_strategy_compose` | 40 | `h_left: ghr93_duplicator_wins M N n r x c x' d` + `h_right: ghr93_duplicator_wins M N n r c y d y'` + pivot conditions -> `ghr93_duplicator_wins M N n r x y x' y'` | **GHR93 Proposition 7 (one step)**: Composes left and right sub-interval games at the SAME n,r into a full-interval game. Requires the pivot point d to have matching rank-r type and gap/point status. |

**Critical detail**: `ghr93_strategy_compose` composes games at the SAME n,r. It does NOT handle the n -> n+1 induction step. It is ONE PIECE of Proposition 7, not the whole thing.

### 2d. CustomGame.lean (key definitions)

| Definition | Line | What It Is |
|------------|------|------------|
| `inClosedInterval` | 39 | Element in [x,y] in extended carrier |
| `game_tuple` | 106 | Combines x, y, selections a_i, challenge b into Fin (n+3) -> ExtendedCarrier |
| `ghr93_winning_condition` | 262 | `same_order_type AND gap_point_agreement AND formula_agreement` |
| `ghr93_duplicator_wins` | 285 | For all Spoiler selections, Duplicator has response satisfying winning condition |

### 2e. Defs.lean (key definitions)

| Definition | Line | What It Is |
|------------|------|------------|
| `Gap` | 236 | Dedekind cut with no supremum |
| `ExtendedCarrier` | 335 | `M.carrier + RDefinableGap M atomMap r` |
| `decomposition_agreement` | N/A (in Decomposition.lean) | The semantic decomposition agreement |
| `discrete_no_gaps` | 532 | In succ-archimedean orders, no gaps exist |
| `stavi_depth` | 164 | Depth of a StaviFormula |
| `game_depth` | 88 | `f(n+1) = (1 + 3*f(n)) * (2*k_n) + 2` |

### 2f. StaviCompleteness.lean (sorry sites)

| Item | Line | What It Is |
|------|------|------------|
| `nf_fraisse_compression` | 2006 | `h_atoms + h_transfer (forall j < k) -> nf_characteristic M k n env = nf_characteristic M' k n env'`. Sorry-free. |
| `zone_match_witness` | 2044 | Given u in M, finds u' in M' with same 1-var NF and orderings. Sorry-free. |
| `nf_2var_existential_transfer` | 2214 | **SORRY at line 2353** (forward) and **2435** (backward): 4-var existential transfer at depth j' for 3-point config |
| `nf_2var_from_interval_data` | 2448 | Calls `nf_fraisse_compression` with `nf_2var_existential_transfer`. Sorry-free itself but depends on sorry'd `nf_2var_existential_transfer`. |
| `nf_exist_sf_guarded_backward` | 2778 | **SORRY at line 2805**: Backward direction of guarded formula. Depends on `nf_2var_from_interval_data` which depends on sorry'd transfer. |

## 3. Sub-Interval Decomposition Extraction Analysis (The Critical Question)

### 3a. What `ghr93_game_implies_decomposition` produces

`ghr93_game_implies_decomposition` at (Decomposition.lean:117) takes:
- `h : ghr93_duplicator_wins M N atomMap n r x y x' y'` (forward game)
- `h_bwd : ghr93_duplicator_wins N M atomMap n r x' y' x y` (backward game)
- Point existence witnesses for both intervals

It produces `decomposition_agreement M N atomMap n r x y x' y'`, which includes:
- Boundary type agreement at x/x' and y/y'
- Forward: for every n-selection from M, matching n-selection from N with type/gap/order agreement and point challenge
- Backward: symmetric

### 3b. Does it give sub-interval decomposition?

**No, not directly.** `ghr93_game_implies_decomposition` gives decomposition agreement on the FULL interval (x,y)/(x',y'). It does NOT automatically give decomposition agreement on sub-intervals (x,u)/(x',u') and (u,y)/(u',y') when you match u -> u'.

**However**, the information IS there implicitly. Here is how to extract it:

Given a game win on (x,y)/(x',y') at parameters n,r:
1. Play the game: Spoiler selects u in [x,y] (plus possibly other elements). Duplicator responds with u' (plus others) satisfying the winning condition.
2. The winning condition gives: for all rank-r formulas A, A^mu holds at u iff A^mu holds at u'. It also gives order preservation.
3. Now consider the sub-interval (x,u)/(x',u'). We want a game win or decomposition agreement here.

To get a game win on the sub-interval (x,u)/(x',u'), we need `ghr93_strategy_restrict_left/right` (CustomGame.lean). These exist in the codebase (confirmed at lines ~1241 and ~1470 of CustomGame.lean). Let me check their exact signatures.

<actually_needed>

The key question is: can we go from a game win at n,r on the full interval to game wins on sub-intervals, and at what n',r'?

**GHR93's approach**: In Proposition 7 (p.115-116), the proof uses the forward strategy from G_{f(n+1);r}(M, xi xi+1; N, yi yi+1) to select the pivot point e, then observes that the decomposition formulas are preserved on sub-intervals. This gives game wins at G_{1+3f(n);r} on sub-intervals (by Lemma 11 backward). Then Theorem 6 inverts these to backward games at G_{f(n);g(n)}.

**For our sorry sites**: The sorry sites are inside `nf_2var_existential_transfer`, which needs 4-var existential transfer at depth j' < k for the 3-point configuration (u,x,t)/(u',x',t'). This is the inner loop of the Fraisse game argument.

### 3c. What the sorry site actually needs

At line 2353, the goal (after `rw [<- hu_quant sub_nf]`) is:

```
(exists w, nf_eval_nf M j' (3+1) (Fin.cons w (Fin.cons u (Fin.cons x (fun _ => t)))) sub_nf)
<->
(exists w', nf_eval_nf M' j' (3+1) (Fin.cons w' (Fin.cons u' (Fin.cons x' (fun _ => t')))) sub_nf)
```

This is: given 3 matched points (u,x,t) in M and (u',x',t') in M' (where u was zone-matched), transfer existential NF statements about a 4th variable w/w' at depth j' < j < k.

**This is essentially the same problem at one more variable**. The outer function `nf_2var_existential_transfer` goes from 2 vars to 3 vars (adding u). The sorry needs to go from 3 vars to 4 vars (adding w). This is inherently recursive.

## 4. Full Pipeline from Sorry to Resolution

### 4.1 The Dependency Chain

```
sorry at line 2805 (nf_exist_sf_guarded_backward)
  <- calls nf_2var_from_interval_data (line 2448, sorry-free)
  <- calls nf_fraisse_compression (line 2006, sorry-free)
  <- calls nf_2var_existential_transfer (line 2214)
     <- SORRY at line 2353 (forward, 4-var transfer at depth j')
     <- SORRY at line 2435 (backward, symmetric)

nf_2var_existential_transfer needs:
  forall j < k, forall chi : NormalForm sig j 3,
    (exists u, nf_eval_nf M j 3 (u::x::t) chi) <->
    (exists u', nf_eval_nf M' j 3 (u'::x'::t') chi)

It proves j=0 case (atoms only). For j=j'+1:
  Atoms: proved via h_3var_atoms.
  Quantifier: needs (exists w, nf_eval M j' 4 (w::u::x::t) sub_nf) <->
                    (exists w', nf_eval M' j' 4 (w'::u'::x'::t') sub_nf)
  This is 4-VAR existential transfer at depth j' for (u,x,t)/(u',x',t').
```

### 4.2 The GHR93 Decomposition Path

Instead of filling the sorry inside `nf_2var_existential_transfer` directly (which requires an infinite regress of variable counts), the GHR93 approach works at the game level where the number of variables is absorbed into the game's round count.

**The correct GHR93 pipeline**:

```
Bridge A hypothesis (1-var NF agreement + interval types at depth k)
  |
  v
decomposition_agreement at n=0, r=k/2 (via discrete_nf_to_decomposition_agreement)
  |
  v
ghr93_duplicator_wins at n=0, r=k/2 (via ghr93_decomposition_implies_game)
  |
  v
[Proposition 7 induction on n]:
  For each n, from game wins at f(n+1) on full intervals,
  derive game wins at f(n) on sub-intervals via:
    1. Play game, match pivot point
    2. Extract sub-interval decomposition agreement (Lemma 11 forward)
    3. Convert back to game wins (Lemma 11 backward)
    4. Invert to backward games (Theorem 6)
    5. Recurse
  |
  v
Standard EF game win G_n((M,x,t), (M',x',t'))
  |
  v
FO formula equivalence at quantifier depth n (Proposition 5 / Ehrenfeucht-Fraisse)
  |
  v
NF characteristic equality: nf_characteristic M k 2 (x,t) = nf_characteristic M' k 2 (x',t')
```

### 4.3 What Exists vs What Is Needed

**EXISTS (sorry-free)**:
1. `decomposition_agreement` definition (Decomposition.lean:62)
2. `ghr93_game_implies_decomposition` -- Lemma 11 forward (Decomposition.lean:117)
3. `ghr93_decomposition_implies_game` -- Lemma 11 backward (Decomposition.lean:272)
4. `ghr93_strategy_compose` -- Proposition 7 single-step composition (Composition.lean:40)
5. `discrete_nf_to_decomposition_agreement` -- Bridge A (NFGameBridge.lean:997)
6. `zone_match_witness` -- zone matching (StaviCompleteness.lean:2044)
7. `nf_fraisse_compression` -- Fraisse compression (StaviCompleteness.lean:2006)
8. `game_win_to_formula_agree` -- extract formula agreement (NFGameBridge.lean:1222)
9. `discrete_no_gaps` -- no gaps for discrete orders (Defs.lean:532)
10. `game_depth` and its monotonicity/strict-mono lemmas (Defs.lean:88-150)

**NEEDED (new lemmas)**:

#### Lemma N1: `discrete_decomposition_to_nf_agree`
```lean
theorem discrete_decomposition_to_nf_agree {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    [discrete instances for M, M']
    (x y : M.carrier) (x' y' : M'.carrier)
    (h_game : ghr93_duplicator_wins M M' atomMap n r
      (extendPoint x) (extendPoint y) (extendPoint x') (extendPoint y'))
    (h_bwd : ghr93_duplicator_wins M' M atomMap n r
      (extendPoint x') (extendPoint y') (extendPoint x) (extendPoint y)) :
    nf_characteristic M (2*r) n (env from x,y) =
    nf_characteristic M' (2*r) n (env from x',y')
```
**Strategy**: Use the game win to get formula agreement at all rank-r formulas. For discrete orders, formula agreement at rank r implies NF agreement at depth proportional to r (via the standard translation). This needs the standard translation correctness theorem (`stavi_table_mu_correct` or similar).

**Estimated lines**: 150-250.

**This is the critical new piece**: Converting game wins to NF equality for discrete orders. In GHR93 this is Corollary 5 (p.115, line 1341-1346), which says: if x and y satisfy the same temporal formulas of rank g(n+1)+1, then all monadic FO formulas of quantifier depth <= n agree.

#### Lemma N2: `discrete_game_induction_step`
```lean
theorem discrete_game_induction_step {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    [discrete instances for M, M']
    -- Forward+backward games on sub-intervals at strength f(n+1),g(n+1)
    (h_fwd : ∀ i, ghr93_duplicator_wins M M' atomMap (game_depth_f sig (n+1)) (game_depth_g sig (n+1))
      (extendPoint (xi i)) (extendPoint (xi (i+1)))
      (extendPoint (yi i)) (extendPoint (yi (i+1))))
    (h_bwd : ∀ i, ghr93_duplicator_wins M' M atomMap (game_depth_f sig (n+1)) (game_depth_g sig (n+1))
      (extendPoint (yi i)) (extendPoint (yi (i+1)))
      (extendPoint (xi i)) (extendPoint (xi (i+1)))) :
    -- Duplicator wins the (n+1)-round standard EF game
    ef_duplicator_wins_n_rounds M M' atomMap (n+1) x y
```
**Strategy**: This is the full Proposition 7 induction step. When Spoiler picks alpha in (xi, xi+1), use the f(n+1)-game to match it to e, extract sub-interval decomposition via Lemma 11 forward, convert to sub-interval games via Lemma 11 backward, then apply Theorem 6 to get backward sub-interval games, and recurse via the induction hypothesis.

**Estimated lines**: 300-500 (the bulk of the work).

#### Lemma N3: `discrete_theorem6_step` (Theorem 6 game inversion)

GHR93 Theorem 6 (*) says: if Duplicator wins G_{1+3n;r+4n}(M,xy;N,x'y'), then Duplicator wins G_{n;r}(N,x'y';M,xy). This "game inversion" is needed in the Proposition 7 proof.

For discrete orders (no gaps, only Cases I and II of Theorem 6), this simplifies considerably but is still non-trivial. It requires induction on n.

**Estimated lines**: 200-400.

### 4.4 Alternative: A Direct Approach Avoiding Full Proposition 7

The sorry sites require 4-var existential transfer at depth j' for 3 matched points. Instead of building the full Proposition 7 machinery, we could try a **direct induction on k (the NF depth)** that works specifically for discrete orders:

**Approach**: Prove that for discrete orders, the bridge lemma hypotheses (1-var NF agreement + ordering + interval types at depth k) imply n-var NF agreement at depth k for any n, by strong induction on k.

- Base case k=0: atoms only, proved.
- Inductive step k+1: Given n-var atoms + quantifier transfer at all j < k+1. For the quantifier transfer at depth k: need (n+1)-var transfer at depth k-1 with matched points. The key insight for discrete orders: zone_match at the (n+1)-var level gives a witness u' with matching 1-var NF. The ordering data for the (n+1)-var configuration comes from the zone match. The interval type data for sub-intervals of the (n+1)-var configuration... this is where the recursion bottoms out, because the interval types are GIVEN by the outer hypotheses (they're properties of the original 2-point interval).

**Problem**: This approach has the same variable-count escalation problem. Each level of the induction adds one more variable. This is exactly what the game approach solves: the game absorbs all variable counts into rounds.

## 5. New Lemmas Needed (Recommended Path)

### Path A: Full GHR93 Game Route (Recommended)

This follows GHR93 most closely and avoids novel mathematics.

#### Step 1: Theorem 6 for Discrete Orders

```lean
-- GHR93 Theorem 6: forward game -> backward game (discrete only)
theorem discrete_ghr93_theorem6 {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [discrete M] [discrete N]
    (n r : Nat)
    (x y : M.carrier) (x' y' : N.carrier)
    (h : ghr93_duplicator_wins M N atomMap (1 + 3*n) (r + 4*n)
      (extendPoint x) (extendPoint y) (extendPoint x') (extendPoint y')) :
    ghr93_duplicator_wins N M atomMap n r
      (extendPoint x') (extendPoint y') (extendPoint x) (extendPoint y)
```

**Proof strategy**: Induction on n. Case n=0: Duplicator uses the forward strategy directly (only Round 2 matters). Case n+1: Uses Claims 1 and 2 from GHR93 p.116 to derive sub-interval games, then Cases I-II (no gaps in discrete orders). The characteristic formula B = X_{alpha_n} detects alpha_n's rank-r type; the supremum/infimum constructions of b and c work directly (no gap complications).

**Existing infrastructure used**: `ghr93_strategy_compose` (for composing sub-interval games), `ghr93_game_implies_decomposition` and `ghr93_decomposition_implies_game` (for Lemma 11 conversions).

**Estimated lines**: 300-500 (most complex new piece).

#### Step 2: Proposition 7 for Discrete Orders

```lean
-- GHR93 Proposition 7: sub-interval games -> full EF game (discrete only)
theorem discrete_ghr93_proposition7 {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [discrete M] [discrete N]
    (n : Nat) (m : Nat)
    (xs : Fin (m+2) → M.carrier) (ys : Fin (m+2) → N.carrier)
    (h_mono_x : StrictMono xs) (h_mono_y : StrictMono ys)
    (h_fwd : ∀ i : Fin (m+1), ghr93_duplicator_wins M N atomMap
      (game_depth_f sig n) (game_depth_g sig n)
      (extendPoint (xs i.castSucc)) (extendPoint (xs i.succ))
      (extendPoint (ys i.castSucc)) (extendPoint (ys i.succ)))
    (h_bwd : ∀ i : Fin (m+1), ghr93_duplicator_wins N M atomMap
      (game_depth_f sig n) (game_depth_g sig n)
      (extendPoint (ys i.castSucc)) (extendPoint (ys i.succ))
      (extendPoint (xs i.castSucc)) (extendPoint (xs i.succ))) :
    -- Duplicator wins n-round standard EF game
    standard_ef_duplicator_wins M N atomMap n (xs ∘ Fin.tail ∘ Fin.castPred) (ys ∘ Fin.tail ∘ Fin.castPred)
```

**Proof strategy**: Induction on n. Use Theorem 6 (Step 1) to get backward sub-interval games. When Spoiler picks alpha, use the game to find e, apply Lemma 11 to extract sub-interval decomposition agreements, convert to sub-interval game wins, and recurse.

**Existing infrastructure used**: `discrete_ghr93_theorem6` (Step 1), `ghr93_game_implies_decomposition`, `ghr93_decomposition_implies_game`, `ghr93_strategy_compose`.

**Estimated lines**: 200-400.

#### Step 3: EF Game Win -> NF Equality

```lean
-- Corollary 5: temporal formula agreement -> FO formula agreement -> NF equality
theorem discrete_ef_game_to_nf_equality {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    [discrete M] [discrete M']
    (k : Nat) (x t : M.carrier) (x' t' : M'.carrier)
    (h_stavi_agree : ∀ (A : StaviFormula), stavi_depth A ≤ game_depth_g sig k + 1 →
      (stavi_temporal_truth M atomMap x A ↔ stavi_temporal_truth M' atomMap x' A) ∧
      (stavi_temporal_truth M atomMap t A ↔ stavi_temporal_truth M' atomMap t' A)) :
    nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
    nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))
```

**Proof strategy**: This follows from Propositions 5 (Ehrenfeucht-Fraisse) + 6 + 7. The temporal formula agreement at sufficient depth gives game wins, which give FO formula equivalence at depth k, which gives NF equality.

**Estimated lines**: 100-200.

#### Step 4: Plug Into Existing Sorry Sites

Replace `nf_2var_existential_transfer` with a version that uses the game route:

```lean
-- Alternative: replace the sorry'd nf_2var_existential_transfer with game-based proof
theorem nf_2var_existential_transfer_via_games {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    (atomMap : Formula → sig.preds)
    (k : Nat) (x t : M.carrier) (x' t' : M'.carrier)
    [discrete M] [discrete M']
    -- ... same hypotheses as nf_2var_existential_transfer ...
    :
    ∀ j, j < k →
      ∀ chi : NormalForm sig j (2 + 1),
        (∃ u, nf_eval_nf M j (2 + 1) (Fin.cons u (Fin.cons x (fun _ => t))) chi) ↔
        (∃ u', nf_eval_nf M' j (2 + 1) (Fin.cons u' (Fin.cons x' (fun _ => t'))) chi)
```

**Proof strategy**: From the bridge hypotheses, derive decomposition_agreement (Bridge A), then game wins (Lemma 11 backward), then use Theorem 6 + Proposition 7 to get full EF game wins, then Corollary 5 to get NF equality. NF equality at depth k for 2 vars implies existential transfer at depth j < k for 3 vars.

Wait -- this is circular. The existential transfer IS what NF equality requires. Let me reconsider.

**The non-circular route**: The game approach does NOT go through NF equality at 2 vars. Instead:
1. Bridge A: NF hypotheses -> decomposition_agreement at n=0 (2 endpoints matched)
2. Game composition: for each new Spoiler challenge, match via zone_match, compose sub-interval games
3. After enough rounds: standard EF game win
4. Standard EF game win at depth n -> FO formula equivalence at quantifier depth n
5. FO formula equivalence at depth k with 2 free variables -> existential transfer at depth < k for 3 variables

The key is that step 4 gives FO equivalence DIRECTLY, not through NF equality. The FO equivalence at 2-var environments (x,t)/(x',t') at depth k means that ANY FO formula phi(x0, x1) of quantifier depth <= k evaluates the same way. In particular, `exists x2, phi(x0, x1, x2)` where phi has depth < k evaluates the same way. This IS the existential transfer.

**So the actual pipeline is**:

```
Bridge hypotheses
  -> decomposition_agreement at n=0, r=k/2 (Bridge A, EXISTS)
  -> game win at n=0, r=k/2 (Lemma 11 backward, EXISTS)
  -> [Proposition 7 + Theorem 6 induction]
  -> standard EF game win at sufficient rounds
  -> FO equivalence at depth k for 2-var environments
  -> existential transfer for 3 vars at depth j < k (by definition of FO equivalence)
```

**This is exactly what GHR93 does** and it is NOT circular.

### Total Estimated New Code

| Component | Lines | Difficulty |
|-----------|-------|------------|
| Theorem 6 (discrete) | 300-500 | Hard (main induction, Claims 1-2, Cases I-II) |
| Proposition 7 (discrete) | 200-400 | Medium (induction on n, uses Theorem 6) |
| EF game -> FO equivalence bridge | 100-200 | Medium (standard EF theorem) |
| Plugging into sorry sites | 50-100 | Easy (connecting pieces) |
| **Total** | **650-1200** | |

## 6. Bypass Alternative Analysis

### 6a. Can we bypass `nf_2var_existential_transfer` entirely?

**YES, in principle.** The call chain is:

```
nf_characterizable_by_stavi (the main theorem)
  -> nf_2var_existence_characterizable (exists SF characterizing 2-var NF)
    -> nf_2var_exist_sf_classical (k >= 1 case)
      -> nf_exist_sf_guarded_backward (backward direction, SORRY at 2805)
        -> needs nf_2var_from_interval_data (which calls nf_2var_existential_transfer)
```

The backward direction `nf_exist_sf_guarded_backward` needs: given a temporal formula holds at t (witnessing some x in the right zone), prove that the 2-var NF of (x,t) equals sub_nf.

**Alternative approach**: Instead of going through `nf_2var_from_interval_data` (which uses the sorry'd existential transfer), use the game-based approach DIRECTLY in `nf_exist_sf_guarded_backward`:

1. From the temporal formula, extract witness x with the right 1-var NF type, correct ordering, and interval type guard.
2. Build decomposition_agreement from these (Bridge A).
3. Convert to game wins (Lemma 11 backward).
4. Use Theorem 6 + Proposition 7 to get full EF game wins.
5. By Corollary 5, get FO equivalence at depth k.
6. FO equivalence at depth k implies NF equality at depth k.
7. NF equality + nf_characteristic_satisfies gives nf_eval_nf for sub_nf.

This bypasses `nf_2var_existential_transfer` entirely by proving the stronger `nf_2var_from_interval_data` directly via games, without going through Fraisse compression.

### 6b. Creating a parallel `discrete_stavi_expressive_completeness`

This is possible but probably not needed. The existing `nf_characterizable_by_stavi` is general (works for all linear orders). The sorry sites are specifically in the 2-var bridge lemma. Fixing the bridge lemma fixes everything.

### 6c. Recommended bypass

**Replace `nf_2var_from_interval_data`** with a game-based proof for discrete orders:

```lean
theorem nf_2var_from_interval_data_discrete {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    [discrete M] [discrete M']
    (atomMap : Formula → sig.preds)
    (k : Nat) (x t : M.carrier) (x' t' : M'.carrier)
    -- same hypotheses as nf_2var_from_interval_data --
    :
    nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
    nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))
```

**Proof route**: Bridge A -> game at n=0 -> Proposition 7 (induction on n, giving standard EF game wins at n rounds) -> Proposition 5 (EF game -> FO equivalence) -> NF equality.

Then `nf_exist_sf_guarded_backward` can call this instead of calling `nf_2var_from_interval_data` + `nf_fraisse_compression` + `nf_2var_existential_transfer`.

## 7. Risks and Blockers

### Risk 1: Theorem 6 Complexity (HIGH)

GHR93 Theorem 6 proof (pp.116-119) is the most complex part. Even restricted to discrete orders (Cases I and II only), it requires:
- Claims 1 and 2 (canonical pivot point, sub-interval game derivation)
- Case I (pivot between selected points)
- Case II (all points on one side, using characteristic formula B and supremum/infimum)

For discrete orders, Case II simplifies because there are no gap-related complications, but the characteristic formula construction and its correctness still require ~200+ lines.

### Risk 2: Standard EF Theorem (Proposition 5) Not Formalized

The codebase has `EFPosition` and `ef_duplicator_wins` (Defs.lean:48-71) but does NOT have a proof of Proposition 5 (EF game win <-> FO formula equivalence). This is a standard result but may need 100-200 lines to formalize.

**Mitigation**: For discrete orders, we may be able to bypass Proposition 5 entirely by using `nf_fraisse_compression` directly with the game-extracted existential transfers. The game wins at sufficient rounds give us the existential transfer for each depth level, which is exactly what `nf_fraisse_compression` needs.

### Risk 3: Rank/Depth Mismatch

The game operates at rank r (StaviFormula depth) while the NF operates at depth k. The relationship between r and k depends on the f,g functions. Bridge A uses r = k/2. The Proposition 7 induction needs growing rank g(n). Getting these numbers to line up correctly requires careful tracking.

**Mitigation**: For the specific application (filling the sorry sites), we only need the game argument at a SPECIFIC depth, not for all n. The parameters need to be chosen so that the game win at sufficient strength implies NF equality at depth k.

### Risk 4: Recursion Depth

Proposition 7's induction on n, combined with Theorem 6's induction on n, creates a double induction. In Lean, this may need `termination_by` annotations and careful structuring.

### Risk 5: The Bridge B Gap (NFGameBridge.lean:1198-1210)

The comment at NFGameBridge.lean:1198 notes that "Full Bridge B (converting game wins to existential NF transfer) is blocked because the game at n=0 only gives formula_agreement at 3 specific positions (x, b, t)." This is the fundamental issue. The game at n=0 provides formula agreement at matched points but does not directly give the sub-interval type data needed for the Fraisse compression lemma.

**Resolution**: This is exactly what Theorem 6 + Proposition 7 resolve. By playing games at higher n (not just n=0), we get enough matched points to determine the full sub-interval structure. The game at n rounds gives n interior matched points, which determines all decomposition formulas up to that precision.

## Summary Recommendations

1. **Follow GHR93 exactly**: The decomposition-formula path via Theorem 6 + Proposition 7 is the only approach that avoids novel mathematics and the variable-count escalation problem.

2. **Implement for discrete orders only**: Cases III and IV of Theorem 6 are vacuous for discrete orders. This reduces the implementation by ~40%.

3. **Key new code**: Theorem 6 (discrete) is the hardest piece (~300-500 lines). Proposition 7 (~200-400 lines) and the EF-to-NF bridge (~100-200 lines) are more straightforward.

4. **Use existing infrastructure heavily**: `ghr93_game_implies_decomposition`, `ghr93_decomposition_implies_game`, `ghr93_strategy_compose`, `discrete_nf_to_decomposition_agreement`, and `zone_match_witness` are all sorry-free and directly usable.

5. **Target**: Replace `nf_2var_from_interval_data`'s proof route with one that goes through games. This eliminates all three sorry sites (2353, 2435, 2805) simultaneously.

6. **Estimated total**: 650-1200 new lines of Lean code. The main risk is Theorem 6 complexity.
