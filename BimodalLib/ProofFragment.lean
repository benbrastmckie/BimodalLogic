/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Conservativity.Table
import BimodalLib.Registry.Complete

/-!
# Proofs that leave the cell of their statement

A theorem row is filed by the operators of its statement. Its reference proof may use more: the
proof profile of the registered derivation (`BimodalLib.proofProfile`) is the join of the
profiles of every formula the derivation derives, and it can be larger than the profile of the
statement. This module lists the rows where it is, and requires a reason for each.

A reason is one of two things. Where the conservativity edge out of the statement's cell is
proved at the row's frame class, the proof can be lowered into the cell, and the edge theorem is
the reason. Otherwise the reason is recorded by hand with `record_proof_fragment`, next to the
registration of the theorem.

The proof profile of a row is computed by evaluating `proofProfile` on the registered
derivation, at the row's own frame class and at the canonical schema variables. It is a report:
no theorem depends on it. A row whose proof profile cannot be evaluated is listed as not
computed and needs a recorded reason like any other listed row.

## Main definitions

* `record_proof_fragment X "reason"`: records why the proof of the registered theorem `X` leaves
  the cell of its statement.
* `assert_proof_fragments_recorded`: fails when a registered theorem whose proof leaves the cell
  of its statement has neither a proved edge nor a recorded reason, and when a reason is
  recorded for a theorem whose proof stays inside the cell.
* `BimodalLib.renderProofFragments`: the section of the index.
-/

namespace BimodalLib

open Lean Meta Elab Command
open FormalSystem.ProofSystem

/-- A recorded reason why the reference proof of a registered theorem leaves the cell of its
statement. -/
structure ProofFragmentReason where
  /-- The reason, as the index prints it. -/
  reason : String

/-- The namespace that holds the recorded reasons: the reason for `X` is
`BimodalLib.ProofFragments.X`. -/
def proofFragmentPrefix : Name := `BimodalLib.ProofFragments

/-- Evaluates a closed expression of type `Profile`. -/
unsafe def evalProfileUnsafe (e : Expr) : MetaM Profile :=
  evalExpr Profile (mkConst ``Profile) e

/-- Evaluates a closed expression of type `Profile`, by running the compiled code of the
definitions it mentions. -/
@[implemented_by evalProfileUnsafe]
opaque evalProfile (e : Expr) : MetaM Profile

/-- What the listing holds for one theorem row. -/
structure ProofFragmentRow where
  /-- The registered declaration. -/
  decl : Name
  /-- The frame class of the row. -/
  frameClass : String
  /-- The profile of the statement. -/
  statement : Profile
  /-- The proof profile of the registered derivation, when it could be evaluated. -/
  proof : Option Profile

/-- Whether the row is listed: its proof profile is not included in the profile of its
statement, or could not be evaluated. -/
def ProofFragmentRow.listed (r : ProofFragmentRow) : Bool :=
  match r.proof with
  | some p => !(p.le r.statement)
  | none => true

/-- The proof profile of the registered declaration `n`, with the profile and frame class of its
row. The derivation is taken at the row's own frame class and at the canonical schema
variables. -/
def proofFragmentRow (n : Name) : MetaM ProofFragmentRow := do
  let row := mkConst (rowName n)
  let fc ← mkAppM ``TheoremEntry.frameClass #[row]
  let some fcName := (← whnf fc).constName?
    | throwError "the registry row of {n} has no computable frame class"
  let statement ← evalProfile (← mkAppM ``TheoremEntry.profile #[row])
  let d ← mkAppM ``TheoremEntry.proof #[row, fc, ← mkAppM ``le_refl #[fc], mkConst ``schemaVar]
  let proof ← try
      pure (some (← evalProfile (← mkAppM ``proofProfile #[d])))
    catch _ => pure none
  return { decl := n, frameClass := fcName.getString!, statement, proof }

/-- The recorded reason for the registered declaration `n`, if one is recorded. -/
def recordedReason? (n : Name) : MetaM (Option String) := do
  let c := proofFragmentPrefix ++ n
  unless (← getEnv).contains c do return none
  let .lit (.strVal reason) ← whnf (← mkAppM ``ProofFragmentReason.reason #[mkConst c])
    | throwError "the recorded reason for {n} is not a string literal"
  return some reason

/-- The proved conservativity edges that lower proofs into a cell: for each, the cell, the frame
class it is proved at (`none` for every class) and the theorem. -/
def provedCellEdges : MetaM (Array (Profile × Option String × String)) := do
  let env ← getEnv
  let mut out := #[]
  for (n, ci) in env.constants.map₁.toList ++ env.constants.map₂.toList do
    unless ci.type.isConstOf ``ConservativityEdge do continue
    let c := mkConst n
    let verdict ← whnf (← mkAppM ``ConservativityEdge.verdict #[c])
    unless verdict.getAppFn.isConstOf ``EdgeVerdict.proved do continue
    let cellE ← whnf (← mkAppM ``ConservativityEdge.cell #[c])
    unless cellE.isAppOfArity ``Option.some 2 do continue
    let cell ← evalProfile cellE.appArg!
    let fcE ← whnf (← mkAppM ``ConservativityEdge.frameClass #[c])
    let fc ← if fcE.isAppOfArity ``Option.some 2 then
        pure ((← whnf fcE.appArg!).constName?.map (·.getString!))
      else pure none
    let .lit (.strVal reference) ← whnf (← mkAppM ``ConservativityEdge.reference #[c])
      | throwError "the conservativity edge {n} has no computable reference"
    out := out.push (cell, fc, reference)
  return out

/-- The reason for a listed row: the recorded one, or else a proved edge out of the cell of its
statement at its frame class. -/
def proofFragmentReason? (edges : Array (Profile × Option String × String))
    (r : ProofFragmentRow) : MetaM (Option String) := do
  if let some reason ← recordedReason? r.decl then return some reason
  let covers := edges.find? fun (cell, fc, _) =>
    cell == r.statement && (fc.isNone || fc == some r.frameClass)
  return covers.map fun (_, _, reference) =>
    s!"The proof can be lowered into the cell of the statement: `{reference}`."

/-- The listed rows, each with its reason if it has one, and the registered declarations that
have a recorded reason although their proof stays inside the cell of their statement. -/
def proofFragmentListing :
    MetaM (Array (ProofFragmentRow × Option String) × Array Name × Nat) := do
  let rows ← registryRows
  let edges ← provedCellEdges
  let mut listed := #[]
  let mut stale := #[]
  for (n, _) in rows do
    let r ← proofFragmentRow n
    if r.listed then listed := listed.push (r, ← proofFragmentReason? edges r)
    else if (← recordedReason? n).isSome then stale := stale.push n
  return (listed, stale, rows.size)

/-- The proof profile of a listed row, as text. -/
def ProofFragmentRow.proofName (r : ProofFragmentRow) : String :=
  match r.proof with
  | some p => p.cellName
  | none => "not computed"

/-- The proof-fragment section of the index. -/
def renderProofFragments : MetaM String := do
  let (listed, _, total) ← proofFragmentListing
  let mut out := s!"## Proofs outside the statement cell\n\n{listed.size} of the {total} \
    registered theorems have a reference proof that derives a formula outside the cell of \
    the statement. The cell of a statement is the set of its operators; the proof profile is \
    the set of operators of every formula the registered derivation derives, computed at the \
    row's own frame class. Each listed row has a reason: a proved conservativity edge, by \
    which the proof can be lowered into the cell, or a reason recorded with \
    `record_proof_fragment`.\n"
  unless listed.isEmpty do
    out := out ++ "\n| Declaration | Frame class | Statement cell | Proof profile | Reason |\n"
    out := out ++ "|---|---|---|---|---|\n"
    for (r, reason) in listed do
      out := out ++ s!"| `{r.decl}` | {r.frameClass} | {r.statement.cellName} | \
        {r.proofName} | {reason.getD "none recorded"} |\n"
  return out

/-- `record_proof_fragment X "reason"` records why the reference proof of the registered theorem
`X` leaves the cell of its statement, as the constant `BimodalLib.ProofFragments.X`. The index
prints the reason beside the row. The command fails if `X` has no registry row. -/
syntax (name := recordProofFragment) "record_proof_fragment " ident ppSpace str : command

/-- Elaborates `record_proof_fragment`. -/
@[command_elab recordProofFragment] def elabRecordProofFragment : CommandElab := fun stx => do
  match stx with
  | `(record_proof_fragment $x:ident $reason:str) => liftTermElabM do
    let n ← realizeGlobalConstNoOverloadWithInfo x
    unless (← getEnv).contains (rowName n) do
      throwError "record_proof_fragment: {.ofConstName n} has no registry row"
    let declName := proofFragmentPrefix ++ n
    if (← getEnv).contains declName then
      throwError "record_proof_fragment: a reason is already recorded for {.ofConstName n}"
    let value ← mkAppM ``ProofFragmentReason.mk #[mkStrLit reason.getString]
    addAndCompile <| .defnDecl <| mkDefinitionValEx declName []
      (mkConst ``ProofFragmentReason) value .abbrev .safe [declName]
    addDocStringCore declName
      s!"The recorded reason why the reference proof of `{n}` leaves the cell of its statement."
  | _ => throwUnsupportedSyntax

/-- `assert_proof_fragments_recorded` computes the proof profile of every registered theorem in
scope. It fails with the names of the theorems whose proof leaves the cell of their statement
and that have neither a proved conservativity edge out of that cell nor a reason recorded with
`record_proof_fragment`; and with the names of the theorems that have a recorded reason although
their proof stays inside the cell. It logs the number of rows it listed. -/
syntax (name := assertProofFragmentsRecorded) "assert_proof_fragments_recorded" : command

/-- Elaborates `assert_proof_fragments_recorded`. -/
@[command_elab assertProofFragmentsRecorded] def elabAssertProofFragmentsRecorded :
    CommandElab := fun stx =>
  match stx with
  | `(assert_proof_fragments_recorded) => liftTermElabM do
    let (listed, stale, total) ← proofFragmentListing
    logInfo m!"{total} registered theorems; {listed.size} have a proof outside the cell of \
      the statement"
    let missing := listed.filter (·.2.isNone)
    unless missing.isEmpty do
      throwError "{missing.size} registered theorem(s) have a proof outside the cell of the \
        statement and no reason; add a `record_proof_fragment` line for each:{indentD
          (MessageData.joinSep (missing.toList.map fun (r, _) =>
            m!"{r.decl} (statement cell: {r.statement.cellName}; proof profile: \
              {r.proofName}; at {r.frameClass})") Format.line)}"
    unless stale.isEmpty do
      throwError "{stale.size} recorded reason(s) are for a theorem whose proof stays inside \
        the cell of its statement; remove the `record_proof_fragment` line of each:{indentD
          (MessageData.joinSep (stale.toList.map (m!"{·}")) Format.line)}"
  | _ => throwUnsupportedSyntax

end BimodalLib
