import Bimodal.Metalogic.SoundnessLemmas
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Completeness
import Bimodal.Metalogic.Decidability
import Bimodal.Metalogic.RepresentationTheorems

/-!
# Bimodal.Metalogic - Soundness, Completeness, and Representation Theorems

Aggregates all metalogic components for bimodal logic TM (Tense and Modality). Provides
the foundational metalogical results: representation theorems, soundness, completeness, and
decidability procedures.

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
- `RepresentationTheorems`: Systematic refactor architecture establishing representation theorems
  as the foundation for all metalogical results, with set-based provability and
  context-sensitive completeness

## Status

| Component | Status | Details |
|-----------|--------|---------|
| Soundness | COMPLETE | 14/14 axioms, 7/7 rules proven |
| Completeness | PARTIAL | Canonical model defined, proofs pending |
| Decidability | COMPLETE | Tableau + proof/countermodel extraction |
| Representation Theorems | IMPLEMENTED | Set-based provability, architecture foundation |

## Key Theorems

- `SetDerivable Γ φ`: Set-based provability with finite subset requirement
- `entails Γ φ`: Context-sensitive semantic entailment 
- `representation_theorem`: Bridge between syntax and semantics (scaffold)
- `general_completeness`: Context-sensitive completeness for empty/finite/infinite Γ
- `soundness : Γ ⊢ φ → Γ ⊨ φ` - Derivability implies validity
- `decide : Formula → DecisionResult` - Returns Valid(proof) or Invalid(countermodel)
- `isValid : Formula → Bool` - Boolean validity check
- `isSatisfiable : Formula → Bool` - Boolean satisfiability check

## Architecture

Based on Task 499 research, the representation theorem approach eliminates circular dependencies:

1. **Representation Theorem** (Primary): SetDerivable Γ φ ↔ ∃ concrete model
2. **General Completeness** (Derived): entails Γ φ → SetDerivable Γ φ  
3. **Finite Model Property** (Derived): From representation theorem
4. **Decidability** (Derived): From FMP + bounded search

## Usage

```lean
import Bimodal.Metalogic

open Bimodal.Metalogic
open Bimodal.Metalogic.Representation
open Bimodal.Metalogic.Decidability

-- Representation theorem foundation
#check SetDerivable
#check entails
#check general_completeness

-- Classical theorems
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
* [RepresentationTheorems.lean](Metalogic/RepresentationTheorems.lean) - Systematic refactor architecture
-/
