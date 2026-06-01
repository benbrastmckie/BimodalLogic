# Implementation Plan: Task #253

- **Task**: 253 - Add progress reporting to dataset generation pipeline
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/253_dataset_generation_progress_reporting/reports/01_progress-reporting-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Add progress reporting to the dataset generation pipeline so that long-running formula generation, valid-seed batch closure, and labeling phases produce periodic human-readable progress output. The primary gap is in `generateFormulas` (FormulaEnumerator.lean), which calls pure enumeration functions that iterate complexity levels 1-N with no IO output, potentially running for hours at high complexity. The fix introduces an IO wrapper that iterates complexity levels with progress between each call to the pure `enumExactBudget`, adds per-round and per-seeding-interval progress to the existing IO function `generateValidBatch`, and enhances the labeling loop in `DatasetExport.lean` with rate and ETA calculations.

### Research Integration

The research report (01_progress-reporting-research.md) identifies:
- `enumerateExhaustive` and `enumerateStratified` are pure functions; progress requires an IO wrapper (Option B recommended: iterate levels in IO, call pure per-level functions between progress lines).
- `generateValidBatch` is already IO with two loop structures (axiom seeding, fixpoint closure) that have natural progress boundaries.
- The labeling loop already reports every 1000 formulas but lacks rate and ETA.
- `IO.monoMsNow` is already used in the labeling loop for elapsed time.
- Use `IO.println` for consistency with existing output (all current output uses stdout).
- Pure core functions (`enumExactBudget`, `enumExactHelper`, etc.) remain unchanged.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items directly addressed by this task. This is a developer-experience improvement for the dataset generation pipeline.

## Goals & Non-Goals

**Goals**:
- Emit per-complexity-level progress during formula enumeration (level N/M, count, elapsed, rate)
- Emit periodic progress during axiom seeding in generateValidBatch (every 10% of seedCount)
- Emit per-round progress during fixpoint Nec/MP closure (round number, pool size, growth)
- Enhance labeling progress with formulas/second rate and ETA
- Preserve all pure function signatures unchanged
- Zero performance regression (progress IO overhead is negligible relative to computation)

**Non-Goals**:
- Switching from stdout to stderr (would create inconsistency with existing code)
- Adding a --quiet flag (deferred to future enhancement)
- Changing the labeling interval from 1000 to 500 (research suggested this but it is optional; keep 1000 for backward compatibility)
- Adding progress bars or ANSI formatting

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `enumerateWithProgress` IO wrapper diverges from pure version semantics | M | L | Call the same `enumExactBudget` per level; the wrapper only adds IO between levels, not different computation |
| ETA inaccuracy at early levels (higher levels take exponentially longer) | L | H | Show "calculating..." until 2+ levels complete; always show rate alongside ETA |
| Memoization cache threading breaks when converting fold to IO loop | M | L | Replicate the exact fold accumulator pattern: thread `(EnumCache, List Formula)` through a `for` loop |
| Build errors from signature changes propagating to callers | M | L | Only `generateFormulas` calls the new IO wrapper; no other callers need changes |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Per-complexity-level progress in formula enumeration [COMPLETED]

**Goal**: Replace silent pure enumeration calls in `generateFormulas` with an IO wrapper that emits progress after each complexity level.

**Tasks**:
- [x] Add `enumerateWithProgress` IO function in FormulaEnumerator.lean that:
  - Takes `EnumParams` and iterates complexity levels 1 to `maxComplexity` in an IO loop
  - Calls `enumExactBudget` (pure) per level with shared `EnumCache`
  - Applies `passesFilter` per level
  - Emits `IO.println` progress per level: `[enum] Level {i}/{max}: {count} formulas (cumulative: {total}), {elapsed}s elapsed, {rate} formulas/sec`
  - Caps at `maxFormulas` (same as `enumerateExhaustive`)
- [x] Add `enumerateStratifiedWithProgress` IO function (or extend `enumerateWithProgress` with quota support) that:
  - Mirrors `enumerateStratified` logic but with per-level IO progress
  - Applies per-level quotas from `stratifiedQuotas` with deterministic sampling
  - Emits the same progress format
- [x] Modify `generateFormulas` to call the IO progress wrappers instead of the pure functions:
  - `.exhaustive` branch: call `enumerateWithProgress` instead of `pure (enumerateExhaustive params)`
  - `.stratified` branch: call `enumerateStratifiedWithProgress` instead of `pure (enumerateStratified params)`
  - `.hybrid` branch: call `enumerateWithProgress` for the exhaustive portion
  - `.random` branch: no change needed (already IO via `sampleRandom`)
- [x] Add start/end timing in `generateFormulas` using `IO.monoMsNow`:
  - Print `[gen] Starting formula enumeration ({mode} mode, max complexity {N})...`
  - After enumeration: `[gen] Enumeration complete: {count} formulas in {elapsed}s`
  - Before valid batch: `[gen] Starting valid-seed generation ({seedCount} seeds)...`
  - After valid batch: `[gen] Valid-seed generation complete: {count} valid formulas in {elapsed}s`
  - Final: `[gen] Total: {count} unique formulas after deduplication`
- [x] Verify `lake build Bimodal.Automation.FormulaEnumerator` passes

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - Add `enumerateWithProgress`, `enumerateStratifiedWithProgress`; modify `generateFormulas`

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` passes with zero errors
- Run smoke test: `lake exe dataset_generator -- --max-complexity 3 --max-formulas 20 --output /tmp/smoke.jsonl` and verify per-level progress lines appear

---

### Phase 2: Progress in generateValidBatch [COMPLETED]

**Goal**: Add progress reporting to the axiom seeding loop and fixpoint closure loop in `generateValidBatch`.

**Tasks**:
- [x] Add seeding progress in the `for _ in List.range seedCount` loop (line ~1004):
  - Track iteration count with a mutable counter
  - Every `max(1, seedCount / 10)` iterations, emit: `[valid] Seeding: {count}/{seedCount} axiom instances, pool: {poolSize} unique`
- [x] Add closure progress after each round in the `while` loop (line ~1044):
  - After each round completes, emit: `[valid] Closure round {round}: pool {prevSize} -> {poolSize} (+{growth}, {growthRate}% growth)`
  - When breaking early due to low growth: `[valid] Closure converged at round {round} ({growthRate}% growth < 1%)`
- [x] Add timing to generateValidBatch:
  - Capture start time at function entry with `IO.monoMsNow`
  - Print elapsed time with seeding and closure progress lines
- [x] Verify `lake build Bimodal.Automation.FormulaEnumerator` passes

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - Modify `generateValidBatch` to add progress lines

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` passes
- Smoke test shows seeding and closure progress lines

---

### Phase 3: Enhanced labeling progress with rate and ETA [NOT STARTED]

**Goal**: Improve the existing every-1000-formulas progress in DatasetExport.lean with formulas/second rate, ETA, and timeout count.

**Tasks**:
- [ ] Enhance the progress line at DatasetExport.lean line ~556-560:
  - Calculate `rate := count * 1000 / max 1 (elapsed - startTime)` (formulas/sec, using ms timestamps)
  - Calculate `remaining := formulas'.length - count`
  - Calculate `etaMs := if rate > 0 then remaining * 1000 / rate else 0`
  - Format ETA as `{min}m {sec}s` or `calculating...` if count < 100
  - Add timeout count and percentage to the progress line
  - New format: `[label] {count}/{total} labeled ({pct}%), {validPct}% valid, {timeoutPct}% timeout, {rate} formulas/sec, ETA: {eta}`
- [ ] Add progress header before the labeling loop:
  - `[label] Starting labeling of {formulas'.length} formulas...`
- [ ] Add completion line after the loop:
  - `[label] Labeling complete: {count} formulas in {elapsed}s ({rate} formulas/sec)`
- [ ] Update the shell script help text to mention progress output
- [ ] Verify `lake build Bimodal.Automation.DatasetExport` passes
- [ ] Run full smoke test to verify end-to-end progress output

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` - Enhance labeling progress line, add header/footer
- `scripts/run_dataset_generation.sh` - Update help text to note progress output

**Verification**:
- `lake build` passes (full project build as final verification)
- Smoke test (`scripts/run_dataset_generation.sh smoke`) shows all three progress tiers:
  1. Per-level enumeration progress
  2. Seeding and closure progress
  3. Enhanced labeling progress with rate and ETA

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] Smoke test (`--max-complexity 3 --max-formulas 20`) produces visible progress lines for all three phases
- [ ] C5 run (`scripts/run_dataset_generation.sh c5`) shows per-level enumeration progress for levels 1-5
- [ ] Progress output does not interfere with JSONL output (JSONL goes to file via handle, progress goes to stdout)
- [ ] Output format is consistent: all progress lines use `[tag]` prefix for grep-ability
- [ ] No performance regression: smoke test completes in similar time as before

## Artifacts & Outputs

- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - Modified with IO progress wrappers and generateValidBatch progress
- `Theories/Bimodal/Automation/DatasetExport.lean` - Modified with enhanced labeling progress
- `scripts/run_dataset_generation.sh` - Updated help text

## Rollback/Contingency

All changes are additive (new IO functions wrapping existing pure functions, new print statements in existing IO functions). The pure core functions are not modified. To revert: restore the three files from git. No data format changes, no schema changes, no API changes.
