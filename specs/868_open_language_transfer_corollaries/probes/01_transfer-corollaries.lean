import FormalSystem

namespace Probe868

open FormalSystem
open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Expressiveness

/-! ### A. Decidability reduction, per-formula, explicit instance argument -/

def decidableOpenValidZTimeOfTr
    (hsep : SeparationOver TaskFrame.IsZTime) (φ : OpenFormula)
    (hdec : Decidable (PlusValidZTime (tr hsep φ))) :
    Decidable (OpenValidIn FrameClass.ZTime φ) :=
  letI := hdec
  decidable_of_iff (PlusValidZTime (tr hsep φ)) (openValidIn_ztime_iff_tr hsep φ).symm

/-! ### B. Uniform hypothesis: NONCOMPUTABLE, hence vacuous (see probe 02, `vacuousUniform`). -/

noncomputable def decidableOpenValidZTime
    (hsep : SeparationOver TaskFrame.IsZTime)
    (hdec : ∀ ψ : PlusFormula, Decidable (PlusValidZTime ψ))
    (φ : OpenFormula) : Decidable (OpenValidIn FrameClass.ZTime φ) :=
  letI := hdec (tr hsep φ)
  decidable_of_iff (PlusValidZTime (tr hsep φ)) (openValidIn_ztime_iff_tr hsep φ).symm

/-! ### C. Bool-level correctness row -/

theorem openValidIn_ztime_iff_decide
    (hsep : SeparationOver TaskFrame.IsZTime)
    (d : PlusFormula → Bool)
    (hd : ∀ ψ : PlusFormula, d ψ = true ↔ PlusValidZTime ψ)
    (φ : OpenFormula) :
    d (tr hsep φ) = true ↔ OpenValidIn FrameClass.ZTime φ :=
  (hd _).trans (openValidIn_ztime_iff_tr hsep φ).symm

/-! ### D. Completeness reduction, generic in the frame predicate and the L+ relation -/

theorem openComplete_of_plusComplete {P : TaskFrame → Prop} (hsep : SeparationOver P)
    (Der : PlusFormula → Prop)
    (hcomp : ∀ ψ : PlusFormula, PlusValidOnFrames (fun F => F.IsRegular ∧ P F) ψ → Der ψ)
    (φ : OpenFormula) (hv : OpenValidOnFrames (fun F => F.IsRegular ∧ P F) φ) :
    Der (tr hsep φ) :=
  hcomp _ ((openValidOnFrames_iff_tr hsep φ).mp hv)

/-! ### E. ZTime / RTime instantiations -/

theorem openComplete_ztime (hsep : SeparationOver TaskFrame.IsZTime)
    (Der : PlusFormula → Prop)
    (hcomp : ∀ ψ : PlusFormula, PlusValidIn FrameClass.ZTime ψ → Der ψ)
    (φ : OpenFormula) (hv : OpenValidIn FrameClass.ZTime φ) :
    Der (tr hsep φ) :=
  hcomp _ ((openValidIn_ztime_iff_tr hsep φ).mp hv)

theorem openComplete_rtime (hsep : SeparationOver TaskFrame.IsRTime)
    (Der : PlusFormula → Prop)
    (hcomp : ∀ ψ : PlusFormula, PlusValidIn FrameClass.RTime ψ → Der ψ)
    (φ : OpenFormula) (hv : OpenValidIn FrameClass.RTime φ) :
    Der (tr hsep φ) :=
  hcomp _ ((openValidIn_rtime_iff_tr hsep φ).mp hv)

/-! ### F. Instantiation at the real L+ derivability relation -/

theorem openComplete_ztime_plusDerivable (hsep : SeparationOver TaskFrame.IsZTime)
    (engine : ∀ ψ : PlusFormula, PlusValidIn FrameClass.ZTime ψ →
      PlusDerivable FrameClass.ZTime [] ψ)
    (φ : OpenFormula) (hv : OpenValidIn FrameClass.ZTime φ) :
    PlusDerivable FrameClass.ZTime [] (tr hsep φ) :=
  openComplete_ztime hsep _ engine φ hv

end Probe868
