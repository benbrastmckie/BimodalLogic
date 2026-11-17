/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Modal
import FormalSystem.Theorems.ProofMode.Discrete
import FormalSystem.Theorems.ProofMode.PlusDiscrete

/-!
# Checked discrete steps and invariance

Next/Previous introduction shifts exactly the selected assumptions. Invariance leaves current
initialization, the current one-step implication, and its strict G/H persistence as obligations.
Both operations require an explicit or generated `FrameClass.ZTime ≤ fc` certificate.
-/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic

private def discreteFrame (judgment : Judgment) :
    TacticM (Expr × List MVarId) := do
  let discrete := mkConst ``FormalSystem.ProofSystem.FrameClass.ZTime
  let expected ← mkAppM ``LE.le #[discrete, judgment.frame]
  if ← isDefEq judgment.frame discrete then
    return (← mkAppM ``le_refl #[discrete], [])
  let proof ← mkFreshExprSyntheticOpaqueMVar expected
  return (proof, [proof.mvarId!])

private def adjacent (past : Bool) (terms : Option (Array Syntax))
    (names : Array Syntax) : TacticM Unit := withMainContext do
  let judgment ← requireJudgment (← getMainGoal)
  let (frame, sideGoals) ← discreteFrame judgment
  let operator := if past then `prev else `next
  let rule := if past then judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.generalizedPrevK
      ``FormalSystem.PlusLanguage.ProofMode.generalizedPrevK
    else judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.generalizedNextK
      ``FormalSystem.PlusLanguage.ProofMode.generalizedNextK
  introduceMappedScope operator rule #[frame] terms names
  setGoals (sideGoals ++ (← getGoals))

private def invariant (past : Bool) : TacticM Unit :=
    withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let (frame, sideGoals) ← discreteFrame judgment
  let rule := if past then judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.pastInvariant
      ``FormalSystem.PlusLanguage.ProofMode.pastInvariant
    else judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.forwardInvariant
      ``FormalSystem.PlusLanguage.ProofMode.forwardInvariant
  let operator := if past then `allPast else `allFuture
  let some args ← operatorArgs? judgment.language operator 1 judgment.formula
    | throwError "invariance requires the matching universal temporal goal"
  let rule ← mkAppOptM rule
    #[some judgment.frame, some judgment.context, some args[0]!, some frame]
  let goals ← goal.apply rule
  replaceMainGoal (sideGoals ++ goals)

/-- Shift selected Next/Previous guarantees to a checked adjacent-point body. -/
syntax (name := lstep) "lstep" ppSpace colGt ident
  (ppSpace "using" ppSpace "[" term,* "]")?
  (ppSpace "as" (ppSpace colGt ident)+)? : tactic

/-- Apply integer-time invariance, leaving initialization and both step obligations. -/
syntax (name := linvariant) "linvariant" ppSpace colGt ident : tactic

private def pastDirection (kind : Syntax) : TacticM Bool :=
  match kind.getId with
  | `future => pure false
  | `past => pure true
  | _ => throwError "expected `future` or `past`"

elab_rules : tactic
  | `(tactic|
      lstep $kind:ident $[using [$terms:term,*]]? $[as $names:ident*]?) => do
    adjacent (← pastDirection kind) (terms.map (·.getElems.map (·.raw)))
      (names.map (·.map (·.raw)) |>.getD #[])
  | `(tactic| linvariant $kind:ident) => do invariant (← pastDirection kind)

end FormalSystem.Automation.ProofMode
