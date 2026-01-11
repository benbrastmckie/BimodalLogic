# BimodalTest

Comprehensive test suite for the Bimodal TM logic library.

## Purpose

This directory contains all tests for the Bimodal library, organized to mirror the source structure. Tests cover unit testing, integration testing, property-based testing, and metalogic verification.

## Test Organization

Tests are organized by module under test:

- **Syntax/**: Formula construction, context operations
  - `FormulaTest.lean` - Formula inductive type tests
  - `FormulaPropertyTest.lean` - Property-based formula tests
  - `ContextTest.lean` - Proof context tests

- **ProofSystem/**: Axiom schema and inference rule validation
  - `AxiomsTest.lean` - TM axiom schemata tests
  - `DerivationTest.lean` - Derivability relation and inference rules
  - `DerivationPropertyTest.lean` - Property-based derivation tests

- **Semantics/**: Task frame semantics, model construction, validity
  - `TaskFrameTest.lean` - Task frame structure tests
  - `TruthTest.lean` - Truth evaluation tests
  - `SemanticPropertyTest.lean` - Semantic property tests

- **Metalogic/**: Soundness, completeness, and decidability property tests
  - `SoundnessTest.lean` - Soundness property tests
  - `SoundnessPropertyTest.lean` - Property-based soundness tests
  - `CompletenessTest.lean` - Completeness property tests

- **Theorems/**: Tests for perpetuity principles and key theorems
  - `PerpetuityTest.lean` - Perpetuity principles P1-P6 tests
  - `ModalS4Test.lean` - Modal S4 theorem tests
  - `ModalS5Test.lean` - Modal S5 theorem tests
  - `PropositionalTest.lean` - Propositional theorem tests

- **Automation/**: Tactic and proof search tests
  - `TacticsTest.lean` - Custom tactic tests
  - `TacticsTest_Simple.lean` - Simple tactic examples
  - `ProofSearchTest.lean` - Proof search tests
  - `ProofSearchBenchmark.lean` - Performance benchmarks
  - `EdgeCaseTest.lean` - Edge case coverage

- **Integration/**: Cross-module integration tests
  - `EndToEndTest.lean` - Basic end-to-end workflows
  - `ProofSystemSemanticsTest.lean` - Proof system and semantics integration
  - `AutomationProofSystemTest.lean` - Automation and proof system integration
  - `ComplexDerivationTest.lean` - Multi-step derivation tests
  - `TemporalIntegrationTest.lean` - Temporal axiom workflows
  - `BimodalIntegrationTest.lean` - Modal-temporal interactions
  - `Helpers.lean` - Reusable test utilities

- **Property/**: Property-based tests using Plausible
  - `Generators.lean` - Type generators for Formula, Context, TaskFrame

## Running Tests

### Run All Tests

```bash
# Run entire test suite
lake exe test

# Build test libraries
lake build BimodalTest

# Expected output:
# Running tests...
# All tests passed
```

### Run Specific Module Tests

```bash
# Test specific module
lake build BimodalTest.Syntax
lake build BimodalTest.ProofSystem
lake build BimodalTest.Semantics
lake build BimodalTest.Integration
lake build BimodalTest.Metalogic
lake build BimodalTest.Theorems
lake build BimodalTest.Automation

# Test specific file
lake env lean BimodalTest/Syntax/FormulaTest.lean
lake env lean BimodalTest/ProofSystem/AxiomsTest.lean
```

### Running Tests in VS Code

1. Open test file in VS Code with lean4 extension
2. LEAN will type-check automatically
3. Errors appear inline with red squiggles
4. Hover over errors to see detailed messages

## Adding New Tests

### File Placement

**Unit tests** (testing single module in isolation):
- Formula tests -> `BimodalTest/Syntax/FormulaTest.lean`
- Axiom tests -> `BimodalTest/ProofSystem/AxiomsTest.lean`
- Semantics tests -> `BimodalTest/Semantics/TruthTest.lean`

**Integration tests** (testing module interactions):
- Place in `BimodalTest/Integration/` directory
- Name descriptively: `ProofSystemSemanticsTest.lean`, etc.

**Property-based tests** (testing general properties):
- Soundness tests -> `BimodalTest/Metalogic/SoundnessPropertyTest.lean`
- Formula properties -> `BimodalTest/Syntax/FormulaPropertyTest.lean`

### Naming Conventions

**Files**: `<Module>Test.lean`
- Example: `FormulaTest.lean`, `AxiomsTest.lean`, `ValidityTest.lean`

**Tests**: `test_<feature>_<expected_behavior>`
- Example: `test_imp_reflexivity`, `test_modal_t_valid`, `test_modus_ponens`

**Modules**: `BimodalTest.<Category>.<Module>Test`
- Example: `BimodalTest.Syntax.FormulaTest`

### Test Template

```lean
/-!
# [Module] Tests

Tests for [module description].
-/

import Bimodal.[Module]

namespace BimodalTest.[Module]Test

-- Test helper functions (if needed)
def test_helper : Type := sorry

-- Unit test example
example : test_feature_works := by
  -- Test implementation
  sorry

-- Property test example
theorem test_property_holds : forall (x : Type), property x := by
  intro x
  -- Property proof
  sorry

end BimodalTest.[Module]Test
```

## Test Quality Standards

### Coverage Requirements

See [TESTING_STANDARDS.md](../docs/development/TESTING_STANDARDS.md) for detailed coverage targets:
- **Overall**: >=85% code coverage
- **Metalogic**: >=90% coverage (soundness/completeness critical)
- **Automation**: >=80% coverage (tactics and proof search)
- **Error handling**: >=75% coverage (error cases tested)

### Test Completeness

Each module should have tests for:
- **Happy path**: Normal usage scenarios
- **Edge cases**: Boundary conditions, empty inputs
- **Error cases**: Invalid inputs, type mismatches
- **Properties**: General properties that must hold
- **Integration**: Interactions with other modules

## Implementation Status

### Test Coverage Summary

| Module | Status | Tests | Notes |
|--------|--------|-------|-------|
| Syntax | Complete | 20+ | Formula, Context fully tested |
| ProofSystem | Complete | 30+ | All axioms and rules tested |
| Semantics | Complete | 25+ | Task frames, truth, validity |
| Integration | Complete | 15+ | Cross-module workflows |
| Theorems | Partial | 40+ | Some sorries pending infrastructure |
| Automation | Partial | 20+ | Core tactics tested |
| Metalogic | Partial | 15+ | Completeness tests pending |

### Sorry Placeholder Status

The test suite contains a few `sorry` placeholders, categorized as follows:

**Pending Infrastructure** (cannot be resolved until source implementation completes):
- `CompletenessTest.lean` (3 sorries) - Tests for completeness theorems require actual
  completeness proofs in `Bimodal/Metalogic/Completeness.lean` to be implemented
- `PropositionalTest.lean` (1 sorry) - Requires deduction theorem infrastructure

**Pending Concrete Proofs** (could be completed with additional proof work):
- `PerpetuityTest.lean` (1 sorry) - Test for `box_conj_intro` needs concrete theorem proofs

**Documented as Pending** (explicitly marked as placeholder tests):
- `ModalS4Test.lean` - All S4 theorem tests commented out pending Phase 4 implementation

### Verification Commands

```bash
# Count sorries in test suite
grep -r "sorry" BimodalTest/ --include="*.lean" | grep -v "README" | wc -l

# Build all tests (compilation = passing)
lake build BimodalTest

# Check specific test modules
lake build BimodalTest.Metalogic
lake build BimodalTest.Theorems
```

For detailed implementation status, see [IMPLEMENTATION_STATUS.md](../docs/project-info/IMPLEMENTATION_STATUS.md).

## Related Documentation

- [Test Coverage Report](../Bimodal/docs/project-info/TEST_COVERAGE.md) - Definition coverage metrics
- [Testing Standards](../docs/development/TESTING_STANDARDS.md) - Detailed test requirements
- [LEAN Style Guide](../docs/development/LEAN_STYLE_GUIDE.md) - Code conventions
- [Implementation Status](../docs/project-info/IMPLEMENTATION_STATUS.md) - Module status
- [Property Testing Guide](Property/README.md) - Property-based testing patterns
- [Integration Testing Guide](Integration/README.md) - Integration test patterns
- [Performance Targets](../Bimodal/docs/project-info/PERFORMANCE_TARGETS.md) - Benchmark baselines

## Navigation

- **Up**: [Project Root](../)
- **Source Code**: [Bimodal/](../Bimodal/)
- **Documentation**: [docs/](../docs/)
