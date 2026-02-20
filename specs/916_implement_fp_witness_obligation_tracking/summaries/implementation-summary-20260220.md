# Implementation Summary: Task #916

**Date**: 2026-02-20
**Session**: sess_1771618766_cea3b9
**Status**: Partial (Phases 1-2 of 4 complete)

## Overview

This implementation addresses 4 sorries in `DovetailingChain.lean`. Phases 1-2 were completed using an elegant GContent/HContent duality approach, eliminating the cross-sign propagation sorries. The F/P witness scheduling (Phase 3) remains for future work.

## What Was Accomplished

### Sorries Closed (2 of 4)

1. **forward_G when t < 0** (was line 606) - CLOSED
   - Cross-sign propagation: G phi in M_t (t < 0) implies phi in M_{t'} (t' > t)
   - Solution: Bridge through M_0 using duality lemmas

2. **backward_H when t >= 0** (was line 617) - CLOSED
   - Cross-sign propagation: H phi in M_t (t >= 0) implies phi in M_{t'} (t' < t)
   - Solution: Symmetric bridge through M_0

### Sorries Remaining (2 of 4)

3. **forward_F** (line 919) - OPEN
   - F-witness existence: F(psi) in M_t requires some s > t with psi in M_s
   - Requires: Cantor-pairing witness scheduling (Phase 3)

4. **backward_P** (line 926) - OPEN
   - P-witness existence: P(psi) in M_t requires some s < t with psi in M_s
   - Requires: Symmetric witness scheduling (Phase 3)

## Implementation Approach

Instead of building a unified chain (original plan), we discovered a more elegant approach using GContent/HContent duality:

**Key Insight**: If `GContent(M) ⊆ M'` (holds by construction from Lindenbaum extension), then `HContent(M') ⊆ M` (provable via axiom temp_a: φ → G(P(φ))).

This duality means:
- The backward chain has implicit G-content propagation toward M_0
- The forward chain has implicit H-content propagation toward M_0
- Cross-sign propagation works by bridging through the shared M_0

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
  - Added import: `Bimodal.Theorems.Combinators`
  - Added ~300 lines of duality lemmas and cross-sign proofs
  - Updated `buildDovetailingChainFamily` to use new lemmas

## New Lemmas Added

| Lemma | Purpose |
|-------|---------|
| `past_temp_a` | Derived φ → H(F(φ)) from temp_a |
| `GContent_subset_implies_HContent_reverse` | Core duality: GContent ⊆ implies HContent ⊆ reverse |
| `HContent_subset_implies_GContent_reverse` | Symmetric duality |
| `dovetailBackwardChainMCS_GContent_reverse` | G propagates toward 0 in backward chain |
| `dovetailForwardChainMCS_HContent_reverse` | H propagates toward 0 in forward chain |
| `dovetailBackwardChain_G_propagates_reverse` | G propagates one step toward 0 |
| `dovetailBackwardChain_G_propagates_reverse_le` | G propagates to any smaller index |
| `dovetailBackwardChain_forward_G` | forward_G in backward chain |
| `dovetailForwardChain_H_propagates_reverse` | H propagates one step toward 0 |
| `dovetailForwardChain_H_propagates_reverse_le` | H propagates to any smaller index |
| `dovetailForwardChain_backward_H` | backward_H in forward chain |
| `dovetailChainSet_forward_G_neg` | Cross-sign forward_G (negative t) |
| `dovetailChainSet_backward_H_nonneg` | Cross-sign backward_H (non-negative t) |

## Verification

- `lake build Bimodal.Metalogic.Bundle.DovetailingChain` - SUCCESS
- Sorry count in DovetailingChain.lean: 4 → 2 (50% reduction)
- `forward_G` and `backward_H` in `buildDovetailingChainFamily` - fully proven

## Next Steps (Phase 3)

To close the remaining 2 sorries (forward_F, backward_P), implement F/P witness scheduling:

1. Import `Mathlib.Data.Nat.Pairing` for Cantor pairing
2. Define obligation enumeration via `Nat.unpair`
3. Augment chain seeds with witness formulas
4. Prove witness existence by surjectivity of enumeration
5. Use `temporal_witness_seed_consistent` and `past_temporal_witness_seed_consistent` for consistency

## Phase Log

| Phase | Status | Description |
|-------|--------|-------------|
| 1-2 | COMPLETED | GContent/HContent duality (cross-sign propagation) |
| 3 | NOT STARTED | F/P witness scheduling |
| 4 | NOT STARTED | Final integration and cleanup |
