/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode

/-! # Boolean rewriting and simplifier diagnostics -/

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace BimodalTest.Automation.ProofModeBooleanTest

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

-- Negative positions reverse implication direction. Explicit paths disambiguate repeated leaves.
example (mapping : Γ ⊢[fc] B.imp A) (provider : Γ ⊢[fc] A.imp C) : Γ ⊢[fc] B.imp C := by
  lrewrite ← mapping (path := [impLeft]) at provider as mapped
  lexact mapped

private def weakeningSchema (X Y : Formula) : ⊢[fc] X.imp (Y.imp X) :=
  .axiom [] _ (.prop_s X Y) (FrameClass.base_le fc)

-- An unmatched data parameter is never guessed from the first Formula local in scope.
example (provider : Γ ⊢[fc] A) : Γ ⊢[fc] A := by
  fail_if_success lrewrite weakeningSchema at provider as guessed
  fail_if_success lrewrite weakeningSchema at provider as guessed (obligations := expose)
  lexact provider

/-- error: Unknown identifier `missingRewriteRule` -/
#guard_msgs in
example : Γ ⊢[fc] A := by
  lsimp only [missingRewriteRule]

/-- error: formula equalities belong to named views (lunfold or lfold) -/
#guard_msgs in
example (equality : A = B) : Γ ⊢[fc] A := by
  lrewrite equality

/-- error: rewrite would leave the formula unchanged -/
#guard_msgs in
example (mapping : Γ ⊢[fc] A.imp A) : Γ ⊢[fc] A := by
  lrewrite mapping

/-- error: lsimp budget exhausted: matches 1/0, scope positions 0/4096 -/
#guard_msgs in
example : Γ ⊢[fc] A.neg.neg := by
  lsimp only [FormalSystem.Theorems.ProofMode.doubleNegationIff] (maxAttempts := 0)

end BimodalTest.Automation.ProofModeBooleanTest
