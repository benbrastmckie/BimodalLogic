import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

/-- PROBE 5': the untlNeg trigger shape, recovered from `isApplicable`. -/
theorem probe_untlNeg_trigger {sf : SignedFormula}
    {fc : FormalSystem.ProofSystem.FrameClass}
    (hA : isApplicable TableauRule.untlNeg sf fc = true) :
    ∃ e g l, sf = ⟨Sign.neg, sf.formula, l⟩ ∧ asUntil? sf.formula = some (e, g) := by
  rcases sf with ⟨sign, φ, l⟩
  cases sign
  · simp only [isApplicable] at hA; simp at hA
  · rcases h : asUntil? φ with _ | ⟨e, g⟩
    · simp only [isApplicable, h] at hA; simp at hA
    · exact ⟨e, g, l, rfl, rfl⟩

end FormalSystem.Metalogic.Decidability
