# Implementation Summary: Task #157 Plan v27 Phases 2-5

## Overview

Completed Phases 2-5 of the GHR94-Faithful Case 2 Fix plan, eliminating the oracle dependency from the separation theorem hierarchy. The main theorem `all_formulas_separable_aux` now uses `no_S_nested_sep` which is fully oracle-free.

## Key Theorems Created

### Phase 2: `snce_single_U_depth_one_sep_with_U_type` (Hierarchy.lean)
- Returns `is_separable_with_U_type` instead of `is_separable`
- Tracks `has_single_U_type` through all 8 case branches
- Supporting infrastructure: `case1/2_sep_with_U_type_gen`, `case5/6/7/8_sep_with_U_type_Z_gen`
- Combined helpers: `snce_combined_U/notU_sep_with_U_type`
- Combinators: `or/and/neg_separable_with_U_type`

### Phase 3: `single_U_formula_sep_with_U_type_no_oracle` (Hierarchy.lean)
- Oracle-free Lemma 10.2.5 returning `is_separable_with_U_type`
- Strong induction on `snce_depth_of_U`
- Corollary: `single_U_formula_separable_no_oracle`

### Phase 4: `lemma_10_2_6_no_oracle` + oracle-free `no_S_nested_sep` (Hierarchy.lean)
- `no_S_nested_sep` at UND <= 1 now uses `lemma_10_2_6_no_oracle`

### Phase 5: n=1 fallback fix (Hierarchy.lean)
- `all_formulas_separable_aux` at n=1 uses `no_S_nested_sep`
- Old axiom-dependent helpers removed

## Plan Deviations

- Task 3.1 (`sep_boxfree_depth_zero`): Skipped -- used existing `separated_boxnorm_snce_depth_zero`
- Import reversal: Deferred -- SeparationThm import kept to avoid file reordering
- Axiom replacement in SeparationThm: Deferred -- axioms still present but unused by main path

## Verification

- `lake build`: Passes (zero errors, zero sorry in modified files)
- Main proof chain: oracle-free
