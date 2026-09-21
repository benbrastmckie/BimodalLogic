/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.ConvexTruthCut
import FormalSystem.Metalogic.ConvexConsequence.Separations

/-!
# CutContrast - The Two Box Ranges Disagree on `□F⊤`

One theorem, contrasting the primary C3 box range with the named alternative
`TruthAtConvexCut` of `Semantics/ConvexTruthCut.lean`.

Under the primary reading `□F⊤` is unsatisfiable, at every model, index and time
(`c3_box_untl_unsat`): the germ at the evaluation time is always in the box's range, and `F⊤` is
false at a germ. Under the cut-back reading the same formula is **true** at a total index of the
integer-time frame (`truthCut_box_someFuture_top`): the box there ranges only over histories
whose domain contains the whole of `ℤ`, and each of those has a later time.

This is the whole of what is proved about the cut-back variant. It lives here rather than beside
the definition because it needs the integer-time fixtures.

## Tags

convex-history · consequence-relation · box-range · design-alternative
-/

namespace FormalSystem.Metalogic.ConvexConsequence

open FormalSystem.Syntax FormalSystem.Semantics

/-- **`□F⊤` is satisfiable under the cut-back box range**, at the total index `totalNF`: every
convex history whose domain contains all of `ℤ` has the time `1` after `0`. Contrast
`c3_box_untl_unsat`, which makes the same formula unsatisfiable under the primary range. -/
theorem truthCut_box_someFuture_top :
    TruthAtConvexCut TaskModel.allTrue totalNF 0
      (Formula.box (Formula.someFuture Formula.top)) :=
  fun _σ _hσc hsub => ⟨1, hsub 1 (totalNF_mem 1), by decide, fun h => h, fun _ _ _ _ h => h⟩

/-- The primary range's verdict on the same formula at the same index, for direct comparison
with `truthCut_box_someFuture_top`: an instance of `c3_box_untl_unsat`. -/
theorem not_truthC3_box_someFuture_top :
    ¬ TruthAtConvex TaskModel.allTrue totalNF 0
      (Formula.box (Formula.someFuture Formula.top)) :=
  c3_box_untl_unsat TaskModel.allTrue totalNF 0 Formula.top Formula.top

end FormalSystem.Metalogic.ConvexConsequence
