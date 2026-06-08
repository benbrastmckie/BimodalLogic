# Phase Prerequisite Handoff: Separation Theorem Sorry Fixes

## Summary

Fixed 3 pre-existing sorry sites in the Separation Hierarchy module chain, making
`all_formulas_separable` (GHR94 Theorem 10.2.9) sorry-free. This was a prerequisite
for the bypass plan that was not identified during planning (the research reports
incorrectly stated the separation theorem was already sorry-free).

## What Was Done

### Sorry 1 & 2 (HierarchyCompletion.lean lines 299, 324)

**Problem**: `snce_single_U_depth_one_sep_with_U_type` returns
`is_separable_with_U_type _ A'' B''` with box-normalized types `A'' = replace_box_with_top A`,
but the goal requires `is_separable_with_U_type _ A B` with original types.

**Solution**: Added bridge infrastructure in HierarchyDefs.lean:
- `replace_untl_args`: replaces all `.untl` node arguments in a formula
- `replace_untl_args_u_free_eq`: identity on U-free formulas
- `replace_untl_args_preserves_separated`: preserves syntactic separation
- `replace_untl_args_equiv`: preserves `int_equiv` given `int_equiv A_old A_new`
- `replace_untl_args_has_single_U_type`: produces `has_single_U_type _ A_new B_new`
- `is_separable_with_U_type_replace_args`: the top-level bridge lemma

### Sorry 3 (HierarchyCaseSep.lean line 352)

**Problem**: `S(ev, q OR U(A,B))` with U-free `ev` needed `is_separable_with_U_type` but
only `is_separable` was available.

**Solution**: Added `snce_Ufree_event_qU_guard_sep_with_U_type` following the case3
decomposition from `case5_sep_with_U_type_Z_gen`, adapted for U-free events:
- D1: `S(ev, q)` -- entirely U-free, trivial
- D2: `S(alpha, Q_Z) AND (A OR B AND U)` -- via `snce_combined_U_sep_with_U_type`
- D3: `S(A AND (q OR U) AND S(alpha, Q_Z), q)` -- built local d21 analog with
  `case1_psi_properties` and event-split pattern

## Verification

```
lean_verify all_formulas_separable:
  axioms: [propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]
  NO sorryAx
```

## What Remains: Phases 2-6

### Phase 2: Kamp Translation (BLOCKING -- most complex remaining piece)

Need to build `monadic_to_temporal : MonadicFormula sig 1 -> Formula` and prove correctness.
This is a full Kamp theorem implementation requiring quantifier elimination by induction
on quantifier depth, using the separation theorem at each step. Estimated 1000+ lines.

**Key decision**: Whether to implement the full Kamp translation or find an alternative
bypass strategy.

### Phase 3: kamp_prior

Combine Phase 2 translation with Phase 1 bridge. Should be straightforward once Phase 2 exists.

### Phase 4: Replace US_expressively_complete_over_prior

Replace import of StaviCompleteness with Separation imports. Rewrite using kamp_prior.
Preserve exact type signature.

### Phase 5: Decouple Completeness.lean

Remove/guard ChronicleToCountermodel import.

### Phase 6: Full verification

`lake build`, `#print axioms completeness_discrete`.

## Key Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/HierarchyDefs.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/HierarchyCompletion.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/HierarchyCaseSep.lean`

## Immediate Next Action

Implement Phase 2 (Kamp Translation) or find an alternative bypass for
`stavi_expressive_completeness` that doesn't require the full Kamp theorem.
