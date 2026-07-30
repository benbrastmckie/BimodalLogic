/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.NoGaps
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Singletons
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleMonadicBridge

/-!
# Theorems 4 and 5 at the chronicle bridge

Reynolds 1992, §6 Theorem 4 (printed p.183) and §7 Theorem 5 (printed p.184) — **D1** and **D2**,
the two hypotheses of Doets' theorem — instantiated at the countable dense endpointless Prior
structure satisfying Sep that this repository actually constructs.

`NoGaps.lean` proves Theorem 4 and `Singletons.lean` proves Theorem 5 for **any** structure
satisfying `SemanticPriorU` and `SemanticPriorS` (and, for Theorem 5, Sep) at a given `atomMap`.
`chronicleIsDensePriorSepStructure` (`BXCanonical/Chronicle/ChronicleMonadicBridge.lean`) exhibits
such a structure. This module is the join point: its `priorU`, `priorS` and `sep` fields plug
straight into the remaining hypotheses.

**A definitional identity, machine-checked here.** `Singletons.lean` restates axiom Sep as
`SemanticSepOpen` rather than importing `SemanticSep` from the bridge, to keep that parametric
§6/§7 layer off the bridge's ~280-module closure. `chronicleMonadic_dense_singletons` below passes
`hpack.sep` — a `SemanticSep` — directly into a `SemanticSepOpen` argument. That application
elaborates only if the two are definitionally the same, so the identity is checked rather than
asserted, and neither declaration is modified.

## Why a separate module

Not because of an import cycle — there is none. Computed over every `import` line in
`FormalSystem/` outside `Boneyard/`: `ChronicleMonadicBridge` transitively imports **zero**
`DenseModelSurgery` modules, and `NoGaps` transitively imports **zero** `BXCanonical` modules.
The two closures are disjoint, and `NoGaps.lean` could legally import the bridge today.

The reason is **layering**. `ChronicleMonadicBridge`'s transitive closure is roughly 280 modules —
the whole canonical-model construction. `DenseModelSurgery/` is a low-level, parametric §6 layer
that should not depend on it. Keeping the join in its own leaf module preserves that separation
while still making the instantiation available.

## What this module does and does not buy

It retires the **structure** half of the standing §6 conditionality caveat, **at this one named
structure**: Prior-U, Prior-S and Sep are no longer hypotheses here.

It does **not** retire the caveat. `IsContempEquivDense ε` remains a hypothesis, and `epsTop`
is still the only `ε` this tree can exhibit satisfying it — for which `EndsInGapOnRight` is
empty, so an instantiation at `epsTop` is vacuous. For Theorem 5 the `epsTop` instantiation is
vacuous a second, independent way: `QuotientDenselyOrdered M (epsTop sig)` is unsatisfiable on any
structure with two distinct points (`quotientDenselyOrdered_epsTop_vacuous`, `Singletons.lean`).
Reynolds' actual `ε`, the one defining `∼_M`, is §8 Lemma 12 and is not yet in this tree.
**No §6 or §7 result is discharged by this module.** See `NoGaps.lean`'s
`## Conditionality after Theorem 4` for the full three-condition accounting.
-/

namespace FormalSystem.Metalogic.BXCanonical.Chronicle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
open FormalSystem.Semantics

/-- **Reynolds §6 Theorem 4 at the chronicle bridge — the right-hand end.**

> *Suppose that `∼` is a contemporaneous equivalence relation on a Prior structure `M`. Then the
> `∼`-classes do not end at gaps.*

This is **D1**, the first hypothesis of Doets' theorem, at the structure the completeness route
runs on. `HasBadIntervalSurgery` is discharged inside `no_gaps_dense_prior`; Prior-U and Prior-S
are discharged here by `chronicleIsDensePriorSepStructure`.

`IsContempEquivDense ε` remains a hypothesis, and is the one condition of the three that this
tree cannot yet supply non-trivially. -/
theorem chronicleMonadic_no_gaps {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula)
    {C : OrderedMonadicStructure (mkSigFrom root) → Prop} [IsDualClosed C] [IsSurgeryClosed C]
    [InStructureClass C (chronicleMonadicStructure fc A h_mcs h_box_dense root)]
    {ε : MonadicFormula (mkSigFrom root) 2} (hε : IsContempEquivDenseOn ε C)
    (t : (chronicleMonadicStructure fc A h_mcs h_box_dense root).carrier) :
    ¬ EndsInGapOnRight (chronicleMonadicStructure fc A h_mcs h_box_dense root) ε t :=
  let hpack := chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root
  no_gaps_dense_prior (mkAtomMapFwd root) (mkAtomMapFwd_surj root) hε hpack.priorU hpack.priorS t

/-- **Reynolds §6 Theorem 4 at the chronicle bridge — the left-hand end.**

*"The classes do not end at gaps"* covers both ends; this is `no_gaps_dense_prior_left` with the
same two Prior hypotheses discharged. -/
theorem chronicleMonadic_no_gaps_left {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula)
    {C : OrderedMonadicStructure (mkSigFrom root) → Prop} [IsDualClosed C] [IsSurgeryClosed C]
    [InStructureClass C (chronicleMonadicStructure fc A h_mcs h_box_dense root)]
    {ε : MonadicFormula (mkSigFrom root) 2} (hε : IsContempEquivDenseOn ε C)
    (t : (chronicleMonadicStructure fc A h_mcs h_box_dense root).carrier) :
    ¬ EndsInGapOnLeft (chronicleMonadicStructure fc A h_mcs h_box_dense root) ε t :=
  let hpack := chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root
  no_gaps_dense_prior_left (mkAtomMapFwd root) (mkAtomMapFwd_surj root) hε
    hpack.priorU hpack.priorS t

/-- **Reynolds §7 Theorem 5 at the chronicle bridge.**

> *Suppose that `M` is a Prior structure which also satisfies every substitution instance of axiom
> Sep. Then for every contemporaneous equivalence relation `∼` such that `M/∼` is densely ordered,
> `M/∼` has a dense set of singletons.*

This is **D2**, the second hypothesis of Doets' theorem, at the structure the completeness route
runs on. Prior-U, Prior-S and Sep are all discharged here by `chronicleIsDensePriorSepStructure`;
Theorem 4, which Theorem 5 consumes, is discharged inside `reynolds_theorem5`.

Passing `hpack.sep` (a `SemanticSep`) into `reynolds_theorem5`'s `SemanticSepOpen` argument is the
machine-checked identity the module header describes.

`IsContempEquivDense ε` and the density of `M/∼` remain hypotheses; the former is the one
condition of the three that this tree cannot yet supply non-trivially. -/
theorem chronicleMonadic_dense_singletons {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula)
    {C : OrderedMonadicStructure (mkSigFrom root) → Prop} [IsDualClosed C] [IsSurgeryClosed C]
    [InStructureClass C (chronicleMonadicStructure fc A h_mcs h_box_dense root)]
    {ε : MonadicFormula (mkSigFrom root) 2} (hε : IsContempEquivDenseOn ε C)
    (hdense : QuotientDenselyOrdered
      (chronicleMonadicStructure fc A h_mcs h_box_dense root) ε) :
    HasDenseSingletons (chronicleMonadicStructure fc A h_mcs h_box_dense root) ε :=
  let hpack := chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root
  reynolds_theorem5 (mkAtomMapFwd root) (mkAtomMapFwd_surj root) hε
    hpack.priorU hpack.priorS hpack.sep hdense

/-! ## Anti-vacuity, stated honestly

The two theorems above are conditional on `IsContempEquivDense ε` and nothing else. The only
inhabitant of that predicate this tree can exhibit is `epsTop` (`Defs.lean`'s
`isContempEquivDense_epsTop`), and `not_endsInGapOnRight_epsTop` shows `EndsInGapOnRight` is
empty for it — so instantiating at `epsTop` yields a true but **vacuous** statement, and is
recorded below as exactly that rather than presented as an anti-vacuity witness.

A live non-trivial `ε` is Reynolds' §8 Lemma 12 and is not in this tree. -/

/-- At `epsTop` the conclusion above holds for a reason that has nothing to do with Theorem 4:
`EndsInGapOnRight` is already empty. Recorded so that no reader mistakes the instantiation for
a non-trivial instance of §6. -/
theorem chronicleMonadic_no_gaps_epsTop_vacuous {fc : FrameClass}
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula)
    (t : (chronicleMonadicStructure fc A h_mcs h_box_dense root).carrier) :
    ¬ EndsInGapOnRight (chronicleMonadicStructure fc A h_mcs h_box_dense root)
      (epsTop (mkSigFrom root)) t :=
  not_endsInGapOnRight_epsTop _ t

/-- Theorem 5's `epsTop` instantiation is vacuous for a **second, independent** reason: its
density hypothesis is itself unsatisfiable. `epsTop`'s single class is the whole structure, so
`QuotientDenselyOrdered`'s `¬ ContempEquivDense` antecedent can never be met.

Recorded so that no reader mistakes the instantiation for a non-trivial instance of §7. -/
theorem chronicleMonadic_dense_singletons_epsTop_vacuous {fc : FrameClass}
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula)
    (a b : (chronicleMonadicStructure fc A h_mcs h_box_dense root).carrier) (hab : a < b) :
    ¬ ¬ ContempEquivDense (chronicleMonadicStructure fc A h_mcs h_box_dense root)
      (epsTop (mkSigFrom root)) a b :=
  quotientDenselyOrdered_epsTop_vacuous _ a b hab

/-! ## The class parameterization weakens nothing — machine-checked

§6 is now stated against an arbitrary structure class `C` (`IsContempEquivDenseOn`, `Defs.lean`).
The plan's census gates require that every pre-existing declaration survive **with its conclusion
unweakened**, so the claim that `C := UnrestrictedClass sig` recovers today's results *verbatim* is
checked here rather than asserted.

Each theorem below restates a pre-parameterization signature **exactly** as it stood, with the same
explicit arguments in the same order and the same conclusion, and discharges it by direct
application. Nothing is supplied at the call: `instInStructureClassUnrestricted`,
`instIsDualClosedUnrestricted` and `instIsSurgeryClosedUnrestricted` discharge all three class
obligations by instance search, which is what makes the recovery verbatim rather than merely
equivalent. Had the parameterization narrowed any of these, the corresponding line would not
elaborate.

These are regression checks, not new mathematics, and they are deliberately not `example`s: a named
theorem is what a later census can grep for. -/

section NoWeakening

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}

open FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery in
/-- Theorem 4, right-hand end, at Reynolds' own unrestricted reading — the pre-parameterization
signature of `no_gaps_dense_prior`, verbatim. -/
theorem no_gaps_dense_prior_unrestricted (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) : ¬ EndsInGapOnRight M ε t :=
  no_gaps_dense_prior atomMap h_surj hε h_prior_U h_prior_S t

open FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery in
/-- Theorem 4, left-hand end, at Reynolds' own unrestricted reading — the pre-parameterization
signature of `no_gaps_dense_prior_left`, verbatim. -/
theorem no_gaps_dense_prior_left_unrestricted (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) : ¬ EndsInGapOnLeft M ε t :=
  no_gaps_dense_prior_left atomMap h_surj hε h_prior_U h_prior_S t

open FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery in
/-- Theorem 5 at Reynolds' own unrestricted reading — the pre-parameterization signature of
`reynolds_theorem5`, verbatim. -/
theorem reynolds_theorem5_unrestricted (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (h_sep : SemanticSepOpen M atomMap)
    (hdense : QuotientDenselyOrdered M ε) :
    HasDenseSingletons M ε :=
  reynolds_theorem5 atomMap h_surj hε h_prior_U h_prior_S h_sep hdense

open FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery in
/-- D2 at Reynolds' own unrestricted reading — the pre-parameterization signature of
`dense_singletons_of_sep`, verbatim. -/
theorem dense_singletons_of_sep_unrestricted (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (h_sep : SemanticSepOpen M atomMap) :
    QuotientDenselyOrdered M ε → HasDenseSingletons M ε :=
  dense_singletons_of_sep atomMap h_surj hε h_prior_U h_prior_S h_sep

end NoWeakening

/-- The chronicle-bridge form of Theorem 4's right-hand end at the unrestricted reading — the
pre-parameterization signature of `chronicleMonadic_no_gaps`, verbatim. -/
theorem chronicleMonadic_no_gaps_unrestricted {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula)
    {ε : MonadicFormula (mkSigFrom root) 2} (hε : IsContempEquivDense ε)
    (t : (chronicleMonadicStructure fc A h_mcs h_box_dense root).carrier) :
    ¬ EndsInGapOnRight (chronicleMonadicStructure fc A h_mcs h_box_dense root) ε t :=
  chronicleMonadic_no_gaps hfc A h_mcs h_box_dense root hε t

/-- The chronicle-bridge form of Theorem 4's left-hand end at the unrestricted reading — the
pre-parameterization signature of `chronicleMonadic_no_gaps_left`, verbatim. -/
theorem chronicleMonadic_no_gaps_left_unrestricted {fc : FrameClass}
    (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula)
    {ε : MonadicFormula (mkSigFrom root) 2} (hε : IsContempEquivDense ε)
    (t : (chronicleMonadicStructure fc A h_mcs h_box_dense root).carrier) :
    ¬ EndsInGapOnLeft (chronicleMonadicStructure fc A h_mcs h_box_dense root) ε t :=
  chronicleMonadic_no_gaps_left hfc A h_mcs h_box_dense root hε t

/-- The chronicle-bridge form of Theorem 5 at the unrestricted reading — the
pre-parameterization signature of `chronicleMonadic_dense_singletons`, verbatim. -/
theorem chronicleMonadic_dense_singletons_unrestricted {fc : FrameClass}
    (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula)
    {ε : MonadicFormula (mkSigFrom root) 2} (hε : IsContempEquivDense ε)
    (hdense : QuotientDenselyOrdered
      (chronicleMonadicStructure fc A h_mcs h_box_dense root) ε) :
    HasDenseSingletons (chronicleMonadicStructure fc A h_mcs h_box_dense root) ε :=
  chronicleMonadic_dense_singletons hfc A h_mcs h_box_dense root hε hdense

end FormalSystem.Metalogic.BXCanonical.Chronicle
