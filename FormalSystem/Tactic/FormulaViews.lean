/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Tactic.FormulaSyntax
import Lean.Elab.Tactic.Rewrite

/-!
# Formula views

A view names an equation between two formulas. Both directions use the same registered equation.
The definition and metadata layers are shared by tactic clients independently of their judgments.
-/

assert_not_exists FormalSystem.ProofSystem.DerivationTree
  FormalSystem.PlusLanguage.PlusDerivationTree

namespace FormalSystem.Tactic.FormulaViews

open Lean Meta Elab Tactic Command
open FormalSystem.Syntax (Formula)
open FormalSystem.PlusLanguage (PlusFormula)

/-- One equation for one formula type and public view name. -/
structure View where
  /-- Name used by the two view tactics. -/
  name : Name
  /-- Type of the two formulas. -/
  formulaType : Name
  /-- Equation identifying the named and expanded forms. -/
  equation : Name

initialize views : SimplePersistentEnvExtension View (Array View) ←
  registerSimplePersistentEnvExtension {
    addImportedFn := fun entries => entries.foldl (· ++ ·) #[]
    addEntryFn := Array.push
  }

namespace TM

private theorem diamond_eq (A : Formula) : A.diamond = A.neg.box.neg := rfl
private theorem next_eq (A : Formula) : A.next = Formula.untl Formula.bot A := rfl
private theorem prev_eq (A : Formula) : A.prev = Formula.snce Formula.bot A := rfl

end TM

namespace TMPlus

private theorem diamond_eq (A : PlusFormula) : A.diamond = A.neg.box.neg := rfl
private theorem dstab_eq (A : PlusFormula) : A.dstab = A.neg.stab.neg := rfl
private theorem next_eq (A : PlusFormula) : A.next = PlusFormula.untl PlusFormula.bot A := rfl
private theorem prev_eq (A : PlusFormula) : A.prev = PlusFormula.snce PlusFormula.bot A := rfl

end TMPlus

/-- Views available for the two core languages. -/
private def coreViews : Array View := #[
  ⟨`diamond, ``Formula, ``TM.diamond_eq⟩, ⟨`next, ``Formula, ``TM.next_eq⟩,
  ⟨`prev, ``Formula, ``TM.prev_eq⟩,
  ⟨`diamond, ``PlusFormula, ``TMPlus.diamond_eq⟩, ⟨`dstab, ``PlusFormula, ``TMPlus.dstab_eq⟩,
  ⟨`next, ``PlusFormula, ``TMPlus.next_eq⟩, ⟨`prev, ``PlusFormula, ``TMPlus.prev_eq⟩]

/-- Built-in rows and extensions share the same lookup. -/
private def allViews (env : Environment) : Array View := coreViews ++ views.getState env

/-- Register a formula-data equation with no proof premises. -/
syntax (name := registerLview) "register_lview " ident ppSpace ident : command

elab_rules : command
  | `(register_lview $view:ident $equation:ident) => do
    let equationName ← liftCoreM <| realizeGlobalConstNoOverloadWithInfo equation
    let formulaType ← liftTermElabM do
      forallTelescopeReducing (← getConstInfo equationName).type fun args type => do
        let some (dataType, _, _) := type.eq?
          | throwErrorAt equation "expected a formula equality"
        let some dataName := dataType.constName?
          | throwErrorAt equation "expected a concrete formula type"
        unless dataName == ``Formula || dataName == ``PlusFormula do
          throwErrorAt equation "expected an equality of Formula or PlusFormula"
        for arg in args do
          if ← isProp (← inferType arg) then
            throwErrorAt equation "a formula view cannot require proof premises"
        pure dataName
    if (allViews (← getEnv)).any
        (fun row => row.name == view.getId && row.formulaType == formulaType) then
      throwErrorAt view "view already registered for {formulaType}"
    modifyEnv fun env => views.addEntry env ⟨view.getId, formulaType, equationName⟩

/-- Change how a formula is written at a goal or named hypothesis. -/
def applyView (name : TSyntax `ident) (location : Option (TSyntax `ident))
    (fold : Bool) : TacticM Unit := withMainContext do
  let rows := (allViews (← getEnv)).filter (fun row => row.name == name.getId)
  if rows.isEmpty then throwErrorAt name "unknown formula view {name.getId}"
  let localId ← location.mapM fun ident => getFVarId ident
  for row in rows do
    let saved ← saveState
    try
      let equation := mkCIdent row.equation
      match localId with
      | some id => rewriteLocalDecl equation fold id
      | none => rewriteTarget equation fold
      return
    catch _ =>
      saved.restore
  throwErrorAt name "view {name.getId} does not match a formula in this location"

/-- Expand a named formula view using its defining equation. -/
syntax (name := lunfold) "lunfold " ident (ppSpace &"at" ppSpace ident)? : tactic

/-- Fold the expansion of a named formula view. -/
syntax (name := lfold) "lfold " ident (ppSpace &"at" ppSpace ident)? : tactic

elab_rules : tactic
  | `(tactic| lunfold $view:ident $[at $loc:ident]?) => applyView view loc false
  | `(tactic| lfold $view:ident $[at $loc:ident]?) => applyView view loc true

end FormalSystem.Tactic.FormulaViews
