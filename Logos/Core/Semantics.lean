import Logos.Core.Semantics.TaskFrame
import Logos.Core.Semantics.WorldHistory
import Logos.Core.Semantics.TaskModel
import Logos.Core.Semantics.Truth
import Logos.Core.Semantics.Validity

/-!
# Logos.Core.Semantics - Task Frame Semantics

Aggregates all Semantics components for the Core TM logic layer.

## Submodules

- `TaskFrame`: Task frame structure with world states and times
- `WorldHistory`: World history definition (functions from time to state)
- `TaskModel`: Model with valuation function
- `Truth`: Truth evaluation at model-history-time triples
- `Validity`: Validity and semantic consequence

## Usage

```lean
import Logos.Core.Semantics

open Logos.Core.Semantics

example (M : TaskModel) (τ : WorldHistory) (t : Time) :
    truth_at M τ t ht (Formula.atom p) = M.val p t := rfl
```
-/
