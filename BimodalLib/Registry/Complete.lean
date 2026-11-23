/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Registry

/-!
# The registration check

`assert_registry_complete` fails when a closed derivation declared in a scanned module has no
registry row. It is what makes the registry complete by construction: a closed derivation added
under `FormalSystem/Theorems/` breaks the build of this library until it is registered.

The check keys on the module a constant is declared in, not on its namespace, and it sees only
modules that are imported where it runs. A module that invokes it over `FormalSystem.Theorems`
imports the root `FormalSystem`, so that every module of the published library is in scope.

A derivation-typed constant is one of three kinds. A **closed derivation** concludes a
derivation from the empty context and has no derivation among its premises. A **context-form
derivation** concludes a derivation from a context that is not syntactically empty. A **rule**
has a derivation among its premises. Only closed derivations are registered; the command logs
the count of each kind so that the boundary is visible.

This module defines the command and does not run it.
-/

namespace BimodalLib

open Lean Meta Elab Command
open FormalSystem.Syntax FormalSystem.ProofSystem

/-- The kind of a derivation-typed constant. -/
inductive DerivationKind
  /-- A derivation from the empty context with no derivation among its premises. -/
  | closed
  /-- A derivation from a context that is not syntactically empty, with no derivation among
  its premises. -/
  | contextForm
  /-- A constant with a derivation among its premises. -/
  | rule
  deriving DecidableEq, Repr

/-- The kind of a constant from its type, or `none` if it does not conclude a derivation. -/
def derivationKind? (type : Expr) : MetaM (Option DerivationKind) :=
  forallTelescope type fun xs body => do
    let body ← whnfR body
    unless body.isAppOfArity ``DerivationTree 3 do return none
    for x in xs do
      let t ← inferType x
      if (t.find? (·.isAppOf ``DerivationTree)).isSome then return some .rule
    if (← whnf body.getAppArgs[1]!).isAppOf ``List.nil then return some .closed
    return some .contextForm

/-- The derivation-typed constants declared in a module whose name has prefix `pfx` and not
prefix `excl`, each with its kind, sorted by name. -/
def scanDerivations (pfx excl : Name) : MetaM (Array (Name × DerivationKind)) := do
  let env ← getEnv
  let mut out := #[]
  for (n, ci) in env.constants.map₁.toList do
    let some idx := env.getModuleIdxFor? n | continue
    let mod := env.header.moduleNames[idx.toNat]!
    unless pfx.isPrefixOf mod && !excl.isPrefixOf mod do continue
    if n.isInternalDetail then continue
    if let some k ← derivationKind? ci.type then out := out.push (n, k)
  return out.qsort (·.1.toString < ·.1.toString)

/-- The registry rows in the environment: each registered declaration with the constant that
holds its row. A row is a constant of type `TheoremEntry` under the registry prefix; the
declaration it registers is read from its name and confirmed against its value, which must
cite that declaration. -/
def registryRows : MetaM (Array (Name × ConstantInfo)) := do
  let env ← getEnv
  let mut out := #[]
  for (n, ci) in env.constants.map₁.toList ++ env.constants.map₂.toList do
    unless ci.type.isConstOf ``TheoremEntry && registryPrefix.isPrefixOf n do continue
    let some v := ci.value? | continue
    let target := n.replacePrefix registryPrefix .anonymous
    unless (v.find? (·.isConstOf target)).isSome do
      throwError "the registry row {n} does not cite the declaration it is named for"
    out := out.push (target, ci)
  return out.qsort (·.1.toString < ·.1.toString)

/-- The declared dual of a row, read from the `dual` argument of its constructor. -/
def rowDual? (ci : ConstantInfo) : Option Name := do
  let v ← ci.value?
  guard (v.isAppOfArity ``TheoremEntry.mk 8)
  let d := v.getAppArgs[7]!
  guard (d.isAppOfArity ``Option.some 2)
  nameOfExpr? d.appArg!

/-- `assert_registry_complete` checks that every closed derivation declared in a module under
`FormalSystem.Theorems`, outside `FormalSystem.Theorems.ProofMode`, has a registry row, and
that every declared dual has one. `assert_registry_complete P excluding Q` scans the modules
with prefix `P` and not prefix `Q` instead. It logs the number of closed derivations,
context-form derivations and rules it found, and fails with the names of the unregistered
closed derivations. Only imported modules are scanned. -/
syntax (name := assertRegistryComplete)
  "assert_registry_complete" (ppSpace ident " excluding " ident)? : command

/-- Elaborates `assert_registry_complete`. -/
@[command_elab assertRegistryComplete] def elabAssertRegistryComplete : CommandElab := fun stx =>
  match stx with
  | `(assert_registry_complete $[$p?:ident excluding $q?:ident]?) => liftTermElabM do
    let pfx := (p?.map (·.getId)).getD `FormalSystem.Theorems
    let excl := (q?.map (·.getId)).getD `FormalSystem.Theorems.ProofMode
    let all ← scanDerivations pfx excl
    let count (k : DerivationKind) := (all.filter (·.2 == k)).size
    let rows ← registryRows
    let registered : NameSet := rows.foldl (fun s r => s.insert r.1) {}
    let closed := (all.filter (·.2 == .closed)).map (·.1)
    logInfo m!"modules under {pfx}, excluding {excl}: {count .closed} closed derivations, \
      {(closed.filter registered.contains).size} of them registered; {count .contextForm} \
      context-form derivations and {count .rule} rules, which are not registered"
    let missing := closed.filter (!registered.contains ·)
    unless missing.isEmpty do
      throwError "{missing.size} closed derivation(s) under {pfx} have no registry row; add \
        a `register_theorem` line for each:{indentD (MessageData.joinSep
          (missing.toList.map (m!"{·}")) Format.line)}"
    let badDuals := rows.filterMap fun (n, ci) =>
      match rowDual? ci with
      | some y => if registered.contains y then none else some m!"{n} (dual := {y})"
      | none => none
    unless badDuals.isEmpty do
      throwError "{badDuals.size} declared dual(s) have no registry row:{indentD
        (MessageData.joinSep badDuals.toList Format.line)}"
  | _ => throwUnsupportedSyntax

end BimodalLib
