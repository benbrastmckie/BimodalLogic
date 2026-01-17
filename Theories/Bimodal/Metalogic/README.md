# Bimodal Metalogic

This directory contains the metalogical foundations for TM (Tense and Modality) bimodal logic,
including soundness, completeness, representation theorems, and decidability.

## Current State Overview

The metalogic currently has **two parallel structures**:

1. **Working Structure** - Self-contained completeness proof in `Completeness.lean`
2. **Intended Structure** - FMP-centric modular architecture (partially implemented, has errors)

### Working Structure (Actual Dependencies)

```
         ProofSystem, Semantics
                   │
                   ▼
    ┌─────────────────────────────┐
    │         SOUNDNESS           │
    │          (PROVEN)           │
    │   Soundness/Soundness.lean  │
    └──────────────┬──────────────┘
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
┌─────────────────┐  ┌───────────────────┐
│DeductionTheorem │  │    Core/Basic     │
│    (PROVEN)     │  │    (Working)      │
└────────┬────────┘  └─────────┬─────────┘
         │                     │
         └──────────┬──────────┘
                    ▼
    ┌─────────────────────────────┐
    │     Completeness.lean       │
    │          (PROVEN)           │
    │   provable_iff_valid        │
    │   Infinite canonical model  │
    └──────────────┬──────────────┘
                   │
                   ▼
    ┌─────────────────────────────┐
    │ Completeness/               │
    │ FiniteCanonicalModel.lean   │
    │          (PROVEN)           │
    │  semantic_weak_completeness │
    └─────────────────────────────┘


         (Separate, not connected to FMP)
    ┌─────────────────────────────┐
    │      Decidability/          │
    │   DecisionProcedure.lean    │
    │   Correctness.lean          │
    │   Soundness: PROVEN         │
    │   Completeness: SORRY       │
    │   (needs FMP connection)    │
    └─────────────────────────────┘
```

### Intended Structure (FMP-Centric, from Task 523 Research)

The ideal architecture places the **Representation Theorem** at the foundation,
with **Finite Model Property (FMP)** as the central bridge enabling all downstream results:

```
                    ┌───────────────────┐
                    │   FOUNDATIONAL    │
                    │    Soundness/     │
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │      Core/        │
                    │  Basic.lean       │
                    │  Provability.lean │
                    │  DeductionThm.lean│
                    └─────────┬─────────┘
                              │
                              ▼
                 ┌────────────────────────┐
                 │  REPRESENTATION LAYER  │
                 │                        │
                 │  CanonicalModel.lean   │
                 │  TruthLemma.lean       │
                 │  RepresentationThm.lean│
                 └────────────┬───────────┘
                              │
                              ▼
                 ┌────────────────────────┐
                 │  FINITE MODEL PROPERTY │
                 │    (Central Bridge)    │
                 │       FMP.lean         │
                 └────────────┬───────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ COMPLETENESS  │    │ DECIDABILITY  │    │  COMPACTNESS  │
│               │    │               │    │               │
│ WeakComplete  │    │ DecidableValid│    │ FiniteSat→Sat │
│ StrongComplete│    │ DecisionProc  │    │               │
└───────────────┘    └───────────────┘    └───────────────┘
```

**Key Principle**: FMP is the central result that enables all three downstream theorems:
- **Completeness**: FMP ensures canonical model is finite, truth lemma works
- **Decidability**: FMP bounds search space, enables termination
- **Compactness**: FMP enables reduction to finite satisfiability

## Module Status

| Module | Status | Notes |
|--------|--------|-------|
| **Soundness/** | ✅ PROVEN | 14 axioms, 7 rules. `soundness : Γ ⊢ φ → Γ ⊨ φ` |
| **DeductionTheorem.lean** | ✅ PROVEN | `(A :: Γ) ⊢ B → Γ ⊢ A → B` |
| **Core/** | ✅ Working | Definitions: Consistent, Valid, MaximalConsistent |
| **Completeness.lean** | ✅ PROVEN | Infinite canonical model, `provable_iff_valid` |
| **Completeness/FiniteCanonicalModel** | ✅ PROVEN | `semantic_weak_completeness` |
| **Decidability/** | ⚠️ Partial | Soundness proven, completeness needs FMP |
| **Representation/** | ❌ Broken | Has compilation errors (API mismatches) |
| **Representation/FMP** | ❌ Scaffolding | Depends on broken Representation |
| **Completeness/CompletenessTheorem** | ❌ Broken | Depends on broken Representation |
| **Applications/Compactness** | ❌ Broken | Depends on broken Representation |

## Key Theorems

### Soundness (PROVEN)
Location: `Soundness/Soundness.lean`

```lean
theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ)
```

### Deduction Theorem (PROVEN)
Location: `DeductionTheorem.lean`

```lean
noncomputable def deduction_theorem (Γ : Context) (A B : Formula) :
    ((A :: Γ) ⊢ B) → (Γ ⊢ A.imp B)
```

### Completeness (PROVEN)
Location: `Completeness.lean`

```lean
theorem provable_iff_valid (φ : Formula) : Nonempty (⊢ φ) ↔ valid φ
```

The proof uses the semantic approach in `Completeness/FiniteCanonicalModel.lean`:
- `semantic_weak_completeness` - Core completeness via contrapositive (PROVEN)
- `semantic_truth_lemma_v2` - Membership equals truth (PROVEN)
- `main_provable_iff_valid` - Soundness + completeness equivalence (PROVEN)

### Decidability (PARTIAL)
Location: `Decidability/`

```lean
def decide (φ : Formula) (searchDepth tableauFuel : Nat) : DecisionResult
theorem decide_sound (φ : Formula) (proof : DerivationTree [] φ) : (⊨ φ)
```

- **Soundness**: PROVEN - decision procedure is sound when it succeeds
- **Completeness**: SORRY - requires FMP for termination bounds (not yet connected)

## Directory Structure

### Current Structure
```
Metalogic/
├── Core/                    # Foundational definitions (WORKING)
│   ├── Basic.lean          # Consistency, validity, MCS definitions
│   └── Provability.lean    # Context-based provability infrastructure
│
├── Soundness/              # Direction: Derivable → Valid (PROVEN)
│   ├── Soundness.lean      # Main soundness theorem
│   └── SoundnessLemmas.lean # Supporting lemmas
│
├── DeductionTheorem.lean   # Deduction theorem (PROVEN)
│                           # TODO: Move to Core/ per intended structure
│
├── Completeness.lean       # Infinite canonical model (PROVEN)
│                           # Self-contained, bypasses Representation/
│
├── Completeness/           # Finite canonical model approach
│   ├── CompletenessTheorem.lean   # (BROKEN - depends on Representation)
│   └── FiniteCanonicalModel.lean  # Core proven, extends Completeness.lean
│
├── Representation/         # Representation theorem infrastructure (BROKEN)
│   ├── CanonicalModel.lean        # Has API mismatch errors
│   ├── TruthLemma.lean            # Has errors
│   ├── RepresentationTheorem.lean # Has errors
│   ├── FiniteModelProperty.lean   # FMP scaffolding (has sorries)
│   └── ContextProvability.lean    # Working context provability
│
├── Decidability/           # Tableau decision procedure (PARTIAL)
│   ├── SignedFormula.lean
│   ├── Tableau.lean
│   ├── Closure.lean
│   ├── Saturation.lean
│   ├── ProofExtraction.lean
│   ├── CountermodelExtraction.lean
│   ├── DecisionProcedure.lean
│   └── Correctness.lean    # Soundness proven, completeness needs FMP
│
├── Applications/           # Applications (BROKEN)
│   └── Compactness.lean    # Depends on broken Representation
│
├── Boneyard/               # Deprecated code
│   ├── SyntacticApproach.lean    # Old syntactic completeness approach
│   └── DurationConstruction.lean # Old Duration-based construction
│
├── Decidability.lean       # Module hub for decidability
└── README.md               # This file
```

### Intended Structure (per Task 523 Research)
```
Metalogic/
├── Core/                           # Foundation definitions & theorems
│   ├── Basic.lean                  # Consistency, Validity definitions
│   ├── Provability.lean            # ContextDerivable, derivation trees
│   ├── DeductionTheorem.lean       # Proof-theoretic tool
│   └── README.md
│
├── Soundness/                      # Direction: Derivable → Valid
│   ├── Soundness.lean
│   ├── SoundnessLemmas.lean
│   └── README.md
│
├── Representation/                 # THE CENTRAL LAYER
│   ├── CanonicalModel.lean         # MCS, canonical frame construction
│   ├── TruthLemma.lean             # φ ∈ Γ ↔ M,Γ ⊨ φ
│   ├── RepresentationTheorem.lean  # Consistent → Satisfiable
│   ├── FiniteModelProperty.lean    # KEY: Satisfiable → Finite-Satisfiable
│   └── README.md
│
├── Completeness/                   # Direction: Valid → Derivable (from FMP)
│   ├── WeakCompleteness.lean       # ⊨ φ → ⊢ φ
│   ├── StrongCompleteness.lean     # Γ ⊨ φ → Γ ⊢ φ
│   └── README.md
│
├── Decidability/                   # From FMP
│   ├── Core/
│   │   ├── SignedFormula.lean
│   │   └── Branch.lean
│   ├── Tableau/
│   │   ├── Rules.lean
│   │   ├── Closure.lean
│   │   └── Saturation.lean
│   ├── Extraction/
│   │   ├── ProofExtraction.lean
│   │   └── CountermodelExtraction.lean
│   ├── DecisionProcedure.lean
│   ├── Correctness.lean            # Sound + Complete (from FMP)
│   └── README.md
│
├── Compactness/                    # From FMP
│   ├── Compactness.lean
│   └── README.md
│
├── Boneyard/                       # Deprecated code preservation
│   ├── SyntacticFiniteModel.lean
│   ├── DurationConstruction.lean
│   └── README.md
│
└── README.md
```

## Migration Path

To achieve the intended FMP-centric structure:

### Phase 1: Fix Representation Module
- Fix API mismatches in `CanonicalModel.lean` (`.toList`, `subformula_closure`)
- Verify `TruthLemma.lean` and `RepresentationTheorem.lean` compile

### Phase 2: Connect FMP to Decidability
- Complete `FiniteModelProperty.lean` proof
- Import FMP in `Decidability/Correctness.lean`
- Prove `tableau_complete` using FMP bounds

### Phase 3: Unify Completeness
- Migrate proven results from `Completeness.lean` to modular structure
- Or: Keep `Completeness.lean` as the working proof, use modular structure for pedagogical purposes

### Phase 4: Move DeductionTheorem
- Move `DeductionTheorem.lean` into `Core/`
- Update all imports

## Known Issues

1. **Representation Module Compilation Errors**:
   - `CanonicalModel.lean` uses incorrect APIs (`.toList` on Set, missing `subformula_closure`)
   - Needs refactoring to use correct Lean 4/Mathlib patterns

2. **FMP Not Connected**:
   - `FiniteModelProperty.lean` has sorries
   - Decidability completeness blocked on FMP

3. **Two Parallel Structures**:
   - `Completeness.lean` works but bypasses the modular Representation layer
   - Need to decide: unify or keep both

## Historical Notes

The completeness proof uses two parallel approaches:

1. **Syntactic Approach** (DEPRECATED): Used `FiniteWorldState` with `IsLocallyConsistent`.
   Failed due to negation-completeness issues. Documented in `Boneyard/SyntacticApproach.lean`.

2. **Semantic Approach** (CURRENT): Uses `SemanticWorldState` as quotient of (history, time) pairs.
   Works because truth is evaluated on histories directly, bypassing negation-completeness issues.

See `Boneyard/README.md` for full deprecation history and rationale.

## Usage

```lean
import Bimodal.Metalogic

open Bimodal.Metalogic
open Bimodal.Metalogic.Soundness
open Bimodal.Metalogic.Decidability

-- Soundness
#check Soundness.soundness

-- Completeness (proven)
#check provable_iff_valid

-- Decision procedure
#check decide
#check DecisionResult
```

## Building

```bash
# Build all working modules
lake build Bimodal.Metalogic

# Build specific components
lake build Bimodal.Metalogic.Soundness.Soundness
lake build Bimodal.Metalogic.Completeness
lake build Bimodal.Metalogic.Decidability

# Note: Representation/ and Applications/ will fail due to errors
```

## References

- Modal Logic, Blackburn et al. - Finite model property
- Goldblatt, Logics of Time and Computation - Temporal completeness
- Wu, M. Verified Decision Procedures for Modal Logics
- Gore, R. (1999). Tableau Methods for Modal and Temporal Logics

---

*Documentation created as part of Task 523 (Clean Up Bimodal Lean Source Files).*
*See `specs/523_bimodal_cleanup/reports/research-003.md` for full architecture analysis.*
*Last updated: 2026-01-17.*
