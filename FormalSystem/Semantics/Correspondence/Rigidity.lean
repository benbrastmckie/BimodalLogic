/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame
import Mathlib.Algebra.Order.Archimedean.Defs

/-!
# Rigidity: over a dense Archimedean order, a uniform dwell time forces a static frame

The paper's *Limit* axiom (`def:frame#Limit`, "$\bigcap_{x > 0} (w)_x = \{w\}$") says that every
world state `w` has, for each `u ≠ w`, *some* positive radius below which `u` is not reachable
from `w`. It does not say that one radius works for every `w`. This module studies what happens
when it does — when the frame has a **uniform dwell time**, a single `x₀ > 0` with
`(w)_{x₀} = {w}` for every `w` — and shows that over a dense Archimedean duration group this
collapses the frame entirely: `w ⇒_x u` holds iff `w = u`, at every `x`. Such a frame is
**static**. Because *Limit* on a finite carrier already supplies a uniform dwell time
(`TaskFrame.exists_uniform_radius_of_finite`, minimised over the carrier), every task frame with
finitely many world states over such an order is static.

## The proof, and what it consumes

The engine is a chop. *Compositionality* (`def:frame#Compositionality`) interpolates: a task of
duration `ε + y` factors through an intermediate state. If every task of duration in `[0, ε]`
is a loop, a task of duration `x ≥ 0` is chopped into `⌈x / ε⌉` loops and is itself a loop. The
Archimedean property supplies the `n` with `x ≤ n • ε` that the chop is measured against; this is
`TaskFrame.eq_of_rel_of_step`, which uses **only** interpolation, the step bound and
`[Archimedean D]` — no density, no *Limit*, no *Seriality*. Density is consumed exactly once, in
`TaskFrame.eq_of_rel_of_uniform_radius`, to pass from the strict cone radius `|y| < x₀` to a
closed step bound `y ≤ ε` for some `0 < ε < x₀`. The two `TaskFrame`-level results are stated at
that hypothesis rather than at the paper's, so that nothing is claimed beyond what the proof
uses.

The *biconditional* form `Static ↔ UniformDwell` at the bundled `FrameOver` level costs more
than the collapse. The direction "static implies uniform dwell" needs only a positive duration
to exist. The direction "uniform dwell implies static" needs, beyond the collapse for `x ≥ 0`,
the reflection law to cover negative `x`, and *Seriality* (`def:frame#Seriality`) to supply the
loop `w ⇒_x w` that `Static` asserts positively. So: the collapse `w ⇒_x u → w = u` uses only
interpolation and the dwell bound; the biconditional additionally uses *Seriality* and
reflection.

Bookkeeping deviation from the informal argument: the chop is run as an induction on the
Archimedean witness `n` rather than by choosing the least `n` with `x ≤ n • ε`; the two are the
same argument, and the induction avoids a well-foundedness detour.

## Scope note: time-indexed frames

The hypotheses here are about the duration group `D` of a task frame, whose task relation is
indexed by *durations*. Frames whose relation is indexed by *times* are a different structure
with a different rigidity boundary — Dedekind completeness of the time order rather than the
Archimedean property — and they now have their own modules: `Semantics/TimeIndexed.lean` defines
`TimeIndexed` and proves `TimeIndexed.constantHistories_of_lub`, that over a densely ordered,
Dedekind-complete time order finitely many states plus *Limit* alone **force constant
histories**; `Semantics/TimeIndexedSharpness.lean` proves
`TimeIndexed.qSwitchFrame_not_constantHistories`, that over `ℚ` a two-state time-indexed frame
switching across an irrational gap satisfies *Limit* and is not constant-historied, so
completeness cannot be dropped.

The conclusion there is constancy of histories, not the relation-level `Static` of this module:
`TimeIndexed.static_of_lub_of_realized` reaches `Static` only from two further hypotheses, a
reflexivity law and a realization law sending each permitted passage to a history that takes it.
The Archimedean hypothesis below should accordingly not be read as the boundary for time-indexed
frames, and `ℚ` is exactly where the two boundaries disagree: it is Archimedean, so the theorem
below applies to task frames over it, and it is not Dedekind-complete, so the time-indexed
theorem does not.

## Scope note: countable carriers over a Dedekind-complete order

The finiteness hypothesis below is not the boundary either. Over a Dedekind-complete duration
order — `ℝ` — a **countable** carrier already forces a static frame, with no finiteness, no
density and no Archimedean hypothesis at all: that is
`Semantics/Correspondence/RigidityReal.lean`'s `FrameOver.static_of_countable`. What replaces
density and the Archimedean property there is Dedekind completeness, entering through Baire's
theorem and Sierpiński's theorem on countable closed partitions of the line
(`ForMathlib/Topology/Sierpinski.lean`); the chop below is not run at all.

That module is kept separate from this one precisely because it consumes topology, which the
`## Import discipline` section here promises this module does not. `ℚ` is where the two
statements come apart: it is dense and Archimedean, so the theorem below applies to its
finite-carrier frames, and it is not Dedekind-complete, so countability does not suffice over it
— `Rigidity.ratClock_not_static` in `RigiditySharpness.lean` is the witness.

## Sharpness

Both hypotheses of `FrameOver.static_iff_uniformDwell` are needed; the compiled witnesses live in
`Semantics/Correspondence/RigiditySharpness.lean` (density cannot be dropped: `ℤ`; the
Archimedean property cannot be dropped: `ℚ ×ₗ ℚ`). That module also records that finiteness
cannot be weakened to countability over a dense Archimedean order (`ratClock_not_static`).

## Import discipline

This module imports only `FormalSystem.Semantics.TaskFrame` and
`Mathlib.Algebra.Order.Archimedean.Defs`; it defines no frame and takes no topology.
-/

namespace FormalSystem.Semantics
namespace TaskFrame

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
**A static relation.** `w ⇒_x u` holds iff `w = u`, at every duration `x`: no task ever changes
the world state, and every state loops at every duration.

Stated on a bare relation so that it applies to `F.TaskRel` for either bundling of a task frame.
The construction `FrameOver.staticFrame` is the canonical example (`staticFrame_rel_iff`).
-/
def Static {W : Type} (R : W → D → W → Prop) : Prop := ∀ w x u, R w x u ↔ w = u

/--
**A uniform dwell time.** Some positive `x₀` with `(w)_{x₀} = {w}` for *every* `w`: the *Limit*
axiom's per-state radius, made uniform across the carrier. Phrased through the cone `cone R w x₀`
exactly as the paper writes `(w)_x`.

`Static R → UniformDwell R` is immediate whenever a positive duration exists; the converse is the
rigidity theorem and needs a dense Archimedean `D` (`FrameOver.static_iff_uniformDwell`).
-/
def UniformDwell {W : Type} (R : W → D → W → Prop) : Prop :=
  ∃ x₀ : D, 0 < x₀ ∧ ∀ w, cone R w x₀ = {w}

/--
**The chop.** If every task of duration in `[0, ε]` is a loop, then every task of nonnegative
duration is a loop.

Stated at the hypothesis the proof actually uses: interpolation (`TaskFrame.Interpolates`, the
half of `def:frame#Compositionality` that splits a task), a closed step bound, and
`[Archimedean D]`. No density, no *Limit*, no *Seriality*, and no `Nontrivial D` — the
conclusion is vacuous when no positive `ε` exists. Choice-free: `lean_verify` reports
`[propext, Quot.sound]`.

The induction runs on the Archimedean witness `n` with `x ≤ n • ε`, generalising over the start
state and the duration, rather than on a least such `n`; see the module docstring.
-/
theorem eq_of_rel_of_step [Archimedean D] {W : Type} {R : W → D → W → Prop}
    (hint : Interpolates R) {ε : D} (hε : 0 < ε)
    (hstep : ∀ w u y, 0 ≤ y → y ≤ ε → R w y u → u = w) :
    ∀ w u x, 0 ≤ x → R w x u → u = w := by
  intro w u x hx hR
  obtain ⟨n, hn⟩ := Archimedean.arch x hε
  induction n generalizing w x with
  | zero =>
    have h0 : x = 0 := le_antisymm (by simpa using hn) hx
    exact hstep w u x hx (by rw [h0]; exact hε.le) hR
  | succ n ih =>
    rcases le_total x ε with hle | hgt
    · exact hstep w u x hx hle hR
    · have hx' : 0 ≤ x - ε := sub_nonneg.mpr hgt
      have hR' : R w (ε + (x - ε)) u := by rwa [add_sub_cancel]
      obtain ⟨v, hwv, hvu⟩ := hint w u ε (x - ε) hε.le hx' hR'
      have hv : v = w := hstep w v ε hε.le le_rfl hwv
      subst hv
      refine ih v (x - ε) hx' hvu ?_
      rw [succ_nsmul] at hn
      exact sub_le_iff_le_add.mpr hn

/--
**The collapse from a strict uniform radius.** If no task of duration `|y| < x₀` leaves its start
state, then no task of nonnegative duration does.

This is where density is consumed, and the only place: `exists_between` produces an `ε` strictly
between `0` and `x₀`, turning the strict radius into the closed step bound `eq_of_rel_of_step`
wants. Everything else is the chop.
-/
theorem eq_of_rel_of_uniform_radius [DenselyOrdered D] [Archimedean D] {W : Type}
    {R : W → D → W → Prop} (hint : Interpolates R)
    {x₀ : D} (hx₀ : 0 < x₀) (hrad : ∀ w u y, |y| < x₀ → R w y u → u = w) :
    ∀ w u x, 0 ≤ x → R w x u → u = w := by
  obtain ⟨ε, hε, hεx⟩ := exists_between hx₀
  exact eq_of_rel_of_step hint hε fun w u y hy hyε hR =>
      hrad w u y (by rw [abs_of_nonneg hy]; exact lt_of_le_of_lt hyε hεx) hR

end TaskFrame

namespace FrameOver

open TaskFrame

variable {D : TemporalOrder}

/--
**Uniform dwell implies static, at the hypotheses the proof consumes.**

The explicit-hypothesis form of `static_of_uniformDwell` below. Interpolation enters through
`TaskFrame.interpolates_of_comp` (*Compositionality*), the reflection law through
`FrameOver.reflection_of_limit` (*Limit*), and the positive half of `Static` through *Seriality*.
*Saturation* is reached by none of the three: this result is well before the extension chain.

The collapse `w ⇒_x u → w = u` for `x ≥ 0` is `TaskFrame.eq_of_rel_of_uniform_radius` at the
interpolation hypothesis; the reflection law extends it to negative `x`. The positive half of
`Static` — that `w ⇒_x w` for every `x` — comes from *Seriality* (`def:frame#Seriality`): some
`u` with `w ⇒_x u` exists, and the collapse identifies it with `w`.

`static_of_uniformDwell` below is this theorem at `[F.IsRegular]`, with its original statement.

Constraints consumed: Compositionality, Seriality, Limit
-/
theorem static_of_uniformDwell_of_compositional_serial_limit [DenselyOrdered ↑D] [Archimedean ↑D]
    (F : FrameOver D) (hcomp : TaskFrame.Compositional F.TaskRel)
    (hser : TaskFrame.Serial F.TaskRel) (hlim : TaskFrame.Limit F.TaskRel)
    (h : UniformDwell F.TaskRel) : Static F.TaskRel := by
  obtain ⟨x₀, hx₀, hcone⟩ := h
  have key := eq_of_rel_of_uniform_radius (TaskFrame.interpolates_of_comp hcomp) hx₀
    (fun w u y hy hR => by
      have : u ∈ cone F.TaskRel w x₀ := ⟨y, hy, hR⟩
      rw [hcone w] at this
      exact this)
  have fwd : ∀ w x u, F.TaskRel w x u → w = u := by
    intro w x u hR
    rcases le_total 0 x with hx | hx
    · exact (key w u x hx hR).symm
    · exact key u w (-x) (neg_nonneg.mpr hx) ((F.reflection_of_limit hlim w x u).mp hR)
  intro w x u
  refine ⟨fwd w x u, ?_⟩
  rintro rfl
  rcases le_total 0 x with hx | hx
  · obtain ⟨⟨u, hu⟩, _⟩ := hser w x hx
    have := fwd w x u hu
    subst this
    exact hu
  · obtain ⟨⟨u, hu⟩, _⟩ := hser w (-x) (neg_nonneg.mpr hx)
    have := fwd w (-x) u hu
    subst this
    exact (F.reflection_of_limit hlim w x w).mpr hu

/--
**Uniform dwell implies static**, over a dense Archimedean duration group.

The collapse `w ⇒_x u → w = u` for `x ≥ 0` is `TaskFrame.eq_of_rel_of_uniform_radius` at the
frame's own interpolation; the reflection law extends it to negative `x`. The positive half of
`Static` — that `w ⇒_x w` for every `x` — comes from *Seriality* (`def:frame#Seriality`): some
`u` with `w ⇒_x u` exists, and the collapse identifies it with `w`.

`static_of_uniformDwell_of_compositional_serial_limit` above is the explicit-hypothesis form,
which is the general one; this is that form at a regular frame.

Constraints consumed: Compositionality, Seriality, Limit
-/
theorem static_of_uniformDwell [DenselyOrdered ↑D] [Archimedean ↑D] (F : FrameOver D)
    [F.IsRegular] (h : UniformDwell F.TaskRel) : Static F.TaskRel := by
  exact F.static_of_uniformDwell_of_compositional_serial_limit F.comp F.serial F.limit h

/--
**Static implies uniform dwell**, over any duration group. Any positive duration is a uniform
dwell time of a static frame, since every cone of a static relation is the singleton of its
apex; `TaskFrame.exists_pos_of_nontrivial` supplies one.
-/
theorem uniformDwell_of_static (F : FrameOver D) (h : Static F.TaskRel) :
    UniformDwell F.TaskRel := by
  obtain ⟨x₀, hx₀⟩ := exists_pos_of_nontrivial (D := ↑D)
  refine ⟨x₀, hx₀, fun w => ?_⟩
  ext u
  constructor
  · rintro ⟨y, _, hR⟩
    exact ((h w y u).mp hR).symm
  · rintro rfl
    exact ⟨0, by simpa using hx₀, (h u 0 u).mpr rfl⟩

/--
**Rigidity.** Over a dense Archimedean duration group, a task frame is static iff it has a
uniform dwell time.

The forward direction holds over any duration group. The backward direction is the content: the
collapse uses only interpolation and the dwell bound (`TaskFrame.eq_of_rel_of_step`, with density
spent once to close the radius), and the biconditional additionally uses *Seriality* and the
reflection law. Both hypotheses are sharp — see `RigiditySharpness.lean`.

The backward direction is routed through
`static_of_uniformDwell_of_compositional_serial_limit`, the binder-free form, rather than through
the corollary beside it, so the marker below is proved where its hypotheses are explicit.

Constraints consumed: Compositionality, Seriality, Limit

Paper: — (the manuscript states no rigidity theorem; stated at the hypothesis the proof uses)
-/
theorem static_iff_uniformDwell [DenselyOrdered ↑D] [Archimedean ↑D] (F : FrameOver D)
    [F.IsRegular] : Static F.TaskRel ↔ UniformDwell F.TaskRel :=
  ⟨F.uniformDwell_of_static,
    F.static_of_uniformDwell_of_compositional_serial_limit F.comp F.serial F.limit⟩

/--
**A finite carrier has a uniform dwell time**, over any duration group. *Limit*
(`def:frame#Limit`) gives each state its own radius (`TaskFrame.exists_uniform_radius_of_finite`);
the minimum over the finite carrier is uniform. No order hypothesis on `D` beyond what
`TemporalOrder` carries — over `ℤ`, for instance, the radius `1` works vacuously, which is
exactly why density is needed in `static_of_finite`.
-/
theorem uniformDwell_of_finite (F : FrameOver D) [F.IsRegular] [Finite F.WorldState] :
    UniformDwell F.TaskRel := by
  classical
  haveI := Fintype.ofFinite F.WorldState
  have hrad := fun w => exists_uniform_radius_of_finite F.TaskRel F.limit w
  choose f hf using hrad
  have huniv : (Finset.univ : Finset F.WorldState).Nonempty :=
    ⟨F.worldNonempty.some, Finset.mem_univ _⟩
  refine ⟨Finset.univ.inf' huniv f, ?_, fun w => ?_⟩
  · rw [Finset.lt_inf'_iff]; exact fun w _ => (hf w).1
  · ext u
    constructor
    · rintro ⟨y, hy, hR⟩
      exact (hf w).2 u y (lt_of_lt_of_le hy (Finset.inf'_le f (Finset.mem_univ w))) hR
    · rintro rfl
      refine ⟨0, ?_, F.nullity u⟩
      rw [abs_zero, Finset.lt_inf'_iff]; exact fun w _ => (hf w).1

/--
**Finite frames over a dense Archimedean order are static.** *Limit* plus finiteness give a
uniform dwell time (`uniformDwell_of_finite`); rigidity (`static_iff_uniformDwell`) does the
rest. So over such an order, no task frame with finitely many world states has any nontrivial
dynamics at all.

Paper: — (the manuscript states no rigidity theorem; stated at the hypothesis the proof uses)
-/
theorem static_of_finite [DenselyOrdered ↑D] [Archimedean ↑D] (F : FrameOver D)
    [F.IsRegular] [Finite F.WorldState] : Static F.TaskRel :=
  F.static_of_uniformDwell F.uniformDwell_of_finite

end FrameOver
end FormalSystem.Semantics
