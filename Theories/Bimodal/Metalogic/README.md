# Bimodal Metalogic

This directory contains the metalogical foundations for TM (Tense and Modality) bimodal logic,
including soundness, completeness, representation theorems, and decidability.

## Architecture Overview

```
                    ┌───────────────────┐
                    │   SOUNDNESS       │
                    │   (PROVEN)        │
                    └─────────┬─────────┘
                              │
                              ↓
                    ┌───────────────────┐
                    │      Core/        │
                    │  Basic.lean       │
                    │  Provability.lean │
                    └─────────┬─────────┘
                              │
                              ↓
                 ┌────────────────────────┐
                 │    COMPLETENESS        │
                 │    (Completeness.lean) │
                 │    - PROVEN via        │
                 │      semantic approach │
                 └────────────┬───────────┘
                              │
                              ↓
                 ┌────────────────────────┐
                 │  FINITE MODEL PROPERTY │
                 │    (Scaffolding)       │
                 └────────────┬───────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ↓                     ↓                     ↓
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ DECIDABILITY  │    │  COMPACTNESS  │    │REPRESENTATION │
│   (PROVEN)    │    │ (Scaffolding) │    │ (Scaffolding) │
└───────────────┘    └───────────────┘    └───────────────┘
```

## Module Status

| Module | Status | Notes |
|--------|--------|-------|
| **Core/** | Working | Definitions: Consistent, Valid, MaximalConsistent |
| **Soundness/** | PROVEN | 14/14 axioms, 7/7 rules. `soundness : Γ ⊢ φ → Γ ⊨ φ` |
| **Completeness.lean** | PROVEN | Infinite canonical model approach |
| **Decidability/** | PROVEN | Tableau + proof/countermodel extraction |
| **Representation/** | Scaffolding | Has compilation errors (API mismatches) |
| **Applications/** | Scaffolding | Compactness depends on broken Representation |
| **Completeness/** | Partial | FiniteCanonicalModel has proven core, broken bridge |

## Key Theorems

### Soundness (PROVEN)
Location: `Soundness/Soundness.lean`

```lean
theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ)
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

### Decidability (PROVEN)
Location: `Decidability/`

```lean
def decide (φ : Formula) (searchDepth tableauFuel : Nat) : DecisionResult
theorem decide_sound (φ : Formula) (proof : DerivationTree [] φ) : (⊨ φ)
```

The decision procedure is sound when it succeeds. Completeness requires FMP (currently scaffolding).

## Directory Structure

```
Metalogic/
├── Core/                    # Foundational definitions
│   ├── Basic.lean          # Consistency, validity, MCS definitions
│   └── Provability.lean    # Context-based provability infrastructure
│
├── Soundness/              # Direction: Derivable → Valid
│   ├── Soundness.lean      # Main soundness theorem (PROVEN)
│   └── SoundnessLemmas.lean # Supporting lemmas (PROVEN)
│
├── Completeness.lean       # Infinite canonical model (PROVEN)
│
├── Completeness/           # Finite canonical model approach
│   ├── CompletenessTheorem.lean   # (Has errors)
│   └── FiniteCanonicalModel.lean  # Core proven, bridge sorries
│
├── Representation/         # Representation theorem infrastructure
│   ├── CanonicalModel.lean        # (Has errors - API mismatches)
│   ├── TruthLemma.lean            # (Has errors)
│   ├── RepresentationTheorem.lean # (Has errors)
│   ├── FiniteModelProperty.lean   # FMP scaffolding (has sorries)
│   └── ContextProvability.lean    # Working context provability
│
├── Decidability/           # Tableau decision procedure (PROVEN)
│   ├── SignedFormula.lean
│   ├── Tableau.lean
│   ├── Closure.lean
│   ├── Saturation.lean
│   ├── ProofExtraction.lean
│   ├── CountermodelExtraction.lean
│   ├── DecisionProcedure.lean
│   └── Correctness.lean    # Soundness proven, completeness needs FMP
│
├── Applications/           # Applications (scaffolding)
│   └── Compactness.lean    # Depends on broken Representation
│
├── DeductionTheorem.lean   # Deduction theorem infrastructure
│
├── Decidability.lean       # Module hub for decidability
└── README.md               # This file
```

## Proven vs Scaffolding

### Proven Core Results

1. **Soundness** (`Soundness/Soundness.lean`):
   - All 14 axiom validity lemmas
   - All 7 inference rule soundness cases
   - Main `soundness` theorem

2. **Completeness** (`Completeness.lean`, `Completeness/FiniteCanonicalModel.lean`):
   - `semantic_weak_completeness` - Contrapositive proof via MCS construction
   - `semantic_truth_lemma_v2` - By definition of SemanticWorldState
   - `main_provable_iff_valid` - Combining soundness and semantic completeness
   - Lindenbaum lemma via Zorn's lemma

3. **Decidability** (`Decidability/*.lean`):
   - Tableau expansion rules
   - Closure detection
   - Saturation checking
   - Proof extraction from closed tableaux
   - `decide_sound` - Soundness of decision procedure

### Scaffolding (Has Sorries or Errors)

1. **Representation Theorem** (`Representation/*.lean`):
   - Has compilation errors due to API mismatches (`.toList`, `subformula_closure`)
   - Needs refactoring to use correct Lean 4/Mathlib APIs

2. **Finite Model Property** (`Representation/FiniteModelProperty.lean`):
   - Has sorries for FMP theorem and filtration
   - Depends on broken CanonicalModel infrastructure

3. **Compactness** (`Applications/Compactness.lean`):
   - Depends on broken Representation module chain

4. **Decidability Completeness** (`Decidability/Correctness.lean`):
   - `tableau_complete` and `decide_complete` have sorries
   - Require FMP for termination bounds

## Usage

```lean
import Bimodal.Metalogic

open Bimodal.Metalogic
open Bimodal.Metalogic.Soundness
open Bimodal.Metalogic.Decidability

-- Soundness
#check Soundness.soundness

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
```

## Historical Notes

The completeness proof uses two parallel approaches:

1. **Syntactic Approach** (DEPRECATED): Used `FiniteWorldState` with `IsLocallyConsistent`.
   Failed due to negation-completeness issues. Documented in `../Boneyard/SyntacticApproach.lean`.

2. **Semantic Approach** (PREFERRED): Uses `SemanticWorldState` as quotient of (history, time) pairs.
   Works because truth is evaluated on histories directly, bypassing negation-completeness issues.

See `../Boneyard/README.md` for full deprecation history and rationale.

## Known Issues

1. **Representation Module Compilation Errors**:
   - `CanonicalModel.lean` uses incorrect APIs (`.toList` on Set, missing `subformula_closure`)
   - Needs refactoring to use correct Lean 4/Mathlib patterns

2. **FMP Sorries**:
   - `finite_model_property` theorem is scaffolding with sorries
   - Filtration construction not completed

3. **Decidability Completeness Gap**:
   - `tableau_complete` and `decide_complete` need FMP for termination bounds
   - Soundness is proven; completeness deferred until FMP is proven

## References

- Modal Logic, Blackburn et al. - Finite model property
- Goldblatt, Logics of Time and Computation - Temporal completeness
- Wu, M. Verified Decision Procedures for Modal Logics
- Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
