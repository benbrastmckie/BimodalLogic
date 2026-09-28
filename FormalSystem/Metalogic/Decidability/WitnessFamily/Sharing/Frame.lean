/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Thread

/-!
# The Branching Frame of a State-Sharing Witness Family

The deterministic device presents its model through `ShiftSet`, whose task relation is the
functional shift relation. That route is closed here by construction: a branching task relation
is not a function, so the frame is built as a literal `FrameOver intOrder`, and
`Semantics/ShiftSet.lean` is neither used nor modified.

## The carrier is a quotient, and only within a single time

World states are `share`-classes of index/time pairs: `(i, u)` and `(j, u)` name the same state
exactly when `share u i j`. Pairs at *different* times are never identified, so time is a
well-defined function on states (`SharingWitnessFamily.time`) and the frame is still a "flow"
whose duration is recoverable from its endpoints.

That per-time restriction is what makes the quotient lift of the task relation go through with
no extra compatibility field on `SharingWitnessFamily`: the four congruences
`reachN_congr_left`, `reachN_congr_right`, `step_congr_left` and `step_congr_right` are all the
compatibility the lift needs, and each is a consequence of `share` being an equivalence.

## One two-sided relation, not two

`FrameOver` takes its primitive on the positive cone and extends it by the reflection
convention. Rather than discharging each constraint against that extension, the construction
defines the two-sided relation `RelZ` once, proves the reflection law for it, and then cites
`TaskFrame.compositional_reflect_of_reflective` and its three siblings — the same route
`ShiftSet.fibre_isRegular` takes.

`RelZ` factors through `SharingWitnessFamily.Conn`, a *duration-free* connectivity predicate on
raw pairs: forward reachability when the source is earlier, backward when it is later. Because
`Conn` mentions no duration, the reflection law is `conn_symm` plus an `omega` on the time
coordinate, rather than a case split on the sign of the duration inside every proof.

## The frame itself lives on `SharingSkeleton`

Not one declaration below inspects a formula, a label or the box guess: the setoid, the carrier,
the connectivity relation, `RelZ`, the frame and all four frame constraints are functions of the
representative structure alone. They are therefore declared on `SharingSkeleton` in
`Sharing/Skeleton.lean`, and this module re-exports them at `SharingWitnessFamily` through
`SharingWitnessFamily.skeleton`, at their original statements.

## Main Definitions

- `SharingWitnessFamily.shareSetoid` — the per-time sharing equivalence on `Fin |lassos| × ℤ`
- `SharingWitnessFamily.WorldState` — its quotient, the frame's carrier
- `SharingWitnessFamily.Conn` — duration-free connectivity between raw positions
- `SharingWitnessFamily.RelZ` — the two-sided task relation on states
- `SharingWitnessFamily.frame` — the branching `FrameOver intOrder`

## Main Results

- `SharingWitnessFamily.relZ_reflection` — the reflection law
- `SharingWitnessFamily.relZ_comp` — *Compositionality*, from `reachN_add`
- `SharingWitnessFamily.relZ_serial` — *Seriality*, from `reachN_const`
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

namespace SharingWitnessFamily

variable {Γ Del : Context}

/--
**The per-time sharing equivalence** on index/time pairs: `(i, u)` and `(j, v)` name the same
world state exactly when `u = v` and `share u i j`.

Pairs at different times are never identified, which is what keeps `time` well defined on the
quotient and the frame a flow.
-/
abbrev shareSetoid (S : SharingWitnessFamily Γ Del) : Setoid (Fin S.lassos.length × ℤ) :=
  S.skeleton.shareSetoid

/-- The frame's carrier: `share`-classes of index/time pairs. -/
abbrev WorldState (S : SharingWitnessFamily Γ Del) : Type := S.skeleton.WorldState

/-- The class of an index at a time. -/
abbrev cls (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) (u : ℤ) : S.WorldState :=
  S.skeleton.cls i u

theorem cls_eq {S : SharingWitnessFamily Γ Del} {i j : Fin S.lassos.length} {u v : ℤ}
    (hu : u = v) (hs : S.share u i j) : S.cls i u = S.cls j v :=
  SharingSkeleton.cls_eq hu hs

theorem share_of_cls_eq {S : SharingWitnessFamily Γ Del} {i j : Fin S.lassos.length} {u v : ℤ}
    (h : S.cls i u = S.cls j v) : u = v ∧ S.share u i j :=
  SharingSkeleton.share_of_cls_eq h

/-- Time is well defined on states, because the setoid never crosses a time. -/
abbrev time (S : SharingWitnessFamily Γ Del) (C : S.WorldState) : ℤ := S.skeleton.time C

@[simp]
theorem time_cls (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) (u : ℤ) :
    S.time (S.cls i u) = u := rfl

/--
**Duration-free connectivity between raw positions.** Forward reachability when the source is
no later than the target, backward reachability otherwise. Symmetric by `conn_symm`, which is
what makes the reflection law cheap.
-/
def Conn (S : SharingWitnessFamily Γ Del) (p q : Fin S.lassos.length × ℤ) : Prop :=
  if p.2 ≤ q.2 then S.ReachN (q.2 - p.2).toNat p.2 p.1 q.1
  else S.ReachN (p.2 - q.2).toNat q.2 q.1 p.1

/--
The family's connectivity is its skeleton's, by definition.

Stated here rather than taken as the *definition* of `SharingWitnessFamily.Conn`, because
`Sharing/Specialize.lean` reaches through the name with `unfold SharingWitnessFamily.Conn` and
then `split`s on the resulting `if`; a delegating `abbrev` would unfold one step, to
`S.skeleton.Conn`, and leave nothing to split. The two are the same proposition, and every
lemma below is proved once, on the skeleton.
-/
theorem conn_eq_skeleton (S : SharingWitnessFamily Γ Del)
    (p q : Fin S.lassos.length × ℤ) : S.Conn p q ↔ S.skeleton.Conn p q := Iff.rfl

theorem conn_of_reachN {S : SharingWitnessFamily Γ Del} {n : ℕ} {u : ℤ}
    {i j : Fin S.lassos.length} (h : S.ReachN n u i j) : S.Conn (i, u) (j, u + (n : ℤ)) :=
  SharingSkeleton.conn_of_reachN (K := S.skeleton) h

theorem conn_symm {S : SharingWitnessFamily Γ Del} {p q : Fin S.lassos.length × ℤ}
    (h : S.Conn p q) : S.Conn q p := SharingSkeleton.conn_symm (K := S.skeleton) h

theorem conn_congr_left {S : SharingWitnessFamily Γ Del} {p p' q : Fin S.lassos.length × ℤ}
    (hp : p.2 = p'.2) (hs : S.share p.2 p.1 p'.1) (h : S.Conn p q) : S.Conn p' q :=
  SharingSkeleton.conn_congr_left (K := S.skeleton) hp hs h

theorem conn_congr_right {S : SharingWitnessFamily Γ Del} {p q q' : Fin S.lassos.length × ℤ}
    (hq : q.2 = q'.2) (hs : S.share q.2 q.1 q'.1) (h : S.Conn p q) : S.Conn p q' :=
  SharingSkeleton.conn_congr_right (K := S.skeleton) hq hs h

/--
**The two-sided task relation on states.** A duration `d` takes `C` to `C'` when the times
differ by `d` and the two raw positions are connected.
-/
abbrev RelZ (S : SharingWitnessFamily Γ Del) (C : S.WorldState) (d : ℤ) (C' : S.WorldState) :
    Prop := S.skeleton.RelZ C d C'

@[simp]
theorem relZ_cls (S : SharingWitnessFamily Γ Del) (i j : Fin S.lassos.length) (u v d : ℤ) :
    S.RelZ (S.cls i u) d (S.cls j v) ↔ (v = u + d ∧ S.Conn (i, u) (j, v)) := Iff.rfl

/-- **The reflection law.** Reversing a duration reverses the relation; `Conn` is duration-free
and symmetric, so only the time coordinate has to move. -/
theorem relZ_reflection (S : SharingWitnessFamily Γ Del) :
    ∀ (C : S.WorldState) (d : ℤ) (C' : S.WorldState), S.RelZ C d C' ↔ S.RelZ C' (-d) C :=
  S.skeleton.relZ_reflection

/-- Every state is the class of some index at its own time. -/
theorem exists_cls (S : SharingWitnessFamily Γ Del) (C : S.WorldState) :
    ∃ i : Fin S.lassos.length, C = S.cls i (S.time C) := S.skeleton.exists_cls C

/-- **Compositionality** for the branching relation, from `reachN_add`. -/
theorem relZ_comp (S : SharingWitnessFamily Γ Del) : TaskFrame.Compositional S.RelZ :=
  S.skeleton.relZ_comp

/-- **Seriality** for the branching relation: staying on one lasso is always available in both
directions. -/
theorem relZ_serial (S : SharingWitnessFamily Γ Del) : TaskFrame.Serial S.RelZ :=
  S.skeleton.relZ_serial

/--
**The branching frame.** Built as a literal `FrameOver intOrder`; nothing here routes through
`ShiftSet`, whose task relation is functional by construction.
-/
abbrev frame (S : SharingWitnessFamily Γ Del) : FrameOver intOrder := S.skeleton.frame

/-- **The frame's task relation is the two-sided relation.** The frame's primitive is `RelZ`
restricted to the positive cone, and `RelZ` satisfies the reflection law, so the reflection
convention recovers it on the nose. -/
@[simp]
theorem frame_taskRel (S : SharingWitnessFamily Γ Del) (C : S.WorldState) (d : ℤ)
    (C' : S.WorldState) : S.frame.TaskRel C d C' ↔ S.RelZ C d C' :=
  S.skeleton.frame_taskRel C d C'

/-- *Compositionality* at the frame's own task relation. -/
theorem frame_comp (S : SharingWitnessFamily Γ Del) :
    TaskFrame.Compositional S.frame.TaskRel := S.skeleton.frame_comp

/-- *Seriality* at the frame's own task relation. -/
theorem frame_serial (S : SharingWitnessFamily Γ Del) :
    TaskFrame.Serial S.frame.TaskRel := S.skeleton.frame_serial

/-! ### The four `def:frame` constraints, and the ℤ-time instances

Limit and Saturation need **no new frame-axiom argument**: the first is
`TaskFrame.limit_of_succOrder` at the zero-duration law, which asks only that a zero-duration
transition is the identity — never that the relation is functional; the second is
`TaskFrame.saturation_of_fib_finite`, whose docstring names exactly this case, an infinite
carrier with finite fibres. Determinism is nowhere used.
-/

/-- **The zero-duration law.** A zero-duration transition is the identity of states — the whole
hypothesis `TaskFrame.limit_of_succOrder` needs. -/
theorem relZ_zero (S : SharingWitnessFamily Γ Del) :
    ∀ C C' : S.WorldState, S.RelZ C 0 C' → C' = C := S.skeleton.relZ_zero

/-- The time coordinate advances by the duration. -/
theorem time_of_relZ (S : SharingWitnessFamily Γ Del) (d : ℤ) :
    ∀ C C' : S.WorldState, S.RelZ C d C' → S.time C' = S.time C + d := S.skeleton.time_of_relZ d

/-- **Limit**, by `TaskFrame.limit_of_succOrder`: over the discrete integer duration the only
arbitrarily-small transition is the zero one. -/
theorem relZ_limit (S : SharingWitnessFamily Γ Del) :
    ∀ C C' : S.WorldState, (∀ x : ℤ, 0 < x → ∃ y, |y| < x ∧ S.RelZ C y C') → C' = C :=
  S.skeleton.relZ_limit

/-- **Fibres are finite.** At a fixed source and duration, every target lies at one fixed time,
where there are at most `|lassos|` classes. The carrier itself is infinite, which is exactly the
case `TaskFrame.saturation_of_fib_finite` is for. -/
theorem relZ_fib_finite (S : SharingWitnessFamily Γ Del) (C : S.WorldState) (d : ℤ) :
    (TaskFrame.Fib S.RelZ C d).Finite := S.skeleton.relZ_fib_finite C d

/-- **Saturation**, by `TaskFrame.saturation_of_fib_finite`. -/
theorem relZ_saturation (S : SharingWitnessFamily Γ Del) : TaskFrame.Saturation S.RelZ :=
  S.skeleton.relZ_saturation

/-- *Limit* at the frame's own task relation. -/
theorem frame_limit (S : SharingWitnessFamily Γ Del) : TaskFrame.Limit S.frame.TaskRel :=
  S.skeleton.frame_limit

/-- *Saturation* at the frame's own task relation. -/
theorem frame_saturation (S : SharingWitnessFamily Γ Del) :
    TaskFrame.Saturation S.frame.TaskRel := S.skeleton.frame_saturation

/-- **The branching frame is regular.** All four constraints, none of them using determinism. -/
instance instIsRegular (S : SharingWitnessFamily Γ Del) : S.frame.IsRegular :=
  S.skeleton.instIsRegular

/-- Regularity at the total space as well as at the fibre: instance synthesis does not project
through `FrameOver.toTaskFrame` on its own. -/
instance instIsRegularTask (S : SharingWitnessFamily Γ Del) :
    S.frame.toTaskFrame.IsRegular := S.skeleton.instIsRegularTask

/-- **The branching frame is a ℤ-time frame.** -/
theorem frame_isZTime (S : SharingWitnessFamily Γ Del) : S.frame.toTaskFrame.IsZTime :=
  S.skeleton.frame_isZTime

/-- The branching frame satisfies the ℤ-time frame class. -/
theorem frame_sat_ztime (S : SharingWitnessFamily Γ Del) :
    FormalSystem.ProofSystem.FrameClass.ZTime.Sat S.frame.toTaskFrame := S.skeleton.frame_sat_ztime

/-- The branching frame satisfies the unconstrained frame class, by antitonicity. -/
theorem frame_sat_base (S : SharingWitnessFamily Γ Del) :
    FormalSystem.ProofSystem.FrameClass.Base.Sat S.frame.toTaskFrame := S.skeleton.frame_sat_base

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
