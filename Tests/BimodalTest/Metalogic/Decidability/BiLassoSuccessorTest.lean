/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Successor

/-!
# Bi-Lasso Successor Tests

`succOf` and `predOf` in `FormalSystem/Metalogic/Decidability/BiLasso/Successor.lean` are not
merely choice-free as proofs; they run. This module is not imported by `Tests/BimodalTest.lean`:
`Successor` belongs to the effective-periodic-extension cluster that is outside the Lake build
graph, so importing it here would pull that cluster in. It is listed in
`scripts/module-invariants-manifest.txt` instead, so C6 compile-checks it in isolation.
-/

namespace BimodalTest.Metalogic.Decidability.BiLassoSuccessorTest

open FormalSystem.Metalogic.Decidability

/-!
## Computability, exhibited

`succOf` and `predOf` are not merely choice-free as proofs; they run. The two-state cycle
`flipPresentation` (`Decidability/IntPresentation.lean`) steps `0 ⇄ 1`, so the first match in
`List.finRange 2` from state `0` is state `1`, and conversely.
-/

section Computation

/-- info: 1 -/
#guard_msgs in
#eval flipPresentation.succOf 0

/-- info: 0 -/
#guard_msgs in
#eval flipPresentation.succOf 1

/-- info: 1 -/
#guard_msgs in
#eval flipPresentation.predOf 0

/-- info: 0 -/
#guard_msgs in
#eval flipPresentation.iterSucc 0 2

end Computation

end BimodalTest.Metalogic.Decidability.BiLassoSuccessorTest
