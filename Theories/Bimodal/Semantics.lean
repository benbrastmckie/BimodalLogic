import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.WorldHistory
import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.Truth
import Bimodal.Semantics.Validity

/-!
# Bimodal.Semantics - Task Frame Semantics

Aggregates all Semantics components for the Core TM logic layer.

## Submodules

- `TaskFrame`: Task frame structure with world states and times
- `WorldHistory`: World history definition (functions from time to state)
- `TaskModel`: Model with valuation function
- `Truth`: Truth evaluation at model-history-time triples
- `Validity`: Validity and semantic consequence

## Usage

```lean
import Bimodal.Semantics

open Bimodal.Semantics

example (M : TaskModel) (τ : WorldHistory) (t : Time) :
    truth_at M τ t ht (Formula.atom p) = M.val p t := rfl
```
-/
