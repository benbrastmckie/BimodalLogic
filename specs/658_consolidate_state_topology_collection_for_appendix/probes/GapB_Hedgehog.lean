import FormalSystem.Semantics.StateTopology.Counterexamples

set_option warn.classDefReducibility false
open Topology TopologicalSpace Set
open FormalSystem.Semantics.TaskFrame

namespace FormalSystem.Semantics.StateTopology
namespace Hedgehog
open HH

/-- Every positive cone at the centre meets every ray: `t < x → p n t ∈ (c)_x`. -/
theorem p_mem_cone_c {n : ℕ} {t : {t : ℝ // 0 < t}} {x : ℝ} (ht : t.1 < x) :
    p n t ∈ cone rel c x :=
  ⟨t.1, by rw [abs_of_pos t.2]; exact ht, show t.1 ≤ t.1 from le_rfl⟩

/-- `{c}` is **not** `𝒩_F`-open: every positive cone at `c` escapes it along ray `0`. -/
theorem not_isOpen_nbhdTopology_singleton_c :
    ¬ IsOpen[nbhdTopology rel] ({c} : Set HH) := by
  intro h
  obtain ⟨x, hx, hsub⟩ := h c rfl
  have := hsub (p_mem_cone_c (n := 0) (t := ⟨x / 2, by positivity⟩) (by dsimp; linarith))
  exact HH.noConfusion (Set.mem_singleton_iff.mp this)

/-- **`𝒯_F ≠ 𝒩_F` on the hedgehog** — the named inequality. `{c}` is a finite intersection of
cones, hence `𝒯_F`-open, but no cone at `c` is contained in it. -/
theorem coneTopology_ne_nbhdTopology : coneTopology rel ≠ nbhdTopology rel := by
  intro heq
  exact not_isOpen_nbhdTopology_singleton_c (heq ▸ isOpen_coneTopology_singleton_c)

/-- **`𝒯_F` is STRICTLY finer than `𝒩_F`** on the hedgehog. In Mathlib's order on
`TopologicalSpace`, `t₁ ≤ t₂` means `t₁` has at least `t₂`'s opens, so this reads
`coneTopology < nbhdTopology`. -/
theorem coneTopology_lt_nbhdTopology : coneTopology rel < nbhdTopology rel :=
  lt_of_le_of_ne (coneTopology_le_nbhdTopology rel (fun w => rel_refl w 0 le_rfl))
    coneTopology_ne_nbhdTopology

#print axioms p_mem_cone_c
#print axioms not_isOpen_nbhdTopology_singleton_c
#print axioms coneTopology_ne_nbhdTopology
#print axioms coneTopology_lt_nbhdTopology

end Hedgehog
end FormalSystem.Semantics.StateTopology
