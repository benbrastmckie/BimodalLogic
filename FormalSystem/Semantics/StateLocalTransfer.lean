/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusLanguage.PlusStateLocal
import FormalSystem.Semantics.StarLanguage.StarStateLocal

/-!
# State-locality transfers along `ofPlus`

`PlusFormula.StateLocal` (`Semantics/PlusLanguage/PlusStateLocal.lean`) and `StarFormula.StateLocal`
(`Semantics/StarLanguage/StarStateLocal.lean`) are two syntactic fragments cut by structural recursion over
two different languages. `ofPlus` (`StarLanguage/Formula.lean`) embeds L⁺ into L⋆ constructor to
constructor, and this module records the one fact that makes the pair a single concept rather
than two parallel ones: the two recursions **agree along the embedding**, in both directions.

## Main Results

- `stateLocal_ofPlus_iff` — `(ofPlus φ).StateLocal ↔ φ.StateLocal`

## Why this is a separate module

The lemma cannot live in `Semantics/PlusLanguage/PlusStateLocal.lean`. That module is imported by
`Metalogic/Conservativity/Plus/AxiomValidity.lean`, which discharges the AS arm of TM⁺ soundness
from `stab_of_stateLocal`; putting an L⋆ import into it would make the whole L⁺ conservativity
route depend on the L⋆ tower, inverting the L → L⁺ → L⋆ layering the tree is built on. It cannot
live in `Semantics/StarLanguage/StarStateLocal.lean` either — that module is outside the territory of the work
that introduced the L⁺ fragment. A third module above both towers is the only placement that
proves the lemma and preserves the layering, so this is that module.

For the same reason it does **not** `open` both `FormalSystem.PlusLanguage` and
`FormalSystem.StarLanguage`: `stateLocal_atom`, `stateLocal_box`, `stateLocal_stab`,
`stateLocal_imp_iff`, `not_stateLocal_untl` and `not_stateLocal_snce` are declared in both, so
opening both would make every one of those names ambiguous. Dot notation on the formula type
resolves each side unaided.

## References

* `FormalSystem/StarLanguage/Formula.lean` — `ofPlus`
* `FormalSystem/Semantics/PlusLanguage/PlusStateLocal.lean` — `PlusFormula.StateLocal`
* `FormalSystem/Semantics/StarLanguage/StarStateLocal.lean` — `StarFormula.StateLocal`

## Tags

state-locality · fragment · plus-language · star-language · transfer
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

/--
**State-locality is preserved and reflected by `ofPlus`**, at every L⁺ formula.

Seven cases, and every one of them is definitional: `ofPlus` maps each L⁺ constructor to the
matching L⋆ constructor, and the two `StateLocal` recursions assign that constructor the same arm
(`True`/`True` for `atom`, `bot`, `box` and `stab`; `∧`/`∧` for `imp`; `False`/`False` for `untl`
and `snce`). Only `imp` needs its inductive hypotheses.

The biconditional is what makes the two fragments one concept: `ofPlus` does not merely preserve
membership, it reflects it, so the L⁺ fragment is exactly the `ofPlus`-preimage of the L⋆
fragment. The two constructors of L⋆ that have no L⁺ source — `timeStore` (admitted recursively)
and `timeRecall` (excluded) — are precisely the difference between the nine-arm and seven-arm
recursions, and neither is in the image of `ofPlus`.

Paper: — (the formalization's own: the manuscript has neither fragment)
-/
theorem stateLocal_ofPlus_iff (φ : PlusLanguage.PlusFormula) :
    (StarLanguage.ofPlus φ).StateLocal ↔ φ.StateLocal := by
  induction φ with
  | atom p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact and_congr ihφ ihψ
  | box φ _ => exact Iff.rfl
  | untl ψ φ _ _ => exact Iff.rfl
  | snce ψ φ _ _ => exact Iff.rfl
  | stab φ _ => exact Iff.rfl

end FormalSystem.Semantics
