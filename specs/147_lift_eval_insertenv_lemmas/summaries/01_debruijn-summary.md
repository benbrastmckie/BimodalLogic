# Implementation Summary: De Bruijn Substitution Lemmas

- **Task**: 147 - lift_eval_insertenv_lemmas
- **Status**: Implemented
- **Plan**: plans/01_debruijn-plan.md
- **Session**: sess_1778871141_a24716

## Changes

### File Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`

### Proofs Completed (4 sorry markers resolved)

1. **`insertEnv_zero_eq_cons`** (formerly line 294): Proved via `funext` + `Fin.cases` with `simp` on `insertEnv`, `Fin.cons_zero`, `Fin.cons_succ`, `Fin.val_succ`.

2. **`insertEnv_succ_cons`** (formerly line 304): Proved via `funext` + `Fin.cases`. Zero case uses `dif_pos` + `rfl`. Succ case uses `split_ifs` to handle 9 branches, with `Fin.succ_inj` contradictions for impossible branches and `convert @Fin.cons_succ` for the final branch.

3. **`insertEnv_finLift`** (formerly line 310): Proved via `by_cases` on `i.val < c.val`. Positive case uses `dif_pos`. Negative case chains `dif_neg` for both the less-than and equality conditions, finishing with `congr 1`.

4. **`lift_eval`** (formerly line 317): Proved by structural induction on the formula. Atom/lt cases use `insertEnv_finLift`. Not/and cases use inductive hypotheses directly. All/ex binder cases use `insertEnv_succ_cons` symmetry to commute `Fin.cons` past `insertEnv`, then apply the IH at `c.succ`.

### Downstream Impact
- **`weaken_eval`** is now sorry-free (it references `insertEnv_zero_eq_cons` and `lift_eval`)
- Unblocks `lift1_eval`/`lift1_lift1_eval` in Table.lean (prerequisites for temporal `table_correctness`)

## Plan Deviations

- **Task 1.3 (insertEnv_finLift)**: Altered -- the validated proof from research left a congruence goal `env ⟨↑i + 1 - 1, ⋯⟩ = env i` open after `rw [dif_neg h2]`. Added `congr 1` to close it.

## Verification

| Check | Result |
|-------|--------|
| `lean_goal` all 4 proofs | No remaining goals |
| `weaken_eval` sorry-free | Confirmed |
| `lake build` | Build completed successfully (1645 jobs) |
| Sorry count (NEquivalence.lean) | 8 -> 4 (remaining 4 belong to task 139) |
| Vacuous definitions | 0 |
| New axioms | 0 |
