# Research Report: Task #568

**Task**: 568 - create_metalogic_v2_test_suite
**Date**: 2026-01-18
**Focus**: Research Metalogic_v2 architecture, identify test coverage needs for MCS properties, canonical model construction, soundness, completeness bridge lemmas, and provable_iff_valid theorem
**Session**: sess_1768805150_dd9971

## Summary

Metalogic_v2 implements a layered architecture for bimodal/temporal modal logic metatheory. The current test suite (4 test files + 2 property test files + 1 integration test) provides good type signature coverage but lacks comprehensive edge case testing, concrete example verification, and cross-module integration tests. Several critical modules lack dedicated test files.

## Architecture Overview

### Module Hierarchy

```
Metalogic_v2/
├── Core/
│   ├── Basic.lean            - Consistency definitions
│   ├── Provability.lean      - Context operations, ContextDerivable
│   ├── MaximalConsistent.lean - MCS theory, Lindenbaum's lemma
│   └── DeductionTheorem.lean  - Deduction theorem
├── Soundness/
│   ├── Soundness.lean        - Main soundness theorem, all 15 axiom validity lemmas
│   └── SoundnessLemmas.lean  - Temporal duality lemmas
├── Representation/
│   ├── CanonicalModel.lean   - CanonicalWorldState, canonicalModel, canonicalFrame
│   ├── TruthLemma.lean       - Truth lemma for all formula constructors
│   ├── RepresentationTheorem.lean - representation_theorem, strong_representation_theorem
│   ├── ContextProvability.lean - Context-based provability bridge
│   └── FiniteModelProperty.lean - FMP, subformulaList, decidability
├── Completeness/
│   ├── WeakCompleteness.lean  - valid -> provable (empty context)
│   └── StrongCompleteness.lean - Gamma |= phi -> Gamma |- phi
└── FMP.lean                   - Central hub re-exporting key theorems
```

### Key Dependencies

- **ContextProvability.lean** imports `Bimodal.Metalogic.Completeness.FiniteCanonicalModel` (old Metalogic)
- This is the PRIMARY DEPENDENCY on old Metalogic that must be addressed before deletion

## Existing Test Coverage Analysis

### Current Test Files

| File | Coverage | Gaps |
|------|----------|------|
| `CoreTest.lean` | Consistency, derivability, deduction theorem, MCS, Lindenbaum | Missing: concrete inconsistent examples, edge cases |
| `SoundnessTest.lean` | All 15 axiom validity, soundness applications, inference rules | Good coverage, could add more edge cases |
| `CompletenessTest.lean` | Weak/strong completeness, impChain helper, round-trips | Good type signature coverage |
| `RepresentationTest.lean` | Canonical model, truth lemma variants, representation theorem | Comprehensive type signatures |
| `CorePropertyTest.lean` | Context operations, derivation structure, SetConsistent | Has 1 sorry (singleton consistency) |
| `SoundnessPropertyTest.lean` | All 15 axiom schemas, soundness structural properties | Good coverage |
| `Integration/Metalogic_v2IntegrationTest.lean` | Cross-layer workflows | Good integration coverage |

### Uncovered Modules

1. **FiniteModelProperty.lean** - No dedicated tests for:
   - `subformulaList` construction
   - `subformulaList_finite` bound proofs
   - `finite_model_property` theorem
   - `semanticWorldState_card_bound`
   - `finite_model_property_constructive`

2. **ContextProvability.lean** - No dedicated tests for:
   - `not_derivable_implies_neg_consistent`
   - `representation_theorem_backward_empty`
   - `representation_validity` equivalence
   - `valid_implies_derivable`

3. **SoundnessLemmas.lean** - No dedicated tests for temporal duality

## Key Theorems Requiring Test Coverage

### 1. MCS Properties (MaximalConsistent.lean)

**Currently Tested**:
- `maximal_consistent_closed` - type signature only
- `maximal_negation_complete` - type signature only
- `set_lindenbaum` - type signature and basic properties

**Needs Testing**:
- `mcs_contains_or_neg` - concrete examples with specific formulas
- `mcs_modus_ponens` - closure under modus ponens
- `canonical_world_consistent` - consistency preservation
- `canonical_world_maximal` - maximality property
- `consistent_chain_union` - chain union consistency
- `finite_list_in_chain_member` - finite witness existence
- `derivation_uses_finite_context` - finiteness of derivation context

### 2. Canonical Model Construction (CanonicalModel.lean, TruthLemma.lean)

**Currently Tested**:
- `CanonicalWorldState` type exists
- `canonicalTruthAt` definition
- All `truthLemma_*` variants (atom, bot, imp, box, all_past, all_future)
- `contextTruthLemma`
- `canonical_modus_ponens`
- `necessitation_lemma`

**Needs Testing**:
- **Concrete world construction**: Build specific CanonicalWorldState instances and verify truth
- **Modal accessibility**: Test canonical accessibility relation properties
- **Truth lemma edge cases**: Empty carrier, singleton carrier, complex nested formulas
- **Model coherence**: Verify canonicalModel satisfies expected frame conditions

### 3. Soundness Lemmas

**Currently Tested**:
- All 15 axiom validity lemmas with type signatures
- `axiom_valid` dispatch function
- Soundness applications with modus ponens
- Necessitation rules

**Needs Testing**:
- **Complex derivation trees**: Multi-step proofs combining multiple axioms
- **Weakening interactions**: Soundness with context extensions
- **Derived rules**: Test common derived inference patterns

### 4. Completeness Bridge Lemmas

**Key Theorems to Test**:
- `representation_theorem`: Consistent Gamma -> exists w with all phi in Gamma true
- `strong_representation_theorem`: Gamma not |- neg phi -> exists w satisfying Gamma and phi
- `representation_satisfiability`: Consistent Gamma <-> canonicalContextSatisfiable Gamma
- `not_derivable_implies_neg_consistent`: unprovability implies consistency
- `representation_theorem_backward_empty`: semantic consequence -> derivability

**Testing Strategy**:
- Test with concrete consistent/inconsistent contexts
- Test with specific formulas where we know the outcome
- Test the contrapositive reasoning paths

### 5. provable_iff_valid Theorem

**Location**: `Completeness/WeakCompleteness.lean`

**Current Coverage**: Type signature only

**Needs Testing**:
- Forward direction (soundness): specific theorems
- Backward direction (completeness): specific valid formulas
- Round-trip verification for known theorems
- Edge cases: complex formulas, deeply nested modalities

### 6. Finite Model Property (FiniteModelProperty.lean)

**No Current Test Coverage**

**Key Items to Test**:
- `subformulaList` construction for all formula types
- `self_mem_subformulaList` - formula is in its own closure
- `subformulaList_finite` - exponential bound proof
- `finite_model_property` - satisfiable implies finite model exists
- `consistent_implies_satisfiable` - consistency to satisfiability
- `semanticWorldState_card_bound` - cardinality bound
- `finite_model_property_constructive` - explicit bound version

## Old Metalogic Test Patterns (For Inspiration)

### From `BimodalTest/Metalogic/CompletenessTest.lean`:
- Tests with `sorry` for meta-level properties (empty context consistency)
- `ecq` (ex contradictione quodlibet) usage for inconsistency proofs
- Round-trip tests: derivable -> valid -> derivable

### From `BimodalTest/Metalogic/SoundnessTest.lean`:
- Direct axiom validity tests
- Soundness with assumptions patterns
- Validity/semantic consequence equivalence

## Recommended Test Structure

### New Test Files to Create

1. **FMPTest.lean** - Dedicated FMP tests
   - Subformula closure tests
   - Finite model property verification
   - Decidability corollaries
   - Cardinality bounds

2. **ContextProvabilityTest.lean** - Bridge lemma tests
   - not_derivable_implies_neg_consistent
   - representation_theorem_backward_empty
   - valid_implies_derivable
   - representation_validity

3. **TruthLemmaPropertyTest.lean** - Truth lemma property tests
   - Edge cases for all formula constructors
   - Compositional truth preservation
   - Concrete world state examples

4. **CanonicalModelPropertyTest.lean** - Canonical model properties
   - Accessibility relation properties
   - Frame condition verification
   - Model coherence checks

### Test Categories for Each Module

For each module, tests should cover:

1. **Type Signature Tests**: Verify declarations type-check (already good coverage)
2. **Example Tests**: Concrete instances with specific formulas
3. **Property Tests**: Universally quantified properties
4. **Edge Case Tests**: Empty contexts, singleton contexts, contradictions
5. **Integration Tests**: Cross-module interactions

## Dependency Analysis for Old Metalogic Deletion

### Current Dependency

`ContextProvability.lean` imports:
```lean
import Bimodal.Metalogic.Completeness.FiniteCanonicalModel
```

Uses:
- `SemanticCanonicalFrame`
- `SemanticCanonicalModel`
- `SemanticWorldState`
- `semantic_weak_completeness`
- `FiniteTime`
- `temporalBound`
- `main_provable_iff_valid`

### For Safe Deletion of Old Metalogic

1. Either:
   - Migrate these definitions to Metalogic_v2, OR
   - Remove the dependency by implementing alternative approach

2. Test suite must verify:
   - All Metalogic_v2 modules compile without old imports
   - All theorems that previously used old Metalogic still work
   - No functionality regression

## Recommendations

### Priority 1: Create FMPTest.lean
The Finite Model Property module has zero test coverage despite being critical infrastructure.

### Priority 2: Create ContextProvabilityTest.lean
Bridge lemmas are essential for completeness and currently untested.

### Priority 3: Expand Concrete Example Tests
Current tests focus on type signatures. Add tests with specific formulas:
- `Formula.atom "p"`, `Formula.bot`, compound formulas
- Known theorems: Modal T, Modal K distribution, temporal axioms

### Priority 4: Add Edge Case Tests
- Empty context handling
- Singleton contexts
- Contradictory contexts (should detect inconsistency)
- Deeply nested formulas

### Priority 5: Fix CorePropertyTest.lean sorry
The `singleton_set_consistent_iff` theorem has a sorry for the case where L = []. This should be resolved.

### Priority 6: Document Old Metalogic Dependencies
Before deletion, create clear documentation of what ContextProvability.lean imports from old Metalogic and how to migrate.

## Concrete Test Examples

### Example: MCS Negation Completeness
```lean
/-- Test: For a specific maximal consistent set, verify phi or neg phi membership -/
example (S : Set Formula) (h : SetMaximalConsistent S) (p : String) :
    Formula.atom p ∈ S ∨ Formula.neg (Formula.atom p) ∈ S :=
  mcs_contains_or_neg h (Formula.atom p)
```

### Example: Subformula Closure
```lean
/-- Test: Box formula includes subformula in closure -/
example (phi : Formula) : phi ∈ subformulaList phi.box := by
  simp [subformulaList]
  right
  exact self_mem_subformulaList phi
```

### Example: provable_iff_valid for Modal T
```lean
/-- Test: Modal T is both provable and valid (round-trip) -/
noncomputable example (phi : Formula) :
    ContextDerivable [] (phi.box.imp phi) ↔ valid (phi.box.imp phi) :=
  provable_iff_valid (phi.box.imp phi)
```

## Next Steps

1. Create `/plan 568` to design the test suite implementation
2. Structure plan with phases:
   - Phase 1: FMPTest.lean
   - Phase 2: ContextProvabilityTest.lean
   - Phase 3: Expanded property tests
   - Phase 4: Edge case coverage
   - Phase 5: Integration verification
3. Ensure all tests compile without old Metalogic imports
4. Run `lake build Tests` to verify

## References

- `Theories/Bimodal/Metalogic_v2/` - Source modules
- `Tests/BimodalTest/Metalogic_v2/` - Existing tests
- `Tests/BimodalTest/Metalogic/` - Old tests for patterns
- Blackburn et al., Modal Logic, Chapter 4 (Canonical Model Construction)
