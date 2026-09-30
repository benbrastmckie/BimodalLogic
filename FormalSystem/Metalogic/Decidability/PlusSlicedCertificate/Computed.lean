/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Timed
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixpoint

/-!
# The Four Computed Fixpoints on the Timed Graph

`Fixpoint.lean` supplies two existential operators at an arbitrary finite graph. This module
instantiates each of them twice — once at `succT` and once at `predT` — giving the four
`Finset`s the decidable checker reads:

* `fwdWalkable` / `bwdWalkable` — `EGFix.gfp` at each graph: the timed positions that begin an
  infinite walk inside `verts`. On a finite vertex set that is exactly the positions that reach a
  cycle, and it is the **existential fair-path half** the plan's Scope Hypothesis identified as new
  work with no counterpart in the tree.
* `untlReach` / `snceReach` — `EUFix.lfp` at each graph: the timed positions from which **some**
  walk delivers the eventuality, with the guard at every strictly intermediate vertex.

Every one of the four is a `Finset` computed from the certificate's own data, so every membership
question about them is decidable with no instance beyond the `DecidableEq` `Position.lean` already
supplies.

## Why the inner operator is existential, against the plan's letter

Sub-phase 15.3 STEP 5 as planned named `AUFix.lfp G.verts G.succT` for the inner
eventuality-discharge step. That is the **universal** `A[g U e]`, and it cannot serve here: the
outer condition this module computes is existential (some infinite walk), and `A[g U e]` at a vertex
says
nothing about whether the particular walk the outer fixpoint builds ever delivers. Worse, the
all-walks reading is precisely the (C2') demand whose failure is why this subtree exists at all —
see `PlusSlicedCertificate.lean`'s header on `not_exists_plusCertifies_pumpTarget`. So the inner
operator is `EUFix`, the existential dual, written generically in `Fixpoint.lean`. `AUFix` itself is
untouched and remains in use unchanged on the `Formula` side. Recorded as a deviation at the plan's
Phase 15 heading.

## What this module does NOT claim

It does **not** claim that any of the four equals `Live.lean`'s declarative `FwdLive` / `BwdLive` /
`Live`. That equality is the bridge (STEP 6) and it is not here: nothing below mentions `Live`, and
no placeholder stands in for it. What is here is each fixpoint together with **both** directions of
its own graph-theoretic characterization, which is what the bridge will consume from this side.

## Main definitions

- `PlusSlicedCertificate.atPosT` — whether a formula is labelled at a timed position
- `PlusSlicedCertificate.fwdWalkable` / `bwdWalkable` — the two `EGFix` fixpoints
- `PlusSlicedCertificate.untlReach` / `snceReach` — the two `EUFix` fixpoints

## Main results

- `PlusSlicedCertificate.exists_fwdWalk_of_mem` / `mem_fwdWalkable_of_walk`, and the backward pair:
  membership **is** the existence of an infinite walk, in both directions
- `PlusSlicedCertificate.mem_untlReach_iff` / `mem_snceReach_iff` — the one-step unfolding
- `PlusSlicedCertificate.exists_untlPath_of_mem` / `mem_untlReach_of_path`, and the backward pair:
  membership **is** the existence of a delivering path, in both directions
- `PlusSlicedCertificate.untlReach_induction` / `snceReach_induction`

## Tags

plus-language · certificate · time-sliced · fixpoint · computed · decidable
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## Reading a label at a timed position -/

/-- Whether a formula is labelled at a timed position. The `Formula`-side counterpart is
`SharingWitnessFamily.atPos`, which reads `S.L`; here the label is carried by the position
itself. -/
def atPosT (G : PlusSlicedCertificate Γ Del) (ψ : PlusFormula) (v : G.TPos) : Bool :=
  decide (ψ ∈ v.1.2.1)

theorem atPosT_iff (G : PlusSlicedCertificate Γ Del) (ψ : PlusFormula) (v : G.TPos) :
    G.atPosT ψ v = true ↔ ψ ∈ v.1.2.1 := by
  simp [atPosT]

/-! ## The outer existential fixpoints: an infinite walk exists

These are the half `AUFix` supplies nothing for. Each is `EGFix.gfp` at one of the two graphs, so
each comes with the coinduction principle that makes membership a *complete* test rather than a
merely sufficient one.
-/

/-- **The timed positions that begin an infinite forward walk** inside `verts`. -/
def fwdWalkable (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
  EGFix.gfp G.verts G.succT

/-- **The timed positions that begin an infinite backward walk** inside `verts`. -/
def bwdWalkable (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
  EGFix.gfp G.verts G.predT

theorem fwdWalkable_subset (G : PlusSlicedCertificate Γ Del) : G.fwdWalkable ⊆ G.verts :=
  EGFix.gfp_subset _ _

theorem bwdWalkable_subset (G : PlusSlicedCertificate Γ Del) : G.bwdWalkable ⊆ G.verts :=
  EGFix.gfp_subset _ _

/-- **One forward step stays inside the fixpoint.** -/
theorem exists_succT_mem_fwdWalkable (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (hv : v ∈ G.fwdWalkable) : ∃ w ∈ G.succT v, w ∈ G.fwdWalkable :=
  EGFix.exists_succ_mem_gfp _ _ hv

/-- **One backward step stays inside the fixpoint.** -/
theorem exists_predT_mem_bwdWalkable (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (hv : v ∈ G.bwdWalkable) : ∃ w ∈ G.predT v, w ∈ G.bwdWalkable :=
  EGFix.exists_succ_mem_gfp _ _ hv

/-- **Membership yields an infinite forward walk.** -/
theorem exists_fwdWalk_of_mem (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (hv : v ∈ G.fwdWalkable) :
    ∃ f : ℕ → G.TPos, f 0 = v ∧ (∀ k, f k ∈ G.fwdWalkable) ∧ ∀ k, f (k + 1) ∈ G.succT (f k) :=
  EGFix.exists_walk_of_mem_gfp _ _ hv

/-- **Membership yields an infinite backward walk.** -/
theorem exists_bwdWalk_of_mem (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (hv : v ∈ G.bwdWalkable) :
    ∃ f : ℕ → G.TPos, f 0 = v ∧ (∀ k, f k ∈ G.bwdWalkable) ∧ ∀ k, f (k + 1) ∈ G.predT (f k) :=
  EGFix.exists_walk_of_mem_gfp _ _ hv

/-- **An infinite forward walk yields membership.** -/
theorem mem_fwdWalkable_of_walk (G : PlusSlicedCertificate Γ Del) (f : ℕ → G.TPos)
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) : f 0 ∈ G.fwdWalkable :=
  EGFix.mem_gfp_of_walk _ _ f hV hs

/-- **An infinite backward walk yields membership.** -/
theorem mem_bwdWalkable_of_walk (G : PlusSlicedCertificate Γ Del) (f : ℕ → G.TPos)
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) : f 0 ∈ G.bwdWalkable :=
  EGFix.mem_gfp_of_walk _ _ f hV hs

/-! ### What a walk does to the time coordinate

Both graphs advance the time by their own wrap at every step, so a walk's times are determined by
its starting time. This is what the bridge will unroll.
-/

/-- **A forward walk's times advance by `nextTime`.** -/
theorem fwdWalk_snd (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) (k : ℕ) : (f (k + 1)).2 = G.nextTime (f k).2 :=
  G.snd_of_mem_succT (hs k)

/-- **A backward walk's times retreat by `prevTime`.** -/
theorem bwdWalk_snd (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) (k : ℕ) : (f (k + 1)).2 = G.prevTime (f k).2 :=
  G.snd_of_mem_predT (hs k)

/-- **A forward walk's position steps along `succP` at the unwrapped time.** -/
theorem fwdWalk_fst (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) (k : ℕ) : (f (k + 1)).1 ∈ G.succP (f k).2 (f k).1 :=
  G.fst_mem_succP_of_mem_succT (hs k)

/-- **A backward walk's position steps along `predP` at the unwrapped time.** -/
theorem bwdWalk_fst (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) (k : ℕ) : (f (k + 1)).1 ∈ G.predP (f k).2 (f k).1 :=
  G.fst_mem_predP_of_mem_predT (hs k)

/-! ## The inner existential fixpoints: some walk delivers

`EUFix.lfp` at each graph, with the eventuality as the event and the `untl` / `snce` guard as the
guard — the same pairing `SharingWitnessFamily.untlFix` / `snceFix` make, with the universal
operator replaced by the existential one for the reason this module's header gives.
-/

/-- **The timed positions from which some forward walk delivers `e`**, carrying `g` throughout. -/
def untlReach (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula) : Finset G.TPos :=
  EUFix.lfp G.verts G.succT (G.atPosT e) (G.atPosT g)

/-- **The `snce` dual**, on the backward graph. An instantiation of the same operator, not a second
development. -/
def snceReach (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula) : Finset G.TPos :=
  EUFix.lfp G.verts G.predT (G.atPosT e) (G.atPosT g)

theorem untlReach_subset (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula) :
    G.untlReach g e ⊆ G.verts := EUFix.lfp_subset _ _ _ _

theorem snceReach_subset (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula) :
    G.snceReach g e ⊆ G.verts := EUFix.lfp_subset _ _ _ _

theorem mem_untlReach_iff (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula) (v : G.TPos) :
    v ∈ G.untlReach g e ↔
      v ∈ G.verts ∧ ∃ w ∈ G.succT v,
        e ∈ w.1.2.1 ∨ (g ∈ w.1.2.1 ∧ w ∈ G.untlReach g e) := by
  rw [untlReach, EUFix.mem_lfp_iff]
  simp only [G.atPosT_iff]

theorem mem_snceReach_iff (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula) (v : G.TPos) :
    v ∈ G.snceReach g e ↔
      v ∈ G.verts ∧ ∃ w ∈ G.predT v,
        e ∈ w.1.2.1 ∨ (g ∈ w.1.2.1 ∧ w ∈ G.snceReach g e) := by
  rw [snceReach, EUFix.mem_lfp_iff]
  simp only [G.atPosT_iff]

/-- Induction along the forward fixpoint's iteration. -/
theorem untlReach_induction (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula)
    {P : G.TPos → Prop}
    (hstep : ∀ v ∈ G.verts,
      (∃ w ∈ G.succT v, e ∈ w.1.2.1 ∨ (g ∈ w.1.2.1 ∧ P w)) → P v) :
    ∀ v ∈ G.untlReach g e, P v := by
  refine EUFix.lfp_induction G.verts G.succT (G.atPosT e) (G.atPosT g) (fun v hv h => ?_)
  obtain ⟨w, hw1, hw⟩ := h
  refine hstep v hv ⟨w, hw1, ?_⟩
  rcases hw with he | ⟨hg, hp⟩
  · exact Or.inl ((G.atPosT_iff e w).mp he)
  · exact Or.inr ⟨(G.atPosT_iff g w).mp hg, hp⟩

/-- Induction along the backward fixpoint's iteration. -/
theorem snceReach_induction (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula)
    {P : G.TPos → Prop}
    (hstep : ∀ v ∈ G.verts,
      (∃ w ∈ G.predT v, e ∈ w.1.2.1 ∨ (g ∈ w.1.2.1 ∧ P w)) → P v) :
    ∀ v ∈ G.snceReach g e, P v := by
  refine EUFix.lfp_induction G.verts G.predT (G.atPosT e) (G.atPosT g) (fun v hv h => ?_)
  obtain ⟨w, hw1, hw⟩ := h
  refine hstep v hv ⟨w, hw1, ?_⟩
  rcases hw with he | ⟨hg, hp⟩
  · exact Or.inl ((G.atPosT_iff e w).mp he)
  · exact Or.inr ⟨(G.atPosT_iff g w).mp hg, hp⟩

/-! ### Membership is exactly the existence of a delivering path -/

/-- **Membership yields a delivering forward path**, every vertex before the delivering one being a
genuine vertex of the graph. -/
theorem exists_untlPath_of_mem (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula) :
    ∀ v ∈ G.untlReach g e,
      ∃ (m : ℕ) (f : ℕ → G.TPos), 0 < m ∧ f 0 = v ∧ (∀ k < m, f k ∈ G.verts) ∧
        (∀ k < m, f (k + 1) ∈ G.succT (f k)) ∧
        e ∈ (f m).1.2.1 ∧ ∀ k, 0 < k → k < m → g ∈ (f k).1.2.1 := by
  intro v hv
  obtain ⟨m, f, hm, hf0, hV, hs, he, hg⟩ :=
    EUFix.exists_path_of_mem_lfp G.verts G.succT (G.atPosT e) (G.atPosT g) v hv
  exact ⟨m, f, hm, hf0, hV, hs, (G.atPosT_iff e (f m)).mp he,
    fun k hk0 hk1 => (G.atPosT_iff g (f k)).mp (hg k hk0 hk1)⟩

/-- **Membership yields a delivering backward path**, the mirror. -/
theorem exists_sncePath_of_mem (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula) :
    ∀ v ∈ G.snceReach g e,
      ∃ (m : ℕ) (f : ℕ → G.TPos), 0 < m ∧ f 0 = v ∧ (∀ k < m, f k ∈ G.verts) ∧
        (∀ k < m, f (k + 1) ∈ G.predT (f k)) ∧
        e ∈ (f m).1.2.1 ∧ ∀ k, 0 < k → k < m → g ∈ (f k).1.2.1 := by
  intro v hv
  obtain ⟨m, f, hm, hf0, hV, hs, he, hg⟩ :=
    EUFix.exists_path_of_mem_lfp G.verts G.predT (G.atPosT e) (G.atPosT g) v hv
  exact ⟨m, f, hm, hf0, hV, hs, (G.atPosT_iff e (f m)).mp he,
    fun k hk0 hk1 => (G.atPosT_iff g (f k)).mp (hg k hk0 hk1)⟩

/-- **A delivering forward path yields membership.** -/
theorem mem_untlReach_of_path (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula)
    (f : ℕ → G.TPos) (m : ℕ) (hm : 0 < m) (hV : ∀ k, k < m → f k ∈ G.verts)
    (hs : ∀ k < m, f (k + 1) ∈ G.succT (f k)) (he : e ∈ (f m).1.2.1)
    (hg : ∀ k, 0 < k → k < m → g ∈ (f k).1.2.1) : f 0 ∈ G.untlReach g e :=
  EUFix.mem_lfp_of_path G.verts G.succT (G.atPosT e) (G.atPosT g) f m hm hV hs
    ((G.atPosT_iff e (f m)).mpr he)
    (fun k hk0 hk1 => (G.atPosT_iff g (f k)).mpr (hg k hk0 hk1))

/-- **A delivering backward path yields membership.** -/
theorem mem_snceReach_of_path (G : PlusSlicedCertificate Γ Del) (g e : PlusFormula)
    (f : ℕ → G.TPos) (m : ℕ) (hm : 0 < m) (hV : ∀ k, k < m → f k ∈ G.verts)
    (hs : ∀ k < m, f (k + 1) ∈ G.predT (f k)) (he : e ∈ (f m).1.2.1)
    (hg : ∀ k, 0 < k → k < m → g ∈ (f k).1.2.1) : f 0 ∈ G.snceReach g e :=
  EUFix.mem_lfp_of_path G.verts G.predT (G.atPosT e) (G.atPosT g) f m hm hV hs
    ((G.atPosT_iff e (f m)).mpr he)
    (fun k hk0 hk1 => (G.atPosT_iff g (f k)).mpr (hg k hk0 hk1))

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
