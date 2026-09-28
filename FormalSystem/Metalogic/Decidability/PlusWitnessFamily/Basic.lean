/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Closure
import FormalSystem.Metalogic.Decidability.BiLasso.Periodic

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

end FormalSystem.Metalogic.Decidability
