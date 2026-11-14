/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle

/-!
# The `I = 1` idle-run sub-regime is REFUTED at the every-amount shape

**NEGATIVE.** This file is the machine-checked record of the obstruction to the remaining
`ForwardSlackWitnessed` frontier: the paths whose intervening idle run has length exactly `1`,
where no repeat block exists to pump. The frontier was previously recorded as "dischargeable on
the pumpable side rather than refuted outright". That is FALSE for the every-amount shape, and
this probe compiles the counterexample.

## What this probe refutes

`forwardSlackWitnessed_refuted_I_one` exhibits a concrete two-state object `stepOr x y = x || y`
— serial in both directions (`fwdOr`, `bwdOr`), with NO idle self-loop, so `stepOr false false =
false` is impossible and every idle run on every ladder path has length exactly `1` — on which
`ForwardSlackWitnessed` is FALSE at amount `4` at the state `xState = (true, 2, 0)`. That state
sits in the pending-forever gap `n + 2 ≤ c` and is realized by the plateau path, so the
refutation is not vacuous: `xState_regime` compiles the regime membership with a concrete
witness.

The mechanism is the amount ceiling `hasForwardSlack_amount_le`
(`FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`), which forces
`(l : ℤ) ≤ n + cntAt g z + I` whenever a genuine next region exists. Because the ceiling is
forced by the OBJECT rather than by a choice of path, it binds uniformly over every path through
the state — which closes the "existential over paths" escape that stops the pin-cascade
refutation at the path level. `forwardSlackWitnessed_holds_below_ceiling` compiles the sharp
boundary: the SAME state carries `ForwardSlackWitnessed` at every amount `l ≤ 3 = n + c + 1`, so
the ceiling — and not some further obstruction — is exactly what the `I = 1` regime refuses.

`not_idleRunPumpable` compiles that `IdleRunPumpable` is unsatisfiable for every path, history
and anchor on this object, so this refutation and the conditional discharge
`forwardSlackWitnessed_of_cell_idleRunPumpable` (`LadderIdle.lean`) cannot collide: the latter's
premise is simply false here.

## What this probe does NOT establish

It does NOT reach the five depth-`0` cell-equality schemas of `LadderCell.lean`
(`cellLE_zero_const_of_kappa_eq_of_forwardSlack` and its `_commonShift_`, `_monotone_`,
`_antitone_`, `_antitone_bounded_` siblings). Those schemas ask for `ForwardSlackWitnessed` at
amount `m * (P + 1)` at the HIGHER state, whose countdown is `c + m * (P + 1)`;
`ceiling_slack_at_consumer_amount` compiles that the ceiling `l ≤ n + cntAt + I` is then
satisfied for free whenever `0 < I`. So all five schemas KEEP `ForwardSlackWitnessed` as a
carried hypothesis, no signature is touched, and `LadderCell.lean` is not edited. For the same
reason `certStabK`'s restatement obligation stays PROVISIONAL, not permanent.

The reserved name `cellLE_zero_const_of_kappa_eq` is claimed by NOTHING in this file, and this
probe bears on its truth value in neither direction.

The surviving frontier is route 4 at the cell level — simultaneous multi-region shortening —
which this probe records but does not attempt.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary
namespace Probe929

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open ClimbWitness (pendT plateau plateauRaw)

/-- Two-state object with NO idle self-loop: `step x y = x || y`. -/
def stepOr : Bool → Bool → Bool := fun x y => x || y

theorem stepOr_idle_idle : stepOr false false = false := rfl

theorem fwdOr : ∀ (t : ℤ) (x : LadderState Bool pendT), ∃ y, RladAdm stepOr pendT t x y := by
  rintro t ⟨⟨q, c, n⟩, hadm⟩
  cases q with
  | false =>
      have hc : c = 0 := hadm rfl
      subst hc
      refine ⟨⟨(true, n, n), by intro h; simp [pendT] at h⟩, ?_⟩
      refine ⟨rfl, by intro _; rfl, Or.inl rfl, ?_⟩
      simp [Count, pendT]
  | true =>
      cases c with
      | zero =>
          refine ⟨⟨(false, 0, n), by intro _; rfl⟩, ?_⟩
          refine ⟨rfl, by intro h; simp [pendT] at h, Or.inl rfl, ?_⟩
          simp [Count, pendT]
      | succ k =>
          refine ⟨⟨(true, k, n), by intro h; simp [pendT] at h⟩, ?_⟩
          refine ⟨rfl, by intro h; simp [pendT] at h, Or.inl rfl, ?_⟩
          simp [Count, pendT]

theorem bwdOr : ∀ (t : ℤ) (x : LadderState Bool pendT), ∃ y, RladAdm stepOr pendT (t - 1) y x := by
  rintro t ⟨⟨q, c, n⟩, hadm⟩
  cases q with
  | false =>
      have hc : c = 0 := hadm rfl
      subst hc
      refine ⟨⟨(true, 0, n), by intro h; simp [pendT] at h⟩, ?_⟩
      refine ⟨rfl, by intro h; simp [pendT] at h, Or.inl rfl, ?_⟩
      simp [Count, pendT]
  | true =>
      refine ⟨⟨(true, c + 1, n), by intro h; simp [pendT] at h⟩, ?_⟩
      refine ⟨rfl, by intro h; simp [pendT] at h, Or.inl rfl, ?_⟩
      simp [Count, pendT]

/-- The plateau path is a ladder path for `stepOr` too. -/
theorem plateau_isLadderPath_stepOr (C : ℕ) : IsLadderPath stepOr pendT (plateau C) := by
  intro u
  change Rlad stepOr pendT u (plateauRaw C u) (plateauRaw C (u + 1))
  unfold Rlad Drift Count plateauRaw stepOr pendT
  split_ifs <;> simp_all <;> omega

def labB : Bool → Atom → Bool := fun _ _ => false

/-- The state `(true, 2, 0)`: pending, countdown `2`, register `0` — in the pending-forever
gap `n + 2 ≤ c`. -/
def xState : LadderState Bool pendT := ⟨(true, 2, 0), by intro h; simp [pendT] at h⟩

theorem plateau_two_at_zero : plateau 2 0 = xState := by
  apply Subtype.ext
  change plateauRaw 2 0 = ((true, 2, 0) : Bool × ℕ × ℕ)
  unfold plateauRaw
  decide

/-- Every ladder path on `stepOr` whose idle run above `z`'s region starts at `z + c + 1`
has that run of length EXACTLY `1`: `stepOr false false = false`, so no two consecutive
idle positions exist. -/
theorem next_pend_of_idle (g : ℤ → LadderState Bool pendT) (hg : IsLadderPath stepOr pendT g)
    (u : ℤ) (hu : pendT (objAt g u) = false) : pendT (objAt g (u + 1)) = true := by
  have hs := objAt_step g hg u
  have : objAt g u = false := hu
  rw [this] at hs
  show objAt g (u + 1) = true
  simpa [stepOr] using hs

/-- **THE I = 1 AMOUNT CEILING, ON EVERY PATH THROUGH THE STATE.** -/
theorem not_hasForwardSlack_of_four
    (g : ℤ → LadderState Bool pendT) (hg : IsLadderPath stepOr pendT g)
    (hgz : g 0 = xState) : ¬ HasForwardSlack g 0 4 0 := by
  intro hs
  have hc : cntAt g 0 = 2 := by rw [show cntAt g 0 = (g 0).1.2.1 from rfl, hgz]; rfl
  have hp0 : pendT (objAt g 0) = true := by
    rw [show objAt g 0 = (g 0).1.1 from rfl, hgz]; rfl
  have h3 : pendT (objAt g (0 + (cntAt g 0 : ℤ) + 1)) = false := not_pend_of_count g hg 0 hp0
  rw [hc] at h3
  have h4 : pendT (objAt g (0 + ((2 : ℕ) : ℤ) + 1 + ((1 : ℕ) : ℤ))) = true := by
    have := next_pend_of_idle g hg _ h3
    simpa using this
  have hidle : ∀ i : ℕ, i < 1 →
      pendT (objAt g (0 + (cntAt g 0 : ℤ) + 1 + (i : ℤ))) = false := by
    intro i hi
    have : i = 0 := by omega
    subst this
    rw [hc]; simpa using h3
  have hnx : pendT (objAt g (0 + (cntAt g 0 : ℤ) + 1 + ((1 : ℕ) : ℤ))) = true := by
    rw [hc]; exact h4
  have hb := hasForwardSlack_amount_le g hg 0 4 0 1 (by omega) hidle hnx hs
  rw [hc] at hb
  norm_num at hb

/-- **THE CELL-LEVEL REFUTATION.** `ForwardSlackWitnessed` is FALSE at amount `4` at the state
`(true, 2, 0)`, which sits in the pending-forever gap `n + 2 ≤ c` and is realized by a ladder
path pending forever into the past. No `I = 1` discharge can conclude
`ForwardSlackWitnessed` at every amount. -/
theorem forwardSlackWitnessed_refuted_I_one :
    ¬ ForwardSlackWitnessed stepOr pendT fwdOr bwdOr labB PlusFormula.bot xState 0 4 0 := by
  intro hw
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdOr bwdOr (plateau 2)
    (plateau_isLadderPath_stepOr 2)
  have hT : tpOf (ladderModel stepOr pendT fwdOr bwdOr labB) PlusFormula.bot τ 0
      ∈ cellAt (ladderModel stepOr pendT fwdOr bwdOr labB) PlusFormula.bot
        ((0, xState) : (ladderFrameAdm stepOr pendT fwdOr bwdOr).WorldState) 0 :=
    (mem_cellAt_ladder_iff fwdOr bwdOr labB PlusFormula.bot xState 0 _).mpr
      ⟨plateau 2, τ, plateau_isLadderPath_stepOr 2, plateau_two_at_zero, hτ, rfl⟩
  obtain ⟨g, σ, hg, hgz, hσ, hslack, -⟩ := hw _ hT
  exact not_hasForwardSlack_of_four g hg hgz hslack

/-- The refuted state IS in the pending-forever regime, witnessed by a concrete path. -/
theorem xState_regime :
    IsLadderPath stepOr pendT (plateau 2) ∧ plateau 2 0 = xState ∧
      (∀ p : ℤ, p ≤ 0 → pendT (objAt (plateau 2) p) = true) ∧
      nxtAt (plateau 2) 0 + 2 ≤ cntAt (plateau 2) 0 :=
  ⟨plateau_isLadderPath_stepOr 2, plateau_two_at_zero, ClimbWitness.plateau_pend_past 2,
    by rw [ClimbWitness.plateau_nxt, ClimbWitness.plateau_cnt_zero]⟩

/-- **924's PREMISE IS UNSATISFIABLE ON THIS OBJECT.** `IdleRunPumpable` fails for EVERY path,
history and anchor on `stepOr`: an object with no idle self-loop has every idle run of length
`1`, and a length-`1` run admits no `(objAt, tpOf)`-repeat block. This is the `I = 1` frontier
exhibited as a whole object rather than as one path. -/
theorem not_idleRunPumpable (φ : PlusFormula) (g : ℤ → LadderState Bool pendT)
    (hg : IsLadderPath stepOr pendT g)
    (σ : WorldHistory (ladderFrameAdm stepOr pendT fwdOr bwdOr).toTaskFrame) (z : ℤ) :
    ¬ IdleRunPumpable stepOr pendT fwdOr bwdOr labB φ g σ z := by
  rintro ⟨-, -, I, k, a, hI, hk, hrun, hstart, hRa, hak, hrep, -⟩
  -- no two consecutive idle positions, so the run has length exactly `1`
  have hI1 : I = 1 := by
    by_contra hne
    have h0 := hrun 0 (by omega)
    have h1 := hrun 1 (by omega)
    have hx := next_pend_of_idle g hg _ (by simpa using h0)
    simp only [Nat.cast_one] at h1
    exact Bool.false_ne_true (h1.symm.trans hx)
  subst hI1
  have hk1 : k = 1 := by omega
  have ha : a = z + (cntAt g z : ℤ) + 1 := by omega
  subst hk1
  subst ha
  have hidle : pendT (objAt g (z + (cntAt g z : ℤ) + 1)) = false := by
    have := hrun 0 (by omega); simpa using this
  have hpend : pendT (objAt g (z + (cntAt g z : ℤ) + 1 + ((1 : ℕ) : ℤ))) = true := by
    simpa using hstart
  rw [hrep] at hidle
  simp only [Nat.cast_one] at hidle hpend
  exact Bool.false_ne_true (hidle.symm.trans hpend)

/-- **THE CEILING NEVER BITES AT THE CONSUMER'S INSTANTIATION.** The five depth-`0` schemas ask
for `ForwardSlackWitnessed` at amount `m · (P + 1)` at the HIGHER state, whose countdown is
`c + m · (P + 1)`; the amount ceiling `l ≤ n + cntAt + I` is then satisfied for free. So the
refutation above does NOT reach the consumer-relevant instantiation. -/
theorem ceiling_slack_at_consumer_amount (n c m P I : ℕ) (hI : 0 < I) :
    ((m * (P + 1) : ℕ) : ℤ) ≤ (n : ℤ) + ((c + m * (P + 1) : ℕ) : ℤ) + (I : ℤ) := by
  push_cast
  omega

/-- At `φ = ⊥` every closure type is empty, so the cell at `xState` is the singleton `{∅}`. -/
theorem tpOf_bot_eq_empty
    (σ : WorldHistory (ladderFrameAdm stepOr pendT fwdOr bwdOr).toTaskFrame) (z : ℤ) :
    tpOf (ladderModel stepOr pendT fwdOr bwdOr labB) PlusFormula.bot σ z = ∅ := by
  classical
  ext ψ
  rw [mem_tpOf_iff]
  constructor
  · rintro ⟨hm, ht⟩
    have : ψ = PlusFormula.bot := by
      revert hm
      unfold plusSubformulaClosure PlusFormula.subformulas
      simp
    subst this
    exact absurd ht (by simp [PlusTruthAt])
  · intro h; exact absurd h (Finset.notMem_empty ψ)

/-- **THE BOUNDARY IS SHARP AT `φ = ⊥`.** The same state carries `ForwardSlackWitnessed` at
every amount `l ≤ 3 = n + c + 1`, and fails at `4`. So the ceiling, not some further
obstruction, is exactly what the `I = 1` regime refuses. -/
theorem forwardSlackWitnessed_holds_below_ceiling (l : ℕ) (hl : l ≤ 3) :
    ForwardSlackWitnessed stepOr pendT fwdOr bwdOr labB PlusFormula.bot xState 0 l 0 := by
  intro T hT
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdOr bwdOr (plateau 2)
    (plateau_isLadderPath_stepOr 2)
  have hTe : T = ∅ := by
    obtain ⟨σ, -, hty⟩ := hT
    rw [← hty, tpOf_bot_eq_empty]
  refine ⟨plateau 2, τ, plateau_isLadderPath_stepOr 2, plateau_two_at_zero, hτ, ?_, ?_⟩
  · exact ClimbWitness.hasForwardSlack_plateau 2 l (by omega)
  · rw [hTe, tpOf_bot_eq_empty]

end Probe929
end FormalSystem.Metalogic.Decidability.RaySummary

section
open FormalSystem.Metalogic.Decidability.RaySummary.Probe929
#print axioms forwardSlackWitnessed_refuted_I_one
#print axioms forwardSlackWitnessed_holds_below_ceiling
#print axioms not_idleRunPumpable
#print axioms ceiling_slack_at_consumer_amount
#print axioms xState_regime
end
