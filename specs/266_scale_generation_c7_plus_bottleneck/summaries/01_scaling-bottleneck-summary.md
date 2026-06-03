# Implementation Summary: Task #266 - Scale Dataset Generation c7+ Bottleneck

- **Task**: 266 - Scale dataset generation to c7+ to find next bottleneck
- **Session**: sess_1748895300_d6f0a4
- **Completed**: 2026-06-02
- **Phases**: 4/4 completed

## What Was Done

Added a preemptive per-formula wall-clock timeout to the dataset generator pipeline, regenerated the complete c8 dataset, generated a c9 sample, and compiled scaling curve data from c5 through c9.

### Phase 1: Wall-Clock Timeout Implementation

Modified `labelFormula` in `DatasetGenerator.lean` to spawn `decideAutoAdaptive` on a dedicated thread via `Task.spawn`, polling `IO.hasFinished` with 1ms sleep intervals. When the deadline (default 5000ms) is exceeded, the function returns immediately with `decisionMethod := "wallclock_timeout"` while the background computation continues running.

Added `--wallclock-timeout N` CLI flag to `DatasetExport.lean` and threaded the parameter through `labelBatch`.

**Throughput impact**: ~600 formulas/sec with timeout enabled vs ~54,000 without (due to per-formula thread spawn + 1ms poll overhead). Acceptable for dataset generation.

### Phase 2: Complete C8 Dataset

Generated 252,900 exhaustive c8 formulas with 5-second wall-clock timeout. Previous attempt stalled at formula #147,865 (`U(p,bot) -> U(p,box(bot))`) for 14+ minutes. With the timeout, this formula and 486 similar ones were capped at 5 seconds each.

### Phase 3: C9 Sample

Generated 50,000 formula c9 sample (first 50K of ~1.2M exhaustive formulas) in 88 seconds. The sample reached average complexity 6, so the slow temporal-modal patterns at higher complexity levels were not exercised.

### Phase 4: Scaling Curve

## Scaling Curve (c5-c9)

| Level | Unique Formulas | Timeouts | Timeout Rate | Wallclock Timeouts | Valid | Valid Rate | Mode |
|-------|-----------------|----------|--------------|--------------------|-------|------------|------|
| c5    | 1,512           | 39       | 2.6%         | 0                  | 99    | 6.5%       | exhaustive |
| c6    | 7,412           | 224      | 3.0%         | 0                  | 637   | 8.6%       | exhaustive |
| c7    | 49,865          | 2,410    | 4.8%         | 0                  | 4,198 | 8.4%       | exhaustive |
| c8    | 252,900         | 19,721   | 7.8%         | 487                | 22,400| 8.9%       | exhaustive |
| c9    | 50,000 (sample) | 2,408    | 4.8%         | 0                  | 4,335 | 8.7%       | first-50K  |

### Formula Count Growth Rate

| Level Pair | Growth Factor |
|------------|---------------|
| c6/c5      | 4.9x          |
| c7/c6      | 6.7x          |
| c8/c7      | 5.1x          |

**Projected c9 exhaustive**: ~1.2M formulas (5x c8). **Projected c10**: ~6M formulas (5x c9).

### C8 Decision Method Distribution

| Method | Count | Percentage |
|--------|-------|------------|
| adaptive_500 | 218,552 | 86.4% |
| adaptive_timeout | 19,234 | 7.6% |
| fast_path_axiom | 8,065 | 3.2% |
| structural_prefilter | 6,562 | 2.6% |
| wallclock_timeout | 487 | 0.2% |

### Wall-Clock Timeout Pattern Analysis

All 487 wallclock-timeout formulas at c8 share the **temporal-modal feedback loop** pattern:
- `U(X, Y) -> U(Y, box(Z))` -- Until with box in the consequent Until's second argument
- `S(X, Y) -> S(Y, box(Z))` -- Since with box in the consequent Since's second argument

These create exponentially branching tableaux where each fuel step expands into multiple sub-branches. The 5-second timeout prevents these from stalling the pipeline while correctly labeling them as timeouts.

## Next Bottleneck Identified

The **next bottleneck beyond c8** is **combinatorial formula count**, not individual formula cost:

1. **C9 exhaustive would be ~1.2M formulas**: At ~600 formulas/sec throughput (with timeout enabled), exhaustive c9 generation would take ~33 minutes for fast formulas alone. Adding the estimated ~2,000 wallclock timeouts at 5s each adds ~2.8 hours. Total estimated: ~3+ hours.

2. **C10 exhaustive would be ~6M formulas**: Completely impractical even with timeouts.

3. **Throughput overhead**: The 1ms-poll per formula adds ~58x overhead vs synchronous execution. For future optimization, consider:
   - Only spawning tasks for formulas with temporal-modal structural signatures
   - Reducing fuel for known-slow patterns instead of using wall-clock timeout
   - Using a shared timer/deadline mechanism instead of per-formula polling

## Files Modified

- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- `labelFormula` with preemptive wall-clock timeout via `Task.spawn` + 1ms-poll; `labelBatch` updated with timeout parameter
- `Theories/Bimodal/Automation/DatasetExport.lean` -- `--wallclock-timeout` CLI flag, parameter threading

## Files Generated

- `data/bmlogic-c8-clean.jsonl` -- 252,900 records (complete c8 exhaustive)
- `data/bmlogic-c8-clean_metadata.json` -- C8 metadata
- `data/bmlogic-c9-sample.jsonl` -- 50,000 records (c9 first-50K sample)
- `data/bmlogic-c9-sample_metadata.json` -- C9 sample metadata

## Plan Deviations

- **Phase 1, Task 1.2**: Used Task.spawn + 1ms-poll preemptive timeout instead of IO.asTask spawn + timeout race (IO.asTask timer approach created too many sleeping threads)
- **Phase 1, Task 1.3**: Skipped -- post-hoc approach was insufficient; preemptive timeout used instead
- **Phase 1, Task 1.4**: Chose option (d): Task.spawn + poll rather than any of the three planned options
- **Phase 2, Task 2.2**: Required resume via checkpoint after process was killed by execution timeout
- **Phase 3, Task 3.1**: Used exhaustive mode with --max-formulas 50000 instead of stratified with quotas
- **Phase 3, Task 3.5**: Skipped -- 50K sample sufficient for scaling data
