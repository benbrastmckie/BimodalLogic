# Implementation Summary: Complexity Tier Extension to C9/C11

- **Task**: 217 - Complexity Tier Extension to C9/C11
- **Status**: PARTIAL (3 of 5 phases completed, 2 partial)
- **Session**: sess_1780330249_5db6da

## What Was Done

### Phase 1: Lean Schema and Enumeration Extensions [COMPLETED]
- Added `max_modal_depth` and `max_temporal_depth` fields to `DatasetRecord` in `DatasetExport.lean`
- Updated `datasetRecordToJson`, `labeledToRecord`, and `Inhabited` instance for 16-field schema
- Added `SamplingMode.stratified` to `FormulaEnumerator.lean`
- Added `stratifiedQuotas` to `CLIArgs` and `EnumParams`
- Implemented `enumerateStratified` with per-level quota support
- Updated `parseCLIArgs` for `--mode stratified` and `--stratified-quotas` flag
- `lake build dataset_generator` compiles successfully

### Phase 2: Shell Script and Run Configuration [COMPLETED]
- Added `run_c9` and `run_c11` functions to `scripts/run_dataset_generation.sh`
- Updated case statement for c9, c11, all
- Added `.gitattributes` entries for c9/c11 Git LFS tracking
- Updated help text with estimated record counts and runtime
- Valid-seed-count reduced from 10K/20K to 500/1000 to avoid O(n^2) MP bottleneck

### Phase 3: Python Schema Migration and Validation Updates [COMPLETED]
- Created `scripts/migrate_schema_v2.py` for retroactive c5/c7 migration to 16-field schema
- Updated `scripts/validate_datasets.py` for 16-field schema (TRAINING_FIELDS includes new fields)
- Added c9/c11 dataset entries to DATASETS list
- Migrated c5 and c7 files: both now have 16 fields, metadata counts match

### Phase 4: Dataset Generation Runs [PARTIAL]
- C9 and C11 full generation requires multi-hour background compute (2-6h and 3-8h respectively)
- Smoke tests passed: c8 exhaustive (5668 records, ~11 min), c11 stratified (100 records, fast)
- Bottleneck identified: `generateValidBatch` O(n^2) MP closure with large seed counts
- Run scripts updated with reduced valid-seed-count (500 for c9, 1000 for c11)
- C5/C7 validation passes with 16-field schema

### Phase 5: Benchmark Curation and Finalization [PARTIAL]
- Created `scripts/curate_very_hard_plus.py` for selecting 100+ records at complexity 8-9
- Script supports `--append` mode to add directly to bmlogic-bench.jsonl
- Updated `data/README.md` with c9/c11 entries and generation instructions
- Actual very_hard+ curation deferred pending c9 dataset generation

## What Remains

1. **Run c9 generation** (background compute, 2-6 hours):
   ```bash
   ./scripts/run_dataset_generation.sh c9
   ```

2. **Run c11 generation** (background compute, 3-8 hours):
   ```bash
   ./scripts/run_dataset_generation.sh c11
   ```

3. **Validate all datasets**:
   ```bash
   python scripts/validate_datasets.py
   ```

4. **Curate very_hard+ benchmark slice** (after c9 is generated):
   ```bash
   python scripts/curate_very_hard_plus.py --append
   python scripts/validate_benchmark.py
   ```

## Performance Observations

- C7 exhaustive enumeration: ~50K formulas, ~15 min
- C8 exhaustive enumeration: ~5.7K formulas (after filter), ~11 min
- C9 exhaustive enumeration: estimated 300K-1.8M formulas, 2-6 hours
- `generateValidBatch(10000)`: >47 min without completing (O(n^2) MP closure)
- `generateValidBatch(2000)`: >26 min without completing
- `generateValidBatch(0)`: enumeration itself still takes >20 min at c9
- C11 stratified enumeration: peaked at 6.9GB RAM for c10/c11 level enumeration

## Key Files Modified

- `Theories/Bimodal/Automation/DatasetExport.lean` - 16-field DatasetRecord, stratified CLI
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - SamplingMode.stratified, enumerateStratified
- `scripts/run_dataset_generation.sh` - c9/c11 run functions with reduced seed counts
- `scripts/validate_datasets.py` - 16-field schema, c9/c11 entries
- `scripts/migrate_schema_v2.py` - schema migration tool (new file)
- `scripts/curate_very_hard_plus.py` - very_hard+ benchmark curation (new file)
- `.gitattributes` - c9/c11 Git LFS tracking
- `data/README.md` - updated file inventory and generation instructions
- `data/bmlogic-c5.jsonl` - migrated to 16-field schema
- `data/bmlogic-c7.jsonl` - migrated to 16-field schema

## Plan Deviations

- Phase 4: Full c9/c11 dataset generation deferred to background compute (multi-hour runs exceed session budget). Smoke tests verified pipeline correctness.
- Phase 4: Valid-seed-count reduced from 10K/20K to 500/1000 to avoid O(n^2) MP closure bottleneck.
- Phase 5: Very hard+ benchmark curation tool created but actual curation deferred pending c9 data.
- Phase 5: Benchmark validation deferred pending c9 data for very_hard+ records.
