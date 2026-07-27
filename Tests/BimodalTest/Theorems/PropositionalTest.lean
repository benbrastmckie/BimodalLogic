/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.Propositional.Core

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

namespace BimodalTest.Theorems.PropositionalTest

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Propositional

/-!
## Law of Excluded Middle Tests
-/

/-- Test LEM type signature: A ∨ ¬A -/
example (A : Formula) : ⊢ A.or A.neg := em A

/-- Test LEM with atomic formula -/
example : ⊢ (Formula.atomS "p").or (Formula.atomS "p").neg := em (Formula.atomS "p")

/-- Test LEM with complex formula -/
example : ⊢ ((Formula.atomS "p").imp (Formula.atomS "q")).or ((Formula.atomS "p").imp (Formula.atomS "q")).neg :=
  em ((Formula.atomS "p").imp (Formula.atomS "q"))

/-!
## Ex Contradictione Quodlibet Tests
-/

/-- Test ECQ type signature: [A, ¬A] ⊢ B -/
example (A B : Formula) : [A, A.neg] ⊢ B := botOfAndNeg A B

/-- Test ECQ with atomic formulas -/
example : [Formula.atomS "p", (Formula.atomS "p").neg] ⊢ Formula.atomS "q" :=
  botOfAndNeg (Formula.atomS "p") (Formula.atomS "q")

/-- Test ECQ deriving complex formula from contradiction -/
example : [Formula.atomS "p", (Formula.atomS "p").neg] ⊢ (Formula.atomS "q").imp (Formula.atomS "r") :=
  botOfAndNeg (Formula.atomS "p") ((Formula.atomS "q").imp (Formula.atomS "r"))

/-!
## Reductio ad Absurdum Tests
-/

/-- Test RAA type signature: A → (¬A → B) -/
example (A B : Formula) : ⊢ A.imp (A.neg.imp B) := impNegImp A B

/-- Test RAA with atomic formulas -/
example : ⊢ (Formula.atomS "p").imp ((Formula.atomS "p").neg.imp (Formula.atomS "q")) :=
  impNegImp (Formula.atomS "p") (Formula.atomS "q")

/-- Test RAA with nested formula -/
example : ⊢ ((Formula.atomS "p").box).imp (((Formula.atomS "p").box).neg.imp (Formula.atomS "q")) :=
  impNegImp (Formula.atomS "p").box (Formula.atomS "q")

/-!
## Ex Falso Quodlibet Tests
-/

/-- Test EFQ type signature: ¬A → (A → B) -/
example (A B : Formula) : ⊢ A.neg.imp (A.imp B) := negImp A B

/-- Test EFQ with atomic formulas -/
example : ⊢ (Formula.atomS "p").neg.imp ((Formula.atomS "p").imp (Formula.atomS "q")) :=
  negImp (Formula.atomS "p") (Formula.atomS "q")

/-- Test EFQ with complex formula -/
example : ⊢ ((Formula.atomS "p").diamond).neg.imp (((Formula.atomS "p").diamond).imp (Formula.atomS "q")) :=
  negImp (Formula.atomS "p").diamond (Formula.atomS "q")

/-!
## Left Disjunction Introduction Tests
-/

/-- Test LDI type signature: [A] ⊢ A ∨ B -/
example (A B : Formula) : [A] ⊢ A.or B := orInl A B

/-- Test LDI with atomic formulas -/
example : [Formula.atomS "p"] ⊢ (Formula.atomS "p").or (Formula.atomS "q") :=
  orInl (Formula.atomS "p") (Formula.atomS "q")

/-- Test LDI with nested formula -/
example : [(Formula.atomS "p").imp (Formula.atomS "q")] ⊢
          ((Formula.atomS "p").imp (Formula.atomS "q")).or (Formula.atomS "r") :=
  orInl ((Formula.atomS "p").imp (Formula.atomS "q")) (Formula.atomS "r")

/-!
## Right Disjunction Introduction Tests
-/

/-- Test RDI type signature: [B] ⊢ A ∨ B -/
example (A B : Formula) : [B] ⊢ A.or B := orInr A B

/-- Test RDI with atomic formulas -/
example : [Formula.atomS "q"] ⊢ (Formula.atomS "p").or (Formula.atomS "q") :=
  orInr (Formula.atomS "p") (Formula.atomS "q")

/-- Test RDI with nested formula -/
example : [(Formula.atomS "r").box] ⊢
          (Formula.atomS "p").or ((Formula.atomS "r").box) :=
  orInr (Formula.atomS "p") ((Formula.atomS "r").box)

/-!
## Reverse Contraposition Tests
-/

/-- Test RCP type signature: (Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A) -/
example (Γ : Context) (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A := impOfNegImpNeg Γ A B h

/-- Test RCP with empty context and atomic formulas -/
example (A B : Formula) (h : ⊢ A.neg.imp B.neg) : ⊢ B.imp A := impOfNegImpNeg [] A B h

/-- Test RCP with concrete formulas -/
example (h : ⊢ (Formula.atomS "p").neg.imp (Formula.atomS "q").neg) :
        ⊢ (Formula.atomS "q").imp (Formula.atomS "p") :=
  impOfNegImpNeg [] (Formula.atomS "p") (Formula.atomS "q") h

/-- Test RCP with complex formulas -/
example (h : ⊢ ((Formula.atomS "p").box).neg.imp ((Formula.atomS "q").diamond).neg) :
        ⊢ ((Formula.atomS "q").diamond).imp ((Formula.atomS "p").box) :=
  impOfNegImpNeg [] ((Formula.atomS "p").box) ((Formula.atomS "q").diamond) h

/-!
## Left Conjunction Elimination Tests
-/

/-- Test LCE type signature: [A ∧ B] ⊢ A -/
example (A B : Formula) : [A.and B] ⊢ A := andLeft A B

/-- Test LCE with atomic formulas -/
example : [(Formula.atomS "p").and (Formula.atomS "q")] ⊢ Formula.atomS "p" :=
  andLeft (Formula.atomS "p") (Formula.atomS "q")

/-- Test LCE with nested formula -/
example : [((Formula.atomS "p").imp (Formula.atomS "q")).and (Formula.atomS "r")] ⊢
          (Formula.atomS "p").imp (Formula.atomS "q") :=
  andLeft ((Formula.atomS "p").imp (Formula.atomS "q")) (Formula.atomS "r")

/-!
## Right Conjunction Elimination Tests
-/

/-- Test RCE type signature: [A ∧ B] ⊢ B -/
example (A B : Formula) : [A.and B] ⊢ B := andRight A B

/-- Test RCE with atomic formulas -/
example : [(Formula.atomS "p").and (Formula.atomS "q")] ⊢ Formula.atomS "q" :=
  andRight (Formula.atomS "p") (Formula.atomS "q")

/-- Test RCE with nested formula -/
example : [(Formula.atomS "p").and ((Formula.atomS "q").box)] ⊢ (Formula.atomS "q").box :=
  andRight (Formula.atomS "p") ((Formula.atomS "q").box)

/-!
## Integration Tests: Combining Multiple Theorems
-/

/-- Test: RAA and EFQ are duals (via theorem_flip) -/
example (A B : Formula) : ⊢ A.imp (A.neg.imp B) := impNegImp A B
example (A B : Formula) : ⊢ A.neg.imp (A.imp B) := negImp A B

/--
Test: Conjunction elimination combined with disjunction introduction.

Demonstrates composing context-based derivations using the deduction theorem.
Strategy: Use deduction theorem to lift ldi to an implication, then apply modus ponens.
-/
noncomputable example : [(Formula.atomS "p").and (Formula.atomS "q")] ⊢
          (Formula.atomS "p").or (Formula.atomS "r") := by
  -- Step 1: Get [p ∧ q] ⊢ p from lce
  have h_p : [(Formula.atomS "p").and (Formula.atomS "q")] ⊢ (Formula.atomS "p") :=
    andLeft (Formula.atomS "p") (Formula.atomS "q")

  -- Step 2: Get [p] ⊢ p ∨ r from ldi
  have h_ldi : [Formula.atomS "p"] ⊢ (Formula.atomS "p").or (Formula.atomS "r") :=
    orInl (Formula.atomS "p") (Formula.atomS "r")

  -- Step 3: Apply deduction theorem: [p] ⊢ p ∨ r implies ⊢ p → (p ∨ r)
  have h_imp : [] ⊢ (Formula.atomS "p").imp ((Formula.atomS "p").or (Formula.atomS "r")) :=
    FormalSystem.Metalogic.Core.deductionTheorem [] (Formula.atomS "p")
      ((Formula.atomS "p").or (Formula.atomS "r")) h_ldi

  -- Step 4: Weaken to the context [p ∧ q]
  have h_imp_ctx : [(Formula.atomS "p").and (Formula.atomS "q")] ⊢
      (Formula.atomS "p").imp ((Formula.atomS "p").or (Formula.atomS "r")) :=
    DerivationTree.weakening [] [(Formula.atomS "p").and (Formula.atomS "q")]
      ((Formula.atomS "p").imp ((Formula.atomS "p").or (Formula.atomS "r")))
      h_imp (List.nil_subset _)

  -- Step 5: Apply modus ponens: [p ∧ q] ⊢ p and [p ∧ q] ⊢ p → (p ∨ r) gives [p ∧ q] ⊢ p ∨ r
  exact DerivationTree.modus_ponens
    [(Formula.atomS "p").and (Formula.atomS "q")]
    (Formula.atomS "p")
    ((Formula.atomS "p").or (Formula.atomS "r"))
    h_imp_ctx h_p

/-- Test: LEM is theorem (not axiom) -/
example (φ : Formula) : ⊢ φ.or φ.neg := em φ

end BimodalTest.Theorems.PropositionalTest
