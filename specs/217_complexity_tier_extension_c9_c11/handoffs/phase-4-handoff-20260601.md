# Phase 4 Handoff: Dataset Generation Runs

## Immediate Next Action

Run the c9 and c11 dataset generation as background jobs:

```bash
# Ensure build is current
lake build dataset_generator

# Run c9 (2-6 hours)
nohup ./scripts/run_dataset_generation.sh c9 > /tmp/c9-run.log 2>&1 &

# Run c11 (3-8 hours) - can run in parallel if enough RAM (needs ~8GB)
nohup ./scripts/run_dataset_generation.sh c11 > /tmp/c11-run.log 2>&1 &
```

After both complete:
```bash
python scripts/validate_datasets.py
python scripts/curate_very_hard_plus.py --append
python scripts/validate_benchmark.py
```

## Current Proof/Code State

- `lake build dataset_generator` succeeds
- c5/c7 datasets migrated to 16-field schema (verified)
- `SamplingMode.stratified` and `enumerateStratified` implemented and smoke-tested
- `parseQuotas` and `--stratified-quotas` CLI parsing working

## Key Decisions

1. **Valid-seed-count reduced**: 10K->500 (c9), 20K->1000 (c11) to avoid `generateValidBatch` O(n^2) MP closure bottleneck
2. **C9 mode remains exhaustive**: The enumeration is complete but slow; stratified would require the same enumeration work
3. **C11 uses stratified**: Quotas at c10:100K, c11:300K to limit the enormous c10/c11 formula spaces

## Deviations

- Full c9/c11 generation deferred to background compute (plan anticipated this possibility)
- Valid-seed-count values in run script differ from original plan values
