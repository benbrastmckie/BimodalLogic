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

variable {F : ConstitutiveFrame}

/--
Evaluate a term to a state given model and assignment.

**Paper notation**: ⟦t⟧^σ_M
-/
partial def evalTerm (M : ConstitutiveModel) (σ : VarAssignment M.frame) : Term → M.frame.State
  | Term.var x => σ x
  | Term.const c => M.interp.getConstant c
  | Term.app f ts =>
    let args : Fin ts.length → M.frame.State := fun i => evalTerm M σ (ts.get i)
    M.interp.functionSymbol f ts.length (fun i => args (Fin.cast (by rfl) i))

mutual
/--
Verification relation: M, σ, s ⊩⁺ φ

A state s verifies formula φ relative to constitutive model M and
variable assignment σ.
-/
def verifies (M : ConstitutiveModel) (σ : VarAssignment M.frame) (s : M.frame.State)
    : ConstitutiveFormula → Prop
  | ConstitutiveFormula.atom p =>
    -- Sentence letter: s verifies p iff s is in the verifier set for p
    s ∈ (M.interp.getSentenceLetter p).verifiers
  | ConstitutiveFormula.pred P ts =>
    -- Predicate: there exists a verifier function f such that s = f(⟦t₁⟧,...,⟦tₙ⟧)
    let args : Fin ts.length → M.frame.State := fun i => evalTerm M σ (ts.get i)
    ∃ f ∈ (M.interp.predicate P ts.length).verifierFns,
      s = f (fun i => args (Fin.cast (by rfl) i))
  | ConstitutiveFormula.bot =>
    -- Bottom: never verified
    False
  | ConstitutiveFormula.top =>
    -- Top: always verified (every state verifies ⊤)
    True
  | ConstitutiveFormula.neg φ =>
    -- Negation: s verifies ¬φ iff s falsifies φ
    falsifies M σ s φ
  | ConstitutiveFormula.and φ ψ =>
    -- Conjunction: s verifies φ ∧ ψ iff s = t ⊔ u for some t, u
    -- where t verifies φ and u verifies ψ
    ∃ t u : M.frame.State, s = M.frame.fusion t u ∧
      verifies M σ t φ ∧ verifies M σ u ψ
  | ConstitutiveFormula.or φ ψ =>
    -- Disjunction: s verifies φ ∨ ψ iff s verifies φ, or s verifies ψ,
    -- or s = t ⊔ u for some t, u where t verifies φ and u verifies ψ
    verifies M σ s φ ∨ verifies M σ s ψ ∨
    ∃ t u : M.frame.State, s = M.frame.fusion t u ∧
      verifies M σ t φ ∧ verifies M σ u ψ
  | ConstitutiveFormula.ident φ ψ =>
    -- Identity: s verifies φ ≡ ψ iff s = null and the verifier sets
    -- and falsifier sets of φ and ψ are equal
    s = M.frame.null ∧
    (∀ t, verifies M σ t φ ↔ verifies M σ t ψ) ∧
    (∀ t, falsifies M σ t φ ↔ falsifies M σ t ψ)
  | ConstitutiveFormula.lambdaApp x φ t =>
    -- Lambda application: s verifies (λx.φ)(t) iff s verifies φ[⟦t⟧/x]
    verifies M (σ.update x (evalTerm M σ t)) s φ

/--
Falsification relation: M, σ, s ⊩⁻ φ

A state s falsifies formula φ relative to constitutive model M and
variable assignment σ.
-/
def falsifies (M : ConstitutiveModel) (σ : VarAssignment M.frame) (s : M.frame.State)
    : ConstitutiveFormula → Prop
  | ConstitutiveFormula.atom p =>
    -- Sentence letter: s falsifies p iff s is in the falsifier set for p
    s ∈ (M.interp.getSentenceLetter p).falsifiers
  | ConstitutiveFormula.pred P ts =>
    -- Predicate: there exists a falsifier function f such that s = f(⟦t₁⟧,...,⟦tₙ⟧)
    let args : Fin ts.length → M.frame.State := fun i => evalTerm M σ (ts.get i)
    ∃ f ∈ (M.interp.predicate P ts.length).falsifierFns,
      s = f (fun i => args (Fin.cast (by rfl) i))
  | ConstitutiveFormula.bot =>
    -- Bottom: only null state falsifies ⊥
    s = M.frame.null
  | ConstitutiveFormula.top =>
    -- Top: only full state falsifies ⊤
    s = M.frame.full
  | ConstitutiveFormula.neg φ =>
    -- Negation: s falsifies ¬φ iff s verifies φ
    verifies M σ s φ
  | ConstitutiveFormula.and φ ψ =>
    -- Conjunction: s falsifies φ ∧ ψ iff s falsifies φ, or s falsifies ψ,
    -- or s = t ⊔ u for some t, u where t falsifies φ and u falsifies ψ
    falsifies M σ s φ ∨ falsifies M σ s ψ ∨
    ∃ t u : M.frame.State, s = M.frame.fusion t u ∧
      falsifies M σ t φ ∧ falsifies M σ u ψ
  | ConstitutiveFormula.or φ ψ =>
    -- Disjunction: s falsifies φ ∨ ψ iff s = t ⊔ u for some t, u
    -- where t falsifies φ and u falsifies ψ
    ∃ t u : M.frame.State, s = M.frame.fusion t u ∧
      falsifies M σ t φ ∧ falsifies M σ u ψ
  | ConstitutiveFormula.ident φ ψ =>
    -- Identity: s falsifies φ ≡ ψ iff s = null and either the verifier sets
    -- or the falsifier sets of φ and ψ differ
    s = M.frame.null ∧
    (¬(∀ t, verifies M σ t φ ↔ verifies M σ t ψ) ∨
     ¬(∀ t, falsifies M σ t φ ↔ falsifies M σ t ψ))
  | ConstitutiveFormula.lambdaApp x φ t =>
    -- Lambda application: s falsifies (λx.φ)(t) iff s falsifies φ[⟦t⟧/x]
    falsifies M (σ.update x (evalTerm M σ t)) s φ
end

section BasicTheorems

variable (M : ConstitutiveModel) (σ : VarAssignment M.frame)

/--
Negation swaps verification and falsification (verification clause).
-/
theorem neg_verifies_iff_falsifies (s : M.frame.State) (φ : ConstitutiveFormula) :
    verifies M σ s (ConstitutiveFormula.neg φ) ↔ falsifies M σ s φ := by
  simp only [verifies]

/--
Negation swaps verification and falsification (falsification clause).
-/
theorem neg_falsifies_iff_verifies (s : M.frame.State) (φ : ConstitutiveFormula) :
    falsifies M σ s (ConstitutiveFormula.neg φ) ↔ verifies M σ s φ := by
  simp only [falsifies]

/--
Double negation: s verifies ¬¬φ iff s verifies φ
-/
theorem double_neg_verifies (s : M.frame.State) (φ : ConstitutiveFormula) :
    verifies M σ s (ConstitutiveFormula.neg (ConstitutiveFormula.neg φ)) ↔ verifies M σ s φ := by
  simp only [verifies, falsifies]

/--
Bottom is never verified.
-/
theorem bot_not_verified (s : M.frame.State) : ¬(verifies M σ s ConstitutiveFormula.bot) := by
  simp only [verifies, not_false_eq_true]

/--
Top is always verified.
-/
theorem top_verified (s : M.frame.State) : verifies M σ s ConstitutiveFormula.top := by
  simp only [verifies]

/--
Only null falsifies bottom.
-/
theorem bot_falsified_iff_null (s : M.frame.State) :
    falsifies M σ s ConstitutiveFormula.bot ↔ s = M.frame.null := by
  simp only [falsifies]

/--
Only full falsifies top.
-/
theorem top_falsified_iff_full (s : M.frame.State) :
    falsifies M σ s ConstitutiveFormula.top ↔ s = M.frame.full := by
  simp only [falsifies]

end BasicTheorems

/--
Extract the bilateral proposition content of a formula.

Given a formula φ, model M, and assignment σ, returns the bilateral
proposition with verifiers and falsifiers determined by the semantics.
-/
def content (M : ConstitutiveModel) (σ : VarAssignment M.frame)
    (φ : ConstitutiveFormula) : BilateralProp M.frame.State where
  verifiers := { s | verifies M σ s φ }
  falsifiers := { s | falsifies M σ s φ }

-- Note: The theorem ident_verifies_iff_same_content connecting identity verification
-- to bilateral proposition equivalence is deferred to avoid mutual recursion complexity
-- in the current implementation.

end Logos.Foundation
