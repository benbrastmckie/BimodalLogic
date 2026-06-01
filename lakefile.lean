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

/-- Dataset validator executable for conformance testing and feasibility gate.
    Run with: lake exe dataset_validator -/
lean_exe dataset_validator where
  root := `Bimodal.Automation.DatasetValidator
  srcDir := "Theories"
  supportInterpreter := true

/-- Proof step extractor for BimodalHarness training data.
    Run with: lake exe proof_extractor -- --output data/proof_steps.jsonl -/
lean_exe proof_extractor where
  root := `Bimodal.Automation.ProofStepExport
  srcDir := "Theories"
  supportInterpreter := true

/-- Enumerator benchmark: validates complexity 5-7 feasibility gates (Task 210).
    Run with: lake exe enum_benchmark -/
lean_exe enum_benchmark where
  root := `Bimodal.Automation.EnumBenchmark
  srcDir := "Theories"
  supportInterpreter := true

/-- Benchmark anchor generator: produces axiom instances for BMLogic-Bench (Task 205).
    Run with: lake exe benchmark_anchors -- --output data/axiom-instances.jsonl -/
lean_exe benchmark_anchors where
  root := `Bimodal.Automation.BenchmarkAnchors
  srcDir := "Theories"
  supportInterpreter := true

/-- Benchmark oracle: validates formula labels via decision procedure (Task 205).
    Run with: lake exe benchmark_oracle -- --input data/bmlogic-bench-candidates.jsonl --output data/bmlogic-bench-validated.jsonl -/
lean_exe benchmark_oracle where
  root := `Bimodal.Automation.BenchmarkOracle
  srcDir := "Theories"
  supportInterpreter := true

/-- Contrastive pair generator for dual-verification training signal (Task 206).
    Run with: lake exe contrastive_generator -- --max-complexity 5 --output data/contrastive_pairs.jsonl -/
lean_exe contrastive_generator where
  root := `Bimodal.Automation.FormulaMutator
  srcDir := "Theories"
  supportInterpreter := true

/-- Tableau bridge REPL for live formula queries (Task 246).
    Run with: lake exe tableau_bridge
    Then send JSONL requests on stdin, one per line. -/
lean_exe tableau_bridge where
  root := `Bimodal.Automation.TableauBridge
  srcDir := "Theories"
  supportInterpreter := true
