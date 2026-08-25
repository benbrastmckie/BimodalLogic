/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.BaseLanguage.Formula
import FormalSystem.BaseLanguage.Axioms
import FormalSystem.BaseLanguage.Derivation
import FormalSystem.BaseLanguage.Translation
-- import FormalSystem.BaseLanguage.AxiomDischarge

/-!
# `FormalSystem.BaseLanguage` — the tense-primitive base language BL and its logic TM

This component is a self-contained mirror of `Syntax` + `ProofSystem` for the paper's *base
language* BL (`def:BL-language`), in which `H` and `G` are primitive rather than derived from
`until`/`since`. It exists to support the **backward** conservativity bridge
`TM ⊢ φ ⟹ TM⁺ ⊢ tr φ`, proved in `FormalSystem/Metalogic/Conservativity.lean`.

## Modules

- `BaseLanguage.Formula` — `BLFormula`, derived operators, `swapBL`
- `BaseLanguage.Axioms` — `BaseLanguage.Axiom` (TM's schemata plus DF/DN/CO) and its
  `minFrameClass`, routed through the *existing* `ProofSystem.FrameClass`
- `BaseLanguage.Derivation` — `BaseLanguage.DerivationTree`, `Derivable`, `⊢ᴮᴸ[fc]` notation
- `BaseLanguage.Translation` — `tr : BLFormula → Formula` and its commutation lemmas
- `BaseLanguage.AxiomDischarge` — a BL⁺ derivation of `tr` of every BL axiom

## Module Invariant

**Nothing under `FormalSystem/BaseLanguage/` imports anything from `FormalSystem/Semantics/`.**
Checkable by `grep -rn 'FormalSystem.Semantics' FormalSystem/BaseLanguage/`.
-/
