import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe735b

variable {F : FrameOver intOrder} [F.IsRegular] {Q : Type}

/-- Under `Presented`, `⊡φ` at the seam is a run-level condition on the presentation: every
anchored run carries `φ`'s letter at its `now` state. No `k`-type is evaluated. -/
theorem plusStab_iff_forall_run_of_presented (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool)
    (hP : Presented M τ t φ lab step) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ ρ : ℤ → Q, IsRun lab step (clNow φ) t ρ → lab (ρ t) (clPhi φ) = true := by
  rw [plusStab_iff_omega]
  constructor
  · intro h ρ hρ
    obtain ⟨bf, hc⟩ := (hP (runTrace lab ρ)).mpr ⟨ρ, hρ, rfl⟩
    have h2 : clTrace M φ t (spliced τ t bf) (clPhi φ) t := h bf
    rw [← hc] at h2
    exact h2
  · intro h bf
    obtain ⟨ρ, hρ, hc⟩ := (hP (clTrace M φ t (spliced τ t bf))).mp ⟨bf, rfl⟩
    have h2 : runTrace lab ρ (clPhi φ) t := h ρ hρ
    rw [← hc] at h2
    exact h2

#print axioms plusStab_iff_forall_run_of_presented

end Probe735b
