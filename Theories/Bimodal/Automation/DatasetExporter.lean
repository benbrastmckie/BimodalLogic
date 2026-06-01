import Bimodal.Automation.DatasetGenerator
import Bimodal.Automation.EnrichedCountermodel
import Bimodal.Automation.FormulaEnumerator
import Bimodal.Automation.DataExport

/-!
# Dataset Exporter: Structured JSON Dataset Assembly

This module assembles labeled formulas into a structured JSON dataset file
with metadata, statistics, and deterministic train/eval split. It provides
the end-to-end pipeline from `EnumConfig` to a complete dataset JSON file.

## Main Definitions

- `DatasetMetadata`: Metadata structure for the dataset (generator, version, config, stats)
- `DatasetMetadata.toJson`: Serialize metadata to JSON
- `EnumConfig.toJson`: Serialize enumeration configuration to JSON
- `BatchStats.toJson`: Serialize batch statistics to JSON
- `exportDatasetJson`: Produce complete dataset JSON string from metadata and labeled formulas
- `writeDataset`: Write string content to a file
- `splitDataset`: Deterministic stratified split into train/eval sets
- `generateAndExportDataset`: End-to-end pipeline: enumerate, label, export
- `generateSplitDatasets`: Generate, split, and export both train and eval datasets

## JSON Schema

The output JSON has this structure:
```json
{
  "metadata": {
    "generator": "BimodalLogic/DatasetExporter",
    "version": "1.0",
    "config": { "maxModalDepth": 3, ... },
    "statistics": { "totalCount": 1234, ... },
    "frameClass": "Base"
  },
  "formulas": [
    { "id": 0, "formula": {...}, "formula_string": "...", ... },
    ...
  ]
}
```

## References

- Phase 5 of Task 201 implementation plan
- `DatasetGenerator.lean`: `LabeledFormula`, `labelBatch`, `computeBatchStats`, `BatchStats`
- `FormulaEnumerator.lean`: `EnumConfig`, `enumerateUpToDepth`
- `DataExport.lean`: JSON serialization primitives
- `EnrichedCountermodel.lean`: Enriched countermodel extraction
-/

set_option autoImplicit false

namespace Bimodal.Automation.DatasetExporter

open Bimodal.Syntax
open Bimodal.Automation
open Bimodal.Automation.DataExport

/-!
## JSON Serialization for EnumConfig and BatchStats
-/

/--
Serialize an `EnumConfig` to a JSON object string.

Example output:
```json
{"maxModalDepth": 3, "maxTemporalDepth": 3, "maxSize": 12, "atomCount": 5}
```
-/
def EnumConfig.toJson (config : EnumConfig) : String :=
  "{\"maxModalDepth\": " ++ toString config.maxModalDepth
  ++ ", \"maxTemporalDepth\": " ++ toString config.maxTemporalDepth
  ++ ", \"maxSize\": " ++ toString config.maxSize
  ++ ", \"atomCount\": " ++ toString config.atomPool.length
  ++ "}"

/--
Serialize a `BatchStats` to a JSON object string.

Example output:
```json
{"totalCount": 100, "validCount": 45, "invalidCount": 50, "timeoutCount": 5, "avgTimeMs": 12}
```
-/
def BatchStats.toJson (stats : BatchStats) : String :=
  "{\"totalCount\": " ++ toString stats.totalCount
  ++ ", \"validCount\": " ++ toString stats.validCount
  ++ ", \"invalidCount\": " ++ toString stats.invalidCount
  ++ ", \"timeoutCount\": " ++ toString stats.timeoutCount
  ++ ", \"avgTimeMs\": " ++ toString stats.avgTimeMs
  ++ "}"

/-!
## Dataset Metadata
-/

/--
Metadata for a generated dataset, including generator identity,
configuration used, and batch statistics.
-/
structure DatasetMetadata where
  /-- Name of the generator module. -/
  generator : String := "BimodalLogic/DatasetExporter"
  /-- Dataset format version. -/
  version : String := "1.0"
  /-- Enumeration configuration used to generate formulas. -/
  config : EnumConfig
  /-- Batch statistics computed from labeled formulas. -/
  stats : BatchStats
  /-- Frame class used for decision procedure. -/
  frameClass : String := "Base"
  deriving Repr

/--
Serialize `DatasetMetadata` to a JSON object string.
-/
def DatasetMetadata.toJson (m : DatasetMetadata) : String :=
  "{\"generator\": \"" ++ escapeJsonString m.generator ++ "\""
  ++ ", \"version\": \"" ++ escapeJsonString m.version ++ "\""
  ++ ", \"config\": " ++ EnumConfig.toJson m.config
  ++ ", \"statistics\": " ++ BatchStats.toJson m.stats
  ++ ", \"frameClass\": \"" ++ escapeJsonString m.frameClass ++ "\""
  ++ "}"

/-!
## Dataset JSON Assembly
-/

/-- Zip a list with sequential indices starting at 0. -/
private def zipWithIndex {α : Type} (xs : List α) : List (Nat × α) :=
  go xs 0 []
where
  go : List α → Nat → List (Nat × α) → List (Nat × α)
  | [], _, acc => acc.reverse
  | x :: rest, idx, acc => go rest (idx + 1) ((idx, x) :: acc)

/--
Add an `"id"` field to a `LabeledFormula.toJson` output string.

Given the JSON string `{"formula": ..., ...}` and an index `n`,
produces `{"id": n, "formula": ..., ...}`.
-/
private def addIdField (idx : Nat) (jsonStr : String) : String :=
  -- LabeledFormula.toJson starts with '{'
  -- We insert "id": N, right after the opening brace
  let rest := jsonStr.drop 1  -- drop the leading '{'
  "{\"id\": " ++ toString idx ++ ", " ++ rest

/--
Produce the complete dataset JSON string from metadata and labeled formulas.

The output has the structure:
```json
{
  "metadata": { ... },
  "formulas": [
    { "id": 0, ... },
    { "id": 1, ... },
    ...
  ]
}
```

Each formula entry is the output of `LabeledFormula.toJson` augmented
with a sequential `"id"` field.
-/
def exportDatasetJson (metadata : DatasetMetadata) (labeled : List LabeledFormula) : String :=
  let metadataStr := metadata.toJson
  let formulaEntries := zipWithIndex labeled |>.map fun (idx, lf) =>
    addIdField idx lf.toJson
  let formulasStr := listToJsonArray formulaEntries
  "{\"metadata\": " ++ metadataStr
  ++ ", \"formulas\": " ++ formulasStr
  ++ "}"

/-!
## File I/O
-/

/--
Write a string to a file at the given path.

Uses `IO.FS.writeFile` to atomically write the content.
-/
def writeDataset (path : String) (content : String) : IO Unit :=
  IO.FS.writeFile ⟨path⟩ content

/-!
## Dataset Splitting
-/

/--
Deterministic stratified split of labeled formulas into train and eval sets.

Stratifies by label (valid/invalid/timeout) to approximately preserve the
label distribution in both sets. Within each stratum, the first
`floor(count * trainRatio)` formulas go to train and the rest to eval.

Returns `(train, eval)`.
-/
def splitDataset (labeled : List LabeledFormula) (trainRatio : Float := 0.8)
    : (List LabeledFormula × List LabeledFormula) :=
  -- Partition by label
  let valid := labeled.filter (fun lf => lf.label == .valid)
  let invalid := labeled.filter (fun lf => lf.label == .invalid)
  let timeout := labeled.filter (fun lf => lf.label == .timeout)
  -- Split each stratum
  let (validTrain, validEval) := splitStratum valid trainRatio
  let (invalidTrain, invalidEval) := splitStratum invalid trainRatio
  let (timeoutTrain, timeoutEval) := splitStratum timeout trainRatio
  -- Combine
  (validTrain ++ invalidTrain ++ timeoutTrain,
   validEval ++ invalidEval ++ timeoutEval)
where
  /-- Split a single stratum at the given ratio. -/
  splitStratum (items : List LabeledFormula) (ratio : Float)
      : (List LabeledFormula × List LabeledFormula) :=
    let n := items.length
    let trainCount := (ratio * n.toFloat).toUInt64.toNat
    (items.take trainCount, items.drop trainCount)

/-!
## End-to-End Pipelines
-/

/--
End-to-end pipeline: enumerate formulas, label them, compute stats,
build metadata, export JSON, write to file, and print summary.

1. Enumerates formulas using `enumerateUpToDepth config`
2. Labels all formulas via `labelBatch`
3. Computes batch statistics
4. Builds dataset metadata
5. Exports complete JSON
6. Writes to the output file
7. Prints summary to stdout
-/
noncomputable def generateAndExportDataset (config : EnumConfig) (outputPath : String) : IO Unit := do
  -- Step 1: Enumerate
  IO.println "Enumerating formulas..."
  let formulas := enumerateUpToDepth config
  IO.println s!"  Generated {formulas.length} unique formulas"

  -- Step 2: Label
  IO.println s!"Labeling {formulas.length} formulas..."
  let labeled ← labelBatch formulas

  -- Step 3: Compute stats
  let stats := computeBatchStats labeled
  IO.println ""
  IO.println (stats.display)

  -- Step 4: Build metadata
  let metadata : DatasetMetadata := {
    config := config
    stats := stats
  }

  -- Step 5: Export JSON
  IO.println ""
  IO.println "Assembling dataset JSON..."
  let jsonContent := exportDatasetJson metadata labeled

  -- Step 6: Write file
  IO.println s!"Writing to {outputPath}..."
  writeDataset outputPath jsonContent
  IO.println s!"  Wrote {labeled.length} formula records"

  -- Step 7: Summary
  IO.println ""
  IO.println "Dataset generation complete."
  let validRate := if stats.totalCount > 0
    then stats.validCount * 100 / stats.totalCount else 0
  let timeoutRate := if stats.totalCount > 0
    then stats.timeoutCount * 100 / stats.totalCount else 0
  IO.println s!"  Valid: {stats.validCount} ({validRate}%)"
  IO.println s!"  Invalid: {stats.invalidCount}"
  IO.println s!"  Timeout: {stats.timeoutCount} ({timeoutRate}%)"

/--
Generate, split into train/eval sets, and export both datasets.

1. Enumerates and labels formulas
2. Performs stratified train/eval split at the given ratio
3. Exports both datasets with appropriate metadata
4. Prints summary statistics for both splits
-/
noncomputable def generateSplitDatasets (config : EnumConfig) (trainPath evalPath : String)
    (trainRatio : Float := 0.8) : IO Unit := do
  -- Step 1: Enumerate
  IO.println "Enumerating formulas..."
  let formulas := enumerateUpToDepth config
  IO.println s!"  Generated {formulas.length} unique formulas"

  -- Step 2: Label
  IO.println s!"Labeling {formulas.length} formulas..."
  let labeled ← labelBatch formulas

  -- Step 3: Split
  let (train, eval) := splitDataset labeled trainRatio
  IO.println s!"  Train set: {train.length} formulas"
  IO.println s!"  Eval set: {eval.length} formulas"

  -- Step 4: Compute stats for each split
  let trainStats := computeBatchStats train
  let evalStats := computeBatchStats eval

  -- Step 5: Build metadata for each split
  let trainMetadata : DatasetMetadata := {
    config := config
    stats := trainStats
  }
  let evalMetadata : DatasetMetadata := {
    config := config
    stats := evalStats
  }

  -- Step 6: Export and write
  IO.println ""
  IO.println "Assembling and writing datasets..."
  let trainJson := exportDatasetJson trainMetadata train
  writeDataset trainPath trainJson
  IO.println s!"  Train: wrote {train.length} records to {trainPath}"

  let evalJson := exportDatasetJson evalMetadata eval
  writeDataset evalPath evalJson
  IO.println s!"  Eval: wrote {eval.length} records to {evalPath}"

  -- Step 7: Summary
  IO.println ""
  IO.println "Train set statistics:"
  IO.println (trainStats.display)
  IO.println ""
  IO.println "Eval set statistics:"
  IO.println (evalStats.display)
  IO.println ""
  IO.println "Dataset generation complete."

end Bimodal.Automation.DatasetExporter
