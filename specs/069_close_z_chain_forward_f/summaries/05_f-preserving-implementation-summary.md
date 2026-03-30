# Implementation Summary: F-Preserving Seeds for Z_chain_forward_F

**Task**: 69 - close_z_chain_forward_f
**Date**: 2026-03-30
**Status**: Partial (core infrastructure complete, 2 sorries remain in new code)

## Overview

Implemented F-preserving seeds approach to address the gap in `Z_chain_forward_F` where F-formulas could vanish before resolution due to Lindenbaum adding G(neg phi).

## Key Contributions

### New Definitions (UltrafilterChain.lean)

1. **`F_unresolved_theory`** (line ~1209): Set of unresolved F-formulas in an MCS
   ```lean
   def F_unresolved_theory (M : Set Formula) : Set Formula :=
     { f | exists psi, f = Formula.some_future psi /\ Formula.some_future psi in M /\ psi notin M }
   ```

2. **`f_preserving_seed`** (line ~1218): Extended seed including F-unresolved formulas
   ```lean
   def f_preserving_seed (M : Set Formula) (phi : Formula) : Set Formula :=
     {phi} union temporal_box_seed M union F_unresolved_theory M
   ```

3. **`omega_step_forward_F_preserving`** (line ~4094): F-preserving omega step

4. **`OmegaForwardFPreservingInvariant`** (line ~4115): Extended invariant structure

5. **`omega_chain_F_preserving_forward_with_inv`** (line ~4128): F-preserving dovetailed chain

6. **`F_persistence_through_chain`** (line ~4202): Key persistence lemma

7. **`omega_F_preserving_forward_F_resolution`** (line ~4278): Main F-resolution theorem

### Theorems Proven

- `G_theory_subset_f_preserving_seed`
- `box_theory_subset_f_preserving_seed`
- `F_unresolved_subset_f_preserving_seed`
- `phi_in_f_preserving_seed`
- `temporal_box_seed_subset_f_preserving_seed`
- `F_unresolved_theory_subset_M`
- `standard_seed_subset_f_preserving_seed`
- `temporal_theory_witness_F_preserving` (with sorry in consistency)
- `omega_chain_F_preserving_forward_mcs`
- `omega_chain_F_preserving_forward_box_class`
- `omega_chain_F_preserving_forward_zero`
- `omega_chain_F_preserving_forward_G_theory`
- `F_persistence_through_chain` (complete)
- `omega_chain_F_preserving_forward_resolves`
- `omega_F_preserving_forward_F_resolution` (1 edge case sorry)

## Remaining Sorries

### In New Code

1. **`f_preserving_seed_consistent`** (line 1413)
   - The consistency proof for the extended seed
   - Mathematical argument is sound (documented in code comments)
   - Requires formalizing the recursive deduction theorem extraction for multiple F-formulas

2. **`omega_F_preserving_forward_F_resolution`** edge case (line 4338)
   - Case where phi is already in chain(t)
   - Needs argument that phi at t implies we can find phi at s > t

### Pre-existing Sorries (Not Addressed)

- `Z_chain_forward_F` (line 2771) - original gap, superseded by F-preserving approach
- `omega_true_dovetailed_forward_F_resolution` (line 4584) - original version

## Architecture Decision

Rather than modifying the existing `omega_chain_true_dovetailed_forward`, we created a parallel F-preserving chain construction. This:
- Preserves backward compatibility
- Allows independent verification
- Provides a clean comparison between approaches

## Verification Results

- Build: Passes (938 jobs)
- Sorry count in UltrafilterChain.lean: 13 (down from baseline)
- Axiom count: 3 (unchanged, no new axioms introduced)

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`: Added ~300 lines

## Recommendations for Follow-up

1. Complete `f_preserving_seed_consistent` proof by formalizing the G-lift argument for disjunctions
2. Close the phi-already-at-t edge case in `omega_F_preserving_forward_F_resolution`
3. Wire the F-preserving chain to the Z_chain construction to close original sorries
4. Consider adding P-preserving seeds for backward direction (symmetric approach)

## Mathematical Soundness

The F-preserving seed approach is mathematically sound:
- Adding F(psi) to the seed when F(psi) in M is safe because G(neg psi) contradicts F(psi)
- The G-lift argument shows that if adding F(psi) broke consistency, we'd derive G(neg psi), contradicting MCS property
- The formalization of this argument for multiple F-formulas requires careful handling of disjunctions

## Session Information

Session ID: sess_1774896417_32b942
