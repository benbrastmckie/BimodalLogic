# Research Report: De Bruijn Lift/InsertEnv Lemmas (Task 147)

- **Task**: 147 - lift_eval_insertenv_lemmas
- **Started**: 2026-05-15T15:40:00Z
- **Completed**: 2026-05-15T15:40:00Z
- **Effort**: Derived from task 140 review
- **Dependencies**: None
- **Sources/Inputs**:
  - Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean (lines 240-317)
  - specs/140_truth_transfer_eliminate_succ_cofinal/reports/01_team-research.md
  - specs/140_truth_transfer_eliminate_succ_cofinal/summaries/01_table-correctness-summary.md
- **Artifacts**: specs/145_lift_eval_insertenv_lemmas/reports/01_scope-analysis.md (this file)
- **Standards**: report-format.md, status-markers.md, artifact-management.md, tasks.md

## Executive Summary

- Task 140 introduced `MonadicFormula.lift`, `finLift`, and `insertEnv` in NEquivalence.lean but left all 4 key lemmas relating them as sorry.
- These 4 lemmas are pure Fin-arithmetic / function-extensionality proofs with no deep mathematical content.
- They form the foundation for `weaken_eval` (already wired) and `table_correctness` temporal cases (task 148).
- All 4 proofs follow standard De Bruijn substitution lemma patterns from type theory.
- Estimated effort: 2-3 hours total.

## Context & Scope

Task 140 implemented the Reynolds Section 6 standard translation (`table`) and proved `table_depth_bound`. It also stated `table_correctness` and proved the base cases (atom, bot, imp, box). The temporal operator cases (G, H, Until, Since) were left as sorry because they depend on `lift_eval`, which was itself left sorry.

The `lift_eval` theorem is the standard De Bruijn substitution lemma: evaluating a lifted formula in an extended environment recovers the original evaluation. It depends on 3 helper lemmas about `insertEnv` and `finLift`.

**These lemmas were incorrectly attributed to "Task 141 scope" by the implementation agent.** Task 141 concerns the canonical truth lemma for Until/Since in `TruthLemma.lean` — a completely different problem. The lift/insertEnv infrastructure is squarely task 140's De Bruijn machinery and should have been completed during task 140.

## Findings

### Definitions already in place (NEquivalence.lean)

All definitions are complete and sorry-free:

1. **`finLift`** (line 244): `Fin n → Fin (n+1)` — shifts index at cutoff `c`. Indices below `c` unchanged, indices >= `c` incremented by 1.

2. **`MonadicFormula.lift`** (line 256): Structural recursion on `MonadicFormula sig n → MonadicFormula sig (n+1)`. Applies `finLift c` to variable indices; increments cutoff under `all`/`ex` binders.

3. **`MonadicFormula.weaken`** (line 272): Defined as `lift 0`. Standard weakening.

4. **`insertEnv`** (line 282): `Fin (n+1) → α` from `Fin n → α` plus a value at position `c`. Three-way case split: index < c (passthrough), index = c (inserted value), index > c (shifted down).

5. **`eval`** (line 228): Tarski satisfaction. Quantifier binding uses `Fin.cons`.

### Lemmas requiring proof (4 root sorries)

#### Lemma 1: `insertEnv_zero_eq_cons` (line 292-294)

```lean
theorem insertEnv_zero_eq_cons {α : Type} {n : Nat} (x : α) (env : Fin n → α) :
    insertEnv 0 x env = Fin.cons x env
```

**What it says**: Inserting at position 0 is the same as `Fin.cons`.

**Proof strategy**: `funext i`. Case split on `i`:
- If `i = 0`: `insertEnv 0 x env 0` hits the `i = c` branch (since `c = 0`), returning `x`. `Fin.cons x env 0 = x` by `Fin.cons_zero`.
- If `i = Fin.succ j`: `insertEnv 0 x env (Fin.succ j)` hits the `i.val > c.val` branch (since `j.val + 1 > 0`), returning `env ⟨j.val + 1 - 1, ...⟩ = env j`. `Fin.cons x env (Fin.succ j) = env j` by `Fin.cons_succ`.

**Key Lean tactics**: `funext i`, `simp [insertEnv, Fin.cons]`, `cases i using Fin.cases`, `omega`.

**Difficulty**: Low. Pure case analysis on `Fin` indices.

#### Lemma 2: `insertEnv_succ_cons` (line 301-304)

```lean
theorem insertEnv_succ_cons {α : Type} {n : Nat} (c : Fin (n + 1)) (x y : α)
    (env : Fin n → α) :
    insertEnv c.succ x (Fin.cons y env) = Fin.cons y (insertEnv c x env)
```

**What it says**: Inserting at `c+1` after `Fin.cons y` equals `Fin.cons y` followed by inserting at `c`. This is the key commutation lemma for the binder case of `lift_eval`.

**Proof strategy**: `funext i`. Case split on `i`:
- If `i = 0`: LHS: `insertEnv c.succ x (Fin.cons y env) 0`. Since `0 < c.succ.val` (i.e., `0 < c.val + 1`), this hits the passthrough branch, giving `(Fin.cons y env) 0 = y`. RHS: `Fin.cons y (insertEnv c x env) 0 = y`.
- If `i = Fin.succ j`: Need to show that the three-way case split on `j+1` vs `c+1` in the LHS matches the case split on `j` vs `c` in the RHS, shifted through `Fin.cons`.

**Key Lean tactics**: `funext i`, `cases i using Fin.cases`, `simp [insertEnv, Fin.cons, Fin.succ]`, `split` for the if-then-else branches, `omega`.

**Difficulty**: Medium. The `Fin.succ` case requires careful index arithmetic to align the three-way split on both sides.

#### Lemma 3: `insertEnv_finLift` (line 307-310)

```lean
private theorem insertEnv_finLift {α : Type} {n : Nat} (c : Fin (n + 1))
    (x : α) (env : Fin n → α) (i : Fin n) :
    insertEnv c x env (finLift c.val i) = env i
```

**What it says**: Looking up a lifted index in an inserted environment recovers the original value. This is the inverse relationship: `finLift` skips position `c`, and `insertEnv` inserts at position `c`, so composing them cancels out.

**Proof strategy**: Unfold `finLift` and `insertEnv`. Case split on whether `i.val < c.val`:
- If `i.val < c.val`: `finLift c i = ⟨i.val, ...⟩` (unchanged). `insertEnv c x env ⟨i.val, ...⟩` hits the `< c` branch, returning `env ⟨i.val, ...⟩ = env i`.
- If `i.val >= c.val`: `finLift c i = ⟨i.val + 1, ...⟩`. Since `i.val + 1 > c.val` and `i.val + 1 /= c.val` (because `i.val >= c.val` implies `i.val + 1 > c.val`), `insertEnv` hits the third branch, returning `env ⟨(i.val + 1) - 1, ...⟩ = env ⟨i.val, ...⟩ = env i`.

**Key Lean tactics**: `simp [insertEnv, finLift]`, `split`, `omega`, `congr`, `ext`.

**Difficulty**: Low-medium. The case split is straightforward once `finLift` is unfolded.

#### Lemma 4: `lift_eval` (line 312-317)

```lean
theorem lift_eval {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (c : Fin (n + 1)) (x : M.carrier) (α : MonadicFormula sig n) :
    eval M (insertEnv c x env) (α.lift c.val) = eval M env α
```

**What it says**: Evaluating a lifted formula in an inserted environment recovers the original evaluation. This is the main De Bruijn substitution lemma.

**Proof strategy**: Structural induction on `α`:
- `atom p i`: `eval M (insertEnv c x env) (.atom p (finLift c.val i)) = M.interp p (insertEnv c x env (finLift c.val i)) = M.interp p (env i)` by `insertEnv_finLift`.
- `lt i j`: Same pattern — two applications of `insertEnv_finLift`.
- `not α`: Unfold `eval`, apply induction hypothesis.
- `and α β`: Unfold `eval`, apply both induction hypotheses.
- `all α`: This is the key case. `eval M (insertEnv c x env) (.all (α.lift (c+1))) = ∀ y, eval M (Fin.cons y (insertEnv c x env)) (α.lift (c+1))`. By `insertEnv_succ_cons`, `Fin.cons y (insertEnv c x env) = insertEnv c.succ x (Fin.cons y env)`. But `α.lift (c+1) = α.lift c.succ.val`, so the IH gives `eval M (insertEnv c.succ x (Fin.cons y env)) (α.lift c.succ.val) = eval M (Fin.cons y env) α`. Hence `∀ y, eval M (Fin.cons y env) α = eval M env (.all α)`.
- `ex α`: Same pattern as `all`.

**Key Lean tactics**: `induction α generalizing c env`, `simp [eval, MonadicFormula.lift]`, `insertEnv_finLift`, `insertEnv_succ_cons`, `congr`, `funext`.

**Difficulty**: Medium. The `all`/`ex` cases require the `insertEnv_succ_cons` commutation and careful handling of the cutoff increment. The proof structure is standard in De Bruijn metatheory.

### Downstream impact

Once these 4 lemmas are proved:
- `weaken_eval` (already wired via `insertEnv_zero_eq_cons` + `lift_eval`) becomes sorry-free automatically.
- `lift1_eval` and `lift1_lift1_eval` in Table.lean become provable (they depend on `lift_eval` + the Table.lean helpers `cons_eq_insertEnv_one` and `cons3_eq_insertEnv`).
- All 4 temporal cases of `table_correctness` become closeable (task 148).

## Recommendations

1. Prove in dependency order: `insertEnv_finLift` first (no dependencies), then `insertEnv_zero_eq_cons` and `insertEnv_succ_cons` (independent of each other), then `lift_eval` (depends on all three).
2. Use `funext` + `Fin.cases`/`Fin.elim` pattern for the `insertEnv` lemmas.
3. For `lift_eval`, follow the standard De Bruijn induction: the `atom`/`lt` cases use `insertEnv_finLift`, the `not`/`and` cases are trivial, and the `all`/`ex` cases use `insertEnv_succ_cons`.
4. Consider using `lean_multi_attempt` to test tactic candidates on each case before committing edits.
