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
* That construction is written **once**, as `modelExistence_of_satPreserved`, parameterized by a
  single hypothesis `hpres` saying that `fc.Sat` survives the ultraproduct. `modelExistenceBase`
  and `modelExistenceDense` are its two instantiations; they used to be two copies of the body.
  `hpres` is false at `.Discrete` and `.Dedekind`, which is why only two rows of the table are
  proved here — see that theorem's docstring.
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

/-- **The frame condition survives `ShiftSet.ofModel`.**

`ShiftSet.ofModel F M` is a shift set on `F.Duration`, but `(ShiftSet.ofModel F M).frame` is
**not** `F`: its carrier is `F.HF`, the total histories of `F`, so a `fc.Sat F` hypothesis does
not land on it by `rfl` and the two frames are genuinely different objects. It does transport,
because every `FrameClass.Sat` clause constrains the *duration* order alone and `ofModel` leaves
that order untouched — so case analysis on the tag closes all four branches with the hypothesis
handed straight back.

Homed in this module rather than in `Semantics/ShiftSet.lean`: its only consumer is
`modelExistence_of_satPreserved` immediately below. The converse
(`fc.Sat F` from `fc.Sat (ofModel F M).frame`) is deliberately not stated — nothing wants it. -/
theorem sat_ofModel_frame {fc : ProofSystem.FrameClass} {F : TaskFrame} (M : TaskModel F)
    (h : fc.Sat F) :
    fc.Sat (ShiftSet.ofModel F M).frame := by
  cases fc <;> exact h

/--
**Model existence at any frame class whose `Sat` survives the ultraproduct.**

The one model-existence proof. `modelExistenceBase` and `modelExistenceDense` below were, before
this generalization, two copies of the body verbatim, differing only in what they put in the
frame-condition slot of the witness; that slot is now the single hypothesis `hpres`, and the
construction — index by `Idx Γ`, choose a witness per index, shift-set each one, combine by
`uShiftSet (idxUF Γ)`, and pull truth back through Łoś — is written once.

**What `hpres` says, and why it is the whole of the class-dependence.** Given an ultrafilter and
a family of shift sets each of whose frames satisfies `fc`, the ultraproduct's frame satisfies
`fc` too. Nothing else about `fc` enters: the index type, the ultrafilter, the choice of
witnesses and the Łoś transport are all uniform in the tag.

**`hpres` is false at `.Discrete` and at `.Dedekind`, and that is not a gap in this proof.** An
ultraproduct of Archimedean orders need not be Archimedean, and an ultraproduct of
Dedekind-complete orders need not be Dedekind-complete — the standard nonstandard-analysis
phenomenon, in both cases. So this route is unavailable at those two tags, and no reformulation
of `hpres` recovers it: `discrete_consequence_not_compact`
(`Metalogic/DiscreteNonCompactness.lean`) and `dedekind_consequence_not_compact`
(`Metalogic/DedekindNonCompactness.lean`) *refute* compactness at those classes outright, and
`compact_of_modelExistence` would turn a model-existence proof into exactly the compactness
those two theorems deny. The failure of `hpres` at half the table is therefore the machine-checked
shape of a real mathematical obstruction, not a missing lemma.

**`T` is an explicit binder on purpose.** With it implicit, the `S i` projection in the Dense
discharge below elaborates against `S : I → TemporalOrder` and fails with `Invalid field 'frame'`;
`I` may stay implicit because the application sites determine it from `u`.
-/
theorem modelExistence_of_satPreserved {fc : ProofSystem.FrameClass}
    (hpres : ∀ {I : Type} (u : Ultrafilter I) (T : I → TemporalOrder)
      (S : ∀ i, ShiftSet (T i)), (∀ i, fc.Sat (S i).frame) → fc.Sat (uShiftSet u S).frame) :
    ModelExistence fc := by
  classical
  intro Γ hfin
  -- `SatisfiableSet` is `Nonempty (PointedModel …)`, not a bare `∃`-chain, so `choose` does not
  -- apply here; `Nonempty.some` extracts the per-index witness instead, and its named fields
  -- replace what `choose`'s six output names used to stand for.
  let P : ∀ i : Idx Γ, PointedModel fc {ψ | ψ ∈ i.val} := fun i => (hfin i.val i.property).some
  refine SatisfiableSet.of_forall
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (P i).Frame (P i).Model)).frame
    (hpres (idxUF Γ) (fun i => (P i).Frame.Duration)
      (fun i => ShiftSet.ofModel (P i).Frame (P i).Model)
      (fun i => sat_ofModel_frame (P i).Model (P i).inClass))
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (P i).Frame (P i).Model)).model
    ((uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (P i).Frame (P i).Model)).hist
      (omk (fun i => (⟨(P i).hist, (P i).htotal⟩ : (P i).Frame.HF))))
    (ShiftSet.hist_isTotal _ _) (Ultraproduct.mk (fun i => (P i).time)) ?_
  intro ψ hψ
  refine (los_truthAt (fun i => ShiftSet.ofModel (P i).Frame (P i).Model) _ _ ψ).mpr ?_
  refine (eventually_mem Γ hψ).mono ?_
  intro i hi
  exact (ShiftSet.forward_repr _ _ _ ψ).mpr
    ((ShiftSet.reverse_repr (P i).Frame (P i).Model ⟨(P i).hist, (P i).htotal⟩ (P i).time ψ).mpr
      ((P i).models ψ hi))

/--
**Model existence for `FrameClass.Base`.** Every finitely satisfiable `Γ : Set Formula` has a
single model satisfying all of `Γ` at once.

`modelExistence_of_satPreserved` at `.Base`, where `Sat .Base` is `True` and the preservation
hypothesis is discharged by `trivial` with nothing to check.
-/
theorem modelExistenceBase : ModelExistenceBase :=
  modelExistence_of_satPreserved (fun _ _ _ _ => trivial)

/--
**Model existence for `FrameClass.Dense`.** `modelExistence_of_satPreserved` at `.Dense`, where
the preservation hypothesis is a real obligation and is discharged by instance synthesis.

`Sat .Dense` unfolds to `DenselyOrdered` on the duration, so `hS` is precisely a family of
density instances on the per-index durations. Reinstalling that family with `haveI` lets synthesis
find the ultraproduct's own `DenselyOrdered` instance (declared in
`Semantics/Ultraproduct/Carrier.lean`); this installs a *new* instance family on the per-index
durations rather than re-installing one already baked into a frame's type, which is why it is
safe here.
-/
theorem modelExistenceDense : ModelExistenceDense :=
  modelExistence_of_satPreserved (fun u T S hS => by
    haveI : ∀ i, DenselyOrdered ((S i).frame.Duration : Type) := hS
    exact (inferInstance : DenselyOrdered (uShiftSet u S).frame.Duration))

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

`sat_ofModel_frame` and `modelExistence_of_satPreserved` are reductions; the other six
declarations of this module are termini, with no hypothesis left undischarged. Each is expected
to report exactly `propext`, `Classical.choice` and `Quot.sound`,
the same set carried by the engines and by the ultraproduct layer they consume, with `sorryAx`
absent throughout. `strongCompletenessBase` and `strongCompletenessDense` are additionally
pinned by the C14 headline axiom baseline in `scripts/check-module-invariants.sh`. -/

#print axioms sat_ofModel_frame
#print axioms modelExistence_of_satPreserved
#print axioms modelExistenceBase
#print axioms modelExistenceDense
#print axioms compactBase
#print axioms compactDense
#print axioms strongCompletenessBase
#print axioms strongCompletenessDense

end FormalSystem.Metalogic
