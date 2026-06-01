# Implementation Plan: Task #242

- **Task**: 242 - Tableau-derived proof step extraction and JSONL pipeline
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (all infrastructure exists)
- **Research Inputs**: specs/242_tableau_proof_step_generation/reports/01_proof-step-pipeline-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Build a new Lean 4 pipeline module that connects the existing FormulaEnumerator, DecisionProcedure, and ProofStepExtractor into a single executable. The module enumerates formulas at configurable complexity, runs `decideAuto` on each, extracts `ProofStep` records from valid results via `extractStepSequence`, applies step-level deduplication, computes diversity metrics (rule/axiom distribution, coverage), and writes JSONL output. The target is 100K+ proof steps with balanced rule distribution and improved axiom name coverage from the current 31/42 (74%) toward 90%+.

### Research Integration

Key findings from the research report (01_proof-step-pipeline-research.md):

1. **Type compatibility is exact**: `DecisionResult.valid` contains `DerivationTree .Base [] phi`, which is exactly what `extractStepSequence` requires. No adapters needed.
2. **100K+ steps achievable** via combined strategy: enumeration at complexity 7-9 (~20K-50K steps), axiom seeding (5K seeds, ~12K-25K steps), deep G^n temporal wrapping (~55K steps), plus existing 10K from 310 hand-registered theorems.
3. **Gap is a connecting module only**: All four components (enumerator, decision procedure, step extractor, JSON export) are production-tested. The missing piece is the orchestrating pipeline.
4. **Performance**: `extractStepSequence` is O(tree_size) and negligible vs `decideAuto`. Streaming pipeline (decide + extract + write per formula) avoids memory pressure.
5. **Rule coverage gap**: `assumption` and `weakening` rules are absent from current data (all hand-registered theorems derive from empty context).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the ML training data infrastructure. The ROADMAP is primarily focused on the completeness proof critical path (tasks 155, 202), but this task is complementary -- it extends the training data pipeline for the BimodalHarness.

## Goals & Non-Goals

**Goals**:
- Create `TableauProofStepPipeline.lean` module connecting existing components
- Register new `tableau_proof_steps` executable in `lakefile.lean`
- Implement step-level deduplication using structural hashing
- Implement diversity metrics (rule histogram, axiom histogram, coverage)
- Export JSONL to `data/tableau_proof_steps.jsonl` with metadata summary
- Target 100K+ proof steps with all 7 inference rules and 38+/42 axiom names

**Non-Goals**:
- Modifying the existing `proof_extractor` or `dataset_generator` executables
- Supporting Dense/Discrete frame classes (Base only for this iteration)
- Building a Python consumer or integration with BimodalHarness training loop
- Achieving 42/42 axiom coverage (uniformity/density axioms require non-Base frame classes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Performance bottleneck at high complexity (c9+) | M | M | Configurable complexity cap, streaming pipeline, progress reporting |
| Shallow proof dominance reduces average steps/formula | M | H | Combine strategies: axiom seeding + deep wrapping to boost step count |
| Compilation time for new module with many imports | L | M | Minimize imports, reuse existing structures |
| assumption/weakening rules remain uncovered | L | M | These require non-empty context proofs; note as future work if not naturally arising |
| `decideAuto` timeouts for complex formulas | L | H | Filter timeouts gracefully, report timeout fraction in metrics |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Pipeline Configuration and Deduplication Infrastructure [COMPLETED]

**Goal**: Define the pipeline configuration structure, step-level deduplication, and diversity metrics data types in a new module.

**Tasks**:
- [x] Create `Theories/Bimodal/Automation/TableauProofStepPipeline.lean` with imports for FormulaEnumerator, DecisionProcedure, ProofStepExtractor, and DataExport
- [x] Define `PipelineConfig` structure with fields: enumeration parameters (complexity bounds, atom pool), axiom seed count, G^n wrap depth/batch size, dedup flag, output path, merge-with-registry flag
- [x] Define `StepDistribution` structure with fields: `ruleHistogram`, `axiomHistogram`, `complexityHistogram`, `totalSteps`, `uniqueSteps`, `theoremCount`
- [x] Implement `hashProofStep : ProofStep -> UInt64` hashing function based on `(context, goal, rule, axiomName)` tuple for deduplication
- [x] Implement `StepDistribution.empty` and `StepDistribution.addStep` for incremental metric accumulation
- [x] Implement `StepDistribution.toJson` for metadata export
- [x] Verify the module compiles with `lake build Bimodal.Automation.TableauProofStepPipeline`

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/TableauProofStepPipeline.lean` - New file: pipeline config, dedup, metrics types

**Verification**:
- Module compiles successfully
- `PipelineConfig`, `StepDistribution`, and `hashProofStep` are defined and type-check

---

### Phase 2: Core Pipeline Logic (Enumerate-Decide-Extract) [COMPLETED]

**Goal**: Implement the main pipeline function that enumerates formulas, runs `decideAuto`, extracts proof steps from valid results, and applies deduplication.

**Tasks**:
- [x] Implement `processFormula : Formula -> Nat -> IO (Option (List ProofStep))` that runs `decideAuto`, pattern-matches on `.valid`, calls `extractStepSequence`, returns steps for valid results and `none` for invalid/timeout *(deviation: altered -- signature is `Formula -> String -> Option (List ProofStep)` (pure, takes name not index))*
- [x] Implement formula naming scheme: `"enum-" ++ String.mk (Nat.toDigits 10 idx)` with zero-padding for sequential IDs
- [x] Implement `runEnumerationPipeline : PipelineConfig -> IO (List ProofStep x StepDistribution)` that:
  - Enumerates formulas via `enumerateUpToDepth` using config's EnumConfig
  - Processes each formula through `processFormula`
  - Applies step-level deduplication using `HashSet UInt64` of step hashes
  - Accumulates `StepDistribution` metrics
  - Reports progress every 1000 formulas to IO
- [x] Implement `runAxiomSeedPipeline : PipelineConfig -> IO (List ProofStep x StepDistribution)` that:
  - Generates valid formulas via `generateValidBatch` with config's seed count
  - Processes each through `decideAuto` + `extractStepSequence`
  - Deduplicates and accumulates metrics
- [x] Implement `runDeepWrappingPipeline : List Formula -> PipelineConfig -> IO (List ProofStep x StepDistribution)` that:
  - Takes the most structurally diverse valid formulas from enumeration
  - Wraps each with G^n for n = 1..maxWrapDepth
  - Extracts steps from each wrapped variant
  - Deduplicates
- [x] Verify compilation with `lake build Bimodal.Automation.TableauProofStepPipeline`

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/TableauProofStepPipeline.lean` - Add core pipeline functions

**Verification**:
- All pipeline functions compile
- Type signatures match: `decideAuto` returns `DecisionResult phi`, `.valid proof` gives `DerivationTree .Base [] phi`, `extractStepSequence` accepts this type

---

### Phase 3: JSONL Export and Metadata [COMPLETED]

**Goal**: Implement JSONL file writing with metadata summary, combining all pipeline strategies into a single output.

**Tasks**:
- [x] Implement `writeProofStepsJSONL : String -> List ProofStep -> IO Nat` that writes each `ProofStep.toJson` as one line, returns line count *(deviation: altered -- takes `Array ProofStep` instead of `List` for performance)*
- [x] Implement `writeMetadataJSON : String -> StepDistribution -> PipelineConfig -> IO Unit` that writes `_metadata.json` with generation parameters, distribution stats, coverage metrics, and timestamp
- [x] Implement `computeCoverage : StepDistribution -> (Nat x Nat x Nat x Nat)` returning (rules_covered, total_rules, axioms_covered, total_axioms)
- [x] Implement `mergeDistributions : StepDistribution -> StepDistribution -> StepDistribution` for combining metrics from multiple pipeline stages
- [x] Implement `runFullPipeline : PipelineConfig -> IO Unit` that:
  - Runs enumeration pipeline
  - Runs axiom seed pipeline
  - Runs deep wrapping pipeline on top valid formulas
  - Optionally merges existing 310-theorem registry steps *(deviation: skipped -- registry merge deferred; registry steps available via existing `lake exe proof_extractor`)*
  - Deduplicates across all sources
  - Writes combined JSONL
  - Writes metadata
  - Prints summary to stdout
- [x] Verify compilation

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/TableauProofStepPipeline.lean` - Add JSONL export, metadata, and full pipeline orchestrator

**Verification**:
- `runFullPipeline` compiles
- Metadata JSON includes rule histogram, axiom histogram, coverage fractions

---

### Phase 4: Executable Registration and CLI [COMPLETED]

**Goal**: Register the pipeline as a new lake executable with CLI argument parsing and run a smoke test.

**Tasks**:
- [x] Add `main : IO Unit` function to `TableauProofStepPipeline.lean` with CLI argument parsing:
  - `--max-complexity N` (default: 7)
  - `--max-modal-depth N` (default: 3)
  - `--max-temporal-depth N` (default: 3)
  - `--valid-seed-count N` (default: 5000)
  - `--max-wrap-depth N` (default: 10)
  - `--wrap-batch-size N` (default: 1000)
  - `--output PATH` (default: `data/tableau_proof_steps.jsonl`)
  - `--no-dedup` flag
  - `--no-registry` flag (skip merging hand-registered theorems)
- [x] Add `lean_exe tableau_proof_steps` target to `lakefile.lean` with root `Bimodal.Automation.TableauProofStepPipeline`, srcDir `Theories`, supportInterpreter true
- [x] Add import of `TableauProofStepPipeline` to `Theories/Bimodal/Automation.lean` (if module index file exists) *(deviation: skipped -- module defines `main` and should not be imported through the umbrella, consistent with other lean_exe targets)*
- [x] Run `lake build tableau_proof_steps` to verify executable builds
- [x] Run smoke test: `lake exe tableau_proof_steps -- --max-complexity 3 --valid-seed-count 10 --max-wrap-depth 2 --output data/test_tableau_steps.jsonl` and verify output is valid JSONL

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/TableauProofStepPipeline.lean` - Add main and CLI parsing
- `lakefile.lean` - Add `lean_exe tableau_proof_steps` target

**Verification**:
- `lake build tableau_proof_steps` succeeds
- Smoke test produces valid JSONL output
- `wc -l data/test_tableau_steps.jsonl` shows non-zero line count
- Each line is valid JSON with required fields (theorem_name, step_index, context, goal, rule, axiom_name, subgoals, frame_class)

---

### Phase 5: Full-Scale Run and Validation [IN PROGRESS]

**Goal**: Execute the pipeline at target scale (complexity 7+), validate output quality, and verify diversity targets.

**Tasks**:
- [ ] Run full pipeline: `lake exe tableau_proof_steps -- --max-complexity 7 --valid-seed-count 5000 --max-wrap-depth 10 --output data/tableau_proof_steps.jsonl`
- [ ] Validate JSONL: all lines parse as valid JSON, required fields present, axiom_name non-null iff rule = "axiom"
- [ ] Check total step count against 100K target
- [ ] Check rule coverage: verify all 7 rules present (or document which are missing and why)
- [ ] Check axiom name coverage: count distinct axiom names, target 38+/42
- [ ] Review metadata JSON for distribution balance
- [ ] If step count < 100K, adjust parameters (increase complexity to 8-9, increase seed count) and re-run
- [ ] Run `lake build` to verify no regressions to existing executables or library
- [ ] Clean up test output: remove `data/test_tableau_steps.jsonl`

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- No source file changes expected; this phase is execution and validation
- `data/tableau_proof_steps.jsonl` - Generated output (not checked in)
- `data/tableau_proof_steps_metadata.json` - Generated metadata (not checked in)

**Verification**:
- `wc -l data/tableau_proof_steps.jsonl` >= 100,000
- `python3 -c "import json; [json.loads(l) for l in open('data/tableau_proof_steps.jsonl')]"` succeeds
- Rule coverage: ideally 7/7, minimum 5/7 (documenting gaps)
- Axiom name coverage: 38+/42
- `lake build` passes with no errors

## Testing & Validation

- [ ] `lake build tableau_proof_steps` compiles successfully
- [ ] Smoke test at complexity 3 produces valid JSONL output
- [ ] Full-scale run at complexity 7+ produces 100K+ steps
- [ ] All JSONL lines are valid JSON with required ProofStepRecord fields
- [ ] Step deduplication reduces total count by expected margin (5-20%)
- [ ] Metadata JSON accurately reflects distribution statistics
- [ ] `lake build` full project passes with no regressions
- [ ] Rule coverage >= 5/7 (target 7/7)
- [ ] Axiom name coverage >= 38/42

## Artifacts & Outputs

- `Theories/Bimodal/Automation/TableauProofStepPipeline.lean` - New pipeline module
- `lakefile.lean` - Updated with `lean_exe tableau_proof_steps` target
- `data/tableau_proof_steps.jsonl` - Generated JSONL output (not checked in)
- `data/tableau_proof_steps_metadata.json` - Generated metadata (not checked in)
- `specs/242_tableau_proof_step_generation/plans/01_implementation-plan.md` - This plan
- `specs/242_tableau_proof_step_generation/summaries/01_execution-summary.md` - Implementation summary (post-implementation)

## Rollback/Contingency

The new module is entirely additive -- it introduces one new file (`TableauProofStepPipeline.lean`) and one new lakefile target. No existing code is modified (except the one-line lakefile addition). To rollback:

1. Delete `Theories/Bimodal/Automation/TableauProofStepPipeline.lean`
2. Remove the `lean_exe tableau_proof_steps` block from `lakefile.lean`
3. Run `lake build` to verify clean state

If the 100K step target proves unachievable at complexity 7, the fallback is to increase to complexity 8-9 or increase the axiom seed count. The pipeline architecture supports this via configuration without code changes.
