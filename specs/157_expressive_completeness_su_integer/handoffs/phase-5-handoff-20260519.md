# Phase 5 Handoff -- Circular Import Blocker

## Immediate Next Action

Resolve the circular import between Hierarchy.lean and SeparationThm.lean by extracting the `all_formulas_separable` chain into a new file `HierarchyCore.lean`.

## Current State

- Phase 4 Task 4.2: COMPLETED -- `no_S_nested_in_U_separable_direct` rewritten with `U_nesting_depth` + `count_U_subformulas` double induction
- Phase 5 Task 5.1: COMPLETED -- `all_formulas_separable_aux` now calls `no_S_nested_in_U_separable_direct` directly
- Phase 5 Tasks 5.2-5.7: BLOCKED on circular import

## The Circular Import

```
Hierarchy.lean --imports--> SeparationThm.lean
                  (uses: all_separable, snce_separable, untl_separable)

SeparationThm.lean --cannot import--> Hierarchy.lean
                      (needs: all_formulas_separable to replace axioms)
```

## Resolution Strategy

Create `HierarchyCore.lean` containing:
- `no_S_nested_in_U_separable_direct` and its dependencies
- `all_formulas_separable_aux` and `all_formulas_separable`

Then:
1. Hierarchy.lean imports HierarchyCore.lean (instead of defining these)
2. SeparationThm.lean imports HierarchyCore.lean (instead of defining axioms)
3. Both can use `all_formulas_separable`

## Key Decisions

1. The depth >= 2 case of `no_S_nested_in_U_separable_direct` with non-U-free extracted args still uses `all_separable`. This is acceptable because once SeparationThm axioms become theorems, the transitive dependency resolves.

2. The early theorems in Hierarchy.lean (`single_U_formula_separable`, `single_U_formula_separable_noax`, etc.) continue to use `snce_separable`/`all_separable`. Once these become theorems, the dependency resolves automatically.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`: +165 lines (helpers + rewrite)
