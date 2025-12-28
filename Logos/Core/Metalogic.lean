import Logos.Core.Metalogic.SoundnessLemmas
import Logos.Core.Metalogic.Soundness
import Logos.Core.Metalogic.Completeness

/-!
# Logos.Core.Metalogic - Soundness and Completeness

Aggregates metalogic components for the Core TM logic layer.

## Submodules

- `SoundnessLemmas`: Bridge theorems for temporal duality soundness
- `Soundness`: Soundness theorem (Γ ⊢ φ → Γ ⊨ φ)
- `Completeness`: Completeness theorem (Γ ⊨ φ → Γ ⊢ φ) - infrastructure only

## Status

- Soundness: Complete (12/12 axioms, 8/8 rules proven)
- Completeness: Infrastructure only (canonical model defined, no proofs)

## Usage

```lean
import Logos.Core.Metalogic

open Logos.Core.Metalogic

-- The soundness theorem
#check soundness
```
-/
