/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Frame

/-!
# The Histories Characterization for the Branching Frame

`ShiftSet.total_eq_orbit` says that every world history of the deterministic device's frame is
a lasso orbit. It is true **because the task relation is functional**: `respects_task 0` alone
pins every state. Once two lassos may share a state a history can cross between them, that
argument fails, and with it the box case of the truth lemma, which is calibrated against "every
position of every lasso".

This module supplies the replacement: every world history of `SharingWitnessFamily.frame` is the
trace of a **thread**, and conversely every thread traces a world history.

## Why the tight `Thread.step` suffices

`Thread`'s step field is `share (u+1) (idx u) (idx (u+1))`, which is *narrower* than the frame's
one-step relation `Step u i j = ∃ i', share u i i' ∧ share (u+1) i' j`. That costs nothing here,
because a history's index at `u` may be chosen **knowing the step it is about to take**: the
witness `i'` supplied by `Step` at `u` is itself a legitimate name for the state at `u`, and is
exactly the index the thread records. The construction reads the representatives off the steps,
not off the states.

There is therefore no two-directional recursion and no gluing: the choice at each time is
independent, and the step law follows from transitivity of `share` at `u + 1`.

## The deterministic case degenerates to `total_eq_orbit`'s content

Under `share u i j := (i = j)` a thread's step field forces `idx (u+1) = idx u`, so `idx` is
constant and `Thread ≃ Fin |lassos|`. The statement below then says that every history is the
trace of a single lasso from some offset — which is `ShiftSet.total_eq_orbit`'s content, read
through the frame isomorphism of `Specialize.lean`. That is the durable anchor for the
specialization.

## The layer itself lives on `SharingSkeleton`

Not one declaration below inspects a formula, a label or the box guess. Threads, their traces
and the characterization are functions of the representative structure alone, so they are
declared on `SharingSkeleton` in `Sharing/Skeleton.lean`; this module re-exports them at
`SharingWitnessFamily` through `SharingWitnessFamily.skeleton`, at their original statements.

## Main Definitions

- `SharingWitnessFamily.hist` — the world history traced by a thread from a time offset

## Main Results

- `SharingWitnessFamily.conn_thread` — any two positions of a thread are connected
- `SharingWitnessFamily.thread_is_history` — a thread's trace is a world history
- `SharingWitnessFamily.total_eq_thread` — **every world history is a thread's trace**
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

namespace SharingWitnessFamily

variable {Γ Del : Context}

/-- **Any two positions of a thread are connected**, in either time order. -/
theorem conn_thread (S : SharingWitnessFamily Γ Del) (θ : S.Thread) (u v : ℤ) :
    S.Conn (θ.idx u, u) (θ.idx v, v) := SharingSkeleton.conn_thread S.skeleton θ u v

/--
**The world history traced by a thread from a time offset.**

The offset is carried here rather than inside the thread: `share` is decoded from periodic
segments indexed by absolute time, so a thread cannot be time-shifted (see `Thread.lean`).
-/
abbrev hist (S : SharingWitnessFamily Γ Del) (θ : S.Thread) (s : ℤ) :
    WorldHistory S.frame.toTaskFrame := S.skeleton.hist θ s

@[simp]
theorem hist_state (S : SharingWitnessFamily Γ Del) (θ : S.Thread) (s t : ℤ) :
    (S.hist θ s).state t = S.cls (θ.idx (s + t)) (s + t) := rfl

/-- **A thread's trace is a world history.** This is what the `box` case of the truth lemma
consumes in the other direction from `total_eq_thread`. -/
theorem thread_is_history (S : SharingWitnessFamily Γ Del) (θ : S.Thread) (s : ℤ) :
    ∃ σ : WorldHistory S.frame.toTaskFrame,
      ∀ t : ℤ, σ.state t = S.cls (θ.idx (s + t)) (s + t) :=
  SharingSkeleton.thread_is_history S.skeleton θ s

/--
**The histories characterization.**

Every world history of the branching frame is the trace of a thread, from some time offset.
This replaces `ShiftSet.total_eq_orbit`, which holds only because the deterministic device's
task relation is functional.
-/
theorem total_eq_thread (S : SharingWitnessFamily Γ Del)
    (σ : WorldHistory S.frame.toTaskFrame) :
    ∃ θ : S.Thread, ∃ s : ℤ, ∀ t : ℤ, σ.state t = S.cls (θ.idx (s + t)) (s + t) :=
  SharingSkeleton.total_eq_thread S.skeleton σ

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
