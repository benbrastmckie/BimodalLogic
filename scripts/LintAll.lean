/-
Copyright (c) 2025 Logos Project. All rights reserved.
Released under MIT license as described in the LICENSE file.
Authors: Logos Contributors

Main lint driver that orchestrates all linting phases for the Logos project.
This executable is registered as the `@[lint_driver]` in lakefile.lean and is
invoked by `lake lint`.
-/

import Lean

open Lean System IO

/-- Parse command line arguments for the lint driver -/
structure LintArgs where
  verbose : Bool := false
  fix : Bool := false
  modules : List String := []
  deriving Inhabited

/-- Parse arguments from command line -/
def parseLintArgs (args : List String) : LintArgs :=
  let rec go (args : List String) (acc : LintArgs) : LintArgs :=
    match args with
    | [] => acc
    | "--verbose" :: rest => go rest { acc with verbose := true }
    | "--fix" :: rest => go rest { acc with fix := true }
    | arg :: rest =>
      if arg.startsWith "--" then
        go rest acc  -- Skip unknown flags
      else
        go rest { acc with modules := acc.modules ++ [arg] }
  go args {}

/-- Run environment linters on compiled modules -/
def runEnvLinters (args : LintArgs) : IO UInt32 := do
  if args.verbose then
    IO.println "[LintAll] Running environment linters..."
  
  -- Build command to run environment linters
  let mut cmdArgs : Array String := #["exe", "runEnvLinters"]
  
  if args.verbose then
    cmdArgs := cmdArgs.push "--verbose"
  
  for module in args.modules do
    cmdArgs := cmdArgs.push module
  
  -- Execute environment linter
  let output ← IO.Process.output {
    cmd := "lake"
    args := cmdArgs
  }
  
  if output.exitCode ≠ 0 then
    IO.eprintln output.stderr
    if args.verbose then
      IO.println s!"[LintAll] Environment linting failed with exit code {output.exitCode}"
  else if args.verbose then
    IO.println "[LintAll] Environment linting: PASSED"
  
  return output.exitCode

/-- Run text-based linters on source files -/
def runTextLinters (args : LintArgs) : IO UInt32 := do
  if args.verbose then
    IO.println "[LintAll] Running text-based linters..."
  
  -- Build command to run text-based linters
  let mut cmdArgs : Array String := #["exe", "lintStyle"]
  
  if args.verbose then
    cmdArgs := cmdArgs.push "--verbose"
  
  if args.fix then
    cmdArgs := cmdArgs.push "--fix"
  
  for module in args.modules do
    cmdArgs := cmdArgs.push module
  
  -- Execute text-based linter
  let output ← IO.Process.output {
    cmd := "lake"
    args := cmdArgs
  }
  
  if output.exitCode ≠ 0 then
    IO.eprintln output.stderr
    if args.verbose then
      IO.println s!"[LintAll] Text-based linting failed with exit code {output.exitCode}"
  else if args.verbose then
    IO.println "[LintAll] Text-based linting: PASSED"
  
  return output.exitCode

/-- Main lint driver entry point -/
def main (args : List String) : IO UInt32 := do
  let lintArgs := parseLintArgs args
  
  if lintArgs.verbose then
    IO.println "[LintAll] Logos Lint Driver v1.0.0"
    IO.println s!"[LintAll] Modules: {lintArgs.modules}"
    IO.println s!"[LintAll] Fix mode: {lintArgs.fix}"
  
  let mut exitCode : UInt32 := 0
  
  -- Phase 1: Environment linters (post-build checks)
  let envExitCode ← runEnvLinters lintArgs
  if envExitCode ≠ 0 then
    exitCode := 1
  
  -- Phase 2: Text-based linters (source file checks)
  let textExitCode ← runTextLinters lintArgs
  if textExitCode ≠ 0 then
    exitCode := 1
  
  -- Summary
  if exitCode = 0 then
    IO.println "✓ All linters passed"
  else
    IO.eprintln "✗ Linting failed - see errors above"
  
  return exitCode
