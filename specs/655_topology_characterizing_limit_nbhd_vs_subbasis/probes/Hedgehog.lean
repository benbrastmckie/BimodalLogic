import Mathlib.Topology.Separation.Basic
import Mathlib.Topology.Order
import Mathlib.Topology.MetricSpace.Basic
import FormalSystem.Semantics.TaskFrame

/-!
# Probe: the hedgehog — `𝒩_F` is strictly below the final topology of all histories

`W = {c} ∪ {p n t : n : ℕ, t > 0}`, `D = ℝ`: one centre `c` and countably many rays, each
carrying the two-origin frame's drift law (`p n t ⇒_x p n s` iff `t ≤ s ≤ t + x`), the centre
reaching `p n t` in any duration `x ≥ t`, no cross-ray tasks, negatives by reflection. Then

* `RHH_serial`, `RHH_compositional`, `RHH_limit` — three of `def:frame`'s four axioms hold
  (*Saturation* is UNVERIFIED here, as for `TwoOrigins.lean`);
* `t1Space_nbhdTopology_RHH` — `𝒩_F` is T1 (from *Limit*);
* `not_isOpen_nbhdTopology_hedgehogOpen` — the set `hedgehogOpen` (the centre together with
  the ray points `p n t` with `t < 1/(n+1)`) is not `𝒩_F`-open: every cone at `c` reaches
  some ray's "tip" `p n ⟨1/(n+1)⟩`;
* `isOpen_preimage_hedgehogOpen_of_history` — yet every history pulls it back to an open set:
  a history leaves `c` along one ray and takes time at least `t` to reach `p n t`;
* `finalTopology_ne_nbhdTopology_RHH` — hence `𝒩_F ≠` the final topology of all histories;
* `not_continuous_coneTopology_RHH_history` — `{c}` is `𝒯_F`-open (two cross-ray cones meet
  only at the centre), so the history "`c` until time `0`, then out ray `0`" is not
  `𝒯_F`-continuous: inside the Seriality+Compositionality+Limit class, histories need not be
  `𝒯_F`-continuous, although they are always `𝒩_F`-continuous.
-/

open Topology TopologicalSpace Set

set_option warn.classDefReducibility false

namespace FormalSystem.Semantics.TaskFrame

-- Restated verbatim from `NbhdTopology.lean`, specialised to `D = ℝ` (kept standalone).
def Limit' {W : Type} (R : W → ℝ → W → Prop) : Prop :=
  ∀ w u, (∀ x : ℝ, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w

def IsHistory' {W : Type} (R : W → ℝ → W → Prop) (τ : ℝ → W) : Prop :=
  ∀ x y, R (τ x) (y - x) (τ y)

def coneTopology' {W : Type} (R : W → ℝ → W → Prop) : TopologicalSpace W :=
  generateFrom {s | ∃ w x, 0 < x ∧ s = cone R w x}

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

/-- The hedgehog: a centre and countably many rays. -/
inductive HH
  | c
  | p (n : ℕ) (t : {t : ℝ // 0 < t})

open HH

/-- The task relation: the centre loops; `c ⇒_x p n t` iff `t ≤ x`; each ray drifts forward
at speed at most `1` with no cross-ray tasks; negative durations by reflection. -/
def RHH : HH → ℝ → HH → Prop
  | c, _, c => True
  | c, x, p _ t => t.1 ≤ x
  | p _ t, x, c => t.1 ≤ -x
  | p n t, x, p m s =>
      n = m ∧ ((0 ≤ x ∧ t.1 ≤ s.1 ∧ s.1 ≤ t.1 + x) ∨ (x < 0 ∧ s.1 ≤ t.1 ∧ t.1 ≤ s.1 - x))

theorem RHH_refl (w : HH) (x : ℝ) (hx : 0 ≤ x) : RHH w x w := by
  cases w with
  | c => trivial
  | p n t => exact ⟨rfl, Or.inl ⟨hx, le_rfl, by linarith⟩⟩

theorem RHH_serial : Serial RHH := by
  intro w x hx
  exact ⟨⟨w, RHH_refl w x hx⟩, ⟨w, RHH_refl w x hx⟩⟩

theorem RHH_compositional : Compositional RHH := by
  intro w v x y hx hy
  cases w with
  | c =>
    cases v with
    | c =>
      constructor
      · intro _; exact ⟨c, trivial, trivial⟩
      · intro _; trivial
    | p m s =>
      constructor
      · intro h
        change s.1 ≤ x + y at h
        rcases le_or_gt s.1 y with hs | hs
        · exact ⟨c, trivial, hs⟩
        · refine ⟨p m ⟨s.1 - y, by linarith⟩, ?_, ⟨rfl, Or.inl ⟨hy, by simp; linarith, by simp⟩⟩⟩
          change s.1 - y ≤ x; linarith
      · rintro ⟨u, hu, huv⟩
        change s.1 ≤ x + y
        cases u with
        | c => change s.1 ≤ y at huv; linarith
        | p k t =>
          change t.1 ≤ x at hu
          obtain ⟨_, huv⟩ := huv
          rcases huv with ⟨_, _, h3⟩ | ⟨h1, _, _⟩
          · linarith
          · linarith
  | p n t =>
    cases v with
    | c =>
      constructor
      · intro h; exact absurd h (show ¬ (t.1 ≤ -(x + y)) by intro h; linarith [t.2])
      · rintro ⟨u, hu, huv⟩
        cases u with
        | c => exact absurd hu (show ¬ (t.1 ≤ -x) by intro h; linarith [t.2])
        | p k r => exact absurd huv (show ¬ (r.1 ≤ -y) by intro h; linarith [r.2])
    | p m s =>
      constructor
      · rintro ⟨rfl, h⟩
        rcases h with ⟨_, h2, h3⟩ | ⟨h1, _, _⟩
        · refine ⟨p _ ⟨min s.1 (t.1 + x), lt_min s.2 (by linarith [t.2])⟩,
            ⟨rfl, Or.inl ⟨hx, le_min h2 (by linarith), min_le_right _ _⟩⟩,
            ⟨rfl, Or.inl ⟨hy, min_le_left _ _, ?_⟩⟩⟩
          rcases min_choice s.1 (t.1 + x) with hm | hm <;> simp only [hm] <;> linarith
        · exact absurd h1 (by linarith)
      · rintro ⟨u, hu, huv⟩
        cases u with
        | c => exact absurd hu (show ¬ (t.1 ≤ -x) by intro h; linarith [t.2])
        | p k r =>
          obtain ⟨rfl, hu⟩ := hu
          obtain ⟨rfl, huv⟩ := huv
          refine ⟨rfl, ?_⟩
          rcases hu with ⟨_, h2, h3⟩ | ⟨h1, _, _⟩
          · rcases huv with ⟨_, h2', h3'⟩ | ⟨h1', _, _⟩
            · exact Or.inl ⟨by linarith, by linarith, by linarith⟩
            · exact absurd h1' (by linarith)
          · exact absurd h1 (by linarith)

/-- *Limit* holds: the centre is not instantaneously connected to any ray point, and each ray
is metric. -/
theorem RHH_limit : Limit' RHH := by
  intro w u h
  cases w with
  | c =>
    cases u with
    | c => rfl
    | p m t =>
      obtain ⟨y, hy, hR⟩ := h t.1 t.2
      change t.1 ≤ y at hR
      exact absurd (abs_lt.mp hy).2 (by linarith)
  | p n t =>
    cases u with
    | c =>
      obtain ⟨y, hy, hR⟩ := h t.1 t.2
      change t.1 ≤ -y at hR
      exact absurd (abs_lt.mp hy).1 (by linarith)
    | p m s =>
      obtain ⟨_, _, hnm, _⟩ := h 1 one_pos
      subst hnm
      have hst : ∀ x : ℝ, 0 < x → |s.1 - t.1| < x := by
        intro x hx
        obtain ⟨y, hy, _, hR⟩ := h x hx
        rcases hR with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
        · rw [abs_of_nonneg h1] at hy; rw [abs_of_nonneg (by linarith)]; linarith
        · rw [abs_of_neg h1] at hy; rw [abs_of_nonpos (by linarith)]; linarith
      have : |s.1 - t.1| = 0 := by
        by_contra hne
        have hpos : 0 < |s.1 - t.1| := lt_of_le_of_ne (abs_nonneg _) (Ne.symm hne)
        exact lt_irrefl _ (hst _ hpos)
      rw [abs_eq_zero, sub_eq_zero] at this
      exact congrArg (p _) (Subtype.ext this)

theorem t1Space_nbhdTopology_RHH : @T1Space HH (nbhdTopology' RHH) :=
  (t1Space_nbhdTopology_iff_limit' RHH).mpr RHH_limit

/-! ## `𝒩_F` is strictly below the final topology of all histories -/

/-- The centre together with the ray points `p n t` below the `n`-th ray's "tip" `1/(n+1)`. -/
def hedgehogOpen : Set HH := {v | ∀ n t, v = p n t → t.1 < 1 / ((n : ℝ) + 1)}

theorem c_mem_hedgehogOpen : c ∈ hedgehogOpen := fun _ _ h => HH.noConfusion h

/-- **`hedgehogOpen` is not `𝒩_F`-open**: every cone at the centre contains the tip
`p n ⟨1/(n+1)⟩` of some ray, since `1/(n+1) < x` for some `n`. -/
theorem not_isOpen_nbhdTopology_hedgehogOpen : ¬ IsOpen[nbhdTopology' RHH] hedgehogOpen := by
  intro h
  obtain ⟨x, hx, hc⟩ := h c c_mem_hedgehogOpen
  obtain ⟨n, hn⟩ := exists_nat_one_div_lt hx
  have hpos : 0 < 1 / ((n : ℝ) + 1) := by positivity
  have hmem : p n ⟨1 / ((n : ℝ) + 1), hpos⟩ ∈ cone RHH c x :=
    ⟨1 / ((n : ℝ) + 1), by rw [abs_of_pos hpos]; exact hn,
      mem_Fib.mpr (show 1 / ((n : ℝ) + 1) ≤ 1 / ((n : ℝ) + 1) from le_rfl)⟩
  exact lt_irrefl _ (hc hmem n _ rfl)

/-- A history visits at most one ray. -/
theorem RHH_history_single_ray {τ : ℝ → HH} (hτ : IsHistory' RHH τ) {a b : ℝ} {n m : ℕ}
    {t s : {t : ℝ // 0 < t}} (ha : τ a = p n t) (hb : τ b = p m s) : n = m := by
  have h := hτ a b
  rw [ha, hb] at h
  exact h.1

/-- The centre persists into the past: a history at `c` at time `z` was at `c` at every
earlier time (a ray point reaches `c` only in negative duration). -/
theorem RHH_history_centre_past {τ : ℝ → HH} (hτ : IsHistory' RHH τ) {z s : ℝ} (hz : τ z = c)
    (hs : s ≤ z) : τ s = c := by
  rcases hτs : τ s with _ | ⟨n, t⟩
  · rfl
  · exfalso
    have h := hτ s z
    rw [hz, hτs] at h
    change t.1 ≤ -(z - s) at h
    linarith [t.2]

/-- Leaving the centre takes time: `τ z = c` and `τ (z + s) = p n t` force `t ≤ s`. -/
theorem RHH_history_reach {τ : ℝ → HH} (hτ : IsHistory' RHH τ) {z s : ℝ} {n : ℕ}
    {t : {t : ℝ // 0 < t}} (hz : τ z = c) (hs : τ (z + s) = p n t) : t.1 ≤ s := by
  have h := hτ z (z + s)
  rw [hz, hs] at h
  change t.1 ≤ z + s - z at h
  linarith

/-- **Every history pulls `hedgehogOpen` back to an open set.** At a centre time, if the
history ever visits a ray it visits only that ray `n₀`, and reaching `p n₀ t` from the centre
takes time `≥ t`, so radius `1/(n₀+1)` works; if it never visits a ray any radius works. At a
ray time `p n t` with `t < 1/(n+1)`, the drift law bounds `|t' - t| ≤ |s|` on the same ray, so
radius `1/(n+1) - t` works. -/
theorem isOpen_preimage_hedgehogOpen_of_history {τ : ℝ → HH} (hτ : IsHistory' RHH τ) :
    IsOpen (τ ⁻¹' hedgehogOpen) := by
  rw [Metric.isOpen_iff]
  intro z hz
  rcases hτz : τ z with _ | ⟨n, t⟩
  · by_cases hvisit : ∃ n₀ s t₀, τ s = p n₀ t₀
    · obtain ⟨n₀, s₀, t₀, hs₀⟩ := hvisit
      refine ⟨1 / ((n₀ : ℝ) + 1), by positivity, ?_⟩
      intro y hy
      rw [Metric.mem_ball, Real.dist_eq] at hy
      show ∀ m t', τ y = p m t' → t'.1 < 1 / ((m : ℝ) + 1)
      intro m t' hy'
      have hm : m = n₀ := RHH_history_single_ray hτ hy' hs₀
      subst hm
      rcases le_or_gt y z with hyz | hyz
      · have := RHH_history_centre_past hτ hτz hyz
        rw [hy'] at this
        exact HH.noConfusion this
      · have hr := RHH_history_reach hτ hτz (s := y - z) (by simpa using hy')
        linarith [le_abs_self (y - z)]
    · push Not at hvisit
      refine ⟨1, one_pos, ?_⟩
      intro y _
      show ∀ m t', τ y = p m t' → t'.1 < 1 / ((m : ℝ) + 1)
      intro m t' hy'
      exact absurd hy' (hvisit m y t')
  · have ht : t.1 < 1 / ((n : ℝ) + 1) := hz n t hτz
    refine ⟨1 / ((n : ℝ) + 1) - t.1, sub_pos.mpr ht, ?_⟩
    intro y hy
    rw [Metric.mem_ball, Real.dist_eq] at hy
    show ∀ m t', τ y = p m t' → t'.1 < 1 / ((m : ℝ) + 1)
    intro m t' hy'
    have h := hτ z y
    rw [hτz, hy'] at h
    obtain ⟨rfl, h⟩ := h
    have hdist : |t'.1 - t.1| ≤ |y - z| := by
      rcases h with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
      · rw [abs_of_nonneg h1, abs_of_nonneg (by linarith)]; linarith
      · rw [abs_of_neg h1, abs_of_nonpos (by linarith)]; linarith
    linarith [le_abs_self (t'.1 - t.1)]

/-- **`𝒩_F` is strictly below the final topology of all histories**: `hedgehogOpen` is open
in every `coinduced τ`, hence in their supremum, but not in `𝒩_F`. -/
theorem finalTopology_ne_nbhdTopology_RHH :
    (⨆ τ : {τ : ℝ → HH // IsHistory' RHH τ}, coinduced τ.1 inferInstance) ≠
      nbhdTopology' RHH := by
  intro heq
  apply not_isOpen_nbhdTopology_hedgehogOpen
  rw [← heq, isOpen_iSup_iff]
  intro τ
  rw [isOpen_coinduced]
  exact isOpen_preimage_hedgehogOpen_of_history τ.2

/-! ## A history that is not `𝒯_F`-continuous, inside the class -/

/-- `c ∈ (p n t)_x` iff `t < x`. -/
theorem c_mem_cone_p {n : ℕ} {t : {t : ℝ // 0 < t}} {x : ℝ} :
    c ∈ cone RHH (p n t) x ↔ t.1 < x := by
  constructor
  · rintro ⟨y, hy, hR⟩
    change t.1 ≤ -y at hR
    linarith [(abs_lt.mp hy).1]
  · intro h
    exact ⟨-t.1, by rw [abs_neg, abs_of_pos t.2]; exact h, show t.1 ≤ -(-t.1) by rw [neg_neg]⟩

/-- Two cross-ray cones meet only at the centre. -/
theorem singleton_c_eq_inter_cone :
    ({c} : Set HH) = cone RHH (p 0 ⟨1, one_pos⟩) 2 ∩ cone RHH (p 1 ⟨1, one_pos⟩) 2 := by
  ext v
  constructor
  · rintro rfl
    exact ⟨c_mem_cone_p.mpr (show (1 : ℝ) < 2 by norm_num),
      c_mem_cone_p.mpr (show (1 : ℝ) < 2 by norm_num)⟩
  · rintro ⟨⟨y, _, h0⟩, ⟨y', _, h1⟩⟩
    cases v with
    | c => rfl
    | p n t => exact absurd ((mem_Fib.mp h0).1.trans (mem_Fib.mp h1).1.symm) (by decide)

/-- `{c}` is `𝒯_F`-open (a finite intersection of cones). -/
theorem isOpen_coneTopology_singleton_c : IsOpen[coneTopology' RHH] ({c} : Set HH) := by
  rw [singleton_c_eq_inter_cone]
  letI := coneTopology' RHH
  exact IsOpen.inter (isOpen_generateFrom_of_mem ⟨_, _, two_pos, rfl⟩)
    (isOpen_generateFrom_of_mem ⟨_, _, two_pos, rfl⟩)

/-- **A hedgehog history that is not `𝒯_F`-continuous**: "`c` until time `0`, then out ray
`0` at unit speed" respects `RHH`, but the preimage of the `𝒯_F`-open `{c}` is `(-∞, 0]`. -/
theorem not_continuous_coneTopology_RHH_history :
    ∃ τ : ℝ → HH, IsHistory' RHH τ ∧ ¬ @Continuous ℝ HH _ (coneTopology' RHH) τ := by
  refine ⟨fun s => if h : s ≤ 0 then c else p 0 ⟨s, not_le.mp h⟩, ?_, ?_⟩
  · intro x y
    dsimp only
    split_ifs with hx hy hy
    · trivial
    · show y ≤ y - x; linarith
    · show x ≤ -(y - x); linarith
    · show (0 : ℕ) = 0 ∧ ((0 ≤ y - x ∧ x ≤ y ∧ y ≤ x + (y - x)) ∨
        (y - x < 0 ∧ y ≤ x ∧ x ≤ y - (y - x)))
      refine ⟨rfl, ?_⟩
      rcases le_or_gt x y with hxy | hxy
      · exact Or.inl ⟨by linarith, hxy, by linarith⟩
      · exact Or.inr ⟨by linarith, hxy.le, by linarith⟩
  · intro hcont
    letI := coneTopology' RHH
    have hpre := hcont.isOpen_preimage ({c} : Set HH) isOpen_coneTopology_singleton_c
    have hpre' : (fun s : ℝ => if h : s ≤ 0 then c else p 0 ⟨s, not_le.mp h⟩) ⁻¹'
        ({c} : Set HH) = Set.Iic 0 := by
      ext s
      simp only [Set.mem_preimage, Set.mem_singleton_iff, Set.mem_Iic]
      split_ifs with hs
      · exact ⟨fun _ => hs, fun _ => rfl⟩
      · exact ⟨fun h => h.elim, fun h => absurd h hs⟩
    rw [hpre', Metric.isOpen_iff] at hpre
    obtain ⟨ε, hε, hb⟩ := hpre 0 (Set.mem_Iic.mpr le_rfl)
    have hmem : ε / 2 ∈ Metric.ball (0 : ℝ) ε := by
      rw [Metric.mem_ball, Real.dist_eq, sub_zero, abs_of_pos (half_pos hε)]
      exact half_lt_self hε
    have := hb hmem
    rw [Set.mem_Iic] at this
    linarith

/-! ## Axiom audit: every headline theorem uses only `propext`, `Classical.choice`, `Quot.sound` -/

#print axioms RHH_serial
#print axioms RHH_compositional
#print axioms RHH_limit
#print axioms t1Space_nbhdTopology_RHH
#print axioms not_isOpen_nbhdTopology_hedgehogOpen
#print axioms isOpen_preimage_hedgehogOpen_of_history
#print axioms finalTopology_ne_nbhdTopology_RHH
#print axioms not_continuous_coneTopology_RHH_history

end FormalSystem.Semantics.TaskFrame
