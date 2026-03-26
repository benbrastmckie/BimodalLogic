# Implementation Summary: Task #58 - Restricted Completeness

**Task**: 58 - wire_completeness_to_frame_conditions
**Status**: BLOCKED
**Session**: sess_1774555424_0fb43c
**Date**: 2026-03-26

## Overview

Phase 2 (Restricted Bidirectional Truth Lemma) is structurally complete but blocked by sorries in Phase 1 (Restricted Family-Level Temporal Coherence).

## Completed Work

### RestrictedTruthLemma.lean Refactoring

The file was refactored to eliminate FMCS structure dependency:

1. **Removed FMCS Construction**: Replaced `restricted_chain_to_fmcs` (which had unprovable `forward_G`/`backward_H` fields) with simpler `restricted_chain_ext` that directly provides Lindenbaum extensions.

2. **Key Theorems Proven** (structurally complete, blocked by Phase 1 sorries):
   - `restricted_chain_ext`: Lindenbaum extension of DRM at position n
   - `restricted_chain_ext_is_mcs`: Extension is maximal consistent
   - `restricted_chain_subset_extended`: DRM membership implies extension membership
   - `extended_chain_closure_subset`: For closure formulas, extension membership implies DRM membership
   - `restricted_truth_lemma`: Bidirectional equivalence for subformula closure
   - `restricted_truth_at_seed`: Corollary for target formula at position 0

3. **Eliminated Unnecessary Sorries**: Removed 4 sorries that were in unused helper theorems (FMCS forward_G/backward_H and forward_F/backward_P coherence).

### Sorry Reduction

| File | Before | After | Notes |
|------|--------|-------|-------|
| RestrictedTruthLemma.lean | 7 | 3 | Removed FMCS structure, kept 3 unused helper lemmas |

Remaining sorries in RestrictedTruthLemma.lean (lines 106, 115, 135) are in helper lemmas that are NOT used anywhere.

## Blocking Issues

### Phase 1 Sorries in SuccChainFMCS.lean

The `build_restricted_tc_family` function (lines 3878-3938) has 2 critical sorries:

| Line | Case | Description |
|------|------|-------------|
| 3892 | forward_F for Int.negSucc k | F(psi) in backward chain, need forward witness |
| 3917 | backward_P for Int.ofNat (k+1) | P(psi) in forward chain, need backward witness |

These represent **cross-chain witness propagation**: when an F or P obligation is in one chain direction but the witness is in the other direction.

### Mathematical Challenge

The core issue is that the restricted chain has two directions:
- Forward chain (non-negative indices): uses `restricted_forward_chain`
- Backward chain (negative indices): uses `restricted_backward_chain`

They meet at position 0 where `forward_chain(0) = backward_chain(0) = M0`.

For F-formulas in the backward chain (line 3892):
1. F(psi) at position -(k+1) must find witness at some position > -(k+1)
2. By Succ relation's f_step, F propagates toward 0
3. If F(psi) reaches position 0, need to use `restricted_forward_chain_forward_F`
4. This requires proving F-propagation through backward chain toward 0

Similar logic applies to P-formulas in forward chain (line 3917).

### Required Lemmas

To complete Phase 1, need to prove:

1. `restricted_backward_chain_F_propagates_to_zero`:
   If F(psi) in backward_chain(k+1), then either psi is in some backward_chain(j) for j < k+1, or F(psi) reaches backward_chain(0).

2. `restricted_forward_chain_P_propagates_to_zero`:
   Symmetric for P in forward chain.

## Impact on Downstream Phases

- **Phase 3 (Lifting)**: Cannot proceed until Phase 1 and 2 complete
- **Phase 4 (Wire to FrameConditions)**: Cannot proceed until Phase 3 complete

## Verification Status

```bash
lake build  # Succeeds with warnings
```

All theorems in RestrictedTruthLemma.lean depend on `sorryAx` due to Phase 1 sorries in `RestrictedTemporallyCoherentFamily`.

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` | Refactored to remove FMCS dependency |
| `specs/058_wire_completeness_to_frame_conditions/plans/10_restricted-completeness.md` | Updated phase statuses |

## Recommendations

1. **Complete Phase 1 First**: Fill the 2 sorries in `build_restricted_tc_family` before continuing with Phase 2 verification.

2. **Cross-Chain Lemmas**: Develop helper lemmas for F/P propagation across chain directions at position 0.

3. **Alternative Approach**: Consider whether the restricted completeness approach is the right path, or if a different construction (like the OmegaFMCS pattern) would be more tractable.

## Axioms Used

Standard mathematical axioms only (when Phase 1 sorries are filled):
- `propext` (propositional extensionality)
- `Classical.choice` (classical logic)
- `Quot.sound` (quotient soundness)
