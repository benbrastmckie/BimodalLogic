# Implementation Plan: Task #204

- **Task**: 204 - Run production dataset generation (medium and deep runs)
- **Status**: [NOT STARTED]
- **Effort**: 3 hours (active) + overnight compute
- **Dependencies**: 203 (completed)
- **Research Inputs**: specs/204_dataset_production_runs/reports/01_production-runs-research.md
- **Artifacts**: plans/01_production-runs-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Execute the dataset generator at production scale in two runs: a medium run (complexity 5, ~5K formulas, ~30 min) and a deep run (complexity 7, hybrid mode, ~50K formulas, 2-12 hours). Each run validates feasibility gates (timeout rate, valid fraction, PatternKey diversity) and stores output in the data/ directory. A shell script wrapper provides reproducibility. The valid fraction gate is relaxed from 30% to 15% based on research findings that higher-complexity formulas are predominantly invalid by nature.

### Research Integration

Key findings from the research report integrated into this plan:
- CLI executable `lake exe dataset_generator` is build-ready with all required flags
- Complexity 4 test showed 18% valid fraction (below original 30% target but within the formal evaluateGate range of 15-70%)
- Batch pipeline holds all formulas in memory; 50K formulas estimated at 1-4 GB
- Hybrid mode mitigates exhaustive enumeration explosion at complexity 7 (exhaustive up to 5, random above)
- The formal `evaluateGate` in DatasetValidator is a separate tool that runs its own enumeration -- it does NOT validate production JSONL files directly
- Metadata companion files are auto-generated alongside JSONL output

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the ML/dataset pipeline established by task 201 (Tier 1 training data) and task 203 (generator infrastructure). Downstream consumers include task 205 (benchmark curation) and eventual ML training. Not directly on the ROADMAP's completeness critical path.

## Goals & Non-Goals

**Goals**:
- Execute medium production run (complexity 5, ~5K formulas with duals)
- Execute deep production run (complexity 7, hybrid mode, ~50K formulas with duals)
- Validate feasibility gates on each run (timeout <20%, valid fraction >=15%, 3+ GoalCategory types)
- Store output in data/ with proper .gitignore coverage
- Create a reproducible shell script for future re-runs
- Document actual metrics for downstream task consumption

**Non-Goals**:
- Modifying the generator code (that was task 203)
- Seeding known-valid formulas to boost valid fraction (deferred to task 205)
- Implementing streaming export for memory optimization (separate task if needed)
- Running the formal DatasetValidator evaluateGate (it does its own enumeration, not on production files)
- Training ML models on the output

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Memory exhaustion on deep run (50K formulas in batch) | H | M | Monitor memory; if OOM, reduce to 25K or 10K formulas and re-run |
| Valid fraction below 15% hard gate | M | M | Accept natural distribution; document for task 205 to address via enrichment |
| Timeout rate exceeds 20% at complexity 7 | M | L | Reduce max-modal-depth or max-temporal-depth from 3 to 2 |
| Deep run exceeds 12 hours | L | M | Run in background; accept partial results if interrupted |
| Build cache invalidated requiring full rebuild | L | L | Run `lake build dataset_generator` as explicit first step |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Build Verification and Script Creation [COMPLETED]

**Goal**: Verify the build compiles, confirm data/ directory structure, and create a reproducible shell script.

**Tasks**:
- [x] Run `lake build dataset_generator` to confirm executable builds (use cached build if available)
- [x] Verify data/ directory exists with .gitignore covering *.jsonl and *_metadata.json
- [x] Create `scripts/run_dataset_generation.sh` with parameterized medium and deep run commands
- [x] Run a quick smoke test: `lake exe dataset_generator -- --max-complexity 3 --max-formulas 20 --output data/smoke-test.jsonl` to confirm the pipeline works end-to-end
- [x] Verify smoke test output: check JSONL is well-formed, metadata file exists, then clean up smoke test files

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `scripts/run_dataset_generation.sh` - New file: shell script with medium and deep run commands
- `data/` - Verify .gitignore configuration

**Verification**:
- `lake build dataset_generator` exits 0
- Smoke test produces valid JSONL with at least 10 records
- Shell script is executable and correctly parameterized

---

### Phase 2: Medium Production Run [COMPLETED]

**Goal**: Execute the complexity 5 medium run with ~5K formulas and validate feasibility gates.

**Tasks**:
- [x] Execute medium run: `lake exe dataset_generator -- --max-complexity 5 --max-modal-depth 2 --max-temporal-depth 2 --max-formulas 5000 --output data/bmlogic-medium.jsonl --include-duals` *(deviation: altered -- reduced modal/temporal depth from 3 to 2 because exhaustive enumeration at depth 3 did not terminate within 1.5 hours; depth 2 is the CLI default)*
- [x] Monitor progress (generator reports every 100 formulas)
- [x] After completion, read `data/bmlogic-medium_metadata.json` for summary statistics
- [x] Count records by label: grep for "valid", "invalid", "timeout" in the JSONL
- [x] Compute feasibility metrics: timeout rate, valid fraction, category diversity
- [x] Evaluate gates: timeout rate <20%, valid fraction >=15% (relaxed from 30% per research), 3+ GoalCategory types
- [x] Spot-check 5-10 JSONL records for well-formedness (proof_trace present for valid, countermodel for invalid)
- [x] Record all metrics for Phase 4 reporting

**Timing**: 30-45 minutes (10-30 min compute + validation)

**Depends on**: 1

**Files to modify**:
- `data/bmlogic-medium.jsonl` - New file: medium run output (~5K records)
- `data/bmlogic-medium_metadata.json` - New file: auto-generated metadata

**Verification**:
- JSONL file exists with at least 3000 records (accounting for filtering and dedup)
- Metadata file exists with valid JSON
- Timeout rate < 20%
- Valid fraction >= 15%
- At least 3 distinct GoalCategory types in output

---

### Phase 3: Deep Production Run [NOT STARTED]

**Goal**: Execute the complexity 7 deep run with ~50K formulas in hybrid mode and validate feasibility gates.

**Tasks**:
- [ ] Execute deep run in background: `lake exe dataset_generator -- --max-complexity 7 --max-modal-depth 3 --max-temporal-depth 3 --max-formulas 50000 --output data/bmlogic-deep.jsonl --mode hybrid --include-duals`
- [ ] Monitor memory usage periodically during the run (if feasible)
- [ ] If the run fails with OOM, re-run with --max-formulas 25000 and document the reduction
- [ ] After completion, read `data/bmlogic-deep_metadata.json` for summary statistics
- [ ] Count records by label: valid, invalid, timeout
- [ ] Compute feasibility metrics: timeout rate, valid fraction, category diversity
- [ ] Evaluate gates: timeout rate <20%, valid fraction >=15%, 3+ GoalCategory types
- [ ] Spot-check 5-10 JSONL records for well-formedness
- [ ] Record all metrics for Phase 4 reporting

**Timing**: 2-12 hours compute + 15 minutes validation

**Depends on**: 2

**Files to modify**:
- `data/bmlogic-deep.jsonl` - New file: deep run output (~50K records)
- `data/bmlogic-deep_metadata.json` - New file: auto-generated metadata

**Verification**:
- JSONL file exists with at least 20000 records (hybrid mode + filtering)
- Metadata file exists with valid JSON
- Timeout rate < 20%
- Valid fraction >= 15%
- At least 3 distinct GoalCategory types in output

---

### Phase 4: Validation Summary and Documentation [NOT STARTED]

**Goal**: Create a summary documenting both runs with actual metrics, feasibility gate results, and guidance for downstream tasks.

**Tasks**:
- [ ] Compile metrics from both runs into a structured comparison table
- [ ] Document any deviations from targets (especially valid fraction)
- [ ] Document the actual file sizes and record counts
- [ ] Note any issues encountered (memory, timeouts, gate failures)
- [ ] Verify data/ .gitignore properly excludes production JSONL files from git
- [ ] Create implementation summary with all metrics and file paths
- [ ] Record guidance for task 205 (benchmark curation): which files to use, valid fraction characteristics, diversity profile

**Timing**: 30 minutes

**Depends on**: 2, 3

**Files to modify**:
- Implementation summary artifact (created during postflight)

**Verification**:
- Summary contains metrics for both medium and deep runs
- All feasibility gate evaluations documented with pass/fail
- File paths and sizes recorded for downstream consumption

## Testing & Validation

- [ ] Smoke test passes (Phase 1): quick 20-formula run produces valid output
- [ ] Medium run JSONL is well-formed: every line parses as valid JSON
- [ ] Medium run feasibility gates: timeout <20%, valid >=15%, 3+ categories
- [ ] Deep run JSONL is well-formed: every line parses as valid JSON
- [ ] Deep run feasibility gates: timeout <20%, valid >=15%, 3+ categories
- [ ] Both metadata files contain valid JSON with expected fields
- [ ] data/.gitignore excludes *.jsonl and *_metadata.json from version control

## Artifacts & Outputs

- `data/bmlogic-medium.jsonl` - Medium production dataset (~5K formulas)
- `data/bmlogic-medium_metadata.json` - Medium run metadata
- `data/bmlogic-deep.jsonl` - Deep production dataset (~50K formulas)
- `data/bmlogic-deep_metadata.json` - Deep run metadata
- `scripts/run_dataset_generation.sh` - Reproducible run script
- Implementation summary with metrics comparison

## Rollback/Contingency

If either production run fails or produces unusable output:
1. Delete the failed JSONL and metadata files from data/
2. Adjust parameters (reduce max-formulas, reduce complexity, reduce modal/temporal depth)
3. Re-run with adjusted parameters
4. If the generator itself has bugs, create a follow-up task to fix the generator code (task 203 scope)

For OOM on the deep run: reduce --max-formulas from 50000 to 25000 or 10000 in increments until the run completes successfully. Document the actual achievable scale.
