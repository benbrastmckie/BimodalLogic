import Bimodal.Metalogic.StagedConstruction.DovetailedFMCS
import Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot
import Bimodal.Metalogic.Bundle.ClosedFlagBundle
import Bimodal.Metalogic.Bundle.SaturatedBFMCSConstruction
import Bimodal.Metalogic.Bundle.CanonicalFMCS

/-!
# BFMCS over DovetailedTimelineQuot for Dense Completeness

This module constructs a temporally complete BFMCS bundle with families indexed by
DovetailedTimelineQuot satisfying both modal coherence (`modal_backward`, `modal_forward`)
and temporal coherence (`forward_F`, `backward_P`).

## Overview

This follows the dual-domain architecture from TimelineQuotBFMCS.lean:
- **Temporal domain**: DovetailedTimelineQuot (dense linear order via Cantor isomorphism)
- **Modal domain**: CanonicalMCS (all maximal consistent sets)
- **BFMCS**: Over CanonicalMCS with modal saturation via closedFlags

The BFMCS is built over CanonicalMCS (not DovetailedTimelineQuot) because:
1. Modal coherence requires quantification over families at the SAME time
2. DovetailedTimelineQuot provides temporal structure, CanonicalMCS provides modal structure
3. The truth lemma evaluates (time, history) pairs

## Key Results

- `dovetailedTimelineQuotRootCanonicalMCS`: Root MCS as CanonicalMCS element
- `dovetailedTimelineQuotClosedFlags`: Modally saturated closed flags
- `dovetailedTimelineQuotBFMCS_modal_forward`: Modal forward via T-axiom
- `dovetailedTimelineQuotBFMCS_modal_backward`: Modal backward via saturation

## References

- Task 18: Dense representation theorem completion
- DovetailedFMCS.lean: Temporal FMCS construction
- TimelineQuotBFMCS.lean: Pattern for BFMCS construction
- ClosedFlagBundle.lean: closedFlags saturation infrastructure
-/

namespace Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuotBFMCS

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot
open Bimodal.Metalogic.StagedConstruction.DovetailedFMCS
open Bimodal.Metalogic.StagedConstruction.DovetailedBuild
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Phase 4.1: Root MCS as CanonicalMCS

The root MCS from the dovetailed construction serves as the anchor for the
closedFlags saturation.
-/

/--
The root MCS for DovetailedTimelineQuot as a CanonicalMCS element.
-/
noncomputable def dovetailedTimelineQuotRootCanonicalMCS : CanonicalMCS where
  world := root_mcs
  is_mcs := root_mcs_proof

/--
The closed set of Flags containing the root MCS.

This set is closed under modal witnesses: every Diamond(psi) in any MCS
in any Flag has a witness MCS in some Flag in the set.
-/
noncomputable def dovetailedTimelineQuotClosedFlags : Set (Flag CanonicalMCS) :=
  closedFlags (dovetailedTimelineQuotRootCanonicalMCS root_mcs root_mcs_proof)

/--
The closed Flags set is nonempty.
-/
theorem dovetailedTimelineQuotClosedFlags_nonempty :
    (dovetailedTimelineQuotClosedFlags root_mcs root_mcs_proof).Nonempty :=
  closedFlags_nonempty (dovetailedTimelineQuotRootCanonicalMCS root_mcs root_mcs_proof)

/--
The union of MCSes from closed Flags is modally saturated.

For any Diamond(psi) in any MCS in this set, there exists a witness MCS
containing psi in the same set.
-/
theorem dovetailedTimelineQuotClosedFlags_modally_saturated :
    MCSSetModallySaturated { M | ∃ flag ∈ dovetailedTimelineQuotClosedFlags root_mcs root_mcs_proof, M ∈ flag } :=
  closedFlags_union_modally_saturated (dovetailedTimelineQuotRootCanonicalMCS root_mcs root_mcs_proof)

/-!
## Phase 4.2: Modal Coherence Proofs

Modal forward follows from T-axiom. Modal backward follows from saturation
via closedFlags_union_modally_saturated.
-/

/--
Modal forward: Box phi in MCS implies phi in MCS.

Uses the T-axiom: Box phi -> phi is a theorem, so Box phi in MCS implies phi in MCS.
-/
theorem dovetailedTimelineQuotBFMCS_modal_forward
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
theorem dovetailedTimelineQuotBFMCS_modal_backward
    (M : CanonicalMCS)
    (h_M : ∃ flag ∈ dovetailedTimelineQuotClosedFlags root_mcs root_mcs_proof, M ∈ flag)
    (phi : Formula)
    (h_all : ∀ W, (∃ flag ∈ dovetailedTimelineQuotClosedFlags root_mcs root_mcs_proof, W ∈ flag) →
      phi ∈ W.world) :
    Formula.box phi ∈ M.world := by
  by_contra h_not_box
  have h_mcs := M.is_mcs
  rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box phi) with h_box | h_neg_box
  · exact h_not_box h_box
  · have h_diamond : (Formula.neg phi).diamond ∈ M.world := by
      have h_dne_box : [] ⊢ (Formula.box (Formula.neg (Formula.neg phi))).imp (Formula.box phi) := by
        have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dne_theorem phi
        have h_nec : [] ⊢ Formula.box ((Formula.neg (Formula.neg phi)).imp phi) :=
          DerivationTree.necessitation _ h_dne
        have h_k : [] ⊢ (Formula.box ((Formula.neg (Formula.neg phi)).imp phi)).imp
            ((Formula.box (Formula.neg (Formula.neg phi))).imp (Formula.box phi)) :=
          DerivationTree.axiom [] _ (Axiom.modal_k_dist (Formula.neg (Formula.neg phi)) phi)
        exact DerivationTree.modus_ponens [] _ _ h_k h_nec
      exact SetMaximalConsistent.contrapositive h_mcs h_dne_box h_neg_box
    have h_sat := dovetailedTimelineQuotClosedFlags_modally_saturated root_mcs root_mcs_proof
    have h_witness := h_sat M h_M (Formula.neg phi) h_diamond
    obtain ⟨W, h_W, h_neg_phi⟩ := h_witness
    have h_phi := h_all W h_W
    exact set_consistent_not_both W.is_mcs.1 phi h_phi h_neg_phi

/-!
## Phase 4.3: Temporal Coherence via DovetailedFMCS

The temporal coherence comes from the existing dovetailedFMCS construction.
-/

/--
The dovetailed FMCS provides temporal coherence.
Re-export for convenience.
-/
noncomputable def dovetailedTimelineQuotTemporalFMCS :
    FMCS (DovetailedTimelineQuot root_mcs root_mcs_proof) :=
  dovetailedFMCS root_mcs root_mcs_proof

/-!
## Phase 4.4: Root in Closed Flags

The root MCS is in the closed flags, ensuring we can evaluate formulas at the root.
-/

/--
The root MCS is in the closed Flags union.
-/
theorem root_in_dovetailedTimelineQuotClosedFlags :
    ∃ flag ∈ dovetailedTimelineQuotClosedFlags root_mcs root_mcs_proof,
      (dovetailedTimelineQuotRootCanonicalMCS root_mcs root_mcs_proof) ∈ flag :=
  Bundle.root_in_closedFlags (dovetailedTimelineQuotRootCanonicalMCS root_mcs root_mcs_proof)

/--
The root MCS's world equals root_mcs.
-/
theorem dovetailedTimelineQuotRootCanonicalMCS_world :
    (dovetailedTimelineQuotRootCanonicalMCS root_mcs root_mcs_proof).world = root_mcs := rfl

/-!
## Phase 4.5: Summary Theorem

The closed Flags construction provides modal saturation for DovetailedTimelineQuot.
-/

/--
Summary theorem: The closed Flags construction provides modal saturation.

This is the key property needed for the Box case of the truth lemma.
-/
theorem dovetailedTimelineQuotDenseBFMCS_modal_saturation :
    MCSSetModallySaturated { M | ∃ flag ∈ dovetailedTimelineQuotClosedFlags root_mcs root_mcs_proof, M ∈ flag } :=
  dovetailedTimelineQuotClosedFlags_modally_saturated root_mcs root_mcs_proof

end Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuotBFMCS
