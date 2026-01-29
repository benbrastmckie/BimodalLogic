# Parametric Finite Model Property Infrastructure

This directory contains the parametric FMP (Finite Model Property) infrastructure for TM bimodal logic.

## Overview

The FMP establishes that if a formula is satisfiable, it is satisfiable in a **finite** model with bounded size. The key insight is that the cardinality bound (2^closureSize) is **purely combinatorial** - independent of any specific duration type D.

## Modules

| Module | Purpose |
|--------|---------|
| `Closure.lean` | Subformula closure, closureWithNeg, closure-maximal consistent sets |
| `BoundedTime.lean` | Finite time domain `BoundedTime k = Fin (2*k+1)` |
| `FiniteWorldState.lean` | Finite world states as truth assignments on closure |
| `SemanticCanonicalModel.lean` | Semantic canonical model with finite world states |
| `FiniteModelProperty.lean` | FMP theorem and cardinality bounds |

## Key Definitions

### Closure Infrastructure (`Closure.lean`)

```lean
def closure (φ : Formula) : Finset Formula
def closureWithNeg (φ : Formula) : Finset Formula
def closureSize (φ : Formula) : Nat
def ClosureMaximalConsistent (φ : Formula) (S : Set Formula) : Prop
```

### Bounded Time (`BoundedTime.lean`)

```lean
abbrev BoundedTime (k : Nat) := Fin (2 * k + 1)
def temporalBound (φ : Formula) : Nat := φ.temporalDepth
```

### Finite World State (`FiniteWorldState.lean`)

```lean
structure FiniteWorldState (φ : Formula)
structure FiniteHistory (φ : Formula)
def worldStateFromClosureMCS (φ : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent φ S) : FiniteWorldState φ
```

### Semantic Canonical Model (`SemanticCanonicalModel.lean`)

```lean
def SemanticWorldState (φ : Formula) := Quotient (htSetoid φ)
noncomputable def SemanticCanonicalFrame (φ : Formula) : TaskFrame Int
noncomputable def SemanticCanonicalModel (φ : Formula) : TaskModel (SemanticCanonicalFrame φ)
```

### FMP Theorems (`FiniteModelProperty.lean`)

```lean
theorem finite_model_property (φ : Formula) :
    formula_satisfiable φ → ∃ (D : Type) ... truth_at M τ t φ

theorem finite_model_property_constructive (φ : Formula) (h_sat : formula_satisfiable φ) :
    ∃ (F : TaskFrame Int) ... Fintype.card F.WorldState ≤ 2 ^ closureSize φ

theorem semanticWorldState_card_bound (φ : Formula) :
    Fintype.card (SemanticWorldState φ) ≤ 2 ^ closureSize φ
```

## Design Rationale

### Why Parametric?

The original `Boneyard/Metalogic_v2/` implementation was hardcoded to `Int` duration. The parametric approach:

1. **Architectural consistency**: Matches the parametric Metalogic/ design using generic D
2. **Maximum generality**: Works for any ordered group D
3. **Future-proofing**: New duration types work automatically
4. **Mathematical elegance**: The bound is D-independent - the proof should reflect this

### BoundedTime Abstraction

The `BoundedTime k` type is the key innovation:
- Defined as `Fin (2*k+1)` - inherits Fintype from Fin
- Provides canonical integer interpretation via `toInt : BoundedTime k → Int`
- Combinatorial structure - the cardinality bound comes from this, not from D

## Known Sorries

| Location | Description | Status |
|----------|-------------|--------|
| `SemanticCanonicalFrame.compositionality` | Frame compositionality axiom | Mathematically false for unbounded durations in finite domain |
| `finite_model_property_constructive` truth bridge | Connecting finite model truth to `truth_at` | Formula induction has problematic cases |

### Recommended Alternative

For **sorry-free completeness**, use `semantic_weak_completeness`:

```lean
noncomputable def semantic_weak_completeness (φ : Formula) :
    (∀ (w : SemanticWorldState φ), semantic_truth_at_v2 φ w t φ) → ⊢ φ
```

This avoids the truth bridge by working directly with finite model truth.

## Usage Examples

### Decidability Analysis

```lean
-- Use the cardinality bound for complexity analysis
theorem semanticWorldState_card_bound (φ : Formula) :
    Fintype.card (SemanticWorldState φ) ≤ 2 ^ closureSize φ
```

### Completeness Proofs

```lean
-- Prefer semantic_weak_completeness (sorry-free)
noncomputable def semantic_weak_completeness (φ : Formula) :
    (∀ w, semantic_truth_at_v2 φ w t φ) → ⊢ φ
```

## References

- Original: `Boneyard/Metalogic_v2/Representation/` FMP modules
- Blackburn et al., Modal Logic, Chapter 4 (Finite Model Property)
- Wu, M., Verified Decision Procedures for Modal Logics
