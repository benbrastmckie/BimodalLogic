# Semantics Tests

Tests for task frame semantics.

## Contents

| File | Description |
|------|-------------|
| TaskFrameTest.lean | Task frame structure tests |
| TruthTest.lean | Truth evaluation tests |
| SemanticPropertyTest.lean | Property-based semantics tests |
| SaturationFiniteAxiomTest.lean | Axiom-profile evidence for the finite-carrier *Saturation* discharge |
| OpenLanguageAxiomTest.lean | Axiom-profile guards for the open-future and open-past language: the Ockhamist separating pair, its time-reversal mirror, and `propext`-only conservativity over L⁺ |
| HybridLanguageAxiomTest.lean | Axiom-profile guards for the hybrid state language: choice-free invariance of the register-free fragment, the two definability theorems for recurrence-freeness, and `propext`-only conservativity over L⁺ |
| QuantLanguageAxiomTest.lean | Axiom-profile guards for the propositional-quantifier language: choice-free invariance under the lifted family, the standard-semantics definability and non-invariance results, and `propext`-only conservativity over L |
| ConvexTruthTest.lean | Axiom-profile guards for the convex-index consequence relations C3 and C4: the five gap closures of the axiom-survival table, `truthC3_timeShift`, the germ theorem `c3_box_untl_unsat`, one refutation, and both table theorems |
| DependentUltraproductProbe.lean | Axiom-profile regression check over the promoted ultraproduct modules |
| ValidityLayerTest.lean | Definitional-coincidence regressions for the abstract validity layer: each language's validity `def`s and derived operators against the generic `PointTruth`/`TruthClauses` ones, plus a toy fifth-language conformance check |
| QTimeTest.lean | ℚ-time frames: `isQTime_rat`, the ℤ non-example, `validQTime_iff_validDense`, and axiom-profile guards |
| StateTopologyTest.lean | Regression witness for the state-topology collection, whose two modules are leaves with no other in-tree consumer: the T1 biconditional in both forms, the open-set criterion, R0 and the equality form of *Limit* at a regular frame, history continuity, the two-origin and hedgehog promotions, and nine axiom-profile guards |

## Coverage

- Task frame construction and accessibility
- Truth evaluation at convex histories
- Validity checking
- Axiom profiles of the finite-carrier *Saturation* discharge and the ultraproduct construction
- The state topology of a task frame, and the declarations the manuscript's topology appendix cites

## Related

- [Source: Semantics/](../../../FormalSystem/Semantics/)
- [Parent README](../README.md)

---

*Last Updated: 2026-03-16*
