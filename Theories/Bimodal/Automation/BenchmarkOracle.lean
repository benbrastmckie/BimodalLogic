import Bimodal.Automation.DatasetGenerator
import Bimodal.Automation.DataExport

/-!
# Benchmark Oracle: Formula Labeling via Decision Procedure

This module provides a batch oracle executable that reads formula ASTs from
a JSONL file, runs the decision procedure on each formula, and outputs
labeled results.

The oracle reads each line as a JSON record containing a `formula_ast` field,
parses the AST into a `Formula`, labels it via `labelFormula`, and writes
the result as a JSONL record to stdout or a file.

## Formula AST JSON Format

The AST follows the same schema as the production dataset:
- `{"tag": "atom", "name": "p"}`
- `{"tag": "bot"}`
- `{"tag": "imp", "left": <ast>, "right": <ast>}`
- `{"tag": "box", "child": <ast>}`
- `{"tag": "untl", "event": <ast>, "guard": <ast>}`
- `{"tag": "snce", "event": <ast>, "guard": <ast>}`

## Usage

```
lake exe benchmark_oracle -- --input data/bmlogic-bench-candidates.jsonl --output data/bmlogic-bench-validated.jsonl
```

## References

- Task 205 Phase 3 implementation plan
- `DatasetGenerator.lean`: `labelFormula`, `LabeledFormula`
- `DataExport.lean`: JSON serialization primitives
-/

set_option autoImplicit false

namespace Bimodal.Automation.BenchmarkOracle

open Bimodal.Syntax
open Bimodal.Automation
open Bimodal.Automation.DataExport

/-!
## Minimal JSON Parser for Formula ASTs

A hand-rolled recursive-descent parser that converts JSON strings into
`Formula` values. Only handles the specific JSON schema used for formula ASTs.
-/

/-- Parser state: the remaining string to parse and current position. -/
structure ParseState where
  input : String
  pos : String.Pos
  deriving Repr

/-- Parser monad: either success with value and new state, or error. -/
abbrev Parser (α : Type) := ParseState → Except String (α × ParseState)

/-- Create a parse state from a string. -/
def mkParseState (s : String) : ParseState :=
  { input := s, pos := ⟨0⟩ }

/-- Check if the parser has reached end of input. -/
def isEof (st : ParseState) : Bool :=
  st.pos ≥ st.input.endPos

/-- Peek at the current character without consuming it. -/
def peek (st : ParseState) : Option Char :=
  if isEof st then none
  else some (st.input.get st.pos)

/-- Consume one character and advance. -/
def advance (st : ParseState) : ParseState :=
  if isEof st then st
  else { st with pos := st.input.next st.pos }

/-- Skip whitespace characters. -/
def skipWS (st : ParseState) : ParseState := Id.run do
  let mut st := st
  while !isEof st do
    let c := st.input.get st.pos
    if c == ' ' || c == '\n' || c == '\r' || c == '\t' then
      st := { st with pos := st.input.next st.pos }
    else
      break
  st

/-- Consume a specific character or fail. -/
def expectChar (c : Char) (st : ParseState) : Except String ParseState :=
  let st := skipWS st
  match peek st with
  | some c' =>
    if c == c' then .ok (advance st)
    else .error s!"expected '{c}' but got '{c}' at position {st.pos.byteIdx}"
  | none => .error s!"expected '{c}' but got EOF"

/-- Parse a JSON string value (after the opening quote). -/
partial def parseJsonString (st : ParseState) : Except String (String × ParseState) := do
  let st := skipWS st
  let st ← expectChar '"' st
  let mut result : String := ""
  let mut st := st
  while true do
    if isEof st then
      throw "unterminated string"
    let c := st.input.get st.pos
    if c == '"' then
      st := advance st
      return (result, st)
    else if c == '\\' then
      st := advance st
      if isEof st then throw "unterminated escape"
      let escaped := st.input.get st.pos
      st := advance st
      match escaped with
      | '"' => result := result.push '"'
      | '\\' => result := result.push '\\'
      | 'n' => result := result.push '\n'
      | _ => result := result.push escaped
    else
      result := result.push c
      st := advance st
  throw "unreachable"

/-- Skip a JSON value (string, number, object, array, null, true, false). -/
partial def skipJsonValue (st : ParseState) : Except String ParseState := do
  let st := skipWS st
  match peek st with
  | some '"' =>
    let (_, st) ← parseJsonString st
    return st
  | some '{' =>
    let mut st := advance st  -- skip {
    let st' := skipWS st
    match peek st' with
    | some '}' => return (advance st')  -- empty object
    | _ =>
      -- Parse key-value pairs
      while true do
        let (_, st') ← parseJsonString st
        let st' := skipWS st'
        let st' ← expectChar ':' st'
        let st' ← skipJsonValue st'
        let st' := skipWS st'
        match peek st' with
        | some ',' => st := advance st'  -- more pairs
        | some '}' => return (advance st')  -- end object
        | _ => throw "expected ',' or '}'"
      throw "unreachable"
  | some '[' =>
    let mut st := advance st  -- skip [
    let st' := skipWS st
    match peek st' with
    | some ']' => return (advance st')  -- empty array
    | _ =>
      while true do
        let st' ← skipJsonValue st
        let st' := skipWS st'
        match peek st' with
        | some ',' => st := advance st'
        | some ']' => return (advance st')
        | _ => throw "expected ',' or ']'"
      throw "unreachable"
  | some c =>
    if c == 'n' || c == 't' || c == 'f' || c.isDigit || c == '-' then
      -- Skip literal (null, true, false, number)
      let mut st := st
      while !isEof st do
        let c := st.input.get st.pos
        if c == ',' || c == '}' || c == ']' || c == ' ' || c == '\n' || c == '\r' then
          break
        st := advance st
      return st
    else
      throw s!"unexpected character '{c}'"
  | none => throw "unexpected EOF in value"

/--
Parse a formula AST from a JSON object string.

Expected format:
- `{"tag": "atom", "name": "p"}`
- `{"tag": "bot"}`
- `{"tag": "imp", "left": <ast>, "right": <ast>}`
- `{"tag": "box", "child": <ast>}`
- `{"tag": "untl", "event": <ast>, "guard": <ast>}`
- `{"tag": "snce", "event": <ast>, "guard": <ast>}`
-/
partial def parseFormulaAst (st : ParseState) : Except String (Formula × ParseState) := do
  let st := skipWS st
  let st ← expectChar '{' st

  -- Parse fields: we need to find "tag" first, then other fields
  let mut tag : String := ""
  let mut fields : List (String × String) := []
  let mut subFormulas : List (String × Formula) := []
  let mut st := st

  while true do
    let st' := skipWS st
    match peek st' with
    | some '}' =>
      st := advance st'
      break
    | _ => pure ()

    -- Parse key
    let (key, st') ← parseJsonString st
    let st' := skipWS st'
    let st' ← expectChar ':' st'
    let st' := skipWS st'

    if key == "tag" then
      let (val, st') ← parseJsonString st'
      tag := val
      st := st'
    else if key == "name" then
      let (val, st') ← parseJsonString st'
      fields := (key, val) :: fields
      st := st'
    else if key == "left" || key == "right" || key == "child" ||
            key == "event" || key == "guard" then
      let (formula, st') ← parseFormulaAst st'
      subFormulas := (key, formula) :: subFormulas
      st := st'
    else
      -- Skip unknown fields
      let st' ← skipJsonValue st'
      st := st'

    let st' := skipWS st
    match peek st' with
    | some ',' => st := advance st'
    | some '}' =>
      st := advance st'
      break
    | _ => throw s!"expected ',' or '}}' in formula object at pos {st'.pos.byteIdx}"

  -- Construct formula from parsed tag and fields
  let getField (name : String) : Except String Formula :=
    match subFormulas.find? (fun (k, _) => k == name) with
    | some (_, f) => .ok f
    | none => .error s!"missing field '{name}' for tag '{tag}'"

  let getStringField (name : String) : Except String String :=
    match fields.find? (fun (k, _) => k == name) with
    | some (_, v) => .ok v
    | none => .error s!"missing string field '{name}' for tag '{tag}'"

  match tag with
  | "atom" =>
    let name ← getStringField "name"
    return (Formula.atom_s name, st)
  | "bot" =>
    return (Formula.bot, st)
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
  | _ =>
    throw s!"unknown formula tag: '{tag}'"

/--
Extract the `formula_ast` field from a JSON line and parse it into a Formula.
This is a simplified extraction that finds `"formula_ast":` in the JSON line
and parses the AST object that follows.
-/
def parseFormulaFromLine (line : String) : Except String Formula := do
  -- Find "formula_ast": in the line
  let key := "\"formula_ast\":"
  match line.findSubstr? key with
  | none => throw "no formula_ast field found"
  | some startIdx =>
    let afterKey := { line with }.extract (line.next (⟨startIdx.byteIdx + key.length - 1⟩)) line.endPos
    let st := mkParseState afterKey
    let st := skipWS st
    let (formula, _) ← parseFormulaAst st
    return formula
where
  /-- Find a substring in a string, returning its byte position. -/
  findSubstr? (s : String) (needle : String) : Option Nat := Id.run do
    let sLen := s.length
    let nLen := needle.length
    if nLen > sLen then return none
    for i in List.range (sLen - nLen + 1) do
      let sub := s.extract ⟨i⟩ ⟨i + nLen⟩
      if sub == needle then return some i
    return none

end Bimodal.Automation.BenchmarkOracle

/-!
## Main Entry Point
-/

open Bimodal.Automation
open Bimodal.Automation.BenchmarkOracle
open Bimodal.Automation.DataExport

/--
Main entry point for the benchmark_oracle executable.

Reads a JSONL file of candidate formulas, parses each formula_ast,
runs the decision procedure, and writes labeled results.
-/
def main (args : List String) : IO Unit := do
  -- Parse arguments
  let mut inputPath := "data/bmlogic-bench-candidates.jsonl"
  let mut outputPath := "data/bmlogic-bench-validated.jsonl"
  let mut i := 0
  while i < args.length do
    match args.get? i with
    | some "--input" =>
      match args.get? (i + 1) with
      | some p => inputPath := p; i := i + 2
      | none => i := i + 1
    | some "--output" =>
      match args.get? (i + 1) with
      | some p => outputPath := p; i := i + 2
      | none => i := i + 1
    | _ => i := i + 1

  IO.println "BMLogic-Bench Oracle Validator"
  IO.println "=============================="
  IO.println s!"Input:  {inputPath}"
  IO.println s!"Output: {outputPath}"
  IO.println ""

  -- Read input file
  let contents ← IO.FS.readFile ⟨inputPath⟩
  let lines := contents.splitOn "\n" |>.filter (· ≠ "")
  IO.println s!"Read {lines.length} candidate records"

  -- Process each line
  let outHandle ← IO.FS.Handle.mk ⟨outputPath⟩ .write
  let mut validCount : Nat := 0
  let mut invalidCount : Nat := 0
  let mut timeoutCount : Nat := 0
  let mut parseErrors : Nat := 0
  let mut alreadyLabeled : Nat := 0
  let mut processed : Nat := 0

  for line in lines do
    processed := processed + 1
    if processed % 100 == 0 then
      IO.println s!"  Progress: {processed}/{lines.length}"

    -- Check if this record already has a definitive label (not "unlabeled")
    -- If it does, pass through unchanged (just verify consistency)
    let isUnlabeled := line.containsSubstr "\"unlabeled\""
    let needsLabeling := isUnlabeled || line.containsSubstr "\"timeout\""

    if !needsLabeling then
      -- Pass through with existing label
      outHandle.putStrLn line
      if line.containsSubstr "\"valid\"" then
        validCount := validCount + 1
      else
        invalidCount := invalidCount + 1
      alreadyLabeled := alreadyLabeled + 1
    else
      -- Parse formula and run oracle
      match parseFormulaFromLine line with
      | .error e =>
        -- Parse failed; write with error annotation
        parseErrors := parseErrors + 1
        -- Skip this record
      | .ok formula =>
        let labeled ← labelFormula formula
        let labelStr := match labeled.label with
          | .valid => "valid"
          | .invalid => "invalid"
          | .timeout => "timeout"

        -- Build updated record: replace label, add proof/countermodel
        let traceStr := match labeled.proofTrace with
          | none => "null"
          | some pt => pt.toJson
        let cmStr := match labeled.countermodel with
          | none => "null"
          | some cm => cm.toJson

        -- Construct output line: keep original fields but update label/proof/countermodel
        let outputLine := "{\"id\": \""
          ++ escapeJsonString (extractField line "id")
          ++ "\", \"split\": \"benchmark\""
          ++ ", \"formula_str\": \"" ++ escapeJsonString labeled.formula.prettyPrint ++ "\""
          ++ ", \"formula_ast\": " ++ labeled.formula.toJson
          ++ ", \"frame_class\": \"Base\""
          ++ ", \"label\": \"" ++ labelStr ++ "\""
          ++ ", \"proof_trace\": " ++ traceStr
          ++ ", \"countermodel\": " ++ cmStr
          ++ ", \"pattern_key\": " ++ labeled.patternKey.toJson
          ++ ", \"metrics\": " ++ labeled.metrics.toJson
          ++ "}"
        outHandle.putStrLn outputLine

        match labeled.label with
        | .valid => validCount := validCount + 1
        | .invalid => invalidCount := invalidCount + 1
        | .timeout => timeoutCount := timeoutCount + 1

  IO.println ""
  IO.println "Results"
  IO.println "======="
  IO.println s!"  Processed: {processed}"
  IO.println s!"  Already labeled (pass-through): {alreadyLabeled}"
  IO.println s!"  Valid: {validCount}"
  IO.println s!"  Invalid: {invalidCount}"
  IO.println s!"  Timeout: {timeoutCount}"
  IO.println s!"  Parse errors: {parseErrors}"
  IO.println ""
  IO.println "Done!"
where
  /-- Extract a simple string field value from a JSON line. -/
  extractField (line : String) (fieldName : String) : String := Id.run do
    let key := "\"" ++ fieldName ++ "\": \""
    match line.findSubstr? key with
    | none => return ""
    | some idx =>
      let start := idx + key.length
      -- Find closing quote (not escaped)
      let mut pos := start
      while pos < line.length do
        let c := line.get ⟨pos⟩
        if c == '"' then
          return line.extract ⟨start⟩ ⟨pos⟩
        else if c == '\\' then
          pos := pos + 2  -- skip escaped char
        else
          pos := pos + 1
      return ""
  findSubstr? (s : String) (needle : String) : Option Nat := Id.run do
    let sLen := s.length
    let nLen := needle.length
    if nLen > sLen then return none
    for i in List.range (sLen - nLen + 1) do
      let sub := s.extract ⟨i⟩ ⟨i + nLen⟩
      if sub == needle then return some i
    return none
