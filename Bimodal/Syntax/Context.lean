import Bimodal.Syntax.Formula

/-!
# Context - Formula Lists for Proof Contexts

This module defines the Context type used to represent assumptions in derivations.

## Main Definitions

- `Context`: Type alias for `List Formula`
- `Context.map`: Apply a transformation to all formulas in a context
- `Context.isEmpty`: Check if a context is empty
- `Context.singleton`: Create a context with a single formula

## Main Results

- Contexts inherit all list operations (membership, subset, append, etc.)
- Map operation preserves structural properties (length, composition)
- Map operation is equivalent to `List.map` for formulas

## Implementation Notes

- Context is simply `List Formula`, leveraging Lean's built-in list operations
- Membership (`∈`) and subset (`⊆`) use standard list definitions
- The `map` operation is essential for modal K and temporal K inference rules
- Performance: List operations are O(n) for traversal, O(1) for cons

## References

* [ARCHITECTURE.md](../../../Documentation/UserGuide/ARCHITECTURE.md) - Proof system specification
* [Formula.lean](./Formula.lean) - Formula type definition
-/

namespace Bimodal.Syntax

/--
Context type representing a list of formula assumptions.

Used in the derivability relation `Γ ⊢ φ` where `Γ` is a context of assumptions.

## Examples

```lean
-- Empty context
example : Context := []

-- Single formula context
example : Context := [Formula.atom "p"]

-- Multiple formulas
example : Context := [Formula.atom "p", Formula.atom "q", Formula.bot]
```
-/
abbrev Context := List Formula

namespace Context

/--
Apply a transformation to all formulas in a context.

This is used in inference rules like:
- Modal K: If `Γ.map box ⊢ φ` then `Γ ⊢ box φ`
- Temporal K: If `Γ.map all_future ⊢ φ` then `Γ ⊢ all_future φ`

## Examples

```lean
Context.map Formula.box [Formula.atom "p", Formula.atom "q"] =
  [Formula.box (Formula.atom "p"), Formula.box (Formula.atom "q")]

Context.map Formula.all_future [Formula.atom "p"] =
  [Formula.all_future (Formula.atom "p")]
```

## Performance

Time complexity: O(n) where n is the length of the context.
Space complexity: O(n) for the new list.
-/
def map (f : Formula → Formula) : Context → Context := List.map f

/--
Check if a context is empty.

## Examples

```lean
isEmpty [] = true
isEmpty [Formula.atom "p"] = false
```
-/
def isEmpty : Context → Bool
  | [] => true
  | _ :: _ => false

/--
Create a context containing a single formula.

## Examples

```lean
singleton (Formula.atom "p") = [Formula.atom "p"]
```
-/
def singleton (φ : Formula) : Context := [φ]

/--
Theorem: Mapping a function over a context preserves length.

This is useful for proving properties about derivations that transform contexts.
-/
theorem map_length (f : Formula → Formula) (Γ : Context) :
    (map f Γ).length = Γ.length := by
  simp [map]

/--
Theorem: Mapping functions compose: `map f (map g Γ) = map (f ∘ g) Γ`.

This allows us to combine multiple context transformations into a single pass.
-/
theorem map_comp (f g : Formula → Formula) (Γ : Context) :
    map f (map g Γ) = map (f ∘ g) Γ := by
  simp [map, List.map_map]

/--
Theorem: Mapping the identity function leaves the context unchanged.
-/
theorem map_id (Γ : Context) : map id Γ = Γ := by
  simp [map]

/--
Theorem: Mapping over an empty context yields an empty context.
-/
theorem map_nil (f : Formula → Formula) : map f [] = [] := by
  rfl

/--
Theorem: Mapping distributes over cons.
-/
theorem map_cons (f : Formula → Formula) (φ : Formula) (Γ : Context) :
    map f (φ :: Γ) = f φ :: map f Γ := by
  rfl

/--
Theorem: Mapping distributes over append.

This is useful when combining contexts in derivations.
-/
theorem map_append (f : Formula → Formula) (Γ Δ : Context) :
    map f (Γ ++ Δ) = map f Γ ++ map f Δ := by
  simp [map]

/--
Theorem: Membership in mapped context comes from mapping a member.

If `φ ∈ map f Γ`, then there exists `ψ ∈ Γ` such that `f ψ = φ`.
-/
theorem mem_map_iff {f : Formula → Formula} {Γ : Context} {φ : Formula} :
    φ ∈ map f Γ ↔ ∃ ψ ∈ Γ, f ψ = φ := by
  simp [map]

/--
Theorem: If `ψ ∈ Γ`, then `f ψ ∈ map f Γ`.

This is the forward direction of `mem_map_iff`.
-/
theorem mem_map_of_mem {f : Formula → Formula} {Γ : Context} {ψ : Formula}
    (h : ψ ∈ Γ) : f ψ ∈ map f Γ := by
  rw [mem_map_iff]
  exact ⟨ψ, h, rfl⟩

/--
Theorem: Empty context has no members.
-/
theorem not_mem_nil (φ : Formula) : φ ∉ ([] : Context) := by
  simp

/--
Theorem: Singleton context contains exactly one formula.
-/
theorem mem_singleton_iff {φ ψ : Formula} :
    φ ∈ singleton ψ ↔ φ = ψ := by
  simp [singleton]

/--
Theorem: isEmpty is true iff the context equals [].
-/
theorem isEmpty_iff_eq_nil (Γ : Context) : isEmpty Γ = true ↔ Γ = [] := by
  cases Γ with
  | nil => simp [isEmpty]
  | cons _ _ => simp [isEmpty]

/--
Theorem: A non-empty context has at least one element.
-/
theorem exists_mem_of_ne_nil {Γ : Context} (h : Γ ≠ []) :
    ∃ φ, φ ∈ Γ := by
  cases Γ with
  | nil => contradiction
  | cons φ _ => exact ⟨φ, List.mem_cons_self φ _⟩

end Context

end Bimodal.Syntax
