# Phase 3 Handoff: Build Verification — Task 298

## Immediate next action

**Poll the detached driver**, do not restart work:

```bash
cat specs/298_fix_c7_labeling_bug_and_regenerate_dataset/logs/driver.log
pgrep -af run-c7-regen.sh   # still alive?
```

The driver (`run-c7-regen.sh`, launched via `setsid nohup`, survives session teardown) handles the
remaining c4 spot-check and c7 regeneration end to end. If it is still alive, **wait** — the
bottleneck is a one-time native compile, not a defect. If it died, re-run it; it is idempotent and
lake caches compiled artifacts:

```bash
setsid nohup bash specs/298_fix_c7_labeling_bug_and_regenerate_dataset/run-c7-regen.sh &
```

## Current state

- **Phases 1-2**: committed in a prior session (`b6aa8e5b0`, `9b2bd79e8`). Verified correct.
- **Phase 3**: `lake build` fully green — "Build completed successfully (1759 jobs)", zero errors,
  all in-file test batteries pass. c4 spot-check deferred to the driver.
- **Phase 4**: delegated to the driver.
- No `Theories/` source edits were needed this session.

## Key findings

1. **Task 343 superseded part of the plan.** It landed on top of task 298's phases 1-2 and replaced
   the plan's `IO.cancel`-only design with a cooperative `abortRef` observed at every tableau step.
   This is strictly stronger and was verified rather than rebuilt. It matters: `IO.cancel` alone only
   *signals*; a non-observing pure computation would ignore it and run on as a zombie thread to
   exhaustion — exactly the original task-298 failure mode. Do not "restore" the plan's design.

2. **The blocker is environmental, not a code defect.** `dataset_generator` has no cached binary in
   `.lake/build/bin/` (its 6 siblings do), so it needs a full native compile: 410 Lean-generated `.c`
   files, only 63 `.o.export` present. `Formula.c` and `FormulaEnumerator.c` each burned 45+ min at
   2-7GB clang RSS. `/proc/<pid>/stat` sampling confirmed clang genuinely working (99% CPU, 498
   ticks/5s), not wedged. The task-298 modules `Saturation.c` and `DatasetGenerator.c` both compiled
   fine at 09:57.

3. **Monitoring pitfall**: an early RSS measurement of 773MB was misleading — it measured the `lake`
   wrapper, not the generator. The driver invokes `./.lake/build/bin/dataset_generator` directly so
   the watchdog observes the real process.

## Deviations recorded

- Phase 4 memory precondition lowered 20GB → 12GB. The 20GB bar is unmeetable on this host: ~17.5GB
  is held by legitimate long-lived Lean LSP/editor processes that must not be killed.
- Phase 4 invokes the binary directly rather than via `lake exe` (see pitfall above).
- Phase 3 c4 spot-check + RSS monitoring deferred to the driver.

All are annotated inline on the plan's checklist items.

## Success criterion (unchanged)

`data/bmlogic-c7.jsonl` record count must significantly exceed 13,749 with no stall at formula
13,750. The driver hard-fails and restores the backup if this is not met, and gates c7 behind a
passing 806-record c4 spot-check.
