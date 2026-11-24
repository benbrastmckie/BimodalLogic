/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.IntTruth
import FormalSystem.Metalogic.Decidability.Verified.Bridge.BoxSaturation
import FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionLabel
import FormalSystem.Metalogic.Decidability.Verified.Bridge.TemporalGate
import FormalSystem.Metalogic.Decidability.Verified.Bridge.BranchOrder
import BimodalLib.Countermodel

/-!
# The branch gates, bundled

The GATED TABLEAU grade admits an open saturated branch as a refutation when it passes the
gates, with the gate theorem applied. This module bundles the gates as one decidable `Bool` and
proves the bridge once, so that an entry discharges its gates by `decide` on finite data.

## No tableau is rebuilt in the kernel

**None of the four gate theorems requires that the branch came from `buildTableau`.** Soundness
rests on the gates alone: `not_valid_of_hasOpen_int` takes the five check flags, the two
`none` results and the root denial, and nothing else. That is what makes an explicit-branch
entry both cheap and sound.

The alternative shape — a `gatedRefuted φ fc : Bool` matching on `buildTableau φ (soundFuel φ)
fc` and discharged by `decide` — asks the kernel to evaluate the whole tableau construction once
per entry. It is deliberately **not** taken here: it was never measured, and the explicit-branch
form sidesteps the question entirely. `native_decide` is barred in this library and is not a
fallback for either shape.

## Two gate bundles in the tree

`BimodalTools.TableauBridge` carries the other bundle, `BranchGates`/`evalBranchGates`.
`lakefile.toml` forbids the `BimodalLib -> BimodalTools` edge outright, so duplicating the
conjunction here is the only route open, and the two bundles must agree.
`Tests/BimodalLibTest/GateAgreementTest.lean` pins that agreement — the test library may import
both, and `BimodalLib` itself may not.

## Main definitions

* `BimodalLib.gatesOK`: the eight gates of `not_valid_of_hasOpen_int`, plus the root-denial
  pair, as one `Bool` over `FormalSystem` primitives only.

## Main statements

* `BimodalLib.not_genericConsequenceIn_of_gatesOK`: the gate bridge. A gated open branch denying
  `φ` refutes `φ` as a consequence of the empty premise list. The conclusion is at
  `FrameClass.Base` whatever `fc` the branch's closure check was run at, because
  `not_valid_of_hasOpen_int` concludes `¬ Valid χ`; `fc` is the class fed to `findClosure`, not
  the class of the conclusion.

## Tags

countermodel · tableau · gates · decide · gated-tableau
-/

namespace BimodalLib

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.Verified.Bridge

/--
The gates of `not_valid_of_hasOpen_int`, bundled as one decidable `Bool`: the five check flags,
the saturation and closure searches coming back empty, and the root-denial pair that says the
branch denies `φ` at the initial label and that that label's world is known.

Every conjunct is a `FormalSystem` primitive over a `Branch`, which is a plain
`List SignedFormula`, so the whole bundle is decidable on finite data.
-/
def gatesOK (φ : Formula) (fc : FrameClass) (b : Branch) (ord : TimeOrdering) : Bool :=
  timeOrderTotal b ord && boxAnchoredCheck b && regionLabelCheck b ord
    && temporalWitnessCheck b ord && branchOrderValid b ord
    && (findUnexpanded b (timeOrd := ord)).isNone && (findClosure b fc).isNone
    && b.hasNegAt φ Label.initial && b.knownWorlds.contains Label.initial.world

/--
**The gate bridge.** A branch passing `gatesOK` and denying `φ` at its initial label refutes `φ`
as a consequence of the empty premise list.

The `knownWorlds` conjunct is taken apart with `List.contains_iff_mem`; `List.contains_iff` is
deprecated and its deprecation warning would fail a `--wfail` build.
-/
theorem not_genericConsequenceIn_of_gatesOK {φ : Formula} {fc : FrameClass}
    {b : Branch} {ord : TimeOrdering} (h : gatesOK φ fc b ord = true) :
    ¬ GenericConsequenceIn FrameClass.Base ([] : List Formula) φ := by
  unfold gatesOK at h
  simp only [Bool.and_eq_true, Option.isNone_iff_eq_none] at h
  obtain ⟨⟨⟨⟨⟨⟨⟨⟨hTot, hBA⟩, hCheck⟩, hTW⟩, hV⟩, hSat⟩, hOpen⟩, hroot⟩, hwc⟩ := h
  have hw₀ : Label.initial.world ∈ b.knownWorlds := List.contains_iff_mem.mp hwc
  intro hc
  exact not_valid_of_hasOpen_int hV fc hSat hOpen hTot hBA hCheck hTW
    hw₀ ((hasNegAt_iff_mem b φ Label.initial).mp hroot)
    ((genericConsequenceIn_nil (L := Formula) _ _).mp hc)

end BimodalLib
