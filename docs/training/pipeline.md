# BimodalLogic Training Data Pipeline

**Last Updated**: 2026-05-29
**Provenance**: Tasks 201 (alphazero_proof_search_harness), 203 (formula_enumerator_dataset_export), 209 (document_training_pipeline)

---

## Overview

The BimodalLogic repository contains a complete, Lean-native training data pipeline for the TM bimodal logic (combining S5 modal logic with linear temporal logic). The pipeline transforms the formal proof system into machine-learning–ready datasets for training an AlphaZero-style proof search assistant.

The pipeline is implemented in 6 Lean modules under `Theories/Bimodal/Automation/`, compiled to two `lake exe` executables, and supplemented by a Python tensor converter script. Together these components enumerate formulas, decide their validity using the formal decision procedure, extract proof traces and countermodels, and export the results as JSONL or structured JSON files.

The downstream consumer is [BimodalHarness](https://github.com/benbrastmckie/BimodalHarness), an AlphaZero-style Python training harness containing the policy network, value network, and MCTS proof search engine. The integration between the two repositories is **artifact-only**: BimodalHarness never calls Lean at runtime. Instead, it reads JSONL files exported by `lake exe dataset_generator` and synced via `make sync-data`.

A Tier 1 feasibility gate (small config, 2/2/8/3-atoms) confirmed that the pipeline is functionally complete and correctly implements the dual-signal architecture. The gate also identified a provability ratio imbalance (3.2% valid vs 15% minimum) that motivates theorem-mining techniques in Tier 2.

---

## Architecture: Dual-Signal Training Data

The pipeline produces **dual-signal** training data: two complementary supervisory signals that train the two neural networks in BimodalHarness.

### Positive Signal: Proof Traces (Policy Network)

For each formula decided as valid (a theorem of TM), the pipeline extracts a `ProofTrace` from the derivation tree:
- **height**: Maximum depth of the proof tree
- **axioms_used**: Names of axiom schemata applied (e.g., `modal_t`, `prop_k`, `bx_until`)
- **rules_applied**: Names of inference rules used (e.g., `modus_ponens`, `necessitation`)

The policy network learns to predict *which axioms and rules to apply* at each step of a proof search. Proof traces are its supervision signal.

### Corrective Signal: Countermodels (Value Network)

For each formula decided as invalid (a non-theorem), the pipeline extracts a `SimpleCountermodel`:
- **trueAtoms**: Atoms that are true in the countermodel
- **falseAtoms**: Atoms that are false in the countermodel
- **formula**: The refuted formula

The value network learns to estimate the probability that a given proof state leads to a valid proof. Countermodels are its corrective signal: they teach the network which formula shapes are *not* theorems.

### Enriched Corrective Signal (Available, Not Yet Wired In)

`EnrichedCountermodel.lean` provides a richer variant that retains the full saturated branch from the tableau, including which modal and temporal subformulas held or failed. This gives the value network deeper insight into *why* a formula is invalid. It is implemented and tested but not yet integrated into the main export pipeline (targeted for Tier 2).

---

## Pipeline Flow

```
FormulaEnumerator.lean
  enumerateUpToDepth(config: EnumConfig) -> List Formula       [exhaustive]
  generateFormulas(params: EnumParams) -> IO (List Formula)    [random/hybrid]
                |
                v
DatasetGenerator.lean
  labelFormula: Formula -> IO LabeledFormula
    ├── decideAuto        (wall-clock timed, auto fuel by complexity)
    ├── decideOptimized   (retry on timeout)
    ├── extractProofTrace -> ProofTrace     (if valid)
    └── SimpleCountermodel                  (if invalid)
  labelBatch: List Formula -> IO (List LabeledFormula)
                |
      .---------+----------.
      v                    v
DatasetExport.lean         DatasetExporter.lean
(JSONL, lake exe)          (JSON, Python pipeline)
  writeDatasetJSONL          exportDatasetJson
  writeMetadata              splitDataset (80/20 stratified)
  main (CLI)                 generateAndExportDataset
      |                                |
      v                                v
data/bmlogic.jsonl         data/training_dataset.json
data/bmlogic_metadata.json data/eval_dataset.json
      |                                |
      +----------.   .----------------+
                 v   v
    BimodalHarness/data/bimodal/   scripts/generate_dataset.py
    (synced via make sync-data)      -> data/training.pt / eval.pt
```

`EnrichedCountermodel.lean` provides an alternative countermodel path that retains the full saturated branch. It is accessible via `findEnrichedCountermodel` and targeted for Tier 2 integration.

---

## Module Reference

### `DataExport.lean`

**Path**: `Theories/Bimodal/Automation/DataExport.lean`
**Namespace**: `Bimodal.Automation.DataExport`
**Role**: JSON serialization primitives for all core types. No external JSON library — uses string concatenation with proper escaping. This module is a dependency of all other pipeline modules.

#### Key API

| Name | Signature | Description |
|------|-----------|-------------|
| `escapeJsonString` | `String -> String` | Escape `"` and `\` for JSON string values |
| `listToJsonArray` | `List String -> String` | Wrap strings as a JSON array `[...]` |
| `Atom.toJson` | `Atom -> String` | `{"base": "p", "fresh_index": null}` |
| `Formula.toJson` | `Formula -> String` | Recursive formula AST as JSON with `"tag"` field |
| `Formula.prettyPrint` | `Formula -> String` | Human-readable notation (→, □, U, S) |
| `GoalCategory.toJson` | `GoalCategory -> String` | Category name as quoted JSON string |
| `PatternKey.toJson` | `PatternKey -> String` | 5-field feature vector as JSON object |
| `SimpleCountermodel.toJson` | `SimpleCountermodel -> String` | `trueAtoms`, `falseAtoms`, `formula` |
| `RuleProfile` | `structure` | Counts of 7 derivation rule types from a proof tree walk |
| `RuleProfile.empty` | `RuleProfile` | Zero-initialized rule profile |
| `RuleProfile.merge` | `RuleProfile -> RuleProfile -> RuleProfile` | Sum corresponding rule counts |
| `walkDerivationTree` | `DerivationTree fc Γ φ -> RuleProfile` | Recursively count rule applications |
| `RuleProfile.toJson` | `RuleProfile -> String` | Rule count object as JSON |
| `proofMetricsToJson` | `Nat -> RuleProfile -> String` | `{"height": N, "rules": {...}}` |

#### Formula JSON Schema

The `Formula.toJson` function produces a tagged JSON object with this schema (by constructor):

| Constructor | JSON Output |
|-------------|-------------|
| `atom a` | `{"tag": "atom", "name": "<base>"}` |
| `bot` | `{"tag": "bot"}` |
| `imp φ ψ` | `{"tag": "imp", "left": <φ>, "right": <ψ>}` |
| `box φ` | `{"tag": "box", "child": <φ>}` |
| `untl φ ψ` | `{"tag": "untl", "event": <φ>, "guard": <ψ>}` |
| `snce φ ψ` | `{"tag": "snce", "event": <φ>, "guard": <ψ>}` |

The `prettyPrint` function uses: `→` for implication, `□` for box, `U(φ, ψ)` for until, `S(φ, ψ)` for since, `⊥` for bottom.

#### `RuleProfile` Structure

The `RuleProfile` structure counts applications of the 7 inference rule constructors in `DerivationTree`:

```
RuleProfile ::= {
  axiomCount              -- .axiom _ _ _ _
  assumptionCount         -- .assumption _ _ _
  mpCount                 -- .modus_ponens _ _ _ d1 d2
  necessitationCount      -- .necessitation _ d
  temporalNecessitationCount  -- .temporal_necessitation _ d
  temporalDualityCount    -- .temporal_duality _ d
  weakeningCount          -- .weakening _ _ _ d _
}
```

#### Design Notes

All serialization is pure string manipulation — no `import Json` or external dependency. `RuleProfile` avoids the need to serialize the full dependent-type proof tree by counting rules via a tree walk (`walkDerivationTree`).

---

### `FormulaEnumerator.lean`

**Path**: `Theories/Bimodal/Automation/FormulaEnumerator.lean`
**Namespace**: `Bimodal.Automation`
**Role**: Bounded enumeration of TM bimodal logic formulas. Provides both exhaustive enumeration (for small complexity bounds) and deterministic pseudo-random sampling (for larger spaces). Contains two APIs: the plan-specified API (Task 201) and a legacy API (Task 203).

#### Plan-Specified API (Task 201): EnumConfig

| Name | Signature | Description |
|------|-----------|-------------|
| `EnumConfig` | `structure` | `maxModalDepth`, `maxTemporalDepth`, `maxSize`, `atomPool` |
| `defaultAtomPool` | `List Atom` | 5 atoms: p, q, r, s, t |
| `smallConfig` | `EnumConfig` | depth 2/2, size 8, 3 atoms — suitable for exhaustive enumeration |
| `mediumConfig` | `EnumConfig` | depth 3/3, size 12, 5 atoms — larger space for sampling |
| `enumerateUpToDepth` | `EnumConfig -> List Formula` | Exhaustive enumeration with deduplication |
| `sampleFormulas` | `EnumConfig -> Nat -> Nat -> List Formula` | Deterministic LCG-based sampling |
| `LCGState` | `structure` | glibc LCG state (a=1103515245, c=12345, m=2³¹) |
| `DiversitySummary` | `structure` | Operator distribution, depth histograms, category counts |
| `diversitySummary` | `List Formula -> DiversitySummary` | Compute diversity metrics over a formula list |

#### Legacy API (Task 203): EnumParams

| Name | Signature | Description |
|------|-----------|-------------|
| `SamplingMode` | `inductive` | `.exhaustive` / `.random` / `.hybrid` |
| `EnumParams` | `structure` | `maxComplexity`, `maxModalDepth`, `maxTemporalDepth`, `atoms`, `maxFormulas`, `samplingMode` |
| `enumerateExhaustive` | `EnumParams -> List Formula` | Exhaustive via budget recursion |
| `sampleRandom` | `EnumParams -> IO (List Formula)` | IO-based random generation |
| `enrichWithDuals` | `List Formula -> List Formula` | Free 2x augmentation via `swap_temporal` |
| `generateFormulas` | `EnumParams -> IO (List Formula)` | Dispatch by `SamplingMode` |
| `DiversityReport` | `structure` | `GoalCategory` counts, modal/temporal depth buckets |
| `computeDiversity` | `List Formula -> DiversityReport` | Legacy diversity computation |

#### Design Notes

- **Three simultaneous constraints**: `enumerateUpToDepth` bounds modal depth, temporal depth, and total size independently. This prevents runaway in any single dimension.
- **Deterministic sampling**: `sampleFormulas` uses a linear congruential generator (LCG). The same seed always produces the same formulas, enabling reproducible experiments.
- **Deduplication**: `enumerateUpToDepth` calls `List.eraseDups` using the `BEq Formula` instance.
- **Filter**: `passesFilter` rejects pure propositional formulas and formulas with complexity < 3, ensuring every formula involves at least one modal or temporal operator.

---

### `DatasetGenerator.lean`

**Path**: `Theories/Bimodal/Automation/DatasetGenerator.lean`
**Namespace**: `Bimodal.Automation`
**Role**: The labeling pipeline. Runs the formal `DecisionProcedure.decide` on enumerated formulas, extracts proof traces and countermodels, computes difficulty metrics, and produces `LabeledFormula` records.

#### Key API

| Name | Signature | Description |
|------|-----------|-------------|
| `ProofTrace` | `structure` | `height : Nat`, `axioms_used : List String`, `rules_applied : List String` |
| `DifficultyMetrics` | `structure` | `complexity`, `modalDepth`, `temporalDepth`, `impCount`, `atomCount`, `decisionTimeMs`, `difficultyTier` |
| `FormulaLabel` | `inductive` | `.valid` / `.invalid` / `.timeout` |
| `LabeledFormula` | `structure` | `formula`, `label`, `proofTrace`, `countermodel`, `metrics`, `patternKey` |
| `extractAxiomName` | `Axiom φ -> String` | Convert all 41 axiom constructors to string names |
| `extractProofTrace` | `DerivationTree fc Γ φ -> ProofTrace` | Recursive tree walk: collect height, axiom names, rule names |
| `computeMetrics` | `Formula -> Nat -> DifficultyMetrics` | Structural metrics + difficulty tier assignment |
| `labelFormula` | `Formula -> IO LabeledFormula` | Run `decideAuto`; retry with `decideOptimized` on timeout |
| `labelBatch` | `List Formula -> IO (List LabeledFormula)` | Batch labeling with progress report every 100 formulas |
| `BatchStats` | `structure` | `totalCount`, `validCount`, `invalidCount`, `timeoutCount`, `avgTimeMs` |
| `computeBatchStats` | `List LabeledFormula -> BatchStats` | Aggregate statistics over a labeled batch |
| `LabeledFormula.toJson` | `LabeledFormula -> String` | Complete JSON with formula AST, features, decision, proof/countermodel, metrics |

#### Labeling Logic

For each formula, `labelFormula`:
1. Records wall-clock start time via `IO.monoMsNow`
2. Calls `decideAuto` with fuel proportional to formula complexity
3. On timeout, retries with `decideOptimized`
4. Produces one of:
   - `valid proof` → extracts `ProofTrace` from the derivation tree
   - `invalid cm` → keeps the `SimpleCountermodel`
   - `timeout` → records metrics only, no proof or countermodel

#### Difficulty Tiers

| Tier | Complexity Range |
|------|-----------------|
| `easy` | complexity ≤ 3 |
| `medium` | complexity ≤ 6 |
| `hard` | complexity ≤ 9 |
| `very_hard` | complexity > 9 |

---

### `EnrichedCountermodel.lean`

**Path**: `Theories/Bimodal/Automation/EnrichedCountermodel.lean`
**Namespace**: `Bimodal.Automation.Enriched`
**Role**: Extends `SimpleCountermodel` (atom truth assignments only) with the full saturated branch from the tableau, providing a richer corrective signal for the value network.

#### Key API

| Name | Signature | Description |
|------|-----------|-------------|
| `EnrichedCountermodel` | `structure` | `simple`, `branchFormulas`, `modalFormulas`, `temporalFormulas`, `branchLength` |
| `isModalFormula` | `SignedFormula -> Bool` | True if top-level is `box` or `imp (.box _) _` |
| `isTemporalFormula` | `SignedFormula -> Bool` | True if top-level is `untl` or `snce` |
| `extractModalFormulas` | `Branch -> List SignedFormula` | Filter branch for modal signed formulas |
| `extractTemporalFormulas` | `Branch -> List SignedFormula` | Filter branch for temporal signed formulas |
| `extractEnrichedCountermodel` | `Formula -> Branch -> EnrichedCountermodel` | Build from formula and raw saturated branch |
| `EnrichedCountermodelResult` | `inductive` | `.found ecm` / `.valid` / `.failed reason` |
| `findEnrichedCountermodel` | `Formula -> Nat -> EnrichedCountermodelResult φ` | Run `buildTableau` and extract enriched data |
| `SignedFormula.toJson` | `SignedFormula -> String` | `{"sign": "pos"/"neg", "formula": ...}` |
| `EnrichedCountermodel.toJson` | `EnrichedCountermodel -> String` | Full enriched countermodel as JSON |

#### Design Rationale

`SimpleCountermodel` discards the saturated branch after extracting atom truth values. `EnrichedCountermodel` retains the full branch so the value network can learn *why* a formula is invalid — specifically, which modal subformulas (box patterns) and temporal subformulas (untl/snce patterns) were the obstruction. This richer corrective signal is expected to produce better-calibrated value estimates in Tier 2.

**Current status**: Implemented, tested, and producing correct JSON output. Not yet wired into the main export path (DatasetExport.lean or DatasetExporter.lean). Targeted for Tier 2 integration.

---

### `DatasetExporter.lean`

**Path**: `Theories/Bimodal/Automation/DatasetExporter.lean`
**Namespace**: `Bimodal.Automation.DatasetExporter`
**Role**: Assembles labeled formulas into a structured JSON dataset file with metadata, statistics, and a deterministic stratified train/eval split. This is the Python pipeline's primary input format.

#### Key API

| Name | Signature | Description |
|------|-----------|-------------|
| `EnumConfig.toJson` | `EnumConfig -> String` | `{"maxModalDepth": N, "maxTemporalDepth": N, "maxSize": N, "atomCount": N}` |
| `BatchStats.toJson` | `BatchStats -> String` | `{"totalCount": N, "validCount": N, ...}` |
| `DatasetMetadata` | `structure` | `generator`, `version`, `config`, `stats`, `frameClass` |
| `DatasetMetadata.toJson` | `DatasetMetadata -> String` | Full metadata JSON object |
| `exportDatasetJson` | `DatasetMetadata -> List LabeledFormula -> String` | Complete dataset JSON with sequential `id` fields |
| `writeDataset` | `String -> String -> IO Unit` | Write string content to a file path |
| `splitDataset` | `List LabeledFormula -> Float -> (List LabeledFormula × List LabeledFormula)` | Deterministic stratified train/eval split (default 0.8) |
| `generateAndExportDataset` | `EnumConfig -> String -> IO Unit` | End-to-end: enumerate → label → export → write |
| `generateSplitDatasets` | `EnumConfig -> String -> String -> Float -> IO Unit` | End-to-end with separate train and eval outputs |

#### Structured JSON Output Schema

```json
{
  "metadata": {
    "generator": "BimodalLogic/DatasetExporter",
    "version": "1.0",
    "config": {
      "maxModalDepth": 3,
      "maxTemporalDepth": 3,
      "maxSize": 12,
      "atomCount": 5
    },
    "statistics": {
      "totalCount": 1234,
      "validCount": 45,
      "invalidCount": 1150,
      "timeoutCount": 39,
      "avgTimeMs": 12
    },
    "frameClass": "Base"
  },
  "formulas": [
    {
      "id": 0,
      "formula": {"tag": "imp", "left": {"tag": "box", "child": {"tag": "atom", "name": "p"}}, "right": {"tag": "atom", "name": "p"}},
      "formula_string": "(□p → p)",
      "features": {"modalDepth": 1, "temporalDepth": 0, "impCount": 1, "complexity": 3, "topOperator": "Implication"},
      "decision": "valid",
      "proof": {"height": 0, "axioms_used": ["modal_t"], "rules_applied": []},
      "countermodel": null,
      "metrics": {"complexity": 3, "modalDepth": 1, "temporalDepth": 0, "impCount": 1, "atomCount": 1, "decisionTimeMs": 2, "difficultyTier": "easy"}
    }
  ]
}
```

#### Split Strategy

`splitDataset` performs deterministic stratified splitting by label. Within each stratum (valid/invalid/timeout), the first `floor(n × ratio)` records go to the train set and the remainder go to the eval set. The default ratio is 0.8 (80% train, 20% eval).

---

### `DatasetExport.lean`

**Path**: `Theories/Bimodal/Automation/DatasetExport.lean`
**Namespace**: `Bimodal.Automation.DatasetExport`
**Role**: JSONL streaming output, CLI argument parsing, and the `main` function for the `lake exe dataset_generator` executable. This is the BimodalHarness-facing export path.

**Note**: This module is distinct from `DataExport.lean` (the JSON serialization primitives). Despite the similar name, `DatasetExport.lean` is the CLI executable entry point, while `DataExport.lean` provides the underlying serialization library.

#### Key API

| Name | Signature | Description |
|------|-----------|-------------|
| `AugmentationInfo` | `structure` | `source`, `originalFormulaStr` — tracks temporal dual provenance |
| `DatasetRecord` | `structure` | Complete export-ready record matching the JSONL schema |
| `datasetRecordToJson` | `DatasetRecord -> String` | One-line JSON serialization of a single record |
| `labeledToRecord` | `Nat -> String -> LabeledFormula -> DatasetRecord` | Convert from `LabeledFormula` with zero-padded `id` |
| `assignSplit` | `String -> String` | Deterministic 80/10/10 train/val/test split via hash bucket |
| `writeRecordJSONL` | `IO.FS.Handle -> DatasetRecord -> IO Unit` | Write one record as a single JSON line |
| `writeDatasetJSONL` | `System.FilePath -> List LabeledFormula -> IO Nat` | Stream all records to a JSONL file; returns record count |
| `DatasetMetadata` | `structure` | Dataset-level statistics for the companion `_metadata.json` file |
| `computeDatasetMetadata` | `List LabeledFormula -> EnumParams -> Bool -> DatasetMetadata` | Aggregate metadata |
| `datasetMetadataToJson` | `DatasetMetadata -> String` | Pretty-print metadata JSON |
| `writeMetadata` | `System.FilePath -> DatasetMetadata -> IO Unit` | Write companion `_metadata.json` |
| `CLIArgs` | `structure` | Parsed CLI arguments |
| `parseCLIArgs` | `List String -> CLIArgs` | Parse all CLI flags |
| `main` | `List String -> IO Unit` | CLI entry point for `lake exe dataset_generator` |

#### JSONL Record Schema

Each line of the output file is one JSON object:

```json
{
  "id": "bmlogic-00001",
  "split": "train",
  "formula_str": "(□p → p)",
  "formula_ast": {"tag": "imp", "left": {"tag": "box", "child": {"tag": "atom", "name": "p"}}, "right": {"tag": "atom", "name": "p"}},
  "frame_class": "Base",
  "label": "valid",
  "proof_trace": {
    "height": 0,
    "axioms_used": ["modal_t"],
    "rules_applied": []
  },
  "countermodel": null,
  "pattern_key": {"modalDepth": 1, "temporalDepth": 0, "impCount": 1, "complexity": 3, "topOperator": "Implication"},
  "metrics": {"complexity": 3, "modalDepth": 1, "temporalDepth": 0, "impCount": 1, "atomCount": 1, "decisionTimeMs": 2, "difficultyTier": "easy"},
  "augmentation": null
}
```

Split assignment (`assignSplit`) uses hash bucketing for deterministic 80/10/10 train/val/test allocation, unlike the `DatasetExporter.lean` 80/20 train/eval split.

---

### `DatasetValidator.lean`

**Path**: `Theories/Bimodal/Automation/DatasetValidator.lean`
**Namespace**: `Bimodal.Automation.DatasetValidator`
**Role**: Quality assurance for the pipeline. Validates correctness via conformance tests (known valid/invalid formulas) and evaluates dataset readiness for training via a feasibility gate. Provides the `main` entry point for `lake exe dataset_validator`.

#### Key API

| Name | Signature | Description |
|------|-----------|-------------|
| `knownValidFormulas` | `List Formula` | 10 curated BX axiom instances (propositional, modal, temporal, mixed) |
| `knownInvalidFormulas` | `List Formula` | 20 curated non-theorems (atoms, non-valid modal/temporal formulas, contradictions) |
| `ConformanceResult` | `structure` | `formula`, `expected`, `actual`, `passed` |
| `runConformanceTests` | `IO Bool` | Run both curated test sets; print `[PASS]`/`[FAIL]` per formula |
| `DiversityReport` | `structure` | `totalFormulas`, `validCount`, `invalidCount`, `timeoutCount`, `provabilityRatio`, `operatorDistribution`, `modalDepthDistribution`, `temporalDepthDistribution`, `proofHeightMean/Variance/Max` |
| `computeDiversityReport` | `List LabeledFormula -> DiversityReport` | Full diversity computation including proof height statistics |
| `FeasibilityResult` | `structure` | `passed`, `totalFormulas`, `provabilityRatio`, `proofHeightVariance`, `categoryDistribution`, `failReasons` |
| `evaluateGate` | `DiversityReport -> Nat -> Nat -> FeasibilityResult` | Evaluate all gate criteria; collect fail reasons |
| `runFeasibilityGate` | `EnumConfig -> String -> IO FeasibilityResult` | Enumerate + label + compute diversity + evaluate gate |
| `runFullValidation` | `IO Unit` | Combined: conformance tests + feasibility gate on `smallConfig` |
| `main` | `IO Unit` | Calls `runFullValidation` |

#### Feasibility Gate Criteria

The gate passes only when **all** hard criteria are satisfied:

| Criterion | Threshold | Hard? |
|-----------|-----------|-------|
| Total distinct formulas | >= 1,000 | Hard |
| Provability ratio (valid / total) | 0.15 to 0.70 | Hard |
| Proof height variance | > 2.0 | Hard |
| Categories with > 10% share | >= 3 | Hard |
| Trivially propositional formulas | < 80% | Hard |
| Formulas with same decision | < 90% | Hard |

`knownValidFormulas` covers: propositional K, weakening S, ex falso, Peirce's law, modal T, modal 4, modal K-distribution, modal future (MF), and two variants. `knownInvalidFormulas` covers: bare atoms, non-valid implications, `box p`, `diamond p`, `F(p)`, `P(p)`, contradictions, and temporal formulas.

---

## Executable Targets

Two `lake exe` targets are registered in `lakefile.lean`:

```lean
lean_exe dataset_generator where
  root := `Bimodal.Automation.DatasetExport
  srcDir := "Theories"
  supportInterpreter := true

lean_exe dataset_validator where
  root := `Bimodal.Automation.DatasetValidator
  srcDir := "Theories"
  supportInterpreter := true
```

### `lake exe dataset_generator`

Generates a JSONL dataset via the `DatasetExport.lean` CLI.

```
lake exe dataset_generator -- [OPTIONS]

  --max-complexity N      Maximum formula complexity/connective count (default: 5)
  --max-modal-depth N     Maximum modal operator nesting depth (default: 2)
  --max-temporal-depth N  Maximum temporal operator nesting depth (default: 2)
  --max-formulas N        Maximum formulas to generate (default: 5000)
  --output PATH           Output JSONL file path (default: data/bmlogic.jsonl)
  --mode MODE             Sampling mode: exhaustive|random|hybrid (default: exhaustive)
  --include-duals         Include temporal dual augmentation via swap_temporal
```

**Output files** (both written by default):
- `<output>` — JSONL file, one record per line
- `<output>_metadata.json` — Companion metadata JSON (counts, config, distributions)

**Example**:
```bash
# Quick test with defaults
lake exe dataset_generator

# Medium production run with explicit parameters
lake exe dataset_generator -- \
  --max-complexity 8 \
  --max-modal-depth 3 \
  --max-temporal-depth 3 \
  --max-formulas 50000 \
  --output data/bmlogic_medium.jsonl \
  --mode hybrid \
  --include-duals
```

### `lake exe dataset_validator`

Runs conformance tests and the feasibility gate via `DatasetValidator.lean`.

```bash
lake exe dataset_validator
```

**Output**: Per-formula pass/fail for conformance tests, then tabulated feasibility gate results with pass/fail per criterion and aggregated decision.

---

## Python Tensor Converter

**Path**: `scripts/generate_dataset.py`
**Input**: Structured JSON file from `DatasetExporter.lean` (single `{"metadata": ..., "formulas": [...]}` object)
**Output**: PyTorch `.pt` tensor dict (or NumPy `.npz` fallback if PyTorch is unavailable)

**Note**: This script reads the **JSON format** from `DatasetExporter.lean`, not the JSONL format from `DatasetExport.lean`. The two export paths are complementary: JSONL for BimodalHarness streaming, JSON for Python tensor conversion.

### Feature Vector (5 dimensions from `PatternKey`)

```
features[i] = [
    modalDepth,           # int: modal operator nesting depth
    temporalDepth,        # int: temporal operator nesting depth
    impCount,             # int: number of implication operators
    complexity,           # int: total connective count
    topOperator_encoded   # int: encoded top-level operator (see below)
]
```

### Encoding Tables

**TopOperator encoding**:

| Operator | Code |
|----------|------|
| Atom | 0 |
| Bottom | 1 |
| Implication | 2 |
| Box | 3 |
| AllPast | 4 |
| AllFuture | 5 |
| Until | 6 |
| Since | 7 |

**Label encoding**:

| Decision | Code |
|----------|------|
| `valid` | 1 |
| `invalid` | 0 |
| `timeout` | -1 |

### Output Tensor Dict

```python
{
    "features": Tensor[N, 5],   # float32 feature matrix
    "labels":   Tensor[N],      # int64 decision labels
    "heights":  Tensor[N],      # float32 proof heights (NaN for non-valid)
}
```

### Usage

```bash
# Convert training set
python scripts/generate_dataset.py data/training_dataset.json data/training.pt

# Convert eval set
python scripts/generate_dataset.py data/eval_dataset.json data/eval.pt
```

---

## Dataset Schemas

### JSONL Record Schema (DatasetExport.lean)

Used by `lake exe dataset_generator` and consumed directly by BimodalHarness. Each line is one complete JSON object.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Zero-padded identifier, e.g., `"bmlogic-00001"` |
| `split` | string | `"train"` / `"val"` / `"test"` (80/10/10 by hash) |
| `formula_str` | string | Human-readable formula, e.g., `"(□p → p)"` |
| `formula_ast` | object | Recursive tagged AST (see Formula JSON Schema above) |
| `frame_class` | string | Always `"Base"` in current pipeline |
| `label` | string | `"valid"` / `"invalid"` / `"timeout"` |
| `proof_trace` | object or null | `{"height": N, "axioms_used": [...], "rules_applied": [...]}` for valid; null otherwise |
| `countermodel` | object or null | `{"trueAtoms": [...], "falseAtoms": [...], "formula": {...}}` for invalid; null otherwise |
| `pattern_key` | object | `{"modalDepth": N, "temporalDepth": N, "impCount": N, "complexity": N, "topOperator": "..."}` |
| `metrics` | object | `{"complexity": N, "modalDepth": N, "temporalDepth": N, "impCount": N, "atomCount": N, "decisionTimeMs": N, "difficultyTier": "..."}` |
| `augmentation` | object or null | `{"source": "...", "originalFormulaStr": "..."}` for temporal duals; null otherwise |

### Structured JSON Schema (DatasetExporter.lean)

Used by the Python tensor converter. Single JSON object with metadata and formula array.

**Top-level fields**:

| Field | Type | Description |
|-------|------|-------------|
| `metadata` | object | Generator provenance, config, statistics, frame class |
| `formulas` | array | Ordered array of formula entries |

**`metadata` fields**:

| Field | Type | Description |
|-------|------|-------------|
| `generator` | string | `"BimodalLogic/DatasetExporter"` |
| `version` | string | Schema version, e.g., `"1.0"` |
| `config` | object | `{"maxModalDepth": N, "maxTemporalDepth": N, "maxSize": N, "atomCount": N}` |
| `statistics` | object | `{"totalCount": N, "validCount": N, "invalidCount": N, "timeoutCount": N, "avgTimeMs": N}` |
| `frameClass` | string | `"Base"` |

**Per-formula entry fields**:

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Sequential integer starting from 0 |
| `formula` | object | Tagged AST (same schema as JSONL `formula_ast`) |
| `formula_string` | string | Human-readable formula string |
| `features` | object | `PatternKey` fields: `modalDepth`, `temporalDepth`, `impCount`, `complexity`, `topOperator` |
| `decision` | string | `"valid"` / `"invalid"` / `"timeout"` |
| `proof` | object or null | Proof trace for valid formulas; null otherwise |
| `countermodel` | object or null | Simple countermodel for invalid formulas; null otherwise |
| `metrics` | object | Difficulty metrics |

---

## BimodalHarness Integration

[BimodalHarness](https://github.com/benbrastmckie/BimodalHarness) is an AlphaZero-style Python training harness implementing the policy network, value network, and MCTS proof search engine for TM bimodal logic. The integration between the two repositories is **artifact-only**: BimodalHarness never calls Lean at runtime.

### Sync Mechanism

```bash
# Step 1: Generate JSONL data in BimodalLogic
lake exe dataset_generator -- --output data/bmlogic.jsonl

# Step 2: Sync to BimodalHarness
make sync-data BIMODAL_LOGIC_PATH=/path/to/BimodalLogic
# Internally runs:
#   rsync -av BimodalLogic/data/ BimodalHarness/data/bimodal/

# Step 3: Load in Python
# BimodalHarness reads via:
#   bimodal_harness.schema.serialization.read_jsonl("data/bimodal/bmlogic.jsonl")
```

### Python Dataclass Correspondence

BimodalHarness defines Python dataclasses in `src/bimodal_harness/schema/records.py` that mirror the Lean types:

| Python Class | Lean Type |
|---|---|
| `TrainingRecord` | `LabeledFormula` (conceptual) |
| `PatternKey` | `Bimodal.Automation.PatternKey` |
| `RuleProfile` | `Bimodal.Automation.DataExport.RuleProfile` |
| `ProofTrace` | `ProofTrace` (DatasetGenerator.lean) |
| `SimpleCountermodel` | `Bimodal.Metalogic.Decidability.SimpleCountermodel` |
| `DifficultyMetrics` | `DifficultyMetrics` (DatasetGenerator.lean) |

Serialization (`schema/serialization.py`) handles `camelCase` ↔ `snake_case` field name mapping between the Lean JSON output and Python dataclasses.

### Schema Contract

The JSONL schema is the integration boundary. The `SCHEMA_VERSION` constant in `BimodalHarness/data/VERSION` and `schema/constants.py` must be bumped whenever the export format changes. When the Lean-side schema changes:

1. Increment `SCHEMA_VERSION` in `data/VERSION`
2. Update `schema/records.py` to match new field names or types
3. Update `schema/serialization.py` camelCase mapping if field names changed
4. Update `schema/validation.py` conformance checks

**Open schema note**: The BimodalHarness `cross-repo-integration.md` shows `{"tag": "box", "child": ..., "event": ...}` while `DataExport.lean` produces `{"tag": "box", "child": ...}` (no `event` field). This discrepancy should be resolved before the next data sync.

### BimodalHarness Repository Structure (Integration-Relevant)

```
src/bimodal_harness/
  schema/
    records.py      -- Python dataclasses mirroring Lean types
    serialization.py -- JSONL read/write with camelCase<->snake_case mapping
    constants.py    -- SCHEMA_VERSION, VALID_LABELS, VALID_TOP_OPERATORS
    validation.py   -- Schema conformance checks
  lean/
    bridge.py       -- Bridge interface (currently stub)
  training/
    loop.py         -- Training loop
    online.py       -- Online learning
  models/           -- Policy and value network architectures
  search/           -- MCTS proof search engine
  z3/               -- Z3 countermodel generation (via ModelChecker)
```

### Downstream Tasks Using Pipeline Output

| BimodalHarness Task | Uses |
|--------------------|------|
| Task 4: Tokenizer | Reads `formula_ast` to build token vocabulary |
| Task 5: Text serializer | Serializes `formula_ast` to natural-language string |
| Task 7: PyTorch Dataset | Loads JSONL via `load_jsonl()` |
| Task 10: MCTS | Uses `LabeledFormula`-shaped records for proof state representation |
| Task 19: Z3 countermodel | Uses `BimodalSemantics` (ModelChecker) for INVALID candidates |

---

## Feasibility Gate Results (Tier 1)

### Configuration Tested

Small config: `maxModalDepth=2`, `maxTemporalDepth=2`, `maxSize=8`, 3 atoms (p, q, r).

### Conformance Tests: 30/30 Passed

**Known valid formulas (10/10)**:

| Formula | Result |
|---------|--------|
| (p → (q → r)) → ((p → q) → (p → r)) (propositional K) | PASS |
| p → (q → p) (weakening) | PASS |
| ⊥ → p (ex falso) | PASS |
| ((p → q) → p) → p (Peirce's law) | PASS |
| □p → p (modal T) | PASS |
| □p → □□p (modal 4) | PASS |
| □(p → q) → (□p → □q) (modal K-distribution) | PASS |
| □p → □(Gp) (modal future MF) | PASS |
| ⊥ → q (ex falso variant) | PASS |
| □q → q (modal T on q) | PASS |

**Known invalid formulas (20/20)**: All 20 curated non-theorems (bare atoms, non-valid implications, `box p`, `diamond p`, `F(p)`, `P(p)`, contradictions, temporal formulas) correctly decided `.invalid`.

### Dataset Statistics (Small Config)

| Metric | Value |
|--------|-------|
| Total formulas | 254,252 |
| Valid (theorems) | 8,284 (3.2%) |
| Invalid (non-theorems) | 235,523 (92.6%) |
| Timeout | 10,445 (4.1%) |
| Provability ratio | 0.033 |

### Operator Distribution

| Category | Count | Percentage |
|----------|-------|------------|
| Implication | 91,152 | 35.9% |
| Until | 62,480 | 24.6% |
| Since | 62,480 | 24.6% |
| Box | 38,136 | 15.0% |
| Atom | 3 | < 0.01% |
| Bottom | 1 | < 0.01% |

### Feasibility Gate Results

| Criterion | Target | Actual | Result |
|-----------|--------|--------|--------|
| Distinct formulas >= 1K | >= 1,000 | 254,252 | PASS |
| Provability ratio | 0.15–0.70 | 0.033 | FAIL |
| Proof height variance | > 2.0 | 0.0 | FAIL |
| >= 3 categories > 10% | >= 3 | 4 | PASS |
| < 80% trivially propositional | < 80% | 35.9% | PASS |
| < 90% same decision | < 90% | 92.6% | FAIL |

**Gate decision: FAILED (3 of 6 hard criteria not met)**

### Root Causes

1. **Provability ratio imbalance**: Random exhaustive enumeration overwhelmingly produces non-theorems. This is expected: most randomly constructed bimodal formulas are not tautologies of TM. Only 3.2% are valid vs the 15% minimum.

2. **Proof height uniformity**: The decision procedure constructs proofs via the tableau method. `extractProofTrace` correctly processes the derivation tree, but tableau-generated proofs have a uniform shallow structure, yielding height 0 and zero variance for all valid formulas.

3. **Category concentration**: 92.6% of formulas are invalid, exceeding the 90% cap. This is a consequence of the provability ratio imbalance.

**Note**: Category diversity is good — 4 categories (Implication, Until, Since, Box) each account for > 10% of formulas. The structural diversity of the enumerator is not the issue; the theoremhood imbalance is.

---

## Recommended Next Steps

### Priority 1: Address Provability Ratio (Gate Blocker)

- **Theorem mining**: Generate formulas by composing known axiom instances (apply modus ponens closure to BX axiom schemata). This guarantees new valid formulas at higher complexity.
- **Biased enumeration**: Use a two-pass strategy — first enumerate from known-valid templates with atom replacement, then pad with random formulas to maintain diversity.
- **Smaller formula sizes**: For complexity ≤ 4, propositional tautologies are more common. Focusing on this range increases the provability ratio with minimal code changes.

### Priority 2: Address Proof Height Uniformity (Gate Blocker)

- Investigate `extractProofTrace` behavior with the tableau-generated derivation trees. The tableau decision procedure likely produces flat `DerivationTree` structures that do not encode proof depth.
- Consider using the tableau branch depth as a proxy for proof complexity.
- Alternatively, implement explicit proof reconstruction that builds derivation trees with recorded depth information.

### Priority 3: Integrate EnrichedCountermodel

Wire `EnrichedCountermodel.lean` into the main export path (`DatasetExport.lean` and/or `DatasetExporter.lean`) so that the full saturated branch content is included in exported records. This activates the richer corrective signal for the value network.

### Planned Tasks

| Task | Description |
|------|-------------|
| 204 | Medium and deep production dataset runs (targeted after Tier 2 improvements) |
| 205 | BMLogic-Bench curation (expert-curated benchmark formulas) |
| 206 | Contrastive pair generation (valid/invalid pairs sharing the same formula skeleton) |
| 207 | Multi-representation export (add enriched countermodel and richer proof data) |
| 208 | HuggingFace dataset packaging for BMLogic-Bench |

---

## Related Tasks

| Task | Title | Role |
|------|-------|------|
| 201 | alphazero_proof_search_harness | Built the entire pipeline in 6 phases; Tier 1 feasibility gate |
| 203 | formula_enumerator_dataset_export | Legacy API (EnumParams/SamplingMode) in FormulaEnumerator |
| 204 | medium_deep_production_runs | Larger dataset generation (planned) |
| 205 | bmlogic_bench_curation | Expert benchmark formulas (planned) |
| 206 | contrastive_pair_generation | Valid/invalid formula pairs (planned) |
| 207 | multi_representation_export | EnrichedCountermodel integration (planned) |
| 208 | huggingface_dataset_packaging | HuggingFace distribution (planned) |
| 209 | document_training_pipeline | This document |
