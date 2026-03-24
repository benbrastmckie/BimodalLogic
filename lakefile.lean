import Lake
open Lake DSL

package Logos

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.27.0-rc1"

require plausible from git
  "https://github.com/leanprover-community/plausible" @ "main"

abbrev theoryLeanOptions : Array LeanOption := #[
  ⟨`pp.unicode.fun, true⟩,
  ⟨`autoImplicit, false⟩
]

@[default_target]
lean_lib Bimodal where
  srcDir := "Theories"
  roots := #[`Bimodal]
  leanOptions := theoryLeanOptions

lean_lib BimodalTest where
  srcDir := "Tests"
  roots := #[`BimodalTest]
  leanOptions := theoryLeanOptions
