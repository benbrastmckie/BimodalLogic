# Teammate C Findings: Proof-Debt-Free Completion Requirements

## Summary

Closing forward_F and backward_P in DovetailingChain.lean with zero proof debt requires replacing the entire linear chain BFMCS construction with a non-linear (witness-graph-guided) construction. The linear chain is mathematically incapable of satisfying F/P witness obligations because Lindenbaum extensions can introduce G(neg(psi)) which kills F(psi) permanently. The existing WitnessGraph.lean provides proven local witness existence (`witnessGraph_forward_F_local`, `witnessGraph_backward_P_local`) but lacks the critical embedding-into-Int infrastructure and global coherence proofs needed for a complete BFMCS. Additionally, eliminating all transitive proof debt requires resolving 3 additional sorries and 2 axioms in downstream files.

## Current Proof Debt Inventory

### Direct Sorries in DovetailingChain.lean

| File | Line | Type | Description | Category |
|------|------|------|-------------|----------|
| DovetailingChain.lean | 1767 | sorry | `buildDovetailingChainFamily_forward_F` -- F(psi) in M_t implies exists s > t with psi in M_s | Fundamental obstacle (linear chain) |
| DovetailingChain.lean | 1779 | sorry | `buildDovetailingChainFamily_backward_P` -- P(psi) in M_t implies exists s < t with psi in M_s | Fundamental obstacle (linear chain) |

### Transitive Sorries in Import Chain

DovetailingChain.lean is imported by TemporalCoherentConstruction.lean, which adds:

| File | Line | Type | Description | Category |
|------|------|------|-------------|----------|
| TemporalCoherentConstruction.lean | 639 | sorry | `temporal_coherent_family_exists` (generic D version) -- only Int is used downstream | Development placeholder |
| TemporalCoherentConstruction.lean | 845 | sorry | `fully_saturated_bmcs_exists_int` -- combines temporal coherence + modal saturation | Construction assumption |
| Construction.lean | 197 | sorry | `singleFamilyBMCS.modal_backward` -- single-family modal backward is unprovable | Construction assumption |

### Axioms in Non-Boneyard Metalogic Files

| File | Line | Declaration | Description | Used in Completeness? |
|------|------|-------------|-------------|----------------------|
| CoherentConstruction.lean | 871 | `saturated_extension_exists` | Every CoherentBundle has a saturated extension | Indirectly (via `construct_saturated_bmcs`) |
| TemporalCoherentConstruction.lean | 781 | `fully_saturated_bmcs_exists` (deprecated) | Generic fully saturated BMCS existence | No (deprecated, replaced by `_int` version) |

### WitnessGraph.lean Status

| Metric | Value |
|--------|-------|
| Sorries | 0 |
| Axioms | 0 |
| Build errors | ~30 (from Phase 3A handoff, may be stale) |

**Note**: WitnessGraph.lean currently has build errors from incomplete Phase 3A work. The file compiles with errors but all theorem *statements* and *proofs for the core local results* are structurally sound. The remaining errors are in helper lemmas for the enriched chain section.

## Dependency Analysis

### What forward_F/backward_P Actually Need to Prove

The sorry'd theorems have these exact signatures:

```lean
-- forward_F
lemma buildDovetailingChainFamily_forward_F
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    forall t : Int, forall phi : Formula,
      Formula.some_future phi in (buildDovetailingChainFamily Gamma h_cons).mcs t ->
      exists s : Int, t < s /\ phi in (buildDovetailingChainFamily Gamma h_cons).mcs s

-- backward_P (symmetric)
lemma buildDovetailingChainFamily_backward_P
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    forall t : Int, forall phi : Formula,
      Formula.some_past phi in (buildDovetailingChainFamily Gamma h_cons).mcs t ->
      exists s : Int, s < t /\ phi in (buildDovetailingChainFamily Gamma h_cons).mcs s
```

These state: for the specific BFMCS `buildDovetailingChainFamily Gamma h_cons`, every F-formula has a strictly future witness and every P-formula has a strictly past witness.

### Why the Linear Chain Cannot Satisfy These

The `buildDovetailingChainFamily` constructs a linear chain `M_0, M_1, M_{-1}, M_2, M_{-2}, ...` where each `M_t` is a Lindenbaum extension of a seed containing GContent/HContent from neighbors. The fundamental issue:

1. F(psi) at M_t does NOT imply psi persists to any M_s with s > t
2. The Lindenbaum extension at any future step can introduce G(neg(psi))
3. Once G(neg(psi)) enters (at any step), it persists forever via the 4-axiom `G(x) -> G(G(x))`
4. G(neg(psi)) and psi are contradictory in an MCS

This is documented extensively in WitnessGraph.lean lines 3008-3047 and is a **fundamental mathematical obstruction**, not merely a proof difficulty.

### What the Witness Graph Already Provides

WitnessGraph.lean contains sorry-free proofs of:

1. **`witnessGraph_forward_F_local`**: For any F(psi) at node i in the witness graph, there exists a witness node j with psi in j's MCS and a forward edge from i to j
2. **`witnessGraph_backward_P_local`**: Symmetric for P obligations
3. **`enrichedChainBFMCS`**: A BFMCS Int with proven `forward_G` and `backward_H` (but NOT forward_F/backward_P)
4. **Seed consistency**: `enriched_forward_seed_consistent` and `enriched_backward_seed_consistent`
5. **Cross-sign coherence**: G/H propagation through shared root MCS

### The Gap: Local to Global

The witness graph proves *local* F/P witness existence (for individual nodes), but does NOT provide:

1. **Int embedding**: A function mapping witness graph nodes to Int indices that respects temporal ordering (forward edges -> strictly increasing, backward edges -> strictly decreasing)
2. **G/H propagation across graph edges**: Proof that GContent propagates along forward edges and HContent along backward edges
3. **Complete BFMCS construction**: A BFMCS Int where `mcs t` returns the MCS of the witness graph node assigned to time t
4. **Global forward_F/backward_P**: Proof that the Int-indexed BFMCS satisfies forward_F and backward_P by virtue of the witness graph's local properties

## Axiom Check

### Axioms in the Critical Completeness Path

The completeness proof in `Completeness.lean` uses:
1. `construct_saturated_bmcs_int` which calls `fully_saturated_bmcs_exists_int` (sorry-backed theorem, line 825 of TemporalCoherentConstruction.lean)
2. This in turn depends on `temporal_coherent_family_exists_Int` which delegates to `temporal_coherent_family_exists_theorem` in DovetailingChain.lean
3. `temporal_coherent_family_exists_theorem` uses both sorry'd lemmas (`forward_F`, `backward_P`)

**Axioms in scope (non-Boneyard)**:
- `saturated_extension_exists` in CoherentConstruction.lean (used by `construct_saturated_bmcs` for generic D, but NOT used in the Int completeness path)
- `fully_saturated_bmcs_exists` in TemporalCoherentConstruction.lean (deprecated, not used in Int path)

**Classical.choice dependencies**: The entire construction is noncomputable and uses Classical.choice extensively (via Lindenbaum extensions, `Classical.propDecidable`, etc.). This is standard for canonical model constructions and NOT considered proof debt.

### Would a Witness-Graph-Guided Approach Introduce New Axioms?

No, if done correctly. The witness graph construction in WitnessGraph.lean is already axiom-free and sorry-free for its local results. The gap is purely in proving global properties of the Int embedding. All required tools (Lindenbaum extension, MCS properties, seed consistency) are already proven.

## Complete Improvement Checklist

### Category 1: Core -- Replace Linear Chain with Non-Linear Construction

| # | Item | Effort | Risk | Priority | Dependency |
|---|------|--------|------|----------|------------|
| 1.1 | Fix remaining ~30 build errors in WitnessGraph.lean | 4-8 hours | Medium | P0 | None |
| 1.2 | Design and prove witness graph Int embedding (topological sort) | 8-16 hours | High | P0 | 1.1 |
| 1.3 | Prove G/H content propagation along witness graph edges | 4-8 hours | Medium | P0 | 1.1 |
| 1.4 | Construct complete BFMCS Int from witness graph | 4-8 hours | Medium | P0 | 1.2, 1.3 |
| 1.5 | Prove forward_F for witness-graph BFMCS | 4-8 hours | Medium | P0 | 1.4 |
| 1.6 | Prove backward_P for witness-graph BFMCS | 2-4 hours | Low | P0 | 1.5 (symmetric) |
| 1.7 | Prove forward_G for witness-graph BFMCS | 4-8 hours | Medium | P0 | 1.4 |
| 1.8 | Prove backward_H for witness-graph BFMCS | 2-4 hours | Low | P0 | 1.7 (symmetric) |

### Category 2: Update DovetailingChain.lean Integration

| # | Item | Effort | Risk | Priority | Dependency |
|---|------|--------|------|----------|------------|
| 2.1 | Replace `buildDovetailingChainFamily_forward_F` sorry with witness-graph proof | 2-4 hours | Low | P0 | 1.5 |
| 2.2 | Replace `buildDovetailingChainFamily_backward_P` sorry with witness-graph proof | 1-2 hours | Low | P0 | 1.6 |
| 2.3 | Update `temporal_coherent_family_exists_theorem` to use witness-graph BFMCS | 2-4 hours | Medium | P0 | 2.1, 2.2 |

### Category 3: Downstream Sorry Elimination (for transitive freedom)

| # | Item | Effort | Risk | Priority | Dependency |
|---|------|--------|------|----------|------------|
| 3.1 | Eliminate `temporal_coherent_family_exists` generic D sorry (line 639 TemporalCoherentConstruction.lean) | 2-4 hours | Low | P1 | 2.3 |
| 3.2 | Eliminate `fully_saturated_bmcs_exists_int` sorry (line 845 TemporalCoherentConstruction.lean) | 8-16 hours | High | P1 | 2.3 + modal saturation integration |
| 3.3 | Eliminate `singleFamilyBMCS.modal_backward` sorry (line 197 Construction.lean) | N/A | N/A | P2 | Not in Int completeness path; may be removable if unused |

### Category 4: Axiom Elimination (for publication-readiness)

| # | Item | Effort | Risk | Priority | Dependency |
|---|------|--------|------|----------|------------|
| 4.1 | Eliminate `saturated_extension_exists` axiom (CoherentConstruction.lean) | 16-32 hours | High | P2 | Not in Int completeness path |
| 4.2 | Remove deprecated `fully_saturated_bmcs_exists` axiom (already deprecated) | 1 hour | Low | P2 | Verify no callers |

### Category 5: Documentation and Architecture

| # | Item | Effort | Risk | Priority | Dependency |
|---|------|--------|------|----------|------------|
| 5.1 | Update DovetailingChain.lean module docstring to reflect non-linear construction | 0.5 hours | Low | P1 | 2.3 |
| 5.2 | Update WitnessGraph.lean Phase 5 analysis comments | 0.5 hours | Low | P1 | 1.5 |
| 5.3 | Update Completeness.lean axiom dependency documentation | 0.5 hours | Low | P1 | 3.2 |
| 5.4 | Update SORRY_REGISTRY.md | 0.5 hours | Low | P1 | All |

## Recommended Approach

### Strategy: Witness-Graph-Guided BFMCS (Deferred Concretization)

The recommended approach builds on the existing sorry-free WitnessGraph.lean infrastructure:

**Phase A -- Fix Build Errors (prerequisite)**
Continue from Phase 3A handoff to get WitnessGraph.lean compiling cleanly. This is approximately 30 errors, mostly in helper lemmas.

**Phase B -- Int Embedding**
The hardest new work. Must define an embedding function `embed : WitnessGraph -> (Nat -> Int)` that:
- Assigns each node a unique Int value
- Preserves forward edge ordering: if edge (i, j, forward) then embed(i) < embed(j)
- Preserves backward edge ordering: if edge (i, j, backward) then embed(j) < embed(i)

**Design choice**: The witness graph is a DAG (new nodes are always added with index > all existing nodes). A simple approach: enumerate nodes in a topological order consistent with edge directions. Since the graph grows unboundedly (one new node per obligation), the embedding is into an omega-length sequence of Int values.

**Key insight**: We do NOT need to embed the entire infinite witness graph into Int at once. We can use the *limit* construction: at each step k, `buildWitnessGraph rootMCS k` gives a finite graph. The BFMCS can be defined as the limit of finite approximations, or more practically, for any specific time index t, we can find the graph step k where node t's MCS stabilizes.

**Phase C -- BFMCS Construction**
Define `witnessGraphBFMCS : {S // SetMaximalConsistent S} -> BFMCS Int` by:
1. Taking the witness graph limit
2. Embedding nodes into Int
3. Proving forward_G, backward_H from GContent/HContent propagation
4. Proving forward_F, backward_P from local witness existence + embedding properties

**Phase D -- Integration**
Replace the sorry'd lemmas in DovetailingChain.lean by delegating to the witness-graph BFMCS.

### Alternative: Direct Replacement

Instead of patching the existing linear chain, define a completely new `witnessGraphChainFamily` that replaces `buildDovetailingChainFamily`. This is cleaner but requires more refactoring of downstream callers.

### Effort Estimate

| Phase | Effort | Cumulative |
|-------|--------|------------|
| A: Fix build errors | 4-8 hours | 4-8 hours |
| B: Int embedding | 8-16 hours | 12-24 hours |
| C: BFMCS construction | 8-16 hours | 20-40 hours |
| D: Integration | 4-8 hours | 24-48 hours |
| **Total for forward_F/backward_P** | **24-48 hours** | |
| E: Downstream sorry elimination (P1) | 12-24 hours | 36-72 hours |
| F: Axiom elimination (P2) | 16-32 hours | 52-104 hours |

### Risk Assessment

**High risk items**:
1. **Int embedding proof** (Phase B): The witness graph is an infinite DAG with both forward and backward edges. Proving a consistent Int embedding exists requires showing the edge relation is acyclic and that every finite subgraph has a consistent linear extension. This is mathematically sound but Lean formalization may be tricky.

2. **`fully_saturated_bmcs_exists_int` elimination** (item 3.2): This requires combining temporal coherence (from the new BFMCS) with modal saturation. The current sorry exists because these two properties are constructed by different mechanisms. Resolution requires either a unified construction or proving they can be combined.

**Medium risk items**:
1. **WitnessGraph build errors** (Phase A): ~30 errors remain from incomplete Phase 3A. Some may reveal deeper issues.
2. **G/H propagation across graph edges** (item 1.3): Must prove GContent(source) subset witness for forward edges and HContent(source) subset witness for backward edges. The seed consistency lemmas guarantee this for the initial extension, but propagation through multiple edges needs separate proof.

**Low risk items**:
1. backward_P is symmetric to forward_F (effort halved)
2. Documentation updates are mechanical
3. Generic D sorry (item 3.1) can be solved by type-level dispatch or restricting to Int only

## Confidence Level

**Medium confidence** that the approach is correct, with caveats:

**High confidence (> 90%)** that:
- The witness graph approach is mathematically sound for closing forward_F/backward_P
- The local witness theorems (`witnessGraph_forward_F_local`, `witnessGraph_backward_P_local`) are correctly proven and sufficient
- No new axioms are needed

**Medium confidence (60-75%)** that:
- The Int embedding can be formalized cleanly in Lean (the infinite DAG case is non-trivial)
- The total effort estimate of 24-48 hours for P0 items is accurate
- The existing WitnessGraph.lean build errors are fixable without major rewrites

**Low confidence (30-50%)** that:
- Item 3.2 (`fully_saturated_bmcs_exists_int`) can be resolved within the same task scope
- Full transitive proof-debt freedom (items 3.x + 4.x) is achievable without architectural redesign

## Appendix: Full Transitive Dependency Chain

```
Completeness.lean
  -> construct_saturated_bmcs_int (TemporalCoherentConstruction.lean)
    -> fully_saturated_bmcs_exists_int [SORRY - line 845]
      -> temporal_coherent_family_exists_Int
        -> temporal_coherent_family_exists_theorem (DovetailingChain.lean)
          -> buildDovetailingChainFamily_forward_F [SORRY - line 1767]
          -> buildDovetailingChainFamily_backward_P [SORRY - line 1779]
      -> modal saturation (sorry-free in ModalSaturation.lean)
      -> combination of temporal + modal [GAP]
  -> bmcs_truth_lemma (TruthLemma.lean, sorry-free)
  -> construct_saturated_bmcs_int_temporally_coherent
    -> fully_saturated_bmcs_exists_int [SORRY - same as above]
```

The completeness theorem transitively depends on exactly 3 sorries (forward_F, backward_P, fully_saturated_bmcs_exists_int) and 0 axioms in the Int path. Eliminating the 2 DovetailingChain sorries would reduce the transitive sorry count for completeness to 1.
