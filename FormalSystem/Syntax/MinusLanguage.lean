/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.MinusLanguage.Formula
import FormalSystem.Syntax.MinusLanguage.Axioms
import FormalSystem.Syntax.MinusLanguage.Derivation
import FormalSystem.Syntax.MinusLanguage.Translation
import FormalSystem.Syntax.MinusLanguage.AxiomDischarge

/-!
# `FormalSystem.MinusLanguage` — the tense-primitive base language L⁻ and its logic TM⁻

This component is a self-contained mirror of `Syntax` + `ProofSystem` for the **tense-primitive
language L⁻**, in which `H` and `G` are primitive rather than derived from `until`/`since`. The
manuscript's `def:BL-language` is the nearest thing it has to a counterpart, but the manuscript
withdrew its H/G fragment, so L⁻ and TM⁻ answer to no paper system. It exists to support the **backward** conservativity bridge
`TM⁻ ⊢ φ ⟹ TM ⊢ tr φ`, proved in `FormalSystem/Metalogic/Conservativity/Backward.lean`.

## Modules

- `MinusLanguage.Formula` — `MinusFormula`, derived operators, `swapMinus`
- `MinusLanguage.Axioms` — `MinusLanguage.Axiom` (TM⁻'s schemata plus DF/DN/CO) and its
  `minFrameClass`, routed through the *existing* `ProofSystem.FrameClass`
- `MinusLanguage.Derivation` — `MinusLanguage.DerivationTree`, `Derivable`, `⊢⁻[fc]` notation
- `MinusLanguage.Translation` — `tr : MinusFormula → Formula` and its commutation lemmas
- `MinusLanguage.AxiomDischarge` — an L derivation of `tr` of every L⁻ axiom

## Module Invariant

**Nothing under `FormalSystem/MinusLanguage/` imports anything from `FormalSystem/Semantics/`.**
Checkable by `grep -rn 'FormalSystem.Semantics' FormalSystem/MinusLanguage/`, whose only matches
are prose mentions in docstrings such as this one — no `import` line matches.

The invariant is **directional**, and reading it as a blanket separation of the two directories
is a mistake. It forbids the edge `MinusLanguage/ → Semantics/`. It says nothing about the
converse edge, which is permitted and is exactly how the base language's semantics is sited:
`FormalSystem/Semantics/MinusLanguage/MinusTruth.lean` imports `FormalSystem.MinusLanguage.Formula` in order to
define `MinusTruthAt` natively on `MinusFormula`, `FormalSystem/Semantics/MinusLanguage/MinusValidity.lean` builds the
L⁻ validity predicates on top of it, and `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean`
composes those with `Metalogic/Conservativity/Backward.lean`'s `translate` to give L⁻ soundness. Meeting
those modules is not evidence that this invariant has been violated.
-/
