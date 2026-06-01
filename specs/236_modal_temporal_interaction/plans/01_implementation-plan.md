# Implementation Plan: Cross-Modal-Temporal Tableau Rules

- **Task**: 236 - Modal-temporal interaction tableau rules
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Tasks 233 (S5 modal rules), 234 (G/H/F/P temporal rules) -- both completed
- **Research Inputs**: specs/236_modal_temporal_interaction/reports/01_modal-temporal-interaction.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Implement cross-modal-temporal interaction rules for the TM bimodal logic tableau in `Tableau.lean`. The current tableau handles modal and temporal rules independently: world-creation rules (boxNeg, diamondPos) propagate only modal universals, and time-creation rules (allFutureNeg, someFuturePos, etc.) propagate only temporal universals. The `modal_future` axiom (`box phi -> box(G phi)`) and the derived `temp_future` principle (`box phi -> G(box phi)`) require cross-propagation: (1) deriving temporal consequences from box formulas, (2) inheriting temporal structure at new worlds, and (3) persisting box formulas across new times.

### Research Integration

The research report (01_modal-temporal-interaction.md) identified three specific gaps and recommended Approach B (augment existing rules plus one new persistent rule):
- **Gap 1**: No `boxTemporal` rule to derive `T(G phi)` and `T(H phi)` from `T(box phi)`.
- **Gap 2**: World-creation rules do not propagate temporal universal formulas to fresh worlds.
- **Gap 3**: Time-creation rules do not propagate `T(box A)` / `F(diamond A)` to fresh times.
- Research confirmed soundness via `box_to_future`, `box_to_past`, and `temp_future_derived` theorems.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add `boxTemporal` rule that derives `T(G phi)` and `T(H phi)` from `T(box phi)`
- Augment `boxNeg` and `diamondPos` to propagate temporal universal formulas to fresh worlds
- Augment time-creation rules to propagate box/diamond-neg formulas to fresh times
- Verify `lake build` passes with all changes
- Add integration tests for key modal-temporal interaction formulas

**Non-Goals**:
- Formal soundness proofs (tableau is in `Decidability/`, not `Metalogic/Soundness/`)
- Termination/blocking changes (task 237 scope)
- Frame-class-specific rules (task 238 scope)
- Performance optimization of propagation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Non-termination from boxTemporal persistence loop | H | L | boxTemporal generates T(G/H phi) which are known formula types; `isApplicable` checks for already-present formulas prevent duplicates |
| Formula explosion from cross-propagation | M | M | Existing `branch.contains` filtering prevents duplicate formulas; propagation is bounded by branch size |
| Rule ordering sensitivity | M | L | Place boxTemporal after boxPos/boxNeg but before temporal rules so derived T(G phi) is available for temporal expansion |
| Pattern-match exhaustiveness in Lean | L | M | Existing match structure in `applyRule` handles fallthrough via `| _, _, _ => (.notApplicable, timeOrd)` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Core boxTemporal Rule [COMPLETED]

**Goal**: Add a new `boxTemporal` persistent rule that derives `T(G phi)` and `T(H phi)` from `T(box phi)`, implementing the `box_to_future` and `box_to_past` consequences of the `modal_future` axiom.

**Tasks**:
- [x] Add `boxTemporal` constructor to the `TableauRule` inductive type (after `diamondNeg`, before temporal rules)
- [x] Add `isApplicable` case for `boxTemporal`: matches `(.pos, .box _)`, returns true only if at least one of `T(G phi)` or `T(H phi)` is not already on the branch at the same label *(deviation: altered -- isApplicable does not take branch parameter; filtering happens in applyRule which returns .notApplicable when both formulas already present)*
- [x] Add `applyRule` case for `boxTemporal`: given `T(box phi)` at label `(w, t)`, generate `T(G phi)` at `(w, t)` and `T(H phi)` at `(w, t)` as a persistent result, filtering out formulas already on the branch
- [x] Add `boxTemporal` to `allRules` list, positioned after `.diamondNeg` and before `.allFuturePos` so the derived temporal formulas are available for temporal expansion
- [x] Verify the file compiles with `lake build Bimodal.Metalogic.Decidability.Tableau`

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Add boxTemporal constructor, isApplicable case, applyRule case, allRules entry

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Tableau` succeeds
- The boxTemporal rule produces persistent results with T(G phi) and T(H phi)

---

### Phase 2: Temporal Inheritance at World Creation [COMPLETED]

**Goal**: Augment `boxNeg` and `diamondPos` rules so that when a fresh world `w'` is created at time `t`, temporal universal formulas at time `t` from any world are also propagated to `(w', t)`. This ensures new worlds inherit the temporal structure established by box formulas via the boxTemporal rule.

**Tasks**:
- [x] In `boxNeg` case of `applyRule`: after existing boxProps and diaProps computation, add propagation of `T(G A)` formulas at time `l.time` from any world to `(freshWorld, l.time)`
- [x] In `boxNeg` case: add propagation of `T(H A)` formulas at time `l.time` from any world to `(freshWorld, l.time)`
- [x] In `boxNeg` case: add propagation of `F(F A)` formulas at time `l.time` from any world to `(freshWorld, l.time)`
- [x] In `boxNeg` case: add propagation of `F(P A)` formulas at time `l.time` from any world to `(freshWorld, l.time)`
- [x] In `boxNeg` case: add propagation of `F(U(event, guard))` and `F(S(event, guard))` formulas at time `l.time` from any world to `(freshWorld, l.time)`
- [x] Apply the same augmentations to the `diamondPos` case
- [x] Add helper functions to `SignedFormula.lean` if needed: `allFuturePosAtTime`, `allPastPosAtTime`, `someFutureNegAtTime`, `somePastNegAtTime`, `untlNegAtTime`, `snceNegAtTime` -- each filters by time index *(also added boxPosAtWorldTime and diamondNegAtWorldTime for Phase 3; also fixed pre-existing ordering issue with blocking code that referenced TimeOrdering before its definition)*
- [x] Verify compilation with `lake build Bimodal.Metalogic.Decidability.Tableau`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` - Add time-filtered collection helper functions
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Augment boxNeg and diamondPos with temporal propagation

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Tableau` succeeds
- Fresh worlds created by boxNeg/diamondPos inherit T(G A), T(H A), F(F A), F(P A) formulas from any world at the same time

---

### Phase 3: Box Persistence at Time Creation [NOT STARTED]

**Goal**: Augment time-creation rules so that when a fresh time `t'` is created at world `w`, `T(box A)` and `F(diamond A)` formulas at `(w, t)` for `t` related to `t'` are also propagated to `(w, t')`. This implements the `temp_future_derived` principle: `box phi -> G(box phi)`.

**Tasks**:
- [ ] In `allFutureNeg` case: after existing gProps and fNegProps, add propagation of `T(box A)` formulas at `(w, l.time)` to `T(box A)` at `(w, freshTime)` -- box persists to future times
- [ ] In `allFutureNeg` case: add propagation of `F(diamond A)` formulas at `(w, l.time)` to `F(diamond A)` at `(w, freshTime)`
- [ ] Apply same augmentations to `someFuturePos` (also creates fresh future time)
- [ ] Apply same augmentations to `untlPos` (creates fresh future time, propagation goes to both branches)
- [ ] In `allPastNeg` case: add propagation of `T(box A)` at `(w, l.time)` to `T(box A)` at `(w, freshTime)` -- box also persists to past times (from `box phi -> H(box phi)`)
- [ ] In `allPastNeg` case: add propagation of `F(diamond A)` at `(w, l.time)` to `F(diamond A)` at `(w, freshTime)`
- [ ] Apply same augmentations to `somePastPos` (creates fresh past time)
- [ ] Apply same augmentations to `sncePos` (creates fresh past time, propagation goes to both branches)
- [ ] Add helper function `boxPosAtWorldTime` to `SignedFormula.lean` if needed: filter T(box A) by world and time
- [ ] Add helper function `diamondNegAtWorldTime` to `SignedFormula.lean` if needed
- [ ] Verify compilation with `lake build Bimodal.Metalogic.Decidability.Tableau`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` - Add world-time-filtered collection helpers (if needed)
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Augment all 8 time-creation rules with box/diamond persistence

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Tableau` succeeds
- T(box A) formulas persist to fresh future and past times
- F(diamond A) formulas persist to fresh future and past times

---

### Phase 4: Testing and Build Verification [NOT STARTED]

**Goal**: Add integration tests for key modal-temporal interaction formulas to `Saturation.lean` or an appropriate test file, and verify the full project builds.

**Tasks**:
- [ ] Add test: `box p -> G p` should be proved valid (T(box p) triggers boxTemporal to derive T(G p), then closure)
- [ ] Add test: `box p -> H p` should be proved valid (symmetric temporal direction)
- [ ] Add test: `box p -> always p` (P1 perpetuity: `box p -> H p /\ p /\ G p`) should be proved valid
- [ ] Add test: `box(box p) -> G(box p)` (nested modal-temporal) should be proved valid
- [ ] Add test: a satisfiable formula like `box p /\ F(neg p)` should produce a countermodel (not prove valid) -- verifies cross-propagation does not over-close
- [ ] Add test: `modal_future` axiom instance `box p -> box(G p)` should be handled correctly
- [ ] Run `lake build` to verify full project compiles with zero errors
- [ ] Verify no new `sorry` or `axiom` introduced via `grep -r "sorry\|axiom " Theories/Bimodal/Metalogic/Decidability/Tableau.lean`

**Timing**: 1 hour (reduced since Phase 2 and 3 include per-phase compilation checks)

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Add modal-temporal interaction test cases
- Possibly `Tests/BimodalTest/` - If test infrastructure lives there

**Verification**:
- All test formulas produce expected results (valid/invalid)
- `lake build` passes with zero errors
- No new `sorry` introduced
- `box p -> G p` closes without timeout

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Decidability.Tableau` passes after each phase
- [ ] `lake build` (full project) passes after Phase 4
- [ ] `box p -> G p` is proved valid by the tableau
- [ ] `box p -> H p` is proved valid by the tableau
- [ ] `box p -> always p` is proved valid by the tableau
- [ ] `box(box p) -> G(box p)` is proved valid
- [ ] Satisfiable formulas (e.g., `box p /\ F(neg p)`) still produce open branches
- [ ] No new `sorry` or `axiom` introduced
- [ ] No regression in existing tableau behavior (propositional, pure modal, pure temporal)

## Artifacts & Outputs

- `specs/236_modal_temporal_interaction/plans/01_implementation-plan.md` (this file)
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` (modified: new boxTemporal rule, augmented world/time creation)
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` (modified: new collection helper functions)
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` (modified: new integration tests)
- `specs/236_modal_temporal_interaction/summaries/01_implementation-summary.md` (created after implementation)

## Rollback/Contingency

All changes are contained within three files in `Metalogic/Decidability/`. If the cross-propagation causes non-termination or incorrect results:
1. Revert `Tableau.lean` to remove boxTemporal and augmented propagation
2. Revert `SignedFormula.lean` to remove new helper functions
3. Revert `Saturation.lean` to remove new tests
4. Use `git checkout -- Theories/Bimodal/Metalogic/Decidability/` to restore
