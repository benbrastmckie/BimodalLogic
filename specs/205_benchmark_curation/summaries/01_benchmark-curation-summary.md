# Implementation Summary: BMLogic-Bench Benchmark Curation

**Task**: 205 - Curate stratified evaluation benchmark (BMLogic-Bench)
**Status**: Implemented
**Session**: sess_1780088191_17e016_a
**Date**: 2026-05-29

## What Was Implemented

BMLogic-Bench, a stratified evaluation benchmark of 727 formulas for decidable bimodal logic TM, was built through a 5-phase pipeline:

1. **Lean Axiom Instance Generator** (`BenchmarkAnchors.lean`): Generated 724 concrete formula instances from all 42 BX axiom schemata with varied substitutions (atoms p, q, r plus modal/temporal sub-formulas). Registered as `lake exe benchmark_anchors`.

2. **Python Curation Script** (`curate_benchmark.py`): Loaded production data (59K records), axiom instances (724), and generated 1,071 near-miss mutations via 8 mutation operators (swap_args, swap_op, negate, drop_box, add_box, atom_swap, bot_inject, weaken_guard). Performed stratified sampling to produce 1,771 candidate entries.

3. **Oracle Validation** (`BenchmarkOracle.lean`): Built a Lean executable with a hand-rolled JSON formula AST parser that processes JSONL records. Validated all 1,771 candidates via the decision procedure with zero parse errors and zero label mismatches against production data.

4. **Final Export** (`finalize_benchmark.py`): Performed final stratified sampling from the validated pool, assigned sequential benchmark IDs, and exported `data/bmlogic-bench.jsonl` with comprehensive metadata.

5. **Verification** (`verify_benchmark.py`): Independent verification confirmed all critical checks pass.

## Key Metrics

| Metric | Value | Target |
|--------|-------|--------|
| Total formulas | 727 | 500-1000 |
| Valid | 340 (46.8%) | ~50% |
| Invalid | 387 (53.2%) | ~50% |
| Easy tier | 50 (6.9%) | 15-20% |
| Medium tier | 300 (41.3%) | 40% |
| Hard tier | 262 (36.0%) | 30-35% |
| Very hard tier | 115 (15.8%) | 10% |
| Axiom coverage | 42/42 | 42/42 |
| Label mismatches | 0 | 0 |
| Duplicate formulas | 0 | 0 |

## Artifacts Created

| Artifact | Type | Description |
|----------|------|-------------|
| `Theories/Bimodal/Automation/BenchmarkAnchors.lean` | Lean module | Axiom instance generator |
| `Theories/Bimodal/Automation/BenchmarkOracle.lean` | Lean module | Formula oracle with JSON parser |
| `scripts/curate_benchmark.py` | Python script | Curation pipeline |
| `scripts/validate_benchmark.py` | Python script | Validation report |
| `scripts/finalize_benchmark.py` | Python script | Final export and metadata |
| `scripts/verify_benchmark.py` | Python script | Independent verification |
| `data/bmlogic-bench.jsonl` | Data (gitignored) | Final benchmark (727 records) |
| `data/bmlogic-bench_metadata.json` | Data (gitignored) | Benchmark metadata |
| `data/axiom-instances.jsonl` | Data (gitignored) | Axiom instances (724 records) |

## Plan Deviations

- **Easy tier proportion**: Adjusted from 20% to 10% target due to severe valid formula scarcity at complexity <= 3. The production dataset has zero valid formulas at this tier, and only 3 axiom instances qualify. Final result: 6.9%.
- **Near-miss tracking**: Mutation metadata (source="mutation", mutation_type) is partially lost during oracle re-labeling because the oracle reconstructs records from scratch. The mutations are present in the benchmark but not explicitly tagged as "near-miss" in all cases.
- **Oracle executable**: Created `BenchmarkOracle.lean` rather than extending `dataset_generator` as the plan suggested. This avoided modifying existing infrastructure and provided a cleaner separation of concerns.
- **Separate validate_benchmark.py**: Created as a thin analysis wrapper rather than a full orchestrator, since the Lean oracle handles the heavy lifting directly.

## Build Verification

- `lake build` passes with zero errors
- Zero sorries in modified files
- Zero vacuous definitions
- Zero new axioms introduced
- All 42 axiom constructors covered in benchmark
