# Research: Cleanest Structural Approach for cd0 in sum_lift_one_var

## Summary of Findings

### 1. What build_bicompat Does at d=0

`build_bicompat` (line 475-488) pattern-matches on `d`:
```lean
| 0, _, _, _, _, _, _, _ => trivial
| d + 1, n, hdn, env_M, env_N, h_idx, h_atoms, cd => ...
```

At `d=0`, it returns `trivial` **immediately** without inspecting any field of `cd` (including `bound`). The `cd` argument is completely dead code at d=0.

Similarly, `BiCompat sig 0 ... = True` (line 165), so the BiCompat result is just `True`.

### 2. sum_nf_lift_gen at d=0 Ignores BiCompat

`sum_nf_lift_gen` (line 768-773) at `d=0`:
```lean
| zero =>
  intro n I _ ms ms' _ env_M env_N h_atoms _ nf
  simp only [nf_eval_nf]
  exact ⟨fun hM a => (h_atoms a).symm.trans (hM a),
         fun hN a => (h_atoms a).trans (hN a)⟩
```

The `_` on line 771 discards the `h_bc : BiCompat sig 0 ...` argument. Only `h_atoms` is used.

### 3. Who Calls sum_lift_one_var

`sum_lift_one_var` is called exclusively from `sum_nf_agree_sentence` (lines 975, 996, 1021, 1041), always within the `| succ k ih_k =>` branch. This means the `k` in `sum_lift_one_var` ranges over all natural numbers (including 0), because when `sum_nf_agree_sentence` is at depth `k+1`, it calls `sum_lift_one_var` with the inner `k`.

**k=0 IS a legitimate case**: When `sum_nf_agree_sentence` processes depth 1, it calls `sum_lift_one_var` with k=0.

Adding `k >= 1` as a hypothesis is NOT viable without restructuring callers.

### 4. The k=0 Edge Case: cd0 is Entirely Unnecessary

At k=0:
- `budget = k + 1 = 1`
- `build_bicompat (budget := 1) 0 1 ... cd0` returns `trivial` (d=0 branch)
- `sum_nf_lift_gen sig 0 1 ... trivial sub_nf` only uses `h_atoms_1`

**Therefore**: For k=0, the entire cd0 construction and `build_bicompat` call can be replaced with:
```lean
exact sum_nf_lift_gen sig 0 1 I ms ms'
    (fun m hm => h_comp m (by omega)) envM envN h_atoms_1 trivial sub_nf
```

### 5. The k>=1 Case: bound is Trivially Provable

For k = k' + 1 (i.e., k >= 1):
- `budget = k + 1 = k' + 2`
- `sz i = 1`
- `bound i` needs `1 < k' + 2`, which is `by omega`

So the sorry in `bound` disappears once we case-split on k.

### 6. The ite-in-types HEq Problem in agree/consistent

Even for k >= 1, the current `eM`/`eN` definitions using `![a]` create unnecessary complexity. The recommended approach:

**Current (problematic)**:
```lean
eM := fun j' => if h : j' = i then
  (show Fin (if j' = i then 1 else 0) → (ms j').carrier from
    by rw [if_pos h, h]; exact fun q => (![a]) q)
  else ...
```

**Recommended (clean)**:
```lean
eM := fun j' x => by
  by_cases h : j' = i
  · exact h ▸ (fun _ : Fin 1 => a) (Fin.cast (if_pos h) x)
  · exact absurd (Fin.cast (if_neg h) x).isLt (by omega)
```

Key benefits:
1. Uses `Fin.cast` pattern (same as working `cd'` in `build_bicompat`)
2. Constant function `fun _ => a` eliminates matrix notation complexity
3. The HEq obligation reduces to proving constant functions with different domain types are HEq (trivial via `Function.hfunext` + `heq_of_eq rfl`)

**Verified working HEq pattern** (tested with lean_run_code):
```lean
have hsz : (if i = i then 1 else 0) = 1 := if_pos rfl
exact Function.hfunext (congrArg Fin hsz) (fun a1 a2 ha => by
  have : a2 = 0 := Fin.eq_zero a2
  subst this
  exact heq_of_eq (by simp [Fin.cons_zero]))
```

### 7. The consistent Field

With constant-function `eM`:
- After `fin_cases p` and `subst hj'` (so j' = i):
- `eM i q = a` for any q (it's constant)
- `eN i q = b` for any q (it's constant)
- `h ▸ (envM 0).2 = eM i q` becomes `a = a` which is `rfl`
- Same for eN side

The sorry in `consistent` becomes provable.

## Recommended Approach

### Structure: Case-split on k at the proof body level

```lean
private noncomputable def sum_lift_one_var ... := by
  -- [setup: envM, envN, h_envM_eq, h_envN_eq, h_idx_1, h_atoms_1 as before]
  rw [← h_envM_eq, ← h_envN_eq]
  match k with
  | 0 =>
    -- Direct proof: no cd0 needed
    exact sum_nf_lift_gen sig 0 1 I ms ms'
      (fun m hm => h_comp m (by omega)) envM envN h_atoms_1 trivial sub_nf
  | k' + 1 =>
    -- cd0 construction with k' + 1 >= 1, so bound is provable
    have cd0 : CompData sig I ms ms' (k' + 2) envM envN h_idx_1 := {
      sz := fun j' => if j' = i then 1 else 0
      eM := fun j' x => by
        by_cases h : j' = i
        · exact h ▸ (fun _ : Fin 1 => a) (Fin.cast (if_pos h) x)
        · exact absurd (Fin.cast (if_neg h) x).isLt (by omega)
      eN := fun j' x => by
        by_cases h : j' = i
        · exact h ▸ (fun _ : Fin 1 => b) (Fin.cast (if_pos h) x)
        · exact absurd (Fin.cast (if_neg h) x).isLt (by omega)
      agree := fun j' nf => by
        by_cases h : j' = i
        · subst h
          -- [HEq convert pattern using Function.hfunext + Fin.eq_zero]
          sorry -- fillable with verified pattern
        · -- j' ≠ i case: sz j' = 0, use h_comp
          sorry -- same pattern as current (already working minus cast)
      bound := fun j' => by
        by_cases h : j' = i
        · rw [if_pos h]; omega  -- 1 < k' + 2
        · rw [if_neg h]; omega  -- 0 < k' + 2
      sz_le_n := fun j' => by
        by_cases h : j' = i
        · rw [if_pos h]  -- 1 ≤ 1
        · rw [if_neg h]; omega  -- 0 ≤ 1
      consistent := fun p j' hj' => by
        -- [same structure but eM/eN being constant makes it rfl]
        sorry -- fillable
    }
    have h_bc := build_bicompat (budget := k' + 2) (k' + 1) 1 (by omega)
      envM envN h_idx_1 h_atoms_1 cd0
    exact sum_nf_lift_gen sig (k' + 1) 1 I ms ms'
      (fun m hm => h_comp m (by omega)) envM envN h_atoms_1 h_bc sub_nf
```

### Why This is the Cleanest Approach

1. **k=0 is completely eliminated**: No cd0, no build_bicompat, no HEq at all. Just `trivial` for BiCompat.
2. **bound sorry disappears**: `1 < k' + 2` is `by omega`.
3. **eM/eN use proven Fin.cast pattern**: Same style as the working `cd'` in `build_bicompat`.
4. **Constant function eliminates matrix notation**: `fun _ => a` vs `(![a]) q` removes one layer of indirection.
5. **HEq in agree is mechanically provable**: The `Function.hfunext` + `Fin.eq_zero` + `heq_of_eq (simp [Fin.cons_zero])` pattern was verified to typecheck.
6. **consistent becomes trivial**: Constant function means all element lookups return the same value.

### Alternative Considered: Adding k >= 1 Hypothesis

This was ruled out because all four call sites in `sum_nf_agree_sentence` are in the `succ k` branch where the inner k can be 0 (when processing depth 1). Adding a precondition would require restructuring the caller or adding a separate lemma for depth 1, which is more invasive than the case-split approach.

### Alternative Considered: Restructuring cd0 Entirely

Instead of `sz := if j' = i then 1 else 0`, one could use a "single-index" CompData variant. But this would require changing the CompData structure or adding a new constructor, which is too invasive. The case-split approach is local and minimal.
