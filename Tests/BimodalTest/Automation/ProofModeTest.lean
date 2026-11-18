/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode

/-!
# Native derivation proof-mode acceptance tests

The fixtures exercise opaque lemma application, modal and temporal scopes, and complete
branch joins. They stay in the deeply embedded calculus rather than opening model witnesses.
-/

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace BimodalTest.Automation.ProofModeTest

variable (A B C : Formula)

example : [A.imp B, A] ⊢ B := by
  lstart hAB hA
  lapply hAB
  lexact hA

example : ⊢ A.imp A := by
  lintro hA
  lexact hA

example : [A, B] ⊢ A.and B := by
  lstart hA hB
  lsplit
  · lexact hA
  · lexact hB

example : [A.or B, A.imp C, B.imp C] ⊢ C := by
  lstart hAB hAC hBC
  lcases hAB as hA hB
  · lapply hAC
    lexact hA
  · lapply hBC
    lexact hB

example : [(A.imp B).box, A.box] ⊢ B.box := by
  lstart hAB hA
  lmodal_intro necessity using [hAB, hA] as hAB hA
  lapply hAB
  lexact hA

example : [(A.imp B).allFuture, A.allFuture] ⊢ B.allFuture := by
  lstart hAB hA
  ltemporal_intro future using [hAB, hA] as hAB hA
  lapply hAB
  lexact hA

example : [(A.imp B).allPast, A.allPast] ⊢ B.allPast := by
  lstart hAB hA
  ltemporal_intro past using [hAB, hA] as hAB hA
  lapply hAB
  lexact hA

example : [A.allFuture, B.someFuture] ⊢ (A.and B).someFuture := by
  lstart hA hB
  ltemporal_cases hB using [hA] as hB hA
  lsplit
  · lexact hA
  · lexact hB

opaque projectionContract : ⊢ (A.and B).imp A := by
  lintro h
  lcases h as hA hB
  lexact hA

-- Reuse an opaque contract and a provider with an abstract context through two cuts.
example (Γ : Context) (provider : Γ ⊢ A.and B) : Γ ⊢ C.imp A := by
  lintro hC
  lhave hPair : A.and B := provider
  lapply (projectionContract A B)
  lexact hPair

-- □ facts travel to an alternative; current facts cannot leak into it.
example : [A.box, A.diamond, A] ⊢ (A.and A).diamond := by
  lstart hBox hPossible hCurrent
  lmodal_cases hPossible using [hBox] as hEvent hA
  lsplit
  · fail_if_success lexact hCurrent
    lexact hEvent
  · lexact hA

-- An explicit empty selection must not inherit the matching outer guarantee.
example : [(A.imp A).box, A.imp A] ⊢ (A.imp A).box := by
  lstart hBox hCurrent
  lmodal_intro necessity using []
  fail_if_success lexact hCurrent
  lintro hA
  lexact hA

example : [(A.imp B.someFuture).allFuture, (B.imp C.someFuture).allFuture] ⊢
    (A.imp C.someFuture).allFuture := by
  lstart hAB hBC
  lprogress using [hAB, hBC]

example : [A.someFuture, (A.imp B.someFuture).allFuture] ⊢ B.someFuture := by
  lstart hA hMap
  ladvance hA using [hMap] as hA hMap
  lapply hMap
  lexact hA

example : [(A.imp B).allFuture, Formula.untl A C] ⊢ Formula.untl B C := by
  lstart hMap hUntil
  luntil guard using hMap
  lexact hUntil

example : [(A.imp B).next, A.next] ⊢[FrameClass.ZTime] B.next := by
  lstart hMap hA
  lstep future using [hMap, hA] as hMap hA
  lapply hMap
  lexact hA

example : [A, A.imp A.next, (A.imp A.next).allFuture] ⊢[FrameClass.ZTime] A.allFuture := by
  lstart hInit hNow hFuture
  linvariant future
  · lexact hInit
  · lexact hNow
  · lexact hFuture

-- An abstract frame retains the certificate as a real proof obligation.
example (fc : FrameClass) (hFrame : FrameClass.ZTime ≤ fc) : ⊢[fc] (A.imp A).next := by
  lstep future using []
  · exact hFrame
  · lintro hA
    lexact hA

-- Native TM⁺ arguments may contain stability; no restriction to embedded TM formulas.
example (p q : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree FrameClass.Base
      [(p.stab.imp q).allPast, p.stab.allPast] q.allPast := by
  lstart hMap hP
  ltemporal_use hMap
  lexact hP

example (p : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree FrameClass.Base
      [p.stab.stab, p.stab.dstab] (p.stab.and p.stab).dstab := by
  lstart hSettled hPossible
  lmodal_cases hPossible using [hSettled] as hEvent hScoped
  lsplit
  · lexact hEvent
  · lexact hScoped

-- Exercise dynamically selected rules and past/dual variants at their tactic entry points.
example : [A.box] ⊢ A.and A := by
  lstart hBox
  lmodal_use hBox as hA
  lsplit
  · lexact hA
  · lmodal_use hBox

example : [A.or B] ⊢ B.or A := by
  lstart hEither
  lcases hEither as hA hB
  · lright
    lexact hA
  · lleft
    lexact hB

example : [(A.imp B).allFuture, Formula.untl C A] ⊢ Formula.untl C B := by
  lstart hMap hUntil
  luntil event using hMap
  lexact hUntil

example : [(A.imp B).allPast, (B.imp C).allPast, Formula.snce A B] ⊢ Formula.snce B C := by
  lstart hGuard hEvent hSince
  lsince guard using hGuard
  lsince event using hEvent
  lexact hSince

example : [(A.imp B).prev, A.prev] ⊢[FrameClass.ZTime] B.prev := by
  lstart hMap hA
  lstep past using [hMap, hA] as hMap hA
  lapply hMap
  lexact hA

example : [A, A.imp A.prev, (A.imp A.prev).allPast] ⊢[FrameClass.ZTime] A.allPast := by
  lstart hInit hNow hPast
  linvariant past
  · lexact hInit
  · lexact hNow
  · lexact hPast

example : [A.allPast, B.somePast] ⊢ (A.and B).somePast := by
  lstart hA hB
  ltemporal_cases hB using [hA] as hB hA
  lsplit
  · lexact hA
  · lexact hB

example : [A] ⊢ A.diamond := by
  lstart hA
  lmodal_intro possibility
  lexact hA

example (p : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree FrameClass.Base [p.stab] (p.or p).stab := by
  lstart hP
  lmodal_intro settled using [hP] as hP
  lleft
  lexact hP

example (p : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree FrameClass.Base [p.stab] p.dstab := by
  lstart hP
  lmodal_intro settled_possibility
  lmodal_use hP

end BimodalTest.Automation.ProofModeTest
