import Mathlib.Tactic

/-!
# Constitutive Formula Syntax

This module defines the formula syntax for the Constitutive Foundation layer.
These formulas are evaluated hyperintensionally using verification and
falsification relations.

## Paper Specification Reference

**Constitutive Syntax (RECURSIVE_SEMANTICS.md)**:
- Sentence letters: p, q, r, ...
- Logical connectives: ¬, ∧, ∨, ⊤, ⊥, ≡

## Main Definitions

- `Term`: Object-level terms (variables, constants, function applications)
- `ConstitutiveFormula`: Formulas with propositional and identity operators
- Derived relations: essence (⊑), ground (≤)

## Implementation Notes

Terms and formulas are parametric over the type of variable/constant/predicate
names for flexibility. The standard instantiation uses String.
-/

namespace Logos.SubTheories.Foundation

/--
Object-level terms in the constitutive language.

Terms denote states in the state space. They include:
- Variables (bound by quantifiers/lambda)
- Individual constants (0-ary function symbols)
- Function applications (n-ary function symbols applied to n terms)
-/
inductive Term where
  /-- Variable reference -/
  | var : String → Term
  /-- Individual constant (0-ary function symbol) -/
  | const : String → Term
  /-- Function application: f(t₁, ..., tₙ) -/
  | app : String → List Term → Term
  deriving Repr

namespace Term

/--
Get all free variables in a term.
-/
partial def freeVars : Term → List String
  | var x => [x]
  | const _ => []
  | app _ ts => ts.flatMap fun t => t.freeVars

/--
Substitute a term for a variable.
-/
partial def subst (t : Term) (x : String) (s : Term) : Term :=
  match t with
  | var y => if y = x then s else var y
  | const c => const c
  | app f ts => app f (ts.map fun t' => t'.subst x s)

end Term

/--
Constitutive formula syntax.

Formulas in the Constitutive Foundation layer. These are evaluated
hyperintensionally using verification and falsification clauses.
-/
inductive ConstitutiveFormula where
  /-- Sentence letter (propositional atom) -/
  | atom : String → ConstitutiveFormula
  /-- Atomic predicate application: F(t₁, ..., tₙ) -/
  | pred : String → List Term → ConstitutiveFormula
  /-- Bottom (⊥, falsum) -/
  | bot : ConstitutiveFormula
  /-- Top (⊤, verum) -/
  | top : ConstitutiveFormula
  /-- Negation: ¬A -/
  | neg : ConstitutiveFormula → ConstitutiveFormula
  /-- Conjunction: A ∧ B -/
  | and : ConstitutiveFormula → ConstitutiveFormula → ConstitutiveFormula
  /-- Disjunction: A ∨ B -/
  | or : ConstitutiveFormula → ConstitutiveFormula → ConstitutiveFormula
  /-- Propositional identity: A ≡ B -/
  | ident : ConstitutiveFormula → ConstitutiveFormula → ConstitutiveFormula
  /-- Lambda abstraction applied to term: (λx.A)(t) -/
  | lambdaApp : String → ConstitutiveFormula → Term → ConstitutiveFormula
  deriving Repr

namespace ConstitutiveFormula

/--
Implication as derived connective: A → B := ¬A ∨ B
-/
def imp (φ ψ : ConstitutiveFormula) : ConstitutiveFormula :=
  .or (.neg φ) ψ

/--
Biconditional as derived connective: A ↔ B := (A → B) ∧ (B → A)
-/
def iff (φ ψ : ConstitutiveFormula) : ConstitutiveFormula :=
  .and (imp φ ψ) (imp ψ φ)

/--
Essence relation as derived: A ⊑ B := A ∧ B ≡ B
"A is essential to B" - A is a conjunctive part of B
-/
def essence (φ ψ : ConstitutiveFormula) : ConstitutiveFormula :=
  .ident (.and φ ψ) ψ

/--
Ground relation as derived: A ≤ B := A ∨ B ≡ B
"A grounds B" - A is a disjunctive part of B
-/
def ground (φ ψ : ConstitutiveFormula) : ConstitutiveFormula :=
  .ident (.or φ ψ) ψ

/--
Structural complexity of a formula.
-/
def complexity : ConstitutiveFormula → Nat
  | atom _ => 1
  | pred _ _ => 1
  | bot => 1
  | top => 1
  | neg φ => 1 + φ.complexity
  | and φ ψ => 1 + φ.complexity + ψ.complexity
  | or φ ψ => 1 + φ.complexity + ψ.complexity
  | ident φ ψ => 1 + φ.complexity + ψ.complexity
  | lambdaApp _ φ _ => 1 + φ.complexity

/--
Get all sentence letters (propositional atoms) in a formula.
-/
def atoms : ConstitutiveFormula → List String
  | atom p => [p]
  | pred _ _ => []
  | bot => []
  | top => []
  | neg φ => φ.atoms
  | and φ ψ => φ.atoms ++ ψ.atoms
  | or φ ψ => φ.atoms ++ ψ.atoms
  | ident φ ψ => φ.atoms ++ ψ.atoms
  | lambdaApp _ φ _ => φ.atoms

/--
Check if formula is atomic (a sentence letter or predicate).
-/
def isAtomic : ConstitutiveFormula → Bool
  | atom _ => true
  | pred _ _ => true
  | _ => false

/--
Check if formula is a literal (atom or negated atom).
-/
def isLiteral : ConstitutiveFormula → Bool
  | atom _ => true
  | pred _ _ => true
  | neg (atom _) => true
  | neg (pred _ _) => true
  | _ => false

section Notation

/-- Notation for negation -/
prefix:80 "~" => ConstitutiveFormula.neg

/-- Notation for conjunction -/
infixl:65 " ⋀ " => ConstitutiveFormula.and

/-- Notation for disjunction -/
infixl:60 " ⋁ " => ConstitutiveFormula.or

/-- Notation for propositional identity -/
infixl:50 " ≣ " => ConstitutiveFormula.ident

/-- Notation for essence relation -/
infixl:50 " ⊑ " => ConstitutiveFormula.essence

/-- Notation for ground relation -/
infixl:50 " ≤ᵍ " => ConstitutiveFormula.ground

end Notation

end ConstitutiveFormula

end Logos.SubTheories.Foundation
