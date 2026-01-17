# Bimodal Metalogic

This directory contains the metalogical foundations for TM (Tense and Modality) bimodal logic,
including soundness, completeness, representation theorems, and decidability.

## Current State Overview

The metalogic has been **unified** following the Task 540 refactor (2026-01-17):

1. **Working Structure** - Self-contained completeness proof in `Completeness.lean` (PROVEN)
2. **Applications Layer** - `CompletenessTheorem.lean` and `Compactness.lean` that re-export theorems
3. **Representation Layer** - Compiles with sorries (9 total), provides scaffolding for FMP-centric approach

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
         ┌─────────┴─────────────┐
         ▼                       ▼
┌───────────────────────┐  ┌───────────────────────┐
│ Completeness/         │  │ CompletenessTheorem   │
│ FiniteCanonicalModel  │  │ (WORKING)             │
│ (PROVEN)              │  │ Re-exports weak/strong│
│ weak_completeness     │  │ completeness          │
└───────────────────────┘  └───────────┬───────────┘
                                       │
                           ┌───────────┴───────────┐
                           ▼                       ▼
                   ┌───────────────┐       ┌───────────────┐
                   │ Compactness   │       │Representation/│
                   │ (WORKING)     │       │ (PARTIAL)     │
                   │ Finite sat→   │       │ 9 sorries     │
                   │ Satisfiable   │       │               │
                   └───────────────┘       └───────────────┘


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
| **Soundness/** | PROVEN | 14 axioms, 7 rules. `soundness : Γ ⊢ φ → Γ ⊨ φ` |
| **DeductionTheorem.lean** | PROVEN | `(A :: Γ) ⊢ B → Γ ⊢ A → B` |
| **Core/** | WORKING | Definitions: Consistent, Valid, MaximalConsistent |
| **Completeness.lean** | PROVEN | Infinite canonical model, `provable_iff_valid` |
| **Completeness/FiniteCanonicalModel** | PROVEN | `semantic_weak_completeness` |
| **Completeness/CompletenessTheorem** | WORKING | Re-exports weak/strong completeness theorems |
| **Applications/Compactness** | WORKING | Compactness theorem via FMP connection |
| **Decidability/** | PARTIAL | Soundness proven, completeness needs FMP |
| **Representation/CanonicalModel** | PARTIAL | Compiles with 2 sorries |
| **Representation/TruthLemma** | PARTIAL | Compiles with 2 sorries |
| **Representation/RepresentationTheorem** | PARTIAL | Compiles with 4 sorries |
| **Representation/FiniteModelProperty** | PARTIAL | Compiles with 1 sorry |

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
│                           # Self-contained completeness proof
│
├── Completeness/           # Finite canonical model approach
│   ├── CompletenessTheorem.lean   # (WORKING) Re-exports completeness theorems
│   └── FiniteCanonicalModel.lean  # Core proven, extends Completeness.lean
│
├── Representation/         # Representation theorem infrastructure (PARTIAL - 9 sorries)
│   ├── CanonicalModel.lean        # Compiles with 2 sorries
│   ├── TruthLemma.lean            # Compiles with 2 sorries
│   ├── RepresentationTheorem.lean # Compiles with 4 sorries
│   ├── FiniteModelProperty.lean   # FMP scaffolding (1 sorry)
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
├── Applications/           # Applications (WORKING)
│   └── Compactness.lean    # Compactness theorem
│
├── Decidability.lean       # Module hub for decidability
└── README.md               # This file

# Note: Deprecated code is in Bimodal/Boneyard/ (sibling directory):
# Theories/Bimodal/Boneyard/
# ├── SyntacticApproach.lean    # Old syntactic completeness approach
# ├── DurationConstruction.lean # Old Duration-based construction
# └── README.md                 # Deprecation history
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

1. **Representation Module Has Sorries** (9 total):
   - `CanonicalModel.lean`: 2 sorries (canonical model construction details)
   - `TruthLemma.lean`: 2 sorries (truth lemma proof steps)
   - `RepresentationTheorem.lean`: 4 sorries (theorem proof steps)
   - `FiniteModelProperty.lean`: 1 sorry (FMP bound proof)
   - All modules compile successfully; sorries are proof obligations not API errors

2. **FMP Not Connected to Decidability**:
   - `FiniteModelProperty.lean` provides FMP scaffolding
   - Decidability completeness still blocked on FMP proof completion

3. **Dual Architecture** (intentional):
   - `Completeness.lean` provides self-contained working completeness proof
   - `Representation/` provides modular scaffolding for future FMP-centric proofs
   - Both approaches are maintained for different use cases

## Historical Notes

The completeness proof uses two parallel approaches:

1. **Syntactic Approach** (DEPRECATED): Used `FiniteWorldState` with `IsLocallyConsistent`.
   Failed due to negation-completeness issues. Documented in `../Boneyard/SyntacticApproach.lean`.

2. **Semantic Approach** (CURRENT): Uses `SemanticWorldState` as quotient of (history, time) pairs.
   Works because truth is evaluated on histories directly, bypassing negation-completeness issues.

See `Theories/Bimodal/Boneyard/README.md` for full deprecation history and rationale.

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
