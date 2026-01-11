import Logos.Explanatory.Frame
import Logos.Explanatory.Syntax
import Logos.Foundation.Semantics

/-!
# Truth Evaluation for Explanatory Extension

This module implements truth evaluation for Explanatory Extension formulas
relative to a model, world-history, time, variable assignment, and temporal index.

## Paper Specification Reference

**Truth Conditions (RECURSIVE_SEMANTICS.md)**:
Truth is evaluated relative to a model M, world-history τ, time x ∈ D,
variable assignment σ, and temporal index i⃗ = ⟨i₁, i₂, ...⟩.

## Main Definitions

- `truthAt`: Truth evaluation function
- `validInModel`: Validity in a specific model
- `entailsInModel`: Logical consequence in a model

## Implementation Notes

Truth evaluation is defined recursively on formula structure. The counterfactual
conditional uses a simplified mereological formulation from the paper.
-/

namespace Logos.Explanatory

open Logos.Foundation
open Logos.Explanatory.Formula

variable {T : Type*} [LinearOrderedAddCommGroup T]

/--
Temporal index for store/recall operators.
A list of times that can be stored into and recalled from.
-/
def TemporalIndex (T : Type*) := List T

namespace TemporalIndex

/-- Empty temporal index -/
def empty : TemporalIndex T := []

/-- Update temporal index at position i with time t -/
def update (idx : TemporalIndex T) (i : Nat) (t : T) : TemporalIndex T :=
  let lst : List T := idx
  if h : i < lst.length then
    lst.set (Fin.mk i h) t
  else
    -- Extend list if needed
    lst ++ List.replicate (i - lst.length) t ++ [t]

/-- Get time at position i (returns 0 if out of bounds) -/
def get [Zero T] (idx : TemporalIndex T) (i : Nat) : T :=
  (idx : List T).getD i 0

end TemporalIndex

/-- Convert Core formula to Constitutive formula (for atoms and base cases) -/
def toConstitutiveFormula : Formula → ConstitutiveFormula
  | Formula.cfml c => c
  | Formula.top => ConstitutiveFormula.top
  | Formula.bot => ConstitutiveFormula.bot
  | Formula.neg φ => ConstitutiveFormula.neg (toConstitutiveFormula φ)
  | Formula.conj φ ψ => ConstitutiveFormula.and (toConstitutiveFormula φ) (toConstitutiveFormula ψ)
  | Formula.disj φ ψ => ConstitutiveFormula.or (toConstitutiveFormula φ) (toConstitutiveFormula ψ)
  | _ => ConstitutiveFormula.top  -- Modal/temporal operators don't have constitutive equivalents

/--
Evaluate a term in a Core model.
-/
partial def evalTermCore (M : CoreModel T) (σ : VarAssignment M.frame.toConstitutiveFrame)
    : Term → M.frame.State
  | Term.var x => σ x
  | Term.const c => M.interp.getConstant c
  | Term.app f ts =>
    let args : Fin ts.length → M.frame.State := fun i => evalTermCore M σ (ts.get i)
    M.interp.functionSymbol f ts.length (fun i => args (Fin.cast (by rfl) i))

/--
Truth evaluation for Explanatory Extension formulas.

M, τ, x, σ, i⃗ ⊨ A

Parameters:
- M: The core model
- τ: The world-history
- t: The current time
- ht: Proof that t is in τ's domain
- σ: Variable assignment
- idx: Temporal index for store/recall
- φ: The formula to evaluate
-/
def truthAt (M : CoreModel T) (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
    (σ : VarAssignment M.frame.toConstitutiveFrame) (idx : TemporalIndex T)
    : Formula → Prop
  | Formula.cfml c =>
    -- Constitutive formula: check if some verifier is part of current world-state
    ∃ s, verifies ⟨M.frame.toConstitutiveFrame, M.interp⟩ σ s c ∧
         M.frame.toConstitutiveFrame.parthood s (τ.states t ht)
  | Formula.top => True
  | Formula.bot => False
  | Formula.neg φ => ¬truthAt M τ t ht σ idx φ
  | Formula.conj φ ψ => truthAt M τ t ht σ idx φ ∧ truthAt M τ t ht σ idx ψ
  | Formula.disj φ ψ => truthAt M τ t ht σ idx φ ∨ truthAt M τ t ht σ idx ψ
  | Formula.box φ =>
    -- □A: true iff A is true at all world-histories at time t
    ∀ (α : WorldHistory M.frame) (hα : t ∈ α.domain),
      truthAt M α t hα σ idx φ
  | Formula.diamond φ =>
    -- ◇A: true iff A is true at some world-history at time t
    ∃ (α : WorldHistory M.frame) (hα : t ∈ α.domain),
      truthAt M α t hα σ idx φ
  | Formula.all_past φ =>
    -- HA: true iff A is true at all past times
    ∀ y (hy : y ∈ τ.domain), y < t → truthAt M τ y hy σ idx φ
  | Formula.all_future φ =>
    -- GA: true iff A is true at all future times
    ∀ y (hy : y ∈ τ.domain), y > t → truthAt M τ y hy σ idx φ
  | Formula.some_past φ =>
    -- PA: true iff A is true at some past time
    ∃ y, ∃ hy : y ∈ τ.domain, y < t ∧ truthAt M τ y hy σ idx φ
  | Formula.some_future φ =>
    -- FA: true iff A is true at some future time
    ∃ y, ∃ hy : y ∈ τ.domain, y > t ∧ truthAt M τ y hy σ idx φ
  | Formula.since φ ψ =>
    -- A ◁ B: B was true at some past time, and A has been true since
    ∃ z, ∃ hz : z ∈ τ.domain, z < t ∧ truthAt M τ z hz σ idx ψ ∧
      ∀ y (hy : y ∈ τ.domain), z < y → y < t → truthAt M τ y hy σ idx φ
  | Formula.untl φ ψ =>
    -- A ▷ B: B will be true at some future time, and A is true until then
    ∃ z, ∃ hz : z ∈ τ.domain, z > t ∧ truthAt M τ z hz σ idx ψ ∧
      ∀ y (hy : y ∈ τ.domain), t < y → y < z → truthAt M τ y hy σ idx φ
  | Formula.counterfactual φ ψ =>
    -- φ □→ C: counterfactual conditional
    -- For all verifiers v of φ and all histories β:
    -- if some maximal v-compatible part of τ(t) fused with v is part of β(t), then C holds in β
    -- Simplified: we check if C holds at all histories where the antecedent could be made true
    ∀ (β : WorldHistory M.frame) (hβ : t ∈ β.domain),
      -- If φ is verified by some part of β(t), then ψ holds in β
      (∃ s, verifies ⟨M.frame.toConstitutiveFrame, M.interp⟩ σ s (toConstitutiveFormula φ) ∧
            M.frame.toConstitutiveFrame.parthood s (β.states t hβ)) →
      truthAt M β t hβ σ idx ψ
  | Formula.store i φ =>
    -- ↑ⁱA: store current time at index i, then evaluate A
    truthAt M τ t ht σ (idx.update i t) φ
  | Formula.rcall i φ =>
    -- ↓ⁱA: recall time from index i, evaluate A at that time
    let recalled := idx.get i
    ∃ h : recalled ∈ τ.domain, truthAt M τ recalled h σ idx φ
  | Formula.all x φ =>
    -- ∀x.A: true iff A is true for all states s
    ∀ s : M.frame.State, truthAt M τ t ht (σ.update x s) idx φ
  | Formula.lambdaApp x φ term =>
    -- (λx.A)(t): substitute term value for x
    truthAt M τ t ht (σ.update x (evalTermCore M σ term)) idx φ

/-! ### Falsehood -/

/--
Falsehood evaluation: M, τ, x, σ, i⃗ ⊭ A
-/
def falsehoodAt (M : CoreModel T) (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
    (σ : VarAssignment M.frame.toConstitutiveFrame) (idx : TemporalIndex T)
    (φ : Formula) : Prop :=
  ¬truthAt M τ t ht σ idx φ

/-! ### Validity and Consequence -/

/--
A formula is valid in a model if it is true at all world-histories and times.
-/
def validInModel (M : CoreModel T) (φ : Formula) : Prop :=
  ∀ (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
    (σ : VarAssignment M.frame.toConstitutiveFrame),
    truthAt M τ t ht σ TemporalIndex.empty φ

/--
Logical consequence in a model: Γ ⊨_M φ if φ is true whenever all formulas in Γ are true.
-/
def entailsInModel (M : CoreModel T) (Γ : List Formula) (φ : Formula) : Prop :=
  ∀ (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
    (σ : VarAssignment M.frame.toConstitutiveFrame),
    (∀ ψ ∈ Γ, truthAt M τ t ht σ TemporalIndex.empty ψ) →
    truthAt M τ t ht σ TemporalIndex.empty φ

/-! ### Notation -/

notation:50 M ", " τ ", " t ", " σ " ⊨ " φ => truthAt M τ t _ σ TemporalIndex.empty φ
notation:50 M ", " τ ", " t ", " σ " ⊭ " φ => falsehoodAt M τ t _ σ TemporalIndex.empty φ

end Logos.Explanatory
