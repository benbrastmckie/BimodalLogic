# Semantics Tests

Tests for task frame semantics.

## Contents

| File | Description |
|------|-------------|
| TaskFrameTest.lean | Task frame structure tests |
| TruthTest.lean | Truth evaluation tests |
| SemanticPropertyTest.lean | Property-based semantics tests |
| SaturationFiniteAxiomTest.lean | Axiom-profile evidence for the finite-carrier *Saturation* discharge |
| DependentUltraproductProbe.lean | Axiom-profile regression check over the promoted ultraproduct modules |
| ValidityLayerTest.lean | Definitional-coincidence regressions for the abstract validity layer: each language's validity `def`s and derived operators against the generic `PointTruth`/`TruthClauses` ones, plus a toy fifth-language conformance check |

## Coverage

- Task frame construction and accessibility
- Truth evaluation at convex histories
- Validity checking
- Axiom profiles of the finite-carrier *Saturation* discharge and the ultraproduct construction

## Related

- [Source: Semantics/](../../../FormalSystem/Semantics/)
- [Parent README](../README.md)

---

*Last Updated: 2026-03-16*
