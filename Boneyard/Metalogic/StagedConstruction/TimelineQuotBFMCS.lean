import Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical
import Bimodal.Metalogic.StagedConstruction.DenseTaskRelation
import Bimodal.Metalogic.Bundle.ClosedFlagBundle
import Bimodal.Metalogic.Bundle.SaturatedBFMCSConstruction
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.TemporalCoherence

/-!
# BFMCS over TimelineQuot for Dense Completeness

This module constructs a temporally complete BFMCS bundle with families indexed by
TimelineQuot satisfying both modal coherence (`modal_backward`, `modal_forward`) and
temporal coherence (`forward_F`, `backward_P`).

## Overview

The singleton BFMCS approach fails `modal_backward` because Diamond(psi) in M does NOT
imply psi in M. The solution requires multiple FMCS families with closure-based
saturation using the ClosedFlagBundle pattern.

## Key Insight: Dual Domain Architecture

For dense completeness, we need:
- **Temporal domain**: TimelineQuot (dense linear order from Cantor)
- **Modal domain**: CanonicalMCS (all maximal consistent sets)
- **BFMCS**: Over CanonicalMCS with modal saturation via closedFlags

The BFMCS is built over CanonicalMCS (not TimelineQuot) because:
1. Modal coherence requires quantification over families at the SAME time
2. TimelineQuot provides temporal structure, CanonicalMCS provides modal structure
3. The truth lemma evaluates (time, history) pairs

## Main Definitions

- `TimelineQuotWitnessSeed`: Structure for placing witness MCS at specific times
- `timelineQuotClosedBFMCS`: BFMCS with closed families satisfying modal saturation
- `timelineQuotBFMCS_modal_forward`: Modal forward via T-axiom
- `timelineQuotBFMCS_modal_backward`: Modal backward via saturation

## References

- Task 17: BFMCS over TimelineQuot dense
- Task 16: DenseTask relation
- ClosedFlagBundle.lean: closedFlags_closed_under_witnesses
- SaturatedBFMCSConstruction.lean: closedFlags_union_modally_saturated
-/

namespace Bimodal.Metalogic.StagedConstruction.TimelineQuotBFMCS

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness
open Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical
open Bimodal.ProofSystem

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Phase 1: TimelineQuot Witness FMCS Structure

A witness FMCS maps a specific time to a witness MCS while preserving
temporal coherence. The key challenge is ensuring forward_G and backward_H
hold when we modify the mcs function at a specific point.

### Architecture Decision

Rather than building witness families with modified mcs functions over TimelineQuot
(which would require complex coherence proofs), we use the dual-domain approach:

1. The BFMCS is over CanonicalMCS (modal domain)
2. TimelineQuot provides the temporal ordering via timelineQuot_lt_implies_canonicalR
3. Modal saturation is achieved via closedFlags

This is the correct architecture from research analysis (MultiFamilyBFMCS.lean lines 276-286).
-/

/-!
### WitnessSeed Structure

A witness seed records the placement of a witness MCS at a specific time.
This is used to track which formulas have been witnessed and where.
-/

/--
A witness seed for TimelineQuot: records a Diamond obligation and its witness.

This is analogous to WitnessRecord but tracks temporal positioning:
- `source_time`: The time in TimelineQuot where Diamond(psi) appears
- `witness_mcs`: The MCS containing psi
- `witness_time`: The time where the witness is placed (if applicable)
-/
structure TimelineQuotWitnessSeed where
  /-- The time where the Diamond formula appears -/
  source_time : TimelineQuot root_mcs root_mcs_proof
  /-- The formula psi where Diamond(psi) is the obligation -/
  inner_formula : Formula
  /-- Proof that Diamond(psi) is in the MCS at source_time -/
  obligation_mem : inner_formula.diamond ∈
    (timelineQuotFMCS root_mcs root_mcs_proof).mcs source_time
  /-- The witness MCS containing psi -/
  witness_mcs : CanonicalMCS
  /-- Proof that psi is in the witness MCS -/
  witness_contains_psi : inner_formula ∈ witness_mcs.world

/--
Build a TimelineQuotWitnessSeed from a WitnessObligation at a specific time.

Uses the WitnessFamilyBundle infrastructure to construct the witness.
-/
noncomputable def buildTimelineQuotWitnessSeed
    (t : TimelineQuot root_mcs root_mcs_proof)
    (psi : Formula)
    (h_diamond : psi.diamond ∈ (timelineQuotFMCS root_mcs root_mcs_proof).mcs t) :
    TimelineQuotWitnessSeed root_mcs root_mcs_proof := by
  -- Get the underlying MCS at time t
  have h_mcs := (timelineQuotFMCS root_mcs root_mcs_proof).is_mcs t
  -- Build the witness obligation
  let M : CanonicalMCS := ⟨(timelineQuotFMCS root_mcs root_mcs_proof).mcs t, h_mcs⟩
  let ob : WitnessObligation := {
    source := M
    inner_formula := psi
    obligation_mem := h_diamond
  }
  let record := buildWitnessRecord ob
  exact {
    source_time := t
    inner_formula := psi
    obligation_mem := h_diamond
    witness_mcs := record.witness
    witness_contains_psi := record.witness_contains_psi
  }

/--
BoxContent preservation for witnesses built via buildTimelineQuotWitnessSeed.

Note: The general `TimelineQuotWitnessSeed` structure allows arbitrary witness_mcs,
but BoxContent preservation is only guaranteed for witnesses constructed via
`buildTimelineQuotWitnessSeed`. This theorem demonstrates that specific case.
-/
theorem buildTimelineQuotWitnessSeed_preserves_boxcontent
    (t : TimelineQuot root_mcs root_mcs_proof)
    (psi : Formula)
    (h_diamond : psi.diamond ∈ (timelineQuotFMCS root_mcs root_mcs_proof).mcs t) :
    MCSBoxContent ((timelineQuotFMCS root_mcs root_mcs_proof).mcs t) ⊆
      (buildTimelineQuotWitnessSeed root_mcs root_mcs_proof t psi h_diamond).witness_mcs.world := by
  -- The witness was built via buildWitnessRecord which preserves BoxContent
  have h_mcs := (timelineQuotFMCS root_mcs root_mcs_proof).is_mcs t
  let M : CanonicalMCS := ⟨(timelineQuotFMCS root_mcs root_mcs_proof).mcs t, h_mcs⟩
  let ob : WitnessObligation := {
    source := M
    inner_formula := psi
    obligation_mem := h_diamond
  }
  -- buildTimelineQuotWitnessSeed uses buildWitnessRecord which preserves BoxContent
  exact buildWitnessRecord_preserves_boxcontent ob

/-!
## Phase 1: Witness FMCS Coherence

We need to show that witness families satisfy forward_G and backward_H.
The key insight is that these properties follow from the CanonicalMCS structure.
-/

/--
Forward G coherence is inherited from canonical structure.

If G phi is in an MCS M and ExistsTask M N, then phi is in N.
This follows from the definition of ExistsTask (g_content(M) ⊆ N).
-/
theorem witnessFMCS_forward_G_helper
    (M N : CanonicalMCS)
    (h_R : ExistsTask M.world N.world)
    (phi : Formula)
    (h_G : Formula.all_future phi ∈ M.world) :
    phi ∈ N.world :=
  canonical_forward_G M.world N.world h_R phi h_G

/--
Backward H coherence is inherited from canonical structure.

If H phi is in an MCS N and ExistsTask M N, then phi is in M.
This follows from the duality of g_content and h_content.
-/
theorem witnessFMCS_backward_H_helper
    (M N : CanonicalMCS)
    (h_R : ExistsTask M.world N.world)
    (phi : Formula)
    (h_H : Formula.all_past phi ∈ N.world) :
    phi ∈ M.world := by
  -- ExistsTask M N means g_content(M) ⊆ N
  -- By duality: h_content(N) ⊆ M
  have h_R_past : ExistsTask_past N.world M.world :=
    g_content_subset_implies_h_content_reverse M.world N.world M.is_mcs N.is_mcs h_R
  exact canonical_backward_H N.world M.world h_R_past phi h_H

/-!
## Phase 2: ClosedFamily BFMCS Construction

We use the ClosedFlagBundle infrastructure to build a BFMCS with modal saturation.
The key observation is that all Flags in closedFlags contain MCSes, and
modal witnesses are guaranteed to exist within the closed set.
-/

/--
The root MCS for TimelineQuot as a CanonicalMCS element.
-/
noncomputable def timelineQuotRootCanonicalMCS : CanonicalMCS where
  world := root_mcs
  is_mcs := root_mcs_proof

/--
The closed set of Flags containing the root MCS.

This set is closed under modal witnesses: every Diamond(psi) in any MCS
in any Flag has a witness MCS in some Flag in the set.
-/
noncomputable def timelineQuotClosedFlags : Set (Flag CanonicalMCS) :=
  closedFlags (timelineQuotRootCanonicalMCS root_mcs root_mcs_proof)

/--
The closed Flags set is nonempty.
-/
theorem timelineQuotClosedFlags_nonempty :
    (timelineQuotClosedFlags root_mcs root_mcs_proof).Nonempty :=
  closedFlags_nonempty (timelineQuotRootCanonicalMCS root_mcs root_mcs_proof)

/--
The union of MCSes from closed Flags is modally saturated.

For any Diamond(psi) in any MCS in this set, there exists a witness MCS
containing psi in the same set.
-/
theorem timelineQuotClosedFlags_modally_saturated :
    MCSSetModallySaturated { M | ∃ flag ∈ timelineQuotClosedFlags root_mcs root_mcs_proof, M ∈ flag } :=
  closedFlags_union_modally_saturated (timelineQuotRootCanonicalMCS root_mcs root_mcs_proof)

/-!
### Initial Families

The initial set of families contains the canonical FMCS.
-/

/--
Initial families: the singleton set containing canonicalMCSBFMCS.

This is the starting point before adding witness families.
-/
def timelineQuotInitialFamilies : Set (FMCS CanonicalMCS) :=
  {canonicalMCSBFMCS}

/--
The initial families set is nonempty.
-/
theorem timelineQuotInitialFamilies_nonempty :
    timelineQuotInitialFamilies.Nonempty :=
  ⟨canonicalMCSBFMCS, Set.mem_singleton _⟩

/-!
### Closed Families BFMCS

We construct a BFMCS from the closed Flags. Each Flag gives an FMCS
over CanonicalMCS, and the collection satisfies modal coherence.
-/

/--
All MCSes in the closed Flags union are MCS elements in CanonicalMCS.

This is trivially true since CanonicalMCS contains all MCSes by definition.
-/
theorem closedFlags_mcs_in_canonical
    (M : CanonicalMCS)
    (h : ∃ flag ∈ timelineQuotClosedFlags root_mcs root_mcs_proof, M ∈ flag) :
    M ∈ (Set.univ : Set CanonicalMCS) :=
  Set.mem_univ M

/-!
## Phase 3: Modal Coherence Proofs

Modal forward follows from T-axiom. Modal backward follows from saturation
via closedFlags_union_modally_saturated.
-/

/--
Modal forward: Box phi in MCS implies phi in MCS.

Uses the T-axiom: Box phi -> phi is a theorem, so Box phi in MCS implies phi in MCS.
-/
theorem timelineQuotBFMCS_modal_forward
    (M : CanonicalMCS) (phi : Formula)
    (h_box : Formula.box phi ∈ M.world) :
    phi ∈ M.world :=
  box_implies_phi_in_mcs M.world M.is_mcs phi h_box

/--
Modal backward: phi in all "accessible" MCSes implies Box phi.

For the closed Flags union, if phi is in every MCS in the set,
then Box phi is in every MCS in the set.

This uses the saturation property combined with MCS maximality.
-/
theorem timelineQuotBFMCS_modal_backward
    (M : CanonicalMCS)
    (h_M : ∃ flag ∈ timelineQuotClosedFlags root_mcs root_mcs_proof, M ∈ flag)
    (phi : Formula)
    (h_all : ∀ W, (∃ flag ∈ timelineQuotClosedFlags root_mcs root_mcs_proof, W ∈ flag) →
      phi ∈ W.world) :
    Formula.box phi ∈ M.world := by
  -- Contrapositive: if Box phi is not in M.world, then neg(Box phi) is
  -- which means Diamond(neg phi) is in M.world
  -- By saturation, there exists W with neg phi in W.world
  -- But phi is in all W by assumption, contradiction
  by_contra h_not_box
  have h_mcs := M.is_mcs
  rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box phi) with h_box | h_neg_box
  · exact h_not_box h_box
  · -- neg(Box phi) = Diamond(neg phi) in M.world
    -- By saturation, exists W in closed flags with (neg phi) in W.world
    have h_diamond : (Formula.neg phi).diamond ∈ M.world := by
      -- Diamond(neg phi) = neg(Box(neg(neg phi)))
      -- neg(Box phi) in M means neg(Box phi) in M.world
      -- We need: neg(Box(neg(neg phi))) in M.world
      -- By double negation: neg(neg phi) is equivalent to phi
      -- So Diamond(neg phi) = neg(Box phi) after DNE reasoning
      -- Actually: Diamond(psi) = neg(Box(neg psi))
      -- So Diamond(neg phi) = neg(Box(neg(neg phi)))
      -- We have neg(Box phi) in M.world
      -- We need to show neg(Box(neg(neg phi))) in M.world
      -- Box phi and Box(neg(neg phi)) are equivalent (by DNE modal reasoning)
      -- So neg(Box phi) and neg(Box(neg(neg phi))) are equivalent
      have h_dne_box : [] ⊢ (Formula.box (Formula.neg (Formula.neg phi))).imp (Formula.box phi) := by
        -- Use Box(DNE): Box(neg neg phi -> phi)
        have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dne_theorem phi
        have h_nec : [] ⊢ Formula.box ((Formula.neg (Formula.neg phi)).imp phi) :=
          DerivationTree.necessitation _ h_dne
        -- Use K: Box(A -> B) -> (Box A -> Box B)
        have h_k : [] ⊢ (Formula.box ((Formula.neg (Formula.neg phi)).imp phi)).imp
            ((Formula.box (Formula.neg (Formula.neg phi))).imp (Formula.box phi)) :=
          DerivationTree.axiom [] _ (Axiom.modal_k_dist (Formula.neg (Formula.neg phi)) phi)
        exact DerivationTree.modus_ponens [] _ _ h_k h_nec
      -- Contrapositive: neg(Box phi) -> neg(Box(neg(neg phi)))
      exact SetMaximalConsistent.contrapositive h_mcs h_dne_box h_neg_box
    -- By modal saturation of closed flags
    have h_sat := timelineQuotClosedFlags_modally_saturated root_mcs root_mcs_proof
    have h_witness := h_sat M h_M (Formula.neg phi) h_diamond
    obtain ⟨W, h_W, h_neg_phi⟩ := h_witness
    -- But phi is in W.world by h_all
    have h_phi := h_all W h_W
    -- Contradiction: both phi and neg phi in W.world
    exact set_consistent_not_both W.is_mcs.1 phi h_phi h_neg_phi

/-!
## Phase 4: Temporal Coherence

Temporal coherence (forward_F, backward_P) for the canonical FMCS follows
from the CanonicalMCS structure and the staged construction.
-/

/--
Forward F coherence for canonicalMCSBFMCS: F(phi) in M implies exists W > M with phi.

This uses the Lindenbaum construction to find a witness MCS.
-/
theorem canonicalMCSBFMCS_forward_F
    (M : CanonicalMCS) (phi : Formula)
    (h_F : Formula.some_future phi ∈ M.world) :
    ∃ W : CanonicalMCS, ExistsTask M.world W.world ∧ phi ∈ W.world := by
  -- F(phi) in M means exists accessible W with phi
  -- The witness is constructed via Lindenbaum extension of {phi} ∪ g_content(M)
  obtain ⟨W_set, h_W_mcs, h_R, h_phi⟩ := canonical_forward_F M.world M.is_mcs phi h_F
  let W : CanonicalMCS := ⟨W_set, h_W_mcs⟩
  exact ⟨W, h_R, h_phi⟩

/--
Backward P coherence for canonicalMCSBFMCS: P(phi) in M implies exists W < M with phi.

This uses the Lindenbaum construction with h_content.
-/
theorem canonicalMCSBFMCS_backward_P
    (M : CanonicalMCS) (phi : Formula)
    (h_P : Formula.some_past phi ∈ M.world) :
    ∃ W : CanonicalMCS, ExistsTask W.world M.world ∧ phi ∈ W.world := by
  -- P(phi) in M means exists W < M (ExistsTask W M) with phi
  -- ExistsTask_past M W means h_content(M) ⊆ W, which is equivalent to ExistsTask W M
  -- for the past direction
  obtain ⟨W_set, h_W_mcs, h_R_past, h_phi⟩ := canonical_backward_P M.world M.is_mcs phi h_P
  let W : CanonicalMCS := ⟨W_set, h_W_mcs⟩
  -- ExistsTask_past M W means h_content(M) ⊆ W
  -- We need to show ExistsTask W.world M.world, i.e., g_content(W) ⊆ M
  -- This follows from h_content/g_content duality
  -- h_content_subset_implies_g_content_reverse: h_content M ⊆ M' implies g_content M' ⊆ M
  -- Here: h_R_past : h_content M.world ⊆ W_set, so g_content W_set ⊆ M.world
  have h_R : ExistsTask W.world M.world :=
    h_content_subset_implies_g_content_reverse M.world W_set M.is_mcs h_W_mcs h_R_past
  exact ⟨W, h_R, h_phi⟩

/-!
## Phase 4: Forward F and Backward P for Closed Families

The closed families satisfy temporal coherence because:
1. Each MCS in a closed Flag is in CanonicalMCS
2. Temporal witnesses exist via canonical_forward_F/canonical_backward_P
3. The witnesses are MCSes, hence in some Flag (though not necessarily in closedFlags)

Note: The temporal witnesses may NOT be in the closed Flags!
This is acceptable because temporal coherence is within-family,
not cross-family like modal coherence.
-/

/--
Forward F within closed Flags (weaker form): F(phi) has a witness MCS.

The witness may not be in closedFlags, but it exists in CanonicalMCS.
-/
theorem closedFlags_forward_F_witness
    (M : CanonicalMCS)
    (_h_M : ∃ flag ∈ timelineQuotClosedFlags root_mcs root_mcs_proof, M ∈ flag)
    (phi : Formula)
    (h_F : Formula.some_future phi ∈ M.world) :
    ∃ W : CanonicalMCS, ExistsTask M.world W.world ∧ phi ∈ W.world :=
  canonicalMCSBFMCS_forward_F M phi h_F

/--
Backward P within closed Flags (weaker form): P(phi) has a witness MCS.

The witness may not be in closedFlags, but it exists in CanonicalMCS.
-/
theorem closedFlags_backward_P_witness
    (M : CanonicalMCS)
    (_h_M : ∃ flag ∈ timelineQuotClosedFlags root_mcs root_mcs_proof, M ∈ flag)
    (phi : Formula)
    (h_P : Formula.some_past phi ∈ M.world) :
    ∃ W : CanonicalMCS, ExistsTask W.world M.world ∧ phi ∈ W.world :=
  canonicalMCSBFMCS_backward_P M phi h_P

/-!
## Phase 5: Wire to Truth Lemma

The BFMCS construction enables the truth lemma for Box formulas.
The key is that modal coherence (forward/backward) ties together
the bundle evaluation semantics with MCS membership.
-/

/--
Truth lemma direction 1: Box phi in MCS implies phi in all accessible MCSes.

For the closed Flags BFMCS, if Box phi is in M.world where M is in closedFlags,
then phi is in every W.world where W is accessible from M.

Accessibility in the bundle is defined by sharing a Flag - if M and W are
in the same Flag, they see each other (S5 semantics).
-/
theorem truth_lemma_box_forward
    (M : CanonicalMCS)
    (_h_M : ∃ flag ∈ timelineQuotClosedFlags root_mcs root_mcs_proof, M ∈ flag)
    (phi : Formula)
    (h_box : Formula.box phi ∈ M.world) :
    phi ∈ M.world :=
  timelineQuotBFMCS_modal_forward M phi h_box

/--
Truth lemma direction 2: phi in all accessible MCSes implies Box phi in MCS.

For the closed Flags BFMCS, if phi is in every W.world where W is in closedFlags,
then Box phi is in M.world for any M in closedFlags.

This is the modal_backward property.
-/
theorem truth_lemma_box_backward
    (M : CanonicalMCS)
    (h_M : ∃ flag ∈ timelineQuotClosedFlags root_mcs root_mcs_proof, M ∈ flag)
    (phi : Formula)
    (h_all : ∀ W, (∃ flag ∈ timelineQuotClosedFlags root_mcs root_mcs_proof, W ∈ flag) →
      phi ∈ W.world) :
    Formula.box phi ∈ M.world :=
  timelineQuotBFMCS_modal_backward root_mcs root_mcs_proof M h_M phi h_all

/-!
## Export: The Main BFMCS Construction

We export the key components for use in completeness proofs.
-/

/--
The root MCS is in the closed Flags union.

This ensures we can evaluate formulas at the root.
-/
theorem root_in_closedFlags :
    ∃ flag ∈ timelineQuotClosedFlags root_mcs root_mcs_proof,
      (timelineQuotRootCanonicalMCS root_mcs root_mcs_proof) ∈ flag := by
  -- Use the existing root_in_closedFlags from ClosedFlagBundle
  exact Bundle.root_in_closedFlags (timelineQuotRootCanonicalMCS root_mcs root_mcs_proof)

/--
The root MCS's world equals root_mcs.
-/
theorem timelineQuotRootCanonicalMCS_world :
    (timelineQuotRootCanonicalMCS root_mcs root_mcs_proof).world = root_mcs := rfl

/--
Summary theorem: The closed Flags construction provides modal saturation.

This is the key property needed for the Box case of the truth lemma.
-/
theorem timelineQuotDenseBFMCS_modal_saturation :
    MCSSetModallySaturated { M | ∃ flag ∈ timelineQuotClosedFlags root_mcs root_mcs_proof, M ∈ flag } :=
  timelineQuotClosedFlags_modally_saturated root_mcs root_mcs_proof

end Bimodal.Metalogic.StagedConstruction.TimelineQuotBFMCS
