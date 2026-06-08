# Implementation Plan: Task #288

- **Task**: 288 - Add deeper invalid-pattern recognizers to structuralPrefilter
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Task 287 (normalization, completed)
- **Research Inputs**: specs/288_deeper_invalid_pattern_recognizers/reports/01_invalid-patterns-research.md
- **Artifacts**: plans/01_invalid-patterns-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Add three invalid-pattern recognizer functions to DatasetGenerator.lean that detect structurally invalid formulas before invoking the tableau decision procedure. The recognizers -- `isTemporalContradiction`, `isObviousSatisfiable`, and `hasUnfulfillableEventuality` -- are wired into `labelFormulaImpl` as Phase 1.5 (after the existing valid prefilter, before the tableau). Each recognizer leverages the existing `isUnsatBotTemporal` as its core building block. A new `PrefilterSoundness.lean` module provides formal soundness proofs for each pattern. Target: reduce c6 timeout count from 96 to 46-66 (31-50% relative reduction).

### Research Integration

Key findings from the research report (01_invalid-patterns-research.md):

1. The existing `isUnsatBotTemporal` already handles the core "always false" detection. The invalid prefilter applies it to the **consequent** (complementing the valid prefilter which checks the antecedent).
2. Three recognizer functions cover distinct patterns: false-consequent detection (15-25 catches), satisfiable-antecedent-to-bot (10-20 catches), and unfulfillable eventuality (5-10 catches).
3. The invalid prefilter should insert **after** the valid prefilter, not before it, to avoid adding overhead to formulas already caught as valid.
4. Soundness proofs require structural induction for `isAlwaysFalse`, model construction for satisfiability claims, and direct contradiction for the eventuality pattern.
5. All recognizers assume the Base frame class (S5 modal + linear temporal) and remain sound under Dense/Discrete specializations.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Implement three invalid-pattern recognizer functions in DatasetGenerator.lean
- Wire a combined `structuralInvalidPrefilter` into `labelFormulaImpl` as Phase 1.5
- Provide formal soundness proofs in a new PrefilterSoundness.lean module
- Construct trivial countermodels for structurally invalid formulas
- Reduce c6 timeout count by catching 30-50 of 96 remaining timeouts

**Non-Goals**:
- General-purpose satisfiability checker (only conservative structural patterns)
- Modifying the existing valid prefilter or decision procedure
- Handling non-Base frame classes differently (all three classes share the same patterns)
- Achieving complete invalid-formula detection (only high-confidence structural patterns)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| False positive: labeling a valid formula as invalid | H | L | Each recognizer has a formal soundness proof; `isAlwaysFalse` and `isTrivialSatisfiable` are conservatively defined |
| Soundness proofs require complex model construction | M | M | Use existing test models from TruthTest.lean as templates; start with specific antecedent shapes rather than full generality |
| Interaction with `labelFormulaWithCache` (task 289) | L | L | Invalid prefilter runs before cache lookup; no cache key change needed |
| `SimpleCountermodel` insufficient for temporal formulas | M | L | The all-atoms-true construction is valid for non-temporal-operator antecedents; for temporal patterns, the countermodel documents the invalidity pattern without full model detail |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Core Recognizer Functions [COMPLETED]

**Goal**: Implement the three invalid-pattern recognizer functions and the combined invalid prefilter in DatasetGenerator.lean.

**Tasks**:
- [x] Add `isAlwaysFalse : Formula -> Bool` as an alias/wrapper for `isUnsatBotTemporal` (or use directly) with documentation noting it serves both the valid prefilter (antecedent check) and invalid prefilter (consequent check) *(deviation: altered -- used isUnsatBotTemporal directly instead of adding a separate isAlwaysFalse wrapper, since they are identical)*
- [x] Add `isTrivialSatisfiable : Formula -> Bool` that conservatively identifies formulas satisfiable in a reflexive 1-world S5 model: atoms, top (`imp bot bot`), `box(satisfiable)`, conjunctions of satisfiables
- [x] Add `isTemporalContradiction : Formula -> Bool` that detects `phi -> psi` where `isAlwaysFalse psi` and not `isAlwaysFalse phi`
- [x] Add `isObviousSatisfiable : Formula -> Bool` that detects `phi -> bot` where `isTrivialSatisfiable phi`, and `phi -> psi` where `isTrivialSatisfiable phi` and `isAlwaysFalse psi`
- [x] Add `hasUnfulfillableEventuality : Formula -> Bool` that detects `phi -> U(event, guard)` where `phi` contains `G(neg(event))` as a conjunct, and the symmetric `phi -> S(event, guard)` where `phi` contains `H(neg(event))`
- [x] Add `constructTrivialCountermodel : Formula -> SimpleCountermodel` that builds a simple all-atoms-true countermodel
- [x] Add `structuralInvalidPrefilter : Formula -> Option (Bool x String)` that chains the three recognizers with descriptive pattern labels: `"invalid_false_consequent"`, `"invalid_satisfiable_neg"`, `"invalid_unfulfillable_eventuality"`
- [x] Add `#eval` tests for each recognizer with positive and negative cases (at least 5 tests per function)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- Add all recognizer functions and `structuralInvalidPrefilter` after the existing valid prefilter code (after line ~690), plus `#eval` tests after existing test block

**Verification**:
- All `#eval` tests produce expected results
- `lake build Bimodal.Automation.DatasetGenerator` passes with zero errors

---

### Phase 2: Wire into labelFormulaImpl [NOT STARTED]

**Goal**: Insert the invalid prefilter into the labeling pipeline as Phase 1.5 between the valid prefilter and the tableau.

**Tasks**:
- [ ] In `labelFormulaImpl`, after the `match structuralPrefilterWithAxiom phi` block (after line 1022), add a second match on `structuralInvalidPrefilter phi`
- [ ] When `structuralInvalidPrefilter` returns `some (false, pattern)`, construct a `LabeledFormula` with `label := .invalid`, using `constructTrivialCountermodel`, `computeMetrics`, `PatternKey.fromFormula`, and `computeInterestingness`
- [ ] Set `decisionMethod := "structural_invalid_prefilter"` and `proofReconstructionMethod := some ("structural_invalid_prefilter:" ++ pattern)` for dataset attribution
- [ ] Use the existing `mkInvalidLabel` helper where applicable, or construct directly if the helper signature does not accommodate the `proofReconstructionMethod` field
- [ ] Add integration `#eval` test: `labelFormulaImpl (Formula.imp (Formula.atom 0) (Formula.untl Formula.bot (Formula.atom 1)))` should return `label := .invalid` with `decisionMethod = "structural_invalid_prefilter"`

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- Modify `labelFormulaImpl` to add Phase 1.5 match block between lines 1022-1023

**Verification**:
- `lake build Bimodal.Automation.DatasetGenerator` passes
- The integration `#eval` test returns the expected invalid label with the structural_invalid_prefilter decision method
- Existing valid prefilter behavior is unchanged (no regression)

---

### Phase 3: Soundness Proofs [NOT STARTED]

**Goal**: Create PrefilterSoundness.lean with formal soundness proofs for each invalid-pattern recognizer.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/PrefilterSoundness.lean` with imports from `DatasetGenerator` and `Bimodal.Semantics.Truth`
- [ ] Prove `isAlwaysFalse_sound`: if `isAlwaysFalse phi = true`, then `phi` is false at every world/time (structural induction on `phi` over the `bot`, `untl`, `snce`, `box` cases)
- [ ] Prove `atom_satisfiable`: every atom is satisfiable (construct a concrete 1-world model with the atom set to true)
- [ ] Prove `box_satisfiable_of_satisfiable`: if `phi` is satisfiable in a reflexive S5 model, then `box(phi)` is satisfiable (using the reflexive accessibility relation)
- [ ] Prove `invalid_false_consequent_sound`: if `isAlwaysFalse consequent = true` and `antecedent` is satisfiable, then `imp antecedent consequent` is not valid
- [ ] Prove `unfulfillable_eventuality_sound`: if `G(neg(event))` holds at time t, then `U(event, guard)` is false at time t (direct contradiction between universal and existential temporal quantification)
- [ ] Add the new module to the Automation barrel file `Theories/Bimodal/Automation.lean` as `import Bimodal.Automation.PrefilterSoundness`

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/PrefilterSoundness.lean` -- **NEW** file with soundness theorems (estimated 120-180 lines)
- `Theories/Bimodal/Automation.lean` -- Add import for PrefilterSoundness

**Verification**:
- `lake build Bimodal.Automation.PrefilterSoundness` passes with zero errors and zero sorries
- `lean_verify` on each soundness theorem shows no `sorryAx`
- All theorems have correct type signatures matching the recognizer definitions

---

### Phase 4: Testing and Validation [NOT STARTED]

**Goal**: Validate correctness of the invalid prefilter by cross-checking against the full tableau and running regression tests.

**Tasks**:
- [ ] Create a cross-validation `#eval` test block that runs both the invalid prefilter and the full `labelFormulaImpl` on a set of 10-15 formulas known to be invalid, verifying label agreement
- [ ] Create a regression test block that runs `structuralPrefilterWithAxiom` then `structuralInvalidPrefilter` on 10 known-valid formulas, verifying the invalid prefilter returns `none` for all of them
- [ ] Add negative tests: formulas where both antecedent and consequent are always-false (vacuously valid, should NOT be caught as invalid)
- [ ] Add edge case tests: `bot -> bot` (valid), `top -> bot` (invalid), `box(bot) -> U(bot, p)` (valid -- both sides always false), `p -> box(bot)` (invalid)

**Timing**: 0.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- Add cross-validation and regression test `#eval` blocks after existing tests

**Verification**:
- All cross-validation tests show label agreement between prefilter and tableau
- All regression tests confirm no false positives (valid formulas not mislabeled)
- All edge case tests produce expected results
- `lake build` (full project) passes with zero errors

---

### Phase 5: Build Verification and Documentation [NOT STARTED]

**Goal**: Full project build verification and documentation update.

**Tasks**:
- [ ] Run `lake build` to verify full project compiles with zero errors
- [ ] Verify zero new sorries introduced: `grep -rn "sorry" Theories/Bimodal/Automation/PrefilterSoundness.lean` returns empty
- [ ] Verify zero new axioms: run `lean_verify` on the main soundness theorems
- [ ] Update the docstring block at the top of the `structuralPrefilterWithAxiom` section in DatasetGenerator.lean to note the existence of the companion `structuralInvalidPrefilter`
- [ ] Add a documentation comment block before `structuralInvalidPrefilter` explaining the three patterns detected, their coverage estimates, and relationship to the valid prefilter

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- Documentation comments
- No other files modified

**Verification**:
- `lake build` passes with zero errors
- `grep -rn "sorry" Theories/Bimodal/Automation/PrefilterSoundness.lean` returns nothing
- `grep -rn "sorry" Theories/Bimodal/Automation/DatasetGenerator.lean` returns no new sorries

## Testing & Validation

- [ ] All `#eval` unit tests pass for each recognizer function (Phase 1)
- [ ] Integration test: `labelFormulaImpl` returns `label := .invalid` with `decisionMethod = "structural_invalid_prefilter"` for known invalid patterns (Phase 2)
- [ ] Cross-validation: no label disagreements between prefilter and full tableau on test set (Phase 4)
- [ ] Regression: no previously valid formulas change label (Phase 4)
- [ ] Soundness proofs: zero sorries in PrefilterSoundness.lean (Phase 3)
- [ ] Full build: `lake build` passes with zero errors (Phase 5)

## Artifacts & Outputs

- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- Modified: 6 new recognizer functions, `structuralInvalidPrefilter`, Phase 1.5 wiring in `labelFormulaImpl`, 30+ `#eval` tests
- `Theories/Bimodal/Automation/PrefilterSoundness.lean` -- **NEW**: Soundness proofs for each invalid pattern recognizer (120-180 lines)
- `Theories/Bimodal/Automation.lean` -- Modified: one new import line

## Rollback/Contingency

All changes are additive. To revert:
1. Remove the Phase 1.5 match block from `labelFormulaImpl` (restoring direct fallthrough to Phase 2)
2. Delete `PrefilterSoundness.lean` and its import from `Automation.lean`
3. Remove the recognizer function definitions and `#eval` tests from `DatasetGenerator.lean`

If soundness proofs (Phase 3) prove too difficult within the time budget:
- Phases 1-2 can be deployed independently with documentation noting "soundness proofs pending"
- The recognizers are conservatively designed (false positive risk is low even without formal proofs)
- Phase 3 can be split into a follow-up task
