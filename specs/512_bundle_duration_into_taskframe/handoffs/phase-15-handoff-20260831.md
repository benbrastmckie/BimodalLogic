# Phase 15 handoff — BiLasso

**Status**: [COMPLETED]. Build 0, test build 0, invariants ALL CHECKS PASSED, zero sorry.

## Immediate next action
Phase 16 — Independence (`ClockFrame`, `LoopingDuration`, `CoNotPriorU`).

## Carry-forward
- The `@LT.lt ℤ _` idiom is permanent, not transitional: `omega` does not see through the
  `TemporalOrder` carrier coercion. Any later phase tempted to "clean up" those restatements
  should not.
- Phase 16 measured scope: `ClockFrame` 8, `LoopingDuration` 9, `CoNotPriorU` 2,
  `Independence.lean` 1 = 20 (plan said 22). `clockFrame` is the single `ℚ` concrete frame;
  spell its order `TemporalOrder.of ℚ`, per Phase 13's placement finding — do NOT declare a
  local `ratOrder`.
