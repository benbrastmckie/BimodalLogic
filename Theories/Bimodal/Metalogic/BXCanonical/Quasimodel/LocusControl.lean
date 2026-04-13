import Bimodal.Metalogic.BXCanonical.Quasimodel.Realization

/-!
# Locus-Control Delegation Layer

Provides primed (`'`) variants of the Frame.lean eventuality resolution
functions, delegating through Realization.lean. These serve as the
interface for higher-level modules.

## Main Results

- `bx_until_eventuality_resolution'`: Forward Until (proved, delegates to Frame.lean)
- `bx_until_backward'`: Backward Until (sorry, delegates to Frame.lean)
- `bx_since_eventuality_resolution'`: Forward Since (proved, delegates to Frame.lean)
- `bx_since_backward'`: Backward Since (sorry, delegates to Frame.lean)

## References

- Burgess 1984: "Basic tense logic" (canonical model construction)
- Task 102 v5: Signature weakening to chain-member guard
-/

namespace Bimodal.Metalogic.BXCanonical.Quasimodel

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical

/-! ## Sorry-Closing Lemmas for Frame.lean -/

/-- Forward Until eventuality resolution (delegates to Realization.lean). -/
noncomputable def bx_until_eventuality_resolution'
    (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧ φ ∈ w.formulas :=
  until_eventuality_resolution w φ ψ h_until h_not_psi

/-- Backward Until (delegates to Realization.lean). -/
noncomputable def bx_until_backward'
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_wv : bx_le w v) (h_ψv : ψ ∈ v.formulas)
    (h_φw : φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas :=
  until_backward w φ ψ v h_wv h_ψv h_φw h_not_psi

/-- Forward Since eventuality resolution (delegates to Realization.lean). -/
noncomputable def bx_since_eventuality_resolution'
    (w : BXPoint) (φ ψ : Formula)
    (h_since : Formula.snce φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas ∧ φ ∈ w.formulas :=
  since_eventuality_resolution w φ ψ h_since h_not_psi

/-- Backward Since (delegates to Realization.lean). -/
noncomputable def bx_since_backward'
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_vw : bx_le v w) (h_ψv : ψ ∈ v.formulas)
    (h_φw : φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.snce φ ψ ∈ w.formulas :=
  since_backward w φ ψ v h_vw h_ψv h_φw h_not_psi

end Bimodal.Metalogic.BXCanonical.Quasimodel
