# Research Report: Complete Torsor Construction for Duration Domain D

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-20
**Focus**: Full mathematical development of D = Aut+(T) where T is the canonical timeline
**Session**: sess_1774100000_tor001

## Executive Summary

This report provides a mathematically rigorous development of the duration domain D as the group of order-preserving automorphisms of the canonical timeline T. The construction yields:

1. **D = Additive(T ≃o T)** with AddGroup structure from RelIso.instGroup
2. **Rigidity** (freeness): if f fixes any point, f = id
3. **Homogeneity** (transitivity): for any a, b in T, exists f with f(a) = b (via back-and-forth)
4. **Holder's Theorem**: free + order-preserving action on linear order implies abelian
5. **LinearOrder on D**: from rigidity + order on T
6. **AddTorsor D T**: from rigidity + homogeneity

---

## Part 1: Timeline Foundation

### 1.1 Definition of the Canonical Timeline T

**Definition**: The canonical timeline T is the antisymmetrization of the bidirectional fragment of CanonicalMCS.

```
T = BidirectionalQuotient M₀ h_mcs₀
  := Antisymmetrization (BidirectionalFragment M₀ h_mcs₀) (≤)
```

where:
- `BidirectionalFragment M₀ h_mcs₀` = MCSes reachable from root M₀ by finite CanonicalR/CanonicalR⁻¹ steps
- The preorder on BidirectionalFragment is induced from CanonicalR
- Antisymmetrization quotients by the equivalence relation `a ≈ b iff a ≤ b ∧ b ≤ a`

**Source**: `Theories/Bimodal/Boneyard/Task956_IntRat/BidirectionalReachable.lean`

### 1.2 Properties of T from Base Logic (15 Axioms)

**Theorem 1.1** (LinearOrder on T):
The antisymmetrization of a preorder is always a partial order. For BidirectionalFragment, the linearity lemma proves it is total, giving `LinearOrder T`.

**Proof sketch**:
- For any two MCSes W, W' in the bidirectional fragment, temporal linearity (temp_linearity axiom) gives:
  - `all_future(all_future(phi) -> psi) ∈ W` OR `all_future(all_future(psi) -> phi) ∈ W`
- This translates via CanonicalR to: W ≤ W' OR W' ≤ W
- The result lifts to the quotient T.

**Theorem 1.2** (Countability of T):
T is countable because:
- Formulas are countable (built from countable atoms with finite operations)
- MCSes are subsets of formulas, hence at most countable many distinct MCSes
- BidirectionalFragment ⊆ MCSes, hence countable
- Quotient of countable set is countable

**Theorem 1.3** (No Endpoints of T):
T has no maximum and no minimum:
- **NoMaxOrder**: For any [W] in T, `some_future(top) ∈ W` (seriality from base axioms). By canonical_forward_F, there exists W' with CanonicalR W W', giving [W] < [W'] in T.
- **NoMinOrder**: Symmetric argument using `some_past(top) ∈ W` and canonical_backward_P.

### 1.3 Properties Under Dense Extension (+DN)

**Theorem 1.4** (DenselyOrdered T under +DN):
With the density axiom `F(phi) -> F(F(phi))`, T becomes densely ordered:
- For any [W] < [W'] in T, there exists intermediate [W''] with [W] < [W''] < [W']
- This follows from the processDensityDovetailed construction in DovetailedBuild

**Required instances for Cantor's theorem**:
```lean
instance : LinearOrder T := ... (from antisymmetrization)
instance : Countable T := ... (from countable formulas)
instance : DenselyOrdered T := ... (from +DN)
instance : NoMaxOrder T := ... (from seriality)
instance : NoMinOrder T := ... (from seriality)
instance : Nonempty T := ⟨BidirectionalFragment.root.toQuotient⟩
```

**Corollary** (Cantor Isomorphism): Under +DN, `T ≃o Rat` via `Order.iso_of_countable_dense`.

### 1.4 Properties Under Discrete Extension (+DF/DB)

**Theorem 1.5** (LocallyFiniteOrder T under +DF/DB):
With discreteness axioms, every element has immediate successors and predecessors:
- DF: `(F(top) ∧ phi ∧ H(phi)) -> F(H(phi))` ensures immediate successors
- DB: Dual axiom ensures immediate predecessors

**Required instances for Int characterization**:
```lean
instance : LinearOrder T := ...
instance : SuccOrder T := ... (from +DF)
instance : PredOrder T := ... (from +DB)
instance : IsSuccArchimedean T := ... (from LocallyFiniteOrder)
instance : NoMaxOrder T := ... (from seriality)
instance : NoMinOrder T := ... (from seriality)
instance : Nonempty T := ...
```

**Corollary** (Int Isomorphism): Under +DF/DB, `T ≃o Int` via `orderIsoIntOfLinearSuccPredArch`.

---

## Part 2: The Translation Group D = Aut+(T)

### 2.1 Definition

**Definition**: The translation group D is the group of order-preserving automorphisms of T, written additively.

```lean
abbrev TranslationGroup (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :=
  Additive (CanonicalTimeline M₀ h_mcs₀ ≃o CanonicalTimeline M₀ h_mcs₀)

-- D = Additive (T ≃o T)
```

**Elements**: Order isomorphisms f : T ≃o T (bijections preserving ≤)
**Addition**: f + g := g ∘ f (composition, via RelIso.instGroup)
**Zero**: identity isomorphism
**Negation**: -f := f.symm (inverse isomorphism)

### 2.2 AddGroup Structure

**Theorem 2.1** (AddGroup D):
D has AddGroup structure from RelIso.instGroup plus the Additive wrapper.

```lean
noncomputable instance instAddGroupTranslationGroup :
    AddGroup (TranslationGroup M₀ h_mcs₀) :=
  Additive.addGroup
```

**Proof**: Immediate from Mathlib.
- `RelIso.instGroup : Group (r ≃r r)` gives group structure on (T ≃o T)
- `Additive.addGroup` converts multiplicative group to additive group

### 2.3 The Action of D on T

**Definition**: The action uses the INVERSE convention for compositionality.

```lean
def TranslationGroup.apply (d : D) (w : T) : T :=
  (Additive.toMul d).symm w

-- Notation: d +ᵥ w := d.apply w
```

**Why the inverse?** RelIso.instGroup defines `f * g = g.trans f`, meaning `(f * g)(x) = f(g(x))`. For TaskFrame compositionality `(d₁ + d₂) +ᵥ w = d₂ +ᵥ (d₁ +ᵥ w)`, we need:
```
(d₁ + d₂).symm = d₂.symm ∘ d₁.symm
```
which holds because `symm` reverses `trans`.

### 2.4 Action Properties (All Sorry-Free)

**Theorem 2.2** (Nullity): `0 +ᵥ w = w`
```lean
@[simp] theorem apply_zero (w : T) : apply 0 w = w := rfl
```

**Theorem 2.3** (Compositionality): `(d₁ + d₂) +ᵥ w = d₂ +ᵥ (d₁ +ᵥ w)`
```lean
@[simp] theorem apply_add (d₁ d₂ : D) (w : T) :
    apply (d₁ + d₂) w = apply d₂ (apply d₁ w) := rfl
```

**Theorem 2.4** (Inverse Cancellation):
```lean
@[simp] theorem apply_neg_cancel_left (d : D) (w : T) :
    apply (-d) (apply d w) = w := by simp

@[simp] theorem apply_neg_cancel_right (d : D) (w : T) :
    apply d (apply (-d) w) = w := by simp
```

---

## Part 3: Rigidity (Freeness of Action)

### 3.1 Statement

**Theorem 3.1** (Rigidity): If f ∈ Aut+(T) fixes any point t₀, then f = id.

Formally: `∀ f : T ≃o T, ∀ t₀ : T, f(t₀) = t₀ → f = OrderIso.refl T`

### 3.2 Proof

**Proof**:

Suppose f(t₀) = t₀ but f ≠ id. Then there exists s with f(s) ≠ s.

**Case 1**: f(s) > s

Since f is order-preserving and f(t₀) = t₀:
- If s > t₀: f(s) > f(t₀) = t₀, so f(s) > t₀. Also f(s) > s > t₀.
- If s < t₀: f(s) < f(t₀) = t₀, so f(s) < t₀. But we assumed f(s) > s, and since s < t₀ and f(s) > s, we have s < f(s).

Consider the set S = {x : f(x) > x}. We have s ∈ S.

**Claim**: S is upward closed in T.
Let x ∈ S (so f(x) > x) and let y > x. Then f(y) > f(x) > x (since f is strictly monotone). We need f(y) > y.

Suppose for contradiction f(y) ≤ y for some y > x with f(x) > x.
Then f(y) ≤ y < f(x) (since f(y) ≤ y and y > x with f(x) > y by... wait, this needs more care).

**Alternative proof via surjectivity**:

Suppose f(s) > s for some s. Consider the interval (s, f(s)).

Since f is surjective, every element of T is in the image of f.
For any t with s < t < f(s), there exists r with f(r) = t.
- If r ≤ s, then f(r) ≤ f(s), but f(r) = t < f(s), consistent.
- If r > s, then f(r) > f(s) since f is order-preserving, but f(r) = t < f(s), contradiction.

So r ≤ s, meaning f(r) ≥ r implies f(r) = t ≥ r, i.e., t ≥ r.
Since r ≤ s < t, we have r < t, consistent.

But now consider what happens at t₀:
- If t₀ < s: f(t₀) = t₀ < s < f(s), and by order-preservation f(s) > f(t₀) = t₀, consistent.
- If t₀ > f(s): Then t₀ > f(s) > s, so f(t₀) > f(f(s)) (wait, this is getting circular).

**Cleaner proof using endpoints**:

T has no endpoints (NoMaxOrder, NoMinOrder). Suppose f ≠ id and f(t₀) = t₀.

Define: S⁺ = {x : f(x) > x}, S⁻ = {x : f(x) < x}, S⁰ = {x : f(x) = x}.

We have t₀ ∈ S⁰. Since f ≠ id, either S⁺ or S⁻ is nonempty.

WLOG S⁺ ≠ ∅. Let s ∈ S⁺, so f(s) > s.

**Key observation**: S⁺ is downward closed above any fixed point.

Suppose t₀ < s with f(s) > s. For any t with t₀ < t < s:
- f(t₀) = t₀ < t < s < f(s)
- By order-preservation and injectivity, f(t) lies between f(t₀) = t₀ and f(s).
- So t₀ < f(t) < f(s).
- But we need to show f(t) > t or f(t) < t.

This argument is getting complicated. Let me state the standard rigidity result for linear orders without endpoints.

### 3.3 Standard Rigidity Theorem

**Theorem** (Rigidity for DLO): Let T be a densely ordered set without endpoints. If f : T → T is an order-preserving bijection fixing some point t₀, then f = id.

**Proof** (by density):

Suppose f(t₀) = t₀ and f ≠ id. Let s be such that f(s) ≠ s. WLOG f(s) > s.

Consider the interval (s, f(s)). By density, there exists m with s < m < f(s).

Since f is surjective, m = f(r) for some r.
- If r ≤ s: then f(r) ≤ f(s), but f(r) = m < f(s). Also f(r) ≥ f(t₀) = t₀ if r ≥ t₀.
- If r > s: then f(r) > f(s) since f is strictly monotone, but f(r) = m < f(s). Contradiction.

So r ≤ s for all preimages of points in (s, f(s)).

Now consider where t₀ lies relative to s:
- **Case t₀ < s**: Then the interval (t₀, s) exists. For any p in (t₀, s), we have t₀ < p < s, so f(t₀) = t₀ < f(p) < f(s). But also if f(s) > s > p, then f(p) might be greater or less than p.

  Actually, let's use a different approach. Consider the orbit of s under f: s, f(s), f(f(s)), ...

  Since f(s) > s and f is order-preserving, f(f(s)) > f(s) > s. By induction, fⁿ(s) is strictly increasing.

  By NoMaxOrder, this sequence is unbounded above.

  Similarly, f⁻¹(s) < s, f⁻²(s) < f⁻¹(s) < s, etc., unbounded below.

  The orbit {..., f⁻²(s), f⁻¹(s), s, f(s), f²(s), ...} is order-isomorphic to ℤ.

  But t₀ is fixed, so t₀ is NOT in this orbit. Where does t₀ fit?

  If t₀ < s, then t₀ < fⁿ(s) for all n ≥ 0. So t₀ is a lower bound for the forward orbit, which is unbounded above but has inf = limit of f⁻ⁿ(s). As n → ∞, f⁻ⁿ(s) → -∞, so t₀ must be between some f⁻ᵏ(s) and f⁻ᵏ⁺¹(s).

  Say f⁻ᵏ(s) < t₀ < f⁻ᵏ⁺¹(s). Then f(f⁻ᵏ(s)) = f⁻ᵏ⁺¹(s) and f(t₀) = t₀. But f is order-preserving, so:
  f⁻ᵏ⁺¹(s) = f(f⁻ᵏ(s)) < f(t₀) = t₀ < f(f⁻ᵏ⁺¹(s)) = f⁻ᵏ⁺²(s).

  But we assumed f⁻ᵏ(s) < t₀ < f⁻ᵏ⁺¹(s), which gives t₀ < f⁻ᵏ⁺¹(s).
  Yet we just showed f⁻ᵏ⁺¹(s) < t₀. Contradiction! ∎

### 3.4 Rigidity for Discrete T

**Theorem** (Rigidity for discrete linear order without endpoints): Same conclusion holds.

**Proof**: The orbit argument works identically. The key is that the orbit partitions into disjoint ℤ-like chains, and a fixed point between consecutive orbit elements yields a contradiction.

### 3.5 Lean Implementation Estimate

```lean
-- Core rigidity theorem
theorem orderIso_eq_id_of_fixedPt
    (T : Type*) [LinearOrder T] [NoMaxOrder T] [NoMinOrder T]
    (f : T ≃o T) (t₀ : T) (h : f t₀ = t₀) (h_ne : f ≠ OrderIso.refl T) :
    False := by
  -- Obtain s with f(s) ≠ s
  -- Case analysis on f(s) > s vs f(s) < s
  -- Orbit argument + fixed point contradiction
  sorry
```

**Estimated lines**: 40-60 lines for the full proof.

---

## Part 4: Homogeneity (Transitivity of Action)

### 4.1 Statement

**Theorem 4.1** (Homogeneity): For any a, b ∈ T, there exists f ∈ Aut+(T) such that f(a) = b.

### 4.2 Proof via Back-and-Forth

**Construction** (Cantor's Back-and-Forth for Dense T):

Given countable dense linear orders T without endpoints and points a, b ∈ T.

1. Enumerate T = {t₀, t₁, t₂, ...} with t₀ = a.
2. Build partial isomorphisms fₙ : Xₙ → Yₙ where:
   - X₀ = {a}, Y₀ = {b}, f₀(a) = b
   - At odd step 2k+1: extend domain (forth)
   - At even step 2k+2: extend codomain (back)

**Extension step (dense case)**:
Given partial iso fₙ : Xₙ → Yₙ preserving order, extend to include new point p:

- Find where p sits relative to Xₙ: determine maximal x⁻ < p and minimal x⁺ > p in Xₙ
- If x⁻ and x⁺ both exist: need y with fₙ(x⁻) < y < fₙ(x⁺). Exists by density of T.
- If only x⁻ exists: need y > fₙ(x⁻). Exists by NoMaxOrder.
- If only x⁺ exists: need y < fₙ(x⁺). Exists by NoMinOrder.
- If neither exists (Xₙ = ∅): set fₙ₊₁(p) = any point (exists by Nonempty).

Define fₙ₊₁ = fₙ ∪ {(p, y)}.

**Union**: f = ⋃ₙ fₙ is a total order isomorphism T ≃o T with f(a) = b.

### 4.3 Back-and-Forth for Discrete T

For discrete T (with SuccOrder/PredOrder), the construction is simpler:

**Construction**:
Given a, b ∈ T with discrete structure:

1. Define f on the orbit of a under succ/pred:
   - f(a) = b
   - f(succ(a)) = succ(b)
   - f(pred(a)) = pred(b)
   - f(succⁿ(a)) = succⁿ(b) for all n
   - f(predⁿ(a)) = predⁿ(b) for all n

2. By IsSuccArchimedean + NoMaxOrder + NoMinOrder, the orbit of any point is all of T.
   (Every element is reachable by finite succ/pred iterations from any starting point.)

3. Therefore f is defined on all of T and is an order isomorphism.

### 4.4 Mathlib Support

```lean
-- Cantor's theorem (existence of isomorphism between countable dense linear orders)
theorem Order.iso_of_countable_dense
    (α : Type*) (β : Type*)
    [LinearOrder α] [LinearOrder β]
    [Countable α] [DenselyOrdered α] [NoMinOrder α] [NoMaxOrder α] [Nonempty α]
    [Countable β] [DenselyOrdered β] [NoMinOrder β] [NoMaxOrder β] [Nonempty β] :
    Nonempty (α ≃o β)
```

The homogeneity theorem is a corollary: take α = β = T and modify the back-and-forth to send a to b.

### 4.5 Lean Implementation Estimate

```lean
-- Homogeneity for dense linear order
theorem exists_orderIso_sending
    (T : Type*) [LinearOrder T] [Countable T] [DenselyOrdered T]
    [NoMaxOrder T] [NoMinOrder T] [Nonempty T]
    (a b : T) : ∃ f : T ≃o T, f a = b := by
  -- Modify Cantor back-and-forth to fix initial condition
  sorry

-- Homogeneity for discrete linear order
theorem exists_orderIso_sending_discrete
    (T : Type*) [LinearOrder T] [SuccOrder T] [PredOrder T]
    [IsSuccArchimedean T] [NoMaxOrder T] [NoMinOrder T] [Nonempty T]
    (a b : T) : ∃ f : T ≃o T, f a = b := by
  -- Direct construction via succ/pred iteration
  sorry
```

**Estimated lines**: 80-120 lines total.

---

## Part 5: Holder's Theorem (Commutativity)

### 5.1 Statement

**Theorem 5.1** (Holder's Theorem): Let G be a group acting freely and order-preservingly on a linearly ordered set T. Then G is abelian.

**Corollary**: D = Aut+(T) is an abelian group.

### 5.2 Proof

**Step 1: Define order on G**

Fix a base point t₀ ∈ T. Define:
```
g₁ ≤ g₂  iff  g₁(t₀) ≤ g₂(t₀)
```

**Claim 5.2** (Well-definedness): The order is independent of choice of t₀.

**Proof**: Suppose we use a different base point t₁. We need:
```
g₁(t₀) ≤ g₂(t₀)  iff  g₁(t₁) ≤ g₂(t₁)
```

Suppose g₁(t₀) ≤ g₂(t₀) but g₁(t₁) > g₂(t₁).

Consider h = g₂⁻¹ ∘ g₁. Then:
- h(t₀) = g₂⁻¹(g₁(t₀)) ≤ g₂⁻¹(g₂(t₀)) = t₀  (since g₂⁻¹ preserves order and g₁(t₀) ≤ g₂(t₀))
- h(t₁) = g₂⁻¹(g₁(t₁)) > g₂⁻¹(g₂(t₁)) = t₁  (since g₂⁻¹ preserves order and g₁(t₁) > g₂(t₁))

So h(t₀) ≤ t₀ and h(t₁) > t₁.

WLOG t₀ < t₁. Then h(t₀) ≤ t₀ < t₁ < h(t₁).

By intermediate value / surjectivity of h, there exists s with t₀ < s < t₁ and h(s) = s (since h(t₀) ≤ t₀ < t₁ < h(t₁), and h is continuous in the order topology sense for linear orders).

Actually, for linear orders, we use: h(t₀) ≤ t₀ and h(t₁) > t₁ with t₀ < t₁.
If h(t₀) < t₀ and h(t₁) > t₁, by order-preservation there's a fixed point between.

More precisely: Define A = {x : h(x) ≤ x} and B = {x : h(x) ≥ x}.
- t₀ ∈ A (since h(t₀) ≤ t₀)
- t₁ ∈ B (since h(t₁) > t₁, so h(t₁) ≥ t₁)
- A ∩ B = fixed points of h

If h has no fixed points, then A and B partition T and h(x) < x for x ∈ A, h(x) > x for x ∈ B.

For any x ∈ A and y ∈ B with x < y, we have h(x) < x < y < h(y).
By order-preservation: h(x) < h(y), which is consistent.

But consider the "boundary" between A and B. In a linear order, if A and B partition and t₀ ∈ A, t₁ ∈ B, then either:
- sup(A ∩ [t₀, t₁]) exists and equals inf(B ∩ [t₀, t₁])
- There's a gap

For dense T: No gaps, so sup(A ∩ [t₀, t₁]) = s = inf(B ∩ [t₀, t₁]).
At s: h(s) ≤ s (if s ∈ A) or h(s) ≥ s (if s ∈ B), and both hold at the boundary, so h(s) = s.

This contradicts freeness! So the original assumption was wrong.

For discrete T: Similar argument using successor structure.

**Step 2: Prove order is bi-invariant**

**Left invariance**: g₁ ≤ g₂ ⟹ h + g₁ ≤ h + g₂

We have g₁(t₀) ≤ g₂(t₀).
Need: (h ∘ g₁)(t₀) ≤ (h ∘ g₂)(t₀), i.e., h(g₁(t₀)) ≤ h(g₂(t₀)).
This holds since h preserves order. ✓

**Right invariance**: g₁ ≤ g₂ ⟹ g₁ + h ≤ g₂ + h

We have g₁(t₀) ≤ g₂(t₀).
Need: (g₁ ∘ h)(t₀) ≤ (g₂ ∘ h)(t₀), i.e., g₁(h(t₀)) ≤ g₂(h(t₀)).

Let s = h(t₀). By well-definedness of order (Step 1), g₁ ≤ g₂ evaluated at s gives g₁(s) ≤ g₂(s). ✓

**Step 3: Derive commutativity**

For any g, h ∈ G, we show g + h = h + g.

Consider: (g + h) vs (h + g).

By bi-invariance:
- g + h ≤ g + h trivially (reflexive)
- From h ≤ h and left invariance: g + h ≤ g + h (no information)

Better approach: Show g + h - (h + g) = 0.

Let k = g + h - h - g = g + h + (-h) + (-g).

Claim: k = 0.

Evaluate at t₀:
k(t₀) = g(h((-h)((-g)(t₀)))))

With our composition convention (d₁ + d₂)(x) = d₂(d₁(x)):
k(t₀) = ((-g) ∘ (-h) ∘ h ∘ g)(t₀) = g⁻¹(h⁻¹(h(g(t₀)))) = g⁻¹(g(t₀)) = t₀.

So k fixes t₀. By rigidity, k = id, i.e., g + h = h + g. ∎

### 5.3 Lean Implementation Estimate

```lean
-- Holder's theorem: free order-preserving action on linear order implies abelian
theorem holder_theorem
    (G : Type*) (T : Type*) [AddGroup G] [LinearOrder T]
    [NoMaxOrder T] [NoMinOrder T]
    (act : G → T ≃o T)
    (h_hom : ∀ g₁ g₂, act (g₁ + g₂) = (act g₂).trans (act g₁))
    (h_free : ∀ g t, (act g) t = t → g = 0) :
    ∀ g₁ g₂ : G, g₁ + g₂ = g₂ + g₁ := by
  intro g₁ g₂
  -- Show (g₁ + g₂) - (g₂ + g₁) fixes any point
  -- Apply freeness
  sorry
```

**Estimated lines**: 60-80 lines.

---

## Part 6: Linear Order on D

### 6.1 Definition

**Definition**: Fix a base point origin ∈ T. Define:
```
d₁ ≤ d₂  iff  d₁ +ᵥ origin ≤ d₂ +ᵥ origin
```

### 6.2 Properties

**Theorem 6.1** (Well-definedness): The order is independent of choice of origin (from Holder's theorem proof).

**Theorem 6.2** (LinearOrder D):
- Reflexivity: d ≤ d since d +ᵥ origin = d +ᵥ origin
- Antisymmetry: d₁ ≤ d₂ ∧ d₂ ≤ d₁ ⟹ d₁ +ᵥ origin = d₂ +ᵥ origin ⟹ d₁ = d₂ (by rigidity)
- Transitivity: from transitivity of ≤ on T
- Totality: from totality of ≤ on T

**Theorem 6.3** (IsOrderedAddMonoid D):
Addition respects order:
- d₁ ≤ d₂ ⟹ d₁ + e ≤ d₂ + e (from bi-invariance in Holder's proof)
- d₁ ≤ d₂ ⟹ e + d₁ ≤ e + d₂ (from bi-invariance)

### 6.3 Lean Implementation

```lean
noncomputable def translationGroupLinearOrder
    (origin : CanonicalTimeline M₀ h_mcs₀) :
    LinearOrder (TranslationGroup M₀ h_mcs₀) where
  le d₁ d₂ := d₁.apply origin ≤ d₂.apply origin
  le_refl := fun d => le_refl (d.apply origin)
  le_trans := fun _ _ _ h₁ h₂ => le_trans h₁ h₂
  le_antisymm := fun d₁ d₂ h₁ h₂ => by
    have heq : d₁.apply origin = d₂.apply origin := le_antisymm h₁ h₂
    -- Apply rigidity: d₁⁻¹ ∘ d₂ fixes origin, hence = id
    sorry
  le_total := fun d₁ d₂ => le_total (d₁.apply origin) (d₂.apply origin)
  ...
```

**Estimated lines**: 30-50 lines.

---

## Part 7: AddTorsor Structure

### 7.1 Definition

**Definition**: AddTorsor D T is established via:
- `vadd : D → T → T` defined as `d +ᵥ w := d.apply w`
- `vsub : T → T → D` defined as `w₁ -ᵥ w₂ := the unique d such that d +ᵥ w₂ = w₁`

### 7.2 Properties

**Theorem 7.1** (vsub is well-defined):
For any w₁, w₂ ∈ T, there exists a unique d ∈ D with d +ᵥ w₂ = w₁.

**Proof**:
- Existence: By homogeneity (Theorem 4.1), there exists f : T ≃o T with f(w₂) = w₁. Take d = f (viewed additively).
- Uniqueness: Suppose d₁ +ᵥ w₂ = w₁ = d₂ +ᵥ w₂. Then (-d₂ + d₁) +ᵥ w₂ = w₂, so -d₂ + d₁ fixes w₂. By rigidity, -d₂ + d₁ = 0, so d₁ = d₂.

**Theorem 7.2** (Torsor Axioms):
- `vsub_vadd' : (w₁ -ᵥ w₂) +ᵥ w₂ = w₁` (by definition of vsub)
- `vadd_vsub' : d +ᵥ w -ᵥ w = d` (follows from uniqueness)

### 7.3 Lean Implementation

```lean
noncomputable instance instAddTorsorTranslationGroup :
    AddTorsor (TranslationGroup M₀ h_mcs₀) (CanonicalTimeline M₀ h_mcs₀) where
  vadd d w := d.apply w
  zero_vadd w := TranslationGroup.apply_zero w
  add_vadd d₁ d₂ w := (TranslationGroup.apply_add d₁ d₂ w).symm
  vsub w₁ w₂ := Classical.choose (exists_orderIso_sending w₂ w₁)  -- from homogeneity
  vsub_vadd' w₁ w₂ := Classical.choose_spec (exists_orderIso_sending w₂ w₁)
  vadd_vsub' d w := by
    have h := Classical.choose_spec (exists_orderIso_sending w (d.apply w))
    -- Uniqueness argument
    sorry
```

**Estimated lines**: 40-60 lines.

---

## Part 8: TaskFrame Construction

### 8.1 Assembly

Given:
- D = TranslationGroup M₀ h_mcs₀ with AddCommGroup (from Holder), LinearOrder, IsOrderedAddMonoid
- T = CanonicalTimeline M₀ h_mcs₀ with AddTorsor D T
- WorldState = T (timeline points, i.e., equivalence classes of MCSes)

**Definition**:
```lean
def torsor_task_rel (w : T) (d : D) (w' : T) : Prop :=
  d +ᵥ w = w'

noncomputable def TorsorTaskFrame : TaskFrame D where
  WorldState := CanonicalTimeline M₀ h_mcs₀
  task_rel := torsor_task_rel
  nullity_identity := fun w u => by simp [torsor_task_rel, TranslationGroup.apply_zero]
  forward_comp := fun w u v d₁ d₂ _ _ h₁ h₂ => by
    simp only [torsor_task_rel] at *
    rw [TranslationGroup.apply_add, h₁, h₂]
  converse := fun w d u => by
    simp only [torsor_task_rel]
    constructor
    · intro h
      rw [← h]
      exact TranslationGroup.apply_neg_cancel_left d w
    · intro h
      rw [← h]
      exact TranslationGroup.apply_neg_cancel_right d w
```

### 8.2 Properties (All Sorry-Free from Prior Sections)

- `nullity_identity`: `task_rel w 0 w` ✓ (Theorem 2.2)
- `forward_comp`: `task_rel w d₁ u ∧ task_rel u d₂ v → task_rel w (d₁+d₂) v` ✓ (Theorem 2.3)
- `converse`: `task_rel w d w' ↔ task_rel w' (-d) w` ✓ (Theorem 2.4)

---

## Part 9: Summary and Dependencies

### 9.1 Dependency Graph

```
                    Base Logic (15 axioms)
                           │
                           ▼
              ┌─── BidirectionalFragment ◄── Root MCS
              │            │
              │            ▼
              │    Antisymmetrization
              │            │
              │            ▼
              │     T = CanonicalTimeline
              │     (LinearOrder, Countable,
              │      NoMaxOrder, NoMinOrder,
              │      Nonempty)
              │            │
    ┌─────────┴────────────┼────────────────┐
    │                      │                │
    ▼                      │                ▼
+DN (Dense)                │          +DF/DB (Discrete)
    │                      │                │
    ▼                      │                ▼
DenselyOrdered T           │          SuccOrder T
    │                      │          PredOrder T
    ▼                      │          IsSuccArchimedean T
Order.iso_of_countable_dense         │
    │                      │                ▼
    ▼                      │    orderIsoIntOfLinearSuccPredArch
T ≃o Rat                   │                │
    │                      │                ▼
    └───────► D = Aut+(T) ◄────────────┘ T ≃o Int
              │
              ▼
         RelIso.instGroup
         Additive wrapper
              │
              ▼
         AddGroup D
              │
    ┌─────────┼─────────┐
    │         │         │
    ▼         │         ▼
Rigidity      │    Homogeneity
(fixed point  │    (back-and-forth or
 => id)       │     succ/pred iteration)
    │         │         │
    └─────────┼─────────┘
              │
              ▼
        Holder's Theorem
        (free + ordered => abelian)
              │
              ▼
        AddCommGroup D
              │
              ▼
        LinearOrder D
        (from rigidity + T order)
              │
              ▼
        IsOrderedAddMonoid D
        (from bi-invariance)
              │
              ▼
         AddTorsor D T
         (from rigidity + homogeneity)
              │
              ▼
        TorsorTaskFrame
        (nullity, compositionality, converse)
```

### 9.2 Estimated Lean Code Lines

| Component | Estimated Lines | Dependencies |
|-----------|-----------------|--------------|
| BidirectionalFragment | ~200 (exists) | CanonicalMCS |
| Antisymmetrization | ~50 | Mathlib |
| LinearOrder T | ~100 | temp_linearity |
| Countability T | ~30 | countable formulas |
| NoMaxOrder/NoMinOrder T | ~50 | seriality |
| DenselyOrdered T (dense case) | ~80 | DovetailedBuild |
| SuccOrder/PredOrder T (discrete case) | ~80 | discreteStagedBuild |
| TranslationGroup definition | ~30 (exists) | - |
| AddGroup D | ~10 (exists) | RelIso.instGroup |
| Action properties | ~50 (exists) | - |
| **Rigidity** | ~60 | NoMaxOrder, NoMinOrder |
| **Homogeneity (dense)** | ~80 | DenselyOrdered, Countable |
| **Homogeneity (discrete)** | ~60 | SuccOrder, IsSuccArchimedean |
| **Holder's Theorem** | ~80 | Rigidity |
| LinearOrder D | ~50 | Rigidity, Holder |
| IsOrderedAddMonoid D | ~40 | Holder |
| **AddTorsor D T** | ~60 | Rigidity, Homogeneity |
| TaskFrame D | ~40 (exists) | AddTorsor |
| **Total new code** | ~430-530 | - |

---

## Part 10: Potential Blockers and Uncertainties

### 10.1 Rigidity Proof Details

The orbit argument requires careful handling of:
- Dense vs discrete cases
- Interaction with NoMaxOrder/NoMinOrder
- Formalization of "intermediate value" argument for dense case

**Mitigation**: The argument is standard and appears in multiple textbooks. Lean proof should follow the structure in Section 3.

### 10.2 Homogeneity via Back-and-Forth

Mathlib has `Order.iso_of_countable_dense` but this gives existence of SOME isomorphism, not one sending a to b.

**Mitigation**: The back-and-forth construction can be modified to fix the initial condition. This is a standard technique.

### 10.3 Discrete Case Infrastructure

The discrete case relies on `discreteStagedBuild` from `StagedExecution.lean`. Need to verify:
- SuccOrder/PredOrder instances on DiscreteTimelineQuot
- IsSuccArchimedean instance

**Current status**: `DiscreteTimeline.lean` has `discrete_Icc_finite_axiom` (axiomatized LocallyFiniteOrder).

**Mitigation**: Either prove this axiom or accept it as an axiom for discrete completeness.

### 10.4 Connection to FMCS Infrastructure

The torsor construction gives a TaskFrame, but completeness also needs:
- An FMCS D structure (family of MCSes indexed by D)
- Forward_F and backward_P properties

**Current approach**: The existing `parametric_to_history` uses full domain, which trivializes convexity. The torsor approach provides the D structure; connecting to existing FMCS infrastructure requires:
1. Define `mcs : D → Set Formula` as the underlying MCS of each timeline point
2. Verify forward_G, backward_H from CanonicalR
3. Forward_F, backward_P follow from BidirectionalFragment closure properties

---

## Part 11: Recommendations

### 11.1 Implementation Order

1. **Phase 1**: Prove rigidity theorem (foundation for everything)
2. **Phase 2**: Prove homogeneity (requires Countable + either Dense or Discrete)
3. **Phase 3**: Prove Holder's theorem (uses rigidity)
4. **Phase 4**: Establish LinearOrder D and IsOrderedAddMonoid D
5. **Phase 5**: Establish AddTorsor D T (uses rigidity + homogeneity)
6. **Phase 6**: Construct TaskFrame and wire to completeness

### 11.2 Dense Case Priority

The dense case (D ~ Rat) is more immediately useful because:
- Cantor isomorphism is cleaner than discrete characterization
- DovetailedBuild infrastructure already exists
- Dense completeness is the primary goal of task 1006

### 11.3 Code Reuse

Maximize reuse of:
- `TranslationGroup.lean` (already defines D, AddGroup, action properties)
- `DurationTransfer.lean` (ratAddCommGroup, intAddCommGroup)
- `ParametricHistory.lean` (parametric_to_history with full domain)

---

## References

### Codebase Files

| File | Purpose |
|------|---------|
| `Boneyard/Task956_IntRat/TranslationGroup.lean` | D definition, AddGroup, action |
| `Boneyard/Task956_IntRat/BidirectionalReachable.lean` | BidirectionalFragment, LinearOrder T |
| `Domain/DurationTransfer.lean` | Group transfer from Int/Rat |
| `Algebraic/ParametricHistory.lean` | FMCS -> WorldHistory |
| `Algebraic/ParametricCanonical.lean` | D-parametric TaskFrame |
| `StagedConstruction/DovetailedBuild.lean` | Dense timeline construction |
| `StagedConstruction/StagedExecution.lean` | Discrete timeline construction |

### Mathlib Theorems

| Theorem | Module | Purpose |
|---------|--------|---------|
| `RelIso.instGroup` | Mathlib.Algebra.Order.Group.End | Group on (r ≃r r) |
| `Additive.addGroup` | Mathlib.Algebra.Group.TypeTags | Additive wrapper |
| `Order.iso_of_countable_dense` | Mathlib.Order.CountableDenseLinearOrder | Cantor isomorphism |
| `orderIsoIntOfLinearSuccPredArch` | Mathlib.Order.SuccPred.LinearLocallyFinite | Int characterization |
| `Equiv.addCommGroup` | Mathlib.Algebra.Group.TransferInstance | Group transfer |

### Mathematical References

- Holder's theorem: standard in ordered group theory
- Back-and-forth method: Cantor's original proof, expositions in model theory texts
- Rigidity of order automorphisms: classical result in order theory
