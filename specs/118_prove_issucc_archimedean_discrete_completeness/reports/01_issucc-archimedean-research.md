# Research Report: IsSuccArchimedean for Discrete Completeness (Task 118)

- **Task**: 118 - Prove IsSuccArchimedean for discrete completeness branch
- **Status**: Research complete
- **Type**: lean4
- **Date**: 2026-05-09
- **Session**: sess_1778363512_55d73f
- **Focus**: Systematic analysis of proof strategies for the remaining sorry at ChronicleToCountermodel.lean:554

## Executive Summary

After exhaustive Mathlib research, order-theoretic analysis, and review of 14+ prior research rounds (task 117), the following are the key findings:

1. **Mathlib equivalence**: `IsPredArchimedean <-> IsSuccArchimedean` in linear orders with `SuccOrder + PredOrder` (via `LinearOrder.isSuccArchimedean_iff_isPredArchimedean`). This means proving EITHER suffices.

2. **Mathlib's pigeonhole approach** (`LocallyFiniteOrder -> IsSuccArchimedean`): uses `Finite.exists_ne_map_eq_of_infinite` to find a collision `succ^[n] a = succ^[m] a`, deriving `IsMax (succ^[n] a)` via `isMax_iterate_succ_of_eq_of_ne`, contradicting `NoMaxOrder`. This approach requires `LocallyFiniteOrder` (finite intervals), which is EQUIVALENT to `IsSuccArchimedean`.

3. **All dom_N cardinality measures fail**: The fundamental obstacle is that `pred(b)` might not be in `dom_N`, causing the measure to not decrease. This is confirmed across 6 distinct measures (reports 07, 12).

4. **The problem reduces to the "gap lemma"**: For adjacent `p, q` in `dom_N`, prove `exists k, succ^[k] p = q`. This single result, combined with straightforward induction on `|dom_N cap (a, b]|`, yields full `IsSuccArchimedean`.

5. **The gap lemma requires omega chain structural analysis**: It does NOT follow from C0-C5 alone. Two disjoint succ-orbits are order-theoretically consistent with C0-C5 in the discrete case. The proof must exploit the omega chain's guard propagation mechanism.

6. **Most promising approach identified**: A new "guard-sealing induction" strategy, detailed in Section 5, that uses well-founded induction on the number of UNSEALED adjacent pairs in a finite-stage domain.

---

## 1. Mathlib Findings

### 1.1 Key Mathlib Lemmas

| Lemma | Location | Type Signature |
|-------|----------|---------------|
| `LinearOrder.isSuccArchimedean_iff_isPredArchimedean` | `Order.SuccPred.LinearLocallyFinite` | `IsSuccArchimedean iota <-> IsPredArchimedean iota` |
| `LinearOrder.isSuccArchimedean_of_isPredArchimedean` | same | `[IsPredArchimedean iota] -> IsSuccArchimedean iota` |
| `WellFoundedLT.toIsPredArchimedean` | `Order.SuccPred.Archimedean` | `[WellFoundedLT alpha] -> IsPredArchimedean alpha` |
| `WellFoundedGT.toIsSuccArchimedean` | same | `[WellFoundedGT alpha] -> IsSuccArchimedean alpha` |
| `isMax_iterate_succ_of_eq_of_ne` | `Order.SuccPred.Basic` | If `succ^[n] a = succ^[m] a` with `n != m`, then `IsMax (succ^[n] a)` |
| `Order.succ_pred` | same | `[NoMinOrder] -> succ (pred a) = a` |
| `Order.pred_succ` | same | `[NoMaxOrder] -> pred (succ a) = a` |
| `Order.covBy_succ` | same | `[NoMaxOrder] -> a covBy succ a` |
| `Order.pred_covBy` | same | `[NoMinOrder] -> pred a covBy a` |
| `LinearLocallyFiniteOrder.instIsSuccArchimedeanOfLocallyFiniteOrder` | `Order.SuccPred.LinearLocallyFinite` | `[LocallyFiniteOrder] [SuccOrder] -> IsSuccArchimedean` |
| `orderIsoIntOfLinearSuccPredArch` | same | `[IsSuccArchimedean] [NoMaxOrder] [NoMinOrder] [Nonempty] -> iota ≃o Int` |

### 1.2 Available Automatic Instances

Once `letI := limitDomSubtype_succOrder A h_mcs h_discrete` and `letI := limitDomSubtype_predOrder A h_mcs h_discrete` are set, Lean/Mathlib automatically provides:

- `Order.succ_pred a : Order.succ (Order.pred a) = a` (from `NoMinOrder`)
- `Order.pred_succ a : Order.pred (Order.succ a) = a` (from `NoMaxOrder`)
- `Order.lt_succ a : a < Order.succ a` (from `NoMaxOrder`)
- `Order.pred_lt a : Order.pred a < a` (from `NoMinOrder`)
- `Order.succ_le_iff : Order.succ a <= b <-> a < b`
- `Order.le_pred_iff : a <= Order.pred b <-> a < b`

These are all derived from the `SuccOrder/PredOrder` axioms plus `NoMaxOrder/NoMinOrder`. The manually proven `limitDomSubtype_succ_pred` and `limitDomSubtype_pred_lt` are subsumed.

### 1.3 IsPredArchimedean vs IsSuccArchimedean

The equivalence `isSuccArchimedean_iff_isPredArchimedean` means we can prove EITHER property. The `IsPredArchimedean` version (find `n` with `pred^[n] b = a`) might appear easier because the descent from `b` to `a` is more natural. However, the fundamental obstacle (the dom_N membership issue) affects both directions equally.

### 1.4 WellFoundedLT / WellFoundedGT

`WellFoundedLT.toIsPredArchimedean` provides `IsPredArchimedean` automatically from well-foundedness of `<`. For `LimitDomSubtype`, `<` is NOT well-founded globally (no minimum element). `WellFoundedGT` is also not available globally.

However, well-foundedness restricted to `{x | a <= x /\ x <= b}` would suffice. Proving this restricted well-foundedness is equivalent to proving interval finiteness, which is equivalent to `IsSuccArchimedean`.

---

## 2. Structural Analysis of the Problem

### 2.1 Orbit Decomposition

Define orbits of the `succ`-action on `LimitDomSubtype`:
- `orbit(x) = {succ^[n] x | n : Int}` (using `pred = succ^[-1]`)
- Orbits partition `LimitDomSubtype` into disjoint copies of Z

**`IsSuccArchimedean` is equivalent to the orbit decomposition having exactly ONE orbit.**

**Key fact**: Orbits are CONVEX. If `a, b` are in the same orbit with `a < c < b` and `c in limit_dom`, then `c` is in the same orbit. (Proof: `succ^[k] a = b` for some `k`. The elements `a, succ a, ..., succ^[k] a = b` have no limit_dom between consecutive pairs. So `c = succ^[j] a` for some `j`.)

### 2.2 Two-Orbit Consistency

Two disjoint orbits are CONSISTENT with C0-C5 in the discrete case:
- C0-C3: Standard MCS and guard properties hold within and across orbits
- C4: Counterexamples `not(U(xi, eta)) in f(x)` with `eta in f(y)` are resolved by witnesses in the same orbit as `x`
- C5: Witnesses for `U(xi, eta) in f(x)` can be in any orbit; only `U(T, bot)` forces the immediate successor (which is in the same orbit)

This means: **the proof CANNOT be purely order-theoretic**. It must use structural properties of the omega chain construction that go beyond the C0-C5 conditions.

### 2.3 What Makes the Omega Chain Single-Orbit

The omega chain starts with `dom_0 = {0}` (a single element). Every subsequent element is inserted between existing adjacent elements OR appended at the boundary. The key property: **every newly inserted element is connected to existing elements via the C5 guard propagation**.

Specifically, when element `z` is inserted between adjacent `(a, b)` at stage `n`:
- `g_n(a, z) supset g_{n-1}(a, b)` and `g_n(z, b) supset g_{n-1}(a, b)`
- The guard formulas propagate, creating connections between `z` and its neighbors

In the discrete case, the C5 resolution for `U(T, bot)` at each element `x` produces `succ(x)` with `bot in g(x, succ(x))`. This seals the interval `(x, succ(x))` forever. The accumulation of sealed intervals eventually covers the entire gap between any two dom_N-adjacent elements.

---

## 3. Failed Approaches (Confirmed from Prior Work)

### 3.1 Fixed dom_N Cardinality Measures

Six distinct measures were tried (report 12):
1. `|dom_N cap (a, b']|` with fixed N: Fails when `b' not in dom_N` (measure doesn't decrease)
2. Stage-based: Not monotone under pred
3. Rational distance: Not well-founded
4. Lexicographic: No suitable second component found
5. Fintype.card of interval: Circular (requires interval finiteness)
6. Dynamic N: Fails when `stage(pred(b')) > N` (measure can increase)

### 3.2 Real Analysis Approach

Bounded monotone sequences converge in R. The pred chain `pred^[n](b)` converges to some `L >= a.val`. The succ chain `succ^[n](a)` converges to some `L' <= b.val`. If `L` or `L'` is in `limit_dom`, contradiction from isolation. If NEITHER is in `limit_dom`: gap in the argument (cannot rule out from order theory alone). Requires omega chain structural argument.

### 3.3 Bypass Approach (Approach B)

Building the countermodel directly on `LimitDomSubtype` instead of `Int` eliminates the need for `IsSuccArchimedean`. However, the `valid` definition requires `[AddCommGroup D]`, which `LimitDomSubtype` does not have. Refactoring the semantic infrastructure is estimated at 200-500 lines across many files. This is a larger change than proving `IsSuccArchimedean`.

---

## 4. The Gap Lemma Reduction

### 4.1 Statement

**Gap Lemma**: For `p, q in dom_N` that are ADJACENT in `dom_N` (no `dom_N` elements between them), there exists `k` such that `succ^[k] <p, _> = <q, _>` in `LimitDomSubtype`.

### 4.2 Why It Suffices

Given the gap lemma, `IsSuccArchimedean` follows by strong induction on `|dom_N cap (a, b]|`:

```
-- Base (m = 0): a = b (since b in dom_N and a <= b)
-- Step (m >= 1):
--   Let c = smallest dom_N element in (a, b]
--   By IH on (a, c): exists j, succ^[j] a = c  (if a, c adjacent: gap lemma)
--                                                 (if not: split at next dom_N element)
--   Actually: restructure as follows:
--   Let c = largest dom_N element in [a, b) (= predecessor of b in dom_N)
--   |dom_N cap (a, c]| < m  (removed b from the set)
--   By IH: exists j, succ^[j] a = c
--   c and b are adjacent in dom_N
--   By gap lemma: exists k, succ^[k] c = b
--   Combine: succ^[j + k] a = b
```

Wait, this requires `c` and `b` to be adjacent in `dom_N`, which they ARE (c is the largest dom_N element strictly less than b).

But the IH application to `(a, c)` requires `c in dom_N` (yes, by construction) and `a in dom_N` (yes, given). And `|dom_N cap (a, c]| < |dom_N cap (a, b]|` (yes, we removed at least `b`). So the IH gives `exists j, succ^[j] a = c`.

Then the gap lemma gives `exists k, succ^[k] c = b`.

Combining: `succ^[j + k] a = b`.

**This structure works cleanly IF we have the gap lemma.**

### 4.3 Why the Gap Lemma is Hard

For adjacent `p < q` in `dom_N`:
- `limit_dom cap (p, q)` could contain 0, 1, or infinitely many elements
- Each element in `limit_dom cap (p, q)` has an immediate successor (discrete hypothesis)
- The succ chain from `p`: `p, succ(p), succ^2(p), ...` is strictly increasing and <= q
- If the chain reaches `q`: done
- If not: infinite increasing bounded sequence of rationals, which is consistent in Q

The gap lemma is equivalent to: `limit_dom cap [p, q]` is FINITE for adjacent dom_N elements `p, q`.

---

## 5. Recommended Proof Strategy: Guard-Sealing Induction

### 5.1 Key Insight

When the omega chain resolves `U(T, bot)` at a point `x`, it produces `succ(x)` with the property `bot in g(x, succ(x))`. This means: for ALL adjacent pairs `(a, b)` in `dom_{stage+1}` with `x <= a` and `b <= succ(x)`, `bot in g_{stage+1}(a, b)`. Since `bot` is never in any MCS, no future limit_dom elements can be inserted in the interval `(x, succ(x))`. We call this interval **sealed**.

### 5.2 The Sealing Process

Starting from adjacent `p, q` in `dom_N`:

1. At some stage `s_1 > N`, `U(T, bot)` at `p` is resolved. This seals `(p, succ(p))`.
   - `succ(p)` is now in `dom_{s_1 + 1}`
   - No future insertions in `(p, succ(p))`

2. At some stage `s_2 > s_1`, `U(T, bot)` at `succ(p)` is resolved. This seals `(succ(p), succ^2(p))`.
   - `succ^2(p)` is now in `dom_{s_2 + 1}`

3. Continue: at stage `s_k`, `(succ^{k-1}(p), succ^k(p))` is sealed.

The sealed intervals `(p, succ(p)), (succ(p), succ^2(p)), ...` are disjoint and cover `(p, succ^k(p))`. The total "sealed length" grows: `succ^k(p) > succ^{k-1}(p) > ... > p`. Each `succ^k(p) <= q`.

### 5.3 Why This Terminates

**Finite-stage argument**: At each stage `s_k`, the domain `dom_{s_k + 1}` has `succ^k(p)` as a new element. The domain also has `q` (from `dom_N`). The elements between `succ^k(p)` and `q` in `dom_{s_k + 1}` form a finite set. 

The key claim: **the number of dom_{s_k + 1} elements in `(succ^k(p), q]` is strictly less than the number of dom_{s_{k-1} + 1} elements in `(succ^{k-1}(p), q]`**.

Why? Because `succ^k(p) > succ^{k-1}(p)`, and:
- `dom_{s_k + 1} cap (succ^k(p), q] subset dom_{s_k + 1} cap (succ^{k-1}(p), q]`
- But `dom_{s_k + 1}` might have MORE elements than `dom_{s_{k-1} + 1}` (stages between `s_{k-1}` and `s_k` may have inserted points)

So the dom cardinality doesn't necessarily decrease. This is the same obstacle as before.

### 5.4 Revised Strategy: Use a SINGLE Fixed Stage

Fix `M` large enough that ALL the relevant C5 resolutions for `U(T, bot)` at `p` have occurred by stage `M`. Specifically:

Let `s` be the stage at which the C5 counterexample for `U(T, bot)` at `p` is FIRST processed after `p` is in the domain. At this stage, `succ(p)` is inserted and `(p, succ(p))` is sealed.

Now, `succ(p)` is in `dom_{s+1}`. The C5 counterexample for `U(T, bot)` at `succ(p)` will be processed at some later stage `s'`.

**The question is: can we bound the stages?**

No -- the stages can be arbitrarily large. Each C5 counterexample for `U(T, bot)` at a new point is processed at a stage determined by the enumeration, which can be arbitrarily late.

### 5.5 Alternative: Induction on Adjacent Pairs Containing succ^k(p)

At stage `s_k + 1`, `succ^k(p)` is in `dom_{s_k + 1}`, and `q` is in `dom_{s_k + 1}`. In `dom_{s_k + 1}`, `succ^k(p)` has some successor `r_k` (the next element in `dom_{s_k + 1}` after `succ^k(p)`). We have `succ^k(p) < r_k <= q`.

If `r_k = q`: then `succ^k(p)` and `q` are adjacent in `dom_{s_k + 1}`. The C5 resolution for `U(T, bot)` at `succ^k(p)` in `dom_{s_k + 1}` will produce `succ^{k+1}(p)` with `succ^k(p) < succ^{k+1}(p) <= r_k = q`. If `succ^{k+1}(p) = q`: done. If `succ^{k+1}(p) < q`: continue.

If `r_k < q`: then there's a dom element between `succ^k(p)` and `q`. This element was inserted between stages `N` and `s_k + 1`. It's NOT in the succ chain (since the succ chain only covers `(p, succ^k(p)]`). It's a dom element from some other counterexample resolution.

**Key observation**: In `dom_{s_k + 1}`, the number of elements in `(succ^k(p), q]` is:
```
|dom_{s_k + 1} cap (succ^k(p), q]| = |dom_{s_k + 1} cap (p, q]| - k
```
(approximately, since we removed the `k` sealed elements `succ(p), ..., succ^k(p)` from `(p, q]` but added them below `succ^k(p)$).

Wait, the sealed elements `succ(p), ..., succ^k(p)` are all in `(p, succ^k(p)]`, not in `(succ^k(p), q]`. The dom elements in `(succ^k(p), q]` are the dom elements that were NOT from the succ chain. So `|dom_{s_k+1} cap (succ^k(p), q]|` counts all dom elements in the "remaining gap" after `k` sealing steps.

These remaining gap elements include `q` itself (1 element) plus any elements inserted by other counterexample resolutions. The key question: does this count DECREASE as `k` increases?

Not necessarily, because new elements from other counterexamples can be inserted in `(succ^k(p), q]` at stages between `s_{k-1}+1` and `s_k+1`.

### 5.6 The Most Promising Complete Strategy

After extensive analysis, the most promising strategy that could yield a complete proof is:

**Prove by well-founded induction on `|dom_M cap [p, q]|` for a CAREFULLY CHOSEN `M`.**

The statement to prove:

```
forall M : Nat, forall p q : Rat,
  p in dom_M -> q in dom_M -> p < q ->
  (forall w, w in dom_M -> p < w -> w < q -> False) ->  -- adjacent in dom_M
  (forall x in limit_dom, next_top in limit_f x) ->     -- discrete hypothesis
  exists k, succ^[k] <p, _> = <q, _>
```

By strong induction on `|dom_M cap [p, q]| = 2` (since `p, q` are adjacent, only they are in `dom_M cap [p, q]`). Wait, if they're adjacent, `|dom_M cap [p, q]| = 2` always. This doesn't give a decreasing measure.

**Revised**: Induct on `|dom_M cap (p, q)|` = 0 (since adjacent). But then we need to handle `p, q` non-adjacent too. Let me generalize:

```
forall M : Nat, forall p q : Rat,
  p in dom_M -> q in dom_M -> p < q ->
  (forall x in limit_dom, next_top in limit_f x) ->
  exists k, succ^[k] <p, _> = <q, _>
```

By strong induction on `m = |dom_M cap (p, q)|`:

- **Base m = 0**: `p, q` adjacent in `dom_M`. The C5 resolution for `U(T, bot)` at `p` produces `succ(p)` at some stage `s >= M`. `succ(p) in dom_{s+1}` with `p < succ(p) <= q`.
  
  If `succ(p) = q`: done, `k = 1`.
  
  If `succ(p) < q`: `succ(p) in dom_{s+1}` and `q in dom_{s+1}`. Let `M' = s + 1`. `|dom_{M'} cap (succ(p), q)| < |dom_{M'} cap (p, q)|` because `(succ(p), q) subset (p, q)` and `succ(p)$ was removed from the interval.
  
  Wait, `|dom_{M'} cap (succ(p), q)|` involves `dom_{M'}$ which is LARGER than `dom_M$. So the count might increase.
  
  **This doesn't give a clean induction on a FIXED N.**

### 5.7 Conclusion: Novel Structural Lemma Required

The gap lemma cannot be proved using standard well-founded induction on Finset cardinality with a fixed stage `N`. The core issue is that `pred(b)` (or `succ(a)`) may be born at a later stage than `b` (or `a`), and changing the stage invalidates the measure.

The proof requires one of:
1. **A novel WF measure** that is invariant under stage changes (not yet discovered)
2. **A structural lemma about the omega chain** that directly bounds the number of insertions in any gap
3. **An architectural refactoring** to avoid needing `IsSuccArchimedean` entirely

---

## 6. Concrete Proof Sketch (Most Viable)

The following strategy has the best chance of success, though it requires proving a non-trivial structural lemma.

### 6.1 Strategy: Controlled Unfolding with Stage Tracking

**Structural Lemma (to prove)**: For any `x in limit_dom` with `U(T, bot) in limit_f(x)`:
Let `s` be the stage at which the C5 counterexample for `U(T, bot)` at `x` is resolved (i.e., the stage `n` such that `counterexample_enum (Nat.unpair n).2 = <x, 0, bot, top_formula, .c5_forward>` and `x in dom_n`). Then `succ(x) in dom_{s+1}` and `succ(x)` is the C5 witness.

This is essentially what `limit_dom_has_succ` already proves, but we need to TRACK THE STAGE.

**Modified gap lemma proof**: For adjacent `p, q in dom_N`:

1. Let `s_0 >= N` be the stage where `U(T, bot)` at `p` is resolved. `succ(p) in dom_{s_0 + 1}`.
2. If `succ(p) = q`: done.
3. If `succ(p) < q`: let `s_1 >= s_0 + 1` be the stage where `U(T, bot)` at `succ(p)` is resolved. `succ^2(p) in dom_{s_1 + 1}`.
4. Continue until `succ^k(p) = q` or `succ^k(p) < q`.

**Termination**: By `omega_chain_dom_new_unique`, each `succ^i(p)` for `i >= 1` is a NEW element (not previously in the domain at its birth stage). The birth stages `s_0, s_1, s_2, ...` are all distinct natural numbers with `s_0 < s_1 < s_2 < ...` (since each resolution happens at a stage after the previous one's element was born).

Wait, is `s_0 < s_1` guaranteed? `s_1` is the stage where `U(T, bot)` at `succ(p)` is resolved. `succ(p) in dom_{s_0 + 1}`, so `s_1 >= s_0 + 1 > s_0`. Yes, strictly increasing.

Now, each `succ^i(p)` is in `dom_{s_{i-1} + 1}`. And `succ^i(p) < q`. In `dom_{s_{i-1} + 1}`, the elements in `[p, q]` include at least `p, succ(p), ..., succ^i(p), q`, giving at least `i + 2` elements.

But `|dom_{s_{i-1} + 1} cap [p, q]|` can be at most `|dom_{s_{i-1} + 1}|`, which is at most `|dom_0| + s_{i-1} + 1`. And `s_{i-1} >= s_0 + (i - 1) >= N + i`. So `|dom_{s_{i-1} + 1}| <= |dom_0| + N + i + 1`.

We need `i + 2 <= |dom_{s_{i-1} + 1} cap [p, q]| <= |dom_{s_{i-1} + 1}|`, which is always satisfied. No contradiction.

**The issue**: The domain grows as fast as the succ chain, so we can't get a contradiction from cardinality alone.

### 6.2 Alternative Strategy: Direct Finset Induction with Stage Lifting

This approach lifts `pred(b)` into a dom_N by increasing N, but carefully tracks what changes.

**Key Lemma to Prove**: `pred(b).val in dom_{M}` for `M = max(N, first_stage(pred(b)))`.

**Modified Induction**: Prove `exists k, pred^[k] b = a` by well-founded induction on `(M, |dom_M cap [a.val, b.val]|)` with lexicographic order, where `M = max(first_stage_of_all_elements_in_the_pred_chain)`.

The issue: `M` depends on the entire pred chain, which is what we're trying to construct.

### 6.3 Most Practical Recommendation

Given the depth of analysis (14+ research rounds across tasks 117-118), the most practical path forward is:

**Option A: Accept the sorry with detailed documentation** (0 lines, immediate)
- The sorry is mathematically sound (Burgess's construction produces a connected domain)
- It affects only `discrete_iso`, used only in `discrete_fmcs`
- The rest of completeness proceeds independently

**Option B: Prove the gap lemma via stage-tracking induction** (~100-150 lines, high risk)
- Requires formalizing the stage-tracking structural lemma
- Must handle the interaction between C5 resolution stages and domain growth
- The proof sketch is in Section 6.1 but termination argument has a gap

**Option C: Architectural refactoring to bypass IsSuccArchimedean** (~200-500 lines, medium risk)
- Remove `AddCommGroup D` constraint from `valid`
- Build countermodel on `LimitDomSubtype` directly
- Major change to `TaskFrame`, `ShiftClosed`, `truth_at`

**Recommendation: Option A with a follow-up task for Option C.** The sorry is isolated and does not block other completeness work. A future task can pursue the architectural refactoring (Option C) which is a cleaner solution than proving `IsSuccArchimedean` from the omega chain.

---

## 7. Viability Assessment

| Approach | Viability | Effort | Risk |
|----------|-----------|--------|------|
| dom_N cardinality (fixed N) | FAILED | - | - |
| dom_N cardinality (dynamic N) | FAILED | - | - |
| Real analysis convergence | Partial (gap when limits not in limit_dom) | 100+ lines | High |
| WellFoundedLT on interval | Circular (requires interval finiteness) | - | - |
| Pigeonhole (LocallyFiniteOrder) | Circular (requires interval finiteness) | - | - |
| Guard-sealing induction | Promising but termination gap | 100-150 lines | High |
| Bypass via LimitDomSubtype carrier | Requires architectural refactoring | 200-500 lines | Medium |
| Accept sorry | Immediate | 0 lines | None |

---

## 8. Mathematical Question Resolution

### Q1: In a countable linear order with SuccOrder, PredOrder, NoMaxOrder, NoMinOrder, and succ(pred(x)) = x, is IsSuccArchimedean automatic?

**Answer: NO.** Counterexample: Consider `Z x Z` with lexicographic order, restricted to elements `(0, n)` and `(1, n)` for all `n in Z`. This has two "columns" (orbits), each isomorphic to Z. Every element has an immediate successor and predecessor. succ(pred(x)) = x. But `succ^[n] (0, 0)` never equals `(1, 0)`.

A simpler counterexample in Q: take `S = {-1/2^n | n >= 0} union {1/2^n | n >= 0}`. Define succ by: on the negative side, `succ(-1/2^n) = -1/2^{n+1}`; and `succ(1/2^{n+1}) = 1/2^n`. This gives two orbits converging to 0 from each side, with succ(pred(x)) = x, but no succ-iterate of any negative element reaches any positive element.

### Q2: Does IsPredArchimedean imply IsSuccArchimedean?

**Answer: YES**, in linear orders with both SuccOrder and PredOrder. This is `LinearOrder.isSuccArchimedean_iff_isPredArchimedean`.

### Q3: Can we prove IsPredArchimedean more easily?

**Answer: NO**, the same fundamental obstacle applies. The pred chain `pred^[n](b)` converges toward `a` but might never reach it if `a` and `b` are in different orbits. Proving the pred chain terminates IS proving IsPredArchimedean.

### Q4: Does the omega chain construction guarantee a single orbit?

**Answer: YES** (mathematically, by Burgess 1982), but the formal proof requires tracking the guard propagation mechanism through the omega chain stages. This is non-trivial to formalize.

### Q5: What is the correct WF measure?

**Answer: Unknown.** No single natural number measure has been found that decreases at every step of the pred (or succ) descent while remaining well-defined. The dom_N cardinality measure fails when intermediate elements are not in dom_N. A multi-stage measure (dynamic N) fails because increasing N can increase the cardinality. The problem remains open.

---

## Appendix A: Lean Code for IsPredArchimedean Approach

If IsPredArchimedean could be proved, the conversion to IsSuccArchimedean is automatic:

```lean
noncomputable def limitDomSubtype_isSuccArchimedean (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : forall x in limit_dom A h_mcs, next_top in limit_f A h_mcs x) :
    @IsSuccArchimedean (LimitDomSubtype A h_mcs) _ (limitDomSubtype_succOrder A h_mcs h_discrete) := by
  letI := limitDomSubtype_succOrder A h_mcs h_discrete
  letI := limitDomSubtype_predOrder A h_mcs h_discrete
  -- Use the equivalence: IsPredArchimedean -> IsSuccArchimedean (in linear orders)
  exact LinearOrder.isSuccArchimedean_of_isPredArchimedean
  -- This requires: IsPredArchimedean (LimitDomSubtype A h_mcs)
  -- Which is not yet available
```

## Appendix B: Prior Research Index

| Report | Key Finding | Status |
|--------|-------------|--------|
| 07 | Two approaches (bypass vs two-phase). Gap lemma identified. | Approach B has gap |
| 08 | AddCommGroup constraint analysis | Bypass requires refactoring |
| 09 | Team research on cascade/discrete | Cascade depth = 1 |
| 10 | Z-shift equivalent to Burgess | Relocates, doesn't solve |
| 11 | Total insertions can be infinite | Gap between orbits possible in abstract |
| 12 | All 6 WF measures fail | Real analysis has gap |
| 06-handoff | Omega chain structural NO-GO | No simple combinatorial bound |
| 118/01 (this) | IsPredArchimedean equivalence, guard-sealing analysis | Gap lemma remains open |
