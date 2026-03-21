# Research Report: Task 961 - Alternative Mathematical Approaches

**Teammate**: B (Devil's Advocate / Alternative Approaches)
**Date**: 2026-03-13
**Focus**: Why has this been so hard? Simpler approaches?

## Executive Summary

The fundamental obstacle is that the density construction provides non-strict intermediates that may collapse into endpoint equivalence classes. The current bounded iteration approach cannot guarantee termination. However, I found a **simpler approach** using Mathlib's `denselyOrdered_iff_forall_not_covBy` that reframes the problem.

**Key Insight**: Prove `DenselyOrdered` by showing NO COVERING RELATIONS exist in the quotient, rather than constructing strict intermediates.

**Confidence Level**: MEDIUM-HIGH

---

## Why This Problem Has Been So Hard

### 1. The Core Obstruction

The density lemma `dense_timeline_has_intermediate` gives:
```
Given p < q (strict in quotient), there exists c with:
- CanonicalR p.mcs c.mcs  (p <= c)
- CanonicalR c.mcs q.mcs  (c <= q)
```

But this intermediate `c` might be **equivalent** to `p` or `q` in the quotient:
- If `CanonicalR c.mcs p.mcs` also holds, then `[c] = [p]`
- If `CanonicalR q.mcs c.mcs` also holds, then `[c] = [q]`

### 2. The Iteration Problem

The current approach iterates:
1. Get intermediate c between p and q
2. If c ~ p, apply density to (c, q)
3. If c ~ q, apply density to (p, c)
4. Repeat until finding a strict intermediate

**The problem**: This iteration may not terminate! Each step uses a different distinguishing formula, but there are infinitely many formulas.

### 3. The Strict Intermediate Partial Solution

`dense_timeline_has_strict_intermediate` improves this when the **source is reflexive**:
```
If CanonicalR a.mcs a.mcs (source reflexive), then the intermediate c satisfies:
- CanonicalR a.mcs c.mcs
- CanonicalR c.mcs b.mcs
- NOT CanonicalR b.mcs c.mcs  (c is NOT equivalent to target!)
```

But c might STILL be equivalent to the source. And when it is, c inherits reflexivity, so we can iterate... but termination is not guaranteed.

---

## Mathlib Discoveries

### Key Theorem: `denselyOrdered_iff_forall_not_covBy`

From `Mathlib.Order.Cover`:
```lean
theorem denselyOrdered_iff_forall_not_covBy :
  DenselyOrdered α ↔ ∀ a b : α, ¬a ⋖ b
```

**This is an equivalence!** To prove `DenselyOrdered`, we only need to show there are NO COVERING RELATIONS.

### Related Lemmas

1. `not_covBy_iff (h : a < b) : ¬a ⋖ b ↔ ∃ c, a < c ∧ c < b`
   - Non-covering is equivalent to having a strict intermediate

2. `exists_lt_lt_of_not_covBy`
   - Extract the intermediate from non-covering

3. `CovBy` definition:
   ```lean
   def CovBy (a b : α) : Prop := a < b ∧ ∀ ⦃c⦄, a < c → ¬c < b
   ```
   - b covers a iff a < b and no element strictly between

---

## Simpler Approach: No-Covering Proof

### The Strategy

Instead of CONSTRUCTING a strict intermediate, prove by CONTRADICTION that no covering relation can exist.

**Assume** `[p] ⋖ [q]` (covering relation in quotient).

Then:
1. `[p] < [q]`: meaning `CanonicalR p.mcs q.mcs` and `¬CanonicalR q.mcs p.mcs`
2. For all `[c]` with `[p] ≤ [c] ≤ [q]`: either `[c] = [p]` or `[c] = [q]`

By `dense_timeline_has_intermediate`, there exists `c` with:
- `CanonicalR p.mcs c.mcs` (so `[p] ≤ [c]`)
- `CanonicalR c.mcs q.mcs` (so `[c] ≤ [q]`)

By the covering assumption, `[c] = [p]` or `[c] = [q]`.

**Key fact**: c CANNOT be equivalent to BOTH p AND q, because that would make `p ~ q`, contradicting `[p] < [q]`.

So exactly ONE of these holds:
- Case A: `c ~ p` (and `c ≁ q`)
- Case B: `c ~ q` (and `c ≁ p`)

### Deriving Contradiction

**Case A** (c ~ p):
- Since c ~ p, we have `CanonicalR c.mcs p.mcs`
- By `mutual_canonicalR_implies_reflexive`, p is reflexive
- Apply `dense_timeline_has_strict_intermediate` to (p, q):
  - Get d with `CanonicalR p.mcs d.mcs`, `CanonicalR d.mcs q.mcs`, `¬CanonicalR q.mcs d.mcs`
  - So `[d] ≠ [q]`!
  - By covering assumption, `[d] = [p]`
  - Then d ~ p, so d is reflexive, iterate...

**The key question**: Does this iteration TERMINATE?

### Termination Argument (Sketch)

Each iteration produces an intermediate d with `¬CanonicalR q.mcs d.mcs`. If d ~ p, iterate again.

The distinguishing formula construction in `density_frame_condition_strict` uses a formula delta with:
- `G(delta) ∈ q.mcs`
- `delta ∉ p.mcs`
- The intermediate contains `¬delta`

If ALL intermediates are equivalent to p, then ALL contain `¬delta_i` for various delta_i.

**Conjecture**: The formula constraints accumulate in a way that eventually FORCES a non-equivalent intermediate, because MCS consistency prevents containing infinitely many contradictory formulas.

This is NOT proven in the current codebase - it's the sorries.

---

## Why Previous Approaches Failed

### 1. Bounded Iteration (Current)

The code iterates 4 levels deep with explicit `by_cases` branches. This is:
- Ugly and unscalable
- Fundamentally incomplete (what if 5 iterations needed?)
- Doesn't prove termination

### 2. Classical.choose

Using `Classical.choose` on the existential doesn't help because:
- We don't have a proof that a strict intermediate EXISTS
- We're trying to PROVE existence, not extract a witness

### 3. Quotient-Level Reasoning

The code tries to reason at both the preorder AND quotient levels, creating complexity. A cleaner approach would reason purely about covering relations.

---

## Recommended Approach

### Step 1: Prove Using `denselyOrdered_iff_forall_not_covBy`

Replace the direct `DenselyOrdered` instance with:
```lean
instance : DenselyOrdered (TimelineQuot root_mcs root_mcs_proof) :=
  denselyOrdered_iff_forall_not_covBy.mpr (fun a b => not_covBy_timelineQuot a b)
```

Where `not_covBy_timelineQuot` proves there are no covering relations.

### Step 2: Prove `not_covBy_timelineQuot`

```lean
theorem not_covBy_timelineQuot (a b : TimelineQuot ...) : ¬ a ⋖ b := by
  intro ⟨hab, h_no_between⟩
  -- hab : a < b
  -- h_no_between : ∀ c, a < c → ¬c < b
  -- Get representatives, derive contradiction using density + reflexivity chain
  ...
```

### Step 3: Handle the Termination

For termination, consider:

**Option A**: Prove that the distinguishing formula sequence is well-founded (hard, requires formula complexity measure)

**Option B**: Use a cardinality argument - if infinitely many intermediates exist between p and q at the preorder level, they can't ALL be equivalent to just two equivalence classes [p] and [q] (needs careful formulation)

**Option C**: Prove that reflexive equivalence classes are "isolated" in some sense - if [p] is reflexive and [p] < [q], then there's always a non-reflexive element strictly between (requires understanding the structure of reflexive MCSs)

---

## What If We're Overcomplicating This?

### Direct Existence Observation

The density construction `density_frame_condition` is based on:
- The Density axiom (DN): `F(phi) → F(F(phi))`
- Which gives: between any two CanonicalR-related MCSs, there's an intermediate

The structure of the proof creates intermediates with SPECIFIC formula content:
- The intermediate V contains `¬delta` where delta is a distinguishing formula
- This prevents V from being equivalent to the target (if target is reflexive)

**Perhaps** the right approach is to prove that V cannot be equivalent to the source EITHER, by showing the formula content is incompatible.

### Formula Content Analysis

When we create V via density:
1. We start with source M, target M', with `¬CanonicalR(M', M)`
2. We get delta with `G(delta) ∈ M'` but `delta ∉ M`
3. If M is reflexive, then `G(delta) ∉ M` (else delta ∈ M)
4. We create V containing `¬delta`

For V ~ M, we need `CanonicalR V M` and `CanonicalR M V`.

`CanonicalR M V` is given by construction.

For `CanonicalR V M`: we need `GContent(V) ⊆ M`.

**If** we could show that V is NOT reflexive (i.e., `¬CanonicalR V V`), then even if V ~ M, we could use this asymmetry somehow...

But actually, if V ~ M and M is reflexive, then V is also reflexive!

---

## Conclusion

**The simpler approach exists**: Use `denselyOrdered_iff_forall_not_covBy` to prove density via absence of covering relations, rather than explicit strict intermediate construction.

**The termination problem remains**: Whether we construct or prove by contradiction, we need to show that the reflexive equivalence class chain terminates.

**Most promising direction**: Analyze the formula content constraints more carefully. The density construction adds specific formulas (like `¬delta`) to intermediates. These constraints should eventually force the intermediate out of the source equivalence class.

**Alternative**: Prove a structural theorem about reflexive MCSs that limits their "size" or connectivity in a way that prevents infinite chains of equivalent intermediates.

---

## Appendix: Mathlib Lookup Results

### lean_leansearch: "dense order antisymmetrization quotient preorder"
- `Antisymmetrization` definition
- `instPartialOrderAntisymmetrization` instance
- `toAntisymmetrization_le_toAntisymmetrization_iff` lemma

### lean_leanfinder: "covering relation covBy in densely ordered set is empty"
- `not_covBy`: In dense order, nothing covers anything
- `denselyOrdered_iff_forall_not_covBy`: THE KEY EQUIVALENCE
- `CovBy.Ioo_eq`: Covering implies empty open interval

### lean_leanfinder: "prove DenselyOrdered by showing no covering relation exists"
- `DenselyOrdered` structure definition
- Various density instances for dual, subsets, WithBot/WithTop

### Key Files in Mathlib
- `Mathlib/Order/Cover.lean` - Covering relation theory
- `Mathlib/Order/Antisymmetrization.lean` - Quotient construction
