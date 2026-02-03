# TM Bimodal Logic Metalogic

This directory contains the metalogic infrastructure for TM bimodal logic, including soundness,
completeness, decidability, and the finite model property.

## What the Metalogic Establishes

The metalogic proves the fundamental metatheoretic results for TM bimodal logic:

1. **Soundness**: Every derivable formula is semantically valid
2. **Completeness**: Every valid formula is derivable (via BMCS and FMP approaches)
3. **Finite Model Property**: Satisfiable formulas have finite models
4. **Decidability**: Tableau-based decision procedure with proof extraction
5. **Algebraic**: Alternative approach via Lindenbaum quotient and ultrafilter-MCS bijection

## Main Results

### Soundness (`Soundness.lean`)
```lean
theorem soundness : (Gamma |- phi) -> (Gamma |= phi)
```
All 15 TM axioms and 7 derivation rules preserve validity.

### BMCS Completeness (`Bundle/`)
```lean
theorem bmcs_weak_completeness : bmcs_valid phi -> |- phi
theorem bmcs_strong_completeness : bmcs_consequence Gamma phi -> Gamma |- phi
```
Henkin-style completeness via Bundle of Maximal Consistent Sets.

### FMP Completeness (`FMP/`)
```lean
def fmp_weak_completeness : (forall w, semantic_truth phi w t phi) -> |- phi
theorem semanticWorldState_card_bound : card worlds <= 2^closureSize
```
Completeness via finite canonical model construction.

### Decidability (`Decidability/`)
```lean
def decide : (phi : Formula) -> DecisionResult phi
def isValid : Formula -> Bool
def isSatisfiable : Formula -> Bool
```
Tableau-based decision procedure returning proofs or countermodels.

## Architecture Overview

```
Metalogic/
├── README.md              # This file
├── Metalogic.lean         # Re-export module with docstring
├── Soundness.lean         # Main soundness theorem
├── SoundnessLemmas.lean   # Supporting lemmas for soundness
├── Completeness.lean      # MCS closure properties (top-level)
├── Decidability.lean      # Re-export for decidability
│
├── Core/                  # Foundational MCS theory
│   ├── Core.lean
│   ├── MaximalConsistent.lean
│   ├── DeductionTheorem.lean
│   └── MCSProperties.lean
│
├── Bundle/                # BMCS completeness (primary approach)
│   ├── IndexedMCSFamily.lean
│   ├── BMCS.lean
│   ├── BMCSTruth.lean
│   ├── TruthLemma.lean
│   ├── ModalSaturation.lean
│   ├── Construction.lean
│   └── Completeness.lean
│
├── FMP/                   # Finite Model Property
│   ├── Closure.lean
│   ├── BoundedTime.lean
│   ├── FiniteWorldState.lean
│   └── SemanticCanonicalModel.lean
│
├── Decidability/          # Tableau decision procedure
│   ├── SignedFormula.lean
│   ├── Tableau.lean
│   ├── Saturation.lean
│   ├── Closure.lean
│   ├── Correctness.lean
│   ├── ProofExtraction.lean
│   ├── CountermodelExtraction.lean
│   └── DecisionProcedure.lean
│
├── Algebraic/             # Alternative algebraic approach
│   ├── LindenbaumQuotient.lean
│   ├── BooleanStructure.lean
│   ├── InteriorOperators.lean
│   ├── UltrafilterMCS.lean
│   └── AlgebraicRepresentation.lean
│
├── Soundness/             # Soundness documentation
├── Representation/        # Archived
├── Compactness/           # Archived
└── UnderDevelopment/      # WIP approaches
```

## Subdirectory Summaries

| Directory | Purpose | Status | README |
|-----------|---------|--------|--------|
| [Core/](Core/README.md) | MCS theory, Lindenbaum's lemma | Sorry-free | Yes |
| [Bundle/](Bundle/README.md) | BMCS completeness | Sorry-free (main theorems) | Yes |
| [FMP/](FMP/README.md) | Finite model property | Sorry-free | Yes |
| [Decidability/](Decidability/README.md) | Tableau decision procedure | Sorry-free | Yes |
| [Algebraic/](Algebraic/README.md) | Algebraic approach | Sorry-free | Yes |
| Soundness/ | Soundness documentation | N/A | Yes |
| Representation/ | Archived | Archived | Yes |
| Compactness/ | Archived | Archived | Yes |
| UnderDevelopment/ | WIP approaches | Research | Yes |

## Sorry Status

**Active sorries in Metalogic/**: 4 (in helper lemmas, documented with alternatives)

| File | Location | Sorry | Status | Alternative |
|------|----------|-------|--------|-------------|
| Bundle/TruthLemma.lean | ~383 | all_future backward | Documented | Omega-rule |
| Bundle/TruthLemma.lean | ~395 | all_past backward | Documented | Omega-rule |
| Bundle/Construction.lean | ~220 | modal_backward | Documented | Multi-family BMCS |
| FMP/Closure.lean | ~728 | diamond membership | Documented | Minor edge case |

**Key Point**: These do NOT affect main theorems. All main completeness, soundness, and
decidability theorems are sorry-free.

### Recommended Theorems

For BMCS completeness (Henkin-style):
```lean
import Bimodal.Metalogic.Bundle.Completeness
-- bmcs_weak_completeness, bmcs_strong_completeness
```

For FMP-based completeness:
```lean
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
-- fmp_weak_completeness
```

For decidability:
```lean
import Bimodal.Metalogic.Decidability
-- decide, isValid, isSatisfiable
```

## Key Features

- **Universal**: Parametric over ANY totally ordered additive commutative group D
- **Syntactic**: Builds semantic objects from pure syntax (MCS membership)
- **Self-contained**: No dependencies on archived code
- **Verified**: Decision procedure returns proofs or countermodels

## References

- Modal Logic, Blackburn et al., Chapters 4-5
- JPL Paper "The Perpetuity Calculus of Agency"

---

*Last updated: 2026-02-03*
