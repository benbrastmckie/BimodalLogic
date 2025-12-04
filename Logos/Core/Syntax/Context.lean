import Logos.Core.Syntax.Formula

/-!
# Context - Formula Lists for Proof Contexts

This module defines the Context type used to represent assumptions in derivations.

## Main Definitions

- `Context`: Type alias for `List Formula`
- `Context.map`: Apply a transformation to all formulas in a context

## Main Results

- Contexts inherit all list operations (membership, subset, append, etc.)
- Map operation preserves structural properties (length, etc.)

## Implementation Notes

- Context is simply `List Formula`, leveraging LEAN's built-in list operations
- Membership (`∈`) and subset (`⊆`) use standard list definitions
- The `map` operation is essential for modal K and temporal K inference rules

## References

* [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) - Proof system specification
* [Formula.lean](./Formula.lean) - Formula type definition
-/

namespace Logos.Core.Syntax

/--
Context type representing a list of formula assumptions.

Used in the derivability relation `Γ ⊢ φ` where `Γ` is a context of assumptions.
-/
abbrev Context := List Formula

namespace Context

/--
Apply a transformation to all formulas in a context.

This is used in inference rules like:
- Modal K: If `Γ.map box ⊢ φ` then `Γ ⊢ box φ`
- Temporal K: If `Γ.map future ⊢ φ` then `Γ ⊢ future φ`

## Examples

```lean
Context.map Formula.box [Formula.atom "p", Formula.atom "q"] =
  [Formula.box (Formula.atom "p"), Formula.box (Formula.atom "q")]
```
-/
def map (f : Formula → Formula) : Context → Context
  | [] => []
  | h :: t => f h :: map f t

/--
Theorem: Mapping a function over a context preserves length.
-/
theorem map_length (f : Formula → Formula) (Γ : Context) :
  (map f Γ).length = Γ.length := by
  induction Γ with
  | nil => rfl
  | cons h t ih => simp [map, ih]

/--
Theorem: Mapping functions compose: `map f (map g Γ) = map (f ∘ g) Γ`.
-/
theorem map_comp (f g : Formula → Formula) (Γ : Context) :
  map f (map g Γ) = map (f ∘ g) Γ := by
  induction Γ with
  | nil => rfl
  | cons h t ih => simp [map, ih]

end Context

end Logos.Core.Syntax
