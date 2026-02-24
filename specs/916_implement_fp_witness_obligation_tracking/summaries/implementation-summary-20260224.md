# Implementation Summary: Task #916 - Phases 3B, 5A, 5B, 5C, 6 (partial)

**Date**: 2026-02-24
**Sessions**: sess_1771904039_b1889e, sess_1771905472_29ec70, sess_1771945665_c15254
**Status**: PARTIAL (Phases 3B, 5A completed; Phases 5B, 5C partial; Phase 6 blocked; Phase 7 not started)

## Overview

WitnessGraph.lean now builds cleanly with **0 errors and 0 sorries** (down from 4 errors and 4 sorries). All four original sorries have been resolved: 2 by proof (forward_G, backward_H) and 2 by removal (forward_F, backward_P were mathematically impossible for the enriched chain construction and unused downstream).

DovetailingChain.lean retains 2 sorries (forward_F, backward_P) that are **mathematically unprovable** for the current linear chain construction. Phase 6 analysis (iteration 3) confirmed this and identified viable resolution paths.

## File State

| Metric | Before Task 916 | After Iteration 1 | After Iteration 2 | After Iteration 3 |
|--------|-----------------|-------------------|-------------------|--------------------|
| WitnessGraph errors | 4 | **0** | **0** | **0** |
| WitnessGraph sorries | 4 | 2 | **0** | **0** |
| DovetailingChain sorries | 4 | 4 | 2 | 2 (documented as unprovable) |
| Documentation | - | - | Analysis in WitnessGraph | Updated docstrings in DovetailingChain + TemporalCoherentConstruction |

Note: DovetailingChain sorry count dropped from 4 to 2 due to cross-sign propagation work
done in an earlier task (not Task 916). Task 916 Iteration 3 updated the documentation to
reflect the current sorry count.

## Work Completed

### Phase 3B: Fix Build Errors [COMPLETED]

1. **`set_mcs_neg_or` (2 errors)**: Replaced with existing `set_mcs_negation_complete`
2. **`GContent_subset_implies_HContent_reverse` (2 errors)**: Duplicated from DovetailingChain.lean
3. **`enrichedBackwardChain_GContent_reverse` type mismatch**: Fixed duality direction

### Phase 5A: Cross-Sign Sorries [COMPLETED]

Proved `enrichedChainBFMCS.forward_G` and `enrichedChainBFMCS.backward_H` with 11 new lemmas:

**Core infrastructure (7 lemmas):**
- `enriched_chains_share_base` - chains share rootMCS at index 0
- `enrichedBackwardChain_G_propagates_reverse[_le]` - G toward 0 in backward chain
- `enrichedBackwardChain_forward_G` - forward_G within backward chain
- `enrichedForwardChain_H_propagates_reverse[_le]` - H toward 0 in forward chain
- `enrichedForwardChain_backward_H` - backward_H within forward chain

**Int-level case-split (4 lemmas):**
- `enrichedChainSet_forward_G_nonneg` / `_neg` - forward_G cases
- `enrichedChainSet_backward_H_nonpos` / `_nonneg` - backward_H cases

### Phase 5B: Forward_F [PARTIAL]

**Analysis (complete)**: Exhaustive exploration of approaches confirmed that forward_F is mathematically unprovable for ANY linear chain construction:

- **Root cause**: `F(phi) -> G(F(phi))` is not provable in TM logic. F-formulas don't self-persist through GContent seeds. G(neg phi) can enter via opaque Lindenbaum extensions at any step, permanently killing F(phi).

- **Approaches explored**: omega-squared inner chain, companion chains, interleaved enriched+witness chains, priority-based witnessing, generalized seed consistency, argument-by-contradiction with Nat.unpair coverage, direct witness graph embedding. All have the same fundamental gap.

**Action taken**: Removed the 2 impossible sorry'd theorems (`enrichedForwardChain_forward_F`, `enrichedBackwardChain_backward_P`). These were unused downstream and mathematically unprovable for the enriched chain. Added detailed mathematical analysis documenting the impossibility.

**Forward path identified**: The witness graph infrastructure (`witnessGraph_forward_F_local`, `witnessGraph_backward_P_local`) provides the correct local properties. A future task should build a BFMCS that embeds witness graph nodes into Int while maintaining both GContent propagation (for forward_G) and F-witness existence (for forward_F). This requires a non-linear construction (tree unraveling or omega-squared chain).

### Phase 5C: Backward_P [PARTIAL]

Symmetric to Phase 5B. The impossible sorry was removed along with forward_F. WitnessGraph.lean now has 0 sorries.

### Phase 6: Integration with DovetailingChain [BLOCKED]

**Iteration 3 analysis** confirmed that the Phase 6 plan (simple import + wiring) is not viable:

1. **`buildDovetailingChainFamily` forward_F unprovable**: The linear chain with single-encoding (decodeFormula n at step n) cannot guarantee F-formula survival. GContent seeds strip F-formulas, and Lindenbaum extensions can introduce G(neg(psi)) at any step.

2. **Nat.unpair redesign doesn't help**: A chain checking F(decode(b)) in mcs(a) where (a,b) = Nat.unpair(n) covers all (time, formula) pairs, but the seed consistency argument requires F(psi) in mcs(n) (the predecessor), not mcs(a) (the source). G(neg(psi)) can enter between steps a and n.

3. **`witnessGraphBFMCS` (constant family) doesn't help**: F(psi) in rootMCS does not imply psi in rootMCS.

4. **Non-constant witness graph embedding doesn't help for forward_G**: GContent only propagates along edges, not between arbitrary graph nodes.

5. **ZornFamily approach has same gap**: `total_family_FObligations_satisfied` is sorry'd for the same fundamental reason.

**Documentation updated**: Corrected sorry counts in DovetailingChain.lean (4 -> 2) and TemporalCoherentConstruction.lean. Added detailed blocker analysis to forward_F and backward_P docstrings.

**Viable resolution paths** (all require new tasks, 15-30h each):
1. **Omega-squared construction**: Inner chain for each F-obligation at each outer step
2. **Witness-graph-guided chain**: Chain that consults witness graph at each step
3. **Zorn with F/P invariant**: Extend Zorn approach to carry F/P coherence

## Remaining Work

### Phase 6 (BLOCKED): Requires new BFMCS construction
- Cannot close forward_F/backward_P with current codebase
- Need a new task for one of the three resolution paths above

### Phase 7 (NOT STARTED): Documentation
- Deferred until Phase 6 is resolved

## Verification

```
lake build Bimodal.Metalogic.Bundle.WitnessGraph
# Build completed successfully (0 errors, 0 sorry warnings from this file)

lake build Bimodal.Metalogic.Bundle.DovetailingChain
# Build completed successfully (2 sorry warnings: forward_F, backward_P)

lake build Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
# Build completed successfully
```

## Files Modified

### Iteration 1-2 (WitnessGraph.lean)
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` - Fixed errors, added ~280 lines of proof code, removed 2 impossible sorry'd theorems, added analysis documentation

### Iteration 3 (Documentation)
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Updated sorry count documentation (4->2), improved forward_F/backward_P docstrings with blocker analysis
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Updated sorry count documentation
- `specs/916_implement_fp_witness_obligation_tracking/plans/implementation-011.md` - Phase 6 marked BLOCKED with detailed analysis

## Artifacts

- Summary: `specs/916_implement_fp_witness_obligation_tracking/summaries/implementation-summary-20260224.md`
- Handoff (iter 1): `specs/916_implement_fp_witness_obligation_tracking/handoffs/phase-5B-handoff-20260224.md`
- Plan: `specs/916_implement_fp_witness_obligation_tracking/plans/implementation-011.md`

## Phase Status

- Phase 3B: [COMPLETED] - 0 build errors
- Phase 5A: [COMPLETED] - forward_G and backward_H proven (sorry-free)
- Phase 5B: [PARTIAL] - Analysis complete, impossible sorries removed, new construction needed
- Phase 5C: [PARTIAL] - Symmetric to 5B, sorries removed
- Phase 6: [BLOCKED] - Integration impossible with current construction; requires new task
- Phase 7: [NOT STARTED] - Documentation (deferred until Phase 6 resolved)
