/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.ConeUnravelling

/-!
# Evidence for the forward-cone unravelling

This module is **permanent evidence**, not a conventional test. It pins the axiom profiles of the
forward-cone unravelling's five headline declarations as `#guard_msgs`-gated `#print axioms`
blocks. These are build-breaking: if a profile moves, this module stops compiling. Every profile
recorded below was *measured* in the same dispatch that landed the frame assembly, never typed
from memory or carried over from `OrientedForestSaturationTest.lean`.

## When one of these guards fires

A red build here means an axiom profile moved. The expected block is updated **in the same commit
as the change that moved it**, with the move justified in that commit — never updated on its own
to turn a red build green. A guard silently re-baselined to match whatever the tree now does
records nothing and protects nothing.

Two of the five are worth reading before re-baselining anything:

* `coneF_surjective` is **axiom-free**, and that is a fact about the construction rather than an
  accident of the proof: `coneF` is the sum eliminator, the witness is `fun w => ⟨.inl w, rfl⟩`,
  and the `inl` layer being a verbatim copy of the base is exactly what makes it one line. A
  profile appearing here would mean the projection or the carrier changed shape, not that a proof
  got sloppier.
* `exists_coneUnravelling` is the headline, and its ceiling is
  `[propext, Classical.choice, Quot.sound]` — the same ceiling as
  `saturation_of_orientedForest` and as `TaskFrame.saturation_of_finite`. So the cone route adds
  no new axiom cost over either of the other two *Saturation* discharges in this tree.

## What this module does not pin

It does **not** pin that `exists_coneUnravelling` is proved of the cone rather than delegated to
`UniversalCover.exists_orientedForest_cover`. No axiom, `sorry` or name-existence check can see
that difference — both have satisfying witnesses of the same type — which is why the prohibition
lives in `exists_coneUnravelling`'s own doc comment, as prose a reader must honour, and is
recorded in this task's plan under `## Decisions`. A guard cannot substitute for it.
-/

namespace BimodalTest.Semantics

/-! ## Axiom profiles

Every block below is build-breaking: `#guard_msgs` compares the `#print axioms` info message
against the expected text and fails the build on any difference.
-/

/-! ### The oriented-forest obligation on the `inr` layer

The `inr` layer is the only layer that is a forest; the `inl` layer is a verbatim copy of the base
and inherits its loops and opposite edges. This is the declaration that makes the two-layer split
necessary rather than a stylistic choice.
-/

/-- info: 'FormalSystem.Semantics.coneRin_isOrientedForest' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.coneRin_isOrientedForest

/-! ### The two-layer *Saturation* split

`saturation_coneR` takes the base's *Saturation* in `ofStepRel` form and takes no seriality
hypothesis at all.
-/

/-- info: 'FormalSystem.Semantics.saturation_coneR' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.saturation_coneR

/-! ### The projection

Surjectivity is axiom-free; two-way boundedness reads the base frame through
`FrameOver.taskRel_eq_iter` and therefore picks up the standard three.
-/

/-- info: 'FormalSystem.Semantics.coneF_surjective' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Semantics.coneF_surjective

/-- info: 'FormalSystem.Semantics.coneF_twoWayBounded' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.coneF_twoWayBounded

/-! ### The headline -/

/-- info: 'FormalSystem.Semantics.exists_coneUnravelling' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.exists_coneUnravelling

end BimodalTest.Semantics
