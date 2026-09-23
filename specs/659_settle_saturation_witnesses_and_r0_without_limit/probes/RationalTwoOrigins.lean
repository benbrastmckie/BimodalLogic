import Mathlib.Data.Rat.Lemmas
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import FormalSystem.Semantics.TaskFrame

/-!
# Probe: the ℚ-carrier two-origin frame satisfies *Seriality*, *Compositionality* and *Limit*,
and **fails *Saturation***

The relation is the two-origin half-line's, verbatim, with the duration type and the ray index
moved from `ℝ` to `ℚ`. Three constraints survive the move unchanged; *Saturation* does not.
The witness is a `⊇`-directed family of nonempty segments straddling the Dedekind cut
`{q : q² < 2} | {q : 2 < q²}`, which has no rational point.
-/

open Set

set_option maxHeartbeats 2000000

namespace FormalSystem.Semantics.StateTopology
namespace RationalTwoOrigins

open FormalSystem.Semantics.TaskFrame

/-- States of the ℚ-carrier half-line with two origins. -/
inductive TQ
  | o (b : Bool)
  | p (t : {t : ℚ // 0 < t})

open TQ

/-- The two-origin task relation, over `ℚ`. -/
def rel : TQ → ℚ → TQ → Prop
  | o b, _, o b' => b = b'
  | o _, x, p t => t.1 ≤ x
  | p t, x, o _ => t.1 ≤ -x
  | p t, x, p s => (0 ≤ x ∧ t.1 ≤ s.1 ∧ s.1 ≤ t.1 + x) ∨ (x < 0 ∧ s.1 ≤ t.1 ∧ t.1 ≤ s.1 - x)

theorem rel_refl (w : TQ) (x : ℚ) (hx : 0 ≤ x) : rel w x w := by
  cases w with
  | o b => exact rfl
  | p t => exact Or.inl ⟨hx, le_rfl, by linarith⟩

/-- **Seriality survives the move to `ℚ`.** -/
theorem rel_serial : Serial rel := by
  intro w x hx
  exact ⟨⟨w, rel_refl w x hx⟩, ⟨w, rel_refl w x hx⟩⟩

/-- **Compositionality survives the move to `ℚ`.** -/
theorem rel_compositional : Compositional rel := by
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

/-- **Limit survives the move to `ℚ`.** -/
theorem rel_limit : TaskFrame.Limit rel := by
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
      have hst : ∀ x : ℚ, 0 < x → |s.1 - t.1| < x := by
        intro x hx
        obtain ⟨y, hy, hR⟩ := h x hx
        rcases hR with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
        · rw [abs_of_nonneg h1] at hy; rw [abs_of_nonneg (by linarith)]; linarith
        · rw [abs_of_neg h1] at hy; rw [abs_of_nonpos (by linarith)]; linarith
      have hzero : |s.1 - t.1| = 0 := by
        by_contra hne
        have hpos : 0 < |s.1 - t.1| := lt_of_le_of_ne (abs_nonneg _) (Ne.symm hne)
        exact lt_irrefl _ (hst _ hpos)
      rw [abs_eq_zero, sub_eq_zero] at hzero
      exact congrArg p (Subtype.ext hzero)

/-! ### *Saturation* fails: nested rational intervals with an irrational limit -/

/-- No rational squares to `2`: the cut the family below straddles has no rational point. -/
theorem sq_ne_two (q : ℚ) : q ^ 2 ≠ 2 := by
  intro h
  have h1 : (q ^ 2).num = q.num ^ 2 := Rat.num_pow q 2
  rw [h, show (2 : ℚ).num = 2 from rfl] at h1
  have hcase : q.num ≤ -2 ∨ q.num = -1 ∨ q.num = 0 ∨ q.num = 1 ∨ 2 ≤ q.num := by omega
  rcases hcase with h' | h' | h' | h' | h'
  · nlinarith [sq_nonneg (q.num + 2)]
  · rw [h'] at h1; norm_num at h1
  · rw [h'] at h1; norm_num at h1
  · rw [h'] at h1; norm_num at h1
  · nlinarith [sq_nonneg (q.num - 2)]

/-- The segment `[p a, p b]` at matching offsets is exactly the rational interval `[a, b]` on the
ray, with no origins, whenever `0 < a < b`. -/
theorem mem_straddle {a b : {t : ℚ // 0 < t}} (hab : a.1 < b.1) (w : TQ) :
    w ∈ Seg rel (p a) (p b) (b.1 - a.1) (b.1 - a.1) ↔
      ∃ s : {t : ℚ // 0 < t}, w = p s ∧ a.1 ≤ s.1 ∧ s.1 ≤ b.1 := by
  cases w with
  | o c =>
    constructor
    · rintro ⟨h1, -⟩
      exact absurd (show a.1 ≤ -(b.1 - a.1) from h1) (by intro hh; linarith [b.2])
    · rintro ⟨s, hs, -⟩; exact absurd hs (by simp)
  | p s =>
    constructor
    · rintro ⟨h1, h2⟩
      refine ⟨s, rfl, ?_, ?_⟩
      · rcases h2 with ⟨hx, -, -⟩ | ⟨-, -, h3⟩
        · linarith
        · linarith
      · rcases h1 with ⟨-, -, h3⟩ | ⟨hx, -, -⟩
        · linarith
        · linarith
    · rintro ⟨s', hs', h1, h2⟩
      have hss : s' = s := by injection hs' with h; exact h.symm
      subst hss
      exact ⟨Or.inl ⟨by linarith, h1, by linarith⟩, Or.inr ⟨by linarith, h2, by linarith⟩⟩

/-- The `⊇`-directed family: every rational interval straddling the cut. -/
def straddleFamily : Set (Set TQ) :=
  {s | ∃ a b : {t : ℚ // 0 < t}, a.1 ^ 2 < 2 ∧ 2 < b.1 ^ 2 ∧
    s = Seg rel (p a) (p b) (b.1 - a.1) (b.1 - a.1)}

theorem lt_of_straddle {a b : ℚ} (ha0 : 0 < a) (hb0 : 0 < b) (ha : a ^ 2 < 2) (hb : 2 < b ^ 2) :
    a < b := by
  by_contra hc
  exact absurd hb (not_lt.mpr (by nlinarith [not_lt.mp hc]))

/-- **The ℚ-carrier two-origin relation FAILS *Saturation***: the rational intervals straddling
the cut `{q : q² < 2} | {q : 2 < q²}` form a `⊇`-directed family of nonempty segments whose
intersection is empty. Dedekind completeness of the carrier is what the real-carrier witness
uses, and it is not decorative. -/
theorem not_rel_saturation : ¬ TaskFrame.Saturation rel := by
  intro hsat
  have hone : ((1 : ℚ)) ^ 2 < 2 := by norm_num
  have htwo : (2 : ℚ) < ((2 : ℚ)) ^ 2 := by norm_num
  have hne : straddleFamily.Nonempty :=
    ⟨_, ⟨⟨1, one_pos⟩, ⟨2, by norm_num⟩, hone, htwo, rfl⟩⟩
  have hdir : DirectedFamily straddleFamily := by
    refine ⟨hne, ?_⟩
    rintro s₁ ⟨a₁, b₁, ha₁, hb₁, rfl⟩ s₂ ⟨a₂, b₂, ha₂, hb₂, rfl⟩
    have haM : (max a₁.1 a₂.1) ^ 2 < 2 := by
      rcases max_choice a₁.1 a₂.1 with h | h <;> rw [h] <;> assumption
    have hbM : 2 < (min b₁.1 b₂.1) ^ 2 := by
      rcases min_choice b₁.1 b₂.1 with h | h <;> rw [h] <;> assumption
    have hA0 : (0 : ℚ) < max a₁.1 a₂.1 := lt_max_of_lt_left a₁.2
    have hB0 : (0 : ℚ) < min b₁.1 b₂.1 := lt_min b₁.2 b₂.2
    have hAB : max a₁.1 a₂.1 < min b₁.1 b₂.1 := lt_of_straddle hA0 hB0 haM hbM
    refine ⟨_, ⟨⟨max a₁.1 a₂.1, hA0⟩, ⟨min b₁.1 b₂.1, hB0⟩, haM, hbM, rfl⟩, ?_⟩
    intro w hw
    rw [mem_straddle (a := ⟨max a₁.1 a₂.1, hA0⟩) (b := ⟨min b₁.1 b₂.1, hB0⟩) hAB] at hw
    obtain ⟨s, rfl, hs1, hs2⟩ := hw
    simp only [max_le_iff, le_min_iff] at hs1 hs2
    exact ⟨(mem_straddle (a := a₁) (b := b₁) (lt_of_straddle a₁.2 b₁.2 ha₁ hb₁) _).mpr
        ⟨s, rfl, hs1.1, hs2.1⟩,
      (mem_straddle (a := a₂) (b := b₂) (lt_of_straddle a₂.2 b₂.2 ha₂ hb₂) _).mpr
        ⟨s, rfl, hs1.2, hs2.2⟩⟩
  have hmem : ∀ s ∈ straddleFamily, (IsFiber rel s ∨ IsSegment rel s) ∧ s.Nonempty := by
    rintro s ⟨a, b, ha, hb, rfl⟩
    have hab : a.1 < b.1 := lt_of_straddle a.2 b.2 ha hb
    exact ⟨Or.inr ⟨p a, p b, _, _, by linarith, by linarith, rfl⟩,
      ⟨p a, (mem_straddle (a := a) (b := b) hab _).mpr ⟨a, rfl, le_rfl, le_of_lt hab⟩⟩⟩
  obtain ⟨w, hw⟩ := hsat straddleFamily hdir hmem
  have hbase : Seg rel (p ⟨1, one_pos⟩) (p ⟨2, by norm_num⟩) ((2:ℚ) - 1) ((2:ℚ) - 1)
      ∈ straddleFamily := ⟨⟨1, one_pos⟩, ⟨2, by norm_num⟩, hone, htwo, rfl⟩
  obtain ⟨s, hs, hs1, hs2⟩ :=
    (mem_straddle (a := ⟨1, one_pos⟩) (b := ⟨2, by norm_num⟩) (by norm_num) w).mp
      (Set.mem_sInter.mp hw _ hbase)
  subst hs
  -- The Newton step `t = (2s+2)/(s+2)` moves `s` strictly across the cut, in either direction.
  have hpos : (0 : ℚ) < s.1 + 2 := by linarith [s.2]
  set t : ℚ := (2 * s.1 + 2) / (s.1 + 2) with ht
  have ht0 : 0 < t := by
    rw [ht]; exact div_pos (by linarith [s.2]) (by linarith [s.2])
  have htsq : t ^ 2 - 2 = 2 * (s.1 ^ 2 - 2) / (s.1 + 2) ^ 2 := by
    rw [ht]; field_simp; ring
  have htdiff : t - s.1 = (2 - s.1 ^ 2) / (s.1 + 2) := by rw [ht]; field_simp; ring
  rcases lt_trichotomy (s.1 ^ 2) 2 with hlt | heq | hgt
  · -- `s` is below the cut: the member `[t, 2]` excludes it.
    have htlt : t ^ 2 < 2 := by
      have : t ^ 2 - 2 < 0 := by
        rw [htsq]; exact div_neg_of_neg_of_pos (by linarith) (by positivity)
      linarith
    have hts : s.1 < t := by
      have : 0 < t - s.1 := by rw [htdiff]; exact div_pos (by linarith) hpos
      linarith
    have hm : Seg rel (p ⟨t, ht0⟩) (p ⟨2, by norm_num⟩) ((2:ℚ) - t) ((2:ℚ) - t)
        ∈ straddleFamily := ⟨⟨t, ht0⟩, ⟨2, by norm_num⟩, htlt, htwo, rfl⟩
    obtain ⟨s', hs', hs'1, -⟩ :=
      (mem_straddle (a := ⟨t, ht0⟩) (b := ⟨2, by norm_num⟩)
        (by simp only []; nlinarith [htlt]) _).mp (Set.mem_sInter.mp hw _ hm)
    have : s' = s := by injection hs' with h; exact h.symm
    subst this
    exact absurd hs'1 (by simp only []; linarith)
  · exact sq_ne_two s.1 heq
  · -- `s` is above the cut: the member `[1, t]` excludes it.
    have htgt : 2 < t ^ 2 := by
      have : 0 < t ^ 2 - 2 := by
        rw [htsq]; exact div_pos (by linarith) (by positivity)
      linarith
    have hst : t < s.1 := by
      have : t - s.1 < 0 := by
        rw [htdiff]; exact div_neg_of_neg_of_pos (by linarith) hpos
      linarith
    have hm : Seg rel (p ⟨1, one_pos⟩) (p ⟨t, ht0⟩) (t - 1) (t - 1) ∈ straddleFamily :=
      ⟨⟨1, one_pos⟩, ⟨t, ht0⟩, hone, htgt, rfl⟩
    obtain ⟨s', hs', -, hs'2⟩ :=
      (mem_straddle (a := ⟨1, one_pos⟩) (b := ⟨t, ht0⟩)
        (by simp only []; nlinarith [htgt]) _).mp (Set.mem_sInter.mp hw _ hm)
    have : s' = s := by injection hs' with h; exact h.symm
    subst this
    exact absurd hs'2 (by simp only []; linarith)

end RationalTwoOrigins
end FormalSystem.Semantics.StateTopology
