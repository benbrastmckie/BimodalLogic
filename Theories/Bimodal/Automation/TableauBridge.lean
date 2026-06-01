import Bimodal.Automation.DatasetGenerator
import Bimodal.Automation.DataExport
import Bimodal.Automation.ProofStepExtractor
import Bimodal.Automation.EnrichedCountermodel

/-!
# Tableau Bridge: REPL for Live Formula Queries

This module implements a persistent REPL process with a JSONL stdin/stdout
protocol. It composes existing infrastructure -- `pFormula` parser from
BenchmarkOracle, `decideAuto` from DecisionProcedure, `extractStepSequence`
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

- `BenchmarkOracle.lean`: `pFormula` JSON parser
- `DecisionProcedure.lean`: `decideAuto`
- `ProofStepExtractor.lean`: `extractStepSequence`, `ProofStep.toJson`
- `CountermodelExtraction.lean`: `SimpleCountermodel.toJson`
- `EnrichedCountermodel.lean`: `EnrichedCountermodel.toJson`
- `DatasetGenerator.lean`: `extractProofTrace`, `ProofTrace.toJson`
-/

set_option autoImplicit false

namespace Bimodal.Automation.TableauBridge

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Decidability
open Bimodal.Automation
open Bimodal.Automation.DataExport
open Bimodal.Automation.ProofStepExtractor
open Bimodal.Automation.Enriched

/-!
## JSON Parser Infrastructure

Hand-rolled recursive-descent JSON parser for the request envelope and formula AST.
Replicates the parser from BenchmarkOracle to avoid importing that module's root-level
`main` function (which would conflict with our own `main` entry point).
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
  | "atom" => return (Formula.atom_s name, st)
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
    return (Formula.untl event guard, st)
  | "snce" =>
    let event ← getField "event"
    let guard ← getField "guard"
    return (Formula.snce event guard, st)
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
Unrecognized strings default to `.Base`.
-/
def parseFrameClass (s : String) : FrameClass :=
  match s with
  | "Dense" => .Dense
  | "Discrete" => .Discrete
  | _ => .Base

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
      frameClass := parseFrameClass val
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
## Command Handlers
-/

/--
Handle a `tableau_decide` command.

Runs `decideAuto` on the formula and returns:
- For valid: proof trace, rule profile, and metrics
- For invalid: simple countermodel
- For timeout: timeout status
-/
def handleDecide (φ : Formula) (fc : FrameClass) : IO String := do
  let startTime ← IO.monoMsNow
  let result := decideAuto φ fc
  let endTime ← IO.monoMsNow
  let elapsed := endTime - startTime
  match result with
  | .valid proof =>
    let trace := extractProofTrace proof
    let rp := walkDerivationTree proof
    return "{\"status\": \"valid\""
      ++ ", \"proof_trace\": " ++ trace.toJson
      ++ ", \"rule_profile\": " ++ rp.toJson
      ++ ", \"formula_string\": \"" ++ escapeJsonString φ.prettyPrint ++ "\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"
  | .invalid cm =>
    return "{\"status\": \"invalid\""
      ++ ", \"countermodel\": " ++ cm.toJson
      ++ ", \"formula_string\": \"" ++ escapeJsonString φ.prettyPrint ++ "\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"
  | .timeout =>
    return "{\"status\": \"timeout\""
      ++ ", \"formula_string\": \"" ++ escapeJsonString φ.prettyPrint ++ "\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"

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
  | .timeout =>
    return "{\"status\": \"timeout\""
      ++ ", \"message\": \"Decision procedure timed out.\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"

/--
Handle a `countermodel` command.

Runs `decideAuto` on the formula. If invalid, returns the simple countermodel
plus enriched countermodel data.
-/
def handleCountermodel (φ : Formula) (fc : FrameClass) : IO String := do
  let startTime ← IO.monoMsNow
  let result := decideAuto φ fc
  let endTime ← IO.monoMsNow
  let elapsed := endTime - startTime
  match result with
  | .invalid cm =>
    let (ecm, scmSummary) := extractCountermodelData φ
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
      ++ ", \"consistent\": " ++ toString cm.isConsistent
      ++ ", \"formula_string\": \"" ++ escapeJsonString φ.prettyPrint ++ "\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"
  | .valid _ =>
    return "{\"status\": \"valid\""
      ++ ", \"message\": \"Formula is valid; no countermodel exists.\""
      ++ ", \"time_ms\": " ++ toString elapsed
      ++ "}"
  | .timeout =>
    return "{\"status\": \"timeout\""
      ++ ", \"message\": \"Decision procedure timed out.\""
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

end Bimodal.Automation.TableauBridge

/-!
## Main Entry Point
-/

/--
Entry point for the `tableau_bridge` executable.
Ignores command-line arguments and enters the REPL loop.
-/
def main (_args : List String) : IO Unit :=
  Bimodal.Automation.TableauBridge.replLoop
