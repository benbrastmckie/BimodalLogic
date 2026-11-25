/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Basic
import FormalSystem.Theorems.ProofMode.Possibility
import FormalSystem.Theorems.ProofMode.PlusModal

/-!
# Checked modal and temporal scope introduction

Selected modal guarantees become assumptions only in the body derivation. Generalized K
reconstructs their modalities, and context substitution discharges the original guarantees.
An outer Lean hypothesis retains its original object context and cannot leak into the body.
-/

namespace FormalSystem.Automation.ProofMode

open FormalSystem.Tactic.FormulaSyntax (Language)

open Lean Meta Elab Tactic

/-- The universal modalities with checked contextual introduction rules. -/
inductive Scope where
  | necessity
  | settled
  | future
  | past
  deriving BEq

/-- Formula operator associated with a scoped rule. -/
def Scope.operator : Scope → Name
  | .necessity => `box
  | .settled => `stab
  | .future => `allFuture
  | .past => `allPast

/-- The calculus's derivation-producing contextual introduction function. -/
def Scope.rule (scope : Scope) (language : Language) : MetaM Name := do
  match scope, language with
  | .necessity, .tm => return ``FormalSystem.Theorems.generalizedModalK
  | .future, .tm => return ``FormalSystem.Theorems.generalizedTemporalK
  | .past, .tm => return ``FormalSystem.Theorems.generalizedPastK
  | .necessity, .plus => return ``FormalSystem.PlusLanguage.ProofMode.generalizedModalK
  | .settled, .plus => return ``FormalSystem.PlusLanguage.ProofMode.generalizedStabK
  | .future, .plus => return ``FormalSystem.PlusLanguage.ProofMode.generalizedTemporalK
  | .past, .plus => return ``FormalSystem.PlusLanguage.ProofMode.generalizedPastK
  | .settled, .tm => throwError "settledness requires the TM⁺ language"

/-- Build an assumption-substitution environment from supplied native derivations. -/
private def contextProofEnvironment (judgment : Judgment) (proofs : Array Expr) : MetaM Expr := do
  let nilName := judgment.language.ruleName
    ``FormalSystem.Theorems.ProofMode.nilContextProofs
    ``FormalSystem.PlusLanguage.ProofMode.nilContextProofs
  let consName := judgment.language.ruleName
    ``FormalSystem.Theorems.ProofMode.consContextProofs
    ``FormalSystem.PlusLanguage.ProofMode.consContextProofs
  let mut result ← mkAppOptM nilName #[some judgment.frame, some judgment.context]
  for proof in proofs.reverse do
    result ← mkAppM consName #[proof, result]
  return result

/-- Substitute selected opaque guarantees into a derivation's assumption context. -/
def substituteProofs (judgment : Judgment) (proof : Expr)
    (assumptions : Array Expr) : MetaM Expr := do
  let environment ← contextProofEnvironment judgment assumptions
  mkAppM (judgment.language.ruleName
    ``FormalSystem.Theorems.ProofMode.substContext
    ``FormalSystem.PlusLanguage.ProofMode.substContext) #[proof, environment]

/-- Elaborate the selected guarantees, or every matching assumption when `terms` is `none`, and
check that each has the unary `operator` scope. Each result is adapted to the goal judgment. -/
def scopedGuarantees (judgment : Judgment) (operator : Name)
    (terms : Option (Array Syntax)) : TacticM (Array Expr) := do
  let mut proofs : Array Expr := #[]
  match terms with
  | none =>
    for formula in ← contextEntries judgment.context do
      if (← operatorArgs? judgment.language operator 1 formula).isSome then
        proofs := proofs.push (← assumptionProof judgment formula)
  | some terms =>
    for term in terms do
      proofs := proofs.push (← adaptProof (← elaborateProof term) judgment)
  for proof in proofs do
    let some source ← judgment? (← inferType proof)
      | throwError "expected a native derivation"
    unless (← operatorArgs? judgment.language operator 1 source.formula).isSome do
      throwError "selected guarantee must have the matching {operatorSymbol operator} scope"
  return proofs

/-- `introduceMappedScope` over already checked guarantee derivations. The rule receives
`parameters`, then the body context, body formula and body derivation. Bodies are named in the
order of `proofs`, or `h1, h2, …` when `names` is empty. -/
def introduceScopeFromProofs (operator rule : Name) (parameters proofs : Array Expr)
    (names : Array Syntax) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let some goalArgs ← operatorArgs? judgment.language operator 1 judgment.formula
    | throwError "the goal does not have the requested universal modality"
  let mut formulas : Array Expr := #[]
  for proof in proofs do
    let some source ← judgment? (← inferType proof)
      | throwError "expected a native derivation"
    let some args ← operatorArgs? judgment.language operator 1 source.formula
      | throwError "selected guarantee does not have the requested modality"
    formulas := formulas.push args[0]!
  unless names.isEmpty || names.size == formulas.size do
    throwError "expected {formulas.size} body hypothesis names in the supplied guarantee order"
  let context ← contextExpr judgment.language formulas
  let body ← mkFreshExprSyntheticOpaqueMVar
    (← derivationType judgment context goalArgs[0]!)
  let lifted ← mkAppM rule (parameters ++ #[context, goalArgs[0]!, body])
  let proof ← substituteProofs judgment lifted proofs
  unless ← isDefEq (← inferType proof) (← goal.getType) do
    throwError "contextual introduction produced an incompatible judgment"
  goal.assign proof
  let mut bodyGoal := body.mvarId!
  for i in [:formulas.size] do
    bodyGoal ← bodyGoal.withContext do
      let bodyJudgment ← requireJudgment bodyGoal
      let name := if names.isEmpty then Name.mkSimple s!"h{i + 1}" else names[i]!.getId
      nameProof bodyGoal name (← assumptionProof bodyJudgment formulas[i]!)
  replaceMainGoal [bodyGoal]

/-- Select guarantees and introduce their checked mapped-context scope. -/
def introduceMappedScope (operator rule : Name) (parameters : Array Expr)
    (terms : Option (Array Syntax)) (names : Array Syntax) : TacticM Unit :=
    withMainContext do
  let judgment ← requireJudgment (← getMainGoal)
  let proofs ← scopedGuarantees judgment operator terms
  introduceScopeFromProofs operator rule parameters proofs names

/-- Introduce a universal modality through its registered native contextual rule. -/
private def introduceScope (scope : Scope) (terms : Option (Array Syntax)) (names : Array Syntax) :
    TacticM Unit := withMainContext do
  let judgment ← requireJudgment (← getMainGoal)
  introduceMappedScope scope.operator (← scope.rule judgment.language) #[] terms names

private def modalUse (term : Syntax) (name : Option Name) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let proof ← adaptProof (← elaborateProof term) judgment
  let some source ← judgment? (← inferType proof) | throwError "expected a derivation"
  let (operator, args) ← match ← operatorArgs? judgment.language `box 1 source.formula with
    | some args => pure (`modal_t, args)
    | none =>
      if judgment.language == .plus then
        match ← operatorArgs? judgment.language `stab 1 source.formula with
        | some args => pure (`stab_t, args)
        | none => throwError "lmodal_use expected necessity or settledness"
      else throwError "lmodal_use expected necessity"
  let axiomName := if operator == `stab_t then
      ``FormalSystem.PlusLanguage.PlusAxiom.stab_t
    else judgment.language.ruleName
      ``FormalSystem.ProofSystem.Axiom.modal_t ``FormalSystem.PlusLanguage.PlusAxiom.modal_t
  let axiomWitness ← mkAppM axiomName #[args[0]!]
  let compatible ← mkAppM ``FormalSystem.ProofSystem.FrameClass.base_le #[judgment.frame]
  let implication ← formulaApp judgment.language `imp #[source.formula, args[0]!]
  let axiomProof ← mkAppM (← judgment.language.derivationRule `axiom)
    #[judgment.context, implication, axiomWitness, compatible]
  let result ← modusPonens judgment axiomProof proof
  match name with
  | some name => replaceMainGoal [← nameProof goal name result]
  | none =>
    unless ← isDefEq (← inferType result) (← goal.getType) do
      throwError "modal body does not match the goal; use `as name` to retain it"
    goal.assign result
    replaceMainGoal []

private def introducePossibility (settled : Bool) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let operator := if settled then `dstab else `diamond
  if settled && judgment.language != .plus then
    throwError "settled possibility requires TM⁺"
  let some _ ← operatorArgs? judgment.language operator 1 judgment.formula
    | throwError "possibility introduction expected an object possibility goal"
  let ruleName := if settled then
      ``FormalSystem.PlusLanguage.ProofMode.settledPossibilityIntro
    else judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.diamondIntro
      ``FormalSystem.PlusLanguage.ProofMode.diamondIntro
  let rule ← mkConstWithFreshMVarLevels ruleName
  replaceMainGoal (← goal.apply rule)

private def possibilityCases (term : Syntax) (selected : Option (Array Syntax))
    (names : Array Syntax) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let (scope, operator, conclusion) ←
    match ← operatorArgs? judgment.language `diamond 1 judgment.formula with
    | some args => pure (Scope.necessity, `diamond, args)
    | none =>
      if judgment.language != .plus then
        throwError "possibility cases require a possibility conclusion"
      let some args ← operatorArgs? judgment.language `dstab 1 judgment.formula
        | throwError "possibility cases require a possibility conclusion"
      pure (Scope.settled, `dstab, args)
  let eventProof ← adaptProof (← elaborateProof term) judgment
  let some source ← judgment? (← inferType eventProof)
    | throwError "expected a native derivation"
  let some event ← operatorArgs? judgment.language operator 1 source.formula
    | throwError "expected a possibility derivation"
  let guarantees ← scopedGuarantees judgment scope.operator selected
  let mut formulas : Array Expr := #[]
  for guarantee in guarantees do
    let some source ← judgment? (← inferType guarantee)
      | throwError "expected a native derivation"
    let some args ← operatorArgs? judgment.language scope.operator 1 source.formula
      | throwError "selected guarantee must have the matching modal scope"
    formulas := formulas.push args[0]!
  unless names.size == formulas.size + 1 do
    throwError "expected an alternative name and {formulas.size} scoped assumption names"
  let context ← contextExpr judgment.language formulas
  let assumptions := #[event[0]!] ++ formulas
  let bodyContext ← contextExpr judgment.language assumptions
  let body ← mkFreshExprSyntheticOpaqueMVar
    (← derivationType judgment bodyContext conclusion[0]!)
  let deductionName := judgment.language.ruleName
    ``FormalSystem.Metalogic.Core.deductionTheorem
    ``FormalSystem.PlusLanguage.ProofMode.deductionTheorem
  let implication ← mkAppM deductionName #[context, event[0]!, conclusion[0]!, body]
  let some implicationJudgment ← judgment? (← inferType implication)
    | throwError "expected a native implication derivation"
  let lifted ← mkAppM (← scope.rule judgment.language)
    #[context, implicationJudgment.formula, implication]
  let mapping ← substituteProofs judgment lifted guarantees
  let ruleName := if scope == .settled then
      ``FormalSystem.PlusLanguage.ProofMode.settledPossibilityConsequence
    else judgment.language.ruleName
      ``FormalSystem.Theorems.ProofMode.diamondConsequence
      ``FormalSystem.PlusLanguage.ProofMode.diamondConsequence
  let proof ← mkAppM ruleName #[mapping, eventProof]
  unless ← isDefEq (← inferType proof) (← goal.getType) do
    throwError "possibility consequence produced an incompatible judgment"
  goal.assign proof
  let mut bodyGoal := body.mvarId!
  for i in [:assumptions.size] do
    bodyGoal ← bodyGoal.withContext do
      let bodyJudgment ← requireJudgment bodyGoal
      nameProof bodyGoal names[i]!.getId (← assumptionProof bodyJudgment assumptions[i]!)
  replaceMainGoal [bodyGoal]

/-- Introduce necessity/settledness scopes or their dual possibility goals. -/
syntax (name := lmodalIntro) "lmodal_intro" ppSpace colGt ident
  (ppSpace "using" ppSpace "[" term,* "]")? (ppSpace "as" (ppSpace colGt ident)+)? : tactic

/-- Apply modal T to a necessity or settledness derivation. -/
syntax (name := lmodalUse) "lmodal_use" ppSpace colGt term
  (ppSpace "as" ppSpace colGt ident)? : tactic

/-- Open a possible alternative, carrying only guarantees with the matching modal scope. -/
syntax (name := lmodalCases) "lmodal_cases" ppSpace colGt term
  (ppSpace "using" ppSpace "[" term,* "]")? ppSpace "as" (ppSpace colGt ident)+ : tactic

/-- Introduce strict universal future or past through its generalized K rule. -/
syntax (name := ltemporalIntro) "ltemporal_intro" ppSpace colGt ident
  (ppSpace "using" ppSpace "[" term,* "]")? (ppSpace "as" (ppSpace colGt ident)+)? : tactic

elab_rules : tactic
  | `(tactic| lmodal_intro $kind:ident $[using [$terms:term,*]]? $[as $names:ident*]?) => do
    if kind.getId == `possibility || kind.getId == `settled_possibility then
      unless terms.isNone && names.isNone do
        throwError "possibility introduction takes no scoped hypothesis list"
      introducePossibility (kind.getId == `settled_possibility)
      return
    let scope ← match kind.getId with
      | `necessity => pure Scope.necessity
      | `settled => pure Scope.settled
      | _ => throwError "expected `necessity` or `settled`"
    introduceScope scope (terms.map (·.getElems.map (·.raw)))
      (names.map (·.map (·.raw)) |>.getD #[])
  | `(tactic| ltemporal_intro $kind:ident $[using [$terms:term,*]]? $[as $names:ident*]?) => do
    let scope ← match kind.getId with
      | `future => pure Scope.future
      | `past => pure Scope.past
      | _ => throwError "expected `future` or `past`"
    introduceScope scope (terms.map (·.getElems.map (·.raw)))
      (names.map (·.map (·.raw)) |>.getD #[])
  | `(tactic| lmodal_use $proof:term $[as $name:ident]?) =>
    modalUse proof (name.map (·.getId))
  | `(tactic| lmodal_cases $proof:term $[using [$terms:term,*]]? as $names:ident*) =>
    possibilityCases proof (terms.map (·.getElems.map (·.raw))) (names.map (·.raw))

end FormalSystem.Automation.ProofMode
