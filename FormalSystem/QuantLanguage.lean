/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.QuantLanguage.Formula
import FormalSystem.QuantLanguage.QuantInvariance
import FormalSystem.QuantLanguage.QuantRecurrence
import FormalSystem.QuantLanguage.QuantTruth

/-!
# `FormalSystem.QuantLanguage` — the base language plus propositional quantifiers

This component formalizes the **propositional-quantifier language**: the base language L extended
by a binder over sentence letters, evaluated relative to a family of admissible propositions.

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ∀p φ
```

`∀p φ` (`all p φ`) holds at `(M, τ, x)` iff `φ` holds at `(M[p ↦ S], τ, x)` for every admissible
set `S` of world states, where `M[p ↦ S]` re-interprets the letter `p` by `S`.

**Why the component exists.** A task frame may let a world history revisit a world state
(*recurrence*). The base language cannot tell a frame with recurrence from one without: its
clauses are preserved by a history-lifting morphism
(`FormalSystem/Semantics/HistoryMorphism.lean`). Propositional quantifiers change that or leave it
alone depending on what they range over, and this component states both halves about one truth
relation.

## Modules

- `QuantLanguage.Formula` — `QuantFormula`, the derived operators (with `Formula`'s right-hand
  sides), the universal modality `univ` and its dual `exist`, the atom formula `isAtom`, the
  quantified recurrence sentence `qRec`, and the embedding `ofFormula`

## Semantic modules

- `QuantLanguage.QuantTruth` — `TaskModel.updateAtom`; `QuantTruthAt`, the truth recursion
  relative to an admissible family; the clause lemmas, among them `all_iff` and `univ_iff`;
  truth-level conservativity over L (`quantTruthAt_ofFormula`)
- `QuantLanguage.QuantInvariance` — `pulledBack`, the lifted propositions along a history-lifting
  map; `lifted_invariance`: when the quantifier ranges over the lifted propositions only, truth is
  invariant along any history-lifting morphism, so such quantifiers see no recurrence
- `QuantLanguage.QuantRecurrence` — under the standard semantics the atom formula names a world
  state (`isAtom_iff`), the quantified recurrence sentence defines recurrence-freeness
  (`qRec_defines`), and quantifier truth is not invariant along a history-lifting morphism from a
  recurrence-free frame onto a frame with recurrence (`standard_not_invariant`)

## Design decisions

**The admissible family is the design.** Truth takes a family `Adm` of sets of world states, and
the quantifier ranges over `Adm`. `Set.univ` is the **standard** semantics. The preimage family
along a history-lifting map is the **clock-independent** one: the propositions that cannot tell
two preimages of one state apart. Both are one recursion at two arguments, which is what lets the
contrast between them be a pair of theorems about a single relation.

**Letters denote sets of world states.** A sentence letter is interpreted by a set of world
states (`def:BL-semantics`: `τ(x) ∈ |p|`), so a proposition in the range of the quantifier is one
too. The quantifier binds an `Atom`, the library's type of sentence letters, and re-interprets it
through `TaskModel.updateAtom`; the truth relation takes a `TaskModel`, as every truth relation of
the library does, which is what makes conservativity over L statable.

**An extension language, a root-level component, semantic only.** The language is a separate
inductive with a constructor-to-constructor embedding of L; it sits at the library root under a
flat namespace, as every object language of this library does; and it has no proof system.

**No validity layer.** The results of the component are frame-level: they quantify over the
models, histories and times of one frame, or compare two frames along a morphism. None quantifies
over a frame class of quantifier models, and the standard and clock-independent semantics would
need two validity notions; so the component does not instantiate
`Semantics/ValidityLayer.lean`.

## Not formalized

- **Any proof system, soundness or completeness result**, and any claim about the axiomatizability
  or decidability of the language under either semantics.
- **A validity layer**, for the reason given above.
- **Definability of the same-state modality and the state binder** of
  `FormalSystem/HybridLanguage/` from propositional quantifiers under the standard semantics.
- **The transposition sentence** with two quantified state names.

## Module Invariant

**Syntax before semantics within this directory**, exactly as in the sibling language
components: a syntax file imports nothing from `FormalSystem/Semantics/` and no semantic module of
any language. `scripts/check-metalogic-cycles.sh` enforces it, reading each file's layer from the
per-file table in `scripts/measure-refactor-partitions.py`; a new file in this directory needs a
row there.

## References

* JPL paper `def:BL-semantics` — the base clauses; a sentence letter denotes a set of world states
* JPL paper `cor:occurrence` — every world state occurs in some possible world, consumed by
  `isAtom_iff`
* `FormalSystem/Semantics/HistoryMorphism.lean` — history-lifting morphisms and
  recurrence-freeness
* `FormalSystem/HybridLanguage.lean` — the sibling component, which names world states by
  registers rather than by quantified propositions
* `FormalSystem/QuantLanguage/README.md` — the paper-label correspondence table

## Tags

quant-language · propositional-quantifier · admissible-family · recurrence
-/
