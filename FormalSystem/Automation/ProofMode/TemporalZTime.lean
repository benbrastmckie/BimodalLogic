/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Temporal

/-! # One-step expansion and contraction of Until and Since -/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic

/-- Checked one-step rule declarations for the selected language. -/
private def oneStepRule (judgment : Judgment) (rule : Name) : MetaM Name := do
  let pair ← match rule with
    | `untilFold => pure (``FormalSystem.Theorems.ProofMode.untilFold,
        ``FormalSystem.PlusLanguage.ProofMode.untilFold)
    | `sinceFold => pure (``FormalSystem.Theorems.ProofMode.sinceFold,
        ``FormalSystem.PlusLanguage.ProofMode.sinceFold)
    | `untilUnfoldCases => pure (``FormalSystem.Theorems.ProofMode.untilUnfoldCases,
        ``FormalSystem.PlusLanguage.ProofMode.untilUnfoldCases)
    | `sinceUnfoldCases => pure (``FormalSystem.Theorems.ProofMode.sinceUnfoldCases,
        ``FormalSystem.PlusLanguage.ProofMode.sinceUnfoldCases)
    | _ => throwError "unregistered one-step temporal rule {rule}"
  return judgment.language.ruleName pair.1 pair.2

/-- The one-step branches `X e` and `X(g ∧ U g e)` (or `Y`/`S`). -/
private def stepBranches (judgment : Judgment) (past : Bool) (guard event : Expr) :
    MetaM (Expr × Expr) := do
  let (operator, step, _, _) := binaryOperators past
  let whole ← formulaApp judgment.language operator #[guard, event]
  let now ← formulaApp judgment.language step #[event]
  let later ← formulaApp judgment.language step
    #[← formulaApp judgment.language `and #[guard, whole]]
  return (now, later)

private def binaryFold (past : Bool) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let (guard, event) ← binaryArgs judgment past judgment.formula "contract"
  let (now, later) ← stepBranches judgment past guard event
  let premise ← temporalPremiseGoal judgment (← formulaApp judgment.language `or #[now, later])
  finishTemporal goal (← mkAppM (← oneStepRule judgment (if past then `sinceFold else `untilFold))
    #[premise])
    [premise.mvarId!]

private def binaryUnfold (past : Bool) (term : Syntax) (eventName continueName : Name) :
    TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let fact ← adaptProof (← elaborateProof term) judgment
  let (guard, event) ← binaryArgs judgment past (← proofJudgment fact).formula "expand"
  let (gate, gateGoals) ← integerTimeGate judgment
  let (now, later) ← stepBranches judgment past guard event
  let branch (head : Expr) : MetaM Expr := do
    mkFreshExprSyntheticOpaqueMVar (← derivationType judgment
      (← mkAppM ``List.cons #[head, judgment.context]) judgment.formula)
  let hEvent ← branch now
  let hContinue ← branch later
  let proof ← mkAppM
    (← oneStepRule judgment (if past then `sinceUnfoldCases else `untilUnfoldCases))
    #[gate, fact, hEvent, hContinue]
  let named (body : Expr) (name : Name) (head : Expr) : MetaM MVarId :=
    body.mvarId!.withContext do
      nameProof body.mvarId! name (← assumptionProof (← requireJudgment body.mvarId!) head)
  let eventGoal ← named hEvent eventName now
  let continueGoal ← named hContinue continueName later
  finishTemporal goal proof (gateGoals ++ [eventGoal, continueGoal])

/-- Reduce an Until goal to `X e ∨ X(g ∧ U g e)`, at every frame class. -/
syntax (name := luntilFold) "luntil" ppSpace &"contract" : tactic

/-- Unfold an Until fact one step on integer time; both branches keep `X` and prove the goal. -/
syntax (name := luntilUnfold) "luntil" ppSpace &"expand" ppSpace colGt term ppSpace "as"
  ppSpace colGt ident ppSpace colGt ident : tactic

/-- Reduce a Since goal to `Y e ∨ Y(g ∧ S g e)`, at every frame class. -/
syntax (name := lsinceFold) "lsince" ppSpace &"contract" : tactic

/-- Unfold a Since fact one step on integer time; both branches keep `Y`. -/
syntax (name := lsinceUnfold) "lsince" ppSpace &"expand" ppSpace colGt term ppSpace "as"
  ppSpace colGt ident ppSpace colGt ident : tactic

elab_rules : tactic
  | `(tactic| luntil contract) => binaryFold false
  | `(tactic| lsince contract) => binaryFold true
  | `(tactic| luntil expand $proof:term as $event:ident $cont:ident) =>
    binaryUnfold false proof event.getId cont.getId
  | `(tactic| lsince expand $proof:term as $event:ident $cont:ident) =>
    binaryUnfold true proof event.getId cont.getId

end FormalSystem.Automation.ProofMode
