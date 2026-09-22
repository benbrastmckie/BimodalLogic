-- PROBE (scratch, not a library module). Compiled green via lean_run_code against this tree.
-- `#print axioms Probe.TimeIndexed.constant_of_lub` => [propext, Classical.choice, Quot.sound]
import FormalSystem.Semantics.TaskFrame
import Mathlib.Algebra.Order.Group.Bounds

namespace Probe
open FormalSystem.Semantics

structure TimeIndexed (D : TemporalOrder) where
  W : Type
  [nonempty : Nonempty W]
  R : W → ↑D → ↑D → W → Prop

namespace TimeIndexed
variable {D : TemporalOrder}

def Hist (G : TimeIndexed D) : Set (↑D → G.W) := {τ | ∀ x y, G.R (τ x) x y (τ y)}

def Limit (G : TimeIndexed D) : Prop :=
  ∀ w u t, (∀ ε : ↑D, 0 < ε → ∃ s, |s - t| < ε ∧ G.R w t s u) → u = w

def ConstantHistories (G : TimeIndexed D) : Prop := ∀ τ ∈ G.Hist, ∀ x y, τ x = τ y

theorem exists_uniform_radius (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit)
    (w : G.W) (t : ↑D) : ∃ ε : ↑D, 0 < ε ∧ ∀ u s, |s - t| < ε → G.R w t s u → u = w := by
  haveI := Fintype.ofFinite G.W
  classical
  obtain ⟨x₀, hx₀⟩ : ∃ x : ↑D, 0 < x := TaskFrame.exists_pos_of_nontrivial
  have hrad : ∀ u : G.W, ∃ ε : ↑D, 0 < ε ∧ ∀ s, |s - t| < ε → G.R w t s u → u = w := by
    intro u
    by_cases huw : u = w
    · exact ⟨x₀, hx₀, fun _ _ _ => huw⟩
    · have hne : ¬ ∀ ε : ↑D, 0 < ε → ∃ s, |s - t| < ε ∧ G.R w t s u :=
        fun hh => huw (hlim w u t hh)
      push Not at hne
      obtain ⟨ε, hε, hnε⟩ := hne
      exact ⟨ε, hε, fun s hs hR => absurd hR (hnε s hs)⟩
  have huniv : (Finset.univ : Finset G.W).Nonempty := ⟨w, Finset.mem_univ w⟩
  let f : G.W → ↑D := fun u => (hrad u).choose
  refine ⟨Finset.univ.inf' huniv f, ?_, ?_⟩
  · rw [Finset.lt_inf'_iff]; exact fun u _ => (hrad u).choose_spec.1
  · intro u s hs hR
    exact (hrad u).choose_spec.2 s (lt_of_lt_of_le hs (Finset.inf'_le f (Finset.mem_univ u))) hR

theorem locally_constant (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit)
    {τ : ↑D → G.W} (hτ : τ ∈ G.Hist) (t : ↑D) :
    ∃ ε : ↑D, 0 < ε ∧ ∀ s, |s - t| < ε → τ s = τ t := by
  obtain ⟨ε, hε, h⟩ := G.exists_uniform_radius hlim (τ t) t
  exact ⟨ε, hε, fun s hs => h (τ s) s hs (hτ t s)⟩

theorem constant_of_lub [DenselyOrdered ↑D]
    (hlub : ∀ s : Set ↑D, s.Nonempty → BddAbove s → ∃ c, IsLUB s c)
    (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit) : G.ConstantHistories := by
  classical
  have key : ∀ (τ : ↑D → G.W), τ ∈ G.Hist → ∀ a b : ↑D, a ≤ b → τ a = τ b := by
    intro τ hτ a b hab
    set S : Set ↑D := {y | a ≤ y ∧ y ≤ b ∧ τ y = τ a} with hS
    have haS : a ∈ S := ⟨le_refl a, hab, rfl⟩
    obtain ⟨c, hc⟩ := hlub S ⟨a, haS⟩ ⟨b, fun y hy => hy.2.1⟩
    obtain ⟨ε, hε, hloc⟩ := G.locally_constant hlim hτ c
    have hac : a ≤ c := hc.1 haS
    have hcb : c ≤ b := hc.2 (fun y hy => hy.2.1)
    obtain ⟨s, hsS, hsc, hsle⟩ := IsLUB.exists_between_sub_self hc hε
    have hτc : τ c = τ a := by
      have hsabs : |s - c| < ε := by
        rw [abs_sub_lt_iff]
        exact ⟨lt_of_le_of_lt (sub_nonpos.mpr hsle) hε, sub_lt_comm.mp hsc⟩
      rw [← hloc s hsabs]; exact hsS.2.2
    rcases eq_or_lt_of_le hcb with h | hlt
    · rw [← h]; exact hτc.symm
    · exfalso
      obtain ⟨y, hy1, hy2⟩ := exists_between (lt_min hlt (lt_add_of_pos_right c hε))
      have hyabs : |y - c| < ε := by
        rw [abs_sub_lt_iff]
        exact ⟨sub_lt_iff_lt_add'.mpr (lt_of_lt_of_le hy2 (min_le_right _ _)),
          lt_of_lt_of_le (sub_neg.mpr hy1) hε.le⟩
      have hyS : y ∈ S := ⟨le_of_lt (lt_of_le_of_lt hac hy1),
        le_of_lt (lt_of_lt_of_le hy2 (min_le_left _ _)), by rw [hloc y hyabs]; exact hτc⟩
      exact absurd (hc.1 hyS) (not_le.mpr hy1)
  intro τ hτ x y
  rcases le_total x y with h | h
  · exact key τ hτ x y h
  · exact (key τ hτ y x h).symm

end TimeIndexed
end Probe
