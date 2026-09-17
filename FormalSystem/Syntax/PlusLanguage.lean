/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.PlusLanguage.Formula
import FormalSystem.Syntax.PlusLanguage.Axioms
import FormalSystem.Syntax.PlusLanguage.Derivation
import FormalSystem.Syntax.PlusLanguage.Substitution

/-!
# `FormalSystem.PlusLanguage` — the language L⁺ and its logic TM⁺

This component is a self-contained mirror of `Syntax` + `ProofSystem` for the language **L⁺**:
L (`FormalSystem.Syntax.Formula`) extended by the paper's **stability modal** `⊡`
(`def:BLstar-semantics`), read "settled at the present world state". It follows the
pattern of `FormalSystem.MinusLanguage`: a separate inductive with an embedding, and a
proof system mirroring `ProofSystem.DerivationTree` constructor for constructor.

## Modules

- `PlusLanguage.Formula` — `PlusFormula`, the derived operators (with `Formula`'s right-hand
  sides), `swapTemporal`, the purity predicates `IsPureFuture`/`IsPurePast`, and the embedding
  `ofFormula`
- `PlusLanguage.Axioms` — `PlusAxiom`, the closed inductive of TM⁺ schemata: the 45 TM
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

## Where the L⁺ semantics and metatheory live

- `FormalSystem/Semantics/PlusLanguage/PlusTruth.lean` — `PlusTruthAt`
- `FormalSystem/Semantics/PlusLanguage/PlusValidity.lean` — `PlusValidIn`, semantic conservativity
- `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean`, `PlusNonValidities.lean` — the pasting validities
  and the refutations that bound the axiom set
- `FormalSystem/Metalogic/Conservativity/Plus.lean` — soundness of TM⁺ at all four frame
  classes and proof-theoretic conservativity over TM in both directions

## Module Invariant

**Nothing under `FormalSystem/PlusLanguage/` imports anything from `FormalSystem/Semantics/`.**
Checkable by `grep -rn 'FormalSystem.Semantics' FormalSystem/PlusLanguage/`, whose only matches
are prose mentions in docstrings — no `import` line matches. The invariant is directional,
exactly as for `MinusLanguage/`: the converse edge is permitted and is how L⁺ acquires its
semantics.
-/
