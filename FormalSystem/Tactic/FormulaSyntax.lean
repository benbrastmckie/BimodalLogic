/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.PlusLanguage.Formula
import FormalSystem.Syntax.Connectives
import Lean.Meta.AppBuilder
import Lean.Meta.CollectMVars

/-! Formula syntax for metaprogramming: operators are recognized through the connective
signature at any formula type, and built under the names of TM and TM⁺. -/

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

/-- The formula type of the object language. -/
def Language.formulaType (language : Language) : Expr :=
  mkConst language.formulaNamespace

/-- The declaration spelling `operator` in the namespace of the formula type `type`, such as
`StarFormula.diamond` for `diamond` at `StarFormula`, when there is one. -/
def operatorConst? (type : Expr) (operator : Name) : MetaM (Option Name) := do
  let some typeName := (← whnfR type).getAppFn.constName? | return none
  let name := typeName ++ operator
  return if (← getEnv).contains name then some name else none

/-- The declaration spelling `operator` in the namespace of the formula type `type`. A type
without the operator is an error. -/
def operatorConst (type : Expr) (operator : Name) : MetaM Name := do
  let some name ← operatorConst? type operator
    | throwError "operator {operator} is not available at {type}"
  return name

/-- The signature declarations spelling `operator`: the derived operator of `Sig`, then the
class projection of the primitive. -/
def signatureNames (operator : Name) : MetaM (Array Name) := do
  let .str .anonymous spelling := operator | return #[]
  let derived := `FormalSystem.Syntax.Sig ++ operator
  let primitive := (`FormalSystem.Syntax).str ("Has" ++ spelling.capitalize) ++ operator
  return #[derived, primitive].filter (← getEnv).contains

/-- Apply the signature declaration `name` at the formula type `type` to fresh metavariable
arguments, returning the application and its explicit arguments. The result is `none` when
`type` lacks an instance the declaration needs. -/
def signatureProbe? (name : Name) (type : Expr) : MetaM (Option (Expr × Array Expr)) := do
  let function ← mkConstWithFreshMVarLevels name
  let (arguments, binders, _) ← forallMetaTelescope (← inferType function)
  let some carrier := arguments[0]? | return none
  unless ← isDefEq carrier type do return none
  let mut explicit := #[]
  for argument in arguments, binder in binders do
    if binder.isInstImplicit then
      let some inst ← synthInstance? (← instantiateMVars (← inferType argument)) | return none
      argument.mvarId!.assign inst
    else if binder.isExplicit then explicit := explicit.push argument
  return some (mkAppN function arguments, explicit)

/-- The term `operator` is matched against at `type`: the signature operator when `type` has its
instances, otherwise the declaration in the namespace of `type`. An operator with neither is an
error. -/
def operatorProbe (type : Expr) (operator : Name) (arity : Nat) :
    MetaM (Expr × Array Expr) := do
  for name in ← signatureNames operator do
    if let some (candidate, arguments) ← signatureProbe? name type then
      unless arguments.size == arity do
        throwError "operator {operator} takes {arguments.size} arguments, not {arity}"
      return (candidate, arguments)
  let name ← operatorConst type operator
  let arguments ← (List.range arity).toArray.mapM fun _ => mkFreshExprMVar type
  return (← mkAppM name arguments, arguments)

/-- Build an operator application through the declaration of the object language, so that the
result displays and rewrites under the name of that language. -/
def formulaApp (language : Language) (operator : Name) (arguments : Array Expr) : MetaM Expr := do
  mkAppM (← operatorConst language.formulaType operator) arguments

/-- Read a constructor or derived operator of the formula type `type`, retaining its object
arguments. The head constant is compared with the declaration in the namespace of `type` first;
otherwise the formula is unified with the signature operator at `type`. An operator `type` does
not have is an error. -/
def operatorArgs? (type : Expr) (operator : Name) (arity : Nat)
    (formula : Expr) : MetaM (Option (Array Expr)) := do
  let formula ← instantiateMVars formula
  if let some name ← operatorConst? type operator then
    if formula.getAppFn.constName? == some name then
      return some formula.getAppArgs
  let saved ← saveState
  let (candidate, arguments) ← operatorProbe type operator arity
  if ← isDefEq formula candidate then
    return some (← arguments.mapM instantiateMVars)
  saved.restore
  return none

/-- Read a rule's syntax without constraining its pre-existing formula metavariables. Fresh
probe arguments must resolve entirely to expressions already present in the statement. -/
def rigidOperatorArgs? (type : Expr) (operator : Name) (arity : Nat)
    (formula : Expr) : MetaM (Option (Array Expr)) := do
  let formula ← instantiateMVars formula
  if formula.getAppFn.isMVar then return none
  let original ← getMVars formula
  let saved ← saveState
  let result ← operatorArgs? type operator arity formula
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
