/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Topology.Order.Compact
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import FormalSystem.Semantics.StateTopology

/-!
# The metric frame: carrier `ℝ`, speed at most `c`

**"The metric frame" was not a declared object.** It existed only as prose — `StateTopology.lean`'s
`Triangle` docstring says "deterministic (group-action) frames and the metric frames satisfy it",
and the module's real-carrier bridges (`TaskFrame.nbhdTopology_eq_real`,
`TaskFrame.coneTopology_eq_nbhdTopology_real`) take the ball shape of the cones as a *hypothesis*.
A hypothesis shape is not a frame. This module names the object those results were always about:

`rel c : ℝ → ℝ → ℝ → Prop := fun r y u => |u - r| ≤ c * |y|` — a task of duration `y` moves at
speed at most `c`.

## What it satisfies

All four `def:frame` constraints, for `0 < c`: `rel_serial`, `rel_compositional`, `rel_limit`,
`rel_saturation`. `isRegular` assembles them into `FrameOver.IsRegular` at any positive speed, and
`instance : (frame 1).IsRegular` pins the unit-speed case for instance synthesis. *Saturation*
holds by the same `Set.Icc` route the two-origin half-line uses
(`TaskFrame.exists_mem_image_of_directedFamily_Icc`), with the **identity** as shadow map: every
fibre is a closed ball, hence a closed interval, and every segment is an intersection of two of
them (`isIcc_of_fiber_or_segment`).

## What it shows

`finalTopology_eq_nbhdTopology`: on this frame the cone-neighbourhood topology `𝒩_F` **is** the
final topology induced by all histories. It specialises the general criterion
`TaskFrame.finalTopology_eq_of_surjective_open_history`, via the straight line at full speed
`t ↦ c · t`, which is a history (`isHistory_line`), surjective, and open (multiplication by a
nonzero constant).

The consequence the manuscript consumes: `StateTopology/Counterexamples.lean`'s hedgehog separates
`𝒩_F` from the final topology (`Hedgehog.finalTopology_ne_nbhdTopology`), and this module locates
that separation. It is a feature of **branching** — a cone at the hedgehog's centre reaches every
ray at once while any one history follows a single ray — not of the cone construction. On the
frame the paper's own intuition is built from, the two topologies agree.

## Import weight

Like `Semantics/StateTopology.lean` and its sibling witness modules, this is a leaf: nothing under
`FormalSystem/` imports it and the generated library root reaches it directly. See
`docs/ARCHITECTURE.md`'s "The state topology is a leaf, on purpose".

## References

- JPL paper `def:frame`, `def:task-topology`
-/

-- Inherited from `Semantics/StateTopology.lean`: `coneTopology` and `nbhdTopology` are `def`s of
-- class type, which `warn.classDefReducibility` reports at every mention.
set_option warn.classDefReducibility false

open Topology TopologicalSpace Set

namespace FormalSystem.Semantics.StateTopology
namespace MetricFrame

open FormalSystem.Semantics FormalSystem.Semantics.TaskFrame

variable (c : ℝ)

/-- **The metric task relation**: a task of duration `y` moves at speed at most `c`. -/
def rel (c : ℝ) : ℝ → ℝ → ℝ → Prop := fun r y u => |u - r| ≤ c * |y|

/-- The metric relation obeys the reflection law at every duration, so the `FrameOver` value below
recovers it as its `TaskRel`. -/
theorem rel_reflection (r y u : ℝ) : rel c r y u ↔ rel c u (-y) r := by
  unfold rel
  rw [abs_neg, ← abs_neg (u - r), neg_sub]

/-- **The metric frame satisfies *Seriality*** (`def:frame#Seriality`). -/
theorem rel_serial (hc : 0 ≤ c) : Serial (rel c) := by
  have hself : ∀ w x : ℝ, rel c w x w := by
    intro w x; change |w - w| ≤ c * |x|; simp only [sub_self, abs_zero]; positivity
  intro w x _
  exact ⟨⟨w, hself w x⟩, ⟨w, hself w x⟩⟩

/-- **The metric frame satisfies *Limit*** (`def:frame#Limit`). -/
theorem rel_limit (hc : 0 < c) : TaskFrame.Limit (rel c) := by
  intro w u h
  by_contra hne
  have hpos : 0 < |u - w| := abs_pos.mpr (sub_ne_zero.mpr hne)
  obtain ⟨y, hy, hR⟩ := h (|u - w| / c) (by positivity)
  have h1 : |u - w| ≤ c * |y| := hR
  have h2 : c * |y| < c * (|u - w| / c) := mul_lt_mul_of_pos_left hy hc
  rw [mul_div_cancel₀ _ hc.ne'] at h2
  linarith

/-- **The metric frame satisfies *Compositionality*** (`def:frame#Compositionality`), both halves:
a task of duration `x + y` splits at the point reached after `x`. The interpolation direction
splits at `w + (c·x/|v-w|)·(v-w)` whenever the endpoint is further than `c·x`. -/
theorem rel_compositional (hc : 0 < c) : Compositional (rel c) := by
  intro w v x y hx hy
  constructor
  · intro h
    have hxy : |v - w| ≤ c * x + c * y := by
      have h0 : |v - w| ≤ c * |x + y| := h
      rwa [abs_of_nonneg (by linarith : (0:ℝ) ≤ x + y), mul_add] at h0
    rcases le_or_gt (|v - w|) (c * x) with hle | hgt
    · refine ⟨v, ?_, ?_⟩
      · change |v - w| ≤ c * |x|; rwa [abs_of_nonneg hx]
      · change |v - v| ≤ c * |y|; simp only [sub_self, abs_zero]; positivity
    · have hd : (0 : ℝ) < |v - w| := lt_of_le_of_lt (mul_nonneg hc.le hx) hgt
      refine ⟨w + (c * x / |v - w|) * (v - w), ?_, ?_⟩
      · change |w + (c * x / |v - w|) * (v - w) - w| ≤ c * |x|
        rw [add_sub_cancel_left, abs_mul, abs_of_nonneg (by positivity : (0:ℝ) ≤ c * x / |v - w|),
          div_mul_cancel₀ _ (ne_of_gt hd), abs_of_nonneg hx]
      · change |v - (w + (c * x / |v - w|) * (v - w))| ≤ c * |y|
        have heq : v - (w + (c * x / |v - w|) * (v - w)) = (1 - c * x / |v - w|) * (v - w) := by
          ring
        have hle1 : c * x / |v - w| ≤ 1 := by rw [div_le_one hd]; linarith
        rw [heq, abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ 1 - c * x / |v - w|),
          abs_of_nonneg hy, sub_mul, one_mul, div_mul_cancel₀ _ (ne_of_gt hd)]
        linarith
  · rintro ⟨u, h1, h2⟩
    have e1 : |u - w| ≤ c * |x| := h1
    have e2 : |v - u| ≤ c * |y| := h2
    change |v - w| ≤ c * |x + y|
    have hsum : |v - w| ≤ |v - u| + |u - w| := abs_sub_le v u w
    rw [abs_of_nonneg hx] at e1
    rw [abs_of_nonneg hy] at e2
    rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ x + y), mul_add]
    linarith

/-! ### *Saturation*: the identity is its own shadow map -/

/-- Every fibre of the metric relation is a closed ball, hence a closed interval. -/
theorem fib_eq_Icc (w x : ℝ) : Fib (rel c) w x = Icc (w - c * |x|) (w + c * |x|) := by
  ext u
  simp only [mem_Fib, Set.mem_Icc]
  change |u - w| ≤ c * |x| ↔ _
  rw [abs_le]
  constructor
  · rintro ⟨h1, h2⟩; exact ⟨by linarith, by linarith⟩
  · rintro ⟨h1, h2⟩; exact ⟨by linarith, by linarith⟩

/-- Every fibre and every segment of the metric relation is a closed interval — fibres are closed
balls, and a segment is an intersection of two of them. -/
theorem isIcc_of_fiber_or_segment {s : Set ℝ}
    (h : IsFiber (rel c) s ∨ IsSegment (rel c) s) : ∃ a b, s = Icc a b := by
  rcases h with ⟨w, x, rfl⟩ | ⟨w, v, x, y, -, -, rfl⟩
  · exact ⟨_, _, fib_eq_Icc c w x⟩
  · refine ⟨(w - c * |x|) ⊔ (v - c * |-y|), (w + c * |x|) ⊓ (v + c * |-y|), ?_⟩
    rw [Seg, fib_eq_Icc, fib_eq_Icc, Set.Icc_inter_Icc]

/-- **The metric frame satisfies *Saturation*** (`def:frame#Saturation`), at every speed.

The shadow argument degenerates here: the carrier is already `ℝ`, so the *identity* is the shadow
map and `TaskFrame.exists_mem_image_of_directedFamily_Icc` returns a common element rather than a
common image point. No lifting step is needed, which is what distinguishes this frame from the
two-origin half-line and the hedgehog, where the shadow map is genuinely non-injective. -/
theorem rel_saturation : TaskFrame.Saturation (rel c) := by
  intro S hdir hmem
  obtain ⟨r, hr⟩ := TaskFrame.exists_mem_image_of_directedFamily_Icc (fun u : ℝ => u) hdir
    (fun s hs => (hmem s hs).2)
    (fun s hs => by
      obtain ⟨a, b, h⟩ := isIcc_of_fiber_or_segment c (hmem s hs).1
      exact ⟨a, b, by rw [Set.image_id', h]⟩)
  refine ⟨r, Set.mem_sInter.mpr fun s hs => ?_⟩
  have h := hr s hs
  rwa [Set.image_id'] at h

/-! ### The cones are the Euclidean balls -/

/-- The cones of the metric relation are the Euclidean balls. -/
theorem cone_eq_ball (hc : 0 < c) (r x : ℝ) (_hx : 0 < x) :
    cone (rel c) r x = Metric.ball r (c * x) := by
  ext u
  simp only [mem_cone, Metric.mem_ball, Real.dist_eq]
  constructor
  · rintro ⟨y, hy, hR⟩
    have : |u - r| ≤ c * |y| := hR
    have : c * |y| < c * x := mul_lt_mul_of_pos_left hy hc
    linarith
  · intro h
    refine ⟨|u - r| / c, ?_, ?_⟩
    · rw [abs_of_nonneg (by positivity), div_lt_iff₀ hc]
      nlinarith
    · change |u - r| ≤ c * |(|u - r| / c)|
      have habs : |(|u - r| / c)| = |u - r| / c := abs_of_nonneg (by positivity)
      rw [habs, mul_div_cancel₀]
      exact hc.ne'

/-- `𝒩_F` on the metric frame **is** the Euclidean topology, by
`TaskFrame.nbhdTopology_eq_real`. -/
theorem nbhdTopology_eq (hc : 0 < c) :
    nbhdTopology (rel c) = (inferInstance : TopologicalSpace ℝ) :=
  nbhdTopology_eq_real (rel c) hc (cone_eq_ball c hc)

/-! ### `𝒩_F` is the final topology of all histories -/

/-- The straight line at full speed is a history. -/
theorem isHistory_line (hc : 0 < c) (r₀ : ℝ) :
    IsHistory (rel c) (fun t => r₀ + c * t) := by
  intro x y
  change |(r₀ + c * y) - (r₀ + c * x)| ≤ c * |y - x|
  rw [show (r₀ + c * y) - (r₀ + c * x) = c * (y - x) by ring, abs_mul,
    abs_of_nonneg (le_of_lt hc)]

/-- **On the metric frame the cone-neighbourhood topology and the final topology of all histories
COINCIDE.** A specialisation of `TaskFrame.finalTopology_eq_of_surjective_open_history` through the
straight line at full speed, which is surjective and open.

The hedgehog's separation of the two
(`StateTopology/Counterexamples.lean`'s `Hedgehog.finalTopology_ne_nbhdTopology`) is therefore a
feature of branching, not of the cone construction.

Paper: — (formalization-native) -/
theorem finalTopology_eq_nbhdTopology (hc : 0 < c) :
    (⨆ σ : {σ : ℝ → ℝ // IsHistory (rel c) σ},
      TopologicalSpace.coinduced σ.1 (inferInstance : TopologicalSpace ℝ)) =
      nbhdTopology (rel c) := by
  refine finalTopology_eq_of_surjective_open_history (rel c) (isHistory_line c hc 0) ?_ ?_
  · intro u
    exact ⟨u / c, by simp only [zero_add]; field_simp⟩
  · intro U hU
    rw [nbhdTopology_eq c hc]
    have h1 : (fun t : ℝ => 0 + c * t) '' U = (fun t : ℝ => t / c) ⁻¹' U := by
      ext y
      constructor
      · rintro ⟨t, ht, rfl⟩
        change (0 + c * t) / c ∈ U
        rwa [zero_add, mul_div_cancel_left₀ t hc.ne']
      · intro hy
        refine ⟨y / c, hy, ?_⟩
        change 0 + c * (y / c) = y
        rw [zero_add]; field_simp
    rw [h1]
    exact hU.preimage (continuous_id.div_const c)

/-! ### The frame-level forms -/

/-- The real line as a temporal order, for this frame's duration type. Named `metricRealOrder`
rather than `realOrder` for the reason recorded at
`StateTopology/Counterexamples.lean`'s `TwoOrigins.twoOriginRealOrder`. -/
noncomputable abbrev metricRealOrder : TemporalOrder := TemporalOrder.of ℝ

/-- **The metric frame.** The object "the metric frame" names throughout the topology development,
finally declared. -/
@[reducible] noncomputable def frame (c : ℝ) : FrameOver metricRealOrder where
  WorldState := ℝ
  worldNonempty := ⟨0⟩
  PosRel w x u := rel c w (x : ℝ) u

theorem frame_taskRel_eq : (frame c).TaskRel = rel c :=
  TaskFrame.reflect_eq_of_reflective (rel c) (rel_reflection c)

theorem frame_serial (hc : 0 ≤ c) : Serial (frame c).TaskRel := by
  rw [frame_taskRel_eq]; exact rel_serial c hc

theorem frame_compositional (hc : 0 < c) : Compositional (frame c).TaskRel := by
  rw [frame_taskRel_eq]; exact rel_compositional c hc

theorem frame_limit (hc : 0 < c) : TaskFrame.Limit (frame c).TaskRel := by
  rw [frame_taskRel_eq]; exact rel_limit c hc

theorem frame_saturation : TaskFrame.Saturation (frame c).TaskRel := by
  rw [frame_taskRel_eq]; exact rel_saturation c

/-- **The metric frame is a *regular* frame at every positive speed** — a genuine `def:frame` task
frame, with all four constraints proved.

Stated as a plain theorem rather than an `instance` because the positivity hypothesis cannot be
synthesised; `instMetricFrameOneIsRegular` below pins the unit-speed case for synthesis.

Paper: `def:frame`
-/
theorem isRegular (hc : 0 < c) : (frame c).IsRegular where
  comp := frame_compositional c hc
  serial := frame_serial c hc.le
  limit := frame_limit c hc
  saturation := frame_saturation c

/-- The unit-speed metric frame, as an `FrameOver.IsRegular` instance. -/
instance instMetricFrameOneIsRegular : (frame 1).IsRegular := isRegular 1 one_pos

end MetricFrame
end FormalSystem.Semantics.StateTopology
