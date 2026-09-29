/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Basic
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Skeleton

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

## The substrate lives on `SharingSkeleton`

The per-time equivalence and everything built on it are **label-free**: not one construction in
this module, `Thread.lean`, `Frame.lean` or `Histories.lean` inspects a formula, a label or the
box guess. That theory therefore lives on `SharingSkeleton` (`Sharing/Skeleton.lean`), and this
module keeps every name it has always exported — `rep`, `share`, the two periodicities, the
equivalence laws, `rep_idem'`, `decidableShare` — at its original statement, as a delegation
through `SharingWitnessFamily.skeleton`. See `Sharing/Skeleton.lean`'s header for why `share` is
the kernel of a map rather than a relation field, and for the measurement that licenses the
split.

## Field names are still an export contract

`back`, `mid`, `fwd`, `bx` and `lassos` are inherited from `WitnessFamily`, not re-declared, so
the model checker's JSON export contract is unchanged. `repBack`, `repMid` and `repFwd` extend
it additively.

## Main Definitions

- `SharingWitnessFamily` — a witness family plus three periodic segments of representative maps
- `SharingWitnessFamily.skeleton` — the label-free substrate the branching theory runs on
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
A witness family extended by a periodic, per-time equivalence on lasso indices.

The equivalence is encoded as three segments of **representative maps** decoded by
`Periodic.unrollOf`; see `Sharing/Skeleton.lean`'s header for why maps rather than relations. The
parent's five fields are an export contract and are inherited, not re-declared.
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
  /-- Succession matrices for the leftward cycle, indexed left-to-right in time. -/
  transBack : List (Fin lassos.length → Fin lassos.length → Bool)
  /-- Succession matrices for the window `[0, |transMid|)`. -/
  transMid : List (Fin lassos.length → Fin lassos.length → Bool)
  /-- Succession matrices for the rightward cycle, indexed left-to-right in time. -/
  transFwd : List (Fin lassos.length → Fin lassos.length → Bool)
  /-- The succession cycles carry the representatives' periods. -/
  transBack_len : transBack.length = repBack.length
  /-- The succession window has the representative window's length. -/
  transMid_len : transMid.length = repMid.length
  /-- The forward succession cycle has the forward representative cycle's period. -/
  transFwd_len : transFwd.length = repFwd.length
  /-- Every listed matrix is reflexive: staying on one index is always a legitimate step. -/
  trans_refl : ∀ r ∈ transBack ++ transMid ++ transFwd, ∀ i, r i i = true
  /-- **Thread lifting**, the well-formedness obligation the fourth datum creates: every state
  path of the frame is tracked by a succession path. -/
  lift : LiftableRaw lassos.length repBack repMid repFwd transBack transMid transFwd

namespace SharingWitnessFamily

variable {Γ Del : Context}

/--
**The family's label-free substrate.**

Everything the branching device is built from — `rep`, `share`, the threads, the quotient frame
and its histories — is a function of this projection alone. The index count is
`lassos.length` definitionally, so `Fin S.lassos.length` and `Fin S.skeleton.n` interchange with
no coercion.
-/
@[reducible]
def skeleton (S : SharingWitnessFamily Γ Del) : SharingSkeleton where
  n := S.lassos.length
  n_pos := S.lassos_length_pos
  repBack := S.repBack
  repMid := S.repMid
  repFwd := S.repFwd
  repBack_ne := S.repBack_ne
  repFwd_ne := S.repFwd_ne
  rep_idem := S.rep_idem
  transBack := S.transBack
  transMid := S.transMid
  transFwd := S.transFwd
  transBack_len := S.transBack_len
  transMid_len := S.transMid_len
  transFwd_len := S.transFwd_len
  trans_refl := S.trans_refl
  lift := S.lift

@[simp]
theorem skeleton_n (S : SharingWitnessFamily Γ Del) : S.skeleton.n = S.lassos.length := rfl

/-- The decoded bi-infinite representative map, by the same three-segment scheme that decodes
the labels. Out of range it is the identity. -/
def rep (S : SharingWitnessFamily Γ Del) (u : ℤ) :
    Fin S.lassos.length → Fin S.lassos.length :=
  S.skeleton.rep u

theorem rep_eq_skeleton (S : SharingWitnessFamily Γ Del) (u : ℤ) : S.rep u = S.skeleton.rep u :=
  rfl

theorem rep_def (S : SharingWitnessFamily Γ Del) (u : ℤ) :
    S.rep u = @Periodic.unrollOf _ (repIdInhabited _) S.repBack S.repMid S.repFwd u := rfl

/-- The backward representative-cycle length, as an integer. -/
abbrev nbr (S : SharingWitnessFamily Γ Del) : ℤ := (S.repBack.length : ℤ)

/-- The representative-window length, as an integer. -/
abbrev nmr (S : SharingWitnessFamily Γ Del) : ℤ := (S.repMid.length : ℤ)

/-- The forward representative-cycle length, as an integer. -/
abbrev nfr (S : SharingWitnessFamily Γ Del) : ℤ := (S.repFwd.length : ℤ)

theorem nbr_pos (S : SharingWitnessFamily Γ Del) : 0 < S.nbr := S.skeleton.nbr_pos

theorem nfr_pos (S : SharingWitnessFamily Γ Del) : 0 < S.nfr := S.skeleton.nfr_pos

theorem nmr_nonneg (S : SharingWitnessFamily Γ Del) : 0 ≤ S.nmr := S.skeleton.nmr_nonneg

/-- **Leftward periodicity.** Strictly left of the origin the representatives have period
`|repBack|`. Instantiated from `Periodic.unrollOf_sub_back_length`; no new arithmetic. -/
theorem rep_sub_back_length (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u < 0) :
    S.rep (u - S.nbr) = S.rep u := S.skeleton.rep_sub_back_length hu

/-- **Rightward periodicity.** At or past `|repMid|` the representatives have period `|repFwd|`.
Instantiated from `Periodic.unrollOf_add_fwd_length`; no new arithmetic. -/
theorem rep_add_fwd_length (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : S.nmr ≤ u) :
    S.rep (u + S.nfr) = S.rep u := S.skeleton.rep_add_fwd_length hu

/--
**Two lasso indices name the same world state at time `u`.**

The kernel of `rep u`, so an equivalence relation with nothing to prove.
-/
def share (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) : Prop :=
  S.skeleton.share u i j

theorem share_eq_skeleton (S : SharingWitnessFamily Γ Del) (u : ℤ)
    (i j : Fin S.lassos.length) : S.share u i j ↔ S.skeleton.share u i j := Iff.rfl

theorem share_def (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.share u i j ↔ S.rep u i = S.rep u j := Iff.rfl

@[refl]
theorem share_refl (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.share u i i := rfl

theorem share_symm {S : SharingWitnessFamily Γ Del} {u : ℤ} {i j : Fin S.lassos.length}
    (h : S.share u i j) : S.share u j i := SharingSkeleton.share_symm h

theorem share_trans {S : SharingWitnessFamily Γ Del} {u : ℤ} {i j k : Fin S.lassos.length}
    (hij : S.share u i j) (hjk : S.share u j k) : S.share u i k :=
  SharingSkeleton.share_trans hij hjk

/-- Sharing is periodic leftward, with the representatives. -/
theorem share_sub_back_length (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u < 0)
    (i j : Fin S.lassos.length) : S.share (u - S.nbr) i j ↔ S.share u i j :=
  S.skeleton.share_sub_back_length hu i j

/-- Sharing is periodic rightward, with the representatives. -/
theorem share_add_fwd_length (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : S.nmr ≤ u)
    (i j : Fin S.lassos.length) : S.share (u + S.nfr) i j ↔ S.share u i j :=
  S.skeleton.share_add_fwd_length hu i j

/-- The decoded map is either one of the listed maps or the identity. -/
theorem rep_mem_or_id (S : SharingWitnessFamily Γ Del) (u : ℤ) :
    S.rep u ∈ S.repBack ++ S.repMid ++ S.repFwd ∨ S.rep u = id := S.skeleton.rep_mem_or_id u

/-- **The decoded map is idempotent**, so `rep u` is a genuine choice of representatives. -/
theorem rep_idem' (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.rep u (S.rep u i) = S.rep u i := S.skeleton.rep_idem' u i

/-- Every index shares its own representative. -/
theorem share_rep (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.share u i (S.rep u i) := S.skeleton.share_rep u i

/-- Sharing is exactly having the same representative. -/
theorem share_iff_rep_eq (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.share u i j ↔ S.rep u i = S.rep u j := Iff.rfl

/-! ## The fourth periodic datum, re-exported -/

/-- The decoded bi-infinite succession matrix. Out of range it is the identity relation. -/
def transRaw (S : SharingWitnessFamily Γ Del) (u : ℤ) :
    Fin S.lassos.length → Fin S.lassos.length → Bool :=
  S.skeleton.transRaw u

theorem transRaw_eq_skeleton (S : SharingWitnessFamily Γ Del) (u : ℤ) :
    S.transRaw u = S.skeleton.transRaw u := rfl

theorem transRaw_def (S : SharingWitnessFamily Γ Del) (u : ℤ) :
    S.transRaw u
      = @Periodic.unrollOf _ (transEqInhabited _) S.transBack S.transMid S.transFwd u :=
  rfl

/-- **Succession, arrival-pruned**, at the family's own `share`. -/
def trans (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) : Prop :=
  S.skeleton.trans u i j

theorem trans_eq_skeleton (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.trans u i j ↔ S.skeleton.trans u i j := Iff.rfl

theorem trans_def (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.trans u i j ↔ (S.transRaw u i j = true ∧ S.share (u + 1) i j) := Iff.rfl

theorem transRaw_refl (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.transRaw u i i = true := S.skeleton.transRaw_refl u i

@[refl]
theorem trans_refl' (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.trans u i i :=
  S.skeleton.trans_refl' u i

theorem share_succ_of_trans {S : SharingWitnessFamily Γ Del} {u : ℤ} {i j : Fin S.lassos.length}
    (h : S.trans u i j) : S.share (u + 1) i j := h.2

instance decidableTrans (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    Decidable (S.trans u i j) := inferInstanceAs (Decidable (S.skeleton.trans u i j))

/-- **Leftward periodicity of succession**, at the representatives' own period. -/
theorem transRaw_sub_back_length (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : u < 0) :
    S.transRaw (u - S.nbr) = S.transRaw u := S.skeleton.transRaw_sub_back_length hu

/-- **Rightward periodicity of succession**, at the representatives' own period. -/
theorem transRaw_add_fwd_length (S : SharingWitnessFamily Γ Del) {u : ℤ} (hu : S.nmr ≤ u) :
    S.transRaw (u + S.nfr) = S.transRaw u := S.skeleton.transRaw_add_fwd_length hu

instance decidableShare (S : SharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    Decidable (S.share u i j) :=
  inferInstanceAs (Decidable (S.rep u i = S.rep u j))

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
