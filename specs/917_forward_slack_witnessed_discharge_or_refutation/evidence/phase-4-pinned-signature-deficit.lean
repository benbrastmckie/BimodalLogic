import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

set_option autoImplicit false
set_option linter.unusedVariables false

namespace FormalSystem.Metalogic.Decidability.RaySummary

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

theorem probe_low {g : ℤ → LadderState Q pend} {a : ℤ} {l : ℕ}
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hrep : objAt g a = objAt g (a + (l : ℤ)))
    (s : ℤ) (hsa : s < a) (hs0 : pend (delObj g a l s) = false)
    (hs1 : pend (delObj g a l (s + 1)) = true) :
    pend (objAt g s) = false ∧ pend (objAt g (s + 1)) = true ∧
      (((delCnt g a l (s + 1) : ℤ) = (cntAt g (s + 1) : ℤ) - l ∧
          (cntAt g (s + 1) : ℤ) = (cntAt g a : ℤ) + (a - (s + 1)))
        ∨ ((delCnt g a l (s + 1) : ℤ) = (cntAt g (s + 1) : ℤ) ∧
            s + 1 + (cntAt g (s + 1) : ℤ) < a)) := by
  have hpa : pend (objAt g a) = true := pend_of_del hg hl hcl
  rw [delObj_eq_of_le hrep s (by omega)] at hs0
  rw [delObj_eq_of_le hrep (s + 1) (by omega)] at hs1
  refine ⟨hs0, hs1, ?_⟩
  rcases lt_or_eq_of_le (show s + 1 ≤ a by omega) with hlt | heq
  · rw [delCnt_of_lt (s + 1) hlt]
    by_cases hc : a ≤ s + 1 + (cntAt g (s + 1) : ℤ)
    · rw [if_pos hc]
      have hge := cntAt_ge_of_reaches hg (s + 1) (by omega) hs1 hc
      exact Or.inl ⟨by omega, by omega⟩
    · rw [if_neg hc]
      exact Or.inr ⟨rfl, by omega⟩
  · rw [heq, delCnt_of_ge a le_rfl]
    have hseg := (delSeg hg hpa hcl (a + (l : ℤ)) (by omega) le_rfl).2
    rw [← heq] at hseg ⊢
    exact Or.inl ⟨by omega, by omega⟩

theorem probe_high {g : ℤ → LadderState Q pend} {a : ℤ} {l : ℕ}
    (s : ℤ) (hsa : a ≤ s) (hs0 : pend (delObj g a l s) = false)
    (hs1 : pend (delObj g a l (s + 1)) = true) :
    pend (objAt g (s + (l : ℤ))) = false ∧ pend (objAt g (s + (l : ℤ) + 1)) = true ∧
      delCnt g a l (s + 1) = cntAt g (s + (l : ℤ) + 1) := by
  rw [delObj_of_ge s (by omega)] at hs0
  rw [delObj_of_ge (s + 1) (by omega),
    show s + 1 + (l : ℤ) = s + (l : ℤ) + 1 by ring] at hs1
  refine ⟨hs0, hs1, ?_⟩
  rw [delCnt_of_ge (s + 1) (by omega), show s + 1 + (l : ℤ) = s + (l : ℤ) + 1 by ring]

/-- The pinned Phase-4 statement PLUS the one extra hypothesis `hnz`. -/
theorem probe_main_with_gap {g : ℤ → LadderState Q pend} {z a : ℤ} {l : ℕ}
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hza : z + (cntAt g z : ℤ) + 1 ≤ a)
    (hnz : (nxtAt g z : ℤ) ≤ (cntAt g z : ℤ))
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hrep : objAt g a = objAt g (a + (l : ℤ)))
    (hanch : ∀ v : ℤ, a ≤ v → pend (delObj g a l v) = false →
      pend (delObj g a l (v + 1)) = true →
      ((delCnt g a l (v + 1) : ℤ) - (nxtAt g z : ℤ)).natAbs ≤ (v - z).natAbs)
    (hstraddle : ∀ s v : ℤ, s < a → a ≤ v →
      pend (delObj g a l s) = false → pend (delObj g a l (s + 1)) = true →
      pend (delObj g a l v) = false → pend (delObj g a l (v + 1)) = true →
      ((delCnt g a l (s + 1) : ℤ) - (delCnt g a l (v + 1) : ℤ)).natAbs
        ≤ (s - v).natAbs) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v, objAt g' v = delObj g a l v) ∧ (∀ v, cntAt g' v = delCnt g a l v) ∧
      nxtAt g' z = nxtAt g z := by
  have habove : ∀ s : ℤ, pend (delObj g a l s) = false → z < s := by
    intro s hs
    by_contra hle
    rw [not_lt] at hle
    rw [delObj_eq_of_le hrep s (by omega)] at hs
    exact Bool.false_ne_true (hs.symm.trans (hpast s (by omega)))
  refine exists_ladderPath_of_walk_nxt_at (delObj g a l) (delCnt g a l) z (nxtAt g z)
    (delObj_step hg hrep) (delCnt_idle hg) (delCnt_pend_pend hg hl hcl)
    (delCnt_pend_idle hg hl hcl) (fun s v hs0 hs1 hv0 hv1 => ?_) (fun v hv0 hv1 => ?_)
  · rcases lt_or_ge s a with hs | hs
    · rcases lt_or_ge v a with hv | hv
      · obtain ⟨hs0', hs1', hsc⟩ := probe_low hg hl hcl hrep s hs hs0 hs1
        obtain ⟨hv0', hv1', hvc⟩ := probe_low hg hl hcl hrep v hv hv0 hv1
        have hpc := pinCompat_of_ladderPath g hg (s + 1 - 1) (v + 1 - 1)
          (by simpa using hs0') (by simpa using hs1') (by simpa using hv0')
          (by simpa using hv1')
        simp only [sub_add_cancel] at hpc
        rcases hsc with ⟨hse, hsr⟩ | ⟨hse, hsr⟩
        · rcases hvc with ⟨hve, hvr⟩ | ⟨hve, hvr⟩
          · omega
          · -- `s`'s region swallows the block, `v`'s does not, so `v ≤ s`
            have hvs : v ≤ s := by
              by_contra hgt
              rw [not_le] at hgt
              have := (cntAt_sub_of_pend g hg (s + 1) hs1' (v - (s + 1)).toNat (by omega)).1
              rw [show s + 1 + (((v - (s + 1)).toNat : ℕ) : ℤ) = v by omega] at this
              exact Bool.false_ne_true (hv0'.symm.trans this)
            omega
        · rcases hvc with ⟨hve, hvr⟩ | ⟨hve, hvr⟩
          · have hsv : s ≤ v := by
              by_contra hgt
              rw [not_le] at hgt
              have := (cntAt_sub_of_pend g hg (v + 1) hv1' (s - (v + 1)).toNat (by omega)).1
              rw [show v + 1 + (((s - (v + 1)).toNat : ℕ) : ℤ) = s by omega] at this
              exact Bool.false_ne_true (hs0'.symm.trans this)
            omega
          · omega
      · exact hstraddle s v hs hv hs0 hs1 hv0 hv1
    · rcases lt_or_ge v a with hv | hv
      · have := hstraddle v s hv hs hv0 hv1 hs0 hs1
        omega
      · obtain ⟨hs0', hs1', hsc⟩ := probe_high s hs hs0 hs1
        obtain ⟨hv0', hv1', hvc⟩ := probe_high v hv hv0 hv1
        rw [hsc, hvc]
        have hpc := pinCompat_of_ladderPath g hg (s + (l : ℤ)) (v + (l : ℤ))
          hs0' hs1' hv0' hv1'
        rw [show s + (l : ℤ) - (v + (l : ℤ)) = s - v by ring] at hpc
        exact hpc
  · rcases lt_or_ge v a with hv | hv
    · obtain ⟨hv0', hv1', hvc⟩ := probe_low hg hl hcl hrep v hv hv0 hv1
      have hzv : z < v := habove v hv0
      have hpin := cntAt_eq_nxtAt_of_idle_pend g hg v hv0' hv1'
      have hlip := nxtAt_lipschitz_two_sided g hg v z
      rcases hvc with ⟨hve, hvr⟩ | ⟨hve, hvr⟩
      · omega
      · omega
    · exact hanch v hv hv0 hv1

end FormalSystem.Metalogic.Decidability.RaySummary
