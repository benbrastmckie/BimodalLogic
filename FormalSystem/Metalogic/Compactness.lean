/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.StrongCompleteness
import FormalSystem.Semantics.Ultraproduct.Los
import FormalSystem.Semantics.Ultraproduct.IndexFilter

/-!
# Compactness and Strong Completeness for `FrameClass.Base` and `FrameClass.Dense`

This module **discharges** the four statements that
`FormalSystem/Metalogic/SetConsequence.lean` introduces as vocabulary —
`ModelExistenceBase`, `ModelExistenceDense`, `CompactBase`, `CompactDense` — and collects the
two strong-completeness results they unlock, `StrongCompletenessBase` and
`StrongCompletenessDense`. All six are proved here unconditionally.

## The route

Compactness for a possibly-infinite premise set is obtained by an **ultraproduct** construction,
not by the `BXCanonical` chronicle machinery. `FormalSystem/Metalogic/StrongCompleteness.lean`
records why: a chronicle is coherent relative to a single `Finset` subformula root, whereas an
arbitrary `Γ : Set Formula` needs coherence over `⋃_{ψ ∈ Γ} subformulaClosure ψ`, which is not a
`Finset` and has no single root. The ultraproduct route sidesteps that obstruction entirely by
building the model out of the finitely-satisfiable fragments rather than out of a single
saturated chronicle.

The construction, in outline:

* The index type is `Ultraproduct.Idx Γ` (`FormalSystem/Semantics/Ultraproduct/IndexFilter.lean`),
  the finite lists drawn from `Γ`. `Ultraproduct.idxUF Γ` is an ultrafilter on it for which
  `Ultraproduct.eventually_mem` says each `ψ ∈ Γ` belongs to eventually every index list.
* Finite satisfiability supplies, per index, a frame/model/history/time witness. Each such
  witness is turned into a shift set by `ShiftSet.ofModel`, and the pointwise family is combined
  by `Ultraproduct.uShiftSet`, which needs no side hypotheses.
* Łoś's theorem for this construction, `Ultraproduct.los_truthAt`, transports truth at the
  ultraproduct back to eventual truth along the family. `ShiftSet.forward_repr` and
  `ShiftSet.reverse_repr` mediate between the orbit-history form Łoś speaks about and truth in
  the original per-index models.
* For the Dense branch, the per-index density hypotheses are reinstalled as an instance family
  so that the `DenselyOrdered` instance on the ultraproduct duration (declared in
  `FormalSystem/Semantics/Ultraproduct/Carrier.lean`) is found by synthesis.

## The capstone

`compactBase` and `compactDense` are then immediate from the single `FrameClass`-generic bridge
`compact_of_modelExistence` in `FormalSystem/Metalogic/StrongCompleteness.lean`, and the two
strong-completeness results follow from the single reduction `strongCompleteness_of_compact` by
supplying the weak-completeness engines `completeness_base` and `completeness_dense` from that
same module. Both were per-class duplicates before the `FrameClass`-indexing collapse; each is
now one declaration, applied at two tags.

That reduction remains **engine-generic**: the `engine` parameter is supplied at the call site
here, not removed from the declaration. It states, on its own, that compactness is the whole of
the remaining gap between weak and strong completeness, and that statement is worth having
independently of this module's instantiation of it.

## Status of the four `FrameClass` cases

* `FrameClass.Discrete` — compactness and strong completeness are **refuted**, in
  `FormalSystem/Metalogic/DiscreteNonCompactness.lean`.
* `FrameClass.Base` and `FrameClass.Dense` — **proved**, here.
* `FrameClass.Dedekind` — compactness and strong completeness are **refuted** too, in
  `FormalSystem/Metalogic/DedekindNonCompactness.lean`, by a different witness (`archWitness`
  does not port: `Formula.next` is vacuous on a densely ordered carrier). Reynolds 1992
  Theorem 7 remains the *weak* completeness result for the class.
-/

open Filter FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.Semantics.Ultraproduct

namespace FormalSystem.Metalogic

/--
**Model existence for `FrameClass.Base`.** Every finitely satisfiable `Γ : Set Formula` has a
single model satisfying all of `Γ` at once.

The witness is the ultraproduct, over `idxUF Γ`, of the per-index models supplied by finite
satisfiability. `eventually_mem` puts each `ψ ∈ Γ` in eventually every index list, and
`los_truthAt` converts that eventual per-index truth into truth at the ultraproduct.
-/
theorem modelExistenceBase : ModelExistenceBase := by
  classical
  intro Γ hfin
  choose F _hF M τ hτ t ht using fun (i : Idx Γ) => hfin i.val i.property
  refine ⟨(uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame,
    trivial,
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).model,
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).hist
      (omk (fun i => (⟨τ i, hτ i⟩ : (F i).HF))),
    ShiftSet.hist_isTotal _ _, Ultraproduct.mk (fun i => t i), ?_⟩
  intro ψ hψ
  refine (los_truthAt (fun i => ShiftSet.ofModel (F i) (M i)) _ _ ψ).mpr ?_
  refine (eventually_mem Γ hψ).mono ?_
  intro i hi
  exact (ShiftSet.forward_repr _ _ _ ψ).mpr
    ((ShiftSet.reverse_repr (F i) (M i) ⟨τ i, hτ i⟩ (t i) ψ).mpr (ht i ψ hi))

/--
**Model existence for `FrameClass.Dense`.** As `modelExistenceBase`, with the density of the
witness frame carried through the construction.

`SatisfiableDenseSet` carries an extra frame-condition binder per index, so `choose` extracts
one more component. Reinstalling that family as an instance with `haveI` lets instance synthesis
find the ultraproduct's own `DenselyOrdered` instance; this installs a *new* instance family on
the per-index durations rather than re-installing one already baked into a frame's type, which
is why it is safe here.

**Why the witness slot is type-ascribed.** Since `SatisfiableDenseSet` became
`SatisfiableSet FrameClass.Dense`, that slot's type is `FrameClass.Sat .Dense F`, which unfolds
to `TaskFrame.IsDense F` — a plain `def` whose head symbol is not `DenselyOrdered`. Instance
synthesis reduces only at reducible transparency, so a **bare** `inferInstance` cannot see
through it and fails with `type class instance expected`. Ascribing the expected type names
`DenselyOrdered …` directly, synthesis succeeds there, and the result unifies with `Sat .Dense F`
by ordinary definitional unfolding. This is the same invisibility already recorded on
`SetSemanticConsequenceDense.of_forall` (`Metalogic/SetConsequence.lean`), and the reason the
`SatisfiableSet.*_of_forall` adapters take their frame conditions as instance arguments.
-/
theorem modelExistenceDense : ModelExistenceDense := by
  classical
  intro Γ hfin
  choose F hd M τ hτ t ht using fun (i : Idx Γ) => hfin i.val i.property
  haveI : ∀ i, DenselyOrdered ((F i).Duration : Type) := hd
  refine ⟨(uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame,
    (inferInstance : DenselyOrdered
      (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame.Duration),
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).model,
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).hist
      (omk (fun i => (⟨τ i, hτ i⟩ : (F i).HF))),
    ShiftSet.hist_isTotal _ _, Ultraproduct.mk (fun i => t i), ?_⟩
  intro ψ hψ
  refine (los_truthAt (fun i => ShiftSet.ofModel (F i) (M i)) _ _ ψ).mpr ?_
  refine (eventually_mem Γ hψ).mono ?_
  intro i hi
  exact (ShiftSet.forward_repr _ _ _ ψ).mpr
    ((ShiftSet.reverse_repr (F i) (M i) ⟨τ i, hτ i⟩ (t i) ψ).mpr (ht i ψ hi))

/-- **Compactness for `FrameClass.Base`**, from model existence via the class-generic bridge
`compact_of_modelExistence`. `ModelExistenceBase` *is* `ModelExistence .Base` and `CompactBase`
*is* `Compact .Base`, definitionally, so the bridge applies with no transport. -/
theorem compactBase : CompactBase := compact_of_modelExistence modelExistenceBase

/-- **Compactness for `FrameClass.Dense`**, by the same route as `compactBase`. -/
theorem compactDense : CompactDense := compact_of_modelExistence modelExistenceDense

/--
**Strong completeness for `FrameClass.Base`**, unconditionally: `Γ ⊨ φ → Γ ⊢ φ` for arbitrary
`Γ : Set Formula`.

Obtained from the class-generic reduction `strongCompleteness_of_compact` by supplying
`compactBase` and the weak-completeness engine `completeness_base`. The reduction's `engine`
parameter is instantiated here, not eliminated.
-/
theorem strongCompletenessBase : StrongCompletenessBase :=
  strongCompleteness_of_compact compactBase completeness_base

/--
**Strong completeness for `FrameClass.Dense`**, unconditionally, by the same route as
`strongCompletenessBase` with `compactDense` and `completeness_dense`.
-/
theorem strongCompletenessDense : StrongCompletenessDense :=
  strongCompleteness_of_compact compactDense completeness_dense

/-! ### Axiom audit

All six declarations of this module are termini, not reductions: no hypothesis remains
undischarged. Each is expected to report exactly `propext`, `Classical.choice` and `Quot.sound`,
the same set carried by the engines and by the ultraproduct layer they consume, with `sorryAx`
absent throughout. `strongCompletenessBase` and `strongCompletenessDense` are additionally
pinned by the C14 headline axiom baseline in `scripts/check-module-invariants.sh`. -/

#print axioms modelExistenceBase
#print axioms modelExistenceDense
#print axioms compactBase
#print axioms compactDense
#print axioms strongCompletenessBase
#print axioms strongCompletenessDense

end FormalSystem.Metalogic
