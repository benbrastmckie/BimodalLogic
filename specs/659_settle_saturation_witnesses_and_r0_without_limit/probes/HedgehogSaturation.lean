import Mathlib.Topology.Order.Compact
import FormalSystem.Semantics.StateTopology.Counterexamples

/-!
# Probe: *Saturation* for the hedgehog
-/

open Topology TopologicalSpace Set

set_option warn.classDefReducibility false

namespace FormalSystem.Semantics.StateTopology
namespace Hedgehog

open HH FormalSystem.Semantics.TaskFrame

/-- The shadow map `W → [0, ∞)`: the centre goes to `0`, `p n t` goes to `t`. -/
def shadow : HH → ℝ
  | c => 0
  | p _ u => u.1

@[simp] theorem shadow_c : shadow c = 0 := rfl

@[simp] theorem shadow_p (n : ℕ) (u : {t : ℝ // 0 < t}) : shadow (p n u) = u.1 := rfl

/-- A *band*: optionally the centre, together with a real interval on a set of rays. -/
def band (k : Prop) (N : Set ℕ) (a b : ℝ) : Set HH :=
  {w | match w with
       | c => k
       | p n u => n ∈ N ∧ a ≤ u.1 ∧ u.1 ≤ b}

@[simp] theorem c_mem_band {k : Prop} {N : Set ℕ} {a b : ℝ} :
    c ∈ band k N a b ↔ k := Iff.rfl

@[simp] theorem p_mem_band {n : ℕ} {u : {t : ℝ // 0 < t}} {k : Prop} {N : Set ℕ} {a b : ℝ} :
    p n u ∈ band k N a b ↔ n ∈ N ∧ a ≤ u.1 ∧ u.1 ≤ b := Iff.rfl

/-- The invariant every fibre and segment satisfies: the centre is present exactly when the
interval reaches down to `0`. -/
def Good (k : Prop) (a : ℝ) : Prop := (k ∧ a ≤ 0) ∨ (¬ k ∧ 0 < a)

/-- Bands are closed under intersection. -/
theorem band_inter (k₁ k₂ : Prop) (N₁ N₂ : Set ℕ) (a₁ b₁ a₂ b₂ : ℝ) :
    band k₁ N₁ a₁ b₁ ∩ band k₂ N₂ a₂ b₂ =
      band (k₁ ∧ k₂) (N₁ ∩ N₂) (max a₁ a₂) (min b₁ b₂) := by
  ext u
  cases u with
  | c => exact Iff.rfl
  | p n s =>
    simp only [Set.mem_inter_iff, p_mem_band, max_le_iff, le_min_iff]
    constructor
    · rintro ⟨⟨h1, h2, h3⟩, ⟨h4, h5, h6⟩⟩; exact ⟨⟨h1, h4⟩, ⟨h2, h5⟩, h3, h6⟩
    · rintro ⟨⟨h1, h4⟩, ⟨h2, h5⟩, h3, h6⟩; exact ⟨⟨h1, h2, h3⟩, ⟨h4, h5, h6⟩⟩

/-- **Every fibre of the hedgehog relation is a `Good` band on `univ` or on a single ray.** -/
theorem fib_band (w : HH) (x : ℝ) :
    ∃ (k : Prop) (N : Set ℕ) (a b : ℝ),
      Good k a ∧ (N = univ ∨ N.Subsingleton) ∧ Fib rel w x = band k N a b := by
  cases w with
  | c =>
    refine ⟨True, univ, 0, x, Or.inl ⟨trivial, le_rfl⟩, Or.inl rfl, ?_⟩
    ext u
    cases u with
    | c => exact ⟨fun _ => trivial, fun _ => trivial⟩
    | p m s =>
      exact ⟨fun h => ⟨Set.mem_univ m, le_of_lt s.2, show s.1 ≤ x from h⟩,
             fun h => show s.1 ≤ x from h.2.2⟩
  | p n t =>
    rcases le_or_gt 0 x with hx | hx
    · refine ⟨False, {n}, t.1, t.1 + x, Or.inr ⟨not_false, t.2⟩,
        Or.inr (Set.subsingleton_singleton), ?_⟩
      ext u
      cases u with
      | c => exact ⟨fun h => absurd (show t.1 ≤ -x from h) (by linarith [t.2]), False.elim⟩
      | p m s =>
        constructor
        · rintro ⟨rfl, ⟨-, h2, h3⟩ | ⟨h1, -, -⟩⟩
          · exact ⟨rfl, h2, h3⟩
          · linarith
        · rintro ⟨hm, h1, h2⟩
          exact ⟨(Set.mem_singleton_iff.mp hm).symm, Or.inl ⟨hx, h1, h2⟩⟩
    · rcases le_or_gt t.1 (-x) with ht | ht
      · refine ⟨True, {n}, t.1 + x, t.1, Or.inl ⟨trivial, by linarith⟩,
          Or.inr (Set.subsingleton_singleton), ?_⟩
        ext u
        cases u with
        | c => exact ⟨fun _ => trivial, fun _ => show t.1 ≤ -x from ht⟩
        | p m s =>
          constructor
          · rintro ⟨rfl, ⟨h1, -, -⟩ | ⟨-, h2, h3⟩⟩
            · linarith
            · exact ⟨rfl, by linarith, h2⟩
          · rintro ⟨hm, h1, h2⟩
            exact ⟨(Set.mem_singleton_iff.mp hm).symm, Or.inr ⟨hx, h2, by linarith⟩⟩
      · refine ⟨False, {n}, t.1 + x, t.1, Or.inr ⟨not_false, by linarith⟩,
          Or.inr (Set.subsingleton_singleton), ?_⟩
        ext u
        cases u with
        | c => exact ⟨fun h => absurd (show t.1 ≤ -x from h) (by linarith), False.elim⟩
        | p m s =>
          constructor
          · rintro ⟨rfl, ⟨h1, -, -⟩ | ⟨-, h2, h3⟩⟩
            · linarith
            · exact ⟨rfl, by linarith, h2⟩
          · rintro ⟨hm, h1, h2⟩
            exact ⟨(Set.mem_singleton_iff.mp hm).symm, Or.inr ⟨hx, h2, by linarith⟩⟩

/-- **Every fibre and every segment of the hedgehog relation is a `Good` band.** -/
theorem class_band {s : Set HH} (hcls : IsFiber rel s ∨ IsSegment rel s) :
    ∃ (k : Prop) (N : Set ℕ) (a b : ℝ),
      Good k a ∧ (N = univ ∨ N.Subsingleton) ∧ s = band k N a b := by
  rcases hcls with ⟨w, x, rfl⟩ | ⟨w, v, x, y, -, -, rfl⟩
  · exact fib_band w x
  · obtain ⟨k₁, N₁, a₁, b₁, hG₁, hN₁, hE₁⟩ := fib_band w x
    obtain ⟨k₂, N₂, a₂, b₂, hG₂, hN₂, hE₂⟩ := fib_band v (-y)
    refine ⟨k₁ ∧ k₂, N₁ ∩ N₂, max a₁ a₂, min b₁ b₂, ?_, ?_,
      by rw [Seg, hE₁, hE₂, band_inter]⟩
    · rcases hG₁ with ⟨hk₁, ha₁⟩ | ⟨hk₁, ha₁⟩
      · rcases hG₂ with ⟨hk₂, ha₂⟩ | ⟨hk₂, ha₂⟩
        · exact Or.inl ⟨⟨hk₁, hk₂⟩, max_le ha₁ ha₂⟩
        · exact Or.inr ⟨fun h => hk₂ h.2, lt_of_lt_of_le ha₂ (le_max_right _ _)⟩
      · exact Or.inr ⟨fun h => hk₁ h.1, lt_of_lt_of_le ha₁ (le_max_left _ _)⟩
    · rcases hN₁ with rfl | hs₁
      · rcases hN₂ with rfl | hs₂
        · exact Or.inl (by simp)
        · exact Or.inr (hs₂.anti Set.inter_subset_right)
      · exact Or.inr (hs₁.anti Set.inter_subset_left)

/-- Every nonempty fibre or segment has a closed bounded shadow. -/
theorem shadow_isIcc {s : Set HH} (hcls : IsFiber rel s ∨ IsSegment rel s) (hne : s.Nonempty) :
    ∃ a' b', shadow '' s = Icc a' b' := by
  obtain ⟨k, N, a, b, hG, -, rfl⟩ := class_band hcls
  rcases Set.eq_empty_or_nonempty N with rfl | ⟨n, hn⟩
  · -- No rays survive: the band is `{c}` (it is nonempty, so the centre is present).
    refine ⟨0, 0, ?_⟩
    have hk : k := by
      obtain ⟨w, hw⟩ := hne
      cases w with
      | c => exact hw
      | p m s => exact absurd (p_mem_band.mp hw).1 (by simp)
    ext r
    constructor
    · rintro ⟨w, hw, rfl⟩
      cases w with
      | c => simp
      | p m s => exact absurd (p_mem_band.mp hw).1 (by simp)
    · intro hr
      rw [Set.mem_Icc] at hr
      exact ⟨c, hk, by simp [le_antisymm hr.2 hr.1]⟩
  · refine ⟨max a 0, max b 0, ?_⟩
    ext r
    constructor
    · rintro ⟨w, hw, rfl⟩
      cases w with
      | c =>
        rcases hG with ⟨-, ha⟩ | ⟨hk, -⟩
        · exact ⟨by simp [max_eq_right ha], by simp⟩
        · exact absurd (c_mem_band.mp hw) hk
      | p m s =>
        obtain ⟨-, h1, h2⟩ := p_mem_band.mp hw
        exact ⟨max_le h1 (le_of_lt s.2), le_trans h2 (le_max_left _ _)⟩
    · rintro ⟨h1, h2⟩
      have hb : 0 < r → r ≤ b := by
        intro h0
        rcases le_or_gt b 0 with hbn | hbp
        · rw [max_eq_right hbn] at h2; linarith
        · rw [max_eq_left (le_of_lt hbp)] at h2; exact h2
      rcases hG with ⟨hk, ha⟩ | ⟨hk, ha⟩
      · rw [max_eq_right ha] at h1
        rcases eq_or_lt_of_le h1 with h0 | h0
        · exact ⟨c, hk, by simp [h0.symm]⟩
        · exact ⟨p n ⟨r, h0⟩, ⟨hn, le_trans ha (le_of_lt h0), hb h0⟩, rfl⟩
      · rw [max_eq_left (le_of_lt ha)] at h1
        have h0 : 0 < r := lt_of_lt_of_le ha h1
        exact ⟨p n ⟨r, h0⟩, ⟨hn, h1, hb h0⟩, rfl⟩

/-- Directedness plus "each member's ray scope is `univ` or a singleton" picks a common ray. -/
theorem common_ray {S : Set (Set HH)} (u : {t : ℝ // 0 < t})
    (hdirS : ∀ s₁ ∈ S, ∀ s₂ ∈ S, ∃ s' ∈ S, s' ⊆ s₁ ∩ s₂)
    (hA : ∀ s ∈ S, ∃ n, p n u ∈ s)
    (hone : ∀ s ∈ S, ∀ n m, p n u ∈ s → p m u ∈ s → n = m ∨ ∀ j, p j u ∈ s) :
    ∃ n, ∀ s ∈ S, p n u ∈ s := by
  by_cases hall : ∀ s ∈ S, ∀ j, p j u ∈ s
  · exact ⟨0, fun s hs => hall s hs 0⟩
  · push Not at hall
    obtain ⟨s₀, hs₀, j₀, hj₀⟩ := hall
    obtain ⟨n₀, hn₀⟩ := hA s₀ hs₀
    refine ⟨n₀, fun s hs => ?_⟩
    obtain ⟨s', hs', hsub⟩ := hdirS s hs s₀ hs₀
    obtain ⟨n', hn'⟩ := hA s' hs'
    have hn'₀ : p n' u ∈ s₀ := (hsub hn').2
    rcases hone s₀ hs₀ n' n₀ hn'₀ hn₀ with rfl | hbad
    · exact (hsub hn').1
    · exact absurd (hbad j₀) hj₀

/-- **The hedgehog satisfies *Saturation*** (`def:frame#Saturation`). -/
theorem rel_saturation : TaskFrame.Saturation rel := by
  intro S hdir hmem
  obtain ⟨hSne, hdirS⟩ := hdir
  haveI : Nonempty ↥S := hSne.to_subtype
  have hIcc : ∀ i : ↥S, ∃ a b, shadow '' (i : Set HH) = Icc a b := fun i =>
    shadow_isIcc (hmem i.1 i.2).1 (hmem i.1 i.2).2
  have hcpt : ∀ i : ↥S, IsCompact (shadow '' (i : Set HH)) := by
    intro i; obtain ⟨a, b, h⟩ := hIcc i; rw [h]; exact isCompact_Icc
  have hcl : ∀ i : ↥S, IsClosed (shadow '' (i : Set HH)) := by
    intro i; obtain ⟨a, b, h⟩ := hIcc i; rw [h]; exact isClosed_Icc
  have hnn : ∀ i : ↥S, (shadow '' (i : Set HH)).Nonempty := fun i => (hmem i.1 i.2).2.image _
  have hdirec : Directed (· ⊇ ·) (fun i : ↥S => shadow '' (i : Set HH)) := by
    rintro ⟨s₁, h₁⟩ ⟨s₂, h₂⟩
    obtain ⟨s', hs', hsub⟩ := hdirS s₁ h₁ s₂ h₂
    exact ⟨⟨s', hs'⟩, Set.image_mono (hsub.trans Set.inter_subset_left),
      Set.image_mono (hsub.trans Set.inter_subset_right)⟩
  obtain ⟨r, hr⟩ := IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed _
    hdirec hnn hcpt hcl
  rw [Set.mem_iInter] at hr
  have hrS : ∀ s ∈ S, r ∈ shadow '' s := fun s hs => hr ⟨s, hs⟩
  rcases lt_or_ge 0 r with hrpos | hrle
  · -- `r > 0`: every member meets the circle of radius `r`; directedness fixes the ray.
    have hA : ∀ s ∈ S, ∃ n, p n ⟨r, hrpos⟩ ∈ s := by
      intro s hs
      obtain ⟨w, hw, hws⟩ := hrS s hs
      cases w with
      | c => rw [shadow_c] at hws; exact absurd hws.symm (by linarith)
      | p m v =>
        rw [shadow_p] at hws
        exact ⟨m, by rwa [show v = ⟨r, hrpos⟩ from Subtype.ext hws] at hw⟩
    have hone : ∀ s ∈ S, ∀ n m, p n ⟨r, hrpos⟩ ∈ s → p m ⟨r, hrpos⟩ ∈ s →
        n = m ∨ ∀ j, p j ⟨r, hrpos⟩ ∈ s := by
      intro s hs n m hn hm
      obtain ⟨k, N, a, b, -, hN, hE⟩ := class_band (hmem s hs).1
      rw [hE] at hn hm ⊢
      obtain ⟨hnN, ha, hb⟩ := p_mem_band.mp hn
      rcases hN with rfl | hsub
      · exact Or.inr fun j => ⟨Set.mem_univ j, ha, hb⟩
      · exact Or.inl (hsub hnN (p_mem_band.mp hm).1)
    obtain ⟨n, hn⟩ := common_ray (S := S) ⟨r, hrpos⟩ hdirS hA hone
    exact ⟨p n ⟨r, hrpos⟩, Set.mem_sInter.mpr hn⟩
  · -- `r = 0`: the centre is the only shadow preimage of `0`, so it lies in every member.
    refine ⟨c, Set.mem_sInter.mpr fun s hs => ?_⟩
    obtain ⟨w, hw, hws⟩ := hrS s hs
    cases w with
    | c => exact hw
    | p m v => rw [shadow_p] at hws; exact absurd hws (by intro h; linarith [v.2])

/-- **The hedgehog frame satisfies *Saturation***, as a fact about the frame. -/
theorem frame_saturation : TaskFrame.Saturation frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_saturation

/-- **The hedgehog is a *regular* frame** — a genuine `def:frame` task frame, all four
constraints proved. -/
instance : frame.IsRegular where
  comp := frame_compositional
  serial := frame_serial
  limit := frame_limit
  saturation := frame_saturation

/-- **Some TASK FRAME separates `𝒩_F` from the final topology of all histories** — the instance
above is what upgrades `finalTopology_ne_nbhdTopology` from a statement about a structure to a
statement about a `def:frame` task frame. -/
theorem taskFrame_t1Space : @T1Space frame.WorldState (FrameOver.stateTopology frame) :=
  FrameOver.instT1SpaceOfRegular frame

end Hedgehog
end FormalSystem.Semantics.StateTopology
