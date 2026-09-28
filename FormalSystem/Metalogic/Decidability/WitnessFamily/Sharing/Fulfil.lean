/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Decide

/-!
# The Position Graph and the `A[g U e]` Fixpoint

(C2') is the condition that every **thread** through a position discharges the eventualities
labelled there. Unlike the deterministic (C2), it is not a statement about one lasso: once
histories recombine there are infinitely many walks through a position, and the condition
universally quantifies over all of them. This module supplies the computational core that
makes it decidable — a finite graph and a least fixpoint over it. The semantic condition and
the correctness of this computation against it are the next phase's subject; nothing here
claims them.

## `A[g U e]`, as a least fixpoint

"Every walk from `v` delivers `e`, with `g` at every strictly intermediate position" is the
branching-time operator `A[g U e]`. On a finite graph it is the **least** fixpoint of

```
F(X) = { v : every successor w of v has e ∈ lab w, or has g ∈ lab w and lies in X }
```

Least, not greatest: the greatest fixpoint also contains the positions that pass the obligation
around a cycle forever without ever delivering, which is exactly the failure the deterministic
device's `FulfillingLab` exists to exclude (`Examples.lean`'s `sepFamily` is the witness that
the distinction has content). `AUFix.lfp` below is the iteration from `∅`, and
`AUFix.lfp_least` is the property that pins it down as least.

## The termination measure

The iteration is increasing and confined to the vertex set, so its cardinality is nondecreasing
and bounded. `AUFix.exists_stab` runs the pigeonhole: if no step from index `0` to index
`|V|` were fixed, every step would strictly increase the cardinality and
`(iter (|V| + 1)).card ≥ |V| + 1 > |V| ≥ (iter (|V| + 1)).card`. This is the same shrinking
`Finset`-cardinality measure as `BiLasso/GoodCycle.lean`'s bound, read in the growing rather
than the shrinking direction: the "not yet known to fulfil" set `V \ iter n` strictly shrinks
exactly when `iter n` strictly grows. Fuel `|V| + 1` rather than `|V|`, because the chain
starts at index `0` with `∅` and may grow at each of `|V|` subsequent steps.

## The dual is an instantiation

`snceFix` is `AUFix.lfp` with `predF` in place of `succF` and nothing else changed. No lemma
below is proved twice: everything about the fixpoint is stated at an arbitrary successor
function, so the backward computation inherits it.

## Window wraparound

The graph's vertices are the positions `(i, u)` with `u` in the combined window of
`Sharing/Decide.lean`. Its edges must not leave the window, so `nextTime` steps to `u + 1`
except at the right edge, where it wraps back by one forward period, and `prevTime` mirrors
this at the left edge. Both wraps are data-preserving — `rep_nextTime`, `L_nextTime` and their
duals discharge that from `data_congr_fwd` and `data_congr_back` — which is what will let the
next phase read a walk in this graph as a walk in the bi-infinite position space.

## What this module does *not* claim

Nothing here relates `untlFix` to threads. The positions of the graph are a folded image of the
bi-infinite position space, and whether folding preserves the *universal* obligation is exactly
the content of the next phase — including the far-left case, where `Decide.lean`'s
`untlObl_shift_back` needed an extra period of headroom for the deterministic analogue. The
combined window carries two periods on each side for that reason.

## Main Definitions

- `AUFix.step` / `AUFix.iter` / `AUFix.lfp` — the operator, its iteration, and the fixpoint
- `SharingWitnessFamily.verts` / `succF` / `predF` — the position graph and its two directions
- `SharingWitnessFamily.untlFix` / `snceFix` — the two fixpoints

## Main Results

- `AUFix.step_mono` — the operator is monotone
- `AUFix.exists_stab` — the iteration stabilizes within `|V|` steps
- `AUFix.lfp_fixed` / `AUFix.lfp_least` / `AUFix.lfp_induction`
- `SharingWitnessFamily.rep_nextTime` / `L_nextTime` and duals — the wraps preserve data
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-!
## The `A[g U e]` least fixpoint, at an arbitrary finite graph

Stated at an arbitrary vertex type with an arbitrary successor function, so that the `snce`
computation is this same development at `predF`.
-/

namespace AUFix

variable {α : Type*} [DecidableEq α]

/--
One step of the `A[g U e]` operator: the positions all of whose successors either deliver the
event now, or carry the guard and are already known to deliver it later.
-/
def step (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) : Finset α :=
  V.filter (fun v => ∀ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ X))

theorem step_subset (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) :
    step V succ isE isG X ⊆ V := Finset.filter_subset _ _

/-- **The operator is monotone**, which is what makes the iteration a chain. -/
theorem step_mono (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {X Y : Finset α}
    (h : X ⊆ Y) : step V succ isE isG X ⊆ step V succ isE isG Y := by
  intro v hv
  rw [step, Finset.mem_filter] at hv ⊢
  refine ⟨hv.1, fun w hw => ?_⟩
  rcases hv.2 w hw with he | ⟨hg, hx⟩
  · exact Or.inl he
  · exact Or.inr ⟨hg, h hx⟩

/-- The iteration of the operator from `∅`. -/
def iter (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) : ℕ → Finset α
  | 0 => ∅
  | n + 1 => step V succ isE isG (iter V succ isE isG n)

theorem iter_subset (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ n, iter V succ isE isG n ⊆ V
  | 0 => Finset.empty_subset _
  | _ + 1 => step_subset _ _ _ _ _

theorem iter_succ_mono (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ n, iter V succ isE isG n ⊆ iter V succ isE isG (n + 1)
  | 0 => Finset.empty_subset _
  | n + 1 => step_mono V succ isE isG (iter_succ_mono V succ isE isG n)

theorem iter_mono (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {m n : ℕ}
    (h : m ≤ n) : iter V succ isE isG m ⊆ iter V succ isE isG n := by
  induction n with
  | zero =>
      have hm : m = 0 := Nat.le_zero.mp h
      subst hm
      exact Finset.Subset.refl _
  | succ k ih =>
      rcases Nat.lt_or_ge m (k + 1) with hlt | hge
      · exact subset_trans (ih (Nat.lt_succ_iff.mp hlt)) (iter_succ_mono V succ isE isG k)
      · have hm : m = k + 1 := le_antisymm h hge
        subst hm
        exact Finset.Subset.refl _

/-- **Stabilization propagates**: once one step is fixed, every later index agrees with it. -/
theorem iter_stab (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {n : ℕ}
    (h : iter V succ isE isG (n + 1) = iter V succ isE isG n) :
    ∀ m, n ≤ m → iter V succ isE isG m = iter V succ isE isG n := by
  intro m
  induction m with
  | zero =>
      intro hm
      have hn : n = 0 := Nat.le_zero.mp hm
      subst hn
      rfl
  | succ k ih =>
      intro hm
      rcases Nat.lt_or_ge n (k + 1) with hlt | hge
      · have hk : n ≤ k := Nat.lt_succ_iff.mp hlt
        have hek : iter V succ isE isG k = iter V succ isE isG n := ih hk
        have : iter V succ isE isG (k + 1)
            = step V succ isE isG (iter V succ isE isG n) := by
          rw [← hek]; rfl
        rw [this]
        exact h
      · have hn : n = k + 1 := le_antisymm hm hge
        subst hn
        rfl

/--
**The iteration stabilizes within `|V|` steps.**

The pigeonhole on the cardinality measure: an increasing chain inside `V` that never repeats
would have to exceed `V`'s own cardinality.
-/
theorem exists_stab (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∃ n ≤ V.card, iter V succ isE isG (n + 1) = iter V succ isE isG n := by
  by_contra hc
  push Not at hc
  have hcard : ∀ n, n ≤ V.card + 1 → n ≤ (iter V succ isE isG n).card := by
    intro n
    induction n with
    | zero => intro _; exact Nat.zero_le _
    | succ k ih =>
        intro hk
        have hk' : k ≤ V.card := by omega
        have hne := hc k hk'
        have hsub := iter_succ_mono V succ isE isG k
        have hss : iter V succ isE isG k ⊂ iter V succ isE isG (k + 1) :=
          Finset.ssubset_iff_subset_ne.mpr ⟨hsub, fun hcon => hne hcon.symm⟩
        have hlt := Finset.card_lt_card hss
        have hprev := ih (by omega)
        omega
  have h1 := hcard (V.card + 1) (le_refl _)
  have h2 : (iter V succ isE isG (V.card + 1)).card ≤ V.card :=
    Finset.card_le_card (iter_subset V succ isE isG _)
  omega

/-- **The `A[g U e]` fixpoint**: the iteration run to its stabilization bound. -/
def lfp (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) : Finset α :=
  iter V succ isE isG (V.card + 1)

theorem lfp_subset (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    lfp V succ isE isG ⊆ V := iter_subset _ _ _ _ _

/-- **It is a fixpoint.** -/
theorem lfp_fixed (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    step V succ isE isG (lfp V succ isE isG) = lfp V succ isE isG := by
  obtain ⟨n, hn, hstab⟩ := exists_stab V succ isE isG
  have e1 : iter V succ isE isG (V.card + 1) = iter V succ isE isG n :=
    iter_stab V succ isE isG hstab _ (by omega)
  have e2 : iter V succ isE isG (V.card + 2) = iter V succ isE isG n :=
    iter_stab V succ isE isG hstab _ (by omega)
  change iter V succ isE isG (V.card + 2) = iter V succ isE isG (V.card + 1)
  rw [e1, e2]

/-- **It is the least pre-fixpoint**, which is what excludes the eventualities that are passed
around a cycle forever without ever being delivered. -/
theorem lfp_least (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {X : Finset α}
    (h : step V succ isE isG X ⊆ X) : lfp V succ isE isG ⊆ X := by
  have key : ∀ n, iter V succ isE isG n ⊆ X := by
    intro n
    induction n with
    | zero => exact Finset.empty_subset _
    | succ k ih => exact subset_trans (step_mono V succ isE isG ih) h
  exact key _

/-- Membership in the fixpoint, unfolded one step. -/
theorem mem_lfp_iff (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (v : α) :
    v ∈ lfp V succ isE isG ↔
      v ∈ V ∧ ∀ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ lfp V succ isE isG) := by
  constructor
  · intro hv
    rw [← lfp_fixed V succ isE isG, step, Finset.mem_filter] at hv
    exact hv
  · intro hv
    rw [← lfp_fixed V succ isE isG, step, Finset.mem_filter]
    exact hv

/--
**Induction along the iteration.** The tool a soundness proof against the semantic condition
consumes: a property closed under the operator holds throughout the fixpoint.
-/
theorem lfp_induction (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {P : α → Prop}
    (hstep : ∀ v ∈ V, (∀ w ∈ succ v, isE w = true ∨ (isG w = true ∧ P w)) → P v) :
    ∀ v ∈ lfp V succ isE isG, P v := by
  have key : ∀ n, ∀ v ∈ iter V succ isE isG n, P v := by
    intro n
    induction n with
    | zero => intro v hv; simp only [iter] at hv; exact absurd hv (by simp)
    | succ k ih =>
        intro v hv
        have hv' : v ∈ step V succ isE isG (iter V succ isE isG k) := hv
        rw [step, Finset.mem_filter] at hv'
        refine hstep v hv'.1 (fun w hw => ?_)
        rcases hv'.2 w hw with he | ⟨hg, hx⟩
        · exact Or.inl he
        · exact Or.inr ⟨hg, ih w hx⟩
  exact key _

end AUFix

namespace SharingWitnessFamily

variable {Γ Del : Context}

/-! ## The position graph -/

/-- A position of the family: a lasso index and a time. -/
abbrev Pos (S : SharingWitnessFamily Γ Del) : Type := Fin S.lassos.length × ℤ

/-- The times of the combined window. -/
def winTimes (S : SharingWitnessFamily Γ Del) : Finset ℤ :=
  Finset.Ico S.cohWindowLo S.cohWindowHi

theorem mem_winTimes (S : SharingWitnessFamily Γ Del) (u : ℤ) :
    u ∈ S.winTimes ↔ S.cohWindowLo ≤ u ∧ u < S.cohWindowHi := Finset.mem_Ico

/-- The vertices of the position graph: every lasso index at every window time. -/
def verts (S : SharingWitnessFamily Γ Del) : Finset S.Pos := Finset.univ ×ˢ S.winTimes

theorem mem_verts (S : SharingWitnessFamily Γ Del) (v : S.Pos) :
    v ∈ S.verts ↔ v.2 ∈ S.winTimes := by
  simp [verts, Finset.mem_product]

/--
**The vertex set is finite.**

`Pos` itself is not a `Fintype` and cannot be: its time coordinate is `ℤ`, and keeping the time
coordinate in the carrier is precisely the feature that makes `Probe476.fmp_false`'s pigeonhole
step inapplicable to this design. Finiteness therefore lives on `verts`, a `Finset` of `Pos`,
and the graph is carried as a `Finset`-valued successor function rather than as a relation on a
`Fintype`. The `Fintype` the fixpoint needs is the one below, which comes free from `verts`.
-/
example (S : SharingWitnessFamily Γ Del) : Fintype {v : S.Pos // v ∈ S.verts} := inferInstance

/--
The successor time inside the window: `u + 1`, wrapped back by one forward period at the right
edge so the graph never leaves the window.
-/
def nextTime (S : SharingWitnessFamily Γ Del) (u : ℤ) : ℤ :=
  if u + 1 < S.cohWindowHi then u + 1 else u + 1 - S.NF

/-- The predecessor time inside the window, the leftward mirror of `nextTime`. -/
def prevTime (S : SharingWitnessFamily Γ Del) (u : ℤ) : ℤ :=
  if S.cohWindowLo ≤ u - 1 then u - 1 else u - 1 + S.NB

/-- At the right edge of the window the successor time is exactly the wrap target. -/
theorem nextTime_edge (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes)
    (hw : ¬ u + 1 < S.cohWindowHi) : u + 1 = S.NM + 2 * S.NF ∧ S.nextTime u = S.NM + S.NF := by
  obtain ⟨_, hhi⟩ := (S.mem_winTimes u).mp hu
  have hHi : S.cohWindowHi = S.NM + 2 * S.NF := rfl
  refine ⟨by omega, ?_⟩
  simp only [nextTime, if_neg hw]
  omega

/-- At the left edge of the window the predecessor time is exactly the wrap target. -/
theorem prevTime_edge (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes)
    (hw : ¬ S.cohWindowLo ≤ u - 1) : u - 1 = -2 * S.NB - 1 ∧ S.prevTime u = -S.NB - 1 := by
  obtain ⟨hlo, _⟩ := (S.mem_winTimes u).mp hu
  have hLo : S.cohWindowLo = -2 * S.NB := rfl
  refine ⟨by omega, ?_⟩
  simp only [prevTime, if_neg hw]
  omega

theorem nextTime_mem (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes) :
    S.nextTime u ∈ S.winTimes := by
  have hNB := S.NB_pos
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  obtain ⟨hlo, hhi⟩ := (S.mem_winTimes u).mp hu
  have hLo : S.cohWindowLo = -2 * S.NB := rfl
  have hHi : S.cohWindowHi = S.NM + 2 * S.NF := rfl
  rw [S.mem_winTimes]
  by_cases hw : u + 1 < S.cohWindowHi
  · simp only [nextTime, if_pos hw]; omega
  · obtain ⟨_, he⟩ := S.nextTime_edge hu hw
    rw [he]; omega

theorem prevTime_mem (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes) :
    S.prevTime u ∈ S.winTimes := by
  have hNB := S.NB_pos
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  obtain ⟨hlo, hhi⟩ := (S.mem_winTimes u).mp hu
  have hLo : S.cohWindowLo = -2 * S.NB := rfl
  have hHi : S.cohWindowHi = S.NM + 2 * S.NF := rfl
  rw [S.mem_winTimes]
  by_cases hw : S.cohWindowLo ≤ u - 1
  · simp only [prevTime, if_pos hw]; omega
  · obtain ⟨_, he⟩ := S.prevTime_edge hu hw
    rw [he]; omega

/-! ### The wraps preserve the family's data -/

/-- The forward wrap does not change the representative map. -/
theorem rep_nextTime (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes) :
    S.rep (S.nextTime u) = S.rep (u + 1) := by
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  by_cases hw : u + 1 < S.cohWindowHi
  · simp only [nextTime, if_pos hw]
  · obtain ⟨hue, he⟩ := S.nextTime_edge hu hw
    rw [he, hue]
    refine (S.data_congr_fwd (by omega) (by omega) ?_).1
    rw [show S.NM + S.NF - S.NM = 0 + 1 * S.NF by omega,
      show S.NM + 2 * S.NF - S.NM = 0 + 2 * S.NF by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-- The forward wrap does not change any lasso's label. -/
theorem L_nextTime (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes)
    (i : Fin S.lassos.length) : S.L i (S.nextTime u) = S.L i (u + 1) := by
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  by_cases hw : u + 1 < S.cohWindowHi
  · simp only [nextTime, if_pos hw]
  · obtain ⟨hue, he⟩ := S.nextTime_edge hu hw
    rw [he, hue]
    refine (S.data_congr_fwd (by omega) (by omega) ?_).2 i
    rw [show S.NM + S.NF - S.NM = 0 + 1 * S.NF by omega,
      show S.NM + 2 * S.NF - S.NM = 0 + 2 * S.NF by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-- The backward wrap does not change the representative map. -/
theorem rep_prevTime (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes) :
    S.rep (S.prevTime u) = S.rep (u - 1) := by
  have hNB := S.NB_pos
  by_cases hw : S.cohWindowLo ≤ u - 1
  · simp only [prevTime, if_pos hw]
  · obtain ⟨hue, he⟩ := S.prevTime_edge hu hw
    rw [he, hue]
    refine (S.data_congr_back (by omega) (by omega) ?_).1
    rw [show -S.NB - 1 = (-1 - S.NB) + 0 * S.NB by omega,
      show -2 * S.NB - 1 = (-1 - S.NB) + (-1) * S.NB by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-- The backward wrap does not change any lasso's label. -/
theorem L_prevTime (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes)
    (i : Fin S.lassos.length) : S.L i (S.prevTime u) = S.L i (u - 1) := by
  have hNB := S.NB_pos
  by_cases hw : S.cohWindowLo ≤ u - 1
  · simp only [prevTime, if_pos hw]
  · obtain ⟨hue, he⟩ := S.prevTime_edge hu hw
    rw [he, hue]
    refine (S.data_congr_back (by omega) (by omega) ?_).2 i
    rw [show -S.NB - 1 = (-1 - S.NB) + 0 * S.NB by omega,
      show -2 * S.NB - 1 = (-1 - S.NB) + (-1) * S.NB by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-! ### The two edge relations -/

/--
The successors of a position: every index sharing the state one step later, at the window's
successor time. `Step` at the underlying times, folded into the window.
-/
def succF (S : SharingWitnessFamily Γ Del) (v : S.Pos) : Finset S.Pos :=
  S.verts.filter (fun w => w.2 = S.nextTime v.2 ∧ S.share (v.2 + 1) v.1 w.1)

/-- The predecessors of a position, the converse edge relation. -/
def predF (S : SharingWitnessFamily Γ Del) (v : S.Pos) : Finset S.Pos :=
  S.verts.filter (fun w => w.2 = S.prevTime v.2 ∧ S.share v.2 v.1 w.1)

theorem mem_succF (S : SharingWitnessFamily Γ Del) (v w : S.Pos) :
    w ∈ S.succF v ↔ w ∈ S.verts ∧ w.2 = S.nextTime v.2 ∧ S.share (v.2 + 1) v.1 w.1 :=
  Finset.mem_filter

theorem mem_predF (S : SharingWitnessFamily Γ Del) (v w : S.Pos) :
    w ∈ S.predF v ↔ w ∈ S.verts ∧ w.2 = S.prevTime v.2 ∧ S.share v.2 v.1 w.1 :=
  Finset.mem_filter

theorem succF_subset (S : SharingWitnessFamily Γ Del) (v : S.Pos) : S.succF v ⊆ S.verts :=
  Finset.filter_subset _ _

theorem predF_subset (S : SharingWitnessFamily Γ Del) (v : S.Pos) : S.predF v ⊆ S.verts :=
  Finset.filter_subset _ _

/-- **Every vertex has a successor**: staying on the same lasso is always a step, because
`share` is reflexive. The graph has no dead ends, so a walk can always be continued. -/
theorem succF_nonempty (S : SharingWitnessFamily Γ Del) {v : S.Pos} (hv : v ∈ S.verts) :
    (S.succF v).Nonempty := by
  refine ⟨(v.1, S.nextTime v.2), ?_⟩
  rw [S.mem_succF]
  exact ⟨(S.mem_verts _).mpr (S.nextTime_mem ((S.mem_verts v).mp hv)), rfl,
    S.share_refl (v.2 + 1) v.1⟩

/-- **Every vertex has a predecessor**, for the same reason. -/
theorem predF_nonempty (S : SharingWitnessFamily Γ Del) {v : S.Pos} (hv : v ∈ S.verts) :
    (S.predF v).Nonempty := by
  refine ⟨(v.1, S.prevTime v.2), ?_⟩
  rw [S.mem_predF]
  exact ⟨(S.mem_verts _).mpr (S.prevTime_mem ((S.mem_verts v).mp hv)), rfl,
    S.share_refl v.2 v.1⟩

/-! ## The two fixpoints -/

/-- Whether a formula is labelled at a position. -/
def atPos (S : SharingWitnessFamily Γ Del) (χ : Formula) (v : S.Pos) : Bool :=
  decide (χ ∈ S.L v.1 v.2)

theorem atPos_iff (S : SharingWitnessFamily Γ Del) (χ : Formula) (v : S.Pos) :
    S.atPos χ v = true ↔ χ ∈ S.L v.1 v.2 := by
  simp [atPos]

/--
**`A[g U e]` over the position graph**: the least set of positions from which every forward walk
delivers `e`, with `g` labelled at every strictly intermediate position.
-/
def untlFix (S : SharingWitnessFamily Γ Del) (g e : Formula) : Finset S.Pos :=
  AUFix.lfp S.verts S.succF (S.atPos e) (S.atPos g)

/--
**The `snce` dual**, on the reversed graph.

`AUFix.lfp` with `predF` for `succF`, and nothing else: the dual is an instantiation of the
same operator, not a second development.
-/
def snceFix (S : SharingWitnessFamily Γ Del) (g e : Formula) : Finset S.Pos :=
  AUFix.lfp S.verts S.predF (S.atPos e) (S.atPos g)

theorem untlFix_subset (S : SharingWitnessFamily Γ Del) (g e : Formula) :
    S.untlFix g e ⊆ S.verts := AUFix.lfp_subset _ _ _ _

theorem snceFix_subset (S : SharingWitnessFamily Γ Del) (g e : Formula) :
    S.snceFix g e ⊆ S.verts := AUFix.lfp_subset _ _ _ _

theorem mem_untlFix_iff (S : SharingWitnessFamily Γ Del) (g e : Formula) (v : S.Pos) :
    v ∈ S.untlFix g e ↔
      v ∈ S.verts ∧ ∀ w ∈ S.succF v,
        e ∈ S.L w.1 w.2 ∨ (g ∈ S.L w.1 w.2 ∧ w ∈ S.untlFix g e) := by
  rw [untlFix, AUFix.mem_lfp_iff]
  simp only [S.atPos_iff]

theorem mem_snceFix_iff (S : SharingWitnessFamily Γ Del) (g e : Formula) (v : S.Pos) :
    v ∈ S.snceFix g e ↔
      v ∈ S.verts ∧ ∀ w ∈ S.predF v,
        e ∈ S.L w.1 w.2 ∨ (g ∈ S.L w.1 w.2 ∧ w ∈ S.snceFix g e) := by
  rw [snceFix, AUFix.mem_lfp_iff]
  simp only [S.atPos_iff]

/-- Induction along the forward fixpoint's iteration. -/
theorem untlFix_induction (S : SharingWitnessFamily Γ Del) (g e : Formula) {P : S.Pos → Prop}
    (hstep : ∀ v ∈ S.verts,
      (∀ w ∈ S.succF v, e ∈ S.L w.1 w.2 ∨ (g ∈ S.L w.1 w.2 ∧ P w)) → P v) :
    ∀ v ∈ S.untlFix g e, P v := by
  refine AUFix.lfp_induction S.verts S.succF (S.atPos e) (S.atPos g) (fun v hv h => ?_)
  refine hstep v hv (fun w hw => ?_)
  rcases h w hw with he | ⟨hg, hp⟩
  · exact Or.inl ((S.atPos_iff e w).mp he)
  · exact Or.inr ⟨(S.atPos_iff g w).mp hg, hp⟩

/-- Induction along the backward fixpoint's iteration. -/
theorem snceFix_induction (S : SharingWitnessFamily Γ Del) (g e : Formula) {P : S.Pos → Prop}
    (hstep : ∀ v ∈ S.verts,
      (∀ w ∈ S.predF v, e ∈ S.L w.1 w.2 ∨ (g ∈ S.L w.1 w.2 ∧ P w)) → P v) :
    ∀ v ∈ S.snceFix g e, P v := by
  refine AUFix.lfp_induction S.verts S.predF (S.atPos e) (S.atPos g) (fun v hv h => ?_)
  refine hstep v hv (fun w hw => ?_)
  rcases h w hw with he | ⟨hg, hp⟩
  · exact Or.inl ((S.atPos_iff e w).mp he)
  · exact Or.inr ⟨(S.atPos_iff g w).mp hg, hp⟩

/-! ## Folding a ℤ-time into the window

A walk in the position graph is not literally a walk in the bi-infinite position space: at the
two window edges `nextTime` and `prevTime` wrap. `FoldRel` is the equivalence the forward wrap
generates and `FoldRelB` the one the backward wrap generates, and the `rep`/`L` lemmas below say
that neither can change the family's datum. That is what lets a graph walk be read as a ℤ-walk
and back.

Agreement of the *data* is not itself preserved by `+1` at the boundaries — two times may carry
the same labels by accident and diverge one step later — which is why the relation carries the
residue condition rather than the data agreement it implies.
-/

/-- **The forward folding relation**: equal, or both at or past the combined window offset and
congruent modulo the combined forward period. -/
def FoldRel (S : SharingWitnessFamily Γ Del) (a b : ℤ) : Prop :=
  a = b ∨ (S.NM ≤ a ∧ S.NM ≤ b ∧ (a - S.NM) % S.NF = (b - S.NM) % S.NF)

/-- **The backward folding relation**, the leftward mirror of `FoldRel`. -/
def FoldRelB (S : SharingWitnessFamily Γ Del) (a b : ℤ) : Prop :=
  a = b ∨ (a < 0 ∧ b < 0 ∧ a % S.NB = b % S.NB)

theorem foldRel_refl (S : SharingWitnessFamily Γ Del) (a : ℤ) : S.FoldRel a a := Or.inl rfl

theorem foldRelB_refl (S : SharingWitnessFamily Γ Del) (a : ℤ) : S.FoldRelB a a := Or.inl rfl

theorem foldRel_symm {S : SharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRel a b) :
    S.FoldRel b a := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · exact Or.inr ⟨h2, h1, h3.symm⟩

theorem foldRelB_symm {S : SharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRelB a b) :
    S.FoldRelB b a := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · exact Or.inr ⟨h2, h1, h3.symm⟩

theorem foldRel_trans {S : SharingWitnessFamily Γ Del} {a b c : ℤ} (h1 : S.FoldRel a b)
    (h2 : S.FoldRel b c) : S.FoldRel a c := by
  rcases h1 with rfl | ⟨p1, p2, p3⟩
  · exact h2
  · rcases h2 with rfl | ⟨_, q2, q3⟩
    · exact Or.inr ⟨p1, p2, p3⟩
    · exact Or.inr ⟨p1, q2, p3.trans q3⟩

theorem foldRelB_trans {S : SharingWitnessFamily Γ Del} {a b c : ℤ} (h1 : S.FoldRelB a b)
    (h2 : S.FoldRelB b c) : S.FoldRelB a c := by
  rcases h1 with rfl | ⟨p1, p2, p3⟩
  · exact h2
  · rcases h2 with rfl | ⟨_, q2, q3⟩
    · exact Or.inr ⟨p1, p2, p3⟩
    · exact Or.inr ⟨p1, q2, p3.trans q3⟩

/-- Folded times carry the same representative map. -/
theorem foldRel_rep {S : SharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRel a b) :
    S.rep a = S.rep b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · exact (S.data_congr_fwd h1 h2 h3).1

/-- Folded times carry the same labels. -/
theorem foldRel_L {S : SharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRel a b)
    (i : Fin S.lassos.length) : S.L i a = S.L i b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · exact (S.data_congr_fwd h1 h2 h3).2 i

theorem foldRelB_rep {S : SharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRelB a b) :
    S.rep a = S.rep b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · exact (S.data_congr_back h1 h2 h3).1

theorem foldRelB_L {S : SharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRelB a b)
    (i : Fin S.lassos.length) : S.L i a = S.L i b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · exact (S.data_congr_back h1 h2 h3).2 i

/-- The forward relation is closed under a common successor. -/
theorem foldRel_succ {S : SharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRel a b) :
    S.FoldRel (a + 1) (b + 1) := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · refine Or.inr ⟨by omega, by omega, ?_⟩
    have h4 := LabelledLasso.emod_shift (k := 1) h3
    rwa [show a - S.NM + 1 = a + 1 - S.NM by omega,
      show b - S.NM + 1 = b + 1 - S.NM by omega] at h4

/-- The backward relation is closed under a common predecessor. -/
theorem foldRelB_pred {S : SharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRelB a b) :
    S.FoldRelB (a - 1) (b - 1) := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · refine Or.inr ⟨by omega, by omega, ?_⟩
    have h4 := LabelledLasso.emod_shift (k := -1) h3
    rwa [show a + (-1 : ℤ) = a - 1 by omega, show b + (-1 : ℤ) = b - 1 by omega] at h4

/-- **The forward wrap is a fold**: the graph's successor time is folding-equivalent to the
genuine successor time. -/
theorem foldRel_nextTime (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes) :
    S.FoldRel (S.nextTime u) (u + 1) := by
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  by_cases hw : u + 1 < S.cohWindowHi
  · exact Or.inl (by simp only [nextTime, if_pos hw])
  · obtain ⟨hue, he⟩ := S.nextTime_edge hu hw
    refine Or.inr ?_
    rw [he, hue]
    refine ⟨by omega, by omega, ?_⟩
    rw [show S.NM + S.NF - S.NM = 0 + 1 * S.NF by omega,
      show S.NM + 2 * S.NF - S.NM = 0 + 2 * S.NF by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-- **The backward wrap is a fold**, the mirror of `foldRel_nextTime`. -/
theorem foldRelB_prevTime (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes) :
    S.FoldRelB (S.prevTime u) (u - 1) := by
  have hNB := S.NB_pos
  by_cases hw : S.cohWindowLo ≤ u - 1
  · exact Or.inl (by simp only [prevTime, if_pos hw])
  · obtain ⟨hue, he⟩ := S.prevTime_edge hu hw
    refine Or.inr ?_
    rw [he, hue]
    refine ⟨by omega, by omega, ?_⟩
    rw [show -S.NB - 1 = (-1 - S.NB) + 0 * S.NB by omega,
      show -2 * S.NB - 1 = (-1 - S.NB) + (-1) * S.NB by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-- **Every time at or after the window's left edge folds forward into the window.** -/
theorem exists_fold_fwd (S : SharingWitnessFamily Γ Del) {t : ℤ} (ht : S.cohWindowLo ≤ t) :
    ∃ t' : ℤ, t' ∈ S.winTimes ∧ S.FoldRel t' t := by
  have hNB := S.NB_pos
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  have hHi : S.cohWindowHi = S.NM + 2 * S.NF := rfl
  have hLo : S.cohWindowLo = -2 * S.NB := rfl
  by_cases hin : t < S.cohWindowHi
  · exact ⟨t, (S.mem_winTimes t).mpr ⟨ht, hin⟩, S.foldRel_refl t⟩
  · have h0 : 0 ≤ (t - S.NM) % S.NF := Int.emod_nonneg _ (by omega)
    have h1 : (t - S.NM) % S.NF < S.NF := Int.emod_lt_of_pos _ hNF
    refine ⟨S.NM + (t - S.NM) % S.NF + S.NF, (S.mem_winTimes _).mpr (by omega), ?_⟩
    refine Or.inr ⟨by omega, by omega, ?_⟩
    rw [show S.NM + (t - S.NM) % S.NF + S.NF - S.NM = (t - S.NM) % S.NF + 1 * S.NF by omega,
      Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]

/-- **Every time before the window's right edge folds backward into the window.** -/
theorem exists_fold_back (S : SharingWitnessFamily Γ Del) {t : ℤ} (ht : t < S.cohWindowHi) :
    ∃ t' : ℤ, t' ∈ S.winTimes ∧ S.FoldRelB t' t := by
  have hNB := S.NB_pos
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  have hHi : S.cohWindowHi = S.NM + 2 * S.NF := rfl
  have hLo : S.cohWindowLo = -2 * S.NB := rfl
  by_cases hin : S.cohWindowLo ≤ t
  · exact ⟨t, (S.mem_winTimes t).mpr ⟨hin, ht⟩, S.foldRelB_refl t⟩
  · have h0 : 0 ≤ t % S.NB := Int.emod_nonneg _ (by omega)
    have h1 : t % S.NB < S.NB := Int.emod_lt_of_pos _ hNB
    refine ⟨t % S.NB - 2 * S.NB, (S.mem_winTimes _).mpr (by omega), ?_⟩
    refine Or.inr ⟨by omega, by omega, ?_⟩
    rw [show t % S.NB - 2 * S.NB = t % S.NB + (-2) * S.NB by omega,
      Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]

/-! ## Reading a graph walk as a thread

A thread is a bi-infinite object and a graph walk is a one-sided infinite one, so the
translation pads: before the walk's start time the thread stands still on the start index,
which is legitimate because `share` is reflexive. Forward of the start time it follows the
walk, and the fold invariant `FwdWalk.foldRel` is what makes the walk's `share` obligations at
*graph* times discharge the thread's obligations at *real* times.
-/

/-- An infinite forward walk in the position graph. -/
structure FwdWalk (S : SharingWitnessFamily Γ Del) where
  /-- The positions visited, in order. -/
  pos : ℕ → S.Pos
  /-- The walk starts at a vertex. -/
  start_mem : pos 0 ∈ S.verts
  /-- Each position is a graph successor of its predecessor. -/
  step : ∀ k, pos (k + 1) ∈ S.succF (pos k)

/-- An infinite backward walk in the position graph. -/
structure BwdWalk (S : SharingWitnessFamily Γ Del) where
  /-- The positions visited, in order of increasing distance into the past. -/
  pos : ℕ → S.Pos
  /-- The walk starts at a vertex. -/
  start_mem : pos 0 ∈ S.verts
  /-- Each position is a graph predecessor of its predecessor in the enumeration. -/
  step : ∀ k, pos (k + 1) ∈ S.predF (pos k)

namespace FwdWalk

variable {S : SharingWitnessFamily Γ Del}

theorem mem_verts (w : S.FwdWalk) : ∀ k, w.pos k ∈ S.verts
  | 0 => w.start_mem
  | k + 1 => S.succF_subset _ (w.step k)

theorem time_succ (w : S.FwdWalk) (k : ℕ) : (w.pos (k + 1)).2 = S.nextTime (w.pos k).2 :=
  ((S.mem_succF _ _).mp (w.step k)).2.1

theorem share_succ (w : S.FwdWalk) (k : ℕ) :
    S.share ((w.pos k).2 + 1) (w.pos k).1 (w.pos (k + 1)).1 :=
  ((S.mem_succF _ _).mp (w.step k)).2.2

/-- **The fold invariant.** The walk's `k`-th graph time folds the genuine time `u + k`. -/
theorem foldRel (w : S.FwdWalk) (k : ℕ) :
    S.FoldRel (w.pos k).2 ((w.pos 0).2 + (k : ℤ)) := by
  induction k with
  | zero => simp only [Nat.cast_zero, add_zero]; exact S.foldRel_refl _
  | succ k ih =>
      have hw : (w.pos k).2 ∈ S.winTimes := (S.mem_verts _).mp (w.mem_verts k)
      have hnext := S.foldRel_trans (S.foldRel_nextTime hw) (S.foldRel_succ ih)
      rw [w.time_succ k,
        show (w.pos 0).2 + ((k + 1 : ℕ) : ℤ) = (w.pos 0).2 + (k : ℤ) + 1 by omega]
      exact hnext

/-- The index function of the thread that follows the walk. -/
def walkIdx (w : S.FwdWalk) (t : ℤ) : Fin S.lassos.length :=
  if (w.pos 0).2 ≤ t then (w.pos (t - (w.pos 0).2).toNat).1 else (w.pos 0).1

theorem walkIdx_add (w : S.FwdWalk) (k : ℕ) :
    w.walkIdx ((w.pos 0).2 + (k : ℤ)) = (w.pos k).1 := by
  have h : ((w.pos 0).2 + (k : ℤ) - (w.pos 0).2).toNat = k := by omega
  simp only [walkIdx, if_pos (show (w.pos 0).2 ≤ (w.pos 0).2 + (k : ℤ) by omega), h]

theorem walkIdx_le (w : S.FwdWalk) {t : ℤ} (h : t ≤ (w.pos 0).2) :
    w.walkIdx t = (w.pos 0).1 := by
  rcases eq_or_lt_of_le h with rfl | hlt
  · have h0 := w.walkIdx_add 0
    simpa using h0
  · simp only [walkIdx, if_neg (by omega : ¬ (w.pos 0).2 ≤ t)]

theorem walkIdx_step (w : S.FwdWalk) (t : ℤ) :
    S.share (t + 1) (w.walkIdx t) (w.walkIdx (t + 1)) := by
  by_cases h1 : (w.pos 0).2 ≤ t
  · have hkt : (w.pos 0).2 + (((t - (w.pos 0).2).toNat : ℕ) : ℤ) = t := by omega
    have e1 : w.walkIdx t = (w.pos (t - (w.pos 0).2).toNat).1 := by
      simp only [walkIdx, if_pos h1]
    have e2 : w.walkIdx (t + 1) = (w.pos ((t - (w.pos 0).2).toNat + 1)).1 := by
      have hx : (t + 1 - (w.pos 0).2).toNat = (t - (w.pos 0).2).toNat + 1 := by omega
      simp only [walkIdx, if_pos (show (w.pos 0).2 ≤ t + 1 by omega), hx]
    have hf : S.FoldRel ((w.pos (t - (w.pos 0).2).toNat).2 + 1) (t + 1) := by
      have hff := S.foldRel_succ (w.foldRel (t - (w.pos 0).2).toNat)
      rwa [hkt] at hff
    have hrep : S.rep ((w.pos (t - (w.pos 0).2).toNat).2 + 1) = S.rep (t + 1) :=
      S.foldRel_rep hf
    have hs := w.share_succ (t - (w.pos 0).2).toNat
    rw [S.share_def] at hs
    rw [e1, e2, S.share_def, ← hrep]
    exact hs
  · rw [w.walkIdx_le (by omega), w.walkIdx_le (by omega)]

/-- **The thread following a forward walk.** -/
def toThread (w : S.FwdWalk) : S.Thread where
  idx := w.walkIdx
  step := w.walkIdx_step

@[simp]
theorem toThread_idx (w : S.FwdWalk) (t : ℤ) : w.toThread.idx t = w.walkIdx t := rfl

end FwdWalk

namespace BwdWalk

variable {S : SharingWitnessFamily Γ Del}

theorem mem_verts (w : S.BwdWalk) : ∀ k, w.pos k ∈ S.verts
  | 0 => w.start_mem
  | k + 1 => S.predF_subset _ (w.step k)

theorem time_succ (w : S.BwdWalk) (k : ℕ) : (w.pos (k + 1)).2 = S.prevTime (w.pos k).2 :=
  ((S.mem_predF _ _).mp (w.step k)).2.1

theorem share_succ (w : S.BwdWalk) (k : ℕ) :
    S.share (w.pos k).2 (w.pos k).1 (w.pos (k + 1)).1 :=
  ((S.mem_predF _ _).mp (w.step k)).2.2

/-- **The fold invariant**, the backward mirror. -/
theorem foldRelB (w : S.BwdWalk) (k : ℕ) :
    S.FoldRelB (w.pos k).2 ((w.pos 0).2 - (k : ℤ)) := by
  induction k with
  | zero => simp only [Nat.cast_zero, sub_zero]; exact S.foldRelB_refl _
  | succ k ih =>
      have hw : (w.pos k).2 ∈ S.winTimes := (S.mem_verts _).mp (w.mem_verts k)
      have hnext := S.foldRelB_trans (S.foldRelB_prevTime hw) (S.foldRelB_pred ih)
      rw [w.time_succ k,
        show (w.pos 0).2 - ((k + 1 : ℕ) : ℤ) = (w.pos 0).2 - (k : ℤ) - 1 by omega]
      exact hnext

/-- The index function of the thread that follows the backward walk. -/
def walkIdx (w : S.BwdWalk) (t : ℤ) : Fin S.lassos.length :=
  if t ≤ (w.pos 0).2 then (w.pos ((w.pos 0).2 - t).toNat).1 else (w.pos 0).1

theorem walkIdx_sub (w : S.BwdWalk) (k : ℕ) :
    w.walkIdx ((w.pos 0).2 - (k : ℤ)) = (w.pos k).1 := by
  have h : ((w.pos 0).2 - ((w.pos 0).2 - (k : ℤ))).toNat = k := by omega
  simp only [walkIdx, if_pos (show (w.pos 0).2 - (k : ℤ) ≤ (w.pos 0).2 by omega), h]

theorem walkIdx_ge (w : S.BwdWalk) {t : ℤ} (h : (w.pos 0).2 ≤ t) :
    w.walkIdx t = (w.pos 0).1 := by
  rcases eq_or_lt_of_le h with rfl | hlt
  · have h0 := w.walkIdx_sub 0
    simpa using h0
  · simp only [walkIdx, if_neg (by omega : ¬ t ≤ (w.pos 0).2)]

theorem walkIdx_step (w : S.BwdWalk) (t : ℤ) :
    S.share (t + 1) (w.walkIdx t) (w.walkIdx (t + 1)) := by
  by_cases h1 : t + 1 ≤ (w.pos 0).2
  · have hkt : (w.pos 0).2 - (((w.pos 0).2 - t - 1).toNat : ℤ) = t + 1 := by omega
    have e1 : w.walkIdx t = (w.pos (((w.pos 0).2 - t - 1).toNat + 1)).1 := by
      have hx : ((w.pos 0).2 - t).toNat = ((w.pos 0).2 - t - 1).toNat + 1 := by omega
      simp only [walkIdx, if_pos (show t ≤ (w.pos 0).2 by omega), hx]
    have e2 : w.walkIdx (t + 1) = (w.pos ((w.pos 0).2 - t - 1).toNat).1 := by
      have hx : ((w.pos 0).2 - (t + 1)).toNat = ((w.pos 0).2 - t - 1).toNat := by omega
      simp only [walkIdx, if_pos h1, hx]
    have hf : S.FoldRelB (w.pos ((w.pos 0).2 - t - 1).toNat).2 (t + 1) := by
      have hff := w.foldRelB ((w.pos 0).2 - t - 1).toNat
      rwa [hkt] at hff
    have hrep : S.rep (w.pos ((w.pos 0).2 - t - 1).toNat).2 = S.rep (t + 1) :=
      S.foldRelB_rep hf
    have hs := w.share_succ ((w.pos 0).2 - t - 1).toNat
    rw [S.share_def] at hs
    rw [e1, e2, S.share_def, ← hrep]
    exact hs.symm
  · rw [w.walkIdx_ge (by omega), w.walkIdx_ge (by omega)]

/-- **The thread following a backward walk.** -/
def toThread (w : S.BwdWalk) : S.Thread where
  idx := w.walkIdx
  step := w.walkIdx_step

@[simp]
theorem toThread_idx (w : S.BwdWalk) (t : ℤ) : w.toThread.idx t = w.walkIdx t := rfl

end BwdWalk

/-! ## (C1') propagation along a thread

The far-left (and far-right) case of the window reduction below turns on a fact that has no
counterpart in the deterministic device's `untlObl_shift_back`: an unfulfilled eventuality is
**carried along every thread together with its guard**. That is a consequence of (C1')
`LocalCoherentShare` alone, and it is what lets a position outside the combined window discharge
its obligation by walking into the window rather than by folding into it.

Recorded plainly, because it is the reason the window equivalence below is stated relative to
`LocalCoherentShare` rather than as a standalone `Decidable (ThreadFulfilling S)` instance.
-/

/-- **One step of the `untl` unfolding along a thread.** -/
theorem untl_thread_step {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    (θ : S.Thread) {g e : Formula} (hc : Formula.untl g e ∈ closureOf (Γ ++ Del)) {t : ℤ}
    (ht : Formula.untl g e ∈ S.L (θ.idx t) t) :
    e ∈ S.L (θ.idx (t + 1)) (t + 1) ∨
      (g ∈ S.L (θ.idx (t + 1)) (t + 1) ∧
        Formula.untl g e ∈ S.L (θ.idx (t + 1)) (t + 1)) :=
  ((h (θ.idx t) t).2.2.2.1 (θ.idx (t + 1)) (θ.step t) g e hc).mp ht

/-- A thread's index at `t` shares the state at `t` with its index at `t - 1`. -/
theorem thread_share_pred {S : SharingWitnessFamily Γ Del} (θ : S.Thread) (t : ℤ) :
    S.share t (θ.idx t) (θ.idx (t - 1)) := by
  have hstep := θ.step (t - 1)
  rw [show t - 1 + 1 = t by omega] at hstep
  exact S.share_symm hstep

/-- **One step of the `snce` unfolding along a thread.** -/
theorem snce_thread_step {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    (θ : S.Thread) {g e : Formula} (hc : Formula.snce g e ∈ closureOf (Γ ++ Del)) {t : ℤ}
    (ht : Formula.snce g e ∈ S.L (θ.idx t) t) :
    e ∈ S.L (θ.idx (t - 1)) (t - 1) ∨
      (g ∈ S.L (θ.idx (t - 1)) (t - 1) ∧
        Formula.snce g e ∈ S.L (θ.idx (t - 1)) (t - 1)) :=
  ((h (θ.idx t) t).2.2.2.2 (θ.idx (t - 1)) (thread_share_pred θ t) g e hc).mp ht

/-- **(C1') propagation, forward, by step count.** -/
theorem untl_propagate {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    (θ : S.Thread) {g e : Formula} (hc : Formula.untl g e ∈ closureOf (Γ ++ Del)) {t : ℤ}
    (ht : Formula.untl g e ∈ S.L (θ.idx t) t) :
    ∀ n : ℕ, (∀ r : ℤ, t < r → r ≤ t + 1 + (n : ℤ) → e ∉ S.L (θ.idx r) r) →
      (∀ r : ℤ, t < r → r ≤ t + 1 + (n : ℤ) → g ∈ S.L (θ.idx r) r) ∧
        Formula.untl g e ∈ S.L (θ.idx (t + 1 + (n : ℤ))) (t + 1 + (n : ℤ)) := by
  intro n
  induction n with
  | zero =>
      intro hno
      simp only [Nat.cast_zero, add_zero] at hno ⊢
      have hne : e ∉ S.L (θ.idx (t + 1)) (t + 1) := hno (t + 1) (by omega) (le_refl _)
      rcases untl_thread_step h θ hc ht with he | ⟨hg, hu⟩
      · exact absurd he hne
      · refine ⟨fun r hr1 hr2 => ?_, hu⟩
        have hre : r = t + 1 := by omega
        subst hre
        exact hg
  | succ n ih =>
      intro hno
      have hno' : ∀ r : ℤ, t < r → r ≤ t + 1 + (n : ℤ) → e ∉ S.L (θ.idx r) r := by
        intro r hr1 hr2
        exact hno r hr1 (by push_cast; omega)
      obtain ⟨hg, hu⟩ := ih hno'
      have hne : e ∉ S.L (θ.idx (t + 1 + (n : ℤ) + 1)) (t + 1 + (n : ℤ) + 1) := by
        refine hno _ (by omega) ?_
        push_cast
        omega
      have hcast : t + 1 + ((n + 1 : ℕ) : ℤ) = t + 1 + (n : ℤ) + 1 := by push_cast; omega
      rcases untl_thread_step h θ hc hu with he | ⟨hg2, hu2⟩
      · exact absurd he hne
      · refine ⟨fun r hr1 hr2 => ?_, ?_⟩
        · rcases lt_or_ge (t + 1 + (n : ℤ)) r with hgt | hle
          · have hre : r = t + 1 + (n : ℤ) + 1 := by rw [hcast] at hr2; omega
            subst hre
            exact hg2
          · exact hg r hr1 hle
        · rw [hcast]
          exact hu2

/-- **(C1') propagation, forward, at an arbitrary later time.** -/
theorem untl_propagate_le {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    (θ : S.Thread) {g e : Formula} (hc : Formula.untl g e ∈ closureOf (Γ ++ Del)) {t s : ℤ}
    (hts : t < s) (ht : Formula.untl g e ∈ S.L (θ.idx t) t)
    (hno : ∀ r : ℤ, t < r → r ≤ s → e ∉ S.L (θ.idx r) r) :
    (∀ r : ℤ, t < r → r ≤ s → g ∈ S.L (θ.idx r) r) ∧
      Formula.untl g e ∈ S.L (θ.idx s) s := by
  have hs : t + 1 + (((s - t - 1).toNat : ℕ) : ℤ) = s := by omega
  have hmain := untl_propagate h θ hc ht (s - t - 1).toNat (by rw [hs]; exact hno)
  rw [hs] at hmain
  exact hmain

/-- **(C1') propagation, backward, by step count.** -/
theorem snce_propagate {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    (θ : S.Thread) {g e : Formula} (hc : Formula.snce g e ∈ closureOf (Γ ++ Del)) {t : ℤ}
    (ht : Formula.snce g e ∈ S.L (θ.idx t) t) :
    ∀ n : ℕ, (∀ r : ℤ, t - 1 - (n : ℤ) ≤ r → r < t → e ∉ S.L (θ.idx r) r) →
      (∀ r : ℤ, t - 1 - (n : ℤ) ≤ r → r < t → g ∈ S.L (θ.idx r) r) ∧
        Formula.snce g e ∈ S.L (θ.idx (t - 1 - (n : ℤ))) (t - 1 - (n : ℤ)) := by
  intro n
  induction n with
  | zero =>
      intro hno
      simp only [Nat.cast_zero, sub_zero] at hno ⊢
      have hne : e ∉ S.L (θ.idx (t - 1)) (t - 1) := hno (t - 1) (le_refl _) (by omega)
      rcases snce_thread_step h θ hc ht with he | ⟨hg, hu⟩
      · exact absurd he hne
      · refine ⟨fun r hr1 hr2 => ?_, hu⟩
        have hre : r = t - 1 := by omega
        subst hre
        exact hg
  | succ n ih =>
      intro hno
      have hno' : ∀ r : ℤ, t - 1 - (n : ℤ) ≤ r → r < t → e ∉ S.L (θ.idx r) r := by
        intro r hr1 hr2
        exact hno r (by push_cast; omega) hr2
      obtain ⟨hg, hu⟩ := ih hno'
      have hne : e ∉ S.L (θ.idx (t - 1 - (n : ℤ) - 1)) (t - 1 - (n : ℤ) - 1) := by
        refine hno _ ?_ (by omega)
        push_cast
        omega
      have hcast : t - 1 - ((n + 1 : ℕ) : ℤ) = t - 1 - (n : ℤ) - 1 := by push_cast; omega
      rcases snce_thread_step h θ hc hu with he | ⟨hg2, hu2⟩
      · exact absurd he hne
      · refine ⟨fun r hr1 hr2 => ?_, ?_⟩
        · rcases lt_or_ge r (t - 1 - (n : ℤ)) with hgt | hle
          · have hre : r = t - 1 - (n : ℤ) - 1 := by rw [hcast] at hr1; omega
            subst hre
            exact hg2
          · exact hg r hle hr2
        · rw [hcast]
          exact hu2

/-- **(C1') propagation, backward, at an arbitrary earlier time.** -/
theorem snce_propagate_ge {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    (θ : S.Thread) {g e : Formula} (hc : Formula.snce g e ∈ closureOf (Γ ++ Del)) {t s : ℤ}
    (hts : s < t) (ht : Formula.snce g e ∈ S.L (θ.idx t) t)
    (hno : ∀ r : ℤ, s ≤ r → r < t → e ∉ S.L (θ.idx r) r) :
    (∀ r : ℤ, s ≤ r → r < t → g ∈ S.L (θ.idx r) r) ∧
      Formula.snce g e ∈ S.L (θ.idx s) s := by
  have hs : t - 1 - (((t - s - 1).toNat : ℕ) : ℤ) = s := by omega
  have hmain := snce_propagate h θ hc ht (t - s - 1).toNat (by rw [hs]; exact hno)
  rw [hs] at hmain
  exact hmain

/-- **From an event to a fulfilment.** Under (C1'), an `untl` obligation that meets its event at
*some* later time meets it at the *first* such time, and propagation supplies the guard over the
strictly intermediate positions. -/
theorem untl_fulfil_of_exists {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    (θ : S.Thread) {g e : Formula} (hc : Formula.untl g e ∈ closureOf (Γ ++ Del)) {t : ℤ}
    (ht : Formula.untl g e ∈ S.L (θ.idx t) t)
    (hex : ∃ s : ℤ, t < s ∧ e ∈ S.L (θ.idx s) s) :
    ∃ s : ℤ, t < s ∧ e ∈ S.L (θ.idx s) s ∧
      ∀ r : ℤ, t < r → r < s → g ∈ S.L (θ.idx r) r := by
  classical
  have hex' : ∃ n : ℕ, e ∈ S.L (θ.idx (t + 1 + (n : ℤ))) (t + 1 + (n : ℤ)) := by
    obtain ⟨s, hs1, hs2⟩ := hex
    refine ⟨(s - t - 1).toNat, ?_⟩
    rwa [show t + 1 + (((s - t - 1).toNat : ℕ) : ℤ) = s by omega]
  obtain ⟨n, hspec, hmin⟩ :
      ∃ n : ℕ, e ∈ S.L (θ.idx (t + 1 + (n : ℤ))) (t + 1 + (n : ℤ)) ∧
        ∀ m : ℕ, m < n → e ∉ S.L (θ.idx (t + 1 + (m : ℤ))) (t + 1 + (m : ℤ)) :=
    ⟨Nat.find hex', Nat.find_spec hex', fun m hm => Nat.find_min hex' hm⟩
  refine ⟨t + 1 + (n : ℤ), by omega, hspec, ?_⟩
  intro r hr1 hr2
  rcases Nat.eq_zero_or_pos n with hn0 | hnpos
  · exfalso
    rw [hn0] at hr2
    simp only [Nat.cast_zero, add_zero] at hr2
    omega
  · have hno : ∀ r' : ℤ, t < r' → r' ≤ t + (n : ℤ) → e ∉ S.L (θ.idx r') r' := by
      intro r' hr1' hr2'
      have hre : r' = t + 1 + (((r' - t - 1).toNat : ℕ) : ℤ) := by omega
      rw [hre]
      exact hmin _ (by omega)
    have hprop := untl_propagate_le h θ hc (show t < t + (n : ℤ) by omega) ht hno
    exact hprop.1 r hr1 (by omega)

/-- **From an event to a fulfilment**, the backward mirror. -/
theorem snce_fulfil_of_exists {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    (θ : S.Thread) {g e : Formula} (hc : Formula.snce g e ∈ closureOf (Γ ++ Del)) {t : ℤ}
    (ht : Formula.snce g e ∈ S.L (θ.idx t) t)
    (hex : ∃ s : ℤ, s < t ∧ e ∈ S.L (θ.idx s) s) :
    ∃ s : ℤ, s < t ∧ e ∈ S.L (θ.idx s) s ∧
      ∀ r : ℤ, s < r → r < t → g ∈ S.L (θ.idx r) r := by
  classical
  have hex' : ∃ n : ℕ, e ∈ S.L (θ.idx (t - 1 - (n : ℤ))) (t - 1 - (n : ℤ)) := by
    obtain ⟨s, hs1, hs2⟩ := hex
    refine ⟨(t - s - 1).toNat, ?_⟩
    rwa [show t - 1 - (((t - s - 1).toNat : ℕ) : ℤ) = s by omega]
  obtain ⟨n, hspec, hmin⟩ :
      ∃ n : ℕ, e ∈ S.L (θ.idx (t - 1 - (n : ℤ))) (t - 1 - (n : ℤ)) ∧
        ∀ m : ℕ, m < n → e ∉ S.L (θ.idx (t - 1 - (m : ℤ))) (t - 1 - (m : ℤ)) :=
    ⟨Nat.find hex', Nat.find_spec hex', fun m hm => Nat.find_min hex' hm⟩
  refine ⟨t - 1 - (n : ℤ), by omega, hspec, ?_⟩
  intro r hr1 hr2
  rcases Nat.eq_zero_or_pos n with hn0 | hnpos
  · exfalso
    rw [hn0] at hr1
    simp only [Nat.cast_zero, sub_zero] at hr1
    omega
  · have hno : ∀ r' : ℤ, t - (n : ℤ) ≤ r' → r' < t → e ∉ S.L (θ.idx r') r' := by
      intro r' hr1' hr2'
      have hre : r' = t - 1 - (((t - r' - 1).toNat : ℕ) : ℤ) := by omega
      rw [hre]
      exact hmin _ (by omega)
    have hprop := snce_propagate_ge h θ hc (show t - (n : ℤ) < t by omega) ht hno
    exact hprop.1 r (by omega) hr2

/-! ## Soundness: the fixpoint implies the semantic condition

Both directions are proved by the induction principles of `Sharing/Fulfil.lean`'s fixpoint,
transported along the fold relations. Nothing here needs `LocalCoherentShare`: the fold carries
a thread's real position to a graph vertex step by step, and the fixpoint's own unfolding does
the rest.
-/

/-- **Soundness of `untlFix`.** A vertex in the forward fixpoint discharges the eventuality
along every thread through every time it folds. -/
theorem thread_untl_of_mem_untlFix (S : SharingWitnessFamily Γ Del) (g e : Formula) :
    ∀ v ∈ S.untlFix g e, ∀ t : ℤ, S.FoldRel v.2 t → ∀ θ : S.Thread, θ.idx t = v.1 →
      ∃ s : ℤ, t < s ∧ e ∈ S.L (θ.idx s) s ∧
        ∀ r : ℤ, t < r → r < s → g ∈ S.L (θ.idx r) r := by
  refine S.untlFix_induction g e
    (P := fun v => ∀ t : ℤ, S.FoldRel v.2 t → ∀ θ : S.Thread, θ.idx t = v.1 →
      ∃ s : ℤ, t < s ∧ e ∈ S.L (θ.idx s) s ∧
        ∀ r : ℤ, t < r → r < s → g ∈ S.L (θ.idx r) r)
    (fun v hv H t hft θ hθ => ?_)
  have hvw : v.2 ∈ S.winTimes := (S.mem_verts v).mp hv
  have hfs : S.FoldRel (S.nextTime v.2) (t + 1) :=
    S.foldRel_trans (S.foldRel_nextTime hvw) (S.foldRel_succ hft)
  have hwv : ((θ.idx (t + 1), S.nextTime v.2) : S.Pos) ∈ S.verts :=
    (S.mem_verts _).mpr (S.nextTime_mem hvw)
  have hws : ((θ.idx (t + 1), S.nextTime v.2) : S.Pos) ∈ S.succF v := by
    rw [S.mem_succF]
    refine ⟨hwv, rfl, ?_⟩
    have hrep : S.rep (v.2 + 1) = S.rep (t + 1) := S.foldRel_rep (S.foldRel_succ hft)
    have hs := θ.step t
    rw [S.share_def] at hs
    rw [← hθ, S.share_def, hrep]
    exact hs
  have hLeq : ∀ χ : Formula,
      χ ∈ S.L (θ.idx (t + 1)) (S.nextTime v.2) ↔ χ ∈ S.L (θ.idx (t + 1)) (t + 1) := by
    intro χ
    rw [S.foldRel_L hfs (θ.idx (t + 1))]
  rcases H _ hws with he | ⟨hg, hP⟩
  · refine ⟨t + 1, by omega, (hLeq e).mp he, ?_⟩
    intro r hr1 hr2
    exfalso
    omega
  · obtain ⟨s, hs1, hs2, hs3⟩ := hP (t + 1) hfs θ rfl
    refine ⟨s, by omega, hs2, ?_⟩
    intro r hr1 hr2
    rcases eq_or_lt_of_le (show t + 1 ≤ r by omega) with heq | hlt
    · rw [← heq]
      exact (hLeq g).mp hg
    · exact hs3 r hlt hr2

/-- **Soundness of `snceFix`**, the backward mirror. -/
theorem thread_snce_of_mem_snceFix (S : SharingWitnessFamily Γ Del) (g e : Formula) :
    ∀ v ∈ S.snceFix g e, ∀ t : ℤ, S.FoldRelB v.2 t → ∀ θ : S.Thread, θ.idx t = v.1 →
      ∃ s : ℤ, s < t ∧ e ∈ S.L (θ.idx s) s ∧
        ∀ r : ℤ, s < r → r < t → g ∈ S.L (θ.idx r) r := by
  refine S.snceFix_induction g e
    (P := fun v => ∀ t : ℤ, S.FoldRelB v.2 t → ∀ θ : S.Thread, θ.idx t = v.1 →
      ∃ s : ℤ, s < t ∧ e ∈ S.L (θ.idx s) s ∧
        ∀ r : ℤ, s < r → r < t → g ∈ S.L (θ.idx r) r)
    (fun v hv H t hft θ hθ => ?_)
  have hvw : v.2 ∈ S.winTimes := (S.mem_verts v).mp hv
  have hfs : S.FoldRelB (S.prevTime v.2) (t - 1) :=
    S.foldRelB_trans (S.foldRelB_prevTime hvw) (S.foldRelB_pred hft)
  have hwv : ((θ.idx (t - 1), S.prevTime v.2) : S.Pos) ∈ S.verts :=
    (S.mem_verts _).mpr (S.prevTime_mem hvw)
  have hws : ((θ.idx (t - 1), S.prevTime v.2) : S.Pos) ∈ S.predF v := by
    rw [S.mem_predF]
    refine ⟨hwv, rfl, ?_⟩
    have hrep : S.rep v.2 = S.rep t := S.foldRelB_rep hft
    have hs := thread_share_pred θ t
    rw [S.share_def] at hs
    rw [← hθ, S.share_def, hrep]
    exact hs
  have hLeq : ∀ χ : Formula,
      χ ∈ S.L (θ.idx (t - 1)) (S.prevTime v.2) ↔ χ ∈ S.L (θ.idx (t - 1)) (t - 1) := by
    intro χ
    rw [S.foldRelB_L hfs (θ.idx (t - 1))]
  rcases H _ hws with he | ⟨hg, hP⟩
  · refine ⟨t - 1, by omega, (hLeq e).mp he, ?_⟩
    intro r hr1 hr2
    exfalso
    omega
  · obtain ⟨s, hs1, hs2, hs3⟩ := hP (t - 1) hfs θ rfl
    refine ⟨s, by omega, hs2, ?_⟩
    intro r hr1 hr2
    rcases eq_or_lt_of_le (show r ≤ t - 1 by omega) with heq | hlt
    · rw [heq]
      exact (hLeq g).mp hg
    · exact hs3 r hr1 hlt

/-! ## A computed smoke test

The fixpoint is a *computation*, so it can be wrong in a way no lemma above would catch: an
operator that never fires, a window that decodes to the wrong times, an edge relation that is
empty. The `#guard`s below run it on the smallest family that has anything to say and check the
answer against a hand computation. They are a mechanical non-vacuity check on the computation,
not a mathematical claim — the correctness of `untlFix` against the semantic condition is the
next phase's subject.

The family has one lasso with `back = [∅]`, `mid = [{p}]`, `fwd = [∅]` and identity
representative maps, so `NB = NF = 1`, `NM = 2` and the window is `[-2, 4)`: six positions,
labelled `∅, ∅, {p}, ∅, ∅, ∅` at `-2, -1, 0, 1, 2, 3`. `nextTime` is `u + 1` except at `3`,
where it wraps back to `3`; `prevTime` is `u - 1` except at `-2`, where it wraps to `-2`.

With `g = e = p`, `A[p U p]` holds exactly at `-1` — the one position whose every successor
carries `p` — and nowhere else, because at every other position the successor carries neither
the event nor the guard. The `snce` dual is the mirror image at `1`. That the two answers are
singletons rather than `∅` or the whole window is the point: the operator fires, and it does
not fire everywhere.
-/

section SmokeTest

/-- The single atom of the smoke test. -/
private def smokeAtom : Atom := Atom.mkBase "p"

/-- The single formula of the smoke test. -/
private def smokeP : Formula := Formula.atom smokeAtom

/-- The smoke test's premise context. -/
private def smokeCtx : Context := [smokeP]

/-- One lasso carrying `p` at the origin and nothing anywhere else. -/
private def smokeLasso : LabelledLasso (closureOf (smokeCtx ++ ([] : Context))) where
  back := [∅]
  mid := [{smokeP}]
  fwd := [∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by decide

/-- The smallest sharing family: one lasso, identity representatives, so `share` is total and
the graph is a single folded line. -/
private def smokeFamily : SharingWitnessFamily smokeCtx [] where
  bx := fun _ => false
  lassos := [smokeLasso]
  lassos_ne := by simp
  repBack := [fun i => i]
  repMid := [fun i => i]
  repFwd := [fun i => i]
  repBack_ne := by simp
  repFwd_ne := by simp
  rep_idem := by decide

-- linter.hashCommand: these `#guard`s run the compiled definitions, which is the point of a
-- smoke test — a `theorem … := by decide` would check the same fact without exercising the
-- evaluator the model checker will use.
set_option linter.hashCommand false in
#guard smokeFamily.winTimes = ({-2, -1, 0, 1, 2, 3} : Finset ℤ)

set_option linter.hashCommand false in
#guard (smokeFamily.untlFix smokeP smokeP).image Prod.snd = ({-1} : Finset ℤ)

set_option linter.hashCommand false in
#guard (smokeFamily.snceFix smokeP smokeP).image Prod.snd = ({1} : Finset ℤ)

end SmokeTest

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
