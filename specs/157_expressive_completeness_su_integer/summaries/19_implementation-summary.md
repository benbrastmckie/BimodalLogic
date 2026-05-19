# Implementation Summary: Task #157 -- Phase 4-5 Partial (Plan v19)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: PARTIAL
- **Plan**: plans/19_revised-restructuring-plan.md
- **Session**: sess_1779214591_6c5f29

## Changes Made

### Phase 4: Rewrite `no_S_nested_in_U_separable_direct` (COMPLETED with deviations)

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

1. **Added `subst_U_free_U_nesting_depth_le_one`**: Proves that substituting `.untl A B` (with U-free A, B) into a U-free formula gives `U_nesting_depth <= 1`.

2. **Added `callback_U_nesting_depth_le_one`**: Proves callback formulas from back-substitution have `U_nesting_depth <= 1` when the extracted U-type has U-free args.

3. **Added `subst_in_separated_separable_depth`**: A variant of `subst_in_separated_separable` that passes `U_nesting_depth <= 1` to the callback.

4. **Rewrote `no_S_nested_in_U_separable_direct`**: Replaced 4-line thin wrapper with proper `U_nesting_depth` + `count_U_subformulas` double induction per GHR94 Lemma 10.2.7.

### Phase 5 Task 5.1: Rewrite `all_formulas_separable_aux` (COMPLETED)

Replaced both `.snce` and `.untl` n=1 fallback paths with direct calls to `no_S_nested_in_U_separable_direct`.

### Phase 5 Tasks 5.2-5.7: BLOCKED

Circular import dependency prevents replacing axioms in SeparationThm.lean.

## Plan Deviations

- Task 4.2 altered: Used double induction instead of innermost U-type extraction
- Task 4.3 deferred: Axiom-freeness requires Phase 5 circular import resolution
- Phase 5 Tasks 5.2-5.7 blocked: Circular import

## Verification

- `lake build`: SUCCESS
- Sorry count (modified files): 0
- New axioms: 0
- Vacuous definitions: 0

## Remaining Work

1. Break circular import (create HierarchyCore.lean)
2. Replace 9 axioms in SeparationThm.lean
3. Phases 6-7: cleanup and final verification
