# Phase 1 Handoff: Add Wall-Clock Timeout to labelFormula

**Task**: 266 - Scale dataset generation to c7+ to find next bottleneck
**Session**: sess_1748895300_d6f0a4
**Phase**: 1 of 4
**Status**: COMPLETED

## What Was Done

Added a preemptive wall-clock timeout to `labelFormula` in `DatasetGenerator.lean`:

1. **`wallclockTimeoutMs` parameter** (default 5000ms) added to `labelFormula` and `labelBatch`
2. **`--wallclock-timeout` CLI flag** added to `DatasetExport.lean`
3. **Preemptive timeout mechanism**: Uses `Task.spawn` on a dedicated thread + 1ms-poll loop
   - Spawns `decideAutoAdaptive` on a dedicated thread
   - Polls `IO.hasFinished` with 1ms sleep intervals
   - If deadline exceeded, returns immediately with `decisionMethod := "wallclock_timeout"`
   - Background task continues running but doesn't block pipeline

## Key Decision: Post-hoc vs Preemptive Timeout

The plan offered three options. Initial attempt used post-hoc check (measure elapsed after completion). This does NOT prevent stalls -- the computation still blocks for 14+ minutes on hard formulas. Switched to `Task.spawn` + 1ms-poll approach which truly prevents stalls.

Throughput: ~930 formulas/sec (vs ~54,000 synchronous). The 1ms overhead per formula is acceptable for c8 (~4.5 min estimated).

## Immediate Next Action

Phase 2: c8 generation is already running. Wait for completion, record metrics, verify record count.

## Files Modified

- `Theories/Bimodal/Automation/DatasetGenerator.lean` - `labelFormula` with timeout, `labelBatch` updated
- `Theories/Bimodal/Automation/DatasetExport.lean` - CLI flag, parameter threading
