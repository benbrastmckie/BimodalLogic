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

/-!
# FormalSystem.Syntax - Formula Syntax

Aggregates all syntax components for bimodal logic TM (Tense and Modality). Provides
the inductive formula type with 6 primitive constructors and derived operators,
plus context types for proof assumptions.

## Submodules

- `Formula`: Inductive formula type with 6 primitives (atom, bot, imp, box, all_past, all_future)
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
| `H` | all_past | Universal past ("for all past times") |
| `G` | all_future | Universal future ("for all future times") |

## Derived Operators

| Symbol | Name | Definition |
|--------|------|------------|
| `¬` | neg | `φ.imp bot` |
| `∧` | and | `¬(φ → ¬ψ)` |
| `∨` | or | `¬φ → ψ` |
| `◇` | diamond | `¬□¬φ` |
| `P` | some_past | `¬H¬φ` |
| `F` | some_future | `¬G¬φ` |
| `△` | always | `Hφ ∧ Gφ` |
| `▽` | sometimes | `Pφ ∨ Fφ` |

## Usage

```lean
import FormalSystem.Syntax

open FormalSystem.Syntax

-- Build formulas using constructors
def necessity_p : Formula := Formula.box (Formula.atom_s "p")
def future_q : Formula := Formula.all_future (Formula.atom_s "q")

-- Use method syntax for derived operators
def possibly_p : Formula := (Formula.atom_s "p").diamond
def always_p : Formula := (Formula.atom_s "p").always

-- Contexts for derivations
def assumptions : Context := [Formula.atom_s "p", Formula.atom_s "q"]
```

## References

* [Formula.lean](Syntax/Formula.lean) - Formula type and operators
* [Context.lean](Syntax/Context.lean) - Context type for proof assumptions
-/
