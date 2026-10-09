import FormalSystem.Metalogic.Decidability.RaySummary.Realize
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth

/-! Scratch machine-check for task 747 research: every model realized by requirement (S)'s
construction `modelOf` lives on a finite-width `ofSlicedStep` frame, so by
`NoFiniteWidth.no_finite_width_sat` none of them satisfies the witness `Φ` anywhere -- while
`Φ.neg` IS a ℤ-time non-validity (`not_plusValidZTime_neg_Φ`). So the (S) construction, ranged
over ALL `Cons` presentations, cannot be the soundness half of a complete lift to validity for
`box`/`stab`-bearing L⁺. -/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

variable {Q : Type} [Fintype Q] [DecidableEq Q] [Nonempty Q]

/-- No model built by `modelOf` satisfies the finite-width witness `Φ` at any seam and time. -/
theorem modelOf_not_sat_Φ {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool}
    {step : Q → Q → Bool} (hC : Cons φ lab step)
    (τ : WorldHistory (frameOf hC).toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt (modelOf φ lab step hC) τ t NoFiniteWidth.Φ :=
  NoFiniteWidth.no_finite_width_sat (fun _ q q' => step q q' = true)
    (fun _ q => hC.serialFwd q) (fun _ q => hC.serialBwd q) (modelOf φ lab step hC) τ t

/-- Hence every `modelOf` model VALIDATES `Φ.neg` at every point, although `Φ.neg` is refuted on
some regular ℤ-model (`not_plusValidZTime_neg_Φ`): the constructed-model family misses a
ℤ-time non-validity. -/
theorem modelOf_sat_neg_Φ {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool}
    {step : Q → Q → Bool} (hC : Cons φ lab step)
    (τ : WorldHistory (frameOf hC).toTaskFrame) (t : ℤ) :
    PlusTruthAt (modelOf φ lab step hC) τ t NoFiniteWidth.Φ.neg :=
  (PlusTruth.neg_iff _ _ _ _).mpr (modelOf_not_sat_Φ hC τ t)

/-- The gap, stated as one sentence: `Φ.neg` is not ℤ-valid, yet no `Cons` presentation's
`modelOf` refutes it. -/
theorem modelOf_incomplete :
    ¬ PlusValidZTime NoFiniteWidth.Φ.neg ∧
      ∀ {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
        (hC : Cons φ lab step) (τ : WorldHistory (frameOf hC).toTaskFrame) (t : ℤ),
        PlusTruthAt (modelOf φ lab step hC) τ t NoFiniteWidth.Φ.neg :=
  ⟨NoFiniteWidth.not_plusValidZTime_neg_Φ, fun hC τ t => modelOf_sat_neg_Φ hC τ t⟩

end FormalSystem.Metalogic.Decidability.RaySummary

#print axioms FormalSystem.Metalogic.Decidability.RaySummary.modelOf_not_sat_Φ
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.modelOf_incomplete
