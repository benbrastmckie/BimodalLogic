-- Metalogic_v2: Re-export from Boneyard for backwards compatibility
-- The actual implementation has been moved to Bimodal.Boneyard.Metalogic_v2

-- FMP (includes Core, Soundness, Representation transitively)
import Bimodal.Boneyard.Metalogic_v2.FMP

-- Application Layers
import Bimodal.Boneyard.Metalogic_v2.Completeness.StrongCompleteness
import Bimodal.Boneyard.Metalogic_v2.Applications.Compactness

/-!
# DEPRECATED: Bimodal.Metalogic_v2

This module has been moved to `Bimodal.Boneyard.Metalogic_v2/` as part of the
Task 654 migration to a Universal Parametric Canonical Model approach.

**Migration Guide**:
- This file re-exports from Boneyard for backwards compatibility
- New development should use `Bimodal.Metalogic` once Task 654 completes
- The old implementation is preserved in `Bimodal.Boneyard.Metalogic_v2/` for reference

## Metalogic_v2 Architecture (Archived)

Metalogic_v2 established a representation-first architecture where the
Finite Model Property (FMP) serves as the central bridge theorem. The
dependency structure was:

```
Core -> Soundness -> Representation -> FMP -> {Completeness, Decidability, Applications}
```

## Key Results (Re-exported from Boneyard)

- `soundness`: derivable phi -> valid phi (proven)
- `set_lindenbaum`: Every consistent set extends to MCS (proven)
- `deduction_theorem`: (phi :: Gamma) derives psi -> Gamma derives (phi -> psi) (proven)
- `representation_theorem`: Consistent Gamma -> satisfiable in canonical model
- `finite_model_property`: Satisfiable -> satisfiable in finite model
- `weak_completeness`: valid phi -> derivable phi (via axiom)
- `strong_completeness`: Gamma entails phi -> Gamma derives phi
-/
