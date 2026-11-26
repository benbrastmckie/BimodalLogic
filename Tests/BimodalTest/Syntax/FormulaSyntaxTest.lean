/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.TemporalViews
import FormalSystem.StarLanguage.Formula
import FormalSystem.Tactic.FormulaSyntax

/-!
# Formula Syntax Test Suite

Operator recognition through the connective signature: `operatorArgs?` reads an operator at any
formula type that has the instances, with the arguments recovered.

## Test Categories

- L⋆: `diamond`, `allFuture`, `dstab` and `next` recognized at `StarFormula`, by head constant and
  by unification with the primitive form
- L: `weakUntil` recognized at `Formula`, event first
- Absence: `dstab` and `stab` at `Formula` raise an error naming the operator and the type
- Rejection: `diamond` against a `neg` term, and `neg` against an atom, return `none`
- Rigid reading: `rigidOperatorArgs?` reads at `StarFormula` and assigns no metavariable
- Building: `formulaApp` builds the constant of the object language, not the signature term
- Per-type names: `operatorConst` names the declaration in the namespace of the type
-/

namespace BimodalTest.Syntax.FormulaSyntaxTest

open Lean Meta Elab
open Lean.Elab.Term (TermElabM elabTerm synthesizeSyntheticMVarsNoPostponing)
open FormalSystem.Syntax
open FormalSystem.PlusLanguage (PlusFormula)
open FormalSystem.StarLanguage (StarFormula)
open FormalSystem.Tactic.FormulaSyntax

/-- Elaborate `fun xs => body`, read `operator` off `body` at the type of `body`, and check the
recovered arguments against `expected`, a list of indices into `xs`. -/
private def expectArgs (operator : Name) (arity : Nat) (term : TermElabM Expr)
    (expected : Option (Array Nat)) : TermElabM Unit := do
  let term ← instantiateMVars (← term)
  lambdaTelescope term fun xs body => do
    let type ← inferType body
    let result ← operatorArgs? type operator arity body
    match result, expected with
    | none, none => pure ()
    | some arguments, some indices =>
      unless arguments == indices.map fun index => xs[index]! do
        throwError "{operator} at {type}: recovered {arguments}"
    | none, some _ => throwError "{operator} at {type}: not recognized"
    | some arguments, none => throwError "{operator} at {type}: recognized with {arguments}"

/-- Run `action` and require the error `message`. -/
private def expectError (message : String) (action : MetaM Unit) : MetaM Unit := do
  let failure ← try action; pure none catch error => pure (some (← error.toMessageData.toString))
  unless failure == some message do
    throwError "expected the error '{message}', got {failure}"

private def elab! (syntax_ : TermElabM Syntax) : TermElabM Expr := do
  let term ← elabTerm (← syntax_) none
  synthesizeSyntheticMVarsNoPostponing
  return term

/-! ## Recognition at L⋆ -/

-- By head constant.
run_elab expectArgs `diamond 1 (elab! `(fun (a : StarFormula) => a.diamond)) (some #[0])
run_elab expectArgs `allFuture 1 (elab! `(fun (a : StarFormula) => a.allFuture)) (some #[0])
run_elab expectArgs `dstab 1 (elab! `(fun (a : StarFormula) => a.dstab)) (some #[0])
run_elab expectArgs `next 1 (elab! `(fun (a : StarFormula) => a.next)) (some #[0])

-- By unification with a term that does not carry the operator's name.
run_elab do
  expectArgs `next 1
    (elab! `(fun (a : StarFormula) => StarFormula.untl StarFormula.bot a)) (some #[0])
run_elab do
  expectArgs `diamond 1
    (elab! `(fun (a : StarFormula) => (a.neg.box).neg)) (some #[0])
run_elab do
  expectArgs `dstab 1
    (elab! `(fun (a : StarFormula) => Sig.dstab a)) (some #[0])
run_elab do
  expectArgs `allFuture 1
    (elab! `(fun (a : StarFormula) => Sig.allFuture a)) (some #[0])

-- Primitives are read through their classes.
run_elab expectArgs `stab 1 (elab! `(fun (a : StarFormula) => a.stab)) (some #[0])
run_elab expectArgs `untl 2 (elab! `(fun (a b : StarFormula) => HasUntl.untl a b)) (some #[0, 1])

/-! ## Recognition at L -/

-- `weakUntil` is event first; the arguments come back in the order they were given.
run_elab do
  expectArgs `weakUntil 2
    (elab! `(fun (a b : Formula) => Formula.weakUntil a b)) (some #[0, 1])
run_elab do
  expectArgs `weakUntil 2
    (elab! `(fun (a b : Formula) => (Formula.untl b a).or b.allFuture)) (some #[0, 1])

/-! ## An operator the type does not have -/

run_meta expectError "operator dstab is not available at FormalSystem.Syntax.Formula" do
  withLocalDeclD `a (mkConst ``Formula) fun a => do
    discard <| operatorArgs? (mkConst ``Formula) `dstab 1 (← mkAppM ``Formula.neg #[a])

run_meta expectError "operator stab is not available at FormalSystem.Syntax.Formula" do
  withLocalDeclD `a (mkConst ``Formula) fun a => do
    discard <| operatorArgs? (mkConst ``Formula) `stab 1 a

/-! ## A formula that is not the operator -/

run_elab expectArgs `diamond 1 (elab! `(fun (a : StarFormula) => a.neg)) none
run_elab expectArgs `diamond 1 (elab! `(fun (a : Formula) => a.neg)) none
run_elab expectArgs `neg 1 (elab! `(fun (p : Atom) => Formula.atom p)) none

/-! ## Rigid reading -/

-- The rigid reader recovers arguments at L⋆, and declines a metavariable formula rather than
-- assign it.
run_meta do
  withLocalDeclD `a (mkConst ``StarFormula) fun a => do
    let type := mkConst ``StarFormula
    let formula ← mkAppM ``StarFormula.diamond #[a]
    unless (← rigidOperatorArgs? type `diamond 1 formula) == some #[a] do
      throwError "rigid diamond at StarFormula: not recovered"
    let hole ← mkFreshExprMVar type
    unless (← rigidOperatorArgs? type `diamond 1 hole).isNone do
      throwError "rigid diamond read a metavariable"
    if ← hole.mvarId!.isAssigned then throwError "rigid diamond assigned a metavariable"

/-! ## Building and per-type names -/

run_meta do
  withLocalDeclD `a (mkConst ``Formula) fun a => do
    let built ← formulaApp .tm `diamond #[a]
    unless built.isAppOfArity ``Formula.diamond 1 do throwError "formulaApp: {built}"
  withLocalDeclD `a (mkConst ``PlusFormula) fun a => do
    let built ← formulaApp .plus `dstab #[a]
    unless built.isAppOfArity ``PlusFormula.dstab 1 do throwError "formulaApp: {built}"
  unless (← operatorConst (mkConst ``StarFormula) `next) == ``StarFormula.next do
    throwError "operatorConst: wrong name at StarFormula"
  unless (← operatorConst? (mkConst ``Formula) `stab).isNone do
    throwError "operatorConst?: stab found at Formula"

run_meta expectError "operator dstab is not available at FormalSystem.Syntax.Formula" do
  discard <| formulaApp .tm `dstab #[]

end BimodalTest.Syntax.FormulaSyntaxTest
