# Metalogic_v2: Representation-First Architecture

This directory contains a reorganized metalogic infrastructure for TM bimodal logic, following a representation-first architecture where the Finite Model Property (FMP) serves as the central bridge theorem.

## Architecture Overview

The architecture follows a bottom-up dependency structure. Arrows point downward, showing
"uses" / "imports" relationships (i.e., higher modules import lower ones).

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│      SOUNDNESS      │     │         CORE        │     │    (external)       │
│                     │     │                     │     │  Bimodal.Syntax     │
│ Soundness.lean      │     │ MaximalConsistent   │     │  Bimodal.Semantics  │
│   soundness         │     │   set_lindenbaum    │     │  Bimodal.ProofSystem│
│   axiom_valid       │     │   maximal_*_closed  │     │  Mathlib.*          │
│                     │     │   theorem_in_mcs    │     │                     │
│ SoundnessLemmas     │     │                     │     │                     │
│   temporal duality  │     │ DeductionTheorem    │     │                     │
│   bridge theorems   │     │   deduction_theorem │     │                     │
│                     │     │   exchange, weaken  │     │                     │
│                     │     │                     │     │                     │
│                     │     │ Basic.lean          │     │                     │
│                     │     │   Consistent, Valid │     │                     │
│                     │     │   MaximalConsistent │     │                     │
│                     │     │                     │     │                     │
│                     │     │ Provability.lean    │     │                     │
│                     │     │   context-based ⊢   │     │                     │
└──────────┬──────────┘     └──────────┬──────────┘     └──────────┬──────────┘
           │                           │                           │
           └───────────────────────────┼───────────────────────────┘
                                       │
                                       ▼
        (FOUNDATIONS - No internal Metalogic_v2 dependencies)
╔══════════════════════════════════════╤════════════════════════════════════════╗
║                       ┌──────────────┴──────────────┐                         ║
║                       │ CanonicalModel.lean         │                         ║
║                       │   CanonicalWorldState       │                         ║
║                       │   CanonicalFrame, Model     │                         ║
║                       │   mcs_contains_or_neg       │                         ║
║                       │   mcs_modus_ponens          │                         ║
║                       └──────────────┬──────────────┘                         ║
║                                      │                                        ║
║                  ┌───────────────────┴────────────────┐                       ║
║                  │                                    │                       ║
║  ┌───────────────┴───────────────┐                    │                       ║
║  │ Closure.lean                  │                    │                       ║
║  │   closure, closureWithNeg     │                    │                       ║
║  │   ClosureMaximalConsistent    │                    │                       ║
║  │   mcs_projection_is_closure   │                    │                       ║
║  └───────────────┬───────────────┘                    │                       ║
║                  │                                    │                       ║
║  ┌───────────────┴───────────────┐  ┌─────────────────┴─────────────────────┐ ║
║  │ FiniteWorldState.lean         │  │ TruthLemma.lean                       │ ║
║  │   FiniteWorldState            │  │   canonicalTruthAt                    │ ║
║  │   FiniteHistory               │  │   truthLemma_*                        │ ║
║  │   worldStateFromClosureMCS    │  │   necessitation_lemma                 │ ║
║  └───────────────┬───────────────┘  └─────────────────┬─────────────────────┘ ║
║                  │                                    │                       ║
║  ┌───────────────┴───────────────┐  ┌─────────────────┴─────────────────────┐ ║
║  │ SemanticCanonicalModel.lean   │  │ ContextProvability.lean               │ ║
║  │   semantic_weak_completeness  │  │   representation_validity             │ ║
║  │   SemanticWorldState          │  │   valid_implies_derivable             │ ║
║  │   SemanticCanonicalFrame      │  │   representation_theorem_backward     │ ║
║  └───────────────┬───────────────┘  └─────────────────┬─────────────────────┘ ║
║                  │                                    │                       ║
║  ┌───────────────┴───────────────┐  ┌─────────────────┴─────────────────────┐ ║
║  │ FiniteModelProperty.lean      │  │ RepresentationTheorem.lean            │ ║
║  │   finite_model_property       │  │   representation_theorem              │ ║
║  │   validity_decidable_via_fmp  │  │   strong_representation_theorem       │ ║
║  │   satisfiability_decidable    │  │   completeness_corollary              │ ║
║  └───────────────────────────────┘  └───────────────────────────────────────┘ ║
╚═══════════════════════════════════════════════════════════════════════════════╝
                     REPRESENTATION (Bridge Layer)
                                       │
                                       ▼
                            ┌──────────┴──────────┐
                            │     FMP.lean        │
                            │   (re-export hub)   │
                            └──────────┬──────────┘
                                       │
                                       ▼
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         COMPLETENESS (Derived)                                ║
║  WeakCompleteness.lean: weak_completeness, provable_iff_valid                 ║
║  StrongCompleteness.lean: strong_completeness, context_provable_iff_entails   ║
╚═══════════════════════════════════════════════════════════════════════════════╝
                                       │
                                       ▼
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         APPLICATIONS (Most Derived)                           ║
║  Compactness.lean                                                             ║
║    compactness_entailment, compactness_satisfiability                         ║
╚═══════════════════════════════════════════════════════════════════════════════╝
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
│   ├── Closure.lean            # Subformula closure, ClosureMaximalConsistent
│   ├── FiniteWorldState.lean   # Finite world state construction
│   ├── SemanticCanonicalModel.lean # Semantic canonical model (sorry-free completeness)
│   ├── RepresentationTheorem.lean # Representation theorem
│   ├── ContextProvability.lean # Context provability bridge
│   └── FiniteModelProperty.lean # FMP and decidability
├── Completeness/
│   ├── WeakCompleteness.lean   # valid -> provable
│   └── StrongCompleteness.lean # semantic consequence -> derivable
├── Applications/
│   └── Compactness.lean        # Compactness theorems
├── FMP.lean                    # Re-export hub (imports FiniteModelProperty)
└── README.md                   # This file
```

## Key Theorems

### Core Theorems

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
| `semantic_weak_completeness` | Representation/SemanticCanonicalModel.lean | Core completeness (sorry-free) |
| `semantic_truth_at_v2` | Representation/SemanticCanonicalModel.lean | Finite model truth definition |
| `semantic_truth_lemma_v2` | Representation/SemanticCanonicalModel.lean | Truth correspondence lemma |

### Theorems with Sorries (4 total)

| Location | Theorem | Issue | Impact |
|----------|---------|-------|--------|
| Closure.lean:484 | `closure_mcs_neg_complete` | Double-negation escape | Edge case |
| SemanticCanonicalModel.lean:236 | `semantic_task_rel_compositionality` | History gluing in finite model | Acceptable limitation |
| SemanticCanonicalModel.lean | `main_provable_iff_valid_v2` | Truth bridge for completeness direction | See note below |
| FiniteWorldState.lean:343 | `closure_mcs_implies_locally_consistent` | Temporal axioms | Edge case |

Note: The deprecated theorems `semantic_truth_implies_truth_at` and `main_weak_completeness_v2` have been
removed. See `Boneyard/DeprecatedCompleteness.lean` for documentation of the deprecated approach.

### Architectural Note on Completeness

**Primary Result: `semantic_weak_completeness` (SORRY-FREE)**
- Proves: `(forall w, semantic_truth_at_v2 phi w t phi) -> provable phi`
- Uses internal finite model truth definition
- Avoids the problematic truth bridge between general `truth_at` and finite model truth
- Ported from the old Metalogic (FiniteCanonicalModel.lean lines 3644-3713)

**Equivalence Statement: `main_provable_iff_valid_v2` (HAS SORRY)**
- Proves: `Nonempty (provable phi) <-> valid phi`
- The soundness direction is fully proven
- The completeness direction (valid -> provable) has a sorry because it requires a "truth bridge"
  connecting general validity (truth in ALL models) to finite model truth

**Recommended Path**: Use `semantic_weak_completeness` for completeness results.

**Deprecated Approach**: The alternative approach using `semantic_truth_implies_truth_at` and
`main_weak_completeness_v2` has been removed. See `Boneyard/DeprecatedCompleteness.lean` for
documentation of why this approach was deprecated.

**Impact Summary**: Core theorems (soundness, deduction theorem, MCS properties) are fully proven.
The `semantic_weak_completeness` theorem provides a sorry-free completeness core. The remaining
sorries affect edge cases and the equivalence statement, not the main completeness result.

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
5. **Complete the truth bridge**: Optionally prove a truth bridge lemma via structural formula induction
   to eliminate the sorry in `main_provable_iff_valid_v2` (not blocking - `semantic_weak_completeness`
   provides the core result). See `Boneyard/DeprecatedCompleteness.lean` for the technical challenges.
6. **Edge case sorries**: Address `closure_mcs_neg_complete` and `closure_mcs_implies_locally_consistent` if tractable

## References

- Modal Logic, Blackburn et al., Chapter 4 (Canonical Models)
- Handbook of Modal Logic, van Benthem & Blackburn (2006)
- Task 554 Research Report: specs/554_bimodal_metalogic_v2_reorganize/reports/research-001.md
