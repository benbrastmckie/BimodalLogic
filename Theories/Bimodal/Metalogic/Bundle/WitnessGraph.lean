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
At each step n, we decode n into (nodeIdx, formulaIdx) via `Nat.unpair`, check if
the formula creates an F/P obligation at the node, and if so create a witness.

### Key Design

- **Enumeration**: `Nat.unpair` surjects onto Nat x Nat, so every (node, formula)
  pair is eventually visited.
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

Decodes n to (nodeIdx, formulaIdx) via Nat.unpair. If the node exists and the
formula decodes to psi:
- If F(psi) is in the node's MCS and not yet witnessed: create future witness
- Else if P(psi) is in the node's MCS and not yet witnessed: create past witness
- Else: return graph unchanged

**Design note**: We check F first, then P. A single step processes at most one
obligation. The other obligation (if both exist) will be handled at a different
step via the coverage argument. -/
noncomputable def processStep (g : WitnessGraph) (n : Nat) : WitnessGraph :=
  let (nodeIdx, formulaIdx) := Nat.unpair n
  if h_node : nodeIdx < g.nodes.length then
    match decodeFormulaWG formulaIdx with
    | none => g
    | some psi =>
      let nodeMCS := (g.nodeAt nodeIdx h_node).mcs
      if h_F : Formula.some_future psi ∈ nodeMCS.val then
        if g.isWitnessed nodeIdx (.future psi) then g
        else g.addFutureWitness nodeIdx h_node psi h_F
      else if h_P : Formula.some_past psi ∈ nodeMCS.val then
        if g.isWitnessed nodeIdx (.past psi) then g
        else g.addPastWitness nodeIdx h_node psi h_P
      else g
  else g

/-!
### Build Witness Graph

Iterate `processStep` to build the witness graph incrementally.
At step k, the graph `buildWitnessGraph root k` has processed pairs 0..k-1.
-/

/-- Build the witness graph by iterating processStep for k steps.

Starting from an initial single-node graph (the root MCS), each step processes
one (node, formula) pair. After k steps, all pairs with Nat.pair encoding < k
have been examined.

**Coverage**: Since Nat.unpair surjects onto Nat x Nat, and Formula is Encodable,
every (node, formula) pair is eventually processed. For any F(psi) at node i,
the pair (i, encodeFormula psi) has encoding Nat.pair i (encodeFormula psi),
so it will be processed at that step. -/
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
  split  -- match on pair
  split  -- if nodeIdx < length
  · split  -- match decodeFormulaWG
    · exact Nat.le_refl _  -- none case
    · -- some psi case
      dsimp only
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
  split  -- match on pair
  split  -- if nodeIdx < length
  · split  -- match decodeFormulaWG
    · rfl  -- none
    · -- some psi; need to reduce the let binding
      dsimp only
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

/-- For any node index i and formula psi, there exists a step number n such that
Nat.unpair n = (i, encodeFormulaWG psi). This is the coverage lemma. -/
lemma coverage_step_exists (i : Nat) (psi : Formula) :
    ∃ n : Nat, Nat.unpair n = (i, encodeFormulaWG psi) := by
  exact ⟨Nat.pair i (encodeFormulaWG psi), Nat.unpair_pair i (encodeFormulaWG psi)⟩

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

end Bimodal.Metalogic.Bundle
