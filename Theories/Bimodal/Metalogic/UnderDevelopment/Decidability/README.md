# Decidability: Tableau-Based Decision Procedure

This directory contains a tableau-based decision procedure for TM bimodal logic.

## Status: UNDER DEVELOPMENT

**Total Sorries**: 5

This infrastructure is near-complete and provides constructive witnesses (proofs or countermodels). Completing the 5 sorries would enable verified decision automation.

## Files

| File | Sorries | Description |
|------|---------|-------------|
| SignedFormula.lean | 0 | Signed formula and branch types |
| Tableau.lean | 0 | Tableau rules and expansion |
| Saturation.lean | 0 | Branch saturation algorithm |
| Closure.lean | 0 | Closure detection |
| Correctness.lean | 2 | Soundness/completeness of tableau rules |
| ProofExtraction.lean | 0 | Extract proofs from closed tableaux |
| CountermodelExtraction.lean | 0 | Extract countermodels from open branches |
| DecisionProcedure.lean | 3 | Main decision procedure |

## Sorry Analysis

### Correctness.lean (2 sorries)

| Sorry | Description |
|-------|-------------|
| tableau_soundness | If tableau closes, formula is valid |
| tableau_completeness | If formula is valid, tableau closes |

### DecisionProcedure.lean (3 sorries)

| Sorry | Description |
|-------|-------------|
| termination | Tableau expansion terminates |
| decide_correct_valid | If decide returns true, formula is valid |
| decide_correct_invalid | If decide returns false, formula is invalid |

## Architecture

```
SignedFormula.lean
        |
        v
   Tableau.lean
        |
        v
  Saturation.lean  Closure.lean
        \              /
         \            /
          v          v
      Correctness.lean
             |
    +--------+--------+
    |                 |
    v                 v
ProofExtraction  CountermodelExtraction
    \                 /
     \               /
      v             v
   DecisionProcedure.lean
```

## Potential Applications

1. **Tactic integration**: `decide_bimodal` tactic for automation
   ```lean
   example : valid (box p ⟶ diamond p) := by decide_bimodal
   ```

2. **Testing**: Generate test cases with known validity status
3. **Education**: Interactive proof exploration with visualization
4. **Counterexample generation**: Automatic countermodel construction

## Development Notes

### To work on these files:

1. Uncomment the relevant import in `Decidability.lean`
2. Build: `lake build Bimodal.Metalogic.UnderDevelopment.Decidability.SignedFormula`
3. Re-comment import before committing

### Completing the sorries:

1. **termination**: Prove that subformula closure bounds exploration
2. **tableau_soundness**: Induction on derivation, show closed branches give proofs
3. **tableau_completeness**: Induction on formula complexity, use FMP
4. **decide_correct_***: Combine soundness, completeness, termination

### Key insights:

- Finite Model Property guarantees bounded exploration
- Subformula closure provides termination measure
- Each expansion step decreases formula complexity

## References

- Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
- Wu, M. Verified Decision Procedures for Modal Logics (Lean formalization)
- Task 774: Restoration to UnderDevelopment/
