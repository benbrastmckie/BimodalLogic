# Research Report: Progress Reporting for Dataset Generation Pipeline

**Task**: 253
**Date**: 2026-06-01
**Status**: Researched

## Summary

The dataset generation pipeline (`lake exe dataset_generator`) has two long-running phases that currently produce no progress output: (1) formula enumeration/generation via `generateFormulas` in `FormulaEnumerator.lean`, and (2) the labeling loop in `DatasetExport.lean`'s `main`. The labeling phase already has progress reporting every 1000 formulas (line 556-560), but the formula generation phase -- which can take minutes to hours at high complexity -- emits only "Generating formulas..." before going silent. This research identifies exactly where progress checkpoints should be inserted and what information is available to report at each point.

## Current Architecture

### Pipeline Flow

```
main (DatasetExport.lean)
  |
  +-- Step 1: generateFormulas (FormulaEnumerator.lean)   <-- SILENT, can take hours
  |     |
  |     +-- enumerateExhaustive / enumerateStratified      <-- Pure, no IO
  |     |     (iterates complexity levels 1..maxComplexity)
  |     |
  |     +-- generateValidBatch                             <-- IO, has loops
  |           (axiom seeding + fixpoint Nec/MP closure)
  |
  +-- Step 2: enrichWithDuals                              <-- Pure, fast
  |
  +-- Step 3-4: Labeling loop                              <-- Has progress (every 1000)
  |     (labelFormula per formula, write JSONL line)
  |
  +-- Steps 5-7: Stats, metadata, feasibility              <-- Fast
```

### Current Output Gaps

1. **`generateFormulas`** (line 1154, FormulaEnumerator.lean): Calls `enumerateExhaustive`/`enumerateStratified` (pure, no IO) then `generateValidBatch` (IO). The pure enumeration phase is the primary bottleneck at complexity 9+ and produces zero output.

2. **`enumerateExhaustive`** (line 578): Pure function iterating complexity levels 1 to `maxComplexity`. Each level calls `enumExactBudget` with memoization. At complexity 9, levels 8-9 dominate runtime. No IO possible in current signature.

3. **`enumerateStratified`** (line 1102): Also pure. Same issue.

4. **`generateValidBatch`** (line 993): IO function with clear loop structure:
   - Phase 1: Seed pool with `seedCount` axiom instances (line 1004, loop over `List.range seedCount`)
   - Phase 2: Ex-falso cap (fast, negligible)
   - Phase 3: Fixpoint Nec/MP closure (line 1044, `while round < 10 && poolArr.size < 10000`)
   - Phase 4: Filtering (fast)

5. **`main`** labeling loop (line 540, DatasetExport.lean): Already has progress every 1000 formulas. This is adequate but could be improved with rate and ETA.

## Analysis of Each Insertion Point

### Point 1: `generateFormulas` -- Wrapping the Two Sub-Phases

`generateFormulas` is the IO entry point. It already does IO (calls `generateValidBatch` and `sampleRandom`). Adding `IO.eprintln` calls here is trivial.

**What to report**:
- Start/end of enumeration sub-phase (exhaustive/stratified/random/hybrid)
- Start/end of valid-seed generation sub-phase
- Formula counts after each sub-phase

**Change**: Add `IO.eprintln` before and after the `match params.samplingMode` block and before/after `generateValidBatch`.

### Point 2: `enumerateExhaustive` / `enumerateStratified` -- Per-Complexity-Level Progress

These are pure functions (`List Formula` return type, no IO). To add progress reporting, they need to become IO functions.

**Option A -- Convert to IO**: Change signatures from `List Formula` to `IO (List Formula)`. Insert `IO.eprintln` at each complexity level iteration. This requires changing all callers.

**Option B -- IO wrapper with per-level calls**: Instead of calling the pure function once, break the loop into the `main` function: iterate complexity levels 1..N in IO code, calling `enumExactBudget` (pure) per level, and emitting progress between levels.

**Recommendation**: Option B is cleaner. The memoization cache (`EnumCache`) is threaded through the fold in `enumerateExhaustive`. We can replicate this fold in IO code in `generateFormulas` or `main`, calling `enumExactBudget` per level and emitting progress between levels.

**What to report per level**:
- Current complexity level and total levels
- Formulas generated at this level
- Cumulative formula count
- Elapsed time since generation started
- Formulas/second rate

### Point 3: `generateValidBatch` -- Axiom Seeding and Closure Rounds

Already an IO function. The two loops (axiom seeding, fixpoint closure) have natural progress points.

**Phase 1 (Axiom seeding)**: The `for _ in List.range seedCount` loop (line 1004) iterates `seedCount` times (500-10000). Each iteration is fast (microseconds), so reporting every N iterations (e.g., every 500 or every 10%) is appropriate.

**Phase 3 (Fixpoint closure)**: The `while` loop (line 1044) runs up to 10 rounds. Each round does Nec+MP over the full pool. Report per round: round number, pool size, new formulas added, growth rate.

**What to report**:
- Axiom seeding: `Seeding: {count}/{seedCount} axiom instances, pool size: {poolSize}`
- Closure: `Closure round {round}: pool size {poolSize} (+{growth}), growth rate {rate}%`

### Point 4: `main` Labeling Loop -- Enhanced Progress

Current progress (line 556-560) reports every 1000 formulas: count, total, valid%, elapsed seconds.

**Enhancements**:
- Add formulas/second rate
- Add ETA (estimated time to completion)
- Report current formula complexity (to show progression through complexity levels)
- Report per-label breakdown (valid/invalid/timeout counts)

### Point 5: Shell Script -- Stderr Passthrough

Currently `run_dataset_generation.sh` uses `time lake exe dataset_generator -- ...` which captures wall-clock time. Progress written to stderr (`IO.eprintln`) will appear in real-time since stderr is unbuffered. Progress written to stdout (`IO.println`) will also appear since the shell does not redirect stdout.

**Recommendation**: Use `IO.eprintln` for progress lines (stderr) to keep stdout clean for potential piping. However, the current codebase uses `IO.println` for all output including the existing progress line. For consistency, continue using `IO.println` -- the shell script does not redirect stdout. If downstream users need clean stdout, a future task can separate data output (stdout) from progress (stderr).

**Shell script changes**: Minimal. The script already wraps each run with start/end timestamps. The Lean executable's enhanced progress will appear automatically. No parsing needed.

## Proposed Implementation Approach

### Phase 1: Per-Complexity-Level Progress in Formula Generation

Refactor `generateFormulas` to iterate complexity levels in IO code rather than delegating to the pure `enumerateExhaustive`/`enumerateStratified` functions. This means:

1. Add a new IO function `enumerateWithProgress` in `FormulaEnumerator.lean` that:
   - Takes `EnumParams` and iterates complexity levels 1..`maxComplexity`
   - Calls `enumExactBudget` (pure) per level
   - Applies `passesFilter` per level
   - For stratified mode: applies per-level quotas
   - Emits progress per level via `IO.println`
   - Threads the `EnumCache` through levels (same as the pure versions)

2. Modify `generateFormulas` to call `enumerateWithProgress` instead of `enumerateExhaustive`/`enumerateStratified`.

**Progress format per level**:
```
  [enum] Level 3/9: 156 formulas (cumulative: 178), 0.2s elapsed, 890 formulas/sec
  [enum] Level 4/9: 624 formulas (cumulative: 802), 0.5s elapsed, 1604 formulas/sec
  ...
  [enum] Level 9/9: 485201 formulas (cumulative: 536419), 142.3s elapsed, 3770 formulas/sec
```

### Phase 2: Progress in `generateValidBatch`

Add progress reporting to the existing IO loops:

1. Axiom seeding loop: report every `max(1, seedCount / 10)` iterations
2. Fixpoint closure: report after each round

**Progress format**:
```
  [valid] Seeding: 500/5000 axiom instances, pool: 487 unique
  [valid] Seeding: 1000/5000 axiom instances, pool: 961 unique
  ...
  [valid] Closure round 1: pool 5234 -> 6891 (+1657, 31% growth)
  [valid] Closure round 2: pool 6891 -> 7102 (+211, 3% growth)
  [valid] Closure round 3: pool 7102 -> 7115 (+13, 0% growth) -- converged
```

### Phase 3: Enhanced Labeling Progress

Improve the existing every-1000 progress in `main` (DatasetExport.lean):

1. Add formulas/second rate
2. Add ETA calculation
3. Add timeout count to progress line
4. Optionally reduce interval to every 500 for better UX on smaller runs

**Enhanced format**:
```
  [label] 1000/50000 labeled (2%), 45% valid, 1% timeout, 312 formulas/sec, ETA: 2m 37s
  [label] 2000/50000 labeled (4%), 43% valid, 2% timeout, 298 formulas/sec, ETA: 2m 41s
```

### Phase 4: Shell Script Minimal Updates

No structural changes needed. Consider adding:
- A note in the help text about progress output
- Optional `--quiet` flag passed through to the Lean executable (future enhancement)

## Key Design Decisions

### stdout vs stderr

Use `IO.println` (stdout) for consistency with existing code. All current output including the existing progress line at DatasetExport.lean:560 uses `IO.println`. Switching to `IO.eprintln` would create inconsistency. The shell script does not redirect stdout.

### Progress Interval

- **Enumeration**: Per complexity level (natural boundary, 1-11 levels max)
- **Axiom seeding**: Every 10% of `seedCount`
- **Closure**: Per round (max 10 rounds)
- **Labeling**: Every 500 formulas (down from current 1000, for better responsiveness on smaller runs)

### Timing

Use `IO.monoMsNow` (already used in the labeling loop) for elapsed time. Store start time at the beginning of `generateFormulas` and pass it through or capture it in a closure.

### ETA Calculation

```
eta_seconds = (elapsed_seconds / formulas_done) * formulas_remaining
```

Format as `Xm Ys` for readability. Show "calculating..." for the first progress line when rate is not yet stable.

### Pure Function Preservation

The pure enumeration functions (`enumExactHelper`, `enumExactBudget`, `enumerateExhaustive`, `enumerateStratified`, `enumHelper`) should remain pure. The IO wrapper iterates complexity levels and calls the pure `enumExactBudget` per level. This preserves testability and composability of the pure core.

## Files to Modify

| File | Changes |
|------|---------|
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | Add `enumerateWithProgress` IO function; modify `generateFormulas` to use it; add progress to `generateValidBatch` |
| `Theories/Bimodal/Automation/DatasetExport.lean` | Enhance labeling progress in `main` with rate, ETA, and adjusted interval |
| `scripts/run_dataset_generation.sh` | Minimal: update help text only |

## Complexity Estimate

- **Phase 1** (per-level progress): Medium. Requires new IO function replicating the fold logic of `enumerateExhaustive`/`enumerateStratified` but with IO interleaving. The pure core functions are reused unchanged.
- **Phase 2** (generateValidBatch progress): Easy. Insert `IO.println` calls into existing IO loops.
- **Phase 3** (enhanced labeling progress): Easy. Modify existing progress line, add rate/ETA calculation.
- **Phase 4** (shell script): Trivial. Documentation update only.

Total estimated effort: 3 phases of implementation, approximately 100-150 lines of new/modified Lean code.

## Risks and Mitigations

1. **Performance overhead of progress reporting**: Negligible. `IO.println` is fast relative to the computation per complexity level. Even at the labeling interval of 500 formulas, the overhead is < 0.01%.

2. **`enumerateWithProgress` diverging from pure versions**: Mitigate by having the IO function call the same `enumExactBudget` per level, just with progress between calls. The computation logic is not duplicated.

3. **ETA inaccuracy**: Formula generation is not uniform across complexity levels (higher levels take much longer). ETA based on overall rate will be inaccurate early on. Mitigate by showing "calculating..." until at least 2 levels are complete, and by showing rate alongside ETA so users can judge.

## Conclusion

The main gap is in formula enumeration (`generateFormulas`), which is the longest phase and currently silent. The fix is straightforward: wrap the per-complexity-level iteration in IO code and emit progress between levels. The valid-seed generation and labeling phases already have natural IO boundaries where progress can be inserted with minimal refactoring.
