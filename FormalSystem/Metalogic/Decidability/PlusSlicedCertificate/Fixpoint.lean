/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Finset.Card
import Mathlib.Data.Nat.Find
import Mathlib.Logic.Function.Iterate

/-!
# Two Existential Fixpoints on a Finite Graph

`WitnessFamily/Sharing/Fulfil.lean`'s `AUFix` is the **universal** `A[g U e]` operator: the least
set of vertices from which *every* forward walk delivers `e`. It is exactly right for the
`Formula`-side (C2'), which demands that every thread of a presentation discharge its
eventualities. This module supplies the two operators the *sliced* side needs instead, and they
are both **existential**.

## Why `AUFix` is the wrong operator here, and is deliberately not used

The sliced certificate class exists precisely to replace the all-threads demand with fulfilment of
**live** positions only — a position is live when *some* run occupies it and discharges its
eventualities, not when every walk through it does. So the outer condition is an existential
greatest fixpoint (`EGFix`: an infinite walk exists), and the eventuality-discharge inside it is an
existential least fixpoint (`EUFix`: some walk delivers). A universal inner operator cannot serve an
existential outer one: `A[g U e]` at a vertex says nothing about whether the *particular* walk the
outer fixpoint is building ever delivers.

This is a recorded departure from the plan's sub-phase 15.3 STEP 5, which named
`AUFix.lfp G.verts G.succT` for the inner step. The plan's own Scope Hypothesis asked for `AUFix`'s
binders to be read at implementation time; read, they give the stronger conclusion that `AUFix`
supplies **neither** half here. `AUFix` itself is untouched and remains in use, unchanged, on the
`Formula` side.

## Both operators terminate without any `Fintype`

Each is stated at an arbitrary vertex type with `DecidableEq` and an explicit `V : Finset α`, and
each terminates by `V.card` — `EGFix` by a strictly *decreasing* chain from `V`, `EUFix` by a
strictly *increasing* chain from `∅`. Nothing here asks the vertex type to be finite, which is what
lets them run on the rolled timed carrier `TPos := G.Pos × ℤ`.

## Main definitions

- `Nu.gfp` — the greatest fixpoint of an **arbitrary** deflating monotone contraction on
  `Finset α`, terminating at `V.card`
- `EGFix.gfp` — `Nu` at "has a successor in the set": the vertices that begin an infinite walk
  inside `V`
- `EUFix.lfp` — the least set from which some walk delivers `e` with `g` throughout

## Main results

- `Nu.gfp_fixed` / `Nu.gfp_greatest` — the fixpoint and its coinduction principle, at any
  contraction. Stated at an arbitrary `F` rather than an arbitrary successor function because the
  eventuality-aware liveness fixpoint is a **nested** one: its inner reachability test depends
  on the set being contracted, so it is not of the form `step succ`
- `EGFix.gfp_fixed` / `EGFix.gfp_greatest` — the same, specialized
- `EGFix.exists_walk_of_mem_gfp` / `EGFix.mem_gfp_of_walk` — membership **is** the existence of an
  infinite walk, in both directions
- `EUFix.mem_lfp_iff` / `EUFix.lfp_least` / `EUFix.lfp_induction`
- `EUFix.exists_path_of_mem_lfp` / `EUFix.mem_lfp_of_path` — membership **is** the existence of a
  delivering finite path, in both directions
- `EUFix.lfp_mono_all` — monotonicity in the vertex set **and** in the event and guard predicates,
  which is what a nested outer contraction needs of its inner test; `EUFix.lfp_mono_V` is the
  special case at a fixed event and guard
- `Glue.walk` — a sequence of finite paths glued into one infinite walk, with the three readouts
  (`walk_mem`, `walk_step`, `walk_eq`) a fairness argument reads off it
- `Fair.exists_fair_walk` — the round-robin concatenation: on a set where every vertex both
  continues and can discharge each of its pending eventualities *without leaving the set*, one
  infinite walk discharges **every** eventuality pending anywhere along it

## Tags

fixpoint · finite-graph · existential · decidable
-/

namespace FormalSystem.Metalogic.Decidability

/-!
## A greatest fixpoint at an arbitrary contraction

The iteration is the same whatever the contraction is, so it is written once here and instantiated
below. A **contraction** is a map on `Finset α` that is *deflating* (`F X ⊆ X`) and *monotone*; the
first makes the iteration a decreasing chain and the second makes it a chain at all. Termination is
`V.card` for the same pigeonhole reason `AUFix`'s increasing chain terminates.

`EGFix` below is the instance at "has a successor in the set". The instance the eventuality-aware
liveness fixpoint needs is **not** of that form — its inner reachability test depends on the set
being contracted — which is exactly why the iteration is stated at an arbitrary `F` rather than
at an arbitrary successor function.
-/

namespace Nu

/-! No `DecidableEq` is needed at this level: the iteration only ever applies `F`, and nothing here
filters. -/

variable {α : Type*}

/-- The iteration of a contraction from `V`. -/
def iter (V : Finset α) (F : Finset α → Finset α) : ℕ → Finset α
  | 0 => V
  | n + 1 => F (iter V F n)

theorem iter_subset (V : Finset α) {F : Finset α → Finset α} (hd : ∀ X, F X ⊆ X) :
    ∀ n, iter V F n ⊆ V
  | 0 => Finset.Subset.refl _
  | n + 1 => subset_trans (hd _) (iter_subset V hd n)

theorem iter_succ_anti (V : Finset α) {F : Finset α → Finset α} (hd : ∀ X, F X ⊆ X)
    (hm : ∀ X Y, X ⊆ Y → F X ⊆ F Y) : ∀ n, iter V F (n + 1) ⊆ iter V F n
  | 0 => hd _
  | n + 1 => hm _ _ (iter_succ_anti V hd hm n)

theorem iter_anti (V : Finset α) {F : Finset α → Finset α} (hd : ∀ X, F X ⊆ X)
    (hm : ∀ X Y, X ⊆ Y → F X ⊆ F Y) {m n : ℕ} (h : m ≤ n) : iter V F n ⊆ iter V F m := by
  induction n with
  | zero =>
      have hm0 : m = 0 := Nat.le_zero.mp h
      subst hm0
      exact Finset.Subset.refl _
  | succ k ih =>
      rcases Nat.lt_or_ge m (k + 1) with hlt | hge
      · exact subset_trans (iter_succ_anti V hd hm k) (ih (Nat.lt_succ_iff.mp hlt))
      · have hmk : m = k + 1 := le_antisymm h hge
        subst hmk
        exact Finset.Subset.refl _

/-- **Stabilization propagates**: once one contraction is fixed, every later index agrees. -/
theorem iter_stab (V : Finset α) {F : Finset α → Finset α} {n : ℕ}
    (h : iter V F (n + 1) = iter V F n) : ∀ m, n ≤ m → iter V F m = iter V F n := by
  intro m
  induction m with
  | zero =>
      intro hmm
      have hn : n = 0 := Nat.le_zero.mp hmm
      subst hn
      rfl
  | succ k ih =>
      intro hmm
      rcases Nat.lt_or_ge n (k + 1) with hlt | hge
      · have hk : n ≤ k := Nat.lt_succ_iff.mp hlt
        have hek : iter V F k = iter V F n := ih hk
        have hs : iter V F (k + 1) = F (iter V F n) := by rw [← hek]; rfl
        rw [hs]
        exact h
      · have hn : n = k + 1 := le_antisymm hmm hge
        subst hn
        rfl

/--
**The contraction stabilizes within `|V|` steps.**

The pigeonhole on the cardinality measure, mirrored from `AUFix.exists_stab`: a *decreasing* chain
inside `V` that never repeats would have to run below zero.
-/
theorem exists_stab (V : Finset α) {F : Finset α → Finset α} (hd : ∀ X, F X ⊆ X)
    (hm : ∀ X Y, X ⊆ Y → F X ⊆ F Y) : ∃ n ≤ V.card, iter V F (n + 1) = iter V F n := by
  by_contra hc
  push Not at hc
  have hcard : ∀ n, n ≤ V.card + 1 → (iter V F n).card + n ≤ V.card := by
    intro n
    induction n with
    | zero => intro _; simpa using Finset.card_le_card (iter_subset V hd 0)
    | succ k ih =>
        intro hk
        have hk' : k ≤ V.card := by omega
        have hne := hc k hk'
        have hsub := iter_succ_anti V hd hm k
        have hss : iter V F (k + 1) ⊂ iter V F k :=
          Finset.ssubset_iff_subset_ne.mpr ⟨hsub, hne⟩
        have hlt := Finset.card_lt_card hss
        have hprev := ih (by omega)
        omega
  have h1 := hcard (V.card + 1) (le_refl _)
  omega

/-- **The greatest fixpoint of a contraction**: the iteration run to its stabilization bound. -/
def gfp (V : Finset α) (F : Finset α → Finset α) : Finset α := iter V F (V.card + 1)

theorem gfp_subset (V : Finset α) {F : Finset α → Finset α} (hd : ∀ X, F X ⊆ X) :
    gfp V F ⊆ V := iter_subset V hd _

/-- **It is a fixpoint.** -/
theorem gfp_fixed (V : Finset α) {F : Finset α → Finset α} (hd : ∀ X, F X ⊆ X)
    (hm : ∀ X Y, X ⊆ Y → F X ⊆ F Y) : F (gfp V F) = gfp V F := by
  obtain ⟨n, hn, hstab⟩ := exists_stab V hd hm
  have e1 : iter V F (V.card + 1) = iter V F n := iter_stab V hstab _ (by omega)
  have e2 : iter V F (V.card + 2) = iter V F n := iter_stab V hstab _ (by omega)
  change iter V F (V.card + 2) = iter V F (V.card + 1)
  rw [e1, e2]

/--
**It is the greatest post-fixpoint** — the coinduction principle, and what makes membership a
*complete* test rather than a merely sufficient one.
-/
theorem gfp_greatest (V : Finset α) {F : Finset α → Finset α}
    (hm : ∀ X Y, X ⊆ Y → F X ⊆ F Y) {X : Finset α} (hXV : X ⊆ V) (hX : X ⊆ F X) :
    X ⊆ gfp V F := by
  have key : ∀ n, X ⊆ iter V F n := by
    intro n
    induction n with
    | zero => exact hXV
    | succ k ih => exact subset_trans hX (hm _ _ ih)
  exact key _

end Nu

/-!
## `EG ⊤`: the vertices that begin an infinite walk

The instance of `Nu` at "has a successor in the set". A vertex survives every contraction exactly
when it begins a walk that never leaves `V`, which on a finite `V` is exactly when it reaches a
cycle.
-/

namespace EGFix

variable {α : Type*} [DecidableEq α]

/-- One contraction: keep the vertices of `X` that have at least one successor inside `X`. -/
def step (succ : α → Finset α) (X : Finset α) : Finset α :=
  X.filter (fun v => ∃ w ∈ succ v, w ∈ X)

theorem mem_step (succ : α → Finset α) (X : Finset α) (v : α) :
    v ∈ step succ X ↔ v ∈ X ∧ ∃ w ∈ succ v, w ∈ X := Finset.mem_filter

/-- **The contraction is deflating**, the first half of what `Nu` asks. -/
theorem step_subset (succ : α → Finset α) (X : Finset α) : step succ X ⊆ X :=
  Finset.filter_subset _ _

/-- **The contraction is monotone**, the second half of what `Nu` asks. -/
theorem step_mono (succ : α → Finset α) {X Y : Finset α} (h : X ⊆ Y) :
    step succ X ⊆ step succ Y := by
  intro v hv
  rw [mem_step] at hv ⊢
  obtain ⟨hvX, w, hw1, hw2⟩ := hv
  exact ⟨h hvX, w, hw1, h hw2⟩

/-- **The `EG ⊤` fixpoint**: `Nu` at this contraction. -/
def gfp (V : Finset α) (succ : α → Finset α) : Finset α := Nu.gfp V (step succ)

theorem gfp_subset (V : Finset α) (succ : α → Finset α) : gfp V succ ⊆ V :=
  Nu.gfp_subset V (step_subset succ)

/-- **It is a fixpoint.** -/
theorem gfp_fixed (V : Finset α) (succ : α → Finset α) :
    step succ (gfp V succ) = gfp V succ :=
  Nu.gfp_fixed V (step_subset succ) (fun _ _ h => step_mono succ h)

/-- **Every vertex of the fixpoint has a successor inside it.** -/
theorem exists_succ_mem_gfp (V : Finset α) (succ : α → Finset α) {v : α} (hv : v ∈ gfp V succ) :
    ∃ w ∈ succ v, w ∈ gfp V succ := by
  rw [← gfp_fixed V succ, mem_step] at hv
  exact hv.2

/-- **It is the greatest post-fixpoint** — the coinduction principle. -/
theorem gfp_greatest (V : Finset α) (succ : α → Finset α) {X : Finset α} (hXV : X ⊆ V)
    (hstep : ∀ v ∈ X, ∃ w ∈ succ v, w ∈ X) : X ⊆ gfp V succ :=
  Nu.gfp_greatest V (fun _ _ h => step_mono succ h) hXV
    (fun v hv => (mem_step succ X v).mpr ⟨hv, hstep v hv⟩)

/-! ### Membership is exactly the existence of an infinite walk

Both directions, so that a soundness proof cites one and a completeness proof the other rather than
re-deriving either.
-/

/-- **A vertex of the fixpoint begins an infinite walk inside the fixpoint.** -/
theorem exists_walk_of_mem_gfp (V : Finset α) (succ : α → Finset α) {v : α}
    (hv : v ∈ gfp V succ) :
    ∃ f : ℕ → α, f 0 = v ∧ (∀ k, f k ∈ gfp V succ) ∧ ∀ k, f (k + 1) ∈ succ (f k) := by
  classical
  have hnext : ∀ x : {a // a ∈ gfp V succ}, ∃ y : {a // a ∈ gfp V succ}, y.1 ∈ succ x.1 := by
    intro x
    obtain ⟨w, hw1, hw2⟩ := exists_succ_mem_gfp V succ x.2
    exact ⟨⟨w, hw2⟩, hw1⟩
  choose g hg using hnext
  refine ⟨fun k => (g^[k] ⟨v, hv⟩).1, rfl, fun k => (g^[k] ⟨v, hv⟩).2, fun k => ?_⟩
  change (g^[k + 1] ⟨v, hv⟩).1 ∈ succ (g^[k] ⟨v, hv⟩).1
  rw [Function.iterate_succ_apply']
  exact hg _

/-- **A vertex beginning an infinite walk inside `V` is in the fixpoint.** -/
theorem mem_gfp_of_walk (V : Finset α) (succ : α → Finset α) (f : ℕ → α) (hV : ∀ k, f k ∈ V)
    (hs : ∀ k, f (k + 1) ∈ succ (f k)) : f 0 ∈ gfp V succ := by
  classical
  refine gfp_greatest V succ (X := V.filter (fun a => ∃ k, f k = a)) (Finset.filter_subset _ _)
    ?_ (Finset.mem_filter.mpr ⟨hV 0, 0, rfl⟩)
  intro a ha
  obtain ⟨-, k, hk⟩ := Finset.mem_filter.mp ha
  refine ⟨f (k + 1), ?_, Finset.mem_filter.mpr ⟨hV (k + 1), k + 1, rfl⟩⟩
  rw [← hk]
  exact hs k

end EGFix

/-!
## `E[g U e]`: the vertices from which some walk delivers

The least fixpoint of "some successor delivers now, or carries the guard and delivers later",
computed from `∅`. This is `AUFix` with its universal successor quantifier replaced by an
existential one, and nothing else; the proofs are the same proofs, which is the point.
-/

namespace EUFix

variable {α : Type*} [DecidableEq α]

/-- Prepending a vertex to a path. Definitional at both `0` and `k + 1`, which keeps the path
arithmetic below free of natural subtraction. -/
def cons (v : α) (f : ℕ → α) : ℕ → α
  | 0 => v
  | k + 1 => f k

omit [DecidableEq α] in
@[simp] theorem cons_zero (v : α) (f : ℕ → α) : cons v f 0 = v := rfl

omit [DecidableEq α] in
@[simp] theorem cons_succ (v : α) (f : ℕ → α) (k : ℕ) : cons v f (k + 1) = f k := rfl

/--
One step of the `E[g U e]` operator: the vertices **some** of whose successors either deliver the
event now, or carry the guard and are already known to deliver it later.
-/
def step (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) : Finset α :=
  V.filter (fun v => ∃ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ X))

theorem mem_step (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α)
    (v : α) :
    v ∈ step V succ isE isG X ↔
      v ∈ V ∧ ∃ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ X) := Finset.mem_filter

theorem step_subset (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) :
    step V succ isE isG X ⊆ V := Finset.filter_subset _ _

/-- **The operator is monotone**, which is what makes the iteration a chain. -/
theorem step_mono (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {X Y : Finset α}
    (h : X ⊆ Y) : step V succ isE isG X ⊆ step V succ isE isG Y := by
  intro v hv
  rw [mem_step] at hv ⊢
  obtain ⟨hvV, w, hw1, hw⟩ := hv
  refine ⟨hvV, w, hw1, ?_⟩
  rcases hw with he | ⟨hg, hx⟩
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
        have hs : iter V succ isE isG (k + 1) = step V succ isE isG (iter V succ isE isG n) := by
          rw [← hek]; rfl
        rw [hs]
        exact h
      · have hn : n = k + 1 := le_antisymm hm hge
        subst hn
        rfl

/-- **The iteration stabilizes within `|V|` steps.** -/
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

/-- **The `E[g U e]` fixpoint**: the iteration run to its stabilization bound. -/
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

/-- **It is the least pre-fixpoint**, which is what excludes an eventuality that is passed around a
cycle forever without ever being delivered. -/
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
      v ∈ V ∧ ∃ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ lfp V succ isE isG) := by
  constructor
  · intro hv
    rw [← lfp_fixed V succ isE isG, mem_step] at hv
    exact hv
  · intro hv
    rw [← lfp_fixed V succ isE isG, mem_step]
    exact hv

/-- **Induction along the iteration.** -/
theorem lfp_induction (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) {P : α → Prop}
    (hstep : ∀ v ∈ V, (∃ w ∈ succ v, isE w = true ∨ (isG w = true ∧ P w)) → P v) :
    ∀ v ∈ lfp V succ isE isG, P v := by
  have key : ∀ n, ∀ v ∈ iter V succ isE isG n, P v := by
    intro n
    induction n with
    | zero => intro v hv; simp only [iter] at hv; exact absurd hv (by simp)
    | succ k ih =>
        intro v hv
        have hv' : v ∈ step V succ isE isG (iter V succ isE isG k) := hv
        rw [mem_step] at hv'
        obtain ⟨hvV, w, hw1, hw⟩ := hv'
        refine hstep v hvV ⟨w, hw1, ?_⟩
        rcases hw with he | ⟨hg, hx⟩
        · exact Or.inl he
        · exact Or.inr ⟨hg, ih w hx⟩
  exact key _

/-! ### Membership is exactly the existence of a delivering path

Both directions, so that a soundness proof cites one and a completeness proof the other.
-/

/--
**A vertex of the fixpoint begins a finite path that delivers the event**, with the guard at
every strictly intermediate vertex, and with every vertex *before* the delivering one inside `V`.

The `∀ k < m, f k ∈ V` conjunct is what makes the path usable by a **nested** fixpoint: an outer
contraction building an infinite walk inside its own set can only splice this path in if the path
does not leave that set. The delivering vertex `f m` is deliberately **not** claimed to lie in `V`
— it need not, and a caller that needs it there says so through `isE`, as
`LiveFix.lean`'s `untlLiveAt` does.
-/
theorem exists_path_of_mem_lfp (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ v ∈ lfp V succ isE isG,
      ∃ (m : ℕ) (f : ℕ → α), 0 < m ∧ f 0 = v ∧ (∀ k < m, f k ∈ V) ∧
        (∀ k < m, f (k + 1) ∈ succ (f k)) ∧
        isE (f m) = true ∧ ∀ k, 0 < k → k < m → isG (f k) = true := by
  refine lfp_induction V succ isE isG (fun v hv h => ?_)
  obtain ⟨w, hw1, hw⟩ := h
  rcases hw with he | ⟨hg, m', f', hm', hf0, hmem', hstep', he', hg'⟩
  · refine ⟨1, cons v (fun _ => w), Nat.one_pos, rfl, ?_, ?_, he, ?_⟩
    · intro k hk
      have hk0 : k = 0 := by omega
      subst hk0
      simpa using hv
    · intro k hk
      have hk0 : k = 0 := by omega
      subst hk0
      simpa using hw1
    · intro k hk0 hk1
      omega
  · refine ⟨m' + 1, cons v f', Nat.succ_pos _, rfl, ?_, ?_, he', ?_⟩
    · intro k hk
      cases k with
      | zero => simpa using hv
      | succ j => simpa using hmem' j (by omega)
    · intro k hk
      cases k with
      | zero => simpa [hf0] using hw1
      | succ j => simpa using hstep' j (by omega)
    · intro k hk0 hk1
      cases k with
      | zero => omega
      | succ j =>
          cases j with
          | zero => simpa [hf0] using hg
          | succ i => simpa using hg' (i + 1) (by omega) (by omega)

/-- **A vertex beginning a delivering path is in the fixpoint.** -/
theorem mem_lfp_of_path (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (f : ℕ → α)
    (m : ℕ) (hm : 0 < m) (hV : ∀ k, k < m → f k ∈ V) (hs : ∀ k < m, f (k + 1) ∈ succ (f k))
    (he : isE (f m) = true) (hg : ∀ k, 0 < k → k < m → isG (f k) = true) :
    f 0 ∈ lfp V succ isE isG := by
  have key : ∀ d j, j + d + 1 = m → f j ∈ lfp V succ isE isG := by
    intro d
    induction d with
    | zero =>
        intro j hj
        rw [mem_lfp_iff]
        refine ⟨hV j (by omega), f (j + 1), hs j (by omega), Or.inl ?_⟩
        rw [show j + 1 = m from by omega]
        exact he
    | succ c ih =>
        intro j hj
        rw [mem_lfp_iff]
        exact ⟨hV j (by omega), f (j + 1), hs j (by omega),
          Or.inr ⟨hg (j + 1) (by omega) (by omega), ih (j + 1) (by omega)⟩⟩
  exact key (m - 1) 0 (by omega)

/-! ### Monotonicity in the vertex set

What a **nested** fixpoint needs: an outer contraction whose inner reachability test is taken inside
the set being contracted is monotone only if `lfp` is monotone in that set. Landed here so the
eventuality-aware liveness fixpoint can cite it rather than re-prove it.
-/

/--
**One step is monotone in the vertex set, in the event, and in the guard, all at once.**

The vertex-set argument alone is not enough for the nested liveness fixpoint. That fixpoint's inner
test relativizes **both** the intermediate vertices *and* the delivering one to the set being
contracted — `isE` carries a `w ∈ X` conjunct — so the inner `lfp` varies with `X` through its
event predicate as well as through its vertex set. Monotonicity in `isE` / `isG` is therefore not a
generalization for its own sake; without it the outer contraction is not monotone and `Nu` does not
apply. See `LiveFix.lean`'s `untlLiveAt` for the predicate that needs it.
-/
theorem step_mono_all {V V' : Finset α} (hV : V ⊆ V') (succ : α → Finset α)
    {isE isG isE' isG' : α → Bool} (hE : ∀ w, isE w = true → isE' w = true)
    (hG : ∀ w, isG w = true → isG' w = true) {X X' : Finset α} (hX : X ⊆ X') :
    step V succ isE isG X ⊆ step V' succ isE' isG' X' := by
  intro v hv
  rw [mem_step] at hv ⊢
  obtain ⟨hvV, w, hw1, hw⟩ := hv
  refine ⟨hV hvV, w, hw1, ?_⟩
  rcases hw with he | ⟨hg, hx⟩
  · exact Or.inl (hE w he)
  · exact Or.inr ⟨hG w hg, hX hx⟩

theorem iter_mono_all {V V' : Finset α} (hV : V ⊆ V') (succ : α → Finset α)
    {isE isG isE' isG' : α → Bool} (hE : ∀ w, isE w = true → isE' w = true)
    (hG : ∀ w, isG w = true → isG' w = true) :
    ∀ n, iter V succ isE isG n ⊆ iter V' succ isE' isG' n
  | 0 => Finset.Subset.refl _
  | n + 1 => step_mono_all hV succ hE hG (iter_mono_all hV succ hE hG n)

/-- **The fixpoint is monotone in all three arguments.** Not immediate from `iter_mono_all` alone,
because the two iterations are run to *different* bounds; the increasing chain closes the gap. -/
theorem lfp_mono_all {V V' : Finset α} (hV : V ⊆ V') (succ : α → Finset α)
    {isE isG isE' isG' : α → Bool} (hE : ∀ w, isE w = true → isE' w = true)
    (hG : ∀ w, isG w = true → isG' w = true) :
    lfp V succ isE isG ⊆ lfp V' succ isE' isG' := by
  refine subset_trans (iter_mono_all hV succ hE hG (V.card + 1)) ?_
  have hc : V.card ≤ V'.card := Finset.card_le_card hV
  exact iter_mono V' succ isE' isG' (by omega)

theorem step_mono_V {V V' : Finset α} (hV : V ⊆ V') (succ : α → Finset α) (isE isG : α → Bool)
    {X X' : Finset α} (hX : X ⊆ X') :
    step V succ isE isG X ⊆ step V' succ isE isG X' :=
  step_mono_all hV succ (fun _ h => h) (fun _ h => h) hX

theorem iter_mono_V {V V' : Finset α} (hV : V ⊆ V') (succ : α → Finset α) (isE isG : α → Bool) :
    ∀ n, iter V succ isE isG n ⊆ iter V' succ isE isG n :=
  iter_mono_all hV succ (fun _ h => h) (fun _ h => h)

/-- **The fixpoint is monotone in the vertex set**, the special case of `lfp_mono_all` at a fixed
event and guard. -/
theorem lfp_mono_V {V V' : Finset α} (hV : V ⊆ V') (succ : α → Finset α) (isE isG : α → Bool) :
    lfp V succ isE isG ⊆ lfp V' succ isE isG :=
  lfp_mono_all hV succ (fun _ h => h) (fun _ h => h)

end EUFix

/-!
## Gluing finite paths into one infinite walk

A fairness argument builds its walk in **blocks**: finitely many steps at a time, each block chosen
for a different obligation. This namespace turns such a block sequence into the single `ℕ → α` an
infinite-walk statement wants, with the readouts a fairness proof needs off it — every vertex lies
where the blocks do, every consecutive pair is an edge, and the `j`-th vertex of block `n` sits at a
computable index.

Nothing here mentions a fixpoint or a graph: the block data is arbitrary, and the only standing
assumption is that every block has positive length.
-/

namespace Glue

variable {α : Type*}

/-- The index at which block `n` begins. -/
def off (len : ℕ → ℕ) : ℕ → ℕ
  | 0 => 0
  | n + 1 => off len n + len n

theorem off_succ (len : ℕ → ℕ) (n : ℕ) : off len (n + 1) = off len n + len n := rfl

/-- **Positive-length blocks reach every index**: `off` dominates the identity. This is what makes
the block counter unbounded, and it is the only thing a fairness argument needs of the block
lengths. -/
theorem le_off (len : ℕ → ℕ) (h1 : ∀ n, 1 ≤ len n) : ∀ n, n ≤ off len n
  | 0 => Nat.zero_le _
  | n + 1 => by
      have hn := le_off len h1 n
      have hl := h1 n
      have he := off_succ len n
      omega

theorem off_lt_off_succ (len : ℕ → ℕ) (h1 : ∀ n, 1 ≤ len n) (n : ℕ) :
    off len n < off len (n + 1) := by
  have hl := h1 n
  have he := off_succ len n
  omega

theorem off_mono (len : ℕ → ℕ) {m n : ℕ} (h : m ≤ n) : off len m ≤ off len n := by
  induction n with
  | zero =>
      have hm : m = 0 := Nat.le_zero.mp h
      subst hm
      exact Nat.le_refl _
  | succ k ih =>
      rcases Nat.lt_or_ge m (k + 1) with hlt | hge
      · have hik := ih (Nat.lt_succ_iff.mp hlt)
        have he := off_succ len k
        omega
      · have hm : m = k + 1 := le_antisymm h hge
        subst hm
        exact Nat.le_refl _

/--
The block an index belongs to. Defined by recursion on the index rather than by a search, so that
its characterization below is an induction rather than a minimization.

The bound is written `off len n + len n` rather than `off len (n + 1)` throughout this namespace,
even though `off_succ` makes the two equal by `rfl`. That is not cosmetic: `omega` treats
`off len (n + 1)` and `off len n` as unrelated atoms, so every arithmetic step would otherwise need
`off_succ` supplied by hand at exactly the right instantiation.
-/
def idx (len : ℕ → ℕ) : ℕ → ℕ
  | 0 => 0
  | t + 1 => if off len (idx len t) + len (idx len t) ≤ t + 1 then idx len t + 1 else idx len t

@[simp] theorem idx_zero (len : ℕ → ℕ) : idx len 0 = 0 := rfl

theorem idx_succ (len : ℕ → ℕ) (t : ℕ) :
    idx len (t + 1) =
      if off len (idx len t) + len (idx len t) ≤ t + 1 then idx len t + 1 else idx len t := rfl

/-- **The block an index is assigned to really contains it.** -/
theorem idx_spec (len : ℕ → ℕ) (h1 : ∀ n, 1 ≤ len n) :
    ∀ t, off len (idx len t) ≤ t ∧ t < off len (idx len t) + len (idx len t)
  | 0 => by
      have hl : 1 ≤ len (idx len 0) := h1 _
      have hz : off len (idx len 0) = 0 := rfl
      omega
  | t + 1 => by
      obtain ⟨h2, h3⟩ := idx_spec len h1 t
      by_cases hc : off len (idx len t) + len (idx len t) ≤ t + 1
      · have heq : idx len (t + 1) = idx len t + 1 := by rw [idx_succ, if_pos hc]
        rw [heq]
        have hl : 1 ≤ len (idx len t + 1) := h1 _
        have he : off len (idx len t + 1) = off len (idx len t) + len (idx len t) :=
          off_succ len (idx len t)
        omega
      · have heq : idx len (t + 1) = idx len t := by rw [idx_succ, if_neg hc]
        rw [heq]
        omega

/-- **The containing block is unique**, which is what turns `idx` from a definition into an
address. -/
theorem idx_eq (len : ℕ → ℕ) (h1 : ∀ n, 1 ≤ len n) {t n : ℕ} (h : off len n ≤ t)
    (h' : t < off len n + len n) : idx len t = n := by
  obtain ⟨h2, h3⟩ := idx_spec len h1 t
  rcases Nat.lt_trichotomy (idx len t) n with hlt | heq | hgt
  · have hle : off len (idx len t + 1) ≤ off len n := off_mono len (Nat.succ_le_of_lt hlt)
    have he : off len (idx len t + 1) = off len (idx len t) + len (idx len t) :=
      off_succ len (idx len t)
    omega
  · exact heq
  · have hle : off len (n + 1) ≤ off len (idx len t) := off_mono len (Nat.succ_le_of_lt hgt)
    have he : off len (n + 1) = off len n + len n := off_succ len n
    omega

/-- **The glued walk**: follow the block an index belongs to, from that block's own start. -/
def walk (len : ℕ → ℕ) (path : ℕ → ℕ → α) (t : ℕ) : α :=
  path (idx len t) (t - off len (idx len t))

@[simp] theorem walk_zero (len : ℕ → ℕ) (path : ℕ → ℕ → α) : walk len path 0 = path 0 0 := rfl

/--
**The `j`-th vertex of block `n` is the glued walk at index `off len n + j`**, for every `j` up to
and *including* the block's length.

The boundary case `j = len n` is the one that earns the gluing hypothesis: there the index already
belongs to block `n + 1`, and the two readings agree exactly because block `n + 1` starts where
block `n` ends.
-/
theorem walk_eq (len : ℕ → ℕ) (path : ℕ → ℕ → α) (h1 : ∀ n, 1 ≤ len n)
    (hglue : ∀ n, path (n + 1) 0 = path n (len n)) {n j : ℕ} (hj : j ≤ len n) :
    walk len path (off len n + j) = path n j := by
  rcases Nat.lt_or_ge j (len n) with hlt | hge
  · have hi : idx len (off len n + j) = n := idx_eq len h1 (by omega) (by omega)
    unfold walk
    rw [hi, Nat.add_sub_cancel_left]
  · have hje : j = len n := le_antisymm hj hge
    subst hje
    have he : off len n + len n = off len (n + 1) := (off_succ len n).symm
    rw [he]
    have hl : 1 ≤ len (n + 1) := h1 _
    have hi : idx len (off len (n + 1)) = n + 1 :=
      idx_eq len h1 (Nat.le_refl _) (by omega)
    unfold walk
    rw [hi, Nat.sub_self]
    exact hglue n

/-- **The glued walk stays where the blocks do.** -/
theorem walk_mem {W : Finset α} (len : ℕ → ℕ) (path : ℕ → ℕ → α) (h1 : ∀ n, 1 ≤ len n)
    (hmem : ∀ n j, j ≤ len n → path n j ∈ W) (t : ℕ) : walk len path t ∈ W := by
  obtain ⟨h2, h3⟩ := idx_spec len h1 t
  unfold walk
  exact hmem _ _ (by omega)

/-- **The glued walk is a walk.** -/
theorem walk_step (len : ℕ → ℕ) (path : ℕ → ℕ → α) (succ : α → Finset α) (h1 : ∀ n, 1 ≤ len n)
    (hglue : ∀ n, path (n + 1) 0 = path n (len n))
    (hstep : ∀ n j, j < len n → path n (j + 1) ∈ succ (path n j)) (t : ℕ) :
    walk len path (t + 1) ∈ succ (walk len path t) := by
  obtain ⟨h2, h3⟩ := idx_spec len h1 t
  have hj : t - off len (idx len t) < len (idx len t) := by omega
  have e1 : walk len path t = path (idx len t) (t - off len (idx len t)) := by
    have h := walk_eq len path h1 hglue (n := idx len t) (j := t - off len (idx len t))
      (le_of_lt hj)
    rw [show off len (idx len t) + (t - off len (idx len t)) = t from by omega] at h
    exact h
  have e2 : walk len path (t + 1) = path (idx len t) (t - off len (idx len t) + 1) := by
    have h := walk_eq len path h1 hglue (n := idx len t) (j := t - off len (idx len t) + 1)
      (by omega)
    rw [show off len (idx len t) + (t - off len (idx len t) + 1) = t + 1 from by omega] at h
    exact h
  rw [e1, e2]
  exact hstep _ _ hj

end Glue

/-!
## The round-robin concatenation

`EGFix` supplies an infinite walk and `EUFix` supplies a discharging path, but neither supplies the
**one** walk that discharges **every** obligation pending anywhere along it. That is this
namespace's business, and it has no counterpart in the `Formula`-side development: there the
fulfilment demand is universal over threads and is proved directly, so no schedule is ever needed.

Two ingredients make it work, and each is load-bearing:

* **Relativized discharge.** The inner reachability must be taken inside the set being contracted
  *and* must land back inside it — `inSet` below. A discharging path that ends outside the set
  strands the walk at a vertex with no continuation, so it does not extend to a fair walk at all.
* **Propagation.** An obligation pending at a vertex is, at the very next step, either delivered or
  still pending with its guard. Without it the conclusion is false: an obligation could lapse
  between being demanded and being scheduled, and a late discharge would not answer an early
  demand.
-/

namespace Fair

variable {α ι : Type*}

/-- **Deliver, and land back inside the set.** The event predicate a *nested* inner reachability
must use: the outer fixpoint's walk may never leave its own set, so the vertex that discharges an
obligation has to be in it. -/
def inSet [DecidableEq α] (W : Finset α) (isE : α → Bool) (w : α) : Bool :=
  isE w && decide (w ∈ W)

theorem inSet_iff [DecidableEq α] (W : Finset α) (isE : α → Bool) (w : α) :
    inSet W isE w = true ↔ isE w = true ∧ w ∈ W := by
  simp [inSet]

theorem inSet_mono [DecidableEq α] {W W' : Finset α} (h : W ⊆ W') (isE : α → Bool) (w : α) :
    inSet W isE w = true → inSet W' isE w = true := by
  rw [inSet_iff, inSet_iff]
  exact fun hw => ⟨hw.1, h hw.2⟩

/-! ### The block sequence

The blocks are indexed by a per-vertex, per-obligation choice of length and path, supplied as plain
functions so that the recursion below is an ordinary definition with equation lemmas rather than a
`let` inside a proof.
-/

/-- **The vertex block `n` begins at**, under a schedule `sch`. -/
def blockStart (L : α → ι → ℕ) (P : α → ι → ℕ → α) (sch : ℕ → ι) (v : α) : ℕ → α
  | 0 => v
  | n + 1 => P (blockStart L P sch v n) (sch n) (L (blockStart L P sch v n) (sch n))

/-- The length of block `n`. -/
def blockLen (L : α → ι → ℕ) (P : α → ι → ℕ → α) (sch : ℕ → ι) (v : α) (n : ℕ) : ℕ :=
  L (blockStart L P sch v n) (sch n)

/-- The path traversed in block `n`. -/
def blockPath (L : α → ι → ℕ) (P : α → ι → ℕ → α) (sch : ℕ → ι) (v : α) (n : ℕ) : ℕ → α :=
  P (blockStart L P sch v n) (sch n)

/-! ### Fairness, at an arbitrary block structure

Stated about an arbitrary walk and an arbitrary sequence of block-start indices, so that the
`Glue`-specific arithmetic is supplied once by the caller rather than entangled with the propagation
argument.
-/

/--
**A late discharge answers an early demand.**

Given a walk, block-start indices that grow at least as fast as their own counter, a schedule that
serves every servable obligation arbitrarily late, and per-block delivery of that block's own
obligation, every obligation pending anywhere on the walk is discharged strictly later — with its
guard at every index in between.
-/
theorem fair_of_blocks {W : Finset α} {succ : α → Finset α} {pend isE isG : ι → α → Bool}
    (f : ℕ → α) (hfW : ∀ k, f k ∈ W) (hfs : ∀ k, f (k + 1) ∈ succ (f k))
    (hprop : ∀ u ∈ W, ∀ w ∈ succ u, w ∈ W → ∀ i : ι, pend i u = true →
      isE i w = true ∨ (isG i w = true ∧ pend i w = true))
    (start : ℕ → ℕ) (hstart_le : ∀ n, n ≤ start n) (sch : ℕ → ι)
    (hsched : ∀ (i : ι) (n : ℕ), (∃ u ∈ W, pend i u = true) → ∃ m, n ≤ m ∧ sch m = i)
    (hblock : ∀ (n : ℕ) (i : ι), sch n = i → pend i (f (start n)) = true →
      ∃ m, start n < m ∧ isE i (f m) = true)
    (k : ℕ) (i : ι) (hpk : pend i (f k) = true) :
    ∃ m, k < m ∧ isE i (f m) = true ∧ ∀ j, k < j → j < m → isG i (f j) = true := by
  -- An obligation not delivered on `(k₀, k₀ + d]` is still pending at `k₀ + d`, guard and all.
  have hcarry : ∀ k0 d : ℕ, pend i (f k0) = true →
      (∀ j, k0 < j → j ≤ k0 + d → isE i (f j) = false) →
      pend i (f (k0 + d)) = true ∧ ∀ j, k0 < j → j ≤ k0 + d → isG i (f j) = true := by
    intro k0 d
    induction d with
    | zero =>
        intro hp _
        exact ⟨by simpa using hp, fun j hj1 hj2 => absurd hj1 (by omega)⟩
    | succ c ih =>
        intro hp hno
        obtain ⟨hpc, hgc⟩ := ih hp (fun j hj1 hj2 => hno j hj1 (by omega))
        have hnext := hprop _ (hfW (k0 + c)) _ (hfs (k0 + c)) (hfW (k0 + c + 1)) i hpc
        have hne : isE i (f (k0 + c + 1)) = false := hno (k0 + c + 1) (by omega) (by omega)
        rcases hnext with he | ⟨hg, hp'⟩
        · rw [he] at hne
          exact absurd hne (by simp)
        · refine ⟨?_, ?_⟩
          · rw [show k0 + (c + 1) = k0 + c + 1 from by omega]
            exact hp'
          · intro j hj1 hj2
            rcases Nat.lt_or_ge j (k0 + c + 1) with hlt | hge
            · exact hgc j hj1 (by omega)
            · rw [show j = k0 + c + 1 from by omega]
              exact hg
  -- Round-robin: the obligation is scheduled at some block whose start is at or past `k`.
  have hsome : ∃ m, k < m ∧ isE i (f m) = true := by
    obtain ⟨n, hn1, hn2⟩ := hsched i k ⟨f k, hfW k, hpk⟩
    have hk : k ≤ start n := le_trans hn1 (hstart_le n)
    by_cases hd : ∃ m, k < m ∧ m ≤ start n ∧ isE i (f m) = true
    · obtain ⟨m, hm1, -, hm3⟩ := hd
      exact ⟨m, hm1, hm3⟩
    · push Not at hd
      have hno : ∀ j, k < j → j ≤ k + (start n - k) → isE i (f j) = false := by
        intro j hj1 hj2
        have hj := hd j hj1 (by omega)
        simpa using hj
      obtain ⟨hpo, -⟩ := hcarry k (start n - k) hpk hno
      rw [show k + (start n - k) = start n from by omega] at hpo
      obtain ⟨m, hm1, hm2⟩ := hblock n i hn2 hpo
      exact ⟨m, by omega, hm2⟩
  -- Take the earliest discharge; the guard then comes from the propagation above.
  obtain ⟨m0, hm01, hm02⟩ := hsome
  have hex : ∃ d : ℕ, isE i (f (k + 1 + d)) = true :=
    ⟨m0 - k - 1, by rw [show k + 1 + (m0 - k - 1) = m0 from by omega]; exact hm02⟩
  refine ⟨k + 1 + Nat.find hex, by omega, Nat.find_spec hex, ?_⟩
  intro j hj1 hj2
  have hno : ∀ j', k < j' → j' ≤ k + Nat.find hex → isE i (f j') = false := by
    intro j' hj1' hj2'
    have hlt : j' - k - 1 < Nat.find hex := by omega
    have hmin := Nat.find_min hex hlt
    rw [show k + 1 + (j' - k - 1) = j' from by omega] at hmin
    simpa using hmin
  obtain ⟨-, hg⟩ := hcarry k (Nat.find hex) hpk hno
  exact hg j hj1 (by omega)

/-! ### One block

Either a discharging path for the scheduled obligation, when it is pending, or a single continuing
step when it is not. In both cases a path of positive length that never leaves `W`, its endpoint
included — which is exactly what `inSet` buys.
-/

theorem exists_block [DecidableEq α] {W : Finset α} {succ : α → Finset α}
    {pend isE isG : ι → α → Bool}
    (hstep : ∀ u ∈ W, ∃ w ∈ succ u, w ∈ W)
    (hdis : ∀ u ∈ W, ∀ i : ι, pend i u = true →
      u ∈ EUFix.lfp W succ (inSet W (isE i)) (isG i))
    {v : α} (hv : v ∈ W) (i : ι) :
    ∃ (l : ℕ) (p : ℕ → α), 0 < l ∧ p 0 = v ∧ (∀ j, j ≤ l → p j ∈ W) ∧
      (∀ j, j < l → p (j + 1) ∈ succ (p j)) ∧
      (pend i v = true → ∃ j, 0 < j ∧ j ≤ l ∧ isE i (p j) = true) := by
  by_cases hp : pend i v = true
  · obtain ⟨m, p, hm, hp0, hpV, hps, hpe, -⟩ :=
      EUFix.exists_path_of_mem_lfp W succ (inSet W (isE i)) (isG i) v (hdis v hv i hp)
    have hend := (inSet_iff W (isE i) (p m)).mp hpe
    refine ⟨m, p, hm, hp0, ?_, hps, fun _ => ⟨m, hm, Nat.le_refl _, hend.1⟩⟩
    intro j hj
    rcases Nat.lt_or_ge j m with hlt | hge
    · exact hpV j hlt
    · rw [show j = m from le_antisymm hj hge]
      exact hend.2
  · obtain ⟨w, hw1, hw2⟩ := hstep v hv
    refine ⟨1, fun j => if j = 0 then v else w, Nat.one_pos, by simp, ?_, ?_, ?_⟩
    · intro j _
      cases j with
      | zero => simpa using hv
      | succ c => simpa using hw2
    · intro j hj
      cases j with
      | zero => simpa using hw1
      | succ c => exact absurd hj (by omega)
    · intro hc
      exact absurd hc hp

/-! ### The fair walk -/

/--
**The round-robin concatenation, at given block data.**

`sch` names the obligation attended to in block `n`, and `hsched` asks only that an obligation which
is pending *somewhere* in `W` be scheduled arbitrarily late. Keeping the schedule a parameter leaves
the modular arithmetic of a concrete round-robin at the call site, where the obligation set is
known, and keeps this proof about the concatenation.
-/
theorem exists_fair_walk_of_blocks {W : Finset α} {succ : α → Finset α}
    {pend isE isG : ι → α → Bool} (L : α → ι → ℕ) (P : α → ι → ℕ → α) (sch : ℕ → ι)
    (hL : ∀ u ∈ W, ∀ i : ι, 0 < L u i)
    (hP0 : ∀ u ∈ W, ∀ i : ι, P u i 0 = u)
    (hPmem : ∀ u ∈ W, ∀ (i : ι) (j : ℕ), j ≤ L u i → P u i j ∈ W)
    (hPstep : ∀ u ∈ W, ∀ (i : ι) (j : ℕ), j < L u i → P u i (j + 1) ∈ succ (P u i j))
    (hPdel : ∀ u ∈ W, ∀ i : ι, pend i u = true →
      ∃ j, 0 < j ∧ j ≤ L u i ∧ isE i (P u i j) = true)
    (hprop : ∀ u ∈ W, ∀ w ∈ succ u, w ∈ W → ∀ i : ι, pend i u = true →
      isE i w = true ∨ (isG i w = true ∧ pend i w = true))
    (hsched : ∀ (i : ι) (n : ℕ), (∃ u ∈ W, pend i u = true) → ∃ m, n ≤ m ∧ sch m = i)
    {v : α} (hv : v ∈ W) :
    ∃ f : ℕ → α, f 0 = v ∧ (∀ k, f k ∈ W) ∧ (∀ k, f (k + 1) ∈ succ (f k)) ∧
      ∀ (k : ℕ) (i : ι), pend i (f k) = true →
        ∃ m, k < m ∧ isE i (f m) = true ∧ ∀ j, k < j → j < m → isG i (f j) = true := by
  have hstW : ∀ n, blockStart L P sch v n ∈ W := by
    intro n
    induction n with
    | zero => exact hv
    | succ c ih =>
        have h := hPmem _ ih (sch c) (L (blockStart L P sch v c) (sch c)) (Nat.le_refl _)
        exact h
  have h1 : ∀ n, 1 ≤ blockLen L P sch v n := fun n => hL _ (hstW n) (sch n)
  have hglue : ∀ n, blockPath L P sch v (n + 1) 0
      = blockPath L P sch v n (blockLen L P sch v n) :=
    fun n => hP0 _ (hstW (n + 1)) (sch (n + 1))
  have hmemW : ∀ t, Glue.walk (blockLen L P sch v) (blockPath L P sch v) t ∈ W :=
    Glue.walk_mem _ _ h1 (fun n j hj => hPmem _ (hstW n) (sch n) j hj)
  have hstepW : ∀ t, Glue.walk (blockLen L P sch v) (blockPath L P sch v) (t + 1) ∈
      succ (Glue.walk (blockLen L P sch v) (blockPath L P sch v) t) :=
    Glue.walk_step _ _ succ h1 hglue (fun n j hj => hPstep _ (hstW n) (sch n) j hj)
  have hzero : Glue.walk (blockLen L P sch v) (blockPath L P sch v) 0 = v := by
    rw [Glue.walk_zero]
    exact hP0 _ hv (sch 0)
  have hstart : ∀ n, Glue.walk (blockLen L P sch v) (blockPath L P sch v)
      (Glue.off (blockLen L P sch v) n) = blockStart L P sch v n := by
    intro n
    have h := Glue.walk_eq (blockLen L P sch v) (blockPath L P sch v) h1 hglue
      (n := n) (j := 0) (Nat.zero_le _)
    rw [Nat.add_zero] at h
    rw [h]
    exact hP0 _ (hstW n) (sch n)
  refine ⟨Glue.walk (blockLen L P sch v) (blockPath L P sch v), hzero, hmemW, hstepW, ?_⟩
  intro k i hpk
  refine fair_of_blocks (W := W) (succ := succ) (pend := pend) (isE := isE) (isG := isG)
    _ hmemW hstepW hprop (Glue.off (blockLen L P sch v))
    (Glue.le_off _ h1) sch hsched ?_ k i hpk
  intro n i' hti hpi
  subst hti
  rw [hstart n] at hpi
  obtain ⟨j, hj0, hj1, hj2⟩ := hPdel _ (hstW n) (sch n) hpi
  refine ⟨Glue.off (blockLen L P sch v) n + j, by omega, ?_⟩
  rw [Glue.walk_eq (blockLen L P sch v) (blockPath L P sch v) h1 hglue (n := n) (j := j) hj1]
  exact hj2

/--
**The round-robin concatenation.**

On a set `W` where every vertex continues inside `W` and every obligation pending at a vertex can be
discharged without leaving `W`, one infinite walk from any vertex discharges **every** obligation
pending anywhere along it, guard included.
-/
theorem exists_fair_walk [DecidableEq α] {W : Finset α} {succ : α → Finset α}
    {pend isE isG : ι → α → Bool} (sch : ℕ → ι)
    (hstep : ∀ u ∈ W, ∃ w ∈ succ u, w ∈ W)
    (hdis : ∀ u ∈ W, ∀ i : ι, pend i u = true →
      u ∈ EUFix.lfp W succ (inSet W (isE i)) (isG i))
    (hprop : ∀ u ∈ W, ∀ w ∈ succ u, w ∈ W → ∀ i : ι, pend i u = true →
      isE i w = true ∨ (isG i w = true ∧ pend i w = true))
    (hsched : ∀ (i : ι) (n : ℕ), (∃ u ∈ W, pend i u = true) → ∃ m, n ≤ m ∧ sch m = i)
    {v : α} (hv : v ∈ W) :
    ∃ f : ℕ → α, f 0 = v ∧ (∀ k, f k ∈ W) ∧ (∀ k, f (k + 1) ∈ succ (f k)) ∧
      ∀ (k : ℕ) (i : ι), pend i (f k) = true →
        ∃ m, k < m ∧ isE i (f m) = true ∧ ∀ j, k < j → j < m → isG i (f j) = true := by
  classical
  have hblk : ∀ (u : α) (i : ι), ∃ (l : ℕ) (p : ℕ → α), u ∈ W →
      (0 < l ∧ p 0 = u ∧ (∀ j, j ≤ l → p j ∈ W) ∧ (∀ j, j < l → p (j + 1) ∈ succ (p j)) ∧
        (pend i u = true → ∃ j, 0 < j ∧ j ≤ l ∧ isE i (p j) = true)) := by
    intro u i
    by_cases hu : u ∈ W
    · obtain ⟨l, p, hlp⟩ := exists_block hstep hdis hu i
      exact ⟨l, p, fun _ => hlp⟩
    · exact ⟨1, fun _ => u, fun hc => absurd hc hu⟩
  choose L P hLP using hblk
  exact exists_fair_walk_of_blocks L P sch
    (fun u hu i => (hLP u i hu).1)
    (fun u hu i => (hLP u i hu).2.1)
    (fun u hu i j hj => (hLP u i hu).2.2.1 j hj)
    (fun u hu i j hj => (hLP u i hu).2.2.2.1 j hj)
    (fun u hu i hp => (hLP u i hu).2.2.2.2 hp)
    hprop hsched hv

end Fair

end FormalSystem.Metalogic.Decidability
