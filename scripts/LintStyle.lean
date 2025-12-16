/-
Copyright (c) 2025 Logos Project. All rights reserved.
Released under MIT license as described in the LICENSE file.
Authors: Logos Contributors

Text-based linter for source file style checks.
Checks whitespace, line length, and other text-level issues.
-/

import Lean

open Lean System IO

/-- Text-based linter for source file style -/
structure StyleLinter where
  name : String
  check : String → Array (Nat × String)  -- Line number × error message
  fix : String → String := id

/-- Check for trailing whitespace -/
def trailingWhitespaceLinter : StyleLinter where
  name := "trailingWhitespace"
  check := fun content =>
    let lines := content.splitOn "\n"
    let results := lines.toArray.mapIdx fun idx line =>
      if line.endsWith " " || line.endsWith "\t" then
        #[(idx + 1, "Trailing whitespace")]
      else
        #[]
    results.flatten
  fix := fun content =>
    let lines := content.splitOn "\n"
    String.intercalate "\n" (lines.map (·.trimRight))

/-- Check for line length violations (100 char limit) -/
def longLineLinter (maxLength : Nat := 100) : StyleLinter where
  name := "longLine"
  check := fun content =>
    let lines := content.splitOn "\n"
    let results := lines.toArray.mapIdx fun idx line =>
      if line.length > maxLength then
        #[(idx + 1, s!"Line exceeds {maxLength} characters ({line.length})")]
      else
        #[]
    results.flatten
  fix := id  -- Cannot auto-fix long lines safely

/-- Check for non-breaking spaces (U+00A0) which should be regular spaces -/
def nonBreakingSpaceLinter : StyleLinter where
  name := "nonBreakingSpace"
  check := fun content =>
    let lines := content.splitOn "\n"
    let results := lines.toArray.mapIdx fun idx line =>
      -- Check if line contains non-breaking space character
      if line.any (· == '\u00A0') then
        #[(idx + 1, "Non-breaking space found (use regular space)")]
      else
        #[]
    results.flatten
  fix := fun content =>
    -- Replace all non-breaking spaces with regular spaces
    String.mk (content.toList.map fun c => if c == '\u00A0' then ' ' else c)

/-- All text-based linters -/
def allStyleLinters : Array StyleLinter := #[
  trailingWhitespaceLinter,
  longLineLinter 100,
  nonBreakingSpaceLinter
]

/-- Parse command line arguments -/
structure StyleLinterArgs where
  fix : Bool := false
  verbose : Bool := false
  files : List String := []
  deriving Inhabited

/-- Parse arguments from command line -/
def parseArgs (args : List String) : StyleLinterArgs :=
  let rec go (args : List String) (acc : StyleLinterArgs) : StyleLinterArgs :=
    match args with
    | [] => acc
    | "--fix" :: rest => go rest { acc with fix := true }
    | "--verbose" :: rest => go rest { acc with verbose := true }
    | arg :: rest =>
      if arg.startsWith "--" then
        go rest acc  -- Skip unknown flags
      else if arg.endsWith ".lean" then
        go rest { acc with files := acc.files ++ [arg] }
      else
        go rest acc
  go args {}

/-- Find all .lean files in a directory recursively -/
partial def findLeanFiles (dir : String) : IO (Array String) := do
  let mut files : Array String := #[]
  
  -- Check if directory exists
  if !(← FilePath.pathExists dir) then
    return files
  
  -- Read directory entries
  let entries ← FilePath.readDir dir
  
  for entry in entries do
    let path := dir ++ "/" ++ entry.fileName
    
    if ← FilePath.isDir path then
      -- Recursively search subdirectories
      files := files ++ (← findLeanFiles path)
    else if entry.fileName.endsWith ".lean" then
      -- Add .lean file
      files := files.push path
  
  return files

/-- Main entry point for text-based linting -/
def main (args : List String) : IO UInt32 := do
  let linterArgs := parseArgs args
  
  -- Determine files to lint
  let mut filesToLint : Array String := #[]
  
  if linterArgs.files.isEmpty then
    -- Lint all Logos files by default
    if linterArgs.verbose then
      IO.println "[LintStyle] No files specified, linting all Logos files..."
    filesToLint := ← findLeanFiles "Logos"
  else
    filesToLint := linterArgs.files.toArray
  
  if linterArgs.verbose then
    IO.println s!"[LintStyle] Logos Style Linter v1.0.0"
    IO.println s!"[LintStyle] Files to check: {filesToLint.size}"
    IO.println s!"[LintStyle] Fix mode: {linterArgs.fix}"
  
  let mut totalErrors := 0
  let mut totalFiles := 0
  let mut filesWithErrors := 0
  
  for file in filesToLint do
    -- Check if file exists
    if !(← FilePath.pathExists file) then
      if linterArgs.verbose then
        IO.println s!"[LintStyle] Skipping non-existent file: {file}"
      continue
    
    totalFiles := totalFiles + 1
    
    if linterArgs.verbose then
      IO.println s!"[LintStyle] Checking {file}..."
    
    let content ← IO.FS.readFile file
    let mut fileErrors := 0
    let mut fixedContent := content
    
    for linter in allStyleLinters do
      let errors := linter.check content
      fileErrors := fileErrors + errors.size
      
      if errors.size > 0 then
        IO.println s!"{file}: {linter.name} ({errors.size} issues)"
        for (line, msg) in errors do
          IO.println s!"  Line {line}: {msg}"
      
      if linterArgs.fix then
        fixedContent := linter.fix fixedContent
    
    if linterArgs.fix && fileErrors > 0 then
      IO.FS.writeFile file fixedContent
      IO.println s!"✓ Fixed {fileErrors} issues in {file}"
    
    if fileErrors > 0 then
      filesWithErrors := filesWithErrors + 1
    
    totalErrors := totalErrors + fileErrors
  
  -- Summary
  IO.println ""
  IO.println s!"[LintStyle] Checked {totalFiles} files"
  
  if totalErrors > 0 then
    IO.eprintln s!"✗ Found {totalErrors} style issues in {filesWithErrors} files"
    if !linterArgs.fix then
      IO.println "  Run with --fix to automatically fix some issues"
    return 1
  else
    IO.println "✓ All style checks passed"
    return 0
