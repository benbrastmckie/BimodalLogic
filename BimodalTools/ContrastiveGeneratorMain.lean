/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.ContrastiveGenerator

/-!
# Contrastive Pair Generator: the executable root

The root of `lake exe contrastive_generator`: argument parsing and `main`, and nothing else. The
mutation engine, `ContrastivePair` and the JSONL export all live in
`BimodalTools/ContrastiveGenerator.lean`, which this module imports.

The split exists because an executable root declares a root-namespace `main`, and two of those
cannot share one environment. With `main` isolated here, `BimodalTools.lean` and
`Tests/BimodalToolsTest/FormulaMutatorTest.lean` import the engine directly. This mirrors the
`DatasetGeneratorMain` / `DatasetGenerator` pair.
-/

open FormalSystem.Syntax
open FormalSystem.Automation
-- The former `FormalSystem.Automation` namespace is split across two libraries now: the
-- proof-automation half stayed, the dataset/benchmark half is here in `BimodalTools`.
open BimodalTools
open BimodalTools.ContrastiveGenerator

/--
Configuration for the contrastive pair generator.
-/
structure ContrastiveConfig where
  /-- Maximum formula complexity for enumeration. -/
  maxComplexity : Nat := 5
  /-- Maximum modal depth for enumeration. -/
  maxModalDepth : Nat := 2
  /-- Maximum temporal depth for enumeration. -/
  maxTemporalDepth : Nat := 2
  /-- Maximum number of formulas to process. -/
  maxFormulas : Nat := 1000
  /-- Number of parallel threads for labeling (0 = sequential). -/
  parallelThreads : Nat := 0
  /-- Output JSONL file path. -/
  outputPath : String := "data/contrastive_pairs.jsonl"
  deriving Repr, Inhabited

/--
Parse CLI arguments into a `ContrastiveConfig`.
-/
def parseContrastiveArgs (args : List String) : ContrastiveConfig :=
  go args default
where
  go : List String → ContrastiveConfig → ContrastiveConfig
  | "--max-complexity" :: n :: rest, cfg =>
    go rest { cfg with maxComplexity := n.toNat! }
  | "--max-modal-depth" :: n :: rest, cfg =>
    go rest { cfg with maxModalDepth := n.toNat! }
  | "--max-temporal-depth" :: n :: rest, cfg =>
    go rest { cfg with maxTemporalDepth := n.toNat! }
  | "--max-formulas" :: n :: rest, cfg =>
    go rest { cfg with maxFormulas := n.toNat! }
  | "--parallel" :: n :: rest, cfg =>
    go rest { cfg with parallelThreads := n.toNat! }
  | "--output" :: p :: rest, cfg =>
    go rest { cfg with outputPath := p }
  | _ :: rest, cfg => go rest cfg
  | [], cfg => cfg

/--
Main entry point for the contrastive pair generator executable.

1. Parses CLI arguments
2. Enumerates formulas using FormulaEnumerator
3. Labels each formula via the decision procedure
4. Generates contrastive pairs from labeled formulas
5. Exports results to JSONL
6. Prints summary statistics
-/
def main (args : List String) : IO Unit := do
  let cfg := parseContrastiveArgs args
  IO.println "=== Contrastive Pair Generator ==="
  IO.println
      s!"Config: maxComplexity={cfg.maxComplexity}, maxModalDepth={cfg.maxModalDepth}, \
          maxTemporalDepth={cfg.maxTemporalDepth}, maxFormulas={cfg.maxFormulas}"
  IO.println s!"Parallel threads: {cfg.parallelThreads}"
  IO.println s!"Output: {cfg.outputPath}"
  -- Step 1: Enumerate formulas
  IO.println "\n[Step 1] Enumerating formulas..."
  let params : EnumParams := {
    maxComplexity := cfg.maxComplexity
    maxModalDepth := cfg.maxModalDepth
    maxTemporalDepth := cfg.maxTemporalDepth
    maxFormulas := cfg.maxFormulas
    samplingMode := .exhaustive
  }
  let formulas ← generateFormulas params
  IO.println s!"  Generated {formulas.length} formulas"
  -- Step 2: Label formulas
  IO.println "\n[Step 2] Labeling formulas with decision procedure..."
  let labeled ← labelBatch formulas (parallelThreads := cfg.parallelThreads)
  let validCount := labeled.filter (·.label == .valid) |>.length
  let invalidCount := labeled.filter (·.label == .invalid) |>.length
  let timeoutCount := labeled.filter (·.label == .timeout) |>.length
  IO.println s!"  Valid: {validCount}, Invalid: {invalidCount}, Timeout: {timeoutCount}"
  -- Step 3: Generate contrastive pairs
  IO.println "\n[Step 3] Generating contrastive pairs..."
  let mut allPairsCount : Nat := 0
  let mut contrastivePairs : List ContrastivePair := []
  for lf in labeled do
    let pairs ← generateContrastivePairs lf
    allPairsCount := allPairsCount + pairs.length
    let filtered := filterContrastive pairs
    contrastivePairs := contrastivePairs ++ filtered
    if contrastivePairs.length % 100 == 0 && contrastivePairs.length > 0 then
      IO.println s!"  ... {contrastivePairs.length} contrastive pairs so far"
  -- Step 4: Export to JSONL
  IO.println s!"\n[Step 4] Exporting {contrastivePairs.length} contrastive pairs to JSONL..."
  writeContrastiveJSONL contrastivePairs cfg.outputPath
  -- Step 5: Print summary
  let stats := computeContrastiveStats allPairsCount contrastivePairs
  printContrastiveStats stats
  IO.println s!"\nOutput written to: {cfg.outputPath}"
