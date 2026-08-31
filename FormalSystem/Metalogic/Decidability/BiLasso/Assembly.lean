/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Check
import FormalSystem.Semantics.Validity

/-!
# FormalSystem.Metalogic.Decidability.BiLasso.Assembly — from `check` to `Decidable ValidDiscrete`

What the bi-lasso layer buys *given* a finite-model theorem, and nothing more. This module
assembles `check` and `check_correct` (`Check.lean`) into `Decidable (ValidDiscrete φ)`, taking
the finite-model step as a **hypothesis** named `fmp`. It does not prove `fmp`, and nothing here
brings that theorem closer.

## The hypothesis, stated exactly

> `fmp` : `∀ ψ, ¬ ValidDiscrete ψ → ∃ P ∈ cands ψ, ∃ w : Fin P.card, SatAtState P w ψ.neg`,
> for a computable `cands : Formula → List IntPresentation`.

`fmp` is the one open theorem between this layer and decidability of `ValidDiscrete`. Its crux is
box-faithfulness and it is genuinely hard — see `README.md` in this directory. Nothing in the
bi-lasso layer performs any part of it: `exists_annot_of_truth` (`Extraction.lean`) takes a
`WorldHistory P.toTaskFrame` as *input*, so it compresses histories **within** a given
presentation; it does not produce a presentation from an arbitrary countermodel.

## Declarations

- `not_validDiscrete_of_satAtState`: the soundness direction, which needs no hypothesis at all.
  A state of a presentation satisfying `φ.neg` refutes `ValidDiscrete φ` outright — ℤ instantiates
  that predicate's whole binder bundle with no instance work.
- `validDiscrete_iff_check` / `decidableValidDiscrete`: the assembly for a single canonical
  presentation `canon : Formula → IntPresentation`.
- `validDiscrete_iff_checkFamily` / `decidableValidDiscreteFamily`: the assembly for a candidate
  *list* `cands : Formula → List IntPresentation`. This is the form the real `fmp` must take:
  `cands` cannot be "presentations of card at most `presentationBound φ`", because
  `IntPresentation.val` is a function on the `Infinite` type `Atom` and no such finite list
  exists. See `IntPresentation.lean`.

## Axioms

All five declarations measure `[propext, Classical.choice, Quot.sound]`.

The resulting `Decidable` instance **computes** — it carries no `Classical.dec` in its data — but
that is not choice-freedom, and no choice-freedom is claimed. The two are different properties and
only the first holds here. `wlem_of_spherical`
(`Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean`) derives weak excluded middle from
`Spherical R` at the finite carrier `Bool` over ℤ using `[propext, Quot.sound]` alone, so no
finite-carrier route to this result can be choice-free.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

theorem not_validDiscrete_of_satAtState
    (P : IntPresentation) (w : Fin P.card) (φ : Formula)
    (h : SatAtState P w φ.neg) : ¬ ValidDiscrete φ := by
  obtain ⟨τ, hτ, t, -, htr⟩ := h
  intro hv
  exact htr (hv P.toTaskFrame P.toModel τ hτ t)

theorem validDiscrete_iff_check
    (canon : Formula → IntPresentation)
    (fmp : ∀ ψ : Formula, ¬ ValidDiscrete ψ → ∃ w, SatAtState (canon ψ) w ψ.neg)
    (φ : Formula) :
    (∀ w : Fin (canon φ).card, check (canon φ) w φ.neg = false) ↔ ValidDiscrete φ := by
  constructor
  · intro hall
    by_contra hnv
    obtain ⟨w, hw⟩ := fmp φ hnv
    have : check (canon φ) w φ.neg = true := (check_correct _ _ _).mpr hw
    rw [hall w] at this
    exact Bool.false_ne_true this
  · intro hv w
    rcases Bool.eq_false_or_eq_true (check (canon φ) w φ.neg) with h | h
    · exact absurd hv (not_validDiscrete_of_satAtState _ w φ ((check_correct _ _ _).mp h))
    · exact h

def decidableValidDiscrete
    (canon : Formula → IntPresentation)
    (fmp : ∀ ψ : Formula, ¬ ValidDiscrete ψ → ∃ w, SatAtState (canon ψ) w ψ.neg)
    (φ : Formula) : Decidable (ValidDiscrete φ) :=
  decidable_of_iff _ (validDiscrete_iff_check canon fmp φ)

theorem validDiscrete_iff_checkFamily
    (cands : Formula → List IntPresentation)
    (fmp : ∀ ψ : Formula, ¬ ValidDiscrete ψ →
      ∃ P ∈ cands ψ, ∃ w : Fin P.card, SatAtState P w ψ.neg)
    (φ : Formula) :
    (∀ P ∈ cands φ, ∀ w : Fin P.card, check P w φ.neg = false) ↔ ValidDiscrete φ := by
  constructor
  · intro hall
    by_contra hnv
    obtain ⟨P, hP, w, hw⟩ := fmp φ hnv
    have h1 : check P w φ.neg = true := (check_correct _ _ _).mpr hw
    rw [hall P hP w] at h1
    exact Bool.false_ne_true h1
  · intro hv P _ w
    rcases Bool.eq_false_or_eq_true (check P w φ.neg) with h | h
    · exact absurd hv (not_validDiscrete_of_satAtState P w φ ((check_correct _ _ _).mp h))
    · exact h

def decidableValidDiscreteFamily
    (cands : Formula → List IntPresentation)
    (fmp : ∀ ψ : Formula, ¬ ValidDiscrete ψ →
      ∃ P ∈ cands ψ, ∃ w : Fin P.card, SatAtState P w ψ.neg)
    (φ : Formula) : Decidable (ValidDiscrete φ) :=
  decidable_of_iff _ (validDiscrete_iff_checkFamily cands fmp φ)

end FormalSystem.Metalogic.Decidability
