/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.ClockFrame
import Mathlib.Algebra.Order.Archimedean.Basic

/-!
# Looping durations, periodicity, and the validity of `CO`

The `CO`-validity half of the independence result uses the periodic clock frame only through a
single property, isolated here as `LoopingDuration`: a nonzero duration `π` whose task relation
is the identity, `w ⇒_π u ⟺ u = w`.

Three lemmas follow, each proved for an arbitrary frame carrying a looping duration:

* **Lemma A** (`states_add_of_looping`) — *history* periodicity. `def:world-history`'s
  task-respect clause, applied at the single pair `(x, x + π)`, already forces
  `τ(x + π) = τ(x)` for every total history. Nothing about `H_F` is needed.
* **Lemma B** (`truthAt_add_period`) — *truth* periodicity:
  `M,τ,t ⊨ φ ⟺ M,τ,t+π ⊨ φ`, by induction on `Formula`. The history is universally quantified
  *inside* the induction, which is what lets the `□` case — whose clause ranges over **all**
  total histories — apply the induction hypothesis at each of them.
* **Lemma C** (`allPast_imp_allFuture`, `co_true`) — over an Archimedean `D`, periodicity
  collapses past and future: `Hψ → Gψ` holds at every point, and hence every instance of `CO`
  is true at every point, for every `ψ`.

`allFuture_imp_allPast` records the past mirror `Gψ → Hψ`, which the same argument gives for
free and which the `temporal_duality` closure of `CoNotPriorU.lean` consumes.

The clock frame instantiates all of this at `π = 1`: see `clockFrame_looping` and
`clock_co_true` at the end of the file.
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {D : TemporalOrder}

/-! ## Looping durations -/

/--
`π` is a **looping duration** of `F`: a nonzero duration whose task relation is the identity.

The clock frame's circumference `1` is one, and it is the only property of the clock frame that
the `CO`-validity argument uses.
-/
def LoopingDuration (F : FrameOver D) (π : ↑D) : Prop :=
  π ≠ 0 ∧ ∀ w u, F.TaskRel w π u ↔ u = w

/-- The negation of a looping duration is a looping duration, by the converse convention. -/
theorem LoopingDuration.neg {F : FrameOver D} {π : ↑D} (h : LoopingDuration F π) :
    LoopingDuration F (-π) := by
  refine ⟨neg_ne_zero.mpr h.1, fun w u => ?_⟩
  have hconv := F.converse w (-π) u
  rw [neg_neg] at hconv
  exact hconv.trans ((h.2 u w).trans eq_comm)

/-- A frame with a looping duration has a **positive** one. -/
theorem LoopingDuration.exists_pos {F : FrameOver D} {π : ↑D} (h : LoopingDuration F π) :
    ∃ p : D, 0 < p ∧ LoopingDuration F p := by
  rcases lt_trichotomy π 0 with hlt | heq | hgt
  · exact ⟨-π, neg_pos.mpr hlt, h.neg⟩
  · exact absurd heq h.1
  · exact ⟨π, hgt, h⟩

/-! ## Lemma A — history periodicity -/

/--
**Lemma A.** A looping duration makes every total history periodic.

This is forced by `def:world-history`'s task-respect clause alone, applied at the single pair of
times `(x, x + π)`: the clause hands over `τ(x) ⇒_π τ(x + π)`, and a looping duration relates a
state only to itself.
-/
theorem states_add_of_looping {F : FrameOver D} {π : ↑D} (h : LoopingDuration F π)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (x : ↑D) :
    τ.states (x + π) (hτ (x + π)) = τ.states x (hτ x) := by
  have hr := τ.respects_task x (x + π) (hτ x) (hτ (x + π))
  have hd : x + π - x = π := by abel
  rw [hd] at hr
  exact (h.2 _ _).mp hr

/-! ## Lemma B — truth periodicity -/

/--
**Lemma B.** Truth is `π`-periodic in time, for every formula, at every total history.

The statement quantifies over the history **inside** the induction. That is essential and not a
stylistic choice: the `□` clause of `TruthAt` ranges over *all* total histories, so the induction
hypothesis has to be available at each of them, not only at the history the statement started
with.
-/
theorem truthAt_add_period {F : FrameOver D} (M : TaskModel F) {π : ↑D}
    (h : LoopingDuration F π) :
    ∀ (φ : Formula) (τ : WorldHistory F), τ.IsTotal → ∀ t : ↑D,
      (TruthAt M τ t φ ↔ TruthAt M τ (t + π) φ) := by
  intro φ
  induction φ with
  | atom p =>
      intro τ hτ t
      simp only [TruthAt]
      constructor
      · rintro ⟨_, hv⟩
        exact ⟨hτ _, by rw [states_add_of_looping h τ hτ t]; exact hv⟩
      · rintro ⟨_, hv⟩
        exact ⟨hτ _, by rw [← states_add_of_looping h τ hτ t]; exact hv⟩
  | bot => intro _ _ _; exact Iff.rfl
  | imp ψ χ ihψ ihχ =>
      intro τ hτ t
      simp only [TruthAt]
      constructor
      · intro hi hψ; exact (ihχ τ hτ t).mp (hi ((ihψ τ hτ t).mpr hψ))
      · intro hi hψ; exact (ihχ τ hτ t).mpr (hi ((ihψ τ hτ t).mp hψ))
  | box ψ ih =>
      intro τ hτ t
      simp only [TruthAt]
      exact ⟨fun hb σ hσ => (ih σ hσ t).mp (hb σ hσ),
             fun hb σ hσ => (ih σ hσ t).mpr (hb σ hσ)⟩
  | untl χ ψ ihχ ihψ =>
      intro τ hτ t
      simp only [TruthAt]
      constructor
      · rintro ⟨s, hs, hev, hg⟩
        refine ⟨s + π, (add_lt_add_iff_right π).mpr hs, (ihψ τ hτ s).mp hev, ?_⟩
        intro r hr1 hr2
        have hrl : t < r - π := lt_sub_iff_add_lt.mpr hr1
        have hrr : r - π < s := sub_lt_iff_lt_add.mpr hr2
        have hkey := (ihχ τ hτ (r - π)).mp (hg (r - π) hrl hrr)
        rwa [sub_add_cancel] at hkey
      · rintro ⟨s, hs, hev, hg⟩
        have hs' : t < s - π := lt_sub_iff_add_lt.mpr hs
        refine ⟨s - π, hs', ?_, ?_⟩
        · exact (ihψ τ hτ (s - π)).mpr (by rwa [sub_add_cancel])
        · intro r hr1 hr2
          have hrl : t + π < r + π := (add_lt_add_iff_right π).mpr hr1
          have hrr : r + π < s := by
            have := (add_lt_add_iff_right π).mpr hr2
            rwa [sub_add_cancel] at this
          exact (ihχ τ hτ r).mpr (hg (r + π) hrl hrr)
  | snce χ ψ ihχ ihψ =>
      intro τ hτ t
      simp only [TruthAt]
      constructor
      · rintro ⟨s, hs, hev, hg⟩
        refine ⟨s + π, (add_lt_add_iff_right π).mpr hs, (ihψ τ hτ s).mp hev, ?_⟩
        intro r hr1 hr2
        have hrl : s < r - π := lt_sub_iff_add_lt.mpr hr1
        have hrr : r - π < t := sub_lt_iff_lt_add.mpr hr2
        have hkey := (ihχ τ hτ (r - π)).mp (hg (r - π) hrl hrr)
        rwa [sub_add_cancel] at hkey
      · rintro ⟨s, hs, hev, hg⟩
        have hs' : s - π < t := sub_lt_iff_lt_add.mpr hs
        refine ⟨s - π, hs', ?_, ?_⟩
        · exact (ihψ τ hτ (s - π)).mpr (by rwa [sub_add_cancel])
        · intro r hr1 hr2
          have hrl : s < r + π := by
            have := (add_lt_add_iff_right π).mpr hr1
            rwa [sub_add_cancel] at this
          have hrr : r + π < t + π := (add_lt_add_iff_right π).mpr hr2
          exact (ihχ τ hτ r).mpr (hg (r + π) hrl hrr)

/-- **Lemma B, iterated**: truth is invariant under any whole number of loops. -/
theorem truthAt_add_nsmul {F : FrameOver D} (M : TaskModel F) {π : ↑D}
    (h : LoopingDuration F π) (φ : Formula) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : ↑D) :
    ∀ n : ℕ, (TruthAt M τ t φ ↔ TruthAt M τ (t + n • π) φ) := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      have h1 := truthAt_add_period M h φ τ hτ (t + n • π)
      have h2 : t + n • π + π = t + (n + 1) • π := by
        rw [succ_nsmul]; abel
      rw [h2] at h1
      exact ih.trans h1

/-! ## Lemma C — `CO` is true everywhere -/

/--
**Lemma C.** Over an Archimedean duration order, a looping duration collapses `H` into `G`:
if `ψ` holds at every past time then it holds at every future time.

Given a future point `s`, the Archimedean property supplies a whole number of loops carrying `s`
strictly below `t`. `ψ` holds there because `Hψ` does, and Lemma B carries it back up to `s`.
-/
theorem allPast_imp_allFuture {F : FrameOver D} [Archimedean ↑D] (M : TaskModel F) {π : ↑D}
    (h : LoopingDuration F π) (ψ : Formula) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : ↑D)
    (hH : TruthAt M τ t ψ.allPast) : TruthAt M τ t ψ.allFuture := by
  obtain ⟨p, hp, hlp⟩ := h.exists_pos
  rw [Truth.future_iff]
  rw [Truth.past_iff] at hH
  intro s hs
  obtain ⟨n, hn⟩ := Archimedean.arch (s - t) hp
  -- One extra loop turns `≤` into `<`.
  have hlt : s - (n + 1) • p < t := by
    have h1 : s - n • p ≤ t :=
      calc s - n • p ≤ s - (s - t) := sub_le_sub_left hn s
        _ = t := by abel
    calc s - (n + 1) • p = s - n • p - p := by rw [succ_nsmul]; abel
      _ ≤ t - p := sub_le_sub_right h1 p
      _ < t := sub_lt_self t hp
  have hbase := hH (s - (n + 1) • p) hlt
  have hstep := (truthAt_add_nsmul M hlp ψ τ hτ (s - (n + 1) • p) (n + 1)).mp hbase
  rwa [sub_add_cancel] at hstep

/--
The past mirror of Lemma C: `Gψ → Hψ`. Free from the same argument, and consumed by the
`temporal_duality` closure of the `CO` derivation system.
-/
theorem allFuture_imp_allPast {F : FrameOver D} [Archimedean ↑D] (M : TaskModel F) {π : ↑D}
    (h : LoopingDuration F π) (ψ : Formula) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : ↑D)
    (hG : TruthAt M τ t ψ.allFuture) : TruthAt M τ t ψ.allPast := by
  obtain ⟨p, hp, hlp⟩ := h.exists_pos
  rw [Truth.past_iff]
  rw [Truth.future_iff] at hG
  intro s hs
  obtain ⟨n, hn⟩ := Archimedean.arch (t - s) hp
  have hgt : t < s + (n + 1) • p := by
    have h1 : t ≤ s + n • p := by
      calc t = s + (t - s) := by abel
        _ ≤ s + n • p := (add_le_add_iff_left s).mpr hn
    calc t ≤ s + n • p := h1
      _ < s + n • p + p := lt_add_of_pos_right _ hp
      _ = s + (n + 1) • p := by rw [succ_nsmul]; abel
  have hbase := hG (s + (n + 1) • p) hgt
  exact (truthAt_add_nsmul M hlp ψ τ hτ s (n + 1)).mpr hbase

/--
**Every `CO` instance is true everywhere** in every model on a frame with a looping duration.

`Formula.co ψ = △(Hψ → F(Hψ)) → (Hψ → Gψ)`, and the consequent is already valid here by
Lemma C, so the antecedent is discarded.
-/
theorem co_true {F : FrameOver D} [Archimedean ↑D] (M : TaskModel F) {π : ↑D}
    (h : LoopingDuration F π) (ψ : Formula) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : ↑D) :
    TruthAt M τ t (Formula.co ψ) :=
  fun _ hH => allPast_imp_allFuture M h ψ τ hτ t hH

/-! ## The clock instance -/

/-- Duration `1` moves no point of the circle: `⟦1⟧ = 0`. -/
theorem clockRel_one (w u : ClockState) : clockRel w 1 u ↔ u = w := by
  show u = w + cmk 1 ↔ u = w
  rw [cmk_one, add_zero]

/-- The clock frame's circumference `1` is a looping duration. -/
theorem clockFrame_looping : LoopingDuration clockFrame (1 : ℚ) :=
  ⟨one_ne_zero, fun w u => clockRel_one w u⟩

/-- Lemma C at the clock frame: every `CO` instance is true at every point of every model on the
periodic clock, along every total history. -/
theorem clock_co_true (M : TaskModel clockFrame) (ψ : Formula)
    (τ : WorldHistory clockFrame) (hτ : τ.IsTotal) (t : ℚ) :
    TruthAt M τ t (Formula.co ψ) :=
  co_true M clockFrame_looping ψ τ hτ t

/-- `Hψ → Gψ` at the clock frame. -/
theorem clock_allPast_imp_allFuture (M : TaskModel clockFrame) (ψ : Formula)
    (τ : WorldHistory clockFrame) (hτ : τ.IsTotal) (t : ℚ)
    (hH : TruthAt M τ t ψ.allPast) : TruthAt M τ t ψ.allFuture :=
  allPast_imp_allFuture M clockFrame_looping ψ τ hτ t hH

/-- `Gψ → Hψ` at the clock frame. -/
theorem clock_allFuture_imp_allPast (M : TaskModel clockFrame) (ψ : Formula)
    (τ : WorldHistory clockFrame) (hτ : τ.IsTotal) (t : ℚ)
    (hG : TruthAt M τ t ψ.allFuture) : TruthAt M τ t ψ.allPast :=
  allFuture_imp_allPast M clockFrame_looping ψ τ hτ t hG

end FormalSystem.Metalogic.Independence
