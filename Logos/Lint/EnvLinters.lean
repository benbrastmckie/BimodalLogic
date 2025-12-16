/-
Copyright (c) 2025 Logos Project. All rights reserved.
Released under MIT license as described in the LICENSE file.
Authors: Logos Contributors

Custom environment linters for the Logos project.
These linters run post-build and check compiled modules for TM-specific
conventions and quality standards.
-/

import Batteries.Tactic.Lint
import Lean

open Lean Meta Elab Command

/-- Check if a string contains a substring -/
def String.hasSubstring (s : String) (sub : String) : Bool :=
  (s.splitOn sub).length > 1

/--
Check that all public theorems have documentation.
This enforces the project requirement for 100% docstring coverage on theorems.
-/
@[env_linter]
def docBlameTheorems : Batteries.Tactic.Lint.Linter where
  noErrorsFound := "All public theorems documented."
  errorsFound := "MISSING THEOREM DOCUMENTATION:"
  test declName := do
    let info ← getConstInfo declName
    -- Check if theorem and public (not internal/private)
    if info.isTheorem && !declName.isInternal then
      -- Check for docstring
      if (← findDocString? (← getEnv) declName).isNone then
        return some m!"Missing docstring for theorem `{declName}`"
    return none

/--
Check TM-specific naming conventions for modal and temporal operators.
Ensures consistency in naming across the codebase.
-/
@[env_linter]
def tmNamingConventions : Batteries.Tactic.Lint.Linter where
  noErrorsFound := "All declarations follow TM naming conventions."
  errorsFound := "NAMING CONVENTION VIOLATIONS:"
  test declName := do
    let name := declName.toString

    -- Skip internal and test declarations
    if declName.isInternal || (name.hasSubstring "Test") then
      return none

    -- Check for modal operator naming (box/diamond should include 'modal' context)
    -- Allow exceptions for core definitions like Formula.box
    if ((name.hasSubstring "box" || name.hasSubstring "diamond") &&
       !(name.hasSubstring "Formula") &&
       !(name.hasSubstring "modal") &&
       !(name.hasSubstring "Modal")) then
      return some m!"Modal operator `{declName}` should include 'modal' in name for clarity"

    -- Check for temporal operator naming (past/future should include 'temporal' context)
    -- Allow exceptions for core definitions like Formula.all_past
    if (((name.hasSubstring "past" || name.hasSubstring "future") &&
        !(name.hasSubstring "Formula") &&
        !(name.hasSubstring "temporal") &&
        !(name.hasSubstring "Temporal") &&
        !(name.hasSubstring "perpetuity") &&  -- Perpetuity theorems are exempt
        !(name.hasSubstring "Perpetuity"))) then
      return some m!"Temporal operator `{declName}` should include 'temporal' in name for clarity"

    return none

/--
Check proof structure - warn about sorry placeholders in non-test files.
This is disabled by default but can be enabled for strict quality checks.
-/
@[env_linter disabled]
def noSorryInProofs : Batteries.Tactic.Lint.Linter where
  noErrorsFound := "No sorry placeholders found."
  errorsFound := "SORRY PLACEHOLDERS FOUND:"
  test declName := do
    let info ← getConstInfo declName
    let name := declName.toString

    -- Skip test files
    if name.hasSubstring "Test" then
      return none

    -- Check if theorem/definition
    if info.isTheorem then
      -- Check if proof contains sorry
      -- Note: This is a simplified check. Full implementation would
      -- traverse the proof term to detect Expr.sorry
      let value := info.value!
      if value.hasSorry then
        return some m!"Theorem `{declName}` contains sorry placeholder"

    return none

/--
Check that axioms are properly documented with mathematical statements.
Axioms should have comprehensive docstrings explaining their logical meaning.
-/
@[env_linter]
def axiomDocumentation : Batteries.Tactic.Lint.Linter where
  noErrorsFound := "All axioms properly documented."
  errorsFound := "AXIOM DOCUMENTATION ISSUES:"
  test declName := do
    let name := declName.toString

    -- Check if this is an axiom declaration
    if name.hasSubstring "Axiom" && !declName.isInternal then
      -- Check for docstring
      match ← findDocString? (← getEnv) declName with
      | none =>
        return some m!"Axiom `{declName}` missing docstring"
      | some doc =>
        -- Check if docstring is substantial (>50 chars as heuristic)
        if doc.length < 50 then
          return some m!"Axiom `{declName}` has insufficient documentation (docstring too short)"

    return none
