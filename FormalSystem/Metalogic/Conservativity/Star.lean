/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Star.StarPasting
import FormalSystem.Metalogic.Conservativity.Star.StarAxiomValidity
import FormalSystem.Metalogic.Conservativity.Star.StarSoundness
import FormalSystem.Metalogic.Conservativity.Star.Forward

/-!
# The register extension L⋆ / TM⋆ — soundness and conservativity

**TM⋆** is the logic of the language L⋆ = L⁺ + the time registers `↑ⁱ`/`↓ⁱ`
(`FormalSystem/StarLanguage/`): the 53 TM⁺ schemata re-declared directly over `StarFormula`,
plus sixteen register schemata, under the seven rules of TM⁺ and TM. Its
semantics is `def:BLstar-semantics` over points `(τ, x, v⃗)`
(`FormalSystem/Semantics/StarLanguage/StarTruth.lean`).

**This file is the aggregator, and it holds no declarations.**

| Module | Contents |
|--------|----------|
| `Conservativity/Star/StarPasting.lean` | `star_truth_congr_agreeFrom`, `star_truth_congr_agreeUpTo`, `star_paste_valid`, `star_untl_paste_valid` — the two L⋆ purity congruences and the PS / US validities the pasting schemata consume |
| `Conservativity/Star/StarAxiomValidity.lean` | `starAxiom_validIn_min`, `starAxiom_swap_validIn_min` — validity and swap-validity of every `StarAxiom` constructor, one arm each and no wildcard |
| `Conservativity/Star/StarSoundness.lean` | `star_derivable_valid_and_swap_validIn`, `star_soundness_validIn`, the four rows, `star_not_derivable_nil_bot` — soundness of TM⋆ at every class, TD discharged semantically |
| `Conservativity/Star/Forward.lean` | `forward_star`, `starDerivable_ofFormula_iff` — TM⋆ conservative over TM in both directions, unconditionally; `starConservative_of_plusComplete` and `plusIncomplete_of_starNonconservative` — the conditional pair over TM⁺ |

## The result, stated precisely

**TM⋆ over TM: unconditional, both directions, all four classes.** For every L formula `φ`,
`TM⋆ ⊢⋆[fc] ofPlus (ofFormula φ) ↔ TM ⊢[fc] φ` (`starDerivable_ofFormula_iff`). Adding the time
registers proves no new theorem of the base language.

**TM⋆ over TM⁺: a proved conditional pair, because TM⁺ completeness is open.** If TM⁺ is complete
at `fc` then TM⋆ is conservative over it (`starConservative_of_plusComplete`); and,
unconditionally, any separating witness for non-conservativity is a witness of TM⁺ incompleteness
(`plusIncomplete_of_starNonconservative`). The question is therefore *equivalent modulo TM⋆
soundness* to the tree's own recorded open problem, and no work on TM⋆ alone can decide it.

**TM⋆ completeness: OPEN, under two named obstructions.** See
`Conservativity/Star/README.md`.

## References

* `FormalSystem/Metalogic/Conservativity/Star/README.md` — the module inventory and the record of
  what is proved, what is conditional, and what is open
* `FormalSystem/Metalogic/Conservativity/Plus.lean` — the L⁺ aggregator this one is shaped after
-/
