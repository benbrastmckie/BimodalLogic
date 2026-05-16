# Teammate A Findings: Primary Approach for Fixing 15 Build Errors

**Task**: 154 — Sum preservation for k-equivalence of ordered monadic structures
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
**Scope**: 15 build errors in `build_bicompat` (Category 2) and `sum_lift_one_var` (Category 4)
**Date**: 2026-05-15

---

## Key Findings

### Finding 1: Category 2 — The Exact Elaboration Failure for `.1` on `Fin.cons`

**Error locations**: Lines 547–550 and 628–631 (duplicated in fwd/bwd oracle arms).

**Root cause**: `Fin.cons` is a *dependent* function:
```
Fin.cons : {n : ℕ} → {α : Fin (n+1) → Sort u} → α 0 → ((i : Fin n) → α i.succ) → (i : Fin (n+1)) → α i
```
When `env_M : Fin n → (orderedSum sig I ms).carrier` (a *non-dependent* function), Lean cannot infer the motive `α` from the second argument, so `Fin.cons (show T from ⟨j, c⟩) env_M` fails to elaborate with a known result type. Consequently, `(Fin.cons ... env_M p).1` — the `.1` Sigma projection — cannot be resolved because Lean does not know the result type is `Sigma (...)`.

The `show T from x` pattern elaborates to `(have this := ⟨j, c⟩; this)` in the goal state. This is visible in the LSP goal at line 547: the environment elements appear as `(have this := ⟨j, c⟩; this)` rather than typed Sigma terms.

**Verified**: `Matrix.vecCons` (non-dependent) and `Fin.cons` (dependent) are definitionally equal for non-dependent functions (`rfl` proves it), but `Matrix.vecCons` successfully supports `.1` projection while `Fin.cons` does not in this context.

**Minimal fix for h_idx'**: The current term-mode proof `Fin.cases rfl (fun k => h_idx k)` must be replaced with a tactic proof that defines the extended environments as explicit `let` bindings using `fun p => Fin.cases ⟨j, c⟩ env_M p`, then proves the index equality via `Fin.cases` case split.

The concrete replacement for each occurrence of `h_idx'`:

```lean
-- Replace the current h_idx' (which fails to elaborate) with:
let envM_ext : Fin (n + 1) → (orderedSum sig I ms).carrier :=
  fun p => Fin.cases (⟨j, c⟩ : (orderedSum sig I ms).carrier) env_M p
let envN_ext : Fin (n + 1) → (orderedSum sig I ms').carrier :=
  fun p => Fin.cases (⟨j, c'⟩ : (orderedSum sig I ms').carrier) env_N p
have h_idx' : ∀ p : Fin (n + 1), (envM_ext p).1 = (envN_ext p).1 := by
  intro p
  refine Fin.cases ?_ ?_ p
  · rfl   -- both project to j
  · intro k; exact h_idx k
```

**Verified working**: `Fin.cases x env` is definitionally equal to `Fin.cons x env` (`rfl` proves it, confirmed by `lean_run_code`), so the `cd'` construction and the recursive `build_bicompat` call can use `envM_ext` and `envN_ext` directly. The `.1` on `envM_ext p` works because `envM_ext p` has known type `(orderedSum sig I ms).carrier = Sigma (fun i => (ms i).carrier)`.

The `h_atoms_ext` hypothesis refers to `Fin.cons (show _ from ⟨j, c⟩) env_M`. Since `envM_ext = Fin.cons ⟨j, c⟩ env_M` by `rfl`, the `cd'` structure body and the recursive call work without any `show`-related transport.

---

### Finding 2: Category 4A — `subst h` Eliminates the Wrong Variable

**Error location**: Line 788 `Unknown identifier 'i'`.

**Root cause**: In the `agree` field proof, `by_cases h : j' = i` is followed by `subst h`. Lean's `subst` tactic with `h : j' = i` eliminates `i` (not `j'`), even though `i` is the function parameter introduced first.

**Verified experimentally** via `lean_run_code`:
```lean
-- After `subst h` with h : j' = i (both locals):
-- Context before: i : I, j' : I, h : j' = i
-- Context after:  j' : I  (i is gone, renamed to j')
-- This holds even when i is a named function parameter!
```

Lean's `subst` eliminates whichever variable appears on the RHS when both sides are free locals, regardless of introduction order. The substitution is `i := j'`, leaving `j'` in scope and eliminating `i`.

**Consequence**: After `subst h`, the identifier `i` no longer exists. The tactic `simp only [show (if i = i then 1 else 0) = 1 from if_pos rfl, ...]` at line 788 fails with "Unknown identifier `i`" because `i` was eliminated.

**Fix**: Replace `subst h` with `simp only [h, if_pos h]` (or just `simp [h]`) in the agree field's `case pos` branch. This rewrites the goal using `h : j' = i` without eliminating either variable from context.

---

### Finding 3: Category 4B — Opaque `show T from by rw` in `eM`/`eN` Blocks Reduction

**Error locations**: Lines 792, 794, 800, 802, 812.

**Root cause**: The current `eM` and `eN` definitions use:
```lean
show Fin (if j' = i then 1 else 0) → (ms j').carrier from
  by rw [if_pos h, h]; exact fun q => (![a]) q
```
This pattern creates an opaque `Eq.mpr`-based term that `simp`, `dif_pos`, and `convert` cannot reduce.

The LSP goal state at line 791 confirms: the `eM j'` in the goal appears as `if h : True then (have this := ⋯.mpr (⋯.mpr fun q ↦ ![a] q); this) else ...`. Neither `dif_pos rfl` nor `dif_pos trivial` simplifies the inner `have this := ...` opacity. The `simp [dif_pos rfl]` at line 792 produces goal `k = k + 1 - if j' = j' then 1 else 0` (a numeric equality) on which `funext` is incorrectly applied.

**Fix**: Change `eM` and `eN` to use a transparent definition:

```lean
eM := fun j' q =>
  if h : j' = i
  then h ▸ a                              -- ignore q; Fin 1 is trivially satisfied
  else Fin.elim0 (Fin.cast (if_neg h) q)  -- q : Fin 0 via cast from Fin (if j' = i then 1 else 0)

eN := fun j' q =>
  if h : j' = i
  then h ▸ b
  else Fin.elim0 (Fin.cast (if_neg h) q)
```

**Verified working** via `lean_run_code`:
- `Fin.cast (if_neg h) q` successfully casts `q : Fin (if j' = i then 1 else 0)` to `Fin 0` when `h : j' ≠ i`.
- `simp` proves `(if h : i = i then h ▸ a else Fin.elim0 (Fin.cast (if_neg h) q)) = a` directly.
- `eM i = fun _ => a` follows from `simp` (confirmed).
- The consistent field existential becomes: `refine ⟨⟨0, by simp⟩, ?_⟩; simp` (confirmed working).

With the old `show T from by rw` definition, `simp` cannot reduce `eM j'` for any `j'`. With the new definition, `simp` fully reduces it.

---

### Finding 4: Category 4C — The `bound` Proof Is Mathematically Broken for k = 0

**Error location**: Line 805 (`omega could not prove the goal: No usable constraints`).

**Root cause**: This is a genuine mathematical impossibility, not merely a tactic failure.

The `cd0` CompData uses `budget = k + 1` and `sz i = 1`. The `bound` field requires `sz j' < budget` for all `j'`. For `j' = i`: `sz i = 1 < k + 1`. This requires `k ≥ 1`.

When `k = 0`: `sz i = 1 < 1` is FALSE. There is no valid proof.

**Why `sz i = 1` is mandatory**: The `consistent` field requires, for each `p : Fin 1` with `(envM p).1 = j'`, that `∃ q : Fin (sz j')` witnessing the correspondence. Since `envM` maps to component `i`, we need `∃ q : Fin (sz i)`, which requires `Fin (sz i)` to be nonempty, i.e., `sz i ≥ 1`.

**Why increasing `budget` to `k + 2` cannot fix it**: The `agree` field needs agreement at depth `(budget - sz i)` for `sz i` variables. With `budget = k + 1` and `sz i = 1`: depth = `k + 1 - 1 = k`. This exactly matches `h_agree_comp` (which provides depth-`k` for 1 variable). Increasing budget to `k + 2` would require depth-`(k+1)` for 1 variable, which `h_agree_comp` does not provide. `nf_agreement_monotone` goes only downward (from higher to lower depth), so depth-`k` cannot produce depth-`(k+1)`.

**Confirmed**: `1 < k' + 1 + 1` (for `k = succ k'`, i.e., `k ≥ 1`) is provable by `omega`.

**The mathematical fix**: Case-split `sum_lift_one_var` on `k`:

- **`k = 0`**: `BiCompat sig 0 1 = True` (trivially, by the `| 0, ... => trivial` case of `build_bicompat`). No `cd0` is needed. Construct directly:
  ```lean
  have h_bc : BiCompat sig 0 1 I ms ms' envM envN := trivial
  exact sum_nf_lift_gen sig 0 1 I ms ms' (fun m hm => h_comp m (by omega))
    envM envN h_atoms_1 h_bc sub_nf
  ```
  For `k = 0`, `sum_nf_lift_gen` at depth 0 uses only `h_atoms_1` to close the goal — the `BiCompat` is never accessed.

- **`k = succ k'`**: Use the full `cd0` construction with `budget = k + 1 = k' + 2`.
  - Bound: `sz i = 1 < k' + 2` by `omega` (since `k' ≥ 0` implies `k' + 2 ≥ 2 > 1`). ✓
  - Agree: depth `(k' + 2 - 1) = k' + 1 = k` for 1 var. ✓ (matches `h_agree_comp`)

---

### Finding 5: Category 4D — Residual Error in `consistent` at Line 812

**Error**: `Application type mismatch: rfl has type ?m = ?m but expected 0 < if i = i then 1 else 0`.

With the current opaque `eM` definition, after `simp only [dif_pos rfl, show (if i = i then 1 else 0) = 1 from if_pos rfl]`, the `⟨0, rfl⟩` witness fails because `rfl` cannot prove `0 < if i = i then 1 else 0` (the `if` is stuck and not reduced to `1`).

With the new transparent `eM` definition, this becomes `⟨⟨0, by simp⟩, by simp, by simp⟩` — all three `simp` calls succeed because `simp` can reduce the new `eM` at `j' = i`.

---

## Recommended Approach

### Two-Phase Refactoring

**Phase 1: Fix Category 2** (h_idx' in build_bicompat) — Low complexity, high confidence.

The `h_idx'` definition occurs twice (forward oracle, lines 547–550; backward oracle, lines 628–631). Replace both with the `envM_ext` / `envN_ext` `let`-binding pattern. Also update the `cd'` struct body and the recursive `build_bicompat` call to use `envM_ext`/`envN_ext` instead of `Fin.cons (show _ from ⟨j, c⟩) env_M`.

```lean
-- In the forward oracle body (d + 1 case):
let envM_ext : Fin (n + 1) → (orderedSum sig I ms).carrier :=
  fun p => Fin.cases (⟨j, c⟩ : (orderedSum sig I ms).carrier) env_M p
let envN_ext : Fin (n + 1) → (orderedSum sig I ms').carrier :=
  fun p => Fin.cases (⟨j, c'⟩ : (orderedSum sig I ms').carrier) env_N p
have h_idx' : ∀ p : Fin (n + 1), (envM_ext p).1 = (envN_ext p).1 :=
  fun p => Fin.cases rfl (fun k => h_idx k) p
have cd' : CompData sig I ms ms' budget envM_ext envN_ext h_idx' := { ... }
exact build_bicompat d (n + 1) (by omega) envM_ext envN_ext h_idx' h_atoms_ext cd'
```

Note: `h_atoms_ext` at lines 536–544 is stated for `Fin.cons (show _ from ⟨j, c⟩) env_M`. Since `envM_ext = Fin.cons ⟨j, c⟩ env_M` definitionally, the `cd'` body fields (sz, eM, eN, agree, bound, consistent) work with `envM_ext` without modification. The `h_atoms_ext` argument to `build_bicompat` also works by definitional equality.

**Phase 2: Fix Category 4** (cd0 in sum_lift_one_var) — Medium complexity, requires case-split.

Replace the current monolithic `sum_lift_one_var` body with two branches:

```lean
-- Branch 1: k = 0
-- BiCompat sig 0 1 = trivially True; no cd0 needed
have h_bc : BiCompat sig 0 1 I ms ms' envM envN := trivial
exact sum_nf_lift_gen sig 0 1 I ms ms'
  (fun m hm => h_comp m (by omega)) envM envN h_atoms_1 h_bc sub_nf

-- Branch 2: k = succ k' (k ≥ 1)
-- Use cleaner eM/eN definitions:
have cd0 : CompData sig I ms ms' (k + 1) envM envN h_idx_1 := {
  sz := fun j' => if j' = i then 1 else 0
  eM := fun j' q => if h : j' = i then h ▸ a else Fin.elim0 (Fin.cast (if_neg h) q)
  eN := fun j' q => if h : j' = i then h ▸ b else Fin.elim0 (Fin.cast (if_neg h) q)
  agree := fun j' => by
    by_cases h : j' = i
    · simp only [h, if_pos rfl, Nat.succ_sub_one]
      -- Goal: ∀ nf : NF sig k 1, nf_eval (ms j') k 1 (fun _ => h ▸ a) nf ↔ ...
      intro nf
      convert h_agree_comp nf using 2 <;> (funext q; fin_cases q; simp)
    · simp only [if_neg h]
      -- Goal: ∀ nf : NF sig (k+1) 0, nf_eval (ms j') (k+1) 0 Fin.elim0 nf ↔ ...
      intro nf
      have := h_comp (k + 1) le_rfl j' nf
      convert this using 2 <;> (funext q; exact Fin.elim0 q)
  bound := fun j' => by
    by_cases h : j' = i
    · simp [h]; omega  -- sz i = 1 < k + 1; works because k = succ k' ≥ 1
    · simp [h]         -- sz j' = 0 < k + 1
  consistent := fun p j' hj' => by
    fin_cases p
    simp only [h_envM] at hj'
    subst hj'  -- eliminates j' (hj' : i = j'), leaves i
    refine ⟨⟨0, by simp⟩, by simp, by simp⟩
}
```

---

## Evidence Summary

| Issue | Status | Verification |
|-------|--------|-------------|
| `.1` on `Fin.cons (show T from x) env_M p` fails to elaborate | Confirmed | `lean_run_code` exact error reproduced |
| `Fin.cases x env = Fin.cons x env` definitionally | Confirmed | `rfl` succeeds in `lean_run_code` |
| `let envM_ext := Fin.cases x env; (envM_ext p).1` works | Confirmed | Tactic proof succeeds |
| `subst h` with `h : j' = i` eliminates `i` (not `j'`) | Confirmed | `trace_state` shows `j' : I` after subst |
| `show T from by rw; exact` creates opaque `Eq.mpr` term | Confirmed | `dif_pos rfl` cannot reduce residual `have this := ...` |
| New `eM := fun j' q => if h : j' = i then h ▸ a else Fin.elim0 (Fin.cast (if_neg h) q)` | Verified | `simp` reduces `eM i = fun _ => a` |
| `bound: sz i = 1 < k + 1` unprovable for abstract `k` | Confirmed | `omega` fails on `1 < k + 1` (`1 < 1` for `k = 0`) |
| `bound: 1 < k' + 1 + 1` (for `k = succ k'`) | Confirmed | `omega` succeeds |
| For `k = 0`, `BiCompat sig 0 1 = trivial` bypasses `bound` | Architecture confirmed | `| 0, ... => trivial` pattern in `build_bicompat` |

---

## Confidence Level

**Category 2 fix (h_idx')**: HIGH. The `envM_ext / envN_ext` let-binding approach is verified by `lean_run_code`. The `Fin.cases = Fin.cons` definitional equality means zero semantic changes to downstream logic. This fix requires only local rewrites at two symmetric locations.

**Category 4A fix (avoid subst)**: HIGH. Using `simp [h]` instead of `subst h` in the agree field is a straightforward change with verified behavior. The key insight — that `subst h` with `h : j' = i` eliminates `i` (the outer parameter) rather than `j'` — is fully confirmed experimentally.

**Category 4B fix (cleaner eM)**: HIGH. The `Fin.cast (if_neg h)` approach is verified working in `lean_run_code`. `simp` correctly reduces the new `eM`/`eN` definition at the relevant case positions. The consistent field becomes trivial.

**Category 4C fix (case-split on k)**: HIGH. The mathematical obstruction is genuine (proven by showing `1 < k + 1` is false for `k = 0`) and the case-split is the correct resolution. For `k = 0`, `BiCompat sig 0 1 = True` by the `| 0 => trivial` case, requiring no CompData. For `k = succ k'`, bound holds by `omega`.

**Overall**: These are surgical fixes that do not require restructuring `CompData`, `build_bicompat`, or `sum_nf_lift_gen`. All changes are localized to `h_idx'` (two symmetric occurrences in `build_bicompat`) and `cd0` (in `sum_lift_one_var`).

---

## Relation to Previous Work

The observation that `nf_agreement_monotone` successfully bridges depth mismatches is consistent with the findings here: in the `agree` field of `cd0` for `k = succ k'`, the `j' = i` case uses `h_agree_comp` directly (same depth), and the `j' ≠ i` case uses `h_comp (k+1) le_rfl` directly. No monotonicity bridge is needed at this level.

The `cast (by congr 1; omega) x` pattern consistently fails because `congr 1` on `NormalForm sig d n` produces separate goals for `d` and `n`, but the cast changes both simultaneously. This is consistent with Category 4B: the `show T from by rw [...]` pattern is similarly opaque to reduction tactics.
