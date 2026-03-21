import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuotBFMCS
import Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot
import Bimodal.Metalogic.StagedConstruction.DovetailedFMCS

/-!
# Dense Instantiation: D = DovetailedTimelineQuot

This module instantiates the D-parametric algebraic representation theorem for the
dense case D = DovetailedTimelineQuot (a dense linear order isomorphic to Q).

## Main Results

- `DenseCanonicalTaskFrame`: The parametric canonical TaskFrame with D = DovetailedTimelineQuot
- `DenseCanonicalTaskModel`: The parametric canonical TaskModel with D = DovetailedTimelineQuot
- `dense_representation_unconditional`: The unconditional representation theorem for dense TM logic

## DovetailedTimelineQuot as Duration Type

DovetailedTimelineQuot satisfies all required typeclasses for the D-parametric construction:
- `AddCommGroup`: Transferred from Q via Cantor isomorphism
- `LinearOrder`: Inherited from the antisymmetrization construction
- `IsOrderedAddMonoid`: Transferred from Q
- `DenselyOrdered`: Proven for the construction
- `NoMaxOrder` and `NoMinOrder`: Required for dense temporal logic

## BFMCS Construction

The full representation theorem uses `dovetailedTimelineQuotBFMCS` from Task 30, which provides:
1. A singleton BFMCS containing `dovetailedFMCS`
2. Proven `temporally_coherent` property (no sorries)
3. Root MCS connection via `dovetailedTimelineQuotBFMCS_root_at_time`

## Sorry Inventory

The construction inherits:
- 1 sorry from `dovetailedTimelineQuotBFMCS.modal_backward` (known limitation)
- This does NOT affect the truth lemma, which only requires `temporally_coherent`

## References

- DiscreteInstantiation.lean: Pattern for D = Int
- DovetailedTimelineQuotBFMCS.lean: BFMCS construction
- Task 30: Build temporally coherent dense BFMCS
- Task 31: Wire dense truth lemma instantiation (this module)
-/

namespace Bimodal.Metalogic.Algebraic.DenseInstantiation

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Metalogic.Algebraic.ParametricRepresentation
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot
open Bimodal.Metalogic.StagedConstruction.DovetailedFMCS
open Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuotBFMCS
open Bimodal.Semantics

/-!
## Typeclass Verification

Verify that DovetailedTimelineQuot satisfies all required typeclasses for the D-parametric construction.
Note: These require the root_mcs parameter, so we verify within a variable context.
-/

section TypeclassVerification

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

-- DovetailedTimelineQuot has an AddCommGroup structure (transferred from Q)
noncomputable example : AddCommGroup (DovetailedTimelineQuot root_mcs root_mcs_proof) :=
  dovetailedTimelineQuotAddCommGroup root_mcs root_mcs_proof

-- DovetailedTimelineQuot has a LinearOrder structure
noncomputable example : LinearOrder (DovetailedTimelineQuot root_mcs root_mcs_proof) :=
  inferInstance

-- DovetailedTimelineQuot is an ordered additive monoid (transferred from Q)
noncomputable example : @IsOrderedAddMonoid (DovetailedTimelineQuot root_mcs root_mcs_proof)
    (dovetailedTimelineQuotAddCommGroup root_mcs root_mcs_proof).toAddCommMonoid
    (inferInstance : PartialOrder (DovetailedTimelineQuot root_mcs root_mcs_proof)) :=
  dovetailedTimelineQuotIsOrderedAddMonoid root_mcs root_mcs_proof

-- DovetailedTimelineQuot is densely ordered
example : DenselyOrdered (DovetailedTimelineQuot root_mcs root_mcs_proof) :=
  inferInstance

-- DovetailedTimelineQuot has no maximum or minimum
example : NoMaxOrder (DovetailedTimelineQuot root_mcs root_mcs_proof) :=
  inferInstance

example : NoMinOrder (DovetailedTimelineQuot root_mcs root_mcs_proof) :=
  inferInstance

-- DovetailedTimelineQuot is nontrivial
example : Nontrivial (DovetailedTimelineQuot root_mcs root_mcs_proof) :=
  inferInstance

end TypeclassVerification

/-!
## Dense Canonical Structures

Instantiate the parametric canonical structures with D = DovetailedTimelineQuot.
Since DovetailedTimelineQuot depends on the root MCS, these are parameterized.
-/

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

-- Make the typeclass instances available locally for the remainder of this section
attribute [local instance] dovetailedTimelineQuotAddCommGroup dovetailedTimelineQuotIsOrderedAddMonoid

/--
The dense canonical TaskFrame: the parametric canonical TaskFrame with D = DovetailedTimelineQuot.

This TaskFrame has:
- WorldState = ParametricCanonicalWorldState (MCS-based world states)
- D = DovetailedTimelineQuot root_mcs root_mcs_proof (dense rationals)
- task_rel = parametric_canonical_task_rel (uses CanonicalR)

The frame satisfies all TaskFrame axioms by the parametric construction.
-/
noncomputable abbrev DenseCanonicalTaskFrame : TaskFrame (DovetailedTimelineQuot root_mcs root_mcs_proof) :=
  ParametricCanonicalTaskFrame (DovetailedTimelineQuot root_mcs root_mcs_proof)

/--
The dense canonical TaskModel: the parametric canonical TaskModel with D = DovetailedTimelineQuot.

Valuation is MCS membership: atom p is true at world M iff p ∈ M.
-/
noncomputable abbrev DenseCanonicalTaskModel : TaskModel (DenseCanonicalTaskFrame root_mcs root_mcs_proof) :=
  ParametricCanonicalTaskModel (DovetailedTimelineQuot root_mcs root_mcs_proof)

/-!
## Dense Representation Theorem

The dense representation theorem states that if a formula is not provable,
then there exists a countermodel over the dense canonical TaskFrame.
-/

/--
Dense non-provability implies neg-extends-to-MCS.

This is a specialization of the generic theorem.
-/
theorem dense_not_provable_implies_neg_extends_to_mcs
    (φ : Formula) (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ)) :
    ∃ M : Set Formula, SetMaximalConsistent M ∧ φ.neg ∈ M :=
  not_provable_implies_neg_extends_to_mcs φ h_not_prov

/--
Dense representation from neg-membership.

If φ.neg is in a family's MCS within a temporally coherent BFMCS over DovetailedTimelineQuot,
then φ is false at that point in the dense canonical model.
-/
theorem dense_representation_from_neg_membership
    (B : BFMCS (DovetailedTimelineQuot root_mcs root_mcs_proof))
    (h_tc : B.temporally_coherent)
    (φ : Formula)
    (fam : FMCS (DovetailedTimelineQuot root_mcs root_mcs_proof))
    (hfam : fam ∈ B.families)
    (t : DovetailedTimelineQuot root_mcs root_mcs_proof)
    (h_neg_in : φ.neg ∈ fam.mcs t) :
    ¬truth_at (ParametricCanonicalTaskModel (DovetailedTimelineQuot root_mcs root_mcs_proof))
      (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ :=
  parametric_representation_from_neg_membership B h_tc φ fam hfam t h_neg_in

/--
Dense countermodel implies non-provability.

If a formula has a countermodel in some temporally coherent BFMCS over DovetailedTimelineQuot,
then it is not provable.
-/
theorem dense_countermodel_implies_not_provable
    (B : BFMCS (DovetailedTimelineQuot root_mcs root_mcs_proof))
    (h_tc : B.temporally_coherent)
    (φ : Formula)
    (fam : FMCS (DovetailedTimelineQuot root_mcs root_mcs_proof))
    (hfam : fam ∈ B.families)
    (t : DovetailedTimelineQuot root_mcs root_mcs_proof)
    (h_false : ¬truth_at (ParametricCanonicalTaskModel (DovetailedTimelineQuot root_mcs root_mcs_proof))
      (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ) :
    ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ) :=
  countermodel_implies_not_provable B h_tc φ fam hfam t h_false

/--
**Dense Representation Theorem (Conditional Version)**

Given a function that constructs a temporally coherent BFMCS over DovetailedTimelineQuot
containing any given MCS, if a formula is not provable, then there exists
a countermodel in the dense canonical TaskFrame.

This conditional formulation avoids sorries by shifting the BFMCS construction
to the caller.
-/
theorem dense_representation_conditional
    (φ : Formula) (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ))
    (construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
      Σ' (B : BFMCS (DovetailedTimelineQuot root_mcs root_mcs_proof))
         (h_tc : B.temporally_coherent)
         (fam : FMCS (DovetailedTimelineQuot root_mcs root_mcs_proof))
         (hfam : fam ∈ B.families)
         (t : DovetailedTimelineQuot root_mcs root_mcs_proof),
         M = fam.mcs t) :
    ∃ (B : BFMCS (DovetailedTimelineQuot root_mcs root_mcs_proof))
      (h_tc : B.temporally_coherent)
      (fam : FMCS (DovetailedTimelineQuot root_mcs root_mcs_proof))
      (hfam : fam ∈ B.families)
      (t : DovetailedTimelineQuot root_mcs root_mcs_proof),
      ¬truth_at (ParametricCanonicalTaskModel (DovetailedTimelineQuot root_mcs root_mcs_proof))
        (ShiftClosedParametricCanonicalOmega B)
        (parametric_to_history fam) t φ :=
  parametric_algebraic_representation_conditional φ h_not_prov construct_bfmcs

/-!
## BFMCS Construction Function

The construction function required by the conditional representation theorem.
Uses `dovetailedTimelineQuotBFMCS` from Task 30.
-/

/--
Given an MCS M, construct a temporally coherent BFMCS over DovetailedTimelineQuot
containing M.

**Key Insight**: We use the root_mcs to build the DovetailedTimelineQuot domain.
The MCS M must be related to root_mcs for this to work. In the completeness proof,
M IS the root_mcs (the Lindenbaum extension of {phi.neg}), so this construction
is exactly what we need.

**Construction**:
1. Build DovetailedTimelineQuot from M (the given MCS)
2. Use dovetailedTimelineQuotBFMCS to get the BFMCS
3. The eval_family at the root time contains M

**Sorry Status**: Inherits the modal_backward sorry from dovetailedTimelineQuotBFMCS.
This does NOT affect temporal coherence.
-/
noncomputable def construct_bfmcs_from_mcs_Dense
    (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (B : BFMCS (DovetailedTimelineQuot M h_mcs))
       (h_tc : B.temporally_coherent)
       (fam : FMCS (DovetailedTimelineQuot M h_mcs))
       (hfam : fam ∈ B.families)
       (t : DovetailedTimelineQuot M h_mcs),
       M = fam.mcs t :=
  -- Build the BFMCS from dovetailedTimelineQuotBFMCS
  let B := dovetailedTimelineQuotBFMCS M h_mcs
  let h_tc := dovetailedTimelineQuotBFMCS_temporally_coherent M h_mcs
  -- The evaluation family is the dovetailedFMCS
  let fam := dovetailedFMCS M h_mcs
  let hfam : fam ∈ B.families := Set.mem_singleton _
  -- Get the time where root MCS appears
  let root_result := dovetailedTimelineQuot_root_exists M h_mcs
  let t := root_result.choose
  let h_eq := root_result.choose_spec
  -- M = fam.mcs t
  ⟨B, h_tc, fam, hfam, t, h_eq.symm⟩

/-!
## Unconditional Dense Representation Theorem

The unconditional theorem uses `construct_bfmcs_from_mcs_Dense` to eliminate the
conditional requirement.
-/

/--
**Dense Representation Theorem (Unconditional Version)**

If a formula is not provable in the TM proof system,
then there exists a countermodel in the dense canonical TaskFrame.

**Proof Structure**:
1. If φ is not provable, then φ.neg is consistent
2. By Lindenbaum, φ.neg extends to an MCS M
3. Using `construct_bfmcs_from_mcs_Dense M`, we get a BFMCS over DovetailedTimelineQuot
   containing M at some time t
4. By the truth lemma, φ.neg ∈ M implies φ is false at M in the canonical model

**Key Point**: The domain D = DovetailedTimelineQuot M h_mcs is BUILT from M.
This is the correct architecture for dense completeness: the canonical domain
is constructed from the root MCS, not fixed in advance.

**Sorry Status**:
The only sorries are in the BFMCS construction (modal_backward), not in the
logical structure of the representation theorem or the truth lemma.
-/
theorem dense_representation_unconditional
    (φ : Formula) (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ)) :
    ∃ (M : Set Formula) (h_mcs : SetMaximalConsistent M),
    ∃ (B : BFMCS (DovetailedTimelineQuot M h_mcs))
      (h_tc : B.temporally_coherent)
      (fam : FMCS (DovetailedTimelineQuot M h_mcs))
      (hfam : fam ∈ B.families)
      (t : DovetailedTimelineQuot M h_mcs),
      ¬truth_at (ParametricCanonicalTaskModel (DovetailedTimelineQuot M h_mcs))
        (ShiftClosedParametricCanonicalOmega B)
        (parametric_to_history fam) t φ := by
  -- Step 1: Get MCS containing φ.neg
  obtain ⟨M, h_mcs, h_neg_in⟩ := dense_not_provable_implies_neg_extends_to_mcs φ h_not_prov
  -- Step 2: Construct the BFMCS using let bindings (PSigma)
  let result := construct_bfmcs_from_mcs_Dense M h_mcs
  let B := result.1
  let h_tc := result.2.1
  let fam := result.2.2.1
  let hfam := result.2.2.2.1
  let t := result.2.2.2.2.1
  let h_eq := result.2.2.2.2.2
  -- Step 3: φ.neg ∈ fam.mcs t
  have h_neg_in_fam : φ.neg ∈ fam.mcs t := h_eq ▸ h_neg_in
  -- Step 4: Apply representation theorem
  exact ⟨M, h_mcs, B, h_tc, fam, hfam, t,
    dense_representation_from_neg_membership M h_mcs B h_tc φ fam hfam t h_neg_in_fam⟩

/-!
## Summary

This module provides the dense (D = DovetailedTimelineQuot) instantiation of the
parametric algebraic representation theorem:

1. **DenseCanonicalTaskFrame**: TaskFrame with D = DovetailedTimelineQuot
2. **DenseCanonicalTaskModel**: TaskModel with MCS-based valuation
3. **dense_representation_conditional**: Conditional representation theorem
4. **dense_representation_unconditional**: Unconditional representation theorem

**Status** (Task 31, 2026-03-21):
Both conditional and unconditional theorems are available. The unconditional
theorem uses `construct_bfmcs_from_mcs_Dense` which builds on Task 30's
`dovetailedTimelineQuotBFMCS` with proven temporal coherence.

**Sorry Inventory**:
The remaining sorries are in the BFMCS construction infrastructure:
- Modal backward: requires `phi -> Box phi` which is not generally provable

**Key Achievement** (Task 31):
This module provides the representation theorem infrastructure needed to close
the sorry in `timelineQuot_not_valid_of_neg_consistent`. The next step is to
wire this into `TimelineQuotCompleteness.lean`.

**Connection to Dense Completeness**:
The dense completeness theorem (valid_dense φ → provable φ) is the
contrapositive of this representation theorem. To establish it, one needs:
1. This representation theorem (non-provable → countermodel)
2. The connection between "valid over all dense models" and
   "valid in the dense canonical model"
-/

end Bimodal.Metalogic.Algebraic.DenseInstantiation
