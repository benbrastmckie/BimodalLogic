/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.PlusRules
import FormalSystem.Theorems.ProofMode.Possibility

/-!
# Native TM⁺ possibility rules

Possibility introduction and consequence transfer the checked TM derivations at arbitrary
TM⁺ formulas. Context substitution supplies the caller's opaque premise derivations.
-/

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass DerivationTree)

variable {fc : FrameClass} {Γ : PlusContext}

private def atom (n : Nat) : Formula := .atom (Atom.mkFresh "" n)

private def assign (A B : PlusFormula) (p : Atom) : PlusFormula :=
  if p.freshIndex == some 0 then A else B

/-- Any current assertion is possible, by the source calculus's modal T rule. -/
def diamondIntro {A : PlusFormula} (hA : PlusDerivationTree fc Γ A) :
    PlusDerivationTree fc Γ A.diamond :=
  substContext (.ofTMSubst (fun _ => A)
    (FormalSystem.Theorems.ProofMode.diamondIntro (.assumption [atom 0] (atom 0) (by simp))))
      (consContextProofs hA (nilContextProofs Γ))

/-- Map a possibility with a necessary implication, retaining its modal scope. -/
def diamondConsequence {A B : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (A.imp B).box)
    (hA : PlusDerivationTree fc Γ A.diamond) : PlusDerivationTree fc Γ B.diamond :=
  substContext (.ofTMSubst (assign A B)
    (FormalSystem.Theorems.ProofMode.diamondConsequence
      (Γ := [((atom 0).imp (atom 1)).box, (atom 0).diamond])
      (A := atom 0) (B := atom 1)
      (.assumption _ _ (by simp)) (.assumption _ _ (by simp))))
      (consContextProofs hMap (consContextProofs hA (nilContextProofs Γ)))

/-- Any current assertion is possible through the present state, by stability T. -/
def settledPossibilityIntro {A : PlusFormula} (hA : PlusDerivationTree fc Γ A) :
    PlusDerivationTree fc Γ A.dstab := by
  refine deductionTheorem Γ (PlusFormula.stab A.neg) .bot ?_
  have hA' := weaken hA (List.subset_cons_self (PlusFormula.stab A.neg) Γ)
  have hNegA : PlusDerivationTree fc (PlusFormula.stab A.neg :: Γ) A.neg :=
    ctxMp (.axiom _ _ (.stab_t A.neg) (FrameClass.base_le fc))
      (.assumption _ _ (by simp))
  exact ctxMp hNegA hA'

/-- Map a same-state possibility using an implication settled at that state. -/
def settledPossibilityConsequence {A B : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (PlusFormula.stab (A.imp B)))
    (hA : PlusDerivationTree fc Γ A.dstab) : PlusDerivationTree fc Γ B.dstab := by
  have hContra : PlusDerivationTree fc [] ((A.imp B).imp (B.neg.imp A.neg)) :=
    .ofTMSubst (assign A B)
      (FormalSystem.Theorems.Propositional.contraposeImp (atom 0) (atom 1))
  have hSettledContra : PlusDerivationTree fc Γ
      (PlusFormula.stab (B.neg.imp A.neg)) :=
    ctxMp (ctxMp (.axiom Γ _ (.stab_k (A.imp B) (B.neg.imp A.neg))
      (FrameClass.base_le fc)) (thmIn (stabNecessitation hContra))) hMap
  refine deductionTheorem Γ (PlusFormula.stab B.neg) .bot ?_
  have hNegA : PlusDerivationTree fc (PlusFormula.stab B.neg :: Γ)
      (PlusFormula.stab A.neg) :=
    ctxMp (ctxMp (.axiom _ _ (.stab_k B.neg A.neg) (FrameClass.base_le fc))
      (weaken hSettledContra (List.subset_cons_self (PlusFormula.stab B.neg) Γ)))
      (.assumption _ _ (by simp))
  exact ctxMp (weaken hA (List.subset_cons_self (PlusFormula.stab B.neg) Γ)) hNegA

end FormalSystem.PlusLanguage.ProofMode
