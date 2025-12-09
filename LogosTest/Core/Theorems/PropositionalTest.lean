import Logos.Core.Theorems.Propositional

/-!
# Propositional Theorems Tests

Tests for propositional logic theorems derived in Hilbert-style proof calculus.

## Test Coverage

### Phase 1: Propositional Foundations
- `lem`: Law of Excluded Middle - `⊢ A ∨ ¬A`
- `ecq`: Ex Contradictione Quodlibet - `[A, ¬A] ⊢ B`
- `raa`: Reductio ad Absurdum - `⊢ A → (¬A → B)`
- `efq`: Ex Falso Quodlibet - `⊢ ¬A → (A → B)`
- `ldi`: Left Disjunction Introduction - `[A] ⊢ A ∨ B`
- `rdi`: Right Disjunction Introduction - `[B] ⊢ A ∨ B`
- `rcp`: Reverse Contraposition - `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)`
- `lce`: Left Conjunction Elimination - `[A ∧ B] ⊢ A`
- `rce`: Right Conjunction Elimination - `[A ∧ B] ⊢ B`

Each theorem has minimum 2 test cases (simple atomic, nested/complex).
-/

namespace LogosTest.Core.Theorems.PropositionalTest

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Theorems.Propositional

/-!
## Law of Excluded Middle Tests
-/

/-- Test LEM type signature: A ∨ ¬A -/
example (A : Formula) : ⊢ A.or A.neg := lem A

/-- Test LEM with atomic formula -/
example : ⊢ (Formula.atom "p").or (Formula.atom "p").neg := lem (Formula.atom "p")

/-- Test LEM with complex formula -/
example : ⊢ ((Formula.atom "p").imp (Formula.atom "q")).or ((Formula.atom "p").imp (Formula.atom "q")).neg :=
  lem ((Formula.atom "p").imp (Formula.atom "q"))

/-!
## Ex Contradictione Quodlibet Tests
-/

/-- Test ECQ type signature: [A, ¬A] ⊢ B -/
example (A B : Formula) : [A, A.neg] ⊢ B := ecq A B

/-- Test ECQ with atomic formulas -/
example : [Formula.atom "p", (Formula.atom "p").neg] ⊢ Formula.atom "q" :=
  ecq (Formula.atom "p") (Formula.atom "q")

/-- Test ECQ deriving complex formula from contradiction -/
example : [Formula.atom "p", (Formula.atom "p").neg] ⊢ (Formula.atom "q").imp (Formula.atom "r") :=
  ecq (Formula.atom "p") ((Formula.atom "q").imp (Formula.atom "r"))

/-!
## Reductio ad Absurdum Tests
-/

/-- Test RAA type signature: A → (¬A → B) -/
example (A B : Formula) : ⊢ A.imp (A.neg.imp B) := raa A B

/-- Test RAA with atomic formulas -/
example : ⊢ (Formula.atom "p").imp ((Formula.atom "p").neg.imp (Formula.atom "q")) :=
  raa (Formula.atom "p") (Formula.atom "q")

/-- Test RAA with nested formula -/
example : ⊢ ((Formula.atom "p").box).imp (((Formula.atom "p").box).neg.imp (Formula.atom "q")) :=
  raa (Formula.atom "p").box (Formula.atom "q")

/-!
## Ex Falso Quodlibet Tests
-/

/-- Test EFQ type signature: ¬A → (A → B) -/
example (A B : Formula) : ⊢ A.neg.imp (A.imp B) := efq A B

/-- Test EFQ with atomic formulas -/
example : ⊢ (Formula.atom "p").neg.imp ((Formula.atom "p").imp (Formula.atom "q")) :=
  efq (Formula.atom "p") (Formula.atom "q")

/-- Test EFQ with complex formula -/
example : ⊢ ((Formula.atom "p").diamond).neg.imp (((Formula.atom "p").diamond).imp (Formula.atom "q")) :=
  efq (Formula.atom "p").diamond (Formula.atom "q")

/-!
## Left Disjunction Introduction Tests
-/

/-- Test LDI type signature: [A] ⊢ A ∨ B -/
example (A B : Formula) : [A] ⊢ A.or B := ldi A B

/-- Test LDI with atomic formulas -/
example : [Formula.atom "p"] ⊢ (Formula.atom "p").or (Formula.atom "q") :=
  ldi (Formula.atom "p") (Formula.atom "q")

/-- Test LDI with nested formula -/
example : [(Formula.atom "p").imp (Formula.atom "q")] ⊢
          ((Formula.atom "p").imp (Formula.atom "q")).or (Formula.atom "r") :=
  ldi ((Formula.atom "p").imp (Formula.atom "q")) (Formula.atom "r")

/-!
## Right Disjunction Introduction Tests
-/

/-- Test RDI type signature: [B] ⊢ A ∨ B -/
example (A B : Formula) : [B] ⊢ A.or B := rdi A B

/-- Test RDI with atomic formulas -/
example : [Formula.atom "q"] ⊢ (Formula.atom "p").or (Formula.atom "q") :=
  rdi (Formula.atom "p") (Formula.atom "q")

/-- Test RDI with nested formula -/
example : [(Formula.atom "r").box] ⊢
          (Formula.atom "p").or ((Formula.atom "r").box) :=
  rdi (Formula.atom "p") ((Formula.atom "r").box)

/-!
## Reverse Contraposition Tests
-/

/-- Test RCP type signature: (Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A) -/
example (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A := rcp A B h

/-- Test RCP with empty context and atomic formulas -/
example (A B : Formula) (h : ⊢ A.neg.imp B.neg) : ⊢ B.imp A := rcp A B h

/-- Test RCP with concrete formulas -/
example (h : ⊢ (Formula.atom "p").neg.imp (Formula.atom "q").neg) :
        ⊢ (Formula.atom "q").imp (Formula.atom "p") :=
  rcp (Formula.atom "p") (Formula.atom "q") h

/-- Test RCP with complex formulas -/
example (h : ⊢ ((Formula.atom "p").box).neg.imp ((Formula.atom "q").diamond).neg) :
        ⊢ ((Formula.atom "q").diamond).imp ((Formula.atom "p").box) :=
  rcp ((Formula.atom "p").box) ((Formula.atom "q").diamond) h

/-!
## Left Conjunction Elimination Tests
-/

/-- Test LCE type signature: [A ∧ B] ⊢ A -/
example (A B : Formula) : [A.and B] ⊢ A := lce A B

/-- Test LCE with atomic formulas -/
example : [(Formula.atom "p").and (Formula.atom "q")] ⊢ Formula.atom "p" :=
  lce (Formula.atom "p") (Formula.atom "q")

/-- Test LCE with nested formula -/
example : [((Formula.atom "p").imp (Formula.atom "q")).and (Formula.atom "r")] ⊢
          (Formula.atom "p").imp (Formula.atom "q") :=
  lce ((Formula.atom "p").imp (Formula.atom "q")) (Formula.atom "r")

/-!
## Right Conjunction Elimination Tests
-/

/-- Test RCE type signature: [A ∧ B] ⊢ B -/
example (A B : Formula) : [A.and B] ⊢ B := rce A B

/-- Test RCE with atomic formulas -/
example : [(Formula.atom "p").and (Formula.atom "q")] ⊢ Formula.atom "q" :=
  rce (Formula.atom "p") (Formula.atom "q")

/-- Test RCE with nested formula -/
example : [(Formula.atom "p").and ((Formula.atom "q").box)] ⊢ (Formula.atom "q").box :=
  rce (Formula.atom "p") ((Formula.atom "q").box)

/-!
## Integration Tests: Combining Multiple Theorems
-/

/-- Test: RAA and EFQ are duals (via theorem_flip) -/
example (A B : Formula) : ⊢ A.imp (A.neg.imp B) := raa A B
example (A B : Formula) : ⊢ A.neg.imp (A.imp B) := efq A B

/-- Test: Conjunction elimination combined with disjunction introduction -/
example : [(Formula.atom "p").and (Formula.atom "q")] ⊢
          (Formula.atom "p").or (Formula.atom "r") := by
  have h_p := lce (Formula.atom "p") (Formula.atom "q")
  -- Now h_p : [p ∧ q] ⊢ p
  -- We need to derive: [p ∧ q] ⊢ p ∨ r
  -- Use weakening to add context, then apply ldi
  -- Actually, ldi requires [p] ⊢ p ∨ r, so we need to show [p ∧ q] ⊢ p ∨ r
  -- This requires additional context manipulation
  sorry  -- This test requires deduction theorem infrastructure

/-- Test: LEM is theorem (not axiom) -/
example (φ : Formula) : ⊢ φ.or φ.neg := lem φ

end LogosTest.Core.Theorems.PropositionalTest
