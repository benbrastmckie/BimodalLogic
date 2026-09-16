/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Plus.Atomization
import FormalSystem.Metalogic.Conservativity.Plus.AxiomValidity
import FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness
import FormalSystem.Metalogic.Conservativity.Plus.Forward
import FormalSystem.Metalogic.Conservativity.Plus.Corollaries

/-!
# The stability extension L⁺ / TM⁺ — soundness and conservativity over TM

**TM⁺** is the logic of the language L⁺ = L + `⊡` (`FormalSystem/PlusLanguage/`): the 45 TM
schemata re-declared over `PlusFormula`, the S5 schemata for `⊡`, the bridges `□φ → ⊡φ` and
`p → ⊡p` (atoms), and the two pasting schemata PS/US with pure-future/pure-past side conditions,
under the seven rules of TM. Its semantics is the paper's `($\Stability$)` clause
(`def:BLstar-semantics`) over the task-frame semantics of L
(`FormalSystem/Semantics/PlusLanguage/PlusTruth.lean`).

**This file is the aggregator, and it holds no declarations.** It re-exports the four modules of
the L⁺ metatheory:

| Module | Contents |
|--------|----------|
| `Conservativity/Plus/Atomization.lean` | `Encoding`, `atomize`, `TaskModel.atomModel`, the transfer lemma `plusTruthAt_iff_atomize`, and `plusValidIn_of_tm` / `plusValidIn_swap_of_tm` — TM schema soundness over L⁺ in one lemma |
| `Conservativity/Plus/AxiomValidity.lean` | `plusAxiom_validIn_min`, `plusAxiom_swap_validIn_min` — validity and swap-validity of every `PlusAxiom` constructor, one arm each |
| `Conservativity/Plus/PlusSoundness.lean` | `plus_derivable_valid_and_swap_validIn`, `plus_soundness_validIn`, `plus_soundness_in`, the four rows — soundness of TM⁺ at every class, TD discharged semantically |
| `Conservativity/Plus/Forward.lean` | `forward_plus`, `plusDerivable_ofFormula_iff`, `plus_of_tmMinus`, `tmFrag_iff_plus` — conservativity over TM in both directions |

## The result, stated precisely

**`Forward⁺` (TM⁺ over TM) holds at all four classes, unlike `Forward` (TM over TM⁻).** For
every L formula `φ` and every `fc ∈ {Base, Dense, Discrete, Dedekind}`:

```
TM⁺ ⊢[fc] ofFormula φ   ↔   TM ⊢[fc] φ          (plusDerivable_ofFormula_iff)
```

Backward is the embedding of derivations (`PlusLanguage/Derivation.lean`); forward is TM⁺
soundness composed with the truth-transfer bridge `plusValidIn_ofFormula_iff` and the TM
completeness engine at `fc`. No TM⁺ completeness is used. Semantic conservativity,
`PlusValidIn fc (ofFormula φ) ↔ ValidIn fc φ`, is `Semantics/PlusLanguage/PlusValidity.lean`'s
`plusValidIn_ofFormula_iff`. The composed pair L⁻ ⊂ L⁺ inherits the L⁻ ⊂ L status exactly:
backward at every class (`plus_of_tmMinus`), forward not asserted (refuted at `.Base` and `.ZTime`,
open at `.Dense` and `.RTime` — `Metalogic/Conservativity.lean`).

## What is open, and is not promised here

- **Completeness of TM⁺** over the all-histories semantics, at any class. The four TM
  completeness engines build deterministic countermodels, on which `⊡` is the identity, so none
  of them can refute a `¬⊡`-formula and none transfers; a canonical model on `⊡`-classes of
  maximal consistent sets faces a lifting obstruction the pasting schemata do not resolve for
  mixed past/future demands. Nothing in this tree asserts or approaches TM⁺ completeness.
- **Decidability of TM⁺.** By the conservativity above, a decision procedure for TM⁺ would
  decide TM, whose decidability is itself open at every class; no result in either direction is
  claimed.

## Import discipline

The four children import each other in the chain
`Atomization ← AxiomValidity ← PlusSoundness ← Forward`; none imports this aggregator, and the
aggregator is imported by `Metalogic/Conservativity.lean`.
-/
