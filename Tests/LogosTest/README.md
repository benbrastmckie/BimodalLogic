# LogosTest

Thin wrapper test suite that imports from BimodalTest for TM logic tests.

## Test Organization

Tests for the Bimodal TM logic library are located in `BimodalTest/`, following the Mathlib pattern (Mathlib/ + MathlibTest/). This directory re-exports those tests for backwards compatibility with existing test infrastructure.

### BimodalTest Structure

The actual tests are in `BimodalTest/`:

- **Syntax/**: Formula construction, context operations, DSL tests
  - FormulaTest.lean: Formula inductive type tests
  - ContextTest.lean: Proof context tests
- **ProofSystem/**: Axiom schema and inference rule validation
  - AxiomsTest.lean: TM axiom schemata tests
  - DerivationTest.lean: Derivability relation and inference rules
- **Semantics/**: Task frame semantics, model construction, validity
  - TaskFrameTest.lean: Task frame structure tests
  - TruthTest.lean: Truth evaluation tests
- **Integration/**: Cross-module integration tests
  - Tests that involve multiple modules working together
- **Metalogic/**: Soundness, completeness, and decidability property tests
  - SoundnessTest.lean: Soundness property tests
  - CompletenessTest.lean: Completeness property tests
- **Theorems/**: Tests for perpetuity principles and key theorems
  - PerpetuityTest.lean: Perpetuity principles P1-P6 tests
- **Automation/**: Tactic and proof search tests
  - TacticsTest.lean: Custom tactic tests
  - ProofSearchTest.lean: Automated proof search tests
- **Property/**: Property-based tests using Plausible
  - Generators.lean: Type generators for Formula, Context, TaskFrame

## Running Tests

### Run All Tests

```bash
# Run entire test suite
lake exe test

# Build test libraries
lake build BimodalTest
lake build LogosTest

# Expected output:
# Running tests...
# All tests passed
```

### Run Specific Module Tests

```bash
# Test specific module via BimodalTest
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

For Bimodal TM logic tests, add files to `BimodalTest/`:

**Unit tests** (testing single module in isolation):
- Formula tests -> `BimodalTest/Syntax/FormulaTest.lean`
- Axiom tests -> `BimodalTest/ProofSystem/AxiomsTest.lean`
- Semantics tests -> `BimodalTest/Semantics/TruthTest.lean`

**Integration tests** (testing module interactions):
- Place in `BimodalTest/Integration/` directory
- Name descriptively: `ProofSystemSemanticsTest.lean`, etc.

**Property-based tests** (testing general properties):
- Soundness tests -> `BimodalTest/Metalogic/SoundnessTest.lean`
- Completeness tests -> `BimodalTest/Metalogic/CompletenessTest.lean`

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

## Current Test Status

**Implemented Tests**:
- Syntax: Formula construction, context operations
- ProofSystem: Axiom schema validation, derivation tests
- Semantics: Task frame properties, truth evaluation
- Integration: Basic cross-module tests
- Theorems: Perpetuity principle tests

**Partial Tests**:
- Metalogic: Soundness tests (5/8 axioms, 4/7 rules)

**Planned Tests**:
- Automation: Tactic tests (when tactics implemented)
- Metalogic: Completeness tests (when completeness proven)

For detailed status, see [IMPLEMENTATION_STATUS.md](../docs/project-info/IMPLEMENTATION_STATUS.md).

## Related Documentation

- [Testing Standards](../docs/development/TESTING_STANDARDS.md) - Detailed test requirements
- [LEAN Style Guide](../docs/development/LEAN_STYLE_GUIDE.md) - Code conventions
- [Implementation Status](../docs/project-info/IMPLEMENTATION_STATUS.md) - Module status

## Navigation

- **Up**: [Logos Root](../)
- **Source Code**: [Logos/](../Logos/)
- **Bimodal Library**: [Bimodal/](../Bimodal/)
- **Bimodal Tests**: [BimodalTest/](../BimodalTest/)
- **Documentation**: [docs/](../docs/)
- **Examples**: [Archive/](../Archive/)
