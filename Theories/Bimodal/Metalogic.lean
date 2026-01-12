import Bimodal.Metalogic.SoundnessLemmas
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Completeness
import Bimodal.Metalogic.Decidability

/-!
# Bimodal.Metalogic - Soundness, Completeness, and Decidability

Aggregates all metalogic components for bimodal logic TM (Tense and Modality). Provides
the foundational metalogical results: soundness, completeness infrastructure, and
tableau-based decision procedures.

## Submodules

- `SoundnessLemmas`: Bridge theorems connecting syntax and semantics, including temporal
  duality preservation and swap_past_future semantic equivalence
- `Soundness`: Main soundness theorem `Γ ⊢ φ → Γ ⊨ φ` with proofs for all 14 axioms
  and 7 inference rules
- `Completeness`: Completeness infrastructure with canonical model construction, maximal
  consistent sets, and truth lemma scaffolding (proofs in progress)
- `Decidability`: Tableau-based decision procedure returning proof terms or countermodels,
  with 8 submodules (SignedFormula, Tableau, Closure, Saturation, ProofExtraction,
  CountermodelExtraction, DecisionProcedure, Correctness)

## Status

| Component | Status | Details |
|-----------|--------|---------|
| Soundness | COMPLETE | 14/14 axioms, 7/7 rules proven |
| Completeness | PARTIAL | Canonical model defined, proofs pending |
| Decidability | COMPLETE | Tableau + proof/countermodel extraction |

## Key Theorems

- `soundness : Γ ⊢ φ → Γ ⊨ φ` - Derivability implies validity
- `decide : Formula → DecisionResult` - Returns Valid(proof) or Invalid(countermodel)
- `isValid : Formula → Bool` - Boolean validity check
- `isSatisfiable : Formula → Bool` - Boolean satisfiability check

## Usage

```lean
import Bimodal.Metalogic

open Bimodal.Metalogic
open Bimodal.Metalogic.Decidability

-- Soundness theorem
#check soundness

-- Decision procedure
#check decide
#check isValid
#check isSatisfiable
```

## References

* [SoundnessLemmas.lean](Metalogic/SoundnessLemmas.lean) - Bridge theorems
* [Soundness.lean](Metalogic/Soundness.lean) - Soundness proof
* [Completeness.lean](Metalogic/Completeness.lean) - Completeness infrastructure
* [Decidability.lean](Metalogic/Decidability.lean) - Decision procedure (8 submodules)
-/
