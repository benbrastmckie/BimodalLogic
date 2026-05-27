# Research Report: GHR93 Proposition 7 -- Composition Lemma for EF Games

**Task**: 155 (Reynolds Pipeline Activation)
**Phase**: 6 Root Blocker Analysis
**Date**: 2026-05-27

## 1. GHR93 Faithful Statement

### Proposition 7 (Strategy Composition)

**Source**: Gabbay, Hodkinson, Reynolds (1993/1994), Chapter 9, Section 8

**Statement**: Let M, N be ordered monadic structures with atom map. Let r be a rank and n a round count. Given:

1. A split point c in the extended carrier M_r of M, with c in the closed interval [x, y]
2. A corresponding split point d in the extended carrier N_r of N, with d in [x', y']
3. c and d have the same rank-r type and the same gap/point status
4. Duplicator wins G_{n;r}(M, x c; N, x' d) -- the LEFT sub-interval game
5. Duplicator wins G_{n;r}(M, c y; N, d y') -- the RIGHT sub-interval game

**Conclusion**: Duplicator wins G_{n;r}(M, x y; N, x' y') -- the FULL interval game.

### Proof Idea

When Spoiler selects n elements a_1, ..., a_n from [x, y] in M_r:

1. **Partition** the selections into LEFT = {a_i : a_i <= c} and RIGHT = {a_i : a_i > c}
2. **Apply the left strategy** to the LEFT selections (padded to n elements) to get Duplicator's responses in [x', d]
3. **Apply the right strategy** to the RIGHT selections (padded to n elements) to get Duplicator's responses in [d, y']
4. **Merge** the two response sets into a single n-element response in [x', y']
5. For Round 2 (point challenge b' in [x', y'] ∩ N):
   - If b' <= d: apply the left strategy's Round 2 to get b in [x, c] ∩ M
   - If b' > d: apply the right strategy's Round 2 to get b in [c, y] ∩ M
6. **Show the winning condition holds** on the merged tuple:
   - **Order preservation**: Elements within each sub-interval have their order preserved by the sub-strategy. Cross-interval order (LEFT < RIGHT) is preserved because all left responses are <= d and all right responses are >= d.
   - **Gap/point agreement**: Each response inherits gap/point status from the sub-strategy that produced it. The split point c/d has matching status by hypothesis.
   - **Formula agreement**: Each response at position i inherits formula agreement from the sub-strategy. Cross-interval formula agreement follows from the split point's type agreement.

### Subtleties

1. **Padding**: Each sub-strategy expects n selections, but we only have |LEFT| and |RIGHT| respectively. We pad with the split point c (or with boundary elements). The existing `ghr93_duplicator_wins_round_mono` theorem handles the case where n' <= n by padding with boundary elements, which is exactly what we need.

2. **Gap at split point**: If c is a gap, Round 2's point challenge cannot land exactly on c. The point challenge selects an actual point (not a gap), so it falls strictly in one sub-interval. This simplifies the case analysis.

3. **Cross-interval order**: The key insight is that for any left response a'_L <= d and any right response a'_R >= d, we automatically have a'_L <= a'_R. The sub-strategies guarantee order preservation within each sub-interval, and the split point d mediates between the two.

## 2. Current Infrastructure Inventory

### Files in `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/`

| File | Lines | Contents |
|------|-------|----------|
| `Defs.lean` | 559 | EFPosition, game_depth, stavi_n_equiv, Gap, ExtendedCarrier, rank embedding basics |
| `TypeFormulas.lean` | ~700 | rank_embed, rank_type, stavi_temporal_truth_mu, mu_holds |
| `GapDetection.lean` | 5057 | left_formula, right_formula, gap detection (Lemma 9) |
| `CustomGame.lean` | 1594 | game_tuple, same_order_type, formula_agreement, ghr93_duplicator_wins, strategy restriction (left/right), round monotonicity, rank lifting, K+/K- operators, gap characterization |
| `Decomposition.lean` | 315 | decomposition_agreement, Lemma 11 (game <-> decomposition) |
| `StaviCompleteness.lean` | 1652 | Standard translation (stavi_table_mu), NF characterization infrastructure, nf_characterizable_by_stavi (SORRY at line 1567), stavi_expressive_completeness |

### Key Definitions (Existing)

| Definition | Type | Location |
|------------|------|----------|
| `ghr93_duplicator_wins` | `M N atomMap n r x y x' y' : Prop` | CustomGame.lean:285 |
| `game_tuple` | `Fin (n+3) -> ExtendedCarrier` | CustomGame.lean:106 |
| `same_order_type` | `n tM tN : Prop` | CustomGame.lean:228 |
| `formula_agreement` | `n tM tN : Prop` | CustomGame.lean:239 |
| `gap_point_agreement` | `n tM tN : Prop` | CustomGame.lean:250 |
| `ghr93_winning_condition` | `n tM tN : Prop` | CustomGame.lean:262 |
| `inClosedInterval` | `x y e : Prop` | CustomGame.lean:39 |
| `ghr93_duplicator_wins_round_mono` | round n' <= n monotonicity | CustomGame.lean:428 |
| `ghr93_strategy_restrict_left` | left sub-interval restriction | CustomGame.lean:1228 |
| `ghr93_strategy_restrict_right` | right sub-interval restriction | CustomGame.lean:1457 |
| `ghr93_winning_condition_symm` | winning condition is symmetric | CustomGame.lean:1580 |
| `ghr93_duplicator_wins_degenerate_gap` | degenerate gap-gap intervals | CustomGame.lean:314 |
| `decomposition_agreement` | semantic decomposition equiv | Decomposition.lean:62 |
| `ghr93_game_iff_decomposition` | Lemma 11 | Decomposition.lean:302 |
| `rank_embed` | rank r -> rank r' embedding | TypeFormulas.lean:52 |

### What EXISTS (relevant to composition)

1. **Round monotonicity** (`ghr93_duplicator_wins_round_mono`): If Duplicator wins with n rounds, she wins with n' <= n rounds. Uses padding with boundary elements. This is directly usable for the padding step in composition.

2. **Strategy restriction left/right** (`ghr93_strategy_restrict_left`, `ghr93_strategy_restrict_right`): Given a winning strategy on [x, y] and a split point c with consistent response d, extract winning strategies on [x, c] and [c, y]. These are the CONVERSE of composition -- they decompose strategies rather than composing them.

3. **Degenerate gap handling** (`ghr93_duplicator_wins_degenerate_gap`): When both endpoints are the same gap, the game is vacuously won (no actual points exist in the degenerate interval).

4. **Winning condition symmetry** (`ghr93_winning_condition_symm`): The winning condition is symmetric in M/N, which helps when converting between forward and backward games.

### What is MISSING

1. **The composition lemma itself** (Proposition 7): No theorem composes two sub-interval strategies into a full-interval strategy.

2. **Partition/merge infrastructure**: No definition for partitioning Spoiler's selections by position relative to a split point, or for merging Duplicator's sub-interval responses into a single response.

3. **Cross-interval order transfer**: No lemma establishing that left responses <= d <= right responses implies the merged tuple preserves order.

## 3. Sorry Site Analysis

### Proof State at StaviCompleteness.lean:1567

```
case succ
sig : MonadicSignature
atomMap : Formula -> sig.preds
h_surj : forall (p : sig.preds), exists a, atomMap (Formula.atom a) = p
k : Nat
ih : forall (nf : NormalForm sig k 1), exists A,
       forall (M : OrderedMonadicStructure sig) (t : M.carrier),
         stavi_temporal_truth M atomMap t A <-> nf_eval_nf M k 1 (fun x => t) nf
nf : NormalForm sig (k + 1) 1
|- exists A, forall (M : OrderedMonadicStructure sig) (t : M.carrier),
     stavi_temporal_truth M atomMap t A <-> nf_eval_nf M (k + 1) 1 (fun x => t) nf
```

### What the IH Provides

For every 1-variable depth-k NF `nf_1 : NormalForm sig k 1`, there exists a StaviFormula `A` such that for all structures M and points t:

```
stavi_temporal_truth M atomMap t A <-> nf_eval_nf M k 1 (fun _ => t) nf_1
```

This means: the IH can characterize the 1-variable type of any single point at depth k.

### What the Goal Requires

For the given `nf : NormalForm sig (k+1) 1`, produce a StaviFormula `A` such that:

```
stavi_temporal_truth M atomMap t A <-> nf_eval_nf M (k+1) 1 (fun _ => t) nf
```

Unfolding `nf_eval_nf` at depth k+1:

```
nf_eval_nf M (k+1) 1 (fun _ => t) nf
  = (forall a : AtomKind sig 1, atom_eval M (fun _ => t) a <-> nf.1 a = true)
  AND
    (forall sub_nf : NormalForm sig k 2,
      (exists x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf)
      <-> nf.2 sub_nf = true)
```

The atom part is straightforward (same as depth 0). The hard part is the quantifier part: for each `sub_nf : NormalForm sig k 2`, we need a StaviFormula that captures:

```
exists x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf
```

This is a 2-variable property: it asks whether there exists a point x such that the PAIR (x, t) satisfies a depth-k 2-variable NF. The IH only gives 1-variable characterizations.

### The Gap Between IH and Goal

The IH characterizes 1-variable types. But `nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf` describes the JOINT type of (x, t) at depth k -- a 2-variable property that depends on:
- Predicates at x
- Predicates at t
- Order between x and t
- For k >= 1: which depth-(k-1) 3-variable NFs are realized with a third variable

The temporal connectives U, S, U', S' express existential properties of points relative to a reference point t. GHR93's insight is that the game-theoretic composition lemma (Proposition 7) shows these connectives are powerful enough to capture all 2-variable types, by composing 1-variable type information across sub-intervals.

## 4. Proposed Lean Statement

### Core Composition Lemma

```lean
/-- **GHR93 Proposition 7**: Strategy composition for EF games.

    Given Duplicator winning strategies on the sub-intervals [x,c] and [c,y]
    (with matching split point d in [x',y']), compose them into a winning
    strategy on the full interval [x,y]. -/
theorem ghr93_strategy_compose {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula -> sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
    (hxc : x <= c) (hcy : c <= y) (hx'd : x' <= d) (hdy' : d <= y')
    (hcd_type : forall (A : StaviFormula), stavi_depth A <= r ->
      (stavi_temporal_truth_mu M atomMap r c A <->
       stavi_temporal_truth_mu N atomMap r d A))
    (hcd_gp : (IsPoint c <-> IsPoint d) /\ (IsGap c <-> IsGap d))
    (h_left : ghr93_duplicator_wins M N atomMap n r x c x' d)
    (h_right : ghr93_duplicator_wins M N atomMap n r c y d y') :
    ghr93_duplicator_wins M N atomMap n r x y x' y'
```

### Auxiliary Definitions Needed

```lean
/-- Partition Spoiler's selections into left (<= c) and right (> c) groups.
    Returns (left_count, left_selections, right_selections, left_indices). -/
noncomputable def partition_selections {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula -> sig.preds} {r : Nat}
    {n : Nat} (c : ExtendedCarrier M atomMap r)
    (a : Fin n -> ExtendedCarrier M atomMap r) :
    { p : (Fin n -> Bool) // forall i, p i = true <-> a i <= c }

/-- Merge two sub-interval response tuples into a single full-interval
    response tuple, placing left responses and right responses according
    to the original partition. -/
noncomputable def merge_responses {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula -> sig.preds} {r : Nat}
    {n : Nat} (partition : Fin n -> Bool)
    (left_resp : Fin n -> ExtendedCarrier N atomMap r)
    (right_resp : Fin n -> ExtendedCarrier N atomMap r) :
    Fin n -> ExtendedCarrier N atomMap r
```

## 5. Proof Strategy

### Step 1: Partition (5-10 lines)

Given Spoiler's selection `a : Fin n -> ExtendedCarrier M atomMap r` from [x, y], classify each element:
- `is_left i := a i <= c`
- Left selections: those with `a i <= c`, in [x, c]
- Right selections: those with `a i > c`, i.e., `c < a i`, in [c, y]

### Step 2: Apply Sub-Strategies via Round Monotonicity (30-50 lines)

Count: let n_L = number of left selections, n_R = number of right. We have n_L + n_R = n.

- Extract left selections as `a_L : Fin n_L -> ExtendedCarrier M atomMap r` in [x, c]
- Extract right selections as `a_R : Fin n_R -> ExtendedCarrier M atomMap r` in [c, y]

Apply `ghr93_duplicator_wins_round_mono` to reduce from n-round strategies to n_L and n_R-round strategies:
- `h_left` gives n-round strategy on [x, c]; use round monotonicity to get n_L-round strategy
- `h_right` gives n-round strategy on [c, y]; use round monotonicity to get n_R-round strategy

Apply each sub-strategy to get:
- `a'_L : Fin n_L -> ExtendedCarrier N atomMap r` in [x', d]
- `a'_R : Fin n_R -> ExtendedCarrier N atomMap r` in [d, y']

### Step 3: Merge Responses (20-30 lines)

Construct `a' : Fin n -> ExtendedCarrier N atomMap r` by placing the sub-responses back into their original positions:
- `a' i := if is_left i then a'_L (left_index i) else a'_R (right_index i)`

Show all `a' i` are in [x', y']:
- Left responses are in [x', d] subset [x', y']
- Right responses are in [d, y'] subset [x', y']

### Step 4: Handle Round 2 Point Challenge (30-50 lines)

Given Spoiler's point challenge `b' : N.carrier` in [x', y']:
- Case `extendPoint b' <= d`: Challenge is in [x', d]. Use left strategy's Round 2 to get `b : M.carrier` in [x, c] subset [x, y].
- Case `d < extendPoint b'`: Challenge is in [d, y']. Use right strategy's Round 2 to get `b : M.carrier` in [c, y] subset [x, y].

Note: If d is a gap, `extendPoint b'` is always strictly comparable to d (never equal), so exactly one case applies.

### Step 5: Prove Winning Condition on Merged Tuple (80-120 lines)

This is the most involved step. For the merged game tuple `game_tuple x y a' b'` vs `game_tuple x' y' a b`, show:

**5a. Same order type** (40-60 lines): For all pairs (i, j) in Fin (n+3):
- Both in left sub-interval: order preserved by left strategy
- Both in right sub-interval: order preserved by right strategy
- One left, one right: left element <= c and right element > c in M; left response <= d and right response > d in N. So order is preserved across the split.
- Boundary/challenge point cases: handled by the sub-strategy that contains the relevant point

The cross-interval case is the key novelty. The argument is:
- If a_i <= c < a_j, then in M: a_i < a_j (strictly, since c < a_j implies a_i <= c < a_j)
- The left response a'_i <= d and right response a'_j >= d. But we need a'_i < a'_j.
- Since the sub-strategies preserve order within their intervals, and a'_i <= d <= a'_j, we need to rule out a'_i = d = a'_j. This requires showing that if a_i = c and a_j = c (impossible since a_j > c), or a more careful argument using the order structure.

Actually, the argument is simpler: a_i <= c and a_j > c, so a_i < a_j. On the N side, a'_i <= d and a'_j >= d. If a'_i = a'_j, then a'_i = d = a'_j. But from the left sub-strategy, if a_i < c then a'_i < d (by same_order_type in left game with boundary c/d). If a_i = c, then a'_i = d (same_order_type). And a_j > c implies a'_j > d (same_order_type in right game with boundary c/d). So if a_i < c: a'_i < d <= a'_j, hence a'_i < a'_j. If a_i = c: a'_i = d < a'_j, hence a'_i < a'_j.

**5b. Gap/point agreement** (10-15 lines): Each position i inherits gap/point agreement from whichever sub-strategy produced its response.

**5c. Formula agreement** (10-15 lines): Each position i inherits formula agreement from its sub-strategy.

### Alternative: Cleaner Approach via `n = n_L + n_R` Splitting

Instead of round monotonicity, we can use the full n-round sub-strategies directly by padding:
- Pad the left selections to n elements by filling extra positions with x (or c)
- Pad the right selections to n elements by filling extra positions with c (or y)
- Apply the n-round strategies to the padded selections
- Extract the relevant responses and merge

This avoids needing explicit counting of n_L and n_R and the associated Fin arithmetic.

**Recommended approach**: Use padding (simpler). The padding positions get responses that we discard, so their values do not matter.

## 6. Integration Plan

### How Composition Feeds Into nf_characterizable_by_stavi

The composition lemma is NOT directly used in the sorry at line 1567. Instead, it enables the following chain:

1. **Composition lemma (Prop 7)** enables proving that n-equivalence (agreement on all StaviFormulas of bounded depth) implies Duplicator wins the EF game. This is the MAIN INDUCTION of GHR93 Section 8.

2. The main induction (using Cases I-IV, which are partially formalized in CaseAnalysis.lean) shows:
   - If (M, t) and (N, s) agree on all StaviFormulas of depth <= game_depth(n+1), then Duplicator wins G_{n+1; game_depth(n)}(M, -inf t; N, -inf s) -- where -inf is the left boundary.

3. From this game-theoretic result, Lemma 11 converts game wins to decomposition agreement, which implies NF agreement.

4. The NF agreement at depth game_depth(n) for n-equivalent structures implies that the NF partition is coarser than the n-equivalence partition -- meaning each NF class is a union of n-equivalence classes.

5. Since the n-equivalence classes are definable by StaviFormulas (by definition), and each NF class is a Boolean combination of n-equivalence classes, each NF class is definable by a StaviFormula.

### Where Composition Is Used in the Main Induction

In the four cases of the main induction (CaseAnalysis.lean):

- **Case I** (split point exists): The forward game strategy on [x, y] is DECOMPOSED via strategy restriction into sub-interval strategies on [x, c] and [c, y]. The IH is applied to each sub-interval. Then **Proposition 7 is used to COMPOSE** the resulting sub-interval strategies back into a full-interval backward strategy.

- **Cases II-IV** do not directly use composition; they construct the backward strategy differently using Until/Since/Stavi connective witnesses.

So the composition lemma is specifically needed to close the gap in Case I (and potentially in the top-level induction structure).

### Integration Into the Inductive Step

The actual integration requires more than just Proposition 7. The full chain is:

1. **Unpack nf**: `nf : NormalForm sig (k+1) 1` gives atom assignment `nf.1` and quantifier assignment `nf.2`.

2. **Build atom part**: Same as depth 0 -- conjunction of atom literals (already done in `nf_base_sf`).

3. **Build quantifier part**: For each `sub_nf : NormalForm sig k 2`:
   - Determine order direction (x > t, x < t, x = t) from `sub_nf`'s atom assignment
   - For x > t (Until direction): build `U(A_x, B_guard)` or `U'(A_x, B_guard)` where A_x characterizes x's 1-variable type (from IH) and B_guard characterizes types in the interval (t, x)
   - For x < t (Since direction): build `S(A_x, B_guard)` or `S'(A_x, B_guard)` similarly
   - The CORRECTNESS of these formulas requires the composition lemma to show that the temporal formula captures the 2-variable type

4. **Combine**: The full StaviFormula is a conjunction of the atom part and a conjunction/disjunction over the quantifier part.

5. **Prove correctness**: Show the constructed StaviFormula is equivalent to `nf_eval_nf M (k+1) 1 (fun _ => t) nf`. The atom part is direct. The quantifier part requires:
   - Forward: If `exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf`, show the corresponding temporal formula holds. This uses the game infrastructure to translate from 2-variable NF satisfaction to temporal truth.
   - Backward: If the temporal formula holds, show the existential is satisfied. This uses the composition lemma to reconstruct the 2-variable NF satisfaction from temporal connective semantics.

## 7. Dependencies

### Required for Proposition 7 Itself

| Dependency | Status | Notes |
|------------|--------|-------|
| `ghr93_duplicator_wins` definition | Done | CustomGame.lean:285 |
| `game_tuple` definition | Done | CustomGame.lean:106 |
| `ghr93_winning_condition` | Done | CustomGame.lean:262 |
| `same_order_type` / `formula_agreement` / `gap_point_agreement` | Done | CustomGame.lean |
| `inClosedInterval` | Done | CustomGame.lean:39 |
| `ghr93_duplicator_wins_round_mono` | Done | CustomGame.lean:428 |
| Partition/merge infrastructure | **MISSING** | New definitions needed |
| Cross-interval order transfer lemma | **MISSING** | New lemma needed |

### Required Between Proposition 7 and the Sorry at Line 1567

| Dependency | Status | Notes |
|------------|--------|-------|
| Proposition 7 (composition) | **MISSING** | This research report |
| Main induction bridge (Cases I-IV using composition) | **PARTIAL** | CaseAnalysis.lean has sorries in Cases II, III/IV |
| Forward-to-backward (Theorem 6) | Done | Theorem6.lean (sorry-free) |
| Lemma 11 (game <-> decomposition) | Done | Decomposition.lean |
| NF existence formula for depth k >= 1 | **MISSING** | Requires composition lemma |
| Stavi temporal formula builder for 2-variable NFs | **MISSING** | Requires IH + composition |

### Critical Path

```
Proposition 7 (composition)
  |
  v
Close Case I sorry in CaseAnalysis.lean (uses composition to compose sub-interval strategies)
  |
  v
Close Cases II, III/IV sorries (interval bound issues)
  |
  v
Complete main induction: n-equivalence => Duplicator wins
  |
  v
Build StaviFormula for depth-(k+1) NFs using main induction + IH
  |
  v
Close sorry at StaviCompleteness.lean:1567 (nf_characterizable_by_stavi)
  |
  v
stavi_expressive_completeness (already proved from nf_characterizable_by_stavi)
```

## 8. Estimated Complexity

### Proposition 7 Itself

| Component | Lines | Difficulty |
|-----------|-------|-----------|
| `partition_selections` definition + properties | 30-40 | Low |
| `merge_responses` definition + properties | 30-40 | Low |
| Cross-interval order transfer lemma | 40-60 | Medium |
| Main `ghr93_strategy_compose` theorem | 150-250 | High |
| **Subtotal** | **250-390** | |

The main theorem difficulty is in the winning condition proof (Step 5 above). The order preservation across sub-intervals requires careful case analysis on all pairs of indices, including boundary indices (x, y, b) and selection indices. The game_tuple simplification lemmas (game_tuple_zero_eq, game_tuple_b_eq, game_tuple_y_eq, game_tuple_sel_eq) will be heavily used.

### Integration Into the Sorry

| Component | Lines | Difficulty |
|-----------|-------|-----------|
| Build NF existence formula for k >= 1 sub_nfs | 100-150 | High |
| Prove correctness of existence formula (forward) | 150-200 | Very High |
| Prove correctness of existence formula (backward) | 150-200 | Very High |
| Assemble full StaviFormula for depth-(k+1) NF | 50-80 | Medium |
| Prove full correctness | 100-150 | High |
| **Subtotal** | **550-780** | |

### Upstream Sorries (CaseAnalysis.lean)

| Component | Lines | Difficulty |
|-----------|-------|-----------|
| Close Case II sorry (interval bound) | 100-200 | High |
| Close Cases III/IV sorry (gap detection transfer) | 200-400 | Very High |
| **Subtotal** | **300-600** | |

### Total Estimated Effort

| Scope | Lines | Notes |
|-------|-------|-------|
| Proposition 7 alone | 250-390 | Self-contained, can be done first |
| CaseAnalysis.lean sorries | 300-600 | Depends on Proposition 7 |
| nf_characterizable_by_stavi sorry | 550-780 | Depends on everything above |
| **Grand total** | **1100-1770** | Full path from Proposition 7 to sorry-free |

### Recommended File Location

The composition lemma should be placed in a new section of `CustomGame.lean` (after the strategy restriction theorems) or in a new file `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean` that imports `CustomGame.lean`. Given CustomGame.lean is already 1594 lines, a new file is recommended to keep files manageable.

### Implementation Order

1. **Phase 6A**: Implement `ghr93_strategy_compose` in new `Composition.lean` (250-390 lines)
2. **Phase 6B**: Close CaseAnalysis.lean sorries using composition (300-600 lines)
3. **Phase 6C**: Close `nf_characterizable_by_stavi` sorry using the completed main induction (550-780 lines)

Phase 6A is self-contained and can be implemented and verified independently.
