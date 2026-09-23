/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.StateTopology
import FormalSystem.Semantics.ShiftSet

/-!
# Frames that satisfy some `def:frame` constraints and not others

**This module is the acceptance test for the general/regular split.** Every frame in it is an
ordinary `FrameOver` value with the constraints it satisfies proved as *separate facts*, and with
at least one constraint deliberately **not** claimed. None of it is expressible while
`def:frame`'s four constraints are fields of the frame structure: a frame that violates one of
them cannot be written down at all, so neither can any statement distinguishing the constraints.
See `Semantics/TaskFrame.lean`'s header section "General frames and the regular class".

## The four-state funnel

`funnelFrame` is the named witness. Its carrier is `Fin 4`; at a positive duration `w ⇒_x u`
holds when `w = u` or `w` is low (`< 2`) and `u` is high (`≥ 2`), and negative durations are the
reflection of that. It satisfies *Seriality*, *Compositionality* and *Saturation* —
`funnel_serial`, `funnel_compositional`, `funnel_saturation`, each proved on its own — and it
**fails *Limit*** (`funnel_not_limit`), because state `2` lies in every positive cone of state `0`.

Two consequences make it the witness this refactor exists for:

* `funnel_t1Space_coneTopology` — the cone topology `𝒯_F` of `def:task-topology` is T1 on it
  (indeed discrete), **although *Limit* fails**. So the converse of `app:topology-t1` is false,
  and `FrameOver.t1Space_iff_limit` is a biconditional only for `𝒩_F`.
* `funnel_sep_of_history` — the shift-separation condition `ShiftSet.sep` holds on the funnel's
  histories **although *Limit* fails**. So `ShiftSet.rev_sep_of_limit` (*Limit* ⟹ separation) is
  genuinely one-directional.

`funnelFrame` is deliberately **not** an `IsRegular` instance, and must never be given one: its
whole content is that it is a frame which is not regular.

## Two more frames, with a different constraint profile

`TwoOrigins.frame` (the half-line with two origins) and `Hedgehog.frame` (a centre with countably
many rays) each satisfy *Seriality*, *Compositionality* and *Limit*, each proved separately, and
**do not claim *Saturation***. That is deliberate and is stated in their own docstrings: the
paper's argument for *Saturation* on them runs through a "shadow" map that is not formalised
here, and supplying it would be new mathematics rather than a consequence of this refactor.
Neither is an `IsRegular` instance. Their profile — three constraints proved, one not claimed —
is exactly what the general frame structure is for.

* `TwoOrigins.frame_t1Space` and `TwoOrigins.frame_not_t2Space` — a state space that is **T1 but
  not Hausdorff**. *Limit* gives T1 (`FrameOver.t1Space_iff_limit`); nothing in `def:frame` gives
  T2, because the two origins are distinct states whose short-task futures overlap at every
  scale.
* `Hedgehog.finalTopology_ne_nbhdTopology` — `TaskFrame.finalTopology_le_nbhdTopology` says
  `𝒩_F` sits below the final topology of all histories; this frame shows the inclusion is
  **strict**. A cone at the centre reaches every ray at once, while a history follows one ray.
* `Hedgehog.not_continuous_coneTopology_history` — even inside the three-constraint class, a
  history need not be `𝒯_F`-continuous.

## Supporting facts

* `funnelRel_nbhdTopology_eq_top`, `funnel_not_t1Space` — `𝒩_F` is indiscrete on the funnel, as
  `FrameOver.t1Space_iff_limit` predicts from the failure of *Limit*.
* `funnelRel_not_isOpen_cone` — a cone need not be `𝒩_F`-open. `𝒩_F` is the finest topology in
  which every *neighbourhood* contains a cone, not one in which the cones are neighbourhoods.
* `funnel_one_way_pair` — the funnel contains a one-way instantaneous pair, the configuration
  `TaskFrame.limit_of_t1Space_coneTopology` says must be present whenever `𝒯_F` is T1 and
  *Limit* fails.
* `TaskFrame.nbhdTopology_isOpen_iff_int` and its three siblings — over `ℤ` both topologies are
  the partition topology of `⇒₀`, and *Limit*, discreteness and `⇒₀ ⊆ id` all coincide. This is
  why the funnel needs a densely ordered duration type: over `ℤ` no such witness exists.
* `funnel_not_continuous_coneTopology` — a history need not be `𝒯_F`-continuous, although every
  history is `𝒩_F`-continuous (`TaskFrame.continuous_nbhdTopology_of_history`).

## Import weight

Like `Semantics/StateTopology.lean`, this module is a leaf: nothing under `FormalSystem/` imports
it and the generated library root reaches it directly. See that module's header.

## References

- JPL paper `def:frame`, `def:task-topology`, `app:topology-t1`
-/

-- Inherited from `Semantics/StateTopology.lean`: `coneTopology` and `nbhdTopology` are `def`s of
-- class type, which `warn.classDefReducibility` reports at every mention.
set_option warn.classDefReducibility false

open Topology TopologicalSpace Set

namespace FormalSystem.Semantics.TaskFrame

/-! ## Over `ℤ`, both topologies are the partition topology of `⇒₀`

These are general facts about a bare relation over `ℤ`, not about any particular frame, and they
are what makes the four-state funnel's `[DenselyOrdered]` hypothesis necessary rather than
convenient: over `ℤ` the smallest positive cone is the zero fibre, so `𝒯_F = 𝒩_F` and *Limit*,
discreteness and `⇒₀ ⊆ id` all coincide. No funnel-shaped witness exists there. -/

variable {W : Type}

/-- Over `ℤ` the radius-one cone is the zero fibre: `|y| < 1` forces `y = 0`. -/
theorem cone_int_one (R : W → ℤ → W → Prop) (w : W) : cone R w 1 = {u | R w 0 u} := by
  ext u
  simp only [mem_cone, Int.abs_lt_one_iff, Set.mem_setOf_eq]
  constructor
  · rintro ⟨y, rfl, h⟩; exact h
  · intro h; exact ⟨0, rfl, h⟩

/-- Over `ℤ`, `O` is `𝒩_F`-open exactly when it is closed under `⇒₀`. -/
theorem nbhdTopology_isOpen_iff_int (R : W → ℤ → W → Prop) {O : Set W} :
    IsOpen[nbhdTopology R] O ↔ ∀ w ∈ O, ∀ u, R w 0 u → u ∈ O := by
  rw [nbhdTopology_isOpen_iff]
  constructor
  · intro h w hw u hR
    obtain ⟨x, hx, hc⟩ := h w hw
    exact hc ⟨0, by simpa using hx, hR⟩
  · intro h w hw
    refine ⟨1, one_pos, ?_⟩
    rw [cone_int_one]
    exact fun u hu => h w hw u hu

/-- Over `ℤ`, *Limit* is exactly `⇒₀ ⊆ id`. -/
theorem limit_int_iff (R : W → ℤ → W → Prop) : Limit R ↔ ∀ w u, R w 0 u → u = w := by
  constructor
  · intro h w u hR
    exact h w u fun x hx => ⟨0, by simpa using hx, hR⟩
  · intro h w u hu
    obtain ⟨y, hy, hR⟩ := hu 1 one_pos
    rw [Int.abs_lt_one_iff] at hy
    exact h w u (hy ▸ hR)

/-- Over `ℤ`, `𝒩_F` is discrete exactly when *Limit* holds. -/
theorem discreteTopology_nbhdTopology_int_iff (R : W → ℤ → W → Prop) :
    @DiscreteTopology W (nbhdTopology R) ↔ Limit R := by
  rw [discreteTopology_nbhdTopology_iff, limit_int_iff]
  constructor
  · intro h w u hR
    obtain ⟨x, hx, hc⟩ := h w
    exact hc ⟨0, by simpa using hx, hR⟩
  · intro h w
    refine ⟨1, one_pos, ?_⟩
    rw [cone_int_one]
    exact fun u hu => h w u hu

end FormalSystem.Semantics.TaskFrame

namespace FormalSystem.Semantics.StateTopology

open FormalSystem.Semantics.TaskFrame

variable {D : TemporalOrder}

/-! ## The four-state funnel -/

/--
**The funnel relation** on `Fin 4`: at duration `0` it is the identity; at a positive duration
`w ⇒_x u` holds when `w = u` or `w` is *low* (`w < 2`) and `u` is *high* (`u ≥ 2`); at a negative
duration it is the reflection of that.

The name is the picture: the two low states pour into the two high states at every positive
duration, however small, and nothing comes back.
-/
def funnelRel (w : Fin 4) (x : ↑D) (u : Fin 4) : Prop :=
  (x = 0 ∧ w = u) ∨ (0 < x ∧ (w = u ∨ (w.val < 2 ∧ 2 ≤ u.val))) ∨
    (x < 0 ∧ (w = u ∨ (u.val < 2 ∧ 2 ≤ w.val)))

@[simp] theorem funnelRel_zero {w u : Fin 4} : funnelRel w (0 : ↑D) u ↔ w = u := by
  simp [funnelRel]

theorem funnelRel_pos {w u : Fin 4} {x : ↑D} (hx : 0 < x) :
    funnelRel w x u ↔ (w = u ∨ (w.val < 2 ∧ 2 ≤ u.val)) := by
  simp [funnelRel, hx.ne', hx, not_lt.mpr hx.le]

theorem funnelRel_neg {w u : Fin 4} {x : ↑D} (hx : x < 0) :
    funnelRel w x u ↔ (w = u ∨ (u.val < 2 ∧ 2 ≤ w.val)) := by
  simp [funnelRel, hx.ne, hx, not_lt.mpr hx.le]

theorem funnelRel_refl (w : Fin 4) (x : ↑D) : funnelRel w x w := by
  rcases lt_trichotomy x 0 with h | h | h
  · exact (funnelRel_neg h).mpr (Or.inl rfl)
  · subst h; exact funnelRel_zero.mpr rfl
  · exact (funnelRel_pos h).mpr (Or.inl rfl)

/-- The funnel relation obeys the reflection law at every duration, including zero. -/
theorem funnelRel_reflection_imp {w u : Fin 4} {x : ↑D} (h : funnelRel w x u) :
    funnelRel u (-x) w := by
  rcases lt_trichotomy x 0 with hx | hx | hx
  · rw [funnelRel_neg hx] at h
    rw [funnelRel_pos (neg_pos.mpr hx)]
    rcases h with h | h
    · exact Or.inl h.symm
    · exact Or.inr h
  · subst hx; rw [neg_zero, funnelRel_zero] at *; exact h.symm
  · rw [funnelRel_pos hx] at h
    rw [funnelRel_neg (neg_neg_iff_pos.mpr hx)]
    rcases h with h | h
    · exact Or.inl h.symm
    · exact Or.inr h

/-- The reflection law as the biconditional `FrameOver.ofReflective` asks for. -/
theorem funnelRel_reflection (w : Fin 4) (x : ↑D) (u : Fin 4) :
    funnelRel w x u ↔ funnelRel u (-x) w :=
  ⟨funnelRel_reflection_imp, fun h => by simpa using funnelRel_reflection_imp h⟩

/--
**The four-state funnel, as a general task frame.**

A general frame: its data is a carrier, a relation on the positive cone, and nothing else — no
`def:frame` constraint is asked for at its construction. That is the point: the frame exists, and
which constraints it satisfies is a separate question, answered one at a time below.

Written as a **literal structure** rather than through `FrameOver.ofReflective`, for the reason
that constructor's own docstring records: `ofReflective` is a plain definition, so a frame built
by it has a world-state type that reduces only at default transparency, and the decision
procedures below (`decide` over `Fin 4`, the numerals `0`/`2`, `Set.Finite`) need
`funnelFrame.WorldState` to reduce to `Fin 4` at *reducible* transparency. The reflection law
(`funnelRel_reflection`) is still what makes the restriction-and-extension round trip work, and
`funnelFrame_taskRel_eq` is the bridge it proves.

**Deliberately not an `IsRegular` instance, and it must never be given one.** *Limit* fails on it
(`funnel_not_limit`), so it is a frame and not a regular frame. Before the general/regular split
this value could not be written down.
-/
@[reducible] def funnelFrame : FrameOver D where
  WorldState := Fin 4
  worldNonempty := ⟨0⟩
  PosRel w x u := funnelRel w (x : ↑D) u

/-- The funnel frame's task relation **is** the funnel relation, as an equation of relations —
so every fact about `funnelRel` below is a fact about the frame. This is
`TaskFrame.reflect_eq_of_reflective` at `funnelRel_reflection`: the extension of the restriction
of a reflective relation is the relation again. -/
@[simp] theorem funnelFrame_taskRel_eq : (funnelFrame (D := D)).TaskRel = funnelRel :=
  TaskFrame.reflect_eq_of_reflective funnelRel funnelRel_reflection

/-! ### Three of the four constraints hold, each proved separately

Each constraint is proved first over the bare relation `funnelRel`, where the four states are
literally `Fin 4` and `decide` applies, and then transported to the frame by
`funnelFrame_taskRel_eq`. The frame-level form is the one the general/regular split makes
meaningful: it is a constraint *predicated of* a frame, not a field the frame carries. -/

/-- *Seriality* for the funnel relation: every state loops at every duration. -/
theorem funnelRel_serial : Serial (funnelRel (D := D)) :=
  fun w x _ => ⟨⟨w, funnelRel_refl w x⟩, ⟨w, funnelRel_refl w x⟩⟩

/-- *Compositionality* for the funnel relation, both halves. The positive-duration case is a
decidable check over the four states. -/
theorem funnelRel_compositional : Compositional (funnelRel (D := D)) := by
  intro w v x y hx hy
  rcases eq_or_lt_of_le hx with hx0 | hxpos
  · subst hx0
    rw [zero_add]
    constructor
    · intro h; exact ⟨w, funnelRel_zero.mpr rfl, h⟩
    · rintro ⟨u, h1, h2⟩; rw [funnelRel_zero] at h1; subst h1; exact h2
  rcases eq_or_lt_of_le hy with hy0 | hypos
  · subst hy0
    rw [add_zero]
    constructor
    · intro h; exact ⟨v, h, funnelRel_zero.mpr rfl⟩
    · rintro ⟨u, h1, h2⟩; rw [funnelRel_zero] at h2; subst h2; exact h1
  simp only [funnelRel_pos hxpos, funnelRel_pos hypos, funnelRel_pos (add_pos hxpos hypos)]
  revert w v
  decide

/-- *Saturation* for the funnel relation, by `cor:saturation-finite`: the carrier is finite. -/
theorem funnelRel_saturation : Saturation (funnelRel (D := D)) :=
  saturation_of_finite _

/-- **The funnel satisfies *Seriality*** (`def:frame#Seriality`), as a fact about the frame. -/
theorem funnel_serial : Serial (funnelFrame (D := D)).TaskRel := by
  rw [funnelFrame_taskRel_eq]; exact funnelRel_serial

/-- **The funnel satisfies *Compositionality*** (`def:frame#Compositionality`), as a fact about
the frame. -/
theorem funnel_compositional : Compositional (funnelFrame (D := D)).TaskRel := by
  rw [funnelFrame_taskRel_eq]; exact funnelRel_compositional

/-- **The funnel satisfies *Saturation*** (`def:frame#Saturation`), as a fact about the frame. -/
theorem funnel_saturation : Saturation (funnelFrame (D := D)).TaskRel := by
  rw [funnelFrame_taskRel_eq]; exact funnelRel_saturation

/-! ### *Limit* fails — the acceptance test -/

/-- Over a densely ordered duration type, membership in a positive cone of the funnel relation is
the *symmetric* funnel relation: a low state and a high state lie in each other's every cone. -/
theorem mem_cone_funnelRel [DenselyOrdered ↑D] {w u : Fin 4} {x : ↑D} (hx : 0 < x) :
    u ∈ cone (funnelRel (D := D)) w x ↔
      (w = u ∨ (w.val < 2 ∧ 2 ≤ u.val) ∨ (u.val < 2 ∧ 2 ≤ w.val)) := by
  constructor
  · rintro ⟨y, -, hR0⟩
    have hR : funnelRel w y u := hR0
    rcases lt_trichotomy y 0 with hy | hy | hy
    · rw [funnelRel_neg hy] at hR; tauto
    · subst hy; rw [funnelRel_zero] at hR; exact Or.inl hR
    · rw [funnelRel_pos hy] at hR; tauto
  · intro h
    obtain ⟨y, hy0, hyx⟩ := exists_between hx
    rcases h with h | h | h
    · exact ⟨0, by rw [abs_zero]; exact hx, funnelRel_zero.mpr h⟩
    · exact ⟨y, by rw [abs_of_pos hy0]; exact hyx, (funnelRel_pos hy0).mpr (Or.inr h)⟩
    · exact ⟨-y, by rw [abs_neg, abs_of_pos hy0]; exact hyx,
        (funnelRel_neg (neg_neg_iff_pos.mpr hy0)).mpr (Or.inr h)⟩

/-- *Limit* fails for the funnel relation: state `2` lies in every positive cone of state `0`. -/
theorem funnelRel_not_limit [DenselyOrdered ↑D] : ¬ TaskFrame.Limit (funnelRel (D := D)) := by
  intro h
  have h2 : (2 : Fin 4) = 0 :=
    h 0 2 fun x hx => (mem_cone_funnelRel hx).mpr (Or.inr (Or.inl (by decide)))
  exact absurd h2 (by decide)

/--
**`Limit` fails on the funnel**, as a fact about the frame: state `2` lies in every positive cone
of state `0`, yet `2 ≠ 0`.

This is one half of the acceptance test. It is not a statement *about* a regular frame with a
constraint removed — it is a statement about a frame, of a constraint that frame does not have.

*Limit* is the constraint this frame does not satisfy.

Paper: `def:frame#Limit`
-/
theorem funnel_not_limit [DenselyOrdered ↑D] :
    ¬ TaskFrame.Limit (funnelFrame (D := D)).TaskRel := by
  rw [funnelFrame_taskRel_eq]; exact funnelRel_not_limit

/-- Each singleton is the finite intersection of the cones centred at the members of one cone,
`{w} = ⋂_{v ∈ (w)_x} (v)_x` — a decidable check over the four states. -/
theorem funnelRel_singleton_eq_biInter_cone [DenselyOrdered ↑D] (w : Fin 4) {x : ↑D}
    (hx : 0 < x) :
    ({w} : Set (Fin 4)) = ⋂ v ∈ cone (funnelRel (D := D)) w x, cone (funnelRel (D := D)) v x := by
  ext u
  simp only [Set.mem_singleton_iff, Set.mem_iInter, mem_cone_funnelRel hx]
  revert u w
  decide

/-- **`𝒯_F` is discrete on the funnel**: every singleton is a finite intersection of cones. -/
theorem funnelRel_discreteTopology_coneTopology [DenselyOrdered ↑D] :
    @DiscreteTopology (Fin 4) (coneTopology (funnelRel (D := D))) := by
  letI := coneTopology (funnelRel (D := D))
  rw [discreteTopology_iff_isOpen_singleton]
  intro w
  obtain ⟨x, hx⟩ := exists_pos_of_nontrivial (D := ↑D)
  rw [funnelRel_singleton_eq_biInter_cone w hx]
  exact (cone (funnelRel (D := D)) w x).toFinite.isOpen_biInter
    fun v _ => isOpen_generateFrom_of_mem ⟨v, x, hx, rfl⟩

/-- The funnel frame's cone topology **is** the cone topology of the funnel relation. -/
theorem funnel_coneTop_eq :
    FrameOver.coneTop (funnelFrame (D := D)) = coneTopology (funnelRel (D := D)) := by
  unfold FrameOver.coneTop
  rw [funnelFrame_taskRel_eq]

/--
**THE ACCEPTANCE TEST.** The cone topology `𝒯_F` of `def:task-topology` is T1 on the funnel's
state space **although *Limit* fails there** (`funnel_not_limit`).

Neither this frame nor this statement can be written down while `def:frame`'s four constraints
are fields of `FrameOver`: there is then no such thing as a frame violating *Limit*, so the
contrast has nothing to be a contrast between. Together with `funnel_not_limit` this pair is the
evidence that the general/regular split achieved its purpose.

Mathematically it says the converse of `app:topology-t1` is **false**: `𝒯_F` being T1 does not
give *Limit* back. The gap is exactly the one-way instantaneous pairs
(`TaskFrame.limit_of_t1Space_coneTopology`), and `funnel_one_way_pair` exhibits one.

This refutes the converse of that result.

Paper: `app:topology-t1`
-/
theorem funnel_t1Space_coneTopology [DenselyOrdered ↑D] :
    @T1Space (Fin 4) (FrameOver.coneTop (funnelFrame (D := D))) := by
  rw [funnel_coneTop_eq]
  letI := coneTopology (funnelRel (D := D))
  haveI := funnelRel_discreteTopology_coneTopology (D := D)
  infer_instance

/-! ### `𝒩_F` is indiscrete on the funnel -/

/-- **`𝒩_F` is indiscrete on the funnel**: a cone at a low state drags in the high states, whose
cones drag the low states back, so every nonempty `𝒩_F`-open set is everything. -/
theorem funnelRel_nbhdTopology_eq_top [DenselyOrdered ↑D] :
    nbhdTopology (funnelRel (D := D)) = ⊤ := by
  apply TopologicalSpace.ext
  funext O
  apply propext
  rw [isOpen_top_iff]
  change (∀ w ∈ O, ∃ x, 0 < x ∧ cone (funnelRel (D := D)) w x ⊆ O) ↔ _
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
        exact hc ((mem_cone_funnelRel hx).mpr (Or.inr hu))
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
      obtain ⟨x, hx⟩ := exists_pos_of_nontrivial (D := ↑D)
      exact ⟨x, hx, subset_univ _⟩

/--
**The funnel's state topology is not T1**, exactly as `FrameOver.t1Space_iff_limit` predicts from
the failure of *Limit*.

The topology is named **explicitly** here, and must be. `funnelFrame` is `@[reducible]` so that
its carrier reduces to `Fin 4` for the decision procedures, and `Fin 4` carries Mathlib's own
discrete `instTopologicalSpaceFin`; a bare `T1Space funnelFrame.WorldState` therefore resolves to
*that* topology and says nothing about the frame. This is the carrier-keying hazard
`Semantics/StateTopology.lean`'s header records for real carriers, biting at a finite one —
never spell a frame carrier's topology implicitly in a statement about the frame.
-/
theorem funnel_not_t1Space [DenselyOrdered ↑D] :
    ¬ @T1Space (funnelFrame (D := D)).WorldState (FrameOver.stateTopology (funnelFrame (D := D))) :=
  fun h => funnel_not_limit (D := D) ((FrameOver.t1Space_iff_limit _).mp h)

/-- **A cone need not be `𝒩_F`-open**: `(0)_x = {0, 2, 3}` on the funnel, which is neither empty
nor everything, while every `𝒩_F`-open set is one of those two. -/
theorem funnelRel_not_isOpen_cone [DenselyOrdered ↑D] {x : ↑D} (hx : 0 < x) :
    ¬ IsOpen[nbhdTopology (funnelRel (D := D))] (cone (funnelRel (D := D)) 0 x) := by
  rw [funnelRel_nbhdTopology_eq_top, isOpen_top_iff]
  rintro (h | h)
  · have h0 : (0 : Fin 4) ∈ cone (funnelRel (D := D)) 0 x :=
      (mem_cone_funnelRel hx).mpr (Or.inl rfl)
    rw [h] at h0
    exact absurd h0 (Set.notMem_empty _)
  · have h1 : (1 : Fin 4) ∈ cone (funnelRel (D := D)) 0 x := by rw [h]; trivial
    rw [mem_cone_funnelRel hx] at h1
    revert h1; decide

/-- **The funnel contains a one-way instantaneous pair**: `0 ⇒_y 2` for arbitrarily small `y ≥ 0`,
and never `2 ⇒_y 0`. This is the configuration `TaskFrame.limit_of_t1Space_coneTopology` says must
be present whenever `𝒯_F` is T1 and *Limit* fails, and it is why *NoOneWay* is not free. -/
theorem funnel_one_way_pair [DenselyOrdered ↑D] :
    QuickFwd (funnelRel (D := D)) 0 2 ∧ ¬ QuickFwd (funnelRel (D := D)) 2 0 := by
  constructor
  · intro x hx
    obtain ⟨y, hy0, hyx⟩ := exists_between hx
    exact ⟨y, hy0.le, hyx, (funnelRel_pos hy0).mpr (Or.inr ⟨by decide, by decide⟩)⟩
  · intro h
    obtain ⟨x, hx⟩ := exists_pos_of_nontrivial (D := ↑D)
    obtain ⟨y, hy0, -, hR⟩ := h x hx
    rcases eq_or_lt_of_le hy0 with hy | hy
    · rw [← hy, funnelRel_zero] at hR; exact absurd hR (by decide)
    · rw [funnelRel_pos hy] at hR; revert hR; decide

/-! ### Separation without *Limit* -/

/-- A low state persists into the past along any history of the funnel. -/
theorem funnel_history_low_past {σ : ↑D → Fin 4}
    (hσ : ∀ x y, funnelRel (σ x) (y - x) (σ y)) {s t : ↑D} (hst : s ≤ t)
    (hlow : (σ t).val < 2) : σ s = σ t := by
  have h := hσ s t
  rcases eq_or_lt_of_le hst with rfl | hlt
  · rfl
  · rw [funnelRel_pos (sub_pos.mpr hlt)] at h
    rcases h with h | h
    · exact h
    · exact absurd h.2 (not_le.mpr hlow)

/-- A high state persists into the future along any history of the funnel. -/
theorem funnel_history_high_future {σ : ↑D → Fin 4}
    (hσ : ∀ x y, funnelRel (σ x) (y - x) (σ y)) {s t : ↑D} (hts : t ≤ s)
    (hhigh : 2 ≤ (σ t).val) : σ s = σ t := by
  have h := hσ t s
  rcases eq_or_lt_of_le hts with rfl | hlt
  · rfl
  · rw [funnelRel_pos (sub_pos.mpr hlt)] at h
    rcases h with h | h
    · exact h.symm
    · exact absurd h.1 (not_lt.mpr hhigh)

/-- If two shifts of a history agree then the history is fixed by their difference. -/
theorem funnel_history_shift_fixed {σ : ↑D → Fin 4} {a b : ↑D}
    (h : ∀ t, σ (t + a) = σ (t + b)) (u : ↑D) : σ (u + (a - b)) = σ u := by
  have := h (u - b)
  rwa [sub_add_cancel, show u - b + a = u + (a - b) by abel] at this

/-- The shift-invariance set of a funnel history is convex: invariance under `s ≥ 0` gives
invariance under every `y` with `0 ≤ y ≤ s`. -/
theorem funnel_history_invariant_of_le {σ : ↑D → Fin 4}
    (hσ : ∀ x y, funnelRel (σ x) (y - x) (σ y)) {s : ↑D}
    (hs : ∀ u, σ (u + s) = σ u) {y : ↑D} (hy0 : 0 ≤ y) (hys : y ≤ s) (u : ↑D) :
    σ (u + y) = σ u := by
  rcases lt_or_ge (σ u).val 2 with hlow | hhigh
  · have hlow' : (σ (u + s)).val < 2 := by rw [hs u]; exact hlow
    rw [funnel_history_low_past hσ ((add_le_add_iff_left u).mpr hys) hlow', hs u]
  · exact funnel_history_high_future hσ (le_add_of_nonneg_right hy0) hhigh

/--
**Separation holds on the funnel's histories although *Limit* fails.**

`ShiftSet.sep` — a history lying within arbitrarily small shifts of another *is* that other — is
exactly the shift-action transcription of *Limit*, and `ShiftSet.rev_sep_of_limit` derives it from
*Limit*. This is the converse failing: the funnel has no *Limit* (`funnel_not_limit`) and yet its
histories separate, because a funnel history is constant on a down-set of low states and on the
complementary up-set of high states, so its shift-invariance set is convex.

The other half of what the general/regular split makes expressible: before it, `sep` could only
be discussed at frames that satisfy *Limit* by construction.
-/
theorem funnel_sep_of_history {τ σ : ↑D → Fin 4}
    (hσ : ∀ x y, funnelRel (σ x) (y - x) (σ y))
    (h : ∀ x : ↑D, 0 < x → ∃ y : ↑D, |y| < x ∧ ∀ t, τ t = σ (t + y)) : τ = σ := by
  obtain ⟨x₀, hx₀⟩ := exists_pos_of_nontrivial (D := ↑D)
  obtain ⟨y₁, _, hτ₁⟩ := h x₀ hx₀
  by_cases hy₁0 : y₁ = 0
  · subst hy₁0; funext t; rw [hτ₁ t, add_zero]
  obtain ⟨y₂, hy₂, hτ₂⟩ := h |y₁| (abs_pos.mpr hy₁0)
  have hd : ∀ u, σ (u + (y₁ - y₂)) = σ u :=
    funnel_history_shift_fixed (fun t => (hτ₁ t).symm.trans (hτ₂ t))
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
  obtain ⟨y₃, hy₃, hτ₃⟩ := h _ (abs_pos.mpr hdne)
  have hy₃inv : ∀ u, σ (u + y₃) = σ u := by
    intro u
    rcases le_or_gt 0 y₃ with hy0 | hy0
    · rw [abs_of_nonneg hy0] at hy₃
      exact funnel_history_invariant_of_le hσ hs hy0 hy₃.le u
    · rw [abs_of_neg hy0] at hy₃
      have := funnel_history_invariant_of_le hσ hs (neg_nonneg.mpr hy0.le) hy₃.le (u + y₃)
      rw [add_neg_cancel_right] at this
      exact this.symm
  funext t
  rw [hτ₃ t, hy₃inv t]

/-! ### A history that is not `𝒯_F`-continuous

Every history is `𝒩_F`-continuous unconditionally
(`TaskFrame.continuous_nbhdTopology_of_history`). It need not be `𝒯_F`-continuous: over `ℝ` the
funnel history "low before time `0`, high from `0` on" respects the relation, and `{2}` is
`𝒯_F`-open because `𝒯_F` is discrete, while its preimage `[0, ∞)` is not open in `ℝ`. -/

/-- **A funnel history that is not `𝒯_F`-continuous.** -/
theorem funnel_not_continuous_coneTopology :
    ∃ τ : ℝ → Fin 4,
      (∀ x y : ℝ, funnelRel (D := TemporalOrder.of ℝ) (τ x) (y - x) (τ y)) ∧
      ¬ @Continuous ℝ (Fin 4) _
          (coneTopology (funnelRel (D := TemporalOrder.of ℝ))) τ := by
  refine ⟨fun t => if t < 0 then 1 else 2, ?_, ?_⟩
  · intro x y
    dsimp only
    split_ifs with hx hy hy
    · exact funnelRel_refl _ _
    · exact (funnelRel_pos (by linarith)).mpr (Or.inr ⟨by decide, by decide⟩)
    · exact (funnelRel_neg (by linarith)).mpr (Or.inr ⟨by decide, by decide⟩)
    · exact funnelRel_refl _ _
  · intro hcont
    letI := coneTopology (funnelRel (D := TemporalOrder.of ℝ))
    haveI := funnelRel_discreteTopology_coneTopology (D := TemporalOrder.of ℝ)
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


/-! ## The half-line with two origins: T1 but not Hausdorff

A frame satisfying *Seriality*, *Compositionality* and *Limit*, over `ℝ`, whose state topology is
T1 (by `FrameOver.t1Space_iff_limit`, since *Limit* holds) and **not Hausdorff**. The states are
two origins and a ray: both origins loop at every duration, either origin reaches the ray point
`p t` in any duration `x ≥ t`, and the ray drifts forward at speed at most `1`.

**`Saturation` is deliberately NOT claimed for this frame**, and it is not an oversight. The
paper's argument for it goes through a "shadow" map `W → [0, ∞)` collapsing the two origins, and
that argument is not formalised here; opening it would be new mathematical work rather than a
consequence of the general/regular split. What this frame is *for* is exactly the profile it
has — three constraints proved, one not claimed — which the general frame structure is what makes
writable. It is therefore **not** an `IsRegular` instance either.

The separation failure is the point: the two origins are distinct states (*Limit* holds, so no
instantaneous transition joins them) whose short-task futures overlap at every scale. T1 is a
statement about single points; Hausdorff is a statement about pairs, and *Limit* does not give it.
-/

namespace TwoOrigins

/-- The states of the half-line with two origins: two origins `o true`, `o false`, and one ray
point `p t` for each `t > 0`. -/
inductive TO
  | o (b : Bool)
  | p (t : {t : ℝ // 0 < t})

open TO

/-- The two-origin task relation: origins loop at every duration; `o b ⇒_x p t` iff `t ≤ x`; the
ray drifts forward at speed at most `1`; negative durations by reflection. -/
def rel : TO → ℝ → TO → Prop
  | o b, _, o b' => b = b'
  | o _, x, p t => t.1 ≤ x
  | p t, x, o _ => t.1 ≤ -x
  | p t, x, p s => (0 ≤ x ∧ t.1 ≤ s.1 ∧ s.1 ≤ t.1 + x) ∨ (x < 0 ∧ s.1 ≤ t.1 ∧ t.1 ≤ s.1 - x)

theorem rel_refl (w : TO) (x : ℝ) (hx : 0 ≤ x) : rel w x w := by
  cases w with
  | o b => exact rfl
  | p t => exact Or.inl ⟨hx, le_rfl, by linarith⟩

/-- **The two-origin frame satisfies *Seriality*** (`def:frame#Seriality`). -/
theorem rel_serial : Serial rel := by
  intro w x hx
  exact ⟨⟨w, rel_refl w x hx⟩, ⟨w, rel_refl w x hx⟩⟩

/-- **The two-origin frame satisfies *Compositionality*** (`def:frame#Compositionality`), both
halves. The interpolation direction splits a ray task at the intermediate point
`min s (t + x)`. -/
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

/-- **The two-origin frame satisfies *Limit*** (`def:frame#Limit`): the two origins are not
instantaneously connected, and the ray is metric. -/
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
      have hst : ∀ x : ℝ, 0 < x → |s.1 - t.1| < x := by
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

/-- The two-origin relation obeys the reflection law at every duration. -/
theorem rel_reflection (w : TO) (x : ℝ) (u : TO) : rel w x u ↔ rel u (-x) w := by
  cases w with
  | o b =>
    cases u with
    | o b' => exact eq_comm
    | p t => change t.1 ≤ x ↔ t.1 ≤ -(-x); rw [neg_neg]
  | p t =>
    cases u with
    | o b => exact Iff.rfl
    | p s =>
      constructor
      · rintro (⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩)
        · rcases eq_or_lt_of_le h1 with h0 | h0
          · exact Or.inl ⟨by linarith, by linarith, by linarith⟩
          · exact Or.inr ⟨by linarith, h2, by linarith⟩
        · exact Or.inl ⟨by linarith, h2, by linarith⟩
      · rintro (⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩)
        · rcases eq_or_lt_of_le h1 with h0 | h0
          · exact Or.inl ⟨by linarith, by linarith, by linarith⟩
          · exact Or.inr ⟨by linarith, h2, by linarith⟩
        · exact Or.inl ⟨by linarith, h2, by linarith⟩

/-- The real line as a temporal order, for this frame's duration type. Named
`twoOriginRealOrder` rather than `realOrder` because `Semantics.realOrder`
(`Correspondence/RigidityReal.lean`) already carries that base name, and C17's
dead-declaration census keys on the last dot-segment: two declarations sharing a base name mask
each other and neither can ever be reported dead. -/
noncomputable abbrev twoOriginRealOrder : TemporalOrder := TemporalOrder.of ℝ

/--
**The half-line with two origins, as a general task frame.**

A literal structure, for the reason recorded at `funnelFrame`: the case analyses below need the
carrier to reduce to `TO` at reducible transparency. It carries no `def:frame` constraint as part
of its data; `frame_serial`, `frame_compositional` and `frame_limit` are the three it satisfies,
and *Saturation* is deliberately not claimed. It is therefore **not** an `IsRegular` instance.
-/
@[reducible] noncomputable def frame : FrameOver twoOriginRealOrder where
  WorldState := TO
  worldNonempty := ⟨o true⟩
  PosRel w x u := rel w (x : ℝ) u

/-- The two-origin frame's task relation **is** the two-origin relation. -/
@[simp] theorem frame_taskRel_eq : frame.TaskRel = rel :=
  TaskFrame.reflect_eq_of_reflective rel rel_reflection

/-- **The frame satisfies *Seriality***, as a fact about the frame. -/
theorem frame_serial : Serial frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_serial

/-- **The frame satisfies *Compositionality***, as a fact about the frame. -/
theorem frame_compositional : Compositional frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_compositional

/-- **The frame satisfies *Limit***, as a fact about the frame. -/
theorem frame_limit : TaskFrame.Limit frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_limit

/-- **The frame's state topology is T1**, by `FrameOver.t1Space_iff_limit` at `frame_limit`.
The topology is named explicitly for the reason recorded at `funnel_not_t1Space`. -/
theorem frame_t1Space : @T1Space frame.WorldState (FrameOver.stateTopology frame) :=
  (FrameOver.t1Space_iff_limit frame).mpr frame_limit

/-- `𝒩_F` is T1 on the two-origin frame, from *Limit* through
`TaskFrame.t1Space_nbhdTopology_iff_limit`. -/
theorem t1Space_nbhdTopology : @T1Space TO (nbhdTopology rel) :=
  (t1Space_nbhdTopology_iff_limit rel).mpr rel_limit

/-- Every positive cone at an origin contains the whole initial segment of the ray. -/
theorem mem_cone_origin (b : Bool) {x : ℝ} (t : {t : ℝ // 0 < t}) (ht : t.1 < x) :
    p t ∈ cone rel (o b) x :=
  ⟨t.1, by rw [abs_of_pos t.2]; exact ht, show t.1 ≤ t.1 from le_rfl⟩

/-- **`𝒩_F` is not Hausdorff** on the two-origin frame: any two open sets containing the two
origins meet on the ray. Together with `t1Space_nbhdTopology` this is a state space that is T1
and not T2 — *Limit* gives the first and nothing in `def:frame` gives the second. -/
theorem not_t2Space_nbhdTopology : ¬ @T2Space TO (nbhdTopology rel) := by
  intro h
  letI := nbhdTopology rel
  obtain ⟨U, V, hU, hV, hoU, hoV, hd⟩ := h.t2 (show o true ≠ o false by simp)
  obtain ⟨x, hx, hcU⟩ := hU _ hoU
  obtain ⟨x', hx', hcV⟩ := hV _ hoV
  set t : {t : ℝ // 0 < t} := ⟨min x x' / 2, by positivity⟩ with ht
  have hx2 : (t : ℝ) < x := by
    rw [ht]; dsimp only
    linarith [min_le_left x x', min_le_right x x', lt_min hx hx']
  have hx2' : (t : ℝ) < x' := by
    rw [ht]; dsimp only
    linarith [min_le_left x x', min_le_right x x', lt_min hx hx']
  have htU : p t ∈ U := hcU (mem_cone_origin true t hx2)
  have htV : p t ∈ V := hcV (mem_cone_origin false t hx2')
  exact Set.disjoint_left.mp hd htU htV

/-- **The frame's state topology is not Hausdorff**, as a fact about the frame. A T1 state space
that is not T2: *Limit* gives the first (`frame_t1Space`) and no `def:frame` constraint gives the
second.

Paper: — (formalization-native; the paper states no separation axiom beyond `app:topology-t1`) -/
theorem frame_not_t2Space : ¬ @T2Space frame.WorldState (FrameOver.stateTopology frame) := by
  intro h
  refine not_t2Space_nbhdTopology ?_
  have hEq : FrameOver.stateTopology frame = nbhdTopology rel := by
    unfold FrameOver.stateTopology
    rw [frame_taskRel_eq]
  rwa [hEq] at h

end TwoOrigins

/-! ## The hedgehog: `𝒩_F` is strictly below the final topology of all histories

A centre and countably many rays, each carrying the two-origin frame's drift law, with no
cross-ray tasks. It satisfies *Seriality*, *Compositionality* and *Limit*; **`Saturation` is again
deliberately not claimed**, for the reason recorded at `TwoOrigins`, and it is **not** an
`IsRegular` instance.

What it shows: `TaskFrame.finalTopology_le_nbhdTopology` says `𝒩_F` is *below* the final topology
of all histories, and this frame shows the inclusion is **strict**. The set
`hedgehogOpen` — the centre together with the points of each ray below that ray's shrinking
"tip" — is open in the final topology, because a history leaves the centre along one ray and takes
time at least `t` to reach the point at distance `t`; but it is not `𝒩_F`-open, because a single
cone at the centre reaches every ray at once and so contains some ray's whole tip. The gap is the
uniformity: `𝒩_F` sees one radius for all rays, a history sees one ray.
-/

namespace Hedgehog

/-- The hedgehog's states: one centre and countably many rays. -/
inductive HH
  | c
  | p (n : ℕ) (t : {t : ℝ // 0 < t})

open HH

/-- The hedgehog task relation: the centre loops; `c ⇒_x p n t` iff `t ≤ x`; each ray drifts
forward at speed at most `1` with no cross-ray tasks; negative durations by reflection. -/
def rel : HH → ℝ → HH → Prop
  | c, _, c => True
  | c, x, p _ t => t.1 ≤ x
  | p _ t, x, c => t.1 ≤ -x
  | p n t, x, p m s =>
      n = m ∧ ((0 ≤ x ∧ t.1 ≤ s.1 ∧ s.1 ≤ t.1 + x) ∨ (x < 0 ∧ s.1 ≤ t.1 ∧ t.1 ≤ s.1 - x))

theorem rel_refl (w : HH) (x : ℝ) (hx : 0 ≤ x) : rel w x w := by
  cases w with
  | c => trivial
  | p n t => exact ⟨rfl, Or.inl ⟨hx, le_rfl, by linarith⟩⟩

/-- **The hedgehog satisfies *Seriality*** (`def:frame#Seriality`). -/
theorem rel_serial : Serial rel := by
  intro w x hx
  exact ⟨⟨w, rel_refl w x hx⟩, ⟨w, rel_refl w x hx⟩⟩

/-- **The hedgehog satisfies *Compositionality*** (`def:frame#Compositionality`), both halves. -/
theorem rel_compositional : Compositional rel := by
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
          obtain ⟨-, huv⟩ := huv
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

/-- **The hedgehog satisfies *Limit*** (`def:frame#Limit`): the centre is not instantaneously
connected to any ray point, and each ray is metric. -/
theorem rel_limit : TaskFrame.Limit rel := by
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
      obtain ⟨-, -, hnm, -⟩ := h 1 one_pos
      subst hnm
      have hst : ∀ x : ℝ, 0 < x → |s.1 - t.1| < x := by
        intro x hx
        obtain ⟨y, hy, -, hR⟩ := h x hx
        rcases hR with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
        · rw [abs_of_nonneg h1] at hy; rw [abs_of_nonneg (by linarith)]; linarith
        · rw [abs_of_neg h1] at hy; rw [abs_of_nonpos (by linarith)]; linarith
      have hzero : |s.1 - t.1| = 0 := by
        by_contra hne
        have hpos : 0 < |s.1 - t.1| := lt_of_le_of_ne (abs_nonneg _) (Ne.symm hne)
        exact lt_irrefl _ (hst _ hpos)
      rw [abs_eq_zero, sub_eq_zero] at hzero
      exact congrArg (p _) (Subtype.ext hzero)

/-- The hedgehog relation obeys the reflection law at every duration. -/
theorem rel_reflection (w : HH) (x : ℝ) (u : HH) : rel w x u ↔ rel u (-x) w := by
  cases w with
  | c =>
    cases u with
    | c => exact Iff.rfl
    | p m s => change s.1 ≤ x ↔ s.1 ≤ -(-x); rw [neg_neg]
  | p n t =>
    cases u with
    | c => exact Iff.rfl
    | p m s =>
      constructor
      · rintro ⟨rfl, h | h⟩
        · rcases eq_or_lt_of_le h.1 with h0 | h0
          · exact ⟨rfl, Or.inl ⟨by linarith, by linarith [h.2.1, h.2.2], by linarith [h.2.2]⟩⟩
          · exact ⟨rfl, Or.inr ⟨by linarith, h.2.1, by linarith [h.2.2]⟩⟩
        · exact ⟨rfl, Or.inl ⟨by linarith [h.1], h.2.1, by linarith [h.2.2]⟩⟩
      · rintro ⟨rfl, h | h⟩
        · rcases eq_or_lt_of_le h.1 with h0 | h0
          · exact ⟨rfl, Or.inl ⟨by linarith, by linarith [h.2.1, h.2.2], by linarith [h.2.2]⟩⟩
          · exact ⟨rfl, Or.inr ⟨by linarith, h.2.1, by linarith [h.2.2]⟩⟩
        · exact ⟨rfl, Or.inl ⟨by linarith [h.1], h.2.1, by linarith [h.2.2]⟩⟩

/--
**The hedgehog, as a general task frame.** A literal structure, for the reason recorded at
`funnelFrame`. It carries no `def:frame` constraint as part of its data; three are proved
separately and *Saturation* is not claimed, so it is **not** an `IsRegular` instance.
-/
@[reducible] noncomputable def frame : FrameOver TwoOrigins.twoOriginRealOrder where
  WorldState := HH
  worldNonempty := ⟨c⟩
  PosRel w x u := rel w (x : ℝ) u

/-- The hedgehog frame's task relation **is** the hedgehog relation. -/
@[simp] theorem frame_taskRel_eq : frame.TaskRel = rel :=
  TaskFrame.reflect_eq_of_reflective rel rel_reflection

/-- **The frame satisfies *Seriality***, as a fact about the frame. -/
theorem frame_serial : Serial frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_serial

/-- **The frame satisfies *Compositionality***, as a fact about the frame. -/
theorem frame_compositional : Compositional frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_compositional

/-- **The frame satisfies *Limit***, as a fact about the frame. -/
theorem frame_limit : TaskFrame.Limit frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_limit

/-- **The frame's state topology is T1**, by `FrameOver.t1Space_iff_limit`. The topology is named
explicitly for the reason recorded at `funnel_not_t1Space`. -/
theorem frame_t1Space : @T1Space frame.WorldState (FrameOver.stateTopology frame) :=
  (FrameOver.t1Space_iff_limit frame).mpr frame_limit

/-! ### `𝒩_F` is strictly below the final topology of all histories -/

/-- The centre together with the points of each ray below that ray's shrinking tip
`1/(n+1)`. -/
def hedgehogOpen : Set HH := {v | ∀ n t, v = p n t → t.1 < 1 / ((n : ℝ) + 1)}

theorem c_mem_hedgehogOpen : c ∈ hedgehogOpen := fun _ _ h => HH.noConfusion h

/-- **`hedgehogOpen` is not `𝒩_F`-open**: every cone at the centre contains the tip
`p n ⟨1/(n+1)⟩` of some ray, because `1/(n+1) < x` for some `n`. -/
theorem not_isOpen_nbhdTopology_hedgehogOpen :
    ¬ IsOpen[nbhdTopology rel] hedgehogOpen := by
  intro h
  obtain ⟨x, hx, hc⟩ := h c c_mem_hedgehogOpen
  obtain ⟨n, hn⟩ := exists_nat_one_div_lt hx
  have hpos : 0 < 1 / ((n : ℝ) + 1) := by positivity
  have hmem : p n ⟨1 / ((n : ℝ) + 1), hpos⟩ ∈ cone rel c x :=
    ⟨1 / ((n : ℝ) + 1), by rw [abs_of_pos hpos]; exact hn,
      mem_Fib.mpr (show 1 / ((n : ℝ) + 1) ≤ 1 / ((n : ℝ) + 1) from le_rfl)⟩
  exact lt_irrefl _ (hc hmem n _ rfl)

/-- A history visits at most one ray. -/
theorem history_single_ray {τ : ℝ → HH} (hτ : TaskFrame.IsHistory rel τ) {a b : ℝ} {n m : ℕ}
    {t s : {t : ℝ // 0 < t}} (ha : τ a = p n t) (hb : τ b = p m s) : n = m := by
  have h := hτ a b
  rw [ha, hb] at h
  exact h.1

/-- The centre persists into the past: a ray point reaches the centre only in negative
duration. -/
theorem history_centre_past {τ : ℝ → HH} (hτ : TaskFrame.IsHistory rel τ) {z s : ℝ}
    (hz : τ z = c) (hs : s ≤ z) : τ s = c := by
  rcases hτs : τ s with _ | ⟨n, t⟩
  · rfl
  · exfalso
    have h := hτ s z
    rw [hz, hτs] at h
    change t.1 ≤ -(z - s) at h
    linarith [t.2]

/-- Leaving the centre takes time: `τ z = c` and `τ (z + s) = p n t` force `t ≤ s`. -/
theorem history_reach {τ : ℝ → HH} (hτ : TaskFrame.IsHistory rel τ) {z s : ℝ} {n : ℕ}
    {t : {t : ℝ // 0 < t}} (hz : τ z = c) (hs : τ (z + s) = p n t) : t.1 ≤ s := by
  have h := hτ z (z + s)
  rw [hz, hs] at h
  change t.1 ≤ z + s - z at h
  linarith

/-- **Every history pulls `hedgehogOpen` back to an open set.** A history visits at most one ray,
and reaching that ray's point at distance `t` from the centre takes time at least `t`. -/
theorem isOpen_preimage_hedgehogOpen_of_history {τ : ℝ → HH} (hτ : TaskFrame.IsHistory rel τ) :
    IsOpen (τ ⁻¹' hedgehogOpen) := by
  rw [Metric.isOpen_iff]
  intro z hz
  rcases hτz : τ z with _ | ⟨n, t⟩
  · by_cases hvisit : ∃ n₀ s t₀, τ s = p n₀ t₀
    · obtain ⟨n₀, s₀, t₀, hs₀⟩ := hvisit
      refine ⟨1 / ((n₀ : ℝ) + 1), by positivity, ?_⟩
      intro y hy
      rw [Metric.mem_ball, Real.dist_eq] at hy
      change ∀ m t', τ y = p m t' → t'.1 < 1 / ((m : ℝ) + 1)
      intro m t' hy'
      have hm : m = n₀ := history_single_ray hτ hy' hs₀
      subst hm
      rcases le_or_gt y z with hyz | hyz
      · have hcy := history_centre_past hτ hτz hyz
        rw [hy'] at hcy
        exact HH.noConfusion hcy
      · have hr := history_reach hτ hτz (s := y - z) (by simpa using hy')
        linarith [le_abs_self (y - z)]
    · push Not at hvisit
      refine ⟨1, one_pos, ?_⟩
      intro y _
      change ∀ m t', τ y = p m t' → t'.1 < 1 / ((m : ℝ) + 1)
      intro m t' hy'
      exact absurd hy' (hvisit m y t')
  · have ht : t.1 < 1 / ((n : ℝ) + 1) := hz n t hτz
    refine ⟨1 / ((n : ℝ) + 1) - t.1, sub_pos.mpr ht, ?_⟩
    intro y hy
    rw [Metric.mem_ball, Real.dist_eq] at hy
    change ∀ m t', τ y = p m t' → t'.1 < 1 / ((m : ℝ) + 1)
    intro m t' hy'
    have h := hτ z y
    rw [hτz, hy'] at h
    obtain ⟨rfl, h⟩ := h
    have hdist : |t'.1 - t.1| ≤ |y - z| := by
      rcases h with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
      · rw [abs_of_nonneg h1, abs_of_nonneg (by linarith)]; linarith
      · rw [abs_of_neg h1, abs_of_nonpos (by linarith)]; linarith
    linarith [le_abs_self (t'.1 - t.1)]

/--
**`𝒩_F` is strictly below the final topology of all histories.**

`TaskFrame.finalTopology_le_nbhdTopology` gives the inclusion unconditionally; this frame shows
it is strict. `hedgehogOpen` is open in every history's coinduced topology, hence in their
supremum, and is not `𝒩_F`-open.

Paper: — (formalization-native; the paper does not compare `𝒩_F` with a final topology)
-/
theorem finalTopology_ne_nbhdTopology :
    (⨆ τ : {τ : ℝ → HH // TaskFrame.IsHistory rel τ}, coinduced τ.1 inferInstance) ≠
      nbhdTopology rel := by
  intro heq
  apply not_isOpen_nbhdTopology_hedgehogOpen
  rw [← heq, isOpen_iSup_iff]
  intro τ
  rw [isOpen_coinduced]
  exact isOpen_preimage_hedgehogOpen_of_history τ.2

/-! ### A history that is not `𝒯_F`-continuous, inside the three-constraint class -/

/-- `c ∈ (p n t)_x` iff `t < x`. -/
theorem c_mem_cone_p {n : ℕ} {t : {t : ℝ // 0 < t}} {x : ℝ} :
    c ∈ cone rel (p n t) x ↔ t.1 < x := by
  constructor
  · rintro ⟨y, hy, hR⟩
    change t.1 ≤ -y at hR
    linarith [(abs_lt.mp hy).1]
  · intro h
    exact ⟨-t.1, by rw [abs_neg, abs_of_pos t.2]; exact h, show t.1 ≤ -(-t.1) by rw [neg_neg]⟩

/-- Two cross-ray cones meet only at the centre. -/
theorem singleton_c_eq_inter_cone :
    ({c} : Set HH) = cone rel (p 0 ⟨1, one_pos⟩) 2 ∩ cone rel (p 1 ⟨1, one_pos⟩) 2 := by
  ext v
  constructor
  · rintro rfl
    exact ⟨c_mem_cone_p.mpr (show (1 : ℝ) < 2 by norm_num),
      c_mem_cone_p.mpr (show (1 : ℝ) < 2 by norm_num)⟩
  · rintro ⟨⟨y, -, h0⟩, ⟨y', -, h1⟩⟩
    cases v with
    | c => rfl
    | p n t => exact absurd ((mem_Fib.mp h0).1.trans (mem_Fib.mp h1).1.symm) (by decide)

/-- `{c}` is `𝒯_F`-open: it is a finite intersection of cones. -/
theorem isOpen_coneTopology_singleton_c : IsOpen[coneTopology rel] ({c} : Set HH) := by
  rw [singleton_c_eq_inter_cone]
  letI := coneTopology rel
  exact IsOpen.inter (isOpen_generateFrom_of_mem ⟨_, _, two_pos, rfl⟩)
    (isOpen_generateFrom_of_mem ⟨_, _, two_pos, rfl⟩)

/-- **A hedgehog history that is not `𝒯_F`-continuous**: "`c` until time `0`, then out ray `0` at
unit speed" respects the relation, and the preimage of the `𝒯_F`-open `{c}` is `(-∞, 0]`. So even
inside the *Seriality* + *Compositionality* + *Limit* class, histories need not be
`𝒯_F`-continuous — although they are always `𝒩_F`-continuous. -/
theorem not_continuous_coneTopology_history :
    ∃ τ : ℝ → HH, TaskFrame.IsHistory rel τ ∧ ¬ @Continuous ℝ HH _ (coneTopology rel) τ := by
  refine ⟨fun s => if h : s ≤ 0 then c else p 0 ⟨s, not_le.mp h⟩, ?_, ?_⟩
  · intro x y
    dsimp only
    split_ifs with hx hy hy
    · trivial
    · change y ≤ y - x; linarith
    · change x ≤ -(y - x); linarith
    · change (0 : ℕ) = 0 ∧ ((0 ≤ y - x ∧ x ≤ y ∧ y ≤ x + (y - x)) ∨
        (y - x < 0 ∧ y ≤ x ∧ x ≤ y - (y - x)))
      refine ⟨rfl, ?_⟩
      rcases le_or_gt x y with hxy | hxy
      · exact Or.inl ⟨by linarith, hxy, by linarith⟩
      · exact Or.inr ⟨by linarith, hxy.le, by linarith⟩
  · intro hcont
    letI := coneTopology rel
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
    have hle := hb hmem
    rw [Set.mem_Iic] at hle
    linarith

end Hedgehog

end FormalSystem.Semantics.StateTopology
