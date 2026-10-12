import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761

/-- The two-state object: `step` total, `pend` the identity (`true` pending, `false` idle). -/
abbrev stepB : Bool → Bool → Bool := fun _ _ => true
abbrev pendB : Bool → Bool := fun q => q

/-- Pending at every past time with the countdown `(-z).toNat`, idle from `1` on; `n = B`
throughout. -/
def gPast (B : ℕ) (z : ℤ) : Bool × ℕ × ℕ :=
  if z ≤ 0 then (true, (-z).toNat, B) else (false, 0, B)

theorem gPast_adm (B : ℕ) (z : ℤ) : (gPast B z).2.1 ∈ Adm pendB (gPast B z).1 := by
  unfold gPast
  split_ifs <;> simp [Adm]

def gPastA (B : ℕ) (z : ℤ) : LadderState Bool pendB := ⟨gPast B z, gPast_adm B z⟩

theorem gPast_isPath (B : ℕ) : IsSlicedStepPath (RladAdm stepB pendB) 0 (gPastA B) := by
  intro z
  rcases lt_trichotomy z 0 with h | h | h
  · have h1 : z ≤ 0 := le_of_lt h
    have h2 : z + 1 ≤ 0 := by omega
    simp [RladAdm, Rlad, gPastA, gPast, h1, h2, Drift, Count]
    omega
  · subst h
    simp [RladAdm, Rlad, gPastA, gPast, Drift, Count]
  · have h1 : ¬ z ≤ 0 := not_le.mpr h
    have h2 : ¬ z + 1 ≤ 0 := by omega
    simp [RladAdm, Rlad, gPastA, gPast, h1, h2, Drift, Count]

theorem gPast_pending_past (B : ℕ) (z : ℤ) (hz : z ≤ 0) : (gPastA B z).1.1 = true := by
  simp [gPastA, gPast, hz]

/-- The countdown along the past is unbounded: no pending region of `gPastA` ever ends. -/
theorem gPast_count (B : ℕ) (z : ℤ) (hz : z ≤ 0) : (gPastA B z).1.2.1 = (-z).toNat := by
  simp [gPastA, gPast, hz]

end Probe761

#print axioms Probe761.gPast_isPath
#print axioms Probe761.gPast_pending_past
#print axioms Probe761.gPast_count
