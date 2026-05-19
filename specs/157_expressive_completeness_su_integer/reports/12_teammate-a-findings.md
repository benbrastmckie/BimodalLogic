# Teammate A Findings: Mechanical Repairs for Separation Module

**Task 157 — Expressive Completeness of {S,U} over Integer Time**
**Focus: Constructor Migration after Task 116 removal of `all_past`/`all_future` constructors**

---

## Key Findings

### Summary

- **Root cause**: `Formula.all_past` and `Formula.all_future` were removed as inductive constructors by task 116. They are now `def` abbreviations:
  - `all_future φ = (some_future φ.neg).neg = (untl (φ.imp bot) (bot.imp bot)).imp bot`
  - `all_past φ = (some_past φ.neg).neg = (snce (φ.imp bot) (bot.imp bot)).imp bot`

- **Error type**: Lean reports `"Redundant alternative"` hard errors for every `| .all_past φ =>` or `| .all_future φ =>` match arm in function definitions. These arms are dead code because `all_past`/`all_future` expand to `imp` expressions, which are caught by the `| .imp _ _ =>` arm first.

- **Total repair sites**: 248 match arms across 10 files (68 Type A in function defs, 180 Type B in induction cases).

- **Repair categories**:
  - **Category 1 (Function Def Arms, Type A)**: 68 sites — remove the redundant arm and add a `@[simp]` lemma to restore behavior
  - **Category 2 (Induction Case Arms, Type B)**: 180 sites — remove the invalid named cases and restructure the `imp` case to absorb them via `simp [Formula.all_past, Formula.all_future]`
  - **Category 3 (Expression-level calls)**: No repair needed — `Formula.all_past φ` as a function call still works

- **Semantic complexity**: Most functions that had explicit G/H arms defined behavior that differs from what the `imp` arm gives by default. Simp lemmas must be provided for at least 10 Defs.lean functions. The induction proofs that used G/H cases require restructuring the `imp` arm.

- **Additional issue**: `DualEliminations.lean` has 8 `sorry` statements for the dual elimination cases. This is a pre-existing debt unrelated to the constructor migration, but noted for completeness.

---

## File-by-File Catalog

### 1. `Separation/Defs.lean` (344 lines)

**36 Type A sites** (all in function definitions).

**Status**: HARD ERRORS. This file is the foundation — nothing downstream compiles until this is fixed.

| Lines | Function | Repair |
|-------|----------|--------|
| 47–48 | `int_truth` | Remove arms; add simp lemmas: `int_truth M t (all_past φ) ↔ ∀ s < t, int_truth M s φ` and dual. These are classically equivalent to the imp-expansion but not definitionally equal. |
| 62–63 | `formula_atoms` | Remove arms; NO simp lemma needed (expansion gives same result automatically). |
| 114–115 | `is_U_free` | Remove arms; NO simp lemma needed (expansion gives `is_U_free φ` correctly). |
| 125–126 | `is_S_free` | Remove arms; ADD simp lemma: `is_S_free (all_past φ) = is_S_free φ`. Without it, `is_S_free (all_past φ)` returns `false` (since it contains `snce`), breaking all proofs about U-free, S-free properties. |
| 148–149 | `is_syntactically_separated` | Remove arms; ADD simp lemmas: `is_syntactically_separated (all_past φ) = is_U_free φ` and `is_syntactically_separated (all_future φ) = is_S_free φ`. |
| 173–174 | `is_future_only` | Remove arms; NO simp lemma needed (all_past contains snce → naturally false; all_future's expansion correctly recurses). |
| 186–187 | `is_past_only` | Remove arms; NO simp lemma needed (all_future contains untl → naturally false). |
| 204–205 | `is_properly_separated` | Remove arms; ADD simp lemmas: `is_properly_separated (all_past φ) = is_past_only φ` and `is_properly_separated (all_future φ) = is_future_only φ`. |
| 225–246 | `junction_depth`, `junction_depth_U`, `junction_depth_S` (mutual) | Remove 6 arms; ADD simp lemmas for each: e.g. `junction_depth (all_past φ) = junction_depth φ`. Expansion through snce/untl and imp gives different values. |
| 258–259 | `U_depth_under_S` | Remove arms; ADD simp lemmas: `U_depth_under_S (all_past φ) = U_depth_under_S φ` and `U_depth_under_S (all_future φ) = U_depth_under_S φ`. |
| 270–271 | `count_U_subformulas` | Remove arms; NO simp lemma needed (expansion gives same result). |
| 282–283, 297–298 | `S_nesting_above_U` and inner helper | Remove 4 arms; ADD simp lemmas: `S_nesting_above_U (all_past φ) = S_nesting_above_U φ` and dual. |
| 313–314 | `u_appearances_top_level_only` | Remove arms; ADD simp lemmas. |
| 327–328 | `u_appears_only_as_top_level` | Remove arms; ADD simp lemmas. |
| 338–339 | `no_S_nested_in_U` | Remove arms; ADD simp lemmas: `no_S_nested_in_U (all_past φ) ↔ no_S_nested_in_U φ` etc. |

**Total simp lemmas needed in Defs.lean**: approximately 20 lemmas (2 per affected function × 10 functions).

**Special note on `int_truth`**: This is the most critical. The expanded form is propositionally equivalent (classically) but definitionally distinct. Proofs using `simp [int_truth]` would need to also unfold the simp lemmas. The recommended approach is to add two `@[simp]` lemmas:
```lean
@[simp] theorem int_truth_all_past (M : IntStructure) (t : ℤ) (φ : Formula) :
    int_truth M t (Formula.all_past φ) ↔ ∀ s : ℤ, s < t → int_truth M s φ := by
  simp only [Formula.all_past, Formula.all_future, Formula.neg, Formula.some_past,
             Formula.some_future, Formula.top, int_truth]
  constructor
  · intro h s hst; exact (h ⟨s, hst, fun hs => hs, fun _ _ _ => trivial⟩).elim
  · intro h ⟨s, hst, hns, _⟩; exact hns (h s hst)
```

---

### 2. `Separation/Hierarchy.lean` (1706 lines)

**14 Type A sites + 68 Type B sites = 82 total**.

**Type A (def arms, lines 45–46, 82–83, 316–317, 568–569, 1332–1333, 1381–1382, 1481–1482)**:

| Lines | Function | Repair |
|-------|----------|--------|
| 45–46 | `has_single_U_type` (match) | Remove arms; ADD simp lemmas. |
| 82–83 | `has_single_S_type` (match) | Remove arms; ADD simp lemmas. |
| 316–317 | `abstract_untl` (function def) | Remove arms; ADD simp lemmas for `abstract_untl (all_past ψ) A B p = all_past (abstract_untl ψ A B p)`. |
| 568–569 | `abstract_snce` (function def) | Remove arms; ADD simp lemmas. |
| 1332–1333 | `extract_U_type` (match with 3-tuple) | Remove arms; ADD simp lemmas. |
| 1381–1382 | `snce_depth_of_U` (def) | Remove arms; ADD simp lemmas. |
| 1481–1482 | `replace_untl` (def) | Remove arms; ADD simp lemmas. |

**Type B (induction arms)**: 68 arms across approximately 30 different theorems/proofs.

Key affected theorems:
- `u_free_has_single_U_type` (lines 62–67): `| all_past ψ ih => simp [is_U_free] at h; exact ih h` — merge into `imp` case with `simp [Formula.all_past, is_U_free]`
- `s_free_has_single_S_type` (lines 99–104): similar
- `single_U_formula_separable` (lines 202–205): `| all_past ψ ih => exact all_past_separable ψ (ih h_single)` — merge into `imp` case
- `abstract_untl_fresh` (lines 342–347): needs restructuring
- `abstract_untl_int_equiv` (lines 385–392): more complex, needs simp unfolding of int_truth_all_past
- ~24 more theorems with similar patterns

**Repair approach for Type B induction cases**: For each theorem, remove `| all_past a ih =>` and `| all_future a ih =>` arms. In the `imp` case, add a conditional check: if the expression is actually an `all_past` or `all_future` expansion, the simp lemmas + `ih1`/`ih2` will provide the needed induction hypotheses. In many cases, `simp [Formula.all_past, Formula.all_future, ...]` followed by the existing tactic will work.

---

### 3. `Separation/FormulaOps.lean` (245 lines)

**2 Type A + 2 Type B sites**.

| Lines | Type | Function | Repair |
|-------|------|----------|--------|
| 37–38 | A | `subst_formula` | Remove arms; ADD simp lemmas: `subst_formula (all_past ψ) t r = all_past (subst_formula ψ t r)` |
| 67, 71 | B | `subst_formula_atoms_disjoint` | Merge `| all_past p ih =>` and `| all_future p ih =>` into `imp` case |

---

### 4. `Separation/NormalForm.lean` (455 lines)

**0 Type A + 2 Type B sites**.

| Lines | Type | Context | Repair |
|-------|------|---------|--------|
| 82–83 | B | One theorem's induction | Remove `| all_past _ =>` and `| all_future _ =>` arms; merge into `imp` case with `simp [is_syntactically_separated, is_U_free]` |

---

### 5. `Separation/Eliminations.lean` (698 lines)

**0 Type A + 2 Type B sites**.

| Lines | Type | Context | Repair |
|-------|------|---------|--------|
| 53–54 | B | One theorem's induction | Remove `| all_past _ =>` and `| all_future _ =>` arms; same pattern as NormalForm |

---

### 6. `Separation/DualEliminations.lean` (150 lines)

**0 Type A + 0 Type B sites** — no `all_past`/`all_future` pattern-match errors.

**Pre-existing issue**: All 8 dual elimination cases use `sorry`. This is unrelated to the constructor migration but must be resolved for the task's main theorem.

---

### 7. `Separation/Duality.lean` (~400 lines)

**0 Type A + 20 Type B sites**.

Key affected theorem: `swap_temporal_int_truth` (lines 63–84).

This is the most structurally complex repair site. The induction cases:
```lean
| all_past phi ih =>
    simp only [Formula.swap_temporal, int_truth]
    constructor
    · intro h s hts; have := h (-s) (by omega); rw [ih] at this; simpa [neg_neg] using this
    · intro h s hts; rw [ih]; have := h (-s) (by omega); simpa [neg_neg] using this
```

After repair, `all_past phi` will be handled by the `imp` case. The proof needs to use `simp only [Formula.all_past, Formula.swap_temporal_all_past, int_truth_all_past]` in the `imp` case to recover the quantifier form before applying the `ih` steps.

The `swap_temporal` function does correctly handle `untl ↔ snce` exchange (which is what `all_past` expands to involve), so the `simp [Formula.swap_temporal]` call would unfold through the expansion.

**Estimated complexity**: Medium-high. Each of the ~10 theorems in this file needs the `imp` case extended with simp unfolding.

---

### 8. `Separation/TemporalClosure.lean` (~800 lines)

**8 Type A + 50 Type B sites = 58 total**. This is the largest single file repair burden.

**Type A sites**:

| Lines | Function | Repair |
|-------|----------|--------|
| 62–63 | `replace_box_with_top` | Remove arms; ADD simp lemma: `replace_box_with_top (all_past φ) = all_past (replace_box_with_top φ)` |
| 220–221 | `no_U_nested_in_S` | Remove arms; ADD simp lemma: `no_U_nested_in_S (all_past φ) ↔ no_U_nested_in_S φ` |
| 597–598 | `expand_temporal` | Remove arms; ADD simp lemmas (critical — these define the expansion!): `expand_temporal (all_past φ) = Formula.neg (.snce (Formula.neg (expand_temporal φ)) Formula.top)` |
| 681–682 | `has_no_allpast_allfuture` | Remove arms; NO simp lemma needed since the expansion naturally contains no `all_past`/`all_future` constructors (they don't exist anymore) — but the predicate must be re-examined |

**Special issue with `has_no_allpast_allfuture`**:
This predicate (lines 676–684) checks if a formula contains no `all_past`/`all_future` constructors. Since those are no longer constructors, this predicate is now trivially true for all formulas. The downstream proofs that use `simp [has_no_allpast_allfuture]` to discharge impossible cases will need updating — those goals will no longer arise.

**Type B sites**: 50 arms across approximately 25 theorems. These follow the same patterns as Hierarchy.lean.

---

### 9. `Separation/DedekindZ.lean` (~1900 lines)

**6 Type A + 14 Type B sites = 20 total**.

**Type A sites**:

| Lines | Function | Repair |
|-------|----------|--------|
| 557–558 | `replace_untl_with_top` | Remove arms; ADD simp lemmas: `replace_untl_with_top (all_past p) A B = all_past (replace_untl_with_top p A B)` |
| 583–584 | `u_free_replacement_prop` (match) | Remove arms; ADD simp lemmas |
| 754–755 | `replace_untl_with_bot` | Remove arms; ADD simp lemmas |

**Type B sites**: 14 arms.

---

### 10. `Separation/IntHelpers.lean` (157 lines)

**0 sites** — uses `Formula.some_past` and `Formula.some_future` only in theorem statements (not pattern-match arms). No repair needed.

---

### 11. `Separation/NegationEquiv.lean`

**0 sites** — uses `all_future`/`all_past` only in expression position (building formulas), not in pattern-match arms. No repair needed.

---

### 12. `Separation/SeparationThm.lean` (285 lines)

**0 Type A + 4 Type B sites**.

| Lines | Theorem | Repair |
|-------|---------|--------|
| 138–139 | `all_separable` | Remove `| all_past φ ih =>` and `| all_future φ ih =>` arms. The `imp` case now covers these. The imp case currently builds a separated equivalent for `imp φ ψ`; it will now also cover `all_past` as `imp (snce (neg φ) top) bot`. The axioms `all_past_separable` and `all_future_separable` are still applicable — just need to be invoked within the `imp` case for this specific shape. |
| 261–262 | `all_properly_separable` | Same pattern, using `all_past_properly_separable`/`all_future_properly_separable` axioms. |

**Note**: The axioms `all_past_separable`, `all_future_separable`, `all_past_properly_separable`, `all_future_properly_separable` in `SeparationThm.lean` (lines 90–95, 223–229) are still valid — they are `axiom` declarations about a propositional type, not pattern-matching on constructors.

---

### 13. `WeakCanonical/ExpressiveCompleteness.lean` (~2100 lines)

**2 Type A + 18 Type B sites = 20 total**.

**Type A sites**:

| Lines | Function | Repair |
|-------|----------|--------|
| 633–638 | `elimExtFromSep` | Remove arms; ADD simp lemmas for the function's behavior on `all_past`/`all_future` |

**Type B sites**: 18 arms across approximately 9 theorems (lines 192–200, 244–246, 708–711, 732–733, 910–914, 976–979, 1116, 1145, 1384–1387, 1799–1821).

---

## Complete Repair Count Table

| File | Type A (def arms) | Type B (induction) | Total | Simp Lemmas Needed |
|------|-------------------|-------------------|-------|-------------------|
| Defs.lean | 36 | 0 | 36 | ~20 |
| Hierarchy.lean | 14 | 68 | 82 | ~14 |
| FormulaOps.lean | 2 | 2 | 4 | 2 |
| NormalForm.lean | 0 | 2 | 2 | 0 |
| Eliminations.lean | 0 | 2 | 2 | 0 |
| DualEliminations.lean | 0 | 0 | 0 | 0 |
| Duality.lean | 0 | 20 | 20 | 0 |
| TemporalClosure.lean | 8 | 50 | 58 | ~8 |
| DedekindZ.lean | 6 | 14 | 20 | 6 |
| IntHelpers.lean | 0 | 0 | 0 | 0 |
| NegationEquiv.lean | 0 | 0 | 0 | 0 |
| SeparationThm.lean | 0 | 4 | 4 | 0 |
| ExpressiveCompleteness.lean | 2 | 18 | 20 | 2 |
| **TOTALS** | **68** | **180** | **248** | **~52** |

---

## Recommended Approach

### Repair Strategy: Simp-Lemma Bridge

The cleanest mechanical repair preserves the mathematical content of the Separation module while adapting to the new constructor-free representation of G/H.

**Phase 1 — Fix Defs.lean (BLOCKING for all other files)**:

1. Remove all 36 `| .all_past φ =>` and `| .all_future φ =>` arms from function definitions.
2. Add approximately 20 `@[simp]` lemmas of the form:
   ```lean
   @[simp] theorem int_truth_all_past (M : IntStructure) (t : ℤ) (φ : Formula) :
       int_truth M t (Formula.all_past φ) ↔ ∀ s : ℤ, s < t → int_truth M s φ
   @[simp] theorem is_S_free_all_past (φ : Formula) :
       is_S_free (Formula.all_past φ) = is_S_free φ
   @[simp] theorem is_syntactically_separated_all_past (φ : Formula) :
       is_syntactically_separated (Formula.all_past φ) = is_U_free φ
   -- etc.
   ```
   Each lemma proves the new function value equals what the old arm returned.
3. Each simp lemma proof uses `simp [Formula.all_past, Formula.all_future, Formula.neg, Formula.some_past, Formula.some_future, Formula.top, <function_name>]`.

**Phase 2 — Fix each file in dependency order**:

Process files in this order (each depends on earlier):
1. `Defs.lean` (foundation)
2. `IntHelpers.lean` (no changes needed)
3. `NegationEquiv.lean` (no changes needed)
4. `FormulaOps.lean` (2 Type A + 2 Type B)
5. `Eliminations.lean` (2 Type B)
6. `NormalForm.lean` (2 Type B)
7. `SeparationThm.lean` (4 Type B, axioms unchanged)
8. `TemporalClosure.lean` (8 Type A + 50 Type B)
9. `DedekindZ.lean` (6 Type A + 14 Type B)
10. `Hierarchy.lean` (14 Type A + 68 Type B)
11. `Duality.lean` (20 Type B)
12. `DualEliminations.lean` (all sorry, no G/H issues)
13. `ExpressiveCompleteness.lean` (2 Type A + 18 Type B)

**For Type B (induction cases)**:
Pattern in each theorem: remove `| all_past a ih =>` and `| all_future a ih =>` cases. In the `imp` case, add:
```lean
| imp φ ψ ih1 ih2 =>
  -- Handle all_past/all_future which now expand through imp
  simp only [Formula.all_past, Formula.all_future, ...]
  <existing imp proof>
```
In many cases, the existing simp lemmas from Phase 1 plus the IH on the inner formula will be sufficient.

**Special cases requiring structural proof changes**:
- `Duality.lean: swap_temporal_int_truth` — needs `int_truth_all_past`/`int_truth_all_future` simp lemmas and quantifier manipulation in the `imp` case
- `Hierarchy.lean: abstract_untl_int_equiv` — needs similar treatment
- `TemporalClosure.lean: all_past_equiv_neg_snce` and `all_future_equiv_neg_untl` — these become definitional equalities (no proof needed), which may simplify downstream code

**The `has_no_allpast_allfuture` predicate**:
This predicate (TemporalClosure.lean) checked for `all_past`/`all_future` constructors. Since those no longer exist as constructors, the predicate always returns `true` for all expanded formulas. The cases `| all_past _ => simp [has_no_allpast_allfuture] at hexp` in proofs were "impossible cases" — they will no longer arise at all since the induction won't generate `all_past`/`all_future` cases. These proof branches should simply be deleted.

---

## Confidence Level

**high** for the following assessments:
- Exact count of Type A and Type B repair sites (verified by grep + build errors)
- The semantic issue with `is_S_free`/`int_truth` requiring explicit simp lemmas
- The repair strategy (simp-lemma bridge is standard Lean 4 practice)
- The ordering of files by dependency

**medium** for:
- Exact number of simp lemmas needed (~52 is an estimate; some functions may need both `all_past` and `all_future` variants, others may fold automatically)
- Whether all Type B induction repairs can be done mechanically by the `simp` approach, or if some need explicit case analysis

**Notes for implementer**:
- The `is_U_free` simp lemma can be verified: `is_U_free (all_past φ) = is_U_free (imp (snce (neg φ) top) bot) = is_U_free (snce (neg φ) top) && is_U_free bot = (is_U_free (neg φ) && is_U_free top) && true = is_U_free φ` — no lemma needed.
- The `int_truth` simp lemma requires classical reasoning (`push_neg` or `Classical.not_forall`) to bridge the propositional gap.
- Start with `lake build Bimodal.Metalogic.WeakCanonical.Separation.Defs` to confirm Phase 1 fixes before proceeding.
