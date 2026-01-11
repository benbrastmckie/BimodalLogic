# Tests

This directory contains test suites for the formal logic theories.

## Structure

| Directory | Description |
|-----------|-------------|
| `BimodalTest/` | Tests for Bimodal TM logic |
| `LogosTest/` | Tests for Logos recursive semantics |

## BimodalTest

Comprehensive test coverage for the Bimodal library:
- `Syntax/` - Formula and context tests
- `ProofSystem/` - Axiom and derivation tests
- `Semantics/` - Truth and validity tests
- `Metalogic/` - Soundness and completeness tests
- `Automation/` - Tactic tests
- `Integration/` - End-to-end tests
- `Property/` - Property-based tests (Plausible)

See `BimodalTest/README.md` for testing standards.

## LogosTest

Tests for the Logos library:
- `Syntax.lean` - Formula syntax tests
- `Semantics.lean` - Constitutive semantics tests
- `Integration.lean` - Cross-layer integration tests

## Running Tests

Build all tests:
```bash
lake build BimodalTest LogosTest
```

Run the test executable:
```bash
lake exe test
```

## Adding Tests for a New Theory

1. Create `Tests/NewTheoryTest/` directory
2. Create `Tests/NewTheoryTest.lean` as the root module
3. Add `lean_lib NewTheoryTest` to `lakefile.lean`:
   ```lean
   lean_lib NewTheoryTest where
     srcDir := "Tests"
     roots := #[`NewTheoryTest]
     leanOptions := theoryLeanOptions
   ```
