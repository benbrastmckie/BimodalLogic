/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.PlusRules
import FormalSystem.Theorems.ModalS5

/-!
# Small closed simplification guarantees

Boolean seeds reconstruct source-calculus proofs. Modal seeds reuse the existing checked TM
schemata at arbitrary TM⁺ arguments. They are ordinary reusable guarantees, not a proof-search
procedure or special cases in the rewriter.
-/

namespace FormalSystem.Theorems.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Theorems.Combinators

variable {fc : FrameClass}

/-- Double negation is a closed equivalence, with its reducing orientation first. -/
def doubleNegationIff (A : Formula) :
    ⊢[fc] (A.neg.neg.imp A).and (A.imp A.neg.neg) :=
  andIntro (Propositional.doubleNegation A) (notNotIntro A)

/-- Repeated conjunction is equivalent to its single opaque assertion. -/
def conjunctionSelfIff (A : Formula) : ⊢[fc] ((A.and A).imp A).and (A.imp (A.and A)) :=
  andIntro (Propositional.lceImp A A)
    (FormalSystem.Metalogic.Core.deductionTheorem [] A (A.and A)
      (andIntro (.assumption _ _ (by simp)) (.assumption _ _ (by simp))))

end FormalSystem.Theorems.ProofMode

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem

variable {fc : FrameClass}

private def atom (n : Nat) : Formula := .atom (Atom.mkFresh "" n)

private def assign (A B : PlusFormula) (p : Atom) : PlusFormula :=
  if p.freshIndex == some 0 then A else B

/-- Double-negation reduction transferred at an arbitrary Plus assertion. -/
def doubleNegationIff (A : PlusFormula) : PlusDerivationTree fc [] (A.neg.neg.iff A) :=
  .ofTMSubst (fun _ => A) (FormalSystem.Theorems.ProofMode.doubleNegationIff (atom 0))

/-- Conjunction idempotence transferred without restricting the argument to embedded TM. -/
def conjunctionSelfIff (A : PlusFormula) : PlusDerivationTree fc [] ((A.and A).iff A) :=
  .ofTMSubst (fun _ => A) (FormalSystem.Theorems.ProofMode.conjunctionSelfIff (atom 0))

/-- Box distributes over conjunction at arbitrary Plus arguments. -/
def boxConjIff (A B : PlusFormula) :
    PlusDerivationTree fc [] ((A.and B).box.iff (A.box.and B.box)) :=
  .ofTMSubst (assign A B) (FormalSystem.Theorems.ModalS5.boxConjIff (atom 0) (atom 1))

/-- Possibility distributes over disjunction at arbitrary Plus arguments. -/
def diamondDisjIff (A B : PlusFormula) :
    PlusDerivationTree fc [] ((A.or B).diamond.iff (A.diamond.or B.diamond)) :=
  .ofTMSubst (assign A B) (FormalSystem.Theorems.ModalS5.diamondDisjIff (atom 0) (atom 1))

/-- A possible necessary assertion is necessary, by the source S5 equivalence. -/
def s5DiamondBox (A : PlusFormula) : PlusDerivationTree fc [] (A.box.diamond.iff A.box) :=
  .ofTMSubst (fun _ => A) (FormalSystem.Theorems.ModalS5.s5DiamondBox (atom 0))

end FormalSystem.PlusLanguage.ProofMode
