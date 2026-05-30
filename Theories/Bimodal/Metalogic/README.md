# TM Bimodal Logic Metalogic

This directory contains the metalogic infrastructure for TM bimodal logic, including soundness,
completeness, decidability, and the finite model property.

## What the Metalogic Establishes

The metalogic proves the fundamental metatheoretic results for TM bimodal logic:

1. **Soundness**: Every derivable formula is semantically valid
2. **Completeness**: Every valid formula is derivable (via BFMCS approach)
3. **Decidability**: Tableau-based decision procedure with proof extraction
4. **Algebraic**: Alternative approach via Lindenbaum quotient and ultrafilter-MCS bijection

## Main Results

### Soundness (`Soundness.lean`)
```lean
theorem soundness : (Gamma |- phi) -> (Gamma |= phi)
```
All 42 TM axiom constructors (covering Base, Dense, and Discrete frame classes) and 7 derivation rules preserve validity.

### BFMCS Completeness (`Bundle/`)
```lean
theorem bmcs_weak_completeness : bmcs_valid phi -> |- phi
theorem bmcs_strong_completeness : bmcs_consequence Gamma phi -> Gamma |- phi
```
Henkin-style completeness via Bundle of Maximal Consistent Sets.

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
├── WeakCanonical.lean     # Re-export for WeakCanonical
├── Soundness.lean         # Main soundness theorem
├── DenseSoundness.lean    # Dense variant soundness
├── DiscreteSoundness.lean # Discrete variant soundness
├── Completeness.lean      # MCS closure properties (top-level)
├── Decidability.lean      # Re-export for decidability
│
├── SoundnessLemmas/       # Supporting lemmas for soundness
│   ├── Core.lean
│   ├── DenseValidity.lean
│   └── FrameClassVariants.lean
│
├── Core/                  # Foundational MCS theory
│   ├── Core.lean
│   ├── MaximalConsistent.lean
│   ├── DeductionTheorem.lean
│   ├── MCSProperties.lean
│   └── RestrictedMCS/     # MCS restricted to subformula closure
│
├── Bundle/                # BFMCS completeness (primary approach)
│   ├── FMCSDef.lean
│   ├── FMCS.lean
│   ├── BFMCS.lean
│   ├── TemporalCoherence.lean
│   ├── TemporalContent.lean
│   ├── ModalSaturation.lean
│   ├── WitnessSeed.lean
│   ├── CanonicalFrame.lean
│   ├── CanonicalTaskRelation.lean
│   ├── CanonicalIrreflexivity.lean
│   ├── SuccRelation.lean
│   ├── SuccExistence.lean
│   ├── UntilSinceCoherence.lean
│   └── Construction.lean
│
├── Decidability/          # Tableau decision procedure
│   ├── SignedFormula.lean
│   ├── Tableau.lean
│   ├── Saturation.lean
│   ├── Closure.lean
│   ├── Correctness.lean
│   ├── ProofExtraction.lean
│   ├── CountermodelExtraction.lean
│   ├── FMP.lean           # Re-export for FMP
│   ├── DecisionProcedure.lean
│   └── FMP/               # Finite model property (7 files)
│
├── Algebraic/             # Alternative algebraic approach
│   ├── LindenbaumQuotient.lean
│   ├── BooleanStructure.lean
│   ├── InteriorOperators.lean
│   ├── UltrafilterMCS.lean
│   ├── AlgebraicCompleteness.lean
│   ├── ParametricCanonical.lean
│   ├── ParametricHistory.lean
│   ├── ParametricTruthLemma.lean
│   ├── ParametricCompleteness.lean
│   └── RestrictedParametricTruthLemma.lean
│
├── BXCanonical/           # Burgess 1982 chronicle completeness
│   ├── Chronicle/         # Dense chronicle construction (7 files)
│   ├── Quasimodel/        # Quasimodel intermediate (6 files)
│   ├── Filtration/        # Filtration for FMP (1 file)
│   └── Completeness.lean  # Main completeness wiring
│
├── WeakCanonical/         # Weak/reflexive completeness (Henkin canonical model)
│   ├── EFGames/           # EF bisimulation games (9 files)
│   ├── ExpressiveCompleteness/ # Expressive completeness (2 files)
│   ├── Expressiveness/    # Separation results (5 files)
│   ├── IntegerModel/      # Integer witness model (3 files)
│   └── Separation/        # Separation theorem (11+ files)
│
├── ConservativeExtension/ # Conservative extension results
│
└── Relational/            # Relational semantics (placeholder)
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
│   Soundness.lean   │      │ Bundle/Construction │       │   Decidability/    │
│ (Soundness theorem)│      │ (BFMCS completeness)│       │ DecisionProcedure  │
└────────────────────┘      └─────────────────────┘       └────────────────────┘
           │                             │
           v                             │
┌────────────────────┐                   │
│ SoundnessLemmas    │                   │
│ (temporal duality) │                   │
└────────────────────┘                   │
                                         v
                                ┌─────────────────────────────────────────┐
                                │             Core/ (Foundation)          │
                                │ MaximalConsistent, DeductionTheorem,    │
                                │ MCSProperties                           │
                                └─────────────────────────────────────────┘
```

### Bundle/ Dependencies (BFMCS Completeness)

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
│  Construction.lean │      │   TruthLemma.lean   │       │    BFMCSTruth.lean  │
│ (BFMCS construction)│      │  (MCS <-> truth)    │       │   (truth defn)     │
└────────────────────┘      └─────────────────────┘       └────────────────────┘
           │                             │                             │
           │                             v                             │
           │                 ┌─────────────────────┐                   │
           │                 │    BFMCSTruth.lean   │<──────────────────┘
           │                 └─────────────────────┘
           │                             │
           v                             v
┌────────────────────┐      ┌─────────────────────┐
│ FMCS   │      │      BFMCS.lean      │
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
│                    Algebraic/AlgebraicCompleteness.lean                   │
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
        │                                                                 │
┌───────┴───────┐                                               ┌─────────┴─────────┐
│   Bundle/     │                                               │   Algebraic/      │
│ (BFMCS appr)  │                                               │ (Algebraic appr)  │
└───────────────┘                                               └───────────────────┘

┌───────────────────────────────────────────────────────────────────────────────────┐
│                              Decidability/                                        │
│                    (Self-contained decision procedure)                            │
└───────────────────────────────────────────────────────────────────────────────────┘
```

## Subdirectory Summaries

| Directory | Purpose | Status | README |
|-----------|---------|--------|--------|
| [Core/](Core/README.md) | MCS theory, Lindenbaum's lemma | Sorry-free | Yes |
| [Bundle/](Bundle/README.md) | BFMCS completeness infrastructure | Sorry-free (main theorems) | Yes |
| [BXCanonical/](BXCanonical/README.md) | Burgess 1982 chronicle completeness | Active | Yes |
| [WeakCanonical/](WeakCanonical/README.md) | Weak/reflexive completeness (Henkin) | Active | Yes |
| [SoundnessLemmas/](SoundnessLemmas/README.md) | Supporting soundness lemmas | Sorry-free | Yes |
| [Decidability/](Decidability/README.md) | Tableau decision procedure | Sorry-free | Yes |
| [Algebraic/](Algebraic/README.md) | Algebraic approach | Sorry-free | Yes |
| [ConservativeExtension/](ConservativeExtension/README.md) | Conservative extension | Active | Yes |
| [Relational/](Relational/README.md) | Relational semantics (placeholder) | Empty | Yes |

## Sorry Status

**Active sorries in Metalogic/**: See Bundle/README.md for current sorry counts.

| File | Count | Description | Impact |
|------|-------|-------------|--------|
| Bundle/*.lean | Various | See Bundle/README.md | Main theorems sorry-free |

**Key Point**: The main completeness, soundness, and decidability theorems are sorry-free.
See individual module READMEs for detailed sorry status.

**Verification command**:
```bash
grep -c "^[[:space:]]*sorry\$\|[[:space:]]sorry\$\|:= sorry\$" Theories/Bimodal/Metalogic/**/*.lean
```

### Recommended Theorems

For BFMCS completeness (Henkin-style):
```lean
import Bimodal.Metalogic.Bundle.Construction
-- BFMCS completeness infrastructure
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

## Related Documentation

- [Parent README](../README.md)
- [Core README](Core/README.md)
- [Bundle README](Bundle/README.md)
- [Decidability README](Decidability/README.md)
- [BXCanonical README](BXCanonical/README.md)
- [WeakCanonical README](WeakCanonical/README.md)
- [SoundnessLemmas README](SoundnessLemmas/README.md)
- [Algebraic README](Algebraic/README.md)

## References

- Modal Logic, Blackburn et al., Chapters 4-5
- JPL Paper "The Perpetuity Calculus of Agency"

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.
