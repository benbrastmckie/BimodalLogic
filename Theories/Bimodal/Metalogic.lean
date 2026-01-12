import Bimodal.Metalogic.SoundnessLemmas
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Completeness
import Bimodal.Metalogic.Decidability

/-!
# Bimodal.Metalogic - Soundness, Completeness, and Decidability

Aggregates metalogic components for the Core TM logic layer.

## Submodules

- `SoundnessLemmas`: Bridge theorems for temporal duality soundness
- `Soundness`: Soundness theorem (Γ ⊢ φ → Γ ⊨ φ)
- `Completeness`: Completeness theorem (Γ ⊨ φ → Γ ⊢ φ) - infrastructure only
- `Decidability`: Decision procedure for TM validity

## Status

- Soundness: Complete (12/12 axioms, 8/8 rules proven)
- Completeness: Infrastructure only (canonical model defined, no proofs)
- Decidability: Tableau-based decision procedure with proof/countermodel extraction

## Usage

```lean
import Bimodal.Metalogic

open Bimodal.Metalogic

-- The soundness theorem
#check soundness

-- Decision procedure
#check Decidability.decide
```
-/
