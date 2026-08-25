import FormalSystem.Metalogic.Decidability.BiLasso.Check
import FormalSystem.Semantics.Validity

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

theorem not_validDiscrete_of_satAtState
    (P : IntPresentation) (w : Fin P.card) (φ : Formula)
    (h : SatAtState P w φ.neg) : ¬ ValidDiscrete φ := by
  obtain ⟨τ, hτ, t, -, htr⟩ := h
  intro hv
  exact htr (hv ℤ P.toTaskFrame P.toModel τ hτ t)

theorem validDiscrete_iff_check
    (canon : Formula → IntPresentation)
    (fmp : ∀ ψ : Formula, ¬ ValidDiscrete ψ → ∃ w, SatAtState (canon ψ) w ψ.neg)
    (φ : Formula) :
    (∀ w : Fin (canon φ).card, check (canon φ) w φ.neg = false) ↔ ValidDiscrete φ := by
  constructor
  · intro hall
    by_contra hnv
    obtain ⟨w, hw⟩ := fmp φ hnv
    have : check (canon φ) w φ.neg = true := (check_correct _ _ _).mpr hw
    rw [hall w] at this
    exact Bool.false_ne_true this
  · intro hv w
    rcases Bool.eq_false_or_eq_true (check (canon φ) w φ.neg) with h | h
    · exact absurd hv (not_validDiscrete_of_satAtState _ w φ ((check_correct _ _ _).mp h))
    · exact h

def decidableValidDiscrete
    (canon : Formula → IntPresentation)
    (fmp : ∀ ψ : Formula, ¬ ValidDiscrete ψ → ∃ w, SatAtState (canon ψ) w ψ.neg)
    (φ : Formula) : Decidable (ValidDiscrete φ) :=
  decidable_of_iff _ (validDiscrete_iff_check canon fmp φ)

theorem validDiscrete_iff_checkFamily
    (cands : Formula → List IntPresentation)
    (fmp : ∀ ψ : Formula, ¬ ValidDiscrete ψ →
      ∃ P ∈ cands ψ, ∃ w : Fin P.card, SatAtState P w ψ.neg)
    (φ : Formula) :
    (∀ P ∈ cands φ, ∀ w : Fin P.card, check P w φ.neg = false) ↔ ValidDiscrete φ := by
  constructor
  · intro hall
    by_contra hnv
    obtain ⟨P, hP, w, hw⟩ := fmp φ hnv
    have h1 : check P w φ.neg = true := (check_correct _ _ _).mpr hw
    rw [hall P hP w] at h1
    exact Bool.false_ne_true h1
  · intro hv P _ w
    rcases Bool.eq_false_or_eq_true (check P w φ.neg) with h | h
    · exact absurd hv (not_validDiscrete_of_satAtState P w φ ((check_correct _ _ _).mp h))
    · exact h

def decidableValidDiscreteFamily
    (cands : Formula → List IntPresentation)
    (fmp : ∀ ψ : Formula, ¬ ValidDiscrete ψ →
      ∃ P ∈ cands ψ, ∃ w : Fin P.card, SatAtState P w ψ.neg)
    (φ : Formula) : Decidable (ValidDiscrete φ) :=
  decidable_of_iff _ (validDiscrete_iff_checkFamily cands fmp φ)

#print axioms not_validDiscrete_of_satAtState
#print axioms validDiscrete_iff_check
#print axioms decidableValidDiscrete
#print axioms validDiscrete_iff_checkFamily
#print axioms decidableValidDiscreteFamily

end FormalSystem.Metalogic.Decidability
