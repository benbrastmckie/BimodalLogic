import Bimodal.Syntax.Formula
import Bimodal.Syntax.Context

/-!
# Bimodal.Syntax - Formula Syntax

Aggregates all Syntax components for the Core TM logic layer.

## Submodules

- `Formula`: Inductive formula type with modal and temporal operators
- `Context`: Proof context (list of formulas)

## Usage

```lean
import Bimodal.Syntax

open Bimodal.Syntax

def example_formula : Formula := Formula.box (Formula.atom "p")
```
-/
