/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Periodic
import Mathlib.Data.Fintype.Pi

/-!
# The Label-Free Branching Substrate

`SharingWitnessFamily` carries two independent data: a **label row** — the lassos, their decoded
`Finset Formula` labels, and the box guess — and a **periodic representative structure** — three
segments of maps `Fin n → Fin n` whose decoding says which lasso indices name the same world
state at each time.

Every construction the branching device is built from stands on the second datum alone. The
per-time equivalence `share`, the threads that step across it, the quotient frame over `intOrder`
and the world histories that frame admits are all functions of the representative structure; not
one of them inspects a label, a formula, or the box guess.

## The measurement that licenses this module

`Sharing/{Basic,Thread,Frame,Histories}.lean` together are 1,065 lines, and across all four the
tokens `Formula`, `.L `, `.lab` and `.bx` occur **zero** times. The substrate is not
*approximately* language-agnostic; it is exactly language-agnostic, and the `Formula` indexing it
used to carry was incidental.

`SharingSkeleton` is that datum on its own. A certificate indexed by any formula type projects
onto it and inherits the whole branching theory rather than re-proving it, and
`SharingWitnessFamily` becomes one such certificate: `Sharing/Basic.lean` and its three siblings
keep every name they exported, at its original statement, as a thin delegation through
`SharingWitnessFamily.skeleton`.

## `share` is the kernel of a map, not a relation field

The sharing datum could have been three lists of *relations* on `Fin n` together with a proof
that each is an equivalence. It is instead three lists of **representative maps**
`Fin n → Fin n`, with

```
share u i j  :=  rep u i = rep u j
```

Two consequences, both deliberate:

* `share u` is an equivalence relation *for free* — it is the kernel of a function — so
  `share_refl`, `share_symm` and `share_trans` are `rfl`, `Eq.symm` and `Eq.trans` and the
  structure carries no `share_equiv` field to discharge.
* The datum decodes through `Periodic.unrollOf`, exactly as labels do, so the leftward and
  rightward periodicities are instantiations of `Periodic.unrollOf_sub_back_length` and
  `Periodic.unrollOf_add_fwd_length` with no new arithmetic.

The out-of-range default of the decoding is the identity map, so outside the three encoded
segments `share` degenerates to equality — the deterministic reading — rather than to an
arbitrary collapse.

`rep_idem` is not needed for the equivalence laws; it is what makes the decoded map an honest
*choice of representatives* (`rep u i` is itself `share u`-equivalent to `i`), which is what the
quotient carrier and the specialization consume.

## Main Definitions

- `SharingSkeleton` — three periodic segments of representative maps on `Fin n`
- `SharingSkeleton.rep` — the decoded bi-infinite representative map
- `SharingSkeleton.share` — the per-time equivalence, as the kernel of `rep`

## Main Results

- `SharingSkeleton.share_refl` / `share_symm` / `share_trans` — the equivalence laws
- `SharingSkeleton.rep_sub_back_length` / `rep_add_fwd_length` — the two periodicities
- `SharingSkeleton.rep_idem'` — the decoded map is idempotent
- `SharingSkeleton.decidableShare` — `share` is decidable
-/

namespace FormalSystem.Metalogic.Decidability

/--
The `Inhabited` instance the representative-map decoding runs at: out of range, the identity.

Declared as a plain `abbrev` rather than an `instance`, so it never competes with
`Pi.instInhabited` during synthesis; every use site passes it explicitly with `@`.
-/
abbrev repIdInhabited (n : ℕ) : Inhabited (Fin n → Fin n) := ⟨id⟩

/--
**The label-free branching substrate.**

A count of indices together with three periodic segments of representative maps on them. This is
the whole datum the branching device stands on: the per-time equivalence `share`, the threads,
the quotient frame and its histories are all functions of it, and none of them inspects a label
or a formula.
-/
structure SharingSkeleton where
  /-- The number of indices. -/
  n : ℕ
  /-- There is at least one index. -/
  n_pos : 0 < n
  /-- Representative maps for the leftward cycle, indexed left-to-right in time. -/
  repBack : List (Fin n → Fin n)
  /-- Representative maps for the finite window `[0, |repMid|)`. -/
  repMid : List (Fin n → Fin n)
  /-- Representative maps for the rightward cycle, indexed left-to-right in time. -/
  repFwd : List (Fin n → Fin n)
  /-- The leftward cycle is non-empty, so leftward decoding is periodic. -/
  repBack_ne : repBack ≠ []
  /-- The rightward cycle is non-empty, so rightward decoding is periodic. -/
  repFwd_ne : repFwd ≠ []
  /-- Every listed map is idempotent, so it is a choice of class representatives. -/
  rep_idem : ∀ f ∈ repBack ++ repMid ++ repFwd, ∀ i, f (f i) = f i

namespace SharingSkeleton

/-- A list lookup with a default either hits the list or returns the default. -/
private theorem getD_mem_or_eq {α : Type*} (l : List α) (d : α) (k : ℕ) :
    l.getD k d ∈ l ∨ l.getD k d = d := by
  rcases lt_or_ge k l.length with hk | hk
  · left
    rw [(List.getElem_eq_getD (l := l) (i := k) (h := hk) d).symm]
    exact List.getElem_mem hk
  · right
    rw [List.getD_eq_getElem?_getD, List.getElem?_eq_none hk]
    rfl

/--
The three-segment decoding returns either a listed value or the out-of-range default.

Stated with the `Inhabited` argument **explicit**, because the decoding here runs at
`repIdInhabited`, which is deliberately not an instance: a `rw [Periodic.unrollOf]` would ask
instance synthesis for it and fail.
-/
private theorem unrollOf_mem_or_default {α : Type*} (inst : Inhabited α)
    (back mid fwd : List α) (t : ℤ) :
    @Periodic.unrollOf α inst back mid fwd t ∈ back ++ mid ++ fwd ∨
      @Periodic.unrollOf α inst back mid fwd t = @default α inst := by
  have hun : @Periodic.unrollOf α inst back mid fwd t
      = if t < 0 then back.getD ((t % (back.length : ℤ)).toNat) (@default α inst)
        else if t < (mid.length : ℤ) then mid.getD t.toNat (@default α inst)
        else fwd.getD (((t - (mid.length : ℤ)) % (fwd.length : ℤ)).toNat) (@default α inst) :=
    rfl
  rw [hun]
  split
  · rcases getD_mem_or_eq back (@default α inst) ((t % (back.length : ℤ)).toNat) with h | h
    · exact Or.inl (List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inl h))))
    · exact Or.inr h
  · split
    · rcases getD_mem_or_eq mid (@default α inst) t.toNat with h | h
      · exact Or.inl (List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inr h))))
      · exact Or.inr h
    · rcases getD_mem_or_eq fwd (@default α inst)
        (((t - (mid.length : ℤ)) % (fwd.length : ℤ)).toNat) with h | h
      · exact Or.inl (List.mem_append.mpr (Or.inr h))
      · exact Or.inr h

/-- The decoded bi-infinite representative map, by the same three-segment scheme that decodes
the labels. Out of range it is the identity. -/
def rep (K : SharingSkeleton) (u : ℤ) : Fin K.n → Fin K.n :=
  @Periodic.unrollOf _ (repIdInhabited _) K.repBack K.repMid K.repFwd u

theorem rep_def (K : SharingSkeleton) (u : ℤ) :
    K.rep u = @Periodic.unrollOf _ (repIdInhabited _) K.repBack K.repMid K.repFwd u := rfl

/-- The backward representative-cycle length, as an integer. -/
abbrev nbr (K : SharingSkeleton) : ℤ := (K.repBack.length : ℤ)

/-- The representative-window length, as an integer. -/
abbrev nmr (K : SharingSkeleton) : ℤ := (K.repMid.length : ℤ)

/-- The forward representative-cycle length, as an integer. -/
abbrev nfr (K : SharingSkeleton) : ℤ := (K.repFwd.length : ℤ)

theorem nbr_pos (K : SharingSkeleton) : 0 < K.nbr :=
  Periodic.length_pos_int K.repBack_ne

theorem nfr_pos (K : SharingSkeleton) : 0 < K.nfr :=
  Periodic.length_pos_int K.repFwd_ne

theorem nmr_nonneg (K : SharingSkeleton) : 0 ≤ K.nmr := Int.natCast_nonneg _

/-- **Leftward periodicity.** Strictly left of the origin the representatives have period
`|repBack|`. Instantiated from `Periodic.unrollOf_sub_back_length`; no new arithmetic. -/
theorem rep_sub_back_length (K : SharingSkeleton) {u : ℤ} (hu : u < 0) :
    K.rep (u - K.nbr) = K.rep u :=
  @Periodic.unrollOf_sub_back_length _ (repIdInhabited _)
    K.repBack K.repMid K.repFwd K.repBack_ne u hu

/-- **Rightward periodicity.** At or past `|repMid|` the representatives have period `|repFwd|`.
Instantiated from `Periodic.unrollOf_add_fwd_length`; no new arithmetic. -/
theorem rep_add_fwd_length (K : SharingSkeleton) {u : ℤ} (hu : K.nmr ≤ u) :
    K.rep (u + K.nfr) = K.rep u :=
  @Periodic.unrollOf_add_fwd_length _ (repIdInhabited _)
    K.repBack K.repMid K.repFwd K.repFwd_ne u hu

/--
**Two indices name the same world state at time `u`.**

The kernel of `rep u`, so an equivalence relation with nothing to prove.
-/
def share (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) : Prop :=
  K.rep u i = K.rep u j

theorem share_def (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.share u i j ↔ K.rep u i = K.rep u j := Iff.rfl

@[refl]
theorem share_refl (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) : K.share u i i := rfl

theorem share_symm {K : SharingSkeleton} {u : ℤ} {i j : Fin K.n}
    (h : K.share u i j) : K.share u j i := h.symm

theorem share_trans {K : SharingSkeleton} {u : ℤ} {i j k : Fin K.n}
    (hij : K.share u i j) (hjk : K.share u j k) : K.share u i k := hij.trans hjk

/-- Sharing is periodic leftward, with the representatives. -/
theorem share_sub_back_length (K : SharingSkeleton) {u : ℤ} (hu : u < 0) (i j : Fin K.n) :
    K.share (u - K.nbr) i j ↔ K.share u i j := by
  simp only [share, K.rep_sub_back_length hu]

/-- Sharing is periodic rightward, with the representatives. -/
theorem share_add_fwd_length (K : SharingSkeleton) {u : ℤ} (hu : K.nmr ≤ u) (i j : Fin K.n) :
    K.share (u + K.nfr) i j ↔ K.share u i j := by
  simp only [share, K.rep_add_fwd_length hu]

/-- The decoded map is either one of the listed maps or the identity. -/
theorem rep_mem_or_id (K : SharingSkeleton) (u : ℤ) :
    K.rep u ∈ K.repBack ++ K.repMid ++ K.repFwd ∨ K.rep u = id :=
  unrollOf_mem_or_default (repIdInhabited _) K.repBack K.repMid K.repFwd u

/-- **The decoded map is idempotent**, so `rep u` is a genuine choice of representatives. -/
theorem rep_idem' (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) :
    K.rep u (K.rep u i) = K.rep u i := by
  rcases K.rep_mem_or_id u with h | h
  · exact K.rep_idem _ h i
  · rw [h]; rfl

/-- Every index shares its own representative. -/
theorem share_rep (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) : K.share u i (K.rep u i) :=
  (K.rep_idem' u i).symm

/-- Sharing is exactly having the same representative. -/
theorem share_iff_rep_eq (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.share u i j ↔ K.rep u i = K.rep u j := Iff.rfl

instance decidableShare (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    Decidable (K.share u i j) :=
  inferInstanceAs (Decidable (K.rep u i = K.rep u j))

/-! ## Threads: the branching analogue of a lasso orbit

On the deterministic device a world history *is* a lasso, shifted. Once two indices may name the
same state at a time, a history can cross from one to the other there, and the object that
replaces "a lasso" is a **thread**: a bi-infinite choice of index that only ever changes across a
shared state.

Three relations, and why all three are needed:

* `Thread` — the bi-infinite object. Its step field is the *tight* one,
  `share (u+1) (idx u) (idx (u+1))`: the thread stays on index `idx u` from `u` to `u + 1` and
  then re-names the state it lands in. This is not a loss of generality, because a history's
  index at `u` may be chosen *knowing* the step it is about to take.
* `Step` — the *class-level* one-step relation, `∃ i', share u i i' ∧ share (u+1) i' j`. This is
  the relation the frame's task relation is built from, and the existential is exactly the
  branching: the state `⟦(i,u)⟧` has one successor for each index passing through it, not one
  successor full stop.
* `ReachN` — `n` iterated `Step`s, with `ReachN 0` the sharing relation itself. This is the
  finite-duration reachability the frame's `PosRel` quantifies over.

`Step` is invariant under `share u` on the left and `share (u+1)` on the right, and `ReachN n`
under `share u` and `share (u + n)`; those four congruences are what let the whole development
descend to the quotient carrier, with no compatibility field added to the structure.

**What is deliberately absent: a thread time-shift.** A thread cannot be time-shifted. `share` is
decoded from three *periodic segments* indexed by absolute time, so `share u` and `share (u + d)`
are different relations for a general `d`, and `fun u => θ.idx (u + d)` fails the step field.
Time offsets therefore live in the *history's* parametrization — `total_eq_thread` carries an
explicit `s : ℤ` and reads `θ.idx (s + t)` at time `s + t` — never in the thread.
-/

/-- Regrouping a successor time offset, used wherever an induction on the step count meets the
integer time coordinate. -/
private theorem int_succ_shift (u : ℤ) (m : ℕ) :
    u + ((m + 1 : ℕ) : ℤ) = u + 1 + (m : ℤ) := by
  omega

/-- Erasing a zero step count from a time offset. -/
private theorem int_zero_shift (u : ℤ) : u + ((0 : ℕ) : ℤ) = u := by
  omega

/--
**A bi-infinite choice of index, stepping only across shared states.**

The step field is the tight form: the thread rides index `idx u` from `u` to `u + 1`, and the
state it arrives at, `⟦(idx u, u+1)⟧`, is the state `⟦(idx (u+1), u+1)⟧` it is recorded as
holding. Threads replace lasso orbits as the objects the frame's histories are traces of.
-/
structure Thread (K : SharingSkeleton) where
  /-- The index held at each time. -/
  idx : ℤ → Fin K.n
  /-- Consecutive indices name the same world state at the later time. -/
  step : ∀ u : ℤ, K.share (u + 1) (idx u) (idx (u + 1))

namespace Thread

variable {K : SharingSkeleton}

/-- Threads are determined by their index function. -/
@[ext]
theorem ext {θ η : K.Thread} (h : ∀ u, θ.idx u = η.idx u) : θ = η := by
  cases θ with
  | mk i₁ s₁ =>
    cases η with
    | mk i₂ s₂ =>
      have hi : i₁ = i₂ := funext h
      subst hi
      rfl

end Thread

/-- The constant thread at index `i`: staying on one index forever is always legitimate. -/
def Thread.const (K : SharingSkeleton) (i : Fin K.n) : K.Thread where
  idx := fun _ => i
  step := fun u => K.share_refl (u + 1) i

instance instNonemptyThread (K : SharingSkeleton) : Nonempty K.Thread :=
  ⟨Thread.const K ⟨0, K.n_pos⟩⟩

@[simp]
theorem Thread.const_idx (K : SharingSkeleton) (i : Fin K.n) (u : ℤ) :
    (Thread.const K i).idx u = i := rfl

/--
**The class-level one-step relation.**

From index `i` at time `u`, a history may continue along *any* index `i'` naming the same state
at `u`, and then re-name the state it lands in at `u + 1`. The existential over `i'` is the
branching: on the deterministic device it collapses to `i' = i` and `Step u i j ↔ j = i`.
-/
def Step (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) : Prop :=
  ∃ i', K.share u i i' ∧ K.share (u + 1) i' j

theorem step_of_share_succ {K : SharingSkeleton} {u : ℤ} {i j : Fin K.n}
    (h : K.share (u + 1) i j) : K.Step u i j :=
  ⟨i, K.share_refl u i, h⟩

theorem step_refl (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) : K.Step u i i :=
  step_of_share_succ (K.share_refl (u + 1) i)

/-- `Step` only sees the `share u`-class of its source. -/
theorem step_congr_left {K : SharingSkeleton} {u : ℤ} {i i' j : Fin K.n}
    (h : K.share u i' i) (hs : K.Step u i j) : K.Step u i' j := by
  obtain ⟨k, hk, hkj⟩ := hs
  exact ⟨k, SharingSkeleton.share_trans h hk, hkj⟩

/-- `Step` only sees the `share (u+1)`-class of its target. -/
theorem step_congr_right {K : SharingSkeleton} {u : ℤ} {i j j' : Fin K.n}
    (hs : K.Step u i j) (h : K.share (u + 1) j j') : K.Step u i j' := by
  obtain ⟨k, hk, hkj⟩ := hs
  exact ⟨k, hk, SharingSkeleton.share_trans hkj h⟩

instance decidableStep (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    Decidable (K.Step u i j) :=
  inferInstanceAs (Decidable (∃ i', K.share u i i' ∧ K.share (u + 1) i' j))

/--
**`n`-step reachability.** At `n = 0` it is the sharing relation — same time, same state — and
each successor step is one `Step`.
-/
def ReachN (K : SharingSkeleton) : ℕ → ℤ → Fin K.n → Fin K.n → Prop
  | 0, u, i, j => K.share u i j
  | (n + 1), u, i, j => ∃ k, K.Step u i k ∧ ReachN K n (u + 1) k j

@[simp]
theorem reachN_zero (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.ReachN 0 u i j ↔ K.share u i j := Iff.rfl

theorem reachN_succ (K : SharingSkeleton) (n : ℕ) (u : ℤ) (i j : Fin K.n) :
    K.ReachN (n + 1) u i j ↔ ∃ k, K.Step u i k ∧ K.ReachN n (u + 1) k j := Iff.rfl

/-- Reachability only sees the `share u`-class of its source. -/
theorem reachN_congr_left {K : SharingSkeleton} {n : ℕ} {u : ℤ} {i i' j : Fin K.n}
    (h : K.share u i' i) (hr : K.ReachN n u i j) : K.ReachN n u i' j := by
  cases n with
  | zero => exact SharingSkeleton.share_trans h hr
  | succ m =>
    obtain ⟨k, hk, hrest⟩ := hr
    exact ⟨k, step_congr_left h hk, hrest⟩

/-- Reachability only sees the `share (u + n)`-class of its target. -/
theorem reachN_congr_right {K : SharingSkeleton} {n : ℕ} {u : ℤ} {i j j' : Fin K.n}
    (hr : K.ReachN n u i j) (h : K.share (u + (n : ℤ)) j j') : K.ReachN n u i j' := by
  induction n generalizing u i with
  | zero =>
    rw [int_zero_shift] at h
    exact SharingSkeleton.share_trans hr h
  | succ m ih =>
    obtain ⟨k, hk, hrest⟩ := hr
    refine ⟨k, hk, ih hrest ?_⟩
    rw [← int_succ_shift]
    exact h

/-- Staying on one index is reachability of every length. -/
theorem reachN_const (K : SharingSkeleton) (n : ℕ) (u : ℤ) (i : Fin K.n) : K.ReachN n u i i := by
  induction n generalizing u with
  | zero => exact K.share_refl u i
  | succ m ih => exact ⟨i, step_refl K u i, ih (u + 1)⟩

/-- One step of reachability is one `Step`. -/
theorem reachN_one (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.ReachN 1 u i j ↔ K.Step u i j := by
  constructor
  · rintro ⟨k, hk, hr⟩
    exact step_congr_right hk hr
  · intro h
    exact ⟨j, h, K.share_refl (u + 1) j⟩

/--
**Concatenation and splitting.** Reachability of length `m + n` factors through an intermediate
state at time `u + m`, in both directions. This is the whole content of the *Compositionality*
discharge for the branching frame.
-/
theorem reachN_add (K : SharingSkeleton) (m n : ℕ) (u : ℤ) (i j : Fin K.n) :
    K.ReachN (m + n) u i j ↔ ∃ k, K.ReachN m u i k ∧ K.ReachN n (u + (m : ℤ)) k j := by
  induction m generalizing u i with
  | zero =>
    rw [Nat.zero_add]
    constructor
    · intro h
      refine ⟨i, K.share_refl u i, ?_⟩
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

instance decidableReachN (K : SharingSkeleton) :
    ∀ (n : ℕ) (u : ℤ) (i j : Fin K.n), Decidable (K.ReachN n u i j)
  | 0, u, i, j => inferInstanceAs (Decidable (K.share u i j))
  | (n + 1), u, i, j =>
      letI : ∀ (v : ℤ) (a b : Fin K.n), Decidable (K.ReachN n v a b) :=
        fun v a b => decidableReachN K n v a b
      inferInstanceAs (Decidable (∃ k, K.Step u i k ∧ K.ReachN n (u + 1) k j))

namespace Thread

variable {K : SharingSkeleton}

/-- A thread's one-step move is a `Step` of the class-level relation. -/
theorem step' (θ : K.Thread) (u : ℤ) : K.Step u (θ.idx u) (θ.idx (u + 1)) :=
  step_of_share_succ (θ.step u)

/-- **A thread realizes reachability between its own positions.** -/
theorem reachN (θ : K.Thread) (n : ℕ) (u : ℤ) :
    K.ReachN n u (θ.idx u) (θ.idx (u + (n : ℤ))) := by
  induction n generalizing u with
  | zero => simpa using K.share_refl u (θ.idx u)
  | succ m ih =>
    refine ⟨θ.idx (u + 1), θ.step' u, ?_⟩
    rw [int_succ_shift]
    exact ih (u + 1)

end Thread

end SharingSkeleton

end FormalSystem.Metalogic.Decidability
