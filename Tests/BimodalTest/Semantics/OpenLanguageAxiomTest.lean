/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage

/-!
# Axiom-profile evidence for the open-future and open-past language

`#guard_msgs`-gated `#print axioms` blocks for the headline theorems of
`FormalSystem/OpenLanguage/`. They are **build-breaking**: if a profile moves, this module stops
compiling. Every expected string was measured from this toolchain.

Two things are recorded.

1. **The separating pair and its mirror use the three standard axioms and nothing else.** The
   validity `hnOpen_openValid` is classical only through `OpenTruth.dofut_iff`, whose `¬∀¬ ↔ ∃`
   step is the same `by_contra` the inherited `dstab_iff` uses; the refutation
   `hnStab_refuted_sinkFrame` inherits `Classical.choice` from the finite-carrier *Saturation*
   discharge behind `FrameOver.ofStep`, which cannot be made choice-free (see
   `SaturationFiniteAxiomTest.lean`).
2. **Conservativity over L⁺ is `propext` only.** `openValid_ofPlus_iff` is a congruence induction;
   a `Classical.choice` appearing there means the truth-transfer bridge has stopped being one.

## When one of these guards fires

The expected block is updated in the same commit as the change that moved the profile, with the
move justified there — never re-baselined on its own to turn a red build green. The same four
headline profiles are pinned a second time by check C14 of `scripts/check-module-invariants.sh`.

## References

* `FormalSystem/OpenLanguage/OpenOckhamist.lean` — the separating pair and its mirror
* `FormalSystem/OpenLanguage/OpenReversal.lean` — `openValid_reflectTime`
* `Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean` — why the finite-carrier
  *Saturation* discharge is classical
-/

namespace BimodalTest.Semantics.OpenLanguageAxiomTest

/-! ## The separating pair -/

/--
info: 'FormalSystem.OpenLanguage.hnOpen_openValid' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.OpenLanguage.hnOpen_openValid

/--
info: 'FormalSystem.OpenLanguage.hnStab_refuted_sinkFrame' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.OpenLanguage.hnStab_refuted_sinkFrame

/-! ## The time-reversal mirror -/

/--
info: 'FormalSystem.OpenLanguage.openValid_reflectTime' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.OpenLanguage.openValid_reflectTime

/--
info: 'FormalSystem.OpenLanguage.hnOpenMirror_openValid' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.OpenLanguage.hnOpenMirror_openValid

/--
info: 'FormalSystem.OpenLanguage.not_openValid_hnStabMirror' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.OpenLanguage.not_openValid_hnStabMirror

/-! ## Conservativity over L⁺ -/

/-- info: 'FormalSystem.OpenLanguage.openValid_ofPlus_iff' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.OpenLanguage.openValid_ofPlus_iff

end BimodalTest.Semantics.OpenLanguageAxiomTest
