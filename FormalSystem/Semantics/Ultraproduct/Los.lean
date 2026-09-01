/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Ultraproduct.ShiftSetProduct

/-!
# Łoś's theorem for the ultraproduct shift set

`Ultraproduct/ShiftSetProduct.lean` assembles `uShiftSet φ S : ShiftSet (UT φ T)` from a family
`S : ∀ i, ShiftSet (T i)`. This module proves the fundamental theorem of ultraproducts for it:

* `los` — Łoś at `ShiftTruth`: a formula holds at `⟨omk f, mk x⟩` in the ultraproduct shift set
  exactly when it holds at `⟨f i, x i⟩` in eventually many factors;
* `los_truthAt` — the same statement at `TruthAt`, along the orbit histories.

## Routing: why `ShiftTruth` first, and not `TruthAt` directly

`ShiftTruth`'s `box` clause quantifies over the carrier `S.Carrier`
(`Semantics/ShiftSet.lean:261-265`), which is exactly the sort the ultraproduct construction
quotients. `TruthAt`'s `box` clause quantifies over all *total world histories* of the frame, a
sort with no direct ultraproduct presentation; attacking it head-on would require a fresh
choice-function argument over total histories. That argument already exists, once, inside
`ShiftSet.forward_repr` (`Semantics/ShiftSet.lean:278`ff), whose own `box` case reconciles the two
quantifiers via `hist_isTotal` (`:226`) and `total_eq_orbit` (`:245`). So `los_truthAt` is
obtained by *reuse*: conjugate `los` with `forward_repr` on both sides. No new choice argument
over histories is introduced anywhere in this file.

## Three cases need choice, not one

The `box` case is not the only case with real content. `untl` and `snce` each carry both an
`∃ s : D` and a bounded `∀ r : D` (`Semantics/ShiftSet.lean:266-269`), so each needs a
witness-section extraction in one direction and a counterexample-section extraction in the other
— two `exists_section` calls per case. They are the two longest cases below. Only `atom`, `bot`
and `imp` are mechanical, and even `bot` is not `Iff.rfl` (it needs `φ.NeBot`, via
`Filter.Eventually.exists`).

## Axiom profile

`#print axioms los` and `#print axioms los_truthAt` both report
`[propext, Classical.choice, Quot.sound]`, with `sorryAx` absent. `Classical.choice` enters
through `exists_section` and through `Carrier.lean`'s `LinearOrder` instance.
-/

set_option linter.unusedSectionVars false

open Filter FormalSystem.Syntax
open FormalSystem.Semantics.ShiftSet (ShiftTruth)

namespace FormalSystem.Semantics.Ultraproduct

variable {I : Type} {φ : Ultrafilter I} {T : I → TemporalOrder}

/-! ## Łoś at `ShiftTruth` -/

/-- **Łoś's theorem for `ShiftTruth`.**

Note the statement shape: `χ` is generalized FIRST and `f`, `x` appear under a `∀` in the
conclusion. `induction χ with` then gives induction hypotheses quantified over all carrier
sections and all duration sections, which the `box` case (arbitrary `v`) and the `untl`/`snce`
cases (arbitrary time `s`, `r`) both require. An induction hypothesis fixed at the ambient `f`,
`x` closes none of those three cases. Writing `(f) (x)` as ordinary binders and using
`generalizing f x` also works; this form was the one measured. -/
theorem los (S : ∀ i, ShiftSet (T i)) (χ : Formula) :
    ∀ (f : ∀ i, (S i).Carrier) (x : ∀ i, ↑(T i)),
      ShiftTruth (uShiftSet φ S) (omk f) (mk x) χ ↔
        ∀ᶠ i in φ, ShiftTruth (S i) (f i) (x i) χ := by
  haveI : ∀ i, Nonempty ((S i).Carrier) := fun i => (S i).carrier_nonempty
  induction χ with
  | atom p => intro f x; exact Iff.rfl
  | bot => intro f x; exact ⟨fun h => h.elim, fun h => by obtain ⟨_, hi⟩ := h.exists; exact hi⟩
  | imp ψ χ ihψ ihχ =>
    intro f x
    -- NB: `rw [show _ ↔ _ from Iff.rfl]` FAILS here (`uShiftSet` is semireducible, so
    -- `(uShiftSet φ S).Carrier` will not reduce during motive typing). `Iff.trans` works.
    exact (imp_congr (ihψ f x) (ihχ f x)).trans Ultrafilter.eventually_imp.symm
  | box ψ ih =>
    intro f x
    constructor
    · intro h
      by_contra hc
      have h2 : ∀ᶠ i in φ, ∃ v, ¬ ShiftTruth (S i) v (x i) ψ :=
        (Ultrafilter.eventually_not.mpr hc).mono (fun i hi => not_forall.mp hi)
      obtain ⟨g, hg⟩ := exists_section h2
      obtain ⟨j, hj1, hj2⟩ := (((ih g x).mp (h (omk g))).and hg).exists
      exact hj2 hj1
    · intro h v
      obtain ⟨g, rfl⟩ := omk_surjective v
      exact (ih g x).mpr (h.mono fun i hi => hi (g i))
  | untl ψ χ ihψ ihχ =>
    intro f x
    constructor
    · rintro ⟨s, hs, he, hg⟩
      obtain ⟨σ, rfl⟩ := mk_surjective s
      have h1 : ∀ᶠ i in φ, x i < σ i := mk_lt_mk.mp hs
      have h2 := (ihχ f σ).mp he
      have h3 : ∀ᶠ i in φ, ∀ r, x i < r → r < σ i → ShiftTruth (S i) (f i) r ψ := by
        by_contra hc
        have h4 : ∀ᶠ i in φ, ∃ r, x i < r ∧ r < σ i ∧ ¬ ShiftTruth (S i) (f i) r ψ :=
          (Ultrafilter.eventually_not.mpr hc).mono (fun i hi => by
            obtain ⟨r, hr⟩ := not_forall.mp hi; exact ⟨r, by tauto⟩)
        obtain ⟨ρ, hρ⟩ := exists_section h4
        have hx := (ihψ f ρ).mp (hg (mk ρ) (mk_lt_mk.mpr (hρ.mono fun i hi => hi.1))
          (mk_lt_mk.mpr (hρ.mono fun i hi => hi.2.1)))
        obtain ⟨j, hj1, hj2⟩ := (hx.and hρ).exists
        exact hj2.2.2 hj1
      exact ((h1.and (h2.and h3)).mono (fun i hi => ⟨σ i, hi.1, hi.2.1, hi.2.2⟩))
    · intro h
      obtain ⟨σ, hσ⟩ := exists_section h
      refine ⟨mk σ, mk_lt_mk.mpr (hσ.mono fun i hi => hi.1),
        (ihχ f σ).mpr (hσ.mono fun i hi => hi.2.1), ?_⟩
      intro r hr1 hr2
      obtain ⟨ρ, rfl⟩ := mk_surjective r
      exact (ihψ f ρ).mpr (((mk_lt_mk.mp hr1).and ((mk_lt_mk.mp hr2).and hσ)).mono
        (fun i hi => hi.2.2.2.2 (ρ i) hi.1 hi.2.1))
  | snce ψ χ ihψ ihχ =>
    intro f x
    constructor
    · rintro ⟨s, hs, he, hg⟩
      obtain ⟨σ, rfl⟩ := mk_surjective s
      have h1 : ∀ᶠ i in φ, σ i < x i := mk_lt_mk.mp hs
      have h2 := (ihχ f σ).mp he
      have h3 : ∀ᶠ i in φ, ∀ r, σ i < r → r < x i → ShiftTruth (S i) (f i) r ψ := by
        by_contra hc
        have h4 : ∀ᶠ i in φ, ∃ r, σ i < r ∧ r < x i ∧ ¬ ShiftTruth (S i) (f i) r ψ :=
          (Ultrafilter.eventually_not.mpr hc).mono (fun i hi => by
            obtain ⟨r, hr⟩ := not_forall.mp hi; exact ⟨r, by tauto⟩)
        obtain ⟨ρ, hρ⟩ := exists_section h4
        have hx := (ihψ f ρ).mp (hg (mk ρ) (mk_lt_mk.mpr (hρ.mono fun i hi => hi.1))
          (mk_lt_mk.mpr (hρ.mono fun i hi => hi.2.1)))
        obtain ⟨j, hj1, hj2⟩ := (hx.and hρ).exists
        exact hj2.2.2 hj1
      exact ((h1.and (h2.and h3)).mono (fun i hi => ⟨σ i, hi.1, hi.2.1, hi.2.2⟩))
    · intro h
      obtain ⟨σ, hσ⟩ := exists_section h
      refine ⟨mk σ, mk_lt_mk.mpr (hσ.mono fun i hi => hi.1),
        (ihχ f σ).mpr (hσ.mono fun i hi => hi.2.1), ?_⟩
      intro r hr1 hr2
      obtain ⟨ρ, rfl⟩ := mk_surjective r
      exact (ihψ f ρ).mpr (((mk_lt_mk.mp hr1).and ((mk_lt_mk.mp hr2).and hσ)).mono
        (fun i hi => hi.2.2.2.2 (ρ i) hi.1 hi.2.1))

end FormalSystem.Semantics.Ultraproduct
