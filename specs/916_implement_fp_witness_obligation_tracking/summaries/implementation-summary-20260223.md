# Implementation Summary: Task #916 (Phase 1)

**Session**: 2026-02-23, sess_1771892810_8cdc73
**Phase**: 1 of 6 (Define Witness Graph Structure)
**Status**: Phase 1 COMPLETED

## Changes Made

Created new file `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` implementing
the core data structures for the "Deferred Concretization" approach to close the
`forward_F` and `backward_P` sorries in DovetailingChain.lean.

### Structures Defined

| Structure | Purpose |
|-----------|---------|
| `ObligationType` | F(psi) or P(psi) obligation classification |
| `WitnessObligation` | Pairs node index with obligation type |
| `WitnessNode` | MCS subtype + origin tracking (root or witness) |
| `EdgeDirection` | Forward (F-obligation) or backward (P-obligation) |
| `WitnessEdge` | Directed edge with source, destination, and direction |
| `WitnessGraph` | Complete graph: nodes, edges, obligations, resolved map |
| `WitnessGraph.WellFormed` | 4 structural invariants (nonempty, edges_valid, obligations_valid, resolved_valid) |

### Key Theorems and Lemmas

| Name | Statement |
|------|-----------|
| `witnessSeed_future_consistent` | F(psi) in MCS M implies {psi} union GContent(M) is consistent |
| `witnessSeed_past_consistent` | P(psi) in MCS M implies {psi} union HContent(M) is consistent |
| `witnessSeed_consistent` | Unified consistency theorem for both obligation types |
| `initialWitnessGraph_wellFormed` | Initial graph satisfies all well-formedness conditions |
| `addWitness_preserves_node` | Existing nodes unchanged when adding witness |
| `addWitness_new_node` | New witness accessible at end of node list |

### Design Decisions

1. **Circular import avoidance**: Duplicated seed consistency proofs from DovetailingChain.lean
   rather than importing it. This avoids a circular dependency when Phase 6 adds an import
   of WitnessGraph into DovetailingChain.

2. **List-based storage**: Used `List WitnessNode` and `List WitnessEdge` instead of partial
   functions `Nat -> Option _`. Lists are finite and amenable to induction, matching the
   incremental construction approach.

3. **Subtype for MCS**: `WitnessNode.mcs` uses `{ S : Set Formula // SetMaximalConsistent S }`
   to carry the maximal consistency proof with the data, following the established pattern
   in the codebase.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` (NEW, ~690 lines)

## Verification

- `lake build Bimodal.Metalogic.Bundle.WitnessGraph` succeeds
- Full project `lake build` succeeds (1001 jobs)
- No sorries introduced
- No axioms introduced
- No regressions in existing code

## Next Steps

Phase 2: Implement Witness Graph Construction
- Define `initialGraph` from consistent context
- Define `collectObligations` using Formula Encodable instance
- Define `processObligation` to create witness nodes
- Prove `processObligation_preserves_structure`
