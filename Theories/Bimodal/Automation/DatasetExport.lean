import Bimodal.Automation.DatasetGenerator
import Bimodal.Automation.DataExport

/-!
# Dataset Export: JSONL Streaming, CLI, and Lake Executable

This module provides the complete dataset export pipeline: it converts labeled
formulas into JSONL (one JSON object per line) records, writes them to files,
computes dataset metadata, and provides a CLI `main` function for the compiled
Lake executable.

## Main Definitions

- `DatasetRecord`: Export-ready record structure with all fields for JSONL output
- `AugmentationInfo`: Tracks whether a record was produced via temporal duality
- `DatasetMetadata`: Dataset-level statistics (counts, distributions, parameters)
- `writeRecordJSONL`: Write a single record as one JSON line
- `writeDatasetJSONL`: Stream all records to a JSONL file
- `main`: CLI entry point for `lake exe dataset_generator`

## JSON Format

Each JSONL line contains:
```json
{
  "id": "bmlogic-00001",
  "split": "train",
  "formula_str": "(□p → p)",
  "formula_ast": {"tag": "imp", "left": {"tag": "box", ...}, "right": ...},
  "frame_class": "Base",
  "label": "valid",
  "proof_trace": {"height": 0, "axioms_used": ["modal_t"], "rules_applied": []},
  "countermodel": null,
  "pattern_key": {"modalDepth": 1, ...},
  "metrics": {"complexity": 3, ...},
  "augmentation": null
}
```

## CLI Usage

```
lake exe dataset_generator -- [OPTIONS]
  --max-complexity N      Maximum formula complexity (default: 5)
  --max-modal-depth N     Maximum modal nesting (default: 2)
  --max-temporal-depth N  Maximum temporal nesting (default: 2)
  --max-formulas N        Maximum formulas to generate (default: 5000)
  --valid-seed-count N    Number of axiom-seeded valid formulas (default: 500)
  --output PATH           Output JSONL file path (default: data/bmlogic.jsonl)
  --mode MODE             Sampling: exhaustive|random|hybrid (default: exhaustive)
  --include-duals         Include temporal dual augmentation
```

## Downstream Usage (Python)

```python
import json
with open("data/bmlogic.jsonl") as f:
    records = [json.loads(line) for line in f]
valid = [r for r in records if r["label"] == "valid"]
```

## References

- DataExport.lean: existing JSON serialization primitives (toJson for Formula, Atom, etc.)
- Team research report: specs/203_formula_enumerator_dataset_export/reports/01_team-research.md
-/

set_option autoImplicit false

namespace Bimodal.Automation.DatasetExport

open Bimodal.Syntax
open Bimodal.Automation
open Bimodal.Automation.DataExport
open Bimodal.Metalogic.Decidability

/-!
## Additional JSON Serialization

Build on existing `DataExport.lean` primitives (Formula.toJson, Formula.prettyPrint,
PatternKey.toJson, GoalCategory.toJson, SimpleCountermodel.toJson) with serialization
for the new types introduced in DatasetGenerator.
-/

/--
Serialize a `ProofTrace` to a JSON object string.

Example:
```json
{"height": 2, "axioms_used": ["modal_t", "prop_k"], "rules_applied": ["modus_ponens"]}
```
-/
def proofTraceToJson (pt : ProofTrace) : String :=
  let axiomsArr := listToJsonArray (pt.axioms_used.map fun s =>
    "\"" ++ escapeJsonString s ++ "\"")
  let rulesArr := listToJsonArray (pt.rules_applied.map fun s =>
    "\"" ++ escapeJsonString s ++ "\"")
  "{\"height\": " ++ toString pt.height
  ++ ", \"axioms_used\": " ++ axiomsArr
  ++ ", \"rules_applied\": " ++ rulesArr
  ++ "}"

/--
Serialize a `DifficultyMetrics` to a JSON object string.
-/
def difficultyMetricsToJson (dm : DifficultyMetrics) : String :=
  "{\"complexity\": " ++ toString dm.complexity
  ++ ", \"modalDepth\": " ++ toString dm.modalDepth
  ++ ", \"temporalDepth\": " ++ toString dm.temporalDepth
  ++ ", \"impCount\": " ++ toString dm.impCount
  ++ ", \"atomCount\": " ++ toString dm.atomCount
  ++ ", \"decisionTimeMs\": " ++ toString dm.decisionTimeMs
  ++ ", \"difficultyTier\": \"" ++ escapeJsonString dm.difficultyTier ++ "\""
  ++ "}"

/--
Serialize a `FormulaLabel` to a JSON string value.
-/
def formulaLabelToJson (fl : FormulaLabel) : String :=
  match fl with
  | .valid => "\"valid\""
  | .invalid => "\"invalid\""
  | .timeout => "\"timeout\""

/-!
## Augmentation Info
-/

/--
Information about how a record was produced (original or augmented).
-/
structure AugmentationInfo where
  /-- Source of the record. -/
  source : String
  /-- Original formula string if this is a dual. -/
  originalFormulaStr : Option String
  deriving Repr, Inhabited

/--
Serialize `AugmentationInfo` to JSON.
-/
def augmentationInfoToJson (ai : AugmentationInfo) : String :=
  let origStr := match ai.originalFormulaStr with
    | none => "null"
    | some s => "\"" ++ escapeJsonString s ++ "\""
  "{\"source\": \"" ++ escapeJsonString ai.source
  ++ "\", \"original_formula_str\": " ++ origStr ++ "}"

/-!
## Dataset Record
-/

/--
A complete dataset record ready for JSONL export.
Mirrors the JSON schema from the research report.
-/
structure DatasetRecord where
  /-- Unique identifier (e.g., "bmlogic-00001"). -/
  id : String
  /-- Dataset split: "train", "val", or "test". -/
  split : String := "train"
  /-- Human-readable formula string. -/
  formula_str : String
  /-- JSON AST representation. -/
  formula_ast : String
  /-- Frame class used for decision. -/
  frame_class : String := "Base"
  /-- Classification label. -/
  label : FormulaLabel
  /-- Proof trace (valid formulas only). -/
  proof_trace : Option ProofTrace
  /-- Countermodel (invalid formulas only). -/
  countermodel : Option SimpleCountermodel
  /-- Pattern key for structural indexing. -/
  pattern_key : PatternKey
  /-- Difficulty metrics. -/
  metrics : DifficultyMetrics
  /-- Augmentation info (None for original formulas). -/
  augmentation : Option AugmentationInfo
  /-- S-expression representation of the formula. -/
  formula_sexpr : String
  /-- Prefix-notation token list as a pre-serialized JSON array. -/
  formula_tokens : String
  /-- Numeric feature vector from PatternKey as a pre-serialized JSON array. -/
  pattern_features : String
  deriving Repr

instance : Inhabited DatasetRecord :=
  ⟨{ id := ""
     split := "train"
     formula_str := ""
     formula_ast := ""
     frame_class := "Base"
     label := .timeout
     proof_trace := none
     countermodel := none
     pattern_key := default
     metrics := default
     augmentation := none
     formula_sexpr := ""
     formula_tokens := "[]"
     pattern_features := "[]" }⟩

/--
Serialize a `DatasetRecord` to a JSON object string (one line).
-/
def datasetRecordToJson (r : DatasetRecord) : String :=
  let traceStr := match r.proof_trace with
    | none => "null"
    | some pt => proofTraceToJson pt
  let cmStr := match r.countermodel with
    | none => "null"
    | some cm => cm.toJson
  let augStr := match r.augmentation with
    | none => "null"
    | some ai => augmentationInfoToJson ai
  "{\"id\": \"" ++ escapeJsonString r.id ++ "\""
  ++ ", \"split\": \"" ++ escapeJsonString r.split ++ "\""
  ++ ", \"formula_str\": \"" ++ escapeJsonString r.formula_str ++ "\""
  ++ ", \"formula_ast\": " ++ r.formula_ast
  ++ ", \"frame_class\": \"" ++ escapeJsonString r.frame_class ++ "\""
  ++ ", \"label\": " ++ formulaLabelToJson r.label
  ++ ", \"proof_trace\": " ++ traceStr
  ++ ", \"countermodel\": " ++ cmStr
  ++ ", \"pattern_key\": " ++ r.pattern_key.toJson
  ++ ", \"metrics\": " ++ difficultyMetricsToJson r.metrics
  ++ ", \"augmentation\": " ++ augStr
  ++ ", \"formula_sexpr\": \"" ++ escapeJsonString r.formula_sexpr ++ "\""
  ++ ", \"formula_tokens\": " ++ r.formula_tokens
  ++ ", \"pattern_features\": " ++ r.pattern_features
  ++ "}"

/--
Convert a `LabeledFormula` to a `DatasetRecord` with the given ID and split.
-/
def labeledToRecord (idx : Nat) (splitName : String) (lf : LabeledFormula)
    : DatasetRecord :=
  let idStr := "bmlogic-" ++ String.ofList (padNat idx 5)
  { id := idStr
    split := splitName
    formula_str := lf.formula.prettyPrint
    formula_ast := lf.formula.toJson
    frame_class := "Base"
    label := lf.label
    proof_trace := lf.proofTrace
    countermodel := lf.countermodel
    pattern_key := lf.patternKey
    metrics := lf.metrics
    augmentation := none
    formula_sexpr := lf.formula.toSExpr
    formula_tokens := tokenListToJson lf.formula.tokenize
    pattern_features := lf.patternKey.featureVectorToJson }
where
  /-- Zero-pad a natural number to at least `width` digits. -/
  padNat (n : Nat) (width : Nat) : List Char :=
    let s := toString n
    let padLen := if s.length < width then width - s.length else 0
    (List.replicate padLen '0') ++ s.toList

/--
Assign a deterministic split based on formula string hash.
- train: 80%
- val: 10%
- test: 10%
-/
def assignSplit (formulaStr : String) : String :=
  let h := hash formulaStr
  let bucket := h % 100
  if bucket < 80 then "train"
  else if bucket < 90 then "val"
  else "test"

/-!
## JSONL File Writing
-/

/--
Write a single dataset record as one JSON line to a file handle.
-/
def writeRecordJSONL (handle : IO.FS.Handle) (record : DatasetRecord) : IO Unit :=
  handle.putStrLn (datasetRecordToJson record)

/--
Stream all labeled formulas to a JSONL file with deterministic split assignment.
-/
def writeDatasetJSONL (outputPath : System.FilePath) (labeled : List LabeledFormula)
    : IO Nat := do
  let handle ← IO.FS.Handle.mk outputPath .write
  let mut count : Nat := 0
  for lf in labeled do
    let splitName := assignSplit lf.formula.prettyPrint
    let record := labeledToRecord (count + 1) splitName lf
    writeRecordJSONL handle record
    count := count + 1
  return count

/-!
## Dataset Metadata
-/

/--
Dataset-level metadata for the companion `_metadata.json` file.
-/
structure DatasetMetadata where
  /-- Total records in the dataset. -/
  totalRecords : Nat
  /-- Number of valid formulas. -/
  validCount : Nat
  /-- Number of invalid formulas. -/
  invalidCount : Nat
  /-- Number of timeouts. -/
  timeoutCount : Nat
  /-- Average formula complexity. -/
  avgComplexity : Nat
  /-- Whether temporal duals were included. -/
  includeDuals : Bool
  /-- Maximum complexity used. -/
  maxComplexity : Nat
  /-- Sampling mode used. -/
  samplingMode : String
  deriving Repr, Inhabited

/--
Compute dataset metadata from a list of labeled formulas and parameters.
-/
def computeDatasetMetadata (labeled : List LabeledFormula) (params : EnumParams)
    (includeDuals : Bool) : DatasetMetadata :=
  let stats := computeBatchStats labeled
  let totalComplexity := labeled.foldl (fun acc lf => acc + lf.metrics.complexity) 0
  let avgC := if labeled.length > 0 then totalComplexity / labeled.length else 0
  let modeStr := match params.samplingMode with
    | .exhaustive => "exhaustive"
    | .random => "random"
    | .hybrid => "hybrid"
  { totalRecords := stats.totalCount
    validCount := stats.validCount
    invalidCount := stats.invalidCount
    timeoutCount := stats.timeoutCount
    avgComplexity := avgC
    includeDuals := includeDuals
    maxComplexity := params.maxComplexity
    samplingMode := modeStr }

/--
Serialize dataset metadata to a JSON string.
-/
def datasetMetadataToJson (m : DatasetMetadata) : String :=
  let dualStr := if m.includeDuals then "true" else "false"
  "{\n"
  ++ "  \"total_records\": " ++ toString m.totalRecords ++ ",\n"
  ++ "  \"valid_count\": " ++ toString m.validCount ++ ",\n"
  ++ "  \"invalid_count\": " ++ toString m.invalidCount ++ ",\n"
  ++ "  \"timeout_count\": " ++ toString m.timeoutCount ++ ",\n"
  ++ "  \"avg_complexity\": " ++ toString m.avgComplexity ++ ",\n"
  ++ "  \"include_duals\": " ++ dualStr ++ ",\n"
  ++ "  \"max_complexity\": " ++ toString m.maxComplexity ++ ",\n"
  ++ "  \"sampling_mode\": \"" ++ m.samplingMode ++ "\",\n"
  ++ "  \"frame_class\": \"Base\",\n"
  ++ "  \"representations\": [\n"
  ++ "    {\"field\": \"formula_str\", \"format\": \"human-readable\", \"description\": \"Pretty-printed unicode notation\"},\n"
  ++ "    {\"field\": \"formula_ast\", \"format\": \"json-ast\", \"description\": \"Recursive JSON AST with tag discriminator\"},\n"
  ++ "    {\"field\": \"formula_sexpr\", \"format\": \"s-expression\", \"description\": \"Canonical parenthesized prefix notation\"},\n"
  ++ "    {\"field\": \"formula_tokens\", \"format\": \"token-list\", \"description\": \"Prefix-notation token list for transformers\"},\n"
  ++ "    {\"field\": \"pattern_key\", \"format\": \"json-object\", \"description\": \"Structural pattern key with named fields\"},\n"
  ++ "    {\"field\": \"pattern_features\", \"format\": \"numeric-vector\", \"description\": \"Flat numeric feature vector for value estimators\"}\n"
  ++ "  ]\n"
  ++ "}"

/--
Write dataset metadata to a companion JSON file.
The metadata file path is derived by replacing `.jsonl` with `_metadata.json`.
-/
def writeMetadata (outputPath : System.FilePath) (metadata : DatasetMetadata) : IO Unit := do
  let metaPath := outputPath.toString.replace ".jsonl" "_metadata.json"
  IO.FS.writeFile ⟨metaPath⟩ (datasetMetadataToJson metadata)

/-!
## CLI Argument Parsing
-/

/--
Parsed CLI arguments for the dataset generator.
-/
structure CLIArgs where
  maxComplexity : Nat := 5
  maxModalDepth : Nat := 2
  maxTemporalDepth : Nat := 2
  maxFormulas : Nat := 5000
  output : String := "data/bmlogic.jsonl"
  mode : SamplingMode := .exhaustive
  includeDuals : Bool := false
  validSeedCount : Nat := 500
  deriving Repr, Inhabited

/--
Parse CLI arguments from a list of strings.
Supports: `--max-complexity`, `--max-modal-depth`, `--max-temporal-depth`,
`--max-formulas`, `--output`, `--mode`, `--include-duals`.
-/
def parseCLIArgs (args : List String) : CLIArgs :=
  go args {}
where
  go : List String → CLIArgs → CLIArgs
  | [], acc => acc
  | "--max-complexity" :: n :: rest, acc =>
    go rest { acc with maxComplexity := n.toNat! }
  | "--max-modal-depth" :: n :: rest, acc =>
    go rest { acc with maxModalDepth := n.toNat! }
  | "--max-temporal-depth" :: n :: rest, acc =>
    go rest { acc with maxTemporalDepth := n.toNat! }
  | "--max-formulas" :: n :: rest, acc =>
    go rest { acc with maxFormulas := n.toNat! }
  | "--output" :: p :: rest, acc =>
    go rest { acc with output := p }
  | "--mode" :: m :: rest, acc =>
    let mode := match m with
      | "random" => SamplingMode.random
      | "hybrid" => SamplingMode.hybrid
      | _ => SamplingMode.exhaustive
    go rest { acc with mode := mode }
  | "--include-duals" :: rest, acc =>
    go rest { acc with includeDuals := true }
  | "--valid-seed-count" :: n :: rest, acc =>
    go rest { acc with validSeedCount := n.toNat! }
  | _ :: rest, acc => go rest acc

end Bimodal.Automation.DatasetExport

/-!
## Main Entry Point

The `main` function is the CLI entry point for `lake exe dataset_generator`.
-/

open Bimodal.Automation
open Bimodal.Automation.DatasetExport

/--
Main entry point for the dataset generator executable.

Pipeline:
1. Parse CLI arguments
2. Construct EnumParams
3. Enumerate/sample formulas
4. Optionally enrich with temporal duals
5. Label all formulas via decision procedure
6. Write JSONL dataset file
7. Write metadata file
8. Print summary statistics
-/
def main (args : List String) : IO Unit := do
  let cliArgs := parseCLIArgs args
  IO.println s!"BMLogic Dataset Generator"
  IO.println s!"========================"
  IO.println s!"Max complexity: {cliArgs.maxComplexity}"
  IO.println s!"Max modal depth: {cliArgs.maxModalDepth}"
  IO.println s!"Max temporal depth: {cliArgs.maxTemporalDepth}"
  IO.println s!"Max formulas: {cliArgs.maxFormulas}"
  IO.println s!"Valid seed count: {cliArgs.validSeedCount}"
  IO.println s!"Output: {cliArgs.output}"
  IO.println s!"Include duals: {cliArgs.includeDuals}"
  IO.println ""

  -- Step 1: Enumerate formulas
  let params : EnumParams := {
    maxComplexity := cliArgs.maxComplexity
    maxModalDepth := cliArgs.maxModalDepth
    maxTemporalDepth := cliArgs.maxTemporalDepth
    maxFormulas := cliArgs.maxFormulas
    samplingMode := cliArgs.mode
    validSeedCount := cliArgs.validSeedCount
  }
  IO.println "Generating formulas..."
  let formulas ← generateFormulas params
  IO.println s!"  Generated {formulas.length} unique formulas"

  -- Step 2: Optionally enrich with duals
  let formulas' := if cliArgs.includeDuals then
    enrichWithDuals formulas
  else formulas
  if cliArgs.includeDuals then
    IO.println s!"  After temporal duals: {formulas'.length} formulas"

  -- Step 3: Label all formulas
  IO.println s!"Labeling {formulas'.length} formulas..."
  let labeled ← labelBatch formulas'

  -- Step 4: Print statistics
  let stats := computeBatchStats labeled
  IO.println ""
  IO.println (stats.display)
  IO.println ""

  -- Step 5: Ensure output directory exists
  let outputPath : System.FilePath := ⟨cliArgs.output⟩
  match outputPath.parent with
  | some dir => do
    let dirExists ← dir.pathExists
    if !dirExists then
      IO.FS.createDirAll dir
  | none => pure ()

  -- Step 6: Write JSONL
  IO.println s!"Writing JSONL to {cliArgs.output}..."
  let count ← writeDatasetJSONL outputPath labeled
  IO.println s!"  Wrote {count} records"

  -- Step 7: Write metadata
  let metadata := computeDatasetMetadata labeled params cliArgs.includeDuals
  writeMetadata outputPath metadata
  IO.println s!"  Wrote metadata file"

  -- Step 8: Feasibility checks
  IO.println ""
  IO.println "Feasibility Checks:"
  let timeoutRate := if stats.totalCount > 0
    then stats.timeoutCount * 100 / stats.totalCount else 0
  let validRate := if stats.totalCount > 0
    then stats.validCount * 100 / stats.totalCount else 0
  IO.println s!"  Timeout rate: {timeoutRate}% (target: <20%)"
  IO.println s!"  Valid fraction: {validRate}% (target: >=30%)"

  -- Report diversity
  let diversity := computeDiversity (labeled.map (·.formula))
  IO.println s!"  Category diversity: {diversity.categoryCounts.length} categories"
  IO.println ""
  IO.println "Done!"
