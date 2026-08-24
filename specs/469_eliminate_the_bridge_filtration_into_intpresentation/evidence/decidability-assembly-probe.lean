import FormalSystem.Metalogic.Decidability.BiLasso.Check
import FormalSystem.Semantics.Validity

/-! Probe: the ASSEMBLY. Given a canonical presentation family and the FMP half as a
    hypothesis, `Decidable (ValidDiscrete φ)` follows -- computably, through `check`.
    No transfer lemma, no enumeration of presentations, no `Fin n`-from-`Finite`. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

theorem not_validDiscrete_of_satAtState
    (P : IntPresentation) (w : Fin P.card) (φ : Formula)
    (h : SatAtState P w φ.neg) : ¬ ValidDiscrete φ := by
  obtain ⟨τ, hτ, t, -, htr⟩ := h
  intro hv
  exact htr (hv ℤ P.toTaskFrame P.toModel τ hτ t)

/-- The assembly: `ValidDiscrete φ` is equivalent to `check` returning `false` at every state
of the canonical presentation for `φ`. -/
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

/-- The `Decidable` instance it licenses. -/
def decidableValidDiscrete
    (canon : Formula → IntPresentation)
    (fmp : ∀ ψ : Formula, ¬ ValidDiscrete ψ → ∃ w, SatAtState (canon ψ) w ψ.neg)
    (φ : Formula) : Decidable (ValidDiscrete φ) :=
  decidable_of_iff _ (validDiscrete_iff_check canon fmp φ)

#print axioms validDiscrete_iff_check
#print axioms decidableValidDiscrete
