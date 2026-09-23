/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/
import Mathlib.Data.Rat.Lemmas
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import FormalSystem.Semantics.Extension.Completion
import FormalSystem.Semantics.StateTopology.ConstraintWitnesses

/-!
# Probe: a frame satisfying *Completion* and failing *Saturation*

`W = ℚ`, `D = ℤ`, `w ⇒_x v` iff `|v - w| ≤ |x|` — unit-speed drift on a rationally incomplete
carrier over **discrete** time.

* *Seriality*, *Compositionality*, *Limit* hold (`srel_serial`, `srel_compositional`,
  `srel_limit`).
* *Completion* holds (`srel_coherentCompletion`) because `ℤ` has nearest times: the family's own
  constraint at the nearest domain time on each side of `z` is the `⊆`-least one, so no
  intersection of infinitely many shrinking constraints is ever demanded. This is
  `PartialHistory.completion_of_hasNearest`'s argument, run at the bare relation.
* *Saturation* **fails** (`not_srel_saturation`): fibres and segments are **not** indexed by
  times, so a `⊇`-directed family of segments may shrink onto a Dedekind cut of `ℚ` even though
  the durations are integers. The witness is the family of rational intervals `[a, b]` with
  `1 ≤ a`, `a² < 2 < b²`, `b ≤ 2`, each realised as the segment `[b-1, a+1]_1^1`.

So *Completion* is **strictly weaker** than *Saturation*, and the converse
`Completion → Saturation` is **false** — it fails at every frame of this shape. Consistently with
`saturation_of_completion` (`specs/evidence/frame-constraints-audit/`), this frame refutes
mixed-sign composition (`not_srel_totalComp`).
-/

open Set

namespace FormalSystem.Semantics.StateTopology
namespace SeparatingFrame

open FormalSystem.Semantics FormalSystem.Semantics.TaskFrame
open FormalSystem.Semantics.PartialHistory (HasNearest hasNearest_int)

/-- `PartialHistory.CoherentCompletion`, over a bare task relation. -/
def CoherentCompletionRel {W D : Type} [AddCommGroup D] (R : W → D → W → Prop) : Prop :=
  ∀ (X : D → Prop), (∃ t, X t) →
    ∀ (w : (t : D) → X t → W),
      (∀ (s t : D) (hs : X s) (ht : X t), R (w s hs) (t - s) (w t ht)) →
      ∀ z : D, ∃ u : W, ∀ (t : D) (ht : X t), R (w t ht) (z - t) u

/-- Unit-speed drift on `ℚ` over `ℤ`-time. -/
def srel (w : ℚ) (x : ℤ) (v : ℚ) : Prop := |v - w| ≤ |(x : ℚ)|

theorem srel_iff {w : ℚ} {x : ℤ} {v : ℚ} : srel w x v ↔ |v - w| ≤ |(x : ℚ)| := Iff.rfl

theorem srel_of_nonneg {w : ℚ} {x : ℤ} {v : ℚ} (hx : 0 ≤ x) :
    srel w x v ↔ |v - w| ≤ (x : ℚ) := by
  rw [srel_iff, abs_of_nonneg (by exact_mod_cast hx : (0 : ℚ) ≤ (x : ℚ))]

/-! ## *Seriality*, *Compositionality*, *Limit* -/

theorem srel_serial : Serial srel := by
  intro w x hx
  have h : srel w x w := by
    rw [srel_iff, sub_self, abs_zero]
    exact abs_nonneg _
  exact ⟨⟨w, h⟩, ⟨w, h⟩⟩

theorem srel_compositional : Compositional srel := by
  intro w v x y hx hy
  have hx' : (0 : ℚ) ≤ (x : ℚ) := by exact_mod_cast hx
  have hy' : (0 : ℚ) ≤ (y : ℚ) := by exact_mod_cast hy
  rw [srel_of_nonneg (by omega : (0 : ℤ) ≤ x + y)]
  push_cast
  constructor
  · intro h
    rw [abs_le] at h
    rcases le_total v (w - x) with hlt | hge
    · refine ⟨w - (x : ℚ), ?_, ?_⟩
      · rw [srel_of_nonneg hx, show w - (x : ℚ) - w = -(x : ℚ) by ring, abs_neg,
          abs_of_nonneg hx']
      · rw [srel_of_nonneg hy, abs_le]; constructor <;> linarith
    · rcases le_total (w + x) v with hge' | hle'
      · refine ⟨w + (x : ℚ), ?_, ?_⟩
        · rw [srel_of_nonneg hx, show w + (x : ℚ) - w = (x : ℚ) by ring, abs_of_nonneg hx']
        · rw [srel_of_nonneg hy, abs_le]; constructor <;> linarith
      · refine ⟨v, ?_, ?_⟩
        · rw [srel_of_nonneg hx, abs_le]; constructor <;> linarith
        · rw [srel_of_nonneg hy, sub_self, abs_zero]; exact hy'
  · rintro ⟨u, hu1, hu2⟩
    rw [srel_of_nonneg hx, abs_le] at hu1
    rw [srel_of_nonneg hy, abs_le] at hu2
    rw [abs_le]
    constructor <;> linarith [hu1.1, hu1.2, hu2.1, hu2.2]

theorem srel_limit : TaskFrame.Limit srel := by
  intro w u h
  obtain ⟨y, hy, hR⟩ := h 1 one_pos
  have hy0 : y = 0 := by
    rcases abs_lt.mp hy with ⟨h1, h2⟩
    omega
  subst hy0
  rw [srel_iff] at hR
  simp only [Int.cast_zero, abs_zero] at hR
  have h0 : u - w = 0 := abs_eq_zero.mp (le_antisymm hR (abs_nonneg _))
  linarith

/-! ## *Completion* holds: `ℤ` has nearest times -/

theorem srel_coherentCompletion : CoherentCompletionRel srel := by
  intro X hXne w hw z
  obtain ⟨hlow, hhigh⟩ := hasNearest_int X z
  -- coherence, in ℚ-arithmetic form
  have hcoh : ∀ (s t : ℤ) (hs : X s) (ht : X t), |w t ht - w s hs| ≤ |(t : ℚ) - (s : ℚ)| := by
    intro s t hs ht
    have h := hw s t hs ht
    rw [srel_iff] at h
    push_cast at h
    exact h
  by_cases hbelow : ∃ t, X t ∧ t ≤ z
  · obtain ⟨tm, htm, htmz, htmax⟩ := hlow hbelow
    by_cases habove : ∃ t, X t ∧ z ≤ t
    · obtain ⟨tp, htp, hztp, htmin⟩ := hhigh habove
      have htmzq : (tm : ℚ) ≤ (z : ℚ) := by exact_mod_cast htmz
      have hztpq : (z : ℚ) ≤ (tp : ℚ) := by exact_mod_cast hztp
      have hspan0 := hcoh tm tp htm htp
      rw [abs_of_nonneg (by linarith : (0 : ℚ) ≤ (tp : ℚ) - (tm : ℚ))] at hspan0
      rw [abs_le] at hspan0
      have hlmax : w tm htm - ((z : ℚ) - (tm : ℚ))
          ≤ max (w tm htm - ((z : ℚ) - (tm : ℚ))) (w tp htp - ((tp : ℚ) - (z : ℚ))) :=
        le_max_left _ _
      have hrmax : w tp htp - ((tp : ℚ) - (z : ℚ))
          ≤ max (w tm htm - ((z : ℚ) - (tm : ℚ))) (w tp htp - ((tp : ℚ) - (z : ℚ))) :=
        le_max_right _ _
      have hub1 : max (w tm htm - ((z : ℚ) - (tm : ℚ))) (w tp htp - ((tp : ℚ) - (z : ℚ)))
          ≤ w tm htm + ((z : ℚ) - (tm : ℚ)) :=
        max_le (by linarith) (by linarith [hspan0.2])
      have hub2 : max (w tm htm - ((z : ℚ) - (tm : ℚ))) (w tp htp - ((tp : ℚ) - (z : ℚ)))
          ≤ w tp htp + ((tp : ℚ) - (z : ℚ)) :=
        max_le (by linarith [hspan0.1]) (by linarith)
      refine ⟨max (w tm htm - ((z : ℚ) - (tm : ℚ))) (w tp htp - ((tp : ℚ) - (z : ℚ))),
        fun t ht => ?_⟩
      rw [srel_iff]
      push_cast
      rw [abs_le]
      rcases le_total t z with htz | hzt
      · have hle : t ≤ tm := htmax t ht htz
        have hcast : (t : ℚ) ≤ (tm : ℚ) := by exact_mod_cast hle
        have hgap := hcoh t tm ht htm
        rw [abs_of_nonneg (by linarith : (0 : ℚ) ≤ (tm : ℚ) - (t : ℚ)),
          abs_sub_comm, abs_le] at hgap
        have htzq : (t : ℚ) ≤ (z : ℚ) := by exact_mod_cast htz
        rw [abs_of_nonneg (by linarith : (0 : ℚ) ≤ (z : ℚ) - (t : ℚ))]
        constructor <;> linarith [hgap.1, hgap.2]
      · have hge : tp ≤ t := htmin t ht hzt
        have hcast : (tp : ℚ) ≤ (t : ℚ) := by exact_mod_cast hge
        have hgap := hcoh t tp ht htp
        rw [abs_of_nonpos (by linarith : (tp : ℚ) - (t : ℚ) ≤ 0), abs_le] at hgap
        have hztq : (z : ℚ) ≤ (t : ℚ) := by exact_mod_cast hzt
        rw [abs_of_nonpos (by linarith : (z : ℚ) - (t : ℚ) ≤ 0)]
        constructor <;> linarith [hgap.1, hgap.2]
    · -- domain entirely at or below `z`
      refine ⟨w tm htm, fun t ht => ?_⟩
      have htz : t ≤ z := le_of_not_ge fun h => habove ⟨t, ht, h⟩
      have hle : t ≤ tm := htmax t ht htz
      have hcast : (t : ℚ) ≤ (tm : ℚ) := by exact_mod_cast hle
      have htmzq : (tm : ℚ) ≤ (z : ℚ) := by exact_mod_cast htmz
      have htzq : (t : ℚ) ≤ (z : ℚ) := by exact_mod_cast htz
      have hgap := hcoh t tm ht htm
      rw [abs_of_nonneg (by linarith : (0 : ℚ) ≤ (tm : ℚ) - (t : ℚ)), abs_sub_comm,
        abs_le] at hgap
      rw [srel_iff]
      push_cast
      rw [abs_le, abs_of_nonneg (by linarith : (0 : ℚ) ≤ (z : ℚ) - (t : ℚ))]
      constructor <;> linarith [hgap.1, hgap.2]
  · -- domain entirely at or above `z`
    have habove : ∃ t, X t ∧ z ≤ t := by
      obtain ⟨t, ht⟩ := hXne
      exact ⟨t, ht, le_of_not_ge fun h => hbelow ⟨t, ht, h⟩⟩
    obtain ⟨tp, htp, hztp, htmin⟩ := hhigh habove
    refine ⟨w tp htp, fun t ht => ?_⟩
    have hzt : z ≤ t := le_of_not_ge fun h => hbelow ⟨t, ht, h⟩
    have hge : tp ≤ t := htmin t ht hzt
    have hcast : (tp : ℚ) ≤ (t : ℚ) := by exact_mod_cast hge
    have hztpq : (z : ℚ) ≤ (tp : ℚ) := by exact_mod_cast hztp
    have hztq : (z : ℚ) ≤ (t : ℚ) := by exact_mod_cast hzt
    have hgap := hcoh t tp ht htp
    rw [abs_of_nonpos (by linarith : (tp : ℚ) - (t : ℚ) ≤ 0), abs_le] at hgap
    rw [srel_iff]
    push_cast
    rw [abs_le, abs_of_nonpos (by linarith : (z : ℚ) - (t : ℚ) ≤ 0)]
    constructor <;> linarith [hgap.1, hgap.2]

/-! ## *Saturation* fails: segments shrink onto a Dedekind cut -/

/-- The rational interval `[a, b]`, realised as the segment `[b-1, a+1]_1^1`. -/
theorem mem_sseg {a b q : ℚ} (hab : b - a ≤ 2) :
    q ∈ Seg srel (b - 1) (a + 1) 1 1 ↔ a ≤ q ∧ q ≤ b := by
  simp only [Seg, Set.mem_inter_iff, mem_Fib, srel_iff]
  constructor
  · rintro ⟨h1, h2⟩
    rw [abs_le] at h1 h2
    norm_num at h1 h2
    exact ⟨by linarith [h2.1], by linarith [h1.2]⟩
  · rintro ⟨h1, h2⟩
    constructor <;> · rw [abs_le]; norm_num; constructor <;> linarith

/-- The `⊇`-directed family of rational intervals straddling the cut at `√2`. -/
def straddle : Set (Set ℚ) :=
  {s | ∃ a b : ℚ, 1 ≤ a ∧ a ^ 2 < 2 ∧ 2 < b ^ 2 ∧ 1 ≤ b ∧ b ≤ 2 ∧
    s = Seg srel (b - 1) (a + 1) 1 1}

theorem lt_of_straddle {a b : ℚ} (ha0 : 0 < a) (hb0 : 0 < b) (ha : a ^ 2 < 2) (hb : 2 < b ^ 2) :
    a < b := by
  by_contra hc
  exact absurd hb (not_lt.mpr (by nlinarith [not_lt.mp hc]))

/--
**The ℚ-over-ℤ drift relation FAILS *Saturation***, although it satisfies *Completion*.

Durations are integers, so no coherent family of states can accumulate; but fibres and segments
are not indexed by times, and a `⊇`-directed family of them shrinks onto the cut
`{q : q² < 2} | {q : 2 < q²}`, which has no rational point.
-/
theorem not_srel_saturation : ¬ TaskFrame.Saturation srel := by
  intro hsat
  have hone : ((1 : ℚ)) ^ 2 < 2 := by norm_num
  have htwo : (2 : ℚ) < ((2 : ℚ)) ^ 2 := by norm_num
  have hwidth : ∀ {a b : ℚ}, 1 ≤ a → b ≤ 2 → b - a ≤ 2 := by intro a b h1 h2; linarith
  have hne : straddle.Nonempty := ⟨_, ⟨1, 2, le_rfl, hone, htwo, by norm_num, le_rfl, rfl⟩⟩
  have hdir : DirectedFamily straddle := by
    refine ⟨hne, ?_⟩
    rintro s₁ ⟨a₁, b₁, ha₁1, ha₁, hb₁, hb₁1, hb₁2, rfl⟩ s₂ ⟨a₂, b₂, ha₂1, ha₂, hb₂, hb₂1, hb₂2, rfl⟩
    have haM : (max a₁ a₂) ^ 2 < 2 := by
      rcases max_choice a₁ a₂ with h | h <;> rw [h] <;> assumption
    have hbM : 2 < (min b₁ b₂) ^ 2 := by
      rcases min_choice b₁ b₂ with h | h <;> rw [h] <;> assumption
    have hA1 : (1 : ℚ) ≤ max a₁ a₂ := le_max_of_le_left ha₁1
    have hB2 : min b₁ b₂ ≤ 2 := min_le_of_left_le hb₁2
    refine ⟨_, ⟨max a₁ a₂, min b₁ b₂, hA1, haM, hbM, le_min hb₁1 hb₂1, hB2, rfl⟩, ?_⟩
    intro q hq
    rw [mem_sseg (hwidth hA1 hB2)] at hq
    simp only [max_le_iff, le_min_iff] at hq
    exact ⟨(mem_sseg (hwidth ha₁1 hb₁2)).mpr ⟨hq.1.1, hq.2.1⟩,
      (mem_sseg (hwidth ha₂1 hb₂2)).mpr ⟨hq.1.2, hq.2.2⟩⟩
  have hmem : ∀ s ∈ straddle, (IsFiber srel s ∨ IsSegment srel s) ∧ s.Nonempty := by
    rintro s ⟨a, b, ha1, ha, hb, hb1, hb2, rfl⟩
    refine ⟨Or.inr ⟨b - 1, a + 1, 1, 1, by norm_num, by norm_num, rfl⟩,
      ⟨a, (mem_sseg (hwidth ha1 hb2)).mpr
        ⟨le_rfl, le_of_lt (lt_of_straddle (by linarith) (by linarith) ha hb)⟩⟩⟩
  obtain ⟨q, hq⟩ := hsat straddle hdir hmem
  have hbase : Seg srel ((2 : ℚ) - 1) ((1 : ℚ) + 1) 1 1 ∈ straddle :=
    ⟨1, 2, le_rfl, hone, htwo, by norm_num, le_rfl, rfl⟩
  obtain ⟨hq1, hq2⟩ := (mem_sseg (by norm_num : (2 : ℚ) - 1 ≤ 2)).mp (Set.mem_sInter.mp hq _ hbase)
  -- the Newton step `t = (2q+2)/(q+2)` crosses `q` while staying on its own side of the cut
  have hpos : (0 : ℚ) < q + 2 := by linarith
  set t : ℚ := (2 * q + 2) / (q + 2) with ht
  have ht1 : 1 ≤ t := by
    rw [ht, le_div_iff₀ hpos]; linarith
  have ht2 : t ≤ 2 := by
    rw [ht, div_le_iff₀ hpos]; linarith
  have htsq : t ^ 2 - 2 = 2 * (q ^ 2 - 2) / (q + 2) ^ 2 := by rw [ht]; field_simp; ring
  have htdiff : t - q = (2 - q ^ 2) / (q + 2) := by rw [ht]; field_simp; ring
  rcases lt_trichotomy (q ^ 2) 2 with hlt | heq | hgt
  · have htlt : t ^ 2 < 2 := by
      have : t ^ 2 - 2 < 0 := by
        rw [htsq]; exact div_neg_of_neg_of_pos (by linarith) (by positivity)
      linarith
    have hts : q < t := by
      have : 0 < t - q := by rw [htdiff]; exact div_pos (by linarith) hpos
      linarith
    have hm : Seg srel ((2 : ℚ) - 1) (t + 1) 1 1 ∈ straddle :=
      ⟨t, 2, ht1, htlt, htwo, by norm_num, le_rfl, rfl⟩
    obtain ⟨hlow, -⟩ := (mem_sseg (by linarith : (2 : ℚ) - t ≤ 2)).mp (Set.mem_sInter.mp hq _ hm)
    linarith
  · exact RationalTwoOrigins.sq_ne_two q heq
  · have htgt : 2 < t ^ 2 := by
      have : 0 < t ^ 2 - 2 := by
        rw [htsq]; exact div_pos (by linarith) (by positivity)
      linarith
    have hst : t < q := by
      have : t - q < 0 := by
        rw [htdiff]; exact div_neg_of_neg_of_pos (by linarith) hpos
      linarith
    have hm : Seg srel (t - 1) ((1 : ℚ) + 1) 1 1 ∈ straddle :=
      ⟨1, t, le_rfl, hone, htgt, ht1, ht2, rfl⟩
    obtain ⟨-, hhigh⟩ := (mem_sseg (by linarith : t - 1 ≤ 2)).mp (Set.mem_sInter.mp hq _ hm)
    linarith

/-! ## Consistency with `saturation_of_completion`: mixed-sign composition fails here -/

/-- Mixed-sign composition, as declared in `specs/evidence/frame-constraints-audit/`. -/
def TotalComp {W : Type} {D : Type} [AddCommGroup D] (R : W → D → W → Prop) : Prop :=
  ∀ w u v x y, R w x u → R u y v → R w (x + y) v

theorem not_srel_totalComp : ¬ TotalComp srel := by
  intro h
  have h1 : srel 0 1 1 := by rw [srel_iff]; norm_num
  have h2 : srel 1 (-1) 2 := by rw [srel_iff]; norm_num
  have h3 := h 0 1 2 1 (-1) h1 h2
  rw [srel_iff] at h3
  norm_num at h3

end SeparatingFrame
end FormalSystem.Semantics.StateTopology

section AxiomCheck
#print axioms FormalSystem.Semantics.StateTopology.SeparatingFrame.srel_serial
#print axioms FormalSystem.Semantics.StateTopology.SeparatingFrame.srel_compositional
#print axioms FormalSystem.Semantics.StateTopology.SeparatingFrame.srel_limit
#print axioms FormalSystem.Semantics.StateTopology.SeparatingFrame.srel_coherentCompletion
#print axioms FormalSystem.Semantics.StateTopology.SeparatingFrame.not_srel_saturation
#print axioms FormalSystem.Semantics.StateTopology.SeparatingFrame.not_srel_totalComp
end AxiomCheck
