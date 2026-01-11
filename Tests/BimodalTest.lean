import BimodalTest.Syntax.FormulaTest
import BimodalTest.Syntax.ContextTest
import BimodalTest.Syntax.FormulaPropertyTest
import BimodalTest.ProofSystem.AxiomsTest
import BimodalTest.ProofSystem.DerivationTest
import BimodalTest.ProofSystem.DerivationPropertyTest
import BimodalTest.Semantics.TruthTest
import BimodalTest.Semantics.TaskFrameTest
import BimodalTest.Semantics.SemanticPropertyTest
import BimodalTest.Metalogic.SoundnessTest
import BimodalTest.Metalogic.CompletenessTest
import BimodalTest.Metalogic.SoundnessPropertyTest
import BimodalTest.Theorems.PropositionalTest
import BimodalTest.Theorems.ModalS4Test
import BimodalTest.Theorems.ModalS5Test
import BimodalTest.Theorems.PerpetuityTest
import BimodalTest.Automation.ProofSearchTest
import BimodalTest.Automation.EdgeCaseTest
import BimodalTest.Automation.ProofSearchBenchmark
import BimodalTest.Automation.TacticsTest
import BimodalTest.Automation.TacticsTest_Simple
import BimodalTest.Integration.Helpers
import BimodalTest.Integration.EndToEndTest
import BimodalTest.Integration.ProofSystemSemanticsTest
import BimodalTest.Integration.AutomationProofSystemTest
import BimodalTest.Integration.ComplexDerivationTest
import BimodalTest.Integration.TemporalIntegrationTest
import BimodalTest.Integration.BimodalIntegrationTest
import BimodalTest.Property.Generators
import BimodalTest.Property

/-!
# BimodalTest - Test Suite for Bimodal TM Logic

Comprehensive test suite for the Bimodal library, following the Mathlib pattern
(Mathlib/ + MathlibTest/) with tests in a separate top-level directory.

## Test Organization

Tests mirror the Bimodal library structure:
- `Syntax/` - Formula and Context tests
- `ProofSystem/` - Axiom and Derivation tests
- `Semantics/` - Truth and TaskFrame tests
- `Metalogic/` - Soundness and Completeness tests
- `Theorems/` - Specific theorem tests (Perpetuity, Modal axioms)
- `Automation/` - Proof search and tactic tests
- `Integration/` - Cross-module integration tests
- `Property/` - Property-based tests with Plausible

## Running Tests

```bash
lake build BimodalTest    # Build test library
lake exe test             # Run test executable
```
-/

namespace BimodalTest

def version : String := "0.1.0"

end BimodalTest
