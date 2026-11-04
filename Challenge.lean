import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

theorem hasForwardSlack_mono {Q : Type} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (z : ℤ) {l l' n : ℕ}
    (h : HasForwardSlack g z l n) (hle : l' ≤ l) : HasForwardSlack g z l' n := sorry


theorem hasForwardSlack_of_next_region_cnt_le {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z : ℤ) (l n : ℕ)
    (hnext : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      (cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) : ℤ) ≤ (n : ℤ) + cntAt g z + I - l) :
    HasForwardSlack g z l n := sorry


theorem hasForwardSlack_del {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) {a : ℤ} {l : ℕ} (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hza : z ≤ a) (hal : a + (l : ℤ) ≤ z + (cntAt g z : ℤ)) {L n : ℕ}
    (hslack : HasForwardSlack g z L n) (hlL : l ≤ L)
    (g' : ℤ → LadderState Q pend) (hg' : IsLadderPath step pend g')
    (hobj : ∀ v, objAt g' v = delObj g a l v) (hcnt : ∀ v, cntAt g' v = delCnt g a l v) :
    HasForwardSlack g' z (L - l) n := sorry


theorem budget_mul_succ_le_Tc {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
      (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) ≤ Tc := sorry


theorem exists_typeBlock_of_spacing {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hg : IsLadderPath step pend g) (z : ℤ) (hz : pend (objAt g z) = true)
    (w₀ : ℤ) (s : ℕ) (hzw : z ≤ w₀)
    (hroom : w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * s : ℕ) : ℤ)
      ≤ z + (cntAt g z : ℤ)) :
    ∃ (u : ℤ) (d : ℕ), 0 < d ∧
      d ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ∧
      w₀ ≤ u ∧
      u + ((d * s : ℕ) : ℤ)
        ≤ w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * s : ℕ) : ℤ) ∧
      d * s ≤ cntAt g u ∧
      objAt g u = objAt g (u + ((d * s : ℕ) : ℤ)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ u
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + ((d * s : ℕ) : ℤ)) := sorry


theorem exists_ladderPath_through_deleted_exact_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true) (m : ℕ)
    (hTc : Tc + m * (P + 1) ≤ cntAt g z)
    (hgap : nxtAt g z + m * (P + 1) +
      Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) ≤ cntAt g z)
    (hslack : HasForwardSlack g z
      (m * (P + 1) + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := sorry


theorem mem_cellAt_of_shift_of_hasForwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ) (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c)
    (hslk : n + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
      (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) ≤ c)
    (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n), h'⟩)
    (hslack : HasForwardSlack g z
      (m * (P + 1) + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)) n)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

