import Logos.Core.Syntax.Formula
import Logos.Core.Syntax.Context

/-!
# Logos.Core.Syntax - Formula Syntax

Aggregates all Syntax components for the Core TM logic layer.

## Submodules

- `Formula`: Inductive formula type with modal and temporal operators
- `Context`: Proof context (list of formulas)

## Usage

```lean
import Logos.Core.Syntax

open Logos.Core.Syntax

def example_formula : Formula := Formula.box (Formula.atom "p")
```
-/
