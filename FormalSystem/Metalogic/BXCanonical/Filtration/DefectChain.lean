/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

-- SigmaOrdering archived to Boneyard/FiltrationOrdering/
import FormalSystem.Metalogic.BXCanonical.Frame
import FormalSystem.Metalogic.BXCanonical.Quasimodel.Construction

/-!
# Defect-Discharge Chain Construction

Defines the sigma defect count on BXPoints (counting Until-formulas in Sigma
whose goal is absent) and constructs defect-discharge chains via well-founded
recursion. The chain construction is the first step toward closing the
Until/Since sorries in Frame.lean.

## Main Definitions

- `sigmaDefectCount`: Number of Until-formulas in Sigma with unresolved goals
- `until_defect`: Predicate for a single Until defect

## Main Results

- `sigma_defect_count_bounded`: Defect count is bounded by Sigma.card
- `defect_step_F_psi`: φ U ψ ∈ w gives F(ψ) ∈ w (from BX10)
- `defect_step_self_accum`: φ U ψ ∈ w gives (φ ∧ (φ U ψ)) U ψ ∈ w (from BX5)

Note: `defect_step_phi` (BX9) and `since_defect_step_phi` (BX9') removed --
unsound under open guard.

## References

- Burgess 1984: One-step defect discharge
-/

namespace FormalSystem.Metalogic.BXCanonical.Filtration

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Metalogic.BXCanonical

/-! ## Until Defect Count -/

/-- Classical decidability of the Until-defect predicate, named rather than obtained from a
file-level `open Classical`: this is the only predicate in the file that needs it, and both
`sigmaDefectCount` and its bound must synthesise the *same* instance. -/
@[instance_reducible]
private noncomputable def untilDefectDecidable (w : BXPoint) :
    DecidablePred (fun f : Formula =>
      f ∈ w.formulas ∧ ∃ φ ψ : Formula, f = Formula.untl φ ψ ∧ ψ ∉ w.formulas) :=
  Classical.decPred _

/-- Classical decidability of the Since-defect predicate; mirror of `untilDefectDecidable`. -/
@[instance_reducible]
private noncomputable def sinceDefectDecidable (w : BXPoint) :
    DecidablePred (fun f : Formula =>
      f ∈ w.formulas ∧ ∃ φ ψ : Formula, f = Formula.snce φ ψ ∧ ψ ∉ w.formulas) :=
  Classical.decPred _

attribute [local instance] untilDefectDecidable sinceDefectDecidable

/-- A formula is an Until-defect at BXPoint w relative to Sigma if it is
    an Until formula in Sigma present at w whose goal (right operand) is absent. -/
def IsUntilDefect (w : BXPoint) (Sigma : Finset Formula) (f : Formula) : Prop :=
  f ∈ Sigma ∧ f ∈ w.formulas ∧
  ∃ φ ψ : Formula, f = Formula.untl φ ψ ∧ ψ ∉ w.formulas

/-- Count of Until-defects at w relative to Sigma. -/
noncomputable def sigmaDefectCount (w : BXPoint) (Sigma : Finset Formula) : Nat :=
  (Sigma.filter (fun f =>
    f ∈ w.formulas ∧
    ∃ φ ψ : Formula, f = Formula.untl φ ψ ∧ ψ ∉ w.formulas)).card

/-- The defect count is bounded by the size of Sigma. -/
theorem sigma_defect_count_bounded (w : BXPoint) (Sigma : Finset Formula) :
    sigmaDefectCount w Sigma ≤ Sigma.card := by
  unfold sigmaDefectCount
  exact Finset.card_filter_le Sigma _

/-! ## Defect Step Properties -/

/-- If φ U ψ ∈ w, then F(ψ) ∈ w (from BX10: eventuality extraction). -/
theorem defect_step_F_psi {w : BXPoint} {φ ψ : Formula}
    (h_until : Formula.untl φ ψ ∈ w.formulas) :
    Formula.someFuture ψ ∈ w.formulas := by
  have h_ax : DerivationTree FrameClass.Base [] _ := DerivationTree.axiom [] _ (Axiom.until_F φ ψ)
      trivial
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_until

/-- If φ U ψ ∈ w, then G(P(φ U ψ)) ∈ w (from BX4: temporal connectedness). -/
theorem defect_step_connect {w : BXPoint} {φ ψ : Formula}
    (h_until : Formula.untl φ ψ ∈ w.formulas) :
    Formula.allFuture (Formula.somePast (Formula.untl φ ψ)) ∈ w.formulas := by
  have h_ax : DerivationTree FrameClass.Base [] _ := DerivationTree.axiom [] _
      (Axiom.connect_future (Formula.untl φ ψ)) trivial
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_until

/-- If φ U ψ ∈ w, then (φ ∧ (φ U ψ)) U ψ ∈ w (from BX5: self-accumulation). -/
theorem defect_step_self_accum {w : BXPoint} {φ ψ : Formula}
    (h_until : Formula.untl φ ψ ∈ w.formulas) :
    Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ ∈ w.formulas := by
  have h_ax : DerivationTree FrameClass.Base [] _ := DerivationTree.axiom [] _
      (Axiom.self_accum_until φ ψ) trivial
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_until

/-! ## Since Defect Properties (Mirror) -/

/-- Count of Since-defects at w relative to Sigma. -/
noncomputable def sigmaSinceDefectCount (w : BXPoint) (Sigma : Finset Formula) : Nat :=
  (Sigma.filter (fun f =>
    f ∈ w.formulas ∧
    ∃ φ ψ : Formula, f = Formula.snce φ ψ ∧ ψ ∉ w.formulas)).card

/-- If φ S ψ ∈ w, then P(ψ) ∈ w (from BX10': eventuality extraction). -/
theorem since_defect_step_P_psi {w : BXPoint} {φ ψ : Formula}
    (h_since : Formula.snce φ ψ ∈ w.formulas) :
    Formula.somePast ψ ∈ w.formulas := by
  have h_ax : DerivationTree FrameClass.Base [] _ := DerivationTree.axiom [] _ (Axiom.since_P φ ψ)
      trivial
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_since

/-- If φ S ψ ∈ w, then H(F(φ S ψ)) ∈ w (from BX4': temporal connectedness). -/
theorem since_defect_step_connect {w : BXPoint} {φ ψ : Formula}
    (h_since : Formula.snce φ ψ ∈ w.formulas) :
    Formula.allPast (Formula.someFuture (Formula.snce φ ψ)) ∈ w.formulas := by
  have h_ax : DerivationTree FrameClass.Base [] _ := DerivationTree.axiom [] _
      (Axiom.connect_past (Formula.snce φ ψ)) trivial
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_since

end FormalSystem.Metalogic.BXCanonical.Filtration
