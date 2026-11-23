/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Registry

/-!
# Pairing a second proof with a registered statement

A statement is registered once and may be proved several times. `reprove X as Y := t`
elaborates the term `t` against the type of the registered declaration `X` and declares `Y`
with that type, so a second proof cannot drift from the statement it is a proof of: a proof of
anything else is a type error. The command then adds a row of type `BimodalLib.ReproofEntry`,
whose `proof` field cites `Y` at the statement of the row of `X`. The pairing is therefore a
term the kernel has checked, and not a naming convention.

## Main definitions

* `BimodalLib.ReproofEntry`: the row of the registered statement together with the second
  proof, at that row's statement.
* `reprove X as Y := t`: the pairing command. The row of `Y` is the constant
  `BimodalLib.Reproofs.Y`, with the full name of `Y` after the prefix.
-/

namespace BimodalLib

open Lean Meta Elab Command
open FormalSystem.Syntax FormalSystem.ProofSystem

/-- A second proof of a registered statement. -/
structure ReproofEntry where
  /-- The row of the registered statement. -/
  entry : TheoremEntry
  /-- The second proof, at the statement of that row. -/
  proof : ∀ fc, entry.frameClass ≤ fc → ∀ v, DerivationTree fc [] (entry.stmt v)

/-- The namespace that holds the pairing rows: the row of `Y` is `BimodalLib.Reproofs.Y`. -/
def reproofPrefix : Name := `BimodalLib.Reproofs

/-- `reprove X as Y := t` declares `Y` as a second proof of the statement registered for `X`.
The term `t` is elaborated against the type of `X`, so it is a type error for `t` to prove
anything else. The command also adds the row `BimodalLib.Reproofs.Y`, of type
`BimodalLib.ReproofEntry`, which pairs `Y` with the registry row of `X`. It fails if `X` has no
registry row. `Y` is declared in the current namespace. -/
syntax (name := reproveAs) (docComment)? "reprove " ident " as " ident " := " term : command

/-- Elaborates `reprove`. -/
@[command_elab reproveAs] def elabReproveAs : CommandElab := fun stx => do
  match stx with
  | `($[$doc?:docComment]? reprove $x:ident as $y:ident := $t:term) =>
    let ns ← getCurrNamespace
    liftTermElabM do
      let n ← realizeGlobalConstNoOverloadWithInfo x
      unless (← getEnv).contains (rowName n) do
        throwError "reprove: {.ofConstName n} has no registry row; register it with \
          `register_theorem` first"
      let declName := ns ++ y.getId
      if (← getEnv).contains declName then
        throwError "reprove: {declName} has already been declared"
      let type := (← getConstInfo n).type
      let val ← Term.withoutErrToSorry do
        let v ← Term.elabTermEnsuringType t type
        Term.synthesizeSyntheticMVarsNoPostponing
        instantiateMVars v
      if val.hasMVar then
        throwError "reprove: the proof of {declName} has unresolved metavariables"
      addAndCompile <| .defnDecl <| mkDefinitionValEx declName [] type val
        (.regular (getMaxHeight (← getEnv) val + 1)) .safe [declName]
      addDeclarationRangesFromSyntax declName stx y
      Term.addTermInfo' y (mkConst declName) (isBinder := true)
      match doc? with
      | some doc => addDocString declName (mkNullNode #[]) doc
      | none => addDocStringCore declName s!"A second proof of the statement registered for `{n}`."
      let row ← mkTheoremEntry declName none
      let pairing ← mkAppM ``ReproofEntry.mk #[mkConst (rowName n), row.getAppArgs[3]!]
      let pairingName := reproofPrefix ++ declName
      addAndCompile <| .defnDecl <| mkDefinitionValEx pairingName [] (mkConst ``ReproofEntry)
        (← instantiateMVars pairing) .abbrev .safe [pairingName]
      addDocStringCore pairingName
        s!"The pairing row of `{declName}`: a second proof of the statement registered for `{n}`."
  | _ => throwUnsupportedSyntax

end BimodalLib
