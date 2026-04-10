import Bimodal.Metalogic.BXCanonical.Quasimodel.Realization

/-!
# Locus-Control Lemma and Sorry Closure

This module provides the locus-control lemma and the final sorry-closing proofs
for the Until/Since truth lemma in the BX canonical model.

## Main Results

- `bx_until_eventuality_resolution'`: Replacement for Frame.lean sorry at line 653
- `bx_until_backward'`: Replacement for Frame.lean sorry at line 675
- `bx_since_eventuality_resolution'`: Replacement for Frame.lean sorry at line 690
- `bx_since_backward'`: Replacement for Frame.lean sorry at line 704

## Mathematical Status

The four sorry targets require proving that the canonical ordering `bx_le`
(defined as `g_content ⊆`) behaves linearly on intervals between Until/Since
witnesses. The Burgess-Xu axiom system (BX1-BX11) captures this linearity
through BX7 (Until linearity) and BX11 (temporal linearity), but extracting
the proof at the MCS level requires either:

1. A direct proof of interval linearity from BX7/BX11, or
2. The full quasimodel construction (Hintikka points + defect discharge + realization)

Approach (2) is structurally complete in this module hierarchy but the
core realization lifting lemma (proving combined seed consistency at each
chain step) remains open.

## References

- Burgess 1984: "Basic tense logic" (canonical model construction)
- Reynolds 1996: Section 2 (quasimodel realization)
- Verbrugge 2007: "Completeness by Construction"
-/

namespace Bimodal.Metalogic.BXCanonical.Quasimodel

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical

/-! ## Sorry-Closing Lemmas for Frame.lean -/

/-- Replacement for Frame.lean:653 sorry.

    Forward Until eventuality resolution: given φ U ψ ∈ w and ψ ∉ w,
    construct v ≥ w with ψ ∈ v and the guard φ on [w, v) satisfied.

    This delegates to the quasimodel construction in Realization.lean. -/
noncomputable def bx_until_eventuality_resolution'
    (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
      ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas :=
  until_eventuality_resolution w φ ψ h_until h_not_psi

/-- Replacement for Frame.lean:675 sorry.

    Backward Until: given v ≥ w with ψ ∈ v and the guard φ on [w, v),
    derive φ U ψ ∈ w. -/
noncomputable def bx_until_backward'
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_wv : bx_le w v) (h_ψv : ψ ∈ v.formulas)
    (h_guard : ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas :=
  until_backward w φ ψ v h_wv h_ψv h_guard h_not_psi

/-- Replacement for Frame.lean:690 sorry.

    Forward Since eventuality resolution: mirror of Until for past direction. -/
noncomputable def bx_since_eventuality_resolution'
    (w : BXPoint) (φ ψ : Formula)
    (h_since : Formula.snce φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas ∧
      ∀ u : BXPoint, bx_le v u ∧ ¬bx_le u v → bx_le u w → φ ∈ u.formulas :=
  since_eventuality_resolution w φ ψ h_since h_not_psi

/-- Replacement for Frame.lean:704 sorry.

    Backward Since: mirror of backward Until for past direction. -/
noncomputable def bx_since_backward'
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_vw : bx_le v w) (h_ψv : ψ ∈ v.formulas)
    (h_guard : ∀ u : BXPoint, bx_le v u ∧ ¬bx_le u v → bx_le u w → φ ∈ u.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.snce φ ψ ∈ w.formulas :=
  since_backward w φ ψ v h_vw h_ψv h_guard h_not_psi

end Bimodal.Metalogic.BXCanonical.Quasimodel
