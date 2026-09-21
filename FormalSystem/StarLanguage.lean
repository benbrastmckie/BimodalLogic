/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.StarLanguage.Formula
import FormalSystem.StarLanguage.Axioms
import FormalSystem.StarLanguage.Derivation
import FormalSystem.StarLanguage.Embedding
import FormalSystem.StarLanguage.StarTruth
import FormalSystem.StarLanguage.StarValidity
import FormalSystem.StarLanguage.StarDeterminism
import FormalSystem.StarLanguage.StarNonValidities
import FormalSystem.StarLanguage.StarStateLocal

/-!
# `FormalSystem.StarLanguage` — the language L⋆ = L⁺ + time store/recall

This component carries the manuscript's `\BL^\star` in the presentation
`def:BLstar-semantics` gives it: L⁺ (`FormalSystem.PlusLanguage`) extended by the two hybrid
time registers `↑ⁱ` (store) and `↓ⁱ` (recall), with the world registers `↑_M`/`↓_M` suppressed.
It follows the pattern of `FormalSystem.MinusLanguage` and `FormalSystem.PlusLanguage`: a
separate inductive with a constructor-to-constructor embedding.

## Modules

- `StarLanguage.Formula` — `StarFormula`, the derived operators (with `PlusFormula`'s right-hand
  sides), `reflectTime`, and the embedding `ofPlus`
- `StarLanguage.Axioms` — `StarAxiom`, the axiom schemata of TM⋆: 53 mirror constructors carrying
  every TM⁺ schema at its `ofPlus` instances, plus the sixteen register schemata, with
  `StarAxiom.minFrameClass`
- `StarLanguage.Derivation` — `StarDerivationTree`, the notation `⊢⋆[fc]`, `StarDerivable`, and
  the structural apparatus (`lift`, `height`, `ofWeakeningNil`) the soundness recursion consumes
- `StarLanguage.Embedding` — `StarDerivationTree.ofPlusTree` and `starDerivable_of_plusDerivable`:
  every TM⁺ theorem is a TM⋆ theorem at its embedded formula

## Semantic modules

- `StarLanguage.StarTruth` — `StarTruthAt` over the manuscript's points `(τ, x, v⃗)`, the
  transport layer, and the truth transfer `starTruthAt_ofPlus`
- `StarLanguage.StarValidity` — `TaskFrame.StarValidOn`, `StarValidOnFrames`, `StarValidIn`,
  `StarValid`; `sentDet` (`sent:det`) and the `(∗)` unfolding chain
- `StarLanguage.StarDeterminism` — `app:deterministic-future`'s positive half, `detPM`, and
  Theorem C's `Det-pm` half
- `StarLanguage.StarNonValidities` — `app:deterministic-future`'s negative half: `sent:det`
  refuted over a non-deterministic frame
- `StarLanguage.StarStateLocal` — the state-locality fragment of L⋆ and its headline `φ ↔ ⊡φ`

`FormalSystem/Metalogic/Independence/StarDiscrimination.lean` carries the discrimination
footnote, and stays under `Metalogic/`.

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

**Syntax before semantics within this directory.** `Formula.lean`, `Axioms.lean`,
`Derivation.lean` and `Embedding.lean` import nothing from `FormalSystem/Semantics/`; the
semantic modules beside them do, and that edge is what gives L⋆ its meaning. Checkable by
`grep -rln 'import FormalSystem.Semantics' FormalSystem/StarLanguage/`, whose matches must all
be semantic modules.

This replaces the pre-merge invariant *"nothing under `FormalSystem/Syntax/StarLanguage/`
imports anything from `FormalSystem/Semantics/`"*, which the directory merge falsifies by
construction: the two halves now share one directory. The directional content survives — the
syntax half is still a leaf with respect to `Semantics/` — but it is now a file-level property,
not a directory-level one. `scripts/check-metalogic-cycles.sh` enforces it, reading each file's
layer from the per-file table in `scripts/measure-refactor-partitions.py`; a new file in this
directory needs a row there.
-/
