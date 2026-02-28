# Handoff: Phase 5B - Forward_F via Witness Graph Bridge

## Immediate Next Action

Design and implement a BFMCS construction that satisfies BOTH forward_G and forward_F. The two viable approaches are:

1. **Omega-squared construction**: Build an inner chain at each outer step that processes ALL F-formulas
2. **Witness-graph-guided chain**: Linearize the witness graph DAG and fill gaps with GContent extensions

Start by choosing an approach and defining the new chain construction.

## Current State

- **File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`
- **Lines**: ~3380 (after Phase 3B + 5A additions)
- **Build**: Clean (0 errors, 2 sorry warnings at lines 3025 and 3033)
- **Sorries remaining**: 2 (`enrichedForwardChain_forward_F` line 3025, `enrichedBackwardChain_backward_P` line 3033)

### What's Proven

1. **Phase 3B**: All build errors fixed. `set_mcs_neg_or` -> `set_mcs_negation_complete`. Added `GContent_subset_implies_HContent_reverse`, `HContent_subset_implies_GContent_reverse`, `past_temp_a'`.

2. **Phase 5A**: `enrichedChainBFMCS.forward_G` and `backward_H` fully proven via 11 new helper lemmas (cross-sign G/H propagation infrastructure). The enriched chain at Int level handles all 4 cases (both non-negative, both negative, cross-sign).

3. **Witness Graph Phase 1-3**: Complete infrastructure for building witness graphs with local F/P witness existence (`witnessGraph_forward_F_local`, `witnessGraph_backward_P_local`). GContent and HContent propagate along edges.

### What's NOT Proven and Why

`enrichedForwardChain_forward_F` and `enrichedBackwardChain_backward_P` remain sorry because:

- **F-persistence failure**: F(psi) in chain(0) does NOT imply F(psi) in chain(n). The enriched chain processes formula psi at a specific step n (determined by Nat.unpair). At that step, F(psi) might have been replaced by G(neg psi) via the non-constructive Lindenbaum extension.

- **Root cause**: F(phi) -> G(F(phi)) is NOT provable in TM logic. So F-formulas do not self-persist through GContent seeds. G-formulas DO self-persist (4-axiom: G(phi) -> G(G(phi))).

## Key Decisions Made

1. **Duplicated `GContent_subset_implies_HContent_reverse` and `HContent_subset_implies_GContent_reverse`** in WitnessGraph.lean to avoid circular import (DovetailingChain.lean will later import WitnessGraph.lean in Phase 6).

2. **Used case-split approach** for cross-sign coherence: separate lemmas for non-negative, negative, and cross-sign cases, following the same pattern as DovetailingChain.lean.

3. **Confirmed the enriched chain CANNOT prove forward_F** -- this is a mathematical impossibility, not an implementation gap.

## What NOT to Try

1. **Direct enriched chain forward_F proof**: Mathematically impossible. F-formulas don't persist through GContent seeds.

2. **Constant BFMCS (`witnessGraphBFMCS`)**: Trivially satisfies forward_G/backward_H but CANNOT satisfy forward_F because F(psi) in rootMCS does not imply psi in rootMCS.

3. **Direct witness graph node-as-Int embedding**: Fails forward_G because GContent doesn't propagate between non-adjacent nodes in the DAG.

## Critical Context

1. The BFMCS structure only needs `mcs`, `is_mcs`, `forward_G`, `backward_H` fields. Forward_F and backward_P are proven SEPARATELY as standalone lemmas.

2. The witness graph's `witnessGraph_forward_F_local` proves: for F(psi) at node i, exists witness node j > i with psi in j and GContent(node_i) subset of node_j.

3. The 4-axiom (`G(phi) -> G(G(phi))`) is the key to G-persistence. The T-axiom (`G(phi) -> phi`) converts G-membership to direct membership.

4. `enrichedChainBFMCS` already has forward_G and backward_H proven. Any new construction should either extend it or replace it entirely.

5. The `enriched_forward_seed_consistent` and `forward_temporal_witness_seed_consistent` lemmas prove that `{psi} union GContent(M)` is consistent when `F(psi) in M`.

## References

- **Plan**: `specs/916_implement_fp_witness_obligation_tracking/plans/implementation-011.md`
- **WitnessGraph.lean**: `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`
- **DovetailingChain.lean**: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (has same sorry)
- **Research-003**: Team consensus on approach (see `specs/916_implement_fp_witness_obligation_tracking/reports/`)
- **Research-010**: Deferred concretization approach
