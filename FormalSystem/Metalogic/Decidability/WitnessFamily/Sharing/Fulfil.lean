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
