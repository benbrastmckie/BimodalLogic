/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.ForwardProofGenerator
import FormalSystem.Automation.DatasetGenerator
import FormalSystem.Automation.DataExport
import FormalSystem.Automation.InterestingnessMetrics

/-! # Proof-First Exporter

CLI executable that runs the forward-chaining proof generator and emits the
result as a JSONL file. Each line is a `LabeledFormula` record serialized via
the existing `LabeledFormula.toJson` from `DatasetGenerator.lean`.

## Usage

```bash
lake exe proof_first_generator -- --max-depth 2 --seed 1000 --atoms "p,q,r" --output data/proof_first.jsonl
```

-/

namespace FormalSystem.Automation

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Automation.DataExport
open FormalSystem.Automation.InterestingnessMetrics

/-- Convert a forward-generation result into a list of labeled formulas. -/
def exportToJsonl (cfg : ForwardConfig)
    (pool : List (Sigma fun φ => DerivationTree cfg.frameClass [] φ))
    : IO (List LabeledFormula) := do
  let mut records : List LabeledFormula := []
  for σ in pool do
    let ⟨φ, d⟩ := σ
    let trace := extractProofTrace d
    let rp := walkDerivationTree d
    let metrics := computeMetrics φ 0
    let patternKey := PatternKey.fromFormula φ
    let intResult := computeInterestingness φ (some trace.toProofData) (some rp)
    records := {
      formula := φ
      label := .valid
      proofTrace := some trace
      countermodel := none
      metrics := metrics
      patternKey := patternKey
      ruleProfile := some rp
      decisionMethod := "proof_first"
      countermodelConsistent := none
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := some "proof_first_compositional"
      interestingnessScore := some intResult.compositeScore
      interestingnessTier := some intResult.tier.toString
    } :: records
  return records.reverse

/-- Write a list of `LabeledFormula` records to a JSONL file. -/
def writeJsonl (records : List LabeledFormula) (path : System.FilePath) : IO Unit := do
  let h ← IO.FS.Handle.mk path .write
  for lf in records do
    h.putStrLn lf.toJson
  h.flush

/-- Parse a comma-separated atom string into a list of `Atom`. -/
def parseAtoms (s : String) : List Atom :=
  s.splitOn "," |>.map Atom.mkBase

/-- Parse CLI arguments into a `ForwardConfig`. -/
def parseForwardConfig (args : List String) : IO ForwardConfig := do
  let mut cfg : ForwardConfig := { atoms := [] }
  let mut i := 0
  while i < args.length do
    match args[i]? with
    | some "--max-depth" =>
      i := i + 1
      match args[i]? with
      | some v => cfg := { cfg with maxDepth := v.toNat! }
      | none => pure ()
    | some "--seed" =>
      i := i + 1
      match args[i]? with
      | some v => cfg := { cfg with seedCount := v.toNat! }
      | none => pure ()
    | some "--atoms" =>
      i := i + 1
      match args[i]? with
      | some v => cfg := { cfg with atoms := parseAtoms v }
      | none => pure ()
    | some "--output" =>
      i := i + 1
      -- output path handled by caller
      pure ()
    | some "--frame-class" =>
      i := i + 1
      match args[i]? with
      | some "dense" => cfg := { cfg with frameClass := .Dense }
      | some "discrete" => cfg := { cfg with frameClass := .Discrete }
      | _ => cfg := { cfg with frameClass := .Base }
    | some "--max-pool-size" =>
      i := i + 1
      match args[i]? with
      | some v => cfg := { cfg with maxPoolSize := v.toNat! }
      | none => pure ()
    | some "--layer-uniform" =>
      cfg := { cfg with layerUniform := true }
    | some "--no-layer-uniform" =>
      cfg := { cfg with layerUniform := false }
    | _ => pure ()
    i := i + 1
  return cfg

/-- Extract output path from CLI arguments. -/
def parseOutputPath (args : List String) : IO System.FilePath := do
  let mut path := System.FilePath.mk "data/proof_first.jsonl"
  let mut i := 0
  while i < args.length do
    match args[i]? with
    | some "--output" =>
      i := i + 1
      match args[i]? with
      | some v => path := System.FilePath.mk v
      | none => pure ()
    | _ => pure ()
    i := i + 1
  return path

end FormalSystem.Automation

/-- Main entry point for the proof-first generator CLI. -/
def main (args : List String) : IO Unit := do
  let cfg ← FormalSystem.Automation.parseForwardConfig args
  let outputPath ← FormalSystem.Automation.parseOutputPath args
  IO.println s!"[proof-first] Starting generation with config: {repr cfg}"
  IO.println s!"[proof-first] Generating proof pool..."
  let pool ← FormalSystem.Automation.forwardGenerate cfg
  IO.println s!"[proof-first] Pool size: {pool.length}"
  let records ← FormalSystem.Automation.exportToJsonl cfg pool
  IO.println s!"[proof-first] Exporting {records.length} records to {outputPath}"
  FormalSystem.Automation.writeJsonl records outputPath
  IO.println s!"[proof-first] Done."
