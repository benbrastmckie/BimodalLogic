/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.QuantLanguage

/-!
# Axiom-profile evidence for the propositional-quantifier language

`#guard_msgs`-gated `#print axioms` blocks for the headline theorems of
`FormalSystem/QuantLanguage/`. They are **build-breaking**: if a profile moves, this module stops
compiling. Every expected string was measured from this toolchain.

Three things are recorded.

1. **The lifted invariance is choice-free.** `lifted_invariance` is a congruence induction whose
   `box` and `all` cases destructure existentials; it uses `propext` and `Quot.sound` and no
   `Classical.choice`.
2. **The standard-semantics results use the three standard axioms and nothing else.**
   `qRec_defines` and `standard_not_invariant` are classical through `isAtom_iff`, which decides
   membership of the named state in an arbitrary set and consumes `cor:occurrence`, itself a
   Zorn argument.
3. **Conservativity over L is `propext` only.** `quantTruthAt_ofFormula` is a congruence
   induction.

## When one of these guards fires

The expected block is updated in the same commit as the change that moved the profile, with the
move justified there — never re-baselined on its own to turn a red build green. The first three
profiles are pinned a second time by check C14 of `scripts/check-module-invariants.sh`.

## References

* `FormalSystem/QuantLanguage/QuantInvariance.lean` — `lifted_invariance`
* `FormalSystem/QuantLanguage/QuantRecurrence.lean` — `qRec_defines`, `standard_not_invariant`
* `FormalSystem/QuantLanguage/QuantTruth.lean` — `quantTruthAt_ofFormula`
-/

namespace BimodalTest.Semantics.QuantLanguageAxiomTest

/-! ## Invariance under the lifted family -/

/--
info: 'FormalSystem.QuantLanguage.lifted_invariance' depends on axioms: [propext, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.QuantLanguage.lifted_invariance

/-! ## The standard semantics sees recurrence -/

/--
info: 'FormalSystem.QuantLanguage.qRec_defines' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.QuantLanguage.qRec_defines

/--
info: 'FormalSystem.QuantLanguage.standard_not_invariant' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.QuantLanguage.standard_not_invariant

/-! ## Conservativity over L -/

/--
info: 'FormalSystem.QuantLanguage.quantTruthAt_ofFormula' depends on axioms: [propext]
-/
#guard_msgs in
#print axioms FormalSystem.QuantLanguage.quantTruthAt_ofFormula

end BimodalTest.Semantics.QuantLanguageAxiomTest
