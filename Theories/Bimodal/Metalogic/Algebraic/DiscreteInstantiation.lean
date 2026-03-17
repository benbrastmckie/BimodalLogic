import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Mathlib.Algebra.Order.Group.Int

/-!
# Discrete Instantiation: D = Int

This module instantiates the D-parametric algebraic representation theorem for the
discrete case D = Int (integers).

## Main Results

- `DiscreteCanonicalTaskFrame`: The parametric canonical TaskFrame with D = Int
- `DiscreteCanonicalTaskModel`: The parametric canonical TaskModel with D = Int
- `discrete_parametric_representation_conditional`: Representation theorem for Int

## Integers as Duration Type

Int satisfies all required typeclasses for the D-parametric construction:
- `AddCommGroup Int`: Int is an additive commutative group
- `LinearOrder Int`: Int has a total order
- `IsOrderedAddMonoid Int`: Addition respects the order

For discrete temporal logic, Int represents discrete time steps.

## Note on BFMCS Construction

The full representation theorem for D = Int requires constructing a temporally
coherent BFMCS over Int. This construction is non-trivial and depends on:
1. The existence of F-witnesses (temporal forward coherence)
2. The existence of P-witnesses (temporal backward coherence)

For now, we provide the typeclass instantiation and the conditional representation
theorem. The BFMCS construction is left to future work or may use existing
infrastructure from the staged construction modules.

## References

- Research: specs/985_lindenbaum_tarski_representation_theorem/reports/research-002.md
- Plan: specs/985_lindenbaum_tarski_representation_theorem/plans/implementation-001.md
-/

namespace Bimodal.Metalogic.Algebraic.DiscreteInstantiation

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

Verify that Int satisfies all required typeclasses for the D-parametric construction.
-/

-- Int is an ordered additive commutative group
example : AddCommGroup Int := inferInstance
example : LinearOrder Int := inferInstance
example : IsOrderedAddMonoid Int := inferInstance

/-!
## Discrete Canonical Structures

Instantiate the parametric canonical structures with D = Int.
-/

/--
The discrete canonical TaskFrame: the parametric canonical TaskFrame with D = Int.

This TaskFrame has:
- WorldState = ParametricCanonicalWorldState (MCS-based world states)
- D = Int (discrete integers)
- task_rel = parametric_canonical_task_rel (uses CanonicalR)

The frame satisfies all TaskFrame axioms (nullity_identity, forward_comp, converse)
by the parametric construction.
-/
abbrev DiscreteCanonicalTaskFrame : TaskFrame Int :=
  ParametricCanonicalTaskFrame Int

/--
The discrete canonical TaskModel: the parametric canonical TaskModel with D = Int.

Valuation is MCS membership: atom p is true at world M iff p ∈ M.
-/
abbrev DiscreteCanonicalTaskModel : TaskModel DiscreteCanonicalTaskFrame :=
  ParametricCanonicalTaskModel Int

/-!
## Discrete Representation Theorem

The discrete representation theorem states that if a formula is not provable,
then there exists a countermodel over the discrete canonical TaskFrame.
-/

/--
Discrete non-provability implies neg-extends-to-MCS.

This is a specialization of the generic theorem for D = Int.
-/
theorem discrete_not_provable_implies_neg_extends_to_mcs
    (φ : Formula) (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ)) :
    ∃ M : Set Formula, SetMaximalConsistent M ∧ φ.neg ∈ M :=
  not_provable_implies_neg_extends_to_mcs φ h_not_prov

/--
Discrete representation from neg-membership.

If φ.neg is in a family's MCS within a temporally coherent BFMCS over Int,
then φ is false at that point in the discrete canonical model.
-/
theorem discrete_representation_from_neg_membership
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (φ : Formula)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (h_neg_in : φ.neg ∈ fam.mcs t) :
    ¬truth_at DiscreteCanonicalTaskModel (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ :=
  parametric_representation_from_neg_membership B h_tc φ fam hfam t h_neg_in

/--
Discrete countermodel implies non-provability.

If a formula has a countermodel in some temporally coherent BFMCS over Int,
then it is not provable.
-/
theorem discrete_countermodel_implies_not_provable
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (φ : Formula)
    (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int)
    (h_false : ¬truth_at DiscreteCanonicalTaskModel (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ) :
    ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ) :=
  countermodel_implies_not_provable B h_tc φ fam hfam t h_false

/--
**Discrete Representation Theorem (Conditional Version)**

Given a function that constructs a temporally coherent BFMCS over Int
containing any given MCS, if a formula is not provable, then there exists
a countermodel in the discrete canonical TaskFrame.

This conditional formulation avoids sorries by shifting the BFMCS construction
to the caller.
-/
theorem discrete_representation_conditional
    (φ : Formula) (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ))
    (construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
      Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent)
         (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
         M = fam.mcs t) :
    ∃ (B : BFMCS Int) (h_tc : B.temporally_coherent)
      (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
      ¬truth_at DiscreteCanonicalTaskModel (ShiftClosedParametricCanonicalOmega B)
        (parametric_to_history fam) t φ :=
  parametric_algebraic_representation_conditional φ h_not_prov construct_bfmcs

/-!
## Summary

This module provides the discrete (D = Int) instantiation of the parametric
algebraic representation theorem:

1. **DiscreteCanonicalTaskFrame**: TaskFrame with D = Int
2. **DiscreteCanonicalTaskModel**: TaskModel with MCS-based valuation
3. **discrete_representation_conditional**: If φ is not provable and we can
   construct a BFMCS containing φ.neg, then φ has a countermodel

The construction is sorry-free. The full representation theorem
(without the `construct_bfmcs` assumption) requires building a temporally
coherent BFMCS over Int that contains any given MCS. This construction
exists in the staged construction modules but is not wired here.

**Connection to Discrete Completeness**:
The discrete completeness theorem (valid_discrete φ → provable φ) is the
contrapositive of this representation theorem. To establish it, one needs:
1. This representation theorem (non-provable → countermodel)
2. The connection between "valid over all discrete models" and
   "valid in the discrete canonical model"
-/

end Bimodal.Metalogic.Algebraic.DiscreteInstantiation
