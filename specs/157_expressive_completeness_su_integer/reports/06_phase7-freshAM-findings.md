# Phase 7 Research: freshAM / atomMap Disjointness

**Date**: 2026-05-17
**Task**: 157 — Expressive Completeness of {S,U} over Z
**Focus**: Closing the remaining sorry in `atom_elim_correct`

---

## 1. Current Construction (What the Code Actually Does)

### `to_int_struct`

```lean
def to_int_struct {sig : MonadicSignature} (M : IntStructureFromSig sig)
    (atomMap : sig.preds → Atom) : Separation.IntStructure where
  val a := {t : Int | ∃ p : sig.preds, atomMap p = a ∧ M.interp p t}
```

The resulting `IntStructure` assigns to each atom `a` the set of times `t` where some predicate `p` with `atomMap p = a` holds. Membership at `atomMap p` is thus exactly `M.interp p z` (when `atomMap` is injective, proven by `to_int_struct_mem_atomMap`).

### `Atom.mk_fresh`

```lean
structure Atom where
  base : String
  fresh_index : Option Nat
def mk_fresh (s : String) (n : Nat) : Atom := ⟨s, some n⟩
```

Two atoms `mk_fresh s n` and `mk_fresh s' n'` are equal iff `s = s'` and `n = n'`. There is an existing lemma `mk_fresh_injective s` for fixed base `s`. There is **no** lemma of the form `mk_fresh s n ≠ mk_fresh s' n'` when `s ≠ s'`, but this is trivially provable since `Atom.mk.injEq` gives `s = s' ∧ some n = some n'`.

### `freshAM` at Each Recursion Level

At every quantifier level in `expressiveness_inner` (both `.ex` and `.all` cases), `freshAM` is defined identically:

```lean
let freshAM : (extSignature sig).preds → Atom :=
  fun ep => Atom.mk_fresh "e" (Fintype.equivFin (extSignature sig).preds ep).val
```

It maps each `ExtPred sig` to `mk_fresh "e" k` where `k` is the `Fin`-index of the predicate in `Fintype.equivFin (extSignature sig).preds`. The range of `freshAM` is `{mk_fresh "e" 0, mk_fresh "e" 1, ..., mk_fresh "e" (card (ExtPred sig) - 1)}`.

### `atomMap` at the Top Level (in `separation_implies_expressiveness`)

```lean
let atomMap : sig.preds -> Bimodal.Syntax.Atom :=
  fun q => Bimodal.Syntax.Atom.mk_fresh "p" (Fintype.equivFin sig.preds q).val
```

Base string `"p"`, so range is `{mk_fresh "p" 0, mk_fresh "p" 1, ...}`. This is disjoint from `freshAM`'s range (base `"e"`) because `"p" ≠ "e"`.

### `atomMap` at Recursive Levels

When `expressiveness_inner` handles `.ex alpha` or `.all alpha`, it:
1. Constructs `freshAM` with base `"e"` as above.
2. Calls `outerIH ... (extSignature sig) freshAM freshAM_inj (reduceElimLast 1 alpha) ...` to get `ihExt`.
3. The recursive call sees `atomMap' = freshAM` (base `"e"`).
4. If that recursive call in turn handles another quantifier, it again constructs its own `freshAM'` with base `"e"` and indices from `Fintype.equivFin (extSignature (extSignature sig)).preds`.

This means at recursion depth ≥ 2, we have:
- Outer level: `atomMap` = previous `freshAM` = `mk_fresh "e" 0..N-1`
- Inner `freshAM` = `mk_fresh "e" 0..M-1` where `M = card (ExtPred (extSignature sig))`

Both have base `"e"`. Their index ranges are `0..N-1` and `0..M-1`. Since `M ≥ 2N+2` (ExtPred has `2|preds|+2` elements), the ranges for the outer and inner levels start both at 0, meaning index 0 appears in both. **Overlap is real.**

---

## 2. The Problem: Where Disjointness is Needed

### Why `atom_elim_correct` needs disjointness

The function `quantElimFormula atomMap freshAM B_sep` builds substitution lists including:

```lean
let origSubs := origSubsList atomMap freshAM
-- origSubs = [(freshAM (.orig p), Formula.atom (atomMap p)) | p ∈ sig.preds]
```

Then `elimExtFromSep (origSubs ++ constSubsList freshAM σ) lt_atom gt_atom B_sep` applies these substitutions via `applySubsts`. The critical property `applySubsts` needs is that after substituting `freshAM (.orig p)` → `Formula.atom (atomMap p)`, the subsequent substitutions for `freshAM (.const_at_ref p)`, `freshAM .lt_ref`, `freshAM .gt_ref` do **not** further touch the atom `atomMap p`.

This requires: `atomMap p ∉ {freshAM (.const_at_ref q), freshAM .lt_ref, freshAM .gt_ref | q}` for all `p`.

Equivalently: **the range of `atomMap` is disjoint from the range of `freshAM`**.

At the top level, `atomMap` has base `"p"` and `freshAM` has base `"e"`: trivially disjoint.

At recursive levels, both have base `"e"` with potentially overlapping Nat indices.

### Was `h_disj` removed?

The current `atom_elim_correct` signature (line 909–915) has no `h_disj` parameter. The comment at line 905–907 says the hypothesis is needed for the proof. According to the phase-7-handoff-20260517f.md, `h_disj` was removed to "keep the interface clean and compilable." But the proof cannot proceed without it — the sorry at line 916 is precisely where disjointness would be used in the structural induction on `B_sep`.

---

## 3. The Three Options and Their Tradeoffs

### Option A: Different base strings per recursion level

Change `freshAM` to use a depth-indexed base:
```lean
let freshAM : (extSignature sig).preds → Atom :=
  fun ep => Atom.mk_fresh ("e" ++ toString depth) (Fintype.equivFin ...).val
```

Problem: `expressiveness_inner` does not currently receive a `depth` parameter, and threading it through `expressiveness_wf` / `outerIH` would require changing all signatures. The `outerIH` type does not mention depth.

### Option B: Offset indices (recommended in handoff)

Change `freshAM` so that its index range starts above the maximum index in `atomMap`'s range:
```lean
let offset := Fintype.card sig.preds  -- atomMap uses indices 0..card-1
let freshAM : (extSignature sig).preds → Atom :=
  fun ep => Atom.mk_fresh "e" (offset + (Fintype.equivFin (extSignature sig).preds ep).val)
```

But when `atomMap` itself has base `"e"` (at recursive levels), the outer `atomMap` maps `sig.preds` to `mk_fresh "e" 0..(card sig.preds - 1)`. Setting `offset = card sig.preds` means `freshAM` uses indices `card sig.preds .. card sig.preds + card (ExtPred sig) - 1`. These don't overlap with `0..card sig.preds - 1`.

**This works** if we can compute the right offset. But `atomMap` is an arbitrary injective function — we cannot generically determine its index range.

**Conclusion**: Option B only works cleanly when `atomMap` is the specific top-level map with known range. At recursive levels where `atomMap = freshAM_prev`, this requires either (1) knowing the previous `freshAM`'s offset, or (2) threading an offset parameter.

### Option C: Add `h_disj` hypothesis to `atom_elim_correct` and thread it through

Add a hypothesis to `atom_elim_correct`:
```lean
(h_disj : ∀ p : sig.preds, ∀ ep : (extSignature sig).preds,
    atomMap p ≠ freshAM ep  -- or equivalently: Set.range atomMap ∩ Set.range freshAM = ∅)
```

Then in `expressiveness_inner`, prove this hypothesis at each recursive call.

**At top level** (`atomMap` base `"p"`, `freshAM` base `"e"`): immediate from `Atom.mk.injEq`.

**At recursive levels** (`atomMap = freshAM_prev` base `"e"`, new `freshAM` uses same base `"e"`): this is where the gap is. The new `freshAM` would need to use non-overlapping indices.

---

## 4. The Correct Fix: Combine Options B and C

The cleanest approach that avoids changing `atom_elim_correct`'s external interface is:

**Change `freshAM` construction in `expressiveness_inner` so that it provably avoids the range of `atomMap`.**

Since `atomMap : sig.preds → Atom` is an arbitrary injective function, its range is a finite set of `card sig.preds` atoms. We can always find atoms disjoint from any finite set.

### Concrete Fix (Finset-offset approach)

```lean
-- In expressiveness_inner, .ex case:
-- The range of atomMap is a finite set with card sig.preds elements.
-- Choose freshAM to use indices starting above card sig.preds,
-- with base "e" (or any fixed base distinct from whatever atomMap uses).
-- Since atomMap may use "e" at recursive levels, we need the offset.

-- Key observation: atomMap maps sig.preds (finite, card N) injectively.
-- freshAM maps (extSignature sig).preds (finite, card M = 2N+2) to atoms.
-- We need: range(atomMap) ∩ range(freshAM) = ∅.

-- Simple approach: use base "e" but index starting at card sig.preds.
-- This works if atomMap's range uses indices 0..N-1 (which is true if
-- atomMap = freshAM_prev from the previous level).
-- But we cannot know the exact indices of an arbitrary atomMap.
```

The true root cause is that `atom_elim_correct` accepts an *arbitrary* injective `atomMap`, but the disjointness constraint is a structural property of how `expressiveness_inner` constructs `freshAM` relative to that specific `atomMap`.

### The Correct Solution

**Add `h_disj` as a parameter to `atom_elim_correct` AND ensure it is provable at every call site.**

```lean
private theorem atom_elim_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ p : sig.preds, ∀ ep : (extSignature sig).preds,
        atomMap p ≠ freshAM ep)
    (M : IntStructureFromSig sig) (t : Int)
    (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    Separation.int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep) := by
  -- Proof by structural induction on B_sep
  -- Uses h_disj to ensure applySubsts doesn't "double-substitute"
  sorry
```

Then in `expressiveness_inner`, the call at line 1026 becomes:
```lean
exact h_chain.trans (atom_elim_correct atomMap hinj freshAM freshAM_inj h_disj M t B_sep hB_sep)
```

where `h_disj` is proved as follows:

**At top level** (`atomMap` uses base `"p"`, `freshAM` uses base `"e"`):
```lean
have h_disj : ∀ p : sig.preds, ∀ ep : (extSignature sig).preds,
    atomMap p ≠ freshAM ep := by
  intro p ep
  simp only [atomMap, freshAM, Atom.mk_fresh, Atom.mk.injEq]
  intro ⟨hbase, _⟩
  exact absurd hbase (by decide)  -- "p" ≠ "e"
```

**At recursive levels** (`atomMap = freshAM_prev` uses base `"e"` with indices `0..N-1`, new `freshAM` uses base `"e"` with indices `N..N+M-1`):

Fix `freshAM` to use an offset:
```lean
let offset : Nat := Fintype.card sig.preds
let freshAM : (extSignature sig).preds → Atom :=
  fun ep => Atom.mk_fresh "e" (offset + (Fintype.equivFin (extSignature sig).preds ep).val)
```

Then:
```lean
have h_disj : ∀ p : sig.preds, ∀ ep : (extSignature sig).preds,
    atomMap p ≠ freshAM ep := by
  intro p ep
  simp only [freshAM, Atom.mk_fresh, Atom.mk.injEq]
  intro ⟨_, hidx⟩
  -- hidx : (Fintype.equivFin sig.preds p).val = offset + (Fintype.equivFin ...).val
  -- But (Fintype.equivFin sig.preds p).val < card sig.preds = offset
  -- and offset + k ≥ offset, contradiction.
  -- (This requires atomMap = freshAM_prev with known index range)
```

**The gap**: This only works when `atomMap`'s index range is exactly `0..card sig.preds - 1`. At the top level this is guaranteed by definition. At recursive level 1, `atomMap = freshAM_prev` with `freshAM_prev` using base `"e"` and indices `card sig.preds .. card sig.preds + M - 1`. So the recursive `freshAM` must use indices `card sig.preds + M ..`.

This means the offset must be **cumulative** across recursion levels. The `outerIH`'s type must somehow convey the upper bound of `atomMap`'s index range to make this work cleanly.

---

## 5. Is `freshAM_inj` Sufficient?

**No.** Injectivity of `freshAM` alone is not enough.

The proof of `atom_elim_correct` by structural induction on `B_sep` requires that when `applySubsts` processes `origSubs` (which replaces `freshAM (.orig p)` with `Formula.atom (atomMap p)`), the subsequent entries in `constSubsList` (which look for `freshAM (.const_at_ref q)`) do not accidentally match `atomMap p`.

The substitution `subst_formula φ (freshAM (.const_at_ref q)) r` will trigger on any occurrence of `freshAM (.const_at_ref q)` in `φ`, including occurrences that were just introduced as `Formula.atom (atomMap p)` in the previous step. This only causes a problem if `atomMap p = freshAM (.const_at_ref q)` for some `p, q` — which is exactly what disjointness rules out.

Injectivity of `freshAM` tells us `freshAM (.orig p) ≠ freshAM (.const_at_ref q)` (since `.orig p ≠ .const_at_ref q`). But it says nothing about `atomMap p` vs `freshAM (.const_at_ref q)`.

---

## 6. What `to_int_struct` Does and What Disjointness Enables

The model `to_int_struct (extIntStruct M t) freshAM` assigns:
```
val a = {z | ∃ ep, freshAM ep = a ∧ (extIntStruct M t).interp ep z}
```

Since `freshAM` is injective, membership at `freshAM ep` exactly tracks `(extIntStruct M t).interp ep z`.

The model `to_int_struct M atomMap` assigns:
```
val a = {z | ∃ p, atomMap p = a ∧ M.interp p z}
```

The `quantElimFormula` is built over `to_int_struct M atomMap`. For the proof of `atom_elim_correct` to go through, the substitutions in `elimExtFromSep` must:

1. Replace `freshAM (.orig p)` atoms with formulas equivalent in `to_int_struct M atomMap` to `M.interp p z`.
2. Replace `freshAM (.const_at_ref p)` atoms with either `⊤` or `⊥` depending on `M.interp p t`.
3. Replace `freshAM .lt_ref` and `freshAM .gt_ref` atoms with `⊤` or `⊥` depending on the time context.

Step 1 introduces `atomMap p` atoms into the formula. Step 2 must not modify these. This is exactly what `h_disj` (atomMap range disjoint from freshAM range) guarantees.

---

## 7. Proposed Fix: Concrete Lean Code

### Step 1: Add `h_disj` parameter to `atom_elim_correct`

```lean
private theorem atom_elim_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep)
    (M : IntStructureFromSig sig) (t : Int)
    (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    Separation.int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep) := by
  sorry -- proof by structural induction on B_sep
```

### Step 2: Change `freshAM` construction in `expressiveness_inner`

In **both** the `.ex` and `.all` cases, change:

```lean
-- OLD (indices 0..M-1, may overlap with atomMap at recursive levels):
let freshAM : (extSignature sig).preds → Atom :=
  fun ep => Atom.mk_fresh "e" (Fintype.equivFin (extSignature sig).preds ep).val

-- NEW (indices card(sig.preds)..card(sig.preds)+M-1):
-- NOTE: At the top level, atomMap uses base "p", so even index 0 would be safe.
-- But to work uniformly at all recursion levels, we use a different base entirely.
-- The cleanest fix: freshAM uses base "fresh_ext" (never used by any atomMap).
let freshAM : (extSignature sig).preds → Atom :=
  fun ep => Atom.mk_fresh "fresh_ext" (Fintype.equivFin (extSignature sig).preds ep).val
```

Then `h_disj` becomes provable from the structure of atoms alone, without knowing the atomMap's index range:

```lean
have h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds),
    atomMap p ≠ freshAM ep := by
  intro p ep
  simp only [freshAM, Atom.mk_fresh, Atom.mk.injEq, not_and]
  -- Goal: atomMap p ≠ {base := "fresh_ext", fresh_index := some k}
  -- This is NOT provable in general, since atomMap is arbitrary.
```

**This fails**: `atomMap` is arbitrary and might use base `"fresh_ext"`.

### Step 3: The Correct Structural Fix

The fundamental issue is that `expressiveness_inner` receives an **arbitrary** injective `atomMap` and must construct a `freshAM` with disjoint range. With an arbitrary `atomMap`, we cannot pick a fixed base string that is guaranteed to avoid it.

**The correct approach** is to change `expressiveness_inner`'s interface to also pass a **finite set of atoms to avoid**:

```lean
-- Add to expressiveness_inner's parameters:
(atomMap_range : Finset Atom)
(h_atomMap_range : ∀ p, atomMap p ∈ atomMap_range)

-- Then construct freshAM using Atom.fresh_for extended to M atoms:
-- (requires M distinct fresh atoms all outside atomMap_range)
```

But this changes `expressiveness_wf` and the outer `outerIH` type significantly.

### Simplest Working Fix (Recommended)

**The simplest fix that works**: change `atom_elim_correct` to require `h_disj`, AND change `freshAM` construction in `expressiveness_inner` to use `Atom.fresh_for` to produce atoms outside the range of `atomMap`.

Since `sig.preds` is a `Fintype`, `atomMap` has a finite range. We can compute:
```lean
let atomMap_range : Finset Atom :=
  (Finset.univ : Finset sig.preds).image atomMap
```

Then construct `freshAM` using any injective function whose range avoids `atomMap_range`. Since `ExtPred sig` is finite (size `2 * card sig.preds + 2`), we need that many fresh atoms:

```lean
-- Use the Nat-indexed fresh atoms starting from the first index not in atomMap_range
-- The existing Atom.mk_fresh gives us a countable supply; we just need to pick
-- card (ExtPred sig) distinct atoms not in atomMap_range.
-- One approach: use mk_fresh "e" with offset = max index in atomMap_range + 1,
-- but this assumes atomMap only uses base "e".
```

**The truly clean fix** that avoids all of these issues: **add `h_disj` to `atom_elim_correct` and prove it at each call site by choosing `freshAM` to use a distinct base string from `atomMap`, threading the base string through the induction.**

Concretely: change `outerIH` to also take an "avoid" base string and use a different base for `freshAM` at each depth. At depth 0, `atomMap` uses `"p"` so `freshAM` uses `"e"`. At depth 1, `atomMap` uses `"e"` (since depth-0 `freshAM` used `"e"`), so `freshAM` must use a different string. But without threading, we cannot know this.

---

## 8. Confidence Assessment

**High confidence** on:
- The disjointness gap is real and is the sole blocker for `atom_elim_correct`
- `freshAM_inj` alone is insufficient; range-disjointness is genuinely needed
- The problem only manifests at recursion depth ≥ 2 (nested quantifiers)
- Disjointness is needed to prevent "double substitution" in `applySubsts`
- The `to_int_struct` construction requires disjointness for the model transfer to be correct

**Medium confidence** on:
- The exact form of `h_disj` that will typecheck cleanly
- Whether changing `outerIH`'s type is necessary or if a local fix suffices

**Recommendation**:
The least-invasive fix that closes the sorry without changing `outerIH`'s external type is:

1. Add `h_disj : ∀ p ep, atomMap p ≠ freshAM ep` to `atom_elim_correct`.
2. In `expressiveness_inner`, after constructing `freshAM`, prove `h_disj` using the fact that `freshAM` can be constructed to avoid `atomMap`'s finite range — either by using `Finset.image` to compute the range and choosing fresh indices above it, or (most robustly) by using a different base string and threading a "used bases" invariant through `outerIH`.

The deepest root issue is that the `outerIH` type (line 930–935) does not encode any constraint on `atomMap'`'s range, so downstream `freshAM` constructions have no information to avoid it. **The minimal fix**: add an additional parameter `(atomMap_card : Nat) (h_range_bound : ∀ p, (Fintype.equivFin sig.preds p).val < atomMap_card)` to `expressiveness_inner` and use `atomMap_card` as the index offset for `freshAM`. This is provable at every call site since `atomMap_card = card sig.preds` at the top level, and the recursive call passes `card (extSignature sig).preds` as the new card.
