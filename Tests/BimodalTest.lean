/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTest.Syntax.FormulaTest
import BimodalTest.Syntax.ContextTest
import BimodalTest.Syntax.FormulaPropertyTest
import BimodalTest.ProofSystem.AxiomsTest
import BimodalTest.ProofSystem.DerivationTest
import BimodalTest.ProofSystem.DerivationPropertyTest
import BimodalTest.Semantics.TruthTest
import BimodalTest.Semantics.TaskFrameTest
import BimodalTest.Semantics.SemanticPropertyTest
import BimodalTest.Theorems.PropositionalTest
import BimodalTest.Theorems.ModalS4Test
import BimodalTest.Theorems.ModalS5Test
import BimodalTest.Theorems.PerpetuityTest
import BimodalTest.Metalogic.PropDecideTest
import BimodalTest.Automation.ProofSearchTest
import BimodalTest.Automation.EdgeCaseTest
import BimodalTest.Automation.ProofSearchBenchmark
import BimodalTest.Automation.TacticsTest
import BimodalTest.Automation.TacticsTest_Simple
import BimodalTest.Automation.LemmaDBTest
import BimodalTest.Automation.DeductionTest
import BimodalTest.Automation.C5SmokeTest
import BimodalTest.Automation.NormalizationTest
import BimodalTest.Automation.WeakeningSearchTest
import BimodalTest.Automation.InterestingnessTest
import BimodalTest.TraceCertificateTest
import BimodalTest.TraceExportTest
import BimodalTest.TraceExporterE2ETest
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
- Loose `Trace*Test.lean` - trace-certificate and trace-export round-trip tests

Every test module that can be imported here is imported above. Four are
deliberately excluded, for two different reasons:

- `ProofSystem/DerivationBenchmark.lean`, `Semantics/SemanticBenchmark.lean` —
  do not compile at all; they pass `String` where `Atom` is now required.
- `Automation/FormulaMutatorTest.lean`, `Automation/ProofFirstTests.lean` —
  compile in isolation but cannot be imported here. Each pulls in an executable
  root (`Automation/FormulaMutator.lean`, `Automation/ProofFirstExporter.lean`)
  that defines `main`, and this environment already has `main` from
  `Automation/DatasetValidator.lean`. Importing either yields
  "environment already contains 'main'". Fixing this means restructuring where
  `main` lives in the executable roots, not editing the tests.

All four are tracked in `scripts/module-invariants-manifest.txt`, which
compile-checks the importable ones in isolation, so excluded code cannot rot
unseen. A test module absent from both this file and that manifest is a gap in
the gate; the invariant check fails on exactly that condition.

## Running Tests

```bash
lake build BimodalTest    # Build test library
```
-/

namespace BimodalTest

def version : String := "0.1.0"

end BimodalTest
