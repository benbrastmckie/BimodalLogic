import FormalSystem.Semantics.StateTopology

/-!
# Probe: `𝒩_F` need not be R0 once *Limit* is dropped

`W = {γ} ∪ {r t : t ∈ ℝ}` over `D = ℝ`.  The ray `r` drifts forward at speed at most `1`
(the two-origin frame's law, on the whole line).  The **ghost** `γ` loops at every duration and
reaches *every strictly positive* ray point in *every strictly positive* duration.  Nothing
reaches `γ` forward.

*Seriality* and *Compositionality* hold; *Limit* fails; and `𝒩_F` is **not R0**:
`r 0 ∈ cl {γ}` while `γ ∉ cl {r 0}`.
-/

open Topology TopologicalSpace Set

set_option warn.classDefReducibility false

namespace FormalSystem.Semantics.StateTopology
namespace GhostRay

open FormalSystem.Semantics FormalSystem.Semantics.TaskFrame

/-- The states: a ghost `γ` and a two-sided ray. -/
inductive GH
  | γ
  | r (t : ℝ)

open GH

/-- The ghost-ray task relation. -/
def rel : GH → ℝ → GH → Prop
  | γ, _, γ => True
  | γ, x, r s => 0 < x ∧ 0 < s
  | r t, x, γ => x < 0 ∧ 0 < t
  | r t, x, r s => (0 ≤ x ∧ t ≤ s ∧ s ≤ t + x) ∨ (x < 0 ∧ s ≤ t ∧ t ≤ s - x)

theorem rel_refl (w : GH) (x : ℝ) (hx : 0 ≤ x) : rel w x w := by
  cases w with
  | γ => trivial
  | r t => exact Or.inl ⟨hx, le_rfl, by linarith⟩

/-- **The ghost-ray frame satisfies *Seriality*** (`def:frame#Seriality`). -/
theorem rel_serial : Serial rel := by
  intro w x hx
  exact ⟨⟨w, rel_refl w x hx⟩, ⟨w, rel_refl w x hx⟩⟩

/-- The ghost-ray relation obeys the reflection law at every duration. -/
theorem rel_reflection (w : GH) (x : ℝ) (u : GH) : rel w x u ↔ rel u (-x) w := by
  cases w with
  | γ =>
    cases u with
    | γ => exact Iff.rfl
    | r s => exact ⟨fun h => ⟨by linarith [h.1], h.2⟩, fun h => ⟨by linarith [h.1], h.2⟩⟩
  | r t =>
    cases u with
    | γ => exact ⟨fun h => ⟨by linarith [h.1], h.2⟩, fun h => ⟨by linarith [h.1], h.2⟩⟩
    | r s =>
      constructor
      · rintro (⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩)
        · rcases eq_or_lt_of_le h1 with h0 | h0
          · exact Or.inl ⟨by linarith, by linarith, by linarith⟩
          · exact Or.inr ⟨by linarith, h2, by linarith⟩
        · exact Or.inl ⟨by linarith, h2, by linarith⟩
      · rintro (⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩)
        · rcases eq_or_lt_of_le h1 with h0 | h0
          · exact Or.inl ⟨by linarith, by linarith, by linarith⟩
          · exact Or.inr ⟨by linarith, h2, by linarith⟩
        · exact Or.inl ⟨by linarith, h2, by linarith⟩

/-- **The ghost-ray frame satisfies *Compositionality*** (`def:frame#Compositionality`), both
halves. -/
theorem rel_compositional : Compositional rel := by
  intro w v x y hx hy
  cases w with
  | γ =>
    cases v with
    | γ => exact ⟨fun _ => ⟨γ, trivial, trivial⟩, fun _ => trivial⟩
    | r s =>
      constructor
      · rintro ⟨h1, h2⟩
        rcases eq_or_lt_of_le hy with hy0 | hy0
        · exact ⟨r s, ⟨by linarith, h2⟩, Or.inl ⟨hy, le_rfl, by linarith⟩⟩
        · exact ⟨γ, trivial, ⟨hy0, h2⟩⟩
      · rintro ⟨m, hm, hmv⟩
        cases m with
        | γ => exact ⟨by linarith [hmv.1], hmv.2⟩
        | r q =>
          rcases hmv with ⟨-, h2, -⟩ | ⟨h1, -, -⟩
          · exact ⟨by linarith [hm.1], by linarith [hm.2]⟩
          · linarith
  | r t =>
    cases v with
    | γ =>
      constructor
      · rintro ⟨h1, -⟩; linarith
      · rintro ⟨m, hm, hmv⟩
        cases m with
        | γ => exact absurd hm.1 (by linarith)
        | r q => exact absurd hmv.1 (by linarith)
    | r s =>
      constructor
      · rintro (⟨-, h2, h3⟩ | ⟨h1, -, -⟩)
        · refine ⟨r (min s (t + x)), Or.inl ⟨hx, le_min h2 (by linarith), min_le_right _ _⟩,
            Or.inl ⟨hy, min_le_left _ _, ?_⟩⟩
          rcases min_choice s (t + x) with hm | hm <;> simp only [hm] <;> linarith
        · linarith
      · rintro ⟨m, hm, hmv⟩
        cases m with
        | γ => exact absurd hm.1 (by linarith)
        | r q =>
          rcases hm with ⟨-, h2, h3⟩ | ⟨h1, -, -⟩
          · rcases hmv with ⟨-, h2', h3'⟩ | ⟨h1', -, -⟩
            · exact Or.inl ⟨by linarith, by linarith, by linarith⟩
            · linarith
          · linarith

/-! ### `𝒩_F` is not R0 -/

/-- The ghost lies in every positive cone at every strictly positive ray point. -/
theorem γ_mem_cone_r {s : ℝ} (hs : 0 < s) {x : ℝ} (hx : 0 < x) : γ ∈ cone rel (r s) x :=
  ⟨-x / 2, by rw [abs_of_neg (by linarith)]; linarith, ⟨by linarith, hs⟩⟩

/-- Every strictly positive ray point is in the closure of the ghost. -/
theorem r_mem_closure_γ {s : ℝ} (hs : 0 < s) :
    r s ∈ @closure GH (nbhdTopology rel) ({γ} : Set GH) := by
  letI := nbhdTopology rel
  rw [mem_closure_iff]
  intro O hO hmem
  obtain ⟨x, hx, hc⟩ := hO _ hmem
  exact ⟨γ, hc (γ_mem_cone_r hs hx), rfl⟩

/-- **`r 0` is in the closure of the ghost**, although no task links them directly: every cone at
`r 0` meets the (closed) closure of `{γ}`. -/
theorem r0_mem_closure_γ : r 0 ∈ @closure GH (nbhdTopology rel) ({γ} : Set GH) := by
  letI := nbhdTopology rel
  refine (nbhdTopology_isClosed_iff rel _).mp isClosed_closure _ (fun x hx => ?_)
  refine ⟨r (x / 2), ⟨x / 2, ?_, ?_⟩, r_mem_closure_γ (by linarith)⟩
  · rw [abs_of_pos (by linarith)]; linarith
  · exact Or.inl ⟨by linarith, by linarith, by linarith⟩

/-- `{r 0}` is closed: its complement is `𝒩_F`-open. -/
theorem isClosed_singleton_r0 : IsClosed[nbhdTopology rel] ({r 0} : Set GH) := by
  letI := nbhdTopology rel
  rw [← isOpen_compl_iff]
  intro w hw
  cases w with
  | γ =>
    refine ⟨1, one_pos, ?_⟩
    rintro v ⟨y, hy, hR⟩ hv
    rw [Set.mem_singleton_iff] at hv
    subst hv
    exact absurd hR.2 (by norm_num)
  | r t =>
    have ht : t ≠ 0 := fun h => hw (by rw [h]; rfl)
    refine ⟨|t|, abs_pos.mpr ht, ?_⟩
    rintro v ⟨y, hy, hR⟩ hv
    rw [Set.mem_singleton_iff] at hv
    subst hv
    rcases hR with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
    · rw [abs_of_nonneg h1] at hy; rcases abs_cases t with ⟨he, -⟩ | ⟨he, -⟩ <;>
        rw [he] at hy <;> linarith
    · rw [abs_of_neg h1] at hy; rcases abs_cases t with ⟨he, -⟩ | ⟨he, -⟩ <;>
        rw [he] at hy <;> linarith

/-- **`𝒩_F` is not R0 on the ghost-ray frame.** `r 0 ∈ cl {γ}` but `γ ∉ cl {r 0}`. So *R0* is as
fragile as *T1*: it too fails as soon as *Limit* is dropped, even with *Seriality* and
*Compositionality* in force.

Paper: `app:topology-r0` -/
theorem not_r0Space_nbhdTopology : ¬ @R0Space GH (nbhdTopology rel) := by
  letI := nbhdTopology rel
  intro h
  have hγ : γ ∈ closure ({r 0} : Set GH) :=
    (TaskFrame.r0Space_iff_mem_closure_comm.mp h) _ _ r0_mem_closure_γ
  rw [isClosed_singleton_r0.closure_eq, Set.mem_singleton_iff] at hγ
  exact GH.noConfusion hγ

/-- **The ghost-ray frame fails *Limit***, as a corollary: *Limit* would make `𝒩_F` R0. -/
theorem not_limit : ¬ TaskFrame.Limit rel :=
  fun h => not_r0Space_nbhdTopology (TaskFrame.r0Space_nbhdTopology_of_limit rel h)

/-- The ghost is instantaneously close to `r 1`, which is the direct failure of *Limit*. -/
theorem not_limit_witness : ∀ x : ℝ, 0 < x → r 1 ∈ cone rel γ x :=
  fun x hx => ⟨x / 2, by rw [abs_of_pos (by linarith)]; linarith, ⟨by linarith, one_pos⟩⟩

/-! ### The frame-level forms -/

/-- The real line as a temporal order, for this probe's duration type. -/
noncomputable abbrev ghostRealOrder : TemporalOrder := TemporalOrder.of ℝ

/-- **The ghost-ray structure, as a general task frame.** It carries no `def:frame` constraint as
part of its data; `frame_serial` and `frame_compositional` are the two it satisfies, and *Limit*
fails. It is therefore **not** an `FrameOver.IsRegular` instance. -/
@[reducible] noncomputable def frame : FrameOver ghostRealOrder where
  WorldState := GH
  worldNonempty := ⟨γ⟩
  PosRel w x u := rel w (x : ℝ) u

theorem frame_taskRel_eq : frame.TaskRel = rel :=
  TaskFrame.reflect_eq_of_reflective rel rel_reflection

theorem frame_serial : Serial frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_serial

theorem frame_compositional : Compositional frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_compositional

theorem frame_not_limit : ¬ TaskFrame.Limit frame.TaskRel := by
  rw [frame_taskRel_eq]; exact not_limit

/-- **The frame's state topology is not R0.** -/
theorem frame_not_r0Space : ¬ @R0Space frame.WorldState (FrameOver.stateTopology frame) := by
  intro h
  refine not_r0Space_nbhdTopology ?_
  have hEq : FrameOver.stateTopology frame = nbhdTopology rel := by
    unfold FrameOver.stateTopology
    rw [frame_taskRel_eq]
  rwa [hEq] at h

end GhostRay
end FormalSystem.Semantics.StateTopology
