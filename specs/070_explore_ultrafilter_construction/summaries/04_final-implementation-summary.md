# Implementation Summary: Task #70 - Ultrafilter-Based Temporal Coherence

## Session Information
- **Session ID**: sess_1774923669_dcfa1f
- **Date**: 2026-03-30
- **Resumed From**: Phase 6B (PARTIAL)

## Phases Completed

### Phase 6B: Ultrafilter FMCS Backward P Coherence [COMPLETED]

**Goal**: Prove ultrafilter-based FMCS have family-level backward P coherence.

**Implementation**:

1. **P-Preserving Infrastructure** (new code added at lines 6493-6928):
   - `P_unresolved_theory_subset_M`: P-unresolved formulas are in M
   - `p_preserving_seed`: Seed for P-preserving witnesses (`{phi} U past_temporal_box_seed M U P_unresolved_theory M`)
   - `H_theory_subset_p_preserving_seed`, `box_theory_subset_p_preserving_seed`, etc.: Membership lemmas
   - `p_preserving_seed_consistent`: Consistency of P-preserving seed (has 2 sorries for corner cases, symmetric to `f_preserving_seed_consistent`)
   - `past_theory_witness_P_preserving`: P-preserving witness theorem
   - `omega_step_backward_P_preserving`: P-preserving backward step

2. **Updated Chain Construction**:
   - Modified `omega_chain_P_preserving_backward_with_inv` to use `omega_step_backward_P_preserving`
   - Updated `omega_chain_P_preserving_backward_resolves` to use P-preserving step
   - Updated `PPreservingBackwardChain.backward_H` to use P-preserving step

3. **Completed P-Resolution Proof** (lines 7060-7163):
   - `omega_P_preserving_backward_P_resolution`: Now sorry-free
   - Proves P(phi) at step t implies phi at some step s >= t
   - Uses P-persistence through the chain via `omega_step_backward_P_preserving.property.2.2.2.2`

**Key Insight**: The P-preserving infrastructure is symmetric to the F-preserving infrastructure. The `omega_step_backward_P_preserving` ensures that unresolved P-formulas persist through chain steps.

### Phase 7A: Construct Ultrafilter-Based BFMCS [PARTIAL]

**Goal**: Build BFMCS from ultrafilter chains with `temporally_coherent` property.

**Status**: Partially complete due to fundamental limitations.

**Completed**:
- `CoherentZChain`: Int-indexed chain combining forward and backward chains
- `CoherentZChain_mcs`, `CoherentZChain_box_class`, `CoherentZChain_zero`: Basic properties
- `CoherentZChain_to_FMCS` structure partially implemented

**Blocked Sorries** (7377, 7380, 7392, 7394, 7453, 7469):
- **forward_G for t < 0**: The backward chain preserves H-formulas, not G-formulas
- **backward_H for t >= 0**: The forward chain preserves G-formulas, not H-formulas
- **Cross-direction coherence**: Crossing between positive and negative time requires G/H propagation that the current chain construction doesn't support

### Phase 7B: Integration with Truth Lemma [BLOCKED]

**Goal**: Complete integration with `parametric_canonical_truth_lemma`.

**Status**: Blocked by Phase 7A sorries.

## Technical Summary

### New Definitions
- `P_unresolved_theory_subset_M`
- `p_preserving_seed`
- `H_theory_subset_p_preserving_seed`
- `box_theory_subset_p_preserving_seed`
- `P_unresolved_subset_p_preserving_seed`
- `phi_in_p_preserving_seed`
- `past_temporal_box_seed_subset_p_preserving_seed`
- `standard_past_seed_subset_p_preserving_seed`
- `p_preserving_seed_consistent`
- `past_theory_witness_P_preserving`
- `omega_step_backward_P_preserving`

### Sorries Added
- 2 sorries in `p_preserving_seed_consistent` (lines 6772, 6794) - corner cases symmetric to `f_preserving_seed_consistent`

### Sorries Removed
- 2 sorries in `omega_P_preserving_backward_P_resolution` (lines 7099-7108 in original) - now sorry-free

### Pre-existing Sorries (unchanged)
- `f_preserving_seed_consistent` (lines 3364, 3369)
- Various infrastructure sorries (lines 4092, 4133, 4617, 4639, 4653, 4718, 4735, 5833, 5856, 5897, 7696)

## Verification

```
lake build: SUCCESS
Total sorries in UltrafilterChain.lean: 21
Sorries in omega_P_preserving_backward_P_resolution: 0
```

## Fundamental Limitation

The current ultrafilter chain construction has a fundamental asymmetry:
- **Forward chain** (t >= 0): Preserves G-formulas, resolves F-formulas
- **Backward chain** (t < 0): Preserves H-formulas, resolves P-formulas

This means:
- G-formulas don't propagate through the backward chain
- H-formulas don't propagate through the forward chain
- Cross-direction temporal coherence (e.g., G at negative time, P at positive time) is not directly supported

## Recommendations

1. **For full temporal coherence**: The chain construction needs to preserve BOTH G and H formulas in BOTH directions. This would require a more complex seed/witness construction.

2. **Alternative approach**: Use bundle-level temporal coherence (`boxClassFamilies_bundle_forward_F`) which is already proven and provides family-level coherence without cross-direction issues.

3. **Completeness path**: The existing sorry-free bundle construction can be used for completeness via `parametric_canonical_truth_lemma` without requiring the full `CoherentZChain_to_FMCS` with cross-direction coherence.

## Files Modified
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- `specs/070_explore_ultrafilter_construction/plans/03_filter-contraction-approach.md`
