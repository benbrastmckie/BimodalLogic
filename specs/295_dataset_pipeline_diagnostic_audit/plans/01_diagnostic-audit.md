# Implementation Plan: Task #295 (v2)

- **Task**: 295 - Diagnostic audit of the dataset generation pipeline
- **Status**: [IN PROGRESS]
- **Effort**: 6 hours
- **Dependencies**: None (tasks 284, 285, 287, 289 all completed)
- **Research Inputs**: specs/295_dataset_pipeline_diagnostic_audit/reports/01_diagnostic-audit.md
- **Artifacts**: plans/01_diagnostic-audit.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **Plan Version**: 2

## Overview

This plan audits the dataset generation pipeline after four recent enhancements (tasks 284, 285, 287, 289). The focus is diagnostic: escalate complexity from c4 upward to find the labeling bottleneck (using timeouts to avoid stalls), validate correctness of prefilter, cache, and normalization, audit which derived operators are natural and useful vs redundant noise, and produce a diagnostic report with what works, what does not work, bottleneck location, operator curation recommendations, and prioritized improvements. The goal is exhaustive generation (all formulas per complexity class), not random sampling. Phase 1 code quality fixes and Phase 2 enumeration profiling are already complete.

### Research Integration

The research report (01_diagnostic-audit.md) provides:
- Complete pipeline architecture map (5 stages: enumeration, prefiltering, labeling, normalization, export)
- Post-task-285 formula count projections (8x at c4-c5, 15-100x at c6-c7)
- 10 prioritized improvements ranked by effort/impact
- Verification that all 4 enhancements compile with zero sorries
- Stale dataset baseline metrics for comparison
- Key finding: labeling is the bottleneck, not enumeration (c7 enumerates 1.25M formulas in 101ms)

### Prior Plan Reference

Revision of v1 plan. Phases 1-2 preserved from v1 (completed). Phases 3-5 revised to shift focus toward bottleneck discovery, operator curation, and diagnostic reporting rather than brute-force regeneration through c7.

### Roadmap Alignment

No specific ROADMAP.md items are directly advanced by this diagnostic task. This is an infrastructure audit enabling future dataset enhancement work.

## Goals & Non-Goals

**Goals**:
- Validate correctness of recent enhancements (prefilter patterns, cache behavior, normalization round-trips)
- Audit derived operators: which are natural and useful for reasoning vs redundant noise from combinatorial explosion
- Escalate exhaustive labeling from c4 upward to find the bottleneck (where labeling becomes infeasible)
- Measure timing, cache hit rates, and prefilter effectiveness at each complexity level
- Produce a diagnostic report with what works, what does not, bottleneck location, operator curation recommendations, and prioritized improvements

**Non-Goals**:
- Forcing exhaustive labeling through c7 regardless of feasibility
- Implementing memory-bounded enumeration (separate future task)
- Changing the cache eviction policy (enhancement, not diagnostic)
- Modifying tableau fuel strategy or timeout parameters
- Random sampling or hybrid modes (this audit targets exhaustive generation)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| c5+ labeling takes too long | M | H | Use wall-clock timeouts (e.g. 5-10 min cap per complexity level); record where it stalls and move on |
| Operator curation analysis is subjective | M | M | Ground in quantitative data: formula count contribution per operator, timeout rate per operator family |
| `lake build` failure after changes | H | L | Run `lake build` after each code change; revert if broken |
| Existing stale datasets confuse comparison | L | L | Clearly label all new runs as post-enhancement; compare against stale baselines from research report |

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

### Phase 3: Correctness Validation and Operator Audit [COMPLETED]

**Goal**: Validate correctness of prefilter, cache, normalization, and label agreement on c4 exhaustive data. Audit derived operators to assess which are natural and useful vs redundant.

**Tasks**:
- [x] Run existing inline `#eval` tests in DatasetGenerator.lean (~60+ tests) to confirm all prefilter patterns work correctly *(all 8 test blocks pass: pool generation, hybrid mode, fallthrough, mini-batch comparison, invalid prefilter, cross-validation, regression, edge cases)*
- [x] Run normalization round-trip tests: verify `normalizeFormula phi = phi` identity for representative formulas at each complexity level *(normalizeFormula_id proven by induction; foldFormula/toPrimitive round-trip passes on 21 formulas)*
- [x] Run c4 exhaustive labeling with cache enabled (wall-clock cap of 5 minutes for the full c4 run) and record:
  - Total labeled formulas, valid count, invalid count, timeout count
  - Cache hit/miss statistics
  - Invalid prefilter catches (should be nonzero with task 288 patterns active)
  - Decision method distribution (structural_prefilter, structural_invalid_prefilter, cached, adaptive_500, etc.)
  - Wall-clock time for the full c4 run
  *(c4: 806 formulas, 17 valid (2%), 669 invalid, 120 timeout (14%), 1s labeling, structural_prefilter: 15, adaptive_500: 671, adaptive_timeout: 120; no structural_invalid_prefilter catches at c4 level)*
- [x] Cross-validate hybrid vs exhaustive labeling on a c4 subset: verify zero label disagreements *(full c4 cross-validation: 806/806 labels match, zero mismatches)*
- [x] Verify fold/unfold round-trip for enriched formula fields in JSONL output *(verified: formula_folded_str/sexpr/json all present; U(bot,top) correctly folds to F(bot); box(bot)->bot folds to neg(box(bot)))*
- [x] Operator audit: enumerate c4 and c5 formulas grouped by which derived operator they contain *(deviation: altered -- used JSONL folded_sexpr analysis instead of direct enumeration; also discovered that 8/13 derived operators have zero pipeline presence due to passesFilter complexity>=3 gate and canonicalization dedup)*
- [x] Produce an operator curation recommendation *(see diagnostic report for full analysis)*

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- No source files modified (validation and analysis only; may add temporary `#eval` tests that are removed after)

**Verification**:
- All existing `#eval` tests pass
- Cache statistics show nonzero hit/miss counts at c4
- Invalid prefilter catches > 0 in c4 data
- Zero label disagreements between hybrid and exhaustive modes
- Normalization round-trip identity holds for all tested formulas
- Operator audit table produced with per-operator formula counts

---

### Phase 4: Bottleneck Discovery via Escalating Labeling [COMPLETED]

**Goal**: Escalate exhaustive labeling from c4 upward to find where the pipeline becomes infeasible. Use timeouts so nothing runs indefinitely. Record the bottleneck.

**Tasks**:
- [x] Run c4 exhaustive labeling (if not already done in Phase 3) and record timing, timeout rate, and decision method distribution *(completed in Phase 3: c4 = 806 formulas, 1s, 14% timeout)*
- [x] Run c5 exhaustive labeling with a wall-clock cap (e.g. 10 minutes total). Record:
  - How many formulas are labeled before the cap
  - Estimated time to complete all ~75K formulas
  - Timeout rate and prefilter effectiveness
  - Whether the run completes or is cut short
  *(c5 completed fully: 6,029 formulas, 11s, 19% timeout, 529 formulas/sec)*
- [x] If c5 completes, attempt c6 with a wall-clock cap (e.g. 15 minutes). Record same metrics. If c6 is infeasible, document why (time, memory, or timeout rate explosion).
  *(c6 completed fully: 39,787 formulas, ~15 min total (including enum+dedup), 25.9% timeout, avg ~250 formulas/sec labeling; 62 wallclock_timeout hits)*
- [x] Do NOT attempt c7 labeling unless c6 completes quickly (unlikely given ~170K formulas at c6 enumeration level). Instead, extrapolate from c4-c6 trends.
  *(c7 not attempted: extrapolated ~300K formulas post-dedup, estimated 20-30 min labeling; feasible but timeout rate likely >30%)*
- [x] Build a bottleneck analysis table *(see diagnostic report)*
- [x] Cross-reference with the operator audit from Phase 3 *(see diagnostic report)*

**Timing**: 1.5 hours (includes running compiled binaries with timeouts)

**Depends on**: 2, 3

**Files to modify**:
- No source files modified (profiling and analysis only)
- May regenerate dataset files in `data/` if labeling completes at a given level

**Verification**:
- Bottleneck complexity level identified with quantitative justification
- Timing data recorded for each attempted complexity level
- Extrapolation from trends documented
- Operator pruning impact estimated

---

### Phase 5: Diagnostic Report [IN PROGRESS]

**Goal**: Produce the final diagnostic report summarizing all findings: what works, what does not, bottleneck location, operator curation, and prioritized improvements.

**Tasks**:
- [ ] Create diagnostic summary at `specs/295_dataset_pipeline_diagnostic_audit/summaries/01_diagnostic-audit-summary.md` containing:
  - Executive summary of pipeline health post-enhancements
  - What works well (prefilter, cache, normalization, enumeration speed)
  - What does not work or needs improvement (labeling speed at scale, operator explosion)
  - Bottleneck analysis: at which complexity level does exhaustive labeling become infeasible, and why
  - Operator curation recommendations: which derived operators to keep (natural, useful), which to consider dropping (marginal), and the estimated formula count reduction from pruning
  - Correctness validation results (prefilter, cache, hybrid/exhaustive agreement, normalization)
  - Enumeration profiling results table (c4-c7 formula counts, timing, memory from Phase 2)
  - Labeling profiling results (c4-c6 timing, timeout rates, cache effectiveness from Phase 4)
  - Comparison against stale dataset baselines from research report
  - Prioritized improvements list with effort/impact ratings (updated from research P1-P10 with new findings)
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
- Operator curation section provides clear keep/drop recommendations with quantitative backing
- Prioritized improvement list updated with effort/impact ratings

## Testing & Validation

- [ ] `lake build` passes after Phase 1 code changes (verified in Phase 1)
- [ ] All existing `#eval` tests in DatasetGenerator.lean pass
- [ ] `sampleOneRandom` produces derived operators (diamond, always, sometimes, etc.) (verified in Phase 1)
- [ ] `hashDedup` replacement preserves formula count (no false collisions on c4) (verified in Phase 1)
- [ ] Cache statistics are nonzero in c4 labeling run
- [ ] Invalid prefilter catches are nonzero in c4 labeling run
- [ ] Zero label disagreements between hybrid and exhaustive modes at c4
- [ ] Normalization round-trip identity holds
- [ ] Bottleneck complexity level identified with timing data
- [ ] Operator curation table produced with per-operator formula counts and recommendations

## Artifacts & Outputs

- `specs/295_dataset_pipeline_diagnostic_audit/plans/01_diagnostic-audit.md` (this file)
- `specs/295_dataset_pipeline_diagnostic_audit/summaries/01_diagnostic-audit-summary.md` (diagnostic report)
- Modified source files from Phase 1: FormulaEnumerator.lean, DatasetGenerator.lean, DatasetExport.lean
- Regenerated dataset files in `data/` only if labeling completes at a given complexity level

## Rollback/Contingency

- All code changes in Phase 1 are localized to three files in `Theories/Bimodal/Automation/`. If any change breaks the build, revert individual changes using `git checkout -- <file>` and proceed with the remaining fixes.
- If c5 labeling exceeds the wall-clock cap, record partial results and extrapolate. The audit still provides value from c4 data and the operator audit.
- If operator audit reveals that all derived operators are useful, document that finding and focus the report on labeling speed improvements instead.
- Stale datasets in `data/` can be preserved by backing up before regeneration: `cp data/bmlogic-c{4,5,6}.jsonl data/backup/`.
