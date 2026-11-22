/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.Congruence.Basic
import FormalSystem.Theorems.ProofMode.PlusRules

/-! # Boolean congruence and the TM and TM⁺ implication kits -/

namespace FormalSystem.Theorems.ProofMode.Congruence

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage

section TM

variable (fc : FrameClass)

/-- Closed TM implication kit at frame class `fc`. -/
def tmKit : Kit Formula (DerivationTree fc []) where
  imp := Formula.imp
  refl A := Combinators.identity A
  trans h₁ h₂ := Combinators.impTrans h₁ h₂

variable {fc}

/-- `⊢ (A → B) → ((B → C) → (A → C))`, the flipped composition combinator. -/
private def tmImpLeftSchema (A B C : Formula) :
    DerivationTree fc [] ((A.imp B).imp ((B.imp C).imp (A.imp C))) :=
  Combinators.mp Combinators.bCombinator Combinators.theoremFlip

/-- Implication antecedent `x ↦ x → C`, antitone with identity demand. -/
def tmImpLeft (C : Formula) : Step (tmKit fc) where
  wrap x := x.imp C
  demand x := x
  flips := true
  transfer A B := tmImpLeftSchema A B C
  demandMono h := h

/-- Implication consequent `x ↦ C → x`, monotone with identity demand. -/
def tmImpRight (C : Formula) : Step (tmKit fc) where
  wrap x := C.imp x
  demand x := x
  flips := false
  transfer _ _ := Combinators.bCombinator
  demandMono h := h

end TM

section TMPlus

variable (fc : FrameClass)

private def plusImpTrans {A B C : PlusFormula}
    (h₁ : PlusDerivationTree fc [] (A.imp B)) (h₂ : PlusDerivationTree fc [] (B.imp C)) :
    PlusDerivationTree fc [] (A.imp C) :=
  .modus_ponens [] _ _
    (.modus_ponens [] _ _ (.axiom [] _ (.prop_k A B C) (FrameClass.base_le fc))
      (.modus_ponens [] _ _ (.axiom [] _ (.prop_s (B.imp C) A) (FrameClass.base_le fc)) h₂))
    h₁

/-- Closed TM⁺ implication kit at frame class `fc`. -/
def plusKit : Kit PlusFormula (PlusDerivationTree fc []) where
  imp := PlusFormula.imp
  refl := PlusLanguage.ProofMode.identity
  trans := plusImpTrans fc

variable {fc}

/-- A fresh TM atom used for substituting a checked schema over TM⁺ formulas. -/
def schemaAtom (n : Nat) : Formula := .atom (Atom.mkFresh "" n)

/-- Supply the TM⁺ arguments for the three fresh atoms of a congruence schema. -/
def assignSchemaAtoms (A B C : PlusFormula) (p : Atom) : PlusFormula :=
  match p.freshIndex with
  | some 0 => A
  | some 1 => B
  | _ => C

/-- Implication antecedent `x ↦ x → C`, antitone, from the transferred TM schema. -/
def plusImpLeft (C : PlusFormula) : Step (plusKit fc) where
  wrap x := x.imp C
  demand x := x
  flips := true
  transfer A B := .ofTMSubst (assignSchemaAtoms A B C)
    (tmImpLeftSchema (schemaAtom 0) (schemaAtom 1) (schemaAtom 2))
  demandMono h := h

/-- Implication consequent `x ↦ C → x`, monotone, from the transferred TM schema. -/
def plusImpRight (C : PlusFormula) : Step (plusKit fc) where
  wrap x := C.imp x
  demand x := x
  flips := false
  transfer A B := .ofTMSubst (assignSchemaAtoms A B C)
    (Combinators.bCombinator (A := schemaAtom 2) (B := schemaAtom 0) (C := schemaAtom 1))
  demandMono h := h

end TMPlus

end FormalSystem.Theorems.ProofMode.Congruence
