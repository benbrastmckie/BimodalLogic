# Research Report: Complete table_correctness Temporal Cases (Task 148)

- **Task**: 148 - table_correctness_temporal_cases
- **Started**: 2026-05-15T15:40:00Z
- **Completed**: 2026-05-15T15:40:00Z
- **Effort**: Derived from task 140 review
- **Dependencies**: Task 147 (lift_eval_insertenv_lemmas)
- **Sources/Inputs**:
  - Theories/Bimodal/Metalogic/WeakCanonical/Table.lean (lines 220-304)
  - Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean (lines 98-139)
  - Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean (lines 228-236, eval definition)
  - specs/140_truth_transfer_eliminate_succ_cofinal/reports/01_team-research.md
- **Artifacts**: specs/146_table_correctness_temporal_cases/reports/01_scope-analysis.md (this file)
- **Standards**: report-format.md, status-markers.md, artifact-management.md, tasks.md

## Executive Summary

- Task 140 proved `table_correctness` for base cases (atom, bot, imp, box) but left the 4 temporal operator cases (G, H, Until, Since) as sorry.
- Two Table.lean helper lemmas (`cons_eq_insertEnv_one`, `cons3_eq_insertEnv`) are also sorry and needed for the temporal cases.
- Once task 147 proves `lift_eval`, the temporal cases become straightforward: unfold definitions, apply `lift1_eval` / `lift1_lift1_eval`, then use the induction hypotheses.
- Additionally, `chronicle_is_good` in Transfer.lean step 3 needs its `atomMap` signature updated to match the redesigned `mkAtomMap`, and the pipeline status table should be updated.
- Estimated effort: 1.5-2 hours total (after task 147 completes).

## Context & Scope

### What task 140 accomplished

Task 140 implemented the full `table` definition (all 8 `Formula` constructors), proved `table_depth_bound`, defined `temporal_truth`, and proved `table_correctness` for the 4 base cases:

```lean
theorem table_correctness ... (φ : Formula) :
    eval M (fun _ => t) (table sig atomMap φ) ↔ temporal_truth M atomMap t φ := by
  induction φ generalizing t with
  | atom a => simp only [table, eval, temporal_truth]           -- DONE
  | bot => simp only [table, eval, temporal_truth, lt_irrefl]   -- DONE
  | imp ψ₁ ψ₂ ih₁ ih₂ => ... (8 lines)                        -- DONE
  | box ψ => simp only [table, eval, temporal_truth]            -- DONE
  | all_future ψ ih => sorry   -- THIS TASK
  | all_past ψ ih => sorry     -- THIS TASK
  | untl ψ₁ ψ₂ ih₁ ih₂ => sorry  -- THIS TASK
  | snce ψ₁ ψ₂ ih₁ ih₂ => sorry  -- THIS TASK
```

### What this task must complete

1. Prove the 2 Table.lean helper lemmas (`cons_eq_insertEnv_one`, `cons3_eq_insertEnv`)
2. Close all 4 temporal cases of `table_correctness`
3. Fix `chronicle_is_good` atomMap signature in Transfer.lean step 3
4. Update Transfer.lean pipeline status table to reflect that `table_correctness` is fully proved
5. Verify the full codebase builds clean with 0 new sorries in Table.lean

## Findings

### Helper lemmas needed (Table.lean)

#### `cons_eq_insertEnv_one` (Table.lean:224-227)

```lean
private theorem cons_eq_insertEnv_one {α : Type} (s t : α) :
    (Fin.cons s (fun (_ : Fin 1) => t) : Fin 2 → α) =
    insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
  sorry
```

**What it says**: The 2-element environment `[s, t]` (built via `Fin.cons`) equals inserting `t` at position 1 into the 1-element environment `[s]`.

**Proof strategy**: `funext i`. For `Fin 2`, there are two cases:
- `i = 0`: LHS = `Fin.cons s _ 0 = s`. RHS = `insertEnv 1 t (fun _ => s) 0`. Since `0 < 1`, the passthrough branch gives `(fun _ => s) ⟨0, ...⟩ = s`.
- `i = 1`: LHS = `Fin.cons s (fun _ => t) 1 = t`. RHS = `insertEnv 1 t _ 1`. Since `1 = 1`, the insertion branch gives `t`.

**Difficulty**: Low. Two-case `Fin` exhaustion.

#### `cons3_eq_insertEnv` (Table.lean:238-241)

```lean
private theorem cons3_eq_insertEnv {α : Type} (u s t : α) :
    (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) : Fin 3 → α) =
    insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
  sorry
```

**What it says**: The 3-element environment `[u, s, t]` equals inserting `s` at position 1 into `[u, t]`.

**Proof strategy**: `funext i`. For `Fin 3`, three cases:
- `i = 0`: Both sides give `u`.
- `i = 1`: LHS = `s`. RHS = `insertEnv 1 s _ 1 = s` (insertion branch).
- `i = 2`: LHS = `t`. RHS = `insertEnv 1 s _ 2`. Since `2 > 1` and `2 /= 1`, passthrough-shift gives `(Fin.cons u (fun _ => t)) ⟨1, ...⟩ = t`.

**Difficulty**: Low. Three-case `Fin` exhaustion.

### Temporal cases of `table_correctness`

All 4 cases follow the same pattern: unfold `table` and `eval` to expose the quantifier structure, apply the lift-evaluation lemma to bridge the lifted subformula back to the original, then use the induction hypothesis.

#### Case: `all_future` (G)

**Goal after `simp only [table, eval, temporal_truth]`**:
```
(∀ s, ¬(t < s ∧ ¬eval M (Fin.cons s (fun _ => t)) ((table sig atomMap ψ).lift 1)))
↔ (∀ s, t < s → temporal_truth M atomMap s ψ)
```

**Proof sketch**:
1. The LHS is `∀ s, ¬(t < s ∧ ¬...)` which is equivalent to `∀ s, t < s → ...` by `push_neg` / classical logic.
2. Apply `lift1_eval` (from task 147): `eval M (Fin.cons s (fun _ => t)) ((table sig atomMap ψ).lift 1) = eval M (fun _ => s) (table sig atomMap ψ)`.
3. Apply `ih s`: `eval M (fun _ => s) (table sig atomMap ψ) ↔ temporal_truth M atomMap s ψ`.
4. The two sides now match.

**Key tactic sequence**: `constructor` then `intro h s hlt`, `push_neg at h`, `rw [lift1_eval]`, `exact (ih s).mp (h s hlt)` (and symmetric for the reverse direction).

#### Case: `all_past` (H)

Symmetric to `all_future` with `s < t` instead of `t < s`. The `lt` indices are swapped (`lt 0 1` instead of `lt 1 0`). The proof is identical modulo the order direction.

#### Case: `untl` (Until)

**Goal after `simp only [table, eval, temporal_truth]`**:
```
(∃ s, t < s ∧ eval M (Fin.cons s (fun _ => t)) ((table sig atomMap ψ₁).lift 1) ∧
  ∀ u, ¬((t < u ∧ u < s) ∧ ¬eval M (Fin.cons u (Fin.cons s (fun _ => t)))
    (((table sig atomMap ψ₂).lift 1).lift 1)))
↔ (∃ s, t < s ∧ temporal_truth M atomMap s ψ₁ ∧
    ∀ r, t < r → r < s → temporal_truth M atomMap r ψ₂)
```

**Proof sketch**:
1. `constructor` to split the iff.
2. Forward: `intro ⟨s, hts, h_event, h_guard⟩`.
   - Apply `lift1_eval` to convert `eval ... ((table ψ₁).lift 1)` to `eval ... (table ψ₁)`.
   - Apply `ih₁ s` to get `temporal_truth ... s ψ₁`.
   - For the guard: `push_neg at h_guard` to get `∀ u, (t < u ∧ u < s) → eval ... (((table ψ₂).lift 1).lift 1)`.
   - Apply `lift1_lift1_eval` to convert the double-lifted eval.
   - Apply `ih₂ u` to get `temporal_truth ... u ψ₂`.
3. Backward: symmetric using `.mpr` instead of `.mp`.

**Key helper**: `lift1_lift1_eval` (Table.lean:244-255) handles the 3-variable context `[u, s, t]`. Once task 147 proves `lift_eval`, `lift1_lift1_eval` becomes sorry-free (its proof already chains `cons3_eq_insertEnv` → `lift_eval` → `lift1_eval`).

#### Case: `snce` (Since)

Symmetric to `untl` with reversed order direction (`s < t`, `s < r`, `r < t`). The proof structure is identical.

### Transfer.lean pipeline cleanup

#### `chronicle_is_good` signature mismatch (step 3)

The commented-out pipeline step 3 reads:
```lean
-- have h_good := chronicle_is_good M sig aMap (φ.complexity + 1)
```

After task 140's `mkAtomMap` redesign, `aMap` has type `(mkSigFrom φ).preds → Formula` (subtype projection). But `chronicle_is_good` in IntegerModel.lean expects `atomMap : sig.preds → Formula`. These types are the same when `sig = mkSigFrom φ`, but the comment should use the correct variable name and the type annotation should be verified.

**Action**: Update the comment to use the redesigned signature. Even though `chronicle_is_good` is still sorry, having the correct types in the commented pipeline ensures it will type-check when activated.

#### Pipeline status table update

Transfer.lean lines 98-111 contain a status table. After this task completes, step 5 should change from `PARTIAL` to `READY`:

```
| 5 | Transfer truth via `table_correctness` | READY (fully proved) |
```

## Recommendations

1. **Prove helpers first**: `cons_eq_insertEnv_one` and `cons3_eq_insertEnv` are trivial `Fin` case analyses (~15 min).
2. **Start with `all_future`**: The simplest temporal case (1 quantifier, 2 variables). Get the pattern right here, then replicate for `all_past`.
3. **Then `untl`**: The 2-quantifier case is more complex but follows the same pattern with `lift1_lift1_eval` for the inner guard. Replicate for `snce`.
4. **Use `push_neg` liberally**: The `table` definition encodes `∀s, ¬(... ∧ ¬...)` as the De Morgan form of `∀s, ... → ...`. The `push_neg` tactic converts between these.
5. **Verify with `lean_verify`**: After closing all sorries, run `lean_verify` on `table_correctness` to confirm no `sorryAx` in the axiom set.
6. **Fix Transfer.lean comments last**: Low-risk cleanup after the proofs are done.

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| `lift1_eval` not yet proved (task 147 incomplete) | Blocking | Task 148 depends on 145; do not start until 145 is done |
| `push_neg` / `simp` doesn't fully normalize the quantifier structure | Low | Manual `intro`/`exact` fallback; the mathematical content is thin |
| `Fin.cons` / `insertEnv` simp lemmas conflict or loop | Low | Use `simp only` with explicit lemma lists |
| Double-lift case (`untl`/`snce`) has unexpected Fin coercion issues | Medium | Test with `lean_goal` at each step; use `omega` for index arithmetic |
