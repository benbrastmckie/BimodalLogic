# Implementation Summary: Task 58 - Omega-Enumeration BFMCS (Partial)

**Status**: PARTIAL
**Plan**: `plans/05_omega-enumeration.md`
**Session**: sess_1774479337_c37b92
**Date**: 2026-03-25

## Objective

Implement omega-enumeration BFMCS architecture to eliminate 3 sorries in `FrameConditions/Completeness.lean`:
- `dense_completeness_fc` (line 108)
- `discrete_completeness_fc` (line 151)
- `completeness_over_Int` (line 170)

## Completed Work

### Phase 1: Prerequisites and Foundation [COMPLETED]

Added to `UltrafilterChain.lean`:

1. **`box_class_agree_trans`**: Transitivity of box_class_agree
2. **`F_obligations`, `P_obligations`**: Sets of F/P-formulas in an MCS
3. **`F_inner`, `P_inner`**: Extract inner formula from F/P-obligations
4. **`G_theory_preserved_by_witness`**: G-theory preservation lemma
5. **`H_theory_preserved_by_witness`**: H-theory preservation lemma

### Phase 2: Omega Chain Forward Construction [COMPLETED]

1. **`omega_step_forward`**: Single step F-witness construction
2. **`OmegaForwardInvariant`**: Invariant tracking MCS, G-propagation, box-class
3. **`omega_chain_forward_with_inv`**: Forward chain with full invariant
4. **`omega_chain_forward`**: The Nat-indexed forward chain
5. **`omega_chain_forward_mcs`**: Each element is MCS
6. **`omega_chain_forward_box_class`**: Box-class agreement with M0
7. **`omega_chain_forward_zero`**: Chain at 0 = M0
8. **`omega_chain_forward_G_theory`**: G-theory propagation from M0
9. **`omega_chain_forward_G_monotone`**: G-formulas propagate forward in chain

### Phase 3: Omega Chain Backward Construction [COMPLETED]

Symmetric to Phase 2:
1. **`omega_step_backward`**: Single step P-witness construction
2. **`OmegaBackwardInvariant`**: Invariant tracking MCS, H-propagation, box-class
3. **`omega_chain_backward_with_inv`**: Backward chain with full invariant
4. **`omega_chain_backward`**: The Nat-indexed backward chain
5. **`omega_chain_backward_mcs`**: Each element is MCS
6. **`omega_chain_backward_box_class`**: Box-class agreement with M0
7. **`omega_chain_backward_zero`**: Chain at 0 = M0
8. **`omega_chain_backward_H_theory`**: H-theory propagation from M0

### Phase 4: Z-Chain and OmegaFMCS Construction [PARTIAL]

1. **`Z_chain`**: Combined Int-indexed chain (forward for t >= 0, backward for t < 0)
2. **`Z_chain_mcs`**: Every element is MCS
3. **`Z_chain_box_class`**: Box-class agreement with M0
4. **`Z_chain_zero`**: Z_chain at 0 = M0
5. **`OmegaFMCS`**: FMCS wrapper around Z_chain

**Incomplete** (with sorry):
- `Z_chain_forward_G`: G-propagation has gaps at boundary crossing (backward to forward)
- `Z_chain_backward_H`: H-propagation has gaps (symmetric issue)

### Phase 5: Temporal Coherence [PARTIAL]

**Incomplete** (with sorry):
- `Z_chain_forward_F`: F-witness existence for arbitrary F(phi)
- `Z_chain_backward_P`: P-witness existence for arbitrary P(phi)

## Remaining Work

### Critical Gaps

1. **FMCS Coherence (forward_G, backward_H)**:
   - The backward chain preserves H-theory from M0 but NOT G-theory
   - When crossing from backward chain to forward chain, G-formulas don't propagate
   - Fix: Modify `past_theory_witness_exists` to also preserve G-theory, or extend backward chain invariant

2. **Temporal Coherence (forward_F, backward_P)**:
   - Current chain resolves only F_top at each step, not arbitrary F-obligations
   - Need dovetailed resolution: at step n, resolve the n-th F-obligation
   - Requires enumeration of formulas and tracking which obligations are resolved

### Architectural Issue

The core mathematical challenge: the witness theorems (`temporal_theory_witness_exists`, `past_theory_witness_exists`) preserve one type of theory:
- F-witnesses preserve G-theory
- P-witnesses preserve H-theory

But for the Z-chain boundary crossing, we need BOTH:
- G-theory to propagate forward (from backward chain through M0 to forward chain)
- H-theory to propagate backward (from forward chain through M0 to backward chain)

### Possible Solutions

1. **Extended Witness Theorem**: Prove a combined witness that preserves BOTH G and H theories
2. **Separate F/P Resolution**: Build a different chain where F-obligations are resolved going forward and P-obligations going backward, with proper theory propagation
3. **Bundle-Level Coherence**: Weaken the requirement to bundle-level (exists family with phi) rather than family-level

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Added ~400 lines of omega-chain infrastructure

## Sorries Added

In `UltrafilterChain.lean`:
- `Z_chain_forward_G`: 2 sorries (crossing cases)
- `Z_chain_backward_H`: 1 sorry
- `Z_chain_forward_F`: 1 sorry
- `Z_chain_backward_P`: 1 sorry

The deprecated `boxClassFamilies_temporally_coherent` and `construct_bfmcs` were already marked as sorry-blocked; these are now documented as using sorry with reference to the new omega construction.

## Verification

```bash
lake build  # Succeeds with warnings about sorries
```

The 3 target sorries in `FrameConditions/Completeness.lean` remain uneliminated pending completion of the omega-chain temporal coherence proofs.

## Next Steps

1. Prove extended witness theorem preserving both G and H theories
2. Use extended witness in chain construction
3. Complete `Z_chain_forward_G`, `Z_chain_backward_H`, `Z_chain_forward_F`, `Z_chain_backward_P`
4. Wire `OmegaFMCS` to completeness theorems via `construct_bfmcs_omega`
5. Eliminate the 3 target sorries
