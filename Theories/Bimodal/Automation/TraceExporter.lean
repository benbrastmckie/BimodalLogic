/-
Copyright (c) 2026 BimodalLogic contributors.
Released under the project's standard license.
-/

import Batteries
import Bimodal.Syntax
import Bimodal.ProofSystem
import Bimodal.Metalogic.Decidability.SignedFormula
import Bimodal.Metalogic.Decidability.Closure
import Bimodal.Metalogic.Decidability.TraceCertificate
import Bimodal.Metalogic.Decidability.DecisionProcedure
import Bimodal.Metalogic.Decidability.TraceExport
import Bimodal.Automation.DataExport

/-!
# Trace Exporter CLI: Stream JSONL Proof Certificates (Task 277)

Reads formulas (as JSONL requests on stdin), runs the trace-instrumented
decision procedure, and emits JSONL `ProofCertificate`s to stdout. Each
request is one line of JSON; each response is one line of JSON.

## Request Format

```json
{"command": "trace_decide", "formula": {"tag": "imp", ...}, "fuel": 500, "frame_class": "Base"}
```

## Response Format

```json
{"status": "success", "certificate": { ... ProofCertificate fields ... }}
```

## CLI Usage

```
echo '{"command":"trace_decide","formula":{"tag":"atom","name":"p"}}' | lake exe trace_exporter
```

## References

- `Bimodal.Metalogic.Decidability.DecisionProcedure.decideWithTrace` — main entry point.
- `Bimodal.Metalogic.Decidability.TraceExport.proofCertificateToJsonString` — JSON serializer.
- `Bimodal.Automation.TableauBridge` — REPL pattern.
-/

set_option autoImplicit false

namespace Bimodal.Automation.TraceExporter

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Decidability
open Bimodal.Metalogic.Decidability.TraceExport

/-!
## Request/Response Types
-/

/-- Frame class as a string (for JSON request parsing). -/
inductive ReqFrameClass : Type where
  | base : ReqFrameClass
  | dense : ReqFrameClass
  | discrete : ReqFrameClass
  deriving Repr, BEq, DecidableEq, Inhabited

def reqFrameClassToFrameClass : ReqFrameClass → FrameClass
  | .base    => .Base
  | .dense   => .Dense
  | .discrete => .Discrete

def reqFrameClassFromString? (s : String) : Option ReqFrameClass :=
  match s with
  | "Base"     => some .base
  | "Dense"    => some .dense
  | "Discrete" => some .discrete
  | _          => none

/-- Parsed request from JSONL. -/
structure Request where
  command   : String
  formula   : Option Formula := none
  fuel      : Nat := 500
  frameClass : ReqFrameClass := .base
  deriving Repr, Inhabited

/-- Result of dispatch. -/
inductive DispatchResult : Type where
  | ok (response : String)
  | parseError (msg : String)
  | shutdown

namespace DispatchResult

end DispatchResult

/-- Construct a JSON error response. -/
def mkErrorJson (msg : String) : String :=
  let escaped := escapeJsonString msg
  "{\"status\": \"error\", \"message\": \"" ++ escaped ++ "\"}"

/-!
## Request Parsing (JSONL)
-/

/-- Recursive-descent JSON parser state. -/
structure PState where
  chars : Array Char
  pos   : Nat
  deriving Inhabited

namespace PState

def ofString (s : String) : PState :=
  ⟨s.toList.toArray, 0⟩

def atEnd? (p : PState) : Bool := p.pos >= p.chars.size

def peek? (p : PState) : Option Char :=
  if p.atEnd? then none else some p.chars[p.pos]!

def consume? (p : PState) : Option (Char × PState) :=
  match p.peek? with
  | none => none
  | some c => some (c, { p with pos := p.pos + 1 })

def expect (p : PState) (c : Char) : Option PState :=
  match p.consume? with
  | some (c', p') =>
    if c' == c then some p' else none
  | none => none

def skipWhitespace (p : PState) : PState :=
  let rec loop (p : PState) : PState :=
    match p.peek? with
    | some c =>
      if c == ' ' ∨ c == Char.ofNat 9 ∨ c == Char.ofNat 10 ∨ c == Char.ofNat 13 then
        loop { p with pos := p.pos + 1 }
      else p
    | none => p
  loop p

end PState

/-- Parse a JSON string (e.g. `"atom"`). -/
partial def parseJsonString (p : PState) : Option (String × PState) :=
  match p.expect '"' with
  | none => none
  | some p =>
    let rec loop (acc : String) (p : PState) : Option (String × PState) :=
      match p.consume? with
      | none => none
      | some ('"', p) => some (acc, p)
      | some ('\\', p) =>
        match p.consume? with
        | some ('"', p) => loop (acc ++ "\"") p
        | some ('\\', p) => loop (acc ++ "\\") p
        | some ('/', p) => loop (acc ++ "/") p
        | some ('n', p) => loop (acc ++ "\n") p
        | some ('t', p) => loop (acc ++ "\t") p
        | some ('r', p) => loop (acc ++ "\r") p
        | some (c, p) => loop (acc ++ c.toString) p
        | none => none
      | some (c, p) => loop (acc.push c) p
    loop "" p

/-- Parse a JSON number (Nat only). -/
partial def parseJsonNat (p : PState) : Option (Nat × PState) :=
  let p := PState.skipWhitespace p
  let rec loop (acc : Nat) (p : PState) : Option (Nat × PState) :=
    match PState.peek? p with
    | some c =>
      if '0' ≤ c ∧ c ≤ '9' then
        let digit := c.toNat - '0'.toNat
        loop (acc * 10 + digit) { p with pos := p.pos + 1 }
      else
        some (acc, p)
    | none => some (acc, p)
  loop 0 p

/-- Parse a JSON value (only the cases we need: string, number, object, null). -/
partial def parseJsonValue (p : PState) : Option (String × PState) := do
  let p := PState.skipWhitespace p
  match PState.peek? p with
  | some '"' =>
    parseJsonString p
  | some c =>
    if '0' ≤ c ∧ c ≤ '9' then
      let (n, p) ← parseJsonNat p
      some (toString n, p)
    else if c == '{' then
      -- Object: parse as { "key": "value", ... } and render as JSON
      -- For simplicity, we re-parse the entire object from the original
      -- string by counting braces.
      let p1 ← PState.expect p '{'
      let rec walk (depth : Nat) (p : PState) (acc : String) : Option (String × PState) :=
        match PState.consume? p with
        | none => none
        | some ('{', p) => walk (depth + 1) p (acc ++ "{")
        | some ('}', p) =>
          if depth == 0 then
            some (acc ++ "}", p)
          else
            walk (depth - 1) p (acc ++ "}")
        | some ('"', p) =>
          let (s, p) ← parseJsonString { p with pos := p.pos - 1 }
          walk depth p (acc ++ "\"" ++ s ++ "\"")
        | some (c, p) => walk depth p (acc.push c)
      walk 0 p1 ""
    else if c == 'n' then
      -- null
      match p with
      | ⟨arr, pos⟩ =>
        if pos + 4 ≤ arr.size ∧
           arr[pos]! == 'n' ∧ arr[pos+1]! == 'u' ∧
           arr[pos+2]! == 'l' ∧ arr[pos+3]! == 'l' then
          some ("null", { p with pos := pos + 4 })
        else none
    else none
  | none => none

/-- Parse the request object. -/
def parseRequest (line : String) : Either String Request := do
  let p := PState.ofString line
  let p ← PState.expect p '{'
  let p := PState.skipWhitespace p
  -- We need to find the "command" and "formula" fields.
  -- For simplicity, do a single key-by-key pass.
  let rec parseFields (p : PState) (acc : Request) (count : Nat) : Option (Request × PState) :=
    let p := PState.skipWhitespace p
    match PState.peek? p with
    | none => none
    | some '}' =>
      -- end of object
      match PState.consume? p with
      | some (_, p) => some (acc, p)
      | none => none
    | some ',' =>
      match PState.consume? p with
      | some (_, p) => parseFields p acc (count + 1)
      | none => none
    | some _ =>
      -- Parse key
      let (key, p) ← parseJsonString p
      let p := PState.skipWhitespace p
      let p ← PState.expect p ':'
      let p := PState.skipWhitespace p
      -- Parse value (using parseJsonValue for full nested support)
      let (value, p) ← parseJsonValue p
      let newAcc :=
        if key == "command" then { acc with command := value }
        else if key == "fuel" then
          match value.toNat? with
          | some n => { acc with fuel := n }
          | none => acc
        else if key == "frame_class" then
          match reqFrameClassFromString? value with
          | some fc => { acc with frameClass := fc }
          | none => acc
        else if key == "formula" then
          -- The formula is given as a JSON-encoded Formula AST
          match parseFormula value with
          | some φ => { acc with formula := some φ }
          | none => acc
        else acc
      parseFields p newAcc (count + 1)
  match parseFields p ⟨⟩ 0 with
  | some (req, _) => pure req
  | none => .error "failed to parse request object"

/-- Parse a formula from its JSON representation. -/
partial def parseFormula (s : String) : Option Formula :=
  -- For simplicity, we only support a few key tags: "atom", "imp", "and", "or", "neg", "box", "diamond", "all_future", "some_future"
  -- We delegate to a small parser.
  let p := PState.ofString s
  match parseFormulaValue p with
  | some (φ, p) =>
    if (PState.skipWhitespace p).atEnd? then some φ else none
  | none => none
where
  parseFormulaValue (p : PState) : Option (Formula × PState) := do
    let p := PState.skipWhitespace p
    let p ← PState.expect p '{'
    let p := PState.skipWhitespace p
    let (tag, p) ← parseJsonString p
    let p := PState.skipWhitespace p
    let p ← PState.expect p ':'
    let p := PState.skipWhitespace p
    -- Now we parse fields. Each field is "key": value
    let rec parseBody (p : PState) (acc : List (String × String)) : Option (List (String × String) × PState) :=
      let p := PState.skipWhitespace p
      match PState.peek? p with
      | some '}' =>
        match PState.consume? p with
        | some (_, p) => some (acc.reverse, p)
        | none => none
      | some ',' =>
        match PState.consume? p with
        | some (_, p) => parseBody p acc
        | none => none
      | some _ =>
        let (k, p) ← parseJsonString p
        let p := PState.skipWhitespace p
        let p ← PState.expect p ':'
        let p := PState.skipWhitespace p
        let (v, p) ← parseJsonValue p
        parseBody p ((k, v) :: acc)
    let (fields, p) ← parseBody p []
    let p := PState.skipWhitespace p
    let p ← PState.expect p '}'
    let lookup : String → Option String
      | n => fields.findSome? fun (k, v) => if k == n then some v else none
    match tag with
    | "atom" =>
      match lookup "name" with
      | some n => some (.atom_s n, p)
      | none => none
    | "var" =>
      match lookup "name" with
      | some n => some (.var n, p)
      | none => none
    | "neg" =>
      match lookup "fmla" with
      | some s =>
        match parseFormula s with
        | some f => some (.neg f, p)
        | none => none
      | none => none
    | "and" =>
      match lookup "fmla" with
      | some s =>
        match parseFormula s with
        | some f => some (.and f, p)
        | none => none
      | none => none
    | "or" =>
      match lookup "fmla" with
      | some s =>
        match parseFormula s with
        | some f => some (.or f, p)
        | none => none
      | none => none
    | "imp" =>
      match lookup "lhs", lookup "rhs" with
      | some ls, some rs =>
        match parseFormula ls, parseFormula rs with
        | some l, some r => some (.imp l r, p)
        | _, _ => none
      | _, _ => none
    | "box" =>
      match lookup "fmla" with
      | some s =>
        match parseFormula s with
        | some f => some (.box f, p)
        | none => none
      | none => none
    | "diamond" =>
      match lookup "fmla" with
      | some s =>
        match parseFormula s with
        | some f => some (.diamond f, p)
        | none => none
      | none => none
    | "all_future" =>
      match lookup "fmla" with
      | some s =>
        match parseFormula s with
        | some f => some (.all_future f, p)
        | none => none
      | none => none
    | "some_future" =>
      match lookup "fmla" with
      | some s =>
        match parseFormula s with
        | some f => some (.some_future f, p)
        | none => none
      | none => none
    | _ => none

/-- Parse a single line into a `Request` (returning a friendly error on failure). -/
def parseRequestLine (line : String) : Either String Request :=
  let trimmed := line.trimAscii.toString
  if trimmed.isEmpty then .error "empty line"
  else if trimmed.startsWith "{" then
    parseRequest trimmed
  else
    .error s!"expected JSON object, got: {trimmed.take 30}"

/-!
## Dispatch
-/

/-- Dispatch a single request to a JSON response string. -/
def dispatchRequest (req : Request) : String :=
  match req.command with
  | "trace_decide" =>
    match req.formula with
    | none => mkErrorJson "trace_decide requires a 'formula' field"
    | some φ =>
      let fc := reqFrameClassToFrameClass req.frameClass
      let result := decideWithTrace φ req.fuel fc
      traceResultToJsonString result
  | "ping" =>
    "{\"status\": \"pong\"}"
  | "shutdown" =>
    "{\"status\": \"shutdown\"}"
  | other =>
    mkErrorJson s!"unknown command: {other}"

/-!
## REPL Loop
-/

/--
Main REPL loop. Reads JSONL requests from stdin, dispatches them, and
writes JSONL responses to stdout. Terminates on EOF or shutdown command.
-/
partial def replLoop : IO Unit := do
  let stdin ← IO.getStdin
  let stdout ← IO.getStdout
  -- Emit ready signal
  stdout.putStrLn "{\"status\": \"ready\"}"
  stdout.flush
  let stderr ← IO.getStderr
  stderr.putStrLn "trace_exporter: ready"
  stderr.flush
  -- Main loop
  let rec loop : IO Unit := do
    let line ← stdin.getLine
    if line.isEmpty then
      return
    let trimmed := line.trimAscii.toString
    if trimmed.isEmpty then
      loop
    else
      match parseRequestLine trimmed with
      | .error msg =>
        stdout.putStrLn (mkErrorJson msg)
        stdout.flush
        loop
      | .ok req =>
        let resp := dispatchRequest req
        stdout.putStrLn resp
        stdout.flush
        if req.command == "shutdown" then
          return
        else
          loop
  loop

end Bimodal.Automation.TraceExporter

/--
Entry point for the `trace_exporter` executable.
-/
def main (_args : List String) : IO Unit :=
  Bimodal.Automation.TraceExporter.replLoop
