# Phase 3 Handoff: Task 3.7 Blocker (Callback Termination)

## Status: BLOCKED at Task 3.7

## Completed Work (Tasks 3.4-3.6, 3.8)

### Task 3.4: callback_has_single_U_type
- File: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
- Added `subst_U_free_gives_single_U_type`: Substituting U(A,B) (with U-free A, B) for an atom in a U-free formula yields single U-type.
- Added `callback_has_single_U_type`: `.snce(subst c p U(A,B), subst d p U(A,B))` has single U-type when c, d are U-free.

### Task 3.5: separated_boxnorm_snce_depth_zero
- File: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
- **Deviation**: Renamed from `is_syntactically_separated_snce_depth_zero` because the original theorem is FALSE. `is_syntactically_separated` treats `.box` as atomic while `snce_depth_of_U` passes through it. Counterexample: `.box(.snce(.untl p0 p1, p2))` is separated (box is atomic) but has sdoU = 1.
- Fixed version: `separated_boxnorm_snce_depth_zero` proves `snce_depth_of_U(replace_box_with_top phi) = 0` when `is_syntactically_separated phi = true`.

### Task 3.6: _gen variants for Cases 3, 4, 6, 7
- Eliminations.lean: `elim_case_3_gen`, `elim_case_4_gen` (replaced elim_case_2/1 calls with _gen versions)
- DedekindZ.lean: `case6_separable_Z_gen`, `case7_separable_Z_gen` (dropped unused `_ha'`, `_hq'`), `case8_separable_Z_gen` made public (was private)

### Task 3.8: NormalForm.lean _gen wrappers
- Added `case1_separable_gen` through `case8_separable_gen` (all 8 cases)
- Added `lemma_10_2_4_gen`: conjunction of all 8 cases, requiring only U-free a, q and S-free A, B

## Blocker: Task 3.7 (single_U_formula_separable_noax)

### The Problem
Cannot prove `single_U_formula_separable_noax` (axiom-free Lemma 10.2.5) because the `.snce C F` case requires handling callback formulas from `no_S_nested_in_U_separable_param_jd` that are NOT smaller than the original formula by any standard well-founded measure.

### Attempts Made
1. **snce_depth_of_U strong induction**: Callbacks don't decrease sdoU
2. **Structural induction**: Callbacks are not structurally sub-formulas
3. **count_U_subformulas induction**: Callbacks can have more U-subformulas (substitution expands)
4. **Fuel-based (Nat.rec)**: No provable bound on nesting depth
5. **Self-referential callback**: Circular definition, Lean needs termination proof

### Root Cause
`no_S_nested_in_U_separable_param_jd` is a black box that internally reduces `count_U_subformulas` but doesn't expose this to the callback. The callback receives formulas whose relationship to the original is opaque.

### Recommended Next Steps
1. **Research**: `/research 157` focusing on approaches (a)-(d) from the blocker documentation in the plan
2. **Most promising**: Approach (a) -- modify `no_S_nested_in_U_separable_param` to include `count_U < original` in the callback signature
3. **Alternative**: Approach (b) -- inline the U-abstraction logic into `all_formulas_separable_aux` as a single well-founded recursion

## Build State
- `lake build` passes with zero errors
- All new theorems are sorry-free
- `all_separable` still uses axioms (Task 3.7 was the prerequisite for eliminating them)

## Files Modified in This Session
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (Tasks 3.4, 3.5)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` (Task 3.6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (Task 3.6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` (Task 3.8)
