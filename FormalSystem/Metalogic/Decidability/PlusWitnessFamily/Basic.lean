/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Closure
import FormalSystem.Metalogic.Decidability.BiLasso.Periodic
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Skeleton

/-!
# The L⁺ Witness Family

`WitnessFamily` (`WitnessFamily/Basic.lean`) is monomorphic in `Formula` at every level:
`Context := List Formula`, `closureOf : Context → Finset Formula`, and the labels are
`Finset Formula`. `Formula` has six constructors and no stability modal, so the certificate it
indexes cannot state a condition about `⊡`.

This module is the L⁺-indexed parallel: the same three-segment periodic decoding, the same box
guess, the same main-lasso convention, with `Formula` replaced by `PlusFormula` and `closureOf`
by `plusClosureOf`. Nothing here is a generalization of the `Formula` side — the two inductives
share no supertype — and nothing here modifies it.

## The shipping export contract is untouched

`WitnessFamily`'s fields `bx`, `lassos`, and `LabelledLasso`'s `back`, `mid`, `fwd` are the model
checker's JSON export contract. This module adds no field to them and changes none of them: the
L⁺ certificate is a **separate, parallel** export that a consumer adopts only when it wants `⊡`.
The deterministic bi-lasso certificate keeps working byte-identically.

## Why the lasso layer is a transcription rather than a generalization

`lab`, the two periodicities and `lab_subset` are already language-agnostic in *substance* —
they are `Periodic.unrollOf` instantiated at a `Finset` of something, plus the observation that
the out-of-range default `∅` is a subset of anything. They are transcribed rather than
abstracted because abstracting them would mean putting a type parameter on `LabelledLasso`, and
that would change the shipping structure. The branching substrate, which is the expensive part,
*is* shared: see `PlusSharingWitnessFamily.skeleton`.

## Main Definitions

- `PlusLabelledLasso` — three periodic segments of `Finset PlusFormula` labels
- `PlusLabelledLasso.lab` — the decoded bi-infinite label function
- `PlusWitnessFamily` — a box guess plus a non-empty list of L⁺ labelled lassos
- `PlusWitnessFamily.L` — the family's label function, indexed by lasso and time

## Main Results

- `PlusLabelledLasso.lab_sub_back_length` / `lab_add_fwd_length` — the two periodicities
- `PlusLabelledLasso.lab_subset` — every decoded label lies inside the target closure
- `PlusWitnessFamily.subset_plusClosureOf` — the same, at the family
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

/--
An L⁺ labelled bi-lasso: three lists of labels, decoded into a bi-infinite label function by
`Periodic.unrollOf`, with every listed label inside the target closure `C`.

The two non-emptiness fields are what make the decoding periodic in both directions; `mid` may
be empty, in which case the two cycles meet at the origin.
-/
structure PlusLabelledLasso (C : Finset PlusFormula) where
  /-- Labels for the leftward cycle, indexed left-to-right in time. -/
  back : List (Finset PlusFormula)
  /-- Labels for the finite window `[0, |mid|)`. -/
  mid : List (Finset PlusFormula)
  /-- Labels for the rightward cycle, indexed left-to-right in time. -/
  fwd : List (Finset PlusFormula)
  /-- The leftward cycle is non-empty, so leftward decoding is periodic. -/
  back_ne : back ≠ []
  /-- The rightward cycle is non-empty, so rightward decoding is periodic. -/
  fwd_ne : fwd ≠ []
  /-- Every listed label is a set of L⁺ formulas from the target closure. -/
  label_sub : ∀ X ∈ back ++ mid ++ fwd, X ⊆ C
  deriving DecidableEq

namespace PlusLabelledLasso

variable {C : Finset PlusFormula}

/-- The decoded bi-infinite label function, by the same three-segment scheme that decodes a
`BiLasso`'s states. -/
def lab (Λ : PlusLabelledLasso C) (t : ℤ) : Finset PlusFormula :=
  Periodic.unrollOf Λ.back Λ.mid Λ.fwd t

theorem lab_def (Λ : PlusLabelledLasso C) (t : ℤ) :
    Λ.lab t = Periodic.unrollOf Λ.back Λ.mid Λ.fwd t := rfl

/-- The backward cycle length, as an integer. -/
abbrev nb (Λ : PlusLabelledLasso C) : ℤ := (Λ.back.length : ℤ)

/-- The window length, as an integer. -/
abbrev nm (Λ : PlusLabelledLasso C) : ℤ := (Λ.mid.length : ℤ)

/-- The forward cycle length, as an integer. -/
abbrev nf (Λ : PlusLabelledLasso C) : ℤ := (Λ.fwd.length : ℤ)

theorem nb_pos (Λ : PlusLabelledLasso C) : 0 < Λ.nb := Periodic.length_pos_int Λ.back_ne

theorem nf_pos (Λ : PlusLabelledLasso C) : 0 < Λ.nf := Periodic.length_pos_int Λ.fwd_ne

theorem nm_nonneg (Λ : PlusLabelledLasso C) : 0 ≤ Λ.nm := Int.natCast_nonneg _

/-- **Leftward periodicity.** Strictly left of the origin the labels have period `|back|`. -/
theorem lab_sub_back_length (Λ : PlusLabelledLasso C) {t : ℤ} (ht : t < 0) :
    Λ.lab (t - Λ.nb) = Λ.lab t :=
  Periodic.unrollOf_sub_back_length _ _ _ Λ.back_ne ht

/-- **Rightward periodicity.** At or past `|mid|` the labels have period `|fwd|`. -/
theorem lab_add_fwd_length (Λ : PlusLabelledLasso C) {t : ℤ} (ht : Λ.nm ≤ t) :
    Λ.lab (t + Λ.nf) = Λ.lab t :=
  Periodic.unrollOf_add_fwd_length _ _ _ Λ.fwd_ne ht

/-- The empty label is the decoding's out-of-range default. -/
theorem default_finset : (default : Finset PlusFormula) = ∅ := rfl

/--
**Every decoded label lies inside the target closure.**

The structure field states this for the labels as they are *listed*; this restates it for the
labels as they are *decoded*, which is the form every consumer uses. The decoding only ever
returns a listed label or the default `∅`, and `∅` is a subset of anything.
-/
theorem lab_subset (Λ : PlusLabelledLasso C) (t : ℤ) : Λ.lab t ⊆ C := by
  have hmem : ∀ (l : List (Finset PlusFormula)) (i : ℕ),
      (∀ X ∈ l, X ⊆ C) → l.getD i ∅ ⊆ C := by
    intro l i hl
    rcases lt_or_ge i l.length with hi | hi
    · rw [(List.getElem_eq_getD (l := l) (i := i) (h := hi) ∅).symm]
      exact hl _ (List.getElem_mem hi)
    · rw [List.getD_eq_getElem?_getD, List.getElem?_eq_none hi]
      simp
  have hsub := Λ.label_sub
  have hback : ∀ X ∈ Λ.back, X ⊆ C := fun X hX => hsub X (by simp [hX])
  have hmid : ∀ X ∈ Λ.mid, X ⊆ C := fun X hX => hsub X (by simp [hX])
  have hfwd : ∀ X ∈ Λ.fwd, X ⊆ C := fun X hX => hsub X (by simp [hX])
  rw [lab_def, Periodic.unrollOf]
  split
  · exact hmem _ _ hback
  · split
    · exact hmem _ _ hmid
    · exact hmem _ _ hfwd

end PlusLabelledLasso

/--
An L⁺ witness family: a box guess plus a non-empty list of L⁺ labelled lassos, lasso `0` main.

The box guess `bx` is read only at formulas `χ` with `□χ` in the target closure; `PlusBoxFaithful`
(in `Predicates.lean`) is what ties it to global label membership. It is a single
`PlusFormula → Bool` rather than a per-position field because the truth of a boxed formula is
independent of both history and time.

There is deliberately **no** `stab` guess beside it. `⊡` is not history- and time-independent;
it is same-time and cross-index, which is why the stability condition (C5) relates labels at one
time across the `share`-class rather than pinning a global Boolean.
-/
structure PlusWitnessFamily (Γ Del : PlusContext) where
  /-- The box guess, read only at formulas boxed inside the target closure. -/
  bx : PlusFormula → Bool
  /-- The lassos of the family; lasso `0` is the main one, where the target is read. -/
  lassos : List (PlusLabelledLasso (plusClosureOf (Γ ++ Del)))
  /-- The family has at least one lasso, so the presented carrier is non-empty. -/
  lassos_ne : lassos ≠ []

namespace PlusWitnessFamily

variable {Γ Del : PlusContext}

/-- The family has positively many lassos, so `Fin W.lassos.length` is inhabited. -/
theorem lassos_length_pos (W : PlusWitnessFamily Γ Del) : 0 < W.lassos.length :=
  List.length_pos_of_ne_nil W.lassos_ne

/-- The main lasso's index, pinned at `0` exactly as `BiLasso` pins its origin. -/
def mainIdx (W : PlusWitnessFamily Γ Del) : Fin W.lassos.length :=
  ⟨0, W.lassos_length_pos⟩

/-- The family's decoded label function, indexed by lasso and time. -/
def L (W : PlusWitnessFamily Γ Del) (i : Fin W.lassos.length) (t : ℤ) : Finset PlusFormula :=
  (W.lassos.get i).lab t

/-- The main lasso's label function, where the target is read. -/
def main (W : PlusWitnessFamily Γ Del) : ℤ → Finset PlusFormula := W.L W.mainIdx

/-- Every decoded label of every lasso lies inside the target closure. -/
theorem subset_plusClosureOf (W : PlusWitnessFamily Γ Del) (i : Fin W.lassos.length) (t : ℤ) :
    W.L i t ⊆ plusClosureOf (Γ ++ Del) :=
  (W.lassos.get i).lab_subset t

end PlusWitnessFamily

/-!
## The branching L⁺ certificate

`PlusSharingWitnessFamily` is `PlusWitnessFamily` extended by the three periodic segments of
representative maps that make the presented frame branch — the same extension
`SharingWitnessFamily` makes on the `Formula` side, and carrying the same field names.

What it does **not** do is re-prove the branching theory. The representative structure is exactly
a `SharingSkeleton`, and `SharingSkeleton` already carries `share`, the threads, the quotient
frame over `intOrder`, all four frame constraints, the world histories and `total_eq_thread` —
944 lines, none of which mentions a formula. `PlusSharingWitnessFamily.skeleton` is the
projection, and everything below it is a one-line delegation. Zero lines of substrate are
duplicated on this side.

This is what makes the stability condition (C5) affordable. `⊡` depends on the world state alone,
the frame's world states *are* the `share`-classes, and those classes are supplied by the
skeleton the `Formula`-side certificate already established as green.
-/

/--
An L⁺ witness family extended by the periodic representative maps that make its frame branch.

The parent's three fields are the L⁺ export contract and are inherited, not re-declared;
`repBack`, `repMid` and `repFwd` extend it additively, exactly as on the `Formula` side.
-/
structure PlusSharingWitnessFamily (Γ Del : PlusContext) extends PlusWitnessFamily Γ Del where
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

namespace PlusSharingWitnessFamily

variable {Γ Del : PlusContext}

/--
**The L⁺ family's label-free substrate.**

The whole branching theory is inherited through this projection rather than duplicated. Marked
`@[reducible]` for the same reason the `Formula`-side projection is: without it,
`Fin S.skeleton.n` and `Fin S.lassos.length` fail to unify at the transparency `rw`'s keyed
matching uses, and rewrites whose pattern mentions `share` fail against terms whose indices came
from a thread.
-/
@[reducible]
def skeleton (S : PlusSharingWitnessFamily Γ Del) : SharingSkeleton where
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

/-- The skeleton's index count is the family's lasso count, definitionally, so
`Fin S.lassos.length` and `Fin S.skeleton.n` interchange with no coercion. -/
@[simp]
theorem skeleton_n (S : PlusSharingWitnessFamily Γ Del) : S.skeleton.n = S.lassos.length := rfl

/-- The decoded bi-infinite representative map. -/
def rep (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) :
    Fin S.lassos.length → Fin S.lassos.length :=
  S.skeleton.rep u

/-- **Two lasso indices name the same world state at time `u`.** The kernel of `rep u`, so an
equivalence relation with nothing to prove. -/
def share (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) : Prop :=
  S.skeleton.share u i j

theorem share_def (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.share u i j ↔ S.rep u i = S.rep u j := Iff.rfl

@[refl]
theorem share_refl (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.share u i i := rfl

theorem share_symm {S : PlusSharingWitnessFamily Γ Del} {u : ℤ} {i j : Fin S.lassos.length}
    (h : S.share u i j) : S.share u j i := SharingSkeleton.share_symm h

theorem share_trans {S : PlusSharingWitnessFamily Γ Del} {u : ℤ} {i j k : Fin S.lassos.length}
    (hij : S.share u i j) (hjk : S.share u j k) : S.share u i k :=
  SharingSkeleton.share_trans hij hjk

/-! ### The fourth periodic datum, re-exported -/

/-- The decoded bi-infinite succession matrix. Out of range it is the identity relation. -/
def transRaw (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) :
    Fin S.lassos.length → Fin S.lassos.length → Bool :=
  S.skeleton.transRaw u

theorem transRaw_eq_skeleton (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) :
    S.transRaw u = S.skeleton.transRaw u := rfl

theorem transRaw_def (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) :
    S.transRaw u
      = @Periodic.unrollOf _ (transEqInhabited _) S.transBack S.transMid S.transFwd u := rfl

/-- **Succession, arrival-pruned**, at the family's own `share`. -/
def trans (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) : Prop :=
  S.skeleton.trans u i j

theorem trans_def (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) (i j : Fin S.lassos.length) :
    S.trans u i j ↔ (S.transRaw u i j = true ∧ S.share (u + 1) i j) := Iff.rfl

theorem transRaw_refl (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.transRaw u i i = true := S.skeleton.transRaw_refl u i

@[refl]
theorem trans_refl' (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.trans u i i := S.skeleton.trans_refl' u i

theorem share_succ_of_trans {S : PlusSharingWitnessFamily Γ Del} {u : ℤ}
    {i j : Fin S.lassos.length} (h : S.trans u i j) : S.share (u + 1) i j := h.2

instance decidableTrans (S : PlusSharingWitnessFamily Γ Del) (u : ℤ)
    (i j : Fin S.lassos.length) : Decidable (S.trans u i j) :=
  inferInstanceAs (Decidable (S.skeleton.trans u i j))

/-- Every index shares its own representative. -/
theorem share_rep (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
    S.share u i (S.rep u i) := S.skeleton.share_rep u i

instance decidableShare (S : PlusSharingWitnessFamily Γ Del) (u : ℤ)
    (i j : Fin S.lassos.length) : Decidable (S.share u i j) :=
  inferInstanceAs (Decidable (S.rep u i = S.rep u j))

/-- A bi-infinite choice of lasso index, stepping only across shared states. -/
abbrev Thread (S : PlusSharingWitnessFamily Γ Del) : Type := S.skeleton.Thread

/-- The constant thread at index `i`. -/
abbrev Thread.const (S : PlusSharingWitnessFamily Γ Del) (i : Fin S.lassos.length) : S.Thread :=
  SharingSkeleton.Thread.const S.skeleton i

instance instNonemptyThread (S : PlusSharingWitnessFamily Γ Del) : Nonempty S.Thread :=
  ⟨Thread.const S S.mainIdx⟩

/-- A thread's step, phrased at the family's own `share`. Declared here so that dot notation on a
family thread resolves to this rather than to the skeleton's field, which is stated at
`S.skeleton.share`. -/
theorem Thread.step {S : PlusSharingWitnessFamily Γ Del} (θ : S.Thread) (u : ℤ) :
    S.trans u (θ.idx u) (θ.idx (u + 1)) := SharingSkeleton.Thread.step θ u

/--
**An L⁺ family thread's step, read as the arrival-time sharing fact.**

The Plus-side twin of `SharingWitnessFamily.thread_share_succ`, and the single point through
which every consumer in this directory reads a thread's step, so that `Thread.step` above is
free to change meaning without touching any of them.
-/
theorem thread_share_succ {S : PlusSharingWitnessFamily Γ Del} (θ : S.Thread) (u : ℤ) :
    S.share (u + 1) (θ.idx u) (θ.idx (u + 1)) := SharingSkeleton.thread_share_succ θ u

/-- The frame's carrier: `share`-classes of index/time pairs. -/
abbrev WorldState (S : PlusSharingWitnessFamily Γ Del) : Type := S.skeleton.WorldState

/-- The class of a lasso index at a time. -/
abbrev cls (S : PlusSharingWitnessFamily Γ Del) (i : Fin S.lassos.length) (u : ℤ) :
    S.WorldState := S.skeleton.cls i u

theorem cls_eq {S : PlusSharingWitnessFamily Γ Del} {i j : Fin S.lassos.length} {u v : ℤ}
    (hu : u = v) (hs : S.share u i j) : S.cls i u = S.cls j v :=
  SharingSkeleton.cls_eq hu hs

theorem share_of_cls_eq {S : PlusSharingWitnessFamily Γ Del} {i j : Fin S.lassos.length}
    {u v : ℤ} (h : S.cls i u = S.cls j v) : u = v ∧ S.share u i j :=
  SharingSkeleton.share_of_cls_eq h

open FormalSystem.Semantics in
/-- **The branching frame**, inherited from the skeleton. -/
abbrev frame (S : PlusSharingWitnessFamily Γ Del) : FrameOver intOrder := S.skeleton.frame

open FormalSystem.Semantics in
/-- The world history traced by a thread from a time offset. -/
abbrev hist (S : PlusSharingWitnessFamily Γ Del) (θ : S.Thread) (s : ℤ) :
    WorldHistory S.frame.toTaskFrame := S.skeleton.hist θ s

open FormalSystem.Semantics in
/--
**The histories characterization**, inherited from the skeleton.

Every world history of the branching frame is the trace of a thread. This is the
determinism-free replacement for `ShiftSet.total_eq_orbit`, and the reason the L⁺ agreement
theorem's `box` and `stab` cases can quantify over histories at all.
-/
theorem total_eq_thread (S : PlusSharingWitnessFamily Γ Del)
    (σ : WorldHistory S.frame.toTaskFrame) :
    ∃ θ : S.Thread, ∃ s : ℤ, ∀ t : ℤ, σ.state t = S.cls (θ.idx (s + t)) (s + t) :=
  SharingSkeleton.total_eq_thread S.skeleton σ

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
