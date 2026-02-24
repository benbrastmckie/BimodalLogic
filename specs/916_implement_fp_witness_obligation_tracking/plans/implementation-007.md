# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P Witness Obligation Tracking
- **Status**: [NOT STARTED]
- **Effort**: 28-44 hours (revised from 60-90)
- **Dependencies**: None
- **Research Inputs**: research-010.md (deferred concretization), research-011.md (progress review)
- **Artifacts**: plans/implementation-007.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean
- **Lean Intent**: true
- **Version**: 007 (revised from 006 based on implementation progress)

## Overview

This plan revises implementation-006 based on progress review (research-011). Phases 1-2 are complete. Phase 3 has 5 remaining sorries. This revision restructures Phase 3 for efficient completion and simplifies Phases 4-6 to near-corollaries of Phase 3.

### Key Changes from v006

1. **Phase 3 restructured**: Tackle GContent/HContent propagation first (self-contained), then refactor F/P local proofs to avoid isWitnessed case-split
2. **Phases 4-6 simplified**: Use node index directly for Int embedding (no topological sort needed since edges satisfy src < dst)
3. **Effort reduced**: 28-44 hours remaining (down from 60-90 total)
4. **Helper lemmas added**: Foundation lemmas to enable cleaner main proofs

### Current State (from research-011)

| Phase | Status | Sorries |
|-------|--------|---------|
| Phase 1: Structure | COMPLETED | 0 |
| Phase 2: Construction | COMPLETED | 0 |
| Phase 3: Properties | PARTIAL | 5 |
| Phases 4-6 | NOT STARTED | - |

## Goals & Non-Goals

**Goals** (unchanged):
- Close forward_F and backward_P sorries in DovetailingChain.lean
- Produce BFMCS Int via witness graph construction

**Non-Goals** (unchanged):
- Modifying DovetailingChain.lean construction
- Cross-sign propagation (separate task)

## Sorry Characterization

### Current Sorries in WitnessGraph.lean (5 total)

| Line | Theorem | Category | Strategy |
|------|---------|----------|----------|
| 1373 | `witnessGraph_forward_F_local` | isWitnessed extraction | Refactor to strong induction |
| 1427 | `witnessGraph_backward_P_local` | isWitnessed extraction | Same as above |
| 1437 | `witnessGraph_backward_P_local` | F-blocks-P | Recursive coverage |
| 1467 | `witnessGraph_GContent_propagates` | Content propagation | Strong induction |
| 1479 | `witnessGraph_HContent_propagates` | Content propagation | Strong induction |

### Target Sorries in DovetailingChain.lean (2 total)

- Line 1754: `buildDovetailingChainFamily_forward_F`
- Line 1761: `buildDovetailingChainFamily_backward_P`

## Implementation Phases

### Phase 1: Define Witness Graph Structure [COMPLETED]

*No changes - fully complete, sorry-free*

---

### Phase 2: Implement Witness Graph Construction [COMPLETED]

*No changes - fully complete, sorry-free*

---

### Phase 3: Complete Witness Graph Properties [PARTIAL]

- **Dependencies**: Phases 1-2
- **Goal**: Close 5 remaining sorries in property proofs
- **Estimated effort**: 13-19 hours

**Sub-phase 3A: Foundation Helper Lemmas** [NOT STARTED]

*Prove these first to enable cleaner main proofs:*

1. `processStep_new_edge_GContent`: When processStep creates forward edge, GContent(source) ⊆ witness
2. `processStep_new_edge_HContent`: Symmetric for backward edges
3. `buildWitnessGraph_mcsAt_stable`: MCS at node i unchanged after node creation
4. `edge_created_at_unique`: Each edge was created at exactly one step (needed for induction)

**Estimated effort**: 3-4 hours

---

**Sub-phase 3B: GContent/HContent Propagation** [NOT STARTED]

*Self-contained induction proofs, independent of isWitnessed machinery*

**Tasks**:
- [ ] Prove `witnessGraph_GContent_propagates` (line 1467):
  - Statement: If forward edge (i,j) exists at step k, then GContent(node i) ⊆ node j
  - Proof: Strong induction on k
    - Base: k=0, no edges, vacuous
    - Inductive: Edge inherited from k-1 (IH + MCS stability) or freshly created (use 3A helper)
- [ ] Prove `witnessGraph_HContent_propagates` (line 1479):
  - Symmetric to GContent proof

**Estimated effort**: 4-6 hours

---

**Sub-phase 3C: Forward F Local Witness** [NOT STARTED]

*Refactor to avoid isWitnessed case-split*

**Key insight from research-011**: Instead of case-splitting on `isWitnessed` at the coverage step, use strong induction on the step where the witness edge was *first created*. This avoids needing to extract information from `isWitnessed = true`.

**Revised proof strategy for `witnessGraph_forward_F_local` (line 1373)**:
1. By `coverage_step_exists`, there exists step n where pair (i, psi) is examined
2. Either processStep at n creates a forward edge (use `processStep_creates_fresh_future_witness`)
3. Or the edge already exists (find by induction on build steps 0..n-1)
4. In either case, produce the required witness edge

**Tasks**:
- [ ] Add lemma `forward_edge_existence_by_coverage`:
  ```lean
  theorem forward_edge_existence_by_coverage (h_F : F(psi) ∈ g.mcsAt i) :
    ∃ k j, k ≤ steps ∧ (buildWitnessGraph root k).hasForwardEdge i j ∧
           psi ∈ (buildWitnessGraph root k).mcsAt j
  ```
- [ ] Complete `witnessGraph_forward_F_local` using above lemma

**Estimated effort**: 3-5 hours

---

**Sub-phase 3D: Backward P Local Witness** [NOT STARTED]

*Handle F-blocks-P complication*

**Strategy for line 1427 (isWitnessed=true)**: Same refactoring as 3C

**Strategy for line 1437 (F-blocks-P)**:
- When both F(psi) and P(psi) in MCS, processStep handles F first
- After F is witnessed, subsequent coverage passes will handle P
- Prove `isWitnessed_monotone`: once witnessed, stays witnessed
- Use recursive coverage argument

**Tasks**:
- [ ] Add `isWitnessed_monotone` lemma
- [ ] Add `isWitnessed_after_addFutureWitness` lemma
- [ ] Complete `witnessGraph_backward_P_local` using coverage iteration

**Estimated effort**: 3-4 hours

---

### Phase 4: Int Embedding (Simplified) [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Define BFMCS Int from witness graph
- **Estimated effort**: 5-8 hours

**Simplification from v006**: Since edges satisfy `src < dst` (proven in Phase 3 as `witnessGraph_edges_acyclic`), use node index directly as the Int embedding. No topological sort needed.

**Tasks**:
- [ ] Define `witnessGraphBFMCS : WitnessGraph → BFMCS Int`:
  ```lean
  def witnessGraphBFMCS (g : WitnessGraph) : BFMCS Int where
    mcs t := if t < 0 then g.mcsAt 0  -- negative: default to root
             else if h : t.toNat < g.nodes.length then g.mcsAt t.toNat
             else g.mcsAt (g.nodes.length - 1)  -- beyond: default to last
  ```
- [ ] Prove `witnessGraphBFMCS_at_node`: For valid node i, mcs(i) = g.mcsAt i
- [ ] Prove embedding preserves strict ordering on edges

**Estimated effort**: 5-8 hours

---

### Phase 5: Global Temporal Coherence [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Prove all 4 temporal coherence properties for BFMCS
- **Estimated effort**: 6-10 hours

**Key insight**: These become near-corollaries of Phase 3 properties combined with Phase 4 embedding.

**Tasks**:
- [ ] Prove `witnessGraphBFMCS_forward_G`:
  - If G(phi) ∈ mcs(t) and t < s, then phi ∈ mcs(s)
  - Uses: GContent propagation + embedding
- [ ] Prove `witnessGraphBFMCS_backward_H`:
  - Symmetric to forward_G
- [ ] Prove `witnessGraphBFMCS_forward_F`:
  - If F(phi) ∈ mcs(t), then ∃s > t with phi ∈ mcs(s)
  - Uses: `witnessGraph_forward_F_local` + embedding
- [ ] Prove `witnessGraphBFMCS_backward_P`:
  - Symmetric to forward_F

**Estimated effort**: 6-10 hours

---

### Phase 6: Integration [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Replace sorries in DovetailingChain.lean
- **Estimated effort**: 4-6 hours

**Tasks**:
- [ ] Add import of WitnessGraph.lean to DovetailingChain.lean
- [ ] Define `buildDovetailingChainFamily` using `witnessGraphBFMCS`
- [ ] Wire `witnessGraphBFMCS_forward_F` to close sorry at line 1754
- [ ] Wire `witnessGraphBFMCS_backward_P` to close sorry at line 1761
- [ ] Verify `lake build` succeeds with 0 new sorries
- [ ] Create implementation summary

**Estimated effort**: 4-6 hours

---

## Summary of Changes from v006

| Aspect | v006 | v007 |
|--------|------|------|
| Total effort | 60-90 hours | 28-44 hours |
| Phase 3 structure | Single phase | 4 sub-phases with dependencies |
| Phase 3 approach | isWitnessed case-split | Strong induction on edge creation |
| Phase 4 approach | Topological sort + Int embedding | Direct node index (edges are acyclic) |
| Phase 5 scope | Full re-proof | Near-corollaries |
| Helper lemmas | Implicit | Explicit foundation (3A) |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Strong induction refactoring harder than expected | LOW | MEDIUM | Fallback: prove isWitnessed inversion |
| Embedding edge cases at Int boundaries | LOW | LOW | Default to root/last node for out-of-range |
| Context exhaustion | MEDIUM | MEDIUM | Sub-phases sized at 3-6 hours each |

## Success Criteria

- [ ] WitnessGraph.lean: 0 sorries (currently 5)
- [ ] DovetailingChain.lean forward_F/backward_P: 0 sorries (currently 2)
- [ ] `lake build` succeeds
- [ ] No new axioms introduced
