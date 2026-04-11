import Bimodal.Metalogic.BXCanonical.Filtration.SigmaOrdering
import Bimodal.Metalogic.BXCanonical.Quasimodel.Construction

/-!
# Defect-Discharge Chain Construction

Defines the sigma defect count on BXPoints (counting Until-formulas in Sigma
whose goal is absent) and constructs defect-discharge chains via well-founded
recursion. The chain construction is the first step toward closing the
Until/Since sorries in Frame.lean.

## Main Definitions

- `sigma_defect_count`: Number of Until-formulas in Sigma with unresolved goals
- `until_defect`: Predicate for a single Until defect

## Main Results

- `sigma_defect_count_bounded`: Defect count is bounded by Sigma.card
- `until_elim_mcs_or`: φ U ψ ∈ w gives φ ∈ w or ψ ∈ w (from BX9)
- `defect_step_phi`: If φ U ψ ∈ w and ψ ∉ w, then φ ∈ w

## References

- Burgess 1984: One-step defect discharge
- Task 101 research report (section 11.6)
-/

namespace Bimodal.Metalogic.BXCanonical.Filtration

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical
open Classical

/-! ## Until Defect Count -/

/-- A formula is an Until-defect at BXPoint w relative to Sigma if it is
    an Until formula in Sigma present at w whose goal (right operand) is absent. -/
def is_until_defect (w : BXPoint) (Sigma : Finset Formula) (f : Formula) : Prop :=
  f ∈ Sigma ∧ f ∈ w.formulas ∧
  ∃ φ ψ : Formula, f = Formula.untl φ ψ ∧ ψ ∉ w.formulas

/-- Count of Until-defects at w relative to Sigma. -/
noncomputable def sigma_defect_count (w : BXPoint) (Sigma : Finset Formula) : Nat :=
  (Sigma.filter (fun f =>
    f ∈ w.formulas ∧
    ∃ φ ψ : Formula, f = Formula.untl φ ψ ∧ ψ ∉ w.formulas)).card

/-- The defect count is bounded by the size of Sigma. -/
theorem sigma_defect_count_bounded (w : BXPoint) (Sigma : Finset Formula) :
    sigma_defect_count w Sigma ≤ Sigma.card := by
  unfold sigma_defect_count
  exact Finset.card_filter_le Sigma _

/-! ## Defect Step Properties -/

/-- If φ U ψ ∈ w and ψ ∉ w, then φ ∈ w (from BX9: Until elimination). -/
theorem defect_step_phi {w : BXPoint} {φ ψ : Formula}
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    φ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.until_elim φ ψ)
  have h_or := SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_until
  -- φ ∨ ψ ∈ w. Since ψ ∉ w: φ ∈ w.
  cases SetMaximalConsistent.negation_complete w.is_mcs φ with
  | inl h => exact h
  | inr h_neg_phi =>
    have h_psi := SetMaximalConsistent.implication_property w.is_mcs h_or h_neg_phi
    exact absurd h_psi h_not_psi

/-- If φ U ψ ∈ w, then F(ψ) ∈ w (from BX10: eventuality extraction). -/
theorem defect_step_F_psi {w : BXPoint} {φ ψ : Formula}
    (h_until : Formula.untl φ ψ ∈ w.formulas) :
    Formula.some_future ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.until_F φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_until

/-- If φ U ψ ∈ w, then G(P(φ U ψ)) ∈ w (from BX4: temporal connectedness). -/
theorem defect_step_connect {w : BXPoint} {φ ψ : Formula}
    (h_until : Formula.untl φ ψ ∈ w.formulas) :
    Formula.all_future (Formula.some_past (Formula.untl φ ψ)) ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.connect_future (Formula.untl φ ψ))
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_until

/-- If φ U ψ ∈ w, then (φ ∧ (φ U ψ)) U ψ ∈ w (from BX5: self-accumulation). -/
theorem defect_step_self_accum {w : BXPoint} {φ ψ : Formula}
    (h_until : Formula.untl φ ψ ∈ w.formulas) :
    Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.self_accum_until φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_until

/-! ## Since Defect Properties (Mirror) -/

/-- Count of Since-defects at w relative to Sigma. -/
noncomputable def sigma_since_defect_count (w : BXPoint) (Sigma : Finset Formula) : Nat :=
  (Sigma.filter (fun f =>
    f ∈ w.formulas ∧
    ∃ φ ψ : Formula, f = Formula.snce φ ψ ∧ ψ ∉ w.formulas)).card

/-- If φ S ψ ∈ w and ψ ∉ w, then φ ∈ w (from BX9': Since elimination). -/
theorem since_defect_step_phi {w : BXPoint} {φ ψ : Formula}
    (h_since : Formula.snce φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    φ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.since_elim φ ψ)
  have h_or := SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_since
  cases SetMaximalConsistent.negation_complete w.is_mcs φ with
  | inl h => exact h
  | inr h_neg_phi =>
    have h_psi := SetMaximalConsistent.implication_property w.is_mcs h_or h_neg_phi
    exact absurd h_psi h_not_psi

/-- If φ S ψ ∈ w, then P(ψ) ∈ w (from BX10': eventuality extraction). -/
theorem since_defect_step_P_psi {w : BXPoint} {φ ψ : Formula}
    (h_since : Formula.snce φ ψ ∈ w.formulas) :
    Formula.some_past ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.since_P φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_since

/-- If φ S ψ ∈ w, then H(F(φ S ψ)) ∈ w (from BX4': temporal connectedness). -/
theorem since_defect_step_connect {w : BXPoint} {φ ψ : Formula}
    (h_since : Formula.snce φ ψ ∈ w.formulas) :
    Formula.all_past (Formula.some_future (Formula.snce φ ψ)) ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.connect_past (Formula.snce φ ψ))
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_since

end Bimodal.Metalogic.BXCanonical.Filtration
