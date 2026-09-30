/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fold
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Computed

/-!
# Reading a Graph Walk as a ℤ-Indexed Half-Run

A walk in the timed graph lives on `verts`, a finite set of *window* times. A run of the certificate
lives on all of `ℤ`. This module is the translation in one direction: a forward walk is read as a
sequence of positions indexed by the genuine times at or after its start, and a backward walk as a
sequence indexed by the genuine times at or before its start.

## The one fact that makes the translation work

At step `k` a forward walk sits at the window time `(f k).2`, which is **not** `(f 0).2 + k` — the
wrap has folded it back, possibly many times. `fwdWalk_foldF` says the two times are nevertheless
`FoldF`-equivalent, by induction on `k` from `Fold.lean`'s `foldF_nextTime` and `foldF_succ`. Every
statement below is that lemma composed with one of `Fold.lean`'s data or graph-layer transports: the
walk's positions are positions of the **genuine** slices, and they step along `succP` at the
**genuine** times, even though the graph only ever read the folded ones.

## What this module does NOT do

It does **not** build a `LabRun`, and it does **not** relate anything here to `Live.lean`'s
declarative `FwdLive` / `BwdLive` / `Live`. A `LabRun` needs a labelling on **all** of `ℤ` together
with the five local-coherence clauses at every time; a single walk supplies one half-line and the
one-step clauses on it. Splicing the two half-lines, discharging the eventualities, and the
resulting equality with `Live` are still ahead, and nothing here stands in for them. What is here is
each half-line fact in the shape a `LabRun` field will consume.

## Main definitions

- `PlusSlicedCertificate.fwdWalkPos` / `bwdWalkPos` — the position a walk occupies at a genuine time
  on its own half-line

## Main results

- `PlusSlicedCertificate.fwdWalk_foldF` / `bwdWalk_foldB` — **every step of a walk is a fold**
- `PlusSlicedCertificate.fwdWalk_posAt` / `fwdWalk_succP`, and the backward pair: the walk is a
  genuine one-step path at the genuine times
- `PlusSlicedCertificate.fwdWalkPos_mem_posAt` / `fwdWalkPos_mem_succP`, and the backward pair: the
  same, read off the ℤ-indexed function on its half-line
- `PlusSlicedCertificate.fwdWalkPos_edge` / `fwdWalkPos_agrees` / `fwdWalkPos_labCoherent` /
  `fwdWalkPos_stepClause` / `fwdWalkPos_lab_sub`, and the backward analogues — the `LabRun`-shaped
  readouts

## Tags

plus-language · certificate · time-sliced · walk · unroll
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## Every step of a walk is a fold -/

/-- **A forward walk's window time at step `k` is `FoldF`-equivalent to the genuine time.** The
induction that justifies reading the whole module's remaining lemmas at genuine times. -/
theorem fwdWalk_foldF (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) :
    ∀ k : ℕ, G.FoldF (f k).2 ((f 0).2 + (k : ℤ)) := by
  intro k
  induction k with
  | zero => simpa using G.foldF_refl (f 0).2
  | succ j ih =>
      have hj : (f j).2 ∈ G.winTimes := G.snd_mem_winTimes_of_mem_verts (hV j)
      have h1 : (f (j + 1)).2 = G.nextTime (f j).2 := G.snd_of_mem_succT (hs j)
      have h2 : G.FoldF ((f j).2 + 1) ((f 0).2 + (j : ℤ) + 1) := foldF_succ ih
      have h3 : G.FoldF (G.nextTime (f j).2) ((f j).2 + 1) := G.foldF_nextTime hj
      have h4 : (f 0).2 + ((j + 1 : ℕ) : ℤ) = (f 0).2 + (j : ℤ) + 1 := by omega
      rw [h1, h4]
      exact foldF_trans h3 h2

/-- **A backward walk's window time at step `k` is `FoldB`-equivalent to the genuine time.** -/
theorem bwdWalk_foldB (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) :
    ∀ k : ℕ, G.FoldB (f k).2 ((f 0).2 - (k : ℤ)) := by
  intro k
  induction k with
  | zero => simpa using G.foldB_refl (f 0).2
  | succ j ih =>
      have hj : (f j).2 ∈ G.winTimes := G.snd_mem_winTimes_of_mem_verts (hV j)
      have h1 : (f (j + 1)).2 = G.prevTime (f j).2 := G.snd_of_mem_predT (hs j)
      have h2 : G.FoldB ((f j).2 - 1) ((f 0).2 - (j : ℤ) - 1) := foldB_pred ih
      have h3 : G.FoldB (G.prevTime (f j).2) ((f j).2 - 1) := G.foldB_prevTime hj
      have h4 : (f 0).2 - ((j + 1 : ℕ) : ℤ) = (f 0).2 - (j : ℤ) - 1 := by omega
      rw [h1, h4]
      exact foldB_trans h3 h2

/-! ## The walk is a genuine one-step path at the genuine times -/

/-- **A forward walk's positions are positions of the genuine slices.** -/
theorem fwdWalk_posAt (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) (k : ℕ) :
    (f k).1 ∈ G.posAt ((f 0).2 + (k : ℤ)) := by
  have h := G.fst_mem_posAt_of_mem_verts (hV k)
  rwa [G.foldF_posAt (G.fwdWalk_foldF hV hs k)] at h

/-- **A backward walk's positions are positions of the genuine slices.** -/
theorem bwdWalk_posAt (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) (k : ℕ) :
    (f k).1 ∈ G.posAt ((f 0).2 - (k : ℤ)) := by
  have h := G.fst_mem_posAt_of_mem_verts (hV k)
  rwa [G.foldB_posAt (G.bwdWalk_foldB hV hs k)] at h

/-- **A forward walk steps along `succP` at the genuine times**, although the graph read only the
folded ones. -/
theorem fwdWalk_succP (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) (k : ℕ) :
    (f (k + 1)).1 ∈ G.succP ((f 0).2 + (k : ℤ)) (f k).1 := by
  have h := G.fwdWalk_fst hs k
  rwa [G.foldF_succP (G.fwdWalk_foldF hV hs k) (f k).1] at h

/-- **A backward walk steps along `predP` at the genuine times.** -/
theorem bwdWalk_predP (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) (k : ℕ) :
    (f (k + 1)).1 ∈ G.predP ((f 0).2 - (k : ℤ)) (f k).1 := by
  have h := G.bwdWalk_fst hs k
  rwa [G.foldB_predP (G.bwdWalk_foldB hV hs k) (f k).1] at h

/-! ## The ℤ-indexed readout

Off its own half-line each function is pinned to the walk's starting position, an inert default that
no lemma below reads. Every statement carries the half-line hypothesis explicitly.
-/

/-- **The position a forward walk occupies at a genuine time at or after its start.** -/
def fwdWalkPos (G : PlusSlicedCertificate Γ Del) (f : ℕ → G.TPos) (t : ℤ) : G.Pos :=
  if (f 0).2 ≤ t then (f (t - (f 0).2).toNat).1 else (f 0).1

/-- **The position a backward walk occupies at a genuine time at or before its start.** -/
def bwdWalkPos (G : PlusSlicedCertificate Γ Del) (f : ℕ → G.TPos) (t : ℤ) : G.Pos :=
  if t ≤ (f 0).2 then (f ((f 0).2 - t).toNat).1 else (f 0).1

theorem fwdWalkPos_add (G : PlusSlicedCertificate Γ Del) (f : ℕ → G.TPos) (k : ℕ) :
    G.fwdWalkPos f ((f 0).2 + (k : ℤ)) = (f k).1 := by
  have hk : ((f 0).2 + (k : ℤ) - (f 0).2).toNat = k := by omega
  rw [fwdWalkPos, if_pos (by omega : (f 0).2 ≤ (f 0).2 + (k : ℤ)), hk]

theorem bwdWalkPos_sub (G : PlusSlicedCertificate Γ Del) (f : ℕ → G.TPos) (k : ℕ) :
    G.bwdWalkPos f ((f 0).2 - (k : ℤ)) = (f k).1 := by
  have hk : ((f 0).2 - ((f 0).2 - (k : ℤ))).toNat = k := by omega
  rw [bwdWalkPos, if_pos (by omega : (f 0).2 - (k : ℤ) ≤ (f 0).2), hk]

/-- Every time on the forward half-line is the start plus a natural number. -/
theorem exists_nat_add {a t : ℤ} (h : a ≤ t) : ∃ k : ℕ, t = a + (k : ℤ) :=
  ⟨(t - a).toNat, by omega⟩

/-- Every time on the backward half-line is the start minus a natural number. -/
theorem exists_nat_sub {a t : ℤ} (h : t ≤ a) : ∃ k : ℕ, t = a - (k : ℤ) :=
  ⟨(a - t).toNat, by omega⟩

theorem fwdWalkPos_mem_posAt (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) {t : ℤ}
    (ht : (f 0).2 ≤ t) : G.fwdWalkPos f t ∈ G.posAt t := by
  obtain ⟨k, hk⟩ := exists_nat_add ht
  subst hk
  rw [G.fwdWalkPos_add]
  exact G.fwdWalk_posAt hV hs k

theorem bwdWalkPos_mem_posAt (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) {t : ℤ}
    (ht : t ≤ (f 0).2) : G.bwdWalkPos f t ∈ G.posAt t := by
  obtain ⟨k, hk⟩ := exists_nat_sub ht
  subst hk
  rw [G.bwdWalkPos_sub]
  exact G.bwdWalk_posAt hV hs k

theorem fwdWalkPos_mem_succP (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) {t : ℤ}
    (ht : (f 0).2 ≤ t) : G.fwdWalkPos f (t + 1) ∈ G.succP t (G.fwdWalkPos f t) := by
  obtain ⟨k, hk⟩ := exists_nat_add ht
  subst hk
  have hcast : (f 0).2 + (k : ℤ) + 1 = (f 0).2 + ((k + 1 : ℕ) : ℤ) := by omega
  rw [G.fwdWalkPos_add, hcast, G.fwdWalkPos_add]
  exact G.fwdWalk_succP hV hs k

theorem bwdWalkPos_mem_predP (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) {t : ℤ}
    (ht : t ≤ (f 0).2) : G.bwdWalkPos f (t - 1) ∈ G.predP t (G.bwdWalkPos f t) := by
  obtain ⟨k, hk⟩ := exists_nat_sub ht
  subst hk
  have hcast : (f 0).2 - (k : ℤ) - 1 = (f 0).2 - ((k + 1 : ℕ) : ℤ) := by omega
  rw [G.bwdWalkPos_sub, hcast, G.bwdWalkPos_sub]
  exact G.bwdWalk_predP hV hs k

/-! ## The `LabRun`-shaped readouts

Each field a `LabRun` demands, restricted to the walk's own half-line. The splice that turns two
half-lines into one run is not here.
-/

theorem fwdWalkPos_lab_sub (G : PlusSlicedCertificate Γ Del) (f : ℕ → G.TPos) (t : ℤ) :
    (G.fwdWalkPos f t).2.1 ⊆ plusClosureOf (Γ ++ Del) := G.pos_lab_sub _

theorem bwdWalkPos_lab_sub (G : PlusSlicedCertificate Γ Del) (f : ℕ → G.TPos) (t : ℤ) :
    (G.bwdWalkPos f t).2.1 ⊆ plusClosureOf (Γ ++ Del) := G.pos_lab_sub _

theorem fwdWalkPos_labCoherent (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) {t : ℤ}
    (ht : (f 0).2 ≤ t) : LabCoherent Γ Del (G.fwdWalkPos f t).2.1 :=
  ((G.mem_posAt t _).mp (G.fwdWalkPos_mem_posAt hV hs ht)).1

theorem bwdWalkPos_labCoherent (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) {t : ℤ}
    (ht : t ≤ (f 0).2) : LabCoherent Γ Del (G.bwdWalkPos f t).2.1 :=
  ((G.mem_posAt t _).mp (G.bwdWalkPos_mem_posAt hV hs ht)).1

theorem fwdWalkPos_agrees (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) {t : ℤ}
    (ht : (f 0).2 ≤ t) :
    G.AgreesOnState t (G.fwdWalkPos f t).1 (G.fwdWalkPos f t).2.1 :=
  ((G.mem_posAt t _).mp (G.fwdWalkPos_mem_posAt hV hs ht)).2

theorem bwdWalkPos_agrees (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) {t : ℤ}
    (ht : t ≤ (f 0).2) :
    G.AgreesOnState t (G.bwdWalkPos f t).1 (G.bwdWalkPos f t).2.1 :=
  ((G.mem_posAt t _).mp (G.bwdWalkPos_mem_posAt hV hs ht)).2

theorem fwdWalkPos_edge (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) {t : ℤ}
    (ht : (f 0).2 ≤ t) :
    G.edge t (G.fwdWalkPos f t).1 (G.fwdWalkPos f (t + 1)).1 = true :=
  ((G.mem_succP t _ _).mp (G.fwdWalkPos_mem_succP hV hs ht)).2.1

theorem bwdWalkPos_edge (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) {t : ℤ}
    (ht : t ≤ (f 0).2) :
    G.edge (t - 1) (G.bwdWalkPos f (t - 1)).1 (G.bwdWalkPos f t).1 = true :=
  ((G.mem_predP t _ _).mp (G.bwdWalkPos_mem_predP hV hs ht)).2.1

theorem fwdWalkPos_stepClause (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.succT (f k)) {t : ℤ}
    (ht : (f 0).2 ≤ t) :
    StepClause Γ Del (G.fwdWalkPos f t).2.1 (G.fwdWalkPos f (t + 1)).2.1 :=
  ((G.mem_succP t _ _).mp (G.fwdWalkPos_mem_succP hV hs ht)).2.2

theorem bwdWalkPos_stepClause (G : PlusSlicedCertificate Γ Del) {f : ℕ → G.TPos}
    (hV : ∀ k, f k ∈ G.verts) (hs : ∀ k, f (k + 1) ∈ G.predT (f k)) {t : ℤ}
    (ht : t ≤ (f 0).2) :
    StepClause Γ Del (G.bwdWalkPos f (t - 1)).2.1 (G.bwdWalkPos f t).2.1 :=
  ((G.mem_predP t _ _).mp (G.bwdWalkPos_mem_predP hV hs ht)).2.2

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
