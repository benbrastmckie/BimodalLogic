# Implementation Summary: Task #67 - Dovetailed OmegaFMCS Construction

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: PARTIAL
- **Session**: sess_1774805922_00b565
- **Date**: 2026-03-29

## Summary

Partial implementation of the dovetailed OmegaFMCS construction for family-level temporal coherence. Added infrastructure for resolving F-obligations but did not complete the full dovetailed chain construction.

## Work Completed

### Phase 1: Infrastructure for Resolving Chain (PARTIAL)

Added to `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`:

1. **Import Added**: `Mathlib.Data.Nat.Pairing` for `Nat.unpair` fairness enumeration

2. **New Definitions**:
   - `resolving_witness`: Wrapper around `omega_step_forward` for resolving specific F-obligations
   - `F_witness_exists`: Restatement of `temporal_theory_witness_exists` for clarity
   - `can_resolve_F_obligation`: Core theorem showing witness construction for F-resolution

3. **New Theorems**:
   - `resolving_witness_excludes_G_neg`: Proves G(neg phi) is excluded from resolving witness
   - `F_resolution_witness_in_box_class`: Shows F-resolution witness exists in box class
   - `omega_forward_F_persistence_or_resolution`: Partial - F(phi) either resolves or persists

4. **Documentation**: Added detailed comments explaining:
   - The gap in the current construction (Lindenbaum extension may add G(neg phi))
   - How the dovetailed approach fixes this by explicit phi inclusion in seed
   - The relationship between bundle-level and family-level coherence

### Key Insight Documented

The fundamental gap is that the current `omega_chain_forward` always resolves `F_top`, not arbitrary F-obligations. The Lindenbaum extension in the witness construction may add `G(neg phi)`, which prevents `F(phi)` from persisting and `phi` from being forced into the witness.

The dovetailed construction fixes this by:
1. Using `Nat.unpair` to enumerate all (time, formula) pairs
2. At each step, explicitly resolving the corresponding F-obligation
3. This ensures every F-obligation is eventually resolved within the same family

## Remaining Work

### Phase 2-6 (NOT STARTED)

- Phase 2: Prove dovetailed chain properties (MCS, box-class, succ)
- Phase 3: Prove fairness via `Nat.unpair` surjectivity
- Phase 4: Symmetric backward chain for P-obligations
- Phase 5: Wire to Z_chain and close sorries
- Phase 6: Connect to BFMCS and close `bfmcs_from_mcs_temporally_coherent`

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`: Added ~150 lines of infrastructure
- `specs/067_prove_bundle_validity_implies_provability/plans/08_dovetailed-omega-fmcs.md`: Updated Phase 1 status

## Sorry Count

### Before
- UltrafilterChain.lean: ~10 sorries
- Completeness.lean: 2 sorries

### After
- UltrafilterChain.lean: 10 sorries (same, added infrastructure doesn't close sorries)
- Completeness.lean: 2 sorries (unchanged)

## Build Status

`lake build` succeeds with no errors. Warnings for sorries are expected.

## Technical Notes

The core sorries that need closing:
1. `Z_chain_forward_F` (line 2425): F(phi) at t implies exists s > t with phi at s
2. `Z_chain_backward_P` (line 2491): Symmetric for P
3. `Z_chain_forward_G` crossing (line 2347): G-theory crossing backward-to-forward
4. `Z_chain_backward_H` (line 2383): H-theory propagation
5. `omega_forward_F_persistence_or_resolution` (line 3174): Partial, has sorry in G(neg phi) branch
6. `omega_forward_F_bounded_persistence` (line 3297): Requires dovetailed construction
7. `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:220): Depends on above

## Next Steps

To complete this task:

1. Implement `dovetailed_chain_forward_with_inv` that uses `Nat.unpair` to select which F-obligation to resolve at each step
2. Prove `dovetailed_chain_forward_F`: the dovetailed chain resolves all F-obligations
3. Define `OmegaDovetailedFMCS` using the dovetailed chain
4. Prove `omegaClassFamilies_temporally_coherent` using the dovetailed construction
5. Replace references to deprecated `boxClassFamilies_temporally_coherent`
6. Close `bfmcs_from_mcs_temporally_coherent` sorry

## Blockers

None - the approach is sound but requires significant implementation effort (~8-10 hours remaining).
