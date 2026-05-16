# Blocker Research: good_of_split_at_succ (Phase 2 Sorry)

**Task**: 155 (Reynolds Pipeline Activation)
**Focus**: How to fill the sorry in `good_of_split_at_succ` (line 351 of IntegerModel.lean)
**Date**: 2026-05-16

---

## 1. Reynolds's Argument (Lemma 17, lines 936-953)

Reynolds proves transitivity of ~M as follows. Given a < b < c with a ~M b and b ~M c, show M|[a,c] is very good. Take any subinterval [t,u] of [a,c]:

- If t and u are on the same side of b: clear (subinterval of a very-good interval).
- If b = t or b = u: use a lexicographic sum (trivial case).
- **Hard case**: a <= t < b < u <= c.

For the hard case, Reynolds argues (lines 945-953):

> "First note that since M|[b,c] is very good then it is also good (even if it is not countable). Thus its flow is discrete and there is a successor b + 1 of b. Now M|[t,b] and M|[b+1,u] are both good. Choose Z1 ~k M|[t,b] and Z2 ~k M|[b+1,u] each with flow a subset of Z. Then we know that M|[t,u] ~k Z1 + Z2 whose flow is isomorphic to an interval of Z itself."

**Critical observation**: Reynolds DOES use the successor b+1. He derives its existence from the fact that good structures have discrete flows (since they're k-equiv to Z-intervals, and k-equiv at depth >= 3 preserves discreteness). But he absolutely relies on splitting at a definite element b+1.

---

## 2. Why SuccOrder Is Appropriate for Phase 2

The current signature of `contemp_equiv_is_equiv` is:
```lean
theorem contemp_equiv_is_equiv (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [NoMaxOrder M.carrier] :
    Equivalence (contemp_equiv sig k M)
```

This `[SuccOrder M.carrier]` is appropriate because:

1. **Reynolds's Theorem 15 context**: The structure M is explicitly assumed to have a "countable, discrete" flow without endpoints (line 840). Discrete linear orders without endpoints have SuccOrder.

2. **Phase 4 doesn't affect Phase 2**: Phase 4 removes SuccOrder from `very_good_implies_good` (Lemma 16), which is a DIFFERENT theorem. Lemma 17 (`contemp_equiv_is_equiv`) is about an arbitrary discrete structure and rightly assumes SuccOrder.

3. **The final application**: `chronicle_is_good` applies to the chronicle, which IS order-isomorphic to Z and therefore HAS SuccOrder. The pipeline is: chronicle has SuccOrder -> `one_class` gives very_good -> `very_good_implies_good` gives good. Phase 4's innovation is that `very_good_implies_good` doesn't need SuccOrder (it uses cofinal sequences instead), but `one_class` and `contemp_equiv_is_equiv` still have it.

**Conclusion**: Keep `[SuccOrder M.carrier]` in `good_of_split_at_succ` and `contemp_equiv_is_equiv`. The sorry should be filled using the SuccOrder infrastructure that's already available.

---

## 3. Existing Infrastructure Analysis

### 3.1 `orderedSum` (NEquivalence.lean:122)

```lean
noncomputable def orderedSum (sig : MonadicSignature) (I : Type) [LinearOrder I]
    (ms : I → OrderedMonadicStructure sig) : OrderedMonadicStructure sig where
  carrier := Sigma fun i => (ms i).carrier
  interp := fun p x => (ms x.1).interp p x.2
  carrier_order := Sigma.Lex.linearOrder  -- lexicographic on (I, component)
```

The carrier is `Sigma fun i => (ms i).carrier`, ordered lexicographically: first by the index `i : I`, then within each component by that component's order.

### 3.2 `doets_lemma_1_4` (OrderedSum.lean:34)

```lean
theorem doets_lemma_1_4 (sig : MonadicSignature) (k : Nat) (I : Type) [LinearOrder I]
    (m m' : I → OrderedMonadicStructure sig)
    (h_equiv : ∀ i, k_equiv sig k (m i) (m' i)) :
    k_equiv sig k (orderedSum sig I m) (orderedSum sig I m')
```

Takes I-indexed families with pointwise k-equivalence and produces k-equivalence of their ordered sums. **Crucially**: both sums use the SAME index type I.

### 3.3 `subinterval` (MonadicFO.lean:129)

```lean
def OrderedMonadicStructure.subinterval (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (a b : M.carrier) : OrderedMonadicStructure sig where
  carrier := {x : M.carrier // a ≤ x ∧ x ≤ b}
  interp p x := M.interp p x.val
  carrier_order := inferInstance
```

Closed interval `[a,b]` as a subtype with inherited order.

### 3.4 `k_equiv_of_iso` (IntegerModel.lean:97)

```lean
theorem k_equiv_of_iso (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) (f : M.carrier ≃o N.carrier)
    (h_pred : ∀ (p : sig.preds) (x : M.carrier), M.interp p x ↔ N.interp p (f x)) :
    k_equiv sig k M N
```

Order-isomorphic structures with matching predicates are k-equivalent.

---

## 4. Proof Strategy for `good_of_split_at_succ`

### Overview

The proof has three main steps:
1. Construct OrderIso from M|[t,u] to orderedSum Bool (fun i => pieces i)
2. Apply doets_lemma_1_4 to get k-equiv to orderedSum of Z-witnesses
3. Show ordered sum of two Z-intervals is a Z-interval (hence good)

### Step 1: The OrderIso

Need: `M|[t,u] ≃o orderedSum Bool (fun i => if i = false then M|[t,b] else M|[succ b, u])`

**Left-to-right** (`toFun`): Given `x : {z // t ≤ z ∧ z ≤ u}`:
- If `x.val ≤ b`: map to `⟨false, ⟨x.val, ⟨x.property.1, hxb⟩⟩⟩`
- If `¬(x.val ≤ b)` (i.e., `b < x.val`): then `Order.succ b ≤ x.val` (by `Order.succ_le_iff.mpr`). Map to `⟨true, ⟨x.val, ⟨hsucc, x.property.2⟩⟩⟩`

**Right-to-left** (`invFun`): Given element of `Sigma (fun i => ...)`:
- If from `false` component: `⟨val, ⟨h_left.1, le_trans h_left.2 (le_of_lt hbu)⟩⟩` (need `b ≤ u` which follows from `hbu : b < u`)
- If from `true` component: `⟨val, ⟨le_trans htb (le_trans (Order.le_succ b) h_right.1), h_right.2⟩⟩` (need `t ≤ succ b` which follows from `htb : t ≤ b` and `Order.le_succ`)

**Order preservation** (`map_rel_iff'`): The lexicographic order on `Sigma` gives:
- `(false, x) < (true, y)` always (different components, false < true)
- `(false, x) < (false, y)` iff `x < y` in M|[t,b]
- `(true, x) < (true, y)` iff `x < y` in M|[succ b, u]

This matches the original order on M|[t,u] because:
- If x ≤ b and y > b: then x < y in M|[t,u] (since x ≤ b < succ b ≤ y)
- If both ≤ b: relative order preserved
- If both > b: relative order preserved

**Key fact needed**: `∀ x : M|[t,u].carrier, x.val ≤ b ∨ Order.succ b ≤ x.val`

This follows from: for any `x`, either `x ≤ b` or `b < x`. If `b < x`, then `Order.succ b ≤ x` (by `SuccOrder.succ_le_of_lt` in a linear order with NoMaxOrder, specifically `Order.succ_le_iff.mpr`). This is EXACTLY where SuccOrder is essential.

### Step 2: Apply doets_lemma_1_4

With the OrderIso established:
```lean
-- h_left : good sig k (M.subinterval sig t b)
-- h_right : good sig k (M.subinterval sig (Order.succ b) u)
obtain ⟨Z1, hZ1⟩ := h_left   -- Z1 ~k M|[t,b]
obtain ⟨Z2, hZ2⟩ := h_right  -- Z2 ~k M|[succ b, u]

-- pieces := fun i => if i = false then M|[t,b] else M|[succ b, u]
-- witnesses := fun i => if i = false then Z1.toOrdered else Z2.toOrdered

-- doets_lemma_1_4 gives:
-- k_equiv (orderedSum Bool pieces) (orderedSum Bool witnesses)
```

Then compose:
```
M|[t,u] ~k orderedSum Bool pieces    (via k_equiv_of_iso with the OrderIso)
         ~k orderedSum Bool witnesses (via doets_lemma_1_4)
```

### Step 3: Ordered Sum of Two Z-Intervals Is a Z-Interval

Need to show: `good sig k (orderedSum Bool witnesses)`, i.e., the ordered sum of Z1.toOrdered and Z2.toOrdered is k-equiv to some Z-interval.

**Construction**: Given Z1 with bounds [lo1, hi1] and Z2 with bounds [lo2, hi2], construct a single Z-interval Z3 whose carrier is [lo1, hi1 + (hi2 - lo2 + 1)] (shifting Z2 to abut Z1).

More precisely:
- Z1.intervalCarrier = {z : Z | lo1 ≤ z ≤ hi1}
- Z2.intervalCarrier = {z : Z | lo2 ≤ z ≤ hi2}
- Shift: let offset = hi1 + 1 - lo2
- Z3 has lo = lo1, hi = hi2 + offset
- Z3.interp p z = if z ≤ hi1 then Z1.interp p z else Z2.interp p (z - offset)

The OrderIso from `Sigma Bool (fun i => ...)` to Z3.intervalCarrier:
- `(false, z)` with z in Z1 maps to z (identity on left part)
- `(true, z)` with z in Z2 maps to z + offset (shift right part)

This is monotone and bijective. Predicates are preserved by construction.

**But**: This only works cleanly when both Z-intervals have `some` bounds (finite intervals). For the `good_of_split_at_succ` use case, both M|[t,b] and M|[succ b, u] are BOUNDED subintervals (they have both endpoints), so their Z-interval witnesses are necessarily bounded (finite or semi-infinite? Actually a bounded discrete structure is finite, so good via `finite_structures_good`...).

Wait -- actually this raises an important subtlety. If M|[t,b] is a finite subinterval (which it is, since [t,b] in a discrete order with SuccOrder is finite between t and b... but we DON'T have IsSuccArchimedean! Without IsSuccArchimedean, [t,b] might NOT be finite.)

Let me reconsider. Without IsSuccArchimedean, [t,b] could be countably infinite (like Z itself restricted to a non-standard interval). The hypothesis `h_left : good sig k (M.subinterval sig t b)` tells us M|[t,b] ~k Z1 for SOME Z-interval Z1. Z1 could be unbounded.

So the Z-interval concatenation lemma needs to handle all cases (bounded + bounded, bounded + unbounded, etc.). But for the specific use case here, both subintervals are bounded (they have both endpoints t,b and succ b, u respectively), so their Z-witnesses will have flows that are intervals of Z. The concatenation of two Z-intervals is again a Z-interval.

**Simplification**: Actually, we can avoid dealing with general Z-interval concatenation. Since both pieces are BOUNDED (have both a minimum and maximum element), and "good" only requires k-equivalence to SOME Z-interval, we can use a simpler argument:

The ordered sum of the two Z-interval witnesses has carrier = `Sigma Bool (fun i => Z_i.intervalCarrier)` with lexicographic order. This is a linear order. We just need to show it's order-isomorphic to some Z-interval. Since it's a lexicographic sum of two intervals of Z (each nonempty, bounded), it's itself isomorphic to an interval of Z (by the shift-and-glue construction above).

---

## 5. Recommended Refactoring

### Keep the Current Signature

```lean
theorem good_of_split_at_succ (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (t b u : M.carrier) (htb : t ≤ b) (hbu : b < u)
    (h_left : good sig k (M.subinterval sig t b))
    (h_right : good sig k (M.subinterval sig (Order.succ b) u)) :
    good sig k (M.subinterval sig t u)
```

This is correct and faithful to Reynolds. No change needed.

### New Helper Definitions Needed

#### Helper 1: Interval Split OrderIso

```lean
/-- OrderIso decomposing [t,u] into orderedSum of [t,b] and [succ b, u]. -/
noncomputable def interval_split_iso (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (t b u : M.carrier) (htb : t ≤ b) (hbu : b < u) :
    (M.subinterval sig t u).carrier ≃o
      (orderedSum sig Bool (fun i => if i = false
        then M.subinterval sig t b
        else M.subinterval sig (Order.succ b) u)).carrier
```

#### Helper 2: Z-Interval Concatenation

```lean
/-- The ordered sum of two bounded Z-interval structures is good
    (k-equiv to a single Z-interval). -/
theorem z_interval_sum_good (sig : MonadicSignature) (k : Nat)
    (Z1 Z2 : ZIntervalStructure sig)
    (h1_lo : Z1.lo.isSome) (h1_hi : Z1.hi.isSome)
    (h2_lo : Z2.lo.isSome) (h2_hi : Z2.hi.isSome)
    (h1_ne : Nonempty Z1.intervalCarrier)
    (h2_ne : Nonempty Z2.intervalCarrier) :
    good sig k (orderedSum sig Bool (fun i =>
      if i = false then Z1.toOrdered sig else Z2.toOrdered sig))
```

### Alternative: Bypass doets_lemma_1_4 Entirely

A simpler approach that avoids constructing the OrderIso to `orderedSum`:

**Direct k-equiv via "glue" strategy**: Show M|[t,u] ~k Z3 directly by constructing Z3 as the glued Z-interval and building the k-equivalence proof by composing the two k-equivalences on the left and right halves.

However, this "direct glue" would essentially re-prove doets_lemma_1_4 for the special case I = Bool. Since doets_lemma_1_4 is already proved, using it is more principled.

### Recommended Approach: Simpler Version Without doets_lemma_1_4

Actually, there is an even simpler approach that avoids BOTH the OrderIso to orderedSum AND doets_lemma_1_4:

**Key insight**: Both `M|[t,b]` and `M|[succ b, u]` are good. We have Z1 ~k M|[t,b] and Z2 ~k M|[succ b, u]. We want M|[t,u] to be good. The cleanest proof:

1. Construct Z3 (the glued Z-interval) directly
2. Construct a predicate-preserving OrderIso from M|[t,u] to (orderedSum sig Bool pieces).carrier -- no, that still needs the OrderIso.

Actually the OrderIso approach IS the right one. Let me lay out the cleanest implementation path.

---

## 6. Concrete Implementation Plan

### Step-by-step proof of `good_of_split_at_succ`:

```lean
theorem good_of_split_at_succ (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (t b u : M.carrier) (htb : t ≤ b) (hbu : b < u)
    (h_left : good sig k (M.subinterval sig t b))
    (h_right : good sig k (M.subinterval sig (Order.succ b) u)) :
    good sig k (M.subinterval sig t u) := by
  -- Extract Z-interval witnesses
  obtain ⟨Z1, hZ1⟩ := h_left
  obtain ⟨Z2, hZ2⟩ := h_right
  -- Define the two-piece decomposition indexed by Bool
  let pieces : Bool → OrderedMonadicStructure sig :=
    fun i => if i = false then M.subinterval sig t b
             else M.subinterval sig (Order.succ b) u
  let witnesses : Bool → OrderedMonadicStructure sig :=
    fun i => if i = false then Z1.toOrdered sig else Z2.toOrdered sig
  -- Step 1: M|[t,u] ~k orderedSum Bool pieces (via OrderIso)
  have h_iso_equiv : k_equiv sig k (M.subinterval sig t u) (orderedSum sig Bool pieces) :=
    k_equiv_of_iso sig k _ _ (interval_split_iso sig M t b u htb hbu) (by
      intro p x; simp [pieces, orderedSum, interval_split_iso]
      -- predicates are preserved by construction
      sorry)
  -- Step 2: orderedSum Bool pieces ~k orderedSum Bool witnesses (via doets_lemma_1_4)
  have h_pieces_equiv : ∀ i, k_equiv sig k (pieces i) (witnesses i) := by
    intro i; cases i
    · exact hZ2  -- true case
    · exact hZ1  -- false case
  have h_sum_equiv := doets_lemma_1_4 sig k Bool pieces witnesses h_pieces_equiv
  -- Step 3: orderedSum Bool witnesses is good (Z-interval concatenation)
  have h_sum_good : good sig k (orderedSum sig Bool witnesses) :=
    z_interval_sum_good sig k Z1 Z2 ...
  -- Compose: M|[t,u] ~k orderedSum pieces ~k orderedSum witnesses ~k Z3
  obtain ⟨Z3, hZ3⟩ := h_sum_good
  exact ⟨Z3, h_iso_equiv.trans (h_sum_equiv.trans hZ3)⟩
```

### The OrderIso Construction (interval_split_iso)

```lean
noncomputable def interval_split_iso (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (t b u : M.carrier) (htb : t ≤ b) (hbu : b < u) :
    (M.subinterval sig t u).carrier ≃o
      (orderedSum sig Bool (fun i => if i = false
        then M.subinterval sig t b
        else M.subinterval sig (Order.succ b) u)).carrier where
  toEquiv := {
    toFun := fun ⟨x, htx, hxu⟩ =>
      if hxb : x ≤ b then
        ⟨false, ⟨x, htx, hxb⟩⟩
      else
        have hbx : b < x := lt_of_not_le hxb
        have hsx : Order.succ b ≤ x := Order.succ_le_iff.mpr hbx
        ⟨true, ⟨x, hsx, hxu⟩⟩
    invFun := fun ⟨i, elem⟩ =>
      match i with
      | false => let ⟨x, htx, hxb⟩ := elem
                 ⟨x, htx, le_trans hxb (le_of_lt hbu)⟩
      | true  => let ⟨x, hsx, hxu⟩ := elem
                 ⟨x, le_trans htb (le_trans (Order.le_succ b) hsx), hxu⟩
    left_inv := by
      intro ⟨x, htx, hxu⟩
      simp only
      split
      · -- x ≤ b case: reconstruct
        simp [Subtype.ext_iff]
      · -- x > b case: reconstruct  
        simp [Subtype.ext_iff]
    right_inv := by
      intro ⟨i, elem⟩
      cases i with
      | false =>
        simp only
        have hxb : elem.val ≤ b := elem.property.2
        simp [dif_pos hxb, Sigma.ext_iff, Subtype.ext_iff]
      | true =>
        simp only
        have hxb : ¬(elem.val ≤ b) := by
          push_neg
          exact lt_of_lt_of_le (Order.lt_succ_iff.mpr le_rfl)
            elem.property.1 -- succ b ≤ elem.val, and b < succ b
          -- actually: b < Order.succ b ≤ elem.val
        simp [dif_neg hxb, Sigma.ext_iff, Subtype.ext_iff]
  }
  map_rel_iff' := by
    intro ⟨x, htx, hxu⟩ ⟨y, hty, hyu⟩
    -- Need to show: x < y ↔ image(x) < image(y) in Sigma.Lex
    simp only
    -- Case split on whether x ≤ b and y ≤ b
    by_cases hxb : x ≤ b <;> by_cases hyb : y ≤ b
    · -- Both ≤ b: same false component, compare directly
      simp [dif_pos hxb, dif_pos hyb, Sigma.Lex.lt_def]
      exact Iff.rfl
    · -- x ≤ b, y > b: (false, _) < (true, _) always in Lex
      simp [dif_pos hxb, dif_neg hyb, Sigma.Lex.lt_def]
      constructor
      · intro _; left; exact Bool.false_lt_true
      · intro _; exact lt_of_le_of_lt hxb (lt_of_not_le hyb)
    · -- x > b, y ≤ b: (true, _) vs (false, _), never <
      simp [dif_neg hxb, dif_pos hyb, Sigma.Lex.lt_def]
      constructor
      · intro hxy; exact absurd (le_of_lt hxy) (not_le.mpr (lt_of_le_of_lt hyb (lt_of_not_le hxb)))
      · intro h; cases h with
        | inl h => exact absurd h (not_lt.mpr (Bool.true_le))
        | inr h => exact absurd h.1 (Ne.symm (Bool.noConfusion))  -- true ≠ false
    · -- Both > b: same true component, compare directly
      simp [dif_neg hxb, dif_neg hyb, Sigma.Lex.lt_def]
      exact Iff.rfl
```

**Note**: The exact Lean syntax for `Sigma.Lex.lt_def` may differ. The key property is that in `Sigma.Lex` with `Bool` index (where `false < true`):
- `⟨false, a⟩ < ⟨true, b⟩` always
- `⟨true, a⟩ < ⟨false, b⟩` never  
- Same index: compare components

### The Z-Interval Concatenation

```lean
/-- Concatenation of two bounded Z-intervals yields a Z-interval. -/
theorem z_interval_sum_good (sig : MonadicSignature) (k : Nat)
    (Z1 Z2 : ZIntervalStructure sig)
    (h1_bdd : Z1.lo.isSome ∧ Z1.hi.isSome)
    (h2_bdd : Z2.lo.isSome ∧ Z2.hi.isSome) :
    good sig k (orderedSum sig Bool (fun i =>
      if i = false then Z1.toOrdered sig else Z2.toOrdered sig)) := by
  -- Extract bounds
  obtain ⟨lo1, hlo1⟩ := Option.isSome_iff_exists.mp h1_bdd.1
  obtain ⟨hi1, hhi1⟩ := Option.isSome_iff_exists.mp h1_bdd.2
  obtain ⟨lo2, hlo2⟩ := Option.isSome_iff_exists.mp h2_bdd.1
  obtain ⟨hi2, hhi2⟩ := Option.isSome_iff_exists.mp h2_bdd.2
  -- Construct Z3: single Z-interval covering both
  let offset : ℤ := hi1 + 1 - lo2
  let Z3 : ZIntervalStructure sig := {
    lo := some lo1
    hi := some (hi2 + offset)
    interp := fun p z =>
      if z ≤ hi1 then Z1.interp p z
      else Z2.interp p (z - offset)
  }
  refine ⟨Z3, ?_⟩
  -- Build OrderIso from orderedSum to Z3.intervalCarrier
  -- (false, z) with lo1 ≤ z ≤ hi1  -->  z
  -- (true, z) with lo2 ≤ z ≤ hi2   -->  z + offset
  -- This is monotone, bijective, and preserves predicates.
  apply k_equiv_of_iso sig k _ _ ?iso ?pred
  case iso => sorry -- OrderIso construction (shift-and-glue)
  case pred => sorry -- Predicate preservation (by construction of Z3.interp)
```

---

## 7. Handling the "Bounded Z-Witnesses" Question

**Problem**: When we extract `⟨Z1, hZ1⟩ := h_left`, we only know Z1 is SOME Z-interval with `k_equiv sig k (M.subinterval sig t b) (Z1.toOrdered sig)`. We need to know Z1 has bounded carrier (both lo and hi are `some`).

**Why this should be true**: M|[t,b] has both a minimum (t) and maximum (b). At k >= 3, k-equivalence preserves "has a minimum" and "has a maximum" (these are expressible in monadic FO of depth 1). Therefore Z1 must also have both endpoints.

**Needed lemma**:
```lean
/-- If M has a minimum and maximum, and M ~k Z (with k >= 2), then Z has bounded carrier. -/
theorem z_witness_bounded_of_bounded (sig : MonadicSignature) (k : Nat) (hk : 2 ≤ k)
    (M : OrderedMonadicStructure sig) (Z : ZIntervalStructure sig)
    (h_min : ∃ m : M.carrier, ∀ x, m ≤ x)
    (h_max : ∃ m : M.carrier, ∀ x, x ≤ m)
    (h_equiv : k_equiv sig k M (Z.toOrdered sig)) :
    Z.lo.isSome ∧ Z.hi.isSome
```

**Alternative (simpler)**: Since M|[t,b] is a bounded subinterval of a discrete order with SuccOrder, it's actually FINITE (between any two elements in a SuccOrder-with-no-gaps, there are finitely many elements... but wait, we don't have IsSuccArchimedean!).

Without IsSuccArchimedean, the interval [t,b] might be infinite even in a SuccOrder. For example, consider a non-standard model of PA -- it has SuccOrder but intervals can be infinite.

So we CANNOT assume M|[t,b] is finite. The `z_witness_bounded_of_bounded` lemma is the right approach: use the fact that k-equiv preserves endpoints.

**Even simpler alternative**: Skip the boundedness requirement. Just prove the concatenation for arbitrary Z-intervals:

```lean
/-- The ordered sum of two Z-intervals (indexed by Bool) is good. -/
theorem z_interval_ordered_sum_good (sig : MonadicSignature) (k : Nat)
    (Z1 Z2 : ZIntervalStructure sig) :
    good sig k (orderedSum sig Bool (fun i =>
      if i = false then Z1.toOrdered sig else Z2.toOrdered sig))
```

This is harder to prove in general (needs to handle unbounded cases) but avoids the `z_witness_bounded_of_bounded` lemma. However, for the specific use case, we can observe:

- M|[t,b] has minimum t and maximum b
- Therefore Z1 must have both bounds (preserved by k-equiv at depth >= 2)
- Similarly for Z2

---

## 8. Alternative Approach: Half-Open Interval (Without SuccOrder)

If one wanted to remove SuccOrder entirely from `good_of_split_at_succ`, one could:

1. Define `openLeftSubinterval`:
```lean
def OrderedMonadicStructure.openLeftSubinterval (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) (a b : M.carrier) : OrderedMonadicStructure sig where
  carrier := {x : M.carrier // a < x ∧ x ≤ b}
  interp p x := M.interp p x.val
  carrier_order := inferInstance
```

2. Show M|[t,u] decomposes as orderedSum of M|[t,b] and M|(b,u] without needing successor.

3. Show (b,u] is good because it's a "sub-structure" of M|[b,u] (which is very good, hence any restriction is good).

**Problem with this approach**: `doets_lemma_1_4` requires both sums to use the SAME index type and the SAME decomposition. We'd need to show (b,u] ~k some Z-interval. But (b,u] is not a `subinterval` in the existing sense (it uses strict lower bound). We'd need to extend `good_of_very_good_subinterval` to handle open-left intervals, or prove that (b,u] is k-equiv to a closed subinterval [min (b,u], u].

The cleanest way: `(b,u]` is order-isomorphic to `[min_element, u]` where `min_element` is the least element strictly greater than b (if it exists). In a SuccOrder, min_element = Order.succ b. Without SuccOrder, it might not exist (e.g., if the order is dense between b and something above b).

**Conclusion**: The half-open approach DOESN'T work without SuccOrder because (b,u] might not have a minimum element in a general linear order, and if it doesn't, it's not clear how to show it's "good" (good structures are k-equiv to Z-intervals, which are discrete and hence have a minimum if bounded below).

---

## 9. Final Recommendation

**Keep `[SuccOrder M.carrier]` in `good_of_split_at_succ`.** This is faithful to Reynolds (who derives discreteness from goodness, but the structure IS discrete) and appropriate for Phase 2's context.

**Implementation requires three new lemmas**:

1. `interval_split_iso` -- OrderIso from [t,u] to ordered sum of [t,b] and [succ b, u]
2. `z_witness_bounded_of_bounded` -- good structures with endpoints have bounded Z-witnesses (OR skip this and use a more general concatenation)
3. `z_interval_sum_good` -- ordered sum of two Z-intervals is good

**Estimated complexity**: The OrderIso is the most tedious part (case analysis on Sigma.Lex ordering). The Z-interval concatenation is conceptually straightforward but requires careful arithmetic on Z bounds.

**Suggested factoring**: Extract `interval_split_iso` and `z_interval_sum_good` as separate lemmas (not inlined in the proof). This keeps `good_of_split_at_succ` itself clean and makes each piece independently testable.

---

## 10. Open Question: Interaction with Phase 4

Phase 4 removes SuccOrder from `very_good_implies_good`. This does NOT affect `good_of_split_at_succ` because:
- `very_good_implies_good` doesn't call `good_of_split_at_succ`
- `good_of_split_at_succ` is called only from `contemp_equiv_is_equiv` (transitivity)
- `contemp_equiv_is_equiv` retains `[SuccOrder M.carrier]` in the plan

The dependency chain is:
```
chronicle_is_good
  ← one_class [SuccOrder, PredOrder, NoMax, NoMin, IsSuccArchimedean]
    ← contemp_equiv_is_equiv [SuccOrder, NoMaxOrder]
      ← good_of_split_at_succ [SuccOrder, NoMaxOrder]
  ← very_good_implies_good [Countable, NoMax, NoMin, Nonempty] (Phase 4: NO SuccOrder)
```

Phase 4 replaces `chronicle_is_good`'s current proof (which uses `orderIsoIntOfLinearSuccPredArch` directly) with `one_class + very_good_implies_good`. Since the chronicle HAS SuccOrder, `one_class` can use it. Then `very_good_implies_good` doesn't need it.

So `good_of_split_at_succ` with `[SuccOrder]` is compatible with the full plan.
