/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.PlusLanguage.Formula
import Lean

/-! Formula syntax for TM and TM⁺ metaprogramming. -/

namespace FormalSystem.Tactic.FormulaSyntax

open Lean Meta

/-- Object languages sharing the formula planner. -/
inductive Language where
  | tm
  | plus
  deriving BEq

/-- Namespace of formula constructors and derived operators. -/
def Language.formulaNamespace : Language → Name
  | .tm => ``FormalSystem.Syntax.Formula
  | .plus => ``FormalSystem.PlusLanguage.PlusFormula

/-- Select the declaration for the object language. -/
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

end FormalSystem.Tactic.FormulaSyntax
