# Implementation Plan: Smoke-Test C5 Dataset Generation

- **Task**: 263 - Smoke-test dataset generation at complexity 5
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: Task 261 (completed)
- **Research Inputs**: specs/263_smoke_test_c5_dataset_generation/reports/01_smoke-test-c5.md
- **Artifacts**: plans/01_smoke-test-c5.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Create a lightweight, reproducible smoke test that verifies c5 dataset generation works correctly end-to-end after the task 261 fixes (fuel bounding, per-record flush, eventuality-aware blocking). Research confirms an existing c5 dataset at `data/bmlogic-c5.jsonl` (1,512 records) already passes all smoke-test criteria: no stalling, well-formed JSONL with all fields populated, 2.6% timeout rate (below 5% target), and the previously-problematic formula (box(bot) -> box(r)) resolves correctly as valid. The implementation creates a Lean #eval-based smoke test and a Python validation script to make these checks reproducible.

### Research Integration

Key findings from the research report (01_smoke-test-c5.md):
- Existing c5 dataset has 1,512 records, all JSONL fields populated, no null metrics
- All box(bot) -> X patterns resolve correctly as valid via adaptive_500
- 39 timeouts (2.6%) fall into two known patterns: double-box and Until/Since with bot event
- Per-record flush confirmed at DatasetExport.lean line 911
- DatasetValidator.lean already has conformance testing infrastructure (knownValidFormulas, knownInvalidFormulas)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No specific ROADMAP.md items are advanced by this task. This is a validation/testing task that confirms the correctness of existing infrastructure.

## Goals & Non-Goals

**Goals**:
- Create a Lean #eval smoke test that labels key c5 formulas (including box(bot) -> box(r)) and verifies correct results
- Create a Python script to validate the existing c5 JSONL dataset for well-formedness, field completeness, and timeout rate
- Confirm no stalling by running the Lean smoke test to completion within a bounded time
- Document verification results

**Non-Goals**:
- Re-generating the full c5 dataset (already exists and is validated)
- Fixing the 39 remaining timeout formulas (known patterns, separate task scope)
- Testing Dense or Discrete frame classes (only Base is in scope)
- Modifying the decision procedure or dataset generator

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lean #eval test takes too long at c5 complexity | M | L | Test only a targeted subset of 10-15 formulas, not full enumeration |
| DatasetValidator conformance tests fail unexpectedly | M | L | Research confirms all known formulas resolve correctly; investigate any new failures |
| Python script finds issues in existing dataset | L | L | Research already verified all fields are populated; script serves as regression guard |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Create Lean #eval Smoke Test [COMPLETED]

**Goal**: Create a Lean file with #eval commands that label targeted c5 formulas and verify correct results, exercising the decision procedure end-to-end.

**Tasks**:
- [x] Create `Tests/BimodalTest/Automation/C5SmokeTest.lean` with imports for DatasetGenerator and DecisionProcedure
- [x] Define 10-15 targeted test formulas at complexity <= 5, including:
  - Previously-problematic: `(box(bot) -> box(r))`, `(box(bot) -> r)`, `(box(bot) -> bot)`
  - Known valid: `box(p -> p)`, `box(bot -> p)`, `(p -> p)`
  - Known invalid: `p`, `bot`, `box(p) -> box(q)`
  - Edge cases at c5: formulas with nested temporal operators
- [x] Write #eval commands that call `labelFormula` (or `decideAutoAdaptive`) on each formula and assert the expected label
- [x] Add an #eval command that runs the existing `runConformanceTests` from DatasetValidator to confirm all known formulas pass
- [x] Register the test file in the lakefile or ensure it builds as part of the test target
- [x] Run `lake build` to verify the test file compiles and all #eval commands succeed

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `Tests/BimodalTest/Automation/C5SmokeTest.lean` - New file: #eval-based smoke test
- `lakefile.lean` - Potentially add lean_lib or lean_exe entry if tests are not auto-discovered

**Verification**:
- `lake build` succeeds with no errors
- All #eval commands produce expected results (valid/invalid labels match expectations)
- No #eval command hangs or times out

---

### Phase 2: Create Python Validation Script [COMPLETED]

**Goal**: Create a Python script that validates the existing c5 JSONL dataset for well-formedness, complete field population, and acceptable timeout rate.

**Tasks**:
- [x] Create `scripts/validate_c5_dataset.py` based on the validation approach from the research report
- [x] Implement JSONL line-by-line parsing with error detection
- [x] Check all 22 expected fields are present in every record *(deviation: altered -- dataset has 25 fields, not 22; all 25 validated)*
- [x] Verify no null metrics (complexity, modalDepth, temporalDepth, impCount, atomCount, decisionTimeMs, difficultyTier)
- [x] Verify decision_method is never null
- [x] Verify valid records have non-null proof_trace and rule_profile
- [x] Verify invalid records have non-null countermodel and countermodel_consistent
- [x] Compute and check timeout rate < 5%
- [x] Check specific regression formula (box(bot) -> box(r)) is labeled valid
- [x] Print summary with PASS/FAIL result
- [x] Run the script against `data/bmlogic-c5.jsonl` and confirm PASS

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `scripts/validate_c5_dataset.py` - New file: Python validation script

**Verification**:
- Script runs to completion on `data/bmlogic-c5.jsonl`
- Output shows PASS with correct statistics (1,512 records, 0 parse errors, 0 null metrics, < 5% timeout rate)

---

### Phase 3: Run Full Verification and Document Results [NOT STARTED]

**Goal**: Execute both the Lean smoke test and Python validation, collect results, and confirm all smoke-test criteria are met.

**Tasks**:
- [ ] Run `lake build Tests.BimodalTest.Automation.C5SmokeTest` (or equivalent) and capture output
- [ ] Run `python3 scripts/validate_c5_dataset.py data/bmlogic-c5.jsonl` and capture output
- [ ] Verify all criteria are met:
  - No stalling (Lean test completes)
  - JSONL well-formed (no parse errors)
  - All fields populated (no null metrics)
  - Timeout rate < 5%
  - box(bot) -> box(r) resolves as valid
- [ ] If any criterion fails, investigate and document the failure

**Timing**: 15 minutes

**Depends on**: 1, 2

**Files to modify**:
- None (execution and verification only)

**Verification**:
- All smoke-test criteria pass
- Both Lean and Python tests produce clean output

## Testing & Validation

- [ ] `lake build` succeeds with no errors (Lean smoke test compiles)
- [ ] All #eval commands in C5SmokeTest.lean produce expected labels
- [ ] Python script reports PASS on existing c5 dataset
- [ ] No null metrics in any JSONL record
- [ ] Timeout rate < 5% (currently 2.6%)
- [ ] Formula (box(bot) -> box(r)) labeled as valid
- [ ] No stalling or hangs during test execution

## Artifacts & Outputs

- `Tests/BimodalTest/Automation/C5SmokeTest.lean` - Lean #eval smoke test
- `scripts/validate_c5_dataset.py` - Python JSONL validation script
- `specs/263_smoke_test_c5_dataset_generation/summaries/01_smoke-test-c5-summary.md` - Implementation summary

## Rollback/Contingency

Both new files (C5SmokeTest.lean, validate_c5_dataset.py) are additive test artifacts. If any issues arise, they can be deleted without affecting the existing codebase. No production code is modified by this plan.
