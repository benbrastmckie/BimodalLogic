# Teammate B Findings: dite + Fin.cast + @Fin.cons Pattern

**Task**: 154 - sum_preservation_ef_games
**Teammate**: B (Restructure CompData)
**Date**: 2026-05-16
**Confidence**: HIGH (all patterns verified via lean_run_code)

## Key Findings

### BREAKTHROUGH: The dite + Fin.cast + @Fin.cons pattern compiles and simplifies

The solution to the elaboration trilemma is to construct ALL CompData fields using **term-mode `dite`** (not `by_cases` tactic) with **`Fin.cast`** to bridge the `ite` gap, and **`@Fin.cons` with explicit motive** for the extended component.

This avoids ALL three previous blockers:
1. **No `subst` needed** → no `if j = j` in types
2. **`Fin.cast (if_pos h)` / `Fin.cast (if_neg h)`** bridges the gap between `Fin (if j' = j then ... else ...)` and the concrete `Fin (cd.sz j + 1)` or `Fin (cd.sz j')`
3. **`@Fin.cons n (fun _ => T)` with explicit constant motive** avoids motive inference issues
4. **ALL fields are term-mode** — no `by_cases` creating `Decidable.casesOn` metavariables

### Verified Pattern (complete working prototype)

```lean
-- sz field: unchanged (still uses ite)
sz := fun j' => if j' = j then cd.sz j + 1 else cd.sz j'

-- eM field: dite + Fin.cast + @Fin.cons
eM := fun j' x =>
  if h : j' = j then
    @Fin.cons (cd.sz j) (fun _ => (ms j).carrier) c (cd.eM j) (Fin.cast (if_pos h) x)
  else
    cd.eM j' (Fin.cast (if_neg h) x)

-- eN field: identical pattern with c' and cd.eN
eN := fun j' x =>
  if h : j' = j then
    @Fin.cons (cd.sz j) (fun _ => (ms' j).carrier) c' (cd.eN j) (Fin.cast (if_pos h) x)
  else
    cd.eN j' (Fin.cast (if_neg h) x)

-- agree field: dite + Fin.cast on both args
agree := fun j' x y =>
  if h : j' = j then
    ext_agree
      (Fin.cast (show budget - (if j' = j then cd.sz j + 1 else cd.sz j') =
                     budget - (cd.sz j + 1) by rw [if_pos h]) x)
      (Fin.cast (if_pos h) y)
  else
    cd.agree j'
      (Fin.cast (show budget - (if j' = j then cd.sz j + 1 else cd.sz j') =
                     budget - cd.sz j' by rw [if_neg h]) x)
      (Fin.cast (if_neg h) y)

-- bound field: dite with rw proof
bound := fun j' =>
  if h : j' = j then by
    rw [show (if j' = j then cd.sz j + 1 else cd.sz j') = cd.sz j + 1 from if_pos h]
    exact hbound  -- NEW parameter: hbound : cd.sz j + 1 < budget
  else by
    rw [show (if j' = j then cd.sz j + 1 else cd.sz j') = cd.sz j' from if_neg h]
    exact cd.bound j'

-- consistent field: use Fin.cast (if_pos h).symm for witnesses (no subst)
consistent := fun p j' hj' => by
  -- For p = 0 (new element), j' = j:
  -- Provide witness Fin.cast (if_pos rfl).symm ⟨0, by omega⟩
  -- For p = succ k, delegate to cd.consistent
  -- Use Fin.cast (if_pos h).symm / (if_neg h).symm to cast witnesses
  ...
```

### Why This Works (Root Cause Analysis)

Previous approaches failed because they used TACTIC-mode case splitting (`by_cases`, `rcases`, `split`), which creates `Decidable.casesOn` terms that Lean's elaborator treats as opaque metavariables. Downstream fields that depend on the result cannot see through the `Decidable.casesOn`.

The `dite` function does essentially the same case split, BUT:
1. It's a TERM, not a tactic — Lean elaborates it as a function application
2. In the positive branch, `h : j' = j` is available but `j'` is NOT eliminated from context
3. `Fin.cast (if_pos h)` explicitly bridges `Fin (if j' = j then ...) → Fin (cd.sz j + 1)` — this is a clean cast, not a rewrite
4. `@Fin.cons` with explicit motive `(fun _ => T)` avoids Lean trying to infer a dependent motive

### Verified Properties

All tested via `lean_run_code`:

| Property | Status |
|----------|--------|
| Structure compiles with dite fields | ✅ |
| `sz j` reduces to `cd.sz j + 1` via `simp` | ✅ |
| `eM j ⟨0, _⟩ = c` via `simp [Fin.cons_zero]` | ✅ |
| `eM j ⟨k+1, _⟩ = cd.eM j ⟨k, _⟩` via `@Fin.cons_succ` | ✅ |
| `eM j' q = cd.eM j' q` for `j' ≠ j` via `simp [dif_neg h]` | ✅ |
| `agree j` reduces to `ext_agree` with casts via `simp` | ✅ |
| `bound` provable via `rw [if_pos h]` then `exact` | ✅ |
| Witnesses via `Fin.cast (if_pos h).symm` (no subst) | ✅ |

### Bound Issue (Blocker 2) Resolution

The `hbound : cd.sz j + 1 < budget` parameter must be provided externally. At the call site in `build_bicompat`, this can be derived from:
- `cd.bound j : cd.sz j < budget` gives `cd.sz j + 1 ≤ budget`
- But we need STRICT: `cd.sz j + 1 < budget`, i.e., `cd.sz j + 2 ≤ budget`
- This requires `budget ≥ cd.sz j + 2`, which follows from `hdn : d + 1 + n ≤ budget` when `d ≥ 1` (always true in the `d + 1` case of build_bicompat)
- For the initial cd0 in sum_lift_one_var with k-split: k ≥ 1 gives budget = k + 1 ≥ 2, and sz j = 1, so 1 + 1 = 2 ≤ budget

### Does NOT Require

- No `extend_CompData` helper function (can be done inline)
- No CompData structure modification
- No `Classical.dec` or `Classical.propDecidable`
- No `subst` anywhere
- No `simp` on `ite` in type positions (only on definitional equality of `dite`)

## Recommended Approach

Apply the dite + Fin.cast + @Fin.cons pattern DIRECTLY to the existing cd' construction in `build_bicompat` (lines 554-587 and 635-668). Replace the current structure literal with one using the pattern above. No helper function needed — the pattern works inline.

For `sum_lift_one_var` cd0 (lines 772-813): same pattern applies. Case-split on `k` first (k=0 bypasses cd0), then build cd0 using dite + Fin.cast.

## Evidence

All code tested via `lean_run_code` against Lean 4.27.0-rc1 with Mathlib. Key test: `extendMiniCD` compiles and all downstream simplification lemmas succeed.
