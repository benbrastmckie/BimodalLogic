# Integration Tests

This directory contains integration tests for the Logos proof system, verifying that all system components work together correctly.

## Overview

Integration tests verify the complete workflow from syntax through proof system to semantics and metalogic. They ensure that:

1. **Soundness holds**: Derivable formulas are semantically valid
2. **Automation works**: Tactics produce valid derivations
3. **Workflows function**: End-to-end proof construction succeeds
4. **Modules integrate**: Cross-module dependencies work correctly

## Test Files

### Core Integration Tests

| File | Tests | Purpose |
|------|-------|---------|
| **EndToEndTest.lean** | 6 | Basic end-to-end workflows |
| **ProofSystemSemanticsTest.lean** | 40 | Proof system ↔ semantics integration |
| **AutomationProofSystemTest.lean** | 60 | Automation ↔ proof system integration |

### Advanced Integration Tests

| File | Tests | Purpose |
|------|-------|---------|
| **ComplexDerivationTest.lean** | 10 | Complex multi-step derivations (5+ steps) |
| **TemporalIntegrationTest.lean** | 15 | Temporal axiom and operator workflows |
| **BimodalIntegrationTest.lean** | 15 | Modal-temporal interaction (MF/TF axioms) |

### Test Infrastructure

| File | Purpose |
|------|---------|
| **Helpers.lean** | Reusable test utilities and builders |
| **COVERAGE.md** | Coverage tracking and metrics |
| **README.md** | This file |

## Test Organization

Tests are organized by integration point:

```
Integration/
├── EndToEndTest.lean              # Basic workflows
├── ProofSystemSemanticsTest.lean  # PS ↔ Semantics
├── AutomationProofSystemTest.lean # Automation ↔ PS
├── ComplexDerivationTest.lean     # Complex derivations
├── TemporalIntegrationTest.lean   # Temporal workflows
├── BimodalIntegrationTest.lean    # Bimodal workflows
├── Helpers.lean                   # Test utilities
├── COVERAGE.md                    # Coverage tracking
└── README.md                      # This file
```

## Running Tests

### Run All Tests

```bash
# Build and run all tests
lake build
lake exe test

# Run with verbose output
lake test -- --verbose
```

### Run Specific Test File

```bash
# Run specific integration test file
lake env lean LogosTest/Core/Integration/ComplexDerivationTest.lean
```

### Check Build Status

```bash
# Verify compilation
lake build LogosTest.Integration
```

## Test Patterns

### Pattern 1: Proof-as-Test

Use theorems as integration tests where type-checking serves as assertion:

```lean
example : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  let deriv : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by tm_auto
  exact soundness [] _ deriv
```

### Pattern 2: Workflow Verification

Test complete workflows from derivation to validity:

```lean
example : True := by
  -- Step 1: Syntactic derivation
  let proof : ⊢ φ := ...
  
  -- Step 2: Apply soundness
  let valid : ⊨ φ := soundness [] φ proof
  
  -- Step 3: Verify semantic validity
  have : ∀ F M τ t ht, truth_at M τ t ht φ := valid
  
  trivial
```

### Pattern 3: Multi-Step Derivation

Test complex derivation chains:

```lean
example : True := by
  -- Step 1: First derivation
  let d1 : Γ ⊢ φ₁ := ...
  
  -- Step 2: Second derivation using d1
  let d2 : Γ ⊢ φ₂ := DerivationTree.modus_ponens ... d1 ...
  
  -- Step 3: Third derivation using d2
  let d3 : Γ ⊢ φ₃ := DerivationTree.modus_ponens ... d2 ...
  
  -- Verify soundness at each step
  have v1 : Γ ⊨ φ₁ := soundness Γ φ₁ d1
  have v2 : Γ ⊨ φ₂ := soundness Γ φ₂ d2
  have v3 : Γ ⊨ φ₃ := soundness Γ φ₃ d3
  
  trivial
```

## Using Test Helpers

The `Helpers.lean` module provides reusable utilities:

```lean
import LogosTest.Core.Integration.Helpers

open LogosTest.Core.Integration.Helpers

-- Build test formulas
let φ := mk_atom "p"
let ψ := mk_box φ
let χ := mk_future ψ

-- Build derivations
let deriv := mk_axiom_deriv (ψ.imp φ) (Axiom.modal_t φ)

-- Verify soundness
have valid := verify_validity (ψ.imp φ) deriv
```

## Coverage Metrics

Current integration test coverage:

- **Overall**: 82% (28/34 scenarios)
- **Axiom Integration**: 100% (15/15 axioms)
- **Inference Rules**: 100% (7/7 rules)
- **Proof System + Semantics**: 83% (10/12 scenarios)
- **Automation + Proof System**: 73% (8/11 scenarios)
- **Full Workflows**: 83% (5/6 scenarios)
- **Cross-Module Dependencies**: 100% (5/5 scenarios)

See [COVERAGE.md](COVERAGE.md) for detailed coverage tracking.

## Test Categories

### 1. Proof System + Semantics Integration

Tests verifying soundness theorem and semantic validity:

- **Files**: `ProofSystemSemanticsTest.lean`, `ComplexDerivationTest.lean`
- **Focus**: Derivation → Soundness → Validity workflow
- **Coverage**: All 15 axioms, all 7 inference rules

### 2. Automation + Proof System Integration

Tests verifying tactics produce valid derivations:

- **Files**: `AutomationProofSystemTest.lean`
- **Focus**: Tactic → Derivation → Soundness workflow
- **Coverage**: `tm_auto`, `apply_axiom`, specific tactics, Aesop rules

### 3. Full Workflow Integration

Tests verifying complete end-to-end workflows:

- **Files**: `EndToEndTest.lean`, `TemporalIntegrationTest.lean`, `BimodalIntegrationTest.lean`
- **Focus**: Syntax → Proof → Semantics → Verification
- **Coverage**: Basic, temporal, and bimodal workflows

### 4. Cross-Module Dependencies

Tests verifying module interactions:

- **Files**: All integration test files
- **Focus**: Syntax ↔ ProofSystem ↔ Semantics ↔ Metalogic
- **Coverage**: All module boundaries

## Writing New Integration Tests

### Step 1: Choose Test File

- **Basic workflow**: Add to `EndToEndTest.lean`
- **Axiom/rule soundness**: Add to `ProofSystemSemanticsTest.lean`
- **Automation**: Add to `AutomationProofSystemTest.lean`
- **Complex derivations**: Add to `ComplexDerivationTest.lean`
- **Temporal**: Add to `TemporalIntegrationTest.lean`
- **Bimodal**: Add to `BimodalIntegrationTest.lean`

### Step 2: Write Test

```lean
/--
Test N: Brief description.

Detailed explanation of what this test verifies.
-/
example : True := by
  -- Test implementation
  trivial
```

### Step 3: Verify Test

```bash
# Build and run
lake build
lake exe test

# Verify specific file
lake env lean LogosTest/Core/Integration/YourTestFile.lean
```

### Step 4: Update Coverage

Update `COVERAGE.md` with:
- New test count
- Coverage percentage
- Test file reference

## Best Practices

### DO

- ✓ Test complete workflows (derivation → soundness → validity)
- ✓ Verify soundness at each step of multi-step derivations
- ✓ Use descriptive test names and docstrings
- ✓ Test both positive cases (valid derivations) and edge cases
- ✓ Use test helpers from `Helpers.lean` for consistency
- ✓ Keep tests focused on integration, not unit testing

### DON'T

- ✗ Test individual functions (use unit tests instead)
- ✗ Duplicate tests across files
- ✗ Use `sorry` in integration tests
- ✗ Create tests that depend on unproven theorems
- ✗ Write tests without docstrings

## Performance Guidelines

- **Target**: < 2 minutes total test execution time
- **Per-test**: < 1 second average execution time
- **Optimization**: Use explicit derivations instead of tactics when possible
- **Monitoring**: Track execution time in CI/CD

## Troubleshooting

### Test Fails to Compile

```bash
# Check syntax errors
lake build LogosTest.Integration

# Check specific file
lake env lean LogosTest/Core/Integration/YourTestFile.lean
```

### Test Fails at Runtime

```bash
# Run with verbose output
lake test -- --verbose

# Check for sorry placeholders
grep -r "sorry" LogosTest/Core/Integration/
```

### Slow Test Execution

```bash
# Profile test execution
time lake exe test

# Identify slow tests
# (Use #time in Lean to profile individual tests)
```

## References

- [Testing Standards](../../../Documentation/Development/TESTING_STANDARDS.md)
- [Lean Style Guide](../../../Documentation/Development/LEAN_STYLE_GUIDE.md)
- [Architecture](../../../Documentation/UserGuide/ARCHITECTURE.md)
- [Soundness Theorem](../../../Logos/Core/Metalogic/Soundness.lean)

## Contributing

When adding new integration tests:

1. Follow the test patterns documented above
2. Update `COVERAGE.md` with new test information
3. Ensure all tests pass before committing
4. Run `lake lint` to check code quality
5. Add docstrings to all new tests

## Questions?

See the main [Testing Standards](../../../Documentation/Development/TESTING_STANDARDS.md) or ask in the project discussion forum.
