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
specifies that the temporal structure is a "totally ordered abelian group D = ⟨D, +, ≤⟩".
ProofChecker implements this via the unbundled typeclasses `[AddCommGroup D] [LinearOrder D]
[IsOrderedAddMonoid D]`, which provide exactly this structure.

## Example Temporal Types

### Integer Time (`Int`)
- **Use case**: Discrete temporal logic, countable time steps
- **Instance**: Uses unbundled instances for AddCommGroup, LinearOrder, IsOrderedAddMonoid
- **Advantages**: Simple, decidable, standard temporal logic interpretation

### Polymorphic Examples
The examples below demonstrate how ProofChecker's polymorphic types work with
any type `D` that has `AddCommGroup`, `LinearOrder`, and `IsOrderedAddMonoid` instances. This includes:
- `Int`: Discrete integer time
- `Rat`: Dense rational time (requires additional Mathlib imports)
- `Real`: Continuous real time (requires additional Mathlib imports)

## Main Definitions

- `intTimeFrame`: Example task frame using `Int` as temporal type
- `intTimeHistory`: Example world history using `Int`
- `genericTimeFrame`: Polymorphic task frame (works with any `D`)
- `genericTimeHistory`: Polymorphic world history (works with any `D`)

## Implementation Notes

- All examples use `trivial` task relations for simplicity
- Convexity proofs use the full domain (`fun _ => True`) for simplicity
- These examples are for demonstration and testing purposes

## References

* [TaskFrame.lean](../ProofChecker/Semantics/TaskFrame.lean) - TaskFrame definition
* [WorldHistory.lean](../ProofChecker/Semantics/WorldHistory.lean) - WorldHistory definition
* JPL Paper app:TaskSemantics (def:frame, line 1835) - Temporal structure specification
-/

namespace Bimodal.Examples.TemporalStructures

open Bimodal.Semantics

/-! ## Integer Time Examples (Standard) -/

/--
Standard integer time task frame.

This is the default temporal structure used in most temporal logic applications.
Discrete time steps with integer arithmetic. WorldState is Unit (trivial).
-/
def intTimeFrame : TaskFrame Int where
  WorldState := Unit
  task_rel := fun _ _ _ => True
  nullity_identity := fun _ _ => ⟨fun _ => Subsingleton.elim _ _, fun _ => trivial⟩
  forward_comp := fun _ _ _ _ _ _ _ _ _ => trivial
  converse := fun _ _ _ => ⟨fun _ => trivial, fun _ => trivial⟩

/--
Integer time task frame with natural number world states.

A slightly more complex frame with `Nat` world states. Task relation is `d ≠ 0 ∨ w = u`
to satisfy nullity_identity while remaining permissive for non-zero durations.
-/
def intNatFrame : TaskFrame Int where
  WorldState := Nat
  task_rel := fun w d u => d ≠ 0 ∨ w = u
  nullity_identity := fun w u => by
    constructor
    · intro h
      cases h with
      | inl h => exact absurd rfl h
      | inr h => exact h
    · intro h
      right; exact h
  forward_comp := fun w u v x y hx hy h1 h2 => by
    cases h1 with
    | inl hxne =>
      left
      intro heq
      have hy_eq : y = -x := (neg_eq_of_add_eq_zero_right heq).symm
      have h1 : 0 ≤ -x := hy_eq ▸ hy
      have h2 : x ≤ 0 := neg_nonneg.mp h1
      have h3 : x = 0 := le_antisymm h2 hx
      exact hxne h3
    | inr hw =>
      cases h2 with
      | inl hyne =>
        left
        intro heq
        have hx_eq : x = -y := (neg_eq_of_add_eq_zero_left heq).symm
        have h1 : 0 ≤ -y := hx_eq ▸ hx
        have h2 : y ≤ 0 := neg_nonneg.mp h1
        have h3 : y = 0 := le_antisymm h2 hy
        exact hyne h3
      | inr hu => right; exact hw.trans hu
  converse := fun w d u => by
    constructor
    · intro h
      cases h with
      | inl hd => left; simp [hd]
      | inr heq => right; exact heq.symm
    · intro h
      cases h with
      | inl hnd => left; simp at hnd; exact hnd
      | inr heq => right; exact heq.symm

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

variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Generic polymorphic task frame.

Works with any temporal type `D` that has ordered additive group instances.
This demonstrates ProofChecker's polymorphic design. WorldState is Unit (trivial).
-/
def genericTimeFrame : TaskFrame D where
  WorldState := Unit
  task_rel := fun _ _ _ => True
  nullity_identity := fun _ _ => ⟨fun _ => Subsingleton.elim _ _, fun _ => trivial⟩
  forward_comp := fun _ _ _ _ _ _ _ _ _ => trivial
  converse := fun _ _ _ => ⟨fun _ => trivial, fun _ => trivial⟩

/--
Generic polymorphic task frame with natural number world states.

Task relation is `d ≠ 0 ∨ w = u` to satisfy nullity_identity.
-/
def genericNatFrame : TaskFrame D where
  WorldState := Nat
  task_rel := fun w d u => d ≠ 0 ∨ w = u
  nullity_identity := fun w u => by
    constructor
    · intro h
      cases h with
      | inl h => exact absurd rfl h
      | inr h => exact h
    · intro h
      right; exact h
  forward_comp := fun w u v x y hx hy h1 h2 => by
    cases h1 with
    | inl hxne =>
      left
      intro heq
      have hy_eq : y = -x := (neg_eq_of_add_eq_zero_right heq).symm
      have h1 : 0 ≤ -x := hy_eq ▸ hy
      have h2 : x ≤ 0 := neg_nonneg.mp h1
      have h3 : x = 0 := le_antisymm h2 hx
      exact hxne h3
    | inr hw =>
      cases h2 with
      | inl hyne =>
        left
        intro heq
        have hx_eq : x = -y := (neg_eq_of_add_eq_zero_left heq).symm
        have h1 : 0 ≤ -y := hx_eq ▸ hx
        have h2 : y ≤ 0 := neg_nonneg.mp h1
        have h3 : y = 0 := le_antisymm h2 hy
        exact hyne h3
      | inr hu => right; exact hw.trans hu
  converse := fun w d u => by
    constructor
    · intro h
      cases h with
      | inl hd => left; simp [hd]
      | inr heq => right; exact heq.symm
    · intro h
      cases h with
      | inl hnd => left; simp at hnd; exact hnd
      | inr heq => right; exact heq.symm

/--
Generic polymorphic world history with universal domain.

Works with the genericTimeFrame, demonstrating polymorphism over the temporal type.
-/
def genericTimeHistory : WorldHistory (genericTimeFrame D) where
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
Integer time satisfies the nullity constraint (derived from nullity_identity).
-/
theorem int_nullity_example : intTimeFrame.task_rel () 0 () :=
  TaskFrame.nullity intTimeFrame ()

/--
Generic time satisfies the nullity constraint (polymorphic proof, derived from nullity_identity).
-/
theorem generic_nullity_example (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    (genericTimeFrame D).task_rel () 0 () :=
  TaskFrame.nullity (genericTimeFrame D) ()

/--
Integer time forward compositionality example: 1 + 2 = 3 duration composition.
-/
theorem int_compositionality_example :
    intTimeFrame.task_rel () 3 () := by
  show intTimeFrame.task_rel () (1 + 2) ()
  exact intTimeFrame.forward_comp () () () 1 2
    (by omega : 0 ≤ (1 : Int))
    (by omega : 0 ≤ (2 : Int))
    (TaskFrame.nullity intTimeFrame ())
    (TaskFrame.nullity intTimeFrame ())

/--
Generic forward compositionality theorem (polymorphic).

For any temporal type `D` and non-negative durations `x` and `y`, tasks compose
to a task of duration `x + y`.
-/
theorem generic_compositionality (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (x y : D) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    (genericTimeFrame D).task_rel () (x + y) () :=
  (genericTimeFrame D).forward_comp () () () x y hx hy
    (TaskFrame.nullity (genericTimeFrame D) ())
    (TaskFrame.nullity (genericTimeFrame D) ())

/-! ## History Domain Examples -/

/--
All integer times are in the universal domain.
-/
theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial

/--
Generic histories have universal domains (polymorphic).
-/
theorem generic_domain_universal (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (t : D) :
    (genericTimeHistory D).domain t := trivial

end Bimodal.Examples.TemporalStructures
