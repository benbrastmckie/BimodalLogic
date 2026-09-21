/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.HybridLanguage

/-!
# Axiom-profile evidence for the hybrid state language

`#guard_msgs`-gated `#print axioms` blocks for the headline theorems of
`FormalSystem/HybridLanguage/`. They are **build-breaking**: if a profile moves, this module stops
compiling. Every expected string was measured from this toolchain.

Three things are recorded.

1. **The invariance is choice-free.** `regFree_invariance` is a congruence induction whose `box`,
   `stab` and `same` cases destructure the morphism's existentials; it uses `propext` and
   `Quot.sound` and no `Classical.choice`.
2. **The definability theorems use the three standard axioms and nothing else.** `recF_defines`
   and `transF_defines` are classical through `by_contra` and through the inherited `and_iff` and
   `or_iff` of `Semantics/TruthClauses.lean`.
3. **Conservativity over L⁺ is `propext` only.** `hybridValidIn_ofPlus_iff` is a congruence
   induction; a `Classical.choice` appearing there means the truth-transfer bridge has stopped
   being one.

## When one of these guards fires

The expected block is updated in the same commit as the change that moved the profile, with the
move justified there — never re-baselined on its own to turn a red build green. The first three
profiles are pinned a second time by check C14 of `scripts/check-module-invariants.sh`.

## References

* `FormalSystem/HybridLanguage/HybridInvariance.lean` — `regFree_invariance`
* `FormalSystem/HybridLanguage/HybridRecurrence.lean` — `recF_defines`
* `FormalSystem/HybridLanguage/HybridTransposition.lean` — `transF_defines`
* `FormalSystem/HybridLanguage/HybridValidity.lean` — `hybridValidIn_ofPlus_iff`
-/

namespace BimodalTest.Semantics.HybridLanguageAxiomTest

/-! ## Invariance of the register-free fragment -/

/--
info: 'FormalSystem.HybridLanguage.regFree_invariance' depends on axioms: [propext, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.HybridLanguage.regFree_invariance

/-! ## Definability of recurrence-freeness -/

/--
info: 'FormalSystem.HybridLanguage.recF_defines' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.HybridLanguage.recF_defines

/--
info: 'FormalSystem.HybridLanguage.transF_defines' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.HybridLanguage.transF_defines

/-! ## Conservativity over L⁺ -/

/--
info: 'FormalSystem.HybridLanguage.hybridValidIn_ofPlus_iff' depends on axioms: [propext]
-/
#guard_msgs in
#print axioms FormalSystem.HybridLanguage.hybridValidIn_ofPlus_iff

end BimodalTest.Semantics.HybridLanguageAxiomTest
