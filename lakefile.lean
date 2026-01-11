import Lake
open Lake DSL

package Logos

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.14.0"

require plausible from git
  "https://github.com/leanprover-community/plausible" @ "main"

-- Common Lean options for all theory libraries
abbrev theoryLeanOptions : Array LeanOption := #[
  ⟨`pp.unicode.fun, true⟩,
  ⟨`autoImplicit, false⟩
]

-- Logos library with linters enabled
@[default_target]
lean_lib Logos where
  srcDir := "Theories"
  roots := #[`Logos]
  leanOptions := theoryLeanOptions

-- Bimodal library - standalone TM logic implementation
lean_lib Bimodal where
  srcDir := "Theories"
  roots := #[`Bimodal]
  leanOptions := theoryLeanOptions

lean_lib LogosTest

-- BimodalTest library - tests for Bimodal TM logic
lean_lib BimodalTest where
  leanOptions := theoryLeanOptions

lean_exe test where
  root := `LogosTest.Main

-- Custom lint driver executable
@[lint_driver]
lean_exe lintAll where
  srcDir := "scripts"
  root := `LintAll
  supportInterpreter := true

-- Environment linter executable
lean_exe runEnvLinters where
  srcDir := "scripts"
  root := `RunEnvLinters
  supportInterpreter := true

-- Text-based style linter executable
lean_exe lintStyle where
  srcDir := "scripts"
  root := `LintStyle
  supportInterpreter := true
