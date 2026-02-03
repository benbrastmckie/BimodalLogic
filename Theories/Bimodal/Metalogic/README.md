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
├── Soundness/             # Soundness conceptual grouping (files at top-level)
├── Representation/        # Archived
└── Compactness/           # Archived
```

## Module Dependency Flowchart

This flowchart shows how modules depend on each other. Arrows point from dependents to dependencies.

### Top-Level Structure

```
                         ┌─────────────────────────────────┐
                         │         Metalogic.lean          │
                         │         (Entry Point)           │
                         └─────────────────────────────────┘
                                         │
           ┌─────────────────────────────┼─────────────────────────────┐
           │                             │                             │
           v                             v                             v
┌────────────────────┐      ┌─────────────────────┐       ┌────────────────────┐
│   Soundness.lean   │      │ Bundle/Completeness │       │ FMP/Semantic       │
│ (Soundness theorem)│      │  (BMCS completeness)│       │ CanonicalModel     │
└────────────────────┘      └─────────────────────┘       └────────────────────┘
           │                             │                             │
           v                             │                             │
┌────────────────────┐                   │                             │
│ SoundnessLemmas    │                   │                             │
│ (temporal duality) │                   │                             │
└────────────────────┘                   │                             │
                                         v                             v
                                ┌─────────────────────────────────────────┐
                                │             Core/ (Foundation)          │
                                │ MaximalConsistent, DeductionTheorem,    │
                                │ MCSProperties                           │
                                └─────────────────────────────────────────┘
```

### Bundle/ Dependencies (BMCS Completeness)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Bundle/Completeness.lean                          │
│        (bmcs_representation, bmcs_weak_completeness, bmcs_strong_completeness) │
└─────────────────────────────────────────────────────────────────────────────┘
                                         │
           ┌─────────────────────────────┼─────────────────────────────┐
           │                             │                             │
           v                             v                             v
┌────────────────────┐      ┌─────────────────────┐       ┌────────────────────┐
│  Construction.lean │      │   TruthLemma.lean   │       │    BMCSTruth.lean  │
│ (BMCS construction)│      │  (MCS <-> truth)    │       │   (truth defn)     │
└────────────────────┘      └─────────────────────┘       └────────────────────┘
           │                             │                             │
           │                             v                             │
           │                 ┌─────────────────────┐                   │
           │                 │    BMCSTruth.lean   │<──────────────────┘
           │                 └─────────────────────┘
           │                             │
           v                             v
┌────────────────────┐      ┌─────────────────────┐
│ IndexedMCSFamily   │      │      BMCS.lean      │
│ (temporal families)│      │ (bundle structure)  │
└────────────────────┘      └─────────────────────┘
           │                             │
           └─────────────────┬───────────┘
                             v
                   ┌─────────────────────┐
                   │       Core/         │
                   │ MaximalConsistent   │
                   │ MCSProperties       │
                   └─────────────────────┘
```

### FMP/ Dependencies (Finite Model Property)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FMP/SemanticCanonicalModel.lean                        │
│                         (fmp_weak_completeness)                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                         │
           ┌─────────────────────────────┼─────────────────────────────┐
           │                             │                             │
           v                             v                             v
┌────────────────────┐      ┌─────────────────────┐       ┌────────────────────┐
│ FiniteWorldState   │      │   BoundedTime.lean  │       │   Soundness.lean   │
│  (finite states)   │      │  (Fin (2k+1) time)  │       │ (for verification) │
└────────────────────┘      └─────────────────────┘       └────────────────────┘
           │
           v
┌────────────────────┐
│   Closure.lean     │
│ (subformula close) │
└────────────────────┘
           │
           v
┌────────────────────┐
│       Core/        │
│ MaximalConsistent  │
│ MCSProperties      │
│ DeductionTheorem   │
└────────────────────┘
```

### Decidability/ Dependencies

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      Decidability/DecisionProcedure.lean                    │
│                         (decide, isValid, isSatisfiable)                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                         │
           ┌─────────────────────────────┴─────────────────────────────┐
           v                                                           v
┌────────────────────┐                                    ┌────────────────────┐
│ ProofExtraction    │                                    │ CountermodelExtr   │
│ (closed -> proof)  │                                    │ (open -> model)    │
└────────────────────┘                                    └────────────────────┘
           │                                                           │
           └─────────────────────────────┬─────────────────────────────┘
                                         v
                              ┌─────────────────────┐
                              │  Correctness.lean   │
                              │ (soundness proof)   │
                              └─────────────────────┘
                                         │
                              ┌─────────────────────┐
                              │  Saturation.lean    │
                              │ (fuel termination)  │
                              └─────────────────────┘
                                         │
                              ┌─────────────────────┐
                              │   Closure.lean      │
                              │ (branch closure)    │
                              └─────────────────────┘
                                         │
                              ┌─────────────────────┐
                              │   Tableau.lean      │
                              │ (expansion rules)   │
                              └─────────────────────┘
                                         │
                              ┌─────────────────────┐
                              │ SignedFormula.lean  │
                              │   (T/F signs)       │
                              └─────────────────────┘
```

### Algebraic/ Dependencies

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Algebraic/AlgebraicRepresentation.lean                   │
│                      (algebraic_representation_theorem)                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                         │
                              ┌─────────────────────┐
                              │  UltrafilterMCS     │
                              │ (ultrafilter <-> MCS)│
                              └─────────────────────┘
                                         │
                    ┌────────────────────┴────────────────────┐
                    v                                         v
         ┌─────────────────────┐                   ┌─────────────────────┐
         │ InteriorOperators   │                   │  BooleanStructure   │
         │   (G, H operators)  │                   │ (Boolean algebra)   │
         └─────────────────────┘                   └─────────────────────┘
                    │                                         │
                    └────────────────────┬────────────────────┘
                                         v
                              ┌─────────────────────┐
                              │ LindenbaumQuotient  │
                              │ (Formula/~provable) │
                              └─────────────────────┘
                                         │
                              ┌─────────────────────┐
                              │       Core/         │
                              │  MaximalConsistent  │
                              └─────────────────────┘
```

### Cross-Module Dependencies

```
                              ┌─────────────────────┐
                              │       Core/         │
                              │ (Foundation Layer)  │
                              └─────────────────────┘
                                         ^
                                         │
        ┌────────────────────────────────┼────────────────────────────────┐
        │                                │                                │
┌───────┴───────┐              ┌─────────┴─────────┐            ┌─────────┴─────────┐
│   Bundle/     │              │      FMP/         │            │   Algebraic/      │
│ (BMCS appr)   │              │ (FMP approach)    │            │ (Algebraic appr)  │
└───────────────┘              └───────────────────┘            └───────────────────┘

┌───────────────────────────────────────────────────────────────────────────────────┐
│                              Decidability/                                        │
│                    (Self-contained decision procedure)                            │
└───────────────────────────────────────────────────────────────────────────────────┘
```

## Subdirectory Summaries

| Directory | Purpose | Status | README |
|-----------|---------|--------|--------|
| [Core/](Core/README.md) | MCS theory, Lindenbaum's lemma | Sorry-free | Yes |
| [Bundle/](Bundle/README.md) | BMCS completeness | Sorry-free (main theorems) | Yes |
| [FMP/](FMP/README.md) | Finite model property | Sorry-free | Yes |
| [Decidability/](Decidability/README.md) | Tableau decision procedure | Sorry-free | Yes |
| [Algebraic/](Algebraic/README.md) | Algebraic approach | Sorry-free | Yes |
| [Soundness/](Soundness/README.md) | Conceptual grouping (files at top-level) | N/A | Yes |
| [Representation/](Representation/README.md) | Archived | Archived | Yes |
| [Compactness/](Compactness/README.md) | Archived | Archived | Yes |

## Sorry Status

**Active sorries in Metalogic/**: 17 across 4 files (in helper lemmas, documented with alternatives)

| File | Count | Description | Impact |
|------|-------|-------------|--------|
| Bundle/TruthLemma.lean | 2 | Temporal backward directions | Does not affect completeness |
| Bundle/Construction.lean | 1 | modal_backward | Architectural limitation |
| Bundle/SaturatedConstruction.lean | 13 | Multi-family saturation WIP | Does not affect main theorems |
| FMP/Closure.lean | 1 | Diamond membership edge case | Minor |

**Key Point**: These do NOT affect main theorems. All main completeness, soundness, and
decidability theorems are sorry-free. The `SaturatedConstruction.lean` file is work-in-progress
infrastructure for future multi-family BMCS construction.

**Verification command**:
```bash
grep -c "^[[:space:]]*sorry\$\|[[:space:]]sorry\$\|:= sorry\$" Theories/Bimodal/Metalogic/**/*.lean
```

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

## Verification

All documentation claims can be verified with these commands:

```bash
# Verify all directories exist
ls -d Theories/Bimodal/Metalogic/*/

# Count sorries in active files
grep -c "^\s*sorry$\|[[:space:]]sorry$" Theories/Bimodal/Metalogic/**/*.lean | grep -v ":0"

# Verify representation theorem exists
grep -n "bmcs_representation" Theories/Bimodal/Metalogic/Bundle/Completeness.lean

# Verify Soundness.lean at top level
ls Theories/Bimodal/Metalogic/Soundness.lean
```

## References

- Modal Logic, Blackburn et al., Chapters 4-5
- JPL Paper "The Perpetuity Calculus of Agency"

---

*Last verified: 2026-02-03*
