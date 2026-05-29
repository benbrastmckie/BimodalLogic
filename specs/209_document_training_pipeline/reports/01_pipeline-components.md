# Research Report: Task #209

**Task**: 209 - document_training_pipeline
**Started**: 2026-05-29T00:00:00Z
**Completed**: 2026-05-29T00:30:00Z
**Effort**: 1 hour (read-only research across 6 Lean modules, Python helper, lakefile, validation reports, BimodalHarness repo)
**Dependencies**: None
**Sources/Inputs**: Codebase (all 6 Lean modules, Python script, lakefile.lean), execution summary, Tier 1 validation report, GitHub API for BimodalHarness
**Artifacts**: `specs/209_document_training_pipeline/reports/01_pipeline-components.md`
**Standards**: report-format.md

---

## Executive Summary

- The BimodalLogic repo contains a complete Lean-native training data pipeline implemented in 6 Lean modules under `Theories/Bimodal/Automation/`, two `lake exe` targets (`dataset_generator`, `dataset_validator`), and a Python tensor converter (`scripts/generate_dataset.py`).
- The pipeline implements a dual-signal architecture: valid formulas carry **proof traces** (positive signal for the policy network) and invalid formulas carry **countermodels** (corrective signal for the value network).
- Exported data is consumed by [BimodalHarness](https://github.com/benbrastmckie/BimodalHarness) via JSONL files synced with `make sync-data`; the integration is artifact-only (BimodalHarness never calls Lean at runtime).
- The Tier 1 feasibility gate identified a provability ratio imbalance (3.2% valid vs 15% minimum), recommending theorem mining or biased enumeration for the next tier.

---

## Context & Scope

Task 201 (alphazero_proof_search_harness) built the entire pipeline in 6 phases. Task 203 contributed an alternative formula enumerator implementation (legacy API). Task 209 aims to produce a reference documentation document describing all components clearly, linking the Lean-side pipeline to the Python-side BimodalHarness training harness.

---

## Findings

### 1. Module: `DataExport.lean`

**Path**: `Theories/Bimodal/Automation/DataExport.lean`
**Namespace**: `Bimodal.Automation.DataExport`

**Imports**:
- `Bimodal.Syntax`
- `Bimodal.Automation.SuccessPatterns`
- `Bimodal.Metalogic.Decidability.CountermodelExtraction`
- `Bimodal.ProofSystem.Derivation`

**Purpose**: JSON serialization primitives for all core types. No external JSON library — uses string concatenation with proper escaping.

**Public API**:

| Name | Type | Description |
|------|------|-------------|
| `escapeJsonString` | `String → String` | Escape `"` and `\` for JSON values |
| `listToJsonArray` | `List String → String` | Wrap a list of JSON strings into `[...]` |
| `Atom.toJson` | `Atom → String` | `{"base": "p", "fresh_index": null}` |
| `Formula.toJson` | `Formula → String` | Recursive formula AST as JSON with `"tag"` field |
| `Formula.prettyPrint` | `Formula → String` | Human-readable notation (→, □, U, S) |
| `GoalCategory.toJson` | `GoalCategory → String` | Category name as quoted JSON string |
| `PatternKey.toJson` | `PatternKey → String` | 5-field feature vector JSON |
| `SimpleCountermodel.toJson` | `SimpleCountermodel → String` | `trueAtoms`, `falseAtoms`, `formula` |
| `RuleProfile` | `structure` | Counts of 7 derivation rule types per proof tree |
| `RuleProfile.empty` | `RuleProfile` | Zero-initialized rule profile |
| `RuleProfile.merge` | `RuleProfile → RuleProfile → RuleProfile` | Sum corresponding counts |
| `walkDerivationTree` | `DerivationTree fc Γ φ → RuleProfile` | Recursively count rule applications |
| `RuleProfile.toJson` | `RuleProfile → String` | Rule count object as JSON |
| `proofMetricsToJson` | `Nat → RuleProfile → String` | `{"height": N, "rules": {...}}` |

**Formula JSON Schema** (by constructor):
- `atom a` → `{"tag": "atom", "name": "<base>"}`
- `bot` → `{"tag": "bot"}`
- `imp φ ψ` → `{"tag": "imp", "left": ..., "right": ...}`
- `box φ` → `{"tag": "box", "child": ...}`
- `untl φ ψ` → `{"tag": "untl", "event": ..., "guard": ...}`
- `snce φ ψ` → `{"tag": "snce", "event": ..., "guard": ...}`

**Design decisions**: No external dependency; all serialization is pure string manipulation. `RuleProfile` avoids serializing the full dependent-type proof tree by counting rules via a tree walk.

---

### 2. Module: `FormulaEnumerator.lean`

**Path**: `Theories/Bimodal/Automation/FormulaEnumerator.lean`
**Namespace**: `Bimodal.Automation`

**Imports**:
- `Bimodal.Syntax`
- `Bimodal.Automation.SuccessPatterns`

**Purpose**: Bounded enumeration of TM bimodal logic formulas. Provides both exhaustive enumeration (for small complexity bounds) and deterministic pseudo-random sampling (for larger spaces). Contains two APIs: the plan-specified API (Task 201) and the legacy API (Task 203).

**Public API — Plan-specified (EnumConfig)**:

| Name | Type | Description |
|------|------|-------------|
| `EnumConfig` | `structure` | `maxModalDepth`, `maxTemporalDepth`, `maxSize`, `atomPool` |
| `defaultAtomPool` | `List Atom` | 5 atoms: p, q, r, s, t |
| `smallConfig` | `EnumConfig` | depth 2, size 8, 3 atoms — exhaustive |
| `mediumConfig` | `EnumConfig` | depth 3, size 12, 5 atoms — sampling |
| `enumerateUpToDepth` | `EnumConfig → List Formula` | Exhaustive enumeration with deduplication |
| `sampleFormulas` | `EnumConfig → Nat → Nat → List Formula` | Deterministic LCG-based sampling |
| `LCGState` | `structure` | glibc LCG state (a=1103515245, c=12345, m=2³¹) |
| `DiversitySummary` | `structure` | Operator distribution, depth histograms, category counts |
| `diversitySummary` | `List Formula → DiversitySummary` | Compute diversity metrics |

**Public API — Legacy (EnumParams)**:

| Name | Type | Description |
|------|------|-------------|
| `SamplingMode` | `inductive` | `.exhaustive` / `.random` / `.hybrid` |
| `EnumParams` | `structure` | `maxComplexity`, `maxModalDepth`, `maxTemporalDepth`, `atoms`, `maxFormulas`, `samplingMode` |
| `enumerateExhaustive` | `EnumParams → List Formula` | Exhaustive via budget recursion |
| `sampleRandom` | `EnumParams → IO (List Formula)` | IO-based random generation |
| `enrichWithDuals` | `List Formula → List Formula` | Free 2x augmentation via `swap_temporal` |
| `generateFormulas` | `EnumParams → IO (List Formula)` | Dispatch by sampling mode |
| `DiversityReport` | `structure` | GoalCategory counts, modal/temporal depth buckets |
| `computeDiversity` | `List Formula → DiversityReport` | Legacy diversity computation |

**Design decisions**:
- Three simultaneous constraints (modal depth, temporal depth, size) prevent runaway in any single dimension.
- LCG sampling is deterministic: same seed always produces same output.
- Deduplication via `List.eraseDups` using `BEq Formula`.
- `passesFilter` rejects pure propositional formulas and complexity < 3.

---

### 3. Module: `DatasetGenerator.lean`

**Path**: `Theories/Bimodal/Automation/DatasetGenerator.lean`
**Namespace**: `Bimodal.Automation`

**Imports**:
- `Bimodal.Metalogic.Decidability.DecisionProcedure`
- `Bimodal.Automation.SuccessPatterns`
- `Bimodal.Automation.FormulaEnumerator`
- `Bimodal.Automation.DataExport`

**Purpose**: Runs the existing `DecisionProcedure.decide` on enumerated formulas, extracts simplified proof traces and countermodels, computes difficulty metrics, and produces labeled records. This is the labeling pipeline.

**Public API**:

| Name | Type | Description |
|------|------|-------------|
| `ProofTrace` | `structure` | `height`, `axioms_used : List String`, `rules_applied : List String` |
| `DifficultyMetrics` | `structure` | `complexity`, `modalDepth`, `temporalDepth`, `impCount`, `atomCount`, `decisionTimeMs`, `difficultyTier` |
| `FormulaLabel` | `inductive` | `.valid` / `.invalid` / `.timeout` |
| `LabeledFormula` | `structure` | `formula`, `label`, `proofTrace`, `countermodel`, `metrics`, `patternKey` |
| `extractAxiomName` | `Axiom φ → String` | Converts all 41 axiom constructors to string names |
| `extractProofTrace` | `DerivationTree fc Γ φ → ProofTrace` | Recursive tree walk collecting height, axioms, rules |
| `computeMetrics` | `Formula → Nat → DifficultyMetrics` | Structural metrics + difficulty tier (easy/medium/hard/very_hard) |
| `labelFormula` | `Formula → IO LabeledFormula` | Run `decideAuto`, retry with `decideOptimized` on timeout |
| `labelBatch` | `List Formula → IO (List LabeledFormula)` | Batch labeling with progress every 100 formulas |
| `BatchStats` | `structure` | `totalCount`, `validCount`, `invalidCount`, `timeoutCount`, `avgTimeMs` |
| `computeBatchStats` | `List LabeledFormula → BatchStats` | Aggregate statistics |
| `LabeledFormula.toJson` | `LabeledFormula → String` | Complete JSON with formula AST, features, decision, proof/countermodel, metrics |

**Labeling logic**: For each formula, `labelFormula` measures wall-clock time, calls `decideAuto` (auto fuel based on complexity), then retries with `decideOptimized` on timeout. Result is one of: `valid proof` (extract `ProofTrace`), `invalid cm` (keep `SimpleCountermodel`), `timeout` (record metrics only).

**Difficulty tiers**: complexity ≤ 3 = easy, ≤ 6 = medium, ≤ 9 = hard, else very_hard.

---

### 4. Module: `EnrichedCountermodel.lean`

**Path**: `Theories/Bimodal/Automation/EnrichedCountermodel.lean`
**Namespace**: `Bimodal.Automation.Enriched`

**Imports**:
- `Bimodal.Syntax`
- `Bimodal.Automation.DataExport`
- `Bimodal.Metalogic.Decidability.CountermodelExtraction`
- `Bimodal.Metalogic.Decidability.SignedFormula`

**Purpose**: Extends `SimpleCountermodel` (atom truth assignments only) with full saturated branch content from the tableau. Provides richer corrective signal: which modal and temporal formulas held or failed on the countermodel branch.

**Public API**:

| Name | Type | Description |
|------|------|-------------|
| `EnrichedCountermodel` | `structure` | `simple`, `branchFormulas`, `modalFormulas`, `temporalFormulas`, `branchLength` |
| `isModalFormula` | `SignedFormula → Bool` | True if top-level is `box` or `imp (.box _) _` |
| `isTemporalFormula` | `SignedFormula → Bool` | True if top-level is `untl` or `snce` |
| `extractModalFormulas` | `Branch → List SignedFormula` | Filter branch for modal formulas |
| `extractTemporalFormulas` | `Branch → List SignedFormula` | Filter branch for temporal formulas |
| `extractEnrichedCountermodel` | `Formula → Branch → EnrichedCountermodel` | Build from raw branch |
| `EnrichedCountermodelResult` | `inductive` | `.found ecm` / `.valid` / `.failed reason` |
| `findEnrichedCountermodel` | `Formula → Nat → EnrichedCountermodelResult φ` | Run `buildTableau` and extract enriched data |
| `SignedFormula.toJson` | `SignedFormula → String` | `{"sign": "pos"/"neg", "formula": ...}` |
| `EnrichedCountermodel.toJson` | `EnrichedCountermodel → String` | Full enriched countermodel as JSON |

**Design rationale**: `SimpleCountermodel` discards the saturated branch after extracting atoms. `EnrichedCountermodel` retains the branch so the value network can learn *why* a formula is invalid — which modal/temporal subformulas were the obstruction. This is the richer corrective signal of the dual-signal architecture.

---

### 5. Module: `DatasetExporter.lean`

**Path**: `Theories/Bimodal/Automation/DatasetExporter.lean`
**Namespace**: `Bimodal.Automation.DatasetExporter`

**Imports**:
- `Bimodal.Automation.DatasetGenerator`
- `Bimodal.Automation.EnrichedCountermodel`
- `Bimodal.Automation.FormulaEnumerator`
- `Bimodal.Automation.DataExport`

**Purpose**: Assembles labeled formulas into a structured JSON dataset file. Provides end-to-end pipelines from `EnumConfig` to a complete JSON file with metadata, statistics, and deterministic train/eval split.

**JSON Output Schema**:
```json
{
  "metadata": {
    "generator": "BimodalLogic/DatasetExporter",
    "version": "1.0",
    "config": { "maxModalDepth": 3, "maxTemporalDepth": 3, "maxSize": 12, "atomCount": 5 },
    "statistics": { "totalCount": N, "validCount": N, "invalidCount": N, "timeoutCount": N, "avgTimeMs": N },
    "frameClass": "Base"
  },
  "formulas": [
    { "id": 0, "formula": {...}, "formula_string": "...", "features": {...}, "decision": "...", "proof": {...}|null, "countermodel": {...}|null, "metrics": {...} },
    ...
  ]
}
```

**Public API**:

| Name | Type | Description |
|------|------|-------------|
| `EnumConfig.toJson` | `EnumConfig → String` | Serialize config parameters |
| `BatchStats.toJson` | `BatchStats → String` | Serialize batch statistics |
| `DatasetMetadata` | `structure` | `generator`, `version`, `config`, `stats`, `frameClass` |
| `DatasetMetadata.toJson` | `DatasetMetadata → String` | Full metadata JSON |
| `exportDatasetJson` | `DatasetMetadata → List LabeledFormula → String` | Assemble complete dataset JSON with sequential `id` fields |
| `writeDataset` | `String → String → IO Unit` | Write string content to file path |
| `splitDataset` | `List LabeledFormula → Float → (List LabeledFormula × List LabeledFormula)` | Deterministic stratified train/eval split (default 80/20) |
| `generateAndExportDataset` | `EnumConfig → String → IO Unit` | End-to-end: enumerate → label → export → write |
| `generateSplitDatasets` | `EnumConfig → String → String → Float → IO Unit` | End-to-end with train/eval split |

**Split strategy**: Stratified by label (valid/invalid/timeout) to preserve distribution. Within each stratum, first `floor(n × ratio)` go to train, rest to eval.

---

### 6. Module: `DatasetExport.lean`

**Path**: `Theories/Bimodal/Automation/DatasetExport.lean`
**Namespace**: `Bimodal.Automation.DatasetExport`

**Note**: This is a distinct module from `DatasetExporter.lean`. It is the root of the `dataset_generator` executable and provides the CLI entry point plus JSONL streaming format.

**Imports**:
- `Bimodal.Automation.DatasetGenerator`
- `Bimodal.Automation.DataExport`

**Purpose**: Provides JSONL streaming output (one record per line), CLI argument parsing, deterministic split assignment, and the `main` function for the `lake exe dataset_generator` executable.

**JSONL Record Schema** (one line per formula):
```json
{
  "id": "bmlogic-00001",
  "split": "train"|"val"|"test",
  "formula_str": "(□p → p)",
  "formula_ast": {"tag": "imp", ...},
  "frame_class": "Base",
  "label": "valid"|"invalid"|"timeout",
  "proof_trace": {"height": 0, "axioms_used": [...], "rules_applied": [...]},
  "countermodel": null,
  "pattern_key": {"modalDepth": 1, ...},
  "metrics": {"complexity": 3, ...},
  "augmentation": null
}
```

**Public API**:

| Name | Type | Description |
|------|------|-------------|
| `AugmentationInfo` | `structure` | `source`, `originalFormulaStr` — tracks temporal dual provenance |
| `DatasetRecord` | `structure` | Complete export-ready record matching JSONL schema |
| `datasetRecordToJson` | `DatasetRecord → String` | One-line JSON serialization |
| `labeledToRecord` | `Nat → String → LabeledFormula → DatasetRecord` | Convert from labeled formula with zero-padded ID |
| `assignSplit` | `String → String` | Deterministic 80/10/10 train/val/test via hash bucket |
| `writeRecordJSONL` | `IO.FS.Handle → DatasetRecord → IO Unit` | Write one record to open file handle |
| `writeDatasetJSONL` | `System.FilePath → List LabeledFormula → IO Nat` | Stream all records to JSONL file |
| `DatasetMetadata` | `structure` | Dataset-level statistics for companion `_metadata.json` |
| `computeDatasetMetadata` | `List LabeledFormula → EnumParams → Bool → DatasetMetadata` | Aggregate metadata |
| `datasetMetadataToJson` | `DatasetMetadata → String` | Pretty-print metadata JSON |
| `writeMetadata` | `System.FilePath → DatasetMetadata → IO Unit` | Write companion `_metadata.json` |
| `CLIArgs` | `structure` | Parsed CLI arguments |
| `parseCLIArgs` | `List String → CLIArgs` | Parse `--max-complexity`, `--output`, `--mode`, `--include-duals`, etc. |
| `main` | `List String → IO Unit` | CLI entry point for `lake exe dataset_generator` |

**CLI flags**:
```
lake exe dataset_generator -- [OPTIONS]
  --max-complexity N      Maximum formula complexity (default: 5)
  --max-modal-depth N     Maximum modal nesting (default: 2)
  --max-temporal-depth N  Maximum temporal nesting (default: 2)
  --max-formulas N        Maximum formulas to generate (default: 5000)
  --output PATH           Output JSONL path (default: data/bmlogic.jsonl)
  --mode MODE             exhaustive|random|hybrid (default: exhaustive)
  --include-duals         Include temporal dual augmentation
```

---

### 7. Module: `DatasetValidator.lean`

**Path**: `Theories/Bimodal/Automation/DatasetValidator.lean`
**Namespace**: `Bimodal.Automation.DatasetValidator`

**Imports**:
- `Bimodal.Automation.DatasetGenerator`
- `Bimodal.Automation.FormulaEnumerator`
- `Bimodal.Automation.DataExport`

**Purpose**: Validates dataset quality via conformance tests (known valid/invalid formulas) and a feasibility gate. Provides the `main` entry point for the `lake exe dataset_validator` executable.

**Public API**:

| Name | Type | Description |
|------|------|-------------|
| `knownValidFormulas` | `List Formula` | 10 curated BX axiom instances (prop K/S/exfalso/peirce, modal T/4/K/future, ex falso variants) |
| `knownInvalidFormulas` | `List Formula` | 20 curated non-theorems (bare atoms, non-valid modal/temporal formulas, contradictions) |
| `ConformanceResult` | `structure` | `formula`, `expected`, `actual`, `passed` |
| `runConformanceTests` | `IO Bool` | Run both curated test sets, print [PASS]/[FAIL] per formula |
| `DiversityReport` | `structure` | `totalFormulas`, `validCount`, `invalidCount`, `timeoutCount`, `provabilityRatio`, `operatorDistribution`, `modalDepthDistribution`, `temporalDepthDistribution`, `proofHeightMean/Variance/Max` |
| `computeDiversityReport` | `List LabeledFormula → DiversityReport` | Full diversity computation with proof height statistics |
| `FeasibilityResult` | `structure` | `passed`, `totalFormulas`, `provabilityRatio`, `proofHeightVariance`, `categoryDistribution`, `failReasons` |
| `evaluateGate` | `DiversityReport → Nat → Nat → FeasibilityResult` | Evaluate gate criteria (see below) |
| `runFeasibilityGate` | `EnumConfig → String → IO FeasibilityResult` | Enumerate + label + compute diversity + evaluate gate |
| `runFullValidation` | `IO Unit` | Combined entry point: conformance tests + feasibility gate on `smallConfig` |
| `main` | `IO Unit` | Calls `runFullValidation` |

**Feasibility gate criteria** (pass requires all hard criteria):
- Total formulas >= `hardMinFormulas` (default: `config.maxSize`)
- Provability ratio in [0.15, 0.70]
- Proof height variance > 2.0
- At least 3 GoalCategory types each account for > 10% of formulas
- Fail if > 80% trivially propositional
- Fail if > 90% same decision

---

### 8. Python Helper: `scripts/generate_dataset.py`

**Purpose**: Converts the structured JSON dataset produced by `DatasetExporter.lean` into PyTorch `.pt` tensors (or numpy `.npz` fallback) for ML training.

**Input**: JSON file from `DatasetExporter` (single `{"metadata": ..., "formulas": [...]}` object)
**Output**: PyTorch tensor dict with `features` (float32, N×5), `labels` (int64), `heights` (float32)

**Feature vector** (5 dimensions from `PatternKey`):
```
[modalDepth, temporalDepth, impCount, complexity, topOperator_encoded]
```

**Label encoding**: `valid=1`, `invalid=0`, `timeout=-1`

**TopOperator encoding**: Atom=0, Bottom=1, Implication=2, Box=3, AllPast=4, AllFuture=5, Until=6, Since=7

**Usage**:
```bash
python scripts/generate_dataset.py data/training_dataset.json data/training.pt
python scripts/generate_dataset.py data/eval_dataset.json data/eval.pt
```

**Note**: This script reads the JSON format from `DatasetExporter.lean`, not the JSONL format from `DatasetExport.lean`. These are two complementary export paths.

---

### 9. Executable Targets (lakefile.lean)

```lean
-- Dataset generator executable
lean_exe dataset_generator where
  root := `Bimodal.Automation.DatasetExport
  srcDir := "Theories"
  supportInterpreter := true

-- Dataset validator executable
lean_exe dataset_validator where
  root := `Bimodal.Automation.DatasetValidator
  srcDir := "Theories"
  supportInterpreter := true
```

**Usage**:
```bash
# Generate JSONL dataset
lake exe dataset_generator -- --max-complexity 5 --output data/bmlogic.jsonl

# Run conformance tests + feasibility gate
lake exe dataset_validator
```

---

### 10. Pipeline Flow

```
FormulaEnumerator.lean
  ├── enumerateUpToDepth (config: EnumConfig) → List Formula
  └── generateFormulas (params: EnumParams) → IO (List Formula)
              │
              ▼
DatasetGenerator.lean
  ├── labelFormula: Formula → IO LabeledFormula
  │     ├── decideAuto (wall-clock timed)
  │     ├── decideOptimized (retry on timeout)
  │     ├── extractProofTrace → ProofTrace
  │     └── SimpleCountermodel (from decision result)
  └── labelBatch: List Formula → IO (List LabeledFormula)
              │
              ├──────────────────────────────────┐
              ▼                                  ▼
DatasetExport.lean                    DatasetExporter.lean
(JSONL output, lake exe)              (JSON output, Python pipeline)
  ├── writeDatasetJSONL               ├── exportDatasetJson
  ├── writeMetadata                   ├── splitDataset (80/20)
  └── main (CLI)                      └── generateAndExportDataset
              │                                  │
              ▼                                  ▼
  data/bmlogic.jsonl              data/training_dataset.json
  data/bmlogic_metadata.json      data/eval_dataset.json
              │                                  │
              ├──────────────────────────────────┤
              ▼                                  ▼
  BimodalHarness/data/bimodal/   scripts/generate_dataset.py
  (synced via make sync-data)      → data/training.pt / eval.pt
```

Additionally, `EnrichedCountermodel.lean` provides an alternative countermodel extraction path that retains the full saturated branch (richer corrective signal), accessible via `findEnrichedCountermodel`.

---

### 11. Connection to BimodalHarness

[BimodalHarness](https://github.com/benbrastmckie/BimodalHarness) is an AlphaZero-style proof search training harness (Python, Shell, PyTorch). The integration is **artifact-only**: BimodalHarness never invokes Lean at runtime.

**Integration mechanism**:
1. `lake exe dataset_generator` produces JSONL files in `BimodalLogic/data/`
2. `make sync-data BIMODAL_LOGIC_PATH=<path>` rsyncs them to `BimodalHarness/data/bimodal/`
3. BimodalHarness reads JSONL via `bimodal_harness.schema.serialization.read_jsonl()`

**BimodalHarness directory structure** (relevant to integration):
```
src/bimodal_harness/
  schema/
    records.py      — Python dataclasses mirroring Lean types (TrainingRecord, PatternKey, RuleProfile, etc.)
    serialization.py — JSONL read/write with camelCase↔snake_case mapping
    constants.py    — SCHEMA_VERSION, VALID_LABELS, VALID_TOP_OPERATORS
    validation.py   — Schema conformance checks
  lean/
    bridge.py       — Bridge interface (currently stub)
  training/
    loop.py         — Training loop
    online.py       — Online learning
  models/           — Neural network architectures (policy, value networks)
  search/           — MCTS proof search
  z3/               — Z3 countermodel generation (via ModelChecker)
```

**Schema contract**: The JSONL schema is the integration boundary. When BimodalLogic changes its export format, `SCHEMA_VERSION` in `BimodalHarness/data/VERSION` must be bumped and `schema/records.py` updated.

**Python dataclass correspondence** (from `schema/records.py`):
| Python class | Lean type |
|---|---|
| `TrainingRecord` | `LabeledFormula` (conceptual) |
| `PatternKey` | `Bimodal.Automation.PatternKey` |
| `RuleProfile` | `Bimodal.Automation.DataExport.RuleProfile` |
| `ProofTrace` | `ProofTrace` from `DatasetGenerator` |
| `SimpleCountermodel` | `Bimodal.Metalogic.Decidability.SimpleCountermodel` |
| `DifficultyMetrics` | `DifficultyMetrics` from `DatasetGenerator` |

**Downstream tasks in BimodalHarness using pipeline output**:
- Task 4: Tokenizer — reads `FormulaNode` AST to build token vocabulary
- Task 5: Text serializer — serializes formula AST to natural-language string
- Task 7: PyTorch Dataset — loads JSONL via `load_jsonl()`
- Task 10: MCTS — uses `LabeledFormula` for proof state representation
- Task 19: Z3 countermodel generation — uses `BimodalSemantics` (ModelChecker) for INVALID candidates

---

### 12. Validation Results (Tier 1)

From `specs/201_alphazero_proof_search_harness/reports/03_tier1-validation.md`:

**Conformance tests**: 30/30 passed
- 10/10 known valid formulas (BX axiom instances) correctly decided `.valid`
- 20/20 known invalid formulas (non-theorems) correctly decided `.invalid`

**Feasibility gate (small config: 2,2,8,3-atoms)**: FAILED
| Criterion | Target | Actual | Result |
|---|---|---|---|
| Distinct formulas >= 1K | >= 1,000 | 254,252 | PASS |
| Provability ratio | 0.15–0.70 | 0.033 | FAIL |
| Proof height variance | > 2.0 | 0.0 | FAIL |
| >= 3 categories > 10% | >= 3 | 4 | PASS |
| < 80% propositional | < 80% | 35.9% | PASS |
| < 90% same decision | < 90% | 92.6% | FAIL |

**Root causes of gate failure**:
1. Random enumeration overwhelmingly produces non-theorems (expected: most random bimodal formulas are not tautologies)
2. Proof heights are 0 for all valid formulas — tableau-generated proofs have uniform shallow structure
3. Category diversity is good (4 categories > 10%), but provability imbalance dominates

---

## Decisions

- The pipeline uses two parallel export paths: `DatasetExport.lean` (JSONL streaming, CLI executable) and `DatasetExporter.lean` (structured JSON with metadata). Both are maintained; BimodalHarness consumes the JSONL path.
- `EnrichedCountermodel.lean` is implemented but not yet wired into the main export pipeline — it is available for Tier 2 when richer corrective signal is needed.
- The `scripts/generate_dataset.py` Python helper targets the JSON (not JSONL) output format, suggesting it was designed for the `DatasetExporter.lean` path specifically.

---

## Risks & Mitigations

- **Provability ratio imbalance**: 3.2% valid formulas is well below the 15% minimum. Mitigation: theorem mining (generate from known-valid templates), smaller formula sizes (complexity ≤ 4 has higher propositional tautology density), or biased sampling.
- **Proof height uniformity**: Tableau-generated proofs have height 0 for all valid formulas. Mitigation: investigate extractProofTrace behavior with tableau trees, or use tableau branch depth as proxy.
- **Schema drift between repos**: BimodalLogic owns the JSONL schema; BimodalHarness must update `schema/records.py` when tags change. Mitigation: explicit `SCHEMA_VERSION` in `data/VERSION` and update protocol documented in `docs/architecture/cross-repo-integration.md`.
- **Note on `box` JSON tag**: The BimodalHarness `cross-repo-integration.md` shows `{"tag": "box", "child": ..., "event": ...}` while `DataExport.lean` produces `{"tag": "box", "child": ...}` (no `event` field). This may reflect an older or future schema version — should be verified before Tier 2 data sync.

---

## Context Extension Recommendations

- **Topic**: Training pipeline documentation
- **Gap**: No `.claude/context/` entry documents the dual-signal pipeline architecture or the BimodalHarness integration pattern
- **Recommendation**: Add a context file `project/pipeline/training-pipeline.md` summarizing the 6-module architecture, JSONL schema, and cross-repo sync workflow for use in future implementation or documentation tasks
