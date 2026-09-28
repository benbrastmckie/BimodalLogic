/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Basic

/-!
# Threads: The Branching Analogue of a Lasso Orbit

On the deterministic device a world history *is* a lasso, shifted. Once two lassos may name the
same state at a time, a history can cross from one to the other there, and the object that
replaces "a lasso" is a **thread**: a bi-infinite choice of lasso index that only ever changes
across a shared state.

## Three relations, and why all three are needed

* `SharingWitnessFamily.Thread` — the bi-infinite object. Its step field is the *tight* one,
  `share (u+1) (idx u) (idx (u+1))`: the thread stays on lasso `idx u` from `u` to `u + 1` and
  then re-names the state it lands in. This is not a loss of generality, because a history's
  index at `u` may be chosen *knowing* the step it is about to take — see `Histories.lean`.
* `SharingWitnessFamily.Step` — the *class-level* one-step relation,
  `∃ i', share u i i' ∧ share (u+1) i' j`. This is the relation the frame's task relation is
  built from, and the existential is exactly the branching: the state `⟦(i,u)⟧` has one successor
  for each lasso passing through it, not one successor full stop.
* `SharingWitnessFamily.ReachN` — `n` iterated `Step`s, with `ReachN 0` the sharing relation
  itself. This is the finite-duration reachability the frame's `PosRel` quantifies over.

`Step` is invariant under `share u` on the left and `share (u+1)` on the right, and `ReachN n`
under `share u` and `share (u + n)`; those four congruences are what let the whole development
descend to the quotient carrier in `Frame.lean`, with no compatibility field added to the
structure.

## What is deliberately absent: a thread time-shift

A thread cannot be time-shifted. `share` is decoded from three *periodic segments* indexed by
absolute time, so `share u` and `share (u + d)` are different relations for a general `d`, and
`fun u => θ.idx (u + d)` fails the step field. Time offsets therefore live in the *history's*
parametrization — `total_eq_thread` carries an explicit `s : ℤ` and reads `θ.idx (s + t)` at
time `s + t` — never in the thread.

## The layer itself lives on `SharingSkeleton`

Not one declaration below inspects a formula, a label or the box guess: threads and the two
reachability relations are functions of the representative structure alone. They are therefore
declared on `SharingSkeleton` in `Sharing/Skeleton.lean`, and this module re-exports them at
`SharingWitnessFamily` through `SharingWitnessFamily.skeleton`, at their original statements.

## Main Definitions

- `SharingWitnessFamily.Thread` — a bi-infinite index choice stepping only across shared states
- `SharingWitnessFamily.Step` — the class-level one-step relation
- `SharingWitnessFamily.ReachN` — `n`-step reachability

## Main Results

- `SharingWitnessFamily.Thread.const` — every constant index choice is a thread
- `SharingWitnessFamily.reachN_add` — concatenation and splitting of reachability
- `SharingWitnessFamily.Thread.reachN` — a thread realizes reachability between its own positions
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

namespace SharingWitnessFamily

variable {Γ Del : Context}

/--
**A bi-infinite choice of lasso index, stepping only across shared states.**

The family's threads are its skeleton's threads: the step field mentions only `share`, so there
is nothing here for the label row to contribute.
-/
abbrev Thread (S : SharingWitnessFamily Γ Del) : Type := S.skeleton.Thread

/-- The constant thread at index `i`: staying on one lasso forever is always legitimate. -/
abbrev Thread.const (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) : S.Thread :=
  SharingSkeleton.Thread.const S.skeleton i

instance instNonemptyThread (S : SharingWitnessFamily Γ Del) : Nonempty S.Thread :=
  ⟨Thread.const S S.mainIdx⟩

/--
**A thread's step, phrased at the family's own `share`.**

Declared at `SharingWitnessFamily.Thread` so that dot notation on a family thread resolves here
rather than to the skeleton's field, which is stated at `S.skeleton.share`. The two are the same
proposition by definition; this restatement is what keeps every downstream `rw [S.share_def]`
matching, and is why `Sharing/Fulfil.lean` needs no edit.
-/
theorem Thread.step {S : SharingWitnessFamily Γ Del} (θ : S.Thread) (u : ℤ) :
    S.share (u + 1) (θ.idx u) (θ.idx (u + 1)) := SharingSkeleton.Thread.step θ u

/-- Threads are determined by their index function. -/
theorem Thread.ext {S : SharingWitnessFamily Γ Del} {θ η : S.Thread}
    (h : ∀ u, θ.idx u = η.idx u) : θ = η := SharingSkeleton.Thread.ext h

@[simp]
theorem Thread.const_idx (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) (u : ℤ) :
    (Thread.const S i).idx u = i := rfl

/--
**The class-level one-step relation.**

From index `i` at time `u`, a history may continue along *any* lasso `i'` naming the same state
at `u`, and then re-name the state it lands in at `u + 1`. The existential over `i'` is the
branching: on the deterministic device it collapses to `i' = i` and `Step u i j ↔ j = i`.
-/
abbrev Step (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) : Prop :=
  S.skeleton.Step u i j

theorem step_of_share_succ {S : SharingWitnessFamily Γ Del} {u : ℤ}
    {i j : Fin S.lassos.length} (h : S.share (u + 1) i j) : S.Step u i j :=
  SharingSkeleton.step_of_share_succ h

theorem step_refl (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.Step u i i := SharingSkeleton.step_refl S.skeleton u i

/-- `Step` only sees the `share u`-class of its source. -/
theorem step_congr_left {S : SharingWitnessFamily Γ Del} {u : ℤ} {i i' j : Fin S.lassos.length}
    (h : S.share u i' i) (hs : S.Step u i j) : S.Step u i' j :=
  SharingSkeleton.step_congr_left h hs

/-- `Step` only sees the `share (u+1)`-class of its target. -/
theorem step_congr_right {S : SharingWitnessFamily Γ Del} {u : ℤ} {i j j' : Fin S.lassos.length}
    (hs : S.Step u i j) (h : S.share (u + 1) j j') : S.Step u i j' :=
  SharingSkeleton.step_congr_right hs h

/--
**`n`-step reachability.** At `n = 0` it is the sharing relation — same time, same state — and
each successor step is one `Step`.
-/
abbrev ReachN (S : SharingWitnessFamily Γ Del) (n : ℕ) (u : ℤ)
    (i j : Fin S.lassos.length) : Prop :=
  S.skeleton.ReachN n u i j

theorem reachN_zero (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.ReachN 0 u i j ↔ S.share u i j := Iff.rfl

theorem reachN_succ (S : SharingWitnessFamily Γ Del) (n : ℕ) (u : ℤ)
    (i j : Fin S.lassos.length) :
    S.ReachN (n + 1) u i j ↔ ∃ k, S.Step u i k ∧ S.ReachN n (u + 1) k j := Iff.rfl

/-- Reachability only sees the `share u`-class of its source. -/
theorem reachN_congr_left {S : SharingWitnessFamily Γ Del} {n : ℕ} {u : ℤ}
    {i i' j : Fin S.lassos.length} (h : S.share u i' i) (hr : S.ReachN n u i j) :
    S.ReachN n u i' j := SharingSkeleton.reachN_congr_left h hr

/-- Reachability only sees the `share (u + n)`-class of its target. -/
theorem reachN_congr_right {S : SharingWitnessFamily Γ Del} {n : ℕ} {u : ℤ}
    {i j j' : Fin S.lassos.length} (hr : S.ReachN n u i j)
    (h : S.share (u + (n : ℤ)) j j') : S.ReachN n u i j' :=
  SharingSkeleton.reachN_congr_right hr h

/-- Staying on one lasso is reachability of every length. -/
theorem reachN_const (S : SharingWitnessFamily Γ Del) (n : ℕ) (u : ℤ)
    (i : Fin S.lassos.length) : S.ReachN n u i i :=
  SharingSkeleton.reachN_const S.skeleton n u i

/-- One step of reachability is one `Step`. -/
theorem reachN_one (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.ReachN 1 u i j ↔ S.Step u i j := SharingSkeleton.reachN_one S.skeleton u i j

/--
**Concatenation and splitting.** Reachability of length `m + n` factors through an intermediate
state at time `u + m`, in both directions. This is the whole content of the *Compositionality*
discharge for the branching frame.
-/
theorem reachN_add (S : SharingWitnessFamily Γ Del) (m n : ℕ) (u : ℤ)
    (i j : Fin S.lassos.length) :
    S.ReachN (m + n) u i j ↔ ∃ k, S.ReachN m u i k ∧ S.ReachN n (u + (m : ℤ)) k j :=
  SharingSkeleton.reachN_add S.skeleton m n u i j

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
