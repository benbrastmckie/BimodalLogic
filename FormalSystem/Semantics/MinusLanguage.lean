/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.MinusLanguage.MinusTruth
import FormalSystem.Semantics.MinusLanguage.MinusFrame
import FormalSystem.Semantics.MinusLanguage.MinusValidity
import FormalSystem.Semantics.MinusLanguage.MinusSchemaValidity

/-!
# `FormalSystem.Semantics.MinusLanguage` — the semantics of the base language L⁻

Aggregator for the semantic modules of the tense-primitive base language L⁻, whose syntax and
proof system live at `FormalSystem/Syntax/MinusLanguage/`. The declarations stay in the
`FormalSystem.Semantics` namespace; only the module paths are grouped here.

## Modules

- `MinusLanguage.MinusTruth` — `MinusTruthAt`, the native truth recursion on `MinusFormula`
  (`def:BL-semantics`), with its clause and derived-operator characterization lemmas
- `MinusLanguage.MinusFrame` — a native L⁻ frame notion not bound to `TaskFrame`
  (`MinusFrame`, `MinusFrameTruth`, `MinusFrameValid`) and the order-reversal transfer lemma
- `MinusLanguage.MinusValidity` — `MinusValid`, `MinusSemanticConsequence` and the per-class
  mirrors of `Semantics/Validity.lean`
- `MinusLanguage.MinusSchemaValidity` — the DF and DN semantic lemmas and their past-duals

This aggregator is imported by the root aggregator `FormalSystem/FormalSystem.lean`, not by
`FormalSystem/Semantics.lean`, mirroring `FormalSystem/Syntax/MinusLanguage.lean`.
-/
