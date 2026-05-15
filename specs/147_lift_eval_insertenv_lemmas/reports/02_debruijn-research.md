# Task 147: De Bruijn Substitution Lemmas -- Research Report

**Session**: sess_1778869234_ab2216_t147
**Status**: Research findings ready for implementation

## Overview

Four sorry'd lemmas in `NEquivalence.lean` handle De Bruijn index manipulation for the monadic first-order formula evaluation. All four proofs have been fully developed and validated via `lean_multi_attempt`.

## Lemma Analysis and Proof Strategies

### 1. `insertEnv_zero_eq_cons` (line 292-294)

**Statement**: `insertEnv 0 x env = Fin.cons x env`

**Strategy**: `funext` + `Fin.cases` with `simp`.

**Proof**:
```lean
funext i
cases i using Fin.cases with
| zero => simp [insertEnv, Fin.cons_zero]
| succ i => simp [insertEnv, Fin.cons_succ, Fin.val_succ]
```

**Key insight**: For the zero case, `insertEnv 0 x env` at index 0 satisfies `0 = 0` in the second branch, giving `x`, which matches `Fin.cons x env 0 = x`. For the succ case, `insertEnv 0 x env` at `i.succ` takes the third branch (since `i.succ.val > 0`), giving `env ⟨i.succ.val - 1, _⟩ = env i`, which matches `Fin.cons x env i.succ = env i`.

### 2. `insertEnv_succ_cons` (line 301-304)

**Statement**: `insertEnv c.succ x (Fin.cons y env) = Fin.cons y (insertEnv c x env)`

**Strategy**: `funext` + `Fin.cases` for the outer split, then `split_ifs` for the `insertEnv` conditionals, plus `convert @Fin.cons_succ` for the last branch.

**Proof**:
```lean
funext i
cases i using Fin.cases with
| zero =>
  unfold insertEnv
  rw [dif_pos (show (0 : Fin (n + 2)).val < c.succ.val by simp [Fin.val_succ])]
  rfl
| succ j =>
  simp only [Fin.cons_succ, insertEnv, Fin.val_succ]
  have hj_lt : j.val < n + 1 := j.isLt
  split_ifs
  all_goals first | rfl | (exfalso; omega) | skip
  · rename_i h1 h2 _ h4
    exact absurd (Fin.succ_inj.mp h2) h4
  · rename_i h1 h2 _ h4
    exact absurd (congrArg Fin.succ h4) h2
  · rename_i h1 h2 h3 h4
    have hne : j.val ≠ c.val := fun h => h4 (Fin.ext h)
    have hpos : 0 < j.val := by omega
    have hjm1_lt : j.val - 1 < n := by omega
    convert @Fin.cons_succ n (fun _ => α) y env ⟨j.val - 1, hjm1_lt⟩ using 2
    ext; simp [Fin.val_mk]; omega
```

**Key challenges**:
- `split_ifs` produces 9 branches from the two nested `dite` on each side. Most close by `rfl` (definitional equality when conditions align) or `exfalso; omega` (contradictory conditions).
- Three non-trivial branches remain: two impossible cases resolved via `Fin.succ_inj`, and one actual computation case where `Fin.cons y env ⟨j+1-1, _⟩ = env ⟨j-1, _⟩` requires `convert @Fin.cons_succ` because Lean cannot definitionally reduce `Fin.cons` on a symbolically-valued `Fin`.
- The `convert ... using 2` approach works because it allows propositional (not just definitional) equality between `Fin` arguments.

### 3. `insertEnv_finLift` (line 307-310)

**Statement**: `insertEnv c x env (finLift c.val i) = env i`

**Strategy**: Unfold `finLift`, case split on `i.val < c.val`, then resolve `insertEnv` branches with `dif_pos`/`dif_neg`.

**Proof**:
```lean
simp only [finLift]
by_cases hlt : i.val < c.val
· simp only [if_pos hlt, insertEnv, dif_pos hlt]
· simp only [if_neg hlt, insertEnv]
  have h1 : ¬(i.val + 1 < c.val) := by omega
  rw [dif_neg h1]
  have h2 : ¬((⟨i.val + 1, (by omega : i.val + 1 < n + 1)⟩ : Fin (n + 1)) = c) := by
    intro heq; have := Fin.ext_iff.mp heq; simp at this; omega
  rw [dif_neg h2]
```

**Key insight**: When `i < c`, `finLift` doesn't shift, and `insertEnv` returns the same element. When `i >= c`, `finLift` shifts up by 1 giving `i+1`, and `insertEnv` at `i+1` (which is > c and != c) shifts back down by 1, recovering `env i`. The final goal `env ⟨i+1-1, _⟩ = env i` closes by `rfl` since `i+1-1 = i` definitionally.

### 4. `lift_eval` (line 313-317)

**Statement**: `eval M (insertEnv c x env) (α.lift c.val) = eval M env α`

**Strategy**: Structural induction on `α` (the formula). The `atom` and `lt` cases use `insertEnv_finLift`. The `not` and `and` cases use the IH directly. The `all` and `ex` cases use `insertEnv_succ_cons` to commute `Fin.cons` past `insertEnv`, then apply the IH.

**Proof**:
```lean
induction α with
| atom p i => simp [eval, MonadicFormula.lift, insertEnv_finLift]
| lt i j => simp [eval, MonadicFormula.lift, insertEnv_finLift]
| not α ih => simp only [eval, MonadicFormula.lift]; rw [ih env c]
| and α β ihα ihβ => simp only [eval, MonadicFormula.lift]; rw [ihα env c, ihβ env c]
| all α ih =>
  simp only [eval, MonadicFormula.lift]
  have key : ∀ y, eval M (Fin.cons y (insertEnv c x env)) (α.lift (c.val + 1)) = eval M (Fin.cons y env) α := by
    intro y
    rw [(insertEnv_succ_cons c x y env).symm]
    exact ih (Fin.cons y env) c.succ
  simp_rw [key]
| ex α ih =>
  simp only [eval, MonadicFormula.lift]
  have key : ∀ y, eval M (Fin.cons y (insertEnv c x env)) (α.lift (c.val + 1)) = eval M (Fin.cons y env) α := by
    intro y
    rw [(insertEnv_succ_cons c x y env).symm]
    exact ih (Fin.cons y env) c.succ
  simp_rw [key]
```

**Key challenges**:
- The IH is automatically generalized over `env` and `c` by the `induction` tactic (since `α` has type `MonadicFormula sig n` where `n` is determined by the formula structure, and `env`/`c` depend on `n`).
- The quantifier cases (`all`/`ex`) require proving `Fin.cons y (insertEnv c x env) = insertEnv c.succ x (Fin.cons y env)` (i.e., `insertEnv_succ_cons`) to align the environment for the IH application.
- Using `simp_rw [key]` rewrites under the quantifier binder, which `rw` cannot do.

### 5. `weaken_eval` (line 327-332)

**Status**: Already proved. Its body uses `insertEnv_zero_eq_cons` and `lift_eval`, both of which we are providing. Once the sorries are replaced, `weaken_eval` will type-check.

## Mathlib Dependencies

The proofs rely on the following Mathlib lemmas (all from `Mathlib.Data.Fin.Tuple.Basic`):

| Lemma | Type | Usage |
|-------|------|-------|
| `Fin.cons_zero` | `Fin.cons x p 0 = x` | Zero case of `insertEnv_zero_eq_cons` |
| `Fin.cons_succ` | `Fin.cons x p i.succ = p i` | Succ cases throughout |
| `Fin.succ_inj` | `i.succ = j.succ ↔ i = j` | Contradiction in `insertEnv_succ_cons` |
| `Fin.val_succ` | `i.succ.val = i.val + 1` | Converting Fin values |
| `Fin.val_mk` | `(⟨v, h⟩ : Fin n).val = v` | Fin literal manipulation |
| `Fin.ext_iff` | `i = j ↔ i.val = j.val` | Converting Fin equality to Nat equality |

## Technical Notes

### Dependent Type Issues with `Fin.cons`

`Fin.cons` has a dependent type signature: `{α : Fin (n+1) → Sort u} → α 0 → ((i : Fin n) → α i.succ) → (i : Fin (n+1)) → α i`. When used with a constant family `fun _ => β`, the return type reduces to `β`, but:

1. `rw` with `Fin.cons_succ` fails on symbolic `Fin` literals `⟨v, h⟩` due to dependent type motive issues.
2. The workaround is `convert @Fin.cons_succ n (fun _ => α) ...` with explicit family annotation, which allows propositional (not just definitional) equality matching.
3. For `Fin` literals like `⟨j.val + 1 - 1, h⟩`, Lean's kernel reduces `j.val + 1 - 1` to `j.val` definitionally (since `Nat.succ n - 1 = n` by pattern matching). However, `j.val - 1 + 1` does NOT reduce to `j.val` for symbolic `j` (since `Nat.sub` can't reduce on symbolic inputs).

### Literature Applicability

The literature (Reynolds 1994, Doets 1987/1989) does not address De Bruijn index formalization. These are standard substitution lemmas for De Bruijn indexed first-order logic, following well-known patterns from proof assistant libraries (e.g., Autosubst, locally nameless representations). The proof architecture is first-principles Lean work, not literature-guided.

## Implementation Recommendation

All four proofs are fully validated. Implementation should be straightforward replacement of the `sorry` markers. No blockers identified. Zero-sorry completion is achievable.
