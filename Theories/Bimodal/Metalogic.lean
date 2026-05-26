import Bimodal.Metalogic.SoundnessLemmas.Core
import Bimodal.Metalogic.SoundnessLemmas.DenseValidity
import Bimodal.Metalogic.SoundnessLemmas.FrameClassVariants
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
| Soundness | SORRY-FREE | `soundness`, `soundness_dense`, `soundness_discrete` |
| Completeness | SORRY (chronicle) | `completeness` (BXCanonical/Completeness.lean) |
| Decidability | SORRY-FREE | `decide` (Decidability/DecisionProcedure.lean) |

## Publication-Ready Theorems

The following theorems are sorry-free with zero custom axioms:

- `soundness`: If Gamma derives phi (dense-compatible), then phi is valid
- `soundness_dense`: Dense-frame-specific soundness
- `soundness_discrete`: Discrete-frame-specific soundness
- `decide`: Tableau-based decision procedure with proof/countermodel extraction

## Axiom Dependencies

Standard Lean axioms only (no custom axioms on publication path):
- `propext`: Propositional extensionality
- `Classical.choice`: Classical choice
- `Quot.sound`: Quotient soundness
- `Lean.ofReduceBool`, `Lean.trustCompiler`: Compiler primitives (from `native_decide`)

## Submodules

- `SoundnessLemmas`: Bridge theorems connecting syntax and semantics
- `Soundness`: Main soundness theorem with proofs for all axioms and rules
- `Completeness`: MCS properties (disjunction, conjunction, modal closure)
- `Decidability`: Tableau-based decision procedure with proof/countermodel extraction
- `BXCanonical/`: Completeness architecture (Chronicle/Burgess construction)
- `WeakCanonical/`: Reynolds/Doets discrete completeness path
- `Algebraic/`: D-parametric algebraic completeness and truth lemma

## References

* [Soundness.lean](Metalogic/Soundness.lean) - Soundness proof
* [BXCanonical/Completeness.lean](Metalogic/BXCanonical/Completeness.lean) - Completeness theorem
* [Decidability.lean](Metalogic/Decidability.lean) - Decision procedure
-/
