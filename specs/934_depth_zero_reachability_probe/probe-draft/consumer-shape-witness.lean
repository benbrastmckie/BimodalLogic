/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell

namespace FormalSystem.Metalogic.Decidability.RaySummary
namespace Probe934

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open ClimbWitness (pendT plateau plateauRaw)
open IdleRunOne

/-- The state `(true, C, 0)`. -/
def hiState (C : ℕ) : LadderState Bool pendT := ⟨(true, C, 0), by intro h; simp [pendT] at h⟩

theorem plateau_at_zero (C : ℕ) : plateau C 0 = hiState C := by
  apply Subtype.ext
  change plateauRaw C 0 = ((true, C, 0) : Bool × ℕ × ℕ)
  unfold plateauRaw
  rw [if_pos (by omega)]
  simp

/-- FSW at every amount `l ≤ C + 1` at `(true, C, 0)`. -/
theorem fsw_hiState (C l : ℕ) (hl : l ≤ C + 1) :
    ForwardSlackWitnessed stepOr pendT fwdOr bwdOr labB PlusFormula.bot (hiState C) 0 l 0 := by
  intro T hT
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdOr bwdOr (plateau C)
    (plateau_isLadderPath_stepOr C)
  have hTe : T = ∅ := by
    obtain ⟨σ, -, hty⟩ := hT
    rw [← hty, tpOf_bot_eq_empty]
  refine ⟨plateau C, τ, plateau_isLadderPath_stepOr C, plateau_at_zero C, hτ, ?_, ?_⟩
  · exact ClimbWitness.hasForwardSlack_plateau C l hl
  · rw [hTe, tpOf_bot_eq_empty]

/-- THE CONSUMER SHAPE: for every modulus and displacement. -/
theorem fsw_consumer_shape (c m P : ℕ) :
    ForwardSlackWitnessed stepOr pendT fwdOr bwdOr labB PlusFormula.bot
      (hiState (c + m * (P + 1))) 0 (m * (P + 1)) 0 :=
  fsw_hiState _ _ (by omega)

/-- The slack premise is NOT vacuous on the witness path: a genuine next region at `I = 1`. -/
theorem plateau_next_region (C : ℕ) :
    pendT (objAt (plateau C) (0 + (cntAt (plateau C) 0 : ℤ) + 1 + ((0 : ℕ) : ℤ))) = false ∧
    pendT (objAt (plateau C) (0 + (cntAt (plateau C) 0 : ℤ) + 1 + ((1 : ℕ) : ℤ))) = true := by
  rw [ClimbWitness.plateau_cnt_zero]
  constructor
  · change (plateauRaw C _).1 = false
    unfold plateauRaw
    rw [if_neg (by push_cast; omega), if_pos (by push_cast; omega)]
  · change (plateauRaw C _).1 = true
    unfold plateauRaw
    rw [if_neg (by push_cast; omega), if_neg (by push_cast; omega)]

theorem no_stab_bot : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure PlusFormula.bot := by
  intro χ
  unfold plusSubformulaClosure PlusFormula.subformulas
  simp

/-- The whole hypothesis set of the restricted schema is jointly satisfiable at a positive amount,
at the periodicity fixpoint's own parameters, and the schema then fires. -/
theorem consumer_fires :
    ∃ (Tc Tn P B c m : ℕ) (h : c ∈ Adm pendT true) (h' : c + m * (P + 1) ∈ Adm pendT true),
      ParamsOk stepOr pendT labB PlusFormula.bot Tc Tn P B ∧
      0 < m * (P + 1) ∧ 0 + 2 ≤ c ∧ Tc ≤ c ∧
      kappa Tc Tn P B (c, 0) = kappa Tc Tn P B (c + m * (P + 1), 0) ∧
      ForwardSlackWitnessed stepOr pendT fwdOr bwdOr labB PlusFormula.bot
        (⟨(true, c + m * (P + 1), 0), h'⟩ : LadderState Bool pendT) 0 (m * (P + 1)) 0 ∧
      cellAt (ladderModel stepOr pendT fwdOr bwdOr labB) PlusFormula.bot
          ((0, ⟨(true, c, 0), h⟩) : (ladderFrameAdm stepOr pendT fwdOr bwdOr).WorldState) 0
        = cellAt (ladderModel stepOr pendT fwdOr bwdOr labB) PlusFormula.bot
            ((0, ⟨(true, c + m * (P + 1), 0), h'⟩) :
              (ladderFrameAdm stepOr pendT fwdOr bwdOr).WorldState) 0 := by
  set Tc := Tcof stepOr pendT labB PlusFormula.bot
  set Tn := Tnof stepOr pendT labB PlusFormula.bot
  set P := Pof stepOr pendT labB PlusFormula.bot
  set B := Bof stepOr pendT labB PlusFormula.bot
  have hp : ParamsOk stepOr pendT labB PlusFormula.bot Tc Tn P B := paramsOk_params _ _ _ _
  set c := Tc + B + 2 with hc
  have hadm : ∀ C : ℕ, C ∈ Adm pendT true := fun C h => by simp [pendT] at h
  have hk : kappa Tc Tn P B (c, 0) = kappa Tc Tn P B (c + 1 * (P + 1), 0) := by
    simp only [kappa, Prod.mk.injEq, Fin.mk.injEq]
    refine ⟨by omega, by simp, trivial, trivial, ?_⟩
    unfold clipIdx
    split <;> split <;> omega
  have hw : ForwardSlackWitnessed stepOr pendT fwdOr bwdOr labB PlusFormula.bot
      (⟨(true, c + 1 * (P + 1), 0), hadm _⟩ : LadderState Bool pendT) 0 (1 * (P + 1)) 0 :=
    fsw_consumer_shape c 1 P
  refine ⟨Tc, Tn, P, B, c, 1, hadm _, hadm _, hp, by omega, by omega, by omega, hk, hw, ?_⟩
  refine cellLE_zero_const_of_kappa_eq_of_forwardSlack stepOr pendT fwdOr bwdOr labB
    PlusFormula.bot Tc Tn P B hp no_stab_bot true c 0 (c + 1 * (P + 1)) 0 (hadm _) (hadm _) 0 hk rfl
    (by omega) (by omega) (by omega) (by omega) ?_ ?_
  · intro m hm
    have : m * (P + 1) = 1 * (P + 1) := by omega
    rw [this]; exact hw
  · intro m hm
    exfalso
    have : 0 < 1 * (P + 1) := by omega
    nlinarith [Nat.zero_le (m * (P + 1))]

/-- The climbing path through `(true, C, 0)` at `0`: register climbs by one per step to `C + 1`
at the idle position `C + 1`, the next region has countdown `C + 1` and the register descends
back to `0` across it, then length-`1` regions forever. -/
def climbCRaw (C : ℕ) (v : ℤ) : Bool × ℕ × ℕ :=
  if v ≤ (C : ℤ) then (true, ((C : ℤ) - v).toNat, (max 0 v).toNat)
  else if v = (C : ℤ) + 1 then (false, 0, C + 1)
  else if v ≤ 2 * (C : ℤ) + 3 then (true, (2 * (C : ℤ) + 3 - v).toNat, (2 * (C : ℤ) + 2 - v).toNat)
  else if (v - (2 * (C : ℤ) + 4)) % 2 = 1 then (true, 0, 0)
  else (false, 0, 0)

theorem climbCRaw_adm (C : ℕ) (v : ℤ) : (climbCRaw C v).2.1 ∈ Adm pendT (climbCRaw C v).1 := by
  intro h
  unfold climbCRaw at *
  split_ifs at * <;> simp_all [pendT]

def climbC (C : ℕ) (v : ℤ) : LadderState Bool pendT := ⟨climbCRaw C v, climbCRaw_adm C v⟩

theorem climbC_isLadderPath (C : ℕ) : IsLadderPath stepOr pendT (climbC C) := by
  intro u
  change Rlad stepOr pendT u (climbCRaw C u) (climbCRaw C (u + 1))
  unfold Rlad Drift Count climbCRaw stepOr pendT
  split_ifs <;> simp_all <;> omega

theorem climbC_at_zero (C : ℕ) : (climbC C 0).1 = ((true, C, 0) : Bool × ℕ × ℕ) := by
  change climbCRaw C 0 = _
  unfold climbCRaw
  rw [if_pos (by omega)]
  simp

/-- The climbing path has NO forward slack at any positive amount. -/
theorem climbC_not_hasForwardSlack (C l : ℕ) (hl : 0 < l) :
    ¬ HasForwardSlack (climbC C) 0 l 0 := by
  intro h
  have hc : cntAt (climbC C) 0 = C := by
    change (climbC C 0).1.2.1 = C
    rw [climbC_at_zero]
  have := h 1 (by omega) (fun i hi => by
      have : i = 0 := by omega
      subst this
      rw [hc]
      change (climbCRaw C _).1 = false
      unfold climbCRaw
      rw [if_neg (by push_cast; omega), if_pos (by push_cast; omega)])
    (by
      rw [hc]
      change (climbCRaw C _).1 = true
      unfold climbCRaw
      rw [if_neg (by push_cast; omega), if_neg (by push_cast; omega),
        if_pos (by push_cast; omega)])
  rw [hc] at this
  have hn : nxtAt (climbC C) (0 + (C : ℤ) + ((1 : ℕ) : ℤ)) = C + 1 := by
    change (climbCRaw C _).2.2 = C + 1
    unfold climbCRaw
    rw [if_neg (by push_cast; omega), if_pos (by push_cast; omega)]
  rw [hn] at this
  push_cast at this
  omega

end Probe934
end FormalSystem.Metalogic.Decidability.RaySummary

section
open FormalSystem.Metalogic.Decidability.RaySummary.Probe934
#print axioms fsw_consumer_shape
#print axioms plateau_next_region
#print axioms consumer_fires
#print axioms climbC_isLadderPath
#print axioms climbC_not_hasForwardSlack
end
