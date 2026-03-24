# Implementation Summary: Task #48 v9 (Partial)

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Plan Version**: v9 (boundary-resolution-seed)
**Status**: PARTIAL
**Date**: 2026-03-23
**Session**: sess_1774309526_500d45

## Completed Work

### Phase 1: Define boundary_resolution_set [COMPLETED]

Added to `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`:

```lean
/-- Formulas that must be resolved at the boundary.
    When F(chi) in u, FF(chi) not in dc, and GF(chi) not in u, add chi to seed. -/
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.all_future (Formula.some_future chi) ∉ u}

theorem boundary_resolution_set_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (deferralClosure phi : Set Formula)) :
    boundary_resolution_set phi u ⊆ (deferralClosure phi : Set Formula)
```

Build verification: SuccExistence.lean builds successfully.

### Phase 2: Prove consistency of augmented seed [PARTIAL]

Added to `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`:

**Completed lemmas:**
1. `neg_not_in_g_content_when_F_in` - chi.neg not in g_content(u) when F(chi) in u
2. `neg_not_in_deferralDisjunctions` - chi.neg not in deferralDisjunctions (form mismatch)
3. `neg_not_in_p_step_blocking_restricted` - chi.neg not in p_step_blocking (form mismatch)
4. `neg_not_in_constrained_successor_seed_restricted` - combines the above

**Blocked:**
- `augmented_seed_consistent` - has 1 sorry at line 1973

The sorry blocks because proving consistency requires showing chi.neg is not *derivable* from old_seed, not just that chi.neg is not directly *in* old_seed.

## Blocker Analysis

The key gap is between:
- **Proven**: chi.neg not in old_seed (direct membership)
- **Needed**: chi.neg not derivable from old_seed

The challenge: old_seed contains g_content(u), deferralDisjunctions(u), and p_step_blocking. These can derive formulas via:
- Modal axiom T: G(phi) -> phi
- Propositional reasoning with disjunctions

If G(chi.neg) in old_seed (via GG(chi.neg) in u), then T-axiom gives chi.neg derivable.

The question is: is GG(chi.neg) in u?
- GG(chi.neg) = neg(FF(chi)) syntactically (modulo some conversions)
- We have FF(chi) not in dc (given)
- Negation completeness on FF(chi) requires FF(chi) in subformulaClosure
- But FF(chi) not in dc implies FF(chi) not in subformulaClosure

So the argument may be: since FF(chi) not in dc, we cannot apply negation completeness, so GG(chi.neg) not necessarily in u. But formalizing this requires careful tracking of closure properties.

## Phases Not Started

- Phase 3: Update constrained_successor_restricted
- Phase 4: Simplify restricted_single_step_forcing
- Phase 5: Update downstream and verify

## Recommendations

1. **Alternative consistency argument**: Instead of proving chi.neg not derivable, show that the augmented seed can be extended to an MCS by showing it's satisfiable in any model satisfying u.

2. **Strengthen boundary conditions**: Add h_chi_in_u : chi in u as additional condition to boundary_resolution_set. Then augmented_seed subset u, and consistency follows trivially.

3. **Different approach**: Instead of modifying the seed, modify the MCS extension procedure to prioritize boundary resolution formulas during Lindenbaum enumeration.

## Files Modified

1. `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
   - Added boundary_resolution_set definition and subset lemma

2. `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
   - Added neg_not_in_* lemmas
   - Added augmented_seed_consistent (with sorry)

## Sorry Count

Before: 7 sorries (2 deprecated + 5 boundary-related)
After: 8 sorries (1 new in augmented_seed_consistent)

## Next Steps

To complete the implementation:
1. Resolve the consistency proof blocker using one of the recommended approaches
2. Complete Phases 3-5 using the augmented seed
3. Update bounded_witness to use v2 constructions
4. Verify build and sorry count reduction
