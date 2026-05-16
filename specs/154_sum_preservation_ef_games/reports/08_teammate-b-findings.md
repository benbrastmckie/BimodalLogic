# Teammate B Findings: Lean 4 / Mathlib Best Practices for ite in Dependent Types

## Executive Summary

The standard Mathlib idiom for "a function that differs at one point" is `Function.update`, not manual `ite`/`dite`. This solves the opaque-DecidableEq problem because `Function.update_self` is proved via `dif_pos rfl` (which works regardless of instance opacity) and is tagged `@[simp]`. Refactoring `CompData.sz` to use `Function.update` eliminates all 9+ manual `rw [if_pos h]` calls across the 3 construction sites.

## Research Question 1: How Mathlib Handles ite/dite in Dependent Type Positions

### Key Finding

Mathlib **avoids** placing raw `ite`/`dite` in type-defining positions whenever possible. Instead, it uses:

1. **`Function.update`** for "function modified at one point" (the exact CompData pattern)
2. **`Fin.cons` / `Fin.snoc`** for extending tuples
3. **`Pi.single`** for "zero everywhere except one point" (additive version)

When `ite` does appear in types, Mathlib relies on `split_ifs`, `if_pos`, `if_neg`, and `simp` -- but these work because Mathlib's `DecidableEq` instances are usually structurally transparent. The CompData problem is specifically that `LinearOrder.decidableEq` is opaque.

### The Opacity Problem Explained

```
-- LinearOrder provides DecidableEq, but it's opaque to the kernel:
instance instDecidableEq_mathlib (a b : I) : Decidable (a = b) := LinearOrder.decidableEq a b

-- This means the kernel CANNOT reduce:
--   if j = j then X else Y  -->  X   (STUCK!)
-- But tactic-level rewrites still work:
--   rw [if_pos rfl]          -- works (doesn't need reduction)
--   simp                     -- works (uses simp lemmas)
```

## Research Question 2: Function.update as the Standard Mathlib Idiom

### YES -- Function.update is the canonical pattern

**Definition** (from `Mathlib.Logic.Function.Basic`):
```lean
def Function.update (f : forall a, beta a) (a' : alpha) (v : beta a') (a : alpha) : beta a :=
  if h : a = a' then Eq.ndrec v h.symm else f a
```

**Key properties** (all `@[simp]`):

| Lemma | Type | Proof |
|-------|------|-------|
| `Function.update_self` | `update f a v a = v` | `dif_pos rfl` |
| `Function.update_of_ne` | `a != a' -> update f a' v a = f a` | `dif_neg h` |
| `Function.update_eq_self` | `update f a (f a) = f` | (equality) |
| `Function.update_idem` | `update (update f a v) a w = update f a w` | |
| `Function.update_comm` | `a != b -> update (update f a v) b w = update (update f b w) a v` | |
| `Function.apply_update` | `f j (update g i v j) = update (fun k => f k (g k)) i (f i v) j` | |

**Critical advantage**: `Function.update_self` is proved by `dif_pos rfl`, which works **regardless of whether DecidableEq is opaque**. The proof term `dif_pos rfl` uses the `rfl : a = a` proof directly without evaluating the decidability instance.

### Comparison: Manual ite vs Function.update

```lean
-- OLD (manual ite, 9+ rw [if_pos h] needed):
sz := fun j' => if j' = j then cd.sz j + 1 else cd.sz j'

-- NEW (Function.update, simp handles everything):
sz := Function.update cd.sz j (cd.sz j + 1)
```

### Verified: simp normalizes Function.update in type positions

```lean
-- simp only [Function.update_self] rewrites INSIDE types:
example (sz : I -> Nat) (j : I) (budget : Nat) 
    (h : forall x : Fin (budget - (sz j + 1)), True) :
    forall x : Fin (budget - Function.update sz j (sz j + 1) j), True := by
  simp only [Function.update_self]
  exact h
-- WORKS! No manual cast needed.
```

## Research Question 3: Handling Opaque DecidableEq

### Three approaches found:

#### Approach A: Function.update (RECOMMENDED)

Completely sidesteps the opacity issue. `Function.update_self`/`Function.update_of_ne` provide the needed equalities without requiring the `DecidableEq` instance to reduce.

#### Approach B: `attribute [local reducible] LinearOrder.decidableEq`

```lean
attribute [local reducible] LinearOrder.decidableEq in
example (j : I) : (if j = j then 42 else 0) = 42 := by rfl
```

**Verified working** but **fragile and discouraged**:
- Depends on knowing the exact instance name
- Can cause performance issues (kernel unfolds too aggressively)
- May break other proofs that rely on opacity
- Not composable with other Mathlib infrastructure

#### Approach C: `open Classical in` / `Classical.dec`

Does NOT help -- `Classical.dec` is also opaque. The issue is opacity of the `Decidable` instance, not which logic system provides it.

### Verdict

**Approach A (Function.update) is the only approach that is both robust and maintainable.**

## Research Question 4: Indexed Family Extension Pattern

### No direct `Fin.update` for indexed families

There is no single Mathlib combinator for "extend an indexed family `(j : I) -> Fin (sz j) -> carrier` by adding one element at index j". The standard approach is:

1. Define the new size: `sz' := Function.update sz j (sz j + 1)`
2. Define the new array using `dite` + `Fin.cons` + `Fin.cast`:

```lean
eM := fun j' x => by
  by_cases h : j' = j
  . subst h
    exact Fin.cons c (cd.eM j) (x.cast (Function.update_self _ _ _))
  . exact cd.eM j' (x.cast (Function.update_of_ne h _ _))
```

### Relevant Mathlib lemmas for Fin.cons + Function.update interaction:

| Lemma | Statement |
|-------|-----------|
| `Fin.cons_update` | `cons x (update p i y) = update (cons x p) i.succ y` |
| `Fin.update_cons_zero` | `update (cons x p) 0 z = cons z p` |
| `Fin.cons_zero` | `cons x p 0 = x` |
| `Fin.cons_succ` | `cons x p i.succ = p i` |
| `Fin.cast_cast` | `cast h' (cast h i) = cast (h.trans h') i` |

## Research Question 5: dite vs ite

### Key insight: `Function.update` uses `dite` internally

```lean
-- Function.update definition:
def update (f : forall a, beta a) (a' : alpha) (v : beta a') (a : alpha) : beta a :=
  if h : a = a' then Eq.ndrec v h.symm else f a
--     ^^^^ dite, not ite
```

The `dite` (dependent if) provides the proof `h : a = a'` in the positive branch, which is needed for `Eq.ndrec` to transport the value `v : beta a'` to type `beta a`. This is why `Function.update` works for dependent type families.

For the CompData case:
- `ite` suffices for `sz` (the Nat-valued function) since both branches have the same type
- But `dite` is needed for `eM`/`eN` because the branch needs `h : j' = j` to perform the type cast
- `Function.update` handles both cases because it uses `dite` + `Eq.ndrec` internally

### Does dite help with reduction?

**No.** Neither `ite` nor `dite` reduce when the `Decidable` instance is opaque. The advantage of `dite` is that it provides the proof in each branch for tactic-level rewrites, but this is already handled by `Function.update`'s lemmas.

## Concrete Refactoring Recommendation for CompData

### Step 1: Change sz definition (all 3 construction sites)

```lean
-- Before:
sz := fun j' => if j' = j then cd.sz j + 1 else cd.sz j'

-- After:
sz := Function.update cd.sz j (cd.sz j + 1)
```

### Step 2: Change eM/eN definitions

```lean
-- Before:
eM := fun j' x => by
  by_cases h : j' = j
  . exact h cast Fin.cons c (cd.eM j) (Fin.cast (if_pos h) x)
  . exact cd.eM j' (Fin.cast (if_neg h) x)

-- After:
eM := fun j' x => by
  by_cases h : j' = j
  . subst h
    exact Fin.cons c (cd.eM j) (x.cast (Function.update_self _ _ _))
  . exact cd.eM j' (x.cast (Function.update_of_ne h _ _))
```

### Step 3: Simplify field proofs

```lean
-- Before (bound):
bound := fun j' => by
  by_cases h : j' = j
  . rw [if_pos h]; exact hbound
  . rw [if_neg h]; exact cd.bound j'

-- After (bound):
bound := fun j' => by
  by_cases h : j' = j
  . subst h; simp [Function.update_self]; exact hbound  -- or omega
  . simp [Function.update_of_ne h]; exact cd.bound j'

-- Before (sz_le_n):
sz_le_n := fun j' => by
  by_cases h : j' = j
  . subst h; simp [if_pos rfl]; exact Nat.succ_le_succ (cd.sz_le_n j')
  . simp [if_neg h]; exact Nat.le_succ_of_le (cd.sz_le_n j')

-- After (sz_le_n):
sz_le_n := fun j' => by
  by_cases h : j' = j
  . subst h; simp [Function.update_self]; exact Nat.succ_le_succ (cd.sz_le_n j)
  . simp [Function.update_of_ne h]; exact Nat.le_succ_of_le (cd.sz_le_n j')
```

### Step 4: Simplify consistent field

```lean
-- Before:
consistent := fun p j' hj' => by
  cases p using Fin.cases with
  | zero =>
    simp [Fin.cons_zero] at hj' |-
    subst hj'
    exact <angbr>angbr<0, by simp [if_pos rfl]>, by simp [dif_pos rfl, Fin.cons_zero],
      by simp [dif_pos rfl, Fin.cons_zero]>

-- After:
consistent := fun p j' hj' => by
  cases p using Fin.cases with
  | zero =>
    simp [Fin.cons_zero] at hj' |-
    subst hj'
    simp only [Function.update_self]
    -- Goal is now clean: exists q : Fin (cd.sz j + 1), ...
    exact <angbr>0, rfl, rfl>  -- or whatever the direct proof is
```

### Expected Impact

| Metric | Before | After |
|--------|--------|-------|
| Manual `rw [if_pos h]` calls | 9+ | 0 |
| Manual `rw [if_neg h]` calls | 6+ | 0 |
| `simp [if_pos rfl]` calls | 6+ | 0 |
| `simp [dif_pos rfl]` / `simp [dif_neg hjj]` | 8+ | 0 |
| Total ite-related proof steps | ~29 | ~6 (just `simp [Function.update_self/of_ne]`) |

## Additional Discovered Patterns

### Pattern: `split` tactic on Function.update

Since `Function.update` is defined with `dite`, the `split` tactic works directly:

```lean
example (sz : I -> Nat) (j j' : I) (P : Nat -> Prop)
    (hj : P (sz j + 1)) (hne : forall j', j' != j -> P (sz j')) :
    P (Function.update sz j (sz j + 1) j') := by
  simp only [Function.update]
  split
  . next h => subst h; exact hj
  . next h => exact hne j' h
```

### Pattern: Bulk normalization with simp at *

```lean
-- When multiple hypotheses contain Function.update expressions:
simp only [Function.update_self, Function.update_of_ne h] at *
-- Normalizes ALL occurrences in ALL hypotheses AND the goal
```

### Pattern: Fin value construction

```lean
-- Constructing Fin values in Function.update types:
-- Instead of: angbr<0, by simp [if_pos rfl]>
-- Use: angbr<0, by rw [Function.update_self]; omega>
-- Or: angbr<0, by simp [Function.update_self]; omega>
```

## Summary of Recommendations

1. **Primary recommendation**: Refactor `CompData.sz` to use `Function.update cd.sz j (cd.sz j + 1)` at all 3 construction sites.

2. **For eM/eN fields**: Keep the `by_cases h : j' = j` pattern but replace `Fin.cast (if_pos h)` with `x.cast (Function.update_self _ _ _)` and `Fin.cast (if_neg h)` with `x.cast (Function.update_of_ne h _ _)`.

3. **For proof fields (agree, bound, sz_le_n, consistent)**: Use `simp only [Function.update_self]` or `simp only [Function.update_of_ne h]` to normalize types before proving the obligations.

4. **Do NOT use** `attribute [local reducible] LinearOrder.decidableEq` -- it's fragile and non-composable.

5. **The refactoring is purely definitional** -- it changes how values are computed but not what they compute. The old `fun j' => if j' = j then cd.sz j + 1 else cd.sz j'` and `Function.update cd.sz j (cd.sz j + 1)` are propositionally (though not definitionally) equal.
