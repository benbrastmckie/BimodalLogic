# Implementation Plan: Task #297

- **Task**: 297 - Verify operator removal and regenerate datasets
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None (task 295 operator removal already committed)
- **Research Inputs**: specs/297_verify_operator_removal_and_regenerate_datasets/reports/01_verify-operator-removal.md
- **Artifacts**: plans/01_verify-operator-removal.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Verify that the removal of 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) from FormulaEnumerator.lean is correct and complete by running builds, enumeration benchmarks, and dataset regeneration pipelines. No source code changes are expected -- this is a verification and data regeneration task. Research confirmed that all 4 target functions (enumExactHelper, sampleOne, sampleOneRandom, randomSubFormula) have zero references to the removed operators, the automation modules build cleanly, and existing datasets already contain zero occurrences due to prior canonicalization dedup.

### Research Integration

Key findings from the research report:
- Zero occurrences of the 6 operators in FormulaEnumerator.lean across all 4 target functions
- Automation modules build cleanly (738 jobs, one unrelated deprecation warning)
- Residual references in FormulaMutator.lean and Formula.lean are appropriate (mutation operators and abbreviation definitions)
- Existing datasets (c4-c7) contain zero removed operators -- canonicalization dedup already eliminated them
- Current baselines: c4=408, c5=6031, c6=39832, c7=77272 records
- Task 295 baseline raw enumeration: c4=7852, c5=75914, c6=~170K, c7=1.25M (pre-dedup)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances dataset infrastructure quality. It validates that the operator pruning from task 295 is consistent and regenerates clean datasets without the 6 removed derived operators. No specific ROADMAP.md items are directly advanced, but this supports the Phase 2 axiom cleanup track by confirming the formula space reduction is correct.

## Goals & Non-Goals

**Goals**:
- Confirm automation modules build cleanly after operator removal
- Verify enumeration counts decreased relative to pre-removal baselines (the 6 operators inflated counts by ~40-60%)
- Confirm no formulas containing removed operators appear in new enumerations
- Regenerate c4, c5, c6 JSONL datasets with clean formula space
- Validate regenerated datasets contain no removed operators and have expected sizes

**Non-Goals**:
- Modifying any source code (this is verification-only)
- Regenerating c7 dataset (only if c6 completes within reasonable time)
- Changing FormulaMutator.lean or Formula.lean residual references (these are correct)
- Performance optimization of the enumeration pipeline

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Benchmark timing gate failure at c6/c7 | M | L | Gates are generous (30s/60s); removal should speed enumeration |
| Dataset generation timeout at c6 | M | M | c6 took ~15 min pre-removal; may be faster now; set 30 min timeout |
| Unexpected formula count discrepancy | H | L | Compare against both raw enum counts and pipeline-surviving counts from research |
| Full project build failure (heartbeat timeout) | L | H | Known pre-existing issue in CanonicalTaskRelation.lean; use targeted `lake build` for automation modules only |

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

### Phase 2: Enumeration Profiling [NOT STARTED]

**Goal**: Run enumeration benchmarks at c4-c7, verify formula counts decreased, and confirm no removed operators appear in enumerated formulas.

**Tasks**:
- [ ] Run `lake exe enum_benchmark` and capture output (formula counts and timing for c5, c6, c7)
- [ ] Compare formula counts against task 295 pre-removal baselines:
  - c4: was 7,852 raw (expect decrease)
  - c5: was 75,914 raw (expect decrease)
  - c6: was ~170K raw (expect decrease)
  - c7: was 1.25M raw (expect decrease)
- [ ] Verify all timing gates pass (c5 < 5000ms, c6 < 30000ms, c7 < 60000ms)
- [ ] Run inline `#eval` spot-checks in FormulaEnumerator.lean to verify specific removed operators are absent:
  - Check that `release(p, q)` does NOT appear in c4 enumeration
  - Check that `weak_until(p, q)` does NOT appear in c4 enumeration
- [ ] Record new formula count baselines for documentation

**Timing**: 30 minutes (c7 benchmark may take up to 60 seconds)

**Depends on**: 1

**Files to modify**: None (verification only; may add temporary `#eval` checks that are removed after)

**Verification**:
- All timing gates pass
- Formula counts at each complexity level are strictly less than pre-removal baselines
- Zero formulas with removed operators found in any enumeration

---

### Phase 3: Labeling Correctness [NOT STARTED]

**Goal**: Run c4 exhaustive labeling to verify zero label disagreements and confirm the prefilter/cache pipeline still works correctly.

**Tasks**:
- [ ] Generate c4 dataset using `lake exe dataset_generator -- --max-complexity 4 --output /tmp/test-c4.jsonl`
- [ ] Verify zero label disagreements in output
- [ ] Check that prefilter and cache mechanisms report correctly (examine generator output messages)
- [ ] Verify the record count is close to the baseline of 408 (may be identical since removed operators contributed zero pipeline-surviving formulas)
- [ ] Grep the output JSONL for any of the 6 removed operator names to confirm absence

**Timing**: 15 minutes (c4 generation takes ~1 second)

**Depends on**: 1

**Files to modify**: None (verification only; output to /tmp)

**Verification**:
- Zero label disagreements
- Record count within expected range (~408, possibly slightly different)
- `grep -c "release\|weak_until\|trigger\|weak_since\|strong_release\|strong_trigger" /tmp/test-c4.jsonl` returns 0

---

### Phase 4: Dataset Regeneration [NOT STARTED]

**Goal**: Regenerate c4, c5, and c6 JSONL datasets using the cleaned formula enumerator. Regenerate c7 only if c6 completes in reasonable time.

**Tasks**:
- [ ] Regenerate c4 dataset:
  ```bash
  lake exe dataset_generator -- --max-complexity 4 --output data/bmlogic-c4.jsonl
  ```
- [ ] Regenerate c5 dataset:
  ```bash
  lake exe dataset_generator -- --max-complexity 5 --output data/bmlogic-c5.jsonl
  ```
- [ ] Regenerate c6 dataset (set 30 minute timeout):
  ```bash
  lake exe dataset_generator -- --max-complexity 6 --output data/bmlogic-c6.jsonl
  ```
- [ ] If c6 completes within 20 minutes, regenerate c7:
  ```bash
  lake exe dataset_generator -- --max-complexity 7 --mode exhaustive --output data/bmlogic-c7.jsonl
  ```
- [ ] Record generation times for each complexity level

**Timing**: 1.5 hours (c4: ~1s, c5: ~11s, c6: ~15 min, c7: ~20-30 min if attempted)

**Depends on**: 2, 3

**Files to modify**:
- `data/bmlogic-c4.jsonl` - Regenerated c4 dataset
- `data/bmlogic-c5.jsonl` - Regenerated c5 dataset
- `data/bmlogic-c6.jsonl` - Regenerated c6 dataset
- `data/bmlogic-c7.jsonl` - Regenerated c7 dataset (if attempted)

**Verification**:
- Each dataset file is non-empty and contains valid JSONL
- Generation completes without errors
- File sizes are reasonable relative to baselines

---

### Phase 5: Validation [NOT STARTED]

**Goal**: Validate regenerated datasets have no removed operators and compare sizes against pre-removal baselines.

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
- [ ] Document final results: new counts, comparison with baselines, any discrepancies
- [ ] If counts differ significantly from baselines, investigate and document the reason (expected: counts should be very close since removed operators contributed zero pipeline-surviving formulas)

**Timing**: 15 minutes

**Depends on**: 4

**Files to modify**: None (validation only)

**Verification**:
- Zero removed operator occurrences in all datasets
- Record counts documented and compared against baselines
- Any discrepancies explained

## Testing & Validation

- [ ] Automation modules build cleanly (Phase 1)
- [ ] Enumeration counts decreased relative to pre-removal raw baselines (Phase 2)
- [ ] All benchmark timing gates pass (Phase 2)
- [ ] Zero removed operators in enumerated formulas (Phase 2)
- [ ] Zero label disagreements at c4 (Phase 3)
- [ ] All regenerated datasets are valid JSONL with zero removed operators (Phase 5)
- [ ] Record counts documented and compared against baselines (Phase 5)

## Artifacts & Outputs

- `data/bmlogic-c4.jsonl` - Regenerated c4 dataset
- `data/bmlogic-c5.jsonl` - Regenerated c5 dataset
- `data/bmlogic-c6.jsonl` - Regenerated c6 dataset
- `data/bmlogic-c7.jsonl` - Regenerated c7 dataset (if c6 completes in time)
- `specs/297_verify_operator_removal_and_regenerate_datasets/plans/01_verify-operator-removal.md` - This plan
- `specs/297_verify_operator_removal_and_regenerate_datasets/summaries/01_verify-operator-removal-summary.md` - Execution summary (created during implementation)

## Rollback/Contingency

This is a verification task with no source code changes. The only files modified are the JSONL datasets in `data/`. If regeneration produces incorrect results:
- The original datasets are recoverable from git history
- Re-run `lake exe dataset_generator` with appropriate flags to regenerate
- If build failures occur, they are pre-existing and unrelated to this task
