import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

/-! Standalone prototype (not a wired probe): the five helper statements the research report
recommends, each compiled via lean_run_code against the built library during research.
`hasForwardSlack_mono` and `hasForwardSlack_of_next_region_cnt_le` compiled in a first run
(no diagnostics on them); the other three in a second run (one unused-variable warning on `hs`,
which the wired version should drop). -/

namespace Probe849

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.RaySummary

section Slack

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- Monotone in the deleted amount: slack for a larger amount is slack for a smaller one. -/
theorem hasForwardSlack_mono (g : ℤ → LadderState Q pend) (z : ℤ) {l l' n : ℕ}
    (h : HasForwardSlack g z l n) (hle : l' ≤ l) : HasForwardSlack g z l' n := by
  intro I hI hidle hnext
  have := h I hI hidle hnext
  omega

/-- The regime with a finite witness: the countdown of the first region above `z`'s region is
at most `n + cntAt g z + I - l` -- in particular whenever it is at most `cntAt g z - l`. -/
theorem hasForwardSlack_of_next_region_cnt_le (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z : ℤ) (l n : ℕ)
    (hnext : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      (cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) : ℤ) ≤ (n : ℤ) + cntAt g z + I - l) :
    HasForwardSlack g z l n := by
  intro I hI hidle hnx
  have h0 := hidle (I - 1) (by omega)
  have hcast : z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ) = z + (cntAt g z : ℤ) + (I : ℤ) := by
    push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring
  rw [hcast] at h0
  have h1 : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnx
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg _ h0 h1
  have := hnext I hI hidle hnx
  rw [show z + (cntAt g z : ℤ) + 1 + (I : ℤ) = z + (cntAt g z : ℤ) + (I : ℤ) + 1 by ring, hpin]
    at this
  exact this

/-- **Forward slack transports across a deletion inside `z`'s region**, decreased by exactly
the deleted length: the first region start above the region keeps its countdown and moves `l`
closer. -/
theorem hasForwardSlack_del (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) {a : ℤ} {l : ℕ} (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hza : z ≤ a) (hal : a + (l : ℤ) ≤ z + (cntAt g z : ℤ)) {L n : ℕ}
    (hslack : HasForwardSlack g z L n) (hlL : l ≤ L)
    (g' : ℤ → LadderState Q pend) (hg' : IsLadderPath step pend g')
    (hobj : ∀ v, objAt g' v = delObj g a l v) (hcnt : ∀ v, cntAt g' v = delCnt g a l v) :
    HasForwardSlack g' z (L - l) n := by
  intro I hI hidle hnext
  have hcz : cntAt g' z = cntAt g z - l := by
    rw [hcnt z]; exact delCnt_sub_of_mem_region hg hl hcl z hza (by omega)
  have hczZ : (cntAt g' z : ℤ) = (cntAt g z : ℤ) - l := by rw [hcz]; omega
  have hpull : ∀ v : ℤ, a ≤ v → objAt g' v = objAt g (v + (l : ℤ)) := fun v hv => by
    rw [hobj v, delObj_of_ge v hv]
  have hidle' : ∀ i : ℕ, i < I →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false := by
    intro i hi
    have := hidle i hi
    rw [hczZ, hpull _ (by omega)] at this
    rwa [show z + ((cntAt g z : ℤ) - l) + 1 + (i : ℤ) + (l : ℤ)
        = z + (cntAt g z : ℤ) + 1 + (i : ℤ) by ring] at this
  have hnext' : pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true := by
    have := hnext
    rw [hczZ, hpull _ (by omega)] at this
    rwa [show z + ((cntAt g z : ℤ) - l) + 1 + (I : ℤ) + (l : ℤ)
        = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring] at this
  have hb := hslack I hI hidle' hnext'
  have h0' := hidle' (I - 1) (by omega)
  have h0 := hidle (I - 1) (by omega)
  have hcast : ∀ C : ℤ, C + 1 + ((I - 1 : ℕ) : ℤ) = C + (I : ℤ) := by
    intro C; push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring
  rw [hcast] at h0' h0
  have h1' : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnext'
  have h1 : pend (objAt g' (z + (cntAt g' z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g' z : ℤ) + (I : ℤ) + 1 = z + (cntAt g' z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnext
  have hpin' := cntAt_eq_nxtAt_of_idle_pend g hg _ h0' h1'
  have hpin := cntAt_eq_nxtAt_of_idle_pend g' hg' _ h0 h1
  have hreg : nxtAt g' (z + (cntAt g' z : ℤ) + (I : ℤ))
      = nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) := by
    rw [← hpin, ← hpin', hcnt, delCnt_of_ge _ (by omega), hczZ]
    congr 1; ring
  rw [hreg, hczZ]
  have hlLZ : ((L - l : ℕ) : ℤ) = (L : ℤ) - l := by omega
  rw [hlLZ]
  omega

end Slack

section Budget

/-- `(K2)` dominates `budget * (budget + 1)`. -/
theorem budget_mul_succ_le_Tc {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
      (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) ≤ Tc := by
  classical
  refine le_trans ?_ hp.2.1.1
  rw [cascadeBound, ← card_prodState Q φ]
  have h3 : 3 ≤ tIdle pend + 2 := by unfold tIdle; omega
  have key : ∀ b : ℕ, b * (b + 1) ≤ 2 ^ b * 3 := by
    intro b
    induction b with
    | zero => simp
    | succ k ih =>
        have hk : k < 2 ^ k := Nat.lt_two_pow_self
        rw [pow_succ]
        nlinarith
  calc Fintype.card (ProdState Q φ) * (Fintype.card (ProdState Q φ) + 1)
      ≤ 2 ^ Fintype.card (ProdState Q φ) * 3 := key _
    _ ≤ 2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2) := Nat.mul_le_mul_left _ h3

end Budget

section Spacing

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE SPACED TYPE PIGEONHOLE.** Among `budget + 1` samples at spacing `s` from `w₀`
inside `z`'s region, two share `(objAt, tpOf)`: a type-respecting block of length `d · s`
with `1 ≤ d ≤ budget`, lying in the sampling window. -/
theorem exists_typeBlock_of_spacing
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
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + ((d * s : ℕ) : ℤ)) := by
  classical
  set b := Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card with hb
  let f : Fin (b + 1) → Q × {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset} :=
    fun i => (objAt g (w₀ + (((i : ℕ) * s : ℕ) : ℤ)),
      ⟨tpOf (ladderModel step pend fwd bwd lab) φ σ (w₀ + (((i : ℕ) * s : ℕ) : ℤ)),
        Finset.mem_powerset.mpr (tpOf_subset _ φ σ _)⟩)
  obtain ⟨a, c, hac, hf⟩ := Fintype.exists_ne_map_eq_of_card_lt f (by
    rw [Fintype.card_prod, Fintype.card_coe, Finset.card_powerset, Fintype.card_fin]
    omega)
  have hf' : f a = f c := hf
  simp only [f, Prod.mk.injEq, Subtype.mk.injEq] at hf'
  obtain ⟨hobj, hty⟩ := hf'
  have ha : (a : ℕ) ≤ b := by omega
  have hc : (c : ℕ) ≤ b := by omega
  have hcnt : ∀ i : ℕ, i ≤ b → ∀ d : ℕ,
      w₀ + ((i * s : ℕ) : ℤ) + ((d * s : ℕ) : ℤ) ≤ z + (cntAt g z : ℤ) →
      d * s ≤ cntAt g (w₀ + ((i * s : ℕ) : ℤ)) := by
    intro i hi d hd
    have hle : (w₀ + ((i * s : ℕ) : ℤ) - z).toNat ≤ cntAt g z := by
      have : ((d * s : ℕ) : ℤ) ≥ 0 := Int.natCast_nonneg _
      omega
    have := (cntAt_sub_of_pend g hg z hz _ hle).2
    rw [show z + (((w₀ + ((i * s : ℕ) : ℤ) - z).toNat : ℕ) : ℤ) = w₀ + ((i * s : ℕ) : ℤ) by
      omega] at this
    omega
  rcases lt_or_gt_of_ne (fun h : (a : ℕ) = (c : ℕ) => hac (Fin.ext h)) with hlt | hlt
  · have hcast : w₀ + (((a : ℕ) * s : ℕ) : ℤ) + ((((c : ℕ) - (a : ℕ)) * s : ℕ) : ℤ)
        = w₀ + (((c : ℕ) * s : ℕ) : ℤ) := by
      push_cast [Nat.cast_sub (le_of_lt hlt)]; ring
    have hwin : w₀ + (((c : ℕ) * s : ℕ) : ℤ) ≤ w₀ + ((b * s : ℕ) : ℤ) := by
      have : (c : ℕ) * s ≤ b * s := Nat.mul_le_mul_right _ hc
      omega
    refine ⟨w₀ + (((a : ℕ) * s : ℕ) : ℤ), (c : ℕ) - (a : ℕ), by omega, by omega,
      by omega, by rw [hcast]; exact hwin, ?_, ?_, ?_⟩
    · exact hcnt (a : ℕ) ha _ (by rw [hcast]; omega)
    · rw [hcast]; exact hobj
    · rw [hcast]; exact hty
  · have hcast : w₀ + (((c : ℕ) * s : ℕ) : ℤ) + ((((a : ℕ) - (c : ℕ)) * s : ℕ) : ℤ)
        = w₀ + (((a : ℕ) * s : ℕ) : ℤ) := by
      push_cast [Nat.cast_sub (le_of_lt hlt)]; ring
    have hwin : w₀ + (((a : ℕ) * s : ℕ) : ℤ) ≤ w₀ + ((b * s : ℕ) : ℤ) := by
      have : (a : ℕ) * s ≤ b * s := Nat.mul_le_mul_right _ ha
      omega
    refine ⟨w₀ + (((c : ℕ) * s : ℕ) : ℤ), (a : ℕ) - (c : ℕ), by omega, by omega,
      by omega, by rw [hcast]; exact hwin, ?_, ?_, ?_⟩
    · exact hcnt (c : ℕ) hc _ (by rw [hcast]; omega)
    · rw [hcast]; exact hobj.symm
    · rw [hcast]; exact hty.symm

end Spacing

end Probe849
