import Mathlib.Topology.Order.Compact
import FormalSystem.Semantics.StateTopology.Counterexamples

/-!
# Probe: *Saturation* for the half-line with two origins
-/

open Topology TopologicalSpace Set

set_option warn.classDefReducibility false

namespace FormalSystem.Semantics.StateTopology
namespace TwoOrigins

open TO FormalSystem.Semantics.TaskFrame

/-- The shadow map `W → [0, ∞)`: both origins go to `0`, `p t` goes to `t`. -/
def shadow : TO → ℝ
  | o _ => 0
  | p u => u.1

@[simp] theorem shadow_o (c : Bool) : shadow (o c) = 0 := rfl

@[simp] theorem shadow_p (u : {t : ℝ // 0 < t}) : shadow (p u) = u.1 := rfl

/-- A *band*: a set of origins together with a real interval of ray points. -/
def band (O : Set Bool) (a b : ℝ) : Set TO :=
  {w | match w with
       | o c => c ∈ O
       | p u => a ≤ u.1 ∧ u.1 ≤ b}

@[simp] theorem o_mem_band {c : Bool} {O : Set Bool} {a b : ℝ} :
    o c ∈ band O a b ↔ c ∈ O := Iff.rfl

@[simp] theorem p_mem_band {u : {t : ℝ // 0 < t}} {O : Set Bool} {a b : ℝ} :
    p u ∈ band O a b ↔ a ≤ u.1 ∧ u.1 ≤ b := Iff.rfl

/-- The invariant every fibre and every nonempty segment of `rel` satisfies. -/
def Good (O : Set Bool) (a : ℝ) : Prop := (O.Nonempty ∧ a ≤ 0) ∨ (O = ∅ ∧ 0 < a)

/-- **Lemma C**: the shadow of a `Good` band is a closed bounded interval. -/
theorem shadow_band {O : Set Bool} {a b : ℝ} (hG : Good O a) :
    shadow '' band O a b = Icc (max a 0) (max b 0) := by
  ext r
  constructor
  · rintro ⟨w, hw, rfl⟩
    cases w with
    | o c =>
      rcases hG with ⟨_, ha⟩ | ⟨hO, _⟩
      · exact ⟨by simp [max_eq_right ha], by simp⟩
      · exact absurd (o_mem_band.mp hw) (by simp [hO])
    | p u =>
      obtain ⟨h1, h2⟩ := p_mem_band.mp hw
      exact ⟨max_le h1 (le_of_lt u.2), le_trans h2 (le_max_left _ _)⟩
  · rintro ⟨h1, h2⟩
    rcases hG with ⟨⟨c, hc⟩, ha⟩ | ⟨hO, ha⟩
    · rw [max_eq_right ha] at h1
      rcases eq_or_lt_of_le h1 with h0 | h0
      · exact ⟨o c, hc, by simp [h0.symm]⟩
      · have hb : r ≤ b := by
          rcases le_or_gt b 0 with hbn | hbp
          · rw [max_eq_right hbn] at h2; linarith
          · rw [max_eq_left (le_of_lt hbp)] at h2; exact h2
        exact ⟨p ⟨r, h0⟩, ⟨le_trans ha (le_of_lt h0), hb⟩, rfl⟩
    · rw [max_eq_left (le_of_lt ha)] at h1
      have h0 : 0 < r := lt_of_lt_of_le ha h1
      have hb : r ≤ b := by
        rcases le_or_gt b 0 with hbn | hbp
        · rw [max_eq_right hbn] at h2; linarith
        · rw [max_eq_left (le_of_lt hbp)] at h2; exact h2
      exact ⟨p ⟨r, h0⟩, ⟨h1, hb⟩, rfl⟩

/-- **Lemma D, fibres**: every fibre of `rel` is a `Good` band. -/
theorem fib_band (w : TO) (x : ℝ) :
    ∃ O a b, Good O a ∧ (O.Nonempty → O = univ ∨ b ≤ x) ∧ Fib rel w x = band O a b := by
  cases w with
  | o c =>
    refine ⟨{c}, 0, x, Or.inl ⟨⟨c, rfl⟩, le_rfl⟩, fun _ => Or.inr le_rfl, ?_⟩
    ext u
    cases u with
    | o c' =>
      exact ⟨fun h => (show c = c' from h).symm, fun h => (show c' = c from h).symm⟩
    | p s =>
      exact ⟨fun h => ⟨le_of_lt s.2, show s.1 ≤ x from h⟩,
             fun h => show s.1 ≤ x from h.2⟩
  | p t =>
    rcases le_or_gt 0 x with hx | hx
    · refine ⟨∅, t.1, t.1 + x, Or.inr ⟨rfl, t.2⟩, fun h => absurd h (by simp), ?_⟩
      ext u
      cases u with
      | o c =>
        exact ⟨fun h => absurd (show t.1 ≤ -x from h) (by linarith [t.2]),
               fun h => absurd h (by simp)⟩
      | p s =>
        constructor
        · rintro (⟨_, h2, h3⟩ | ⟨h1, _, _⟩)
          · exact ⟨h2, h3⟩
          · linarith
        · rintro ⟨h1, h2⟩; exact Or.inl ⟨hx, h1, h2⟩
    · rcases le_or_gt t.1 (-x) with ht | ht
      · refine ⟨univ, t.1 + x, t.1, Or.inl ⟨⟨true, Set.mem_univ true⟩, by linarith⟩,
          fun _ => Or.inl rfl, ?_⟩
        ext u
        cases u with
        | o c => exact ⟨fun _ => Set.mem_univ c, fun _ => show t.1 ≤ -x from ht⟩
        | p s =>
          constructor
          · rintro (⟨h1, _, _⟩ | ⟨_, h2, h3⟩)
            · linarith
            · exact ⟨by linarith, h2⟩
          · rintro ⟨h1, h2⟩; exact Or.inr ⟨hx, h2, by linarith⟩
      · refine ⟨∅, t.1 + x, t.1, Or.inr ⟨rfl, by linarith⟩, fun h => absurd h (by simp), ?_⟩
        ext u
        cases u with
        | o c =>
          exact ⟨fun h => absurd (show t.1 ≤ -x from h) (by linarith),
                 fun h => absurd h (by simp)⟩
        | p s =>
          constructor
          · rintro (⟨h1, _, _⟩ | ⟨_, h2, h3⟩)
            · linarith
            · exact ⟨by linarith, h2⟩
          · rintro ⟨h1, h2⟩; exact Or.inr ⟨hx, h2, by linarith⟩

/-- Bands are closed under intersection. -/
theorem band_inter (O₁ O₂ : Set Bool) (a₁ b₁ a₂ b₂ : ℝ) :
    band O₁ a₁ b₁ ∩ band O₂ a₂ b₂ = band (O₁ ∩ O₂) (max a₁ a₂) (min b₁ b₂) := by
  ext u
  cases u with
  | o c => exact Iff.rfl
  | p s =>
    simp only [Set.mem_inter_iff, p_mem_band, max_le_iff, le_min_iff]
    constructor
    · rintro ⟨⟨h1, h2⟩, ⟨h3, h4⟩⟩; exact ⟨⟨h1, h3⟩, h2, h4⟩
    · rintro ⟨⟨h1, h3⟩, h2, h4⟩; exact ⟨⟨h1, h2⟩, h3, h4⟩

/-- **Lemma D, segments**: every nonempty segment of `rel` is a `Good` band. -/
theorem seg_band {w v : TO} {x y : ℝ} (_hx : 0 ≤ x) (hy : 0 ≤ y)
    (hne : (Seg rel w v x y).Nonempty) :
    ∃ O a b, Good O a ∧ Seg rel w v x y = band O a b := by
  obtain ⟨O₁, a₁, b₁, hG₁, -, hE₁⟩ := fib_band w x
  obtain ⟨O₂, a₂, b₂, hG₂, hU₂, hE₂⟩ := fib_band v (-y)
  refine ⟨O₁ ∩ O₂, max a₁ a₂, min b₁ b₂, ?_, by rw [Seg, hE₁, hE₂, band_inter]⟩
  rcases Set.eq_empty_or_nonempty (O₁ ∩ O₂) with hI | hI
  · -- No origins survive: the lower endpoint must be positive.
    rcases hG₁ with ⟨hn₁, ha₁⟩ | ⟨hO₁, ha₁⟩
    · rcases hG₂ with ⟨hn₂, ha₂⟩ | ⟨hO₂, ha₂⟩
      · -- Both fibres carry origins, but no common one: the band is empty, contradiction.
        exfalso
        have hnu : O₂ ≠ univ := by
          rintro rfl
          obtain ⟨c, hc⟩ := hn₁
          exact absurd (Set.eq_empty_iff_forall_notMem.mp hI c) (by simp [hc])
        have hb₂ : b₂ ≤ -y := (hU₂ hn₂).resolve_left hnu
        obtain ⟨u, hu⟩ := hne
        rw [Seg, hE₁, hE₂, band_inter] at hu
        cases u with
        | o c => exact absurd (o_mem_band.mp hu) (by rw [hI]; simp)
        | p r =>
          obtain ⟨-, h2⟩ := p_mem_band.mp hu
          have : r.1 ≤ -y := le_trans (le_trans h2 (min_le_right _ _)) hb₂
          linarith [r.2]
      · exact Or.inr ⟨hI, lt_of_lt_of_le ha₂ (le_max_right _ _)⟩
    · exact Or.inr ⟨hI, lt_of_lt_of_le ha₁ (le_max_left _ _)⟩
  · -- A common origin survives: both lower endpoints are nonpositive.
    obtain ⟨c, hc₁, hc₂⟩ := hI
    have ha₁ : a₁ ≤ 0 := by
      rcases hG₁ with ⟨-, h⟩ | ⟨hO₁, -⟩
      · exact h
      · exact absurd hc₁ (by rw [hO₁]; simp)
    have ha₂ : a₂ ≤ 0 := by
      rcases hG₂ with ⟨-, h⟩ | ⟨hO₂, -⟩
      · exact h
      · exact absurd hc₂ (by rw [hO₂]; simp)
    exact Or.inl ⟨⟨c, hc₁, hc₂⟩, max_le ha₁ ha₂⟩

/-- Every nonempty fibre or segment of `rel` has a closed, bounded shadow. -/
theorem shadow_isIcc {s : Set TO} (hcls : IsFiber rel s ∨ IsSegment rel s) (hne : s.Nonempty) :
    ∃ a b, shadow '' s = Icc a b := by
  obtain ⟨O, a, b, hG, hE⟩ : ∃ O a b, Good O a ∧ s = band O a b := by
    rcases hcls with ⟨w, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
    · obtain ⟨O, a, b, hG, -, hE⟩ := fib_band w x
      exact ⟨O, a, b, hG, hE⟩
    · exact seg_band hx hy hne
  exact ⟨max a 0, max b 0, by rw [hE, shadow_band hG]⟩

/-- **The two-origin frame satisfies *Saturation*** (`def:frame#Saturation`). -/
theorem rel_saturation : TaskFrame.Saturation rel := by
  intro S hdir hmem
  obtain ⟨hSne, hdirS⟩ := hdir
  haveI : Nonempty ↥S := hSne.to_subtype
  have hIcc : ∀ i : ↥S, ∃ a b, shadow '' (i : Set TO) = Icc a b := fun i =>
    shadow_isIcc (hmem i.1 i.2).1 (hmem i.1 i.2).2
  have hcpt : ∀ i : ↥S, IsCompact (shadow '' (i : Set TO)) := by
    intro i; obtain ⟨a, b, h⟩ := hIcc i; rw [h]; exact isCompact_Icc
  have hcl : ∀ i : ↥S, IsClosed (shadow '' (i : Set TO)) := by
    intro i; obtain ⟨a, b, h⟩ := hIcc i; rw [h]; exact isClosed_Icc
  have hnn : ∀ i : ↥S, (shadow '' (i : Set TO)).Nonempty := fun i => (hmem i.1 i.2).2.image _
  have hdirec : Directed (· ⊇ ·) (fun i : ↥S => shadow '' (i : Set TO)) := by
    rintro ⟨s₁, h₁⟩ ⟨s₂, h₂⟩
    obtain ⟨s', hs', hsub⟩ := hdirS s₁ h₁ s₂ h₂
    exact ⟨⟨s', hs'⟩, Set.image_mono (hsub.trans Set.inter_subset_left),
      Set.image_mono (hsub.trans Set.inter_subset_right)⟩
  obtain ⟨r, hr⟩ := IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed _
    hdirec hnn hcpt hcl
  rw [Set.mem_iInter] at hr
  have hrS : ∀ s ∈ S, r ∈ shadow '' s := fun s hs => hr ⟨s, hs⟩
  rcases lt_or_ge 0 r with hrpos | hrle
  · -- `r > 0`: the unique shadow preimage of `r` is the ray point `p r`.
    refine ⟨p ⟨r, hrpos⟩, Set.mem_sInter.mpr ?_⟩
    intro s hs
    obtain ⟨w, hw, hws⟩ := hrS s hs
    cases w with
    | o c => rw [shadow_o] at hws; exact absurd hws.symm (by linarith)
    | p u =>
      rw [shadow_p] at hws
      have hu : u = ⟨r, hrpos⟩ := Subtype.ext hws
      rwa [hu] at hw
  · -- `r = 0`: every member contains an origin, and directedness picks a common one.
    have horigin : ∀ s ∈ S, ∃ c : Bool, o c ∈ s := by
      intro s hs
      obtain ⟨w, hw, hws⟩ := hrS s hs
      cases w with
      | o c => exact ⟨c, hw⟩
      | p u => rw [shadow_p] at hws; exact absurd hws (by intro h; linarith [u.2])
    by_cases htrue : ∀ s ∈ S, o true ∈ s
    · exact ⟨o true, Set.mem_sInter.mpr htrue⟩
    by_cases hfalse : ∀ s ∈ S, o false ∈ s
    · exact ⟨o false, Set.mem_sInter.mpr hfalse⟩
    exfalso
    push Not at htrue hfalse
    obtain ⟨s₁, hs₁, hn₁⟩ := htrue
    obtain ⟨s₂, hs₂, hn₂⟩ := hfalse
    obtain ⟨s', hs', hsub⟩ := hdirS s₁ hs₁ s₂ hs₂
    obtain ⟨c, hc⟩ := horigin s' hs'
    cases c with
    | true => exact hn₁ (hsub hc).1
    | false => exact hn₂ (hsub hc).2

/-- **The frame satisfies *Saturation***, as a fact about the frame. -/
theorem frame_saturation : TaskFrame.Saturation frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_saturation

/-- **The half-line with two origins is a *regular* frame** — a genuine `def:frame` task frame,
all four constraints proved. -/
instance : frame.IsRegular where
  comp := frame_compositional
  serial := frame_serial
  limit := frame_limit
  saturation := frame_saturation

/-- **Some TASK FRAME is T1 and not Hausdorff.** The upgrade this probe buys the appendix. -/
theorem taskFrame_t1_not_t2 :
    @T1Space frame.WorldState (FrameOver.stateTopology frame) ∧
      ¬ @T2Space frame.WorldState (FrameOver.stateTopology frame) :=
  ⟨FrameOver.instT1SpaceOfRegular frame, frame_not_t2Space⟩

end TwoOrigins
end FormalSystem.Semantics.StateTopology
