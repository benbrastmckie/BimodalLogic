/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusLanguage.PlusTruth
import FormalSystem.Semantics.PlusLanguage.PlusValidity
import FormalSystem.Semantics.PlusLanguage.PlusPasting
import FormalSystem.Semantics.PlusLanguage.PlusNonValidities
import FormalSystem.Semantics.PlusLanguage.PlusDeterminism
import FormalSystem.Semantics.PlusLanguage.PlusStateLocal

/-!
# `FormalSystem.Semantics.PlusLanguage` — the semantics of L⁺

Aggregator for the semantic modules of the language L⁺ (L plus the stability modal `⊡`), whose
syntax and proof system live at `FormalSystem/Syntax/PlusLanguage/`. The declarations stay in the
`FormalSystem.Semantics` namespace; only the module paths are grouped here.

## Modules

- `PlusLanguage.PlusTruth` — `SameStateAt` and `PlusTruthAt`, the truth recursion whose seventh
  clause is the stability clause of `def:BLstar-semantics`
- `PlusLanguage.PlusValidity` — `PlusValidOnFrames`, `PlusValidIn`, `PlusValid`, and the
  semantic conservativity of L⁺ over L
- `PlusLanguage.PlusPasting` — the history-pasting lemma and the pasting validities
- `PlusLanguage.PlusNonValidities` — the refutations on `natFrame` over `ℤ` that bound the
  axiom set from above
- `PlusLanguage.PlusDeterminism` — `app:deterministic`'s positive half: the deterministic
  collapse `⊡φ ↔ φ`
- `PlusLanguage.PlusStateLocal` — the state-locality fragment of L⁺ and its headline `φ ↔ ⊡φ`

The cross-language bridges `Semantics/DeterministicBridge.lean` and
`Semantics/StateLocalTransfer.lean` stay at the `Semantics/` root. This aggregator is imported by
the root aggregator `FormalSystem/FormalSystem.lean`, mirroring
`FormalSystem/Syntax/PlusLanguage.lean`.
-/
