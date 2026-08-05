/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.RealModel.DoetsTheorem
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.ChronicleInstance

/-!
# Doets' theorem at the chronicle bridge — the `ℝ`-flowed structure

Reynolds 1992, §8 Theorem 6 (`doets_theorem_dense`, `RealModel/DoetsTheorem.lean`) instantiated at
`chronicleMonadicStructure`, the countable dense endpointless Prior structure satisfying Sep that
this repository actually constructs (`chronicleIsDensePriorSepStructure`,
`BXCanonical/Chronicle/ChronicleMonadicBridge.lean`).

## What this module discharges

`doets_theorem_dense` takes five order-theoretic instances and the two hypotheses **D1** and **D2**.
All seven are supplied here, none of them assumed:

* `Countable` / `DenselyOrdered` / `NoMaxOrder` / `NoMinOrder` — the `countable`, `denselyOrdered`,
  `noMax`, `noMin` fields of `chronicleIsDensePriorSepStructure`, Reynolds' §9 *"the flow of time of
  `M` is countable, dense and without end points"*; `Nonempty` because the carrier is `ℚ`.
* **D1** — `chronicleMonadic_no_gaps` and `chronicleMonadic_no_gaps_left`
  (`DenseModelSurgery/ChronicleInstance.lean`), §6 Theorem 4 at both ends, at
  `C := CountableDense (mkSigFrom root)`.
* **D2** — `chronicleMonadic_dense_singletons`, §7 Theorem 5, at the same class.

## Why this is not vacuous

The standing §6 caveat had three conditions — Prior-U, Prior-S, Sep, and a live `ε`.
`ChronicleInstance.lean` retired the first three at this structure and recorded, honestly, that the
fourth was still open: `epsTop` was the only `ε` the tree could exhibit satisfying the
**unrestricted** `IsContempEquivDense`, and at `epsTop` both Theorem 4 and Theorem 5 are vacuous —
`EndsInGapOnRight` is empty (`chronicleMonadic_no_gaps_epsTop_vacuous`) and
`QuotientDenselyOrdered` is unsatisfiable (`chronicleMonadic_dense_singletons_epsTop_vacuous`).

Neither escape hatch is taken here. `DoetsD1` and `DoetsD2` quantify over **every** `ε` satisfying
`IsContempEquivDenseOn ε (CountableDense (mkSigFrom root))`, so the two theorems below are proved at
an arbitrary such `ε`, not at a chosen convenient one; and `doets_theorem_dense` then *consumes*
them at `ε := epsDense (mkSigFrom root) k` — Reynolds' own `∼_M` of §8 Lemma 12
(`doetsD1_epsDense` / `doetsD2_epsDense`, `DoetsTheorem.lean`), for which
`epsDense_isContempEquivDenseOn_countableDense` (`RealModel/EpsilonDense.lean`) is the witness. So
the `ε` at which D1 and D2 actually do work in the proof of `chronicleRealFlow_kEquiv` is the live
one, and neither of the two `epsTop` degeneracies is in the picture.

What makes that possible, and what was not available when the caveat was written, is that §6 is now
stated against a structure class (`IsContempEquivDenseOn ε C`, `DenseModelSurgery/Defs.lean`) rather
than against the unrestricted reading alone. `epsDense` satisfies the class-restricted bundle at
`C := CountableDense`; it does **not** satisfy the unrestricted one, and that is a theorem-shaped
fact about `∼_M`, not a gap — the counterexample is in `EpsilonDense`'s module header.

## Why a separate module

The same layering reason `ChronicleInstance.lean` records for itself. `RealModel/` is the parametric
§8 layer and must not depend on the chronicle's ~280-module closure; `ChronicleMonadicBridge` must
not depend on §8. There is no cycle either way — this is a leaf that imports both sides and is
imported by neither.

## Source map

| Reynolds 1992 | Here |
|---|---|
| §8 Theorem 6, printed pp.185-188 | `doets_theorem_dense` (imported) |
| §9, *"D1 and D2 follow from Theorems 4 and 5"* | `chronicleMonadic_doetsD1`, `chronicleMonadic_doetsD2` |
| §9, *"there is a structure with flow of time `ℝ` …"* | `chronicleRealFlow`, `chronicleRealFlow_kEquiv` |
-/

namespace FormalSystem.Metalogic.BXCanonical.Chronicle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
open FormalSystem.Semantics

/-- **D1 at the chronicle bridge** — *"the `∼` classes do not end in gaps"*, for **every**
contemporaneous equivalence relation on the countable dense class, at both ends.

This is `DoetsD1` discharged rather than hypothesized: the two ends are
`chronicleMonadic_no_gaps` and `chronicleMonadic_no_gaps_left`, §6 Theorem 4 with Prior-U and
Prior-S supplied by `chronicleIsDensePriorSepStructure`. The class membership
`InStructureClass (CountableDense _) _` that §6's surgery constructions need is resolved by
instance search from the bridge's own `countable` and `denselyOrdered` fields; it cannot be a
global instance because `h_mcs` and `h_box_dense` are non-class explicit arguments. -/
theorem chronicleMonadic_doetsD1 {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) :
    DoetsD1 (mkSigFrom root) (chronicleMonadicStructure fc A h_mcs h_box_dense root) := by
  intro ε hε t
  haveI := (chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root).countable
  haveI := (chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root).denselyOrdered
  exact ⟨chronicleMonadic_no_gaps hfc A h_mcs h_box_dense root hε t,
    chronicleMonadic_no_gaps_left hfc A h_mcs h_box_dense root hε t⟩

/-- **D2 at the chronicle bridge** — *"if `M/∼` is densely ordered then `M/∼` has a dense set of
singletons"*, for every contemporaneous equivalence relation on the countable dense class.

`DoetsD2` discharged from `chronicleMonadic_dense_singletons`, §7 Theorem 5, with Prior-U, Prior-S
and Sep all supplied by `chronicleIsDensePriorSepStructure`. -/
theorem chronicleMonadic_doetsD2 {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) :
    DoetsD2 (mkSigFrom root) (chronicleMonadicStructure fc A h_mcs h_box_dense root) := by
  intro ε hε hq
  haveI := (chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root).countable
  haveI := (chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root).denselyOrdered
  exact chronicleMonadic_dense_singletons hfc A h_mcs h_box_dense root hε hq

/-- **Doets' theorem at the chronicle bridge.**

> *… there is a temporal structure with flow of time the real numbers satisfying the same monadic
> first-order sentences of quantifier depth at most `k` as `M` does.*

Every hypothesis of `doets_theorem_dense` is discharged: the four order conditions from
`chronicleIsDensePriorSepStructure`, `Nonempty` from the carrier `ℚ`, and D1/D2 from §6 Theorem 4
and §7 Theorem 5 at this structure. Nothing is left as an assumption but `hfc`, `h_mcs`,
`h_box_dense` and `hk : 2 ≤ k`, which are the chronicle's own. -/
theorem exists_chronicleRealFlow {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) (k : Nat) (hk : 2 ≤ k) :
    ∃ R : RIntervalStructure (mkSigFrom root), R.IsRealFlow ∧
      KEquiv (mkSigFrom root) k (chronicleMonadicStructure fc A h_mcs h_box_dense root)
        (R.toOrdered (mkSigFrom root)) := by
  haveI := (chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root).countable
  haveI := (chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root).denselyOrdered
  haveI := (chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root).noMax
  haveI := (chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root).noMin
  haveI : Nonempty (chronicleMonadicStructure fc A h_mcs h_box_dense root).carrier :=
    inferInstanceAs (Nonempty Rat)
  exact doets_theorem_dense (mkSigFrom root) k hk _
    (chronicleMonadic_doetsD1 hfc A h_mcs h_box_dense root)
    (chronicleMonadic_doetsD2 hfc A h_mcs h_box_dense root)

/-- **The `ℝ`-flowed structure `≡ₖ`-equivalent to the chronicle model**, named.

This is the deliverable of Reynolds' Block H: a temporal structure whose flow of time is the real
line and which is indistinguishable from the chronicle bridge by monadic first-order sentences of
quantifier depth at most `k`. `chronicleRealFlow_isRealFlow` and `chronicleRealFlow_kEquiv` are its
two defining properties.

Noncomputable, and irreducibly so: the structure is extracted from Theorem 6's existential, whose
proof chooses a minimal `γ`-palette and a shuffle. -/
noncomputable def chronicleRealFlow {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) (k : Nat) (hk : 2 ≤ k) :
    RIntervalStructure (mkSigFrom root) :=
  (exists_chronicleRealFlow hfc A h_mcs h_box_dense root k hk).choose

/-- **`chronicleRealFlow`'s flow of time is `ℝ`** — the first half of Theorem 6's conclusion. -/
theorem chronicleRealFlow_isRealFlow {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) (k : Nat) (hk : 2 ≤ k) :
    (chronicleRealFlow hfc A h_mcs h_box_dense root k hk).IsRealFlow :=
  (exists_chronicleRealFlow hfc A h_mcs h_box_dense root k hk).choose_spec.1

/-- **`chronicleRealFlow` satisfies the same depth-`k` monadic sentences as the chronicle model** —
the second half of Theorem 6's conclusion, and the property Reynolds' §9 consumes. -/
theorem chronicleRealFlow_kEquiv {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) (k : Nat) (hk : 2 ≤ k) :
    KEquiv (mkSigFrom root) k (chronicleMonadicStructure fc A h_mcs h_box_dense root)
      ((chronicleRealFlow hfc A h_mcs h_box_dense root k hk).toOrdered (mkSigFrom root)) :=
  (exists_chronicleRealFlow hfc A h_mcs h_box_dense root k hk).choose_spec.2

end FormalSystem.Metalogic.BXCanonical.Chronicle
