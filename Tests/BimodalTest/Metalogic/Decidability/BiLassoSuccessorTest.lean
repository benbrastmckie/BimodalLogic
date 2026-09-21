/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Successor

/-!
# Bi-Lasso Successor Tests

`succOf` and `predOf` in `FormalSystem/Metalogic/Decidability/BiLasso/Successor.lean` are not
merely choice-free as proofs; they run. `Tests/BimodalTest.lean` imports this module, so
`lake test` runs the rows below. `Successor` belongs to the effective-periodic-extension cluster,
which no aggregator carries; the generated library root `FormalSystem.lean` imports it directly.
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
