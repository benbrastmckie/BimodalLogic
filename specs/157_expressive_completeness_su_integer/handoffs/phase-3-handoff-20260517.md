# Phase 3 Handoff: Lemma 10.2.5 -- Single-U Elimination

## Completed

- Created `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (~190 LOC)
- Proved `single_U_formula_separable`: any formula with single U-type U(A,B) (A, B S-free) is separable
- Defined `has_single_U_type` predicate for characterizing single-U-type formulas
- Proved helper theorems for building `has_single_U_type` evidence (neg, and, or, untl, all_past, all_future, snce, imp)
- Fixed name clash in SeparationThm.lean (removed duplicate `is_separable_of_equiv`)
- Added Hierarchy.lean to Separation.lean hub imports
- All builds pass, 0 sorry, 0 new axioms

## Key Decisions

1. Used structural induction instead of S-nesting measure induction
2. The `snce` case uses the `snce_separable` temporal closure axiom (from SeparationThm.lean)
3. This axiom will be eliminated in Phase 6 when the full hierarchy is assembled
4. The theorem has the right interface for Phase 5's use in proving Cases 5-8

## Immediate Next Action

Phase 4: Lemma 10.2.6 -- Multi-U Induction on Count. Define `count_distinct_U_under_S` measure, prove fresh-atom substitution preserves truth, prove that after substituting atoms for all-but-one U-types, the formula has single U-type for Lemma 10.2.5.

## Current Proof State

- `single_U_formula_separable` is fully proved (no goals)
- Depends on: `snce_separable`, `all_past_separable`, `all_future_separable` (axioms from SeparationThm.lean)
- All 12 axioms remain (4 in Eliminations, 8 in SeparationThm) -- same as before Phase 3

## Deviations from Plan

- Tasks 3.1, 3.2 skipped (measure already exists and explicit decrease proof not needed)
- Tasks 3.3, 3.4, 3.5 altered (structural induction replaces S-nesting induction)
- Net effect: simpler proof that achieves same interface for downstream phases
