# Research Report: Proof Development for table_correctness Temporal Cases (Task 148)

- **Task**: 148 - table_correctness_temporal_cases
- **Started**: 2026-05-15
- **Effort**: Second research round (proof development)
- **Dependencies**: Task 147 (lift_eval_insertenv_lemmas) -- COMPLETED, Task 145 (MonadicFO split) -- COMPLETED
- **Sources/Inputs**:
  - Theories/Bimodal/Metalogic/WeakCanonical/Table.lean (6 sorries, lines 227, 241, 292, 295, 298, 301)
  - Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean (lift_eval, insertEnv -- all proved)
  - Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean (pipeline status comments)
  - specs/148_table_correctness_temporal_cases/reports/01_scope-analysis.md (prior round)
- **Artifacts**: This report (02_proof-development.md)

## Executive Summary

- All 6 sorry positions in Table.lean have validated proof scripts (tested via `lean_multi_attempt`, all return empty goals with no diagnostics).
- The 2 helper lemmas (`cons_eq_insertEnv_one`, `cons3_eq_insertEnv`) are simple `Fin` case analyses using `Fin.cases` and `simp`.
- The 4 temporal cases follow a uniform pattern: `Iff.intro` with `push_neg` to normalize quantifier forms, `lift1_eval`/`lift1_lift1_eval` to undo De Bruijn lifting, and `ih` to apply the induction hypothesis.
- Transfer.lean pipeline status at step 5 should change from `PARTIAL` to `READY`. The `chronicle_is_good` atomMap signature is already correct (no mismatch found).
- After implementation, `table_correctness` will be fully sorry-free, unblocking step 5 of the Reynolds pipeline.

## Sorry Inventory (Current State)

All 6 sorries are in `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean`:

| Line | Identifier | Type |
|------|-----------|------|
| 227 | `cons_eq_insertEnv_one` | Helper lemma (Fin 2 case analysis) |
| 241 | `cons3_eq_insertEnv` | Helper lemma (Fin 3 case analysis) |
| 292 | `table_correctness` case `all_future` | Temporal case (G) |
| 295 | `table_correctness` case `all_past` | Temporal case (H) |
| 298 | `table_correctness` case `untl` | Temporal case (U) |
| 301 | `table_correctness` case `snce` | Temporal case (S) |

## Validated Proof Scripts

All scripts below were validated via `lean_multi_attempt` -- each returns `goals: []` with no error diagnostics.

### Helper Lemma 1: `cons_eq_insertEnv_one` (line 227)

**Goal**:
```
α : Type
s t : α
⊢ (Fin.cons s fun x ↦ t) = insertEnv ⟨1, ⋯⟩ t fun x ↦ s
```

**Proof script**:
```lean
  funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
```

**Strategy**: `funext` to reduce to pointwise equality. `Fin.cases` splits `Fin 2` into the zero case and the successor case. `simp` with `Fin.cons` and `insertEnv` closes both cases.

### Helper Lemma 2: `cons3_eq_insertEnv` (line 241)

**Goal**:
```
α : Type
u s t : α
⊢ Fin.cons u (Fin.cons s fun x ↦ t) = insertEnv ⟨1, ⋯⟩ s (Fin.cons u fun x ↦ t)
```

**Proof script**:
```lean
  funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv]); refine Fin.cases ?_ ?_ j <;> simp
```

**Strategy**: Two-level `Fin.cases`. The outer split separates index 0 (both sides give `u`). For successor indices, a second `Fin.cases` on `j` separates index 1 (both sides give `s`) from index 2 (both sides give `t`).

### Temporal Case 1: `all_future` (G) (line 292)

**Goal** (after `simp only [table, eval, temporal_truth]`):
```
⊢ (∀ (x : M.carrier),
      ¬(Fin.cons x (fun x ↦ t) ⟨1, _⟩ < Fin.cons x (fun x ↦ t) ⟨0, _⟩ ∧
          ¬eval M (Fin.cons x fun x ↦ t) (MonadicFormula.lift 1 (table sig atomMap ψ)))) ↔
    ∀ (s : M.carrier), t < s → temporal_truth M atomMap s ψ
```

**Proof script**:
```lean
    exact Iff.intro
      (fun h s hts => by push_neg at h; have := h s hts; rw [lift1_eval] at this; exact (ih s).mp this)
      (fun h s => by push_neg; intro hts; rw [lift1_eval]; exact (ih s).mpr (h s hts))
```

**Strategy**: The LHS encodes `∀ s, ¬(t < s ∧ ¬eval ...)` which `push_neg` normalizes to `∀ s, t < s → eval ...`. Then `lift1_eval` converts `eval M (Fin.cons s (fun _ => t)) ((table ψ).lift 1)` to `eval M (fun _ => s) (table ψ)`, and `ih s` provides the final bridge to `temporal_truth`.

### Temporal Case 2: `all_past` (H) (line 295)

**Goal** (after `simp only [table, eval, temporal_truth]`):
```
⊢ (∀ (x : M.carrier),
      ¬(Fin.cons x (fun x ↦ t) ⟨0, _⟩ < Fin.cons x (fun x ↦ t) ⟨1, _⟩ ∧
          ¬eval M (Fin.cons x fun x ↦ t) (MonadicFormula.lift 1 (table sig atomMap ψ)))) ↔
    ∀ s < t, temporal_truth M atomMap s ψ
```

**Proof script**:
```lean
    exact Iff.intro
      (fun h s hst => by push_neg at h; have := h s hst; rw [lift1_eval] at this; exact (ih s).mp this)
      (fun h s => by push_neg; intro hst; rw [lift1_eval]; exact (ih s).mpr (h s hst))
```

**Strategy**: Symmetric to `all_future` with `s < t` instead of `t < s`.

### Temporal Case 3: `untl` (Until) (line 298)

**Goal** (after `simp only [table, eval, temporal_truth]`):
```
⊢ (∃ x, t < x ∧ eval M (Fin.cons x fun x ↦ t) ((table ψ₁).lift 1) ∧
      ∀ x₁, ¬((t < x₁ ∧ x₁ < x) ∧
          ¬eval M (Fin.cons x₁ (Fin.cons x fun x ↦ t)) (((table ψ₂).lift 1).lift 1))) ↔
    ∃ s, t < s ∧ temporal_truth M atomMap s ψ₁ ∧
        ∀ r, t < r → r < s → temporal_truth M atomMap r ψ₂
```

**Proof script**:
```lean
    exact Iff.intro
      (fun ⟨s, hts, h1, h2⟩ => ⟨s, hts, by rw [lift1_eval] at h1; exact (ih₁ s).mp h1,
        fun r htr hrs => by push_neg at h2; have := h2 r ⟨htr, hrs⟩; rw [lift1_lift1_eval] at this; exact (ih₂ r).mp this⟩)
      (fun ⟨s, hts, h1, h2⟩ => ⟨s, hts, by rw [lift1_eval]; exact (ih₁ s).mpr h1,
        fun r => by push_neg; intro ⟨htr, hrs⟩; rw [lift1_lift1_eval]; exact (ih₂ r).mpr (h2 r htr hrs)⟩)
```

**Strategy**: Destructure the existential witness `s`. For the event condition, `lift1_eval` handles the single lift; for the guard `∀ r`, `push_neg` normalizes `¬(... ∧ ¬eval ...)` and `lift1_lift1_eval` handles the double lift (3-variable context `[r, s, t]`).

### Temporal Case 4: `snce` (Since) (line 301)

**Goal** (after `simp only [table, eval, temporal_truth]`):
```
⊢ (∃ x, x < t ∧ eval M (Fin.cons x fun x ↦ t) ((table ψ₁).lift 1) ∧
      ∀ x₁, ¬((x < x₁ ∧ x₁ < t) ∧
          ¬eval M (Fin.cons x₁ (Fin.cons x fun x ↦ t)) (((table ψ₂).lift 1).lift 1))) ↔
    ∃ s < t, temporal_truth M atomMap s ψ₁ ∧
        ∀ r, s < r → r < t → temporal_truth M atomMap r ψ₂
```

**Proof script**:
```lean
    exact Iff.intro
      (fun ⟨s, hst, h1, h2⟩ => ⟨s, hst, by rw [lift1_eval] at h1; exact (ih₁ s).mp h1,
        fun r hsr hrt => by push_neg at h2; have := h2 r ⟨hsr, hrt⟩; rw [lift1_lift1_eval] at this; exact (ih₂ r).mp this⟩)
      (fun ⟨s, hst, h1, h2⟩ => ⟨s, hst, by rw [lift1_eval]; exact (ih₁ s).mpr h1,
        fun r => by push_neg; intro ⟨hsr, hrt⟩; rw [lift1_lift1_eval]; exact (ih₂ r).mpr (h2 r hsr hrt)⟩)
```

**Strategy**: Symmetric to `untl` with reversed order direction (`s < t`, `s < r`, `r < t`).

## Transfer.lean Updates

### Pipeline Status (line 106)

Change step 5 from:
```
| 5 | Transfer truth via `table_correctness` | PARTIAL (temporal cases need `lift_eval`) |
```
to:
```
| 5 | Transfer truth via `table_correctness` | READY (fully proved, no sorry) |
```

### chronicle_is_good Signature (line 135)

The prior report flagged a potential atomMap signature mismatch. Investigation shows **no mismatch exists**:
- `chronicle_is_good` expects `atomMap : sig.preds → Formula` (inverse direction from table)
- `mkAtomMap φ` provides `(mkSigFrom φ).preds → Formula` -- this matches perfectly
- The comment on line 135 (`have h_good := chronicle_is_good M sig aMap (φ.complexity + 1)`) is correct

No changes needed to the `chronicle_is_good` comment.

### Additional Status Comments

Update line 111 from:
```
`table_correctness` is stated and proved for base cases; temporal operator
cases depend on `lift_eval` (sorry-propagating, Task 141 scope).
```
to:
```
`table_correctness` is fully proved (all 8 cases, no sorry).
```

Update the Table.lean module docstring (line 19-20) from:
```
- `table_correctness`: PROVED for base cases (atom, bot, imp, box);
  temporal operator cases (G, H, U, S) sorry-propagating from `lift_eval` (Task 141)
```
to:
```
- `table_correctness`: PROVED (all 8 cases, sorry-free)
```

## Dependency Chain

```
MonadicFO.lean (lift_eval, insertEnv -- proved by task 147)
  |
  v
Table.lean: cons_eq_insertEnv_one  -->  lift1_eval
Table.lean: cons3_eq_insertEnv     -->  lift1_lift1_eval
                                         |
                                         v
                            table_correctness (all 4 temporal cases)
                                         |
                                         v
                            Transfer.lean step 5 (READY)
```

## Downstream Impact

Closing `table_correctness` unblocks:
1. **Transfer.lean step 5**: The truth transfer step can now use `table_correctness` to translate between monadic FO evaluation and temporal truth. Step 5 status changes from PARTIAL to READY.
2. **Reynolds pipeline**: Steps 3 and 6 remain the actual blockers. Step 3 (`chronicle_is_good`) depends on `sum_preservation` (Doets 1.4). Step 6 (ZIntervalStructure to TaskFrame bridge) is an architectural gap.

No other files reference `table_correctness` -- the impact is contained to Transfer.lean's pipeline progression.

## Implementation Plan

### Phase 1: Helper Lemmas (estimated: 5 min)
1. Replace `sorry` at line 227 with validated proof for `cons_eq_insertEnv_one`
2. Replace `sorry` at line 241 with validated proof for `cons3_eq_insertEnv`

### Phase 2: Temporal Cases (estimated: 10 min)
3. Replace `sorry` at line 292 with validated proof for `all_future`
4. Replace `sorry` at line 295 with validated proof for `all_past`
5. Replace `sorry` at line 298 with validated proof for `untl`
6. Replace `sorry` at line 301 with validated proof for `snce`

### Phase 3: Docstring and Status Updates (estimated: 5 min)
7. Update Table.lean module docstring (line 19-20)
8. Update Transfer.lean pipeline status table (line 106)
9. Update Transfer.lean description paragraph (lines 110-111)

### Phase 4: Verification (estimated: 10 min)
10. Run `lake build` to verify clean compilation
11. Run `lean_verify` on `Bimodal.Metalogic.WeakCanonical.table_correctness` to confirm no `sorryAx`

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Proof scripts fail on actual edit (multi_attempt vs real) | Very Low | All 6 scripts validated with empty goals and no diagnostics |
| Lake build reveals transitive sorry issues | Very Low | MonadicFO.lean's `lift_eval` is fully proved (task 147 completed) |
| Fin.cons/insertEnv simp lemmas cause issues | Very Low | Proofs use explicit `Fin.cases` decomposition, not fragile simp chains |
