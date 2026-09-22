-- PROBE (scratch, not a library module). Compiled green via lean_run_code against this tree.
-- Axioms of every theorem below: [propext, Classical.choice, Quot.sound]; no sorryAx.
-- Prepend the `TimeIndexed` block of 01_positive_theorem.lean to run this standalone.
import FormalSystem.Semantics.TaskFrame
import Mathlib.NumberTheory.Real.Irrational

namespace Probe
open FormalSystem.Semantics

namespace TimeIndexed
variable {D : TemporalOrder}
def Compositional (G : TimeIndexed D) : Prop :=
  ∀ w v x y z, x ≤ y → y ≤ z → (G.R w x z v ↔ ∃ u, G.R w x y u ∧ G.R u y z v)
def Serial (G : TimeIndexed D) : Prop := ∀ w x y, (∃ u, G.R w x y u) ∧ (∃ v, G.R v x y w)
def Converse (G : TimeIndexed D) : Prop := ∀ w x y u, G.R w x y u ↔ G.R u y x w
def Static (G : TimeIndexed D) : Prop := ∀ w x y u, G.R w x y u ↔ w = u
end TimeIndexed

/-- A rational time lies below the irrational cut `√2`. -/
def belowCut (x : ℚ) : Prop := (x : ℝ) < Real.sqrt 2

theorem cut_not_rat (x : ℚ) : (x : ℝ) ≠ Real.sqrt 2 := fun h => irrational_sqrt_two ⟨x, h⟩

theorem belowCut_mono {x y : ℚ} (h : x ≤ y) (hy : belowCut y) : belowCut x :=
  lt_of_le_of_lt (by exact_mod_cast h) hy

theorem one_belowCut : belowCut 1 := by
  have : (1:ℝ) < Real.sqrt 2 := by
    nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]
  simpa [belowCut] using this

theorem two_not_belowCut : ¬ belowCut 2 := by
  have h : Real.sqrt 2 < (2:ℝ) := by
    nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]
  simp only [belowCut]; push Not; push_cast; linarith

/-- No rational time is a cut point, so every rational time has a cut-free neighbourhood. -/
theorem exists_radius (x : ℚ) :
    ∃ ε : ℚ, 0 < ε ∧ ∀ s : ℚ, |s - x| < ε → (belowCut s ↔ belowCut x) := by
  have hne : (x : ℝ) ≠ Real.sqrt 2 := cut_not_rat x
  obtain ⟨ε, hε0, hεd⟩ := exists_rat_btwn (abs_pos.mpr (sub_ne_zero.mpr hne))
  refine ⟨ε, by exact_mod_cast hε0, ?_⟩
  intro s hs
  have hs' : |(s:ℝ) - (x:ℝ)| < (ε:ℝ) := by
    have h : ((|s - x| : ℚ) : ℝ) < ((ε:ℚ):ℝ) := by exact_mod_cast hs
    rwa [Rat.cast_abs, Rat.cast_sub] at h
  have habs : |(s:ℝ) - (x:ℝ)| < |(x:ℝ) - Real.sqrt 2| := lt_trans hs' hεd
  rcases lt_or_gt_of_ne hne with hx | hx
  · have h1 : |(x:ℝ) - Real.sqrt 2| = Real.sqrt 2 - (x:ℝ) := by
      rw [abs_sub_comm, abs_of_pos (sub_pos.mpr hx)]
    rw [h1] at habs
    have h2 : (s:ℝ) - (x:ℝ) < Real.sqrt 2 - (x:ℝ) := lt_of_le_of_lt (le_abs_self _) habs
    exact iff_of_true (show (s:ℝ) < Real.sqrt 2 by linarith) (show (x:ℝ) < Real.sqrt 2 from hx)
  · have h1 : |(x:ℝ) - Real.sqrt 2| = (x:ℝ) - Real.sqrt 2 := abs_of_pos (sub_pos.mpr hx)
    rw [h1] at habs
    have h2 : (x:ℝ) - (s:ℝ) < (x:ℝ) - Real.sqrt 2 :=
      lt_of_le_of_lt ((le_abs_self _).trans (abs_sub_comm _ _).le) habs
    exact iff_of_false (show ¬ ((s:ℝ) < Real.sqrt 2) by push Not; linarith)
      (show ¬ ((x:ℝ) < Real.sqrt 2) by push Not; linarith)

/-- The presenting relation: the state changes exactly when the cut is crossed. -/
def switchRel (w : Bool) (x y : ℚ) (u : Bool) : Prop :=
  w = u ∨ (w = false ∧ u = true ∧ belowCut x ∧ ¬ belowCut y)
        ∨ (w = true ∧ u = false ∧ belowCut y ∧ ¬ belowCut x)

def qSwitch : TimeIndexed (TemporalOrder.of ℚ) where
  W := Bool
  R := switchRel

theorem qSwitch_converse : qSwitch.Converse := by
  intro w x y u
  change switchRel w x y u ↔ switchRel u y x w
  unfold switchRel
  constructor <;> rintro (h | ⟨h1,h2,h3,h4⟩ | ⟨h1,h2,h3,h4⟩)
  · exact Or.inl h.symm
  · exact Or.inr (Or.inr ⟨h2, h1, h3, h4⟩)
  · exact Or.inr (Or.inl ⟨h2, h1, h3, h4⟩)
  · exact Or.inl h.symm
  · exact Or.inr (Or.inr ⟨h2, h1, h3, h4⟩)
  · exact Or.inr (Or.inl ⟨h2, h1, h3, h4⟩)

theorem qSwitch_serial : qSwitch.Serial := fun w _ _ => ⟨⟨w, Or.inl rfl⟩, ⟨w, Or.inl rfl⟩⟩

theorem qSwitch_limit : qSwitch.Limit := by
  intro w u t h
  obtain ⟨ε, hε, hrad⟩ := exists_radius t
  obtain ⟨s, hs, hR⟩ := h ε hε
  have hiff : belowCut s ↔ belowCut t := hrad s hs
  rcases hR with h0 | ⟨_,_,h3,h4⟩ | ⟨_,_,h3,h4⟩
  · exact h0.symm
  · exact absurd (hiff.mpr h3) h4
  · exact absurd (hiff.mp h3) h4

theorem qSwitch_compositional : qSwitch.Compositional := by
  intro w v x y z hxy hyz
  change switchRel w x z v ↔ ∃ u, switchRel w x y u ∧ switchRel u y z v
  unfold switchRel
  by_cases hA : belowCut x <;> by_cases hB : belowCut y <;> by_cases hC : belowCut z <;>
    cases w <;> cases v <;> simp_all [belowCut_mono hxy, belowCut_mono hyz]

theorem qSwitch_not_static : ¬ qSwitch.Static := by
  intro h
  have := (h false 1 2 true).mp
    (show switchRel false 1 2 true from Or.inr (Or.inl ⟨rfl, rfl, one_belowCut, two_not_belowCut⟩))
  exact Bool.noConfusion this

open Classical in
/-- The switching history: `false` below the cut, `true` above it. -/
noncomputable def switchHist : ℚ → Bool := fun t => if belowCut t then false else true

theorem switchHist_mem : switchHist ∈ qSwitch.Hist := by
  intro x y
  change switchRel (switchHist x) x y (switchHist y)
  unfold switchRel switchHist
  by_cases hx : belowCut x <;> by_cases hy : belowCut y <;> simp [hx, hy]

theorem qSwitch_not_constantHistories : ¬ qSwitch.ConstantHistories := by
  intro h
  have h2 := h switchHist switchHist_mem 1 2
  unfold switchHist at h2
  rw [if_pos one_belowCut, if_neg two_not_belowCut] at h2
  exact Bool.noConfusion h2

end Probe
