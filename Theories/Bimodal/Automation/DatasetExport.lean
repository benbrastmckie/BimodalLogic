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
  /-- Enriched countermodel with branch structure (invalid formulas only). -/
  enriched_countermodel : Option Enriched.EnrichedCountermodel
  /-- Semantic countermodel summary (invalid formulas only). -/
  semantic_countermodel : Option SemanticCountermodelSummary
  /-- How the proof was reconstructed (valid formulas only). -/
  proof_reconstruction_method : Option String
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
     countermodel_consistent := none
     enriched_countermodel := none
     semantic_countermodel := none
     proof_reconstruction_method := none }⟩

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
  let ecmStr := match r.enriched_countermodel with
    | none => "null"
    | some ecm => ecm.toJson
  let scmStr := match r.semantic_countermodel with
    | none => "null"
    | some s => s.toJson
  let reconStr := match r.proof_reconstruction_method with
    | none => "null"
    | some m => "\"" ++ escapeJsonString m ++ "\""
  "{\"id\": \"" ++ escapeJsonString r.id ++ "\""
  ++ ", \"split\": \"" ++ escapeJsonString r.split ++ "\""
  ++ ", \"formula_str\": \"" ++ escapeJsonString r.formula_str ++ "\""
  ++ ", \"formula_ast\": " ++ r.formula_ast
  ++ ", \"frame_class\": \"" ++ escapeJsonString r.frame_class ++ "\""
  ++ ", \"label\": " ++ formulaLabelToJson r.label
  ++ ", \"decision_method\": \"" ++ escapeJsonString r.decision_method ++ "\""
  ++ ", \"proof_reconstruction_method\": " ++ reconStr
  ++ ", \"proof_trace\": " ++ traceStr
  ++ ", \"rule_profile\": " ++ rpStr
  ++ ", \"countermodel\": " ++ cmStr
  ++ ", \"countermodel_consistent\": " ++ cmConsStr
  ++ ", \"enriched_countermodel\": " ++ ecmStr
  ++ ", \"semantic_countermodel\": " ++ scmStr
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
    countermodel_consistent := lf.countermodelConsistent
    enriched_countermodel := lf.enrichedCountermodel
    semantic_countermodel := lf.semanticCountermodelSummary
    proof_reconstruction_method := lf.proofReconstructionMethod }
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
  /-- Resume from formula N (skip the first N formulas and append to existing output).
      0 means fresh start (default). -/
  resumeFrom : Nat := 0
  /-- Path to checkpoint file containing serialized formula list for deterministic resume.
      Default: derived from output path by replacing .jsonl with .checkpoint -/
  checkpointFile : Option String := none
  /-- When set, read formulas from the checkpoint file instead of re-enumerating. -/
  useCheckpoint : Bool := false
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
  | "--resume-from" :: n :: rest, acc =>
    go rest { acc with resumeFrom := n.toNat! }
  | "--checkpoint-file" :: p :: rest, acc =>
    go rest { acc with checkpointFile := some p }
  | "--use-checkpoint" :: rest, acc =>
    go rest { acc with useCheckpoint := true }
  | _ :: rest, acc => go rest acc

end Bimodal.Automation.DatasetExport

/-!
## S-Expression Parser for Checkpoint Resume

Parse formulas from S-expression strings written by `Formula.toSExpr`.
Used to read checkpoint files for deterministic resume.
-/

open Bimodal.Syntax
open Bimodal.Automation
open Bimodal.Automation.DatasetExport

/-- Parser state for S-expression parsing using raw byte positions. -/
structure SExprPS where
  input : String
  pos : String.Pos.Raw

/-- Get the current character without advancing. -/
def SExprPS.peek (st : SExprPS) : Option Char :=
  String.Pos.Raw.get? st.input st.pos

/-- Advance position by one character (using the current character's byte width). -/
def SExprPS.advance (st : SExprPS) : SExprPS :=
  match String.Pos.Raw.get? st.input st.pos with
  | some c => { st with pos := ⟨st.pos.byteIdx + c.utf8Size⟩ }
  | none => st

/-- Skip whitespace characters (recursive helper). -/
def SExprPS.skipWSAux (st : SExprPS) : (fuel : Nat) → SExprPS
  | 0 => st
  | fuel + 1 =>
    match st.peek with
    | some ' ' | some '\t' | some '\n' | some '\r' => st.advance.skipWSAux fuel
    | _ => st

/-- Skip whitespace characters. -/
def SExprPS.skipWS (st : SExprPS) : SExprPS := st.skipWSAux 1000

/-- Check if the input matches a specific string at current position. -/
def SExprPS.matchStr (st : SExprPS) (s : String) : Bool :=
  let chars := s.toList
  let rec go (p : String.Pos.Raw) : List Char → Bool
    | [] => true
    | c :: cs =>
      match String.Pos.Raw.get? st.input p with
      | some c' => if c == c' then go ⟨p.byteIdx + c'.utf8Size⟩ cs else false
      | none => false
  go st.pos chars

/-- Advance position by the byte length of a string. -/
def SExprPS.advanceBy (st : SExprPS) (s : String) : SExprPS :=
  { st with pos := ⟨st.pos.byteIdx + s.utf8ByteSize⟩ }

/-- Parse quoted string contents (recursive helper). -/
def parseQuotedStringAux (st : SExprPS) (acc : String) : (fuel : Nat) → Option (String × SExprPS)
  | 0 => none
  | fuel + 1 =>
    match st.peek with
    | some '"' => some (acc, st.advance)  -- skip closing quote
    | some '\\' =>
      let st := st.advance
      match st.peek with
      | some c => parseQuotedStringAux st.advance (acc.push c) fuel
      | none => none
    | some c => parseQuotedStringAux st.advance (acc.push c) fuel
    | none => none

/-- Parse a quoted string (e.g., "p" or "hello"). -/
def parseQuotedStringSExpr (st : SExprPS) : Option (String × SExprPS) :=
  match st.peek with
  | some '"' => parseQuotedStringAux st.advance "" 10000
  | _ => none

/-- Parse a natural number (recursive helper). -/
def parseNatSExprAux (st : SExprPS) (acc : Nat) (hasDigit : Bool) : (fuel : Nat) → Option (Nat × SExprPS)
  | 0 => if hasDigit then some (acc, st) else none
  | fuel + 1 =>
    match st.peek with
    | some c =>
      if c.isDigit then parseNatSExprAux st.advance (acc * 10 + (c.toNat - '0'.toNat)) true fuel
      else if hasDigit then some (acc, st)
      else none
    | none => if hasDigit then some (acc, st) else none

/-- Parse a natural number. -/
def parseNatSExpr (st : SExprPS) : Option (Nat × SExprPS) :=
  parseNatSExprAux st 0 false 100

/-- Parse a single formula from an S-expression string.
    Returns the parsed formula and the remaining parser state.

    Supported forms:
    - `bot`
    - `(atom "name")`
    - `(atom "name" N)` (with fresh index)
    - `(imp <φ> <ψ>)`
    - `(box <φ>)`
    - `(untl <φ> <ψ>)`
    - `(snce <φ> <ψ>)` -/
def parseSExprFormula (st : SExprPS) : (fuel : Nat) → Option (Formula × SExprPS)
  | 0 => none
  | fuel + 1 =>
    let st := st.skipWS
    match st.peek with
    | some '(' =>
      let st := st.advance.skipWS
      -- Parse tag
      if st.matchStr "atom " then
        let st := st.advanceBy "atom "
        let st := st.skipWS
        match parseQuotedStringSExpr st with
        | some (name, st) =>
          let st := st.skipWS
          -- Check for optional fresh index
          match st.peek with
          | some ')' => some (Formula.atom (Atom.mk_base name), st.advance)
          | some c =>
            if c.isDigit then
              match parseNatSExpr st with
              | some (idx, st) =>
                let st := st.skipWS
                match st.peek with
                | some ')' => some (Formula.atom ⟨name, some idx⟩, st.advance)
                | _ => none
              | none => none
            else none
          | none => none
        | none => none
      else if st.matchStr "imp " then
        let st := st.advanceBy "imp "
        match parseSExprFormula st fuel with
        | some (lhs, st) =>
          match parseSExprFormula st fuel with
          | some (rhs, st) =>
            let st := st.skipWS
            match st.peek with
            | some ')' => some (Formula.imp lhs rhs, st.advance)
            | _ => none
          | none => none
        | none => none
      else if st.matchStr "box " then
        let st := st.advanceBy "box "
        match parseSExprFormula st fuel with
        | some (child, st) =>
          let st := st.skipWS
          match st.peek with
          | some ')' => some (Formula.box child, st.advance)
          | _ => none
        | none => none
      else if st.matchStr "untl " then
        let st := st.advanceBy "untl "
        match parseSExprFormula st fuel with
        | some (lhs, st) =>
          match parseSExprFormula st fuel with
          | some (rhs, st) =>
            let st := st.skipWS
            match st.peek with
            | some ')' => some (Formula.untl lhs rhs, st.advance)
            | _ => none
          | none => none
        | none => none
      else if st.matchStr "snce " then
        let st := st.advanceBy "snce "
        match parseSExprFormula st fuel with
        | some (lhs, st) =>
          match parseSExprFormula st fuel with
          | some (rhs, st) =>
            let st := st.skipWS
            match st.peek with
            | some ')' => some (Formula.snce lhs rhs, st.advance)
            | _ => none
          | none => none
        | none => none
      else none
    | some 'b' =>
      if st.matchStr "bot" then
        some (Formula.bot, st.advanceBy "bot")
      else none
    | _ => none

/-- Parse a single-line S-expression into a Formula.
    Returns `none` if parsing fails. -/
def parseFormulaSExpr (s : String) : Option Formula :=
  let st : SExprPS := { input := s, pos := ⟨0⟩ }
  match parseSExprFormula st 10000 with
  | some (φ, _) => some φ
  | none => none

/-- Enumerate formulas and optionally enrich with duals.
    Factored out of main for reuse in checkpoint vs fresh enumeration paths. -/
private def enumerateAndEnrich (params : EnumParams) (includeDuals : Bool) : IO (List Formula) := do
  IO.println "Generating formulas..."
  let formulas ← generateFormulas params
  IO.println s!"  Generated {formulas.length} unique formulas"
  let formulas' := if includeDuals then enrichWithDuals formulas else formulas
  if includeDuals then
    IO.println s!"  After temporal duals: {formulas'.length} formulas"
  return formulas'

/-!
## Main Entry Point

The `main` function is the CLI entry point for `lake exe dataset_generator`.
-/

/--
Main entry point for the dataset generator executable.

Pipeline:
1. Parse CLI arguments
2. Construct EnumParams
3. Load formulas (from checkpoint or fresh enumeration)
4. Optionally enrich with temporal duals
5. Write checkpoint file (for future resume)
6. Skip already-labeled formulas if resuming
7. Label remaining formulas, write JSONL lines immediately
8. Write metadata file
9. Print summary statistics
10. Clean up checkpoint on completion
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
  if cliArgs.resumeFrom > 0 then
    IO.println s!"Resume from: formula {cliArgs.resumeFrom}"
  IO.println ""

  -- Step 1: Determine checkpoint file path
  let checkpointPath : System.FilePath :=
    match cliArgs.checkpointFile with
    | some p => ⟨p⟩
    | none => ⟨cliArgs.output.replace ".jsonl" ".checkpoint"⟩

  -- Step 1b: Load formulas (from checkpoint or fresh enumeration)
  let params : EnumParams := {
    maxComplexity := cliArgs.maxComplexity
    maxModalDepth := cliArgs.maxModalDepth
    maxTemporalDepth := cliArgs.maxTemporalDepth
    maxFormulas := cliArgs.maxFormulas
    samplingMode := cliArgs.mode
    validSeedCount := cliArgs.validSeedCount
    stratifiedQuotas := cliArgs.stratifiedQuotas
  }
  -- When resuming, try to load from checkpoint to avoid re-enumeration non-determinism
  let useCheckpointFile := cliArgs.useCheckpoint ||
    (cliArgs.resumeFrom > 0 && (← checkpointPath.pathExists))
  let formulas' ← if useCheckpointFile then do
    IO.println s!"Loading formulas from checkpoint: {checkpointPath}..."
    let content ← IO.FS.readFile checkpointPath
    let lines := (content.splitOn "\n").filter (· ≠ "")
    let parsed := lines.filterMap parseFormulaSExpr
    if parsed.length == 0 then do
      IO.println "  WARNING: checkpoint file empty or unparseable, falling back to re-enumeration"
      let formulas ← enumerateAndEnrich params cliArgs.includeDuals
      pure formulas
    else do
      IO.println s!"  Loaded {parsed.length} formulas from checkpoint"
      pure parsed
  else do
    let formulas ← enumerateAndEnrich params cliArgs.includeDuals
    pure formulas

  -- Step 2: Ensure output directory exists
  let outputPath : System.FilePath := ⟨cliArgs.output⟩
  match outputPath.parent with
  | some dir => do
    let dirExists ← dir.pathExists
    if !dirExists then
      IO.FS.createDirAll dir
  | none => pure ()

  -- Step 2b: Write checkpoint file on fresh runs
  if cliArgs.resumeFrom == 0 then do
    IO.println s!"Writing checkpoint file: {checkpointPath}..."
    let cpHandle ← IO.FS.Handle.mk checkpointPath .write
    for φ in formulas' do
      cpHandle.putStrLn φ.toSExpr
    IO.println s!"  Wrote {formulas'.length} formulas to checkpoint"

  -- Step 3d: Skip already-labeled formulas when resuming
  let formulasToLabel := if cliArgs.resumeFrom > 0 then
    formulas'.drop cliArgs.resumeFrom
  else formulas'

  -- Step 4: Streaming label + write pipeline
  -- Label each formula, write JSONL line immediately, accumulate lightweight stats
  let totalFormulas := formulas'.length
  if cliArgs.resumeFrom > 0 then
    IO.println s!"Resuming from formula {cliArgs.resumeFrom} ({formulasToLabel.length} remaining of {totalFormulas})..."
  IO.println s!"Labeling and streaming {formulasToLabel.length} formulas to {cliArgs.output}..."
  IO.println s!"[label] Starting labeling of {formulasToLabel.length} formulas..."
  let fileMode := if cliArgs.resumeFrom > 0 then IO.FS.Mode.append else IO.FS.Mode.write
  let handle ← IO.FS.Handle.mk outputPath fileMode
  let startTime ← IO.monoMsNow
  let mut count : Nat := cliArgs.resumeFrom
  let mut validCount : Nat := 0
  let mut invalidCount : Nat := 0
  let mut timeoutCount : Nat := 0
  let mut totalComplexity : Nat := 0
  let mut totalTimeMs : Nat := 0
  let mut categoryCounts : List (GoalCategory × Nat) := []
  let mut methodCounts : List (String × Nat) := []
  for φ in formulasToLabel do
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
      let elapsedMs := elapsed - startTime
      let labeledSoFar := count - cliArgs.resumeFrom
      let pct := if totalFormulas > 0 then count * 100 / totalFormulas else 0
      let validPct := if labeledSoFar > 0 then validCount * 100 / labeledSoFar else 0
      let timeoutPct := if labeledSoFar > 0 then timeoutCount * 100 / labeledSoFar else 0
      let rate := if elapsedMs > 0 then labeledSoFar * 1000 / elapsedMs else labeledSoFar
      let etaStr := if labeledSoFar < 100 then "calculating..."
        else if rate > 0 then
          let remaining := totalFormulas - count
          let etaSecs := remaining / rate
          let etaMin := etaSecs / 60
          let etaSecRem := etaSecs % 60
          s!"{etaMin}m {etaSecRem}s"
        else "unknown"
      IO.println s!"[label] {count}/{totalFormulas} labeled ({pct}%), {validPct}% valid, {timeoutPct}% timeout, {rate} formulas/sec, ETA: {etaStr}"

  -- Labeling completion line
  let labelEndMs ← IO.monoMsNow
  let labelElapsedMs := labelEndMs - startTime
  let labelElapsedSecs := labelElapsedMs / 1000
  let labeledThisRun := count - cliArgs.resumeFrom
  let finalRate := if labelElapsedMs > 0 then labeledThisRun * 1000 / labelElapsedMs else labeledThisRun
  if cliArgs.resumeFrom > 0 then
    IO.println s!"[label] Labeling complete: {labeledThisRun} formulas in {labelElapsedSecs}s ({finalRate} formulas/sec), total {count} of {totalFormulas}"
  else
    IO.println s!"[label] Labeling complete: {count} formulas in {labelElapsedSecs}s ({finalRate} formulas/sec)"

  -- Step 5: Print statistics (for this run's portion only)
  let avgTimeMs := if labeledThisRun > 0 then totalTimeMs / labeledThisRun else 0
  let avgComplexity := if labeledThisRun > 0 then totalComplexity / labeledThisRun else 0
  IO.println ""
  IO.println s!"Batch Statistics{if cliArgs.resumeFrom > 0 then " (this run)" else ""}:"
  IO.println s!"  Labeled: {labeledThisRun}{if cliArgs.resumeFrom > 0 then s!" (total in file: {count})" else ""}"
  IO.println s!"  Valid: {validCount} ({if labeledThisRun > 0 then validCount * 100 / labeledThisRun else 0}%)"
  IO.println s!"  Invalid: {invalidCount}"
  IO.println s!"  Timeout: {timeoutCount} ({if labeledThisRun > 0 then timeoutCount * 100 / labeledThisRun else 0}%)"
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
  IO.println s!"  Wrote {labeledThisRun} records to {cliArgs.output}{if cliArgs.resumeFrom > 0 then s!" (appended, total: {count})" else ""}"
  IO.println s!"  Wrote metadata file"

  -- Step 6b: Clean up checkpoint file on successful completion
  if cliArgs.resumeFrom == 0 || count == totalFormulas then do
    let cpExists ← checkpointPath.pathExists
    if cpExists then do
      IO.FS.removeFile checkpointPath
      IO.println s!"  Cleaned up checkpoint file: {checkpointPath}"

  -- Step 7: Feasibility checks
  IO.println ""
  IO.println "Feasibility Checks:"
  let timeoutRate := if labeledThisRun > 0
    then timeoutCount * 100 / labeledThisRun else 0
  let validRate := if labeledThisRun > 0
    then validCount * 100 / labeledThisRun else 0
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
