import Bimodal.Syntax.Formula
import Bimodal.Syntax.Context
import Bimodal.Syntax.Subformulas
import Bimodal.Syntax.SubformulaClosure

/-!
# Bimodal.Syntax - Formula Syntax

Aggregates all syntax components for bimodal logic TM (Tense and Modality). Provides
the inductive formula type with 6 primitive constructors and derived operators,
plus context types for proof assumptions.

## Submodules

- `Formula`: Inductive formula type with 6 primitives (atom, bot, imp, box, all_past, all_future)
  plus derived operators (neg, and, or, diamond, always, sometimes) and decidable equality
- `Context`: Type alias `List Formula` for proof assumptions with map, membership, and subset operations

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
import Bimodal.Syntax

open Bimodal.Syntax

-- Build formulas using constructors
def necessity_p : Formula := Formula.box (Formula.atom "p")
def future_q : Formula := Formula.all_future (Formula.atom "q")

-- Use method syntax for derived operators
def possibly_p : Formula := (Formula.atom "p").diamond
def always_p : Formula := (Formula.atom "p").always

-- Contexts for derivations
def assumptions : Context := [Formula.atom "p", Formula.atom "q"]
```

## References

* [Formula.lean](Syntax/Formula.lean) - Formula type and operators
* [Context.lean](Syntax/Context.lean) - Context type for proof assumptions
-/
