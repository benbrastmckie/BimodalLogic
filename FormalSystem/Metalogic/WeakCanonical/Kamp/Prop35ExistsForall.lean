/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.ExistsForallFormula
import FormalSystem.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# Proposition 3.5 foundation: rendering unary types (per-formula-finite layer)

Rabinovich's Proposition 3.5 (*A Proof of Kamp's Theorem*, 2014, PDF p.5) states that every
∃∀-formula with **one free variable** is equivalent to a `TL(Until, Since)` formula, via the
`A_k ∧ (B_{k+1} Until …)` future chain and its `Since` past mirror. The atomic building block on
which that chain rests is the rendering of a single **unary type** — the quantifier-free unary
`αⱼ`/`βⱼ` of the Def 3.1 object — as a temporal-logic `Formula` that reads back exactly as the
type's realization predicate.

## Where the rendering now lives

Under the infinite E[Σ] alphabet of Def 4.1 (p.5), the total-alphabet rendering that this module
formerly carried (`unaryToFormula` / `unaryToFormula_correct`, folding the depth-0 characteristic
formula over `Fintype.elems` of the whole expanded signature) is not constructible: `Formula` is
infinite, so `(sigE sig F).preds` carries no `Fintype`. The production rendering is the
per-formula-finite `unaryToFormulaFin` / `unaryToFormulaFin_correct` (`PerFormulaRender.lean`),
which folds over the finite mentioned-atom set `M` only — the faithful Prop 3.5 content ("the
type is a finite disjunction of the mentioned atoms"). The total-alphabet twins were retired with
the rest of the total-type layer at the Fin switchover.

This module is retained as the documented Prop 3.5 anchor point of the chain (`Prop35Chain.lean`
imports it); it re-exports nothing.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 3.5 (p.5), Definition 4.1 (p.5).
  Cited by PDF page; the companion markdown transcription is corrupt.
- `PerFormulaRender.lean`: `unaryToFormulaFin`, `unaryToFormulaFin_correct` (the production
  rendering).
- `ExistsForallFormula.lean`: the Def 3.1 object.
-/

namespace Bimodal.Metalogic.WeakCanonical

end Bimodal.Metalogic.WeakCanonical
