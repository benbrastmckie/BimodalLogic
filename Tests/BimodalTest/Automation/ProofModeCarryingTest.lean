/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode

/-!
# The carrying table

The keys are pinned, each row's rules are checked against its source, target and frame flag, and
each row is exercised through a tactic in both languages.
-/

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
open Lean Meta Elab Tactic FormalSystem.Automation.ProofMode
open FormalSystem.Tactic.FormulaSyntax (Language)

namespace BimodalTest.Automation.ProofModeCarryingTest

variable {fc : FrameClass} (A B : Formula) (P Q : PlusFormula)

#guard carryRules.map (fun row => (row.source, row.target, row.framed)) ==
  #[(`allFuture, `allFuture, false), (`allFuture, `next, true),
    (`allPast, `allPast, false), (`allPast, `prev, true)]

-- Each rule takes a source-headed fact, last, to the same fact under the target operator, and
-- has a frame premise exactly when its row is framed.
run_meta do
  for row in carryRules do
    for language in [Language.tm, Language.plus] do
      let rule := language.ruleName row.rule.1 row.rule.2
      forallTelescope (← getConstInfo rule).type fun parameters type => do
        let some result ← judgment? type | throwError "{rule}: not a derivation rule"
        let some fact ← judgment? (← inferType parameters.back!)
          | throwError "{rule}: the fact is not last"
        unless result.language == language do throwError "{rule}: wrong language"
        unless (← operatorArgs? language row.source 1 fact.formula).isSome do
          throwError "{rule}: wrong source"
        let some body ← operatorArgs? language row.target 1 result.formula
          | throwError "{rule}: wrong target"
        unless ← isDefEq body[0]! fact.formula do throwError "{rule}: the fact is not kept"
        let framed ← parameters.anyM fun parameter => return (← inferType parameter).isAppOf ``LE.le
        unless framed == row.framed do throwError "{rule}: wrong frame flag"

/-! ## `G` into `G`, `H` into `H`: every frame class -/

example : [A.allFuture] ⊢[fc] A.allFuture.allFuture := by
  lstart hA
  ltemporal_intro future using [] keeping [hA] as hA
  lexact hA

example : [A.allPast] ⊢[fc] A.allPast.allPast := by
  lstart hA
  ltemporal_intro past using [] keeping [hA] as hA
  lexact hA

example : PlusDerivationTree fc [P.stab.allFuture] P.stab.allFuture.allFuture := by
  lstart hP
  ltemporal_intro future using [] keeping [hP] as hP
  lexact hP

example : PlusDerivationTree fc [P.stab.allPast] P.stab.allPast.allPast := by
  lstart hP
  ltemporal_intro past using [] keeping [hP] as hP
  lexact hP

/-! ## `G` into `X`, `H` into `Y`: ZTime -/

example : [A.allFuture] ⊢[FrameClass.ZTime] A.allFuture.next := by
  lstart hA
  lstep future using [] keeping [hA] as hA
  lexact hA

example (hZ : FrameClass.ZTime ≤ fc) : [A.allPast] ⊢[fc] A.allPast.prev := by
  lstart hA
  lstep past using [] keeping [hA] as hA
  lexact hA

example (hZ : FrameClass.ZTime ≤ fc) :
    PlusDerivationTree fc [P.stab.allFuture] P.stab.allFuture.next := by
  lstart hP
  lstep future using [] keeping [hP] as hP
  lexact hP

example (hZ : FrameClass.ZTime ≤ fc) :
    PlusDerivationTree fc [P.stab.allPast] P.stab.allPast.prev := by
  lstart hP
  lstep past using [] keeping [hP] as hP
  lexact hP

-- `using` bodies lose their operator and kept facts do not; names follow that order.
example : [A.next, B.allFuture] ⊢[FrameClass.ZTime] (A.and B.allFuture).next := by
  lstart hA hB
  lstep future using [hA] keeping [hB] as hA hB
  lsplit
  · lexact hA
  · lexact hB

/-! ## Rejections name the scope and the sources it accepts -/

/--
error: `keeping` carries only G-scoped facts into the G scope; A.allPast needs its own preservation rule
-/
#guard_msgs in
example : [A.allPast] ⊢ A.allPast.allFuture := by
  lstart hA
  ltemporal_intro future using [] keeping [hA] as hA

/--
error: `keeping` carries only G-scoped facts into the X scope; A.next needs its own preservation rule
-/
#guard_msgs in
example : [A.next] ⊢[FrameClass.ZTime] A.next.next := by
  lstart hA
  lstep future using [] keeping [hA] as hA

/--
error: `keeping` carries only H-scoped facts into the H scope; A needs its own preservation rule
-/
#guard_msgs in
example : [A, B.somePast] ⊢ (B.and A).somePast := by
  lstart hA hB
  ltemporal_cases hB using [] keeping [hA] as hB hA

-- The frame premise of a framed row is the step's own gate.
/-- error: integer-time reasoning requires FrameClass.ZTime ≤ FrameClass.Dense -/
#guard_msgs in
example : [A.allFuture] ⊢[FrameClass.Dense] A.allFuture.next := by
  lstart hA
  lstep future using [] keeping [hA] as hA

end BimodalTest.Automation.ProofModeCarryingTest
