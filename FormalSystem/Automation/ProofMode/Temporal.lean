/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Carrying
import FormalSystem.Automation.ProofMode.Modal
import FormalSystem.Automation.ProofMode.Rewriting
import FormalSystem.Theorems.ProofMode.Temporal
import FormalSystem.Theorems.ProofMode.PlusTemporal
import FormalSystem.Theorems.ProofMode.TemporalComposition
import FormalSystem.Tactic.TemporalFormulaViews

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
| `luntil guard/event using d` | Until operand monotonicity |
| `luntil intro` | `untilIntro`: `G g` and `F e` |
| `ltime_reflect [as h..]` | `reflectGoal`, mapping the whole context and the conclusion |
| `ltime_reflect using d [as h]` | `reflectContext` on a native fact |

`lsince` mirrors each `luntil` form with H/P/Y and `S`.

## Body name order

Names always list the event (cases/advance only), then the `using` guarantees in order, then
the `keeping` facts in order. Omitting `using` selects every
matching assumption; `using []` selects none.

## `keeping`

`keeping [k]` applies the row of `Carrying.lean` for the fact's operator and the scope entered. Here
a future step accepts only a strict `G P` fact and a past step only an `H P` fact. Temporal 4
(`futureKeep`/`pastKeep`) turns it into `G(G P)`/`H(H P)` before the scope rule removes one
operator, so the body holds `G P`/`H P` again. A bare current fact is rejected: no native rule
carries it to a later point. `using` guarantees are still unwrapped exactly once.

## Frame gates

Integer-time expansion, invariance and backward induction receive their
`FrameClass.ZTime ≤ fc` premise from an exact local certificate or a decided concrete tag. An
incompatible concrete tag is rejected immediately. An abstract tag becomes an explicit goal.
-/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic
open FormalSystem.Tactic.FormulaSyntax (Language)
open FormalSystem.Tactic.FormulaViews (viewHead?)

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

/-- Check and install a temporal certificate with explicit premise goals. -/
def finishTemporal (goal : MVarId) (proof : Expr) (goals : List MVarId := []) :
    TacticM Unit := do
  unless ← isDefEq (← inferType proof) (← goal.getType) do
    throwError "the temporal rule does not prove the current conclusion"
  goal.assign proof
  replaceMainGoal goals

/-- A fresh native premise at the goal's frame class and context. -/
def temporalPremiseGoal (judgment : Judgment) (formula : Expr) : MetaM Expr := do
  mkFreshExprSyntheticOpaqueMVar (← derivationType judgment judgment.context formula)

/-- Checked TM and TM⁺ declarations of the temporal composition rules. -/
private def compositionRule (judgment : Judgment) (rule : Name) : MetaM Name := do
  let pair ← match rule with
    | `untilIntro => pure (``FormalSystem.Theorems.ProofMode.untilIntro,
        ``FormalSystem.PlusLanguage.ProofMode.untilIntro)
    | `sinceIntro => pure (``FormalSystem.Theorems.ProofMode.sinceIntro,
        ``FormalSystem.PlusLanguage.ProofMode.sinceIntro)
    | `reflectGoal => pure (``FormalSystem.Theorems.ProofMode.reflectGoal,
        ``FormalSystem.PlusLanguage.ProofMode.reflectGoal)
    | `reflectContext => pure (``FormalSystem.Theorems.ProofMode.reflectContext,
        ``FormalSystem.PlusLanguage.ProofMode.reflectContext)
    | _ => throwError "unregistered temporal composition rule {rule}"
  return judgment.language.ruleName pair.1 pair.2

/-! ## Integer-time gate -/

/-- The `FrameClass.ZTime ≤ fc` premise of an explicitly requested integer-time rule. An exact
local certificate or a decided concrete tag discharges it; an incompatible concrete tag is
rejected; an abstract tag is returned as an explicit goal. -/
def integerTimeGate (judgment : Judgment) : TacticM (Expr × List MVarId) := do
  let type ← mkAppM ``LE.le
    #[mkConst ``FormalSystem.ProofSystem.FrameClass.ZTime, judgment.frame]
  if (← instantiateMVars type).hasExprMVar then
    throwError "the frame class of the goal is undetermined"
  let gate ← mkFreshExprMVar type
  let pending ← try resolveRuleParameters #[gate] catch _ =>
    throwError "integer-time reasoning requires FrameClass.ZTime ≤ {judgment.frame}"
  return (gate, pending)

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
  let kept ← carriedFacts judgment scope.operator keptTerms
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
  finishTemporal goal proof [bodyGoal]

/-- `ltemporal_intro` with `keeping`: select the body assumptions and retain strict guarantees. -/
private def introduceKeeping (past : Bool) (terms : Option (Array Syntax))
    (keptTerms : Array Syntax) (names : Array Syntax) : TacticM Unit := withMainContext do
  let judgment ← requireJudgment (← getMainGoal)
  let scope := if past then Scope.past else Scope.future
  let selected ← scopedGuarantees judgment scope.operator terms
  let kept ← carriedFacts judgment scope.operator keptTerms
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
  finishTemporal goal proof [premise.mvarId!]

/-! ## Until and Since -/

/-- Binary operator, one-step operator, universal and existential scope of a direction. -/
def binaryOperators (past : Bool) : Name × Name × Name × Name :=
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
  finishTemporal goal (← mkAppM name #[mapping, premise]) [premise.mvarId!]

/-- Read `U g e`/`S g e`, returning guard and event. -/
def binaryArgs (judgment : Judgment) (past : Bool) (formula : Expr) (what : String) :
    MetaM (Expr × Expr) := do
  let (operator, _, _, _) := binaryOperators past
  let some args ← operatorArgs? judgment.language operator 2 formula
    | throwError "{what} expects {if past then "a Since" else "an Until"} formula"
  return (args[0]!, args[1]!)

private def binaryIntro (past : Bool) : TacticM Unit := withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let (guard, event) ← binaryArgs judgment past judgment.formula "intro"
  let (_, _, universal, existential) := binaryOperators past
  let hGuard ← temporalPremiseGoal judgment (← formulaApp judgment.language universal #[guard])
  let hEvent ← temporalPremiseGoal judgment (← formulaApp judgment.language existential #[event])
  let rule ← compositionRule judgment (if past then `sinceIntro else `untilIntro)
  finishTemporal goal (← mkAppM rule #[hGuard, hEvent]) [hGuard.mvarId!, hEvent.mvarId!]

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
    if (← viewHead? source language.formulaNamespace) == some head then
      let some reflected ← viewHead? target language.formulaNamespace
        | throwError "missing reflected formula view {target}"
      return ← mkAppM reflected (← formula.getAppArgs.mapM (reflectView language))
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
  let body ← temporalPremiseGoal { judgment with context } formula
  let proof ← mkAppOptM (← compositionRule judgment `reflectGoal)
    #[some judgment.frame, some judgment.context, some judgment.formula, some body]
  finishTemporal goal proof [body.mvarId!]
  if let some names := names then
    evalTactic (← `(tactic| lstart $(names.map (⟨·⟩)):ident*))

private def timeReflectUsing (term : Syntax) (name : Option Name) : TacticM Unit :=
    withMainContext do
  let goal ← getMainGoal
  let judgment ← requireJudgment goal
  let fact ← elaborateProof term
  let some source ← judgment? (← inferType fact)
    | throwError "ltime_reflect using expects a native derivation"
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

/-! ## Syntax -/

/-- Open an eventuality body using only selected G/H guarantees; `using []` selects none.
`keeping [k]` additionally carries strict G/H facts so the body still has them. Name the event,
then `using` guarantees, then kept facts. -/
syntax (name := ltemporalCases) "ltemporal_cases" ppSpace colGt term
  (ppSpace "using" ppSpace "[" term,* "]")? (ppSpace &"keeping" ppSpace "[" term,* "]")?
  ppSpace "as" (ppSpace colGt ident)+ : tactic

/-- Open an eventuality with an eventual body conclusion, using the proved temporal bind rule.
`keeping` retains strict G/H facts in the body as for `ltemporal_cases`. -/
syntax (name := ladvance) "ladvance" ppSpace colGt term
  (ppSpace "using" ppSpace "[" term,* "]")? (ppSpace &"keeping" ppSpace "[" term,* "]")?
  ppSpace "as" (ppSpace colGt ident)+ : tactic

/-- Introduce strict G/H, additionally keeping strict G/H facts in the body through temporal 4.
An explicit `using` list selects facts whose outer temporal operator is removed. -/
syntax (name := ltemporalIntroKeeping) "ltemporal_intro" ppSpace colGt ident
  (ppSpace "using" ppSpace "[" term,* "]")? ppSpace &"keeping" ppSpace "[" term,* "]"
  (ppSpace "as" (ppSpace colGt ident)+)? : tactic

/-- Apply a G/H-scoped implication, leaving the corresponding G/H/F/P premise. -/
syntax (name := ltemporalUse) "ltemporal_use" ppSpace colGt term : tactic

/-- Map the guard or event of an Until goal with a future-scoped implication. -/
syntax (name := luntil) "luntil" ppSpace colGt ident ppSpace "using" ppSpace colGt term : tactic

/-- Introduce `U g e` from `G g` and `F e`. -/
syntax (name := luntilIntro) "luntil" ppSpace &"intro" : tactic

/-- Map the guard or event of a Since goal with a past-scoped implication. -/
syntax (name := lsince) "lsince" ppSpace colGt ident ppSpace "using" ppSpace colGt term : tactic

/-- Introduce `S g e` from `H g` and `P e`. -/
syntax (name := lsinceIntro) "lsince" ppSpace &"intro" : tactic

/-- Replace `Γ ⊢ A` by `reflect Γ ⊢ reflect A`, mapping every assumption; `as` names them. -/
syntax (name := ltimeReflect) "ltime_reflect" (ppSpace "as" (ppSpace colGt ident)+)? : tactic

/-- Reflect a native fact with its whole context and close the goal, or name it with `as`. -/
syntax (name := ltimeReflectUsing) "ltime_reflect" ppSpace "using" ppSpace colGt term
  (ppSpace "as" ppSpace colGt ident)? : tactic

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
  | `(tactic| luntil $kind:ident using $proof:term) => do
    binaryTemporal false (← guardOrEvent kind) proof
  | `(tactic| luntil intro) => binaryIntro false
  | `(tactic| lsince $kind:ident using $proof:term) => do
    binaryTemporal true (← guardOrEvent kind) proof
  | `(tactic| lsince intro) => binaryIntro true
  | `(tactic| ltime_reflect $[as $names:ident*]?) => timeReflect (names.map (·.map (·.raw)))
  | `(tactic| ltime_reflect using $proof:term $[as $name:ident]?) =>
    timeReflectUsing proof (name.map (·.getId))
end FormalSystem.Automation.ProofMode
