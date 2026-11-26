/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Meta

/-!
# Named propositional steps for deeply embedded proofs

The commands apply native derivation-producing rules. Local names contain source-context
derivations, so a theorem from an outer scope cannot enter a smaller object context silently.
-/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic

private def start (names : Array Syntax) : TacticM Unit := withMainContext do
  let mut goal ← getMainGoal
  let judgment ← requireJudgment goal
  let formulas ← contextEntries judgment.context
  if !names.isEmpty && names.size != formulas.size then
    throwError "lstart expected {formulas.size} hypothesis names"
  for i in [:formulas.size] do
    let proof ← assumptionProof judgment formulas[i]!
    let name := if names.isEmpty then Name.mkSimple s!"h{i + 1}" else names[i]!.getId
    goal ← nameProof goal name proof
  replaceMainGoal [goal]

private def introduce (name : Name) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let some args ← operatorArgs? judgment.language.formulaType `imp 2 judgment.formula
    | throwError "lintro expected an object-language implication"
  let type ← mkConstWithFreshMVarLevels <| judgment.language.ruleName
    ``FormalSystem.Metalogic.Core.deductionTheorem
    ``FormalSystem.PlusLanguage.ProofMode.deductionTheorem
  let goals ← goal.apply type
  let [body] := goals | throwError "unexpected deduction-rule premises"
  let bodyJudgment ← requireJudgment body
  let body ← body.withContext do
    nameProof body name (← assumptionProof bodyJudgment args[0]!)
  replaceMainGoal [body]

private def exactProof (term : Syntax) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let proof ← elaborateProof term
  let proof ← adaptProof proof judgment
  unless ← isDefEq (← inferType proof) (← goal.getType) do
    throwError "the derivation does not prove the current object-language conclusion"
  goal.assign proof
  replaceMainGoal []

/-- Apply a once-elaborated native theorem; leave data parameters inferable from its premises.
Only holes created since `firstNewIndex` become new goals. Proposition and native derivation
premises come first, followed by object implications and then undetermined data parameters.

`firstNewIndex` MUST be snapshotted from `(← getMCtx).mvarCounter` BEFORE `proof` is elaborated.
The goal-partitioning loop below drops every metavariable whose declaration index is below
`firstNewIndex`, and elaborating the proof term is what creates the rule's own parameter
metavariables. A counter read AFTER elaboration therefore sits above all of them, so every
parameter metavariable is filtered out, none becomes a goal, and the surrounding `by` block fails
later with an opaque placeholder-synthesis error rather than at this call. `applyProof` below is
the in-tree caller that reads the counter in the required order. -/
def applyDerivationProof (proof : Expr) (firstNewIndex : Nat) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let (parameters, binders, type) ← forallMetaTelescopeReducing (← inferType proof)
  let allParameters ← proofParameters proof parameters
  let mut proof := mkAppN proof parameters
  let some source ← judgment? type | throwError "lapply expected a derivation-producing theorem"
  let mut conclusion := source.formula
  let mut antecedents : Array Expr := #[]
  let mut matched := false
  for _ in [:64] do
    if ← isDefEq conclusion judgment.formula then
      matched := true
      break
    let some args ← operatorArgs? judgment.language.formulaType `imp 2 conclusion
      | throwError "lapply conclusion does not match the goal"
    antecedents := antecedents.push args[0]!
    conclusion := args[1]!
  unless matched do throwError "lapply exceeded the implication-chain limit"
  proof ← adaptProof proof judgment
  let mut premises : Array MVarId := #[]
  for antecedent in antecedents do
    let premise ← mkFreshExprSyntheticOpaqueMVar
      (← derivationType judgment judgment.context antecedent)
    proof ← modusPonens judgment proof premise
    premises := premises.push premise.mvarId!
  -- Defensive invariant check with no constructible trigger from user syntax: once the
  -- implication chain above has matched the conclusion against `judgment.formula` and
  -- `adaptProof` has aligned frame class, object language and context, the two types agree by
  -- construction. A frame-class mismatch -- the nearest candidate trigger -- is rejected one
  -- step earlier by `adaptProof` with "different frame classes; supply an explicitly lifted
  -- derivation" (measured). Hence no `#guard_msgs` pin for this arm.
  unless ← isDefEq (← inferType proof) (← goal.getType) do
    throwError "the applied rule produced an incompatible judgment"
  for i in [:parameters.size] do
    if binders[i]!.isInstImplicit && !(← parameters[i]!.mvarId!.isAssigned) then
      let instanceGoal := parameters[i]!.mvarId!
      let instanceType ← instanceGoal.getType
      let message := m!"lapply could not synthesize the required instance {instanceType}"
      unless ← Term.synthesizeInstMVarCore instanceGoal (extraErrorMsg? := some message) do
        throwError message
  goal.assign proof
  let mut proofGoals : List MVarId := []
  let mut dataGoals : List MVarId := []
  for parameter in allParameters do
    if !parameter.isMVar || (← parameter.mvarId!.isAssigned) then continue
    let id := parameter.mvarId!
    if (← id.getDecl).index < firstNewIndex then continue
    let type ← inferType parameter
    if (← isProp type) || (← judgment? type).isSome then
      id.setKind .syntheticOpaque
      proofGoals := proofGoals ++ [id]
    else
      id.setKind .natural
      dataGoals := dataGoals ++ [id]
  replaceMainGoal (proofGoals ++ premises.toList ++ dataGoals)

private def applyProof (term : Syntax) : TacticM Unit := withMainContext do
  let saved ← saveState
  try
    let firstNewIndex := (← getMCtx).mvarCounter
    applyDerivationProof (← elaborateProof term) firstNewIndex
  catch error => saved.restore; throw error

private def splitConjunction : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let some _ ← operatorArgs? judgment.language.formulaType `and 2 judgment.formula
    | throwError "lsplit expected an object-language conjunction"
  let rule ← mkConstWithFreshMVarLevels <| judgment.language.ruleName
    ``FormalSystem.Theorems.Combinators.andIntro
    ``FormalSystem.PlusLanguage.ProofMode.andIntro
  replaceMainGoal (← goal.apply rule)

private def haveProof (name : Name) (formulaTerm : Syntax)
    (proofTerm : Option Syntax) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let formula ← Term.elabTerm formulaTerm (some (mkConst judgment.language.formulaNamespace))
  let proofGoal ← mkFreshExprSyntheticOpaqueMVar
    (← derivationType judgment judgment.context formula)
  let context ← mkAppM ``List.cons #[formula, judgment.context]
  let continuation ← mkFreshExprSyntheticOpaqueMVar
    (← derivationType judgment context judgment.formula)
  let proof ← mkAppM (judgment.language.ruleName
    ``FormalSystem.Theorems.ProofMode.cut ``FormalSystem.PlusLanguage.ProofMode.cut)
    #[proofGoal, continuation]
  goal.assign proof
  let continuationGoal ← continuation.mvarId!.withContext do
    let continuationJudgment ← requireJudgment continuation.mvarId!
    nameProof continuation.mvarId! name (← assumptionProof continuationJudgment formula)
  match proofTerm with
  | none => replaceMainGoal [proofGoal.mvarId!, continuationGoal]
  | some term =>
    let value ← adaptProof (← elaborateProof term) { judgment with formula }
    unless ← isDefEq (← inferType value) (← inferType proofGoal) do
      throwError "the supplied derivation does not prove the intermediate assertion"
    proofGoal.mvarId!.assign value
    replaceMainGoal [continuationGoal]

private def casesProof (term : Syntax) (leftName rightName : Name) : TacticM Unit :=
    withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let proof ← adaptProof (← elaborateProof term) judgment
  let some source ← judgment? (← inferType proof) | throwError "expected a derivation"
  if let some _ ← operatorArgs? judgment.language.formulaType `and 2 source.formula then
    let left ← mkAppM (judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.andFst
      ``FormalSystem.PlusLanguage.ProofMode.andFst) #[proof]
    let right ← mkAppM (judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.andSnd
      ``FormalSystem.PlusLanguage.ProofMode.andSnd) #[proof]
    let goal ← nameProof goal leftName left
    replaceMainGoal [← nameProof goal rightName right]
  else if let some args ← operatorArgs? judgment.language.formulaType `or 2 source.formula then
    let leftContext ← mkAppM ``List.cons #[args[0]!, judgment.context]
    let rightContext ← mkAppM ``List.cons #[args[1]!, judgment.context]
    let left ← mkFreshExprSyntheticOpaqueMVar
      (← derivationType judgment leftContext judgment.formula)
    let right ← mkFreshExprSyntheticOpaqueMVar
      (← derivationType judgment rightContext judgment.formula)
    let result ← mkAppM (judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.orCases
      ``FormalSystem.PlusLanguage.ProofMode.orCases) #[proof, left, right]
    goal.assign result
    let leftGoal ← left.mvarId!.withContext do
      nameProof left.mvarId! leftName (← assumptionProof (← requireJudgment left.mvarId!) args[0]!)
    let rightGoal ← right.mvarId!.withContext do
      nameProof right.mvarId! rightName
        (← assumptionProof (← requireJudgment right.mvarId!) args[1]!)
    replaceMainGoal [leftGoal, rightGoal]
  else
    throwError "lcases expected an object conjunction or disjunction"

private def introduceDisjunction (left : Bool) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let some _ ← operatorArgs? judgment.language.formulaType `or 2 judgment.formula
    | throwError "expected an object disjunction"
  let ruleName := if left then judgment.language.ruleName
      ``FormalSystem.Theorems.Propositional.orIntroL
      ``FormalSystem.PlusLanguage.ProofMode.orIntroL
    else judgment.language.ruleName ``FormalSystem.Theorems.Propositional.orIntroR
      ``FormalSystem.PlusLanguage.ProofMode.orIntroR
  replaceMainGoal (← goal.apply (← mkConstWithFreshMVarLevels ruleName))

/-- Name the explicit assumptions in a native derivation context. -/
syntax (name := lstart) "lstart" (ppSpace colGt ident)* : tactic

/-- Introduce an object implication through the checked deduction theorem. -/
syntax (name := lintro) "lintro" ppSpace colGt ident : tactic

/-- Close a native derivation goal using an existing derivation and checked weakening. -/
syntax (name := lexact) "lexact" ppSpace colGt term : tactic

/-- Apply an opaque derivation statement, generating native derivation premises. -/
syntax (name := lapply) "lapply" ppSpace colGt term : tactic

/-- Split an object conjunction through its derived introduction rule. -/
syntax (name := lsplit) "lsplit" : tactic

/-- Establish a named intermediate assertion and continue by checked cut. -/
syntax (name := lhave) "lhave" ppSpace colGt ident " : " term (" := " term)? : tactic

/-- Decompose a conjunction or open every branch of a disjunction. -/
syntax (name := lcases) "lcases" ppSpace colGt term " as " ident ppSpace colGt ident : tactic

/-- Prove an object disjunction through its left alternative. -/
syntax (name := lleft) "lleft" : tactic

/-- Prove an object disjunction through its right alternative. -/
syntax (name := lright) "lright" : tactic

elab_rules : tactic
  | `(tactic| lstart $names:ident*) => start names
  | `(tactic| lintro $name:ident) => introduce name.getId
  | `(tactic| lexact $proof:term) => exactProof proof
  | `(tactic| lapply $proof:term) => applyProof proof
  | `(tactic| lsplit) => splitConjunction
  | `(tactic| lhave $name:ident : $formula:term $[:= $proof:term]?) =>
    haveProof name.getId formula (proof.map (·.raw))
  | `(tactic| lcases $proof:term as $left:ident $right:ident) =>
    casesProof proof left.getId right.getId
  | `(tactic| lleft) => introduceDisjunction true
  | `(tactic| lright) => introduceDisjunction false
end FormalSystem.Automation.ProofMode
