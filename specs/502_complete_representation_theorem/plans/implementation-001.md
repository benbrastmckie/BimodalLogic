# Implementation Plan: Complete Representation Theorem using Context-Based Provability

## METADATA

- **Task Number**: 502
- **Session ID**: sess_502_context_001
- **Language**: lean
- **Proof Strategy**: Context-based refactoring with semantic integration
- **Complexity**: medium
- **Total Estimated Effort**: 4 hours
- **Mathlib Dependencies**: 
  - Mathlib.Data.List.Basic
  - Mathlib.Data.Finset.Basic  
  - Mathlib.Data.Set.Basic
  - Mathlib.Control.Basic
- **Research Integrated**: true (research-001.md, research-002.md)
- **Parent Task**: 499 (foundation completed)

## OVERVIEW

### Problem Statement
Complete the representation theorem in the TM bimodal/temporal modal logic system by replacing set-based provability (`SetDerivable`) with Lean-idiomatic context-based provability (`ContextDerivable` using `List Formula`). Eliminate all set-based components from the Bimodal/ theory and integrate with the semantic approach from FiniteCanonicalModel.lean.

### Scope
- Replace `SetDerivable Γ φ` with `ContextDerivable Γ φ` throughout Bimodal/Metalogic
- Implement context-based representation theorem using semantic infrastructure
- Integrate with FiniteCanonicalModel.lean's proven semantic approach
- Remove all set-based provability components
- Update completeness theorems to use context-based approach

### Lean-Specific Constraints
- Must use Lean idiomatic patterns: `List Formula` instead of `Set Formula`
- Preserve existing semantic infrastructure from FiniteCanonicalModel.lean
- Maintain compatibility with existing proof system (`DerivationTree`)
- Avoid artificial finiteness constraints (lists are naturally finite)
- Provide better temporal logic integration capabilities

### Definition of Done
- All `SetDerivable` references replaced with `ContextDerivable`
- Context-based representation theorem proven with no sorries
- Integration with semantic canonical model complete
- All set-based components removed from Bimodal/Metalogic
- Lake build succeeds with no warnings
- Documentation updated with context-based approach

## PROOF STRATEGY

### High-Level Approach
Use a **context-based refactoring strategy** that leverages Lean's dependent type theory:

1. **Forward Direction** (Syntax → Semantics):
   - Use existing soundness theorem adapted for contexts
   - Construct finite countermodel using semantic infrastructure
   - Prove representation theorem forward direction

2. **Backward Direction** (Semantics → Syntax):
   - Use semantic canonical model from FiniteCanonicalModel.lean
   - Apply proven `semantic_weak_completeness` theorem
   - Convert semantic entailment to context-based derivability

### Key Tactics to Use
- `exact` and `refine` for constructive proofs
- `induction` for formula structure proofs
- `cases` for context manipulation
- `simp` and `rw` for context list operations
- `have` and `exists` for witness construction

### Mathlib Theorems to Leverage
- `List.mem_cons`, `List.append_assoc` for context operations
- `Finset.mem_coe`, `Finset.subset_coe` during transition
- `Classical.choice` for existence proofs
- Subformula closure properties from FiniteCanonicalModel.lean

### Potential Pitfalls and Mitigation
- **Context Order**: Preserve list order during conversion
- **Duplicate Formulas**: Handle duplicates naturally (sets eliminate them)
- **Import Organization**: Ensure proper imports after set removal
- **Backward Compatibility**: Provide conversion theorems during transition

## IMPLEMENTATION PHASES

### Phase 1: Context-Based Provability Foundation
**Status**: [NOT STARTED]
**Objective**: Define context-based provability infrastructure and basic properties

**Tasks**:
- Define `ContextDerivable Γ φ` using `List Formula`
- Prove equivalence with standard `DerivationTree` for empty context
- Implement context manipulation utilities (extension, subset)
- Prove basic soundness theorem for context-based provability

**Acceptance Criteria**:
- `ContextDerivable` definition compiles and is documented
- `empty_context_derivability_iff` theorem proven
- Context utility functions implemented with tests
- `context_soundness` theorem proven

**Estimated Hours**: 1

### Phase 2: Integration with Semantic Infrastructure
**Status**: [NOT STARTED]
**Objective**: Connect context-based provability with FiniteCanonicalModel semantic approach

**Tasks**:
- Remove set-based definitions from RepresentationTheorems.lean
- Import and adapt semantic infrastructure from FiniteCanonicalModel.lean
- Define context-based entailment using `List Formula`
- Prove semantic entailment → context derivability bridge

**Acceptance Criteria**:
- Set-based components removed from RepresentationTheorems.lean
- Context-based entailment defined and documented
- Bridge theorems connecting semantic and syntactic sides proven
- Lake build succeeds with semantic integration

**Estimated Hours**: 1

### Phase 3: Context-Based Representation Theorem
**Status**: [NOT STARTED]
**Objective**: Prove the full representation theorem using context-based approach

**Tasks**:
- Implement forward direction: derivability → semantic model
- Implement backward direction using semantic canonical model
- Prove bidirectional representation theorem with no sorries
- Add corollaries (finite model property, decidability connection)

**Acceptance Criteria**:
- `representation_theorem_context` proven bidirectionally
- No sorries remain in proof
- Finite model property corollary derived
- Documentation added explaining context-based approach

**Estimated Hours**: 1.5

### Phase 4: Completeness Integration and Cleanup
**Status**: [NOT STARTED]
**Objective**: Update completeness theorems and remove all set-based remnants

**Tasks**:
- Update completeness theorems to use `ContextDerivable`
- Remove remaining set-based imports and definitions
- Add conversion theorems for backward compatibility
- Update module documentation and examples

**Acceptance Criteria**:
- All completeness theorems use context-based provability
- No set-based imports remain in Bimodal/Metalogic
- Conversion theorems provided for legacy code
- Module documentation reflects context-based approach

**Estimated Hours**: 0.5

## MATHLIB INTEGRATION

### Required Imports
```lean
import Mathlib.Data.List.Basic
import Mathlib.Data.Finset.Basic  -- for transition period only
import Mathlib.Data.Set.Basic     -- for transition period only
import Mathlib.Control.Basic
import Mathlib.Logic.Basic
```

### Relevant Namespaces
- `List` operations: `append`, `cons`, `mem`, `subset`
- `Finset` operations: during transition only
- `Classical` for existence proofs

### API Usage Patterns
```lean
-- Context manipulation
def ContextDerivable (Γ : List Formula) (φ : Formula) : Prop :=
  Nonempty (DerivationTree Γ φ)

-- Context extension (weakening)
def Context.extends (Δ Γ : List Formula) : Prop :=
  ∀ φ ∈ Δ, φ ∈ Γ

-- Context operations
def Context.merge (Γ₁ Γ₂ : List Formula) : List Formula := Γ₁ ++ Γ₂
```

### Version Compatibility Notes
- Remove `Finset` and `Set` imports after transition complete
- Ensure no reliance on set-theoretic properties
- Test with Lean 4.0+ dependent type features

## TESTING AND VALIDATION

### Type Checking
- Run `lake build` after each phase
- Verify no import errors after set removal
- Check all new definitions compile

### Unit Tests
- Test context manipulation utilities
- Verify equivalence theorems for conversion
- Test representation theorem on example formulas

### Property Testing
- Verify soundness theorem holds on test cases
- Test completeness direction on simple examples
- Validate finite model property corollary

### Example Usage Verification
- Provide examples of context-based provability
- Demonstrate integration with semantic model
- Show improved temporal logic reasoning

## ARTIFACTS

### Lean Source Files
- `Theories/Bimodal/Metalogic/RepresentationTheorems.lean` (updated)
- `Theories/Bimodal/Metalogic/Context.lean` (new utilities)
- `Theories/Bimodal/Metalogic.lean` (updated imports)

### Test Files
- `Theories/Bimodal/Metalogic/Test/ContextDerivableTest.lean` (new)

### Documentation
- Updated module docstrings for context-based approach
- Migration guide from set-based to context-based
- Integration examples with FiniteCanonicalModel

## ROLLBACK

### Git Commit Strategy
- Commit after each completed phase with descriptive message
- Branch: `feature/context-based-provability`
- Tag major milestones: `phase-1-context-foundation`, `representation-theorem-context`

### Revert Procedure if Proof Blocked
- Keep set-based components in separate branch for fallback
- Use conditional compilation (`if false`) during transition
- Document conversion theorems for future migration

### Alternative Approaches if Primary Strategy Fails
- Hybrid approach: maintain both set-based and context-based during transition
- Incremental migration: replace theorems one by one
- Deprecation path: mark set-based as deprecated before removal

---
**Created**: 2026-01-15  
**Last Updated**: 2026-01-15  
**Next Review**: After Phase 1 completion  
**Total Phases**: 4  
**Estimated Total Effort**: 4 hours