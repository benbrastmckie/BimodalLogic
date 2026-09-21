/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.HybridLanguage.Formula
import FormalSystem.HybridLanguage.HybridTruth
import FormalSystem.HybridLanguage.HybridValidity

/-!
# `FormalSystem.HybridLanguage` — L⁺ plus the same-state modality, state registers and the binder

This component formalizes the **hybrid state language**: L⁺ extended by a modality that frees the
stability modal `⊡` from the present time, by registers that store world states, and by a binder
that stores the present one.

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ⊡φ | [≡]φ | i | ↓ᵢ φ
```

`[≡]φ` (`same`) holds at `(τ, x)` iff `φ` holds at every (history, time) pair occupying the world
state `τ(x)`, at any time. `i` (`reg i`) holds iff `τ(x)` is the `i`-th stored state. `↓ᵢ φ`
(`bind i φ`) stores `τ(x)` in register `i` and evaluates `φ`.

**Why the component exists.** A task frame may let a world history revisit a world state
(*recurrence*), and may let two histories pass through the same states in opposite orders
(*transposition*). The base language, L⁺ and L⋆ cannot tell a frame with either from one without:
their clauses consult a world state only through the valuation, the history and time structure,
and the same-state relation at the present time, and all three are preserved by a history-lifting
morphism (`FormalSystem/Semantics/HistoryMorphism.lean`). This component locates the resource that
breaks the invariance — a state-identity test across two times of one history — by exhibiting a
language one step short of it and a language that has it.

## Modules

- `HybridLanguage.Formula` — `HybridFormula`, the derived operators (with `PlusFormula`'s
  right-hand sides), the universal modality `univ` and its dual `exist`, the recurrence formula
  `recF`, the transposition formula `transF`, the register-free fragment `RegFree`, and the
  embedding `ofPlus`

## Semantic modules

- `HybridLanguage.HybridTruth` — `HybridTruthAt`, the truth recursion relative to a register
  vector, whose last three clauses are those of `[≡]`, the registers and the binder; the clause
  lemmas, among them `univ_iff` (`A φ` holds iff `φ` holds at every history and time);
  truth-level conservativity over L⁺ (`hybridTruthAt_ofPlus`)
- `HybridLanguage.HybridValidity` — `TaskFrame.HybridValidOn`, `HybridValidOnFrames`,
  `HybridValidIn`, `HybridValid`, each quantifying over every register vector; semantic
  conservativity over L⁺ at every frame class (`hybridValidIn_ofPlus_iff`)

## Design decisions

**A nominal is a free register.** Truth is relative to a register vector `ℕ → WorldState` and
validity quantifies over all of them, so a register no binder captures is a state nominal under an
arbitrary assignment. Nominals and registers are one language, not two.

**An extension language, not semantic operators.** The hybrid state language is a separate
inductive with a constructor-to-constructor embedding of L⁺, following
`FormalSystem/OpenLanguage/`. The definability results are validities of a formula on a frame,
which only a syntax can state. No constructor is added to `PlusFormula`, `PlusAxiom` or
`PlusDerivationTree`.

**A root-level component.** Every object language of this library is a self-contained directory
at the library root under a flat namespace, and this one follows them. Its dependencies are
language-to-language (`PlusLanguage`), the same shape as `OpenLanguage → PlusLanguage`.

**Semantic only.** The component has no proof system, and no axiomatization, soundness or
completeness claim is made for any of its operators. In particular no naming rule is stated.

## A state nominal names a point of a quotient

A register names a world state, and many (history, time) pairs occupy one world state. A state
nominal therefore names a point of the quotient of the (history, time) pairs by the same-state
relation, not a point of evaluation. `A(i → φ)` and `E(i ∧ φ)` are consequently **not** dual, and
results of hybrid logic that depend on a nominal being true at exactly one point do not transfer
to state nominals.

## Not formalized

- **Any proof system, soundness or completeness result** for the language, and any naming or
  pasting rule.
- **The class-level form of the invariance**: that class validity of a register-free formula
  equals validity over the recurrence-free members of the class. It needs the translation product
  of a frame, which is not part of this component.
- **World registers.** The manuscript's registers of `sub:Extension` store times and worlds;
  `FormalSystem/StarLanguage/` formalizes the time registers, and the world registers have no
  formalization in this tree. The registers here store world states, which the manuscript does not
  have.
- **The strong-transposition formula**, which would require the two histories to agree outside an
  interval.

## Module Invariant

**Syntax before semantics within this directory**, exactly as in the sibling language
components: a syntax file imports nothing from `FormalSystem/Semantics/` and no semantic module of
any language. `scripts/check-metalogic-cycles.sh` enforces it, reading each file's layer from the
per-file table in `scripts/measure-refactor-partitions.py`; a new file in this directory needs a
row there.

## References

* JPL paper `def:BLstar-semantics` — `⟨τ⟩_x` and the `⊡` clause
* JPL paper `sub:Extension` — the manuscript's registers
* [P. Blackburn, M. de Rijke, Y. Venema, *Modal Logic*][blackburn2002], §7.3 — point nominals and
  the satisfaction operator
* `FormalSystem/Semantics/HistoryMorphism.lean` — history-lifting morphisms and
  recurrence-freeness
* `FormalSystem/PlusLanguage.lean` — L⁺, the language this one extends
* `FormalSystem/HybridLanguage/README.md` — the paper-label correspondence table

## Tags

hybrid-language · state-nominal · state-register · recurrence · transposition
-/
