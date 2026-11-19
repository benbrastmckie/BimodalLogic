/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.Rewriting

/-!
# Checked logical rewrite registration

Registration validates the theorem telescope and its native conclusion. Entries record only
the declaration and its fixed simplification orientation, never a logical justification in
metadata. `lsimp only` still considers only explicitly listed rules.
-/

namespace FormalSystem.Automation.ProofMode

open Lean Meta Elab Command

/-- Persistent orientation of a checked native rewrite declaration. -/
structure RewriteRegistration where
  /-- Actual resolved declaration name. -/
  name : Name
  /-- Reverse the declaration's displayed implication/equivalence orientation for simp. -/
  reverse : Bool

/-- Persistent registry of validated schema declarations and their selected orientations. -/
initialize rewriteRegistrationExt :
    SimplePersistentEnvExtension RewriteRegistration (NameMap RewriteRegistration) ←
  registerSimplePersistentEnvExtension {
    addEntryFn := fun entries entry => entries.insert entry.name entry
    addImportedFn := fun imports => imports.foldl (fun entries imported =>
      imported.foldl (fun entries entry => entries.insert entry.name entry) entries) {}
  }

/-- Inspect a named rule's type, including its explicit premises, before adding metadata. -/
def validateRewriteDeclaration (name : Name) : TermElabM Unit := withNewMCtxDepth do
  let proof ← mkConstWithFreshMVarLevels name
  let (parameters, _, type) ← forallMetaTelescopeReducing (← inferType proof)
  let some j ← judgment? type | throwError "rewrite declaration must return a native derivation"
  unless ← isDefEq j.context (← contextExpr j.language #[]) do
    throwError "registered rewrite schemas must have an empty logical context"
  discard <| readRewriteEvidence (mkAppN proof parameters)

/-- Default registered orientation, without inspecting the declaration's value. -/
def registeredRewriteOrientation (proof : Expr) : MetaM Bool := do
  let some name := proof.getAppFn.constName? | return false
  return (rewriteRegistrationExt.getState (← getEnv) |>.find? name).map (·.reverse) |>.getD false

/-- Register a checked native rewrite schema and its fixed simplification orientation. -/
syntax (name := registerLrewrite) "register_lrewrite " ident (ppSpace &"reverse")? : command

private def registerRule (name : Syntax) (reverse : Bool) : CommandElabM Unit := do
  let resolved ← liftTermElabM do
    let resolved ← realizeGlobalConstNoOverloadWithInfo name
    validateRewriteDeclaration resolved
    return resolved
  modifyEnv (rewriteRegistrationExt.addEntry · ⟨resolved, reverse⟩)

elab_rules : command
  | `(command| register_lrewrite $name:ident) => registerRule name false
  | `(command| register_lrewrite $name:ident reverse) => registerRule name true

end FormalSystem.Automation.ProofMode
