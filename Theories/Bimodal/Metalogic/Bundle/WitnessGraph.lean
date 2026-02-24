import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Theorems.Combinators
import Mathlib.Logic.Encodable.Basic

/-!
# Witness Graph Construction for F/P Obligation Resolution

This module implements the "Deferred Concretization" approach to close the
`forward_F` and `backward_P` sorries in `DovetailingChain.lean`.

## Overview

Instead of maintaining F-formula persistence through a linear chain (which fails
because F-formulas are invisible to GContent seeds), we build a directed graph
where each F/P obligation gets its OWN witness node via fresh Lindenbaum extension.

### Key Insight

The linear chain construction suffers from F-persistence issues: when building
M_0, M_1, M_2, ..., an F(psi) formula at M_0 may not persist to the node where
its witness is needed. The witness graph avoids this by creating a fresh MCS for
each obligation directly from the source node, rather than propagating through
intermediate nodes.

## Construction Outline

1. **Phase 1** (this file): Define core data structures (WitnessNode, WitnessObligation,
   WitnessGraph) with well-formedness conditions.
2. **Phase 2**: Build the witness graph by processing obligations one at a time.
3. **Phase 3**: Prove local witness properties (F/P witness existence, GContent/HContent
   propagation).
4. **Phase 4**: Embed the witness graph into Int.
5. **Phase 5**: Prove global temporal coherence (forward_G, backward_H, forward_F,
   backward_P).
6. **Phase 6**: Integrate into DovetailingChain.lean to eliminate sorries.

## References

- Task 916 plan v006 (specs/916_implement_fp_witness_obligation_tracking/plans/implementation-006.md)
- Research report v010 (deferred concretization approach)
- DovetailingChain.lean: forward_temporal_witness_seed_consistent, past_temporal_witness_seed_consistent
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Core Type Definitions

### ObligationType

Classifies temporal obligations as either future (F) or past (P).
An F-obligation requires a strictly future witness; a P-obligation requires
a strictly past witness.
-/

/--
The type of temporal obligation arising from an MCS.

- `future psi`: The formula `F(psi)` is in some MCS, requiring a strictly future
  witness node containing `psi`.
- `past psi`: The formula `P(psi)` is in some MCS, requiring a strictly past
  witness node containing `psi`.
-/
inductive ObligationType where
  /-- F(psi) obligation: need a future witness containing psi -/
  | future : Formula -> ObligationType
  /-- P(psi) obligation: need a past witness containing psi -/
  | past : Formula -> ObligationType
  deriving DecidableEq, BEq

/-!
### WitnessObligation

Pairs a node index with an obligation type, recording which node generated
the obligation and what kind of witness is needed.
-/

/--
A temporal witness obligation: node `nodeIdx` contains F(psi) or P(psi),
requiring a witness node to be created.

The `nodeIdx` field identifies the source node in the witness graph.
The `obligation` field specifies whether a future or past witness is needed,
and for which formula.
-/
structure WitnessObligation where
  /-- Index of the node that has this obligation -/
  nodeIdx : Nat
  /-- The type of obligation (future or past, with formula) -/
  obligation : ObligationType
  deriving DecidableEq, BEq

/-!
### WitnessNode

A node in the witness graph, wrapping an MCS with metadata about its origin.
The `source` field tracks whether this is the root node (None) or a witness
created to resolve a specific obligation (Some oblIdx).
-/

/--
A node in the witness graph.

Each node wraps a maximal consistent set (MCS) and records how it was created:
- The root node has `source = none`
- A witness node has `source = some oblIdx` indicating which obligation it resolves

**Design Note**: We store the MCS as a subtype `{ S : Set Formula // SetMaximalConsistent S }`
to carry the proof of maximal consistency with the data. This avoids separate proof
obligations when extracting MCS properties.
-/
structure WitnessNode where
  /-- The maximal consistent set at this node -/
  mcs : { S : Set Formula // SetMaximalConsistent S }
  /-- None for root node, Some n for witness of obligation n -/
  source : Option Nat

/-!
### EdgeDirection

Encodes the temporal direction of an edge in the witness graph.
Forward edges go from source to witness (for F-obligations),
backward edges go from witness to source (for P-obligations).
-/

/--
Direction of an edge in the witness graph.

- `forward`: Source node is in the past of witness node (for F-obligations)
- `backward`: Witness node is in the past of source node (for P-obligations)
-/
inductive EdgeDirection where
  /-- Forward edge: source < witness in temporal order -/
  | forward : EdgeDirection
  /-- Backward edge: witness < source in temporal order -/
  | backward : EdgeDirection
  deriving DecidableEq, BEq

/-!
### WitnessEdge

An edge in the witness graph connecting a source node to its witness.
The direction indicates the temporal ordering constraint.
-/

/--
An edge in the witness graph.

Connects the source node (where the obligation originates) to the witness node
(where the witnessing formula lives). The direction encodes the temporal ordering:
- `forward`: source is strictly before witness (F-obligation)
- `backward`: witness is strictly before source (P-obligation)
-/
structure WitnessEdge where
  /-- Index of the source node (where obligation originates) -/
  src : Nat
  /-- Index of the destination/witness node -/
  dst : Nat
  /-- Direction of the edge (temporal ordering) -/
  dir : EdgeDirection
  deriving DecidableEq, BEq

/-!
### WitnessGraph

The complete witness graph structure. This captures the state of the graph
after all obligations have been processed.

**Design Decision**: We use a `List WitnessNode` for nodes (finite, ordered by
construction step) and `List WitnessEdge` for edges. This gives us concrete
finite structures amenable to induction, rather than partial functions on Nat.

The `obligations` list tracks all obligations discovered during construction.
The `resolved` field maps obligation indices to their witness node indices.
-/

/--
A witness graph for temporal obligation resolution.

The graph is built incrementally: starting from a root node (the Lindenbaum
extension of the input context), each F/P obligation in any node generates a
new witness node via fresh Lindenbaum extension.

**Invariants** (enforced by well-formedness conditions):
- `nodes` is non-empty (root node at index 0)
- Each edge connects valid node indices
- Each resolved obligation maps to a valid witness node
- Edge directions are consistent with obligation types
-/
structure WitnessGraph where
  /-- All nodes in the graph (index 0 is root) -/
  nodes : List WitnessNode
  /-- Directed edges encoding temporal ordering constraints -/
  edges : List WitnessEdge
  /-- All discovered obligations -/
  obligations : List WitnessObligation
  /-- Map from obligation index to witness node index (None if unresolved) -/
  resolved : Nat -> Option Nat

/-!
## Well-Formedness Conditions

These predicates and lemmas ensure structural integrity of a WitnessGraph.
-/

/-- A witness graph is non-empty (has at least the root node). -/
def WitnessGraph.nonempty (g : WitnessGraph) : Prop :=
  g.nodes.length > 0

/-- An edge refers to valid node indices. -/
def WitnessEdge.valid (e : WitnessEdge) (nodeCount : Nat) : Prop :=
  e.src < nodeCount ∧ e.dst < nodeCount

/-- All edges in the graph refer to valid node indices. -/
def WitnessGraph.edgesValid (g : WitnessGraph) : Prop :=
  ∀ e ∈ g.edges, e.valid g.nodes.length

/-- All obligations refer to valid node indices. -/
def WitnessGraph.obligationsValid (g : WitnessGraph) : Prop :=
  ∀ obl ∈ g.obligations, obl.nodeIdx < g.nodes.length

/-- All resolved obligations map to valid witness node indices. -/
def WitnessGraph.resolvedValid (g : WitnessGraph) : Prop :=
  ∀ i : Nat, ∀ j : Nat, g.resolved i = some j → j < g.nodes.length

/-- An edge is consistent with its obligation: F-obligations get forward edges,
P-obligations get backward edges. -/
def WitnessGraph.edgeConsistentWithObligation
    (g : WitnessGraph) (oblIdx : Nat) (e : WitnessEdge) : Prop :=
  match g.obligations[oblIdx]? with
  | some obl =>
    e.src = obl.nodeIdx ∧
    (match obl.obligation with
     | ObligationType.future _ => e.dir = .forward
     | ObligationType.past _ => e.dir = .backward)
  | none => False

/--
A witness graph is well-formed if all structural invariants hold.
-/
structure WitnessGraph.WellFormed (g : WitnessGraph) : Prop where
  /-- The graph has at least one node (the root) -/
  nonempty : g.nonempty
  /-- All edges reference valid nodes -/
  edges_valid : g.edgesValid
  /-- All obligations reference valid nodes -/
  obligations_valid : g.obligationsValid
  /-- All resolved obligations map to valid nodes -/
  resolved_valid : g.resolvedValid

/-!
## Node Accessors

Helper functions for extracting MCS data from witness graph nodes.
-/

/-- Get the MCS set at a node index, or none if out of bounds. -/
def WitnessGraph.nodeAt? (g : WitnessGraph) (i : Nat) : Option WitnessNode :=
  g.nodes[i]?

/-- Get the MCS set at a node index (requires proof of validity). -/
def WitnessGraph.nodeAt (g : WitnessGraph) (i : Nat) (h : i < g.nodes.length) : WitnessNode :=
  g.nodes[i]

/-- The MCS at a valid node index. -/
def WitnessGraph.mcsAt (g : WitnessGraph) (i : Nat) (h : i < g.nodes.length) : Set Formula :=
  (g.nodeAt i h).mcs.val

/-- The MCS at any valid node is maximal consistent. -/
lemma WitnessGraph.mcsAt_is_mcs (g : WitnessGraph) (i : Nat) (h : i < g.nodes.length) :
    SetMaximalConsistent (g.mcsAt i h) :=
  (g.nodeAt i h).mcs.property

/-!
## Obligation Formula Extraction

Extract the witnessed formula from an obligation type.
-/

/-- Get the formula from an obligation type. -/
def ObligationType.formula : ObligationType -> Formula
  | .future psi => psi
  | .past psi => psi

/-- Get the full temporal formula (F(psi) or P(psi)) from an obligation type. -/
def ObligationType.temporalFormula : ObligationType -> Formula
  | .future psi => Formula.some_future psi
  | .past psi => Formula.some_past psi

/-- An obligation is an F-obligation. -/
def ObligationType.isFuture : ObligationType -> Bool
  | .future _ => true
  | .past _ => false

/-- An obligation is a P-obligation. -/
def ObligationType.isPast : ObligationType -> Bool
  | .future _ => false
  | .past _ => true

/-!
## Edge Relation

Define when two nodes are connected by an edge, and the induced temporal ordering.
-/

/-- Node i is a direct predecessor of node j in the witness graph
(there exists a forward edge from i to j or a backward edge from j to i). -/
def WitnessGraph.precedes (g : WitnessGraph) (i j : Nat) : Prop :=
  ∃ e ∈ g.edges,
    (e.src = i ∧ e.dst = j ∧ e.dir = .forward) ∨
    (e.src = j ∧ e.dst = i ∧ e.dir = .backward)

/-- Node i should be temporally before node j based on a specific edge. -/
def WitnessEdge.inducesOrder (e : WitnessEdge) (i j : Nat) : Prop :=
  (e.src = i ∧ e.dst = j ∧ e.dir = .forward) ∨
  (e.src = j ∧ e.dst = i ∧ e.dir = .backward)

/-!
## Obligation Collection

Given an MCS, enumerate its F/P obligations.
-/

-- Classical decidability needed for membership checks
attribute [local instance] Classical.propDecidable

/--
Collect F-obligations from an MCS at a given node index.

For each formula F(psi) in the MCS, creates a WitnessObligation recording
that nodeIdx needs a future witness for psi.

**Note**: This returns a (possibly infinite) set of obligations. The actual
construction will process obligations via enumeration using the Encodable instance.
-/
def collectFutureObligations (nodeIdx : Nat) (M : Set Formula) : Set WitnessObligation :=
  { obl | ∃ psi : Formula,
    Formula.some_future psi ∈ M ∧
    obl = ⟨nodeIdx, .future psi⟩ }

/--
Collect P-obligations from an MCS at a given node index.
-/
def collectPastObligations (nodeIdx : Nat) (M : Set Formula) : Set WitnessObligation :=
  { obl | ∃ psi : Formula,
    Formula.some_past psi ∈ M ∧
    obl = ⟨nodeIdx, .past psi⟩ }

/--
All temporal obligations at a node.
-/
def collectAllObligations (nodeIdx : Nat) (M : Set Formula) : Set WitnessObligation :=
  collectFutureObligations nodeIdx M ∪ collectPastObligations nodeIdx M

/-!
## Witness Seed Construction

For an F(psi) obligation at node with MCS M, the witness seed is {psi} union GContent(M).
For a P(psi) obligation at node with MCS M, the witness seed is {psi} union HContent(M).

These definitions mirror `ForwardTemporalWitnessSeed` and `PastTemporalWitnessSeed`
from DovetailingChain.lean, duplicated here to avoid a circular import dependency
(Phase 6 will add an import of WitnessGraph into DovetailingChain).
-/

/--
The seed for creating a witness node for an obligation.

For F(psi) at MCS M: seed = {psi} union GContent(M)
For P(psi) at MCS M: seed = {psi} union HContent(M)

The consistency of these seeds is proven in `witnessSeed_consistent` below,
using the same argument as `forward_temporal_witness_seed_consistent` and
`past_temporal_witness_seed_consistent` in DovetailingChain.lean.
-/
def witnessSeed (M : Set Formula) (obl : ObligationType) : Set Formula :=
  match obl with
  | .future psi => {psi} ∪ GContent M
  | .past psi => {psi} ∪ HContent M

/--
The witnessed formula is in the witness seed.
-/
lemma formula_mem_witnessSeed (M : Set Formula) (obl : ObligationType) :
    obl.formula ∈ witnessSeed M obl := by
  match obl with
  | .future psi => exact Set.mem_union_left _ (Set.mem_singleton psi)
  | .past psi => exact Set.mem_union_left _ (Set.mem_singleton psi)

/--
For F-obligations, GContent(M) is a subset of the witness seed.
-/
lemma GContent_subset_witnessSeed_future (M : Set Formula) (psi : Formula) :
    GContent M ⊆ witnessSeed M (.future psi) :=
  Set.subset_union_right

/--
For P-obligations, HContent(M) is a subset of the witness seed.
-/
lemma HContent_subset_witnessSeed_past (M : Set Formula) (psi : Formula) :
    HContent M ⊆ witnessSeed M (.past psi) :=
  Set.subset_union_right

/--
Forward witness seed consistency: If F(psi) is in an MCS M, then
{psi} union GContent(M) is consistent.

This duplicates `forward_temporal_witness_seed_consistent` from DovetailingChain.lean
to avoid circular imports. The proof is identical: assume inconsistency, apply
deduction theorem to get a derivation of neg(psi), lift via generalized temporal K
to get G(neg(psi)) in M, contradicting F(psi) = neg(G(neg(psi))) in M.
-/
theorem witnessSeed_future_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    SetConsistent (witnessSeed M (.future psi)) := by
  intro L hL_sub ⟨d⟩
  by_cases h_psi_in : psi ∈ L
  · -- Case: psi in L
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)
    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord
    -- Get G chi in M for each chi in L_filt from GContent
    have h_G_filt_in_M : ∀ chi ∈ L_filt, Formula.all_future chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [witnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gcontent
      · exact absurd h_eq h_ne
      · exact h_gcontent
    -- Apply generalized temporal K
    have d_G_neg : (Context.map Formula.all_future L_filt) ⊢ Formula.all_future (Formula.neg psi) :=
      Bimodal.Theorems.generalized_temporal_k L_filt (Formula.neg psi) d_neg
    -- All formulas in G(L_filt) are in M
    have h_G_context_in_M : ∀ phi ∈ Context.map Formula.all_future L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_G_filt_in_M chi h_chi_in
    -- By MCS closure, G(neg psi) in M
    have h_G_neg_in_M : Formula.all_future (Formula.neg psi) ∈ M :=
      set_mcs_closed_under_derivation h_mcs (Context.map Formula.all_future L_filt)
        h_G_context_in_M d_G_neg
    -- Contradiction: F psi = neg(G(neg psi)) is also in M
    have h_F_eq : Formula.some_future psi = Formula.neg (Formula.all_future (Formula.neg psi)) := rfl
    rw [h_F_eq] at h_F
    exact set_consistent_not_both h_mcs.1 (Formula.all_future (Formula.neg psi)) h_G_neg_in_M h_F
  · -- Case: psi not in L, so L subset GContent M subset M
    have h_L_in_M : ∀ chi ∈ L, chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [witnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gcontent
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · have h_G_chi : Formula.all_future chi ∈ M := h_gcontent
        have h_T := DerivationTree.axiom [] ((Formula.all_future chi).imp chi) (Axiom.temp_t_future chi)
        exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G_chi
    exact h_mcs.1 L h_L_in_M ⟨d⟩

/--
Past witness seed consistency: If P(psi) is in an MCS M, then
{psi} union HContent(M) is consistent.

This duplicates `past_temporal_witness_seed_consistent` from DovetailingChain.lean
to avoid circular imports. The proof mirrors the future version, using H and P
instead of G and F.
-/
theorem witnessSeed_past_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    SetConsistent (witnessSeed M (.past psi)) := by
  intro L hL_sub ⟨d⟩
  by_cases h_psi_in : psi ∈ L
  · -- Case: psi in L
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)
    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord
    -- Get H chi in M for each chi in L_filt from HContent
    have h_H_filt_in_M : ∀ chi ∈ L_filt, Formula.all_past chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [witnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_hcontent
      · exact absurd h_eq h_ne
      · exact h_hcontent
    -- Apply generalized past K
    have d_H_neg : (Context.map Formula.all_past L_filt) ⊢ Formula.all_past (Formula.neg psi) :=
      Bimodal.Theorems.generalized_past_k L_filt (Formula.neg psi) d_neg
    -- All formulas in H(L_filt) are in M
    have h_H_context_in_M : ∀ phi ∈ Context.map Formula.all_past L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_H_filt_in_M chi h_chi_in
    -- By MCS closure, H(neg psi) in M
    have h_H_neg_in_M : Formula.all_past (Formula.neg psi) ∈ M :=
      set_mcs_closed_under_derivation h_mcs (Context.map Formula.all_past L_filt)
        h_H_context_in_M d_H_neg
    -- Contradiction: P psi = neg(H(neg psi)) is also in M
    have h_P_eq : Formula.some_past psi = Formula.neg (Formula.all_past (Formula.neg psi)) := rfl
    rw [h_P_eq] at h_P
    exact set_consistent_not_both h_mcs.1 (Formula.all_past (Formula.neg psi)) h_H_neg_in_M h_P
  · -- Case: psi not in L, so L subset HContent M subset M
    have h_L_in_M : ∀ chi ∈ L, chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [witnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_hcontent
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · have h_H_chi : Formula.all_past chi ∈ M := h_hcontent
        have h_T := DerivationTree.axiom [] ((Formula.all_past chi).imp chi) (Axiom.temp_t_past chi)
        exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H_chi
    exact h_mcs.1 L h_L_in_M ⟨d⟩

/--
The witness seed is consistent when the obligation's temporal formula is in the MCS.

This is the central consistency result that enables the construction:
- For F(psi): uses `witnessSeed_future_consistent`
- For P(psi): uses `witnessSeed_past_consistent`
-/
theorem witnessSeed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (obl : ObligationType) (h_in : obl.temporalFormula ∈ M) :
    SetConsistent (witnessSeed M obl) := by
  match obl with
  | .future psi => exact witnessSeed_future_consistent M h_mcs psi h_in
  | .past psi => exact witnessSeed_past_consistent M h_mcs psi h_in

/-!
## Initial Graph Construction

The initial graph consists of a single root node (the Lindenbaum extension
of the input context).
-/

/--
Create a single-node witness graph from a root MCS.

The root node is at index 0 with `source = none`. There are no edges and
no resolved obligations. The obligations list will be populated during
graph construction (Phase 2).
-/
def initialWitnessGraph (rootMCS : { S : Set Formula // SetMaximalConsistent S }) :
    WitnessGraph where
  nodes := [⟨rootMCS, none⟩]
  edges := []
  obligations := []
  resolved := fun _ => none

/-- The initial witness graph is non-empty. -/
lemma initialWitnessGraph_nonempty (rootMCS : { S : Set Formula // SetMaximalConsistent S }) :
    (initialWitnessGraph rootMCS).nonempty := by
  simp [initialWitnessGraph, WitnessGraph.nonempty]

/-- The initial witness graph has valid edges (vacuously). -/
lemma initialWitnessGraph_edgesValid (rootMCS : { S : Set Formula // SetMaximalConsistent S }) :
    (initialWitnessGraph rootMCS).edgesValid := by
  intro e h_e
  simp [initialWitnessGraph] at h_e

/-- The initial witness graph has valid obligations (vacuously). -/
lemma initialWitnessGraph_obligationsValid (rootMCS : { S : Set Formula // SetMaximalConsistent S }) :
    (initialWitnessGraph rootMCS).obligationsValid := by
  intro obl h_obl
  simp [initialWitnessGraph] at h_obl

/-- The initial witness graph has valid resolved obligations (vacuously). -/
lemma initialWitnessGraph_resolvedValid (rootMCS : { S : Set Formula // SetMaximalConsistent S }) :
    (initialWitnessGraph rootMCS).resolvedValid := by
  intro i j h_eq
  simp [initialWitnessGraph] at h_eq

/-- The initial witness graph is well-formed. -/
theorem initialWitnessGraph_wellFormed (rootMCS : { S : Set Formula // SetMaximalConsistent S }) :
    WitnessGraph.WellFormed (initialWitnessGraph rootMCS) :=
  ⟨initialWitnessGraph_nonempty rootMCS,
   initialWitnessGraph_edgesValid rootMCS,
   initialWitnessGraph_obligationsValid rootMCS,
   initialWitnessGraph_resolvedValid rootMCS⟩

/-- The root node of the initial graph has the given MCS. -/
lemma initialWitnessGraph_root_mcs (rootMCS : { S : Set Formula // SetMaximalConsistent S }) :
    (initialWitnessGraph rootMCS).nodeAt 0
      (by simp [initialWitnessGraph]) =
      ⟨rootMCS, none⟩ := by
  simp [WitnessGraph.nodeAt, initialWitnessGraph]

/-!
## Graph Extension (adding a witness node)

These definitions support adding a witness node to resolve an obligation.
Used in Phase 2 to build the full graph incrementally.
-/

/--
Extend a witness graph by adding a new witness node and corresponding edge.

Given:
- An existing well-formed graph `g`
- An obligation index `oblIdx` to resolve
- A new MCS `witnessMCS` (obtained via Lindenbaum on the witness seed)

Returns a new graph with:
- The witness node appended to the node list
- A new edge between the source node and the witness node
- The obligation marked as resolved
-/
def WitnessGraph.addWitness (g : WitnessGraph) (oblIdx : Nat)
    (obl : WitnessObligation) (witnessMCS : { S : Set Formula // SetMaximalConsistent S })
    (edgeDir : EdgeDirection) : WitnessGraph where
  nodes := g.nodes ++ [⟨witnessMCS, some oblIdx⟩]
  edges := g.edges ++ [⟨obl.nodeIdx, g.nodes.length, edgeDir⟩]
  obligations := g.obligations
  resolved := fun i => if i = oblIdx then some g.nodes.length else g.resolved i

/-- The node count increases by 1 after adding a witness. -/
lemma WitnessGraph.addWitness_length (g : WitnessGraph) (oblIdx : Nat)
    (obl : WitnessObligation) (witnessMCS : { S : Set Formula // SetMaximalConsistent S })
    (edgeDir : EdgeDirection) :
    (g.addWitness oblIdx obl witnessMCS edgeDir).nodes.length = g.nodes.length + 1 := by
  simp [addWitness]

/-- Adding a witness preserves non-emptiness. -/
lemma WitnessGraph.addWitness_nonempty (g : WitnessGraph) (oblIdx : Nat)
    (obl : WitnessObligation) (witnessMCS : { S : Set Formula // SetMaximalConsistent S })
    (edgeDir : EdgeDirection) (_h_ne : g.nonempty) :
    (g.addWitness oblIdx obl witnessMCS edgeDir).nonempty := by
  simp [nonempty, addWitness]

/-- Existing nodes are preserved when adding a witness. -/
lemma WitnessGraph.addWitness_preserves_node (g : WitnessGraph) (oblIdx : Nat)
    (obl : WitnessObligation) (witnessMCS : { S : Set Formula // SetMaximalConsistent S })
    (edgeDir : EdgeDirection) (i : Nat) (h : i < g.nodes.length) :
    (g.addWitness oblIdx obl witnessMCS edgeDir).nodes[i]? = g.nodes[i]? := by
  simp [addWitness, List.getElem?_append_left h]

/-- The newly added witness node is at the end of the list. -/
lemma WitnessGraph.addWitness_new_node (g : WitnessGraph) (oblIdx : Nat)
    (obl : WitnessObligation) (witnessMCS : { S : Set Formula // SetMaximalConsistent S })
    (edgeDir : EdgeDirection) :
    (g.addWitness oblIdx obl witnessMCS edgeDir).nodes[g.nodes.length]? =
      some ⟨witnessMCS, some oblIdx⟩ := by
  simp [addWitness]

/-- The resolved map for the new obligation returns the witness index. -/
lemma WitnessGraph.addWitness_resolved (g : WitnessGraph) (oblIdx : Nat)
    (obl : WitnessObligation) (witnessMCS : { S : Set Formula // SetMaximalConsistent S })
    (edgeDir : EdgeDirection) :
    (g.addWitness oblIdx obl witnessMCS edgeDir).resolved oblIdx = some g.nodes.length := by
  simp [addWitness]

/-- The resolved map is preserved for other obligation indices. -/
lemma WitnessGraph.addWitness_resolved_other (g : WitnessGraph) (oblIdx : Nat)
    (obl : WitnessObligation) (witnessMCS : { S : Set Formula // SetMaximalConsistent S })
    (edgeDir : EdgeDirection) (i : Nat) (h_ne : i ≠ oblIdx) :
    (g.addWitness oblIdx obl witnessMCS edgeDir).resolved i = g.resolved i := by
  simp [addWitness, h_ne]

/-!
## Phase 2: Witness Graph Construction

### Overview

The witness graph is built incrementally by processing (node, formula) pairs.
At each step n, we decode n via double-unpair: `Nat.unpair(n) = (round, pairIdx)`
and `Nat.unpair(pairIdx) = (nodeIdx, formulaIdx)`. We then check if the formula
creates an F/P obligation at the node, and if so create a witness.

### Key Design

- **Enumeration**: Double-unpair ensures every (node, formula) pair is visited
  infinitely often (once per round). This is critical because nodes created at
  step k may have pair encodings less than k under single-unpair.
- **Lazy obligation discovery**: Instead of collecting all obligations upfront (which
  would require enumerating an infinite set), we discover obligations on-the-fly
  by checking formula membership at each step.
- **One witness per step**: Each step creates at most one witness node, keeping the
  consistency argument simple (uses `witnessSeed_consistent` directly).

### Formula Enumeration

We use the same `Encodable Formula` instance as DovetailingChain.lean.
-/

/-- Encodable instance for Formula, derived from the Countable instance. -/
noncomputable instance formulaEncodableWG : Encodable Formula := Encodable.ofCountable Formula

/-- Decode a natural number to a formula (if it's in the range of the encoding). -/
noncomputable def decodeFormulaWG (k : Nat) : Option Formula :=
  @Encodable.decode Formula formulaEncodableWG k

/-- Encode a formula to a natural number. -/
noncomputable def encodeFormulaWG (phi : Formula) : Nat :=
  @Encodable.encode Formula formulaEncodableWG phi

/-- Surjectivity: decoding the encoding recovers the original formula. -/
lemma decodeFormulaWG_encodeFormulaWG (psi : Formula) :
    decodeFormulaWG (encodeFormulaWG psi) = some psi := by
  simp only [decodeFormulaWG, encodeFormulaWG]
  exact Encodable.encodek psi

/-!
### Process Step

At step n, we decode n to (nodeIdx, formulaIdx), then:
1. Check nodeIdx < graph.nodes.length (node exists)
2. Decode formulaIdx to get a formula psi
3. Check if F(psi) or P(psi) is in the node's MCS
4. If yes: create witness via Lindenbaum on the witness seed
5. If no: return graph unchanged
-/

/-- Check whether a specific obligation (node, obligation type) has already been witnessed
in the graph. An obligation is witnessed if there exists a resolved entry matching it. -/
noncomputable def WitnessGraph.isWitnessed (g : WitnessGraph) (nodeIdx : Nat) (obl : ObligationType) : Bool :=
  g.obligations.zipIdx.any fun ⟨wo, i⟩ =>
    wo.nodeIdx == nodeIdx && wo.obligation == obl && (g.resolved i).isSome

/-- Create a witness node for a future obligation F(psi) at a given source node.
Returns the updated graph with:
- A new witness node whose MCS extends {psi} union GContent(source)
- A forward edge from source to witness
- The obligation recorded and resolved -/
noncomputable def WitnessGraph.addFutureWitness (g : WitnessGraph)
    (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
    (h_F : Formula.some_future psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val) :
    WitnessGraph :=
  let sourceMCS := (g.nodeAt sourceIdx h_valid).mcs
  let seed := witnessSeed sourceMCS.val (.future psi)
  let h_seed_cons := witnessSeed_future_consistent sourceMCS.val sourceMCS.property psi h_F
  let h_ext := set_lindenbaum seed h_seed_cons
  let witnessMCS : { S : Set Formula // SetMaximalConsistent S } :=
    ⟨Classical.choose h_ext, (Classical.choose_spec h_ext).2⟩
  let oblIdx := g.obligations.length
  let obl : WitnessObligation := ⟨sourceIdx, .future psi⟩
  { nodes := g.nodes ++ [⟨witnessMCS, some oblIdx⟩]
    edges := g.edges ++ [⟨sourceIdx, g.nodes.length, .forward⟩]
    obligations := g.obligations ++ [obl]
    resolved := fun i => if i = oblIdx then some g.nodes.length else g.resolved i }

/-- Create a witness node for a past obligation P(psi) at a given source node.
Returns the updated graph with:
- A new witness node whose MCS extends {psi} union HContent(source)
- A backward edge from source to witness
- The obligation recorded and resolved -/
noncomputable def WitnessGraph.addPastWitness (g : WitnessGraph)
    (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
    (h_P : Formula.some_past psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val) :
    WitnessGraph :=
  let sourceMCS := (g.nodeAt sourceIdx h_valid).mcs
  let seed := witnessSeed sourceMCS.val (.past psi)
  let h_seed_cons := witnessSeed_past_consistent sourceMCS.val sourceMCS.property psi h_P
  let h_ext := set_lindenbaum seed h_seed_cons
  let witnessMCS : { S : Set Formula // SetMaximalConsistent S } :=
    ⟨Classical.choose h_ext, (Classical.choose_spec h_ext).2⟩
  let oblIdx := g.obligations.length
  let obl : WitnessObligation := ⟨sourceIdx, .past psi⟩
  { nodes := g.nodes ++ [⟨witnessMCS, some oblIdx⟩]
    edges := g.edges ++ [⟨sourceIdx, g.nodes.length, .backward⟩]
    obligations := g.obligations ++ [obl]
    resolved := fun i => if i = oblIdx then some g.nodes.length else g.resolved i }

/-!
### Process Step Function

The core construction step. At each step n, we process the pair
`(nodeIdx, formulaIdx) = Nat.unpair n`. If the node exists and the formula
decodes to psi, we check F(psi) and P(psi) membership and create witnesses.

We process future obligations first, then past (for definiteness; order doesn't
matter for correctness since coverage guarantees both are eventually processed).
-/

/-- Process step n of the witness graph construction.

Decodes n via double-unpair: first Nat.unpair(n) = (_, pairIdx), then
Nat.unpair(pairIdx) = (nodeIdx, formulaIdx). This ensures every (nodeIdx, formulaIdx)
pair is processed infinitely often (once per value of the first component), which is
critical for coverage: nodes created at step k may have obligations whose pair encoding
is less than k under single-unpair.

If the node exists and the formula decodes to psi:
- If F(psi) is in the node's MCS and not yet witnessed: create future witness
- Else if P(psi) is in the node's MCS and not yet witnessed: create past witness
- Else: return graph unchanged

**Design note**: We check F first, then P. A single step processes at most one
obligation. The other obligation (if both exist) will be handled at a different
step via the coverage argument. -/
noncomputable def processStep (g : WitnessGraph) (n : Nat) : WitnessGraph :=
  let (_, pairIdx) := Nat.unpair n
  let (nodeIdx, formulaIdx) := Nat.unpair pairIdx
  if h_node : nodeIdx < g.nodes.length then
    match decodeFormulaWG formulaIdx with
    | none => g
    | some psi =>
      if h_F : Formula.some_future psi ∈ (g.nodeAt nodeIdx h_node).mcs.val then
        if g.isWitnessed nodeIdx (.future psi) then g
        else g.addFutureWitness nodeIdx h_node psi h_F
      else if h_P : Formula.some_past psi ∈ (g.nodeAt nodeIdx h_node).mcs.val then
        if g.isWitnessed nodeIdx (.past psi) then g
        else g.addPastWitness nodeIdx h_node psi h_P
      else g
  else g

/-!
### Build Witness Graph

Iterate `processStep` to build the witness graph incrementally.
At step k, the graph `buildWitnessGraph root k` has processed steps 0..k-1.
-/

/-- Build the witness graph by iterating processStep for k steps.

Starting from an initial single-node graph (the root MCS), each step processes
one (node, formula) pair. After k steps, all pairs with Nat.pair encoding < k
have been examined.

**Coverage**: Double-unpair ensures every (node, formula) pair is processed
infinitely often. For any F(psi) at node i that exists at step k, we can find
a step n >= k where processStep examines the pair (i, encodeFormula psi),
ensuring the node exists when its obligation is processed. -/
noncomputable def buildWitnessGraph
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) : Nat → WitnessGraph
  | 0 => initialWitnessGraph rootMCS
  | n + 1 => processStep (buildWitnessGraph rootMCS n) n

/-!
### Basic Properties of processStep and buildWitnessGraph
-/

/-- processStep does not decrease node count. -/
lemma processStep_nodes_length_ge (g : WitnessGraph) (n : Nat) :
    g.nodes.length ≤ (processStep g n).nodes.length := by
  unfold processStep
  split  -- first unpair
  split  -- second unpair
  split  -- if nodeIdx < length
  · split  -- match decodeFormulaWG
    · exact Nat.le_refl _  -- none case
    · -- some psi case
      split  -- if F(psi) in MCS
      · split  -- if witnessed
        · exact Nat.le_refl _
        · simp [WitnessGraph.addFutureWitness]
      · split  -- if P(psi) in MCS
        · split  -- if witnessed
          · exact Nat.le_refl _
          · simp [WitnessGraph.addPastWitness]
        · exact Nat.le_refl _
  · exact Nat.le_refl _  -- nodeIdx >= length

/-- The witness graph is non-empty at every step (always has at least the root). -/
lemma buildWitnessGraph_nonempty (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) : (buildWitnessGraph rootMCS n).nonempty := by
  induction n with
  | zero => exact initialWitnessGraph_nonempty rootMCS
  | succ n ih =>
    simp only [buildWitnessGraph, WitnessGraph.nonempty]
    have h := processStep_nodes_length_ge (buildWitnessGraph rootMCS n) n
    simp only [WitnessGraph.nonempty] at ih
    omega

/-- Node count is monotonically non-decreasing. -/
lemma buildWitnessGraph_nodes_length_mono (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) :
    (buildWitnessGraph rootMCS n).nodes.length ≤ (buildWitnessGraph rootMCS (n + 1)).nodes.length := by
  simp only [buildWitnessGraph]
  exact processStep_nodes_length_ge _ _

/-- processStep preserves existing nodes (only appends new nodes). -/
lemma processStep_node_preserved (g : WitnessGraph) (n : Nat)
    (i : Nat) (h_i : i < g.nodes.length) :
    (processStep g n).nodes[i]? = g.nodes[i]? := by
  unfold processStep
  split  -- first unpair
  split  -- second unpair
  split  -- if nodeIdx < length
  · split  -- match decodeFormulaWG
    · rfl  -- none
    · -- some psi
      split  -- if F(psi) in MCS
      · split  -- if already witnessed
        · rfl
        · simp only [WitnessGraph.addFutureWitness]
          rw [List.getElem?_append_left h_i]
      · split  -- if P(psi) in MCS
        · split  -- if already witnessed
          · rfl
          · simp only [WitnessGraph.addPastWitness]
            rw [List.getElem?_append_left h_i]
        · rfl
  · rfl  -- nodeIdx >= length

/-- The root node is preserved at every step. -/
lemma buildWitnessGraph_root_preserved (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) :
    (buildWitnessGraph rootMCS n).nodes[0]? = some ⟨rootMCS, none⟩ := by
  induction n with
  | zero =>
    simp [buildWitnessGraph, initialWitnessGraph]
  | succ n ih =>
    simp only [buildWitnessGraph]
    have h_len : 0 < (buildWitnessGraph rootMCS n).nodes.length := by
      have := buildWitnessGraph_nonempty rootMCS n
      simp [WitnessGraph.nonempty] at this
      exact this
    rw [processStep_node_preserved _ _ 0 h_len]
    exact ih

/-- Existing nodes are preserved when the graph grows (nodes are only appended). -/
lemma buildWitnessGraph_node_preserved (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) (i : Nat) (h_i : i < (buildWitnessGraph rootMCS n).nodes.length) :
    (buildWitnessGraph rootMCS (n + 1)).nodes[i]? = (buildWitnessGraph rootMCS n).nodes[i]? := by
  simp only [buildWitnessGraph]
  exact processStep_node_preserved _ _ i h_i

/-!
### Witness Seed Membership Properties

When a witness is created, its MCS extends the witness seed. These lemmas
connect the witness node's MCS to the source node's MCS via the seed.
-/

/-- The witness seed is a subset of the MCS created from it by Lindenbaum.
This is the key property linking witness nodes to their obligations. -/
lemma lindenbaum_extends_seed (seed : Set Formula) (h_cons : SetConsistent seed) :
    seed ⊆ Classical.choose (set_lindenbaum seed h_cons) :=
  (Classical.choose_spec (set_lindenbaum seed h_cons)).1

/-- The MCS created from a seed by Lindenbaum is maximal consistent. -/
lemma lindenbaum_is_mcs (seed : Set Formula) (h_cons : SetConsistent seed) :
    SetMaximalConsistent (Classical.choose (set_lindenbaum seed h_cons)) :=
  (Classical.choose_spec (set_lindenbaum seed h_cons)).2

/-!
### Witness Contains Formula

When we create a future witness for F(psi), psi is in the witness MCS.
When we create a past witness for P(psi), psi is in the witness MCS.
These follow from psi being in the witness seed and Lindenbaum extending the seed.
-/

/-- Helper: accessing the last element of a list append. -/
private lemma list_get_append_last {α : Type*} (l : List α) (a : α) :
    (l ++ [a]).get ⟨l.length, by simp⟩ = a := by
  show (l ++ [a])[l.length] = a
  rw [List.getElem_append_right (by omega)]
  simp

/-- When a future witness is created for F(psi) at node i, the witness node's
MCS extends the witness seed {psi} union GContent(source). In particular,
psi is in the witness MCS. -/
theorem addFutureWitness_witness_seed_extends (g : WitnessGraph)
    (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
    (h_F : Formula.some_future psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val) :
    let seed := witnessSeed (g.nodeAt sourceIdx h_valid).mcs.val (.future psi)
    let h_cons := witnessSeed_future_consistent (g.nodeAt sourceIdx h_valid).mcs.val
      (g.nodeAt sourceIdx h_valid).mcs.property psi h_F
    seed ⊆ Classical.choose (set_lindenbaum seed h_cons) :=
  lindenbaum_extends_seed
    (witnessSeed (g.nodeAt sourceIdx h_valid).mcs.val (.future psi))
    (witnessSeed_future_consistent (g.nodeAt sourceIdx h_valid).mcs.val
      (g.nodeAt sourceIdx h_valid).mcs.property psi h_F)

/-- When a future witness is created, psi is in the witness MCS (follows from seed extension). -/
theorem addFutureWitness_contains_formula (g : WitnessGraph)
    (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
    (h_F : Formula.some_future psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val) :
    let seed := witnessSeed (g.nodeAt sourceIdx h_valid).mcs.val (.future psi)
    let h_cons := witnessSeed_future_consistent (g.nodeAt sourceIdx h_valid).mcs.val
      (g.nodeAt sourceIdx h_valid).mcs.property psi h_F
    psi ∈ Classical.choose (set_lindenbaum seed h_cons) :=
  addFutureWitness_witness_seed_extends g sourceIdx h_valid psi h_F
    (formula_mem_witnessSeed _ _)

/-- When a past witness is created for P(psi) at node i, the witness node's
MCS extends the witness seed {psi} union HContent(source). -/
theorem addPastWitness_witness_seed_extends (g : WitnessGraph)
    (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
    (h_P : Formula.some_past psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val) :
    let seed := witnessSeed (g.nodeAt sourceIdx h_valid).mcs.val (.past psi)
    let h_cons := witnessSeed_past_consistent (g.nodeAt sourceIdx h_valid).mcs.val
      (g.nodeAt sourceIdx h_valid).mcs.property psi h_P
    seed ⊆ Classical.choose (set_lindenbaum seed h_cons) :=
  lindenbaum_extends_seed
    (witnessSeed (g.nodeAt sourceIdx h_valid).mcs.val (.past psi))
    (witnessSeed_past_consistent (g.nodeAt sourceIdx h_valid).mcs.val
      (g.nodeAt sourceIdx h_valid).mcs.property psi h_P)

/-- When a past witness is created, psi is in the witness MCS. -/
theorem addPastWitness_contains_formula (g : WitnessGraph)
    (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
    (h_P : Formula.some_past psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val) :
    let seed := witnessSeed (g.nodeAt sourceIdx h_valid).mcs.val (.past psi)
    let h_cons := witnessSeed_past_consistent (g.nodeAt sourceIdx h_valid).mcs.val
      (g.nodeAt sourceIdx h_valid).mcs.property psi h_P
    psi ∈ Classical.choose (set_lindenbaum seed h_cons) :=
  addPastWitness_witness_seed_extends g sourceIdx h_valid psi h_P
    (formula_mem_witnessSeed _ _)

/-!
### GContent Propagation Through Witness Edges

When a future witness is created from source node via seed = {psi} union GContent(source),
the witness MCS extends GContent(source). This means the G-content of the source
propagates to the witness, which is essential for forward_G.
-/

/-- When a future witness is created, GContent of the source is a subset of the witness MCS.
This follows from GContent being a subset of the witness seed, and Lindenbaum extending the seed. -/
theorem addFutureWitness_GContent_extends (g : WitnessGraph)
    (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
    (h_F : Formula.some_future psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val) :
    let seed := witnessSeed (g.nodeAt sourceIdx h_valid).mcs.val (.future psi)
    let h_cons := witnessSeed_future_consistent (g.nodeAt sourceIdx h_valid).mcs.val
      (g.nodeAt sourceIdx h_valid).mcs.property psi h_F
    GContent (g.nodeAt sourceIdx h_valid).mcs.val ⊆
      Classical.choose (set_lindenbaum seed h_cons) :=
  fun _ h_phi =>
    addFutureWitness_witness_seed_extends g sourceIdx h_valid psi h_F
      (GContent_subset_witnessSeed_future _ psi h_phi)

/-- When a past witness is created, HContent of the source is a subset of the witness MCS. -/
theorem addPastWitness_HContent_extends (g : WitnessGraph)
    (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
    (h_P : Formula.some_past psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val) :
    let seed := witnessSeed (g.nodeAt sourceIdx h_valid).mcs.val (.past psi)
    let h_cons := witnessSeed_past_consistent (g.nodeAt sourceIdx h_valid).mcs.val
      (g.nodeAt sourceIdx h_valid).mcs.property psi h_P
    HContent (g.nodeAt sourceIdx h_valid).mcs.val ⊆
      Classical.choose (set_lindenbaum seed h_cons) :=
  fun _ h_phi =>
    addPastWitness_witness_seed_extends g sourceIdx h_valid psi h_P
      (HContent_subset_witnessSeed_past _ psi h_phi)

/-!
### Coverage Theorem

The key theorem: for any F(psi) obligation at any node that exists at step n,
there exists a step k >= n where the obligation is processed. This follows from
the surjectivity of Nat.unpair and the Encodable instance on Formula.
-/

/-- For any node index i, formula psi, and minimum step bound k, there exists
a step n >= k such that processStep at step n will examine pair (i, encodeFormulaWG psi).

This uses the double-unpair structure: n = Nat.pair(round, Nat.pair(i, encodeFormulaWG psi)).
By choosing round large enough, we ensure n >= k. -/
lemma coverage_step_exists (i : Nat) (psi : Formula) (k : Nat) :
    ∃ n : Nat, n ≥ k ∧
      (Nat.unpair (Nat.unpair n).2) = (i, encodeFormulaWG psi) := by
  let pairIdx := Nat.pair i (encodeFormulaWG psi)
  -- Choose round large enough that Nat.pair(round, pairIdx) >= k
  use Nat.pair k pairIdx
  constructor
  · exact Nat.left_le_pair k pairIdx
  · simp [Nat.unpair_pair, pairIdx]

/-- The witness graph at a later step extends the graph at an earlier step
(in terms of node count). -/
lemma buildWitnessGraph_nodes_length_mono_le (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_le : m ≤ n) :
    (buildWitnessGraph rootMCS m).nodes.length ≤ (buildWitnessGraph rootMCS n).nodes.length := by
  induction h_le with
  | refl => exact Nat.le_refl _
  | step h_le ih => exact le_trans ih (buildWitnessGraph_nodes_length_mono rootMCS _)

/-- Nodes are stable: a node that exists at step m still exists (unchanged) at step n >= m. -/
lemma buildWitnessGraph_node_stable (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_le : m ≤ n) (i : Nat) (h_i : i < (buildWitnessGraph rootMCS m).nodes.length) :
    (buildWitnessGraph rootMCS n).nodes[i]? = (buildWitnessGraph rootMCS m).nodes[i]? := by
  induction h_le with
  | refl => rfl
  | step h_le ih =>
    have h_i' : i < (buildWitnessGraph rootMCS _).nodes.length :=
      lt_of_lt_of_le h_i (buildWitnessGraph_nodes_length_mono_le rootMCS m _ h_le)
    rw [buildWitnessGraph_node_preserved rootMCS _ i h_i']
    exact ih

/-!
## Phase 3: Witness Graph Properties

### Limit Graph Concepts

The "limit graph" is the union over all finite construction steps. Instead of
constructing an explicit limit object, we reason about properties that hold
"eventually" - i.e., at some finite step.
-/

/-- An edge exists in the graph at some step k. -/
def edgeExistsAtStep (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (e : WitnessEdge) : Prop :=
  ∃ k : Nat, e ∈ (buildWitnessGraph rootMCS k).edges

/-- A node exists in the graph at step k. -/
def nodeExistsAtStep (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (i : Nat) (k : Nat) : Prop :=
  i < (buildWitnessGraph rootMCS k).nodes.length

/-- Get the MCS at node i, which is stable once the node exists. -/
noncomputable def stableNodeMCS (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (i : Nat) (k : Nat) (h : nodeExistsAtStep rootMCS i k) : { S : Set Formula // SetMaximalConsistent S } :=
  ((buildWitnessGraph rootMCS k).nodeAt i h).mcs

/-!
### Edge Preservation

Edges, like nodes, are only appended and never removed.
-/

/-- processStep preserves existing edges (only appends new edges). -/
lemma processStep_edge_preserved (g : WitnessGraph) (n : Nat)
    (e : WitnessEdge) (h_e : e ∈ g.edges) :
    e ∈ (processStep g n).edges := by
  unfold processStep
  split  -- first unpair
  split  -- second unpair
  split  -- if nodeIdx < length
  · split  -- match decode
    · exact h_e
    · split  -- if F(psi) in MCS
      · split  -- if witnessed
        · exact h_e
        · simp only [WitnessGraph.addFutureWitness]
          exact List.mem_append_left _ h_e
      · split  -- if P(psi) in MCS
        · split  -- if witnessed
          · exact h_e
          · simp only [WitnessGraph.addPastWitness]
            exact List.mem_append_left _ h_e
        · exact h_e
  · exact h_e

/-- Edges in buildWitnessGraph are preserved at later steps. -/
lemma buildWitnessGraph_edge_stable (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_le : m ≤ n) (e : WitnessEdge)
    (h_e : e ∈ (buildWitnessGraph rootMCS m).edges) :
    e ∈ (buildWitnessGraph rootMCS n).edges := by
  induction h_le with
  | refl => exact h_e
  | step h_le ih =>
    simp only [buildWitnessGraph]
    exact processStep_edge_preserved _ _ _ ih

/-!
### processStep outcome characterization

Rather than tracking each branch of processStep individually, we characterize
the three possible outcomes: unchanged, addFutureWitness, or addPastWitness.
-/

/-- processStep at step n either returns g unchanged, or adds exactly one node/edge.
When it adds a witness:
- For future witness: new edge is (src, g.nodes.length, forward) and new node
  extends {psi} union GContent(source)
- For past witness: new edge is (src, g.nodes.length, backward) and new node
  extends {psi} union HContent(source)
-/
inductive ProcessStepOutcome (g : WitnessGraph) (n : Nat) : Prop where
  /-- Graph unchanged -/
  | unchanged : processStep g n = g → ProcessStepOutcome g n
  /-- Future witness created -/
  | futureWitness (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
      (h_F : Formula.some_future psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val) :
      processStep g n = g.addFutureWitness sourceIdx h_valid psi h_F →
      ProcessStepOutcome g n
  /-- Past witness created -/
  | pastWitness (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
      (h_P : Formula.some_past psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val) :
      processStep g n = g.addPastWitness sourceIdx h_valid psi h_P →
      ProcessStepOutcome g n

/-!
### Forward F Local Witness Existence

The main theorem: for any F(psi) at node i existing at step k,
there exists a later step k' and a witness node j such that:
1. psi is in node j's MCS
2. There is a forward edge from i to j at step k'
-/

/-- The node MCS at index i is the same regardless of which step we look at,
as long as the node exists. -/
private lemma getElem?_eq_implies_getElem_eq {α : Type*} (l1 l2 : List α)
    (i : Nat) (h1 : i < l1.length) (h2 : i < l2.length)
    (h_eq : l1[i]? = l2[i]?) :
    l1[i] = l2[i] := by
  rw [List.getElem?_eq_getElem h1, List.getElem?_eq_getElem h2] at h_eq
  exact Option.some.inj h_eq

lemma stableNodeMCS_eq (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (i : Nat) (k1 k2 : Nat) (h1 : nodeExistsAtStep rootMCS i k1) (h2 : nodeExistsAtStep rootMCS i k2) :
    stableNodeMCS rootMCS i k1 h1 = stableNodeMCS rootMCS i k2 h2 := by
  simp only [stableNodeMCS, WitnessGraph.nodeAt]
  by_cases h : k1 ≤ k2
  · have h_stable := buildWitnessGraph_node_stable rootMCS k1 k2 h i h1
    -- h_stable : (bWG k2).nodes[i]? = (bWG k1).nodes[i]?
    have h2' : i < (buildWitnessGraph rootMCS k2).nodes.length :=
      lt_of_lt_of_le h1 (buildWitnessGraph_nodes_length_mono_le rootMCS k1 k2 h)
    have h_node_eq := getElem?_eq_implies_getElem_eq _ _ i h1 h2' h_stable.symm
    exact congrArg WitnessNode.mcs h_node_eq
  · push_neg at h
    have h_le : k2 ≤ k1 := by omega
    have h_stable := buildWitnessGraph_node_stable rootMCS k2 k1 h_le i h2
    -- h_stable : (bWG k1).nodes[i]? = (bWG k2).nodes[i]?
    have h1' : i < (buildWitnessGraph rootMCS k1).nodes.length :=
      lt_of_lt_of_le h2 (buildWitnessGraph_nodes_length_mono_le rootMCS k2 k1 h_le)
    have h_node_eq := getElem?_eq_implies_getElem_eq _ _ i h2 h1' h_stable.symm
    exact (congrArg WitnessNode.mcs h_node_eq).symm

/-!
### Witness Existence from processStep

When processStep processes the pair (i, encodeFormulaWG psi) and F(psi) is
in node i's MCS, a witness is either already present or freshly created.
-/

/-- When processStep processes step n where the double-unpair gives (i, encodeFormulaWG psi),
node i exists, F(psi) is in node i's MCS, and the obligation is not yet witnessed,
then processStep produces addFutureWitness.

Proof: Unfold processStep to show that the specific branch conditions are met. -/
theorem processStep_creates_fresh_future_witness (g : WitnessGraph) (n : Nat)
    (i : Nat) (h_i : i < g.nodes.length) (psi : Formula)
    (h_unpair : (Nat.unpair (Nat.unpair n).2) = (i, encodeFormulaWG psi))
    (h_F : Formula.some_future psi ∈ (g.nodeAt i h_i).mcs.val)
    (h_not_witnessed : g.isWitnessed i (.future psi) = false) :
    (⟨i, g.nodes.length, .forward⟩ : WitnessEdge) ∈ (processStep g n).edges ∧
    (processStep g n).nodes.length = g.nodes.length + 1 ∧
    (∀ (h_j : g.nodes.length < (processStep g n).nodes.length),
      psi ∈ ((processStep g n).nodeAt g.nodes.length h_j).mcs.val ∧
      GContent (g.nodeAt i h_i).mcs.val ⊆
        ((processStep g n).nodeAt g.nodes.length h_j).mcs.val) := by
  -- Key step: show processStep g n produces addFutureWitness
  -- We prove this by converting processStep to processStep_unfold equivalent
  -- and then applying conditions
  suffices h_eq : processStep g n = g.addFutureWitness i h_i psi h_F by
    rw [h_eq]
    refine ⟨?_, ?_, ?_⟩
    · simp [WitnessGraph.addFutureWitness]
    · simp [WitnessGraph.addFutureWitness]
    · intro h_j
      simp only [WitnessGraph.addFutureWitness, WitnessGraph.nodeAt,
        List.getElem_append_right (Nat.le_refl _)]
      simp only [Nat.sub_self, List.getElem_cons_zero]
      exact ⟨(Classical.choose_spec (set_lindenbaum _ _)).1 (formula_mem_witnessSeed _ _),
             fun _ h_phi => (Classical.choose_spec (set_lindenbaum _ _)).1
               (GContent_subset_witnessSeed_future _ psi h_phi)⟩
  -- Now prove processStep g n = g.addFutureWitness i h_i psi h_F
  -- This requires carefully tracking the double-unpair match
  sorry

/-- Symmetric version for past witnesses. -/
theorem processStep_creates_fresh_past_witness (g : WitnessGraph) (n : Nat)
    (i : Nat) (h_i : i < g.nodes.length) (psi : Formula)
    (h_unpair : (Nat.unpair (Nat.unpair n).2) = (i, encodeFormulaWG psi))
    (h_not_F : Formula.some_future psi ∉ (g.nodeAt i h_i).mcs.val)
    (h_P : Formula.some_past psi ∈ (g.nodeAt i h_i).mcs.val)
    (h_not_witnessed : g.isWitnessed i (.past psi) = false) :
    (⟨i, g.nodes.length, .backward⟩ : WitnessEdge) ∈ (processStep g n).edges ∧
    (processStep g n).nodes.length = g.nodes.length + 1 ∧
    (∀ (h_j : g.nodes.length < (processStep g n).nodes.length),
      psi ∈ ((processStep g n).nodeAt g.nodes.length h_j).mcs.val ∧
      HContent (g.nodeAt i h_i).mcs.val ⊆
        ((processStep g n).nodeAt g.nodes.length h_j).mcs.val) := by
  suffices h_eq : processStep g n = g.addPastWitness i h_i psi h_P by
    rw [h_eq]
    refine ⟨?_, ?_, ?_⟩
    · simp [WitnessGraph.addPastWitness]
    · simp [WitnessGraph.addPastWitness]
    · intro h_j
      simp only [WitnessGraph.addPastWitness, WitnessGraph.nodeAt,
        List.getElem_append_right (Nat.le_refl _)]
      simp only [Nat.sub_self, List.getElem_cons_zero]
      exact ⟨(Classical.choose_spec (set_lindenbaum _ _)).1 (formula_mem_witnessSeed _ _),
             fun _ h_phi => (Classical.choose_spec (set_lindenbaum _ _)).1
               (HContent_subset_witnessSeed_past _ psi h_phi)⟩
  sorry

/-!
### Phase 3 Main Theorems

The six key properties of the witness graph construction.
-/

/-- **Theorem 1: Forward F Local Witness Existence**

For any F(psi) at node i (existing at step k), there exists a step k' and a
witness node j at step k' such that:
- psi is in node j's MCS
- There is a forward edge from i to j
- GContent of node i's MCS is a subset of node j's MCS

This is the core property enabling forward_F in the completeness proof. -/
theorem witnessGraph_forward_F_local (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (i : Nat) (k : Nat) (h_i : i < (buildWitnessGraph rootMCS k).nodes.length)
    (psi : Formula)
    (h_F : Formula.some_future psi ∈ ((buildWitnessGraph rootMCS k).nodeAt i h_i).mcs.val) :
    ∃ (k' : Nat) (j : Nat) (h_j : j < (buildWitnessGraph rootMCS k').nodes.length),
      (⟨i, j, .forward⟩ : WitnessEdge) ∈ (buildWitnessGraph rootMCS k').edges ∧
      psi ∈ ((buildWitnessGraph rootMCS k').nodeAt j h_j).mcs.val := by
  -- Step 1: Find a step n >= k where the pair (i, encodeFormulaWG psi) is processed
  obtain ⟨n, h_n_ge_k, h_unpair⟩ := coverage_step_exists i psi k
  -- Step 2: Node i exists at step n (by monotonicity from step k)
  have h_i_at_n : i < (buildWitnessGraph rootMCS n).nodes.length :=
    lt_of_lt_of_le h_i (buildWitnessGraph_nodes_length_mono_le rootMCS k n h_n_ge_k)
  -- Step 3: F(psi) is in node i's MCS at step n (same MCS by stability)
  have h_node_stable := buildWitnessGraph_node_stable rootMCS k n h_n_ge_k i h_i
  have h_node_eq := getElem?_eq_implies_getElem_eq _ _ i h_i h_i_at_n h_node_stable.symm
  have h_F_at_n : Formula.some_future psi ∈
      ((buildWitnessGraph rootMCS n).nodeAt i h_i_at_n).mcs.val := by
    simp only [WitnessGraph.nodeAt] at h_F ⊢
    rw [← h_node_eq]
    exact h_F
  -- Step 4: Case split on whether the obligation is already witnessed
  let g_n := buildWitnessGraph rootMCS n
  by_cases h_wit : g_n.isWitnessed i (.future psi) = true
  · -- Case: already witnessed - witness exists at step n
    -- The witness was created at an earlier step.
    -- When isWitnessed returns true, there's a resolved obligation entry.
    -- The edge and node were created at the same time as the obligation.
    sorry  -- TODO: Extract witness from isWitnessed = true
  · -- Case: not yet witnessed - fresh witness created at step n+1
    have h_wit_false : g_n.isWitnessed i (.future psi) = false := by
      cases h_eq : g_n.isWitnessed i (.future psi) <;> simp_all
    have ⟨h_edge, h_len⟩ := processStep_creates_fresh_future_witness g_n n i h_i_at_n psi
      h_unpair h_F_at_n h_wit_false
    -- The witness node is at index g_n.nodes.length, in graph at step n+1
    use n + 1, g_n.nodes.length
    have h_j_bound : g_n.nodes.length < (buildWitnessGraph rootMCS (n + 1)).nodes.length := by
      simp only [buildWitnessGraph]; omega
    use h_j_bound
    constructor
    · -- Edge exists at step n+1
      simp only [buildWitnessGraph]
      exact h_edge
    · -- psi is in the witness node's MCS at step n+1
      -- The witness MCS extends the seed {psi} union GContent(source)
      -- We need to show psi is in the witness node at step n+1
      -- processStep g_n n = g_n.addFutureWitness i h_i_at_n psi h_F_at_n
      -- The witness node at g_n.nodes.length has MCS extending {psi} union GContent
      sorry  -- TODO: Show psi in witness MCS

/-- **Theorem 2: Backward P Local Witness Existence**

Symmetric to forward_F_local. For any P(psi) at node i, there exists a witness
node j with a backward edge from i to j and psi in j's MCS. -/
theorem witnessGraph_backward_P_local (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (i : Nat) (k : Nat) (h_i : i < (buildWitnessGraph rootMCS k).nodes.length)
    (psi : Formula)
    (h_P : Formula.some_past psi ∈ ((buildWitnessGraph rootMCS k).nodeAt i h_i).mcs.val) :
    ∃ (k' : Nat) (j : Nat) (h_j : j < (buildWitnessGraph rootMCS k').nodes.length),
      (⟨i, j, .backward⟩ : WitnessEdge) ∈ (buildWitnessGraph rootMCS k').edges ∧
      psi ∈ ((buildWitnessGraph rootMCS k').nodeAt j h_j).mcs.val := by
  sorry

/-- **Theorem 3: GContent Propagation**

For any forward edge (i, j) created by addFutureWitness, GContent of node i's
MCS is a subset of node j's MCS. This follows directly from the witness seed
construction: the seed includes GContent(source), and Lindenbaum extends the seed. -/
theorem witnessGraph_GContent_propagates (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (i j : Nat) (k : Nat)
    (h_i : i < (buildWitnessGraph rootMCS k).nodes.length)
    (h_j : j < (buildWitnessGraph rootMCS k).nodes.length)
    (h_edge : (⟨i, j, .forward⟩ : WitnessEdge) ∈ (buildWitnessGraph rootMCS k).edges) :
    GContent ((buildWitnessGraph rootMCS k).nodeAt i h_i).mcs.val ⊆
      ((buildWitnessGraph rootMCS k).nodeAt j h_j).mcs.val := by
  sorry

/-- **Theorem 4: HContent Propagation**

Symmetric to GContent propagation. For backward edges, HContent propagates. -/
theorem witnessGraph_HContent_propagates (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (i j : Nat) (k : Nat)
    (h_i : i < (buildWitnessGraph rootMCS k).nodes.length)
    (h_j : j < (buildWitnessGraph rootMCS k).nodes.length)
    (h_edge : (⟨i, j, .backward⟩ : WitnessEdge) ∈ (buildWitnessGraph rootMCS k).edges) :
    HContent ((buildWitnessGraph rootMCS k).nodeAt i h_i).mcs.val ⊆
      ((buildWitnessGraph rootMCS k).nodeAt j h_j).mcs.val := by
  sorry

/-- **Theorem 5: Acyclicity**

The edge relation in the witness graph has no cycles. Each edge connects a source
node (with lower index) to a witness node (with higher index), so the edge relation
is well-founded on node indices. -/
-- Helper: processStep edges are a superset of g.edges, and any new edge has src < dst
private lemma processStep_edges_subset_or_new (g : WitnessGraph) (n : Nat) :
    (∀ e ∈ (processStep g n).edges, e ∈ g.edges) ∨
    (∃ sourceIdx : Nat, sourceIdx < g.nodes.length ∧
      (processStep g n).edges = g.edges ++ [⟨sourceIdx, g.nodes.length, .forward⟩]) ∨
    (∃ sourceIdx : Nat, sourceIdx < g.nodes.length ∧
      (processStep g n).edges = g.edges ++ [⟨sourceIdx, g.nodes.length, .backward⟩]) := by
  unfold processStep
  split  -- first unpair
  split  -- second unpair
  split  -- if nodeIdx < length
  · rename_i h_node
    split  -- match decode
    · left; intro e h; exact h  -- none
    · -- some psi
      split  -- if F(psi) in MCS
      · -- F(psi)
        split  -- if witnessed
        · left; intro e h; exact h  -- already witnessed, g unchanged
        · -- addFutureWitness
          right; left
          exact ⟨_, h_node, rfl⟩
      · -- not F
        split  -- if P(psi)
        · -- P(psi)
          split  -- if witnessed
          · left; intro e h; exact h
          · -- addPastWitness
            right; right
            exact ⟨_, h_node, rfl⟩
        · left; intro e h; exact h
  · left; intro e h; exact h

theorem witnessGraph_edges_acyclic (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (k : Nat) (e : WitnessEdge) (h_e : e ∈ (buildWitnessGraph rootMCS k).edges) :
    e.src < e.dst := by
  induction k with
  | zero =>
    -- Initial graph has no edges
    simp [buildWitnessGraph, initialWitnessGraph] at h_e
  | succ n ih =>
    simp only [buildWitnessGraph] at h_e
    let g := buildWitnessGraph rootMCS n
    have h_cases := processStep_edges_subset_or_new g n
    rcases h_cases with h_same | ⟨src, h_src, h_eq⟩ | ⟨src, h_src, h_eq⟩
    · -- processStep returned g unchanged
      exact ih (h_same e h_e)
    · -- processStep added a forward edge
      rw [h_eq] at h_e
      simp [List.mem_append] at h_e
      rcases h_e with h_old | h_new
      · exact ih h_old
      · -- e is the new edge (src, g.nodes.length, forward)
        rw [h_new]; exact h_src
    · -- processStep added a backward edge
      rw [h_eq] at h_e
      simp [List.mem_append] at h_e
      rcases h_e with h_old | h_new
      · exact ih h_old
      · rw [h_new]; exact h_src

/-- **Theorem 6: Countability**

The set of nodes at each step is finite (bounded by k + 1 since each step adds
at most one node). In the limit, the set of all nodes is countable since each
node is indexed by its natural number position. -/
theorem witnessGraph_nodes_finite (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (k : Nat) : (buildWitnessGraph rootMCS k).nodes.length ≤ k + 1 := by
  induction k with
  | zero => simp [buildWitnessGraph, initialWitnessGraph]
  | succ n ih =>
    have h_mono := buildWitnessGraph_nodes_length_mono rootMCS n
    have h_inc := processStep_nodes_length_ge (buildWitnessGraph rootMCS n) n
    -- processStep adds at most 1 node
    suffices h : (processStep (buildWitnessGraph rootMCS n) n).nodes.length ≤
        (buildWitnessGraph rootMCS n).nodes.length + 1 by
      simp only [buildWitnessGraph]; omega
    unfold processStep
    split; split; split
    · split
      · exact Nat.le_succ _
      · split
        · split
          · exact Nat.le_succ _
          · simp [WitnessGraph.addFutureWitness]
        · split
          · split
            · exact Nat.le_succ _
            · simp [WitnessGraph.addPastWitness]
          · exact Nat.le_succ _
    · exact Nat.le_succ _

end Bimodal.Metalogic.Bundle
