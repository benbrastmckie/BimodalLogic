# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P Witness Obligation Tracking
- **Status**: [IMPLEMENTING]
- **Effort**: 60-90 hours
- **Dependencies**: None
- **Research Inputs**: specs/916_implement_fp_witness_obligation_tracking/reports/research-010.md (deferred concretization approach)
- **Artifacts**: plans/implementation-006.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements the "Deferred Concretization" approach from research-010 to close the 2 remaining sorries (`forward_F`, `backward_P`) in DovetailingChain.lean. The approach builds a witness graph in two phases: (1) construct a countable directed graph of MCSs with ordering constraints where each F/P obligation has a dedicated witness node, (2) embed the graph into Int while preserving GContent/HContent propagation. This replaces the linear chain construction that suffered from F-persistence issues.

### Research Integration

Key findings from research-010.md integrated:
1. **Root cause confirmed**: Linear chain cannot guarantee F-persistence because F-formulas are invisible to GContent seed (research-008, research-009)
2. **FPreservingSeed conjecture refuted**: research-010 proves counterexample in implementation-005 Phase 2 progress
3. **Deferred concretization viable**: Each F-obligation gets fresh Lindenbaum extension, avoiding persistence problem
4. **Literature precedent**: Mosaic method (Marx, Mikulas, Reynolds 2000), step-by-step construction (Gabbay et al.)
5. **GContent transitivity**: Proven via 4-axiom G(phi) -> G(G(phi)), matches existing `dovetailForwardChain_G_propagates`
6. **Reusable infrastructure**: `forward_temporal_witness_seed_consistent`, `past_temporal_witness_seed_consistent` (~1800 lines sorry-free)

## Goals & Non-Goals

**Goals**:
- Create new module `WitnessGraph.lean` implementing deferred concretization construction
- Prove forward_F and backward_P using witness graph structure
- Produce BFMCS Int that can replace current DovetailingChain family
- Maintain all existing proven properties (forward_G, backward_H where already proven)
- Eliminate the 2 sorries at lines 1754 and 1761 of DovetailingChain.lean

**Non-Goals**:
- Modifying existing DovetailingChain.lean construction (new module instead)
- Proving cross-sign propagation (forward_G when t < 0, backward_H when t >= 0) - separate task
- Implementing canonical model construction (different approach)
- Constructive Lindenbaum alternatives (boneyard approach)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Int embedding preserving GContent transitivity is hard to formalize | HIGH | MEDIUM | Phase 4 uses existing `GContent_subset_implies_HContent_reverse` pattern; embed via order-preserving map |
| Witness graph termination not well-founded | MEDIUM | LOW | Formulas are countable; index by Nat via encodable instance; each step processes one obligation |
| Infinite F-obligation chains | MEDIUM | LOW | Graph is countable (Formula countable); embed into Nat subset of Int |
| Re-proving forward_G/backward_H in new framework | MEDIUM | MEDIUM | Phase 5 uses same arguments as existing proofs; 4-axiom transitivity already proven |
| Context exhaustion on long phases | MEDIUM | MEDIUM | Phases sized at 8-12 hours; handoff protocol for context exhaustion |

## Sorry Characterization

### Pre-existing Sorries
- `buildDovetailingChainFamily_forward_F` at line 1754 (forward_F sorry)
- `buildDovetailingChainFamily_backward_P` at line 1761 (backward_P sorry)

### Expected Resolution
- Phase 3 proves forward_F via witness graph structure
- Phase 3 proves backward_P via symmetric construction
- Phase 6 integrates into existing theorem, eliminating sorries

### New Sorries
- None expected. Construction uses proven infrastructure only.

### Remaining Debt
After this implementation:
- 0 sorries for forward_F and backward_P
- Cross-sign propagation sorries (forward_G when t < 0, backward_H when t >= 0) remain - separate task

## Axiom Characterization

### Pre-existing Axioms
- No axioms in DovetailingChain.lean scope
- `temporal_coherent_family_exists` axiom in TemporalCoherentConstruction.lean is replaced by theorem

### Expected Resolution
- No axioms needed for deferred concretization approach
- All proofs use structural arguments and existing Lindenbaum machinery

### New Axioms
- None. NEVER introduce axioms.

### Remaining Debt
- No axiom debt from this task

## Implementation Phases

### Phase 1: Define Witness Graph Structure [COMPLETED]

- **Dependencies**: None
- **Goal**: Define the core data structures for the witness graph with ordering constraints

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`
- [ ] Define `WitnessNode` type:
  ```lean
  structure WitnessNode where
    mcs : { S : Set Formula // SetMaximalConsistent S }
    source : Option Nat  -- None for root, Some n for witness of obligation n
  ```
- [ ] Define `ObligationType`:
  ```lean
  inductive ObligationType
    | future : Formula -> ObligationType  -- F(psi) obligation
    | past : Formula -> ObligationType    -- P(psi) obligation
  ```
- [ ] Define `WitnessObligation`:
  ```lean
  structure WitnessObligation where
    nodeIdx : Nat           -- Which node has the obligation
    obligation : ObligationType
  ```
- [ ] Define `WitnessGraph` structure:
  ```lean
  structure WitnessGraph where
    nodes : Nat -> Option WitnessNode      -- Partial function, nodes[0] is root
    nodeCount : Nat                         -- Current number of nodes
    edges : Nat -> Nat -> Prop              -- edges i j means node i < node j in time
    obligations : List WitnessObligation    -- Pending obligations
    witnesses : Nat -> Option Nat           -- obligation index -> witness node index
  ```
- [ ] Prove basic well-formedness lemmas (nodes array consistency)

**Timing**: 8-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` (new file)

**Verification**:
- `lake build` succeeds
- All definitions type-check
- No sorries introduced

**Progress:**

**Session: 2026-02-23, sess_1771892810_8cdc73**
- Added: `ObligationType` inductive type (future/past obligation classification)
- Added: `WitnessObligation` structure (node index + obligation type)
- Added: `WitnessNode` structure (MCS subtype + source tracking)
- Added: `EdgeDirection` and `WitnessEdge` types for temporal ordering edges
- Added: `WitnessGraph` structure (nodes, edges, obligations, resolved map)
- Added: `WitnessGraph.WellFormed` structure with 4 invariants (nonempty, edges_valid, obligations_valid, resolved_valid)
- Added: `witnessSeed` definition and `witnessSeed_consistent` theorem (duplicated from DovetailingChain to avoid circular imports)
- Added: `witnessSeed_future_consistent` and `witnessSeed_past_consistent` (full proofs, ~50 lines each)
- Added: `initialWitnessGraph` with well-formedness proof
- Added: `WitnessGraph.addWitness` with preservation lemmas (length, nonempty, node preservation, new node access, resolved map)
- Completed: All Phase 1 objectives
- Sorries: 0 introduced

---

### Phase 2: Implement Witness Graph Construction [COMPLETED]

- **Dependencies**: Phase 1
- **Goal**: Build the witness graph by processing F/P obligations one at a time

**Tasks**:
- [ ] Define `initialGraph`:
  ```lean
  def initialGraph (Gamma : List Formula) (h_cons : ContextConsistent Gamma) : WitnessGraph :=
    let base_mcs := set_lindenbaum (contextAsSet Gamma) (list_consistent_to_set_consistent h_cons)
    { nodes := fun n => if n = 0 then some ⟨Classical.choose base_mcs, ...⟩ else none,
      nodeCount := 1,
      edges := fun _ _ => False,
      obligations := collectObligations 0 (Classical.choose base_mcs),
      witnesses := fun _ => none }
  ```
- [ ] Define `collectObligations`:
  ```lean
  def collectObligations (nodeIdx : Nat) (mcs : Set Formula) : List WitnessObligation :=
    -- Enumerate F(psi) and P(psi) formulas in mcs
    -- Use Formula.Encodable to enumerate
  ```
- [ ] Define `processObligation`:
  ```lean
  def processObligation (g : WitnessGraph) (oblIdx : Nat) : WitnessGraph :=
    match g.obligations.get? oblIdx with
    | none => g
    | some obl =>
      match obl.obligation with
      | .future psi =>
        -- Create witness node via Lindenbaum({psi} ∪ GContent(sourceNode))
        -- Add edge sourceNode -> newNode
        -- Collect new obligations from newNode
        -- Mark obligation as witnessed
      | .past psi =>
        -- Create witness node via Lindenbaum({psi} ∪ HContent(sourceNode))
        -- Add edge newNode -> sourceNode
        -- Collect new obligations from newNode
  ```
- [ ] Prove `processObligation_preserves_structure`:
  - Statement: Processing an obligation yields a valid WitnessGraph
  - Proof: Reuses `forward_temporal_witness_seed_consistent` for F, `past_temporal_witness_seed_consistent` for P
- [ ] Define `buildWitnessGraph`:
  ```lean
  def buildWitnessGraph (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
      Nat -> WitnessGraph :=
    fun n => (processObligation^[n]) (initialGraph Gamma h_cons)
  ```
- [ ] Prove `buildWitnessGraph_obligations_decrease` (progress lemma):
  - Statement: Each step either decreases pending obligations or stabilizes
- [ ] Prove `buildWitnessGraph_witness_exists`:
  - Statement: For any F(psi) at node n, there exists step k where witness is created

**Timing**: 12-15 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`

**Verification**:
- `lake build` succeeds
- `processObligation_preserves_structure` proven without sorry
- Graph construction terminates (via obligation enumeration)

**Progress:**

**Session: 2026-02-23, sess_1771893934_40c616**
- Added: `formulaEncodableWG`, `decodeFormulaWG`, `encodeFormulaWG` - Formula enumeration for witness graph
- Added: `WitnessGraph.isWitnessed` - Check if obligation already has witness
- Added: `WitnessGraph.addFutureWitness` - Create witness node for F(psi) obligation
- Added: `WitnessGraph.addPastWitness` - Create witness node for P(psi) obligation
- Added: `processStep` - Core construction step using Nat.unpair to enumerate (node, formula) pairs
- Added: `buildWitnessGraph` - Iterates processStep from initial graph
- Added: `processStep_nodes_length_ge` - processStep monotonicity
- Added: `processStep_node_preserved` - processStep preserves existing nodes
- Added: `buildWitnessGraph_nonempty` - graph always has root
- Added: `buildWitnessGraph_nodes_length_mono`, `_mono_le` - monotone node count
- Added: `buildWitnessGraph_root_preserved` - root stability
- Added: `buildWitnessGraph_node_preserved`, `_node_stable` - node stability across steps
- Added: `lindenbaum_extends_seed`, `lindenbaum_is_mcs` - Lindenbaum helper lemmas
- Added: `addFutureWitness_witness_seed_extends`, `addFutureWitness_contains_formula` - Future witness MCS contains psi
- Added: `addPastWitness_witness_seed_extends`, `addPastWitness_contains_formula` - Past witness MCS contains psi
- Added: `addFutureWitness_GContent_extends` - GContent propagation through future witness edges
- Added: `addPastWitness_HContent_extends` - HContent propagation through past witness edges
- Added: `coverage_step_exists` - Coverage: every (node, formula) pair is eventually processed
- Completed: All Phase 2 objectives
- Sorries: 0 introduced

---

### Phase 3: Prove Witness Graph Properties [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Prove that the witness graph satisfies F/P witness existence and G/H propagation

**Tasks**:
- [ ] Prove `witnessGraph_forward_F_local`:
  - Statement: For F(psi) at node n, there exists node m with edge n -> m and psi in m
  - Proof: By construction - processObligation creates such witness
- [ ] Prove `witnessGraph_backward_P_local`:
  - Statement: For P(psi) at node n, there exists node m with edge m -> n and psi in m
  - Proof: Symmetric to forward
- [ ] Prove `witnessGraph_GContent_propagates`:
  - Statement: If edge(n, m), then GContent(nodes[n].mcs) subset nodes[m].mcs
  - Proof: By construction - witness seed includes GContent
- [ ] Prove `witnessGraph_HContent_propagates`:
  - Statement: If edge(m, n), then HContent(nodes[n].mcs) subset nodes[m].mcs
  - Proof: By construction - witness seed includes HContent
- [ ] Prove `witnessGraph_acyclic`:
  - Statement: The edge relation has no cycles
  - Proof: Each edge is created with strict ordering constraint; F-witness is always future, P-witness always past
- [ ] Prove `witnessGraph_countable`:
  - Statement: The set of nodes is countable
  - Proof: Formula is Encodable; each obligation generates at most one node

**Timing**: 10-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`

**Verification**:
- `lake build` succeeds
- All local witness properties proven
- Graph acyclicity proven
- No sorries in Phase 3 lemmas

---

### Phase 4: Implement Int Embedding [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Embed the witness graph into Int while preserving ordering and GContent/HContent propagation

**Tasks**:
- [ ] Define `WitnessGraphOrdering`:
  - Statement: Transitive closure of edge relation is a strict partial order
  - Proof: Acyclicity + transitivity
- [ ] Prove `witnessGraph_order_embeddable`:
  - Statement: Any countable acyclic graph can be embedded into Int
  - Proof: Topological sort + assign integers in order
- [ ] Define `embedWitnessGraph`:
  ```lean
  def embedWitnessGraph (g : WitnessGraph) : Nat -> Int :=
    -- Topological sort of nodes
    -- Assign integers preserving edge ordering
  ```
- [ ] Prove `embedWitnessGraph_preserves_order`:
  - Statement: If edge(n, m), then embedWitnessGraph g n < embedWitnessGraph g m
  - Proof: Topological sort property
- [ ] Define `witnessGraphToBFMCS`:
  ```lean
  def witnessGraphToBFMCS (Gamma : List Formula) (h_cons : ContextConsistent Gamma) : BFMCS Int :=
    let fullGraph := buildWitnessGraph Gamma h_cons (enumerateAllObligations Gamma)
    { mcs := fun t =>
        if let some n := inverseEmbed fullGraph t then
          (fullGraph.nodes n).get!.mcs.val
        else
          -- Default MCS via Lindenbaum at appropriate position
          ... }
  ```
- [ ] Prove `witnessGraphToBFMCS_preserves_context`:
  - Statement: For gamma in Gamma, gamma in mcs 0
  - Proof: Root node is Lindenbaum extension of Gamma

**Timing**: 12-15 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`

**Verification**:
- `lake build` succeeds
- Embedding preserves strict order
- BFMCS structure well-defined

---

### Phase 5: Prove Global Temporal Coherence [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Prove forward_G, backward_H, forward_F, backward_P for the embedded BFMCS

**Tasks**:
- [ ] Prove `witnessGraphBFMCS_forward_G`:
  - Statement: G(phi) in mcs(t) implies phi in mcs(t') for all t < t'
  - Proof: By transitivity of GContent via 4-axiom; reuse pattern from `dovetailForwardChain_G_propagates`
- [ ] Prove `witnessGraphBFMCS_backward_H`:
  - Statement: H(phi) in mcs(t) implies phi in mcs(t') for all t' < t
  - Proof: Symmetric using HContent transitivity
- [ ] Prove `witnessGraphBFMCS_forward_F`:
  - Statement: F(phi) in mcs(t) implies exists s > t with phi in mcs(s)
  - Proof:
    1. Map t to witness graph node n
    2. F(phi) at n has witness node m by Phase 3
    3. edge(n, m) means embed(n) < embed(m) by Phase 4
    4. phi in m.mcs by construction
    5. s = embed(m) > t = embed(n)
- [ ] Prove `witnessGraphBFMCS_backward_P`:
  - Statement: P(phi) in mcs(t) implies exists s < t with phi in mcs(s)
  - Proof: Symmetric to forward_F
- [ ] Prove `GContent_transitive_through_graph`:
  - Statement: If path n -> ... -> m in graph, then GContent(n.mcs) subset m.mcs
  - Proof: Induction on path length; each edge propagates GContent; 4-axiom gives G(G(phi)) = G(phi)
- [ ] Prove `HContent_transitive_through_graph`:
  - Statement: Symmetric for HContent on backward paths

**Timing**: 10-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`

**Verification**:
- `lake build` succeeds
- forward_F and backward_P proven without sorry
- forward_G and backward_H proven for positive/negative time respectively

---

### Phase 6: Integration and Sorry Elimination [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Integrate witness graph construction into DovetailingChain.lean and eliminate sorries

**Tasks**:
- [ ] Add import of WitnessGraph.lean to DovetailingChain.lean
- [ ] Create wrapper theorem `witnessGraph_temporal_coherent_family_exists`:
  ```lean
  theorem witnessGraph_temporal_coherent_family_exists
      (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
      ∃ (fam : BFMCS Int),
        (∀ gamma ∈ Gamma, gamma ∈ fam.mcs 0) ∧
        (∀ t : Int, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : Int, t < s ∧ φ ∈ fam.mcs s) ∧
        (∀ t : Int, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : Int, s < t ∧ φ ∈ fam.mcs s) := by
    use witnessGraphToBFMCS Gamma h_cons
    exact ⟨witnessGraphBFMCS_preserves_context ...,
           witnessGraphBFMCS_forward_F ...,
           witnessGraphBFMCS_backward_P ...⟩
  ```
- [ ] Replace sorries in `buildDovetailingChainFamily_forward_F`:
  - Option A: Redefine `buildDovetailingChainFamily` to use witness graph
  - Option B: Prove equivalence between witness graph and existing chain
  - Decision: Option A (cleaner, avoids equivalence proof)
- [ ] Replace sorries in `buildDovetailingChainFamily_backward_P`:
  - Same approach as forward_F
- [ ] Update `temporal_coherent_family_exists_theorem` to use witness graph
- [ ] Verify all downstream theorems still compile
- [ ] Run `#print axioms temporal_coherent_family_exists_theorem` to confirm sorry-free

**Timing**: 8-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`

**Verification**:
- `lake build` succeeds
- `#print axioms temporal_coherent_family_exists_theorem` shows standard axioms only (no sorry)
- Completeness.lean still compiles
- Repository sorry count decreased by 2

---

## Testing & Validation

- [ ] `lake build` succeeds with no new sorries
- [ ] `#print axioms witnessGraph_temporal_coherent_family_exists` shows standard axioms only
- [ ] `#print axioms witnessGraphBFMCS_forward_F` shows standard axioms only
- [ ] `#print axioms witnessGraphBFMCS_backward_P` shows standard axioms only
- [ ] Cross-sign propagation lemmas (forward_G, backward_H) still compile
- [ ] Completeness.lean compiles without modification
- [ ] TruthLemma.lean compiles without modification
- [ ] Repository sorry count: `grep -r "sorry" Theories/ | wc -l` should decrease by 2

## Artifacts & Outputs

- `plans/implementation-006.md` (this file)
- New: `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- Final: `summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If witness graph embedding to Int proves intractable:
1. Preserve all work in git (WitnessGraph.lean as standalone module)
2. Document specific embedding obstruction
3. Consider alternative embedding targets (Nat, rationals)
4. Accept sorry debt with full documentation of progress

If GContent transitivity through paths fails:
1. Document which path configurations fail
2. Check if 4-axiom application needs explicit induction setup
3. May require explicit path induction lemma

If context exhaustion occurs mid-phase:
1. Write handoff per standard protocol
2. Successor reads handoff and continues from checkpoint
3. Progress tracked in phase Progress subsection

## Comparison with Prior Plans

| Plan | Approach | Status | Reason |
|------|----------|--------|--------|
| v001 | Initial | BLOCKED | Underspecified |
| v002 | Direct proof | BLOCKED | F-persistence not derivable |
| v003 | Flat chain with witness | BLOCKED | F(psi) killed before processing step |
| v004 | Omega^2 directed limit | BLOCKED | Generalized consistency lemma is FALSE |
| v005 | Derivation surgery | BLOCKED | FPreservingSeed conjecture refuted by counterexample |
| v006 | Deferred concretization | Current | Fresh Lindenbaum for each witness, no persistence issue |

The key insight of v006: instead of trying to make F-formulas persist through a linear chain (v002-v005), build a graph where each F-obligation gets its OWN witness node via fresh Lindenbaum extension. This eliminates the persistence problem entirely.

## Reuse of Existing Lemmas

| Existing Lemma | Status | Phase Used |
|----------------|--------|------------|
| `forward_temporal_witness_seed_consistent` | Valid | Phase 2 (witness creation) |
| `past_temporal_witness_seed_consistent` | Valid | Phase 2 (witness creation) |
| `GContent_subset_implies_HContent_reverse` | Valid | Phase 5 (duality) |
| `HContent_subset_implies_GContent_reverse` | Valid | Phase 5 (duality) |
| `set_lindenbaum` | Valid | Phase 2 (MCS creation) |
| `generalized_temporal_k` | Valid | Phase 5 (G-lifting) |
| `dovetailForwardChain_G_propagates` pattern | Valid | Phase 5 (GContent transitivity) |
