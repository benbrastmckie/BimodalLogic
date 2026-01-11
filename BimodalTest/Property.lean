import BimodalTest.Property.Generators
import BimodalTest.Syntax.FormulaPropertyTest
import BimodalTest.ProofSystem.DerivationPropertyTest
import BimodalTest.Semantics.SemanticPropertyTest
import BimodalTest.Metalogic.SoundnessPropertyTest

/-!
# Property-Based Tests

This module aggregates all property-based tests for the Logos proof checker.

## Overview

Property-based testing uses the Plausible framework to automatically generate
test cases and verify that properties hold across a wide range of inputs.

## Test Modules

- **Generators**: Type generators for Formula, Context, TaskFrame
- **FormulaPropertyTest**: Formula transformation and invariant properties
- **DerivationPropertyTest**: Derivation system structural properties
- **SemanticPropertyTest**: Task frame and semantic properties
- **SoundnessPropertyTest**: Axiom validity and soundness properties

## Running Property Tests

```bash
# Run all property tests
lake env lean BimodalTest/Property.lean

# Run specific property test module
lake env lean BimodalTest/Syntax/FormulaPropertyTest.lean
lake env lean BimodalTest/ProofSystem/DerivationPropertyTest.lean
lake env lean BimodalTest/Semantics/SemanticPropertyTest.lean
lake env lean BimodalTest/Metalogic/SoundnessPropertyTest.lean
```

## Test Configuration

Property tests are configured with:
- **numInst**: 100 test cases per property (default)
- **maxSize**: 30-50 for formula size (varies by test)
- **numRetries**: 20 for precondition retries (default)

## References

* [Property Testing Guide](../../Documentation/Development/PROPERTY_TESTING_GUIDE.md)
* [Plausible Framework](https://github.com/leanprover-community/plausible)
* [Research Report](../../.opencode/specs/174_property_based_testing/reports/research-001.md)
-/

namespace BimodalTest.Property

-- Re-export generators for convenience
open BimodalTest.Property.Generators

end BimodalTest.Property
