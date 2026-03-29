# Implementation Progress: Task #67 - Dovetailed OmegaFMCS Construction

**Task**: 67 - prove_bundle_validity_implies_provability
**Plan**: 08_dovetailed-omega-fmcs.md
**Status**: PARTIAL
**Session**: sess_1774806830_5e4b96

## Summary

This session added significant infrastructure for the dovetailed F-resolution approach but did not close the primary sorry in `bfmcs_from_mcs_temporally_coherent`. The key blocker is that the existing `boxClassFamilies` construction uses `SuccChainFMCS` which internally relies on `omega_chain_forward` - a chain that only resolves F_top at each step, not arbitrary F-obligations.

## Progress Made

### Phase 1: Infrastructure Added [PARTIAL]

**New infrastructure in UltrafilterChain.lean** (~200 lines):

1. **Resolving witness lemmas**:
   - `resolving_witness_contains_phi`: Proves phi is in the resolving witness
   - `resolving_witness_G_theory`: G-theory preservation
   - `resolving_witness_box_agree`: Box-class agreement
   - `resolving_witness_invariant`: OmegaForwardInvariant preservation

2. **Resolving chain construction**:
   - `omega_chain_resolving_at_1`: Chain that resolves specific F(phi) at step 1
   - `omega_chain_resolving_at_1_val`: Accessor
   - `omega_chain_resolving_at_1_contains_phi`: Key theorem - phi IN chain(1)
   - `omega_chain_resolving_at_1_mcs`: MCS at every point
   - `omega_chain_resolving_at_1_box_class`: Box-class agreement

3. **Dovetailed chain skeleton**:
   - `omega_chain_dovetailed_forward_with_inv`: Placeholder for full dovetailing
   - Helper definitions for F-obligation selection

### Key Insight Confirmed

The session confirmed the fundamental gap identified in team research (report 22):

- The current `omega_chain_forward` uses `F_top` at each step
- This means an arbitrary `F(phi)` might NOT be resolved
- The witness for F_top might contain `G(neg phi)`, blocking `phi` from appearing
- The seed for Lindenbaum extension is `{neg bot} ∪ G_theory ∪ box_theory`, not the full MCS
- `G(neg phi)` can enter through Lindenbaum extension if consistent with seed

**Concrete example**: If `Box(neg phi) ∈ M`, then `Box(neg phi)` is in the seed. By T-axiom, `neg phi` follows, so `{seed} ∪ {phi}` is INCONSISTENT. The witness cannot contain `phi` even though `F(phi) ∈ M`.

### Build Status

- `lake build` succeeds
- All new definitions compile without error
- Existing sorries remain in:
  - `Z_chain_forward_F` (line 2486)
  - `Z_chain_backward_P` (line 2495)
  - `omega_forward_F_persistence_or_resolution` crossing case (line 3593)
  - `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:226)

## Remaining Work

### To Close the Sorry

The fundamental fix requires ONE of:

1. **Replace `omega_chain_forward` entirely**: Build a chain where at each step, we explicitly select and resolve a specific F-obligation using `Nat.unpair` enumeration and `resolving_witness`. This guarantees every F(phi) is eventually resolved.

2. **Modify `boxClassFamilies`**: Instead of using `SuccChainFMCS` (which uses `omega_chain_forward`), use a new `DovetailedFMCS` construction that guarantees family-level coherence.

3. **Prove F-persistence differently**: Show that if `F(phi) ∈ chain(t)` and `G(neg phi) ∉ chain(t)`, then `G(neg phi) ∉ chain(t+1)`. This would require analyzing the Lindenbaum extension more carefully.

### Effort Estimate

- Full dovetailed chain implementation: 4-6 hours
- Integration with boxClassFamilies: 2-3 hours
- Closing Z_chain_forward_F: 1-2 hours (if dovetailed chain is done)
- Closing bfmcs_from_mcs_temporally_coherent: 1 hour (wiring)
- Total remaining: 8-12 hours

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`: +200 lines of infrastructure

## Artifacts

- `plans/08_dovetailed-omega-fmcs.md`: Implementation plan (Phase 1 PARTIAL)
- `summaries/09_dovetailed-omega-progress.md`: This file

## Next Steps

1. Implement full dovetailed chain using `Nat.unpair` enumeration
2. Define `DovetailedFMCS` as FMCS using the dovetailed chain
3. Prove `DovetailedFMCS` has family-level forward_F
4. Replace `SuccChainFMCS` in `boxClassFamilies` with `DovetailedFMCS`
5. Wire through to close `bfmcs_from_mcs_temporally_coherent`
