import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.WorldHistory
import Bimodal.Syntax.Formula

/-!
# TaskModel - Task Models with Valuation

This module defines task models, which extend task frames with valuation functions.

## Main Definitions

- `TaskModel`: Task model structure with valuation function
- Example models for testing

## Implementation Notes

- Valuation assigns truth values to atoms at each world state
- Valuation function: `WorldState → String → Prop`
- Models provide complete semantic interpretation for TM formulas

## References

* [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) - Task model specification
* [TaskFrame.lean](TaskFrame.lean) - Task frame structure
* [Formula.lean](../Syntax/Formula.lean) - Formula syntax
-/

namespace Bimodal.Semantics

open Bimodal.Syntax

/--
Task model for bimodal logic TM.

A task model extends a task frame with a valuation function that determines
which atomic propositions are true at each world state.

This provides the complete semantic structure needed to evaluate formula truth.

**Polymorphic Temporal Type**: TaskModel inherits temporal type parameter from TaskFrame,
ensuring valuation is independent of the specific temporal order used.
-/
structure TaskModel {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) where
  /--
  Valuation function: assigns truth values to atomic propositions at world states.

  `valuation w p` is true iff atomic proposition `p` is true at world state `w`.
  -/
  valuation : F.WorldState → String → Prop

namespace TaskModel

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {F : TaskFrame D}

/--
Simple model where all atoms are false everywhere.
-/
def all_false : TaskModel F where
  valuation := fun _ _ => False

/--
Simple model where all atoms are true everywhere.
-/
def all_true : TaskModel F where
  valuation := fun _ _ => True

/--
Model where specific atoms have specific truth values.

Helper function to construct models for testing.
-/
def from_list (trueAtoms : List String) : TaskModel F where
  valuation := fun _ p => p ∈ trueAtoms

end TaskModel

end Bimodal.Semantics
