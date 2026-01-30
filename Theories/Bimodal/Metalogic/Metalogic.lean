-- Metalogic: TM Bimodal Logic Metalogic Infrastructure
-- Self-contained (no Boneyard dependencies)

-- Core metalogic infrastructure (includes all subdirectory dependencies)
import Bimodal.Metalogic.FMP
import Bimodal.Metalogic.Completeness.Completeness
-- Compactness archived to Boneyard/Metalogic_v4/ (Task 772)
-- It depended on infinitary strong completeness which uses sorried representation theorem
-- Optional extension: Alternative algebraic approach
-- import Bimodal.Metalogic.Algebraic.Algebraic

/-!
# TM Bimodal Logic Metalogic

This module provides the complete metalogic infrastructure for TM bimodal logic,
including soundness, completeness, representation theorems, and the finite model property.

**Status**: Self-contained (NO Boneyard dependencies as of 2026-01-29)

## Architecture

The metalogic is organized into 7 subdirectories:

```
Metalogic/
├── Core/              # Foundational definitions and MCS theory
├── Soundness/         # Soundness theorem (15 axioms, 7 rules)
├── Representation/    # Canonical world/family definitions (sorry-free parts)
├── FMP/               # Finite Model Property (includes semantic completeness)
├── Completeness/      # Weak completeness theorem
└── Algebraic/         # Alternative algebraic approach (sorry-free)

Boneyard/Metalogic_v4/ (Archived - Task 772):
├── TaskRelation.lean, CoherentConstruction.lean, TruthLemma.lean
├── CanonicalHistory.lean, UniversalCanonicalModel.lean
├── InfinitaryStrongCompleteness.lean
└── Compactness.lean
```

## Dependency Layers

```
Layer 1 (Foundations):
    Core/
      │
Layer 2 (Proof Theory):
    Soundness/
      │
Layer 3 (Model Theory):
    Representation/
      │
Layer 4 (Completeness):
    Completeness/
      │
Layer 5 (Applications):
    FMP/
      │
Layer 6 (Extensions):
    Algebraic/
```

## Main Results

### Soundness (`Soundness/`)
```lean
theorem soundness : (Gamma ⊢ φ) → (Gamma ⊨ φ)
```
Derivability implies semantic validity. All 15 TM axioms and 7 derivation rules proven sound.

### Representation (Partially Archived - Task 772)
The sorried parts of the representation theorem infrastructure have been archived to
`Boneyard/Metalogic_v4/`. The sorry-free core definitions remain:
- `CanonicalWorld.lean` - Canonical world state definitions
- `IndexedMCSFamily.lean` - Indexed MCS family structure

### Weak Completeness (`Completeness/`)
```lean
theorem weak_completeness : valid φ → ContextDerivable [] φ
theorem provable_iff_valid : ContextDerivable [] φ ↔ valid φ
```
(Depends on Representation for canonical model construction.)

### Finite Model Property (`FMP/`)
```lean
theorem finite_model_property : satisfiable φ → ∃ finite_model, satisfiable_in φ
theorem semanticWorldState_card_bound : card worlds ≤ 2^closureSize
```

### Compactness (ARCHIVED - Task 772)
**Archived to Boneyard/Metalogic_v4/**: Depended on infinitary strong completeness.
The finite compactness case (`compactness_finset`) remains trivially true.

### Canonical Completeness Result
```lean
theorem semantic_weak_completeness (phi : Formula) :
    (∀ w : SemanticWorldState phi, semantic_truth_at_v2 phi w origin phi) → ⊢ phi
```
This is **THE completeness theorem** - it avoids the truth bridge gap via contrapositive.

## Known Architectural Limitations

These are **final limitations** (not future work):

| Location | Limitation | Reason |
|----------|------------|--------|
| `SemanticCanonicalFrame.compositionality` | Sorry | Mathematically false for unbounded durations |
| `truth_at_implies_semantic_truth` | Sorry | Box quantifies over ALL histories (Task 750) |
| Archived to Boneyard/Metalogic_v4/ | 17 sorries | Representation theorem architectural limitations |

## Key Features

- **Universal**: Parametric over ANY totally ordered additive commutative group D
- **Syntactic**: Builds semantic objects from pure syntax (MCS membership)
- **Self-contained**: No dependencies on Boneyard/ deprecated code
- **Type-theoretic**: Uses Lean 4 typeclasses for algebraic structure

## Subdirectory READMEs

- `Core/README.md` - MCS theory and foundational definitions
- `Soundness/README.md` - Soundness proof organization
- `Representation/README.md` - Canonical model construction
- `Completeness/README.md` - Weak completeness proof
- `FMP/README.md` - Finite Model Property infrastructure
- `Algebraic/README.md` - Alternative algebraic approach (sorry-free)

## References

- Modal Logic, Blackburn et al., Chapters 4-5 (Completeness via Canonical Models)
- Research reports: Task 750 (truth bridge analysis), Task 764 (migration)
-/
