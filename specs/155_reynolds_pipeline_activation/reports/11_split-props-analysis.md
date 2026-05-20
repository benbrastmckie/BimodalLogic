# Analysis: obtain_split_point_props Sorry

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`, lines 172-210
**Task**: 155, Phase 4C.2 (inductive step setup)
**Date**: 2026-05-20

---

## 1. What the Sorry Must Produce

`obtain_split_point_props` constructs a `SplitPointProps` record containing:

```lean
∃ (c : ExtendedCarrier M atomMap r) (d : ExtendedCarrier N atomMap r),
  SplitPointProps n x y x' y' c d a_bwd
```

The record fields are:
- `hc_interval : inClosedInterval x y c` and `hd_interval : inClosedInterval x' y' d`
- `hd_le_an : d ≤ a_bwd ⟨n, ...⟩`
- `hxc, hcy, hx'd, hdy'` (sub-interval well-formedness, redundant with interval membership)
- `sigma : ghr93_duplicator_wins N M atomMap n r x' d x c`
- `tau : ghr93_duplicator_wins N M atomMap n r d y' c y`

Available hypotheses:
- `hxy : x ≤ y`, `hx'y' : x' ≤ y'`
- `h_pt : ∃ p : N.carrier, inClosedInterval x' y' (extendPoint p)`
- `ih : ghr93_duplicator_wins M N atomMap (1+3*n) r x y x' y' → ghr93_duplicator_wins N M atomMap n r x' y' x y`
- `h_fwd : ghr93_duplicator_wins M N atomMap (4+3*n) r x y x' y'`
- `a_bwd : Fin (n+1) → ExtendedCarrier N atomMap r` (Spoiler's backward picks)
- `ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i)`

---

## 2. Question-by-Question Analysis

### Q1: Infimum Infrastructure

**Current state**: `ExtendedCarrier M atomMap r` has a `LinearOrder` instance (`extendedLinearOrder`). There is NO `ConditionallyCompleteLattice`, `InfSet`, `sSup`, or `sInf` instance.

**Does M_r have infima?** Not automatically. `ExtendedCarrier` is `M.carrier ⊕ RDefinableGap M atomMap r`. Even if `M.carrier` has a conditionally complete lattice structure, the sum type with the interleaved ordering does not inherit one from Mathlib. There is no Mathlib instance that gives `ConditionallyCompleteLattice` to a custom sum type with non-standard ordering.

**What GHR93 actually needs**: The infimum d is defined as `inf{t in [x',y'] : C holds on (t,y') in N_r}`. This is an infimum of a subset of a linearly ordered type. The infimum exists as an element of M_r precisely because M_r contains all r-definable gaps -- any Dedekind cut in M_r that is r-definable has a corresponding element.

**Can we use `Classical.choice`?** Not directly for an infimum. We would need to show that the set `{t in [x',y'] : C holds on (t,y')}` is bounded below (it is, by x') and non-empty, then appeal to conditional completeness. But we do not have conditional completeness.

**Recommended approach**: Bypass the infimum construction entirely. The GHR93 proof uses d as an infimum for conceptual clarity, but the formal content only requires:

1. d is in [x',y']
2. d <= a_n (the last selection)
3. Duplicator has backward strategies on [x',d] and [d,y']

These can be obtained without computing an actual infimum. Instead, use the forward strategy `h_fwd` to derive the split points by playing the game strategically. The key insight: we do not need "the" infimum; we need "a" point with these properties.

**Alternative: existential split point**. Given the (4+3n)-round forward strategy, we can:
- Play 1+3n rounds on the full interval to invoke the IH
- Use the remaining 3 rounds to "locate" the split point
- The split point can be obtained as the response to a carefully chosen Spoiler move

This avoids all lattice infrastructure.

### Q2: Strategy Restriction

**The question**: Given `ghr93_duplicator_wins M N atomMap k r x y x' y'` and c in [x,y], d in [x',y'], can we derive `ghr93_duplicator_wins M N atomMap k r x c x' d`?

**Reading the game definition carefully**:

```lean
def ghr93_duplicator_wins M N atomMap n r x y x' y' :=
  ∀ (a : Fin n → ExtendedCarrier M atomMap r),
    (∀ i, inClosedInterval x y (a i)) →
    ∃ (a' : Fin n → ExtendedCarrier N atomMap r),
      (∀ i, inClosedInterval x' y' (a' i)) ∧
      ∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
        ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
          ghr93_winning_condition n (game_tuple x y a b) (game_tuple x' y' a' b')
```

**Strategy restriction does NOT work directly.** The winning condition (`ghr93_winning_condition`) compares game tuples that include the boundary elements x, y (and x', y') at indices 0 and n+2. If we restrict from [x,y] to [x,c], the game tuple changes: the boundary y is replaced by c. But the original strategy's winning condition was proved for tuples with boundary y, not c.

Specifically: `game_tuple x y a b` has `x` at index 0 and `y` at index n+2. Restricting to `game_tuple x c a b` puts `c` at index n+2. The formula agreement, order type, and gap/point agreement at index n+2 would need to hold for c (resp. d) rather than y (resp. y'). The original strategy says nothing about formula agreement at c vs d.

**What is actually needed**: A new lemma:

```lean
theorem ghr93_strategy_restrict_left
    (h : ghr93_duplicator_wins M N atomMap k r x y x' y')
    (hc : inClosedInterval x y c) (hd : inClosedInterval x' y' d)
    (hc_d_agree : rank_type M atomMap r c = rank_type N atomMap r d)
    (hc_d_gap : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d)) :
    ghr93_duplicator_wins M N atomMap k r x c x' d
```

This requires that c and d agree on rank-r types and gap/point status (which is how c and d are constructed in GHR93 -- d is defined by a formula, c is the corresponding element from the strategy). The proof would:

1. Take any Spoiler selection in [x,c], which is also in [x,y]
2. Apply the full strategy to get a response in [x',y']
3. Show the response is actually in [x',d] (using the type agreement at c/d and the strategy's order-preservation)
4. Transfer the winning condition

**This is non-trivial but feasible**. Estimated: 80-120 lines. The main difficulty is step 3: showing that the strategy's responses, when fed selections from [x,c], stay in [x',d]. This follows from the order-preservation in the winning condition (same_order_type) combined with the fact that all selections are <= c, so all responses are <= d (since c and d correspond under the strategy).

### Q3: IH Application (Round Reduction)

**The problem**: We start with a (4+3n)-round forward strategy on [x,y] vs [x',y']. We need (1+3n)-round forward strategies on [x,c] vs [x',d] and [c,y] vs [d,y']. Then we apply the IH to convert these to n-round backward strategies.

**Round reduction**: From (4+3n) rounds to (1+3n) rounds. The difference is 3 rounds. This is handled by `ghr93_duplicator_wins_round_mono` (already proved in EFGames.lean):

```lean
theorem ghr93_duplicator_wins_round_mono (hn : n' ≤ n)
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h : ghr93_duplicator_wins M N atomMap n r x y x' y') :
    ghr93_duplicator_wins M N atomMap n' r x y x' y'
```

Since `1 + 3*n ≤ 4 + 3*n`, round monotonicity gives us a (1+3n)-round strategy on the full interval. Combined with strategy restriction (Q2), we get (1+3n)-round strategies on the sub-intervals. Then the IH converts these to n-round backward strategies.

**Chain of inference**:
1. `h_fwd : ghr93_duplicator_wins M N atomMap (4+3*n) r x y x' y'`
2. By round_mono (since 1+3*n <= 4+3*n): `ghr93_duplicator_wins M N atomMap (1+3*n) r x y x' y'`
3. By strategy_restrict_left: `ghr93_duplicator_wins M N atomMap (1+3*n) r x c x' d`
4. By ih: `ghr93_duplicator_wins N M atomMap n r x' d x c` (= sigma)

Similarly for tau on the right sub-interval.

**Blocker**: Step 3 requires `strategy_restrict_left` (not yet written). Step 4 requires the IH to work on sub-intervals, but the current IH is:

```lean
ih : ghr93_duplicator_wins M N atomMap (1+3*n) r x y x' y' →
     ghr93_duplicator_wins N M atomMap n r x' y' x y
```

This IH is stated for the **full** interval [x,y], not sub-intervals. The induction in `ghr93_forward_to_backward` is on n, with x, y, x', y' universally quantified. So the IH actually applies to ANY interval, not just [x,y]. But the current formalization has the IH bound to specific x, y, x', y'.

**This is a structural issue.** The current proof structure binds the IH to specific endpoints. The fix is to ensure the induction is set up so the IH is universally quantified over all endpoints. Looking at line 388:

```lean
induction n with
| zero => ...
| succ n _ih => ...
```

The `_ih` provided by `induction n` in the `succ` case will be the full theorem statement with `n` replacing `n+1`, BUT it will be for the same `M, N, atomMap, x, y, x', y'` from the theorem context. Since these are universally quantified in the theorem statement, `_ih` should actually be usable for any endpoints.

Let me verify: the theorem is `ghr93_forward_to_backward atomMap n r ... x y x' y' ... h`. The induction on `n` gives IH for `n` at any `r, x, y, x', y'`. Yes, because these are universally quantified in the theorem. The `_ih` at line 437 has the correct polymorphic type. So the IH can be applied to sub-intervals directly.

**Conclusion**: The IH application works. The only missing piece is `strategy_restrict_left` (and its right-side dual).

### Q4: Does d Need to Be a Gap or Can It Be a Point?

In GHR93, d = inf{t in [x',y'] : C holds on (t,y')}. This infimum could be:
- An actual point of N (if the infimum falls on a point)
- A gap of N (if the infimum falls in a Dedekind cut)
- A boundary element x' or y'

In the formalization, d has type `ExtendedCarrier N atomMap r`, which is `N.carrier ⊕ RDefinableGap N atomMap r`. So d can be either a point or a gap -- no special treatment needed. The `ExtendedCarrier` type already handles both cases uniformly.

The key constraint is that d must be in [x',y'] and d <= a_n. Whether d is a point or gap does not affect the construction of sigma and tau.

### Q5: Simplification from Uniform Rank

The uniform-rank version means all elements (x, y, c, d, a_i, etc.) live in the same `ExtendedCarrier M atomMap r`. This eliminates:

1. No rank embedding needed for the split points (they live at the same rank as everything else)
2. No cross-rank coercion for strategy restriction
3. The IH and round monotonicity operate at the same rank

This is a significant simplification over the full GHR93 statement. The strategy restriction lemma only needs to work within a single rank level.

---

## 3. Missing Infrastructure (Ordered by Priority)

### 3.1 Strategy Restriction (HIGH PRIORITY, ~100-150 lines)

Two lemmas needed:

```lean
theorem ghr93_strategy_restrict_left
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k r : Nat} {x y c : ExtendedCarrier M atomMap r}
    {x' y' d : ExtendedCarrier N atomMap r}
    (h : ghr93_duplicator_wins M N atomMap k r x y x' y')
    (hxc : x ≤ c) (hcy : c ≤ y)
    (hx'd : x' ≤ d) (hdy' : d ≤ y')
    (hcd_type : rank_type M atomMap r c = rank_type N atomMap r d)
    (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d)) :
    ghr93_duplicator_wins M N atomMap k r x c x' d

theorem ghr93_strategy_restrict_right
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k r : Nat} {x y c : ExtendedCarrier M atomMap r}
    {x' y' d : ExtendedCarrier N atomMap r}
    (h : ghr93_duplicator_wins M N atomMap k r x y x' y')
    (hxc : x ≤ c) (hcy : c ≤ y)
    (hx'd : x' ≤ d) (hdy' : d ≤ y')
    (hcd_type : rank_type M atomMap r c = rank_type N atomMap r d)
    (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d)) :
    ghr93_duplicator_wins M N atomMap k r c y d y'
```

**Proof approach**: Given Spoiler's selection in [x,c], it is also in [x,y]. Apply the full strategy. The key step is showing responses land in [x',d]: from the winning condition, same_order_type ensures that if all selections are <= c (resp. >= c), then all responses are <= d (resp. >= d). The formula agreement and gap/point agreement at c/d carry over to the restricted game tuple because c and d have the same rank_type.

### 3.2 Split Point Construction (HIGH PRIORITY, ~80-120 lines)

The actual construction of c and d. Two approaches:

**Approach A (Infimum-based, faithful to GHR93)**:
- Requires `ConditionallyCompleteLattice (ExtendedCarrier M atomMap r)` or manual infimum
- Substantial infrastructure investment (~200+ lines for the lattice instance)
- Not recommended

**Approach B (Game-based, simpler)**:
Use the forward strategy itself to find c and d. Given the (4+3n)-round forward strategy:

1. Play the forward game with a_bwd as Spoiler's selection (padded to (4+3n) elements)
2. The strategy gives responses in [x,y]
3. Pick d = a_bwd(n) (the last Spoiler pick, or x' if simpler)
4. Pick c = the strategy's response to d

This avoids infimum computation entirely. The split point properties follow from the strategy's winning condition.

Actually, re-reading GHR93 more carefully: the construction of d depends on A = X_{(a_{n-1}, a_n)}, which is the interval type formula. d is the infimum of points where this formula's "continuation" C holds. This is deeply tied to the formula structure.

**Approach C (Existential, recommended)**:
Since `obtain_split_point_props` only needs to produce existence (`∃ c d, SplitPointProps ...`), we can use `Classical.choice` more freely. The argument:

1. The (4+3n)-round forward strategy on [x,y] vs [x',y'] can be restricted to (1+3n) rounds by round_mono
2. Apply the IH to the full interval to get `ghr93_duplicator_wins N M atomMap n r x' y' x y`
3. For any split point d in [x',y'] with d <= a_n, we need backward strategies on [x',d] and [d,y']
4. Use d = x' (trivial split): sigma becomes the 0-game on [x',x'] (vacuous), and tau = full backward strategy from IH

Wait -- this trivial split gives sigma on a degenerate interval [x',x'] and tau on [x',y'], which does NOT help for Case I (where some selections are below d). If d = x', then no selection can be below d (since all are in [x',y']), making Case I vacuously impossible. But then Cases II-IV need the full backward strategy on [x',y'], which is just the IH.

**This suggests the trivial split d = x', c = x might work for the type structure**, but it would make Case I impossible and force everything into Cases II-IV. Let me reconsider...

Actually, the current code already does this (lines 197-210): it sets c = x, d = x' as placeholders. The issue is that the split fields `hd_le_an`, `sigma`, and `tau` are sorry'd.

For `hd_le_an` with d = x': this would require x' <= a_bwd(n), which follows from `ha_bwd n` (all selections are in [x',y'], hence x' <= a_bwd(n)). So `hd_le_an` is provable with d = x'.

For sigma with d = x': `ghr93_duplicator_wins N M atomMap n r x' x' x x`. This is a game on a degenerate interval [x',x']. Spoiler must choose n elements from [x',x'], all equal to x'. Duplicator responds with n copies of x. The winning condition requires formula agreement at x' vs x, which is NOT guaranteed.

So the trivial split does NOT work for sigma unless x and x' are type-equivalent.

**Recommended approach**: The construction must be non-trivial. The most practical path:

1. From the (4+3n)-round forward strategy, extract the first move: play with 1 element = a_bwd(n) in [x,y]
2. The strategy gives a response a'(0) in [x',y'] -- call it c_candidate
3. Now restrict: play the remaining (3+3n) rounds on [x, c_candidate] and [c_candidate, y]
4. Use round_mono to get (1+3n) rounds on each sub-interval
5. Apply IH to each sub-interval

This requires:
- Playing the forward game with specific selections
- Extracting the strategy's response
- Showing the response preserves type agreement

Estimated: ~150-200 lines including helper lemmas.

### 3.3 Type Agreement at Split Points (MEDIUM PRIORITY, ~50-80 lines)

Need to show that c and d (however constructed) have the same rank_type. This follows from the winning condition of the forward strategy when c and d correspond to each other in a play of the game.

---

## 4. Effort Estimate

| Component | Lines | Difficulty |
|-----------|-------|-----------|
| Strategy restriction (left + right) | 100-150 | Medium-Hard |
| Split point construction | 150-200 | Hard |
| Type agreement at split points | 50-80 | Medium |
| IH wiring (sub-interval application) | 30-50 | Easy |
| **Total for obtain_split_point_props** | **330-480** | **Hard** |

This is the single hardest sorry in Phase 4C. Cases I-IV each consume the split point properties but do not require additional infrastructure of this kind.

---

## 5. Recommended Simplification

### Option: Refactor the IH

The current IH is bound to specific endpoints. Refactoring `ghr93_forward_to_backward` to use strong induction with universally quantified endpoints would make the sub-interval application cleaner. This is already the case (the theorem universally quantifies x, y, x', y'), so `_ih` at the induction step should already be polymorphic. Verify by checking the type of `_ih` in the `succ n` branch.

### Option: Defer Infimum, Use Direct Game Play

Instead of computing d as an infimum, define d operationally:
1. Play the forward strategy with a specific selection that includes a_bwd(n)
2. Extract the strategy's response as c
3. Set d = a_bwd(n) itself

With d = a_bwd(n): `hd_le_an` is `le_refl`. `hd_interval` follows from `ha_bwd`. The challenge is getting sigma and tau. Since d = a_bwd(n) is in [x',y'], we need backward strategies on [x', a_bwd(n)] and [a_bwd(n), y']. These come from restricting the forward strategy to these sub-intervals and applying the IH.

For c: play the forward strategy with a single selection a_bwd(n) from Spoiler. The strategy's response is some element in [x,y]. Take this as c. The winning condition gives rank_type agreement between c and a_bwd(n).

**This approach eliminates the infimum entirely.** The cost is that d = a_bwd(n) rather than the "optimal" split point from GHR93, but the proof structure is preserved: any selection below a_bwd(n) goes to sigma, any at or above goes to tau (and a_bwd(n) itself goes to tau since d <= a_bwd(n) is equality).

**Caveat**: In Case I, the split requires that some selection is strictly below d. With d = a_bwd(n), this means some a_bwd(i) < a_bwd(n). Whether this gives the right number of elements on each side (at most n) depends on having n+1 total elements with at least one on each side.

---

## 6. Summary

1. **No lattice instance exists** for `ExtendedCarrier`. Building one (~200+ lines) is possible but not recommended.

2. **Strategy restriction is the critical missing lemma**. It requires showing that a winning strategy on [x,y] restricts to [x,c] when c and d have matching rank types. Estimated 100-150 lines.

3. **The IH is applicable to sub-intervals** because the theorem universally quantifies endpoints. No structural refactoring needed.

4. **The infimum can be avoided** by setting d = a_bwd(n) (the last Spoiler selection) and c = the strategy's response. This simplifies the construction substantially.

5. **Total effort**: 330-480 lines for the full `obtain_split_point_props`. This is the keystone -- once it is closed, Cases I-IV become independent and can proceed in parallel.
