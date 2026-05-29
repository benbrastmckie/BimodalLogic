import Bimodal.Automation.DatasetGenerator
import Bimodal.Automation.DataExport

/-!
# Benchmark Oracle: Formula Labeling via Decision Procedure

This module provides a batch oracle executable that reads formula AST JSON
strings from a file (one per line), parses each into a `Formula`, runs the
decision procedure, and outputs labeled results as JSONL.

The oracle uses a hand-rolled JSON parser for the formula AST schema.

## Usage

```
lake exe benchmark_oracle -- --input formulas.txt --output results.jsonl
```

Where `formulas.txt` contains one JSON AST per line.

## References

- Task 205 Phase 3 implementation plan
- `DatasetGenerator.lean`: `labelFormula`, `LabeledFormula`
-/

set_option autoImplicit false

namespace Bimodal.Automation.BenchmarkOracle

open Bimodal.Syntax
open Bimodal.Automation
open Bimodal.Automation.DataExport

/-!
## Simple recursive-descent JSON AST parser for Formula
-/

/-- Parser state: remaining characters and position. -/
structure PState where
  chars : Array Char
  pos : Nat
  deriving Repr, Inhabited

def mkPState (s : String) : PState :=
  { chars := s.toList.toArray, pos := 0 }

def pEof (st : PState) : Bool := st.pos ≥ st.chars.size

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

/-- Extract and parse the formula_ast field from a JSONL record line. -/
def parseFormulaFromRecord (line : String) : Except String Formula := do
  -- Find "formula_ast": in the line
  let key := "\"formula_ast\":"
  let parts := line.splitOn key
  if parts.length < 2 then
    throw "no formula_ast field found"
  else
    -- Get everything after the key
    match parts.drop 1 |>.head? with
    | none => throw "empty after formula_ast key"
    | some rest =>
      let st := mkPState rest
      let st := pSkipWS st
      let (formula, _) ← pFormula st
      return formula

/-- Check if a string contains a substring using splitOn. -/
def strContains (s : String) (sub : String) : Bool :=
  (s.splitOn sub).length > 1

end Bimodal.Automation.BenchmarkOracle

/-!
## Main Entry Point
-/

open Bimodal.Automation
open Bimodal.Automation.BenchmarkOracle
open Bimodal.Automation.DataExport

def main (args : List String) : IO Unit := do
  let argsArr := args.toArray
  let mut inputPath := "data/bmlogic-bench-candidates.jsonl"
  let mut outputPath := "data/bmlogic-bench-validated.jsonl"
  let mut i := 0
  while i < argsArr.size do
    match argsArr[i]? with
    | some "--input" =>
      match argsArr[i + 1]? with
      | some p => inputPath := p; i := i + 2
      | none => i := i + 1
    | some "--output" =>
      match argsArr[i + 1]? with
      | some p => outputPath := p; i := i + 2
      | none => i := i + 1
    | _ => i := i + 1

  IO.println "BMLogic-Bench Oracle Validator"
  IO.println "=============================="
  IO.println s!"Input:  {inputPath}"
  IO.println s!"Output: {outputPath}"
  IO.println ""

  let contents ← IO.FS.readFile ⟨inputPath⟩
  let lines := contents.splitOn "\n" |>.filter (· ≠ "")
  IO.println s!"Read {lines.length} candidate records"

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

    let isUnlabeled := strContains line "\"unlabeled\""
    let hasTimeout := strContains line "\"label\": \"timeout\""
    let needsLabeling := isUnlabeled || hasTimeout

    if !needsLabeling then
      outHandle.putStrLn line
      if strContains line "\"label\": \"valid\"" then
        validCount := validCount + 1
      else
        invalidCount := invalidCount + 1
      alreadyLabeled := alreadyLabeled + 1
    else
      match parseFormulaFromRecord line with
      | .error _e =>
        parseErrors := parseErrors + 1
      | .ok formula =>
        let labeled ← labelFormula formula
        let labelStr := match labeled.label with
          | .valid => "valid"
          | .invalid => "invalid"
          | .timeout => "timeout"
        let traceStr := match labeled.proofTrace with
          | none => "null"
          | some pt => pt.toJson
        let cmStr := match labeled.countermodel with
          | none => "null"
          | some cm => cm.toJson

        -- Extract id from the input line
        let idParts := line.splitOn "\"id\": \""
        let recordId := if idParts.length >= 2 then
          match (idParts.drop 1 |>.head?) with
          | some rest => (rest.splitOn "\"").head?.getD ""
          | none => s!"oracle-{processed}"
        else s!"oracle-{processed}"

        let outputLine := "{\"id\": \""
          ++ escapeJsonString recordId
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
