import Bimodal.Syntax.Context

/-!
# Context Test Suite

Tests for the Context type and helper functions.

## Test Categories

- Context type alias (List Formula)
- Membership tests
- Subset tests
- Map operation (applying transformation to all formulas)
- Helper functions (isEmpty, singleton)
- Structural theorems (map_length, map_comp, etc.)
-/

namespace LogosTest.Core.Syntax

open Bimodal.Syntax

-- Test: Empty context
example : ([] : Context) = [] := rfl

-- Test: Single formula context
example : [Formula.atom "p"] = [Formula.atom "p"] := rfl

-- Test: Multiple formulas context
example :
  [Formula.atom "p", Formula.atom "q", Formula.bot] =
  [Formula.atom "p", Formula.atom "q", Formula.bot] := rfl

-- Test: Membership - element present
example : Formula.atom "p" ∈ [Formula.atom "p", Formula.atom "q"] := by
  simp

-- Test: Membership - element not present
example : Formula.atom "r" ∉ [Formula.atom "p", Formula.atom "q"] := by
  simp

-- Test: Subset - empty is subset of any
example (Γ : Context) : [] ⊆ Γ := by
  intro x
  intro h
  contradiction

-- Test: Subset - self is subset of self
example (Γ : Context) : Γ ⊆ Γ := by
  intro x h
  exact h

-- Test: Subset - transitivity
example (Γ Δ Θ : Context) (h1 : Γ ⊆ Δ) (h2 : Δ ⊆ Θ) : Γ ⊆ Θ := by
  intro x hx
  exact h2 (h1 hx)

-- Test: Map operation - empty context
example (f : Formula → Formula) : Context.map f [] = [] := rfl

-- Test: Map operation - single element
example (f : Formula → Formula) (p : Formula) :
  Context.map f [p] = [f p] := rfl

-- Test: Map operation - multiple elements
example (f : Formula → Formula) (p q r : Formula) :
  Context.map f [p, q, r] = [f p, f q, f r] := rfl

-- Test: Map with box operator
example :
  Context.map Formula.box [Formula.atom "p", Formula.atom "q"] =
  [Formula.box (Formula.atom "p"), Formula.box (Formula.atom "q")] := rfl

-- Test: Map with all_future operator
example :
  Context.map Formula.all_future [Formula.atom "p", Formula.atom "q"] =
  [Formula.all_future (Formula.atom "p"), Formula.all_future (Formula.atom "q")] := rfl

-- Test: Map composition theorem
example (f g : Formula → Formula) (Γ : Context) :
  Context.map f (Context.map g Γ) = Context.map (f ∘ g) Γ := by
  exact Context.map_comp f g Γ

-- Test: Map preserves length theorem
example (f : Formula → Formula) (Γ : Context) :
  (Context.map f Γ).length = Γ.length := by
  exact Context.map_length f Γ

-- Test: Map identity theorem
example (Γ : Context) : Context.map id Γ = Γ := by
  exact Context.map_id Γ

-- Test: Map distributes over append
example (f : Formula → Formula) (Γ Δ : Context) :
  Context.map f (Γ ++ Δ) = Context.map f Γ ++ Context.map f Δ := by
  exact Context.map_append f Γ Δ

-- Test: isEmpty - empty context
example : Context.isEmpty [] = true := rfl

-- Test: isEmpty - non-empty context
example : Context.isEmpty [Formula.atom "p"] = false := rfl

-- Test: singleton creates single-element context
example : Context.singleton (Formula.atom "p") = [Formula.atom "p"] := rfl

-- Test: mem_singleton_iff
example (φ ψ : Formula) :
  φ ∈ Context.singleton ψ ↔ φ = ψ := by
  exact Context.mem_singleton_iff

-- Test: isEmpty_iff_eq_nil
example (Γ : Context) :
  Context.isEmpty Γ = true ↔ Γ = [] := by
  exact Context.isEmpty_iff_eq_nil Γ

-- Test: not_mem_nil
example (φ : Formula) : φ ∉ ([] : Context) := by
  exact Context.not_mem_nil φ

-- Test: mem_map_iff - forward direction
example (f : Formula → Formula) (Γ : Context) (ψ : Formula) (h : ψ ∈ Γ) :
  f ψ ∈ Context.map f Γ := by
  exact Context.mem_map_of_mem h

-- Test: mem_map_iff - bidirectional
example (f : Formula → Formula) (Γ : Context) (φ : Formula) :
  φ ∈ Context.map f Γ ↔ ∃ ψ ∈ Γ, f ψ = φ := by
  exact Context.mem_map_iff

-- Test: map_cons
example (f : Formula → Formula) (φ : Formula) (Γ : Context) :
  Context.map f (φ :: Γ) = f φ :: Context.map f Γ := by
  exact Context.map_cons f φ Γ

-- Test: exists_mem_of_ne_nil
example (Γ : Context) (h : Γ ≠ []) : ∃ φ, φ ∈ Γ := by
  exact Context.exists_mem_of_ne_nil h

-- Integration test: Map box over context and check membership
example :
  Formula.box (Formula.atom "p") ∈
    Context.map Formula.box [Formula.atom "p", Formula.atom "q"] := by
  apply Context.mem_map_of_mem
  simp

-- Integration test: Map composition with box and all_future
example (Γ : Context) :
  Context.map Formula.box (Context.map Formula.all_future Γ) =
  Context.map (Formula.box ∘ Formula.all_future) Γ := by
  exact Context.map_comp Formula.box Formula.all_future Γ

-- Integration test: Length preservation through multiple maps
example (Γ : Context) :
  (Context.map Formula.box (Context.map Formula.all_future Γ)).length = Γ.length := by
  rw [Context.map_comp]
  exact Context.map_length _ Γ

end LogosTest.Core.Syntax
