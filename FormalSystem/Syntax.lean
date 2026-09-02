/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import FormalSystem.Syntax.Context
import FormalSystem.Syntax.Subformulas
import FormalSystem.Syntax.SubformulaClosure.Closure
import FormalSystem.Syntax.SubformulaClosure.NestingDepth
import FormalSystem.Syntax.SubformulaClosure.TemporalFormulas
import FormalSystem.Syntax.SubformulaClosure.IteratedTemporal

/-!
# FormalSystem.Syntax - Formula Syntax

Aggregates all syntax components for bimodal logic TM (Tense and Modality). Provides
the inductive formula type with 6 primitive constructors and derived operators,
plus context types for proof assumptions.

## Submodules

- `Formula`: Inductive formula type with 6 primitives (atom, bot, imp, box, allPast, allFuture)
  plus derived operators (neg, and, or, diamond, always, sometimes) and decidable equality
- `Context`: Type alias `List Formula` for proof assumptions with map, membership, and subset
operations

## Primitive Operators

| Symbol | Name | Description |
|--------|------|-------------|
| `p` | atom | Propositional variable |
| `⊥` | bot | Falsum (bottom) |
| `→` | imp | Material implication |
| `□` | box | Metaphysical necessity |
| `H` | allPast | Universal past ("for all past times") |
| `G` | allFuture | Universal future ("for all future times") |

## Derived Operators

| Symbol | Name | Definition |
|--------|------|------------|
| `¬` | neg | `φ.imp bot` |
| `∧` | and | `¬(φ → ¬ψ)` |
| `∨` | or | `¬φ → ψ` |
| `◇` | diamond | `¬□¬φ` |
| `P` | somePast | `¬H¬φ` |
| `F` | someFuture | `¬G¬φ` |
| `△` | always | `Hφ ∧ Gφ` |
| `▽` | sometimes | `Pφ ∨ Fφ` |

## Usage

```lean
import FormalSystem.Syntax

open FormalSystem.Syntax

-- Build formulas using constructors
def necessity_p : Formula := Formula.box (Formula.atomS "p")
def future_q : Formula := Formula.allFuture (Formula.atomS "q")

-- Use method syntax for derived operators
def possibly_p : Formula := (Formula.atomS "p").diamond
def always_p : Formula := (Formula.atomS "p").always

-- Contexts for derivations
def assumptions : Context := [Formula.atomS "p", Formula.atomS "q"]
```

## References

* [Formula.lean](Syntax/Formula.lean) - Formula type and operators
* [Context.lean](Syntax/Context.lean) - Context type for proof assumptions
-/
