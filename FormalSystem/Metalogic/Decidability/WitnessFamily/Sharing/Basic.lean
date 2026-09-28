/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Basic
import Mathlib.Data.Fintype.Pi

/-!
# State-Sharing Witness Families

A `WitnessFamily` presents a model whose task relation is **functional**: from a lasso index and
a time there is exactly one successor, namely the same lasso one step later. That is what makes
`ShiftSet.total_eq_orbit` true — every world history of the presented frame is one of the lasso
orbits — and it is also what makes the device blind to the stability modal, since
`states_eq_of_deterministic` collapses `⊡` to the identity on a deterministic frame.

A `SharingWitnessFamily` adds, on top of the same five exported fields, a **per-time equivalence
on lasso indices**: at time `u`, indices `i` and `j` may name the *same* world state. Two lassos
that share a state at `u` let a history cross from one to the other there, so the task relation
of the presented frame branches and the histories are no longer the lasso orbits.

## The deterministic device is untouched

Nothing in this directory edits `Basic.lean`, `Predicates.lean`, `Std.lean`, `Agreement.lean` or
`Decide.lean`, and nothing edits `Semantics/ShiftSet.lean`. The branching device is an
*addition*: `Sharing/Specialize.lean` recovers the deterministic one as the instance where every
representative map is the identity, so `share u i j ↔ i = j`.

## `share` is the kernel of a map, not a relation field

The sharing datum could have been three lists of *relations* on `Fin |lassos|` together with a
proof that each is an equivalence. It is instead three lists of **representative maps**
`Fin |lassos| → Fin |lassos|`, with

```
share u i j  :=  rep u i = rep u j
```

Two consequences, both deliberate:

* `share u` is an equivalence relation *for free* — it is the kernel of a function — so
  `share_refl`, `share_symm` and `share_trans` are `rfl`, `Eq.symm` and `Eq.trans` and the
  structure carries no `share_equiv` field to discharge.
* The datum decodes through `Periodic.unrollOf`, exactly as the labels do, so the leftward and
  rightward periodicities are instantiations of `Periodic.unrollOf_sub_back_length` and
  `Periodic.unrollOf_add_fwd_length` with no new arithmetic, and the window reduction that makes
  the label conditions decidable applies to the sharing conditions by the same argument.

The out-of-range default of the decoding is the identity map, so outside the three encoded
segments `share` degenerates to equality — the deterministic reading — rather than to an
arbitrary collapse.

`rep_idem` is not needed for the equivalence laws; it is what makes the decoded map an honest
*choice of representatives* (`rep u i` is itself `share u`-equivalent to `i`), which is what the
quotient carrier and the specialization consume.

## Field names are still an export contract

`back`, `mid`, `fwd`, `bx` and `lassos` are inherited from `WitnessFamily`, not re-declared, so
the model checker's JSON export contract is unchanged. `repBack`, `repMid` and `repFwd` extend
it additively.

## Main Definitions

- `SharingWitnessFamily` — a witness family plus three periodic segments of representative maps
- `SharingWitnessFamily.rep` — the decoded bi-infinite representative map
- `SharingWitnessFamily.share` — the per-time equivalence, as the kernel of `rep`

## Main Results

- `SharingWitnessFamily.share_refl` / `share_symm` / `share_trans` — the equivalence laws
- `SharingWitnessFamily.rep_sub_back_length` / `rep_add_fwd_length` — the two periodicities
- `SharingWitnessFamily.rep_idem'` — the decoded map is idempotent
- `SharingWitnessFamily.decidableShare` — `share` is decidable
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/--
The `Inhabited` instance the representative-map decoding runs at: out of range, the identity.

Declared as a plain `abbrev` rather than an `instance`, so it never competes with
`Pi.instInhabited` during synthesis; every use site passes it explicitly with `@`.
-/
abbrev repIdInhabited (n : ℕ) : Inhabited (Fin n → Fin n) := ⟨id⟩

/--
A witness family extended by a periodic, per-time equivalence on lasso indices.

The equivalence is encoded as three segments of **representative maps** decoded by
`Periodic.unrollOf`; see this module's header for why maps rather than relations. The parent's
five fields are an export contract and are inherited, not re-declared.
-/
structure SharingWitnessFamily (Γ Del : Context) extends WitnessFamily Γ Del where
  /-- Representative maps for the leftward cycle, indexed left-to-right in time. -/
  repBack : List (Fin lassos.length → Fin lassos.length)
  /-- Representative maps for the finite window `[0, |repMid|)`. -/
  repMid : List (Fin lassos.length → Fin lassos.length)
  /-- Representative maps for the rightward cycle, indexed left-to-right in time. -/
  repFwd : List (Fin lassos.length → Fin lassos.length)
  /-- The leftward cycle is non-empty, so leftward decoding is periodic. -/
  repBack_ne : repBack ≠ []
  /-- The rightward cycle is non-empty, so rightward decoding is periodic. -/
  repFwd_ne : repFwd ≠ []
  /-- Every listed map is idempotent, so it is a choice of class representatives. -/
  rep_idem : ∀ f ∈ repBack ++ repMid ++ repFwd, ∀ i, f (f i) = f i

namespace SharingWitnessFamily

variable {Γ Del : Context}

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
def rep (S : SharingWitnessFamily Γ Del) (u : ℤ) :
    Fin S.lassos.length → Fin S.lassos.length :=
  @Periodic.unrollOf _ (repIdInhabited _) S.repBack S.repMid S.repFwd u

theorem rep_def (S : SharingWitnessFamily Γ Del) (u : ℤ) :
    S.rep u = @Periodic.unrollOf _ (repIdInhabited _) S.repBack S.repMid S.repFwd u := rfl

/-- The backward representative-cycle length, as an integer. -/
abbrev nbr (S : SharingWitnessFamily Γ Del) : ℤ := (S.repBack.length : ℤ)

/-- The representative-window length, as an integer. -/
abbrev nmr (S : SharingWitnessFamily Γ Del) : ℤ := (S.repMid.length : ℤ)

/-- The forward representative-cycle length, as an integer. -/
abbrev nfr (S : SharingWitnessFamily Γ Del) : ℤ := (S.repFwd.length : ℤ)

theorem nbr_pos (S : SharingWitnessFamily Γ Del) : 0 < S.nbr :=
  Periodic.length_pos_int S.repBack_ne

theorem nfr_pos (S : SharingWitnessFamily Γ Del) : 0 < S.nfr :=
  Periodic.length_pos_int S.repFwd_ne

theorem nmr_nonneg (S : SharingWitnessFamily Γ Del) : 0 ≤ S.nmr := Int.natCast_nonneg _

/-- **Leftward periodicity.** Strictly left of the origin the representatives have period
`|repBack|`. Instantiated from `Periodic.unrollOf_sub_back_length`; no new arithmetic. -/
theorem rep_sub_back_length (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u < 0) :
    S.rep (u - S.nbr) = S.rep u :=
  @Periodic.unrollOf_sub_back_length _ (repIdInhabited _)
    S.repBack S.repMid S.repFwd S.repBack_ne u hu

/-- **Rightward periodicity.** At or past `|repMid|` the representatives have period `|repFwd|`.
Instantiated from `Periodic.unrollOf_add_fwd_length`; no new arithmetic. -/
theorem rep_add_fwd_length (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : S.nmr ≤ u) :
    S.rep (u + S.nfr) = S.rep u :=
  @Periodic.unrollOf_add_fwd_length _ (repIdInhabited _)
    S.repBack S.repMid S.repFwd S.repFwd_ne u hu

/--
**Two lasso indices name the same world state at time `u`.**

The kernel of `rep u`, so an equivalence relation with nothing to prove.
-/
def share (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) : Prop :=
  S.rep u i = S.rep u j

theorem share_def (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.share u i j ↔ S.rep u i = S.rep u j := Iff.rfl

@[refl]
theorem share_refl (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.share u i i := rfl

theorem share_symm {S : SharingWitnessFamily Γ Del} {u : ℤ} {i j : Fin S.lassos.length}
    (h : S.share u i j) : S.share u j i := h.symm

theorem share_trans {S : SharingWitnessFamily Γ Del} {u : ℤ} {i j k : Fin S.lassos.length}
    (hij : S.share u i j) (hjk : S.share u j k) : S.share u i k := hij.trans hjk

/-- Sharing is periodic leftward, with the representatives. -/
theorem share_sub_back_length (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u < 0)
    (i j : Fin S.lassos.length) : S.share (u - S.nbr) i j ↔ S.share u i j := by
  simp only [share, S.rep_sub_back_length hu]

/-- Sharing is periodic rightward, with the representatives. -/
theorem share_add_fwd_length (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : S.nmr ≤ u)
    (i j : Fin S.lassos.length) : S.share (u + S.nfr) i j ↔ S.share u i j := by
  simp only [share, S.rep_add_fwd_length hu]

/-- The decoded map is either one of the listed maps or the identity. -/
theorem rep_mem_or_id (S : SharingWitnessFamily Γ Del) (u : ℤ) :
    S.rep u ∈ S.repBack ++ S.repMid ++ S.repFwd ∨ S.rep u = id :=
  unrollOf_mem_or_default (repIdInhabited _) S.repBack S.repMid S.repFwd u

/-- **The decoded map is idempotent**, so `rep u` is a genuine choice of representatives. -/
theorem rep_idem' (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.rep u (S.rep u i) = S.rep u i := by
  rcases S.rep_mem_or_id u with h | h
  · exact S.rep_idem _ h i
  · rw [h]; rfl

/-- Every index shares its own representative. -/
theorem share_rep (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.share u i (S.rep u i) := (S.rep_idem' u i).symm

/-- Sharing is exactly having the same representative. -/
theorem share_iff_rep_eq (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.share u i j ↔ S.rep u i = S.rep u j := Iff.rfl

instance decidableShare (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    Decidable (S.share u i j) :=
  inferInstanceAs (Decidable (S.rep u i = S.rep u j))

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
