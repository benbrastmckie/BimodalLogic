import Bimodal.Metalogic.SoundnessLemmas
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Completeness
import Bimodal.Metalogic.Decidability

/-!
# Bimodal.Metalogic - Soundness, Completeness, and Decidability

Aggregates all metalogic components for bimodal logic TM (Tense and Modality). Provides
the foundational metalogical results: soundness, completeness, and tableau-based decision
procedures.

## Main Results

| Component | Status | Key Theorem |
|-----------|--------|-------------|
| Soundness | COMPLETE | `soundness : Gamma derives phi -> Gamma valid phi` |
| Completeness | IN PROGRESS | BXCanonical architecture |
| Decidability | COMPLETE | `decide : Formula -> DecisionResult` |

## Publication-Ready Theorems

The following theorems are sorry-free with zero custom axioms:

- `soundness`: If Gamma derives phi, then phi is valid (Soundness.lean)
- `bmcs_truth_lemma`: Truth lemma for BFMCS (Bundle/TruthLemma.lean)


## Axiom Dependencies

Standard Lean axioms only (no custom axioms on publication path):
- `propext`: Propositional extensionality
- `Classical.choice`: Classical choice
- `Quot.sound`: Quotient soundness
- `Lean.ofReduceBool`: Compiler primitives
- `Lean.trustCompiler`: Compiler trust

## Submodules

- `SoundnessLemmas`: Bridge theorems connecting syntax and semantics
- `Soundness`: Main soundness theorem with proofs for all 21 axioms and 7 rules
- `Completeness`: Completeness infrastructure (MCS theory, canonical constructions)
- `Decidability`: Tableau-based decision procedure with proof/countermodel extraction
- `Bundle/`: BFMCS infrastructure and truth lemma
- `BXCanonical/`: Reflexive BX completeness architecture (active)

## Usage

```lean
import Bimodal.Metalogic

-- Soundness theorem
#check Bimodal.Metalogic.soundness

-- Decision procedure
#check Bimodal.Metalogic.Decidability.decide
```

## References

* [Bundle/TruthLemma.lean](Metalogic/Bundle/TruthLemma.lean) - Truth lemma
* [Soundness.lean](Metalogic/Soundness.lean) - Soundness proof
* [Decidability.lean](Metalogic/Decidability.lean) - Decision procedure
* [SuccChain/](Metalogic/SuccChain/) - Successor chain completeness (active development)
-/
