# Implementation Summary: Task #681 (v2)

**Completed**: 2026-01-28
**Plan Version**: implementation-004.md
**Session**: sess_1769637804_bebe3a

## Overview

This implementation attempt addressed the remaining Phase 4 sorries from implementation-003.md. The plan had 3 phases focused on completing the coherent construction proofs.

## Changes Made

### Phase 1: Seed Consistency Proofs (Partial)

**Status**: Documented as acceptable gap

The sorries at lines 380 and 393 (seed consistency within chain construction) remain. These correspond to the Boneyard gap at line 2507. The issue is that proving `forward_seed S` is consistent requires knowing `G⊥ ∉ S`, which requires inductive proof about the chain construction itself.

**Decision**: Accept these sorries as matching the Boneyard's architectural gap. The `forward_seed_consistent_of_no_G_bot` lemma (line 175) is fully proven when given an MCS and the `G⊥ ∉ S` hypothesis directly.

### Phase 2: G-Persistence Through Chain (Complete)

**Status**: Fully proven

Added two new lemmas:
1. `mcs_forward_chain_is_mcs` (line 459): Proves each element in the forward chain is an MCS.
2. `mcs_forward_chain_G_persistence` (line 471): Proves G-formulas persist through the forward chain, i.e., if `Gφ ∈ mcs(n)` then `Gφ ∈ mcs(m)` for all `m ≥ n`.

The main `mcs_forward_chain_coherent` lemma (line 513) now uses `mcs_forward_chain_G_persistence` instead of a sorry. The proof strategy:
1. Use G-persistence to get `Gφ ∈ mcs(m-1)` from `Gφ ∈ mcs(n)`
2. Then `φ ∈ forward_seed(mcs(m-1))` by definition
3. Finally `φ ∈ mcs(m)` by seed containment

### Phase 3: Pairwise Coherence Cases (Partial)

**Status**: Infrastructure improved, cross-modal cases documented as gaps

Improvements:
- Fixed the `by_cases` structure in `mcs_unified_chain_pairwise_coherent` for clearer case handling
- Case 1 (both forward chain) and Case 2 (contradiction) are complete
- Removed unused simp arguments causing warnings

Remaining gaps (documented with detailed comments):
- **Case 3**: Cross-origin forward_G (t < 0 ≤ t')
- **Case 4**: Both backward chain forward_G (t, t' < 0)
- **backward_H**: Requires parallel infrastructure to forward_G
- **forward_H**: Requires T-axiom + backward propagation
- **backward_G**: Requires T-axiom + forward propagation

## Files Modified

- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
  - Added `mcs_forward_chain_is_mcs` lemma
  - Added `mcs_forward_chain_G_persistence` lemma
  - Fixed `mcs_forward_chain_coherent` proof (removed sorry)
  - Improved case structure in `mcs_unified_chain_pairwise_coherent`
  - Added detailed documentation for remaining gaps

## Verification

- Lake build: Success (977 jobs)
- Sorries reduced: From 8 to 7 (line 480 sorry removed)
- All proofs compile without errors

## Sorry Analysis

| Location | Description | Status |
|----------|-------------|--------|
| Line 380 | forward_seed consistency in chain | Boneyard gap match |
| Line 393 | backward_seed consistency in chain | Boneyard gap match |
| Line 576 | Cross-origin forward_G | Needs cross-chain propagation |
| Line 584 | Backward chain forward_G | Needs backward_chain_coherent |
| Line 595 | backward_H | Needs backward_H infrastructure |
| Line 612 | forward_H | Needs T-axiom + backward propagation |
| Line 623 | backward_G | Needs T-axiom + forward propagation |

## Architectural Notes

The remaining 5 coherence sorries (excluding seed consistency) all require variations of the same pattern:
1. Use T-axiom to extract φ from Gφ or Hφ at one time point
2. Propagate φ through the chain to another time point

The challenge is that propagation direction doesn't always match construction direction:
- Forward chain builds from 0 → +∞, naturally preserving G-coherence
- Backward chain builds from 0 → -∞, naturally preserving H-coherence
- Cross-modal coherence (G through backward chain, H through forward chain) requires additional lemmas

## Recommendations

1. **For Task 658**: The coherent construction provides the core infrastructure. Task 658 can use `CoherentIndexedFamily.toIndexedMCSFamily` to bridge to `IndexedMCSFamily`, accepting the remaining sorries as documented gaps.

2. **Future Work**: Complete the backward chain coherence infrastructure (`mcs_backward_chain_coherent`, `mcs_backward_chain_H_persistence`) to enable cross-modal cases.

3. **Mathematical Completeness**: The remaining gaps are genuine proof obligations, not architectural flaws. The Boneyard has equivalent gaps, suggesting this is a standard challenge in canonical model constructions.
