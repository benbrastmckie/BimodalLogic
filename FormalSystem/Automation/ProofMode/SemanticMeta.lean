/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Positions
import FormalSystem.Semantics.Truth
import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.Semantics.ProofModeRules

/-!
# Indexed semantic goal views

The public TM/Plus syntax adapters share formula positions with the native frontend. This
view retains the exact truth environment, model, typed history, time and inert environment.
Clause applications force that environment dictionary instead of silently choosing another
local instance. No source derivation is inferred from semantic truth.
-/

namespace FormalSystem.Automation.ProofMode.Semantic

open Lean Meta Elab Tactic
open FormalSystem.Semantics

/-- A pointed truth judgment, with every semantic index retained as a typed expression. -/
structure TruthJudgment where
  /-- Public object-language syntax adapter. -/
  language : Language
  /-- Exact frame, including its duration carrier. -/
  frame : Expr
  /-- Actual model/valuation. -/
  model : Expr
  /-- Typed world history. -/
  history : Expr
  /-- Evaluation time on this frame. -/
  time : Expr
  /-- Inert environment, including noncanonical instances if supported by their clauses. -/
  environment : Expr
  /-- The exact `TruthEnv` instance. -/
  truthEnvironment : Expr
  /-- Object-language formula. -/
  formula : Expr
  /-- Keep the public TruthAt/PlusTruthAt presentation when it was the source surface. -/
  direct : Bool

/-- Compare nominal indices one at a time, before any formula or satisfaction is unfolded.
`history`/`time` may be skipped when the calling rule's own clause relates them. -/
def sameIndex (expected actual : TruthJudgment) (what : MessageData)
    (history time : Bool := true) : MetaM Unit := do
  unless expected.language == actual.language do
    throwError "{what} is in another object language; supply an explicit translation"
  let check (label : String) (wanted found : Expr) : MetaM Unit := do
    unless ← isDefEq wanted found do
      throwError "{what} is at a different {label}:{indentExpr found}\nexpected{indentExpr wanted}\
        \nMove it only with an explicit transport certificate."
  check "truth dictionary" expected.truthEnvironment actual.truthEnvironment
  check "frame" expected.frame actual.frame
  check "model" expected.model actual.model
  if history then check "history" expected.history actual.history
  if time then check "time" expected.time actual.time
  check "environment" expected.environment actual.environment

/-- Compare all semantic indices explicitly, even for formulas whose truth erases an index. -/
def samePoint (a b : TruthJudgment) : MetaM Bool := do
  if a.language != b.language then return false
  for (x, y) in #[(a.frame, b.frame), (a.truthEnvironment, b.truthEnvironment),
      (a.model, b.model), (a.history, b.history), (a.time, b.time),
      (a.environment, b.environment)] do
    unless ← isDefEq x y do return false
  return true

/-- Run a semantic command so that a failure leaves the proof state unchanged. -/
def transactional {α : Type} (k : TacticM α) : TacticM α := do
  let saved ← Tactic.saveState
  try k catch ex =>
    saved.restore (restoreInfo := true)
    throw ex

private def pointProjection? (node : Expr) : Option Expr := do
  let (field, point) ← match node with
    | .proj name i value =>
      if name == ``ProofModeRules.Point then some (i, value) else none
    | _ =>
      let args := node.getAppArgs
      if args.size != 4 then none
      else if node.isAppOf ``ProofModeRules.Point.history then some (0, args[3]!)
      else if node.isAppOf ``ProofModeRules.Point.time then some (1, args[3]!)
      else if node.isAppOf ``ProofModeRules.Point.env then some (2, args[3]!)
      else none
  if field < 3 && point.isAppOfArity ``ProofModeRules.Point.mk 6 then
    some point.getAppArgs[3 + field]!
  else none

/-- Reduce literal Point projections for display, preserving model/history provider constants. -/
def presentPointIndex (value : Expr) : MetaM Expr := do
  let mut current ← instantiateMVars value
  for _ in [:16] do
    let next := current.replace pointProjection?
    if next == current then return current
    current := next
  return current

/-- Build truth at the selected point without changing the frame, model or environment. -/
def truthType (j : TruthJudgment) (formula : Expr)
    (history : Option Expr := none) (time : Option Expr := none) : MetaM Expr := do
  let history := history.getD j.history
  let time := time.getD j.time
  if j.direct then
    mkAppOptM (j.language.ruleName ``FormalSystem.Semantics.TruthAt
      ``FormalSystem.PlusLanguage.PlusTruthAt)
      #[some j.frame, some j.model, some history, some time, some formula]
  else
    mkAppOptM ``TruthEnv.T #[some (mkConst j.language.formulaNamespace),
      some j.truthEnvironment, some j.frame, some j.model, some history, some time,
      some j.environment, some formula]

private def languageOfCarrier? (carrier : Expr) : MetaM (Option Language) := do
  let carrier ← whnf (← instantiateMVars carrier)
  match carrier.constName? with
  | some ``FormalSystem.Syntax.Formula => return some .tm
  | some ``FormalSystem.PlusLanguage.PlusFormula => return some .plus
  | _ => return none

private def readTruthHead? (type : Expr) : MetaM (Option TruthJudgment) := do
  let arguments := type.getAppArgs
  match type.getAppFn.constName? with
  | some ``FormalSystem.Semantics.TruthAt | some ``FormalSystem.PlusLanguage.PlusTruthAt =>
    if arguments.size != 5 then return none
    let language := if type.getAppFn.constName? == some ``FormalSystem.Semantics.TruthAt then
        Language.tm else Language.plus
    let instanceName := language.ruleName ``FormalSystem.Semantics.instTruthEnvFormula
      ``FormalSystem.PlusLanguage.instTruthEnvPlusFormula
    return some ⟨language, arguments[0]!, arguments[1]!, arguments[2]!, arguments[3]!,
      mkConst ``PUnit.unit [.succ .zero], mkConst instanceName, arguments[4]!, true⟩
  | some ``TruthEnv.T =>
    if arguments.size != 8 then return none
    let some language ← languageOfCarrier? arguments[0]! | return none
    return some ⟨language, arguments[2]!, arguments[3]!, arguments[4]!, arguments[5]!,
      arguments[6]!, arguments[1]!, arguments[7]!, false⟩
  | _ => return none

/-- Recognize semantic heads before reducing truth itself; expand only outer abbreviations. -/
def truthJudgment? (type : Expr) : MetaM (Option TruthJudgment) := do
  let mut type ← instantiateMVars type
  for _ in [:16] do
    type := type.consumeMData
    if let some judgment ← readTruthHead? type then return some judgment
    let some expanded ← unfoldDefinition? type | return none
    if expanded == type then return none
    type := expanded
  return none

private def truthHeads : Array Name :=
  #[``FormalSystem.Semantics.TruthAt, ``FormalSystem.PlusLanguage.PlusTruthAt, ``TruthEnv.T,
    ``ProofModeRules.At, ``ProofModeRules.ImpAt, ``ProofModeRules.IffAt]

private def logicalHead (type : Expr) : MetaM Expr := do
  let mut current ← instantiateMVars type
  for _ in [:16] do
    current := current.consumeMData
    if truthHeads.any current.isAppOf then return current
    if current.isForall || #[``Iff, ``And, ``Or, ``Not, ``Exists].any current.isAppOf then
      return current
    let some expanded ← unfoldDefinition? current | return current
    if expanded == current then return current
    current := expanded
  return current

private def containsTruth (type : Expr) : Bool :=
  (type.find? fun node => truthHeads.any node.isConstOf).isSome

/-- Compare proposition types while retaining every truth index beneath logical binders.
Ordinary nonsemantic leaves use Lean definitional equality. No provider body is inspected. -/
partial def indexedDefEq (left right : Expr) (fuel : Nat := 128) : MetaM Bool := do
  if fuel == 0 then throwError "indexed type comparison exhausted its logical-binder budget"
  if (← instantiateMVars left) == (← instantiateMVars right) then return true
  let a ← truthJudgment? left
  let b ← truthJudgment? right
  match a, b with
  | some a, some b => return (← samePoint a b) && (← isDefEq a.formula b.formula)
  | some _, none | none, some _ => return false
  | none, none => pure ()
  let left ← logicalHead left
  let right ← logicalHead right
  if left.isAppOfArity ``Not 1 && right.isAppOfArity ``Not 1 then
    return ← indexedDefEq left.appArg! right.appArg! (fuel - 1)
  if left.isAppOfArity ``Exists 2 && right.isAppOfArity ``Exists 2 then
    let a := left.getAppArgs
    let b := right.getAppArgs
    unless ← indexedDefEq a[0]! b[0]! (fuel - 1) do return false
    return ← withLocalDeclD `witness a[0]! fun value =>
      indexedDefEq (mkApp a[1]! value).headBeta (mkApp b[1]! value).headBeta (fuel - 1)
  for op in #[``Iff, ``And, ``Or] do
    if left.isAppOfArity op 2 && right.isAppOfArity op 2 then
      let a := left.getAppArgs
      let b := right.getAppArgs
      return (← indexedDefEq a[0]! b[0]! (fuel - 1)) &&
        (← indexedDefEq a[1]! b[1]! (fuel - 1))
  match left, right with
  | .forallE name a body kind, .forallE _ b other _ =>
    unless ← indexedDefEq a b (fuel - 1) do return false
    withLocalDecl name kind a fun bound =>
      indexedDefEq (body.instantiate1 bound) (other.instantiate1 bound) (fuel - 1)
  | _, _ =>
    if containsTruth left || containsTruth right then return false
    isDefEq left right

/-- Require a supported indexed truth goal; no native or completeness fallback is attempted. -/
def requireTruth (goal : MVarId) : MetaM TruthJudgment := do
  let some judgment ← truthJudgment? (← goal.getType)
    | throwError "expected TM/Plus pointed truth with explicit model, history and time"
  return judgment

/-- Apply a shared clause theorem with the actual language and truth dictionary forced. -/
def semanticApp (j : TruthJudgment) (name : Name) (arguments : Array Expr) : MetaM Expr := do
  let specialized ← mkAppOptM name
    #[some (mkConst j.language.formulaNamespace), some j.truthEnvironment]
  mkAppM' specialized arguments

/-- Build the pure kernel's typed point, preserving the inert environment. -/
def pointExpr (j : TruthJudgment) : MetaM Expr :=
  mkAppOptM ``ProofModeRules.Point.mk #[some (mkConst j.language.formulaNamespace),
    some j.truthEnvironment, some j.frame, some j.history, some j.time, some j.environment]

/-- The shared clause theorem for a known operator, with arguments still opaque. -/
def clauseIff (j : TruthJudgment) (operator : Name) (arguments : Array Expr) : MetaM Expr := do
  let name ← match operator with
    | `imp => pure ``ImpClause.imp_clause
    | `box => pure ``BoxClause.box_clause
    | `stab => pure ``StabClause.stab_clause
    | `untl => pure ``UntlClause.untl_clause
    | `snce => pure ``SnceClause.snce_clause
    | `neg => pure ``TruthClauses.neg_iff
    | `and => pure ``TruthClauses.and_iff
    | `or => pure ``TruthClauses.or_iff
    | `diamond => pure ``TruthClauses.diamond_iff
    | `dstab => pure ``TruthClauses.dstab_iff
    | `allFuture => pure ``TruthClauses.allFuture_iff
    | `allPast => pure ``TruthClauses.allPast_iff
    | `someFuture => pure ``TruthClauses.someFuture_iff
    | `somePast => pure ``TruthClauses.somePast_iff
    | `next => pure ``ProofModeRules.next_iff
    | `prev => pure ``ProofModeRules.prev_iff
    | _ => throwError "no registered semantic clause for {operator}"
  semanticApp j name (#[j.model, j.history, j.time, j.environment] ++ arguments)

/-- Replace one truth goal by its checked clause right-hand side. -/
def openClause (goal : MVarId) (j : TruthJudgment) (operator : Name)
    (arguments : Array Expr) : MetaM (List MVarId) := do
  let equivalence ← clauseIff j operator arguments
  goal.apply (← mkAppM ``Iff.mpr #[equivalence])

/-- State the semantic point explicitly in a fact's type after checking the producer. -/
def noteTruth (goal : MVarId) (name : Name) (j : TruthJudgment)
    (formula proof : Expr) : MetaM MVarId := do
  let expected ← truthType j formula
  unless ← isDefEq (← inferType proof) expected do
    throwError "semantic certificate proves a different indexed judgment"
  nameProof goal name (← mkExpectedTypeHint proof expected)

end FormalSystem.Automation.ProofMode.Semantic
