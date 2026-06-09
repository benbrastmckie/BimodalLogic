# Phase 1 Handoff: Add Global Branch Counter to Saturation.lean

## What was done
- Added `maxBranches : Nat := 50000` and `branchesUsed : Nat := 0` parameters to `expandBranchWithFuel`
- Added early return `none` when `branchesUsed >= maxBranches` (before fuel check)
- At `.extended` case: increments `branchesUsed` by 1
- At `.split` case: increments `branchesUsed` by `branches.length`
- Mirrored all changes in `expandBranchWithFuel_tracedImpl`
- Updated soundness theorems (`tryBranch_inr`, `foldl_preserves_findClosure`, `expandBranchWithFuel_sound`, `blocking_sound`) to generalize over the new parameters
- All existing tests pass, build successful

## Key decisions
- Used default parameters (50000 / 0) so callers don't need changes
- The branch counter guard is placed BEFORE the fuel match, so it fires even at fuel > 0
- Soundness proof uses `split at h` for the new `if` guard (cleaner than `by_cases`)

## Next action
Phase 2: Fix timeout mechanism in DatasetGenerator.lean - replace `Task.spawn` with `IO.asTask` + `IO.cancel`, add adaptive fuel reduction
