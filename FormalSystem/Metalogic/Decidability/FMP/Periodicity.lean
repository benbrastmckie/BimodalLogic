/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.IntNormalForm
import Mathlib.Data.Fintype.Pigeonhole
import Mathlib.SetTheory.Cardinal.Finite

/-!
# Periodicity: Pigeonhole and Splicing over a Finite Carrier

The reusable periodicity toolkit for ℤ-time frames with a finite `WorldState`. Nothing of this
kind existed in the tree — no `UltimatelyPeriodic`, no `EventuallyPeriodic`, no lasso detection —
so this is new construction rather than a re-export.

Everything here is stated against `Semantics/IntNormalForm.lean`'s `iter` and `IsStepPath`, the
adjacency presentation `mem_HF_iff_adjacent` establishes, so the results apply to **any**
`TaskFrame ℤ` with finite `WorldState` and not only to one particular construction.

## The three results

1. **Pigeonhole** (`exists_repeat_of_card_lt`, `exists_repeat_of_isStepPath`): a window longer than
   the carrier repeats a state.
2. **Splice** (`exists_lt_iter_of_card_le`): a repeated state licenses excising the loop between
   its two occurrences, yielding a strictly shorter iterate between the same endpoints.
3. **Bounded witness distance** (`exists_bounded_iter`): if a property is reachable at all, it is
   reachable within `Nat.card W` steps.

## A correction to the planned statement of (3)

The obvious phrasing — "if a state satisfying `P` is reachable *along the path* at all, it is
reachable *along that path* within a bound in `card W`" — is **false for a fixed path**, and the
statement here is deliberately not it. Counterexample: over `W = Fin 3` with steps `0 → 1`,
`1 → 0`, `1 → 2`, the path `0, 1, 0, 1, 0, 1, 2, …` is a legitimate step-path on which the first
state satisfying `· = 2` sits at distance 6, well beyond `card W = 3`. A path is free to wander
around a loop arbitrarily often before leaving it, and pigeonhole says only that it *repeats* a
state, not that the repetition can be removed without changing the path.

What is true — and what a bounded search actually needs — is the *reachability* statement:
shortening is available if one is allowed to pick a different path. That is `exists_bounded_iter`
below, and (2) is exactly the shortening step it runs on.

## Path form and iterate form

`iter` is a convenient inductive predicate but a poor object to do pigeonhole on, since it does not
expose the intermediate states. `exists_path_of_iter` and `iter_of_path` convert between the two
presentations; the splice lemma works in the path presentation and returns to the iterate one.
-/

namespace FormalSystem.Semantics

/-!
## Converting between iterates and explicit paths
-/

/--
An `n`-step iterate exposes an explicit path: a function on `ℕ` running from `w` to `u` in `n`
adjacent steps. Values beyond `n` are unconstrained.
-/
theorem exists_path_of_iter {W : Type} (R : W → W → Prop) (n : ℕ) (w u : W)
    (h : iter R n w u) :
    ∃ p : ℕ → W, p 0 = w ∧ p n = u ∧ ∀ i, i < n → R (p i) (p (i + 1)) := by
  induction n generalizing u with
  | zero =>
    exact ⟨fun _ => w, rfl, (iter_zero R w u).mp h, fun i hi => absurd hi (Nat.not_lt_zero i)⟩
  | succ n ih =>
    obtain ⟨v, hv, hvu⟩ := h
    obtain ⟨p, hp0, hpn, hadj⟩ := ih v hv
    classical
    refine ⟨fun i => if i ≤ n then p i else u, ?_, ?_, ?_⟩
    · simpa using hp0
    · simp
    · intro i hi
      rcases Nat.lt_succ_iff_lt_or_eq.mp hi with hlt | heq
      · have h1 : i ≤ n := Nat.le_of_lt hlt
        have h2 : i + 1 ≤ n := hlt
        simpa [h1, h2] using hadj i hlt
      · subst heq
        have h1 : ¬ (i + 1 ≤ i) := by omega
        simpa [h1, hpn] using hvu

/-- An adjacent stretch of a path is an iterate between its endpoints. -/
theorem iter_of_path {W : Type} (R : W → W → Prop) (p : ℕ → W) (a : ℕ) :
    ∀ n : ℕ, (∀ i, a ≤ i → i < a + n → R (p i) (p (i + 1))) → iter R n (p a) (p (a + n)) := by
  intro n
  induction n with
  | zero => intro _; exact rfl
  | succ n ih =>
    intro h
    refine ⟨p (a + n), ih (fun i hi hlt => h i hi (by omega)), ?_⟩
    exact h (a + n) (by omega) (by omega)

/-!
## Pigeonhole
-/

/--
**Pigeonhole on a window.** Any window of length exceeding the carrier's cardinality repeats a
state. Stated for a bare function on `ℤ`: adjacency plays no role whatsoever in this argument, and
saying so keeps the lemma reusable.
-/
theorem exists_repeat_of_card_lt {W : Type} [Finite W] (f : ℤ → W) (a : ℤ) (n : ℕ)
    (hn : Nat.card W < n) :
    ∃ i j : ℤ, a ≤ i ∧ i < j ∧ j ≤ a + n ∧ f i = f j := by
  classical
  haveI := Fintype.ofFinite W
  have hcW : Fintype.card W = Nat.card W := Nat.card_eq_fintype_card.symm
  have hc : Fintype.card W < Fintype.card (Fin (n + 1)) := by
    rw [Fintype.card_fin, hcW]; omega
  obtain ⟨x, y, hxy, hfxy⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun k : Fin (n + 1) => f (a + (k : ℕ))) hc
  rcases lt_or_gt_of_ne (fun h : (x : ℕ) = (y : ℕ) => hxy (Fin.ext h)) with hlt | hlt
  · exact ⟨a + (x : ℕ), a + (y : ℕ), by omega, by exact_mod_cast by omega,
      by have := y.isLt; omega, hfxy⟩
  · exact ⟨a + (y : ℕ), a + (x : ℕ), by omega, by exact_mod_cast by omega,
      by have := x.isLt; omega, hfxy.symm⟩

/-- The pigeonhole, phrased on a bi-infinite step-path. The adjacency hypothesis is carried for
the reader's benefit and is not consumed — a repeat is forced by finiteness alone. -/
theorem exists_repeat_of_isStepPath {F : TaskFrame ℤ} [Finite F.WorldState]
    {f : ℤ → F.WorldState} (_h : IsStepPath F f) (a : ℤ) (n : ℕ)
    (hn : Nat.card F.WorldState < n) :
    ∃ i j : ℤ, a ≤ i ∧ i < j ∧ j ≤ a + n ∧ f i = f j :=
  exists_repeat_of_card_lt f a n hn

/-!
## Splicing
-/

/--
**The splice lemma.** An iterate at least as long as the carrier passes through some state twice,
and the loop between the two visits can be excised: the same two endpoints are joined by a
*strictly shorter* iterate.

This is what turns "reachable" into "reachable within a bound": iterating it drives any witness
length below `Nat.card W`.
-/
theorem exists_lt_iter_of_card_le {W : Type} [Finite W] (R : W → W → Prop) {n : ℕ} {w u : W}
    (h : iter R n w u) (hn : Nat.card W ≤ n) : ∃ m, m < n ∧ iter R m w u := by
  classical
  haveI := Fintype.ofFinite W
  obtain ⟨p, hp0, hpn, hadj⟩ := exists_path_of_iter R n w u h
  have hcW : Fintype.card W = Nat.card W := Nat.card_eq_fintype_card.symm
  have hc : Fintype.card W < Fintype.card (Fin (n + 1)) := by
    rw [Fintype.card_fin, hcW]; omega
  obtain ⟨x, y, hxy, hpxy⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun k : Fin (n + 1) => p (k : ℕ)) hc
  -- Name the earlier index `i` and the later `j`.
  obtain ⟨i, j, hij, hjn, hpij⟩ :
      ∃ i j : ℕ, i < j ∧ j ≤ n ∧ p i = p j := by
    rcases lt_or_gt_of_ne (fun hh : (x : ℕ) = (y : ℕ) => hxy (Fin.ext hh)) with hlt | hlt
    · exact ⟨x, y, hlt, by have := y.isLt; omega, hpxy⟩
    · exact ⟨y, x, hlt, by have := x.isLt; omega, hpxy.symm⟩
  -- `w ⟶^i p i` and `p j ⟶^(n - j) u`, and `p i = p j`.
  have hwi : iter R i w (p i) := by
    have := iter_of_path R p 0 i (fun k _ hk => hadj k (by omega))
    simpa [hp0] using this
  have hju : iter R (n - j) (p j) u := by
    have := iter_of_path R p j (n - j) (fun k hk hk' => hadj k (by omega))
    have hjj : j + (n - j) = n := by omega
    rwa [hjj, hpn] at this
  refine ⟨i + (n - j), by omega, ?_⟩
  exact (iter_add R i (n - j) w u).mpr ⟨p i, hwi, hpij ▸ hju⟩

/-!
## Bounded witness distance
-/

/--
**Bounded witness distance.** If some state satisfying `P` is reachable from `w` at all, it is
reachable in fewer than `Nat.card W` steps.

Read the quantifiers carefully: this is a statement about *reachability*, not about a fixed path.
See this module's docstring for the counterexample showing the fixed-path phrasing is false. The
proof is strong induction on the witness length, shortening by `exists_lt_iter_of_card_le`
whenever the length is still at least `Nat.card W`.

This is the bound a decision procedure searches to: to decide whether a `P`-state is reachable it
suffices to enumerate iterates of length `< Nat.card W`.
-/
theorem exists_bounded_iter {W : Type} [Finite W] (R : W → W → Prop) (P : W → Prop) (w : W)
    (h : ∃ n u, iter R n w u ∧ P u) :
    ∃ n u, n < Nat.card W ∧ iter R n w u ∧ P u := by
  obtain ⟨n, u, hn, hu⟩ := h
  induction n using Nat.strong_induction_on generalizing u with
  | _ n ih =>
    by_cases hlt : n < Nat.card W
    · exact ⟨n, u, hlt, hn, hu⟩
    · obtain ⟨m, hmn, hm⟩ := exists_lt_iter_of_card_le R hn (by omega)
      exact ih m hmn u hm hu

/-- The same bound, phrased for the one-step relation of a `TaskFrame ℤ` with finite carrier —
the form `mem_HF_iff_adjacent` hands to a search over a finite step-graph. -/
theorem exists_bounded_iter_step (F : TaskFrame ℤ) [Finite F.WorldState]
    (P : F.WorldState → Prop) (w : F.WorldState)
    (h : ∃ n u, iter F.step n w u ∧ P u) :
    ∃ n u, n < Nat.card F.WorldState ∧ iter F.step n w u ∧ P u :=
  exists_bounded_iter F.step P w h

/-!
## Worked instances

Each of the three results exercised on the two-state cycle — `Bool` with the flip relation, which
is `flipFrame.step` (`Semantics/IntNormalForm.lean`). `Nat.card Bool = 2`, so the bounds are small
enough to read off.
-/

section WorkedInstances

/-- Pigeonhole: any window of three consecutive times in a `Bool`-valued path repeats a state. -/
example (f : ℤ → Bool) (a : ℤ) :
    ∃ i j : ℤ, a ≤ i ∧ i < j ∧ j ≤ a + 3 ∧ f i = f j :=
  exists_repeat_of_card_lt f a 3 (by simp)

/-- Splice: `true ⟶ false ⟶ true` is a two-step loop, and `Nat.card Bool = 2`, so the loop is
excisable — a strictly shorter iterate joins the same endpoints (here the empty one). -/
example : ∃ m, m < 2 ∧ iter (fun w u : Bool => w ≠ u) m true true :=
  exists_lt_iter_of_card_le (fun w u : Bool => w ≠ u)
    (n := 2) (w := true) (u := true) ⟨false, ⟨true, rfl, by simp⟩, by simp⟩ (by simp)

/-- Bounded witness distance: `false` is reachable from `true` along the flip relation, hence
reachable in fewer than `Nat.card Bool = 2` steps. -/
example : ∃ n u, n < Nat.card Bool ∧ iter (fun w u : Bool => w ≠ u) n true u ∧ u = false :=
  exists_bounded_iter (fun w u : Bool => w ≠ u) (· = false) true
    ⟨1, false, ⟨true, rfl, by simp⟩, rfl⟩

/-- The same bound reached through a frame's one-step relation rather than a bare relation, via
`exists_bounded_iter_step` and `flipFrame`. -/
example (P : flipFrame.WorldState → Prop) (w : flipFrame.WorldState)
    (h : ∃ n u, iter flipFrame.step n w u ∧ P u) :
    ∃ n u, n < Nat.card flipFrame.WorldState ∧ iter flipFrame.step n w u ∧ P u := by
  haveI : Finite flipFrame.WorldState := inferInstanceAs (Finite Bool)
  exact exists_bounded_iter_step flipFrame P w h

end WorkedInstances

end FormalSystem.Semantics
