# Research Report: Task #514

**Task**: 514 - Expand test coverage for Metalogic_v2
**Date**: 2026-01-18
**Focus**: Analyze Metalogic_v2/ architecture and existing test patterns from Metalogic/ to develop test coverage strategy for the new representation-theorem-centric architecture

## Summary

The Metalogic_v2 directory implements a reorganized metalogic infrastructure with a representation-first architecture where the Finite Model Property (FMP) serves as the central bridge theorem. The existing test patterns in Tests/BimodalTest/Metalogic/ provide a solid foundation using example-based verification, soundness application tests, and property-based testing with Plausible. A comprehensive test strategy for Metalogic_v2 should follow this established pattern while focusing on the new architectural layers: Core, Soundness, Representation, and Completeness.

## Findings

### 1. Metalogic_v2 Architecture Analysis

The Metalogic_v2 directory follows a layered architecture with clear separation of concerns:

```
Metalogic_v2/
├── Core/                          # Foundation layer
│   ├── Basic.lean                 # Consistency, Valid definitions
│   ├── Provability.lean           # ContextDerivable, SetDerivable
│   ├── DeductionTheorem.lean      # Proven deduction theorem
│   └── MaximalConsistent.lean     # MCS theory, Lindenbaum (proven)
├── Soundness/                     # Soundness layer
│   ├── SoundnessLemmas.lean       # Temporal duality bridge
│   └── Soundness.lean             # 15/15 axiom validity lemmas (proven)
├── Representation/                # Central layer
│   ├── CanonicalModel.lean        # CanonicalWorldState, CanonicalFrame
│   ├── TruthLemma.lean            # Truth lemma variants
│   ├── RepresentationTheorem.lean # Main representation theorem
│   ├── ContextProvability.lean    # Context provability bridge (has axiom)
│   └── FiniteModelProperty.lean   # FMP statement
├── Completeness/                  # Application layer
│   ├── WeakCompleteness.lean      # valid -> provable
│   └── StrongCompleteness.lean    # semantic consequence -> derivable
├── Applications/
│   └── Compactness.lean           # Compactness theorems
└── FMP.lean                       # Central hub (re-exports)
```

**Key architectural principle**: The representation theorem is central, with soundness proven from axioms up and completeness flowing down from representation.

### 2. Proven vs Sorry Components

**Fully Proven (no sorry)**:
| Component | Location | Description |
|-----------|----------|-------------|
| `soundness` | Soundness/Soundness.lean | `Gamma |- phi -> Gamma |= phi` |
| `deduction_theorem` | Core/DeductionTheorem.lean | `(phi :: Gamma) |- psi -> Gamma |- phi -> psi` |
| `set_lindenbaum` | Core/MaximalConsistent.lean | Every consistent set extends to MCS |
| `maximal_consistent_closed` | Core/MaximalConsistent.lean | MCS is deductively closed |
| `maximal_negation_complete` | Core/MaximalConsistent.lean | `phi notin MCS -> neg phi in MCS` |
| `representation_theorem` | Representation/RepresentationTheorem.lean | Consistent Gamma -> satisfiable in canonical |
| All 15 axiom validity lemmas | Soundness/Soundness.lean | `prop_k_valid`, `modal_t_valid`, etc. |

**With Sorries/Axioms**:
| Component | Location | Status |
|-----------|----------|--------|
| `consistent_iff_consistent'` | Core/Basic.lean | sorry (equivalence proof) |
| `necessitation_lemma` | Representation/TruthLemma.lean | sorry |
| `representation_theorem_backward_empty` | Representation/ContextProvability.lean | **axiom** (critical) |

### 3. Existing Test Patterns from Metalogic/

The existing tests in `Tests/BimodalTest/Metalogic/` use several patterns:

**Pattern 1: Axiom Validity Tests** (SoundnessTest.lean)
```lean
-- Test: Modal T is valid
example (phi : Formula) : |= (phi.box.imp phi) := modal_t_valid phi

-- Test: Modal T axiom is derivable
example (phi : Formula) : |- (phi.box.imp phi) :=
  DerivationTree.axiom [] _ (Axiom.modal_t phi)
```

**Pattern 2: Soundness Application Tests** (SoundnessTest.lean)
```lean
-- Test: Soundness applies to Modal T derivation
example (phi : Formula) : [] |= (phi.box.imp phi) := by
  let deriv : |- (phi.box.imp phi) := DerivationTree.axiom [] _ (Axiom.modal_t phi)
  exact soundness [] (phi.box.imp phi) deriv
```

**Pattern 3: Property-Based Tests** (SoundnessPropertyTest.lean)
```lean
-- Property: Modal T axiom is valid for all formulas
#eval Testable.check (forall phi : Formula, |= (phi.box.imp phi)) {
  numInst := 100,
  maxSize := 40
}
```

**Pattern 4: Type Signature Verification** (CompletenessTest.lean)
```lean
-- Test: Lindenbaum's lemma type signature
example (Gamma : Context) (h : Consistent Gamma) :
    exists Delta : Context, (forall phi, phi in Gamma -> phi in Delta) /\ MaximalConsistent Delta :=
  lindenbaum Gamma h
```

**Pattern 5: Integration Tests** (EndToEndTest.lean)
```lean
-- Integration Test: Complete metalogical pathway
example : True := by
  let proof : |- ((Formula.atom "p").box.imp (Formula.atom "p")) := ...
  let valid_from_soundness : [] |= (...) := soundness [] _ proof
  let valid_direct : |= (...) := modal_t_valid (Formula.atom "p")
  trivial
```

### 4. Generator Infrastructure

The project has a well-developed property testing infrastructure in `Tests/BimodalTest/Property/Generators.lean`:

- `Arbitrary Formula`: Size-controlled recursive generator
- `Shrinkable Formula`: Shrinking strategy for counterexamples
- `SampleableExt TaskFrame`: Finite frame generation
- `SampleableExt TaskModel`: Model generation with hash-based valuation
- Helper generators: `genFormulaOfSize`, `genNonEmptyContext`, `genPropFormula`

These generators are reusable for Metalogic_v2 tests.

### 5. Import Considerations

For Metalogic_v2 tests, imports should follow the layered architecture:
- Core tests: `import Bimodal.Metalogic_v2.Core.MaximalConsistent`
- Soundness tests: `import Bimodal.Metalogic_v2.Soundness.Soundness`
- Representation tests: `import Bimodal.Metalogic_v2.FMP` (central hub)
- Completeness tests: `import Bimodal.Metalogic_v2.Completeness.WeakCompleteness`

**Critical**: Do NOT import from old `Bimodal.Metalogic` as it will be removed.

### 6. Test Coverage Gaps

Current test coverage gaps for Metalogic_v2:

1. **Core Layer**: No tests exist for:
   - `Consistent` definition behavior
   - `ContextDerivable` vs `SetDerivable` relationship
   - `Context.extends`, `Context.merge`, `Context.subset` operations

2. **Representation Layer**: No tests exist for:
   - `CanonicalWorldState` properties
   - `canonicalTruthAt` truth conditions
   - `truthLemma_*` variants (atom, bot, imp, box, all_past, all_future)
   - `representation_theorem` applications
   - `strong_representation_theorem` usage

3. **Completeness Layer**: No tests exist for:
   - `weak_completeness` applications
   - `provable_iff_valid` equivalence
   - `strong_completeness` usage

## Recommended Test Strategy

### Phase 1: Core Layer Tests (Priority: High)
Create `Tests/BimodalTest/Metalogic_v2/CoreTest.lean`:

1. **Consistency Tests**
   - Empty context is consistent
   - Context with contradiction is inconsistent
   - Consistency preserved under extension

2. **Provability Tests**
   - `ContextDerivable` type signature verification
   - Empty context derivability equivalence
   - Derivation examples

3. **Deduction Theorem Tests**
   - Basic deduction theorem application
   - Multi-step deduction examples

4. **Maximal Consistent Set Tests**
   - `set_lindenbaum` type signature
   - `maximal_consistent_closed` application
   - `maximal_negation_complete` examples

### Phase 2: Soundness Layer Tests (Priority: High)
Create `Tests/BimodalTest/Metalogic_v2/SoundnessTest.lean`:

1. **Axiom Validity Tests** (all 15 axioms)
   - Use same pattern as existing SoundnessTest.lean
   - Import from `Bimodal.Metalogic_v2.Soundness.Soundness`

2. **Soundness Application Tests**
   - Soundness for derivations from empty context
   - Soundness for derivations from non-empty context

3. **Property-Based Tests**
   - Reuse existing SoundnessPropertyTest patterns

### Phase 3: Representation Layer Tests (Priority: High)
Create `Tests/BimodalTest/Metalogic_v2/RepresentationTest.lean`:

1. **Canonical Model Tests**
   - `CanonicalWorldState` type construction
   - `canonicalFrame` existence
   - `canonicalModel` existence

2. **Truth Lemma Tests**
   - `truthLemma_detailed` equivalence
   - `truthLemma_atom` for atomic formulas
   - `truthLemma_bot` falsity preservation
   - `truthLemma_imp`, `truthLemma_box`, etc.

3. **Representation Theorem Tests**
   - Type signature verification
   - `strong_representation_theorem` examples
   - `completeness_corollary` application

### Phase 4: Completeness Layer Tests (Priority: Medium)
Create `Tests/BimodalTest/Metalogic_v2/CompletenessTest.lean`:

1. **Weak Completeness Tests**
   - Type signature verification
   - Application examples (uses axiom, so noncomputable)

2. **Strong Completeness Tests**
   - Type signature verification
   - Context-based examples

3. **Equivalence Tests**
   - `provable_iff_valid` bidirectional tests

### Phase 5: Integration Tests (Priority: Medium)
Create `Tests/BimodalTest/Integration/Metalogic_v2IntegrationTest.lean`:

1. **End-to-End Workflow**
   - Derive theorem syntactically
   - Apply soundness for semantic validity
   - Verify completeness pathway

2. **Layer Integration**
   - Core -> Representation flow
   - Representation -> Completeness flow
   - Soundness <-> Completeness equivalence

## Test File Structure

```
Tests/BimodalTest/
├── Metalogic_v2/                        # NEW: Metalogic_v2 tests
│   ├── CoreTest.lean                    # Core layer tests
│   ├── CorePropertyTest.lean            # Property-based core tests
│   ├── SoundnessTest.lean               # Soundness tests
│   ├── SoundnessPropertyTest.lean       # Property-based soundness
│   ├── RepresentationTest.lean          # Representation layer tests
│   ├── CompletenessTest.lean            # Completeness layer tests
│   └── README.md                        # Metalogic_v2 test documentation
├── Integration/
│   └── Metalogic_v2IntegrationTest.lean # Integration tests
└── ...
```

## Effort Estimate

| Phase | Files | Estimated Effort |
|-------|-------|------------------|
| Phase 1: Core Tests | 2 files | 2-3 hours |
| Phase 2: Soundness Tests | 2 files | 2-3 hours |
| Phase 3: Representation Tests | 1 file | 2-3 hours |
| Phase 4: Completeness Tests | 1 file | 1-2 hours |
| Phase 5: Integration Tests | 1 file | 1-2 hours |
| **Total** | **7 files** | **8-13 hours** |

## Dependencies

- Metalogic_v2 directory must be stable (no major refactoring)
- Property testing infrastructure (Plausible, Generators.lean) already available
- Test framework patterns established in existing Metalogic tests

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Axiom `representation_theorem_backward_empty` limits testability | Medium | Focus on type signatures and forward direction; document limitations |
| Sorries in Core/Basic.lean block some tests | Low | Work around with `noncomputable` or skip dependent tests |
| Architecture changes during implementation | Medium | Start with stable Core layer; defer Completeness tests |

## References

- Metalogic_v2 README: `Theories/Bimodal/Metalogic_v2/README.md`
- Existing tests: `Tests/BimodalTest/Metalogic/`
- Property generators: `Tests/BimodalTest/Property/Generators.lean`
- Test documentation: `Tests/BimodalTest/README.md`

## Next Steps

Run `/plan 514` to create an implementation plan with detailed phase specifications for each test file.
