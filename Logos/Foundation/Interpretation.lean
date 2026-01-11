import Logos.Foundation.Frame
import Logos.Foundation.Proposition
import Mathlib.Data.Fin.Tuple.Basic

/-!
# Interpretation Functions for Constitutive Models

This module defines interpretation functions that assign meanings to
non-logical vocabulary in constitutive models.

## Paper Specification Reference

**Interpretation (RECURSIVE_SEMANTICS.md)**:
The interpretation function I assigns:
- n-place function symbols f → I(f) : Sⁿ → S (0-place = individual constants)
- n-place predicates F → ordered pairs ⟨v_F, f_F⟩ where:
  - v_F : set of functions Sⁿ → S (verifier functions)
  - f_F : set of functions Sⁿ → S (falsifier functions)
- Sentence letters (0-place predicates) p → ⟨verifier set, falsifier set⟩

## Main Definitions

- `Interpretation`: Structure assigning meanings to non-logical vocabulary
- `VarAssignment`: Variable assignment mapping variables to states

## Implementation Notes

We use `Fin n → S` for n-ary functions over states, which is equivalent
to `Sⁿ → S` in the paper notation.
-/

namespace Logos.Foundation

variable {F : ConstitutiveFrame}

/--
Variable assignment: a function mapping variable names to states.

**Paper notation**: σ : Var → S
-/
def VarAssignment (F : ConstitutiveFrame) := String → F.State

namespace VarAssignment

/--
Update a variable assignment at a single variable.

**Paper notation**: σ[v/x] maps x to v and agrees with σ elsewhere.
-/
def update (σ : VarAssignment F) (x : String) (v : F.State) : VarAssignment F :=
  fun y => if y = x then v else σ y

/--
Updating at x and then looking up x gives the new value.
-/
@[simp]
theorem update_same (σ : VarAssignment F) (x : String) (v : F.State) :
    (σ.update x v) x = v := by
  simp [update]

/--
Updating at x doesn't affect other variables.
-/
@[simp]
theorem update_other (σ : VarAssignment F) (x y : String) (v : F.State) (h : y ≠ x) :
    (σ.update x v) y = σ y := by
  simp [update, h]

end VarAssignment

/--
Predicate interpretation: a bilateral proposition for each arity.

For n-ary predicates, the verifier and falsifier "functions" are actually
sets of functions Sⁿ → S. For sentence letters (0-ary), these reduce to
sets of states.
-/
structure PredicateInterp (F : ConstitutiveFrame) (n : Nat) where
  /-- Verifier functions: each f ∈ verifierFns satisfies f(a₁,...,aₙ) verifies F(a₁,...,aₙ) -/
  verifierFns : Set ((Fin n → F.State) → F.State)
  /-- Falsifier functions: each f ∈ falsifierFns satisfies f(a₁,...,aₙ) falsifies F(a₁,...,aₙ) -/
  falsifierFns : Set ((Fin n → F.State) → F.State)

namespace PredicateInterp

/--
Sentence letter interpretation (0-ary predicate).
Verifier and falsifier functions reduce to constant functions,
which we can identify with states.
-/
def sentenceLetter (F : ConstitutiveFrame) (verifiers falsifiers : Set F.State) :
    PredicateInterp F 0 where
  verifierFns := { f | f (Fin.elim0) ∈ verifiers }
  falsifierFns := { f | f (Fin.elim0) ∈ falsifiers }

/--
Convert to bilateral proposition for sentence letters.
-/
def toBilateralProp (p : PredicateInterp F 0) : BilateralProp F.State where
  verifiers := { s | ∃ f ∈ p.verifierFns, f Fin.elim0 = s }
  falsifiers := { s | ∃ f ∈ p.falsifierFns, f Fin.elim0 = s }

end PredicateInterp

/--
Function symbol interpretation: maps n states to a state.

For individual constants (0-ary function symbols), this is just a state.
-/
def FunctionInterp (F : ConstitutiveFrame) (n : Nat) := (Fin n → F.State) → F.State

namespace FunctionInterp

/--
Individual constant interpretation (0-ary function symbol).
-/
def constant (s : F.State) : FunctionInterp F 0 :=
  fun _ => s

end FunctionInterp

/--
Full interpretation for a constitutive model.

Assigns meanings to function symbols and predicates of each arity.
-/
structure Interpretation (F : ConstitutiveFrame) where
  /-- Interpretation of function symbols by arity -/
  functionSymbol : String → (n : Nat) → FunctionInterp F n
  /-- Interpretation of predicates by arity -/
  predicate : String → (n : Nat) → PredicateInterp F n

namespace Interpretation

/--
Get the interpretation of an individual constant (0-ary function symbol).
-/
def getConstant (I : Interpretation F) (c : String) : F.State :=
  I.functionSymbol c 0 Fin.elim0

/--
Get the interpretation of a sentence letter (0-ary predicate).
-/
def getSentenceLetter (I : Interpretation F) (p : String) : BilateralProp F.State :=
  (I.predicate p 0).toBilateralProp

end Interpretation

/--
Constitutive Model: a frame with an interpretation.

**Paper definition**: M = ⟨S, ⊑, I⟩ where ⟨S, ⊑⟩ is a constitutive frame
and I is an interpretation function.
-/
structure ConstitutiveModel where
  /-- The underlying constitutive frame -/
  frame : ConstitutiveFrame
  /-- Interpretation of non-logical vocabulary -/
  interp : Interpretation frame

namespace ConstitutiveModel

/--
Get the state type from a model.
-/
def State (M : ConstitutiveModel) : Type* := M.frame.State

/--
Get the null state of a model.
-/
def null (M : ConstitutiveModel) : M.frame.State := M.frame.null

/--
Get the full state of a model.
-/
def full (M : ConstitutiveModel) : M.frame.State := M.frame.full

/--
Get fusion operation from a model.
-/
def fusion (M : ConstitutiveModel) (s t : M.frame.State) : M.frame.State :=
  M.frame.fusion s t

end ConstitutiveModel

end Logos.Foundation
