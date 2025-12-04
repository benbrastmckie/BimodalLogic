# ProofCheckerTest

Comprehensive test suite for ProofChecker, organized by module.

## Test Organization

Tests are organized by the module they test:

- **Syntax/**: Formula construction, context operations, DSL tests (when implemented)
  - FormulaTest.lean: Formula inductive type tests
  - ContextTest.lean: Proof context tests
- **ProofSystem/**: Axiom schema and inference rule validation
  - AxiomsTest.lean: TM axiom schemata tests
  - DerivationTest.lean: Derivability relation and inference rules
- **Semantics/**: Task frame semantics, model construction, validity
  - TaskFrameTest.lean: Task frame structure tests
  - TaskModelTest.lean: Model with valuation tests
  - TruthTest.lean: Truth evaluation tests
  - ValidityTest.lean: Validity and consequence tests
- **Integration/**: Cross-module integration tests
  - Tests that involve multiple modules working together
- **Metalogic/**: Soundness, completeness, and decidability property tests
  - SoundnessTest.lean: Soundness property tests
  - CompletenessTest.lean: Completeness property tests (when implemented)
- **Theorems/**: Tests for perpetuity principles and key theorems
  - PerpetuityTest.lean: Perpetuity principles P1-P6 tests
- **Automation/**: Tactic and proof search tests (when implemented)
  - TacticsTest.lean: Custom tactic tests
  - ProofSearchTest.lean: Automated proof search tests

## Running Tests

### Run All Tests

```bash
# Run entire test suite
lake test

# Expected output:
# Running tests...
# ✓ All tests passed
```

### Run Specific Module Tests

```bash
# Test specific module
lake test ProofCheckerTest.Syntax
lake test ProofCheckerTest.ProofSystem
lake test ProofCheckerTest.Semantics
lake test ProofCheckerTest.Integration
lake test ProofCheckerTest.Metalogic
lake test ProofCheckerTest.Theorems
lake test ProofCheckerTest.Automation

# Test specific file
lake env lean ProofCheckerTest/Syntax/FormulaTest.lean
lake env lean ProofCheckerTest/ProofSystem/AxiomsTest.lean
```

### Interpreting Output

- **✓ Green checkmarks**: Tests passed successfully
- **✗ Red errors**: Tests failed with error messages and line numbers
- **Test summary**: Shows pass/fail count at the end

**Common test failure patterns**:
- Type mismatch: Check that formula construction matches expected types
- Derivability failure: Ensure axioms and rules are correctly applied
- Validity failure: Check semantic model construction

### Running Tests in VS Code

1. Open test file in VS Code with lean4 extension
2. LEAN will type-check automatically
3. Errors appear inline with red squiggles
4. Hover over errors to see detailed messages

## Adding New Tests

### File Placement

**Unit tests** (testing single module in isolation):
- Formula tests → `Syntax/FormulaTest.lean`
- Axiom tests → `ProofSystem/AxiomsTest.lean`
- Semantics tests → `Semantics/TruthTest.lean`

**Integration tests** (testing module interactions):
- Place in `Integration/` directory
- Name descriptively: `ProofSystemSemantics.lean`, `SyntaxProofSystem.lean`

**Property-based tests** (testing general properties):
- Soundness tests → `Metalogic/SoundnessTest.lean`
- Completeness tests → `Metalogic/CompletenessTest.lean`

**Theorem tests** (testing specific theorems):
- Perpetuity tests → `Theorems/PerpetuityTest.lean`
- Other theorem tests → `Theorems/<TheoremName>Test.lean`

### Naming Conventions

**Files**: `<Module>Test.lean`
- Example: `FormulaTest.lean`, `AxiomsTest.lean`, `ValidityTest.lean`

**Tests**: `test_<feature>_<expected_behavior>`
- Example: `test_imp_reflexivity`, `test_modal_t_valid`, `test_modus_ponens`

**Modules**: `ProofCheckerTest.<Category>.<Module>Test`
- Example: `ProofCheckerTest.Syntax.FormulaTest`

### Test Categories

1. **Unit Tests**: Test individual functions/definitions in isolation
   - Formula construction correctness
   - Axiom schema instantiation
   - Truth evaluation for simple formulas

2. **Integration Tests**: Test interactions between modules
   - Derivability implies validity (soundness)
   - Axioms + rules work together
   - Syntax + semantics integration

3. **Property-Based Tests**: Test general properties hold
   - All axioms are valid
   - All inference rules preserve validity
   - Soundness: derivability implies validity

4. **Regression Tests**: Test fixed bugs to prevent recurrence
   - Add test when fixing a bug
   - Ensures bug doesn't reappear

### Test Template

```lean
/-!
# [Module] Tests

Tests for [module description].
-/

import ProofChecker.[Module]

namespace ProofCheckerTest.[Module]Test

-- Test helper functions (if needed)
def test_helper : Type := sorry

-- Unit test example
example : test_feature_works := by
  -- Test implementation
  sorry

-- Property test example
theorem test_property_holds : ∀ (x : Type), property x := by
  intro x
  -- Property proof
  sorry

end ProofCheckerTest.[Module]Test
```

## Test Quality Standards

### Coverage Requirements

See [TESTING_STANDARDS.md](../Documentation/Development/TESTING_STANDARDS.md) for detailed coverage targets:
- **Overall**: ≥85% code coverage
- **Metalogic**: ≥90% coverage (soundness/completeness critical)
- **Automation**: ≥80% coverage (tactics and proof search)
- **Error handling**: ≥75% coverage (error cases tested)

### Test Completeness

Each module should have tests for:
- ✓ **Happy path**: Normal usage scenarios
- ✓ **Edge cases**: Boundary conditions, empty inputs
- ✓ **Error cases**: Invalid inputs, type mismatches
- ✓ **Properties**: General properties that must hold
- ✓ **Integration**: Interactions with other modules

### Test Documentation

Every test should have:
- Module docstring explaining what is being tested
- Comments explaining complex test setup
- Clear assertion messages (when using custom assertions)

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

For detailed status, see [IMPLEMENTATION_STATUS.md](../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md).

## Performance Benchmarks

Test suite performance targets:
- **Full test suite**: <30 seconds
- **Single module tests**: <5 seconds
- **Individual test**: <1 second

If tests exceed these benchmarks:
1. Profile slow tests
2. Optimize test setup
3. Consider splitting large tests
4. Report performance issues

## Continuous Integration

Tests run automatically on:
- Every commit (local pre-commit hook)
- Every pull request (GitHub Actions)
- Every push to main branch

CI requirements:
- All tests must pass
- No new lint warnings
- Code coverage maintained

## Debugging Test Failures

### Common Issues

**"Type mismatch" errors**:
- Check formula construction syntax
- Verify types match expected signatures
- Use `#check` to inspect types

**"Derivation failed" errors**:
- Ensure axiom/rule correctly applied
- Check premise list is correct
- Verify formula matches axiom schema

**"Validity check failed" errors**:
- Inspect model construction
- Check frame properties (nullity, compositionality)
- Verify truth evaluation logic

### Debugging Tools

```lean
-- Type inspection
#check my_formula
#check my_derivation

-- Evaluate expressions
#eval my_computation

-- Reduce terms
#reduce my_expression

-- Print information
#print my_definition
```

## Coverage Tools

Check test coverage:

```bash
# Generate coverage report (if tooling available)
lake coverage

# View coverage by module
lake coverage --by-module
```

Coverage reports show:
- Lines executed by tests
- Branches tested
- Functions covered

## Related Documentation

- [Testing Standards](../Documentation/Development/TESTING_STANDARDS.md) - Detailed test requirements
- [Code Standards](../.claude/docs/reference/standards/code-standards.md) - TDD principles
- [LEAN Style Guide](../Documentation/Development/LEAN_STYLE_GUIDE.md) - Code conventions
- [Implementation Status](../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Module status

## Navigation

- **Up**: [ProofChecker Root](../)
- **Source Code**: [ProofChecker/](../ProofChecker/)
- **Documentation**: [Documentation/](../Documentation/)
- **Examples**: [Archive/](../Archive/)
