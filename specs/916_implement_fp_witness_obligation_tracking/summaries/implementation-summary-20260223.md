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

Phases 4-6 remain:
- Phase 4: Int Embedding (3-5 hours)
- Phase 5: Global Temporal Coherence (3-5 hours)
- Phase 6: Integration with DovetailingChain.lean (2-4 hours)
