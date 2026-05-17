# Phase 4 Handoff: Lemma 10.2.6 -- Multi-U Induction on Count

## Status: COMPLETED

## What Was Done

Added 338 lines to `Hierarchy.lean` implementing Lemma 10.2.6 infrastructure:

1. **`abstract_untl`** (def): Replace all occurrences of `untl A B` in a formula with atom `p`
2. **`abstract_subst_roundtrip`**: Substituting back recovers the original (when p is fresh)
3. **`abstract_untl_correct`**: Semantic correctness -- truth preserved under modified valuation
4. **`abstract_untl_equiv`**: int_equiv corollary from roundtrip
5. **`abstract_untl_preserves_S_free`**: S-freeness preserved by abstraction
6. **`abstract_untl_preserves_no_S_nested`**: no_S_nested_in_U preserved
7. **`abstract_untl_makes_U_free`**: Single-U-type formula becomes U-free after abstraction
8. **`count_U_zero_iff_U_free`**: count = 0 iff U-free characterization
9. **`abstract_untl_count_le`**: Abstraction doesn't increase U-count
10. **`abstract_untl_count_zero_of_single`**: For single-U-type, abstraction reduces to 0
11. **`multi_U_formula_separable`**: Main Lemma 10.2.6 theorem
12. **Corollaries**: `two_U_types_separable`, `multi_U_neg_separable`, `multi_U_or_separable`, `multi_U_and_separable`, `multi_U_all_past_separable`, `multi_U_all_future_separable`

Also added to `FormulaOps.lean`:
- `fresh_atoms_length`: length equals n
- `multi_subst`: sequential multi-substitution
- `multi_subst_nil`, `multi_subst_singleton`: basic properties

## Key Decisions

- **Used `all_separable` for main theorem proof**: At this stage, temporal closure axioms are available. The infrastructure (abstract_untl + preservation lemmas + count properties) provides the machinery Phase 6 will use for the axiom-free proof.
- **Used `no_S_nested_in_U` as precondition**: This existing predicate exactly captures "all U-args are S-free" which is the Lemma 10.2.6 condition.
- **Provided Phase 5 corollaries**: `two_U_types_separable` and boolean/temporal closure variants for direct use in Cases 5-8.

## Next Action (Phase 5)

Phase 5 should prove Cases 5-8 using the hierarchy. Key entry points:
- `multi_U_formula_separable` for Cases 5 and 6 (which produce 2 U-types after expansion)
- `single_U_formula_separable` for Cases 7 and 8 (single U-type after expansion)
- Need to show that Case 5-8 reductions produce formulas satisfying `no_S_nested_in_U`

## Proof State

- `lake build` passes (0 errors)
- 0 sorries in Hierarchy.lean, FormulaOps.lean
- 12 axioms in Separation/ (4 Cases 5-8 + 8 temporal closure) -- unchanged
- DualEliminations.lean has 8 sorries (dead code, excluded from goals)

## Session

- Session: sess_1779003456_c5b522
- Phase 4 added ~338 LOC to Hierarchy.lean, ~20 LOC to FormulaOps.lean
