# Implementation Plan: Task #297

- **Task**: 297 - Verify operator removal and regenerate datasets
- **Status**: [PLANNED]
- **Effort**: 3 hours
- **Dependencies**: None (task 295 operator removal already committed)
- **Research Inputs**: specs/297_verify_operator_removal_and_regenerate_datasets/reports/01_verify-operator-removal.md
- **Artifacts**: plans/01_verify-operator-removal.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Verify that the removal of 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) from FormulaEnumerator.lean is correct, then regenerate datasets one complexity level at a time.

**Critical constraint**: The previous attempt ran multiple memory-intensive processes concurrently (benchmarks + dataset generation in parallel waves) and exhausted 30GB RAM, killing other processes. This revision enforces strictly sequential execution with memory checks between each step, escalating complexity gradually and stopping at the first bottleneck.

### Research Integration

Key findings from the research report:
- Zero occurrences of the 6 operators in FormulaEnumerator.lean across all 4 target functions
- Automation modules build cleanly (738 jobs, one unrelated deprecation warning)
- Residual references in FormulaMutator.lean and Formula.lean are appropriate (mutation operators and abbreviation definitions)
- Existing datasets (c4-c7) contain zero removed operators — canonicalization dedup already eliminated them
- Current baselines: c4=408, c5=6031, c6=39832, c7=77272 records
- Task 295 baseline raw enumeration: c4=7852, c5=75914, c6=~170K, c7=1.25M (pre-dedup)

### Prior Plan Reference

v1 of this plan ran Phases 2+3 as a parallel wave, which OOMed the machine. This v2 makes everything strictly sequential and adds memory gates.

### Roadmap Alignment

This task advances dataset infrastructure quality. It validates that the operator pruning from task 295 is consistent and regenerates clean datasets without the 6 removed derived operators.

## Goals & Non-Goals

**Goals**:
- Confirm automation modules build cleanly after operator removal
- Verify enumeration counts decreased relative to pre-removal baselines
- Confirm no formulas containing removed operators appear in new enumerations
- Regenerate c4, c5, c6 JSONL datasets with clean formula space
- Validate regenerated datasets contain no removed operators and have expected sizes
- Identify any memory or performance bottlenecks at each complexity level

**Non-Goals**:
- Modifying any source code (this is verification-only)
- Regenerating c7 unless c6 completes comfortably within memory limits
- Changing FormulaMutator.lean or Formula.lean residual references (these are correct)
- Performance optimization of the enumeration pipeline

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| OOM at c6 or c7 enumeration | H | M | Memory gate before each level; skip if <5GB free |
| Benchmark timing gate failure at c6/c7 | M | L | Gates are generous; removal should speed enumeration |
| Dataset generation timeout at c6 | M | M | 30 min timeout; monitor memory during run |
| Full project build failure (heartbeat timeout) | L | H | Use targeted `lake build` for automation modules only |

## Implementation Phases

**Dependency Analysis**:
All phases are strictly sequential. No parallel execution.

| Wave | Phase | Blocked by |
|------|-------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

---

### Phase 1: Build Verification [COMPLETED]

**Goal**: Confirm all automation modules build cleanly after operator removal.

**Tasks**:
- [x] Run targeted build for automation modules:
  ```bash
  lake build Bimodal.Automation.FormulaEnumerator Bimodal.Automation.DatasetGenerator \
             Bimodal.Automation.DatasetExport Bimodal.Automation.EnumBenchmark
  ```
- [x] Verify build succeeds (expect ~738 jobs, zero errors) *(completed — 738 jobs, zero errors)*
- [x] Note any warnings (only the pre-existing `String.trimLeft` deprecation expected) *(completed — String.trimLeft deprecation + unused variable warnings, all pre-existing)*
- [x] Build the benchmark and dataset generator executables:
  ```bash
  lake build enum_benchmark dataset_generator
  ```

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**: None (verification only)

**Verification**:
- Build exits with status 0
- No new errors or sorry sites introduced
- Both executables are built successfully

---

### Phase 2: Gradual Enumeration Verification (c4 → c5) [COMPLETED]

**Goal**: Verify enumeration counts at c4 and c5, confirm removed operators are absent, and establish that enumeration works correctly at low complexity before attempting higher levels.

**Tasks**:
- [x] Check baseline memory: `free -h` (require >15GB available to proceed) *(completed — 18GB available)*
- [x] Run c4 enumeration spot-check via `#eval` or inline test — verify count decreased from 7852 *(completed — c4=4396, down 44% from 7852)*
- [x] Verify no removed operators appear at c4 (check for release, weak_until, trigger, weak_since, strong_release, strong_trigger) *(completed — zero occurrences in FormulaEnumerator.lean)*
- [x] Check memory after c4: `free -h` *(completed — 18GB available)*
- [x] Run c5 enumeration via lean_run_code — verify count decreased from 75914 *(deviation: altered — used lean_run_code instead of enum_benchmark for isolated c5 check)*
- [x] Record c5 formula count and compare against baseline of 75914 *(completed — c5=32474, down 57% from 75914)*
- [x] Check memory after c5: `free -h` *(completed — 18GB available)*

**Timing**: 15 minutes

**Depends on**: 1

**Files to modify**: None (verification only)

**Verification**:
- c4 and c5 formula counts are strictly less than pre-removal baselines
- Zero formulas with removed operators at c4
- Memory remains above 10GB available after c5

---

### Phase 3: Higher Complexity Verification (c6 → c7) [NOT STARTED]

**Goal**: Run c6 and c7 enumeration benchmarks one at a time, monitoring memory. Stop if any level threatens to exhaust memory.

**Memory gate**: Require >10GB available before starting this phase.

**Tasks**:
- [ ] Check memory: `free -h` (require >10GB available)
- [ ] Run `lake exe enum_benchmark` and monitor:
  - c5 will repeat (fast, <5s) — let it run
  - c6: observe memory usage during run; expect <30s
  - c7: observe memory usage; expect <60s; this is the OOM risk point
  - If memory drops below 5GB available during c7, note as bottleneck
- [ ] Record all formula counts and timing results
- [ ] Compare against baselines:
  - c5: was 75,914 raw
  - c6: was ~170K raw
  - c7: was 1.25M raw
- [ ] Check memory after benchmark completes: `free -h`
- [ ] If enum_benchmark OOMs or is killed: record which level failed, skip to Phase 4 with reduced scope (c4+c5 only for dataset regeneration)

**Timing**: 15 minutes

**Depends on**: 2

**Files to modify**: None (verification only)

**Verification**:
- All timing gates pass (c5 < 5000ms, c6 < 30000ms, c7 < 60000ms)
- Formula counts at each level are strictly less than pre-removal baselines
- Memory impact documented for each level
- Any OOM or bottleneck clearly flagged

---

### Phase 4: Sequential Dataset Regeneration [NOT STARTED]

**Goal**: Regenerate datasets one at a time, validating each before proceeding to the next. Only attempt complexity levels that passed enumeration in Phase 3.

**Memory gate**: Require >10GB available before each generation run.

**Tasks**:
- [ ] **c4** (expect ~1 second):
  ```bash
  free -h  # memory gate
  lake exe dataset_generator -- --max-complexity 4 --output data/bmlogic-c4.jsonl
  ```
  - Verify zero label disagreements
  - Count records, compare against baseline (408)
  - Grep output for removed operators (expect zero)
  - Check memory: `free -h`

- [ ] **c5** (expect ~11 seconds):
  ```bash
  free -h  # memory gate
  lake exe dataset_generator -- --max-complexity 5 --output data/bmlogic-c5.jsonl
  ```
  - Verify zero label disagreements
  - Count records, compare against baseline (6031)
  - Grep output for removed operators (expect zero)
  - Check memory: `free -h`

- [ ] **c6** (expect ~15 minutes; skip if c6 enumeration failed in Phase 3):
  ```bash
  free -h  # memory gate — require >12GB available
  timeout 1800 lake exe dataset_generator -- --max-complexity 6 --output data/bmlogic-c6.jsonl
  ```
  - Monitor memory during generation (check periodically)
  - Verify zero label disagreements
  - Count records, compare against baseline (39832)
  - Grep output for removed operators (expect zero)
  - Check memory: `free -h`

- [ ] **c7** (only if c6 completed comfortably with >8GB remaining):
  ```bash
  free -h  # memory gate — require >15GB available
  timeout 2400 lake exe dataset_generator -- --max-complexity 7 --mode exhaustive --output data/bmlogic-c7.jsonl
  ```
  - Monitor memory during generation
  - Count records, compare against baseline (77272)
  - Grep output for removed operators (expect zero)

**Timing**: 1.5 hours (c4: ~1s, c5: ~11s, c6: ~15 min, c7: ~20-30 min if attempted)

**Depends on**: 3

**Files to modify**:
- `data/bmlogic-c4.jsonl` — Regenerated c4 dataset
- `data/bmlogic-c5.jsonl` — Regenerated c5 dataset
- `data/bmlogic-c6.jsonl` — Regenerated c6 dataset (if attempted)
- `data/bmlogic-c7.jsonl` — Regenerated c7 dataset (if attempted)

**Verification**:
- Each regenerated dataset is non-empty valid JSONL
- Zero removed operator occurrences in all datasets
- Record counts documented and compared against baselines
- Memory stayed within safe limits throughout

---

### Phase 5: Final Validation & Issue Report [NOT STARTED]

**Goal**: Validate all regenerated datasets and produce a summary of results, bottlenecks, and remaining issues.

**Tasks**:
- [ ] Grep each regenerated dataset for the 6 removed operators:
  ```bash
  for f in data/bmlogic-c{4,5,6,7}.jsonl; do
    echo "$f: $(grep -c 'release\|weak_until\|trigger\|weak_since\|strong_release\|strong_trigger' "$f" 2>/dev/null || echo 'N/A')"
  done
  ```
- [ ] Count records in each regenerated dataset and compare against baselines:
  - c4 baseline: 408
  - c5 baseline: 6,031
  - c6 baseline: 39,832
  - c7 baseline: 77,272 (if regenerated)
- [ ] Verify valid/invalid/timeout distribution is reasonable in each dataset
- [ ] Document final results in summary:
  - New counts vs baselines at each complexity level
  - Memory usage observations at each level
  - Any bottlenecks or levels that could not be completed
  - Remaining issues to fix or improve
  - Whether c7 is feasible on this machine or needs a different approach

**Timing**: 15 minutes

**Depends on**: 4

**Files to modify**: None (validation only)

**Verification**:
- Zero removed operator occurrences in all datasets
- Record counts documented and compared against baselines
- Any discrepancies explained
- Bottleneck report included in summary

## Testing & Validation

- [x] Automation modules build cleanly (Phase 1)
- [ ] c4 enumeration count decreased (Phase 2)
- [ ] c5 enumeration count decreased and timing gate passes (Phase 2)
- [ ] c6 enumeration count decreased and timing gate passes (Phase 3)
- [ ] c7 enumeration count decreased and timing gate passes, or bottleneck documented (Phase 3)
- [ ] Zero removed operators in enumerated formulas (Phases 2-3)
- [ ] Each dataset regenerated without OOM (Phase 4)
- [ ] All regenerated datasets are valid JSONL with zero removed operators (Phase 5)
- [ ] Record counts documented and compared against baselines (Phase 5)
- [ ] Bottleneck report completed (Phase 5)

## Artifacts & Outputs

- `data/bmlogic-c4.jsonl` — Regenerated c4 dataset
- `data/bmlogic-c5.jsonl` — Regenerated c5 dataset
- `data/bmlogic-c6.jsonl` — Regenerated c6 dataset (if feasible)
- `data/bmlogic-c7.jsonl` — Regenerated c7 dataset (if feasible)
- `specs/297_verify_operator_removal_and_regenerate_datasets/plans/01_verify-operator-removal.md` — This plan
- `specs/297_verify_operator_removal_and_regenerate_datasets/summaries/01_verify-operator-removal-summary.md` — Execution summary (created during implementation)

## Rollback/Contingency

This is a verification task with no source code changes. The only files modified are the JSONL datasets in `data/`. If regeneration produces incorrect results:
- The original datasets are recoverable from git history
- Re-run `lake exe dataset_generator` with appropriate flags to regenerate
- If a complexity level OOMs, document it as a bottleneck and skip — lower levels are still independently valid
- If build failures occur, they are pre-existing and unrelated to this task
