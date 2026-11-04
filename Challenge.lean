import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

def iterSpliceIdx (u : ℤ) (l : ℕ) : ℕ → ℤ → ℤ
  | 0, v => v
  | d + 1, v => iterSpliceIdx u l d (spliceIdx u l v)

theorem hasForwardSlack_raise {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) {u : ℤ} {l d : ℕ} (hul : u + (l : ℤ) ≤ z + (cntAt g z : ℤ))
    {L n : ℕ} (hslack : HasForwardSlack g z L n)
    (g' : ℤ → LadderState Q pend) (hg' : IsLadderPath step pend g')
    (hcz : cntAt g' z = cntAt g z + d * l)
    (habove : ∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v →
      objAt g' v = objAt g (v - (d * l : ℕ)) ∧ cntAt g' v = cntAt g (v - (d * l : ℕ))) :
    HasForwardSlack g' z (L + d * l) n := sorry


theorem exists_iterSpliced_ladderPath_idx_of_pend_past {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) {u : ℤ} {l : ℕ}
    (hl : 0 < l) (hcl : l ≤ cntAt g u)
    (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx u l d v)) ∧
      (∀ v : ℤ, v ≤ u → u ≤ v + (cntAt g v : ℤ) → cntAt g' v = cntAt g v + d * l) ∧
      (∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v → cntAt g' v = cntAt g (v - (d * l : ℕ))) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d w) := sorry


theorem exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) (z : ℤ) {u : ℤ} {l : ℕ}
    (hl : 0 < l) (hcl : l ≤ cntAt g u) (hzu : z ≤ u)
    (hul : u + (l : ℤ) ≤ z + (cntAt g z : ℤ))
    (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx u l d v)) ∧
      cntAt g' z = cntAt g z + d * l ∧
      nxtAt g' z = nxtAt g z ∧
      (∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v → cntAt g' v = cntAt g (v - (d * l : ℕ))) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d w) := sorry


theorem exists_ladderPath_through_deleted_exact_upfirst_of_pend_past
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
    (hgap : nxtAt g z + m * (P + 1) ≤ cntAt g z)
    (hslack : HasForwardSlack g z (m * (P + 1)) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := sorry


theorem mem_cellAt_of_shift_of_hasForwardSlack_exact
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ) (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n), h'⟩)
    (hslack : HasForwardSlack g z (m * (P + 1)) n)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

