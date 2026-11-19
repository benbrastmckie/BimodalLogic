/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Modal
import FormalSystem.Theorems.ProofMode.Temporal
import FormalSystem.Theorems.ProofMode.PlusTemporal

/-!
# Scoped temporal steps for native derivations

Eventuality elimination opens an object-language derivation under the event and selected
future- or past-scoped assumptions. Deduction and generalized necessitation close that scope;
consequence or bind reconstructs the outer eventuality. No semantic time witness is introduced,
and an eventual assertion never becomes a current assertion in the caller's context.

Until and Since operations use the source calculus's guard-first, event-second constructors.
The commands apply proved monotonicity and progress rules, preserving their scoped premises.
-/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic

private def proofJudgment (proof : Expr) : MetaM Judgment := do
  let some judgment ← judgment? (← inferType proof)
    | throwError "expected a native derivation"
  return judgment

private def existentialOperator (scope : Scope) : Name :=
  match scope with
  | .future => `someFuture
  | _ => `somePast

private def temporalGoal (judgment : Judgment) : MetaM (Scope × Expr) := do
  if let some args ← operatorArgs? judgment.language `someFuture 1 judgment.formula then
    return (.future, args[0]!)
  if let some args ← operatorArgs? judgment.language `somePast 1 judgment.formula then
    return (.past, args[0]!)
  throwError "expected a strict future or past eventuality goal"

private def finish (goal : MVarId) (proof : Expr) (goals : List MVarId := []) :
    TacticM Unit := do
  unless ← isDefEq (← inferType proof) (← goal.getType) do
    throwError "the temporal rule does not prove the current conclusion"
  goal.assign proof
  replaceMainGoal goals

private def eventualityCases (bind : Bool) (term : Syntax)
    (selected : Option (Array Syntax)) (names : Array Syntax) : TacticM Unit :=
    withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let (scope, conclusion) ← temporalGoal judgment
  let eventProof ← adaptProof (← elaborateProof term) judgment
  let source ← proofJudgment eventProof
  let some eventArgs ← operatorArgs? judgment.language (existentialOperator scope) 1
      source.formula
    | throwError "the selected eventuality has the wrong time direction"
  let mut guarantees : Array Expr := #[]
  match selected with
  | none =>
    for formula in ← contextEntries judgment.context do
      if (← operatorArgs? judgment.language scope.operator 1 formula).isSome then
        guarantees := guarantees.push (← assumptionProof judgment formula)
  | some terms =>
    for term in terms do
      guarantees := guarantees.push (← adaptProof (← elaborateProof term) judgment)
  let mut formulas : Array Expr := #[]
  for guarantee in guarantees do
    let source ← proofJudgment guarantee
    let some args ← operatorArgs? judgment.language scope.operator 1 source.formula
      | throwError "selected guarantee must have the matching universal time scope"
    formulas := formulas.push args[0]!
  unless names.size == formulas.size + 1 do
    throwError "expected an event name and {formulas.size} scoped assumption names"
  let context ← contextExpr judgment.language formulas
  let bodyContext ← contextExpr judgment.language (#[eventArgs[0]!] ++ formulas)
  let bodyFormula := if bind then judgment.formula else conclusion
  let body ← mkFreshExprSyntheticOpaqueMVar
    (← derivationType judgment bodyContext bodyFormula)
  let deductionName := judgment.language.ruleName
    ``FormalSystem.Metalogic.Core.deductionTheorem
    ``FormalSystem.PlusLanguage.ProofMode.deductionTheorem
  let implication ← mkAppM deductionName #[context, eventArgs[0]!, bodyFormula, body]
  let implicationJudgment ← proofJudgment implication
  let lifted ← mkAppM (← scope.rule judgment.language)
    #[context, implicationJudgment.formula, implication]
  let mapping ← substituteProofs judgment lifted guarantees
  let ruleName := match scope, bind with
    | .future, false => judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.futureConsequence
      ``FormalSystem.PlusLanguage.ProofMode.futureConsequence
    | .future, true => judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.futureBind
      ``FormalSystem.PlusLanguage.ProofMode.futureBind
    | _, false => judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.pastConsequence
      ``FormalSystem.PlusLanguage.ProofMode.pastConsequence
    | _, true => judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.pastBind
      ``FormalSystem.PlusLanguage.ProofMode.pastBind
  let proof ← mkAppM ruleName #[mapping, eventProof]
  let mut bodyGoal := body.mvarId!
  let assumptions := #[eventArgs[0]!] ++ formulas
  for i in [:assumptions.size] do
    bodyGoal ← bodyGoal.withContext do
      let bodyJudgment ← requireJudgment bodyGoal
      nameProof bodyGoal names[i]!.getId (← assumptionProof bodyJudgment assumptions[i]!)
  finish goal proof [bodyGoal]

private def temporalUse (term : Syntax) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let mapping ← adaptProof (← elaborateProof term) judgment
  let source ← proofJudgment mapping
  let (scope, mappingArgs) ←
    match ← operatorArgs? judgment.language `allFuture 1 source.formula with
    | some args => pure (Scope.future, args)
    | none =>
      match ← operatorArgs? judgment.language `allPast 1 source.formula with
      | some args => pure (Scope.past, args)
      | none => throwError "ltemporal_use requires a universally scoped implication"
  let some implicationArgs ← operatorArgs? judgment.language `imp 2 mappingArgs[0]!
    | throwError "ltemporal_use requires an implication inside its time scope"
  let universal ← operatorArgs? judgment.language scope.operator 1 judgment.formula
  let eventual ← operatorArgs? judgment.language (existentialOperator scope) 1 judgment.formula
  let (operator, conclusion) ← match universal, eventual with
    | some args, _ => pure (scope.operator, args[0]!)
    | _, some args => pure (existentialOperator scope, args[0]!)
    | _, _ => throwError "the goal must have the implication's future or past direction"
  unless ← isDefEq implicationArgs[1]! conclusion do
    throwError "the scoped implication's conclusion does not match the temporal goal"
  let premiseFormula ← formulaApp judgment.language operator
    #[implicationArgs[0]!]
  let premise ← mkFreshExprSyntheticOpaqueMVar
    (← derivationType judgment judgment.context premiseFormula)
  let proof ← if universal.isSome then do
    let name := match scope with
      | .future => judgment.language.ruleName
        ``FormalSystem.Theorems.TemporalDerived.gDistribution
        ``FormalSystem.PlusLanguage.ProofMode.gDistribution
      | _ => judgment.language.ruleName
        ``FormalSystem.Theorems.TemporalDerived.hDistribution
        ``FormalSystem.PlusLanguage.ProofMode.hDistribution
    let distribution ← mkAppOptM name
      #[some judgment.frame, some implicationArgs[0]!, some implicationArgs[1]!]
    let distribution ← adaptProof distribution judgment
    let implication ← modusPonens judgment distribution mapping
    modusPonens judgment implication premise
  else do
    let name := match scope with
      | .future => judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.futureConsequence
        ``FormalSystem.PlusLanguage.ProofMode.futureConsequence
      | _ => judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.pastConsequence
        ``FormalSystem.PlusLanguage.ProofMode.pastConsequence
    mkAppM name #[mapping, premise]
  finish goal proof [premise.mvarId!]

private def progress (terms : Array Syntax) : TacticM Unit := withMainContext do
  unless terms.size == 2 do throwError "lprogress requires exactly two progress guarantees"
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let first ← adaptProof (← elaborateProof terms[0]!) judgment
  let second ← adaptProof (← elaborateProof terms[1]!) judgment
  let name ← if (← operatorArgs? judgment.language `allFuture 1 judgment.formula).isSome then
      pure (judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.progressTrans
        ``FormalSystem.PlusLanguage.ProofMode.progressTrans)
    else if (← operatorArgs? judgment.language `allPast 1 judgment.formula).isSome then
      pure (judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.pastProgressTrans
        ``FormalSystem.PlusLanguage.ProofMode.pastProgressTrans)
    else throwError "lprogress expected a future- or past-scoped progress goal"
  finish goal (← mkAppM name #[first, second])

private def binaryTemporal (past guard : Bool) (term : Syntax) : TacticM Unit :=
    withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let operator := if past then `snce else `untl
  let scopeOperator := if past then `allPast else `allFuture
  let some goalArgs ← operatorArgs? judgment.language operator 2 judgment.formula
    | throwError "expected the corresponding Until or Since goal"
  let mapping ← adaptProof (← elaborateProof term) judgment
  let source ← proofJudgment mapping
  let some scopeArgs ← operatorArgs? judgment.language scopeOperator 1 source.formula
    | throwError "monotonicity requires an implication in the matching time scope"
  let some implicationArgs ← operatorArgs? judgment.language `imp 2 scopeArgs[0]!
    | throwError "monotonicity requires a scoped implication"
  let targetIndex := if guard then 0 else 1
  unless ← isDefEq implicationArgs[1]! goalArgs[targetIndex]! do
    throwError "the implication's conclusion does not match the selected operand"
  let sourceArgs := goalArgs.set! targetIndex implicationArgs[0]!
  let sourceFormula ← formulaApp judgment.language operator sourceArgs
  let premise ← mkFreshExprSyntheticOpaqueMVar
    (← derivationType judgment judgment.context sourceFormula)
  let name := match past, guard with
    | false, true => judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.untilGuard
      ``FormalSystem.PlusLanguage.ProofMode.untilGuard
    | false, false => judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.untilEvent
      ``FormalSystem.PlusLanguage.ProofMode.untilEvent
    | true, true => judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.sinceGuard
      ``FormalSystem.PlusLanguage.ProofMode.sinceGuard
    | true, false => judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.sinceEvent
      ``FormalSystem.PlusLanguage.ProofMode.sinceEvent
  finish goal (← mkAppM name #[mapping, premise]) [premise.mvarId!]

/-- Open an eventuality body using only selected G/H guarantees; `using []` selects none. -/
syntax (name := ltemporalCases) "ltemporal_cases" ppSpace colGt term
  (ppSpace "using" ppSpace "[" term,* "]")? ppSpace "as" (ppSpace colGt ident)+ : tactic

/-- Open an eventuality with an eventual body conclusion, using the proved temporal bind rule. -/
syntax (name := ladvance) "ladvance" ppSpace colGt term
  (ppSpace "using" ppSpace "[" term,* "]")? ppSpace "as" (ppSpace colGt ident)+ : tactic

/-- Apply a G/H-scoped implication, leaving the corresponding G/H/F/P premise. -/
syntax (name := ltemporalUse) "ltemporal_use" ppSpace colGt term : tactic

/-- Compose two future or past progress guarantees by a native derivation rule. -/
syntax (name := lprogress) "lprogress" ppSpace "using" ppSpace "[" term,* "]" : tactic

/-- Map the guard or event of an Until goal with a future-scoped implication. -/
syntax (name := luntil) "luntil" ppSpace colGt ident ppSpace "using" ppSpace colGt term : tactic

/-- Map the guard or event of a Since goal with a past-scoped implication. -/
syntax (name := lsince) "lsince" ppSpace colGt ident ppSpace "using" ppSpace colGt term : tactic

elab_rules : tactic
  | `(tactic| ltemporal_cases $proof:term $[using [$terms:term,*]]? as $names:ident*) =>
    eventualityCases false proof (terms.map (·.getElems.map (·.raw))) (names.map (·.raw))
  | `(tactic| ladvance $proof:term $[using [$terms:term,*]]? as $names:ident*) =>
    eventualityCases true proof (terms.map (·.getElems.map (·.raw))) (names.map (·.raw))
  | `(tactic| ltemporal_use $proof:term) => temporalUse proof
  | `(tactic| lprogress using [$terms:term,*]) => progress (terms.getElems.map (·.raw))
  | `(tactic| luntil $kind:ident using $proof:term) => do
    let guard ← match kind.getId with
      | `guard => pure true
      | `event => pure false
      | _ => throwError "expected `guard` or `event`"
    binaryTemporal false guard proof
  | `(tactic| lsince $kind:ident using $proof:term) => do
    let guard ← match kind.getId with
      | `guard => pure true
      | `event => pure false
      | _ => throwError "expected `guard` or `event`"
    binaryTemporal true guard proof

end FormalSystem.Automation.ProofMode
