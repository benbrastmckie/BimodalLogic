# Implementation Summary: Task #916

**Date**: 2026-02-20
**Sessions**: sess_1771618766_cea3b9 (plan v002, phases 1-2), sess_1771626129_c718ce (plan v002, phase 3 blocked), sess_1771634621_f7a06b (plan v003, phases 1-2)
**Status**: Partial (plan v003 Phases 1-2 complete)

## Overview

This implementation addresses 2 remaining sorries in `DovetailingChain.lean` (`forward_F` at line 919, `backward_P` at line 926). Earlier sessions (plan v002) already eliminated 2 cross-sign propagation sorries using GContent/HContent duality. The current session (plan v003) implements the omega^2 witness chain infrastructure needed for the coverage argument.

## Plan v003 Phase 1: Omega^2 Witness Chain Structure (COMPLETED)

### Architecture

Defined a flat omega-indexed witness chain construction instead of the originally planned two-level inner/outer chain with Zorn limits:

- `witnessForwardChainMCS`: At step n+1, processes formula `decodeFormula(n)`. If `F(psi) ∈ chain(n)`, extends `{psi} ∪ GContent(chain(n))` via Lindenbaum; otherwise extends `GContent(chain(n))`.
- `witnessBackwardChainMCS`: Symmetric construction using HContent and PastTemporalWitnessSeed.

### Design Rationale

The flat chain avoids:
1. Mutual recursion between inner and outer chains
2. Zorn-based limit construction for the outer chain
3. Nat.pairEquiv bijection (not needed since flat enumeration suffices)

Coverage is guaranteed by encoding surjectivity: every formula is processed at exactly one step.

### Definitions Added

| Definition | Type | Purpose |
|-----------|------|---------|
| `formulaEncodable` | `Encodable Formula` | Encoding instance for formulas |
| `decodeFormula` | `Nat → Option Formula` | Decode natural to formula |
| `encodeFormula` | `Formula → Nat` | Encode formula to natural |
| `ForwardTemporalWitnessSeed` | `Set Formula → Formula → Set Formula` | `{psi} ∪ GContent(M)` |
| `witnessForwardChainMCS` | `Set Formula → ... → Nat → MCS` | Forward witness chain |
| `witnessBackwardChainMCS` | `Set Formula → ... → Nat → MCS` | Backward witness chain |

### Lemmas Proved

| Lemma | Purpose |
|-------|---------|
| `decodeFormula_encodeFormula` | Encoding surjectivity |
| `forward_temporal_witness_seed_consistent` | `{psi} ∪ GContent(M)` consistent when `F(psi) ∈ M` |
| `witnessForwardChainMCS_is_mcs` | Each step is MCS |
| `witnessBackwardChainMCS_is_mcs` | Each step is MCS |
| `witnessForwardChainMCS_zero_extends` | Base set extension |
| `witnessBackwardChainMCS_zero_extends` | Base set extension |
| `witnessForwardChainMCS_GContent_extends` | GContent monotonicity |
| `witnessBackwardChainMCS_HContent_extends` | HContent monotonicity |
| `witnessForwardChain_witness_placed` | Witness placement (forward) |
| `witnessBackwardChain_witness_placed` | Witness placement (backward) |
| `witnessForwardChain_G_propagates[_le]` | G-formula propagation |
| `witnessForwardChain_forward_G` | forward_G for witness chain |
| `witnessBackwardChain_H_propagates[_le]` | H-formula propagation |
| `witnessBackwardChain_backward_H` | backward_H for witness chain |
| `witnessBackwardChainMCS_GContent_reverse` | Cross-direction GContent duality |
| `witnessForwardChainMCS_HContent_reverse` | Cross-direction HContent duality |

## Plan v003 Phase 2: Inner Chain Properties (COMPLETED)

### Lemmas Proved (18 new, all sorry-free)

| Lemma | Purpose |
|-------|---------|
| `witnessForwardChainMCS_GContent_extends_le` | Multi-step GContent monotonicity (forward) |
| `witnessBackwardChainMCS_HContent_extends_le` | Multi-step HContent monotonicity (backward) |
| `witnessForwardChain_coverage` | Encoding-step coverage (forward) |
| `witnessBackwardChain_coverage` | Encoding-step coverage (backward) |
| `witnessForwardChainMCS_extends_base_GContent` | GContent(chain(0)) ⊆ chain(n) |
| `witnessBackwardChainMCS_extends_base_HContent` | HContent(chain(0)) ⊆ chain(n) |
| `witnessForwardChain_F_dichotomy` | F(psi) ∨ G(neg(psi)) in every MCS |
| `witnessBackwardChain_P_dichotomy` | P(psi) ∨ H(neg(psi)) in every MCS |
| `witnessForwardChain_G_neg_persists` | G(neg(psi)) persistence (forward) |
| `witnessBackwardChain_H_neg_persists` | H(neg(psi)) persistence (backward) |
| `witnessForwardChain_F_persists_if_not_killed` | F(psi) present if G(neg(psi)) absent |
| `witnessBackwardChain_P_persists_if_not_killed` | P(psi) present if H(neg(psi)) absent |
| `witnessForwardChain_F_persists` | F-persistence with initial condition |
| `witnessBackwardChain_P_persists` | P-persistence with initial condition |
| `witnessForwardChain_F_implies_G_neg_absent` | Contrapositive: F alive → G(neg) never entered |
| `witnessBackwardChain_P_implies_H_neg_absent` | Contrapositive: P alive → H(neg) never entered |
| `witnessForwardChain_coverage_of_le` | **KEY**: F(psi) at n, k ≤ n → psi at k+1 |
| `witnessBackwardChain_coverage_of_le` | **KEY**: P(psi) at n, k ≤ n → psi at k+1 |

### Design Insight

The plan originally specified `innerChain_F_persists` as unconditional F-persistence. Analysis proved this is impossible: `F(psi) → G(F(psi))` is NOT derivable in TM logic. Instead, we proved `coverage_of_le` which uses the contrapositive: if F(psi) is still alive at step n, G(neg(psi)) never entered at any earlier step, so F(psi) was alive at the encoding index and the witness fires.

## Plan v002 Phases 1-2: Cross-Sign Propagation (Previously COMPLETED)

### Sorries Closed (2 of original 4)

1. **forward_G when t < 0** - CLOSED via GContent/HContent duality bridge through M_0
2. **backward_H when t >= 0** - CLOSED symmetrically

## Remaining Sorries (2)

3. **forward_F** (line ~1605) - Requires coverage argument (plan v003 Phase 3)
4. **backward_P** (line ~1612) - Symmetric to forward_F (plan v003 Phase 5)

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
  - Added import: `Mathlib.Logic.Encodable.Basic`
  - Added `Classical.propDecidable` local instance
  - Added ~300 lines of witness chain infrastructure (Phase 1 of plan v003)
  - Added ~230 lines of inner chain properties (Phase 2 of plan v003)

## Verification

- `lake build` succeeds with no new errors (1001 jobs)
- No new sorries introduced
- All existing downstream files compile unchanged

## Phase Log

| Phase | Plan | Status | Description |
|-------|------|--------|-------------|
| 1-2 | v002 | COMPLETED | Cross-sign propagation via GContent/HContent duality |
| 3 | v002 | BLOCKED | F-persistence problem (led to plan v003) |
| 1 | v003 | COMPLETED | Omega^2 witness chain structure (22 defs/lemmas) |
| 2 | v003 | COMPLETED | Inner chain properties (18 lemmas, all sorry-free) |
| 3 | v003 | NOT STARTED | Coverage argument (forward_F) |
| 4 | v003 | NOT STARTED | BFMCS integration |
| 5 | v003 | NOT STARTED | Backward_P (symmetric) |
