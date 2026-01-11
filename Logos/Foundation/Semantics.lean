import Logos.Foundation.Frame
import Logos.Foundation.Proposition
import Logos.Foundation.Interpretation
import Logos.Foundation.Syntax

/-!
# Verification and Falsification Semantics

This module defines the hyperintensional verification (⊩⁺) and falsification (⊩⁻)
relations for constitutive formulas.

## Paper Specification Reference

**Verification/Falsification (RECURSIVE_SEMANTICS.md)**:
A state s verifies (⊩⁺) or falsifies (⊩⁻) a formula A relative to model M
and assignment σ according to the recursive clauses.

## Main Definitions

- `verifies`: Verification relation (M, σ, s ⊩⁺ A)
- `falsifies`: Falsification relation (M, σ, s ⊩⁻ A)
- `content`: Extract bilateral proposition content of a formula

## Implementation Notes

Verification and falsification are defined mutually recursively on formula
structure. The key insight is that negation swaps verification and falsification,
while conjunction/disjunction interact with the mereological structure.
-/

namespace Logos.Foundation

open ConstitutiveFormula

variable {F : ConstitutiveFrame}

/--
Evaluate a term to a state given model and assignment.

**Paper notation**: ⟦t⟧^σ_M
-/
def evalTerm (M : ConstitutiveModel) (σ : VarAssignment M.frame) : Term → M.frame.State
  | Term.var x => σ x
  | Term.const c => M.interp.getConstant c
  | Term.app f ts =>
    let args : Fin ts.length → M.frame.State := fun i => evalTerm M σ (ts.get i)
    M.interp.functionSymbol f ts.length (fun i => args (Fin.cast (by rfl) i))

/--
Verification relation: M, σ, s ⊩⁺ φ

A state s verifies formula φ relative to constitutive model M and
variable assignment σ.
-/
def verifies (M : ConstitutiveModel) (σ : VarAssignment M.frame) (s : M.frame.State)
    : ConstitutiveFormula → Prop
  | atom p =>
    -- Sentence letter: s verifies p iff s is in the verifier set for p
    s ∈ (M.interp.getSentenceLetter p).verifiers
  | pred P ts =>
    -- Predicate: there exists a verifier function f such that s = f(⟦t₁⟧,...,⟦tₙ⟧)
    let args : Fin ts.length → M.frame.State := fun i => evalTerm M σ (ts.get i)
    ∃ f ∈ (M.interp.predicate P ts.length).verifierFns,
      s = f (fun i => args (Fin.cast (by rfl) i))
  | bot =>
    -- Bottom: never verified
    False
  | top =>
    -- Top: always verified (every state verifies ⊤)
    True
  | neg φ =>
    -- Negation: s verifies ¬φ iff s falsifies φ
    falsifies M σ s φ
  | and φ ψ =>
    -- Conjunction: s verifies φ ∧ ψ iff s = t ⊔ u for some t, u
    -- where t verifies φ and u verifies ψ
    ∃ t u : M.frame.State, s = M.frame.fusion t u ∧
      verifies M σ t φ ∧ verifies M σ u ψ
  | or φ ψ =>
    -- Disjunction: s verifies φ ∨ ψ iff s verifies φ, or s verifies ψ,
    -- or s = t ⊔ u for some t, u where t verifies φ and u verifies ψ
    verifies M σ s φ ∨ verifies M σ s ψ ∨
    ∃ t u : M.frame.State, s = M.frame.fusion t u ∧
      verifies M σ t φ ∧ verifies M σ u ψ
  | ident φ ψ =>
    -- Identity: s verifies φ ≡ ψ iff s = null and the verifier sets
    -- and falsifier sets of φ and ψ are equal
    s = M.frame.null ∧
    (∀ t, verifies M σ t φ ↔ verifies M σ t ψ) ∧
    (∀ t, falsifies M σ t φ ↔ falsifies M σ t ψ)
  | lambdaApp x φ t =>
    -- Lambda application: s verifies (λx.φ)(t) iff s verifies φ[⟦t⟧/x]
    verifies M (σ.update x (evalTerm M σ t)) s φ

/--
Falsification relation: M, σ, s ⊩⁻ φ

A state s falsifies formula φ relative to constitutive model M and
variable assignment σ.
-/
def falsifies (M : ConstitutiveModel) (σ : VarAssignment M.frame) (s : M.frame.State)
    : ConstitutiveFormula → Prop
  | atom p =>
    -- Sentence letter: s falsifies p iff s is in the falsifier set for p
    s ∈ (M.interp.getSentenceLetter p).falsifiers
  | pred P ts =>
    -- Predicate: there exists a falsifier function f such that s = f(⟦t₁⟧,...,⟦tₙ⟧)
    let args : Fin ts.length → M.frame.State := fun i => evalTerm M σ (ts.get i)
    ∃ f ∈ (M.interp.predicate P ts.length).falsifierFns,
      s = f (fun i => args (Fin.cast (by rfl) i))
  | bot =>
    -- Bottom: only null state falsifies ⊥
    s = M.frame.null
  | top =>
    -- Top: only full state falsifies ⊤
    s = M.frame.full
  | neg φ =>
    -- Negation: s falsifies ¬φ iff s verifies φ
    verifies M σ s φ
  | and φ ψ =>
    -- Conjunction: s falsifies φ ∧ ψ iff s falsifies φ, or s falsifies ψ,
    -- or s = t ⊔ u for some t, u where t falsifies φ and u falsifies ψ
    falsifies M σ s φ ∨ falsifies M σ s ψ ∨
    ∃ t u : M.frame.State, s = M.frame.fusion t u ∧
      falsifies M σ t φ ∧ falsifies M σ u ψ
  | or φ ψ =>
    -- Disjunction: s falsifies φ ∨ ψ iff s = t ⊔ u for some t, u
    -- where t falsifies φ and u falsifies ψ
    ∃ t u : M.frame.State, s = M.frame.fusion t u ∧
      falsifies M σ t φ ∧ falsifies M σ u ψ
  | ident φ ψ =>
    -- Identity: s falsifies φ ≡ ψ iff s = null and either the verifier sets
    -- or the falsifier sets of φ and ψ differ
    s = M.frame.null ∧
    (¬(∀ t, verifies M σ t φ ↔ verifies M σ t ψ) ∨
     ¬(∀ t, falsifies M σ t φ ↔ falsifies M σ t ψ))
  | lambdaApp x φ t =>
    -- Lambda application: s falsifies (λx.φ)(t) iff s falsifies φ[⟦t⟧/x]
    falsifies M (σ.update x (evalTerm M σ t)) s φ

/--
Notation for verification: M, σ, s ⊩⁺ φ
-/
notation:50 M ", " σ ", " s " ⊩⁺ " φ => verifies M σ s φ

/--
Notation for falsification: M, σ, s ⊩⁻ φ
-/
notation:50 M ", " σ ", " s " ⊩⁻ " φ => falsifies M σ s φ

section BasicTheorems

variable (M : ConstitutiveModel) (σ : VarAssignment M.frame)

/--
Negation swaps verification and falsification (verification clause).
-/
theorem neg_verifies_iff_falsifies (s : M.frame.State) (φ : ConstitutiveFormula) :
    M, σ, s ⊩⁺ (~φ) ↔ M, σ, s ⊩⁻ φ := by
  simp only [verifies]

/--
Negation swaps verification and falsification (falsification clause).
-/
theorem neg_falsifies_iff_verifies (s : M.frame.State) (φ : ConstitutiveFormula) :
    M, σ, s ⊩⁻ (~φ) ↔ M, σ, s ⊩⁺ φ := by
  simp only [falsifies]

/--
Double negation: s verifies ¬¬φ iff s verifies φ
-/
theorem double_neg_verifies (s : M.frame.State) (φ : ConstitutiveFormula) :
    M, σ, s ⊩⁺ (~(~φ)) ↔ M, σ, s ⊩⁺ φ := by
  simp only [verifies, falsifies]

/--
Bottom is never verified.
-/
theorem bot_not_verified (s : M.frame.State) : ¬(M, σ, s ⊩⁺ bot) := by
  simp only [verifies, not_false_eq_true]

/--
Top is always verified.
-/
theorem top_verified (s : M.frame.State) : M, σ, s ⊩⁺ top := by
  simp only [verifies]

/--
Only null falsifies bottom.
-/
theorem bot_falsified_iff_null (s : M.frame.State) :
    M, σ, s ⊩⁻ bot ↔ s = M.frame.null := by
  simp only [falsifies]

/--
Only full falsifies top.
-/
theorem top_falsified_iff_full (s : M.frame.State) :
    M, σ, s ⊩⁻ top ↔ s = M.frame.full := by
  simp only [falsifies]

end BasicTheorems

/--
Extract the bilateral proposition content of a formula.

Given a formula φ, model M, and assignment σ, returns the bilateral
proposition with verifiers and falsifiers determined by the semantics.
-/
def content (M : ConstitutiveModel) (σ : VarAssignment M.frame)
    (φ : ConstitutiveFormula) : BilateralProp M.frame.State where
  verifiers := { s | M, σ, s ⊩⁺ φ }
  falsifiers := { s | M, σ, s ⊩⁻ φ }

/--
Propositional identity holds iff formulas have the same content.
-/
theorem ident_verifies_iff_same_content (M : ConstitutiveModel)
    (σ : VarAssignment M.frame) (φ ψ : ConstitutiveFormula) :
    M, σ, M.frame.null ⊩⁺ (φ ≣ ψ) ↔ (content M σ φ).equiv (content M σ ψ) := by
  simp only [verifies, content, BilateralProp.equiv]
  constructor
  · intro ⟨_, hv, hf⟩
    constructor
    · ext s; exact hv s
    · ext s; exact hf s
  · intro ⟨hv, hf⟩
    refine ⟨rfl, ?_, ?_⟩
    · intro s; exact Set.ext_iff.mp hv s
    · intro s; exact Set.ext_iff.mp hf s

end Logos.Foundation
