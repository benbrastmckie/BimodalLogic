import Mathlib.Topology.Order.Compact
import Mathlib.Topology.Algebra.Order.Field
import FormalSystem.Semantics.StateTopology

/-!
# Probe: on the metric frame the cone-neighbourhood topology **is** the final topology of all
histories

The metric frame: carrier `ℝ`, `r ⇒_y u` iff `|u - r| ≤ c · |y|` (speed at most `c`).
Its cones are the Euclidean balls, so `𝒩_F` is the usual topology; the straight-line history
`t ↦ r₀ + c · t` is a surjective open map, which forces the final topology of all histories to
collapse onto `𝒩_F`.
-/

open Set Topology

set_option warn.classDefReducibility false

namespace FormalSystem.Semantics.StateTopology
namespace MetricFrame

open FormalSystem.Semantics.TaskFrame

variable {W D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-- **A single surjective open history collapses the final topology onto `𝒩_F`.** This is the
positive half of the open question about `𝒩_F` versus the final topology of all histories: one
history that is surjective and open is enough, and no relation-level condition is needed. -/
theorem finalTopology_eq_of_surjective_open_history [TopologicalSpace D] [OrderTopology D]
    (R : W → D → W → Prop) {τ : D → W} (hτ : IsHistory R τ)
    (hsurj : Function.Surjective τ)
    (hopen : ∀ U : Set D, IsOpen U → IsOpen[nbhdTopology R] (τ '' U)) :
    (⨆ σ : {σ : D → W // IsHistory R σ}, TopologicalSpace.coinduced σ.1 ‹TopologicalSpace D›) =
      nbhdTopology R := by
  refine le_antisymm (finalTopology_le_nbhdTopology R) ?_
  intro O hO
  have hcoin : IsOpen[TopologicalSpace.coinduced τ ‹TopologicalSpace D›] O :=
    le_iSup (fun σ : {σ : D → W // IsHistory R σ} =>
      TopologicalSpace.coinduced σ.1 ‹TopologicalSpace D›) ⟨τ, hτ⟩ O hO
  rw [isOpen_coinduced] at hcoin
  have := hopen _ hcoin
  rwa [Set.image_preimage_eq _ hsurj] at this

/-! ### The metric relation on `ℝ` -/

variable (c : ℝ)

/-- The metric task relation: a task of duration `y` moves at speed at most `c`. -/
def rel (c : ℝ) : ℝ → ℝ → ℝ → Prop := fun r y u => |u - r| ≤ c * |y|

theorem rel_reflection (r y u : ℝ) : rel c r y u ↔ rel c u (-y) r := by
  unfold rel
  rw [abs_neg, ← abs_neg (u - r), neg_sub]

/-- **The metric frame satisfies *Seriality***. -/
theorem rel_serial (hc : 0 ≤ c) : Serial (rel c) := by
  have hself : ∀ w x : ℝ, rel c w x w := by
    intro w x; show |w - w| ≤ c * |x|; simp only [sub_self, abs_zero]; positivity
  intro w x _
  exact ⟨⟨w, hself w x⟩, ⟨w, hself w x⟩⟩

/-- **The metric frame satisfies *Limit***. -/
theorem rel_limit (hc : 0 < c) : TaskFrame.Limit (rel c) := by
  intro w u h
  by_contra hne
  have hpos : 0 < |u - w| := abs_pos.mpr (sub_ne_zero.mpr hne)
  obtain ⟨y, hy, hR⟩ := h (|u - w| / c) (by positivity)
  have h1 : |u - w| ≤ c * |y| := hR
  have h2 : c * |y| < c * (|u - w| / c) := mul_lt_mul_of_pos_left hy hc
  rw [mul_div_cancel₀ _ hc.ne'] at h2
  linarith

/-- **The metric frame satisfies *Compositionality***, both halves: a task of duration `x + y`
splits at the point reached after `x`. -/
theorem rel_compositional (hc : 0 < c) : Compositional (rel c) := by
  intro w v x y hx hy
  constructor
  · intro h
    have hxy : |v - w| ≤ c * x + c * y := by
      have h0 : |v - w| ≤ c * |x + y| := h
      rwa [abs_of_nonneg (by linarith : (0:ℝ) ≤ x + y), mul_add] at h0
    rcases le_or_gt (|v - w|) (c * x) with hle | hgt
    · refine ⟨v, ?_, ?_⟩
      · show |v - w| ≤ c * |x|; rwa [abs_of_nonneg hx]
      · show |v - v| ≤ c * |y|; simp only [sub_self, abs_zero]; positivity
    · have hd : (0 : ℝ) < |v - w| := lt_of_le_of_lt (mul_nonneg hc.le hx) hgt
      refine ⟨w + (c * x / |v - w|) * (v - w), ?_, ?_⟩
      · show |w + (c * x / |v - w|) * (v - w) - w| ≤ c * |x|
        rw [add_sub_cancel_left, abs_mul, abs_of_nonneg (by positivity : (0:ℝ) ≤ c * x / |v - w|),
          div_mul_cancel₀ _ (ne_of_gt hd), abs_of_nonneg hx]
      · show |v - (w + (c * x / |v - w|) * (v - w))| ≤ c * |y|
        have heq : v - (w + (c * x / |v - w|) * (v - w)) = (1 - c * x / |v - w|) * (v - w) := by
          ring
        have hle1 : c * x / |v - w| ≤ 1 := by rw [div_le_one hd]; linarith
        rw [heq, abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ 1 - c * x / |v - w|),
          abs_of_nonneg hy, sub_mul, one_mul, div_mul_cancel₀ _ (ne_of_gt hd)]
        linarith
  · rintro ⟨u, h1, h2⟩
    have e1 : |u - w| ≤ c * |x| := h1
    have e2 : |v - u| ≤ c * |y| := h2
    show |v - w| ≤ c * |x + y|
    have hsum : |v - w| ≤ |v - u| + |u - w| := abs_sub_le v u w
    rw [abs_of_nonneg hx] at e1
    rw [abs_of_nonneg hy] at e2
    rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ x + y), mul_add]
    linarith

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
    · show |u - r| ≤ c * |(|u - r| / c)|
      have habs : |(|u - r| / c)| = |u - r| / c := abs_of_nonneg (by positivity)
      rw [habs, mul_div_cancel₀]
      exact hc.ne'

/-- `𝒩_F` on the metric frame **is** the Euclidean topology. -/
theorem nbhdTopology_eq (hc : 0 < c) :
    nbhdTopology (rel c) = (inferInstance : TopologicalSpace ℝ) :=
  nbhdTopology_eq_real (rel c) hc (cone_eq_ball c hc)

/-- The straight line at full speed is a history. -/
theorem isHistory_line (hc : 0 < c) (r₀ : ℝ) :
    IsHistory (rel c) (fun t => r₀ + c * t) := by
  intro x y
  show |(r₀ + c * y) - (r₀ + c * x)| ≤ c * |y - x|
  rw [show (r₀ + c * y) - (r₀ + c * x) = c * (y - x) by ring, abs_mul,
    abs_of_nonneg (le_of_lt hc)]

/-- **Q3.2 answered: on the metric frame the cone-neighbourhood topology and the final topology
of all histories COINCIDE.** The hedgehog's separation of the two is therefore a feature of
branching, not of the cone construction. -/
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
        show (0 + c * t) / c ∈ U
        rwa [zero_add, mul_div_cancel_left₀ t hc.ne']
      · intro hy
        refine ⟨y / c, hy, ?_⟩
        show 0 + c * (y / c) = y
        rw [zero_add]; field_simp
    rw [h1]
    exact hU.preimage (continuous_id.div_const c)

end MetricFrame
end FormalSystem.Semantics.StateTopology
