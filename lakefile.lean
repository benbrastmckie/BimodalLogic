import Lake
open Lake DSL

package Logos

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.14.0"

require plausible from git
  "https://github.com/leanprover-community/plausible" @ "main"

-- Logos library with linters enabled
@[default_target]
lean_lib Logos where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩
  ]

-- Bimodal library - standalone TM logic implementation
lean_lib Bimodal where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩
  ]

lean_lib LogosTest

-- BimodalTest library - tests for Bimodal TM logic
lean_lib BimodalTest where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩
  ]

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
