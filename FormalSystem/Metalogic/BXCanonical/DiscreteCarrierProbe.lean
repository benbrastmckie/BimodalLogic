/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Algebraic.FlowFrame
import Mathlib.Algebra.Order.Monoid.Prod

/-!
# Discrete carrier probe: the `D`-generic machinery at `D := ℚ ×ₗ ℤ`

This module is the non-Archimedean analogue of the `CarrierProbe` section in the sibling
module `CompletenessDedekind.lean`, which runs the same checks at `D := ℝ`. Here the carrier
is `ℚ ×ₗ ℤ` — the lexicographic product with the rationals dominant — and the `example`s below
exist to fail loudly if the bundle flow machinery
(`Metalogic/Algebraic/FlowFrame.lean`) ever acquires a binder that `ℚ ×ₗ ℤ` cannot discharge
(a `DenselyOrdered`, an `IsSuccArchimedean`, a `Countable`, ...). They are the compile-time
form of the claim that this carrier is admissible for the `FrameClass.Base` layer.

## Why this carrier

`FrameClass.Base` imposes no Archimedean-ness: `Valid` (`FormalSystem/Semantics/Validity.lean`)
binds exactly `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid` and `Nontrivial`. `ℚ ×ₗ ℤ`
discharges all four while being discretely ordered, with successor `(q, n) ↦ (q, n + 1)`, so it
validates `nextTop` everywhere without being Archimedean.

That combination is what `countermodel_discrete` needs, and the obligation this module was
written to scout is now **discharged**: `countermodel_discrete` is proved at this carrier in
`WeakCanonical/GroupModel/CountermodelBase.lean`, off `companionChronicle`
(`WeakCanonical/GroupModel/GroupableCompanion.lean`). Of the two candidate routes, route (i) —
a Base-MCS → Discrete-MCS transfer lemma — is refuted by a `ℤ ×ₗ ℤ` witness, and route (ii),
building the discrete canonical model directly over a non-Archimedean carrier, is the one that
was taken. This module confirms only that the carrier is admissible and that the parametric
machinery elaborates at it; the model itself is built in `CountermodelBase.lean`.

## Contents

Anonymous `example`s only — this module exports nothing. Four instance probes for the
`FrameClass.Base` binders, then the bundle flow frame, model, flow-line history space, and the
load-bearing re-hosted completeness engine, each at `D := ℚ ×ₗ ℤ`.

## References

- Sibling probe at `D := ℝ`: `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean`.
- Target declarations: `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`.
- The obligation this carrier is proposed for: `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`.
-/

namespace FormalSystem.Metalogic.BXCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Semantics
open FormalSystem.Metalogic.Algebraic

section DiscreteCarrierProbe

variable {fc : FrameClass}

/-! ### `ℚ ×ₗ ℤ` discharges the four `FrameClass.Base` binders -/

example : AddCommGroup (ℚ ×ₗ ℤ) := inferInstance
example : LinearOrder (ℚ ×ₗ ℤ) := inferInstance
example : IsOrderedAddMonoid (ℚ ×ₗ ℤ) := inferInstance
example : Nontrivial (ℚ ×ₗ ℤ) := inferInstance

/-! ### The bundle flow machinery elaborates at `ℚ ×ₗ ℤ` -/

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) :
    FrameOver (TemporalOrder.of (ℚ ×ₗ ℤ)) :=
  bundleFlowFrame B

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) : TaskModel (bundleFlowFrame B) :=
  bundleFlowModel B

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) :
    Set (WorldHistory (bundleFlowFrame B)) :=
  {σ | ∀ t, σ.domain t}

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) (root : Formula)
    (h_rtc : B.RestrictedTemporallyCoherent root)
    (h_buc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_fuc : B.RestrictedForwardUntilSinceCoherent root)
    (φ : Formula) (h_sub : φ ∈ subformulaClosure root)
    (fam : FMCS (fc := fc) (ℚ ×ₗ ℤ)) (hfam : fam ∈ B.families)
    (w₀ t : ℚ ×ₗ ℤ) (h_neg_in : φ.neg ∈ fam.mcs (w₀ + t)) :
    ¬TruthAt (bundleFlowModel B) (bundleFlowHistory ⟨fam, hfam⟩ w₀) t φ :=
  bundleFlow_completeness_from_neg_membership B root ⟨h_rtc, h_fuc, h_buc⟩ φ h_sub
    ⟨fam, hfam⟩ w₀ t h_neg_in

end DiscreteCarrierProbe

end FormalSystem.Metalogic.BXCanonical
