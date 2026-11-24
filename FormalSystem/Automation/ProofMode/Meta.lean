/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Tactic.FormulaSyntax
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

export FormalSystem.Tactic.FormulaSyntax
  (formulaApp operatorArgs? rigidOperatorArgs?)

open FormalSystem.Tactic.FormulaSyntax (Language)

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

/-- Native derivation type constructor. -/
def _root_.FormalSystem.Tactic.FormulaSyntax.Language.derivationName : Language → Name
  | .tm => ``FormalSystem.ProofSystem.DerivationTree
  | .plus => ``FormalSystem.PlusLanguage.PlusDerivationTree

/-- Checked native constructor and structural-rule declarations. -/
def _root_.FormalSystem.Tactic.FormulaSyntax.Language.derivationRule
    (language : Language) (rule : Name) : MetaM Name := do
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

/-- Read the judgment carried by an elaborated native proof. -/
def proofJudgment (proof : Expr) : MetaM Judgment := do
  let some judgment ← judgment? (← inferType proof)
    | throwError "expected a native derivation"
  return judgment

/-- User-facing symbol of a registered unary operator. -/
def operatorSymbol : Name → String
  | `allFuture => "G"
  | `allPast => "H"
  | `box => "□"
  | `stab => "⊡"
  | `next => "X"
  | `prev => "Y"
  | operator => operator.toString

/-- Collect explicit telescope parameters and implicit holes inserted by term elaboration. -/
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
  Term.withoutErrToSorry (Term.elabTerm term none)

/-- Apply the native modus-ponens constructor to two derivations. -/
def modusPonens (judgment : Judgment) (implication premise : Expr) : MetaM Expr := do
  let some args ← operatorArgs? judgment.language `imp 2
      (← proofJudgment implication).formula
    | throwError "expected an object-language implication"
  mkAppM (← judgment.language.derivationRule `modus_ponens)
    #[judgment.context, args[0]!, args[1]!, implication, premise]

end FormalSystem.Automation.ProofMode
