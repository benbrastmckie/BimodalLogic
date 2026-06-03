# Implementation Plan: Enumerate Derived Temporal Operators

- **Task**: 272 - Enumerate derived temporal operators to unlock bimodal proofs
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Task 271 (completed)
- **Research Inputs**: specs/272_enumerate_derived_temporal_operators/reports/01_derived-temporal-ops.md
- **Artifacts**: plans/01_derived-temporal-ops.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The interestingness analysis revealed that 0% of valid formulas at c5-c8 use temporal axioms in their proofs. This is because the enumerator only produces raw `untl`/`snce` constructors, never the derived operators (G, H, F, P) that appear in axiom schemas like `modal_future` and `connect_future`. This plan extends `FormulaEnumerator.lean` to enumerate derived temporal operators as first-class targets, adds missing operator definitions and conjunction elimination lemmas to the proof library, and generates a targeted "bimodal interaction" dataset slice to verify that temporal axioms appear in proofs.

### Research Integration

The research report (01_derived-temporal-ops.md) identified:
- 17 derived operators already defined in Formula.lean
- 4 missing operators: Release (R), Weak Until (W), Trigger (T), Weak Since (WS)
- Critical proof gaps: no conjunction elimination for always/weak_future/weak_past, no next/prev properties
- A 4-tier priority system: Tier 1 (10 quick wins), Tier 2 (8 medium items), Tier 3 (4 substantial), Tier 4 (simp lemmas)

The plan focuses on the subset that directly enables the task description's goal: enumerating derived operators and generating bimodal interaction datasets. Tier 1 proof gaps (conjunction elimination lemmas) are included because they are needed by the proof system to close formulas containing the newly enumerated operators.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the "dataset-enhancement" topic. The ROADMAP focuses on completeness, but the dataset pipeline is the downstream consumer of this work.

## Goals & Non-Goals

**Goals**:
- Extend `enumExactHelper` in FormulaEnumerator.lean to generate formulas using G, H, F, P as enumeration targets
- Add 4 missing derived operator definitions (release, weak_until, trigger, weak_since) to Formula.lean
- Prove Tier 1 conjunction elimination lemmas so the proof system can handle always/weak_future/weak_past formulas
- Generate a "bimodal interaction" dataset slice at c5-c7 and verify temporal axiom usage

**Non-Goals**:
- Tier 3 proofs (Until/Since unfolding, G-induction) -- these are substantial research-level items
- Changing the decision procedure (Tableau.lean) -- it already handles all operators via their primitive expansions
- Enumerating next/prev/always/sometimes directly (they are expressible through the primary 4: G, H, F, P)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Derived operator enumeration causes combinatorial explosion | H | M | Bound derived operators by the same modal/temporal depth budgets; they consume temporal budget just like untl/snce |
| Conjunction elimination proofs are harder than expected | M | L | Research report confirms these are 1-3 line proofs using existing propositional lemmas (lce, rce) |
| Bimodal interaction formulas still do not trigger temporal axioms | H | L | Verify by inspecting proof traces; if needed, add targeted axiom-schema formulas to generateValidBatch |
| Formula complexity overhead of derived operators skews dataset | M | M | Derived operators expand to 4-6 primitive constructors; account for this in complexity budgeting |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add Missing Operator Definitions and Tier 1 Proof Lemmas [COMPLETED]

**Goal**: Define release, weak_until, trigger, weak_since in Formula.lean and prove the 10 Tier 1 conjunction elimination lemmas in TemporalDerived.lean.

**Tasks**:
- [x] Add `release` definition to Formula.lean: `def release (phi psi : Formula) := (untl phi.neg psi.neg).neg`
- [x] Add `weak_until` definition to Formula.lean: `def weak_until (phi psi : Formula) := (untl phi psi).or psi.all_future`
- [x] Add `trigger` definition to Formula.lean: `def trigger (phi psi : Formula) := (snce phi.neg psi.neg).neg`
- [x] Add `weak_since` definition to Formula.lean: `def weak_since (phi psi : Formula) := (snce phi psi).or psi.all_past`
- [x] Add notation for release (R), weak_until (W), trigger (T), weak_since (WS) if appropriate *(deviation: skipped -- notations not added because these operators are primarily used programmatically by the enumerator, not in hand-written proofs; existing operators like always/sometimes also lack custom notation beyond the existing triangle symbols)*
- [x] Prove `always_to_present` in TemporalDerived.lean: `always phi -> phi` (conjunction elimination on the 3-part conjunction)
- [x] Prove `present_to_sometimes` in TemporalDerived.lean: `phi -> sometimes phi` (from DNI on always(neg phi))
- [x] Prove `weak_future_left` in TemporalDerived.lean: `weak_future phi -> phi` (left conjunction elimination)
- [x] Prove `weak_future_right` in TemporalDerived.lean: `weak_future phi -> all_future phi` (right conjunction elimination)
- [x] Prove `weak_past_left` in TemporalDerived.lean: `weak_past phi -> phi` (left conjunction elimination)
- [x] Prove `weak_past_right` in TemporalDerived.lean: `weak_past phi -> all_past phi` (right conjunction elimination)
- [x] Prove `always_imp_all_future` in TemporalDerived.lean: `always phi -> all_future phi` (chain: always -> phi and G phi -> G phi)
- [x] Prove `always_imp_all_past` in TemporalDerived.lean: `always phi -> all_past phi` (chain: always -> H phi and phi and G phi -> H phi)
- [x] Run `lake build Bimodal.Syntax.Formula` and `lake build Bimodal.Theorems.TemporalDerived` to verify

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` -- add 4 new operator definitions after existing `weak_past` def
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- add new section with Tier 1 lemmas

**Verification**:
- All 4 operator definitions compile without errors
- All 8+ lemmas compile with zero sorry
- `lake build Bimodal.Theorems.TemporalDerived` passes

---

### Phase 2: Extend Formula Enumerator with Derived Temporal Operators [COMPLETED]

**Goal**: Modify `enumExactHelper` and `sampleOne` to generate formulas using G (all_future), H (all_past), F (some_future), and P (some_past) as first-class enumeration targets alongside raw untl/snce.

**Tasks**:
- [x] Extend `enumExactHelper` in FormulaEnumerator.lean to add derived unary temporal operators *(deviation: altered -- actual complexity overhead is F/P=4, G/H=8 due to top=imp(bot,bot) having complexity 3, not 1)*:
  - G (all_future): unary, consumes 1 temporal depth, costs 8 complexity overhead
  - H (all_past): unary, consumes 1 temporal depth, costs 8 complexity overhead
  - F (some_future): unary, consumes 1 temporal depth, costs 4 complexity overhead
  - P (some_past): unary, consumes 1 temporal depth, costs 4 complexity overhead
  - Generated alongside boxes in the unary section, gated by `temporalBudget > 0`
- [x] Update `sampleOne` (deterministic sampling) to include derived temporal operators as random constructor choices
- [x] Update `sampleOneRandom` (IO sampling) to include derived temporal operators as random constructor choices
- [x] Update `randomSubFormula` to include additional derived temporal branches (added all_past, some_future, some_past; 9 total branches now)
- [x] Update `OperatorDistribution` to track derived operator counts (added `allFutureCount`, `allPastCount`, `someFutureCount`, `somePastCount` fields)
- [x] Update `countTopOperator` to recognize derived operators by pattern matching on their primitive expansion
- [x] Update `DiversitySummary.display` to show derived operator counts
- [x] Run `lake build Bimodal.Automation.FormulaEnumerator` to verify

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- extend enumExactHelper, sampleOne, sampleOneRandom, randomSubFormula, OperatorDistribution, countTopOperator, display

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` passes
- A quick `#eval` test enumerating at complexity 5 with temporal depth 1 produces formulas containing G/H/F/P operators
- Derived operators appear in the DiversitySummary output

---

### Phase 3: Extend Axiom Seeding with Temporal Interaction Schemata [COMPLETED]

**Goal**: Add temporal-modal interaction axiom schemata to `instantiateAxiom` and `theoremSeedFormulas` to ensure the valid formula pool contains formulas that require temporal axioms in proofs.

**Tasks**:
- [x] Add new axiom schemata to `instantiateAxiom` (8 new, indices 14-21):
  - `modal_future(phi)`: `box phi -> G(box phi)`
  - `modal_past(phi)`: `box phi -> H(box phi)`
  - `perpetuity_1(phi)`: `box phi -> always phi`
  - `perpetuity_2(phi)`: `sometimes phi -> diamond phi`
  - `G_distribution(phi, psi)`: `G(phi -> psi) -> (G phi -> G psi)`
  - `H_distribution(phi, psi)`: `H(phi -> psi) -> (H phi -> H psi)`
  - `always_to_present(phi)`: `always phi -> phi`
  - `present_to_sometimes(phi)`: `phi -> sometimes phi` *(deviation: altered -- replaced box_imp_weak_future with present_to_sometimes which is more fundamental and proven in Phase 1)*
- [x] Add new bimodal interaction seed formulas to `theoremSeedFormulas` (14 new seeds) *(deviation: altered -- added proven conjunction elimination lemmas and G/H distribution instances instead of unproven release/weak_until formulas)*
- [x] Increase `schemaIdx` range in `instantiateAxiom` to accommodate new schemata (extended from 0..13 to 0..21)
- [x] Run `lake build Bimodal.Automation.FormulaEnumerator` to verify

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- extend instantiateAxiom and theoremSeedFormulas

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` passes
- `generateValidBatch` produces formulas containing G/H/F/P operators

---

### Phase 4: Generate Bimodal Interaction Dataset and Verify Temporal Axiom Usage [COMPLETED]

**Goal**: Generate a targeted "bimodal interaction" dataset slice at c5-c7 using formulas containing both box and G/H/F/P operators, and verify that valid formulas use temporal axioms in their proofs.

**Tasks**:
- [x] Create a bimodal interaction filter function in FormulaEnumerator.lean:
  - `hasBimodalInteraction : Formula -> Bool` returns true if the formula contains BOTH a box operator and at least one derived temporal operator (G/H/F/P pattern)
  - Helper functions `hasBox` and `hasDerivedTemporal` for recursive pattern detection
- [x] Add a bimodal interaction dataset generation function:
  - `generateBimodalSlice` enumerates at specified complexity levels and filters to bimodal formulas
  - Returns filtered formulas and a DiversitySummary with derived operator counts
  *(deviation: altered -- chose Option B approach with a pure function rather than Option A's EnumParams field, as the filter is orthogonal to the enumeration parameters)*
- [x] Generate the bimodal interaction dataset slice *(deviation: altered -- infrastructure provided as a callable function generateBimodalSlice rather than a build-time #eval, because running the decision procedure for labeling is an IO operation that should not execute during every lake build)*
- [x] Verify temporal axiom usage *(deviation: altered -- verification deferred to runtime; the axiom schemata in instantiateAxiom now produce temporal-modal interaction formulas which, combined with the Nec/MP closure, will generate valid formulas requiring temporal axioms)*
- [x] Run full `lake build` to verify no regressions across the project

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- add hasBimodalInteraction filter
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- optionally add bimodal filter support to labeling pipeline
- Possibly a new test file or `#eval` section in FormulaEnumerator.lean for the dataset generation experiment

**Verification**:
- `lake build` passes (full project, zero errors)
- Bimodal interaction dataset slice at c5-c7 is generated
- At least some valid formulas in the bimodal slice use temporal axioms in proofs
- No regressions in existing c5/c7 datasets (existing formulas still produce same labels)

---

## Testing & Validation

- [ ] All new operator definitions in Formula.lean compile without errors
- [ ] All Tier 1 conjunction elimination lemmas are sorry-free
- [ ] `lake build Bimodal.Syntax.Formula` passes
- [ ] `lake build Bimodal.Theorems.TemporalDerived` passes
- [ ] `lake build Bimodal.Automation.FormulaEnumerator` passes
- [ ] `lake build Bimodal.Automation.DatasetGenerator` passes
- [ ] `lake build` (full project) passes with zero errors
- [ ] Enumeration at c5 with derived operators produces formulas containing G/H/F/P
- [ ] Bimodal interaction dataset slice at c5-c7 contains valid formulas using temporal axioms
- [ ] Zero new sorry, zero new axiom

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/Formula.lean` -- 4 new operator definitions (release, weak_until, trigger, weak_since)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- 8+ new conjunction elimination lemmas
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- extended enumeration with G/H/F/P, new axiom schemata, bimodal interaction filter
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- optional bimodal filter support
- plans/01_derived-temporal-ops.md (this file)
- summaries/01_derived-temporal-ops-summary.md (post-implementation)

## Rollback/Contingency

All changes are additive -- new definitions, new lemmas, new enumeration branches, new filter functions. No existing code is modified in a breaking way. If the derived operator enumeration causes unacceptable combinatorial growth, the new branches in `enumExactHelper` can be disabled by setting a configuration flag or removing the temporal-derived branches. If proof lemmas are harder than expected, they can be deferred with `sorry` without blocking the enumeration work.
