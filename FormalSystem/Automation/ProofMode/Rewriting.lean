/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Positions
import FormalSystem.Automation.ProofMode.Modal
import FormalSystem.Theorems.ProofMode.ScopeConversions
import Lean.Elab.Tactic.Rewrite

/-!
# Checked positional rewriting of native derivations

The planner retains the role of the target, polarity, scope demand and exact occurrence.
Replay invokes the pure congruence kernel and supplied derivations, with no inspection of a
provider body. Fact rewriting adds a new name and preserves the original object context.
-/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic
open FormalSystem.Theorems.ProofMode

initialize registerTraceClass `proofMode.rewrite

/-- A closed positional transfer plus its independently planned scope word and polarity. -/
structure PathCertificate where
  /-- Pure kernel descriptor. -/
  step : Expr
  /-- Outermost-first nonidentity demands. -/
  word : Array Name
  /-- Implication-antecedent parity. -/
  flips : Bool

private def composeSteps (outer inner : Expr) : MetaM Expr :=
  mkAppM ``Congruence.Step.comp #[outer, inner]

private def primitiveStep (j : Judgment) (tm plus : Name)
    (arguments : Array Expr := #[]) : MetaM Expr :=
  mkAppOptM (j.language.ruleName tm plus) (#[some j.frame] ++ arguments.map some)

private def negStep (j : Judgment) : MetaM Expr := do
  primitiveStep j ``Congruence.tmImpLeft ``Congruence.plusImpLeft
    #[← formulaApp j.language `bot #[]]

private def onePosition (j : Judgment) (p : Position) (exactNext : Bool) : MetaM Expr := do
  let left := p.arguments[0]!
  let right := p.arguments.getD 1 left
  match p.name with
  | `impLeft => primitiveStep j ``Congruence.tmImpLeft ``Congruence.plusImpLeft #[right]
  | `impRight => primitiveStep j ``Congruence.tmImpRight ``Congruence.plusImpRight #[left]
  | `boxBody => primitiveStep j ``Congruence.tmBox ``Congruence.plusBox
  | `stabilityBody => mkAppOptM ``Congruence.plusStability #[some j.frame]
  | `futureBody => primitiveStep j ``Congruence.tmFuture ``Congruence.plusFuture
  | `pastBody => primitiveStep j ``Congruence.tmPast ``Congruence.plusPast
  | `untilGuard =>
    primitiveStep j ``Congruence.tmUntilGuard ``Congruence.plusUntilGuard #[right]
  | `untilEvent =>
    primitiveStep j ``Congruence.tmUntilEvent ``Congruence.plusUntilEvent #[left]
  | `sinceGuard =>
    primitiveStep j ``Congruence.tmSinceGuard ``Congruence.plusSinceGuard #[right]
  | `sinceEvent =>
    primitiveStep j ``Congruence.tmSinceEvent ``Congruence.plusSinceEvent #[left]
  | `nextBody =>
    if exactNext then primitiveStep j ``Congruence.tmNext ``Congruence.plusNext
    else primitiveStep j ``Congruence.tmNextFuture ``Congruence.plusNextFuture
  | `prevBody =>
    if exactNext then primitiveStep j ``Congruence.tmPrev ``Congruence.plusPrev
    else primitiveStep j ``Congruence.tmPrevPast ``Congruence.plusPrevPast
  | `negBody => negStep j
  | `andLeft =>
    composeSteps (← negStep j)
      (← primitiveStep j ``Congruence.tmImpLeft ``Congruence.plusImpLeft
        #[← formulaApp j.language `neg #[right]])
  | `andRight =>
    composeSteps (← negStep j) (← composeSteps
      (← primitiveStep j ``Congruence.tmImpRight ``Congruence.plusImpRight #[left])
      (← negStep j))
  | `orLeft =>
    composeSteps (← primitiveStep j ``Congruence.tmImpLeft ``Congruence.plusImpLeft #[right])
      (← negStep j)
  | `orRight =>
    primitiveStep j ``Congruence.tmImpRight ``Congruence.plusImpRight
      #[← formulaApp j.language `neg #[left]]
  | `possibilityBody | `settledPossibilityBody =>
    let middle ← if p.name == `possibilityBody then
        primitiveStep j ``Congruence.tmBox ``Congruence.plusBox
      else mkAppOptM ``Congruence.plusStability #[some j.frame]
    composeSteps (← negStep j) (← composeSteps middle (← negStep j))
  | `futureEvent =>
    primitiveStep j ``Congruence.tmUntilEvent ``Congruence.plusUntilEvent
      #[← formulaApp j.language `top #[]]
  | `pastEvent =>
    primitiveStep j ``Congruence.tmSinceEvent ``Congruence.plusSinceEvent
      #[← formulaApp j.language `top #[]]
  | _ => throwError "no checked congruence for position {p.name}"

private def positionDemand (p : Position) (suggestion : Option Name) : Option Name :=
  match p.name with
  | `boxBody | `possibilityBody => some `box
  | `stabilityBody | `settledPossibilityBody => some `stab
  | `futureBody | `untilGuard | `untilEvent | `futureEvent => some `allFuture
  | `pastBody | `sinceGuard | `sinceEvent | `pastEvent => some `allPast
  | `nextBody => some (if suggestion == some `next then `next else `allFuture)
  | `prevBody => some (if suggestion == some `prev then `prev else `allPast)
  | _ => none

/-- Construct one shared native path certificate; Plus uses its native step instances. -/
def pathCertificate (j : Judgment) (path : Array Position)
    (evidenceWord : Array Name := #[]) : MetaM PathCertificate := do
  let kit ← mkAppM (j.language.ruleName ``Congruence.tmKit ``Congruence.plusKit) #[j.frame]
  let mut step ← mkAppM ``Congruence.Step.identity #[kit]
  let mut positions : Array (Position × Bool) := #[]
  let mut word := #[]
  let mut flips := false
  for p in path do
    let demand := positionDemand p (evidenceWord[word.size]?)
    positions := positions.push (p, demand == some `next || demand == some `prev)
    if let some demand := demand then word := word.push demand
    if p.name == `impLeft || p.name == `negBody then flips := !flips
  for (position, exactNext) in positions.reverse do
    step ← composeSteps (← onePosition j position exactNext) step
  return ⟨step, word, flips⟩

/-- A rule statement, never its proof body, including a possible scoped equivalence. -/
structure RewriteEvidence where
  /-- Native data supplied by the caller. -/
  proof : Expr
  /-- Original native judgment. -/
  judgment : Judgment
  /-- Unary modalities preceding the leaf implication/equivalence. -/
  word : Array Name
  /-- Left formula in the user's orientation. -/
  left : Expr
  /-- Right formula in the user's orientation. -/
  right : Expr
  /-- Whether both implication directions are available. -/
  equivalence : Bool

private def scopeOperators (language : Language) : Array Name :=
  #[`box, `allFuture, `allPast, `next, `prev] ++ if language == .plus then #[`stab] else #[]

/-- Read the outer scope word and leaf implication, retaining its actual native indices. -/
def readRewriteEvidence (proof : Expr) : MetaM RewriteEvidence := do
  let some j ← judgment? (← inferType proof)
    | throwError "lrewrite requires a formula equality or a native implication/equivalence"
  let mut current := j.formula
  let mut word := #[]
  for _ in [:64] do
    current ← instantiateMVars current
    if current.getAppFn.isMVar then
      throwError "rewrite rule has an undetermined conclusion; supply its formula parameters"
    let mut next := none
    for operator in scopeOperators j.language do
      if let some args ← rigidOperatorArgs? j.language operator 1 current then
        next := some (operator, args[0]!)
        break
    match next with
    | some (operator, body) =>
      word := word.push operator
      current := body
    | none => break
  let iffState ← saveState
  if let some args ← rigidOperatorArgs? j.language `and 2 current then
    if let some lhs ← rigidOperatorArgs? j.language `imp 2 args[0]! then
      if let some rhs ← rigidOperatorArgs? j.language `imp 2 args[1]! then
        let sourceMVars ← getMVars current
        let converse ← isDefEq lhs[0]! rhs[1]!
        let converse := converse && (← isDefEq lhs[1]! rhs[0]!)
        let changed ← sourceMVars.anyM (·.isAssigned)
        if converse && !changed then
          return ⟨proof, j, word, lhs[0]!, lhs[1]!, true⟩
  iffState.restore
  let some args ← rigidOperatorArgs? j.language `imp 2 current
    | throwError "expected an implication or a conjunction of converse implications"
  return ⟨proof, j, word, args[0]!, args[1]!, false⟩

private def wordStep (j : Judgment) (word : Array Name) : MetaM Expr := do
  let mut positions := #[]
  for operator in word do
    let names := positionNames operator
    positions := positions.push ⟨names[0]!, operator, #[j.formula], 0⟩
  return (← pathCertificate j positions word).step

private def closedRule (j : Judgment) (rule : Name) (arguments : Array Expr) : MetaM Expr := do
  let proof ← mkAppOptM rule (#[some j.frame] ++ arguments.map some)
  adaptProof proof j

private def evidenceArrow (j : Judgment) (e : RewriteEvidence)
    (reverse : Bool) : MetaM Expr := do
  if reverse && !e.equivalence then
    throwError "one-way implication has the wrong direction for this goal/fact and polarity"
  let proof ← adaptProof e.proof j
  if !e.equivalence then return proof
  let forward ← formulaApp j.language `imp #[e.left, e.right]
  let backward ← formulaApp j.language `imp #[e.right, e.left]
  let rule := if reverse then j.language.ruleName
      ``FormalSystem.Theorems.Propositional.rceImp ``FormalSystem.PlusLanguage.ProofMode.rceImp
    else j.language.ruleName
      ``FormalSystem.Theorems.Propositional.lceImp ``FormalSystem.PlusLanguage.ProofMode.lceImp
  let projection ← mkAppOptM rule #[some j.frame, some forward, some backward]
  let projected ← mkAppM ``Congruence.Step.demandMono #[← wordStep j e.word, projection]
  modusPonens j (← adaptProof projected j) proof

private def liftClosed (j : Judgment) (proof : Expr) (word : Array Name) : MetaM Expr := do
  let empty ← contextExpr j.language #[]
  let mut proof ← adaptProof proof { j with context := empty }
  for operator in word.reverse do
    let scope ← match operator with
      | `box => pure Scope.necessity
      | `stab => pure Scope.settled
      | `allFuture => pure Scope.future
      | `allPast => pure Scope.past
      | _ => throwError "closed Next/Previous necessitation needs its separate existence premise"
    let some source ← judgment? (← inferType proof) | throwError "expected a closed derivation"
    proof ← mkAppM (← scope.rule j.language) #[empty, source.formula, proof]
  adaptProof proof j

private def scopeConvert (j : Judgment) (proof : Expr) (source target : Array Name)
    (leaf : Expr) : MetaM Expr := do
  if source == target then return proof
  if source.size == 1 && target.size == 1 && source[0]! == `box then
    let rule ← match target[0]! with
      | `allFuture => pure (j.language.ruleName
          ``FormalSystem.Theorems.Perpetuity.boxToFuture
          ``FormalSystem.PlusLanguage.ProofMode.boxToFuture)
      | `allPast => pure (j.language.ruleName
          ``FormalSystem.Theorems.Perpetuity.boxToPast
          ``FormalSystem.PlusLanguage.ProofMode.boxToPast)
      | `stab => pure ``FormalSystem.PlusLanguage.ProofMode.boxToStability
      | _ => throwError "unsupported boxed scope conversion"
    return ← modusPonens j (← closedRule j rule #[leaf]) proof
  if source.size == 1 && !target.isEmpty && target.all (· == source[0]!) then
    let operator := source[0]!
    let rule ← match operator with
      | `box => pure (j.language.ruleName ``FormalSystem.ProofSystem.DerivedAxioms.modal4
          ``FormalSystem.PlusLanguage.ProofMode.boxIteration)
      | `allFuture => pure (j.language.ruleName
          ``FormalSystem.Theorems.TemporalDerived.gTransitivity
          ``FormalSystem.PlusLanguage.ProofMode.futureIteration)
      | `allPast => pure (j.language.ruleName
          ``FormalSystem.Theorems.TemporalDerived.hTransitivity
          ``FormalSystem.PlusLanguage.ProofMode.pastIteration)
      | _ => throwError "no iteration rule for the requested scope"
    let mut proof := proof
    let mut body := leaf
    for _ in [:target.size - 1] do
      proof ← modusPonens j (← closedRule j rule #[body]) proof
      body ← formulaApp j.language operator #[body]
    return proof
  throwError "missing scoped rewrite evidence: available {source}, required {target}"

private def supportedScopeConversion (source target : Array Name) : Bool :=
  source == target || (source.size == 1 && target.size == 1 && source[0]! == `box &&
    #[`allFuture, `allPast, `stab].contains target[0]!) ||
  (source.size == 1 && !target.isEmpty && target.all (· == source[0]!) &&
    #[`box, `allFuture, `allPast].contains source[0]!)

/-- Replay one selected native rewrite and return the whole-formula implication. -/
def rewriteCertificate (j : Judgment) (e : RewriteEvidence) (occurrence : Occurrence)
    (goalRole symm : Bool) (expose : Bool := false) : MetaM (Expr × Expr × List MVarId) := do
  let old := if symm then e.right else e.left
  let new := if symm then e.left else e.right
  unless ← isDefEq occurrence.formula old do
    throwError "selected occurrence does not match the rule"
  let replacement ← instantiateMVars (← occurrence.replace j.language new)
  if replacement.hasExprMVar then
    throwError "rewrite leaves an undetermined formula parameter; supply its arguments explicitly"
  let certificate ← pathCertificate j occurrence.path e.word
  let reverseOriginal := (goalRole != certificate.flips) != symm
  let a := if reverseOriginal then e.right else e.left
  let b := if reverseOriginal then e.left else e.right
  let leaf ← formulaApp j.language `imp #[a, b]
  let empty ← contextExpr j.language #[]
  let closed ← isDefEq e.judgment.context empty
  let premiseJudgment := if closed then { j with context := empty } else j
  let mut premise ← evidenceArrow premiseJudgment e reverseOriginal
  let mut obligations := []
  let mut route := "exact"
  if e.word.isEmpty && closed then
    route := "closed"
    premise ← liftClosed j premise certificate.word
  else if supportedScopeConversion e.word certificate.word then
    premise ← adaptProof (← scopeConvert premiseJudgment premise e.word certificate.word leaf) j
    if e.word != certificate.word then route := "conversion"
  else
      unless expose && !certificate.word.isEmpty do
        throwError "missing scoped rewrite evidence: \
          available {e.word}, required {certificate.word}"
      route := "exposed"
      let mut demanded := leaf
      for operator in certificate.word.reverse do
        demanded ← formulaApp j.language operator #[demanded]
      let kernelDemand ← mkAppM ``Congruence.Step.demand #[certificate.step, leaf]
      unless ← isDefEq demanded kernelDemand do throwError "scope planner/kernel demand mismatch"
      let needed ← mkFreshExprSyntheticOpaqueMVar (← derivationType j j.context demanded)
      premise := needed
      obligations := [needed.mvarId!]
  let transfer ← mkAppM ``Congruence.Step.transfer #[certificate.step, a, b]
  let result ← modusPonens j (← adaptProof transfer j) premise
  trace[proofMode.rewrite] "rule {e.proof}, path {occurrence.path.map (·.name)}, \
    demand {certificate.word}, route {route}, frame {j.frame}, \
    goal={goalRole}, reversed={reverseOriginal}, output {replacement}"
  return (result, replacement, obligations)

/-- Side conditions of a rule are solved only by exact local evidence, never proof search. -/
def resolveRuleParameters (parameters : Array Expr) : MetaM (List MVarId) := do
  let mut pending := []
  for parameter in parameters do
    if !parameter.isMVar || (← parameter.mvarId!.isAssigned) then continue
    let type ← instantiateMVars (← inferType parameter)
    if type.hasExprMVar then
      throwError "rewrite premise has undetermined parameters; supply the rule arguments"
    if ← isProp type then
      for localDecl in ← getLCtx do
        if localDecl.isImplementationDetail then continue
        let saved ← saveState
        if ← isDefEq type localDecl.type then
          parameter.mvarId!.assign localDecl.toExpr
          break
        saved.restore
    else if (← judgment? type).isNone then
      throwError "rewrite has an undetermined data parameter; supply it explicitly"
    if !(← parameter.mvarId!.isAssigned) && type.isAppOf ``LE.le then
      let arguments := type.getAppArgs
      if arguments.size >= 4 then
        let carrier ← inferType arguments[arguments.size - 1]!
        if ← isDefEq carrier (mkConst ``FormalSystem.ProofSystem.FrameClass) then
          try
            let decision ← whnf (← mkDecide type)
            if decision.isConstOf ``Bool.true then
              parameter.mvarId!.assign (← mkDecideProof type)
            else if decision.isConstOf ``Bool.false then
              throwError "incompatible concrete frame classes in rewrite rule"
          catch error =>
            -- Abstract tags are kept as obligations; a computed false gate is rejected.
            if !(← instantiateMVars type).hasFVar && !(← instantiateMVars type).hasExprMVar then
              throw error
    if !(← parameter.mvarId!.isAssigned) then
      parameter.mvarId!.setKind .syntheticOpaque
      pending := pending ++ [parameter.mvarId!]
  return pending

/-- Collect explicit telescope parameters and implicit holes inserted by term elaboration. -/
def rewriteParameters (proof : Expr) (parameters : Array Expr) : MetaM (Array Expr) :=
  proofParameters proof parameters

/-- Prepare a once-elaborated theorem by its type; derivation values remain opaque. -/
def prepareRewriteRule (proof : Expr) (j : Judgment) :
    MetaM (RewriteEvidence × Array Expr) := do
  let (parameters, _, type) ← forallMetaTelescopeReducing (← inferType proof)
  let some source ← judgment? type | throwError "expected a native rewrite rule"
  unless source.language == j.language do throwError "rewrite rule uses another object language"
  if source.frame.isMVar then discard <| isDefEq source.frame j.frame
  if source.context.isMVar then
    discard <| isDefEq source.context (← contextExpr j.language #[])
  return (← readRewriteEvidence (mkAppN proof parameters), ← rewriteParameters proof parameters)

/-- Elaborate an explicit rule term once, including its implicit premises. -/
def elaborateRewriteRule (term : Syntax) (j : Judgment) :
    TacticM (RewriteEvidence × Array Expr) := do
  prepareRewriteRule (← elaborateProof term) j

/-- Every unassigned proof hole must be represented by an explicit remaining goal. -/
def checkRewriteHoles (proof : Expr) (allowed : List MVarId) : MetaM Unit := do
  for mvarId in ← getMVars (← instantiateMVars proof) do
    unless allowed.contains mvarId do
      throwError "rewrite contains an unaccounted implicit premise; provide its evidence explicitly"

/-- Keep only live rule premises; remove this invocation's discarded elaboration jobs. -/
def retainedRewriteParameters (parameters : Array Expr) (proof : Expr)
    (firstNewIndex : Nat) : TacticM (Array Expr) := do
  let retained ← getMVars (← instantiateMVars proof)
  let mut result := #[]
  let mut discarded := []
  for parameter in parameters do
    if !parameter.isMVar || (← parameter.mvarId!.isAssigned) then continue
    let mvarId := parameter.mvarId!
    if retained.contains mvarId then result := result.push parameter
    else if (← mvarId.getDecl).index >= firstNewIndex then discarded := mvarId :: discarded
  modifyThe Term.State fun state =>
    { state with
      syntheticMVars := discarded.foldl (fun entries mvarId => entries.erase mvarId)
        state.syntheticMVars
      pendingMVars := state.pendingMVars.filter (!discarded.contains ·) }
  return result

/-- Find a unique applicable occurrence, or the first one for deterministic simplification. -/
def chooseRewriteOccurrence (j : Judgment) (e : RewriteEvidence) (symm : Bool)
    (path : Option (Array Name)) : MetaM Occurrence := do
  if let some path := path then return ← selectOccurrence j.language j.formula path
  let mut candidates : Array Occurrence := #[]
  let old := if symm then e.right else e.left
  for occurrence in ← formulaOccurrences j.language j.formula do
    let saved ← saveState
    if ← isDefEq occurrence.formula old then
      candidates := candidates.push occurrence
    saved.restore
  if candidates.isEmpty then throwError "no matching rewrite occurrence"
  if candidates.size != 1 then
    throwError "ambiguous rewrite ({candidates.size} occurrences); select a path from \
      {candidates.map fun occurrence => occurrence.path.map (·.name)}"
  return candidates[0]!

/-- Install a checked whole-formula certificate at the explicitly planned conclusion type. -/
def finishRewrite (goal : MVarId) (j : Judgment) (proof replacement : Expr)
    (pending : List MVarId) (fact : Option (Expr × Name)) : TacticM Unit := do
  if (← instantiateMVars replacement).hasExprMVar then
    throwError "rewrite leaves an undetermined formula parameter; supply the rule arguments"
  checkRewriteHoles proof pending
  match fact with
  | some (source, name) =>
    let result ← modusPonens j proof source
    let expected ← derivationType j j.context replacement
    unless ← isDefEq (← inferType result) expected do
      throwError "rewrite certificate does not prove the planned fact"
    replaceMainGoal (pending ++ [← nameProof goal name (← mkExpectedTypeHint result expected)])
  | none =>
    let next ← mkFreshExprSyntheticOpaqueMVar (← derivationType j j.context replacement)
    let result ← modusPonens j proof next
    unless ← isDefEq (← inferType result) (← goal.getType) do
      throwError "rewrite certificate does not reconstruct the original goal"
    goal.assign result
    replaceMainGoal (pending ++ [next.mvarId!])

/-- Lift a uniquely selected equality of formula data through its exact enclosing positions. -/
def formulaEqualityRewriteProof (j : Judgment) (proof : Expr) (symm : Bool)
    (path : Option (Array Name))
    (resolveParameters : Array Expr → MetaM (List MVarId) := resolveRuleParameters) :
    TacticM (Expr × Expr × List MVarId) := do
  let (parameters, _, type) ← forallMetaTelescopeReducing (← inferType proof)
  let allParameters ← rewriteParameters proof parameters
  unless type.isAppOf ``Eq do throwError "expected an equality of formula data"
  let arguments := type.getAppArgs
  unless ← isDefEq arguments[0]! (mkConst j.language.formulaNamespace) do
    throwError "expected an equality of formula data"
  let old := arguments[if symm then 2 else 1]!
  let replacement := arguments[if symm then 1 else 2]!
  let occurrence ← match path with
    | some path => selectOccurrence j.language j.formula path
    | none => do
      let mut candidates : Array Occurrence := #[]
      for occurrence in ← formulaOccurrences j.language j.formula do
        let saved ← saveState
        if ← isDefEq occurrence.formula old then candidates := candidates.push occurrence
        saved.restore
      if candidates.isEmpty then throwError "no matching equality occurrence"
      if candidates.size != 1 then
        throwError "ambiguous equality rewrite; select a path from \
          {candidates.map fun occurrence => occurrence.path.map (·.name)}"
      pure candidates[0]!
  unless ← isDefEq occurrence.formula old do
    throwError "selected occurrence does not match the equality"
  let mut formula ← instantiateMVars replacement
  if formula.hasExprMVar then throwError "equality leaves an undetermined formula parameter"
  let pending ← resolveParameters allParameters
  let mut equality := mkAppN proof parameters
  if symm then equality ← mkAppM ``Eq.symm #[equality]
  for position in occurrence.path.reverse do
    let congruence ← withLocalDeclD `A (mkConst j.language.formulaNamespace) fun value => do
      mkLambdaFVars #[value] (← position.replace j.language value)
    equality ← mkAppM ``congrArg #[congruence, equality]
    formula ← position.replace j.language formula
  return (formula, equality, pending)

private def equalityRewrite (goal : MVarId) (j : Judgment) (proof : Expr) (symm : Bool)
    (path : Option (Array Name)) (fact : Option (Expr × Name)) (expose : Bool) : TacticM Unit := do
  let (formula, equality, sideGoals) ← formulaEqualityRewriteProof j proof symm path
  unless expose || sideGoals.isEmpty do
    throwError "equality rewrite requires side conditions; use obligations := expose"
  checkRewriteHoles equality sideGoals
  let judgmentCongruence ← withLocalDeclD `A (mkConst j.language.formulaNamespace) fun value => do
    mkLambdaFVars #[value] (← derivationType j j.context value)
  let typeEquality ← mkAppM ``congrArg #[judgmentCongruence, equality]
  match fact with
  | some (source, name) =>
    let result ← mkAppM ``Eq.mp #[typeEquality, source]
    replaceMainGoal (sideGoals ++ [← nameProof goal name result])
  | none =>
    let next ← mkFreshExprSyntheticOpaqueMVar (← derivationType j j.context formula)
    goal.assign (← mkAppM ``Eq.mpr #[typeEquality, next])
    replaceMainGoal (sideGoals ++ [next.mvarId!])

/-- Apply a checked rewrite at a goal or add a rewritten fact, transactionally. -/
def nativeRewrite (term : Syntax) (symm : Bool) (path : Option (Array Name))
    (fact : Option (Syntax × Name)) (expose : Bool) : TacticM Unit := withMainContext do
  let saved ← saveState
  try
    let goal ← getMainGoal
    let goalJudgment ← requireJudgment goal
    let fact ← fact.mapM fun (term, name) => do
      let proof ← elaborateProof term
      let some j ← judgment? (← inferType proof) | throwError "expected a native fact"
      let proof ← adaptProof proof goalJudgment
      return (proof, name, j.formula)
    let j := { goalJudgment with formula := fact.map (·.2.2) |>.getD goalJudgment.formula }
    let factValue := fact.map fun (proof, name, _) => (proof, name)
    let firstNewIndex := (← getMCtx).mvarCounter
    let raw ← elaborateProof term
    let equality ← withoutModifyingState do
      let (_, _, type) ← forallMetaTelescopeReducing (← inferType raw)
      return type.isAppOf ``Eq
    if equality then
      equalityRewrite goal j raw symm path factValue expose
      return
    let (e, parameters) ← prepareRewriteRule raw j
    let occurrence ← chooseRewriteOccurrence j e symm path
    let (certificate, replacement, sideGoals) ←
      rewriteCertificate j e occurrence fact.isNone symm expose
    let parameters ← retainedRewriteParameters parameters certificate firstNewIndex
    let parameterGoals ← resolveRuleParameters parameters
    unless expose || parameterGoals.isEmpty do
      throwError "rewrite requires side conditions; supply evidence or use (obligations := expose)"
    finishRewrite goal j certificate replacement (parameterGoals ++ sideGoals) factValue
  catch error =>
    saved.restore
    throw error

/-- Rewrite through checked derivation congruence, optionally at one explicit formula path. -/
syntax (name := lrewrite) "lrewrite" (ppSpace "←")? ppSpace colGt term:max
  (ppSpace "(" &"path" " := " "[" ident,* "]" ")")?
  (ppSpace "at" ppSpace colGt term ppSpace "as" ppSpace colGt ident)?
  (ppSpace "(" &"obligations" " := " ident ")")? : tactic

elab_rules : tactic
  | `(tactic| lrewrite $[←%$reverse]? $rule:term $[(path := [$path:ident,*])]?
      $[at $fact:term as $name:ident]? $[(obligations := $mode:ident)]?) => do
    if let some mode := mode then
      unless mode.getId == `expose do throwError "expected obligations := expose"
    nativeRewrite rule reverse.isSome
      (path.map (·.getElems.map (·.getId)))
      (fact.map fun fact => (fact, name.get!.getId)) mode.isSome

/-- Validate every finite scope adapter's actual telescope at module elaboration, including
native Plus arguments. This catches runtime-builder drift without a Cartesian proof suite. -/
def validateScopeAdapters : MetaM Unit := do
  for language in #[Language.tm, Language.plus] do
    let frame := mkConst ``FormalSystem.ProofSystem.FrameClass.Base
    let plain ← formulaApp language `bot #[]
    let leaf ← if language == .plus then formulaApp language `stab #[plain] else pure plain
    let mut routes := #[(#[`box], #[`allFuture]), (#[`box], #[`allPast]),
      (#[`box], #[`box, `box]), (#[`allFuture], #[`allFuture, `allFuture]),
      (#[`allPast], #[`allPast, `allPast])]
    if language == .plus then routes := routes.push (#[`box], #[`stab])
    for (source, target) in routes do
      let mut sourceFormula := leaf
      for operator in source.reverse do
        sourceFormula ← formulaApp language operator #[sourceFormula]
      let mut targetFormula := leaf
      for operator in target.reverse do
        targetFormula ← formulaApp language operator #[targetFormula]
      let context ← contextExpr language #[sourceFormula]
      let judgment : Judgment := ⟨language, frame, context, targetFormula⟩
      let result ← scopeConvert judgment (← assumptionProof judgment sourceFormula)
        source target leaf
      unless ← isDefEq (← inferType result) (← derivationType judgment context targetFormula) do
        throwError "scope adapter has an incompatible result type: {source} to {target}"

run_elab validateScopeAdapters

/-- Check every positional builder, closed scope lift and iff projection against its planned
formula. Runtime constant arities therefore have a compile-time backstop in both languages. -/
def validateRewriteAdapters : MetaM Unit := do
  for language in #[Language.tm, Language.plus] do
    withLocalDeclD `A (mkConst language.formulaNamespace) fun a => do
      withLocalDeclD `B (mkConst language.formulaNamespace) fun b => do
        withLocalDeclD `C (mkConst language.formulaNamespace) fun c => do
          let frame := mkConst ``FormalSystem.ProofSystem.FrameClass.Base
          let context ← contextExpr language #[]
          let j : Judgment := ⟨language, frame, context, a⟩
          for operator in formulaViewOperators language do
            let names := positionNames operator
            let arguments := if names.size == 2 then #[a, c] else #[a]
            for index in [:names.size] do
              let position : Position := ⟨names[index]!, operator, arguments, index⟩
              let hints := if operator == `next || operator == `prev then
                  #[#[], #[operator]] else #[#[]]
              for hint in hints do
                let cert ← pathCertificate j #[position] hint
                let old := arguments[index]!
                let original ← position.replace language old
                let changed ← position.replace language b
                let arrow ← formulaApp language `imp #[old, b]
                let mut demand := arrow
                for scope in cert.word.reverse do
                  demand ← formulaApp language scope #[demand]
                let conclusion ← if cert.flips then
                    formulaApp language `imp #[changed, original]
                  else formulaApp language `imp #[original, changed]
                let expected ← derivationType j context
                  (← formulaApp language `imp #[demand, conclusion])
                let transfer ← mkAppM ``Congruence.Step.transfer #[cert.step, old, b]
                unless ← isDefEq (← inferType transfer) expected do
                  throwError "positional adapter has an incompatible telescope: {position.name}"
          let kit ← mkAppM (language.ruleName ``Congruence.tmKit ``Congruence.plusKit) #[frame]
          let identity ← mkAppM ``Congruence.Kit.refl #[kit, a]
          let arrow ← formulaApp language `imp #[a, a]
          let pair ← mkAppM (language.ruleName
            ``FormalSystem.Theorems.Combinators.andIntro
            ``FormalSystem.PlusLanguage.ProofMode.andIntro) #[identity, identity]
          let scopes := if language == .plus then #[`box, `allFuture, `allPast, `stab]
            else #[`box, `allFuture, `allPast]
          for scope in scopes do
            let lifted ← liftClosed j identity #[scope]
            let expected ← derivationType j context (← formulaApp language scope #[arrow])
            unless ← isDefEq (← inferType lifted) expected do
              throwError "closed scope adapter has an incompatible telescope: {scope}"
            let equivalence ← liftClosed j pair #[scope]
            let evidence ← readRewriteEvidence equivalence
            for reverse in #[false, true] do
              let projected ← evidenceArrow j evidence reverse
              unless ← isDefEq (← inferType projected) expected do
                throwError "scoped equivalence projection has an incompatible telescope: {scope}"

run_elab validateRewriteAdapters

end FormalSystem.Automation.ProofMode
