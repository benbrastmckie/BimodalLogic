/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.Formula
import FormalSystem.PlusLanguage.Subformulas
import FormalSystem.PlusLanguage.Axioms
import FormalSystem.PlusLanguage.Derivation
import FormalSystem.PlusLanguage.Substitution
import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.PlusLanguage.PlusValidity
import FormalSystem.PlusLanguage.PlusPasting
import FormalSystem.PlusLanguage.PlusNonValidities
import FormalSystem.PlusLanguage.PlusDeterminism
import FormalSystem.PlusLanguage.PlusStateLocal
import FormalSystem.PlusLanguage.PlusLimitClosure
import FormalSystem.PlusLanguage.PlusIntTransfer
import FormalSystem.PlusLanguage.PlusRayFibre

/-!
# `FormalSystem.PlusLanguage` — the language L⁺, its logic TM⁺, and its semantics

This component is a self-contained mirror of `Syntax` + `ProofSystem` + `Semantics` for the
language **L⁺**:
L (`FormalSystem.Syntax.Formula`) extended by the paper's **stability modal** `⊡`
(`def:BLstar-semantics`), read "settled at the present world state". It follows the
pattern of `FormalSystem.MinusLanguage`: a separate inductive with an embedding, and a
proof system mirroring `ProofSystem.DerivationTree` constructor for constructor.

## Modules

- `PlusLanguage.Formula` — `PlusFormula`, the derived operators (with `Formula`'s right-hand
  sides), `reflectTime`, the purity predicates `IsPureFuture`/`IsPurePast`, and the embedding
  `ofFormula`
- `PlusLanguage.Subformulas` — `PlusFormula.subformulas`, the seven-constructor subformula
  list and its membership lemmas, which the L⁺ certificate's closure is built from
- `PlusLanguage.Axioms` — `PlusAxiom`, the closed inductive of TM⁺ schemata: the 45 TM-shaped
  schemata re-declared over `PlusFormula`, plus the eight `⊡` schemata (S5 for `⊡`, `□φ → ⊡φ`,
  `p → ⊡p` for atoms, and the two pasting schemata with purity side conditions); `minFrameClass`
- `PlusLanguage.Derivation` — `PlusDerivationTree`, `PlusDerivable`, `⊢⁺[fc]` notation, the
  derived `⊡`-necessitation rule, and the **backward conservativity** bridge
  `PlusDerivationTree.ofTM` / `plusDerivable_of_derivable`:
  `TM ⊢[fc] φ ⟹ TM⁺ ⊢[fc] ofFormula φ` at every frame class
- `PlusLanguage.Substitution` — `substPlus`, the interpretation of L in L⁺ at an arbitrary
  atom assignment, and the **substitution transfer** `plusDerivable_substPlus`:
  `TM ⊢[fc] φ ⟹ TM⁺ ⊢[fc] substPlus σ φ`, which is what makes every TM *schema* available at
  L⁺ arguments containing `⊡`

## Semantic modules

- `PlusLanguage.PlusTruth` — `PlusTruthAt`, the truth recursion whose seventh clause is the
  stability clause of `def:BLstar-semantics`; the S5 validities of `⊡`; `stab_state_only`
- `PlusLanguage.PlusValidity` — `PlusValidOnFrames`, `PlusValidIn`, `PlusValid`, and the
  semantic conservativity of L⁺ over L at every frame class
- `PlusLanguage.PlusPasting` — the history-pasting lemma and the pasting validities PS/US/FS/GS
  with their past mirrors
- `PlusLanguage.PlusNonValidities` — the five refutations on `natFrame` over `ℤ` that bound the
  `⊡` axiom set from above
- `PlusLanguage.PlusDeterminism` — `app:deterministic`'s positive half: the deterministic
  collapse `⊡φ ↔ φ`
- `PlusLanguage.PlusStateLocal` — the state-locality fragment of L⁺ and its headline `φ ↔ ⊡φ`
- `PlusLanguage.PlusLimitClosure` — the limit-closure formula `blc` and its validity at `.Base`,
  through a general Zorn-plus-extension lemma for chain-closed properties of partial histories
- `PlusLanguage.PlusIntTransfer` — **carrier normalization for L⁺**: `PlusValidZTime φ ↔
  PlusValidInt φ`, the twin of `Semantics/IntTransfer.lean`'s `validZTime_iff_validInt`, through
  the seven-case truth transport `plusTruthAt_map`
- `PlusLanguage.PlusRayFibre` — `⊡` as a **quantifier over a product of two path spaces**:
  `plusStab_iff_rays` reads the clause over ray pairs through `Presheaf.seamFibreEquiv`, and
  `seamOmegaEquiv` / `plusStab_iff_omega` read it over pairs of ω-indexed step sequences over `ℤ`

The cross-language bridges `Semantics/DeterministicBridge.lean` and
`Semantics/StateLocalTransfer.lean` stay at the `Semantics/` root, because each spans two
language families. `FormalSystem/Metalogic/Conservativity/Plus.lean` carries soundness of TM⁺ at
all four frame classes and proof-theoretic conservativity over TM in both directions.

## Module Invariant

**Syntax before semantics within this directory.** `Formula.lean`, `Axioms.lean`,
`Derivation.lean` and `Substitution.lean` import nothing from `FormalSystem/Semantics/`;
the semantic modules beside them do, and that edge is what gives L⁺ its meaning. Checkable by
`grep -rln 'import FormalSystem.Semantics' FormalSystem/PlusLanguage/`, whose matches must all
be semantic modules.

This replaces the pre-merge invariant *"nothing under `FormalSystem/Syntax/PlusLanguage/`
imports anything from `FormalSystem/Semantics/`"*, which the directory merge falsifies by
construction: the two halves now share one directory. The directional content survives — the
syntax half is still a leaf with respect to `Semantics/` — but it is now a file-level property,
not a directory-level one. `scripts/check-metalogic-cycles.sh` enforces it, reading each file's
layer from the per-file table in `scripts/measure-refactor-partitions.py`; a new file in this
directory needs a row there.
-/
