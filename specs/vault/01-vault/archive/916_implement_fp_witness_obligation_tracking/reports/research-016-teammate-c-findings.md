# Teammate C Findings: Approach Comparison and Mosaic Method

## Summary

After extensive analysis of the mosaic method (Marx, Mikulas, Reynolds 2000), comparison with the witness-graph-guided and omega-squared immediate processing approaches, and careful review of 15 prior research reports, this report concludes that **the omega-squared immediate processing approach is the best path forward**. The mosaic method is mathematically elegant but would require a ground-up rewrite of the BFMCS architecture (~80-120 hours). The witness-graph-guided approach remains blocked by the forward/backward edge ordering conflict. The omega-squared approach with immediate processing is the only option that both resolves the mathematical obstruction and reuses existing infrastructure.

## Mosaic Method Analysis

### What the Mosaic Method Is

The mosaic method (Marx, Mikulas, Reynolds 2000; extended by Marx, Mikulas, Reynolds 2012 for many-dimensional modal logics) decomposes temporal models into small local fragments called "mosaics." Each mosaic is a small structure containing:

- A finite set of states (typically 2-3 points for tense logic)
- An ordering relation between those states
- A labeling function assigning each state the set of formulas true there
- Local consistency conditions: every formula assigned to a state must be locally coherent (e.g., if F(psi) is at state s, there must be a state s' > s in the mosaic with psi at s')

A "mosaic system" is a set of mosaics that is **saturated**: for every mosaic boundary point, there exists another mosaic that extends the timeline in the required direction. The key theorem is that a formula is satisfiable if and only if there exists a saturated mosaic system containing a mosaic where the formula holds.

### How the Mosaic Method Handles Bidirectional Temporal Operators

The mosaic method handles F and P naturally because each mosaic is a LOCAL structure. A mosaic for tense logic over linear orders typically consists of two consecutive time points (s, s') with s < s'. The mosaic specifies:

- Which formulas hold at s and s'
- The transition from s to s' must be "coherent": if G(phi) is at s, then phi must be at s'
- If F(psi) is at s, then either psi is at s' (local witness) or F(psi) is at s' (deferred obligation)
- Similarly for P: if P(psi) is at s', then either psi is at s (local witness) or P(psi) is at s (deferred obligation)

The saturation condition ensures that deferred obligations are eventually resolved: for any F(psi) that persists to the "right boundary" of a mosaic, there must exist a continuation mosaic where psi eventually appears.

**Crucially, there is no global embedding step.** The model is assembled from mosaics by gluing them together along shared boundary points. Forward and backward edges never conflict because each mosaic only handles a local pair of adjacent points. The global model emerges from the saturation property, not from a single DAG embedding.

### Can the Mosaic Method Help with the Bidirectional Edge Conflict?

**Yes, in principle.** The mosaic method avoids the ordering conflict entirely because:

1. It never builds a global DAG that needs embedding into Int
2. Each F/P obligation is handled locally within or between adjacent mosaics
3. The model is assembled incrementally by tiling, not by topological sorting

**However**, this comes at a steep cost: the entire BFMCS construction would need to be replaced with a mosaic-based construction. The current codebase builds a BFMCS as a function `Int -> Set Formula` where each integer maps to an MCS. A mosaic approach would build the model from local pieces and then extract the `Int -> Set Formula` mapping at the end.

### Why the Mosaic Method Is Not Practical Here

1. **No existing infrastructure**: The codebase has zero mosaic-related definitions. The WitnessGraph.lean (3113 lines) and DovetailingChain.lean (~1800 lines sorry-free) provide no mosaic infrastructure.

2. **Architectural mismatch**: The BFMCS structure requires `mcs : D -> Set Formula` with D = Int. Converting a mosaic system into this format requires a separate embedding theorem (essentially the same Int-embedding problem, but at a different abstraction level).

3. **Formalization complexity**: The mosaic method's power comes from its abstract generality -- it works for many logics simultaneously. But this generality means significant overhead in defining mosaic types, coherence conditions, saturation, and the assembly theorem. For a single logic (TM/bimodal tense logic), the step-by-step or omega-squared approach is simpler.

4. **Existing formalizations**: The Rocq/Coq formalization of modal logic completeness (comp-dec-modal project on GitHub) uses pruning-based algorithms, not mosaics. No Lean or Coq formalization of the mosaic method for tense logic exists to my knowledge. We would be breaking new ground with no reference implementation.

5. **Effort estimate**: 80-120 hours minimum for a mosaic-based construction, versus 24-48 hours for omega-squared immediate processing.

### Mosaic Method in the Literature

The mosaic method is primarily used for **decidability and complexity results**, not for practical completeness proofs of specific logics. The key references are:

- Marx, Mikulas, Reynolds (2000): "The Mosaic Method for Temporal Logics" (TABLEAUX 2000) -- proves complexity and completeness for Prior's temporal logic over linear flows of time
- Marx, Mikulas, Reynolds (2012): "On the Mosaic Method for Many-Dimensional Modal Logics" (Logica Universalis) -- extends to combined tense + S5 modalities (directly relevant to TM logic)
- Nemeti (1995): Original mosaic method for algebraic logic
- Marx, Venema (1997): "Mosaics and step-by-step" -- connects mosaics to step-by-step construction

The 2012 extension to combined tense + S5 is particularly relevant: it handles exactly the operator combination in TM logic (G/H/F/P + Box/Diamond). However, the method is abstract and aimed at decidability proofs, not concrete model construction suitable for Lean formalization.

## Three-Way Comparison

| Criterion | Witness-Graph-Guided | Omega-Squared Immediate | Mosaic Method |
|-----------|---------------------|------------------------|---------------|
| **Complexity** | Medium (embedding is hard) | Medium (double indexing) | Very High (new framework) |
| **Existing infra reuse** | High (WitnessGraph.lean 3113 lines) | Medium (seed consistency, GContent props) | None (ground-up) |
| **Mathematical risk** | HIGH: forward/backward edge conflict unsolved | LOW: seed consistency proven, immediate processing avoids persistence | LOW: well-understood theory |
| **Estimated effort** | 55-75 hours (per research-014) | 24-48 hours (per research-015) | 80-120 hours |
| **Handles bidirectional** | NO: conflicting orderings | YES: processes each direction independently | YES: inherent in design |
| **Formalization precedent** | None in any proof assistant | Standard textbook technique | None in Lean/Coq |
| **Integration with BFMCS** | Moderate (need embedding step) | Easy (produces Int-indexed chain) | Hard (mosaic-to-BFMCS conversion) |
| **Confidence (success)** | 40-50% (research-014 estimate) | 60-70% (research-015 teammate-a) | 30-40% (new territory) |

## Recommendation

**Pursue the Omega-Squared Immediate Processing approach.**

The reasoning:

1. **Lowest risk-to-reward ratio**: 24-48 hours with 60-70% success probability gives the best expected outcome. The mosaic method has similar mathematical soundness but 3x the effort and lower success probability due to formalization novelty.

2. **Directly addresses the mathematical obstruction**: The core problem is that F(psi) can be killed by Lindenbaum introducing G(neg(psi)) before the enumeration reaches psi. Immediate processing eliminates this: when F(psi) first appears, process it BEFORE any Lindenbaum extension can kill it. The seed `{psi} union GContent(M)` is proven consistent by `witnessSeed_consistent` (WitnessGraph.lean:544).

3. **Reuses proven infrastructure**: The existing `witnessSeed_consistent`, GContent/HContent propagation lemmas, and cross-sign duality theorems all carry over directly. The enriched chain pattern provides a template for the inner chain construction.

4. **Produces the required BFMCS directly**: The omega-squared construction naturally produces a function `Int -> Set Formula` without requiring any embedding or conversion step.

5. **The witness-graph-guided approach should be abandoned** (or deprioritized as a long-term goal) because the forward/backward edge ordering conflict has no known resolution. Research-015 teammate-a spent extensive analysis on this and concluded that "the ONLY viable construction" is immediate processing, not DAG embedding.

## Can the Witness-Graph-Guided Approach Be Unblocked?

### The Specific Conflict

The witness graph has two types of edges:
- **Forward edges** (i, j, forward): GContent(node_i) subset of node_j's MCS. Temporal meaning: node_i is BEFORE node_j.
- **Backward edges** (i, j, backward): HContent(node_i) subset of node_j's MCS. Temporal meaning: node_j is BEFORE node_i.

The witness graph's `witnessGraph_edges_acyclic` proves `e.src < e.dst` for ALL edges (both forward and backward). This means:
- Forward edge (3, 7): node 3 before node 7 temporally. Construction order 3 < 7. **Consistent.**
- Backward edge (3, 7): node 7 before node 3 temporally. Construction order 3 < 7. **Conflicting.**

### Potential Resolutions Analyzed

**Resolution 1: Dual Timelines**
Place forward-reachable nodes on non-negative Int and backward-reachable nodes on negative Int. Problem: some nodes are reachable by BOTH forward and backward paths from the root. These nodes would need to be at both positive and negative positions simultaneously. Also, forward_G requires GContent propagation between ALL pairs (t, t') with t < t', not just edge-connected pairs. Cross-timeline GContent propagation is not guaranteed.

**Resolution 2: Tree Unraveling**
Unravel the DAG into a tree, then flatten the tree into a linear order. Problem: Unraveling destroys sharing -- the same MCS may appear at multiple tree positions. The resulting BFMCS would have `chain(t) = chain(t')` for different times t, t'. This is fine for model theory but loses the property that each time point has a unique MCS (which is not actually required by the BFMCS structure). However, the unraveled tree still has bidirectional temporal requirements that conflict when linearized.

**Resolution 3: Separate Forward and Backward Subgraphs**
Process the forward subgraph (only forward edges) for non-negative times and the backward subgraph (only backward edges) for negative times. Problem: forward_F obligations at negative times and backward_P obligations at positive times cannot be satisfied by this split. The construction must handle F/P obligations at ALL time positions, not just one direction.

**Resolution 4: Topological Sort with Reversed Backward Edges**
Define a new partial order where forward edges (i, j) give i < j and backward edges (i, j) give j < i. Then topologically sort this partial order. Problem: this partial order may have cycles! Consider: forward edge (2, 5) says 2 < 5, and backward edge (3, 7) says 7 < 3. If there's also a forward edge (5, 7), we get 2 < 5 < 7 < 3, but if there's a forward edge (2, 3), we get 2 < 3 < ... < 7 < 3, a cycle. The witness graph construction does not guarantee this partial order is acyclic.

**Resolution 5: Order-Preserving Injection into Q (rationals)**
Any countable partial order without infinite ascending/descending chains can be embedded into Q, and hence into Int. But the temporal partial order defined above may have cycles (Resolution 4), making this inapplicable.

### Verdict on Unblocking

**The witness-graph-guided approach cannot be unblocked without fundamentally changing the witness graph construction.** The core issue is that the witness graph's construction order (src < dst) does not correspond to temporal order for backward edges. Any resolution that tries to assign temporal positions to witness graph nodes must reconcile forward and backward edge directions, which creates a constraint system that can be cyclic.

A future investigation could explore whether restricting the witness graph construction to avoid certain edge patterns would make the temporal partial order acyclic. However, this would require major changes to `buildWitnessGraph` and its proofs, estimated at 30-50 additional hours on top of the 55-75 hour estimate. This makes it significantly more expensive than the omega-squared approach.

## Detailed Analysis: Why Omega-Squared Immediate Processing Works

### The Construction

At each outer step n, when F(psi) first appears in the current MCS:
1. The current MCS M contains F(psi)
2. The seed `{psi} union GContent(M)` is consistent (by `witnessSeed_consistent`, since F(psi) in M)
3. Create a Lindenbaum extension of this seed as the NEXT inner step
4. The extension contains psi (satisfying forward_F for this obligation)
5. The extension contains GContent(M) (maintaining forward_G continuity)

### Why This Avoids the Persistence Problem

The persistence problem occurs when F(psi) appears at step m but the enumeration doesn't process psi until step n >> m. During the gap [m, n], Lindenbaum extensions at intermediate steps can introduce G(neg(psi)), killing F(psi).

Immediate processing eliminates the gap: F(psi) is processed at the SAME outer step where it first appears. There are no intermediate Lindenbaum extensions between the appearance of F(psi) and its processing. The seed consistency is guaranteed because F(psi) is alive at the moment of processing.

### Key Requirement: One Obligation at a Time

The counterexample that refuted FPreservingSeed used INFINITELY many F-formulas in the seed simultaneously. The omega-squared approach processes ONE F-obligation at a time. The seed `{psi} union GContent(M)` (for a single psi) is proven consistent when F(psi) is in M. This is the critical difference.

### What Needs to Be Proven

1. **GContent monotonicity**: If GContent(M) subset M' and M is MCS, then GContent(M) subset GContent(M'). Follows from the 4-axiom: G(phi) in M implies G(G(phi)) in M, so G(phi) in GContent(M) subset M', so phi in GContent(M').

2. **Inner chain consistency**: Each inner step extends `{psi_i} union GContent(prev)`, proven consistent by witnessSeed_consistent when F(psi_i) is in prev.

3. **Coverage argument**: For any F(psi) at any outer step n, psi is placed at some inner step within outer step n (or at a later outer step if the obligation is propagated).

4. **forward_G continuity**: GContent(chain(t)) subset chain(t+1) for all t. Follows from the inner chain construction using GContent seeds.

5. **backward_P**: Symmetric construction for the backward direction using HContent seeds and `past_temporal_witness_seed_consistent`.

## Confidence Level

**Medium-High (65-75%)**

**Justification**:
- The mathematical argument is sound and follows the standard textbook technique (Goldblatt 1992, Blackburn et al. 2001)
- The seed consistency for single obligations is proven (`witnessSeed_consistent`)
- GContent monotonicity follows straightforwardly from the 4-axiom
- The omega-squared construction has been validated by multiple research reports (003, 010, 015)
- The main risk is formalization complexity in Lean 4 (double-indexed chains, obligation tracking)
- Prior implementation attempts have failed at formalization despite correct mathematics, which lowers confidence from the mathematical 90%+ to practical 65-75%

**What could go wrong**:
1. The inner chain obligation tracking may be more complex than expected (need to handle infinite obligations at each outer step)
2. The "limit" MCS at each outer step (union of inner chain) may not be well-defined without careful treatment of directed limits
3. Cross-sign GContent/HContent coherence across the forward/backward boundary at time 0 may require additional lemmas
4. Context exhaustion during implementation (prior pattern: 3+ sessions exhausted on this task)

## References

### Literature
- Marx, M., Mikulas, S., Reynolds, M. (2000). "The Mosaic Method for Temporal Logics." TABLEAUX 2000. [SpringerLink](https://link.springer.com/chapter/10.1007/10722086_26)
- Marx, M., Mikulas, S., Reynolds, M. (2012). "On the Mosaic Method for Many-Dimensional Modal Logics." Logica Universalis. [SpringerLink](https://link.springer.com/article/10.1007/s11787-012-0074-5)
- Reynolds, M. (2003). "Completeness by construction for tense logics of linear time." [ResearchGate](https://www.researchgate.net/publication/252750536_Completeness_by_construction_for_tense_logics_of_linear_time)
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.
- Burgess, J.P. (1982). "Axioms for tense logic." *Notre Dame Journal of Formal Logic*.
- Hodkinson, I. and Reynolds, M. "Temporal Logic." Chapter 11 in *Handbook of Modal Logic*. [PDF](https://cgi.csc.liv.ac.uk/~frank/MLHandbook/11.pdf)
- Venema, Y. "Temporal Logic." Chapter 10 in *Handbook of Modal Logic*. [PDF](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- comp-dec-modal: Completeness and Decidability of Modal Logic Calculi (Rocq/Coq). [GitHub](https://github.com/rocq-community/comp-dec-modal)

### Project Files
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` -- Witness graph construction (3113 lines, Phases 1-2 sorry-free)
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- Linear chain with 2 sorries (forward_F, backward_P)
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-015.md` -- Latest team synthesis
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-014.md` -- Path forward synthesis
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-010.md` -- Deferred concretization analysis
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-003.md` -- Team consensus on omega-squared

### Proven Lemmas (Reusable)
| Lemma | File | Status |
|-------|------|--------|
| `witnessSeed_consistent` | WitnessGraph.lean:544 | Proven (sorry-free) |
| `forward_temporal_witness_seed_consistent` | DovetailingChain.lean | Proven (sorry-free) |
| `past_temporal_witness_seed_consistent` | DovetailingChain.lean | Proven (sorry-free) |
| `GContent_subset_implies_HContent_reverse` | DovetailingChain.lean | Proven (sorry-free) |
| `HContent_subset_implies_GContent_reverse` | WitnessGraph.lean | Proven (sorry-free) |
| `enrichedForwardChain_GContent_extends` | WitnessGraph.lean | Proven (sorry-free) |
| `enrichedBackwardChain_HContent_extends` | WitnessGraph.lean | Proven (sorry-free) |
| `witnessGraph_forward_F_local` | WitnessGraph.lean | Proven (sorry-free) |
| `witnessGraph_backward_P_local` | WitnessGraph.lean | Proven (sorry-free) |
