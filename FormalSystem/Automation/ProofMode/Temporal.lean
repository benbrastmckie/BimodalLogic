/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Modal
import FormalSystem.Automation.ProofMode.Rewriting
import FormalSystem.Theorems.ProofMode.Temporal
import FormalSystem.Theorems.ProofMode.PlusTemporal
import FormalSystem.Theorems.ProofMode.TemporalComposition
import FormalSystem.PlusLanguage.TemporalViews

/-!
# Scoped temporal steps for native derivations

Eventuality elimination opens an object-language derivation under the event and selected
future- or past-scoped assumptions. Deduction and generalized necessitation close that scope;
consequence or bind reconstructs the outer eventuality. No semantic time witness is introduced,
and an eventual assertion never becomes a current assertion in the caller's context.

Until and Since operations use the source calculus's guard-first, event-second constructors.
Every command applies a proved native rule; the rule's statement fixes the remaining premises.

## Commands

| Command | Native rule |
| --- | --- |
| `ltemporal_cases d using [..] keeping [..] as e h.. k..` | consequence under the event |
| `ladvance d using [..] keeping [..] as e h.. k..` | temporal bind under the event |
| `ltemporal_intro future/past using [..] keeping [..] as h.. k..` | generalized G/H K |
| `ltemporal_use d` | G/H distribution or F/P consequence |
| `lprogress using [d₁, d₂]` | `progressTrans` (unchanged) |
| `lprogress using rule` | the supplied rule, through `lapply` |
| `lprogress cases` | `progressCases`: `G(φ₁∨φ₂→Fψ)` from both cases |
| `lprogress consequence using d` | `progressConsequence` / current `leadsToConsequence` |
| `lprogress trans using d` | `progressTrans` / current `leadsToTrans` with `d` first |
| `luntil guard/event using d` | Until operand monotonicity (unchanged) |
| `luntil fold` | `untilFold`: `X e ∨ X(g ∧ U g e)` at every frame class |
| `luntil intro` | `untilIntro`: `G g` and `F e` |
| `luntil unfold d as hEvent hContinue` | `untilUnfoldCases`, integer time |
| `luntil using rule` | the supplied rule, through `lapply` |
| `ltime_reflect [as h..]` | `reflectGoal`, mapping the whole context and the conclusion |
| `ltime_reflect using d [as h]` | `reflectContext` on a fact, or `lapply` of a rule |
| `ltemporal_dual [←] view [at d as h]` | checked definitional unfolding (folding) of one view |
| `ltemporal_dual [←] using rule [at d as h]` | `lrewrite` with a native equivalence/equality |

`lsince` mirrors each `luntil` form with H/P/Y and `S`.

## Body name order

Names always list the event (cases/advance only), then the `using` guarantees in order, then
the `keeping` facts in order. Omitting `using` keeps the original automatic selection of every
matching assumption; `using []` selects none.

## `keeping`

`keeping [k]` accepts only a strict `G P` fact (future step) or `H P` fact (past step). Temporal 4
(`futureKeep`/`pastKeep`) turns it into `G(G P)`/`H(H P)` before the scope rule removes one
operator, so the body holds `G P`/`H P` again. A bare current fact is rejected: no native rule
carries it to a later point. `using` guarantees are still unwrapped exactly once.

## Frame gates

Integer-time rules requested explicitly (`unfold`, `linduction`, rules via `using`) receive their
`FrameClass.ZTime ≤ fc` premise from an exact local certificate or a decided concrete tag. An
incompatible concrete tag is rejected immediately. An abstract tag becomes an explicit goal.
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

/-- A fresh native premise at the goal's frame class and context. -/
private def premiseGoal (judgment : Judgment) (formula : Expr) : MetaM Expr := do
  mkFreshExprSyntheticOpaqueMVar (← derivationType judgment judgment.context formula)

/-- Checked TM and TM⁺ declarations of the temporal composition rules. -/
private def compositionRule (judgment : Judgment) (rule : Name) : MetaM Name := do
  let pair ← match rule with
    | `untilFold => pure (``FormalSystem.Theorems.ProofMode.untilFold,
        ``FormalSystem.PlusLanguage.ProofMode.untilFold)
    | `sinceFold => pure (``FormalSystem.Theorems.ProofMode.sinceFold,
        ``FormalSystem.PlusLanguage.ProofMode.sinceFold)
    | `untilIntro => pure (``FormalSystem.Theorems.ProofMode.untilIntro,
        ``FormalSystem.PlusLanguage.ProofMode.untilIntro)
    | `sinceIntro => pure (``FormalSystem.Theorems.ProofMode.sinceIntro,
        ``FormalSystem.PlusLanguage.ProofMode.sinceIntro)
    | `untilUnfoldCases => pure (``FormalSystem.Theorems.ProofMode.untilUnfoldCases,
        ``FormalSystem.PlusLanguage.ProofMode.untilUnfoldCases)
    | `sinceUnfoldCases => pure (``FormalSystem.Theorems.ProofMode.sinceUnfoldCases,
        ``FormalSystem.PlusLanguage.ProofMode.sinceUnfoldCases)
    | `futureKeep => pure (``FormalSystem.Theorems.ProofMode.futureKeep,
        ``FormalSystem.PlusLanguage.ProofMode.futureKeep)
    | `pastKeep => pure (``FormalSystem.Theorems.ProofMode.pastKeep,
        ``FormalSystem.PlusLanguage.ProofMode.pastKeep)
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
    | `reflectGoal => pure (``FormalSystem.Theorems.ProofMode.reflectGoal,
        ``FormalSystem.PlusLanguage.ProofMode.reflectGoal)
    | `reflectContext => pure (``FormalSystem.Theorems.ProofMode.reflectContext,
        ``FormalSystem.PlusLanguage.ProofMode.reflectContext)
    | _ => throwError "unregistered temporal composition rule {rule}"
  return judgment.language.ruleName pair.1 pair.2

/-! ## Shared scope helpers

These are public so the discrete frontend reuses the same selection and persistence policy. -/

/-- Elaborate `keeping [...]` facts. Each must derive a strict `G P` (future) or `H P` (past)
at the goal's frame class and an available context; anything else is rejected because no native
rule carries it across a time step. -/
def keptFacts (judgment : Judgment) (past : Bool) (terms : Array Syntax) :
    TacticM (Array Expr) := do
  let operator := if past then `allPast else `allFuture
  let mut result := #[]
  for term in terms do
    let proof ← adaptProof (← elaborateProof term) judgment
    let source ← proofJudgment proof
    unless (← operatorArgs? judgment.language operator 1 source.formula).isSome do
      throwError "`keeping` carries only {if past then "H" else "G"}-scoped facts; \
        {source.formula} needs its own preservation rule"
    result := result.push proof
  return result

/-- Temporal 4 on kept facts: `G P ↦ G(G P)` and `H P ↦ H(H P)`. -/
def persistKept (judgment : Judgment) (past : Bool) (kept : Array Expr) : MetaM (Array Expr) :=
  kept.mapM fun proof => do
    mkAppM (← compositionRule judgment (if past then `pastKeep else `futureKeep)) #[proof]

/-- The `FrameClass.ZTime ≤ fc` premise of an explicitly requested integer-time rule. An exact
local certificate or a decided concrete tag discharges it; an incompatible concrete tag is
rejected; an abstract tag is returned as an explicit goal. -/
def integerTimeGate (judgment : Judgment) : TacticM (Expr × List MVarId) := do
  let type ← mkAppM ``LE.le
    #[mkConst ``FormalSystem.ProofSystem.FrameClass.ZTime, judgment.frame]
  if (← instantiateMVars type).hasExprMVar then
    throwError "the frame class of the goal is undetermined"
  let gate ← mkFreshExprMVar type
  let pending ← resolveRuleParameters #[gate]
  return (gate, pending)

/-- Apply a derivation-producing rule through the existing `lapply`. The rule's statement
controls its premises. Its proposition parameters are discharged only from exact local
certificates or decided concrete frame tags; a false concrete tag is rejected, and anything
else stays an explicit goal. -/
private def applyTemporalProofCore (proof : Expr) (firstNewIndex : Nat) : TacticM Unit := do
  discard getMainGoal
  let rest := (← getGoals).drop 1
  applyDerivationProof proof firstNewIndex
  let after ← getGoals
  let fresh := after.take (after.length - rest.length)
  let mut result : List MVarId := []
  for goal in fresh do
    if ← goal.isAssigned then continue
    let type ← instantiateMVars (← goal.getType)
    if (← isProp type) && !type.hasExprMVar then
      let pending ← goal.withContext do
        resolveRuleParameters #[mkMVar goal]
      result := result ++ pending
    else
      result := result ++ [goal]
  setGoals (result ++ rest)

/-- Apply a temporal rule atomically. Capture `firstNewIndex` before elaborating the proof. -/
def applyTemporalProof (proof : Expr) (firstNewIndex : Nat) : TacticM Unit := do
  let saved ← saveState
  try applyTemporalProofCore proof firstNewIndex
  catch error => saved.restore; throw error

/-- Elaborate a temporal rule once, then apply its native premises and frame gates. -/
def applyTemporalRule (term : Syntax) : TacticM Unit := withMainContext do
  let saved ← saveState
  try
    let firstNewIndex := (← getMCtx).mvarCounter
    applyTemporalProof (← elaborateProof term) firstNewIndex
  catch error => saved.restore; throw error

/-! ## Eventuality cases, advance and universal introduction with `keeping` -/

private def eventualityCases (bind : Bool) (term : Syntax)
    (selected : Option (Array Syntax)) (keptTerms : Array Syntax) (names : Array Syntax) :
    TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let (scope, conclusion) ← temporalGoal judgment
  let eventProof ← adaptProof (← elaborateProof term) judgment
  let source ← proofJudgment eventProof
  let some eventArgs ← operatorArgs? judgment.language (existentialOperator scope) 1
      source.formula
    | throwError "the selected eventuality has the wrong time direction"
  let selectedProofs ← scopedGuarantees judgment scope.operator selected
  let past := scope == .past
  let kept ← persistKept judgment past (← keptFacts judgment past keptTerms)
  let guarantees := selectedProofs ++ kept
  let mut formulas : Array Expr := #[]
  for guarantee in guarantees do
    let source ← proofJudgment guarantee
    let some args ← operatorArgs? judgment.language scope.operator 1 source.formula
      | throwError "selected guarantee must have the matching universal time scope"
    formulas := formulas.push args[0]!
  unless names.size == formulas.size + 1 do
    throwError "expected an event name and {formulas.size} scoped assumption names \
      (using, then keeping)"
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

/-- `ltemporal_intro` with `keeping`: the original selection plus temporal-4 kept facts. -/
private def introduceKeeping (past : Bool) (terms : Option (Array Syntax))
    (keptTerms : Array Syntax) (names : Array Syntax) : TacticM Unit := withMainContext do
  let judgment ← requireJudgment (← getMainGoal)
  let scope := if past then Scope.past else Scope.future
  let selected ← scopedGuarantees judgment scope.operator terms
  let kept ← persistKept judgment past (← keptFacts judgment past keptTerms)
  introduceScopeFromProofs scope.operator (← scope.rule judgment.language) #[]
    (selected ++ kept) names

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

/-! ## Progress -/

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

/-- A leads-to statement: `G(φ → Fψ)` (persistent) or `φ → Fψ` (current), or past mirrors. -/
private structure LeadsTo where
  persistent : Bool
  past : Bool
  source : Expr
  target : Expr

private def leadsTo? (judgment : Judgment) (formula : Expr) : MetaM (Option LeadsTo) := do
  let read (persistent past : Bool) (body : Expr) : MetaM (Option LeadsTo) := do
    let some imp ← operatorArgs? judgment.language `imp 2 body | return none
    let eventual := if past then `somePast else `someFuture
    let some target ← operatorArgs? judgment.language eventual 1 imp[1]! | return none
    return some ⟨persistent, past, imp[0]!, target[0]!⟩
  if let some body ← operatorArgs? judgment.language `allFuture 1 formula then
    if let some result ← read true false body[0]! then return result
  if let some body ← operatorArgs? judgment.language `allPast 1 formula then
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
  let some cases ← operatorArgs? judgment.language `or 2 shape.source
    | throwError "lprogress cases expects a disjunctive source"
  let target ← eventually judgment shape.past shape.target
  let first ← premiseGoal judgment (← scopedImp judgment shape.past cases[0]! target)
  let second ← premiseGoal judgment (← scopedImp judgment shape.past cases[1]! target)
  let rule ← compositionRule judgment
    (if shape.past then `pastProgressCases else `progressCases)
  finish goal (← mkAppM rule #[first, second]) [first.mvarId!, second.mvarId!]

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
  let hPre ← premiseGoal judgment pre
  let hPost ← premiseGoal judgment post
  let name := match wanted.persistent, wanted.past with
    | true, false => `progressConsequence
    | true, true => `pastProgressConsequence
    | false, false => `leadsToConsequence
    | false, true => `pastLeadsToConsequence
  finish goal (← mkAppM (← compositionRule judgment name) #[hPre, hPost, given])
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
  let next ← premiseGoal judgment (← scopedImp judgment wanted.past have_.target
    (← eventually judgment wanted.past wanted.target))
  let name ← match wanted.persistent, wanted.past with
    | true, false => pure (judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.progressTrans
        ``FormalSystem.PlusLanguage.ProofMode.progressTrans)
    | true, true => pure (judgment.language.ruleName
        ``FormalSystem.Theorems.ProofMode.pastProgressTrans
        ``FormalSystem.PlusLanguage.ProofMode.pastProgressTrans)
    | false, false => compositionRule judgment `leadsToTrans
    | false, true => compositionRule judgment `pastLeadsToTrans
  finish goal (← mkAppM name #[given, next]) [next.mvarId!]

/-- Check the goal is a leads-to statement, then apply the rule through `lapply`. -/
private def progressRule (term : Syntax) : TacticM Unit := withMainContext do
  let judgment ← requireJudgment (← getMainGoal)
  discard <| requireLeadsTo judgment judgment.formula
  applyTemporalRule term

/-! ## Until and Since -/

/-- Binary operator, one-step operator, universal and existential scope of a direction. -/
private def binaryOperators (past : Bool) : Name × Name × Name × Name :=
  if past then (`snce, `prev, `allPast, `somePast)
  else (`untl, `next, `allFuture, `someFuture)

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

/-- Read `U g e`/`S g e`, returning guard and event. -/
private def binaryArgs (judgment : Judgment) (past : Bool) (formula : Expr) (what : String) :
    MetaM (Expr × Expr) := do
  let (operator, _, _, _) := binaryOperators past
  let some args ← operatorArgs? judgment.language operator 2 formula
    | throwError "{what} expects {if past then "a Since" else "an Until"} formula"
  return (args[0]!, args[1]!)

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
  let (guard, event) ← binaryArgs judgment past judgment.formula "fold"
  let (now, later) ← stepBranches judgment past guard event
  let premise ← premiseGoal judgment (← formulaApp judgment.language `or #[now, later])
  finish goal (← mkAppM (← compositionRule judgment (if past then `sinceFold else `untilFold))
    #[premise])
    [premise.mvarId!]

private def binaryIntro (past : Bool) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let (guard, event) ← binaryArgs judgment past judgment.formula "intro"
  let (_, _, universal, existential) := binaryOperators past
  let hGuard ← premiseGoal judgment (← formulaApp judgment.language universal #[guard])
  let hEvent ← premiseGoal judgment (← formulaApp judgment.language existential #[event])
  finish goal (← mkAppM (← compositionRule judgment (if past then `sinceIntro else `untilIntro))
    #[hGuard, hEvent])
    [hGuard.mvarId!, hEvent.mvarId!]

private def binaryUnfold (past : Bool) (term : Syntax) (eventName continueName : Name) :
    TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let fact ← adaptProof (← elaborateProof term) judgment
  let (guard, event) ← binaryArgs judgment past (← proofJudgment fact).formula "unfold"
  let (gate, gateGoals) ← integerTimeGate judgment
  let (now, later) ← stepBranches judgment past guard event
  let branch (head : Expr) : MetaM Expr := do
    mkFreshExprSyntheticOpaqueMVar (← derivationType judgment
      (← mkAppM ``List.cons #[head, judgment.context]) judgment.formula)
  let hEvent ← branch now
  let hContinue ← branch later
  let proof ← mkAppM
    (← compositionRule judgment (if past then `sinceUnfoldCases else `untilUnfoldCases))
    #[gate, fact, hEvent, hContinue]
  let named (body : Expr) (name : Name) (head : Expr) : MetaM MVarId :=
    body.mvarId!.withContext do
      nameProof body.mvarId! name (← assumptionProof (← requireJudgment body.mvarId!) head)
  let eventGoal ← named hEvent eventName now
  let continueGoal ← named hContinue continueName later
  finish goal proof (gateGoals ++ [eventGoal, continueGoal])

private def binaryRule (past : Bool) (term : Syntax) : TacticM Unit := withMainContext do
  let judgment ← requireJudgment (← getMainGoal)
  discard <| binaryArgs judgment past judgment.formula "the rule route"
  applyTemporalRule term

/-! ## Contextual time reflection -/

private def reflectionPairs (language : Language) : Array (Name × Name) :=
  #[(`untl, `snce), (`snce, `untl), (`someFuture, `somePast), (`somePast, `someFuture),
    (`allFuture, `allPast), (`allPast, `allFuture), (`next, `prev), (`prev, `next),
    (`imp, `imp), (`and, `and), (`or, `or), (`neg, `neg), (`box, `box),
    (`diamond, `diamond)] ++ if language == .plus then #[(`stab, `stab), (`dstab, `dstab)]
    else #[]

/-- The registered event-first and inclusive views, with their time mirrors. -/
private def viewPairs : Array (Name × Name) :=
  #[(`release, `trigger), (`trigger, `release), (`weakUntil, `weakSince),
    (`weakSince, `weakUntil), (`strongRelease, `strongTrigger),
    (`strongTrigger, `strongRelease), (`inclusiveUntil, `inclusiveSince),
    (`inclusiveSince, `inclusiveUntil)]

/-- Registered derived temporal views, by checked source declaration. -/
def Language.temporalViewName (language : Language) (view : Name) : MetaM Name := do
  let pair ← match view with
    | `release => pure (``FormalSystem.Syntax.Formula.release,
        ``FormalSystem.PlusLanguage.PlusFormula.release)
    | `trigger => pure (``FormalSystem.Syntax.Formula.trigger,
        ``FormalSystem.PlusLanguage.PlusFormula.trigger)
    | `weakUntil => pure (``FormalSystem.Syntax.Formula.weakUntil,
        ``FormalSystem.PlusLanguage.PlusFormula.weakUntil)
    | `weakSince => pure (``FormalSystem.Syntax.Formula.weakSince,
        ``FormalSystem.PlusLanguage.PlusFormula.weakSince)
    | `strongRelease => pure (``FormalSystem.Syntax.Formula.strongRelease,
        ``FormalSystem.PlusLanguage.PlusFormula.strongRelease)
    | `strongTrigger => pure (``FormalSystem.Syntax.Formula.strongTrigger,
        ``FormalSystem.PlusLanguage.PlusFormula.strongTrigger)
    | `before => pure (``FormalSystem.Syntax.Formula.before,
        ``FormalSystem.PlusLanguage.PlusFormula.before)
    | `after => pure (``FormalSystem.Syntax.Formula.after,
        ``FormalSystem.PlusLanguage.PlusFormula.after)
    | `inclusiveUntil => pure (``FormalSystem.Syntax.Formula.inclusiveUntil,
        ``FormalSystem.PlusLanguage.PlusFormula.inclusiveUntil)
    | `inclusiveSince => pure (``FormalSystem.Syntax.Formula.inclusiveSince,
        ``FormalSystem.PlusLanguage.PlusFormula.inclusiveSince)
    | _ => throwError "unregistered temporal view {view}; registered views: release, trigger, \
        weakUntil, weakSince, strongRelease, strongTrigger, before, after, inclusiveUntil, \
        inclusiveSince"
  return language.ruleName pair.1 pair.2

/-- Syntactic time reflection of a formula expression that keeps registered heads. Atoms, `⊥`
and `⊤` are fixed; unregistered subterms are wrapped in `reflectTime`. The caller checks the
result against the actual `reflectTime` by definitional equality. -/
private partial def reflectView (language : Language) (formula : Expr) : MetaM Expr := do
  let formula ← instantiateMVars formula
  let some head := formula.getAppFn.constName? | wrap formula
  for (source, target) in reflectionPairs language do
    if head == (← language.operatorName source) then
      return ← formulaApp language target (← formula.getAppArgs.mapM (reflectView language))
  for (source, target) in viewPairs do
    if head == (← language.temporalViewName source) then
      return ← mkAppM (← language.temporalViewName target)
        (← formula.getAppArgs.mapM (reflectView language))
  for fixed in #[`atom, `bot, `top] do
    if head == (← language.operatorName fixed) then return formula
  wrap formula
where
  wrap (formula : Expr) : MetaM Expr :=
    mkAppM (language.ruleName ``FormalSystem.Syntax.Formula.reflectTime
      ``FormalSystem.PlusLanguage.PlusFormula.reflectTime) #[formula]

/-- Reflect a context entry by entry, keeping an abstract tail as an explicit mapped list. -/
private partial def reflectContextView (language : Language) (context : Expr) : MetaM Expr := do
  let context ← whnfR (← instantiateMVars context)
  match context.getAppFn.constName? with
  | some ``List.nil => return context
  | some ``List.cons =>
    let args := context.getAppArgs
    mkAppM ``List.cons #[← reflectView language args[1]!,
      ← reflectContextView language args[2]!]
  | _ =>
    let reflect := mkConst (language.ruleName ``FormalSystem.Syntax.Formula.reflectTime
      ``FormalSystem.PlusLanguage.PlusFormula.reflectTime)
    mkAppM ``List.map #[reflect, context]

/-- The reflected judgment type, checked against the type of the native reflection rule. -/
private def reflectedType (judgment : Judgment) (actual : Expr) : MetaM Expr := do
  let expected ← derivationType judgment (← reflectContextView judgment.language judgment.context)
    (← reflectView judgment.language judgment.formula)
  unless ← isDefEq expected actual do
    throwError "reflected view does not match the native reflection rule"
  return expected

private def timeReflect (names : Option (Array Syntax)) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let context ← reflectContextView judgment.language judgment.context
  let formula ← reflectView judgment.language judgment.formula
  let body ← premiseGoal { judgment with context } formula
  let proof ← mkAppOptM (← compositionRule judgment `reflectGoal)
    #[some judgment.frame, some judgment.context, some judgment.formula, some body]
  finish goal proof [body.mvarId!]
  if let some names := names then
    evalTactic (← `(tactic| lstart $(names.map (⟨·⟩)):ident*))

private def timeReflectUsing (term : Syntax) (name : Option Name) : TacticM Unit :=
    withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let firstNewIndex := (← getMCtx).mvarCounter
  let fact ← elaborateProof term
  let some source ← judgment? (← inferType fact) | do
    if name.isSome then throwError "`as` names a reflected fact, not a rule application"
    return ← applyTemporalProof fact firstNewIndex
  if (← instantiateMVars fact).hasExprMVar then
    throwError "reflected fact has unresolved parameters; supply its arguments explicitly"
  unless source.language == judgment.language do
    throwError "different object languages; supply an explicit derivation embedding"
  let reflected ← mkAppM (← compositionRule judgment `reflectContext)
    #[source.context, source.formula, fact]
  let type ← reflectedType source (← inferType reflected)
  let reflected ← mkExpectedTypeHint reflected type
  match name with
  | some name => replaceMainGoal [← nameProof goal name reflected]
  | none =>
    let proof ← adaptProof reflected judgment
    unless ← isDefEq (← inferType proof) (← goal.getType) do
      throwError "the reflected derivation does not prove the current conclusion"
    goal.assign proof
    replaceMainGoal []

/-! ## Exact derived temporal views -/

/-- Rewrite every formula node, outermost first, then its formula arguments. -/
private partial def mapFormula (language : Language) (step : Expr → MetaM (Option Expr))
    (formula : Expr) : StateRefT Nat MetaM Expr := do
  let formula ← instantiateMVars formula
  let formula ← match ← step formula with
    | some result => modify (· + 1); pure result
    | none => pure formula
  let fn := formula.getAppFn
  unless fn.isConst do return formula
  let args ← formula.getAppArgs.mapM fun argument => do
    if (← inferType argument).isConstOf language.formulaNamespace then
      mapFormula language step argument
    else pure argument
  return mkAppN fn args

/-- Unfold (or fold) one registered view head by delta reduction (or reducible matching of its
literal right-hand side), returning the new formula and the number of rewritten nodes. -/
private def viewCorrespondence (language : Language) (view : Name) (fold : Bool)
    (formula : Expr) : MetaM (Expr × Nat) := do
  let name ← language.temporalViewName view
  let info ← getConstInfo name
  let arity ← forallTelescopeReducing info.type fun xs _ => pure xs.size
  let step (node : Expr) : MetaM (Option Expr) := do
    if !fold then
      if node.isAppOfArity name arity then return ← delta? node (· == name)
      return none
    if node.getAppFn.isMVar then return none
    let original ← getMVars node
    let saved ← saveState
    let arguments ← (List.range arity).toArray.mapM fun _ =>
      mkFreshExprMVar (mkConst language.formulaNamespace)
    let pattern := info.value!.beta arguments
    if ← withReducible (isDefEq node pattern) then
      let arguments ← arguments.mapM instantiateMVars
      let assigned ← original.anyM (·.isAssigned)
      unless assigned || arguments.any (·.hasExprMVar) do
        return some (mkAppN (mkConst name) arguments)
    saved.restore
    return none
  let (result, count) ← (mapFormula language step formula).run 0
  unless ← isDefEq result formula do
    throwError "view correspondence is not definitional"
  return (result, count)

private def temporalDual (view : Name) (fold : Bool) (fact : Option (Syntax × Name)) :
    TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let describe := if fold then "literal expansion of" else "occurrence of"
  match fact with
  | none =>
    let (formula, count) ← viewCorrespondence judgment.language view fold judgment.formula
    if count == 0 then throwError "no {describe} {view} in the goal"
    replaceMainGoal [← goal.replaceTargetDefEq
      (← derivationType judgment judgment.context formula)]
  | some (term, name) =>
    let proof ← elaborateProof term
    let source ← proofJudgment proof
    let (formula, count) ← viewCorrespondence source.language view fold source.formula
    if count == 0 then throwError "no {describe} {view} in the fact"
    let type ← derivationType source source.context formula
    replaceMainGoal [← nameProof goal name (← mkExpectedTypeHint proof type)]

/-! ## Syntax -/

/-- Open an eventuality body using only selected G/H guarantees; `using []` selects none.
`keeping [k]` additionally carries strict G/H facts so the body still has them. Name the event,
then `using` guarantees, then kept facts. -/
syntax (name := ltemporalCases) "ltemporal_cases" ppSpace colGt term
  (ppSpace "using" ppSpace "[" term,* "]")? (ppSpace "keeping" ppSpace "[" term,* "]")?
  ppSpace "as" (ppSpace colGt ident)+ : tactic

/-- Open an eventuality with an eventual body conclusion, using the proved temporal bind rule.
`keeping` retains strict G/H facts in the body as for `ltemporal_cases`. -/
syntax (name := ladvance) "ladvance" ppSpace colGt term
  (ppSpace "using" ppSpace "[" term,* "]")? (ppSpace "keeping" ppSpace "[" term,* "]")?
  ppSpace "as" (ppSpace colGt ident)+ : tactic

/-- Introduce strict G/H, additionally keeping strict G/H facts in the body through temporal 4.
Without `keeping`, the original `ltemporal_intro` elaborator applies. -/
syntax (name := ltemporalIntroKeeping) "ltemporal_intro" ppSpace colGt ident
  (ppSpace "using" ppSpace "[" term,* "]")? ppSpace "keeping" ppSpace "[" term,* "]"
  (ppSpace "as" (ppSpace colGt ident)+)? : tactic

/-- Apply a G/H-scoped implication, leaving the corresponding G/H/F/P premise. -/
syntax (name := ltemporalUse) "ltemporal_use" ppSpace colGt term : tactic

/-- Compose two future or past progress guarantees by a native derivation rule. -/
syntax (name := lprogress) "lprogress" ppSpace "using" ppSpace "[" term,* "]" : tactic

/-- Apply a native progress rule to a leads-to goal through `lapply`. -/
syntax (name := lprogressRule) (priority := low) "lprogress" ppSpace "using" ppSpace colGt term :
  tactic

/-- Split a persistent leads-to goal with a disjunctive source into its two cases. -/
syntax (name := lprogressCases) "lprogress" ppSpace &"cases" : tactic

/-- Weaken a leads-to guarantee: strengthen its source, weaken its target under G/H. -/
syntax (name := lprogressConsequence) "lprogress" ppSpace &"consequence" ppSpace "using"
  ppSpace colGt term : tactic

/-- Compose a supplied first leads-to step with a persistent second step left as a goal. -/
syntax (name := lprogressTrans) "lprogress" ppSpace &"trans" ppSpace "using" ppSpace colGt term :
  tactic

/-- Map the guard or event of an Until goal with a future-scoped implication. -/
syntax (name := luntil) "luntil" ppSpace colGt ident ppSpace "using" ppSpace colGt term : tactic

/-- Reduce an Until goal to `X e ∨ X(g ∧ U g e)`, at every frame class. -/
syntax (name := luntilFold) "luntil" ppSpace &"fold" : tactic

/-- Introduce `U g e` from `G g` and `F e`. -/
syntax (name := luntilIntro) "luntil" ppSpace &"intro" : tactic

/-- Unfold an Until fact one step on integer time; both branches keep `X` and prove the goal. -/
syntax (name := luntilUnfold) "luntil" ppSpace &"unfold" ppSpace colGt term ppSpace "as"
  ppSpace colGt ident ppSpace colGt ident : tactic

/-- Apply a native rule to an Until goal through `lapply`. -/
syntax (name := luntilRule) "luntil" ppSpace "using" ppSpace colGt term : tactic

/-- Map the guard or event of a Since goal with a past-scoped implication. -/
syntax (name := lsince) "lsince" ppSpace colGt ident ppSpace "using" ppSpace colGt term : tactic

/-- Reduce a Since goal to `Y e ∨ Y(g ∧ S g e)`, at every frame class. -/
syntax (name := lsinceFold) "lsince" ppSpace &"fold" : tactic

/-- Introduce `S g e` from `H g` and `P e`. -/
syntax (name := lsinceIntro) "lsince" ppSpace &"intro" : tactic

/-- Unfold a Since fact one step on integer time; both branches keep `Y`. -/
syntax (name := lsinceUnfold) "lsince" ppSpace &"unfold" ppSpace colGt term ppSpace "as"
  ppSpace colGt ident ppSpace colGt ident : tactic

/-- Apply a native rule to a Since goal through `lapply`. -/
syntax (name := lsinceRule) "lsince" ppSpace "using" ppSpace colGt term : tactic

/-- Replace `Γ ⊢ A` by `reflect Γ ⊢ reflect A`, mapping every assumption; `as` names them. -/
syntax (name := ltimeReflect) "ltime_reflect" (ppSpace "as" (ppSpace colGt ident)+)? : tactic

/-- Reflect a native fact with its whole context and close the goal (or name it with `as`);
a non-derivation term is applied as a rule through `lapply`. -/
syntax (name := ltimeReflectUsing) "ltime_reflect" ppSpace "using" ppSpace colGt term
  (ppSpace "as" ppSpace colGt ident)? : tactic

/-- Unfold (`←`: fold) every occurrence of one registered derived temporal view, by checked
definitional correspondence, in the goal or in a named copy of a fact. -/
syntax (name := ltemporalDual) "ltemporal_dual" (ppSpace "←")? ppSpace colGt ident
  (ppSpace "at" ppSpace colGt term ppSpace "as" ppSpace colGt ident)? : tactic

/-- Rewrite a temporal view with a native equivalence or formula equality, through `lrewrite`. -/
syntax (name := ltemporalDualUsing) "ltemporal_dual" (ppSpace "←")? ppSpace "using"
  ppSpace colGt term (ppSpace "at" ppSpace colGt term ppSpace "as" ppSpace colGt ident)? : tactic

private def guardOrEvent (kind : TSyntax `ident) : TacticM Bool :=
  match kind.getId with
  | `guard => pure true
  | `event => pure false
  | _ => throwError "expected `guard` or `event`"

private def futureOrPast (kind : TSyntax `ident) : TacticM Bool :=
  match kind.getId with
  | `future => pure false
  | `past => pure true
  | _ => throwError "expected `future` or `past`"

/-- Recognize the original two-guarantee list when the generic route receives a list term. -/
private def progressList? (term : Syntax) : Option (Array Syntax) :=
  if term.getKind == `«term[_]» then some term[1].getSepArgs else none

elab_rules : tactic
  | `(tactic| ltemporal_cases $proof:term $[using [$terms:term,*]]?
      $[keeping [$kept:term,*]]? as $names:ident*) =>
    eventualityCases false proof (terms.map (·.getElems.map (·.raw)))
      ((kept.map (·.getElems.map (·.raw))).getD #[]) (names.map (·.raw))
  | `(tactic| ladvance $proof:term $[using [$terms:term,*]]?
      $[keeping [$kept:term,*]]? as $names:ident*) =>
    eventualityCases true proof (terms.map (·.getElems.map (·.raw)))
      ((kept.map (·.getElems.map (·.raw))).getD #[]) (names.map (·.raw))
  | `(tactic| ltemporal_intro $kind:ident $[using [$terms:term,*]]?
      keeping [$kept:term,*] $[as $names:ident*]?) => do
    introduceKeeping (← futureOrPast kind) (terms.map (·.getElems.map (·.raw)))
      (kept.getElems.map (·.raw)) (names.map (·.map (·.raw)) |>.getD #[])
  | `(tactic| ltemporal_use $proof:term) => temporalUse proof
  | `(tactic| lprogress using [$terms:term,*]) => progress (terms.getElems.map (·.raw))
  | `(tactic| lprogress using $rule:term) =>
    match progressList? rule.raw with
    | some terms => progress terms
    | none => progressRule rule
  | `(tactic| lprogress cases) => progressCasesGoal
  | `(tactic| lprogress consequence using $proof:term) => progressConsequenceGoal proof
  | `(tactic| lprogress trans using $proof:term) => progressTransGoal proof
  | `(tactic| luntil $kind:ident using $proof:term) => do
    binaryTemporal false (← guardOrEvent kind) proof
  | `(tactic| luntil fold) => binaryFold false
  | `(tactic| luntil intro) => binaryIntro false
  | `(tactic| luntil unfold $proof:term as $event:ident $cont:ident) =>
    binaryUnfold false proof event.getId cont.getId
  | `(tactic| luntil using $rule:term) => binaryRule false rule
  | `(tactic| lsince $kind:ident using $proof:term) => do
    binaryTemporal true (← guardOrEvent kind) proof
  | `(tactic| lsince fold) => binaryFold true
  | `(tactic| lsince intro) => binaryIntro true
  | `(tactic| lsince unfold $proof:term as $event:ident $cont:ident) =>
    binaryUnfold true proof event.getId cont.getId
  | `(tactic| lsince using $rule:term) => binaryRule true rule
  | `(tactic| ltime_reflect $[as $names:ident*]?) => timeReflect (names.map (·.map (·.raw)))
  | `(tactic| ltime_reflect using $proof:term $[as $name:ident]?) =>
    timeReflectUsing proof (name.map (·.getId))
  | `(tactic| ltemporal_dual $[←%$fold]? $view:ident $[at $fact:term as $name:ident]?) =>
    temporalDual view.getId fold.isSome (fact.map fun fact => (fact.raw, name.get!.getId))
  | `(tactic| ltemporal_dual $[←%$reverse]? using $rule:term
      $[at $fact:term as $name:ident]?) =>
    nativeRewrite rule reverse.isSome none (fact.map fun fact => (fact.raw, name.get!.getId))
      false

end FormalSystem.Automation.ProofMode
