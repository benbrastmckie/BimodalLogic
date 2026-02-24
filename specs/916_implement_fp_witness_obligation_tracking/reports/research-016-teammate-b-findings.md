# Teammate B Findings: Tree Unraveling and DAG Linearization Techniques

## Summary

Tree unraveling is a standard technique in modal logic that converts an arbitrary Kripke frame into a bisimilar tree by expanding paths from a root. However, it is fundamentally unsuitable for tense logics with bidirectional operators (F/P and G/H) because the unraveled tree loses backward accessibility information -- the inverse relation in the original frame does not correspond to any natural relation in the tree. For the witness graph DAG in task 916, the core problem is that forward edges and backward edges impose CONFLICTING temporal orderings on the same set of nodes (both have src < dst in construction order, but backward edges need dst temporally BEFORE src). The standard technique from the literature for handling this is "bulldozing" -- replacing clusters in the canonical model with copies of Z and linearizing the result. A more practical approach for this specific problem is the "interleaved GContent chain with immediate F-processing" (the omega-squared variant), which avoids DAG linearization entirely.

## Literature Review

### Tree Unraveling: Definition and Limitations

The tree unraveling (also: "unravelling") of a Kripke model M = (W, R, V) at a world w0 produces a new model M' = (W', R', V') where:
- W' = all finite sequences (w0, w1, ..., wn) such that w_i R w_{i+1}
- (w0,...,wn) R' (w0,...,wn,w_{n+1}) iff w_n R w_{n+1}
- V'(p, (w0,...,wn)) = V(p, wn)

The projection pi((w0,...,wn)) = wn is a bounded morphism (p-morphism) from M' to M, ensuring that M and M' are bisimilar. Therefore they satisfy the same modal formulas.

**Critical limitation for tense logic**: The unraveled model M' has a TREE structure with edges only going from parent to child. In basic modal logic (with only Box/Diamond), this suffices because the accessibility relation R is the only relation. But in tense logic, satisfaction of past operators (P, H) depends on the INVERSE relation R^{-1}. In the unraveled tree, the inverse relation R'^{-1} goes from child to parent, which does NOT correspond to the original R^{-1} restricted to paths. Specifically:

- In M: if w R^{-1} v (i.e., v R w), then P(phi) at w depends on phi at v
- In M': if (w0,...,wn) R'^{-1} (w0,...,w_{n-1}), this is the PARENT path, which is a single specific predecessor. But in M, w_n might have MANY R-predecessors, and the past operator quantifies over ALL of them.

**Consequence**: Tree unraveling does NOT preserve satisfaction of tense logic formulas. The unraveled tree is bisimilar with respect to the FORWARD relation only. For the backward relation, bisimilarity fails because a node in the tree has exactly one R'^{-1}-predecessor (its parent), while the corresponding node in the original model may have many R^{-1}-predecessors.

This is why tense logics do NOT have the tree model property in general. Instead, they have the tree model property only for the "forward-looking" fragment. Bidirectional tense logic requires richer structures.

### The Bulldozing Technique

The standard technique for completeness proofs of tense logics over linear orders (including Z) is "bulldozing," developed by Segerberg and refined by Goldblatt, Venema, and others.

**Setup**: The canonical model for a tense logic has a frame (W_c, R_c) where:
- W_c = set of all maximal consistent sets (MCS)
- M R_c N iff for all phi, if G(phi) in M then phi in N (equivalently: GContent(M) subset N)

This canonical frame typically contains "clusters" -- groups of MCS that are mutually R_c-related (forming equivalence classes under the symmetric closure of R_c). These clusters are obstacles to linearity.

**Bulldozing procedure**:
1. Identify all proper clusters in the canonical frame (sets of 2+ MCS that are mutually accessible)
2. Replace each proper cluster C with |C| copies of Z (the integers)
3. Order the copies of Z consistently with the original ordering between clusters
4. Define the valuation on the copies by repeating the original cluster's valuations periodically

**Result**: The bulldozed frame is a linear order (in fact, isomorphic to a sub-order of Q or Z depending on the logic), and it satisfies the same tense logic formulas as the original canonical model.

**Relevance to task 916**: Bulldozing operates on the CANONICAL model, which is built from ALL maximal consistent sets of the logic. The construction in task 916 starts from a SINGLE root MCS and builds outward. The canonical model approach is a top-down technique (start with all MCS, then quotient/linearize), while the witness graph is a bottom-up technique (start from root, add witnesses). These are fundamentally different strategies.

### Completeness by Construction (Burgess/van Benthem Method)

An alternative to the canonical model + bulldozing approach is the "step-by-step" or "constructive" method, which builds the model incrementally:

1. Start with a single MCS Gamma_0 (the root)
2. At each stage n, extend the model by adding new MCS to satisfy outstanding temporal obligations
3. The frame T_n at stage n is a finite linear order with an MCS at each point
4. Take the limit as n -> omega

This is closer to what the witness graph construction does. The key difference is that in the standard step-by-step method:
- The frame is always a LINEAR order (a chain)
- New MCS are added at the ENDS of the chain or by INSERTING between existing points
- The construction ensures both forward (F) and backward (P) obligations are met by appropriate insertions

**The critical technique**: When F(psi) appears at some point t in the chain, the construction inserts a new MCS at a position s > t that contains psi AND whose GContent/HContent relationships with adjacent MCS are maintained. This insertion may require restructuring the entire chain -- replacing a segment [t, t+1, ...] with a finer chain that includes the witness.

## Tree Unraveling Design Analysis

### Can We Unravel the Witness Graph DAG?

The witness graph is a DAG with:
- Nodes: MCS indexed by Nat (construction order)
- Forward edges: (src, dst) where GContent(src) subset dst
- Backward edges: (src, dst) where HContent(src) subset dst
- Acyclicity: src < dst for ALL edges (both forward and backward)

A standard tree unraveling would:
1. Pick root node 0
2. For each forward edge (0, j), create a path (0, j) in the tree
3. For each forward edge (j, k), extend to (0, j, k)
4. Continue recursively

**Problem 1: Backward edges are NOT parent-to-child**
Backward edge (i, j) with i < j means: node i has P(psi), and node j is the past witness. Temporally, j should be BEFORE i. But in construction order, j > i. In the unraveled tree, j would be a DESCENDANT of i (further from root), which is the WRONG temporal direction.

**Problem 2: DAG sharing is lost**
If node k is reachable from root via both path (0, 3, k) and (0, 5, k), tree unraveling creates TWO copies of k. These copies might have different GContent relationships with their ancestors, breaking the global GContent propagation chain.

**Problem 3: No natural linear order on the tree**
Even if we unravel successfully, we need to FLATTEN the tree into a linear order indexed by Int. The tree has branching (each node can have multiple children = multiple witness edges), so we need to serialize the branches. Standard techniques (DFS, BFS) give orderings but do NOT preserve GContent propagation between all pairs.

### Verdict on Tree Unraveling

Tree unraveling is NOT applicable to this problem for three independent reasons:
1. Bidirectional tense operators break the bisimulation property of unraveling
2. The backward edge temporal ordering conflicts with tree descent
3. GContent propagation requires linear chain structure, not tree structure

## Impact on GContent/HContent Propagation

### GContent Monotonicity (Key New Lemma)

Before discussing approaches, a critical mathematical fact deserves emphasis. As Teammate A (research-015) identified:

**GContent Monotonicity Lemma**: If M is an MCS and GContent(M) subset M', then GContent(M) subset GContent(M').

**Proof**: Let phi in GContent(M), i.e., G(phi) in M. By the 4-axiom (G(phi) -> G(G(phi))), we get G(G(phi)) in M. So G(phi) in GContent(M). Since GContent(M) subset M', we have G(phi) in M'. Hence phi in GContent(M').

This means: along any GContent chain (where each step extends GContent of the previous), GContent is monotonically non-decreasing. This is the key property that makes forward_G provable for ANY GContent chain.

### GContent Propagation Along Paths

If we have a path n_0 -> n_1 -> ... -> n_k in the witness graph (all forward edges), then:
- GContent(n_0) subset n_1 (by edge propagation)
- GContent(n_0) subset GContent(n_1) (by monotonicity)
- GContent(n_1) subset n_2 (by edge propagation)
- Hence GContent(n_0) subset n_2

By induction: GContent(n_0) subset n_j for all j on the forward path.

**But**: this only works along FORWARD PATHS in the witness graph. Not all pairs of nodes are connected by forward paths. For forward_G, we need GContent(chain(t)) subset chain(t') for ALL t < t', not just connected pairs.

### The Gap-Fill Problem

Between non-adjacent witness graph nodes, we must insert "gap-fill" MCS that maintain GContent continuity. Each gap-fill MCS extends GContent of its predecessor via Lindenbaum extension. This gives a continuous GContent chain.

The gap-fill MCS are NOT witness graph nodes. They are fresh MCS created solely to maintain GContent propagation. When we reach a witness graph node in the ordering, we need to "merge" the GContent chain into the witness node -- i.e., ensure GContent(gap-fill) subset witness_node. This is NOT automatically satisfied.

**This is the same GContent continuity break** documented in research-015 Teammate A's analysis (v4 revision). The witness MCS extends {psi} union GContent(source_node), NOT GContent(preceding_gap_fill). So GContent of the preceding gap-fill may not be a subset of the witness MCS.

## Comparison to Omega-Squared Immediate Processing

### Summary of Approaches

| Approach | Core Idea | Forward_G | Forward_F | Complexity | Viable? |
|----------|-----------|-----------|-----------|------------|---------|
| Tree unraveling | Expand DAG paths into tree branches | Breaks (no linear chain) | Preserved locally | Medium | NO |
| DAG linearization (topological sort) | Total order on DAG nodes + gap-fill | Breaks at gap-fill/witness junctions | Preserved if ordering respects edges | High | NO (GContent break) |
| Bulldozing (canonical model) | Replace clusters with Z copies | Preserved by construction | Preserved by construction | Very High | Theoretically yes, practically prohibitive |
| Omega-squared immediate processing | Process F-obligations immediately in inner chain | Preserved (GContent chain) | Preserved (immediate seed) | High | YES (best candidate) |
| Constant family | Same MCS everywhere | Trivially by T-axiom | Fails (F(psi) =/= psi) | Low | NO |

### Why Omega-Squared is Superior

The omega-squared approach avoids the DAG linearization problem entirely by NOT trying to embed witness graph nodes into the final BFMCS. Instead:

1. Build a standard GContent chain (handles forward_G and backward_H)
2. When F(psi) appears at the current MCS, process it IMMEDIATELY as the next inner step
3. The seed {psi} union GContent(current) is consistent because F(psi) is still alive (no intervening Lindenbaum can kill it if we process immediately)
4. The inner step's MCS is a Lindenbaum extension of the seed, so psi is in it AND GContent continuity is maintained

**Key advantage**: No need to embed the witness graph's complex DAG structure into Int. The witness graph becomes unnecessary at the final construction level -- its role was to motivate the approach and prove seed consistency, but the actual BFMCS is a fresh GContent chain with immediate F-processing.

**Key risk**: The "immediate processing" still requires careful formalization. At each outer step n:
- Multiple F-obligations may be alive simultaneously
- They must be processed one-at-a-time (single-formula seed is consistent; multi-formula seed may not be)
- The inner chain processes all live F-obligations sequentially
- Each inner step processes one F-obligation using {psi_i} union GContent(previous_inner_MCS)
- F(psi_i) must still be alive at the inner step -- this holds because the inner chain propagates GContent, and F(psi_i) was alive at the outer MCS which is the starting point of the inner chain

**Wait**: The inner chain propagates GContent, not F-content. So F(psi_i) from the outer MCS may be killed by an inner Lindenbaum step. Unless we process ALL F-obligations BEFORE any pure GContent extension.

**The correct ordering within each inner chain**:
1. Start from outer MCS M_n (where F(psi_1), F(psi_2), ... are alive)
2. Inner step 1: extend {psi_1} union GContent(M_n). Since F(psi_1) in M_n, this seed is consistent. Result: M_{n,1} with psi_1 in it.
3. Inner step 2: extend {psi_2} union GContent(M_{n,1}). We need F(psi_2) in M_{n,1} or at least the seed to be consistent. Since F(psi_2) in M_n and GContent(M_n) subset M_{n,1}, and M_{n,1} might or might not contain F(psi_2)...

**This is the multi-formula problem again.** Processing psi_1 first may kill F(psi_2) via Lindenbaum.

**Resolution**: Process only ONE F-obligation per outer step. At outer step n, the dovetailing enumeration selects ONE pair (t, psi), and if F(psi) is alive at M_n, immediately extend with {psi} union GContent(M_n). This is EXACTLY what the enriched chain already does -- the problem is that by the time the enumeration reaches psi, F(psi) may have been killed at an earlier outer step.

**The TRUE fix**: At each outer step n, check ALL alive F-obligations and process the FIRST ONE that is still alive. Since the number of formulas in the Fischer-Ladner closure is finite, this terminates. After processing, mark it as done and move to the next outer step.

But this requires a finite "alive F-obligations" check at each step, which is non-trivial to formalize because the set of F-obligations depends on the current MCS (which is itself built by the construction).

## Summary of Key Findings

1. **Tree unraveling is not applicable** to bidirectional tense logics. The technique preserves only forward-looking modal formulas. Past operators require the inverse relation, which is destroyed by unraveling.

2. **DAG linearization via topological sort + gap-fill** fails because GContent continuity breaks at witness-node insertion points. The witness MCS extends GContent of a different source than the gap-fill predecessor.

3. **Bulldozing** (from the canonical model literature) is the theoretically correct technique for linearizing tense logic models, but it operates on the full canonical model (all MCS), not a bottom-up witness graph. Adapting it would essentially mean rebuilding the completeness proof from scratch using canonical model methods rather than the current step-by-step approach.

4. **Omega-squared with immediate processing remains the most practical path**, but the inner-chain multi-formula problem needs careful handling. The recommended approach: process one F-obligation per step using dovetailing, but ensure the construction visits each formula INFINITELY OFTEN (standard dovetailing property) so that F(psi) will eventually be checked while still alive.

5. **The key missing insight** may be that F-obligations do NOT need to be processed at a specific step -- they need to be processed at ANY step where F(psi) is still alive. If the construction checks F(psi) at infinitely many steps, and F(psi) persists for at least finitely many steps before potentially being killed, then there exists a step where F(psi) is checked AND alive. But can we prove F(psi) persists for at least one step? Not necessarily -- G(neg psi) could enter at the very next Lindenbaum extension.

6. **Mathlib infrastructure available**: `LinearExtension` provides a linear order extending any partial order (relevant if topological sort approach were viable). `ReflTransGen` provides reflexive-transitive closure (relevant for multi-edge path propagation). Neither directly solves the core problem.

## Confidence Level

**Medium** (55-65%)

**Justification**: The analysis conclusively rules out tree unraveling and DAG linearization as approaches. The literature review confirms that the standard technique (bulldozing) operates at a different abstraction level than the current codebase's bottom-up approach. The omega-squared approach remains the best candidate, but significant formalization challenges remain, particularly around the multi-formula problem in inner chains. The confidence is not higher because:

1. Every approach analyzed ultimately encounters the same F-persistence obstacle
2. The "process immediately" strategy has been proposed in multiple prior reports but not yet successfully formalized
3. The gap between mathematical intuition ("process F before it dies") and formal proof ("prove F hasn't died yet") remains substantial
4. The estimated effort (24-48 hours per research-015) has not decreased with this analysis

## References

- Blackburn, de Rijke, Venema. "Modal Logic." Cambridge University Press, 2001. (Tree unraveling, bulldozing)
- Goldblatt. "Logics of Time and Computation." CSLI Lecture Notes, 1992. (Tense logic completeness)
- Venema. "Temporal Logic" (Chapter 10 in Handbook of Modal Logic). (Bulldozing, Lin.Z completeness)
- Gabbay, Hodkinson, Reynolds. "Temporal Logic." Oxford, 1994. (Step-by-step method)
- Segerberg. "Modal Logics with Linear Alternative Relations." Theoria, 1970. (Original bulldozing technique)
- Goranko, Otto. "Model Theory of Modal Logic" (Chapter 5 in Handbook of Modal Logic). (Tree model property)
- `Mathlib.Order.Extension.Linear` -- `LinearExtension`, `toLinearExtension` (Lean 4 Mathlib)
- `Mathlib.Logic.Relation` -- `ReflTransGen` (Lean 4 Mathlib)
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` -- witness graph infrastructure
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- current chain construction
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-015-teammate-a-findings.md` -- prior analysis
