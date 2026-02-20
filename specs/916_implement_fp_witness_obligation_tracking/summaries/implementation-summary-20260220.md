# Implementation Summary: Task #916

**Date**: 2026-02-20
**Sessions**: sess_1771618766_cea3b9 (iteration 1), sess_1771626129_c718ce (iteration 2)
**Status**: Partial (Phases 1-2 complete, Phase 3 blocked)

## Overview

This implementation addresses 4 sorries in `DovetailingChain.lean`. Phases 1-2 were completed using an elegant GContent/HContent duality approach, eliminating the cross-sign propagation sorries (2 of 4). Phase 3 (F/P witness scheduling) is BLOCKED due to a fundamental F-formula persistence problem that requires new proof infrastructure.

## What Was Accomplished

### Sorries Closed (2 of 4)

1. **forward_G when t < 0** (was line 606) - CLOSED
   - Cross-sign propagation: G phi in M_t (t < 0) implies phi in M_{t'} (t' > t)
   - Solution: Bridge through M_0 using duality lemmas

2. **backward_H when t >= 0** (was line 617) - CLOSED
   - Cross-sign propagation: H phi in M_t (t >= 0) implies phi in M_{t'} (t' < t)
   - Solution: Symmetric bridge through M_0

### Sorries Remaining (2 of 4) - BLOCKED

3. **forward_F** (line 919) - BLOCKED
   - F-witness existence: F(psi) in M_t requires some s > t with psi in M_s
   - Root cause: F-formulas do not auto-propagate (F(psi) -> G(F(psi)) is not derivable)
   - Non-deterministic Lindenbaum (via Zorn/Classical.choose) can kill F-obligations

4. **backward_P** (line 926) - BLOCKED
   - P-witness existence: symmetric to forward_F
   - Same root cause: P-formulas do not auto-propagate

## Implementation Approach (Phases 1-2)

Instead of building a unified chain (original plan), we discovered a more elegant approach using GContent/HContent duality:

**Key Insight**: If `GContent(M) ⊆ M'` (holds by construction from Lindenbaum extension), then `HContent(M') ⊆ M` (provable via axiom temp_a: phi -> G(P(phi))).

This duality means:
- The backward chain has implicit G-content propagation toward M_0
- The forward chain has implicit H-content propagation toward M_0
- Cross-sign propagation works by bridging through the shared M_0

## Phase 3 Blocker Analysis (Iteration 2)

### The F-Persistence Problem

The core problem: when building MCS M_{n+1} from seed `{psi_n} union GContent(M_n)`, existing F-obligations from M_n may vanish. Specifically:

- F(psi) in M_n means neg(G(neg psi)) in M_n
- M_{n+1} is an MCS extending the seed via Lindenbaum (non-deterministic)
- Lindenbaum CAN add G(neg psi) to M_{n+1}, causing F(psi) to disappear permanently
- Once G(neg psi) enters, it propagates to all future MCSes via GContent, permanently blocking psi

### Approaches Investigated and Why They Fail

1. **Simple formula enumeration**: Each formula gets one "chance" to be witnessed. If F(psi) vanishes before that step, the obligation is lost.

2. **Multi-witness seed**: Adding ALL {psi | F(psi) in M_n} to seed is inconsistent when F(p) and F(neg p) both in M_n.

3. **F-formula propagation in seed**: Including {F(chi) | F(chi) in M_n} in seed is consistent (subset of M_n). But adding a witness psi_n to FGSeed may be inconsistent when G(psi_n -> G(neg chi)) in M_n.

4. **Contradiction argument**: Assuming psi never appears requires temporal_backward_G, which requires forward_F (circular).

### Key Proven Facts

- `GContent(M) union {F(psi)}` IS consistent when F(psi) in M (trivially: subset of M)
- `{psi} union GContent(M)` IS consistent when F(psi) in M (temporal_witness_seed_consistent)
- `{psi} union GContent(M) union {F(chi)}` may be INCONSISTENT (via conditional G-formulas)
- The Encodable/Cantor-pairing infrastructure IS available (verified: Formula derives Countable, Encodable.ofCountable works, Nat.pair/unpair available)

### Resolution Path

The recommended path forward is a **constructive formula-by-formula Lindenbaum** that processes formulas in a controlled order, ensuring F(chi) is processed before G(neg chi). The key new infrastructure needed:

1. **G-derivability independence metatheorem**: `Gamma union {non-G-formulas} |- G(alpha)` iff `Gamma |- G(alpha)` for G-prefixed Gamma. This can be proven by induction on the derivation tree.

2. **Constructive Lindenbaum**: Instead of Zorn-based set_lindenbaum, a formula-by-formula extension that gives full control over which formulas enter the MCS.

Estimated effort: 15-20 hours of formalization work.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
  - Added import: `Bimodal.Theorems.Combinators`
  - Added ~300 lines of duality lemmas and cross-sign proofs
  - Updated `buildDovetailingChainFamily` to use new lemmas

## New Lemmas Added (Phases 1-2)

| Lemma | Purpose |
|-------|---------|
| `past_temp_a` | Derived phi -> H(F(phi)) from temp_a |
| `GContent_subset_implies_HContent_reverse` | Core duality: GContent subset implies HContent subset reverse |
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
- Sorry count in DovetailingChain.lean: 4 -> 2 (50% reduction)
- `forward_G` and `backward_H` in `buildDovetailingChainFamily` - fully proven

## Phase Log

| Phase | Status | Description |
|-------|--------|-------------|
| 1-2 | COMPLETED | GContent/HContent duality (cross-sign propagation) |
| 3 | BLOCKED | F/P witness scheduling (requires constructive Lindenbaum) |
| 4 | BLOCKED | Final integration (blocked on Phase 3) |
