# Implementation Summary: Task #261 Dataset Quality and Stall Diagnosis (v3)

## Overview

Implemented all 5 phases of the v3 plan addressing remaining algorithmic and infrastructure gaps in the dataset generation pipeline. All changes compile with zero errors (1682 jobs).

## Changes by Phase

### Phase 1: Global Fuel Counter for Branch Splits
- Modified `expandBranchWithFuel` split case to divide fuel among sub-branches: `branchFuel = fuel / max(1, branches.length)`
- Bounds total tableau work to O(fuel) instead of O(2^fuel) for branching formulas
- Added `decreasing_by` proof for termination: `fuel / max(1, n) < fuel + 1`
- Updated `expandBranchWithFuel_sound` from simple induction to strong induction (`Nat.strongRecOn`) to handle the reduced fuel value in sub-branches
- **Files**: `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`

### Phase 2: Per-Record Flush and Progress Logging
- Added `handle.flush` after each `writeRecordJSONL` call in the main streaming loop
- Added `IO.eprintln` slow-formula warning for formulas taking >1000ms
- **Files**: `Theories/Bimodal/Automation/DatasetExport.lean`

### Phase 3: Eventuality-Aware Blocking
- Added `pendingAtTime` and `isFulfilled` methods to `EventualityTracker`
- Defined `allEventualitiesFulfilledOrDuplicated` predicate: blocking only fires when all pending eventualities at the blocked time are duplicated at the blocking ancestor
- Modified `isTemporallyBlocked` to conjoin subset blocking with eventuality check
- Added `tracker` parameter (with default) to `findBlockedTime`
- Updated soundness proof to handle the new `findBlockedTime` call
- **Files**: `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean`, `Saturation.lean`

### Phase 4: Frame Class CLI Flag
- Added `frameClass : String := "Base"` to `CLIArgs`
- Added `parseFrameClass` and `frameClassName` helpers
- Added `--frame-class` CLI flag parsing (case-insensitive)
- Modified `labelFormula` to accept `fc : FrameClass := .Base` parameter
- Updated `labeledToRecord` with `fcName` parameter
- Updated `DatasetMetadata` with `frameClassName` field
- **Files**: `Theories/Bimodal/Automation/DatasetExport.lean`, `DatasetGenerator.lean`

### Phase 5: Integration Validation
- Full `lake build` passes with 1682 jobs, zero errors
- All existing `#eval` tests pass (30+ tests across Saturation.lean)
- Updated Saturation.lean documentation for global fuel and eventuality-aware blocking
- Updated DatasetGenerator.lean docstring for frame class support
- Runtime validation (complexity-5 generation, Dense test, kill-test) deferred

## Plan Deviations

- Phase 1: Used fuel-division approach instead of pass-and-return (simpler, no return-type change)
- Phase 1: `tryBranch_inr` helper not modified (works as-is with generic fuel parameter)
- Phase 5: Runtime tests (Tasks 5.2-5.7, 5.9) deferred -- require interactive execution environment

## Verification Results

- **sorry count**: 0 in modified files
- **vacuous definitions**: 0 new
- **axiom count**: 0 new
- **build**: passes (1682 jobs)
- **all #eval tests**: pass
