/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.ConvexConsequence

/-!
# Axiom-profile evidence for the convex-index consequence relations C3 and C4

`#guard_msgs`-gated `#print axioms` blocks for the headline theorems of
`FormalSystem/Semantics/ConvexTruth.lean` and `FormalSystem/Metalogic/ConvexConsequence/`. They
are **build-breaking**: if a profile moves, this module stops compiling. Every expected string
was measured from this toolchain, never guessed.

Three things are recorded.

1. **The gap closures are sorry-free and use the three standard axioms only.** These are the
   five verdicts an earlier survey of the axiom-survival table left conditional, unresolved or
   unchecked: `c3_discrete_propagate_bwd`, `c3_z1`, `c3_prior_U_gap`, `c3_sep`, and the mirror
   `c3_prior_S_gap`. A `sorryAx` appearing in any of them means a verdict has silently reopened.
2. **Shift invariance and the germ theorem.** `truthC3_timeShift` is what makes C3 time-uniform;
   `c3_box_untl_unsat` is what the primary box range costs. The latter does not use
   `Quot.sound`.
3. **A refutation, and both halves of the table.** `refute_C3_discrete_box_necessity` is the germ
   theorem cashed out on a named axiom; `c3_survival_table` and `c3_failure_table` cover all 29
   constructors of `Axiom`.

## When one of these guards fires

The expected block is updated in the same commit as the change that moved the profile, with the
move justified there — never re-baselined on its own to turn a red build green.

## References

* `FormalSystem/Semantics/ConvexTruth.lean` — `TruthAtConvex`, `truthC3_timeShift`, the germ
  theorems
* `FormalSystem/Metalogic/ConvexConsequence/FrameClassSurvival.lean` — three of the gap closures
* `FormalSystem/Metalogic/ConvexConsequence/Mirrors.lean` — `c3_prior_S_gap`
* `FormalSystem/Metalogic/ConvexConsequence/SurvivalTable.lean` — the two table theorems
-/

namespace BimodalTest.Semantics.ConvexTruthTest

/-! ## The gap closures -/

/--
info: 'FormalSystem.Metalogic.ConvexConsequence.c3_discrete_propagate_bwd' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.ConvexConsequence.c3_discrete_propagate_bwd

/--
info: 'FormalSystem.Metalogic.ConvexConsequence.c3_z1' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.ConvexConsequence.c3_z1

/--
info: 'FormalSystem.Metalogic.ConvexConsequence.c3_prior_U_gap' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.ConvexConsequence.c3_prior_U_gap

/--
info: 'FormalSystem.Metalogic.ConvexConsequence.c3_sep' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.ConvexConsequence.c3_sep

/--
info: 'FormalSystem.Metalogic.ConvexConsequence.c3_prior_S_gap' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.ConvexConsequence.c3_prior_S_gap

/-! ## Shift invariance and the germ theorem -/

/--
info: 'FormalSystem.Semantics.truthC3_timeShift' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.truthC3_timeShift

/--
info: 'FormalSystem.Semantics.c3_box_untl_unsat' depends on axioms: [propext, Classical.choice]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.c3_box_untl_unsat

/-! ## A refutation, and the table -/

/--
info: 'FormalSystem.Metalogic.ConvexConsequence.refute_C3_discrete_box_necessity' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.ConvexConsequence.refute_C3_discrete_box_necessity

/--
info: 'FormalSystem.Metalogic.ConvexConsequence.c3_survival_table' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.ConvexConsequence.c3_survival_table

/--
info: 'FormalSystem.Metalogic.ConvexConsequence.c3_failure_table' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.ConvexConsequence.c3_failure_table

end BimodalTest.Semantics.ConvexTruthTest
