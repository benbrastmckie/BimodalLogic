/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Validity

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

This module imports `Semantics/Validity.lean` only. `Validity.lean` already imports
`FrameClassValidity.lean`, which is the single documented `Semantics → ProofSystem` edge, so
`ProofSystem.Axioms` arrives transitively and no new seam is opened here.

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

## Main results

* `Th`, `Mod` — the two maps
* `th_anti`, `mod_anti` — antitonicity
* `subset_mod_th`, `subset_th_mod` — the two inflationary round trips
* `mod_th_mod`, `th_mod_th` — the triple-composite collapses
* `GaloisClosed`, `galoisClosed_mod` — the fixed points, and that every `Mod S` is one
* `galoisClosed_of_indicator` — the indicator mechanism, factored exactly once
* `AxiomSet`, `densitySchema` — the two reified formula sets
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax FormalSystem.ProofSystem

/-! ## The two maps -/

/--
The **theory** of a class of frames: the formulas valid on every member.

`Th` is the right adjoint of the connection; it takes unions of frame classes to intersections of
theories, which is antitonicity (`th_anti`).
-/
def Th (K : Set TaskFrame) : Set Formula := {φ | ∀ F ∈ K, F.ValidOn φ}

/--
The **model class** of a set of formulas: the frames validating every member.

`Mod` is the left adjoint. Its image is exactly the collection of Galois-closed frame classes
(`galoisClosed_mod`), which is what makes "is this class axiomatizable?" and "is this class
Galois-closed?" the same question.
-/
def Mod (S : Set Formula) : Set TaskFrame := {F | ∀ φ ∈ S, F.ValidOn φ}

/-! ## Antitonicity and the round trips -/

/-- `Th` is antitone: a larger frame class has a smaller theory. -/
theorem th_anti {K₁ K₂ : Set TaskFrame} (h : K₁ ⊆ K₂) : Th K₂ ⊆ Th K₁ :=
  fun _ hφ F hF => hφ F (h hF)

/-- `Mod` is antitone: a larger formula set has a smaller model class. -/
theorem mod_anti {S₁ S₂ : Set Formula} (h : S₁ ⊆ S₂) : Mod S₂ ⊆ Mod S₁ :=
  fun _ hF φ hφ => hF φ (h hφ)

/-- The frame-side round trip is inflationary: every frame models its own class's theory. -/
theorem subset_mod_th (K : Set TaskFrame) : K ⊆ Mod (Th K) :=
  fun _ hF _ hφ => hφ _ hF

/-- The formula-side round trip is inflationary: every formula is in the theory of its models. -/
theorem subset_th_mod (S : Set Formula) : S ⊆ Th (Mod S) :=
  fun _ hφ _ hF => hF _ hφ

/-- The frame-side triple composite collapses. -/
theorem mod_th_mod (S : Set Formula) : Mod (Th (Mod S)) = Mod S :=
  Set.Subset.antisymm (mod_anti (subset_th_mod S)) (subset_mod_th (Mod S))

/-- The formula-side triple composite collapses. -/
theorem th_mod_th (K : Set TaskFrame) : Th (Mod (Th K)) = Th K :=
  Set.Subset.antisymm (th_anti (subset_mod_th K)) (subset_th_mod (Th K))

/-! ## Closure -/

/--
A frame class is **Galois-closed** when it is the model class of its own theory — equivalently,
when it is axiomatizable by *some* set of formulas (`galoisClosed_mod` supplies the converse).
-/
def GaloisClosed (K : Set TaskFrame) : Prop := Mod (Th K) = K

/-- Every model class is Galois-closed; this is `mod_th_mod` read as a closure statement. -/
theorem galoisClosed_mod (S : Set Formula) : GaloisClosed (Mod S) := mod_th_mod S

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
  Set.Subset.antisymm (fun F hF => hback F (hF φ hmem)) (subset_mod_th K)

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
