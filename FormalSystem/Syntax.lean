/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import FormalSystem.Syntax.Context
import FormalSystem.Syntax.Subformulas
import FormalSystem.Syntax.SubformulaClosure

/-!
# FormalSystem.Syntax - Formula Syntax

Aggregates all syntax components for bimodal logic TM (Tense and Modality). Provides
the inductive formula type with 6 primitive constructors and derived operators,
plus context types for proof assumptions.

## Submodules

- `Formula`: Inductive formula type with 6 primitives (atom, bot, imp, box, untl, snce)
  plus derived operators (neg, and, or, diamond, somePast, someFuture, allPast, allFuture,
  always, sometimes) and decidable equality
- `Context`: Type alias `List Formula` for proof assumptions with map, membership, and subset
operations
- `SubformulaClosure`: the subformula closure as a `Finset`, with nesting-depth measures,
  temporal classification and the iterated temporal operators
- The L⁻ / L⁺ / L⋆ language family lives in the `MinusLanguage/`, `PlusLanguage/` and
  `StarLanguage/` subdirectories; see `Syntax/README.md`'s `Language family` section. Those
  aggregators are deliberately NOT imported here, so a bare `import FormalSystem.Syntax` does
  not drag in their downstream dependencies.

## Primitive Operators

The six constructors of `Formula`. `untl`/`snce` are **guard-first** — `untl guard event` — so
`untl` is Until and `snce` is Since.

| Symbol | Name | Description |
|--------|------|-------------|
| `p` | atom | Propositional variable |
| `⊥` | bot | Falsum (bottom) |
| `→` | imp | Material implication |
| `□` | box | Metaphysical necessity |
| `U` | untl | Until, `untl guard event` |
| `S` | snce | Since, `snce guard event` |

`H`/`G`/`P`/`F` are **derived**, not primitive — a point worth stating explicitly, because
`MinusLanguage/` (the language L⁻) takes `allPast`/`allFuture` as constructors *instead of*
`untl`/`snce`, and the two must not be conflated.

## Derived Operators

| Symbol | Name | Definition |
|--------|------|------------|
| `¬` | neg | `φ.imp bot` |
| `∧` | and | `¬(φ → ¬ψ)` |
| `∨` | or | `¬φ → ψ` |
| `◇` | diamond | `¬□¬φ` |
| `F` | someFuture | `untl ⊤ φ` |
| `P` | somePast | `snce ⊤ φ` |
| `G` | allFuture | `¬F¬φ` |
| `H` | allPast | `¬P¬φ` |
| `△` | always | `Hφ ∧ (φ ∧ Gφ)` |
| `▽` | sometimes | `¬△¬φ` |

## Usage

```lean
import FormalSystem.Syntax

open FormalSystem.Syntax

-- Build formulas using constructors
def necessityP : Formula := Formula.box (Formula.atomS "p")
def futureQ : Formula := Formula.allFuture (Formula.atomS "q")

-- Use method syntax for derived operators
def possiblyP : Formula := (Formula.atomS "p").diamond
def alwaysP : Formula := (Formula.atomS "p").always

-- Contexts for derivations
def assumptions : Context := [Formula.atomS "p", Formula.atomS "q"]
```

## References

* [Formula.lean](Syntax/Formula.lean) - Formula type and operators
* [Context.lean](Syntax/Context.lean) - Context type for proof assumptions
* [README.md](Syntax/README.md) - the `Language family` section, mapping each operator delta
  (including the stability modal `⊡`/`stab`, "boxdot") to its directory
-/
