# Research Report: Proving Ordered Sum of Z-Intervals is Good

**Task**: 155 (Reynolds Pipeline Activation)
**Focus**: Close the sorry at IntegerModel.lean:470
**Date**: 2026-05-16

---

## Executive Summary

The sorry at line 470 of `IntegerModel.lean` asks to prove:
```lean
good sig (k' + 1) (orderedSum sig Bool witnesses)
```
where `witnesses i = if i = false then Z1.toOrdered sig else Z2.toOrdered sig`.

**Verdict**: The sorry is closable with ~100-150 lines of new code using a two-case strategy:
- **k >= 2** (k' >= 1): Transfer "has max"/"has min" via `doets_lemma_1_1`, establish that both Z1 and Z2 are fully bounded (hence finite), then apply `finite_structures_good`.
- **k = 1** (k' = 0): Directly construct a finite Z-interval matching the 1-type of the ordered sum.

**Critical path note**: This sorry is NOT on the critical path for discrete completeness. The `good_of_split_at_succ` theorem is used only in `contemp_equiv_is_equiv` transitivity, which is bypassed by the `IsSuccArchimedean`-based `one_class` proof. Filling it has independent mathematical value.

---

## 1. Problem Analysis

### 1.1 Proof State at the Sorry

```lean
sig : MonadicSignature
M : OrderedMonadicStructure sig
inst✝¹ : SuccOrder M.carrier
inst✝ : NoMaxOrder M.carrier
t b u : M.carrier
htb : t ≤ b
hbu : b < u
Z1 Z2 : ZIntervalStructure sig
hZ1 : k_equiv sig (k' + 1) (M.subinterval sig t b) (Z1.toOrdered sig)
hZ2 : k_equiv sig (k' + 1) (M.subinterval sig (Order.succ b) u) (Z2.toOrdered sig)
h_iso : k_equiv sig (k' + 1) (M.subinterval sig t u) (orderedSum sig Bool pieces)
h_sum : k_equiv sig (k' + 1) (orderedSum sig Bool pieces) (orderedSum sig Bool witnesses)
⊢ good sig (k' + 1) (orderedSum sig Bool witnesses)
```

### 1.2 Key Definitions

- `ZIntervalStructure sig` has fields: `lo : Option ℤ`, `hi : Option ℤ`, `interp`
- `intervalCarrier` = `{z : ℤ // lo.elim True (· ≤ z) ∧ hi.elim True (z ≤ ·)}`
- `toOrdered sig` builds an `OrderedMonadicStructure` on `intervalCarrier`
- `orderedSum` carrier = `Sigma fun i : Bool => (witnesses i).carrier` with lex order
- `good sig k M` = `∃ Z : ZIntervalStructure sig, k_equiv sig k M (Z.toOrdered sig)`

### 1.3 Why Naive Approaches Fail

1. **Circular**: We have `M|[t,u] ~k orderedSum witnesses` (from h_iso.trans h_sum), but proving `good (M|[t,u])` IS the goal of the outer theorem, so we cannot use it to conclude `good (orderedSum witnesses)`.

2. **Order-iso requires boundedness**: Constructing a single Z-interval order-isomorphic to the ordered sum requires embedding both Z1 and Z2's carriers into ℤ with all of Z1 below Z2. This fails if Z1 is unbounded above (its carrier is infinite in both directions).

3. **Z1/Z2 might be unbounded**: The definition of `good` gives `∃ Z, k_equiv ...` where Z could have `lo = none` or `hi = none`, yielding an infinite carrier.

---

## 2. Solution Architecture

### 2.1 Key Insight: Transfer of Endpoints via Expressibility

"Has a maximum element" is expressible as the monadic FO sentence:
```lean
.ex (.all (.not (.lt 1 0)))  -- ∃x. ∀y. ¬(x < y)
```
with quantifier depth **2**. By `doets_lemma_1_1`, at k >= 2, this sentence transfers across k-equivalences.

**Verified in Lean** (this compiles):
```lean
theorem has_max_transfer (sig : MonadicSignature) (k : Nat) (hk : 2 ≤ k)
    (M N : OrderedMonadicStructure sig)
    (h_equiv : k_equiv sig k M N)
    (h_max : ∃ x : M.carrier, ∀ y : M.carrier, ¬ (x < y)) :
    ∃ x : N.carrier, ∀ y : N.carrier, ¬ (x < y)
```

### 2.2 Boundedness Implications

If `Z.intervalCarrier` has a maximum, then `Z.hi = some _`:
- If `Z.hi = none`, the carrier includes `{z : ℤ // lo.elim True (· ≤ z)}` which is either `ℤ` or `[lo, ∞)` -- both have no maximum.
- So "has max" implies `Z.hi = some _`.

Similarly, "has min" implies `Z.lo = some _`.

For our sorry:
- `M.subinterval sig t b` has max `⟨b, htb, le_refl b⟩` AND min `⟨t, le_refl t, htb⟩`
- `M.subinterval sig (Order.succ b) u` has min `⟨succ b, ...⟩` AND max `⟨u, ..., le_refl u⟩`
- At k >= 2: transfer gives Z1 has both max AND min → Z1.lo = some _, Z1.hi = some _
- At k >= 2: transfer gives Z2 has both max AND min → Z2.lo = some _, Z2.hi = some _

When both `lo = some _` and `hi = some _`, `intervalCarrier` = `{z : ℤ // lo ≤ z ∧ z ≤ hi}` which is `Fintype` (via `Fintype (Set.Icc lo hi)`).

### 2.3 Final Chain for k >= 2

1. Both Z1 and Z2 have `Fintype` carrier (from boundedness)
2. `Sigma.instFintype` gives `Fintype (orderedSum Bool witnesses).carrier`
3. `finite_structures_good` gives `good sig k (orderedSum Bool witnesses)`

### 2.4 The k = 1 Case

At depth 1, "has max" (depth 2) does NOT transfer. Z1 could be all of ℤ. However:

At depth 1, the k-type records only which predicate patterns (`sig.preds → Bool`) are realized by some element. Order information is invisible (AtomKind sig 1 has no `order` atoms since you need 2 distinct variables for order, but depth-1 1-var NFs only have 1 variable).

**Strategy**: Directly construct a finite Z-interval [0, m-1] that realizes exactly the same set of predicate patterns as the ordered sum. Since there are at most `2^|sig.preds|` possible patterns, this finite Z-interval witnesses goodness.

---

## 3. Detailed Implementation Plan

### 3.1 Helper Lemmas Needed

| Lemma | Purpose | Estimated Lines |
|-------|---------|----------------|
| `has_max_sentence` / `has_min_sentence` | MonadicFormula encoding | 10 |
| `k_equiv_preserves_has_max` / `has_min` | Transfer via doets_lemma_1_1 | 20 each |
| `z_interval_bounded_of_has_max_and_min` | has max ∧ has min → lo/hi both some | 20 |
| `z_interval_bounded_fintype` | lo = some _ ∧ hi = some _ → Fintype carrier | 15 |
| `good_of_orderedSum_k1` | Direct k=1 construction | 40-50 |
| Integration at line 470 | Wiring it all together | 20-30 |
| **Total** | | **~150 lines** |

### 3.2 Proof Skeleton for the Sorry (k >= 2 case)

```lean
| succ k' =>
  cases k' with
  | zero => <k=1 argument>
  | succ k'' =>
    -- k = k''+2 >= 2
    -- Step 1: M|[t,b] has both max and min
    have h_M_max : ∃ m : (M.subinterval sig t b).carrier, ∀ x, x ≤ m :=
      ⟨⟨b, htb, le_refl b⟩, fun ⟨_, _, hxb⟩ => hxb⟩
    have h_M_min : ∃ m : (M.subinterval sig t b).carrier, ∀ x, m ≤ x :=
      ⟨⟨t, le_refl t, htb⟩, fun ⟨_, htx, _⟩ => htx⟩
    -- Similarly for M|[succ b, u]
    
    -- Step 2: Transfer to Z1, Z2 (depth 2 ≤ k''+2)
    have h_Z1_max := k_equiv_preserves_has_max sig (k''+2) (by omega) _ _ hZ1 h_M_max
    have h_Z1_min := k_equiv_preserves_has_min sig (k''+2) (by omega) _ _ hZ1 h_M_min
    have h_Z2_max := k_equiv_preserves_has_max sig (k''+2) (by omega) _ _ hZ2 h_succ_M_max
    have h_Z2_min := k_equiv_preserves_has_min sig (k''+2) (by omega) _ _ hZ2 h_succ_M_min
    
    -- Step 3: Z1, Z2 bounded → Fintype carriers
    have h_Z1_fin : Fintype Z1.intervalCarrier := ...
    have h_Z2_fin : Fintype Z2.intervalCarrier := ...
    
    -- Step 4: Sigma is Fintype
    haveI : Fintype (orderedSum sig Bool witnesses).carrier := ...
    
    -- Step 5: Apply finite_structures_good
    exact finite_structures_good sig (k''+2) (orderedSum sig Bool witnesses)
```

### 3.3 Proof Skeleton for k = 1

```lean
| zero =>
  -- k = 1. Construct a finite Z-interval matching the 1-type.
  -- The 1-type records which predicate patterns (sig.preds → Bool) are realized.
  -- The ordered sum realizes the union of patterns from Z1 and Z2.
  -- Build Z3 = [0, m-1] with m = count of realized patterns.
  -- Assign predicates so element i realizes pattern i.
  -- Prove k_equiv sig 1 (orderedSum ...) (Z3.toOrdered sig) by showing
  -- same set of realized patterns (same 1-type).
  sorry -- implement using profile enumeration
```

### 3.4 Key Obstacle: Showing `Fintype Z.intervalCarrier` from Bounds

When `Z.lo = some l` and `Z.hi = some h`:
```lean
-- Z.intervalCarrier = {z : ℤ // l ≤ z ∧ z ≤ h}
-- Proved equivalent to Set.Icc l h which has Fintype in Mathlib:
import Mathlib.Data.Int.Interval

example (l h : ℤ) : Fintype (Set.Icc l h) := inferInstance

-- For the subtype form, use:
Fintype.ofEquiv _ (Equiv.subtypeEquivRight (fun z => (Set.mem_Icc).symm)).symm
```

When `Z.lo = none`: the lo condition is `True`, so `intervalCarrier = {z : ℤ // z ≤ h}` (if `hi = some h`). This is ALSO finite: equivalent to `Set.Iic h` which is `Fintype` (via `Set.fintypeIic` or `Fintype.ofFinset (Finset.Iic h)`). Actually `Set.Iic` on ℤ is NOT finite! We need BOTH bounds.

**Correction**: We need both lo and hi to be `some` for finiteness. This is guaranteed because both M|[t,b] and M|[succ b,u] have BOTH max AND min (from the hypotheses `htb : t ≤ b` and `hbu : b < u`).

---

## 4. Existing Infrastructure

### 4.1 What's Already Proved

| Theorem | Status | File |
|---------|--------|------|
| `finite_structures_good` | Proved | IntegerModel.lean:173 |
| `k_equiv_of_iso` | Proved | IntegerModel.lean:98 |
| `doets_lemma_1_1` | Proved | NormalForm.lean:433 |
| `doets_lemma_1_4` | Proved | OrderedSum.lean:34 |
| `k_equiv_monotone` | Proved | NEquivalence.lean:91 |
| `Sigma.instFintype` | In Mathlib | Mathlib.Data.Fintype.Sigma |
| `Fintype (Set.Icc l h)` for ℤ | In Mathlib | Mathlib.Data.Int.Interval |

### 4.2 What's Missing (Needs Implementation)

| Needed | Complexity | Notes |
|--------|-----------|-------|
| `has_max_sentence` definition | Trivial | `.ex (.all (.not (.lt 1 0)))` |
| `k_equiv_preserves_has_max` | Easy | Chain: eval ↔ + doets_lemma_1_1 + h_nf |
| `z_interval_has_max_implies_hi_some` | Easy | Contrapositive: hi=none → no max |
| `z_interval_bounded_fintype` | Easy | Equiv to Set.Icc + Mathlib |
| k=1 finite witness construction | Medium | Profile enumeration + Z3 construction |
| `orderedSum_carrier_fintype_of_components` | Easy | Sigma.instFintype with if-then-else |

---

## 5. Alternative Approaches Considered

### 5.1 Direct Order-Isomorphism (Partial)

Works for k >= 2 (Z1 bounded above, Z2 bounded below): shift Z2 by `(h1 + 1 - l2)` so all Z2 elements start at `h1 + 1`. The combined carrier is isomorphic to a single interval. But this requires MORE work than just showing finiteness.

**Verdict**: Unnecessary. Once we know both Z1 and Z2 are fully bounded (and hence finite), `finite_structures_good` is simpler.

### 5.2 `doets_lemma_1_5` (Type-Matching Sums)

Already `sorry`'d in the codebase. Would directly solve the problem if proved. But proving it is HARDER than the original sorry -- it requires showing two ordered sums with matching k-type distributions are k-equiv.

**Verdict**: Not a shortcut. More work than the proposed approach.

### 5.3 General "Every Structure is k-equiv to a Finite One"

A standard model-theory result that would make all cases trivial. But requires inductive construction of a finite model from a k-type, which is ~200 lines of new infrastructure.

**Verdict**: Overkill for this specific sorry. The case-split approach is simpler.

---

## 6. Conclusion and Recommendations

### Recommended Implementation Path

1. **Implement k >= 2 case first** (~80 lines): has_max/min transfer + bounded fintype + finite_structures_good
2. **Implement k = 1 case second** (~50 lines): direct finite Z-interval construction matching 1-type
3. **Total**: ~130-150 lines of new code

### Key Verification Results

The following were tested and compile successfully:
- `has_max_transfer` using `doets_lemma_1_1` at depth ≥ 2
- `Fintype (Set.Icc l h)` for ℤ from `Mathlib.Data.Int.Interval`
- `Sigma.instFintype` for `(i : ι) × κ i` when both components are `Fintype`
- Definition and depth computation of `has_max_formula`

### Pragmatic Note

Since `good_of_split_at_succ` is dead code (not on the critical path for discrete completeness), filling this sorry has purely mathematical value. The discrete completeness pipeline works via `chronicle_is_good` → `orderIsoIntOfLinearSuccPredArch` without ever calling `good_of_split_at_succ`.
