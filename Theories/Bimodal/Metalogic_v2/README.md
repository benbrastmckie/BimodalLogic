# Metalogic_v2: Representation-First Architecture

This directory contains a reorganized metalogic infrastructure for TM bimodal logic, following a representation-first architecture where the Finite Model Property (FMP) serves as the central bridge theorem.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Application Layer                            │
├─────────────────────────────────────────────────────────────────┤
│  Completeness/           │  Applications/                       │
│  ├── WeakCompleteness    │  └── Compactness                     │
│  └── StrongCompleteness  │                                      │
└──────────────────────────┴──────────────────────────────────────┘
                              ▲
                              │ imports
                    ┌─────────┴─────────┐
                    │      FMP.lean     │
                    │   (central hub)   │
                    └─────────┬─────────┘
                              │ imports
         ┌────────────────────┼────────────────────┐
         ▼                    ▼                    ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Representation │ │    Soundness    │ │                 │
│  ├── Canonical  │ │  ├── Lemmas     │ │                 │
│  ├── TruthLemma │ │  └── Soundness  │ │                 │
│  ├── RepTheorem │ └─────────────────┘ │                 │
│  ├── ContextProv│                     │                 │
│  └── FMP        │                     │                 │
└────────┬────────┘                     │                 │
         │                              │                 │
         └──────────────────────────────┘                 │
                              │ imports                   │
                    ┌─────────┴─────────┐                 │
                    │       Core        │◄────────────────┘
                    │  ├── Basic        │
                    │  ├── Provability  │
                    │  ├── DeductionThm │
                    │  └── MaxConsistent│
                    └───────────────────┘
```

## Directory Structure

```
Metalogic_v2/
├── Core/
│   ├── Basic.lean              # Consistency definitions
│   ├── Provability.lean        # Context-based provability
│   ├── DeductionTheorem.lean   # Deduction theorem (proven)
│   └── MaximalConsistent.lean  # MCS theory, Lindenbaum (proven)
├── Soundness/
│   ├── SoundnessLemmas.lean    # Temporal duality bridge theorems
│   └── Soundness.lean          # Soundness theorem (proven)
├── Representation/
│   ├── CanonicalModel.lean     # Canonical model construction
│   ├── TruthLemma.lean         # Truth lemma
│   ├── RepresentationTheorem.lean # Representation theorem
│   ├── ContextProvability.lean # Context provability bridge
│   └── FiniteModelProperty.lean # FMP statement
├── Completeness/
│   ├── WeakCompleteness.lean   # valid -> provable
│   └── StrongCompleteness.lean # semantic consequence -> derivable
├── Applications/
│   └── Compactness.lean        # Compactness theorems
├── FMP.lean                    # Central hub (re-exports)
└── README.md                   # This file
```

## Key Theorems

### Proven (no sorry)

| Theorem | Location | Description |
|---------|----------|-------------|
| `soundness` | Soundness/Soundness.lean | Γ ⊢ φ → Γ ⊨ φ |
| `deduction_theorem` | Core/DeductionTheorem.lean | (φ :: Γ) ⊢ ψ → Γ ⊢ φ → ψ |
| `set_lindenbaum` | Core/MaximalConsistent.lean | Every consistent set extends to MCS |
| `maximal_consistent_closed` | Core/MaximalConsistent.lean | MCS is deductively closed |
| `maximal_negation_complete` | Core/MaximalConsistent.lean | φ ∉ MCS → ¬φ ∈ MCS |
| `representation_theorem` | Representation/RepresentationTheorem.lean | Consistent Γ → satisfiable in canonical |
| `mcs_contains_or_neg` | Representation/CanonicalModel.lean | φ ∈ MCS ∨ ¬φ ∈ MCS (MCS is complete) |
| `mcs_modus_ponens` | Representation/CanonicalModel.lean | MCS is closed under modus ponens |
| `representation_theorem_backward_empty` | Representation/ContextProvability.lean | ⊨ φ → ⊢ φ (via main_provable_iff_valid) |
| `weak_completeness` | Completeness/WeakCompleteness.lean | valid φ → provable φ |
| `strong_completeness` | Completeness/StrongCompleteness.lean | Γ ⊨ φ → Γ ⊢ φ |
| `necessitation_lemma` | Representation/TruthLemma.lean | Box operator preservation in MCS |
| `finite_model_property` | Representation/FiniteModelProperty.lean | FMP via satisfiability witness |
| `satisfiability_decidable` | Representation/FiniteModelProperty.lean | Decidability of satisfiability |
| `validity_decidable_via_fmp` | Representation/FiniteModelProperty.lean | Decidability of validity |

All theorems in Metalogic_v2 are fully proven with no sorry statements.

## Usage

### Import the full library

```lean
import Bimodal.Metalogic_v2
```

### Import specific layers

```lean
-- Core only
import Bimodal.Metalogic_v2.Core.MaximalConsistent

-- Soundness
import Bimodal.Metalogic_v2.Soundness.Soundness

-- FMP and downstream
import Bimodal.Metalogic_v2.FMP

-- Completeness
import Bimodal.Metalogic_v2.Completeness.WeakCompleteness
```

## Comparison with Original Metalogic/

| Aspect | Metalogic/ | Metalogic_v2/ |
|--------|------------|---------------|
| **Structure** | Flat | Layered |
| **Import cycles** | Present | Eliminated |
| **MCS definitions** | Duplicated in Completeness + Representation | Consolidated in Core |
| **Representation layer** | Imports Completeness (backwards) | Independent |
| **FMP** | Disconnected | Central bridge |
| **Deduction theorem** | Top-level | In Core layer |

## Migration Guide

### From Metalogic.Completeness

```lean
-- Old
import Bimodal.Metalogic.Completeness

-- New
import Bimodal.Metalogic_v2.Core.MaximalConsistent  -- For MCS
import Bimodal.Metalogic_v2.Completeness.WeakCompleteness  -- For completeness
```

### From Metalogic.Representation

```lean
-- Old
import Bimodal.Metalogic.Representation.CanonicalModel

-- New
import Bimodal.Metalogic_v2.Representation.CanonicalModel
```

## Future Work

1. **Add Decidability layer**: Port Decidability/ with FMP integration
2. **Constructive FMP**: Establish finite model bounds (currently using identity witness)
3. **Proof cleanup**: Remove redundant tactics and improve readability
4. **Deprecate old Metalogic/**: Complete migration and remove dependency on FiniteCanonicalModel.lean

## References

- Modal Logic, Blackburn et al., Chapter 4 (Canonical Models)
- Handbook of Modal Logic, van Benthem & Blackburn (2006)
- Task 554 Research Report: specs/554_bimodal_metalogic_v2_reorganize/reports/research-001.md
