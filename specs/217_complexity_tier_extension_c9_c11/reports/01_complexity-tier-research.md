# Research Report: Complexity Tier Extension to C9/C11

- **Task**: 217 - Complexity tier extension to C9/C11
- **Started**: 2026-05-29T12:00:00Z
- **Completed**: 2026-05-29T12:45:00Z
- **Effort**: Medium-high (implementation involves Lean executable extension + Python pipeline)
- **Dependencies**: None (builds on existing Task 213 infrastructure)
- **Sources/Inputs**:
  - `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- formula enumeration with memoization
  - `Theories/Bimodal/Automation/DatasetExport.lean` -- JSONL streaming pipeline + CLI (dataset_generator executable)
  - `Theories/Bimodal/Automation/DatasetGenerator.lean` -- labeling pipeline (decision procedure integration)
  - `Theories/Bimodal/Automation/BenchmarkAnchors.lean` -- axiom instance generation for BMLogic-Bench
  - `Theories/Bimodal/Automation/EnumBenchmark.lean` -- feasibility gates for c5-c7
  - `Theories/Bimodal/Automation/SuccessPatterns.lean` -- PatternKey structure definition
  - `Theories/Bimodal/Automation/DataExport.lean` -- JSON serialization (PatternKey.toJson, etc.)
  - `scripts/run_dataset_generation.sh` -- production run script (c5, c7)
  - `scripts/curate_benchmark.py` -- benchmark curation with stratified sampling
  - `data/bmlogic-c5.jsonl`, `data/bmlogic-c7.jsonl` -- existing datasets
  - `data/bmlogic-bench.jsonl` -- existing benchmark (727 records)
  - `data/bmlogic-bench_metadata.json`, `data/bmlogic-c5_metadata.json`, `data/bmlogic-c7_metadata.json`
- **Artifacts**:
  - This report: `specs/217_complexity_tier_extension_c9_c11/reports/01_complexity-tier-research.md`
- **Standards**: status-markers.md, artifact-management.md

---

## Executive Summary

- C9 exhaustive enumeration is feasible with the current infrastructure, projecting ~300K-1.8M records (depending on depth bounds), requiring ~2-6 hours of compute and producing ~320MB-1.9GB JSONL files.
- C11 exhaustive enumeration is not feasible (~66M records, ~68GB), requiring stratified sampling with complexity-bucketed quotas.
- The 14-field training schema (c5/c7) is well-defined and can be extended with `max_modal_depth` and `max_temporal_depth` as first-class filter fields by adding them to both `PatternKey.toJson` and `DifficultyMetrics.toJson`.
- The existing `FormulaEnumerator` already supports both exhaustive and random sampling; a new `stratified` SamplingMode must be added for c11-scale datasets.
- The benchmark already contains 115 very_hard records (complexity 10-63), but none at complexity 8-9; the very_hard+ slice needs 100+ records drawn from c9 exhaustive enumeration.
- Wall-clock compute time is dominated by enumeration (Catalan-like growth), not decision procedure labeling (sub-millisecond per formula at c7).

---

## Context and Scope

This research supports extending the BMLogic training dataset from its current c5/c7 exhaustive coverage to c9 and c11 tiers. The task description specifies:

- `bmlogic-c9.jsonl`: exhaustive (if feasible) or stratified-sampled at complexity <= 9
- `bmlogic-c11.jsonl`: stratified-sampled at complexity <= 11
- 14-field schema compatibility with c5/c7
- `very_hard+` benchmark slice with 100+ records at complexity 8-9
- `max_temporal_depth` and `max_modal_depth` as first-class filter fields

---

## Findings

### 1. Current Formula Enumeration Infrastructure

The dataset generation pipeline consists of three Lean modules and one shell driver:

**Executable**: `lake exe dataset_generator` (root: `Bimodal.Automation.DatasetExport`)

**Pipeline flow**:
1. `FormulaEnumerator.generateFormulas` -- enumerate/sample formulas per `EnumParams`
2. `FormulaEnumerator.enrichWithDuals` -- optional 2x temporal dual augmentation
3. `DatasetGenerator.labelFormula` -- per-formula decision procedure + proof trace extraction
4. `DatasetExport.writeRecordJSONL` -- streaming JSONL output (no in-memory accumulation)
5. `DatasetExport.writeMetadata` -- companion `_metadata.json` file

**CLI flags** (from `DatasetExport.parseCLIArgs`):
```
--max-complexity N      (default: 5)
--max-modal-depth N     (default: 2)
--max-temporal-depth N  (default: 2)
--max-formulas N        (default: 5000)
--valid-seed-count N    (default: 500)
--output PATH           (default: data/bmlogic.jsonl)
--mode MODE             exhaustive|random|hybrid (default: exhaustive)
--include-duals         temporal dual augmentation
```

**Production run parameters** (from `scripts/run_dataset_generation.sh`):
- C5: `--max-complexity 5 --max-modal-depth 2 --max-temporal-depth 2 --valid-seed-count 2000 --mode exhaustive --include-duals`
- C7: `--max-complexity 7 --max-modal-depth 2 --max-temporal-depth 2 --max-formulas 50000 --valid-seed-count 5000 --mode exhaustive --include-duals`

**Memoization**: The core enumerator (`enumExactHelper`) uses a `Std.HashMap` cache keyed by `(sizeBudget, modalBudget, temporalBudget)`. At complexity 5 there are only 27 unique argument triples despite 1,027 recursive calls in the naive version. This design extends cleanly to higher complexity.

### 2. The 14-Field Training Schema

The c5/c7 JSONL files use this 14-field schema (defined in `DatasetExport.DatasetRecord`):

| # | Field | Type | Description |
|---|-------|------|-------------|
| 1 | `id` | string | Unique ID (`bmlogic-NNNNN`) |
| 2 | `split` | string | `train`/`val`/`test` (hash-based 80/10/10) |
| 3 | `formula_str` | string | Pretty-printed unicode formula |
| 4 | `formula_ast` | object | Recursive JSON AST with `tag` discriminator |
| 5 | `frame_class` | string | Always `"Base"` |
| 6 | `label` | string | `"valid"`, `"invalid"`, or `"timeout"` |
| 7 | `proof_trace` | object/null | `{height, axioms_used, rules_applied}` for valid |
| 8 | `countermodel` | object/null | `{trueAtoms, falseAtoms, formula}` for invalid |
| 9 | `pattern_key` | object | `{modalDepth, temporalDepth, impCount, complexity, topOperator}` |
| 10 | `metrics` | object | `{complexity, modalDepth, temporalDepth, impCount, atomCount, decisionTimeMs, difficultyTier}` |
| 11 | `augmentation` | object/null | `{source, original_formula_str}` for duals |
| 12 | `formula_sexpr` | string | Canonical s-expression |
| 13 | `formula_tokens` | array | Prefix token list for transformers |
| 14 | `pattern_features` | array | Numeric feature vector `[md, td, ic, c, op]` |

**Key observation**: `modalDepth` and `temporalDepth` already exist as sub-fields within both `pattern_key` and `metrics`, but they are not top-level filter fields. The task requires promoting them to first-class fields for efficient filtering.

### 3. Complexity Growth Analysis

**Observed formula counts by exact complexity** (c7 dataset, 5 atoms, modal-2, temporal-2, with duals+seeds):

| Complexity | Exact Count | Cumulative | Growth Ratio |
|------------|-------------|------------|--------------|
| 3 | 41 | 41 | -- |
| 4 | 144 | 185 | 3.5x |
| 5 | 1,334 | 1,519 | 9.3x |
| 6 | 5,918 | 7,437 | 4.4x |
| 7 | 42,467 | 49,904 | 7.2x |

**Average growth factor**: ~6x per complexity level (geometric mean of ratios 4-7).

**Projections** (at 6x average growth):

| Complexity | Projected Exact | Projected Cumulative | File Size (est.) |
|------------|-----------------|---------------------|------------------|
| 8 | ~255K | ~305K | ~320 MB |
| 9 | ~1.5M | ~1.8M | ~1.9 GB |
| 10 | ~9.2M | ~11M | ~11.5 GB |
| 11 | ~55M | ~66M | ~69 GB |

**Decision procedure timing**: Sub-millisecond at c7 (only 3 of 49,904 records had >0ms decision time). Timeout rate is stable at ~2.8-4.2% across complexity levels.

**Timeout distribution by complexity**:
| Complexity | Timeouts | Total | Rate |
|------------|----------|-------|------|
| 3 | 1 | 41 | 2.4% |
| 4 | 13 | 144 | 9.0% |
| 5 | 39 | 1,334 | 2.9% |
| 6 | 246 | 5,918 | 4.2% |
| 7 | 1,201 | 42,467 | 2.8% |

### 4. Feasibility Assessment

**C9 Exhaustive**: FEASIBLE with caveats.
- Projected ~1.8M records, ~1.9 GB JSONL file
- Wall-clock time: ~2-6 hours (enumeration-dominated)
- Memory: The memoization cache will hold more entries but HashMap scales well
- The `--max-formulas 50000` cap on c7 was not actually binding (c7 produced exactly 49,904); for c9 the cap should be raised to 2,000,000
- Git LFS tracking will be needed (file exceeds GitHub 100MB limit)
- The task description estimate of "300K-800K records" is achievable if modal/temporal depth bounds are kept at 2; the full ~1.8M includes axiom-seeded valid formulas

**C11 Exhaustive**: NOT FEASIBLE.
- Projected ~66M records, ~69 GB file
- Wall-clock time: ~3-9 days
- The task description correctly identifies this as requiring stratified sampling

### 5. Stratified Sampling Strategy for C11

The existing infrastructure provides building blocks but needs a new sampling mode:

**Current `SamplingMode` options**: `exhaustive`, `random`, `hybrid`

**Proposed `stratified` mode** should:
1. Run exhaustive enumeration up to c9 (using existing memoized enumerator)
2. For c10-c11, use `sampleFormulas` (deterministic LCG) with complexity-bucketed quotas
3. Apply per-stratum targets: e.g., 200K records at exact c10, 300K at exact c11
4. Maintain uniform distribution across modal depth x temporal depth x topOperator cells
5. Deduplicate and label via the streaming pipeline

**Quota allocation for c11 stratified** (targeting ~500K-2M total):
- c1-c9: Include entire exhaustive enumeration (~1.8M from c9 dataset, or downsample)
- c10: Sample ~100K-300K from the ~9.2M exhaustive space (1-3% sample rate)
- c11: Sample ~100K-300K from the ~55M exhaustive space (0.2-0.5% sample rate)

**Implementation approach**: Add a `--stratified-quotas` CLI flag accepting per-level caps, and add `SamplingMode.stratified` to the Lean enum. The sampling loop would enumerate exact complexity levels and either exhaustively include or LCG-sample at each level.

### 6. max_temporal_depth and max_modal_depth as First-Class Fields

**Current state**: `modalDepth` and `temporalDepth` are computed by `Formula.modalDepth` and `Formula.temporalDepth` (defined in `Theories/Bimodal/Syntax/Formula.lean`, lines 262-289). They appear as sub-fields of `pattern_key` and `metrics` in every record.

**To promote as first-class filter fields**, two options exist:

**Option A (Lean-side)**: Add them as top-level fields in `DatasetRecord`. This requires modifying `DatasetExport.DatasetRecord`, `labeledToRecord`, and `datasetRecordToJson` to include `"max_modal_depth"` and `"max_temporal_depth"` at the record top level.

**Option B (Python post-processing)**: Add a schema migration script that reads existing JSONL files and injects top-level `max_modal_depth` and `max_temporal_depth` fields extracted from `pattern_key.modalDepth` and `pattern_key.temporalDepth`. This is backward-compatible and simpler.

**Recommendation**: Option A for new datasets (c9, c11), plus Option B for retroactively adding to c5/c7 if schema uniformity is required. The field names should match what the user specifies: `max_modal_depth` and `max_temporal_depth`, which are the formula's actual modal/temporal depth values (not the enumeration bound).

**Important clarification**: The `pattern_key.modalDepth` and `metrics.modalDepth` already record the formula's actual depth. The name `max_modal_depth` in the task description likely refers to promoting these to top-level filter fields for efficient querying (e.g., `jq 'select(.max_modal_depth <= 1)'`). The enumeration *bound* (the `--max-modal-depth` CLI flag) is a generation parameter, not a per-record field.

### 7. Benchmark Anchors and very_hard+ Integration

**Current benchmark state** (`bmlogic-bench.jsonl`, 727 records):
- easy (c <= 3): 50 records
- medium (c 4-6): 300 records
- hard (c 7-9): 262 records (157 at c7, 46 at c8, 59 at c9)
- very_hard (c >= 10): 115 records (complexity range 10-63)

**Observation**: The existing "hard" tier already covers complexity 7-9 with 262 records. The task asks for a `very_hard+` slice with 100+ records at complexity 8-9. This is distinct from the existing tier naming:

- The current `classify_tier` function (in `DatasetGenerator.lean`, line 244): c <= 3 = easy, c 4-6 = medium, c 7-9 = hard, c >= 10 = very_hard
- The existing benchmark has 105 records at complexity 8-9 (46 at c8 + 59 at c9)
- A `very_hard+` slice would draw from c9 exhaustive enumeration, selecting records with high decision time, deep nesting, or complex structure

**Integration strategy**: After generating `bmlogic-c9.jsonl`, use `curate_benchmark.py` (with adapted tier targets) to draw 100+ "hardest" records from complexity 8-9. Selection criteria should prioritize:
1. Records with `label == "timeout"` (hardest for the decision procedure)
2. Records with `modalDepth == 2 AND temporalDepth == 2` (maximum nesting)
3. Records with highest `impCount` (most complex proof structure)
4. Both valid and invalid records for balanced evaluation

### 8. Existing Lean Infrastructure for Complexity Computation

All complexity-related functions are in `Theories/Bimodal/Syntax/Formula.lean`:

```lean
def complexity : Formula -> Nat  -- connective count + 1 (line 162)
def modalDepth : Formula -> Nat  -- max box nesting (line 262)
def temporalDepth : Formula -> Nat  -- max untl/snce nesting (line 283)
def countImplications : Formula -> Nat  -- imp count (line 303)
```

These are purely structural (no IO, no decision procedure needed), so they are fast for any formula.

The `PatternKey.fromFormula` function (line 115 of `SuccessPatterns.lean`) computes all five pattern dimensions at once:
```lean
def PatternKey.fromFormula (phi : Formula) : PatternKey :=
  { modalDepth := phi.modalDepth
  , temporalDepth := phi.temporalDepth
  , impCount := phi.countImplications
  , complexity := phi.complexity
  , topOperator := goalCategory phi }
```

---

## Decisions

1. **C9 mode**: Exhaustive enumeration (feasible at ~1.8M records, ~1.9 GB).
2. **C11 mode**: Stratified sampling with per-complexity-level quotas (exhaustive is not feasible at ~66M records).
3. **Schema extension**: Add `max_modal_depth` and `max_temporal_depth` as top-level fields to `DatasetRecord`, extending the schema from 14 to 16 fields. The c5/c7 datasets should be retroactively migrated for schema uniformity.
4. **Benchmark integration**: Draw very_hard+ slice from c9 exhaustive enumeration using structural difficulty heuristics.

---

## Recommendations

### Phase 1: Lean-side changes (FormulaEnumerator + DatasetExport)

1. **Add `SamplingMode.stratified`** to the `SamplingMode` inductive type in `FormulaEnumerator.lean`. This mode should accept per-level formula caps.
2. **Add `--stratified-quotas` CLI flag** to `DatasetExport.parseCLIArgs` for specifying per-complexity-level record limits (e.g., `--stratified-quotas 9:exhaustive,10:100000,11:300000`).
3. **Add `max_modal_depth` and `max_temporal_depth` fields** to `DatasetRecord` in `DatasetExport.lean` and update `datasetRecordToJson` and `labeledToRecord`.
4. **Update `EnumParams`** to support a `maxFormulas` value of 2,000,000 for c9 (currently defaults to 5,000).
5. **Raise feasibility gate thresholds** in `EnumBenchmark.lean` to cover c8 and c9 (add new timing gates).

### Phase 2: Shell script and Python changes

6. **Extend `run_dataset_generation.sh`** with `c9` and `c11` run configurations:
   - `c9`: `--max-complexity 9 --max-modal-depth 2 --max-temporal-depth 2 --max-formulas 2000000 --valid-seed-count 10000 --mode exhaustive --include-duals`
   - `c11`: `--max-complexity 11 --max-modal-depth 2 --max-temporal-depth 2 --max-formulas 2000000 --valid-seed-count 20000 --mode stratified --include-duals`
7. **Add schema migration script** (`scripts/migrate_schema_v2.py`) to add `max_modal_depth` and `max_temporal_depth` to existing c5/c7 JSONL files.
8. **Update `validate_datasets.py`** to accept the 16-field schema.

### Phase 3: Benchmark extension

9. **Generate c9 dataset** (expect ~2-6 hours runtime).
10. **Curate very_hard+ benchmark slice** from c9 data: select 100+ records at complexity 8-9 using difficulty heuristics (timeout, max depth, imp count).
11. **Update `bmlogic-bench_metadata.json`** with new very_hard+ tier statistics.

### Phase 4: Infrastructure

12. **Git LFS tracking** for `bmlogic-c9.jsonl` and `bmlogic-c11.jsonl`.
13. **Update `data/README.md`** with new file inventory.
14. **Update `croissant.json`** with new dataset metadata.

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| C9 enumeration exceeds memory | Low | High | Monitor with `lake exe enum_benchmark`; the HashMap cache scales linearly |
| C9 runtime exceeds 6 hours | Medium | Medium | Add `--max-formulas` cap at 1.5M; keep modal/temporal depth at 2 |
| C11 stratified sampling has poor coverage | Medium | Medium | Use LCG with diversity-aware seeds; validate operator distribution |
| Timeout rate spikes at c8-c9 | Low | Medium | Current rate is stable ~3%; monitor and adjust decision fuel if needed |
| JSONL file too large for Git LFS | Low | Medium | Git LFS handles multi-GB files; split into shards if needed |
| Schema migration breaks downstream tools | Low | Medium | New fields are additive (16 fields superset of 14); update validators first |

---

## Appendix

### A. Cross-Tabulation: Complexity x Modal Depth x Temporal Depth (c7)

Significant cells only (count > 10):

| Complexity | Modal | Temporal | Count |
|------------|-------|----------|-------|
| 3 | 0 | 1 | 32 |
| 4 | 1 | 0 | 48 |
| 4 | 1 | 1 | 96 |
| 5 | 0 | 0 | 22 |
| 5 | 0 | 1 | 512 |
| 5 | 0 | 2 | 512 |
| 5 | 2 | 0 | 80 |
| 5 | 2 | 1 | 160 |
| 6 | 1 | 0 | 640 |
| 6 | 1 | 1 | 2,560 |
| 6 | 1 | 2 | 2,560 |
| 7 | 0 | 1 | 8,704 |
| 7 | 0 | 2 | 16,384 |
| 7 | 1 | 1 | 2,048 |
| 7 | 1 | 2 | 2,048 |
| 7 | 2 | 0 | 1,424 |
| 7 | 2 | 1 | 5,664 |
| 7 | 2 | 2 | 5,632 |

**Observation**: Temporal-only formulas (modal=0) dominate at high complexity due to binary temporal operators (untl, snce) having faster Catalan-like growth than unary box.

### B. Key File Paths

- Formula complexity: `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Syntax/Formula.lean` (lines 162-289)
- PatternKey: `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Automation/SuccessPatterns.lean` (lines 95-121)
- Dataset generator CLI: `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Automation/DatasetExport.lean` (lines 385-571)
- Formula enumerator: `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Automation/FormulaEnumerator.lean`
- Labeling pipeline: `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Automation/DatasetGenerator.lean`
- Run script: `/home/benjamin/Projects/BimodalLogic/scripts/run_dataset_generation.sh`
- Benchmark curation: `/home/benjamin/Projects/BimodalLogic/scripts/curate_benchmark.py`
- Schema validation: `/home/benjamin/Projects/BimodalLogic/scripts/validate_datasets.py`
- Lakefile executables: `/home/benjamin/Projects/BimodalLogic/lakefile.lean` (lines 38-83)
