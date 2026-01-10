import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.WorldHistory
import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.Truth
import Bimodal.Semantics.Validity

/-!
# Semantics - Task Frame Semantics for Bimodal Logic TM

This module provides the task-based possible world semantics for the bimodal logic TM.

## Main Modules

- `TaskFrame`: Task frame structure with world states, times, and task relation
- `WorldHistory`: World histories over convex time domains
- `TaskModel`: Task models with valuation functions
- `Truth`: Truth evaluation at model-history-time triples
- `Validity`: Validity and semantic consequence

## Semantic Framework

The task semantics interprets formulas in models where:
- Possible worlds are functions from times to world states (world histories)
- World histories must satisfy task relation constraints (compositionality, nullity)
- Modal operators quantify over all world histories
- Temporal operators quantify over times in the history's domain

## Implementation Notes

- Task frames use integers for time for MVP simplicity
- World histories have convex time domains (simplified for MVP)
- Truth evaluation is defined recursively on formula structure
- Validity is truth in all models

## References

* [ARCHITECTURE.md](../../docs/ARCHITECTURE.md) - Task semantics specification
* [Formula.lean](Syntax/Formula.lean) - Formula syntax
-/
