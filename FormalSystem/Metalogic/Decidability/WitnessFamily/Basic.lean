/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Closure
import FormalSystem.Metalogic.Decidability.BiLasso.Periodic

/-!
# Labelled Bi-Lassos and Witness Families

A **witness-family certificate** is the finite object a model checker returns when it refutes a
ℤ-time consequence: a box guess plus a non-empty list of labelled bi-lassos. This module supplies
the datatype; `Predicates.lean` supplies the three conditions a certificate must satisfy, `Std.lean`
the model it presents, and `Agreement.lean` the theorem that makes it a refutation.

## Presentation-free, by design

`BiLasso/Annotation.lean`'s `Annot P φ` labels the positions of a bi-lasso *through an
`IntPresentation`*: each label is tied to a state, and three length agreements keep the two
decodings aligned. A `LabelledLasso` has no states at all. The labels **are** the object: the
valuation of the presented model is read off the atom part of each label, so there is nothing for
a state to add. Everything the alignment layer (`Annot.readIndex`, `Annot.label_unroll_aligned`)
exists to guarantee is vacuous here.

That is what makes the family the right shape for a certificate. `Probe476.fmp_false` rules out
finite `IntPresentation`s as the searched object, and `BiLasso/Agreement.lean`'s three limits rule
out bare windows; a labelled family is what is left.

## Field names are an export contract

The field names below are mirrored field for field by the model checker's JSON export. Renaming
`back`, `mid`, `fwd`, `bx` or `lassos` is a breaking change on the consuming side, not a local
refactor.

## Deliberate duplication against `BiLasso/Annotation.lean`

`Annot`'s label periodicities (`label_sub_back_length`, `label_add_fwd_length`) and this file's
(`lab_sub_back_length`, `lab_add_fwd_length`) are the same two facts about
`Periodic.unrollOf`, instantiated at two different carriers of that decoding. They are not
shared, because sharing them would mean either moving `Annot`'s label fields into a common
structure — which touches `Annotation.lean` and the `Decide.lean` that consumes it — or
generalising over a presentation this datatype deliberately does not have.

The duplication is recorded rather than hidden, exactly as `BiLasso/Periodic.lean` records its
own duplication against `BiLasso/Basic.lean`. **The trigger that retires it**: once a shared
periodic-label presentation lands, `Annot`'s window collapses and `LabelledLasso`'s should be
redefined as its two instances and the duplicated arithmetic deleted. That refactor belongs to
whichever task owns the shared abstraction.

## Main Definitions

- `LabelledLasso` — three label segments, decoded by `Periodic.unrollOf`
- `LabelledLasso.lab` — the decoded bi-infinite label function
- `WitnessFamily` — a box guess plus a non-empty list of labelled lassos, lasso `0` main

## Main Results

- `LabelledLasso.lab_sub_back_length` / `LabelledLasso.lab_add_fwd_length` — the two periodicities
- `LabelledLasso.lab_subset` — every decoded label lies inside the target closure
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/--
A labelled bi-lasso: three lists of labels, decoded into a bi-infinite label function by
`Periodic.unrollOf`, with every listed label inside the target closure `C`.

The two non-emptiness fields are what make the decoding periodic in both directions; `mid` may
be empty, in which case the two cycles meet at the origin.
-/
structure LabelledLasso (C : Finset Formula) where
  /-- Labels for the leftward cycle, indexed left-to-right in time. -/
  back : List (Finset Formula)
  /-- Labels for the finite window `[0, |mid|)`. -/
  mid : List (Finset Formula)
  /-- Labels for the rightward cycle, indexed left-to-right in time. -/
  fwd : List (Finset Formula)
  /-- The leftward cycle is non-empty, so leftward decoding is periodic. -/
  back_ne : back ≠ []
  /-- The rightward cycle is non-empty, so rightward decoding is periodic. -/
  fwd_ne : fwd ≠ []
  /-- Every listed label is a set of formulas from the target closure. -/
  label_sub : ∀ X ∈ back ++ mid ++ fwd, X ⊆ C
  deriving DecidableEq

namespace LabelledLasso

variable {C : Finset Formula}

/-- The decoded bi-infinite label function, by the same three-segment scheme that decodes a
`BiLasso`'s states. -/
def lab (Λ : LabelledLasso C) (t : ℤ) : Finset Formula :=
  Periodic.unrollOf Λ.back Λ.mid Λ.fwd t

theorem lab_def (Λ : LabelledLasso C) (t : ℤ) :
    Λ.lab t = Periodic.unrollOf Λ.back Λ.mid Λ.fwd t := rfl

/-- The backward cycle length, as an integer. -/
abbrev nb (Λ : LabelledLasso C) : ℤ := (Λ.back.length : ℤ)

/-- The window length, as an integer. -/
abbrev nm (Λ : LabelledLasso C) : ℤ := (Λ.mid.length : ℤ)

/-- The forward cycle length, as an integer. -/
abbrev nf (Λ : LabelledLasso C) : ℤ := (Λ.fwd.length : ℤ)

theorem nb_pos (Λ : LabelledLasso C) : 0 < Λ.nb := Periodic.length_pos_int Λ.back_ne

theorem nf_pos (Λ : LabelledLasso C) : 0 < Λ.nf := Periodic.length_pos_int Λ.fwd_ne

theorem nm_nonneg (Λ : LabelledLasso C) : 0 ≤ Λ.nm := Int.natCast_nonneg _

/-- **Leftward periodicity.** Strictly left of the origin the labels have period `|back|`. -/
theorem lab_sub_back_length (Λ : LabelledLasso C) {t : ℤ} (ht : t < 0) :
    Λ.lab (t - Λ.nb) = Λ.lab t :=
  Periodic.unrollOf_sub_back_length _ _ _ Λ.back_ne ht

/-- **Rightward periodicity.** At or past `|mid|` the labels have period `|fwd|`. -/
theorem lab_add_fwd_length (Λ : LabelledLasso C) {t : ℤ} (ht : Λ.nm ≤ t) :
    Λ.lab (t + Λ.nf) = Λ.lab t :=
  Periodic.unrollOf_add_fwd_length _ _ _ Λ.fwd_ne ht

/-- The empty label is the decoding's out-of-range default. -/
theorem default_finset : (default : Finset Formula) = ∅ := rfl

/--
**Every decoded label lies inside the target closure.**

The structure field states this for the labels as they are *listed*; this restates it for the
labels as they are *decoded*, which is the form every consumer uses. The decoding only ever
returns a listed label or the default `∅`, and `∅` is a subset of anything.
-/
theorem lab_subset (Λ : LabelledLasso C) (t : ℤ) : Λ.lab t ⊆ C := by
  have hmem : ∀ (l : List (Finset Formula)) (i : ℕ),
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

end LabelledLasso

/--
A witness family: a box guess plus a non-empty list of labelled lassos, lasso `0` main.

The box guess `bx` is read only at formulas `χ` with `□χ` in the target closure; `BoxFaithful`
(in `Predicates.lean`) is what ties it to global label membership. It is a single
`Formula → Bool` rather than a per-position field because `Semantics.Truth.box_const` makes the
truth of a boxed formula independent of both history and time.
-/
structure WitnessFamily (Γ Del : Context) where
  /-- The box guess, read only at formulas boxed inside the target closure. -/
  bx : Formula → Bool
  /-- The lassos of the family; lasso `0` is the main one, where the target is read. -/
  lassos : List (LabelledLasso (closureOf (Γ ++ Del)))
  /-- The family has at least one lasso, so the presented carrier is non-empty. -/
  lassos_ne : lassos ≠ []

namespace WitnessFamily

variable {Γ Del : Context}

/-- The family has positively many lassos, so `Fin W.lassos.length` is inhabited. -/
theorem lassos_length_pos (W : WitnessFamily Γ Del) : 0 < W.lassos.length :=
  List.length_pos_of_ne_nil W.lassos_ne

/-- The main lasso's index, pinned at `0` exactly as `BiLasso` pins its origin. -/
def mainIdx (W : WitnessFamily Γ Del) : Fin W.lassos.length :=
  ⟨0, W.lassos_length_pos⟩

/-- The family's decoded label function, indexed by lasso and time. -/
def L (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) (t : ℤ) : Finset Formula :=
  (W.lassos.get i).lab t

/-- The main lasso's label function, where the target is read. -/
def main (W : WitnessFamily Γ Del) : ℤ → Finset Formula := W.L W.mainIdx

/-- Every decoded label of every lasso lies inside the target closure. -/
theorem subset_closureOf (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) (t : ℤ) :
    W.L i t ⊆ closureOf (Γ ++ Del) :=
  (W.lassos.get i).lab_subset t

end WitnessFamily

end FormalSystem.Metalogic.Decidability
