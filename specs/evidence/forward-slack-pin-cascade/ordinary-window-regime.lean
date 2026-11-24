/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell

/-!
# The depth-`0` obligation's two counter regimes are SEGREGATED, and the ordinary one is POPULATED

## What this probe holds in place

1. **REGIME SEGREGATION.** No `kappa`-collision crosses the boundary between the pending-forever
   regime `n + 2 ≤ c` and the ordinary window regime `c ≤ n + 1` (`kappa_ne_of_regime_cross`), at
   `2 ≤ B` — which `(K4)` requires. So the two halves of the depth-`0` obligation are genuinely
   separate problems and a discharge in one buys nothing in the other.
2. **THE ORDINARY HALF IS POPULATED.** At the periodicity fixpoint's own parameters there is a
   `kappa`-collision with `c ≠ c'`, both pairs above both thresholds, both pairs in the ordinary
   window regime, the pending-forever gap FAILING at both, and a ladder path through each state
   (`ordinary_window_collision_nonvacuous`). Every landed depth-`0` cell-equality inclusion
   carries the pending-forever gap, so every one of them is VACUOUS on this collision. No landed
   declaration carries either fact; that is why this probe is wired rather than dropped.
3. **THE `⊡`-DUAL IS WHAT THE SEPARATING FAMILIES READ THE GAP WITH.** `diaF ψ` and `.stab ψ`
   both fail the depth-`0` schema's stab-free hypothesis (`diaF_not_stabFree`,
   `stab_not_stabFree`), which is why no compiled separating family refutes
   `CellLEZeroConstOfKappaEq` at depth `0`.
4. **`(K4)`'s FORWARD DEFICIT, AND ITS CLOSURE.** The deficit against `Zrel`'s forward gap arm is
   recorded against the frozen `paramsOkK4Pre`, beside the theorem that the repaired `paramsOkK4`
   now delivers that arm unconditionally.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary
namespace ProbeOrdinaryWindow

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open ClimbWitness (pendT)
open IdleRunOne

/-- **REGIME SEGREGATION.** No `kappa`-collision crosses the boundary. -/
theorem kappa_ne_of_regime_cross (Tc Tn P B c n c' n' : ℕ) (hB : 2 ≤ B)
    (hlo : n + 2 ≤ c) (hhi : c' ≤ n' + 1) :
    kappa Tc Tn P B (c, n) ≠ kappa Tc Tn P B (c', n') := by
  intro h
  simp only [kappa, Prod.mk.injEq, Fin.mk.injEq] at h
  obtain ⟨-, -, -, -, hclip⟩ := h
  simp only [clipIdx] at hclip
  split_ifs at hclip <;> omega

/-- The register-tight path: countdown and register descend together to `0`, then length-`1`
regions forever. At `0` it is the state `(true, n, n)`, a gap-`0` state. -/
def regRaw (n : ℕ) (v : ℤ) : Bool × ℕ × ℕ :=
  if v ≤ (n : ℤ) then (true, ((n : ℤ) - v).toNat, ((n : ℤ) - v).toNat)
  else if (v - (n : ℤ)) % 2 = 1 then (false, 0, 0)
  else (true, 0, 0)

theorem regRaw_adm (n : ℕ) (v : ℤ) : (regRaw n v).2.1 ∈ Adm pendT (regRaw n v).1 := by
  intro h
  unfold regRaw at *
  split_ifs at * <;> simp_all [pendT]

def regN (n : ℕ) (v : ℤ) : LadderState Bool pendT := ⟨regRaw n v, regRaw_adm n v⟩

theorem regN_isLadderPath (n : ℕ) : IsLadderPath stepOr pendT (regN n) := by
  intro u
  change Rlad stepOr pendT u (regRaw n u) (regRaw n (u + 1))
  unfold Rlad Drift Count regRaw stepOr pendT
  split_ifs <;> simp_all <;> omega

theorem regN_at_zero (n : ℕ) : (regN n 0).1 = ((true, n, n) : Bool × ℕ × ℕ) := by
  change regRaw n 0 = _
  unfold regRaw
  rw [if_pos (by omega)]
  simp

/-- **THE ORDINARY WINDOW REGIME IS POPULATED.** At the periodicity fixpoint's own parameters
there is a `kappa`-collision with `c ≠ c'`, both pairs ABOVE both thresholds, both pairs in the
ordinary window regime `c ≤ n + 1`, the pending-forever gap `n + 2 ≤ c` FAILING at both pairs
(so every landed depth-`0` schema is vacuous there), and a ladder path through each state. -/
theorem ordinary_window_collision_nonvacuous :
    ∃ (Tc Tn P B c n c' n' : ℕ),
      ParamsOk stepOr pendT labB PlusFormula.bot Tc Tn P B ∧
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') ∧
      c ≠ c' ∧ Tc ≤ c ∧ Tc ≤ c' ∧ Tn ≤ n ∧ Tn ≤ n' ∧
      c ≤ n + 1 ∧ c' ≤ n' + 1 ∧
      ¬ (n + 2 ≤ c) ∧ ¬ (n' + 2 ≤ c') ∧
      IsLadderPath stepOr pendT (regN n) ∧
      (regN n 0).1 = ((true, c, n) : Bool × ℕ × ℕ) ∧
      IsLadderPath stepOr pendT (regN n') ∧
      (regN n' 0).1 = ((true, c', n') : Bool × ℕ × ℕ) := by
  set Tc := Tcof stepOr pendT labB PlusFormula.bot with hTc
  set Tn := Tnof stepOr pendT labB PlusFormula.bot with hTn
  set P := Pof stepOr pendT labB PlusFormula.bot with hP
  set B := Bof stepOr pendT labB PlusFormula.bot with hB
  refine ⟨Tc, Tn, P, B, Tc + Tn, Tc + Tn, Tc + Tn + (P + 1), Tc + Tn + (P + 1),
    paramsOk_params _ _ _ _, ?_, by omega, by omega, by omega, by omega, by omega,
    by omega, by omega, by omega, by omega,
    regN_isLadderPath _, regN_at_zero _, regN_isLadderPath _, regN_at_zero _⟩
  simp only [kappa, Prod.mk.injEq, Fin.mk.injEq]
  refine ⟨by omega, ?_, by omega, ?_, ?_⟩
  · simp
  · simp
  · simp only [clipIdx]
    split_ifs <;> omega


/-! ## The `⊡`-dual is what every compiled separating family reads the gap with -/

/-- `diaF`, verbatim from the two wired probes
(`ladder-cell-agreement-refutation.lean:2349`, `ladder-step-fragment-gap-depth.lean`). -/
def diaF (psi : PlusFormula) : PlusFormula :=
  PlusFormula.neg (.stab (PlusFormula.neg psi))

/-- **A `diaF`-ROOTED FORMULA FAILS THE DEPTH-`0` SCHEMA'S STAB-FREE HYPOTHESIS.** -/
theorem diaF_not_stabFree (psi : PlusFormula) :
    ¬ (∀ chi : PlusFormula, PlusFormula.stab chi ∉ plusSubformulaClosure (diaF psi)) := by
  intro h
  exact h (PlusFormula.neg psi) (by
    simp [diaF, PlusFormula.neg, plusSubformulaClosure, PlusFormula.subformulas])

/-- **A `.stab`-ROOTED FORMULA FAILS IT TOO** (`thetaC`'s shape). -/
theorem stab_not_stabFree (psi : PlusFormula) :
    ¬ (∀ chi : PlusFormula, PlusFormula.stab chi ∉ plusSubformulaClosure (.stab psi)) := by
  intro h
  exact h psi (by simp [plusSubformulaClosure, PlusFormula.subformulas])

/-! ## (K4)'s forward conjunct WAS one short of the back-and-forth's forward gap arm, and is not

The deficit this section recorded is CLOSED: `paramsOkK4`'s forward conjunct now reads
`2 * dFwd φ + 2 ≤ B` and `Bof`'s middle arm matches, which is exactly `Zrel`'s own forward
demand. The deficit is kept here as a record, stated against the FROZEN `paramsOkK4Pre`
(`CounterQuotient.lean`), beside the companion theorem that the live predicate now delivers the
arm unconditionally. Nothing here is weakened to pass: the measurement is the same measurement,
read against the conjunct it was a measurement of. -/

/-- The witness formula `X p`: `dBack = 0`, `dFwd = 1`. -/
def xp : PlusFormula := .untl .bot (.atom ⟨"p", none⟩)

theorem dBack_xp : dBack xp = 0 := rfl

theorem dFwd_xp : dFwd xp = 1 := rfl

/-- `Bof`'s body before the forward repair, frozen beside the library's own `paramsOkK4Pre`. -/
def BofPre (φ : PlusFormula) : ℕ :=
  max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)

/-- **THE PRE-REPAIR (K4) DID NOT DELIVER `Zrel`'s FORWARD GAP ARM.** `Zrel_of_kappa_eq`
consumes `2 * dFwd phi + 2 <= B`; `paramsOkK4Pre` asks only `2 * dFwd phi + 1 <= B`, and the
deficit bit at the pre-repair `Bof` output itself. -/
theorem paramsOkK4Pre_one_short_of_Zrel_forward_arm :
    paramsOkK4Pre xp 3 ∧ BofPre xp = 3 ∧ ¬ (2 * dFwd xp + 2 ≤ 3) := by
  refine ⟨⟨?_, ?_, ?_⟩, ?_, ?_⟩
  · rw [dBack_xp]; omega
  · rw [dFwd_xp]
  · omega
  · simp [BofPre, dBack_xp, dFwd_xp]
  · rw [dFwd_xp]; omega

/-- **THE DEFICIT IS CLOSED.** The repaired `(K4)` delivers `Zrel`'s forward gap arm for every
formula and every clip it admits, so `cellAt_const_of_kappa_eq_stepFrag`'s `hBb` is discharged
from `ParamsOk` rather than carried. The repaired output at the witness formula is `4`, one above
the clip the frozen conjunct admitted. -/
theorem paramsOkK4_delivers_Zrel_forward_arm :
    (∀ (φ : PlusFormula) (B : ℕ), paramsOkK4 φ B → 2 * dFwd φ + 2 ≤ B) ∧
      Bof stepOr pendT labB xp = 4 ∧ ¬ paramsOkK4 xp 3 := by
  refine ⟨fun _ _ h => h.2.1, ?_, ?_⟩
  · simp [Bof, dBack_xp, dFwd_xp]
  · intro h
    have h2 := h.2.1
    rw [dFwd_xp] at h2
    omega

end ProbeOrdinaryWindow
end FormalSystem.Metalogic.Decidability.RaySummary

section
open FormalSystem.Metalogic.Decidability.RaySummary.ProbeOrdinaryWindow
#print axioms kappa_ne_of_regime_cross
#print axioms regN_isLadderPath
#print axioms ordinary_window_collision_nonvacuous
#print axioms diaF_not_stabFree
#print axioms stab_not_stabFree
#print axioms paramsOkK4Pre_one_short_of_Zrel_forward_arm
#print axioms paramsOkK4_delivers_Zrel_forward_arm
end
