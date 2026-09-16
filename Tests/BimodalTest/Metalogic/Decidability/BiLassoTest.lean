/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Examples

/-!
# Bi-Lasso Tests

Executable checks for `FormalSystem/Metalogic/Decidability/BiLasso/`: the bounded enumerations
return their hand-checkable counts. The successor/predecessor rows for `BiLasso/Successor.lean`
live in `BiLassoSuccessorTest.lean`, which stays outside the aggregator because `Successor` is
outside the build graph.
-/

namespace BimodalTest.Metalogic.Decidability.BiLassoTest

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.BiLassoExamples

/-! ## Bounded enumeration counts (`Examples.lean`)

`boundedBiLassos flipPresentation 2` is 6 by hand: over the two-state flip presentation every step
alternates, so a path is fixed by its origin value (2 choices) and its window length
`|mid| ∈ {0, 1, 2}` (3 choices). The `n = 2` annotated count takes on the order of ten seconds.
-/

section EnumerationCounts

#guard (boundedBiLassos flipPresentation 2).length == 6
#guard (boundedBiLassos loopPresentation 1).length == 2
#guard (boundedAnnots loopPresentation φPos (fun _ => false) 1).length == 36
#guard (boundedAnnots loopPresentation φPos (fun _ => false) 2).length == 1872

end EnumerationCounts

end BimodalTest.Metalogic.Decidability.BiLassoTest
