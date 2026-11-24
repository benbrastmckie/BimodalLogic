/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Countermodels.Boolean.GatedTableau

/-!
# Fixture: one countermodel row whose near miss does not resolve

The near-miss invariant is aimed at this module by `BimodalLibTest.CountermodelTest`, which
expects it to fail and to name both the row and the missing target. The row below is a landed
row with its `nearMiss` field replaced by a name that is deliberately not in the environment, so
the refutation is still the kernel-checked one and the only thing wrong with the row is the
field under test.

The name is written with a single backtick, not two: the double-backtick form resolves the name
at elaboration time and would refuse to compile here, which is exactly the protection the
invariant exists to extend from elaboration to the whole set of rows.
-/

namespace BimodalLibTest.Fixtures

open BimodalLib

/-- A landed row with an unresolvable near miss. Every other field is the landed row's. -/
def badNearMiss : CountermodelEntry FormalSystem.Syntax.Formula :=
  { BimodalLib.Countermodels.Boolean.GatedTableau.cmGatedImpBot with
    nearMiss := some `BimodalLibTest.Fixtures.noSuchDeclaration
    note := "Fixture: the near-miss target is deliberately absent from the environment." }

end BimodalLibTest.Fixtures
