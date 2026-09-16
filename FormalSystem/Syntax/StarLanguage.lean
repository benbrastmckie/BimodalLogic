/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.StarLanguage.Formula
import FormalSystem.Syntax.StarLanguage.Axioms
import FormalSystem.Syntax.StarLanguage.Derivation
import FormalSystem.Syntax.StarLanguage.Embedding

/-!
# `FormalSystem.StarLanguage` — the language L⋆ = L⁺ + time store/recall

This component is the **syntactic** half of the manuscript's `\BL^\star` in the presentation
`def:BLstar-semantics` gives it: L⁺ (`FormalSystem.PlusLanguage`) extended by the two hybrid
time registers `↑ⁱ` (store) and `↓ⁱ` (recall), with the world registers `↑_M`/`↓_M` suppressed.
It follows the pattern of `FormalSystem.MinusLanguage` and `FormalSystem.PlusLanguage`: a
separate inductive with a constructor-to-constructor embedding.

## Modules

- `StarLanguage.Formula` — `StarFormula`, the derived operators (with `PlusFormula`'s right-hand
  sides), `swapTemporal`, and the embedding `ofPlus`
- `StarLanguage.Axioms` — `StarAxiom`, the axiom schemata of TM⋆: 53 mirror constructors carrying
  every TM⁺ schema at its `ofPlus` instances, plus the sixteen register schemata, with
  `StarAxiom.minFrameClass`
- `StarLanguage.Derivation` — `StarDerivationTree`, the notation `⊢⋆[fc]`, `StarDerivable`, and
  the structural apparatus (`lift`, `height`, `ofWeakeningNil`) the soundness recursion consumes
- `StarLanguage.Embedding` — `StarDerivationTree.ofPlusTree` and `starDerivable_of_plusDerivable`:
  every TM⁺ theorem is a TM⋆ theorem at its embedded formula

## Where the L⋆ semantics lives

- `FormalSystem/Semantics/StarLanguage/StarTruth.lean` — `StarTruthAt` over points `(τ, x, v⃗)`, the transport
  layer, and the truth transfer `starTruthAt_ofPlus`
- `FormalSystem/Semantics/StarLanguage/StarValidity.lean` — `TaskFrame.StarValidOn`, `sentDet`
- `FormalSystem/Semantics/StarLanguage/StarDeterminism.lean` — `app:deterministic-future`'s positive half,
  `detPM`, and Theorem C's `Det-pm` half
- `FormalSystem/Semantics/StarLanguage/StarNonValidities.lean` — `app:deterministic-future`'s negative half
- `FormalSystem/Metalogic/Independence/StarDiscrimination.lean` — the discrimination footnote

## The proof system TM⋆

All four names are now **declared**: `StarAxiom` (`StarLanguage/Axioms.lean`),
`StarDerivationTree` and the notation `⊢⋆[fc]` (`StarLanguage/Derivation.lean`), and **TM⋆** as
the name of the system the two present. TM⋆ is formalization-native — the manuscript supplies no
proof system for `\BL^\star` — and is built to the shape of `PlusAxiom`/`PlusDerivationTree` so
that the two systems are structurally comparable and the L⁺ ⊂ L⋆ questions can be stated.

Its metatheory (soundness, the embedding of TM⁺ derivations, and the conservativity verdict)
lives under `FormalSystem/Metalogic/Conservativity/Star/`. See
`FormalSystem/StarLanguage/README.md` for the paper-label correspondence table and for what is
proved, what is conditional, and what is open.

## Module Invariant

**Nothing under `FormalSystem/StarLanguage/` imports anything from `FormalSystem/Semantics/`.**
Checkable by `grep -rn 'import FormalSystem.Semantics' FormalSystem/StarLanguage/`.
-/
