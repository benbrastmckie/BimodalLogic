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
  let name := language.formulaNamespace ++ operator
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
      proof ← mkAppM (target.language.derivationName ++ `lift) #[le, proof]
    else
      throwError "different frame classes; supply an explicitly lifted derivation"
  unless ← isDefEq source.context target.context do
    let inclusion ← inclusionProof source.context target.context
    proof ← mkAppM (target.language.derivationName ++ `weakening)
      #[source.context, target.context, source.formula, proof, inclusion]
  return proof

/-- Construct the assumption derivation at the current object context. -/
def assumptionProof (judgment : Judgment) (formula : Expr) : MetaM Expr := do
  let member ← membershipProof formula judgment.context
  mkAppOptM (judgment.language.derivationName ++ `assumption)
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
  mkAppM (judgment.language.derivationName ++ `modus_ponens)
    #[judgment.context, args[0]!, args[1]!, implication, premise]
where
  /-- Read the native judgment carried by a derivation term. -/
  requireJudgmentFromProof (proof : Expr) : MetaM Judgment := do
    let some judgment ← judgment? (← inferType proof)
      | throwError "expected a native derivation"
    return judgment

end FormalSystem.Automation.ProofMode
