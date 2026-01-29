-- Metalogic: TM Bimodal Logic Metalogic Infrastructure
-- Self-contained (no Boneyard dependencies)

-- Finite Model Property infrastructure (includes all subdirectory dependencies)
import Bimodal.Metalogic.FMP

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
├── Representation/    # Canonical model construction
├── FMP/               # Finite Model Property (parametric)
├── Completeness/      # Weak completeness theorem
├── Compactness/       # Compactness theorem
└── Algebraic/         # Alternative algebraic approach (future extension)
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
Layer 4 (Finiteness):
    FMP/
      │
Layer 5 (Results):
    Completeness/ ── Compactness/
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

### Representation (`Representation/`)
```lean
theorem representation_theorem : SetConsistent {φ} → satisfiable φ
```
Consistent formulas are satisfiable in the universal canonical model.

### Finite Model Property (`FMP/`)
```lean
theorem finite_model_property : satisfiable φ → ∃ finite_model, satisfiable_in φ
theorem semanticWorldState_card_bound : card worlds ≤ 2^closureSize
```

### Weak Completeness (`Completeness/`)
```lean
theorem weak_completeness : valid φ → ContextDerivable [] φ
theorem provable_iff_valid : ContextDerivable [] φ ↔ valid φ
```

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
| `Representation/TruthLemma.lean` box case | Sorry | Same Box semantics limitation |

## Key Features

- **Universal**: Parametric over ANY totally ordered additive commutative group D
- **Syntactic**: Builds semantic objects from pure syntax (MCS membership)
- **Self-contained**: No dependencies on Boneyard/ deprecated code
- **Type-theoretic**: Uses Lean 4 typeclasses for algebraic structure

## Subdirectory READMEs

- `Core/README.md` - MCS theory and foundational definitions
- `Soundness/README.md` - Soundness proof organization
- `Representation/README.md` - Canonical model construction
- `FMP/README.md` - Finite Model Property infrastructure
- `Completeness/README.md` - Weak completeness proof
- `Compactness/README.md` - Compactness theorem
- `Algebraic/README.md` - Alternative algebraic approach (future extension)

## References

- Modal Logic, Blackburn et al., Chapters 4-5 (Completeness via Canonical Models)
- Research reports: Task 750 (truth bridge analysis), Task 764 (migration)
-/
