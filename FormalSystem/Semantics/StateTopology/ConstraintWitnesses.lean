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
import FormalSystem.Semantics.StateTopology

/-!
# Constraint witnesses: a `def:frame` constraint, or a separation property, **failing**

Each witness here exists to show that something is *not* implied. The module is sited beside
`StateTopology/Counterexamples.lean` rather than inside it purely to keep that module under its
recorded length ceiling; the two share a purpose and a leaf status.

## The ghost ray: `𝒩_F` need not be *R0* once *Limit* is dropped

`GhostRay`. The carrier is `{γ} ∪ {r t : t ∈ ℝ}` over `D = ℝ`. The ray `r` drifts forward at
speed at most `1` (the two-origin frame's law, on the whole line). The **ghost** `γ` loops at
every duration and reaches *every strictly positive* ray point in *every strictly positive*
duration; nothing reaches `γ` forward. *Seriality* and *Compositionality* hold
(`frame_serial`, `frame_compositional`), *Limit* fails (`frame_not_limit`), and `𝒩_F` is **not
R0** (`frame_not_r0Space`).

**Why the asymmetry sits where it does**, which is the fact the topology appendix consumes. For
`s > 0` the ghost is in every cone at `r s`, so `r s ∈ cl{γ}` directly. Then
`r 0 ∈ cl{γ}` — not because any task links `γ` to `r 0`, but because every cone at `r 0` contains
some `r (x/2)` with `x > 0`, and `cl{γ}` is closed. In the other direction `{r 0}` is
`𝒩_F`-closed (`isClosed_singleton_r0`), so `γ ∉ cl{r 0}`. The specialization order is therefore
not symmetric, which is exactly the failure of *R0*.

The verdict this records: **R0 is exactly as fragile as T1.** Both fail as soon as *Limit* is
dropped, even with *Seriality* and *Compositionality* in force. So the appendix's derivation of
its *R0* claim from its *T1* claim is already optimal and needs no separate frame-level argument.

A previously recorded sketch — a modified hedgehog carrying an extra state reaching all ray *tips*
instantaneously — is **replaced** by this witness, not patched. It could not have worked as
stated: the asymmetry it needed is between the ghost and the ray's *endpoint* `r 0`, and the
hedgehog's rays have no endpoint other than the centre, which every ray already reaches. Moving
the asymmetry to the tips puts it in the wrong place, because a tip is a `p n t` with `t > 0` and
is therefore reachable *from* the ghost and *back*, leaving the specialization order symmetric.

## The rational two-origin frame: *Saturation* fails for a **completeness** reason

`RationalTwoOrigins`. The two-origin half-line's relation verbatim, with the duration type and the
ray index moved from `ℝ` to `ℚ`. *Seriality*, *Compositionality* and *Limit* survive the move
unchanged (`rel_serial`, `rel_compositional`, `rel_limit`); *Saturation* does **not**
(`not_rel_saturation`).

This is the only statement in the collection exhibiting a frame constraint failing for a
completeness reason, and it is what licenses the claim that the real-carrier witness
(`StateTopology/Counterexamples.lean`'s `TwoOrigins`) is over `ℝ` on purpose. The witness is the
`⊇`-directed family of rational intervals straddling the Dedekind cut `{q : q² < 2} | {q : 2 < q²}`,
which has no rational point: `straddleFamily`.

## Import weight

Like `Semantics/StateTopology.lean` and `StateTopology/Counterexamples.lean`, this module is a
leaf: nothing under `FormalSystem/` imports it and the generated library root reaches it directly.
See `docs/ARCHITECTURE.md`'s "The state topology is a leaf, on purpose".

## References

- JPL paper `def:frame`, `def:task-topology`, `app:topology-t1`, `app:topology-r0`
-/

-- Inherited from `Semantics/StateTopology.lean`: `coneTopology` and `nbhdTopology` are `def`s of
-- class type, which `warn.classDefReducibility` reports at every mention.
set_option warn.classDefReducibility false

open Topology TopologicalSpace Set

namespace FormalSystem.Semantics.StateTopology

/-! ## The ghost ray: `𝒩_F` is not R0 without *Limit* -/

namespace GhostRay

open FormalSystem.Semantics FormalSystem.Semantics.TaskFrame

/-- The states: a ghost `γ` and a two-sided ray. -/
inductive GH
  | γ
  | r (t : ℝ)

open GH

/-- The ghost-ray task relation. The ghost loops at every duration and reaches every strictly
positive ray point in every strictly positive duration; nothing reaches the ghost forward; the
ray drifts at speed at most `1`. -/
def rel : GH → ℝ → GH → Prop
  | γ, _, γ => True
  | γ, x, r s => 0 < x ∧ 0 < s
  | r t, x, γ => x < 0 ∧ 0 < t
  | r t, x, r s => (0 ≤ x ∧ t ≤ s ∧ s ≤ t + x) ∨ (x < 0 ∧ s ≤ t ∧ t ≤ s - x)

theorem rel_refl (w : GH) (x : ℝ) (hx : 0 ≤ x) : rel w x w := by
  cases w with
  | γ => trivial
  | r t => exact Or.inl ⟨hx, le_rfl, by linarith⟩

/-- **The ghost-ray frame satisfies *Seriality*** (`def:frame#Seriality`). -/
theorem rel_serial : Serial rel := by
  intro w x hx
  exact ⟨⟨w, rel_refl w x hx⟩, ⟨w, rel_refl w x hx⟩⟩

/-- The ghost-ray relation obeys the reflection law at every duration, so the `FrameOver` value
below recovers it as its `TaskRel`. -/
theorem rel_reflection (w : GH) (x : ℝ) (u : GH) : rel w x u ↔ rel u (-x) w := by
  cases w with
  | γ =>
    cases u with
    | γ => exact Iff.rfl
    | r s => exact ⟨fun h => ⟨by linarith [h.1], h.2⟩, fun h => ⟨by linarith [h.1], h.2⟩⟩
  | r t =>
    cases u with
    | γ => exact ⟨fun h => ⟨by linarith [h.1], h.2⟩, fun h => ⟨by linarith [h.1], h.2⟩⟩
    | r s =>
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

/-- **The ghost-ray frame satisfies *Compositionality*** (`def:frame#Compositionality`), both
halves. -/
theorem rel_compositional : Compositional rel := by
  intro w v x y hx hy
  cases w with
  | γ =>
    cases v with
    | γ => exact ⟨fun _ => ⟨γ, trivial, trivial⟩, fun _ => trivial⟩
    | r s =>
      constructor
      · rintro ⟨h1, h2⟩
        rcases eq_or_lt_of_le hy with hy0 | hy0
        · exact ⟨r s, ⟨by linarith, h2⟩, Or.inl ⟨hy, le_rfl, by linarith⟩⟩
        · exact ⟨γ, trivial, ⟨hy0, h2⟩⟩
      · rintro ⟨m, hm, hmv⟩
        cases m with
        | γ => exact ⟨by linarith [hmv.1], hmv.2⟩
        | r q =>
          rcases hmv with ⟨-, h2, -⟩ | ⟨h1, -, -⟩
          · exact ⟨by linarith [hm.1], by linarith [hm.2]⟩
          · linarith
  | r t =>
    cases v with
    | γ =>
      constructor
      · rintro ⟨h1, -⟩; linarith
      · rintro ⟨m, hm, hmv⟩
        cases m with
        | γ => exact absurd hm.1 (by linarith)
        | r q => exact absurd hmv.1 (by linarith)
    | r s =>
      constructor
      · rintro (⟨-, h2, h3⟩ | ⟨h1, -, -⟩)
        · refine ⟨r (min s (t + x)), Or.inl ⟨hx, le_min h2 (by linarith), min_le_right _ _⟩,
            Or.inl ⟨hy, min_le_left _ _, ?_⟩⟩
          rcases min_choice s (t + x) with hm | hm <;> simp only [hm] <;> linarith
        · linarith
      · rintro ⟨m, hm, hmv⟩
        cases m with
        | γ => exact absurd hm.1 (by linarith)
        | r q =>
          rcases hm with ⟨-, h2, h3⟩ | ⟨h1, -, -⟩
          · rcases hmv with ⟨-, h2', h3'⟩ | ⟨h1', -, -⟩
            · exact Or.inl ⟨by linarith, by linarith, by linarith⟩
            · linarith
          · linarith

/-! ### `𝒩_F` is not R0 -/

/-- The ghost lies in every positive cone at every strictly positive ray point. -/
theorem γ_mem_cone_r {s : ℝ} (hs : 0 < s) {x : ℝ} (hx : 0 < x) : γ ∈ cone rel (r s) x :=
  ⟨-x / 2, by rw [abs_of_neg (by linarith)]; linarith, ⟨by linarith, hs⟩⟩

/-- Every strictly positive ray point is in the closure of the ghost. -/
theorem r_mem_closure_γ {s : ℝ} (hs : 0 < s) :
    r s ∈ @closure GH (nbhdTopology rel) ({γ} : Set GH) := by
  letI := nbhdTopology rel
  rw [mem_closure_iff]
  intro O hO hmem
  obtain ⟨x, hx, hc⟩ := hO _ hmem
  exact ⟨γ, hc (γ_mem_cone_r hs hx), rfl⟩

/-- **`r 0` is in the closure of the ghost**, although no task links them directly: every cone at
`r 0` contains some `r (x/2)` with `x > 0`, and `cl{γ}` is closed. This is the half of the R0
failure that is not visible from the relation alone. -/
theorem r0_mem_closure_γ : r 0 ∈ @closure GH (nbhdTopology rel) ({γ} : Set GH) := by
  letI := nbhdTopology rel
  refine (nbhdTopology_isClosed_iff rel _).mp isClosed_closure _ (fun x hx => ?_)
  refine ⟨r (x / 2), ⟨x / 2, ?_, ?_⟩, r_mem_closure_γ (by linarith)⟩
  · rw [abs_of_pos (by linarith)]; linarith
  · exact Or.inl ⟨by linarith, by linarith, by linarith⟩

/-- `{r 0}` is closed: its complement is `𝒩_F`-open. This is the other half — the ghost is *not*
in the closure of `r 0`. -/
theorem isClosed_singleton_r0 : IsClosed[nbhdTopology rel] ({r 0} : Set GH) := by
  letI := nbhdTopology rel
  rw [← isOpen_compl_iff]
  intro w hw
  cases w with
  | γ =>
    refine ⟨1, one_pos, ?_⟩
    rintro v ⟨y, hy, hR⟩ hv
    rw [Set.mem_singleton_iff] at hv
    subst hv
    exact absurd hR.2 (by norm_num)
  | r t =>
    have ht : t ≠ 0 := fun h => hw (by rw [h]; rfl)
    refine ⟨|t|, abs_pos.mpr ht, ?_⟩
    rintro v ⟨y, hy, hR⟩ hv
    rw [Set.mem_singleton_iff] at hv
    subst hv
    rcases hR with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
    · rw [abs_of_nonneg h1] at hy; rcases abs_cases t with ⟨he, -⟩ | ⟨he, -⟩ <;>
        rw [he] at hy <;> linarith
    · rw [abs_of_neg h1] at hy; rcases abs_cases t with ⟨he, -⟩ | ⟨he, -⟩ <;>
        rw [he] at hy <;> linarith

/-- **`𝒩_F` is not R0 on the ghost-ray frame.** `r 0 ∈ cl {γ}` but `γ ∉ cl {r 0}`. So *R0* is as
fragile as *T1*: it too fails as soon as *Limit* is dropped, even with *Seriality* and
*Compositionality* in force.

Paper: `app:topology-r0`
-/
theorem not_r0Space_nbhdTopology : ¬ @R0Space GH (nbhdTopology rel) := by
  letI := nbhdTopology rel
  intro h
  have hγ : γ ∈ closure ({r 0} : Set GH) :=
    (TaskFrame.r0Space_iff_mem_closure_comm.mp h) _ _ r0_mem_closure_γ
  rw [isClosed_singleton_r0.closure_eq, Set.mem_singleton_iff] at hγ
  exact GH.noConfusion hγ

/-- **The ghost-ray frame fails *Limit***, as a corollary: *Limit* would make `𝒩_F` R0
(`TaskFrame.r0Space_nbhdTopology_of_limit`). -/
theorem not_limit : ¬ TaskFrame.Limit rel :=
  fun h => not_r0Space_nbhdTopology (TaskFrame.r0Space_nbhdTopology_of_limit rel h)

/-- The ghost is instantaneously close to `r 1`, which is the direct failure of *Limit*. -/
theorem not_limit_witness : ∀ x : ℝ, 0 < x → r 1 ∈ cone rel γ x :=
  fun x hx => ⟨x / 2, by rw [abs_of_pos (by linarith)]; linarith, ⟨by linarith, one_pos⟩⟩

/-! ### The frame-level forms -/

/-- The real line as a temporal order, for this frame's duration type. -/
noncomputable abbrev ghostRealOrder : TemporalOrder := TemporalOrder.of ℝ

/-- **The ghost-ray structure, as a general task frame.** It carries no `def:frame` constraint as
part of its data; `frame_serial` and `frame_compositional` are the two it satisfies, and *Limit*
fails. It is deliberately **not** an `FrameOver.IsRegular` instance, and must never be given one:
its whole content is that *R0* fails without *Limit*. -/
@[reducible] noncomputable def frame : FrameOver ghostRealOrder where
  WorldState := GH
  worldNonempty := ⟨γ⟩
  PosRel w x u := rel w (x : ℝ) u

theorem frame_taskRel_eq : frame.TaskRel = rel :=
  TaskFrame.reflect_eq_of_reflective rel rel_reflection

theorem frame_serial : Serial frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_serial

theorem frame_compositional : Compositional frame.TaskRel := by
  rw [frame_taskRel_eq]; exact rel_compositional

/-- **The ghost-ray frame fails *Limit***, as a fact about the frame. It is a corollary of the
*R0* failure rather than a direct computation: *Limit* would force `𝒩_F` to be R0.

Paper: `def:frame#Limit`
-/
theorem frame_not_limit : ¬ TaskFrame.Limit frame.TaskRel := by
  rw [frame_taskRel_eq]; exact not_limit

/-- **The frame's state topology is not R0.** The frame-level form of
`not_r0Space_nbhdTopology`, and the declaration the topology appendix cites.

Paper: `app:topology-r0`
-/
theorem frame_not_r0Space : ¬ @R0Space frame.WorldState (FrameOver.stateTopology frame) := by
  intro h
  refine not_r0Space_nbhdTopology ?_
  have hEq : FrameOver.stateTopology frame = nbhdTopology rel := by
    unfold FrameOver.stateTopology
    rw [frame_taskRel_eq]
  rwa [hEq] at h

end GhostRay

/-! ## The rational two-origin frame: *Saturation* fails -/

namespace RationalTwoOrigins

open FormalSystem.Semantics.TaskFrame

/-- States of the ℚ-carrier half-line with two origins. -/
inductive TQ
  | o (b : Bool)
  | p (t : {t : ℚ // 0 < t})

open TQ

/-- The two-origin task relation, over `ℚ`: the real-carrier relation of
`StateTopology/Counterexamples.lean`'s `TwoOrigins.rel`, verbatim, with `ℝ` replaced by `ℚ` in
both the duration type and the ray index. -/
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

/-- No rational squares to `2`: the cut the family below straddles has no rational point.

Kept derived from `Rat.num_pow` on purpose. Do **not** substitute `irrational_sqrt_two`:
`Mathlib.NumberTheory.Real.Irrational` is not in this checkout's build, and the substitution would
add a build dependency the tree does not carry. -/
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
ray, with no origins, whenever `0 < a < b`.

The `(a := _) (b := _)` arguments are passed explicitly at every use site below. Letting
unification solve `?a.1 ≟ e` for an anonymous-constructor `e` sends the elaborator into a whnf
loop on the `Subtype` projection; this is a recorded trap, not a style preference. -/
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
(`StateTopology/Counterexamples.lean`'s `TwoOrigins.rel_saturation`) uses, and it is not
decorative.

The closing step is a **Newton step**: for a rational `s` in every member, `t = (2s+2)/(s+2)`
satisfies `t² - 2 = 2(s² - 2)/(s+2)²` and `t - s = (2 - s²)/(s+2)`, so `t` stays on `s`'s own side
of the cut while crossing strictly past `s` — and the member cut at `t` therefore excludes `s`.

Note on scope: `TaskFrame.Saturation` is a **bare-relation** predicate, needing only
`[AddCommGroup] [LinearOrder] [IsOrderedAddMonoid] [Nontrivial]` on the duration type, all of which
`ℚ` has. So no `TemporalOrder.of ℚ` is required here. A frame-level form would need one; that was
not investigated.

Paper: `def:frame#Saturation`
-/
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
