/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.ConvexConsequence.Separations

/-!
# FormalSystem.Metalogic.ConvexConsequence - The Logic of the Convex-Index Relations

Aggregator for the metatheory of C3 and C4, the convex-index consequence relations defined in
`Semantics/ConvexTruth.lean`. It holds no declarations.

C3 is TM's S5 modal layer over a bounded-interval tense logic: every axiom of TM that fails
under it is an existence assertion about the temporal order, and a bounded domain is what
falsifies an existence assertion. This directory states that, row by row, as theorems. It makes
no claim identifying the C3 validities with a known axiomatic system; that is a completeness
question, and no completeness theorem for C3 is stated here.

## Submodules

- `Separations`: the integer-time fixtures, and the theorems separating C1 from C3 and C4
  (`F⊤`) and C3 from C4 (`lastPoint`)

## Tags

convex-history · consequence-relation · axiom-survival
-/
