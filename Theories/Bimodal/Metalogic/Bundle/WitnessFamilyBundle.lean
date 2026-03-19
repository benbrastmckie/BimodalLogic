import Bimodal.Metalogic.Bundle.ChainFMCS
import Bimodal.Metalogic.Bundle.ModalWitnessData
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.BFMCS

/-!
# Witness Family Bundle Infrastructure (Task 1003)

This module provides the infrastructure for tracking modal obligations and their
witnesses in a multi-family BFMCS construction. The key insight is that modal
saturation requires families with DIFFERENT mcs functions - witness families
that place witness MCSes at specific times.

## Overview

The singleton bundle `{canonicalMCSBFMCS}` fails modal saturation because
`Diamond(psi) in t.world` does NOT imply `psi in t.world`. The correct approach
uses multi-family bundles where witness families have mcs functions that map
specific times to witness MCSes.

## Main Definitions

- `WitnessObligation`: A Diamond formula obligation in a source MCS
- `WitnessRecord`: Links an obligation to its witness MCS
- `buildWitnessRecord`: Constructs witness records using ModalWitnessData

## Key Property

For every `WitnessRecord`, the witness MCS contains the inner formula (psi).
This is the foundation for proving modal saturation.

## References

- Task 1003 blocker analysis: specs/1003_implement_modal_coherence/reports/03_blocker-analysis.md
- ModalWitnessData.lean: witness MCS construction
- ChainFMCS.lean: modal_witness_seed_consistent, Flag infrastructure
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## WitnessObligation Structure

A witness obligation records a Diamond formula in a source MCS that requires
a witness family to satisfy modal saturation.
-/

/--
A modal witness obligation: records Diamond(psi) membership in a source MCS.

This captures the data needed to construct a witness family:
- `source`: The CanonicalMCS containing the Diamond formula
- `inner_formula`: The formula psi inside the Diamond
- `obligation_mem`: Proof that Diamond(psi) is in the source MCS

The witness for this obligation is a CanonicalMCS element containing psi.
-/
structure WitnessObligation where
  /-- The source MCS containing Diamond(psi) -/
  source : CanonicalMCS
  /-- The formula psi where Diamond(psi) is the obligation -/
  inner_formula : Formula
  /-- Proof that Diamond(psi) is in the source MCS -/
  obligation_mem : inner_formula.diamond ∈ source.world

/-!
## WitnessRecord Structure

A witness record extends an obligation with its witness MCS and proof.
-/

/--
A witness record: links a Diamond obligation to its witness MCS.

The witness MCS contains:
1. psi (the inner formula) - guaranteed by witness construction
2. BoxContent from source - preserved for modal coherence

This is the key data for constructing witness families in the multi-family BFMCS.
-/
structure WitnessRecord extends WitnessObligation where
  /-- The witness MCS containing psi -/
  witness : CanonicalMCS
  /-- Proof that psi is in the witness MCS -/
  witness_contains_psi : inner_formula ∈ witness.world

/-!
## WitnessRecord Construction

Build witness records using the ModalWitnessData infrastructure.
-/

/--
Build a ModalWitnessData from a WitnessObligation.

This is the intermediate step before constructing the witness MCS.
-/
def WitnessObligation.toModalWitnessData (ob : WitnessObligation) : ModalWitnessData where
  inner_formula := ob.inner_formula
  source_mcs := ob.source.world
  source_is_mcs := ob.source.is_mcs
  diamond_mem := ob.obligation_mem

/--
Build a WitnessRecord from a WitnessObligation by constructing the witness MCS.

The witness is built via Lindenbaum extension of the modal witness seed:
  {psi} ∪ MCSBoxContent(source_mcs)

This is consistent by `modal_witness_seed_consistent` and contains psi
by `witnessAsCanonicalMCS_contains_psi`.
-/
noncomputable def buildWitnessRecord (ob : WitnessObligation) : WitnessRecord where
  source := ob.source
  inner_formula := ob.inner_formula
  obligation_mem := ob.obligation_mem
  witness := witnessAsCanonicalMCS ob.toModalWitnessData
  witness_contains_psi := witnessAsCanonicalMCS_contains_psi ob.toModalWitnessData

/--
The witness in a built WitnessRecord contains the inner formula.

This is the key property for modal saturation: the witness MCS has psi
when Diamond(psi) is in the source MCS.
-/
theorem buildWitnessRecord_contains_psi (ob : WitnessObligation) :
    ob.inner_formula ∈ (buildWitnessRecord ob).witness.world :=
  (buildWitnessRecord ob).witness_contains_psi

/--
The witness in a built WitnessRecord preserves BoxContent from the source.

This is important for modal coherence: Box formulas from the source
are preserved in the witness MCS.
-/
theorem buildWitnessRecord_preserves_boxcontent (ob : WitnessObligation) :
    MCSBoxContent ob.source.world ⊆ (buildWitnessRecord ob).witness.world :=
  witnessAsCanonicalMCS_preserves_boxcontent ob.toModalWitnessData

/-!
## Witness Family Type

A witness family is an FMCS that maps a specific time point to a witness MCS.
The challenge is defining an FMCS where:
- `mcs t0 = W` (the witness MCS at the obligation time)
- Temporal coherence (forward_G, backward_H) is satisfied

For the multi-family BFMCS approach, we use a simpler structure:
- All families share the same domain (CanonicalMCS)
- Witness families differ in their `mcs` functions
- Modal saturation is achieved by having the right witness families
-/

-- NOTE: Constant witness families are NOT valid for temporal coherence.
-- Constant families violate forward_G (G phi in MCS implies phi at later times).
-- Counterexample: MCS with {G(psi), neg(psi)} is consistent.
-- See ModalSaturation.lean for why constant witness families fail.

/-!
## Modal Saturation via Multi-Flag Bundle

The correct approach uses Flags (maximal chains) as families:
- Each Flag gives a `chainFMCS flag : FMCS (ChainFMCSDomain flag)`
- Different Diamond witnesses land in different Flags
- Modal coherence is established via BoxContent propagation

However, BFMCS requires all families to have the same domain type.
We need to either:
1. Lift chainFMCS to work over CanonicalMCS
2. Use a heterogeneous bundle structure
3. Use canonicalMCSBFMCS with witness-aware evaluation

The implementation continues in ClosedFlagBundle.lean (Phase 2).
-/

/-!
## Utility: Collect All Obligations

Given a set of CanonicalMCS elements (e.g., from a Flag), collect all
Diamond obligations that need witnesses.
-/

/--
All Diamond obligations in a single MCS.

Returns the set of formulas psi such that Diamond(psi) is in the MCS.
-/
def allDiamondObligations (M : CanonicalMCS) : Set Formula :=
  { psi | psi.diamond ∈ M.world }

/--
Build a WitnessObligation for each Diamond formula in an MCS.

Given psi in allDiamondObligations M, construct the WitnessObligation.
-/
def mkWitnessObligation (M : CanonicalMCS) (psi : Formula) (h : psi ∈ allDiamondObligations M) :
    WitnessObligation where
  source := M
  inner_formula := psi
  obligation_mem := h

/-!
## Key Theorem: Witness Existence

For every Diamond obligation, we can construct a witness MCS.
This is the foundation for modal saturation.
-/

/--
For every Diamond(psi) in an MCS M, there exists a witness CanonicalMCS
containing psi.

This is the key existence theorem for modal saturation. The witness is
constructed via Lindenbaum extension of the modal witness seed.
-/
theorem witness_exists_for_diamond (M : CanonicalMCS) (psi : Formula)
    (h_diamond : psi.diamond ∈ M.world) :
    ∃ W : CanonicalMCS, psi ∈ W.world := by
  let ob : WitnessObligation := {
    source := M
    inner_formula := psi
    obligation_mem := h_diamond
  }
  exact ⟨(buildWitnessRecord ob).witness, (buildWitnessRecord ob).witness_contains_psi⟩

/--
For every Diamond(psi) in an MCS M, the witness MCS preserves BoxContent from M.

This ensures modal coherence: Box formulas are propagated to witnesses.
-/
theorem witness_preserves_boxcontent (M : CanonicalMCS) (psi : Formula)
    (h_diamond : psi.diamond ∈ M.world) :
    ∃ W : CanonicalMCS, psi ∈ W.world ∧ MCSBoxContent M.world ⊆ W.world := by
  let ob : WitnessObligation := {
    source := M
    inner_formula := psi
    obligation_mem := h_diamond
  }
  exact ⟨(buildWitnessRecord ob).witness,
         (buildWitnessRecord ob).witness_contains_psi,
         buildWitnessRecord_preserves_boxcontent ob⟩

end Bimodal.Metalogic.Bundle
