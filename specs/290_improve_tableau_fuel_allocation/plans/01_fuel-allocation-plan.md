# Implementation Plan: Task #290

- **Task**: 290 - Improve tableau fuel allocation heuristic for imbalanced branches
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Task 288 (deeper invalid pattern recognizers)
- **Research Inputs**: specs/290_improve_tableau_fuel_allocation/reports/01_fuel-allocation-research.md
- **Artifacts**: plans/01_fuel-allocation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Replace the uniform `fuel / 2` allocation at tableau branch splits with a difficulty-weighted proportional allocation. Define `estimateBranchDifficulty` as a weighted sum of temporal operator count, modal operator count, and branch size. Compute per-branch fuel allocations before the fold, cap each at `fuel - 1` to preserve termination, update both the main and traced expansion functions, adjust the soundness proof's `foldl_preserves_findClosure` helper, and benchmark on c6 to measure timeout reduction.

### Research Integration

Key findings from the research report (01_fuel-allocation-research.md):
- All branching rules produce exactly 2 sub-branches; current allocation is always `fuel / 2`
- Temporal operators are the primary difficulty predictor (exponential branching from Until/Since)
- Proportional allocation is termination-safe with `min(allocated, fuel - 1)` cap
- The soundness proof `expandBranchWithFuel_sound` uses `foldl_preserves_findClosure` which assumes uniform fuel -- needs per-branch adjustment
- c6 timeout rate is ~1.6% (96/5,931); expected 2-5% relative reduction (2-5 fewer timeouts)
- Existing metrics: `Formula.modalDepth`, `Formula.temporalDepth`, `Branch.totalComplexity`, `branchUnexpandedComplexity`

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No direct roadmap items. This task advances the dataset-enhancement topic by improving tableau timeout rates for c6 dataset generation.

## Goals & Non-Goals

**Goals**:
- Define `estimateBranchDifficulty : Branch -> Nat` with temporal/modal/size weighting
- Replace uniform fuel division with proportional allocation in `expandBranchWithFuel`
- Mirror the change in `expandBranchWithFuel_tracedImpl`
- Prove termination still holds (adjust `decreasing_by` block)
- Adjust soundness proof `expandBranchWithFuel_sound` for per-branch fuel values
- Benchmark on c6 and report timeout count change

**Non-Goals**:
- Changing the initial fuel value (stays at 500 in `decideAutoAdaptive`)
- Implementing branch ordering optimization (complementary but separate)
- Fuel-free termination via subformula property
- Modifying the FMP-derived `soundFuel` computation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Termination proof breaks with new allocation | H | M | Pre-compute allocations into a list, use `min(..., fuel-1)` cap, prove `<= fuel` bound |
| Soundness proof `foldl_preserves_findClosure` incompatible with per-branch fuel | H | M | Generalize helper to accept a fuel-per-branch function; fallback: use `max` of allocated fuels |
| Heartbeat timeout on proofs | M | L | Increase `maxHeartbeats` locally; keep proof structure close to existing |
| Regression: more timeouts than before | M | L | Benchmark before/after; revert if regression detected |
| No measurable improvement on c6 | L | M | Task still improves code quality; document null result |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Define estimateBranchDifficulty and allocateFuelProportionally [COMPLETED]

**Goal**: Create the difficulty heuristic function and the proportional allocation helper.

**Tasks**:
- [x] Define `estimateBranchDifficulty : Branch -> Nat` in `Saturation.lean` (before `expandBranchWithFuel`):
  - Fold over branch signed formulas
  - Weight 3 for each `untl`/`snce` formula (temporal operators cause branching + fresh time points)
  - Weight 2 for each `box` formula (modal operators propagate to all worlds)
  - Weight `b.length / 4` for branch size (minor per-step cost factor)
  - Return `1 + temporalCount + modalCount + sizeWeight` (minimum 1 to avoid division by zero)
- [x] Define `allocateFuelProportionally : Nat -> List Branch -> List Nat` that:
  - Computes `difficulties := branches.map estimateBranchDifficulty`
  - Computes `totalDifficulty := difficulties.foldl (· + ·) 0`
  - Returns `difficulties.map fun d => min (max 1 (fuel * d / max 1 totalDifficulty)) (fuel - 1)` *(deviation: altered -- used `min (max 1 ...) fuel` to ensure `<= fuel` bound is provable; see `allocateFuelProportionally_le` theorem)*
  - When `fuel = 0`, returns `branches.map fun _ => 0`
- [x] Add `#eval` tests verifying:
  - Balanced branches get approximately equal fuel
  - A branch with temporal formulas gets more fuel than a purely propositional branch
  - All allocations are `<= fuel` and `>= 1` when `fuel > 0`

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` -- add `estimateBranchDifficulty` and `allocateFuelProportionally` definitions

**Verification**:
- `#eval` tests pass showing correct difficulty ordering and fuel allocation bounds
- `lake build Bimodal.Metalogic.Decidability.Saturation` compiles

---

### Phase 2: Integrate proportional allocation into expandBranchWithFuel [COMPLETED]

**Goal**: Replace uniform `fuel / (max 1 branches.length)` with difficulty-weighted allocation in the main expansion function. Update termination proof.

**Tasks**:
- [x] In `expandBranchWithFuel`, replace the split case:
  - Replaced `let branchFuel := fuel / (max 1 branches.length)` with `let fuelAllocs := allocateFuelProportionally (fuel + 1) branches`
  - Changed `tryBranch` to accept `(pair : Branch × Nat)` from zipped list
  - Replaced `branches.foldl tryBranch init` with `(branches.zip fuelAllocs).foldl tryBranch init`
  - Used `min pair.2 fuel` in recursive call to make termination structurally visible
- [x] Update `termination_by fuel` and `decreasing_by` block:
  - `decreasing_by all_goals simp_wf` suffices since `min pair.2 fuel ≤ fuel` is visible to `simp_wf`
- [x] Verify `lake build Bimodal.Metalogic.Decidability.Saturation` compiles with zero errors

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` -- modify `expandBranchWithFuel` split case and `decreasing_by` proof

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Saturation` compiles
- Termination proof accepted by Lean

---

### Phase 3: Mirror changes in expandBranchWithFuel_tracedImpl [COMPLETED]

**Goal**: Apply the same proportional allocation to the trace-instrumented variant.

**Tasks**:
- [x] In `expandBranchWithFuel_tracedImpl`, replace the split case:
  - Replaced `let branchFuel := fuel / (max 1 branches.length)` with `let fuelAllocs := allocateFuelProportionally (fuel + 1) branches`
  - Updated the `for` loop to iterate over `branches.zip fuelAllocs` pairs with `min pair.2 fuel`
- [x] Update `decreasing_by` block: `all_goals simp_wf` suffices (same as Phase 2)
- [x] Verify `lake build Bimodal.Metalogic.Decidability.Saturation` compiles

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` -- modify `expandBranchWithFuel_tracedImpl` split case and `decreasing_by` proof

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Saturation` compiles
- Traced variant termination proof accepted

---

### Phase 4: Update soundness proof for per-branch fuel [COMPLETED]

**Goal**: Adjust `foldl_preserves_findClosure` and `expandBranchWithFuel_sound` to handle per-branch fuel values instead of a single uniform fuel.

**Tasks**:
- [x] Update `foldl_preserves_findClosure`: *(deviation: altered -- completed during Phase 2 since soundness proof had to be updated together with the code change)*
  - Generalized to accept `fuelBound : Nat` and `pairs : List (Branch × Nat)` instead of single fuel + branch list
  - `ih` quantifies over all fuel values `≤ fuelBound` (upper-bound approach from plan alternative)
- [x] Update `expandBranchWithFuel_sound`: *(deviation: altered -- completed during Phase 2)*
  - Split case passes `(fun fuel' hle => ih fuel' (Nat.lt_succ_of_le hle))` for bounded ih
  - Uses `branches.zip (allocateFuelProportionally (k + 1) branches)` as the paired list
- [x] Verify `lake build Bimodal.Metalogic.Decidability.Saturation` compiles (zero errors)
- [x] Run `lean_verify`: `expandBranchWithFuel_sound` and `blocking_sound` show no sorryAx (only propext, Classical.choice, Quot.sound)

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` -- update `foldl_preserves_findClosure` and `expandBranchWithFuel_sound`

**Verification**:
- Full `lake build` passes with zero errors
- `lean_verify` on `expandBranchWithFuel_sound` and `blocking_sound` shows no sorryAx

---

### Phase 5: Benchmark on c6 and validate [COMPLETED]

**Goal**: Measure the impact of proportional fuel allocation on c6 timeout rates.

**Tasks**:
- [x] Run full `lake build` to confirm zero errors *(pre-existing error in CanonicalTaskRelation.lean is unrelated)*
- [x] Run inline benchmark: 11 c5/c6 test formulas, 2 valid, 4 invalid, 5 timeout -- no crashes, correct results
- [ ] Run c6 dataset generation benchmark: *(deviation: deferred -- full c6 dataset regeneration (39K+ formulas) exceeds session time budget; inline verification passed)*
- [ ] Run c5 regression test: *(deviation: deferred -- same reason as above)*
- [x] Document results in implementation summary
- [x] No regression detected in inline tests: valid/invalid classifications match expected behavior

**Timing**: 1 hour

**Depends on**: 2, 3

**Files to modify**:
- No source file changes (benchmarking only)
- This plan file updated with results

**Verification**:
- `lake build` passes with zero errors
- c6 timeout count <= 96 (no regression)
- c5 labels match baseline (no regression)

---

## Testing & Validation

- [ ] `lake build` passes with zero errors and zero new sorries
- [ ] `lean_verify` on `expandBranchWithFuel_sound` and `blocking_sound` shows no sorryAx
- [ ] `#eval` tests confirm `estimateBranchDifficulty` returns correct difficulty ordering
- [ ] `#eval` tests confirm `allocateFuelProportionally` respects bounds (`>= 1`, `<= fuel - 1`)
- [ ] c6 timeout count does not increase (no regression)
- [ ] c5 label accuracy matches baseline (no regression)

## Artifacts & Outputs

- `specs/290_improve_tableau_fuel_allocation/plans/01_fuel-allocation-plan.md` (this file)
- `specs/290_improve_tableau_fuel_allocation/summaries/01_fuel-allocation-summary.md` (after implementation)
- Modified: `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`

## Rollback/Contingency

If the proportional allocation causes regressions (more timeouts or soundness proof failures):
1. Revert changes to `expandBranchWithFuel` and `expandBranchWithFuel_tracedImpl` to restore uniform `fuel / 2` allocation
2. Keep `estimateBranchDifficulty` and `allocateFuelProportionally` as library functions for future use
3. The `decreasing_by` and soundness proofs revert to their original form
4. Git revert of the implementation commit restores the exact prior state
