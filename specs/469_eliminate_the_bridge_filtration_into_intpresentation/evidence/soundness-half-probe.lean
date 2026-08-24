import FormalSystem.Metalogic.Decidability.BiLasso.Check
import FormalSystem.Semantics.Validity

/-! Probe: the SOUNDNESS half of the decidability equivalence.
    A presentation satisfying `φ.neg` refutes `ValidDiscrete φ`. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

theorem not_validDiscrete_of_satAtState
    (P : IntPresentation) (w : Fin P.card) (φ : Formula)
    (h : SatAtState P w φ.neg) : ¬ ValidDiscrete φ := by
  obtain ⟨τ, hτ, t, -, htr⟩ := h
  intro hv
  exact htr (hv ℤ P.toTaskFrame P.toModel τ hτ t)

#print axioms not_validDiscrete_of_satAtState
