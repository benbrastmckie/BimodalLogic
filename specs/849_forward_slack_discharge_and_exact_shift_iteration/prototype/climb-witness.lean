import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

/-! Standalone prototype (not a wired probe): the climbing-register path refutes the
unconditional forward-slack claim. Compiled via lean_run_code against the built library during
research; only a `show`-linter warning was reported. -/

namespace ClimbWitness

open FormalSystem.Metalogic.Decidability.RaySummary

/-- Two-state object: `true` pending, `false` idle, every step allowed. -/
def stepT : Bool → Bool → Bool := fun _ _ => true
def pendT : Bool → Bool := fun b => b

/-- The climbing-register path: pending forever up to `3` with countdown `3 - v`, register
`0` for `v ≤ 0` climbing by one per step to `4` at the idle position `4`, then periodic with
period `6` (five pending positions with countdown `4,3,2,1,0`, one idle), register `4`. -/
def gRaw (v : ℤ) : Bool × ℕ × ℕ :=
  if v ≤ 3 then (true, (3 - v).toNat, (max 0 v).toNat)
  else if v = 4 then (false, 0, 4)
  else if (v - 5) % 6 = 5 then (false, 0, 4)
  else (true, (4 - (v - 5) % 6).toNat, 4)

theorem gRaw_adm (v : ℤ) : (gRaw v).2.1 ∈ Adm pendT (gRaw v).1 := by
  intro h
  unfold gRaw at *
  split_ifs at * <;> simp_all [pendT]

def g (v : ℤ) : LadderState Bool pendT := ⟨gRaw v, gRaw_adm v⟩

theorem g_isLadderPath : IsLadderPath stepT pendT g := by
  intro u
  change Rlad stepT pendT u (gRaw u) (gRaw (u + 1))
  unfold Rlad Drift Count gRaw stepT pendT
  split_ifs <;> simp_all <;> omega

theorem g_past : ∀ p : ℤ, p ≤ 0 → pendT (objAt g p) = true := by
  intro p hp
  simp [objAt, g, gRaw, pendT, show p ≤ 3 by omega]

theorem g_gap : nxtAt g 0 + (0 + 1) ≤ cntAt g 0 := by
  simp [nxtAt, cntAt, g, gRaw]

theorem g_not_slack : ¬ HasForwardSlack g 0 (0 + 1) (nxtAt g 0) := by
  intro h
  have := h 1 (by omega) (fun i hi => by
      have : i = 0 := by omega
      subst this
      simp [objAt, g, gRaw, pendT, cntAt])
    (by simp [objAt, g, gRaw, pendT, cntAt])
  simp [nxtAt, cntAt, g, gRaw] at this

/-- **The unconditional forward-slack claim is refuted by a ladder path**: pending forever
into the past at `0`, gap `nxtAt + (P + 1) ≤ cntAt` with `P = 0`, and no forward slack. -/
theorem refutation :
    ∃ g : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g ∧
      (∀ p : ℤ, p ≤ 0 → pendT (objAt g p) = true) ∧
      nxtAt g 0 + (0 + 1) ≤ cntAt g 0 ∧ ¬ HasForwardSlack g 0 (0 + 1) (nxtAt g 0) :=
  ⟨g, g_isLadderPath, g_past, g_gap, g_not_slack⟩

end ClimbWitness
