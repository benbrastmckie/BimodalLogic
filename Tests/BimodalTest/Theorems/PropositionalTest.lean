import Bimodal.Theorems.Propositional

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

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Propositional

/-!
## Law of Excluded Middle Tests
-/

/-- Test LEM type signature: A ∨ ¬A -/
example (A : Formula) : ⊢ A.or A.neg := lem A

/-- Test LEM with atomic formula -/
example : ⊢ (Formula.atom_s "p").or (Formula.atom_s "p").neg := lem (Formula.atom_s "p")

/-- Test LEM with complex formula -/
example : ⊢ ((Formula.atom_s "p").imp (Formula.atom_s "q")).or ((Formula.atom_s "p").imp (Formula.atom_s "q")).neg :=
  lem ((Formula.atom_s "p").imp (Formula.atom_s "q"))

/-!
## Ex Contradictione Quodlibet Tests
-/

/-- Test ECQ type signature: [A, ¬A] ⊢ B -/
example (A B : Formula) : [A, A.neg] ⊢ B := ecq A B

/-- Test ECQ with atomic formulas -/
example : [Formula.atom_s "p", (Formula.atom_s "p").neg] ⊢ Formula.atom_s "q" :=
  ecq (Formula.atom_s "p") (Formula.atom_s "q")

/-- Test ECQ deriving complex formula from contradiction -/
example : [Formula.atom_s "p", (Formula.atom_s "p").neg] ⊢ (Formula.atom_s "q").imp (Formula.atom_s "r") :=
  ecq (Formula.atom_s "p") ((Formula.atom_s "q").imp (Formula.atom_s "r"))

/-!
## Reductio ad Absurdum Tests
-/

/-- Test RAA type signature: A → (¬A → B) -/
example (A B : Formula) : ⊢ A.imp (A.neg.imp B) := raa A B

/-- Test RAA with atomic formulas -/
example : ⊢ (Formula.atom_s "p").imp ((Formula.atom_s "p").neg.imp (Formula.atom_s "q")) :=
  raa (Formula.atom_s "p") (Formula.atom_s "q")

/-- Test RAA with nested formula -/
example : ⊢ ((Formula.atom_s "p").box).imp (((Formula.atom_s "p").box).neg.imp (Formula.atom_s "q")) :=
  raa (Formula.atom_s "p").box (Formula.atom_s "q")

/-!
## Ex Falso Quodlibet Tests
-/

/-- Test EFQ type signature: ¬A → (A → B) -/
example (A B : Formula) : ⊢ A.neg.imp (A.imp B) := efq A B

/-- Test EFQ with atomic formulas -/
example : ⊢ (Formula.atom_s "p").neg.imp ((Formula.atom_s "p").imp (Formula.atom_s "q")) :=
  efq (Formula.atom_s "p") (Formula.atom_s "q")

/-- Test EFQ with complex formula -/
example : ⊢ ((Formula.atom_s "p").diamond).neg.imp (((Formula.atom_s "p").diamond).imp (Formula.atom_s "q")) :=
  efq (Formula.atom_s "p").diamond (Formula.atom_s "q")

/-!
## Left Disjunction Introduction Tests
-/

/-- Test LDI type signature: [A] ⊢ A ∨ B -/
example (A B : Formula) : [A] ⊢ A.or B := ldi A B

/-- Test LDI with atomic formulas -/
example : [Formula.atom_s "p"] ⊢ (Formula.atom_s "p").or (Formula.atom_s "q") :=
  ldi (Formula.atom_s "p") (Formula.atom_s "q")

/-- Test LDI with nested formula -/
example : [(Formula.atom_s "p").imp (Formula.atom_s "q")] ⊢
          ((Formula.atom_s "p").imp (Formula.atom_s "q")).or (Formula.atom_s "r") :=
  ldi ((Formula.atom_s "p").imp (Formula.atom_s "q")) (Formula.atom_s "r")

/-!
## Right Disjunction Introduction Tests
-/

/-- Test RDI type signature: [B] ⊢ A ∨ B -/
example (A B : Formula) : [B] ⊢ A.or B := rdi A B

/-- Test RDI with atomic formulas -/
example : [Formula.atom_s "q"] ⊢ (Formula.atom_s "p").or (Formula.atom_s "q") :=
  rdi (Formula.atom_s "p") (Formula.atom_s "q")

/-- Test RDI with nested formula -/
example : [(Formula.atom_s "r").box] ⊢
          (Formula.atom_s "p").or ((Formula.atom_s "r").box) :=
  rdi (Formula.atom_s "p") ((Formula.atom_s "r").box)

/-!
## Reverse Contraposition Tests
-/

/-- Test RCP type signature: (Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A) -/
example (Γ : Context) (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A := rcp Γ A B h

/-- Test RCP with empty context and atomic formulas -/
example (A B : Formula) (h : ⊢ A.neg.imp B.neg) : ⊢ B.imp A := rcp [] A B h

/-- Test RCP with concrete formulas -/
example (h : ⊢ (Formula.atom_s "p").neg.imp (Formula.atom_s "q").neg) :
        ⊢ (Formula.atom_s "q").imp (Formula.atom_s "p") :=
  rcp [] (Formula.atom_s "p") (Formula.atom_s "q") h

/-- Test RCP with complex formulas -/
example (h : ⊢ ((Formula.atom_s "p").box).neg.imp ((Formula.atom_s "q").diamond).neg) :
        ⊢ ((Formula.atom_s "q").diamond).imp ((Formula.atom_s "p").box) :=
  rcp [] ((Formula.atom_s "p").box) ((Formula.atom_s "q").diamond) h

/-!
## Left Conjunction Elimination Tests
-/

/-- Test LCE type signature: [A ∧ B] ⊢ A -/
example (A B : Formula) : [A.and B] ⊢ A := lce A B

/-- Test LCE with atomic formulas -/
example : [(Formula.atom_s "p").and (Formula.atom_s "q")] ⊢ Formula.atom_s "p" :=
  lce (Formula.atom_s "p") (Formula.atom_s "q")

/-- Test LCE with nested formula -/
example : [((Formula.atom_s "p").imp (Formula.atom_s "q")).and (Formula.atom_s "r")] ⊢
          (Formula.atom_s "p").imp (Formula.atom_s "q") :=
  lce ((Formula.atom_s "p").imp (Formula.atom_s "q")) (Formula.atom_s "r")

/-!
## Right Conjunction Elimination Tests
-/

/-- Test RCE type signature: [A ∧ B] ⊢ B -/
example (A B : Formula) : [A.and B] ⊢ B := rce A B

/-- Test RCE with atomic formulas -/
example : [(Formula.atom_s "p").and (Formula.atom_s "q")] ⊢ Formula.atom_s "q" :=
  rce (Formula.atom_s "p") (Formula.atom_s "q")

/-- Test RCE with nested formula -/
example : [(Formula.atom_s "p").and ((Formula.atom_s "q").box)] ⊢ (Formula.atom_s "q").box :=
  rce (Formula.atom_s "p") ((Formula.atom_s "q").box)

/-!
## Integration Tests: Combining Multiple Theorems
-/

/-- Test: RAA and EFQ are duals (via theorem_flip) -/
example (A B : Formula) : ⊢ A.imp (A.neg.imp B) := raa A B
example (A B : Formula) : ⊢ A.neg.imp (A.imp B) := efq A B

/--
Test: Conjunction elimination combined with disjunction introduction.

Demonstrates composing context-based derivations using the deduction theorem.
Strategy: Use deduction theorem to lift ldi to an implication, then apply modus ponens.
-/
noncomputable example : [(Formula.atom_s "p").and (Formula.atom_s "q")] ⊢
          (Formula.atom_s "p").or (Formula.atom_s "r") := by
  -- Step 1: Get [p ∧ q] ⊢ p from lce
  have h_p : [(Formula.atom_s "p").and (Formula.atom_s "q")] ⊢ (Formula.atom_s "p") :=
    lce (Formula.atom_s "p") (Formula.atom_s "q")

  -- Step 2: Get [p] ⊢ p ∨ r from ldi
  have h_ldi : [Formula.atom_s "p"] ⊢ (Formula.atom_s "p").or (Formula.atom_s "r") :=
    ldi (Formula.atom_s "p") (Formula.atom_s "r")

  -- Step 3: Apply deduction theorem: [p] ⊢ p ∨ r implies ⊢ p → (p ∨ r)
  have h_imp : [] ⊢ (Formula.atom_s "p").imp ((Formula.atom_s "p").or (Formula.atom_s "r")) :=
    Bimodal.Metalogic.deduction_theorem [] (Formula.atom_s "p")
      ((Formula.atom_s "p").or (Formula.atom_s "r")) h_ldi

  -- Step 4: Weaken to the context [p ∧ q]
  have h_imp_ctx : [(Formula.atom_s "p").and (Formula.atom_s "q")] ⊢
      (Formula.atom_s "p").imp ((Formula.atom_s "p").or (Formula.atom_s "r")) :=
    DerivationTree.weakening [] [(Formula.atom_s "p").and (Formula.atom_s "q")]
      ((Formula.atom_s "p").imp ((Formula.atom_s "p").or (Formula.atom_s "r")))
      h_imp (List.nil_subset _)

  -- Step 5: Apply modus ponens: [p ∧ q] ⊢ p and [p ∧ q] ⊢ p → (p ∨ r) gives [p ∧ q] ⊢ p ∨ r
  exact DerivationTree.modus_ponens
    [(Formula.atom_s "p").and (Formula.atom_s "q")]
    (Formula.atom_s "p")
    ((Formula.atom_s "p").or (Formula.atom_s "r"))
    h_imp_ctx h_p

/-- Test: LEM is theorem (not axiom) -/
example (φ : Formula) : ⊢ φ.or φ.neg := lem φ

end BimodalTest.Theorems.PropositionalTest
