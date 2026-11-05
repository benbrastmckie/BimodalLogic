import FormalSystem

namespace Probe868B

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.PlusLanguage FormalSystem.OpenLanguage
open FormalSystem.ProofSystem FormalSystem.Metalogic.Expressiveness

/-! ### V. VACUITY DEMONSTRATION: the uniform Decidable form needs no hypothesis at all. -/

noncomputable def vacuousUniform (φ : OpenFormula) :
    Decidable (OpenValidIn FrameClass.ZTime φ) := Classical.dec _

/-! ### G. The GENERIC decidability reduction, translation as an explicit function. -/

def decidableOpenValidIn_of_translation (fc : FrameClass) (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (hdec : ∀ ψ : PlusFormula, Decidable (PlusValidIn fc ψ)) (φ : OpenFormula) :
    Decidable (OpenValidIn fc φ) :=
  letI := hdec (T φ)
  decidable_of_iff (PlusValidIn fc (T φ)) (hT φ).symm

/-! ### G'. Bool-level twin of the same reduction. -/

def openDecider (T : OpenFormula → PlusFormula) (d : PlusFormula → Bool) :
    OpenFormula → Bool := fun φ => d (T φ)

theorem openDecider_correct (fc : FrameClass) (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (d : PlusFormula → Bool) (hd : ∀ ψ : PlusFormula, d ψ = true ↔ PlusValidIn fc ψ)
    (φ : OpenFormula) : openDecider T d φ = true ↔ OpenValidIn fc φ :=
  (hd (T φ)).trans (hT φ).symm

/-! ### H. `tr hsep` inhabits the translation slot at ZTime / RTime -- existence only. -/

theorem exists_translation_ztime (hsep : SeparationOver TaskFrame.IsZTime) :
    ∃ T : OpenFormula → PlusFormula,
      ∀ φ : OpenFormula, OpenValidIn FrameClass.ZTime φ ↔ PlusValidIn FrameClass.ZTime (T φ) :=
  ⟨tr hsep, openValidIn_ztime_iff_tr hsep⟩

theorem exists_translation_rtime (hsep : SeparationOver TaskFrame.IsRTime) :
    ∃ T : OpenFormula → PlusFormula,
      ∀ φ : OpenFormula, OpenValidIn FrameClass.RTime φ ↔ PlusValidIn FrameClass.RTime (T φ) :=
  ⟨tr hsep, openValidIn_rtime_iff_tr hsep⟩

/-! ### I. Per-formula decidability reduction at RTime (computable). -/

def decidableOpenValidRTimeOfTr
    (hsep : SeparationOver TaskFrame.IsRTime) (φ : OpenFormula)
    (hdec : Decidable (PlusValidIn FrameClass.RTime (tr hsep φ))) :
    Decidable (OpenValidIn FrameClass.RTime φ) :=
  letI := hdec
  decidable_of_iff (PlusValidIn FrameClass.RTime (tr hsep φ))
    (openValidIn_rtime_iff_tr hsep φ).symm

/-! ### J. Completeness reduction, generic in fc and in the L+ relation. -/

theorem openComplete_of_plusComplete_in {fc : FrameClass} (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (Der : PlusFormula → Prop)
    (hcomp : ∀ ψ : PlusFormula, PlusValidIn fc ψ → Der ψ)
    (φ : OpenFormula) (hv : OpenValidIn fc φ) : Der (T φ) :=
  hcomp _ ((hT φ).mp hv)

/-! ### K. Named Props in the TMMinusComplete style. -/

def PlusComplete (fc : FrameClass) : Prop :=
  ∀ ψ : PlusFormula, PlusValidIn fc ψ → PlusDerivable fc [] ψ

def OpenCompleteViaTranslation (fc : FrameClass) (T : OpenFormula → PlusFormula) : Prop :=
  ∀ φ : OpenFormula, OpenValidIn fc φ → PlusDerivable fc [] (T φ)

theorem openCompleteViaTranslation_of_plusComplete {fc : FrameClass}
    (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (h : PlusComplete fc) : OpenCompleteViaTranslation fc T :=
  fun φ hv => h _ ((hT φ).mp hv)

/-! ### L. Soundness direction comes free from the same iff. -/

theorem openValid_of_plusSound {fc : FrameClass} (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (Der : PlusFormula → Prop)
    (hsound : ∀ ψ : PlusFormula, Der ψ → PlusValidIn fc ψ)
    (φ : OpenFormula) (hd : Der (T φ)) : OpenValidIn fc φ :=
  (hT φ).mpr (hsound _ hd)

#print axioms Probe868B.decidableOpenValidIn_of_translation
#print axioms Probe868B.openDecider
#print axioms Probe868B.openDecider_correct
#print axioms Probe868B.exists_translation_ztime
#print axioms Probe868B.exists_translation_rtime
#print axioms Probe868B.decidableOpenValidRTimeOfTr
#print axioms Probe868B.openComplete_of_plusComplete_in
#print axioms Probe868B.openCompleteViaTranslation_of_plusComplete
#print axioms Probe868B.openValid_of_plusSound

end Probe868B
