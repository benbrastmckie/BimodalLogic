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

---

## Phase 2: Implement Witness Graph Construction

**Session**: 2026-02-23, sess_1771893934_40c616
**Status**: Phase 2 COMPLETED

### Changes Made

Added ~400 lines to `WitnessGraph.lean` implementing the core witness graph construction
machinery. The approach uses lazy (node, formula) pair enumeration via `Nat.unpair` and
`Encodable Formula` to process F/P obligations one at a time, creating witness nodes via
fresh Lindenbaum extensions.

### Key Definitions

| Name | Purpose |
|------|---------|
| `processStep` | Core step: decode Nat.unpair n to (nodeIdx, formulaIdx), check membership, create witness |
| `buildWitnessGraph` | Iterate processStep from initial single-node graph |
| `addFutureWitness` | Create witness node for F(psi) via Lindenbaum({psi} union GContent) |
| `addPastWitness` | Create witness node for P(psi) via Lindenbaum({psi} union HContent) |
| `isWitnessed` | Check if obligation already resolved |

### Key Theorems

| Name | Statement |
|------|-----------|
| `addFutureWitness_contains_formula` | psi in witness MCS when F(psi) is source obligation |
| `addPastWitness_contains_formula` | psi in witness MCS when P(psi) is source obligation |
| `addFutureWitness_GContent_extends` | GContent(source) subset of future witness MCS |
| `addPastWitness_HContent_extends` | HContent(source) subset of past witness MCS |
| `coverage_step_exists` | Every (node, formula) pair eventually processed |
| `processStep_nodes_length_ge` | processStep monotonicity |
| `processStep_node_preserved` | Existing nodes unchanged by processStep |
| `buildWitnessGraph_node_stable` | Nodes stable across multiple steps |
| `buildWitnessGraph_root_preserved` | Root node preserved at all steps |

### Verification

- `lake build` succeeds (1001 jobs)
- 0 sorries introduced
- 0 axioms introduced

---

## Phase 3: Prove Witness Graph Properties [IN PROGRESS]

**Session**: 2026-02-23, sess_1771895035_2fab82
**Status**: Phase 3 PARTIAL (context exhaustion)

### Progress Made

Added ~315 lines of property proof infrastructure. Key proofs started:

| Proof Started | Status |
|--------------|--------|
| `forward_F_witness_exists` | Partial - structure in place |
| `backward_P_witness_exists` | Partial - mirrors forward |
| `GContent_propagates_through_forward` | In progress |
| `node_monotonicity_lemmas` | Multiple helper lemmas added |

### Current Blockers

1. **Build errors**: Omega arithmetic issues with Nat subtraction comparisons
2. **7 sorries**: Remaining proof obligations need completion
3. **Context exhaustion**: Agent hit context limits before finishing

### Files Modified

- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` (now ~1503 lines)

### Next Steps

Continue Phase 3:
- Fix omega arithmetic issues (likely need explicit Nat.sub_le lemmas)
- Complete 7 remaining sorries
- Verify build passes

---

## Phase 3A: Fix 8 Build Errors [COMPLETED]

**Session**: 2026-02-23, sess_1771912616_e1d1af
**Status**: COMPLETED

### Changes Made

Fixed all 8 remaining build errors in WitnessGraph.lean using `congrArg`-based dependent rewrite patterns per research-013.md (Option A). The file now compiles with 0 errors and 0 sorries.

### Errors Fixed

| Error | Location | Root Cause | Fix |
|-------|----------|------------|-----|
| Placeholder synthesis | Line 2135 | `[_]` in list literal | `congrArg List.length h_edges; simp` |
| Type mismatch | Line 1816 | `congr 1` decomposes indexed access wrong | `congrArg WitnessGraph.nodes h_ps_eq; simp` |
| simp no progress | Line 1700 | Can't rewrite through dependent bound | Extract `.nodes` equality, transport index with helper |
| rewrite failed | Lines 1980-1981 | `split` picks wrong expression | Rewrite decode BEFORE split: `simp only [h_decode]` |
| split failed (GContent) | Line 2260 | `match Nat.unpair` not splittable | `processStep_outcome` + `congrArg edges/nodes` |
| split failed (HContent) | Line 2386 | Same as 2260, symmetric | Same pattern as 2260 |

### Key Technical Patterns

1. **`congrArg WitnessGraph.nodes/edges h_ps_eq`** - Extract field equality from struct equality
2. **Decode before split** - `simp only [h_decode]` collapses `match decodeFormulaWG` before `split`
3. **`processStep_outcome` over `unfold processStep`** - Avoids `split` on `match Nat.unpair`
4. **`change (psi == psi) = true; exact beq_self_eq_true psi`** - Handle `ObligationType` BEq

### Files Modified

- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` (now ~2402 lines, 0 sorries, 0 errors)

### Verification

- `lake build Bimodal.Metalogic.Bundle.WitnessGraph` succeeds (0 errors)
- 0 sorries in WitnessGraph.lean
- `end Bimodal.Metalogic.Bundle` present at file end (line 2402)
- No new axioms

### Next Steps

Phases 5-6 remain:
- Phase 5: Global Temporal Coherence (3-5 hours)
- Phase 6: Integration with DovetailingChain.lean (2-4 hours)

---

## Phase 4: Int Embedding [COMPLETED]

**Session**: 2026-02-23, sess_1771912616_e1d1af
**Status**: COMPLETED

### Design Revision

The original plan proposed a direct node-index-to-Int mapping where `mcs(t) = g.mcsAt t.toNat` for integers in range. Analysis revealed this does NOT give forward_G because the witness graph contains backward edges. Between two consecutive nodes connected by a backward edge, HContent (not GContent) propagates, violating the forward_G requirement.

**Revised approach**: Use a constant family where all times map to the root MCS. The T-axiom (G phi -> phi, H phi -> phi) gives forward_G and backward_H trivially. The witness graph serves as an "oracle" for F/P witness existence.

### Changes Made

Added ~187 lines to `WitnessGraph.lean` implementing the Int embedding infrastructure.

### Definitions Added

| Name | Purpose |
|------|---------|
| `mcs_G_implies_self` | T-axiom: G(phi) in MCS implies phi in MCS |
| `mcs_H_implies_self` | T-axiom: H(phi) in MCS implies phi in MCS |
| `mcs_G_implies_GG` | 4-axiom: G(phi) in MCS implies G(G(phi)) in MCS |
| `witnessGraphBFMCS` | BFMCS Int from root MCS (constant family) |
| `witnessGraphBFMCS_mcs_eq` | mcs(t) = rootMCS.val for all t (simp lemma) |
| `witnessGraphBFMCS_root_preserved` | context preservation at time 0 |
| `witnessGraph_node_is_mcs` | node MCS is maximal consistent |
| `witnessGraph_root_mcs` | node 0 in graph equals rootMCS (by induction) |
| `witnessGraphBFMCS_edge_ordering_compatible` | edge acyclicity lifts to Int |
| `witnessGraphBFMCS_at_root` | bridge: BFMCS time 0 = graph node 0 |
| `witnessGraph_forward_F_at_root` | F(psi) at root -> witness in graph |
| `witnessGraph_backward_P_at_root` | P(psi) at root -> witness in graph |

### Key Technical Insight

The direct node-index-to-Int mapping fails for forward_G because:
1. Backward edges have src < dst (by acyclicity) but propagate HContent, not GContent
2. Consecutive nodes connected by a backward edge violate forward_G
3. No forward-edge chain guaranteed between arbitrary node pairs

The constant family avoids this entirely. Phase 5 must connect the witness graph's F/P witnesses to the BFMCS, possibly requiring a non-constant construction.

### Files Modified

- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` (now ~2589 lines, 0 sorries, 0 errors)

### Verification

- `lake build Bimodal.Metalogic.Bundle.WitnessGraph` succeeds (0 errors)
- 0 sorries
- 0 axioms
- `end Bimodal.Metalogic.Bundle` present at file end

### Next Steps

Phase 5 needs to prove forward_F and backward_P. Options:
1. Use constant family + witness graph bridge (requires showing psi in rootMCS whenever F(psi) in rootMCS, which is false in general)
2. Build a non-constant BFMCS (GContent chain with witness placement)
3. Use Zorn's lemma approach (GHCoherentPartialFamily from ZornFamily.lean)

---

## Phase 5: Global Temporal Coherence [BLOCKED]

**Session**: 2026-02-23/24, sess_1771912616_e1d1af
**Status**: BLOCKED (Mathematical obstruction)

### Progress Made

Added ~524 lines implementing an "enriched chain" construction that attempts to extend the constant family with forward/backward chains carrying F/P witness obligations.

### Definitions Added

| Name | Purpose |
|------|---------|
| `enrichedForwardChain` | Forward chain from rootMCS with witness placement |
| `enrichedBackwardChain` | Backward chain from rootMCS with witness placement |
| `enrichedChainSet` | Combined chain mapping Int → Set Formula |
| `enrichedChainSet_is_mcs` | MCS property for combined chain |
| `enrichedForwardChain_GContent_extends` | GContent propagation forward |
| `enrichedBackwardChain_HContent_extends` | HContent propagation backward |
| `enrichedChainBFMCS` | BFMCS Int from enriched chains |

### Mathematical Obstruction

Forward_F and backward_P require **omega-squared construction** as documented in research reports 3-10:

1. **Problem**: The flat chain construction (linear time ℤ) cannot satisfy forward_F witness obligations because:
   - Each time step processes one (node, formula) pair via Nat.unpair
   - An F(psi) obligation at time t needs a witness at time s > t where psi holds
   - But the witness must also satisfy all G-content from times [t, s)
   - This creates nested obligations requiring omega² construction

2. **Same as DovetailingChain.lean**: The 4 sorries in the new code mirror the same obstruction:
   - `enrichedChainBFMCS.forward_F`: sorry
   - `enrichedChainBFMCS.backward_P`: sorry
   - `enrichedChainBFMCS.forward_G`: sorry (cross-sign propagation)
   - `enrichedChainBFMCS.backward_H`: sorry (cross-sign propagation)

### Files Modified

- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` (now ~3113 lines, 4 sorries)

### Next Steps

This is the same fundamental obstruction identified in research reports 3-10. Options:
1. **Accept sorry debt**: These sorries match DovetailingChain.lean - the witness graph infrastructure is complete but the temporal coherence properties require omega² construction
2. **Omega² research**: Invest 30-40 hours in implementing the inner chain construction
3. **Alternative approach**: Investigate if ZornFamily.lean's GHCoherentPartialFamily can be extended
