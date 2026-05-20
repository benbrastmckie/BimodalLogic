# Phase 2 Handoff: Strengthen 10.2.4 to `is_separable_with_U_type`

**Date**: 2026-05-19
**Session**: sess_1779257006_07598e
**Status**: IN PROGRESS (substantial infrastructure complete, 2 sorry remain)

## What Was Accomplished

### 1. Corrected Previous Agent's Error
The Phase 2 blocker was WRONG. Cases 5-8 do NOT use `all_separable`. DedekindZ.lean line 486 confirms: "Cases 5-8 are proved separable without using the `all_separable` axiom." grep shows ZERO references to `all_separable` in DedekindZ.lean.

### 2. Refactored `elim_case_2_gen` (Eliminations.lean)
- Created `case2_psi_properties`: non-existential form giving `int_equiv` and `is_syntactically_separated` for the explicit `case2_psi` formula
- `elim_case_2_gen` now delegates to `case2_psi_properties` (one-liner)
- This mirrors the existing `case1_psi_properties` pattern

### 3. Made DedekindZ.lean Helpers Public
The following private helpers were made public to enable `_with_U_type` composition in Hierarchy.lean:
- `replace_untl_with_top`, `replace_untl_with_bot`
- `untl_under_bool_only`, `u_free_untl_under_bool`
- `replace_U_free_of_bool`, `replace_bot_U_free_of_bool`
- `replace_correct_bool`, `replace_correct_bot`
- `replace_id_of_U_free`, `replace_bot_id_of_U_free`
- `snce_event_congr_with_U`, `snce_event_congr_with_notU`
- `case1_psi_bool_only`, `case3_alpha_aU_factor`
- `d21_sep`, `d21_sep_bool_only`, `d21_sep_equiv`
- `and_or_distrib`

### 4. Created `_with_U_type` Combinators (Hierarchy.lean)
- `or_separable_with_U_type`
- `and_separable_with_U_type`
- `neg_separable_with_U_type`
- Helper: `and_left_congr_hier`, `snce_event_congr_hier`

### 5. Created Case 1 and 2 `_with_U_type` (Hierarchy.lean)
- `case1_sep_with_U_type_gen`: uses `case1_psi_properties` + `case1_psi_has_single_U_type`
- `case2_sep_with_U_type_gen`: uses `case2_psi_properties` + `case2_psi_has_single_U_type`

### 6. Created Combined Helpers with U-type (Hierarchy.lean)
- `snce_combined_U_sep_with_U_type`: S(COMBINED ∧ U, guard) → is_separable_with_U_type
- `snce_combined_notU_sep_with_U_type`: S(COMBINED ∧ ¬U, guard) → is_separable_with_U_type

### 7. Created Case 5 and 8 `_with_U_type` (Hierarchy.lean, fully proved)
- `case5_sep_with_U_type_Z_gen`: 85 lines, mirrors DedekindZ.lean structure
- `case8_sep_with_U_type_Z_gen`: uses Case 2 + neg(Case 5)

### 8. Cases 6 and 7 `_with_U_type` (Hierarchy.lean, SORRY)
- `case6_sep_with_U_type_Z_gen`: sorry (needs `snce_Ufree_event_qU_guard_sep_with_U_type`)
- `case7_sep_with_U_type_Z_gen`: sorry (needs `snce_Ufree_event_qNotU_guard_sep_with_U_type` + `case8_sep_with_U_type_Z_gen`)

## What Remains for Phase 2

### Immediate Next Action
Create `snce_Ufree_event_qU_guard_sep_with_U_type` and `snce_Ufree_event_qNotU_guard_sep_with_U_type` in Hierarchy.lean. These are the U-free-event variants: when the event is U-free, the guard has U in it, and we need `_with_U_type`.

Structure of `snce_Ufree_event_qU_guard_sep_with_U_type`:
- Apply case3_equiv_Z_general (equivalence only, no witness change)
- D1: S(ev, q) → U-free → `u_free_separable_with_type`
- D2: S(alpha, Q_Z) ∧ (A ∨ B∧U) → combine `snce_combined_U_sep_with_U_type` + U-free + `untl_s_free_separable_with_type`
- D3: similar structure using `snce_combined_U_sep_with_U_type`

Then complete `case6_sep_with_U_type_Z_gen` and `case7_sep_with_U_type_Z_gen`.

### After Cases 6-7 Are Done
Create `snce_single_U_depth_one_sep_with_U_type` (same structure as `snce_single_U_depth_one_separable` but using `_with_U_type` case wrappers).

### Phases 3-5 (after Phase 2)
- Phase 3: `single_U_formula_separable_no_oracle` (IH returns `is_separable_with_U_type`)
- Phase 4: Oracle-free `no_S_nested_sep` at UND <= 1
- Phase 5: n=1 fallback fix + import reversal + axiom replacement

## Key Decisions
1. Used non-existential `case*_psi_properties` pattern to access specific witnesses
2. Made DedekindZ.lean helpers public rather than duplicating
3. Created `_with_U_type` versions of combined helpers (`snce_combined_U/notU_sep_with_U_type`) using the public DedekindZ helpers from Hierarchy.lean
4. Replicated full DedekindZ case 5 proof structure with `_with_U_type` combinators

## Build Status
`lake build` passes with 2 sorry warnings (cases 6, 7).
