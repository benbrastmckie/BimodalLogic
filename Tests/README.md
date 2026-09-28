# Tests

This directory contains test suites for the formal logic theories.

## Structure

| Directory | Description |
|-----------|-------------|
| `BimodalTest/` | Tests for Bimodal TM logic |
| `BimodalToolsTest/` | Tests for the `BimodalTools` library (dataset tooling, the canonical wire codec, the source-sentence codec) |
| `fixtures/` | Committed data files a test reads with `include_str`, or that a consumer outside this repository compares against. Distinct from the repository-root `data/`, which is gitignored in its entirety and so cannot hold a shared artifact — see `fixtures/README.md` |

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

## Running Tests

Build all tests:
```bash
lake build BimodalTest
```

Run the test executable:
```bash
lake exe test
```

## Adding Tests for a New Theory

1. Create `Tests/NewTheoryTest/` directory
2. Create `Tests/NewTheoryTest.lean` as the root module
3. Add a `lean_lib` table for `NewTheoryTest` to `lakefile.toml`:
   ```toml
   [[lean_lib]]
   name = "NewTheoryTest"
   srcDir = "Tests"
   leanOptions = {pp.unicode.fun = true, autoImplicit = false}
   ```
