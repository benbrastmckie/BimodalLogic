/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Temporal

/-! # Strict temporal progress and leads-to composition -/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic

/-- Checked strict leads-to rule declarations for the selected language. -/
private def progressRule (judgment : Judgment) (rule : Name) : MetaM Name := do
  let pair ← match rule with
    | `progressCases => pure (``FormalSystem.Theorems.ProofMode.progressCases,
        ``FormalSystem.PlusLanguage.ProofMode.progressCases)
    | `pastProgressCases => pure (``FormalSystem.Theorems.ProofMode.pastProgressCases,
        ``FormalSystem.PlusLanguage.ProofMode.pastProgressCases)
    | `progressConsequence => pure (``FormalSystem.Theorems.ProofMode.progressConsequence,
        ``FormalSystem.PlusLanguage.ProofMode.progressConsequence)
    | `pastProgressConsequence => pure (``FormalSystem.Theorems.ProofMode.pastProgressConsequence,
        ``FormalSystem.PlusLanguage.ProofMode.pastProgressConsequence)
    | `leadsToConsequence => pure (``FormalSystem.Theorems.ProofMode.leadsToConsequence,
        ``FormalSystem.PlusLanguage.ProofMode.leadsToConsequence)
    | `pastLeadsToConsequence => pure (``FormalSystem.Theorems.ProofMode.pastLeadsToConsequence,
        ``FormalSystem.PlusLanguage.ProofMode.pastLeadsToConsequence)
    | `leadsToTrans => pure (``FormalSystem.Theorems.ProofMode.leadsToTrans,
        ``FormalSystem.PlusLanguage.ProofMode.leadsToTrans)
    | `pastLeadsToTrans => pure (``FormalSystem.Theorems.ProofMode.pastLeadsToTrans,
        ``FormalSystem.PlusLanguage.ProofMode.pastLeadsToTrans)
    -- Unreachable from parsed syntax: `rule` is supplied by the elaborators in this module, never
    -- by the user, and every value they pass is matched above. The arm guards a future caller
    -- that passes an unregistered name, and is deliberately unpinned for want of a trigger.
    | _ => throwError "unregistered strict leads-to rule {rule}"
  return judgment.language.ruleName pair.1 pair.2

/-! ## Progress -/

private def progress (terms : Array Syntax) : TacticM Unit := withMainContext do
  unless terms.size == 2 do throwError "lprogress requires exactly two progress guarantees"
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let first ← adaptProof (← elaborateProof terms[0]!) judgment
  let second ← adaptProof (← elaborateProof terms[1]!) judgment
  let type := judgment.language.formulaType
  let name ← if (← operatorArgs? type `allFuture 1 judgment.formula).isSome then
      pure (judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.progressTrans
        ``FormalSystem.PlusLanguage.ProofMode.progressTrans)
    else if (← operatorArgs? judgment.language.formulaType `allPast 1 judgment.formula).isSome then
      pure (judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.pastProgressTrans
        ``FormalSystem.PlusLanguage.ProofMode.pastProgressTrans)
    else throwError "lprogress expected a future- or past-scoped progress goal"
  finishTemporal goal (← mkAppM name #[first, second])

/-- A leads-to statement: `G(φ → Fψ)` (persistent) or `φ → Fψ` (current), or past mirrors. -/
private structure LeadsTo where
  persistent : Bool
  past : Bool
  source : Expr
  target : Expr

private def leadsTo? (judgment : Judgment) (formula : Expr) : MetaM (Option LeadsTo) := do
  let read (persistent past : Bool) (body : Expr) : MetaM (Option LeadsTo) := do
    let some imp ← operatorArgs? judgment.language.formulaType `imp 2 body | return none
    let eventual := if past then `somePast else `someFuture
    let some target ← operatorArgs? judgment.language.formulaType eventual 1 imp[1]! | return none
    return some ⟨persistent, past, imp[0]!, target[0]!⟩
  if let some body ← operatorArgs? judgment.language.formulaType `allFuture 1 formula then
    if let some result ← read true false body[0]! then return result
  if let some body ← operatorArgs? judgment.language.formulaType `allPast 1 formula then
    if let some result ← read true true body[0]! then return result
  if let some result ← read false false formula then return result
  read false true formula

private def requireLeadsTo (judgment : Judgment) (formula : Expr) : MetaM LeadsTo := do
  let some result ← leadsTo? judgment formula
    | throwError "expected a leads-to statement G(φ → Fψ), φ → Fψ, or a past mirror"
  return result

/-- Build `scope (φ → ψ)` for the leads-to direction. -/
private def scopedImp (judgment : Judgment) (past : Bool) (φ ψ : Expr) : MetaM Expr := do
  formulaApp judgment.language (if past then `allPast else `allFuture)
    #[← formulaApp judgment.language `imp #[φ, ψ]]

private def eventually (judgment : Judgment) (past : Bool) (φ : Expr) : MetaM Expr :=
  formulaApp judgment.language (if past then `somePast else `someFuture) #[φ]

private def progressCasesGoal : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let shape ← requireLeadsTo judgment judgment.formula
  unless shape.persistent do throwError "lprogress cases expects a persistent G/H leads-to goal"
  let some cases ← operatorArgs? judgment.language.formulaType `or 2 shape.source
    | throwError "lprogress cases expects a disjunctive source"
  let target ← eventually judgment shape.past shape.target
  let first ← temporalPremiseGoal judgment (← scopedImp judgment shape.past cases[0]! target)
  let second ← temporalPremiseGoal judgment (← scopedImp judgment shape.past cases[1]! target)
  let rule ← progressRule judgment
    (if shape.past then `pastProgressCases else `progressCases)
  finishTemporal goal (← mkAppM rule #[first, second]) [first.mvarId!, second.mvarId!]

private def progressConsequenceGoal (term : Syntax) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let wanted ← requireLeadsTo judgment judgment.formula
  let given ← adaptProof (← elaborateProof term) judgment
  let have_ ← requireLeadsTo judgment (← proofJudgment given).formula
  unless wanted.persistent == have_.persistent && wanted.past == have_.past do
    throwError "the supplied guarantee has a different leads-to form than the goal"
  let pre ← if wanted.persistent then scopedImp judgment wanted.past wanted.source have_.source
    else formulaApp judgment.language `imp #[wanted.source, have_.source]
  let post ← scopedImp judgment wanted.past have_.target wanted.target
  let hPre ← temporalPremiseGoal judgment pre
  let hPost ← temporalPremiseGoal judgment post
  let name := match wanted.persistent, wanted.past with
    | true, false => `progressConsequence
    | true, true => `pastProgressConsequence
    | false, false => `leadsToConsequence
    | false, true => `pastLeadsToConsequence
  finishTemporal goal (← mkAppM (← progressRule judgment name) #[hPre, hPost, given])
    [hPre.mvarId!, hPost.mvarId!]

private def progressTransGoal (term : Syntax) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let wanted ← requireLeadsTo judgment judgment.formula
  let given ← adaptProof (← elaborateProof term) judgment
  let have_ ← requireLeadsTo judgment (← proofJudgment given).formula
  unless wanted.persistent == have_.persistent && wanted.past == have_.past do
    throwError "the supplied first step has a different leads-to form than the goal"
  unless ← isDefEq wanted.source have_.source do
    throwError "the supplied first step has a different source than the goal"
  let next ← temporalPremiseGoal judgment (← scopedImp judgment wanted.past have_.target
    (← eventually judgment wanted.past wanted.target))
  let name ← match wanted.persistent, wanted.past with
    | true, false => pure (judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.progressTrans
        ``FormalSystem.PlusLanguage.ProofMode.progressTrans)
    | true, true => pure (judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.pastProgressTrans
        ``FormalSystem.PlusLanguage.ProofMode.pastProgressTrans)
    | false, false => progressRule judgment `leadsToTrans
    | false, true => progressRule judgment `pastLeadsToTrans
  finishTemporal goal (← mkAppM name #[given, next]) [next.mvarId!]

/-- Compose two future or past progress guarantees by a native derivation rule. -/
syntax (name := lprogress) "lprogress" ppSpace "using" ppSpace "[" term,* "]" : tactic

/-- Split a persistent leads-to goal with a disjunctive source into its two cases. -/
syntax (name := lprogressCases) "lprogress" ppSpace &"cases" : tactic

/-- Weaken a leads-to guarantee: strengthen its source, weaken its target under G/H. -/
syntax (name := lprogressConsequence) "lprogress" ppSpace &"consequence" ppSpace "using"
  ppSpace colGt term : tactic

/-- Compose a supplied first leads-to step with a persistent second step left as a goal. -/
syntax (name := lprogressTrans) "lprogress" ppSpace &"trans" ppSpace "using" ppSpace colGt term :
  tactic

elab_rules : tactic
  | `(tactic| lprogress using [$terms:term,*]) => progress (terms.getElems.map (·.raw))
  | `(tactic| lprogress cases) => progressCasesGoal
  | `(tactic| lprogress consequence using $proof:term) => progressConsequenceGoal proof
  | `(tactic| lprogress trans using $proof:term) => progressTransGoal proof

end FormalSystem.Automation.ProofMode
