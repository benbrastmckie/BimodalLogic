import Bimodal.Metalogic.SoundnessLemmas
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Completeness
import Bimodal.Metalogic.Decidability
import Bimodal.Metalogic.StagedConstruction.Completeness
import Bimodal.Metalogic.Bundle.CanonicalConstruction

/-!
# Bimodal.Metalogic - Soundness, Completeness, and Decidability

Aggregates all metalogic components for bimodal logic TM (Tense and Modality). Provides
the foundational metalogical results: soundness, completeness, and tableau-based decision
procedures.

## Main Results

| Component | Status | Key Theorem |
|-----------|--------|-------------|
| Soundness | COMPLETE | `soundness : Gamma derives phi -> Gamma valid phi` |
| Completeness | COMPLETE | `dense_completeness_components_proven` |
| Decidability | COMPLETE | `decide : Formula -> DecisionResult` |

## Publication-Ready Theorems

The following theorems are sorry-free with zero custom axioms:

- `soundness`: If Gamma derives phi, then phi is valid (Soundness.lean)
- `dense_completeness_components_proven`: All completeness components proven (StagedConstruction/Completeness.lean)
- `cantor_iso`: TimelineQuot is order-isomorphic to Q (CantorApplication.lean)
- `bmcs_truth_lemma`: Truth lemma for BFMCS (Bundle/TruthLemma.lean)
- `shifted_truth_lemma`: Truth lemma for shift-closed Omega (CanonicalConstruction.lean)

## Axiom Dependencies

Standard Lean axioms only (no custom axioms on publication path):
- `propext`: Propositional extensionality
- `Classical.choice`: Classical choice
- `Quot.sound`: Quotient soundness
- `Lean.ofReduceBool`: Compiler primitives
- `Lean.trustCompiler`: Compiler trust

## Submodules

- `SoundnessLemmas`: Bridge theorems connecting syntax and semantics
- `Soundness`: Main soundness theorem with proofs for all 14 axioms and 7 rules
- `Completeness`: Completeness infrastructure (MCS theory, canonical constructions)
- `Decidability`: Tableau-based decision procedure with proof/countermodel extraction
- `StagedConstruction/`: Dense completeness via Cantor-interval construction
- `Bundle/`: BFMCS infrastructure and truth lemma

## Usage

```lean
import Bimodal.Metalogic

-- Soundness theorem
#check Bimodal.Metalogic.soundness

-- Completeness (dense temporal)
#check Bimodal.Metalogic.StagedConstruction.dense_completeness_components_proven

-- Decision procedure
#check Bimodal.Metalogic.Decidability.decide
```

## References

* [StagedConstruction/Completeness.lean](Metalogic/StagedConstruction/Completeness.lean) - Dense completeness
* [Bundle/TruthLemma.lean](Metalogic/Bundle/TruthLemma.lean) - Truth lemma
* [Soundness.lean](Metalogic/Soundness.lean) - Soundness proof
* [Decidability.lean](Metalogic/Decidability.lean) - Decision procedure
-/
