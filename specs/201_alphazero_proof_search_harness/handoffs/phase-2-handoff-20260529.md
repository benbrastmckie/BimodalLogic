# Phase 2 Handoff: Formula Enumeration Engine

## Status
Phase 2 COMPLETED.

## What Was Done
- Extended `Theories/Bimodal/Automation/FormulaEnumerator.lean` with the plan-specified API:
  - `EnumConfig` structure with `maxModalDepth`, `maxTemporalDepth`, `maxSize`, `atomPool`
  - `enumerateUpToDepth` using `enumHelper` that tracks all three constraints simultaneously
  - `sampleFormulas` with deterministic LCG-based pseudo-random sampling (seed-reproducible)
  - `defaultAtomPool` (5 atoms: p, q, r, s, t), `smallConfig`, `mediumConfig`
  - `DiversitySummary` with operator distribution, depth histograms, per-category counts
  - `LCGState` struct for deterministic pseudo-random generation
- Fixed temporal depth tracking in legacy `enumerateAtBudget` (was not decrementing temporal budget for untl/snce children)
- Preserved all legacy API (`EnumParams`, `enumerateExhaustive`, `sampleRandom`, `DiversityReport`)

## Key Decisions
1. Kept both new (`EnumConfig`) and legacy (`EnumParams`) APIs for backward compatibility
2. `enumHelper` uses structural recursion on `sizeBudget` (no `partial` needed)
3. `sampleOne` uses explicit `fuel` parameter for termination (no `partial` needed)
4. LCG uses glibc constants (a=1103515245, c=12345, m=2^31)

## Deviations from Plan
- File already existed from task 203 -- extended rather than created from scratch
- The formula count verification items (1000+ for small, 10000+ for medium) were not tested at runtime since this requires `#eval`; marked as unchecked for Phase 6 validation

## Build Status
- `lake build Bimodal.Automation.FormulaEnumerator` passes
- `lake build` (full project) passes
- Zero sorries, zero axioms, zero vacuous definitions

## Next Action
Phase 3: Batch Decision Pipeline. Create `DatasetGenerator.lean` (already exists with some content). Implement `labelFormula`, `labelBatch`, and `walkDerivationTree` integration.
