import FormalSystem.Metalogic.Decidability.RaySummary.Trace

/-! Scratch machine-check for task 747 research: at a `Presented` seam whose presentation marks
AT MOST ONE state with `now` (the `Cons.nowUnique` condition requirement (S) needed), every
closure formula is `⊡`-stable at the seam: `ψ → ⊡ψ` for all `ψ ∈ cl φ`. So the trace-level
realization hypothesis cannot witness any `⊡`-refutation of a closure formula at the seam
(e.g. `Fp → ⊡Fp`, refuted on model A and on `natFrame` by `refute_determined`). -/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Semantics

variable {F : FrameOver intOrder} [F.IsRegular] {Q : Type}

/-- Every history in the seam's fibre is a splice of some ray pair (the `⇐` half of
`plusStab_iff_omega`, extracted). -/
theorem exists_spliced_eq (τ σ : WorldHistory F.toTaskFrame) (t : ℤ)
    (hσ : τ.state t = σ.state t) : ∃ bf : SeqPair F (τ.state t), spliced τ t bf = σ := by
  let x : Presheaf.StabFibre F.toTaskFrame t (τ.state t) := ⟨σ, hσ.symm⟩
  refine ⟨(seamOmegaEquiv t (τ.state t)) x, ?_⟩
  show ((seamOmegaEquiv t (τ.state t)).symm ((seamOmegaEquiv t (τ.state t)) x)).1 = σ
  rw [(seamOmegaEquiv t (τ.state t)).symm_apply_apply]

/-- Under `Presented`, every history through the seam reads each closure letter at `t` off the
`now` state of some anchored run. -/
theorem presented_letter_at_seam (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
    (hP : Presented M τ t φ lab step) (σ : WorldHistory F.toTaskFrame)
    (hσ : τ.state t = σ.state t) :
    ∃ ρ : ℤ → Q, IsRun lab step (clNow φ) t ρ ∧
      ∀ {ψ : PlusFormula} (h : ψ ∈ plusSubformulaClosure φ),
        (PlusTruthAt M σ t ψ ↔ lab (ρ t) (clLetter φ h) = true) := by
  obtain ⟨bf, hbf⟩ := exists_spliced_eq τ σ t hσ
  obtain ⟨ρ, hρ, hc⟩ := (hP (clTrace M φ t σ)).mp ⟨bf, by rw [hbf]⟩
  refine ⟨ρ, hρ, fun {ψ} h => ?_⟩
  have := congrFun (congrFun hc (clLetter φ h)) t
  simp only [clTrace_letter, runTrace] at this
  exact Iff.of_eq this

/-- **The `⊡`-collapse at a `Presented` seam with a unique `now` state**: every closure formula
true at the seam is `⊡`-true there. -/
theorem stab_of_presented_nowUnique (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
    (hP : Presented M τ t φ lab step)
    (hU : ∀ q q' : Q, lab q (clNow φ) = true → lab q' (clNow φ) = true → q = q')
    {ψ : PlusFormula} (h : ψ ∈ plusSubformulaClosure φ) :
    PlusTruthAt M τ t ψ → PlusTruthAt M τ t (.stab ψ) := by
  intro hψ σ hσ
  obtain ⟨ρτ, hρτ, hτ⟩ := presented_letter_at_seam M τ t φ hP τ rfl
  obtain ⟨ρσ, hρσ, hσ'⟩ := presented_letter_at_seam M τ t φ hP σ hσ
  have hq : ρσ t = ρτ t := hU _ _ ((hρσ.2 t).mpr rfl) ((hρτ.2 t).mpr rfl)
  rw [hσ' h, hq, ← hτ h]
  exact hψ

/-- The same, as the biconditional `ψ ↔ ⊡ψ` at the seam. -/
theorem stab_iff_of_presented_nowUnique (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
    (hP : Presented M τ t φ lab step)
    (hU : ∀ q q' : Q, lab q (clNow φ) = true → lab q' (clNow φ) = true → q = q')
    {ψ : PlusFormula} (h : ψ ∈ plusSubformulaClosure φ) :
    PlusTruthAt M τ t ψ ↔ PlusTruthAt M τ t (.stab ψ) :=
  ⟨stab_of_presented_nowUnique M τ t φ hP hU h, fun hs => hs τ rfl⟩

end FormalSystem.Metalogic.Decidability.RaySummary

#print axioms FormalSystem.Metalogic.Decidability.RaySummary.stab_iff_of_presented_nowUnique
