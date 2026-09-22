import Mathlib.Topology.Separation.Basic
import Mathlib.Topology.Order
import Mathlib.Topology.MetricSpace.Basic
import FormalSystem.Semantics.TaskFrame

/-!
# Probe: the paper's named frames over `ℝ` — both topologies are the Euclidean topology

For the `ℝ`-metric frame (`r ⇒_x s` iff `|s − r| ≤ x`), the translation frame `𝔉¹` of
`app:drift`/`cor:no-characterization` (`r ⇒_x s` iff `s = r + x`), and the drift frame `𝔉°`
of `app:drift` (`x ≤ s − r ≤ 2x`), every positive cone is a Euclidean ball, so

* `nbhdTopology_eq_real` — `𝒩_F` is the usual topology on `ℝ`;
* `coneTopology_eq_nbhdTopology_real` — `𝒯_F = 𝒩_F` (the cones are open balls);

hence both are T1, R0, **Hausdorff**, and **not discrete** on each of the three frames.
-/

open Topology TopologicalSpace Set

set_option warn.classDefReducibility false

namespace FormalSystem.Semantics.TaskFrame

-- Restated verbatim from `NbhdTopology.lean`, specialised to `D = W = ℝ` (kept standalone).
def coneTopology' (R : ℝ → ℝ → ℝ → Prop) : TopologicalSpace ℝ :=
  generateFrom {s | ∃ w x, 0 < x ∧ s = cone R w x}

def nbhdTopology' (R : ℝ → ℝ → ℝ → Prop) : TopologicalSpace ℝ where
  IsOpen O := ∀ w ∈ O, ∃ x : ℝ, 0 < x ∧ cone R w x ⊆ O
  isOpen_univ := fun _ _ => ⟨1, one_pos, subset_univ _⟩
  isOpen_inter := fun _ _ h₁ h₂ w hw => by
    obtain ⟨x₁, hx₁, hc₁⟩ := h₁ w hw.1
    obtain ⟨x₂, hx₂, hc₂⟩ := h₂ w hw.2
    exact ⟨min x₁ x₂, lt_min hx₁ hx₂,
      subset_inter ((cone_mono R w (min_le_left _ _)).trans hc₁)
        ((cone_mono R w (min_le_right _ _)).trans hc₂)⟩
  isOpen_sUnion := fun S hS w hw => by
    obtain ⟨O, hO, hwO⟩ := mem_sUnion.mp hw
    obtain ⟨x, hx, hc⟩ := hS O hO w hwO
    exact ⟨x, hx, hc.trans (subset_sUnion_of_mem hO)⟩

theorem mem_cone_self' {R : ℝ → ℝ → ℝ → Prop} {w : ℝ} (h0 : R w 0 w) {x : ℝ} (hx : 0 < x) :
    w ∈ cone R w x :=
  ⟨0, by rw [abs_zero]; exact hx, h0⟩

theorem coneTopology_le_nbhdTopology' (R : ℝ → ℝ → ℝ → Prop) (h0 : ∀ w, R w 0 w) :
    coneTopology' R ≤ nbhdTopology' R := by
  rw [TopologicalSpace.le_def]
  intro O hO
  have hO' : O = ⋃₀ {c | (∃ w x, 0 < x ∧ c = cone R w x) ∧ c ⊆ O} := by
    ext v
    constructor
    · intro hv
      obtain ⟨x, hx, hc⟩ := hO v hv
      exact ⟨cone R v x, ⟨⟨v, x, hx, rfl⟩, hc⟩, mem_cone_self' (h0 v) hx⟩
    · rintro ⟨c, ⟨_, hcO⟩, hvc⟩
      exact hcO hvc
  rw [hO']
  letI := coneTopology' R
  exact isOpen_sUnion fun c hc => isOpen_generateFrom_of_mem hc.1

/-! ## Generic: cones that are balls give the Euclidean topology -/

/-- If every positive cone is a Euclidean ball (of radius `c · x`), `𝒩_F` is the usual topology. -/
theorem nbhdTopology_eq_real (R : ℝ → ℝ → ℝ → Prop) {c : ℝ} (hc : 0 < c)
    (hcone : ∀ r x, 0 < x → cone R r x = Metric.ball r (c * x)) :
    nbhdTopology' R = (inferInstance : TopologicalSpace ℝ) := by
  apply TopologicalSpace.ext
  funext O
  apply propext
  rw [Metric.isOpen_iff]
  change (∀ w ∈ O, ∃ x : ℝ, 0 < x ∧ cone R w x ⊆ O) ↔ _
  constructor
  · intro h r hr
    obtain ⟨x, hx, hs⟩ := h r hr
    exact ⟨c * x, mul_pos hc hx, by rw [← hcone r x hx]; exact hs⟩
  · intro h r hr
    obtain ⟨ε, hε, hb⟩ := h r hr
    have hε' : 0 < ε / c := div_pos hε hc
    refine ⟨ε / c, hε', ?_⟩
    rw [hcone r _ hε', mul_div_cancel₀ ε hc.ne']
    exact hb

/-- If every positive cone is a ball and `R r 0 r`, then `𝒯_F = 𝒩_F`. -/
theorem coneTopology_eq_nbhdTopology_real (R : ℝ → ℝ → ℝ → Prop) (h0 : ∀ r, R r 0 r) {c : ℝ}
    (hc : 0 < c) (hcone : ∀ r x, 0 < x → cone R r x = Metric.ball r (c * x)) :
    coneTopology' R = nbhdTopology' R := by
  refine le_antisymm (coneTopology_le_nbhdTopology' R h0) ?_
  rw [coneTopology', le_generateFrom_iff_subset_isOpen]
  rintro s ⟨w, x, hx, rfl⟩
  rw [nbhdTopology_eq_real R hc hcone, hcone w x hx]
  exact (Metric.isOpen_ball : IsOpen (Metric.ball w (c * x)))

/-- The usual topology on `ℝ` is not discrete: `{0}` is not open. -/
theorem not_discreteTopology_real : ¬ DiscreteTopology ℝ := by
  intro h
  have h0 := (discreteTopology_iff_isOpen_singleton.mp h) 0
  rw [Metric.isOpen_iff] at h0
  obtain ⟨ε, hε, hb⟩ := h0 0 rfl
  have hmem : ε / 2 ∈ Metric.ball (0 : ℝ) ε := by
    rw [Metric.mem_ball, Real.dist_eq, sub_zero, abs_of_pos (by linarith)]
    linarith
  have := hb hmem
  rw [Set.mem_singleton_iff] at this
  linarith

/-! ## The `ℝ`-metric frame: `r ⇒_x s` iff `|s − r| ≤ |x|` (reflection built in) -/

def metricRel (r x s : ℝ) : Prop := |s - r| ≤ |x|

theorem metricRel_zero (r : ℝ) : metricRel r 0 r := by simp [metricRel]

theorem cone_metricRel (r : ℝ) {x : ℝ} (_hx : 0 < x) :
    cone metricRel r x = Metric.ball r (1 * x) := by
  ext s
  simp only [mem_cone, metricRel, Metric.mem_ball, Real.dist_eq, one_mul]
  constructor
  · rintro ⟨y, hy, h⟩; exact lt_of_le_of_lt h hy
  · intro h; exact ⟨s - r, h, le_rfl⟩

theorem nbhdTopology_metric : nbhdTopology' metricRel = (inferInstance : TopologicalSpace ℝ) :=
  nbhdTopology_eq_real _ one_pos cone_metricRel

theorem coneTopology_metric : coneTopology' metricRel = nbhdTopology' metricRel :=
  coneTopology_eq_nbhdTopology_real _ metricRel_zero one_pos cone_metricRel

theorem t2Space_nbhd_metric : @T2Space ℝ (nbhdTopology' metricRel) := by
  rw [nbhdTopology_metric]; infer_instance

theorem not_discrete_nbhd_metric : ¬ @DiscreteTopology ℝ (nbhdTopology' metricRel) := by
  rw [nbhdTopology_metric]; exact not_discreteTopology_real

/-! ## The translation frame `𝔉¹`: `r ⇒_x s` iff `s = r + x` -/

def translationRel (r x s : ℝ) : Prop := s = r + x

theorem translationRel_zero (r : ℝ) : translationRel r 0 r := by simp [translationRel]

theorem cone_translationRel (r : ℝ) {x : ℝ} (_hx : 0 < x) :
    cone translationRel r x = Metric.ball r (1 * x) := by
  ext s
  simp only [mem_cone, translationRel, Metric.mem_ball, Real.dist_eq, one_mul]
  constructor
  · rintro ⟨y, hy, rfl⟩; simpa using hy
  · intro h; exact ⟨s - r, h, by ring⟩

theorem nbhdTopology_translation :
    nbhdTopology' translationRel = (inferInstance : TopologicalSpace ℝ) :=
  nbhdTopology_eq_real _ one_pos cone_translationRel

theorem coneTopology_translation : coneTopology' translationRel = nbhdTopology' translationRel :=
  coneTopology_eq_nbhdTopology_real _ translationRel_zero one_pos cone_translationRel

/-! ## The drift frame `𝔉°` of `app:drift`: `x ≤ s − r ≤ 2x` for `x ≥ 0`, reflected for `x < 0` -/

def driftRel (r x s : ℝ) : Prop :=
  (0 ≤ x ∧ x ≤ s - r ∧ s - r ≤ 2 * x) ∨ (x < 0 ∧ 2 * x ≤ s - r ∧ s - r ≤ x)

theorem driftRel_zero (r : ℝ) : driftRel r 0 r := by simp [driftRel]

/-- The reflection law for the drift frame, at every duration. -/
theorem driftRel_reflection {r x s : ℝ} (h : driftRel r x s) : driftRel s (-x) r := by
  unfold driftRel at *
  rcases h with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
  · rcases eq_or_lt_of_le h1 with h1 | h1
    · subst h1; left; constructor <;> [simp; constructor <;> linarith]
    · right; constructor <;> [linarith; constructor <;> linarith]
  · left; constructor <;> [linarith; constructor <;> linarith]

theorem cone_driftRel (r : ℝ) {x : ℝ} (_hx : 0 < x) :
    cone driftRel r x = Metric.ball r (2 * x) := by
  ext s
  simp only [mem_cone, driftRel, Metric.mem_ball, Real.dist_eq]
  constructor
  · rintro ⟨y, hy, ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩⟩
    · rw [abs_of_nonneg h1] at hy
      rw [abs_of_nonneg (by linarith)]; linarith
    · rw [abs_of_neg h1] at hy
      rw [abs_of_nonpos (by linarith)]; linarith
  · intro h
    rcases le_or_gt 0 (s - r) with hd | hd
    · rw [abs_of_nonneg hd] at h
      exact ⟨(s - r) / 2, by rw [abs_of_nonneg (by linarith)]; linarith,
        Or.inl ⟨by linarith, by linarith, by linarith⟩⟩
    · rw [abs_of_neg hd] at h
      exact ⟨(s - r) / 2, by rw [abs_of_neg (by linarith)]; linarith,
        Or.inr ⟨by linarith, by linarith, by linarith⟩⟩

theorem nbhdTopology_drift : nbhdTopology' driftRel = (inferInstance : TopologicalSpace ℝ) :=
  nbhdTopology_eq_real _ two_pos cone_driftRel

theorem coneTopology_drift : coneTopology' driftRel = nbhdTopology' driftRel :=
  coneTopology_eq_nbhdTopology_real _ driftRel_zero two_pos cone_driftRel

end FormalSystem.Semantics.TaskFrame
