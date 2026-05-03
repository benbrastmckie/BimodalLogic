# Phase 2 Complete: D0 Seed Consistency (Inconsistent Case)

## Summary

Phase 2 of Task 107 has been partially completed. The structure for `burgess_D0_finite_subset_consistent_incons` has been implemented, and `d0_a_event_list_mem` has been completed.

## Completed Work

### 1. `d0_a_event_list_mem` (Line ~1413) - COMPLETED
- **Status**: Fully proven
- **Proof strategy**: Used `List.mem_filterMap` to extract the witness formula, then case analysis on whether it's an Until or Since formula
- **Key tactics**: `by_cases` for case analysis on the existential conditions, `Classical.choose_spec` to extract the membership proof

### 2. `burgess_D0_finite_subset_consistent_incons` (Lines 1815-1883) - STRUCTURED
- **Status**: Full proof structure implemented with 2 remaining sorries
- **Approach**: Follows the Burgess compression argument adapted for the inconsistent case
- **Key components**:
  - B-guards extraction via `collect_guards`
  - C-events extraction via `d0_c_event_list`
  - A-events extraction via `d0_a_event_list`
  - BX5 self-accumulation on `untl(b, γ_hat)`
  - BX13 enrichment with `α_hat`
  - BX10 F-extraction
  - Event implication proof (4 cases)

## Remaining Work in Phase 2

### Sorry 1: Line 1871 - BX14 Separation Alternative
```lean
have h_enriched : Formula.untl q (Formula.and q (Formula.snce q α_hat).neg) ∈ A := by
  exact separation_until_mcs h_mcs_A h_bx5 (by sorry)
```

**Issue**: The consistent case used `separation_until_mcs` (BX14) which requires `¬untl(b∧β, γ_hat) ∈ A` from maximality. In the inconsistent case, we don't have this assumption.

**Possible approaches**:
1. Use a different event construction that doesn't require BX14
2. Show that the simpler event `q ∧ snce(q, α_hat)` is sufficient
3. Use the fact that β.neg ∈ B to simplify the guard structure

### Sorry 2: Line 1878 - Event Implication Proof (Since Case)
```lean
have h_event_implies_L : ∀ φ ∈ L, DerivationTree [event] φ := by
  sorry
```

**Status**: Cases 1-3 (B elements, β.neg, Until formulas) are complete. Case 4 (Since formulas) has partial progress.

**Remaining issue**: The Since case requires showing:
- `event → snce(q, α_hat) → snce(b, α_hat) → snce(β', α_hat) → snce(β', α')`
- The last step requires right monotonicity: `G(α_hat → α')` 
- Since `α_hat` is the conjunction of all A-events and `α'` is one element, we have `α_hat → α'` by conjunction elimination
- However, we need `G(α_hat → α')` for the modal right monotonicity axiom

## Verification

- `lake build` succeeds
- 5 sorries remain in Phase 3 (Lemma 2.7 related)
- 2 sorries remain in Phase 2 (documented above)

## References

- Burgess 1982 Section 2.6 (p. 170) - Lemma 2.6 D0 seed consistency
- BX5: `self_accum_until_mcs` - self-accumulation
- BX13: `enrichment_until_mcs` - enrichment with Since formula
- BX10: `until_implies_F_mcs` - F-extraction from Until

## Next Steps

For completing Phase 2:
1. Find an alternative to BX14 separation that works without the maximality witness
2. Complete the Since case of the event implication proof using right monotonicity

For Phase 3:
- The 5 sorries in Lemma 2.7 can be addressed after Phase 2 is complete
