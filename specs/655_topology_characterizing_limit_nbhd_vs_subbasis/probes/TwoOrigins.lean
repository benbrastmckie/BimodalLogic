import Mathlib.Topology.Separation.Basic
import Mathlib.Topology.Order
import Mathlib.Topology.MetricSpace.Basic
import FormalSystem.Semantics.TaskFrame

/-!
# Probe: the half-line with two origins — `𝒩_F` is T1 but **not Hausdorff** on a frame
satisfying *Compositionality*, *Seriality* and *Limit*

`W = {o true, o false} ∪ {p t : t > 0}`, `D = ℝ`. Both origins loop at every duration; an origin
reaches `p t` in any duration `x ≥ t`; the ray drifts forward at speed at most `1`
(`p t ⇒_x p s` iff `t ≤ s ≤ t + x`); negative durations by reflection. Then

* `RTO_serial`, `RTO_compositional`, `RTO_limit` — three of `def:frame`'s four axioms hold
  (*Saturation* is argued in the report via the "shadow" map `W → [0, ∞)`, UNVERIFIED here);
* `t1Space_nbhdTopology_RTO` — `𝒩_F` is T1 (from *Limit*, via `t1Space_nbhdTopology_iff_limit`);
* `not_t2Space_nbhdTopology_RTO` — `𝒩_F` is **not Hausdorff**: every neighbourhood of either
  origin contains `p t` for all small `t`.

The two origins are distinct states (*Limit* holds, no instantaneous transition between them)
whose short-task futures overlap at every scale: that is what "T1 but not Hausdorff" means for
the space of world states.
-/

open Topology TopologicalSpace Set

set_option warn.classDefReducibility false

namespace FormalSystem.Semantics.TaskFrame

-- Restated verbatim from `NbhdTopology.lean`, specialised to `D = ℝ` (kept standalone).
def Limit' {W : Type} (R : W → ℝ → W → Prop) : Prop :=
  ∀ w u, (∀ x : ℝ, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w

def nbhdTopology' {W : Type} (R : W → ℝ → W → Prop) : TopologicalSpace W where
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

theorem t1Space_nbhdTopology_iff_limit' {W : Type} (R : W → ℝ → W → Prop) :
    @T1Space W (nbhdTopology' R) ↔ Limit' R := by
  letI := nbhdTopology' R
  constructor
  · intro h w u hwu
    haveI := h
    by_contra hne
    have hopen : IsOpen ({u}ᶜ : Set W) := isOpen_compl_singleton
    obtain ⟨x, hx, hc⟩ := hopen w (fun h => hne (Set.mem_singleton_iff.mp h).symm)
    exact hc (hwu x hx) rfl
  · intro hlim
    refine ⟨fun u => ?_⟩
    rw [← isOpen_compl_iff]
    intro w hw
    have hnot : ¬ ∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u :=
      fun hh => hw (Set.mem_singleton_iff.mpr (hlim w u hh).symm)
    push Not at hnot
    obtain ⟨x, hx, hnx⟩ := hnot
    refine ⟨x, hx, fun v hv hvu => ?_⟩
    obtain ⟨y, hy, hR⟩ := hv
    rw [Set.mem_singleton_iff] at hvu
    subst hvu
    exact hnx y hy hR

/-! ## The frame -/

/-- The half-line with two origins. -/
inductive TO
  | o (b : Bool)
  | p (t : {t : ℝ // 0 < t})

open TO

/-- The task relation: origins loop at every duration; `o b ⇒_x p t` iff `t ≤ x`; the ray
drifts forward at speed at most `1`; negative durations by reflection. -/
def RTO : TO → ℝ → TO → Prop
  | o b, _, o b' => b = b'
  | o _, x, p t => t.1 ≤ x
  | p t, x, o _ => t.1 ≤ -x
  | p t, x, p s => (0 ≤ x ∧ t.1 ≤ s.1 ∧ s.1 ≤ t.1 + x) ∨ (x < 0 ∧ s.1 ≤ t.1 ∧ t.1 ≤ s.1 - x)

theorem RTO_refl (w : TO) (x : ℝ) (hx : 0 ≤ x) : RTO w x w := by
  cases w with
  | o b => exact rfl
  | p t => exact Or.inl ⟨hx, le_rfl, by linarith⟩

theorem RTO_serial : Serial RTO := by
  intro w x hx
  exact ⟨⟨w, RTO_refl w x hx⟩, ⟨w, RTO_refl w x hx⟩⟩

theorem RTO_compositional : Compositional RTO := by
  intro w v x y hx hy
  cases w with
  | o b =>
    cases v with
    | o b' =>
      constructor
      · intro h; exact ⟨o b, rfl, h⟩
      · rintro ⟨u, hu, huv⟩
        cases u with
        | o b'' => exact (hu : b = b'').trans huv
        | p t => exact absurd huv (show ¬ (t.1 ≤ -y) by intro h; linarith [t.2])
    | p s =>
      constructor
      · intro h
        change s.1 ≤ x + y at h
        rcases le_or_gt s.1 y with hs | hs
        · exact ⟨o b, rfl, hs⟩
        · refine ⟨p ⟨s.1 - y, by linarith⟩, ?_, Or.inl ⟨hy, by simp; linarith, by simp⟩⟩
          change s.1 - y ≤ x; linarith
      · rintro ⟨u, hu, huv⟩
        change s.1 ≤ x + y
        cases u with
        | o b'' => change s.1 ≤ y at huv; linarith
        | p t =>
          change t.1 ≤ x at hu
          rcases huv with ⟨_, _, h3⟩ | ⟨h1, _, _⟩
          · linarith
          · linarith
  | p t =>
    cases v with
    | o b' =>
      constructor
      · intro h; exact absurd h (show ¬ (t.1 ≤ -(x + y)) by intro h; linarith [t.2])
      · rintro ⟨u, hu, huv⟩
        cases u with
        | o b'' => exact absurd hu (show ¬ (t.1 ≤ -x) by intro h; linarith [t.2])
        | p r => exact absurd huv (show ¬ (r.1 ≤ -y) by intro h; linarith [r.2])
    | p s =>
      constructor
      · intro h
        rcases h with ⟨_, h2, h3⟩ | ⟨h1, _, _⟩
        · refine ⟨p ⟨min s.1 (t.1 + x), lt_min s.2 (by linarith [t.2])⟩,
            Or.inl ⟨hx, le_min h2 (by linarith), min_le_right _ _⟩,
            Or.inl ⟨hy, min_le_left _ _, ?_⟩⟩
          rcases min_choice s.1 (t.1 + x) with hm | hm <;> simp only [hm] <;> linarith
        · exact absurd h1 (by linarith)
      · rintro ⟨u, hu, huv⟩
        cases u with
        | o b'' => exact absurd hu (show ¬ (t.1 ≤ -x) by intro h; linarith [t.2])
        | p r =>
          rcases hu with ⟨_, h2, h3⟩ | ⟨h1, _, _⟩
          · rcases huv with ⟨_, h2', h3'⟩ | ⟨h1', _, _⟩
            · exact Or.inl ⟨by linarith, by linarith, by linarith⟩
            · exact absurd h1' (by linarith)
          · exact absurd h1 (by linarith)

/-- *Limit* holds: the two origins are not instantaneously connected, and the ray is metric. -/
theorem RTO_limit : Limit' RTO := by
  intro w u h
  cases w with
  | o b =>
    cases u with
    | o b' => obtain ⟨_, _, hR⟩ := h 1 one_pos; exact congrArg o (hR : b = b').symm
    | p t =>
      obtain ⟨y, hy, hR⟩ := h t.1 t.2
      change t.1 ≤ y at hR
      exact absurd (abs_lt.mp hy).2 (by linarith)
  | p t =>
    cases u with
    | o b =>
      obtain ⟨y, hy, hR⟩ := h t.1 t.2
      change t.1 ≤ -y at hR
      exact absurd (abs_lt.mp hy).1 (by linarith)
    | p s =>
      have hst : ∀ x : ℝ, 0 < x → |s.1 - t.1| < x := by
        intro x hx
        obtain ⟨y, hy, hR⟩ := h x hx
        rcases hR with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
        · rw [abs_of_nonneg h1] at hy; rw [abs_of_nonneg (by linarith)]; linarith
        · rw [abs_of_neg h1] at hy; rw [abs_of_nonpos (by linarith)]; linarith
      have : |s.1 - t.1| = 0 := by
        by_contra hne
        have hpos : 0 < |s.1 - t.1| := lt_of_le_of_ne (abs_nonneg _) (Ne.symm hne)
        exact lt_irrefl _ (hst _ hpos)
      rw [abs_eq_zero, sub_eq_zero] at this
      exact congrArg p (Subtype.ext this)

/-! ## `𝒩_F` is T1 but not Hausdorff -/

theorem t1Space_nbhdTopology_RTO : @T1Space TO (nbhdTopology' RTO) :=
  (t1Space_nbhdTopology_iff_limit' RTO).mpr RTO_limit

/-- Every positive cone at an origin contains the whole initial segment of the ray. -/
theorem mem_cone_origin (b : Bool) {x : ℝ} (t : {t : ℝ // 0 < t}) (ht : t.1 < x) :
    p t ∈ cone RTO (o b) x :=
  ⟨t.1, by rw [abs_of_pos t.2]; exact ht, show t.1 ≤ t.1 from le_rfl⟩

/-- **`𝒩_F` is not Hausdorff**: any two open sets containing the two origins meet on the ray. -/
theorem not_t2Space_nbhdTopology_RTO : ¬ @T2Space TO (nbhdTopology' RTO) := by
  intro h
  letI := nbhdTopology' RTO
  obtain ⟨U, V, hU, hV, hoU, hoV, hd⟩ := h.t2 (show o true ≠ o false by simp)
  obtain ⟨x, hx, hcU⟩ := hU _ hoU
  obtain ⟨x', hx', hcV⟩ := hV _ hoV
  set t : {t : ℝ // 0 < t} := ⟨min x x' / 2, by positivity⟩
  have htU : p t ∈ U := hcU (mem_cone_origin true t (by
    show min x x' / 2 < x; linarith [min_le_left x x', min_le_right x x', lt_min hx hx']))
  have htV : p t ∈ V := hcV (mem_cone_origin false t (by
    show min x x' / 2 < x'; linarith [min_le_left x x', min_le_right x x', lt_min hx hx']))
  exact Set.disjoint_left.mp hd htU htV

end FormalSystem.Semantics.TaskFrame
