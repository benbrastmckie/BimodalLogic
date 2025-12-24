import LogosTest.Syntax
import LogosTest.ProofSystem
import LogosTest.Semantics
import LogosTest.Metalogic
import LogosTest.Integration
import LogosTest.Theorems
import LogosTest.Property

/-!
# Logos Test Suite Root

This is the main entry point for the Logos test suite, which provides
comprehensive testing for all modules in the Logos library.

## Overview

The test suite is organized to mirror the main library structure, providing:
- **Unit Tests**: Testing individual modules and functions
- **Integration Tests**: Testing interactions between modules
- **Metalogic Tests**: Verifying soundness and completeness properties
- **Example-Based Tests**: Testing via concrete examples

## Test Structure

The test suite mirrors the main library structure:

- `LogosTest.Syntax`: Tests for formula construction and parsing
- `LogosTest.ProofSystem`: Tests for axioms and inference rules
- `LogosTest.Semantics`: Tests for task semantics and validity
- `LogosTest.Integration`: Cross-module integration tests
- `LogosTest.Metalogic`: Soundness and completeness tests

## Test Naming Convention

Test files use the pattern `<Module>Test.lean` (e.g., `FormulaTest.lean`).
Test functions use the pattern `test_<feature>_<expected_behavior>`.

## Running Tests

Run all tests:
```bash
lake test
```

Run specific test module:
```bash
lake env lean LogosTest/Syntax/FormulaTest.lean
```
-/

namespace LogosTest

-- Test suite version (should match main library version)
def version : String := "0.1.0"

end LogosTest
