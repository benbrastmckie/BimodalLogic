# Implementation Plan: Task #213

- **Task**: 213 - Production-scale dataset generation validation
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: Tasks 210 (enumeration fix), 212 (proof step extractor)
- **Research Inputs**: specs/213_production_scale_dataset_validation/reports/01_team-research.md
- **Artifacts**: plans/01_production-validation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The enumeration blowup fixed in task 210 enables complexity 5-7 generation (51K formulas in 3ms), but the pipeline is not production-ready. Four critical issues remain: valid fraction at 4% vs. the 15% gate, degenerate validity signal (94% trivial ex_falso instances), no temporal operator coverage in axiom seeds, and untested full-pipeline performance at 51K scale. This plan addresses both regression validation (confirming the enumeration fix works end-to-end) and signal quality enhancement (fixing the ex_falso dominance, adding temporal axiom schemata, integrating task 212 theorem seeds, and implementing streaming writes). Done when: the full pipeline runs at complexity 7 with valid fraction above 15%, ex_falso below 50% of valid set, all four operator categories above 10%, and `lake build` passes after each phase.

### Research Integration

The team research report (4 teammates) identified the root causes and recommended a two-phase approach. Key findings integrated:

- **Teammate A**: Pipeline architecture mapped; CLI defaults to 500 seeds but `--valid-seed-count` is not exposed as a flag. `EnumParams.validSeedCount` uses struct default (500) but is operationally inaccessible.
- **Teammate B**: Saturation-based generation (Nec/MP closure to fixpoint) is the gold standard. Streaming write is essential at 50K+ scale. Parallel labeling via `IO.asTask` provides 3-4x throughput.
- **Teammate C**: 15% gate unmet; benchmark sampled 200 formulas from front of list (exhaustive-dominated, missing seeds). Complexity 7 full pipeline never tested.
- **Teammate D**: 94% of valid formulas are `(bot → phi)` ex_falso instances. Task 212's 36 proven theorems are disconnected. Recommended task split into regression validation + signal quality.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances dataset generation infrastructure for the ML proof search harness. Not directly on the completeness critical path but supports the publication-quality tooling ecosystem (Phase 5 in roadmap). The dataset pipeline builds on the formula enumerator (task 203), enumeration fix (task 210), and proof step extractor (task 212).

## Goals & Non-Goals

**Goals**:
- Run full pipeline at complexity 5 and 7, measure wall-clock time, memory, valid fraction
- Expose `--valid-seed-count` as a CLI flag for production tuning
- Update run script with post-task-210 parameters (exhaustive at complexity 5+7)
- Fix ex_falso dominance (target: below 50% of valid set)
- Add temporal axiom schemata to `instantiateAxiom` (serial_future, until_F, connect_future, and duals)
- Add temporal operators (untl, snce) to `randomSubFormula`
- Integrate task 212 theorem seeds into `generateValidBatch`
- Implement streaming JSONL write to prevent OOM at 50K+
- Run Nec/MP closure to fixpoint instead of fixed 2 rounds
- Confirm valid fraction above 15% and all operator categories above 10%

**Non-Goals**:
- Parallel labeling via `IO.asTask` (P3 enhancement, deferred)
- In-memory labeling cache (P4 optimization, deferred)
- Dataset versioning or reproducibility via fixed random seed
- Decision time distribution metrics or axiom schema coverage metrics
- Contrastive pair generation (already in FormulaMutator from task 206)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Labeling 51K formulas exceeds reasonable time (>30 min) | H | M | Monitor timing at 1K intervals; cap at configurable timeout per formula |
| Nec/MP fixpoint closure generates combinatorial explosion in pool size | M | M | Cap pool size at 10K; stop when growth rate drops below 1% per round |
| Temporal axiom seeds produce mostly timeout labels | M | L | Pre-test temporal seeds in isolation; adjust maxParamSize for temporal schemata |
| `eraseDups` on 51K formulas causes quadratic slowdown | H | H | Replace List.eraseDups with HashMap-based dedup; measure before/after |
| OOM during full pipeline with in-memory accumulation | H | M | Implement streaming write in Phase 3 before running full pipeline |
| Task 212 ProofStepExtractor API not compatible with formula injection | M | L | Inspect TheoremEntry structure; adapt extraction to produce Formula values |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

### Phase 1: CLI Flag and Run Script Update [COMPLETED]

**Goal**: Expose `--valid-seed-count` as a CLI parameter and update the run script for post-task-210 parameters. This is the minimal regression infrastructure needed to unblock all other phases.

**Tasks**:
- [ ] Add `validSeedCount : Nat := 500` field to `CLIArgs` in `DatasetExport.lean`
- [ ] Add `--valid-seed-count` parsing case to `parseCLIArgs` in `DatasetExport.lean`
- [ ] Wire `CLIArgs.validSeedCount` into `EnumParams` construction in `main`
- [ ] Print `validSeedCount` in the CLI banner
- [ ] Update `run_dataset_generation.sh` medium run: change `--max-complexity 4` to `--max-complexity 5`, add `--valid-seed-count 2000`
- [ ] Update `run_dataset_generation.sh` deep run: change from `--mode random` to `--mode exhaustive`, change to `--max-complexity 7`, add `--valid-seed-count 5000`
- [ ] Add a `production` run target that runs complexity 7 exhaustive with high seed count
- [ ] Run `lake build` to verify compilation

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` - Add validSeedCount to CLIArgs, parsing, and main wiring
- `scripts/run_dataset_generation.sh` - Update medium/deep parameters, add production target

**Verification**:
- `lake build` passes
- `lake exe dataset_generator -- --help` shows `--valid-seed-count` (or verify in code since no --help handler exists)
- Run smoke test: `lake exe dataset_generator -- --max-complexity 3 --max-formulas 20 --valid-seed-count 10 --output data/test-cli.jsonl`

---

### Phase 2: Temporal Axiom Seeds and Subformula Coverage [NOT STARTED]

**Goal**: Fix the two root causes of poor validity signal: (1) `instantiateAxiom` only generates propositional/modal formulas (no temporal operators), and (2) `randomSubFormula` only produces atom/imp/box (no temporal operators). Also fix ex_falso dominance by rebalancing schema selection.

**Tasks**:
- [ ] Add temporal axiom schemata to `instantiateAxiom` in `FormulaEnumerator.lean`:
  - `serial_future`: `Formula.top.imp (Formula.all_future Formula.top).neg.neg` (i.e., `T -> F(T)`)
  - `serial_past`: `Formula.top.imp (Formula.all_past Formula.top).neg.neg` (i.e., `T -> P(T)`)
  - `until_F(phi)`: `(Formula.untl phi psi).imp (Formula.all_future psi).neg.neg` (i.e., `(phi U psi) -> F(psi)`)
  - `connect_future(phi)`: `phi.imp (Formula.all_future ((Formula.all_past phi).neg.neg))` (i.e., `phi -> G(P(phi))`)
  - `right_mono_until(phi, psi, chi)`: `(Formula.all_future (phi.imp psi)).imp ((chi.untl phi).imp (chi.untl psi))`
  - `F_until_equiv(phi)`: `(Formula.all_future phi).neg.neg.imp (Formula.untl Formula.top phi)` (i.e., `F(phi) -> T U phi`)
- [ ] Add temporal operators to `randomSubFormula` in `FormulaEnumerator.lean`:
  - Extend the choice branches from 4 to 6: add `all_future`/`all_past` (unary, like box) and `untl`/`snce` (binary, like imp)
  - Adjust probability weights: `atom=1, imp=2, box=1, all_future=1, untl=1` (6 total branches)
- [ ] Rebalance `instantiateAxiom` schema selection to reduce ex_falso dominance:
  - Increase total schemata from 8 to 14 (adding 6 temporal)
  - Weight ex_falso at 1/14 instead of 1/8 (from 12.5% to 7.1% of seeds)
- [ ] Run `lake build` to verify compilation

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - `instantiateAxiom`, `randomSubFormula`

**Verification**:
- `lake build` passes
- Quick test: run `lake exe dataset_generator -- --max-complexity 4 --max-formulas 100 --valid-seed-count 50 --output data/test-temporal.jsonl` and inspect output for temporal operators in valid formulas

---

### Phase 3: Streaming Write and OOM Prevention [NOT STARTED]

**Goal**: Refactor `DatasetExport.lean` to write JSONL records one at a time (streaming) instead of accumulating all `LabeledFormula` in memory before export. This prevents OOM at 50K+ formulas and enables progress monitoring during long runs.

**Tasks**:
- [ ] Refactor `main` in `DatasetExport.lean` to use streaming write pattern:
  - Open output file handle before labeling loop
  - Label each formula individually, write JSONL line immediately, flush periodically
  - Accumulate only lightweight statistics (counts, category tallies), not full LabeledFormula objects
  - Print progress every 1000 formulas: count, valid%, elapsed time
- [ ] Refactor metadata computation to use running accumulators instead of full list scan:
  - Track `validCount`, `invalidCount`, `timeoutCount`, `categoryDistribution` incrementally
  - Write metadata file after streaming loop completes
- [ ] Replace `List.eraseDups` in `generateFormulas` with `Std.HashMap`-based dedup:
  - Use `Formula.toString` or a hash as the key
  - This avoids the O(n^2) cost on 51K formulas
- [ ] Run `lake build` to verify compilation

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` - Streaming write, progress reporting, incremental stats
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - HashMap dedup in `generateFormulas`

**Verification**:
- `lake build` passes
- Run smoke test: `lake exe dataset_generator -- --max-complexity 3 --max-formulas 50 --output data/test-stream.jsonl` produces correct JSONL and metadata
- Verify progress output appears during execution

---

### Phase 4: Nec/MP Fixpoint Closure and Theorem Seed Integration [NOT STARTED]

**Goal**: Replace the fixed 2-round Nec/MP closure in `generateValidBatch` with a fixpoint loop (stopping when growth rate drops below threshold or pool exceeds cap). Integrate task 212's proven theorems as additional validity seeds.

**Tasks**:
- [ ] Refactor `generateValidBatch` in `FormulaEnumerator.lean`:
  - Replace the hard-coded 2 rounds of Nec+MP with a `while` loop that continues until: (a) no new formulas added in the last round, or (b) pool exceeds 10,000 formulas, or (c) 10 rounds completed
  - Track pool size before and after each round; log growth rate
  - Filter output to `complexity >= 3 && complexity <= maxComplexity`
- [ ] Add theorem seed integration to `generateValidBatch`:
  - Create a `theoremSeedFormulas` function that returns a list of Formula values from task 212's proven theorems
  - Include the 36 theorems from the registry (propositional, modal, temporal categories)
  - Add these to the initial seed pool before Nec/MP closure
  - These are guaranteed valid and provide deep proof structures (heights up to 325)
- [ ] Cap ex_falso instances in the seed pool: after axiom instantiation, limit ex_falso-pattern formulas to at most 20% of the seed pool, replacing excess with additional non-ex_falso instantiations
- [ ] Run `lake build` to verify compilation

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - `generateValidBatch` fixpoint loop, theorem seed integration, ex_falso cap
- `Theories/Bimodal/Automation/DatasetExport.lean` - Import ProofStepExtractor if needed for theorem formulas

**Verification**:
- `lake build` passes
- Run with increased seed count: `lake exe dataset_generator -- --max-complexity 5 --valid-seed-count 1000 --max-formulas 500 --output data/test-fixpoint.jsonl`
- Verify: valid fraction improved vs. baseline, ex_falso below 50% of valid formulas

---

### Phase 5: Full Pipeline Regression Run at Complexity 5 and 7 [NOT STARTED]

**Goal**: Execute the complete pipeline at production scale and measure all metrics against task 204 baselines. This is the core validation phase.

**Tasks**:
- [ ] Run complexity 5 production pipeline:
  - `lake exe dataset_generator -- --max-complexity 5 --valid-seed-count 3000 --max-formulas 5000 --output data/bmlogic-c5.jsonl --include-duals`
  - Record: wall-clock time, formula count, valid/invalid/timeout fractions, operator category distribution
- [ ] Run complexity 7 production pipeline:
  - `lake exe dataset_generator -- --max-complexity 7 --valid-seed-count 5000 --max-formulas 60000 --output data/bmlogic-c7.jsonl --include-duals`
  - Record: wall-clock time, peak memory (via `/usr/bin/time -v`), formula count, valid fraction, operator diversity
- [ ] Compare results against task 204 baselines:
  - Medium (task 204): complexity 4, 25% valid fraction
  - Deep (task 204): complexity 7 random-only, 1.6% valid fraction
  - Target: valid fraction > 15%, ex_falso < 50% of valid, all 4 operator categories > 10%
- [ ] Validate output integrity:
  - JSONL parseable by Python: `python3 -c "import json; [json.loads(l) for l in open('data/bmlogic-c7.jsonl')]"`
  - Metadata file present and consistent with JSONL record count
  - No duplicate formula IDs
- [ ] Update `run_dataset_generation.sh` with final tuned parameters based on results
- [ ] Document results: timing, counts, valid fractions, operator diversity, comparison to baselines

**Timing**: 3 hours (includes pipeline execution time and analysis)

**Depends on**: 3, 4

**Files to modify**:
- `scripts/run_dataset_generation.sh` - Final parameter tuning based on production results

**Verification**:
- Both complexity 5 and 7 runs complete without OOM or crash
- Valid fraction above 15% in at least the complexity 5 run
- JSONL output passes Python JSON parse validation
- Metadata file accurate
- Operator diversity covers all 4 categories (propositional, modal, temporal_future, temporal_past)

---

### Phase 6: Benchmark Update and Feasibility Gate Validation [NOT STARTED]

**Goal**: Update the `EnumBenchmark.lean` to test the improved pipeline with temporal seeds and fixpoint closure. Validate all feasibility gates and document remaining bottlenecks.

**Tasks**:
- [ ] Update `benchmarkValidFraction` in `EnumBenchmark.lean`:
  - Increase seed count to test the improved axiom seeding (temporal + theorem seeds)
  - Sample from the middle of the combined list (not just front) to avoid exhaustive-dominated bias
  - Add an explicit check for ex_falso dominance: count `bot → phi` patterns in valid set
  - Add operator diversity check: count formulas containing each operator category
- [ ] Add a new `benchmarkFullPipeline` function:
  - Run the full pipeline at complexity 7 with streaming write
  - Report: total time, labeling time, write time, formula count, valid fraction
  - Check feasibility gates: timeout rate < 20%, valid fraction >= 15%, 3+ distinct categories
- [ ] Run `lake build` and then `lake exe enum_benchmark` to validate all gates
- [ ] Document any remaining bottlenecks or parameter tuning needs in a brief inline summary
- [ ] If valid fraction gate at complexity 7 still fails, document the gap and recommend next steps (e.g., higher seed ratio, parallel labeling)

**Timing**: 2 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Automation/EnumBenchmark.lean` - Updated benchmarks, full pipeline test, diversity checks

**Verification**:
- `lake build` passes
- `lake exe enum_benchmark` runs to completion
- Feasibility gates documented with pass/fail status
- If any gate fails, clear diagnosis and recommended parameter adjustment documented

## Testing & Validation

- [ ] `lake build` passes after every phase
- [ ] Smoke test (complexity 3, 20 formulas) works with `--valid-seed-count` flag
- [ ] Complexity 5 full pipeline produces valid JSONL output with metadata
- [ ] Complexity 7 full pipeline completes without OOM
- [ ] Valid fraction above 15% (at least at complexity 5; complexity 7 may need parameter tuning)
- [ ] Ex_falso instances below 50% of valid formulas
- [ ] All 4 operator categories represented at >10% in valid set
- [ ] Python JSONL parse validation succeeds on output files
- [ ] Benchmark gates: timeout rate < 20%, valid fraction >= 15%, 3+ categories

## Artifacts & Outputs

- `specs/213_production_scale_dataset_validation/plans/01_production-validation-plan.md` (this file)
- `Theories/Bimodal/Automation/DatasetExport.lean` - CLI flag, streaming write
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - Temporal seeds, fixpoint closure, HashMap dedup
- `Theories/Bimodal/Automation/EnumBenchmark.lean` - Updated benchmarks
- `scripts/run_dataset_generation.sh` - Updated production parameters
- `data/bmlogic-c5.jsonl` + `data/bmlogic-c5_metadata.json` - Complexity 5 production output
- `data/bmlogic-c7.jsonl` + `data/bmlogic-c7_metadata.json` - Complexity 7 production output

## Rollback/Contingency

All changes are to Lean source files that compile via `lake build`. If any phase introduces a build failure, revert the specific file changes from that phase using `git checkout -- <file>`. The existing dataset files (`bmlogic-medium.jsonl`, `bmlogic-deep.jsonl`) are not modified and serve as baselines. If the valid fraction gate cannot be met at complexity 7 even with all enhancements, document the gap and recommend a follow-up task focused on parallel labeling and decision time filtering.
