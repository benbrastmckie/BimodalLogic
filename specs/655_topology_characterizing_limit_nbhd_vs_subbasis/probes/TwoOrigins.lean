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

/-! ## `𝒯_F = 𝒩_F` on the two-origin frame

The route through a `Triangle'` shortcut condition is **not available** on this frame:
`Triangle' RTO` is false (`not_triangle_RTO` below), because the mixed-sign two-step path
`o true ⇒₁ p ⟨1⟩ ⇒₋₁ o false` joins the two origins while `RTO (o true) t (o false)` is
`true = false` at every duration. The equality is proved instead by the direct route of
`NbhdTopology.lean`'s `coneTopology_eq_nbhdTopology_iff`: every cone of `RTO` is `𝒩_F`-open. -/

/-- `𝒯_F` (`def:task-topology`), restated for `D = ℝ` (this file is standalone). -/
def coneTopology' {W : Type} (R : W → ℝ → W → Prop) : TopologicalSpace W :=
  generateFrom {s | ∃ w x, 0 < x ∧ s = cone R w x}

theorem mem_cone_self' {W : Type} {R : W → ℝ → W → Prop} {w : W} (h0 : R w 0 w) {x : ℝ}
    (hx : 0 < x) : w ∈ cone R w x :=
  ⟨0, by rw [abs_zero]; exact hx, h0⟩

/-- `𝒯_F ≤ 𝒩_F` given only `R w 0 w`, restated from `NbhdTopology.lean` for `D = ℝ`. -/
theorem coneTopology_le_nbhdTopology' {W : Type} (R : W → ℝ → W → Prop) (h0 : ∀ w, R w 0 w) :
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

/-- `𝒯_F = 𝒩_F` exactly when every cone is `𝒩_F`-open, restated for `D = ℝ`. -/
theorem coneTopology_eq_nbhdTopology_iff' {W : Type} {R : W → ℝ → W → Prop}
    (h0 : ∀ w, R w 0 w) :
    coneTopology' R = nbhdTopology' R ↔
      ∀ w x, 0 < x → IsOpen[nbhdTopology' R] (cone R w x) := by
  constructor
  · intro h w x hx
    rw [← h]
    exact isOpen_generateFrom_of_mem ⟨w, x, hx, rfl⟩
  · intro h
    refine le_antisymm (coneTopology_le_nbhdTopology' R h0) ?_
    rw [coneTopology', le_generateFrom_iff_subset_isOpen]
    rintro s ⟨w, x, hx, rfl⟩
    exact h w x hx

/-- The mixed-sign shortcut condition of `NbhdTopology.lean`, restated for `D = ℝ`. -/
def Triangle' {W : Type} (R : W → ℝ → W → Prop) : Prop :=
  ∀ w u v y z, R w y u → R u z v → ∃ t, |t| ≤ |y| + |z| ∧ R w t v

/-- **The shortcut condition fails on this frame.** `o true ⇒₁ p ⟨1⟩` and `p ⟨1⟩ ⇒₋₁ o false`
are both tasks, but no duration joins the two origins: `RTO (o b) t (o b')` is `b = b'`. This
refutes the route through `Triangle'`; the cones are nevertheless `𝒩_F`-open (next lemma). -/
theorem not_triangle_RTO : ¬ Triangle' RTO := by
  intro h
  obtain ⟨t, _, hR⟩ := h (o true) (p ⟨1, one_pos⟩) (o false) 1 (-1)
    (show (1 : ℝ) ≤ 1 from le_rfl) (show (1 : ℝ) ≤ -(-1) by norm_num)
  exact Bool.noConfusion (hR : true = false)

/-! ### Cone membership: `(o b)_x = {o b} ∪ {p t : t < x}` and
`(p t)_x = {p s : |s - t| < x} ∪ {o true, o false : t < x}` -/

theorem o_mem_cone_o {b b' : Bool} {x : ℝ} (hx : 0 < x) :
    o b' ∈ cone RTO (o b) x ↔ b = b' := by
  constructor
  · rintro ⟨y, _, hR⟩; exact hR
  · intro h; exact ⟨0, by rwa [abs_zero], h⟩

theorem p_mem_cone_o {b : Bool} {t : {t : ℝ // 0 < t}} {x : ℝ} :
    p t ∈ cone RTO (o b) x ↔ t.1 < x := by
  constructor
  · rintro ⟨y, hy, hR⟩
    change t.1 ≤ y at hR
    exact lt_of_le_of_lt hR (lt_of_le_of_lt (le_abs_self y) hy)
  · intro h
    exact ⟨t.1, by rwa [abs_of_pos t.2], show t.1 ≤ t.1 from le_rfl⟩

theorem o_mem_cone_p {b : Bool} {t : {t : ℝ // 0 < t}} {x : ℝ} :
    o b ∈ cone RTO (p t) x ↔ t.1 < x := by
  constructor
  · rintro ⟨y, hy, hR⟩
    change t.1 ≤ -y at hR
    exact lt_of_le_of_lt hR (lt_of_le_of_lt (neg_le_abs y) hy)
  · intro h
    refine ⟨-t.1, by rwa [abs_neg, abs_of_pos t.2], ?_⟩
    change t.1 ≤ -(-t.1)
    linarith

theorem p_mem_cone_p {t s : {t : ℝ // 0 < t}} {x : ℝ} :
    p s ∈ cone RTO (p t) x ↔ |s.1 - t.1| < x := by
  constructor
  · rintro ⟨y, hy, hR⟩
    rcases hR with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
    · rw [abs_of_nonneg h1] at hy
      rw [abs_of_nonneg (by linarith : (0 : ℝ) ≤ s.1 - t.1)]
      linarith
    · rw [abs_of_neg h1] at hy
      rw [abs_of_nonpos (by linarith : s.1 - t.1 ≤ (0 : ℝ))]
      linarith
  · intro h
    rcases le_or_gt t.1 s.1 with hts | hts
    · exact ⟨s.1 - t.1, h, Or.inl ⟨by linarith, hts, by linarith⟩⟩
    · exact ⟨s.1 - t.1, h, Or.inr ⟨by linarith, by linarith, by linarith⟩⟩

/-- **Every cone of `RTO` is `𝒩_F`-open**, with explicit radii: at `p t ∈ (o b)_x` use
`min t (x - t)` (small enough to exclude both origins, since an origin in `(p t)_ε` needs
`t < ε`); at `p s ∈ (p t)_x` use `x - |s - t|`; at `o b ∈ (p t)_x` use `x - t`. -/
theorem isOpen_nbhdTopology_cone_RTO (w : TO) (x : ℝ) (hx : 0 < x) :
    IsOpen[nbhdTopology' RTO] (cone RTO w x) := by
  cases w with
  | o b =>
    intro u hu
    cases u with
    | o b' =>
      obtain rfl : b = b' := (o_mem_cone_o hx).mp hu
      exact ⟨x, hx, subset_rfl⟩
    | p t =>
      have ht : t.1 < x := p_mem_cone_o.mp hu
      refine ⟨min t.1 (x - t.1), lt_min t.2 (by linarith), fun v hv => ?_⟩
      cases v with
      | o b' =>
        exact absurd (o_mem_cone_p.mp hv) (by have := min_le_left t.1 (x - t.1); linarith)
      | p s =>
        have hs : |s.1 - t.1| < min t.1 (x - t.1) := p_mem_cone_p.mp hv
        refine p_mem_cone_o.mpr ?_
        have h1 : s.1 - t.1 ≤ |s.1 - t.1| := le_abs_self _
        have h2 := min_le_right t.1 (x - t.1)
        linarith
  | p t =>
    intro u hu
    cases u with
    | o b =>
      have ht : t.1 < x := o_mem_cone_p.mp hu
      refine ⟨x - t.1, by linarith, fun v hv => ?_⟩
      cases v with
      | o b' => exact o_mem_cone_p.mpr ht
      | p s =>
        have hs : s.1 < x - t.1 := p_mem_cone_o.mp hv
        refine p_mem_cone_p.mpr ?_
        rw [abs_lt]
        constructor <;> linarith [s.2, t.2]
    | p s =>
      have hs : |s.1 - t.1| < x := p_mem_cone_p.mp hu
      refine ⟨x - |s.1 - t.1|, by linarith, fun v hv => ?_⟩
      cases v with
      | o b =>
        have h1 : s.1 < x - |s.1 - t.1| := o_mem_cone_p.mp hv
        refine o_mem_cone_p.mpr ?_
        have h2 : t.1 - s.1 ≤ |s.1 - t.1| := by
          rw [abs_sub_comm]; exact le_abs_self _
        linarith
      | p r =>
        have h1 : |r.1 - s.1| < x - |s.1 - t.1| := p_mem_cone_p.mp hv
        refine p_mem_cone_p.mpr ?_
        have h2 : |r.1 - t.1| ≤ |r.1 - s.1| + |s.1 - t.1| := abs_sub_le _ _ _
        linarith

/-- **`𝒯_F = 𝒩_F` on the two-origin frame**, by cone-openness rather than by a shortcut
condition (which fails here: `not_triangle_RTO`). -/
theorem coneTopology_eq_nbhdTopology_RTO : coneTopology' RTO = nbhdTopology' RTO :=
  (coneTopology_eq_nbhdTopology_iff' (fun w => RTO_refl w 0 le_rfl)).mpr
    isOpen_nbhdTopology_cone_RTO

/-- **`𝒯_F` is not Hausdorff either** on this frame: it coincides with `𝒩_F`, which separates
neither origin from the other. So "T1 but not Hausdorff" is not an artefact of the choice of
topology. -/
theorem not_t2Space_coneTopology_RTO : ¬ @T2Space TO (coneTopology' RTO) := by
  rw [coneTopology_eq_nbhdTopology_RTO]
  exact not_t2Space_nbhdTopology_RTO

/-! ## Axiom audit: every headline theorem uses only `propext`, `Classical.choice`, `Quot.sound` -/

#print axioms RTO_serial
#print axioms RTO_compositional
#print axioms RTO_limit
#print axioms t1Space_nbhdTopology_RTO
#print axioms not_t2Space_nbhdTopology_RTO
#print axioms not_triangle_RTO
#print axioms isOpen_nbhdTopology_cone_RTO
#print axioms coneTopology_eq_nbhdTopology_RTO
#print axioms not_t2Space_coneTopology_RTO

end FormalSystem.Semantics.TaskFrame
