/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Archimedean.Basic
import Mathlib.Data.Int.SuccPred
import Mathlib.Data.Rat.Lemmas
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
-- `Extension.Completion` is imported for exactly one declaration, `PartialHistory.hasNearest_int`,
-- which `SeparatingFrame.srel_completion` consumes. This module is a leaf — nothing under
-- `FormalSystem/` imports it — so the edge adds weight to nothing else.
import FormalSystem.Semantics.Extension.Completion
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

**It fails *Completion* too, and that is why it is not the separator** (`not_rel_completion`).
*Completion* (`TaskFrame.Completion`, `Semantics/TaskFrame.lean`) is the derived condition the
extension chain actually consumes — `def:frame`'s fourth constraint is *Saturation* — and the
obvious probe of whether it is a *strict* weakening of *Saturation* is to ask whether this
relation — already *Serial*, *Compositional*, *Limit* and
non-*Saturated* — satisfies it. It does not: the coherent family at the times `tm n = -(1/2)^n`
carrying the ray positions `phi n = nt n - (1/2)^n` has empty fibre intersection at `z = 0`,
because the two bounds pinch onto `√2`. The rational carrier is therefore not the separator; the
separation is exhibited by `SeparatingFrame` below instead.

**And no dense-time frame of this shape can be the separator.** The pinch is not an artefact of
this particular family. Over a **dense** temporal order, any coherent family whose times
accumulate at `z` forces the witness position to the single real number `lim φ(t)`: position
nondecreasing and position-minus-time nonincreasing squeeze the admissible interval shut, so the
only candidate is a point of the completion of the carrier, and a carrier missing that point
fails *Completion* exactly where it fails *Saturation*. **So no dense-time frame with a
continuous-drift relation separates the two conditions, and searching for one is wasted effort.**
The separation is a discreteness phenomenon, which is what `SeparatingFrame` exploits.

## The void and bump frames: *Seriality* and *Compositionality* are independent

`voidFrame`, `bumpFrame`. Two frames on `Bool` over `ℤ`-time, each satisfying three of
`def:frame`'s constraints and failing the fourth. The void frame is the **empty** task relation:
*Compositionality* and *Limit* hold vacuously, *Saturation* holds because the carrier is finite,
and *Seriality* fails at `x = 0` because no state has a successor. The bump frame is the identity
at duration `0`, the **total** relation at duration `±1`, and the identity again from `|d| ≥ 2`
outwards: *Seriality*, *Limit* and *Saturation* hold, and *Compositionality* fails because two
`±1` steps compose to a duration-`2` pair that the `|d| ≥ 2` identity clause refuses.

**With these two, the independence matrix for `def:frame` is complete.** Every one of the four
constraints now has a compiled witness satisfying the other three and failing it:

* *Compositionality* fails at the **bump frame**: `bumpFrame_serial`, `bumpFrame_limit`,
  `bumpFrame_saturation`, `bumpFrame_not_compositional` (below).
* *Seriality* fails at the **void frame**: `voidFrame_compositional`, `voidFrame_limit`,
  `voidFrame_saturation`, `voidFrame_not_serial` (below).
* *Limit* fails at the **four-state funnel**: `funnel_serial`, `funnel_compositional`,
  `funnel_saturation`, `funnel_not_limit` (in `StateTopology/Counterexamples.lean`).
* *Saturation* fails at the **rational two-origin frame**: `RationalTwoOrigins.rel_serial`,
  `.rel_compositional`, `.rel_limit`, `.not_rel_saturation` (above).

**And a fifth row, which is a *separation* rather than an independence.** *Completion*
(`TaskFrame.Completion`) is the derived condition `lem:step` consumes, stated at the
bare-relation level so that the comparison with `def:frame`'s own clauses is a comparison of like
with like. *Saturation* implies it, and the converse is **false**: the separating frame —
unit-speed drift on `ℚ` over `ℤ`-time — satisfies *Seriality*, *Compositionality*, *Limit*
**and** *Completion*
(`SeparatingFrame.srel_serial`, `.srel_compositional`, `.srel_limit`, `.srel_completion`) while
failing *Saturation* (`SeparatingFrame.not_srel_saturation`). So **`Completion → Saturation` is
false unconditionally, and *Completion* is a strict weakening of *Saturation***. The mechanism is
the one this module's rational-carrier section names: *Completion*'s quantifier is indexed by
**times**, so it collapses over an order with nearest times, while *Saturation*'s is indexed by
**balls**, which no discreteness of the duration order reaches.

**What the two `¬ Saturation` witnesses do *not* establish.** Both of them fail the **nest**
condition `S₁` (`TaskFrame.NestSaturation`) as well as the `⊇`-directed condition `S₁ᵈ`
(`TaskFrame.Saturation`): their straddle families contain a cofinal nest, exhibited as
`RationalTwoOrigins.nest` and `SeparatingFrame.nest` and used by
`RationalTwoOrigins.not_rel_nestSaturation` and `SeparatingFrame.not_srel_nestSaturation`. So
neither witness separates the two forms, and **neither bears on whether `S₁ → S₁ᵈ`**, which stays
open. Reading `not_srel_saturation` as evidence about directedness was a standing assumption of
the collection; these two theorems retire it.

**A packaging asymmetry, recorded rather than papered over.** Three of the four independence rows
are certified at the **frame** level — the statements are about a `FrameOver`'s `TaskRel`. The
*Saturation* row and the whole of the fifth, separating row are certified at the
**bare-relation** level only: neither `RationalTwoOrigins.rel` nor `SeparatingFrame.srel` carries
a `FrameOver` wrapper, because wrapping either would need a reflection law for its carrier that
this module does not prove. The results are genuine at exactly the level `def:frame` states its
constraints — they are conditions on the task relation — but no row should be read as claiming a
`FrameOver` witness it does not have.

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

-- Raised from the 1500 default for `SeparatingFrame.nest`, `not_srel_nestSaturation` and their
-- `RationalTwoOrigins` companions, which correct a standing assumption about the witnesses
-- already hosted here, and for `srel_fiberSaturation`, which closes the fibers-only candidate
-- against the same witness -- all of them belong beside the witnesses they are about.
-- `docs/ARCHITECTURE.md` records that nothing under `FormalSystem/` imports this module, so
-- a sibling module importing it would falsify that record; the baseline is the sanctioned
-- response instead. Not for parking unrelated material.
set_option linter.style.longFile 1800

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

/-! ## *Completion* fails here too: the Newton iteration for `√2` from above

The primary probe of the *Saturation*-vs-*Completion* question, answered negatively. See the
module docstring's rational-carrier section for what the answer costs and what it rules out.
-/

-- Seed `3/2`, not `2`: with seed `2` the first Newton step `2 → 3/2` is exactly `1/2`, which is
-- exactly the first time gap, leaving `phi` no slack at `n = 0` and breaking `phi_le_succ`.
/-- Newton iterates for `√2`, started at `3/2`: `nt (n+1) = (nt n ^ 2 + 2) / (2 * nt n)`. -/
def nt : ℕ → ℚ
  | 0 => 3 / 2
  | n + 1 => (nt n ^ 2 + 2) / (2 * nt n)

theorem nt_succ (n : ℕ) : nt (n + 1) = (nt n ^ 2 + 2) / (2 * nt n) := rfl

/-- The three invariants of the iteration: it stays at least `1`, stays strictly above the cut,
and its distance to the cut halves at least once per step from `(1/2)^2` down. -/
theorem nt_inv (n : ℕ) : 1 ≤ nt n ∧ 2 < nt n ^ 2 ∧ nt n ^ 2 - 2 ≤ (1 / 2 : ℚ) ^ (n + 2) := by
  induction n with
  | zero => refine ⟨by norm_num [nt], by norm_num [nt], by norm_num [nt]⟩
  | succ n ih =>
    obtain ⟨h1, h2, h3⟩ := ih
    have hx0 : (0 : ℚ) < nt n := by linarith
    have hone : 1 ≤ nt (n + 1) := by
      rw [nt_succ, le_div_iff₀ (by positivity)]
      nlinarith [sq_nonneg (nt n - 1)]
    have hsq : nt (n + 1) ^ 2 - 2 = (nt n ^ 2 - 2) ^ 2 / (4 * nt n ^ 2) := by
      rw [nt_succ]; field_simp; ring
    have hden : (0 : ℚ) < 4 * nt n ^ 2 := by positivity
    have hgt : 2 < nt (n + 1) ^ 2 := by
      have : 0 < nt (n + 1) ^ 2 - 2 := by
        rw [hsq]; exact div_pos (by nlinarith) hden
      linarith
    refine ⟨hone, hgt, ?_⟩
    -- `e ≤ a ≤ 1/4` and `4 * nt n ^ 2 > 8` give `e² / (4 nt n²) ≤ a² / 8 ≤ a / 32 ≤ a / 2`.
    have ha : (1 / 2 : ℚ) ^ (n + 2) ≤ 1 / 4 := by
      calc (1 / 2 : ℚ) ^ (n + 2) ≤ (1 / 2 : ℚ) ^ 2 :=
            pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
        _ = 1 / 4 := by norm_num
    have hapos : (0 : ℚ) < (1 / 2 : ℚ) ^ (n + 2) := by positivity
    have hsucc_pow : (1 / 2 : ℚ) ^ (n + 1 + 2) = (1 / 2 : ℚ) ^ (n + 2) / 2 := by
      rw [pow_succ]; ring
    rw [hsq, hsucc_pow, div_le_div_iff₀ hden (by norm_num)]
    nlinarith [sq_nonneg (nt n ^ 2 - 2), sq_nonneg (nt n)]

theorem nt_one_le (n : ℕ) : 1 ≤ nt n := (nt_inv n).1
theorem nt_sq_gt (n : ℕ) : 2 < nt n ^ 2 := (nt_inv n).2.1
theorem nt_err (n : ℕ) : nt n ^ 2 - 2 ≤ (1 / 2 : ℚ) ^ (n + 2) := (nt_inv n).2.2

theorem nt_succ_le (n : ℕ) : nt (n + 1) ≤ nt n := by
  have h1 := nt_one_le n
  have h2 := nt_sq_gt n
  rw [nt_succ, div_le_iff₀ (by linarith)]
  nlinarith

theorem nt_antitone : Antitone nt := antitone_nat_of_succ_le nt_succ_le

theorem nt_le_start (n : ℕ) : nt n ≤ 3 / 2 := by
  have := nt_antitone (Nat.zero_le n)
  simpa [nt] using this

/-- The step of the iteration is at most `(1/2)^(n+1)` — slower than the times converge. -/
theorem nt_step (n : ℕ) : nt n - nt (n + 1) ≤ (1 / 2 : ℚ) ^ (n + 1) := by
  have h1 := nt_one_le n
  have h2 := nt_sq_gt n
  have h3 := nt_err n
  have hstep : nt n - nt (n + 1) = (nt n ^ 2 - 2) / (2 * nt n) := by
    rw [nt_succ]; field_simp; ring
  have hle : (nt n ^ 2 - 2) / (2 * nt n) ≤ (nt n ^ 2 - 2) / 2 := by
    apply div_le_div_of_nonneg_left (by linarith) (by norm_num) (by linarith)
  have hpow : (1 / 2 : ℚ) ^ (n + 2) = (1 / 2 : ℚ) ^ (n + 1) / 2 := by rw [pow_succ]; ring
  rw [hstep]
  have hpos : (0 : ℚ) < (1 / 2 : ℚ) ^ (n + 1) := by positivity
  linarith [hle, h3, hpow]

/-! ### The coherent family -/

/-- The times: `-(1/2)^n`, accumulating at `0` from below. -/
def tm (n : ℕ) : ℚ := -(1 / 2 : ℚ) ^ n

/-- The positions: `nt n - (1/2)^n`, increasing to the cut. -/
def phi (n : ℕ) : ℚ := nt n - (1 / 2 : ℚ) ^ n

theorem phi_le_succ (n : ℕ) : phi n ≤ phi (n + 1) := by
  have h := nt_step n
  have hpow : (1 / 2 : ℚ) ^ n = (1 / 2 : ℚ) ^ (n + 1) * 2 := by rw [pow_succ]; ring
  simp only [phi]
  linarith [hpow]

theorem phi_mono : Monotone phi := monotone_nat_of_le_succ phi_le_succ

theorem phi_pos (n : ℕ) : 0 < phi n := by
  have := phi_mono (Nat.zero_le n)
  have h0 : phi 0 = 1 / 2 := by norm_num [phi, nt]
  linarith [h0, this]

/--
The Newton-minus-gap sequence stays strictly below the cut: `phi n ^ 2 < 2`.

With `e = (1/2)^n` and `x = nt n`, the invariants `nt_err` (`x² - 2 ≤ e/4`) and `nt_one_le`
(`x ≥ 1`) give `(x - e)² - 2 ≤ e(1/4 - 2x + e) ≤ -3e/4 < 0`, since `0 < e ≤ 1`.

Paper: — (formalization-native; an invariant of the Newton iteration used to exhibit the cofinal
nest inside `SeparatingFrame.straddle`)
-/
theorem phi_sq_lt_two (n : ℕ) : phi n ^ 2 < 2 := by
  have hx := nt_one_le n
  have herr := nt_err n
  have hepos : (0 : ℚ) < (1 / 2 : ℚ) ^ n := by positivity
  have hele : (1 / 2 : ℚ) ^ n ≤ 1 := pow_le_one₀ (by norm_num) (by norm_num)
  have hpow : (1 / 2 : ℚ) ^ (n + 2) = (1 / 2 : ℚ) ^ n / 4 := by rw [pow_add]; ring
  simp only [phi]
  nlinarith [herr, hx, hepos, hele, hpow]

-- The index shift by two is load bearing, for the same reason the `1 ≤ b` conjunct of
-- `SeparatingFrame.straddle` is: `phi 0 = 1/2` and `phi 1 = 11/12` both fail that conjunct, so a
-- nest indexed by `phi n` would leave `straddle` rather than sit inside it. `phi 2 = 475/408`.
/--
From index `2` on, `phi` clears `1`.

Paper: — (formalization-native; supplies `SeparatingFrame.straddle`'s `1 ≤ a` conjunct for the
cofinal nest)
-/
theorem one_le_phi_add_two (n : ℕ) : 1 ≤ phi (n + 2) := by
  have h2 : (1 : ℚ) ≤ phi 2 := by norm_num [phi, nt]
  exact h2.trans (phi_mono (by omega))

/-- The times are pairwise distinct: `(1/2)^m = (1/2)^n` only at `m = n`. -/
theorem pow_half_inj {m n : ℕ} (h : (1 / 2 : ℚ) ^ m = (1 / 2 : ℚ) ^ n) : m = n := by
  by_contra hne
  rcases Nat.lt_or_ge m n with hlt | hge
  · have := pow_lt_pow_right_of_lt_one₀ (show (0 : ℚ) < 1 / 2 by norm_num)
      (show (1 / 2 : ℚ) < 1 by norm_num) hlt
    linarith
  · have hlt : n < m := lt_of_le_of_ne hge (fun hEq => hne hEq.symm)
    have := pow_lt_pow_right_of_lt_one₀ (show (0 : ℚ) < 1 / 2 by norm_num)
      (show (1 / 2 : ℚ) < 1 by norm_num) hlt
    linarith

/-- Coherence: the family is nondecreasing in position and 1-Lipschitz in time. -/
theorem key (m n : ℕ) :
    rel (p ⟨phi m, phi_pos m⟩) (tm n - tm m) (p ⟨phi n, phi_pos n⟩) := by
  rcases lt_trichotomy m n with h | h | h
  · have hp : (1 / 2 : ℚ) ^ n < (1 / 2 : ℚ) ^ m :=
      pow_lt_pow_right_of_lt_one₀ (by norm_num) (by norm_num) h
    have hnt : nt n ≤ nt m := nt_antitone h.le
    have hph : phi m ≤ phi n := phi_mono h.le
    refine Or.inl ⟨by simp only [tm]; linarith, hph, ?_⟩
    simp only [tm, phi]
    linarith
  · subst h
    exact Or.inl ⟨by simp, le_rfl, by simp⟩
  · have hp : (1 / 2 : ℚ) ^ m < (1 / 2 : ℚ) ^ n :=
      pow_lt_pow_right_of_lt_one₀ (by norm_num) (by norm_num) h
    have hnt : nt m ≤ nt n := nt_antitone h.le
    have hph : phi n ≤ phi m := phi_mono h.le
    refine Or.inr ⟨by simp only [tm]; linarith, hph, ?_⟩
    simp only [tm, phi]
    linarith

/-! ### *Completion* fails -/

/-- The state carried at a time of the family: the ray point at the position indexed by any
witness that the time is one of the `tm n`. -/
noncomputable def stateAt (t : ℚ) (ht : ∃ n : ℕ, t = tm n) : TQ :=
  p ⟨phi (Classical.choose ht), phi_pos _⟩

/--
**The ℚ-carrier two-origin relation FAILS *Completion*** — the primary probe, answered
negatively.

The family `{p (phi n)}` at the times `tm n = -(1/2)^n` is coherent, and at `z = 0` its fibre
intersection is empty: a witness `p v` would need `nt n - (1/2)^n ≤ v ≤ nt n` for every `n`, and
the two sides pinch onto the Dedekind cut, so `v² = 2` — impossible over `ℚ` (`sq_ne_two`).

So the rational carrier is **not** a frame separating *Completion* from *Saturation*: it fails
both. The separation is exhibited instead by `SeparatingFrame` below, over **discrete** time; the
module docstring records why no dense-time frame of this shape can serve.

Note on scope, as for `not_rel_saturation`: `TaskFrame.Completion` is a **bare-relation**
predicate, needing only `[AddCommGroup] [LinearOrder] [IsOrderedAddMonoid] [Nontrivial]` on the
duration type, all of which `ℚ` has, so no `TemporalOrder.of ℚ` is required.

Paper: — (*Completion* is the derived condition the extension chain consumes and has no anchor in
the manuscript; `def:frame`'s fourth constraint is *Saturation*)
-/
theorem not_rel_completion : ¬ TaskFrame.Completion rel := by
  intro hcc
  classical
  have hXne : ∃ t : ℚ, ∃ n : ℕ, t = tm n := ⟨tm 0, 0, rfl⟩
  have hcoh : ∀ (s t : ℚ) (hs : ∃ n : ℕ, s = tm n) (ht : ∃ n : ℕ, t = tm n),
      rel (stateAt s hs) (t - s) (stateAt t ht) := by
    intro s t hs ht
    have hs' : s = tm (Classical.choose hs) := Classical.choose_spec hs
    have ht' : t = tm (Classical.choose ht) := Classical.choose_spec ht
    have hk := key (Classical.choose hs) (Classical.choose ht)
    rw [← hs', ← ht'] at hk
    exact hk
  obtain ⟨u, hu⟩ := hcc (fun t => ∃ n : ℕ, t = tm n) hXne stateAt hcoh 0
  -- The membership proofs, named once so their chosen indices are the same term throughout.
  have hmem : ∀ n : ℕ, ∃ k : ℕ, tm n = tm k := fun n => ⟨n, rfl⟩
  have hpow : ∀ n : ℕ, (1 / 2 : ℚ) ^ (Classical.choose (hmem n)) = (1 / 2 : ℚ) ^ n := by
    intro n
    have h : -((1 / 2 : ℚ) ^ n) = -((1 / 2 : ℚ) ^ (Classical.choose (hmem n))) :=
      Classical.choose_spec (hmem n)
    exact (neg_inj.mp h).symm
  have hall : ∀ n : ℕ,
      rel (p ⟨phi (Classical.choose (hmem n)), phi_pos _⟩) ((1 / 2 : ℚ) ^ n) u := by
    intro n
    have h := hu (tm n) (hmem n)
    rw [show (0 : ℚ) - tm n = (1 / 2 : ℚ) ^ n by simp [tm]] at h
    exact h
  cases u with
  | o b =>
    have h := hall 0
    rw [pow_zero] at h
    have h' : phi (Classical.choose (hmem 0)) ≤ -(1 : ℚ) := h
    have := phi_pos (Classical.choose (hmem 0))
    linarith
  | p v =>
    have hv0 : (0 : ℚ) < v.1 := v.2
    -- At every `n`: `nt m - (1/2)^n ≤ v ≤ nt m`, where `m` is the chosen index at `tm n`.
    have hband : ∀ n : ℕ, ∃ m : ℕ, (1 / 2 : ℚ) ^ m = (1 / 2 : ℚ) ^ n ∧
        nt m - (1 / 2 : ℚ) ^ n ≤ v.1 ∧ v.1 ≤ nt m := by
      intro n
      have h := hall n
      have hpos : (0 : ℚ) < (1 / 2 : ℚ) ^ n := by positivity
      refine ⟨Classical.choose (hmem n), hpow n, ?_, ?_⟩
      · rcases h with ⟨-, h2, -⟩ | ⟨h1, -, -⟩
        · simp only [phi] at h2; rw [hpow n] at h2; linarith
        · linarith
      · rcases h with ⟨-, -, h3⟩ | ⟨h1, -, -⟩
        · simp only [phi] at h3; rw [hpow n] at h3; linarith
        · linarith
    rcases lt_trichotomy (v.1 ^ 2) 2 with hlt | heq | hgt
    · -- below the cut: some `nt m - (1/2)^n` overtakes `v`
      have hδpos : 0 < (2 - v.1 ^ 2) / (3 / 2 + v.1) := div_pos (by linarith) (by linarith)
      obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one hδpos (show (1 / 2 : ℚ) < 1 by norm_num)
      obtain ⟨m, -, hlow, -⟩ := hband n
      have hm1 := nt_one_le m
      have hmsq := nt_sq_gt m
      have hmle := nt_le_start m
      have hgap : (2 - v.1 ^ 2) / (3 / 2 + v.1) ≤ nt m - v.1 := by
        rw [div_le_iff₀ (by linarith)]
        nlinarith
      linarith
    · exact sq_ne_two v.1 heq
    · -- above the cut: the upper bound `nt m` drops below `v`
      obtain ⟨n, hn⟩ :=
        exists_pow_lt_of_lt_one (show (0 : ℚ) < v.1 ^ 2 - 2 by linarith)
          (show (1 / 2 : ℚ) < 1 by norm_num)
      obtain ⟨m, hpm, -, hhigh⟩ := hband (n + 2)
      have herr := nt_err m
      have hm1 := nt_one_le m
      have hsmall : (1 / 2 : ℚ) ^ (m + 2) ≤ (1 / 2 : ℚ) ^ n := by
        have h2 : (1 / 2 : ℚ) ^ (m + 2) = (1 / 2 : ℚ) ^ m * (1 / 2 : ℚ) ^ 2 := by ring
        have h3 : (1 / 2 : ℚ) ^ (n + 2) = (1 / 2 : ℚ) ^ n * (1 / 2 : ℚ) ^ 2 := by ring
        have hpn : (0 : ℚ) < (1 / 2 : ℚ) ^ n := by positivity
        rw [h2]
        rw [h3] at hpm
        nlinarith [hpm]
      nlinarith [hhigh, herr, hsmall, hn]

/-! ### The failure is of the **nest** condition `S₁` here too -/

/--
The cofinal **nest** inside `straddleFamily`: the intervals `[phi (n+2), nt n]`, decreasing onto
the cut at `√2`. `nt` descends to the cut from above and `phi` ascends to it from below, so the
family is a `⊆`-chain outright.

No `1 ≤ a` guard is needed here, unlike `SeparatingFrame.nest`: this carrier's segment endpoints
are already `{t : ℚ // 0 < t}`, so `phi_pos` suffices. The index is still shifted by two, to keep
the two witnesses' nests literally the same intervals.

Paper: `def:frame#Saturation`
-/
def nest : Set (Set TQ) :=
  {s | ∃ n : ℕ, s = Seg rel (p ⟨phi (n + 2), phi_pos (n + 2)⟩)
    (p ⟨nt n, by linarith [nt_one_le n]⟩)
    (nt n - phi (n + 2)) (nt n - phi (n + 2))}

/--
**The ℚ-carrier two-origin relation fails the nest condition `S₁`**, not merely the `⊇`-directed
condition `S₁ᵈ` (`not_rel_saturation`).

The companion of `SeparatingFrame.not_srel_nestSaturation`, and it makes the correction uniform:
**neither** of the development's `¬ Saturation` witnesses separates the directed form from the
nest form, so neither bears on whether `S₁ → S₁ᵈ`. That question stays open; see
`TaskFrame.Saturation`'s docstring for what a witness would have to look like.

Paper: `def:frame#Saturation`
-/
theorem not_rel_nestSaturation : ¬ TaskFrame.NestSaturation rel := by
  intro hS1
  have hlt : ∀ n : ℕ, phi (n + 2) < nt n := fun n =>
    lt_of_straddle (phi_pos (n + 2)) (by linarith [nt_one_le n])
      (phi_sq_lt_two (n + 2)) (nt_sq_gt n)
  have hmemiff : ∀ (n : ℕ) (w : TQ),
      w ∈ Seg rel (p ⟨phi (n + 2), phi_pos (n + 2)⟩) (p ⟨nt n, by linarith [nt_one_le n]⟩)
          (nt n - phi (n + 2)) (nt n - phi (n + 2))
        ↔ ∃ s : {t : ℚ // 0 < t}, w = p s ∧ phi (n + 2) ≤ s.1 ∧ s.1 ≤ nt n := by
    intro n w
    exact mem_straddle (a := ⟨phi (n + 2), phi_pos (n + 2)⟩)
      (b := ⟨nt n, by linarith [nt_one_le n]⟩) (hlt n) w
  have hne : nest.Nonempty := ⟨_, ⟨0, rfl⟩⟩
  have hchain : IsChain (· ⊆ ·) nest := by
    rintro s₁ ⟨m, rfl⟩ s₂ ⟨n, rfl⟩ -
    rcases le_total m n with h | h
    · refine Or.inr fun w hw => ?_
      rw [hmemiff] at hw ⊢
      obtain ⟨s, hs, h1, h2⟩ := hw
      exact ⟨s, hs, le_trans (phi_mono (by omega)) h1, le_trans h2 (nt_antitone h)⟩
    · refine Or.inl fun w hw => ?_
      rw [hmemiff] at hw ⊢
      obtain ⟨s, hs, h1, h2⟩ := hw
      exact ⟨s, hs, le_trans (phi_mono (by omega)) h1, le_trans h2 (nt_antitone h)⟩
  have hmem : ∀ s ∈ nest, (IsFiber rel s ∨ IsSegment rel s) ∧ s.Nonempty := by
    rintro s ⟨n, rfl⟩
    refine ⟨Or.inr ⟨_, _, _, _, by linarith [hlt n], by linarith [hlt n], rfl⟩,
      ⟨p ⟨phi (n + 2), phi_pos (n + 2)⟩,
        (hmemiff n _).mpr ⟨⟨phi (n + 2), phi_pos (n + 2)⟩, rfl, le_rfl, (hlt n).le⟩⟩⟩
  obtain ⟨w, hw⟩ := hS1 nest ⟨hne, hchain⟩ hmem
  obtain ⟨v, hv, -, -⟩ := (hmemiff 0 w).mp (Set.mem_sInter.mp hw _ ⟨0, rfl⟩)
  subst hv
  have hband : ∀ n : ℕ, phi (n + 2) ≤ v.1 ∧ v.1 ≤ nt n := by
    intro n
    obtain ⟨s, hs, h1, h2⟩ := (hmemiff n _).mp (Set.mem_sInter.mp hw _ ⟨n, rfl⟩)
    have : s = v := by injection hs with h; exact h.symm
    subst this
    exact ⟨h1, h2⟩
  have hq1 : (1 : ℚ) ≤ v.1 := le_trans (one_le_phi_add_two 0) (hband 0).1
  have hle : v.1 ^ 2 ≤ 2 := by
    by_contra hcon
    have hc := lt_of_not_ge hcon
    obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one (show (0 : ℚ) < v.1 ^ 2 - 2 by linarith)
      (show (1 / 2 : ℚ) < 1 by norm_num)
    have hb := (hband n).2
    have herr := nt_err n
    have h1 := nt_one_le n
    have hsmall : (1 / 2 : ℚ) ^ (n + 2) ≤ (1 / 2 : ℚ) ^ n :=
      pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
    nlinarith [hb, herr, h1, hsmall, hn]
  have hge : (2 : ℚ) ≤ v.1 ^ 2 := by
    by_contra hcon
    have hc := lt_of_not_ge hcon
    obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one (show (0 : ℚ) < (2 - v.1 ^ 2) / 3 by linarith)
      (show (1 / 2 : ℚ) < 1 by norm_num)
    have ha := (hband n).1
    have hsq := nt_sq_gt (n + 2)
    have hstart := nt_le_start (n + 2)
    have hepos : (0 : ℚ) < (1 / 2 : ℚ) ^ (n + 2) := by positivity
    have hsmall : (1 / 2 : ℚ) ^ (n + 2) ≤ (1 / 2 : ℚ) ^ n :=
      pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
    have hphi : phi (n + 2) = nt (n + 2) - (1 / 2 : ℚ) ^ (n + 2) := rfl
    have h1 := one_le_phi_add_two n
    nlinarith [ha, hsq, hstart, hepos, hsmall, hn, hphi, h1]
  exact sq_ne_two v.1 (le_antisymm hle hge)

end RationalTwoOrigins

/-! ## The separating frame: *Completion* holds and *Saturation* fails -/

namespace SeparatingFrame

open FormalSystem.Semantics FormalSystem.Semantics.TaskFrame
open FormalSystem.Semantics.PartialHistory (hasNearest_int)

/-!
`W = ℚ`, `D = ℤ`, `w ⇒_x v` iff `|v - w| ≤ |x|` — unit-speed drift on a rationally incomplete
carrier over **discrete** time. This is the theorem of the collection rather than one more
independence row: it separates *Completion* from *Saturation*, and so settles the converse
`Completion → Saturation` negatively.

Three facts a reader needs, in the order they matter:

1. ***Completion* holds by the nearest-times argument, and needs no completeness of the carrier
   at all** (`srel_completion`). `ℤ` has a nearest domain time on each side of the target time
   `z` (`PartialHistory.hasNearest_int`), so the constraint that nearest time imposes is the
   `⊆`-least one and the witness is read off it. No intersection of infinitely many shrinking
   constraints is ever demanded. This is `PartialHistory.completion_of_hasNearest`'s argument,
   run at the bare relation because `srel` carries no `FrameOver` wrapper.

2. ***Saturation* fails, because fibres and segments are not indexed by times**
   (`not_srel_saturation`). A `⊇`-directed family of *segments* is ordered by inclusion and by
   nothing else; the durations being integers constrains the family not at all. So the family of
   rational intervals `[a, b]` with `a² < 2 < b²` — each realised as the segment
   `[b-1, a+1]_1^1` — shrinks onto the Dedekind cut `{q : q² < 2} | {q : 2 < q²}`, which has no
   rational point. The contrast with (1) is the whole content of the separation: **time-indexed
   quantifiers collapse over an order with nearest times, ball-indexed ones never do.**

3. **The separation is realised over ℤ-time** — precisely the region where
   `PartialHistory.extension_of_isZTime` already shows *Saturation* is redundant for
   `thm:extension`. So *Saturation* excludes ordinary discrete-time frames with a dense state
   space, and `thm:extension` has no need of that exclusion. Together with
   `RationalTwoOrigins.not_rel_completion` above — which rules the dense-time family out
   entirely — this is why the separator had to be discrete.

**Why `not_srel_totalComp` is here.** The converse *does* hold under mixed-sign composition plus
*Limit* (`saturation_of_completion`, in the `specs/evidence/frame-constraints-audit/` probe), so
any separating frame **must** fail mixed-sign composition. This frame does
(`not_srel_totalComp`): the theorem is the consistency check on the separation, not a stray
result.
-/

/-- Unit-speed drift on `ℚ` over `ℤ`-time. -/
def srel (w : ℚ) (x : ℤ) (v : ℚ) : Prop := |v - w| ≤ |(x : ℚ)|

theorem srel_iff {w : ℚ} {x : ℤ} {v : ℚ} : srel w x v ↔ |v - w| ≤ |(x : ℚ)| := Iff.rfl

theorem srel_of_nonneg {w : ℚ} {x : ℤ} {v : ℚ} (hx : 0 ≤ x) :
    srel w x v ↔ |v - w| ≤ (x : ℚ) := by
  rw [srel_iff, abs_of_nonneg (by exact_mod_cast hx : (0 : ℚ) ≤ (x : ℚ))]

/-! ### *Seriality*, *Compositionality*, *Limit* -/

/-- **The separating frame satisfies *Seriality***: every state is its own successor and
predecessor, since `|w - w| = 0 ≤ |x|`. -/
theorem srel_serial : Serial srel := by
  intro w x hx
  have h : srel w x w := by
    rw [srel_iff, sub_self, abs_zero]
    exact abs_nonneg _
  exact ⟨⟨w, h⟩, ⟨w, h⟩⟩

/-- **The separating frame satisfies *Compositionality***: a drift of at most `x + y` splits at
whichever intermediate point the two budgets allow. -/
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

/-- **The separating frame satisfies *Limit***: the only duration of absolute value below `1` is
`0`, and a zero-duration task pins the state. -/
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

/-! ### *Completion* holds: `ℤ` has nearest times -/

/--
**The separating frame satisfies *Completion*.**

`ℤ` has nearest times (`PartialHistory.hasNearest_int`), so the constraint imposed by the nearest
domain time on each side of `z` is the `⊆`-least one and the witness is read off it — no
completeness of the carrier `ℚ` is demanded anywhere. Two-sided, the witness is the larger of the
two one-sided endpoints; one-sided, it is the nearest time's own state.

Paper: — (*Completion* is the derived condition the extension chain consumes and has no anchor in
the manuscript; `def:frame`'s fourth constraint is *Saturation*)
-/
theorem srel_completion : TaskFrame.Completion srel := by
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

/-! ### *Saturation* fails: segments shrink onto a Dedekind cut -/

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

-- The `1 ≤ b` conjunct is load bearing and easy to lose. Without it, `2 < b ^ 2` also admits
-- `b ≤ -2`, and then `[a, b]` is empty rather than a nonempty segment, so the `s.Nonempty` half
-- of *Saturation*'s member condition fails. `RationalTwoOrigins.straddleFamily` needs no such
-- guard because its endpoints are `{t : ℚ // 0 < t}`; porting the argument to a bare-`ℚ` carrier
-- is exactly where the guard goes missing.
/-- The `⊇`-directed family of rational intervals straddling the cut at `√2`. -/
def straddle : Set (Set ℚ) :=
  {s | ∃ a b : ℚ, 1 ≤ a ∧ a ^ 2 < 2 ∧ 2 < b ^ 2 ∧ 1 ≤ b ∧ b ≤ 2 ∧
    s = Seg srel (b - 1) (a + 1) 1 1}

theorem lt_of_straddle {a b : ℚ} (ha0 : 0 < a) (hb0 : 0 < b) (ha : a ^ 2 < 2) (hb : 2 < b ^ 2) :
    a < b := by
  by_contra hc
  exact absurd hb (not_lt.mpr (by nlinarith [not_lt.mp hc]))

/--
**The ℚ-over-ℤ drift relation FAILS *Saturation***, although it satisfies *Completion*
(`srel_completion`), *Seriality*, *Compositionality* and *Limit*.

**So `Completion → Saturation` is false, unconditionally, and *Completion* is a *strict*
weakening of *Saturation*.** Durations are integers, so no coherent family of states can
accumulate and *Completion* is safe; but fibres and segments are not indexed by times, and a
`⊇`-directed family of them shrinks onto the cut `{q : q² < 2} | {q : 2 < q²}`, which has no
rational point.

Paper: `def:frame#Saturation`
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

/-! ### The failure is of the **nest** condition `S₁`, not merely of `S₁ᵈ` -/

/--
The cofinal **nest** inside `straddle`: the intervals `[phi (n+2), nt n]`, in the `mem_sseg`
realisation `Seg srel (nt n - 1) (phi (n + 2) + 1) 1 1`, decreasing onto the cut at `√2`.

`nt` descends to the cut from above and `phi` ascends to it from below, so this family is a
`⊆`-chain outright — no directedness is needed to refine two of its members. Its existence is
what makes the separating frame a witness against the nest condition `S₁` and not merely against
the `⊇`-directed condition `S₁ᵈ`.

Paper: `def:frame#Saturation`
-/
def nest : Set (Set ℚ) :=
  {s | ∃ n : ℕ, s = Seg srel (RationalTwoOrigins.nt n - 1)
    (RationalTwoOrigins.phi (n + 2) + 1) 1 1}

/--
**Correction of a standing assumption.** The ℚ-over-ℤ drift relation satisfies *Seriality*,
*Compositionality*, *Limit* and *Completion*, and fails the **nest** condition
`S₁` (`TaskFrame.NestSaturation`) — not merely the `⊇`-directed condition `S₁ᵈ`
(`TaskFrame.Saturation`, `not_srel_saturation`).

So the existing sharpness result is about `S₁`, and **neither existing `¬ Saturation` witness
says anything about directedness**: the converse `S₁ → S₁ᵈ` stays open, and closing it would need
a duration type with mismatched one-sided cofinal characters (see `TaskFrame.Saturation`'s
docstring for the recipe). It was tempting to read `not_srel_saturation` as bearing on that
question; it does not, and this theorem is what settles the reading rather than leaving it as an
inference.

The nest is `nest` — the intervals `[phi (n+2), nt n]` — and the three obligations are discharged
where `not_srel_saturation` discharges its own: membership by `mem_sseg`, nonemptiness by
`lt_of_straddle`, and emptiness of the intersection by two `exists_pow_lt_of_lt_one` squeezes
pinning any common point to `q² = 2`, which `RationalTwoOrigins.sq_ne_two` refutes.

Paper: `def:frame#Saturation`
-/
theorem not_srel_nestSaturation : ¬ TaskFrame.NestSaturation srel := by
  intro hS1
  have nest_width : ∀ n : ℕ,
      RationalTwoOrigins.nt n - RationalTwoOrigins.phi (n + 2) ≤ 2 := fun n => by
    linarith [RationalTwoOrigins.nt_le_start n, RationalTwoOrigins.one_le_phi_add_two n]
  have nest_lt : ∀ n : ℕ,
      RationalTwoOrigins.phi (n + 2) < RationalTwoOrigins.nt n := fun n =>
    lt_of_straddle (by linarith [RationalTwoOrigins.one_le_phi_add_two n])
      (by linarith [RationalTwoOrigins.nt_one_le n])
      (RationalTwoOrigins.phi_sq_lt_two (n + 2)) (RationalTwoOrigins.nt_sq_gt n)
  have hmemiff : ∀ (n : ℕ) (q : ℚ),
      q ∈ Seg srel (RationalTwoOrigins.nt n - 1) (RationalTwoOrigins.phi (n + 2) + 1) 1 1
        ↔ RationalTwoOrigins.phi (n + 2) ≤ q ∧ q ≤ RationalTwoOrigins.nt n :=
    fun n q => mem_sseg (nest_width n)
  have hne : nest.Nonempty := ⟨_, ⟨0, rfl⟩⟩
  have hchain : IsChain (· ⊆ ·) nest := by
    rintro s₁ ⟨m, rfl⟩ s₂ ⟨n, rfl⟩ -
    rcases le_total m n with h | h
    · refine Or.inr fun q hq => ?_
      rw [hmemiff] at hq ⊢
      exact ⟨le_trans (RationalTwoOrigins.phi_mono (by omega)) hq.1,
        le_trans hq.2 (RationalTwoOrigins.nt_antitone h)⟩
    · refine Or.inl fun q hq => ?_
      rw [hmemiff] at hq ⊢
      exact ⟨le_trans (RationalTwoOrigins.phi_mono (by omega)) hq.1,
        le_trans hq.2 (RationalTwoOrigins.nt_antitone h)⟩
  have hmem : ∀ s ∈ nest, (IsFiber srel s ∨ IsSegment srel s) ∧ s.Nonempty := by
    rintro s ⟨n, rfl⟩
    refine ⟨Or.inr ⟨RationalTwoOrigins.nt n - 1, RationalTwoOrigins.phi (n + 2) + 1, 1, 1,
      by norm_num, by norm_num, rfl⟩,
      ⟨RationalTwoOrigins.phi (n + 2), (hmemiff n _).mpr ⟨le_rfl, (nest_lt n).le⟩⟩⟩
  obtain ⟨q, hq⟩ := hS1 nest ⟨hne, hchain⟩ hmem
  have hband : ∀ n : ℕ,
      RationalTwoOrigins.phi (n + 2) ≤ q ∧ q ≤ RationalTwoOrigins.nt n := fun n =>
    (hmemiff n q).mp (Set.mem_sInter.mp hq _ ⟨n, rfl⟩)
  have hq1 : (1 : ℚ) ≤ q :=
    le_trans (RationalTwoOrigins.one_le_phi_add_two 0) (hband 0).1
  have hle : q ^ 2 ≤ 2 := by
    by_contra hcon
    have hc := lt_of_not_ge hcon
    obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one (show (0 : ℚ) < q ^ 2 - 2 by linarith)
      (show (1 / 2 : ℚ) < 1 by norm_num)
    have hb := (hband n).2
    have herr := RationalTwoOrigins.nt_err n
    have h1 := RationalTwoOrigins.nt_one_le n
    have hsmall : (1 / 2 : ℚ) ^ (n + 2) ≤ (1 / 2 : ℚ) ^ n :=
      pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
    nlinarith [hb, herr, h1, hsmall, hn]
  have hge : (2 : ℚ) ≤ q ^ 2 := by
    by_contra hcon
    have hc := lt_of_not_ge hcon
    obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one (show (0 : ℚ) < (2 - q ^ 2) / 3 by linarith)
      (show (1 / 2 : ℚ) < 1 by norm_num)
    have ha := (hband n).1
    have hsq := RationalTwoOrigins.nt_sq_gt (n + 2)
    have hstart := RationalTwoOrigins.nt_le_start (n + 2)
    have hepos : (0 : ℚ) < (1 / 2 : ℚ) ^ (n + 2) := by positivity
    have hsmall : (1 / 2 : ℚ) ^ (n + 2) ≤ (1 / 2 : ℚ) ^ n :=
      pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
    have hphi : RationalTwoOrigins.phi (n + 2)
        = RationalTwoOrigins.nt (n + 2) - (1 / 2 : ℚ) ^ (n + 2) := rfl
    have h1 := RationalTwoOrigins.one_le_phi_add_two n
    nlinarith [ha, hsq, hstart, hepos, hsmall, hn, hphi, h1]
  exact RationalTwoOrigins.sq_ne_two q (le_antisymm hle hge)

/-! ### Segments are load bearing: a fibers-only axiom is inadequate -/

/--
*Saturation*'s statement with the fiber/segment disjunction narrowed to **fibers alone**: every
`⊇`-directed family of nonempty fibers has nonempty intersection.

This is the `⊇`-directed form `S₁ᵈ`, not the nest form, so it is deliberately **not** an
instantiation of `Order.SphericallyComplete` — the general layer in
`ForMathlib/Order/BallSpace.lean` carries the nest condition, and a directed sibling there would
be an addition that nothing else needs.

Paper: — (formalization-native; the fibers-only weakening of `def:frame`'s *Saturation*, stated
here only to be refuted as a candidate)
-/
def FiberSaturation {W : Type} {D : Type} (R : W → D → W → Prop) : Prop :=
  ∀ S : Set (Set W), DirectedFamily S →
    (∀ s ∈ S, IsFiber R s ∧ s.Nonempty) → (⋂₀ S).Nonempty

/-- A fiber of `srel` is the rational interval of radius `|x|` about `w`. -/
theorem mem_fib_srel {w v : ℚ} {x : ℤ} :
    v ∈ Fib srel w x ↔ |v - w| ≤ |(x : ℚ)| := Iff.rfl

/-- The fiber radii are **integers**, so they are compared through `Int.natAbs`. -/
theorem natAbs_cast_rat (x : ℤ) : ((x.natAbs : ℕ) : ℚ) = |(x : ℚ)| := by
  rw [← Int.cast_abs, Int.abs_eq_natAbs, Int.cast_natCast]

/--
**The separating frame satisfies the fibers-only condition.**

The radii of `srel`'s fibers are **integers**, so among the members of any directed family there
is one, `s₀`, of least radius. Directedness refines `s₀` and an arbitrary member `J` by some
member `K ⊆ s₀ ∩ J`; minimality gives `K` radius at least `s₀`'s, while `K ⊆ s₀` gives it radius
at most `s₀`'s, so the two radii agree — and a closed interval contained in another of the same
radius is that interval. Hence `s₀ = K ⊆ J` for every `J`, and `s₀` is nonempty, so the whole
family meets.

The discreteness of `ℤ` is doing the work, exactly as it does for `srel_completion`: it is what
supplies a least radius. Over a dense duration type the radii could shrink without a minimum and
this argument would say nothing.

Paper: — (formalization-native; the positive half of the fibers-only sharpness fact)
-/
theorem srel_fiberSaturation : FiberSaturation srel := by
  classical
  intro S hdir hmem
  obtain ⟨hSne, hdirS⟩ := hdir
  have hex : ∃ n : ℕ, ∃ s ∈ S, ∃ (w : ℚ) (x : ℤ), s = Fib srel w x ∧ x.natAbs = n := by
    obtain ⟨s, hs⟩ := hSne
    obtain ⟨w, x, hwx⟩ := (hmem s hs).1
    exact ⟨x.natAbs, s, hs, w, x, hwx, rfl⟩
  obtain ⟨s₀, hs₀, w₀, x₀, hs₀eq, hx₀⟩ := Nat.find_spec hex
  have hmin : ∀ (s : Set ℚ), s ∈ S → ∀ (w : ℚ) (x : ℤ), s = Fib srel w x →
      Nat.find hex ≤ x.natAbs := by
    intro s hs w x hsx
    by_contra hlt
    exact Nat.find_min hex (Nat.lt_of_not_ge hlt) ⟨s, hs, w, x, hsx, rfl⟩
  have hsub : ∀ J ∈ S, s₀ ⊆ J := by
    intro J hJ
    obtain ⟨K, hK, hKsub⟩ := hdirS s₀ hs₀ J hJ
    obtain ⟨w', x', hK'⟩ := (hmem K hK).1
    have hKle : Nat.find hex ≤ x'.natAbs := hmin K hK w' x' hK'
    have hx₀le : (|(x₀ : ℚ)|) ≤ |(x' : ℚ)| := by
      rw [← natAbs_cast_rat, ← natAbs_cast_rat]
      exact_mod_cast hx₀ ▸ hKle
    have hKs₀ : K ⊆ s₀ := fun v hv => (hKsub hv).1
    have hup : |(w' + |(x' : ℚ)|) - w₀| ≤ |(x₀ : ℚ)| := by
      have hmemK : (w' + |(x' : ℚ)|) ∈ K := by
        rw [hK', mem_fib_srel]; simp [abs_of_nonneg (abs_nonneg ((x' : ℚ)))]
      have hmem₀ := hKs₀ hmemK
      rwa [hs₀eq, mem_fib_srel] at hmem₀
    have hdown : |(w' - |(x' : ℚ)|) - w₀| ≤ |(x₀ : ℚ)| := by
      have hmemK : (w' - |(x' : ℚ)|) ∈ K := by
        rw [hK', mem_fib_srel]; simp [abs_of_nonpos (neg_nonpos.mpr (abs_nonneg ((x' : ℚ))))]
      have hmem₀ := hKs₀ hmemK
      rwa [hs₀eq, mem_fib_srel] at hmem₀
    rw [abs_le] at hup hdown
    have hxeq : |(x' : ℚ)| = |(x₀ : ℚ)| := le_antisymm (by linarith [hup.2, hdown.1]) hx₀le
    have hweq : w' = w₀ := by
      have h1 : w' ≤ w₀ := by linarith [hup.2, hxeq]
      have h2 : w₀ ≤ w' := by linarith [hdown.1, hxeq]
      linarith
    refine fun v hv => hKsub ?_ |>.2
    rw [hK', mem_fib_srel, hweq, hxeq]
    rw [hs₀eq, mem_fib_srel] at hv
    exact hv
  obtain ⟨u, hu⟩ := (hmem s₀ hs₀).2
  exact ⟨u, Set.mem_sInter.2 fun J hJ => hsub J hJ hu⟩

/--
**Segments are load bearing: a fibers-only fourth constraint is inadequate.**

`srel` satisfies the fibers-only condition (`srel_fiberSaturation`) and fails *Saturation*
(`not_srel_saturation`), so narrowing `def:frame`'s fourth constraint to fibers alone would
**strictly** weaken it — and weaken it past what `lem:step` needs, since the straddling regime of
`Constraints τ z` consists of segments and contains no fiber at all.

This closes the fibers-only candidate row: the segment clause of *Saturation* is not redundant
decoration inherited from `def:task-relation`, it is the half of the ball space that the
two-sided constraint families actually live in.

Paper: — (formalization-native; the sharpness fact that closes the fibers-only candidate)
-/
theorem not_fiberSaturation_imp_saturation :
    FiberSaturation srel ∧ ¬ TaskFrame.Saturation srel :=
  ⟨srel_fiberSaturation, not_srel_saturation⟩

/-! ### Consistency with `saturation_of_completion`: mixed-sign composition fails here -/

/-- Mixed-sign composition, as declared in `specs/evidence/frame-constraints-audit/`: composition
with **no** sign proviso on the two durations. -/
def TotalComp {W : Type} {D : Type} [AddCommGroup D] (R : W → D → W → Prop) : Prop :=
  ∀ w u v x y, R w x u → R u y v → R w (x + y) v

/-- **Mixed-sign composition fails here**, as it must: `saturation_of_completion` proves the
converse `Completion → Saturation` under `TotalComp` plus *Limit*, so any frame separating the
two has to refute `TotalComp`. Drifting `0 ⇒₁ 1 ⇒₋₁ 2` would compose to `0 ⇒₀ 2`. -/
theorem not_srel_totalComp : ¬ TotalComp srel := by
  intro h
  have h1 : srel 0 1 1 := by rw [srel_iff]; norm_num
  have h2 : srel 1 (-1) 2 := by rw [srel_iff]; norm_num
  have h3 := h 0 1 2 1 (-1) h1 h2
  rw [srel_iff] at h3
  norm_num at h3

end SeparatingFrame

/-! ## The void frame: *Seriality* is independent of the other three -/

/-- The **empty** task relation on `Bool` over `ℤ`-time. -/
def voidRel : Bool → ℤ → Bool → Prop := fun _ _ _ => False

/-- The void relation obeys the reflection law: both sides are `False`. -/
theorem voidRel_refl_law : ∀ w d u, voidRel w d u ↔ voidRel u (-d) w := by
  intro w d u; exact Iff.rfl

/--
**The void frame** `V` — the independence witness for *Seriality*.

Nothing is related to anything at any duration. *Compositionality* and *Limit* are vacuous,
*Saturation* is free because `Bool` is finite, and *Seriality* fails outright: it demands a
successor and a predecessor at every `x ≥ 0`, and the empty relation supplies neither.

No `IsRegular` instance is declared for this frame, by construction — it fails a constraint.
-/
def voidFrame : FrameOver intOrder :=
  FrameOver.ofReflective Bool voidRel voidRel_refl_law

theorem voidFrame_taskRel : voidFrame.TaskRel = voidRel :=
  FrameOver.ofReflective_taskRel_eq

/-- *Compositionality* holds **vacuously**: both halves of the biconditional are `False`.
Paper: `def:frame#Compositionality`
-/
theorem voidFrame_compositional : TaskFrame.Compositional voidFrame.TaskRel := by
  rw [voidFrame_taskRel]
  intro w v x y _ _
  exact ⟨fun h => h.elim, fun ⟨_, h, _⟩ => h.elim⟩

/-- *Limit* holds **vacuously**: the cone hypothesis cannot be met, since no duration relates
anything.
Paper: `def:frame#Limit`
-/
theorem voidFrame_limit : TaskFrame.Limit voidFrame.TaskRel := by
  rw [voidFrame_taskRel]
  intro w u h
  obtain ⟨y, _, hy⟩ := h 1 (by norm_num)
  exact hy.elim

/-- *Saturation* holds **for free**, by `cor:saturation-finite`
(`TaskFrame.saturation_of_finite`) — the carrier `Bool` is finite. It is not proved by hand.
Paper: `cor:saturation-finite`
-/
theorem voidFrame_saturation : TaskFrame.Saturation voidFrame.TaskRel := by
  rw [voidFrame_taskRel]
  exact TaskFrame.saturation_of_finite voidRel

/-- **The independence witness for *Seriality***: no state has a `0`-successor.
Paper: `def:frame#Seriality`
-/
theorem voidFrame_not_serial : ¬ TaskFrame.Serial voidFrame.TaskRel := by
  rw [voidFrame_taskRel]
  intro h
  obtain ⟨⟨u, hu⟩, _⟩ := h false 0 le_rfl
  exact hu.elim

/-! ## The bump frame: *Compositionality* is independent of the other three -/

/--
The **bump** relation on `Bool` over `ℤ`-time: the identity at duration `0`, the total relation at
duration `±1`, and the identity again from `|d| ≥ 2` outwards.
-/
def bumpRel : Bool → ℤ → Bool → Prop :=
  fun w d u => (d = 0 ∧ w = u) ∨ |d| = 1 ∨ (2 ≤ |d| ∧ w = u)

/-- The bump relation obeys the reflection law: every clause is symmetric under `d ↦ -d` together
with `w ↔ u`, since `|-d| = |d|` and `-d = 0 ↔ d = 0`. -/
theorem bumpRel_refl_law : ∀ w d u, bumpRel w d u ↔ bumpRel u (-d) w := by
  intro w d u
  simp only [bumpRel, abs_neg, neg_eq_zero]
  constructor
  · rintro (⟨h1, h2⟩ | h | ⟨h1, h2⟩)
    · exact Or.inl ⟨h1, h2.symm⟩
    · exact Or.inr (Or.inl h)
    · exact Or.inr (Or.inr ⟨h1, h2.symm⟩)
  · rintro (⟨h1, h2⟩ | h | ⟨h1, h2⟩)
    · exact Or.inl ⟨h1, h2.symm⟩
    · exact Or.inr (Or.inl h)
    · exact Or.inr (Or.inr ⟨h1, h2.symm⟩)

/--
**The bump frame** `B` — the independence witness for *Compositionality*.

The shape that refutes composition is the single "bump" at `|d| = 1`: a step of duration `1` may
change the state, but a pair of such steps must land in the duration-`2` clause, where only the
identity is permitted. So `ff ⇒₁ tt` and `tt ⇒₁ tt` hold while `ff ⇏₂ tt`, and the `←` half of
`def:frame#Compositionality`'s biconditional fails.

*Seriality* holds because every state relates to itself at every `x ≥ 0` (through the `d = 0`,
`|d| = 1` or `2 ≤ |d|` clause as `x` dictates). *Limit* is free by
`TaskFrame.limit_of_succOrder`, because the time is `ℤ` and the only duration-`0` pairs are the
identity. *Saturation* is free by `cor:saturation-finite` (`TaskFrame.saturation_of_finite`),
because the carrier `Bool` is finite. Neither is proved by hand.

No `IsRegular` instance is declared for this frame, by construction — it fails a constraint.
-/
def bumpFrame : FrameOver intOrder :=
  FrameOver.ofReflective Bool bumpRel bumpRel_refl_law

theorem bumpFrame_taskRel : bumpFrame.TaskRel = bumpRel :=
  FrameOver.ofReflective_taskRel_eq

/-- *Seriality* holds: every state is its own successor and predecessor at every `x ≥ 0`.
Paper: `def:frame#Seriality`
-/
theorem bumpFrame_serial : TaskFrame.Serial bumpFrame.TaskRel := by
  rw [bumpFrame_taskRel]
  have key : ∀ (w : Bool) (x : ℤ), 0 ≤ x → bumpRel w x w := by
    intro w x hx
    by_cases h0 : x = 0
    · exact Or.inl ⟨h0, rfl⟩
    by_cases h1 : x = 1
    · exact Or.inr (Or.inl (by rw [h1]; norm_num))
    · refine Or.inr (Or.inr ⟨?_, rfl⟩)
      rw [abs_of_nonneg hx]
      omega
  intro w x hx
  exact ⟨⟨w, key w x hx⟩, ⟨w, key w x hx⟩⟩

/-- *Limit* holds, through `TaskFrame.limit_of_succOrder`: the time is `ℤ`, so it suffices that
the duration-`0` pairs are exactly the identity.
Paper: `def:frame#Limit`
-/
theorem bumpFrame_limit : TaskFrame.Limit bumpFrame.TaskRel := by
  rw [bumpFrame_taskRel]
  haveI : SuccOrder (intOrder.carrier) := (inferInstance : SuccOrder ℤ)
  haveI : NoMaxOrder (intOrder.carrier) := (inferInstance : NoMaxOrder ℤ)
  refine TaskFrame.limit_of_succOrder (fun w u hR => ?_)
  rcases hR with ⟨_, h2⟩ | h | ⟨h1, _⟩
  · exact h2.symm
  · norm_num at h
  · norm_num at h1

/-- *Saturation* holds **for free**, by `cor:saturation-finite`
(`TaskFrame.saturation_of_finite`) — the carrier `Bool` is finite.
Paper: `cor:saturation-finite`
-/
theorem bumpFrame_saturation : TaskFrame.Saturation bumpFrame.TaskRel := by
  rw [bumpFrame_taskRel]
  exact TaskFrame.saturation_of_finite bumpRel

/--
**The independence witness for *Compositionality***: `ff ⇒₁ tt` and `tt ⇒₁ tt`, yet `ff ⇏₂ tt`,
so the composition (`←`) half of the biconditional fails.

Paper: `def:frame#Compositionality`
-/
theorem bumpFrame_not_compositional : ¬ TaskFrame.Compositional bumpFrame.TaskRel := by
  rw [bumpFrame_taskRel]
  intro h
  have hone : |(1 : ℤ)| = 1 := by norm_num
  have hrhs : ∃ u, bumpRel false 1 u ∧ bumpRel u 1 true :=
    ⟨true, Or.inr (Or.inl hone), Or.inr (Or.inl hone)⟩
  have hlhs := (h false true 1 1 (by norm_num) (by norm_num)).mpr hrhs
  rcases hlhs with ⟨h1, _⟩ | h1 | ⟨_, h2⟩
  · norm_num at h1
  · norm_num at h1
  · norm_num at h2

end FormalSystem.Semantics.StateTopology
