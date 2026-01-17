-- Metalogic_v2: Representation-First Architecture Hub Module
-- Import the top-level modules from each layer

-- FMP (includes Core, Soundness, Representation transitively)
import Bimodal.Metalogic_v2.FMP

-- Application Layers
import Bimodal.Metalogic_v2.Completeness.StrongCompleteness
import Bimodal.Metalogic_v2.Applications.Compactness

/-!
# Metalogic_v2: Representation-First Architecture

This is the top-level hub module for the Metalogic_v2 reorganization.

## Overview

Metalogic_v2 establishes a representation-first architecture where the
Finite Model Property (FMP) serves as the central bridge theorem. The
dependency structure is:

```
Core -> Soundness -> Representation -> FMP -> {Completeness, Decidability, Applications}
```

## Architecture

### Core Layer (Foundation)
- `Core/Basic.lean` - Consistency definitions
- `Core/Provability.lean` - Context-based provability
- `Core/DeductionTheorem.lean` - Deduction theorem (proven)
- `Core/MaximalConsistent.lean` - MCS theory, Lindenbaum's lemma (proven)

### Soundness Layer
- `Soundness/SoundnessLemmas.lean` - Bridge theorems for temporal duality
- `Soundness/Soundness.lean` - Soundness theorem (proven)

### Representation Layer
- `Representation/CanonicalModel.lean` - Canonical model construction
- `Representation/TruthLemma.lean` - Truth lemma
- `Representation/RepresentationTheorem.lean` - Representation theorem
- `Representation/ContextProvability.lean` - Context provability bridge
- `Representation/FiniteModelProperty.lean` - FMP statement

### FMP Bridge
- `FMP.lean` - Central hub re-exporting key theorems

### Application Layers
- `Completeness/WeakCompleteness.lean` - valid phi -> derivable phi
- `Completeness/StrongCompleteness.lean` - Gamma entails phi -> Gamma derives phi
- `Applications/Compactness.lean` - Compactness theorems

## Key Results

- `soundness`: derivable phi -> valid phi (proven)
- `set_lindenbaum`: Every consistent set extends to MCS (proven)
- `deduction_theorem`: (phi :: Gamma) derives psi -> Gamma derives (phi -> psi) (proven)
- `representation_theorem`: Consistent Gamma -> satisfiable in canonical model
- `finite_model_property`: Satisfiable -> satisfiable in finite model
- `weak_completeness`: valid phi -> derivable phi (via axiom)
- `strong_completeness`: Gamma entails phi -> Gamma derives phi

## Usage

Import this module for access to all Metalogic_v2 results.
Or import specific layers for more targeted access.

See README.md in the Metalogic_v2 directory for detailed documentation.
-/
