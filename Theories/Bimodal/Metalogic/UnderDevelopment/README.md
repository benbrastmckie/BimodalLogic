# Under Development: Alternative Completeness Approaches

This directory contains work-in-progress proof infrastructure that is **not part of the main build**. These approaches contain sorries and are preserved for research and potential future completion.

## Contents

### RepresentationTheorem/ (17 sorries)

Universal canonical model approach to completeness using indexed MCS families.

| File | Sorries | Description |
|------|---------|-------------|
| TaskRelation.lean | 5 | Cross-sign duration composition |
| CoherentConstruction.lean | 8 | Cross-origin coherence witnessing |
| TruthLemma.lean | 4 | Box/temporal backward directions |
| CanonicalHistory.lean | 0 | Depends on TaskRelation (sorry-free itself) |
| UniversalCanonicalModel.lean | 0 | Depends on truth lemma/coherent construction |
| InfinitaryStrongCompleteness.lean | 0 | Depends on representation theorem |
| Compactness.lean | 0 | Depends on infinitary completeness |

**Why sorries exist**: See individual READMEs for detailed explanations. Key limitations:
- Cross-origin coherence requires omega-rule not present in TM logic
- Box semantics use S5-style universal quantification over ALL histories
- Temporal backward directions require infinite derivation

### Decidability/ (5 sorries)

Tableau-based decision procedure for TM bimodal logic.

| File | Sorries | Description |
|------|---------|-------------|
| SignedFormula.lean | 0 | Core types |
| Tableau.lean | 0 | Tableau rules |
| Saturation.lean | 0 | Branch saturation |
| Closure.lean | 0 | Closure detection |
| Correctness.lean | 2 | Soundness/completeness of tableau rules |
| ProofExtraction.lean | 0 | Extract proofs from closed tableaux |
| CountermodelExtraction.lean | 0 | Extract countermodels from open branches |
| DecisionProcedure.lean | 3 | Main decision procedure |

**Status**: Near-complete infrastructure. Completing the 5 sorries would enable:
- Verified decision automation (`decide_bimodal` tactic)
- Countermodel generation for unprovable formulas
- Proof synthesis for valid formulas

## Import Isolation Rules

**CRITICAL**: This directory maintains strict import isolation:

1. **Files here CAN import** from elsewhere in the project
2. **Files here CANNOT be imported** by files outside UnderDevelopment/
3. The root `UnderDevelopment.lean` keeps imports **commented out**

This ensures:
- Main `lake build` never compiles UnderDevelopment/ code
- No sorries propagate to the main codebase
- Developers can work on these files independently

## Working Alternative

For **sorry-free completeness**, use:
```lean
import Bimodal.Metalogic.FMP.SemanticCanonicalModel

-- semantic_weak_completeness works via contrapositive
-- and avoids all architectural limitations
```

## Development Guidelines

1. **To work on files**: Uncomment the relevant import in the subdirectory root module
2. **Before committing**: Re-comment imports to maintain isolation
3. **Building individually**: `lake build Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem.TaskRelation`
4. **Testing full build**: `lake build` should NOT compile UnderDevelopment/

## History

- **Task 772** (2026-01-30): Original archival to Boneyard/Metalogic_v4/
- **Task 774** (2026-01-30): Restoration to UnderDevelopment/ with import isolation

## References

- Task 750: Truth bridge analysis (identified architectural limitations)
- Task 769: Deprecation analysis with DEPRECATED markers
- `FMP/SemanticCanonicalModel.lean`: Sorry-free completeness via contrapositive
