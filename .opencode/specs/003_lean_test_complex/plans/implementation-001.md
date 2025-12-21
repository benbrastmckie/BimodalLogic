# Implementation Plan: Completeness Theorem for Bimodal Logic

**Project**: 003_lean_test_complex
**Complexity**: complex
**Estimated Effort**: 3-4 hours
**Plan ID**: implementation-001
**Created**: 2025-12-20
**Status**: pending

## Task Description

Implement completeness theorem for bimodal logic with canonical model construction. This is a complex proof requiring multiple supporting theorems, custom tactics, and sophisticated proof techniques.

## Theorems to Implement

### Theorem 1: canonical_model_exists

Prove that a canonical model exists for any consistent set of formulas.

**Type Signature**: 
```lean
theorem canonical_model_exists (Γ : Set Formula) (h : Consistent Γ) : 
  ∃ M : Model, CanonicalModel M ∧ ∀ φ ∈ Γ, M ⊨ φ
```

**Proof Strategy**: 
- Construct maximal consistent extension of Γ
- Define canonical model from maximal consistent sets
- Prove model satisfies all formulas in Γ

**Dependencies**: 
- `Logos.Core.ProofSystem.Axioms`
- `Logos.Core.ProofSystem.Derivation`
- `Logos.Core.Semantics.TaskModel`
- Custom: `MaximalConsistentSet`, `CanonicalModel` definitions

**Expected Tactics**:
- `use` - Provide witness for existential
- `constructor` - Build conjunction
- `intro` - Introduce hypotheses
- `induction` - Induct on formula structure
- Custom tactics for canonical model construction

### Theorem 2: truth_lemma

Prove the truth lemma for the canonical model: a formula is true at a world iff it's in that world's maximal consistent set.

**Type Signature**: 
```lean
theorem truth_lemma (M : CanonicalModel) (w : M.World) (φ : Formula) : 
  M ⊨[w] φ ↔ φ ∈ w.formulas
```

**Proof Strategy**: 
- Induction on formula structure
- Base case: atomic formulas
- Inductive cases: connectives and modal operators
- Use canonical model properties

**Dependencies**: 
- `canonical_model_exists`
- `Logos.Core.Semantics.Truth`

**Expected Tactics**:
- `induction` - On formula structure
- `cases` - Case analysis on formula constructors
- `simp` - Simplify truth conditions
- `constructor` - Build biconditional

### Theorem 3: completeness_strong

Prove strong completeness: if Γ ⊨ φ then Γ ⊢ φ.

**Type Signature**: 
```lean
theorem completeness_strong (Γ : Set Formula) (φ : Formula) : 
  Γ ⊨ φ → Γ ⊢ φ
```

**Proof Strategy**: 
- Assume Γ ⊨ φ
- Suppose Γ ⊬ φ (proof by contradiction)
- Then Γ ∪ {¬φ} is consistent
- Construct canonical model satisfying Γ ∪ {¬φ}
- Use truth lemma to derive contradiction

**Dependencies**: 
- `canonical_model_exists`
- `truth_lemma`
- `Logos.Core.Metalogic.Soundness`

**Expected Tactics**:
- `intro` - Introduce semantic entailment
- `by_contra` - Proof by contradiction
- `apply` - Apply previous theorems
- `have` - Intermediate results

### Theorem 4: completeness_weak

Prove weak completeness as a corollary: ⊨ φ → ⊢ φ.

**Type Signature**: 
```lean
theorem completeness_weak (φ : Formula) : 
  ⊨ φ → ⊢ φ
```

**Proof Strategy**: 
- Apply strong completeness with Γ = ∅

**Dependencies**: 
- `completeness_strong`

**Expected Tactics**:
- `intro`
- `apply completeness_strong`
- `simp`

### Theorem 5: canonical_model_properties

Prove key properties of the canonical model (reflexivity, transitivity, etc.).

**Type Signature**: 
```lean
theorem canonical_model_properties (M : CanonicalModel) : 
  Reflexive M.R ∧ Transitive M.R ∧ Symmetric M.R
```

**Proof Strategy**: 
- Prove each property separately
- Use axioms and maximal consistency

**Dependencies**: 
- `canonical_model_exists`
- Modal axioms (T, 4, B)

**Expected Tactics**:
- `constructor` - Build conjunction
- `intro` - Introduce variables
- `apply` - Apply axioms
- Custom tactics for accessibility relation

## Implementation Details

### Target Files

1. **Canonical Model Definition**
   - **Path**: `Logos/Core/Semantics/CanonicalModel.lean`
   - **Module**: `Logos.Core.Semantics.CanonicalModel`
   - **Content**: 
     - `MaximalConsistentSet` structure
     - `CanonicalModel` structure
     - Helper functions and lemmas

2. **Completeness Proofs**
   - **Path**: `Logos/Core/Metalogic/Completeness.lean`
   - **Module**: `Logos.Core.Metalogic.Completeness`
   - **Content**: All 5 theorems listed above

### Required Imports
```lean
-- For CanonicalModel.lean
import Logos.Core.Syntax.Formula
import Logos.Core.ProofSystem.Derivation
import Logos.Core.Semantics.TaskModel

-- For Completeness.lean
import Logos.Core.Semantics.CanonicalModel
import Logos.Core.Semantics.Truth
import Logos.Core.Metalogic.Soundness
import Logos.Core.ProofSystem.Axioms
```

### Code Structure

**CanonicalModel.lean**:
```lean
namespace Logos.Core.Semantics

/-- A maximal consistent set of formulas. -/
structure MaximalConsistentSet where
  formulas : Set Formula
  consistent : Consistent formulas
  maximal : ∀ φ, φ ∉ formulas → ¬Consistent (formulas ∪ {φ})

/-- The canonical model constructed from maximal consistent sets. -/
structure CanonicalModel extends Model where
  worlds_are_mcs : ∀ w : World, ∃ mcs : MaximalConsistentSet, w.formulas = mcs.formulas
  accessibility_def : ∀ w₁ w₂ : World, R w₁ w₂ ↔ 
    (∀ φ, □φ ∈ w₁.formulas → φ ∈ w₂.formulas)

-- Helper lemmas
lemma mcs_contains_theorems (mcs : MaximalConsistentSet) (φ : Formula) :
  ⊢ φ → φ ∈ mcs.formulas := by sorry

lemma mcs_closed_under_mp (mcs : MaximalConsistentSet) (φ ψ : Formula) :
  φ → ψ ∈ mcs.formulas → φ ∈ mcs.formulas → ψ ∈ mcs.formulas := by sorry

end Logos.Core.Semantics
```

**Completeness.lean**:
```lean
namespace Logos.Core.Metalogic

-- All 5 theorems with sorry placeholders initially

end Logos.Core.Metalogic
```

### Testing
- **Test File**: `LogosTest/Core/Metalogic/CompletenessTest.lean`
- **Test Cases**: 
  - Verify all theorems compile
  - Test canonical model construction
  - Test truth lemma on sample formulas
  - Test completeness with known valid formulas
  - Performance: compilation time per theorem

## Dependency Graph

```
completeness_weak
└── completeness_strong
    ├── canonical_model_exists
    │   └── MaximalConsistentSet (definition)
    ├── truth_lemma
    │   ├── canonical_model_exists
    │   └── canonical_model_properties
    └── soundness (from previous work)

canonical_model_properties
└── canonical_model_exists
```

## Metaprogramming Requirements

May require custom tactics:
- `canonical_model_tac` - Automate canonical model construction steps
- `truth_lemma_tac` - Automate truth lemma induction cases
- `mcs_tac` - Reasoning about maximal consistent sets

## Success Criteria

- [x] All 5 theorems compile without errors
- [x] No `sorry` placeholders in final version
- [x] Follows LEAN 4 style guide
- [x] Documentation includes examples and detailed docstrings
- [x] Tests pass in `LogosTest/Core/Metalogic/CompletenessTest.lean`
- [x] Performance: compilation time < 10s per theorem
- [x] Canonical model construction is well-documented
- [x] Custom tactics (if needed) are documented

## Notes

This is a complex test case designed to verify:
- Multi-file implementation
- Complex proof techniques (canonical models)
- Theorem interdependencies
- Potential custom tactic development
- Long compilation times
- Sophisticated proof strategies
- Multiple phases of /lean command (research, planning, implementation, verification)

## Metadata

```yaml
complexity: complex
theorem_count: 5
estimated_lines: 200+
dependencies: 8+
test_coverage: comprehensive
interdependencies: true
requires_metaprogramming: possibly
multi_file: true
```
