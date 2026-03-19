import Bimodal.Metalogic.Bundle.ChainFMCS
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.CanonicalFMCS

/-!
# Modal Witness Data Infrastructure (Task 1003)

This module provides the `ModalWitnessData` structure and helper functions for constructing
modal witnesses in BFMCS. The key insight is that witness MCSes constructed via Lindenbaum
extension are automatically `CanonicalMCS` elements (no reachability requirement), enabling
modal saturation by construction.

## Main Definitions

- `ModalWitnessData`: Links a Diamond formula in a source MCS to its witness MCS
- `buildWitnessMCS`: Constructs the witness MCS via Lindenbaum extension
- `witnessAsCanonicalMCS`: Wraps the witness MCS as a CanonicalMCS element

## Key Property

The witness MCS is automatically a CanonicalMCS element since it is SetMaximalConsistent.
No reachability requirement is needed (unlike the failed CanonicalReachable approach).

## References

- Task 1002 design document: specs/1002_design_modal_witness_infrastructure/reports/03_design-document.md
- ChainFMCS.lean: modal_witness_seed_consistent, MCSBoxContent
- Construction.lean: lindenbaumMCS_set, lindenbaumMCS_set_is_mcs, lindenbaumMCS_set_extends
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## ModalWitnessData Structure

Links a Diamond formula in a source MCS to its witness MCS containing the inner formula.
-/

/--
Data for a single modal witness: links Diamond(psi) in a source MCS to psi in a witness MCS.

The witness MCS is constructed via Lindenbaum extension of the modal witness seed:
  {psi} ∪ MCSBoxContent(source_mcs)

This seed is consistent when Diamond(psi) is in source_mcs, by `modal_witness_seed_consistent`.
The witness MCS preserves BoxContent from the source, ensuring S5 modal coherence.

**Key Property**: The witness MCS is automatically a CanonicalMCS element since it is
SetMaximalConsistent. No reachability requirement is needed (unlike the failed
CanonicalReachable approach).
-/
structure ModalWitnessData where
  /-- The formula psi where Diamond(psi) appears in the source MCS -/
  inner_formula : Formula
  /-- The source MCS containing Diamond(psi) -/
  source_mcs : Set Formula
  /-- Proof that source is maximal consistent -/
  source_is_mcs : SetMaximalConsistent source_mcs
  /-- Proof that Diamond(psi) is in source MCS -/
  diamond_mem : inner_formula.diamond ∈ source_mcs

/-!
## Witness MCS Construction

Constructs the witness MCS via Lindenbaum extension of the modal witness seed.
-/

/--
The modal witness seed for a ModalWitnessData: {psi} ∪ BoxContent(source_mcs).

This is consistent when Diamond(psi) is in source_mcs (by `modal_witness_seed_consistent`).
-/
def ModalWitnessData.witness_seed (w : ModalWitnessData) : Set Formula :=
  ModalWitnessSeed w.source_mcs w.inner_formula

/--
The modal witness seed is consistent (delegates to `modal_witness_seed_consistent`).
-/
theorem ModalWitnessData.seed_consistent (w : ModalWitnessData) :
    SetConsistent w.witness_seed :=
  modal_witness_seed_consistent w.source_mcs w.source_is_mcs w.inner_formula w.diamond_mem

/--
Construct the witness MCS from ModalWitnessData via Lindenbaum extension.

The witness MCS contains:
1. psi (the inner formula)
2. MCSBoxContent(source_mcs) - preserved BoxContent for S5 coherence

**Implementation**: Uses `lindenbaumMCS_set` on the witness seed. Since the seed is
consistent (psi plus BoxContent where Diamond(psi) is in source), Lindenbaum extends
it to a full MCS.
-/
noncomputable def buildWitnessMCS (w : ModalWitnessData) : Set Formula :=
  lindenbaumMCS_set w.witness_seed w.seed_consistent

/--
The witness MCS is maximal consistent.
-/
theorem buildWitnessMCS_is_mcs (w : ModalWitnessData) :
    SetMaximalConsistent (buildWitnessMCS w) :=
  lindenbaumMCS_set_is_mcs w.witness_seed w.seed_consistent

/--
The witness MCS contains psi (the inner formula).
-/
theorem buildWitnessMCS_contains_psi (w : ModalWitnessData) :
    w.inner_formula ∈ buildWitnessMCS w := by
  apply lindenbaumMCS_set_extends
  -- psi is in ModalWitnessSeed = {psi} ∪ MCSBoxContent
  exact psi_mem_ModalWitnessSeed w.source_mcs w.inner_formula

/--
The witness MCS contains BoxContent from the source MCS.

This is critical for S5 modal coherence: formulas Box(phi) in source_mcs
are preserved in the witness, maintaining the modal fabric.
-/
theorem buildWitnessMCS_contains_boxcontent (w : ModalWitnessData) :
    MCSBoxContent w.source_mcs ⊆ buildWitnessMCS w := by
  intro phi h_box
  apply lindenbaumMCS_set_extends
  -- phi is in MCSBoxContent, which is subset of ModalWitnessSeed
  exact MCSBoxContent_subset_ModalWitnessSeed w.source_mcs w.inner_formula h_box

/-!
## Witness as CanonicalMCS

Wraps the witness MCS as a CanonicalMCS element.
-/

/--
Construct a CanonicalMCS element from a modal witness.

**Critical Insight**: The witness MCS is automatically a CanonicalMCS element
because CanonicalMCS only requires SetMaximalConsistent. There is no reachability
requirement (unlike CanonicalReachable which failed for backward_P).

This mirrors the success pattern from CanonicalFMCS.lean where using ALL MCSes
as domain made forward_F and backward_P trivial.
-/
noncomputable def witnessAsCanonicalMCS (w : ModalWitnessData) : CanonicalMCS :=
  { world := buildWitnessMCS w
  , is_mcs := buildWitnessMCS_is_mcs w }

/--
The witness family (viewed as CanonicalMCS) contains psi.
-/
theorem witnessAsCanonicalMCS_contains_psi (w : ModalWitnessData) :
    w.inner_formula ∈ (witnessAsCanonicalMCS w).world :=
  buildWitnessMCS_contains_psi w

/--
The witness family (viewed as CanonicalMCS) preserves BoxContent from source.
-/
theorem witnessAsCanonicalMCS_preserves_boxcontent (w : ModalWitnessData) :
    MCSBoxContent w.source_mcs ⊆ (witnessAsCanonicalMCS w).world :=
  buildWitnessMCS_contains_boxcontent w

end Bimodal.Metalogic.Bundle
