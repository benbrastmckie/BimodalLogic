/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Diagnostics.Record
import BimodalLib.Registry

/-!
# The RE-PROVE and COMPARE record emitters

Two command elaborators, `#reprove_record` and `#compare_record`. Each prints **exactly one** JSON
object per invocation to stdout, in the schema of `BimodalLib/Diagnostics/Record.lean`, and the
measuring script collects them. No command here writes a tracked file as an elaboration side
effect: a command that did would be both untestable and non-composable, and the two properties the
measuring script needs most — that a record can be produced from a probe outside the build graph,
and that two runs from one commit agree byte for byte — both depend on the record being a value
rather than a write.

## `#reprove_record` is a wrapper, not a reader, and that is the whole point

```
#reprove_record myMirror stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lapply,lexact" escape 0 in
def myMirror (A B : Formula) : [A.imp B, A] ⊢ B := by
  lstart hAB hA; lapply hAB; lexact hA
```

Heartbeats and wall-clock elaboration time can only be observed **during** the elaboration that
produces a declaration; once the declaration is in the environment both figures are gone. So the
command wraps the declaration it measures, reading `IO.getNumHeartbeats` and `IO.monoMsNow` either
side of `elabCommand`, exactly as Mathlib's `#count_heartbeats in` does, and divides the heartbeat
delta by 1000 to report the same unit that command reports. The named identifier is then looked up
in the environment the inner command just extended, which is where the unknown-declaration and
no-value error paths come from: a wrapper whose inner command declares something else, or declares
an `axiom` or an `opaque`, is a mistake worth a message rather than a silent zero.

The inner command is elaborated with `Elab.async false`, which is required rather than preferred:
with the default on, a declaration body is elaborated in a background task, so the constant would
not be in the environment when this elaborator resumes, and the heartbeat delta would exclude the
body's own elaboration.

`lake env lean -Ddiagnostics.commit=...`. That is the route in use; the tracked probe therefore
declaration into a failure and destroy the measurement, so lifting it is required -- but it is
lifted by the probe, at file scope, where `specs/evidence/` is the one place a bare
`set_option maxHeartbeats 0` is correct. Wrapping it here instead is not available: a `command`
category quotation cannot splice a nested command (`command.pseudo.antiquot` is unimplemented),
and setting the option around `elabCommand` would silently change the measurement's conditions
without the probe saying so.

## `#compare_record` is a reader

```
#compare_record myMirror referenceProof kind "hand" lengths 3 7
```

It reads two already-elaborated declarations — the script and the reference — and needs no timing,
because a comparison is of two finished things.

## What is derived and what is supplied

Derived from the environment, never retyped: `term_size` (`ConstantInfo.value?` through
`Lean.Expr.sizeWithoutSharing`), `axioms` (`Lean.collectAxioms`, the same collector
`#print axioms` uses), `frame_class` (read off the declaration's own type when the type names a
closed `FrameClass` constructor), `fragment` (from the registry row when the statement has one),
and `derivation_size` / `derivation_height` (by reducing this library's own measures on the value,
null when the statement is schematic and so has no closed instance to reduce).

Supplied by the caller: the stage, the outcome, the failure class, the tactic list, the escape
size, the reference kind and the two lengths. These are facts about the script, not about the
term, and nothing in the environment knows them.

## The stamp route, and which one is in use

`commit`, `date` and `command` are carried as **registered string options**
(`diagnostics.commit`, `diagnostics.date`, `diagnostics.command`), set from outside by
`lake env lean -Ddiagnostics.commit=...`. That is the route in use; the tracked probe therefore
stays stamp-free, which is what the measuring script's zeroed-stamp `--json` determinism contract
wants anyway. The fallback route — the script writing stamp lines into a scratch copy of the probe
— is not in use and is not implemented, because `-D` carries a string option without complaint.

A fourth option, `diagnostics.zeroTimings`, zeroes `heartbeats` and `elab_ms`. Those two fields
are the only ones that are not a function of the commit and the toolchain, so zeroing them is what
makes a record byte-stable -- which is what a `#guard_msgs` test on a whole record needs, and what
the measuring script's `--json` mode compares. The baseline document quotes the unzeroed figures.

An unset option records the empty-but-explicit value `"unstamped"` rather than an empty string, so
a record produced by a bare `lake env lean` is identifiable as unstamped rather than looking like
a stamped record whose stamp was lost.

## Error messages

Every `throwError` path below is pinned, one for one, by a `#guard_msgs` negative test in
`Tests/BimodalLibTest/DiagnosticsTest.lean`, and every message is reproduced verbatim in
`docs/reference/diagnostics.md` so the text has one documented home.
-/

open Lean Lean.Elab Lean.Elab.Command Lean.Meta
open FormalSystem.ProofSystem (FrameClass)

namespace BimodalLib.Diagnostics

/-! ## The stamp options -/

register_option diagnostics.commit : String := {
  defValue := ""
  descr := "The commit a diagnostics record is measured at; set with -Ddiagnostics.commit=<sha>."
}

register_option diagnostics.date : String := {
  defValue := ""
  descr := "The UTC date a diagnostics record is measured on; set with -Ddiagnostics.date=<date>."
}

register_option diagnostics.zeroTimings : Bool := {
  defValue := false
  descr := "Record 0 for heartbeats and elab_ms, so a record is byte-stable across runs; \
set with -Ddiagnostics.zeroTimings=true."
}

register_option diagnostics.command : String := {
  defValue := ""
  descr := "The command line that produced a diagnostics record; set with -Ddiagnostics.command=."
}

/-- The value recorded for a stamp option that was never set. -/
def unstamped : String := "unstamped"

/-- A stamp option's value, or `unstamped` when it is empty. -/
private def stampOr (s : String) : String := if s.isEmpty then unstamped else s

/--
Whether the two volatile timing fields are to be zeroed.

Heartbeats and wall-clock milliseconds are the only fields of a record that are not a function of
the commit and the toolchain, so they are the only obstacle to a byte-stable record. Zeroing them
on request is what lets a `#guard_msgs` test pin a whole record, and what lets the measuring
script's `--json` mode compare two runs byte for byte without comparing the numbers the figures
are *for*. The baseline document quotes the unzeroed figures.
-/
def readZeroTimings : CommandElabM Bool := do
  return diagnostics.zeroTimings.get (← getOptions)

/-- Read the three stamp options out of the ambient option set. -/
def readStamps : CommandElabM (String × String × String) := do
  let opts ← getOptions
  return (stampOr (diagnostics.commit.get opts),
          stampOr (diagnostics.date.get opts),
          stampOr (diagnostics.command.get opts))

/-! ## Environment readers -/

/--
Resolve a declaration name written in the command against the namespace the command appears in.

A command elaborator sees the identifier as written, so `#reprove_record myMirror ... in def
myMirror ...` inside `namespace Foo` names `myMirror` while the declaration it wraps is
`Foo.myMirror`. Candidates are tried innermost namespace first, then each enclosing one, then the
bare name, so the nearest declaration wins -- the same direction Lean's own name resolution
prefers.

The resolved `ConstantInfo` is returned with the name, so that this is the module's **single**
unknown-declaration gate. A separate lookup helper beside it would carry a second copy of the same
message that no caller could reach, and an unreachable `throwError` is one a `#guard_msgs` test
cannot pin.
-/
def resolveDeclName (base : Name) : CommandElabM (Name × ConstantInfo) := do
  let env ← getEnv
  let mut cands : List Name := []
  let mut cur ← getCurrNamespace
  while !cur.isAnonymous do
    cands := cands ++ [cur ++ base]
    cur := cur.getPrefix
  cands := cands ++ [base]
  for c in cands do
    if let some info := env.find? c then
      return (c, info)
  throwError "diagnostics: unknown declaration `{base}`"

/--
The declaration's elaborated value. A constant that holds no value -- an `axiom`, an `opaque`, or
a constructor -- is a mistake worth a message rather than a silent zero.
-/
def valueOf (declName : Name) (info : ConstantInfo) : CommandElabM Expr := do
  match info.value? with
  | none => throwError "diagnostics: declaration `{declName}` has no value to measure"
  | some v => return v

/-- The axiom set a declaration depends on, from the same collector `#print axioms` uses. -/
def axiomsOf (declName : Name) : CommandElabM (List String) := do
  let axs ← collectAxioms declName
  return (axs.toList.map (·.toString))

/--
The frame class named in a declaration's type, when the type names a closed `FrameClass`
constructor. A schematic statement abstracting over the frame class has none, and records
`"schematic"` rather than guessing one.

Named `frameClassOfType` and not `frameClassOf`: `BimodalLib.frameClassOf` already exists in
`BimodalLib/Registry.lean`, and `check-module-invariants.sh` C17's dead-declaration census keys on
a declaration's last dot-segment, so two declarations sharing a base name mask each other and
neither can ever be reported dead.
-/
def frameClassOfType (info : ConstantInfo) : CommandElabM String := do
  let found ← liftTermElabM <| Meta.MetaM.run' do
    let mut result : Option String := none
    let ty := info.type
    for sub in (ty.getAppArgs.toList ++ [ty]) do
      if result.isNone then
        if let some s := frameClassCtor? sub then
          result := some s
    -- Look one level deeper: the frame class is an argument of the judgment, which is itself
    -- under the statement's binders.
    if result.isNone then
      let body := ty.getForallBody
      for sub in body.getAppArgs.toList do
        if result.isNone then
          if let some s := frameClassCtor? sub then
            result := some s
    return result
  return found.getD "schematic"
where
  /-- The constructor name of a closed `FrameClass` expression, if it is one. -/
  frameClassCtor? (e : Expr) : Option String :=
    match e.getAppFn with
    | .const n _ =>
      match n with
      | ``FrameClass.Base => some "Base"
      | ``FrameClass.Dense => some "Dense"
      | ``FrameClass.ZTime => some "ZTime"
      | ``FrameClass.RTime => some "RTime"
      | _ => none
    | _ => none

/--
The fragment of a statement, read from its registry row when it has one. Every mirror measured by
the proof-mode cost baseline is unregistered, and records `"unregistered"` rather than an empty
string: a reader can then tell an unregistered mirror from a registry key at a glance.
-/
def fragmentOf (declName : Name) : CommandElabM String := do
  let env ← getEnv
  let row := BimodalLib.rowName declName
  if env.find? row |>.isNone then
    return "unregistered"
  let reduced ← liftTermElabM <| Meta.MetaM.run' do
    let e ← Meta.mkAppM ``BimodalLib.TheoremEntry.fragment #[mkConst row]
    try
      let w ← Meta.whnf e
      return match w.getAppFn with
        | .const n _ => some n.getString!
        | _ => none
    catch _ => return none
  return reduced.getD "unregistered"

/--
The identifier a record is keyed by: the registry key when the statement has a row, and the
`data/`-style unregistered identifier otherwise.
-/
def statementIdOf (declName : Name) : CommandElabM String := do
  let env ← getEnv
  if env.find? (BimodalLib.rowName declName) |>.isSome then
    return declName.toString
  return unregisteredStatementId declName.toString

/--
Evaluate a closed `Nat`-valued expression by **compiled** evaluation, as `#eval` does, returning
`none` when it cannot be evaluated.

Reduction is not an alternative here, and that was measured rather than assumed: `whnf` at `.all`
transparency and `Meta.reduce` with proofs and types both unskipped each reduce the *argument* of
`derivationSize` to constructor form and then leave the application itself unreduced, so
`Meta.evalNat` sees no literal. Compiled evaluation is what `#eval derivationSize d` already does
successfully on a closed instance, which is the measure's documented access route.

The `@[implemented_by]` pattern is how a `MetaM` action reaches `unsafe` compiled evaluation: the
safe body is the conservative answer, and the unsafe implementation is what actually runs.
-/
unsafe def evalNatExprUnsafe (e : Expr) : Meta.MetaM (Option Nat) := do
  try
    return some (← Meta.evalExpr Nat (mkConst ``Nat) e)
  catch _ =>
    return none

@[implemented_by evalNatExprUnsafe]
def evalNatExpr (_e : Expr) : Meta.MetaM (Option Nat) := return none

/--
The node count and height of the derivation a declaration's value builds, by reducing this
library's own measures on it.

Both are `none` when the statement is schematic — a value under a binder has no closed instance to
reduce — and that is a property of the measure rather than a gap in this emitter; see
`BimodalLib/Diagnostics/Size.lean`.
-/
def derivationMeasuresOf (declName : Name) (info : ConstantInfo) :
    CommandElabM (Option Nat × Option Nat) := do
  if info.type.isForall then
    return (none, none)
  let plus := isPlusJudgment info.type
  liftTermElabM <| Meta.MetaM.run' do
    let v := mkConst declName
    let sizeFn :=
      if plus then ``BimodalLib.Diagnostics.plusDerivationSize
      else ``BimodalLib.Diagnostics.derivationSize
    let heightFn :=
      if plus then ``FormalSystem.PlusLanguage.PlusDerivationTree.height
      else ``FormalSystem.ProofSystem.DerivationTree.height
    -- `mkAppM`, not `mkApp`: both measures take the frame class, the context and the formula as
    -- implicit arguments, so a bare `mkApp` puts the derivation into the frame-class slot and the
    -- evaluation fails on a type mismatch instead of on anything real.
    let size ← evalNatExpr (← Meta.mkAppM sizeFn #[v])
    let height ← evalNatExpr (← Meta.mkAppM heightFn #[v])
    return (size, height)
where
  /-- Whether the judgment is a TM⁺ one, so that the TM⁺ measures are the ones to evaluate. -/
  isPlusJudgment (ty : Expr) : Bool :=
    match ty.getAppFn with
    | .const n _ => n == ``FormalSystem.PlusLanguage.PlusDerivationTree
    | _ => false

/-! ## Parsers for the closed enumerations

Each of these is a `throwError` path, because the whole point of a closed enumeration is that an
out-of-enum value is refused at the emitter rather than recorded and discovered downstream.
-/

/-- Read a stage key, refusing anything outside the closed list. -/
def parseStage (s : String) : CommandElabM Stage := do
  match Stage.ofKey? s with
  | some st => return st
  | none =>
    throwError "diagnostics: `{s}` is not a stage; expected one of {Stage.all.map Stage.key}"

/-- Read an outcome key, refusing anything outside the closed list. -/
def parseOutcome (s : String) : CommandElabM Outcome := do
  match Outcome.ofKey? s with
  | some o => return o
  | none =>
    throwError
      "diagnostics: `{s}` is not an outcome; expected one of {Outcome.all.map Outcome.key}"

/--
Read a failure class key. The literal `none` is the absent value, which is what a script closed by
the mode's rules alone records; anything else outside the closed list is refused.
-/
def parseFailureClass (s : String) : CommandElabM (Option FailureClass) := do
  if s == "none" then return none
  match FailureClass.ofKey? s with
  | some f => return some f
  | none =>
    let expected := FailureClass.all.map FailureClass.key
    throwError
      "diagnostics: `{s}` is not a failure class; expected `none` or one of {expected}"

/-- Read a reference kind key, refusing anything outside the closed list. -/
def parseReferenceKind (s : String) : CommandElabM ReferenceKind := do
  match ReferenceKind.ofKey? s with
  | some k => return k
  | none =>
    let expected := ReferenceKind.all.map ReferenceKind.key
    throwError "diagnostics: `{s}` is not a reference kind; expected one of {expected}"

/-- Split a comma-separated tactic list, dropping empty entries and preserving first-use order. -/
def parseTactics (s : String) : List String :=
  (s.splitOn ",").map (fun t => t.trimAscii.toString) |>.filter (fun t => !t.isEmpty)

/-! ## `#reprove_record` -/

/--
`#reprove_record <decl> stage <s> outcome <s> failure <s> tactics <s> escape <n> in <command>`
elaborates the enclosed command while measuring it, then prints one RE-PROVE record for the named
declaration.

The stage is taken as a string rather than fixed to `reprove`, so that a mis-stamped probe is
refused by `parseStage` rather than silently recorded under the wrong key, and so that this one
syntax remains usable by the reserved stages' emitters when they are written.
-/
syntax (name := reproveRecordCmd) "#reprove_record " ident
  &" stage " str &" outcome " str &" failure " str &" tactics " str &" escape " num
  &" in " command : command

/--
The non-atom children of a syntax node, in source order. The emitters read their arguments
positionally through this rather than through a quotation pattern, because a `command` category
quotation cannot carry a nested `$cmd:command` antiquotation in a **pattern** position: the
`command.pseudo.antiquot` elaborator is unimplemented there. Filtering the atoms out also makes the
reader insensitive to the exact spelling and spacing of the keyword atoms.

Each keyword atom of both commands is declared with `&"..."`, i.e. as a **non-reserved** symbol.
A plain `"..."` atom reserves its spelling as a token for the whole module, which would make
`stage`, `outcome` and `kind` unusable as field names and local identifiers in this very file --
including in the structure instances the emitters build.
-/
def nonAtomArgs (stx : Syntax) : Array Syntax :=
  stx.getArgs.filter fun s => match s with
    | .atom _ _ => false
    | _ => true

/-- A string-literal argument, or a syntax error naming the position. -/
private def strArg (args : Array Syntax) (i : Nat) : CommandElabM String := do
  match args[i]?.bind Syntax.isStrLit? with
  | some s => return s
  | none => throwUnsupportedSyntax

/-- A numeric-literal argument, or a syntax error naming the position. -/
private def natArg (args : Array Syntax) (i : Nat) : CommandElabM Nat := do
  match args[i]?.bind Syntax.isNatLit? with
  | some n => return n
  | none => throwUnsupportedSyntax

/-- An identifier argument, or a syntax error naming the position. -/
private def identArg (args : Array Syntax) (i : Nat) : CommandElabM Name := do
  match args[i]? with
  | some s => if s.isIdent then return s.getId else throwUnsupportedSyntax
  | none => throwUnsupportedSyntax

@[command_elab reproveRecordCmd]
def elabReproveRecord : CommandElab := fun stx => do
  let args := nonAtomArgs stx
  unless args.size == 7 do throwUnsupportedSyntax
  let declName ← identArg args 0
  let stg ← parseStage (← strArg args 1)
  let out ← parseOutcome (← strArg args 2)
  let failureS ← strArg args 3
  let fcls ← parseFailureClass failureS
  if fcls.isSome && !out.admitsFailureClass then
    throwError
      "diagnostics: outcome `{out.key}` admits no failure class, but `{failureS}` was given"
  if fcls.isNone && out.admitsFailureClass then
    throwError "diagnostics: outcome `{out.key}` requires a failure class, but `none` was given"
  let tacs := parseTactics (← strArg args 4)
  let escSize ← natArg args 5
  let some inner := args[6]? | throwUnsupportedSyntax
  let startHb ← IO.getNumHeartbeats
  let startMs ← IO.monoMsNow
  -- `Elab.async false` is required, not a preference. With the default on, a declaration body is
  -- elaborated in a background task, so the constant is not in the environment when this
  -- elaborator resumes -- every measurement below would report `unknown declaration` -- and the
  -- heartbeat delta would exclude the body's own elaboration, which is the bulk of what this
  -- command exists to measure.
  withScope (fun sc => { sc with opts := sc.opts.setBool `Elab.async false }) do
    elabCommand inner
  let finishHb ← IO.getNumHeartbeats
  let finishMs ← IO.monoMsNow
  let zeroTimings ← readZeroTimings
  let heartbeats := if zeroTimings then 0 else (finishHb - startHb) / 1000
  let elabMs := if zeroTimings then 0 else finishMs - startMs
  -- `resolveDeclName` is the unknown-declaration gate and `valueOf` the no-value gate; both run
  -- before anything else reads the constant, so a message names the real problem.
  let (declName, info) ← resolveDeclName declName
  let value ← valueOf declName info
  let (derivSize, derivHeight) ← derivationMeasuresOf declName info
  let (commit, _date, command) ← readStamps
  let head : Head :=
    { statement := ← statementIdOf declName
      stage := stg
      fragment := ← fragmentOf declName
      frameClass := ← frameClassOfType info
      commit := commit
      command := command }
  let record : ReproveRecord :=
    { head := head
      outcome := out
      failureClass := fcls
      tacticCount := tacs.length
      distinctTactics := tacs.eraseDups
      escapeSize := escSize
      heartbeats := heartbeats
      elabMs := elabMs
      termSize := value.sizeWithoutSharing
      derivationSize := derivSize
      derivationHeight := derivHeight
      axioms := ← axiomsOf declName }
  logInfo record.toJson.compress

/-! ## `#compare_record` -/

/--
`#compare_record <script> <reference> kind <s> lengths <n> <n>` prints one COMPARE record for a
proof-mode script measured against a reference proof.

`length_ratio` is emitted only when the reference kind is `hand`; against an extracted reference
the record carries both derivation sizes and both fragments instead, which is the comparison that
is meaningful there.
-/
syntax (name := compareRecordCmd) "#compare_record " ident ident
  &" kind " str &" lengths " num num : command

@[command_elab compareRecordCmd]
def elabCompareRecord : CommandElab := fun stx => do
  let args := nonAtomArgs stx
  unless args.size == 5 do throwUnsupportedSyntax
  let scriptName ← identArg args 0
  let refName ← identArg args 1
  let refKind ← parseReferenceKind (← strArg args 2)
  let scriptLen ← natArg args 3
  let refLen ← natArg args 4
  -- Both are read, so both go through the unknown-declaration and no-value gates.
  let (scriptName, scriptInfo) ← resolveDeclName scriptName
  let (refName, refInfo) ← resolveDeclName refName
  let _ ← valueOf scriptName scriptInfo
  let _ ← valueOf refName refInfo
  let (scriptSize, _) ← derivationMeasuresOf scriptName scriptInfo
  let (refSize, _) ← derivationMeasuresOf refName refInfo
  let (commit, _date, command) ← readStamps
  let statementFragment ← fragmentOf scriptName
  let proofFragment ← fragmentOf refName
  let head : Head :=
    { statement := ← statementIdOf scriptName
      stage := .compare
      fragment := statementFragment
      frameClass := ← frameClassOfType scriptInfo
      commit := commit
      command := command }
  let ratio :=
    if refKind.admitsLengthRatio then
      lengthRatioMilliOf scriptLen refLen
    else
      none
  let record : CompareRecord :=
    { head := head
      scriptLength := scriptLen
      handProofLength := refLen
      lengthRatioMilli := ratio
      referenceKind := refKind
      builtDerivationSize := scriptSize
      referenceDerivationSize := refSize
      statementFragment := statementFragment
      proofFragment := proofFragment }
  logInfo record.toJson.compress

end BimodalLib.Diagnostics
