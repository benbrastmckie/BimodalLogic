import Bimodal.Metalogic.BXCanonical.Frame
import Bimodal.Metalogic.BXCanonical.Quasimodel.Construction
import Bimodal.Metalogic.BXCanonical.Filtration.DefectChain

/-!
# Canonical Chain Infrastructure

Provides MCS-level lemmas for BX axioms used in eventuality resolution,
and delegation bridges from Realization.lean to Frame.lean.

## Key BX Axiom Lemmas

- `F_imp_top_until_mcs`: BX12 at MCS level (F(ψ) → ⊤ U ψ)

## Eventuality Resolution Status (Task 113 open guard refactor)

The Frame.lean forward eventuality resolution functions are proved:
- `bx_until_eventuality_resolution`: Forward Until (via BX10 + bx_forward_witness)
- `bx_since_eventuality_resolution`: Forward Since (via BX10' + bx_backward_witness)

Under open guard (task 113), the return types no longer claim φ ∈ w
(BX9/BX9' removed as unsound). The delegation bridges are updated to match.

## References

- Burgess 1984: "Basic tense logic" (until induction in original axiom system)
- Xu 1988: "Completeness for Until-Since on linear orders"
- Task 102 research reports (specs/102_*/reports/)
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical.Filtration

/-! ## BX12 at MCS level: F(ψ) → ⊤ U ψ -/

/-- BX12 at MCS level: if F(ψ) ∈ w then (⊤ U ψ) ∈ w.
    Here ⊤ is encoded as ⊥ → ⊥ (i.e., Formula.bot.imp Formula.bot). -/
theorem F_imp_top_until_mcs {w : BXPoint} {ψ : Formula}
    (h : Formula.some_future ψ ∈ w.formulas) :
    Formula.untl ψ (Formula.bot.imp Formula.bot) ∈ w.formulas := by
  have h_ax : DerivationTree FrameClass.Base [] ((Formula.some_future ψ).imp
    (Formula.untl ψ (Formula.bot.imp Formula.bot))) :=
    DerivationTree.axiom [] _ (Axiom.F_until_equiv ψ) trivial
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- BX12' at MCS level: if P(ψ) ∈ w then (⊤ S ψ) ∈ w. -/
theorem P_imp_top_since_mcs {w : BXPoint} {ψ : Formula}
    (h : Formula.some_past ψ ∈ w.formulas) :
    Formula.snce ψ (Formula.bot.imp Formula.bot) ∈ w.formulas := by
  have h_ax : DerivationTree FrameClass.Base [] ((Formula.some_past ψ).imp
    (Formula.snce ψ (Formula.bot.imp Formula.bot))) :=
    DerivationTree.axiom [] _ (Axiom.P_since_equiv ψ) trivial
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-! ## BX6 at MCS level: absorption -/

/-- BX6 at MCS level: absorption of Until.
    If φ U (φ ∧ (φ U ψ)) ∈ w then φ U ψ ∈ w. -/
theorem absorb_until_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.untl (Formula.and φ (Formula.untl ψ φ)) φ ∈ w.formulas) :
    Formula.untl ψ φ ∈ w.formulas := by
  have h_ax : DerivationTree FrameClass.Base [] ((Formula.untl (Formula.and φ (Formula.untl ψ φ)) φ).imp
    (Formula.untl ψ φ)) :=
    DerivationTree.axiom [] _ (Axiom.absorb_until φ ψ) trivial
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- BX6' at MCS level: absorption of Since. -/
theorem absorb_since_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.snce (Formula.and φ (Formula.snce ψ φ)) φ ∈ w.formulas) :
    Formula.snce ψ φ ∈ w.formulas := by
  have h_ax : DerivationTree FrameClass.Base [] ((Formula.snce (Formula.and φ (Formula.snce ψ φ)) φ).imp
    (Formula.snce ψ φ)) :=
    DerivationTree.axiom [] _ (Axiom.absorb_since φ ψ) trivial
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-! ## Delegation: Realization.lean sorry closure

The Realization.lean functions delegate to the Frame.lean eventuality
resolution functions. These bridges match the weakened signatures
(chain-member guard instead of universal BXPoint guard). -/

/-- Delegation bridge: Realization.until_eventuality_resolution can call
    Frame.bx_until_eventuality_resolution.
    Under open guard (task 113), return type no longer claims φ ∈ w. -/
theorem delegation_until_eventuality
    (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl ψ φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas :=
  bx_until_eventuality_resolution w φ ψ h_until h_not_psi

/-- Delegation bridge for Since eventuality.
    Under open guard (task 113), return type no longer claims φ ∈ w. -/
theorem delegation_since_eventuality
    (w : BXPoint) (φ ψ : Formula)
    (h_since : Formula.snce ψ φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas :=
  bx_since_eventuality_resolution w φ ψ h_since h_not_psi

end Bimodal.Metalogic.BXCanonical
