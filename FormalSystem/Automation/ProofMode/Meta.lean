/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.Basic
import FormalSystem.Theorems.ProofMode.PlusRules

/-!
# Shared metaprogramming for native derivation goals

The frontend reads native TM/TM⁺ judgments and constructs checked context inclusions and
derivation terms. Named hypotheses are ordinary Lean locals containing derivation data.
Their source contexts remain part of their types after a scope change.
-/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Tactic

/-- The two native derivation languages supported by the frontend. -/
inductive Language where
  | tm
  | plus
  deriving BEq

/-- The frame class, object context, and conclusion of a native derivation goal. -/
structure Judgment where
  /-- Native language, never a semantic truth judgment. -/
  language : Language
  /-- Source calculus frame-class index. -/
  frame : Expr
  /-- Object-language assumption list. -/
  context : Expr
  /-- Object-language conclusion. -/
  formula : Expr

/-- Namespace of formula constructors and derived operators. -/
def Language.formulaNamespace : Language → Name
  | .tm => ``FormalSystem.Syntax.Formula
  | .plus => ``FormalSystem.PlusLanguage.PlusFormula

/-- Native derivation type constructor. -/
def Language.derivationName : Language → Name
  | .tm => ``FormalSystem.ProofSystem.DerivationTree
  | .plus => ``FormalSystem.PlusLanguage.PlusDerivationTree

/-- Select a TM helper or its native TM⁺ counterpart. -/
def Language.ruleName (language : Language) (tm plus : Name) : Name :=
  if language == .tm then tm else plus

/-- Checked operator declarations. A source rename fails here rather than at tactic invocation. -/
def Language.operatorName (language : Language) (operator : Name) : MetaM Name := do
  let pair ← match operator with
    | `atom => pure (``FormalSystem.Syntax.Formula.atom,
        ``FormalSystem.PlusLanguage.PlusFormula.atom)
    | `bot => pure (``FormalSystem.Syntax.Formula.bot,
        ``FormalSystem.PlusLanguage.PlusFormula.bot)
    | `top => pure (``FormalSystem.Syntax.Formula.top,
        ``FormalSystem.PlusLanguage.PlusFormula.top)
    | `imp => pure (``FormalSystem.Syntax.Formula.imp,
        ``FormalSystem.PlusLanguage.PlusFormula.imp)
    | `neg => pure (``FormalSystem.Syntax.Formula.neg,
        ``FormalSystem.PlusLanguage.PlusFormula.neg)
    | `and => pure (``FormalSystem.Syntax.Formula.and,
        ``FormalSystem.PlusLanguage.PlusFormula.and)
    | `or => pure (``FormalSystem.Syntax.Formula.or,
        ``FormalSystem.PlusLanguage.PlusFormula.or)
    | `box => pure (``FormalSystem.Syntax.Formula.box,
        ``FormalSystem.PlusLanguage.PlusFormula.box)
    | `diamond => pure (``FormalSystem.Syntax.Formula.diamond,
        ``FormalSystem.PlusLanguage.PlusFormula.diamond)
    | `untl => pure (``FormalSystem.Syntax.Formula.untl,
        ``FormalSystem.PlusLanguage.PlusFormula.untl)
    | `snce => pure (``FormalSystem.Syntax.Formula.snce,
        ``FormalSystem.PlusLanguage.PlusFormula.snce)
    | `allFuture => pure (``FormalSystem.Syntax.Formula.allFuture,
        ``FormalSystem.PlusLanguage.PlusFormula.allFuture)
    | `allPast => pure (``FormalSystem.Syntax.Formula.allPast,
        ``FormalSystem.PlusLanguage.PlusFormula.allPast)
    | `someFuture => pure (``FormalSystem.Syntax.Formula.someFuture,
        ``FormalSystem.PlusLanguage.PlusFormula.someFuture)
    | `somePast => pure (``FormalSystem.Syntax.Formula.somePast,
        ``FormalSystem.PlusLanguage.PlusFormula.somePast)
    | `next => pure (``FormalSystem.Syntax.Formula.next,
        ``FormalSystem.PlusLanguage.PlusFormula.next)
    | `prev => pure (``FormalSystem.Syntax.Formula.prev,
        ``FormalSystem.PlusLanguage.PlusFormula.prev)
    | `after => pure (``FormalSystem.Syntax.Formula.after,
        ``FormalSystem.PlusLanguage.PlusFormula.after)
    | `stab => do
      unless language == .plus do throwError "stability requires TM⁺"
      pure (``FormalSystem.PlusLanguage.PlusFormula.stab,
        ``FormalSystem.PlusLanguage.PlusFormula.stab)
    | `dstab => do
      unless language == .plus do throwError "same-state possibility requires TM⁺"
      pure (``FormalSystem.PlusLanguage.PlusFormula.dstab,
        ``FormalSystem.PlusLanguage.PlusFormula.dstab)
    | _ => throwError "unregistered formula operator {operator}"
  return language.ruleName pair.1 pair.2

/-- Build an operator application through its checked source declaration. -/
def formulaApp (language : Language) (operator : Name) (arguments : Array Expr) : MetaM Expr := do
  mkAppM (← language.operatorName operator) arguments

/-- Checked native constructor and structural-rule declarations. -/
def Language.derivationRule (language : Language) (rule : Name) : MetaM Name := do
  let pair ← match rule with
    | `lift => pure (``FormalSystem.ProofSystem.DerivationTree.lift,
          ``FormalSystem.PlusLanguage.PlusDerivationTree.lift)
    | `weakening => pure (``FormalSystem.ProofSystem.DerivationTree.weakening,
          ``FormalSystem.PlusLanguage.PlusDerivationTree.weakening)
    | `assumption => pure (``FormalSystem.ProofSystem.DerivationTree.assumption,
          ``FormalSystem.PlusLanguage.PlusDerivationTree.assumption)
    | `modus_ponens => pure (``FormalSystem.ProofSystem.DerivationTree.modus_ponens,
          ``FormalSystem.PlusLanguage.PlusDerivationTree.modus_ponens)
    | `axiom => pure (``FormalSystem.ProofSystem.DerivationTree.axiom,
          ``FormalSystem.PlusLanguage.PlusDerivationTree.axiom)
    | _ => throwError "unregistered native rule {rule}"
  return language.ruleName pair.1 pair.2

/-- Read a native derivation judgment without inspecting any derivation value. -/
def judgment? (type : Expr) : MetaM (Option Judgment) := do
  let type ← whnf type
  let args := type.getAppArgs
  if args.size != 3 then return none
  let language ← match type.getAppFn.constName? with
    | some ``FormalSystem.ProofSystem.DerivationTree => pure Language.tm
    | some ``FormalSystem.PlusLanguage.PlusDerivationTree => pure Language.plus
    | _ => return none
  return some ⟨language, args[0]!, args[1]!, args[2]!⟩

/-- Collect telescope parameters and implicit holes inserted while elaborating a proof term. -/
def proofParameters (proof : Expr) (parameters : Array Expr) : MetaM (Array Expr) := do
  let mut result := parameters
  for mvarId in ← getMVars (mkAppN proof parameters) do
    let argument := mkMVar mvarId
    if !result.contains argument then result := result.push argument
  return result

/-- Require a native TM or TM⁺ goal. -/
def requireJudgment (goal : MVarId) : MetaM Judgment := do
  let some judgment ← judgment? (← goal.getType)
    | throwError "expected a native TM or TM⁺ derivation goal"
  return judgment

/-- Construct a native derivation type with a new context and conclusion. -/
def derivationType (judgment : Judgment) (context formula : Expr) : MetaM Expr :=
  mkAppM judgment.language.derivationName #[judgment.frame, context, formula]

/-- Read a constructor or derived operator, retaining its object arguments. -/
def operatorArgs? (language : Language) (operator : Name) (arity : Nat)
    (formula : Expr) : MetaM (Option (Array Expr)) := do
  let formula ← instantiateMVars formula
  let name ← language.operatorName operator
  if formula.getAppFn.constName? == some name then
    return some formula.getAppArgs
  let saved ← saveState
  let args ← (List.range arity).toArray.mapM fun _ =>
    mkFreshExprMVar (mkConst language.formulaNamespace)
  let candidate ← mkAppM name args
  if ← isDefEq formula candidate then
    return some (← args.mapM instantiateMVars)
  saved.restore
  return none

/-- Read a rule's syntax without constraining its pre-existing formula metavariables. Fresh
probe arguments must resolve entirely to expressions already present in the statement. -/
def rigidOperatorArgs? (language : Language) (operator : Name) (arity : Nat)
    (formula : Expr) : MetaM (Option (Array Expr)) := do
  let formula ← instantiateMVars formula
  if formula.getAppFn.isMVar then return none
  let original ← getMVars formula
  let saved ← saveState
  let result ← operatorArgs? language operator arity formula
  let result ← result.mapM fun arguments => arguments.mapM instantiateMVars
  let mut valid := true
  for mvarId in original do
    if ← mvarId.isAssigned then valid := false
  if let some arguments := result then
    for argument in arguments do
      for mvarId in ← getMVars argument do
        if !original.contains mvarId then valid := false
  saved.restore
  return if valid then result else none

/-- Enumerate a concrete assumption list; abstract tails require explicit proof terms. -/
partial def contextEntries (context : Expr) : MetaM (Array Expr) := do
  let context ← whnf context
  match context.getAppFn.constName? with
  | some ``List.nil => return #[]
  | some ``List.cons =>
    let args := context.getAppArgs
    return #[args[1]!] ++ (← contextEntries args[2]!)
  | _ => throwError "cannot enumerate this object context; supply an explicit derivation"

/-- Construct a formula list without changing the source language. -/
def contextExpr (language : Language) (formulas : Array Expr) : MetaM Expr := do
  let type := mkConst language.formulaNamespace
  let mut result ← mkAppOptM ``List.nil #[some type]
  for formula in formulas.reverse do
    result ← mkAppM ``List.cons #[formula, result]
  return result

/-- Construct a membership proof by inspecting the assumption list, not a derivation. -/
private partial def membershipProof (formula context : Expr) : MetaM Expr := do
  let context ← whnf context
  if context.getAppFn.constName? != some ``List.cons then
    throwError "the required formula is absent from the current object context"
  let args := context.getAppArgs
  if ← isDefEq formula args[1]! then
    return ← mkAppOptM ``List.mem_cons_self #[none, some formula, some args[2]!]
  let tail ← membershipProof formula args[2]!
  mkAppM ``List.mem_cons_of_mem #[args[1]!, tail]

/-- Prove source-context inclusion, rejecting facts unavailable after a scope change. -/
private partial def inclusionProof (source target : Expr) : MetaM Expr := do
  if ← isDefEq source target then
    return ← mkAppM ``FormalSystem.Theorems.ProofMode.context_refl #[target]
  let source ← whnf source
  match source.getAppFn.constName? with
  | some ``List.nil => mkAppM ``FormalSystem.Theorems.ProofMode.context_nil #[target]
  | some ``List.cons =>
    let args := source.getAppArgs
    let head ← membershipProof args[1]! target
    let tail ← inclusionProof args[2]! target
    mkAppM ``FormalSystem.Theorems.ProofMode.context_cons #[head, tail]
  | _ =>
    let target ← whnf target
    if target.getAppFn.constName? == some ``List.cons then
      let args := target.getAppArgs
      let rest ← inclusionProof source args[2]!
      return ← mkAppM ``FormalSystem.Theorems.ProofMode.context_weaken_head #[args[1]!, rest]
    throwError "source object context is not available here; supply context correspondence"

/-- Adapt an existing proof using only frame lifting and checked context weakening. -/
def adaptProof (proof : Expr) (target : Judgment) : MetaM Expr := do
  let some source ← judgment? (← inferType proof)
    | throwError "expected a native derivation, not a semantic fact or a validity proof"
  unless source.language == target.language do
    throwError "different object languages; supply an explicit derivation embedding"
  let mut proof := proof
  unless ← isDefEq source.frame target.frame do
    if ← isDefEq source.frame (mkConst ``FormalSystem.ProofSystem.FrameClass.Base) then
      let le ← mkAppM ``FormalSystem.ProofSystem.FrameClass.base_le #[target.frame]
      proof ← mkAppM (← target.language.derivationRule `lift) #[le, proof]
    else
      throwError "different frame classes; supply an explicitly lifted derivation"
  unless ← isDefEq source.context target.context do
    let inclusion ← inclusionProof source.context target.context
    proof ← mkAppM (← target.language.derivationRule `weakening)
      #[source.context, target.context, source.formula, proof, inclusion]
  return proof

/-- Construct the assumption derivation at the current object context. -/
def assumptionProof (judgment : Judgment) (formula : Expr) : MetaM Expr := do
  let member ← membershipProof formula judgment.context
  mkAppOptM (← judgment.language.derivationRule `assumption)
    #[some judgment.frame, some judgment.context, some formula, some member]

/-- Add a user-facing name for existing derivation data. -/
def nameProof (goal : MVarId) (name : Name) (proof : Expr) : MetaM MVarId := do
  let (_, goal) ← goal.note name proof
  return goal

/-- Elaborate a proof term in the current Lean context. -/
def elaborateProof (term : Syntax) : TacticM Expr :=
  Term.elabTerm term none

/-- Apply the native modus-ponens constructor to two derivations. -/
def modusPonens (judgment : Judgment) (implication premise : Expr) : MetaM Expr := do
  let some args ← operatorArgs? judgment.language `imp 2
      (← requireJudgmentFromProof implication).formula
    | throwError "expected an object-language implication"
  mkAppM (← judgment.language.derivationRule `modus_ponens)
    #[judgment.context, args[0]!, args[1]!, implication, premise]
where
  /-- Read the native judgment carried by a derivation term. -/
  requireJudgmentFromProof (proof : Expr) : MetaM Judgment := do
    let some judgment ← judgment? (← inferType proof)
      | throwError "expected a native derivation"
    return judgment

end FormalSystem.Automation.ProofMode
