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
exactly the index the thread records. The construction below does precisely that — it reads the
representatives off the steps, not off the states.

There is therefore no two-directional recursion and no gluing: the choice at each time is
independent, and the step law follows from transitivity of `share` at `u + 1`.

## The deterministic case degenerates to `total_eq_orbit`'s content

Under `share u i j := (i = j)` a thread's step field forces `idx (u+1) = idx u`, so `idx` is
constant and `Thread ≃ Fin |lassos|`. The statement below then says that every history is the
trace of a single lasso from some offset — which is `ShiftSet.total_eq_orbit`'s content, read
through the frame isomorphism of `Specialize.lean`. That is the durable anchor for the
specialization.

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
    S.Conn (θ.idx u, u) (θ.idx v, v) := by
  rcases le_total u v with h | h
  · have hc := conn_of_reachN (θ.reachN (v - u).toNat u)
    rwa [show u + (((v - u).toNat : ℕ) : ℤ) = v from by omega] at hc
  · have hc := conn_of_reachN (θ.reachN (u - v).toNat v)
    rw [show v + (((u - v).toNat : ℕ) : ℤ) = u from by omega] at hc
    exact conn_symm hc

/--
**The world history traced by a thread from a time offset.**

The offset is carried here rather than inside the thread: `share` is decoded from periodic
segments indexed by absolute time, so a thread cannot be time-shifted (see `Thread.lean`).
-/
def hist (S : SharingWitnessFamily Γ Del) (θ : S.Thread) (s : ℤ) :
    WorldHistory S.frame.toTaskFrame :=
  WorldHistory.ofTotal S.frame.toTaskFrame (fun t => S.cls (θ.idx (s + t)) (s + t)) <| by
    intro a b
    refine (S.frame_taskRel _ _ _).mpr ?_
    exact (S.relZ_cls _ _ _ _ _).mpr ⟨by omega, conn_thread S θ (s + a) (s + b)⟩

@[simp]
theorem hist_state (S : SharingWitnessFamily Γ Del) (θ : S.Thread) (s t : ℤ) :
    (S.hist θ s).state t = S.cls (θ.idx (s + t)) (s + t) := rfl

/-- **A thread's trace is a world history.** This is what the `box` case of the truth lemma
consumes in the other direction from `total_eq_thread`. -/
theorem thread_is_history (S : SharingWitnessFamily Γ Del) (θ : S.Thread) (s : ℤ) :
    ∃ σ : WorldHistory S.frame.toTaskFrame,
      ∀ t : ℤ, σ.state t = S.cls (θ.idx (s + t)) (s + t) :=
  ⟨S.hist θ s, fun _ => rfl⟩

/--
**The histories characterization.**

Every world history of the branching frame is the trace of a thread, from some time offset.
This replaces `ShiftSet.total_eq_orbit`, which holds only because the deterministic device's
task relation is functional.
-/
theorem total_eq_thread (S : SharingWitnessFamily Γ Del)
    (σ : WorldHistory S.frame.toTaskFrame) :
    ∃ θ : S.Thread, ∃ s : ℤ, ∀ t : ℤ, σ.state t = S.cls (θ.idx (s + t)) (s + t) := by
  classical
  set s := S.time (σ.state 0) with hs
  have htime : ∀ t : ℤ, S.time (σ.state t) = s + t := by
    intro t
    have h := (S.frame_taskRel _ _ _).mp (σ.respects_task 0 t)
    have h2 := S.time_of_relZ (t - 0) _ _ h
    omega
  have hrep : ∀ t : ℤ, ∃ i : Fin S.lassos.length, σ.state t = S.cls i (s + t) := by
    intro t
    obtain ⟨i, hi⟩ := S.exists_cls (σ.state t)
    exact ⟨i, by rw [hi, htime t]⟩
  choose a ha using hrep
  have hstep : ∀ t : ℤ, S.Step (s + t) (a t) (a (t + 1)) := by
    intro t
    have h := (S.frame_taskRel _ _ _).mp (σ.respects_task t (t + 1))
    rw [ha t, ha (t + 1)] at h
    obtain ⟨_, hc⟩ := (S.relZ_cls _ _ _ _ _).mp h
    unfold Conn at hc
    rw [if_pos (by omega : (a t, s + t).2 ≤ (a (t + 1), s + (t + 1)).2)] at hc
    rw [show ((a (t + 1), s + (t + 1)).2 - (a t, s + t).2).toNat = 1 from by omega] at hc
    exact (S.reachN_one _ _ _).mp hc
  choose b hb₁ hb₂ using hstep
  refine ⟨⟨fun v => b (v - s), ?_⟩, s, ?_⟩
  · intro v
    have h₁ := hb₂ (v - s)
    have h₂ := hb₁ (v - s + 1)
    rw [show s + (v - s) + 1 = v + 1 from by omega] at h₁
    rw [show s + (v - s + 1) = v + 1 from by omega] at h₂
    have h₃ := S.share_trans h₁ h₂
    rwa [show v - s + 1 = v + 1 - s from by omega] at h₃
  · intro t
    change σ.state t = S.cls (b (s + t - s)) (s + t)
    rw [show s + t - s = t from by omega, ha t]
    exact cls_eq rfl (hb₁ t)

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
