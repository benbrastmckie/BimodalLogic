import Mathlib.Algebra.Order.Group.Int
import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.WorldHistory

/-!
# Temporal Structures - Example Frame Instantiations

This module provides examples demonstrating the use of different temporal types
with ProofChecker's generalized semantics. The polymorphic `TaskFrame T` and
`WorldHistory F` structures can be instantiated with various temporal types.

## Paper Alignment

The JPL paper "The Perpetuity Calculus of Agency" (§app:TaskSemantics, def:frame, line 1835)
specifies that the temporal structure is a "totally ordered abelian group T = ⟨T, +, ≤⟩".
ProofChecker implements this via the `LinearOrderedAddCommGroup` typeclass, which
provides exactly this structure.

## Example Temporal Types

### Integer Time (`Int`)
- **Use case**: Discrete temporal logic, countable time steps
- **Instance**: `instLinearOrderedAddCommGroupInt`
- **Advantages**: Simple, decidable, standard temporal logic interpretation

### Polymorphic Examples
The examples below demonstrate how ProofChecker's polymorphic types work with
any type `T` that has a `LinearOrderedAddCommGroup` instance. This includes:
- `Int`: Discrete integer time
- `Rat`: Dense rational time (requires additional Mathlib imports)
- `Real`: Continuous real time (requires additional Mathlib imports)

## Main Definitions

- `intTimeFrame`: Example task frame using `Int` as temporal type
- `intTimeHistory`: Example world history using `Int`
- `genericTimeFrame`: Polymorphic task frame (works with any `T`)
- `genericTimeHistory`: Polymorphic world history (works with any `T`)

## Implementation Notes

- All examples use `trivial` task relations for simplicity
- Convexity proofs use the full domain (`fun _ => True`) for simplicity
- These examples are for demonstration and testing purposes

## References

* [TaskFrame.lean](../ProofChecker/Semantics/TaskFrame.lean) - TaskFrame definition
* [WorldHistory.lean](../ProofChecker/Semantics/WorldHistory.lean) - WorldHistory definition
* JPL Paper app:TaskSemantics (def:frame, line 1835) - Temporal structure specification
-/

namespace Archive

open Bimodal.Semantics

/-! ## Integer Time Examples (Standard) -/

/--
Standard integer time task frame.

This is the default temporal structure used in most temporal logic applications.
Discrete time steps with integer arithmetic.
-/
def intTimeFrame : TaskFrame Int where
  WorldState := Unit
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial

/--
Integer time task frame with natural number world states.

A slightly more complex frame with `Nat` world states.
-/
def intNatFrame : TaskFrame Int where
  WorldState := Nat
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial

/--
Integer time world history with universal domain.

All integer times are in the domain. This is the simplest possible history.
-/
def intTimeHistory : WorldHistory intTimeFrame where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun _ _ => ()
  respects_task := fun _ _ _ _ _ => trivial

/-! ## Polymorphic Examples -/

section Polymorphic

variable (T : Type*) [LinearOrderedAddCommGroup T]

/--
Generic polymorphic task frame.

Works with any temporal type `T` that has a `LinearOrderedAddCommGroup` instance.
This demonstrates ProofChecker's polymorphic design.
-/
def genericTimeFrame : TaskFrame T where
  WorldState := Unit
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial

/--
Generic polymorphic task frame with natural number world states.
-/
def genericNatFrame : TaskFrame T where
  WorldState := Nat
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial

/--
Generic polymorphic world history with universal domain.

Works with the genericTimeFrame, demonstrating polymorphism over the temporal type.
-/
def genericTimeHistory : WorldHistory (genericTimeFrame T) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun _ _ => ()
  respects_task := fun _ _ _ _ _ => trivial

end Polymorphic

/-! ## Comparison Examples -/

/--
Demonstrates that the same frame definition works with explicit Int.
-/
example : (genericTimeFrame Int).WorldState = Unit := rfl

/--
Demonstrates that generic and specific Int frames have the same task relation behavior.
-/
example : (genericTimeFrame Int).task_rel = intTimeFrame.task_rel := rfl

/-! ## Properties -/

/--
Integer time satisfies the nullity constraint.
-/
theorem int_nullity_example : intTimeFrame.task_rel () 0 () :=
  intTimeFrame.nullity ()

/--
Generic time satisfies the nullity constraint (polymorphic proof).
-/
theorem generic_nullity_example (T : Type*) [LinearOrderedAddCommGroup T] :
    (genericTimeFrame T).task_rel () 0 () :=
  (genericTimeFrame T).nullity ()

/--
Integer time compositionality example: 1 + 2 = 3 duration composition.
-/
theorem int_compositionality_example :
    intTimeFrame.task_rel () 3 () := by
  show intTimeFrame.task_rel () (1 + 2) ()
  exact intTimeFrame.compositionality () () () 1 2
    (intTimeFrame.nullity ())
    (intTimeFrame.nullity ())

/--
Generic compositionality theorem (polymorphic).

For any temporal type `T`, tasks of duration `x` and `y` compose
to a task of duration `x + y`.
-/
theorem generic_compositionality (T : Type*) [LinearOrderedAddCommGroup T] (x y : T) :
    (genericTimeFrame T).task_rel () (x + y) () :=
  (genericTimeFrame T).compositionality () () () x y
    ((genericTimeFrame T).nullity ())
    ((genericTimeFrame T).nullity ())

/-! ## History Domain Examples -/

/--
All integer times are in the universal domain.
-/
theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial

/--
Generic histories have universal domains (polymorphic).
-/
theorem generic_domain_universal (T : Type*) [LinearOrderedAddCommGroup T] (t : T) :
    (genericTimeHistory T).domain t := trivial

end Archive
