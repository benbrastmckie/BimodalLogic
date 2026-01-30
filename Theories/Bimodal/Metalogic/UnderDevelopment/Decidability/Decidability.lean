/-!
# Decidability: Tableau-Based Decision Procedure

This module collects the tableau-based decision procedure infrastructure
for TM bimodal logic.

## Files

- `SignedFormula.lean`: Signed formula and branch types (0 sorries)
- `Tableau.lean`: Tableau rules and expansion (0 sorries)
- `Saturation.lean`: Branch saturation (0 sorries)
- `Closure.lean`: Closure detection (0 sorries)
- `Correctness.lean`: Correctness of tableau method (2 sorries)
- `ProofExtraction.lean`: Proof extraction from closed tableaux (0 sorries)
- `CountermodelExtraction.lean`: Countermodel extraction from open branches (0 sorries)
- `DecisionProcedure.lean`: Main decision procedure (3 sorries)

## Total Sorries: 5

| File | Sorries | Nature |
|------|---------|--------|
| Correctness.lean | 2 | Soundness/completeness of tableau rules |
| DecisionProcedure.lean | 3 | Termination/correctness of decision procedure |

## Status: UNDER DEVELOPMENT

This infrastructure is near-complete and provides constructive witnesses
(proofs or countermodels). Completing the 5 sorries would enable:
- Verified decision automation
- Countermodel generation for unprovable formulas
- Proof synthesis for valid formulas

## Potential Applications

1. **Tactic integration**: `decide_bimodal` tactic for automation
2. **Testing**: Generate test cases with known validity status
3. **Education**: Interactive proof exploration

## References

- Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
- Wu, M. Verified Decision Procedures for Modal Logics (Lean formalization)
- Task 774: Restoration to UnderDevelopment/
-/

-- COMMENTED IMPORTS - Enable individually for development
-- import Bimodal.Metalogic.UnderDevelopment.Decidability.SignedFormula
-- import Bimodal.Metalogic.UnderDevelopment.Decidability.Tableau
-- import Bimodal.Metalogic.UnderDevelopment.Decidability.Saturation
-- import Bimodal.Metalogic.UnderDevelopment.Decidability.Closure
-- import Bimodal.Metalogic.UnderDevelopment.Decidability.Correctness
-- import Bimodal.Metalogic.UnderDevelopment.Decidability.ProofExtraction
-- import Bimodal.Metalogic.UnderDevelopment.Decidability.CountermodelExtraction
-- import Bimodal.Metalogic.UnderDevelopment.Decidability.DecisionProcedure
