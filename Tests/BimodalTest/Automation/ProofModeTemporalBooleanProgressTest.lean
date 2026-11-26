/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode

/-!
# Strict leads-to composition

The coverage matrix: each of the four progress forms (`using [·, ·]`, `cases`,
`consequence using ·`, `trans using ·`) in the future and past directions, at both TM and TM⁺.
The future-TM `using [·, ·]` cell is covered in `ProofModeTest.lean` and is deliberately not
repeated here.
-/

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage

namespace BimodalTest.Automation.ProofModeTemporalBooleanProgressTest

variable {fc : FrameClass} (Γ : Context) (A B C D : Formula) (P Q R S : PlusFormula)

/-! ## Future, TM -/

-- Consequence and finite cases compose persistent leads-to guarantees.
example : [(A.imp C.someFuture).allFuture, (B.imp C.someFuture).allFuture] ⊢
    ((A.or B).imp C.someFuture).allFuture := by
  lstart hA hB
  lprogress cases
  · lexact hA
  · lexact hB

-- The weakening form: strengthen the source and weaken the target under `G`.
example : [(A.imp B).allFuture, (C.imp D).allFuture, (B.imp C.someFuture).allFuture] ⊢
    (A.imp D.someFuture).allFuture := by
  lstart hPre hPost hMid
  lprogress consequence using hMid
  · lexact hPre
  · lexact hPost

-- The one-sided composition form: the second step is left as the single remaining goal.
example : [(A.imp B.someFuture).allFuture, (B.imp C.someFuture).allFuture] ⊢
    (A.imp C.someFuture).allFuture := by
  lstart hFirst hSecond
  lprogress trans using hFirst
  lexact hSecond

/-! ## Past, TM -/

example : [(A.imp B.somePast).allPast, (B.imp C.somePast).allPast] ⊢
    (A.imp C.somePast).allPast := by
  lstart hAB hBC
  lprogress using [hAB, hBC]

example : [(A.imp C.somePast).allPast, (B.imp C.somePast).allPast] ⊢
    ((A.or B).imp C.somePast).allPast := by
  lstart hA hB
  lprogress cases
  · lexact hA
  · lexact hB

example : [(A.imp B).allPast, (C.imp D).allPast, (B.imp C.somePast).allPast] ⊢
    (A.imp D.somePast).allPast := by
  lstart hPre hPost hMid
  lprogress consequence using hMid
  · lexact hPre
  · lexact hPost

example : [(A.imp B.somePast).allPast, (B.imp C.somePast).allPast] ⊢
    (A.imp C.somePast).allPast := by
  lstart hFirst hSecond
  lprogress trans using hFirst
  lexact hSecond

/-! ## Future, TM⁺

Written in the `PlusDerivationTree` shape, so the `FormalSystem.PlusLanguage.ProofMode` mirrors
are the rules actually exercised. -/

example : PlusDerivationTree fc
    [(P.imp Q.someFuture).allFuture, (Q.imp R.someFuture).allFuture]
    (P.imp R.someFuture).allFuture := by
  lstart hPQ hQR
  lprogress using [hPQ, hQR]

example : PlusDerivationTree fc
    [(P.imp R.someFuture).allFuture, (Q.imp R.someFuture).allFuture]
    ((P.or Q).imp R.someFuture).allFuture := by
  lstart hP hQ
  lprogress cases
  · lexact hP
  · lexact hQ

example : PlusDerivationTree fc
    [(P.imp Q).allFuture, (R.imp S).allFuture, (Q.imp R.someFuture).allFuture]
    (P.imp S.someFuture).allFuture := by
  lstart hPre hPost hMid
  lprogress consequence using hMid
  · lexact hPre
  · lexact hPost

example : PlusDerivationTree fc
    [(P.imp Q.someFuture).allFuture, (Q.imp R.someFuture).allFuture]
    (P.imp R.someFuture).allFuture := by
  lstart hFirst hSecond
  lprogress trans using hFirst
  lexact hSecond

/-! ## Past, TM⁺ -/

example : PlusDerivationTree fc
    [(P.imp Q.somePast).allPast, (Q.imp R.somePast).allPast]
    (P.imp R.somePast).allPast := by
  lstart hPQ hQR
  lprogress using [hPQ, hQR]

example : PlusDerivationTree fc
    [(P.imp R.somePast).allPast, (Q.imp R.somePast).allPast]
    ((P.or Q).imp R.somePast).allPast := by
  lstart hP hQ
  lprogress cases
  · lexact hP
  · lexact hQ

example : PlusDerivationTree fc
    [(P.imp Q).allPast, (R.imp S).allPast, (Q.imp R.somePast).allPast]
    (P.imp S.somePast).allPast := by
  lstart hPre hPost hMid
  lprogress consequence using hMid
  · lexact hPre
  · lexact hPost

example : PlusDerivationTree fc
    [(P.imp Q.somePast).allPast, (Q.imp R.somePast).allPast]
    (P.imp R.somePast).allPast := by
  lstart hFirst hSecond
  lprogress trans using hFirst
  lexact hSecond

/-! ## Negative tests: every added diagnostic in `TemporalBoolean.lean`

One `#guard_msgs` block per reachable `throwError` the strict-progress elaborators added. The
module's remaining arm, `unregistered strict leads-to rule`, is unreachable from parsed syntax
and carries its reason in-source instead. -/

/-- error: lprogress requires exactly two progress guarantees -/
#guard_msgs in
example : [(A.imp B.someFuture).allFuture] ⊢ (A.imp B.someFuture).allFuture := by
  lstart hAB
  lprogress using [hAB]

/-- error: lprogress expected a future- or past-scoped progress goal -/
#guard_msgs in
example : [A] ⊢ A := by
  lstart hA
  lprogress using [hA, hA]

/-- error: expected a leads-to statement G(φ → Fψ), φ → Fψ, or a past mirror -/
#guard_msgs in
example : [A] ⊢ A := by
  lstart hA
  lprogress cases

/-- error: lprogress cases expects a persistent G/H leads-to goal -/
#guard_msgs in
example : [A] ⊢ (A.or B).imp C.someFuture := by
  lstart hA
  lprogress cases

/-- error: lprogress cases expects a disjunctive source -/
#guard_msgs in
example : [A] ⊢ (A.imp C.someFuture).allFuture := by
  lstart hA
  lprogress cases

/-- error: the supplied guarantee has a different leads-to form than the goal -/
#guard_msgs in
example : [B.imp C.someFuture] ⊢ (A.imp C.someFuture).allFuture := by
  lstart hCurrent
  lprogress consequence using hCurrent

/-- error: the supplied first step has a different leads-to form than the goal -/
#guard_msgs in
example : [B.imp C.someFuture] ⊢ (A.imp C.someFuture).allFuture := by
  lstart hCurrent
  lprogress trans using hCurrent

/-- error: the supplied first step has a different source than the goal -/
#guard_msgs in
example : [(B.imp D.someFuture).allFuture] ⊢ (A.imp C.someFuture).allFuture := by
  lstart hFirst
  lprogress trans using hFirst

end BimodalTest.Automation.ProofModeTemporalBooleanProgressTest
