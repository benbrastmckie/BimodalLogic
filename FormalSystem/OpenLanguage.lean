/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.OpenClasses

/-!
# `FormalSystem.OpenLanguage` — the language L^▷: L⁺ plus the open-future and open-past modals

This component formalizes the two restricted modals that the manuscript's subsection *Restricted
Modalities* (`sub:RestrictedModalities`) introduces beside the stability modal `⊡`:

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ⊡φ | ▷φ | ◁φ
```

`▷` (`ofut`) is the manuscript's *open future* operator, quantifying over `|τ⟩_x`, the possible
worlds that agree with the world of evaluation at every time up to and including the time of
evaluation; `◁` (`opast`) is the *open past* operator over `⟨τ|_x`, the worlds that agree from
the time of evaluation onward. `⊡` quantifies over `⟨τ⟩_x`, the worlds through the present world
**state**.

**Why the component exists.** Branching-time (Ockhamist) historical necessity quantifies over the
histories that share the *past* of the moment of evaluation. On a tree, "same moment" and "same
past" coincide. On a task frame they do not: the present world state fixes the alternatives of
`⊡`, and two possible worlds through one state need share neither past nor future. So the
operator of this semantics that corresponds to historical necessity is `▷`, **not** `⊡`, and proof
steps that rely on shared pasts do not transfer to `⊡`. The component states that distinction as
library theorems rather than leaving it to be rediscovered.

## Modules

- `OpenLanguage.OpenClasses` — the three history classes `⟨τ⟩_x`, `|τ⟩_x`, `⟨τ|_x`, each the
  equivalence class of an explicit relation, with the manuscript's inclusions, intersection and
  monotonicity

## Design decisions

**An extension language, not semantic operators.** L^▷ is a separate inductive with a
constructor-to-constructor embedding of L⁺, following `FormalSystem/StarLanguage/`. Operators on
truth sets with no syntax would be shorter, but under them the Ockhamist principle and its
stability transposition are schemata over a model and a truth set, not a validity of a formula and
a refutation of one; the tense clauses of the consequent would have to be rebuilt as set
operators; and the time-reversal mirror would still need a transport induction. No constructor is
added to `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`.

**A root-level component.** Every object language of this library is a self-contained directory
at the library root under a flat namespace, and L^▷ follows them. Its dependencies are
language-to-language (`PlusLanguage.PlusPasting`, `PlusLanguage.PlusNonValidities`), the same
shape as `StarLanguage → PlusLanguage`. It sits strictly downstream of `Semantics/Truth.lean`, so
the `assert_not_exists` guards there are untouched. L^▷ is **semantic only**: it has no proof
system.

**The frame reversal lives here.** The converse frame of `lem:time-reflection` is
language-independent, but it is built inside this component, which is its only consumer; the
frame-level half may be promoted to `Semantics/` later.

## Manuscript operators without a formalization

- **Any axiomatization, soundness or completeness claim for `▷` and `◁`.** The manuscript gives
  none: "I will omit further consideration of the restricted modals".
- **The nomic operator**, over a four-place task relation `⇒ʷ` indexed by world states.
- **The world registers** `↑_M`, `↓_M` of `sub:Extension`.

## Module Invariant

**Syntax before semantics within this directory**, exactly as in the sibling language
components: a syntax file imports nothing from `FormalSystem/Semantics/` and no semantic module of
any language. `scripts/check-metalogic-cycles.sh` enforces it, reading each file's layer from the
per-file table in `scripts/measure-refactor-partitions.py`; a new file in this directory needs a
row there.

## References

* JPL paper `sub:RestrictedModalities` — the stability clause, the items *Open Futures* and *Open
  Pasts*, and the clauses for the open-future and open-past operators
* JPL paper `def:BLstar-semantics` — `⟨τ⟩_x` and the `⊡` clause
* JPL paper `lem:time-reflection` — the converse frame
* `FormalSystem/PlusLanguage.lean` — L⁺, the language this one extends
* `FormalSystem/OpenLanguage/README.md` — the paper-label correspondence table

## Tags

open-language · open-future · open-past · historical-necessity
-/
