import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Step0

/-- The type-pigeonhole budget IS the cardinality of the certificate product carrier. -/
theorem card_prodState (Q : Type) [Fintype Q] (φ : PlusFormula) :
    Fintype.card (ProdState Q φ) = Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card := by
  classical
  show Fintype.card (Q × ClType φ) = _
  rw [Fintype.card_prod]
  congr 1
  rw [show Fintype.card (ClType φ) = ((plusSubformulaClosure φ).powerset).card from
    Fintype.card_coe _, Finset.card_powerset]

/-- **STEP 0, SETTLED.** `(K2)`'s cascade bound dominates the type-pigeonhole budget, with the
budget as its own EXPONENT. -/
theorem budget_le_cascadeBound {Q : Type} [Fintype Q] (pend : Q → Bool) (φ : PlusFormula) :
    Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1 ≤ cascadeBound pend φ := by
  classical
  rw [cascadeBound, ← card_prodState Q φ]
  have h1 : Fintype.card (ProdState Q φ) < 2 ^ Fintype.card (ProdState Q φ) :=
    Nat.lt_two_pow_self
  have h2 : 1 ≤ tIdle pend + 2 := by omega
  calc Fintype.card (ProdState Q φ) + 1
      ≤ 2 ^ Fintype.card (ProdState Q φ) := by omega
    _ ≤ 2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2) := Nat.le_mul_of_pos_right _ (by omega)

/-- **The budget is available at every `Tc` the parameter conditions admit**, through `(K2)` and
`cascadeBound` ALONE -- `satThreshold`, `satPeriod`, `prodPre_periodic`, `prodPreStep` and
`cohIdle` are not cited, no parameter is added and `ParamsOk` is not strengthened. -/
theorem budget_le_Tc {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1 ≤ Tc :=
  le_trans (budget_le_cascadeBound pend φ) hp.2.1.1

/-- **And therefore at the compared countdowns in the saturated regime**: the regime
`eq_or_both_ge_of_min_eq` puts the pumping case in, where both countdowns are at least `Tc`. -/
theorem budget_le_cnt {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) (c c' : ℕ)
    (hmin : min c Tc = min c' Tc) :
    c = c' ∨ (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1 ≤ c ∧
      Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1 ≤ c') := by
  rcases eq_or_both_ge_of_min_eq Tc c c' hmin with h | ⟨h1, h2⟩
  · exact Or.inl h
  · exact Or.inr ⟨le_trans (budget_le_Tc step pend lab φ Tc Tn P B hp) h1,
      le_trans (budget_le_Tc step pend lab φ Tc Tn P B hp) h2⟩

end Step0

#print axioms Step0.card_prodState
#print axioms Step0.budget_le_cascadeBound
#print axioms Step0.budget_le_Tc
#print axioms Step0.budget_le_cnt
