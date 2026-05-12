# Teammate B Findings: Mathlib Convergence API for IsSuccArchimedean

Task: 123 | Date: 2026-05-11

## 1. Monotone Convergence in R for Nat-Indexed Sequences

### Primary Lemma: `Real.tendsto_of_bddBelow_antitone`

```
theorem Real.tendsto_of_bddBelow_antitone
    {f : ℕ → ℝ} (h_bdd : BddBelow (Set.range f)) (h_ant : Antitone f) :
    ∃ r, Filter.Tendsto f Filter.atTop (nhds r)
```

**Location**: `Mathlib.Topology.Instances.NNReal.Lemmas` (already imported at line 11)

**What it gives**: A bounded-below antitone (decreasing) Nat-indexed sequence in R converges to some limit r in the nhds topology. This is exactly what we need for the pred-chain `pred^[k](b)` cast to R.

### Increasing variant: `Real.tendsto_of_bddAbove_monotone`

```
theorem Real.tendsto_of_bddAbove_monotone
    {f : ℕ → ℝ} (h_bdd : BddAbove (Set.range f)) (h_mon : Monotone f) :
    ∃ r, Filter.Tendsto f Filter.atTop (nhds r)
```

**Location**: Same file. For the succ-orbit `succ^[n](a)` cast to R (increasing, bounded above by b).

### General variant: `tendsto_of_monotone`

```
theorem tendsto_of_monotone {f : ι → α}
    (h_mono : Monotone f) :
    Tendsto f atTop atTop ∨ ∃ l, Tendsto f atTop (𝓝 l)
```

**Location**: `Mathlib.Topology.Order.MonotoneConvergence`. This is more general (works for conditionally complete linear orders, not just R), but since our sequence is bounded, the specific R variants are more convenient as they directly provide the limit.

### Building blocks used internally

```
tendsto_atTop_isLUB : Monotone f → IsLUB (Set.range f) a → Tendsto f atTop (nhds a)
tendsto_atTop_isGLB : Antitone f → IsGLB (Set.range f) a → Tendsto f atTop (nhds a)
tendsto_atTop_ciSup : Monotone f → BddAbove (Set.range f) → Tendsto f atTop (nhds (⨆ i, f i))
tendsto_atTop_ciInf : Antitone f → BddBelow (Set.range f) → Tendsto f atTop (nhds (⨅ i, f i))
```

**Location**: `Mathlib.Topology.Order.MonotoneConvergence`

## 2. Rat.cast Order Preservation

### Exact Signatures

All from `Mathlib.Data.Rat.Cast.Order` (already imported at line 12):

```
theorem Rat.cast_le {p q : ℚ} {K : Type} [Field K] [LinearOrder K] [IsStrictOrderedRing K] :
    ↑p ≤ ↑q ↔ p ≤ q

theorem Rat.cast_lt {p q : ℚ} {K : Type} [Field K] [LinearOrder K] [IsStrictOrderedRing K] :
    ↑p < ↑q ↔ p < q

theorem Rat.cast_mono {K : Type} [Field K] [LinearOrder K] [IsStrictOrderedRing K] :
    Monotone (Rat.cast : ℚ → K)

theorem Rat.cast_strictMono {K : Type} [Field K] [LinearOrder K] [IsStrictOrderedRing K] :
    StrictMono (Rat.cast : ℚ → K)
```

### How to Use for Transfer

Given `a b : LimitDomSubtype A h_mcs` (subtypes of Q):

- From `a.val ≤ b.val` (in Q) to `(a.val : ℝ) ≤ (b.val : ℝ)`: use `Rat.cast_le.mpr`
- From `a.val < b.val` (in Q) to `(a.val : ℝ) < (b.val : ℝ)`: use `Rat.cast_lt.mpr`
- Monotone transfer: `Rat.cast_mono` directly gives `Monotone (Rat.cast : ℚ → ℝ)`

### Composing with Antitone Sequences

If `f : ℕ → LimitDomSubtype` is antitone (in the subtype order), then `fun n => (f n).val` is antitone in Q (since the subtype order is inherited), and `fun n => ((f n).val : ℝ)` is antitone in R.

Proof chain:
```
Monotone.comp_antitone : Monotone g → Antitone f → Antitone (g ∘ f)
```
Apply with `g = Rat.cast` (which is `Monotone` by `Rat.cast_mono`) and `f = fun n => (pred^[n] b).val`.

## 3. Extracting Contradiction from Convergence

### Key Lemma: `tendsto_order`

```
theorem tendsto_order {f : β → α} {a : α} {x : Filter β} :
    Tendsto f x (nhds a) ↔
      (∀ a' < a, ∀ᶠ b in x, a' < f b) ∧
      (∀ a' > a, ∀ᶠ b in x, f b < a')
```

**Location**: `Mathlib.Topology.Order.Basic` (transitive dependency of existing imports)

This decomposes convergence to L into two "eventually" conditions:
- For any a' < L: eventually f(n) > a'
- For any a' > L: eventually f(n) < a'

### Converting Eventually to Exists

```
Filter.eventually_atTop {p : α → Prop} :
    (∀ᶠ x in atTop, p x) ↔ ∃ a, ∀ b ≥ a, p b
```

This converts `∀ᶠ` over `atTop` to `∃ N, ∀ n ≥ N, ...`.

### The Contradiction Argument

Given:
- The succ-orbit `s(n) = succ^[n](a)` with values in LimitDomSubtype, increasing, bounded by b
- The pred-chain `p(k) = pred^[k](b)` with values in LimitDomSubtype, decreasing, bounded below by a
- `s(n) < p(k)` for all n, k (because succ-orbit < b and iterating to pred^[k](b) shows s(n) <= pred^[k](b) by `succ_iter_le_pred_of_lt_forall` iteration)

Cast to R:
- `f_up(n) = (s(n).val : ℝ)` is monotone, bounded above -- converges to L_up
- `f_down(k) = (p(k).val : ℝ)` is antitone, bounded below -- converges to L_down
- `L_up ≤ L_down` since f_up(n) ≤ f_down(k) for all n, k

**Case L_up < L_down**: Pick a rational q with L_up < (q : ℝ) < L_down. By `tendsto_order`:
- Eventually s(n).val < q (since s converges to L_up < q)
- Eventually p(k).val > q (since p converges to L_down > q)
But p(k) is a domain point, and p(k) > s(n) for all n. Also s(n+1) = succ(s(n)) is the immediate successor of s(n), meaning no domain points between s(n) and s(n+1). For large n, s(n).val is close to L_up, and s(n+1).val is close to L_up too. The gap s(n+1).val - s(n).val tends to 0. But p(k).val stays above L_down > L_up, so p(k) cannot be between any consecutive s(n), s(n+1) -- it's above all of them. This is consistent... actually this case doesn't directly yield a contradiction from the succ/pred no-between property alone. We need a different argument.

**Actually, the simplest approach**: Note that s(n) < p(k) for all n,k. In particular, s(n) < p(0) = b for all n. Also s(n) <= pred(b) for all n. Similarly s(n) <= pred(pred(b)) for all n (by iterating `succ_iter_le_pred_of_lt_forall`). So s(n) <= pred^[k](b) for all n, k.

Now the pred-chain p(k) is strictly decreasing. The values p(k).val form an infinite strictly decreasing sequence of rationals bounded below by a.val. Cast to R: the sequence `f_down(k) = (p(k).val : ℝ)` converges to some L.

By `tendsto_order`, for any eps > 0, eventually p(k).val < L + eps. In particular, for any two consecutive pred-chain elements p(k) and p(k+1) = pred(p(k)), both their R-values are eventually within eps of L. So `p(k).val - p(k+1).val → 0` as k → infinity.

But each p(k) and p(k+1) are consecutive in LimitDomSubtype: pred(p(k)) = p(k+1), with no domain points between p(k+1) and p(k). The succ-orbit values s(n) must all be ≤ p(k+1) for every k (as shown above). But the succ-orbit is increasing and bounded above by every p(k). The succ-orbit converges to L_up ≤ L.

If L_up = L: For large n, s(n).val is close to L from below. For large k, p(k).val is close to L from above. So for large enough n and k, we have s(n).val < L < p(k+1).val < p(k).val, with the gap p(k) - p(k+1) small. But s(n) is a domain point with s(n) < p(k+1), so s(n) ≤ pred(p(k+1)) = p(k+2). Iterating, s(n) ≤ p(k) for ALL k. But p(k).val → L and s(n).val → L. For any fixed n, s(n).val ≤ p(k).val for all k. Taking k → ∞, s(n).val ≤ L. And L = L_up = sup s(n).val. So s(n).val → L from below.

Now: for large n, s(n).val > L - eps. For large k, p(k).val < L + eps. With eps small enough, p(k).val - s(n).val < 2eps. But p(k) is a domain point and s(n) is a domain point, with p(k+1) = pred(p(k)) between them (p(k+1) < p(k)). Since s(n) ≤ p(k+1) < p(k), s(n) is a domain point below p(k). succ(s(n)) = s(n+1) is the immediate successor -- no domain points between s(n) and s(n+1). If p(k) is between s(n) and s(n+1), that contradicts no-between. Otherwise p(k) ≥ s(n+1).

**The cleaner contradiction**: Eventually the pred-chain p(k) and succ-orbit s(n) interleave. Specifically: for large k, p(k+1) < p(k), and both are close to L. For large n, s(n) is close to L. Since both sequences converge to L, there exist n, k such that s(n) < p(k+1) < p(k) < s(n+1). But that means p(k+1) is a domain point between s(n) and s(n+1) = succ(s(n)), contradicting the immediate successor property.

**Proof that such n, k exist**: 
- s(n+1).val - s(n).val → 0 (both converge to L)
- p(k).val → L from above
- For large n, the gap (s(n).val, s(n+1).val) has length approaching 0
- For large k, p(k).val is close to L
- Since s(n).val → L, for large n, s(n+1).val - s(n).val is small
- Pick k such that p(k).val is within the gap (s(n).val, s(n+1).val) for some n

Wait, this requires p(k) to be BETWEEN consecutive succ-orbit elements. But we know p(k) ≥ s(n) for all n (since s(n) ≤ pred^[k](b) = p(k)). So p(k) is ABOVE all succ-orbit elements. That means p(k).val ≥ s(n).val for all n, hence p(k).val ≥ L_up. So p(k) cannot be between s(n) and s(n+1) if p(k) ≥ s(n+1).

**Revised cleaner contradiction**: The real issue is that the succ-orbit is bounded above by EVERY pred-chain element. So L_up ≤ L_down = L. If L_up = L, then s(n).val → L from below, and p(k).val → L from above. The gap between them shrinks but never closes: for every n, s(n) < p(0) (strictly). And p(k) → L means for each p(k), we have s(n) ≤ p(k) for all n.

Here is the actual contradiction: consider n large enough that s(n).val > L - delta for any delta > 0. Then s(n+1) = succ(s(n)), and s(n+1).val > s(n).val ≥ L - delta, so s(n+1).val > L - delta. But also s(n+1).val ≤ L (since L = L_up = sup). So s(n+1).val is in (L - delta, L]. If s(n+1) = s(n), then s is eventually constant, say s(n) = c for large n. Then succ(c) = c, meaning c is a max element, contradicting NoMaxOrder.

So s is **strictly** increasing (s(n+1) > s(n) always, since succ(x) > x by `NoMaxOrder` and `limitDomSubtype_succ_le_iff`). In particular, all s(n) are distinct. The sequence s(n).val is strictly increasing and bounded above by L = L_up. But ALSO bounded above by every p(k).val. Since p(k).val → L from above, we have for any eps > 0, eventually p(k).val < L + eps.

Now apply `succ_iter_le_pred_of_lt_forall` iteratively. We have:
- s(n) < p(0) = b for all n
- So s(n) ≤ pred(b) = p(1) for all n
- s(n) < p(1) for all n (since if s(n) = p(1) for some n, then s(n+1) = succ(p(1)), but s(n+1) < b = succ(pred(b)) = succ(p(1))... wait, succ(pred(b)) = b, so s(n+1) = succ(p(1)) = b. But s(n+1) < b. Contradiction!)

THIS is the key! If any s(n) = p(k) for some n, k, then s(n+1) = succ(s(n)) = succ(p(k)), and p(k) = pred(p(k-1)), so succ(p(k)) = succ(pred(p(k-1))) = p(k-1) (by `succ_pred`). So s(n+1) = p(k-1). Iterating, s(n+k) = p(0) = b. But s(n+k) < b for all n. Contradiction!

So s(n) < p(k) (strictly) for all n, k. In particular, s(n) ≠ p(k) always.

Now if s(n) < p(k) strictly for all n, k, the succ-orbit and pred-chain never meet. Cast to R: f_up converges to L_up, f_down converges to L_down, with L_up ≤ L_down.

If L_up < L_down: there's a gap. But s is strictly increasing, so s(n).val → L_up strictly from below. Every s(n) is a domain point, and succ(s(n)) = s(n+1) is the immediate successor. For large n, s(n).val and s(n+1).val are both close to L_up, with the gap approaching 0. Since L_up < L_down, the first pred-chain element p(0) = b has p(0).val ≥ L_down > L_up, and s(n) < p(0). The domain point p(0) is above all orbit elements. But succ of the last orbit element (approaching L_up) should still be below p(0)... this doesn't immediately give a contradiction.

**THE ACTUALLY CLEAN PROOF**: Use the fact that s is strictly increasing on LimitDomSubtype. The function n ↦ s(n) is a strict injection from ℕ into the set {x : LimitDomSubtype | a ≤ x ∧ x ≤ pred(b)}. This set, viewed as a subset of the rationals, is contained in the interval [a.val, pred(b).val]. If this set is finite, the injection from ℕ contradicts finiteness. If this set is infinite, the convergence argument gives the contradiction.

But can we prove this set is finite WITHOUT convergence? That would be circular.

## 4. Alternative: Pure Order Theory Approaches

### 4.1 Approach via `Set.Finite` of Icc — NEEDS INVESTIGATION

If we can prove `Set.Finite (Set.Icc a b)` for LimitDomSubtype (in the discrete case), then:
- An injection from ℕ into Icc a b is impossible
- The succ-orbit is such an injection (it's strictly monotone, hence injective)
- Contradiction

The question is: how to prove `Set.Finite (Set.Icc a b)`.

**Relevant Mathlib**: `Set.finite_Icc` exists but requires `LocallyFiniteOrder`. Building `LocallyFiniteOrder` requires constructing `Finset.Icc`, which is equally hard.

### 4.2 Approach via Mathlib's existing proof pattern

Mathlib proves `IsSuccArchimedean` from `LocallyFiniteOrder` at line 166 of `Mathlib/Order/SuccPred/LinearLocallyFinite.lean`. The proof uses pigeonhole: the map `n ↦ succ^[n] i` from ℕ to `Finset.Icc i j` must have two colliding values since the target is finite, and collision implies `IsMax`, contradicting `< j`.

Key lemma used: `Finite.exists_ne_map_eq_of_infinite`:
```
theorem Finite.exists_ne_map_eq_of_infinite [Infinite α] [Finite β] (f : α → β) :
    ∃ x y, x ≠ y ∧ f x = f y
```

And: `Order.isMax_iterate_succ_of_eq_of_ne`:
```
theorem Order.isMax_iterate_succ_of_eq_of_ne {a : α} {n m : ℕ}
    (h : succ^[n] a = succ^[m] a) (hne : n ≠ m) : IsMax (succ^[n] a)
```

### 4.3 Direct adaptation of Mathlib's proof (RECOMMENDED)

Instead of building the full `LocallyFiniteOrder` infrastructure, we can directly adapt Mathlib's proof to use convergence to prove the Icc is finite, then apply the pigeonhole argument.

Sketch:
1. Assume `∀ n, succ^[n] a ≠ b` (the negation of the goal)
2. Show `succ^[n] a < b` for all n (by induction + the assumption)
3. Define `f : ℕ → Set.Icc a b` by `f n = ⟨succ^[n] a, ...⟩` (orbit stays in Icc)
4. Show `f` is injective (orbit is strictly increasing)
5. The orbit values (in Q) are strictly increasing and bounded above by b.val
6. Cast to R: converges to some L ≤ b.val (by `Real.tendsto_of_bddAbove_monotone`)
7. Use `tendsto_order` to show: for any eps, eventually s(n+1).val - s(n).val < eps
8. Since s(n) and s(n+1) are consecutive (succ(s(n)) = s(n+1), no domain points between), the gap approaching 0 means: eventually succ(s(n)).val - s(n).val < eps
9. But also s(n+1).val > s(n).val always (strict monotonicity in Q)
10. Contradiction comes from: the orbit is injective, strictly increasing, with gaps → 0, and each gap contains no domain points. But there's a pred-chain from b descending through the SAME set. Alternatively: since the Rat-valued gaps approach 0 but each gap is a "hole" in the domain, the limit L cannot be in the domain (if it were, pred(L) would swallow late orbit elements). And L cannot be outside the domain either (then all orbit elements below L, and succ gives the next one, but succ is a domain point, so orbit extends past L... wait, no -- succ(s(n)) = s(n+1) and s(n+1).val > s(n).val, approaching L from below).

### 4.4 The simplest clean proof I can see

Here is the cleanest proof structure:

```
-- Assume for contradiction: succ^[n](a) ≠ b for all n
-- Step 1: succ^[n](a) < b for all n
-- Step 2: succ^[n](a) ≤ pred^[k](b) for all n, k (by iterating succ_iter_le_pred_of_lt_forall)
-- Step 3: pred-chain p(k) = pred^[k](b) is strictly decreasing, bounded below by a
-- Step 4: Cast p to R: (p(k).val : ℝ) is antitone, bounded below → converges to L
-- Step 5: The gap p(k).val - p(k+1).val → 0 as k → ∞
-- Step 6: succ-orbit s(n) < p(k) for all n, k, but s is increasing with
--         s(n).val ≤ p(k).val → s(n).val ≤ L for all n
-- Step 7: s is strictly increasing (NoMaxOrder) but bounded above by L
-- Step 8: Cast s to R: (s(n).val : ℝ) is monotone, bounded above → converges to L' ≤ L
-- Step 9: For large k, p(k).val - p(k+1).val < eps. No domain points between p(k+1) and p(k).
--         But s(n) ≤ p(k+1) for all n, so s(n).val ≤ p(k+1).val.
--         For large n, s(n).val is close to L'. Since s(n) ≤ p(k+1) < p(k),
--         and p(k+1).val approaches L from above, L' ≤ L.
-- Step 10: Both converge. p(k).val → L, s(n).val → L' ≤ L.
--          For large k and n: p(k+1).val < L + eps, s(n).val > L' - eps.
--          If L' = L: s(n).val > L - eps and p(k+1).val < L + eps.
--            So p(k+1).val - s(n).val < 2*eps.
--            But p(k+1) is a domain point above s(n), and s(n+1) = succ(s(n)) is
--            the immediate successor (no domain points between s(n) and s(n+1)).
--            Since p(k+1) > s(n) and p(k+1) is a domain point, p(k+1) ≥ s(n+1).
--            So s(n+1).val ≤ p(k+1).val < L + eps.
--            But also s(n+1).val > s(n).val > L - eps.
--            This shows s(n+1).val is in (L - eps, L + eps) for any eps > 0.
--            As n → ∞, s(n).val → L. So L' = L.
--          
--          Now: s(n).val → L from below, p(k).val → L from above.
--          For large n: s(n).val is close to L, and s(n+1).val = succ(s(n)).val
--          is strictly above s(n).val, both close to L.
--          For large k: p(k).val is close to L from above.
--          So p(k) is a domain point close to L from above,
--          and s(n) is a domain point close to L from below.
--          s(n+1) = succ(s(n)), so no domain points between s(n) and s(n+1).
--          But p(k) IS a domain point, and for appropriate n,k:
--          s(n) < p(k) < s(n+1)? That would contradict no-between.
--          
--          Can we find such n, k?
--          We need: s(n) < p(k) < succ(s(n)) = s(n+1)
--          i.e., s(n).val < p(k).val < s(n+1).val
--          
--          p(k).val → L from above, s(n).val → L from below.
--          s(n+1).val → L from below (since s(n+1).val ≤ L for all n).
--          For large n: s(n+1).val - s(n).val → 0.
--          For large k: p(k).val is close to L.
--          
--          Pick n large so that s(n).val > L - delta and s(n+1).val < L + delta.
--          Wait: s(n+1).val ≤ L always (if L = L_up). So s(n+1).val ≤ L.
--          And p(k).val ≥ L always? Not necessarily...
--
-- ISSUE: L_up could equal L_down or be strictly less. And we need to show
-- that the orbit enters a "gap" of the pred-chain, which requires careful
-- interleaving.
```

**THE SIMPLEST CLEAN CONTRADICTION** (avoiding the interleaving complexity):

The iteration argument is simpler:

1. s(n) < b for all n
2. So s(n) ≤ pred(b) for all n
3. If s(m) = pred(b) for some m, then s(m+1) = succ(pred(b)) = b (by `succ_pred`). But s(m+1) < b. Contradiction.
4. So s(n) < pred(b) for all n
5. So s(n) ≤ pred(pred(b)) = pred^[2](b) for all n
6. If s(m) = pred^[2](b) for some m, then by step 3 logic, s(m+2) = b. Contradiction.
7. So s(n) < pred^[2](b) for all n
8. Continue: s(n) < pred^[k](b) for all n, k

Now define the pred-chain g(k) = pred^[k](b). This gives strictly decreasing rational values: g(0).val > g(1).val > g(2).val > ...

All these values are ≥ a.val (since s(0) = a ≤ g(k) for all k, so a.val ≤ g(k).val).

Cast to R: h(k) = (g(k).val : ℝ) is antitone and bounded below by (a.val : ℝ). By `Real.tendsto_of_bddBelow_antitone`, h converges to some L.

Now: h(k) - h(k+1) = g(k).val - g(k+1).val → 0 as k → ∞ (since both h(k) and h(k+1) converge to L).

But g(k+1) = pred(g(k)), and succ(g(k+1)) = succ(pred(g(k))) = g(k) (by `succ_pred`). So the interval (g(k+1), g(k)) in the subtype order contains no domain points (since succ(g(k+1)) = g(k)).

The rational distance g(k).val - g(k+1).val represents a "gap" in the domain with no domain points inside. This gap → 0.

But s is strictly increasing (s(n+1) > s(n) always), and s(n) ≤ g(k+1) for all n, k. So s(n).val ≤ g(k+1).val for all k. Taking k → ∞: s(n).val ≤ L for all n. And s is strictly increasing with s(n).val ≤ L. The gaps s(n+1).val - s(n).val > 0 and s(n).val ≤ L.

Now sum the gaps: s(N).val - s(0).val = Σ_{n=0}^{N-1} (s(n+1).val - s(n).val) ≤ L - a.val.

Each gap s(n+1).val - s(n).val > 0. The partial sums are bounded. This is an infinite series of positive terms with bounded partial sums. It converges.

So the gaps s(n+1).val - s(n).val → 0.

Similarly the gaps g(k).val - g(k+1).val → 0.

Now: for any domain point x with x ≤ g(k) for all k, we have x.val ≤ L (since g(k).val → L from above). And succ(x).val > x.val, with succ(x) also ≤ g(k) for all k (since succ(x) ≤ g(k) iff x < g(k), which is true since x ≤ g(k+1) < g(k)). So succ(x).val ≤ L too.

The orbit {s(n)} is an infinite set of distinct domain points in the interval [a.val, L] (in Q). Each point has an immediate successor (no domain points between). The sequence is strictly increasing with values → L.

Similarly, {g(k)} is an infinite set of distinct domain points in [L, b.val] (in Q), strictly decreasing with values → L.

Now consider the orbit and pred-chain together: both accumulate at L (in R). But L is either a rational or an irrational.

**Case L is irrational**: Consider any domain point z with z.val < L. Then succ(z) is a domain point with succ(z).val > z.val. If succ(z).val > L, then succ(z).val > L, but L is irrational, so succ(z).val ≠ L. Since succ(z) is a domain point and z.val < L < succ(z).val, the pred-chain element g(k) with g(k).val close to L from above satisfies z < g(k) < succ(z)? No -- g(k).val is close to L from above, and succ(z).val > L, so g(k).val could be < succ(z).val. That would give z < g(k) < succ(z), contradicting the immediate successor property. YES -- THIS GIVES THE CONTRADICTION when succ(z).val > L.

But does any orbit element have succ value above L? Since s(n).val → L from below and succ(s(n)) = s(n+1), with s(n+1).val → L from below, we have s(n+1).val < L for all n (or = L but L is irrational and s(n+1).val is rational, so strictly <). So succ(s(n)).val = s(n+1).val < L for all n. The orbit never crosses L.

Hmm, so in the irrational case, the orbit stays below L and the pred-chain stays above L. No interleaving.

**Case L is rational**: If L is in the domain, let z be the domain point with z.val = L. Then pred(z) is a domain point with pred(z).val < L. For large k, g(k).val is close to L from above, so g(k).val < L + eps. But also g(k) > z (since g(k).val > L = z.val... wait, g(k).val → L, so eventually g(k).val could equal L. If g(k₀).val = L for some k₀, then g(k₀) = z. Then g(k₀+1) = pred(z), and g(k₀+2) = pred(pred(z)), etc. The orbit s(n) ≤ pred(z) for all n (since s(n) < z and s(n) ≤ pred(z)). But also s(n) ≤ pred(pred(z)) for all n, etc. So s(n) ≤ pred^[j](z) for all j. But pred^[j](z).val → L' (a new limit) from above, with L' ≤ pred(z).val < L. This shifts the problem but doesn't resolve it.

If g(k).val > L for all k but g(k).val → L: then z (with z.val = L) satisfies z < g(k) for all k. succ(z) is a domain point with succ(z).val > L. For large k, g(k).val is close to L from above. If succ(z).val > g(k).val for some k, then z < g(k) < succ(z), contradicting that succ(z) is the immediate successor of z (no domain points between z and succ(z)).

succ(z).val > z.val = L. g(k).val → L from above. For large k, g(k).val < succ(z).val (since g(k).val → L < succ(z).val). So for large k: z.val = L < g(k).val < succ(z).val. This means g(k) is a domain point with z < g(k) < succ(z). Contradiction with the immediate successor property!

**THIS IS THE CONTRADICTION** for the case L rational and L in the domain.

**Case L is rational but NOT in the domain**: Then there's no domain point at L. The orbit stays below L, the pred-chain stays above L (or reaches L, but if g(k₀).val = L, then g(k₀) would be a domain point with rational value L, contradicting L not in domain). So g(k).val > L for all k and g(k).val → L. Similarly s(n).val < L for all n and s(n).val → L.

Consider any domain point z with z.val > L. Then z > s(n) for all n. pred(z) has pred(z).val < z.val. If pred(z).val ≥ L, then pred(z) is another domain point above L. Iterate: pred^[j](z) eventually has value < L (since the pred-chain of z goes below L eventually... or does it?). Actually, the pred-chain from g(0) = b already gives g(k).val → L from above. For any domain point z above L, if z = g(k) for some k, then pred(z) = g(k+1) is above L too (since g(k+1).val > L). So the pred-chain from b never goes below L.

But s(n).val → L from below. For any domain point below L, its successor is also below L (since s(n+1).val < L). So no domain point below L has a successor above L. And no domain point above L has a predecessor below L (since pred(g(k)) = g(k+1) which is above L).

This means the domain is "disconnected" at L: no domain point crosses L via succ or pred. But a ≤ s(n) < L < g(k) ≤ b, and succ^[n](a) never reaches b. This is exactly what we assumed. So this case doesn't give a contradiction... yet.

But wait: consider the succ-orbit. s(n).val → L from below. succ(s(n)) = s(n+1), and s(n+1).val > s(n).val. For large n, s(n).val is very close to L. succ(s(n)) = s(n+1) has s(n+1).val also close to L (from below). The gap s(n+1).val - s(n).val → 0.

Now, s(n) and s(n+1) are consecutive domain points: no domain points between them. The gap (s(n).val, s(n+1).val) contains no domain-valued rationals. As n → ∞, these gaps cover intervals approaching L from below, with gaps shrinking to 0.

Consider a domain point z that is the INFIMUM of the pred-chain {g(k)}: z.val = inf{g(k).val}. If z exists in the domain, z.val = L (the limit), contradicting L not in domain. So no domain point equals the infimum.

But the pred-chain {g(k)} is a decreasing sequence of domain points. The set of domain points above L is {g(k) | k ∈ ℕ} (well, possibly more, but all domain points above L in [L, b] are in the pred-chain by the "no gap" property). Actually, are they? Between g(k+1) and g(k) there are no domain points, so YES -- every domain point in the interval [a, b] that is ≥ g(k+1) and ≤ g(k) is either g(k+1) or g(k). So the domain points above L in [a, b] are exactly {g(k)}.

Similarly, domain points below L in [a, b] are exactly {s(n)}.

So the domain in [a, b] is {s(n)} ∪ {g(k)}, all approaching L from both sides but never reaching it. This is a valid configuration... mathematically there's no contradiction here from pure convergence alone.

**WAIT**: But we also know that `NoMaxOrder` holds for LimitDomSubtype. Every domain point has a successor. In particular, s(n) has succ(s(n)) = s(n+1). And g(k) has succ(g(k)). What is succ(g(k))? If k > 0, then g(k) = pred(g(k-1)), so succ(g(k)) = succ(pred(g(k-1))) = g(k-1) (by `succ_pred`). And succ(g(0)) = succ(b) is some domain point above b, outside [a, b].

So within [a, b], the structure is: ... s(0) < s(1) < s(2) < ... (approaching L) ... g(2) < g(1) < g(0) = b (descending from b). The succ function chains s(n) → s(n+1) and g(k) → g(k-1). The pred function chains g(k-1) → g(k) and s(n) → s(n-1) (for n > 0).

What about pred(s(0)) = pred(a)? It's outside [a, b], not relevant.

What about succ(g(k)) for k > 0? succ(g(k)) = g(k-1). For k = 0: succ(g(0)) = succ(b) is outside [a, b].

So the succ-orbit from a goes: a = s(0), s(1), s(2), ..., and never reaches any g(k). The pred-chain from b goes: b = g(0), g(1), g(2), ..., and never reaches any s(n). The two chains are disjoint and separated by L.

But here's the thing: the domain in [a, b] is the union of two omega-chains, one going up from a and one going down from b. These chains are supposed to cover ALL domain points in [a, b]. Between s(n) and s(n+1), no domain points (by construction of succ). Between g(k+1) and g(k), no domain points (by construction of pred). And between s(n) and g(k) for the "innermost" elements closest to L, there are no domain points either (since for any domain point x with s(n) < x < g(k), x is a domain point in [a, b], so x must be either some s(m) or some g(j), but we argued all s(m) < L and all g(j) > L, so x is between L - eps and L + eps, and either x < L giving x = s(m), or x > L giving x = g(j)).

This means the limit_dom ∩ [a.val, b.val] is countably infinite with no points at L. But limit_dom is a subset of Q, and the construction adds domain points in each omega-chain stage. The question is whether this infinite-in-both-directions structure is actually realizable by the chronicle construction. The plan (and prior research) assert it is NOT possible because the discrete guard `U(T, bot)` prevents accumulation. But the convergence proof must show this formally.

## 5. IsSuccArchimedean Proofs in Mathlib

### 5.1 Integer proof (direct computation)

```
instance : IsSuccArchimedean ℤ :=
  ⟨fun {a b} h =>
    ⟨(b - a).toNat, by rw [succ_iterate, toNat_sub_of_le h, ← add_sub_assoc, add_sub_cancel_left]⟩⟩
```

This works because `succ^[n] a = a + n` for integers, so `n = b - a` gives `succ^[n] a = b`.

**Cannot adapt**: Our type doesn't have additive structure.

### 5.2 From WellFoundedGT (automatic)

```
instance (priority := 100) WellFoundedGT.toIsSuccArchimedean [WellFoundedGT α] [SuccOrder α] :
    IsSuccArchimedean α
```

**Potentially usable**: If we can show `>` is well-founded on LimitDomSubtype (i.e., no infinite strictly decreasing sequence), we get IsSuccArchimedean for free. But proving WellFoundedGT for a subtype of Q requires essentially the same convergence argument.

### 5.3 From LocallyFiniteOrder (pigeonhole)

The proof at line 166 of LinearLocallyFinite.lean:
1. Map ℕ → Finset.Icc i j via n ↦ succ^[n] i
2. Since Finset.Icc is finite and ℕ is infinite, pigeonhole gives collision
3. Collision implies IsMax, contradicting < j

**Best candidate for adaptation**: If we can show `Set.Icc a b` is finite for LimitDomSubtype.

### 5.4 From OrderDual

```
instance : IsSuccArchimedean αᵒᵈ := ...  -- from IsPredArchimedean
```

## 6. Recommended Proof Strategy

### Option A: Convergence + Gap Contradiction (plan-aligned)

This is the approach in the plan. The proof proceeds:

1. Assume ∀ n, succ^[n](a) ≠ b
2. Show succ^[n](a) < b for all n
3. Define pred-chain p(k) = pred^[k](b), show s(n) ≤ p(k) for all n, k
4. Cast p(k).val to R; show antitone, bounded below; converges to L
5. Use `tendsto_order` to show: for large k, p(k).val - p(k+1).val < eps
6. succ(p(k+1)) = p(k) (by `succ_pred`), so no domain points between p(k+1) and p(k)
7. For large k, pick eps so that the rational gap (p(k+1).val, p(k).val) has width < eps
8. s(n) ≤ p(k+1) for all n,k; so s is bounded above by every p(k+1)
9. s also converges to some L' ≤ L
10. **Key step**: We need s(n) = p(k+1) for some n, k (contradiction since s(m+k+1) = b)
    Or: we need a domain point strictly between consecutive pred-chain elements
    (contradiction since succ(p(k+1)) = p(k), so no domain points in between)

**Problem**: Step 10 requires showing the succ-orbit actually meets the pred-chain, which is exactly what we're trying to prove. The convergence argument alone doesn't give this interleaving.

**Resolution**: The convergence DOES give the contradiction via the following argument:

Consider the set S = {x : LimitDomSubtype | a ≤ x ∧ x ≤ b}. Both the succ-orbit and pred-chain are subsets. The succ-orbit is s(0) < s(1) < s(2) < ... and the pred-chain is g(0) > g(1) > g(2) > .... Since s(n) < g(k) for all n, k, these are disjoint.

Now define h : ℕ × ℕ → LimitDomSubtype by h(n, 0) = s(n), h(0, k) = g(k). This doesn't directly help. Instead:

**The key realization**: The pred-chain from b eventually reaches a (since we assume it doesn't, and derive contradiction). Actually no -- we're trying to prove the succ-orbit from a reaches b, which is equivalent to the pred-chain from b reaching a (by `isSuccArchimedean_iff_isPredArchimedean`).

So the proof should work symmetrically: assume pred^[k](b) ≠ a for all k, derive contradiction. But that's the SAME problem.

### Option B: Direct adaptation of Mathlib's pigeonhole proof (STRONGEST RECOMMENDATION)

Bypass the convergence argument entirely. Instead, prove `Set.Icc a b` is finite for LimitDomSubtype, then apply the Mathlib pattern.

**How to prove finiteness**: Use the convergence argument to show the Icc is finite, THEN use finiteness to get IsSuccArchimedean.

Actually, the convergence argument can prove finiteness:

1. Suppose Set.Icc a b is infinite (for contradiction)
2. An infinite subset of Q contained in [a.val, b.val] has an accumulation point L in R
3. There exist domain points arbitrarily close to L from either side
4. If L is rational and in the domain: consider pred(L) and L. Between pred(L) and L, no domain points. But there exist domain points in (pred(L).val, L.val) since it accumulates at L from below. Contradiction.
5. If L is not in the domain or L is irrational: any domain point z with z.val > L has pred(z) with pred(z).val < z.val. If pred(z).val > L, then there are domain points between z and pred(z)? No -- no domain points between pred(z) and z by definition. But there are domain points accumulating at L from below and from above (since L is an accumulation point from both sides -- or at least one side).

**Hmm, "accumulation point" from the Bolzano-Weierstrass theorem for bounded infinite subsets of R.** Let me check if Mathlib has this.

```
theorem IsCompact.exists_tendsto_of_frequently
```

or better:

```
theorem BolzanoWeierstrass : Set.Infinite s → BddAbove s → BddBelow s → ∃ accumulation point
```

Actually, the simpler approach: an infinite subset of Icc a b in Q gives an infinite sequence. Bolzano-Weierstrass (in R) gives a convergent subsequence. The limit point creates the contradiction.

But this is getting complicated. Let me check what Mathlib has for Bolzano-Weierstrass.

### Option C: Convergence of the succ-orbit directly (SIMPLEST PROOF)

Here is what I believe is the cleanest proof:

```
-- Context: succ^[n](a) < b for all n
-- The succ-orbit s(n) = succ^[n](a) is strictly increasing and bounded above
-- Cast to R: (s(n).val : ℝ) converges to some L
-- 
-- Key claim: succ(s(n)) = s(n+1), and succ(s(n)).val > s(n).val,
-- but also succ(s(n)).val → L (since s(n+1).val → L).
-- So the gap succ(s(n)).val - s(n).val → 0.
-- Between s(n) and succ(s(n)) = s(n+1), no domain points.
-- The gap has rational width → 0.
-- 
-- Now consider any domain point z with z.val > L. We claim z ≥ b.
-- Proof: z.val > L ≥ s(n).val for all n, so z > s(n) for all n.
-- Since z is a domain point above all s(n), and succ(s(n)) = s(n+1) ≤ ... ≤ z,
-- we need succ(s(n)) ≤ z for all n, so s(n+1) ≤ z for all n.
-- But also z is a domain point. pred(z) < z, so pred(z).val < z.val.
-- If pred(z).val ≥ L: pred(z) is above all s(n) too. Iterate: pred^[j](z) ≥ all s(n).
-- The pred-chain from z stays above all s(n). pred^[j](z) is strictly decreasing,
-- bounded below by s(n) for all n. So pred^[j](z).val ≥ L for all j.
-- But the pred-chain has values → some L'' ≥ L.
-- If L'' > L: contradiction with density? No, we're in discrete case.
-- If L'' = L: the pred-chain of z accumulates at L from above.
-- Between pred^[j+1](z) and pred^[j](z), no domain points.
-- These gaps shrink to 0. But s(n) is a domain point ≤ pred^[j](z) for all n, j.
-- For large n, s(n).val is close to L = L''. For large j, pred^[j](z).val is close to L.
-- So for large n and j, s(n) and pred^[j](z) are both close to L.
-- pred^[j](z) is a domain point above s(n). succ(s(n)) = s(n+1).
-- No domain points between s(n) and s(n+1).
-- If pred^[j](z) is between s(n) and s(n+1): CONTRADICTION.
-- This happens when s(n).val < pred^[j](z).val < s(n+1).val.
-- 
-- We have:
-- s(n).val → L from below
-- pred^[j](z).val → L from above
-- s(n+1).val - s(n).val → 0
-- pred^[j](z).val - L → 0
-- 
-- For any j, pred^[j](z).val > L > s(n).val for large n.
-- pred^[j](z) > s(n) (as domain points), so pred^[j](z) ≥ s(n+1) = succ(s(n))
-- (since pred^[j](z) is a domain point above s(n), and no domain points between
-- s(n) and succ(s(n)) = s(n+1), so pred^[j](z) ≥ s(n+1)).
-- This gives pred^[j](z).val ≥ s(n+1).val for all n.
-- In particular pred^[j](z).val ≥ sup_n s(n).val = L.
-- So pred^[j](z).val ≥ L for all j.
-- 
-- Now: pred^[j](z).val > L for all j (if pred^[j](z).val = L, then pred^[j](z) is
-- a domain point with rational value L, and pred^[j](z) > s(n) for all n, but
-- s(n).val → L from below. So for large n, s(n).val > L - eps.
-- succ(s(n)) = s(n+1) with s(n+1).val > s(n).val.
-- Since pred^[j](z) > s(n) and pred^[j](z) is a domain point,
-- pred^[j](z) ≥ succ(s(n)) = s(n+1).
-- pred^[j](z).val ≥ s(n+1).val for all n.
-- L = pred^[j](z).val ≥ s(n+1).val → L.
-- So s(n+1).val → L from below with s(n+1).val ≤ L.
-- succ(pred^[j](z)) = pred^[j-1](z) (by succ_pred).
-- pred^[j-1](z).val > pred^[j](z).val = L.
-- So pred^[j-1](z) > pred^[j](z).
-- But pred^[j](z).val = L and s(n).val < L for all n, s(n).val → L.
-- succ(s(n)) = s(n+1), and s(n+1).val ≤ L = pred^[j](z).val.
-- If s(n+1).val = L for some n+1: then s(n+1) is a domain point with value L.
-- But s(n+1) ≤ pred^[j](z), and pred^[j](z).val = L = s(n+1).val,
-- so s(n+1) = pred^[j](z) (since domain points are subtypes of Q, equal val ↔ equal).
-- Then s(n+2) = succ(s(n+1)) = succ(pred^[j](z)) = pred^[j-1](z).
-- Iterating: s(n+1+k) = pred^[j-k](z) for k ≤ j.
-- When k = j: s(n+1+j) = pred^[0](z) = z.
-- But z ≥ b (from our claim), so s(n+1+j) ≥ b. But s(m) < b for all m. Contradiction!
-- 
-- So s(n).val < L for all n (strictly). L = sup is not attained.
-- pred^[j](z).val > L for all j (strictly).
-- pred^[j](z).val → L''. 
-- If L'' = L: pred^[j](z) > L > s(n), and gaps on both sides shrink to 0.
-- For large j and n: both pred^[j](z) and s(n) are within eps of L.
-- pred^[j](z).val - s(n).val < 2*eps.
-- But pred^[j](z) is a domain point above s(n), so pred^[j](z) ≥ succ(s(n)) = s(n+1).
-- pred^[j](z).val ≥ s(n+1).val.
-- Also s(n+1).val - s(n).val → 0.
-- pred^[j](z).val - s(n+1).val = pred^[j](z).val - s(n).val - (s(n+1).val - s(n).val)
--                                < 2*eps - (s(n+1).val - s(n).val)
-- But s(n+1).val - s(n).val > 0 always.
-- For sufficiently small eps, 2*eps < s(n+1).val - s(n).val???
-- No! Both approach 0. We can't guarantee which is smaller.
-- 
-- ACTUAL KEY: pred^[j](z) ≥ s(n+1) ≥ s(n) + delta_n where delta_n → 0.
-- pred^[j](z) ≤ L + gamma_j where gamma_j → 0.
-- s(n+1) ≥ s(n) ≥ L - epsilon_n where epsilon_n → 0.
-- So pred^[j](z) ∈ [s(n+1), s(n+1) + ???]... this is getting circular.
```

**THE ACTUAL PROOF THAT WORKS**: After extensive analysis, the clean contradiction is:

**Both the succ-orbit and pred-chain converge to the same limit L. The gaps between consecutive orbit elements and between consecutive pred-chain elements both approach 0. For sufficiently large n and k, a pred-chain element falls strictly between two consecutive orbit elements, contradicting the immediate successor property.**

Formally:
1. f_up(n) = (s(n).val : ℝ) → L_up (monotone bounded)
2. f_down(k) = (p(k).val : ℝ) → L_down (antitone bounded)  
3. L_up ≤ L_down
4. If L_up < L_down, pick rational q with L_up < q < L_down. Eventually f_up(n) < q and f_down(k) > q for all large n, k. Consider the domain point s(n) closest to q from below. succ(s(n)) = s(n+1). If s(n+1).val ≤ q, continue. Eventually we get the largest s(N) with s(N).val ≤ q. Then succ(s(N)) = s(N+1) has s(N+1).val > q (since s converges to L_up and q > L_up... WAIT no, q > L_up means eventually s(n).val < q, so ALL s(n) stay below q. And all p(k) stay above q. So there are no domain points in [q-eps, q+eps] for small eps. But this doesn't directly give a contradiction.

**HMMMM**. Let me reconsider.

**THE ACTUAL CLEAN PROOF (for real this time)**:

The contradiction comes from the SUCC-ORBIT ALONE, without the pred-chain:

1. s(n) is strictly increasing (s(n+1) = succ(s(n)) > s(n))
2. s(n) < b for all n (assumption)
3. s(n).val is strictly increasing in Q, bounded above by b.val
4. Cast to R: (s(n).val : ℝ) is monotone, bounded → converges to L ≤ (b.val : ℝ)
5. s(n+1).val - s(n).val → 0 (since both s(n).val and s(n+1).val converge to L)

Wait, I can't directly say s(n+1).val - s(n).val → 0 from convergence. That's for convergent sequences: if a_n → L, then a_{n+1} - a_n → 0. YES -- this follows from `tendsto_sub`:

If f_n → L and f_{n+1} → L, then f_{n+1} - f_n → 0. But also f_{n+1} - f_n > 0 always (strict monotonicity).

6. Between s(n) and s(n+1), no domain points (immediate successor property)
7. The rational interval (s(n).val, s(n+1).val) has width → 0 and contains no domain points
8. Now s(n).val ≤ pred(b).val for all n (since s(n) < b implies s(n) ≤ pred(b))
9. pred(b).val < b.val
10. Similarly s(n).val ≤ pred(pred(b)).val for all n (iterate step 8)
11. The pred-chain from b: pred^[k](b) > s(n) for all n (strict, since if = then orbit reaches b)
12. For each k: pred^[k](b) is a domain point > s(n) for all n
13. So pred^[k](b) ≥ succ(s(n)) = s(n+1) for all n (no domain points between s(n) and succ(s(n)))
14. So pred^[k](b).val ≥ s(n+1).val → L (taking n → ∞)
15. pred^[k](b).val ≥ L for all k
16. pred^[k](b).val → L (since it's decreasing, bounded below by L)
17. So L_down = L
18. For large k: pred^[k](b).val is close to L from above
19. For large n: s(n).val is close to L from below
20. Both get within eps of L

21. **THE CONTRADICTION**: For large k, the gap pred^[k](b).val - pred^[k+1](b).val → 0. No domain points in this gap. For large n, s(n).val is close to L. Since pred^[k+1](b) ≥ s(n+1) for all n, and pred^[k+1](b).val → L, and s(n+1).val → L, we have for any n: pred^[k+1](b) ≥ s(n+1). 

Now the orbit elements s(n) and pred-chain elements pred^[k](b) are both domain points, interleaved near L. Since both sides approach L, for large enough n and k:
- s(n).val > L - eps  
- pred^[k](b).val < L + eps
- s(n+1).val > s(n).val (by strict monotonicity)
- pred^[k](b) ≥ s(n+1) (proved above)
- pred^[k+1](b) = pred(pred^[k](b))
- succ(pred^[k+1](b)) = pred^[k](b) (by succ_pred)
- No domain points between pred^[k+1](b) and pred^[k](b)

If s(n) is between pred^[k+1](b) and pred^[k](b), that's a domain point in the gap: contradiction.

When does s(n) fall in this gap? We need: pred^[k+1](b) < s(n) < pred^[k](b).

But we showed pred^[k](b) ≥ s(n+1) > s(n). So pred^[k](b) > s(n). 
And pred^[k+1](b) ≥ s(n+1) > s(n). So pred^[k+1](b) > s(n).
Hmm, pred^[k+1](b) > s(n) too, so s(n) < pred^[k+1](b) -- s(n) is NOT in the gap.

This doesn't work because ALL pred-chain elements are above ALL orbit elements.

**THE FUNDAMENTAL ISSUE**: The succ-orbit stays below L and the pred-chain stays above L. They never interleave. The contradiction must come from L itself.

**FINAL CLEAN PROOF**: The contradiction is that the succ-orbit is a strictly increasing, strictly bounded sequence of domain points. The succ function maps each orbit element to the NEXT orbit element. Since s(n).val → L and L is the supremum, for any domain point z with z.val > L, we have z > s(n) for all n, so z ≥ succ(s(n)) = s(n+1) for all n. Thus z.val ≥ L. This just says the supremum is a lower bound for points above L, which is trivial.

For a domain point z with z.val = L (if L is rational and in the domain): z ≥ s(n) for all n (since z.val = L ≥ s(n).val). In fact z > s(n) for all n (since s(n).val < L = z.val, strictly, because s is strictly increasing toward L). So z > s(n) for all n. succ(s(n)) = s(n+1) ≤ z. So s(n).val < z.val for all n. In particular a ≤ s(0) < z ≤ b. Also: we showed s(n) ≤ pred^[k](b) for all n, k. And pred^[k](b).val → L. If z.val = L, then z ≤ pred^[k](b) for large k (since pred^[k](b).val → L from above, and z.val = L). Actually pred^[k](b).val ≥ L = z.val, so pred^[k](b) ≥ z.

Now consider pred(z). pred(z) < z, so pred(z).val < L. succ(pred(z)) = z (by succ_pred). But pred(z) is a domain point below L. So pred(z).val < L. Since s(n).val → L strictly from below, for large n, s(n).val > pred(z).val. So s(n) > pred(z). But also s(n) < z. So pred(z) < s(n) < z. This means s(n) is a domain point between pred(z) and z = succ(pred(z)). **CONTRADICTION**: no domain points between pred(z) and succ(pred(z)).

**THIS WORKS** when L is rational and in the domain.

If L is not in the domain or L is irrational: Consider a domain point z > L (closest one). pred(z) is a domain point. If pred(z).val ≥ L: the pred-chain from z stays above L. If pred(z).val < L: there are orbit elements s(n) with s(n).val > pred(z).val (for large n). So pred(z) < s(n) < z for large n. But no domain points between pred(z) and succ(pred(z)) = z. So s(n) is a domain point in this gap. **CONTRADICTION**.

So if pred(z).val < L for any domain point z with z.val > L: contradiction immediately.

If pred(z).val ≥ L for ALL domain points z above L: then the pred-chain from any such z stays above L. In particular, the pred-chain from b: pred^[k](b).val → L from above, and pred(pred^[k](b)) = pred^[k+1](b) has pred^[k+1](b).val ≥ L for all k. So the infimum of pred^[k](b).val is exactly L, and it's not attained.

Now L is the infimum of {pred^[k](b).val} and the supremum of {s(n).val}, and no domain point has value L.

Consider the domain point z = pred^[K](b) for large K. z.val is close to L from above. pred(z) = pred^[K+1](b), with pred(z).val ≥ L. Between pred(z) and z, no domain points. But the orbit point s(N) for large N has s(N).val close to L from below, so s(N).val < L ≤ pred(z).val. So s(N) ≤ pred(z). And s(N) < z. No contradiction yet since s(N) ≤ pred(z) means s(N) is NOT between pred(z) and z.

**THE REAL ISSUE**: all orbit points are ≤ pred(z), and z.val is close to L but > L. pred(z).val ≥ L ≥ all orbit values. So orbit values are below pred(z). This means pred(z) is above all orbit elements. Then pred(pred(z)) is above all orbit elements too. The entire pred-chain from b is above all orbit elements. The orbit and pred-chain are separated by L (or by the gap between them).

So in this case (L not in domain and all pred-chain predecessors stay above L): the orbit converges to L from below, and the pred-chain converges to L from above, but L itself has no domain point. The orbit has infinitely many points below L, all within [a.val, L). Each has an immediate successor, with the gaps shrinking. The pred-chain has infinitely many points above L, all within (L, b.val]. Each has an immediate predecessor.

**BUT WAIT**: We need to go back to basics. Look at pred(z) where z = pred^[K](b). We claim pred(z).val ≥ L. But what if pred(z).val < L? Then pred(z) < L (as domain point) and z > L. Between pred(z) and z, no domain points. But orbit elements s(n) with s(n).val close to L from below give s(n).val < L < z.val, and s(n).val > pred(z).val (for large n). So s(n) is between pred(z) and z. Contradiction with no domain points between pred(z) and z.

So: either pred(z).val ≥ L (and we continue the pred-chain above L), or pred(z).val < L (and we get immediate contradiction). For the pred-chain: if pred^[K](b).val → L and pred^[K+1](b).val ≥ L for all K, fine. But if for some K, pred^[K+1](b).val < L, we get contradiction immediately.

So suppose pred^[k](b).val > L for all k (strictly, since L is not in domain). Then the infimum is L but never attained. The distance pred^[k](b).val - L → 0. Consider the gap between pred^[K+1](b) and pred^[K](b). This gap has width pred^[K](b).val - pred^[K+1](b).val, and both endpoints > L. The gap (pred^[K+1](b).val, pred^[K](b).val) contains no domain points. As K → ∞, both endpoints approach L, so the gap narrows.

But succ orbit elements are all < L (since s(n).val < L). So orbit elements are NOT in this gap (the gap is above L, orbit is below L). No contradiction from the gap being empty.

**REVISED ANALYSIS**: In the case where L is not attained and no pred-chain element goes below L, there is truly no contradiction from the immediate successor property alone. The configuration is: an infinite ascending chain below L and an infinite descending chain above L, with L as a limit point but not a domain point. This is structurally consistent with the discrete no-between property.

However, **this configuration IS contradictory when the type has NoMaxOrder and NoPredOrder**. The orbit s(n) converges to L from below. For each s(n), succ(s(n)) = s(n+1) < L. So the orbit NEVER crosses L. But consider pred-chain elements: they're above L and decreasing toward L. For any z in the pred-chain, pred(z) is in the pred-chain and also above L.

The issue is: the pred-chain from b is b, pred(b), pred(pred(b)), ..., all above L. This is a infinite strictly decreasing sequence of rationals above L, approaching L. OK, so this is consistent.

But now: what about domain points BETWEEN the orbit and the pred-chain? By our analysis, ALL domain points in [a, b] are either orbit elements (below L) or pred-chain elements (above L). There are no domain points at L. There are no domain points between the last orbit element and the first pred-chain element (there is no "last" orbit element -- they approach L from below). 

So: the orbit goes up to L, and the pred-chain comes down to L, but they never meet because L is not a domain point. This means succ^[n](a) ≠ b for all n. This is exactly our assumption. So in this case, the assumption is CONSISTENT!

**Wait -- that can't be right.** If this were a valid configuration, then IsSuccArchimedean would be FALSE for LimitDomSubtype. But the plan and prior research say it's TRUE.

Let me reconsider. Is this configuration actually possible for the chronicle construction's limit_dom?

**CRITICAL INSIGHT**: The above analysis shows that for a GENERIC linear order with SuccOrder, PredOrder, NoMaxOrder, NoMinOrder, the IsSuccArchimedean property does NOT follow from just having immediate successors and predecessors. The Int has it because of its additive structure. A generic discrete linear order embeddable in Q might NOT have it.

However, our type `LimitDomSubtype` is NOT generic. It is built by a specific construction (omega-chain + counterexample elimination). The plan and prior research claim IsSuccArchimedean holds because of structural properties of this specific construction.

**What property of the construction rules out the "two-chain" scenario?**

The omega-chain construction adds points one at a time. At each stage, a point is added either:
- Above the current maximum (forward resolution)
- Below the current minimum (backward resolution)  
- Between two existing points (counterexample elimination via C4/C5)

In the DISCRETE case (U(T,bot) guard), C4 counterexample elimination is blocked: there are no dense midpoints. Only C5 (Until/Since) can add intermediate points, but the C5 construction in the discrete case adds immediate successors/predecessors only.

So the omega-chain construction in the discrete case builds a chain by adding one successor/predecessor at a time. Starting from 0, the chain extends finitely far in each direction at each stage. After omega stages, the union could be infinite in both directions, but each element was added finitely.

The "two-chain" scenario (orbit below L, pred-chain above L, never meeting) would require the construction to have added infinitely many points below L and infinitely many above L, without ever adding a point at L. This seems possible a priori.

But: at each stage, the construction extends by one point. Points below L are added at stages n_0, n_1, n_2, ... and points above L are added at stages m_0, m_1, m_2, .... The construction alternates between extending various chains. Every element is connected to 0 by a finite succ/pred chain (at the stage it was added). So the succ-chain from 0 reaches every element eventually.

WAIT -- that's exactly what we're trying to prove! The construction adds points along omega-chains, each finitely connected to 0. But the LIMIT domain is the union of all stages. A point added at stage K is connected to 0 by a path within stage K's domain. But the SUCC/PRED of the limit_dom might differ from stage K's succ/pred (since later stages can insert points between existing ones -- but in the DISCRETE case, they can't! Because the U(T,bot) guard prevents midpoint insertion).

**THE KEY**: In the discrete case, once a successor pair (x, y) is established (x is the immediate successor of y at some stage), NO later stage can insert a point between x and y. This is because:
- The only way to insert a point between x and y is via C4 counterexample elimination (density)
- But the U(T,bot) guard ensures F'T is NOT in any domain MCS, so C4 is blocked
- C5 (Until/Since) only extends chains at the boundaries (adding new successors/predecessors to existing max/min elements)

Wait, C5 might also add points BETWEEN existing points. Let me check.

Actually, the C5 construction resolves Until(phi, psi) by finding a witness: a point where psi holds, with phi holding at all intermediate points. In the discrete case, this might add a point between existing points if the Until formula requires it. But the immediate successor property from U(T,bot) means that between any two consecutive domain points, nothing can be inserted.

**HMMMM**. I think the actual situation is more subtle and depends on the specific construction. But the prior research (report 05) discusses this extensively and concludes that Icc CAN be infinite in the chronicle construction. The author's comment at lines 1052-1055 (now probably renumbered) even states this.

So the question is: CAN the "two-chain" scenario occur? If yes, IsSuccArchimedean is FALSE and the plan is wrong. If no, we need a proof that rules it out.

Given the prior research and the plan's assertion that IsSuccArchimedean IS provable via convergence, and the code author's choice to leave this as the last sorry rather than marking it as impossible, I believe IsSuccArchimedean IS true for LimitDomSubtype.

**The missing ingredient**: The convergence proof needs to use a property of LimitDomSubtype beyond just "discrete linear order with succ/pred and no max/min." There must be a property of the specific construction that rules out the two-chain scenario.

After re-reading the research and the plan, I believe the intended argument uses the fact that between succ-orbit elements and pred-chain elements, the `Subtype.val` comparison works: if both sequences converge to L in R, eventually elements from both sequences are within epsilon of L, and since both are Q-valued with gaps → 0, the immediate successor/predecessor property forces them to meet.

But as my analysis shows, this doesn't follow from convergence alone. The orbit stays below L and the pred-chain stays above L. They don't interleave.

**POTENTIAL RESOLUTION**: Maybe the argument doesn't need L_up = L_down. Maybe the argument just needs that the succ-orbit and pred-chain are two infinite strictly monotone sequences in a bounded interval of Q, and shows that their union is infinite, but THEN uses a different property to derive contradiction.

Or: the argument could show that pred^[k](b) eventually equals some s(n), by using a property specific to the omega-chain construction (like: all domain points are reachable from 0 by finite succ/pred chains within some finite stage).

## 7. Confidence Assessment and Recommendation

### Confidence: MEDIUM-LOW (65%) that the convergence approach alone suffices

The convergence approach as described in the plan is mathematically correct IF we can show the succ-orbit and pred-chain interleave (i.e., L_up = L_down and some pred-chain element falls between consecutive orbit elements). My analysis shows this does NOT follow from the discrete structure alone. It requires an additional property of the chronicle construction.

### What additional property is needed

One of:
1. Every domain point is reachable from 0 by finite succ-chain (THIS IS EXACTLY IsSuccArchimedean -- circular)
2. The limit_dom has no accumulation points (i.e., Set.Icc a b is finite) -- this would make the proof trivial
3. The omega-chain construction ensures that predecessors eventually reach earlier stages -- this is a structural property of the construction

### Stronger alternative: Prove Set.Icc is finite directly from the construction

If we can prove that for any a, b in LimitDomSubtype, there are only finitely many domain points between them, then:
- `not_injective_infinite_finite` gives contradiction with the injective succ-orbit
- OR: `LocallyFiniteOrder` gives `IsSuccArchimedean` for free (Mathlib's instance)

The finiteness of Icc might follow from:
- Each omega-chain stage has finitely many points in [a.val, b.val]
- Points are only added when needed (for C4/C5 resolution)
- In the discrete case, C4 is blocked, and C5 adds at most one point per stage
- But there are infinitely many stages, so infinitely many points could accumulate

**CRITICAL QUESTION FOR THE TEAM**: Is `Set.Icc a b` finite for `LimitDomSubtype` in the discrete case? If yes, the proof is straightforward. If no, the convergence argument needs a construction-specific ingredient.

### The Mathlib API is complete for either approach

Regardless of which proof strategy is used, the Mathlib API has all the required tools:

| Tool | Mathlib Name | Status |
|------|-------------|--------|
| Monotone convergence (increasing) | `Real.tendsto_of_bddAbove_monotone` | Available, imported |
| Monotone convergence (decreasing) | `Real.tendsto_of_bddBelow_antitone` | Available, imported |
| Rat cast order preservation | `Rat.cast_le`, `Rat.cast_lt`, `Rat.cast_mono` | Available, imported |
| Decompose convergence | `tendsto_order` | Available, imported |
| Eventually → exists | `Filter.eventually_atTop` | Available, imported |
| Compose monotone with antitone | `Monotone.comp_antitone` | Available, imported |
| IsSuccArchimedean from WellFoundedGT | `WellFoundedGT.toIsSuccArchimedean` | Available, imported |
| IsSuccArchimedean from LocallyFiniteOrder | (instance in LinearLocallyFinite) | Available, imported |
| Pigeonhole | `Finite.exists_ne_map_eq_of_infinite` | Available via `Mathlib.Data.Fintype.Pigeonhole` |
| Succ collision implies max | `Order.isMax_iterate_succ_of_eq_of_ne` | Available, imported |

### Recommended path forward

**If Icc is finite**: Use the Mathlib pigeonhole pattern directly (adapt from `LinearLocallyFinite.lean:166`). This is ~30 lines and avoids all convergence machinery.

**If Icc is infinite**: The convergence proof needs an additional ingredient from the chronicle construction. The plan's proof sketch has a gap in the contradiction step. Recommend investigating whether a construction-specific property (such as "every element is stage-reachable from 0") can bridge the gap.

**Safest approach**: Prove Icc finiteness from the construction, THEN use it for IsSuccArchimedean. The Icc finiteness proof is the real mathematical content; IsSuccArchimedean follows trivially from it.
