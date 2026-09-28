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

end SharingSkeleton

end FormalSystem.Metalogic.Decidability
