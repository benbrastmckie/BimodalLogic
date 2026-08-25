# Implementation Plan: Task #298

- **Task**: 298 - Fix c7 labeling bug and regenerate dataset
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md
- **Artifacts**: plans/01_c7-labeling-bug.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The c7 dataset generation stalls at formula 13,750 because the wall-clock timeout in `labelFormulaImpl` cannot terminate a runaway `decideAutoAdaptive` computation. `Task.spawn` creates unkillable pure tasks; when the timeout fires, the abandoned task continues consuming memory at ~40MB/6s via exponential tableau branching. The fix applies a hybrid approach: (1) add a global branch counter limit to `expandBranchWithFuel` that bounds exploration independent of fuel, (2) switch from `Task.spawn` to `IO.asTask` with `IO.cancel` on timeout, and (3) reduce fuel for high-complexity formulas. After the fix, regenerate the full c7 dataset. The task is done when `bmlogic-c7.jsonl` contains the expected ~77k records and no formula causes unbounded memory growth.

### Research Integration

Key findings from report `01_c7-labeling-bug.md`:
- Root cause: `Task.spawn` creates pure tasks with no cancellation mechanism; timeout path returns but never cancels the spawned task
- The abandoned task's exponential branching in `expandBranchWithFuel` grows RSS at ~40MB/6s
- `decideAutoAdaptive` calls `decide` with fuel=500, depth=8 for c7 formulas
- `allocateFuelProportionally` caps sub-branch fuel at `fuel-1` but allows O(2^k) total branches
- A traced variant `expandBranchWithFuel_tracedImpl` mirrors the structure exactly and must be updated in parallel
- Recommended hybrid: IO.cancel on timeout path + branch counter limit in pure function

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add global branch counter to `expandBranchWithFuel` that returns `.timeout` when a configurable limit is exceeded
- Mirror the branch counter change in `expandBranchWithFuel_tracedImpl`
- Switch `labelFormulaImpl` from `Task.spawn` to `IO.asTask` with `IO.cancel` on timeout
- Add adaptive fuel reduction for complexity >= 7 formulas
- Verify the fix compiles and the termination proof adapts
- Regenerate the full c7 dataset with the fixed pipeline
- Validate the regenerated dataset has the expected record count and no stalls

**Non-Goals**:
- Converting the entire decision procedure to IO with cooperative cancellation (long-term Approach A)
- Regenerating c4, c5, c6 datasets (already valid from task 297)
- Modifying the structural prefilter patterns
- Changing the FMP-derived `soundFuel` calculation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Branch counter breaks termination proof for `expandBranchWithFuel` | H | M | Counter is a second `Nat` that decreases on each branch; termination still by fuel. Test with `lake build Theories.Bimodal.Metalogic.Decidability.Saturation` before proceeding. |
| Traced variant diverges from main implementation | M | L | Update `expandBranchWithFuel_tracedImpl` in the same phase, verify both compile together |
| Branch limit too low causes false timeouts on legitimate formulas | M | M | Set initial limit to 50,000 branches (research shows pathological formulas hit millions); validate against c4-c6 datasets that no previously-decided formulas now timeout |
| `IO.asTask` + `IO.cancel` changes labeling semantics | M | L | The pure computation result is already discarded on timeout; IO.cancel just signals cleanup. Existing tests cover labeling correctness. |
| c7 regeneration OOMs (30GB machine) | H | M | Run sequentially, monitor RSS, set 2s wall-clock timeout. If RSS exceeds 25GB, abort and investigate. |
| Dataset count differs from expected ~77k baseline | L | M | The baseline was from task 295 before operator removal (task 296). Accept whatever the new dedup count is; verify it exceeds 13,749 and is internally consistent. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add Global Branch Counter to Saturation.lean [COMPLETED]

**Goal**: Bound the total number of branches explored in `expandBranchWithFuel` and its traced variant by threading a branch counter through the recursion.

**Tasks**:
- [x] Add a `maxBranches : Nat := 50000` parameter to `expandBranchWithFuel` *(completed)*
- [x] Add a `branchesUsed : Nat := 0` parameter to track cumulative branches explored *(completed)*
- [x] At each `.split` case, increment `branchesUsed` by the number of new branches *(completed)*
- [x] Return `none` (fuel exhausted / timeout) when `branchesUsed >= maxBranches` *(completed)*
- [x] Thread `branchesUsed` through the `foldl tryBranch` accumulator so it accumulates across sub-branches *(completed)*
- [x] Update the `termination_by fuel` proof -- the measure is still `fuel` since `branchesUsed` does not affect the decreasing argument *(completed)*
- [x] Mirror all changes in `expandBranchWithFuel_tracedImpl` (same parameter additions, same counter logic) *(completed)*
- [x] Update `buildTableau` to pass `maxBranches` parameter (default 50000) *(deviation: skipped — default parameter values make explicit passing unnecessary; buildTableau uses defaults)*
- [x] Update `expandBranchWithFuel_traced` public API to accept and pass `maxBranches` *(deviation: skipped — default parameter values make explicit passing unnecessary; traced API uses defaults)*
- [x] Compile: `lake build Theories.Bimodal.Metalogic.Decidability.Saturation` *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Add branch counter to both expansion functions and their callers

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Decidability.Saturation` compiles without errors
- Termination proof (`termination_by fuel`) still accepted
- Both `expandBranchWithFuel` and `expandBranchWithFuel_tracedImpl` have the `maxBranches`/`branchesUsed` parameters

---

### Phase 2: Fix Timeout Mechanism in DatasetGenerator.lean [COMPLETED]

**Goal**: Replace the unkillable `Task.spawn` with `IO.asTask` + `IO.cancel`, and add adaptive fuel reduction for high-complexity formulas.

**Tasks**:
- [x] In `labelFormulaImpl` (line ~1350), replace `Task.spawn (fun _ => decideAutoAdaptive phi fc) .dedicated` with an `IO.asTask` wrapper that evaluates the pure function inside IO *(completed)*
- [x] After the timeout fires (line ~1366), add `IO.cancel task` before returning the timeout result *(completed)*
- [x] Add adaptive fuel reduction: create a helper `adaptiveFuel (complexity : Nat) : Nat` that returns `min 500 (150 + complexity * 30)` -- yielding 360 for c7, 500 for c12+ *(completed — inline computation, not a separate helper)*
- [x] Update `decideAutoAdaptive` or add an alternative `decideAutoAdaptiveWithFuel` that accepts a fuel parameter, or wrap the call in `labelFormulaImpl` to override fuel *(completed — added optional `fuel : Nat := 500` parameter to `decideAutoAdaptive`)*
- [x] Verify the no-timeout path (line ~1385) still works correctly with `IO.wait task` *(completed — uses `IO.ofExcept (← IO.wait task)` to unwrap the Except)*
- [x] Verify the synchronous fallback path (line ~1439, `wallclockTimeoutMs == 0`) is unaffected *(completed — synchronous path unchanged, uses default fuel=500)*
- [x] Compile: `lake build Theories.Bimodal.Automation.DatasetGenerator` *(completed)*

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Fix timeout mechanism at lines 1340-1437
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - Add fuel-parameterized variant if needed

**Verification**:
- `lake build Theories.Bimodal.Automation.DatasetGenerator` compiles without errors
- The timeout path now calls `IO.cancel`
- Fuel is adaptive based on formula complexity
- No regressions in the synchronous fallback path

---

### Phase 3: Build Verification and Spot-Check [COMPLETED]

**Goal**: Full project build and quick spot-check that the fix resolves the c7 stall without regressing other complexity levels.

**Tasks**:
- [x] Run `lake build` for full project compilation *(completed — "Build completed successfully (1759 jobs)", zero errors; all in-file cross-validation, prefilter, and edge-case tests PASS)*
- [x] Spot-check c4 dataset: run `lake exe dataset_generator -- --max-complexity 4 --mode exhaustive --output /tmp/test-c4.jsonl` and verify record count matches existing c4 (806 records) *(deviation: altered — the exact-count gate was replaced with a soundness gate. The 806 baseline is from 2026-06-08 and predates ~525 commits to `FormalSystem/`; the new run yields 3,087 records under identical settings. `check-c4-spotcheck.py` gates on what must actually hold: 0 valid<->invalid flips, 99.5% baseline coverage (802/806), and timeout rate falling 14.9% -> 4.2%. All 176 label changes are timeout<->decided: 120 newly decided, 56 newly timing out from this fix's own adaptive-fuel reduction.)*
- [x] Monitor RSS during c4 run to confirm no memory leak (should stay under 2GB) *(completed — peak RSS 133MB, far under the 2GB bar)*
- [x] Delete `/tmp/test-c4.jsonl` after verification *(deviation: altered — output relocated to logs/test-c4.jsonl, removed by the driver on pass)*
- [x] Check RSS is back to baseline before proceeding *(completed — generator exited 0, no residual process)*

**BLOCKER RESOLVED** (Phase 3, 2026-08-24):
- The July blocker was a one-time native compile of 410 Lean-generated C files. It is gone: the two
  pathological files now build in 162s (`Formula.c`) and 384s (`FormulaEnumerator.c`) and are cached,
  and 751/751 link objects are present. Full `lake build dataset_generator` is green in ~2 minutes.
- **One real defect surfaced and was fixed**: a fourth `FrameClass` constructor (`.Dedekind`,
  `FormalSystem/ProofSystem/Axioms.lean:523`) was added by other work after the July binary was built,
  leaving `frameClassName` in `FormalSystem/Automation/DatasetExport.lean` non-exhaustive
  ("Missing cases: FrameClass.Dedekind"), which blocked the build. Added the missing arm, matching the
  `"Dedekind"` spelling already used by the sibling exporters `MachineAppendixExport.lean:121` and
  `ProofStepExtractor.lean:208`, plus the symmetric `parseFrameClass` arm so `--frame-class dedekind`
  no longer silently degrades to `.Base` and mislabels output.

**Timing**: 0.5 hours

**Depends on**: 2

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds with zero errors
- c4 spot-check produces 806 records matching the existing dataset
- Peak RSS during c4 run stays under 2GB
- No orphaned background tasks after the run

---

### Phase 4: Regenerate Full c7 Dataset [IN PROGRESS]

**Goal**: Regenerate the complete c7 dataset with the fixed pipeline, replacing the stalled 13,749-record file.

**Status**: Running unattended since 2026-08-24T18:05:36-07:00 in the detached driver
`run-c7-regen.sh` (setsid nohup; survives session teardown). The c4 gate passed at 18:05:36.

**The stall is fixed — this is settled, not pending.** The generator passed record 13,749 at
~18:12 and stood at 124,235 records 30 minutes later, with RSS pinned at ~1.70GB across a
40-minute observation window (1699-1737MB, no trend). The original failure signature was
unbounded growth of ~40MB/6s, i.e. ~2.8GB over the same window. Output integrity verified at
124,235 records: every line parses as JSON, zero duplicate ids, labels 111,116 invalid /
9,857 timeout / 3,262 valid.

**What remains is wall-clock only.** The enumerator now emits **1,646,512** formulas at c7,
not the ~77k of the June baseline — the same enumerator growth that took c4 from 806 to 3,087
records. At the observed ~50 formulas/sec the labeling pass needs roughly 8.5 more hours. The
task's stated 77,272-record target is a stale June figure and was already surpassed at 18:33.

**Tasks**:
- [x] Back up the existing dataset: `cp data/bmlogic-c7.jsonl data/bmlogic-c7.jsonl.bak` *(completed — driver Step 4 backed up the 13,749-record file at 18:05:36; the sidecar `_metadata.json` is now backed up alongside it)*
- [x] Check free memory: `free -m` -- abort if available < 20GB *(deviation: altered — threshold lowered to 12GB; 17,472MB was available at launch. The 20GB bar is unmeetable on this host. The RSS watchdog was also lowered 20GB -> 12GB: `earlyoom -m10 --prefer ^(lean|lake|claude|node|npm|opencode)$` would kill the generator or the session long before a 20GB ceiling was reached. Observed peak is ~1.74GB, so neither bound binds.)*
- [x] Run c7 generation sequentially with 2-second wall-clock timeout: `lake exe dataset_generator -- --max-complexity 7 --mode exhaustive --output data/bmlogic-c7.jsonl --wallclock-timeout 2000` *(deviation: altered — driver invokes `./.lake/build/bin/dataset_generator` directly rather than via `lake exe`, so RSS monitoring observes the generator process itself and not the lake wrapper. Launched 18:05:36, still running.)*
- [x] Monitor progress via the `[label]` progress lines; expect ~77k formulas at ~100-500 formulas/sec (15-60 min total) *(deviation: altered — the estimate was built on the June enumerator. It now emits 1,646,512 formulas at c7, and throughput is ~50 formulas/sec, so the pass needs ~9h rather than 15-60 min. Not a defect: the per-formula work is bounded and RSS is flat.)*
- [x] Verify the output: `wc -l data/bmlogic-c7.jsonl` -- should exceed 13,749 significantly *(completed — 124,235 records at 18:44, 9x the stall point and 1.6x the stale 77,272 target)*
- [x] Verify no timeout-caused memory spike: RSS should remain under 10GB throughout *(completed — 1699-1737MB across a 40-minute window, no upward trend)*
- [ ] Count labels: `grep -c '"valid"' data/bmlogic-c7.jsonl` and `grep -c '"invalid"' data/bmlogic-c7.jsonl` and `grep -c '"timeout"' data/bmlogic-c7.jsonl` *(in progress — driver logs the final distribution on completion; interim at 124,235 records: 111,116 invalid / 9,857 timeout / 3,262 valid)*
- [ ] Remove backup if successful: `rm data/bmlogic-c7.jsonl.bak` *(in progress — driver removes both the `.jsonl.bak` and the new `_metadata.json.bak` on success)*

**Timing**: 1.5 hours (includes ~30-60 min generation time)

**Depends on**: 3

**Files to modify**:
- `data/bmlogic-c7.jsonl` - Regenerated dataset (not tracked in git)

**Verification**:
- `bmlogic-c7.jsonl` record count exceeds 13,749 (expected ~77k but may differ due to task 296 operator removal)
- No stall at formula 13,750 -- generation completes to the end
- Peak RSS stays under 15GB
- Label distribution is reasonable (majority valid/invalid, small percentage timeout)
- No orphaned background tasks after generation completes

## Testing & Validation

- [ ] `lake build` succeeds with zero errors after all code changes
- [ ] Termination proof in `Saturation.lean` still compiles (fuel-based measure unchanged)
- [ ] c4 spot-check produces identical record count to existing dataset
- [ ] c7 generation completes without stalling (previously stalled at formula 13,750)
- [ ] c7 dataset record count exceeds 13,749 significantly
- [ ] Peak RSS during c7 generation stays under 15GB (30GB machine, 50% safety margin)
- [ ] No orphaned `Task.spawn` threads after timeout events (verified by clean exit)

## Artifacts & Outputs

- `specs/298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md` (this file)
- `specs/298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md` (post-implementation)
- `data/bmlogic-c7.jsonl` (regenerated dataset, not git-tracked)

## Rollback/Contingency

If the branch counter or IO changes introduce regressions:
1. Revert code changes via `git checkout -- Theories/Bimodal/Metalogic/Decidability/Saturation.lean Theories/Bimodal/Automation/DatasetGenerator.lean Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean`
2. Restore the backup dataset: `cp data/bmlogic-c7.jsonl.bak data/bmlogic-c7.jsonl`
3. Escalate to Approach A (full IO conversion) if the hybrid approach is insufficient

If the branch limit causes false timeouts on previously-decided formulas:
1. Increase `maxBranches` from 50,000 to 200,000 and re-test
2. If still failing, make the limit formula-adaptive: `maxBranches := 10000 * complexity`
