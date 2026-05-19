# Phase 3 Handoff: Hierarchy Theorem (GHR94 10.2.8)

## Status: PARTIAL -- `decreasing_by sorry` in termination proof

## What Was Done

### New lemmas added to Hierarchy.lean:
1. `abstract_snce_subst_roundtrip` (line ~539) -- syntactic roundtrip for abstract_snce + subst. Dual of `abstract_subst_roundtrip`.
2. `untl_congr` / `snce_congr` (line ~1553) -- int_equiv congruence for temporal operators.
3. `no_S_nested_sep_callback` (line ~1584) -- self-referential callback: `no_S_nested_in_U chi -> is_separable chi`. Uses `no_S_nested_in_U_separable_param` with itself as callback. **HAS `decreasing_by sorry` for termination.**
4. `no_S_nested_sep_all` (line ~1591) -- thin wrapper around `no_S_nested_sep_callback`.

### Proof architecture:
- `.snce a b`: By IH, get separated psi_a, psi_b. Box-normalize them (`replace_box_with_top`). The box-normalized `.snce` satisfies `no_S_nested_in_U` (via `snce_of_boxfree_sep_no_S_nested`). Apply `no_S_nested_sep_all`.
- `.untl a b`: By IH, get separated psi_a, psi_b. Box-normalize. `.untl(box-norm psi_a, box-norm psi_b)` satisfies `no_U_nested_in_S` (via `untl_of_boxfree_sep_no_U_nested`). Apply `swap_temporal` duality to convert to `no_S_nested_in_U`, then `no_S_nested_sep_all`, then dual back.

### Key insight:
- `is_syntactically_separated phi` does NOT imply `no_S_nested_in_U phi` because `.box` contents are opaque in separation but transparent in `no_S_nested_in_U`.
- The fix is `replace_box_with_top`, which is semantically equivalent (`replace_box_equiv`) and produces formulas where `no_S_nested_in_U` holds.

## Remaining Issue

`no_S_nested_sep_callback` has `decreasing_by sorry` because:
- It calls itself through the callback parameter of `no_S_nested_in_U_separable_param`.
- The callback formula zeta has `no_S_nested_in_U zeta` but `sizeOf zeta` is NOT bounded by `sizeOf chi`.
- Lean's termination checker can't verify the recursion terminates because `no_S_nested_in_U_separable_param` is opaque (a `theorem`).

### Why the recursion IS well-founded (meta-theoretically):
1. `no_S_nested_in_U_separable_param` internally uses `count_U_subformulas` induction (terminates).
2. The callback is invoked finitely many times per call to `no_S_nested_in_U_separable_param`.
3. Each callback formula has `no_S_nested_in_U`.
4. Applying `no_S_nested_sep_callback` to a callback formula triggers (1) again with a new count_U.
5. The TOTAL work is finite because the recursion tree has bounded branching and bounded depth (the depth is bounded by the junction depth of the formula, though this is hard to formalize).

### Possible fixes:
1. **Inline `no_S_nested_in_U_separable_param`**: Build a SINGLE well-founded recursion on `(junction_depth, count_U_subformulas, sizeOf)` triple that handles both the count_U induction and the callback in one function. This would require duplicating ~50 lines from `no_S_nested_in_U_separable_param`.
2. **Use `single_U_formula_separable` for the callback**: The callback formulas have `has_single_U_type ... A B` (since substitution introduces only one kind of `.untl`). Prove a callback-free version of `single_U_formula_separable` by noting the `.snce` case reduces to `.snce` of separated formulas which are `no_S_nested_in_U` after box-normalization, creating a STRICT sizeOf decrease.
3. **Use `Acc.intro` manually**: Construct an `Acc` proof for the relation by showing every formula is accessible via a transfinite induction argument.

### Verification:
- `lean_verify all_formulas_separable_aux` shows: `["propext", "sorryAx", "Classical.choice", "Quot.sound"]`. The `sorryAx` comes from the `decreasing_by sorry` in `no_S_nested_sep_callback`.
- Once the termination sorry is eliminated, `sorryAx` should disappear, leaving only standard axioms.

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

## Next Steps
1. Eliminate the `decreasing_by sorry` in `no_S_nested_sep_callback` (the main blocker).
2. Complete Tasks 3.4-3.6 (update wrapper, replace `all_separable` references, verify).
3. Proceed to Phase 4 (axiom elimination in SeparationThm.lean).
