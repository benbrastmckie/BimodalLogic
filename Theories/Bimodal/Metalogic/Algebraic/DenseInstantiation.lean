import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Mathlib.Algebra.Order.Ring.Rat

/-!
# Dense Instantiation: D = Rat

This module instantiates the D-parametric algebraic representation theorem for the
dense case D = Rat (rational numbers).

## Main Results

- `DenseCanonicalTaskFrame`: The parametric canonical TaskFrame with D = Rat
- `DenseCanonicalTaskModel`: The parametric canonical TaskModel with D = Rat
- `dense_parametric_representation_conditional`: Representation theorem for Rat

## Rational Numbers as Duration Type

Rat satisfies all required typeclasses for the D-parametric construction:
- `AddCommGroup Rat`: Rat is an additive commutative group
- `LinearOrder Rat`: Rat has a total order
- `IsOrderedAddMonoid Rat`: Addition respects the order
- `DenselyOrdered Rat`: Between any two rationals, there's another

The dense ordering property is crucial for models of dense temporal logic.

## Note on BFMCS Construction

The full representation theorem for D = Rat requires constructing a temporally
coherent BFMCS over Rat. This construction is non-trivial and depends on:
1. The existence of F-witnesses (temporal forward coherence)
2. The existence of P-witnesses (temporal backward coherence)

For now, we provide the typeclass instantiation and the conditional representation
theorem. The BFMCS construction is left to future work or may use existing
infrastructure from the staged construction modules.

## References

- Research: specs/985_lindenbaum_tarski_representation_theorem/reports/research-002.md
- Plan: specs/985_lindenbaum_tarski_representation_theorem/plans/implementation-001.md
-/

namespace Bimodal.Metalogic.Algebraic.DenseInstantiation

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Metalogic.Algebraic.ParametricRepresentation
open Bimodal.Semantics

/-!
## Typeclass Verification

Verify that Rat satisfies all required typeclasses for the D-parametric construction.
-/

-- Rat is an ordered additive commutative group
example : AddCommGroup Rat := inferInstance
example : LinearOrder Rat := inferInstance
example : IsOrderedAddMonoid Rat := inferInstance
-- Note: DenselyOrdered Rat exists in mathlib but requires additional imports.
-- The key property is that between any two rationals there's another.

/-!
## Dense Canonical Structures

Instantiate the parametric canonical structures with D = Rat.
-/

/--
The dense canonical TaskFrame: the parametric canonical TaskFrame with D = Rat.

This TaskFrame has:
- WorldState = ParametricCanonicalWorldState (MCS-based world states)
- D = Rat (dense rational numbers)
- task_rel = parametric_canonical_task_rel (uses CanonicalR)

The frame satisfies all TaskFrame axioms (nullity_identity, forward_comp, converse)
by the parametric construction.
-/
abbrev DenseCanonicalTaskFrame : TaskFrame Rat :=
  ParametricCanonicalTaskFrame Rat

/--
The dense canonical TaskModel: the parametric canonical TaskModel with D = Rat.

Valuation is MCS membership: atom p is true at world M iff p ∈ M.
-/
abbrev DenseCanonicalTaskModel : TaskModel DenseCanonicalTaskFrame :=
  ParametricCanonicalTaskModel Rat

/-!
## Dense Representation Theorem

The dense representation theorem states that if a formula is not provable,
then there exists a countermodel over the dense canonical TaskFrame.
-/

/--
Dense non-provability implies neg-extends-to-MCS.

This is a specialization of the generic theorem for D = Rat.
-/
theorem dense_not_provable_implies_neg_extends_to_mcs
    (φ : Formula) (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ)) :
    ∃ M : Set Formula, SetMaximalConsistent M ∧ φ.neg ∈ M :=
  not_provable_implies_neg_extends_to_mcs φ h_not_prov

/--
Dense representation from neg-membership.

If φ.neg is in a family's MCS within a temporally coherent BFMCS over Rat,
then φ is false at that point in the dense canonical model.
-/
theorem dense_representation_from_neg_membership
    (B : BFMCS Rat) (h_tc : B.temporally_coherent)
    (φ : Formula)
    (fam : FMCS Rat) (hfam : fam ∈ B.families)
    (t : Rat) (h_neg_in : φ.neg ∈ fam.mcs t) :
    ¬truth_at DenseCanonicalTaskModel (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ :=
  parametric_representation_from_neg_membership B h_tc φ fam hfam t h_neg_in

/--
Dense countermodel implies non-provability.

If a formula has a countermodel in some temporally coherent BFMCS over Rat,
then it is not provable.
-/
theorem dense_countermodel_implies_not_provable
    (B : BFMCS Rat) (h_tc : B.temporally_coherent)
    (φ : Formula)
    (fam : FMCS Rat) (hfam : fam ∈ B.families) (t : Rat)
    (h_false : ¬truth_at DenseCanonicalTaskModel (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ) :
    ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ) :=
  countermodel_implies_not_provable B h_tc φ fam hfam t h_false

/--
**Dense Representation Theorem (Conditional Version)**

Given a function that constructs a temporally coherent BFMCS over Rat
containing any given MCS, if a formula is not provable, then there exists
a countermodel in the dense canonical TaskFrame.

This conditional formulation avoids sorries by shifting the BFMCS construction
to the caller.
-/
theorem dense_representation_conditional
    (φ : Formula) (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ))
    (construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
      Σ' (B : BFMCS Rat) (h_tc : B.temporally_coherent)
         (fam : FMCS Rat) (hfam : fam ∈ B.families) (t : Rat),
         M = fam.mcs t) :
    ∃ (B : BFMCS Rat) (h_tc : B.temporally_coherent)
      (fam : FMCS Rat) (hfam : fam ∈ B.families) (t : Rat),
      ¬truth_at DenseCanonicalTaskModel (ShiftClosedParametricCanonicalOmega B)
        (parametric_to_history fam) t φ :=
  parametric_algebraic_representation_conditional φ h_not_prov construct_bfmcs

/-!
## Summary

This module provides the dense (D = Rat) instantiation of the parametric
algebraic representation theorem:

1. **DenseCanonicalTaskFrame**: TaskFrame with D = Rat
2. **DenseCanonicalTaskModel**: TaskModel with MCS-based valuation
3. **dense_representation_conditional**: If φ is not provable and we can
   construct a BFMCS containing φ.neg, then φ has a countermodel

The construction is sorry-free. The full representation theorem
(without the `construct_bfmcs` assumption) requires building a temporally
coherent BFMCS over Rat that contains any given MCS. This construction
exists in the staged construction modules but is not wired here.

**Connection to Dense Completeness**:
The dense completeness theorem (valid_dense φ → provable φ) is the
contrapositive of this representation theorem. To establish it, one needs:
1. This representation theorem (non-provable → countermodel)
2. The connection between "valid over all dense models" and
   "valid in the dense canonical model"
-/

end Bimodal.Metalogic.Algebraic.DenseInstantiation
