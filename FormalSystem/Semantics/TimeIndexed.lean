/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame
import Mathlib.Algebra.Order.Group.Bounds

/-!
# Time-indexed frames, and the Dedekind rigidity boundary

A task frame (`FrameOver`) indexes its relation by a **duration**: `w ⇒_x u` says that some task
of length `x` carries `w` to `u`, and the same duration means the same thing wherever it is
applied. A **time-indexed frame** indexes the relation by an ordered *pair of times* instead:
`G.R w x y u` says that the frame permits passing from state `w` at time `x` to state `u` at
time `y`. Nothing requires the permission to depend on `y - x` alone; a time-indexed frame that
does satisfy that invariance is `Stationary`, and stationarity is precisely the bridge back to
the duration-indexed picture.

The two structures have different rigidity boundaries, and that is what this module and its
companion `TimeIndexedSharpness.lean` exist to prove.

* **Duration-indexed** (`Semantics/Correspondence/Rigidity.lean`): over a **dense Archimedean**
  duration group, finitely many world states plus *Limit* force a static frame. The engine is a
  chop — *Compositionality* factors a long task into short ones and the Archimedean property
  bounds how many pieces are needed.
* **Time-indexed** (here): over a **densely ordered, Dedekind-complete** time order, finitely
  many states plus *Limit* force every history to be constant. The engine is a supremum — there
  is no duration to chop, so the argument instead walks a least upper bound up the time line and
  uses completeness to close every gap. *Compositionality* is never used.

Over `ℚ` the two boundaries genuinely disagree: `ℚ` is Archimedean but not Dedekind-complete, and
`TimeIndexedSharpness.lean` exhibits a two-state time-indexed frame over `ℚ` satisfying every
condition below — including *Limit* — whose switching history is not constant. That module also
carries the side-by-side comparison table.

## Shared infrastructure

This structure is **shared infrastructure, not a local convenience**. The frame-correspondence
program of the accompanying manuscript states its Theorem A — the correspondence between a
time-indexed frame's histories and its two-time relation over `ℤ`-time — in terms of exactly this
structure, and that development is the other intended consumer of this module. Accordingly:

* the field names are `W`, `nonempty` and `R`, taken verbatim from that program's Lean-verification
  report, and deliberately **not** `FrameOver`'s `WorldState` / `worldNonempty` / `PosRel`. The
  divergence is mandated so the correspondence development consumes this structure unchanged, and
  it doubles as a signal that this is a different structure rather than a second presentation of a
  task frame;
* the predicate family is stated at the generality that program needs, not merely at what the
  rigidity theorem below consumes. `Stationary` and `P` carry no theorem here at all; they are
  present because Theorem A is stated in terms of them.

*Saturation* has no analogue here. On a finite carrier it is automatic, no result in this module
or its companion consumes it, and stating it would require transposing the fiber/segment
vocabulary to absolute times for no use.

## What the positive theorem consumes

`constantHistories_of_lub` takes a densely ordered time carrier, a Prop-valued least-upper-bound
hypothesis, a finite state type and *Limit* (`def:frame#Limit`, transposed to times). It uses
nothing else: no *Compositionality*, no *Seriality*, no *Saturation*, no converse convention, no
unboundedness of the time order, and no topology. Dedekind completeness enters as the Prop-valued
`hlub` binder rather than as a `ConditionallyCompleteLinearOrder` instance, following the
convention `Semantics/DurationClassification.lean` already states for duration groups.

The theorem concludes `ConstantHistories`, **not** the relation-level `Static`. Those are two
different claims: constancy of histories says nothing about pairs `⟨w, u⟩` that no history
realizes. `static_of_lub_of_realized` closes that gap, but only from two further named
hypotheses — a reflexivity law and a realization law — which are recorded as hypotheses precisely
because they are not consequences of the ones above.

## Import discipline

This module imports only `FormalSystem.Semantics.TaskFrame` (for `TemporalOrder` and
`TaskFrame.exists_pos_of_nontrivial`) and `Mathlib.Algebra.Order.Group.Bounds` (for
`IsLUB.exists_between_sub_self`). The analysis import that the `ℚ` witness needs lives in
`TimeIndexedSharpness.lean` alone, so that the correspondence program's dependency path stays at
`TaskFrame` weight.
-/

namespace FormalSystem.Semantics

/--
**A time-indexed frame** over the time order `D`: a nonempty type of states together with a
relation indexed by an ordered pair of times, `G.R w x y u` reading "the frame permits state `w`
at time `x` to be followed by state `u` at time `y`".

Field names are the frame-correspondence program's, deliberately not `FrameOver`'s, so that its
Theorem A consumes this structure unchanged. See this module's header for the full rationale.
-/
structure TimeIndexed (D : TemporalOrder) where
  /-- The type of states. -/
  W : Type
  /-- States are inhabited, as for a task frame's world states. -/
  [nonempty : Nonempty W]
  /-- The two-time relation: `R w x y u` permits `w` at `x` to be followed by `u` at `y`. -/
  R : W → ↑D → ↑D → W → Prop

namespace TimeIndexed

variable {D : TemporalOrder}

/--
**The histories of a time-indexed frame**: state assignments to the whole time line that respect
the relation at every ordered pair of times. The analogue of a task frame's total partial
histories (`def:world-history`), stated directly as a set of functions because a time-indexed
frame's relation already speaks of absolute times.
-/
def Hist (G : TimeIndexed D) : Set (↑D → G.W) := {τ | ∀ x y, G.R (τ x) x y (τ y)}

/--
**Limit**, transposed to times. The task frame's *Limit* axiom (`def:frame#Limit`,
"$\bigcap_{x > 0} (w)_x = \{w\}$") says a state is separated from every other state by some
positive radius of durations; here the radius is a neighbourhood of the *time* `t` instead, so
the separation may vary with `t` as well as with the state. That extra freedom is exactly what
the `ℚ` witness in `TimeIndexedSharpness.lean` exploits.
-/
def Limit (G : TimeIndexed D) : Prop :=
  ∀ w u t, (∀ ε : ↑D, 0 < ε → ∃ s, |s - t| < ε ∧ G.R w t s u) → u = w

/--
**Compositionality**, transposed to times: a permitted passage across `[x, z]` factors through
any intermediate time `y`. No theorem in this module or its companion consumes it; it is stated
because the frame-correspondence program's Theorem A does, and because the `ℚ` witness is checked
against it (`qSwitchFrame_compositional`) so that the witness is not dismissible as degenerate.
-/
def Compositional (G : TimeIndexed D) : Prop :=
  ∀ w v x y z, x ≤ y → y ≤ z → (G.R w x z v ↔ ∃ u, G.R w x y u ∧ G.R u y z v)

/-- **Seriality**, transposed to times: every state at every ordered pair of times has both a
successor and a predecessor. -/
def Serial (G : TimeIndexed D) : Prop := ∀ w x y, (∃ u, G.R w x y u) ∧ (∃ v, G.R v x y w)

/-- **The converse convention**: reversing the two times reverses the two states. A time-indexed
frame satisfying this is determined by its restriction to `x ≤ y`. -/
def Converse (G : TimeIndexed D) : Prop := ∀ w x y u, G.R w x y u ↔ G.R u y x w

/--
**A static time-indexed frame**: the relation collapses to state identity at every pair of times,
the time-indexed twin of `TaskFrame.Static`. Strictly stronger than `ConstantHistories` — see
`static_of_lub_of_realized` for the two extra hypotheses that bridge them.
-/
def Static (G : TimeIndexed D) : Prop := ∀ w x y u, G.R w x y u ↔ w = u

/-- **Every history is constant**: no history of the frame ever changes state. This is what the
positive theorem below delivers. -/
def ConstantHistories (G : TimeIndexed D) : Prop := ∀ τ ∈ G.Hist, ∀ x y, τ x = τ y

/--
**Stationarity**: the relation depends on the two times only through their difference, so that
shifting both by a common `d` changes nothing. This is the precise bridge back to the
duration-indexed picture — a stationary time-indexed frame is the same data as a relation on
durations. No theorem here consumes it; it is present because the frame-correspondence program's
Theorem A is stated in terms of it.
-/
def Stationary (G : TimeIndexed D) : Prop := ∀ w u x y d, G.R w x y u ↔ G.R w (x + d) (y + d) u

/--
**The history-realized relation at a pair of times**: the pairs of states that some history
actually takes at `x` and at `y`. Always contained in `{p | G.R p.1 x y p.2}`, and the
frame-correspondence program's Theorem A is the assertion that the containment is an equality
over `ℤ`-time. No theorem here consumes it; it is present for that development.
-/
def P (G : TimeIndexed D) (x y : ↑D) : Set (G.W × G.W) := {p | ∃ τ ∈ G.Hist, p = (τ x, τ y)}

/--
**A uniform separation radius at a time.** *Limit* gives each state `u ≠ w` its own radius around
`t` below which `u` is unreachable from `w`; on a finite carrier the minimum of those finitely
many radii is a single radius that works for every `u` at once.

The time-indexed transcription of `TaskFrame.exists_uniform_radius_of_finite`. Note that the
radius still depends on `t`: nothing here makes it uniform *in time*, and the `ℚ` witness of
`TimeIndexedSharpness.lean` is precisely a frame where it cannot be.

Paper: — (the manuscript states no rigidity theorem; stated at the hypothesis the proof uses)
-/
theorem exists_uniform_radius_of_finite (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit)
    (w : G.W) (t : ↑D) : ∃ ε : ↑D, 0 < ε ∧ ∀ u s, |s - t| < ε → G.R w t s u → u = w := by
  haveI := Fintype.ofFinite G.W
  classical
  obtain ⟨x₀, hx₀⟩ : ∃ x : ↑D, 0 < x := TaskFrame.exists_pos_of_nontrivial
  have hrad : ∀ u : G.W, ∃ ε : ↑D, 0 < ε ∧ ∀ s, |s - t| < ε → G.R w t s u → u = w := by
    intro u
    by_cases huw : u = w
    · exact ⟨x₀, hx₀, fun _ _ _ => huw⟩
    · have hne : ¬ ∀ ε : ↑D, 0 < ε → ∃ s, |s - t| < ε ∧ G.R w t s u :=
        fun hh => huw (hlim w u t hh)
      push Not at hne
      obtain ⟨ε, hε, hnε⟩ := hne
      exact ⟨ε, hε, fun s hs hR => absurd hR (hnε s hs)⟩
  have huniv : (Finset.univ : Finset G.W).Nonempty := ⟨w, Finset.mem_univ w⟩
  let f : G.W → ↑D := fun u => (hrad u).choose
  refine ⟨Finset.univ.inf' huniv f, ?_, ?_⟩
  · rw [Finset.lt_inf'_iff]; exact fun u _ => (hrad u).choose_spec.1
  · intro u s hs hR
    exact (hrad u).choose_spec.2 s (lt_of_lt_of_le hs (Finset.inf'_le f (Finset.mem_univ u))) hR

/--
**Histories are locally constant.** Instantiating the uniform radius at the state a history
already occupies turns separation into constancy on a neighbourhood of the time.

Paper: — (the manuscript states no rigidity theorem; stated at the hypothesis the proof uses)
-/
theorem locally_constant_of_finite (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit)
    {τ : ↑D → G.W} (hτ : τ ∈ G.Hist) (t : ↑D) :
    ∃ ε : ↑D, 0 < ε ∧ ∀ s, |s - t| < ε → τ s = τ t := by
  obtain ⟨ε, hε, h⟩ := G.exists_uniform_radius_of_finite hlim (τ t) t
  exact ⟨ε, hε, fun s hs => h (τ s) s hs (hτ t s)⟩

/--
**The Dedekind rigidity boundary, positive half.** Over a densely ordered, Dedekind-complete time
order, a time-indexed frame with finitely many states satisfying *Limit* has only constant
histories.

The proof is the order-theoretic form of a connectedness argument, run without topology. Fix a
history `τ` and times `a ≤ b`, and let `S` be the times in `[a, b]` at which `τ` still agrees
with its value at `a`. Dedekind completeness supplies a least upper bound `c` of `S`; local
constancy at `c` puts `c` itself into `S` (via `IsLUB.exists_between_sub_self`) and, if `c` were
below `b`, density would produce a point of `S` strictly above `c` — contradicting leastness. So
`c = b`, and `τ b = τ a`.

**Hypotheses the proof does not use**, recorded so that nothing is claimed beyond what is
consumed: *Compositionality*, *Seriality*, *Saturation*, the converse convention, unboundedness
of the time order, and any topology on the carrier. Dedekind completeness is taken as the
Prop-valued `hlub` binder rather than as an order instance, per
`Semantics/DurationClassification.lean`'s stated convention.

Both hypotheses on `D` are sharp, and each is witnessed in `TimeIndexedSharpness.lean`: density
fails over `ℤ`, and Dedekind completeness fails over `ℚ`.

Paper: — (the manuscript states no rigidity theorem; stated at the hypothesis the proof uses)
-/
theorem constantHistories_of_lub [DenselyOrdered ↑D]
    (hlub : ∀ s : Set ↑D, s.Nonempty → BddAbove s → ∃ c, IsLUB s c)
    (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit) : G.ConstantHistories := by
  classical
  have key : ∀ (τ : ↑D → G.W), τ ∈ G.Hist → ∀ a b : ↑D, a ≤ b → τ a = τ b := by
    intro τ hτ a b hab
    set S : Set ↑D := {y | a ≤ y ∧ y ≤ b ∧ τ y = τ a} with hS
    have haS : a ∈ S := ⟨le_refl a, hab, rfl⟩
    obtain ⟨c, hc⟩ := hlub S ⟨a, haS⟩ ⟨b, fun y hy => hy.2.1⟩
    obtain ⟨ε, hε, hloc⟩ := G.locally_constant_of_finite hlim hτ c
    have hac : a ≤ c := hc.1 haS
    have hcb : c ≤ b := hc.2 (fun y hy => hy.2.1)
    obtain ⟨s, hsS, hsc, hsle⟩ := IsLUB.exists_between_sub_self hc hε
    have hτc : τ c = τ a := by
      have hsabs : |s - c| < ε := by
        rw [abs_sub_lt_iff]
        exact ⟨lt_of_le_of_lt (sub_nonpos.mpr hsle) hε, sub_lt_comm.mp hsc⟩
      rw [← hloc s hsabs]; exact hsS.2.2
    rcases eq_or_lt_of_le hcb with h | hlt
    · rw [← h]; exact hτc.symm
    · exfalso
      obtain ⟨y, hy1, hy2⟩ := exists_between (lt_min hlt (lt_add_of_pos_right c hε))
      have hyabs : |y - c| < ε := by
        rw [abs_sub_lt_iff]
        exact ⟨sub_lt_iff_lt_add'.mpr (lt_of_lt_of_le hy2 (min_le_right _ _)),
          lt_of_lt_of_le (sub_neg.mpr hy1) hε.le⟩
      have hyS : y ∈ S := ⟨le_of_lt (lt_of_le_of_lt hac hy1),
        le_of_lt (lt_of_lt_of_le hy2 (min_le_left _ _)), by rw [hloc y hyabs]; exact hτc⟩
      exact absurd (hc.1 hyS) (not_le.mpr hy1)
  intro τ hτ x y
  rcases le_total x y with h | h
  · exact key τ hτ x y h
  · exact (key τ hτ y x h).symm

/--
**From constant histories to a static relation**, at the cost of two further hypotheses.

`constantHistories_of_lub` constrains only those pairs of states that some history realizes, so
it cannot by itself refute a permission `G.R w x y u` that no history witnesses. Two named laws
close the gap and are stated as hypotheses precisely because neither follows from the hypotheses
above:

* `hrefl`, a reflexivity law: every state may stay put across every pair of times. This supplies
  the positive half of `Static`.
* `hreal`, a realization law: every permitted passage is taken by some history. This is the
  substantive one — it is the time-indexed analogue of the extension theorem's
  `cor:occurrence`, and over a task frame it would be proved from *Saturation*; here it is
  assumed rather than derived, because no *Saturation* analogue is stated in this module.

Paper: — (the manuscript states no rigidity theorem; stated at the hypothesis the proof uses)
-/
theorem static_of_lub_of_realized [DenselyOrdered ↑D]
    (hlub : ∀ s : Set ↑D, s.Nonempty → BddAbove s → ∃ c, IsLUB s c)
    (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit)
    (hrefl : ∀ w x y, G.R w x y w)
    (hreal : ∀ w x y u, G.R w x y u → ∃ τ ∈ G.Hist, τ x = w ∧ τ y = u) :
    G.Static := by
  intro w x y u
  refine ⟨fun hR => ?_, fun h => h ▸ hrefl w x y⟩
  obtain ⟨τ, hτ, hx, hy⟩ := hreal w x y u hR
  rw [← hx, ← hy]
  exact constantHistories_of_lub hlub G hlim τ hτ x y

end TimeIndexed
end FormalSystem.Semantics
