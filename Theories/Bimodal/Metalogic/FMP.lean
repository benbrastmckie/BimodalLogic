import Bimodal.Metalogic.FMP.Closure
import Bimodal.Metalogic.FMP.BoundedTime
import Bimodal.Metalogic.FMP.FiniteWorldState
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
import Bimodal.Metalogic.FMP.SemanticTaskFrame
import Bimodal.Metalogic.FMP.FiniteModelProperty

/-!
# Parametric Finite Model Property Infrastructure

This module aggregates the FMP infrastructure for the parametric architecture.

## Overview

The Finite Model Property (FMP) establishes that if a formula is satisfiable,
it is satisfiable in a finite model with bounded size. The key insight is that
the cardinality bound (2^closureSize) is purely combinatorial - independent of
any specific duration type.

## Submodules

- `Closure.lean`: Subformula closure and closure-maximal consistent sets
- `BoundedTime.lean`: Finite time domain with 2k+1 elements
- `FiniteWorldState.lean`: Finite world states as truth assignments on closure
- `SemanticCanonicalModel.lean`: Semantic canonical model construction
- `FiniteModelProperty.lean`: FMP theorem and cardinality bounds

## Main Results

- `finite_model_property`: If φ satisfiable → φ has finite model
- `finite_model_property_constructive`: With explicit 2^closureSize bound
- `semantic_weak_completeness`: (∀ w, truth w φ) → ⊢ φ (sorry-free)
- `semanticWorldState_card_bound`: |worlds| ≤ 2^closureSize

## Known Sorries

- `SemanticCanonicalFrame.compositionality`: Mathematically false for unbounded
  durations in bounded time domain. Not needed for core completeness.
- `finite_model_property_constructive` truth bridge: Connecting finite model
  truth to general `truth_at`. Use `semantic_weak_completeness` instead.

## Architecture

This is the parametric port of `Boneyard/Metalogic_v2/Representation/` FMP modules.
The key design change is using `BoundedTime k` (= `Fin (2*k+1)`) as the time domain,
which is combinatorially defined independent of the duration type.

## Usage

For completeness proofs, prefer `semantic_weak_completeness` which avoids the
truth bridge sorry. For decidability analysis, use `semanticWorldState_card_bound`
which provides the explicit 2^closureSize bound.

## References

- Blackburn et al., Modal Logic, Chapter 4 (Finite Model Property)
-/

namespace Bimodal.Metalogic.FMP

-- Re-export key definitions
open Bimodal.Metalogic.FMP

end Bimodal.Metalogic.FMP
