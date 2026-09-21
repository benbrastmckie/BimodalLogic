/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.MinusLanguage.Formula
import FormalSystem.MinusLanguage.Axioms
import FormalSystem.MinusLanguage.Derivation
import FormalSystem.MinusLanguage.Translation
import FormalSystem.MinusLanguage.AxiomDischarge
import FormalSystem.MinusLanguage.MinusTruth
import FormalSystem.MinusLanguage.MinusFrame
import FormalSystem.MinusLanguage.MinusValidity
import FormalSystem.MinusLanguage.MinusSchemaValidity

/-!
# `FormalSystem.MinusLanguage` — the base language L⁻, its logic TM⁻, and its semantics

This component is a self-contained mirror of `Syntax` + `ProofSystem` + `Semantics` for the
**tense-primitive language L⁻**, in which `H` and `G` are primitive rather than derived from
`until`/`since`. The
manuscript's `def:BL-language` is the nearest thing it has to a counterpart, but the manuscript
withdrew its H/G fragment, so L⁻ and TM⁻ answer to no paper system. It exists to support the
**backward** conservativity bridge `TM⁻ ⊢ φ ⟹ TM ⊢ tr φ`, proved in
`FormalSystem/Metalogic/Conservativity/Backward.lean`.

## Modules

- `MinusLanguage.Formula` — `MinusFormula`, derived operators, `reflectTime`
- `MinusLanguage.Axioms` — `MinusLanguage.Axiom` (TM⁻'s schemata plus DF/DN/CO) and its
  `minFrameClass`, routed through the *existing* `ProofSystem.FrameClass`
- `MinusLanguage.Derivation` — `MinusLanguage.DerivationTree`, `Derivable`, `⊢⁻[fc]` notation
- `MinusLanguage.Translation` — `tr : MinusFormula → Formula` and its commutation lemmas
- `MinusLanguage.AxiomDischarge` — an L derivation of `tr` of every L⁻ axiom

## Semantic modules

- `MinusLanguage.MinusTruth` — `MinusTruthAt`, the native six-clause truth recursion on
  `MinusFormula` (`def:BL-semantics`), **not** `TruthAt ∘ tr`, with its clause and
  derived-operator characterization lemmas
- `MinusLanguage.MinusFrame` — a native L⁻ frame notion not bound to `TaskFrame`
  (`MinusFrame`, `MinusFrameTruth`, `MinusFrameValid`) and the order-reversal transfer lemma
- `MinusLanguage.MinusValidity` — `MinusValid`, `MinusSemanticConsequence` and the per-class
  mirrors of `Semantics/Validity.lean`
- `MinusLanguage.MinusSchemaValidity` — the DF and DN semantic lemmas and their past-duals
- `MinusLanguage.Soundness` — the truth-transfer bridge `truthAt_tr`, and L⁻ soundness at
  `FrameClass.Base` and its three extensions, by composition through
  `Metalogic/Conservativity/Backward.lean`'s `translate`

## Module Invariant

**Syntax before semantics within this directory.** `Formula.lean`, `Axioms.lean`,
`Derivation.lean`, `Translation.lean` and `AxiomDischarge.lean` import nothing from
`FormalSystem/Semantics/`; the semantic modules beside them do, and that edge is what gives L⁻
its meaning — `MinusTruth.lean` imports `MinusLanguage.Formula` to define `MinusTruthAt`
natively on `MinusFormula`, `MinusValidity.lean` builds the validity predicates on top of it,
and `Soundness.lean` composes those with `translate`. Checkable by
`grep -rln 'import FormalSystem.Semantics' FormalSystem/MinusLanguage/`, whose matches must all
be semantic modules.

This replaces the pre-merge invariant *"nothing under `FormalSystem/Syntax/MinusLanguage/`
imports anything from `FormalSystem/Semantics/`"*, which the directory merge falsifies by
construction: the two halves now share one directory. The directional content survives — the
syntax half is still a leaf with respect to `Semantics/` — but it is now a file-level property,
not a directory-level one, and no mechanical check enforces it.
-/
