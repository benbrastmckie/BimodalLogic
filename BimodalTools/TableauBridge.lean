/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.DatasetGenerator
import BimodalTools.DataExport
import BimodalTools.ProofStepExtractor
import BimodalTools.EnrichedCountermodel
import FormalSystem.Metalogic.Decidability.Verified.Bridge.BranchOrder
import FormalSystem.Metalogic.Decidability.Verified.Bridge.BoxSaturation
import FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionLabel
import FormalSystem.Metalogic.Decidability.Verified.Bridge.TemporalGate

/-!
# Tableau Bridge: REPL for Live Formula Queries

This module implements a persistent REPL process with a JSONL stdin/stdout
protocol. It composes existing infrastructure -- `pFormula` parser from
BenchmarkOracleMain, `decideAuto` from DecisionProcedure, `extractStepSequence`
from ProofStepExtractor, and countermodel extraction -- into command handlers.

## Commands

| Command           | Action                                              |
|-------------------|-----------------------------------------------------|
| `tableau_decide`  | Decide validity, return proof trace / countermodel   |
| `tableau_steps`   | Extract ordered proof steps for valid formulas       |
| `countermodel`    | Extract countermodel for invalid formulas            |
| `ping`            | Health check (returns `{"status": "pong"}`)          |
| `shutdown`        | Clean process exit                                   |

## Protocol

JSONL over stdin/stdout (one JSON object per line).

**Request**:
```json
{"command": "tableau_decide", "formula": {"tag": "imp", ...}, "frame_class": "Base"}
```

**Response**:
```json
{"status": "valid", "proof_trace": {...}, "time_ms": 12}
```

## Usage

```
lake exe tableau_bridge
```

Then send JSON requests on stdin, one per line. Responses appear on stdout.

## References

* `BimodalTools/BenchmarkOracleMain.lean` — `pFormula` JSON parser
* `DecisionProcedure.lean`: `decideAuto`
* `BimodalTools/ProofStepExtractor.lean` — `extractStepSequence`, `ProofStep.toJson`
* `CountermodelExtraction.lean`: `SimpleCountermodel.toJson`
* `BimodalTools/EnrichedCountermodel.lean` — `EnrichedCountermodel.toJson`
* `BimodalTools/DatasetGenerator.lean` — `extractProofTrace`, `ProofTrace.toJson`
-/

set_option autoImplicit false

namespace BimodalTools.TableauBridge

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.Verified.Bridge
open FormalSystem.Automation
open BimodalTools.DataExport
open BimodalTools.ProofStepExtractor
open BimodalTools.Enriched

/-!
## JSON Parser Infrastructure

Hand-rolled recursive-descent JSON parser for the request envelope and formula AST.
Replicates the parser from BenchmarkOracleMain to avoid importing that module's root-level
`main` function (which would conflict with the `main` of `BimodalTools/TableauBridgeMain.lean`,
this module's executable root).
-/

/-- Parser state: remaining characters and position. -/
structure PState where
  chars : Array Char
  pos : Nat
  deriving Repr, Inhabited

def mkPState (s : String) : PState :=
  { chars := s.toList.toArray, pos := 0 }

def pEof (st : PState) : Bool := st.pos >= st.chars.size

def pPeek (st : PState) : Option Char :=
  if st.pos < st.chars.size then st.chars[st.pos]? else none

def pAdvance (st : PState) : PState :=
  { st with pos := st.pos + 1 }

def pSkipWS (st : PState) : PState := Id.run do
  let mut st := st
  while st.pos < st.chars.size do
    match st.chars[st.pos]? with
    | some ' ' | some '\n' | some '\r' | some '\t' =>
      st := { st with pos := st.pos + 1 }
    | _ => break
  st

def pExpect (c : Char) (st : PState) : Except String PState :=
  let st := pSkipWS st
  match pPeek st with
  | some c' =>
    if c == c' then .ok (pAdvance st)
    else .error s!"expected '{c}' got '{c'}' at pos {st.pos}"
  | none => .error s!"expected '{c}' got EOF"

/-- Parse a JSON string value (expects opening quote). -/
partial def pString (st : PState) : Except String (String × PState) := do
  let st := pSkipWS st
  let st ← pExpect '"' st
  let mut result : List Char := []
  let mut st := st
  while true do
    if pEof st then throw "unterminated string"
    match st.chars[st.pos]? with
    | some '"' =>
      st := pAdvance st
      return (String.ofList result.reverse, st)
    | some '\\' =>
      st := pAdvance st
      if pEof st then throw "unterminated escape"
      match st.chars[st.pos]? with
      | some c =>
        st := pAdvance st
        match c with
        | '"' => result := '"' :: result
        | '\\' => result := '\\' :: result
        | 'n' => result := '\n' :: result
        | _ => result := c :: result
      | none => throw "escape at EOF"
    | some c =>
      result := c :: result
      st := pAdvance st
    | none => throw "unexpected none in string parse"
  throw "unreachable"

/-- Skip a JSON value without parsing it (for unknown fields). -/
partial def pSkipValue (st : PState) : Except String PState := do
  let st := pSkipWS st
  match pPeek st with
  | some '"' =>
    let (_, st) ← pString st
    return st
  | some '{' =>
    let mut st := pAdvance st
    let st' := pSkipWS st
    match pPeek st' with
    | some '}' => return (pAdvance st')
    | _ =>
      while true do
        let (_, st') ← pString st
        let st' := pSkipWS st'
        let st' ← pExpect ':' st'
        let st' ← pSkipValue st'
        let st' := pSkipWS st'
        match pPeek st' with
        | some ',' => st := pAdvance st'
        | some '}' => return (pAdvance st')
        | _ => throw "expected , or } in object"
      throw "unreachable"
  | some '[' =>
    let mut st := pAdvance st
    let st' := pSkipWS st
    match pPeek st' with
    | some ']' => return (pAdvance st')
    | _ =>
      while true do
        let st' ← pSkipValue st
        let st' := pSkipWS st'
        match pPeek st' with
        | some ',' => st := pAdvance st'
        | some ']' => return (pAdvance st')
        | _ => throw "expected , or ] in array"
      throw "unreachable"
  | some c =>
    if c == 'n' || c == 't' || c == 'f' || c.isDigit || c == '-' then
      let mut st := st
      while !pEof st do
        match pPeek st with
        | some c' =>
          if c' == ',' || c' == '}' || c' == ']' || c' == ' ' || c' == '\n' then
            break
          st := pAdvance st
        | none => break
      return st
    else
      throw s!"unexpected char '{c}'"
  | none => throw "unexpected EOF in value"

/-- Parse a formula AST from a JSON object. -/
partial def pFormula (st : PState) : Except String (Formula × PState) := do
  let st := pSkipWS st
  let st ← pExpect '{' st
  let mut tag : String := ""
  let mut name : String := ""
  let mut subFormulas : List (String × Formula) := []
  let mut st := st
  while true do
    let st' := pSkipWS st
    match pPeek st' with
    | some '}' =>
      st := pAdvance st'
      break
    | _ => pure ()
    let (key, st') ← pString st
    let st' := pSkipWS st'
    let st' ← pExpect ':' st'
    let st' := pSkipWS st'
    if key == "tag" then
      let (val, st') ← pString st'
      tag := val
      st := st'
    else if key == "name" then
      let (val, st') ← pString st'
      name := val
      st := st'
    else if key == "left" || key == "right" || key == "child" ||
            key == "event" || key == "guard" then
      let (formula, st') ← pFormula st'
      subFormulas := (key, formula) :: subFormulas
      st := st'
    else
      let st' ← pSkipValue st'
      st := st'
    let st' := pSkipWS st
    match pPeek st' with
    | some ',' => st := pAdvance st'
    | some '}' =>
      st := pAdvance st'
      break
    | _ => throw s!"expected , or }} at pos {st'.pos}"
  let getField (fname : String) : Except String Formula :=
    match subFormulas.find? (fun (k, _) => k == fname) with
    | some (_, f) => .ok f
    | none => .error s!"missing field '{fname}' for tag '{tag}'"
  match tag with
  | "atom" => return (Formula.atomS name, st)
  | "bot" => return (Formula.bot, st)
  | "imp" =>
    let left ← getField "left"
    let right ← getField "right"
    return (Formula.imp left right, st)
  | "box" =>
    let child ← getField "child"
    return (Formula.box child, st)
  | "untl" =>
    let event ← getField "event"
    let guard ← getField "guard"
    return (Formula.untl guard event, st)
  | "snce" =>
    let event ← getField "event"
    let guard ← getField "guard"
    return (Formula.snce guard event, st)
  | _ => throw s!"unknown tag '{tag}'"

/-!
## Bridge Command Type
-/

/--
Commands supported by the bridge REPL.
-/
inductive BridgeCommand where
  | tableau_decide
  | tableau_steps
  | countermodel
  | ping
  | shutdown
  deriving Repr, DecidableEq

/--
A parsed request from the JSONL protocol.
-/
structure BridgeRequest where
  command : BridgeCommand
  formula : Option Formula
  frameClass : FrameClass
  deriving Repr

/-!
## Parsers
-/

/--
Parse a frame class string to a `FrameClass` value.

The accepted vocabulary is exactly `"Base"`, `"Dense"`, `"ZTime"`, `"Discrete"` and `"RTime"`.
`"Discrete"` is an accepted alias for `"ZTime"`; `"RTime"` is the Dedekind class, which the
tableau engine genuinely supports (`allRulesForFC` has a live `rTimeRules` arm). `ZTime` and
`RTime` are *incomparable* in `FrameClass`'s partial order (`FormalSystem/ProofSystem/Axioms.lean`,
the `LE FrameClass` instance), so neither is an alias for the other.

Every other string is **rejected** with an `.error`, which `parseRequest` propagates and
`replLoop` renders as `{"status": "error", "message": ...}`. This replaces an earlier
silent `_ => .Base` fallback, under which a request at `"RTime"` — or at a typo — was decided
at `.Base` and answered as though the requested class had been honoured.
-/
def parseFrameClass (s : String) : Except String FrameClass :=
  match s with
  | "Base" => .ok .Base
  | "Dense" => .ok .Dense
  | "ZTime" => .ok .ZTime
  | "Discrete" => .ok .ZTime
  | "RTime" => .ok .RTime
  | _ =>
    .error s!"unknown frame_class: '{s}' (expected one of: Base, Dense, ZTime, Discrete, RTime)"

/--
Parse a command string to a `BridgeCommand`.
-/
def parseCommand (s : String) : Except String BridgeCommand :=
  match s with
  | "tableau_decide" => .ok .tableau_decide
  | "tableau_steps" => .ok .tableau_steps
  | "countermodel" => .ok .countermodel
  | "ping" => .ok .ping
  | "shutdown" => .ok .shutdown
  | _ => .error s!"unknown command: {s}"

/--
Parse a JSON number (natural number) from the parser state.
-/
partial def pNat (st : PState) : Except String (Nat × PState) := do
  let st := pSkipWS st
  let mut digits : List Char := []
  let mut st := st
  while st.pos < st.chars.size do
    match st.chars[st.pos]? with
    | some c =>
      if c.isDigit then
        digits := c :: digits
        st := pAdvance st
      else
        break
    | none => break
  if digits.isEmpty then
    throw s!"expected number at pos {st.pos}"
  let numStr := String.ofList digits.reverse
  match numStr.toNat? with
  | some n => return (n, st)
  | none => throw s!"invalid number: {numStr}"

/--
Parse a request envelope from a JSON line.

Expected format:
```json
{"command": "tableau_decide", "formula": {...}, "frame_class": "Base", "timeout_ms": 500}
```

Only "command" is required. "formula" is required for tableau_decide, tableau_steps,
and countermodel. "frame_class" defaults to "Base". "timeout_ms" is accepted but
currently unused (fuel-based bounding via soundFuel is used instead).
-/
partial def parseRequest (line : String) : Except String BridgeRequest := do
  let st := mkPState line
  let st := pSkipWS st
  let st ← pExpect '{' st
  let mut command : Option BridgeCommand := none
  let mut formula : Option Formula := none
  let mut frameClass : FrameClass := .Base
  let mut st := st
  while true do
    let st' := pSkipWS st
    match pPeek st' with
    | some '}' =>
      st := pAdvance st'
      break
    | _ => pure ()
    let (key, st') ← pString st
    let st' := pSkipWS st'
    let st' ← pExpect ':' st'
    let st' := pSkipWS st'
    if key == "command" then
      let (val, st') ← pString st'
      let cmd ← parseCommand val
      command := some cmd
      st := st'
    else if key == "formula" then
      let (f, st') ← pFormula st'
      formula := some f
      st := st'
    else if key == "frame_class" then
      let (val, st') ← pString st'
      frameClass ← parseFrameClass val
      st := st'
    else if key == "timeout_ms" then
      let (_val, st') ← pNat st'
      st := st'
    else
      let st' ← pSkipValue st'
      st := st'
    let st' := pSkipWS st
    match pPeek st' with
    | some ',' => st := pAdvance st'
    | some '}' =>
      st := pAdvance st'
      break
    | _ => throw s!"expected , or }} at pos {st'.pos}"
  match command with
  | none => throw "missing 'command' field"
  | some cmd =>
    return { command := cmd, formula := formula, frameClass := frameClass }

/-!
## Response Builders
-/

/--
Build an error response JSON string.
-/
def mkErrorResponse (msg : String) (timeMs : Nat := 0) : String :=
  "{\"status\": \"error\", \"message\": \"" ++ escapeJsonString msg
  ++ "\", \"time_ms\": " ++ toString timeMs ++ "}"

/--
Build a pong response JSON string.
-/
def mkPongResponse : String :=
  "{\"status\": \"pong\"}"

/-!
## Branch Gates

An `"invalid"` verdict is produced from a saturated open branch. That branch refutes the formula
*as a Lean theorem* only when the branch also satisfies the hypothesis bundle of
`not_valid_of_hasOpen_int` / `not_validZTime_of_hasOpen_int`
(`FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean`). The bridge evaluates that
bundle and reports it, so a consumer can tell a theorem-backed refutation from a heuristic one.
-/

/--
The hypothesis bundle of `not_valid_of_hasOpen_int` / `not_validZTime_of_hasOpen_int`, evaluated
as booleans on the open saturated branch a `.invalid` verdict came from.

The task's protocol change names four gates (`timeOrderTotal`, `boxAnchoredCheck`,
`regionLabelCheck`, `temporalWitnessCheck`); each keeps its own field here. The remaining four
fields are the rest of what the two theorems actually consume, and they are not redundant:
`branchOrderValid` is strictly **stronger** than `timeOrderTotal` (a cycle makes every time
reachable from every other, so `timeOrderTotal` reports `true` on an inconsistent order while
`branchOrderValid` rejects it on irreflexivity — pinned in
`Tests/BimodalTest/Metalogic/Decidability/Verified/BridgeProbes.lean`). Reporting only the four
named gates would therefore let a cyclic time order be read as theorem-backed.

`gated` is accordingly the conjunction of all eight fields, and it is exactly the claim
"`not_valid_of_hasOpen_int` (and, at `.ZTime`, `not_validZTime_of_hasOpen_int`) applies to this
branch". `gated = false` means the `"invalid"` verdict is the decision procedure's own and is
*not* backed by either theorem; it is not a claim that the formula is valid.
-/
structure BranchGates where
  /-- `timeOrderTotal b ord`: every pair of known times is comparable under `ord`. -/
  timeOrderTotal : Bool
  /-- `boxAnchoredCheck b`: every `□`-obligation is anchored at a known world. -/
  boxAnchored : Bool
  /-- `regionLabelCheck b ord`: the branch's labels agree with the region structure. -/
  regionLabel : Bool
  /-- `temporalWitnessCheck b ord`: every eventuality has its witness on the branch. -/
  temporalWitness : Bool
  /-- `branchOrderValid b ord` (`hV`): total **and** irreflexive **and** transitive. Strictly
      stronger than `timeOrderTotal`; see this structure's docstring. -/
  branchOrderValid : Bool
  /-- `findUnexpanded b (timeOrd := ord) = none` (`hSat`).

      Computed at `findUnexpanded`'s **default** `fc := .Base`, deliberately *not* at the
      request's frame class. That is how `not_valid_of_hasOpen_int` states `hSat`: its `fc`
      argument is threaded to `hOpen`/`findClosure`, while `hSat` is written without one and so
      takes the default. `ExpandedTableau.hasOpen` carries its own saturation certificate at the
      tableau's actual `fc`; that is a different proposition, and computing it here would make
      `gated` a claim the theorem does not license. -/
  saturated : Bool
  /-- `findClosure b fc = none` (`hOpen`), at the **request's** frame class — this is the one the
      theorem takes as an explicit argument. -/
  noClosure : Bool
  /-- The root-denial pair `hw₀`/`hroot`: `F(φ)` sits on the branch at `Label.initial`, and that
      label's world is among the branch's known worlds. Both are needed, so they are reported as
      one field rather than split. -/
  rootDenied : Bool
  deriving Repr, DecidableEq

/--
`true` exactly when every hypothesis of `not_valid_of_hasOpen_int` /
`not_validZTime_of_hasOpen_int` holds on the branch — i.e. when the `"invalid"` verdict is
theorem-backed rather than heuristic.
-/
def BranchGates.gated (g : BranchGates) : Bool :=
  g.timeOrderTotal && g.boxAnchored && g.regionLabel && g.temporalWitness
    && g.branchOrderValid && g.saturated && g.noClosure && g.rootDenied

/-- Serialize the gates as a JSON object: one key per field, plus `"gated"`. -/
def BranchGates.toJson (g : BranchGates) : String :=
  "{\"time_order_total\": " ++ toString g.timeOrderTotal
  ++ ", \"box_anchored_check\": " ++ toString g.boxAnchored
  ++ ", \"region_label_check\": " ++ toString g.regionLabel
  ++ ", \"temporal_witness_check\": " ++ toString g.temporalWitness
  ++ ", \"branch_order_valid\": " ++ toString g.branchOrderValid
  ++ ", \"saturated\": " ++ toString g.saturated
  ++ ", \"no_closure\": " ++ toString g.noClosure
  ++ ", \"root_denied\": " ++ toString g.rootDenied
  ++ ", \"gated\": " ++ toString g.gated
  ++ "}"

/--
Evaluate the eight hypotheses on a branch already in hand.

`fc` is the frame class the tableau was built at; it reaches `findClosure` only. See
`BranchGates.saturated`'s docstring for why `findUnexpanded` is *not* given it.
-/
def gatesOfBranch (φ : Formula) (b : Branch) (ord : TimeOrdering) (fc : FrameClass) :
    BranchGates :=
  { timeOrderTotal := timeOrderTotal b ord
  , boxAnchored := boxAnchoredCheck b
  , regionLabel := regionLabelCheck b ord
  , temporalWitness := temporalWitnessCheck b ord
  , branchOrderValid := branchOrderValid b ord
  , saturated := (findUnexpanded b (timeOrd := ord)).isNone
  , noClosure := (findClosure b fc).isNone
  , rootDenied := b.hasNegAt φ Label.initial && b.knownWorlds.contains Label.initial.world
  }

/--
Rebuild the tableau for `φ` at `fc` and evaluate the gates on its open branch.

`buildTableau φ (soundFuel φ) fc` is the exact call `decideAuto` makes (via `decide`), and
`buildTableau` is pure and total, so the branch recovered here is the same one the `.invalid`
verdict came from. `DecisionResult` discards the branch and the `TimeOrdering`, which is why a
re-run rather than a projection is used — the same mechanism `extractCountermodelData` already
relies on.

Returns `none` when the rebuild does not land on an open branch. That arm is unreachable whenever
`decideAuto` returned `.invalid`; it exists so the case is handled rather than guessed at.
-/
def evalBranchGates (φ : Formula) (fc : FrameClass) : Option BranchGates :=
  match buildTableau φ (soundFuel φ) fc with
  | some (.hasOpen b ord _ _) => some (gatesOfBranch φ b ord fc)
  | _ => none

/-- Render an `Option BranchGates` as the value of the response's `"gates"` key. -/
def gatesJson : Option BranchGates → String
  | none => "null"
  | some g => g.toJson

/-!
## Command Handlers
-/

/--
The pure body of a `tableau_decide` response: the opening brace and every field except
`"time_ms"`, which `handleDecide` splices on. Everything the command computes is pure, so the
whole response shape is decidable from a `#guard` without an `IO` harness — which is what
`Tests/BimodalToolsTest/TableauBridgeTest.lean` uses.

Runs `decideAuto` on the formula and returns:
- For valid: proof trace, rule profile, and metrics
- For invalid: simple countermodel, plus the `"gates"` object (see `BranchGates`)
- For fuel exhaustion: timeout status; for a closed tableau with no proof term:
  `valid_no_proof_term` status (R7 — a closed tableau is never reported undecided)
-/
def decideResponseBody (φ : Formula) (fc : FrameClass) : String :=
  match decideAuto φ fc with
  | .valid proof =>
    let trace := extractProofTrace proof
    let rp := walkDerivationTree proof
    "{\"status\": \"valid\""
      ++ ", \"proof_trace\": " ++ trace.toJson
      ++ ", \"rule_profile\": " ++ rp.toJson
      ++ ", \"formula_string\": \"" ++ escapeJsonString φ.prettyPrint ++ "\""
  | .invalid cm =>
    -- `"gates"` is additive: `"status"` stays `"invalid"` and every pre-existing field is
    -- unchanged. `"gated": true` is what licenses citing `not_valid_of_hasOpen_int` /
    -- `not_validZTime_of_hasOpen_int` for this verdict; `false` marks it heuristic.
    "{\"status\": \"invalid\""
      ++ ", \"countermodel\": " ++ cm.toJson
      ++ ", \"gates\": " ++ gatesJson (evalBranchGates φ fc)
      ++ ", \"formula_string\": \"" ++ escapeJsonString φ.prettyPrint ++ "\""
  | .fuelExhausted =>
    "{\"status\": \"timeout\""
      ++ ", \"formula_string\": \"" ++ escapeJsonString φ.prettyPrint ++ "\""
  | .extractionFailed =>
    -- Closed tableau, no proof term: valid, not undecided (R7).
    "{\"status\": \"valid_no_proof_term\""
      ++ ", \"formula_string\": \"" ++ escapeJsonString φ.prettyPrint ++ "\""

/--
Handle a `tableau_decide` command: time `decideResponseBody` and close the object with
`"time_ms"`.
-/
def handleDecide (φ : Formula) (fc : FrameClass) : IO String := do
  let startTime ← IO.monoMsNow
  let body := decideResponseBody φ fc
  let endTime ← IO.monoMsNow
  return body ++ ", \"time_ms\": " ++ toString (endTime - startTime) ++ "}"

/--
Handle a `tableau_steps` command.

Runs `decideAuto` on the formula. If valid, extracts ordered proof steps
via `extractStepSequence` and returns a JSON array.
-/
def handleSteps (φ : Formula) (fc : FrameClass) : IO String := do
  let startTime ← IO.monoMsNow
  let result := decideAuto φ fc
  let endTime ← IO.monoMsNow
  let elapsed := endTime - startTime
  match result with
  | .valid proof =>
    let fcStr := frameClassToString fc
    let (steps, _) := extractStepSequence "query" fcStr 0 proof
    let stepsJson := listToJsonArray (steps.map ProofStep.toJson)
    return "{\"status\": \"valid\""
      ++ ", \"steps\": " ++ stepsJson
      ++ ", \"step_count\": " ++ toString steps.length
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"
  | .invalid _ =>
    return "{\"status\": \"invalid\""
      ++ ", \"message\": \"Formula is invalid; no proof steps exist.\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"
  | .fuelExhausted =>
    return "{\"status\": \"timeout\""
      ++ ", \"message\": \"Decision procedure timed out.\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"
  | .extractionFailed =>
    -- Closed tableau, no proof term: valid, not undecided (R7).
    return "{\"status\": \"valid_no_proof_term\""
      ++ ", \"message\": \"Tableau closed; proof term could not be reconstructed.\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"

/--
Handle a `countermodel` command.

Runs `decideAuto` on the formula. If invalid, returns the simple countermodel, the enriched and
semantic countermodel data, and the `"gates"` object (see `BranchGates`).
-/
def handleCountermodel (φ : Formula) (fc : FrameClass) : IO String := do
  let startTime ← IO.monoMsNow
  -- `decideAuto` decides at `soundFuel φ`; bind the same fuel and reuse it for the
  -- countermodel/gates re-run below, so that re-run matches the deciding tableau exactly
  -- (same fuel, same frame class). The bridge has no wall-clock timeout, so no abort ref is
  -- threaded here (out of scope; see research Section 8).
  let fuel := soundFuel φ
  let result := decideAuto φ fc
  let endTime ← IO.monoMsNow
  let elapsed := endTime - startTime
  match result with
  | .invalid cm =>
    -- ONE `buildTableau` re-run feeds both the gates and the enriched/semantic countermodels,
    -- so the invalid path performs one extra build rather than two.
    --
    -- `extractCountermodelData` is deliberately not called here. Its `buildTableau φ fuel` call
    -- takes the `fc` **default** of `.Base`, so a `countermodel` request at `"ZTime"` used to
    -- extract its enriched countermodel from a `.Base` tableau while the verdict came from a
    -- `.ZTime` one. Inlining the body at the request's `fc` fixes that without changing a
    -- signature that has other call sites.
    let (gates, ecm, scmSummary) :
        Option BranchGates × Option Enriched.EnrichedCountermodel ×
          Option SemanticCountermodelSummary :=
      match buildTableau φ fuel fc with
      | some (.hasOpen b ord _ _) =>
        ( some (gatesOfBranch φ b ord fc)
        , some (Enriched.extractEnrichedCountermodel φ b)
        , some (SemanticCountermodelSummary.fromSemanticCountermodel
                  (extractSemanticCountermodel φ b ord)) )
      | _ => (none, none, none)
    let ecmStr := match ecm with
      | none => "null"
      | some e => e.toJson
    let scmStr := match scmSummary with
      | none => "null"
      | some s => s.toJson
    return "{\"status\": \"invalid\""
      ++ ", \"countermodel\": " ++ cm.toJson
      ++ ", \"enriched_countermodel\": " ++ ecmStr
      ++ ", \"semantic_countermodel\": " ++ scmStr
      ++ ", \"gates\": " ++ gatesJson gates
      ++ ", \"consistent\": " ++ toString cm.isConsistent
      ++ ", \"formula_string\": \"" ++ escapeJsonString φ.prettyPrint ++ "\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"
  | .valid _ =>
    return "{\"status\": \"valid\""
      ++ ", \"message\": \"Formula is valid; no countermodel exists.\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"
  | .fuelExhausted =>
    return "{\"status\": \"timeout\""
      ++ ", \"message\": \"Decision procedure timed out.\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"
  | .extractionFailed =>
    -- Closed tableau, no proof term: valid, not undecided (R7).
    return "{\"status\": \"valid_no_proof_term\""
      ++ ", \"message\": \"Tableau closed; proof term could not be reconstructed.\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"

/--
Dispatch a parsed request to the appropriate handler.
-/
def dispatch (req : BridgeRequest) : IO (Option String) := do
  match req.command with
  | .ping => return some mkPongResponse
  | .shutdown => return none
  | .tableau_decide =>
    match req.formula with
    | none => return some (mkErrorResponse "tableau_decide requires a 'formula' field")
    | some φ =>
      let resp ← handleDecide φ req.frameClass
      return some resp
  | .tableau_steps =>
    match req.formula with
    | none => return some (mkErrorResponse "tableau_steps requires a 'formula' field")
    | some φ =>
      let resp ← handleSteps φ req.frameClass
      return some resp
  | .countermodel =>
    match req.formula with
    | none => return some (mkErrorResponse "countermodel requires a 'formula' field")
    | some φ =>
      let resp ← handleCountermodel φ req.frameClass
      return some resp

/-!
## REPL Loop
-/

/--
Main REPL loop. Reads JSON requests from stdin, dispatches them,
and writes JSON responses to stdout. Terminates on EOF or shutdown command.
-/
partial def replLoop : IO Unit := do
  let stdin ← IO.getStdin
  let stdout ← IO.getStdout
  -- Emit ready signal on stdout
  stdout.putStrLn "{\"status\": \"ready\"}"
  stdout.flush
  -- Emit startup banner to stderr
  let stderr ← IO.getStderr
  stderr.putStrLn "tableau_bridge: ready"
  stderr.flush
  -- Enter main loop
  let rec loop : IO Unit := do
    let line ← stdin.getLine
    -- EOF: getLine returns empty string
    if line.isEmpty then
      return
    let trimmed := line.trimAscii.toString
    -- Skip blank lines
    if trimmed.isEmpty then
      loop
    else
      match parseRequest trimmed with
      | .error msg =>
        stdout.putStrLn (mkErrorResponse msg)
        stdout.flush
        loop
      | .ok req =>
        match (← dispatch req) with
        | none =>
          -- shutdown command: exit cleanly
          return
        | some resp =>
          stdout.putStrLn resp
          stdout.flush
          loop
  loop

end BimodalTools.TableauBridge
