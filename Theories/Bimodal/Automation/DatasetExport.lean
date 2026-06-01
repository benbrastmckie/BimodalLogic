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
  /-- Maximum modal nesting depth of the formula. -/
  max_modal_depth : Nat
  /-- Maximum temporal nesting depth of the formula. -/
  max_temporal_depth : Nat
  /-- Which decision pipeline stage produced the result. -/
  decision_method : String
  /-- Rule application counts (valid formulas only). -/
  rule_profile : Option RuleProfile
  /-- Whether the countermodel is self-consistent (invalid formulas only). -/
  countermodel_consistent : Option Bool
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
     pattern_features := "[]"
     max_modal_depth := 0
     max_temporal_depth := 0
     decision_method := "timeout"
     rule_profile := none
     countermodel_consistent := none }⟩

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
  let rpStr := match r.rule_profile with
    | none => "null"
    | some rp => rp.toJson
  let cmConsStr := match r.countermodel_consistent with
    | none => "null"
    | some true => "true"
    | some false => "false"
  "{\"id\": \"" ++ escapeJsonString r.id ++ "\""
  ++ ", \"split\": \"" ++ escapeJsonString r.split ++ "\""
  ++ ", \"formula_str\": \"" ++ escapeJsonString r.formula_str ++ "\""
  ++ ", \"formula_ast\": " ++ r.formula_ast
  ++ ", \"frame_class\": \"" ++ escapeJsonString r.frame_class ++ "\""
  ++ ", \"label\": " ++ formulaLabelToJson r.label
  ++ ", \"decision_method\": \"" ++ escapeJsonString r.decision_method ++ "\""
  ++ ", \"proof_trace\": " ++ traceStr
  ++ ", \"rule_profile\": " ++ rpStr
  ++ ", \"countermodel\": " ++ cmStr
  ++ ", \"countermodel_consistent\": " ++ cmConsStr
  ++ ", \"pattern_key\": " ++ r.pattern_key.toJson
  ++ ", \"metrics\": " ++ difficultyMetricsToJson r.metrics
  ++ ", \"augmentation\": " ++ augStr
  ++ ", \"formula_sexpr\": \"" ++ escapeJsonString r.formula_sexpr ++ "\""
  ++ ", \"formula_tokens\": " ++ r.formula_tokens
  ++ ", \"pattern_features\": " ++ r.pattern_features
  ++ ", \"max_modal_depth\": " ++ toString r.max_modal_depth
  ++ ", \"max_temporal_depth\": " ++ toString r.max_temporal_depth
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
    pattern_features := lf.patternKey.featureVectorToJson
    max_modal_depth := lf.patternKey.modalDepth
    max_temporal_depth := lf.patternKey.temporalDepth
    decision_method := lf.decisionMethod
    rule_profile := lf.ruleProfile
    countermodel_consistent := lf.countermodelConsistent }
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
  /-- Decision method distribution: (method_name, count). -/
  decisionMethodDist : List (String × Nat) := []
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
    | .stratified => "stratified"
  -- Compute decision method distribution
  let methodDist := labeled.foldl (fun acc lf =>
    let method := lf.decisionMethod
    if acc.any (fun (k, _) => k == method) then
      acc.map fun (k, n) => if k == method then (k, n + 1) else (k, n)
    else
      (method, 1) :: acc
  ) ([] : List (String × Nat))
  { totalRecords := stats.totalCount
    validCount := stats.validCount
    invalidCount := stats.invalidCount
    timeoutCount := stats.timeoutCount
    avgComplexity := avgC
    includeDuals := includeDuals
    maxComplexity := params.maxComplexity
    samplingMode := modeStr
    decisionMethodDist := methodDist }

/--
Serialize dataset metadata to a JSON string.
-/
def datasetMetadataToJson (m : DatasetMetadata) : String :=
  let dualStr := if m.includeDuals then "true" else "false"
  let methodDistStr := if m.decisionMethodDist.isEmpty then "null"
    else
      let entries := m.decisionMethodDist.map fun (method, count) =>
        "\"" ++ escapeJsonString method ++ "\": " ++ toString count
      "{" ++ String.intercalate ", " entries ++ "}"
  "{\n"
  ++ "  \"total_records\": " ++ toString m.totalRecords ++ ",\n"
  ++ "  \"valid_count\": " ++ toString m.validCount ++ ",\n"
  ++ "  \"invalid_count\": " ++ toString m.invalidCount ++ ",\n"
  ++ "  \"timeout_count\": " ++ toString m.timeoutCount ++ ",\n"
  ++ "  \"avg_complexity\": " ++ toString m.avgComplexity ++ ",\n"
  ++ "  \"include_duals\": " ++ dualStr ++ ",\n"
  ++ "  \"max_complexity\": " ++ toString m.maxComplexity ++ ",\n"
  ++ "  \"sampling_mode\": \"" ++ m.samplingMode ++ "\",\n"
  ++ "  \"decision_method_distribution\": " ++ methodDistStr ++ ",\n"
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
  /-- Per-complexity-level quotas for stratified sampling.
      Each pair is (complexity, maxRecords). A maxRecords of 0 means exhaustive.
      Format: "9:0,10:100000,11:300000" where 0 = exhaustive -/
  stratifiedQuotas : List (Nat × Nat) := []
  deriving Repr, Inhabited

/--
Parse a stratified quotas string of the form "9:0,10:100000,11:300000".
Each entry is complexity:maxRecords where 0 means exhaustive at that level.
-/
def parseQuotas (s : String) : List (Nat × Nat) :=
  let entries := s.splitOn ","
  entries.filterMap fun entry =>
    let parts := entry.splitOn ":"
    match parts with
    | [complexityStr, quotaStr] =>
      let complexity := complexityStr.trimAscii.toString.toNat!
      let quota := quotaStr.trimAscii.toString.toNat!
      some (complexity, quota)
    | _ => none

/--
Parse CLI arguments from a list of strings.
Supports: `--max-complexity`, `--max-modal-depth`, `--max-temporal-depth`,
`--max-formulas`, `--output`, `--mode`, `--include-duals`, `--stratified-quotas`.
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
      | "stratified" => SamplingMode.stratified
      | _ => SamplingMode.exhaustive
    go rest { acc with mode := mode }
  | "--include-duals" :: rest, acc =>
    go rest { acc with includeDuals := true }
  | "--valid-seed-count" :: n :: rest, acc =>
    go rest { acc with validSeedCount := n.toNat! }
  | "--stratified-quotas" :: q :: rest, acc =>
    go rest { acc with stratifiedQuotas := parseQuotas q }
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
    stratifiedQuotas := cliArgs.stratifiedQuotas
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

  -- Step 3: Ensure output directory exists
  let outputPath : System.FilePath := ⟨cliArgs.output⟩
  match outputPath.parent with
  | some dir => do
    let dirExists ← dir.pathExists
    if !dirExists then
      IO.FS.createDirAll dir
  | none => pure ()

  -- Step 4: Streaming label + write pipeline
  -- Label each formula, write JSONL line immediately, accumulate lightweight stats
  IO.println s!"Labeling and streaming {formulas'.length} formulas to {cliArgs.output}..."
  let handle ← IO.FS.Handle.mk outputPath .write
  let startTime ← IO.monoMsNow
  let mut count : Nat := 0
  let mut validCount : Nat := 0
  let mut invalidCount : Nat := 0
  let mut timeoutCount : Nat := 0
  let mut totalComplexity : Nat := 0
  let mut totalTimeMs : Nat := 0
  let mut categoryCounts : List (GoalCategory × Nat) := []
  let mut methodCounts : List (String × Nat) := []
  for φ in formulas' do
    let labeled ← labelFormula φ
    -- Write JSONL line immediately (no accumulation)
    let splitName := assignSplit labeled.formula.prettyPrint
    let record := labeledToRecord (count + 1) splitName labeled
    writeRecordJSONL handle record
    -- Update running accumulators
    count := count + 1
    totalComplexity := totalComplexity + labeled.metrics.complexity
    totalTimeMs := totalTimeMs + labeled.metrics.decisionTimeMs
    match labeled.label with
    | .valid => validCount := validCount + 1
    | .invalid => invalidCount := invalidCount + 1
    | .timeout => timeoutCount := timeoutCount + 1
    categoryCounts := incrCategoryCount categoryCounts (goalCategory labeled.formula)
    methodCounts := incrMethodCount methodCounts labeled.decisionMethod
    -- Progress reporting every 1000 formulas
    if count % 1000 == 0 then
      let elapsed ← IO.monoMsNow
      let elapsedSecs := (elapsed - startTime) / 1000
      let validPct := if count > 0 then validCount * 100 / count else 0
      IO.println s!"  Progress: {count}/{formulas'.length} labeled, {validPct}% valid, {elapsedSecs}s elapsed"

  -- Step 5: Print statistics
  let avgTimeMs := if count > 0 then totalTimeMs / count else 0
  let avgComplexity := if count > 0 then totalComplexity / count else 0
  IO.println ""
  IO.println s!"Batch Statistics:"
  IO.println s!"  Total: {count}"
  IO.println s!"  Valid: {validCount} ({if count > 0 then validCount * 100 / count else 0}%)"
  IO.println s!"  Invalid: {invalidCount}"
  IO.println s!"  Timeout: {timeoutCount} ({if count > 0 then timeoutCount * 100 / count else 0}%)"
  IO.println s!"  Avg decision time: {avgTimeMs}ms"
  IO.println ""

  -- Step 6: Write metadata from accumulators (no list scan needed)
  let modeStr := match params.samplingMode with
    | .exhaustive => "exhaustive"
    | .random => "random"
    | .hybrid => "hybrid"
    | .stratified => "stratified"
  let metadata : DatasetMetadata := {
    totalRecords := count
    validCount := validCount
    invalidCount := invalidCount
    timeoutCount := timeoutCount
    avgComplexity := avgComplexity
    includeDuals := cliArgs.includeDuals
    maxComplexity := params.maxComplexity
    samplingMode := modeStr
    decisionMethodDist := methodCounts
  }
  writeMetadata outputPath metadata
  IO.println s!"  Wrote {count} records to {cliArgs.output}"
  IO.println s!"  Wrote metadata file"

  -- Step 7: Feasibility checks
  IO.println ""
  IO.println "Feasibility Checks:"
  let timeoutRate := if count > 0
    then timeoutCount * 100 / count else 0
  let validRate := if count > 0
    then validCount * 100 / count else 0
  IO.println s!"  Timeout rate: {timeoutRate}% (target: <20%)"
  IO.println s!"  Valid fraction: {validRate}% (target: >=30%)"
  IO.println s!"  Category diversity: {categoryCounts.length} categories"
  IO.println ""
  IO.println "Done!"
where
  /-- Increment category count in an association list. -/
  incrCategoryCount (counts : List (GoalCategory × Nat)) (cat : GoalCategory)
      : List (GoalCategory × Nat) :=
    if counts.any (fun (k, _) => k == cat) then
      counts.map fun (k, n) => if k == cat then (k, n + 1) else (k, n)
    else
      (cat, 1) :: counts
  /-- Increment decision method count in an association list. -/
  incrMethodCount (counts : List (String × Nat)) (method : String)
      : List (String × Nat) :=
    if counts.any (fun (k, _) => k == method) then
      counts.map fun (k, n) => if k == method then (k, n + 1) else (k, n)
    else
      (method, 1) :: counts
