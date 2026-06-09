# Research Report: c7 Labeling Bug at Formula ~13,750

**Task**: 298 - Fix c7 labeling bug and regenerate dataset
**Date**: 2026-06-08
**Session**: sess_1780984632_5fd25b
**Status**: Researched

## Summary

The c7 dataset generation stalls reproducibly at formula 13,750 because the wall-clock timeout mechanism in `labelFormulaImpl` cannot actually terminate a runaway `decideAutoAdaptive` computation. The decision procedure is spawned as a pure `Task.spawn` on a dedicated OS thread. When the 1-second timeout fires, the pipeline correctly records a timeout result and attempts to move on, but the abandoned pure task continues running indefinitely -- consuming memory at ~40MB/6s -- because Lean 4's `Task.spawn` creates unkillable pure tasks. There is no `IO.cancel` call on the task, and even if there were, `decideAutoAdaptive` is a pure function that never checks `IO.checkCanceled`.

## Findings

### 1. The Problematic Formula

The existing `data/bmlogic-c7.jsonl` file contains exactly 13,749 records, confirming the stall occurs when labeling formula #13,750. The last successfully processed formula (record 13,749) is:

```
(p -> (U((S(((bot -> (q -> bot)) -> bot), bot) -> bot), (bot -> bot)) -> bot))
```

S-expression: `(imp (atom "p") (imp (untl (imp (snce (imp (imp bot (imp (atom "q") bot)) bot) bot) bot) (imp bot bot)) bot))`

This is a c7 formula (complexity 7, temporal depth 2, modal depth 0) that resolved successfully in 3ms via `adaptive_500`. Formula #13,750 is the next in enumeration order after deduplication and follows the enumeration produced by `enumExactBudget` across complexity levels 1-7.

### 2. Labeling Pipeline Architecture

The labeling pipeline flows as follows:

1. **`DatasetExport.main`** iterates over the formula list, calling `labelFormulaWithCache` for each
2. **`labelFormulaWithCache`** checks a `Std.Mutex`-protected `DecideCache`, then delegates to `labelFormula`
3. **`labelFormula`** dispatches based on `GenerationMode` (exhaustive/proofFirst/hybrid), calling `labelFormulaImpl` for exhaustive mode
4. **`labelFormulaImpl`** implements a 3-phase pipeline:
   - **Phase 1**: Structural valid prefilter (`structuralPrefilterWithAxiom`) -- O(n) pattern matching for known-valid patterns
   - **Phase 1.5**: Structural invalid prefilter (`structuralInvalidPrefilter`) -- O(n) pattern matching for known-invalid patterns
   - **Phase 2**: Decision procedure with wall-clock timeout -- spawns `decideAutoAdaptive` on a background task and polls for completion

### 3. Timeout Mechanism Analysis

The timeout implementation is in `labelFormulaImpl` (DatasetGenerator.lean, lines 1340-1437):

```lean
let task := Task.spawn (fun _ => decideAutoAdaptive φ fc) .dedicated
let deadline := startTime + wallclockTimeoutMs
let mut timedOut := false
repeat do
  let done ← IO.hasFinished task
  if done then break
  let now ← IO.monoMsNow
  if now >= deadline then
    timedOut := true
    break
  IO.sleep 1
-- ... if timedOut, return timeout result
```

**Critical problems identified:**

**Problem 1: No task cancellation.** When `timedOut` fires, the function returns a timeout `LabeledFormula` but never calls `IO.cancel task`. The pure task continues executing on its dedicated OS thread.

**Problem 2: Pure tasks are unkillable.** Even if `IO.cancel` were called, it would have no effect. Lean 4's `IO.cancel` sets a cooperative cancellation flag that must be checked via `IO.checkCanceled` (defined at `Init.System.IO:496`). But `decideAutoAdaptive` is a pure function -- it never calls `IO.checkCanceled`. The `Task.spawn` API creates pure tasks that cannot be cooperatively cancelled.

**Problem 3: Abandoned task leaks memory.** The spawned task holds a reference to the entire decision tree being built. With fuel=500 and exponential branching (each split creates multiple sub-branches, each with up to `fuel` steps), a single pathological formula can trigger 2^k branch exploration consuming gigabytes of memory.

### 4. Decision Procedure Fuel Analysis

`decideAutoAdaptive` calls `decide φ depth 500 fc` where:
- `depth = 5 + φ.complexity / 2` = 5 + 3 = 8 for c7 formulas
- `fuel = 500` (fixed, NOT the FMP-derived `soundFuel`)

Within `expandBranchWithFuel` (Saturation.lean), at each split:
- All sub-branches are explored (foldl over branches)
- Each sub-branch receives up to `fuel` steps (via `allocateFuelProportionally`)
- Blocking (subset type subsumption) should prevent infinite chains, but complex temporal formulas can create many distinct types before blocking fires

For a formula with k binary splits before blocking fires, the total work is O(2^k). With fuel=500, k could be as high as ~20-30 for temporal formulas with nested Until/Since operators, resulting in millions of branch explorations.

### 5. Why Formula 13,750 Specifically

The formula at position 13,750 in the post-dedup enumeration order is a c7 formula that:
- Passes both structural prefilters (neither obviously valid nor obviously invalid)
- Causes exponential branching in the tableau within the fuel=500 budget
- The branching does not quickly resolve -- blocking fires late or not at all within 500 steps

The reproducibility (all 3 attempts stall at exactly 13,749 records) confirms the enumeration order is deterministic and the problematic formula is always at the same position.

### 6. Why Memory Growth Is Unbounded

When the timeout fires:
1. The main thread returns a timeout result for formula 13,750
2. The background Task.spawn'd thread continues running `expandBranchWithFuel` with fuel=500
3. The exponential branching allocates new `Branch` lists, `AppliedSet` hash sets, and `TimeOrdering` structures at each level
4. The GC cannot reclaim these allocations because the still-running task holds live references
5. RSS grows at ~40MB/6s as the exponential exploration continues
6. Eventually, the system runs out of memory or the pure computation finishes (potentially hours later)

The main thread likely stalls because either:
- The next formula in the pipeline also triggers a long computation, and now TWO abandoned tasks are running
- GC pressure from the leaked task slows all IO operations, including the poll loop for subsequent formulas
- The OS begins swapping due to RSS pressure, causing all threads to slow dramatically

### 7. Existing Timeout Patterns in the Codebase

The `DatasetExport.lean` parallel path (lines 1094-1157) uses `IO.asTask` for the outer chunk processing, but `labelFormulaWithCache` internally still calls `labelFormulaImpl`, which uses the same `Task.spawn` pattern. So parallel mode has the same vulnerability.

The project has no other timeout patterns. The `isTimeoutPattern` function in DatasetExport.lean (line 834) recognizes known timeout patterns (`U(atom, X) -> U(Y, Z)` and `S(atom, X) -> S(Y, Z)`) for stratified sampling exclusion, but this pattern-matching is applied only during stratified sampling, not during exhaustive enumeration.

## Recommended Fix Strategy

### Approach A: IO-based Decision with Cooperative Cancellation (Recommended)

Convert the decision procedure invocation to use IO with a `CancelToken`:

1. **Create an IO wrapper for `decide`** that periodically checks a cancellation token:
   ```lean
   def decideAutoAdaptiveIO (φ : Formula) (fc : FrameClass) (cancel : IO.CancelToken)
       : IO (DecisionResult φ × String) := do
     -- Wrap the pure decide, checking cancellation between major phases
     if ← cancel.isSet then return (.timeout, "cancelled")
     -- ... check between axiom proof, proof search, and tableau phases
   ```

2. **Insert cancellation checks in `expandBranchWithFuel`**: Add a cancellation check at each recursive call. Since `expandBranchWithFuel` is pure, this requires either:
   - Converting it to a `ReaderT CancelToken IO` monad (higher impact but thorough)
   - Adding a step counter to the pure function that returns `.timeout` at a lower fuel threshold (simpler but less responsive)

3. **Use `IO.asTask` instead of `Task.spawn`** and call `IO.cancel` on timeout.

**Pros**: Complete fix; the decision procedure truly stops when cancelled.
**Cons**: Requires modifying the core decision procedure (Saturation.lean, DecisionProcedure.lean); need to verify termination proofs still compile.

### Approach B: IO Wrapper with Cancel + Lower Fuel (Moderate)

Keep the pure `decideAutoAdaptive` but add cancellation awareness at the IO boundary:

1. **Wrap `decideAutoAdaptive` in an IO function** using `IO.asTask`:
   ```lean
   let task ← IO.asTask (do
     let result := decideAutoAdaptive φ fc
     return result) .dedicated
   ```

2. **Call `IO.cancel task` when timeout fires**

3. **Insert `IO.checkCanceled` at strategic points** in the IO wrapper -- but since the actual computation is pure (no IO yield points), cancellation can only fire between the IO task setup and the pure computation start. This means the pure computation itself is still not interruptible.

4. **Reduce fuel as a secondary defense**: Lower fuel from 500 to e.g. 200 for c7+, ensuring the exponential expansion stays bounded.

**Pros**: Simpler; no changes to Saturation.lean termination proofs.
**Cons**: The pure computation is still not truly interruptible; it can only be cancelled before it starts. The lower fuel may cause false timeouts for formulas that legitimately need 500 steps.

### Approach C: Fuel Reduction + Abandoned Task Mitigation (Simplest)

Keep the current architecture but:

1. **Reduce fuel for high-complexity formulas**: Use formula-adaptive fuel instead of fixed 500:
   ```lean
   let fuel := min 500 (200 + φ.complexity * 10)  -- ~270 for c7
   ```

2. **Add `IO.cancel task` after timeout fires**: Even though it won't stop the pure computation, it signals to the runtime that the task result is no longer needed.

3. **Add a global memory watchdog**: Before labeling each formula, check RSS and skip formulas if RSS exceeds a threshold.

4. **Extend structural prefilters**: The `isTimeoutPattern` function already recognizes `U(atom, X) -> U(Y, Z)` patterns. Extend it to cover the formula at position 13,750 and similar patterns.

**Pros**: Minimal code changes; no impact on termination proofs.
**Cons**: Does not fix the root cause; relies on heuristics.

### Approach D: Convert Decide to Step-Limited Pure Function (Best Long-Term)

Modify `expandBranchWithFuel` to also limit total branches explored, not just fuel:

1. **Add a branch counter**: Track total branches explored across all splits. Return `.timeout` when a global branch limit is exceeded.

2. **Thread the counter through recursion**: The counter is pure (just a `Nat`), so no monad change needed.

3. **Set a reasonable branch limit**: e.g., 10,000 total branches explored. This prevents exponential blowup regardless of fuel.

**Pros**: Fixes the root cause in the pure function; no IO/monad changes; termination proof adapts easily.
**Cons**: Requires modifying `expandBranchWithFuel` signature and threading the counter.

### Recommended Fix Order

1. **Immediate fix (Approach C + D hybrid)**: Add `IO.cancel` to timeout path, reduce fuel, AND add a branch counter limit to `expandBranchWithFuel`. This addresses both the symptom (leaked tasks) and root cause (exponential branching).

2. **Long-term fix (Approach A)**: Convert the decision procedure to IO with proper cancellation for a complete solution.

## Key Files

| File | Role | Lines of Interest |
|------|------|-------------------|
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | Labeling pipeline, timeout mechanism | 1340-1437 (timeout loop), 1350 (Task.spawn) |
| `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` | Decision procedure entry points | 198-203 (decideAutoAdaptive) |
| `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` | Tableau expansion with fuel | 228-277 (expandBranchWithFuel), 258-276 (split handling) |
| `Theories/Bimodal/Automation/DatasetExport.lean` | CLI entry point, formula iteration | 1094-1197 (labeling loop) |
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | Formula enumeration | 154-302 (enumExactHelper) |

## Appendix: Lean 4 Task/Cancellation API Summary

| API | Type | Effect |
|-----|------|--------|
| `Task.spawn f .dedicated` | Creates pure task | Runs `f` on a new OS thread; result accessible via `Task.get`; no cancellation mechanism |
| `IO.asTask act .dedicated` | Creates IO task | Runs `act` on a new OS thread; cancellable via `IO.cancel`; must call `IO.checkCanceled` to respond |
| `IO.cancel task` | Cooperative cancellation | Sets a flag that `IO.checkCanceled` reads; only works for IO tasks |
| `IO.checkCanceled` | Check cancellation flag | Returns `true` if `IO.cancel` was called on the current task |
| `IO.hasFinished task` | Poll task state | Returns `true` if the task has completed |
| `IO.CancelToken` | Shared cancellation cell | Mutable `Bool` ref; `set`/`isSet` for cross-task cancellation |
