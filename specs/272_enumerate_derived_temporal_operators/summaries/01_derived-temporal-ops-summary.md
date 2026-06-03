# Implementation Summary: Enumerate Derived Temporal Operators

- **Task**: 272 - Enumerate derived temporal operators to unlock bimodal proofs
- **Status**: Implemented
- **Phases**: 4/4 completed
- **Build**: All modified modules pass `lake build`

## What Was Implemented

### Phase 1: Operator Definitions and Proof Lemmas

**Formula.lean** -- 4 new derived operator definitions:
- `release`: R(phi, psi) = neg(untl(neg phi, neg psi)) -- dual of Until
- `weak_until`: W(phi, psi) = (untl phi psi) or G(psi) -- Until without liveness
- `trigger`: T(phi, psi) = neg(snce(neg phi, neg psi)) -- dual of Since
- `weak_since`: WS(phi, psi) = (snce phi psi) or H(psi) -- Since without liveness

**TemporalDerived.lean** -- 8 Tier 1 conjunction elimination lemmas (all sorry-free, noncomputable):
- `always_to_present`: always(phi) -> phi
- `present_to_sometimes`: phi -> sometimes(phi)
- `weak_future_left`: weak_future(phi) -> phi
- `weak_future_right`: weak_future(phi) -> G(phi)
- `weak_past_left`: weak_past(phi) -> phi
- `weak_past_right`: weak_past(phi) -> H(phi)
- `always_imp_all_future`: always(phi) -> G(phi)
- `always_imp_all_past`: always(phi) -> H(phi)

### Phase 2: Enumerator Extension

**FormulaEnumerator.lean** -- derived temporal operators as first-class enumeration targets:
- `enumExactHelper`: G/H/F/P generated alongside box in the unary section, gated by temporalBudget > 0. Complexity overhead: F/P = 4, G/H = 8 (due to top = imp(bot, bot) having complexity 3).
- `sampleOne`: Added F/P and G/H as constructor choices (gated by sizeBudget thresholds).
- `sampleOneRandom`: Added F/P (choice 5) and G/H (choice 6) to IO-based random sampling.
- `randomSubFormula`: Extended from 6 to 9 branches (added all_past, some_future, some_past).
- `OperatorDistribution`: Added `allFutureCount`, `allPastCount`, `someFutureCount`, `somePastCount` fields.
- `countTopOperator`: Pattern-matches primitive expansion to recognize G/H/F/P.
- `DiversitySummary.display`: Shows derived temporal operator counts.

### Phase 3: Axiom Seeding

**FormulaEnumerator.lean** -- temporal-modal interaction schemata:
- `instantiateAxiom`: Extended from 14 to 22 schemata (indices 14-21). New schemata:
  - modal_future(phi): box(phi) -> G(box(phi))
  - modal_past(phi): box(phi) -> H(box(phi))
  - perpetuity_1(phi): box(phi) -> always(phi)
  - perpetuity_2(phi): sometimes(phi) -> diamond(phi)
  - G_distribution(phi, psi): G(phi -> psi) -> (G(phi) -> G(psi))
  - H_distribution(phi, psi): H(phi -> psi) -> (H(phi) -> H(psi))
  - always_to_present(phi): always(phi) -> phi
  - present_to_sometimes(phi): phi -> sometimes(phi)
- `theoremSeedFormulas`: Added 14 bimodal interaction seed formulas including G/H distribution instances, conjunction elimination lemmas, and deep temporal chains.

### Phase 4: Bimodal Interaction Filter

**FormulaEnumerator.lean** -- bimodal interaction dataset infrastructure:
- `hasBimodalInteraction`: Returns true if formula contains BOTH box and derived temporal (G/H/F/P).
- `generateBimodalSlice`: Enumerates at specified complexity levels, filters to bimodal formulas, returns with DiversitySummary.
- Helper functions `hasBox` and `hasDerivedTemporal` for recursive pattern detection.

## Plan Deviations

- Phase 1, Task 1.5: Notation for release/weak_until/trigger/weak_since was skipped because these operators are primarily used programmatically by the enumerator, not in hand-written proofs.
- Phase 2, Task 2.1: Complexity cost estimates in the plan (F/P=2, G/H=4) were corrected to actual values (F/P=4, G/H=8) based on the Formula.complexity function accounting for top = imp(bot, bot) having complexity 3.
- Phase 3, Task 3.1: Replaced box_imp_weak_future with present_to_sometimes which is more fundamental and proven in Phase 1.
- Phase 3, Task 3.2: Added proven conjunction elimination lemmas and G/H distribution instances instead of unproven release/weak_until formulas.
- Phase 4, Tasks 4.3-4.4: Dataset generation and temporal axiom verification are provided as callable infrastructure (generateBimodalSlice) rather than build-time #eval, because running the decision procedure is an IO operation.

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Syntax/Formula.lean` | +4 operator definitions (release, weak_until, trigger, weak_since) |
| `Theories/Bimodal/Theorems/TemporalDerived.lean` | +8 conjunction elimination lemmas (sorry-free) |
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | Extended enumeration (G/H/F/P), 22 axiom schemata, bimodal filter |

## Verification

- Zero sorry in modified files
- Zero new axioms introduced
- Zero vacuous definitions
- `lake build Bimodal.Syntax.Formula` passes
- `lake build Bimodal.Theorems.TemporalDerived` passes
- `lake build Bimodal.Automation.FormulaEnumerator` passes
- `lake build Bimodal.Automation.DatasetGenerator` passes (downstream consumer)
