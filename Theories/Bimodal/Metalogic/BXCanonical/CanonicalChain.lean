import Bimodal.Metalogic.BXCanonical.Frame
import Bimodal.Metalogic.BXCanonical.Quasimodel.Construction
import Bimodal.Metalogic.BXCanonical.Filtration.DefectChain

/-!
# Canonical Chain Infrastructure

Provides MCS-level lemmas for BX axioms used in eventuality resolution,
and delegation bridges from Realization.lean to Frame.lean.

## Key BX Axiom Lemmas

- `psi_imp_until_mcs`: BX8 at MCS level (ψ → φ U ψ)
- `psi_imp_since_mcs`: BX8' at MCS level (ψ → φ S ψ)
- `F_imp_top_until_mcs`: BX12 at MCS level (F(ψ) → ⊤ U ψ)
- `left_mono_until_mcs`: BX2 at MCS level (G(φ → χ) → (φ U ψ → χ U ψ))

## Eventuality Resolution Status (Task 102, v5)

The Frame.lean eventuality resolution signatures have been weakened from
universal guard quantification over all BXPoints to chain-member guard
(φ ∈ w at the starting point). This resolved the unprovability issue
documented in earlier versions.

### Closed (2 of 4)
- `bx_until_eventuality_resolution`: Forward Until (proved via BX9 + BX10 + bx_forward_witness)
- `bx_since_eventuality_resolution`: Forward Since (proved via BX9' + BX10' + bx_backward_witness)

### Remaining (2 of 4)
- `bx_until_backward`: Backward Until (requires Until induction along chain)
- `bx_since_backward`: Backward Since (mirror)

### Why Backward is Hard

The backward direction takes φ ∈ w, ψ ∈ v (with bx_le w v), and needs
to derive φ U ψ ∈ w. This requires propagating the Until formula through
the bx_le ordering, but bx_le only propagates G-content (not arbitrary
formulas). The deterministic chain approach (DeterministicFMCS.lean) uses
`until_intro: X(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)` with backward induction,
but this requires a successor/next-time structure that the non-deterministic
canonical ordering lacks.

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

/-! ## BX8 at MCS level: ψ → φ U ψ -/

/-- BX8 at MCS level: if ψ ∈ w then (φ U ψ) ∈ w. -/
theorem psi_imp_until_mcs {w : BXPoint} {φ ψ : Formula}
    (h : ψ ∈ w.formulas) : Formula.untl φ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] (ψ.imp (Formula.untl φ ψ)) :=
    DerivationTree.axiom [] _ (Axiom.refl_intro_until φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- BX8' at MCS level: if ψ ∈ w then (φ S ψ) ∈ w. -/
theorem psi_imp_since_mcs {w : BXPoint} {φ ψ : Formula}
    (h : ψ ∈ w.formulas) : Formula.snce φ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] (ψ.imp (Formula.snce φ ψ)) :=
    DerivationTree.axiom [] _ (Axiom.refl_intro_since φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-! ## BX12 at MCS level: F(ψ) → ⊤ U ψ -/

/-- BX12 at MCS level: if F(ψ) ∈ w then (⊤ U ψ) ∈ w.
    Here ⊤ is encoded as ⊥ → ⊥ (i.e., Formula.bot.imp Formula.bot). -/
theorem F_imp_top_until_mcs {w : BXPoint} {ψ : Formula}
    (h : Formula.some_future ψ ∈ w.formulas) :
    Formula.untl (Formula.bot.imp Formula.bot) ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.some_future ψ).imp
    (Formula.untl (Formula.bot.imp Formula.bot) ψ)) :=
    DerivationTree.axiom [] _ (Axiom.F_until_equiv ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- BX12' at MCS level: if P(ψ) ∈ w then (⊤ S ψ) ∈ w. -/
theorem P_imp_top_since_mcs {w : BXPoint} {ψ : Formula}
    (h : Formula.some_past ψ ∈ w.formulas) :
    Formula.snce (Formula.bot.imp Formula.bot) ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.some_past ψ).imp
    (Formula.snce (Formula.bot.imp Formula.bot) ψ)) :=
    DerivationTree.axiom [] _ (Axiom.P_since_equiv ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-! ## BX2 at MCS level: left monotonicity of Until -/

/-- BX2 at MCS level: left monotonicity of Until.
    If G(φ → χ) ∈ w and (φ U ψ) ∈ w, then (χ U ψ) ∈ w. -/
theorem left_mono_until_mcs {w : BXPoint} {φ ψ χ : Formula}
    (h_G : Formula.all_future (φ.imp χ) ∈ w.formulas)
    (h_until : Formula.untl φ ψ ∈ w.formulas) :
    Formula.untl χ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.all_future (φ.imp χ)).imp
    ((Formula.untl φ ψ).imp (Formula.untl χ ψ))) :=
    DerivationTree.axiom [] _ (Axiom.left_mono_until φ ψ χ)
  have h1 := SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_G
  exact SetMaximalConsistent.implication_property w.is_mcs h1 h_until

/-- BX2' at MCS level: left monotonicity of Since. -/
theorem left_mono_since_mcs {w : BXPoint} {φ ψ χ : Formula}
    (h_H : Formula.all_past (φ.imp χ) ∈ w.formulas)
    (h_since : Formula.snce φ ψ ∈ w.formulas) :
    Formula.snce χ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.all_past (φ.imp χ)).imp
    ((Formula.snce φ ψ).imp (Formula.snce χ ψ))) :=
    DerivationTree.axiom [] _ (Axiom.left_mono_since φ ψ χ)
  have h1 := SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h_H
  exact SetMaximalConsistent.implication_property w.is_mcs h1 h_since

/-! ## BX6 at MCS level: absorption -/

/-- BX6 at MCS level: absorption of Until.
    If φ U (φ ∧ (φ U ψ)) ∈ w then φ U ψ ∈ w. -/
theorem absorb_until_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.untl φ (Formula.and φ (Formula.untl φ ψ)) ∈ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp
    (Formula.untl φ ψ)) :=
    DerivationTree.axiom [] _ (Axiom.absorb_until φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- BX6' at MCS level: absorption of Since. -/
theorem absorb_since_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.snce φ (Formula.and φ (Formula.snce φ ψ)) ∈ w.formulas) :
    Formula.snce φ ψ ∈ w.formulas := by
  have h_ax : DerivationTree [] ((Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp
    (Formula.snce φ ψ)) :=
    DerivationTree.axiom [] _ (Axiom.absorb_since φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-! ## Delegation: Realization.lean sorry closure

The Realization.lean functions delegate to the Frame.lean eventuality
resolution functions. These bridges match the weakened signatures
(chain-member guard instead of universal BXPoint guard). -/

/-- Delegation bridge: Realization.until_eventuality_resolution can call
    Frame.bx_until_eventuality_resolution. -/
theorem delegation_until_eventuality
    (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧ φ ∈ w.formulas :=
  bx_until_eventuality_resolution w φ ψ h_until h_not_psi

/-- Delegation bridge for backward Until. -/
theorem delegation_until_backward
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_wv : bx_le w v) (h_ψv : ψ ∈ v.formulas)
    (h_φw : φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas :=
  bx_until_backward w φ ψ v h_wv h_ψv h_φw h_not_psi

/-- Delegation bridge for Since eventuality. -/
theorem delegation_since_eventuality
    (w : BXPoint) (φ ψ : Formula)
    (h_since : Formula.snce φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas ∧ φ ∈ w.formulas :=
  bx_since_eventuality_resolution w φ ψ h_since h_not_psi

/-- Delegation bridge for backward Since. -/
theorem delegation_since_backward
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_vw : bx_le v w) (h_ψv : ψ ∈ v.formulas)
    (h_φw : φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.snce φ ψ ∈ w.formulas :=
  bx_since_backward w φ ψ v h_vw h_ψv h_φw h_not_psi

end Bimodal.Metalogic.BXCanonical
