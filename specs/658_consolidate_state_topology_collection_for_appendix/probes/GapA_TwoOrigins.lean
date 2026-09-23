import FormalSystem.Semantics.StateTopology.Counterexamples

set_option warn.classDefReducibility false
open Topology TopologicalSpace Set
open FormalSystem.Semantics
open FormalSystem.Semantics.TaskFrame

namespace FormalSystem.Semantics.StateTopology
namespace TwoOrigins
open TO

/-- **The mixed-sign shortcut condition FAILS on this frame.** `o true ⇒₁ p ⟨1⟩` and
`p ⟨1⟩ ⇒₋₁ o false` are both tasks, but no duration joins the two origins, since
`rel (o b) t (o b')` is `b = b'` at every duration. With `coneTopology_eq_nbhdTopology` below,
this is the library's witness that *Triangle* is **sufficient but not necessary** for
cone-openness. -/
theorem not_triangle : ¬ TaskFrame.Triangle rel := by
  intro h
  obtain ⟨t, _, hR⟩ := h (o true) (p ⟨1, one_pos⟩) (o false) 1 (-1)
    (show (1 : ℝ) ≤ 1 from le_rfl) (show (1 : ℝ) ≤ -(-1) by norm_num)
  exact Bool.noConfusion (hR : true = false)

/-! ### Cone membership: `(o b)_x = {o b} ∪ {p t : t < x}` and
`(p t)_x = {p s : |s - t| < x} ∪ {o true, o false : t < x}` -/

/-- An origin lies in a positive cone at an origin exactly when they are the same origin. -/
theorem o_mem_cone_o {b b' : Bool} {x : ℝ} (hx : 0 < x) :
    o b' ∈ cone rel (o b) x ↔ b = b' := by
  constructor
  · rintro ⟨y, _, hR⟩; exact hR
  · intro h; exact ⟨0, by rwa [abs_zero], h⟩

/-- A ray point lies in a cone at an origin exactly when it is nearer than the radius. -/
theorem p_mem_cone_o {b : Bool} {t : {t : ℝ // 0 < t}} {x : ℝ} :
    p t ∈ cone rel (o b) x ↔ t.1 < x := by
  constructor
  · rintro ⟨y, hy, hR⟩
    change t.1 ≤ y at hR
    exact lt_of_le_of_lt hR (lt_of_le_of_lt (le_abs_self y) hy)
  · intro h
    exact ⟨t.1, by rwa [abs_of_pos t.2], show t.1 ≤ t.1 from le_rfl⟩

/-- An origin lies in a cone at a ray point exactly when the ray point is nearer than the
radius — for BOTH origins, which is why this frame is not Hausdorff. -/
theorem o_mem_cone_p {b : Bool} {t : {t : ℝ // 0 < t}} {x : ℝ} :
    o b ∈ cone rel (p t) x ↔ t.1 < x := by
  constructor
  · rintro ⟨y, hy, hR⟩
    change t.1 ≤ -y at hR
    exact lt_of_le_of_lt hR (lt_of_le_of_lt (neg_le_abs y) hy)
  · intro h
    refine ⟨-t.1, by rwa [abs_neg, abs_of_pos t.2], ?_⟩
    change t.1 ≤ -(-t.1)
    linarith

/-- On the ray the cones are Euclidean intervals. -/
theorem p_mem_cone_p {t s : {t : ℝ // 0 < t}} {x : ℝ} :
    p s ∈ cone rel (p t) x ↔ |s.1 - t.1| < x := by
  constructor
  · rintro ⟨y, hy, hR⟩
    rcases hR with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
    · rw [abs_of_nonneg h1] at hy
      rw [abs_of_nonneg (by linarith : (0 : ℝ) ≤ s.1 - t.1)]
      linarith
    · rw [abs_of_neg h1] at hy
      rw [abs_of_nonpos (by linarith : s.1 - t.1 ≤ (0 : ℝ))]
      linarith
  · intro h
    rcases le_or_gt t.1 s.1 with hts | hts
    · exact ⟨s.1 - t.1, h, Or.inl ⟨by linarith, hts, by linarith⟩⟩
    · exact ⟨s.1 - t.1, h, Or.inr ⟨by linarith, by linarith, by linarith⟩⟩

/-- **Every cone of `rel` is `𝒩_F`-open**, with explicit radii: at `p t ∈ (o b)_x` use
`min t (x - t)` (small enough to exclude both origins, since an origin in `(p t)_ε` needs
`t < ε`); at `p s ∈ (p t)_x` use `x - |s - t|`; at `o b ∈ (p t)_x` use `x - t`. -/
theorem isOpen_nbhdTopology_cone (w : TO) (x : ℝ) (hx : 0 < x) :
    IsOpen[nbhdTopology rel] (cone rel w x) := by
  cases w with
  | o b =>
    intro u hu
    cases u with
    | o b' =>
      obtain rfl : b = b' := (o_mem_cone_o hx).mp hu
      exact ⟨x, hx, subset_rfl⟩
    | p t =>
      have ht : t.1 < x := p_mem_cone_o.mp hu
      refine ⟨min t.1 (x - t.1), lt_min t.2 (by linarith), fun v hv => ?_⟩
      cases v with
      | o b' =>
        exact absurd (o_mem_cone_p.mp hv) (by have := min_le_left t.1 (x - t.1); linarith)
      | p s =>
        have hs : |s.1 - t.1| < min t.1 (x - t.1) := p_mem_cone_p.mp hv
        refine p_mem_cone_o.mpr ?_
        have h1 : s.1 - t.1 ≤ |s.1 - t.1| := le_abs_self _
        have h2 := min_le_right t.1 (x - t.1)
        linarith
  | p t =>
    intro u hu
    cases u with
    | o b =>
      have ht : t.1 < x := o_mem_cone_p.mp hu
      refine ⟨x - t.1, by linarith, fun v hv => ?_⟩
      cases v with
      | o b' => exact o_mem_cone_p.mpr ht
      | p s =>
        have hs : s.1 < x - t.1 := p_mem_cone_o.mp hv
        refine p_mem_cone_p.mpr ?_
        rw [abs_lt]
        constructor <;> linarith [s.2, t.2]
    | p s =>
      have hs : |s.1 - t.1| < x := p_mem_cone_p.mp hu
      refine ⟨x - |s.1 - t.1|, by linarith, fun v hv => ?_⟩
      cases v with
      | o b =>
        have h1 : s.1 < x - |s.1 - t.1| := o_mem_cone_p.mp hv
        refine o_mem_cone_p.mpr ?_
        have h2 : t.1 - s.1 ≤ |s.1 - t.1| := by
          rw [abs_sub_comm]; exact le_abs_self _
        linarith
      | p r =>
        have h1 : |r.1 - s.1| < x - |s.1 - t.1| := p_mem_cone_p.mp hv
        refine p_mem_cone_p.mpr ?_
        have h2 : |r.1 - t.1| ≤ |r.1 - s.1| + |s.1 - t.1| := abs_sub_le _ _ _
        linarith

/-- **`𝒯_F = 𝒩_F` on the two-origin frame**, by cone-openness rather than by the shortcut
condition, which fails here (`not_triangle`). -/
theorem coneTopology_eq_nbhdTopology : coneTopology rel = nbhdTopology rel :=
  (TaskFrame.coneTopology_eq_nbhdTopology_iff (fun w => rel_refl w 0 le_rfl)).mpr
    isOpen_nbhdTopology_cone

/-- **`𝒯_F` is not Hausdorff either** on this frame: it coincides with `𝒩_F`, which separates
neither origin from the other. So T1-but-not-Hausdorff is a property of the FRAME, not an
artefact of which topology is chosen. -/
theorem not_t2Space_coneTopology : ¬ @T2Space TO (coneTopology rel) := by
  rw [coneTopology_eq_nbhdTopology]
  exact not_t2Space_nbhdTopology

/-! ### The frame-level forms — the register the appendix cites -/

/-- The two topologies coincide on the two-origin frame, as a fact about the frame. -/
theorem frame_coneTop_eq_stateTopology : frame.coneTop = FrameOver.stateTopology frame := by
  unfold FrameOver.coneTop FrameOver.stateTopology
  rw [frame_taskRel_eq]; exact coneTopology_eq_nbhdTopology

/-- **Neither topology on this frame is Hausdorff.** -/
theorem frame_not_t2Space_coneTop : ¬ @T2Space frame.WorldState frame.coneTop := by
  rw [frame_coneTop_eq_stateTopology]
  exact frame_not_t2Space

#print axioms not_triangle
#print axioms o_mem_cone_o
#print axioms p_mem_cone_o
#print axioms o_mem_cone_p
#print axioms p_mem_cone_p
#print axioms isOpen_nbhdTopology_cone
#print axioms coneTopology_eq_nbhdTopology
#print axioms not_t2Space_coneTopology
#print axioms frame_coneTop_eq_stateTopology
#print axioms frame_not_t2Space_coneTop

end TwoOrigins
end FormalSystem.Semantics.StateTopology
