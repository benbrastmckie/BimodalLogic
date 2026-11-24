import FormalSystem.Metalogic.Decidability.RaySummary.LadderStepFrag

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

theorem dBack_add_dFwd_le_closure_card (φ : PlusFormula) :
    dBack φ + dFwd φ ≤ (plusSubformulaClosure φ).card := sorry


theorem paramsOk_two_depth_sum_le_Tc {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula)
    (Tc Tn P B : ℕ) (hp : ParamsOk step pend lab φ Tc Tn P B) :
    2 * (dBack φ + dFwd φ) ≤ Tc := sorry


theorem paramsOk_two_depth_sum_le_Tn {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula)
    (Tc Tn P B : ℕ) (hp : ParamsOk step pend lab φ Tc Tn P B) :
    2 * (dBack φ + dFwd φ) ≤ Tn := sorry


theorem Zrel_of_kappa_eq {Q : Type} {pend : Q → Bool} (a b Tc Tn P B : ℕ)
    (hTc : 2 * (a + b) ≤ Tc) (hTn : 2 * (a + b) ≤ Tn)
    (hBa : 2 * a ≤ B) (hBb : 2 * b + 2 ≤ B) (q : Q) (c n c' n' : ℕ)
    (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) :
    Zrel a b (⟨(q, c, n), h⟩ : LadderState Q pend) ⟨(q, c', n'), h'⟩ := sorry


theorem cellLE_zero_const_of_kappa_eq_stepFrag {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (hφ : StepFrag φ) (Tc Tn P B : ℕ) :
    CellLEZeroConstOfKappaEq step pend fwd bwd lab φ Tc Tn P B := sorry

