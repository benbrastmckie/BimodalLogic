# Implementation Plan: Complexity Tier Extension to C9/C11

- **Task**: 217 - Complexity tier extension to C9/C11
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours
- **Dependencies**: None (builds on existing Task 213 infrastructure)
- **Research Inputs**: reports/01_complexity-tier-research.md
- **Artifacts**: plans/01_complexity-tier-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan extends the BMLogic training dataset pipeline from its current c5/c7 exhaustive coverage to c9 (exhaustive, ~300K-1.8M records) and c11 (stratified-sampled, ~500K-2M records). The work spans four areas: Lean-side schema and enumeration changes, Python tooling updates, shell script orchestration, and benchmark curation. Definition of done: `bmlogic-c9.jsonl` and `bmlogic-c11.jsonl` pass schema validation with the new 16-field schema, the `very_hard+` benchmark slice contains 100+ records at complexity 8-9, and all existing datasets are retroactively migrated.

### Research Integration

Key findings from `reports/01_complexity-tier-research.md`:
- C9 exhaustive enumeration is feasible (~1.8M records, ~1.9 GB, ~2-6 hours compute)
- C11 exhaustive enumeration is not feasible (~66M records); requires stratified sampling with per-complexity-level quotas
- The 14-field schema should be extended to 16 fields by promoting `max_modal_depth` and `max_temporal_depth` to top-level record fields
- A new `SamplingMode.stratified` variant is needed with per-level quota support
- The existing benchmark has 105 records at c8-c9 but lacks a dedicated `very_hard+` slice
- Decision procedure timing is sub-millisecond at c7; timeout rate stable at ~3%

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No direct roadmap items. This task advances the ML training data infrastructure for the bimodal logic decision procedure. The ROADMAP.md is focused on completeness proof milestones, not dataset generation.

## Goals & Non-Goals

**Goals**:
- Generate `bmlogic-c9.jsonl` via exhaustive enumeration with the 16-field schema
- Generate `bmlogic-c11.jsonl` via stratified sampling with the 16-field schema
- Add `max_modal_depth` and `max_temporal_depth` as top-level fields in `DatasetRecord`
- Retroactively migrate c5/c7 JSONL files to the 16-field schema
- Curate a `very_hard+` benchmark slice with 100+ records at complexity 8-9
- Update validation scripts, run scripts, and metadata files

**Non-Goals**:
- Changing the decision procedure or its timeout behavior
- Implementing sharding for large JSONL files (deferred unless file sizes exceed practical limits)
- Modifying the benchmark tier classification function in `DatasetGenerator.lean`
- Full HuggingFace dataset card and croissant.json update (separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C9 enumeration exceeds memory | H | L | HashMap cache scales linearly; monitor with smoke test at c8 first |
| C9 runtime exceeds 6 hours | M | M | Set `--max-formulas 2000000` cap; keep modal/temporal depth at 2 |
| C11 stratified sampling has poor operator distribution | M | M | Use diversity-aware LCG seeds; validate operator distribution post-hoc |
| Schema migration breaks downstream consumers | M | L | New fields are additive (16 superset of 14); update validators first |
| JSONL files too large for Git | M | L | Add Git LFS tracking for `data/bmlogic-c9.jsonl` and `data/bmlogic-c11.jsonl` |
| Lean compilation time increases from new SamplingMode | L | L | The stratified mode is runtime-only; compile-time impact is minimal |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Lean Schema and Enumeration Extensions [COMPLETED]

**Goal**: Extend `DatasetRecord` to 16 fields, add `SamplingMode.stratified`, and update CLI parsing to support stratified quotas and higher formula caps.

**Tasks**:
- [x] Add `max_modal_depth : Nat` and `max_temporal_depth : Nat` fields to `DatasetRecord` in `DatasetExport.lean`
- [x] Update `datasetRecordToJson` to emit the two new top-level fields
- [x] Update `labeledToRecord` to populate the new fields from `PatternKey`
- [x] Update the `Inhabited` instance for `DatasetRecord` with default values for the new fields
- [x] Add `SamplingMode.stratified` constructor to the `SamplingMode` inductive in `FormulaEnumerator.lean`
- [x] Add `stratifiedQuotas : List (Nat × Nat)` field to `CLIArgs` (complexity-level, max-records pairs) *(deviation: altered -- also added to `EnumParams` so it's accessible in `generateFormulas`)*
- [x] Extend `parseCLIArgs` to handle `--mode stratified` and `--stratified-quotas` flag (format: `9:exhaustive,10:100000,11:300000`) *(deviation: altered -- format uses `9:0` for exhaustive instead of `9:exhaustive` since quotas are Nat pairs)*
- [x] Implement stratified generation logic in `generateFormulas`: exhaustive up to quota-marked levels, LCG sampling above *(deviation: altered -- implemented as separate `enumerateStratified` function called from `generateFormulas`)*
- [x] Update the `main` function's mode string serialization to handle `SamplingMode.stratified`
- [x] Run `lake build dataset_generator` to verify compilation

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` - DatasetRecord, serialization, CLI, main
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - SamplingMode, stratified generation

**Verification**:
- `lake build dataset_generator` succeeds
- Smoke test: `lake exe dataset_generator -- --max-complexity 3 --max-formulas 20 --output /tmp/smoke.jsonl` produces records with `max_modal_depth` and `max_temporal_depth` top-level fields
- Stratified mode parses: `--mode stratified --stratified-quotas 3:exhaustive` does not crash

---

### Phase 2: Shell Script and Run Configuration [NOT STARTED]

**Goal**: Add c9 and c11 run configurations to the production script, and add Git LFS tracking for large output files.

**Tasks**:
- [ ] Add `run_c9` function to `scripts/run_dataset_generation.sh` with parameters: `--max-complexity 9 --max-modal-depth 2 --max-temporal-depth 2 --max-formulas 2000000 --valid-seed-count 10000 --mode exhaustive --include-duals --output data/bmlogic-c9.jsonl`
- [ ] Add `run_c11` function with parameters: `--max-complexity 11 --max-modal-depth 2 --max-temporal-depth 2 --max-formulas 2000000 --valid-seed-count 20000 --mode stratified --stratified-quotas 9:exhaustive,10:100000,11:300000 --include-duals --output data/bmlogic-c11.jsonl`
- [ ] Update the `case` statement to accept `c9`, `c11`, and `all` (which now runs c5, c7, c9, c11)
- [ ] Update help text with estimated record counts and runtime
- [ ] Add `.gitattributes` entries for Git LFS tracking of `data/bmlogic-c9.jsonl` and `data/bmlogic-c11.jsonl`
- [ ] Run a quick c9 smoke test at `--max-complexity 8 --max-formulas 500` to validate the pipeline end-to-end before committing to the full c9 run

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `scripts/run_dataset_generation.sh` - new run functions and case entries
- `.gitattributes` - Git LFS tracking rules (create if not exists)

**Verification**:
- `./scripts/run_dataset_generation.sh help` shows c9 and c11 options
- Smoke test at c8 with 500 formulas produces valid JSONL with 16 fields
- `.gitattributes` contains `data/bmlogic-c9.jsonl filter=lfs` entries

---

### Phase 3: Python Schema Migration and Validation Updates [NOT STARTED]

**Goal**: Create a schema migration script for c5/c7 retroactive upgrade and update the validation script for the 16-field schema.

**Tasks**:
- [ ] Create `scripts/migrate_schema_v2.py` that reads existing JSONL files and injects `max_modal_depth` and `max_temporal_depth` top-level fields extracted from `pattern_key.modalDepth` and `pattern_key.temporalDepth`
- [ ] The migration script should write to a `.tmp` file and atomically rename to avoid data loss
- [ ] Add `--dry-run` mode that prints sample records without modifying files
- [ ] Update `TRAINING_FIELDS` in `scripts/validate_datasets.py` to include `max_modal_depth` and `max_temporal_depth` (16-field set)
- [ ] Add `bmlogic-c9` and `bmlogic-c11` dataset entries to the `DATASETS` list in `validate_datasets.py`
- [ ] Run `scripts/migrate_schema_v2.py` on `data/bmlogic-c5.jsonl` and `data/bmlogic-c7.jsonl` to retroactively add the new fields
- [ ] Verify migration: first and last records of c5/c7 contain the two new top-level fields

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `scripts/migrate_schema_v2.py` - new file for schema migration
- `scripts/validate_datasets.py` - updated field set and dataset list
- `data/bmlogic-c5.jsonl` - retroactive migration (in-place via atomic rename)
- `data/bmlogic-c7.jsonl` - retroactive migration (in-place via atomic rename)

**Verification**:
- `python scripts/migrate_schema_v2.py --dry-run data/bmlogic-c5.jsonl` shows correct field injection
- After migration, `python scripts/validate_datasets.py` passes for c5 and c7
- Line counts of c5/c7 are unchanged after migration

---

### Phase 4: Dataset Generation Runs [NOT STARTED]

**Goal**: Execute c9 exhaustive enumeration and c11 stratified sampling to produce the final dataset files.

**Tasks**:
- [ ] Run `./scripts/run_dataset_generation.sh c9` and capture timing and output statistics
- [ ] Verify `data/bmlogic-c9.jsonl` record count is in the expected 300K-1.8M range
- [ ] Verify `data/bmlogic-c9_metadata.json` is consistent with the JSONL line count
- [ ] Run `./scripts/run_dataset_generation.sh c11` and capture timing and output statistics
- [ ] Verify `data/bmlogic-c11.jsonl` record count is in the expected 500K-2M range
- [ ] Verify `data/bmlogic-c11_metadata.json` is consistent with the JSONL line count
- [ ] Run `python scripts/validate_datasets.py` to confirm all four datasets (c5, c7, c9, c11) pass 16-field schema validation
- [ ] Spot-check operator distribution in c11 stratified data (verify at least 4 GoalCategory types at c10+ records)

**Timing**: 1.5 hours (active work; compute time is 2-6 hours but runs unattended)

**Depends on**: 2

**Files to modify**:
- `data/bmlogic-c9.jsonl` - generated output
- `data/bmlogic-c9_metadata.json` - generated metadata
- `data/bmlogic-c11.jsonl` - generated output
- `data/bmlogic-c11_metadata.json` - generated metadata

**Verification**:
- `wc -l data/bmlogic-c9.jsonl` returns a count in range 300K-1.8M
- `wc -l data/bmlogic-c11.jsonl` returns a count in range 500K-2M
- `python scripts/validate_datasets.py` exits 0
- Timeout rate is below 20% for both datasets

---

### Phase 5: Benchmark Curation and Finalization [NOT STARTED]

**Goal**: Curate a `very_hard+` benchmark slice from c9 data and update benchmark metadata.

**Tasks**:
- [ ] Extend `scripts/curate_benchmark.py` (or create a dedicated script) to select 100+ records from c9 at complexity 8-9 using difficulty heuristics: prioritize `label == "timeout"`, then `modalDepth == 2 AND temporalDepth == 2`, then highest `impCount`
- [ ] Ensure balanced mix of valid and invalid labels in the very_hard+ slice
- [ ] Generate the very_hard+ slice and append to or integrate with `data/bmlogic-bench.jsonl`
- [ ] Update `data/bmlogic-bench_metadata.json` with new tier statistics including very_hard+ count
- [ ] Update `data/README.md` with new file inventory (c9, c11 entries, updated sizes and record counts)
- [ ] Run `python scripts/validate_benchmark.py` to verify benchmark integrity

**Timing**: 1.5 hours

**Depends on**: 3, 4

**Files to modify**:
- `scripts/curate_benchmark.py` - extend or add very_hard+ selection logic
- `data/bmlogic-bench.jsonl` - updated benchmark with very_hard+ records
- `data/bmlogic-bench_metadata.json` - updated statistics
- `data/README.md` - updated file inventory

**Verification**:
- The very_hard+ slice contains at least 100 records at complexity 8-9
- `python scripts/validate_benchmark.py` exits 0
- `data/bmlogic-bench_metadata.json` shows updated tier counts
- `data/README.md` lists all four training datasets (c5, c7, c9, c11)

## Testing & Validation

- [ ] `lake build dataset_generator` compiles without errors
- [ ] Smoke test at c3 produces records with 16 fields including `max_modal_depth` and `max_temporal_depth`
- [ ] `python scripts/validate_datasets.py` passes for all datasets (c5, c7, c9, c11)
- [ ] `python scripts/validate_benchmark.py` passes for the updated benchmark
- [ ] Schema migration preserves exact line counts in c5/c7 files
- [ ] c9 JSONL record count is in the 300K-1.8M range
- [ ] c11 JSONL record count is in the 500K-2M range
- [ ] very_hard+ benchmark slice has 100+ records at complexity 8-9
- [ ] Git LFS tracking is configured for c9 and c11 files

## Artifacts & Outputs

- `specs/217_complexity_tier_extension_c9_c11/plans/01_complexity-tier-plan.md` (this plan)
- `data/bmlogic-c9.jsonl` - exhaustive c9 dataset
- `data/bmlogic-c9_metadata.json` - c9 metadata
- `data/bmlogic-c11.jsonl` - stratified c11 dataset
- `data/bmlogic-c11_metadata.json` - c11 metadata
- `data/bmlogic-c5.jsonl` - retroactively migrated to 16-field schema
- `data/bmlogic-c7.jsonl` - retroactively migrated to 16-field schema
- `data/bmlogic-bench.jsonl` - updated with very_hard+ slice
- `data/bmlogic-bench_metadata.json` - updated tier statistics
- `scripts/migrate_schema_v2.py` - schema migration tool
- `.gitattributes` - Git LFS configuration

## Rollback/Contingency

- If c9 enumeration exceeds memory or hits an unrecoverable error, fall back to `--max-formulas 500000` cap and note reduced coverage in metadata
- If c11 stratified sampling produces poor distribution, adjust quotas (increase c10/c11 sample rates) and re-run
- Schema migration creates `.tmp` files before atomic rename; original files recoverable via `git checkout` if migration corrupts data
- If Lean changes break existing tests, revert `DatasetExport.lean` and `FormulaEnumerator.lean` to HEAD and investigate
- Benchmark curation is additive; the existing benchmark can be restored from git history
