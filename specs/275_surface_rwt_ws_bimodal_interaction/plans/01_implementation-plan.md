# Implementation Plan: Surface R/WU/T/WS Bimodal Interaction

- **Task**: 275 - surface_rwt_ws_bimodal_interaction
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: Task 274 (F/P/G/H complexity reduction — stale overheads fixed here)
- **Research Inputs**: `specs/275_surface_rwt_ws_bimodal_interaction/reports/01_research.md`
- **Artifacts**: `specs/275_surface_rwt_ws_bimodal_interaction/plans/01_implementation-plan.md` (this file)
- **Standards**: `.opencode/context/formats/plan-format.md`; `status-markers.md`; `artifact-management.md`; `tasks.md`
- **Type**: lean4
- **Lean Intent**: true

## Overview

Task 275 surfaces four existing derived temporal operators (Release R, Weak Until WU, Trigger T, Weak Since WS) into the automation layer. These operators are defined in `Formula.lean` but invisible to `hasBimodalInteraction`, `Formula.complexity`, and the formula enumerator. The work is purely automation-layer plumbing: adding pattern-match cases, fixing stale overhead constants from task 274, and regenerating the c5 dataset. No new axioms or proofs are required.

### Research Integration

Integrated report: `specs/275_surface_rwt_ws_bimodal_interaction/reports/01_research.md`

Key findings applied:
- `hasDerivedTemporal` / `hasBimodalInteraction` live in `FormulaEnumerator.lean` (lines 1694–1716), not `DatasetGenerator.lean`
- `Formula.complexity` (lines 170–184) needs 4 pattern-match cases inserted **before** generic `imp`/`untl`/`snce` cases
- WU and WS patterns overlap with G/H — must place WU/WS patterns **before** G/H in `complexity`
- Stale pre-task-274 overheads remain in `sampleOne` (F/P: 4, G/H: 8) and `randomSubFormula` (F/P: 4, G/H: 8); both must be reduced to 1
- `enumExactHelper`, `sampleOne`, `sampleOneRandom`, and `randomSubFormula` all need R/WU/T/WS generation branches
- Optional: extend `OperatorDistribution` / `countTopOperator` for visibility

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Extend `Formula.complexity` in `Formula.lean` with pattern-matched cases for R, WU, T, and WS, reducing their complexity from 8–9 to 3 (matching binary `untl`/`snce` cost)
- Extend `hasDerivedTemporal` / `hasBimodalInteraction` in `FormulaEnumerator.lean` to recognize R, WU, T, and WS structural patterns
- Integrate R/WU/T/WS into all enumerator sampling paths: `enumExactHelper`, `sampleOne`, `sampleOneRandom`, and `randomSubFormula`
- Fix stale pre-task-274 overhead constants in `sampleOne` and `randomSubFormula`
- Add complexity property tests for R/WU/T/WS in `FormulaPropertyTest.lean`
- Regenerate the c5 dataset and verify approximately 3x increase in bimodal formula count

**Non-Goals**:
- No changes to proof system, semantics, or axioms
- No modification of operator definitions in `Formula.lean` (only complexity pattern-matching)
- No changes to `DatasetGenerator.lean` logic (only `FormulaEnumerator.lean`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| WU/WS pattern-match shadowed by G/H generic patterns | High (wrong complexity values) | Medium | Place WU/WS cases **before** G/H cases in `complexity`; verify with `#eval` smoke tests |
| Stale overhead constants cause enumeration to skip valid sizes | Medium | Medium | Update `sampleOne` and `randomSubFormula` overheads to 1; add unit tests |
| Dataset regeneration takes unexpectedly long | Low | Low | Run with `--max-complexity 5` only; benchmark against prior generation time |
| Build failures from overlapping pattern matches | Medium | Low | Build after each file change; use `lake build` to catch overlap early |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Formula.complexity Pattern-Matching [COMPLETED]

**Goal**: Add 4 pattern-match cases to `Formula.complexity` so R, WU, T, and WS are treated as first-class binary temporal operators with cost `1 + left + right`.

**Tasks**:
- [ ] Insert 4 pattern-match cases in `Theories/Bimodal/Syntax/Formula.lean` before generic `imp φ ψ` and before generic `untl φ ψ` / `snce φ ψ` cases:
  - `imp (untl (imp φ bot) (imp ψ bot)) bot` → Release (R φ ψ)
  - `imp (snce (imp φ bot) (imp ψ bot)) bot` → Trigger (T φ ψ)
  - `imp (imp (untl φ ψ) bot) (imp (untl (imp ψ bot) (imp bot bot)) bot)` → Weak Until (WU φ ψ)
  - `imp (imp (snce φ ψ) bot) (imp (snce (imp ψ bot) (imp bot bot)) bot)` → Weak Since (WS φ ψ)
- [ ] Ensure WU/WS cases appear **before** G/H cases to prevent shadowing
- [ ] Add `#eval` smoke tests verifying complexity on atomic operands equals 3 for each operator
- [ ] Run `lake build` to verify no pattern-match overlap errors

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` — add 4 complexity cases + smoke tests

**Verification**:
- `lake build` succeeds with no pattern-match warnings
- `#eval (Formula.release p q).complexity` returns `3` for atomic `p`, `q`
- `#eval (Formula.weak_until p q).complexity` returns `3` for atomic `p`, `q`

---

### Phase 2: hasDerivedTemporal / hasBimodalInteraction Extension [COMPLETED]

**Goal**: Extend `hasDerivedTemporal` to recognize R, WU, T, and WS structural patterns so `hasBimodalInteraction` includes them.

**Tasks**:
- [ ] Add 4 pattern branches to `hasDerivedTemporal` in `Theories/Bimodal/Automation/FormulaEnumerator.lean`:
  - Release: `imp (untl (imp φ bot) (imp ψ bot)) bot`
  - Trigger: `imp (snce (imp φ bot) (imp ψ bot)) bot`
  - Weak Until: `imp (imp (untl φ ψ) bot) (imp (untl (imp ψ bot) (imp bot bot)) bot)`
  - Weak Since: `imp (imp (snce φ ψ) bot) (imp (snce (imp ψ bot) (imp bot bot)) bot)`
- [ ] Run `lake build` to verify `FormulaEnumerator.lean` compiles

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` — extend `hasDerivedTemporal` (lines 1694–1716)

**Verification**:
- `lake build` succeeds
- Quick `#eval` check: `hasBimodalInteraction (box (release p q))` returns `true`

---

### Phase 3: Enumerator Sampling Integration [COMPLETED]

**Goal**: Integrate R/WU/T/WS into all formula generation paths and fix stale overhead constants.

**Tasks**:
- [ ] `enumExactHelper` (binary section, lines 236–245): add R, WU, T, WS generation alongside `untl`/`snce` using `tLefts`/`tRights` cross-product
- [ ] `sampleOne` (lines 399–414):
  - Fix F/P overhead from `sizeBudget - 4` to `sizeBudget - 1`
  - Fix G/H overhead from `sizeBudget - 8` to `sizeBudget - 1`
  - Add R/WU/T/WS branch(es) with same split-budget logic as `untl`/`snce`
- [ ] `sampleOneRandom` (lines 820–846): add R/WU/T/WS branch(es), reusing existing F/P/G/H overhead pattern
- [ ] `randomSubFormula` (lines 985–1000):
  - Fix F/P overhead from `maxSize - 4` to `maxSize - 1`
  - Fix G/H overhead from `maxSize - 8` to `maxSize - 1`
  - Add R/WU/T/WS as new choice branches with split-budget logic
- [ ] Optional: extend `OperatorDistribution` and `countTopOperator` with `releaseCount`, `weakUntilCount`, `triggerCount`, `weakSinceCount`
- [ ] Run `lake build` after each sub-file change

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` — `enumExactHelper`, `sampleOne`, `sampleOneRandom`, `randomSubFormula`, optional `OperatorDistribution`

**Verification**:
- `lake build` succeeds with no unused-variable warnings
- All sampling functions compile without pattern-match issues

---

### Phase 4: Testing & Dataset Validation [COMPLETED]

**Goal**: Verify correctness with property tests and confirm the ~3x bimodal formula count increase in the c5 dataset.

**Tasks**:
- [ ] Add 4 complexity property tests in `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean`:
  - `(Formula.release p q).complexity = 1 + p.complexity + q.complexity`
  - `(Formula.weak_until p q).complexity = 1 + p.complexity + q.complexity`
  - `(Formula.trigger p q).complexity = 1 + p.complexity + q.complexity`
  - `(Formula.weak_since p q).complexity = 1 + p.complexity + q.complexity`
- [ ] Run `lake test` (or `lake exec` for the test suite) to verify all tests pass
- [ ] Regenerate c5 dataset: `lake exe dataset_generator -- --max-complexity 5`
- [ ] Compare bimodal formula count against pre-change baseline; confirm ~3x increase
- [ ] If count increase is not observed, debug `hasBimodalInteraction` and enumerator paths

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean` — add 4 test cases

**Verification**:
- All tests in `FormulaPropertyTest.lean` pass
- Bimodal formula count in generated c5 dataset is approximately 3x the previous count

## Testing & Validation

- [ ] `lake build` succeeds across all modified files
- [ ] Complexity property tests for R, WU, T, WS pass
- [ ] `#eval` smoke tests on `Formula.lean` return expected values (complexity = 3 for atomic operands)
- [ ] `#eval` smoke tests on `FormulaEnumerator.lean` confirm `hasBimodalInteraction (box (release p q)) = true`
- [ ] C5 dataset regeneration completes without errors
- [ ] Bimodal formula count in c5 dataset increases by approximately 3x

## Artifacts & Outputs

- `specs/275_surface_rwt_ws_bimodal_interaction/plans/01_implementation-plan.md` — this plan
- Modified `Theories/Bimodal/Syntax/Formula.lean` — 4 new complexity cases + smoke tests
- Modified `Theories/Bimodal/Automation/FormulaEnumerator.lean` — `hasDerivedTemporal`, sampling paths, overhead fixes
- Modified `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean` — 4 complexity property tests
- Generated c5 dataset with elevated bimodal formula count

## Rollback/Contingency

- All changes are additive (new pattern-match branches) or constant adjustments (overhead fixes). Reverting requires:
  1. Removing the 4 pattern-match cases from `Formula.complexity`
  2. Removing the 4 pattern branches from `hasDerivedTemporal`
  3. Reverting overhead constants in `sampleOne` and `randomSubFormula` to 4/8
  4. Removing R/WU/T/WS branches from all sampling functions
- No proof files are touched, so rollback is low-risk and will not affect the proof system
- If dataset count does not increase, inspect `hasDerivedTemporal` logic and confirm pattern matching captures the exact structural forms
