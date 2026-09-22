import Mathlib.Topology.Separation.Basic
import Mathlib.Topology.Order
import Mathlib.Topology.Order.Basic
import Mathlib.Topology.MetricSpace.Basic
import FormalSystem.Semantics.TaskFrame

/-!
# Probe: the four-state funnel — `𝒯_F` is T1 (indeed discrete) while *Limit* fails

`W = Fin 4`, any densely ordered `D`; for `x > 0`, `w ⇒_x u` iff `w = u` or `w ∈ {0,1}` and
`u ∈ {2,3}`; `⇒_0 = id`; extended by the reflection convention. Verified here:

* `R4_compositional`, `R4_serial`, `R4_saturation` — three of `def:frame`'s four axioms hold;
* `R4_not_limit` — *Limit* fails (`2 ∈ (0)_x` for every `x > 0`);
* `discreteTopology_coneTopology_R4` — `𝒯_F` is discrete, hence T1: the converse of
  `app:topology-t1` fails;
* `nbhdTopology_R4_eq_top` — `𝒩_F` is indiscrete, hence not T1, as `t1Space_nbhdTopology_iff_limit`
  predicts;
* `not_isOpen_cone_R4` — the cone `(0)_x` is not `𝒩_F`-open: cones need not be `𝒩_F`-open;
* `not_noOneWay_R4` — the funnel is a one-way instantaneous pair (`0 ⇒_y 2` for all small `y > 0`,
  never `2 ⇒_y 0`), the configuration `limit_of_t1Space_coneTopology` says must be present.

Only the probe `NbhdTopology.lean` is needed for the topology definitions; it is inlined by
`import`-free copy below to keep this file standalone against the library.
-/

open Topology TopologicalSpace Set

set_option warn.classDefReducibility false

namespace FormalSystem.Semantics.TaskFrame

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

-- The two topologies, restated verbatim from `NbhdTopology.lean` (kept standalone).
local notation "Cone" => cone

theorem exists_pos_duration' : ∃ x : D, 0 < x := by
  obtain ⟨a, ha⟩ := exists_ne (0 : D)
  rcases lt_or_gt_of_ne ha with hlt | hgt
  · exact ⟨-a, neg_pos.mpr hlt⟩
  · exact ⟨a, hgt⟩

def Limit' {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w

def coneTopology' {W : Type} (R : W → D → W → Prop) : TopologicalSpace W :=
  generateFrom {s | ∃ w x, 0 < x ∧ s = cone R w x}

def nbhdTopology' {W : Type} (R : W → D → W → Prop) : TopologicalSpace W where
  IsOpen O := ∀ w ∈ O, ∃ x, 0 < x ∧ cone R w x ⊆ O
  isOpen_univ := fun _ _ =>
    let ⟨x, hx⟩ := exists_pos_duration' (D := D); ⟨x, hx, subset_univ _⟩
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

/-! ## The frame -/

/-- The four-state funnel relation: `⇒_0 = id`; for `x > 0`, `w ⇒_x u` iff `w = u` or
`w ∈ {0,1}` and `u ∈ {2,3}`; for `x < 0` the reflection of the latter. -/
def R4 (w : Fin 4) (x : D) (u : Fin 4) : Prop :=
  (x = 0 ∧ w = u) ∨ (0 < x ∧ (w = u ∨ (w.val < 2 ∧ 2 ≤ u.val))) ∨
    (x < 0 ∧ (w = u ∨ (u.val < 2 ∧ 2 ≤ w.val)))

omit [IsOrderedAddMonoid D] [Nontrivial D] in
theorem R4_zero {w u : Fin 4} : R4 w (0 : D) u ↔ w = u := by
  simp [R4]

omit [IsOrderedAddMonoid D] [Nontrivial D] in
theorem R4_pos {w u : Fin 4} {x : D} (hx : 0 < x) :
    R4 w x u ↔ (w = u ∨ (w.val < 2 ∧ 2 ≤ u.val)) := by
  simp [R4, hx.ne', hx, not_lt.mpr hx.le]

omit [IsOrderedAddMonoid D] [Nontrivial D] in
theorem R4_neg {w u : Fin 4} {x : D} (hx : x < 0) :
    R4 w x u ↔ (w = u ∨ (u.val < 2 ∧ 2 ≤ w.val)) := by
  simp [R4, hx.ne, hx, not_lt.mpr hx.le]

omit [IsOrderedAddMonoid D] [Nontrivial D] in
theorem R4_refl (w : Fin 4) (x : D) : R4 w x w := by
  rcases lt_trichotomy x 0 with h | h | h
  · exact (R4_neg h).mpr (Or.inl rfl)
  · subst h; exact R4_zero.mpr rfl
  · exact (R4_pos h).mpr (Or.inl rfl)

omit [Nontrivial D] in
/-- The reflection law holds for `R4` at every duration (including zero). -/
theorem R4_reflection {w u : Fin 4} {x : D} (h : R4 w x u) : R4 u (-x) w := by
  rcases lt_trichotomy x 0 with hx | hx | hx
  · rw [R4_neg hx] at h
    rw [R4_pos (neg_pos.mpr hx)]
    rcases h with h | h
    · exact Or.inl h.symm
    · exact Or.inr h
  · subst hx; rw [neg_zero, R4_zero] at *; exact h.symm
  · rw [R4_pos hx] at h
    rw [R4_neg (neg_neg_iff_pos.mpr hx)]
    rcases h with h | h
    · exact Or.inl h.symm
    · exact Or.inr h

omit [IsOrderedAddMonoid D] [Nontrivial D] in
theorem R4_serial : Serial (R4 (D := D)) :=
  fun w x _ => ⟨⟨w, R4_refl w x⟩, ⟨w, R4_refl w x⟩⟩

omit [Nontrivial D] in
/-- *Compositionality*, both halves, for `R4`. -/
theorem R4_compositional : Compositional (R4 (D := D)) := by
  intro w v x y hx hy
  rcases eq_or_lt_of_le hx with hx0 | hxpos
  · subst hx0
    rw [zero_add]
    constructor
    · intro h; exact ⟨w, R4_zero.mpr rfl, h⟩
    · rintro ⟨u, hu, huv⟩; rw [R4_zero] at hu; subst hu; exact huv
  rcases eq_or_lt_of_le hy with hy0 | hypos
  · subst hy0
    rw [add_zero]
    constructor
    · intro h; exact ⟨v, h, R4_zero.mpr rfl⟩
    · rintro ⟨u, hu, huv⟩; rw [R4_zero] at huv; subst huv; exact hu
  simp only [R4_pos hxpos, R4_pos hypos, R4_pos (add_pos hxpos hypos)]
  revert w v
  decide

omit [IsOrderedAddMonoid D] [Nontrivial D] in
theorem R4_saturation : Saturation (R4 (D := D)) :=
  saturation_of_finite _

/-! ## Cones -/

omit [Nontrivial D] in
/-- Over a dense `D`, membership in a positive cone of `R4` is the symmetric funnel relation. -/
theorem mem_cone_R4 [DenselyOrdered D] {w u : Fin 4} {x : D} (hx : 0 < x) :
    u ∈ cone R4 w x ↔ (w = u ∨ (w.val < 2 ∧ 2 ≤ u.val) ∨ (u.val < 2 ∧ 2 ≤ w.val)) := by
  constructor
  · rintro ⟨y, _, hR⟩
    rw [mem_Fib] at hR
    rcases lt_trichotomy y 0 with hy | hy | hy
    · rw [R4_neg hy] at hR; tauto
    · subst hy; rw [R4_zero] at hR; exact Or.inl hR
    · rw [R4_pos hy] at hR; tauto
  · intro h
    obtain ⟨y, hy0, hyx⟩ := exists_between hx
    rcases h with h | h | h
    · exact ⟨0, by rw [abs_zero]; exact hx, R4_zero.mpr h⟩
    · exact ⟨y, by rw [abs_of_pos hy0]; exact hyx, (R4_pos hy0).mpr (Or.inr h)⟩
    · exact ⟨-y, by rw [abs_neg, abs_of_pos hy0]; exact hyx,
        (R4_neg (neg_neg_iff_pos.mpr hy0)).mpr (Or.inr h)⟩

omit [Nontrivial D] in
/-- **Limit fails**: `2 ∈ (0)_x` for every `x > 0`, yet `2 ≠ 0`. -/
theorem R4_not_limit [DenselyOrdered D] : ¬ Limit' (R4 (D := D)) := by
  intro h
  have := h 0 2 fun x hx => (mem_cone_R4 hx).mpr (Or.inr (Or.inl (by decide)))
  exact absurd this (by decide)

/-! ## `𝒯_F` is discrete -/

omit [Nontrivial D] in
/-- Each singleton is the finite intersection of the cones centred at the members of the cone
at that point: `{w} = ⋂_{v ∈ (w)_x} (v)_x`. -/
theorem singleton_eq_biInter_cone_R4 [DenselyOrdered D] (w : Fin 4) {x : D} (hx : 0 < x) :
    ({w} : Set (Fin 4)) = ⋂ v ∈ cone R4 w x, cone R4 v x := by
  ext u
  simp only [Set.mem_singleton_iff, Set.mem_iInter, mem_cone_R4 hx]
  revert u w
  decide

/-- **`𝒯_F` is discrete** on the four-state funnel — hence T1, although *Limit* fails. -/
theorem discreteTopology_coneTopology_R4 [DenselyOrdered D] :
    @DiscreteTopology (Fin 4) (coneTopology' (R4 (D := D))) := by
  letI := coneTopology' (R4 (D := D))
  rw [discreteTopology_iff_isOpen_singleton]
  intro w
  obtain ⟨x, hx⟩ := exists_pos_duration' (D := D)
  rw [singleton_eq_biInter_cone_R4 w hx]
  exact (cone R4 w x).toFinite.isOpen_biInter fun v _ =>
    isOpen_generateFrom_of_mem ⟨v, x, hx, rfl⟩

theorem t1Space_coneTopology_R4 [DenselyOrdered D] :
    @T1Space (Fin 4) (coneTopology' (R4 (D := D))) := by
  letI := coneTopology' (R4 (D := D))
  haveI := discreteTopology_coneTopology_R4 (D := D)
  infer_instance

/-! ## `𝒩_F` is indiscrete -/

/-- **`𝒩_F` is indiscrete** on the four-state funnel: `0`'s cones drag in `2` and `3`, whose
cones drag in `0` and `1`; every nonempty `𝒩_F`-open set is everything. -/
theorem nbhdTopology_R4_eq_top [DenselyOrdered D] :
    nbhdTopology' (R4 (D := D)) = ⊤ := by
  apply TopologicalSpace.ext
  funext O
  apply propext
  rw [isOpen_top_iff]
  change (∀ w ∈ O, ∃ x, 0 < x ∧ cone R4 w x ⊆ O) ↔ _
  constructor
  · intro h
    by_cases hO : O = ∅
    · exact Or.inl hO
    · right
      obtain ⟨w, hw⟩ := Set.nonempty_iff_ne_empty.mpr hO
      have step : ∀ w ∈ O, ∀ u : Fin 4,
          (w.val < 2 ∧ 2 ≤ u.val) ∨ (u.val < 2 ∧ 2 ≤ w.val) → u ∈ O := by
        intro w hw u hu
        obtain ⟨x, hx, hc⟩ := h w hw
        exact hc ((mem_cone_R4 hx).mpr (Or.inr hu))
      have h02 : ∀ a ∈ O, a.val < 2 → (2 : Fin 4) ∈ O ∧ (3 : Fin 4) ∈ O := fun a ha h =>
        ⟨step a ha 2 (Or.inl ⟨h, by decide⟩), step a ha 3 (Or.inl ⟨h, by decide⟩)⟩
      have h20 : ∀ a ∈ O, 2 ≤ a.val → (0 : Fin 4) ∈ O ∧ (1 : Fin 4) ∈ O := fun a ha h =>
        ⟨step a ha 0 (Or.inr ⟨by decide, h⟩), step a ha 1 (Or.inr ⟨by decide, h⟩)⟩
      have hboth : ((0 : Fin 4) ∈ O ∧ (1 : Fin 4) ∈ O) ∧ ((2 : Fin 4) ∈ O ∧ (3 : Fin 4) ∈ O) := by
        rcases lt_or_ge w.val 2 with hlt | hge
        · have h23 := h02 w hw hlt
          exact ⟨h20 2 h23.1 (by decide), h23⟩
        · have h01 := h20 w hw hge
          exact ⟨h01, h02 0 h01.1 (by decide)⟩
      refine Set.eq_univ_iff_forall.mpr fun u => ?_
      match u with
      | 0 => exact hboth.1.1
      | 1 => exact hboth.1.2
      | 2 => exact hboth.2.1
      | 3 => exact hboth.2.2
  · rintro (rfl | rfl)
    · intro w hw; exact absurd hw (Set.notMem_empty w)
    · intro w _
      obtain ⟨x, hx⟩ := exists_pos_duration' (D := D)
      exact ⟨x, hx, subset_univ _⟩

/-- **`𝒩_F` is not T1** on the four-state funnel, as `t1Space_nbhdTopology_iff_limit` predicts. -/
theorem not_t1Space_nbhdTopology_R4 [DenselyOrdered D] :
    ¬ @T1Space (Fin 4) (nbhdTopology' (R4 (D := D))) := by
  intro h
  rw [nbhdTopology_R4_eq_top] at h
  have := @isOpen_compl_singleton (Fin 4) ⊤ h 0
  rw [isOpen_top_iff] at this
  rcases this with h1 | h1
  · have h1' : (1 : Fin 4) ∈ ({(0 : Fin 4)}ᶜ : Set (Fin 4)) := by simp
    rw [h1] at h1'
    exact absurd h1' (Set.notMem_empty _)
  · have h0 : (0 : Fin 4) ∈ ({(0 : Fin 4)}ᶜ : Set (Fin 4)) := by rw [h1]; trivial
    exact h0 rfl

/-- **Cones need not be `𝒩_F`-open**: `(0)_x = {0, 2, 3}` is neither empty nor everything. -/
theorem not_isOpen_cone_R4 [DenselyOrdered D] {x : D} (hx : 0 < x) :
    ¬ IsOpen[nbhdTopology' (R4 (D := D))] (cone R4 (0 : Fin 4) x) := by
  rw [nbhdTopology_R4_eq_top, isOpen_top_iff]
  rintro (h | h)
  · have h0 : (0 : Fin 4) ∈ cone R4 (0 : Fin 4) x := (mem_cone_R4 hx).mpr (Or.inl rfl)
    rw [h] at h0
    exact absurd h0 (Set.notMem_empty _)
  · have h1 : (1 : Fin 4) ∈ cone R4 (0 : Fin 4) x := by rw [h]; trivial
    rw [mem_cone_R4 hx] at h1
    revert h1; decide

/-! ## The funnel is a one-way instantaneous pair -/

def QuickFwd' {W : Type} (R : W → D → W → Prop) (w u : W) : Prop :=
  ∀ x, 0 < x → ∃ y, 0 ≤ y ∧ y < x ∧ R w y u

/-- `0 ⇒_y 2` for arbitrarily small `y ≥ 0`, but never `2 ⇒_y 0` for `y ≥ 0`: a one-way
instantaneous pair, exactly the configuration `limit_of_t1Space_coneTopology` says must be
present whenever `𝒯_F` is T1 and *Limit* fails. -/
theorem not_noOneWay_R4 [DenselyOrdered D] :
    QuickFwd' (R4 (D := D)) 0 2 ∧ ¬ QuickFwd' (R4 (D := D)) 2 0 := by
  constructor
  · intro x hx
    obtain ⟨y, hy0, hyx⟩ := exists_between hx
    exact ⟨y, hy0.le, hyx, (R4_pos hy0).mpr (Or.inr ⟨by decide, by decide⟩)⟩
  · intro h
    obtain ⟨x, hx⟩ := exists_pos_duration' (D := D)
    obtain ⟨y, hy0, _, hR⟩ := h x hx
    rcases eq_or_lt_of_le hy0 with hy | hy
    · subst hy; rw [R4_zero] at hR; exact absurd hR (by decide)
    · rw [R4_pos hy] at hR; revert hR; decide

/-! ## Histories over the funnel

A history over `R4` is constant on a down-set of low states and on the complementary up-set of
high states (`R4_history_low_past`, `R4_history_high_future`). The separation property `sep`
of `ShiftSet.lean` (`σ = y·τ` for arbitrarily small `|y|` implies `σ = τ`) therefore holds on
the funnel's histories although *Limit* fails (`R4_sep`): so `rev_sep` is genuinely one-way.
The proof uses neither density nor an Archimedean order — only that a shift-invariance set of a
funnel history is convex (`R4_history_invariant_of_le`). -/

def IsHistory' {W : Type} (R : W → D → W → Prop) (τ : D → W) : Prop :=
  ∀ x y, R (τ x) (y - x) (τ y)

omit [Nontrivial D] in
/-- A low state persists into the past: if `σ t` is low then `σ s = σ t` for all `s ≤ t`. -/
theorem R4_history_low_past {σ : D → Fin 4} (hσ : IsHistory' R4 σ) {s t : D} (hst : s ≤ t)
    (hlow : (σ t).val < 2) : σ s = σ t := by
  have h := hσ s t
  rcases eq_or_lt_of_le hst with rfl | hlt
  · rfl
  · rw [R4_pos (sub_pos.mpr hlt)] at h
    rcases h with h | h
    · exact h
    · exact absurd h.2 (not_le.mpr hlow)

omit [Nontrivial D] in
/-- A high state persists into the future: if `σ t` is high then `σ s = σ t` for all `t ≤ s`. -/
theorem R4_history_high_future {σ : D → Fin 4} (hσ : IsHistory' R4 σ) {s t : D} (hts : t ≤ s)
    (hhigh : 2 ≤ (σ t).val) : σ s = σ t := by
  have h := hσ t s
  rcases eq_or_lt_of_le hts with rfl | hlt
  · rfl
  · rw [R4_pos (sub_pos.mpr hlt)] at h
    rcases h with h | h
    · exact h.symm
    · exact absurd h.1 (not_lt.mpr hhigh)

omit [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] in
/-- If two shifts of `σ` agree then `σ` is fixed by their difference. -/
theorem R4_history_shift_fixed {σ : D → Fin 4} {a b : D} (h : ∀ t, σ (t + a) = σ (t + b))
    (u : D) : σ (u + (a - b)) = σ u := by
  have := h (u - b)
  rwa [sub_add_cancel, show u - b + a = u + (a - b) by abel] at this

omit [Nontrivial D] in
/-- The shift-invariance set of a funnel history is convex: invariance under `s ≥ 0` gives
invariance under every `y` with `0 ≤ y ≤ s`. -/
theorem R4_history_invariant_of_le {σ : D → Fin 4} (hσ : IsHistory' R4 σ) {s : D}
    (hs : ∀ u, σ (u + s) = σ u) {y : D} (hy0 : 0 ≤ y) (hys : y ≤ s) (u : D) :
    σ (u + y) = σ u := by
  rcases lt_or_ge (σ u).val 2 with hlow | hhigh
  · have hlow' : (σ (u + s)).val < 2 := by rw [hs u]; exact hlow
    rw [R4_history_low_past hσ ((add_le_add_iff_left u).mpr hys) hlow', hs u]
  · exact R4_history_high_future hσ (le_add_of_nonneg_right hy0) hhigh

/-- **`sep` holds on the funnel's histories although *Limit* fails**: if `τ` is a shift of the
history `σ` by arbitrarily small durations, then `τ = σ`. This is `ShiftSet.sep` for `H_{R4}`;
`rev_sep` (Limit ⟹ sep) is therefore genuinely one-directional. -/
theorem R4_sep {τ σ : D → Fin 4} (hσ : IsHistory' R4 σ)
    (h : ∀ x : D, 0 < x → ∃ y : D, |y| < x ∧ ∀ t, τ t = σ (t + y)) : τ = σ := by
  obtain ⟨x₀, hx₀⟩ := exists_pos_duration' (D := D)
  obtain ⟨y₁, _, hτ₁⟩ := h x₀ hx₀
  by_cases hy₁0 : y₁ = 0
  · subst hy₁0; funext t; rw [hτ₁ t, add_zero]
  obtain ⟨y₂, hy₂, hτ₂⟩ := h |y₁| (abs_pos.mpr hy₁0)
  -- `σ` is fixed by `d := y₁ - y₂ ≠ 0`, hence by `|d| > 0`.
  have hd : ∀ u, σ (u + (y₁ - y₂)) = σ u :=
    R4_history_shift_fixed (fun t => (hτ₁ t).symm.trans (hτ₂ t))
  have hdne : y₁ - y₂ ≠ 0 := by
    intro h0; rw [sub_eq_zero] at h0; subst h0; exact lt_irrefl _ hy₂
  have hs : ∀ u, σ (u + |y₁ - y₂|) = σ u := by
    intro u
    rcases le_or_gt 0 (y₁ - y₂) with hd0 | hd0
    · rw [abs_of_nonneg hd0]; exact hd u
    · rw [abs_of_neg hd0]
      have := hd (u + -(y₁ - y₂))
      rw [neg_add_cancel_right] at this
      exact this.symm
  -- A shift `y₃` with `|y₃| < |d|` then fixes `σ` by convexity, so `τ = y₃·σ = σ`.
  obtain ⟨y₃, hy₃, hτ₃⟩ := h _ (abs_pos.mpr hdne)
  have hy₃inv : ∀ u, σ (u + y₃) = σ u := by
    intro u
    rcases le_or_gt 0 y₃ with hy0 | hy0
    · rw [abs_of_nonneg hy0] at hy₃
      exact R4_history_invariant_of_le hσ hs hy0 hy₃.le u
    · rw [abs_of_neg hy0] at hy₃
      have := R4_history_invariant_of_le hσ hs (neg_nonneg.mpr hy0.le) hy₃.le (u + y₃)
      rw [add_neg_cancel_right] at this
      exact this.symm
  funext t
  rw [hτ₃ t, hy₃inv t]

/-! ## A history that is not `𝒯_F`-continuous

Over `D = ℝ`, the history "`1` before time `0`, `2` from time `0` on" respects `R4`, but `{2}`
is `𝒯_F`-open (`𝒯_F` is discrete) and its preimage `[0, ∞)` is not open in `ℝ`. Histories are
always `𝒩_F`-continuous (`continuous_nbhdTopology_of_history`); they need not be
`𝒯_F`-continuous. -/

/-- **A funnel history that is not `𝒯_F`-continuous.** -/
theorem not_continuous_coneTopology_R4_history :
    ∃ τ : ℝ → Fin 4, IsHistory' (R4 (D := ℝ)) τ ∧
      ¬ @Continuous ℝ (Fin 4) _ (coneTopology' (R4 (D := ℝ))) τ := by
  refine ⟨fun t => if t < 0 then 1 else 2, ?_, ?_⟩
  · intro x y
    dsimp only
    split_ifs with hx hy hy
    · exact R4_refl _ _
    · exact (R4_pos (by linarith)).mpr (Or.inr ⟨by decide, by decide⟩)
    · exact (R4_neg (by linarith)).mpr (Or.inr ⟨by decide, by decide⟩)
    · exact R4_refl _ _
  · intro hcont
    letI := coneTopology' (R4 (D := ℝ))
    haveI := discreteTopology_coneTopology_R4 (D := ℝ)
    have hpre := hcont.isOpen_preimage ({2} : Set (Fin 4)) (isOpen_discrete _)
    have hpre' : (fun t : ℝ => if t < 0 then (1 : Fin 4) else 2) ⁻¹' ({2} : Set (Fin 4)) =
        Set.Ici 0 := by
      ext t
      simp only [Set.mem_preimage, Set.mem_singleton_iff, Set.mem_Ici]
      split_ifs with ht
      · exact ⟨fun h => absurd h (by decide), fun h => absurd ht (not_lt.mpr h)⟩
      · exact ⟨fun _ => not_lt.mp ht, fun _ => rfl⟩
    rw [hpre', Metric.isOpen_iff] at hpre
    obtain ⟨ε, hε, hb⟩ := hpre 0 (Set.mem_Ici.mpr le_rfl)
    have hmem : -(ε / 2) ∈ Metric.ball (0 : ℝ) ε := by
      rw [Metric.mem_ball, Real.dist_eq, sub_zero, abs_neg, abs_of_pos (half_pos hε)]
      exact half_lt_self hε
    have := hb hmem
    rw [Set.mem_Ici] at this
    linarith

/-! ## Axiom audit: every headline theorem uses only `propext`, `Classical.choice`, `Quot.sound` -/

#print axioms R4_compositional
#print axioms R4_saturation
#print axioms R4_not_limit
#print axioms discreteTopology_coneTopology_R4
#print axioms nbhdTopology_R4_eq_top
#print axioms not_isOpen_cone_R4
#print axioms not_noOneWay_R4
#print axioms R4_sep
#print axioms not_continuous_coneTopology_R4_history

end FormalSystem.Semantics.TaskFrame
