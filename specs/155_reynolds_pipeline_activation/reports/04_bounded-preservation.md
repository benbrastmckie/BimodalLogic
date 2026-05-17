# Research Report: Bounded Preservation via k-equiv

## Summary

"Has a maximum element" is expressible at quantifier depth **2** in the monadic FO language over linear orders. Therefore, k-equiv at k >= 2 preserves "has max" via `doets_lemma_1_1`. For k = 1, "has max" is NOT preserved (demonstrated by counterexample), but the sorry at line 470 can still be closed because the `orderedSum Bool witnesses` can be proved good at depth 1 via a direct finite-interval construction.

---

## 1. Expressibility Analysis

### 1.1 AtomKind at each variable count

From `NormalForm.lean` lines 58-60:
```lean
inductive AtomKind (sig : MonadicSignature) (n : Nat) : Type where
  | pred (p : sig.preds) (i : Fin n) : AtomKind sig n
  | order (i j : Fin n) (h : i ≠ j) : AtomKind sig n
```

Key facts:
- `AtomKind sig 0` is **empty** (no `Fin 0` elements)
- `AtomKind sig 1` has only `pred` atoms (one variable, but `order` needs TWO distinct variables)
- `AtomKind sig 2` has `pred` atoms AND `order` atoms (`order 0 1 h` and `order 1 0 h'`)

### 1.2 "Has max" as a formula

"Has a maximum element" = `exists x. forall y. not (x < y)`

In De Bruijn encoding (after `exists x`, x is var 0; after `forall y`, y is var 0, x is var 1):
```lean
MonadicFormula.ex (MonadicFormula.all (MonadicFormula.not (MonadicFormula.lt 1 0)))
```

Quantifier depth computation:
- `.lt 1 0` : depth 0
- `.not (.lt 1 0)` : depth 0
- `.all (.not (.lt 1 0))` : depth 0 + 1 = **1**
- `.ex (.all (.not (.lt 1 0)))` : depth 1 + 1 = **2**

**Conclusion: "has max" has quantifier depth 2.**

### 1.3 NF perspective

At depth 1 with 0 free variables, the 1-type records which depth-0 1-variable NFs are realized. Depth-0 1-var NFs (`AtomKind sig 1 -> Bool`) only have predicate atoms — no order information. So **1-types cannot distinguish bounded from unbounded structures**.

At depth 2, the 2-type records which depth-1 1-variable NFs exist. A depth-1 1-var NF of element x records which depth-0 2-var NFs are realized when adding another element y. The depth-0 2-var NFs include `order 0 1` (y < x) and `order 1 0` (x < y). A maximum element x has the property that NO depth-0 2-var NF with `order 1 0 = true` is realized — this is captured in its depth-1 NF. **So "has max" IS distinguished at depth 2.**

### 1.4 Counterexample at depth 1

Take `sig` with 0 predicates. Then:
- `{0}` (single-point Z-interval [0,0]): has a maximum
- `Z` (all integers, no bounds): has no maximum

Both have the same 1-type: `AtomKind sig 1` is empty (no predicates), so there's exactly one depth-0 1-var NF (the empty truth assignment), realized in both structures.

Therefore `k_equiv sig 1 {0} Z` holds, but {0} has max and Z doesn't. QED: 1-equiv does NOT preserve "has max".

---

## 2. Preservation Theorem

### 2.1 For k >= 2 (clean case)

By `doets_lemma_1_1` (already proved in NormalForm.lean line 433):

```lean
theorem doets_lemma_1_1 : ... 
    ∀ (n : Nat) (phi : MonadicFormula sig n) (_h_depth : phi.quantifier_depth ≤ k)
    (M N : OrderedMonadicStructure sig)
    (env_M : Fin n �� M.carrier) (env_N : Fin n → N.carrier)
    (h_same_nf : ∀ nf : NormalForm sig k n,
      nf_eval_nf M k n env_M nf ↔ nf_eval_nf N k n env_N nf),
    (eval M env_M phi ↔ eval N env_N phi)
```

Combined with `k_equiv` definition: if `k_equiv sig k M N` and `k >= 2`, then `M` and `N` agree on all sentences of depth <= k, which includes "has max" (depth 2).

**Specific lemma to construct:**
```lean
/-- k-equiv at depth k ≥ 2 preserves "has maximum element". -/
theorem k_equiv_preserves_has_max (sig : MonadicSignature) (k : Nat) (hk : 2 ≤ k)
    (M N : OrderedMonadicStructure sig)
    (h_equiv : k_equiv sig k M N)
    (h_max : ∃ m : M.carrier, ∀ x : M.carrier, x ≤ m) :
    ∃ n : N.carrier, ∀ x : N.carrier, x ≤ n := by
  -- "has max" is ∃x. ∀y. ¬(x < y), depth 2 ≤ k
  -- Use doets_lemma_1_1 with the "has max" sentence
  ...
```

### 2.2 For k = 1 (special case)

At k = 1, we cannot use "has max" preservation. But we don't NEED to. The goal is to show `good sig 1 (orderedSum Bool witnesses)` where `witnesses` maps `false` to `Z1.toOrdered sig` and `true` to `Z2.toOrdered sig`.

**Strategy for k = 1:** Directly construct a Z-interval that is 1-equivalent to the ordered sum.

Key insight: 1-equivalence only depends on which predicate profiles (depth-0 1-var NFs) are realized. The ordered sum of Z1 and Z2 realizes exactly the UNION of profiles from Z1 and Z2. Since there are finitely many profiles (at most `2^|sig.preds|`), we can construct a finite Z-interval with exactly those profiles.

Alternatively, since both Z1 and Z2 are Z-intervals with the same 1-type as the original subintervals (which are 1-equiv to them), we can show the ordered sum is 1-equiv to one of them (if they share the same profiles) or construct a new Z-interval.

**Simplest approach for k = 1:** Use `finite_structures_good`. We need the ordered sum to be finite, or use a different argument.

Actually the cleanest approach: at k = 1, use `k_equiv_monotone` to step down. We have `k_equiv sig (k'+1) (M.subinterval sig t b) (Z1.toOrdered sig)`. If we could show `good sig 1 (orderedSum Bool witnesses)` regardless of boundedness... 

**Even simpler:** We can prove `good sig 1 (orderedSum Bool witnesses)` directly by constructing a Z-interval. The ordered sum has some set of predicate profiles S. Build `Z := { lo := some 0, hi := some (|S| - 1), interp := <assign profile i to element i> }`. Then show `k_equiv sig 1 (orderedSum Bool witnesses) (Z.toOrdered sig)` by proving they realize the same profiles.

---

## 3. Implementation Plan for the Sorry

### 3.1 Overall structure (replacing line 470)

```lean
    | succ k' =>
      cases k' with
      | zero =>
        -- k = 1: use profile-matching construction
        <proof for k=1>
      | succ k'' =>
        -- k = k''+2 ≥ 2: use has-max/has-min preservation
        <proof for k≥2>
```

### 3.2 Proof for k >= 2

1. Prove `has_max_of_subinterval`: `M.subinterval sig t b` has max `⟨b, htb, le_refl b⟩`
2. Prove `k_equiv_preserves_has_max` using `doets_lemma_1_1` with the "has max" sentence
3. Conclude `Z1.hi = some _` (Z1's carrier has a maximum, which means hi is some)
4. Similarly prove `has_min_of_subinterval` for the right piece and conclude `Z2.lo = some _`
5. With Z1 bounded above and Z2 bounded below, construct the glued Z-interval:
   - Z3 with `lo := Z1.lo`, `hi := some (Z1.hi.get + Z2.hi.elim ... + 1)` or use a shift
   - Build order isomorphism from `orderedSum Bool [Z1.toOrdered, Z2.toOrdered]` to Z3.toOrdered
   - Apply `k_equiv_of_iso` + `finite_structures_good` or direct iso

### 3.3 Proof for k = 1 (alternative direct approach)

Since at k = 1, order atoms don't exist at 1-variable depth, ALL ordered structures with the same predicate profile set are 1-equivalent. Strategy:

1. Collect the set of predicate profiles realized by `orderedSum Bool witnesses`
2. Build a finite Z-interval [0, n-1] with elements assigned those profiles
3. Show 1-equivalence by profile matching (no order comparison matters)

### 3.4 Converting "has max" to Z-interval boundedness

The critical connection: if `Z1.toOrdered sig` has a maximum element in its carrier `{z : Z | Z.lo.elim True (· ≤ z) ∧ Z.hi.elim True (z ≤ ·)}`, then `Z1.hi` must be `some _`.

**Proof:** If `Z1.hi = none`, the carrier is `{z : Z | Z.lo.elim True (· ≤ z)}`. For any element `⟨n, h⟩`, the element `⟨n+1, ...⟩` is strictly greater. So no maximum exists. Contradiction.

---

## 4. Specific Lemmas Needed

### Lemma 1: subinterval_has_max
```lean
theorem subinterval_has_max (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (t b : M.carrier) (htb : t ≤ b) :
    ∃ m : (M.subinterval sig t b).carrier, ∀ x, x ≤ m :=
  ⟨⟨b, htb, le_refl b⟩, fun ⟨x, _, hxb⟩ => hxb⟩
```

### Lemma 2: subinterval_has_min
```lean
theorem subinterval_has_min (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (t b : M.carrier) (htb : t ≤ b) :
    ∃ m : (M.subinterval sig t b).carrier, ∀ x, m ≤ x :=
  ⟨⟨t, le_refl t, htb⟩, fun ⟨x, htx, _⟩ => htx⟩
```

### Lemma 3: has_max_formula (the MonadicFormula sentence)
```lean
def has_max_sentence (sig : MonadicSignature) : MonadicSentence sig :=
  .ex (.all (.not (.lt (⟨1, by omega⟩ : Fin 2) (⟨0, by omega⟩ : Fin 2))))

theorem has_max_sentence_depth (sig : MonadicSignature) :
    (has_max_sentence sig).quantifier_depth = 2 := by
  simp [has_max_sentence, MonadicFormula.quantifier_depth]

theorem has_max_sentence_spec (sig : MonadicSignature) (M : OrderedMonadicStructure sig) :
    eval M Fin.elim0 (has_max_sentence sig) ↔ 
    (∃ m : M.carrier, ∀ x : M.carrier, ¬(m < x)) := by
  simp [has_max_sentence, eval, Fin.cons]
```

Note: `¬(m < x)` is equivalent to `x ≤ m` in a linear order. So `∃ m, ∀ x, ¬(m < x)` is equivalent to "has max".

### Lemma 4: k_equiv_preserves_has_max
```lean
theorem k_equiv_preserves_has_max (sig : MonadicSignature) {k : Nat} (hk : 2 ≤ k)
    (M N : OrderedMonadicStructure sig)
    (h_equiv : k_equiv sig k M N)
    (h_max : ∃ m : M.carrier, ∀ x : M.carrier, x ≤ m) :
    ∃ n : N.carrier, ∀ x : N.carrier, x ≤ n := by
  -- Convert to ¬(m < x) form
  obtain ⟨m, hm⟩ := h_max
  have h_eval_M : eval M Fin.elim0 (has_max_sentence sig) := by
    exact ⟨m, fun x => not_lt.mpr (hm x)⟩
  -- k_equiv implies same NF agreement
  have h_nf_agree : ∀ nf : NormalForm sig k 0,
      nf_eval_nf M k 0 Fin.elim0 nf ↔ nf_eval_nf N k 0 Fin.elim0 nf := by
    intro nf
    have h_pt := congr_fun h_equiv nf
    simp only [k_type_of, decide_eq_decide] at h_pt
    exact h_pt
  -- Apply doets_lemma_1_1
  have h_transfer := doets_lemma_1_1 k 0 (has_max_sentence sig)
    (by simp [has_max_sentence_depth]; omega) M N Fin.elim0 Fin.elim0 h_nf_agree
  have h_eval_N := h_transfer.mp h_eval_M
  obtain ⟨n, hn⟩ := h_eval_N
  exact ⟨n, fun x => le_of_not_lt (hn x)⟩
```

### Lemma 5: z_interval_unbounded_above_no_max
```lean
theorem z_interval_unbounded_above_no_max (sig : MonadicSignature)
    (Z : ZIntervalStructure sig) (h_hi : Z.hi = none) :
    ¬∃ m : Z.intervalCarrier, ∀ x : Z.intervalCarrier, x ≤ m := by
  intro ⟨⟨m, hm⟩, hall⟩
  have h_above : (⟨m + 1, ?_⟩ : Z.intervalCarrier) ≤ ⟨m, hm⟩ := hall ⟨m + 1, _⟩
  · -- m + 1 ≤ m is false
    simp at h_above
  · -- m + 1 is in the carrier
    simp [ZIntervalStructure.intervalCarrier, h_hi]
    exact ⟨by linarith [hm.1], trivial⟩  -- lo condition + hi=none
```

### Lemma 6: z_interval_has_max_iff
```lean
theorem z_interval_has_max_iff (sig : MonadicSignature) (Z : ZIntervalStructure sig)
    (h_nonempty : Nonempty Z.intervalCarrier) :
    (∃ m : (Z.toOrdered sig).carrier, ∀ x, x ≤ m) ↔ Z.hi.isSome := by
  ...
```

---

## 5. The k = 1 Case: Why It's Actually Easy

For k = 1, we bypass the has-max argument entirely. The ordered sum of two Z-intervals is always 1-good because:

1. At depth 1, the k-type only depends on which "1-element profiles" exist (combinations of predicate truth values at single elements)
2. The ordered sum of Z1 and Z2 realizes the union of profiles from Z1 and Z2
3. We can always find a finite Z-interval realizing any finite set of profiles

**Concrete construction for k = 1:**

Let `S` = set of depth-0 1-var NFs realized by the ordered sum. Since `|S| ≤ 2^|sig.preds|` (finite), construct:
```lean
let Z3 : ZIntervalStructure sig := {
  lo := some 0
  hi := some (|S| - 1)
  interp := fun p z => <assign based on which profile z represents>
}
```
Then prove `k_equiv sig 1 (orderedSum Bool witnesses) (Z3.toOrdered sig)` by showing they realize the same depth-0 1-var NFs existentially.

**Even simpler alternative for k = 1:** Since we already know `M.subinterval sig t b` is 1-equiv to `Z1.toOrdered sig` and `M.subinterval sig (Order.succ b) u` is 1-equiv to `Z2.toOrdered sig`, and at depth 1 the ordered sum inherits the profiles from both pieces, we can use the chain:

```
orderedSum Bool witnesses 
  ~1 orderedSum Bool pieces       (by doets_lemma_1_4 with k=1)
  ~1 M.subinterval sig t u       (by the iso already proved at line 349)
```

Wait — this is BACKWARDS from what we need! We already have:
- `h_iso : k_equiv sig k (M.subinterval sig t u) (orderedSum sig Bool pieces)`
- `h_sum : k_equiv sig k (orderedSum sig Bool pieces) (orderedSum sig Bool witnesses)`

So `M.subinterval sig t u ~k orderedSum Bool witnesses`. The GOAL is `good sig k (orderedSum Bool witnesses)`, which means we need a Z-interval that the ordered sum is k-equiv to. This is equivalent to showing `M.subinterval sig t u` is good (since they're k-equiv, and good is transitive under k-equiv). But that's exactly what we're TRYING to prove. **This confirms circularity.**

So for k = 1, we genuinely need a direct construction of a Z-interval that is 1-equiv to the ordered sum.

### Direct k=1 construction sketch:

```lean
-- At k=1, we prove good directly by constructing a profile-matching Z-interval.
-- The key: at depth 1, k-equiv only sees which AtomKind sig 1 profiles exist.
-- AtomKind sig 1 = pred atoms only (no order atoms at n=1).
-- So 1-equiv ↔ same set of unary predicate profiles.
-- The orderedSum realizes some set of profiles S ⊆ Finset (sig.preds → Bool).
-- Construct Z3 : ZIntervalStructure with |S| elements, each assigned one profile.
-- Then Z3 ≅ Fin |S| as ordered set, with profiles matching.
-- k_equiv sig 1 (orderedSum Bool witnesses) (Z3.toOrdered sig) follows.
```

---

## 6. Recommended Implementation Order

1. **Add helper lemmas** (subinterval_has_max, subinterval_has_min, z_interval_unbounded_above_no_max)
2. **Define has_max_sentence** and prove its spec + depth
3. **Prove k_equiv_preserves_has_max** using doets_lemma_1_1
4. **Prove z_interval_has_max_iff** (or just the direction: has_max → hi.isSome)
5. **Case split the sorry** into k=1 and k≥2 subcases
6. **k≥2 subcase**: Apply preservation lemma to get Z1.hi = some _, Z2.lo = some _, then construct glued Z3
7. **k=1 subcase**: Profile-matching finite Z-interval construction

### Estimated complexity:
- Steps 1-4: Straightforward (~50-80 lines)
- Step 6 (k≥2): Medium complexity (~80-120 lines, mainly the shift-and-glue construction)
- Step 7 (k=1): Medium complexity (~60-100 lines, constructing the profile Z-interval and proving 1-equiv)

---

## 7. Key Insight: The Glue for k >= 2

Once we know `Z1.hi = some h1` and `Z2.lo = some l2`:

The ordered sum `orderedSum Bool [Z1.toOrdered sig, Z2.toOrdered sig]` has carrier:
- `{(false, z) | z in Z1.intervalCarrier}` (all elements from Z1, ordered first)
- `{(true, z) | z in Z2.intervalCarrier}` (all elements from Z2, ordered second)

Since Z1 has a maximum `h1` and Z2 has a minimum `l2`, the full carrier is order-isomorphic to a single Z-interval:
```
Z3 := { lo := Z1.lo, hi := Z2.hi, ... }   -- shifted appropriately
```

The shift: map `(false, z) -> z` for Z1 elements, and `(true, z) -> z + (h1 + 1 - l2)` for Z2 elements. This places all Z1 elements below all Z2 elements (since Z1 has max h1, and Z2 elements start at l2 shifted to h1 + 1).

Alternatively, use `k_equiv_of_iso` with the order isomorphism, plus the finiteness argument:
- Z1 bounded above + Z2 bounded below means:
  - Z1 carrier is `{z | lo1 ≤ z ≤ h1}` — FINITE (bounded interval of Z)
  - But Z2 might not have a finite carrier (could be unbounded above)
  
Wait — we only know Z1 has a max (Z1.hi = some _). We DON'T necessarily know Z2 has a max. And Z1 might not have a min (Z1.lo could be none). So the ordered sum could be infinite.

The correct approach: build a Z-interval Z3 that is ORDER-ISOMORPHIC to the ordered sum. The ordered sum has carrier = Z1's interval (below) THEN Z2's interval (above). These are two sub-intervals of Z, concatenated. By shifting Z2's elements, we get a single interval:

- Z1 carrier: `{z | Z1.lo.elim True (· ≤ z) ∧ z ≤ h1}` (bounded above by h1)
- Z2 carrier: `{z | l2 ≤ z ∧ Z2.hi.elim True (z ≤ ·)}` (bounded below by l2)
- Shift Z2 by `(h1 + 1 - l2)`: now Z2 starts at h1 + 1
- Combined: `{z | Z1.lo.elim True (· ≤ z) ∧ (Z2.hi.elim True (z - (h1+1-l2) ≤ ·) ∨ z ≤ h1)}`

This is more complex. The cleanest approach:
```
Z3.lo := Z1.lo
Z3.hi := Z2.hi.map (· + (h1 + 1 - l2))
```
with the shift embedding being `z -> z + (h1 + 1 - l2)` for Z2 elements.

Then `Z3.intervalCarrier ≃o (orderedSum Bool [Z1.toOrdered, Z2.toOrdered]).carrier` via:
- `(false, ⟨z, hz⟩) ↦ ⟨z, ...⟩` (z is in Z1's range, which is within Z3's range)
- `(true, ⟨z, hz⟩) ↦ ⟨z + (h1 + 1 - l2), ...⟩` (shifted to sit above h1)

This is monotone and bijective, hence an order isomorphism.

Then apply `k_equiv_of_iso` with appropriate predicate transfer.

---

## 8. Answer to the Original Questions

1. **Is "has max" expressible?** YES, as `MonadicFormula.ex (MonadicFormula.all (MonadicFormula.not (MonadicFormula.lt 1 0)))` at quantifier depth 2.

2. **Does AtomKind include order atoms?** YES: `AtomKind.order i j h` for `i ≠ j : Fin n`. Available when n ≥ 2.

3. **Existing expressibility results?** YES: `doets_lemma_1_1` (NormalForm.lean line 433) provides exactly the bridge theorem needed.

4. **Existing bounds-to-k_equiv lemmas?** NO. This needs to be constructed.

5. **How nf_eval_nf works?** Perfectly suited: the normal form agreement at depth k implies formula agreement for all formulas of depth ≤ k. This is `doets_lemma_1_1`.

6. **Alternative approach?** Not needed for k ≥ 2. For k = 1, the profile-matching construction bypasses the expressibility argument entirely.

7. **Order atoms at n=1?** NONE. `AtomKind sig 1` only has `pred` atoms (confirmed at line 145: `atomKind_one_pred_only`). Order atoms require n ≥ 2 distinct variables. This is why "has max" needs depth 2 (to introduce two variables).

### Depth summary:
| k value | "has max" preserved? | Proof strategy |
|---------|---------------------|----------------|
| k = 0 | N/A (already handled) | Direct: trivial Z-interval |
| k = 1 | NO | Profile-matching Z-interval |
| k >= 2 | YES | doets_lemma_1_1 + shift-and-glue |
