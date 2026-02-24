# Research Report: Task #916 (Implementation Progress Review)

**Task**: Implement F/P Witness Obligation Tracking
**Date**: 2026-02-23
**Focus**: Progress review of WitnessGraph.lean implementation and path forward analysis
**Session**: sess_1771899483_ae9fe0

---

## 1. Executive Summary

The WitnessGraph.lean implementation has made substantial progress through Phases 1-2 (fully completed) and Phase 3 (partial). The file is 1579 lines with 5 remaining sorries across 4 theorems, all in Phase 3. The build succeeds cleanly. Phases 4-6 have not been started.

The 5 remaining sorries break into three categories: (A) extracting witness information from `isWitnessed = true` (2 sorries, identical pattern), (B) handling `F(psi)` blocking `P(psi)` processing in `processStep` (1 sorry), and (C) proving GContent/HContent propagation through edges (2 sorries, symmetric). Category C is the most architecturally significant; Categories A and B are bookkeeping complications from the `isWitnessed` check.

**Key recommendation**: A refactoring of the proof structure for `witnessGraph_forward_F_local` and `witnessGraph_backward_P_local` would simplify all 3 sorry categories. Rather than case-splitting on `isWitnessed` at step `n`, the proof should use strong induction on the construction step where the witness edge was first created, which avoids the need to extract information from `isWitnessed = true` entirely.

---

## 2. Current State Analysis

### 2.1 File Metrics

| Metric | Value |
|--------|-------|
| Total lines | 1579 |
| Sorries | 5 (across 4 theorems) |
| Axioms | 0 |
| Build status | Succeeds (697 jobs) |
| Phases completed | Phase 1 (structure), Phase 2 (construction) |
| Phase in progress | Phase 3 (properties) -- PARTIAL |
| Phases not started | Phase 4 (Int embedding), Phase 5 (global coherence), Phase 6 (integration) |

### 2.2 What Is Proven (Sorry-Free)

The following are fully proven without sorry:

**Phase 1 -- Core Infrastructure (lines 1-680)**:
- `ObligationType`, `WitnessObligation`, `WitnessNode`, `WitnessEdge`, `WitnessGraph` structures
- `WitnessGraph.WellFormed` with 4 invariants
- `witnessSeed_future_consistent` and `witnessSeed_past_consistent` (~50 lines each, full deduction-theoretic proofs)
- `initialWitnessGraph_wellFormed`
- `addWitness` family of preservation lemmas (6 lemmas)

**Phase 2 -- Construction Machinery (lines 680-1102)**:
- `processStep` and `buildWitnessGraph` definitions
- `processStep_nodes_length_ge`, `processStep_node_preserved` (monotonicity)
- `buildWitnessGraph_nonempty`, `buildWitnessGraph_root_preserved`
- `buildWitnessGraph_node_stable`, `buildWitnessGraph_nodes_length_mono_le`
- `addFutureWitness_contains_formula`, `addPastWitness_contains_formula`
- `addFutureWitness_GContent_extends`, `addPastWitness_HContent_extends`
- `coverage_step_exists` (every (node, formula) pair is eventually processed)
- `lindenbaum_extends_seed`, `lindenbaum_is_mcs`

**Phase 3 -- Partial (lines 1103-1579)**:
- `edgeExistsAtStep`, `nodeExistsAtStep`, `stableNodeMCS` definitions
- `processStep_edge_preserved`, `buildWitnessGraph_edge_stable`
- `ProcessStepOutcome` inductive type
- `stableNodeMCS_eq` (MCS stability across steps)
- `processStep_creates_fresh_future_witness`, `processStep_creates_fresh_past_witness` (full proofs)
- `witnessGraph_edges_acyclic` (full proof -- edges always have `src < dst`)
- `witnessGraph_nodes_finite` (full proof -- at most k+1 nodes at step k)

### 2.3 Remaining Sorries (5 total)

#### Sorry 1: `witnessGraph_forward_F_local` line 1373 (isWitnessed = true case)

**Goal state**:
```
h_wit : g_n.isWitnessed i (ObligationType.future psi) = true
-- g_n = buildWitnessGraph rootMCS n
-- F(psi) is in node i's MCS at step n
-- Need: exists k' j such that forward edge (i,j) at step k' and psi in node j
```

**Difficulty**: When `isWitnessed = true`, the obligation was already resolved at some earlier step. The proof needs to extract the witness node index from the `isWitnessed` check (which uses `List.any` with `zipIdx`), then show the corresponding edge and node still exist at step n or later. This requires:
1. An inversion lemma for `isWitnessed = true` that produces the obligation index and witness node
2. Showing that the edge and node created when the obligation was resolved persist to step n

#### Sorry 2: `witnessGraph_backward_P_local` line 1427 (isWitnessed = true case)

**Goal state**: Identical pattern to Sorry 1, but for past obligations.

#### Sorry 3: `witnessGraph_backward_P_local` line 1437 (F blocks P case)

**Goal state**:
```
h_wit_false : g_n.isWitnessed i (ObligationType.past psi) = false
h_F_at_n : psi.some_future ∈ node i's MCS at step n
-- P(psi) is in MCS, but F(psi) is ALSO in MCS
-- processStep checks F first, so it processes F(psi) instead of P(psi)
-- Need: exists k' j such that backward edge (i,j) at step k' and psi in node j
```

**Difficulty**: The `processStep` function checks `F(psi)` before `P(psi)`. When both are in the MCS, the step at `n` handles the F-obligation, not the P-obligation. The proof needs to find a different step where P is handled. Options:
- Use `coverage_step_exists` to find another step n' where the pair (i, psi) is examined again. At n', either (a) the F-obligation is already witnessed (so processStep skips it and processes P), or (b) F is still unwitnessed (processStep handles F again, but a later step will handle P).
- This is solvable via a well-founded argument: each coverage pass either witnesses a new obligation or skips because it is already witnessed. Eventually P gets its turn.

#### Sorry 4: `witnessGraph_GContent_propagates` line 1467

**Goal state**:
```
h_edge : { src := i, dst := j, dir := EdgeDirection.forward } in graph edges at step k
-- Need: GContent(node i's MCS) subset of node j's MCS
```

**Difficulty**: Must trace the edge back to the `processStep` that created it, then use `addFutureWitness_GContent_extends`. This requires:
1. An induction on `k` showing that any forward edge at step k was either inherited from step k-1 or freshly created by `processStep` at step k
2. If freshly created: `addFutureWitness_GContent_extends` applies directly (the witness MCS extends GContent of source)
3. If inherited: by induction hypothesis, the property held at step k-1
4. The subtlety: at step k, the MCS at node i may appear different than at the step when the edge was created, but `buildWitnessGraph_node_stable` ensures the MCS is unchanged

#### Sorry 5: `witnessGraph_HContent_propagates` line 1479

**Goal state**: Symmetric to Sorry 4 for backward edges and HContent.

---

## 3. Analysis of Proof Strategies

### 3.1 Sorries 1-2: `isWitnessed = true` Inversion

**Current approach**: Case-split on `isWitnessed` at the coverage step `n`. When true, need to extract witness info.

**Problem**: `isWitnessed` uses `List.any` on `obligations.zipIdx`, which is computationally opaque. Extracting an existential witness from `List.any = true` requires `List.any_iff_exists` or similar, then further destructuring to get the obligation index, then using the `resolved` map to find the witness node, then verifying the edge exists.

**Recommended alternative**: Instead of case-splitting on `isWitnessed`, restructure the proof to use strong induction on the build step. The key observation: for any F(psi) at node i existing at step k, either:
- The witness was already created at some step m <= k (find it by induction)
- The witness will be created at the next coverage step (by `processStep_creates_fresh_future_witness`)

A cleaner formulation would be:

```
-- Lemma: processStep either creates a witness or preserves existing ones
-- Main theorem: by strong induction on the first step where the edge appears
```

This eliminates the need for `isWitnessed` inversion entirely, since the proof focuses on the step where the edge was created rather than the step where the obligation is examined.

**Effort estimate**: 4-6 hours to refactor + prove

### 3.2 Sorry 3: F-blocks-P Processing

**Current approach**: At step n, both F(psi) and P(psi) are in the MCS. processStep handles F first.

**Three resolution strategies**:

**Strategy A (Recursive coverage)**: Use `coverage_step_exists` to find step n' > n. At n', the F-obligation from step n is already witnessed (or was witnessed at an even earlier step). So processStep at n' will skip F and process P.

**Strategy B (Different formula encoding)**: Note that processStep uses `decodeFormulaWG` which maps Nat to Formula. The pair (i, encodeFormulaWG psi) always decodes to psi, and both F(psi) and P(psi) are checked. There is no separate encoding for "check P of psi". This means F(psi) always gets priority on any step that examines psi at node i.

The fix for Strategy A requires showing:
1. At step n, F(psi) is processed and witnessed (or was already witnessed)
2. At a later step n', the pair (i, psi) is examined again
3. At n', `isWitnessed i (.future psi)` is now true (F was handled)
4. So processStep proceeds to check P(psi), finds it unwitnessed, and creates a witness

This requires proving that `isWitnessed` becomes true after `addFutureWitness` creates a witness. This is the `isWitnessed` monotonicity property: once an obligation is witnessed, it stays witnessed.

**Strategy C (Simplify processStep)**: Modify processStep to handle both F and P in a single step when both exist. This eliminates the blocking issue entirely but requires modifying Phase 2 code.

**Recommended**: Strategy A -- it is mathematically clean and requires no code changes. However, it does require the `isWitnessed` monotonicity lemma and an `isWitnessed_after_addFutureWitness` lemma.

**Effort estimate**: 3-5 hours

### 3.3 Sorries 4-5: GContent/HContent Propagation

**Current approach**: The theorems state propagation for any edge at step k, but the proof is empty.

**Recommended proof structure**: Strong induction on k.

For `witnessGraph_GContent_propagates`:
1. Base case (k=0): No edges in initial graph, so vacuously true
2. Inductive case (k = n+1):
   - The edge is either inherited from step n or freshly created at step n
   - If inherited: by IH, GContent propagated at step n. Node MCSs are stable, so it propagates at step n+1
   - If freshly created: the edge was created by `addFutureWitness`. By `addFutureWitness_GContent_extends`, GContent of source is a subset of witness MCS. This is exactly what we need.

The critical helper lemma needed: characterizing the edges at step k+1 as either inherited from step k or freshly created. `processStep_edges_subset_or_new` (line 1487, already proven) provides exactly this characterization.

Additional helper needed: when an edge is inherited from step k-1 to step k, the MCS at the source and destination nodes are unchanged (by `buildWitnessGraph_node_stable`). So GContent propagation at step k-1 implies propagation at step k.

**Effort estimate**: 6-8 hours (requires careful MCS stability arguments matching indices)

---

## 4. Remaining Work Assessment

### 4.1 Phase 3 Completion

| Sorry | Category | Strategy | Effort (hrs) |
|-------|----------|----------|-------------|
| 1 (forward F isWitnessed=true) | A | Refactor to avoid isWitnessed case | 4-6 |
| 2 (backward P isWitnessed=true) | A | Same as Sorry 1 | (included above) |
| 3 (F blocks P) | B | Recursive coverage with monotonicity | 3-5 |
| 4 (GContent propagates) | C | Strong induction + processStep characterization | 6-8 |
| 5 (HContent propagates) | C | Symmetric to Sorry 4 | (included above) |
| **Total Phase 3** | | | **13-19 hours** |

### 4.2 Phases 4-6

| Phase | Description | Effort (hrs) | Dependencies |
|-------|-------------|-------------|--------------|
| Phase 4: Int Embedding | Embed witness graph into Int preserving order | 12-15 | Phase 3 |
| Phase 5: Global Coherence | Prove forward_G, backward_H, forward_F, backward_P for BFMCS | 10-12 | Phase 4 |
| Phase 6: Integration | Replace sorries in DovetailingChain.lean | 8-10 | Phase 5 |
| **Total Phases 4-6** | | **30-37 hours** | |

### 4.3 Total Remaining

**Total remaining effort: 43-56 hours** (Phase 3: 13-19 + Phases 4-6: 30-37)

---

## 5. Architectural Assessment

### 5.1 Is the Current Approach Sound?

**Yes.** The deferred concretization approach is mathematically sound and well-executed:
- Phase 1-2 definitions are clean and well-structured
- The coverage argument via double-unpair is correct
- Witness seed consistency (the hard mathematical content) is fully proven
- Edge acyclicity (src < dst) is proven, supporting future Int embedding
- The remaining sorries are all bookkeeping/structural -- no fundamental mathematical obstacles

### 5.2 Alternative Approaches Considered and Rejected

The plan file documents 5 prior approaches (v001-v005) that were rejected for sound reasons:
- v001-v003: F-persistence through linear chain fails
- v004: Generalized consistency lemma is false
- v005: FPreservingSeed conjecture refuted by counterexample

The current v006 (deferred concretization) avoids all these pitfalls.

### 5.3 Potential Simplification of Phases 4-6

**Phase 4 simplification**: Instead of a full topological sort and Int embedding, the proof can assign integers by node index (since edges satisfy src < dst). Define `embed(i) = i` and note that all edges preserve strict ordering. The BFMCS can be defined on Nat rather than Int, then embedded into Int via the natural inclusion. This avoids the need for a topological sort.

However, the BFMCS must be defined on ALL of Int (not just non-negative integers). The trick: for negative integers, use a default MCS (e.g., the root MCS). Since no edges point to negative indices, the temporal properties at negative indices only need to satisfy GContent/HContent propagation, which holds trivially if all negative-index MCSs are identical.

**Phase 5 simplification**: With the simplified embedding (node index = integer), forward_F becomes: if F(psi) is in MCS at node i, then by `witnessGraph_forward_F_local`, there exists node j > i with psi in MCS at j. Since embed(j) > embed(i), this gives the required future witness. This is nearly a direct corollary of the Phase 3 theorems.

**Phase 6 consideration**: Integration requires defining a BFMCS Int that uses the witness graph. The existing `buildDovetailingChainFamily` in DovetailingChain.lean would need to be replaced or supplemented. The simplest approach: define `witnessGraphBFMCS` in WitnessGraph.lean and prove all four temporal coherence properties there, then have DovetailingChain.lean import and use it.

---

## 6. Recommendations

### 6.1 Immediate Priority: Complete Phase 3 (5 sorries)

**Approach**: Tackle in this order:
1. **GContent/HContent propagation (Sorries 4-5)** -- These are self-contained induction proofs that do not depend on the isWitnessed machinery. Start here to build momentum. Requires helper lemma connecting `processStep_edges_subset_or_new` with MCS stability.
2. **Forward F isWitnessed=true (Sorry 1)** -- Refactor proof to avoid isWitnessed case-split, using instead a direct construction argument.
3. **Backward P (Sorries 2-3)** -- After the forward case is resolved, the backward case follows with minor modifications for the F-blocks-P complication.

### 6.2 Helper Lemmas to Prove First

Before tackling the main sorries, prove these foundational lemmas:

1. **`processStep_new_edge_GContent`**: When processStep creates a forward edge at step n, GContent of source is subset of witness MCS at step n+1. (Combines existing `processStep_creates_fresh_future_witness` with `addFutureWitness_GContent_extends`.)

2. **`processStep_new_edge_HContent`**: Symmetric for backward edges.

3. **`buildWitnessGraph_mcsAt_stable`**: If node i exists at step m, then `(buildWitnessGraph root n).mcsAt i = (buildWitnessGraph root m).mcsAt i` for all n >= m. (Wraps existing `buildWitnessGraph_node_stable` for the MCS specifically.)

4. **`isWitnessed_monotone`**: If `g.isWitnessed i obl = true` and g' extends g (in the sense of processStep/buildWitnessGraph), then `g'.isWitnessed i obl = true`. (Needed only if the isWitnessed-based proof structure is retained.)

### 6.3 Medium-Term: Simplify Phases 4-6

The original plan estimates 30-37 hours for Phases 4-6. With the simplified embedding approach (use node index directly, default MCS for negative integers), this could be reduced to 15-25 hours.

### 6.4 Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| GContent propagation proof is harder than expected (MCS stability across steps) | LOW | MEDIUM | Core lemmas already proven; helper lemmas needed are straightforward |
| isWitnessed inversion is more complex than expected | MEDIUM | LOW | Alternative: restructure proofs to avoid isWitnessed case (recommended) |
| Int embedding introduces unexpected complications | LOW | HIGH | Simplified embedding via node index avoids topological sort |
| Context exhaustion on long proofs | HIGH | MEDIUM | Break each sorry into separate lemma; commit after each |

---

## 7. Sorry Debt Status

### WitnessGraph.lean (5 sorries)

All 5 sorries are development placeholders with clear remediation paths:

| Line | Theorem | Category | Remediation |
|------|---------|----------|-------------|
| 1373 | `witnessGraph_forward_F_local` | Development placeholder | Refactor to avoid isWitnessed case or prove isWitnessed inversion |
| 1427 | `witnessGraph_backward_P_local` | Development placeholder | Same approach as line 1373 |
| 1437 | `witnessGraph_backward_P_local` | Development placeholder | Recursive coverage after F is witnessed |
| 1467 | `witnessGraph_GContent_propagates` | Development placeholder | Strong induction on k with processStep characterization |
| 1479 | `witnessGraph_HContent_propagates` | Development placeholder | Symmetric to line 1467 |

These 5 sorries block transitive sorry-freedom for: `witnessGraph_forward_F_local`, `witnessGraph_backward_P_local`, `witnessGraph_GContent_propagates`, `witnessGraph_HContent_propagates`, and all downstream theorems that will depend on them (Phases 4-6).

### DovetailingChain.lean (2 sorries, pre-existing)

The original target sorries (`buildDovetailingChainFamily_forward_F` at line 1754, `buildDovetailingChainFamily_backward_P` at line 1761) remain untouched. These will be eliminated in Phase 6 after Phases 3-5 are complete.

---

## 8. References

- Implementation plan: `specs/916_implement_fp_witness_obligation_tracking/plans/implementation-006.md`
- Prior research: `specs/916_implement_fp_witness_obligation_tracking/reports/research-010.md`
- Implementation file: `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`
- Target file: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`

---

## 9. Next Steps

1. Implement helper lemmas (Section 6.2) as foundation for Phase 3 sorry closure
2. Prove GContent/HContent propagation (Sorries 4-5) via strong induction
3. Refactor forward_F_local proof to avoid isWitnessed case-split (Sorry 1)
4. Complete backward_P_local proof (Sorries 2-3)
5. Proceed to simplified Phase 4 (Int embedding via node index)
