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

### Phase 2: Extend Formula Enumerator with Derived Temporal Operators [NOT STARTED]

**Goal**: Modify `enumExactHelper` and `sampleOne` to generate formulas using G (all_future), H (all_past), F (some_future), and P (some_past) as first-class enumeration targets alongside raw untl/snce.

**Tasks**:
- [ ] Extend `enumExactHelper` in FormulaEnumerator.lean to add derived unary temporal operators:
  - G (all_future): unary, consumes 1 temporal depth, costs ~4 complexity (neg(untl(neg phi, top)))
  - H (all_past): unary, consumes 1 temporal depth, costs ~4 complexity (neg(snce(neg phi, top)))
  - F (some_future): unary, consumes 1 temporal depth, costs ~2 complexity (untl(phi, top))
  - P (some_past): unary, consumes 1 temporal depth, costs ~2 complexity (snce(phi, top))
  - These should be generated alongside boxes in the unary section, gated by `temporalBudget > 0`
  - Use the actual complexity cost of each operator (F/P cost 2: untl/snce + top; G/H cost 4: neg + untl/snce + neg + top)
- [ ] Update `sampleOne` (deterministic sampling) to include derived temporal operators as random constructor choices
- [ ] Update `sampleOneRandom` (IO sampling) to include derived temporal operators as random constructor choices
- [ ] Update `randomSubFormula` to include additional derived temporal branches (currently has `all_future` at choice 3 -- add `all_past`, `some_future`, `some_past`)
- [ ] Update `OperatorDistribution` to track derived operator counts (add `allFutureCount`, `allPastCount`, `someFutureCount`, `somePastCount` fields)
- [ ] Update `countTopOperator` to recognize derived operators by pattern matching on their primitive expansion
- [ ] Update `DiversitySummary.display` to show derived operator counts
- [ ] Run `lake build Bimodal.Automation.FormulaEnumerator` to verify

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- extend enumExactHelper, sampleOne, sampleOneRandom, randomSubFormula, OperatorDistribution, countTopOperator, display

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` passes
- A quick `#eval` test enumerating at complexity 5 with temporal depth 1 produces formulas containing G/H/F/P operators
- Derived operators appear in the DiversitySummary output

---

### Phase 3: Extend Axiom Seeding with Temporal Interaction Schemata [NOT STARTED]

**Goal**: Add temporal-modal interaction axiom schemata to `instantiateAxiom` and `theoremSeedFormulas` to ensure the valid formula pool contains formulas that require temporal axioms in proofs.

**Tasks**:
- [ ] Add new axiom schemata to `instantiateAxiom`:
  - `modal_future(phi)`: `box phi -> G(box phi)` (derived from temp_future_derived)
  - `modal_past(phi)`: `box phi -> H(box phi)` (past dual)
  - `perpetuity_1(phi)`: `box phi -> always phi`
  - `perpetuity_2(phi)`: `sometimes phi -> diamond phi`
  - `G_distribution(phi, psi)`: `G(phi -> psi) -> (G phi -> G psi)`
  - `H_distribution(phi, psi)`: `H(phi -> psi) -> (H phi -> H psi)`
  - `always_to_present(phi)`: `always phi -> phi`
  - `box_imp_weak_future(phi)`: `box phi -> weak_future phi`
- [ ] Add new bimodal interaction seed formulas to `theoremSeedFormulas`:
  - Formulas mixing box with G/H/F/P: `G(p) -> box(G(p))`, `box(p) -> G(box(p))`, `sometimes(box(p)) -> box(always(p))`
  - Formulas using the newly defined release/weak_until if complexity allows
- [ ] Increase `schemaIdx` range in `instantiateAxiom` to accommodate new schemata (currently 0..13, extend)
- [ ] Run `lake build Bimodal.Automation.FormulaEnumerator` to verify

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- extend instantiateAxiom and theoremSeedFormulas

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` passes
- `generateValidBatch` produces formulas containing G/H/F/P operators

---

### Phase 4: Generate Bimodal Interaction Dataset and Verify Temporal Axiom Usage [NOT STARTED]

**Goal**: Generate a targeted "bimodal interaction" dataset slice at c5-c7 using formulas containing both box and G/H/F/P operators, and verify that valid formulas use temporal axioms in their proofs.

**Tasks**:
- [ ] Create a bimodal interaction filter function in FormulaEnumerator.lean or DatasetGenerator.lean:
  - `hasBimodalInteraction : Formula -> Bool` returns true if the formula contains BOTH a box operator and at least one derived temporal operator (G/H/F/P pattern)
- [ ] Add a bimodal interaction dataset generation mode or configuration:
  - Option A: Add a `bimodalOnly : Bool` field to `EnumParams` that applies the bimodal interaction filter
  - Option B: Create a standalone `#eval` test that enumerates at c5-c7, filters to bimodal formulas, labels them, and reports axiom usage
- [ ] Generate the bimodal interaction dataset slice:
  - Enumerate formulas at c5, c6, c7 with derived temporal operators enabled
  - Filter to formulas containing both modal and temporal operators
  - Label with the decision procedure
  - Report: total formulas, valid count, invalid count, temporal axiom usage in proofs
- [ ] Verify temporal axiom usage:
  - Check that valid formulas in the bimodal slice cite temporal axioms (modal_future, connect_future, G_distribution, etc.) in their proof traces
  - Report the fraction of valid formulas using temporal axioms (target: > 0%, ideally > 10%)
- [ ] Run full `lake build` to verify no regressions across the project

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
