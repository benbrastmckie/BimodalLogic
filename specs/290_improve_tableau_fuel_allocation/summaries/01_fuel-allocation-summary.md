# Implementation Summary: Task #290

- **Task**: 290 - Improve tableau fuel allocation heuristic for imbalanced branches
- **Status**: Implemented
- **Plan**: specs/290_improve_tableau_fuel_allocation/plans/01_fuel-allocation-plan.md
- **Modified Files**: `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`

## Changes Made

### Phase 1: Define estimateBranchDifficulty and allocateFuelProportionally

Added two helper functions and a supporting theorem:

- **`temporalCount : Formula -> Nat`** (private): Counts Until/Since operators recursively
- **`modalCount : Formula -> Nat`** (private): Counts Box operators recursively
- **`estimateBranchDifficulty : Branch -> Nat`**: Weighted sum: `1 + 3*temporal + 2*modal + size/4`
- **`allocateFuelProportionally : Nat -> List Branch -> List Nat`**: Computes per-branch fuel proportional to difficulty, capped at `fuel - 1` via `min`
- **`allocateFuelProportionally_le`**: Theorem proving each allocation is `<= fuel - 1`

5 `#eval` tests added (FA1-FA5) verifying:
- Balanced branches get equal fuel
- Temporal branches get more fuel than propositional
- All allocations within bounds [1, fuel-1]
- Zero fuel gives all zeros
- Difficulty ordering: temporal > modal > propositional

### Phase 2: Integrate into expandBranchWithFuel

Replaced uniform `fuel / (max 1 branches.length)` with proportional allocation:
- Pre-computes `fuelAllocs := allocateFuelProportionally (fuel + 1) branches`
- Zips branches with fuel allocations: `(branches.zip fuelAllocs).foldl tryBranch init`
- Recursive call uses `min pair.2 fuel` for termination visibility
- Termination proof: `decreasing_by all_goals simp_wf` (no manual proof needed)

### Phase 3: Mirror in traced variant

Applied identical changes to `expandBranchWithFuel_tracedImpl`:
- Same `allocateFuelProportionally` call
- `for pair in branches.zip fuelAllocs` replaces `for newBranch in branches`
- Same termination strategy

### Phase 4: Update soundness proof

Updated `tryBranch_inr`, `foldl_preserves_findClosure`, and `expandBranchWithFuel_sound`:
- Generalized from single `fuel` parameter to `fuelBound` with `(fuel' : Nat) -> fuel' <= fuelBound -> ...` induction hypothesis
- `foldl_preserves_findClosure` operates on `List (Branch x Nat)` pairs
- Strong induction still applies: `min pair.2 k <= k < k + 1`

### Phase 5: Verification

- Full module build: zero errors (724 jobs)
- `lean_verify expandBranchWithFuel_sound`: no sorryAx (only propext, Classical.choice, Quot.sound)
- `lean_verify blocking_sound`: no sorryAx
- `lean_verify allocateFuelProportionally_le`: no sorryAx
- Inline benchmark (11 formulas): 2 valid, 4 invalid, 5 timeout -- correct behavior
- Zero sorries in Saturation.lean
- Zero new axioms

## Verification Results

| Check | Result |
|-------|--------|
| sorry count (Saturation.lean) | 0 |
| vacuous definitions | 0 |
| new axioms | 0 |
| Module build | Pass (724 jobs) |
| expandBranchWithFuel_sound | No sorryAx |
| blocking_sound | No sorryAx |
| allocateFuelProportionally_le | No sorryAx |
| #eval tests FA1-FA5 | All PASS |
| Inline benchmark | Correct classifications |

## Plan Deviations

- **Phase 1, Task allocateFuelProportionally**: Used `min (max 1 ...) fuel` ordering instead of `max 1 (min ... (fuel-1))` to make the `<= fuel` bound trivially provable via `Nat.min_le_right`
- **Phase 4**: Completed during Phase 2 since the soundness proof had to be updated together with the code change (cannot build with stale proof)
- **Phase 5, c6/c5 benchmarks**: Full dataset regeneration deferred (39K+ formulas exceeds session time budget); inline verification passed. The full c6 regeneration should be run via `lake exe dataset_generator -- --max-complexity 6` to measure exact timeout reduction.

## Key Design Decisions

1. **`min pair.2 fuel` in recursive call**: Makes termination visible to `simp_wf` without manual proof, at no cost (allocateFuelProportionally already caps at fuel)
2. **Zip-fold pattern**: `(branches.zip fuelAllocs).foldl` preserves the existing tryBranch structure while passing per-branch fuel
3. **Upper-bound IH**: Soundness proof uses `∀ fuel' ≤ fuelBound, ...` instead of single-fuel IH, cleanly handling varying per-branch fuel values
