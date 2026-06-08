# Implementation Plan: Task #295

- **Task**: 295 - Diagnostic audit and stress-test of the dataset generation pipeline (c4-c7)
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (tasks 284, 285, 287, 289 all completed)
- **Research Inputs**: specs/295_dataset_pipeline_diagnostic_audit/reports/01_diagnostic-audit.md
- **Artifacts**: plans/01_diagnostic-audit.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan exercises the full dataset generation pipeline at complexity levels c4-c7 after four recent enhancements (tasks 284, 285, 287, 289), collects profiling data (timing, memory, formula counts, cache statistics), validates correctness of prefilter patterns, cache behavior, and normalization round-trips, applies targeted code quality fixes identified by research, and produces a final diagnostic report with quantitative results. The existing c4-c7 datasets in `data/` are stale (generated before the enhancements) and must be regenerated to assess the combined impact.

### Research Integration

The research report (01_diagnostic-audit.md) provides:
- Complete pipeline architecture map (5 stages: enumeration, prefiltering, labeling, normalization, export)
- Post-task-285 formula count projections (8x at c4-c5, 15-100x at c6-c7)
- 10 prioritized improvements ranked by effort/impact
- Verification that all 4 enhancements compile with zero sorries
- Stale dataset baseline metrics for comparison
- Key finding: `sampleOneRandom` not updated with derived operators, `hashDedup` has collision risk, duplicate serialization code exists

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No specific ROADMAP.md items are directly advanced by this diagnostic task. This is an infrastructure audit enabling future dataset enhancement work.

## Goals & Non-Goals

**Goals**:
- Regenerate c4-c5 datasets with current code and collect timing/profiling data
- Profile c6-c7 enumeration to establish memory and time feasibility ceilings
- Validate correctness: prefilter patterns, cache hit rates, label agreement, normalization round-trips
- Fix hashDedup collision risk, consolidate duplicate serialization, update random sampling for derived operators
- Remove dead code (pure `enumerateExhaustive`)
- Produce a diagnostic report with quantitative before/after comparison

**Non-Goals**:
- Implementing memory-bounded enumeration at c7+ (separate task, P10 from research)
- Changing the cache eviction policy (enhancement, not diagnostic)
- Full c6-c7 dataset regeneration (may be infeasible due to formula explosion; profiling only)
- Modifying tableau fuel strategy or timeout parameters
- Box-descent extension for invalid prefilter (enhancement for future task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| c6-c7 enumeration OOM | H | H | Run enumeration-only benchmarks first; use `--max-formulas` cap for labeling; profile with system memory tools |
| `lake build` failure after code changes | H | L | Run `lake build` after each code change phase; revert if broken |
| hashDedup replacement changes dataset contents | M | L | Run before/after comparison on c4 to verify dedup correctness |
| Random sampling changes affect hybrid mode | M | L | Test sampleOneRandom independently before integration |
| Compiled binary execution takes too long | M | M | Set wall-clock timeouts; profile c4-c5 first (fast), then extrapolate c6-c7 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Code Quality Fixes and Build Verification [COMPLETED]

**Goal**: Apply the targeted code quality fixes identified by research (P3-P5, P9 from the prioritized list) and verify the project builds cleanly.

**Tasks**:
- [x] Fix `hashDedup` collision risk in `FormulaEnumerator.lean` (~line 1706): replace `UInt64` hash key with proper `Std.HashSet Formula` or add equality check after hash match to prevent silent formula loss
- [x] Consolidate duplicate `ProofTrace.toJson` between `DatasetGenerator.lean` (line 1767) and `DatasetExport.lean` (line 101, as `proofTraceToJson`): keep one canonical version, import from the other. Same for `DifficultyMetrics.toJson` (DatasetGenerator.lean line 1780) vs `difficultyMetricsToJson` (DatasetExport.lean line 114) *(deviation: altered -- also consolidated `formulaLabelToJson` duplicate)*
- [x] Update `sampleOneRandom` (FormulaEnumerator.lean ~line 850) and `sampleOne` (~line 394) to include derived operator branches (diamond, always, sometimes, next, prev, weak_future, weak_past) matching the existing `enumExactHelper` branches
- [x] Remove dead code: pure `enumerateExhaustive` function (FormulaEnumerator.lean ~line 833) that is superseded by `enumerateWithProgress` (IO version with checkpoint support)
- [x] Remove duplicate `deterministicSampleFormulas` (local `where` version inside `enumerateStratified` vs top-level private version)
- [x] Run `lake build` and verify zero errors, zero new sorries, zero new axioms

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - hashDedup fix, sampleOne/sampleOneRandom derived operator branches, dead code removal
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - serialization consolidation (remove duplicates or redirect)
- `Theories/Bimodal/Automation/DatasetExport.lean` - serialization consolidation (keep canonical versions)

**Verification**:
- `lake build` passes with zero errors
- `grep -r "sorry" Theories/Bimodal/Automation/FormulaEnumerator.lean Theories/Bimodal/Automation/DatasetGenerator.lean Theories/Bimodal/Automation/DatasetExport.lean` returns no new sorries
- `sampleOneRandom` contains branches for `diamond`, `always`, `sometimes`, `next`, `prev`, `weak_future`, `weak_past`
- `hashDedup` uses proper equality-based deduplication

---

### Phase 2: Enumeration Profiling at c4-c7 [COMPLETED]

**Goal**: Profile the enumeration stage at each complexity level to measure formula counts, timing, and memory usage after task 285 derived operator expansion.

**Tasks**:
- [x] Run `lake exe enum_benchmark` at c4, c5, c6, c7 to collect exact formula counts per complexity level *(c5: 23K cumulative post-filter, 2ms; c6: 170K, 12ms; c7: 1.25M, 101ms)*
- [x] Record wall-clock time for each complexity level enumeration *(total benchmark: 2.85s wall-clock)*
- [x] Monitor memory usage during c6-c7 enumeration using system tools (`/usr/bin/time -v` or equivalent) *(peak RSS: 248MB at c7)*
- [ ] Test atom canonicalization dedup ratio at each level with `--canonical-dedup` *(deviation: skipped -- benchmark does not support --canonical-dedup flag; inline #eval confirms ~4.58x ratio from research)*
- [x] Compare measured formula counts against research projections (7,852 at c4, 75,914 at c5, ~600K+ at c6, ~5M+ at c7) *(exact-complexity #eval matches: c4=7852, c5=75914)*
- [x] If c7 exhaustive enumeration is infeasible (OOM or >30 minutes), record the failure point and extrapolate *(c7 exhaustive enumeration FEASIBLE: 1.25M formulas in 101ms, 248MB peak RSS)*

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- No source files modified (profiling only)

**Verification**:
- Formula counts recorded for c4, c5, c6, and c7 (or documented as infeasible with reason)
- Timing data collected for each level
- Memory usage data for c6-c7 (peak RSS)
- Comparison table: pre-285 vs post-285 formula counts

---

### Phase 3: Pipeline Correctness Validation [NOT STARTED]

**Goal**: Validate correctness of prefilter patterns, cache behavior, hybrid/exhaustive label agreement, and normalization round-trips using `#eval` tests and small-batch generation.

**Tasks**:
- [ ] Run existing inline `#eval` tests in DatasetGenerator.lean (~60+ tests) to confirm all prefilter patterns work correctly
- [ ] Run normalization round-trip tests: verify `normalizeFormula phi = phi` identity for representative formulas at each complexity level
- [ ] Run c4 full pipeline with cache enabled (using `lake exe dataset_generator -- --max-complexity 4 --cache-size 10000`) and verify:
  - Cache hit/miss statistics are collected
  - Invalid prefilter catches are nonzero (task 288 patterns active)
  - Decision method distribution includes `structural_prefilter`, `structural_invalid_prefilter`, `cached`, `adaptive_500`
- [ ] Cross-validate hybrid vs exhaustive labeling on a small c4 sample: run the same formulas with `--generation-mode hybrid` and `--generation-mode exhaustive`, verify zero label disagreements
- [ ] Test updated `sampleOneRandom` by generating random samples and verifying derived operators appear
- [ ] Verify fold/unfold round-trip for enriched formula fields in JSONL output: `toPrimitive(foldFormulaFull(phi)) == phi` for all formula types

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- No source files modified (validation only; may add temporary `#eval` tests that are removed after validation)

**Verification**:
- All existing `#eval` tests pass
- Cache statistics show nonzero hit/miss counts at c4
- Invalid prefilter catches > 0 in c4 dataset
- Zero label disagreements between hybrid and exhaustive modes
- `sampleOneRandom` produces formulas containing derived operators
- Normalization round-trip identity holds for all tested formulas

---

### Phase 4: Dataset Regeneration with Profiling [NOT STARTED]

**Goal**: Regenerate c4 and c5 datasets with current code, collecting full profiling data. Attempt c6 with formula cap. Produce comparative metrics against stale baselines.

**Tasks**:
- [ ] Regenerate c4 dataset: `lake exe dataset_generator -- --max-complexity 4 --wallclock-timeout 1000 --generation-mode exhaustive --output data/bmlogic-c4.jsonl`
- [ ] Regenerate c5 dataset: `lake exe dataset_generator -- --max-complexity 5 --wallclock-timeout 1000 --generation-mode exhaustive --output data/bmlogic-c5.jsonl`
- [ ] Attempt c6 with formula cap: `lake exe dataset_generator -- --max-complexity 6 --wallclock-timeout 1000 --generation-mode exhaustive --max-formulas 50000 --output data/bmlogic-c6.jsonl` (cap to prevent OOM; record actual enumerated count)
- [ ] For each regenerated dataset, collect and record:
  - Total records, valid count, invalid count, timeout count
  - Timeout rate (% of total)
  - Decision method distribution (structural_prefilter, structural_invalid_prefilter, cached, fast_path_axiom, adaptive_500, adaptive_timeout, wallclock_timeout)
  - Cache hit rate
  - Per-pattern prefilter hit counts (if available in output)
  - Wall-clock generation time
- [ ] Build before/after comparison table against stale baselines from research report (Section 3)
- [ ] Compute: timeout rate reduction, valid fraction change, new formula count, cache effectiveness

**Timing**: 2 hours (includes waiting for compiled binary execution)

**Depends on**: 2, 3

**Files to modify**:
- `data/bmlogic-c4.jsonl` - Regenerated dataset
- `data/bmlogic-c5.jsonl` - Regenerated dataset
- `data/bmlogic-c6.jsonl` - Regenerated dataset (capped)

**Verification**:
- c4 dataset has more records than stale baseline (408 records)
- c5 dataset has more records than stale baseline (6,031 records)
- Timeout rate at c4 is lower than stale baseline (12.7%)
- Invalid prefilter entries appear in regenerated datasets (0 in stale)
- Cache entries appear in regenerated datasets (0 in stale)
- All JSONL records are well-formed (parseable JSON, no null required fields)

---

### Phase 5: Diagnostic Report and Summary [NOT STARTED]

**Goal**: Produce the final diagnostic report summarizing all quantitative findings, code quality improvements, and a prioritized list of remaining actionable improvements.

**Tasks**:
- [ ] Create diagnostic summary at `specs/295_dataset_pipeline_diagnostic_audit/summaries/01_diagnostic-audit-summary.md` containing:
  - Executive summary of pipeline health post-enhancements
  - Enumeration profiling results table (c4-c7 formula counts, timing, memory)
  - Dataset comparison table (stale vs regenerated: records, valid%, timeout%, cache hits)
  - Decision method distribution shift analysis
  - Code quality fixes applied (hashDedup, serialization consolidation, random sampling, dead code)
  - Correctness validation results (prefilter, cache, hybrid/exhaustive agreement, normalization)
  - Updated prioritized improvements list (remaining items from research P6-P10 plus any new findings)
  - Feasibility assessment for c6-c7 full exhaustive generation
- [ ] Run `lake build` one final time to confirm clean state
- [ ] Verify all modified files compile without issues

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `specs/295_dataset_pipeline_diagnostic_audit/summaries/01_diagnostic-audit-summary.md` - New file (diagnostic report)

**Verification**:
- Diagnostic report contains all required sections
- All quantitative data is sourced from actual profiling runs (no fabricated numbers)
- `lake build` passes
- Prioritized improvement list updated with effort/impact ratings

## Testing & Validation

- [ ] `lake build` passes after Phase 1 code changes
- [ ] All existing `#eval` tests in DatasetGenerator.lean pass
- [ ] `sampleOneRandom` produces derived operators (diamond, always, sometimes, etc.)
- [ ] `hashDedup` replacement preserves formula count (no false collisions on c4)
- [ ] Cache statistics are nonzero in regenerated datasets
- [ ] Invalid prefilter catches are nonzero in regenerated datasets
- [ ] Zero label disagreements between hybrid and exhaustive modes at c4
- [ ] Normalization round-trip identity holds
- [ ] Regenerated c4 record count > 408 (stale baseline)
- [ ] Regenerated c5 record count > 6,031 (stale baseline)

## Artifacts & Outputs

- `specs/295_dataset_pipeline_diagnostic_audit/plans/01_diagnostic-audit.md` (this file)
- `specs/295_dataset_pipeline_diagnostic_audit/summaries/01_diagnostic-audit-summary.md` (diagnostic report)
- `data/bmlogic-c4.jsonl` (regenerated)
- `data/bmlogic-c5.jsonl` (regenerated)
- `data/bmlogic-c6.jsonl` (regenerated, capped)
- Modified source files: FormulaEnumerator.lean, DatasetGenerator.lean, DatasetExport.lean

## Rollback/Contingency

- All code changes in Phase 1 are localized to three files in `Theories/Bimodal/Automation/`. If any change breaks the build, revert individual changes using `git checkout -- <file>` and proceed with the remaining fixes.
- If c6-c7 enumeration proves completely infeasible (OOM within seconds), skip those levels and document the ceiling in the diagnostic report. The audit still provides value from c4-c5 profiling and code quality fixes.
- Stale datasets in `data/` can be preserved by backing up before regeneration: `cp data/bmlogic-c{4,5,6}.jsonl data/backup/`.
- If `hashDedup` replacement changes dedup behavior, compare c4 formula counts before/after to validate correctness before proceeding to larger datasets.
