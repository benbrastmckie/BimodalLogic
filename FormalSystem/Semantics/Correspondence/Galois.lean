/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Validity
import Mathlib.Order.Concept

/-!
# The `Th`/`Mod` Galois connection on the frame-class layer

The frame-class layer of `def:frame-validity` is a Galois connection between sets of task frames
and sets of formulas, ordered by inclusion and connected by validity:

* `Th K` — the formulas valid on every frame in `K`;
* `Mod S` — the frames validating every formula in `S`.

Both maps are antitone, both round trips are inflationary, and both triple composites collapse.
`GaloisClosed K` names the fixed points of `Mod ∘ Th`, and `galoisClosed_of_indicator` is the
*single* mechanism by which a class is shown closed: exhibit one formula that is valid on
precisely the members of the class. Every closure corollary in
`Semantics/Correspondence/Indicator.lean` is one application of that lemma, with no per-class
copy of the argument.

## Reified sets

`Axiom` is an inductive family indexed by `Formula` rather than a set of formulas, so the axiom
set permitted at a frame-class tag must be reified before `Mod` can consume it:

```
AxiomSet fc = {φ | ∃ h : Axiom φ, h.minFrameClass ≤ fc}
```

This is exactly the side condition `DerivationTree.axiom` carries, read as a set. Similarly
`densitySchema` reifies the density schema `GGψ → Gψ` as the set of its instances.

**`AxiomSet fc` is a set of axiom instances, not of theorems.** The two differ, and the
distinction is load-bearing for the sandwich theorems in `Metalogic/Independence/`: since
`AxiomSet fc ⊆ {φ | Derivable fc [] φ}`, antitonicity gives
`Mod {φ | Derivable fc [] φ} ⊆ Mod (AxiomSet fc)`, so a sandwich stated over `AxiomSet` is the
stronger statement. It is also the only one available: `Mod` of a theorem set would require a
single-frame `F.ValidOn φ → F.ValidOn φ.swapTemporal` closure lemma for the `temporal_duality`
rule, and no such lemma exists — nor should it, since a frame need not be closed under time
reversal.

## Import seam

This module imports `Semantics/Validity.lean` and `Mathlib.Order.Concept`. `Validity.lean`
already imports `FrameClassValidity.lean`, which is the single documented
`Semantics → ProofSystem` edge, so `ProofSystem.Axioms` arrives transitively. The Mathlib edge
is a leaf: `Order.Concept` imports only `Mathlib.Data.Set.Lattice` and `Mathlib.Order.Closure`
and mentions no `FormalSystem` module, so it opens no `Semantics → ProofSystem`-style seam and
the claim this section makes is unchanged.

## Non-goals

Recorded here because they belong to the statement of what this layer does *not* promise:

> closed-form characterizations of Mod(TM+_f) and Mod(TM+_c) are OPEN and not promised —
> evidence: no variable-free BL+ sentence separates Z from Z ×ₗ Z or Q from R, and sep has no
> correspondent.

The `sep` half of that evidence is recorded at the axiom itself: `ProofSystem/Axioms.lean`'s
`sep` docstring quotes Reynolds (printed p.169) to the effect that the Reynolds triple enforces
only a *definably* Dedekind-complete model — "there may be gaps in the order but ... you wouldn't
know that just looking at the behaviour of temporal formulas". A closed-form characterization of
`Mod (AxiomSet .Dedekind)` would have to contradict that. The `ℤ`-versus-`ℤ ×ₗ ℤ` half is
witnessed in `Metalogic/Independence/LexIntWitness.lean`, and the `ℚ`-versus-`ℝ` half in
`Metalogic/Independence/RationalWitness.lean`: in each case the witness frame is a member of the
`Mod` side that the `Sat` side excludes, so the two classes are provably distinct without either
being characterized.

## Over Mathlib

`Th` and `Mod` are the two polars of the validity relation `validOnRel` in the sense of
`Mathlib.Order.Concept`: `Th = upperPolar validOnRel`, `Mod = lowerPolar validOnRel`, and
`GaloisClosed = Order.IsExtent validOnRel`. Each connection theorem below is therefore a single
projection of the corresponding Mathlib lemma, and the closure corollaries
(`galoisClosed_iInter`, `galoisClosed_inter`, `galoisClosed_univ`) and the `Mod`-of-union lemmas
(`mod_union`, `mod_iUnion`, `mod_empty`, `th_empty`) come for free. The names and docstrings are
retained so that call sites read in this development's own vocabulary.

Note that `GaloisClosed K` is `K ∈ Set.range Mod`, a range membership, rather than the
fixed-point *equation* `Mod (Th K) = K`. The two are equivalent — that is `galoisClosed_iff` —
but not definitionally equal, so a consumer that needs the equation goes through the bridge.

## Main results

* `validOnRel` — the validity relation the two polars are taken along
* `Th`, `Mod` — the two maps
* `th_anti`, `mod_anti` — antitonicity
* `subset_mod_th`, `subset_th_mod` — the two inflationary round trips
* `mod_th_mod`, `th_mod_th` — the triple-composite collapses
* `mod_th_gc` — the adjunction as an explicit Mathlib `GaloisConnection`
* `GaloisClosed`, `galoisClosed_mod` — the fixed points, and that every `Mod S` is one
* `galoisClosed_iff` — the bridge back to the fixed-point equation
* `galoisClosed_of_indicator`, `galoisClosed_of_indicator_iff` — the indicator mechanism,
  factored exactly once, with the iff-shaped entry point that call sites use
* `galoisClosed_iInter`, `galoisClosed_inter`, `galoisClosed_univ` — closure under intersections
* `mod_union`, `mod_iUnion`, `mod_empty`, `th_empty` — `Mod` and `Th` on unions and the empty set
* `AxiomSet`, `densitySchema` — the two reified formula sets
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax FormalSystem.ProofSystem Order

/-! ## The two maps -/

/--
The **validity relation** between task frames and formulas, as a bare relation.

`Th` and `Mod` are the upper and lower polars of this relation in the sense of
`Mathlib.Order.Concept`, so every theorem in this section is a projection of a Mathlib lemma
specialised at `validOnRel`.
-/
def validOnRel (F : TaskFrame) (φ : Formula) : Prop := F.ValidOn φ

/--
The **theory** of a class of frames: the formulas valid on every member.

`Th` is the right adjoint of the connection; it takes unions of frame classes to intersections of
theories, which is antitonicity (`th_anti`).

This is `upperPolar validOnRel`, and is `rfl`-defeq to `{φ | ∀ F ∈ K, F.ValidOn φ}`.
-/
abbrev Th : Set TaskFrame → Set Formula := upperPolar validOnRel

/--
The **model class** of a set of formulas: the frames validating every member.

`Mod` is the left adjoint. Its image is exactly the collection of Galois-closed frame classes
(`galoisClosed_mod`), which is what makes "is this class axiomatizable?" and "is this class
Galois-closed?" the same question — and, over Mathlib, is literally the definition of
`GaloisClosed`.

This is `lowerPolar validOnRel`, and is `rfl`-defeq to `{F | ∀ φ ∈ S, F.ValidOn φ}`.
-/
abbrev Mod : Set Formula → Set TaskFrame := lowerPolar validOnRel

/-! ## Antitonicity and the round trips -/

/-- `Th` is antitone: a larger frame class has a smaller theory. -/
theorem th_anti {K₁ K₂ : Set TaskFrame} (h : K₁ ⊆ K₂) : Th K₂ ⊆ Th K₁ :=
  upperPolar_anti _ h

/-- `Mod` is antitone: a larger formula set has a smaller model class. -/
theorem mod_anti {S₁ S₂ : Set Formula} (h : S₁ ⊆ S₂) : Mod S₂ ⊆ Mod S₁ :=
  lowerPolar_anti _ h

/-- The frame-side round trip is inflationary: every frame models its own class's theory. -/
theorem subset_mod_th (K : Set TaskFrame) : K ⊆ Mod (Th K) :=
  subset_lowerPolar_upperPolar _ K

/-- The formula-side round trip is inflationary: every formula is in the theory of its models. -/
theorem subset_th_mod (S : Set Formula) : S ⊆ Th (Mod S) :=
  subset_upperPolar_lowerPolar _ S

/-- The frame-side triple composite collapses. -/
theorem mod_th_mod (S : Set Formula) : Mod (Th (Mod S)) = Mod S :=
  lowerPolar_upperPolar_lowerPolar _ S

/-- The formula-side triple composite collapses. -/
theorem th_mod_th (K : Set TaskFrame) : Th (Mod (Th K)) = Th K :=
  upperPolar_lowerPolar_upperPolar _ K

/--
The `Mod`/`Th` adjunction as an explicit Mathlib `GaloisConnection`, between `Set Formula` and
the order dual of `Set TaskFrame`.

The dual is what turns the antitone pair into a monotone adjoint pair; it is recorded here for
discoverability, so that the connection is findable under Mathlib's own vocabulary. Nothing in
this file is derived from it — the polar lemmas above are dual-free and shorter.
-/
theorem mod_th_gc : GaloisConnection (α := Set Formula) (β := (Set TaskFrame)ᵒᵈ)
    (OrderDual.toDual ∘ Mod) (Th ∘ OrderDual.ofDual) :=
  gc_lowerPolar_upperPolar validOnRel

/-! ## `Mod` and `Th` on unions -/

/-- `Mod` turns unions of formula sets into intersections of model classes. -/
theorem mod_union (S₁ S₂ : Set Formula) : Mod (S₁ ∪ S₂) = Mod S₁ ∩ Mod S₂ :=
  lowerPolar_union _ S₁ S₂

/-- The indexed form of `mod_union`. -/
theorem mod_iUnion {ι : Sort*} (f : ι → Set Formula) : Mod (⋃ i, f i) = ⋂ i, Mod (f i) :=
  lowerPolar_iUnion _ f

/-- Every frame models the empty set of formulas vacuously. -/
theorem mod_empty : Mod ∅ = Set.univ := lowerPolar_empty _

/-- Every formula is vacuously valid on the empty class of frames. -/
theorem th_empty : Th ∅ = Set.univ := upperPolar_empty _

/-! ## Closure -/

/--
A frame class is **Galois-closed** when it is the model class of its own theory — equivalently,
when it is axiomatizable by *some* set of formulas (`galoisClosed_mod` supplies the converse).

This is Mathlib's `Order.IsExtent validOnRel`, which states the "axiomatizable by some set"
reading directly: `K ∈ Set.range Mod`. The fixed-point *equation* `Mod (Th K) = K` is the
equivalent form, and `galoisClosed_iff` is the bridge; the two are equivalent but not
definitionally equal.
-/
abbrev GaloisClosed : Set TaskFrame → Prop := Order.IsExtent validOnRel

/-- Every model class is Galois-closed; this is `mod_th_mod` read as a closure statement. -/
theorem galoisClosed_mod (S : Set Formula) : GaloisClosed (Mod S) := Order.isExtent_lowerPolar

/--
`GaloisClosed K` is equivalent to the fixed-point equation `Mod (Th K) = K`.

`GaloisClosed` is defined as a range membership rather than as this equation, so any consumer
that wants the equation — or that wants to *supply* one, as an `antisymm` argument does — goes
through this bridge.
-/
theorem galoisClosed_iff {K : Set TaskFrame} : GaloisClosed K ↔ Mod (Th K) = K :=
  Order.isExtent_iff

/-- An intersection of Galois-closed frame classes is Galois-closed. -/
theorem galoisClosed_iInter {ι : Sort*} (f : ι → Set TaskFrame)
    (hf : ∀ i, GaloisClosed (f i)) : GaloisClosed (⋂ i, f i) :=
  Order.IsExtent.iInter f hf

/-- The binary form of `galoisClosed_iInter`. -/
theorem galoisClosed_inter {K K' : Set TaskFrame}
    (h : GaloisClosed K) (h' : GaloisClosed K') : GaloisClosed (K ∩ K') :=
  h.inter h'

/-- The class of all task frames is Galois-closed; it is `Mod ∅`. -/
theorem galoisClosed_univ : GaloisClosed (Set.univ : Set TaskFrame) := Order.IsExtent.univ

/--
**The indicator mechanism, factored exactly once.**

To show a frame class `K` is Galois-closed it suffices to exhibit a single formula `φ` that is

* valid on every member of `K` (`hmem : φ ∈ Th K`), and
* valid on *no* frame outside `K` (`hback`, stated positively).

Such a `φ` is an *indicator* for `K`. Both closure corollaries in
`Semantics/Correspondence/Indicator.lean` — for the dense class and for the paper-Discrete class —
are single applications of this lemma at `(Formula.next Formula.top).neg` and
`Formula.next Formula.top` respectively. There is deliberately no per-class copy of the argument.

Note that no proof theory is involved: `φ` need not be an axiom, and the fact that
`Axiom.dense_indicator` happens to be the dense case's indicator is rhetorical rather than
load-bearing.
-/
theorem galoisClosed_of_indicator {K : Set TaskFrame} (φ : Formula)
    (hmem : φ ∈ Th K) (hback : ∀ F : TaskFrame, F.ValidOn φ → F ∈ K) : GaloisClosed K :=
  galoisClosed_iff.mpr
    (Set.Subset.antisymm (fun _ hF => hback _ (hF hmem)) (subset_mod_th K))

/--
**The indicator mechanism, as an iff.** This is the entry point call sites use.

`galoisClosed_of_indicator`'s two hypotheses are the two directions of a single biconditional,
and every correspondence result in this development already produces that biconditional
(`validOn_neg_nextTop_iff`, `validOn_nextTop_iff_isDiscrete`, …). Passing it whole means a
closure corollary is one application with no glue.
-/
theorem galoisClosed_of_indicator_iff {K : Set TaskFrame} (φ : Formula)
    (h : ∀ F : TaskFrame, F.ValidOn φ ↔ F ∈ K) : GaloisClosed K :=
  galoisClosed_of_indicator φ (fun F hF => (h F).mpr hF) (fun F hv => (h F).mp hv)

/-! ## Reified formula sets -/

/--
The set of **axiom instances** permitted at frame class `fc`.

`Axiom` is an inductive family indexed by `Formula`, so `{ax | ax.minFrameClass ≤ fc}` is not
directly a `Set Formula`; the existential reifies it. The condition `h.minFrameClass ≤ fc` is
exactly the side condition carried by `DerivationTree.axiom`, so `AxiomSet fc` is the set of
formulas usable as axiom leaves in an `fc`-derivation.
-/
def AxiomSet (fc : FrameClass) : Set Formula := {φ | ∃ h : Axiom φ, h.minFrameClass ≤ fc}

/--
The **density schema** `GGψ → Gψ`, reified as the set of its instances.

This is `Axiom.density`'s indexing formula read as a set, and is the formula-side input to the
deliverable-(3) statement `Mod densitySchema = {F | F.FwdRec}` at `ℤ`.
-/
def densitySchema : Set Formula :=
  {φ | ∃ ψ : Formula, φ = ψ.allFuture.allFuture.imp ψ.allFuture}

end FormalSystem.Semantics
