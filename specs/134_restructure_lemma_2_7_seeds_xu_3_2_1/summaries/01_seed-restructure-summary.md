# Implementation Summary: Restructure lemma_2_7/lemma_2_7_since Seeds Using Xu 3.2.1

- **Task**: 134
- **Status**: Implemented
- **Date**: 2026-05-13

## Changes

### Seed Simplification

Reduced both `lemma_2_7_seed` and `lemma_2_7_since_seed` from 5 components to 3 components each:

**Until-direction (`lemma_2_7_seed`)**:
- Before: `B ∪ {eta} ∪ {untl(γ,β)} ∪ {snce(α,β)} ∪ {snce(α, β∧xi)}`
- After: `B ∪ {eta} ∪ {snce(α, β∧xi)}`

**Since-direction (`lemma_2_7_since_seed`)**:
- Before: `B ∪ {eta} ∪ {untl(γ,β)} ∪ {snce(α,β)} ∪ {untl(γ, β∧xi)}`
- After: `B ∪ {eta} ∪ {untl(γ, β∧xi)}`

Components 3 (`{untl(γ,β)}`) and 4 (`{snce(α,β)}`) were removed because Xu 3.2.1 (task 115) proves these formulas are already in B for any BurgessR3Maximal(A,B,C).

### Proof Body Updates

All four main lemma proofs (lemma_2_7, lemma_2_7_since, lemma_2_8, lemma_2_8_since) now derive untl/snce memberships in D via Xu 3.2.1 + B subset D, following the pattern established in `lemma_2_6_splitting`:
```
h_untl_D := h_B_sub_D (xu_lemma_3_2_1_until h_mcs_A h_mcs_C h_r3m hbeta hgamma)
h_snce_D := h_B_sub_D (xu_lemma_3_2_1_since h_mcs_A h_mcs_C h_r3m hbeta halpha)
```

### Consistency Proof Simplification

All four consistency proofs simplified from 5-way to 3-way case analysis:
- `lemma_2_7_seed_consistent`: 5-way -> 3-way
- `lemma_2_8_seed_consistent`: 5-way -> 3-way
- `lemma_2_7_since_seed_consistent`: 5-way -> 3-way (completely rewritten; no longer uses L_14 filtering through lemma_2_7_seed)
- `lemma_2_8_since_seed_consistent`: 5-way -> 3-way (completely rewritten)

### Dead Code Removed

- `l27_c_event_list` and `l27_c_event_list_mem` (Until C-event extraction, component 3)
- `l27_guard_untl_val` and `l27_collect_guards_mem_of_untl` (Until guard helpers, component 3)
- `l27_guard_snce_val` and `l27_collect_guards_mem_of_snce` (Since guard helpers, component 4)
- `l27_a_event_list_α_mem` (Since A-event extraction, component 4)
- `l27_c_event_list_γ_mem` (Until C-event membership)
- Simplified `l27_guard` from 5-case to 3-case
- Simplified `l27_a_event_list` and `l27_a_event_list_mem` to handle only component 3
- Simplified `l27_collect_guards_mem_of_snce_xi` (removed extra preconditions)
- Simplified `l27_a_event_list_α_mem_xi` (removed extra preconditions)

## Metrics

- **Line count**: 4333 -> 3555 (778 lines removed, 18% reduction)
- **Sorries in PointInsertion.lean**: 0
- **New axioms**: 0
- **CounterexampleElimination.lean**: Zero modifications
- **Build**: Passes with zero errors

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`

## Output Type Preservation

All four output types remain unchanged:
- `lemma_2_7`: `exists B' D B'', BurgessR3Maximal A B' D /\ ...`
- `lemma_2_7_since`: `exists B' D B'', BurgessR3Maximal A B' D /\ ...`
- `lemma_2_8`: same structure with neg_disj hypothesis
- `lemma_2_8_since`: same structure with neg_disj hypothesis
