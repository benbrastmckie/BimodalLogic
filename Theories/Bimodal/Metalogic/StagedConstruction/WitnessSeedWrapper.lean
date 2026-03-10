import Bimodal.Metalogic.Canonical.CanonicalTimeline
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.StagedConstruction.StagedTimeline

/-!
# Witness Seed Wrappers for Staged Construction

This module provides the core forward/backward temporal witness construction
functions and their properties, adapted for use in the staged timeline.

## Core Functions

- `executeForwardStep`: Given MCS M with F(psi) ∈ M, create forward witness W
- `executeBackwardStep`: Given MCS M with P(psi) ∈ M, create backward witness W
- `forwardWitnessPoint` / `backwardWitnessPoint`: Stage-annotated versions

## Key Properties

- Forward witness: CanonicalR(M, W), psi ∈ W, W is MCS
- Backward witness: CanonicalR(W, M), psi ∈ W, W is MCS

## Strictness Note

Individual witness steps are NOT necessarily strict under irreflexive semantics.
The staged construction ensures density and no-endpoints through the overall
construction (odd stages insert intermediates), not through step strictness.
See research-034 for detailed analysis.

## References

- Task 956 plan v014: Phase 2
- WitnessSeed.lean: Consistency proofs
- CanonicalFrame.lean: CanonicalR, canonical_forward_F, canonical_backward_P
- CanonicalTimeline.lean: Seriality and density
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem

/-!
## Execute Step Functions

These create specific Lindenbaum witnesses for F/P obligations.
Replicated from ConstructiveFragment.lean to avoid importing that module
(which has pre-existing build errors from Lean version migration).
-/

/--
Execute a single forward witness step: given an MCS M with F(phi) ∈ M,
return the specific Lindenbaum witness MCS containing {phi} ∪ GContent(M).
-/
noncomputable def executeForwardStep (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) : Set Formula :=
  lindenbaumMCS_set (ForwardTemporalWitnessSeed M phi)
    (forward_temporal_witness_seed_consistent M h_mcs phi h_F)

/--
Execute a single backward witness step: given an MCS M with P(phi) ∈ M,
return the specific Lindenbaum witness MCS containing {phi} ∪ HContent(M).
-/
noncomputable def executeBackwardStep (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) : Set Formula :=
  lindenbaumMCS_set (PastTemporalWitnessSeed M phi)
    (past_temporal_witness_seed_consistent M h_mcs phi h_P)

/-!
## CanonicalR Properties
-/

theorem executeForwardStep_canonicalR {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {phi : Formula} {h_F : Formula.some_future phi ∈ M} :
    CanonicalR M (executeForwardStep M h_mcs phi h_F) :=
  fun _ h_psi => lindenbaumMCS_set_extends _ _ (GContent_subset_ForwardTemporalWitnessSeed M phi h_psi)

theorem executeBackwardStep_canonicalR_past {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {phi : Formula} {h_P : Formula.some_past phi ∈ M} :
    CanonicalR_past M (executeBackwardStep M h_mcs phi h_P) :=
  fun _ h_psi => lindenbaumMCS_set_extends _ _ (HContent_subset_PastTemporalWitnessSeed M phi h_psi)

theorem executeBackwardStep_canonicalR {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {phi : Formula} {h_P : Formula.some_past phi ∈ M} :
    CanonicalR (executeBackwardStep M h_mcs phi h_P) M :=
  HContent_subset_implies_GContent_reverse M _ h_mcs
    (lindenbaumMCS_set_is_mcs _ _)
    (executeBackwardStep_canonicalR_past (h_mcs := h_mcs) (h_P := h_P))

/-!
## MCS Properties
-/

theorem executeForwardStep_mcs {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {phi : Formula} {h_F : Formula.some_future phi ∈ M} :
    SetMaximalConsistent (executeForwardStep M h_mcs phi h_F) :=
  lindenbaumMCS_set_is_mcs _ _

theorem executeBackwardStep_mcs {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {phi : Formula} {h_P : Formula.some_past phi ∈ M} :
    SetMaximalConsistent (executeBackwardStep M h_mcs phi h_P) :=
  lindenbaumMCS_set_is_mcs _ _

/-!
## Seed Extension Properties
-/

/--
The forward witness contains phi (the target formula from the F-obligation).
-/
theorem executeForwardStep_contains_phi {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {phi : Formula} {h_F : Formula.some_future phi ∈ M} :
    phi ∈ executeForwardStep M h_mcs phi h_F :=
  lindenbaumMCS_set_extends _ _ (psi_mem_ForwardTemporalWitnessSeed M phi)

/--
The backward witness contains phi (the target formula from the P-obligation).
-/
theorem executeBackwardStep_contains_phi {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {phi : Formula} {h_P : Formula.some_past phi ∈ M} :
    phi ∈ executeBackwardStep M h_mcs phi h_P :=
  lindenbaumMCS_set_extends _ _ (psi_mem_PastTemporalWitnessSeed M phi)

/-!
## StagedPoint Wrappers

Wrap the execute step functions to produce StagedPoints with stage annotations.
-/

/--
Create a StagedPoint from a forward witness step at a given stage.
-/
noncomputable def forwardWitnessPoint
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M)
    (stage : Stage) : StagedPoint where
  mcs := executeForwardStep M h_mcs phi h_F
  is_mcs := executeForwardStep_mcs
  introduced_at := stage

/--
Create a StagedPoint from a backward witness step at a given stage.
-/
noncomputable def backwardWitnessPoint
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M)
    (stage : Stage) : StagedPoint where
  mcs := executeBackwardStep M h_mcs phi h_P
  is_mcs := executeBackwardStep_mcs
  introduced_at := stage

/--
The forward witness point is in the canonical future of M.
-/
theorem forwardWitnessPoint_canonicalR
    {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {phi : Formula} {h_F : Formula.some_future phi ∈ M}
    {stage : Stage} :
    CanonicalR M (forwardWitnessPoint M h_mcs phi h_F stage).mcs :=
  executeForwardStep_canonicalR (h_mcs := h_mcs) (h_F := h_F)

/--
The backward witness point has M in its canonical future.
-/
theorem backwardWitnessPoint_canonicalR
    {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {phi : Formula} {h_P : Formula.some_past phi ∈ M}
    {stage : Stage} :
    CanonicalR (backwardWitnessPoint M h_mcs phi h_P stage).mcs M :=
  executeBackwardStep_canonicalR (h_mcs := h_mcs) (h_P := h_P)

/--
The forward witness point contains phi.
-/
theorem forwardWitnessPoint_contains_phi
    {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {phi : Formula} {h_F : Formula.some_future phi ∈ M}
    {stage : Stage} :
    phi ∈ (forwardWitnessPoint M h_mcs phi h_F stage).mcs :=
  executeForwardStep_contains_phi (h_mcs := h_mcs) (h_F := h_F)

/--
The backward witness point contains phi.
-/
theorem backwardWitnessPoint_contains_phi
    {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {phi : Formula} {h_P : Formula.some_past phi ∈ M}
    {stage : Stage} :
    phi ∈ (backwardWitnessPoint M h_mcs phi h_P stage).mcs :=
  executeBackwardStep_contains_phi (h_mcs := h_mcs) (h_P := h_P)

/-!
## Seriality Witnesses

Every MCS has canonical successors and predecessors (from seriality axioms).
These provide the F/P obligations that the even stages process.
-/

/--
Every StagedPoint has F(¬⊥) in its MCS (seriality future axiom is a theorem).
-/
theorem stagedPoint_has_seriality_future (p : StagedPoint) :
    Formula.some_future (Formula.neg Formula.bot) ∈ p.mcs :=
  mcs_contains_seriality_future p.mcs p.is_mcs

/--
Every StagedPoint has P(¬⊥) in its MCS (seriality past axiom is a theorem).
-/
theorem stagedPoint_has_seriality_past (p : StagedPoint) :
    Formula.some_past (Formula.neg Formula.bot) ∈ p.mcs :=
  mcs_contains_seriality_past p.mcs p.is_mcs

/-!
## Density from Density Axiom

The density axiom F(psi) → F(F(psi)) provides intermediate witnesses.
-/

/--
Given F(psi) ∈ M, there exists W with CanonicalR(M, W) and F(psi) ∈ W.
This is the key property for odd-stage density insertion.
-/
theorem density_witness_exists
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧
      Formula.some_future psi ∈ W :=
  density_of_canonicalR M h_mcs psi h_F

-- Note: The forward witness for F(psi) does not necessarily preserve F(psi) in W.
-- The density axiom separately gives intermediate witnesses that DO preserve F(psi).
-- For the staged construction, density is ensured by odd stages using
-- `density_witness_exists`, not by properties of individual forward witnesses.

end Bimodal.Metalogic.StagedConstruction
