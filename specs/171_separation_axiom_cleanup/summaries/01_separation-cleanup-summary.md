# Implementation Summary: Separation Axiom Cleanup

- **Task**: 171 - Eliminate remaining separation axioms and clean up post-task-157 artifacts
- **Status**: Implemented
- **Session**: sess_1779262392_5cd576

## Overview

Eliminated all 5 remaining axioms from `SeparationThm.lean` and cleaned up 22+ stale comments and 2 dead wrappers across the Separation module. The Separation directory now contains zero axioms, zero sorries, and zero stale "Phase 6" or "temporal closure axiom" references.

## Theorems Proved

### Phase 1: Predicate Equivalence (Defs.lean)
1. `s_free_eq_future_only` -- `is_S_free phi = is_future_only phi` (structural induction)
2. `u_free_eq_past_only` -- `is_U_free phi = is_past_only phi` (structural induction)
3. `syn_sep_eq_proper_sep` -- `is_syntactically_separated phi = is_properly_separated phi`
4. `separable_iff_properly_separable` -- `is_separable phi <-> is_properly_separable phi`
5. `int_truth_depends_only_on_atoms` -- truth depends only on atoms in `formula_atoms`

### Phase 2: Group A Axioms Replaced (SeparationThm.lean)
1. `all_formulas_properly_separable` -- bridge theorem via `separable_iff_properly_separable`
2. `all_past_properly_separable` -- was axiom, now theorem via `all_formulas_properly_separable`
3. `all_future_properly_separable` -- was axiom, now theorem
4. `untl_properly_separable` -- was axiom, now theorem
5. `snce_properly_separable` -- was axiom, now theorem
6. `all_properly_separable` -- simplified from structural induction to one-liner

### Phase 3: Atom Preservation (SeparationThm.lean)
1. `restrict_atoms` -- replaces atoms outside an allowed set with top
2. `formula_atoms_restrict_subset` -- restricted atoms are within allowed set
3. `restrict_atoms_preserves_properly_separated` -- restriction preserves separation
4. `restrict_atoms_truth` -- semantic agreement under modified model
5. `int_equiv_restrict_atoms` -- restriction preserves int_equiv
6. `proper_separation_preserves_atoms` -- was axiom, now theorem

## Axioms Eliminated

| # | Axiom | Approach |
|---|-------|----------|
| 1 | `all_past_properly_separable` | Predicate equivalence: `syn_sep = proper_sep` |
| 2 | `all_future_properly_separable` | Predicate equivalence |
| 3 | `untl_properly_separable` | Predicate equivalence |
| 4 | `snce_properly_separable` | Predicate equivalence |
| 5 | `proper_separation_preserves_atoms` | Atom restriction: replace extra atoms with top |

## Dead Code Removed

- `no_S_nested_in_U_separable_noax` (Hierarchy.lean) -- trivial wrapper
- `no_S_nested_in_U_separable_direct` (Hierarchy.lean) -- trivial wrapper

## Verification Results

- `lake build`: passes (1647 jobs)
- `grep -rn "^axiom" Separation/`: zero results
- `lean_verify proper_separation_theorem_int`: zero custom axioms
- `lean_verify proper_separation_preserves_atoms`: zero custom axioms
- `lean_verify all_properly_separable`: zero custom axioms
- `lean_verify all_formulas_properly_separable`: zero custom axioms
- `grep "Phase 6" Separation/`: zero results
- `grep "temporal closure axiom" Separation/`: zero results
- `grep "sorry" Separation/`: zero results

## Plan Deviations

- **Phase 3**: The plan called for strengthening 8+ hierarchy functions to track `formula_atoms` through the separation procedure (estimated 9 hours). Instead, a post-hoc "atom restriction" approach was used: take any separated witness, replace atoms outside `formula_atoms phi` with top. This reduced Phase 3 from 9 hours to ~1 hour while producing a cleaner proof. Plan steps 3.1-3.8 were skipped; step 3.9 was altered.
- **Phase 2**: Dead axioms `all_past_properly_separable` and `all_future_properly_separable` were converted to theorems with unused arguments (to preserve API) rather than deleted outright.
- **Phase 5**: ExpressiveCompleteness.lean verification was skipped due to a pre-existing build issue (Hierarchy.lean's import chain doesn't include FormulaOps.lean when built in isolation). This is not caused by this task.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` -- added 5 theorems
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replaced 5 axioms with theorems, added atom restriction infrastructure
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- deleted 2 dead wrappers, updated 6 stale comments
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- updated 3 stale comments
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- updated 3 stale comments
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- updated 1 stale comment
