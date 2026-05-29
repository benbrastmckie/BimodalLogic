# Implementation Plan: Task #203

- **Task**: 203 - Build formula enumerator, decider labeling, and JSON dataset export
- **Status**: [NOT STARTED]
- **Effort**: 28 hours
- **Dependencies**: None (builds on existing DecisionProcedure, SuccessPatterns, Formula infrastructure)
- **Research Inputs**: specs/203_formula_enumerator_dataset_export/reports/01_team-research.md
- **Artifacts**: plans/01_formula-enum-dataset.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Build a three-module Lean 4 pipeline under `Theories/Bimodal/Automation/` that enumerates TM formulas at controlled depth, labels them using the existing `DecisionProcedure.decide` function, extracts simplified proof traces, and streams labeled records as JSONL via a compiled Lake executable. The pipeline produces a dataset of 2K-50K labeled formulas (configurable) with proof traces, countermodels, difficulty metrics, and structural pattern keys. A 500-1K held-out benchmark subset validates the system. The boundary is the JSONL file -- everything upstream is pure Lean in this repo.

### Research Integration

The team research report (4 teammates) established key architectural decisions:

1. **Hybrid enumeration**: Exhaustive at complexity <=7 (~60K formulas feasible), grammar-based random sampling above. This avoids the super-exponential blowup (2.5M at complexity 9, 117M at 11).
2. **Compiled executable**: Lake native binary with streaming JSONL output, not `#eval`. 10-100x performance difference.
3. **Simplified ProofTrace**: Extract height, axiom names, rule names from `DerivationTree` -- full serialization is impractical (dependent types, 42 axiom constructors).
4. **Base frame class only**: `decide` checks `ax.minFrameClass <= FrameClass.Base`. Dense/Discrete labeling requires future work.
5. **No existing JSON infrastructure**: Zero files import `Lean.Data.Json`. All `ToJson` instances built from scratch.
6. **Revised feasibility gate**: Timeout rate <20%, valid fraction >=30%, PatternKey entropy threshold. The original ">80% non-propositional" gate is trivially easy.
7. **Temporal duality augmentation**: `swap_temporal` gives free 2x valid dataset multiplier.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances Phase 0 of the ML-for-theorem-proving pipeline described in the ROADMAP under "Planned evolution." It directly supports:
- Building the labeled formula dataset needed for training value estimators
- Establishing the Lean-side data generation boundary for downstream Python consumption
- Creating the BMLogic-Bench benchmark for potential NeurIPS 2026 Datasets track submission

## Goals & Non-Goals

**Goals**:
- Enumerate TM formulas at controlled modal/temporal depth with structural diversity
- Label each formula as valid/invalid/timeout using the existing `decide`/`decideAuto` procedure
- Extract simplified proof traces (height, axioms used, rules applied) from valid results
- Export labeled dataset as streaming JSONL with configurable parameters
- Build a compiled Lake executable (`lake exe dataset_generator`)
- Curate a 500-1K held-out evaluation benchmark with stratified difficulty
- Validate feasibility gates: timeout <20%, valid >=30%, PatternKey diversity

**Non-Goals**:
- Dense/Discrete frame class labeling (only Base supported by `decide`)
- Full `DerivationTree` serialization (too complex, dependent types)
- Rich countermodel structure beyond `SimpleCountermodel` atom-level data
- Python-side tensor conversion or training harness (separate repo)
- HuggingFace upload automation (documented but not implemented)
- Contrastive mutation pairs (deferred to follow-up task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `decideAuto` fuel inadequate for complexity 7+ formulas | H | M | Add configurable fuel multiplier; measure timeout rate early; tune `recommendedFuel` scaling |
| `ToJson` boilerplate compilation slowdown (200-400 new lines importing `Lean.Data.Json`) | M | M | Keep JSON infrastructure in dedicated `DatasetExport.lean`; minimize transitive imports |
| Exhaustive enumeration at complexity 7 produces >60K formulas, labeling takes >1 hour | M | L | Cap enumeration count via `maxFormulas` parameter; default fast run at complexity 5 (1.6K formulas) |
| `DerivationTree` traversal for ProofTrace extraction encounters pattern-match gaps | H | M | Start with safe extraction (height + top-level rule only); extend incrementally; fallback to `ProofTrace.unknown` |
| Random sampling produces biased formula distribution (e.g., deeply nested implication chains) | M | M | Weight sampling productions; reject formulas with complexity <3 or >80% implication operators |
| Lake executable build fails with linker errors on `Lean.Data.Json` imports | M | L | Test `import Lean.Data.Json` in isolation first; use `supportInterpreter := true` as fallback |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |

Phases within the same wave can execute in parallel. Phases 4 and 5 are independent of each other but both require Phase 3.

---

### Phase 1: FormulaEnumerator.lean -- Bounded Generation and Diversity [COMPLETED]

**Goal**: Create the formula enumeration module that generates structurally diverse TM formulas at controlled depth via exhaustive enumeration (low complexity) and grammar-based random sampling (higher complexity).

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/FormulaEnumerator.lean` with proper imports (`Bimodal.Syntax`, `Bimodal.Automation.SuccessPatterns`)
- [ ] Define `EnumParams` structure:
  ```
  structure EnumParams where
    maxComplexity : Nat := 5
    maxModalDepth : Nat := 2
    maxTemporalDepth : Nat := 2
    atoms : List Atom := [Atom.mk_base "p", Atom.mk_base "q", Atom.mk_base "r"]
    maxFormulas : Nat := 5000
    samplingMode : SamplingMode := .exhaustive
  ```
- [ ] Define `SamplingMode` enum: `.exhaustive`, `.random`, `.hybrid`
- [ ] Implement `enumerateExhaustive : EnumParams → List Formula` using bounded recursion on complexity budget. At each step, choose among 6 constructors (`atom`, `bot`, `imp`, `box`, `untl`, `snce`) respecting depth bounds. Use `Formula.complexity`, `Formula.modalDepth`, `Formula.temporalDepth` for bound checking
- [ ] Implement deduplication via `BEq Formula` (already derived) using `List.eraseDups` or `Std.HashSet`
- [ ] Implement `sampleRandom : EnumParams → IO (List Formula)` using `IO.rand` for grammar-based random generation with configurable production weights. Ensure all 6 primitive constructors are represented (not just derived operators)
- [ ] Implement `enrichWithDuals : List Formula → List Formula` applying `Formula.swap_temporal` to generate temporal duals
- [ ] Implement diversity metrics: count formulas by `GoalCategory` (from `goalCategory`), by modal depth bucket, by temporal depth bucket. Report distribution
- [ ] Implement rejection criteria: skip formulas that are pure propositional (no box/untl/snce), skip trivially small formulas (complexity < 3)
- [ ] Add `#eval` smoke test: enumerate at complexity <=3, verify count and diversity
- [ ] Verify `lake build Bimodal` compiles cleanly with new file

**Timing**: 6 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- NEW: ~250-350 lines, enumeration logic
- `Theories/Bimodal/Automation.lean` (or equivalent aggregator) -- add import if needed

**Verification**:
- `lake build Bimodal` succeeds with no errors
- `#eval (enumerateExhaustive { maxComplexity := 3 }).length` returns expected count (small, verifiable by hand)
- All 6 constructor types present in output at complexity 5
- `enrichWithDuals` doubles the valid formula count

---

### Phase 2: DatasetGenerator.lean -- Decider Integration and ProofTrace Extraction [COMPLETED]

**Goal**: Create the dataset generation module that runs the existing decision procedure on enumerated formulas, extracts simplified proof traces from valid results, computes difficulty metrics, and produces labeled records.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/DatasetGenerator.lean` with imports for `Bimodal.Metalogic.Decidability.DecisionProcedure`, `Bimodal.Automation.SuccessPatterns`, `Bimodal.Automation.FormulaEnumerator`
- [ ] Define `ProofTrace` structure:
  ```
  structure ProofTrace where
    height : Nat
    axioms_used : List String
    rules_applied : List String
    deriving Repr, Inhabited
  ```
- [ ] Define `DifficultyMetrics` structure:
  ```
  structure DifficultyMetrics where
    complexity : Nat
    modalDepth : Nat
    temporalDepth : Nat
    impCount : Nat
    atomCount : Nat
    decisionTimeMs : Nat := 0
    difficultyTier : String := "unknown"
    deriving Repr, Inhabited
  ```
- [ ] Define `FormulaLabel` enum: `.valid`, `.invalid`, `.timeout`
- [ ] Define `LabeledFormula` structure combining `Formula`, `FormulaLabel`, `Option ProofTrace`, `Option SimpleCountermodel`, `DifficultyMetrics`, `PatternKey`
- [ ] Implement `extractProofTrace : DerivationTree FrameClass.Base [] phi → ProofTrace` by recursive traversal of the tree:
  - `axiom` constructor: extract axiom constructor name as string, height 0
  - `modus_ponens`: add "modus_ponens" to rules, recurse on children, take max height + 1
  - `necessitation`: add "necessitation" to rules, recurse
  - `temporal_necessitation`: add "temporal_necessitation" to rules, recurse
  - `temporal_duality`: add "temporal_duality" to rules, recurse
  - `assumption`: add "assumption", height 0
  - `weakening`: add "weakening", recurse on child
- [ ] Implement `extractAxiomName : Axiom phi → String` by pattern-matching on all 42 axiom constructors (e.g., `| .prop_k _ _ _ => "prop_k"`, `| .modal_t _ => "modal_t"`, etc.)
- [ ] Implement `computeMetrics : Formula → Nat → DifficultyMetrics` using `Formula.complexity`, `Formula.modalDepth`, `Formula.temporalDepth`, `Formula.countImplications`, `Formula.atoms` (for atom count)
- [ ] Implement `classifyDifficulty : DifficultyMetrics → Nat → String` mapping (complexity, decision time) to tier labels: "easy" (complexity <=3), "medium" (4-6), "hard" (7-9), "very_hard" (>=10)
- [ ] Implement `labelFormula : Formula → IO LabeledFormula` that:
  1. Calls `decideAuto phi` (or `decide phi` with configurable fuel)
  2. Measures wall-clock time via `IO.monoMsNow`
  3. Pattern-matches on `DecisionResult`: `.valid proof` extracts ProofTrace, `.invalid cm` records SimpleCountermodel, `.timeout` records timeout
  4. Computes `DifficultyMetrics` and `PatternKey.fromFormula`
- [ ] Implement `labelBatch : List Formula → IO (List LabeledFormula)` with progress reporting (print every 100 formulas processed)
- [ ] Add `#eval` smoke test: label 5 known formulas (2 valid axiom instances, 2 invalid, 1 hard timeout candidate)
- [ ] Verify `lake build Bimodal` compiles cleanly

**Timing**: 8 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- NEW: ~300-400 lines, labeling pipeline
- `Theories/Bimodal/Automation.lean` (or equivalent aggregator) -- add import if needed

**Verification**:
- `lake build Bimodal` succeeds with no errors
- `#eval` test: known valid formula (e.g., `modal_t` instance `box p -> p`) produces `FormulaLabel.valid` with non-empty ProofTrace
- `#eval` test: known invalid formula produces `FormulaLabel.invalid` with SimpleCountermodel containing true/false atoms
- `extractProofTrace` produces sensible axiom names and rule lists
- `DifficultyMetrics` fields are populated correctly for test cases

---

### Phase 3: DatasetExport.lean -- JSON Serialization, JSONL Streaming, and Lake Executable [COMPLETED]

**Goal**: Create the JSON export module with `ToJson` instances for all data types, a streaming JSONL writer, and a `main` function compiled as a Lake executable. This is the most infrastructure-heavy phase since no existing code imports `Lean.Data.Json`.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/DatasetExport.lean` with imports for `Lean.Data.Json`, `Lean.Data.Json.Printer`, `Bimodal.Automation.DatasetGenerator`, `Bimodal.Automation.FormulaEnumerator`
- [ ] Implement `instance : ToJson Atom` (serialize as string)
- [ ] Implement `formulaToJson : Formula → Json` as recursive function producing tagged AST:
  - `atom a` -> `{"tag": "atom", "name": a.toString}`
  - `bot` -> `{"tag": "bot"}`
  - `imp phi psi` -> `{"tag": "imp", "left": ..., "right": ...}`
  - `box phi` -> `{"tag": "box", "child": ...}`
  - `untl phi psi` -> `{"tag": "untl", "event": ..., "guard": ...}`
  - `snce phi psi` -> `{"tag": "snce", "event": ..., "guard": ...}`
- [ ] Implement `formulaToString : Formula → String` for human-readable representation using operator symbols (box, imp, etc.)
- [ ] Implement `instance : ToJson GoalCategory` (serialize as string)
- [ ] Implement `instance : ToJson PatternKey` (serialize as object with all 5 fields)
- [ ] Implement `instance : ToJson ProofTrace` (serialize as object: height, axioms_used as JSON array, rules_applied as JSON array)
- [ ] Implement `instance : ToJson SimpleCountermodel` (serialize trueAtoms/falseAtoms as string arrays, formula as string)
- [ ] Implement `instance : ToJson DifficultyMetrics` (serialize all 7 fields)
- [ ] Implement `instance : ToJson FormulaLabel` (serialize as string: "valid"/"invalid"/"timeout")
- [ ] Define `DatasetRecord` structure mirroring the JSON schema from research:
  ```
  structure DatasetRecord where
    id : String
    split : String := "train"
    formula_str : String
    formula_ast : Json
    frame_class : String := "Base"
    label : FormulaLabel
    proof_trace : Option ProofTrace
    countermodel : Option SimpleCountermodel
    pattern_key : PatternKey
    metrics : DifficultyMetrics
    augmentation : Option AugmentationInfo
    deriving Inhabited
  ```
- [ ] Implement `instance : ToJson DatasetRecord`
- [ ] Implement `labeledToRecord : Nat → String → LabeledFormula → DatasetRecord` converting from internal to export format with sequential ID and split assignment
- [ ] Implement `writeRecordJSONL : IO.FS.Handle → DatasetRecord → IO Unit` writing a single JSON line
- [ ] Implement `writeDatasetJSONL : FilePath → List LabeledFormula → String → IO Unit` streaming all records to file with ID counter
- [ ] Define `DatasetMetadata` structure for dataset-level statistics (total count, valid/invalid/timeout counts, label distribution, avg complexity, generation parameters)
- [ ] Implement `computeDatasetMetadata : List LabeledFormula → EnumParams → DatasetMetadata`
- [ ] Implement `writeMetadata : FilePath → DatasetMetadata → IO Unit` writing companion `_metadata.json` file
- [ ] Define CLI parameter parsing: `--max-complexity N`, `--max-modal-depth N`, `--max-temporal-depth N`, `--max-formulas N`, `--output PATH`, `--mode exhaustive|random|hybrid`, `--include-duals`
- [ ] Implement `main : IO Unit` that:
  1. Parses CLI arguments
  2. Constructs `EnumParams`
  3. Enumerates formulas
  4. Optionally enriches with temporal duals
  5. Labels all formulas with progress output
  6. Writes JSONL dataset file
  7. Writes metadata file
  8. Prints summary statistics to stdout
- [ ] Add `lean_exe` target to `lakefile.lean`:
  ```
  lean_exe dataset_generator where
    root := `Bimodal.Automation.DatasetExport
    supportInterpreter := true
  ```
- [ ] Test: `lake build dataset_generator` compiles successfully
- [ ] Test: `lake exe dataset_generator -- --max-complexity 3 --max-formulas 50 --output data/test.jsonl` produces valid JSONL
- [ ] Validate output: each line is valid JSON, all required fields present, formula_ast is well-formed

**Timing**: 8 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` -- NEW: ~300-400 lines, JSON export and CLI
- `lakefile.lean` -- add `lean_exe dataset_generator` target

**Verification**:
- `lake build dataset_generator` succeeds
- Small test run produces valid JSONL (each line parseable as JSON)
- Metadata file written with correct statistics
- `formula_ast` field contains well-formed tagged AST
- `proof_trace` is non-null for valid formulas, null for invalid/timeout
- `countermodel` is non-null for invalid formulas
- CLI argument parsing works for all documented flags

---

### Phase 4: Integration Testing, Feasibility Gate Validation, and Benchmark Curation [NOT STARTED]

**Goal**: Run the full pipeline at production scale (complexity <=5 for fast run, <=7 for deep run), validate the three feasibility gates, curate the 500-1K held-out benchmark with stratified difficulty, and fix any issues discovered during integration.

**Tasks**:
- [ ] Run fast dataset generation: `lake exe dataset_generator -- --max-complexity 5 --max-formulas 5000 --output data/bmlogic-fast.jsonl --include-duals`
- [ ] Verify fast run completes in <10 minutes
- [ ] Compute and verify feasibility gates on fast run:
  - **Timeout rate**: Count timeout records / total, assert <20%
  - **Valid fraction**: Count valid records / total, assert >=30%
  - **PatternKey diversity**: Compute entropy over `GoalCategory` distribution and modal/temporal depth buckets, verify non-trivial spread
  - **Operator coverage**: All 6 constructors (`atom`, `bot`, `imp`, `box`, `untl`, `snce`) present in formula_ast fields
- [ ] Run deep dataset generation: `lake exe dataset_generator -- --max-complexity 7 --max-formulas 50000 --output data/bmlogic-deep.jsonl --mode hybrid --include-duals`
- [ ] Verify deep run completes in <6 hours (can run overnight)
- [ ] Implement benchmark curation in `DatasetExport.lean` or as post-processing:
  - Deterministic split via hash: `hash(formula_str) % 100` -> train (80%), val (10%), test (10%)
  - Stratify test split by difficulty tier: Easy (20%), Medium (40%), Hard (30%), Very Hard (10%)
  - Balance validity: aim for ~50% valid, ~50% invalid in test split
  - Include all BX axiom instances (42 formulas) as known-valid anchors in test set
- [ ] Verify benchmark contains 500-1K formulas with balanced labels and stratified difficulty
- [ ] If feasibility gates fail: adjust `EnumParams` (raise minimum modal/temporal depth requirements, add production weights favoring temporal constructors, increase fuel multiplier)
- [ ] Verify dataset file size is manageable (<100MB for deep run)
- [ ] Spot-check 10 random records: verify formula_str matches formula_ast, label is consistent with proof_trace/countermodel presence, metrics are reasonable
- [ ] Run `lake build Bimodal` to verify no regressions in the main library

**Timing**: 4 hours (excluding deep run wall-clock time)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` -- add benchmark split logic and axiom anchor inclusion
- `data/` -- NEW directory for generated datasets (gitignored)

**Verification**:
- Fast run (<10 min) produces 2K-5K labeled formulas
- All three feasibility gates pass
- Benchmark subset has 500-1K formulas with stratified difficulty
- No regressions in `lake build Bimodal`
- JSONL files are valid and loadable by a JSON parser

---

### Phase 5: Documentation, Dataset README, and Cleanup [NOT STARTED]

**Goal**: Write module-level documentation, create a dataset README describing the schema and usage, add `.gitignore` entries for generated data, and clean up any code quality issues.

**Tasks**:
- [ ] Add comprehensive module docstrings to all three new files following the existing `/-! ... -/` pattern in the codebase (see `Formula.lean`, `DecisionProcedure.lean` for examples)
- [ ] Document `EnumParams` fields with examples in docstrings
- [ ] Document `DatasetRecord` JSON schema in the `DatasetExport.lean` module header, matching the schema from the research report
- [ ] Create `data/.gitignore` with `*.jsonl` and `*_metadata.json` entries (generated data should not be committed)
- [ ] Document known limitations prominently:
  - Base frame class only (`decide` limitation)
  - `SimpleCountermodel` is atom-level only (no world/time structure)
  - `recommendedFuel` may be insufficient for complexity 9+ formulas
  - Temporal duality doubles valid formulas but not invalid ones
- [ ] Document how to run the pipeline:
  - Fast run: `lake exe dataset_generator -- --max-complexity 5 --max-formulas 5000 --output data/bmlogic.jsonl`
  - Deep run: `lake exe dataset_generator -- --max-complexity 7 --max-formulas 50000 --output data/bmlogic-deep.jsonl --mode hybrid --include-duals`
- [ ] Add usage examples in module docstring for downstream Python consumption:
  ```python
  import json
  with open("data/bmlogic.jsonl") as f:
      records = [json.loads(line) for line in f]
  ```
- [ ] Review all new code for consistency with codebase style (see `Theories/Bimodal/` conventions): `autoImplicit false`, `pp.unicode.fun true`, proper namespace nesting
- [ ] Final `lake build Bimodal` and `lake build dataset_generator` verification

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- add module docstrings
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- add module docstrings
- `Theories/Bimodal/Automation/DatasetExport.lean` -- add module docstrings and schema documentation
- `data/.gitignore` -- NEW: gitignore for generated datasets

**Verification**:
- All three modules have comprehensive `/-! ... -/` headers
- `lake build Bimodal` succeeds
- `lake build dataset_generator` succeeds
- Documentation is accurate and matches actual behavior

---

## Testing & Validation

- [ ] `lake build Bimodal` succeeds at each phase with no new errors
- [ ] `lake build dataset_generator` produces a native binary
- [ ] Fast run (complexity <=5, ~5K formulas) completes in <10 minutes
- [ ] Feasibility gate: timeout rate <20%
- [ ] Feasibility gate: valid fraction >=30%
- [ ] Feasibility gate: all 6 Formula constructors represented
- [ ] Known valid formulas (BX axiom instances) are labeled `.valid` with non-empty ProofTrace
- [ ] Known invalid formulas produce `.invalid` with non-empty SimpleCountermodel
- [ ] JSONL output: every line is valid JSON
- [ ] JSONL output: all required fields present (`id`, `formula_str`, `formula_ast`, `frame_class`, `label`, `pattern_key`, `metrics`)
- [ ] `formula_ast` round-trips: tagged AST correctly represents the formula
- [ ] Benchmark subset: 500-1K formulas, stratified by difficulty, balanced by validity
- [ ] No regressions in existing test suite

## Artifacts & Outputs

- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- Formula enumeration module (~250-350 lines)
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- Decider integration and ProofTrace extraction (~300-400 lines)
- `Theories/Bimodal/Automation/DatasetExport.lean` -- JSON serialization, JSONL streaming, CLI executable (~300-400 lines)
- `lakefile.lean` -- Updated with `lean_exe dataset_generator` target
- `data/.gitignore` -- Gitignore for generated datasets
- `data/bmlogic-fast.jsonl` -- Fast run output (2K-5K records, gitignored)
- `data/bmlogic-fast_metadata.json` -- Fast run metadata (gitignored)

## Rollback/Contingency

All new code is additive -- three new `.lean` files and one new `lean_exe` target. Rollback is trivial:

1. Delete the three new files: `FormulaEnumerator.lean`, `DatasetGenerator.lean`, `DatasetExport.lean`
2. Remove the `lean_exe dataset_generator` block from `lakefile.lean`
3. Remove any import additions from aggregator files
4. `lake build Bimodal` will succeed as before

If the `decideAuto` fuel proves inadequate (high timeout rate), the mitigation is to reduce `maxComplexity` to 5 (where all formulas are decidable quickly) and defer complexity 7+ to a follow-up task with tuned fuel parameters.

If `Lean.Data.Json` imports cause build issues with the main library, isolate all JSON code in `DatasetExport.lean` and ensure only the executable target depends on it, not the `Bimodal` library target.
