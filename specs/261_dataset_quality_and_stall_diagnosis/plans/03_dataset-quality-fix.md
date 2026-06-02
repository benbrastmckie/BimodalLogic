# Implementation Plan: Task #261 (v3)

- **Task**: 261 - Dataset Quality and Stall Diagnosis
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: Task 253 (enriched countermodel + decision method tracking)
- **Research Inputs**: specs/261_dataset_quality_and_stall_diagnosis/reports/01_dataset-quality-stall.md, specs/261_dataset_quality_and_stall_diagnosis/reports/02_tableau-termination-literature.md
- **Artifacts**: plans/03_dataset-quality-fix.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Plan v01 resolved the primary stall cause (persistent rule loop via AppliedSet), added adaptive fuel caps (500/2000/10000 tiers), and built a compositional proof fast path for box-valid formulas. This v3 plan addresses the remaining algorithmic and infrastructure gaps identified by the literature survey (Report 02): exponential branching in the tableau split case, missing eventuality-aware blocking for Until/Since loops, absent per-record flush in the JSONL pipeline, and the hardcoded Base frame class. These fixes will reduce the timeout rate below 2%, eliminate data loss risk from crashes, and enable multi-frame-class dataset generation.

### Research Integration

**Report 01 (code-level diagnosis)**:
- Persistent rule loop (boxPos): RESOLVED by v01 Phase 1 (AppliedSet)
- Adaptive fuel: RESOLVED by v01 Phase 2 (decideAutoAdaptive)
- Missing JSONL fields: RESOLVED by v01 Phase 4 (binary rebuild)
- Exponential branching in split case: REMAINING -- each sub-branch receives full fuel (line 181 of Saturation.lean)
- 32 Until/Since timeout patterns (`U(bot,X)->Y`): REMAINING -- no structural termination for eventuality loops
- No handle.flush: REMAINING
- Frame class hardcoded to Base: REMAINING

**Report 02 (literature survey)**:
- Global fuel counter recommended over fuel division (simpler, equally effective) -- Priority 1 from report
- Eventuality-aware blocking needed (thread EventualityTracker into isTemporallyBlocked) -- Priority 2 from report
- Reynolds PRUNE rule for Until/Since structural termination -- Priority 5 from report
- Worklist architecture and global caching deferred as high-complexity refactors

### Prior Plan Reference

Plan v01 (01_dataset-quality-stall.md) executed 4 phases, all marked COMPLETED:
- Phase 1 (3h): Persistent rule loop fix via AppliedSet -- validated approach, loop is resolved
- Phase 2 (2h): Adaptive fuel with 3 tiers -- correctly integrated into labelFormula
- Phase 3 (2h): Compositional proof fast path for box-valid patterns -- working, called in decide before tableau
- Phase 4 (3h): Rebuild and validate -- binary rebuilt with all enrichment fields
- **Lesson learned**: The 10K fuel cap from adaptive fuel already mitigates exponential branching for most formulas, but does not eliminate the O(2^fuel) worst case within each tier. A global fuel counter is the correct fix.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Eliminate O(2^fuel) worst-case branching by introducing a global fuel counter shared across all sub-branches
- Add eventuality-aware blocking so Until/Since loops terminate structurally instead of relying on fuel exhaustion
- Add per-record flush to the streaming JSONL pipeline to prevent data loss on crash or kill
- Add a `--frame-class` CLI flag to DatasetExport.lean enabling Dense and Discrete dataset generation
- Reduce timeout rate from ~5% (post-v01) to <2% on representative formula sets

**Non-Goals**:
- Worklist architecture refactor (Report 02 Priority 3) -- high complexity, deferred
- Global caching / Gore-Nguyen pattern (Report 02 Priority 4) -- high complexity, deferred
- Full Reynolds PRUNE rule implementation -- medium complexity, only the eventuality-aware blocking subset is in scope (the three-occurrence check is a future optimization)
- Formal termination proof (blocking_terminates theorem) -- separate verification effort
- c11 generation or stratified sampling -- separate task scope

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Global fuel counter changes tableau semantics (soundness regression) | H | L | The counter only bounds total work; it does not alter rule selection or branch content. `expandBranchWithFuel_sound` depends on `findClosure`, not fuel distribution. Verify theorem still type-checks. |
| Eventuality-aware blocking falsely blocks satisfiable branches | H | M | Conservative approach: only block when ALL pending eventualities at the blocked time are duplicated at the blocking ancestor (fulfilled-or-duplicated predicate). This is strictly more conservative than current blocking. |
| Per-record flush degrades throughput on large generation runs | L | M | Lean's `IO.FS.Handle.flush` is a lightweight syscall. Even at 1.6M records, overhead is <5% of total runtime. Can be gated behind a `--flush` flag if needed. |
| Frame class threading changes labelFormula signature, breaking callers | M | L | Add `fc` parameter with default `FrameClass.Base` to preserve backward compatibility. All existing call sites continue working without change. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4 | 1 |
| 3 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Global Fuel Counter for Branch Splits [COMPLETED]

**Goal**: Replace per-branch full-fuel allocation in the split case of `expandBranchWithFuel` with a shared global fuel counter, bounding total tableau work to O(fuel) instead of O(2^fuel).

**Tasks**:
- [x] **Task 1.1**: Add a `globalFuelRef : IO.Ref Nat` parameter to `expandBranchWithFuel` *(deviation: altered -- used fuel-division approach instead of pass-and-return, dividing fuel by max(1, branches.length) in the split case. This preserves the pure function signature while achieving O(fuel) total work.)*
- [x] **Task 1.2**: Evaluate the pure vs. monadic approach *(completed -- fuel-division avoids return-type change, preserving proof structure)*
- [x] **Task 1.3**: Modify the split case: added `let branchFuel := fuel / (max 1 branches.length)` and use `branchFuel` in recursive calls
- [ ] **Task 1.4**: Update `tryBranch` fold accumulator to carry the remaining fuel *(deviation: skipped -- fuel-division approach does not need accumulator changes; each sub-branch gets a fixed share)*
- [x] **Task 1.5**: Ensure fuel is decremented on each expansion step -- verified, `fuel + 1` pattern decrements correctly; added `decreasing_by` proof for `branchFuel < fuel + 1`
- [x] **Task 1.6**: Update `expandBranchWithFuel_sound` theorem -- restructured from simple induction to strong induction (`Nat.strongRecOn`) to handle `branchFuel <= fuel`
- [ ] **Task 1.7**: Update `tryBranch_inr` *(deviation: skipped -- helper theorem is generic over fuel parameter, works as-is with fuel-division; called with `branchFuel` from the main proof)*
- [x] **Task 1.8**: Test: all existing tests pass (7 Until/Since tests, 5 blocking tests, 5 persistent loop tests, 13 frame-class tests)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` -- `expandBranchWithFuel` split case, `tryBranch_inr` theorem

**Verification**:
- `lake build` passes with zero errors
- `expandBranchWithFuel_sound` theorem still type-checks
- High-branching formulas complete in bounded time (no exponential blowup)

---

### Phase 2: Per-Record Flush and Progress Logging [COMPLETED]

**Goal**: Add `handle.flush` after each JSONL record write to prevent data loss, and add a per-formula slow-decision warning log for post-run analysis.

**Tasks**:
- [ ] **Task 2.1**: Add `handle.flush` call in `writeRecordJSONL` *(deviation: skipped -- used option 2 instead)*
- [x] **Task 2.2**: Add `handle.flush` in main streaming loop after `writeRecordJSONL` call *(completed)*
- [x] **Task 2.3**: Add slow-formula warning with `IO.eprintln` for formulas > 1000ms *(completed)*
- [x] **Task 2.4**: Verify flush does not cause type errors *(completed -- `lake build` passes)*

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` -- main streaming loop (~line 868-900)

**Verification**:
- `lake build` passes
- When running a small generation test (10-50 formulas), each record appears in the output file immediately (not buffered until process exit)
- Slow-formula warnings appear on stderr for formulas exceeding 1 second

---

### Phase 3: Eventuality-Aware Blocking [COMPLETED]

**Goal**: Modify `isTemporallyBlocked` / `findBlockedTime` to consult the `EventualityTracker`, preventing premature blocking of time points with unfulfilled Until/Since obligations. This will structurally terminate the `U(bot, X) -> Y` timeout patterns.

**Tasks**:
- [x] **Task 3.1**: Add `tracker : EventualityTracker` parameter to `findBlockedTime` in SignedFormula.lean (with default `EventualityTracker.empty`)
- [x] **Task 3.2**: Define `allEventualitiesFulfilledOrDuplicated` predicate in SignedFormula.lean
- [x] **Task 3.3**: Modify blocking condition in `isTemporallyBlocked` to conjoin eventuality check
- [x] **Task 3.4**: Thread tracker through `expandBranchWithFuel` into `findBlockedTime` call
- [x] **Task 3.5**: Verified EventualityTracker is up-to-date at blocking check point (lines 157-158)
- [x] **Task 3.6**: All existing `U(bot,p)->F(p)` and `S(bot,p)->P(p)` tests pass
- [x] **Task 3.7**: `U(p,q)` satisfiable test passes (open branch found)
- [x] **Task 3.8**: `expandBranchWithFuel_sound` theorem updated with `split at h` for eventuality-aware blocking; type-checks

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` -- `isSubsetBlocked` or new `isSubsetBlockedWithEventualities`
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` -- `findBlockedTime` signature, `expandBranchWithFuel` threading

**Verification**:
- `lake build` passes with zero errors
- `U(bot, p) -> q` decides as valid without fuel exhaustion
- `S(bot, p) -> q` decides as valid without fuel exhaustion
- Satisfiable Until formulas (e.g., `U(p, top)`) still correctly return invalid/countermodel
- `expandBranchWithFuel_sound` still type-checks

---

### Phase 4: Frame Class CLI Flag [COMPLETED]

**Goal**: Add a `--frame-class` CLI flag to the dataset generator allowing selection of `Base`, `Dense`, or `Discrete` frame classes, and thread the choice through to `labelFormula` and `decideAutoAdaptive`.

**Tasks**:
- [x] **Task 4.1**: Add `frameClass : String := "Base"` field to CLIArgs
- [x] **Task 4.2**: Add `--frame-class` CLI flag parsing (case-insensitive)
- [x] **Task 4.3**: Add `parseFrameClass` and `frameClassName` helpers *(deviation: altered -- returns FrameClass directly instead of Option FrameClass, defaults to .Base for unrecognized)*
- [x] **Task 4.4**: Thread parsed FrameClass through main loop into `labelFormula`
- [x] **Task 4.5**: Add `fc : FrameClass := .Base` parameter to `labelFormula` in DatasetGenerator.lean
- [x] **Task 4.6**: Pass `fc` to `decideAutoAdaptive` in `labelFormula`
- [x] **Task 4.7**: Update `labeledToRecord` with `fcName` parameter, replacing hardcoded "Base"
- [x] **Task 4.8**: Update metadata with `frameClassName` field, used in `datasetMetadataToJson`
- [x] **Task 4.9**: Backward compatible: default parameters ensure no behavioral change

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` -- CLI args, main loop, record construction
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- `labelFormula` signature (add `fc` parameter)

**Verification**:
- `lake build` passes
- `lake exe dataset_generator -- --max-complexity 4 --max-formulas 20 --frame-class Base` produces records with `frame_class: "Base"`
- `lake exe dataset_generator -- --max-complexity 4 --max-formulas 20 --frame-class Dense` produces records with `frame_class: "Dense"`
- `lake exe dataset_generator -- --max-complexity 4 --max-formulas 20 --frame-class Discrete` produces records with `frame_class: "Discrete"`
- Running without `--frame-class` defaults to Base

---

### Phase 5: Integration Validation and Regression Test [NOT STARTED]

**Goal**: Run an end-to-end validation pass confirming all fixes work together: global fuel prevents exponential blowup, eventuality-aware blocking terminates Until/Since patterns, flush prevents data loss, and frame class selection works.

**Tasks**:
- [ ] Rebuild binary: `lake build dataset_generator`
- [ ] Run complexity-5 exhaustive generation with Base frame class (~1300 formulas): `lake exe dataset_generator -- --max-complexity 5 --max-formulas 2000 --output data/test-c5-base.jsonl`
- [ ] Verify timeout rate is < 2% (down from 11.4% in c9 and ~5% post-v01)
- [ ] Verify all 22 JSONL fields present (including the 6 enrichment fields)
- [ ] Verify no formula takes > 10 seconds (global fuel should bound this)
- [ ] Run a 20-formula Dense test: `lake exe dataset_generator -- --max-complexity 4 --max-formulas 20 --frame-class Dense --output data/test-c4-dense.jsonl`
- [ ] Verify Dense-specific records have `frame_class: "Dense"` and Dense axiom handling works
- [ ] Test specific regression formulas via `#eval` or a test file:
  - `U(bot, p) -> q` should be valid (eventuality-aware blocking)
  - `S(bot, p) -> q` should be valid (eventuality-aware blocking)
  - `(box(bot -> bot) -> r)` should be valid (AppliedSet + compositional, already fixed in v01)
  - A high-branching formula should complete within fuel budget (global fuel)
- [ ] Verify data integrity: kill the generator mid-run (Ctrl-C) and confirm the output file contains complete, parseable JSONL lines (no truncated final line, thanks to per-record flush)
- [ ] Update the documentation comment in Saturation.lean (lines 740-775) to note the global fuel fix and eventuality-aware blocking additions
- [ ] Update DatasetGenerator.lean module docstring to mention frame class support

**Timing**: 4 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` -- documentation comments
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- module docstring update

**Verification**:
- `lake build` passes with zero errors (full project)
- Complexity-5 test run completes in < 5 minutes with < 2% timeout rate
- Dense/Discrete test runs produce correctly labeled records
- Specific regression formulas all decide correctly
- Interrupted generation produces valid partial output

## Testing & Validation

- [ ] `lake build` passes with zero errors after all phases
- [ ] `expandBranchWithFuel_sound` theorem still type-checks after global fuel change (Phase 1)
- [ ] High-branching formulas complete in O(fuel) time, not O(2^fuel) (Phase 1)
- [ ] JSONL records are flushed to disk after each write -- no truncated last line on kill (Phase 2)
- [ ] `U(bot, p) -> q` and `S(bot, p) -> q` decide as valid via structural blocking (Phase 3)
- [ ] Satisfiable Until formulas still produce valid countermodels (Phase 3)
- [ ] `--frame-class Dense` and `--frame-class Discrete` produce correctly classified records (Phase 4)
- [ ] Timeout rate on complexity-5 exhaustive run is < 2% (Phase 5)
- [ ] All 22 JSONL fields present in output records (Phase 5)
- [ ] No single formula takes > 10 seconds to decide (Phase 5)

## Artifacts & Outputs

- `specs/261_dataset_quality_and_stall_diagnosis/plans/03_dataset-quality-fix.md` (this plan)
- Modified `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` (global fuel, eventuality-aware blocking)
- Modified `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` (eventuality check in blocking)
- Modified `Theories/Bimodal/Automation/DatasetExport.lean` (flush, frame class CLI, slow-formula warnings)
- Modified `Theories/Bimodal/Automation/DatasetGenerator.lean` (labelFormula frame class parameter)
- Rebuilt `dataset_generator` binary
- Test output files: `data/test-c5-base.jsonl`, `data/test-c4-dense.jsonl`
- `specs/261_dataset_quality_and_stall_diagnosis/summaries/03_dataset-quality-fix-summary.md` (post-implementation)

## Rollback/Contingency

All changes are in Lean source files tracked by git. If any phase introduces build errors or incorrect behavior:
1. `git stash` or selective `git checkout` to revert specific files
2. Phase 1 (global fuel) is isolated to Saturation.lean split-case logic; reverting restores the per-branch fuel behavior (which is already mitigated by the 10K cap)
3. Phase 2 (flush) is a single line addition; trivial to revert
4. Phase 3 (eventuality-aware blocking) adds a conjunctive condition; removing it restores the current subset-only blocking
5. Phase 4 (frame class CLI) adds a parameter with a default; removing the CLI flag parsing restores the Base-only behavior
6. Each phase is independently revertible without affecting other phases
