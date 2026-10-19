/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient

/-!
# The definitional layer of the ladder's realization statement

This module lands the three objects the ladder realization statements quantify over, and nothing
else: `typeOfCl`, the projection out of `Certificate.lean`'s closure component `ClType`;
`certChain`, the bi-infinite certificate chain over the product carrier
`Q × ClType φ × CK Tc Tn P B`; and `LadderCons`, the consistency bundle on a candidate set.

There is no theorem in this module. The three hard obligations — soundness, the agreement of
class-equivalent cells, and the lift in pumping form — are each stated and proved elsewhere, and
none of the three definitions below consumes any of them.

## The ladder's structural liveness, and the shape the backward half is retained in

`Realize.lean`'s `Cons` carries two liveness fields. Their fate here is NOT symmetric, and the
asymmetry is a compiled fact and not a convention.

* The FORWARD field (`ulive`) is REPLACED. Its work is done by the `Count`-driven decrease of the
  current deadline `c` while the object is pending: by `RunLayer.lean`'s `Count`, a pending-to-
  pending step forces `c' + 1 = c`, so `c` strictly decreases along any pending stretch and no
  forward obligation can be deferred forever. Nothing has to be hypothesized for this; it is a
  consequence of the relation `RladAdm` already carries.
* The BACKWARD field (`slive`) is RETAINED, in the shape `certBwdK` — Phase 9's landed
  `DischPathK` taken along the reversed `relK` over the product carrier, with the letters read as
  formula membership in the `ClType` component. It is retained because the ladder's structural
  liveness is FORWARD-ONLY: the thirteenth wired probe
  `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` exhibits an
  admissible ladder path that is pending at every past time with its countdown growing without
  bound into the past (`gPast_isPath`, `gPast_pending_past`, `gPast_count`), so the `Count`
  argument that discharges the forward direction has no backward mirror and the past-directed
  obligations must be carried by a discharge condition of their own. This is a statement about
  the landed form of the ladder's liveness and about nothing else: no claim is made here that one
  device discriminates between any two classes of structures.

`Realize.lean`'s `SLive` is NOT retained and cannot be: it, and with it `UCoh`, `ULive`, `SCoh`,
`deferGraph`, `bwdDeferGraph`, `Disch`, `DischBwd`, `persist` and `snce_iff_of_SCoh_SLive`, are
indexed by `(clSig φ).preds` letters over a labelling `Q → (clSig φ).preds → Bool`, whereas
`LadderCons` below carries `lab : Q → Atom → Bool` and keeps the closure component in `ClType φ`,
so none of those terms elaborates at this carrier. No new translation layer is authored to bridge
the two, because `DischPathK`, `certFwdK` and `certBwdK` already are that layer, at the carrier
the ladder's statements are pinned at.

## What this module does NOT hold

* **No soundness field on `LadderCons`.** A clause asserting that the projections of ladder
  histories lie in the candidate set would make the second conjunct of the realization-side run
  theorem near-vacuous under a filed name. That conjunct is discharged instead from the soundness
  obligation plus `LadderCons`'s own maximality clause, with no field added.
* **No model-side notion appears in any of the three definitions.** None of them mentions a
  history, a closure type read off a model, the ladder model, or a cell: they are conditions on a
  chain and on a set, and the composition with the model layer is the content of the obligations
  that consume them.
* **No stratification by `⊡`-nesting depth.** `certChain` carries no depth parameter. The
  stratified alternative was the route not taken by the recorded presentation decision, and a
  depth-indexed `certChain` would change the pinned signature of the lift that consumes it.
* **No decision procedure, no bound, no index.** Nothing here decides anything, every quantity
  named is a count, and no tuple is stated as an index of a ladder cell at any parameters.
-/

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-! ## The closure component's projection

`ClType φ` is landed in `Certificate.lean` as `{T : Finset PlusFormula // T ∈
(plusSubformulaClosure φ).powerset}`; only its projection was missing. -/

/-- **The closure component's projection**: the `Finset` of closure formulas a `ClType` carries.
`ClType` is landed (`Certificate.lean`); this is its first projection under a name the
realization statements can quantify over. -/
def typeOfCl {φ : PlusFormula} (T : ClType φ) : Finset PlusFormula := T.val

/-! ## The bi-infinite certificate chain

The chain condition over the product carrier `Q × ClType φ × CK Tc Tn P B`: the landed relation
`relK` between consecutive positions, local coherence at every position through the landed
`certLocK`, and the two temporal obligations read as formula membership in the `ClType`
component.

The last two conjuncts are the chain-level counterpart of `DischPathK`, the landed guarded
discharge path that `certFwdK` and `certBwdK` quantify at a SET: on a chain the discharging path
is a contiguous stretch of the chain itself, so the obligation is stated at the chain's own
positions and the existential ranges over times rather than over paths inside a candidate set.
The first conjunct is implied by the second — `cohIdle` constrains `locCoh` at both of its
endpoints — and is kept explicit so that the condition is named by the landed predicate rather
than left to be read out of the relation. -/

/-- **THE BI-INFINITE CERTIFICATE CHAIN.** `ξ` is locally coherent at every position
(`certLocK`), steps by `relK` at every position, and fulfils every forward `untl` obligation at
some later position and every backward `snce` obligation at some earlier position, with the guard
holding throughout the intervening stretch. No depth or stratification parameter: the chain
condition is unstratified. -/
def certChain {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ)
    (ξ : ℤ → Q × ClType φ × CK Tc Tn P B) : Prop :=
  certLocK lab φ Tc Tn P B (Set.range ξ) ∧
    (∀ t : ℤ, relK step pend lab φ Tc Tn P B (ξ t) (ξ (t + 1))) ∧
    (∀ (t : ℤ) (g e : PlusFormula), PlusFormula.untl g e ∈ (ξ t).2.1.val →
      ∃ s : ℤ, t < s ∧ e ∈ (ξ s).2.1.val ∧ ∀ r : ℤ, t < r → r < s → g ∈ (ξ r).2.1.val) ∧
    (∀ (t : ℤ) (g e : PlusFormula), PlusFormula.snce g e ∈ (ξ t).2.1.val →
      ∃ s : ℤ, s < t ∧ e ∈ (ξ s).2.1.val ∧ ∀ r : ℤ, s < r → r < t → g ∈ (ξ r).2.1.val)

/-! ## The consistency bundle

`LadderCons` is the certificate conditions on a candidate set together with the maximality
clause. The acceptance criterion is part of it and is never dropped: `certAdmK`'s own `certBoxK`
pins the `□` letter as ONE GLOBAL BIT and its `certStabK` pins the `⊡` letter per `(q, κ)`, which
is the granularity the anchor layer's fixpoint equations force. -/

/-- **THE CONSISTENCY BUNDLE.** `R` is `certAdmK`-certified — the six conditions, the two
acceptance conditions `certStabK` (per `(q, κ)`) and `certBoxK` (one global bit) included — and
`R` contains the maximum certified subset `Dmax`. Together with `dmax_maximal` the two clauses
pin `R` to `Dmax` exactly; both are stated, because the maximality clause is what the
realization-side run theorem discharges its membership conjunct from, and the certification
clause is what its chain conjunct reads. No liveness field of `Realize.lean`'s `Cons` survives as
such: the forward one is replaced by the `Count`-driven decrease and the backward one is
`certAdmK`'s own `certBwdK`. -/
def LadderCons {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ)
    (R : Set (Q × ClType φ × CK Tc Tn P B)) : Prop :=
  certAdmK step pend lab φ Tc Tn P B R ∧ Dmax step pend lab φ Tc Tn P B ⊆ R

end FormalSystem.Metalogic.Decidability.RaySummary
