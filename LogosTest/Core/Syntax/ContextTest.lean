import Logos.Core.Syntax.Context

/-!
# Context Test Suite

Tests for the Context type and helper functions.

## Test Categories

- Context type alias (List Formula)
- Membership tests
- Subset tests
- Map operation (applying transformation to all formulas)
-/

namespace LogosTest.Core.Syntax

open Logos.Core.Syntax

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

-- Test: Map composition
example (f g : Formula → Formula) (Γ : Context) :
  Context.map f (Context.map g Γ) = Context.map (f ∘ g) Γ := by
  induction Γ with
  | nil => rfl
  | cons h t ih => simp [Context.map, ih]

-- Test: Map preserves length
example (f : Formula → Formula) (Γ : Context) :
  (Context.map f Γ).length = Γ.length := by
  induction Γ with
  | nil => rfl
  | cons h t ih => simp [Context.map, ih]

end LogosTest.Core.Syntax
