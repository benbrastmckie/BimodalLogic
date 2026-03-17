import Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical
import Bimodal.Metalogic.Bundle.ChainFMCS

/-!
# Witness Chain FMCS for TimelineQuot

This module provides witness family construction for modal saturation over TimelineQuot.
A witness family is an FMCS that contains a specific "witness" MCS at a designated time,
used to satisfy Diamond formula requirements in the truth lemma.

## Overview

For modal saturation, when we have ◇ψ in some family at time t, we need a witness family
where ψ is in the MCS at time t. This module constructs such families while maintaining
temporal coherence (forward_G, backward_H).

## Key Insight

TimelineQuot elements already have associated MCSs via `timelineQuotMCS`. A witness
family replaces the MCS at the seed time with the witness MCS while preserving the
structure elsewhere. The key is that:

1. The witness MCS is consistent with the temporal structure
2. CanonicalR relationships are maintained for forward_G/backward_H

## Construction Strategy

Given a witness MCS M_w and seed time t_seed:
1. For t = t_seed: use M_w
2. For t ≠ t_seed: use the original timelineQuotMCS assignment

The coherence proofs require that M_w is "compatible" with the timeline at t_seed,
which is ensured by the modal saturation condition (◇ψ implies ψ is consistent).

## References

- Task 982: Wire dense completeness domain connection
- research-006.md: Axiom-free modal saturation analysis
- ChainFMCS.lean: Chain-based FMCS infrastructure
-/

namespace Bimodal.Metalogic.StagedConstruction.WitnessChainFMCS

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness
open Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Modal Witness Seed for TimelineQuot

When ◇ψ is in an MCS at some time, we can build a witness MCS containing ψ
by extending {ψ} ∪ BoxContent(M) via Lindenbaum's lemma.
-/

/--
Build a witness MCS containing ψ from an MCS M where ◇ψ ∈ M.

This uses `modal_witness_seed_consistent` from ChainFMCS.lean to establish
that {ψ} ∪ BoxContent(M) is consistent, then extends to a full MCS.
-/
noncomputable def buildWitnessMCS
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : psi.diamond ∈ M) :
    Set Formula :=
  lindenbaumMCS_set (ModalWitnessSeed M psi) (modal_witness_seed_consistent M h_mcs psi h_diamond)

/--
The witness MCS contains ψ.
-/
theorem buildWitnessMCS_contains_psi
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : psi.diamond ∈ M) :
    psi ∈ buildWitnessMCS M h_mcs psi h_diamond := by
  have h_extends := lindenbaumMCS_set_extends (ModalWitnessSeed M psi)
    (modal_witness_seed_consistent M h_mcs psi h_diamond)
  exact h_extends (psi_mem_ModalWitnessSeed M psi)

/--
The witness MCS is maximal consistent.
-/
theorem buildWitnessMCS_is_mcs
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : psi.diamond ∈ M) :
    SetMaximalConsistent (buildWitnessMCS M h_mcs psi h_diamond) :=
  lindenbaumMCS_set_is_mcs (ModalWitnessSeed M psi)
    (modal_witness_seed_consistent M h_mcs psi h_diamond)

/--
The witness MCS contains BoxContent(M).

This is crucial: the witness MCS preserves all Box formulas from the original MCS,
enabling inter-family modal coherence.
-/
theorem buildWitnessMCS_contains_boxcontent
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : psi.diamond ∈ M) :
    MCSBoxContent M ⊆ buildWitnessMCS M h_mcs psi h_diamond := by
  have h_extends := lindenbaumMCS_set_extends (ModalWitnessSeed M psi)
    (modal_witness_seed_consistent M h_mcs psi h_diamond)
  exact fun phi h_phi => h_extends (MCSBoxContent_subset_ModalWitnessSeed M psi h_phi)

/-!
## Witness Family Structure

A witness family over TimelineQuot provides an FMCS where:
- At the seed time: the witness MCS
- At other times: follows canonical structure

The key insight is that we need the witness family to be temporally coherent,
which requires the witness MCS to be compatible with the timeline structure.

For simplicity, we construct witness families as the original timelineQuotFMCS
but use the containment of BoxContent to establish that modal saturation holds.
-/

/--
Structure bundling a witness MCS with its containment of a specific formula.
-/
structure WitnessMCSData (psi : Formula) where
  /-- The witness MCS -/
  mcs : Set Formula
  /-- Proof that it's maximal consistent -/
  is_mcs : SetMaximalConsistent mcs
  /-- The witness contains psi -/
  contains_psi : psi ∈ mcs

/--
Create WitnessMCSData from a source MCS containing ◇ψ.
-/
noncomputable def mkWitnessMCSData
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : psi.diamond ∈ M) :
    WitnessMCSData psi :=
  { mcs := buildWitnessMCS M h_mcs psi h_diamond
  , is_mcs := buildWitnessMCS_is_mcs M h_mcs psi h_diamond
  , contains_psi := buildWitnessMCS_contains_psi M h_mcs psi h_diamond }

/-!
## Key Theorem: Modal Forward from BoxContent Containment

The critical insight is that modal_forward holds between any two MCSs M₁, M₂
if BoxContent(M₁) ⊆ M₂. This allows witness families built via BoxContent
extension to satisfy the BFMCS modal coherence conditions.
-/

/--
If BoxContent(M₁) ⊆ M₂ and □φ ∈ M₁, then φ ∈ M₂.

This follows directly from the definition of BoxContent.
-/
theorem boxcontent_subset_implies_box_forward
    (M₁ M₂ : Set Formula)
    (h_sub : MCSBoxContent M₁ ⊆ M₂)
    (phi : Formula) (h_box : Formula.box phi ∈ M₁) :
    phi ∈ M₂ := by
  -- Box phi ∈ M₁ means phi ∈ BoxContent(M₁)
  have h_in_bc : phi ∈ MCSBoxContent M₁ := h_box
  exact h_sub h_in_bc

/-!
## Witness Family as Wrapped Original Family

Rather than building a completely new FMCS, we observe that:
1. `timelineQuotFMCS` already provides the temporal structure
2. For modal saturation, we need witnesses at specific times
3. The witness MCS built via BoxContent inherits the necessary Box formulas

The modal saturation property will be established at the BFMCS level in
ClosureSaturation.lean by showing that whenever ◇ψ appears, a witness MCS
containing ψ exists (built via buildWitnessMCS).

For the FMCS structure itself, we use the original timelineQuotFMCS.
The key insight is that modal_forward doesn't require the families to be
identical - it only requires Box formula membership to transfer.
-/

/--
The original timelineQuotFMCS serves as the primary evaluation family.

Modal saturation is achieved not by modifying this FMCS but by constructing
a BFMCS bundle where additional witness families provide the necessary
psi-containing MCSs when ◇ψ appears.
-/
noncomputable abbrev primaryFMCS : FMCS (TimelineQuot root_mcs root_mcs_proof) :=
  timelineQuotFMCS root_mcs root_mcs_proof

/-!
## Summary

This module establishes:
1. `buildWitnessMCS`: Construct witness MCS from ◇ψ membership
2. `buildWitnessMCS_contains_psi`: The witness contains ψ
3. `buildWitnessMCS_contains_boxcontent`: The witness preserves BoxContent
4. `boxcontent_subset_implies_box_forward`: BoxContent containment implies modal forward

The actual BFMCS construction with modal saturation is in ClosureSaturation.lean,
which uses these primitives to build the witness families for each Diamond formula
in the subformula closure.
-/

end Bimodal.Metalogic.StagedConstruction.WitnessChainFMCS
