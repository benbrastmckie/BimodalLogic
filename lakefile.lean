import Lake
open Lake DSL

package Logos where
  testDriver := "BimodalTest"

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

/-- Archived dead code. Not built by default.
    Build with: lake build BoneyardArchive -/
lean_lib BoneyardArchive where
  srcDir := "Theories"
  globs := #[.submodules `Bimodal.Boneyard]
  leanOptions := theoryLeanOptions

lean_lib BimodalTest where
  srcDir := "Tests"
  roots := #[`BimodalTest]
  leanOptions := theoryLeanOptions

/-- Dataset generator executable for ML training data.
    Run with: lake exe dataset_generator -- --max-complexity 5 --output data/bmlogic.jsonl -/
lean_exe dataset_generator where
  root := `Bimodal.Automation.DatasetExport
  srcDir := "Theories"
  supportInterpreter := true
