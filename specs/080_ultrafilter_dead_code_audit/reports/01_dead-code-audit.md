# UltrafilterChain.lean Dead Code Audit

**Task**: 80 - ultrafilter_dead_code_audit
**File**: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
**Total Lines**: 8,376
**Session**: sess_1774988830_d365d0

## Executive Summary

UltrafilterChain.lean contains **25 sorries** across multiple abandoned approaches. Based on analysis of ROADMAP.md documentation and inline comments, approximately **2,100-2,400 lines** (25-29%) are dead code belonging to approaches with mathematically FALSE dependencies.

**Key Finding**: Four distinct approaches have been abandoned:
1. **Old SuccChain** (`f_nesting_is_bounded` = FALSE)
2. **Bidirectional Seed** (`H(a) -> G(H(a))` = NOT derivable)
3. **Z_chain cross-chain propagation** (structural gap)
4. **CoherentZChain** (same structural gaps)

## Sorry Inventory

| Line | Approach | Status | Rationale |
|------|----------|--------|-----------|
| 3377 | f_preserving_seed | DEAD | sub-case A unprovable (ARCHIVED) |
| 3383 | f_preserving_seed | DEAD | sub-case B unprovable (ARCHIVED) |
| 3887 | bidirectional_seed | DEAD | H(a) -> G(H(a)) NOT derivable (BLOCKED) |
| 4301 | bidirectional_seed | DEAD | H_theory not G-liftable (BLOCKED) |
| 4721 | boxClassFamilies_temporally_coherent | DEAD | deprecated, FALSE dependency |
| 4767 | construct_bfmcs | DEAD | deprecated, FALSE dependency |
| 5251 | Z_chain_forward_G | DEAD | cross-chain gap (forward/backward) |
| 5273 | Z_chain_forward_G | DEAD | cross-chain gap (backward only) |
| 5287 | Z_chain_backward_H | DEAD | symmetric gap |
| 5352 | Z_chain_forward_F | DEAD | gap between Z_chain and F-preserving |
| 5369 | Z_chain_backward_P | DEAD | gap between Z_chain and P-preserving |
| 6487 | omega_forward_F_persistence_or_resolution | DEAD | G(neg phi) can enter chain |
| 6510 | omega_forward_F_bounded_persistence | DEAD | needs dovetailed construction |
| 6551 | Z_chain_forward_F' | DEAD | backward chain crossing |
| 7082 | omega_F_preserving_forward_chain | ACTIVE? | Phase 6A refinement (unclear) |
| 7426 | p_preserving_seed_consistent | DEAD | P-preserving sub-case stuck |
| 7448 | p_preserving_seed_consistent | DEAD | P-preserving sub-case stuck |
| 8047 | CoherentZChain forward_G | DEAD | t < 0 to t' >= 0 crossing |
| 8050 | CoherentZChain forward_G | DEAD | both t < 0 and t' < 0 |
| 8062 | CoherentZChain backward_H | DEAD | t >= 0 case |
| 8064 | CoherentZChain backward_H | DEAD | crossing case |
| 8123 | CoherentZChain_forward_F | DEAD | t < 0 case |
| 8139 | CoherentZChain_backward_P | DEAD | t >= 0 case |
| 8374 | omega_true_dovetailed_forward_F_resolution | DEAD | F(phi) vanishes case (ARCHIVED) |

**Total**: 24 sorries identified (1 unclear status)

## Dead Code Regions

### Region 1: F-Preserving Seed Construction (Lines ~2500-3450)

**Status**: DEAD CODE
**Reason**: `f_preserving_seed_consistent` is mathematically FALSE (Task #69 counterexample)

**Key elements**:
- `f_preserving_seed` definition (~2520)
- `f_preserving_seed_consistent` theorem (~3110-3412)
- `temporal_theory_witness_F_preserving` (~3427-3449)

**Sorries**: 3377, 3383
**Estimated lines**: ~950 lines

### Region 2: Bidirectional Temporal Box Seed (Lines ~3700-4310)

**Status**: DEAD CODE
**Reason**: `H(a) -> G(H(a))` is NOT derivable in TM logic

**Key elements**:
- `bidirectional_temporal_box_seed` definition (~3700)
- `G_of_bidirectional_seed` theorem (~3800-3890)
- `bidirectional_seed_consistent` theorem (~3904-4309)

**Sorries**: 3887, 4301
**Estimated lines**: ~610 lines

### Region 3: Old SuccChain with FALSE Dependencies (Lines ~4680-4770)

**Status**: DEAD CODE (deprecated)
**Reason**: Depends on `f_nesting_is_bounded` which is FALSE

**Key elements**:
- `boxClassFamilies_temporally_coherent` (deprecated, line 4714)
- `construct_bfmcs` (deprecated, line 4759)

**Sorries**: 4721, 4767
**Estimated lines**: ~90 lines

### Region 4: Z_chain Construction (Lines ~5050-5420)

**Status**: DEAD CODE
**Reason**: Structural gap - forward/backward chains don't properly propagate G/H

**Key elements**:
- `Z_chain` definition (~5050)
- `Z_chain_forward_G` (~5180-5280)
- `Z_chain_backward_H` (~5283-5290)
- `Z_chain_forward_F` (~5330-5355)
- `Z_chain_backward_P` (~5360-5370)
- `OmegaFMCS` (~5295-5300)

**Sorries**: 5251, 5273, 5287, 5352, 5369
**Estimated lines**: ~370 lines

### Region 5: Omega Chain (non-F-preserving) (Lines ~6400-6600)

**Status**: DEAD CODE
**Reason**: Basic omega chain doesn't guarantee F-resolution; needs dovetailed construction

**Key elements**:
- `omega_forward_F_persistence_or_resolution` (~6410-6490)
- `omega_forward_F_bounded_persistence` (~6500-6515)
- `Z_chain_forward_F'` (~6518-6555)

**Sorries**: 6487, 6510, 6551
**Estimated lines**: ~200 lines

### Region 6: P-Preserving Seed Construction (Lines ~7140-7500)

**Status**: DEAD CODE
**Reason**: Symmetric to F-preserving; same structural gaps

**Key elements**:
- `P_unresolved_theory` definition (~7145)
- `p_preserving_seed_consistent` theorem (~7350-7500)

**Sorries**: 7426, 7448
**Estimated lines**: ~360 lines

### Region 7: CoherentZChain (Lines ~7920-8170)

**Status**: DEAD CODE
**Reason**: Same cross-direction propagation gaps as Z_chain; marked ARCHIVED

**Key elements**:
- `CoherentZChain` definition (~7960)
- `CoherentZChain_to_FMCS` (~8010-8090)
- `CoherentZChain_forward_F` (~8099-8125)
- `CoherentZChain_backward_P` (~8132-8165)

**Sorries**: 8047, 8050, 8062, 8064, 8123, 8139
**Estimated lines**: ~250 lines

### Region 8: True Dovetailed Forward Chain (Lines ~8330-8376)

**Status**: DEAD CODE
**Reason**: Marked ARCHIVED; "F(phi) vanishes" case unfixable via this approach

**Key elements**:
- `omega_true_dovetailed_forward_F_resolution` (~8337-8375)

**Sorries**: 8374
**Estimated lines**: ~45 lines

## Potentially Active Code (Requires Verification)

### F-Preserving Forward Chain (Lines ~6850-7120)

**Status**: UNCLEAR - possibly ACTIVE
**Issue**: One sorry at line 7082 for "Phase 6A refinement"

This section appears to be part of the newer approach and may still be in development. The surrounding infrastructure (`FPreservingForwardChain`, `omega_F_preserving_forward_F_resolution`) seems sorry-free based on ROADMAP.md claims.

**Recommendation**: Verify if line 7082 sorry is blocking or can be closed.

## Summary Table

| Region | Lines | Status | Sorries | Estimated Removable |
|--------|-------|--------|---------|---------------------|
| F-preserving seed | ~2500-3450 | DEAD | 2 | 950 |
| Bidirectional seed | ~3700-4310 | DEAD | 2 | 610 |
| Old SuccChain (deprecated) | ~4680-4770 | DEAD | 2 | 90 |
| Z_chain | ~5050-5420 | DEAD | 5 | 370 |
| Omega chain (basic) | ~6400-6600 | DEAD | 3 | 200 |
| P-preserving seed | ~7140-7500 | DEAD | 2 | 360 |
| CoherentZChain | ~7920-8170 | DEAD | 6 | 250 |
| True dovetailed | ~8330-8376 | DEAD | 1 | 45 |
| **TOTAL** | | | **23** | **~2,875** |

## Recommendations

### 1. Immediate Cleanup (High Confidence)

These regions have explicit `ARCHIVED`, `BLOCKED`, `DEAD CODE`, or `deprecated` markers:

- Remove `f_preserving_seed` construction (3377, 3383)
- Remove `bidirectional_temporal_box_seed` construction (3887, 4301)
- Remove deprecated `boxClassFamilies_temporally_coherent` and `construct_bfmcs` (4721, 4767)
- Remove `CoherentZChain` (8047, 8050, 8062, 8064, 8123, 8139)
- Remove `omega_true_dovetailed_forward_F_resolution` (8374)

**Sorries eliminated**: 13
**Lines removed**: ~2,000

### 2. Secondary Cleanup (Medium Confidence)

These regions lack explicit markers but are clearly superseded:

- Remove basic `Z_chain` construction (5251, 5273, 5287, 5352, 5369)
- Remove basic omega chain F-resolution theorems (6487, 6510, 6551)
- Remove `P_unresolved_theory` and `p_preserving_seed_consistent` (7426, 7448)

**Sorries eliminated**: 10
**Additional lines removed**: ~930

### 3. Investigate Before Removal

- Line 7082: Verify if this blocks current approach or is orphaned

## Cross-Reference with ROADMAP.md

The ROADMAP.md "Temporal Coherence Resolution (March 2026)" section confirms:

1. **CoherentZChain** (lines 7920-8170): "Fundamentally broken" - matches our finding
2. **f_preserving_seed** sub-case A: "Mathematically unprovable" - matches our finding
3. **omega_true_dovetailed**: "Unfixable sorry" - matches our finding
4. **Bidirectional Temporal Witness**: "BLOCKED" - matches our finding

## Working Approach (NOT Dead Code)

Per ROADMAP.md, the **separate-direction witnesses** approach in `SuccChainFMCS.lean` is the current working path:
- Forward witnesses use `temporal_box_seed` (G-liftable, proven consistent)
- Backward witnesses use `past_temporal_box_seed` (H-liftable, proven consistent)
- Cross-direction coherence at chain level via Succ relation properties

This code is in a **different file** (`SuccChainFMCS.lean`) and should NOT be removed from `UltrafilterChain.lean` since it's not there.

## Conclusion

**Conservative estimate**: ~2,100 lines removable (25% of file)
**Aggressive estimate**: ~2,875 lines removable (34% of file)
**Sorries eliminated**: 23-24 of 25 (92-96%)

After cleanup, `UltrafilterChain.lean` would contain:
- Core ultrafilter relation definitions (R_G, R_Box)
- Basic properties (reflexivity, transitivity, Euclidean)
- Box class family construction (modal saturation)
- Possibly the F-preserving forward chain infrastructure

The remaining sorry (line 7082) should be investigated to determine if it's part of active development or can also be removed.
