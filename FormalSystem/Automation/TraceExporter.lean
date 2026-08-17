/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax
import FormalSystem.ProofSystem
import FormalSystem.Metalogic.Decidability.SignedFormula
import FormalSystem.Metalogic.Decidability.Closure
import FormalSystem.Metalogic.Decidability.TraceCertificate
import FormalSystem.Metalogic.Decidability.DecisionProcedure
import FormalSystem.Metalogic.Decidability.TraceExport
import FormalSystem.Automation.DataExport

/-!
# Trace Exporter CLI: Stream JSONL Proof Certificates

Reads formulas (one per line, S-expression syntax) and emits JSONL
`ProofCertificate`s to stdout.

## S-Expression Formula Format

Each input line is a formula in S-expression notation:
```
(imp (atom p) (atom q))
(box (imp p p))
(neg (or (atom p) (atom q)))
```

The supported tags are: `atom`, `var`, `neg`, `and`, `or`, `imp`,
`box`, `diamond`, `allFuture`, `someFuture`, `allPast`, `somePast`.

## CLI Usage

```
echo '(imp (atom p) (atom q))' | lake exe trace_exporter
```

Or with flags:
```
echo '(imp (atom p) (atom q))' | lake exe trace_exporter -- --fuel 200 --frame-class Base
```

## References

- `FormalSystem.Metalogic.Decidability.DecisionProcedure.decideWithTrace` — main entry point.
- `FormalSystem.Metalogic.Decidability.TraceExport.proofCertificateToJsonString` — JSON serializer.
-/

/-!
# Trace Exporter CLI: Stream JSONL Proof Certificates

Reads formulas (one per line, S-expression syntax) and emits JSONL
`ProofCertificate`s to stdout.

## S-Expression Formula Format

Each input line is a formula in S-expression notation:
```
(imp (atom p) (atom q))
(box (imp p p))
(neg (or (atom p) (atom q)))
```

The supported tags are: `atom`, `var`, `neg`, `and`, `or`, `imp`,
`box`, `diamond`, `allFuture`, `someFuture`, `allPast`, `somePast`.

## CLI Usage

```
echo '(imp (atom p) (atom q))' | lake exe trace_exporter
```

Or with flags:
```
echo '(imp (atom p) (atom q))' | lake exe trace_exporter -- --fuel 200 --frame-class Base
```

## References

- `FormalSystem.Metalogic.Decidability.DecisionProcedure.decideWithTrace` — main entry point.
- `FormalSystem.Metalogic.Decidability.TraceExport.proofCertificateToJsonString` — JSON serializer.
- `FormalSystem.Automation.DatasetExport.parseFormulaSExpr` — S-expression formula parser.
-/

set_option autoImplicit false

namespace FormalSystem.Automation.TraceExporter

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.TraceExport
open FormalSystem.Automation.DataExport

/-!
## S-Expression Formula Parser

A minimal recursive-descent parser for S-expression formulas. Supports
the following tags (which map to `Formula` constructors):
- `atom <name>`: `Formula.atomS <name>`
- `bot`: `Formula.bot`
- `imp <lhs> <rhs>`: `Formula.imp l r`
- `box <fmla>`: `Formula.box f`
- `untl <lhs> <rhs>`: `Formula.untl l r` (Until)
- `snce <lhs> <rhs>`: `Formula.snce l r` (Since)
-/

partial def readToken (acc : List Char) (chars : List Char) : List Char × List Char :=
  match chars with
  | [] => (acc, [])
  | c :: rest =>
    if c == ' ' ∨ c == Char.ofNat 9 ∨ c == Char.ofNat 10 ∨ c == Char.ofNat 13 ∨ c == '(' ∨ c == ')'
        then
      (acc, chars)
    else
      readToken (c :: acc) rest

/-- Tokenize an S-expression string into a list of tokens. -/
partial def tokenizeSExpr (s : String) : List String :=
  let rec tokenizeLoop (acc : List String) (chars : List Char) : List String :=
    match chars with
    | [] => acc.reverse
    | c :: rest =>
      if c == ' ' ∨ c == Char.ofNat 9 ∨ c == Char.ofNat 10 ∨ c == Char.ofNat 13 then
        tokenizeLoop acc rest
      else if c == '(' ∨ c == ')' then
        tokenizeLoop (c.toString :: acc) rest
      else
        let (token, rest') := readToken [c] rest
        tokenizeLoop (String.ofList token.reverse :: acc) rest'
  tokenizeLoop [] s.toList

/-- Parse an S-expression formula string. Returns `none` on failure. -/
partial def parseSExprFormula (s : String) : Option Formula :=
  let tokens := tokenizeSExpr s
  match parseFromTokens tokens with
  | some (φ, []) => some φ
  | _ => none
where
  parseFromTokens : List String → Option (Formula × List String)
    | [] => none
    | "(" :: rest =>
      match rest with
      | [] => none
      | "atom" :: name :: rest2 =>
        match rest2 with
        | ")" :: more => some (.atomS name, more)
        | _ => none
      | "bot" :: ")" :: more => some (.bot, more)
      | "imp" :: rest2 =>
        match parseFromTokens rest2 with
        | some (l, rest3) =>
          match parseFromTokens rest3 with
          | some (r, ")" :: more) => some (.imp l r, more)
          | _ => none
        | _ => none
      | "box" :: rest2 =>
        match parseFromTokens rest2 with
        | some (f, ")" :: more) => some (.box f, more)
        | _ => none
      | "untl" :: rest2 =>
        match parseFromTokens rest2 with
        | some (l, rest3) =>
          match parseFromTokens rest3 with
          | some (r, ")" :: more) => some (.untl r l, more)
          | _ => none
        | _ => none
      | "snce" :: rest2 =>
        match parseFromTokens rest2 with
        | some (l, rest3) =>
          match parseFromTokens rest3 with
          | some (r, ")" :: more) => some (.snce r l, more)
          | _ => none
        | _ => none
      | _ => none
    | _ => none

/-!
## Configuration
-/

/-- Runtime configuration for the trace exporter. -/
structure Config where
  /-- Maximum tableau expansion steps. -/
  fuel : Nat := 500
  /-- Frame class to use (Base, Dense, Discrete). -/
  frameClass : FrameClass := .Base
  deriving Inhabited

/-- Parse a frame-class string from the CLI. -/
def parseFrameClass? (s : String) : Option FrameClass :=
  match s with
  | "Base"     => some .Base
  | "Dense"    => some .Dense
  | "Discrete" => some .Discrete
  | _          => none

/-- Parse the `--fuel N` and `--frame-class X` flags from CLI args. -/
def parseArgs (args : List String) : Config :=
  let rec loop (args : List String) (cfg : Config) : Config :=
    match args with
    | [] => cfg
    | "--fuel" :: n :: rest =>
      match n.toNat? with
      | some k => loop rest { cfg with fuel := k }
      | none => loop rest cfg
    | "--frame-class" :: fc :: rest =>
      match parseFrameClass? fc with
      | some f => loop rest { cfg with frameClass := f }
      | none => loop rest cfg
    | _ :: rest => loop rest cfg
  loop args { fuel := 500, frameClass := .Base }

/-!
## Per-Line Processing
-/

/-- Process a single formula line: parse, decide, emit JSONL. -/
def processLine (line : String) (cfg : Config) : String :=
  let trimmed := line.trimAscii.toString
  if trimmed.isEmpty then ""
  else
    match parseSExprFormula trimmed with
    | none =>
      "{\"status\": \"error\", \"message\": \"failed to parse formula: " ++
        escapeJsonString trimmed ++ "\"}"
    | some φ =>
      let result := decideWithTrace φ cfg.fuel cfg.frameClass
      traceResultToJsonString result

/-!
## Main Loop
-/

/-- Read stdin line-by-line and emit one JSONL result per line. -/
partial def mainLoop (cfg : Config) : IO Unit := do
  let stdin ← IO.getStdin
  let stdout ← IO.getStdout
  let rec loop : IO Unit := do
    let line ← stdin.getLine
    if line.isEmpty then
      return
    let result := processLine line cfg
    if not result.isEmpty then
      stdout.putStrLn result
      stdout.flush
    loop
  loop

end FormalSystem.Automation.TraceExporter

/--
Entry point for the `trace_exporter` executable.

Usage:
```
echo '(imp (atom p) (atom q))' | lake exe trace_exporter
```
-/
def main (args : List String) : IO Unit := do
  let cfg := FormalSystem.Automation.TraceExporter.parseArgs args
  FormalSystem.Automation.TraceExporter.mainLoop cfg
