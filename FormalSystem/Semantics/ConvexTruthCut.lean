/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.ConvexTruth

/-!
# ConvexTruthCut - The Cut-Back Box Range, as a Named Alternative

`TruthAtConvex` reads the paper's alternative-semantics footnote literally: `□` ranges over
*every* convex history through the evaluation time, one-point histories included. Those germs
make every boxed `U`/`S`-formula unsatisfiable (`c3_box_untl_unsat`, `c3_box_snce_unsat`). This
module records the variant that avoids that, as a definition with a name, so that the choice
between the two is made on the record rather than by accident.

`TruthAtConvexCut` is identical to `TruthAtConvex` except in the box clause, which ranges over
the convex histories whose domain **contains the index's domain**. A germ is then in the box's
range only at a germ index, and a box evaluated at a total index ranges over total histories
only.

## What changes, and what does not carry over

- **The box becomes index-dependent.** Its range is read off `dom τ`, not off the evaluation
  time alone, so the analogue of `truthC3_box_indep` **fails** for this variant. With it goes the
  one-line argument for the S5 rows: `□φ → □□φ`, for instance, now compares a range determined by
  `dom τ` with ranges determined by each larger `dom σ`.
- **The survival table is not inherited.** The verdicts proved for `TruthAtConvex` in
  `Metalogic/ConvexConsequence/` are verdicts about the primary box range. No second table is
  given for this variant; only the definition and one contrast theorem
  (`truthCut_box_someFuture_top` in `Metalogic/ConvexConsequence/CutContrast.lean`) are.

## The working default

The footnote's own reading stays the **primary** C3, because the footnote is the definition of
record and the germ result is more interesting stated than avoided. That default is revisable by
the author. Overriding it — promoting this variant to primary — changes which formulas are
C3-valid, and therefore changes what a completeness theorem for C3 would be about; it should be
decided before such a theorem is attempted, not after.

A third candidate, a box over interval sections of some minimum length, is not defined: it needs
a length parameter that is natural only over the integers or the reals.

## Main Definitions

- `TruthAtConvexCut`: the C3 truth recursion with the cut-back box range

## References

* `FormalSystem/Semantics/ConvexTruth.lean` — the primary recursion `TruthAtConvex`

## Tags

convex-history · consequence-relation · box-range · design-alternative
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

variable {F : TaskFrame}

/--
**C3 truth with the cut-back box range.** Every clause is `TruthAtConvex`'s except `box`, which
quantifies over the convex partial histories `σ` whose domain contains the domain of the index
`τ`, rather than over every convex history through the evaluation time.

When the evaluation time lies in `dom τ` — the side condition every C3 validity notion imposes —
each such `σ` has the evaluation time in its domain too, so this box range is a subset of the
primary one.
-/
def TruthAtConvexCut (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) : Formula → Prop
  | .atom p => ∃ ht : τ.domain t, M.valuation (τ.states t ht) p
  | .bot => False
  | .imp φ ψ => TruthAtConvexCut M τ t φ → TruthAtConvexCut M τ t ψ
  | .box φ => ∀ σ : PartialHistory F, σ.IsConvex → (∀ s : F.Duration, τ.domain s → σ.domain s) →
      TruthAtConvexCut M σ t φ
  | .untl ψ φ => ∃ s : F.Duration, τ.domain s ∧ t < s ∧ TruthAtConvexCut M τ s φ ∧
      ∀ r : F.Duration, τ.domain r → t < r → r < s → TruthAtConvexCut M τ r ψ
  | .snce ψ φ => ∃ s : F.Duration, τ.domain s ∧ s < t ∧ TruthAtConvexCut M τ s φ ∧
      ∀ r : F.Duration, τ.domain r → s < r → r < t → TruthAtConvexCut M τ r ψ

end FormalSystem.Semantics
