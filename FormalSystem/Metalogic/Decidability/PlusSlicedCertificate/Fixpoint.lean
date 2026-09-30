/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Finset.Card
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

end FormalSystem.Metalogic.Decidability
