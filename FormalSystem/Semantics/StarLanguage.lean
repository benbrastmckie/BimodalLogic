/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.StarLanguage.StarTruth
import FormalSystem.Semantics.StarLanguage.StarValidity
import FormalSystem.Semantics.StarLanguage.StarDeterminism
import FormalSystem.Semantics.StarLanguage.StarNonValidities
import FormalSystem.Semantics.StarLanguage.StarStateLocal

/-!
# `FormalSystem.Semantics.StarLanguage` — the semantics of L⋆

Aggregator for the semantic modules of the language L⋆ (L⁺ plus the time registers `↑ⁱ`/`↓ⁱ`),
whose syntax lives at `FormalSystem/Syntax/StarLanguage/`. The declarations stay in the
`FormalSystem.Semantics` namespace; only the module paths are grouped here.

## Modules

- `StarLanguage.StarTruth` — `StarTruthAt`, truth over the manuscript's points `(τ, x, v⃗)`
- `StarLanguage.StarValidity` — L⋆ validity, `sent:det`, and the `(∗)` unfolding chain
- `StarLanguage.StarDeterminism` — `app:deterministic-future`'s positive half, `Det-pm`, and
  the definability theorem
- `StarLanguage.StarNonValidities` — `app:deterministic-future`'s negative half: `sent:det`
  refuted over a non-deterministic frame
- `StarLanguage.StarStateLocal` — the state-locality fragment of L⋆ and its headline `φ ↔ ⊡φ`

This aggregator is imported by the root aggregator `FormalSystem/FormalSystem.lean`, mirroring
`FormalSystem/Syntax/StarLanguage.lean`.
-/
