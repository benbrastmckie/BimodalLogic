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

/-- Regrouping a successor time offset, used wherever an induction on the step count meets the
integer time coordinate. -/
private theorem int_succ_shift (u : ℤ) (m : ℕ) :
    u + ((m + 1 : ℕ) : ℤ) = u + 1 + (m : ℤ) := by
  omega

/-- Erasing a zero step count from a time offset. -/
private theorem int_zero_shift (u : ℤ) : u + ((0 : ℕ) : ℤ) = u := by
  omega

/--
**A bi-infinite choice of lasso index, stepping only across shared states.**

The step field is the tight form: the thread rides lasso `idx u` from `u` to `u + 1`, and the
state it arrives at, `⟦(idx u, u+1)⟧`, is the state `⟦(idx (u+1), u+1)⟧` it is recorded as
holding. Threads replace lasso orbits as the objects the frame's histories are traces of.
-/
structure Thread (S : SharingWitnessFamily Γ Del) where
  /-- The index held at each time. -/
  idx : ℤ → Fin S.lassos.length
  /-- Consecutive indices name the same world state at the later time. -/
  step : ∀ u : ℤ, S.share (u + 1) (idx u) (idx (u + 1))

namespace Thread

variable {S : SharingWitnessFamily Γ Del}

/-- Threads are determined by their index function. -/
@[ext]
theorem ext {θ η : S.Thread} (h : ∀ u, θ.idx u = η.idx u) : θ = η := by
  cases θ with
  | mk i₁ s₁ =>
    cases η with
    | mk i₂ s₂ =>
      have hi : i₁ = i₂ := funext h
      subst hi
      rfl

end Thread

/-- The constant thread at index `i`: staying on one lasso forever is always legitimate. -/
def Thread.const (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) : S.Thread where
  idx := fun _ => i
  step := fun u => S.share_refl (u + 1) i

instance instNonemptyThread (S : SharingWitnessFamily Γ Del) : Nonempty S.Thread :=
  ⟨Thread.const S S.mainIdx⟩

@[simp]
theorem Thread.const_idx (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) (u : ℤ) :
    (Thread.const S i).idx u = i := rfl

/--
**The class-level one-step relation.**

From index `i` at time `u`, a history may continue along *any* lasso `i'` naming the same state
at `u`, and then re-name the state it lands in at `u + 1`. The existential over `i'` is the
branching: on the deterministic device it collapses to `i' = i` and `Step u i j ↔ j = i`.
-/
def Step (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) : Prop :=
  ∃ i', S.share u i i' ∧ S.share (u + 1) i' j

theorem step_of_share_succ {S : SharingWitnessFamily Γ Del} {u : ℤ}
    {i j : Fin S.lassos.length} (h : S.share (u + 1) i j) : S.Step u i j :=
  ⟨i, S.share_refl u i, h⟩

theorem step_refl (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.Step u i i :=
  step_of_share_succ (S.share_refl (u + 1) i)

/-- `Step` only sees the `share u`-class of its source. -/
theorem step_congr_left {S : SharingWitnessFamily Γ Del} {u : ℤ} {i i' j : Fin S.lassos.length}
    (h : S.share u i' i) (hs : S.Step u i j) : S.Step u i' j := by
  obtain ⟨k, hk, hkj⟩ := hs
  exact ⟨k, S.share_trans h hk, hkj⟩

/-- `Step` only sees the `share (u+1)`-class of its target. -/
theorem step_congr_right {S : SharingWitnessFamily Γ Del} {u : ℤ} {i j j' : Fin S.lassos.length}
    (hs : S.Step u i j) (h : S.share (u + 1) j j') : S.Step u i j' := by
  obtain ⟨k, hk, hkj⟩ := hs
  exact ⟨k, hk, S.share_trans hkj h⟩

instance decidableStep (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    Decidable (S.Step u i j) :=
  inferInstanceAs (Decidable (∃ i', S.share u i i' ∧ S.share (u + 1) i' j))

/--
**`n`-step reachability.** At `n = 0` it is the sharing relation — same time, same state — and
each successor step is one `Step`.
-/
def ReachN (S : SharingWitnessFamily Γ Del) :
    ℕ → ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop
  | 0, u, i, j => S.share u i j
  | (n + 1), u, i, j => ∃ k, S.Step u i k ∧ ReachN S n (u + 1) k j

@[simp]
theorem reachN_zero (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.ReachN 0 u i j ↔ S.share u i j := Iff.rfl

theorem reachN_succ (S : SharingWitnessFamily Γ Del) (n : ℕ) (u : ℤ)
    (i j : Fin S.lassos.length) :
    S.ReachN (n + 1) u i j ↔ ∃ k, S.Step u i k ∧ S.ReachN n (u + 1) k j := Iff.rfl

/-- Reachability only sees the `share u`-class of its source. -/
theorem reachN_congr_left {S : SharingWitnessFamily Γ Del} {n : ℕ} {u : ℤ}
    {i i' j : Fin S.lassos.length} (h : S.share u i' i) (hr : S.ReachN n u i j) :
    S.ReachN n u i' j := by
  cases n with
  | zero => exact S.share_trans h hr
  | succ m =>
    obtain ⟨k, hk, hrest⟩ := hr
    exact ⟨k, step_congr_left h hk, hrest⟩

/-- Reachability only sees the `share (u + n)`-class of its target. -/
theorem reachN_congr_right {S : SharingWitnessFamily Γ Del} {n : ℕ} {u : ℤ}
    {i j j' : Fin S.lassos.length} (hr : S.ReachN n u i j)
    (h : S.share (u + (n : ℤ)) j j') : S.ReachN n u i j' := by
  induction n generalizing u i with
  | zero =>
    rw [int_zero_shift] at h
    exact S.share_trans hr h
  | succ m ih =>
    obtain ⟨k, hk, hrest⟩ := hr
    refine ⟨k, hk, ih hrest ?_⟩
    rw [← int_succ_shift]
    exact h

/-- Staying on one lasso is reachability of every length. -/
theorem reachN_const (S : SharingWitnessFamily Γ Del) (n : ℕ) (u : ℤ)
    (i : Fin S.lassos.length) : S.ReachN n u i i := by
  induction n generalizing u with
  | zero => exact S.share_refl u i
  | succ m ih => exact ⟨i, step_refl S u i, ih (u + 1)⟩

/-- One step of reachability is one `Step`. -/
theorem reachN_one (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.ReachN 1 u i j ↔ S.Step u i j := by
  constructor
  · rintro ⟨k, hk, hr⟩
    exact step_congr_right hk hr
  · intro h
    exact ⟨j, h, S.share_refl (u + 1) j⟩

/--
**Concatenation and splitting.** Reachability of length `m + n` factors through an intermediate
state at time `u + m`, in both directions. This is the whole content of the *Compositionality*
discharge for the branching frame.
-/
theorem reachN_add (S : SharingWitnessFamily Γ Del) (m n : ℕ) (u : ℤ)
    (i j : Fin S.lassos.length) :
    S.ReachN (m + n) u i j ↔ ∃ k, S.ReachN m u i k ∧ S.ReachN n (u + (m : ℤ)) k j := by
  induction m generalizing u i with
  | zero =>
    rw [Nat.zero_add]
    constructor
    · intro h
      refine ⟨i, S.share_refl u i, ?_⟩
      rw [int_zero_shift]
      exact h
    · rintro ⟨k, hik, hr⟩
      rw [int_zero_shift] at hr
      exact reachN_congr_left hik hr
  | succ m ih =>
    have hidx : m + 1 + n = (m + n) + 1 := by omega
    rw [hidx, reachN_succ]
    constructor
    · rintro ⟨k, hk, hr⟩
      obtain ⟨k', hk', hr'⟩ := (ih (u + 1) k).mp hr
      refine ⟨k', ?_, ?_⟩
      · exact ⟨k, hk, hk'⟩
      · rw [int_succ_shift]
        exact hr'
    · rintro ⟨k', hseg, hr'⟩
      rw [reachN_succ] at hseg
      obtain ⟨k, hk, hk'⟩ := hseg
      refine ⟨k, hk, (ih (u + 1) k).mpr ⟨k', hk', ?_⟩⟩
      rw [← int_succ_shift]
      exact hr'

instance decidableReachN (S : SharingWitnessFamily Γ Del) :
    ∀ (n : ℕ) (u : ℤ) (i j : Fin S.lassos.length), Decidable (S.ReachN n u i j)
  | 0, u, i, j => inferInstanceAs (Decidable (S.share u i j))
  | (n + 1), u, i, j =>
      letI : ∀ (v : ℤ) (a b : Fin S.lassos.length), Decidable (S.ReachN n v a b) :=
        fun v a b => decidableReachN S n v a b
      inferInstanceAs (Decidable (∃ k, S.Step u i k ∧ S.ReachN n (u + 1) k j))

namespace Thread

variable {S : SharingWitnessFamily Γ Del}

/-- A thread's one-step move is a `Step` of the class-level relation. -/
theorem step' (θ : S.Thread) (u : ℤ) : S.Step u (θ.idx u) (θ.idx (u + 1)) :=
  step_of_share_succ (θ.step u)

/-- **A thread realizes reachability between its own positions.** -/
theorem reachN (θ : S.Thread) (n : ℕ) (u : ℤ) :
    S.ReachN n u (θ.idx u) (θ.idx (u + (n : ℤ))) := by
  induction n generalizing u with
  | zero => simpa using S.share_refl u (θ.idx u)
  | succ m ih =>
    refine ⟨θ.idx (u + 1), θ.step' u, ?_⟩
    rw [int_succ_shift]
    exact ih (u + 1)

end Thread

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
