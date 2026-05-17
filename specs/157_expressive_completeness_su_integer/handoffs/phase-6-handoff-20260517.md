# Phase 6 Handoff: Blocked on Temporal Closure

**Date**: 2026-05-17
**Session**: sess_1779040893_b6c1b2
**Phase**: 6 (blocked at tasks 6.7-6.14)

## Current State

- Tasks 6.1-6.6: COMPLETED and verified (expand_temporal, equivalence proofs, JD-zero lemma)
- Tasks 6.7-6.14: BLOCKED on circular dependency
- TemporalClosure.lean: Cleaned up (removed ~300-line analysis comment, fixed incorrect theorems)
- Build: Passes successfully (1652 jobs, no errors in Separation/ files)
- Axiom count: 8 axioms remain in SeparationThm.lean (4 weak + 4 proper)
- Sorry count: 4 sorries in ExpressiveCompleteness.lean (2 formula + 2 proof obligations)

## Blocker Analysis

The temporal closure axioms cannot be eliminated due to a **circular dependency**:

```
all_separable (structural induction)
  └─ needs temporal closure axioms (snce_separable, untl_separable, etc.)
       └─ needs Cases 5-8 to be axiom-free
            └─ Cases 5-8 currently use all_separable (circular!)
```

**Why Cases 5-8 use all_separable**: GHR94's explicit separated formulas for Cases 5-8
are incorrect on integer (discrete) time. The existence proof goes through all_separable.

**What was tried and why each fails**:

1. **Direct no_S_nested_in_U → separable**: Circular in snce, all_past, all_future cases
2. **abstract_untl + substitute back**: subst_formula G p (untl A B) breaks U-freeness in snce args of G
3. **WF induction on (JD, size)**: Transformed formula can be larger than original
4. **Independent Cases 5-8**: No correct explicit formulas found for Z
5. **subst_separable lemma**: False in general (counterexample: snce with atom p substituted by untl)

## Possible Resolutions (for future research)

1. **Find explicit Cases 5-8 formulas for Z**: Research problem. GHR94's dense-time formulas fail on Z. Correct formulas would bypass all circularity.
2. **Restricted subst_separable**: Track WHERE atom p appears in separated G. If p never appears in snce/all_past args, substitution preserves separation. Requires proving the specific G from abstract_untl has this property.
3. **Combined WF induction**: Single induction with measure that accounts for formula structure + abstraction progress. Complex but potentially viable.
4. **Alternative proof approach**: Reynolds' axiomatization, automata-theoretic argument, or EF games for Z-separation.

## Files Modified This Session

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean`: Cleaned up (removed large comment block, fixed incorrect `expand_temporal_preserves_S_free`/`expand_temporal_preserves_U_free` theorems, removed `abstract_untl_preserves_separated` that depended on Hierarchy.lean import)
- `specs/157_expressive_completeness_su_integer/plans/03_hierarchy-first-plan.md`: Updated Phase 6 to [BLOCKED] with blocker documentation

## Key Decisions

1. Removed previous agent's `expand_temporal_preserves_S_free` and `expand_temporal_preserves_U_free` — these were FALSE for the all_past/all_future cases (expand_temporal introduces snce/untl which break S/U-freeness)
2. Replaced with correctly restricted versions `expand_preserves_U_free_no_allf` and `expand_preserves_S_free_no_allp` that require `has_no_allpast_allfuture`
3. Removed `abstract_untl_preserves_separated` — depends on Hierarchy.lean import which would introduce axiom dependency

## Immediate Next Action

Phase 6 requires mathematical research to resolve the blocker. The most promising direction is finding correct explicit separated formulas for Cases 5-8 on integer time, which would completely break the circular dependency.
