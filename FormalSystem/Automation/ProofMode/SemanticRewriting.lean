/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.SemanticMeta
import FormalSystem.Automation.ProofMode.Simplification

/-!
# Indexed semantic rewriting

Formula positions and budgets are shared with the native planner. Certificates use the
pointed semantic kernel; explicit quantified evidence is matched against its actual demand.
A fact at one point is never generalized to another point. Provider bodies remain opaque.
-/

namespace FormalSystem.Automation.ProofMode.Semantic

open Lean Meta Elab Tactic
open FormalSystem.Semantics

/-- A semantic rewrite schema, inspected through its statement. -/
structure Evidence where
  /-- Once-elaborated provider. -/
  proof : Expr
  /-- First formula of the relation. -/
  left : Expr
  /-- Second formula of the relation. -/
  right : Expr
  /-- Equivalence provides both orientations. -/
  equivalence : Bool
  /-- Object-language scope hints, used only for choosing the conditional Next adapter. -/
  word : Array Name := #[]

private def relation? (type : Expr) : MetaM (Option (TruthJudgment × TruthJudgment × Bool)) := do
  let type ← instantiateMVars type
  if type.isAppOfArity ``Iff 2 then
    let args := type.getAppArgs
    let some a ← truthJudgment? args[0]! | return none
    let some b ← truthJudgment? args[1]! | return none
    return some (a, b, true)
  if let .forallE _ domain body _ := type then
    unless body.hasLooseBVars do
      let some a ← truthJudgment? domain | return none
      let some b ← truthJudgment? body | return none
      return some (a, b, false)
  return none

/-- Instantiate only schema binders, stopping before a pointed truth or leaf relation. -/
private def instantiateSchema (proof : Expr) : MetaM (Expr × Expr × Array Expr) := do
  let mut value := proof
  let mut type ← inferType value
  let mut parameters := #[]
  for _ in [:64] do
    if (← truthJudgment? type).isSome || (← relation? type).isSome then
      return (value, type, ← proofParameters proof parameters)
    let type' ← whnfR type
    let .forallE _ domain body _ := type'
      | throwError "expected indexed semantic truth, implication, or equivalence"
    let argument ← mkFreshExprMVar domain
    parameters := parameters.push argument
    value := mkApp value argument
    type := body.instantiate1 argument
  throwError "semantic rule telescope exceeded 64 parameters"

private def formulaRelation (j : TruthJudgment) : MetaM (Expr × Expr × Bool × Array Name) := do
  let mut formula := j.formula
  let mut word := #[]
  for _ in [:64] do
    let mut found := false
    for op in #[`box, `stab, `allFuture, `allPast, `next, `prev] do
      if op == `stab && j.language != .plus then continue
      if let some args ← rigidOperatorArgs? j.language op 1 formula then
        word := word.push op
        formula := args[0]!
        found := true
        break
    unless found do break
  if let some args ← rigidOperatorArgs? j.language `and 2 formula then
    if let some ab ← rigidOperatorArgs? j.language `imp 2 args[0]! then
      if let some ba ← rigidOperatorArgs? j.language `imp 2 args[1]! then
        let saved ← saveState
        let holes ← getMVars formula
        let converse ← isDefEq ab[0]! ba[1]!
        let converse := converse && (← isDefEq ab[1]! ba[0]!)
        let changed ← holes.anyM (·.isAssigned)
        saved.restore
        if converse && !changed then return (ab[0]!, ab[1]!, true, word)
  let some args ← rigidOperatorArgs? j.language `imp 2 formula
    | throwError "semantic rewrite formula is not an implication or equivalence"
  return (args[0]!, args[1]!, false, word)

/-- Read a semantic schema, retaining its relation and explicit scope word. -/
def readEvidence (proof : Expr) : MetaM Evidence := do
  let (_, type, _) ← instantiateSchema proof
  if let some (a, b, iff_) ← relation? type then
    unless ← samePoint a b do throwError "rewrite relation changes its semantic point"
    return ⟨proof, a.formula, b.formula, iff_, #[]⟩
  let some j ← truthJudgment? type | throwError "expected a semantic rewrite statement"
  let (a, b, iff_, word) ← formulaRelation j
  return ⟨proof, a, b, iff_, word⟩

private def stepApp (j : TruthJudgment) (name : Name) (args : Array Expr := #[]) : MetaM Expr := do
  let specialized ← mkAppOptM name #[some (mkConst j.language.formulaNamespace),
    some j.truthEnvironment, some j.frame, some j.model]
  let mut specialized := specialized
  for _ in [:8] do
    let .forallE _ domain _ info ← whnf (← inferType specialized) | break
    if info != .instImplicit then break
    specialized := mkApp specialized (← synthInstance domain)
  let result ← mkAppM' specialized args
  let expected ← mkAppOptM ``ProofModeRules.Step
    #[some (mkConst j.language.formulaNamespace), some j.truthEnvironment,
      some j.frame, some j.model]
  unless ← isDefEq (← inferType result) expected do
    throwError "semantic position belongs to a different model or truth environment"
  return result

private def positionStep (j : TruthJudgment) (p : Position) (cover : Bool) : MetaM Expr := do
  let left := p.arguments[0]!
  let right := p.arguments.getD 1 left
  let (name, args) ← match p.name with
    | `impLeft => pure (``ProofModeRules.Step.impLeft, #[right])
    | `impRight => pure (``ProofModeRules.Step.impRight, #[left])
    | `negBody => pure (``ProofModeRules.Step.negBody, #[])
    | `andLeft => pure (``ProofModeRules.Step.andLeft, #[right])
    | `andRight => pure (``ProofModeRules.Step.andRight, #[left])
    | `orLeft => pure (``ProofModeRules.Step.orLeft, #[right])
    | `orRight => pure (``ProofModeRules.Step.orRight, #[left])
    | `boxBody => pure (``ProofModeRules.Step.box, #[])
    | `stabilityBody => pure (``ProofModeRules.Step.stab, #[])
    | `possibilityBody => pure (``ProofModeRules.Step.diamondBody, #[])
    | `settledPossibilityBody => pure (``ProofModeRules.Step.dstabBody, #[])
    | `futureBody => pure (``ProofModeRules.Step.future, #[])
    | `pastBody => pure (``ProofModeRules.Step.past, #[])
    | `futureEvent => pure (``ProofModeRules.Step.someFutureEvent, #[])
    | `pastEvent => pure (``ProofModeRules.Step.somePastEvent, #[])
    | `untilGuard => pure (``ProofModeRules.Step.untilGuard, #[right])
    | `untilEvent => pure (``ProofModeRules.Step.untilEvent, #[left])
    | `sinceGuard => pure (``ProofModeRules.Step.sinceGuard, #[right])
    | `sinceEvent => pure (``ProofModeRules.Step.sinceEvent, #[left])
    | `nextBody => pure (if cover then ``ProofModeRules.Step.nextCover
        else ``ProofModeRules.Step.nextFuture, #[])
    | `prevBody => pure (if cover then ``ProofModeRules.Step.prevCover
        else ``ProofModeRules.Step.prevPast, #[])
    | _ => throwError "unsupported semantic position {p.name}"
  stepApp j name args

private def semanticPath (j : TruthJudgment) (path : Array Position) (word : Array Name) :
    MetaM (Expr × Bool) := do
  let mut step ← stepApp j ``ProofModeRules.Step.identity
  let mut flips := false
  let mut hints : Array Bool := #[]
  let mut scope := 0
  for p in path do
    let cover := (p.name == `nextBody && word[scope]? == some `next) ||
      (p.name == `prevBody && word[scope]? == some `prev)
    hints := hints.push cover
    if #[`boxBody, `stabilityBody, `possibilityBody, `settledPossibilityBody, `futureBody,
        `pastBody, `futureEvent, `pastEvent, `untilGuard, `untilEvent, `sinceGuard,
        `sinceEvent, `nextBody, `prevBody].contains p.name then scope := scope + 1
    if p.name == `impLeft || p.name == `negBody then flips := !flips
  for i in (List.range path.size).reverse do
    step ← mkAppM ``ProofModeRules.Step.comp #[← positionStep j path[i]! hints[i]!, step]
  return (step, flips)

/-- Convert an object-language scoped relation to a Lean family using only its truth clauses. -/
private partial def truthRelationFamily (j : TruthJudgment) (proof : Expr)
    (fuel : Nat := 64) : MetaM Expr := do
  if fuel == 0 then throwError "semantic evidence scope exceeds 64 operators"
  for op in #[`box, `stab, `allFuture, `allPast, `next, `prev] do
    if op == `stab && j.language != .plus then continue
    if let some args ← rigidOperatorArgs? j.language op 1 j.formula then
      if op == `next || op == `prev then
        let carrier ← mkAppM ``FormalSystem.Semantics.TemporalOrder.carrier
          #[← mkAppM ``FormalSystem.Semantics.TaskFrame.Duration #[j.frame]]
        return ← withLocalDeclD `s carrier fun s => do
          let order ← mkAppM ``CovBy (if op == `next then #[j.time, s] else #[s, j.time])
          withLocalDeclD `hCover order fun h => do
            let body ← semanticApp j
              (if op == `next then ``ProofModeRules.next_at else ``ProofModeRules.prev_at)
              #[h, proof]
            mkLambdaFVars #[s, h]
              (← truthRelationFamily { j with formula := args[0]!, time := s } body (fuel - 1))
      let clause ← clauseIff j op args
      let family ← mkAppM ``Iff.mp #[clause, proof]
      let count := if op == `box then 1 else 2
      return ← forallBoundedTelescope (← inferType family) (some count) fun vars bodyType => do
        let some bodyJudgment ← truthJudgment? bodyType
          | throwError "scope clause does not retain a pointed truth body"
        let converted ← truthRelationFamily bodyJudgment (mkAppN family vars) (fuel - 1)
        mkLambdaFVars vars converted
  if let some args ← rigidOperatorArgs? j.language `and 2 j.formula then
    let pair ← mkAppM ``Iff.mp #[← clauseIff j `and args, proof]
    let left ← mkAppM ``And.left #[pair]
    let right ← mkAppM ``And.right #[pair]
    let some a ← truthJudgment? (← inferType left) | throwError "expected truth of implication"
    let some b ← truthJudgment? (← inferType right) | throwError "expected truth of implication"
    return ← mkAppM ``Iff.intro #[← truthRelationFamily a left (fuel - 1),
      ← truthRelationFamily b right (fuel - 1)]
  let some args ← rigidOperatorArgs? j.language `imp 2 j.formula
    | throwError "expected an object-language implication"
  mkAppM ``Iff.mp #[← clauseIff j `imp args, proof]

private partial def reverseFamily (proof : Expr) (fuel : Nat := 64) : MetaM Expr := do
  if fuel == 0 then throwError "semantic equivalence family exceeds 64 binders"
  let type ← inferType proof
  if let some (_, _, iff_) ← relation? type then
    unless iff_ do throwError "cannot reverse a one-way semantic relation"
    return ← mkAppM ``Iff.symm #[proof]
  let .forallE name domain _ kind ← whnfR type
    | throwError "expected a quantified semantic equivalence"
  withLocalDecl name kind domain fun bound => do
    mkLambdaFVars #[bound] (← reverseFamily (mkApp proof bound) (fuel - 1))

private def normalizePointRelation (proof : Expr) (expected : Expr) : MetaM (Option Expr) := do
  let some (a, b, iff_) ← relation? (← inferType proof) | return none
  let some (x, y, wantedIff) ← relation? expected | return none
  unless ← samePoint a x do return none
  unless ← samePoint b y do return none
  unless ← isDefEq a.formula x.formula do return none
  unless ← isDefEq b.formula y.formula do return none
  if wantedIff && !iff_ then return none
  let result ← if iff_ && !wantedIff then mkAppM ``Iff.mp #[proof] else pure proof
  unless ← isDefEq (← inferType result) expected do return none
  return some result

private partial def alignFamily (proof expected : Expr) (fuel : Nat := 64) : MetaM Expr := do
  if fuel == 0 then throwError "semantic family matching exceeds 64 binders"
  let expected ← withTransparency .default (whnf expected)
  if (← relation? expected).isSome then
    let some result ← normalizePointRelation proof expected
      | throwError "semantic relation has different evaluation indices or formulas"
    return result
  let .forallE name domain body kind := expected
    | throwError "expected a semantic relation or quantified demand"
  let .forallE _ sourceDomain _ _ ← whnfR (← inferType proof)
    | throwError "point evidence cannot discharge a quantified scope"
  unless ← isDefEq domain sourceDomain do throwError "different semantic scope domains"
  withLocalDecl name kind domain fun bound => do
    mkLambdaFVars #[bound]
      (← alignFamily (mkApp proof bound) (body.instantiate1 bound) (fuel - 1))

private def resolveSemanticParameters (parameters : Array Expr) : MetaM (List MVarId) := do
  let mut pending := []
  for parameter in parameters do
    if !parameter.isMVar || (← parameter.mvarId!.isAssigned) then continue
    let type ← instantiateMVars (← inferType parameter)
    if type.hasExprMVar then throwError "semantic premise has undetermined data parameters"
    unless ← isProp type do throwError "supply the semantic rule's remaining data arguments"
    for localDecl in ← getLCtx do
      if localDecl.isImplementationDetail then continue
      let saved ← saveState
      if ← indexedDefEq type localDecl.type then
        parameter.mvarId!.assign localDecl.toExpr
        break
      saved.restore
    if ← parameter.mvarId!.isAssigned then continue
    if type.isAppOf ``LE.le then
      pending := pending ++ (← resolveRuleParameters #[parameter])
    else
      parameter.mvarId!.setKind .syntheticOpaque
      pending := pending ++ [parameter.mvarId!]
  return pending

private def matchPointParameters (parameters : Array Expr) (source target : TruthJudgment) :
    MetaM Unit := do
  let sourcePoint ← pointExpr source
  let targetPoint ← pointExpr target
  for parameter in parameters do
    if !parameter.isMVar || (← parameter.mvarId!.isAssigned) then continue
    let type ← inferType parameter
    unless type.isAppOf ``ProofModeRules.Point do continue
    let saved ← saveState
    let same ← isDefEq sourcePoint parameter
    let assigned ← parameter.mvarId!.isAssigned
    saved.restore
    if same && !assigned && (← isDefEq type (← inferType targetPoint)) then
      parameter.mvarId!.assign targetPoint

/-- Match only the explicitly supplied family, introducing its required scope binders.
Side conditions use exact local evidence; unmatched data are never chosen from the context. -/
private partial def demandProof (j : TruthJudgment) (e : Evidence) (expected : Expr)
    (reverse : Bool) (expose : Bool) (fuel : Nat := 64) : MetaM (Expr × List MVarId) := do
  if fuel == 0 then throwError "semantic demand exceeds 64 binders"
  let trial ← saveState
  let mut failure : Option Exception := none
  try
    let (raw, type, parameters) ← instantiateSchema e.proof
    let expectedHead ← withTransparency .default (whnf expected)
    if let some (target, _, _) ← relation? expectedHead then
      if let some source ← truthJudgment? type then
        matchPointParameters parameters source target
      else if let some (source, _, _) ← relation? type then
        matchPointParameters parameters source target
    let proof ← if let some source ← truthJudgment? type then
        unless source.language == j.language do throwError "different semantic formula language"
        truthRelationFamily source raw
      else pure raw
    let proof ← if reverse && e.equivalence then reverseFamily proof else pure proof
    let proof ← alignFamily proof expected
    let pending ← resolveSemanticParameters parameters
    unless expose || pending.isEmpty do throwError "semantic rule requires side conditions"
    checkRewriteHoles proof pending
    return (proof, pending)
  catch error =>
    trace[proofMode.rewrite] "semantic demand mismatch: {error.toMessageData}"
    trial.restore
    failure := some error
  let some cause := failure | throwError "semantic demand failed without a diagnostic"
  let expected' ← withTransparency .default (whnf expected)
  if (← relation? expected').isSome then throw cause
  let .forallE name domain body kind := expected' | throw cause
  withLocalDecl name kind domain fun bound => do
    let (proof, pending) ← demandProof j e (body.instantiate1 bound) reverse expose (fuel - 1)
    unless pending.isEmpty do
      throwError "dependent scope side conditions need an explicit quantified certificate"
    return (← mkLambdaFVars #[bound] proof, [])

private partial def presentDemand (j : TruthJudgment) (type : Expr)
    (fuel : Nat := 128) : MetaM Expr := do
  if fuel == 0 then throwError "semantic demand presentation exhausted its binder budget"
  if let some pointed ← truthJudgment? type then
    let shown := { pointed with
      direct := j.direct
      history := ← presentPointIndex pointed.history
      time := ← presentPointIndex pointed.time
      environment := ← presentPointIndex pointed.environment }
    return ← truthType shown pointed.formula
  let type ← withTransparency .default (whnf type)
  for op in #[``Iff, ``And, ``Or] do
    if type.isAppOfArity op 2 then
      let args := type.getAppArgs
      return ← mkAppM op #[← presentDemand j args[0]! (fuel - 1),
        ← presentDemand j args[1]! (fuel - 1)]
  if let .forallE name domain body kind := type then
    let domain ← if (← truthJudgment? domain).isSome then presentDemand j domain (fuel - 1)
      else presentPointIndex domain
    return ← withLocalDecl name kind domain fun bound => do
      mkForallFVars #[bound] (← presentDemand j (body.instantiate1 bound) (fuel - 1))
  presentPointIndex type

/-- Build a whole-formula semantic rewrite certificate using the shared formula positions. -/
def semanticCertificate (j : TruthJudgment) (e : Evidence) (occurrence : Occurrence)
    (goalRole symm expose : Bool) : MetaM (Expr × Expr × List MVarId) := do
  let old := if symm then e.right else e.left
  let new := if symm then e.left else e.right
  unless ← isDefEq occurrence.formula old do throwError "selected occurrence does not match"
  let replacement ← instantiateMVars (← occurrence.replace j.language new)
  if replacement.hasExprMVar then throwError "semantic rewrite leaves undetermined formula data"
  let (step, flips) ← semanticPath j occurrence.path e.word
  let reverse := (goalRole != flips) != symm
  if reverse && !e.equivalence then throwError "one-way semantic rule has the wrong direction"
  let point ← pointExpr j
  let predicate ← if e.equivalence then
      semanticApp j ``ProofModeRules.IffAt #[j.model, old, new]
    else
      semanticApp j ``ProofModeRules.OrientedAt
        #[j.model, toExpr flips, if goalRole then new else old, if goalRole then old else new]
  let expected ← mkAppM ``ProofModeRules.Step.demand #[step, predicate, point]
  let dischargeState ← saveState
  let (demand, pending) ← try demandProof j e expected symm expose catch error =>
    dischargeState.restore
    unless expose do throw error
    let shown ← presentDemand j expected
    unless ← isDefEq shown expected do throwError "semantic demand presentation changed its type"
    let needed ← mkFreshExprSyntheticOpaqueMVar shown
    pure (needed, [needed.mvarId!])
  let name := if e.equivalence then
      (if goalRole then ``ProofModeRules.Step.rewriteGoalOfIff
        else ``ProofModeRules.Step.rewriteFactOfIff)
    else if goalRole then ``ProofModeRules.Step.rewriteGoal else ``ProofModeRules.Step.rewriteFact
  let certificate ← mkAppOptM name #[some (mkConst j.language.formulaNamespace),
    some j.truthEnvironment, some j.frame, some j.model, some step, some old, some new,
    some point, some demand]
  let expectedArrow ← mkArrow (← truthType j (if goalRole then replacement else j.formula))
    (← truthType j (if goalRole then j.formula else replacement))
  unless ← isDefEq (← inferType certificate) expectedArrow do
    throwError "semantic position certificate does not prove the planned indexed transformation"
  return (certificate, replacement, pending)

private def chooseOccurrence (j : TruthJudgment) (e : Evidence) (symm : Bool)
    (path : Option (Array Name)) : MetaM Occurrence := do
  if let some path := path then return ← selectOccurrence j.language j.formula path
  let old := if symm then e.right else e.left
  let mut found := #[]
  for occurrence in ← formulaOccurrences j.language j.formula do
    let saved ← saveState
    if ← isDefEq occurrence.formula old then found := found.push occurrence
    saved.restore
  unless found.size == 1 do
    throwError "semantic rewrite has {found.size} matches; select a path from \
      {found.map fun o => o.path.map (·.name)}"
  return found[0]!

private def finishSemanticRewrite (goal : MVarId) (j : TruthJudgment)
    (certificate replacement : Expr) (pending : List MVarId) (fact : Option (Expr × Name)) :
    TacticM Unit := do
  match fact with
  | some (source, name) =>
    let result := mkApp certificate source
    checkRewriteHoles result pending
    replaceMainGoal (pending ++ [← noteTruth goal name j replacement result])
  | none =>
    let next ← mkFreshExprSyntheticOpaqueMVar (← truthType j replacement)
    checkRewriteHoles certificate pending
    goal.assign (mkApp certificate next)
    replaceMainGoal (pending ++ [next.mvarId!])

/-- Lift formula-data equality through shared positions and the exact semantic truth predicate. -/
def semanticEqualityCertificate (j : TruthJudgment) (raw : Expr) (symm goalRole expose : Bool)
    (path : Option (Array Name)) : TacticM (Expr × Expr × List MVarId) := do
  let fake : Judgment := ⟨j.language, mkConst ``FormalSystem.ProofSystem.FrameClass.Base,
    ← contextExpr j.language #[], j.formula⟩
  let (replacement, eq, pending) ←
    formulaEqualityRewriteProof fake raw symm path (resolveParameters := resolveSemanticParameters)
  unless expose || pending.isEmpty do throwError "equality needs explicit side conditions"
  let fn ← withLocalDeclD `A (mkConst j.language.formulaNamespace) fun a => do
    mkLambdaFVars #[a] (← truthType j a)
  let typeEq ← mkAppM ``congrArg #[fn, eq]
  let certificate ← mkAppM (if goalRole then ``Eq.mpr else ``Eq.mp) #[typeEq]
  return (certificate, replacement, pending)

/-- Rewrite one semantic goal/fact transactionally, preserving its actual evaluation indices. -/
def semanticRewrite (term : Syntax) (symm : Bool) (path : Option (Array Name))
    (fact : Option (Syntax × Name)) (expose : Bool) : TacticM Unit := withMainContext do
  let saved ← saveState
  try
    let goal ← getMainGoal
    let original ← requireTruth goal
    let (j, factValue) ← match fact with
      | none => pure (original, none)
      | some (term, name) =>
        let proof ← elaborateProof term
        let some source ← truthJudgment? (← inferType proof)
          | throwError "expected an indexed semantic fact"
        pure (source, some (proof, name))
    let firstNewIndex := (← getMCtx).mvarCounter
    let raw ← elaborateProof term
    let rawParameters ← getMVars raw
    let equality ← withoutModifyingState do
      let (_, _, type) ← forallMetaTelescopeReducing (← inferType raw)
      return type.isAppOf ``Eq
    if equality then
      let (certificate, replacement, pending) ←
        semanticEqualityCertificate j raw symm fact.isNone expose path
      finishSemanticRewrite goal j certificate replacement pending factValue
      return
    let e ← readEvidence raw
    let occurrence ← chooseOccurrence j e symm path
    let (certificate, replacement, pending) ←
      semanticCertificate j e occurrence fact.isNone symm expose
    discard <| retainedRewriteParameters (rawParameters.map mkMVar) certificate firstNewIndex
    finishSemanticRewrite goal j certificate replacement pending factValue
  catch error => saved.restore; throw error

/-- Validate a semantic declaration's full telescope before recording its simp orientation. -/
def validateSemanticRewriteDeclaration (name : Name) : TermElabM Unit := withNewMCtxDepth do
  discard <| readEvidence (← mkConstWithFreshMVarLevels name)

private def registerSemanticRule (name : Syntax) (reverse : Bool) : Command.CommandElabM Unit := do
  let (resolved, native) ← Command.liftTermElabM <| withNewMCtxDepth do
    let resolved ← realizeGlobalConstNoOverloadWithInfo name
    let (_, _, type) ← forallMetaTelescopeReducing
      (← inferType (← mkConstWithFreshMVarLevels resolved))
    let native := (← FormalSystem.Automation.ProofMode.judgment? type).isSome
    unless native do validateSemanticRewriteDeclaration resolved
    return (resolved, native)
  if native then throwUnsupportedSyntax
  modifyEnv (rewriteRegistrationExt.addEntry · ⟨resolved, reverse⟩)

elab_rules : command
  | `(command| register_lrewrite $name:ident) => registerSemanticRule name false
  | `(command| register_lrewrite $name:ident reverse) => registerSemanticRule name true

@[no_fallback] elab_rules : tactic
  | `(tactic| lrewrite $[←%$reverse]? $rule:term $[(path := [$path:ident,*])]?
      $[at $fact:term as $name:ident]? $[(obligations := $mode:ident)]?) => do
    unless (← truthJudgment? (← (← getMainGoal).getType)).isSome do
      throwUnsupportedSyntax
    if let some mode := mode then
      unless mode.getId == `expose do throwError "expected obligations := expose"
    semanticRewrite rule reverse.isSome (path.map (·.getElems.map (·.getId)))
      (fact.map fun fact => (fact, name.get!.getId)) mode.isSome

end FormalSystem.Automation.ProofMode.Semantic
