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
        if g.isWitnessed nodeIdx (.future psi) then
          -- F already witnessed; fall through to check P
          if h_P : Formula.some_past psi ∈ (g.nodeAt nodeIdx h_node).mcs.val then
            if g.isWitnessed nodeIdx (.past psi) then g
            else g.addPastWitness nodeIdx h_node psi h_P
          else g
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
      · split  -- if F witnessed
        · split  -- if P(psi) in MCS (F witnessed, fall through)
          · split  -- if P witnessed
            · exact Nat.le_refl _
            · simp [WitnessGraph.addPastWitness]
          · exact Nat.le_refl _
        · simp [WitnessGraph.addFutureWitness]
      · split  -- if P(psi) in MCS
        · split  -- if P witnessed
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
      · split  -- if F already witnessed
        · split  -- if P(psi) in MCS (F witnessed, fall through)
          · split  -- if P witnessed
            · rfl
            · simp only [WitnessGraph.addPastWitness]
              rw [List.getElem?_append_left h_i]
          · rfl
        · simp only [WitnessGraph.addFutureWitness]
          rw [List.getElem?_append_left h_i]
      · split  -- if P(psi) in MCS
        · split  -- if P already witnessed
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
      · split  -- if F witnessed
        · split  -- if P(psi) in MCS (F witnessed, fall through)
          · split  -- if P witnessed
            · exact h_e
            · simp only [WitnessGraph.addPastWitness]
              exact List.mem_append_left _ h_e
          · exact h_e
        · simp only [WitnessGraph.addFutureWitness]
          exact List.mem_append_left _ h_e
      · split  -- if P(psi) in MCS
        · split  -- if P witnessed
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
      exact ⟨addFutureWitness_contains_formula g i h_i psi h_F,
             addFutureWitness_GContent_extends g i h_i psi h_F⟩
  -- Now prove processStep g n = g.addFutureWitness i h_i psi h_F
  -- Unfold processStep and track through double-unpair match
  unfold processStep
  -- After unfolding, the let-destructuring gives us (_, pairIdx) = Nat.unpair n
  -- and (nodeIdx, formulaIdx) = Nat.unpair pairIdx
  -- We need h_unpair to determine that nodeIdx = i and formulaIdx = encodeFormulaWG psi
  simp only [h_unpair]
  simp only [show i < g.nodes.length from h_i, dite_true]
  have h_decode : decodeFormulaWG (encodeFormulaWG psi) = some psi := decodeFormulaWG_encodeFormulaWG psi
  split
  · -- case none: contradicts h_decode
    rename_i h_none
    rw [h_decode] at h_none
    exact absurd h_none nofun
  · -- case some psi_1:
    rename_i psi_1 h_some
    rw [h_decode] at h_some
    cases h_some
    simp only [h_F, dite_true, h_not_witnessed, ite_false, Bool.false_eq_true]

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
      exact ⟨addPastWitness_contains_formula g i h_i psi h_P,
             addPastWitness_HContent_extends g i h_i psi h_P⟩
  -- Now prove processStep g n = g.addPastWitness i h_i psi h_P
  unfold processStep
  simp only [h_unpair]
  simp only [show i < g.nodes.length from h_i, dite_true]
  have h_decode : decodeFormulaWG (encodeFormulaWG psi) = some psi := decodeFormulaWG_encodeFormulaWG psi
  split
  · -- case none: contradicts h_decode
    rename_i h_none
    rw [h_decode] at h_none
    exact absurd h_none nofun
  · -- case some psi_1:
    rename_i psi_1 h_some
    rw [h_decode] at h_some
    cases h_some
    simp only [h_not_F, dite_false, h_P, dite_true, h_not_witnessed, ite_false, Bool.false_eq_true]

/-- New case: when F is in MCS and already witnessed, processStep falls through to create a
past witness if P is in MCS and not yet witnessed. -/
theorem processStep_creates_past_witness_F_witnessed (g : WitnessGraph) (n : Nat)
    (i : Nat) (h_i : i < g.nodes.length) (psi : Formula)
    (h_unpair : (Nat.unpair (Nat.unpair n).2) = (i, encodeFormulaWG psi))
    (h_F : Formula.some_future psi ∈ (g.nodeAt i h_i).mcs.val)
    (h_F_witnessed : g.isWitnessed i (.future psi) = true)
    (h_P : Formula.some_past psi ∈ (g.nodeAt i h_i).mcs.val)
    (h_not_witnessed_P : g.isWitnessed i (.past psi) = false) :
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
      exact ⟨addPastWitness_contains_formula g i h_i psi h_P,
             addPastWitness_HContent_extends g i h_i psi h_P⟩
  unfold processStep
  simp only [h_unpair]
  simp only [show i < g.nodes.length from h_i, dite_true]
  have h_decode : decodeFormulaWG (encodeFormulaWG psi) = some psi := decodeFormulaWG_encodeFormulaWG psi
  split
  · rename_i h_none; rw [h_decode] at h_none; exact absurd h_none nofun
  · rename_i psi_1 h_some; rw [h_decode] at h_some; cases h_some
    simp only [h_F, dite_true, h_F_witnessed, ite_true, h_P, dite_true,
               h_not_witnessed_P, ite_false, Bool.false_eq_true]

/-!
### Helper Lemmas for isWitnessed = true Cases

When isWitnessed returns true, we need to extract the actual witness edge
and witness node. These lemmas connect the resolved map to the edge list.
-/

/-- When addFutureWitness changes isWitnessed i (.future psi) from false to true,
the newly added obligation must match (i, psi). This pins down the source node
and formula. -/
private lemma addFutureWitness_new_obl_matches (g : WitnessGraph) (nIdx i : Nat)
    (psi' psi : Formula) (h_nIdx : nIdx < g.nodes.length)
    (h_F : Formula.some_future psi' ∈ (g.nodeAt nIdx h_nIdx).mcs.val)
    (h_false : g.isWitnessed i (.future psi) = false)
    (h_true : (g.addFutureWitness nIdx h_nIdx psi' h_F).isWitnessed i (.future psi) = true) :
    nIdx = i ∧ psi' = psi := by
  simp only [WitnessGraph.isWitnessed, WitnessGraph.addFutureWitness] at h_false h_true
  rw [List.zipIdx_append, List.any_append] at h_true
  -- The old part (same as h_false but with new resolved function)
  have h_old_false : g.obligations.zipIdx.any (fun ⟨wo, idx⟩ =>
      wo.nodeIdx == i && wo.obligation == ObligationType.future psi &&
      (if idx = g.obligations.length then some g.nodes.length
       else g.resolved idx).isSome) = false := by
    rw [Bool.eq_false_iff]
    intro h_old
    rw [Bool.eq_false_iff] at h_false
    apply h_false
    simp only [List.any_eq_true] at h_old ⊢
    obtain ⟨⟨wo, idx⟩, h_mem, h_cond⟩ := h_old
    refine ⟨⟨wo, idx⟩, h_mem, ?_⟩
    simp only [Bool.and_eq_true, beq_iff_eq, Option.isSome_iff_exists] at h_cond ⊢
    obtain ⟨⟨h_ni, h_obl⟩, witnessIdx, h_res⟩ := h_cond
    have h_idx_lt : idx < g.obligations.length := by
      have := (List.mem_zipIdx h_mem).2.1; simp at this; omega
    rw [if_neg (Nat.ne_of_lt h_idx_lt)] at h_res
    exact ⟨⟨h_ni, h_obl⟩, witnessIdx, h_res⟩
  rw [h_old_false, Bool.false_or] at h_true
  -- Now h_true is about the singleton new obligation
  simp only [List.zipIdx_cons, List.zipIdx_nil, List.any_cons, List.any_nil, Bool.or_false,
             Bool.and_eq_true, beq_iff_eq] at h_true
  obtain ⟨⟨h_ni_eq, h_obl_eq⟩, _⟩ := h_true
  refine ⟨h_ni_eq, ?_⟩
  -- h_obl_eq : (ObligationType.future psi' == ObligationType.future psi) = true
  -- Unfold derived BEq to structural Formula BEq
  simp only [BEq.beq] at h_obl_eq
  exact Formula.eq_of_beq h_obl_eq

/-- Symmetric version: addPastWitness changing isWitnessed i (.past psi). -/
private lemma addPastWitness_new_obl_matches (g : WitnessGraph) (nIdx i : Nat)
    (psi' psi : Formula) (h_nIdx : nIdx < g.nodes.length)
    (h_P : Formula.some_past psi' ∈ (g.nodeAt nIdx h_nIdx).mcs.val)
    (h_false : g.isWitnessed i (.past psi) = false)
    (h_true : (g.addPastWitness nIdx h_nIdx psi' h_P).isWitnessed i (.past psi) = true) :
    nIdx = i ∧ psi' = psi := by
  simp only [WitnessGraph.isWitnessed, WitnessGraph.addPastWitness] at h_false h_true
  rw [List.zipIdx_append, List.any_append] at h_true
  have h_old_false : g.obligations.zipIdx.any (fun ⟨wo, idx⟩ =>
      wo.nodeIdx == i && wo.obligation == ObligationType.past psi &&
      (if idx = g.obligations.length then some g.nodes.length
       else g.resolved idx).isSome) = false := by
    rw [Bool.eq_false_iff]
    intro h_old
    rw [Bool.eq_false_iff] at h_false
    apply h_false
    simp only [List.any_eq_true] at h_old ⊢
    obtain ⟨⟨wo, idx⟩, h_mem, h_cond⟩ := h_old
    refine ⟨⟨wo, idx⟩, h_mem, ?_⟩
    simp only [Bool.and_eq_true, beq_iff_eq, Option.isSome_iff_exists] at h_cond ⊢
    obtain ⟨⟨h_ni, h_obl⟩, witnessIdx, h_res⟩ := h_cond
    have h_idx_lt : idx < g.obligations.length := by
      have := (List.mem_zipIdx h_mem).2.1; simp at this; omega
    rw [if_neg (Nat.ne_of_lt h_idx_lt)] at h_res
    exact ⟨⟨h_ni, h_obl⟩, witnessIdx, h_res⟩
  rw [h_old_false, Bool.false_or] at h_true
  simp only [List.zipIdx_cons, List.zipIdx_nil, List.any_cons, List.any_nil, Bool.or_false,
             Bool.and_eq_true, beq_iff_eq] at h_true
  obtain ⟨⟨h_ni_eq, h_obl_eq⟩, _⟩ := h_true
  refine ⟨h_ni_eq, ?_⟩
  simp only [BEq.beq] at h_obl_eq
  exact Formula.eq_of_beq h_obl_eq

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
      · -- F(psi) in MCS
        split  -- if F witnessed
        · -- F witnessed: fall through to P check
          split  -- if P(psi) in MCS
          · split  -- if P witnessed
            · left; intro e h; exact h  -- both witnessed, g unchanged
            · -- addPastWitness (F witnessed, P not witnessed)
              right; right
              exact ⟨_, h_node, rfl⟩
          · left; intro e h; exact h  -- P not in MCS, g unchanged
        · -- addFutureWitness (F not witnessed)
          right; left
          exact ⟨_, h_node, rfl⟩
      · -- F not in MCS
        split  -- if P(psi)
        · -- P(psi)
          split  -- if P witnessed
          · left; intro e h; exact h
          · -- addPastWitness
            right; right
            exact ⟨_, h_node, rfl⟩
        · left; intro e h; exact h
  · left; intro e h; exact h

/-- Helper: addFutureWitness preserves isWitnessed for existing obligations. -/
private lemma addFutureWitness_isWitnessed_monotone (g : WitnessGraph)
    (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
    (h_F : Formula.some_future psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val)
    (i : Nat) (obl : ObligationType) (h_true : g.isWitnessed i obl = true) :
    (g.addFutureWitness sourceIdx h_valid psi h_F).isWitnessed i obl = true := by
  simp only [WitnessGraph.isWitnessed, WitnessGraph.addFutureWitness]
  rw [List.zipIdx_append, List.any_append]
  -- The old part of any still succeeds because:
  -- 1. Old obligations are preserved (same list prefix)
  -- 2. Old resolved values are preserved (if i = oblIdx then ... else g.resolved i)
  --    For old indices idx < g.obligations.length, idx ≠ g.obligations.length so resolved unchanged
  suffices h_old : g.obligations.zipIdx.any (fun ⟨wo, idx⟩ =>
      wo.nodeIdx == i && wo.obligation == obl &&
      (if idx = g.obligations.length then some g.nodes.length else g.resolved idx).isSome) = true by
    rw [h_old, Bool.true_or]
  simp only [WitnessGraph.isWitnessed] at h_true
  simp only [List.any_eq_true] at h_true ⊢
  obtain ⟨⟨wo, idx⟩, h_mem, h_cond⟩ := h_true
  refine ⟨⟨wo, idx⟩, h_mem, ?_⟩
  simp only [Bool.and_eq_true, beq_iff_eq, Option.isSome_iff_exists] at h_cond ⊢
  obtain ⟨⟨h_ni, h_obl⟩, w, h_res⟩ := h_cond
  have h_idx_lt : idx < g.obligations.length := by
    have := (List.mem_zipIdx h_mem).2.1; omega
  rw [if_neg (Nat.ne_of_lt h_idx_lt)]
  exact ⟨⟨h_ni, h_obl⟩, w, h_res⟩

/-- Helper: addPastWitness preserves isWitnessed for existing obligations. -/
private lemma addPastWitness_isWitnessed_monotone (g : WitnessGraph)
    (sourceIdx : Nat) (h_valid : sourceIdx < g.nodes.length) (psi : Formula)
    (h_P : Formula.some_past psi ∈ (g.nodeAt sourceIdx h_valid).mcs.val)
    (i : Nat) (obl : ObligationType) (h_true : g.isWitnessed i obl = true) :
    (g.addPastWitness sourceIdx h_valid psi h_P).isWitnessed i obl = true := by
  simp only [WitnessGraph.isWitnessed, WitnessGraph.addPastWitness]
  rw [List.zipIdx_append, List.any_append]
  suffices h_old : g.obligations.zipIdx.any (fun ⟨wo, idx⟩ =>
      wo.nodeIdx == i && wo.obligation == obl &&
      (if idx = g.obligations.length then some g.nodes.length else g.resolved idx).isSome) = true by
    rw [h_old, Bool.true_or]
  simp only [WitnessGraph.isWitnessed] at h_true
  simp only [List.any_eq_true] at h_true ⊢
  obtain ⟨⟨wo, idx⟩, h_mem, h_cond⟩ := h_true
  refine ⟨⟨wo, idx⟩, h_mem, ?_⟩
  simp only [Bool.and_eq_true, beq_iff_eq, Option.isSome_iff_exists] at h_cond ⊢
  obtain ⟨⟨h_ni, h_obl⟩, w, h_res⟩ := h_cond
  have h_idx_lt : idx < g.obligations.length := by
    have := (List.mem_zipIdx h_mem).2.1; omega
  rw [if_neg (Nat.ne_of_lt h_idx_lt)]
  exact ⟨⟨h_ni, h_obl⟩, w, h_res⟩

/-- isWitnessed is monotone: once true, stays true. -/
private lemma processStep_isWitnessed_monotone (g : WitnessGraph) (n i : Nat) (obl : ObligationType)
    (h_true : g.isWitnessed i obl = true) :
    (processStep g n).isWitnessed i obl = true := by
  unfold processStep
  split  -- first unpair
  split  -- second unpair
  split  -- if nodeIdx < length
  · rename_i h_node
    split  -- match decode
    · exact h_true  -- none: g unchanged
    · rename_i psi_val _
      split  -- if F(psi) in MCS
      · rename_i h_F
        split  -- if F witnessed
        · rename_i h_F_wit
          split  -- if P(psi) in MCS
          · rename_i h_P
            split  -- if P witnessed
            · exact h_true  -- both witnessed: g unchanged
            · -- addPastWitness (F witnessed, P not witnessed)
              exact addPastWitness_isWitnessed_monotone g _ h_node psi_val h_P i obl h_true
          · exact h_true  -- P not in MCS: g unchanged
        · -- addFutureWitness (F not witnessed)
          exact addFutureWitness_isWitnessed_monotone g _ h_node psi_val h_F i obl h_true
      · split  -- if P(psi) in MCS
        · rename_i h_not_F h_P
          split  -- if P witnessed
          · exact h_true  -- P witnessed: g unchanged
          · -- addPastWitness
            exact addPastWitness_isWitnessed_monotone g _ h_node psi_val h_P i obl h_true
        · exact h_true  -- neither F nor P: g unchanged
  · exact h_true  -- nodeIdx >= length: g unchanged

/-- isWitnessed is monotone across build steps. -/
private lemma buildWitnessGraph_isWitnessed_monotone
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_le : m ≤ n) (i : Nat) (obl : ObligationType)
    (h_true : (buildWitnessGraph rootMCS m).isWitnessed i obl = true) :
    (buildWitnessGraph rootMCS n).isWitnessed i obl = true := by
  induction h_le with
  | refl => exact h_true
  | step h_le ih =>
    simp only [buildWitnessGraph]
    exact processStep_isWitnessed_monotone _ _ _ _ ih

/-- processStep either returns g unchanged (same obligations, resolved, edges, nodes),
or adds one future witness, or adds one past witness. -/
private lemma processStep_outcome (g : WitnessGraph) (n : Nat) :
    (processStep g n = g) ∨
    (∃ (nodeIdx : Nat) (h_node : nodeIdx < g.nodes.length) (psi : Formula)
       (h_F : Formula.some_future psi ∈ (g.nodeAt nodeIdx h_node).mcs.val),
       processStep g n = g.addFutureWitness nodeIdx h_node psi h_F) ∨
    (∃ (nodeIdx : Nat) (h_node : nodeIdx < g.nodes.length) (psi : Formula)
       (h_P : Formula.some_past psi ∈ (g.nodeAt nodeIdx h_node).mcs.val),
       processStep g n = g.addPastWitness nodeIdx h_node psi h_P) := by
  unfold processStep
  split  -- first unpair
  split  -- second unpair
  split  -- if nodeIdx < length
  · rename_i h_node
    split  -- match decode
    · left; rfl  -- none
    · rename_i psi_val _
      split  -- if F(psi) in MCS
      · rename_i h_F
        split  -- if F witnessed
        · rename_i h_F_wit
          split  -- if P(psi) in MCS
          · rename_i h_P
            split  -- if P witnessed
            · left; rfl
            · right; right; exact ⟨_, h_node, psi_val, h_P, rfl⟩
          · left; rfl
        · right; left; exact ⟨_, h_node, psi_val, h_F, rfl⟩
      · split  -- if P(psi)
        · rename_i h_not_F h_P
          split
          · left; rfl
          · right; right; exact ⟨_, h_node, psi_val, h_P, rfl⟩
        · left; rfl
  · left; rfl

/-- When isWitnessed i (.future psi) = true at step n, a forward witness edge
and witness node exist at that same step. Proven by induction on n. -/
private lemma forward_witness_of_isWitnessed
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n i : Nat) (psi : Formula)
    (h_wit : (buildWitnessGraph rootMCS n).isWitnessed i (.future psi) = true) :
    ∃ (k' : Nat) (j : Nat) (h_j : j < (buildWitnessGraph rootMCS k').nodes.length),
      (⟨i, j, .forward⟩ : WitnessEdge) ∈ (buildWitnessGraph rootMCS k').edges ∧
      psi ∈ ((buildWitnessGraph rootMCS k').nodeAt j h_j).mcs.val := by
  induction n with
  | zero =>
    simp only [buildWitnessGraph, initialWitnessGraph, WitnessGraph.isWitnessed,
               List.zipIdx_nil, List.any_nil] at h_wit
    exact absurd h_wit (by decide)
  | succ m ih =>
    by_cases h_prev : (buildWitnessGraph rootMCS m).isWitnessed i (.future psi) = true
    · exact ih h_prev
    · -- isWitnessed became true at step m+1
      simp only [buildWitnessGraph] at h_wit
      have h_prev_false : (buildWitnessGraph rootMCS m).isWitnessed i (.future psi) = false := by
        cases h : (buildWitnessGraph rootMCS m).isWitnessed i (.future psi) <;> simp_all
      let g := buildWitnessGraph rootMCS m
      have h_out := processStep_outcome g m
      rcases h_out with h_unchanged | ⟨nIdx, h_nIdx, psi', h_F', h_ps_eq⟩ |
          ⟨nIdx, h_nIdx, psi', h_P', h_ps_eq⟩
      · -- processStep = g: isWitnessed unchanged → contradiction
        rw [h_unchanged] at h_wit
        rw [h_prev_false] at h_wit
        exact absurd h_wit (by decide)
      · -- processStep = addFutureWitness: isWitnessed became true via new obligation
        rw [h_ps_eq] at h_wit
        have ⟨h_nIdx_eq, h_psi_eq⟩ := addFutureWitness_new_obl_matches g nIdx i psi' psi
          h_nIdx h_F' h_prev_false h_wit
        subst h_nIdx_eq; subst h_psi_eq
        use m + 1, g.nodes.length
        have h_j_bound : g.nodes.length < (buildWitnessGraph rootMCS (m + 1)).nodes.length := by
          simp only [buildWitnessGraph]
          rw [h_ps_eq]
          simp [WitnessGraph.addFutureWitness, List.length_append]
        use h_j_bound
        constructor
        · -- Edge membership: the new edge is in the appended edges list
          simp only [buildWitnessGraph]
          rw [h_ps_eq]
          simp [WitnessGraph.addFutureWitness, List.mem_append]
        · -- psi' in the witness node's MCS
          -- The witness node is at g.nodes.length in processStep g m
          -- Use h_ps_eq to connect processStep to addFutureWitness
          have h_nodes_gt : g.nodes.length < (processStep g m).nodes.length := by
            rw [h_ps_eq]; simp [WitnessGraph.addFutureWitness, List.length_append]
          have h_mem := addFutureWitness_contains_formula g nIdx h_nIdx psi' h_F'
          -- The processStep result = addFutureWitness result, so same nodes
          -- Use h_ps_eq to transport membership through graph equality
          have h_bound : g.nodes.length < (processStep g m).nodes.length := by
            rw [h_ps_eq]; simp [WitnessGraph.addFutureWitness, List.length_append]
          -- The processStep result equals addFutureWitness, so use the latter's properties
          simp only [buildWitnessGraph, WitnessGraph.nodeAt]
          -- Show the node at g.nodes.length in processStep = node at g.nodes.length in addFutureWitness
          -- The goal is psi' ∈ (processStep g m).nodes[g.nodes.length].mcs
          -- We know processStep g m = g.addFutureWitness ... and the new node contains psi'
          simp only [h_ps_eq, WitnessGraph.addFutureWitness, List.getElem_append_right (Nat.le_refl _),
            Nat.sub_self, List.getElem_cons_zero]
          exact h_mem
      · -- processStep = addPastWitness: doesn't change .future isWitnessed
        rw [h_ps_eq] at h_wit
        -- addPastWitness only adds a .past obligation, so isWitnessed for .future is unchanged
        -- except possibly via the resolved map change for old obligations
        -- The isWitnessed monotonicity already handles this via addPastWitness_isWitnessed_monotone
        -- But we need to show it didn't NEWLY become true, i.e. it was already true before
        -- which contradicts h_prev_false. So show addPastWitness preserves false -> false for .future
        exfalso
        -- h_wit : (g.addPastWitness ...).isWitnessed i (.future psi) = true
        -- h_prev_false : g.isWitnessed i (.future psi) = false
        -- But addPastWitness only adds a .past obligation. The new obligation can't match .future.
        -- And old obligations have preserved resolved values. So isWitnessed can't become true.
        simp only [WitnessGraph.isWitnessed, WitnessGraph.addPastWitness] at h_wit
        rw [List.zipIdx_append, List.any_append] at h_wit
        -- Split the any into old part ∨ new part
        rw [Bool.or_eq_true] at h_wit
        rcases h_wit with h_old_part | h_new_part
        · -- Old part: same obligations, but resolved might differ for new index
          simp only [WitnessGraph.isWitnessed] at h_prev_false
          rw [Bool.eq_false_iff] at h_prev_false
          apply h_prev_false
          simp only [List.any_eq_true] at h_old_part ⊢
          obtain ⟨⟨wo, idx⟩, h_mem, h_cond⟩ := h_old_part
          refine ⟨⟨wo, idx⟩, h_mem, ?_⟩
          simp only [Bool.and_eq_true, beq_iff_eq, Option.isSome_iff_exists] at h_cond ⊢
          obtain ⟨⟨h_ni, h_obl⟩, w, h_res⟩ := h_cond
          have h_idx_lt : idx < g.obligations.length := by have := (List.mem_zipIdx h_mem).2.1; omega
          rw [if_neg (Nat.ne_of_lt h_idx_lt)] at h_res
          exact ⟨⟨h_ni, h_obl⟩, w, h_res⟩
        · -- New part: the new obligation is .past, can't match .future
          simp only [List.zipIdx_cons, List.zipIdx_nil, List.any_cons, List.any_nil, Bool.or_false,
                     Bool.and_eq_true] at h_new_part
          obtain ⟨⟨_, h_obl_eq⟩, _⟩ := h_new_part
          -- h_obl_eq has ObligationType.past ... == ObligationType.future ..., contradiction
          delta instBEqObligationType instBEqObligationType.beq at h_obl_eq
          simp at h_obl_eq

/-- Symmetric: when isWitnessed i (.past psi) = true at step n, a backward witness exists. -/
private lemma backward_witness_of_isWitnessed
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n i : Nat) (psi : Formula)
    (h_wit : (buildWitnessGraph rootMCS n).isWitnessed i (.past psi) = true) :
    ∃ (k' : Nat) (j : Nat) (h_j : j < (buildWitnessGraph rootMCS k').nodes.length),
      (⟨i, j, .backward⟩ : WitnessEdge) ∈ (buildWitnessGraph rootMCS k').edges ∧
      psi ∈ ((buildWitnessGraph rootMCS k').nodeAt j h_j).mcs.val := by
  induction n with
  | zero =>
    simp only [buildWitnessGraph, initialWitnessGraph, WitnessGraph.isWitnessed,
               List.zipIdx_nil, List.any_nil] at h_wit
    exact absurd h_wit (by decide)
  | succ m ih =>
    by_cases h_prev : (buildWitnessGraph rootMCS m).isWitnessed i (.past psi) = true
    · exact ih h_prev
    · simp only [buildWitnessGraph] at h_wit
      have h_prev_false : (buildWitnessGraph rootMCS m).isWitnessed i (.past psi) = false := by
        cases h : (buildWitnessGraph rootMCS m).isWitnessed i (.past psi) <;> simp_all
      let g := buildWitnessGraph rootMCS m
      have h_out := processStep_outcome g m
      rcases h_out with h_unchanged | ⟨nIdx, h_nIdx, psi', h_F', h_ps_eq⟩ |
          ⟨nIdx, h_nIdx, psi', h_P', h_ps_eq⟩
      · -- processStep = g: contradiction
        rw [h_unchanged] at h_wit
        rw [h_prev_false] at h_wit
        exact absurd h_wit (by decide)
      · -- processStep = addFutureWitness: doesn't change .past isWitnessed
        exfalso
        rw [h_ps_eq] at h_wit
        simp only [WitnessGraph.isWitnessed, WitnessGraph.addFutureWitness] at h_wit
        rw [List.zipIdx_append, List.any_append] at h_wit
        rw [Bool.or_eq_true] at h_wit
        rcases h_wit with h_old_part | h_new_part
        · simp only [WitnessGraph.isWitnessed] at h_prev_false
          rw [Bool.eq_false_iff] at h_prev_false
          apply h_prev_false
          simp only [List.any_eq_true] at h_old_part ⊢
          obtain ⟨⟨wo, idx⟩, h_mem, h_cond⟩ := h_old_part
          refine ⟨⟨wo, idx⟩, h_mem, ?_⟩
          simp only [Bool.and_eq_true, beq_iff_eq, Option.isSome_iff_exists] at h_cond ⊢
          obtain ⟨⟨h_ni, h_obl⟩, w, h_res⟩ := h_cond
          have h_idx_lt : idx < g.obligations.length := by have := (List.mem_zipIdx h_mem).2.1; omega
          rw [if_neg (Nat.ne_of_lt h_idx_lt)] at h_res
          exact ⟨⟨h_ni, h_obl⟩, w, h_res⟩
        · simp only [List.zipIdx_cons, List.zipIdx_nil, List.any_cons, List.any_nil, Bool.or_false,
                     Bool.and_eq_true] at h_new_part
          obtain ⟨⟨_, h_obl_eq⟩, _⟩ := h_new_part
          -- h_obl_eq has ObligationType.future ... == ObligationType.past ..., contradiction
          delta instBEqObligationType instBEqObligationType.beq at h_obl_eq
          simp at h_obl_eq
      · -- processStep = addPastWitness: isWitnessed became true via new obligation
        rw [h_ps_eq] at h_wit
        have ⟨h_nIdx_eq, h_psi_eq⟩ := addPastWitness_new_obl_matches g nIdx i psi' psi
          h_nIdx h_P' h_prev_false h_wit
        subst h_nIdx_eq; subst h_psi_eq
        use m + 1, g.nodes.length
        have h_j_bound : g.nodes.length < (buildWitnessGraph rootMCS (m + 1)).nodes.length := by
          simp only [buildWitnessGraph]
          rw [h_ps_eq]
          simp [WitnessGraph.addPastWitness, List.length_append]
        use h_j_bound
        constructor
        · -- Edge membership
          simp only [buildWitnessGraph]
          rw [h_ps_eq]
          simp [WitnessGraph.addPastWitness, List.mem_append]
        · -- psi' in the witness node's MCS
          have h_mem := addPastWitness_contains_formula g nIdx h_nIdx psi' h_P'
          have h_bound : g.nodes.length < (processStep g m).nodes.length := by
            rw [h_ps_eq]; simp [WitnessGraph.addPastWitness, List.length_append]
          simp only [buildWitnessGraph, WitnessGraph.nodeAt]
          have h_eq : ∀ (h1 : g.nodes.length < (processStep g m).nodes.length)
              (h2 : g.nodes.length < (g.addPastWitness nIdx h_nIdx psi' h_P').nodes.length),
              (processStep g m).nodes[g.nodes.length]'h1 =
              (g.addPastWitness nIdx h_nIdx psi' h_P').nodes[g.nodes.length]'h2 := by
            intro h1 h2; congr 1; exact h_ps_eq
          rw [h_eq h_bound (by simp [WitnessGraph.addPastWitness, List.length_append])]
          simp only [WitnessGraph.addPastWitness, List.getElem_append_right (Nat.le_refl _),
            Nat.sub_self, List.getElem_cons_zero]
          exact h_mem

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
  · -- Case: already witnessed - use inductive helper to extract witness
    exact forward_witness_of_isWitnessed rootMCS n i psi h_wit
  · -- Case: not yet witnessed - fresh witness created at step n+1
    have h_wit_false : g_n.isWitnessed i (.future psi) = false := by
      cases h_eq : g_n.isWitnessed i (.future psi) <;> simp_all
    have ⟨h_edge, h_len⟩ := processStep_creates_fresh_future_witness g_n n i h_i_at_n psi
      h_unpair h_F_at_n h_wit_false
    -- The witness node is at index g_n.nodes.length, in graph at step n+1
    use n + 1, g_n.nodes.length
    have h_j_bound : g_n.nodes.length < (buildWitnessGraph rootMCS (n + 1)).nodes.length := by
      simp only [buildWitnessGraph]
      rw [h_len.1]
      exact Nat.lt_succ_self _
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
      have h_bound : g_n.nodes.length < (processStep g_n n).nodes.length := by
        rw [h_len.1]; exact Nat.lt_succ_self _
      exact (h_len.2 h_bound).1

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
  -- Step 1: Find a step n >= k where the pair (i, encodeFormulaWG psi) is processed
  obtain ⟨n, h_n_ge_k, h_unpair⟩ := coverage_step_exists i psi k
  -- Step 2: Node i exists at step n (by monotonicity from step k)
  have h_i_at_n : i < (buildWitnessGraph rootMCS n).nodes.length :=
    lt_of_lt_of_le h_i (buildWitnessGraph_nodes_length_mono_le rootMCS k n h_n_ge_k)
  -- Step 3: P(psi) is in node i's MCS at step n (same MCS by stability)
  have h_node_stable := buildWitnessGraph_node_stable rootMCS k n h_n_ge_k i h_i
  have h_node_eq := getElem?_eq_implies_getElem_eq _ _ i h_i h_i_at_n h_node_stable.symm
  have h_P_at_n : Formula.some_past psi ∈
      ((buildWitnessGraph rootMCS n).nodeAt i h_i_at_n).mcs.val := by
    simp only [WitnessGraph.nodeAt] at h_P ⊢
    rw [← h_node_eq]
    exact h_P
  -- Step 4: Case split on whether the obligation is already witnessed
  let g_n := buildWitnessGraph rootMCS n
  by_cases h_wit : g_n.isWitnessed i (.past psi) = true
  · -- Case: already witnessed - use inductive helper
    exact backward_witness_of_isWitnessed rootMCS n i psi h_wit
  · -- Case: not yet witnessed - fresh witness created at step n+1
    -- Also need to check if F(psi) is in the MCS (processStep checks F first)
    have h_wit_false : g_n.isWitnessed i (.past psi) = false := by
      cases h_eq : g_n.isWitnessed i (.past psi) <;> simp_all
    by_cases h_F_at_n : Formula.some_future psi ∈ ((buildWitnessGraph rootMCS n).nodeAt i h_i_at_n).mcs.val
    · -- F(psi) is also in MCS - case split on whether F is already witnessed
      by_cases h_F_wit : g_n.isWitnessed i (.future psi) = true
      · -- F witnessed: processStep falls through to P branch at step n
        -- (new processStep behavior: when F witnessed, check P next)
        have ⟨h_edge, h_len⟩ := processStep_creates_past_witness_F_witnessed g_n n i h_i_at_n psi
          h_unpair h_F_at_n h_F_wit h_P_at_n h_wit_false
        use n + 1, g_n.nodes.length
        have h_j_bound : g_n.nodes.length < (buildWitnessGraph rootMCS (n + 1)).nodes.length := by
          simp only [buildWitnessGraph]; rw [h_len.1]; exact Nat.lt_succ_self _
        use h_j_bound
        constructor
        · simp only [buildWitnessGraph]; exact h_edge
        · have h_bound : g_n.nodes.length < (processStep g_n n).nodes.length := by
            rw [h_len.1]; exact Nat.lt_succ_self _
          exact (h_len.2 h_bound).1
      · -- F not witnessed: processStep creates future witness at n+1
        -- Find another coverage step n'' ≥ n+2 after F is witnessed
        have h_F_wit_false : g_n.isWitnessed i (.future psi) = false := by
          cases h : g_n.isWitnessed i (.future psi) <;> simp_all
        -- At step n+1, future witness is created (F not witnessed, F in MCS)
        -- F becomes witnessed at step n+1
        -- Find n'' ≥ n+2 where (i, psi) is processed again
        obtain ⟨n'', h_n''_ge, h_unpair''⟩ := coverage_step_exists i psi (n + 2)
        -- At n'', node i still exists
        have h_i_at_n'' : i < (buildWitnessGraph rootMCS n'').nodes.length :=
          lt_of_lt_of_le h_i_at_n
            (buildWitnessGraph_nodes_length_mono_le rootMCS n n''
              (by omega))
        -- P(psi) still in MCS at n'' (by node stability)
        have h_node_stable_n'' := buildWitnessGraph_node_stable rootMCS n n'' (by omega) i h_i_at_n
        have h_node_eq_n'' := getElem?_eq_implies_getElem_eq _ _ i h_i_at_n h_i_at_n'' h_node_stable_n''.symm
        have h_P_at_n'' : Formula.some_past psi ∈
            ((buildWitnessGraph rootMCS n'').nodeAt i h_i_at_n'').mcs.val := by
          simp only [WitnessGraph.nodeAt] at h_P_at_n ⊢; rw [← h_node_eq_n'']; exact h_P_at_n
        -- F(psi) in MCS at n'' (by stability)
        have h_F_at_n'' : Formula.some_future psi ∈
            ((buildWitnessGraph rootMCS n'').nodeAt i h_i_at_n'').mcs.val := by
          simp only [WitnessGraph.nodeAt] at h_F_at_n ⊢; rw [← h_node_eq_n'']; exact h_F_at_n
        -- At step n+1, F becomes witnessed (processStep creates future witness)
        -- Use forward_witness_of_isWitnessed on the witness created at n+1
        -- Instead: the processStep at n creates a future witness, making isWitnessed true
        -- Use the fact that processStep adds an obligation that is resolved
        -- Direct approach: show that the obligation at step n+1 has the witness
        have h_F_wit_at_n1 : (buildWitnessGraph rootMCS (n + 1)).isWitnessed i (.future psi) = true := by
          -- At step n, processStep creates a future witness
          -- This means the F obligation for (i, psi) is added and resolved in one step
          -- processStep_outcome tells us processStep = addFutureWitness
          -- Then addFutureWitness adds obligation and resolves it
          -- So isWitnessed becomes true
          simp only [buildWitnessGraph]
          -- Unfold isWitnessed on the processStep result
          -- Since F not witnessed at step n, processStep creates addFutureWitness
          -- The new obligation has i, .future psi, and is resolved to g_n.nodes.length
          -- Use the monotonicity: if processStep adds an obligation that is self-resolved, isWitnessed = true
          -- For now, use a direct simp-based proof
          unfold processStep
          simp only [h_unpair, show i < g_n.nodes.length from h_i_at_n, dite_true]
          have h_decode := decodeFormulaWG_encodeFormulaWG psi
          split
          · rename_i h_none; rw [h_decode] at h_none; exact absurd h_none nofun
          · rename_i psi_1 h_some; rw [h_decode] at h_some; cases h_some
            simp only [dite_true, ite_false, Bool.false_eq_true]
            split
            · -- F(psi) in MCS: take the addFutureWitness branch
              split
              · -- F witnessed: contradiction with h_F_wit_false
                rename_i h_F_wit_true
                rw [h_F_wit_false] at h_F_wit_true
                exact absurd h_F_wit_true (by decide)
              · -- F not witnessed: addFutureWitness
                simp only [WitnessGraph.isWitnessed, WitnessGraph.addFutureWitness]
                rw [List.zipIdx_append, List.any_append, Bool.or_eq_true]
                right
                simp only [List.zipIdx_cons, List.zipIdx_nil, List.any_cons, List.any_nil, Bool.or_false,
                  Bool.and_eq_true, Option.isSome_iff_exists]
                refine ⟨⟨beq_self_eq_true i, ?_⟩, ⟨g_n.nodes.length, by simp⟩⟩
                simp only [BEq.beq]
                exact beq_self_eq_true psi
            · -- F(psi) not in MCS: contradiction with h_F_at_n
              rename_i h_not_F
              exact absurd h_F_at_n h_not_F
        -- F is witnessed at n'' (monotone from n+1 ≤ n'' since n'' ≥ n+2)
        have h_F_wit_at_n'' : (buildWitnessGraph rootMCS n'').isWitnessed i (.future psi) = true :=
          buildWitnessGraph_isWitnessed_monotone rootMCS (n + 1) n'' (by omega) i
            (.future psi) h_F_wit_at_n1
        -- Now case split on P witnessed at n''
        by_cases h_P_wit_at_n'' : (buildWitnessGraph rootMCS n'').isWitnessed i (.past psi) = true
        · -- P already witnessed at n'': use backward_witness_of_isWitnessed
          exact backward_witness_of_isWitnessed rootMCS n'' i psi h_P_wit_at_n''
        · -- P not witnessed at n'': processStep at n'' creates past witness
          have h_P_wit_false_n'' : (buildWitnessGraph rootMCS n'').isWitnessed i (.past psi) = false := by
            cases h : (buildWitnessGraph rootMCS n'').isWitnessed i (.past psi) <;> simp_all
          have ⟨h_edge'', h_len''⟩ := processStep_creates_past_witness_F_witnessed
            (buildWitnessGraph rootMCS n'') n'' i h_i_at_n'' psi
            h_unpair'' h_F_at_n'' h_F_wit_at_n'' h_P_at_n'' h_P_wit_false_n''
          use n'' + 1, (buildWitnessGraph rootMCS n'').nodes.length
          have h_j_bound'' : (buildWitnessGraph rootMCS n'').nodes.length <
              (buildWitnessGraph rootMCS (n'' + 1)).nodes.length := by
            simp only [buildWitnessGraph]; rw [h_len''.1]; exact Nat.lt_succ_self _
          use h_j_bound''
          constructor
          · simp only [buildWitnessGraph]; exact h_edge''
          · have h_bound'' : (buildWitnessGraph rootMCS n'').nodes.length <
                (processStep (buildWitnessGraph rootMCS n'') n'').nodes.length := by
              rw [h_len''.1]; exact Nat.lt_succ_self _
            exact (h_len''.2 h_bound'').1
    · -- F(psi) is not in MCS - processStep will process P
      have h_not_F : Formula.some_future psi ∉ (g_n.nodeAt i h_i_at_n).mcs.val := h_F_at_n
      have ⟨h_edge, h_len⟩ := processStep_creates_fresh_past_witness g_n n i h_i_at_n psi
        h_unpair h_not_F h_P_at_n h_wit_false
      use n + 1, g_n.nodes.length
      have h_j_bound : g_n.nodes.length < (buildWitnessGraph rootMCS (n + 1)).nodes.length := by
        simp only [buildWitnessGraph]
        rw [h_len.1]
        exact Nat.lt_succ_self _
      use h_j_bound
      constructor
      · simp only [buildWitnessGraph]
        exact h_edge
      · have h_bound : g_n.nodes.length < (processStep g_n n).nodes.length := by
          rw [h_len.1]; exact Nat.lt_succ_self _
        exact (h_len.2 h_bound).1

/-- **Theorem 5: Acyclicity**

The edge relation in the witness graph has no cycles. Each edge connects a source
node (with lower index) to a witness node (with higher index), so the edge relation
is well-founded on node indices. -/
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
        · split  -- if F witnessed
          · split  -- if P in MCS
            · split  -- if P witnessed
              · exact Nat.le_succ _
              · simp [WitnessGraph.addPastWitness]
            · exact Nat.le_succ _
          · simp [WitnessGraph.addFutureWitness]
        · split
          · split
            · exact Nat.le_succ _
            · simp [WitnessGraph.addPastWitness]
          · exact Nat.le_succ _
    · exact Nat.le_succ _

/-!
### Edge Validity (well-formedness of edge indices)

All edges in buildWitnessGraph reference valid node indices.
This is needed for the content propagation proofs: when an edge is "old"
(inherited from a previous step), we need to know both endpoints are valid
at the earlier step to apply node stability.
-/

/-- When processStep adds any edge, the node count increases strictly. -/
private lemma processStep_new_edge_nodes_gt (g : WitnessGraph) (n : Nat)
    (h_new : (∃ sourceIdx : Nat, sourceIdx < g.nodes.length ∧
        (processStep g n).edges = g.edges ++ [⟨sourceIdx, g.nodes.length, .forward⟩]) ∨
      (∃ sourceIdx : Nat, sourceIdx < g.nodes.length ∧
        (processStep g n).edges = g.edges ++ [⟨sourceIdx, g.nodes.length, .backward⟩])) :
    g.nodes.length < (processStep g n).nodes.length := by
  -- Use processStep_outcome to characterize the result
  have h_out := processStep_outcome g n
  rcases h_out with h_unchanged | ⟨nIdx, h_nIdx, psi, h_F, h_ps_eq⟩ |
      ⟨nIdx, h_nIdx, psi, h_P, h_ps_eq⟩
  · -- g unchanged: contradicts h_new (no new edge)
    rcases h_new with ⟨src, _, h_edges⟩ | ⟨src, _, h_edges⟩
    · rw [h_unchanged] at h_edges
      have : g.edges.length = (g.edges ++ [_]).length := by rw [h_edges]
      simp [List.length_append] at this
    · rw [h_unchanged] at h_edges
      have : g.edges.length = (g.edges ++ [_]).length := by rw [h_edges]
      simp [List.length_append] at this
  · -- addFutureWitness: nodes.length = g.nodes.length + 1
    rw [h_ps_eq]; simp [WitnessGraph.addFutureWitness]
  · -- addPastWitness: nodes.length = g.nodes.length + 1
    rw [h_ps_eq]; simp [WitnessGraph.addPastWitness]

/-- processStep preserves edge validity and maintains it for new edges. -/
private lemma processStep_edgesValid (g : WitnessGraph) (n : Nat)
    (h_valid : g.edgesValid) :
    (processStep g n).edgesValid := by
  intro e h_e
  have h_ge := processStep_nodes_length_ge g n
  have h_cases := processStep_edges_subset_or_new g n
  rcases h_cases with h_same | ⟨src, h_src, h_eq⟩ | ⟨src, h_src, h_eq⟩
  · -- Graph unchanged: edges are g.edges, so use h_valid + monotonicity
    have h_old := h_same e h_e
    have ⟨h_s, h_d⟩ := h_valid e h_old
    exact ⟨lt_of_lt_of_le h_s h_ge, lt_of_lt_of_le h_d h_ge⟩
  · -- Forward edge added
    have h_gt := processStep_new_edge_nodes_gt g n (Or.inl ⟨src, h_src, h_eq⟩)
    rw [h_eq] at h_e
    rcases List.mem_append.mp h_e with h_old | h_new
    · have ⟨h_s, h_d⟩ := h_valid e h_old
      exact ⟨lt_of_lt_of_le h_s h_ge, lt_of_lt_of_le h_d h_ge⟩
    · simp at h_new; rw [h_new]
      exact ⟨lt_of_lt_of_le h_src h_ge, h_gt⟩
  · -- Backward edge added
    have h_gt := processStep_new_edge_nodes_gt g n (Or.inr ⟨src, h_src, h_eq⟩)
    rw [h_eq] at h_e
    rcases List.mem_append.mp h_e with h_old | h_new
    · have ⟨h_s, h_d⟩ := h_valid e h_old
      exact ⟨lt_of_lt_of_le h_s h_ge, lt_of_lt_of_le h_d h_ge⟩
    · simp at h_new; rw [h_new]
      exact ⟨lt_of_lt_of_le h_src h_ge, h_gt⟩

/-- All edges in buildWitnessGraph reference valid node indices. -/
theorem buildWitnessGraph_edgesValid (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (k : Nat) : (buildWitnessGraph rootMCS k).edgesValid := by
  induction k with
  | zero => exact initialWitnessGraph_edgesValid rootMCS
  | succ n ih =>
    simp only [buildWitnessGraph]
    exact processStep_edgesValid _ _ ih

/-!
### Content Propagation Through Edges

The main theorems: forward edges propagate GContent, backward edges propagate HContent.
-/

/-- **Theorem 3: GContent Propagation**

For any forward edge (i, j) in the witness graph, GContent of node i's
MCS is a subset of node j's MCS.

Proof by induction on the construction step k:
- Base: no edges at step 0
- Inductive: the edge is either inherited (use IH + node stability)
  or freshly created by addFutureWitness (use seed construction property). -/
theorem witnessGraph_GContent_propagates (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (i j : Nat) (k : Nat)
    (h_i : i < (buildWitnessGraph rootMCS k).nodes.length)
    (h_j : j < (buildWitnessGraph rootMCS k).nodes.length)
    (h_edge : (⟨i, j, .forward⟩ : WitnessEdge) ∈ (buildWitnessGraph rootMCS k).edges) :
    GContent ((buildWitnessGraph rootMCS k).nodeAt i h_i).mcs.val ⊆
      ((buildWitnessGraph rootMCS k).nodeAt j h_j).mcs.val := by
  induction k with
  | zero =>
    simp [buildWitnessGraph, initialWitnessGraph] at h_edge
  | succ n ih =>
    simp only [buildWitnessGraph] at h_edge h_i h_j ⊢
    let g := buildWitnessGraph rootMCS n
    have h_cases := processStep_edges_subset_or_new g n
    rcases h_cases with h_same | ⟨src, h_src, h_eq⟩ | ⟨src, h_src, h_eq⟩
    · -- Case: edges unchanged (processStep returned g unchanged modulo edges)
      have h_old := h_same _ h_edge
      -- Both i and j are valid in g (from edge validity)
      have h_ev := buildWitnessGraph_edgesValid rootMCS n
      have ⟨h_i_valid, h_j_valid⟩ := h_ev _ h_old
      simp [WitnessEdge.valid] at h_i_valid h_j_valid
      -- By IH: GContent(mcs_i at step n) ⊆ mcs_j at step n
      have h_ih := ih h_i_valid h_j_valid h_old
      -- Nodes are stable from step n to step n+1
      have h_stable_i := processStep_node_preserved g n i h_i_valid
      have h_stable_j := processStep_node_preserved g n j h_j_valid
      -- mcs_i at step n+1 = mcs_i at step n
      have h_eq_i := getElem?_eq_implies_getElem_eq _ _ i h_i_valid h_i h_stable_i.symm
      have h_eq_j := getElem?_eq_implies_getElem_eq _ _ j h_j_valid h_j h_stable_j.symm
      simp only [WitnessGraph.nodeAt] at h_ih ⊢
      rw [← h_eq_i, ← h_eq_j]
      exact h_ih
    · -- Case: processStep added a forward edge (src, g.nodes.length, .forward)
      rw [h_eq] at h_edge
      simp [List.mem_append] at h_edge
      rcases h_edge with h_old | h_new
      · -- Old edge from step n
        have h_ev := buildWitnessGraph_edgesValid rootMCS n
        have ⟨h_i_valid, h_j_valid⟩ := h_ev _ h_old
        simp [WitnessEdge.valid] at h_i_valid h_j_valid
        have h_ih := ih h_i_valid h_j_valid h_old
        have h_stable_i := processStep_node_preserved g n i h_i_valid
        have h_stable_j := processStep_node_preserved g n j h_j_valid
        have h_eq_i := getElem?_eq_implies_getElem_eq _ _ i h_i_valid h_i h_stable_i.symm
        have h_eq_j := getElem?_eq_implies_getElem_eq _ _ j h_j_valid h_j h_stable_j.symm
        simp only [WitnessGraph.nodeAt] at h_ih ⊢
        rw [← h_eq_i, ← h_eq_j]
        exact h_ih
      · -- New edge: i = src, j = g.nodes.length
        obtain ⟨h_i_eq, h_j_eq⟩ := h_new
        subst h_i_eq; subst h_j_eq
        -- Source node exists in g and is preserved
        have h_stable_src := processStep_node_preserved g n i h_src
        have h_eq_src := getElem?_eq_implies_getElem_eq _ _ i h_src h_i h_stable_src.symm
        simp only [WitnessGraph.nodeAt] at h_eq_src ⊢
        rw [← h_eq_src]
        -- processStep created a fresh forward witness with GContent propagation
        -- Use processStep_creates_fresh_future_witness or unfold directly
        -- The new node at g.nodes.length has MCS extending GContent(source)
        -- We need to connect the processStep result to the addFutureWitness properties
        -- Let's unfold processStep to extract the GContent property
        unfold processStep at h_j ⊢
        split; split at h_j  -- first unpair
        split; split at h_j  -- second unpair
        split; split at h_j  -- if nodeIdx < length
        · rename_i h_node
          split; split at h_j  -- match decode
          · -- none: contradicts h_eq (would not add new edge)
            simp at h_eq
          · rename_i psi
            split; split at h_j  -- if F(psi)
            · rename_i h_F
              split; split at h_j  -- if witnessed
              · simp at h_eq  -- contradicts new edge being added
              · -- addFutureWitness branch
                -- h_eq tells us: addFutureWitness edges = g.edges ++ [(nodeIdx, g.nodes.length, .forward)]
                -- And we're looking at src = nodeIdx, dst = g.nodes.length
                simp only [WitnessGraph.addFutureWitness] at h_eq h_j ⊢
                -- Extract that source node matches
                have h_src_match : (Nat.unpair (Nat.unpair n).2).1 = src := by
                  have := List.append_cancel_left h_eq
                  simp at this; exact this.1
                simp only [WitnessGraph.nodeAt, List.getElem_append_right (Nat.le_refl _),
                  Nat.sub_self, List.getElem_cons_zero]
                rw [← h_src_match] at h_src
                conv_lhs => rw [show (g.nodes ++ [_])[src] = g.nodes[src] from by
                  rw [List.getElem_append_left h_src]]
                rw [h_src_match]
                exact addFutureWitness_GContent_extends g _ h_node _ h_F
            · split; split at h_j  -- if P(psi)
              · split; split at h_j  -- if witnessed
                · simp at h_eq
                · -- addPastWitness: backward edge, contradicts forward in h_eq
                  simp only [WitnessGraph.addPastWitness] at h_eq
                  have := List.append_cancel_left h_eq
                  simp at this
              · simp at h_eq
        · simp at h_eq
    · -- Case: processStep added a backward edge - impossible for forward edge
      -- After simp, the new backward edge is eliminated (forward ≠ backward)
      -- so h_edge is already just the old edge membership
      rw [h_eq] at h_edge
      simp [List.mem_append, WitnessEdge.mk.injEq] at h_edge
      -- h_edge now is: ⟨i, j, .forward⟩ ∈ g.edges (backward case eliminated)
      have h_ev := buildWitnessGraph_edgesValid rootMCS n
      have ⟨h_i_valid, h_j_valid⟩ := h_ev _ h_edge
      simp [WitnessEdge.valid] at h_i_valid h_j_valid
      have h_ih := ih h_i_valid h_j_valid h_edge
      have h_stable_i := processStep_node_preserved g n i h_i_valid
      have h_stable_j := processStep_node_preserved g n j h_j_valid
      have h_eq_i := getElem?_eq_implies_getElem_eq _ _ i h_i_valid h_i h_stable_i.symm
      have h_eq_j := getElem?_eq_implies_getElem_eq _ _ j h_j_valid h_j h_stable_j.symm
      simp only [WitnessGraph.nodeAt] at h_ih ⊢
      rw [← h_eq_i, ← h_eq_j]
      exact h_ih

/-- **Theorem 4: HContent Propagation**

For any backward edge (i, j) in the witness graph, HContent of node i's
MCS is a subset of node j's MCS. Symmetric to GContent propagation. -/
theorem witnessGraph_HContent_propagates (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (i j : Nat) (k : Nat)
    (h_i : i < (buildWitnessGraph rootMCS k).nodes.length)
    (h_j : j < (buildWitnessGraph rootMCS k).nodes.length)
    (h_edge : (⟨i, j, .backward⟩ : WitnessEdge) ∈ (buildWitnessGraph rootMCS k).edges) :
    HContent ((buildWitnessGraph rootMCS k).nodeAt i h_i).mcs.val ⊆
      ((buildWitnessGraph rootMCS k).nodeAt j h_j).mcs.val := by
  induction k with
  | zero =>
    simp [buildWitnessGraph, initialWitnessGraph] at h_edge
  | succ n ih =>
    simp only [buildWitnessGraph] at h_edge h_i h_j ⊢
    let g := buildWitnessGraph rootMCS n
    have h_cases := processStep_edges_subset_or_new g n
    rcases h_cases with h_same | ⟨src, h_src, h_eq⟩ | ⟨src, h_src, h_eq⟩
    · -- Case: edges unchanged
      have h_old := h_same _ h_edge
      have h_ev := buildWitnessGraph_edgesValid rootMCS n
      have ⟨h_i_valid, h_j_valid⟩ := h_ev _ h_old
      simp [WitnessEdge.valid] at h_i_valid h_j_valid
      have h_ih := ih h_i_valid h_j_valid h_old
      have h_stable_i := processStep_node_preserved g n i h_i_valid
      have h_stable_j := processStep_node_preserved g n j h_j_valid
      have h_eq_i := getElem?_eq_implies_getElem_eq _ _ i h_i_valid h_i h_stable_i.symm
      have h_eq_j := getElem?_eq_implies_getElem_eq _ _ j h_j_valid h_j h_stable_j.symm
      simp only [WitnessGraph.nodeAt] at h_ih ⊢
      rw [← h_eq_i, ← h_eq_j]
      exact h_ih
    · -- Case: processStep added a forward edge - backward edge can't match
      -- After simp, the new forward edge is eliminated (backward ≠ forward)
      rw [h_eq] at h_edge
      simp [List.mem_append, WitnessEdge.mk.injEq] at h_edge
      have h_ev := buildWitnessGraph_edgesValid rootMCS n
      have ⟨h_i_valid, h_j_valid⟩ := h_ev _ h_edge
      simp [WitnessEdge.valid] at h_i_valid h_j_valid
      have h_ih := ih h_i_valid h_j_valid h_edge
      have h_stable_i := processStep_node_preserved g n i h_i_valid
      have h_stable_j := processStep_node_preserved g n j h_j_valid
      have h_eq_i := getElem?_eq_implies_getElem_eq _ _ i h_i_valid h_i h_stable_i.symm
      have h_eq_j := getElem?_eq_implies_getElem_eq _ _ j h_j_valid h_j h_stable_j.symm
      simp only [WitnessGraph.nodeAt] at h_ih ⊢
      rw [← h_eq_i, ← h_eq_j]
      exact h_ih
    · -- Case: processStep added a backward edge
      rw [h_eq] at h_edge
      simp [List.mem_append] at h_edge
      rcases h_edge with h_old | h_new
      · -- Old edge
        have h_ev := buildWitnessGraph_edgesValid rootMCS n
        have ⟨h_i_valid, h_j_valid⟩ := h_ev _ h_old
        simp [WitnessEdge.valid] at h_i_valid h_j_valid
        have h_ih := ih h_i_valid h_j_valid h_old
        have h_stable_i := processStep_node_preserved g n i h_i_valid
        have h_stable_j := processStep_node_preserved g n j h_j_valid
        have h_eq_i := getElem?_eq_implies_getElem_eq _ _ i h_i_valid h_i h_stable_i.symm
        have h_eq_j := getElem?_eq_implies_getElem_eq _ _ j h_j_valid h_j h_stable_j.symm
        simp only [WitnessGraph.nodeAt] at h_ih ⊢
        rw [← h_eq_i, ← h_eq_j]
        exact h_ih
      · -- New edge: i = src, j = g.nodes.length
        obtain ⟨h_i_eq, h_j_eq⟩ := h_new
        subst h_i_eq; subst h_j_eq
        have h_stable_src := processStep_node_preserved g n i h_src
        have h_eq_src := getElem?_eq_implies_getElem_eq _ _ i h_src h_i h_stable_src.symm
        simp only [WitnessGraph.nodeAt] at h_eq_src ⊢
        rw [← h_eq_src]
        -- Unfold processStep to get to the addPastWitness branch
        unfold processStep at h_j ⊢
        split; split at h_j
        split; split at h_j
        split; split at h_j
        · rename_i h_node
          split; split at h_j
          · simp at h_eq
          · rename_i psi
            split; split at h_j
            · split; split at h_j
              · simp at h_eq
              · -- addFutureWitness: forward edge, contradicts backward in h_eq
                simp only [WitnessGraph.addFutureWitness] at h_eq
                have := List.append_cancel_left h_eq
                simp at this
            · split; split at h_j
              · rename_i h_P
                split; split at h_j
                · simp at h_eq
                · -- addPastWitness branch
                  simp only [WitnessGraph.addPastWitness] at h_eq h_j ⊢
                  have h_src_match : (Nat.unpair (Nat.unpair n).2).1 = src := by
                    have := List.append_cancel_left h_eq
                    simp at this; exact this.1
                  simp only [WitnessGraph.nodeAt, List.getElem_append_right (Nat.le_refl _),
                    Nat.sub_self, List.getElem_cons_zero]
                  rw [← h_src_match] at h_src
                  conv_lhs => rw [show (g.nodes ++ [_])[src] = g.nodes[src] from by
                    rw [List.getElem_append_left h_src]]
                  rw [h_src_match]
                  exact addPastWitness_HContent_extends g _ h_node _ h_P
              · simp at h_eq
        · simp at h_eq

end Bimodal.Metalogic.Bundle
