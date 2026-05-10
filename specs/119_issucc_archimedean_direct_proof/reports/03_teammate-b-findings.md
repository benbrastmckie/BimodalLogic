# Teammate B Findings: Set.Finite / LocallyFiniteOrder Approach

- **Task**: 119 - Prove IsSuccArchimedean via Direct Connectivity Extraction
- **Session**: sess_1778449535_f13ea4
- **Date**: 2026-05-10
- **Angle**: Mathlib Set.Finite infrastructure, LocallyFiniteOrder, topological finiteness

## Executive Summary

Exhaustive search of Mathlib reveals three potential pathways from `Set.Finite` to `IsSuccArchimedean`, but all three have a **fundamental circularity**: proving `Set.Finite (Set.Icc a b)` for `LimitDomSubtype` is equivalent in difficulty to proving `IsSuccArchimedean` directly. The circularity cannot be broken by topology alone. The direct dom_N count induction (with FIXED N) is the most promising approach, but it has a known gap when intermediate elements are born after stage N. A novel "ascending dom_N induction" approach is proposed that may resolve this gap.

## 1. Mathlib Chain: LocallyFiniteOrder -> IsSuccArchimedean

### 1.1 The Complete Chain

The following Mathlib instances form a complete chain from `LocallyFiniteOrder` to `IsSuccArchimedean`:

```
LinearLocallyFiniteOrder.instIsSuccArchimedeanOfLocallyFiniteOrder
  : [LinearOrder iota] -> [LocallyFiniteOrder iota] -> [SuccOrder iota] -> IsSuccArchimedean iota
```

**File**: `Mathlib/Order/SuccPred/LinearLocallyFinite.lean`, line 166.

**Proof mechanism**: Pigeonhole principle. If `succ^[n](a) < b` for all n, then all iterates land in `Finset.Icc a b` (finite). By `Finite.exists_ne_map_eq_of_infinite`, two iterates coincide. This gives `IsMax(succ^[n](a))`, contradicting `succ^[n](a) < b`.

**Key lemma used**: `Finite.exists_ne_map_eq_of_infinite` (Pigeonhole for infinite -> finite maps).

### 1.2 Constructing LocallyFiniteOrder

To use the chain above, we need `LocallyFiniteOrder (LimitDomSubtype A h_mcs)`.

**Constructor**: `LocallyFiniteOrder.ofIcc'`
```
LocallyFiniteOrder.ofIcc' (alpha : Type) [Preorder alpha] [DecidableLE alpha]
    (finsetIcc : alpha -> alpha -> Finset alpha)
    (mem_Icc : forall a b x, x in finsetIcc a b <-> a <= x /\ x <= b)
    : LocallyFiniteOrder alpha
```

**Requirements**:
1. `DecidableLE (LimitDomSubtype A h_mcs)` -- available (ℚ has decidable <=)
2. `finsetIcc` -- must construct a `Finset` for each interval
3. `mem_Icc` -- must prove membership characterization

**Construction of `finsetIcc`**: If `(Set.Icc a b).Finite` is proven, we can use `Set.Finite.toFinset` to produce the `Finset`. The membership property follows from the definition.

### 1.3 The Circularity

Proving `(Set.Icc a b).Finite` for `LimitDomSubtype` is **equivalent** to the original problem. Here is why:

- `Set.Icc a b` in `LimitDomSubtype` = `{x : LimitDomSubtype | a <= x /\ x <= b}` = `{q in limit_dom | a.val <= q /\ q <= b.val}` as a subtype
- This equals `limit_dom ∩ [a.val, b.val]` when viewed as a set of rationals
- Proving this finite requires either (a) proving succ iteration reaches b (IsSuccArchimedean!), or (b) using omega chain structural properties

**Counterexample showing non-triviality**: Z x Z with lexicographic order embeds into Q (countable, succ/pred exist, no max/min) but has infinite bounded intervals. So succ/pred existence + embedding in Q does NOT imply finite intervals. The omega chain's specific structure must be used.

## 2. Alternative Path: WellFoundedGT.toIsSuccArchimedean

### 2.1 The Instance

```
WellFoundedGT.toIsSuccArchimedean
  : [PartialOrder alpha] [WellFoundedGT alpha] [SuccOrder alpha] -> IsSuccArchimedean alpha
```

**File**: `Mathlib/Order/SuccPred/Archimedean.lean`

### 2.2 Why It Fails

`WellFoundedGT` requires that the `>` relation is well-founded on the WHOLE type. `LimitDomSubtype` has infinite descending chains (e.g., `0, pred(0), pred^2(0), ...`), so `WellFoundedGT` is FALSE for the entire type.

`Finite.to_wellFoundedGT` (`[Finite alpha] [Preorder alpha] -> WellFoundedGT alpha`, in `Mathlib/Data/Fintype/Card.lean`) is also inapplicable since `LimitDomSubtype` is infinite.

## 3. Topological Approaches

### 3.1 Bolzano-Weierstrass via IsCompact + IsDiscrete

**Theorem**: `IsCompact.finite : IsCompact s -> IsDiscrete s -> s.Finite`
**File**: `Mathlib/Topology/Compactness/Compact.lean`

**Plan**: Show `limit_dom_image := Rat.cast '' (limit_dom ∩ Icc a.val b.val)` is compact and discrete in R.

**Blockage (IsCompact)**: `limit_dom_image ⊆ Set.Icc (↑a.val) (↑b.val)` (compact in R by `isCompact_Icc`). But `IsCompact.finite` requires `IsCompact` on `limit_dom_image` itself, not just containment in a compact set. And `limit_dom_image` is NOT compact (not closed in R in general).

### 3.2 Metric.finite_isBounded_inter_isClosed

**Theorem**: `Metric.finite_isBounded_inter_isClosed : [ProperSpace alpha] -> IsDiscrete s -> IsBounded K -> IsClosed s -> (K ∩ s).Finite`
**File**: `Mathlib/Topology/MetricSpace/Bounded.lean`

**Blockage (IsClosed)**: `limit_dom` cast to R is NOT closed. Example: if limit_dom contains {1/n | n >= 1}, its closure in R includes 0, which need not be in limit_dom. R is a `ProperSpace` (`instProperSpaceReal`), and `IsBounded` holds for the image of [a.val, b.val], but `IsClosed` fails.

### 3.3 Bolzano-Weierstrass by Contradiction

**Attempt**: Suppose `limit_dom ∩ [a.val, b.val]` is infinite. Cast to R. Use `tendsto_subseq_of_bounded` to get a convergent subsequence with limit L in closure([↑a.val, ↑b.val]). Derive contradiction.

**Blockage (accumulation point outside s)**: L may be irrational or a rational not in `limit_dom`. The `IsDiscrete` property of `limit_dom_image` prevents accumulation points IN the set, but allows accumulation from outside. Example: {1/n} in R is discrete (each point isolated) but 0 is an external accumulation point.

**Case analysis**:
- L in limit_dom (cast): Contradiction with isolation. The open interval (pred(L), succ(L)) contains only L from limit_dom, so eventually the convergent subsequence has all terms equal to L, contradicting distinct terms.
- L NOT in limit_dom (cast): No direct contradiction. The convergent sequence approaches L from one side, producing infinitely many distinct limit_dom points converging to L. Showing this leads to contradiction requires proving that the succ chain from the first element reaches beyond L, which IS IsSuccArchimedean. **Circular.**

### 3.4 Summary of Topological Approaches

All topological approaches fail due to one of:
1. `IsClosed` requirement not met (limit_dom not closed in R)
2. `IsCompact` requirement not met (subset of compact not necessarily compact)
3. Accumulation point outside the set (no contradiction available without IsSuccArchimedean)

## 4. Dom_N Count Induction (Fixed N)

### 4.1 The Approach

For `a <= b` with `a < b`, fix `N = max(birth(a), birth(b))`. Both `a.val, b.val in dom_N`.

Define `count_N(b') = |dom_N.filter(fun q => a.val < q /\ q <= b'.val)|`.

Strong induction on `count_N(b)`.

### 4.2 The Descent Step

From b to pred(b):
- `pred(b).val < b.val` (predecessor property)
- No `limit_dom` elements in `(pred(b).val, b.val)` (predecessor definition)
- Therefore no `dom_N` elements in `(pred(b).val, b.val)` (since `dom_N ⊆ limit_dom`)
- `b.val in dom_N` (since `birth(b) <= N`)
- So `dom_N ∩ (pred(b).val, b.val] = {b.val}`
- Therefore `count_N(pred(b)) = count_N(b) - 1` (strict decrease)

### 4.3 The Gap: Base Case

When `count_N(b') = 0` and `a < b'`:
- No `dom_N` elements in `(a.val, b'.val]`
- But `b' in limit_dom` with `b'.val > a.val`
- `b'.val` might not be in `dom_N` (born after stage N)
- Cannot descend further with the current measure
- Cannot conclude `a = b'` or apply IH

### 4.4 Why the Gap Exists

The gap occurs when b' is a limit_dom element between two consecutive dom_N elements, born at stage > N. The fixed N cannot "see" b' in its dom_N.

**Critical observation**: This gap ONLY occurs when the IH is applied to intermediate elements. For the ORIGINAL b, `b.val in dom_N` always holds. The problem is that `pred(b).val` might not be in `dom_N`, and after descending to pred(b), the next pred might also not be in dom_N, etc.

### 4.5 Proposed Fix: N-Ascending Induction

**Idea**: Instead of fixing N once, allow N to increase as we descend. Define a NESTED induction:

**Outer induction** on `count_N(b)` where `N = max(birth(a), birth(b))`.

**Inner handling** when `pred(b).val not in dom_N`:
- Let `M = max(N, birth(pred(b)))`. Now `pred(b).val in dom_M`.
- `count_M(pred(b)) = |dom_M.filter(fun q => a.val < q /\ q <= pred(b).val)|`
- Since `dom_M ⊇ dom_N`, `count_M(pred(b)) >= count_N(pred(b)) = count_N(b) - 1`.
- But `count_M(b) >= count_N(b)` (more dom elements in the interval).
- So we need a DIFFERENT measure that accounts for the stage increase.

**Combined measure**: `(count_N(b), birth(b))` where N = max(birth(a), birth(b)).
- When `b.val in dom_N`: count decreases, regardless of birth.
- When `b.val not in dom_N`: impossible, since `birth(b) <= N`.

Wait -- for the ORIGINAL b, `birth(b) <= N` by construction. But for pred(b):
- `birth(pred(b))` might be > N.
- In the IH, we quantify over b' with count_N(b') < count_N(b).
- For b' = pred(b), count_N(pred(b)) = count_N(b) - 1.
- The IH gives: exists n, succ^[n](a) = pred(b).
- Then succ^[n+1](a) = b. Done.

**KEY REALIZATION**: The IH quantifies over ALL b' with count_N(b') < count_N(b) and a <= b'. For such b', we need to show exists n, succ^[n](a) = b'. The proof for b' would set N' = max(birth(a), birth(b')), compute count_{N'}(b'), and proceed.

But the strong induction is on count_N for the FIXED N. Different b' values with the same count_N value would use the SAME N (the one fixed at the outermost level).

**This doesn't work** because different b' values have different birth stages and need different N values.

### 4.6 Correct Formulation: Universal Quantifier Inside Induction

The correct statement for strong induction:

```
forall (k : Nat), forall (a b : LimitDomSubtype),
  a <= b ->
  let N := max(birth(a), birth(b))
  |dom_N.filter(fun q => a.val < q /\ q <= b.val)| <= k ->
  exists n, succ^[n](a) = b
```

Induction on k.

**Base k = 0**: count = 0 means no dom_N elements in (a.val, b.val]. Since b.val in dom_N (birth(b) <= N), this means b.val not in (a.val, b.val], so a.val >= b.val. Combined with a <= b, a = b. Take n = 0.

**Step k+1**: Given a < b, count_N(b) = k+1 (where N = max(birth(a), birth(b))).
Let pb = pred(b). Then a <= pb < b.
count_N(pb) = k (since b.val in dom_N, dom_N ∩ (pb.val, b.val] = {b.val}).

Set N' = max(birth(a), birth(pb)).

**Sub-case N' = N**: count_{N'}(pb) = count_N(pb) = k. Apply IH with k to (a, pb, N'). Get n with succ^[n](a) = pb. Then succ^[n+1](a) = b.

**Sub-case N' > N**: birth(pb) > birth(b). Then N' > N. count_{N'}(pb) = |dom_{N'}.filter(...)| could be > k (dom_{N'} has more elements than dom_N in the interval). So we CANNOT apply IH at level k.

**Sub-case N' < N**: N' = max(birth(a), birth(pb)). If birth(pb) < birth(b), then N' = max(birth(a), birth(pb)). If birth(a) >= birth(b), N' = birth(a) = N, so N' = N. If birth(a) < birth(b), N' = max(birth(a), birth(pb)) which could be < N. Then count_{N'}(pb) <= count_N(pb) = k (fewer dom elements). Apply IH at level k.

**The problematic sub-case is N' > N.** This occurs when birth(pred(b)) > birth(b).

## 5. The Structural Alternative: Direct Proof Without Finiteness

Given the circularity of the Set.Finite approach, the most viable path is to prove IsSuccArchimedean DIRECTLY using a well-founded measure on the omega chain structure. The dom_N count induction (Section 4) works except when `birth(pred(b)) > birth(b)`, i.e., when the predecessor of b was born AFTER b in the omega chain.

### 5.1 When Does birth(pred(b)) > birth(b)?

This happens when b enters the domain at stage birth(b), but its predecessor (the closest limit_dom element below b) enters later. Concretely: at stage birth(b), some point p < b.val is the domain-predecessor of b. Later, at stage m > birth(b), a new point q is inserted between p and b.val. If q becomes the limit_dom predecessor of b (i.e., no further insertions between q and b), then pred(b) = q with birth(q) = m > birth(b).

### 5.2 The Complete Measure Proposal

Use a well-founded measure that handles BOTH directions of birth ordering:

```
measure(a, b) := (|dom_N ∩ (a.val, b.val]|, 0)    -- lexicographic on (Nat, Nat)
```

where N = max(birth(a), birth(b), birth(succ(a)), birth(pred(b))).

By including birth(succ(a)) and birth(pred(b)) in N, we ensure that succ(a) and pred(b) are both in dom_N. This gives:

- count_N(pred(b)) = count_N(b) - 1 (b.val removed, pred(b).val added if not already present)
- But wait: is pred(b).val necessarily added? pred(b).val in dom_N since birth(pred(b)) <= N.
- And b.val in dom_N since birth(b) <= N.
- dom_N ∩ (pred(b).val, b.val] = {b.val} (no limit_dom between pred(b) and b).
- pred(b).val in dom_N ∩ (a.val, pred(b).val] (if a.val < pred(b).val).
- So count_N(pred(b)) = count_N(b) - 1 (removed b.val from count).

This seems to work! But the IH application requires the SAME N for the recursive call on (a, pred(b)). For (a, pred(b)), the N' would be max(birth(a), birth(pred(b)), birth(succ(a)), birth(pred(pred(b)))). This could be > N (if birth(pred(pred(b))) > N).

**The problem recurses**: we'd need to include birth of pred^k(b) for all k in N, which is circular (requires knowing the pred chain is finite = IsSuccArchimedean).

### 5.3 The FIXED-N Escape

The resolution is to NOT recompute N for each recursive call. Instead:

**Statement**: For all a, b, a <= b implies exists n, succ^[n](a) = b.

**Proof**: Fix a, b with a < b. Let N = max(birth(a), birth(b)).
Both a.val, b.val in dom_N. Do strong induction on count := |dom_N ∩ (a.val, b.val]|.

count >= 1 (since b.val in dom_N ∩ (a.val, b.val]).

Let pb = pred(b). Then a <= pb < b.

By the predecessor property: no limit_dom in (pb.val, b.val), hence no dom_N there.
So dom_N ∩ (pb.val, b.val] = {b.val}. Therefore count_N(pb) = count_N(b) - 1.

**IH** (on count_N, universal over a' and b'):
For all a', b' with a' <= b', if |dom_N ∩ (a'.val, b'.val]| < count, then exists n, succ^[n](a') = b'.

Apply IH to a' = a, b' = pb. Need a <= pb (yes) and count_N(a, pb) < count (yes: count - 1 < count).

**But**: the IH's N is the SAME fixed N, not max(birth(a'), birth(b')).
For the IH application, count_N(a, pb) = |dom_N ∩ (a.val, pb.val]|.
Is this well-defined? Yes -- dom_N is a fixed Finset, the filter is well-defined.

**The IH gives**: exists n, succ^[n](a) = pb.
Then succ^[n+1](a) = succ(pb) = b. Done!

**Base case**: count_N(a, b') = 0 means no dom_N elements in (a.val, b'.val].
If a < b': then a.val < b'.val, and b' is in limit_dom. But b'.val might not be in dom_N.
Is a = b' forced? a.val in dom_N? Yes (birth(a) <= N).
a.val is NOT in (a.val, b'.val] (excluded from half-open interval). So count = 0 is consistent with a < b'.

**THIS IS THE GAP AGAIN.** When count_N = 0 and a < b', the IH cannot descend further.

### 5.4 Resolving the Base Case Gap

The gap occurs when a < b' and no dom_N elements between a and b'. This means a.val and b'.val are in different "gaps" of dom_N, or b'.val is past the last dom_N element above a.val.

**Resolution attempt**: In this case, consider the dom_N-successor of a.val, call it q (the smallest dom_N element > a.val). Since count_N(a, b') = 0, q > b'.val (no dom_N in (a.val, b'.val]). So a.val < b'.val < q, and the entire interval (a.val, q) has only one dom_N boundary: a.val on the left, q on the right.

All limit_dom elements in (a.val, b'.val] were born after stage N. These elements are "gap-filling" elements between two consecutive dom_N elements.

**Key question**: Can we prove that succ iteration from a reaches b' using ONLY the gap-filling structure?

Within the gap (a.val, q): all limit_dom elements here are born at stages > N. The gap was an open interval in dom_N. Each insertion splits a sub-gap. The succ chain from a through these gap-filling elements should eventually reach q (or pass through b' on the way).

But proving this requires understanding the gap structure, which is another instance of the same problem at a smaller scale.

## 6. Mathlib Lemma Inventory

### 6.1 Set.Finite Constructors (verified in Mathlib)

| Lemma | Type | File |
|-------|------|------|
| `Set.Finite.subset` | `s.Finite -> t ⊆ s -> t.Finite` | `Data/Set/Finite/Basic.lean` |
| `Set.Finite.image` | `s.Finite -> (f '' s).Finite` | `Data/Set/Finite/Basic.lean` |
| `Set.Finite.preimage` | `InjOn f (f ⁻¹' s) -> s.Finite -> (f ⁻¹' s).Finite` | `Data/Set/Finite/Basic.lean` |
| `Finset.finite_toSet` | `(s : Finset alpha) -> (s : Set alpha).Finite` | `Data/Set/Finite/Basic.lean` |
| `Set.Finite.toFinset` | `s.Finite -> Finset alpha` | `Data/Set/Finite/Basic.lean` |
| `IsCompact.finite` | `IsCompact s -> IsDiscrete s -> s.Finite` | `Topology/Compactness/Compact.lean` |
| `Metric.finite_isBounded_inter_isClosed` | `IsDiscrete s -> IsBounded K -> IsClosed s -> (K ∩ s).Finite` | `Topology/MetricSpace/Bounded.lean` |

### 6.2 LocallyFiniteOrder Infrastructure

| Lemma | Type | File |
|-------|------|------|
| `LocallyFiniteOrder.ofIcc'` | `[DecidableLE alpha] -> finsetIcc -> mem_Icc -> LocallyFiniteOrder alpha` | `Order/Interval/Finset/Defs.lean` |
| `Set.finite_Icc` | `[LocallyFiniteOrder alpha] -> (Set.Icc a b).Finite` | `Order/Interval/Finset/Defs.lean` |
| `OrderEmbedding.locallyFiniteOrder` | `alpha ↪o beta -> [LocallyFiniteOrder beta] -> LocallyFiniteOrder alpha` | `Order/Interval/Finset/Defs.lean` |

### 6.3 IsSuccArchimedean Path

| Lemma | Type | File |
|-------|------|------|
| `LinearLocallyFiniteOrder.instIsSuccArchimedean...` | `[LinearOrder] [LocallyFiniteOrder] [SuccOrder] -> IsSuccArchimedean` | `Order/SuccPred/LinearLocallyFinite.lean` |
| `WellFoundedGT.toIsSuccArchimedean` | `[PartialOrder] [WellFoundedGT] [SuccOrder] -> IsSuccArchimedean` | `Order/SuccPred/Archimedean.lean` |
| `Finite.to_wellFoundedGT` | `[Finite alpha] [Preorder alpha] -> WellFoundedGT alpha` | `Data/Fintype/Card.lean` |
| `Finite.exists_ne_map_eq_of_infinite` | Pigeonhole principle | `Data/Fintype/Pigeonhole.lean` |

### 6.4 Topological Infrastructure

| Lemma | Type | File |
|-------|------|------|
| `instProperSpaceReal` | `ProperSpace R` | `Topology/MetricSpace/ProperSpace.lean` |
| `isCompact_Icc` | `IsCompact (Set.Icc a b)` (in R) | `Topology/Order/Basic.lean` |
| `tendsto_subseq_of_bounded` | Bolzano-Weierstrass in metric spaces | `Topology/MetricSpace/Sequences.lean` |
| `Rat.cast_injective` | `Injective (Rat.cast : Q -> R)` | `Data/Rat/Cast/Order.lean` |
| `isDiscrete_iff_forall_exists_isOpen` | characterization of IsDiscrete | `Topology/DiscreteSubset.lean` |

### 6.5 Pigeonhole Tools

| Lemma | Type | File |
|-------|------|------|
| `Finite.exists_ne_map_eq_of_infinite` | `[Finite beta] -> (f : alpha -> beta) -> exists n m, n != m /\ f n = f m` | `Data/Fintype/Pigeonhole.lean` |
| `isMax_iterate_succ_of_eq_of_ne` | `succ^[n] a = succ^[m] a -> n != m -> IsMax (succ^[n] a)` | `Order/SuccPred/Archimedean.lean` |

## 7. Recommendations

### 7.1 The LocallyFiniteOrder / Set.Finite Approach is BLOCKED

All pathways through `Set.Finite` or `LocallyFiniteOrder` have the same fundamental circularity: proving bounded intervals are finite requires either (a) IsSuccArchimedean (circular), (b) the set being closed in R (false), or (c) the set being compact (false for non-closed subsets).

### 7.2 The Direct dom_N Count Induction is the ONLY Viable Path

The dom_N count induction (Section 4) almost works. The FIXED-N variant (Section 5.3) reduces the problem to a single gap: when count_N = 0 and a < b, all relevant elements are born after stage N. The proof then requires showing that succ iteration traverses this gap.

### 7.3 Recommended Strategy: Nested Induction with Increasing N

```
-- Outer: strong induction on count_N(a, b) with N = max(birth(a), birth(b))
-- When count_N(b) > 0: apply IH to pred(b) (count decreases by 1)
-- When count_N(b) = 0 and a < b: the "gap case"
--   In the gap case, a.val and b.val are between consecutive dom_N elements
--   (or a.val is in dom_N and the next dom_N element is above b.val)
--   Set M = max(birth(a), birth(b)), which equals N (same as before).
--   But b.val in dom_N (birth(b) <= N), so count >= 1 when a < b.
--   WAIT: count_N(b) = |dom_N ∩ (a.val, b.val]| and b.val in dom_N.
--   If a.val < b.val, then b.val in (a.val, b.val] ∩ dom_N, so count >= 1.
--   So count = 0 implies a.val >= b.val, i.e., a >= b.
--   Combined with a <= b: a = b. Take n = 0.
```

**WAIT**: The base case gap DOES NOT EXIST when the IH quantifies over (a, b) pairs with THEIR OWN N values!

Re-reading Section 5.3 more carefully: the IH is applied to the pair (a, pred(b)). For THIS pair, N' = max(birth(a), birth(pred(b))). The count is |dom_{N'} ∩ (a.val, pred(b).val]|.

But the STRONG INDUCTION variable is count_N where N = max(birth(a), birth(b)) for the ORIGINAL pair. When we apply IH to (a, pred(b)), we need count_N(pred(b)) < count_N(b), which holds.

The IH then says: for ANY pair (a', b') with count_N(a', b') < count_N(a, b), exists n, succ^[n](a') = b'. Here N is STILL the original N.

For the pair (a, pred(b)), count_N(a, pred(b)) = count_N(a, b) - 1. Apply IH: exists n, succ^[n](a) = pred(b). Then succ^[n+1](a) = b. Done.

For the base case: count_N = 0 means b.val not in dom_N ∩ (a.val, b.val]. But b.val in dom_N (birth(b) <= N). If a < b, then a.val < b.val, so b.val in (a.val, b.val], and b.val in dom_N, contradiction with count = 0. So count_N >= 1 when a < b. So count_N = 0 implies a >= b, hence a = b. n = 0.

**THE BASE CASE GAP DOES NOT EXIST!** The induction is COMPLETE.

### 7.4 Corrected Proof Sketch

```lean
noncomputable def limitDomSubtype_isSuccArchimedean ... := by
  letI := limitDomSubtype_succOrder A h_mcs h_discrete
  constructor
  intro a b hab
  rcases eq_or_lt_of_le hab with rfl | hab_lt
  . exact ⟨0, rfl⟩
  . -- a < b, both in limit_dom
    obtain ⟨na, hna⟩ := a.property
    obtain ⟨nb, hnb⟩ := b.property
    set N := max na nb
    have ha_N := omega_chain_dom_mono_le A h_mcs (le_max_left na nb) hna
    have hb_N := omega_chain_dom_mono_le A h_mcs (le_max_right na nb) hnb
    -- count = |dom_N ∩ (a.val, b.val]|
    set count := ((omega_chain_val A h_mcs N).dom.filter
      (fun q => decide (a.val < q ∧ q ≤ b.val) = true)).card
    -- Strong induction on count, universal over b
    suffices ∀ (k : Nat) (b' : LimitDomSubtype A h_mcs),
        a ≤ b' →
        ((omega_chain_val A h_mcs N).dom.filter
          (fun q => decide (a.val < q ∧ q ≤ b'.val) = true)).card ≤ k →
        ∃ n, Order.succ^[n] a = b' by
      exact this count b hab.le le_rfl
    intro k
    induction k with
    | zero =>
      intro b' hab' hcount
      -- count = 0 and a ≤ b': must have a = b'
      -- If a < b': b'.val in dom_N (since birth(b') ≤ ...) WAIT:
      -- b' is arbitrary, birth(b') might be > N!
      -- The count is with FIXED dom_N. If b'.val not in dom_N,
      -- count could still be 0 with a < b'.
      -- THIS IS THE GAP AGAIN.
      sorry
    | succ k ih => sorry
```

**Wait, I was wrong.** The IH quantifies over ALL b' with a <= b', not just those where b'.val in dom_N. For an arbitrary b' with b'.val not in dom_N, count_N = 0 is possible even when a < b'.

The resolution is: in the inductive step, we only apply IH to pred(b') where b'.val IS in dom_N. But an arbitrary b' in the universal quantifier might have b'.val not in dom_N.

### 7.5 ACTUAL FIX: Prove the statement only for original b, not universally

The correct formulation avoids universal quantification:

```
-- Goal: exists n, succ^[n] a = b  (for the SPECIFIC a, b given)
-- N = max(birth(a), birth(b))
-- Induction on count_N(b) = |dom_N ∩ (a.val, b.val]|
-- count_N(b) ≥ 1 since b.val ∈ dom_N and a.val < b.val

-- Step: let pb = pred(b). Then a ≤ pb < b.
-- count_N(pb) = count_N(b) - 1

-- Apply IH to (a, pb, count_N(pb)):
-- BUT we need the SAME a and the SAME N!
-- And we need to prove the statement for pb:
--   exists n, succ^[n] a = pb

-- For this, N is FIXED. Is pb.val in dom_N?
-- NOT NECESSARILY. birth(pb) might be > N.
-- But count_N(pb) = count_N(b) - 1 regardless.

-- If count_N(pb) = 0: need a = pb.
-- But a.val < pb.val is possible (if a.val < pb.val < b.val and no dom_N between them).

-- THE GAP PERSISTS for the inductive hypothesis applied to pb when pb.val ∉ dom_N.
```

### 7.6 Final Assessment

The dom_N count induction with FIXED N has a genuine gap when the IH is applied to elements whose `.val` is NOT in dom_N. This gap is isomorphic to the original problem restricted to a "gap interval" of dom_N.

The `Set.Finite` / `LocallyFiniteOrder` pathway does NOT offer a shortcut around this gap. All approaches reduce to the same fundamental challenge: proving that the succ chain traverses "dom_N gaps" (intervals between consecutive dom_N elements that contain later-born limit_dom elements).

**The recommended approach remains**: find a well-founded measure that decreases across dom_N gaps. The most promising candidate is a measure that combines the dom_N count with omega chain structural invariants (e.g., the number of unresolved counterexamples relevant to the interval).
