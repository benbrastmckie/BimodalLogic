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
          -- Transport through struct equality to field equality
          have h_nodes_eq := congrArg WitnessGraph.nodes h_ps_eq
          have h_eq : ∀ (h1 : g.nodes.length < (processStep g m).nodes.length)
              (h2 : g.nodes.length < (g.addFutureWitness nIdx h_nIdx psi' h_F').nodes.length),
              (processStep g m).nodes[g.nodes.length]'h1 =
              (g.addFutureWitness nIdx h_nIdx psi' h_F').nodes[g.nodes.length]'h2 := by
            intro h1 h2; simp [h_nodes_eq]
          rw [h_eq h_bound (by simp [WitnessGraph.addFutureWitness, List.length_append])]
          simp only [WitnessGraph.addFutureWitness, List.getElem_append_right (Nat.le_refl _),
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
            intro h1 h2; have := congrArg WitnessGraph.nodes h_ps_eq; simp [this]
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
          -- Rewrite decode BEFORE split to collapse the match
          simp only [h_decode]
          -- Collapse the nested ifs using known facts
          simp only [h_i_at_n, dite_true, h_F_at_n]
          rw [h_F_wit_false]; simp
          -- We're now in the addFutureWitness branch directly
          simp only [WitnessGraph.isWitnessed, WitnessGraph.addFutureWitness]
          rw [List.zipIdx_append, List.any_append, Bool.or_eq_true]
          right
          simp only [List.zipIdx_cons, List.zipIdx_nil, List.any_cons, List.any_nil, Bool.or_false,
            Bool.and_eq_true, Option.isSome_iff_exists]
          refine ⟨⟨beq_self_eq_true i, ?_⟩, ⟨g_n.nodes.length, ?_⟩⟩
          · change (psi == psi) = true; exact beq_self_eq_true psi
          · simp [Nat.zero_add, show g_n = buildWitnessGraph rootMCS n from rfl]
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
      have := congrArg List.length h_edges
      simp at this
    · rw [h_unchanged] at h_edges
      have := congrArg List.length h_edges
      simp at this
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
        -- Use processStep_outcome to avoid unfold processStep
        have h_out := processStep_outcome g n
        rcases h_out with h_unchanged | ⟨nIdx, h_nIdx, psi, h_F, h_ps_eq⟩ |
            ⟨nIdx, h_nIdx, psi, h_P, h_ps_eq⟩
        · -- unchanged: contradicts h_eq (no new edges)
          rw [h_unchanged] at h_eq
          have := congrArg List.length h_eq; simp at this
        · -- addFutureWitness: forward edge added
          have h_nodes_eq := congrArg WitnessGraph.nodes h_ps_eq
          have h_edges_eq := congrArg WitnessGraph.edges h_ps_eq
          simp only [WitnessGraph.addFutureWitness] at h_edges_eq
          rw [h_edges_eq] at h_eq
          have h_src_eq : nIdx = i := by
            have h_cancel := List.append_cancel_left h_eq
            simp [List.cons.injEq, WitnessEdge.mk.injEq] at h_cancel
            exact h_cancel
          subst h_src_eq
          -- Transport the node at j = g.nodes.length through struct equality
          have h_j_eq : ∀ (h1 : g.nodes.length < (processStep g n).nodes.length)
              (h2 : g.nodes.length < (g.addFutureWitness nIdx h_nIdx psi h_F).nodes.length),
              (processStep g n).nodes[g.nodes.length]'h1 =
              (g.addFutureWitness nIdx h_nIdx psi h_F).nodes[g.nodes.length]'h2 := by
            intro h1 h2; simp [h_nodes_eq]
          rw [h_j_eq h_j (by simp [WitnessGraph.addFutureWitness])]
          simp only [WitnessGraph.addFutureWitness, List.getElem_append_right (Nat.le_refl _),
            Nat.sub_self, List.getElem_cons_zero]
          exact addFutureWitness_GContent_extends g nIdx h_nIdx psi h_F
        · -- addPastWitness: backward edge, contradicts forward edge in h_eq
          have h_edges_eq := congrArg WitnessGraph.edges h_ps_eq
          simp only [WitnessGraph.addPastWitness] at h_edges_eq
          rw [h_edges_eq] at h_eq
          have := List.append_cancel_left h_eq; simp at this
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
        -- Use processStep_outcome to avoid unfold processStep
        have h_out := processStep_outcome g n
        rcases h_out with h_unchanged | ⟨nIdx, h_nIdx, psi, h_F, h_ps_eq⟩ |
            ⟨nIdx, h_nIdx, psi, h_P, h_ps_eq⟩
        · -- unchanged: contradicts h_eq (no new edges)
          rw [h_unchanged] at h_eq
          have := congrArg List.length h_eq; simp at this
        · -- addFutureWitness: forward edge, contradicts backward in h_eq
          have h_edges_eq := congrArg WitnessGraph.edges h_ps_eq
          simp only [WitnessGraph.addFutureWitness] at h_edges_eq
          rw [h_edges_eq] at h_eq
          have := List.append_cancel_left h_eq; simp at this
        · -- addPastWitness: backward edge added
          have h_nodes_eq := congrArg WitnessGraph.nodes h_ps_eq
          have h_edges_eq := congrArg WitnessGraph.edges h_ps_eq
          simp only [WitnessGraph.addPastWitness] at h_edges_eq
          rw [h_edges_eq] at h_eq
          have h_src_eq : nIdx = i := by
            have h_cancel := List.append_cancel_left h_eq
            simp [List.cons.injEq, WitnessEdge.mk.injEq] at h_cancel
            exact h_cancel
          subst h_src_eq
          have h_j_eq : ∀ (h1 : g.nodes.length < (processStep g n).nodes.length)
              (h2 : g.nodes.length < (g.addPastWitness nIdx h_nIdx psi h_P).nodes.length),
              (processStep g n).nodes[g.nodes.length]'h1 =
              (g.addPastWitness nIdx h_nIdx psi h_P).nodes[g.nodes.length]'h2 := by
            intro h1 h2; simp [h_nodes_eq]
          rw [h_j_eq h_j (by simp [WitnessGraph.addPastWitness])]
          simp only [WitnessGraph.addPastWitness, List.getElem_append_right (Nat.le_refl _),
            Nat.sub_self, List.getElem_cons_zero]
          exact addPastWitness_HContent_extends g nIdx h_nIdx psi h_P

/-!
## Phase 4: Int Embedding

Define a BFMCS Int from the witness graph construction.

### Design Overview

The witness graph creates a directed acyclic graph where each node holds an MCS.
For the completeness proof, we need a BFMCS Int (a family of MCS indexed by Int)
that satisfies:
1. `forward_G`: G(phi) at time t implies phi at all future times t' > t
2. `backward_H`: H(phi) at time t implies phi at all past times t' < t
3. Context Gamma at time 0

Forward_F and backward_P (existential witnesses) are proved separately in Phase 5.

### Approach: Constant Family with Witness Graph Oracle

We use the root MCS as a constant family (all times map to the same MCS).
The T-axiom (G phi -> phi, H phi -> phi) gives forward_G and backward_H trivially.

The witness graph serves as an "oracle" for Phase 5/6: it provides the proof
that for any F(psi) or P(psi) in the root MCS, there exists a witness node
with psi in its MCS. Phase 5 will connect these witnesses to prove forward_F
and backward_P via a more sophisticated construction if needed.

### Mathematical Note

A direct node-index-to-Int embedding (mapping node i to integer i) would NOT
give forward_G, because the witness graph contains both forward and backward
edges, and GContent only propagates along forward edges. Backward edges give
HContent propagation, not GContent. So two consecutive nodes (by index) that
are connected by a backward edge would violate forward_G.

The constant family sidesteps this issue entirely. Phase 5 may introduce a
non-constant construction (e.g., a GContent chain with witness placement)
if needed for forward_F.
-/

/-- T-axiom helper: G(phi) in an MCS implies phi in the same MCS.
Uses the axiom temp_t_future: G(phi) -> phi. -/
lemma mcs_G_implies_self {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_G : Formula.all_future phi ∈ M) : phi ∈ M := by
  have h_T := Bimodal.ProofSystem.DerivationTree.axiom []
    (phi.all_future.imp phi) (Bimodal.ProofSystem.Axiom.temp_t_future phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G

/-- T-axiom helper: H(phi) in an MCS implies phi in the same MCS.
Uses the axiom temp_t_past: H(phi) -> phi. -/
lemma mcs_H_implies_self {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_H : Formula.all_past phi ∈ M) : phi ∈ M := by
  have h_T := Bimodal.ProofSystem.DerivationTree.axiom []
    (phi.all_past.imp phi) (Bimodal.ProofSystem.Axiom.temp_t_past phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H

/-- 4-axiom helper: G(phi) in an MCS implies G(G(phi)) in the same MCS.
Uses the axiom temp_4: G(phi) -> G(G(phi)). -/
lemma mcs_G_implies_GG {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_G : Formula.all_future phi ∈ M) :
    Formula.all_future (Formula.all_future phi) ∈ M := by
  have h_4 := Bimodal.ProofSystem.DerivationTree.axiom []
    ((Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)))
    (Bimodal.ProofSystem.Axiom.temp_4 phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_4) h_G

/-- The BFMCS Int constructed from the witness graph.

Maps every integer to the root MCS. Forward_G and backward_H hold by the
T-axiom. Context preservation at time 0 is immediate.

This provides the structural skeleton for the completeness proof. The witness
graph's local F/P properties connect to this family via the root MCS identity. -/
noncomputable def witnessGraphBFMCS
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) : BFMCS Int where
  mcs _ := rootMCS.val
  is_mcs _ := rootMCS.property
  forward_G := fun _ _ phi _ h_G =>
    mcs_G_implies_self rootMCS.property phi h_G
  backward_H := fun _ _ phi _ h_H =>
    mcs_H_implies_self rootMCS.property phi h_H

/-- The MCS at any time in the witness graph BFMCS is the root MCS. -/
@[simp] lemma witnessGraphBFMCS_mcs_eq
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) (t : Int) :
    (witnessGraphBFMCS rootMCS).mcs t = rootMCS.val := rfl

/-- The root MCS is preserved at time 0. -/
lemma witnessGraphBFMCS_root_preserved
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) :
    ∀ phi ∈ rootMCS.val, phi ∈ (witnessGraphBFMCS rootMCS).mcs 0 :=
  fun _ h => h

/-- For any node i in the witness graph at step k, the MCS at node i
is maximal consistent. This is a basic accessor used in Phase 5. -/
lemma witnessGraph_node_is_mcs
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (k : Nat) (i : Nat) (h_i : i < (buildWitnessGraph rootMCS k).nodes.length) :
    SetMaximalConsistent ((buildWitnessGraph rootMCS k).mcsAt i h_i) :=
  WitnessGraph.mcsAt_is_mcs _ _ _

/-- The root node (index 0) in the witness graph at any step has the root MCS.
This connects the witness graph's node 0 to the BFMCS's time 0. -/
lemma witnessGraph_root_mcs
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (k : Nat) (h_pos : 0 < (buildWitnessGraph rootMCS k).nodes.length) :
    (buildWitnessGraph rootMCS k).mcsAt 0 h_pos = rootMCS.val := by
  simp only [WitnessGraph.mcsAt, WitnessGraph.nodeAt]
  induction k with
  | zero =>
    simp [buildWitnessGraph, initialWitnessGraph]
  | succ n ih =>
    have h_pos_n : 0 < (buildWitnessGraph rootMCS n).nodes.length :=
      buildWitnessGraph_nonempty rootMCS n
    have h_stable := processStep_node_preserved (buildWitnessGraph rootMCS n) n 0 h_pos_n
    simp only [buildWitnessGraph]
    have h_eq := getElem?_eq_implies_getElem_eq
      (processStep (buildWitnessGraph rootMCS n) n).nodes
      (buildWitnessGraph rootMCS n).nodes
      0 h_pos h_pos_n h_stable
    rw [h_eq]
    exact ih h_pos_n

/-- The embedding preserves strict ordering on edges: for any edge in the
witness graph, src < dst when lifted to Int. This ensures the witness graph's
acyclicity is compatible with integer ordering. -/
theorem witnessGraphBFMCS_edge_ordering_compatible
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (k : Nat) (e : WitnessEdge) (h_e : e ∈ (buildWitnessGraph rootMCS k).edges) :
    (e.src : Int) < (e.dst : Int) := by
  have h_acyclic := witnessGraph_edges_acyclic rootMCS k e h_e
  exact Int.ofNat_lt.mpr h_acyclic

/-!
### Witness Graph Properties

These lemmas connect the witness graph's local properties to the BFMCS.

**Note**: The witness graph proves LOCAL witness existence (for any single F/P
obligation, a consistent witness MCS can be constructed). However, integrating
these local witnesses into a GLOBAL BFMCS with ALL four temporal coherence
properties (forward_G, backward_H, forward_F, backward_P) simultaneously requires
a non-linear construction such as omega-squared. The witness graph alone does NOT
suffice to close the forward_F/backward_P sorries in DovetailingChain.lean because
its constant-family BFMCS only has universal G/H propagation, not existential F/P
witness properties. See Task 916 research reports 015-016 for detailed analysis.
-/

/-- Key bridge lemma: The root MCS equals the BFMCS's MCS at time 0.
Since witnessGraphBFMCS is a constant family, this is trivially true. -/
lemma witnessGraphBFMCS_at_root
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (k : Nat) (h_pos : 0 < (buildWitnessGraph rootMCS k).nodes.length) :
    (witnessGraphBFMCS rootMCS).mcs 0 =
      (buildWitnessGraph rootMCS k).mcsAt 0 h_pos := by
  simp [witnessGraph_root_mcs rootMCS k h_pos]

/-- Forward F witness existence in the graph implies a formula relationship.
If F(psi) is in the root MCS (= mcs(0) of the BFMCS), the witness graph
provides a node j with psi in j's MCS. This is the key input for Phase 5. -/
theorem witnessGraph_forward_F_at_root
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (psi : Formula)
    (h_F : Formula.some_future psi ∈ rootMCS.val) :
    ∃ (k' : Nat) (j : Nat) (h_j : j < (buildWitnessGraph rootMCS k').nodes.length),
      (⟨0, j, .forward⟩ : WitnessEdge) ∈ (buildWitnessGraph rootMCS k').edges ∧
      psi ∈ ((buildWitnessGraph rootMCS k').nodeAt j h_j).mcs.val := by
  have h_pos : 0 < (buildWitnessGraph rootMCS 0).nodes.length :=
    buildWitnessGraph_nonempty rootMCS 0
  -- Node 0 at step 0 has rootMCS
  have h_F_at_0 : Formula.some_future psi ∈
      ((buildWitnessGraph rootMCS 0).nodeAt 0 h_pos).mcs.val := by
    unfold WitnessGraph.nodeAt
    simp [buildWitnessGraph, initialWitnessGraph]
    exact h_F
  exact witnessGraph_forward_F_local rootMCS 0 0 h_pos psi h_F_at_0

/-- Backward P witness existence in the graph for the root.
Symmetric to `witnessGraph_forward_F_at_root`. -/
theorem witnessGraph_backward_P_at_root
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (psi : Formula)
    (h_P : Formula.some_past psi ∈ rootMCS.val) :
    ∃ (k' : Nat) (j : Nat) (h_j : j < (buildWitnessGraph rootMCS k').nodes.length),
      (⟨0, j, .backward⟩ : WitnessEdge) ∈ (buildWitnessGraph rootMCS k').edges ∧
      psi ∈ ((buildWitnessGraph rootMCS k').nodeAt j h_j).mcs.val := by
  have h_pos : 0 < (buildWitnessGraph rootMCS 0).nodes.length :=
    buildWitnessGraph_nonempty rootMCS 0
  -- Node 0 at step 0 has rootMCS
  have h_P_at_0 : Formula.some_past psi ∈
      ((buildWitnessGraph rootMCS 0).nodeAt 0 h_pos).mcs.val := by
    unfold WitnessGraph.nodeAt
    simp [buildWitnessGraph, initialWitnessGraph]
    exact h_P
  exact witnessGraph_backward_P_local rootMCS 0 0 h_pos psi h_P_at_0

/-!
## Phase 5: Enriched Chain with Forward_G and Backward_H

### Status: forward_G and backward_H fully proven (sorry-free)

The enriched chain construction provides a BFMCS Int with proven forward_G and
backward_H properties. The enriched forward chain extends via GContent seeds
(with witness placement for F-formulas via Nat.unpair enumeration), and the
enriched backward chain extends via HContent seeds (symmetric).

Cross-sign coherence (G propagation from negative to non-negative times, and
H propagation from non-negative to negative times) is handled by propagating
through the shared root MCS at index 0.

### Forward_F and backward_P

These properties CANNOT be proven for any linear chain construction
(see detailed analysis in the "Forward F and Backward P: Analysis" section below).
The forward_F/backward_P obligations remain in DovetailingChain.lean and require
a non-linear construction (witness graph or omega-squared chain).

### Phase 5 Architecture

The enriched chain builds on the witness graph's local properties:
- `enrichedForwardChain_witness_placed`: places phi at step n+1 when F(phi)
  is in chain(n) and the formula matches the Nat.unpair encoding
- `enrichedForwardChain_F_dichotomy`: at any step, either F(psi) or G(neg psi)
- `enrichedForwardChain_F_implies_G_neg_absent`: F(psi) at n implies G(neg psi)
  absent at all m <= n
-/

/-!
### Helper Lemmas for Enriched Chain
-/

/-- GContent of an MCS is consistent. Duplicate of `dovetail_GContent_consistent`
from DovetailingChain.lean, defined here to avoid circular imports. -/
lemma GContent_consistent_of_mcs' {M : Set Formula} (h_mcs : SetMaximalConsistent M) :
    SetConsistent (GContent M) := by
  intro L hL ⟨d⟩
  have hL_in_M : ∀ x ∈ L, x ∈ M := fun x hx => by
    have h_G : Formula.all_future x ∈ M := hL x hx
    have h_T := DerivationTree.axiom [] ((Formula.all_future x).imp x) (Axiom.temp_t_future x)
    exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G
  exact h_mcs.1 L hL_in_M ⟨d⟩

/-- HContent of an MCS is consistent. Duplicate of `dovetail_HContent_consistent`
from DovetailingChain.lean, defined here to avoid circular imports. -/
lemma HContent_consistent_of_mcs' {M : Set Formula} (h_mcs : SetMaximalConsistent M) :
    SetConsistent (HContent M) := by
  intro L hL ⟨d⟩
  have hL_in_M : ∀ x ∈ L, x ∈ M := fun x hx => by
    have h_H : Formula.all_past x ∈ M := hL x hx
    have h_T := DerivationTree.axiom [] ((Formula.all_past x).imp x) (Axiom.temp_t_past x)
    exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H
  exact h_mcs.1 L hL_in_M ⟨d⟩

/-- Forward witness seed: {psi} union GContent(M). Consistent when F(psi) in MCS M.
Duplicate of seed consistency from DovetailingChain.lean for circular import avoidance.
Uses the same proof structure as `witnessSeed_future_consistent`. -/
theorem enriched_forward_seed_consistent {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    SetConsistent ({psi} ∪ GContent M) := by
  intro L hL_sub ⟨d⟩
  by_cases h_psi_in : psi ∈ L
  · let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)
    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord
    have h_G_filt_in_M : ∀ chi ∈ L_filt, Formula.all_future chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_and.1
      simp only [Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gc
      · exact absurd h_eq h_ne
      · exact h_gc
    have d_G_neg : (Context.map Formula.all_future L_filt) ⊢ Formula.all_future (Formula.neg psi) :=
      Bimodal.Theorems.generalized_temporal_k L_filt (Formula.neg psi) d_neg
    have h_G_ctx_in_M : ∀ phi ∈ Context.map Formula.all_future L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]; exact h_G_filt_in_M chi h_chi_in
    have h_G_neg_in_M := set_mcs_closed_under_derivation h_mcs
      (Context.map Formula.all_future L_filt) h_G_ctx_in_M d_G_neg
    have h_F_eq : Formula.some_future psi = Formula.neg (Formula.all_future (Formula.neg psi)) := rfl
    rw [h_F_eq] at h_F
    exact set_consistent_not_both h_mcs.1 _ h_G_neg_in_M h_F
  · have h_L_in_M : ∀ chi ∈ L, chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gc
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · have h_T := DerivationTree.axiom [] ((Formula.all_future chi).imp chi) (Axiom.temp_t_future chi)
        exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_gc
    exact h_mcs.1 L h_L_in_M ⟨d⟩

/-- Backward witness seed: {psi} union HContent(M). Consistent when P(psi) in MCS M. -/
theorem enriched_backward_seed_consistent {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    SetConsistent ({psi} ∪ HContent M) := by
  intro L hL_sub ⟨d⟩
  by_cases h_psi_in : psi ∈ L
  · let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)
    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord
    have h_H_filt_in_M : ∀ chi ∈ L_filt, Formula.all_past chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_and.1
      simp only [Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_hc
      · exact absurd h_eq h_ne
      · exact h_hc
    have d_H_neg : (Context.map Formula.all_past L_filt) ⊢ Formula.all_past (Formula.neg psi) :=
      Bimodal.Theorems.generalized_past_k L_filt (Formula.neg psi) d_neg
    have h_H_ctx_in_M : ∀ phi ∈ Context.map Formula.all_past L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]; exact h_H_filt_in_M chi h_chi_in
    have h_H_neg_in_M := set_mcs_closed_under_derivation h_mcs
      (Context.map Formula.all_past L_filt) h_H_ctx_in_M d_H_neg
    have h_P_eq : Formula.some_past psi = Formula.neg (Formula.all_past (Formula.neg psi)) := rfl
    rw [h_P_eq] at h_P
    exact set_consistent_not_both h_mcs.1 _ h_H_neg_in_M h_P
  · have h_L_in_M : ∀ chi ∈ L, chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_hc
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · have h_T := DerivationTree.axiom [] ((Formula.all_past chi).imp chi) (Axiom.temp_t_past chi)
        exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_hc
    exact h_mcs.1 L h_L_in_M ⟨d⟩

/-!
### Enriched Chain Definitions
-/

/-- Enriched forward chain: uses Nat.unpair for repeated formula coverage.

At step n+1, decode formula from `(Nat.unpair n).2`. If `F(decoded)` is in chain(n),
seed is `{decoded} union GContent(chain(n))`; otherwise seed is `GContent(chain(n))`.

Since every formula index j appears infinitely often as `(Nat.unpair n).2` (via
`n = Nat.pair a j` for all `a`), every F-obligation is re-checked infinitely often. -/
noncomputable def enrichedForwardChain
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) :
    Nat → { M : Set Formula // SetMaximalConsistent M }
  | 0 => rootMCS
  | n + 1 =>
    let prev := enrichedForwardChain rootMCS n
    let formulaIdx := (Nat.unpair n).2
    match decodeFormulaWG formulaIdx with
    | none =>
      let h_gc := GContent_consistent_of_mcs' prev.property
      let h := set_lindenbaum (GContent prev.val) h_gc
      ⟨Classical.choose h, (Classical.choose_spec h).2⟩
    | some psi =>
      if h_F : Formula.some_future psi ∈ prev.val then
        let h_seed := enriched_forward_seed_consistent prev.property psi h_F
        let h := set_lindenbaum ({psi} ∪ GContent prev.val) h_seed
        ⟨Classical.choose h, (Classical.choose_spec h).2⟩
      else
        let h_gc := GContent_consistent_of_mcs' prev.property
        let h := set_lindenbaum (GContent prev.val) h_gc
        ⟨Classical.choose h, (Classical.choose_spec h).2⟩

/-- Enriched backward chain: symmetric to enrichedForwardChain using HContent and P. -/
noncomputable def enrichedBackwardChain
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) :
    Nat → { M : Set Formula // SetMaximalConsistent M }
  | 0 => rootMCS
  | n + 1 =>
    let prev := enrichedBackwardChain rootMCS n
    let formulaIdx := (Nat.unpair n).2
    match decodeFormulaWG formulaIdx with
    | none =>
      let h_hc := HContent_consistent_of_mcs' prev.property
      let h := set_lindenbaum (HContent prev.val) h_hc
      ⟨Classical.choose h, (Classical.choose_spec h).2⟩
    | some psi =>
      if h_P : Formula.some_past psi ∈ prev.val then
        let h_seed := enriched_backward_seed_consistent prev.property psi h_P
        let h := set_lindenbaum ({psi} ∪ HContent prev.val) h_seed
        ⟨Classical.choose h, (Classical.choose_spec h).2⟩
      else
        let h_hc := HContent_consistent_of_mcs' prev.property
        let h := set_lindenbaum (HContent prev.val) h_hc
        ⟨Classical.choose h, (Classical.choose_spec h).2⟩

/-!
### Basic Properties of Enriched Chain
-/

/-- Each step of the enriched forward chain is an MCS. -/
lemma enrichedForwardChain_is_mcs
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) (n : Nat) :
    SetMaximalConsistent (enrichedForwardChain rootMCS n).val :=
  (enrichedForwardChain rootMCS n).property

/-- Each step of the enriched backward chain is an MCS. -/
lemma enrichedBackwardChain_is_mcs
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) (n : Nat) :
    SetMaximalConsistent (enrichedBackwardChain rootMCS n).val :=
  (enrichedBackwardChain rootMCS n).property

/-- GContent of each enriched forward chain element extends to the next. -/
lemma enrichedForwardChain_GContent_extends
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) (n : Nat) :
    GContent (enrichedForwardChain rootMCS n).val ⊆
      (enrichedForwardChain rootMCS (n + 1)).val := by
  intro phi h_phi
  simp only [enrichedForwardChain]
  cases h_dec : decodeFormulaWG (Nat.unpair n).2 with
  | none =>
    simp only [h_dec]
    exact (Classical.choose_spec (set_lindenbaum (GContent (enrichedForwardChain rootMCS n).val)
      (GContent_consistent_of_mcs' (enrichedForwardChain rootMCS n).property))).1 h_phi
  | some psi =>
    simp only [h_dec]
    split_ifs with h_F
    · -- F(psi) in prev: seed = {psi} union GContent(prev), GContent subset seed
      have h_in_seed : phi ∈ ({psi} ∪ GContent (enrichedForwardChain rootMCS n).val) :=
        Set.mem_union_right _ h_phi
      exact (Classical.choose_spec (set_lindenbaum ({psi} ∪ GContent (enrichedForwardChain rootMCS n).val)
        (enriched_forward_seed_consistent (enrichedForwardChain rootMCS n).property psi h_F))).1 h_in_seed
    · -- F(psi) not in prev: just GContent
      exact (Classical.choose_spec (set_lindenbaum (GContent (enrichedForwardChain rootMCS n).val)
        (GContent_consistent_of_mcs' (enrichedForwardChain rootMCS n).property))).1 h_phi

/-- HContent of each enriched backward chain element extends to the next. -/
lemma enrichedBackwardChain_HContent_extends
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) (n : Nat) :
    HContent (enrichedBackwardChain rootMCS n).val ⊆
      (enrichedBackwardChain rootMCS (n + 1)).val := by
  intro phi h_phi
  simp only [enrichedBackwardChain]
  cases h_dec : decodeFormulaWG (Nat.unpair n).2 with
  | none =>
    simp only [h_dec]
    exact (Classical.choose_spec (set_lindenbaum (HContent (enrichedBackwardChain rootMCS n).val)
      (HContent_consistent_of_mcs' (enrichedBackwardChain rootMCS n).property))).1 h_phi
  | some psi =>
    simp only [h_dec]
    split_ifs with h_P
    · have h_in_seed : phi ∈ ({psi} ∪ HContent (enrichedBackwardChain rootMCS n).val) :=
        Set.mem_union_right _ h_phi
      exact (Classical.choose_spec (set_lindenbaum ({psi} ∪ HContent (enrichedBackwardChain rootMCS n).val)
        (enriched_backward_seed_consistent (enrichedBackwardChain rootMCS n).property psi h_P))).1 h_in_seed
    · exact (Classical.choose_spec (set_lindenbaum (HContent (enrichedBackwardChain rootMCS n).val)
        (HContent_consistent_of_mcs' (enrichedBackwardChain rootMCS n).property))).1 h_phi

/-!
### Forward G and Backward H for Enriched Chain
-/

/-- G propagates forward one step through the enriched chain.
Uses 4-axiom: G(phi) in MCS implies G(G(phi)) in MCS, hence G(phi) in GContent. -/
lemma enrichedForwardChain_G_propagates
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (enrichedForwardChain rootMCS n).val) :
    Formula.all_future phi ∈ (enrichedForwardChain rootMCS (n + 1)).val := by
  have h_mcs := enrichedForwardChain_is_mcs rootMCS n
  have h_GG := set_mcs_all_future_all_future h_mcs h_G
  exact enrichedForwardChain_GContent_extends rootMCS n h_GG

/-- G propagates through multiple steps of the enriched chain. -/
lemma enrichedForwardChain_G_propagates_le
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (enrichedForwardChain rootMCS m).val) :
    Formula.all_future phi ∈ (enrichedForwardChain rootMCS n).val := by
  induction h_le with
  | refl => exact h_G
  | step _ ih => exact enrichedForwardChain_G_propagates rootMCS _ phi ih

/-- forward_G for the enriched forward chain: G(phi) at step m implies phi at step n > m. -/
lemma enrichedForwardChain_forward_G
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (enrichedForwardChain rootMCS m).val) :
    phi ∈ (enrichedForwardChain rootMCS n).val := by
  have h_G_n := enrichedForwardChain_G_propagates_le rootMCS m n (Nat.le_of_lt h_lt) phi h_G
  exact mcs_G_implies_self (enrichedForwardChain_is_mcs rootMCS n) phi h_G_n

/-- H propagates backward one step through the enriched chain. -/
lemma enrichedBackwardChain_H_propagates
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (enrichedBackwardChain rootMCS n).val) :
    Formula.all_past phi ∈ (enrichedBackwardChain rootMCS (n + 1)).val := by
  have h_mcs := enrichedBackwardChain_is_mcs rootMCS n
  have h_HH := set_mcs_all_past_all_past h_mcs h_H
  exact enrichedBackwardChain_HContent_extends rootMCS n h_HH

/-- H propagates through multiple steps of the enriched backward chain. -/
lemma enrichedBackwardChain_H_propagates_le
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (enrichedBackwardChain rootMCS m).val) :
    Formula.all_past phi ∈ (enrichedBackwardChain rootMCS n).val := by
  induction h_le with
  | refl => exact h_H
  | step _ ih => exact enrichedBackwardChain_H_propagates rootMCS _ phi ih

/-- backward_H for the enriched backward chain. -/
lemma enrichedBackwardChain_backward_H
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (enrichedBackwardChain rootMCS m).val) :
    phi ∈ (enrichedBackwardChain rootMCS n).val := by
  have h_H_n := enrichedBackwardChain_H_propagates_le rootMCS m n (Nat.le_of_lt h_lt) phi h_H
  exact mcs_H_implies_self (enrichedBackwardChain_is_mcs rootMCS n) phi h_H_n

/-!
### Witness Placement in Enriched Chain
-/

/-- Witness placement: if at step n the unpair component matches formula psi
and F(psi) is in chain(n), then psi is in chain(n+1). -/
lemma enrichedForwardChain_witness_placed
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) (psi : Formula)
    (h_dec : decodeFormulaWG (Nat.unpair n).2 = some psi)
    (h_F : Formula.some_future psi ∈ (enrichedForwardChain rootMCS n).val) :
    psi ∈ (enrichedForwardChain rootMCS (n + 1)).val := by
  simp only [enrichedForwardChain, h_dec, h_F, dite_true]
  have h_in_seed : psi ∈ ({psi} ∪ GContent (enrichedForwardChain rootMCS n).val) :=
    Set.mem_union_left _ (Set.mem_singleton psi)
  exact (Classical.choose_spec (set_lindenbaum ({psi} ∪ GContent (enrichedForwardChain rootMCS n).val)
    (enriched_forward_seed_consistent (enrichedForwardChain rootMCS n).property psi h_F))).1 h_in_seed

/-- Backward witness placement: symmetric. -/
lemma enrichedBackwardChain_witness_placed
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) (psi : Formula)
    (h_dec : decodeFormulaWG (Nat.unpair n).2 = some psi)
    (h_P : Formula.some_past psi ∈ (enrichedBackwardChain rootMCS n).val) :
    psi ∈ (enrichedBackwardChain rootMCS (n + 1)).val := by
  simp only [enrichedBackwardChain, h_dec, h_P, dite_true]
  have h_in_seed : psi ∈ ({psi} ∪ HContent (enrichedBackwardChain rootMCS n).val) :=
    Set.mem_union_left _ (Set.mem_singleton psi)
  exact (Classical.choose_spec (set_lindenbaum ({psi} ∪ HContent (enrichedBackwardChain rootMCS n).val)
    (enriched_backward_seed_consistent (enrichedBackwardChain rootMCS n).property psi h_P))).1 h_in_seed

/-!
### F/P Dichotomy and Persistence
-/

/-- F-formula dichotomy: at any step, either F(psi) or G(neg psi) is in the chain. -/
lemma enrichedForwardChain_F_dichotomy
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) (psi : Formula) :
    Formula.some_future psi ∈ (enrichedForwardChain rootMCS n).val ∨
    Formula.all_future (Formula.neg psi) ∈ (enrichedForwardChain rootMCS n).val := by
  have h_mcs := enrichedForwardChain_is_mcs rootMCS n
  have h_F_def : Formula.some_future psi = Formula.neg (Formula.all_future (Formula.neg psi)) := rfl
  by_cases h : Formula.all_future (Formula.neg psi) ∈ (enrichedForwardChain rootMCS n).val
  · exact Or.inr h
  · left
    have h_neg := set_mcs_negation_complete h_mcs (Formula.all_future (Formula.neg psi))
    rcases h_neg with h_in | h_neg_in
    · exact absurd h_in h
    · rw [h_F_def]; exact h_neg_in

/-- If F(psi) is in chain(n) then G(neg psi) is absent at all steps m <= n. -/
lemma enrichedForwardChain_F_implies_G_neg_absent
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_le : m ≤ n) (psi : Formula)
    (h_F : Formula.some_future psi ∈ (enrichedForwardChain rootMCS n).val) :
    Formula.all_future (Formula.neg psi) ∉ (enrichedForwardChain rootMCS m).val := by
  intro h_G
  have h_G_n := enrichedForwardChain_G_propagates_le rootMCS m n h_le (Formula.neg psi) h_G
  have h_mcs := enrichedForwardChain_is_mcs rootMCS n
  have h_F_eq : Formula.some_future psi = Formula.neg (Formula.all_future (Formula.neg psi)) := rfl
  rw [h_F_eq] at h_F
  exact set_consistent_not_both h_mcs.1 _ h_G_n h_F

/-- P-formula dichotomy for backward chain. -/
lemma enrichedBackwardChain_P_dichotomy
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) (psi : Formula) :
    Formula.some_past psi ∈ (enrichedBackwardChain rootMCS n).val ∨
    Formula.all_past (Formula.neg psi) ∈ (enrichedBackwardChain rootMCS n).val := by
  have h_mcs := enrichedBackwardChain_is_mcs rootMCS n
  have h_P_def : Formula.some_past psi = Formula.neg (Formula.all_past (Formula.neg psi)) := rfl
  by_cases h : Formula.all_past (Formula.neg psi) ∈ (enrichedBackwardChain rootMCS n).val
  · exact Or.inr h
  · left; rw [h_P_def]
    exact (set_mcs_negation_complete h_mcs (Formula.all_past (Formula.neg psi))).resolve_left h

/-- If P(psi) is in backward chain(n) then H(neg psi) absent at all steps m <= n. -/
lemma enrichedBackwardChain_P_implies_H_neg_absent
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_le : m ≤ n) (psi : Formula)
    (h_P : Formula.some_past psi ∈ (enrichedBackwardChain rootMCS n).val) :
    Formula.all_past (Formula.neg psi) ∉ (enrichedBackwardChain rootMCS m).val := by
  intro h_H
  have h_H_n := enrichedBackwardChain_H_propagates_le rootMCS m n h_le (Formula.neg psi) h_H
  have h_mcs := enrichedBackwardChain_is_mcs rootMCS n
  have h_P_eq : Formula.some_past psi = Formula.neg (Formula.all_past (Formula.neg psi)) := rfl
  rw [h_P_eq] at h_P
  exact set_consistent_not_both h_mcs.1 _ h_H_n h_P


/-!
### Forward F and Backward P: Analysis

Forward_F and backward_P require that for any `F(phi) in chain(n)`, there exists
`s > n` with `phi in chain(s)`. These properties CANNOT be proven for the enriched
linear chain construction because:

1. `F(phi) -> G(F(phi))` is NOT provable in TM logic (F-formulas don't self-persist)
2. Lindenbaum extensions are opaque (`Classical.choose`): `G(neg phi)` can enter
   the chain at any step between formula re-checks, killing `F(phi)` before the
   witness fires
3. The spacing of re-check steps (via `Nat.unpair` or simple encoding) cannot be
   guaranteed to precede the entry of `G(neg phi)`

**Detailed Analysis (Task 916, Phase 5B)**:

The fundamental issue is that F-formulas do not propagate through GContent seeds.
The GContent seed `{phi : G(phi) in M}` only carries G-stripped formulas. Since
`F(psi) = neg(G(neg psi))`, the formula `F(psi)` is NOT in GContent form and
does NOT persist through GContent-based Lindenbaum extensions.

At each step n of the enriched chain:
- chain(n+1) is a Lindenbaum extension of either `{psi'} union GContent(chain(n))`
  or `GContent(chain(n))`
- The Lindenbaum extension can include `G(neg phi)`, which eliminates `F(phi)`
- Once `G(neg phi)` enters (at any step), it persists forever via the 4-axiom
  (`G(x) -> G(G(x))`)

**Consequence**: The theorems `enrichedForwardChain_forward_F` and
`enrichedBackwardChain_backward_P` are mathematically unprovable for this
chain construction. They have been removed (previously sorry'd but unused).

**Forward path**: The correct resolution requires a non-linear construction.
The witness graph already provides local F/P witness existence
(`witnessGraph_forward_F_local`, `witnessGraph_backward_P_local`).
A future task should build a BFMCS that uses the witness graph structure
to satisfy forward_F and backward_P. See research-003 and research-010.

**Note**: The `enrichedChainBFMCS` below provides a proven BFMCS with
`forward_G` and `backward_H`. Forward_F and backward_P remain as open problems
for the BFMCS construction, tracked in DovetailingChain.lean.
-/

/-!
### Enriched Chain BFMCS

Combine the enriched forward and backward chains into a BFMCS Int.
The forward chain handles non-negative times, the backward chain handles negative times.
Both chains share the root MCS at time 0.
-/

/-- Unified enriched chain set: non-negative uses forward, negative uses backward. -/
noncomputable def enrichedChainSet
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (t : Int) : Set Formula :=
  if _ : 0 ≤ t then
    (enrichedForwardChain rootMCS t.toNat).val
  else
    (enrichedBackwardChain rootMCS ((-t - 1).toNat)).val

/-- The enriched chain at each time is an MCS. -/
lemma enrichedChainSet_is_mcs
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (t : Int) :
    SetMaximalConsistent (enrichedChainSet rootMCS t) := by
  simp only [enrichedChainSet]
  split
  · exact enrichedForwardChain_is_mcs rootMCS t.toNat
  · exact enrichedBackwardChain_is_mcs rootMCS ((-t - 1).toNat)

/-- Past analog of axiom temp_a: ⊢ φ → H(F(φ)).
Derived from temp_a via temporal duality.
Duplicated from DovetailingChain.lean to avoid circular import dependency. -/
noncomputable def past_temp_a' (psi : Formula) :
    [] ⊢ psi.imp psi.some_future.all_past := by
  have h_ta := DerivationTree.axiom [] _ (Axiom.temp_a psi.swap_past_future)
  have h_dual := DerivationTree.temporal_duality _ h_ta
  have h_eq : (psi.swap_past_future.imp psi.swap_past_future.sometime_past.all_future).swap_past_future
    = psi.imp psi.some_future.all_past := by
    simp [Formula.swap_temporal, Formula.neg, Formula.sometime_past, Formula.some_past,
          Formula.some_future, Formula.swap_past_future, Formula.swap_past_future_involution]
  rw [h_eq] at h_dual; exact h_dual

/-- If HContent(M) ⊆ M', then GContent(M') ⊆ M.
Uses past_temp_a: φ → H(F(φ)).
Duplicated from DovetailingChain.lean to avoid circular import dependency. -/
theorem HContent_subset_implies_GContent_reverse
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_HC : HContent M ⊆ M') :
    GContent M' ⊆ M := by
  intro phi h_G_phi_in_M'
  have h_G_phi : Formula.all_future phi ∈ M' := h_G_phi_in_M'
  by_contra h_not_phi
  have h_neg_phi : Formula.neg phi ∈ M := by
    rcases set_mcs_negation_complete h_mcs phi with h | h
    · exact absurd h h_not_phi
    · exact h
  have h_pta : [] ⊢ (Formula.neg phi).imp (Formula.neg phi).some_future.all_past :=
    past_temp_a' (Formula.neg phi)
  have h_H_F_neg : (Formula.neg phi).some_future.all_past ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_pta) h_neg_phi
  have h_F_neg_M' : (Formula.neg phi).some_future ∈ M' := h_HC h_H_F_neg
  have h_dni : [] ⊢ phi.imp phi.neg.neg := Bimodal.Theorems.Combinators.dni phi
  have h_G_dni : [] ⊢ (phi.imp phi.neg.neg).all_future :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_fk : [] ⊢ (phi.imp phi.neg.neg).all_future.imp (phi.all_future.imp phi.neg.neg.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist phi phi.neg.neg)
  have h_G_imp : [] ⊢ phi.all_future.imp phi.neg.neg.all_future :=
    DerivationTree.modus_ponens [] _ _ h_fk h_G_dni
  have h_G_nn : phi.neg.neg.all_future ∈ M' :=
    set_mcs_implication_property h_mcs' (theorem_in_mcs h_mcs' h_G_imp) h_G_phi
  have h_eq : (Formula.neg phi).some_future = Formula.neg (phi.neg.neg.all_future) := rfl
  rw [h_eq] at h_F_neg_M'
  exact set_consistent_not_both h_mcs'.1 (phi.neg.neg.all_future) h_G_nn h_F_neg_M'

/-- If GContent(M) ⊆ M', then HContent(M') ⊆ M.
Uses temp_a: φ → G(P(φ)).
Duplicated from DovetailingChain.lean to avoid circular import dependency. -/
theorem GContent_subset_implies_HContent_reverse
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_GC : GContent M ⊆ M') :
    HContent M' ⊆ M := by
  intro phi h_H_phi_in_M'
  by_contra h_not_phi
  have h_neg_phi : Formula.neg phi ∈ M := by
    rcases set_mcs_negation_complete h_mcs phi with h | h
    · exact absurd h h_not_phi
    · exact h
  have h_ta : [] ⊢ (Formula.neg phi).imp (Formula.all_future (Formula.neg phi).sometime_past) :=
    DerivationTree.axiom [] _ (Axiom.temp_a (Formula.neg phi))
  have h_G_P_neg : Formula.all_future (Formula.neg phi).sometime_past ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_ta) h_neg_phi
  have h_P_neg_M' : (Formula.neg phi).sometime_past ∈ M' := h_GC h_G_P_neg
  have h_dni : [] ⊢ phi.imp phi.neg.neg := Bimodal.Theorems.Combinators.dni phi
  have h_H_dni : [] ⊢ (phi.imp phi.neg.neg).all_past :=
    Bimodal.Theorems.past_necessitation _ h_dni
  have h_pk : [] ⊢ (phi.imp phi.neg.neg).all_past.imp (phi.all_past.imp phi.neg.neg.all_past) :=
    Bimodal.Theorems.past_k_dist phi phi.neg.neg
  have h_H_imp : [] ⊢ phi.all_past.imp phi.neg.neg.all_past :=
    DerivationTree.modus_ponens [] _ _ h_pk h_H_dni
  have h_H_nn : phi.neg.neg.all_past ∈ M' :=
    set_mcs_implication_property h_mcs' (theorem_in_mcs h_mcs' h_H_imp) h_H_phi_in_M'
  have h_eq : (Formula.neg phi).sometime_past = Formula.neg (phi.neg.neg.all_past) := rfl
  rw [h_eq] at h_P_neg_M'
  exact set_consistent_not_both h_mcs'.1 (phi.neg.neg.all_past) h_H_nn h_P_neg_M'

/-- GContent extends through the backward chain (needed for cross-sign G propagation). -/
lemma enrichedBackwardChain_GContent_reverse
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) (n : Nat) :
    GContent (enrichedBackwardChain rootMCS (n + 1)).val ⊆
      (enrichedBackwardChain rootMCS n).val := by
  have h_hc := enrichedBackwardChain_HContent_extends rootMCS n
  exact HContent_subset_implies_GContent_reverse
    (enrichedBackwardChain rootMCS n).val
    (enrichedBackwardChain rootMCS (n + 1)).val
    (enrichedBackwardChain_is_mcs rootMCS n)
    (enrichedBackwardChain_is_mcs rootMCS (n + 1))
    h_hc

/-- HContent extends through the forward chain in reverse (needed for cross-sign H). -/
lemma enrichedForwardChain_HContent_reverse
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) (n : Nat) :
    HContent (enrichedForwardChain rootMCS (n + 1)).val ⊆
      (enrichedForwardChain rootMCS n).val := by
  have h_gc := enrichedForwardChain_GContent_extends rootMCS n
  exact GContent_subset_implies_HContent_reverse
    (enrichedForwardChain rootMCS n).val
    (enrichedForwardChain rootMCS (n + 1)).val
    (enrichedForwardChain_is_mcs rootMCS n)
    (enrichedForwardChain_is_mcs rootMCS (n + 1))
    h_gc

/-!
### Cross-Sign Coherence Infrastructure

G propagation toward 0 in the backward chain (for cross-sign forward_G),
H propagation toward 0 in the forward chain (for cross-sign backward_H),
and the shared base lemma.
-/

/-- Forward and backward enriched chains share the same MCS at index 0. -/
lemma enriched_chains_share_base
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) :
    (enrichedForwardChain rootMCS 0).val = (enrichedBackwardChain rootMCS 0).val := rfl

/-- G propagates toward 0 in the backward chain (decreasing index). -/
lemma enrichedBackwardChain_G_propagates_reverse
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (enrichedBackwardChain rootMCS (n + 1)).val) :
    Formula.all_future phi ∈ (enrichedBackwardChain rootMCS n).val := by
  have h_mcs_n1 := enrichedBackwardChain_is_mcs rootMCS (n + 1)
  have h_GG := set_mcs_all_future_all_future h_mcs_n1 h_G
  exact enrichedBackwardChain_GContent_reverse rootMCS n h_GG

/-- G propagates toward 0: from index n to index m (m ≤ n) in the backward chain. -/
lemma enrichedBackwardChain_G_propagates_reverse_le
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (enrichedBackwardChain rootMCS n).val) :
    Formula.all_future phi ∈ (enrichedBackwardChain rootMCS m).val := by
  induction h_le with
  | refl => exact h_G
  | step h_le ih =>
    have := enrichedBackwardChain_G_propagates_reverse rootMCS _ phi h_G
    exact ih this

/-- forward_G within the backward chain: G(phi) at index n implies phi at index m for m < n. -/
lemma enrichedBackwardChain_forward_G
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_G : Formula.all_future phi ∈ (enrichedBackwardChain rootMCS n).val) :
    phi ∈ (enrichedBackwardChain rootMCS m).val := by
  have h_G_m := enrichedBackwardChain_G_propagates_reverse_le rootMCS m n (Nat.le_of_lt h_lt) phi h_G
  exact mcs_G_implies_self (enrichedBackwardChain_is_mcs rootMCS m) phi h_G_m

/-- H propagates toward 0 in the forward chain (decreasing index). -/
lemma enrichedForwardChain_H_propagates_reverse
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (n : Nat) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (enrichedForwardChain rootMCS (n + 1)).val) :
    Formula.all_past phi ∈ (enrichedForwardChain rootMCS n).val := by
  have h_mcs_n1 := enrichedForwardChain_is_mcs rootMCS (n + 1)
  have h_HH := set_mcs_all_past_all_past h_mcs_n1 h_H
  exact enrichedForwardChain_HContent_reverse rootMCS n h_HH

/-- H propagates toward 0: from index n to index m (m ≤ n) in the forward chain. -/
lemma enrichedForwardChain_H_propagates_reverse_le
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_le : m ≤ n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (enrichedForwardChain rootMCS n).val) :
    Formula.all_past phi ∈ (enrichedForwardChain rootMCS m).val := by
  induction h_le with
  | refl => exact h_H
  | step h_le ih =>
    have := enrichedForwardChain_H_propagates_reverse rootMCS _ phi h_H
    exact ih this

/-- backward_H within the forward chain: H(phi) at index n implies phi at index m for m < n. -/
lemma enrichedForwardChain_backward_H
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (m n : Nat) (h_lt : m < n) (phi : Formula)
    (h_H : Formula.all_past phi ∈ (enrichedForwardChain rootMCS n).val) :
    phi ∈ (enrichedForwardChain rootMCS m).val := by
  have h_H_m := enrichedForwardChain_H_propagates_reverse_le rootMCS m n (Nat.le_of_lt h_lt) phi h_H
  exact mcs_H_implies_self (enrichedForwardChain_is_mcs rootMCS m) phi h_H_m

/-!
### Int-Level forward_G and backward_H

Case-split on the sign of the Int index to dispatch to the appropriate chain lemma.
-/

/-- forward_G for non-negative Int indices (both in forward chain). -/
lemma enrichedChainSet_forward_G_nonneg
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (t t' : Int) (h_t_nn : 0 ≤ t) (h_t'_nn : 0 ≤ t') (h_lt : t < t')
    (phi : Formula) (h_G : Formula.all_future phi ∈ enrichedChainSet rootMCS t) :
    phi ∈ enrichedChainSet rootMCS t' := by
  simp only [enrichedChainSet, h_t_nn, h_t'_nn, ↓reduceDIte] at h_G ⊢
  have h_lt_nat : t.toNat < t'.toNat := by
    rw [← Int.ofNat_lt]
    rwa [Int.toNat_of_nonneg h_t_nn, Int.toNat_of_nonneg h_t'_nn]
  exact enrichedForwardChain_forward_G rootMCS t.toNat t'.toNat h_lt_nat phi h_G

/-- forward_G for negative source: G(phi) in M_t (t < 0) implies phi in M_{t'} (t' > t). -/
lemma enrichedChainSet_forward_G_neg
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (t t' : Int) (h_t_neg : t < 0) (h_lt : t < t')
    (phi : Formula) (h_G : Formula.all_future phi ∈ enrichedChainSet rootMCS t) :
    phi ∈ enrichedChainSet rootMCS t' := by
  have h_t_not_nn : ¬(0 ≤ t) := not_le.mpr h_t_neg
  simp only [enrichedChainSet, h_t_not_nn, ↓reduceDIte] at h_G
  -- G(phi) in backward chain at index (-t-1).toNat
  -- Step 1: Propagate G(phi) through backward chain to index 0 (= root)
  have h_G_at_0 : Formula.all_future phi ∈ (enrichedBackwardChain rootMCS 0).val :=
    enrichedBackwardChain_G_propagates_reverse_le rootMCS 0 (-t - 1).toNat
      (Nat.zero_le _) phi h_G
  -- backward chain 0 = forward chain 0 = rootMCS
  have h_chain_eq := enriched_chains_share_base rootMCS
  have h_G_fwd_0 : Formula.all_future phi ∈ (enrichedForwardChain rootMCS 0).val := by
    rw [h_chain_eq]; exact h_G_at_0
  -- Branch on t'
  by_cases h_t'_nn : 0 ≤ t'
  · -- Case t' >= 0: use forward chain
    simp only [enrichedChainSet, h_t'_nn, ↓reduceDIte]
    by_cases h_t'_zero : t' = 0
    · -- t' = 0: apply T-axiom
      subst h_t'_zero
      exact mcs_G_implies_self (enrichedForwardChain_is_mcs rootMCS 0) phi h_G_fwd_0
    · -- t' > 0: forward chain propagation
      have h_lt_nat : 0 < t'.toNat := by omega
      exact enrichedForwardChain_forward_G rootMCS 0 t'.toNat h_lt_nat phi h_G_fwd_0
  · -- Case t' < 0: both negative, backward chain forward_G
    push_neg at h_t'_nn
    have h_t'_not_nn : ¬(0 ≤ t') := not_le.mpr h_t'_nn
    simp only [enrichedChainSet, h_t'_not_nn, ↓reduceDIte]
    have h_idx_lt : (-t' - 1).toNat < (-t - 1).toNat := by
      rw [← Int.ofNat_lt]
      rw [Int.toNat_of_nonneg (by omega), Int.toNat_of_nonneg (by omega)]
      omega
    exact enrichedBackwardChain_forward_G rootMCS (-t' - 1).toNat (-t - 1).toNat h_idx_lt phi h_G

/-- backward_H for non-positive Int indices (both in backward chain). -/
lemma enrichedChainSet_backward_H_nonpos
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (t t' : Int) (h_t_neg : t < 0) (h_t'_neg : t' < 0) (h_lt : t' < t)
    (phi : Formula) (h_H : Formula.all_past phi ∈ enrichedChainSet rootMCS t) :
    phi ∈ enrichedChainSet rootMCS t' := by
  have h_t_not_nn : ¬(0 ≤ t) := not_le.mpr h_t_neg
  have h_t'_not_nn : ¬(0 ≤ t') := not_le.mpr h_t'_neg
  simp only [enrichedChainSet, h_t_not_nn, h_t'_not_nn, ↓reduceDIte] at h_H ⊢
  have h_idx_lt : (-t - 1).toNat < (-t' - 1).toNat := by
    rw [← Int.ofNat_lt]
    rw [Int.toNat_of_nonneg (by omega), Int.toNat_of_nonneg (by omega)]
    omega
  exact enrichedBackwardChain_backward_H rootMCS (-t - 1).toNat (-t' - 1).toNat h_idx_lt phi h_H

/-- backward_H for non-negative source: H(phi) in M_t (t >= 0) implies phi in M_{t'} (t' < t). -/
lemma enrichedChainSet_backward_H_nonneg
    (rootMCS : { S : Set Formula // SetMaximalConsistent S })
    (t t' : Int) (h_t_nn : 0 ≤ t) (h_lt : t' < t)
    (phi : Formula) (h_H : Formula.all_past phi ∈ enrichedChainSet rootMCS t) :
    phi ∈ enrichedChainSet rootMCS t' := by
  simp only [enrichedChainSet, h_t_nn, ↓reduceDIte] at h_H
  -- H(phi) in forward chain at index t.toNat
  -- Step 1: Propagate H(phi) through forward chain to index 0
  have h_H_at_0 : Formula.all_past phi ∈ (enrichedForwardChain rootMCS 0).val :=
    enrichedForwardChain_H_propagates_reverse_le rootMCS 0 t.toNat (Nat.zero_le _) phi h_H
  -- forward chain 0 = backward chain 0
  have h_chain_eq := (enriched_chains_share_base rootMCS).symm
  have h_H_bwd_0 : Formula.all_past phi ∈ (enrichedBackwardChain rootMCS 0).val := by
    rw [h_chain_eq]; exact h_H_at_0
  by_cases h_t'_neg : t' < 0
  · -- Case t' < 0: use backward chain
    have h_t'_not_nn : ¬(0 ≤ t') := not_le.mpr h_t'_neg
    simp only [enrichedChainSet, h_t'_not_nn, ↓reduceDIte]
    by_cases h_t'_idx_zero : (-t' - 1).toNat = 0
    · -- t' = -1: apply T-axiom at backward chain index 0
      rw [show (-t' - 1).toNat = 0 from h_t'_idx_zero]
      exact mcs_H_implies_self (enrichedBackwardChain_is_mcs rootMCS 0) phi h_H_bwd_0
    · -- t' < -1: backward chain propagation
      have h_lt_nat : 0 < (-t' - 1).toNat := Nat.pos_of_ne_zero h_t'_idx_zero
      exact enrichedBackwardChain_backward_H rootMCS 0 (-t' - 1).toNat h_lt_nat phi h_H_bwd_0
  · -- Case t' >= 0: both non-negative, use forward chain backward_H
    push_neg at h_t'_neg
    simp only [enrichedChainSet, h_t'_neg, ↓reduceDIte]
    have h_lt_nat : t'.toNat < t.toNat := by
      rw [← Int.ofNat_lt]
      rwa [Int.toNat_of_nonneg h_t'_neg, Int.toNat_of_nonneg h_t_nn]
    exact enrichedForwardChain_backward_H rootMCS t'.toNat t.toNat h_lt_nat phi h_H

/-- The enriched BFMCS Int from a root MCS.

Maps non-negative integers to the enriched forward chain and negative integers
to the enriched backward chain. Both chains share the root MCS at time 0.

**Proven properties** (sorry-free):
- forward_G: proven via cross-sign G propagation infrastructure
- backward_H: proven via cross-sign H propagation infrastructure

**Note**: forward_F and backward_P cannot be proven for this linear chain
construction (see analysis above). These properties require a non-linear
construction using the witness graph. See DovetailingChain.lean for the
downstream integration point.
-/
noncomputable def enrichedChainBFMCS
    (rootMCS : { S : Set Formula // SetMaximalConsistent S }) : BFMCS Int where
  mcs t := enrichedChainSet rootMCS t
  is_mcs t := enrichedChainSet_is_mcs rootMCS t
  forward_G := fun t t' phi h_le h_G => by
    rcases h_le.lt_or_eq with h_lt | h_eq
    · by_cases h_t : 0 ≤ t
      · have h_t' : 0 ≤ t' := le_of_lt (lt_of_le_of_lt h_t h_lt)
        exact enrichedChainSet_forward_G_nonneg rootMCS t t' h_t h_t' h_lt phi h_G
      · push_neg at h_t
        exact enrichedChainSet_forward_G_neg rootMCS t t' h_t h_lt phi h_G
    · subst h_eq
      exact mcs_G_implies_self (enrichedChainSet_is_mcs rootMCS t) phi h_G
  backward_H := fun t t' phi h_le h_H => by
    rcases h_le.lt_or_eq with h_lt | h_eq
    · by_cases h_t : t < 0
      · have h_t' : t' < 0 := lt_trans h_lt h_t
        exact enrichedChainSet_backward_H_nonpos rootMCS t t' h_t h_t' h_lt phi h_H
      · push_neg at h_t
        exact enrichedChainSet_backward_H_nonneg rootMCS t t' h_t h_lt phi h_H
    · subst h_eq
      exact mcs_H_implies_self (enrichedChainSet_is_mcs rootMCS t') phi h_H

end Bimodal.Metalogic.Bundle
