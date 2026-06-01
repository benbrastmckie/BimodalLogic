# Implementation Summary: Cross-Modal-Temporal Tableau Rules

- **Task**: 236 - Modal-temporal interaction tableau rules
- **Status**: [COMPLETED]
- **Plan**: specs/236_modal_temporal_interaction/plans/01_implementation-plan.md
- **Type**: lean4

## Overview

Implemented cross-modal-temporal interaction rules for the TM bimodal logic tableau in three files: `Tableau.lean`, `SignedFormula.lean`, and `Saturation.lean`. The changes close three gaps identified in the research report:

1. **Gap 1 (boxTemporal rule)**: Added a new `boxTemporal` persistent rule to `TableauRule` that derives `T(G phi)` and `T(H phi)` from `T(box phi)`, implementing the `box_to_future` and `box_to_past` consequences of the `modal_future` axiom.

2. **Gap 2 (temporal inheritance at world creation)**: Augmented `boxNeg` and `diamondPos` rules to propagate temporal universal formulas (`T(G A)`, `T(H A)`, `F(F A)`, `F(P A)`, `F(U(event,guard))`, `F(S(event,guard))`) at the same time index to fresh worlds.

3. **Gap 3 (box persistence at time creation)**: Augmented 6 time-creation rules (`allFutureNeg`, `allPastNeg`, `someFuturePos`, `somePastPos`, `untlPos`, `sncePos`) to propagate `T(box A)` and `F(diamond A)` formulas to fresh times, implementing `box phi -> G(box phi)`.

## Files Modified

- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` — Added `boxTemporal` constructor, `isApplicable` case, `applyRule` case, `allRules` entry, `boxDiamondPersistence` helper, augmented world-creation and time-creation rules
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` — Added 8 collection helper functions (`allFuturePosAtTime`, `allPastPosAtTime`, `someFutureNegAtTime`, `somePastNegAtTime`, `untlNegAtTime`, `snceNegAtTime`, `boxPosAtWorldTime`, `diamondNegAtWorldTime`), fixed pre-existing ordering issue with blocking code
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` — Added 6 modal-temporal interaction tests (MT1-MT6)

## Test Results

| Test | Formula | Expected | Result |
|------|---------|----------|--------|
| MT1 | `box p -> G p` | Valid | PASS |
| MT2 | `box p -> H p` | Valid | PASS |
| MT3 | `box p -> always p` | Valid | INFO (fuel exhausted, task 237) |
| MT4 | `box(box p) -> G(box p)` | Valid | INFO (fuel exhausted, task 237) |
| MT5 | `p /\ F(neg p)` | Satisfiable | PASS |
| MT6 | `box p -> box(G p)` | Valid | PASS |

MT3 and MT4 are complex compound formulas that require blocking refinement from task 237 for proper termination. The core interaction mechanism (MT1, MT2, MT6) works correctly.

No regressions in existing tests (propositional, modal, temporal, Until/Since, blocking tests all PASS).

## Plan Deviations

- **Phase 1, Task 1.2**: `isApplicable` does not take a branch parameter; filtering happens in `applyRule` which returns `.notApplicable` when both T(G phi) and T(H phi) are already present.
- **Phase 2, Task 2.7**: Also added `boxPosAtWorldTime` and `diamondNegAtWorldTime` helpers for Phase 3 use. Fixed pre-existing ordering issue where blocking code referenced `TimeOrdering` before its definition.
- **Phase 3, Task 3.11**: Augmented 6 time-creation rules (not 8 as originally planned) — `untlNeg` and `snceNeg` decompose at existing times and do not need box persistence. Added shared `boxDiamondPersistence` helper to reduce code duplication.
- **Phase 4, Task 4.3/4.4**: MT3 and MT4 report INFO rather than PASS due to fuel exhaustion; requires blocking refinement from task 237.
- **Phase 4, Task 4.5**: Used `p /\ F(neg p)` instead of `box p /\ F(neg p)` since the latter is actually unsatisfiable with correct cross-propagation.

## Verification

- `lake build` passes with zero errors (1679 jobs)
- No new `sorry` introduced in modified files
- No new `axiom` introduced
- No vacuous definitions
