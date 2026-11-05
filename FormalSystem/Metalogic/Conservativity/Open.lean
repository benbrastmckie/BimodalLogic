/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Open.OpenAxiomValidity
import FormalSystem.Metalogic.Conservativity.Open.OpenSoundness

/-!
# The restricted-modal extension L^▷ — soundness and conservativity over TM⁺

**The L^▷ proof system** is the logic of the language L^▷ = L⁺ + `▷` + `◁`
(`FormalSystem/OpenLanguage/`): the 53 TM⁺ schemata re-declared over `OpenFormula` (so `□▷p → □G▷p`
is an MF instance), S5 for each restricted modal, the strength ordering `□ ⟹ ⊡ ⟹ ▷/◁`, the
Ockhamist principle for `▷` and its open-past mirror, two rigidity schemata with
pure-future/pure-past side conditions, and the forward half of the definability equation
`⊡φ ↔ ▷◁φ` — under the seven rules of TM⁺.

## What this component claims, and what it does not

It claims **soundness** at every frame class, **conservativity over TM⁺ in both directions** on
the image of the embedding, **conservativity over TM at all four classes**, and the **collapse
under `Determined`**. It claims **no completeness**, at any frame class, in any form. The
canonical-bundle obstruction that defeats TM⁺ completeness at the base class is untouched here:
`Metalogic/Independence/` keeps `plus_incomplete_base` exactly as proved, the limit-closure
principle stays a non-theorem, and an LC_n-style schema is still required in L^▷ exactly as it is
in L⁺.

## The class split

The open-future modal is **L⁺-definable over integer and real time** and **not definable** over
the base and dense classes (`Metalogic/Expressiveness/`). `OpenValid` quantifies over the base
class, so this system is a genuine extension of TM⁺ where it is stated, and a notational variant
of it over integer and real time.

## Modules

- `Conservativity.Open.OpenAxiomValidity` — the per-block validity and reflection-validity helper
  theorems, and the two wildcard-free dispatch lemmas assembled from them
- `Conservativity.Open.OpenSoundness` — the companion recursion over `OpenDerivationTree`,
  `open_soundness_validIn`, the context form, the four class rows and the consistency row

## References

* `FormalSystem/Metalogic/Conservativity/Plus.lean` — the TM⁺ counterpart, one language down
* `FormalSystem/OpenLanguage.lean` — the language and its semantics
* `FormalSystem/Metalogic/Conservativity/Open/README.md` — the module table and the atomization
  obstruction

## Tags

open-language · soundness · conservativity
-/
