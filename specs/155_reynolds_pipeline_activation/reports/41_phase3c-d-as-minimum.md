# Report 41: Phase 3C Root Blocker -- Redefining d as the Minimum of Backward Selections

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-27
**Focus**: Faithful GHR93 construction where d = minimum of backward selections, resolving sel_pn_ord and b_resp-vs-p_n sorry sites

---

## 1. GHR93 Faithful Construction

### 1.1 What GHR93 Says About d and Lemma 10

**GHR93 p.115-116 (Section 8, Theorem 6 inductive step)**:

GHR93 defines d (denoted "d-bar" or "c'" in GHR94 Ch 12) as follows:

> Define C = X_{(a_n, y')} -- the interval type formula for (a_n, y').
> Define S_C = { t in [x', y'] : C holds at all mu-points in (t, y') }.
> d-bar = inf(S_C).

This is the infimum of the **continuation set**, not the minimum of the backward selections directly. However, GHR93 then makes a critical move:

**GHR93 p.116, just before the case analysis**:

> "We may assume [the selections] are all distinct."

This is **Lemma 10 (Strategy Restriction)**: Given an n-round Duplicator winning strategy, Duplicator can convert it to a strategy where all of Spoiler's selections in any winning play are distinct. The idea: if Spoiler plays a_i = a_j (i < j), Duplicator copies the response from index j to index i. The resulting play has the same order type, gap/point status, and formula agreement because the duplicated positions are identical.

**After Lemma 10**: With distinct selections, GHR93 assumes WLOG that selections are **strictly ordered**: x' < a_0 < a_1 < ... < a_n < y'. This follows from the game winning condition: the same_order_type condition ensures that the order of a-positions is mirrored on the e-side, so reindexing to increasing order preserves the winning condition.

**Role of d as infimum**: Since a_bwd(n) is in S_C (trivially: the continuation condition is vacuous at a_n itself), and d = inf(S_C) <= a_bwd(n), we have d <= a_bwd(k) for all k (because, in GHR93's construction, all selections lie in S_C or above S_C). Crucially, with the strict ordering x' < a_0 < ... < a_n, the **minimum** of {a_0, ..., a_n} is a_0, and d = inf(S_C) <= a_0.

### 1.2 The sel_pn_ord Ordering in GHR93

In GHR93's Case II (all selections in (d, y'), a_n is a point):

1. Tau is applied to a_0, ..., a_{n-1}, delivering e_0, ..., e_{n-1}.
2. e_n is constructed as a U(B,A) witness above e_{n-1}.
3. Since a_0 < a_1 < ... < a_n (strict ordering), a_k < a_n for all k < n.
4. Since tau preserves ordering, e_0 < e_1 < ... < e_{n-1} < e_n.
5. Therefore (a_k < a_n <-> e_k < e_n) = (True <-> True).
6. And (a_k = a_n <-> e_k = e_n) = (False <-> False).

**GHR93 never needs an explicit ordering argument for sel-vs-p_n.** The ordering is trivial because both sequences are strictly increasing by construction.

### 1.3 What the Formalization Does Differently

The current formalization:

1. Defines d = inf(S_C) correctly (as of recent refactoring in SplitPoint.lean).
2. Does NOT apply Lemma 10 -- selections may have duplicates.
3. Does NOT sort selections to be increasing.
4. Constructs e_n via a d-compatible forward game (not via U(B,A) transfer).
5. Cannot derive sel_pn_ord because a_init(k) and extendPoint p_n are both >= d, creating a "fan" configuration (V-shape) rather than a chain, making pivot_chain_order inapplicable.

---

## 2. Current Infrastructure Inventory

### 2.1 SplitPointProps (SplitPoint.lean:44-111)

| Field | Type | Line |
|-------|------|------|
| `hc_interval` | `inClosedInterval x y c` | 53 |
| `hd_interval` | `inClosedInterval x' y' d` | 55 |
| `hd_le_an` | `d <= a_bwd(n)` | 60 |
| `hxc` | `x <= c` | 62 |
| `hcy` | `c <= y` | 64 |
| `hx'd` | `x' <= d` | 66 |
| `hdy'` | `d <= y'` | 68 |
| `h_pt_xc` | Point in [x,c] or degenerate | 72-73 |
| `h_pt_cy` | Point in [c,y] or degenerate | 77-78 |
| `hcd_form` | Formula agreement c/d at rank r | 81-83 |
| `hcd_gp` | Gap/point correspondence c/d | 86 |
| `sigma` | `ghr93_duplicator_wins N M n r x' d x c` | 89 |
| `tau` | `ghr93_duplicator_wins N M n r d y' c y` | 92 |
| `h_fwd_n1` | `ghr93_duplicator_wins M N (n+1) r x y x' y'` | 96 |
| `h_d_compat_left` | D-compatible (1+3n+1)-round forward | 101-111 |

**Note**: `sel_pn_ord` is NOT a field of SplitPointProps. It is a local `have` with `sorry` inside `ghr93_case_II` in CaseAnalysis.lean.

### 2.2 Definition of d in obtain_split_point_props (SplitPoint.lean:141-162)

The current code defines d as inf(S_C) (continuation set infimum):

```
set S_C := continuation_set x' y' (a_bwd ⟨n, by omega⟩)
-- ...
obtain ⟨d, hd_interval, hd_glb, hd_le_an_proof, hd_is_inf⟩ := ...
```

This is the GHR93-faithful definition. The earlier "d = a_bwd(n)" approach was replaced. The current d = inf(S_C) with:
- `hd_glb : forall s in S_C, d <= s`
- `hd_le_an_proof : d <= a_bwd(n)`
- `hd_is_inf : forall e, (forall s in S_C, e <= s) -> e <= d`

### 2.3 Sorry Sites in CaseAnalysis.lean

| Line | Type | Description |
|------|------|-------------|
| 425 | Case I | Index mapping for same_order_type (pre-existing) |
| 1435 | Case A sel_pn_ord | `intro k; sorry` -- THE PHASE 3C TARGET |
| 1804 | Case B sel_pn_ord | `intro k; sorry` -- THE PHASE 3C TARGET |
| 2015 | Case B b_resp-vs-p_n | `sorry` in grid dispatch -- Phase 3C TARGET |
| 2068 | Case B dead code | `sorry` in block-commented proof |
| 4100 | Cases III-IV | `sorry` for gap detection (independent blocker) |

### 2.4 Downstream Consumers

```
SplitPoint.lean (defines SplitPointProps, obtain_split_point_props)
  |
  +-- CaseAnalysis.lean (imports SplitPoint, uses SplitPointProps)
       |
       +-- ghr93_case_II (uses props.tau, props.h_d_compat_left, etc.)
       |   - sel_pn_ord sorry at lines 1435, 1804
       |   - b_resp-vs-p_n sorry at line 2015
       |
       +-- ghr93_cases_III_IV (sorry at line 4100, independent)
       |
       +-- ghr93_inductive_step (combines cases I-IV)
            |
            +-- Theorem6.lean (imports CaseAnalysis)
                 |
                 +-- ghr93_forward_to_backward (the main theorem)
```

---

## 3. Proposed Changes

### 3.1 Overview: Three-Component Approach

The fix has three components:
1. **Lemma 10 (Strategy Restriction)**: New standalone theorem (~120-160 lines)
2. **Selection Sorting + d = min**: Refactoring in obtain_split_point_props (~100-150 lines)
3. **sel_pn_ord closure**: Replace sorry with trivial proof (~20-30 lines)

Total estimated: 240-340 lines of new/modified code.

### 3.2 Component 1: Lemma 10 (Strategy Restriction)

**Statement** (GHR93 Lemma 10, p.116):

```lean
/-- GHR93 Lemma 10: Strategy restriction to distinct selections.
    If Duplicator has a winning strategy for G_{n;r}(M, xy; N, x'y'),
    then she also has a winning strategy where, for any play with distinct
    Spoiler selections, Duplicator's response is consistent. Equivalently:
    the winning strategy can be assumed to work only on tuples of
    distinct selections, because Duplicator can handle duplicates by
    copying responses. -/
theorem ghr93_strategy_restrict_distinct
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hwin : ghr93_duplicator_wins M N atomMap n r x y x' y') :
    -- For any selection with possible duplicates, Duplicator can produce
    -- a response that agrees with the response to the "distinct" sub-selection.
    -- Operationally: given a : Fin n -> [x,y], let a_distinct be the unique
    -- values, Duplicator responds to a_distinct, then copies for duplicates.
    ghr93_duplicator_wins M N atomMap n r x y x' y'
    -- (The output type is the same -- we get back a winning strategy.
    --  The key property is that if we APPLY this strategy to a selection
    --  with a_i = a_j, the response satisfies a'_i = a'_j.)
```

**Key insight**: The statement is actually trivial in its most direct form -- we already have a winning strategy, and it handles any selections including those with duplicates. The real content of Lemma 10 is that given a winning strategy, if Spoiler plays a_i = a_j, then Duplicator's response satisfies a'_i = a'_j. This follows from the same_order_type condition: if tM(1+i) = tM(1+j), then tN(1+i) = tN(1+j) by the = component of same_order_type.

**The actual needed lemma is not strategy restriction but the WLOG sorting step**: Given any backward selection a_bwd, we can permute it to be (weakly) increasing, and the winning condition is preserved under this permutation.

**Revised Lemma 10 formulation**:

```lean
/-- GHR93 Lemma 10 consequence: the backward game winning condition
    is invariant under permutation of Spoiler's selections plus
    corresponding permutation of Duplicator's responses. -/
theorem ghr93_winning_condition_perm
    {n : Nat} (sigma : Equiv.Perm (Fin n))
    {a_bwd : Fin n → ExtendedCarrier N atomMap r}
    {a'_resp : Fin n → ExtendedCarrier M atomMap r}
    -- ... winning condition for (a_bwd, a'_resp) implies
    -- winning condition for (a_bwd ∘ sigma, a'_resp ∘ sigma)
```

This is straightforward: permuting both sides of the game tuple by the same permutation preserves same_order_type, gap_point_agreement, and formula_agreement.

### 3.3 Component 2: Selection Sorting + d = min

**Current state**: In `obtain_split_point_props`, d = inf(S_C), and there is no sorting of a_bwd. All of a_bwd's entries satisfy d <= a_bwd(i) (because a_bwd(n) is in S_C and d = inf(S_C) <= a_bwd(n), but NOT necessarily d <= a_bwd(k) for k < n).

**Wait -- critical observation**: Currently `hd_le_an : d <= a_bwd(n)` is the ONLY ordering guarantee. The field says d <= a_bwd(n), NOT d <= a_bwd(k) for general k. In CaseAnalysis.lean, `h_no_split : forall i, d <= a_bwd i` is a hypothesis of ghr93_case_II, meaning it is checked AFTER the split-point construction and determines which case (I vs II/III/IV) applies. If some a_bwd(k) < d, Case I applies for that selection.

**This means**: The Phase 3C fix is NOT about changing how d is defined in obtain_split_point_props. d = inf(S_C) is already correct. The issue is that in Case II (all selections >= d), we need sel_pn_ord, which requires strict ordering of selections relative to p_n = a_bwd(n).

**The actual fix needed**: Inside ghr93_case_II (not in obtain_split_point_props), after receiving a_bwd with h_no_split, SORT the selections and show that the winning condition is preserved under permutation.

**Revised approach**:

1. In ghr93_case_II, given `a_bwd : Fin (n+1) -> ExtendedCarrier N atomMap r` with `h_no_split : forall i, d <= a_bwd i`:
2. Let `sigma := Tuple.sort a_bwd` (Mathlib's sorting permutation).
3. Let `a_sorted := a_bwd ∘ sigma` (monotone by `Tuple.monotone_sort`).
4. Show that if we can construct a winning response for `a_sorted`, we can permute back to get a winning response for `a_bwd`.
5. For `a_sorted`: d <= a_sorted(0) <= a_sorted(1) <= ... <= a_sorted(n).
6. `p_n_sorted := a_sorted(n) = a_bwd(sigma(n))` is the maximum.
7. For any k < n: a_sorted(k) <= a_sorted(n) = p_n_sorted.
8. If a_sorted(k) is a point and a_sorted(n) is a point, the ordering is <= (monotone), and we can derive the sel_pn_ord biconditional.

**Subtlety with non-strict ordering**: If a_sorted(k) = a_sorted(n) (duplicate selections), then a_init(k) = p_n, and we need resp_tau(k) = e_n. But resp_tau is Duplicator's response via tau, and e_n is constructed from the forward game. If a_init(k) = p_n, then by tau's same_order_type, resp_tau(k) would have the same formula agreement as a response to p_n. But e_n is from a different game.

**This is the core subtlety that Lemma 10 addresses**: With the WLOG distinct assumption, a_sorted(k) < a_sorted(n) for all k < n (strict), so the equality case never arises.

### 3.4 Component 3: Proving sel_pn_ord After Sorting

After sorting and assuming distinct selections:

```lean
-- a_sorted is strictly increasing (monotone + injective => strictMono)
-- a_sorted(k) < a_sorted(n) for all k < n
-- tau preserves strict ordering: resp_sorted(k) < resp_sorted(n-1)
-- e_n > resp_sorted(n-1) (from U(B,A) construction OR from forward game)
-- Therefore resp_sorted(k) < e_n for all k < n
-- The biconditional is True <-> True
```

But there is a key dependency: the current e_n construction uses the forward game, not U(B,A). With the forward game approach, we get e_n from playing the d-compatible game, and the ordering resp_tau(k) < e_n is NOT guaranteed.

**This reveals the two-pronged nature of Phase 3C**:

1. **Sorting** addresses `a_init(k) < p_n` (N-side): With sorted distinct selections, a_sorted(k) < a_sorted(n) = p_n for all k < n. This makes the N-side of the biconditional trivially True.

2. **e_n construction** addresses `resp_tau(k) < e_n` (M-side): This requires EITHER:
   - (a) U(B,A) transfer approach (GHR93 faithful): e_n > e_{n-1} >= resp_tau(k) by construction. Requires formula materialization (~200+ lines, previously deemed infeasible).
   - (b) Chain through tau's b-response: Play tau with e_n_pt as challenge, get b_tau_en in [d,y']. Then resp_tau(k) < b_tau_en <-> a_init(k) < a_init(tau.b_resp). If b_tau_en = p_n, we're done. But b_tau_en != p_n in general.
   - (c) **Both sides True via independent arguments**: Show a_init(k) < p_n (from sorting) AND resp_tau(k) < e_n (from a separate argument). Then True <-> True.

**Option (c) is the most viable**. The M-side `resp_tau(k) < e_n` can potentially be derived from the d-compatible big game:

From `hord_big` at positions `(1+k, b-position)`: `(a_pad_big(k) < e_n <-> a'_big(k) < p_n)`.
Since `a_pad_big(k) = resp_tau(k)`: `(resp_tau(k) < e_n <-> a'_big(k) < p_n)`.
If `a'_big(k) < p_n` is True, then `resp_tau(k) < e_n` is True.

Can we show `a'_big(k) < p_n`? From `hord_big` at `(1+3n, 1+k)`: `(c < resp_tau(k) <-> d < a'_big(k))`. From `tau_d_sel`: `(d < a_init(k) <-> c < resp_tau(k))`. So `d < a_init(k) <-> d < a'_big(k)`.

With sorted distinct selections: `d <= a_sorted(0) < a_sorted(1) < ... < a_sorted(n) = p_n`. Since d = inf(S_C) and a_sorted(0) is the minimum selection, we have d <= a_sorted(0). If d < a_sorted(0) (which holds when d is strictly below all selections), then d < a_init(k) for all k, giving d < a'_big(k) for all k. But d < a'_big(k) does NOT imply a'_big(k) < p_n.

**This is the same fan problem**. The fundamental issue persists even with sorting: we know d < a'_big(k) and d < p_n, but not a'_big(k) < p_n.

### 3.5 Revised Strategy: Sorting + Modified e_n Construction

The clean resolution requires BOTH:

1. **Sort selections** so a_init(k) < p_n is trivially True (N-side solved).
2. **Modify e_n construction** so resp_tau(k) < e_n is provable (M-side solved).

For (2), instead of the d-compatible forward game, play tau with one additional round. Specifically:

**New e_n construction via (n+1)-round tau**:

If we had `tau_n1 : ghr93_duplicator_wins N M (n+1) r d y' c y` (an (n+1)-round backward game on the right sub-interval), we could play it with the FULL set of selections a_bwd(0),...,a_bwd(n) and get responses e_0,...,e_n plus a point challenge.

From tau_n1's same_order_type: `(a_bwd(k) < a_bwd(n) <-> e_k < e_n)` directly for all k.

**Round budget**: tau is constructed from the IH applied to the restricted forward game on [c,y]/[d,y']. The restricted game has `1+3n` rounds. Applying the IH gives an n-round backward game (tau). For an (n+1)-round backward game, we'd need `1+3(n+1) = 4+3n` rounds, but the restricted game only has `1+3n`.

**However**: the UNRESTRICTED forward game `h_fwd` has `4+3n` rounds. If we could restrict it to [c,y]/[d,y'] with `4+3n` rounds (instead of consuming rounds for the restriction), we'd have enough.

The current strategy_restrict_right consumes 1 round for the restriction step, leaving `3n` rounds. Then `round_mono` gives `1+3n` rounds. The IH converts `1+3n` forward rounds to `n` backward rounds.

For `n+1` backward rounds, we need `1+3(n+1) = 4+3n` forward rounds on [c,y]/[d,y']. The unrestricted game has `4+3n` on [x,y]/[x',y']. Strategy restriction consumes some rounds. The current approach consumes 1 round, leaving `3+3n`. We need `4+3n` on the sub-interval. So we're 1 round short.

**Alternative: Use h_fwd_n1 directly**. `h_fwd_n1 : ghr93_duplicator_wins M N (n+1) r x y x' y'` is an (n+1)-round forward game on the FULL interval. Playing it with selections {resp_tau(0), ..., resp_tau(n-1), e_n_from_tau} on the M-side gives N-side responses, but these are NEW points, not a_init.

### 3.6 The Definitive Approach: Sort + Both-Sides-True

After extensive analysis, the mathematically correct approach that avoids all the game infrastructure issues is:

**Step 1**: Sort selections (via Tuple.sort) to get a_sorted with a_sorted(0) <= ... <= a_sorted(n).

**Step 2**: Apply Lemma 10 (WLOG distinct). This requires proving that when a_sorted(k) = a_sorted(j), the winning condition for the a_sorted tuple can be derived from the winning condition for the deduplicated tuple. Concretely: if a_bwd(i) = a_bwd(j), then a'_resp(i) = a'_resp(j) is forced by same_order_type (the = component). So duplicating responses at equal positions is free.

**Step 3**: With distinct sorted selections: a_sorted(0) < a_sorted(1) < ... < a_sorted(n).

**Step 4**: Show a_sorted(k) < a_sorted(n) = extendPoint p_n for k < n (trivial from strict monotonicity).

**Step 5**: For the M-side, we need resp_tau(k) < e_n. This is where the approach diverges from simply showing "both sides True":

Option A (chain through tau's last element):
- tau_sel_sel gives: a_init(k) < a_init(n-1) <-> resp_tau(k) < resp_tau(n-1)
- With sorted distinct selections: a_init(k) < a_init(n-1) is True for k < n-1
- So resp_tau(k) < resp_tau(n-1) for k < n-1
- We need resp_tau(n-1) < e_n, which IS derivable if we can chain through the pivot d/c:
  - hord_cd_en_pn: c < e_n <-> d < p_n
  - tau_d_sel(n-1): d < a_init(n-1) <-> c < resp_tau(n-1)
  - With sorted distinct: d <= a_sorted(0) < a_sorted(n-1) = a_init(n-1), so IF d < a_init(n-1) is True, then c < resp_tau(n-1) is True
  - And d < p_n (from hd_le_an and strict ordering), so c < e_n is True
  - But c < resp_tau(n-1) and c < e_n does NOT give resp_tau(n-1) < e_n (fan!)

**This is STILL the fan problem for the M-side.** The sorting fixes the N-side but not the M-side.

### 3.7 The Only Clean Fix: Add sel_pn_ord as a New SplitPointProps Field

After exhaustive analysis confirming all game-based approaches fail (reports 33, 34, and this analysis), the mathematically correct fix requires adding `sel_pn_ord` as a field of SplitPointProps that is populated from a richer game infrastructure. Specifically:

**Extend the d-compatible game to include a_init positions**. Create a d-compatible game with `2n+1` selection positions (n for resp_tau, n for a_init, 1 for c), giving a `(2n+2)`-round forward game. The same_order_type from this game would include both a_init and resp_tau in relation to e_n.

**Round budget check**: We need `2n+2` selection slots. The d-compatible game currently uses `1+3n+1 = 3n+2` slots (enough for 2n+2 when n >= 0). So the round budget is sufficient.

**The actual fix**:

Replace `a_pad_big` in CaseAnalysis.lean to include BOTH resp_tau(k) AND a_init(k) as selections:

```lean
let a_pad_big : Fin (1 + 3*n + 1) -> ExtendedCarrier M atomMap r := fun i =>
  if h : i.val < n then resp_tau ⟨i.val, h⟩           -- positions 0..n-1
  else if h2 : i.val < 2*n then  -- positions n..2n-1: need M-side points
    -- corresponding to a_init on N-side... but a_init is N-side!
    sorry -- THIS DOESN'T WORK: a_init is N-side, a_pad_big is M-side
```

**This fails**: a_init(k) are N-side points; we cannot place them in the M-side selection array. The forward game has M selecting and N responding.

### 3.8 Final Assessment: The Root Issue

The root issue is architectural, not about sorting:

1. **tau game**: Spoiler plays N-side (a_init), Duplicator responds M-side (resp_tau). Gives ordering between a_init positions and between resp_tau positions.

2. **d-compatible forward game**: Spoiler plays M-side (resp_tau, c), Duplicator responds N-side (a'_big, d). Gives ordering between resp_tau+e_n on M-side and a'_big+p_n on N-side.

3. **The gap**: a_init (from tau) and a'_big (from forward game) are DIFFERENT N-side point sets with no direct relationship. No amount of sorting changes this.

4. **GHR93's solution**: Construct e_n via U(B,A) transfer, making e_n > e_{n-1} = resp_tau(n-1) by construction. This creates a CHAIN on the M-side: resp_tau(k) <= resp_tau(n-1) < e_n.

5. **Our obstacle**: Formula materialization (creating U(B,A) as a StaviFormula) was deemed infeasible in reports 22 and 30.

**Reframing**: The sel_pn_ord sorry is not resolvable by sorting alone. It requires either:
- (A) Formula materialization (U(B,A) transfer) -- high effort, ~200+ lines
- (B) A new game that includes BOTH a_init and resp_tau with p_n/e_n
- (C) The sorting approach COMBINED WITH a proof that resp_tau(n-1) < e_n

**Option (C) is the most promising** if we can establish resp_tau(n-1) < e_n via a chain argument.

---

## 4. Detailed Design for the Most Viable Approach

### 4.1 Sort + Chain Through (resp_tau(n-1), a_init(n-1))

**N-side chain**: With sorted distinct selections, a_init(k) < a_init(n-1) < p_n for all k < n-1. The a_init(n-1) < p_n holds because a_sorted(n-1) < a_sorted(n) = p_n (strict ordering of distinct sorted elements, where p_n is the n-th = last).

**M-side chain**: We need resp_tau(k) < resp_tau(n-1) < e_n.
- resp_tau(k) < resp_tau(n-1) for k < n-1: follows from tau_sel_sel + N-side strict ordering.
- resp_tau(n-1) < e_n: THIS is the crux. Can we derive it?

**Derivation of resp_tau(n-1) < e_n**:

From the d-compatible big game, a_pad_big(n-1) = resp_tau(n-1) is an M-side selection at position n-1. The b-position is e_n. So hord_big at (1+(n-1), b-position) gives:

```
(resp_tau(n-1) < e_n <-> a'_big(n-1) < extendPoint p_n)
```

So `resp_tau(n-1) < e_n` iff `a'_big(n-1) < extendPoint p_n`.

Can we show `a'_big(n-1) < p_n`?

From hord_big at (1+3n, 1+(n-1)):
```
(c < resp_tau(n-1) <-> d < a'_big(n-1))
```

From tau_d_sel(n-1):
```
(d < a_init(n-1) <-> c < resp_tau(n-1))
```

So: `d < a_init(n-1) <-> d < a'_big(n-1)` and `d = a_init(n-1) <-> d = a'_big(n-1)`.

With sorted distinct selections: d < a_init(n-1) is True (since d = inf(S_C) and a_init(n-1) is strictly above d in the sorted case). So d < a'_big(n-1) is True.

But d < a'_big(n-1) and d < p_n does NOT give a'_big(n-1) < p_n. **Fan problem again.**

### 4.2 New Idea: Play Tau With (n+1) Positions via Augmented Selection

Instead of playing tau with only the first n selections, play it with all n+1 selections (a_bwd(0),...,a_bwd(n)). This requires an (n+1)-round tau, which we don't have.

**But**: We do have tau as an n-round game. We can play it with n positions from {a_bwd(0),...,a_bwd(n)} minus the minimum. With sorted distinct selections, the minimum is a_sorted(0). If we set d = a_sorted(0) as the left boundary, then tau covers [a_sorted(0), y'] / [c, y], and we play it with a_sorted(1),...,a_sorted(n) (which are n positions, all strictly above d = a_sorted(0)).

**This is exactly the GHR93 construction!**

In this restructured approach:
- d = a_sorted(0) = minimum of the selections
- tau covers [d, y'] / [c, y] with n selections a_sorted(1),...,a_sorted(n)
- a_init(k) = a_sorted(k+1) for k < n
- p_n = a_sorted(n) (the maximum)
- a_init(k) < p_n for all k < n (strict ordering)
- tau produces resp_tau(0),...,resp_tau(n-1) with same ordering
- For the M-side: resp_tau(k) < resp_tau(n-1) for k < n-1 (from tau ordering)
- e_n is constructed from the forward game with p_n as challenge
- We STILL need resp_tau(n-1) < e_n

**The key difference**: With d = minimum of selections (not inf(S_C)), we have d = a_sorted(0) which is an ACTUAL SELECTION, not just a lower bound. This means d is either a carrier point or a gap in [x', y'].

**Problem**: Changing d from inf(S_C) to min(selections) breaks the continuation set construction. d = inf(S_C) is needed for the Claim 1 argument (showing c corresponds to d). d = min(selections) does not have the same continuation set properties.

### 4.3 Reconciliation: Two Different d's

GHR93 uses d = inf(S_C) for the Claim 1 argument AND assumes sorted distinct selections. The key GHR93 claim is that with sorted distinct selections, inf(S_C) <= a_sorted(0) < a_sorted(1) < ... < a_sorted(n), so ALL selections are in (d, y'] (strictly above d). The split point d is BELOW all selections.

In Case II: all selections >= d. With sorted distinct: a_sorted(0) > d OR a_sorted(0) = d.

If a_sorted(0) = d: Then the minimum selection equals d. This means tau covers [d, y'] with selections a_sorted(1),...,a_sorted(n), and d = a_sorted(0) is the LEFT BOUNDARY of tau, not a selection. We have n selections for the n-round tau. Good.

If a_sorted(0) > d: All selections are STRICTLY above d. Tau covers [d, y'] with all n+1 selections, but tau only has n rounds. We need to either:
- Use the minimum as a special position (not fed to tau)
- OR play tau with n of the n+1 selections and handle the remaining one differently

**GHR93's answer**: p_n (= a_bwd(n) = a_sorted(n) = maximum) is handled separately via the U(B,A) construction. Tau handles the other n selections a_sorted(0),...,a_sorted(n-1).

With d = inf(S_C) and sorted distinct:
- d <= a_sorted(0) < a_sorted(1) < ... < a_sorted(n)
- tau covers [d, y'] with n rounds, applied to a_sorted(0),...,a_sorted(n-1) (n positions)
- p_n = a_sorted(n) is the maximum
- a_init(k) = a_sorted(k) for k < n
- p_n = a_sorted(n) > a_sorted(k) = a_init(k) for all k < n -- **N-SIDE SOLVED**

For the M-side: e_n is constructed via the forward game. We need resp_tau(k) < e_n.

With the sorted approach, a_init(n-1) = a_sorted(n-1) is the SECOND LARGEST selection. It is the largest selection fed to tau. So resp_tau(n-1) is the M-side response to the largest tau selection.

We need resp_tau(n-1) < e_n. This still requires the chain argument through the pivot, which still has the fan problem.

### 4.4 The Real Resolution: Both-Sides-True with Sorted Selections

With sorted distinct selections, the biconditional `a_init(k) < p_n <-> resp_tau(k) < e_n` has the N-side True (a_init(k) < p_n). For the biconditional to hold, we need the M-side True (resp_tau(k) < e_n).

**Key claim**: resp_tau(k) < e_n follows from c <= resp_tau(k) < e_n, where c < e_n is derivable from hord_cd_en_pn and d < p_n.

Wait. We have:
- hord_cd_en_pn: `c < e_n <-> d < p_n`
- With sorted distinct: d <= a_sorted(0) < a_sorted(n) = p_n, so d < p_n (unless d = p_n, which would mean all selections equal d -- handled separately)
- So c < e_n

And:
- c <= resp_tau(k) (from hc_le_rtau)

So c <= resp_tau(k) and c < e_n. But this gives NO ordering between resp_tau(k) and e_n.

**Unless resp_tau(k) = c**: Then resp_tau(k) < e_n follows from c < e_n. But resp_tau(k) = c happens only if a_init(k) = d (from tau_d_sel), which in the sorted distinct case means a_sorted(k) = d. If d is strictly below all selections, this doesn't happen. If d = a_sorted(0), then a_init(0) = d, resp_tau(0) = c (by tau_d_sel's = component), and resp_tau(0) = c < e_n.

For k > 0 with sorted distinct: a_init(k) > a_init(0) >= d, so d < a_init(k), giving c < resp_tau(k). So resp_tau(k) > c. But c < e_n and resp_tau(k) > c still gives no ordering between resp_tau(k) and e_n.

**The fan problem is truly fundamental.** No amount of sorting resolves it without either:
1. A game that includes BOTH resp_tau(k) and e_n as positions with a_init(k) and p_n as their counterparts
2. The U(B,A) transfer giving e_n > resp_tau(n-1) directly

---

## 5. Lemma 10 Design

### 5.1 Precise Lean Statement

```lean
/-- GHR93 Lemma 10: Winning condition is preserved under permutation of
    Spoiler's and Duplicator's selection arrays by the same permutation. -/
theorem ghr93_winning_condition_perm
    {n : Nat} {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (a : Fin n → ExtendedCarrier M atomMap r)
    (a' : Fin n → ExtendedCarrier N atomMap r)
    (b : M.carrier) (b' : N.carrier)
    (sigma : Equiv.Perm (Fin n))
    (hwin : ghr93_winning_condition n
      (game_tuple x y a b) (game_tuple x' y' a' b')) :
    ghr93_winning_condition n
      (game_tuple x y (a ∘ sigma) b)
      (game_tuple x' y' (a' ∘ sigma) b')
```

### 5.2 Proof Strategy

The proof unfolds `ghr93_winning_condition` into three components:
- **same_order_type**: For any i, j in the permuted tuple, `game_tuple x y (a ∘ sigma) b` at position i maps to `(a ∘ sigma)(i-1) = a(sigma(i-1))` for selection positions. The ordering `a(sigma(i-1)) < a(sigma(j-1))` iff `a'(sigma(i-1)) < a'(sigma(j-1))` follows from the ORIGINAL same_order_type at positions sigma(i-1) and sigma(j-1).
- **gap_point_agreement**: Same argument -- permuting indices preserves the property.
- **formula_agreement**: Same argument.

Estimated: ~60-80 lines.

### 5.3 Mathlib Dependencies

- `Tuple.sort : (Fin n -> alpha) -> Equiv.Perm (Fin n)` (from `Mathlib.Data.Fin.Tuple.Sort`)
- `Tuple.monotone_sort : Monotone (f ∘ (Tuple.sort f))` (same module)
- `Monotone.strictMono_of_injective` (from `Mathlib.Order.Monotone.Defs`) -- for converting monotone + injective to strictMono

---

## 6. Sorting Infrastructure

### 6.1 What Mathlib Provides

| Definition/Theorem | Module | Purpose |
|---|---|---|
| `Tuple.sort` | `Mathlib.Data.Fin.Tuple.Sort` | Returns a permutation that sorts a tuple |
| `Tuple.monotone_sort` | same | `f ∘ (Tuple.sort f)` is monotone |
| `Tuple.sort_eq_refl_iff_monotone` | same | sort is identity iff already monotone |
| `Tuple.eq_sort_iff` | same | Characterizes when sigma = sort f |
| `Monotone.strictMono_of_injective` | `Mathlib.Order.Monotone.Defs` | Monotone + injective = strictMono |
| `StrictMono.injective` | `Mathlib.Order.Monotone.Basic` | StrictMono implies injective |
| `Finset.min'_le` | `Mathlib.Data.Finset.Max` | Minimum of finset <= any member |

### 6.2 Application to a_bwd

```lean
-- Sort a_bwd
let sigma := Tuple.sort a_bwd
let a_sorted : Fin (n+1) -> ExtendedCarrier N atomMap r := a_bwd ∘ sigma
-- a_sorted is monotone
have h_mono : Monotone a_sorted := Tuple.monotone_sort a_bwd
-- a_sorted(n) is the maximum
have h_max : ∀ k : Fin (n+1), a_sorted k ≤ a_sorted ⟨n, by omega⟩ :=
  fun k => h_mono (Fin.le_last k)
```

For distinct selections (after Lemma 10):
```lean
-- If a_sorted is injective, then strictMono
have h_strict : StrictMono a_sorted :=
  h_mono.strictMono_of_injective h_inj
-- a_sorted(k) < a_sorted(n) for k < n
have h_lt : ∀ k : Fin n, a_sorted ⟨k.val, by omega⟩ < a_sorted ⟨n, by omega⟩ :=
  fun k => h_strict (by omega : (⟨k.val, by omega⟩ : Fin (n+1)) < ⟨n, by omega⟩)
```

---

## 7. Blast Radius Assessment

### 7.1 Files Affected

| File | Impact |
|------|--------|
| `SplitPoint.lean` | **No change needed** -- d = inf(S_C) is already correct |
| `CaseAnalysis.lean` | **Major** -- ghr93_case_II needs sorting + permutation |
| `CustomGame.lean` | **Minor** -- add `ghr93_winning_condition_perm` (~60-80 lines) |
| `Theorem6.lean` | **None** -- consumes CaseAnalysis output, no structural change |

### 7.2 Properties of d That Would Break

If d's definition changed (which we are NOT recommending):
- `hd_le_an : d <= a_bwd(n)` -- would break if d = min(selections) instead of inf(S_C)
- All Claim 1 infrastructure -- relies on d = inf(S_C)
- sigma/tau sub-interval boundaries -- rely on d's continuation set properties

**Our recommendation does NOT change d's definition.** d remains inf(S_C).

### 7.3 Downstream Impact

The sel_pn_ord sorry is consumed only inside ghr93_case_II (CaseAnalysis.lean). Closing it affects:
- Case A grid dispatch (line ~1594)
- Case B grid dispatch (line ~1866)
- The b_resp vs p_n sorry (line ~2015) -- SEPARATE ANALYSIS NEEDED

---

## 8. Does d-as-minimum Also Fix b_resp vs p_n?

### 8.1 The b_resp vs p_n Sorry (CaseAnalysis.lean:2015)

In Case B (c < b_sp), the grid dispatch needs:
```
(extendPoint b_resp < extendPoint p_n <-> extendPoint b_sp < e_n)
```

where b_resp is Duplicator's Round 2 response from the tau game to the challenge b_sp.

This has the same fan structure: d <= b_resp and d <= p_n, so pivot through d fails.

### 8.2 Analysis

The b_resp vs p_n ordering is:
- N-side: `b_resp < p_n`? b_resp is in [d, y'], p_n = a_sorted(n) is in [d, y']. No ordering guaranteed.
- M-side: `b_sp < e_n`? b_sp is in [x, y], e_n is in [x, y]. No ordering guaranteed.

From the tau game's ordering at (b-position, sel(n-1)):
```
(b_resp < a_init(n-1) <-> b_sp < resp_tau(n-1))
```

And from the tau game at (b-position, 0-position):
```
(d < b_resp <-> c < b_sp)
```

With sorted distinct selections and the pivot through a_init(n-1)/resp_tau(n-1):
- If we knew b_resp < p_n <-> b_resp < a_init(n-1) (only when a_init(n-1) = p_n, which is false with distinct), this wouldn't help.

**The b_resp vs p_n sorry is also the fan problem.** Sorting does NOT fix it. The b_resp position comes from tau's Round 2, and p_n/e_n come from the forward game. They are in different games with no direct connection.

### 8.3 Conclusion

No, the d-as-minimum restructure does NOT fix the b_resp vs p_n sorry. That sorry requires the same kind of game infrastructure change (a game that includes both b_resp and p_n as related positions).

---

## 9. Estimated Complexity

### 9.1 If Using Sort + Both-Sides-True (Requires M-side resp_tau(k) < e_n)

| Component | Lines | Difficulty |
|-----------|-------|------------|
| `ghr93_winning_condition_perm` in CustomGame.lean | 60-80 | Medium |
| Sorting infrastructure in ghr93_case_II | 30-50 | Low |
| WLOG distinct (Lemma 10 proper) | 80-120 | Medium-High |
| Proving resp_tau(k) < e_n (M-side) | ??? | **BLOCKED** (fan problem) |
| sel_pn_ord closure (if M-side solved) | 20-30 | Low |
| **Total (excluding M-side)** | **190-280** | |

### 9.2 If Using U(B,A) Transfer (Full GHR93 Alignment)

| Component | Lines | Difficulty |
|-----------|-------|------------|
| Formula materialization (X_t as StaviFormula) | 100-150 | High |
| U(B,A) construction and semantics | 80-120 | High |
| tau formula transfer at rank r+1 | 40-60 | Medium |
| e_n = U(B,A) witness extraction | 30-50 | Medium |
| Sorting + Lemma 10 (may not be needed) | 0-120 | Low-Medium |
| sel_pn_ord closure (trivial) | 10-20 | Low |
| **Total** | **260-520** | |

### 9.3 If Using Augmented Forward Game (2n+2 positions)

Not feasible -- a_init are N-side, cannot be placed in M-side selection.

---

## 10. Recommendations

### 10.1 Primary Recommendation: Hybrid Approach

The most viable approach combines:

1. **Sort selections** in ghr93_case_II (~40 lines). This solves the N-side of sel_pn_ord trivially.

2. **For the M-side**: Instead of proving resp_tau(k) < e_n from existing infrastructure, **change the e_n construction** to use an (n+1)-round tau game obtained by passing the IH parameter differently.

   Specifically: Instead of applying tau (n-round) to a_init(0),...,a_init(n-1) and using the forward game for e_n, pass ALL n+1 sorted positions through a single combined game. This requires rethinking how tau is used, potentially by:
   - Playing the forward game h_fwd_n1 with the n+1 M-side selections being resp_sigma + resp_tau combined
   - Extracting the ordering from a single same_order_type that covers all positions

3. **As a fallback**: Keep sel_pn_ord as a sorry'd local `have` and track it as a known mathematical debt, with the understanding that the full fix requires either formula materialization or a deeper game infrastructure change.

### 10.2 If Full Sorry-Free Closure Is Required

The only approaches that achieve full sorry-free closure are:

A. **Formula materialization** (U(B,A) transfer): Faithfully follows GHR93. Estimated 260-520 lines. High difficulty. Previously deemed infeasible in reports 22 and 30, but should be re-evaluated.

B. **Restructure to use a single (n+1)-round game**: Instead of separate tau + forward game, use one (n+1)-round backward game on the full interval that covers all positions. This requires a fundamentally different proof architecture than what exists.

### 10.3 Not Recommended

- Changing d from inf(S_C) to min(selections): Breaks Claim 1 infrastructure for no gain.
- Any game-based approach that tries to relate a'_big to a_init: Proven infeasible.
- Sorting alone without addressing the M-side: Solves N-side only.

---

## Appendix: Key File References

| Item | File | Lines |
|------|------|-------|
| SplitPointProps structure | SplitPoint.lean | 44-111 |
| obtain_split_point_props | SplitPoint.lean | 141-1040 |
| d = inf(S_C) construction | SplitPoint.lean | 163-184 |
| SplitPointProps assembly | SplitPoint.lean | 1024-1040 |
| ghr93_case_II | CaseAnalysis.lean | 1187-2015 |
| sel_pn_ord sorry (Case A) | CaseAnalysis.lean | 1432-1435 |
| sel_pn_ord sorry (Case B) | CaseAnalysis.lean | 1801-1804 |
| b_resp vs p_n sorry | CaseAnalysis.lean | 2010-2015 |
| Cases III-IV sorry | CaseAnalysis.lean | 4100 |
| ghr93_duplicator_wins | CustomGame.lean | 285-303 |
| same_order_type | CustomGame.lean | 228-235 |
| game_tuple | CustomGame.lean | 106-115 |
| pivot_chain_order' | EFGameTactics.lean | 86-92 |
| Tuple.sort | Mathlib.Data.Fin.Tuple.Sort | (Mathlib) |
| Tuple.monotone_sort | Mathlib.Data.Fin.Tuple.Sort | (Mathlib) |
| continuation_set | Claim1.lean | 164-170 |
| Report 33 (lit-sel-pn-ordering) | specs/155.../reports/ | Full report |
| Report 33 (infra-sel-pn-fix) | specs/155.../reports/ | Full report |
| Report 34 (lemma10-strategy-restrict) | specs/155.../reports/ | Full report |
