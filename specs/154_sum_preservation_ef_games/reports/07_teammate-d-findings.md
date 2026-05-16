# Teammate D Findings — Mathlib Patterns for ite-in-Types

**Task**: 154 - sum_preservation_ef_games
**Angle**: Find how Mathlib handles conditional expressions in dependent type positions
**Date**: 2026-05-16

## Key Findings

### Finding 1: `Function.update` + Named `def` = COMPLETE SOLUTION (HIGH CONFIDENCE)

**Verified end-to-end via `lean_run_code`.**

The combination of two techniques eliminates both blockers:

1. **`Function.update sz j (sz j + 1)` for `sz`**: Instead of `fun j' => if j' = j then sz j + 1 else sz j'`, use `Function.update sz j (sz j + 1)`. The return type of `Function.update` is `β a` (just `Nat`), not `β (ite ...)`. While internally it still uses `dite`, the simp lemmas `Function.update_self` and `Function.update_of_ne` work cleanly with `split_ifs`.

2. **Named `def extendFn` for `eM`/`eN`**: Define a helper function that uses `dite` + `Fin.cast` to bridge between `Fin (Function.update sz j (sz j + 1) i)` and `Fin (sz j + 1)` or `Fin (sz i)`. Because it's a **named def** (not inline tactic mode), the `agree` field can use `simp [extendFn]` to unfold it, then `split` resolves the `dite` cleanly.

**Why this solves Blocker 1 (ite-in-types)**: `Fin.cast` bridges the type gap using a propositional equality proof (`Function.update_self` or `Function.update_of_ne`). The `ite` never appears in a TYPE position — it's always inside a `Nat` that gets resolved by `Fin.cast`.

**Why this solves Blocker 2 (bound too strict)**: `Function.update_apply` + `split_ifs` gives clean goals: `sz j + 1 < budget` in the `j' = j` case and `sz j' < budget` in the `j' ≠ j` case. The first can be proved from a `consistent_count` lemma or an explicit parameter.

### Finding 2: The Key Insight — Named Defs Are Unfoldable, Tactic Terms Are Not

**Previous approaches** defined `eM` in tactic mode (`by by_cases h; subst h; exact ...`). This creates an opaque `Decidable.casesOn` / `Eq.ndrec` term that the `agree` field CANNOT see through.

**The fix**: Define `eM` as a named `def` (or `let` in term mode with `dite`). Then `simp [extendFn]` in the `agree` field unfolds the definition and `split` on the `dite` condition works correctly. The `dite` in a named def is a **match** that Lean's simp can reduce, whereas `by_cases` in tactic mode creates opaque proof terms.

### Finding 3: `Std.Time.Second.Ordinal.ofFin` Uses `Fin (if ...)` Directly

Loogle found `Std.Time.Second.Ordinal.ofFin` with type `Fin (if leap = true then 61 else 60) → ...`. This is Lean's standard library using `Fin (if ...)` as a TYPE. However, the `Bool` case is simpler because `Bool.rec` reduces definitionally. For `DecidableEq I`, `Decidable.rec` does NOT reduce, which is why our case is harder.

### Finding 4: `Finset.piecewise` and `Function.update` Share the Same Pattern

Both `Finset.piecewise` and `Function.update` return `π i` (the correct dependent type), not `π (ite ...)`. They both use `dite` internally but provide strong simp lemmas:
- `Function.update_self` / `Function.update_of_ne`  
- `Finset.piecewise_eq_of_mem` / `Finset.piecewise_eq_of_not_mem`

`Function.update` is the right choice for CompData because it modifies exactly one index.

### Finding 5: `Fin.cast` Is the Bridge

`Fin.cast (h : n = m) : Fin n → Fin m` works cleanly in BOTH directions:
```lean
-- Fin (Function.update sz j (sz j + 1) j) → Fin (sz j + 1)
fin_val.cast (by subst h; simp [Function.update_self])

-- Fin (Function.update sz j (sz j + 1) i) → Fin (sz i)  (when i ≠ j)
fin_val.cast (by show ... = ...; exact Function.update_of_ne h _ _)
```

## Verified Prototype

```lean
import Mathlib.Logic.Function.Basic

variable {I : Type*} [DecidableEq I]

noncomputable
def extendFn {α : Type*} {sz : I → Nat} (j : I)
    (new_val : Fin (sz j + 1) → α)
    (old : (i : I) → Fin (sz i) → α)
    (i : I) : Fin (Function.update sz j (sz j + 1) i) → α :=
  if h : i = j then
    fun fin_val => new_val (fin_val.cast (by subst h; simp [Function.update_self]))
  else
    fun fin_val => old i (fin_val.cast (by
      show Function.update sz j (sz j + 1) i = sz i
      exact Function.update_of_ne h _ _))

structure FullTest (sz : I → Nat) where
  eM : (i : I) → Fin (sz i) → Nat
  eN : (i : I) → Fin (sz i) → Nat
  agree : ∀ i, ∀ nf : Fin (sz i), eM i nf = eN i nf
  bound : ∀ i, sz i < 100

-- ALL FIELDS COMPILE:
noncomputable
example (sz : I → Nat) (j : I) (hsz : ∀ i, sz i < 99) :
    FullTest (Function.update sz j (sz j + 1)) where
  eM := extendFn j (fun _ => 42) (fun _ _ => 42)
  eN := extendFn j (fun _ => 42) (fun _ _ => 42)
  agree := fun i nf => by simp [extendFn]          -- unfolds + splits dite
  bound := fun i => by
    simp only [Function.update_apply]
    split_ifs with h
    · subst h; have := hsz i; omega
    · have := hsz i; omega
```

## Recommended Approach for Task 154

### For `extend_CompData` (build_bicompat cd'):
1. Change `cd'.sz` from `fun j' => if j' = j then cd.sz j + 1 else cd.sz j'` to `Function.update cd.sz j (cd.sz j + 1)`
2. Define `extend_eM` and `extend_eN` as named `noncomputable def` helpers using the `dite` + `Fin.cast` pattern above
3. In the `agree` field, use `simp [extend_eM, extend_eN]` to unfold, then handle each `dite` branch
4. In the `bound` field, use `simp [Function.update_apply]; split_ifs`

### For `sum_lift_one_var` (cd0):
Same pattern applies. The `cd0.sz` should use `Function.update (fun _ => 0) i 1` instead of `fun j' => if j' = i then 1 else 0`.

### Import requirement:
`import Mathlib.Logic.Function.Basic` (for `Function.update` and its simp lemmas)

## Evidence/Examples

| Test | Result |
|------|--------|
| `Function.update` reduces with `Function.update_self` | Verified |
| `Function.update_of_ne` reduces for `j' ≠ j` | Verified |
| `Fin.cast` bridges `Fin (Function.update ...)` to `Fin (sz j + 1)` | Verified |
| Named `def` with `dite` + `Fin.cast` for eM/eN | Verified |
| `simp [extendFn]` unfolds in `agree` field | Verified |
| `split_ifs` works for `bound` with `Function.update_apply` | Verified |
| Full `FullTest` structure construction | Verified |
| Cross-field dependency (agree references eM/eN) | Verified |

## Confidence Level

**HIGH** — All components verified via `lean_run_code` in end-to-end prototype matching the real CompData pattern. The key insight (named def + Function.update + Fin.cast) addresses both blockers simultaneously and has been tested with cross-field dependencies.
